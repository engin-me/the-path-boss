# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: DRAFT — Tur 4 Claude incelemesi tamamlandı
Tur: 4
Son güncelleme: 2026-09-28
Kaynak: Kullanıcının sağladığı ilk öneri Codex tarafından dosyaya işlendi.
Tur 1–4 Claude incelemeleri: tamamlandı. Kullanıcının yeni yönlendirmeleri Tur 4 önerisine işlendi; `Notlar (Claude)` Tur 4 incelemesidir.
Sıradaki adım: Kullanıcı, `Notlar (Claude)` → `Açık Sorular` altındaki öncelikli üç kararı seçer; ardından Codex Tur 5 sentezini yapar.

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

Yetkinlik öncelikle bir **bilgi modelidir**: patronun ilgili departmandaki sorunları kendi başına ne kadar derinden teşhis edebildiğini belirler. “Düzelt” eylemini kilitlemez. Patronun yetkinliği ve aktif danışmanın ilgili alan desteği birlikte, sorunu düzeltme olasılığını belirler. Danışmanın katkısı patronun kalıcı yetkinliğini artırmaz.

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
- T4: Satın alma müdürü belirli tedarikçiyi kayırıyor
- T5: Müdür tedarikçiden kişisel ödeme/komisyon alıyor

Satın Alma yetkinliği 70 olan patron T1-T3 sorunlarını kendi başına görebilir; T4-T5'in kök nedenini kendi başına teşhis edemez. Açıklanamayan kayıp sinyali görünür kalır; bağımsız uzman daha derin nedeni raporlayabilir.

### Sorun Çözüm Döngüsü

Önerilen akış: **sorun veya açıklanamayan kayıp sinyali → “Düzelt” → para ve zaman harcaması → sonuç**. Sorun çözümü için ek efor adımı, mini oyun veya her soruna özel müdahale menüsü yoktur. Patron derin nedeni göremese de “Düzelt” butonu aktiftir.

Patronun ilgili yetkinliği, varsa aktif danışmanın **o alandaki geçici katkısıyla** toplanır. Toplam sorunun Tier eşiğine ulaşıyorsa “Düzelt” para ve zaman maliyetiyle kesin sonuç verir; eşiğin altındaysa aynı maliyet harcanır ve başarı için olasılık hesabı yapılır. Başarısız denemede sorun devam eder. Örnek: Planlama yetkinliği 20 olan patron, Planlama +50 sağlayan danışmanla 70 eşikli Planlama sorununu kesin çözebilir. Danışman tutmak tek başına sorunu ortadan kaldırmaz; oyuncu yine “Düzelt”e basar.

Eşik altı olasılığı **Tier/kademe farkına** göre düşer. Tur 4 için kabul edilen taslak denge: bir kademe eksik ≈ %80, iki kademe ≈ %40, üç kademe ≈ %15, dört veya daha fazla kademe ≈ %5. Örneğin 60/70 bir kademe farktır ve yaklaşık %80 başarı verir. Rakamlar oyun testleriyle ayarlanabilir; Tier eşiklerinin kesin değerleri de henüz FREEZE değildir. Başarı olasılığının oyuncuya nasıl gösterileceği ve tekrar deneme maliyeti açık karardır.

Bu akışta yetkinlik, hangi eyleme basılabileceğinden çok **neyin yanlış gittiğini bilme** ve bilinmeyen sorunu çözme şansıyla ilgilidir. Tekrar tekrar kör denemenin teşhis ve danışmanı değersizleştirmemesi denge testinde özellikle incelenmelidir.

### Müdür Etkisi

Müdürün kendi uzmanlığı bazı düşük Tier sorunları patrona ulaşmadan çözebilmelidir.

Müdürün çözebildiği rutin işler ve hazırladığı raporlar patronun zamanını korur. Müdürün kendisinin sorun kaynağı olabildiği durumlarda patronun bilgisi veya bağımsız bir uzman denetimi değer kazanır. Derin sorunların her departmanda yolsuzluk olarak yazılması gerekmez.

Bir müdürü kovup yenisini alma, ilgili soruna karşı ayrı bir yönetim kararı olabilir. Yeni müdürün bulunması ve işe alışması zaman ve para doğurur; bunun “Düzelt” akışına zorunlu bir alt sistem olarak eklenip eklenmeyeceği henüz kararlaştırılmadı.

Kötü müdür + bilgili patron:
Patron sık sık müdahale eder; zaman ve para kaybeder.

İyi müdür + bilgisiz patron:
Sistem çoğunlukla yürür ancak müdürün çözemediği derin problemlerde patron teşhis koyamaz.

İyi müdür + bilgili patron:
İdeal yapı.

Kötü müdür + bilgisiz patron:
Yüksek işletme riski.

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

