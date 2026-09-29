"""Three career months followed by three factory months, using fixture values.

This is an interactive prototype of CURRENT FREEZE structure. Career gains,
prices, probabilities and month counts are illustrative balance inputs.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from decimal import Decimal
from random import Random

from game.simulation import (
    Factory, FixQuote, FixResult, JobOffer, MonthReport, ProblemRoot, ProblemRow,
    Solvency, amount,
)


SKILLS = (
    "Üretim", "Planlama", "Depo & Sevkiyat", "Bakım", "Kalite",
    "Satın Alma", "Finans", "Ar-Ge / Ür-Ge", "Yatırım", "İnsan Yönetimi",
)
THRESHOLDS = {1: 30, 2: 50}


@dataclass(frozen=True)
class WorkRole:
    title: str
    wage: Decimal
    gains: dict[str, int]


WORK_ROLES = {
    "cnc": WorkRole("CNC Operatörü", amount(30),
                    {"Üretim": 18, "Kalite": 4, "Bakım": 2, "Planlama": 2}),
    "lider": WorkRole("Takım Lideri", amount(24),
                      {"İnsan Yönetimi": 15, "Planlama": 12,
                       "Üretim": 4, "Kalite": 4}),
}


@dataclass(frozen=True)
class CareerMonth:
    month: int
    job: str
    secondary: str | None
    wage: Decimal
    course_fee: Decimal
    switch_cost_hours: int
    cash_after: Decimal
    energy_after: int


@dataclass
class Career:
    cash: Decimal = Decimal(60)
    energy: int = 6
    month: int = 1
    current_job: str | None = None
    skills: dict[str, int] = field(default_factory=lambda: {
        name: (40 if name == "Üretim" else 25 if name == "Planlama" else 20)
        for name in SKILLS
    })

    def work_month(self, job: str, secondary: str | None = None) -> CareerMonth:
        if self.month > 3:
            raise ValueError("The prototype has three career months")
        if job not in WORK_ROLES:
            raise ValueError("Unknown job")
        if secondary not in (None, "rest", *SKILLS):
            raise ValueError("Unknown course or rest choice")
        switching = self.current_job is not None and job != self.current_job
        switch_hours = 2 if switching else 0
        time_used = 5 + switch_hours + (3 if secondary is not None else 0)
        energy_used = 3 + (2 if secondary in SKILLS else 0)
        if time_used > 8:
            raise ValueError("Not enough time; switching jobs uses two hours")
        if energy_used > self.energy:
            raise ValueError("Not enough energy for work and course")
        course_fee = amount(10) if secondary in SKILLS else amount(0)
        if self.cash < course_fee:
            raise ValueError("Not enough personal cash for course")

        role = WORK_ROLES[job]
        wage = role.wage - (amount(5) if switching else amount(0))
        current_month = self.month
        self.cash += wage - course_fee
        for skill, gain in role.gains.items():
            self.skills[skill] = min(100, self.skills[skill] + gain)
        if secondary in SKILLS:
            self.skills[secondary] = min(100, self.skills[secondary] + 15)
        self.energy = min(6, self.energy - energy_used + (2 if secondary == "rest" else 0) + 3)
        self.current_job = job
        self.month += 1
        return CareerMonth(current_month, role.title, secondary, wage, course_fee,
                           switch_hours, self.cash, self.energy)

    def found_small_factory(self) -> Factory:
        if self.month <= 3:
            raise ValueError("Finish the prototype career period first")
        company_cash = self.cash - amount(30)  # fixture machine purchase
        if company_cash < amount(50 + 20):  # first ordinary cost + small-scale upper guarantee
            raise ValueError("Startup cash does not cover known costs and hidden guarantee")
        self.cash = amount(0)
        factory = Factory(
            cash=company_cash, company_debt=amount(0), asset_reference=amount(30),
            max_gross_profit=amount(70), ordinary_expense=amount(50),
            machine_capacity=100, machine_quality=1,
        )
        factory.add_problem("planning_1", ProblemRoot("Planlama", (ProblemRow(2, amount(10)),)))
        factory.add_problem("production", ProblemRoot("Üretim", (ProblemRow(1, amount(10)),)))
        return factory


OFFERS = {
    "temkinli": JobOffer(70, amount(1), known_cost=amount(8), minimum_quality=1),
    "buyuk": JobOffer(100, amount("1.1"), known_cost=amount(20), minimum_quality=1),
}
QUOTES = {
    1: FixQuote(amount(2), amount(4), amount(4), amount(1), amount(1), amount(2)),
    2: FixQuote(amount(5), amount(12), amount(20), amount(1), amount(2), amount(3)),
}


@dataclass(frozen=True)
class FactoryMonth:
    month: int
    offer: str
    report: MonthReport
    fixes: tuple[tuple[str, FixResult], ...]
    end_cash: Decimal
    solvency: Solvency


class FactoryCampaign:
    def __init__(self, career: Career, factory: Factory) -> None:
        self.career = career
        self.factory = factory
        self.pending_offer: str | None = None
        self.pending_report: MonthReport | None = None
        self.pending_fixes: list[tuple[str, FixResult]] = []

    def start_month(self, offer: str) -> MonthReport:
        if self.pending_report is not None:
            raise ValueError("Finish the current month first")
        if self.factory.month > 3:
            raise ValueError("The prototype has three factory months")
        if offer not in OFFERS:
            raise ValueError("Unknown offer")
        job = OFFERS[offer]
        if self.factory.cash < self.factory.ordinary_expense + job.known_cost:
            raise ValueError("Not enough cash to cover known monthly costs")
        if self.factory.month == 3 and not self.factory.problems["planning_1"].active:
            self.factory.add_problem(
                "planning_2", ProblemRoot("Planlama", (ProblemRow(2, amount(5)),))
            )
        self.factory.accept_job(job)
        self.pending_offer = offer
        self.pending_report = self.factory.report()
        return self.pending_report

    def problem_choices(self) -> list[tuple[str, str, Decimal, Decimal]]:
        if self.pending_report is None:
            raise ValueError("Accept a job first")
        choices = []
        for root_id, root in self.factory.problems.items():
            if not root.active or root.attempted_month == self.factory.month:
                continue
            visible = self.career.skills[root.department] >= THRESHOLDS[root.deepest_tier]
            label = f"{root.department} T{root.deepest_tier}" if visible else f"{root.department}: derinlik bilinmiyor"
            choices.append((root_id, label, root.total_loss, QUOTES[root.deepest_tier].upper_money))
        return choices

    def fix(self, root_id: str, roll: Decimal) -> FixResult:
        if self.pending_report is None:
            raise ValueError("Accept a job first")
        root = self.factory.problems[root_id]
        remaining_hours = amount(6) - sum(
            (result.hours_used for _, result in self.pending_fixes), amount(0)
        )
        result = self.factory.attempt_fix(
            root_id, patron_skill=self.career.skills[root.department],
            advisor_skills=(), thresholds=THRESHOLDS,
            quote=QUOTES[root.deepest_tier], patron_hours=remaining_hours,
            success_chance_below_threshold=amount("0.40"), roll=roll,
        )
        self.pending_fixes.append((root_id, result))
        return result

    def finish_month(self) -> FactoryMonth:
        if self.pending_report is None or self.pending_offer is None:
            raise ValueError("Accept a job first")
        report = self.pending_report
        month = self.factory.month
        offer = self.pending_offer
        solvency = self.factory.end_month(report, asset_depreciation=amount(1))
        completed = FactoryMonth(month, offer, report, tuple(self.pending_fixes),
                                 self.factory.cash, solvency)
        self.pending_offer = None
        self.pending_report = None
        self.pending_fixes = []
        return completed


def autoplay(route: str) -> tuple[Career, list[CareerMonth], list[FactoryMonth]]:
    """Two deterministic strategies to compare career history with factory decisions."""
    if route not in ("teknik", "dengeli"):
        raise ValueError("Route must be teknik or dengeli")
    career = Career()
    career_actions = (
        (("cnc", "rest"), ("cnc", "rest"), ("cnc", "rest"))
        if route == "teknik" else
        (("cnc", "Planlama"), ("cnc", "rest"), ("lider", None))
    )
    career_trace = [career.work_month(*action) for action in career_actions]
    campaign = FactoryCampaign(career, career.found_small_factory())
    factory_actions = (
        (("buyuk", "planning_1", "0.90"),
         ("buyuk", "planning_1", "0.10"),
         ("buyuk", "production", "0.90"))
        if route == "teknik" else
        (("temkinli", "planning_1", "0.90"),
         ("buyuk", "production", "0.90"),
         ("buyuk", "planning_2", "0.90"))
    )
    factory_trace = []
    for offer, root_id, roll in factory_actions:
        campaign.start_month(offer)
        campaign.fix(root_id, amount(roll))
        factory_trace.append(campaign.finish_month())
    return career, career_trace, factory_trace
