# IDEA-004 — İş Alma ve Makine Yatırımları

## Durum/Tur

Durum: Tur 2 sentezi; Claude'un üç önerisi kullanıcı tarafından kabul edildi. Bu dosya FREEZE değildir.
Tur: 2
Date: 2026-09-29
Bağımlılıklar: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md), [FRZ-002 v2](../freeze/FRZ-002_v2_fabrika_ekonomisi.md), [FRZ-003](../freeze/FRZ-003_iflas_ve_fabrika_satisi.md).

## Öneri (GPT)

**İş Alma.** Oyuncu ay sonunda sınırlı sayıda iş/ihale teklifi görür. Her teklifte gereken makine niteliği, iş miktarı, teslim süresi, beklenen gelir, tahmini maliyet ve kapasite kullanımı açık olur. İlk sürümde **sabit koşullu teklifler** seçilir; fiyat pazarlığı ertelenir. Toplam kapasiteyi aşmamak koşuluyla **birden çok tam iş** alınabilir; tek bir iş parçalı kabul edilmez. Kabul edilen işler makine kapasitesini ve teslim zamanını bağlar.

**Rapor hedefi ve boş kapasite.** FRZ-002 v2'nin raporundaki **beklenen çıktı**, makinelerin teorik üretimi değil, o ay kabul edilmiş işlerin kapasite içinde kalan üretim hedefidir. Kullanılmayan makine kapasitesi ayrı bir **“boş kapasite”** satırıdır ve sorun kaybına katılmaz. FRZ-002 v2'nin %33 gerçekleşme tabanı ve yaklaşık %20 departman kayıp tavanı kabul edilmiş iş hedefi üzerinden değerlendirilir. Teklif ekranı, son raporda görülen toplam kaybı güvenlik tamponu olarak düşerek oyuncuya ihtiyatlı boş kapasite tahmini gösterir; bu tampon fiziksel kapasite kaybıyla bire bir aynı şey değildir.

**Teslim ve kasa.** İlk sürümde ayrıca gecikme cezası kesilmez: teslim edilemeyen miktarın etkisi gerçekleşmeyen ürün satış geliridir; sorun kaybı raporda yeniden ikinci bir satıra yazılmaz. Gelecekte ceza eklenirse çıktı eşdeğeri ilgili sorun satırının kaybına dahil edilir. İş kabulü FRZ-002 v2'nin **karar adımında** olur. Kabul edilen işlerin bu ay ödenecek bilinen malzeme ve benzeri maliyetleri, Düzelt güvencesindeki kullanılabilir nakitten düşülür. Gelir yalnızca işin teslim edildiği ayın fiili satışında kasaya girer.

**Makine yatırımı.** Makine markası/modeli yalnızca ad değildir: aylık kapasiteyi, uygun olunabilen işleri ve birim maliyeti etkiler. Örnek A/B/C torna tezgâhının 10/15/17 birim üretmesi yalnızca tasarım örneğidir. Daha nitelikli tezgâh, belli şartları olan niş işlere erişim sağlayabilir; yüksek alış fiyatı, sonraki kâr fırsatı ve yeniden satış değeriyle birlikte değerlendirilir. Teklif ekranı oyuncunun mevcut makinelerle işi yapıp yapamayacağını ve kabulden sonra boş kapasiteyi gösterir.

**Azami kazanç ve iflas bağlantısı.** FRZ-003'teki azami aylık brüt kâr, oyuncunun uygun makinelerle teknik olarak alabileceği işlerin, kapasite sınırı içindeki en iyi aylık bileşimidir; fiilen kabul edilen işler veya son ayın kârı değildir. Yakın dönemin **birkaç aylık teklif havuzu ortalaması** kullanılır ve yalnızca ay sonunda güncellenir. Yeni fabrikada geçmiş ay yoksa başlangıç iş havuzu kullanılır. **Yeni alınan makinenin azami kâr potansiyeline katkısı ilk tam faaliyet ayı tamamlandıktan sonra** sayılır; kredili makine alımı iflas eşiğini aynı gün yapay biçimde yükseltmez.

**Yatırım değeri ve çıkış.** Yatırım ekranı her makinenin alış bedelini, güncel referans değerini, bu ay normal satış tutarını ve zorunlu tasfiye tutarını ayrı gösterir. FRZ-003'teki `yatırım değeri`, eldeki satılabilir varlıkların **güncel piyasa referans değerleri toplamıdır**; alınmış ama artık elde olmayan makineler sayılmaz. Referans değer alış bedelinden başlar ve zamanla düşer. FRZ-003'teki normal %70 / zorunlu %50 çarpanları aynı referansa uygulanır; makine alıp hemen satmak kâr sağlamaz. Satış önizlemesi kapasite, alınabilir işler, azami net katkı ve iflas eşiğindeki değişimi birlikte gösterir.

**FREEZE etkisi.** Beklenen çıktı tanımı ve iş maliyeti güvencesi FRZ-002 v2'yi, yeni makinenin azami kâra ne zaman dahil olacağı ve yatırım referansı FRZ-003'ü ayrıntılandırır. Onaylanan tasarım FREEZE'e geçirildiğinde bu iki dosyanın yeni sürümleri hazırlanmalı, eski sürümler SUPERSEDED işaretlenmelidir; bu IDEA dosyası yürürlükteki kararları tek başına değiştirmez.

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

1. Teklif havuzunun “birkaç ay” aralığı, başlangıç havuzu ve piyasa düşüşünün hızı sayısal dengede belirlenecektir.
2. Makinenin piyasa referans değerinin aylık düşüş eğrisi ve farklı makine niteliklerinin fiyat/kapasite dengesi açık kalır.
3. Son rapordaki toplam kaybın boş kapasite tahminine uygulanacak güvenlik tamponu oyun testinde ayarlanmalıdır; parasal kayıp fiziksel kapasiteyle bire bir aynı değildir.

## Karar Özeti

- İlk sürümde sabit koşullu teklif ve kapasite izin verdikçe birden çok tam iş seçilir; çünkü makine çeşitliliği işe yararken iş parçalama ve pazarlık ilk akışı ağırlaştırmamalıdır.
- Beklenen çıktı kabul edilmiş iş hedefine bağlanır, boş kapasite ayrı gösterilir; çünkü satılmamış üretim gücü FRZ-002 v2'deki sorun kaybı gibi görünmemelidir.
- İlk sürümde ayrı gecikme cezası olmaz; çünkü teslim edilmeyen işin kaybı gerçekleşmeyen satış geliriyle zaten görünür ve çift sayım önlenmelidir.
- İşin bu ay bilinen maliyeti kullanılabilir nakitten ayrılır, gelir teslim ayına yazılır; çünkü FRZ-002 v2'nin müdahale güvencesi ve gerçek nakit sırası korunmalıdır.
- Yatırım referansı alış bedelinden başlayıp zamanla düşen güncel piyasa değeridir; çünkü %70 satışla makine al-sat kârı doğmamalıdır.
- Azami kâr birkaç aylık alınabilir teklif havuzuyla ay sonunda güncellenir, yeni makine ilk tam faaliyet ayından sonra katkı verir; çünkü piyasa şoku ve kredili yatırım iflas eşiğini anında oynatmamalıdır.
