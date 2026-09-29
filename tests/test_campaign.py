"""Whole-journey checks for the short playable career-to-factory slice."""

import io
import unittest
from unittest.mock import patch

from game.campaign import Career, FactoryCampaign, autoplay, chance_for_gap
from game.play_campaign import play_interactive
from game.simulation import amount


class CareerToFactory(unittest.TestCase):
    def test_career_routes_change_factory_knowledge_and_results(self) -> None:
        technical, _, technical_months = autoplay("teknik")
        balanced, _, balanced_months = autoplay("dengeli")
        self.assertEqual((technical.skills["Üretim"], technical.skills["Planlama"]),
                         (94, 31))
        self.assertEqual((balanced.skills["Üretim"], balanced.skills["Planlama"]),
                         (80, 56))
        self.assertFalse(technical_months[0].fixes[0][1].certain)
        self.assertTrue(balanced_months[0].fixes[0][1].certain)
        self.assertEqual([month.report.realized for month in balanced_months],
                         list(map(amount, (50, 90, 95))))
        self.assertEqual([month.end_cash for month in technical_months],
                         list(map(amount, (133, 139, "158.5"))))
        self.assertEqual([month.end_cash for month in balanced_months],
                         list(map(amount, (79, 104, "126.5"))))

    def test_time_and_energy_are_real_opportunity_costs(self) -> None:
        career = Career()
        career.work_month("cnc", "Planlama")
        self.assertEqual(career.energy, 4)
        with self.assertRaisesRegex(ValueError, "energy"):
            career.work_month("cnc", "Planlama")
        with self.assertRaisesRegex(ValueError, "time"):
            career.work_month("lider", "Planlama")
        self.assertEqual(career.month, 2)
        self.assertEqual(career.skills["Planlama"], 42)

    def test_factory_access_depends_on_cash_not_all_skills(self) -> None:
        career = Career()
        for _ in range(3):
            career.work_month("cnc", "rest")
        self.assertEqual(career.skills["Planlama"], 31)
        factory = career.found_small_factory()
        self.assertEqual(factory.cash, amount(120))
        self.assertEqual(career.cash, amount(0))

    def test_job_cost_reserve_can_block_fix(self) -> None:
        career = Career()
        for _ in range(3):
            career.work_month("cnc", "rest")
        factory = career.found_small_factory()
        factory.cash = amount(80)
        game = FactoryCampaign(career, factory)
        game.start_month("buyuk")
        self.assertEqual(factory.available_for_fix(), amount(10))
        with self.assertRaisesRegex(ValueError, "unreserved cash"):
            game.fix("planning_1", amount("0.9"))
        self.assertEqual(factory.cash, amount(80))

    def test_distinct_roots_can_be_fixed_in_same_month(self) -> None:
        career = Career()
        for _ in range(3):
            career.work_month("cnc", "rest")
        game = FactoryCampaign(career, career.found_small_factory())
        game.start_month("buyuk")
        first = game.fix("planning_1", amount("0.9"))
        second = game.fix("production", amount("0.9"))
        self.assertFalse(first.success)
        self.assertTrue(second.success)
        completed = game.finish_month()
        self.assertEqual(len(completed.fixes), 2)
        self.assertEqual(completed.report.realized, amount(80))
        self.assertFalse(game.factory.problems["production"].active)

    def test_hidden_rows_share_quote_and_chance_follows_tier_gap(self) -> None:
        career = Career()
        for _ in range(3):
            career.work_month("cnc", "rest")
        game = FactoryCampaign(career, career.found_small_factory())
        career.skills["Planlama"] = 20  # reaches no Tier: T1 and T2 both hidden
        quote = game.quote_for(game.factory.problems["planning_1"])
        self.assertEqual((quote.estimated_money, quote.upper_money), (amount(2), amount(20)))
        self.assertEqual(chance_for_gap(1), amount("0.80"))
        self.assertEqual(chance_for_gap(2), amount("0.40"))
        self.assertEqual(chance_for_gap(4), amount("0.05"))

    def test_terminal_can_finish_six_months_without_random_fix(self) -> None:
        answers = ["1", "r", "1", "r", "1", "r", "2", "0", "2", "0", "2", "0"]
        with patch("builtins.input", side_effect=answers), patch("sys.stdout", new=io.StringIO()) as output:
            play_interactive()
        self.assertIn("Üç aylık prototip tamamlandı", output.getvalue())


if __name__ == "__main__":
    unittest.main()
