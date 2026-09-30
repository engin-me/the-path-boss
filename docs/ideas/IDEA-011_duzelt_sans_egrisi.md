# IDEA-011 — Düzelt Şans Eğrisi

## Durum/Tur

Durum: KARARA BAĞLANDI — kullanıcı Claude Tur 1 incelemesi ve düzeltilmiş test kanıtıyla [FRZ-001 v2](../freeze/FRZ-001_v2_patron_yetkinlikleri.md) sürümünü onayladı.
Tur: 1
Tarih: 2026-09-29
Bağımlılık: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md) §2–4 ve [IDEA-009](IDEA-009_kariyer_egitim_ve_yetkinlik_yollari.md).

## Öneri (GPT)

Etkin yetkinlik ilgili kökün Tier eşiğine (T1=30, T2=50, T3=70, T4=90, T5=100) ulaşırsa Düzelt kesindir. Altındaysa yüzde şans `max(5, 100 − 4 × (eşik − etkin yetkinlik))` olur. 89 → T4 %96, 70 → T4 %20 ve 50 → T3 %20 örnekleridir. Etkin yetkinlik FRZ-001'deki `max(patron, aktif danışmanlar)` ile bulunur; statlar şansı doğrudan değiştirmez. Prototipin yaklaşık %80/%40/%15/%5 kademe kuralı kaldırılır.

Görünürlük yapısı değişmez: oyuncunun erişemediği dolu satır ayrı adsız satır kalır. Birden fazla gizli Tier mümkünse şans etiketi **Belirsiz**; tek olası gizli Tier varsa çıkarılabilen şans etiketi gösterilir. Görünür satırda etiketler **Kesin** (%100), **Yüksek** (≥%80 ve <%100), **Orta** (%40–79), **Düşük** (<%40; taban %5) olur. Bağlı kökün en derin Tier'i şans hesabında kullanılmaya devam eder.

Sürekli eğri her puanı anlamlı kılar. Tohum hatası giderildikten sonra aynı kod ve aynı 100 tohumla, yalnız şans kuralı değiştirilerek yapılan karşılaştırmada Kör Tamirci'nin başarı oranı **%78'den %48'e**, ortalama son net kasası **159'dan 9'a** düştü. Önceki %80 → %58 ve 191 → 106 sayıları tekrarlanamayan koşudan geliyordu ve kanıt olarak kullanılmaz. Bu gözlem kör deneme baskısının yönünü gösterir, kesin ekonomi dengesi sonucu değildir. Diploma tavanının Tier başına inmesi [FRZ-007 v3](../freeze/FRZ-007_v3_calisanlik_kariyeri.md) ile birlikte değerlendirilir.

## Notlar (Claude)

Tur 1 incelemesi. FRZ-001 ve FRZ-001 v2 taslağı ile karşılaştırıldı; kural patron testinde uygulanıp ölçüldü. Bu turda yalnızca bu bölüm değişti.

**Ölçüm yöntemi:** Aynı kod, aynı 100 tohum, kendi makine parkları. Yalnız şans kuralı değiştirildi (eski %80/%40/%15/%5 kademe ↔ yeni puan başına −%4, en az %5).

| Karakter | Eski kural: başarı / net kasa | Yeni kural: başarı / net kasa |
| --- | --- | --- |
| Kör Tamirci (gizli satırları da dener) | %78 / 159 | **%48 / 9** |
| Finansçı Kumarbaz (kör dener) | %82 / 722 | %53 / 587 |
| Yalnız görünür sorunu düzeltenler | değişmedi | değişmedi |
| İflas sayıları | değişmedi | değişmedi |

### Aldığım Notlar

- Taslak, patron testindeki uygulamayla birebir aynı: `max(5, 100 − 4 × (eşik − etkin yetkinlik))`, etiketler Kesin / Yüksek ≥%80 / Orta %40–79 / Düşük <%40.
- **Hedef tuttu.** Kör denemenin aşırı ödülü kalktı; eğri yalnız eşik altında deneme yapan oyuncuyu etkiliyor, iflas sayılarını değiştirmiyor.
- Görünürlük, bağlı kök ve statların şansa etkisizliği değişmeden korunmuş. Kural FRZ-001'in "bilgi açığı imkânsız değil, riskli" ilkesiyle uyumlu, çünkü şans hiç sıfır olmuyor.

