# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: FRZ-001 kapsamı kullanıcı tarafından onaylandı; kalan konular öneri olarak açık
Tur: 16
Son güncelleme: 2026-09-29
Kaynak: Kullanıcının ilk önerisi, sonraki kararları ve 2026-09-28 tarihli beyin fırtınası notlarından seçilen fikirler.
Tur 1–15 Claude incelemeleri tamamlandı. `Notlar (Claude)` Tur 15 incelemesidir ve Claude'un metni olarak korunur. Kullanıcı Tur 16 çekirdek kapsamını onayladı: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md). Bu dosyanın kalan önerileri onaylanmış oyun kuralı değildir.
Sıradaki adım: FRZ-001 kapsamı dışında kalan ekonomi, danışman piyasası, iflas ve personel konularını ayrı tasarım çalışmalarıyla ele almak.

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

Önerilen aylık fabrika akışı: **ay sonu raporu → her departmanın kartı → gerekirse danışman seçimi → ilgili satırda “Düzelt” → para ve patron zamanı harcaması → anında sonuç**. Her departmanın modelinde **tam beş Tier yuvası** vardır; aynı Tier'de ikinci sorun oluşmaz. Oyuncu kartta beş satır görür: eriştiği Tier'ler T1…Tk adıyla, erişemediği dolu Tier yuvaları **“Derinlik bilinmiyor”** başlığı altında ayrı adsız ve sırasız satırlar olarak, mümkün ama boş yuvalar **“–”**, **boş ve mevcut ölçek sınırının dışındaki** yuvalar **“ölçek dışı”** olarak görünür. Daha büyük ölçekte doğmuş dolu yuva, fabrika küçüldüğünde “ölçek dışı” diye saklanmaz; sorun satırı olarak kalır. Gizli dolu satır kendi kayıp miktarını ve tek “Düzelt” butonunu gösterir. **O satırın oluştuğu ölçek ve etkin yetkinlik dikkate alındığında yalnızca bir gizli Tier mümkünse** satırın şans etiketi gösterilir ve başlığı “Nedeni bilinmiyor” olur; daha çok Tier mümkünse “belirsiz” kalır. Gerçek kök nedeni görünmez. Görünür satır patronun tanıdığı belirtinin riskini yüksek/orta gibi kaba etiketle gösterebilir. Danışman ilgili alandaki etkin yetkinliği yükselttiğinde o satırın Tier'i ve uygun bilgisi açılır; ikinci eylem açılmaz. **Aynı köke ayda en fazla bir kez müdahale edilir; fabrika genelinde tek müdahale sınırı yoktur.** Farklı köklere müdahale sayısını para ve aylık patron zamanı sınırlar. Başarısız denemede tahmini para ve zaman harcanır, bağlı satırlar da aynı ay görünür biçimde kilitlenir; kök sonraki ay yeniden denenebilir. Mini oyun veya ayrı müdahale menüsü yoktur.

Etkin yetkinlik sorunun kök nedeninin eşiğine ulaşıyorsa “Düzelt” kesin sonuç verir; eşiğin altındaysa para ve zaman harcanıp başarı için olasılık hesabı yapılır. Örnek: Planlama puanı 20 olan patron ve Planlama puanı 80 olan aktif danışman için etkin değer **max(20, 80) = 80** olur; 70 eşikli Planlama sorunu kesin çözülür. Danışman tutmak tek başına sorunu ortadan kaldırmaz; oyuncu yine “Düzelt”e basar. Eski **20 + 50 = 70** örneği artık geçerli değildir: max(20, 50) = 50, dolayısıyla o sorunda olasılık hesabı yapılır. Danışman varlığı sorunu gidermek için gereken **oyun parası maliyetini değiştirmez**; danışmanın bedeli sözleşmede ödenir. Danışman, analiz yükünü üstlenerek gereken **patron zamanını azaltır**. Kesin zaman tasarrufu denge parametresidir.

Tek bir tutarlı örnek için fabrikanın beklenen çıktısı **100 birim**, Planlama kaynaklı kaybı **10 birim** olsun. Planlama'nın gerçek satırları T1: –, T2: **2**, T3: **5**, T4: **3**, T5: – birimdir. **Planlama yetkinliği 60** olan patron T2'yi 50 eşiğiyle tanır; kartında T1: –, T2: 2, “Derinlik bilinmiyor”: 5, “Derinlik bilinmiyor”: 3 ve gizli boş yuva: – görür. Gizli iki satırın T3 ve T4 olduğunu ve sırasını öğrenmez. T2 bağımsız kökse kesin çözer; başka, daha derin bir satırla bağlıysa başarı o ortak kökün derinliğine göre hesaplanır. İlgili alanda **90 puanlık** aktif danışman T3 ile T4'ü de açar ve patron zamanını azaltır; patronun kalıcı puanı 60 kalır.

**Farklı Tier satırları aynı kök nedene bağlanabilir; bağlantı yalnızca aynı departmanda ve en fazla iki Tier kademe aralığında kurulur.** Örneğin T1–T3, T2–T4 veya T3–T5 mümkündür; T1–T5 mümkün değildir. **Aynı köke bağlı bütün satırlar tek oluşum olayında birlikte doğar** ve aynı ayın ölçek tavanını taşır; sonradan o köke yeni satır eklenmez. Böylece eski bir satırın güvencesi daha sonra eklenen derin bir satır yüzünden yetersiz kalmaz. Kökün derinliği **bağlı satırların en derin Tier'i** olur. Oyuncu hangi bağlı satırda “Düzelt”e basarsa bassın başarı ihtimali ve gerçek çözüm maliyeti köke göre hesaplanır; başarı bütün bağlı satırları kapatır. Bu nedenle görünür T2'ye basmak gizli bağlı T4'ü kesin veya toplamda ucuz biçimde aşmaz: patron yetkinliği 60 ise T4 kökü için iki kademe eksik taslak başarı ihtimali ≈ %40'tır. Böylece önceki “gizli satır görünür satırla bağlanmaz” yasağı kalkar; yasağın amacı olan kolay Tier üzerinden derin sorunu garantili çözmeme korunur. Etkin yetkinlik kökün en derin eşiğine ulaşınca bağlantı teşhis edilebilir.