Fabrika battıktan sonra **aynı karakterle devam edilir** ve karakter borç yüküyle yeniden başlar. Borç, toparlanmanın mümkün olduğu ölçekte olmalıdır; **yaklaşık bir oyun yılında toparlanma** kullanıcı tarafından örnek ufuk olarak verildi, kesin süre değildir. Psikoloji, yeni başlayan bir karakterinkinden yaklaşık **%25 düşük** başlayabilir; bu da taslak örnektir, sabit denge değeri değildir. Düşüş kalıcı bir başarısızlık sarmalı yaratmamalıdır. Stat kazanımını hızlandırma veya her kazanıma +1 ekleme birer olasılıktır; hangisinin kullanılacağı kararlaştırılmadı. Önceki turda istenen yetkinlik kaybının sürüp sürmeyeceği ve “acı tecrübe” ile telafi edilip edilmeyeceği de açık kalır.

Değerlendirme raporu fabrikanın ömrünü, en çok kayıp yaratan departmanları, görülen/görülmeyen sorunları ve dikkate alınmayan uyarıları özetleyebilir (`GAME_OVERVIEW` §23). Rapor oyuncuya sonraki girişimde neyi öğrenmesi veya kime yetki vermesi gerektiğini anlatmalıdır. Aynı karakterle devam etme tercihi, `GAME_OVERVIEW` §5–6 ve §25'teki “ikinci kariyer / sonraki run” dilini netleştirmeyi gerektirir; bu IDEA aşamasında vizyon belgesi değiştirilmez.

### Eksik Yetkinliği Kapatma Yolları

Oyuncunun her işi yapmış olması zorunlu değildir.

Eksikler şunlarla kapatılabilir:

- iyi müdür
- danışman
- ortak
- uzman çalışan
- dış kaynak
- eğitim / sonradan öğrenme

Danışmanların farklı fiyat ve uzmanlık profilleri vardır. Her danışman **3–5 yetkinlik alanına** ayrı katkı verebilir; örnek profil: Planlama +50, Üretim +20, Finans +30, Satış +70. Fiyat, sağladığı katkıların gücü ve kapsamıyla ilişkili olmalıdır. Bu sayılar taslak örnektir. **Satış**, mevcut on patron yetkinliği arasında değildir; bunun yeni alan mı olduğu veya başka bir alanla eşleşip eşleşmediği ayrıca kararlaştırılmalıdır.

Aktif danışman desteği, yalnızca danışmanın kapsadığı alanda patronun **etkin yetkinliğine** eklenir; patronun kalıcı puanını değiştirmez. Etkin değer ilgili sorunun eşiğine ulaşırsa sorun görünür hale gelir ve “Düzelt” kesin başarı verir. Eşiğe ulaşmıyorsa danışmanın katkısı kademe farkını azaltarak başarı şansını yükseltebilir. Örnek: Planlama 20 + danışman 50 = etkin 70; 70 eşikli sorun “Düzelt” ile kesin çözülür. Danışmanın görev süresi, aynı anda kaç danışmanın çalışabileceği ve katkıların birbiriyle toplanıp toplanmayacağı açık karardır.

Danışman çağırmak oyun içi para, yönetim zamanı ve bekleme süresi harcatır. Bu kaynakların dengesi, sürekli danışman kullanımını otomatik en iyi strateji yapmamalıdır. Oyunun ürettiği bir sorunu çözmek için gerçek para harcamak zorunlu olamaz. Kesin fiyat formülü, görev süresi, tekrar kullanımı ve monetizasyon biçimi henüz kesinleşmedi.

### Tasarım İlkesi

Mükemmel patron her şeyi kendisi yapan kişi değildir.

“Düzelt” sade bir operasyon eylemidir; fabrika döneminin stratejisi ekip seçimi, danışman kullanımı, bütçe, zaman ve diğer yönetim kararlarında kurulmalıdır. Bu sistemlerin kapsamı ayrıca tasarlanacaktır.

