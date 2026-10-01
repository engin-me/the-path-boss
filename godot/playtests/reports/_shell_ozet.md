# Fabrika kabuğu simülasyonu — gerçekçi ekonomi (yeniden kurulum)

Test girdisidir; denge kararı değildir. Girdiler: `godot/playtests/ekonomi_degerleri.csv` ve kullanıcının gerçek dünya değerleri.

Koşullar: 60 tohum × 24 ay; başlangıç parası $24k (5 yıl × $400 tasarruf); tezgâh fiyatları (Hassas) Torna 75k, Freze 90k, Taşlama 110k, Dövme 150k, seviye çarpanları 0,6 / 1,0 / 2,4; mavi yaka Torna 1,0k, Freze 1,1k, Taşlama 1,3k, Dövme 1,5k (Dövme 2 kişi); dolaylı personel her 4 doğrudan işçiye 1; beyaz yaka 4. tezgâhtan itibaren sırayla; kira $4/m² + bina işletme $4/m²; amortisman 20 yıl; hızlı satış %80; çelik 600/1000 $/t; sarf %3,5; enerji kW × saat × $0,13. Müşteri referans marjı sade işte %60, karmaşık işte %100 (kalibrasyon girdisi `mid_base`/`mid_slope`).

Karakterler betiklidir (fiyat = kendi maliyet tahmini × (1 + marj)); Sermayeli karakterler $220k–300k ile başlar.

Karakter | Kiralanamadı | Ayakta | Zorunlu kapanış | İflas | Ort. son net kasa | En düşük kasa (ort.) | OEE (24 sa, ort.) | Kapasite kullanımı | Ort. vardiya | Geç teslim / teslim | Bırakılan-iptal | Son skor | Teklif: kabul / karşı / ret 
 --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: 
 Tek makine | 0 | 37 | 0 | 23 | -3 | -9 | %14 | %84 | 1.0 | 102 / 225 | 16 | %72 | 262 / 22 / 0 
 Küçük temkinli | 0 | 9 | 0 | 51 | -16 | -17 | %15 | %74 | 1.0 | 71 / 103 | 34 | %65 | 156 / 0 / 0 
 Küçük vardiyacı | 0 | 60 | 0 | 0 | 186 | 1 | %60 | %97 | 2.9 | 24 / 609 | 0 | %94 | 595 / 265 / 103 
 Orta ikinci el | 0 | 29 | 0 | 31 | 9 | -14 | %46 | %94 | 2.6 | 24 / 329 | 2 | %87 | 412 / 42 / 1 
 Sermayeli yeni makine | 0 | 58 | 0 | 2 | 432 | 14 | %64 | %90 | 2.6 | 122 / 695 | 10 | %83 | 357 / 604 / 1006 
 Sermayeli büyük | 0 | 59 | 0 | 1 | 404 | 102 | %58 | %82 | 2.6 | 118 / 550 | 112 | %63 | 819 / 185 / 78

## Bulgular

1. **Tek ikinci el torna, tek vardiya, patron operatör** en zor başlangıç: yaklaşık yarısı iflas ediyor, kalanı zar zor ayakta. İşin çoğu geç teslim (eski makine, bakım sorunları). Büyümek için ikinci vardiya ve ikinci makine şart.
2. **Küçük vardiyacı** (3 ikinci el makine, 2,9 vardiya) 24 ayda $186k'ya ulaşıyor; küçük başlayanlar için vardiya en güçlü kaldıraç.
3. **Küçük temkinli** (Pacific Alloy, tek vardiya) çoğunlukla batıyor; Pacific hâlâ tuzak.
4. Sermayeli karakterler (yeni makine, büyük) yüksek ve istikrarlı; ancak 24 ayda 10–15× büyüme hızlı sayılır, kalibrasyon sürüyor.
5. Müşteri marjı ve talep bandı ayarlanabilir (`mid=` ve `slope=` bağımsız değişkenleri).