**Kök maliyeti:** Her Tier'in birbirine **örtüşmeyen**, yükseldikçe artan bir **oyun parası fiyat bandı** vardır. Kök neden türünün gerçek müdahale bedeli kendi Tier bandının içinden seçilir; satırın kayıp büyüklüğü bedeli belirlemez. Gizli satırın para tahmini, patron veya danışmanın erişemediği **en sığ, satırın oluştuğu ölçek sınıfında mümkün Tier'in bant tabanıdır**. Görünür satırın para tahmini, şans etiketinin işaret ettiği **kök Tier'inin bant tabanıdır**. Aynı Tier'deki farklı kök türleri farklı gerçek bedellere sahip olabilir. Para için değişmez: **tahmin ≤ gerçek kök bedeli ≤ üst bedel**.

**Patron saati:** Saat bantları örtüşebilir; fakat Tier yükseldikçe bantların **tabanı da tavanı da azalmaz**. Böylece saat için de tahmin ≤ gerçek ≤ üst korunur. İlgili alandaki danışman zaman indirimi uygulanıyorsa **tahmin, gerçek ve üst saat aynı oranla** azaltılır. Oranın kesin değeri ve danışmanın puanı patronunkinden düşükken indirimin geçerli olup olmayacağı denge kararıdır.

**Üst bedel ve güvence:** Gizli satırın “en fazla” para ve saati, departmanda **gerçekte hangi sorunların bulunduğuna bakılmadan**, **satırın ortaya çıktığı aydaki fabrika ölçeğinde oluşabilecek en derin Tier'in bant tavanından** hesaplanır. Satırın oluştuğu ay oyuncunun raporunda bilinir; üst bedel gizli Tier'i ifşa etmez. Aynı ölçekte oluşan gizli satırlar aynı üst bedeli gösterir; farklı aylarda farklı ölçeklerde oluşanlar ayrı üst bedel gösterebilir. Görünür satırda kök Tier'i etiketten anlaşıldığı için üst tutarlar o Tier'in bant tavanıdır. Onay anında oyuncunun kasası ve **bu ay kalan patron saati** ayrı ayrı üst bedele yeterli olmalıdır; değilse “Düzelt” görünür kalır ama yetersiz kaynak gerekçesiyle başlatılamaz. Sonuç anında belirlenir: başarısızlıkta yalnızca tahmin, başarıda kökün gerçek bedeli **aynı ay** harcanır. Başarıda toplam bedel hangi bağlı satırdan denendiğine bağlı değildir; borç, taksit veya gelecek ay saat düşümü yoktur. Güvence yalnızca basma anındaki yeterlilik kontrolüdür, uzun süreli kaynak ayırma durumu yaratmaz.

**Fabrika ölçeği ve sorun derinliği:** Fabrikanın ölçeği, o departmanda **oluşabilecek en derin Tier'i** sınırlar. Böylece küçük fabrikada T5 güvencesi otomatik istenmez ve erken dönemde danışmansız kör deneme tamamen kapanmaz. Örneğin küçükte T3, ortada T4, büyükte T5 tavanı düşünülebilir; bunlar kesin eşik veya zorunlu dağılım değildir. Ölçek sınırı oyuncuya açıkça gösterilir; üst bedel gizli gerçek durumu değil bu herkese açık sınırı yansıtır. Ölçek **büyüyünce veya küçülünce** mevcut satırın Tier'i ve oluştuğu ayın güvence tavanı değişmez. Yeni satırlar yeni ölçeğin tavanıyla doğar. Danışman aday gücünün ölçeğe bağlı olmasıyla bu tavanın uyumu ayrıca sınanır.

Yalnızca modeli anlatan taslak örnekte Planlama yetkinliği **60** olsun ve incelenen gizli satırlar fabrika **büyükken**, T5 tavanıyla doğmuş olsun. T3 para bandı **35–45 bin**, T4 **70–90 bin**, T5 **150–170 bin** olabilir; örnek saat aralıkları sırasıyla **9–11**, **13–15**, **19–21** saattir. Bu gizli satırlarda ortak tahmin T3 tabanı **35 bin / 9 saat**, üst güvence T5 tavanı **170 bin / 21 saat** görünür; gerçek T4 kökü başarıyla giderilirse bedeli kendi T4 bandındaki kök türüne göre hesaplanır. Aynı satırlar sonradan küçülen fabrikada da oluşum aylarının T5 güvencesini korur. Küçük fabrikada yeni doğan bir satırın olası derinliği T3 ile sınırlıysa üst bedeli yalnızca T3 tavanıdır. Sayılar kesin fiyat, saat veya ölçek kararı değildir.

Bağlantı öğrenildikten sonra yalnızca gizli satırlardan oluşan grubun tahmini gerçek kök bedeline çevrilmez; Tier sızmamalıdır. Bağlı grupta görünür satır varsa oyuncu kök Tier'ini etiketten zaten sezebilir. Bu gruptaki gizli satırın daha ucuz başarısızlık denemesi olarak kullanılmasını önlemek için bütün bağlı satırlara görünür satırın kök Tier tabanını gösterme önerisi **açıktır**; kullanıcı henüz bunu seçmedi.

