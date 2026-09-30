# Fabrika kabuğu simülasyonu — Faz 1 (yük bazlı kapasite, vardiya, OEE, FIFO)

Test girdisidir; denge kararı değildir. Motor: `godot/scripts/shell/shell_boss.gd`, koşucu: `godot/tests/shell_sim.gd`. Kurallar: IDEA-015..018 önerileridir.

Koşullar: 100 tohum × 12 ay; başlangıç parası $800k; `price_per_x` 0,13; kiralar $15k–45k; teorik kapasite Torna 2000x / Freze 1600x / Taşlama 1200x / Dövme 800x; performans %70/80/90; hurda %2–9; OEE = vardiya/3 × performans × (1 − hurda) × sorun çarpanı. Karakterler betiklidir: sabit tezgah planı, kapasiteye göre iş kabulü (vaat edilen yük, teslim tarihine kadar kapasitenin %85'ini aşmaz), "vardiyacı" karakterler birikim yüksekse vardiya açar.


| Karakter | Kiralanamadı | Ayakta | Zorunlu kapanış | İflas | Ort. son net kasa | En düşük kasa (ort.) | İlk iş ayı | OEE (24 sa, ort.) | Kapasite kullanımı | Ort. vardiya | Geç teslim / teslim | Bırakılan-iptal | Son skor | Gizli satırlı ay | Danışmansız deneme mümkün | Para engeli |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Tek makine | 0 | 98 | 0 | 2 | 178 | 55 | 1.1 | %24 | %95 | 1.0 | 77 / 300 | 0 | %83 | 63 | 63 | 0 |
| Küçük temkinli | 0 | 85 | 0 | 15 | -66 | -167 | 1.0 | %22 | %67 | 1.0 | 132 / 262 | 32 | %71 | 73 | 48 | 25 |
| Küçük vardiyacı | 0 | 96 | 0 | 4 | 165 | -111 | 1.0 | %45 | %80 | 2.0 | 68 / 648 | 4 | %88 | 79 | 25 | 54 |
| Orta ikinci el | 0 | 99 | 0 | 1 | -104 | -227 | 1.0 | %24 | %56 | 1.3 | 161 / 368 | 28 | %72 | 139 | 4 | 135 |
| Orta yeni makine | 0 | 90 | 0 | 10 | -27 | -155 | 1.0 | %28 | %66 | 1.3 | 172 / 381 | 30 | %73 | 42 | 0 | 42 |
| Büyük iddialı | 0 | 98 | 0 | 2 | -199 | -294 | 1.0 | %21 | %45 | 1.1 | 133 / 298 | 36 | %71 | 140 | 0 | 140 |


## Bulgular

1. Vardiya kararı gerçek bir kaldıraç: aynı parkla (Ridgeway + 2 ikinci el tezgah) "temkinli" (tek vardiya, OEE ≈ %22) zararda, "vardiyacı" (ortalama 2 vardiya, OEE ≈ %46) kârlı.
2. Tek makine patron vardiyasıyla kârlı ama tavanı düşük (OEE ≈ %24, kullanım %95); büyümek vardiya ve personel ister.
3. Orta ve büyük parklar hâlâ zararda: kapasite kullanımı %45–60. İş talebi parkın tür ve seviye dağılımına göre yetersiz; kira, ekipman ve personel sabit. Pazar büyüklüğü (teklif boyutu ve sayısı) parka göre ölçeklenmeli ya da maliyetler düşmeli (denge).
4. Geç teslim oranı yüksek (yaklaşık %25–45): teslim süreleri dar. Skor bu yüzden %70–90 arasında.
5. Gizli Düzelt erişimi (FRZ-001 v3 erken test) orta/büyük parkta para engelli; Faz 2'deki peşinat işletme sermayesini rahatlatacak.
