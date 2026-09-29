# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: DRAFT — Tur 10 revize edildi, Claude incelemesi bekleniyor
Tur: 10
Son güncelleme: 2026-09-29
Kaynak: Kullanıcının ilk önerisi, sonraki kararları ve 2026-09-28 tarihli beyin fırtınası notlarından seçilen fikirler.
Tur 1–9 Claude incelemeleri tamamlandı; aşağıdaki `Notlar (Claude)` hâlâ Tur 9 incelemesidir. Tur 10, kullanıcının son kararlarıyla Claude incelemesi öncesinde revize edildi.
Sıradaki adım: Claude bu Tur 10 önerisini aynı dosyanın `Notlar (Claude)` bölümünde inceler. Beyin fırtınasındaki kesinleşmemiş seçenekler karar olarak alınmaz; FREEZE için ayrıca kullanıcı onayı gerekir.

## Öneri (GPT)

### Amaç

Oyuncunun çalışanlık kariyerinde edindiği deneyimin, fabrika sahibi olduğunda doğrudan anlamlı hale gelmesini sağlamak.

Patronun gücü yalnızca para veya statlardan değil, geçmişte hangi işleri ne kadar öğrendiğinden gelmeli.

### Patron Yetkinlikleri

Her yetkinlik 0-100 arasındadır.

1. Üretim
2. Planlama
3. Depo & Sevkiyat
4. Bakım
5. Kalite
6. Satın Alma
7. Finans
8. Ar-Ge / Ür-Ge
9. Yatırım
10. İnsan Yönetimi

Bu on alanın teorik toplamı 1000'dir; toplam puanın oyunda ayrı bir işlevi henüz önerilmiyor.

### Temel Mantık

Yetkinlik doğrudan üretim/verim bonusu değildir.

Yetkinlik öncelikle bir **bilgi modelidir**: patronun ilgili departmandaki sorunları kendi başına ne kadar derinden teşhis edebildiğini belirler. “Düzelt” eylemini kilitlemez. Sorun çözümünde ilgili alanın **etkin yetkinliği**, patronun puanı ile aktif danışmanların o alandaki puanlarının **en yükseğidir**; puanlar toplanmaz. Danışman patronun kalıcı yetkinliğini artırmaz.

Önerilen görünürlük eşikleri:

- 30 -> Tier 1
- 50 -> Tier 2
- 70 -> Tier 3
- 90 -> Tier 4
- 100 -> Tier 5

Eşikler taslak değerlerdir; çözüm döngüsü sınanmadan kesinleşmez. Patronun yetkinliği yetersizse yüksek derinlikteki kök neden gizli kalabilir. Buna rağmen departmandaki açıklanamayan kayıp oyuncuya sinyal olarak gösterilir. Patronun yetkinlikle ulaştığı kademe **Görüş Seviyesi**, sorunun eşik kademesi **Sorun Derinliği** olarak adlandırılır; bu terimler yeni mekanik veya tetikleyici getirmez.

Örnek:

Satın Alma performansı düşüktür.

- T1: Fiyatlar piyasanın üzerinde
- T2: Tedarikçi termin performansı kötü
- T3: Tek tedarikçiye aşırı bağımlılık
- T4: Satın alma sürecinde belirli tedarikçiler sistematik olarak kayrılıyor
- T5: Tedarik kararlarında gizli çıkar çatışması veya usulsüz ödeme var

Satın Alma yetkinliği 70 olan patron T1-T3 sorunlarını kendi başına görebilir; T4-T5'in kök nedenini kendi başına teşhis edemez. Açıklanamayan kayıp sinyali görünür kalır; bağımsız uzman daha derin nedeni raporlayabilir.

### Sorun Çözüm Döngüsü

Önerilen aylık fabrika akışı: **ay sonu raporu → ayrı sorun kartları → gerekirse danışman kartlarını değerlendirme → bir sorun kartında “Düzelt” → para ve patron zamanı harcaması → sonuç**. Her sorunun kendi kartında tek bir “Düzelt” butonu ve sözel çözüm olasılığı bulunur; danışman varken de ikinci bir eylem açılmaz. **Oyuncunun fabrika genelinde ayda yalnızca bir “Düzelt” hakkı vardır.** Başarısız denemede de hak, para ve zaman harcanır; sorun sonraki aya taşınır. Danışman sonradan tutulsa bile o ay ikinci kez basılamaz. Sorun çözümü için mini oyun veya müdahale menüsü yoktur.

Etkin yetkinlik sorunun kök nedeninin eşiğine ulaşıyorsa “Düzelt” kesin sonuç verir; eşiğin altındaysa para ve zaman harcanıp başarı için olasılık hesabı yapılır. Örnek: Planlama puanı 20 olan patron ve Planlama puanı 80 olan aktif danışman için etkin değer **max(20, 80) = 80** olur; 70 eşikli Planlama sorunu kesin çözülür. Danışman tutmak tek başına sorunu ortadan kaldırmaz; oyuncu yine “Düzelt”e basar. Eski **20 + 50 = 70** örneği artık geçerli değildir: max(20, 50) = 50, dolayısıyla o sorunda olasılık hesabı yapılır. Danışman varlığı sorunu gidermek için gereken **oyun parası maliyetini değiştirmez**; danışmanın bedeli sözleşmede ödenir. Danışman, analiz yükünü üstlenerek gereken **patron zamanını azaltır**. Kesin zaman tasarrufu denge parametresidir.

**Aynı görünür kök nedene bağlı birkaç sorun satırı olabilir.** Bunlardan herhangi birinin “Düzelt”i başarıyla uygulanırsa bağlı satırların hepsi kapanır ve kayıpları geri kazanılır. Kök nedenin eşiği ve başarı hesabı tıklanan satıra göre değişmez. **Gizli sorunlar başka sorunlarla ortak kök nedeni paylaşmaz; T1 ile T5 sorunları da aynı köke bağlanmaz.** Bağlantılar oyuncuya doğrudan açıklanmak zorunda değildir; oyuncu ipuçlarından tahmin yürütebilir. Çözümün para maliyetini sorun satırının yüzde kaybı değil, kök nedeni gidermek için yapılacak iş belirler. Sorun kartlarının görünen maliyetleri genel olarak yakın aralıkta ama birebir aynı olmamalıdır; özellikle bağlı satırlarda özdeş fiyat, bağlantıyı ele verir. En ucuz satırı seçmenin baskın stratejiye dönüşme riski Claude incelemesine açıktır.