**Görünür kök kilidi:** Başarısız denemede aynı köke bağlı bütün satırlar ay bitene kadar kilitlenir. Oyuncuya “Bu sorunla aynı kökten geldiği anlaşılan 1 satır daha bu ay denenemez” gibi bir mesaj verilir. İlk müdahale bağlantıyı açığa çıkarır: başarıda satırlar birlikte kapanır, başarısızlıkta kilitlenir. Mesaj kökün Tier'ini ve nedenini açıklamaz; başarısızlığın bilgi üretmesi bilinçli tasarım tercihidir.

“Düzelt”, sorunun gerektirdiği işlemin yapılmış olmasıdır; kişi kaynaklı sorunda konuşma, yaptırım veya işten çıkarma gibi sonucu da kapsayabilir. Oyuncu için ayrıca müdür kovma zinciri veya her soruna özel eylem menüsü açılmaz. Hangi işlemin gerçekleştiği sonuç metninde anlatılabilir; buna ayrı bir müdür karakteri veya müdür yetkinliği gerekmez.

Eşik altı olasılığı **etkin yetkinlik ile kökün en derin Tier'i arasındaki kademe farkına** göre düşer. Kabul edilen taslak denge: bir kademe eksik ≈ %80, iki kademe ≈ %40, üç kademe ≈ %15, dört veya daha fazla kademe ≈ %5. Örneğin 60/70 bir kademe farktır ve yaklaşık %80 başarı verir. Rakamlar oyun testleriyle ayarlanabilir; eşikler henüz FREEZE değildir. **Görünür sorunlu satırda** olasılık yüzde yerine kaba etiketle gösterilir; bu bağlantı sınırı nedeniyle mevcut modelde “kesin”, “yüksek” veya “orta” olabilir. **Gizli satırda** normalde **“belirsiz”** yazılır; çünkü kademe farkından türeyen sözel etiket gerçek Tier'i ele verebilir. Ancak oluşum ölçeğinde ve mevcut yetkinlikle **tek olası gizli Tier** kaldıysa oyuncunun zaten çıkarabildiği şans etiketi gösterilir; neden yine gizli kalır. “Düşük” iç hesapta var olsa da çoğu gizli satırda ekranda görünmez; üçlü etiket kararının sadeleştirilmesi henüz açık karardır. Görünür bir satırın beklenenden düşük etiketi daha derin bağlantıyı sezdirir; bu, tanınan bir belirtinin altında başka neden olabileceği sinyalidir. Aynı kökü sonraki ay yeniden denemenin para maliyeti açık denge kararıdır.

Bu akışta yetkinlik, hangi eyleme basılabileceğinden çok **neyin yanlış gittiğini bilme** ve bilinmeyen sorunu çözme şansıyla ilgilidir. Aynı köke aylık tek deneme ile para ve zaman maliyeti, kör müdahaleyi sınırlar; etkisi oyun testinde incelenmelidir.

### Fabrika Performansı ve Zaman

Kullanıcının Claude'a anlattığı basit birim modelinde fabrika için **beklenen/ulaşılabilir 100 birim**, **gerçekleşen 40 birim**, **kayıp 60 birim** olabilir. Kayıp departmanlara dağıtılır: örnek **Planlama 10 + Satın Alma 20 + Sevkiyat 5 + Finans 5 + Üretim 20 = 60 birim**. Her departman kaybının altında sorun satırları vardır; satırların doğrudan kayıpları kendi departman toplamını açıklar. Bağlı iki satırın kaybı ayrı ayrı sayılır; ortak kökün müdahalesi ikisini birlikte kaldırır. Departmanlar arası çarpımsal hesap bu aşamada önerilmez. **Her departmanın performansı en az %33** olmalıdır; sorun üretimi bu tabanı aşacak kayıp yaratmaz. Departman yüzdesi ile fabrika kayıp biriminin nasıl bağlanacağı henüz açık bir ekonomi kuralıdır. Makine, ürün, kapasite ve talebe göre 100 birimlik beklentinin nasıl belirleneceği de ayrı ekonomi tasarımında kesinleşir.

Yukarıdaki Planlama kartı, bu fabrika örneğindeki **10 birimlik Planlama kaybının** 2 + 5 + 3 olarak satırlara dağıtılmasıdır. Önceki, ayrı bir senaryoda kullanılan “Planlama 100 birim kayıp” ve “Planlama %60; dört sorun satırı” örnekleri aynı fabrika hesabıymış gibi kullanılmaz. Departman yüzdesi ile fabrika kayıp biriminin dönüşümü açık ekonomi kararıdır.

Patronun aylık yönetim zamanı için **40 saatlik başlangıç örneği** vardır; değer testte değişebilir. Fabrika büyüdükçe sorun sayısı artar, bu yüzden para ve patron zamanı hangi sorunlara müdahale edileceğini belirler. Danışman ilgili alanda müdahalenin patron saatini azaltır; saat bakiyesini artırmaz. Müdahalelerin kesin saatleri ve büyüyen fabrikada gelecekteki ekip/personel sisteminin patron yükünü nasıl azaltacağı ayrı denge ve personel kararlarıdır.

### İnsan Yönetimi ve Personel

Bu IDEA'da müdür için ayrı kimlik veya yetkinlik puanı tanımlanmıyor. Bu, gelecekte ekip/personel sisteminin ayrı bir IDEA'da tasarlanmasını engellemez. **Kişi kaynaklı sorunların ortaya çıkma sıklığını yalnızca patronun kalıcı İnsan Yönetimi puanı azaltır**; danışmanın İnsan Yönetimi puanı bu yatay sıklık etkisine katılmaz. Etki aylık performans raporlarına yansır. En yüksek İnsan Yönetimi yetkinliği için **yaklaşık %80 azalma tavanı** ve kişi kaynaklı sorunların toplam sorunlar içinde **yaklaşık %30–40 payı** başlangıç denge hedefidir. İnsan Yönetimi alanının kendi sorunları da vardır; bu yüzden danışman kartındaki İnsan Yönetimi puanı o alanın sorunlarını görme/çözmede işe yarar. Kişi kaynaklı bir sorun başarıyla “Düzelt”ildiğinde gereken personel işlemi çözümün içinde sayılır. Kesin sıklık eğrisi ve sorun içeriği testle belirlenecektir.

