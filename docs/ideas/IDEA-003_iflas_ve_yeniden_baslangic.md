# IDEA-003 — İflas ve Yeniden Başlangıç

## Durum/Tur

Durum: DRAFT — Tur 2 sentezi; bu dosya FREEZE değildir.
Tur: 2
Date: 2026-09-29
Bağımlılıklar: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md), [FRZ-002](../freeze/FRZ-002_fabrika_ekonomisi.md).

## Öneri (GPT)

**İflas eşiği.** Kullanıcının kararı: **kasa eksideyse ve açık, fabrikanın azami aylık brüt kârının altı katına eşit veya daha büyükse fabrika batar.** Formül: `kasa < 0 ve −kasa ≥ 6 × azami aylık brüt kâr`. Örneğin en iyi performansta aylık **50K brüt kâr** üretebilen fabrika, kasa **−300K** olduğunda batar: en iyi durumda bile altı ay yalnızca borca çalışması gerekecektir. Kasa ay sonunda FRZ-002 sırasıyla hesaplanır. Geçici zarar tek başına iflas sayılmaz; eşik yaklaşırken açık uyarı gösterilir. “Azami” değer gerçekleşen son ayın kârı değildir; makine sayısının belirlediği kapasiteye, makine niteliğinin belirlediği kârlılığa ve fabrikanın alabileceği işlere dayanır. Örnek: A/B/C marka torna tezgâhları farklı üretim ve iş yeterlilikleri sağlar; bazı ihaleler belirli tezgâh niteliği ister. Makine yatırımı ve **İş Alma** ayrı IDEA'da tasarlanır. Bu dosya onların sayılarını, marka listesini veya ihale kuralını dondurmaz.

**Kriz hamlesi.** Eşik aşılmadan önce oyuncu kapasiteyi ve nakdi etkileyen makine satışı/küçülme ya da tek seferlik kriz kredisi gibi yolları değerlendirebilir. Satışın kasaya katkısı ile kapasite kaybı aynı hesapta görünmelidir. Kredi borcu artırır; sadece süre kazandırır, iflas eşiğini tek başına iyileştirmez. FRZ-002'nin Düzelt için kullanılabilir nakit güvencesi değişmez. Ayrı sabit “iki aylık kriz penceresi” önerilmez; oyuncunun toparlanma şansı borç/potansiyel eşik oranından gelir.

**Sonrası.** Fabrika kapanır, aynı karakter çalışanlık kariyerine döner; yetkinlikleri ve mevcut statları silinmez. Borç, harcanmış oyun zamanı ve geçici psikoloji düşüşü bedeldir. Claude'un kullanıcının kabul ettiği önerisi: borç taksiti **çalışan gelirinin sabit yüzdesi** olur, işsiz ayda durur ve faiz işlemez; yeni fabrika ancak bu iflas borcu kapandıktan sonra kurulabilir. İflas kaynaklı psikoloji düşüşü zamanla kendiliğinden toparlanır; işten çıkarılma bu özel toparlanma sürecini geriye sarmaz. Yaklaşık bir yılda borcu kapatma ve yaklaşık %25 psikoloji farkı denge hedefi/örneğidir, kesin sayı değildir.

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

1. “Azami brüt kâr” potansiyelinin hangi ulaşılabilir iş havuzundan hesaplanacağı, İş Alma sistemi tasarlanırken netleşmelidir.
2. Kriz kredisinin hangi koşulda işe yaradığı ve makine satışının borç/kapasite hesabı, İş Alma ve yatırım sistemi tasarlanırken sınanmalıdır.

## Karar Özeti

- Kasa açığı azami **aylık brüt kârın altı katına eşit veya daha büyükse** fabrika batar; çünkü en iyi performansta bile altı ay yalnızca borca çalışmak gerekecek ve tek kötü ay otomatik son olmayacaktır.
- İflas sonrası aynı karakterin borcu gelir yüzdesiyle, işsizken faizsiz/ödemesiz kapatması ve psikolojisinin kendiliğinden toparlanması benimsendi; çünkü oyuncu borç ve performans sarmalına kilitlenmemelidir.
- İflas borcu bitmeden yeni fabrika kurulmaması benimsendi; çünkü tekrar iflaslarla borçların üst üste binmesi engellenmelidir.
- Gizli köklerin iflas raporunda tam açıklanması benimsendi; çünkü başarısızlık sonraki kariyere somut öğrenme hedefi bırakmalıdır.
- Bir kez sınırlı “acı tecrübe” yetkinliği ve genel stat hızı artışı olmaması korundu; çünkü oyuncu başarısızlıktan öğrenmeli ama iflas bir puan toplama yöntemi olmamalıdır.