### Bulduğum Sakıncalar

**1. Öneri metnindeki kanıt sayısı eski ve tekrarlanamaz (düzeltilmeli).**
"Kör Tamirci %80 → %58, 191 → 106" sayıları, tohum hatası düzeltilmeden önceki 40 tohumlu bir koşudan geliyor. O sürümde danışman adayları tohumdan bağımsız karıştırılıyordu ve aynı tohum farklı sonuç verebiliyordu. Tekrarlanabilir, 100 tohumlu değerler yukarıdaki tabloda: **%78 → %48 ve 159 → 9** (yalnız şans kuralının etkisi). Açık Karar 2'deki "tekrarlanabilirlik doğrulanacak" maddesi bu düzeltmeyle kapandı.

### Kafama Yatmayanlar

- **Etiket dağılımı:** "Yüksek" etiketi yalnız eşiğin en fazla 5 puan altında görünüyor (≥%80). Bir Tier aşağıdan bakan patron (20 puan fark) her zaman "Düşük" görüyor. Bu kasıtlıysa sorun yok. Ama oyuncu görünür satırların çoğunda yalnız "Kesin" ya da "Düşük" görecek; "Orta" ancak 6–15 puan farkta çıkıyor. Arayüz testinde etiketlerin yeterince bilgi verip vermediği gözlenmeli.
- **Erken dönem:** Tier başındaki patron bir üst Tier sorununa %20 ile giriyor (eski kuralda %80). Erken Kurucu'nun iflası bu kuralla değişmedi (100'de 94, ikisinde de). Ama erken dönemde gizli sorunları denemek artık daha az cazip. IDEA-010'daki erken dönem sorunu çözülünce yeniden ölçülmeli.

### Açık Sorular

1. Öneri metnindeki kanıt sayıları tekrarlanabilir değerlerle (%78 → %48, 159 → 9) güncellensin mi?
2. Etiket eşikleri (Yüksek ≥%80) bu haliyle mi kalsın?

**FREEZE durumu:** 1. madde düzeltilirse FRZ-001 v2 onaya hazır.

## Açık Kararlar

- Yeni eğri ve diploma tavanı onaylandı; sorun büyümesiyle birleştiğinde erken fabrikanın danışmansız gizli deneme imkânı [IDEA-012](IDEA-012_erken_donem_ve_teklif_havuzu.md) kapsamında sınanacak.
- “Yüksek” etiketinin eşikten en fazla beş puan aşağıda görülmesinin arayüzde yeterince bilgilendirici olup olmadığı oynanarak değerlendirilecek; bu, formülün onayını bekletmez.

## Karar Özeti

- Kullanıcı kademe şansı yerine eşik altı her puan farkı için yüzde dört düşen, en az %5 şans bırakan eğriyi FRZ-001 v2 kararı olarak onayladı; çünkü her yetkinlik puanı anlamlı olmalı ve kör deneme aşırı ödüllendirilmemeli.
- Kullanıcı tekrarlanabilir 100 tohumlu %78 → %48 başarı ve 159 → 9 net kasa karşılaştırmasını önceki hatalı sayıların yerine kabul etti; çünkü şans kuralının etkisi aynı koşullarda ölçülmeli.
- Kullanıcı eşik ve üstünde kesin çözümü, statların şansa etkisizliğini ve mevcut görünürlük kurallarını korumayı onayladı; çünkü bilgi ve danışman desteği kesin çözümün kaynağı kalmalı, gizli Tier etiketle sızmamalı.
- Kullanıcı görünür olasılık etiketlerini Kesin/Yüksek/Orta/Düşük olarak belirledi; çünkü oyuncu yüzdeyi görmeden müdahalenin risk düzeyini anlayabilmeli.
