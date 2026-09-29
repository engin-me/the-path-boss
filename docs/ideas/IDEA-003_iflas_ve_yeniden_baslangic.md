# IDEA-003 — İflas ve Yeniden Başlangıç

## Durum/Tur

Durum: DRAFT — Tur 3 sentezi; bu dosya FREEZE değildir.
Tur: 3
Date: 2026-09-29
Bağımlılıklar: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md), [FRZ-002](../freeze/FRZ-002_fabrika_ekonomisi.md).

## Öneri (GPT)

**İflas eşiği.** Kullanıcının altı aylık toparlanma fikri, kabul ettiği Claude düzeltmesiyle **borca ayrılabilecek azami aylık net katkı** üzerinden ölçülür: `net katkı = max(0, azami aylık brüt kâr − aylık olağan giderler)`, `net pozisyon = kasa − ödenmemiş şirket/kriz kredisi bakiyesi`. Net pozisyon eksideyse ve `−net pozisyon ≥ 6 × net katkı` ise fabrika iflas eder. Azami brüt kâr, son ayın gerçekleşen kârı değil; makine sayısı/kalitesi ile alınabilir işler üzerinden hesaplanan potansiyeldir. Örneğin 50K azami brüt kâr ve sıfır olağan giderde −300K net pozisyon iflastır; olağan gider 40K ise katkı 10K, eşik −60K olur. Net katkı sıfırken net borç varsa eşik sıfırdır. Ay sonu kasa FRZ-002 sırasıyla hesaplanır; eşik yaklaşırken açık uyarı gösterilir. Makine markalarının kapasite, iş yeterliliği ve kârlılık farkı ile **İş Alma** ayrı IDEA'da tasarlanır.

**Kriz hamlesi.** Eşik aşılmadan önce makine satışı/küçülme veya tek seferlik kriz kredisi değerlendirilebilir. Kredi nakdi artırırken aynı tutarda borç yarattığından **net pozisyonu tek başına iyileştirmez**; işletmeye kısa vadeli harcama olanağı verir. Makine satışı onayında satış sonrası net açık, düşen kapasite ve **yeni iflas eşiği** birlikte gösterilir; eşik satışla aşılabilir. İş havuzunun oynaklığı için azami katkı yakın dönem alınabilir işlerin ortalamasından hesaplansın ve yalnızca ay sonunda güncellensin. Eksi şirket net pozisyonuna düşük, önceden görünen aylık finansman gideri işlensin; böylece borçlu fabrikanın hiçbir şey yapmadan süresiz beklemesi cazip olmaz. Bu gider çalışanlık dönemindeki kişisel borca uygulanmaz. FRZ-002'nin Düzelt güvencesi değişmez. Sabit kriz süresi eklenmez.

**Erken tasfiye ve fabrika satışı.** Oyuncu zorunlu iflastan önce fabrikayı gönüllü kapatıp yatırımlarını satabilir. Makine/varlıklar normal satışta referans değerinin yaklaşık **%70'i**, zorunlu iflas tasfiyesinde yaklaşık **%50'si** üzerinden değerlendirilsin; oranlar kullanıcı örneği ve ilk denge hedefidir. “Yatırım” görünümünde yatırılmış toplam, her varlığın ve bütün fabrikanın **bu ay sonundaki tahmini satış değeri**, borçlar ve oyuncuya kalacak net tutar ayrı gösterilsin. Tasfiye geliri şirket borçlarını kapatırsa bu **iflas değil gönüllü çıkıştır**: karakter kalan parayla, FRZ-002'nin kuruluş kasası koşulunu karşılayarak yeni fabrika kurabilir. Satış gelirinden sonra açık kalırsa şirket tasfiye edilir, kişisel borç/psikoloji/öğrenme kurallarıyla **iflas** gerçekleşir; makineyi erken satmak daha az kişisel kayıp yaratabilir.

**Başarılı fabrikanın devri.** İşleri iyi giden fabrika da **çalışır işletme olarak** satılabilsin. Değer, yalnızca tezgâhların ikinci el bedeli değil; kanıtlanmış sürdürülebilir kârlılık ve iş alma kapasitesini de yansıtsın, borçlar satışta düşülsün. Net satış geliri karakterin yeni fabrika kurma sermayesi olur. Aynı gün al-satla bedelsiz büyüme olmaması için kârlılık primi ancak belli bir faaliyet geçmişiyle oluşsun; kesin değerleme formülü İş Alma/yatırım tasarımında belirlensin. Bu çıkış **iflasın psikoloji ve acı tecrübe sonuçlarını tetiklemez**.

**FREEZE bağımlılığı.** FRZ-002'nin mevcut kasa formülünde kredi, varlık/fabrika satışı ve finansman gideri ayrıca tanımlı değildir. Bu taslak söz konusu nakit olaylarını önerir; onaylanırsa FRZ-002 ile uyumlu yeni FREEZE sürümü gerekir. Bu IDEA mevcut FREEZE metnini değiştirmez.