“Düzelt”, sorunun gerektirdiği işlemin yapılmış olmasıdır; kişi kaynaklı sorunda konuşma, yaptırım veya işten çıkarma gibi sonucu da kapsayabilir. Oyuncu için ayrıca müdür kovma zinciri veya her soruna özel eylem menüsü açılmaz. Hangi işlemin gerçekleştiği sonuç metninde anlatılabilir; buna ayrı bir müdür karakteri veya müdür yetkinliği gerekmez.

Eşik altı olasılığı **kademe farkına** göre düşer. Kabul edilen taslak denge: bir kademe eksik ≈ %80, iki kademe ≈ %40, üç kademe ≈ %15, dört veya daha fazla kademe ≈ %5. Örneğin 60/70 bir kademe farktır ve yaklaşık %80 başarı verir. Rakamlar oyun testleriyle ayarlanabilir; eşiklerin kesin değerleri de henüz FREEZE değildir. Her sorun kartında çözüm olasılığı yüzde yerine **yüksek / orta / düşük** olarak yazılır; dördüncü etiket eklenmez. Tur 8 taslak eşlemesi: ≈ %80 yüksek, ≈ %40 orta, ≈ %15 ve ≈ %5 düşük. Üç etiket yakın bilgi açıkları hakkında kısmi ipucu verir; derin açıkların tam kademesini gizler. Aynı sorunu sonraki ay yeniden denemenin para maliyeti açık denge kararıdır.

Bu akışta yetkinlik, hangi eyleme basılabileceğinden çok **neyin yanlış gittiğini bilme** ve bilinmeyen sorunu çözme şansıyla ilgilidir. Aylık tek hak, kör denemenin teşhis ve danışmanı değersizleştirmesini sınırlamalıdır; etkisi oyun testinde incelenmelidir.

### Fabrika Performansı ve Zaman

Kullanıcının tarif ettiği rapor modelinde, departmanın ulaşılabilir performansından sorunların etkileri düşülerek gerçekleşen performansa varılır. Örnek: **Planlama %60** ise dört sorun satırının etkileri **−%5, −%15, −%10, −%10 = −%40** olabilir. ERP kaynaklı ilk iki satır aynı görünür köke bağlıysa başarılı tek müdahalede ikisi de kalkar ve diğer koşullar sabitken performans **%80** olur. Bu örnekte yüzde kayıpları toplamsaldır; hesaplama kuralı ve farklı nedenlerin etkileşimi fabrika ekonomisi tasarımında sınanacaktır. Ulaşılabilir performansın makine, ürün, kapasite ve talep gibi gerçek sınırlarla tanımlanması ayrıca gerekir.

Patronun aylık yönetim zamanı sınırlıdır; para olsa bile bütün yönetim işleri aynı ay yapılamaz. **Ayda tek “Düzelt”** kuralıyla birlikte bu zaman, diğer yönetim kararları için de fırsat maliyeti yaratır. Aylık saat bakiyesi, çözüm süreleri ve danışmanın zaman tasarrufu henüz sayısal olarak kararlaştırılmadı.

### İnsan Yönetimi ve Personel

Bu IDEA'da müdür için ayrı kimlik veya yetkinlik puanı tanımlanmıyor. Bu, gelecekte ekip/personel sisteminin ayrı bir IDEA'da tasarlanmasını engellemez. **Kişi kaynaklı sorunların ortaya çıkma sıklığını yalnızca patronun kalıcı İnsan Yönetimi puanı azaltır**; danışmanın İnsan Yönetimi puanı bu yatay sıklık etkisine katılmaz. Etki aylık performans raporlarına yansır. En yüksek İnsan Yönetimi yetkinliği için **yaklaşık %80 azalma tavanı** ve kişi kaynaklı sorunların toplam sorunlar içinde **yaklaşık %30–40 payı** başlangıç denge hedefidir. İnsan Yönetimi alanının kendi sorunları da vardır; bu yüzden danışman kartındaki İnsan Yönetimi puanı o alanın sorunlarını görme/çözmede işe yarar. Kişi kaynaklı bir sorun başarıyla “Düzelt”ildiğinde gereken personel işlemi çözümün içinde sayılır. Kesin sıklık eğrisi ve sorun içeriği testle belirlenecektir.

Bu yönlendirme, `GAME_OVERVIEW` §10'daki ayrı müdür uzmanlığı ve iyi/kötü müdür matrisinden ayrılıyor. FREEZE öncesi bu tutarsızlık gözden geçirilmeli; yön dondurulursa vizyon belgesi de yeni tasarıma göre güncellenmelidir.

### Statların Rolü

Statlar doğrudan yetkinlik puanı veya Tier açmaz.

Statlar:
- yetkinlik kazanma hızını,
- problem çözme süresini,
- problem çözme maliyetini,
- “Düzelt” dışındaki bazı görevlerde başarı oranını

etkileyebilir.

Statlar, eşik altı “Düzelt” olasılığını doğrudan artırmaz; burada belirleyici olan ilgili alanın yetkinliği ve danışman desteğidir. Statlar süreyi ve maliyeti etkileyebilir. Böylece yüksek Zeka, meslek deneyiminin yerini tek başına alamaz.

Örnek:
Çok yüksek Zeka, hayatında satın almada çalışmamış bir patronun T4 satın alma sorununu otomatik görmesini sağlamaz.

### Kariyerden Patronluğa Geçiş

Oyuncunun fabrika kurması için bütün yetkinliklerinin yüksek olması gerekmez.

