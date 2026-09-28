# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: DRAFT — Tur 2 Claude incelemesi tamamlandı
Tur: 2
Son güncelleme: 2026-09-28
Kaynak: Kullanıcının sağladığı ilk öneri Codex tarafından dosyaya işlendi.
Tur 1 Claude incelemesi: tamamlandı. Tur 2 GPT sentezi: tamamlandı. Tur 2 Claude incelemesi: tamamlandı (`Notlar (Claude)`).
Sıradaki adım: Kullanıcı, `Notlar (Claude)` → `Açık Sorular` altındaki öncelikli üç kararı seçer; ardından GPT Tur 3 sentezini yapar.

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

Yetkinlik, patronun ilgili departmandaki sorunları **kendi başına** ne kadar derinden teşhis edebildiğini ve bir müdahalenin olası sonucunu ne kadar iyi öngördüğünü belirler. Sorunu görmek, onu kendiliğinden çözmez. Patronun bilmediği bir kök nedeni yetkin bir müdür, danışman veya ortak teşhis edebilir; böyle bir rapor patrona kalıcı yetkinlik kazandırmaz.

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

Satın Alma yetkinliği 70 olan patron T1-T3 sorunlarını görebilir; T4-T5'i teşhis edemez.

### Sorun Çözüm Döngüsü

Önerilen akış: **sinyal → araştırma/teşhis → müdahale kararı → zaman ve kaynak harcaması → sonuç → izleme**. Araştırmayı patron yapabilir veya yetkin birine devredebilir. Bir departmanda açıklanamayan kayıp bulunması, kök nedenin oyuncuya açıklanması anlamına gelmez; oyuncuya araştıracağı yeri gösterir.

Teşhis edilen kök nedene uygun müdahalenin kalıcı sonuç verme ihtimali daha yüksek ve maliyeti daha öngörülebilirdir. Kök neden bilinmeden yapılan müdahale bir belirtiyi hafifletebilir; bazen doğru sonuca da ulaşabilir, fakat nedeni ortadan kalkmadıysa sorun yeniden ortaya çıkar. Oyuncu, tekrarı ve önceki müdahalenin sınırlı etkisini görebilmelidir. Tekrar, keyfî bir sayaçla değil devam eden nedenin etkisiyle oluşur.

### Genel Müdahale Türleri

Aşağıdaki altı tür, her departmanda kullanılabilecek **taslak eylem aileleridir**; her sorun için altısının birden sunulması gerekmez. Seçenekler teşhise, ekibe ve koşullara göre açılır. Hiçbiri her durumda en iyi seçenek olmamalıdır.

1. **Doğrudan müdahale:** Patron kendi yönetim zamanını harcar; bilgi açığı varsa etkisi sınırlı veya maliyeti belirsiz olabilir.
2. **Müdüre devretme:** Rutin işlerde patron zamanını korur; müdürün uzmanlığına ve güvenilirliğine bağlıdır. Müdürden şüpheleniliyorsa bağımsız kontrol gerekir.
3. **Süreç veya sistem değişikliği:** İlk yatırım ve uygulama zamanı ister; teşhis edilen kök nedene uyarsa uzun süreli fayda sağlayabilir.
4. **Kaynak ekleme:** Para veya kapasite açığını hızlı kapatabilir; nakit akışı ve başka departmanlarda fırsat maliyeti yaratır.
5. **Personel kararı:** İşe alma, eğitim, görev değiştirme veya ayrılma yoluyla çözüm arar; İnsan Yönetimi riski ve geçiş süresi taşır.
6. **Bilinçli kabul veya erteleme:** Bugünkü zamanı ve parayı korur; sorun izlenmezse kayıp veya risk büyüyebilir.

Sonuç; nedenin doğru anlaşılmasına, seçilen eylemin uygunluğuna, çalışanların becerisine ve statların etkilediği uygulama süresi/maliyetine bağlıdır. Kesin başarı oranları ve kayıp büyümesi bu IDEA'nın açık kararlarıdır.

### Müdür Etkisi

Müdürün kendi uzmanlığı bazı düşük Tier sorunları patrona ulaşmadan çözebilmelidir.

Müdürün çözebildiği rutin işler ve hazırladığı raporlar patronun zamanını korur. Müdürün kendisinin sorun kaynağı olabildiği durumlarda patronun bilgisi veya bağımsız bir uzman denetimi değer kazanır. Derin sorunların her departmanda yolsuzluk olarak yazılması gerekmez.

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

