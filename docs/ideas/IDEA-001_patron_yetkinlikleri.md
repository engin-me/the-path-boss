# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: DRAFT — Tur 5 GPT sentezi hazır, Claude incelemesi bekleniyor
Tur: 5
Son güncelleme: 2026-09-28
Kaynak: Kullanıcının sağladığı ilk öneri Codex tarafından dosyaya işlendi.
Tur 1–4 Claude incelemeleri: tamamlandı. Kullanıcının yeni yönlendirmeleri Tur 5 önerisine işlendi; `Notlar (Claude)` hâlâ Tur 4 incelemesidir.
Sıradaki adım: Claude, Tur 5 önerisini inceleyip `Notlar (Claude)` bölümünü günceller.

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

Eşikler taslak değerlerdir; çözüm döngüsü sınanmadan kesinleşmez. Patronun yetkinliği yetersizse yüksek derinlikteki kök neden gizli kalabilir. Buna rağmen departmandaki açıklanamayan kayıp oyuncuya sinyal olarak gösterilir. Patronun görüş seviyesi ile sorunun derinliği için ayrı adlar daha sonra belirlenecek.

Örnek:

Satın Alma performansı düşüktür.

- T1: Fiyatlar piyasanın üzerinde
- T2: Tedarikçi termin performansı kötü
- T3: Tek tedarikçiye aşırı bağımlılık
- T4: Satın alma sürecinde belirli tedarikçiler sistematik olarak kayrılıyor
- T5: Tedarik kararlarında gizli çıkar çatışması veya usulsüz ödeme var

Satın Alma yetkinliği 70 olan patron T1-T3 sorunlarını kendi başına görebilir; T4-T5'in kök nedenini kendi başına teşhis edemez. Açıklanamayan kayıp sinyali görünür kalır; bağımsız uzman daha derin nedeni raporlayabilir.

### Sorun Çözüm Döngüsü

Önerilen akış: **sorun veya açıklanamayan kayıp sinyali → “Düzelt” → para ve zaman harcaması → sonuç**. Sorun çözümü için ek efor adımı, mini oyun veya her soruna özel müdahale menüsü yoktur. Patron derin nedeni göremese de “Düzelt” butonu aktiftir.

Etkin yetkinlik sorunun Tier eşiğine ulaşıyorsa “Düzelt” para ve zaman maliyetiyle kesin sonuç verir; eşiğin altındaysa aynı maliyet harcanır ve başarı için olasılık hesabı yapılır. Başarısız denemede sorun devam eder. Örnek: Planlama puanı 20 olan patron ve Planlama puanı 80 olan aktif danışman için etkin değer **max(20, 80) = 80** olur; 70 eşikli Planlama sorunu kesin çözülür. Danışman tutmak tek başına sorunu ortadan kaldırmaz; oyuncu yine “Düzelt”e basar. Eski **20 + 50 = 70** örneği artık geçerli değildir: max(20, 50) = 50, dolayısıyla o sorunda olasılık hesabı yapılır.

“Düzelt”, sorunun gerektirdiği işlemin yapılmış olmasıdır; kişi kaynaklı sorunda konuşma, yaptırım veya işten çıkarma gibi sonucu da kapsayabilir. Oyuncu için ayrıca müdür kovma zinciri veya her soruna özel eylem menüsü açılmaz. Hangi işlemin gerçekleştiği sonuç metninde anlatılabilir; buna ayrı bir müdür karakteri veya müdür yetkinliği gerekmez.

Eşik altı olasılığı **Tier/kademe farkına** göre düşer. Tur 4 için kabul edilen taslak denge: bir kademe eksik ≈ %80, iki kademe ≈ %40, üç kademe ≈ %15, dört veya daha fazla kademe ≈ %5. Örneğin 60/70 bir kademe farktır ve yaklaşık %80 başarı verir. Rakamlar oyun testleriyle ayarlanabilir; Tier eşiklerinin kesin değerleri de henüz FREEZE değildir. Başarı olasılığının oyuncuya nasıl gösterileceği ve tekrar deneme maliyeti açık karardır.

