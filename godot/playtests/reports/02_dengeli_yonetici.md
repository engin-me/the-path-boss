# Oyun testi — Dengeli Yönetici

Yazan: Claude · Persona dosyası: `02_dengeli_yonetici.json` · Tohum: 22.0 · Bu rapor test girdisidir, tasarım kararı değildir.

> Her alanda orta bilgili; kapasitenin bir kısmını boş bırakır, riski ölçülü alır, bilmediği yerde danışman tutar.

**Yetkinlikler:** Üretim 60, Planlama 60, Depo & Sevkiyat 60, Bakım 60, Kalite 60, Satın Alma 60, Finans 60, Ar-Ge / Ür-Ge 60, Yatırım 60, İnsan Yönetimi 60

**Diploma:** Mühendislik + İşletme (tavanı aşan puanlar kırpılır; ayrıntı olay geçmişinde)

**Başlangıç:** para 400.0, makineler {"A":1.0,"B":1.0}, politika `{"buy":[],"credit_when_cash_below":60.0,"fix":"all","hire_when_hidden_loss":6.0,"jobs":"safe","min_chance":"Orta"}`

## Aylar

| Ay | Çıktı | Kayıp | Gelir | Düzelt öncesi sorun satırları | Düzelt başarı/deneme | Danışman | Önlenen | Ay sonu kasa | Açık / eşik |
| --- | --- | ---: | ---: | --- | --- | --- | ---: | ---: | --- |
| 1 | 42/50 | 8 | 65 | 1 görünür / 1 gizli | 1/2 (engel 0) | — | 0 | 141 | 0 / 463 |
| 2 | 52/60 | 7 | 80 | 1 görünür / 1 gizli | 2/2 (engel 0) | — | 0 | 101 | 0 / 484 |
| 3 | 39/50 | 11 | 78 | 1 görünür / 1 gizli | 1/1 (engel 1) | — | 0 | 93 | 0 / 491 |
| 4 | 60/75 | 14 | 105 | 2 görünür / 1 gizli | 0/0 (engel 3) | — | 0 | 107 | 0 / 485 |
| 5 | 26/45 | 19 | 53 | 2 görünür / 2 gizli | 2/2 (engel 2) | — | 0 | 70 | 0 / 474 |
| 6 | 60/75 | 15 | 99 | 1 görünür / 2 gizli | 0/0 (engel 3) | — | 0 | 86 | 0 / 491 |
| 7 | 28/45 | 16 | 60 | 1 görünür / 3 gizli | 1/1 (engel 3) | — | 0 | 65 | 0 / 490 |
| 8 | 43/65 | 21 | 79 | 2 görünür / 3 gizli | 0/0 (engel 5) | — | 0 | 63 | 0 / 487 |
| 9 | 39/65 | 25 | 70 | 3 görünür / 3 gizli | 0/0 (engel 6) | — | 1 | 52 | 0 / 435 |
| 10 | 18/45 | 26 | 33 | 3 görünür / 3 gizli | 3/4 (engel 2) | — | 2 | 40 | 60 / 426 |
| 11 | 53/65 | 11 | 85 | 1 görünür / 2 gizli | 0/0 (engel 3) | — | 1 | 41 | 59 / 405 |
| 12 | 43/60 | 17 | 71 | 2 görünür / 2 gizli | 0/0 (engel 4) | — | 0 | 31 | 69 / 403 |

## Sonuç

- Fabrika test süresince ayakta kaldı. Son kasa 31, borç 100.
- Bu sefer Planlama bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 60, bu alanın görülmeyen kaybı 48.)
- Bu sefer Yatırım bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 60, bu alanın görülmeyen kaybı 38.)
- İnsan Yönetimi 4 kişi kaynaklı olayı daha doğmadan önledi.

## Kapanış raporu

