# IDEA-003 — İflas ve Yeniden Başlangıç

## Durum/Tur

Durum: DRAFT — Tur 2 sentezi; bu dosya FREEZE değildir.
Tur: 2
Date: 2026-09-29
Bağımlılıklar: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md), [FRZ-002](../freeze/FRZ-002_fabrika_ekonomisi.md).

## Öneri (GPT)

**İflas eşiği.** Kullanıcının yönü: **altı aylık azami aylık brüt kâr potansiyeli, kasadaki açığı karşılamıyorsa fabrika batar.** Formül: `6 × azami aylık brüt kâr < max(0, −kasa)`. Kasa ay sonunda FRZ-002 sırasıyla hesaplanır. Geçici zarar tek başına iflas sayılmaz; eşik yaklaşırken açık uyarı gösterilir. “Azami” değer gerçekleşen son ayın kârı değildir; makine sayısının belirlediği kapasiteye, makine niteliğinin belirlediği kârlılığa ve fabrikanın alabileceği işlere dayanır. Örnek: A/B/C marka torna tezgâhları farklı üretim ve iş yeterlilikleri sağlar; bazı ihaleler belirli tezgâh niteliği ister. Makine yatırımı ve **İş Alma** ayrı IDEA'da tasarlanır. Bu dosya onların sayılarını, marka listesini veya ihale kuralını dondurmaz.

**Kriz hamlesi.** Eşik aşılmadan önce oyuncu kapasiteyi ve nakdi etkileyen makine satışı/küçülme ya da tek seferlik kriz kredisi gibi yolları değerlendirebilir. Satışın kasaya katkısı ile kapasite kaybı aynı hesapta görünmelidir. Kredi borcu artırır; sadece süre kazandırır, iflas eşiğini tek başına iyileştirmez. FRZ-002'nin Düzelt için kullanılabilir nakit güvencesi değişmez. Ayrı sabit “iki aylık kriz penceresi” önerilmez; oyuncunun toparlanma şansı borç/potansiyel eşik oranından gelir.

**Sonrası.** Fabrika kapanır, aynı karakter çalışanlık kariyerine döner; yetkinlikleri ve mevcut statları silinmez. Borç, harcanmış oyun zamanı ve geçici psikoloji düşüşü bedeldir. Claude'un kullanıcının kabul ettiği önerisi: borç taksiti **çalışan gelirinin sabit yüzdesi** olur, işsiz ayda durur ve faiz işlemez; yeni fabrika ancak bu iflas borcu kapandıktan sonra kurulabilir. İflas kaynaklı psikoloji düşüşü zamanla kendiliğinden toparlanır; işten çıkarılma bu özel toparlanma sürecini geriye sarmaz. Yaklaşık bir yılda borcu kapatma ve yaklaşık %25 psikoloji farkı denge hedefi/örneğidir, kesin sayı değildir.

**Öğrenme.** Karakter, en büyük kayba neden olan alanda küçük ve sınırlı bir “acı tecrübe” yetkinlik artışını karakter başına yalnızca bir kez alır. Genel stat kazanım hızı artmaz; kasıtlı tekrarlı iflas bir gelişim yöntemi olmaz.

**Değerlendirme.** İflas ekranı fabrikanın ömrünü, en büyük kayıp alanlarını, görülen ve gizli kalmış sorunları ve göz ardı edilen uyarıları gösterir. Claude'un kullanıcının kabul ettiği önerisi: gizli kökler de **alan, Tier, kök neden ve toplam kayıpla tam açıklanır**; ilgili sorunu kesin görüp çözmek için gereken yetkinlik belirtilir. Bu rapor karakterin puanını artırmaz; sonraki fabrikanın sorunları yeniden oluşur.

Karakterin yaşlanması ve ölümü bu konunun dışında, ayrı çekirdek döngü kararıdır.

## Notlar (Claude)

Tur 1 incelemesi, kısa. Kullanıcının isteğiyle yalnızca **kritik sakıncalar** ve **en fazla üç açık karar** yazıldı. FRZ-001 ve FRZ-002 bağlayıcı kabul edildi. Bu turda yalnızca `Notlar (Claude)` değişti.

### Aldığım Notlar

- Aynı karakterle devam, yetkinlik kaybı yerine tek seferlik "acı tecrübe" ve anlaşılır bir değerlendirme ekranı, kullanıcının önceki yönlendirmeleriyle ve GAME_OVERVIEW'daki "başarısızlık öğretmeli" ilkesiyle uyumlu.

### Bulduğum Sakıncalar

**1. Toparlanma fırsatında oyuncunun kullanabileceği bir kaldıraç yok (kritik).**
Kriz, olağan giderlerin karşılanamadığı anda başlıyor. FRZ-002 §3'e göre kullanılabilir nakit, bu ayın bilinen giderleri düşülerek hesaplanıyor. FRZ-001 §5'e göre de "Düzelt" ancak bu nakit üst güvenceyi karşılıyorsa başlıyor. Krizdeki fabrikada kullanılabilir nakit sıfır ya da eksi olacağı için hiçbir müdahale başlatılamaz. "Toparlanma fırsatı" fiilen iflası beklemekten ibaret kalır. Kriz penceresi en az bir gerçek kaldıraç sunmalı:
- **Küçülme / varlık satışı:** Makine satışı nakit getirir ve ölçeği küçültür. FRZ-001 §6 küçülmeyi zaten tanımlıyor, bu yüzden yeni kural gerekmez.
- **Tek seferlik kriz kredisi:** Toparlanmazsa iflas borcunun bir parçası olur. Böylece 1. ve 2. açık kararlar tek zincire bağlanır.

