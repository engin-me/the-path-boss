"""Terminal campaign. Run `python -m game.play_campaign` or add `--auto`."""

from __future__ import annotations

import argparse
import random
import sys

from game.campaign import (
    Career, FactoryCampaign, OFFERS, SKILLS, WORK_ROLES, autoplay,
)
from game.run_simulation import main as print_acceptance_scenarios
from game.simulation import amount


def ask(prompt: str, valid: set[str]) -> str:
    while True:
        answer = input(prompt).strip().lower()
        if answer in valid:
            return answer
        print("Geçerli seçenekler:", ", ".join(sorted(valid)))


def play_interactive() -> None:
    print("the Path - Boss | 3 ay kariyer + 3 ay fabrika")
    print("Bütün fiyat, puan ve süreler bu prototipe özgü test değerleridir.\n")
    career = Career()
    for _ in range(3):
        print(f"\nKariyer ayı {career.month} | kişisel para {career.cash} | enerji {career.energy}/6")
        print("1 CNC Operatörü: maaş 30, ağırlık Üretim")
        print("2 Takım Lideri: maaş 24, ağırlık Planlama/İnsan Yönetimi")
        print("İş değişimi: +2 zaman, o ay maaş −5. Aylık zaman: 8.")
        while True:
            job = {"1": "cnc", "2": "lider"}[ask("İş [1/2]: ", {"1", "2"})]
            print("0 Ek faaliyet yok | r Dinlen (+2 enerji) | Kurs: 10 para, +15 yetkinlik")
            for index, skill in enumerate(SKILLS, start=1):
                print(f"  {index} {skill}")
            secondary_raw = ask("Ek faaliyet [0/r/1-10]: ",
                                {"0", "r", *(str(n) for n in range(1, 11))})
            secondary = (None if secondary_raw == "0" else "rest" if secondary_raw == "r"
                         else SKILLS[int(secondary_raw) - 1])
            try:
                result = career.work_month(job, secondary)
                print(f"Ay sonu: {result.job}, maaş {result.wage}, kurs {result.course_fee}, "
                      f"para {result.cash_after}, enerji {result.energy_after}")
                print("Üretim", career.skills["Üretim"], "Planlama", career.skills["Planlama"],
                      "İnsan Yönetimi", career.skills["İnsan Yönetimi"])
                break
            except ValueError as error:
                print("Bu seçim yapılamıyor:", error)

    try:
        factory = career.found_small_factory()
    except ValueError as error:
        print("Fabrika kuruluşu başarısız:", error)
        return
    campaign = FactoryCampaign(career, factory)
    print(f"\nFabrika kuruldu. Şirket kasası {factory.cash}; ilk gider 50, "
          "gizli sorun üst güvencesi 20.")

    rng = random.Random()
    for _ in range(3):
        print(f"\nFabrika ayı {factory.month} | kasa {factory.cash}")
        print("1 Temkinli iş: 70 birim, birim gelir 1, bilinen iş maliyeti 8")
        print("2 Büyük iş: 100 birim, birim gelir 1,1, bilinen iş maliyeti 20")
        while True:
            offer = {"1": "temkinli", "2": "buyuk"}[ask("İş kabulü [1/2]: ", {"1", "2"})]
            try:
                report = campaign.start_month(offer)
                break
            except ValueError as error:
                print("İş kabul edilemedi:", error)
        print(f"Rapor: beklenen {report.expected}, kayıp "
              f"{sum(report.losses.values(), amount(0))}, "
              f"gerçekleşen {report.realized}, boş kapasite {report.empty_capacity}")
        print("Bu rapor ayın karar öncesi durumudur; Düzelt faydası sonraki raporda görünür.")

        while True:
            choices = campaign.problem_choices()
            if not choices:
                break
            print(f"Düzelt'e ayrılabilir para {factory.available_for_fix()}")
            print("0 Müdahale yok / ayı bitir")
            for index, (_, label, loss, upper) in enumerate(choices, start=1):
                print(f"{index} {label}: kayıp {loss}, en fazla bedel {upper}")
            selection = ask("Düzelt [0-" + str(len(choices)) + "]: ",
                            {str(n) for n in range(len(choices) + 1)})
            if selection == "0":
                break
            root_id = choices[int(selection) - 1][0]
            try:
                result = campaign.fix(root_id, amount(str(rng.random())))
                print(f"{'Başarılı' if result.success else 'Başarısız'}; "
                      f"{'kesin' if result.certain else 'olasılıklı'}, "
                      f"ödenen {result.money_paid}, harcanan saat {result.hours_used}")
            except ValueError as error:
                print("Düzelt yapılamadı:", error)
                break

        completed = campaign.finish_month()
        print(f"Ay sonu satış {completed.report.revenue}, kasa {completed.end_cash}, "
              f"borç açığı {completed.solvency.debt_gap}, "
              f"kurtarma eşiği {completed.solvency.rescue_threshold}")
        if completed.solvency.must_close:
            liquidation = factory.forced_liquidation(
                expected_wage=WORK_ROLES[career.current_job].wage,
                installment_rate=amount("0.20"), recovery_months=12,
            )
            print(f"İflas: şirket açığı {liquidation.company_shortfall}, "
                  f"kişisel borç {liquidation.personal_debt}")
            return
    print("\nÜç aylık prototip tamamlandı. Şirket kasası:", factory.cash)


def print_auto() -> None:
    print("KARİYER → FABRİKA: İKİ GEÇİCİ ROTA")
    for route in ("teknik", "dengeli"):
        career, career_months, factory_months = autoplay(route)
        print(f"\n{route.upper()} | Üretim {career.skills['Üretim']}, "
              f"Planlama {career.skills['Planlama']}, "
              f"İnsan Yönetimi {career.skills['İnsan Yönetimi']}")
        for month in career_months:
            secondary = "dinlenme" if month.secondary == "rest" else month.secondary or "ek faaliyet yok"
            print(f"  Kariyer {month.month}: {month.job}, "
                  f"{secondary}, para {month.cash_after}")
        for month in factory_months:
            actions = ", ".join(
                f"{game_root_label(root)}: {'başarılı' if result.success else 'başarısız'}"
                for root, result in month.fixes
            ) or "Düzelt yok"
            offer = "büyük iş" if month.offer == "buyuk" else "temkinli iş"
            print(f"  Fabrika {month.month}: {offer}, çıktı {month.report.realized}, "
                  f"{actions}, kasa {month.end_cash}")
    print("\nÖNCEKİ DÖRT KABUL SENARYOSU")
    print_acceptance_scenarios()


def game_root_label(root_id: str) -> str:
    return "Planlama" if root_id.startswith("planning") else "Üretim" if root_id == "production" else root_id


def main() -> None:
    parser = argparse.ArgumentParser(description="the Path - Boss terminal prototipi")
    parser.add_argument("--auto", action="store_true", help="iki kariyer rotasını ve dört kabul senaryosunu çalıştır")
    args = parser.parse_args()
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    try:
        if args.auto:
            print_auto()
        else:
            play_interactive()
    except (EOFError, KeyboardInterrupt):
        print("\nOyun sonlandırıldı.")


if __name__ == "__main__":
    main()
