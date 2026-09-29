# Oyun testi — Teknik Usta

Yazan: Claude · Persona dosyası: `01_teknik_usta.json` · Tohum: 11.0 · Bu rapor test girdisidir, tasarım kararı değildir.

> Üretimden gelen, makineyi bilen ama finans ve yatırımı zayıf patron. İşi doldurur, yalnız gördüğü sorunu düzeltir.

**Yetkinlikler:** Üretim 95, Planlama 55, Depo & Sevkiyat 60, Bakım 85, Kalite 80, Satın Alma 50, Finans 30, Ar-Ge / Ür-Ge 70, Yatırım 40, İnsan Yönetimi 35

**Başlangıç:** para 400.0, makineler {"A":2.0}, politika `{"buy":[{"month":4.0,"type":"B"}],"credit_when_cash_below":60.0,"fix":"visible_only","hire_when_hidden_loss":8.0,"jobs":"greedy","min_chance":"Orta"}`

## Aylar

| Ay | Çıktı | Kayıp | Gelir | Sorun satırları | Düzelt başarı/deneme | Danışman | Önlenen | Ay sonu kasa | Açık / eşik |
| --- | --- | ---: | ---: | --- | --- | --- | ---: | ---: | --- |
| 1 | 32/40 | 8 | 51 | 0 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 212 | 0 / 275 |
| 2 | 40/55 | 15 | 60 | 0 görünür / 1 gizli | 2/2 (engel 0) | — | 0 | 175 | 0 / 285 |
| 3 | 31/45 | 14 | 48 | 0 görünür / 1 gizli | 2/2 (engel 0) | — | 0 | 131 | 0 / 278 |
| 4 | 0/0 | 0 | 0 | 0 görünür / 1 gizli | 2/2 (engel 0) | — | 0 | 57 | 0 / 242 |
| 5 | 16/25 | 9 | 20 | 0 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 104 | 0 / 221 |
| 6 | 62/70 | 8 | 99 | 0 görünür / 1 gizli | 1/1 (engel 0) | — | 1 | 103 | 0 / 240 |
| 7 | 65/75 | 10 | 97 | 0 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 113 | 0 / 244 |
| 8 | 73/80 | 7 | 102 | 0 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 119 | 0 / 230 |
| 9 | 52/65 | 13 | 73 | 0 görünür / 1 gizli | 2/2 (engel 0) | — | 0 | 95 | 5 / 225 |
| 10 | 27/35 | 8 | 40 | 0 görünür / 1 gizli | 1/1 (engel 0) | — | 0 | 63 | 37 / 260 |
| 11 | 69/80 | 11 | 109 | 0 görünür / 2 gizli | 0/0 (engel 0) | — | 0 | 87 | 13 / 279 |
| 12 | 49/65 | 16 | 72 | 2 görünür / 2 gizli | 0/0 (engel 2) | — | 0 | 81 | 19 / 278 |

## Sonuç

- Fabrika test süresince ayakta kaldı. Son kasa 81, borç 100.
- Bu sefer Depo & Sevkiyat bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 60, bu alanın görülmeyen kaybı 60.)
- Bu sefer İnsan Yönetimi bilgisini 70'ye taşımadan fabrika kurmayacağım. (Sende 35, bu alanın görülmeyen kaybı 12.)
- İnsan Yönetimi 1 kişi kaynaklı olayı daha doğmadan önledi.

## Kapanış raporu

- Depo & Sevkiyat T3 · toplam kayıp 60 · görülmedi · sürüyor · kesin çözüm için 70 (patron 60)
- İnsan Yönetimi T3 · toplam kayıp 12 · görülmedi · sürüyor · kesin çözüm için 70 (patron 35)
- Üretim T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 95)
- Kalite T2 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 50 (patron 80)
- Depo & Sevkiyat T1 · toplam kayıp 6 · görüldü · çözüldü · kesin çözüm için 30 (patron 60)
- Kalite T1 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 30 (patron 80)
- Satın Alma T1 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 30 (patron 50)
- Planlama T1 · toplam kayıp 5 · görüldü · çözüldü · kesin çözüm için 30 (patron 55)
- Üretim T2 · toplam kayıp 4 · görüldü · çözüldü · kesin çözüm için 50 (patron 95)
- Satın Alma T2 · toplam kayıp 4 · görüldü · çözüldü · kesin çözüm için 50 (patron 50)
- Finans T1 · toplam kayıp 4 · görüldü · çözüldü · kesin çözüm için 30 (patron 30)
- Planlama T2 · toplam kayıp 3 · görüldü · sürüyor · kesin çözüm için 50 (patron 55)
- Yatırım T1 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 30 (patron 40)
- Ar-Ge / Ür-Ge T2 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 50 (patron 70)
- Ar-Ge / Ür-Ge T1 · toplam kayıp 3 · görüldü · çözüldü · kesin çözüm için 30 (patron 70)
- Üretim T1 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 30 (patron 95)
- Ar-Ge / Ür-Ge T1 · toplam kayıp 2 · görüldü · çözüldü · kesin çözüm için 30 (patron 70)
- Üretim T2 · toplam kayıp 2 · görüldü · sürüyor · kesin çözüm için 50 (patron 95)

