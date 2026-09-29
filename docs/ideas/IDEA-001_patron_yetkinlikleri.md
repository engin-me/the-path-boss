# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: DRAFT — Tur 12 GPT sentezi hazır, Claude incelemesi bekleniyor
Tur: 12
Son güncelleme: 2026-09-29
Kaynak: Kullanıcının ilk önerisi, sonraki kararları ve 2026-09-28 tarihli beyin fırtınası notlarından seçilen fikirler.
Tur 1–11 Claude incelemeleri tamamlandı. `Notlar (Claude)` Tur 11 incelemesidir ve Claude'un metni olarak korunur. Kullanıcı, ortak kökün derinliğinin bağlı satırların en derini olmasını, bağlantının aynı departmanda en fazla iki Tier aralığını kapsamasını ve erişilemeyen sorunların adsız satırlarda gösterilmesini seçti.
Sıradaki adım: Claude Tur 12 önerisini aynı dosyada inceler; özellikle tahmini/gerçek maliyet, kök düzeyinde aylık tekrar kilidi ve departman kaybı hesabındaki açıkları değerlendirir. FREEZE için ayrıca kullanıcı onayı gerekir.

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

Eşikler taslak değerlerdir; çözüm döngüsü sınanmadan kesinleşmez. Patronun ilgili alandaki **tek bir 0–100 yetkinlik puanı** vardır; ayrıca “Görüş Seviyesi” veya “Yetkinlik Seviyesi” diye ikinci bir puan tutulmaz. Her sorunun T1–T5 arasında kendi Tier'i ve yetkinlik eşiği vardır. Etkin yetkinlik **satırın** eşiğine ulaşıyorsa o satırın belirtisi/konusu görünür; **ortak kökün en derin Tier eşiğine** ulaşıyorsa bağlantı ve kök neden de teşhis edilebilir, “Düzelt” kesin sonuç verir. Altındaysa neden veya bağlantı gizli kalabilir ve “Düzelt” olasılıkla denenebilir. **T2 eşiği taslaktaki 50 olarak kalır**; 20/50/30 gibi sayılar yetkinlik eşiği değil kayıp birimleridir.

Örnek:

Satın Alma performansı düşüktür.

- T1: Fiyatlar piyasanın üzerinde
- T2: Tedarikçi termin performansı kötü
- T3: Tek tedarikçiye aşırı bağımlılık
- T4: Satın alma sürecinde belirli tedarikçiler sistematik olarak kayrılıyor
- T5: Tedarik kararlarında gizli çıkar çatışması veya usulsüz ödeme var

Satın Alma yetkinliği 70 olan patronun karşısına çıkan T1–T3 sorunları Tier adlarıyla görünür. T4 veya T5 sorunu varsa ayrı birer **“Derinlik bilinmiyor”** satırında kaybı görünür, nedeni ve Tier adı gizli kalır. İlgili alanda yeterli danışman yetkinliği varsa etkin değer yükselir ve o satırlar kendi Tier adlarıyla açılır. Bu liste olası sorun içeriklerini örnekler; beşinin aynı anda var olduğu anlamına gelmez.

### Sorun Çözüm Döngüsü

Önerilen aylık fabrika akışı: **ay sonu raporu → her departmanın kartı → gerekirse danışman seçimi → ilgili satırda “Düzelt” → para ve patron zamanı harcaması → sonuç**. Her departmanın modelinde **tam beş Tier yuvası** vardır; aynı Tier'de ikinci sorun oluşmaz. Oyuncu kartta beş satır görür: eriştiği Tier'ler T1…Tk adıyla, erişemediği dolu Tier yuvaları **“Derinlik bilinmiyor”** başlığı altında ayrı adsız ve sırasız satırlar olarak, boş yuvalar **“–”** olarak görünür. Gizli dolu satır kendi kayıp miktarını, tek “Düzelt” butonunu ve sözel başarı ihtimalini gösterir; kök neden veya gerçek Tier adı görünmez. Danışman ilgili alandaki etkin yetkinliği yükselttiğinde o satırın Tier'i ve uygun bilgisi açılır; ikinci eylem açılmaz. **Aynı soruna ayda en fazla bir kez müdahale edilir; fabrika genelinde tek müdahale sınırı yoktur.** Farklı sorunlara müdahale sayısını para ve aylık patron zamanı sınırlar. Başarısız denemede para ve zaman harcanır, aynı sorun sonraki ay yeniden denenebilir. Mini oyun veya ayrı müdahale menüsü yoktur.

Etkin yetkinlik sorunun kök nedeninin eşiğine ulaşıyorsa “Düzelt” kesin sonuç verir; eşiğin altındaysa para ve zaman harcanıp başarı için olasılık hesabı yapılır. Örnek: Planlama puanı 20 olan patron ve Planlama puanı 80 olan aktif danışman için etkin değer **max(20, 80) = 80** olur; 70 eşikli Planlama sorunu kesin çözülür. Danışman tutmak tek başına sorunu ortadan kaldırmaz; oyuncu yine “Düzelt”e basar. Eski **20 + 50 = 70** örneği artık geçerli değildir: max(20, 50) = 50, dolayısıyla o sorunda olasılık hesabı yapılır. Danışman varlığı sorunu gidermek için gereken **oyun parası maliyetini değiştirmez**; danışmanın bedeli sözleşmede ödenir. Danışman, analiz yükünü üstlenerek gereken **patron zamanını azaltır**. Kesin zaman tasarrufu denge parametresidir.

