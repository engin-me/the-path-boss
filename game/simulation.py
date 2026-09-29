"""Executable core for the illustrative acceptance scenarios in docs/04.

Numbers such as thresholds, prices and depreciation are injected by scenarios.
They are not final balance values or a replacement for CURRENT FREEZE files.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from decimal import Decimal
from typing import Mapping


def amount(value: int | float | str | Decimal) -> Decimal:
    return Decimal(str(value))


@dataclass(frozen=True)
class JobOffer:
    quantity: int
    unit_price: Decimal
    known_cost: Decimal = Decimal(0)
    minimum_quality: int = 0


@dataclass(frozen=True)
class ProblemRow:
    tier: int
    loss: Decimal


@dataclass
class ProblemRoot:
    department: str
    rows: tuple[ProblemRow, ...]
    active: bool = True
    attempted_month: int | None = None

    def __post_init__(self) -> None:
        tiers = [row.tier for row in self.rows]
        if not tiers or len(tiers) != len(set(tiers)) or max(tiers) - min(tiers) > 2:
            raise ValueError("A root needs distinct Tier rows at most two tiers apart")
        if any(row.loss < 0 for row in self.rows):
            raise ValueError("Problem loss cannot be negative")

    @property
    def deepest_tier(self) -> int:
        return max(row.tier for row in self.rows)

    @property
    def total_loss(self) -> Decimal:
        return sum((row.loss for row in self.rows), Decimal(0))


@dataclass(frozen=True)
class FixQuote:
    estimated_money: Decimal
    actual_money: Decimal
    upper_money: Decimal
    estimated_hours: Decimal
    actual_hours: Decimal
    upper_hours: Decimal

    def __post_init__(self) -> None:
        if not (0 <= self.estimated_money <= self.actual_money <= self.upper_money):
            raise ValueError("Money must obey estimate <= actual <= upper")
        if not (0 <= self.estimated_hours <= self.actual_hours <= self.upper_hours):
            raise ValueError("Hours must obey estimate <= actual <= upper")


@dataclass(frozen=True)
class MonthReport:
    month: int
    expected: int
    realized: Decimal
    revenue: Decimal
    losses: Mapping[str, Decimal]
    empty_capacity: int


@dataclass(frozen=True)
class Solvency:
    debt_gap: Decimal
    rescue_threshold: Decimal

    @property
    def must_close(self) -> bool:
        return self.debt_gap > self.rescue_threshold


@dataclass(frozen=True)
class FixResult:
    success: bool
    certain: bool
    money_paid: Decimal
    hours_used: Decimal


@dataclass(frozen=True)
class Liquidation:
    forced_sale_income: Decimal
    company_shortfall: Decimal
    personal_debt: Decimal


@dataclass
class PersonalDebt:
    remaining: Decimal
    installment_rate: Decimal

    def work_month(self, wage: Decimal) -> Decimal:
        if wage < 0:
            raise ValueError("Wage cannot be negative")
        paid = min(self.remaining, wage * self.installment_rate)
        self.remaining -= paid
        return paid


@dataclass
class Factory:
    cash: Decimal
    company_debt: Decimal
    asset_reference: Decimal
    max_gross_profit: Decimal
    ordinary_expense: Decimal
    machine_capacity: int
    machine_quality: int
    month: int = 1
    preparation_months: int = 0
    closed: bool = False
    problems: dict[str, ProblemRoot] = field(default_factory=dict)
    jobs: list[JobOffer] = field(default_factory=list)

    def _require_open(self) -> None:
        if self.closed:
            raise ValueError("Factory is closed")

    def add_problem(self, root_id: str, problem: ProblemRoot) -> None:
        self._require_open()
        if root_id in self.problems:
            raise ValueError("Root ID already exists")
        occupied = {
            (root.department, row.tier)
            for root in self.problems.values() if root.active
            for row in root.rows
        }
        if any((problem.department, row.tier) in occupied for row in problem.rows):
            raise ValueError("Only one active problem per department and Tier")
        self.problems[root_id] = problem

    def accept_job(self, offer: JobOffer) -> None:
        self._require_open()
        if self.preparation_months:
            raise ValueError("Production cannot start during preparation")
        if offer.quantity <= 0 or offer.unit_price < 0 or offer.known_cost < 0:
            raise ValueError("Invalid job offer")
        if offer.minimum_quality > self.machine_quality:
            raise ValueError("Machine does not meet offer requirements")
        if sum(job.quantity for job in self.jobs) + offer.quantity > self.machine_capacity:
            raise ValueError("The complete job exceeds capacity")
        self.jobs.append(offer)

    def available_for_fix(self, due_financing: Decimal = Decimal(0)) -> Decimal:
        return self.cash - self.ordinary_expense - sum(
            (job.known_cost for job in self.jobs), Decimal(0)
        ) - due_financing

    def report(self, *, department_cap: Decimal = Decimal("0.20")) -> MonthReport:
        self._require_open()
        expected = sum(job.quantity for job in self.jobs)
        losses: dict[str, Decimal] = {}
        for root in self.problems.values():
            if root.active:
                losses[root.department] = losses.get(root.department, Decimal(0)) + root.total_loss
        if any(loss > expected * department_cap for loss in losses.values()):
            raise ValueError("A department exceeds the fixture loss cap")
        total_loss = sum(losses.values(), Decimal(0))
        realized = Decimal(expected) - total_loss
        if realized < Decimal(expected) * Decimal("0.33"):
            raise ValueError("Problems exceed the minimum realization floor")
        units_left = realized
        revenue = Decimal(0)
        for job in self.jobs:
            delivered = min(units_left, Decimal(job.quantity))
            revenue += delivered * job.unit_price
            units_left -= delivered
        return MonthReport(
            self.month, expected, realized, revenue, losses,
            self.machine_capacity - expected,
        )

    def attempt_fix(
        self, root_id: str, *, patron_skill: int, advisor_skills: tuple[int, ...],
        thresholds: Mapping[int, int], quote: FixQuote, patron_hours: Decimal,
        success_chance_below_threshold: Decimal, roll: Decimal,
        due_financing: Decimal = Decimal(0),
    ) -> FixResult:
        self._require_open()
        root = self.problems[root_id]
        if not root.active or root.attempted_month == self.month:
            raise ValueError("This root cannot be attempted again this month")
        if self.available_for_fix(due_financing) < quote.upper_money:
            raise ValueError("Not enough unreserved cash for upper guarantee")
        if patron_hours < quote.upper_hours:
            raise ValueError("Not enough patron time for upper guarantee")
        effective_skill = max((patron_skill, *advisor_skills))
        certain = effective_skill >= thresholds[root.deepest_tier]
        if not (0 <= success_chance_below_threshold <= 1 and 0 <= roll < 1):
            raise ValueError("Invalid probability or roll")
        success = certain or roll < success_chance_below_threshold
        paid = quote.actual_money if success else quote.estimated_money
        hours = quote.actual_hours if success else quote.estimated_hours
        self.cash -= paid
        root.attempted_month = self.month
        if success:
            root.active = False
        return FixResult(success, certain, paid, hours)

    def solvency(self) -> Solvency:
        net_contribution = max(Decimal(0), self.max_gross_profit - self.ordinary_expense)
        return Solvency(
            max(Decimal(0), self.company_debt - self.cash),
            self.asset_reference * Decimal("0.50") + net_contribution * 6,
        )

    def preview_asset_sale(self, reference_sold: Decimal, net_contribution_lost: Decimal) -> Solvency:
        self._require_open()
        if not (0 <= reference_sold <= self.asset_reference):
            raise ValueError("Invalid asset reference")
        remaining_net = max(
            Decimal(0), self.max_gross_profit - self.ordinary_expense - net_contribution_lost
        )
        return Solvency(
            max(Decimal(0), self.company_debt - (self.cash + reference_sold * Decimal("0.70"))),
            (self.asset_reference - reference_sold) * Decimal("0.50") + remaining_net * 6,
        )

    def take_credit(self, amount: Decimal) -> None:
        self._require_open()
        if amount < 0:
            raise ValueError("Credit cannot be negative")
        self.cash += amount
        self.company_debt += amount

    def end_month(
        self, report: MonthReport | None = None, *,
        other_operating_cash: Decimal = Decimal(0),
        finance_charge: Decimal = Decimal(0),
        asset_depreciation: Decimal = Decimal(0),
    ) -> Solvency:
        self._require_open()
        if self.preparation_months:
            raise ValueError("Preparation requires advance_preparation")
        if report is not None and report.month != self.month:
            raise ValueError("Report belongs to a different month")
        if finance_charge < 0 or asset_depreciation < 0:
            raise ValueError("Expenses and depreciation cannot be negative")
        self.cash += (report.revenue if report else Decimal(0)) + other_operating_cash
        self.cash -= self.ordinary_expense + sum(
            (job.known_cost for job in self.jobs), Decimal(0)
        ) + finance_charge
        self.asset_reference = max(Decimal(0), self.asset_reference - asset_depreciation)
        self.jobs.clear()
        status = self.solvency()
        self.month += 1
        return status

    def forced_liquidation(
        self, *, expected_wage: Decimal, installment_rate: Decimal,
        recovery_months: int,
    ) -> Liquidation:
        self._require_open()
        if not self.solvency().must_close:
            raise ValueError("Forced liquidation requires the bankruptcy threshold")
        proceeds = self.asset_reference * Decimal("0.50")
        shortfall = max(Decimal(0), self.company_debt - self.cash - proceeds)
        personal_cap = expected_wage * installment_rate * recovery_months
        self.closed = True
        return Liquidation(proceeds, shortfall, min(shortfall, personal_cap))

    def transfer_business(
        self, *, sale_value: Decimal, rebuilding_cost: Decimal,
        proven_profit: bool,
    ) -> Decimal:
        self._require_open()
        if not proven_profit or sale_value > rebuilding_cost or sale_value < 0:
            raise ValueError("Business sale has no proven or capped valuation")
        personal_proceeds = self.cash + sale_value - self.company_debt
        if personal_proceeds < 0:
            raise ValueError("Company debt remains; no personal payout")
        self.closed = True
        return personal_proceeds

    def advance_preparation(self, expense: Decimal) -> None:
        self._require_open()
        if self.preparation_months <= 0 or expense < 0:
            raise ValueError("No preparation month or invalid expense")
        self.cash -= expense
        self.preparation_months -= 1
        self.month += 1

    def meets_small_factory_reserve(self, upper_hidden_guarantee: Decimal) -> bool:
        return self.cash >= self.ordinary_expense + upper_hidden_guarantee