Oyuncu erken fabrika kurabilir ve eksik altyapısının sonuçlarını yaşayabilir.

Örnek ilk oyun:

- Üretim: 90
- Depo & Sevkiyat: 80
- Planlama: 35
- Bakım: 35
- Kalite: 35
- Satın Alma: 30
- Finans: 30
- Ar-Ge / Ür-Ge: 25
- Yatırım: 30
- İnsan Yönetimi: 25

Bu oyuncunun fabrikayı kurabilmesi mümkündür ancak işletmenin uzun süre ayakta kalması zor olabilir.

Oyuncunun ilk başarısızlığı sonraki kariyerinde hangi alanlarda deneyim kazanması gerektiğini öğretmelidir.

### Bilinmeyen Sorun ve Geri Bildirim

Patron kök nedeni göremese bile ilgili sorun kartı **açıklanamayan kayıp veya belirti** gösterir (`GAME_OVERVIEW` §9). Gizli sorun bağımsız kök nedeni taşır; görünür sorunla aynı kökten gelip onun müdahalesiyle kendiliğinden kapanmaz. Oyuncu o karttaki “Düzelt”i deneyebilir veya danışman çağırabilir; gerçek neden otomatik ifşa edilmez. Başarısız deneme sonrasında harcanan para, zaman, aylık müdahale hakkı ve sorunun sürdüğü açıkça gösterilmelidir. Kaybın büyüklüğünün ve kategori ipuçlarının hangi düzeyde gösterileceği açık karardır.

Fabrika battıktan sonra **aynı karakterle devam edilir** ve karakter borç yüküyle yeniden başlar. Borç, toparlanmanın mümkün olduğu ölçekte olmalıdır; **yaklaşık bir oyun yılında toparlanma** kullanıcı tarafından örnek ufuk olarak verildi, kesin süre değildir. Psikoloji, yeni başlayan bir karakterinkinden yaklaşık **%25 düşük** başlayabilir; bu da taslak örnektir, sabit denge değeri değildir. Düşüş kalıcı bir başarısızlık sarmalı yaratmamalıdır.

İflas **yetkinlik kaybettirmez** ve genel stat kazanımını hızlandırmaz. Bunun yerine karakter, kayba en çok yol açan alanda küçük, üst sınırı olan **“acı tecrübe” yetkinlik artışını karakter başına bir kez** alır. Böylece iflastan öğrenilirken kasıtlı tekrar iflasla bonus biriktirme engellenir. Kalıcı bedel borç ve harcanan zamandır; psikoloji düşüşü geçicidir. Kesin artış, borç miktarı ve psikolojinin toparlanma süresi denge kararlarıdır.

Değerlendirme raporu fabrikanın ömrünü, en çok kayıp yaratan departmanları, görülen/görülmeyen sorunları ve dikkate alınmayan uyarıları özetleyebilir (`GAME_OVERVIEW` §23). Rapor oyuncuya sonraki girişimde neyi öğrenmesi veya kime yetki vermesi gerektiğini anlatmalıdır. Aynı karakterle devam etme tercihi, `GAME_OVERVIEW` §5–6 ve §25'teki “ikinci kariyer / sonraki run” dilini netleştirmeyi gerektirir; bu IDEA aşamasında vizyon belgesi değiştirilmez.

### Eksik Yetkinliği Kapatma Yolları

Oyuncunun her işi yapmış olması zorunlu değildir.

Danışman bu IDEA'da mekanikleştirilen yoldur. Aşağıdakiler diğer olası yolları gösterir; bunların kuralları ayrı IDEA'larda tasarlanmadıkça onaylanmış mekanik sayılmaz. **Ortaklık ayrı bir tasarım konusudur. Dış kaynak yalnızca olası telafi yolu olarak anılmıştır; henüz mekanik, fiyat veya kapsamı konuşulmadı.**

- iyi ekip ve personel düzeni
- ortak
- uzman çalışan
- dış kaynak
- eğitim / sonradan öğrenme

Oyunda önceden tanımlı **10–15 danışman kartı** bulunur. Her danışmanın mevcut patron yetkinliklerinden **2–5 alandaki puanı** vardır. Ay sonu raporu görüldükten sonra **aktif danışmanlar aday havuzundan çıkarılır** ve kalan kartlardan rastgele **3 kart açılır**; oyuncu görünen profiller arasından seçim yapar. Sözleşme uzatma teklifi yoktur. **Dördüncü kartı açmak oyun parası veya gerçek paradan biriyle ödenir**. Dördüncü kart rastgele gelir, fakat oyuncunun eksik yetkinliğini kapatan bir karta denk gelme olasılığı normal çekilişe göre **10 yüzde puan daha yüksektir** (ör. %30 yerine %40). Oyuncu bir kez daha ödeme yapıp **beşinci çekimi** yapabilir; gelen kart dördüncü kartın **yerini alır**, ayrı bir beşinci yer açılmaz. Bir ayda en fazla **iki ücretli çekim** yapılır; daha fazla yeniden çekim yoktur. Beşinci çekimin ağırlığı ve iki çekimin fiyatları ayrıca belirlenecektir. Önceki taslaktaki **Satış** örneği, mevcut on yetkinlik arasında olmadığı için çıkarıldı; satış/talep tasarımı ayrı konu olarak ele alınabilir.

Kartın listelediği her alan **en az 25, en fazla 100** puandır. **Kartın toplam puanı ≤ listelenen alan sayısı × 60**. Örnek: beş alanlı kartın bütçesi en fazla 300'dür; iki alan 25'er puansa kalan üç alana toplam 250 puan dağıtılabilir (ör. **25 + 25 + 83 + 83 + 84 = 300**). İki alanlı kartta bütçe 120 olduğu için bir alanın 100 olması, diğer alanın en az 25 olma şartıyla mümkün değildir; iki alanlı üst sınır örneği **95 + 25 = 120**. 100 puanlık uzmanlık en az üç alanlı profilde mümkündür. Bu sonuçlar önerilen üç kuralın matematiksel sonucudur.