Tek bir tutarlı örnek için fabrikanın beklenen çıktısı **100 birim**, Planlama kaynaklı kaybı **10 birim** olsun. Planlama'nın gerçek satırları T1: –, T2: **2**, T3: **5**, T4: **3**, T5: – birimdir. **Planlama yetkinliği 60** olan patron T2'yi 50 eşiğiyle tanır; kartında T1: –, T2: 2, “Derinlik bilinmiyor”: 5, “Derinlik bilinmiyor”: 3 ve gizli boş yuva: – görür. Gizli iki satırın T3 ve T4 olduğunu ve sırasını öğrenmez. T2 bağımsız kökse kesin çözer; başka, daha derin bir satırla bağlıysa başarı o ortak kökün derinliğine göre hesaplanır. İlgili alanda **90 puanlık** aktif danışman T3 ile T4'ü de açar ve patron zamanını azaltır; patronun kalıcı puanı 60 kalır.

**Farklı Tier satırları aynı kök nedene bağlanabilir; bağlantı yalnızca aynı departmanda ve en fazla iki Tier kademe aralığında kurulur.** Örneğin T1–T3, T2–T4 veya T3–T5 mümkündür; T1–T5 mümkün değildir. Kökün derinliği **bağlı satırların en derin Tier'i** olur. Oyuncu hangi bağlı satırda “Düzelt”e basarsa bassın başarı ihtimali ve gerçek para maliyeti köke göre hesaplanır; başarı bütün bağlı satırları kapatır. Bu nedenle görünür T2'ye basmak gizli bağlı T4'ü kesin veya ucuz biçimde aşmaz: patron yetkinliği 60 ise T4 kökü için iki kademe eksik taslak başarı ihtimali ≈ %40'tır. Böylece önceki “gizli satır görünür satırla bağlanmaz” yasağı kalkar; yasağın amacı olan kolay Tier üzerinden derin sorunu garantili çözmeme korunur. Etkin yetkinlik kökün en derin eşiğine ulaşınca bağlantı teşhis edilebilir. Satırda belirtiden hareketle tahmini müdahale bedeli görünebilir; tahsil edilen oyun parası kökün gerçek çözüm maliyetine bağlıdır. Ödeme öncesi maliyet açıklaması ve başarısız kök denemesinde bağlı satırların aynı ay kilitlenip bağlantıyı ne ölçüde ifşa edeceği açık kararlardır.

“Düzelt”, sorunun gerektirdiği işlemin yapılmış olmasıdır; kişi kaynaklı sorunda konuşma, yaptırım veya işten çıkarma gibi sonucu da kapsayabilir. Oyuncu için ayrıca müdür kovma zinciri veya her soruna özel eylem menüsü açılmaz. Hangi işlemin gerçekleştiği sonuç metninde anlatılabilir; buna ayrı bir müdür karakteri veya müdür yetkinliği gerekmez.

Eşik altı olasılığı **etkin yetkinlik ile kökün en derin Tier'i arasındaki kademe farkına** göre düşer. Kabul edilen taslak denge: bir kademe eksik ≈ %80, iki kademe ≈ %40, üç kademe ≈ %15, dört veya daha fazla kademe ≈ %5. Örneğin 60/70 bir kademe farktır ve yaklaşık %80 başarı verir. Rakamlar oyun testleriyle ayarlanabilir; eşikler henüz FREEZE değildir. Sorunlu satırda olasılık yüzde yerine **yüksek / orta / düşük** yazılır; ≈ %80 yüksek, ≈ %40 orta, ≈ %15 ve ≈ %5 düşük taslak eşlemedir. Erişilemeyen satırın Tier adı görünmediği için üç etiket riski kabaca anlatırken derinliği tam ifşa etmez. Aynı kökü sonraki ay yeniden denemenin para maliyeti açık denge kararıdır.

Bu akışta yetkinlik, hangi eyleme basılabileceğinden çok **neyin yanlış gittiğini bilme** ve bilinmeyen sorunu çözme şansıyla ilgilidir. Aynı soruna aylık tek deneme ile para ve zaman maliyeti, kör müdahaleyi sınırlar; etkisi oyun testinde incelenmelidir.

### Fabrika Performansı ve Zaman

Kullanıcının Claude'a anlattığı basit birim modelinde fabrika için **beklenen/ulaşılabilir 100 birim**, **gerçekleşen 40 birim**, **kayıp 60 birim** olabilir. Kayıp departmanlara dağıtılır: örnek **Planlama 10 + Satın Alma 20 + Sevkiyat 5 + Finans 5 + Üretim 20 = 60 birim**. Her departman kaybının altında sorun satırları vardır; satırların doğrudan kayıpları kendi departman toplamını açıklar. Bağlı iki satırın kaybı ayrı ayrı sayılır; ortak kökün müdahalesi ikisini birlikte kaldırır. Departmanlar arası çarpımsal hesap bu aşamada önerilmez. **Her departmanın performansı en az %33** olmalıdır; sorun üretimi bu tabanı aşacak kayıp yaratmaz. Departman yüzdesi ile fabrika kayıp biriminin nasıl bağlanacağı henüz açık bir ekonomi kuralıdır. Makine, ürün, kapasite ve talebe göre 100 birimlik beklentinin nasıl belirleneceği de ayrı ekonomi tasarımında kesinleşir.

Yukarıdaki Planlama kartı, bu fabrika örneğindeki **10 birimlik Planlama kaybının** 2 + 5 + 3 olarak satırlara dağıtılmasıdır. Önceki, ayrı bir senaryoda kullanılan “Planlama 100 birim kayıp” ve “Planlama %60; dört sorun satırı” örnekleri aynı fabrika hesabıymış gibi kullanılmaz. Departman yüzdesi ile fabrika kayıp biriminin dönüşümü açık ekonomi kararıdır.