Bu akışta yetkinlik, hangi eyleme basılabileceğinden çok **neyin yanlış gittiğini bilme** ve bilinmeyen sorunu çözme şansıyla ilgilidir. Tekrar tekrar kör denemenin teşhis ve danışmanı değersizleştirmemesi denge testinde özellikle incelenmelidir.

### İnsan Yönetimi ve Personel

Bu IDEA'da müdür için ayrı kimlik veya yetkinlik puanı tanımlanmıyor. Patronun **İnsan Yönetimi** yetkinliği personel tarafındaki sonuçlara ve aylık performans raporlarına yansır; bunun kesin matematiği ayrı tasarlanacaktır. Kişi kaynaklı bir sorun başarıyla “Düzelt”ildiğinde gereken personel işlemi çözümün içinde sayılır.

Bu yönlendirme, `GAME_OVERVIEW` §10'daki ayrı müdür uzmanlığı ve iyi/kötü müdür matrisinden ayrılıyor. FREEZE öncesi bu tutarsızlık gözden geçirilmeli; yön dondurulursa vizyon belgesi de yeni tasarıma göre güncellenmelidir.

### Statların Rolü

Statlar doğrudan yetkinlik puanı veya Tier açmaz.

Statlar:
- yetkinlik kazanma hızını,
- problem çözme süresini,
- problem çözme maliyetini,
- “Düzelt” dışındaki bazı görevlerde başarı oranını

etkileyebilir.

Tur 4 önerisi: Statlar, eşik altı “Düzelt” olasılığını doğrudan artırmasın; burada belirleyici olan ilgili alanın yetkinliği ve danışman desteği olsun. Böylece yüksek Zeka, meslek deneyiminin yerini tek başına alamaz. Bu sınır henüz kullanıcı tarafından kararlaştırılmadı.

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

Patron kök nedeni göremese bile departman kartı **açıklanamayan kayıp** sinyali verir (`GAME_OVERVIEW` §9). Sinyal, oyuncunun “Düzelt” denemesi veya danışman çağırması için dayanak sağlar; gerçek nedeni otomatik ifşa etmez. Başarısız deneme sonrasında harcanan para ve zaman ile sorunun sürdüğü açıkça gösterilmelidir. Kaybın büyüklüğünün ve kategori ipuçlarının hangi düzeyde gösterileceği açık karardır.

Fabrika battıktan sonra **aynı karakterle devam edilir** ve karakter borç yüküyle yeniden başlar. Borç, toparlanmanın mümkün olduğu ölçekte olmalıdır; **yaklaşık bir oyun yılında toparlanma** kullanıcı tarafından örnek ufuk olarak verildi, kesin süre değildir. Psikoloji, yeni başlayan bir karakterinkinden yaklaşık **%25 düşük** başlayabilir; bu da taslak örnektir, sabit denge değeri değildir. Düşüş kalıcı bir başarısızlık sarmalı yaratmamalıdır.

İflas **yetkinlik kaybettirmez** ve genel stat kazanımını hızlandırmaz. Bunun yerine karakter, kayba en çok yol açan alanda küçük, üst sınırı olan **“acı tecrübe” yetkinlik artışını karakter başına bir kez** alır. Böylece iflastan öğrenilirken kasıtlı tekrar iflasla bonus biriktirme engellenir. Kalıcı bedel borç ve harcanan zamandır; psikoloji düşüşü geçicidir. Kesin artış, borç miktarı ve psikolojinin toparlanma süresi denge kararlarıdır.

Değerlendirme raporu fabrikanın ömrünü, en çok kayıp yaratan departmanları, görülen/görülmeyen sorunları ve dikkate alınmayan uyarıları özetleyebilir (`GAME_OVERVIEW` §23). Rapor oyuncuya sonraki girişimde neyi öğrenmesi veya kime yetki vermesi gerektiğini anlatmalıdır. Aynı karakterle devam etme tercihi, `GAME_OVERVIEW` §5–6 ve §25'teki “ikinci kariyer / sonraki run” dilini netleştirmeyi gerektirir; bu IDEA aşamasında vizyon belgesi değiştirilmez.

### Eksik Yetkinliği Kapatma Yolları

Oyuncunun her işi yapmış olması zorunlu değildir.

Eksikler şunlarla kapatılabilir:

