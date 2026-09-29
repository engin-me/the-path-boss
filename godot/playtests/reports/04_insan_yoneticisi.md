# Oyun testi — İnsan Yöneticisi

Yazan: Claude · Persona dosyası: `04_insan_yoneticisi.json` · Tohum: 44.0 · Bu rapor test girdisidir, tasarım kararı değildir.

> Takım liderliğinden gelen; İnsan Yönetimi 100. Sorunların doğmadan önlenmesine güvenir, temkinli iş alır.

**Yetkinlikler:** Üretim 60, Planlama 80, Depo & Sevkiyat 60, Bakım 50, Kalite 60, Satın Alma 50, Finans 50, Ar-Ge / Ür-Ge 40, Yatırım 50, İnsan Yönetimi 100

**Başlangıç:** para 400.0, makineler {"A":2.0}, politika `{"buy":[],"credit_when_cash_below":60.0,"fix":"visible_only","hire_when_hidden_loss":5.0,"jobs":"safe","min_chance":"Orta"}`

## Aylar

| Ay | Çıktı | Kayıp | Gelir | Sorun satırları | Düzelt başarı/deneme | Danışman | Önlenen | Ay sonu kasa | Açık / eşik |
| --- | --- | ---: | ---: | --- | --- | --- | ---: | ---: | --- |
| 1 | 43/50 | 7 | 60 | 0 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 214 | 0 / 297 |
| 2 | 9/20 | 11 | 14 | 0 görünür / 1 gizli | 2/2 (engel 0) | — | 0 | 147 | 0 / 273 |
| 3 | 21/25 | 4 | 26 | 0 görünür / 1 gizli | 0/0 (engel 0) | — | 1 | 110 | 0 / 255 |
| 4 | 31/40 | 9 | 40 | 0 görünür / 1 gizli | 1/1 (engel 0) | — | 1 | 51 | 0 / 231 |
| 5 | 36/40 | 4 | 54 | 0 görünür / 1 gizli | 0/0 (engel 0) | — | 1 | 139 | 0 / 241 |
| 6 | 29/35 | 6 | 39 | 0 görünür / 1 gizli | 1/1 (engel 0) | — | 1 | 106 | 0 / 250 |
| 7 | 33/40 | 7 | 51 | 0 görünür / 2 gizli | 0/0 (engel 0) | — | 1 | 89 | 11 / 253 |
| 8 | 42/60 | 18 | 65 | 1 görünür / 3 gizli | 0/0 (engel 1) | — | 0 | 76 | 24 / 239 |
| 9 | 27/50 | 23 | 37 | 2 görünür / 3 gizli | 0/0 (engel 2) | — | 0 | 39 | 61 / 246 |
| 10 | 4/15 | 10 | 7 | 2 görünür / 3 gizli | 0/0 (engel 2) | — | 1 | -14 | 114 / 213 |
| 11 | 13/40 | 27 | 16 | 4 görünür / 3 gizli | 0/0 (engel 4) | — | 0 | -68 | 168 / 241 |
| 12 | 23/60 | 37 | 36 | 5 görünür / 3 gizli | 0/0 (engel 5) | — | 0 | -112 | 212 / 240 |

## Sonuç

- Fabrika test süresince ayakta kaldı. Son kasa -112, borç 100.
- Bu sefer Ar-Ge / Ür-Ge bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 40, bu alanın görülmeyen kaybı 66.)
- Bu sefer Satın Alma bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 50, bu alanın görülmeyen kaybı 25.)
- İnsan Yönetimi 6 kişi kaynaklı olayı daha doğmadan önledi.

## Kapanış raporu