Patronun aylık yönetim zamanı için **40 saatlik başlangıç örneği** vardır; değer testte değişebilir. Fabrika büyüdükçe sorun sayısı artar, bu yüzden para ve patron zamanı hangi sorunlara müdahale edileceğini belirler. Danışman ilgili alanda müdahalenin patron saatini azaltır; saat bakiyesini artırmaz. Müdahalelerin kesin saatleri ve büyüyen fabrikada gelecekteki ekip/personel sisteminin patron yükünü nasıl azaltacağı ayrı denge ve personel kararlarıdır.

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

Patron kök nedeni göremese bile departman kartındaki ayrı **“Derinlik bilinmiyor”** satırı kaybı veya belirtiyi gösterir (`GAME_OVERVIEW` §9). Oyuncu o satırın “Düzelt”ini deneyebilir veya danışman tutabilir; gerçek Tier ve neden otomatik ifşa edilmez. Başarısız denemede harcanan para ve zaman ile aynı satırın o ay yeniden denenemeyeceği açıkça gösterilir. **Aynı köke bağlı diğer satırları da kilitlemek önerilir**; bunun bağlantıyı ne ölçüde açığa çıkaracağı ve kategori ipuçlarının düzeyi henüz açık karardır.

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

Danışman kartları **firma büyüklüğüne ve oyuncunun bilgi açığına göre dinamik seçilir**; küçük fabrikaya en güçlü profillerin gelmemesi istenir. Başlangıçta düşünülen 10–15 önceden tanımlı profil ve 2–5 alanlı kart yapısı korunacaksa dinamik seçimin bu havuzdan nasıl yapılacağı açık karardır. Hedefleme gizli kök nedeni ele vermemek için oyuncunun raporda zaten gördüğü departman kayıpları ve görünür sorunlara dayanmalıdır. Ay sonu raporundan sonra **aktif danışmanlar aday havuzundan çıkarılır** ve **3 ücretsiz kart** görünür. Dördüncü kart oyun parası veya gerçek paradan biriyle açılır; bir kez daha ödeme yapılırsa beşinci çekim dördüncü kartın yerini alır, ayrı yer açılmaz. Ayda en fazla iki ücretli çekim vardır. Dördüncü kartın eksik alana uyma olasılığının +10 yüzde puan olması önceki kullanıcı yönlendirmesidir; dinamik seçimin içinde nasıl uygulanacağı açık karardır. Aynı kartın tekrar çıkması, uygun aday kalmaması ve ücretli çekimin olasılığının nasıl gösterileceği de açıktır. **Aktif danışman aylık aday çekilişine girmez; uzatma bu çekilişten ayrı bir sözleşme işlemidir.** Önceki **Satış** örneği, mevcut on yetkinlik arasında olmadığı için çıkarıldı.

Kartın listelediği her alan **en az 25, en fazla 100** puandır. **Kartın toplam puanı ≤ listelenen alan sayısı × 60**. Örnek: beş alanlı kartın bütçesi en fazla 300'dür; iki alan 25'er puansa kalan üç alana toplam 250 puan dağıtılabilir (ör. **25 + 25 + 83 + 83 + 84 = 300**). İki alanlı kartta bütçe 120 olduğu için bir alanın 100 olması, diğer alanın en az 25 olma şartıyla mümkün değildir; iki alanlı üst sınır örneği **95 + 25 = 120**. 100 puanlık uzmanlık en az üç alanlı profilde mümkündür. Bu sonuçlar önerilen üç kuralın matematiksel sonucudur.

Bir kartta **iki alanın 100 olması da mümkündür**: beş alanlı **100 + 100 + 50 + 25 + 25 = 300** kartı bütçe kuralını karşılar. Böyle güçlü profiller çok nadir ve çok pahalı olmalıdır. Kart başına “90+ en fazla bir alan” sınırı konmaz. Havuzda birlikte on alanı kapsayan iki kart bulunması da yasaklanmaz; kapsam, derin sorunların tamamında kesin çözüm anlamına gelmez.

Danışmanların ilgili alan puanı **100'e ulaşabilir**; 90'lık sabit üst sınır yoktur. En güçlü profiller nadir ve pahalı olmalıdır; ayrıca firma ölçeğine göre aday havuzundan çıkarılabilir. Ücret özellikle kartın **en yüksek iki alan puanına ağırlık vererek** artar. Böylece iki alanı 100 olan kart pahalı olur; dolgu alanlar fiyatı yapay biçimde ucuzlatmaz. Kariyerinde öğrenmediği derin sorunu danışmanla çözme yolu korunur, fakat küçük fabrikanın her uzman profiline anında erişmesi garanti değildir. Güçlü kartlara hangi firma ölçeğinde erişildiği ve küçük fabrika kârına göre maliyet dengesi açık karardır.

