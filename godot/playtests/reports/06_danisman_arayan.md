# Oyun testi — Danışman Arayan

Yazan: ChatGPT · Persona dosyası: `06_danisman_arayan.json` · Tohum: 77.0 · Bu rapor test girdisidir, tasarım kararı değildir.

> Bilgi açığını danışmanla kapatmayı deneyen patron. Aynı yetkinlik, makine ve parayla Kör Tamirciye karşılaştırma sağlar.

**Yetkinlikler:** Üretim 60, Planlama 35, Depo & Sevkiyat 40, Bakım 50, Kalite 40, Satın Alma 35, Finans 60, Ar-Ge / Ür-Ge 45, Yatırım 40, İnsan Yönetimi 55

**Başlangıç:** para 400.0, makineler {"A":1.0,"B":1.0}, politika `{"buy":[],"credit_when_cash_below":60.0,"fix":"visible_only","hire_when_hidden_loss":3.0,"jobs":"greedy","min_chance":"Orta"}`

## Aylar

| Ay | Çıktı | Kayıp | Gelir | Düzelt öncesi sorun satırları | Düzelt başarı/deneme | Danışman | Önlenen | Ay sonu kasa | Açık / eşik |
| --- | --- | ---: | ---: | --- | --- | --- | ---: | ---: | --- |
| 1 | 59/65 | 6 | 95 | 1 görünür / 0 gizli | 1/1 (engel 0) | — | 1 | 186 | 0 / 510 |
| 2 | 55/60 | 5 | 85 | 0 görünür / 1 gizli | 0/0 (engel 0) | — | 1 | 194 | 0 / 467 |
| 3 | 67/80 | 13 | 100 | 1 görünür / 2 gizli | 1/1 (engel 0) | Aday 3-3 | 0 | 161 | 0 / 479 |
| 4 | 39/55 | 16 | 75 | 0 görünür / 3 gizli | 0/0 (engel 0) | Aday 3-3 | 1 | 153 | 0 / 481 |
| 5 | 22/40 | 18 | 44 | 0 görünür / 4 gizli | 0/0 (engel 0) | Aday 3-3 | 1 | 124 | 0 / 513 |
| 6 | 51/75 | 24 | 90 | 0 görünür / 5 gizli | 0/0 (engel 0) | — | 0 | 129 | 0 / 484 |
| 7 | 66/95 | 29 | 103 | 1 görünür / 5 gizli | 0/0 (engel 2) | Aday 7-3 | 0 | 103 | 0 / 467 |
| 8 | 54/90 | 36 | 95 | 4 görünür / 4 gizli | 1/1 (engel 3) | Aday 7-3 | 0 | 99 | 0 / 460 |
| 9 | 43/80 | 37 | 62 | 4 görünür / 4 gizli | 1/1 (engel 3) | Aday 7-3 | 0 | 69 | 0 / 501 |
| 10 | 24/60 | 36 | 49 | 2 görünür / 6 gizli | 0/0 (engel 2) | — | 0 | 40 | 0 / 489 |
| 11 | 16/50 | 34 | 34 | 3 görünür / 7 gizli | 2/2 (engel 1) | Aday 11-1 | 0 | 36 | 64 / 508 |
| 12 | 19/60 | 40 | 38 | 3 görünür / 7 gizli | 0/0 (engel 3) | Aday 11-1 | 0 | -4 | 104 / 507 |

## Sonuç

- Fabrika test süresince ayakta kaldı. Son kasa -4, borç 100.
- Bu sefer Ar-Ge / Ür-Ge bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 45, bu alanın görülmeyen kaybı 102.)
- Bu sefer Finans bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 60, bu alanın görülmeyen kaybı 55.)
- İnsan Yönetimi 4 kişi kaynaklı olayı daha doğmadan önledi.

## Kapanış raporu