- iyi ekip ve personel düzeni
- danışman
- ortak
- uzman çalışan
- dış kaynak
- eğitim / sonradan öğrenme

Oyuncu danışman aradığında **10 aday** görür. Her adayın mevcut patron yetkinliklerinden **2–5 alandaki puanı** görünür ve oyuncu bu profillere bakarak seçer. Örnek: bir danışman Planlama 30, Üretim 80, Finans 40, Kalite 60; bir başkası Planlama 50, Üretim 10, Finans 50 olabilir. İlk adayın ücreti, genel yetkinlik gücü ve kapsamı daha yüksek olduğu için ikinci adaydan yüksek olabilir. Kesin fiyat formülü açık karardır. Önceki taslaktaki **Satış** örneği, mevcut on yetkinlik arasında olmadığı için çıkarıldı; satış/talep tasarımı ayrı konu olarak ele alınabilir.

Danışman **belirli süreli sözleşmeyle** tutulur; profilindeki bütün alanlar sözleşme boyunca aktiftir. Örnek fiyatlama: o danışmanın bir aylık ücreti **A** ise 3 ay **2,75A**, 12 ay **10A**. Süreler ve çarpanlar bağlayıcılık/indirim fikrini gösteren taslak değerlerdir. Birden çok danışman aynı anda çalışsa bile ilgili alanda **etkin yetkinlik = max(patronun puanı, aktif danışmanların o alandaki puanları)**; puanlar birbirine eklenmez ve 100'ü aşmaz. Etkin değer sorunun eşiğine ulaşırsa kök neden görünür ve “Düzelt” kesin başarı verir. Danışman ayrılınca patronun kalıcı puanı artmış sayılmaz.

Danışman tutmak oyun içi para ve sözleşme yükü doğurur. Arama/göreve başlama beklemesinin ve yönetim zamanı maliyetinin olup olmayacağı ayrıca değerlendirilecektir. Sürekli danışman tutmanın kariyer deneyimini değersizleştirmemesi için sözleşme fiyatları ve gelir dengesi sınanmalıdır. Oyunun ürettiği bir sorunu çözmek için gerçek para harcamak zorunlu olamaz.

### Tasarım İlkesi

Mükemmel patron her şeyi kendisi yapan kişi değildir.

Neyi bildiğini bilir.
Neyi bilmediğini bilir.
Bilmediği işi kime bırakacağını bilir.

“Düzelt” sade bir operasyon eylemidir; fabrika döneminin stratejisi danışman seçimi, personel sonuçları, bütçe, zaman ve diğer yönetim kararlarında kurulmalıdır. Bu sistemlerin kapsamı ayrıca tasarlanacaktır.

## Notlar (Claude)

Tarihçe: Tur 1 inceleme [REV-001](../reviews/REV-001_claude_patron_yetkinlikleri.md) ve bu dosyanın Git geçmişi. Aşağıdakiler Tur 4 `Öneri (GPT)` metninin incelemesidir. `Karar Özeti`'ndeki kullanıcı yönlendirmeleri tartışmaya açılmamış; notlar bu yönlendirmelerin içindeki açıkları ve uygulanma biçimini hedefler.

### Aldığım Notlar