**İflas sonrası.** Şirket borcu ile karakterin kişisel borcu ayrılır. Şirket varlıkları zorunlu tasfiye değeriyle borca sayılır; karaktere geçen kalan borç, beklenen çalışan gelirinden yaklaşık bir yılda ödenebilecek **tavanla** sınırlanır. Böylece büyük fabrika iflası karakteri kalıcı borca kilitlemez. Aynı karakter çalışanlık kariyerine döner; yetkinlikleri ve mevcut statları silinmez. Kişisel borç taksiti çalışan gelirinin sabit yüzdesidir, işsiz ayda durur ve faiz işlemez; yeni fabrika ancak bu borç kapandıktan sonra kurulabilir. İflas kaynaklı psikoloji düşüşü zamanla kendiliğinden toparlanır; işten çıkarılma bu özel toparlanma sürecini geriye sarmaz. Yaklaşık bir yıllık ödeme ve yaklaşık %25 psikoloji farkı ilk denge hedefi/örneğidir.

**Öğrenme.** Karakter, en büyük kayba neden olan alanda küçük ve sınırlı bir “acı tecrübe” yetkinlik artışını karakter başına yalnızca bir kez alır. Genel stat kazanım hızı artmaz; kasıtlı tekrarlı iflas bir gelişim yöntemi olmaz.

**Değerlendirme.** İflas ekranı fabrikanın ömrünü, en büyük kayıp alanlarını, görülen ve gizli kalmış sorunları ve göz ardı edilen uyarıları gösterir. Claude'un kullanıcının kabul ettiği önerisi: gizli kökler de **alan, Tier, kök neden ve toplam kayıpla tam açıklanır**; ilgili sorunu kesin görüp çözmek için gereken yetkinlik belirtilir. Bu rapor karakterin puanını artırmaz; sonraki fabrikanın sorunları yeniden oluşur.

Karakterin yaşlanması ve ölümü bu konunun dışında, ayrı çekirdek döngü kararıdır.

## Notlar (Claude)

Tur 2 incelemesi, kısa. Yalnızca kritik sakıncalar ve en fazla üç açık karar yazıldı. FRZ-001 ve FRZ-002 bağlayıcı kabul edildi. Bu turda yalnızca `Notlar (Claude)` değişti.

### Aldığım Notlar

- Tur 1 önerileri doğru işlenmiş: gelir yüzdesiyle faizsiz taksit, işsizken ödeme durması, psikolojinin kendiliğinden toparlanması, borç bitmeden yeni fabrika kurulamaması ve iflas raporunda tam açıklama.
- "Eşik = potansiyelin katı" fikri, sabit kriz penceresinden daha anlamlı. Büyük fabrikaya daha uzun, küçük fabrikaya daha kısa bir nefes verir.

### Bulduğum Sakıncalar

**1. Formül iki yerden yanlış ölçüyor: brüt kâr ve kredi (kritik).**
- **Brüt kâr olağan giderleri içermiyor.** Azami brüt kârı 50K, olağan gideri 40K olan fabrika en iyi ayda borca yalnızca 10K ayırabilir. "Altı ay borca çalışır" gerekçesi gerçekte 30 ay eder. Gider brüt kârı aşıyorsa fabrika hiç toparlanamaz ama eşik yine 300K görünür. Öneri: eşik, **azami aylık net katkı** (azami brüt kâr − olağan giderler) üzerinden hesaplansın. Net katkı sıfır veya eksiyse eşik açıkça sıfıra düşer ve oyuncu fabrikanın yapısal olarak zarar ettiğini görür.
- **Kredi formülde yok.** Kriz kredisi kasaya para olarak girerse açık küçülür ve eşik iyileşir. Bu, "kredi eşiği tek başına iyileştirmez" cümlesiyle çelişir. Öneri: formül `kasa` yerine **net pozisyon = kasa − kriz kredisi bakiyesi** kullansın.

**2. İflas borcu fabrika ölçeğine bağlı; "bir yılda ödenir" ve "borç bitmeden yeni fabrika yok" kurallarıyla birlikte kalıcı kilit yaratır (kritik).**
İflas anında açık, azami potansiyelin en az 6 katı. Büyük bir fabrikada bu, çalışan maaşının yüzdesiyle bir yılda değil on yıllarda kapanır. "Borç bitmeden yeni fabrika yok" kuralıyla birleşince karakter bir daha fabrika kuramaz. Bu, Tur 2'nin önlemek istediği kalıcı sarmalın ta kendisi. Öneri: **şirket borcu ile kişisel borç ayrılsın.**
- Açığın büyük kısmı fabrikanın tasfiyesiyle (makineler, alacaklar) kapanmış sayılır.
- Karakterin **kişisel borcu**, beklenen çalışan geliri yüzdesiyle yaklaşık bir yılda kapanacak bir **tavanla** sınırlanır.
- İflasın bedeli yine hissedilir (bir yıl, psikoloji, kaybedilen sermaye), ama ölçeğe göre sonsuza uzamaz.