- Finans T3 · toplam kayıp 55 · görülmedi · sürüyor · kesin çözüm için 70 (patron 60)
- Ar-Ge / Ür-Ge T2 · toplam kayıp 54 · görüldü · sürüyor · kesin çözüm için 50 (patron 45)
- Satın Alma T3 · toplam kayıp 50 · görülmedi · sürüyor · kesin çözüm için 70 (patron 35)
- Ar-Ge / Ür-Ge T3 · toplam kayıp 48 · görülmedi · sürüyor · kesin çözüm için 70 (patron 45)
- Finans T2 · toplam kayıp 20 · görüldü · sürüyor · kesin çözüm için 50 (patron 60)
- Üretim T2 · toplam kayıp 18 · görüldü · çözüldü · kesin çözüm için 50 (patron 60)
- Kalite T2 · toplam kayıp 14 · görülmedi · sürüyor · kesin çözüm için 50 (patron 40)
- Satın Alma T1 · toplam kayıp 10 · görüldü · çözüldü · kesin çözüm için 30 (patron 35)
- Üretim T3 · toplam kayıp 10 · görülmedi · sürüyor · kesin çözüm için 70 (patron 60)
- Planlama T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 35)
- Finans T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Depo & Sevkiyat T2 · toplam kayıp 6 · görülmedi · sürüyor · kesin çözüm için 50 (patron 40)
- Bakım T1 · toplam kayıp 6 · görüldü · sürüyor · kesin çözüm için 30 (patron 50)
- Üretim T1 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Finans T1 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Finans T1 · toplam kayıp 3 · görüldü · sürüyor · kesin çözüm için 30 (patron 60)

## Otomatik bulgular

- Ay 1: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 3: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 4: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 5: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 5: departman kayıp tavanı (%20) devreye girdi.
- Ay 6: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 7: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 7: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 8: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 9: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 10: ay başı kasa (69) giderleri (78) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 10: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 10: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 11: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 11: departman kayıp tavanı (%20) devreye girdi.
- Ay 12: ay başı kasa (36) giderleri (78) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 12: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 12: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).

## Olay geçmişi

- Patron: Danışman Arayan · toplam yetkinlik 460/600 · başlangıç parası 400
- Fabrika açıldı: 2 makine, ölçek Küçük, kasa 180
- Ay 1: Düzelt Planlama T1 → başarılı (6 para, 3 sa)
- Ay 1: 59/65 çıktı, gelir 95, kasa 186, borç açığı 0 / eşik 462
- Ay 2: 55/60 çıktı, gelir 85, kasa 194, borç açığı 0 / eşik 509
- Ay 3: Aday 3-3 3 ay için tutuldu (39).
- Ay 3: Düzelt Finans T1 → başarılı (8 para, 3 sa)
- Ay 3: 67/80 çıktı, gelir 100, kasa 161, borç açığı 0 / eşik 465
- Ay 4: 39/55 çıktı, gelir 75, kasa 153, borç açığı 0 / eşik 478
- Ay 5: Aday 3-3 sözleşmesi bitti; bilgisi fabrikada kalmadı.
- Ay 5: 22/40 çıktı, gelir 44, kasa 124, borç açığı 0 / eşik 479
- Ay 6: 51/75 çıktı, gelir 90, kasa 129, borç açığı 0 / eşik 512
- Ay 7: Aday 7-3 3 ay için tutuldu (39).
- Ay 7: 66/95 çıktı, gelir 103, kasa 103, borç açığı 0 / eşik 482
- Ay 8: Düzelt Satın Alma T1 → başarılı (10 para, 1 sa)
- Ay 8: 54/90 çıktı, gelir 95, kasa 99, borç açığı 0 / eşik 465
- Ay 9: Düzelt Finans T1 → başarılı (6 para, 2 sa)
- Ay 9: Aday 7-3 sözleşmesi bitti; bilgisi fabrikada kalmadı.
- Ay 9: 43/80 çıktı, gelir 62, kasa 69, borç açığı 0 / eşik 458
- Ay 10: 24/60 çıktı, gelir 49, kasa 40, borç açığı 0 / eşik 499
- Ay 11: kriz kredisi 100 alındı; borç açığı değişmedi.
- Ay 11: Aday 11-1 3 ay için tutuldu (39).
- Ay 11: Düzelt Üretim T2 → başarılı (14 para, 5 sa)
- Ay 11: Düzelt Üretim T1 → başarılı (8 para, 2 sa)
- Ay 11: 17/50 çıktı, gelir 34, kasa 36, borç açığı 64 / eşik 488
- Ay 12: 20/60 çıktı, gelir 38, kasa -4, borç açığı 104 / eşik 507

## Test eden yorumu

_Bu bölümü oynayan kişi/yapay zekâ doldurur: tasarım sorunu, mantık hatası, "bu saçma olmuş" noktaları._
