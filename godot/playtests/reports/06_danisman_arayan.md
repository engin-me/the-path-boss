# Oyun testi — Danışman Arayan

Yazan: ChatGPT · Persona dosyası: `06_danisman_arayan.json` · Tohum: 77.0 · Bu rapor test girdisidir, tasarım kararı değildir.

> Bilgi açığını danışmanla kapatmayı deneyen patron. Aynı yetkinlik, makine ve parayla Kör Tamirciye karşılaştırma sağlar.

**Yetkinlikler:** Üretim 60, Planlama 35, Depo & Sevkiyat 40, Bakım 50, Kalite 40, Satın Alma 35, Finans 60, Ar-Ge / Ür-Ge 45, Yatırım 40, İnsan Yönetimi 55

**Diploma:** Diploma yok (tavanı aşan puanlar kırpılır; ayrıntı olay geçmişinde)

**Başlangıç:** para 400.0, makineler {"A":1.0,"B":1.0}, politika `{"buy":[],"credit_when_cash_below":60.0,"fix":"visible_only","hire_when_hidden_loss":3.0,"jobs":"greedy","min_chance":"Orta"}`

## Aylar

| Ay | Çıktı | Kayıp | Gelir | Düzelt öncesi sorun satırları | Düzelt başarı/deneme | Danışman | Önlenen | Ay sonu kasa | Açık / eşik |
| --- | --- | ---: | ---: | --- | --- | --- | ---: | ---: | --- |
| 1 | 59/65 | 6 | 95 | 1 görünür / 0 gizli | 1/1 (engel 0) | — | 1 | 186 | 0 / 486 |
| 2 | 81/85 | 4 | 139 | 1 görünür / 0 gizli | 1/1 (engel 0) | — | 1 | 223 | 0 / 478 |
| 3 | 74/80 | 6 | 129 | 2 görünür / 0 gizli | 2/2 (engel 0) | — | 0 | 246 | 0 / 487 |
| 4 | 70/80 | 10 | 122 | 1 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 268 | 0 / 486 |
| 5 | 85/90 | 4 | 142 | 0 görünür / 1 gizli | 0/0 (engel 0) | — | 1 | 319 | 0 / 494 |
| 6 | 85/95 | 9 | 135 | 1 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 355 | 0 / 483 |
| 7 | 54/65 | 11 | 88 | 2 görünür / 1 gizli | 2/2 (engel 0) | — | 0 | 332 | 0 / 482 |
| 8 | 61/70 | 9 | 103 | 2 görünür / 1 gizli | 2/2 (engel 0) | — | 0 | 327 | 0 / 474 |
| 9 | 81/90 | 8 | 129 | 1 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 348 | 0 / 474 |
| 10 | 77/85 | 7 | 120 | 0 görünür / 2 gizli | 0/0 (engel 0) | — | 0 | 383 | 0 / 512 |
| 11 | 75/85 | 10 | 137 | 1 görünür / 2 gizli | 1/1 (engel 0) | — | 0 | 424 | 0 / 504 |
| 12 | 75/90 | 14 | 119 | 0 görünür / 3 gizli | 1/1 (engel 0) | Aday 12-1 | 1 | 419 | 0 / 502 |

## Sonuç

- Fabrika test süresince ayakta kaldı. Son kasa 419, borç 0.
- Bu sefer Bakım bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 50, bu alanın görülmeyen kaybı 44.)
- Bu sefer Yatırım bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 30, bu alanın görülmeyen kaybı 12.) Bunun için önce ilgili diploma gerekir; diplomasız tavan 30.
- İnsan Yönetimi 4 kişi kaynaklı olayı daha doğmadan önledi.

## Kapanış raporu

