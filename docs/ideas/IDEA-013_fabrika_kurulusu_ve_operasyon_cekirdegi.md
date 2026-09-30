# IDEA-013 — Fabrika Kuruluşu ve Operasyon Çekirdeği

## Durum/Tur

Durum: DRAFT — Claude Tur 1 notları yazıldı; kullanıcı kararı bekleniyor; FREEZE değildir.
Tur: 1
Tarih: 2026-09-30
Bağımlılıklar: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md), [FRZ-002 v3](../freeze/FRZ-002_v3_fabrika_ekonomisi.md), [FRZ-003 v2](../freeze/FRZ-003_v2_iflas_ve_fabrika_satisi.md), [FRZ-004](../freeze/FRZ-004_is_alma_ve_makine_yatirimlari.md), [FRZ-005 v2](../freeze/FRZ-005_v2_personel_ve_insan_yonetimi.md).
Kaynak: Kullanıcının fabrika kurma ve yönetme anlatımı ile 29–30 Eylül 2026 tarihli tasarım ve UI çalışma belgeleri. Bu belgeler onaylı oyun kuralı değildir.

## Öneri (GPT)

### Amaç ve ilk oynanabilir döngü

Oyuncu fabrikayı bir rapor tablosu olarak değil, kiraladığı alanın, aldığı makinelerin ve çalışan kadrosunun görüldüğü bir yer olarak deneyimler. Kararların ekonomik sonucu aylık raporda açıklanır. İlk dilim şu sırayı sınar: **kiralık alan seç → makine seç ve kur → vardiya ile gerekli personeli gör → ücret politikası seç → uygun işi kabul et → sağlam ürün, gider ve kasa sonucunu incele**. İlk dilim, mevcut tek Düzelt ve sorun kartı kurallarını koruyarak bunlarla birlikte oynanabilir olmalıdır.

### Alan ve görsel sahne

- Kiralık yer ilanı başlangıçta kullanılabilir zemin alanını ve aylık kirayı gösterir. 100 m² için A, 150 m² için yaklaşık 2A ve daha büyük ilanlar kullanıcı örnekleridir; kesin fiyat eğrisi değildir.
- Makine ve gerekli diğer yatırımlar alan tüketir. Alan yetersizse yeni yatırım o yere kurulamaz. Büyük yeri erken kiralamanın boş alan kira maliyeti, küçük yerin ise büyüme sınırı vardır.
- 2,5D veya tepeden sahne makineleri, kullanılan/boş alanı, kurulumu süren yatırımları ve temel uyarıları gösterir. Oyuncunun makineyi sahnede hangi kareye koyduğu ayrı bir üretim bonusu yaratmaz; yerleşim optimizasyonu ve iş planı mekaniği bu önerinin kapsamı dışındadır.
- Raporlar korunur; görsel sahne yatırım ve kapasite durumunu anlamayı kolaylaştırır.

### Makine kataloğu ve kapasite zamanı

- Başlangıç kataloğunda dört torna, üç freze ve iki taşlama çeşidi tasarım hedefidir. Diğer ekipmanlar ayrıca seçilir. Her yatırım için en az fiyat, alan, teorik kapasite, vardiya başına personel ihtiyacı, uygun iş niteliği, teslim/kurulum süresi, işletme maliyeti ve güncel referans değerinin veri alanları tanımlanır.
- Makine alımı karar anında kasayı ve FRZ-003 v2 yatırım hesabını etkiler. Teslim ve kurulum bitmeden fiili üretim kapasitesi artmaz. İflas hesabındaki azami kâr katkısının ilk tam faaliyet ayı sonrasına bırakılması korunur.
- Farklı makine parklarının eriştiği teklifler ve boş kapasite simülasyonda karşılaştırılır. Çeşitlilik veya uzmanlaşma peşinen kazanan ilan edilmez; ikisi için de anlamlı tercih ve bedel aranır.

### Otomatik kadro ve ücret politikası