**3. Eşik oynak: küçülme hamlesi oyuncuyu iflasa itebilir, pazar dalgalanması iflas yaratabilir (kritik).**
Eşik azami potansiyele bağlı, potansiyel de makinelere ve alınabilir işlere dayanıyor.
- Örnek: kasa −200K, potansiyel 50K, eşik 300K. Makine satışı +50K getirir, açık 150K'ye iner. Ama potansiyel 20K'ye düşer, eşik 120K olur ve fabrika **satış anında batar**. Kriz hamlesi tuzağa dönüşür.
- Alınabilir iş havuzu ay ay değişirse, oyuncu hiçbir şey yapmadan eşik altına düşebilir.

Öneri:
- Makine satışı onay ekranında **"satıştan sonra açık / yeni eşik"** önizlemesi zorunlu olsun.
- Potansiyel, iş havuzunun **ortalamasına** (ör. son birkaç ayın) dayansın ve yalnızca ay sonunda güncellensin.

### Kafama Yatmayanlar

- **Zombi fabrika riski:** Açık faiz işletmiyor ve süre sınırı yok. Fabrika eşiğin hemen altında aylarca kalabilir. Bu sürede kullanılabilir nakit eksi olduğu için FRZ-002'ye göre Düzelt ve danışman kapalıdır; oyuncunun yapabileceği tek şey beklemek olur. Açığa küçük bir maliyet (ör. aylık faiz) konursa sonuç netleşir. Sabit pencere istenmediği için bu, pencere yerine sadece bir yön verir.

### Açık Sorular

1. Eşik, azami **net katkı** (brüt kâr − olağan giderler) ve **kredi dahil net pozisyon** üzerinden hesaplansın mı (Claude önerisi)?
2. İflasta şirket borcu ile kişisel borç ayrılsın ve kişisel borç yaklaşık bir yıllık ödeme tavanıyla sınırlansın mı (Claude önerisi)?
3. Makine satışında yeni eşik önizlemesi zorunlu olsun, potansiyel iş havuzu ortalamasıyla yalnızca ay sonunda güncellensin mi (Claude önerisi)? Açığa küçük bir faiz konulsun mu?

## Açık Kararlar

1. İkinci el varlıkların **referans değeri** alış bedeli mi, güncel piyasa değeri mi olmalı? Erken satış %70 ve zorunlu tasfiye %50 oranlarının kesin dengesi yatırım tasarımında sınanmalıdır.
2. Çalışır fabrikanın kârlılık primi hangi faaliyet geçmişiyle kazanılmalı; aynı gün al-sat istismarını hangi sade kural önlemeli?
3. Azami net katkı için yakın dönem alınabilir iş havuzu, şirket borcunun finansman gideri ve kişisel borç tavanının kesin hesabı İş Alma/ekonomi dengesinde netleşmelidir.

## Karar Özeti

- Net pozisyon açığı, olağan giderlerden sonraki azami aylık **net katkının altı katına eşit veya daha büyükse** fabrika batar; çünkü en iyi performansta altı ayda ödenemeyecek borç, tek kötü aydan daha anlamlı iflas ölçüsüdür.
- Şirket kredisi net pozisyonda borç sayılır, azami katkı yakın dönem iş havuzuyla ay sonunda güncellenir ve makine satışında yeni eşik önizlenir; çünkü krediyle eşik aşılmamalı ve satışın iflas etkisi oyuncuya görünmelidir.
- Borçlu şirkete görünen küçük finansman gideri uygulanır; çünkü müdahale yapamayan fabrikanın süresiz beklemesi bir çıkış yolu olmamalıdır.
- Şirket ve kişisel borç ayrılır, kişisel borç yaklaşık bir yıllık çalışma ödemesiyle sınırlanır; çünkü büyük fabrika kaybı aynı karakterin gelecek girişimini kalıcı olarak kilitlememelidir.
- Erken varlık tasfiyesi, zorunlu tasfiyeden daha yüksek değerle yapılabilir; çünkü kötü gidişi erken gören oyuncu daha az kayıpla çıkabilmelidir. %70/%50 oranları denge örneğidir.
- Kârlı fabrika çalışır işletme olarak satılıp net gelirle daha büyük bir fabrika kurulabilir; çünkü başarılı işletmeyi devretmek oyuncuya yeni bir büyüme kararı sunar. Değerleme ayrıntısı açıktır.
- İflas sonrası aynı karakterin borcu gelir yüzdesiyle, işsizken faizsiz/ödemesiz kapatması ve psikolojisinin kendiliğinden toparlanması benimsendi; çünkü oyuncu borç ve performans sarmalına kilitlenmemelidir.
- İflas borcu bitmeden yeni fabrika kurulmaması benimsendi; çünkü tekrar iflaslarla borçların üst üste binmesi engellenmelidir.
- Gizli köklerin iflas raporunda tam açıklanması benimsendi; çünkü başarısızlık sonraki kariyere somut öğrenme hedefi bırakmalıdır.
- Bir kez sınırlı “acı tecrübe” yetkinliği ve genel stat hızı artışı olmaması korundu; çünkü oyuncu başarısızlıktan öğrenmeli ama iflas bir puan toplama yöntemi olmamalıdır.
