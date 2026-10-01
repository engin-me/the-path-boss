# Fabrika kabuğu simülasyonu — Faz 1 + 2 + 3 (teklif ve pazarlık)

Test girdisidir; denge kararı değildir. Motor: `godot/scripts/shell/shell_boss.gd`, koşucu: `godot/tests/shell_sim.gd`. Kurallar: IDEA-015..018 önerileridir.

Koşullar: 100 tohum × 12 ay; başlangıç parası $800k; `price_per_x` 0,13. İlan fiyatsızdır: oyuncu fiyat, peşinat ve teslim süresi teklif eder. Müşterinin gizli aciliyeti (1–10) kabul edeceği en yüksek fiyatı belirler: maliyeti × (1 + marj), marj sade işte %5–40, karmaşık işte %40–85 arasında aciliyetle kayar; zayıf teslimat skoru, yüksek peşinat ve geç teslim sınırı düşürür. Sınırın %10'una kadar üstü evet/hayır karşı teklif alır; ötesi reddedilir ve ret notu müşterinin tahmini maliyetini ve aciliyetini yazar. Karakterler betiklidir: kendi maliyet hesabı × (1 + marj) fiyatı ile teklif verir (Tek makine ve temkinliler %30, vardiyacılar %45, yeni makineci %60).



| Karakter | Kiralanamadı | Ayakta | Zorunlu kapanış | İflas | Ort. son net kasa | En düşük kasa (ort.) | İlk iş ayı | OEE (24 sa, ort.) | Kapasite kullanımı | Ort. vardiya | Geç teslim / teslim | Bırakılan-iptal | Son skor | Teklif: kabul / karşı / ret | Gizli satırlı ay | Danışmansız deneme mümkün | Para engeli |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Tek makine | 0 | 100 | 0 | 0 | 264 | 166 | 1.1 | %24 | %95 | 1.0 | 41 / 259 | 0 | %84 | 276 / 143 / 79 | 58 | 58 | 0 |
| Küçük temkinli | 0 | 79 | 0 | 21 | -62 | -155 | 1.0 | %23 | %63 | 1.0 | 96 / 155 | 47 | %68 | 282 / 103 / 11 | 65 | 63 | 2 |
| Küçük vardiyacı | 0 | 100 | 0 | 0 | 1072 | 100 | 1.0 | %59 | %88 | 2.5 | 43 / 714 | 0 | %91 | 610 / 580 / 841 | 54 | 52 | 2 |
| Orta ikinci el | 0 | 92 | 0 | 8 | 88 | -272 | 1.0 | %40 | %70 | 1.8 | 51 / 456 | 9 | %84 | 511 / 221 / 214 | 100 | 38 | 62 |
| Orta yeni makine | 0 | 95 | 0 | 5 | 22 | -103 | 2.5 | %30 | %30 | 1.2 | 4 / 79 | 0 | %82 | 5 / 102 / 6441 | 24 | 24 | 0 |
| Büyük iddialı | 0 | 92 | 0 | 8 | 254 | -354 | 1.0 | %36 | %60 | 1.7 | 48 / 425 | 10 | %83 | 430 / 282 / 397 | 98 | 29 | 69 |


## 13 bina ve kira

Kiralık binalar 13 boyuttadır (150–3500 m², `art/factories/factory_1..13`). Kira = 22,5k × (alan/150)^0,85 × (1 + %1 × (yükseklik − 8)); 150 m² $22,5k, 400 m² $53k, 1000 m² $117,5k, 3500 m² $350k. Karakterler parkına uygun binayı seçti: tek/küçük park factory_1, orta park factory_3 (300 m²), büyük park factory_4 (400 m²). Büyük binalar (1500 m² ve üstü) ancak çok makineli parkta anlamlı; kira değerleri yer tutucudur.

## Bulgular

1. Teklif marjı gerçek bir ödünleşim yaratıyor: %30 marjla teklif verenler çoğunlukla kabul alır; %60 marjla teklif verenler (Atlas ve yeni makine) çok sayıda ret alır, işi az olur (kapasite kullanımı %31) ama kârsız değil.
2. Sade işlerde marj düşük, karmaşık işlerde yüksek; bu yüzden büyük ve nitelikli park daha kârlı iş alabilir ama onun için ilan sayısı ve uygunluk yeterli olmalı.
3. Zamanında teslimat skoru fiyat toleransını belirliyor; geç teslim ve bırakma skoru düşürüp sonraki tekliflerde müşteri toleransını azaltıyor (simülasyonda skorlar %68–91).
4. Tek makineli park hâlâ kârlı; vardiya açmak en güçlü kaldıraç.