- Gerekli personel, makinelerin vardiya başına ihtiyacı ve seçili vardiya sayısından türetilir. Oyuncu her makineye tek tek personel sürüklemez. Açık pozisyonlar, doldurulmuş pozisyonlar ve personel eksikliğinin kapasite etkisi görünür.
- Beş ücret grubu: **operatör, saha yöneticisi, beyaz yaka, ofis yöneticisi, üst düzey yönetici**. Her grupta ücret politikası işletme giderini ve işe alım/tutma koşullarını etkiler. Düşük ücret boş kadro ve devir riski yaratabilir; yüksek ücret sınırlı istikrar faydası karşılığında kârı azaltır. Ayrı müdür karakteri veya müdür yetkinliği bu taslakla eklenmez.
- Oyuncu, bir makine ve bir vardiyalı ilk düzende operatör ihtiyacını kendisi karşılayabilir. Bu çalışma aynı ayın patron yönetim zamanından harcar. Sonraki makine ve vardiyalar ek personel gerektirir. Zamanın kesin tutarı ve patronun hangi vardiyayı karşılayabileceği açık karardır.
- Yemek, prim, servis, eğitim ve sarf kalitesi gibi personel/operasyon politikaları tek karar kartıyla sunulabilir. Her biri para veya zaman bedeline karşı ölçülebilir bir sonuç vermelidir; kesin etkiler bu turda belirlenmez.

### OEE, sorunlar ve para hesabı

- Kullanıcının hedefi, makine sayısının yanında **iyi ürün üretme ve bunu kâra çevirme becerisinin** oyunda belirleyici olmasıdır. OEE kullanılabilirlik × performans × kalite olarak fiziksel üretimin açıklayıcı bileşenleri şeklinde araştırılır. OEE tek başına satış veya kâr değildir: alınmış iş, satılan sağlam ürün ve birim gelir de gerekir.
- Örnek: kabul edilmiş 100 birimlik işte bakım duruşu 10 birim, kalan 90 birimde kalite kaybı 4,5 birimse 85,5 sağlam birim vardır. Bakım ve Kalite sorun satırları bu 14,5 fiziksel kaybı açıklar; OEE çarpımı uygulandıktan sonra kayıp ikinci kez düşülmez.
- FRZ-002 v3'ün çıktı eşdeğeri fiziksel ürünle özdeş değildir; Finans gibi alanların kaybı da raporlanır. Fiziksel OEE, departmanların eşdeğer kayıpları, %33 taban ve yaklaşık %20 departman tavanı arasında **tek kaynaklı bir hesap/uzlaştırma** tasarlanmalıdır. Mevcut FRZ-002 v3 geçerlidir; bu öneri onun formülünü sessizce değiştirmez.
- Aylık kasa, FRZ-002 v3 uyarınca fiili satış, ücret, kira, malzeme, yatırım, finansman ve Düzelt giderleriyle açıklanır. Ucuz sarf daha düşük girdi bedeli karşılığında hurda veya arıza riskini artırabilir; kalite kaybı fiziksel ürün ve sorun raporunda iki ayrı ceza olarak sayılmaz.

### Sonraki tasarım konuları

İlk döngü çalıştıktan sonra leasing ve teşvikli kredi, kiradan kendi binasına inşaatla geçiş, ayrıca Ar-Ge ürün geliştirip patentle satma ayrı IDEA konularında ele alınır. Bu üç konu şirket borcu, satılabilir yatırım değeri veya mevcut iş/ihale dışındaki satış yolunu değiştirebilir; burada kesin kural önerilmez. Ürün için geçen “%150/%300 marj” örnekleri, satış marjı mı maliyet üzerine kâr oranı mı olduğu belirlenmeden denge değeri sayılmaz.

### Claude incelemesi için odak

1. FRZ-002 v3'teki toplamsal eşdeğer kayıplar ile fiziksel OEE arasında çift sayım olmadan hangi en küçük köprü kurulabilir?
2. Patronun operatörlüğü, tek Düzelt için gereken patron saatiyle anlamlı fakat çıkışsız olmayan bir tercih yaratıyor mu?
3. Ücret, personel açığı ve OEE etkilerinde aynı personel kaybı iki kez yazılıyor mu; ayrı müdür karakteri eklemeden işler yürür mü?
4. Teslim/kurulum, makine referans değeri ve ilk tam faaliyet ayı kuralları korunuyor mu?

