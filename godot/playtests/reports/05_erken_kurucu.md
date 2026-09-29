# Oyun testi — Erken Kurucu

Yazan: Claude · Persona dosyası: `05_erken_kurucu.json` · Tohum: 55.0 · Bu rapor test girdisidir, tasarım kararı değildir.

> GAME_OVERVIEW'daki ilk oyun örneği, diplomasız: Üretim ve Sevkiyat tavanda (70), diğerleri zayıf; az parayla erkenden fabrika kurar.

**Yetkinlikler:** Üretim 70, Planlama 35, Depo & Sevkiyat 70, Bakım 35, Kalite 35, Satın Alma 30, Finans 30, Ar-Ge / Ür-Ge 25, Yatırım 30, İnsan Yönetimi 25

**Diploma:** Diploma yok (tavanı aşan puanlar kırpılır; ayrıntı olay geçmişinde)

**Başlangıç:** para 300.0, makineler {"A":2.0}, politika `{"buy":[],"credit_when_cash_below":50.0,"fix":"all","hire_when_hidden_loss":8.0,"jobs":"greedy","min_chance":"Orta"}`

## Aylar

| Ay | Çıktı | Kayıp | Gelir | Düzelt öncesi sorun satırları | Düzelt başarı/deneme | Danışman | Önlenen | Ay sonu kasa | Açık / eşik |
| --- | --- | ---: | ---: | --- | --- | --- | ---: | ---: | --- |
| 1 | 34/45 | 11 | 54 | 2 görünür / 0 gizli | 2/2 (engel 0) | — | 0 | 87 | 0 / 335 |
| 2 | 16/20 | 4 | 25 | 0 görünür / 1 gizli | 0/0 (engel 0) | — | 0 | 49 | 0 / 311 |
| 3 | 51/65 | 13 | 77 | 0 görünür / 3 gizli | 0/0 (engel 0) | — | 0 | 149 | 0 / 275 |
| 4 | 55/80 | 25 | 85 | 0 görünür / 5 gizli | 2/2 (engel 2) | Aday 4-3 | 0 | 99 | 1 / 273 |
| 5 | 0/0 | 0 | 0 | 1 görünür / 3 gizli | 1/1 (engel 2) | Aday 4-3 | 0 | 14 | 86 / 254 |
| 6 | 6/20 | 13 | 10 | 2 görünür / 3 gizli | 0/0 (engel 3) | Aday 4-3 | 0 | -41 | 141 / 242 |
| 7 | 45/75 | 29 | 68 | 1 görünür / 5 gizli | 0/0 (engel 1) | — | 0 | -61 | 161 / 259 |
| 8 | 18/50 | 31 | 30 | 2 görünür / 5 gizli | 0/0 (engel 2) | — | 1 | -109 | 209 / 258 |
| 9 | 11/35 | 23 | 17 | 2 görünür / 6 gizli | 0/0 (engel 2) | — | 0 | -162 | 262 / 257 |

## Sonuç

- Zorunlu kapanış ve iflas. Son kasa -162, borç 100.
- Bu sefer Ar-Ge / Ür-Ge bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 25, bu alanın görülmeyen kaybı 60.) Bunun için önce ilgili diploma gerekir; diplomasız tavan 30.
- Bu sefer Bakım bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 35, bu alanın görülmeyen kaybı 52.)
- İnsan Yönetimi 1 kişi kaynaklı olayı daha doğmadan önledi.

## Kapanış raporu

