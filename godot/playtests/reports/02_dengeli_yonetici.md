# Oyun testi — Dengeli Yönetici

Yazan: Claude · Persona dosyası: `02_dengeli_yonetici.json` · Tohum: 22.0 · Bu rapor test girdisidir, tasarım kararı değildir.

> Her alanda orta bilgili; kapasitenin bir kısmını boş bırakır, riski ölçülü alır, bilmediği yerde danışman tutar.

**Yetkinlikler:** Üretim 60, Planlama 60, Depo & Sevkiyat 60, Bakım 60, Kalite 60, Satın Alma 60, Finans 60, Ar-Ge / Ür-Ge 60, Yatırım 60, İnsan Yönetimi 60

**Başlangıç:** para 400.0, makineler {"A":1.0,"B":1.0}, politika `{"buy":[],"credit_when_cash_below":60.0,"fix":"all","hire_when_hidden_loss":6.0,"jobs":"safe","min_chance":"Orta"}`

## Aylar

| Ay | Çıktı | Kayıp | Gelir | Sorun satırları | Düzelt başarı/deneme | Danışman | Önlenen | Ay sonu kasa | Açık / eşik |
| --- | --- | ---: | ---: | --- | --- | --- | ---: | ---: | --- |
| 1 | 42/50 | 8 | 65 | 0 görünür / 1 gizli | 1/2 (engel 0) | — | 0 | 141 | 0 / 480 |
| 2 | 23/35 | 12 | 34 | 0 görünür / 2 gizli | 1/3 (engel 0) | — | 0 | 49 | 0 / 477 |
| 3 | 58/65 | 7 | 94 | 0 görünür / 1 gizli | 1/2 (engel 0) | — | 1 | 104 | 0 / 497 |
| 4 | 59/70 | 11 | 105 | 1 görünür / 1 gizli | 1/1 (engel 2) | — | 0 | 116 | 0 / 502 |
| 5 | 65/75 | 10 | 112 | 1 görünür / 1 gizli | 1/1 (engel 2) | — | 1 | 128 | 0 / 512 |
| 6 | 44/55 | 11 | 59 | 1 görünür / 0 gizli | 2/2 (engel 1) | — | 0 | 73 | 27 / 475 |
| 7 | 65/70 | 5 | 112 | 2 görünür / 0 gizli | 0/0 (engel 2) | — | 0 | 98 | 2 / 447 |
| 8 | 65/75 | 10 | 101 | 1 görünür / 1 gizli | 1/1 (engel 2) | — | 0 | 109 | 0 / 478 |
| 9 | 49/65 | 16 | 95 | 0 görünür / 2 gizli | 2/2 (engel 2) | — | 0 | 98 | 2 / 499 |
| 10 | 35/45 | 10 | 72 | 0 görünür / 2 gizli | 0/0 (engel 2) | — | 1 | 94 | 6 / 462 |
| 11 | 56/75 | 19 | 100 | 1 görünür / 3 gizli | 0/0 (engel 4) | — | 0 | 107 | 0 / 442 |
| 12 | 34/55 | 21 | 64 | 0 görünür / 3 gizli | 2/2 (engel 3) | — | 0 | 67 | 33 / 441 |

## Sonuç

- Fabrika test süresince ayakta kaldı. Son kasa 67, borç 100.
- Bu sefer Planlama bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 60, bu alanın görülmeyen kaybı 25.)
- Bu sefer Yatırım bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 60, bu alanın görülmeyen kaybı 25.)
- İnsan Yönetimi 3 kişi kaynaklı olayı daha doğmadan önledi.

## Kapanış raporu

- Planlama T3 · toplam kayıp 25 · görülmedi · çözüldü · kesin çözüm için 70 (patron 60)
- Yatırım T3 · toplam kayıp 25 · görülmedi · sürüyor · kesin çözüm için 70 (patron 60)
- Bakım T3 · toplam kayıp 20 · görülmedi · sürüyor · kesin çözüm için 70 (patron 60)
- Planlama T2 · toplam kayıp 10 · görüldü · çözüldü · kesin çözüm için 50 (patron 60)
- Depo & Sevkiyat T3 · toplam kayıp 10 · görülmedi · sürüyor · kesin çözüm için 70 (patron 60)
- İnsan Yönetimi T2 · toplam kayıp 8 · görüldü · çözüldü · kesin çözüm için 50 (patron 60)
- İnsan Yönetimi T3 · toplam kayıp 6 · görülmedi · çözüldü · kesin çözüm için 70 (patron 60)
- Bakım T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- İnsan Yönetimi T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Finans T2 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 50 (patron 60)
- Planlama T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Satın Alma T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Ar-Ge / Ür-Ge T1 · toplam kayıp 4 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Kalite T1 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Kalite T1 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)

