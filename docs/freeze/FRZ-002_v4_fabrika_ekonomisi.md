# FRZ-002 v4 — Fabrika Ekonomisi, İş Hedefi ve Kasa Olayları

Status: DRAFT — önerilen yeni sürüm; [FRZ-002 v3](FRZ-002_v3_fabrika_ekonomisi.md) CURRENT kalır.
Date: 2026-09-29
Source: [FRZ-002 v3](FRZ-002_v3_fabrika_ekonomisi.md) ve [IDEA-010 çözülmeyen sorunların büyümesi](../ideas/IDEA-010_sorun_buyumesi.md).
Depends on: [FRZ-001 v2](FRZ-001_v2_patron_yetkinlikleri.md). Companion decisions: [FRZ-003 v2](FRZ-003_v2_iflas_ve_fabrika_satisi.md), [FRZ-004](FRZ-004_is_alma_ve_makine_yatirimlari.md).

## Taslak Kararlar

### 1. Ortak rapor birimi ve kayıp hesabı

**Ne:** Ay sonu raporu beklenen, gerçekleşen ve kaybedilen **çıktı eşdeğeri birimi** gösterir. On yetkinlik alanının fiziksel üretim, para veya ilk sürümde gelecek fırsatı kaybı bu ortak rapor birimine çevrilir. Çıktı eşdeğeri, fiziksel satılan ürün sayısı değildir. Her kayıp birimi yalnızca **bir sorun satırına ve kökün bulunduğu bir departmana** aittir. Ortak köke bağlı farklı satırların ayrı kayıpları toplanır; başarılı Düzelt hepsini kaldırır. Departmanların eşdeğer kayıpları toplanır, çarpımsal hesap kullanılmaz.

**Ne:** **Beklenen çıktı**, bu ay kabul edilmiş işlerin kapasite içindeki üretim hedefidir; makinenin iş alınmamış teorik kapasitesi değildir. Kullanılmayan kapasite raporda ayrı **“boş kapasite”** olarak gösterilir ve sorun kaybına eklenmez. Aynı kural, %33 gerçekleşme tabanının ve departman başına yaklaşık %20 kayıp tavanının hesabında kabul edilmiş iş hedefinin payda olmasını sağlar.

**Neden:** Gizli satırın kayıp birimi Tier'ini ele vermemeli; rapor toplamı anlaşılır olmalı ve aynı malzeme veya para kaybı iki departmanda sayılmamalıdır. İş alınmamış kapasite, kaynağı olmayan bir sorun kaybı gibi görünmemelidir.

### 2. Basit sınırlar

**Ne:** Raporun gerçekleşen çıktı eşdeğeri, beklenenin **en az %33'ü** olur. Bir departmanın eşdeğer kaybı, beklenenin **yaklaşık %20'si** düzeyinde bir üst sınırla tutulur; bu oran ilk denge hedefidir. Tavana ulaşmış departmanda ek kayıp sorunu üretilmez. Ayrı bir departman ağırlıkları tablosu kurulmaz.

**Neden:** Fabrika performansı eksiye veya çıkışsız seviyeye inmemeli; bölüm kayıpları okunur kalmalı ve karmaşık ağırlık hesabı gerekmemelidir.

### 2A. Çözülmeyen sorun kaybının büyümesi

**Ne:** Her sorun satırının oluştuğu aydaki başlangıç aylık kaybı saklanır. Ayın kararlarında çözülmeden kalan satırın sonraki aylık potansiyel kaybı bir önceki aya göre **%5 artar**, fakat **başlangıç kaybının iki katını** aşmaz. Aynı oran ve tavan bütün Tier'lere uygulanır. Başarılı Düzelt ilgili kökün bağlı bütün satırlarını kapatır; etkisi mevcut FRZ-002 v3 §4 sırasıyla sonraki raporda görünür. Büyüme mevcut satırların kaybını değiştirir, köke sonradan yeni bağlı satır doğurmaz; FRZ-001 §4'teki bağlı satırların birlikte oluşma kuralı korunur.

