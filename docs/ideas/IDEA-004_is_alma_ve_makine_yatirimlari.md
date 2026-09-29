# IDEA-004 — İş Alma ve Makine Yatırımları

## Durum/Tur

Durum: DRAFT — Claude incelemesi bekleniyor; bu dosya FREEZE değildir.
Tur: 1
Date: 2026-09-29
Bağımlılıklar: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md), [FRZ-002 v2](../freeze/FRZ-002_v2_fabrika_ekonomisi.md), [FRZ-003](../freeze/FRZ-003_iflas_ve_fabrika_satisi.md).

## Öneri (GPT)

**İş Alma.** Oyuncu ay sonunda sınırlı sayıda iş/ihale teklifi görür. Her teklifte gereken makine niteliği, iş miktarı, teslim süresi, beklenen gelir, tahmini maliyet ve kapasite kullanımı açık olur. Oyuncu hangi işlere gireceğini seçer; kabul edilen işler makine kapasitesini ve teslim zamanını bağlar. İlk sürümde sabit koşullu teklif seçimi yeterli olabilir; teklif fiyatı pazarlığı daha sonra değerlendirilebilir.

**Makine yatırımı.** Makine markası/modeli yalnızca ad değildir: aylık kapasiteyi, uygun olunabilen işleri ve birim maliyeti etkiler. Örnek A/B/C torna tezgâhının 10/15/17 birim üretmesi yalnızca tasarım örneğidir. Daha nitelikli tezgâh, belli şartları olan niş işlere erişim sağlayabilir; yüksek alış fiyatı, sonraki kâr fırsatı ve yeniden satış değeriyle birlikte değerlendirilir. Teklif ekranı oyuncunun mevcut makinelerle işi yapıp yapamayacağını ve kabulden sonra boş kapasiteyi gösterir.

**Azami kazanç ve iflas bağlantısı.** FRZ-003'teki azami aylık brüt kâr, oyuncunun **mevcut makine parkıyla teknik olarak alabileceği işlerden**, kapasite sınırı içinde ulaşılabilir en iyi aylık iş bileşimidir. Oyuncunun o ay gerçekten kabul ettiği iş veya son ayın gerçekleşen kârı değildir. Hesap, piyasada alınabilir tekliflerin yakın dönem ortalamasını kullanır ve ay sonunda güncellenir; sınırsız hayalî sipariş varsayılmaz. Yeni fabrikada geçmiş ay yoksa başlangıç iş havuzu kullanılır. Kesin havuz ve süre değerleri denge konusudur.

**Yatırım değeri ve çıkış.** Yatırım ekranı her makinenin alış bedelini, güncel referans değerini, bu ay normal satış tutarını ve zorunlu tasfiye tutarını ayrı gösterir. FRZ-003'teki `yatırım değeri`, mevcut satılabilir varlıkların **güncel referans değerleri toplamıdır**; alınmış ama artık elde olmayan makineler sayılmaz. Normal %70 / zorunlu %50 çarpanları aynı referansa uygulanır. Satış önizlemesi kapasite, alınabilir işler, azami net katkı ve iflas eşiğindeki değişimi birlikte gösterir.

## Notlar (Claude)

Tur 1 incelemesi, kısa. Yalnızca **kritik çelişkiler** ve **en fazla üç açık karar** yazıldı. FRZ-001, FRZ-002 v2 ve FRZ-003 bağlayıcı kabul edildi. Bu turda yalnızca `Notlar (Claude)` değişti.

### Aldığım Notlar

- Azami brüt kârın "mevcut makinelerle teknik olarak alınabilir işlerin kapasite içindeki en iyi bileşimi ve yakın dönem ortalaması" olarak tanımlanması FRZ-003 §1 ile tutarlı. Yatırım değerinin elde olan varlıkların güncel referansı olması da tutarlı.

### Bulduğum Sakıncalar

**1. "Beklenen çıktı" tanımsız kalırsa boş kapasite kayıp gibi görünür (kritik; FRZ-002 v2 §1 ile çelişki).**
FRZ-002 v2'ye göre raporda her kayıp birimi bir sorun satırına aittir. Beklenen çıktı makine potansiyeli olarak alınırsa, oyuncunun iş almadığı kapasite de raporda "kayıp" görünür. Oysa bu kaybın ait olduğu bir sorun satırı yoktur. Öneri: **beklenen çıktı = bu ay kabul edilmiş işlerin, kapasite içindeki üretim hedefi.** Kullanılmayan kapasite kayıp değil, raporda ayrı bir satırda **"boş kapasite"** olarak gösterilsin. %33 taban ve yaklaşık %20 departman tavanı da bu hedefe uygulanır.