- Planlama T3 · toplam kayıp 34 · görülmedi · sürüyor · kesin çözüm için 70 (patron 35)
- Ar-Ge / Ür-Ge T3 · toplam kayıp 33 · görülmedi · sürüyor · kesin çözüm için 70 (patron 25)
- Üretim T2 · toplam kayıp 26 · görüldü · sürüyor · kesin çözüm için 50 (patron 70)
- Bakım T2 · toplam kayıp 22 · görüldü · sürüyor · kesin çözüm için 50 (patron 35)
- Bakım T3 · toplam kayıp 22 · görülmedi · çözüldü · kesin çözüm için 70 (patron 35)
- Ar-Ge / Ür-Ge T1 · toplam kayıp 19 · görülmedi · sürüyor · kesin çözüm için 30 (patron 25)
- Ar-Ge / Ür-Ge T2 · toplam kayıp 9 · görülmedi · sürüyor · kesin çözüm için 50 (patron 25)
- Bakım T2 · toplam kayıp 8 · görülmedi · çözüldü · kesin çözüm için 50 (patron 35)
- Satın Alma T1 · toplam kayıp 8 · görüldü · sürüyor · kesin çözüm için 30 (patron 30)
- Satın Alma T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 30)
- İnsan Yönetimi T1 · toplam kayıp 6 · görülmedi · çözüldü · kesin çözüm için 30 (patron 25)
- Depo & Sevkiyat T3 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 70 (patron 70)
- İnsan Yönetimi T1 · toplam kayıp 3 · görülmedi · sürüyor · kesin çözüm için 30 (patron 25)

## Otomatik bulgular

- Ay 1: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: departman kayıp tavanı (%20) devreye girdi.
- Ay 3: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 4: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 5: hiç iş alınmadı; bütün kapasite boş kaldı.
- Ay 5: departman kayıp tavanı (%20) devreye girdi.
- Ay 6: ay başı kasa (14) giderleri (62) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 6: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 6: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 6: departman kayıp tavanı (%20) devreye girdi.
- Ay 7: ay başı kasa (-41) giderleri (86) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 7: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 7: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 8: ay başı kasa (-61) giderleri (75) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 8: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 8: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 8: departman kayıp tavanı (%20) devreye girdi.
- Ay 9: ay başı kasa (-109) giderleri (65) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 9: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 9: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 9: departman kayıp tavanı (%20) devreye girdi.

## Olay geçmişi

- Patron: Erken Kurucu · Diploma yok · toplam yetkinlik 385/415 · başlangıç parası 300
- Fabrika açıldı: 2 makine, ölçek Küçük, kasa 140
- Ay 1: Düzelt Satın Alma T1 → başarılı (9 para, 2 sa)
- Ay 1: Düzelt Depo & Sevkiyat T3 → başarılı (30 para, 5 sa)
- Ay 1: 34/45 çıktı, gelir 54, kasa 87, borç açığı 0 / eşik 361
- Ay 2: 16/20 çıktı, gelir 25, kasa 49, borç açığı 0 / eşik 334
- Ay 3: kriz kredisi 100 alındı; borç açığı değişmedi.
- Ay 3: 52/65 çıktı, gelir 77, kasa 149, borç açığı 0 / eşik 310
- Ay 4: Aday 4-3 3 ay için tutuldu (21).
- Ay 4: Düzelt İnsan Yönetimi T1 → başarılı (6 para, 1 sa)
- Ay 4: Düzelt Bakım T2 → başarılı (18 para, 2 sa)
- Ay 4: 55/80 çıktı, gelir 85, kasa 99, borç açığı 1 / eşik 274
- Ay 5: Düzelt Bakım · derinliği bilinmeyen sorun → başarılı (30 para, 6 sa)
- Ay 5: 0/0 çıktı, gelir 0, kasa 14, borç açığı 86 / eşik 272
- Ay 6: Aday 4-3 sözleşmesi bitti; bilgisi fabrikada kalmadı.
- Ay 6: 7/20 çıktı, gelir 10, kasa -41, borç açığı 141 / eşik 253
- Ay 7: 46/75 çıktı, gelir 68, kasa -61, borç açığı 161 / eşik 241
- Ay 8: 19/50 çıktı, gelir 30, kasa -109, borç açığı 209 / eşik 258
- Ay 9: 12/35 çıktı, gelir 17, kasa -162, borç açığı 262 / eşik 257
- 9. ay kapandı. Kasa -162. Borç açığı 262, kurtarma eşiği 257. Eksi net pozisyon için 4 finansman gideri işledi. Borç açığı eşiği aştı: zorunlu kapanış. Tasfiye sonrası 192 açık kaldı; iflas.

## Test eden yorumu

_Bu bölümü oynayan kişi/yapay zekâ doldurur: tasarım sorunu, mantık hatası, "bu saçma olmuş" noktaları._