**2. Borç, düşük psikoloji ve çalışanlık kariyeri, bilinen ölüm sarmalını yeniden kurabilir (kritik).**
GAME_OVERVIEW'daki çalışanlık sistemleri bölümünde "kovulma → psikoloji çöküşü → düşük performans → tekrar kovulma" sarmalı zaten tespit edilmiş. İflastan sonra karakter işe **düşük psikoloji ve borçla** dönüyor. Düşük psikoloji performansı düşürür, kovulma riski artar, maaş kesilir, borç ödenemez, psikoloji daha da düşer. "Yaklaşık bir yılda toparlanma" hedefi bu zincir kırılmadan tutmaz. Öneri:
- İflas kaynaklı psikoloji düşüşü **zamanla kendiliğinden** toparlansın (ör. sabit bir sürede doğrusal). Performans ve kovulma olayları bu toparlanmayı geri çevirmesin.
- Borç taksiti **gelirin sabit bir yüzdesi** olsun. İşsiz kalınan ayda taksit dursun, faiz birikmesin.

**3. Borçluyken yeni fabrika kurmak tanımsız; borç üst üste binebilir (kritik).**
FRZ-002 §4 kuruluş kasası için bir alt sınır koyuyor. Borçlu karakterin bu kasayı nasıl bulacağı ve borcun yeni fabrikaya devredip devretmeyeceği belli değil. Devrederse şu zincir mümkün olur: iflas, borçla yeni fabrika, ikinci iflas, katlanmış borç. Bu, yasaklanan kalıcı sarmalın ta kendisi. Öneri: **yeni fabrika ancak iflas borcu kapandıktan sonra kurulabilsin.** Bu tek kural borç birikmesini önler ve "bir yıl" hedefine somut bir anlam verir: bu süre, yeni girişime hazırlık süresi olur.

### Kafama Yatmayanlar

- Kapsam gereği bu turda ayrıca not yazılmadı.

### Açık Sorular

`Açık Kararlar` 1–3 için öneriler:

1. **İflas tetikleyicisi:** En sade kural şöyle:
   - Ay sonu kasası eksiye düşerse **kriz** başlar ve açık bir uyarı çıkar.
   - Kriz boyunca (ör. 2 ay) küçülme ve kriz kredisi kaldıraçları açıktır.
   - Süre sonunda kasa hâlâ eksideyse **iflas** gerçekleşir.
   - Krizde danışman sözleşmesi de kullanılabilir nakit sınırına tabi olsun; aksi halde oyuncu krizi kendi eliyle derinleştirebilir.
2. **Borç ve psikoloji:**
   - Taksit gelirin sabit bir yüzdesi olsun ve işsizken dursun.
   - Psikoloji zamanla kendiliğinden toparlansın; kovulma zincirine geri beslenmesin.
   - Yeni fabrika ancak borç kapandıktan sonra kurulabilsin.
   - Borç tutarı, bu yüzde ile yaklaşık bir yılda kapanacak biçimde ayarlansın.
3. **Değerlendirme ekranında gizli kökler:** Öneri, **tam açıklama** (Tier, alan, kök neden, toplam kayıp). Bunun oyunu bozmayacak olmasının nedeni şu: sonraki fabrikada sorunlar yeniden üretiliyor ve gizli satırlar yine yalnızca kayıp gösteriyor. Başarı şansı oyuncunun bilgisine değil, yetkinliğe ve danışmana bağlı. Bu yüzden içerik bilgisi mekanik bir avantaj sağlamaz. Ayrıca her gizli kök için "bunu çözmek için şu alanda en az şu yetkinlik gerekirdi" satırı eklenmeli; sonraki kariyerin öğrenme hedefini doğrudan bu verir.

## Açık Kararlar

1. `50K × 6 = 300K` ve kasa `−300K` örneğinde iflas olsun mu? Yazılan `<` eşitsizliğinde **olmaz**; örnekte iflas isteniyorsa sınır `≤` olarak yazılmalıdır.
2. Eşikteki “azami brüt kâr” mı, “azami gelir” mi esas alınacak? Maliyetler yüzünden farklıdır. İş Alma tasarımı gelene kadar potansiyelin hangi iş havuzundan hesaplanacağı da açık kalır.
3. Kriz kredisinin hangi koşulda işe yaradığı ve makine satışının borç/kapasite hesabı, İş Alma ve yatırım sistemi tasarlanırken sınanmalıdır.

## Karar Özeti

- Altı aylık üretim/kâr potansiyeli kasa açığını karşılayamıyorsa iflas yönü seçildi; çünkü fabrikanın borcu kurtarma kapasitesiyle ölçülmeli, tek kötü ay otomatik son olmamalıdır. Eşitlik ve gelir/kâr terimi açıktır.
- İflas sonrası aynı karakterin borcu gelir yüzdesiyle, işsizken faizsiz/ödemesiz kapatması ve psikolojisinin kendiliğinden toparlanması benimsendi; çünkü oyuncu borç ve performans sarmalına kilitlenmemelidir.
- İflas borcu bitmeden yeni fabrika kurulmaması benimsendi; çünkü tekrar iflaslarla borçların üst üste binmesi engellenmelidir.
- Gizli köklerin iflas raporunda tam açıklanması benimsendi; çünkü başarısızlık sonraki kariyere somut öğrenme hedefi bırakmalıdır.
- Bir kez sınırlı “acı tecrübe” yetkinliği ve genel stat hızı artışı olmaması korundu; çünkü oyuncu başarısızlıktan öğrenmeli ama iflas bir puan toplama yöntemi olmamalıdır.