**2. Gizli sorun kaybı teslim taahhüdüyle çakışıyor; gecikme cezası aynı kaybı iki kez yazar (kritik; FRZ-002 v2 §1 ile çelişki).**
Kabul edilen iş, kapasiteyi ve teslim tarihini bağlıyor. Sorun satırları ise gerçekleşen çıktıyı düşürüyor; gizli satırların kaybı oyuncunun göremediği bir nedenden geliyor. Teslim kaçınca ayrıca ceza kesilirse, aynı kayıp hem sorun satırında hem cezada sayılır. Öneri:
- **İlk sürümde ayrı gecikme cezası olmasın.** Kaybın etkisi yalnızca gerçekleşmeyen satış gelirinde görünsün.
- Ceza istenirse, cezanın çıktı eşdeğeri **aynı sorun satırının kaybına dahil** edilsin.
- Teklif ekranındaki boş kapasite, **son raporda görülen toplam kayıp düşülerek** gösterilsin. Oyuncu bilinen kayıplarla kendini fazla yüklemesin.

**3. İş maliyetleri FRZ-002 v2'nin kullanılabilir nakit kuralında yok (kritik).**
Kabul edilen işin "tahmini maliyeti" (malzeme vb.) ay içinde ödeniyorsa, FRZ-002 v2'deki güvence hesabı bunu bilmiyor. Oyuncu işi kabul eder, aynı ay güvenceden geçen Düzelt'lere de para harcar, ay sonunda kasa eksiye düşer. Güvencenin amacı delinir. Öneri:
- İş kabulü akıştaki **karar adımında** yapılsın.
- Kabul edilen işlerin bu ay ödenecek bilinen maliyetleri, kullanılabilir nakitten **"bilinen gider"** olarak düşülsün.
- Gelir, iş teslim edildiği ayın satışında yazılsın.

### Kafama Yatmayanlar

- Kapsam gereği bu turda ayrıca not yazılmadı.

### Açık Sorular

`Açık Kararlar` 1–3 için öneriler:

1. **Sabit koşullu teklif:** İlk sürüm için yeterli; pazarlık ertelensin. Katılıyorum.
2. **Birden çok iş:** Kapasite toplamını aşmamak koşuluyla **birden çok tam iş** alınabilsin. Tek bir işi parçalı almak olmasın.
   - Tek iş akışı makine çeşitliliğini anlamsızlaştırır.
   - Azami kâr zaten "en iyi iş bileşimi" olarak tanımlı; tek iş kuralı bu tanımla çelişir.
3. **Havuz ve referans değeri:**
   - Referans değer, alış bedelinden başlayıp zamanla düşen **güncel piyasa değeri** olsun. %70 çarpanıyla birlikte al-sat hiçbir zaman kâr etmez.
   - Potansiyel, son birkaç ayın teklif havuzunun ortalaması olsun ve ay sonunda güncellensin.
   - **Yeni alınan makinenin potansiyele katkısı, ilk tam faaliyet ayından sonra** sayılsın. Aksi halde krizdeki oyuncu kredili makine alımıyla FRZ-003 eşiğini anında yükseltip zorunlu kapanıştan kaçabilir.

## Açık Kararlar

1. İlk sürümde sabit koşullu iş seçimi yeterli mi; fiyat pazarlığı ne zaman gerekli olur?
2. Kısmi kapasiteyle birden çok iş alınabilir mi, yoksa önce tek iş akışıyla mı başlanmalı?
3. Azami kâr için “alınabilir teklif” havuzu ve yatırım referans değeri nasıl hesaplanmalı ki piyasa şoku iflası rastgele tetiklemesin ve makine al-sat istismarı oluşmasın?

## Karar Özeti

- Bu turda yeni nihai karar yoktur. Önceki kullanıcı yönlendirmesi: farklı makineler kapasiteyi, kârlılığı ve erişilen ihaleleri etkilesin; çünkü yatırım seçimi hem fabrika işlerini hem sonraki büyüme yolunu değiştirmelidir. Kesin kural ancak kullanıcı onayıyla FREEZE olur.
