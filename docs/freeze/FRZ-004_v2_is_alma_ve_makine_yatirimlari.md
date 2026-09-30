# FRZ-004 v2 — İş Alma ve Makine Yatırımları

Status: CURRENT — [FRZ-004](FRZ-004_is_alma_ve_makine_yatirimlari.md) sürümünü supersede eder.
Date: 2026-09-30
Source: [IDEA-004](../ideas/IDEA-004_is_alma_ve_makine_yatirimlari.md) ve Claude incelemesi sonrası [IDEA-012](../ideas/IDEA-012_erken_donem_ve_teklif_havuzu.md); kullanıcının aylık teklif havuzu kararı.
Depends on: [FRZ-001 v3](FRZ-001_v3_patron_yetkinlikleri.md), [FRZ-002 v4](FRZ-002_v4_fabrika_ekonomisi.md), [FRZ-003 v2](FRZ-003_v2_iflas_ve_fabrika_satisi.md).

## Onaylanan Kararlar

### 1. Teklif ve iş seçimi

**Ne:** Oyuncu ay sonunda sınırlı sayıda iş/ihale teklifi görür. Teklifte gereken makine niteliği, iş miktarı, teslim süresi, beklenen gelir, tahmini maliyet ve kapasite kullanımı gösterilir. İlk sürümde teklifler **sabit koşulludur**; fiyat pazarlığı yoktur. Kapasite toplamı izin verdikçe **birden çok tam iş** kabul edilir; bir iş parçalı kabul edilmez. Kabul edilen işler kapasiteyi ve teslim zamanını bağlar.

**Neden:** İş seçimi makine yatırımlarını anlamlı kılmalı, fakat ilk akış pazarlık ve parça parça iş bölme yüküyle ağırlaşmamalıdır.

### 1A. Her ay makine parkına uygun teklif tabanı

**Ne:** Çalışabilir makine kapasitesi olan her ayın beş teklifinden en az üçü, mevcut parkın karşılayabildiği makine niteliğinde ve tek başına tamamlayabileceği miktarda **tam iş** olmalıdır. Diğer iki teklif serbest çekilir. Uygunluk teklifin kârlı olduğunu, birlikte seçilen bütün uygun işlerin aynı anda yapılabileceğini veya oyuncunun maliyeti ödeyebileceğini garanti etmez. Çalışabilir makine yoksa uygun iş garantisi uygulanmaz; teslim/kurulumu bitmeyen makine gelir veya kapasite yaratmaz. Teklif fiyatı ve miktarı uygun aralık içinde değişken kalır. Oluşan gerçek teklif listesi mevcut teklif geçmişine girer; azami kâr potansiyeli [FRZ-003 v2](FRZ-003_v2_iflas_ve_fabrika_satisi.md) uyarınca yalnız ay sonunda güncellenir.

**Neden:** Yalnız düşük nitelikli parkın aylarca sıfır alınabilir işle karşılaşması, yatırım ve nakit kararından bağımsız yapısal iflas yaratıyordu. Her ay 3/5 tabanıyla 100 tohumluk prototipte Erken Kurucu'nun ayakta kalması 6'dan 87'ye yükseldi; 2/5 tabanında 70'ti. Kalan serbest teklifler, fiyat değişimi ve kapasite sınırı pazar riskini korur.

### 2. Rapor, kapasite ve teslim

**Ne:** FRZ-002 v4 uyarınca beklenen çıktı, o ay kabul edilmiş işlerin kapasite içindeki hedefidir. Kullanılmayan kapasite raporda ayrı **boş kapasite** olarak görünür ve departman sorun kaybına eklenmez. %33 gerçekleşme tabanı ve yaklaşık %20 departman kayıp tavanı kabul edilmiş iş hedefine uygulanır. Teklif ekranı son rapordaki toplam kaybı ihtiyat payı olarak düşen bir boş kapasite tahmini sunar; raporun ortak kayıp birimi fiziksel makine kapasitesiyle bire bir eşit sayılmaz.

**Ne:** İlk sürümde ayrı teslim gecikmesi cezası yoktur. Teslim edilmeyen iş gelir yazılmaz; sorundan doğan kayıp ilgili tek rapor satırında kalır. Gelecekte ceza eklenirse aynı kayıp ikinci kez yazılmaz, cezanın çıktı eşdeğeri ilgili sorun satırına bağlanır.