## Otomatik bulgular

- Ay 1: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: departman kayıp tavanı (%20) devreye girdi.
- Ay 3: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 4: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 5: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 6: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 6: departman kayıp tavanı (%20) devreye girdi.
- Ay 7: ay başı kasa (73) giderleri (87) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 7: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 7: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 8: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 9: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 10: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 10: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 11: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 11: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 12: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).

## Olay geçmişi

- Patron: Dengeli Yönetici · toplam yetkinlik 600/600 · başlangıç parası 400
- Fabrika açıldı: 2 makine, ölçek Küçük, kasa 180
- Ay 1: Düzelt Bakım T1 → başarılı (6 para, 3 sa)
- Ay 1: Düzelt İnsan Yönetimi · derinliği bilinmeyen sorun → başarısız (25 para, 5 sa)
- Ay 1: 42/50 çıktı, gelir 65, kasa 141, borç açığı 0 / eşik 466
- Ay 2: Düzelt İnsan Yönetimi T1 → başarılı (7 para, 2 sa)
- Ay 2: Düzelt Planlama · derinliği bilinmeyen sorun → başarısız (25 para, 5 sa)
- Ay 2: Düzelt İnsan Yönetimi · derinliği bilinmeyen sorun → başarısız (25 para, 5 sa)
- Ay 2: 23/35 çıktı, gelir 34, kasa 49, borç açığı 0 / eşik 479
- Ay 3: kriz kredisi 100 alındı; borç açığı değişmedi.
- Ay 3: Düzelt Planlama · derinliği bilinmeyen sorun → başarısız (25 para, 5 sa)
- Ay 3: Düzelt İnsan Yönetimi · derinliği bilinmeyen sorun → başarılı (32 para, 6 sa)
- Ay 3: 58/65 çıktı, gelir 94, kasa 104, borç açığı 0 / eşik 475
- Ay 4: Düzelt Kalite T1 → başarılı (8 para, 3 sa)
- Ay 4: 59/70 çıktı, gelir 105, kasa 116, borç açığı 0 / eşik 496
- Ay 5: Düzelt Finans T2 → başarılı (14 para, 3 sa)
- Ay 5: 65/75 çıktı, gelir 112, kasa 128, borç açığı 0 / eşik 501
- Ay 6: Düzelt Planlama T1 → başarılı (6 para, 2 sa)
- Ay 6: Düzelt Planlama · derinliği bilinmeyen sorun → başarılı (32 para, 5 sa)
- Ay 6: 44/55 çıktı, gelir 59, kasa 73, borç açığı 27 / eşik 511
- Ay 7: 65/70 çıktı, gelir 112, kasa 98, borç açığı 2 / eşik 473
- Ay 8: Düzelt Satın Alma T1 → başarılı (7 para, 2 sa)
- Ay 8: 65/75 çıktı, gelir 101, kasa 109, borç açığı 0 / eşik 445
- Ay 9: Düzelt Ar-Ge / Ür-Ge T1 → başarılı (7 para, 3 sa)
- Ay 9: Düzelt Planlama T2 → başarılı (17 para, 4 sa)
- Ay 9: 49/65 çıktı, gelir 95, kasa 98, borç açığı 2 / eşik 476
- Ay 10: 35/45 çıktı, gelir 72, kasa 94, borç açığı 6 / eşik 498
- Ay 11: 56/75 çıktı, gelir 100, kasa 107, borç açığı 0 / eşik 461
- Ay 12: Düzelt İnsan Yönetimi T2 → başarılı (14 para, 5 sa)
- Ay 12: Düzelt Kalite T1 → başarılı (8 para, 3 sa)
- Ay 12: 34/55 çıktı, gelir 64, kasa 67, borç açığı 33 / eşik 441

## Test eden yorumu

_Bu bölümü oynayan kişi/yapay zekâ doldurur: tasarım sorunu, mantık hatası, "bu saçma olmuş" noktaları._