Bir kartta **iki alanın 100 olması da mümkündür**: beş alanlı **100 + 100 + 50 + 25 + 25 = 300** kartı bütçe kuralını karşılar. Böyle güçlü profiller çok nadir ve çok pahalı olmalıdır. Kart başına “90+ en fazla bir alan” sınırı konmaz. Havuzda birlikte on alanı kapsayan iki kart bulunması da yasaklanmaz; kapsam, derin sorunların tamamında kesin çözüm anlamına gelmez.

Danışmanların ilgili alan puanı **100'e ulaşabilir**; 90'lık sabit üst sınır yoktur. En güçlü profiller nadir ve pahalı olmalıdır; ücret özellikle kartın **en yüksek iki alan puanına ağırlık vererek** hızla artar. Böylece iki alanı 100 olan kart gerçekten pahalı olur; düşük puanlı dolgu alanlar fiyatı yapay biçimde ucuzlatmaz. Oyuncu kendi kariyerinde öğrenmediği en derin sorunu da danışman aracılığıyla kesin çözebilir, ama bunu sürekli yapmak ağır bir oyun içi maliyet doğurur. Kesin fiyat formülü, güçlü kartların havuzdaki sayısı ve küçük fabrika kârına göre maliyet dengesi açık karardır.

Danışman **belirli süreli sözleşmeyle** tutulur ve işe alındığı anda başlar; profilindeki bütün alanlar sözleşme boyunca aktiftir. **Aynı anda en fazla iki danışman** aktif olabilir. Örnek fiyatlama: o danışmanın bir aylık ücreti **A** ise 3 ay **2,75A**, 12 ay **10A**. Süreler ve çarpanlar bağlayıcılık/indirim fikrini gösteren taslak değerlerdir. Ödenen sözleşme ücreti, danışman erken bırakılırsa da iade edilmez. İki danışman aynı anda çalışsa bile ilgili alanda **etkin yetkinlik = max(patronun puanı, aktif danışmanların o alandaki puanları)**; puanlar birbirine eklenmez ve 100'ü aşmaz. Etkin değer sorunun eşiğine ulaşırsa kök neden görünür ve “Düzelt” kesin başarı verir. Danışman ayrılınca patronun kalıcı puanı artmış sayılmaz.

Danışman sözleşmesi oyun parası **veya** gerçek paradan biriyle ödenebilir; ikisi birden istenmez. Aynı danışman teklifine oyun parasıyla da erişilebilmelidir; gerçek para ödemesi sorunu çözmek için zorunlu hale gelmez. Ay sonu kart açılışı dışında ek bekleme yoktur; danışman hemen göreve başlar. Sürekli danışman tutmanın kariyer deneyimini değersizleştirmemesi için fiyatlar, dördüncü kart açma bedeli ve gelir dengesi sınanmalıdır. Ek kartın gerçek parayla açılması ücretli arama avantajı doğurduğu için monetizasyon incelemesinde özellikle değerlendirilmelidir.

Küçük veya nakdi sıkışık fabrikanın sürekli danışman tutması zor olmalıdır; bunun ne ölçüde doğal nakit akışından doğacağı test edilmelidir. Prestijli danışmanların firma ölçeğine göre aday havuzundan çıkması beyin fırtınası önerisidir, kullanıcı kararı değildir. Danışmanın analiz edip ayrıca uygulanıp uygulanmayacağına karar verilen ikinci bir eylem, sözleşme uzatma ve uyum/güven statı bu sürümün mekaniğine eklenmez.

### Tasarım İlkesi

Mükemmel patron her şeyi kendisi yapan kişi değildir.

Neyi bildiğini bilir.
Neyi bilmediğini bilir.
Bilmediği işi kime bırakacağını bilir.

“Düzelt” sade bir operasyon eylemidir; fabrika döneminin stratejisi danışman seçimi, personel sonuçları, bütçe, zaman ve diğer yönetim kararlarında kurulmalıdır. Bu sistemlerin kapsamı ayrıca tasarlanacaktır.

## Notlar (Claude)

Tarihçe: Tur 1 inceleme [REV-001](../reviews/REV-001_claude_patron_yetkinlikleri.md) ve bu dosyanın Git geçmişi. Aşağıdakiler Tur 9 `Öneri (GPT)` metninin incelemesidir. `Karar Özeti`'ndeki kullanıcı yönlendirmeleri (gerçek parayla ödeme seçeneği dahil) tartışmaya açılmamış; notlar bu yönlendirmelerin vizyon belgesiyle uyumunu, uygulama risklerini ve kalan açıkları hedefler.

### Aldığım Notlar

- Tur 8'in iki gerekçe düzeltmesi yapıldı: üç etiketin "yakın açığı sezdirir, derin açığı gizler" niteliği ve kart bütçesinde dengenin fiyat ve nadirlikle kurulduğu artık Karar Özeti'nde doğru yazıyor. Fiyatın en yüksek iki puana ağırlık vermesi dolgu alan sorununu kapattı.
- İnsan Yönetimi paketi tamamlandı: yaklaşık %80 azaltma tavanı, kişi kaynaklı sorunlar için yaklaşık %30–40 pay ve kendi alan sorunları. Danışman kartındaki İnsan Yönetimi puanı artık boşta kalmıyor.
- Her sorunun kendi kartı ve kendi "Düzelt" butonu, Tur 3'ten beri açık olan "Düzelt neyi hedefliyor?" sorusunu en sade biçimde kapattı.
- Eksik yetkinliği kapatma listesi netleşti: danışman listeden çıktı, ortaklık ayrı IDEA, dış kaynak "henüz konuşulmadı" diye işaretlendi. FREEZE'in tanımsız sistemleri onaylama riski kalmadı.
- "FREEZE öncesi" grubundaki ilkelerin çoğu kapandı. Açık Kararlar'da ilkesi kapanıp yalnızca testi kalan üç maddeyi (etiket eşlemesi, kart bütçesi gösterimi, İnsan Yönetimi hedefleri) maddeleri silmeden "Denge ve test" grubuna taşıdım.