## Otomatik bulgular

- Ay 1: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 2: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 3: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 3: departman kayıp tavanı (%20) devreye girdi.
- Ay 4: hiç iş alınmadı; bütün kapasite boş kaldı.
- Ay 4: departman kayıp tavanı (%20) devreye girdi.
- Ay 5: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 6: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 7: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 8: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 9: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 10: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 11: ay başı kasa (63) giderleri (84) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor.
- Ay 11: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).
- Ay 12: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi.
- Ay 12: kayıplar yüzünden 1 iş tam teslim edilemedi; ayrı ceza yok (FRZ-004).

## Olay geçmişi

- Patron: Teknik Usta · toplam yetkinlik 600/600 · başlangıç parası 400
- Fabrika açıldı: 2 makine, ölçek Küçük, kasa 240
- Ay 1: Düzelt Ar-Ge / Ür-Ge T1 → başarılı (7 para, 2 sa)
- Ay 1: 32/40 çıktı, gelir 51, kasa 212, borç açığı 0 / eşik 307
- Ay 2: Düzelt Üretim T1 → başarılı (8 para, 2 sa)
- Ay 2: Düzelt Üretim T2 → başarılı (15 para, 5 sa)
- Ay 2: 40/55 çıktı, gelir 60, kasa 175, borç açığı 0 / eşik 274
- Ay 3: Düzelt Kalite T2 → başarılı (16 para, 5 sa)
- Ay 3: Düzelt Kalite T1 → başarılı (6 para, 2 sa)
- Ay 3: 31/45 çıktı, gelir 48, kasa 131, borç açığı 0 / eşik 284
- Ay 4: Düzelt Satın Alma T1 → başarılı (6 para, 3 sa)
- Ay 4: Düzelt Satın Alma T2 → başarılı (14 para, 5 sa)
- Ay 4: 0/0 çıktı, gelir 0, kasa 57, borç açığı 0 / eşik 277
- Ay 5: kriz kredisi 100 alındı; borç açığı değişmedi.
- Ay 5: Düzelt Finans T1 → başarılı (9 para, 3 sa)
- Ay 5: 16/25 çıktı, gelir 20, kasa 104, borç açığı 0 / eşik 241
- Ay 6: Düzelt Ar-Ge / Ür-Ge T2 → başarılı (15 para, 3 sa)
- Ay 6: 62/70 çıktı, gelir 99, kasa 103, borç açığı 0 / eşik 220
- Ay 7: Düzelt Planlama T1 → başarılı (7 para, 3 sa)
- Ay 7: 65/75 çıktı, gelir 97, kasa 113, borç açığı 0 / eşik 239
- Ay 8: Düzelt Ar-Ge / Ür-Ge T1 → başarılı (8 para, 2 sa)
- Ay 8: 73/80 çıktı, gelir 102, kasa 119, borç açığı 0 / eşik 243
- Ay 9: Düzelt Depo & Sevkiyat T1 → başarılı (8 para, 3 sa)
- Ay 9: Düzelt Üretim T1 → başarılı (8 para, 3 sa)
- Ay 9: 52/65 çıktı, gelir 73, kasa 95, borç açığı 5 / eşik 229
- Ay 10: Düzelt Yatırım T1 → başarılı (6 para, 3 sa)
- Ay 10: 27/35 çıktı, gelir 40, kasa 63, borç açığı 37 / eşik 224
- Ay 11: 69/80 çıktı, gelir 109, kasa 87, borç açığı 13 / eşik 259
- Ay 12: 49/65 çıktı, gelir 72, kasa 81, borç açığı 19 / eşik 278

## Test eden yorumu

_Bu bölümü oynayan kişi/yapay zekâ doldurur: tasarım sorunu, mantık hatası, "bu saçma olmuş" noktaları._
