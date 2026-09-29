# Oyun testi — Teknik Usta

Yazan: Claude · Persona dosyası: `01_teknik_usta.json` · Tohum: 11.0 · Bu rapor test girdisidir, tasarım kararı değildir.

> Üretimden gelen diplomasız usta: saha alanlarında tavanda (70), finans ve yatırımı zayıf. İşi doldurur, yalnız gördüğü sorunu düzeltir.

**Yetkinlikler:** Üretim 70, Planlama 50, Depo & Sevkiyat 60, Bakım 70, Kalite 70, Satın Alma 50, Finans 30, Ar-Ge / Ür-Ge 30, Yatırım 30, İnsan Yönetimi 35

**Diploma:** Diploma yok (tavanı aşan puanlar kırpılır; ayrıntı olay geçmişinde)

**Başlangıç:** para 400.0, makineler {"A":2.0}, politika `{"buy":[{"month":4.0,"type":"B"}],"credit_when_cash_below":60.0,"fix":"visible_only","hire_when_hidden_loss":8.0,"jobs":"greedy","min_chance":"Orta"}`

## Aylar

| Ay | Çıktı | Kayıp | Gelir | Düzelt öncesi sorun satırları | Düzelt başarı/deneme | Danışman | Önlenen | Ay sonu kasa | Açık / eşik |
| --- | --- | ---: | ---: | --- | --- | --- | ---: | ---: | --- |
| 1 | 32/40 | 8 | 51 | 1 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 212 | 0 / 228 |
| 2 | 72/80 | 7 | 96 | 1 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 218 | 0 / 226 |
| 3 | 0/0 | 0 | 0 | 2 görünür / 1 gizli | 2/2 (engel 0) | — | 0 | 144 | 0 / 237 |
| 4 | 32/40 | 8 | 50 | 1 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 113 | 0 / 351 |
| 5 | 0/0 | 0 | 0 | 1 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 44 | 0 / 314 |
| 6 | 24/35 | 10 | 37 | 2 görünür / 1 gizli | 2/2 (engel 0) | — | 0 | 82 | 18 / 235 |
| 7 | 66/75 | 9 | 90 | 1 görünür / 1 gizli | 0/0 (engel 1) | — | 0 | 91 | 9 / 250 |
| 8 | 49/65 | 15 | 78 | 2 görünür / 1 gizli | 0/0 (engel 2) | — | 1 | 94 | 6 / 249 |
| 9 | 45/65 | 20 | 68 | 3 görünür / 1 gizli | 0/0 (engel 3) | — | 0 | 81 | 19 / 253 |
| 10 | 6/20 | 13 | 9 | 3 görünür / 3 gizli | 1/1 (engel 2) | — | 0 | 11 | 89 / 225 |
| 11 | 16/45 | 29 | 23 | 4 görünür / 3 gizli | 0/0 (engel 4) | — | 0 | -40 | 140 / 180 |
| 12 | 9/30 | 20 | 13 | 4 görünür / 4 gizli | 0/0 (engel 4) | — | 0 | -98 | 198 / 179 |

## Sonuç

- Zorunlu kapanış ve iflas. Son kasa -98, borç 100.
- Bu sefer Depo & Sevkiyat bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 60, bu alanın görülmeyen kaybı 80.)
- Bu sefer Finans bilgisini 50'ye taşımadan fabrika kurmayacağım. (Sende 30, bu alanın görülmeyen kaybı 19.) Bunun için önce ilgili diploma gerekir; diplomasız tavan 30.
- İnsan Yönetimi 1 kişi kaynaklı olayı daha doğmadan önledi.

## Kapanış raporu

- Depo & Sevkiyat T3 · toplam kayıp 80 · görülmedi · sürüyor · kesin çözüm için 70 (patron 60)
- Finans T2 · toplam kayıp 19 · görülmedi · sürüyor · kesin çözüm için 50 (patron 30)
- Bakım T2 · toplam kayıp 19 · görüldü · çözüldü · kesin çözüm için 50 (patron 70)
- Depo & Sevkiyat T2 · toplam kayıp 17 · görüldü · sürüyor · kesin çözüm için 50 (patron 60)
- İnsan Yönetimi T2 · toplam kayıp 16 · görülmedi · sürüyor · kesin çözüm için 50 (patron 35)
- Kalite T3 · toplam kayıp 14 · görüldü · sürüyor · kesin çözüm için 70 (patron 70)
- Finans T1 · toplam kayıp 10 · görüldü · sürüyor · kesin çözüm için 30 (patron 30)
- Bakım T3 · toplam kayıp 6 · görüldü · sürüyor · kesin çözüm için 70 (patron 70)
- Depo & Sevkiyat T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Ar-Ge / Ür-Ge T1 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 30 (patron 30)
- Üretim T2 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 50 (patron 70)
- Yatırım T3 · toplam kayıp 2 · görülmedi · sürüyor · kesin çözüm için 70 (patron 30)
- Bakım T2 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 50 (patron 70)
- Kalite T2 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 50 (patron 70)
- Bakım T2 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 50 (patron 70)
- Planlama T1 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 30 (patron 50)
- İnsan Yönetimi T1 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 30 (patron 35)