### Bulduğum Sakıncalar

- **Gerçek parayla danışman sözleşmesi GAME_OVERVIEW §26 ile gerilim yaratıyor (kritik):** §26'nın temel ilkesi "oyuncunun bilgisizliğini yapay şekilde cezalandırıp çözümü gerçek paraya satmamak". §11 de gerçek paranın oyunun yarattığı sorunların zorunlu çözümü olmamasını istiyor. Danışman tam olarak bilgi açığını kapatan araç. Üstelik kariyer yetkinliğinin değerli kalması için danışmanın oyun içinde **pahalı** olması gerekiyor (REV-001 C2'den beri tüm dengenin dayanağı bu). Pahalı bir oyun içi seçenek ile yanında duran gerçek para seçeneği birleşince, gerçek para kâğıt üzerinde zorunlu olmasa da pratikte bilgi açığının "hızlı yolu" olur. Kariyer dengesi ile monetizasyon aynı kaldıraca bağlanmış oluyor: danışman oyun içinde ne kadar pahalıysa gerçek para o kadar cazip. Proje kuralı gereği bu, vizyon belgesiyle bir tutarsızlık olarak kullanıcıya bildirilmeli. Kullanıcı kararını koruyarak önerilen korkuluklar:
  - Gerçek parayla ödenen sözleşme, oyun parası karşılığından hiçbir koşulda avantajlı olmasın (aynı kart, aynı süre, aynı etki).
  - Ölçülebilir bir "oyun parasıyla erişim" hedefi yazılsın: tipik küçük fabrikada, ihtiyaç duyulan bir danışmana oyun parasıyla makul bir sürede (ör. 1–2 ay kârı) erişilebilmeli.
  - İflas sonrası borçlu dönemde gerçek parayla danışman tutmanın, iflasın kalıcı bedelini (borç + zaman) fiilen satın almaya dönüşmediği ayrıca sınansın.
- **Gerçek parayla rastgele kart açmak ücretli çekiliş sayılabilir (uygulama riski):** Dördüncü kart rastgele ve gerçek parayla açılabiliyor. Bu, ücretli rastgele ödül mekanizmasıdır. Mağaza kuralları (App Store / Google Play) bu tür öğelerde olasılıkların açıklanmasını istiyor; bazı ülkelerde (ör. Belçika) ücretli rastgele ödüller kısıtlı veya yasak. "Daha fazla kart açılabilir mi?" sorusu da evet olursa mekanizma sınırsız ücretli çekilişe dönüşür. Öneri: gerçek parayla açılan ek kart rastgele olmasın; oyuncu bir alan seçsin ve o alanı içeren bir kart gelsin. Ya da ek kart yalnızca oyun parasıyla açılsın. Kesin durum hukuki değerlendirme ister.
- **Yeniden görünen aktif kart çekiliş hakkını boşa harcıyor:** İki aktif danışman ve 10–15 kartlık havuzla, ayda üç çekilişten birinin zaten sözleşmesi süren bir karta denk gelmesi sık olur. Karar Özeti bunu mekanizmanın sonucu olarak kabul ediyor, ama kart o haliyle oyuncuya bir şey sunmuyor. Öneri: yeniden görünen aktif kart **sözleşme uzatma teklifi** olarak gelsin (ör. mevcut sözleşmenin sonuna eklenen süre). Böylece boşa giden çekiliş anlamlı bir seçeneğe dönüşür ve Tur 9'da açık bırakılan "ikinci teklif nasıl birleşir?" sorusu da kapanır.

### Kafama Yatmayanlar

- **Ayrı sorun kartları gizli sorunların sayısını ele veriyor:** Kök neden gizli olsa da her gizli sorun ayrı kart olunca bilgisiz patron bile "bu departmanda üç gizli sorun var, biri yüksek şanslı" bilgisine sahip oluyor. Bu, "neyi bilmediğini bilir" ilkesiyle uyumlu ve arayüzü sadeleştiriyor; bilinçli kabul edilmesi öneriliyor. Ancak GAME_OVERVIEW §9'daki tek, toplu "açıklanamayan kayıp" sinyali fikri fiilen değişti. FREEZE sonrası vizyon belgesi güncellenmeli.
- **Karar Özeti'ndeki bir gerekçe mekanizmayı tekrar ediyor:** "Sözleşmesi süren danışman sonraki ay yeniden aday olabilir; çünkü sabit kart havuzundan çekiliş aktif kartları otomatik dışlamaz" maddesi *ne olduğunu* söylüyor, *neden* seçildiğini söylemiyor. Proje kuralı gerekçe istiyor. Uzatma teklifi önerisi kabul edilirse gerekçe doğal olarak "oyuncu çalışan danışmanın sözleşmesini uzatabilmeli" olur.
- **Terimler:** "Tier" hâlâ hem patron hem sorun için kullanılıyor. Codex bunun yalnızca terim önerisi olduğunu doğru not etmiş. FREEZE metni yazılmadan önce evet/hayır ile kapanmalı.

### Açık Sorular

Tur 10'dan önce kullanıcının karar vermesi önerilen üç konu:

1. **Gerçek para ve danışman sözleşmesi (§26 ile gerilim):** Hangisi?
   - (a) Sözleşme yalnızca oyun parasıyla; gerçek para yalnızca ek kart için (Claude önerisi).
   - (b) Mevcut karar korunur, ama korkuluklar eklenir: gerçek para hiçbir koşulda avantajlı olmaz, "oyun parasıyla 1–2 aylık kârla erişim" hedefi yazılır, iflas dönemi ayrıca sınanır.
   - (c) Mevcut hali, korkuluk eklenmeden.