## Notlar (Claude)

Tur 1 · 2026-09-30 · Ölçüm: `godot/` patron testi, 100 tohum, %5 büyüme açık, taban 3/5 teklif kuralı açık (IDEA-012 önerisi; kapalıyken sonuçlar aynı yönde). Sayılar prototip girdisidir; denge kararı değildir. Prototipte henüz alan/kira/maaş/vardiya yok; yalnız patron saati ve sabit gider davranışı ölçülebildi (`operator=H` stres anahtarı).

### Aldığım Notlar

- Sıralı örnek (100→90→85,5; kayıp 14,5) FRZ-002 v3 ile tutarlı: toplam kayıp 14,5, gerçekleşen 85,5. Yön doğru: OEE ayrı bir hesap değil, aynı sorun satırlarının fiziksel okunuşu olmalı.
- Kapsam ayrımı (yerleşim optimizasyonu yok, müdür karakteri yok, leasing/bina/Ar-Ge sonraya) doğru ve FRZ-005 v2 ile uyumlu.
- Teslim/kurulum ve ilk tam faaliyet ayı kuralı prototipte korunuyor (azami kâr potansiyeli yalnız ay sonu ve yalnız bir tam ay çalışmış makineyle). Alan/kira eklenirse bu kural değişmemeli.

### Bulduğum Sakıncalar