Danışman **belirli süreli sözleşmeyle** tutulur ve işe alındığı anda başlar; profilindeki bütün alanlar sözleşme boyunca aktiftir. **Aynı anda en fazla iki danışman** aktif olabilir. Sözleşme yalnızca **ilk yarısında** uzatılabilir; ikinci yarısında uzatma yapılamaz. Uzatma, aylık yeni danışman kartı çekilişinden ayrı bir işlem olur. Sözleşme bitince aynı danışmanın yeniden bulunup bulunmayacağı ve uzatma bedeli açık denge kararlarıdır. Örnek ilk fiyatlama: bir aylık ücret **A** ise 3 ay **2,75A**, 12 ay **10A**. Süreler ve çarpanlar bağlayıcılık/indirim fikrini gösteren taslak değerlerdir. Ödenen sözleşme ücreti, danışman erken bırakılırsa da iade edilmez. İki danışman aynı anda çalışsa bile ilgili alanda **etkin yetkinlik = max(patronun puanı, aktif danışmanların o alandaki puanları)**; puanlar birbirine eklenmez ve 100'ü aşmaz. Etkin değer sorunun eşiğine ulaşırsa kök neden görünür ve “Düzelt” kesin başarı verir. Danışman ayrılınca patronun kalıcı puanı artmış sayılmaz.

Danışman sözleşmesi oyun parası **veya** gerçek paradan biriyle ödenebilir; ikisi birden istenmez. Aynı danışman teklifine oyun parasıyla da erişilebilmelidir; gerçek para ödemesi sorunu çözmek için zorunlu hale gelmez. Ay sonu kart açılışı dışında ek bekleme yoktur; danışman hemen göreve başlar. Sürekli danışman tutmanın kariyer deneyimini değersizleştirmemesi için fiyatlar, dördüncü kart açma bedeli ve gelir dengesi sınanmalıdır. Ek kartın gerçek parayla açılması ücretli arama avantajı doğurduğu için monetizasyon incelemesinde özellikle değerlendirilmelidir.

Küçük veya nakdi sıkışık fabrikanın sürekli danışman tutması zor olmalıdır; bunun ne ölçüde doğal nakit akışından doğacağı test edilmelidir. **Firma ölçeği danışman kartlarının gücünü sınırlar**; Claude'un aktardığı yeni kullanıcı yönlendirmesi bunu beyin fırtınası önerisi olmaktan çıkarır. Danışmanın analizinden sonra ayrı bir "dinle/dinleme" eylemi ve uyum/güven statı bu sürümün mekaniğine eklenmez; kullanıcı her sorunda tek "Düzelt" butonunu seçti. Rutin sorunlar için tek buton, stratejik olaylar için çoklu müdahale seçeneği beyin fırtınasında geçti, fakat IDEA-001'in onaylı mekaniği değildir; ayrı kapsam kararı olarak açık tutulur. Sözleşmenin ilk yarısında uzatma mümkün olup bitiş sonrası devam garantisi ayrıca kararlaştırılmadı.

### Tasarım İlkesi

Mükemmel patron her şeyi kendisi yapan kişi değildir.

Neyi bildiğini bilir.
Neyi bilmediğini bilir.
Bilmediği işi kime bırakacağını bilir.

“Düzelt” sade bir operasyon eylemidir; fabrika döneminin stratejisi danışman seçimi, personel sonuçları, bütçe, zaman ve diğer yönetim kararlarında kurulmalıdır. Bu sistemlerin kapsamı ayrıca tasarlanacaktır.

## Notlar (Claude)

Tarihçe: Tur 1 inceleme [REV-001](../reviews/REV-001_claude_patron_yetkinlikleri.md) ve bu dosyanın Git geçmişi. Aşağıdakiler Tur 12 `Öneri (GPT)` metninin incelemesidir. Kullanıcının isteğiyle özellikle **kök düzeyinde aylık tekrar kilidi**, **tahmini/gerçek maliyet** ve **beş satırlı gizli sorun gösterimi** ele alındı. `Karar Özeti` tartışmaya açılmamış; notlar kararların içindeki açıkları ve uygulanma biçimini hedefler. Bu turda yalnızca `Notlar (Claude)` değişti.

### Aldığım Notlar

- Tur 11'in ana önerileri doğru işlenmiş: kökün derinliği bağlı satırların en derini, bağlantı aynı departmanda ve en fazla iki kademe aralıkta, "gizli satır görünür satırla bağlanmaz" yasağı kalktı. Başarı ve maliyet kökten hesaplanıyor.
- Tutarlı örnek düzeltildi: Planlama'nın 10 birimlik kaybı 2 + 5 + 3 olarak satırlara dağıtılıyor. Tur 11'deki "Planlama 100 birim" çelişkisi kapandı.
- "Satırın eşiği → belirti görünür; kökün eşiği → bağlantı ve kesin sonuç" ayrımı açık ve tek kurala dayanıyor.
- Satın Alma örneği beş satırlı kart ve "Derinlik bilinmiyor" diline uyarlandı.

### Bulduğum Sakıncalar