Bu yönlendirme, `GAME_OVERVIEW` §10'daki ayrı müdür uzmanlığı ve iyi/kötü müdür matrisinden ayrılıyor. Personel sistemi FRZ-001 kapsamı dışındadır; o konu tasarlanırken vizyon belgesiyle uyumu gözden geçirilmelidir.

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

Patron kök nedeni göremese bile departman kartındaki ayrı **“Derinlik bilinmiyor”** satırı kaybı veya belirtiyi gösterir (`GAME_OVERVIEW` §9). Oyuncu o satırın “Düzelt”ini deneyebilir veya danışman tutabilir; gerçek Tier ve neden otomatik ifşa edilmez. Gizli satırın şansı **“belirsiz”** görünür. Başarısız denemede harcanan tahmini para ve zaman ile **aynı köke bağlı bütün satırların** o ay yeniden denenemeyeceği gösterilir. Bu kilit bağlantıyı açıklar; kökün derinliğini açıklamaz.

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

Tarihçe: Tur 1 inceleme [REV-001](../reviews/REV-001_claude_patron_yetkinlikleri.md) ve bu dosyanın Git geçmişi. Aşağıdakiler Tur 15 `Öneri (GPT)` metninin incelemesidir. Kullanıcının isteğiyle özellikle **fabrika ölçeği geçişi**, **saat güvencesi** ve **küçük fabrikanın danışmansız gizli sorun deneyebilmesi** ele alındı. `Karar Özeti` tartışmaya açılmamış; notlar kararların içindeki açıkları ve uygulanma biçimini hedefler. Bu turda yalnızca `Notlar (Claude)` değişti.

Örneklerde Tur 15'in bantları kullanıldı: T3 35–45 bin / 9–11 saat, T4 70–90 bin / 13–15 saat, T5 150–170 bin / 19–21 saat. Alt Tier'ler için şu varsayım eklendi: T1 8–12 bin / 3–5 saat, T2 17–23 bin / 5–7 saat.

### Aldığım Notlar

- Tur 14 kararları doğru işlenmiş: örtüşmeyen para bantları, üst bedelin gerçek durumdan bağımsız olması, ölçeğe bağlı derinlik tavanı ve güvencenin yalnızca basma anında yapılan bir yeterlilik kontrolü olması.
- "Ölçek büyüyünce mevcut sorunların Tier'i değişmez" kuralı doğru; oyuncu var olan sorunun sessizce derinleştiğini görmez.
- Ölçek sınırının oyuncuya açıkça gösterilmesi, üst bedeli sızıntısız ve anlaşılır kılıyor.
- Ucuz bağlı satır sorunu ve erişim test ölçütü "henüz karar değil" olarak dürüstçe işaretlenmiş.

### Bulduğum Sakıncalar

**1. Ölçek küçülmesi "gerçek ≤ üst" değişmezini bozar (kritik).**
Tur 15 yalnızca büyümeyi tanımlıyor. Fabrika küçülürse (kriz, makine satışı, iflasa yakın dönem) tavan düşer, ama o sırada var olan T4 sorunu yerinde kalır. Örnek: orta ölçekten küçüğe inen fabrikada gizli satırların üst bedeli T3 tavanına (45 bin) iner. Gerçek bir T4 kökünün bedeli ise 70–90 bindir. Başarıda güvence yetmez ve Tur 13'te kaldırılan zorunlu ek fatura geri döner. Üç yol var:
- **(a) Tavan yalnızca artar:** Basit ve sızıntısız, ama krizden küçülen fabrikanın yeni sorunları da büyük fabrika derinliğinde kalır. Bu, §20'deki sarmal riskine hizmet eder.
- **(b) Küçülmede tavan, o anda var olan bütün satırlar kapanana kadar eski değerinde kalır:** Hangi satırların o anda var olduğu oyuncunun gördüğü bilgidir, bu yüzden sızıntı yapmaz. Yine de "ne zaman düşecek" takibi gerektirir.
- **(c) Satır bazlı tavan (Claude önerisi):** Her satırın üst bedeli, **satırın ortaya çıktığı aydaki ölçek tavanından** hesaplanır. Satırın ortaya çıktığı ay rapordan görülen herkese açık bir bilgidir; sızıntı yapmaz. Tek kural hem büyümeyi hem küçülmeyi çözer:
  - Büyüyünce eski satırlar eski, düşük güvencesini korur.
  - Küçülünce derin eski satırlar kendi yüksek güvencesini korur.
  - Bedeli: aynı departmandaki gizli satırlar, oluştukları aya göre farklı üst bedel gösterebilir. Bu, Tur 15'teki "aynı departmandaki gizli satırlar aynı üst bedeli gösterir" cümlesinin "aynı ölçekte oluşan gizli satırlar" diye güncellenmesini gerektirir. Kullanıcı kararı gerekir.

