# Fabrika kabuğu simülasyonu — son durum

Test girdisidir; denge kararı değildir. Motor: `godot/scripts/shell/shell_boss.gd`, koşucu: `godot/tests/shell_sim.gd`. Kurallar IDEA-015..018 önerileridir, FREEZE değildir.

Koşullar: 100 tohum × 12 ay; başlangıç parası $800k; `price_per_x` 0,13. Bu koşuda yeni mekanikler açık: μ (parça işleme katsayısı) ve ay sonu hurda gideri (tablo aralığından çekilir, üretilen miktara göre kesilir), gerçek kullanıma bağlı enerji, fabrika geneli vardiya planı (mesai +4 sa, saatlik ücret 1,5×), tezgah alanı sınırı %51, personel politikası. Karakterler betiklidir: kendi maliyet hesabı × (1 + marj) ile teklif verir (Tek makine ve temkinliler %30, vardiyacılar %45, yeni makineci %60).

## Personel politikası Standart (varsayılan)

| Karakter | Kiralanamadı | Ayakta | Zorunlu kapanış | İflas | Ort. son net kasa | En düşük kasa (ort.) | İlk iş ayı | OEE (24 sa, ort.) | Kapasite kullanımı | Ort. vardiya | Geç teslim / teslim | Bırakılan-iptal | Son skor | Teklif: kabul / karşı / ret | Gizli satırlı ay | Danışmansız deneme mümkün | Para engeli |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Tek makine | 0 | 100 | 0 | 0 | 289 | 193 | 1.1 | %24 | %95 | 1.0 | 41 / 270 | 0 | %84 | 293 / 139 / 100 | 51 | 51 | 0 |
| Küçük temkinli | 0 | 78 | 0 | 22 | -63 | -160 | 1.0 | %22 | %64 | 1.0 | 98 / 164 | 39 | %69 | 297 / 104 / 39 | 66 | 64 | 2 |
| Küçük vardiyacı | 0 | 100 | 0 | 0 | 919 | 102 | 1.0 | %59 | %86 | 2.5 | 35 / 791 | 0 | %92 | 498 / 739 / 1144 | 52 | 50 | 2 |
| Orta ikinci el | 0 | 90 | 0 | 10 | 68 | -248 | 1.0 | %40 | %69 | 1.8 | 37 / 504 | 8 | %86 | 504 / 255 / 241 | 89 | 34 | 55 |
| Orta yeni makine | 0 | 95 | 0 | 5 | 65 | -80 | 2.9 | %30 | %34 | 1.2 | 7 / 97 | 0 | %82 | 4 / 131 / 6533 | 22 | 22 | 0 |
| Büyük iddialı | 0 | 88 | 0 | 12 | 63 | -376 | 1.0 | %35 | %56 | 1.6 | 43 / 414 | 12 | %84 | 368 / 277 / 370 | 91 | 26 | 65 |

## Politika karşılaştırması (ort. son net kasa)

Yok ($0): Tek makine / Küçük vardiyacı / Büyük iddialı için aşağıdaki kısa tablo; İyi ($1.200/kişi) için de.

**Yok**

| Karakter | Ayakta | İflas | Ort. son net kasa | En düşük kasa (ort.) |
| --- | ---: | ---: | ---: | ---: |
| Tek makine | 100 | 0 | 261 | 168 |
| Küçük temkinli | 77 | 23 | -96 | -173 |
| Küçük vardiyacı | 100 | 0 | 773 | 80 |
| Orta ikinci el | 91 | 9 | 79 | -245 |
| Orta yeni makine | 98 | 2 | 105 | -60 |
| Büyük iddialı | 90 | 10 | 118 | -374 |

**İyi**

| Karakter | Ayakta | İflas | Ort. son net kasa | En düşük kasa (ort.) |
| --- | ---: | ---: | ---: | ---: |
| Tek makine | 100 | 0 | 318 | 214 |
| Küçük temkinli | 78 | 22 | -62 | -157 |
| Küçük vardiyacı | 100 | 0 | 840 | 95 |
| Orta ikinci el | 91 | 9 | 30 | -275 |
| Orta yeni makine | 95 | 5 | 31 | -77 |
| Büyük iddialı | 88 | 12 | 29 | -380 |

## Bulgular

1. **Hiçbir politika baskın değil.** Standart ile Yok/İyi arasındaki fark çoğu karakterde gürültü sınırında; İyi politika, yan gideri ödemeye karşılık sorun önlemeyle az geri kazandırıyor. Küçük işletmede yan gider karın küçük bir kısmı, büyükte daha çok yük.
2. **Pacific tuzağı sürüyor.** Küçük temkinli (Pacific Alloy, tek vardiya, iki torna) her koşulda %22 iflas; teslimlerin çoğu geç, 40+ iş bırakılıyor. Aynı karakteri Nordhaus ile oynatınca iflas ~%15'e iniyor. Gerçek oyuncu için "bu tedarikçiyle malzeme Ay N'de gelir, teslim Ay M" uyarısı öneriliyor.
3. **Yeni makineci karakter (marj %60) hâlâ ilan kazanamıyor** (4 kabul / 6500 ret). Bu karakterin betiği; gerçek oyuncu marjını ayarlar.
4. **Genel gider sabit 6.** Kira ve krediyi makineye bölmek (denendi) tek makineli dükkânda hiçbir ilan kazandırmadı; bu yüzden paylaştırma "alan ÷ 30 m² ile makine sayısından büyüğü" olarak alındı.
5. **Tezgah alanı %51 kuralı** simülasyondaki hiçbir karakteri kısıtlamadı (Para engeli sütunu değişmedi).

Sütunlu tam tablo (Standart):

| Karakter | Kiralanamadı | Ayakta | Zorunlu kapanış | İflas | Ort. son net kasa | En düşük kasa (ort.) | İlk iş ayı | OEE (24 sa, ort.) | Kapasite kullanımı | Ort. vardiya | Geç teslim / teslim | Bırakılan-iptal | Son skor | Teklif: kabul / karşı / ret | Gizli satırlı ay | Danışmansız deneme mümkün | Para engeli |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Tek makine | 0 | 100 | 0 | 0 | 289 | 193 | 1.1 | %24 | %95 | 1.0 | 41 / 270 | 0 | %84 | 293 / 139 / 100 | 51 | 51 | 0 |
| Küçük temkinli | 0 | 78 | 0 | 22 | -63 | -160 | 1.0 | %22 | %64 | 1.0 | 98 / 164 | 39 | %69 | 297 / 104 / 39 | 66 | 64 | 2 |
| Küçük vardiyacı | 0 | 100 | 0 | 0 | 919 | 102 | 1.0 | %59 | %86 | 2.5 | 35 / 791 | 0 | %92 | 498 / 739 / 1144 | 52 | 50 | 2 |
| Orta ikinci el | 0 | 90 | 0 | 10 | 68 | -248 | 1.0 | %40 | %69 | 1.8 | 37 / 504 | 8 | %86 | 504 / 255 / 241 | 89 | 34 | 55 |
| Orta yeni makine | 0 | 95 | 0 | 5 | 65 | -80 | 2.9 | %30 | %34 | 1.2 | 7 / 97 | 0 | %82 | 4 / 131 / 6533 | 22 | 22 | 0 |
| Büyük iddialı | 0 | 88 | 0 | 12 | 63 | -376 | 1.0 | %35 | %56 | 1.6 | 43 / 414 | 12 | %84 | 368 / 277 / 370 | 91 | 26 | 65 |
