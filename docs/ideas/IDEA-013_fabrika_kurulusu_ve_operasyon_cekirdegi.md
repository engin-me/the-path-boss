# IDEA-013 — Fabrika Kuruluşu ve Operasyon Çekirdeği

## Durum/Tur

Durum: DRAFT — Claude incelemesi ve kullanıcı kararı bekleniyor; FREEZE değildir.
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

Tur 1 incelemesi bekleniyor.

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
