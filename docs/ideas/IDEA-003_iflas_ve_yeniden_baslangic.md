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

Tur 3 incelemesi, kısa. Kullanıcının isteğiyle yalnızca **erken tasfiye**, **iflas** ve **başarılı fabrika satışı** arasındaki kritik çelişkiler yazıldı. FRZ-001 ve FRZ-002 bağlayıcı kabul edildi. Bu turda yalnızca `Notlar (Claude)` değişti.

### Aldığım Notlar

- Tur 2 düzeltmeleri doğru işlenmiş: net katkı, kredi dahil net pozisyon, ortalama iş havuzu, satış önizlemesi, şirket borcuna finansman gideri ve kişisel borç tavanı.
- FRZ-002'nin kasa formülünün yeni nakit olaylarıyla (kredi, varlık satışı, finansman gideri) güncellenmesi gerektiği doğru biçimde tespit edilmiş.

### Bulduğum Sakıncalar

**1. Kişisel borç tavanı, iflas yaklaşırken borçlanıp parayı şirketten çekmeyi ödüllendiriyor (kritik istismar).**
Şirket borcunun tavanı aşan kısmı karaktere geçmiyor. Başarılı devirde ise net gelir karakterin sermayesi oluyor. Yani şirket parası ile kişisel para arasında bir geçiş var. Bu geçiş iflasa yakın dönemde de açıksa şu yol baskın strateji olur: kriz kredisi al, parayı karaktere aktar, fabrikayı iflasa bırak. Tavanı aşan borç silinir, çekilen para kalır. Öneri, tek kural: **şirketten karaktere para aktarımı yalnızca net pozisyon artıdayken ve borçsuz çıkışta (gönüllü tasfiye veya devir) yapılabilir.** Net pozisyon eksideyken hiçbir kişisel çekim olmaz.

**2. Borçları karşılayan zorunlu tasfiye "iflas" mı sayılıyor, belirsiz (kritik çelişki).**
Eşik, net pozisyonu varlık değerini hiç saymadan ölçüyor. Makinesi değerli bir fabrika eşiği aşabilir, ama %50'lik zorunlu tasfiye bile bütün borcu kapatabilir. Metin gönüllü tasfiye için "borç kapanırsa iflas değil" diyor, zorunlu tasfiye için bir şey söylemiyor. Bu fabrikaya psikoloji düşüşü, acı tecrübe ve "borç bitmeden yeni fabrika yok" kuralı uygulanırsa, borcunu ödeyebilen oyuncu borcunu ödeyemeyen oyuncuyla aynı cezayı alır. Öneri: **iflas sonuçları yalnızca tasfiyeden sonra açık kalırsa uygulansın.** Açık kalmazsa bu bir "zorunlu kapanış" olur; tek bedeli %70 yerine %50 değer kaybıdır ve karakter kalan parayla yeniden başlayabilir.

**3. Başarılı devir, sorun yükünü sıfırlayan bir döngüye dönüşebilir (kritik baskın strateji riski).**
Olgun fabrika zamanla gizli sorun biriktirir. Yeni fabrika bu sorunlar olmadan başlıyorsa, "kârlıyken sat, primle daha büyüğünü sıfırdan kur" döngüsü sorunları yönetmekten her zaman daha kârlı olur. Bu, GAME_OVERVIEW'daki "kurmak kolay, ayakta tutmak zor" kimliğini boşa çıkarır. Önerilen iki kural:
- **Devir değeri yeniden kurma bedelini aşmasın.** Kârlılık primi, mevcut kayıplar düşülmüş gerçekleşen kârdan hesaplansın. Böylece sorun biriktirmiş fabrika düşük değerle satılır.
- **Yeni fabrika bedava temiz sayfa olmasın.** Kuruluşun, üretimsiz geçen bir hazırlık süresi olsun. Sorun üretimi fabrikanın yaşına değil ölçeğine bağlı olsun. Böylece döngüye girmenin gerçek bir bedeli olur.

Sorun üretiminin yaşa değil ölçeğe bağlı olması FRZ-001'in kapsamı dışında kalıyor. Bu yüzden İş Alma/ekonomi tasarımında açıkça korunmalı.

### Kafama Yatmayanlar

- Kapsam gereği bu turda ayrıca not yazılmadı.

### Açık Sorular

**FREEZE durumu: koşullu olarak hazır.** Yukarıdaki üç kuralın her biri tek cümlelik:
1. İflasa yakın dönemde şirketten kişisel para çekimi yok.
2. Borcu karşılayan zorunlu tasfiye iflas sayılmaz.
3. Devir değeri yeniden kurma bedelini aşmaz; kuruluşun hazırlık süresi var.

Kullanıcı bunları onaylarsa ayrı bir tur gerekmez; FREEZE metnine doğrudan eklenebilir. FREEZE, IDEA'nın kendi belirttiği gibi FRZ-002'nin kasa formülünü kredi, varlık/fabrika satışı ve finansman gideriyle genişleten sürümle **birlikte** çıkmalı. Açık Kararlar'daki üç madde sayısal denge konusu olarak FREEZE dışında kalabilir.

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
