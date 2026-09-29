# IDEA-002 — Fabrika Ekonomisi

## Durum/Tur

Durum: FRZ-002 çekirdek kapsamı kullanıcı tarafından onaylandı; kesin denge konuları açık
Tur: 2
Date: 2026-09-29
Bağımlılık: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md). Bu dosya FREEZE değildir.
Onaylı çekirdek: [FRZ-002](../freeze/FRZ-002_fabrika_ekonomisi.md). Yürürlükteki kurallar bu FREEZE dosyasındadır.

## Öneri (GPT)

**Tek rapor birimi.** Ay sonu raporu **beklenen, gerçekleşen ve kaybedilen çıktı eşdeğeri birimi** göstersin. Makine kapasitesi, ürün ve talep beklenen değerin temelidir. Bütün on alanın kaybı aynı birime çevrilir; fiziksel üretim kaybı, fazla maliyet ve ilk sürümde gelecek fırsatı kaybı raporda karşılaştırılabilir olur. Her kayıp birimi **tek bir sorun satırına** ve kökün bulunduğu **tek departmana** aittir. Ortak köke bağlı farklı satırların kayıpları ayrı ayrı toplanır; başarılı müdahale hepsini kapatır. Departman kayıpları fabrikada toplanır, çarpımsal etki yoktur.

**Sınırlar.** Raporun gerçekleşen çıktı eşdeğeri, beklenenin en az **%33'ü** olur. Tek departmanın kaybı beklenenin en fazla yaklaşık **%20'si** olur; tavana ulaşmış departmanda yeni kayıp sorunu doğmaz. Departman ağırlığı tablosu kullanılmaz. %20 değeri ilk denge hedefidir; oyun testinde ayarlanabilir.

**Nakit ve zaman sırası.** Akış **rapor → danışman/Düzelt kararları → ayın satış ve olağan giderleri → yeni rapor** şeklindedir. Güvence kontrolünde kullanılabilir nakit, **mevcut nakit − bu ayın henüz ödenmemiş bilinen olağan giderleri** olarak hesaplanır; henüz gerçekleşmemiş satış gelirine güvenilmez. Kararların bedeli [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md) uyarınca anında ödenir. Ay sonu nakit hesabı: **önceki nakit + fiili satış geliri − fiili olağan giderler − danışman sözleşmeleri − Düzelt bedelleri**. Fiziksel satış geliri gerçekten satılan üründen hesaplanır. Rapor için çıktı eşdeğerine çevrilen nakit kaybı, bu formülden **ikinci kez** düşülmez; gerçek gideri zaten nakit hesabındadır.

**Müdahalenin etkisi.** “Düzelt”in başarı/başarısızlığı anında belli olur ve bedeli aynı ay ödenir. Başarıyla kaldırılan kayıp **sonraki ayın raporuna** yansır; geçmiş rapor değişmez.

**Ölçeğe uygun denge.** Tier fiyat bantları fabrikanın aylık birim değeriyle orantılı olsun. Fabrika kurulduktan sonraki kasa en az **bir aylık bilinen olağan gider + küçük ölçekte oluşabilecek en derin Tier'in üst bedeli** kadar olsun. Bu alt sınır ilk ayın güvencesini mümkün kılar; [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md)'deki ilk üç ay testi ayrıca sınanır. Tek kötü ayın kaçınılmaz iflasa yol açmaması hedefi korunur; kesin iflas tetikleyicisi ayrı tasarım konusudur.

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

### Onaylanan FREEZE kapsamı

- [FRZ-002](../freeze/FRZ-002_fabrika_ekonomisi.md): Tek çıktı eşdeğeri rapor birimi, kaybın tek satır/departmanda sayılması, %33 fabrika tabanı ve yaklaşık %20 departman tavanı, ay içi nakit sırası ve gider sonrası güvence, müdahale faydasının sonraki raporda görünmesi, ölçeğe bağlı fiyat bantları ve kuruluş sonrası kasa alt sınırı.
- Kesin çevirme değeri, para/saat tutarları, beklenmeyen giderler ve iflas tetikleyicisi bu FREEZE'in dışında kalır.

- Kesin para/saat tutarları, çıktı eşdeğerine çevirme değeri ve başlangıç nakdi oyun testinde belirlenir; **%20 departman tavanı** ilk denge hedefidir.
- Beklenmeyen giderler ve iflas tetikleyicisi ayrı ekonomi/iflas tasarımında kararlaştırılır. Bilinen giderleri ayırmak, henüz bilinmeyen her riski ortadan kaldırmaz.
- Ar-Ge ve Yatırım'ın gerçek gelecek etkileri ilk sürümün aylık çıktı eşdeğerinden sonra ayrı tasarlanır.

## Karar Özeti

Kullanıcının Tur 1 Claude önerilerini kabul ettiği kararların yürürlükteki kapsamı [FRZ-002](../freeze/FRZ-002_fabrika_ekonomisi.md) dosyasındadır:

- On alanın kayıpları raporda tek **çıktı eşdeğeri birimle** gösterilir; çünkü farklı kayıp birimleri gizli Tier'i ele verebilir ve toplamı okunmaz kılar.
- Her kayıp birimi tek sorun satırına ve tek departmana aittir; ortak köke bağlı satırların ayrı kayıpları toplanır, çünkü aynı etkinin departmanlar arasında iki kez sayılması önlenmeli.
- Raporun gerçekleşen eşdeğer değeri beklenenin en az **%33'ü**, tek departman kaybı beklenenin en fazla yaklaşık **%20'si** olur; çünkü oyun anlaşılır bir taban ve departman sınırı ister, ayrıntılı ağırlık tablosu gerektirmemeli.
- Düzelt güvencesi yalnızca nakitten henüz ödenmemiş **bilinen olağan giderler** düşüldükten sonra kontrol edilir, gelecek satış sayılmaz; çünkü zorunlu gider için gereken para karar anında harcanmamalı.
- Düzelt sonucu ve bedeli hemen, kapatılan kaybın rapor etkisi sonraki ay görünür; çünkü kararın sonucu anlaşılır olmalı ve geçmiş ay raporu yeniden yazılmamalı.
- Tier fiyat bantları fabrikanın aylık birim değeriyle orantılı tutulur ve kuruluş sonrası kasa en az ilk ay bilinen giderler ile küçük ölçeğin üst güvencesini karşılar; çünkü erken fabrika için danışmansız müdahale yolu açık kalmalı.