- Ar-Ge / Ür-Ge T2 · toplam kayıp 48 · görülmedi · sürüyor · kesin çözüm için 50 (patron 40)
- Üretim T2 · toplam kayıp 30 · görüldü · sürüyor · kesin çözüm için 50 (patron 60)
- Satın Alma T3 · toplam kayıp 25 · görülmedi · sürüyor · kesin çözüm için 70 (patron 50)
- Yatırım T2 · toplam kayıp 20 · görüldü · sürüyor · kesin çözüm için 50 (patron 50)
- Ar-Ge / Ür-Ge T3 · toplam kayıp 18 · görülmedi · sürüyor · kesin çözüm için 70 (patron 40)
- Bakım T2 · toplam kayıp 12 · görüldü · sürüyor · kesin çözüm için 50 (patron 50)
- Planlama T1 · toplam kayıp 12 · görüldü · sürüyor · kesin çözüm için 30 (patron 80)
- Üretim T1 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- İnsan Yönetimi T3 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 70 (patron 100)
- Depo & Sevkiyat T2 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 50 (patron 60)
- Depo & Sevkiyat T2 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 50 (patron 60)
- Ar-Ge / Ür-Ge T1 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 30 (patron 40)
- Bakım T1 · toplam kayıp 2 · görüldü · sürüyor · kesin çözüm için 30 (patron 50)

## Otomatik bulgular

- Ay 1: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: departman kayıp tavanı (%20) devreye girdi.
- Ay 3: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 4: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 5: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 6: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 7: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 8: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 8: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 9: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 9: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 10: ay başı kasa (39) giderleri (59) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 10: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 10: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 10: departman kayıp tavanı (%20) devreye girdi.
- Ay 11: ay başı kasa (-14) giderleri (68) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 11: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 11: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 12: ay başı kasa (-68) giderleri (77) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 12: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 12: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).

## Olay geçmişi

- Patron: İnsan Yöneticisi · toplam yetkinlik 600/600 · başlangıç parası 400
- Fabrika açıldı: 2 makine, ölçek Küçük, kasa 240
- Ay 1: Düzelt Depo & Sevkiyat T2 → başarılı (15 para, 4 sa)
- Ay 1: 43/50 çıktı, gelir 60, kasa 214, borç açığı 0 / eşik 265
- Ay 2: Düzelt Üretim T1 → başarılı (7 para, 3 sa)
- Ay 2: Düzelt Depo & Sevkiyat T2 → başarılı (13 para, 4 sa)
- Ay 2: 9/20 çıktı, gelir 14, kasa 147, borç açığı 0 / eşik 296
- Ay 3: 21/25 çıktı, gelir 26, kasa 110, borç açığı 0 / eşik 272
- Ay 4: Düzelt İnsan Yönetimi T3 → başarılı (30 para, 7 sa)
- Ay 4: 31/40 çıktı, gelir 40, kasa 51, borç açığı 0 / eşik 253
- Ay 5: kriz kredisi 100 alındı; borç açığı değişmedi.
- Ay 5: 36/40 çıktı, gelir 54, kasa 139, borç açığı 0 / eşik 230
- Ay 6: Düzelt Ar-Ge / Ür-Ge T1 → başarılı (6 para, 2 sa)
- Ay 6: 29/35 çıktı, gelir 39, kasa 106, borç açığı 0 / eşik 240
- Ay 7: 33/40 çıktı, gelir 51, kasa 89, borç açığı 11 / eşik 249
- Ay 8: 42/60 çıktı, gelir 65, kasa 76, borç açığı 24 / eşik 251
- Ay 9: 27/50 çıktı, gelir 37, kasa 39, borç açığı 61 / eşik 238
- Ay 10: 5/15 çıktı, gelir 7, kasa -14, borç açığı 114 / eşik 245
- Ay 11: 13/40 çıktı, gelir 16, kasa -68, borç açığı 168 / eşik 212
- Ay 12: 23/60 çıktı, gelir 36, kasa -112, borç açığı 212 / eşik 240

## Test eden yorumu

_Bu bölümü oynayan kişi/yapay zekâ doldurur: tasarım sorunu, mantık hatası, "bu saçma olmuş" noktaları._