Neyi bildiğini bilir.
Neyi bilmediğini bilir.
Bilmediği işi kime bırakacağını bilir.

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
- Danışman katkılarının kesin fiyat formülü, görev süresi, eşzamanlı çalışma ve üst üste eklenme kuralı; katkının geçerli olduğu alan dışındaki bilginin kapsamı. Claude önerisi: görevlendirme tek alan ve kısa süreli; aynı alanda yalnızca en yüksek katkı geçerli; etkin yetkinlik en fazla 100 (açık).
- Danışmanın örnek profilindeki Satış'ın yeni yetkinlik mi yoksa mevcut bir alanın karşılığı mı olduğu. Claude önerisi: örnekten çıkarılır; talep/satış tarafı ayrı IDEA konusu olur (açık).
- Müdür yetkinliğinin “Düzelt” ihtimaline katılıp katılmayacağı; müdürün kendisinin kaynak olduğu sorunlarda istisna. Claude önerisi: danışmanla aynı toplama kuralı; kaynak müdürse katkısı sıfır (açık).
- Açıklanamayan kayıp sinyali üzerinden basılan “Düzelt”in hangi gizli sorunu hedeflediği.
- Danışman seviyesi ve bulunabilirliği.
- Müdür raporlarının çarpıtılıp çarpıtılamayacağı ve bunun hangi yetkinlikle fark edileceği.
- Gerçek paranın danışmanlık sistemindeki rolü (yalnızca kolaylık mı, hiç mi).
- Oyun içi açıklanamayan kayıp sinyalinin hesap tanımı ve netlik eşikleri; fabrika başarısızlık raporunun ayrıntı düzeyi ve ara dönem (yıllık) özet olup olmayacağı.
- Müdürü kovma, yenisini alma ve alışma sürecinin basit bir ayrı eylem mi yoksa daha ayrıntılı bir sistem mi olacağı; kişi kaynaklı sorunlarda “Düzelt”in bu personel sonucunu kapsayıp kapsamadığı.
- Sorun ertelendiğinde kaybın büyüme hızı.
- İflas borcunun miktarı ve yaklaşık bir oyun yılında toparlanmanın denge hedefi olup olmayacağı; psikoloji düşüşünün süresi ve toparlanma hızı. Claude önerisi: psikoloji belirli sürede kendiliğinden toparlanır, borç ödemesi gelire oranlanır (açık).
- Stat kazanımını hızlandırma veya kazanım başına +1 önerisinden hangisinin, hangi sınırlarla uygulanacağı; önceki yetkinlik kaybı isteğinin korunup korunmayacağı ve “acı tecrübe” önerisi.
- Kasıtlı iflasla telafi bonusu toplanmasının önlenmesi. Claude önerisi: telafi yalnızca kayıp yaratan alanlara bağlı, tek seferlik ve sınırlı (açık).
- Oyunun süresi ve bitiş koşulu; iflastan sonraki sermaye/borç durumu; karar dondurulursa GAME_OVERVIEW'daki "run" dilinin güncellenmesi.
- Fabrika dönemindeki stratejik derinliğin “Düzelt” dışında hangi sistemlerden geleceği.
- Ortak, uzman çalışan, dış kaynak ve eğitim yollarının ayrıştırılması: bu IDEA'da mı, ayrı IDEA'da mı?
- Patron görüş seviyesi ile sorun derinliği için ayrı terimler.
- Yetkinlik Tier eşikleri (T4–T5 arasındaki 10 puanlık aralığın kademe eğrisiyle birlikte yeniden değerlendirilmesi dahil), kazanılma hızı, düşüşü ve beşinci yıl hedefi.
- Müdürlerin sorun çözme matematiği ve departman başına eşzamanlı problem sayısı.
- Statların öğrenme hızına vereceği azami bonus.

## Karar Özeti

Kullanıcının yönlendirmeleri (IDEA düzeyinde; henüz FREEZE değil):

- “Düzelt” butonu yetkinlikten bağımsız açık kalır, her deneme para ve zaman harcar; çünkü sorun çözümü ek efor veya mini oyun gerektirmemeli.
- Yetkinlik Tier eşiğine ulaşıyorsa sorun kesin çözülür; ulaşmıyorsa başarı olasılığı yetkinliğe bağlıdır (60/70 için yaklaşık %80 hedefi); çünkü bilgi açığı çözmeyi imkânsız değil, riskli kılmalı.
- Yetkinlik bilgi modeli olarak öncelikle kök neden görünürlüğünü belirler; çünkü seçenek kilitlemek yerine oyuncunun neyi bildiği öne çıkmalı.
- Fabrika batınca aynı karakter devam eder; çünkü başarısızlık sonraki girişime ders taşımalı, bedelin tam stat/yetkinlik etkisi ise hâlâ açık.
- Danışman 3–5 alana farklı geçici yetkinlik katkısı sağlar ve fiyatı katkısıyla ilişkilidir; çünkü farklı bütçelere ve bilgi açıklarına uygun danışman seçenekleri olmalı.
- Patron ve aktif danışmanın ilgili yetkinlikleri eşiğe ulaşıyorsa “Düzelt” kesin sonuç verir; çünkü danışman tutmanın kör denemeye göre somut faydası olmalı.
- Eşik altı başarı ihtimali kademe farkına göre yaklaşık %80 / %40 / %15 / %5 düşer; çünkü derin bilgi açığında kör deneme anlamlı risk taşımalı.
- İflas sonrası karakter borçla ve daha düşük psikolojiyle devam eder; çünkü kayıp hissedilmeli ama toparlanma mümkün olmalı, borç süresi ve yaklaşık %25 psikoloji farkı henüz örnektir.