- Bakım T3 · toplam kayıp 44 · görülmedi · sürüyor · kesin çözüm için 70 (patron 50)
- Yatırım T2 · toplam kayıp 6 · görülmedi · çözüldü · kesin çözüm için 50 (patron 30)
- Planlama T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 35)
- Kalite T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 40)
- Yatırım T3 · toplam kayıp 6 · görülmedi · sürüyor · kesin çözüm için 70 (patron 30)
- İnsan Yönetimi T1 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 30 (patron 50)
- Kalite T1 · toplam kayıp 4 · görüldü · çözüldü · kesin çözüm için 30 (patron 40)
- İnsan Yönetimi T2 · toplam kayıp 4 · görüldü · çözüldü · kesin çözüm için 50 (patron 50)
- Bakım T1 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 30 (patron 50)
- Satın Alma T1 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 30 (patron 35)
- Üretim T2 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 50 (patron 60)
- Üretim T2 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 50 (patron 60)
- Satın Alma T1 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 30 (patron 35)
- Bakım T2 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 50 (patron 50)
- Depo & Sevkiyat T1 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 30 (patron 40)

## Otomatik bulgular

- Ay 1: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 3: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 4: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 5: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 6: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 7: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 8: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 9: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 10: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 11: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 12: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).

## Olay geçmişi

- Patron: Danışman Arayan · Diploma yok · toplam yetkinlik 400/600 · başlangıç parası 400
- Diploma tavanına kırpıldı: Finans 60→30, Ar-Ge / Ür-Ge 45→30, Yatırım 40→30, İnsan Yönetimi 55→50
- Fabrika açıldı: 2 makine, ölçek Küçük, kasa 180
- Ay 1: Düzelt Planlama T1 → başarılı (6 para, 3 sa)
- Ay 1: 59/65 çıktı, gelir 95, kasa 186, borç açığı 0 / eşik 462
- Ay 2: Düzelt Kalite T1 → başarılı (8 para, 3 sa)
- Ay 2: 81/85 çıktı, gelir 139, kasa 223, borç açığı 0 / eşik 485
- Ay 3: Düzelt Bakım T1 → başarılı (9 para, 2 sa)
- Ay 3: Düzelt Satın Alma T1 → başarılı (6 para, 3 sa)
- Ay 3: 74/80 çıktı, gelir 129, kasa 246, borç açığı 0 / eşik 476
- Ay 4: Düzelt Kalite T1 → başarılı (10 para, 2 sa)
- Ay 4: 70/80 çıktı, gelir 122, kasa 268, borç açığı 0 / eşik 485
- Ay 5: 86/90 çıktı, gelir 142, kasa 319, borç açığı 0 / eşik 485
- Ay 6: Düzelt İnsan Yönetimi T1 → başarılı (8 para, 2 sa)
- Ay 6: 86/95 çıktı, gelir 135, kasa 355, borç açığı 0 / eşik 493
- Ay 7: Düzelt İnsan Yönetimi T2 → başarılı (17 para, 3 sa)
- Ay 7: Düzelt Üretim T2 → başarılı (16 para, 3 sa)
- Ay 7: 54/65 çıktı, gelir 88, kasa 332, borç açığı 0 / eşik 482
- Ay 8: Düzelt Bakım T2 → başarılı (17 para, 5 sa)
- Ay 8: Düzelt Satın Alma T1 → başarılı (9 para, 3 sa)
- Ay 8: 61/70 çıktı, gelir 103, kasa 327, borç açığı 0 / eşik 480
- Ay 9: Düzelt Üretim T2 → başarılı (17 para, 3 sa)
- Ay 9: 82/90 çıktı, gelir 129, kasa 348, borç açığı 0 / eşik 473
- Ay 10: 78/85 çıktı, gelir 120, kasa 383, borç açığı 0 / eşik 472
- Ay 11: Düzelt Depo & Sevkiyat T1 → başarılı (6 para, 2 sa)
- Ay 11: 75/85 çıktı, gelir 137, kasa 424, borç açığı 0 / eşik 510
- Ay 12: Aday 12-1 3 ay için tutuldu (18).
- Ay 12: Düzelt Yatırım T2 → başarılı (16 para, 2 sa)
- Ay 12: 76/90 çıktı, gelir 119, kasa 419, borç açığı 0 / eşik 502

## Test eden yorumu

_Bu bölümü oynayan kişi/yapay zekâ doldurur: tasarım sorunu, mantık hatası, "bu saçma olmuş" noktaları._
