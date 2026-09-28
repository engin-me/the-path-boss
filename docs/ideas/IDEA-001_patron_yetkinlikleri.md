# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: DRAFT — Tur 3 GPT sentezi hazır, Claude incelemesi bekleniyor
Tur: 3
Son güncelleme: 2026-09-28
Kaynak: Kullanıcının sağladığı ilk öneri Codex tarafından dosyaya işlendi.
Tur 1 ve Tur 2 Claude incelemeleri: tamamlandı. Kullanıcının üç öncelikli seçimi Tur 3 önerisine işlendi. `Notlar (Claude)` hâlâ Tur 2 incelemesidir.
Sıradaki adım: Claude, Tur 3 önerisini inceleyip yalnızca `Notlar (Claude)` bölümünü günceller.

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

Toplam teorik maksimum: 1000.

### Temel Mantık

Yetkinlik doğrudan üretim/verim bonusu değildir.

Yetkinlik öncelikle bir **bilgi modelidir**: patronun ilgili departmandaki sorunları kendi başına ne kadar derinden teşhis edebildiğini belirler. Müdahale seçeneklerini kilitlemez. Ayrıca patronun yetkinlik puanı, henüz göremediği derinlikte bir sorunu düzeltmeyi denediğinde başarı olasılığını etkiler. Patronun bilmediği bir kök nedeni yetkin bir müdür, danışman veya ortak teşhis edebilir; böyle bir rapor patrona kalıcı yetkinlik kazandırmaz.

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

Patronun ilgili yetkinliği sorunun Tier eşiğine ulaşıyorsa, “Düzelt” para ve zaman maliyetiyle sorunu çözer. Yetkinliği eşiğin altındaysa aynı maliyet harcanır ve başarı için olasılık hesabı yapılır; başarısız denemede sorun devam eder. Örnek denge hedefi: **60 yetkinlik / 70 eşikli sorun ≈ %80 başarı**. Bu tek örnek sabit formül değildir; eşikten uzaklaştıkça ihtimalin nasıl değişeceği, oyuncuya nasıl gösterileceği ve tekrar deneme maliyeti açık karardır.

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
- bazı görevlerdeki başarı oranını

etkileyebilir.

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

Fabrika battıktan sonra **aynı karakterle devam edilir**. Değerlendirme raporu fabrikanın ömrünü, en çok kayıp yaratan departmanları, görülen/görülmeyen sorunları ve dikkate alınmayan uyarıları özetleyebilir (`GAME_OVERVIEW` §23). Rapor oyuncuya sonraki girişimde neyi öğrenmesi veya kime yetki vermesi gerektiğini anlatmalıdır. Başarısızlık karaktere bazı stat ve yetkinlik kayıpları da yaşatmalıdır; hangi değerlerin ne kadar ve ne süreyle düşeceği henüz açık karardır. Kayıp, oyuncunun önceki deneyiminden ders çıkarma imkanını silmemelidir.

### Eksik Yetkinliği Kapatma Yolları

Oyuncunun her işi yapmış olması zorunlu değildir.

Eksikler şunlarla kapatılabilir:

- iyi müdür
- danışman
- ortak
- uzman çalışan
- dış kaynak
- eğitim / sonradan öğrenme

Danışman özellikle patronun göremediği daha derin sorunları **kendi uzmanlığı ölçüsünde** teşhis edebilir; erişimi patronun görüşünün yalnızca bir kademe üstüyle sınırlanmaz. Raporu tek departmandaki belirli bir duruma yöneliktir: teşhis bilgisi kullanılabilir, fakat patronun genel yetkinliği kalıcı olarak yükselmez. Danışman sorunu doğrudan çözmez; oyuncu yine “Düzelt” eylemine karar verir. Danışman raporunun eşik altındaki başarı olasılığını etkileyip etkilemeyeceği açık karardır.

Danışman çağırmak oyun içi para, yönetim zamanı ve bekleme süresi harcatır. Bu kaynakların dengesi, sürekli danışman kullanımını otomatik en iyi strateji yapmamalıdır. Oyunun ürettiği bir sorunu çözmek için gerçek para harcamak zorunlu olamaz. Danışmanın fiyatı, tekrar kullanımı ve monetizasyon biçimi henüz kesinleşmedi.

### Tasarım İlkesi

Mükemmel patron her şeyi kendisi yapan kişi değildir.

Neyi bildiğini bilir.
Neyi bilmediğini bilir.
Bilmediği işi kime bırakacağını bilir.

## Notlar (Claude)

Tarihçe: Tur 1 inceleme [REV-001](../reviews/REV-001_claude_patron_yetkinlikleri.md) ve bu dosyanın Git geçmişi. Aşağıdakiler Tur 2 `Öneri (GPT)` metninin incelemesidir.

### Aldığım Notlar

