# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: DRAFT — GPT sentezi, yeni inceleme bekliyor
Tur: 2
Son güncelleme: 2026-09-28
Kaynak: Kullanıcının sağladığı ilk öneri Codex tarafından dosyaya işlendi.
Tur 1 Claude incelemesi: tamamlandı (`Notlar (Claude)`).
Sıradaki adım: Claude, güncellenen `Öneri (GPT)` bölümünü inceler; açık kararlar kullanıcıya sunulur.

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

Tarihçe: İlk ayrıntılı inceleme [REV-001](../reviews/REV-001_claude_patron_yetkinlikleri.md). Bu bölüm REV-001'in C1–C3 bulgularına verilen çözüm önerilerini ve kullanıcının yönlendirmelerini içerir.

### Aldığım Notlar

- Korunmalı: müdür × patron 2x2 matrisi, "Tasarım İlkesi", Satın Alma T1–T5 örneği, erken fabrika kurma özgürlüğü.
- **Çözüm döngüsü (C1):** sinyal → teşhis → müdahale → sonuç. Kalıcı çözüm yalnızca kök neden teşhis edildiğinde mümkündür (patron, müdür, danışman veya ortak teşhis edebilir). Aksi halde müdahale belirtiyi giderir ve sorun geri döner.
- **Departmandan bağımsız 6 genel müdahale:** doğrudan müdahale (patron zamanı) · müdüre delege (müdür seviyesine kadar) · süreç/sistem değişikliği (kalıcı, kök neden teşhisi şart) · kaynak ekle (para, finansa yan etki) · personel kararı (İnsan Yönetimi riski) · bilinçli kabul/erteleme (kayıp zamanla büyür). Ekran aynı kalır, metinler departmana göre değişir (GAME_OVERVIEW §27). Böylece 10 × 5 senaryo için ayrı müdahale yazma yükü doğmaz.
- **Yetkinliğin müdahaledeki rolü:** kalıcı çözüm seçeneklerini açar ve sonucun öngörülebilirliğini artırır. Statlar süre, maliyet ve başarı oranını değiştirir.
- **Danışman (C2):** "patronun en fazla +1 Tier üstü" tavanı kaldırılmalı; §11–12 ve §27 bilgi açığının uzmanla kapatılabilmesini istiyor. Danışman tek departmanda, geçici ve yalnızca teşhis sağlar; derinliği kendi seviyesiyle sınırlıdır. Bedeli: oyun parası + patron zamanı + bekleme süresi. Oyun içi kaynakla her zaman erişilebilir; gerçek para en fazla kolaylık sunabilir (§26).
- **Yetkinlik neden hâlâ değerli:** yetkinlik her zaman ve her departmanda açık, bedelsiz ve kalıcıdır; danışman istenince, tek departmanda, bedelli ve geçicidir. Müdürden kaynaklanan T4–T5 sorunlar (kayırma, komisyon) bağımsız bir göz gerektirdiği için iyi müdür yetkinliğin yerini tutamaz.
- **Sinyal ve rapor (C3):** Öneriye şu cümle eklenmeli: "Neden gizli kalabilir; kaybın varlığı her zaman gösterilir ve sonuç raporunda açıklanır." Oyun içi sinyal §9'a bağlanır: departman kartında açıklanamayan kayıp göstergesi ve tekrar sayacı ("bu sorun 3. kez döndü"). Sinyal, danışmanın nereye çağrılacağını gösterir. Rapor §23'e bağlanır: fabrika ömrü, departman kayıp payı, görülen ve görülmeyen sorunlar (kategori + Tier) ve uyarı geçmişi ("5 sinyal, 0 araştırma"). Sorun dağılımı run'lar arasında rastgele olmalı.

### Bulduğum Sakıncalar

- Süreç değişikliği veya kaynak ekleme her durumda en iyiyse dominant strateji olur. Her müdahalenin açıkça zayıf kaldığı bir durum olmalı.
- Danışman ucuz kalırsa "her departmana sürekli danışman" hâlâ dominant olabilir. Bekleme süresi, patron zamanı ve tekrar çağırma gereksiniminin yeterli bir fren olup olmadığı test edilmeli.
- Müdür kaynaklı derin sorunlar dengeyi sağlar, ama her departmanda T5'in yolsuzluğa indirgenmesi tekrar hissi yaratır (REV-001 I3).
- "Danışman seviyesi" yeni bir parametredir; danışman seçimi ayrı bir mini sisteme dönüşmemeli.
- Rapor fazla ayrıntılıysa sonraki run'da keşif hissi azalır.

### Kafama Yatmayanlar

- "Tier" hem patronun görüş seviyesi hem sorunun derinliği için kullanılıyor (REV-001 M2). Müdahale kuralları yazılınca bu karışıklık büyür; iki ayrı terim gerekli.
- "Eğitim / sonradan öğrenme" fabrika döneminde kalıcı yetkinlik veriyorsa, "danışman kalıcı yetkinlik vermez" (§11) ilkesiyle sınırı çizilmeli.
- Tier eşikleri (T4→T5 arası yalnızca 10 puan) müdahale döngüsü belli olmadan kesinleştirilmemeli (REV-001 C4).

### Açık Sorular

- Fabrika kapanınca aynı karakter mi devam eder, yoksa yeni run mı başlar? Raporun ne zaman verileceği buna bağlı: her iflasta mı, iflas eşiğinde mi, yıllık mı?
- Danışman ücreti sabit mi, fabrika ölçeğine mi, danışman seviyesine mi bağlı?
- Sinyal hangi yetkinlik değerlerinde "var → büyüklük → kategori" aşamalarına geçer?
- Bilinçli kabul seçeneğinde kayıp ne hızla büyür?
- Gerçek parayla danışmanlık hiç sunulacak mı?

## Açık Kararlar

- Altı genel müdahale ailesinin kapsamı, hangi koşullarda açıldığı ve zaman/oyun parası maliyeti.
- Kök neden teşhisi kalıcı çözüm için mutlak koşul mu, yoksa başarıyı ve öngörülebilirliği artıran bir avantaj mı?
- Danışman, müdür ve ortağın patron bilgisini hangi kapsamda tamamlayacağı; danışman raporunun süresi ve tekrar kullanım sınırı.
- Danışman ücret modeli ve gerçek paranın rolü (yalnızca kolaylık mı, hiç mi).
- Oyun içi açıklanamayan kayıp sinyalinin netlik eşikleri ve fabrika başarısızlık raporunun ayrıntı düzeyi.
- "Bilinçli kabul/erteleme" seçeneğinde kaybın büyüme hızı.
- Fabrika kapanışından sonra aynı karakterin devam edip etmeyeceği (raporun zamanını belirler).
- Patron görüş seviyesi ile sorun derinliği için ayrı terimler.
- Yetkinlik Tier eşikleri, kazanılma hızı, düşüşü ve beşinci yıl hedefi.
- Müdürlerin sorun çözme matematiği ve departman başına eşzamanlı problem sayısı.
- Statların öğrenme hızına vereceği azami bonus.

## Karar Özeti

Henüz kullanıcı tarafından onaylanmış karar veya FREEZE yok.
