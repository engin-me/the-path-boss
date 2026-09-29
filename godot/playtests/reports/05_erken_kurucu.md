# Oyun testi — Erken Kurucu

Yazan: Claude · Persona dosyası: `05_erken_kurucu.json` · Tohum: 55.0 · Bu rapor test girdisidir, tasarım kararı değildir.

> GAME_OVERVIEW'daki ilk oyun örneği: Üretim ve Sevkiyat güçlü, diğerleri zayıf; az parayla erkenden fabrika kurar.

**Yetkinlikler:** Üretim 90, Planlama 35, Depo & Sevkiyat 80, Bakım 35, Kalite 35, Satın Alma 30, Finans 30, Ar-Ge / Ür-Ge 25, Yatırım 30, İnsan Yönetimi 25

**Başlangıç:** para 300.0, makineler {"A":2.0}, politika `{"buy":[],"credit_when_cash_below":50.0,"fix":"all","hire_when_hidden_loss":8.0,"jobs":"greedy","min_chance":"Orta"}`

## Aylar

| Ay | Çıktı | Kayıp | Gelir | Sorun satırları | Düzelt başarı/deneme | Danışman | Önlenen | Ay sonu kasa | Açık / eşik |
| --- | --- | ---: | ---: | --- | --- | --- | ---: | ---: | --- |
| 1 | 34/45 | 11 | 54 | 0 görünür / 0 gizli | 2/2 (engel 0) | — | 0 | 87 | 0 / 301 |
| 2 | 71/75 | 4 | 100 | 0 görünür / 1 gizli | 0/0 (engel 0) | — | 0 | 106 | 0 / 263 |
| 3 | 47/60 | 13 | 71 | 0 görünür / 3 gizli | 0/0 (engel 0) | — | 0 | 97 | 0 / 244 |
| 4 | 54/75 | 21 | 80 | 0 görünür / 5 gizli | 0/0 (engel 0) | — | 0 | 100 | 0 / 215 |
| 5 | 40/70 | 30 | 56 | 0 görünür / 6 gizli | 1/1 (engel 0) | — | 0 | 62 | 0 / 219 |
| 6 | 4/15 | 10 | 6 | 0 görünür / 7 gizli | 0/0 (engel 0) | — | 0 | 9 | 0 / 173 |
| 7 | 0/0 | 0 | 0 | 1 görünür / 7 gizli | 1/1 (engel 3) | Aday 7-2 | 0 | 6 | 94 / 205 |
| 8 | 35/75 | 40 | 49 | 3 görünür / 7 gizli | 0/0 (engel 5) | Aday 7-2 | 0 | -33 | 133 / 211 |
| 9 | 32/80 | 48 | 46 | 5 görünür / 7 gizli | 0/0 (engel 7) | Aday 7-2 | 0 | -78 | 178 / 196 |
| 10 | 6/20 | 13 | 8 | 5 görünür / 9 gizli | 0/0 (engel 5) | — | 0 | -136 | 236 / 195 |

## Sonuç

- Zorunlu kapanış ve iflas. Son kasa -136, borç 100.
- Bu sefer Bakım bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 35, bu alanın görülmeyen kaybı 72.)
- Bu sefer Ar-Ge / Ür-Ge bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 25, bu alanın görülmeyen kaybı 44.)

## Kapanış raporu