**2. Büyüme anında güvence sıçraması büyümeyi cezalandırır; satır bazlı tavan bunu da çözer.**
Satır bazlı tavan olmadan, küçükten ortaya geçen fabrikada Planlama 60 olan patronun var olan gizli T3 satırlarının üst bedeli bir gecede 45 bin / 11 saatten 90 bin / 15 saate çıkar. Bu satırların hiçbiri T4 olamaz, çünkü küçük ölçekte oluştular. Oyuncu "büyüdüm, dünkü sorunumu artık deneyemiyorum" hissini yaşar. Satır bazlı tavanla bu sıçrama hiç olmaz.
Ayrıca büyüme kararının önünde bir önizleme olmalı: "Orta ölçeğe geçince T4 sorunları görülmeye başlayabilir. Bu alanlarda yetkinliğiniz T4'e yetmiyor: Planlama, Satın Alma…" Böylece büyüme bilinen bir riskle alınan bir karar olur. Bu, "patron neyi bilmediğini bilir" ilkesinin doğrudan bir uygulaması.

**3. Danışman gücü tavanı, sorun derinliği tavanıyla eşlenmeli.**
Tur 15 bu uyumu "ayrıca sınanır" diye bırakmış. Oysa bu bir denge ayarı değil, mantıksal bir koşul: bir ölçekte oluşabilecek en derin sorunun eşiğine o ölçekteki hiçbir aday ulaşamıyorsa, o sorun o ölçekte yalnızca kör şansla çözülebilir. Öneri kuralı: **danışman adaylarının alan puanı tavanı ≥ ölçeğin en derin Tier eşiği**. Örnek taslakta bu, küçük ölçekte en az 70, ortada en az 90, büyükte 100 eder. Güçlü adaylar yine nadir ve pahalı kalabilir; kural yalnızca "hiç yok" durumunu önler.

**4. Saat güvencesi: bantların örtüşmesi sorun değil; gereken koşul tabanın ve tavanın Tier ile azalmaması.**
"Tahmin ≤ gerçek ≤ üst" değişmezi için bantların örtüşmemesi gerekmez. İki koşul yeterli:
- Tier yükseldikçe bant tabanı azalmamalı. Böylece en sığ olası Tier'in tabanı, her gerçek kökün altında kalır.
- Tier yükseldikçe bant tavanı azalmamalı. Böylece en derin olası Tier'in tavanı, her gerçek kökün üstünde kalır.