- Tur 1 notlarının çoğu doğru işlenmiş: izleme adımı eklenmiş çözüm döngüsü; "hiçbiri her durumda en iyi değil" ilkesiyle altı müdahale ailesi; +1 Tier tavanının kaldırılması; danışmanın kalıcı yetkinlik vermemesi ve doğrudan çözüm sağlamaması; gerçek paranın zorunlu çözüm olmaması; müdür kaynaklı sorunların bağımsız denetim gerektirmesi; "her departmanda yolsuzluk" tuzağından kaçınılması.
- Tekrarın "keyfî sayaçla değil devam eden nedenin etkisiyle" oluşması benim tekrar sayacı önerimden daha iyi. Sayaç yalnızca arayüzde bir gösterim olarak kalmalı.
- Eşiklerin taslak olarak işaretlenmesi ve terim ayrımının ertelenmesi doğru; FREEZE öncesinde ikisi de kapanmalı.

### Bulduğum Sakıncalar

- **Kör müdahale açığı:** "Kök neden bilinmeden yapılan müdahale bazen doğru sonuca da ulaşabilir" cümlesi yeni bir dominant strateji açıyor. Oyuncu teşhis yerine ucuz müdahaleleri sırayla dener; yetkinlik de danışman da gereksizleşir. Öneri: kör müdahale yalnızca patronun görebildiği derinliğe kadar kalıcı sonuç verebilsin. Kişi kaynaklı derin sorunlarda (kayırma, komisyon) kör kalıcı çözüm olmasın.
- **Stat açığı:** Statlar "başarı oranını" etkiliyor. Kör müdahale de başarılı olabiliyorsa, yüksek Zeka dolaylı yoldan derin sorunu çözmüş olur. Bu, "Zeka T4 görmez" ilkesini arka kapıdan deler. Statlar yalnızca teşhis edilmiş veya görülebilen derinlikteki müdahalelerin başarısını etkilemeli.
- **Seçenek açılma kuralı tanımsız:** "Seçenekler teşhise, ekibe ve koşullara göre açılır" ifadesi genel kurallara bağlanmazsa her sorun için ayrı seçenek yazmak gerekir; Tur 1'de kaçınılan 10 × 5 içerik yükü geri gelir. Öneri, genel ön koşullar: müdüre devretmek için müdür gerekir; süreç değişikliği o derinlikte teşhis ister; personel kararı teşhiste bir kişinin adının çıkmasını ister; kaynak ekleme ve kabul her zaman açıktır.
- **Danışman freni zayıf ifade edilmiş:** "Para, zaman ve bekleme harcatabilir" ifadesindeki "-abilir" bedeli isteğe bağlı gösteriyor. Bedel "harcatır" olarak kesinleşmeli; yoksa sürekli danışman kullanımı yine en iyi strateji olur.
- **Danışman + kalıcı çözüm döngüsü:** Danışman teşhis eder, patron süreç değişikliğiyle sorunu kalıcı çözer. Bu tutarlı, ancak o zaman yetkinliğin değeri yalnızca sıklık ve maliyet tasarrufuna iner. Derin sorunlar yeterince sık ve çeşitli değilse kariyer yatırımı anlamını yitirir. Denge testinde "10 yıllık danışman maliyeti ile kariyerde harcanan zamanın karşılaştırması" ölçülmeli.
- **Güvenilmeyen raporlar:** Müdürün patrona teşhis raporu verebildiği yazılı. Ancak müdür sorunun kaynağıysa kendi raporunu çarpıtabilir. Bilgisiz patronun bunu fark edip edemeyeceği tanımsız. Bu, İnsan Yönetimi yetkinliğine bağlanmazsa 2x2 matris işlemez.
- **Sinyal hesabı belirsiz:** Aynı departmanda hem görülen hem görülmeyen sorun varsa "açıklanamayan kayıp" neye göre gösteriliyor? Öneri: toplam kayıp eksi görülen sorunların açıkladığı kayıp. Bu hesap eşzamanlı sorun sayısı kararına bağlı.

### Kafama Yatmayanlar

- Yetkinliğe ikinci bir rol eklenmiş ("müdahalenin olası sonucunu öngörme"), fakat bunun eşiklerle nasıl ölçeklendiği yok. Ayrıca yetkinliğin seçenekleri mi açtığı, yoksa yalnızca öngörüyü mü netleştirdiği belirsiz. İkisinden biri seçilmeli.
- Danışman "tekrar kullanımı" belirsiz: teşhis bilgisi sorun çözülene kadar görünür mü kalıyor, yoksa sözleşme bitince kayboluyor mu? Kayboluyorsa oyuncu bildiği bir şeyi "unutmuş" gibi olur; bu, oyuncuyu sinirlendirir.
- Rapor yalnızca "fabrika kapandığında" veriliyor. Ayakta kalan ama kötü giden bir fabrikada oyuncu dönem içinde öğrenme geri bildirimi alamıyor. §21 ("yanlış karar save'i öldürmemeli") ile birlikte yıllık bir ara özet düşünülmeli.
- Eksik yetkinliği kapatmanın altı yolundan ortak, uzman çalışan, dış kaynak ve eğitim hâlâ birbirinden ayrışmıyor (REV-001 I2). Bu IDEA'da mı çözülecek, ayrı IDEA'ya mı taşınacak belli değil.
- Satın Alma örneğindeki "T4–T5'i teşhis edemez" ifadesi yeni metinle uyumsuz kalmış. "Kendi başına teşhis edemez; kayıp sinyali görünür, danışman veya bağımsız uzman teşhis edebilir" olarak güncellenmeli.
- "Toplam teorik maksimum: 1000" hâlâ oyun içi bir anlam taşımıyor (REV-001 M1).