**Ne:** Her sorun satırı tavan öncesi **potansiyel kaybını** saklar. Yaklaşık %20 tavan satırlara tek tek değil, büyüyen potansiyeller toplandıktan sonra **departmanın rapora geçen gerçekleşen toplam kaybına** uygulanır; fabrika genelinde en az %33 gerçekleşme tabanı da korunur. Bu yüzden satır potansiyellerinin toplamı gerçekleşen departman kaybını aşabilir; kart iki toplamı ve tavan farkını ayrı açıklar. Sınıra ulaşmış departmanda yeni sorun üretilmez. Kayıp aynı çıktı eşdeğeri biriminde raporlanır ve aynı gerçek para/gider olayı ikinci kez kasadan düşülmez. Büyüme oranı Tier'e göre değişmediği için gizli sorunun derinliği artış yüzdesinden çıkarılamaz.

**Neden:** Sabit zararlı derin sorunları bekletmek bedelsiz bir stratejiye dönüşüyordu ve gizli sorunlar birikiyordu. Büyüme beklemenin bedelini görünür kılar; iki kat sınırı ve mevcut rapor tavanları kaybın sınırsız artmasını önler. Danışmanın ekonomik değerindeki test artışı **ayrı ücret ayarından** kaynaklandı; büyüme danışman kullanan karakterin de kasasını düşürdü. Tier'den bağımsız oran gizli bilginin rapordan sızmasını engeller. Bu taslak, [IDEA-012](../ideas/IDEA-012_erken_donem_ve_teklif_havuzu.md) erken dönem açığı çözülmeden CURRENT yapılmaz.

### 3. Ay akışı ve kullanılabilir nakit

**Ne:** Sıra **rapor → iş kabulü, danışman ve Düzelt ile yatırım/finansman/çıkış kararları → ayın teslimleri, fiili satışları ve giderleri → sonraki rapor veya kapanış** şeklindedir. FRZ-001'in güvence kontrolündeki kullanılabilir oyun parası, **mevcut kasa eksi bu ayın henüz ödenmemiş bilinen olağan giderleri, kabul edilen işlerin bu ay ödenecek bilinen maliyetleri ve vadesi gelmiş bilinen finansman yükümlülükleridir**; gerçekleşmemiş ürün veya varlık satış geliri eklenmez. Bir maliyet olağan giderlerde zaten sayıldıysa ikinci kez ayrılmaz. Danışman ve Düzelt bedelleri FRZ-001'e göre karar anında ödenir.

**Ne:** Devam eden fabrikada ay sonu kasa, **önceki kasa + fiili ürün satış geliri + gerçekten alınan şirket kredisi + gerçekleşen varlık satış geliri − fiili olağan giderler − danışman sözleşmeleri − Düzelt bedelleri − varlık/makine alım bedelleri − ödenen kredi anaparası − finansman giderleri** ile açıklanır. Henüz onaylanmamış teklif, gelecekteki ihale geliri veya satılmamış makinenin değeri kasaya yazılmaz. Fabrikanın tümünün devri veya tasfiyesi bu aylık faaliyet hesabına eklenip ikinci kez sayılmaz; ayrı kapanış hesabında varlık/fabrika satış bedeli, eldeki kasa ve kalan şirket yükümlülükleri mahsuplaştırılır.

**Ne:** Şirket kredisi kasaya girince aynı tutarda kredi bakiyesi oluşur. İflas hesabındaki **net pozisyon = kasa − ödenmemiş şirket kredisi bakiyesi**; kredi çekmek bu pozisyonu tek başına iyileştirmez. Borçlu şirkete uygulanan görünür finansman gideri şirket hesabına yazılır; iflas sonrası kişisel borca uygulanmaz. Şirketten karaktere kişisel para aktarımı yalnızca borçlar kapatılmış gönüllü tasfiye/devir kapanışında mümkündür.

**Ne:** Gerçek satış geliri fiziksel olarak satılan üründen hesaplanır. Nakit kaybının çıktı eşdeğerine çevrilmesi **yalnızca rapor ölçüsüdür**; aynı gerçek gider kasa hesabından ikinci kez düşülmez.

