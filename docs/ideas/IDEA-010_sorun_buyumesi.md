# IDEA-010 — Çözülmeyen Sorunların Büyümesi

## Durum/Tur

Durum: KARARA BAĞLANDI — [FRZ-002 v4](../freeze/FRZ-002_v4_fabrika_ekonomisi.md), kullanıcı tarafından [IDEA-012](IDEA-012_erken_donem_ve_teklif_havuzu.md) teklif çözümüyle birlikte onaylandı ve CURRENT yapıldı.
Tur: 1
Tarih: 2026-09-29
Bağımlılık: [FRZ-002 v3](../freeze/FRZ-002_v3_fabrika_ekonomisi.md) §1–2 ve [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md) §4.

## Öneri (GPT)

### Sorunun bedeli zamanla artar

Çözülmeyen her sorun satırının aylık potansiyel kaybı, oluşum ayındaki kaybına göre izlenir. Karar ayı sonunda hâlâ açık olan satır sonraki ay için %5 büyür; büyüme başlangıç kaybının iki katında durur. Oran bütün Tier'lerde aynıdır. Bağlı satırlar birlikte oluşmaya devam eder; büyüme mevcut satırları etkiler, yeni bağlı satır doğurmaz. Bir kök çözülürse bağlı bütün kayıpları sonraki raporda kalkar.

Bu öneri [IDEA-001](IDEA-001_patron_yetkinlikleri.md) içinde açık bırakılan “ertelenen sorunun büyüme hızı” sorusunu kapatmak içindir; geçerli FREEZE dosyalarını kendi başına değiştirmez.

Büyüyen **satır potansiyeli** ayrı ayrı saklanır; yaklaşık %20 tavan satırlara tek tek değil, departmanın **rapora geçen toplam gerçekleşen kaybına** uygulanır. Satır potansiyelleri tavana çarptığında, kartta potansiyel toplam ve tavan sonrası gerçekleşen departman kaybı ayrı gösterilip fark açıklanır. Fabrika genelinde en az %33 gerçekleşme tabanı da geçerlidir. Rapor FRZ-002 v3'teki çıktı eşdeğeri birimini kullanır; nakit ve rapor kaybı iki kez sayılmaz. Bütün Tier'lerde aynı büyüme oranı gizli derinliği ele vermez.

### Gerekçe ve test

[Claude patron testi](../../godot/playtests/claude_bulgular.md) derin sorunu düzeltmenin çoğu zaman ekonomik olmadığını ve gizli satırların biriktiğini gösterdi. [ChatGPT patron testi](../../godot/playtests/chatgpt_bulgular.md) eski şans kuralında kör denemenin güçlü kaldığını ve orta bilgi düzeyinin gizli sorun birikimini durdurmadığını gösterdi. Sonraki eşlenmiş testte %5 büyüme beklemenin maliyetini artırdı; danışmanın ekonomik değerindeki artışın nedeni ise **ayrı danışman ücret ayarıydı**, büyüme değil. Büyüme danışman kullanan karakterin de net kasasını 109'dan 80'e düşürdü. Sayılar prototip girdileridir.

### Danışman fiyatı ayrı denge işi

Büyüme uygulandıktan sonra tipik bir departmanın 1–2 aylık gizli zararı, danışman sözleşme fiyatı için patron testinde karşılaştırma düzeyi olsun. Bu bir fiyat FREEZE'i değildir; [FRZ-006 v2](../freeze/FRZ-006_v2_danisman_pazari.md) ücretin kesin değerini açık bırakmaya devam eder.

## Notlar (Claude)

Tur 1 incelemesi. FRZ-001, FRZ-002 v3 ve FRZ-002 v4 taslağı ile karşılaştırıldı; kural patron testinde uygulanıp ölçüldü (`godot/playtests/claude_bulgular.md`, Tur 2). Bu turda yalnızca bu bölüm değişti.

**Ölçüm yöntemi:** Aynı kod, aynı 100 tohum ve kendi makine parkları. Yalnız büyüme açılıp kapatıldı (`GROWTH_RATE` 0,05 ↔ 0). Tohum hatası düzeltildiği için sonuçlar tekrarlanabilir: aynı koşu iki kez birebir aynı özeti üretiyor.

| Karakter | Büyüme yok: iflas / net kasa | Büyüme var: iflas / net kasa |
| --- | --- | --- |
| Temkinli Patron (yalnız görünür sorunu düzeltir) | 0 / 23 | 0 / **−15** |
| Teknik Usta (diplomasız, A×2) | **42** / −212 | **54** / −224 |
| Erken Kurucu (diplomasız, A×2, 300 para) | **89** / −251 | **94** / −256 |
| Kör Tamirci | 0 / 38 | 0 / 9 |
| Danışman Arayan | 0 / 109 | 0 / 80 |

### Aldığım Notlar

- Taslak, patron testindeki uygulamayla birebir aynı: %5 artış, başlangıcın 2 katında durma, bütün Tier'lerde aynı oran, yeni bağlı satır yok, %20 ve %33 sınırları geçerli.
- **Hedef tuttu: beklemek artık bedava değil.** Yalnız görünür sorunu düzelten Temkinli Patron'un net kasası büyümeyle 23'ten −15'e düşüyor; gizli sorunu hiç denememek bir bedel taşıyor.
- Aynı oranın Tier'i sızdırmaması doğru kurulmuş.

### Bulduğum Sakıncalar