### Açık Sorular

Tur 3'ten önce kullanıcının karar vermesi önerilen öncelikli üç konu:

1. Kör müdahale: kalıcı çözüm yalnızca görülebilen derinliğe kadar mı mümkün (Claude önerisi), yoksa her derinlikte küçük bir ihtimal mi olsun?
2. Yetkinlik seçenekleri mi açar, yoksa yalnızca sonuç öngörüsünü mü netleştirir?
3. Fabrika kapanınca aynı karakter mi devam eder, yoksa yeni run mı başlar? Raporun zamanı ve ayrıntısı buna bağlı.

Diğerleri:
- Müdür raporu çarpıtılabilir mi; bunu fark etmek İnsan Yönetimi yetkinliğine mi bağlı?
- Danışman teşhisi, sorun çözülene kadar görünür kalır mı?
- Ortak, uzman çalışan, dış kaynak ve eğitim bu IDEA'da mı ayrıştırılacak, yoksa ayrı bir IDEA'ya mı?

## Açık Kararlar

- “Düzelt”in para/zaman maliyetleri, eşik altındaki başarı eğrisi ve ihtimalin oyuncuya nasıl gösterileceği; 60/70 ≈ %80 örneği yalnızca başlangıç hedefidir.
- Kör denemeyi baskın strateji yapmamak için tekrar denemede aynı mı, artan mı maliyet ve/veya bekleme süresi uygulanacağı.
- Statların eşik altındaki “Düzelt” ihtimaline etkisi; yüksek statın kariyer yetkinliğini dolaylı yoldan geçersiz kılmaması.
- Danışman, müdür ve ortağın patron bilgisini hangi kapsamda tamamlayacağı; danışman raporunun başarı ihtimaline etkisi, teşhis bilgisinin kalıcılığı ve tekrar kullanım sınırı.
- Danışman seviyesi ve bulunabilirliği.
- Müdür raporlarının çarpıtılıp çarpıtılamayacağı ve bunun hangi yetkinlikle fark edileceği.
- Danışman ücret modeli ve gerçek paranın rolü (yalnızca kolaylık mı, hiç mi).
- Oyun içi açıklanamayan kayıp sinyalinin hesap tanımı ve netlik eşikleri; fabrika başarısızlık raporunun ayrıntı düzeyi ve ara dönem (yıllık) özet olup olmayacağı.
- Müdürü kovma, yenisini alma ve alışma sürecinin basit bir ayrı eylem mi yoksa daha ayrıntılı bir sistem mi olacağı.
- Sorun ertelendiğinde kaybın büyüme hızı.
- Fabrika battıktan sonraki stat/yetkinlik kaybının kapsamı, büyüklüğü, süresi ve yeniden kazanılma şekli; kapanış raporunun ayrıntı düzeyi.
- Ortak, uzman çalışan, dış kaynak ve eğitim yollarının ayrıştırılması: bu IDEA'da mı, ayrı IDEA'da mı?
- Patron görüş seviyesi ile sorun derinliği için ayrı terimler.
- Yetkinlik Tier eşikleri, kazanılma hızı, düşüşü ve beşinci yıl hedefi.
- Müdürlerin sorun çözme matematiği ve departman başına eşzamanlı problem sayısı.
- Statların öğrenme hızına vereceği azami bonus.

## Karar Özeti

Kullanıcının Tur 3 yönlendirmeleri (IDEA düzeyinde; henüz FREEZE değil):

- “Düzelt” butonu yetkinlikten bağımsız açık kalır, her deneme para ve zaman harcar; çünkü sorun çözümü ek efor veya mini oyun gerektirmemeli.
- Yetkinlik Tier eşiğine ulaşıyorsa sorun kesin çözülür; ulaşmıyorsa başarı olasılığı yetkinliğe bağlıdır (60/70 için yaklaşık %80 hedefi); çünkü bilgi açığı çözmeyi imkânsız değil, riskli kılmalı.
- Yetkinlik bilgi modeli olarak öncelikle kök neden görünürlüğünü belirler; çünkü seçenek kilitlemek yerine oyuncunun neyi bildiği öne çıkmalı.
- Fabrika batınca aynı karakter devam eder ve bazı stat/yetkinlik kayıpları yaşar; çünkü başarısızlığın bedeli olmalı, ama sonraki girişime ders taşıyabilmeli.