2. **Gerçek parayla ek kart:** Rastgele kalsın mı, yoksa oyuncunun seçtiği alanı içeren kart mı gelsin (Claude önerisi)? Beşinci ve sonraki kartlar gerçek parayla açılabilsin mi?
3. **Küçük onaylar:** Yeniden görünen aktif kart uzatma teklifi olarak gelsin mi? Terimler "Görüş Seviyesi" / "Sorun Derinliği" olsun mu? Ayrı sorun kartlarının gizli sorun sayısını göstermesi bilinçli kabul ediliyor mu?

Bu üç kararla "FREEZE öncesi" grubu kapanır ve kullanıcı onayıyla FRZ-001 taslağına geçilebilir.

## Açık Kararlar

### FREEZE öncesi kapanması önerilenler (ilke düzeyinde)

- Danışman sözleşmesi ve dördüncü kartın oyun parası / gerçek para fiyat dengesi; aynı teklifin oyun parasıyla erişilebilirliği ve ücretli rastgele dördüncü kartın uygulama/mevzuat incelemesi. Claude notu: gerçek parayla danışman sözleşmesi GAME_OVERVIEW §26 ve §11 ile gerilim yaratıyor. Kullanıcının iki ödeme seçeneği ve rastgele dördüncü kart kararı korunur; oyun parasıyla makul erişim hedefi, gerçek para fiyatlandırması ve iflas dönemi etkisi henüz kapanmadı.
- Dördüncü kart için eksik yetkinliği kapatma ölçütünün kesin tanımı, +10 yüzde puanlık ağırlığın sabit havuzda nasıl uygulanacağı, beşinci çekimde bu ağırlığın sürüp sürmeyeceği, iki para birimindeki fiyatlar ve aynı kartın tekrar çıkma kuralı. Ayda en fazla iki ücretli çekim vardır; beşinci çekim dördüncü yerin kartını değiştirir. Aktif danışmanlar aylık aday havuzuna girmez; uzatma teklifi yoktur.
- Her sorun kartında kök neden gizliyken hangi belirti ve kayıp bilgisinin gösterileceği. Görünür bağlı sorunların ortak kökü ipuçlarından tahmin edilebilir; gizli sorunlar bağımsız kök taşır. Bağlı kartların maliyeti farklıyken en ucuz karta basmanın baskın stratejiye dönüşüp dönüşmeyeceği Claude tarafından incelenecek.

### Denge parametreleri ve testle kesinleşecekler

