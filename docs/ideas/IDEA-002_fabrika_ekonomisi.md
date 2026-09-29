# IDEA-002 — Fabrika Ekonomisi

## Durum/Tur

Durum: DRAFT — GPT kısa önerisi, Claude incelemesi bekleniyor
Tur: 1
Date: 2026-09-29
Bağımlılık: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md). Bu dosya FREEZE değildir.

## Öneri (GPT)

Ay sonu raporu üç ana sayı göstersin: **beklenen çıktı, gerçekleşen çıktı, çıktı kaybı**. Beklenen çıktı makine kapasitesi, ürün ve talebe göre belirlenir. **Çıktıyı etkileyen** sorun satırlarının kayıpları kendi departman toplamını; bu toplamlar da fabrikanın çıktı kaybını açıklar. Nakit veya gelecekteki fırsatı etkileyen sorunların kaybı kendi birimiyle gösterilir. Aynı kayıp iki kez sayılmaz. İlk sürümde çıktı kayıpları toplanır; çarpımsal hesap kullanılmaz.

Oyuncunun nakit hesabı açık olsun: **önceki nakit + satış geliri − olağan işletme giderleri − danışman sözleşmeleri − Düzelt bedelleri = yeni nakit**. Satış geliri gerçekleşen çıktıya bağlıdır. Tam gider listesi ve tutarları bu fikrin parçası değil, sonraki denge işidir.

“Düzelt” sonucu anında belli olur; **çıktıdaki iyileşme bir sonraki ayın raporuna** yansısın. Böylece oyuncu müdahalenin parasını bu ay öder, faydasını sonraki ay görür. Rapor geçmiş ayı yeniden yazmaz.

İlk ekonomi dengesi, [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md)'deki kabul testini geçmeli: ilk üç ayda gizli sorun varsa oyuncu her ay en az birini oyun parası ve patron zamanıyla, danışmansız deneyebilmeli. Tek kötü ay doğrudan kaçınılmaz iflas yaratmamalı.

## Notlar (Claude)

Tur 1 incelemesi, kısa. Kullanıcının isteğiyle yalnızca **kritik çelişkiler** ve **üç açık karar** ele alındı. FRZ-001 bağlayıcı kabul edildi. Bu turda yalnızca `Notlar (Claude)` değişti.

### Aldığım Notlar

- Üç sayılı rapor, açık nakit formülü ve "fayda sonraki raporda" kuralı sade ve FRZ-001'in anında sonuç ve aynı ay harcama kurallarıyla uyumlu.
- FRZ-001 kabul testinin ekonominin kabul koşulu yapılması doğru.

### Bulduğum Sakıncalar

**1. Ay içindeki "mevcut nakit" tanımsız; güvence kontrolü ile ay sonu giderleri çakışıyor (kritik).**
FRZ-001 §5'e göre "Düzelt" ancak **mevcut oyun parası** üst bedeli karşılıyorsa başlar. Nakit formülü ise aylık toplam olarak yazılmış. Oyuncu ay içinde bütün nakdi güvenceden geçen müdahalelere harcayabilir. Ay sonunda olağan giderler satış gelirini aşarsa nakit eksiye düşer. Bu, FRZ-001'in "sürpriz para borcu aktarılmaz" gerekçesini ve bu IDEA'nın "tek kötü ay iflas yaratmamalı" hedefini dolaylı yoldan deler. Öneri:
- Zaman çizelgesi açıkça yazılsın: **rapor → kararlar (danışman, Düzelt; anında harcanır) → ay işler (satış geliri, olağan giderler) → sonraki rapor**.
- Güvence kontrolündeki **kullanılabilir nakit = nakit − bu ayın bilinen olağan giderleri** olsun. Gelir belirsiz olduğu için sayılmasın.
- Böylece güvenceden geçen bir müdahale ay sonunda nakdi hiçbir zaman eksiye itemez.

**2. "Aynı kayıp iki kez sayılmaz" cümlesi FRZ-001'deki bağlı satırlarla yanlış okunabilir.**
FRZ-001'e göre bağlı satırlar ayrı belirtilerdir; kayıpları toplanır, kök müdahalesi hepsini birlikte kaldırır. Yasak şöyle yazılmalı: **her kayıp birimi tek bir satıra aittir.** Asıl risk departmanlar arasıdır: aynı malzeme yokluğu hem Satın Alma'da hem Üretim'de satır olarak görünmemeli. Kayıp, kökün bulunduğu departmanın satırında durur (FRZ-001 bağlantıları zaten departman içidir).

