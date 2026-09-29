"""Print the four acceptance scenario outcomes: python -m game.run_simulation."""

import sys

from game.scenarios import bankruptcy_and_return, crisis, first_factory, successful_transfer


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    first = first_factory()
    print("1. İlk fabrika")
    for month, (report, cash, fix) in enumerate(
        zip(first["reports"], first["cash"], first["fixes"]), start=1
    ):
        print(f"   Ay {month}: çıktı {report.realized}, satış {report.revenue}, "
              f"Düzelt {'başarılı' if fix.success else 'başarısız'}, kasa {cash}")

    second = crisis()
    print("2. Kriz")
    print(f"   Satış önizlemesi: açık {second['sale_preview'].debt_gap}, "
          f"eşik {second['sale_preview'].rescue_threshold}")
    for month, status in enumerate(second["month_ends"], start=1):
        print(f"   Ay {month}: açık {status.debt_gap}, "
              f"eşik {status.rescue_threshold}, "
              f"kapanış {'evet' if status.must_close else 'hayır'}")

    third = bankruptcy_and_return()
    print("3. İflas ve dönüş")
    print(f"   Şirket açığı {third['liquidation'].company_shortfall}, "
          f"kişisel borç {third['liquidation'].personal_debt}, "
          f"12 ay sonra kalan {third['debt'].remaining}")

    fourth = successful_transfer()
    print("4. Başarılı devir")
    print(f"   Devir geliri {fourth['payout']}, hazırlık sonrası kasa "
          f"{fourth['after_preparation']}, ilk faaliyet ayı sonu "
          f"{fourth['new'].cash}")


if __name__ == "__main__":
    main()
