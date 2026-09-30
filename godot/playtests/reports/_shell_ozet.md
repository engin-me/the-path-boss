# Fabrika kabuğu simülasyonu — Faz 1 + Faz 2 (tedarik ve peşinat)

Test girdisidir; denge kararı değildir. Motor: `godot/scripts/shell/shell_boss.gd`, koşucu: `godot/tests/shell_sim.gd`. Kurallar: IDEA-015..018 önerileridir.

Koşullar: 100 tohum × 12 ay; başlangıç parası $800k; `price_per_x` 0,13; kiralar $15k–45k; müşteri peşinatı %30 (kabulde), kalan teslimde; hammadde tedarikçiden sipariş edilir (Nordhaus: 1 ay temin, 1 ay vade, %95 fiyat, %10 gecikme; Pacific: 2 ay, 2 ay vade, %88, %25, Ekonomik; Atlas: 1 ay, peşin, %110, %3, Premium; Midland: 1 ay, 1 ay vade, %100, %12). Karakterler betiklidir; iş kabulünde kapasite ve nakit taahhüdü (peşinat + ödenmemiş hammadde) kontrol edilir.


| Karakter | Kiralanamadı | Ayakta | Zorunlu kapanış | İflas | Ort. son net kasa | En düşük kasa (ort.) | İlk iş ayı | OEE (24 sa, ort.) | Kapasite kullanımı | Ort. vardiya | Geç teslim / teslim | Bırakılan-iptal | Son skor | Gizli satırlı ay | Danışmansız deneme mümkün | Para engeli |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Tek makine | 0 | 100 | 0 | 0 | 267 | 166 | 1.1 | %24 | %96 | 1.0 | 48 / 291 | 0 | %84 | 72 | 72 | 0 |
| Küçük temkinli | 0 | 84 | 0 | 16 | -11 | -142 | 1.0 | %22 | %66 | 1.0 | 106 / 177 | 44 | %69 | 64 | 64 | 0 |
| Küçük vardiyacı | 0 | 100 | 0 | 0 | 508 | -19 | 1.0 | %56 | %85 | 2.4 | 44 / 648 | 0 | %90 | 65 | 47 | 18 |
| Orta ikinci el | 0 | 93 | 0 | 7 | 28 | -245 | 1.0 | %34 | %66 | 1.7 | 58 / 371 | 15 | %81 | 140 | 34 | 106 |
| Orta yeni makine | 0 | 81 | 0 | 19 | -76 | -206 | 1.0 | %32 | %75 | 1.5 | 94 / 386 | 38 | %76 | 34 | 0 | 34 |
| Büyük iddialı | 0 | 93 | 0 | 7 | -53 | -350 | 1.0 | %31 | %52 | 1.6 | 44 / 300 | 25 | %80 | 149 | 24 | 125 |


## Bulgular

1. Peşinat ve tedarikçi vadesi işletme sermayesi tuzağını kapatıyor: Faz 1'de zararda olan orta ikinci el park +$76k'ya, büyük iddialı park başabaşa geldi; vardiyacı küçük park +$536k.
2. Hâlâ düşük performans gösterenler: yeni makine tercih eden orta park (Atlas: peşin ve pahalı, makine geç gelir) ve tek vardiyada kalan temkinli park (bırakılan iş çok).
3. Teslim tarihinde hammadde temin süresi payı yer kaplıyor; geç teslim oranı yüksek kalıyor. İlan süreleri temin süresini kapsayacak şekilde artırıldı (+1–2 ay pay).
4. Para engeli: orta/büyük parkta gizli Düzelt erişimi hâlâ kasaya takılıyor; ölçek güvencesi ($105k / $280k) ve erken ay kasaları.