## Otomatik bulgular

- Ay 1: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 3: hiç iş alınmadı; bütün kapasite boş kaldı.
- Ay 3: departman kayıp tavanı (%20) devreye girdi.
- Ay 4: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 5: hiç iş alınmadı; bütün kapasite boş kaldı.
- Ay 5: departman kayıp tavanı (%20) devreye girdi.
- Ay 6: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 7: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 7: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 8: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 8: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 9: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 9: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 10: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 10: departman kayıp tavanı (%20) devreye girdi.
- Ay 11: ay başı kasa (11) giderleri (72) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 11: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 11: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 11: departman kayıp tavanı (%20) devreye girdi.
- Ay 12: ay başı kasa (-40) giderleri (68) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 12: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 12: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 12: departman kayıp tavanı (%20) devreye girdi.

## Olay geçmişi

- Patron: Teknik Usta · Diploma yok · toplam yetkinlik 495/600 · başlangıç parası 400
- Fabrika açıldı: 2 makine, ölçek Küçük, kasa 240
- Ay 1: Düzelt Ar-Ge / Ür-Ge T1 → başarılı (7 para, 2 sa)
- Ay 1: 32/40 çıktı, gelir 51, kasa 212, borç açığı 0 / eşik 307
- Ay 2: Düzelt İnsan Yönetimi T1 → başarılı (7 para, 3 sa)
- Ay 2: 73/80 çıktı, gelir 96, kasa 218, borç açığı 0 / eşik 226
- Ay 3: Düzelt Depo & Sevkiyat T1 → başarılı (10 para, 2 sa)
- Ay 3: Düzelt Planlama T1 → başarılı (10 para, 3 sa)
- Ay 3: 0/0 çıktı, gelir 0, kasa 144, borç açığı 0 / eşik 225
- Ay 4: Düzelt Bakım T2 → başarılı (14 para, 3 sa)
- Ay 4: 32/40 çıktı, gelir 50, kasa 113, borç açığı 0 / eşik 236
- Ay 5: Düzelt Üretim T2 → başarılı (15 para, 5 sa)
- Ay 5: 0/0 çıktı, gelir 0, kasa 44, borç açığı 0 / eşik 350
- Ay 6: kriz kredisi 100 alındı; borç açığı değişmedi.
- Ay 6: Düzelt Bakım T2 → başarılı (13 para, 4 sa)
- Ay 6: Düzelt Kalite T2 → başarılı (18 para, 5 sa)
- Ay 6: 25/35 çıktı, gelir 37, kasa 82, borç açığı 18 / eşik 313
- Ay 7: 66/75 çıktı, gelir 90, kasa 91, borç açığı 9 / eşik 234
- Ay 8: 50/65 çıktı, gelir 78, kasa 94, borç açığı 6 / eşik 249
- Ay 9: 45/65 çıktı, gelir 68, kasa 81, borç açığı 19 / eşik 248
- Ay 10: Düzelt Bakım T2 → başarılı (17 para, 3 sa)
- Ay 10: 7/20 çıktı, gelir 9, kasa 11, borç açığı 89 / eşik 252
- Ay 11: 16/45 çıktı, gelir 23, kasa -40, borç açığı 140 / eşik 224
- Ay 12: 10/30 çıktı, gelir 13, kasa -98, borç açığı 198 / eşik 179
- 12. ay kapandı. Kasa -98. Borç açığı 198, kurtarma eşiği 179. Eksi net pozisyon için 3 finansman gideri işledi. Borç açığı eşiği aştı: zorunlu kapanış. Tasfiye sonrası 131 açık kaldı; iflas.

## Test eden yorumu

_Bu bölümü oynayan kişi/yapay zekâ doldurur: tasarım sorunu, mantık hatası, "bu saçma olmuş" noktaları._