**Ne:** Kabul edilen işin satış geliri, **teslim edildiği ayın** fiili ürün satışına girer. İlk sürümde ayrıca gecikme cezası kesilmez; teslim edilemeyen miktarın etkisi eksik satış geliri ve ilgili sorun satırının kaybıdır, ikinci bir ceza/kayıp satırı açılmaz. İleride ceza tasarlanırsa eşdeğeri aynı sorun satırının kaybına dahil edilerek çift sayım önlenir.

**Neden:** Oyuncu ay sonu zorunlu giderleri veya kabul ettiği işin bilinen maliyetini müdahaleye harcayamamalı, henüz teslim etmediği işin gelirine dayanarak karar vermemeli ve rapor dönüşümü nakit kaybını iki kez yazmamalıdır. Kredi ve varlık satışları gerçek nakit hareketleri olarak görünmeli; kredi geliri borcu gizlememeli, fabrika devri ve makine satışı iki kez sayılmamalıdır.

### 4. Müdahale faydası ve erken erişim

**Ne:** Düzelt sonucu ve bedeli anında belli olur; kaldırılan kaybın rapor etkisi **sonraki ay** görünür. Tier fiyat bantları fabrika ölçeğinin aylık birim değeriyle orantılı tutulur. Kuruluş sonrasındaki kasa en az **ilk ayın bilinen olağan giderleri + küçük ölçekteki olası en derin Tier'in üst güvence bedeli** kadar olmalıdır. FRZ-001'in ilk üç ay danışmansız gizli sorun deneme testi ayrıca sınanır.

**Neden:** Geçmiş raporlar yeniden yazılmamalı; küçük fabrikada da bilgi açığını oyun parasıyla deneme yolu açık kalmalıdır.

## Reddedilen Yollar

- Gizli sorunlarda nakit ve fiziksel çıktı kaybını farklı rapor birimleriyle göstermek; Tier veya sorun türü birimden anlaşılabilir.
- Aynı kaybı farklı departmanlarda tekrar saymak; toplam raporu ve müdahale etkisini şişirir.
- Gelecek satış gelirini Düzelt güvencesine eklemek; henüz gerçekleşmemiş kazanca dayanarak zorunlu gider parasının harcanmasına yol açabilir.
- Departman ağırlıkları ve çarpımsal kayıp hesabıyla başlamak; ilk ekonomi modelini gereksiz karmaşıklaştırır.
- Teorik makine kapasitesini doğrudan beklenen çıktı saymak; iş alınmamış kapasiteyi sorun satırına bağlanamayan sahte kayıp yapar.
- Teslim edilmeyen iş için ilk sürümde ayrıca gecikme cezası kesmek; aynı zararı satışta ve raporda yeniden sayabilir.

## Bağımlılıklar ve Kapsam Dışı Konular

- Çıktı eşdeğerine çevirme değeri, para/saat tutarları, kuruluş sonrası kasa miktarı ve yaklaşık %20 departman sınırının kesin dengesi testle belirlenecektir.
- İflas tetikleyicisi [FRZ-003 v2](FRZ-003_v2_iflas_ve_fabrika_satisi.md) ile tanımlanır; beklenmeyen giderlerin kesin dengesi açık kalır. Bilinen giderleri ayırma kuralı tüm belirsizlikleri ortadan kaldırmaz.
- Finansman giderinin kesin oranı, yatırım referans değerinin aylık düşüşü, kredi tutarı ve ödeme vadesi sonraki denge çalışmalarına aittir.
- Ar-Ge ve Yatırım'ın gerçek uzun vadeli etkileri ayrıca tasarlanır; ilk sürümde aylık çıktı eşdeğeriyle raporlanabilir.
- Danışman kartlarının fiyatları ve gerçek para seçenekleri bu FREEZE kapsamında değildir.
- Büyüme uygulandıktan sonra danışman sözleşme ücreti, tipik departmanın yaklaşık 1–2 aylık gizli zararıyla patron testinde karşılaştırılıp dengelenir; bu hedef bir fiyat FREEZE kararı değildir ve FRZ-006 v2'nin açık fiyat maddesini değiştirmez.