**Neden:** İşsiz duran makine arıza gibi görünmemeli; gizli sorun nedeniyle kaçan teslim hem satış kaybı hem bağımsız ikinci ceza olarak sayılmamalıdır. Kapasite tahmini oyuncuyu gözlenen kayıplar varken aşırı iş almaktan korumalıdır.

### 3. İşin nakit zamanı

**Ne:** İş kabulü ayın karar adımında yapılır. Kabul edilen işin bu ay ödenecek bilinen malzeme ve benzeri maliyetleri FRZ-002 v4'ün kullanılabilir kasa hesabında ayrılır; olağan giderlere zaten dahil edilmiş tutar tekrar ayrılmaz. Gelir yalnızca iş teslim edildiği ayın fiili satışına girer; teklif veya kabul tek başına gelir yaratmaz.

**Neden:** Düzelt güvencesi bilinen iş maliyetini harcamamalı ve henüz teslim edilmemiş işin parasıyla müdahale yapılmamalıdır.

### 4. Makine farkları ve yatırım değeri

**Ne:** Makine markası/modeli kapasiteyi, birim maliyeti ve uygun olunabilen işleri etkiler; bazı işler belirli makine niteliği ister. A/B/C tezgâhının 10/15/17 birimlik örneği bağlayıcı denge değeri değildir. İş teklifinde uygunluk ve kabul sonrası ihtiyatlı boş kapasite gösterilir. Yatırım ekranında alış bedeli, güncel piyasa referans değeri, bu ayki gönüllü satış ve zorunlu tasfiye değerleri ayrı görünür. Referans değer alış bedelinden başlar, zamanla azalır ve yalnızca eldeki satılabilir varlıklar toplamına katılır. FRZ-003 v2'nin %70 gönüllü ve %50 zorunlu satış bedeli bu referans değere uygulanır.

**Neden:** İyi makine niş ve kârlı işe erişim sağlamalı; alış bedeliyle bugünkü satış değeri birbirine karıştırılmamalı ve al-sat kârı oluşmamalıdır.

### 5. Azami brüt kâr potansiyeli

**Ne:** FRZ-003 v2'nin azami aylık brüt kârı, mevcut uygun makineler ve alınabilir teklif havuzuyla kapasite sınırı içinde yapılabilecek en iyi **tam iş bileşiminden** türetilir; kabul edilmiş işlerin veya son ayın gerçekleşen kârı değildir. Son birkaç ayın teklif havuzu ortalaması kullanılır ve hesap yalnızca ay sonunda güncellenir. Yeni fabrikada başlangıç teklif havuzu vardır. Yeni alınan makinenin kâr potansiyeline katkısı ilk **tam faaliyet ayı tamamlandıktan sonra** hesaba girer.

**Neden:** Gerçek talep ve makine niteliği iflas hesabına yansırken tek aylık piyasa şoku veya kredili makine alımı eşiği anında ve yapay biçimde değiştirmemelidir.

## Reddedilen yollar

- Teorik makine kapasitesini doğrudan raporun beklenen çıktısı saymak; iş alınmamış kapasiteyi kaynağı olmayan sorun kaybı yapar.
- İlk sürümde gecikme cezasını ayrıca yazmak; kaybı iki kere sayabilir.
- Tek seferde sadece bir iş veya parçalı iş kabulüyle başlamak; ilki makine çeşitliliğini daraltır, ikincisi ilk akışı gereksiz karmaşıklaştırır.
- Yeni makinenin iflas hesabındaki azami kâra satın alındığı gün katkı vermesi; krediyle eşik istismarı doğurur.

## Ertelenen denge

- Teklif sayısı, havuz ortalamasının kesin ay sayısı, başlangıç havuzu, referans değerin aylık düşüşü ve makine fiyat/kapasite dengesi oyun testinde belirlenir.
- Toplam rapor kaybının boş kapasite tahminine uygulanacak ihtiyat payı ayarlanır; çıktı eşdeğeri fiziksel saat değildir.
- Fiyat pazarlığı ve ayrı teslim cezası ilk sürümün dışındadır; eklenirse yeni IDEA/REVIEW kararı gerekir.
