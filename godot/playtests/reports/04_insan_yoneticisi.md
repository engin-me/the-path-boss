# Oyun testi — İnsan Yöneticisi

Yazan: Claude · Persona dosyası: `04_insan_yoneticisi.json` · Tohum: 44.0 · Bu rapor test girdisidir, tasarım kararı değildir.

> Takım liderliğinden gelen; İnsan Yönetimi 100. Sorunların doğmadan önlenmesine güvenir, temkinli iş alır.

**Yetkinlikler:** Üretim 60, Planlama 80, Depo & Sevkiyat 60, Bakım 50, Kalite 60, Satın Alma 50, Finans 50, Ar-Ge / Ür-Ge 30, Yatırım 50, İnsan Yönetimi 100

**Diploma:** İşletme / İktisat (tavanı aşan puanlar kırpılır; ayrıntı olay geçmişinde)

**Başlangıç:** para 400.0, makineler {"A":2.0}, politika `{"buy":[],"credit_when_cash_below":60.0,"fix":"visible_only","hire_when_hidden_loss":5.0,"jobs":"safe","min_chance":"Orta"}`

## Aylar

| Ay | Çıktı | Kayıp | Gelir | Düzelt öncesi sorun satırları | Düzelt başarı/deneme | Danışman | Önlenen | Ay sonu kasa | Açık / eşik |
| --- | --- | ---: | ---: | --- | --- | --- | ---: | ---: | --- |
| 1 | 43/50 | 7 | 60 | 1 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 214 | 0 / 288 |
| 2 | 34/50 | 15 | 53 | 2 görünür / 1 gizli | 2/2 (engel 0) | — | 0 | 158 | 0 / 297 |
| 3 | 20/35 | 14 | 31 | 1 görünür / 2 gizli | 1/1 (engel 0) | — | 0 | 108 | 0 / 275 |
| 4 | 38/50 | 12 | 48 | 1 görünür / 2 gizli | 1/1 (engel 0) | — | 0 | 68 | 0 / 265 |
| 5 | 39/55 | 15 | 61 | 1 görünür / 2 gizli | 0/0 (engel 1) | — | 0 | 54 | 0 / 223 |
| 6 | 18/40 | 21 | 24 | 2 görünür / 2 gizli | 3/3 (engel 0) | Aday 6-3 | 1 | 38 | 62 / 240 |
| 7 | 0/0 | 0 | 0 | 0 görünür / 1 gizli | 0/0 (engel 0) | Aday 6-3 | 1 | -17 | 117 / 189 |
| 8 | 13/20 | 7 | 17 | 1 görünür / 1 gizli | 0/0 (engel 1) | Aday 6-3 | 1 | -64 | 164 / 201 |
| 9 | 15/25 | 10 | 20 | 2 görünür / 1 gizli | 0/0 (engel 2) | — | 0 | -110 | 210 / 200 |

## Sonuç

- Zorunlu kapanış ve iflas. Son kasa -110, borç 100.
- Bu sefer Yatırım bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 50, bu alanın görülmeyen kaybı 41.)
- Bu sefer Ar-Ge / Ür-Ge bilgisini 50'ye taşımadan fabrika kurmayacağım. (Sende 30, bu alanın görülmeyen kaybı 27.) Bunun için önce ilgili diploma gerekir; diplomasız tavan 30.
- İnsan Yönetimi 3 kişi kaynaklı olayı daha doğmadan önledi.

## Kapanış raporu