- Üç sözel başarı düzeyinin kesin olasılıklarla eşleşmesi ve oyuncuya yeterince anlaşılır geri bildirim vermesi; %80 yüksek / %40 orta / %15–5 düşük taslak eşlemedir. Üç etiket yakın açığı kısmen sezdirir, derin açığı gizler. (Claude notu: ilke Karar Özeti'nde kapandı; yalnızca eşleme testi kaldı.)
- Kart puan bütçesinin oyuncuya nasıl gösterileceği ve iki tane 100 puan içeren kartın nadirlik/fiyat dengesi; fiyat kartın en yüksek iki puanına ağırlık verir, kesin formül testle belirlenecek. (Claude notu: ilke Karar Özeti'nde kapandı.)
- İnsan Yönetimi alanındaki özgül sorunların içeriği, kaynak türü etiketleri ve %80 azaltma / %30–40 kişi kaynaklı sorun payı hedeflerinin testle ayarlanması. Yatay sıklık etkisi yalnızca patronun kalıcı puanına bağlıdır. (Claude notu: ilke Karar Özeti'nde kapandı.)
- “Düzelt”in kök nedenin gerektirdiği işe dayanan para maliyeti, kartların yakın maliyet aralığı, aylık patron zamanı ve danışmanın zaman tasarrufu.
- Kabul edilen taslak kademe eğrisinin (≈ %80 / %40 / %15 / %5) oyun testlerinde ayarlanması; Tier içinde farklı puanların aynı şansa sahip olmasının uygunluğu.
- Ayda bir fabrika geneli “Düzelt” hakkının sorun sayısı ve fabrika ölçeği arttığında dengeye etkisi; sonraki ay tekrar denemenin aynı mı, artan mı para maliyeti taşıyacağı.
- Kart havuzunun kesin büyüklüğü (10–15), her ayki 3 kartın seçim yöntemi, güçlü kartların nadirliği; havuzun ezberlenmesine karşı puan varyasyonu veya büyüyen havuz.
- Kesin fiyat formülü ve 1/3/12 ay için A/2,75A/10A örneklerinin kesinleşmesi.
- Uzun süreli çok alanlı danışmanların baskın strateji olup olmadığı; yıllık danışman maliyetinin küçük fabrika net kârına oranı ve kariyer yetkinliğinin değeri.
- İki aktif danışman ve alan sayısı × 60 bütçesinin dengede kariyer yatırımını koruyup korumadığı; iki kartla kapsanabilen en geniş alan kümesi.
- İnsan Yönetimi'nin kişi kaynaklı sorun sıklığını ne kadar azalttığı ve aylık performans raporlarına nasıl yansıdığı.
- Oyun içi açıklanamayan kayıp sinyalinin hesap tanımı ve netlik eşikleri; her sorunun ayrı kartta gösteriminin UI yükü; fabrika başarısızlık raporunun ayrıntı düzeyi ve ara dönem (yıllık) özet olup olmayacağı.
- Kişi kaynaklı sorunda “Düzelt”in hangi sonucu ve maliyeti ürettiğinin oyuncuya nasıl anlatılacağı; ayrı müdür karakteri veya eylemi açılmaz.
- Sorun ertelendiğinde kaybın büyüme hızı.
- İflas borcunun miktarı ve yaklaşık bir oyun yılında toparlanmanın denge hedefi olup olmayacağı; psikoloji düşüşünün süresi ve toparlanma hızı. Claude önerisi: psikoloji belirli sürede kendiliğinden toparlanır, borç ödemesi gelire oranlanır (açık).
- “Acı tecrübe” artışının kesin büyüklüğü ve üst sınırı; karakter başına tek seferlik verilmesinin denge testi.
- Yetkinlik Tier eşikleri (T4–T5 arasındaki 10 puanlık aralığın kademe eğrisiyle birlikte yeniden değerlendirilmesi dahil), kazanılma hızı, düşüşü ve beşinci yıl hedefi.
- Departman başına eşzamanlı problem sayısı.
- Ulaşılabilir performans ve kârın makine, ürün, talep ve giderlere göre nasıl hesaplanacağı; sorun kayıplarının toplamı, bağlı etkilerin iki kez sayılmaması ve bir müdahalenin farklı satırlara etkisi.
- Statların öğrenme hızına vereceği azami bonus.

### Ayrı IDEA veya FREEZE sonrası işler

- Ortaklık ayrı IDEA'da; dış kaynak, iyi ekip, uzman çalışan ve eğitim henüz tasarlanmamış olası yollar olarak kalır. FREEZE'e onaylı mekanik olarak girmezler.
- Satış/talep konusunun ayrı IDEA olarak ele alınması ve mevcut on yetkinlik listesine etkisi.
- Ekip/personel (müdür) sisteminin ayrı IDEA'da tasarlanması.
- Doğru personeli seçme, müdürün işe alışma süresi ve ücret/etki dengesi ayrı personel IDEA'sında; bu IDEA'da müdür için ayrı puan veya eylem açılmaz.
- `GAME_OVERVIEW` §10'daki müdür modelinin ve §5–6, §25'teki "run" dilinin bu IDEA ile uyumlandırılması (FREEZE sonrası).
- `GAME_OVERVIEW` §9'daki toplu "açıklanamayan kayıp" sinyalinin sorun kartı modeline, §11 ve §26'daki monetizasyon dilinin kullanıcının gerçek para kararına göre güncellenmesi (FREEZE sonrası).
- Oyunun süresi ve bitiş koşulu; iflastan sonraki sermaye/borç durumu. Claude önerisi: çekirdek oyun döngüsü IDEA'sına taşınır (açık).
- Karakterin yaşlanması ve doğal ölümü; aynı karakterle iflas sonrası devam kuralının ömür sınırıyla ilişkisi ayrı çekirdek döngü IDEA'sında tasarlanır. Başlangıç yaşı ve ölüm zamanlaması bu IDEA'nın kararı değildir.
- Firma ölçeğine göre danışman havuzu/prestij kısıtı ve teorik fabrika kârı modeli ayrı ekonomi tasarımında değerlendirilecek beyin fırtınası önerileridir; henüz kullanıcı kararı değildir.
- Fabrika dönemindeki stratejik derinliğin “Düzelt” dışında hangi sistemlerden geleceği.

## Karar Özeti

Kullanıcının yönlendirmeleri (IDEA düzeyinde; henüz FREEZE değil):

- “Düzelt” butonu yetkinlikten bağımsız açık kalır, her deneme para ve zaman harcar; çünkü sorun çözümü ek efor veya mini oyun gerektirmemeli.
- Yetkinlik Tier eşiğine ulaşıyorsa sorun kesin çözülür; ulaşmıyorsa başarı olasılığı yetkinliğe bağlıdır (60/70 için yaklaşık %80 hedefi); çünkü bilgi açığı çözmeyi imkânsız değil, riskli kılmalı.
- Yetkinlik bilgi modeli olarak öncelikle kök neden görünürlüğünü belirler; çünkü seçenek kilitlemek yerine oyuncunun neyi bildiği öne çıkmalı.
- Fabrika batınca aynı karakter devam eder; çünkü başarısızlık sonraki girişime ders taşımalı.
- Ay sonunda 10–15 sabit profilden rastgele 3 danışman kartı açılır, dördüncü kart oyun parası veya gerçek parayla açılır; çünkü oyuncu rapordan sonra seçim yapmalı ve ek kart için ödeme yolu seçebilmeli.
- Her danışman 2–5 alandaki görünür puanıyla fiyatlanır; çünkü farklı bilgi açıkları ve bütçeler için seçenekler olmalı.
- Danışman sözleşmesi süreli ve bütün profil alanları boyunca aktiftir; çünkü oyuncu tek alanlık kısa görev yerine kapsamlı bir danışman seçip süreye bağlanmak istiyor.
- Etkin yetkinlik patron ve aktif danışman puanlarının en yükseğidir, toplama değildir; çünkü çok danışman tutmak 100 üstü puan veya sınırsız güç üretmemeli.
- Aynı anda en fazla iki danışman aktiftir; çünkü tüm alanları sürekli dış destekle kapatmak kariyer yetkinliğinin değerini azaltır.
- Kartta 2–5 alan bulunur, her biri 25–100 puandır ve toplamları alan sayısı × 60'ı aşmaz; çünkü danışman profillerinin puan bütçesi tanımlı olmalı, geniş kartların dengesi ise fiyat ve nadirlikle sağlanmalı.
- Aynı kartta iki ayrı alan 100 puan olabilir ama böyle kartlar çok nadir ve pahalıdır; çünkü kullanıcı güçlü danışman seçeneklerini mümkün tutmak istiyor.
- Danışman puanı 100'e ulaşabilir ve yüksek puan pahalı/nadir olur; çünkü öğrenilmemiş en derin sorun da danışmanla çözülebilmeli ama sürekli dış destek maliyetli olmalı.
- Danışman sözleşme imzalanınca hemen başlar ve ödenen ücret iade edilmez; çünkü oyuncu ay sonu raporundan sonra hemen harekete geçebilmeli, uzun sözleşmenin indirimine de bağlanmalı.
- Etkin yetkinlik eşiğe ulaştığında “Düzelt” kesin sonuç verir; çünkü danışman tutmanın kör denemeye göre somut faydası olmalı.
- Eşik altı başarı ihtimali kademe farkına göre yaklaşık %80 / %40 / %15 / %5 düşer; çünkü derin bilgi açığında kör deneme anlamlı risk taşımalı.
- İflas sonrası karakter borçla ve daha düşük psikolojiyle devam eder; çünkü kayıp hissedilmeli ama toparlanma mümkün olmalı, borç süresi ve yaklaşık %25 psikoloji farkı henüz örnektir.
- İflas yetkinlik kaybettirmez veya genel stat kazanımını hızlandırmaz; bunun yerine karakter başına tek seferlik sınırlı “acı tecrübe” kazandırır, çünkü başarısızlık öğretmeli ve kasıtlı iflas ödül döngüsüne dönüşmemeli.
- “Düzelt” gereken personel işlemlerini de kapsar ve ayrı müdür yetkinliği tanımlanmaz; çünkü oyuncunun yönetim bilgisi İnsan Yönetimi yetkinliği ve aylık sonuçlarda temsil edilmeli.
- İnsan Yönetimi yükseldikçe kişi kaynaklı sorunların sıklığı azalır; çünkü bu yetkinliğin aylık personel sonuçlarında somut karşılığı olmalı.
- İnsan Yönetimi için %50 azaltma tavanı reddedildi, daha güçlü etki önerilecek; çünkü oyuncunun bu yetkinliğe zaman ayırması anlamlı olmalı, kesin oran henüz açık.
- Statlar eşik altı “Düzelt” şansını artırmaz ve gizli sorunlarda şans kaba aralıkla gösterilir; çünkü kariyer bilgisi statla aşılamamalı ve kesin yüzde gizli Tier'ı ele vermemeli.
- Her sorun kendi “Düzelt” butonunu ve yüksek/orta/düşük şans etiketini taşır; çünkü oyuncu hangi soruna müdahale ettiğini ve riskini kart üzerinde görmeli, üç etiket yakın açığı kısmen sezdirirken derin açığı gizler.
- Kişi kaynaklı sorunların sıklığını yalnızca patronun kalıcı İnsan Yönetimi puanı azaltır; çünkü danışman bu yatay kariyer yatırımının yerini almamalı.
- İki danışman kartının birleşince on alanı kapsaması yasaklanmaz; çünkü kapsam tek başına derin sorunlarda kesin çözüm sağlamaz, geniş kartların dengesi fiyat ve nadirlikle kurulmalı.
- Sözleşmesi süren danışman aylık aday havuzuna girmez ve uzatma teklifi yapılmaz; çünkü aktif bir kartın yeniden sunulması seçim hakkını boşa harcar ve uzatma gereksiz ayrıntı ekler.
- Dördüncü kart rastgele kalır ve eksik yetkinliği kapatma olasılığı normal çekilişten 10 yüzde puan yüksek olur; çünkü ücretli seçimde oyuncuya daha yararlı bir aday şansı verilmeli.
- Ayda en fazla iki ücretli danışman çekimi yapılır ve beşinci çekim dördüncü kartın yerini alır; çünkü oyuncu bir kez yeniden deneyebilmeli ama sınırsız kart çevirip en iyi adayı garantilememeli.
- Patronun yetkinlikle eriştiği kademe “Görüş Seviyesi”, sorunun eşik kademesi “Sorun Derinliği” adını alır; çünkü iki kavramı karıştırmadan anlatmak gerekir ve bu adlar yeni mekanik yaratmaz.
- Danışman sözleşmesi oyun parası veya gerçek parayla ödenebilir; çünkü oyuncuya iki ödeme seçeneği sunulurken gerçek para zorunlu olmamalı.
- Danışman fiyatında en yüksek iki alan puanı daha ağır basar; çünkü iki zirve uzmanlığı olan kart ciddi bir bedel taşımalı.
- İnsan Yönetimi yaklaşık %80'e kadar kişi kaynaklı sorunları azaltır, kendi alan sorunları da vardır ve kişi kaynaklı sorunlar toplamın yaklaşık %30–40'ıdır; çünkü bu yetkinlik güçlü ama diğer alanların yerini almayan bir yatırım olmalı.
- Ayrı müdür/ekip mekaniği IDEA-001'in kapsamı dışındadır ve daha sonra tasarlanabilir; çünkü bugünkü basit “Düzelt” akışı gelecekte ekip kararlarını kapatmamalı.
- Fabrika genelinde ayda yalnızca bir “Düzelt” denemesi yapılır ve başarısız deneme de hakkı tüketir; çünkü kör deneme para, zaman ve ertelenen kayıp açısından gerçek risk taşımalı.
- Danışman olsa da her sorun kartında yalnızca tek “Düzelt” bulunur ve başarı hesabı max(patron, aktif danışmanlar) ile yapılır; çünkü danışman desteği ayrı bir karar menüsü yaratmadan yetkinlik açığını kapatmalı.
- Danışman aynı kök nedeni gidermenin oyun parası maliyetini değiştirmez, patron zamanını azaltır; çünkü sözleşme ücreti ayrıca ödenmiştir ve analiz yükünü danışman üstlenir.
- Aynı görünür köke bağlı satırlardan birinin başarıyla düzeltilmesi hepsini kapatır; çünkü tek müdahale ortak nedeni ortadan kaldırır ve satırların kayıpları birlikte geri kazanılır.
- Departman performansı, sorun satırlarının kayıpları düşülerek açıklanır (örneğin %100 − %5 − %15 − %10 − %10 = %60); çünkü oyuncu rapordaki eksik performansı somut nedenlerle ilişkilendirebilmeli.
- Gizli sorunlar başka sorunlarla ortak kök nedeni paylaşmaz ve görünür düşük derinlikli sorun üzerinden çözülmez; çünkü bilinmeyen derin problem kolay bir belirtiye basılarak aşılmamalı.
- Kök nedeni gidermenin para maliyeti kayıp yüzdesine göre belirlenmez ve sorun kartlarının bedelleri genel olarak yakın ama özdeş değildir; çünkü oyuncu bağlantıyı yalnızca fiyat eşitliğinden öğrenmemeli.
- Kartlarda çözüm ihtimali yüksek/orta/düşük olarak üç düzeyde gösterilir; çünkü kaba risk bilgisi verilirken gizli derinlik tam açıklanmamalı.