Bu yüzden saat bantları örtüşebilir; kök türüne göre esneklik kazandırır. (Para bantlarında örtüşmeme kararı sorun değil; yalnızca gerekenden katıdır. Tek ek faydası, başarıdan sonra gösterilen bedelin kökün Tier'ini açıkça söylemesidir.)

Danışmanın saat indirimi için öneri: indirim **tahmin, gerçek ve üst saate aynı oranla** uygulansın (ör. × 0,7). Oransal indirim değişmezi korur. Sabit düşüş ise kısa işleri sıfırın altına itebilir.

Saat güvencesinin pratik etkisini de not ediyorum. Büyük fabrikada Planlama 60 olan patron, gizli satır denemesi için her basışta 21 saat pay tutmalı. 40 saatle başarısız denemeler 9'ar saat yaktığında ay içinde en fazla üç gizli deneme yapılabilir. Ayın son ~20 saati yalnızca görünür satırlara kalır. Bu anlamlı bir yönetim kısıtı ve kabul edilebilir. Küçük fabrikada üst saat 11 olduğu için kısıt hafifler.

**5. Küçük fabrikada danışmansız deneme artık mümkün; ama iki arayüz açığı var.**
Örnek ilk oyuncunun küçük fabrikasında (tavan T3):
- Planlama 35 → tahmin 17 bin / 5 saat, üst 45 bin / 11 saat. Oran ≈ 2,6 kat; Tur 14'teki 8 kattan büyük iyileşme.
- Finans 25 → tahmin 8 bin / 3 saat, üst 45 bin / 11 saat. Oran ≈ 5,6 kat; Tur 14'teki 16 kattan büyük iyileşme.
- En kötü durumda (T3 kökü) şanslar: Planlama 35 için iki kademe (≈ %40), Finans 25 için üç kademe (≈ %15). Risk anlamlı ama deneme yapılabilir. Karar Özeti'ndeki "imkânsız değil, riskli" gerekçesi korunuyor.
- Kasanın bu tutarlara yetip yetmediği ekonomi IDEA'sı olmadan söylenemez. Bu yüzden erişim test ölçütü FREEZE öncesi bir kabul koşulu olarak onaylanmalı.

Arayüz açıkları:
- **Ölçek dışı yuvalar:** Küçük fabrikada T4 ve T5 yuvaları hiçbir zaman dolamaz. Kartta bunlar "–" (boş) olarak görünürse, "gizli boş yuva" ile karışır. Öneri: bu yuvalar **"ölçek dışı"** diye ayrı gösterilsin.
- **Tek olası gizli Tier:** Tavan T3 olan küçük fabrikada Planlama 60 olan patronun tek olası gizli Tier'i T3'tür. "Derinlik bilinmiyor" başlığı burada gerçeği yansıtmaz; tahmin, üst bedel ve şans kesin olarak bellidir. Öneri: olası gizli Tier tekse satır o Tier'in şans etiketini göstersin. Bu herkese açık bilgiden çıkar, sızıntı değildir. Adı ve nedeni yine gizli kalsın.

### Kafama Yatmayanlar

- **"Küçük kal" baskın stratejisi:** Küçük fabrikada derin sorun hiç çıkmıyorsa, küçük kalmak güvenli bir strateji olur. Büyüme kârla teşvik edilmezse oyuncu hiç büyümez ve "fabrikayı ayakta tutmak kurmaktan zordur" deneyimi zayıflar. Büyüme teşvikinin ekonomi IDEA'sında açıkça tasarlanması gerekiyor.
- **Ölçek tanımı ayrık olmalı:** Tavanın bir basamak olarak işlemesi için ölçek kesin sınıflara ayrılmalı (küçük / orta / büyük). Sınıfların eşiği (makine sayısı, çıktı, gelir) ekonomi IDEA'sına ait. IDEA-001 yalnızca "ölçek sınıfı görünür ve ayrıktır" kuralını koymalı.
- **Danışmanın saat indirimi hangi puanda geçerli?** Danışmanın ilgili alandaki puanı patronunkinden düşükse de indirim uygulanıyor mu? Önerim: danışman o alanı kartında listeliyorsa indirim uygulansın. Böylece kural basit kalır.
- **Hâlâ açık:** %33 taban köprüsü, ücretli kartlarda pay-to-win ve ucuz bağlı satır sorunu.

### Açık Sorular

Tur 16'dan önce kullanıcının karar vermesi önerilen üç konu:

1. **Ölçek geçişi:** Gizli satırın üst bedeli, satırın ortaya çıktığı aydaki ölçek tavanından mı hesaplansın (c, Claude önerisi)? Yoksa (a) tavan yalnızca artsın mı, (b) küçülmede var olan satırlar kapanana kadar eski tavan mı sürsün?
2. **Saat güvencesi:** Saat bantları örtüşebilsin, ama taban ve tavan Tier ile azalmasın mı? Danışman indirimi tahmin, gerçek ve üst saate aynı oranla mı uygulansın?
3. **Küçük fabrika erişimi:** Ölçek dışı yuvalar ayrı gösterilsin mi? Tek olası gizli Tier varsa şans etiketi gösterilsin mi? "İlk üç ayda her ay en az bir danışmansız gizli deneme" ölçütü FREEZE öncesi kabul koşulu olsun mu?

Diğerleri:

- Danışman puan tavanı ≥ ölçeğin en derin Tier eşiği kuralı kabul edilsin mi?
- Büyüme öncesi "yeni derinlik riski" önizlemesi eklensin mi?
- Büyüme teşviki ve ölçek sınıflarının eşikleri ekonomi IDEA'sına mı taşınsın?

## Açık Kararlar

### Onaylanan FREEZE kapsamı

- **[FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md):** Patronun on adet 0–100 yetkinliğinin bilgi modeli; T1–T5 sorun görünürlüğü; departman kartı; tek “Düzelt”; ortak kök ve ayda tek deneme; danışmanın etkin yetkinlikte `max` katkısı; oluşum ölçeğine bağlı derinlik ve güvence; başarısızlık/başarı bedelinin temel kuralları. Yürürlükteki kesin kapsam FRZ-001 metnindedir.
- **FRZ-001 dışında kalanlar:** Kesin Tier eşikleri ve olasılıklar, para/saat bantlarının tutarları, ölçek sınıflarının ekonomi eşikleri, departman kaybı hesabı, danışman kart piyasasının fiyat/gerçek para dengesi, iflasın ekonomik parametreleri ve stratejik/personel mekanikleri. Bu konulardaki kullanıcı yönlendirmeleri IDEA ve Git tarihinde açık tasarım girdisi olarak korunur, ilgili sonraki IDEA'larda karara bağlanır.
- **Kabul testi:** İlk oyun örneğinin ilk üç ayında gizli sorun oluştuğu her ay en az bir gizli satır oyun parası ve patron zamanı ile, danışman olmadan denenebilmelidir. Bu kullanıcı tarafından seçilen tasarım hedefidir; ekonomi değerleri belirlendiğinde sınanır.

### FRZ-001 dışında açık kalanlar (ilke düzeyinde)

- Danışman sözleşmesi ve dördüncü kartın oyun parası / gerçek para fiyat dengesi; aynı teklifin oyun parasıyla erişilebilirliği ve ücretli rastgele dördüncü kartın uygulama/mevzuat incelemesi. Claude notu: gerçek parayla danışman sözleşmesi GAME_OVERVIEW §26 ve §11 ile gerilim yaratıyor. Kullanıcının iki ödeme seçeneği ve rastgele dördüncü kart kararı korunur; oyun parasıyla makul erişim hedefi, gerçek para fiyatlandırması ve iflas dönemi etkisi henüz kapanmadı.
- Dinamik kart seçiminde "eksik yetkinliği kapatan" profilin tanımı, +10 yüzde puanlık dördüncü kart hedeflemesinin bu seçimle birleşmesi, beşinci çekimde ağırlığın sürüp sürmeyeceği, fiyatlar ve aynı kartın tekrar çıkması. Uygun aday kalmadıysa ödeme öncesi bildirim, geri koymasız çekim ve ücretli/ücretsiz kartların aynı puan bütçesine uyup uymayacağı açık; Claude'un örneğindeki 55+70 ve 75+65 iki alanlı kartlar mevcut 120 puan tavanını aşar. Gizli sorun bilgisi aday seçimiyle sızmamalı.
- Kullanıcı güvence modelini seçti: üst bedel deneme öncesi karşılanır, sonuç anında belirlenir, gerçek bedel aynı ay harcanır; sonraki ay saat borcu ve taksit kullanılmaz. Para için örtüşmeyen Tier bantları, saat için azalmayan taban/tavan “tahmin ≤ gerçek ≤ üst” kuralını kurar. Kesin fiyat/saat değerleri ve danışmanın indirim oranı denge çalışmasına bırakılabilir.
- Fabrika ölçeği olası sorun derinliğini sınırlar ve her satır oluşum ayının ölçek tavanını korur. Küçük/orta/büyük için T3/T4/T5 yalnızca örnektir; ölçek eşikleri ekonomi tasarımında belirlenir. Kullanıcı, örnek ilk oyunun ilk üç ayında danışmansız gizli müdahale erişimini kabul ölçütü olarak seçti: gizli satır varsa her ay en az biri erişilebilir olmalıdır. Testin geçmesi için başlangıç nakdi ve maliyet bantları ayrıca ayarlanır.
- Aynı köke bağlı satırlar tek oluşum olayında birlikte doğar; çünkü sonraki ay daha derin bir satırın eklenmesi önceki güvence tavanını bozardı. Mevcut kökün ileride yeni belirti üretmesi istenirse bu kural ayrı IDEA ile gözden geçirilmelidir.
- Öğrenilmiş ortak kökün görünür satırı varsa gizli bağlı satırda daha ucuz başarısızlık denemesi yapılabilmesi değerlendirilmeli; gizli satırın tahminini grup içinde yükseltmek bağlantı öğrenildikten sonra makul olabilir, fakat henüz karar değildir.
- “Düzelt”in başarı/başarısızlık sonucu anında belirlenir; çözülen satırların üretim kaybının aynı ay mı yoksa sonraki ay raporunda mı geri kazanıldığı henüz kararlaştırılmadı.
- Adsız gizli Tier yuvalarının sırası ve kayıp miktarının Tier'i açığa çıkarmaması arayüz testinde incelenmeli. Mevcut ölçeğin dışındaki yuvalar “ölçek dışı” gösterilir; tek olası gizli Tier varsa şans etiketi görünür, neden gizli kalır.
- %33 departman tabanının fabrika kayıp birimlerine çevrilmesi; departman ağırlığı veya başka basit bir köprü gerekip gerekmediği. Dinamik kartların gerçek parayla erişiminde GAME_OVERVIEW §11 ve §26'ya uygun korkuluklar da açık.

### Denge parametreleri ve testle kesinleşecekler

- Görünür satırda fiilen “kesin/yüksek/orta”, çok olası Tier'li gizli satırda “belirsiz”, tek olası Tier'li gizli satırda uygun sözel şans görünür. “Düşük” bu son durumda ekrana gelebilir. Yaklaşık %80 / %40 / %15 / %5 olasılıkları iç hesap için taslaktır.
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

Kullanıcının yönlendirmeleri: FRZ-001'de açıkça yer alanlar onaylıdır; diğerleri IDEA düzeyinde öneri olarak kalır.

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
- Statlar eşik altı “Düzelt” şansını artırmaz; çünkü kariyer bilgisi statla aşılamamalı, teşhis ve çözüm ilgili alan yetkinliğinden gelmeli.
- Her departman kartında T1–T5 için daima beş satır vardır; her Tier en fazla bir kez görünür ve boş satır “–” olur, çünkü departman kaybı sabit ve okunur bir yapıda sunulmalı.
- Sorun bulunan her satır kendi “Düzelt” butonunu taşır; görünür satırda kök derinliğine göre “kesin/yüksek/orta”, çok olası Tier'li gizli satırda “belirsiz” gösterilir, çünkü tanınan belirtilerin riski sezilebilirken gizli satırın etiketi gerçek Tier'i ele vermemeli.
- Kişi kaynaklı sorunların sıklığını yalnızca patronun kalıcı İnsan Yönetimi puanı azaltır; çünkü danışman bu yatay kariyer yatırımının yerini almamalı.
- İki danışman kartının birleşince on alanı kapsaması yasaklanmaz; çünkü kapsam tek başına derin sorunlarda kesin çözüm sağlamaz, geniş kartların dengesi fiyat ve nadirlikle kurulmalı.
- Sözleşmesi süren danışman aylık aday havuzuna girmez; sözleşme yalnızca ilk yarısında ayrı işlemle uzatılabilir, çünkü aktif kart çekiliş hakkını boşa harcamamalı ve oyuncu devam kararını erken vermeli.
- Dördüncü kart rastgele kalır ve eksik yetkinliği kapatma olasılığı normal çekilişten 10 yüzde puan yüksek olur; çünkü ücretli seçimde oyuncuya daha yararlı bir aday şansı verilmeli.
- Ayda en fazla iki ücretli danışman çekimi yapılır ve beşinci çekim dördüncü kartın yerini alır; çünkü oyuncu bir kez yeniden deneyebilmeli ama sınırsız kart çevirip en iyi adayı garantilememeli.
- Danışman sözleşmesi oyun parası veya gerçek parayla ödenebilir; çünkü oyuncuya iki ödeme seçeneği sunulurken gerçek para zorunlu olmamalı.
- Danışman fiyatında en yüksek iki alan puanı daha ağır basar; çünkü iki zirve uzmanlığı olan kart ciddi bir bedel taşımalı.
- İnsan Yönetimi yaklaşık %80'e kadar kişi kaynaklı sorunları azaltır, kendi alan sorunları da vardır ve kişi kaynaklı sorunlar toplamın yaklaşık %30–40'ıdır; çünkü bu yetkinlik güçlü ama diğer alanların yerini almayan bir yatırım olmalı.
- Ayrı müdür/ekip mekaniği IDEA-001'in kapsamı dışındadır ve daha sonra tasarlanabilir; çünkü bugünkü basit “Düzelt” akışı gelecekte ekip kararlarını kapatmamalı.
- Aynı köke ayda en fazla bir “Düzelt” denemesi yapılır; fabrika genelindeki müdahaleleri para ve patron zamanı sınırlar, çünkü bağlı satırlardan yeniden deneme istismarı engellenmeli ama başka köklere müdahale açık kalmalı.
- Danışman olsa da her sorunlu Tier satırında yalnızca tek “Düzelt” bulunur ve başarı hesabı max(patron, aktif danışmanlar) ile yapılır; çünkü danışman desteği ayrı bir karar menüsü yaratmadan yetkinlik açığını kapatmalı.
- Danışman aynı kök nedeni gidermenin oyun parası maliyetini değiştirmez, patron zamanını azaltır; çünkü sözleşme ücreti ayrıca ödenmiştir ve analiz yükünü danışman üstlenir.
- Departmanın iç modelinde beş Tier yuvası bulunur ve kayıpları departman toplamını açıklar (aynı fabrika örneğinde Planlama 2 + 5 + 3 = 10 birim); çünkü rapordaki kayıp satırlarla matematiksel olarak eşleşmeli.
- Önceki T2 eşiği 50 kalır ve örnekte patron yetkinliği 60 alınır; çünkü 20/50/30 sayıları yetkinlik eşiği değil sorunların kayıp birimleridir.
- Farklı Tier satırları yalnızca aynı departmanda ve en fazla iki kademe aralıkta ortak kök taşıyabilir; çünkü tek neden birkaç kayıp yaratabilmeli, T1–T5 gibi uzak ve şaşırtıcı bağlantılar oluşmamalı.
- Ortak kökün derinliği bağlı satırların en derin Tier'idir ve hangi satırdan basılırsa basılsın başarı buna göre hesaplanır; çünkü görünür kolay satır gizli derin nedeni kesin çözme yoluna dönüşmemeli.
- Aynı köke bağlı satırlar aynı olayda birlikte oluşur ve sonradan köke satır eklenmez; çünkü satırın oluşum ölçeğindeki güvence tavanı kökün gerçek bedelini karşılamaya devam etmeli.
- Patronun erişemediği dolu Tier yuvaları ayrı adsız satırlar olarak görünür; çünkü kayıp ve müdahale imkânı açık kalırken çıkarılamayan kök nedeni gizli kalmalı.
- Aynı oluşum ölçeğindeki gizli satırların para tahmini erişilemeyen en sığ mümkün Tier'in fiyat bandı tabanıyla ortak gösterilir; çünkü satıra özgü farklı tutarlar gerçek Tier'lerini açığa çıkarmamalı.
- Müdahale onayında olası en yüksek para ve saat güvence olarak aranır; sonuç anında belirlenip başarısızlıkta tahmin, başarıda gerçek kök bedeli aynı ay harcanır, çünkü sürpriz borç ve gelecek ay saat felci olmadan derin kökün tam maliyeti karşılanmalı.
- Gizli satırın üst para ve saat güvencesi gerçek sorunlara bakmadan satırın oluştuğu aydaki ölçek tavanından hesaplanır; çünkü ölçek değişimi eski satırın erişimini bozup gizli durumu sızdırmamalı.
- Her Tier'in örtüşmeyen fiyat bandı vardır ve gerçek kök türü bedelini kendi bandından alır; çünkü farklı kökler farklı iş gerektirirken tahmin ≤ gerçek ≤ üst kuralı iade ve kör deneme indirimi doğurmamalı.
- Fabrika ölçeği oluşabilecek en derin sorun Tier'ini sınırlar; çünkü küçük fabrikanın T5 güvencesi yüzünden gizli müdahaleden bütünüyle mahrum kalması önlenmeli.
- Saat bantları örtüşebilir ama tabanları ve tavanları Tier yükselirken azalmaz; çünkü saat tahmini ve güvencesi gerçek müdahale süresini güvenle sınırlamalı.
- Danışmanın saat indirimi geçerliyse tahmin, gerçek ve üst saate aynı oranla uygulanır; çünkü zaman tasarrufu güvenceden de düşmeli ve tahmin ≤ gerçek ≤ üst korunmalı.
- Ölçek dışındaki Tier yuvaları “ölçek dışı” gösterilir ve tek olası gizli Tier kaldıysa şans etiketi açılır; çünkü oyuncunun zaten çıkarabildiği bilgi gereksiz yere “belirsiz” gösterilmemeli.
- Örnek ilk oyunun ilk üç ayında gizli satır varsa her ay en az biri danışmansız denenebilir olmalıdır; çünkü bilgi açığı çözümü imkânsızlaştırmamalı veya ücretli danışmanı fiilen zorunlu kılmamalı.
- Görünür satır, şans etiketinden anlaşılan kök Tier'inin fiyat bandı tabanını gösterir; çünkü etiketin zaten sunduğu bilgiyle tutarlı tahmin verilmeli ve gerçek kök türünün kesin bedeli sonuçta öğrenilmeli.
- Başarısız müdahale aynı köke bağlı satırları o ay görünür biçimde kilitler ve bağlantıyı bildirir; çünkü aynı kökte tekrar deneme önlenmeli ve başarısızlık oyuncuya bilgi vermeli.
- Gizli satırın Tier'i çıkarılamıyorsa çözüm olasılığı “belirsiz” gösterilir; tek olası gizli Tier kalmışsa uygun şans etiketi görünür, çünkü zaten çıkarılabilir bilgiyi gizlemek oyuncuya yarar sağlamaz.
- Patronun ilgili departmandaki tek yetkinlik puanı Tier eşiğiyle doğrudan karşılaştırılır; çünkü ayrı “Görüş Seviyesi” aynı bilgiyi tekrarlar ve gereksiz kavram yaratır.
- Danışman adaylarının gücü fabrika ölçeğine göre sınırlandırılır ve seçim görünür bilgi açıklarına göre dinamik olur; çünkü küçük fabrikanın en güçlü uzmanlara hemen erişmesi ve gizli sorunların kart teklifinden ifşa edilmesi istenmez.
- Her departmanın performansı en az %33 kalır ve fabrika kaybı basit birimlerle departmanlara dağıtılır; çünkü sorunlar matematiksel olarak açıklanırken departman performansı eksiye düşmemeli ve genel rapor kolay okunmalı.
- Fabrika büyüdükçe sorun sayısı artar ve aylık patron zamanı sınırlıdır (40 saat ilk örnek); çünkü büyüme yönetim önceliği ve ileride yetki devri ihtiyacı yaratmalı.