1. **OEE çarpımsal, FRZ-002 çarpımsal kullanmıyor.** Örnek A×P×K sıralı çarpım (14,5); FRZ-002 v3 §1 ve v4 §1 toplamsal (5 kalite kaybı 100 üzerinden 5, toplam 15). Paralel ikinci formül kendi tavan (%20) ve taban (%33) kuralını ister. **En küçük köprü:** kayıp yalnız sorun satırlarından doğar; OEE bunun fabrika düzeyinde bir *okuma lensi*dir: fiziksel bölümlerin (Bakım → kullanılabilirlik, Planlama/Depo & Sevkiyat/Üretim → performans, Kalite → kalite) gerçekleşen kaybı beklenen çıktıya bölünür; Finans, Satın Alma, Yatırım, Ar-Ge, İnsan Yönetimi kaybı "para/fırsat" olarak OEE dışında ayrı satırdır. Böylece OEE = 1 − fiziksel kayıp/beklenen ve gerçekleşen çıktı ile birebir toplanır, çift sayım yolu kalmaz. Hangi bölümün hangi bileşene gittiği açık karar.
2. **OEE'yi ikinci bir karar katmanına çevirme riski.** Sarf kalitesi, vardiya, ücret, eğitim kartları "OEE çarpanı" olursa aynı kayıp hem satırda hem çarpanda yazılır. **Tek kanal ilkesi:** her politika yalnızca (a) tek bir bölümün yeni satır olasılığı/miktarı, (b) kapasite (payda), ya da (c) kasa giderinden birini etkiler; birden fazlasını değil. Kalite kaybı "fiziksel ürün ve sorun raporunda iki ayrı ceza olmaz" cümlesi bu ilkenin özel hâli.
3. **Personel eksiği kayıp değil, kapasite olmalı.** Ücret düşük → boş kadro → çalışabilir kapasite düşer; bu payda azalmasıdır ve FRZ-002 "boş kapasite" ile aynı çizgidedir (sorun satırı açmaz). Aynı olay bir de "devir sorunu" satırı, ayrıca OEE performans düşüşü açarsa üç kez yazılır. Kadro değerlendirmesi ay başı iş seçiminden önce yapılmalı; işten sonra eksilen kadro FRZ-004'ün "ayrı gecikme cezası yok" kuralını fiilen ihlal eder. Ücretin İnsan Yönetimi önlemesiyle (FRZ-005 v2, kişi kaynaklı %30 pay) üst üste binmemesi için ücret yalnız kadro doluluğunu etkilemeli, yeni kişi sorunu olasılığını değil.
4. **Beş ücret grubundan yalnız operatörün tetikleyicisi var.** Operatör makine × vardiyadan türüyor; saha yöneticisi, beyaz yaka, ofis yöneticisi, üst düzey yönetici için tetikleyici (kaç operatörde/hangi ölçekte) yok. Tetikleyicisiz gruplar süs kalır ya da "ayrı müdür karakteri"ni arka kapıdan getirir (FRZ-005 v2 reddi). İlk dilimde yalnız operatör grubu ve ölçeğe bağlı tek sabit "yönetim kadrosu" gider satırı yeter; kalan gruplar tetikleyici tanımlanınca açılsın.
5. **Tek makine kendi sabit giderini karşılamıyor.** Prototipte A: kapasite 40, ortalama birim marj ≈ 1,02 → tam doluluk en iyi hâlde ≈41; sabit gider 30+12 = 42. Taban kuralıyla bile A×1'de Dengeli ve İnsan Yöneticisi 0/100 (hepsi iflas), Teknik Usta 90/10. Buna gerçek operatör maaşı eklenirse ilk makine tek başına yaşayamaz; patron operatör olmak zorunda kalır. Bu bilinçli bir tasarım ("ilk makineyi kendin çalıştır") olabilir, ama "tercih" değil zorunluluk olur ve patron saati bunu telafi etmezse çıkış yok. Alan kirası mevcut sabit giderin yerine mi üstüne mi geldiği kararlaştırılmalı.
6. **Patron operatörlüğü şu hâliyle tercih değil, uçurum.** Ölçülen aylık patron saati kullanımı ortalama 1,2–7,7 saat (azami 27) / 40. Operatöre 16, 24 ve 32 saat verildiğinde hayatta kalma ve danışmansız gizli Düzelt erişimi **değişmiyor** (saat engeli 0); 36 saatte **bütün** gizli denemeler kilitleniyor (Erken Kurucu 265/272 gizli ay saat engelli; diğer karakterlerde para engeli dışında hepsi). Sebep FRZ-001'in gizli satır "en fazla saat" güvencesi: küçük ölçek T3 tavanı 8 saat, kalan süre bunun altına düşünce deneme hiç başlamıyor. Yani 0–32 saat bedelsiz, 33+ çıkışsız; kademeli fırsat maliyeti yok. FRZ-001 §6'nın ilk üç ay danışmansız deneme testi de 32 saat üstünde kırılır.
7. **Operatör verimi ve OEE.** Patron operatörse Üretim yetkinliği çıktıyı etkiliyor mu? Etkilerse Üretim sorun satırıyla çift sayım, etkilemezse "kendi çalış" tek bedel olarak ücret tasarrufu. Yalnız ikincisini öneriyorum.

### Kafama Yatmayanlar

- Tek IDEA'da alan, kira, 9 makine tipi, vardiya, beş maaş grubu, politika kartları, OEE ve üç gelecek konu: kapsam büyüyor. Öneri: (a) alan + kira + katalog, (b) otomatik kadro + operatör, (c) OEE okuma lensi ayrı dilimler; politika kartları (b) ve (c) bittikten sonra.
- Kullanıcının "iyi ürün üretme becerisi belirleyici olsun" hedefi OEE'siz de sağlanıyor: kayıp zaten Bakım/Kalite/Üretim satırlarından gelir ve Düzelt bilgisiyle çözülür. OEE ancak oyuncuya "hangi bölümüm üretimi kaybettiriyor" sorusunu daha iyi söyletiyorsa ek değer taşır; yeni bir para mekaniği olarak değil.
- Ücret politikası "istikrar faydası" (yüksek ücret) net değil; kadro doluluğu dışında bir fayda tanımlanırsa üçüncü kanal açılır.

### Önerilen sonraki sınama

