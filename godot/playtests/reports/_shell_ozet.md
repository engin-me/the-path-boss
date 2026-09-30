# Fabrika kabuğu simülasyonu — Faz 1 + 2 + 3 (teklif ve pazarlık)

Test girdisidir; denge kararı değildir. Motor: `godot/scripts/shell/shell_boss.gd`, koşucu: `godot/tests/shell_sim.gd`. Kurallar: IDEA-015..018 önerileridir.

Koşullar: 100 tohum × 12 ay; başlangıç parası $800k; `price_per_x` 0,13. İlan fiyatsızdır: oyuncu fiyat, peşinat ve teslim süresi teklif eder. Müşterinin gizli aciliyeti (1–10) kabul edeceği en yüksek fiyatı belirler: maliyeti × (1 + marj), marj sade işte %5–40, karmaşık işte %40–85 arasında aciliyetle kayar; zayıf teslimat skoru, yüksek peşinat ve geç teslim sınırı düşürür. Sınırın %10'una kadar üstü evet/hayır karşı teklif alır; ötesi reddedilir ve ret notu müşterinin tahmini maliyetini ve aciliyetini yazar. Karakterler betiklidir: kendi maliyet hesabı × (1 + marj) fiyatı ile teklif verir (Tek makine ve temkinliler %30, vardiyacılar %45, yeni makineci %60).


| Karakter | Kiralanamadı | Ayakta | Zorunlu kapanış | İflas | Ort. son net kasa | En düşük kasa (ort.) | İlk iş ayı | OEE (24 sa, ort.) | Kapasite kullanımı | Ort. vardiya | Geç teslim / teslim | Bırakılan-iptal | Son skor | Teklif: kabul / karşı / ret | Gizli satırlı ay | Danışmansız deneme mümkün | Para engeli |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Tek makine | 0 | 100 | 0 | 0 | 356 | 244 | 1.1 | %24 | %95 | 1.0 | 41 / 260 | 0 | %84 | 279 / 147 / 80 | 58 | 58 | 0 |
| Küçük temkinli | 0 | 87 | 0 | 13 | 20 | -101 | 1.0 | %23 | %64 | 1.0 | 99 / 161 | 45 | %69 | 298 / 110 / 12 | 65 | 64 | 1 |
| Küçük vardiyacı | 0 | 100 | 0 | 0 | 1154 | 131 | 1.0 | %60 | %89 | 2.6 | 42 / 722 | 0 | %91 | 609 / 609 / 872 | 55 | 52 | 3 |
| Orta ikinci el | 0 | 94 | 0 | 6 | 100 | -219 | 1.0 | %38 | %70 | 1.9 | 39 / 416 | 13 | %84 | 485 / 215 / 214 | 127 | 47 | 80 |
| Orta yeni makine | 0 | 100 | 0 | 0 | 134 | -7 | 3.2 | %29 | %33 | 1.3 | 4 / 85 | 0 | %82 | 4 / 122 / 7667 | 44 | 42 | 2 |
| Büyük iddialı | 0 | 92 | 0 | 8 | 244 | -290 | 1.0 | %35 | %60 | 1.7 | 51 / 419 | 20 | %82 | 420 / 280 / 411 | 138 | 29 | 109 |


## Bulgular

1. Teklif marjı gerçek bir ödünleşim yaratıyor: %30 marjla teklif verenler çoğunlukla kabul alır; %60 marjla teklif verenler (Atlas ve yeni makine) çok sayıda ret alır, işi az olur (kapasite kullanımı %31) ama kârsız değil.
2. Sade işlerde marj düşük, karmaşık işlerde yüksek; bu yüzden büyük ve nitelikli park daha kârlı iş alabilir ama onun için ilan sayısı ve uygunluk yeterli olmalı.
3. Zamanında teslimat skoru fiyat toleransını belirliyor; geç teslim ve bırakma skoru düşürüp sonraki tekliflerde müşteri toleransını azaltıyor (simülasyonda skorlar %68–91).
4. Tek makineli park hâlâ kârlı; vardiya açmak en güçlü kaldıraç.