**3. İki ayrı kayıp birimi gizli Tier'i sızdırabilir (kritik; FRZ-001 §2 ile çelişki riski).**
FRZ-001'e göre gizli satır kayıp miktarını gösterir. Aynı departmanda bazı Tier'ler çıktı birimi, bazıları nakit birimiyle kayıp üretirse, gizli satırın birimi türünü, dolayısıyla Tier'ini ele verebilir. Satın Alma'nın kendi örneği bunu gösteriyor: T1 "yüksek fiyat" nakit kaybıdır, T2 "kötü termin" çıktı kaybıdır. Bu yüzden 1. açık karar gerçekte bir sızıntı kararıdır.

### Kafama Yatmayanlar

- "Tek kötü ay iflas yaratmamalı" hedefi, iflas tetikleyicisi tanımlanmadan ölçülemiyor. Tetikleyici tek ay eksi nakit değil, art arda birkaç ay veya bir borç sınırı olmalı. Bu kural iflas tasarımına ait, ama bu IDEA'nın testi ona bağlı.

### Açık Sorular

`Açık Kararlar` 1–3 için değerlendirme ve öneri:

**1. Çıktı ile nakit/gelecek ayrımı:** Öneri, ayrım **yapılmasın**. Bütün on alanın kayıpları tek bir ortak birimle, **"çıktı eşdeğeri birim"** ile gösterilsin.
- Nakit kaybı sabit bir birim değeriyle çevrilir (ör. yüksek fiyat, faiz, ceza).
- Satış kaybı gerçekleşen çıktıdan düşer.
- Kullanıcının "100 birim beklenen" modeli korunur, departmanlar toplanabilir ve Sakınca 3'teki sızıntı kapanır.
- Kaybın gerçekte nakit mi çıktı mı olduğu yalnızca sonuç metninde anlatılır.
- Ar-Ge/Yatırım'ın "gelecek fırsat" etkisi (talep, yeni ürün) ilk sürümde aylık birim eşdeğeri kayıp olarak modellenir; gerçek gelecek etkisi ayrı IDEA'ya ertelenir.

**2. Departman sınırı ve %33:** Öneri, iki basit sayı.
- **Fabrika tabanı:** Gerçekleşen çıktı, beklenenin en az %33'ü olur.
- **Departman tavanı:** Bir departmanın kaybı beklenenin en fazla ~%20'si olur. Bu, %33 departman tabanının departman başına yaklaşık 30 birimlik ağırlıkla karşılığıdır (30 × 0,67 ≈ 20). Kullanıcının örneğindeki en büyük kayıplar olan Satın Alma 20 ve Üretim 20 ile de tutarlı.
- Departman ağırlığı tablosuna gerek kalmaz.
- Tavana ulaşmış departmanda yeni sorun doğmaz. Bu, görünür kayıptan çıkarılabilen bir bilgi olduğu için sızıntı yapmaz.

**3. Sayılar:** Sayıların ilke onayından sonra belirlenmesine katılıyorum. Yalnız iki yapısal kural şimdiden konmalı:
- **Tier fiyat bantları, ölçeğin aylık birim değeriyle orantılı** olsun. Aksi halde bantlar büyük fabrikada önemsiz, küçük fabrikada erişilmez olur.
- **Kabul testinden türeyen bir alt sınır** konsun: başlangıç nakdi ≥ bir aylık olağan gider + küçük ölçeğin olası en derin Tier tavanı (üst güvence). Bu, FRZ-001 §6'daki erken erişim koşulunun ekonomideki karşılığıdır.

Kullanıcının karar vermesi önerilen üç konu:

1. Bütün alanlar tek "çıktı eşdeğeri birim" ile mi gösterilsin (Claude önerisi)?
2. Fabrika tabanı %33 ve departman tavanı ~%20 kabul mü (Claude önerisi)?
3. Güvence kontrolünde bu ayın bilinen olağan giderleri kullanılabilir nakitten düşülsün mü (Claude önerisi)?

## Açık Kararlar

1. On yetkinlik alanının hangileri **bu ayın üretim çıktısını**, hangileri **nakit veya gelecek fırsatlarını** etkiler?
2. Departmanların kayıp birimlerine katkısı nasıl sınırlandırılır? Önceki taslaktaki **%33 departman performans tabanı** korunacaksa fabrika birimlerine nasıl çevrilir?
3. Ekonomi testinde başlangıç parası, aylık gelir/gider ve Tier fiyat bantlarının sayıları ne olmalı? Bunlar ilke onayından sonra denge çalışmasında belirlensin.

## Karar Özeti

IDEA-002 için henüz kullanıcı tarafından onaylanmış karar yok. Yukarıdaki model inceleme önerisidir; FRZ-001 kuralları geçerlidir.