- Yatırım T3 · toplam kayıp 41 · görülmedi · sürüyor · kesin çözüm için 70 (patron 50)
- Ar-Ge / Ür-Ge T2 · toplam kayıp 27 · görülmedi · çözüldü · kesin çözüm için 50 (patron 30)
- Planlama T3 · toplam kayıp 10 · görüldü · çözüldü · kesin çözüm için 70 (patron 80)
- İnsan Yönetimi T2 · toplam kayıp 6 · görüldü · sürüyor · kesin çözüm için 50 (patron 100)
- Planlama T3 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 70 (patron 80)
- Kalite T1 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Finans T2 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 50 (patron 50)
- Finans T1 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 30 (patron 50)
- İnsan Yönetimi T1 · toplam kayıp 5 · görüldü · sürüyor · kesin çözüm için 30 (patron 100)
- Depo & Sevkiyat T2 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 50 (patron 60)
- Depo & Sevkiyat T2 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 50 (patron 60)

## Otomatik bulgular

- Ay 1: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 3: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 4: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 5: ay başı kasa (68) giderleri (75) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 5: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 5: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 6: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 7: hiç iş alınmadı; bütün kapasite boş kaldı.
- Ay 7: ay başı kasa (38) giderleri (54) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 7: departman kayıp tavanı (%20) devreye girdi.
- Ay 8: ay başı kasa (-17) giderleri (62) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 8: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 8: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 8: departman kayıp tavanı (%20) devreye girdi.
- Ay 9: ay başı kasa (-64) giderleri (63) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 9: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 9: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 9: departman kayıp tavanı (%20) devreye girdi.

## Olay geçmişi

- Patron: İnsan Yöneticisi · İşletme / İktisat · toplam yetkinlik 590/600 · başlangıç parası 400
- Fabrika açıldı: 2 makine, ölçek Küçük, kasa 240
- Ay 1: Düzelt Depo & Sevkiyat T2 → başarılı (15 para, 4 sa)
- Ay 1: 43/50 çıktı, gelir 60, kasa 214, borç açığı 0 / eşik 265
- Ay 2: Düzelt Planlama T3 → başarılı (29 para, 6 sa)
- Ay 2: Düzelt Kalite T1 → başarılı (9 para, 3 sa)
- Ay 2: 35/50 çıktı, gelir 53, kasa 158, borç açığı 0 / eşik 287
- Ay 3: Düzelt Finans T2 → başarılı (16 para, 3 sa)
- Ay 3: 21/35 çıktı, gelir 31, kasa 108, borç açığı 0 / eşik 296
- Ay 4: Düzelt Depo & Sevkiyat T2 → başarılı (15 para, 3 sa)
- Ay 4: 38/50 çıktı, gelir 48, kasa 68, borç açığı 0 / eşik 274
- Ay 5: 40/55 çıktı, gelir 61, kasa 54, borç açığı 0 / eşik 264
- Ay 6: kriz kredisi 100 alındı; borç açığı değişmedi.
- Ay 6: Aday 6-3 3 ay için tutuldu (18).
- Ay 6: Düzelt Planlama T3 → başarılı (32 para, 5 sa)
- Ay 6: Düzelt Ar-Ge / Ür-Ge T2 → başarılı (15 para, 2 sa)
- Ay 6: Düzelt Finans T1 → başarılı (8 para, 3 sa)
- Ay 6: 19/40 çıktı, gelir 24, kasa 38, borç açığı 62 / eşik 222
- Ay 7: 0/0 çıktı, gelir 0, kasa -17, borç açığı 117 / eşik 239
- Ay 8: Aday 6-3 sözleşmesi bitti; bilgisi fabrikada kalmadı.
- Ay 8: 13/20 çıktı, gelir 17, kasa -64, borç açığı 164 / eşik 188
- Ay 9: 15/25 çıktı, gelir 20, kasa -110, borç açığı 210 / eşik 200
- 9. ay kapandı. Kasa -110. Borç açığı 210, kurtarma eşiği 200. Eksi net pozisyon için 3 finansman gideri işledi. Borç açığı eşiği aştı: zorunlu kapanış. Tasfiye sonrası 140 açık kaldı; iflas.

## Test eden yorumu

_Bu bölümü oynayan kişi/yapay zekâ doldurur: tasarım sorunu, mantık hatası, "bu saçma olmuş" noktaları._