- Bakım T3 · toplam kayıp 48 · görülmedi · sürüyor · kesin çözüm için 70 (patron 35)
- Kalite T2 · toplam kayıp 36 · görülmedi · sürüyor · kesin çözüm için 50 (patron 35)
- Ar-Ge / Ür-Ge T3 · toplam kayıp 28 · görülmedi · sürüyor · kesin çözüm için 70 (patron 25)
- Finans T2 · toplam kayıp 24 · görülmedi · sürüyor · kesin çözüm için 50 (patron 30)
- Bakım T2 · toplam kayıp 24 · görüldü · sürüyor · kesin çözüm için 50 (patron 35)
- Satın Alma T3 · toplam kayıp 20 · görülmedi · sürüyor · kesin çözüm için 70 (patron 30)
- Yatırım T2 · toplam kayıp 20 · görülmedi · sürüyor · kesin çözüm için 50 (patron 30)
- Ar-Ge / Ür-Ge T1 · toplam kayıp 16 · görülmedi · çözüldü · kesin çözüm için 30 (patron 25)
- Depo & Sevkiyat T3 · toplam kayıp 12 · görüldü · sürüyor · kesin çözüm için 70 (patron 80)
- Finans T1 · toplam kayıp 12 · görüldü · sürüyor · kesin çözüm için 30 (patron 30)
- Planlama T1 · toplam kayıp 10 · görüldü · sürüyor · kesin çözüm için 30 (patron 35)
- Planlama T2 · toplam kayıp 8 · görülmedi · sürüyor · kesin çözüm için 50 (patron 35)
- Bakım T1 · toplam kayıp 6 · görüldü · sürüyor · kesin çözüm için 30 (patron 35)
- Satın Alma T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 30)
- Üretim T1 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 30 (patron 90)
- Depo & Sevkiyat T3 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 70 (patron 80)
- Finans T3 · toplam kayıp 5 · görülmedi · sürüyor · kesin çözüm için 70 (patron 30)
- Yatırım T1 · toplam kayıp 2 · görüldü · sürüyor · kesin çözüm için 30 (patron 30)

## Otomatik bulgular

- Ay 1: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 3: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 4: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 5: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 6: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 6: departman kayıp tavanı (%20) devreye girdi.
- Ay 7: hiç iş alınmadı; bütün kapasite boş kaldı.
- Ay 7: departman kayıp tavanı (%20) devreye girdi.
- Ay 8: ay başı kasa (6) giderleri (86) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 8: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 8: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 9: ay başı kasa (-33) giderleri (88) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 9: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 9: kayıplar yüzünden 2 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 10: ay başı kasa (-78) giderleri (63) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 10: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 10: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 10: departman kayıp tavanı (%20) devreye girdi.

## Olay geçmişi

- Patron: Erken Kurucu · toplam yetkinlik 415/415 · başlangıç parası 300
- Fabrika açıldı: 2 makine, ölçek Küçük, kasa 140
- Ay 1: Düzelt Satın Alma T1 → başarılı (9 para, 2 sa)
- Ay 1: Düzelt Depo & Sevkiyat T3 → başarılı (30 para, 5 sa)
- Ay 1: 34/45 çıktı, gelir 54, kasa 87, borç açığı 0 / eşik 361
- Ay 2: 71/75 çıktı, gelir 100, kasa 106, borç açığı 0 / eşik 299
- Ay 3: 47/60 çıktı, gelir 71, kasa 97, borç açığı 0 / eşik 262
- Ay 4: 54/75 çıktı, gelir 80, kasa 100, borç açığı 0 / eşik 243
- Ay 5: Düzelt Üretim T1 → başarılı (8 para, 2 sa)
- Ay 5: 40/70 çıktı, gelir 56, kasa 62, borç açığı 0 / eşik 214
- Ay 6: 5/15 çıktı, gelir 6, kasa 9, borç açığı 0 / eşik 218
- Ay 7: kriz kredisi 100 alındı; borç açığı değişmedi.
- Ay 7: Aday 7-2 3 ay için tutuldu (39).
- Ay 7: Düzelt Ar-Ge / Ür-Ge T1 → başarılı (9 para, 1 sa)
- Ay 7: 0/0 çıktı, gelir 0, kasa 6, borç açığı 94 / eşik 172
- Ay 8: 35/75 çıktı, gelir 49, kasa -33, borç açığı 133 / eşik 204
- Ay 9: Aday 7-2 sözleşmesi bitti; bilgisi fabrikada kalmadı.
- Ay 9: 32/80 çıktı, gelir 46, kasa -78, borç açığı 178 / eşik 210
- Ay 10: 7/20 çıktı, gelir 8, kasa -136, borç açığı 236 / eşik 195
- 10. ay kapandı. Kasa -136. Borç açığı 236, kurtarma eşiği 195. Eksi net pozisyon için 4 finansman gideri işledi. Borç açığı eşiği aştı: zorunlu kapanış. Tasfiye sonrası 167 açık kaldı; iflas.

## Test eden yorumu

_Bu bölümü oynayan kişi/yapay zekâ doldurur: tasarım sorunu, mantık hatası, "bu saçma olmuş" noktaları._