- Danışmanın artık somut bir mekanik etkisi var: etkin yetkinliğe katkı, görünürlük ve eşiğe ulaşınca kesin sonuç. Tur 3'teki "danışman işlevsiz" sorunu kapandı.
- Toplama modeli tematik olarak güçlü: bilgili patron danışmanı daha verimli kullanır (60 + 30 = 90, ama 20 + 30 = 50). Kariyer yetkinliği, gereken danışmanı ucuzlatarak değer kazanıyor.
- Kademe eğrisi (≈ %80 / %40 / %15 / %5) kör denemeyi derin sorunlarda gerçekten riskli kılıyor. Eşiklerdeki keskin sıçrama (49 → 50'de %40 → %80) okunur bir hedef yaratıyor; bir kusur değil.
- Statların eşik altı ihtimali etkilememesi önerisi Tur 3 notuyla uyumlu; kabul edilmesi öneriliyor.
- Borç + geçici psikoloji düşüşü + "kalıcı sarmal yaratmamalı" ilkesi, Tur 3'teki ölüm sarmalı uyarısını doğru yönde karşılıyor.
- "Düzelt sade bir operasyon eylemidir; strateji başka sistemlerde" cümlesi Tur 3'teki tycoon'a kayma riskini IDEA'ya yazılı hale getirdi.

### Bulduğum Sakıncalar

- **Danışman aboneliği baskın strateji olabilir (kritik):** Danışman "aktif" olduğu süre boyunca 3–5 alanda etkin yetkinliği yükseltiyorsa, o süredeki tüm sorunlar bu alanlarda kesin çözülür. Oyuncu parası yettiği sürece sürekli danışman tutar; kariyer yetkinliği yalnızca bir maliyet indirimine dönüşür (REV-001 C2 geri döner). Tur 1–2'de uzlaşılan "tek departman, geçici" sınırı da 3–5 alanlı profille fiilen kalkmış oluyor. Öneri (kullanıcı kararını bozmadan): profil danışmanın *hangi alanlarda tutulabileceğini* gösterir, ama her görevlendirme **tek alan ve kısa süre** için yapılır. Fiyat görevlendirilen alanın katkısına göre belirlenir.
- **Katkıların üst üste eklenmesi ve 100'ü aşma:** İki danışman (+50 ve +50) toplanırsa her patron T5'e ulaşır; 60 + 70 = 130 gibi değerler anlamsızdır. Öneri: aynı alanda yalnızca en yüksek danışman katkısı geçerli olsun, etkin yetkinlik 100 ile sınırlansın.
- **Kişi kaynaklı sorunlar artık rutin olarak çözülebilir hale geldi:** Danışmanla etkin değer 90–100'e kolayca çıkıyor. T4–T5 (müdür kayırması, komisyon) "Düzelt" ile kesin çözülüyor, ama müdürün yerinde kalıp kalmadığı hâlâ tanımsız. Tur 3'te açık kalan bu karar artık acil: tanımlanmazsa yolsuzluk parayla "kapatılan" bir sorun olur.
- **Müdür ve danışman için kurallar tutarsız:** Danışmanın katkısı toplanıyor, müdürün katkısı tanımsız. Oyuncu doğal olarak "iyi müdür neden danışman kadar işe yaramıyor?" diye sorar. Öneri: müdür de aynı toplama kuralına girsin, ancak kaynağı müdürün kendisi olan sorunlarda katkısı sıfır sayılsın.
- **Kasıtlı iflas istismarı:** İflastan sonra stat kazanımı hızlanıyor veya her kazanıma +1 ekleniyorsa, oyuncu küçük bir fabrika kurup bilerek batırarak bu bonusu toplayabilir. Öneri: telafi yalnızca raporda en çok kayıp yaratan alanlara bağlı olsun ("acı tecrübe"), bir kez verilsin ve üst sınırı olsun. Etkisi, borcun bir yıllık maliyetinden açıkça küçük kalmalı.
- **Psikoloji −%25 ile §20 sarmalı:** Borçlu, düşük psikolojili ve muhtemelen yeniden iş arayan bir karakter, §20'de bir kez yaşanan "psikoloji → performans → kovulma" sarmalının başlangıç koşullarını taşıyor. "Sarmal yaratmamalı" bir niyet olarak yazılı, ama mekanizması yok. Öneri: psikoloji belirli bir sürede kendiliğinden toparlansın (ör. 6 ay); borç ödemesi gelire oranlanmış olsun.

### Kafama Yatmayanlar

- **"Satış" kapsam genişlemesi:** Danışman örneğindeki Satış, on yetkinlik arasında yok. Aslında oyunda talep/satış tarafının hiç tanımlanmadığını ortaya çıkarıyor. Bu IDEA'ya 11. bir yetkinlik olarak sessizce girmemeli. Örnek profilden çıkarılsın; satış/talep tarafı ayrı bir IDEA konusu olarak işaretlensin.
- **T4–T5 arası yalnızca 10 puan (REV-001 C4):** Kademe eğrisiyle bu artık daha önemli. 90 yetkinlikli patron, en derin (T5) sorunlarda %80 başarıyla neredeyse T4 kadar rahat. Eşik aralıkları eğriyle birlikte yeniden bakılmalı.
- **Karar Özeti'nde gerekçe izi:** Tur 3'teki "bazı stat/yetkinlik kayıpları yaşar" maddesi, Tur 4'te "tam etkisi hâlâ açık" olarak yeniden yazılmış. Proje kuralı hem kararın hem gerekçesinin korunmasını istiyor. Değişikliğin kullanıcı yönlendirmesiyle yapıldığı tek satırla belirtilmeli.
- **Tasarım İlkesi bölümünde yerleşim:** "Düzelt sade bir operasyon eylemidir" paragrafı, üç satırlık ilkenin ilk cümlesiyle devamı arasına girmiş. Paragraf ilkenin sonuna taşınmalı.
- **Oyunun süresi ve bitişi hâlâ tanımsız:** İflastan sonra bir yıl toparlanma ve yeniden sermaye biriktirme süresi, oyunun ne kadar sürdüğü bilinmeden dengelenemez.

### Açık Sorular

Tur 5'ten önce kullanıcının karar vermesi önerilen öncelikli üç konu:

1. Danışman görevlendirmesi süreli bir abonelik mi (3–5 alan birden aktif), yoksa tek alan ve kısa görev mi (Claude önerisi)? Katkılar üst üste eklenmesin ve etkin değer 100 ile sınırlansın mı?
2. Kişi kaynaklı sorunda "Düzelt" ne yapar: müdür değişimini otomatik içerir mi, yoksa müdürü kovmak ayrı bir eylem mi? Müdürün katkısı danışmanla aynı toplama kuralına girsin mi?
3. İflas sonrası telafi kasıtlı iflasa karşı nasıl sınırlanacak? Yetkinlik kaybı tamamen kaldırılıp "acı tecrübe" mi kabul edilecek?

Diğerleri:
- Satış örnek profilden çıkarılsın mı; talep/satış tarafı ayrı IDEA mı olsun?
- Psikolojinin kendiliğinden toparlanma süresi ve borç ödemesinin gelire oranı ne olsun?
- Başarı ihtimali oyuncuya yüzde olarak mı, kaba aralık olarak mı gösterilecek?

## Açık Kararlar

- “Düzelt”in para/zaman maliyetleri ve ihtimalin oyuncuya nasıl gösterileceği; kesin yüzde gizli Tier'ı ele verebilir. Kaba aralık gösterimi Claude önerisidir (açık).
- Kabul edilen taslak kademe eğrisinin (≈ %80 / %40 / %15 / %5) oyun testlerinde ayarlanması; Tier içinde farklı puanların aynı şansa sahip olmasının uygunluğu.
- Kör denemeyi baskın strateji yapmamak için tekrar denemede aynı mı, artan mı maliyet ve/veya bekleme süresi uygulanacağı.
- Statların eşik altı “Düzelt” olasılığını etkileyip etkilemeyeceği; Tur 4 önerisi yalnızca süre ve maliyeti etkilemeleri.
- Danışman adaylarının nasıl yenilendiği, aynı anda tutulabilecek sayı ve fiyat formülü; 1/3/12 ay ile A/2,75A/10A örneklerinin kesinleşmesi.
- Uzun süreli çok alanlı danışmanların baskın strateji olup olmayacağı ve fiyat/erişilebilirlik dengesi.
- Satış/talep konusunun ayrı IDEA olarak ele alınması ve mevcut on yetkinlik listesine etkisi.
- İnsan Yönetimi yetkinliğinin aylık performans raporlarına nasıl yansıdığı; `GAME_OVERVIEW` §10'daki müdür modelinin yeni yönle uyumlandırılması.
- Açıklanamayan kayıp sinyali üzerinden basılan “Düzelt”in hangi gizli sorunu hedeflediği.
- Danışman seviyesi ve bulunabilirliği.
- Gerçek paranın danışmanlık sistemindeki rolü (yalnızca kolaylık mı, hiç mi).
- Oyun içi açıklanamayan kayıp sinyalinin hesap tanımı ve netlik eşikleri; fabrika başarısızlık raporunun ayrıntı düzeyi ve ara dönem (yıllık) özet olup olmayacağı.
- Kişi kaynaklı sorunda “Düzelt”in hangi sonucu ve maliyeti ürettiğinin oyuncuya nasıl anlatılacağı; ayrı müdür karakteri veya eylemi açılmaz.
- Sorun ertelendiğinde kaybın büyüme hızı.
- İflas borcunun miktarı ve yaklaşık bir oyun yılında toparlanmanın denge hedefi olup olmayacağı; psikoloji düşüşünün süresi ve toparlanma hızı. Claude önerisi: psikoloji belirli sürede kendiliğinden toparlanır, borç ödemesi gelire oranlanır (açık).
- “Acı tecrübe” artışının kesin büyüklüğü ve üst sınırı; karakter başına tek seferlik verilmesinin denge testi.
- Oyunun süresi ve bitiş koşulu; iflastan sonraki sermaye/borç durumu; karar dondurulursa GAME_OVERVIEW'daki "run" dilinin güncellenmesi.
- Fabrika dönemindeki stratejik derinliğin “Düzelt” dışında hangi sistemlerden geleceği.
- Ortak, uzman çalışan, dış kaynak ve eğitim yollarının ayrıştırılması: bu IDEA'da mı, ayrı IDEA'da mı?
- Patron görüş seviyesi ile sorun derinliği için ayrı terimler.
- Yetkinlik Tier eşikleri (T4–T5 arasındaki 10 puanlık aralığın kademe eğrisiyle birlikte yeniden değerlendirilmesi dahil), kazanılma hızı, düşüşü ve beşinci yıl hedefi.
- Departman başına eşzamanlı problem sayısı.
- Statların öğrenme hızına vereceği azami bonus.

## Karar Özeti

Kullanıcının yönlendirmeleri (IDEA düzeyinde; henüz FREEZE değil):

- “Düzelt” butonu yetkinlikten bağımsız açık kalır, her deneme para ve zaman harcar; çünkü sorun çözümü ek efor veya mini oyun gerektirmemeli.
- Yetkinlik Tier eşiğine ulaşıyorsa sorun kesin çözülür; ulaşmıyorsa başarı olasılığı yetkinliğe bağlıdır (60/70 için yaklaşık %80 hedefi); çünkü bilgi açığı çözmeyi imkânsız değil, riskli kılmalı.
- Yetkinlik bilgi modeli olarak öncelikle kök neden görünürlüğünü belirler; çünkü seçenek kilitlemek yerine oyuncunun neyi bildiği öne çıkmalı.
- Fabrika batınca aynı karakter devam eder; çünkü başarısızlık sonraki girişime ders taşımalı.
- Oyuncu aramada 10 danışman adayı görür ve her aday 2–5 alandaki puanıyla fiyatlanır; çünkü farklı bilgi açıkları ve bütçeler için görünür seçenekler olmalı.
- Danışman sözleşmesi süreli ve bütün profil alanları boyunca aktiftir; çünkü oyuncu tek alanlık kısa görev yerine kapsamlı bir danışman seçip süreye bağlanmak istiyor.
- Etkin yetkinlik patron ve aktif danışman puanlarının en yükseğidir, toplama değildir; çünkü çok danışman tutmak 100 üstü puan veya sınırsız güç üretmemeli.
- Etkin yetkinlik eşiğe ulaştığında “Düzelt” kesin sonuç verir; çünkü danışman tutmanın kör denemeye göre somut faydası olmalı.
- Eşik altı başarı ihtimali kademe farkına göre yaklaşık %80 / %40 / %15 / %5 düşer; çünkü derin bilgi açığında kör deneme anlamlı risk taşımalı.
- İflas sonrası karakter borçla ve daha düşük psikolojiyle devam eder; çünkü kayıp hissedilmeli ama toparlanma mümkün olmalı, borç süresi ve yaklaşık %25 psikoloji farkı henüz örnektir.
- İflas yetkinlik kaybettirmez veya genel stat kazanımını hızlandırmaz; bunun yerine karakter başına tek seferlik sınırlı “acı tecrübe” kazandırır, çünkü başarısızlık öğretmeli ve kasıtlı iflas ödül döngüsüne dönüşmemeli.
- “Düzelt” gereken personel işlemlerini de kapsar ve ayrı müdür yetkinliği tanımlanmaz; çünkü oyuncunun yönetim bilgisi İnsan Yönetimi yetkinliği ve aylık sonuçlarda temsil edilmeli.