**1. Gizli satırdaki şans etiketi, adsız gösterime rağmen derinliği çoğu durumda tam olarak ele veriyor (kritik).**
Şans yalnızca kademe farkına bağlı ve gizli satırlar tam olarak patronun erişemediği Tier'ler. Bu yüzden etiket, adsız satırın Tier'ini doğrudan söylüyor. Örnek, Planlama yetkinliği 60 (T2'ye erişiyor) olan patron:
- Gizli T3 → 1 kademe → "yüksek"; gizli T4 → 2 kademe → "orta"; gizli T5 → 3 kademe → "düşük".
- Üç gizli yuvanın üç etiketi de birbirinden farklı. Oyuncu "yüksek" yazan adsız satırın T3, "orta" yazanın T4 olduğunu kesin olarak çıkarır.
- Aynı durum patron T3 veya T4'e eriştiğinde de geçerli. Yalnızca T1'e bile erişemeyen ya da yalnızca T1'e erişen patronda "düşük" etiketi birkaç derinliği birleştirip kısmen gizliyor.
- Sonuç: Karar Özeti'ndeki "gizli sorunun tam Tier'i ifşa edilmemeli" gerekçesi gerçekleşmiyor; adsız gösterim fiilen işlevsiz kalıyor. Öneri metnindeki "üç etiket … derinliği tam ifşa etmez" cümlesi bu yüzden doğru değil.

Bu bir tasarım hatası değil, iki hedefin matematiksel olarak bağdaşmaması: şans yalnızca derinliğe bağlıysa, şansı göstermek derinliği gösterir. Kullanıcının seçmesi gereken üç yol:
- **(a) Gizli satırda şans gösterilmesin ("belirsiz") (Claude önerisi):** Patron sorunun var olduğunu ve kaybını bilir, ne kadar zor olduğunu bilmez. "Neyi bilmediğini bilir" ilkesine en uygun ve en sade yol. Görünür satırlar etiketlerini korur.
- **(b) Gizli satırda patronun tahmini gösterilsin:** Etiket gerçek şansı değil, patronun yanılabilen tahminini gösterir; yetkinlik düştükçe tahmin bir kademe şaşabilir. Kaba risk bilgisini korur, derinliği kesinleştirmez, ama yeni bir gürültü kuralı ekler.
- **(c) Derinliğin sezilmesi bilinçli kabul edilsin:** Adsız gösterim yalnızca kozmetik kalır; Karar Özeti'ndeki gerekçe "neden gizli, zorluk sezilebilir" olarak güncellenir.

Ek not: İçerik üretiminde derin sorunların kaybı sistematik olarak daha büyük olursa, kayıp miktarı da derinliği ele verir. Kayıp büyüklüğü Tier'den bağımsız dağıtılmalı.

**2. Kök düzeyinde aylık kilit: her kilit biçimi bağlantıyı ilk etkileşimde ortaya çıkarır; bunu açık bir kural yapın.**
Seçenekler ve sonuçları:
- **Yalnızca satır kilidi:** Aynı kök bağlı satırlardan aynı ay birkaç kez denenebilir (T2, T3, T4 üzerinden %40 şansla üç deneme ≈ %78). Aylık tek deneme kuralı fiilen delinir. Bağlantı yine ortaya çıkar: ikinci satırdaki başarı ilk satırı da kapatır.
- **Görünmez kök kilidi:** Bağlı satır tıklanabilir görünür ama deneme reddedilir ya da sessizce başarısız sayılır. Reddetmek bağlantıyı yine gösterir; sessizce başarısız saymak ise oyuncuyu aldatan bir ceza olur. Kabul edilemez.
- **Görünür kök kilidi (Claude önerisi):** Başarısız denemeden sonra bağlı satırlar da kilitlenir ve mesajla açıklanır: "Bu sorunla aynı kökten geldiği anlaşılan 1 satır daha bu ay denenemez."

Sonuç: bağlantı, kök üzerinde ilk deneme yapıldığı anda ortaya çıkar. Başarıda satırlar birlikte kapandığı için, başarısızlıkta da kilit mesajıyla. Bu kaçınılmaz ve tematik olarak doğru: müdahale bilgi üretir, başarısızlık öğretir. Kilit mesajı bağlantıyı gösterir ama kökün derinliğini ve nedenini göstermez; gizli satırlar adsız kalır. Öneri metnindeki "aynı satırın o ay yeniden denenemeyeceği" ifadesi "aynı kökün" olarak düzeltilmeli.

**3. Tahmini/gerçek maliyet: Tur 11'deki zaman önerimi geri çekiyorum, bir açık yaratıyordu.**
Tur 11'de "sadelik için yalnızca satırın kendi süresi harcansın" önermiştim. Bu bir istismar açar: kökü T4 olan bağlantıda T2 satırından yapılan başarılı müdahale, kökün 14 saatlik işini T2'nin 6 saatiyle çözmüş olur. Öneriyi geri çekiyorum. Önerilen tam model:
- **Onay ekranı:** Satırın tahmini parası ve saati gösterilir. Kök maliyeti önceden gösterilmez, çünkü sığ görünen satırda yüksek bedel görünmesi bağlantıyı ödemeden önce ele verir.
- **Başarısızlık:** Tahmini para ve saat harcanır. Görünür kök kilidi devreye girer ve bağlantı açıklanır.
- **Başarı:** Bağlı satırlar kapanır. Kökün gerçek maliyetiyle arasındaki fark "kök daha derindeymiş" açıklamasıyla faturalanır: para farkı hemen, saat farkı ise sonraki ayın patron zamanından düşülür. Böylece başarı halinde toplam bedel her zaman kökün bedeli olur.
- **Bağlantı bilindikten sonra:** Bağlı satırların hepsi kökün tahminini gösterir. Böylece "en ucuz satırdan dene" avantajı yalnızca bağlantı henüz bilinmezken, yani kasıtlı kullanılamazken vardır.
- **Nakit riski:** Başarıyla gelen büyük bir fark faturası nakdi sıkışık fabrikayı iyi haberle birlikte krize sokabilir. Farka bir üst sınır konmalı (ör. tahminin en fazla 2 katı) ya da fark taksitlendirilmeli.
- **Karar Özeti notu:** "Tahsil edilen bedel … satırdan bağımsız gerçek çözüm maliyetidir" maddesi bu modelle yalnızca başarı halinde tam doğru olur. Başarısızlıkta satırın tahmini tahsil edilir. Madde buna göre "başarıda toplam bedel satırdan bağımsız olarak kökün maliyetidir" diye güncellenmeli.

**4. Görünür satırda düşük çıkan şans bağlantıyı ve kökün derinliğini sezdirir; bu kabul edilebilir.**
Planlama yetkinliği 60 olan patron T2'yi görüyor. T2 gizli bir T4'e bağlıysa T2 satırındaki etiket "kesin" değil "orta" çıkar. Oyuncu T2'nin daha derin bir köke bağlı olduğunu anlar, hatta farkın iki kademe olduğunu çıkarabilir. Bu, Tur 11'de önerdiğim "sezgi sinyali" ve GAME_OVERVIEW §9 ile uyumlu. Ancak 1. maddedeki (a) seçilirse bu satırda bilinçli bir istisna oluşur: görünür satır şans gösterir, gizli satır göstermez. İstisnanın gerekçesi yazılmalı: görünür satırda patron belirtiyi tanıyor ve işin beklenenden zor olduğunu sezebiliyor.

### Kafama Yatmayanlar

- **%33 taban ile birim modeli arasındaki köprü hâlâ açık.** Tur 10'da önerdiğim departman ağırlığı veya yalnızca fabrika tabanı seçeneği yanıt bekliyor. Planlama'nın 10 birimlik kaybının %33 tabanına göre izinli olup olmadığı, Planlama'nın fabrikadaki ağırlığı bilinmeden söylenemiyor.
- **Ücretli kartlar ve pay-to-win** hâlâ açık: ücretli kartların ücretsizlerle aynı puan bütçesine uyması ve avantajın yalnızca hedefleme olması önerisi yanıt bekliyor.
- **Gizli boş yuvanın gösterimi:** Örnekteki "gizli boş yuva: –" satırı oyuncuya erişemediği Tier'lerden birinin boş olduğunu söylüyor. Bu zararsız, çünkü gizli sorun sayısı zaten görünüyor. Ancak adsız satırlar her ay karışık sırayla gösterilmezse, sabit sıra zamanla Tier'i ima edebilir. Açık Kararlar'da not edilmiş; sıranın her ay rastgele olması önerilir.

### Açık Sorular

Tur 13'ten önce kullanıcının karar vermesi önerilen üç konu:

1. **Gizli satırlarda şans etiketi:** (a) "belirsiz" gösterilsin (Claude önerisi), (b) patronun yanılabilen tahmini gösterilsin, (c) derinliğin etiketten sezilmesi bilinçli kabul edilsin. Hangisi?
2. **Kök kilidi:** Başarısız denemeden sonra bağlı satırlar görünür biçimde kilitlensin ve bağlantı mesajla açıklansın mı (Claude önerisi)?
3. **Maliyet modeli:** Onayda satırın tahmini parası ve saati; başarıda kök farkı (para hemen, saat sonraki aydan); bağlantı bilinince tüm bağlı satırlarda kökün tahmini; fark için üst sınır ya da taksit. Bu model kabul edilsin mi?

Diğerleri:

- %33 taban için departman ağırlığı mı, yalnızca fabrika tabanı mı?
- Adsız gizli satırların sırası her ay rastgele olsun mu? Kayıp büyüklüğü Tier'den bağımsız dağıtılsın mı?

## Açık Kararlar

### FREEZE öncesi kapanması önerilenler (ilke düzeyinde)

- Danışman sözleşmesi ve dördüncü kartın oyun parası / gerçek para fiyat dengesi; aynı teklifin oyun parasıyla erişilebilirliği ve ücretli rastgele dördüncü kartın uygulama/mevzuat incelemesi. Claude notu: gerçek parayla danışman sözleşmesi GAME_OVERVIEW §26 ve §11 ile gerilim yaratıyor. Kullanıcının iki ödeme seçeneği ve rastgele dördüncü kart kararı korunur; oyun parasıyla makul erişim hedefi, gerçek para fiyatlandırması ve iflas dönemi etkisi henüz kapanmadı.
- Dinamik kart seçiminde "eksik yetkinliği kapatan" profilin tanımı, +10 yüzde puanlık dördüncü kart hedeflemesinin bu seçimle birleşmesi, beşinci çekimde ağırlığın sürüp sürmeyeceği, fiyatlar ve aynı kartın tekrar çıkması. Uygun aday kalmadıysa ödeme öncesi bildirim, geri koymasız çekim ve ücretli/ücretsiz kartların aynı puan bütçesine uyup uymayacağı açık; Claude'un örneğindeki 55+70 ve 75+65 iki alanlı kartlar mevcut 120 puan tavanını aşar. Gizli sorun bilgisi aday seçimiyle sızmamalı.
- Ortak kök yalnızca aynı departmanda ve en fazla iki Tier aralığında kurulur; kökün derinliği en derin bağlı Tier'dir. Başarısız deneme sonrasında köke bağlı diğer satırların aynı ay kilitlenip kilitlenmediği uygulamada netleştirilmeli; kilit görünürse bağlantının istemeden ifşası değerlendirilmelidir.
- Satırdaki tahmini maliyet ile tahsil edilen gerçek kök maliyeti arasındaki farkın ödeme öncesi nasıl anlatılacağı açık. Claude'un "tahmini bedel peşin, yalnızca başarıda fark faturası" önerisi kullanıcı tarafından henüz seçilmedi.
- Adsız gizli Tier yuvalarında boş “–” satırının sunumu, satırların sırasının Tier'i ima etmemesi ve danışman tutulunca yeniden adlandırılması arayüz testinde incelenmeli.
- %33 departman tabanının fabrika kayıp birimlerine çevrilmesi; departman ağırlığı veya başka basit bir köprü gerekip gerekmediği. Dinamik kartların gerçek parayla erişiminde GAME_OVERVIEW §11 ve §26'ya uygun korkuluklar da açık.

### Denge parametreleri ve testle kesinleşecekler

- Üç sözel başarı düzeyinin kesin olasılıklarla eşleşmesi ve oyuncuya yeterince anlaşılır geri bildirim vermesi; %80 yüksek / %40 orta / %15–5 düşük taslak eşlemedir. Üç etiket yakın açığı kısmen sezdirir, derin açığı gizler. (Claude notu: ilke Karar Özeti'nde kapandı; yalnızca eşleme testi kaldı.)
- Kart puan bütçesinin oyuncuya nasıl gösterileceği ve iki tane 100 puan içeren kartın nadirlik/fiyat dengesi; fiyat kartın en yüksek iki puanına ağırlık verir, kesin formül testle belirlenecek. (Claude notu: ilke Karar Özeti'nde kapandı.)
- İnsan Yönetimi alanındaki özgül sorunların içeriği, kaynak türü etiketleri ve %80 azaltma / %30–40 kişi kaynaklı sorun payı hedeflerinin testle ayarlanması. Yatay sıklık etkisi yalnızca patronun kalıcı puanına bağlıdır. (Claude notu: ilke Karar Özeti'nde kapandı.)
- “Düzelt”in kök nedenin gerektirdiği işe dayanan para maliyeti, kartların yakın maliyet aralığı, aylık patron zamanı ve danışmanın zaman tasarrufu.
- Kabul edilen taslak kademe eğrisinin (≈ %80 / %40 / %15 / %5) oyun testlerinde ayarlanması; Tier içinde farklı puanların aynı şansa sahip olmasının uygunluğu.
- Aylık 40 saat başlangıç örneği, müdahale süreleri ve danışmanın ne kadar zaman tasarrufu sağladığı; başarısız denemelerin saat maliyeti ve sonraki ay tekrar denemenin para maliyeti.
- Kart havuzunun kesin büyüklüğü (10–15 ilk taslaktır), firma ölçeği ve görünen bilgi açığıyla dinamik aday seçimi, güçlü kartların nadirliği ve ücretli adayın güç sınırı.
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
- Departman başına en fazla beş eşzamanlı problem satırı vardır (Tier başına en fazla bir); sorunların hangi sıklıkla ve hangi Tier'de üretileceğinin dengesi açık.
- Ulaşılabilir 100 birimlik fabrika beklentisinin makine, ürün, talep ve giderlere göre hesabı; departman kayıp birimlerinin yüzde performansa dönüşümü, bağlı satırların iki kez sayılmaması ve Ar-Ge/Yatırım gibi alanların aylık çıktıya mı gelecek fırsatlara mı yansıyacağı. Planlama'nın kaybı aynı örnek fabrikada 10 birim olarak gösterildi; departman başına %33 tabanıyla bağlantı hâlâ açık.
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
- Fabrika ölçeğine göre danışman aday gücü IDEA-001 yönüdür; fabrika kârı ve departman ağırlıklarının hesabı ayrı ekonomi tasarımında kesinleşir.
- Rutin sorunlarda tek “Düzelt”, stratejik sorunlarda birden fazla çözüm alternatifi beyin fırtınası önerisidir; mevcut tek buton kuralını değiştirmeden ayrı IDEA/kapsam kararı olarak saklanır.
- Fabrika dönemindeki stratejik derinliğin “Düzelt” dışında hangi sistemlerden geleceği.

## Karar Özeti

Kullanıcının yönlendirmeleri (IDEA düzeyinde; henüz FREEZE değil):

- “Düzelt” butonu yetkinlikten bağımsız açık kalır, her deneme para ve zaman harcar; çünkü sorun çözümü ek efor veya mini oyun gerektirmemeli.
- Yetkinlik Tier eşiğine ulaşıyorsa sorun kesin çözülür; ulaşmıyorsa başarı olasılığı yetkinliğe bağlıdır (60/70 için yaklaşık %80 hedefi); çünkü bilgi açığı çözmeyi imkânsız değil, riskli kılmalı.
- Yetkinlik bilgi modeli olarak öncelikle kök neden görünürlüğünü belirler; çünkü seçenek kilitlemek yerine oyuncunun neyi bildiği öne çıkmalı.
- Fabrika batınca aynı karakter devam eder; çünkü başarısızlık sonraki girişime ders taşımalı.
- Ay sonunda 3 danışman adayı görünür, dördüncü kart oyun parası veya gerçek parayla açılır; çünkü oyuncu rapordan sonra seçim yapmalı ve ek kart için ödeme yolu seçebilmeli; 10–15 sabit profil havuzu dinamik seçimle yeniden değerlendirilecek.
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
- Her departman kartında T1–T5 için daima beş satır vardır; her Tier en fazla bir kez görünür ve boş satır “–” olur, çünkü departman kaybı sabit ve okunur bir yapıda sunulmalı.
- Sorun bulunan her Tier satırı kendi “Düzelt” butonunu ve yüksek/orta/düşük şans etiketini taşır; çünkü oyuncu hangi soruna müdahale ettiğini ve riskini görmeli, üç etiket gizli nedeni tam açıklamamalı.
- Kişi kaynaklı sorunların sıklığını yalnızca patronun kalıcı İnsan Yönetimi puanı azaltır; çünkü danışman bu yatay kariyer yatırımının yerini almamalı.
- İki danışman kartının birleşince on alanı kapsaması yasaklanmaz; çünkü kapsam tek başına derin sorunlarda kesin çözüm sağlamaz, geniş kartların dengesi fiyat ve nadirlikle kurulmalı.
- Sözleşmesi süren danışman aylık aday havuzuna girmez; sözleşme yalnızca ilk yarısında ayrı işlemle uzatılabilir, çünkü aktif kart çekiliş hakkını boşa harcamamalı ve oyuncu devam kararını erken vermeli.
- Dördüncü kart rastgele kalır ve eksik yetkinliği kapatma olasılığı normal çekilişten 10 yüzde puan yüksek olur; çünkü ücretli seçimde oyuncuya daha yararlı bir aday şansı verilmeli.
- Ayda en fazla iki ücretli danışman çekimi yapılır ve beşinci çekim dördüncü kartın yerini alır; çünkü oyuncu bir kez yeniden deneyebilmeli ama sınırsız kart çevirip en iyi adayı garantilememeli.
- Danışman sözleşmesi oyun parası veya gerçek parayla ödenebilir; çünkü oyuncuya iki ödeme seçeneği sunulurken gerçek para zorunlu olmamalı.
- Danışman fiyatında en yüksek iki alan puanı daha ağır basar; çünkü iki zirve uzmanlığı olan kart ciddi bir bedel taşımalı.
- İnsan Yönetimi yaklaşık %80'e kadar kişi kaynaklı sorunları azaltır, kendi alan sorunları da vardır ve kişi kaynaklı sorunlar toplamın yaklaşık %30–40'ıdır; çünkü bu yetkinlik güçlü ama diğer alanların yerini almayan bir yatırım olmalı.
- Ayrı müdür/ekip mekaniği IDEA-001'in kapsamı dışındadır ve daha sonra tasarlanabilir; çünkü bugünkü basit “Düzelt” akışı gelecekte ekip kararlarını kapatmamalı.
- Aynı soruna ayda en fazla bir “Düzelt” denemesi yapılır; fabrika genelindeki müdahaleleri para ve patron zamanı sınırlar, çünkü kör deneme riskli olmalı ama başka sorunlara müdahaleyi engellememeli.
- Danışman olsa da her sorunlu Tier satırında yalnızca tek “Düzelt” bulunur ve başarı hesabı max(patron, aktif danışmanlar) ile yapılır; çünkü danışman desteği ayrı bir karar menüsü yaratmadan yetkinlik açığını kapatmalı.
- Danışman aynı kök nedeni gidermenin oyun parası maliyetini değiştirmez, patron zamanını azaltır; çünkü sözleşme ücreti ayrıca ödenmiştir ve analiz yükünü danışman üstlenir.
- Departmanın iç modelinde beş Tier yuvası bulunur ve kayıpları departman toplamını açıklar (aynı fabrika örneğinde Planlama 2 + 5 + 3 = 10 birim); çünkü rapordaki kayıp satırlarla matematiksel olarak eşleşmeli.
- Önceki T2 eşiği 50 kalır ve örnekte patron yetkinliği 60 alınır; çünkü 20/50/30 sayıları yetkinlik eşiği değil sorunların kayıp birimleridir.
- Farklı Tier satırları yalnızca aynı departmanda ve en fazla iki kademe aralıkta ortak kök taşıyabilir; çünkü tek neden birkaç kayıp yaratabilmeli, T1–T5 gibi uzak ve şaşırtıcı bağlantılar oluşmamalı.
- Ortak kökün derinliği bağlı satırların en derin Tier'idir ve hangi satırdan basılırsa basılsın başarı buna göre hesaplanır; çünkü görünür kolay satır gizli derin nedeni kesin çözme yoluna dönüşmemeli.
- Patronun erişemediği dolu Tier yuvaları “Derinlik bilinmiyor” altında ayrı adsız satırlar olarak görünür; çünkü kayıp ve müdahale imkânı açık kalırken gizli sorunun tam Tier'i ifşa edilmemeli.
- Sorun kartı tahmini maliyet gösterebilir, tahsil edilen bedel aynı kök için satırdan bağımsız gerçek çözüm maliyetidir; çünkü kayıp yüzdesi veya ucuz görünen kart aynı işi daha ucuz hale getirmemeli.
- Sorunlu Tier satırında çözüm ihtimali yüksek/orta/düşük olarak üç düzeyde gösterilir; çünkü kaba risk bilgisi verilirken gizli neden tam açıklanmamalı.
- Patronun ilgili departmandaki tek yetkinlik puanı Tier eşiğiyle doğrudan karşılaştırılır; çünkü ayrı “Görüş Seviyesi” aynı bilgiyi tekrarlar ve gereksiz kavram yaratır.
- Danışman adaylarının gücü fabrika ölçeğine göre sınırlandırılır ve seçim görünür bilgi açıklarına göre dinamik olur; çünkü küçük fabrikanın en güçlü uzmanlara hemen erişmesi ve gizli sorunların kart teklifinden ifşa edilmesi istenmez.
- Her departmanın performansı en az %33 kalır ve fabrika kaybı basit birimlerle departmanlara dağıtılır; çünkü sorunlar matematiksel olarak açıklanırken departman performansı eksiye düşmemeli ve genel rapor kolay okunmalı.
- Fabrika büyüdükçe sorun sayısı artar ve aylık patron zamanı sınırlıdır (40 saat ilk örnek); çünkü büyüme yönetim önceliği ve ileride yetki devri ihtiyacı yaratmalı.
