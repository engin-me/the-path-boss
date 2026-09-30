# Fabrika kabuğu simülasyonu (ShellBoss)

Test girdisidir; denge kararı değildir. Motor: `godot/scripts/shell/shell_boss.gd`, koşucu: `godot/tests/shell_sim.gd`. Kural önerileri: IDEA-015 ve IDEA-016.

Koşullar: 100 tohum × 12 ay; başlangıç parası $800.000; iş geliri ×2; kiralar $15k / 22,5k / 30k / 45k (Ridgeway / Harbor / Millbrook / Iron Valley); parka uygun teklif tabanı 12/20; yaş → Bakım sorunu olasılığı açık; hammadde kabulde düşer (6 ayı aşan işte 6 aylık dilimler); gelir tesliminde verimle orantılı. Karakterler betiklidir (sabit tezgah alım planı, kâra göre açgözlü iş kabulü, görünür sorunlara Düzelt).


| Karakter | Kiralanamadı | Ayakta | Zorunlu kapanış | İflas | Ort. son net kasa | En düşük kasa (ort.) | İlk iş ayı | İşsiz makine-ay | Ort. verim | Düzelt/ay | Gizli satırlı ay | Danışmansız deneme mümkün | Para engeli | Saat engeli |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Küçük temkinli | 0 | 100 | 0 | 0 | 179 | 34 | 2.0 | 0.3 | %91 | 1.15 | 72 | 72 | 0 | 0 |
| Orta ikinci el | 0 | 100 | 0 | 0 | -23 | -76 | 2.0 | 8.4 | %60 | 0.75 | 133 | 81 | 52 | 0 |
| Orta peşinci | 0 | 100 | 0 | 0 | 66 | -36 | 2.0 | 0.9 | %74 | 0.68 | 103 | 97 | 6 | 0 |
| Orta yeni makine | 0 | 100 | 0 | 0 | 74 | -38 | 4.0 | 0.8 | %78 | 0.47 | 0 | 0 | 0 | 0 |
| Tek makine | 0 | 100 | 0 | 0 | 256 | 157 | 2.0 | 0.0 | %89 | 1.24 | 61 | 61 | 0 | 0 |
| Büyük iddialı | 0 | 100 | 0 | 0 | -50 | -82 | 2.0 | 18.9 | %61 | 0.58 | 135 | 38 | 97 | 0 |

## Duyarlılık (aynı karakterler, 60 tohum; "ort. son net kasa" birimi $1.000)

| Ayar | Küçük temkinli | Orta ikinci el | Orta peşinci | Orta yeni makine | Tek makine | Büyük iddialı |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Para 400, gelir ×1, kira ×1 (ilk mock) | -185 | -479 | -366 (100% iflas) | -496 | -146 | -734 |
| Para 400, gelir ×3, kira ×1 | -135 | -493 | -366 (iflas) | -496 | -60 | -759 |
| Para 400, gelir ×3, kira ×0,5 | 25 | -239 | -132 | -212 | 97 | -406 |
| Para 800, gelir ×3, kira ×1 | 128 | -181 | -50 | -59 | 116 | -315 |
| Para 800, gelir ×2, kira ×0,5 (seçilen) | 159 | -12 | 31 | 76 | 285 | -43 |

## Bulgular

1. İlk mock ayarında (para 400, kira $30–90k) hiçbir karakter kârlı değildi; sebep gelirin küçüklüğünden çok kira ve peşin hammadde/makine sermayesi: gelir ×3 tek başına çözmüyor, çünkü hammadde geliri kadar büyüyüp kabulde peşin çıkıyor ve nakit ilk aylarda tükeniyor.
2. Makine teslim süresi işletme sermayesini yiyor: yeni makine seçen karakter ilk işini ay 4'te alıyor, o zamana kadar kira ve ekipman nakdi eritiyor.
3. Seçilen ayarda küçük park kârlı, orta park başabaş, büyük iddialı park zararda; büyümenin karşılığı henüz yok (işsiz makine-ay 19, tezgahlar arasında eşleşen iş az).
4. FRZ-001 v3 §6 erken erişim testi (ay 2–3'te gizli Düzelt denemesi ≥ %90) küçük parkta sağlanıyor (72/72), orta ikinci elde %61 (81/133), büyükte %28 (38/135). Engel para: orta/büyük ölçeğin gizli sorun güvencesi ($105k / $280k) kasayı aşıyor. Saat engeli 0.
5. Yaşlı park verimi düşürüyor (orta ikinci el %60, yeni makine %78): yaş → Bakım sorunu kuralı etkili. Orta yeni makine 0 gizli satırla başlıyor (makine gelene kadar sorun doğmuyor).
