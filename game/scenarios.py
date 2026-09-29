"""Illustrative fixtures matching docs/04_ACCEPTANCE_SCENARIOS.md."""

from __future__ import annotations

from decimal import Decimal

from game.simulation import (
    Factory, FixQuote, JobOffer, PersonalDebt, ProblemRoot, ProblemRow, amount,
)


def first_factory() -> dict:
    factory = Factory(
        cash=amount(120), company_debt=amount(0), asset_reference=amount(100),
        max_gross_profit=amount(50), ordinary_expense=amount(50),
        machine_capacity=100, machine_quality=1,
    )
    factory.add_problem("planning_1", ProblemRoot("Planlama", (ProblemRow(2, amount(10)),)))
    factory.add_problem("production", ProblemRoot("Üretim", (ProblemRow(1, amount(10)),)))
    quote = FixQuote(amount(5), amount(12), amount(20), amount(1), amount(2), amount(3))
    reports, cash, available, results = [], [], [], []
    for index, roll in enumerate((amount("0.9"), amount("0.1"), amount("0.9"))):
        if index == 2:
            factory.add_problem("planning_2", ProblemRoot("Planlama", (ProblemRow(2, amount(5)),)))
        factory.accept_job(JobOffer(100, amount("0.75")))
        report = factory.report()
        reports.append(report)
        available.append(factory.available_for_fix())
        result = factory.attempt_fix(
            "planning_1" if index < 2 else "planning_2",
            patron_skill=35, advisor_skills=(), thresholds={1: 30, 2: 50},
            quote=quote, patron_hours=amount(10),
            success_chance_below_threshold=amount("0.5"), roll=roll,
        )
        results.append(result)
        factory.end_month(report)
        cash.append(factory.cash)
    return {"factory": factory, "reports": reports, "cash": cash,
            "available": available, "fixes": results}


def crisis() -> dict:
    factory = Factory(
        cash=amount(20), company_debt=amount(140), asset_reference=amount(100),
        max_gross_profit=amount(20), ordinary_expense=amount(0),
        machine_capacity=0, machine_quality=0,
    )
    initial = factory.solvency()
    sale_preview = factory.preview_asset_sale(amount(40), amount(12))
    factory.take_credit(amount(30))
    after_credit = factory.solvency()
    month_ends = []
    for operating_cash in (-3, -41, 1):
        month_ends.append(factory.end_month(
            other_operating_cash=amount(operating_cash),
            finance_charge=amount(2), asset_depreciation=amount(2),
        ))
    return {"factory": factory, "initial": initial, "sale_preview": sale_preview,
            "after_credit": after_credit, "month_ends": month_ends}


def bankruptcy_and_return() -> dict:
    failed_factory = crisis()["factory"]
    liquidation = failed_factory.forced_liquidation(
        expected_wage=amount(10), installment_rate=amount("0.20"), recovery_months=12,
    )
    debt = PersonalDebt(liquidation.personal_debt, amount("0.20"))
    payments, balances = [], []
    for _ in range(12):
        payments.append(debt.work_month(amount(10)))
        balances.append(debt.remaining)
    return {"liquidation": liquidation, "payments": payments,
            "balances": balances, "debt": debt}


def successful_transfer() -> dict:
    old = Factory(
        cash=amount(200), company_debt=amount(20), asset_reference=amount(100),
        max_gross_profit=amount(50), ordinary_expense=amount(20),
        machine_capacity=100, machine_quality=1,
    )
    payout = old.transfer_business(
        sale_value=amount(160), rebuilding_cost=amount(180), proven_profit=True,
    )
    new = Factory(
        cash=payout - amount(230), company_debt=amount(0),
        asset_reference=amount(230), max_gross_profit=amount(60),
        ordinary_expense=amount(40), machine_capacity=100, machine_quality=2,
        preparation_months=1,
    )
    new.advance_preparation(amount(20))
    after_preparation = new.cash
    reserve_ok = new.meets_small_factory_reserve(amount(20))
    new.accept_job(JobOffer(55, amount(1), minimum_quality=2))
    new.add_problem("planning", ProblemRoot("Planlama", (ProblemRow(2, amount(5)),)))
    report = new.report()
    available = new.available_for_fix()
    fix = new.attempt_fix(
        "planning", patron_skill=60, advisor_skills=(), thresholds={2: 50},
        quote=FixQuote(amount(5), amount(10), amount(20),
                       amount(1), amount(2), amount(3)),
        patron_hours=amount(10), success_chance_below_threshold=Decimal(0),
        roll=amount("0.99"),
    )
    new.end_month(report)
    return {"old": old, "new": new, "payout": payout,
            "after_preparation": after_preparation, "reserve_ok": reserve_ok,
            "available": available, "report": report, "fix": fix}
