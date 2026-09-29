# IDEA-003 — İflas ve Yeniden Başlangıç

## Durum/Tur

Durum: DRAFT — Claude incelemesi bekleniyor; bu dosya FREEZE değildir.
Tur: 1
Date: 2026-09-29
Bağımlılıklar: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md), [FRZ-002](../freeze/FRZ-002_fabrika_ekonomisi.md).

## Öneri (GPT)

**İflas eşiği.** Tek bir kötü ay fabrikayı otomatik kapatmasın. Olağan yükümlülükler karşılanamadığında oyuncuya açık bir kriz uyarısı ve kısa bir toparlanma fırsatı verilsin. İflas, bu fırsata rağmen fabrikanın ödeme gücü geri kazanılamadığında gerçekleşsin. Kesin süre ve finansal eşik, ekonomi dengesiyle birlikte belirlensin; FRZ-002'nin nakit ve gider sırası korunsun.

**Sonrası.** Fabrika kapanır, aynı karakter çalışanlık kariyerine döner. Yetkinlikleri ve mevcut statları silinmez. Borç, harcanmış oyun zamanı ve geçici psikoloji düşüşü başarısızlığın bedelidir. Borç, makul çalışmayla yaklaşık bir oyun yılında kapatılabilecek ölçekte hedeflenir; bu süre ve yaklaşık %25 psikoloji farkı şimdilik örnektir. Borç ödemesi karakteri yeniden fabrika kuramayacağı kalıcı bir sarmala sokmamalıdır.

**Öğrenme.** Karakter, en büyük kayba neden olan alanda küçük ve sınırlı bir “acı tecrübe” yetkinlik artışını karakter başına yalnızca bir kez alır. Genel stat kazanım hızı artmaz; kasıtlı tekrarlı iflas bir gelişim yöntemi olmaz.

**Değerlendirme.** İflas ekranı fabrikanın ömrünü, en büyük kayıp alanlarını, görülen ve gizli kalmış sorunları ve göz ardı edilen uyarıları anlaşılır biçimde gösterir. Oyuncu sonraki kariyerinde hangi bilgiyi veya desteği arayacağını anlayabilmelidir. Gizli nedenlerin ne kadarının açıklanacağı sonraki ayrıntı kararıdır.

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

1. Oyuncuya anlaşılır uyarı ve toparlanma fırsatı veren en sade iflas tetikleyicisi nedir?
2. Borç ve psikoloji etkisi yaklaşık bir yılda toparlanmayı nasıl destekler; kalıcı başarısızlık sarmalı nasıl önlenir?
3. Değerlendirme ekranı gizli kök nedenleri ne ölçüde açığa çıkarmalı?

## Karar Özeti

- Bu turda yeni nihai karar yoktur. Önceki kullanıcı yönlendirmesi: aynı karakterle devam, borç ve geçici psikoloji bedeli, yetkinlik kaybı yerine bir kez sınırlı öğrenme; çünkü başarısızlık öğretmeli ve yeniden denemeyi mümkün kılmalıdır. Bu maddeler henüz FREEZE değildir.