**1. Büyüme zayıf fabrikaların iflasını artırıyor; asıl sorun ise büyümeden önce de vardı (FREEZE öncesi kapanmalı).**
Teknik Usta'nın iflası 100'de 42'den 54'e, Erken Kurucu'nunki 89'dan 94'e çıkıyor. Ama Erken Kurucu büyüme olmadan da 100'de 89 batıyor. Bunun iki kök nedeni var ve ikisi de büyümeden bağımsız:
- **Teklif havuzu makinelere uymuyor.** `reports/05_erken_kurucu.md`'de 2., 5. ve 6. aylarda beklenen çıktı 20 / 0 / 20; yalnız A tezgâhı olan fabrikaya uygun iş gelmediği için gelir çöküyor.
- **Erken dönem güvencesi yalnız ilk ay var.** FRZ-002 v3 §4 kuruluş kasasını sadece açılış ayı için garanti ediyor. 4–9. aylarda her ay 1–3 Düzelt denemesi nakit güvencesine takılıyor (raporda "engel").

Büyüme bu iki soruna eklenince erken fabrika daha hızlı batıyor. **Öneri:** FRZ-002 v4, erken dönem ve teklif havuzu için açılacak ayrı bir IDEA'yla **birlikte** CURRENT yapılsın; tek başına dondurulursa erken oyunun zaten kırık olan kısmı daha da sertleşir.

**2. Danışmanın kazandığı değer büyümeden değil, ücret ayarından geliyor.**
Büyüme her rotayı yakıyor: Danışman Arayan 109 → 80, Kör Tamirci 38 → 9. Danışmanın kör denemeye üstünlüğü, esas olarak ücretin düşürülmesinden (aynı kodla eski ücrette 12'ye 9, yeni ücrette 80'e 9) ve IDEA-011'deki şans eğrisinden geliyor. Öneri metnindeki "danışman az kullanıldı → büyüme" gerekçesi bu yüzden eksik; ücret dengesinin ayrı bir karar olduğu açıkça yazılmalı.

### Kafama Yatmayanlar

- **Tavana çarpan departmanda satır değerleri (Açık Karar 2).** Testte rapor tavanı yalnız departman toplamına uygulandı; satırlar kendi büyüyen "potansiyel" kayıplarını koruyor ve Düzelt satırın potansiyelini kaldırıyor. Bu, Tier gizliliğini korur ve basittir. Öneri: kural böyle yazılsın ve arayüzde "departman tavanı uygulandı" notu görünsün.
- **Danışman sürekli kullanılıyor.** Danışman Arayan 12 ayda ortalama 4,1 sözleşme yapıyor; iki yuva neredeyse hiç boş kalmıyor. FRZ-006 v2'nin "sürekli danışman kariyerin yerini almamalı" gerekçesiyle gerilim olabilir. 24–36 aylık testte izlenmeli.
- **Danışman ücreti için testin seçtiği değer:** aylık 2 + (en yüksek iki puan)/30; 3 aylık sözleşme ≈ 15–24. Bu, taslaktaki "1–2 aylık departman zararı" hedefine denk geliyor. FREEZE değil, denge girdisi.

### Açık Sorular

1. FRZ-002 v4, erken dönem güvencesi ve teklif havuzu için açılacak yeni IDEA ile birlikte mi onaylansın (Claude önerisi), yoksa tek başına mı?
2. Tavana çarpan departmanda kural: tavan yalnız departman toplamına uygulanır, satırlar potansiyel kaybını korur. Kabul mü?
3. Danışman ücreti için test değeri (2 + en iyi iki puan/30) denge girdisi olarak kayda geçsin mi?

## Açık Kararlar

- %5 ve iki kat sınırının uzun oyunlarda nakit/iflas döngüsüne etkisi oynanarak sınanacak; değişmesi gerekirse yeni IDEA turu açılacak.
- Birden çok satır departman tavanına çarptığında satır potansiyelleri korunacak; tavan yalnız gerçekleşen departman toplamına uygulanacak ve fark raporda açıklanacak.
- FRZ-002 v4, [IDEA-012 erken dönem ve teklif havuzu](IDEA-012_erken_donem_ve_teklif_havuzu.md) çözümüyle birlikte CURRENT yapılacak; tek başına dondurulmayacak.
- Danışman fiyatının 1–2 aylık kayıp düzeyine göre kesin tutarı denge konusudur; FRZ-006 v2'yi bu IDEA değiştirmez.

## Karar Özeti

- Kullanıcı çözülmeyen satırın aylık zararını her ay %5 büyütüp başlangıcın iki katında durdurmayı taslak yönü olarak onayladı; çünkü derin sorunları süresiz ertelemek bedelsiz kalmamalı.
- Kullanıcı aynı büyüme oranını bütün Tier'lere uygulamayı ve mevcut %20 departman ile %33 gerçekleşme sınırlarını korumayı onayladı; çünkü gizli Tier kayıp hızından anlaşılmamalı ve işletme kaybı sınırsızlaşmamalı.
- Kullanıcı büyümenin yeni bağlı satır yaratmamasını onayladı; çünkü FRZ-001'in bütün bağlı satırların aynı olayda doğması kuralı korunmalı.
- Kullanıcı danışman fiyatını büyümeden sonra tipik 1–2 aylık gizli zararla test etmeyi, fiyatı henüz FREEZE etmemeyi seçti; çünkü ekonomideki yeni kayıp hızı görülmeden kesin ücret dengelenemez.
- Kullanıcı büyümeyi erken dönem teklif ve kasa erişimiyle birlikte karara bağlamayı onayladı; çünkü büyüme zayıf fabrikaların mevcut iflas baskısını artırıyor.
- Kullanıcı tavanın satır potansiyeline değil, gerçekleşen departman toplamına uygulanmasını onayladı; çünkü satırın zamanla büyüyen riski kaybolmadan rapor sınırı korunmalı.
