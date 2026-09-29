"""Acceptance checks from docs/04, plus safeguards against key rule regressions."""

import unittest

from game.scenarios import bankruptcy_and_return, crisis, first_factory, successful_transfer
from game.simulation import (
    Factory, FixQuote, JobOffer, PersonalDebt, ProblemRoot, ProblemRow, amount,
)


class AcceptanceScenarios(unittest.TestCase):
    def test_first_factory_three_months(self) -> None:
        outcome = first_factory()
        self.assertEqual(outcome["available"], list(map(amount, (70, 75, 73))))
        self.assertEqual([r.realized for r in outcome["reports"]],
                         list(map(amount, (80, 80, 85))))
        self.assertEqual([r.revenue for r in outcome["reports"]],
                         list(map(amount, (60, 60, "63.75"))))
        self.assertEqual([f.success for f in outcome["fixes"]], [False, True, False])
        self.assertEqual(outcome["cash"], list(map(amount, (125, 123, "131.75"))))
        self.assertFalse(outcome["factory"].problems["planning_1"].active)

    def test_crisis_with_depreciation_and_finance_charge(self) -> None:
        outcome = crisis()
        self.assertEqual((outcome["initial"].debt_gap,
                          outcome["initial"].rescue_threshold),
                         (amount(120), amount(170)))
        self.assertEqual((outcome["sale_preview"].debt_gap,
                          outcome["sale_preview"].rescue_threshold),
                         (amount(92), amount(78)))
        self.assertTrue(outcome["sale_preview"].must_close)
        self.assertEqual(outcome["after_credit"].debt_gap, outcome["initial"].debt_gap)
        self.assertEqual([(s.debt_gap, s.rescue_threshold) for s in outcome["month_ends"]],
                         [(amount(125), amount(169)), (amount(168), amount(168)),
                          (amount(169), amount(167))])
        self.assertEqual([s.must_close for s in outcome["month_ends"]],
                         [False, False, True])
        self.assertEqual(outcome["factory"].asset_reference, amount(94))

    def test_bankruptcy_recovery(self) -> None:
        outcome = bankruptcy_and_return()
        self.assertEqual(outcome["liquidation"].forced_sale_income, amount(47))
        self.assertEqual(outcome["liquidation"].company_shortfall, amount(122))
        self.assertEqual(outcome["liquidation"].personal_debt, amount(24))
        self.assertEqual(outcome["payments"], [amount(2)] * 12)
        self.assertEqual(outcome["balances"], list(map(amount, range(22, -1, -2))))
        self.assertEqual(outcome["debt"].remaining, amount(0))

    def test_successful_transfer_and_preparation(self) -> None:
        outcome = successful_transfer()
        self.assertEqual(outcome["payout"], amount(340))
        self.assertEqual(outcome["after_preparation"], amount(90))
        self.assertTrue(outcome["reserve_ok"])
        self.assertEqual(outcome["available"], amount(50))
        self.assertEqual(outcome["report"].revenue, amount(50))
        self.assertTrue(outcome["fix"].certain)
        self.assertEqual(outcome["new"].cash, amount(90))


class RuleBoundaries(unittest.TestCase):
    def setUp(self) -> None:
        self.factory = Factory(
            cash=amount(70), company_debt=amount(0), asset_reference=amount(50),
            max_gross_profit=amount(30), ordinary_expense=amount(50),
            machine_capacity=100, machine_quality=1,
        )
        self.factory.add_problem(
            "root", ProblemRoot("Planlama", (ProblemRow(1, amount(5)),
                                            ProblemRow(2, amount(10))))
        )
        self.factory.accept_job(JobOffer(100, amount(1)))
        self.quote = FixQuote(amount(5), amount(12), amount(20),
                              amount(1), amount(2), amount(3))

    def test_reserved_cash_and_time_block_fix(self) -> None:
        with self.assertRaisesRegex(ValueError, "patron time"):
            self.factory.attempt_fix(
                "root", patron_skill=60, advisor_skills=(), thresholds={1: 30, 2: 50},
                quote=self.quote, patron_hours=amount(2),
                success_chance_below_threshold=amount(0), roll=amount("0.5"),
            )
        self.factory.cash -= amount(1)
        with self.assertRaisesRegex(ValueError, "unreserved cash"):
            self.factory.attempt_fix(
                "root", patron_skill=60, advisor_skills=(), thresholds={1: 30, 2: 50},
                quote=self.quote, patron_hours=amount(3),
                success_chance_below_threshold=amount(0), roll=amount("0.5"),
            )

    def test_common_root_uses_deepest_tier_and_locks_after_failure(self) -> None:
        result = self.factory.attempt_fix(
            "root", patron_skill=35, advisor_skills=(), thresholds={1: 30, 2: 50},
            quote=self.quote, patron_hours=amount(3),
            success_chance_below_threshold=amount("0.25"), roll=amount("0.8"),
        )
        self.assertFalse(result.success)
        self.assertFalse(result.certain)
        self.assertEqual(result.money_paid, amount(5))
        with self.assertRaisesRegex(ValueError, "again this month"):
            self.factory.attempt_fix(
                "root", patron_skill=35, advisor_skills=(100,),
                thresholds={1: 30, 2: 50}, quote=self.quote,
                patron_hours=amount(3), success_chance_below_threshold=amount(1),
                roll=amount(0),
            )
        self.factory.end_month(self.factory.report())
        self.factory.cash += amount(15)
        result = self.factory.attempt_fix(
            "root", patron_skill=35, advisor_skills=(50,), thresholds={1: 30, 2: 50},
            quote=self.quote, patron_hours=amount(3),
            success_chance_below_threshold=amount(0), roll=amount("0.99"),
        )
        self.assertTrue(result.certain)
        self.assertTrue(result.success)
        self.assertFalse(self.factory.problems["root"].active)

    def test_complete_jobs_only_and_empty_capacity(self) -> None:
        report = self.factory.report()
        self.assertEqual((report.expected, report.realized, report.empty_capacity),
                         (100, amount(85), 0))
        with self.assertRaisesRegex(ValueError, "capacity"):
            self.factory.accept_job(JobOffer(1, amount(1)))
        with self.assertRaisesRegex(ValueError, "requirements"):
            other = Factory(amount(100), amount(0), amount(10), amount(0),
                            amount(0), 100, 1)
            other.accept_job(JobOffer(50, amount(1), minimum_quality=2))

    def test_personal_debt_pauses_when_unemployed(self) -> None:
        debt = PersonalDebt(amount(24), amount("0.2"))
        self.assertEqual(debt.work_month(amount(0)), amount(0))
        self.assertEqual(debt.remaining, amount(24))

    def test_global_output_floor_rejects_excess_problem_generation(self) -> None:
        factory = Factory(amount(100), amount(0), amount(10), amount(0),
                          amount(0), 100, 1)
        factory.accept_job(JobOffer(100, amount(1)))
        for index in range(4):
            factory.add_problem(
                f"root_{index}",
                ProblemRoot(f"department_{index}", (ProblemRow(1, amount(20)),)),
            )
        with self.assertRaisesRegex(ValueError, "minimum realization floor"):
            factory.report()

    def test_uncapped_or_unproven_business_sale_rejected(self) -> None:
        with self.assertRaises(ValueError):
            self.factory.transfer_business(sale_value=amount(100),
                                           rebuilding_cost=amount(90), proven_profit=True)
        with self.assertRaises(ValueError):
            self.factory.transfer_business(sale_value=amount(50),
                                           rebuilding_cost=amount(90), proven_profit=False)


if __name__ == "__main__":
    unittest.main()