Patron kök nedeni göremese bile departman kartı **açıklanamayan kayıp** sinyali verir (`GAME_OVERVIEW` §9). Daha önce müdahale edilen bir sorunun yeniden ortaya çıkması da görünür olmalıdır. Sinyal, danışman veya başka bir uzman çağırma kararına dayanak sağlar; gerçek nedeni otomatik ifşa etmez. Kaybın büyüklüğünün ve kategori ipuçlarının hangi düzeyde gösterileceği açık karardır.

Fabrika kapandığında bir değerlendirme raporu, fabrikanın ömrünü, en çok kayıp yaratan departmanları, görülen/görülmeyen sorunları ve dikkate alınmayan uyarıları özetleyebilir (`GAME_OVERVIEW` §23). Rapor oyuncuya neyi öğrenmesi veya kime yetki vermesi gerektiğini anlatmalıdır. Sonraki oyunun keşif değerini korumak için kök nedenlerin tam ayrıntısı ve raporun zamanlaması henüz belirlenmedi. Aynı karakterle devam edilip edilmeyeceği de ayrı bir karardır.

### Eksik Yetkinliği Kapatma Yolları

Oyuncunun her işi yapmış olması zorunlu değildir.

Eksikler şunlarla kapatılabilir:

- iyi müdür
- danışman
- ortak
- uzman çalışan
- dış kaynak
- eğitim / sonradan öğrenme

Danışman özellikle patronun göremediği daha derin sorunları **kendi uzmanlığı ölçüsünde** teşhis edebilir; erişimi patronun görüşünün yalnızca bir kademe üstüyle sınırlanmaz. Raporu tek departmandaki belirli bir duruma yöneliktir: teşhis bilgisi kullanılabilir, fakat patronun genel yetkinliği kalıcı olarak yükselmez. Danışman doğrudan çözüm sağlamaz; müdahale kararı ve uygulaması ayrıca gerekir.

Danışman çağırmak oyun içi para, yönetim zamanı ve bekleme süresi harcatabilir. Bu kaynakların dengesi, sürekli danışman kullanımını otomatik en iyi strateji yapmamalıdır. Oyunun ürettiği bir sorunu çözmek için gerçek para harcamak zorunlu olamaz. Danışmanın fiyatı, tekrar kullanımı ve monetizasyon biçimi henüz kesinleşmedi.

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

- Altı genel müdahale ailesinin kapsamı, hangi koşullarda açıldığı ve zaman/oyun parası maliyeti. Claude önerisi: sorun bazlı değil, genel ön koşullarla açılır (açık).
- Kök neden teşhisi kalıcı çözüm için mutlak koşul mu, yoksa başarıyı ve öngörülebilirliği artıran bir avantaj mı? Claude önerisi: kör kalıcı çözüm yalnızca patronun görebildiği derinliğe kadar (açık).
- Statların kör müdahale başarısını etkileyip etkilemeyeceği.
- Yetkinliğin rolü: seçenekleri açmak mı, sonuç öngörüsünü netleştirmek mi? Öngörünün eşiklerle ölçeklenmesi.
- Danışman, müdür ve ortağın patron bilgisini hangi kapsamda tamamlayacağı; danışman raporunun süresi, teşhis bilgisinin kalıcılığı ve tekrar kullanım sınırı.
- Danışman seviyesi ve bulunabilirliği.
- Müdür raporlarının çarpıtılıp çarpıtılamayacağı ve bunun hangi yetkinlikle fark edileceği.
- Danışman ücret modeli ve gerçek paranın rolü (yalnızca kolaylık mı, hiç mi).
- Oyun içi açıklanamayan kayıp sinyalinin hesap tanımı ve netlik eşikleri; fabrika başarısızlık raporunun ayrıntı düzeyi ve ara dönem (yıllık) özet olup olmayacağı.
- "Bilinçli kabul/erteleme" seçeneğinde kaybın büyüme hızı.
- Fabrika kapanışından sonra aynı karakterin devam edip etmeyeceği (raporun zamanını belirler).
- Ortak, uzman çalışan, dış kaynak ve eğitim yollarının ayrıştırılması: bu IDEA'da mı, ayrı IDEA'da mı?
- Patron görüş seviyesi ile sorun derinliği için ayrı terimler.
- Yetkinlik Tier eşikleri, kazanılma hızı, düşüşü ve beşinci yıl hedefi.
- Müdürlerin sorun çözme matematiği ve departman başına eşzamanlı problem sayısı.
- Statların öğrenme hızına vereceği azami bonus.

## Karar Özeti

Henüz kullanıcı tarafından onaylanmış karar veya FREEZE yok.