- Planlama T3 · toplam kayıp 48 · görülmedi · çözüldü · kesin çözüm için 70 (patron 60)
- Yatırım T3 · toplam kayıp 38 · görülmedi · sürüyor · kesin çözüm için 70 (patron 60)
- Üretim T3 · toplam kayıp 20 · görülmedi · sürüyor · kesin çözüm için 70 (patron 60)
- İnsan Yönetimi T1 · toplam kayıp 16 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Ar-Ge / Ür-Ge T1 · toplam kayıp 12 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Planlama T2 · toplam kayıp 11 · görüldü · sürüyor · kesin çözüm için 50 (patron 60)
- Planlama T1 · toplam kayıp 10 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Yatırım T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Üretim T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Bakım T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Satın Alma T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Bakım T1 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- İnsan Yönetimi T1 · toplam kayıp 5 · görüldü · sürüyor · kesin çözüm için 30 (patron 60)
- İnsan Yönetimi T3 · toplam kayıp 4 · görülmedi · çözüldü · kesin çözüm için 70 (patron 60)

## Otomatik bulgular

- Ay 1: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 3: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 4: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 4: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 5: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 6: ay başı kasa (70) giderleri (83) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 6: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 6: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 7: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 7: departman kayıp tavanı (%20) devreye girdi.
- Ay 8: ay başı kasa (65) giderleri (81) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 8: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 8: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 9: ay başı kasa (63) giderleri (80) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 9: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 9: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 10: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 10: departman kayıp tavanı (%20) devreye girdi.
- Ay 11: ay başı kasa (40) giderleri (83) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 11: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 11: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 12: ay başı kasa (41) giderleri (80) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 12: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 12: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).

## Olay geçmişi

- Patron: Dengeli Yönetici · Mühendislik + İşletme · toplam yetkinlik 600/600 · başlangıç parası 400
- Fabrika açıldı: 2 makine, ölçek Küçük, kasa 180
- Ay 1: Düzelt Bakım T1 → başarılı (6 para, 3 sa)
- Ay 1: Düzelt İnsan Yönetimi · derinliği bilinmeyen sorun → başarısız (25 para, 5 sa)
- Ay 1: 42/50 çıktı, gelir 65, kasa 141, borç açığı 0 / eşik 466
- Ay 2: Düzelt Bakım T1 → başarılı (10 para, 3 sa)
- Ay 2: Düzelt İnsan Yönetimi · derinliği bilinmeyen sorun → başarılı (32 para, 6 sa)
- Ay 2: 53/60 çıktı, gelir 80, kasa 101, borç açığı 0 / eşik 462
- Ay 3: Düzelt Satın Alma T1 → başarılı (10 para, 3 sa)
- Ay 3: 39/50 çıktı, gelir 78, kasa 93, borç açığı 0 / eşik 482
- Ay 4: 61/75 çıktı, gelir 105, kasa 107, borç açığı 0 / eşik 489
- Ay 5: Düzelt Ar-Ge / Ür-Ge T1 → başarılı (6 para, 2 sa)
- Ay 5: Düzelt Yatırım T1 → başarılı (6 para, 3 sa)
- Ay 5: 26/45 çıktı, gelir 53, kasa 70, borç açığı 0 / eşik 484
- Ay 6: 60/75 çıktı, gelir 99, kasa 86, borç açığı 0 / eşik 472
- Ay 7: Düzelt Planlama T1 → başarılı (9 para, 2 sa)
- Ay 7: 29/45 çıktı, gelir 60, kasa 65, borç açığı 0 / eşik 489
- Ay 8: 44/65 çıktı, gelir 79, kasa 63, borç açığı 0 / eşik 488
- Ay 9: 40/65 çıktı, gelir 70, kasa 52, borç açığı 0 / eşik 486
- Ay 10: kriz kredisi 100 alındı; borç açığı değişmedi.
- Ay 10: Düzelt Planlama · derinliği bilinmeyen sorun → başarılı (30 para, 7 sa)
- Ay 10: Düzelt İnsan Yönetimi T1 → başarılı (6 para, 3 sa)
- Ay 10: Düzelt Yatırım · derinliği bilinmeyen sorun → başarısız (25 para, 5 sa)
- Ay 10: Düzelt Üretim T1 → başarılı (7 para, 3 sa)
- Ay 10: 19/45 çıktı, gelir 33, kasa 40, borç açığı 60 / eşik 434
- Ay 11: 54/65 çıktı, gelir 85, kasa 41, borç açığı 59 / eşik 424
- Ay 12: 43/60 çıktı, gelir 71, kasa 31, borç açığı 69 / eşik 403

## Test eden yorumu

_Bu bölümü oynayan kişi/yapay zekâ doldurur: tasarım sorunu, mantık hatası, "bu saçma olmuş" noktaları._