1. Prototipe **operatör saati** ve **kadro doluluğu (payda)** ekle: patron seçtiği tek vardiyada ilk makineyi çalıştırır (aylık saat kesilir, ücret gideri düşer); operatör saati seçimi `40 − mevcut ölçeğin hidden T tavan saati` ile sınırlanır (küçük ölçek 32) — kalan saat güvenceyi asla bozmasın.
2. Operatör saati 16 / 24 / 32'de ve A×1, A×2, A+B parklarıyla 100 tohum: hayatta kalma, Düzelt erişimi, saat engeli ay sayısı. Operatör olmayan fabrikayı aynı sayıyla karşılaştır.
3. OEE lensi yalnız rapor: fiziksel bölüm kaybı / beklenen ve gerçekleşen/beklenen ile çakıştığını (fark 0) tohumlarda doğrula.

### Açık Sorular

1. OEE bileşenleri için bölüm eşlemesi: Depo & Sevkiyat performans mı, kullanılabilirlik mi? Üretim nereye?
2. Operatörlük: sabit saat mi (ör. 24), yoksa vardiya sayısına bağlı mı; tavan `40 − tavan saati` kuralı kabul mü?
3. Alan kirası mevcut 30 sabit giderin yerine mi geçer, üstüne mi eklenir; tek A makinenin yaşayabilmesi tasarım hedefi mi?
4. Ücret politikası yalnız kadro doluluğunu mu etkiler (önerim), yoksa yeni sorun olasılığını da mı?

## Açık Kararlar

- Fiziksel sağlam ürün hesabı ile FRZ-002 v3 çıktı eşdeğeri ve sorun satırlarının kesin uzlaştırması; gerekirse FRZ-002'nin yeni sürümü.
- Patron operatörlüğünün aylık yönetim saati maliyeti ve vardiya sınırı.
- Beş ücret grubunun başlangıç maaşları, ücret politikasının işe alım/devir etkisi ve eksik kadronun üretime etkisi.
- Başlangıç makinelerinin tam listesi ve sayısal fiyat/alan/kapasite/teslim değerleri; kiralık alan ilanları ve kira eğrisi.
- İlk dilimde hangi operasyon politika kartlarının bulunacağı ve bunların süre/maliyet/etki sınırları.
- Leasing, teşvik, kendi bina yatırımı ve Ar-Ge ürün satışı ayrı tasarım turlarıdır; bu dosyadan kendiliğinden onay çıkmaz.

## Karar Özeti

- Kullanıcı kiralık yer seçimini ve makinenin kapladığı alanı fabrika kuruluşunun parçası olarak istedi; çünkü alan hem kira giderini hem büyüme sınırını belirlemeli.
- Kullanıcı makine çeşitleri ve her makinenin fiyat, alan, personel, kapasite gibi gereksinimlerinin katalogda görünmesini istedi; çünkü yatırım kararı ilerideki iş ve kapasite seçeneklerini değiştirmeli.
- Kullanıcı sahnede yerleşim optimizasyonu istemedi; çünkü bunun gerektirdiği iş planı mekaniği çekirdek kararı güçlendirmeden kapsamı büyütür.
- Kullanıcı personel ihtiyacının makine ve vardiyadan otomatik hesaplanmasını ve beş ücret grubunu istedi; çünkü maaş, kadro sürekliliği ve kâr arasında anlaşılır tercih kurmak istiyor.
- Kullanıcı patronun ilk makineyi tek vardiyada kendisinin işletebilmesini, bunun yönetim zamanını da harcamasını onayladı; çünkü işçi ücretinden tasarrufun yönetim fırsat maliyeti olmalı.
- Kullanıcı üretim, kalite, personel ve sarf kararlarının OEE ve gerçek kâra yansımasını istedi; çünkü fabrikanın yönetim kararları yalnız dekoratif kalmamalı.
- Kullanıcı teslim/kurulum gecikmesini ve ileride finansman, bina, Ar-Ge ürün yollarını tasarım yönü olarak istedi; çünkü yatırımın para kadar zaman ve gelecek fırsat maliyeti de olmalı.
