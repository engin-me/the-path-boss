# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: DRAFT — Tur 9 GPT sentezi hazır, Claude incelemesi bekleniyor
Tur: 9
Son güncelleme: 2026-09-28
Kaynak: Kullanıcının sağladığı ilk öneri Codex tarafından dosyaya işlendi.
Tur 1–8 Claude incelemeleri: tamamlandı. Kullanıcının yeni yönlendirmeleri Tur 9 önerisine işlendi; `Notlar (Claude)` hâlâ Tur 8 incelemesidir.
Sıradaki adım: Claude, Tur 9 önerisini inceleyip `Notlar (Claude)` bölümünü günceller. Terimler, aynı danışmanın yeniden görünmesi ve monetizasyon dengesi henüz açık; FREEZE için ayrıca kullanıcı onayı gerekir.

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

Önerilen aylık fabrika akışı: **ay sonu raporu → ayrı sorun kartları → gerekirse danışman kartlarını değerlendirme → sorun kartındaki “Düzelt” → para ve zaman harcaması → sonuç**. Her sorunun kendi kartında bir “Düzelt” butonu ve sözel çözüm olasılığı bulunur. Patron kök nedeni göremiyorsa kart belirtiyi veya açıklanamayan kaybı gösterir; kök nedeni gizli tutar. Aynı departmanda birden fazla sorun varsa her biri ayrı karttır, dolayısıyla “Düzelt”in hangisini hedeflediği açıktır. Sorun çözümü için ek efor adımı, mini oyun veya müdahale menüsü yoktur. Oyuncu danışman tutmadan da her karttaki düzeltmeyi deneyebilir.

Etkin yetkinlik sorunun Tier eşiğine ulaşıyorsa “Düzelt” para ve zaman maliyetiyle kesin sonuç verir; eşiğin altındaysa aynı maliyet harcanır ve başarı için olasılık hesabı yapılır. Başarısız denemede sorun devam eder. Örnek: Planlama puanı 20 olan patron ve Planlama puanı 80 olan aktif danışman için etkin değer **max(20, 80) = 80** olur; 70 eşikli Planlama sorunu kesin çözülür. Danışman tutmak tek başına sorunu ortadan kaldırmaz; oyuncu yine “Düzelt”e basar. Eski **20 + 50 = 70** örneği artık geçerli değildir: max(20, 50) = 50, dolayısıyla o sorunda olasılık hesabı yapılır.

“Düzelt”, sorunun gerektirdiği işlemin yapılmış olmasıdır; kişi kaynaklı sorunda konuşma, yaptırım veya işten çıkarma gibi sonucu da kapsayabilir. Oyuncu için ayrıca müdür kovma zinciri veya her soruna özel eylem menüsü açılmaz. Hangi işlemin gerçekleştiği sonuç metninde anlatılabilir; buna ayrı bir müdür karakteri veya müdür yetkinliği gerekmez.

Eşik altı olasılığı **Tier/kademe farkına** göre düşer. Kabul edilen taslak denge: bir kademe eksik ≈ %80, iki kademe ≈ %40, üç kademe ≈ %15, dört veya daha fazla kademe ≈ %5. Örneğin 60/70 bir kademe farktır ve yaklaşık %80 başarı verir. Rakamlar oyun testleriyle ayarlanabilir; Tier eşiklerinin kesin değerleri de henüz FREEZE değildir. Her sorun kartında çözüm olasılığı yüzde yerine **yüksek / orta / düşük** olarak yazılır. Tur 8 taslak eşlemesi: ≈ %80 yüksek, ≈ %40 orta, ≈ %15 ve ≈ %5 düşük. Üç etiket yakın bilgi açıkları hakkında kısmi ipucu verir; derin açıkların tam kademesini gizler. Tekrar deneme maliyeti açık karardır.

Bu akışta yetkinlik, hangi eyleme basılabileceğinden çok **neyin yanlış gittiğini bilme** ve bilinmeyen sorunu çözme şansıyla ilgilidir. Tekrar tekrar kör denemenin teşhis ve danışmanı değersizleştirmemesi denge testinde özellikle incelenmelidir.

### İnsan Yönetimi ve Personel

Bu IDEA'da müdür için ayrı kimlik veya yetkinlik puanı tanımlanmıyor. Bu, gelecekte ekip/personel sisteminin ayrı bir IDEA'da tasarlanmasını engellemez. **Kişi kaynaklı sorunların ortaya çıkma sıklığını yalnızca patronun kalıcı İnsan Yönetimi puanı azaltır**; danışmanın İnsan Yönetimi puanı bu yatay sıklık etkisine katılmaz. Etki aylık performans raporlarına yansır. En yüksek İnsan Yönetimi yetkinliği için **yaklaşık %80 azalma tavanı** ve kişi kaynaklı sorunların toplam sorunlar içinde **yaklaşık %30–40 payı** başlangıç denge hedefidir. İnsan Yönetimi alanının kendi sorunları da vardır; bu yüzden danışman kartındaki İnsan Yönetimi puanı o alanın sorunlarını görme/çözmede işe yarar. Kişi kaynaklı bir sorun başarıyla “Düzelt”ildiğinde gereken personel işlemi çözümün içinde sayılır. Kesin sıklık eğrisi ve sorun içeriği testle belirlenecektir.

Bu yönlendirme, `GAME_OVERVIEW` §10'daki ayrı müdür uzmanlığı ve iyi/kötü müdür matrisinden ayrılıyor. FREEZE öncesi bu tutarsızlık gözden geçirilmeli; yön dondurulursa vizyon belgesi de yeni tasarıma göre güncellenmelidir.

### Statların Rolü

Statlar doğrudan yetkinlik puanı veya Tier açmaz.

Statlar:
- yetkinlik kazanma hızını,
- problem çözme süresini,
- problem çözme maliyetini,
- “Düzelt” dışındaki bazı görevlerde başarı oranını

etkileyebilir.

Statlar, eşik altı “Düzelt” olasılığını doğrudan artırmaz; burada belirleyici olan ilgili alanın yetkinliği ve danışman desteğidir. Statlar süreyi ve maliyeti etkileyebilir. Böylece yüksek Zeka, meslek deneyiminin yerini tek başına alamaz.

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

Patron kök nedeni göremese bile ilgili sorun kartı **açıklanamayan kayıp veya belirti** gösterir (`GAME_OVERVIEW` §9). Oyuncu o karttaki “Düzelt”i deneyebilir veya danışman çağırabilir; gerçek neden otomatik ifşa edilmez. Başarısız deneme sonrasında harcanan para ve zaman ile sorunun sürdüğü açıkça gösterilmelidir. Kaybın büyüklüğünün ve kategori ipuçlarının hangi düzeyde gösterileceği açık karardır.

Fabrika battıktan sonra **aynı karakterle devam edilir** ve karakter borç yüküyle yeniden başlar. Borç, toparlanmanın mümkün olduğu ölçekte olmalıdır; **yaklaşık bir oyun yılında toparlanma** kullanıcı tarafından örnek ufuk olarak verildi, kesin süre değildir. Psikoloji, yeni başlayan bir karakterinkinden yaklaşık **%25 düşük** başlayabilir; bu da taslak örnektir, sabit denge değeri değildir. Düşüş kalıcı bir başarısızlık sarmalı yaratmamalıdır.

İflas **yetkinlik kaybettirmez** ve genel stat kazanımını hızlandırmaz. Bunun yerine karakter, kayba en çok yol açan alanda küçük, üst sınırı olan **“acı tecrübe” yetkinlik artışını karakter başına bir kez** alır. Böylece iflastan öğrenilirken kasıtlı tekrar iflasla bonus biriktirme engellenir. Kalıcı bedel borç ve harcanan zamandır; psikoloji düşüşü geçicidir. Kesin artış, borç miktarı ve psikolojinin toparlanma süresi denge kararlarıdır.

Değerlendirme raporu fabrikanın ömrünü, en çok kayıp yaratan departmanları, görülen/görülmeyen sorunları ve dikkate alınmayan uyarıları özetleyebilir (`GAME_OVERVIEW` §23). Rapor oyuncuya sonraki girişimde neyi öğrenmesi veya kime yetki vermesi gerektiğini anlatmalıdır. Aynı karakterle devam etme tercihi, `GAME_OVERVIEW` §5–6 ve §25'teki “ikinci kariyer / sonraki run” dilini netleştirmeyi gerektirir; bu IDEA aşamasında vizyon belgesi değiştirilmez.

### Eksik Yetkinliği Kapatma Yolları

Oyuncunun her işi yapmış olması zorunlu değildir.

Danışman bu IDEA'da mekanikleştirilen yoldur. Aşağıdakiler diğer olası yolları gösterir; bunların kuralları ayrı IDEA'larda tasarlanmadıkça onaylanmış mekanik sayılmaz. **Ortaklık ayrı bir tasarım konusudur. Dış kaynak yalnızca olası telafi yolu olarak anılmıştır; henüz mekanik, fiyat veya kapsamı konuşulmadı.**

- iyi ekip ve personel düzeni
- ortak
- uzman çalışan
- dış kaynak
- eğitim / sonradan öğrenme

Oyunda önceden tanımlı **10–15 danışman kartı** bulunur. Her danışmanın mevcut patron yetkinliklerinden **2–5 alandaki puanı** vardır. Ay sonu raporu görüldükten sonra bu havuzdan rastgele **3 kart açılır**; oyuncu görünen profiller arasından seçim yapar. Listeyi sınırsız veya ücretsiz yeniden çekemez. **Dördüncü kartı açmak oyun parası veya gerçek paradan biriyle ödenir**; daha fazla kart açılabilip açılamayacağı ve bedeli açık karardır. Sözleşmesi süren danışmanın kartı sonraki aylarda yeniden görünebilir; aynı danışman için ikinci teklifin mevcut sözleşmeyle nasıl birleşeceği açık karardır. Önceki taslaktaki **Satış** örneği, mevcut on yetkinlik arasında olmadığı için çıkarıldı; satış/talep tasarımı ayrı konu olarak ele alınabilir.

Kartın listelediği her alan **en az 25, en fazla 100** puandır. **Kartın toplam puanı ≤ listelenen alan sayısı × 60**. Örnek: beş alanlı kartın bütçesi en fazla 300'dür; iki alan 25'er puansa kalan üç alana toplam 250 puan dağıtılabilir (ör. **25 + 25 + 83 + 83 + 84 = 300**). İki alanlı kartta bütçe 120 olduğu için bir alanın 100 olması, diğer alanın en az 25 olma şartıyla mümkün değildir; iki alanlı üst sınır örneği **95 + 25 = 120**. 100 puanlık uzmanlık en az üç alanlı profilde mümkündür. Bu sonuçlar önerilen üç kuralın matematiksel sonucudur.

Bir kartta **iki alanın 100 olması da mümkündür**: beş alanlı **100 + 100 + 50 + 25 + 25 = 300** kartı bütçe kuralını karşılar. Böyle güçlü profiller çok nadir ve çok pahalı olmalıdır. Kart başına “90+ en fazla bir alan” sınırı konmaz. Havuzda birlikte on alanı kapsayan iki kart bulunması da yasaklanmaz; kapsam, derin sorunların tamamında kesin çözüm anlamına gelmez.

Danışmanların ilgili alan puanı **100'e ulaşabilir**; 90'lık sabit üst sınır yoktur. En güçlü profiller nadir ve pahalı olmalıdır; ücret özellikle kartın **en yüksek iki alan puanına ağırlık vererek** hızla artar. Böylece iki alanı 100 olan kart gerçekten pahalı olur; düşük puanlı dolgu alanlar fiyatı yapay biçimde ucuzlatmaz. Oyuncu kendi kariyerinde öğrenmediği en derin sorunu da danışman aracılığıyla kesin çözebilir, ama bunu sürekli yapmak ağır bir oyun içi maliyet doğurur. Kesin fiyat formülü, güçlü kartların havuzdaki sayısı ve küçük fabrika kârına göre maliyet dengesi açık karardır.

Danışman **belirli süreli sözleşmeyle** tutulur ve işe alındığı anda başlar; profilindeki bütün alanlar sözleşme boyunca aktiftir. **Aynı anda en fazla iki danışman** aktif olabilir. Örnek fiyatlama: o danışmanın bir aylık ücreti **A** ise 3 ay **2,75A**, 12 ay **10A**. Süreler ve çarpanlar bağlayıcılık/indirim fikrini gösteren taslak değerlerdir. Ödenen sözleşme ücreti, danışman erken bırakılırsa da iade edilmez. İki danışman aynı anda çalışsa bile ilgili alanda **etkin yetkinlik = max(patronun puanı, aktif danışmanların o alandaki puanları)**; puanlar birbirine eklenmez ve 100'ü aşmaz. Etkin değer sorunun eşiğine ulaşırsa kök neden görünür ve “Düzelt” kesin başarı verir. Danışman ayrılınca patronun kalıcı puanı artmış sayılmaz.

Danışman sözleşmesi oyun parası **veya** gerçek paradan biriyle ödenebilir; ikisi birden istenmez. Aynı danışman teklifine oyun parasıyla da erişilebilmelidir; gerçek para ödemesi sorunu çözmek için zorunlu hale gelmez. Ay sonu kart açılışı dışında ek bekleme yoktur; danışman hemen göreve başlar. Sürekli danışman tutmanın kariyer deneyimini değersizleştirmemesi için fiyatlar, dördüncü kart açma bedeli ve gelir dengesi sınanmalıdır. Ek kartın gerçek parayla açılması ücretli arama avantajı doğurduğu için monetizasyon incelemesinde özellikle değerlendirilmelidir.

### Tasarım İlkesi

Mükemmel patron her şeyi kendisi yapan kişi değildir.

Neyi bildiğini bilir.
Neyi bilmediğini bilir.
Bilmediği işi kime bırakacağını bilir.

“Düzelt” sade bir operasyon eylemidir; fabrika döneminin stratejisi danışman seçimi, personel sonuçları, bütçe, zaman ve diğer yönetim kararlarında kurulmalıdır. Bu sistemlerin kapsamı ayrıca tasarlanacaktır.

## Notlar (Claude)

Tarihçe: Tur 1 inceleme [REV-001](../reviews/REV-001_claude_patron_yetkinlikleri.md) ve bu dosyanın Git geçmişi. Aşağıdakiler Tur 8 `Öneri (GPT)` metninin incelemesidir. `Karar Özeti`'ndeki kullanıcı yönlendirmeleri (iki 100'lük kart ve iki kartla tam kapsam dahil) tartışmaya açılmamış; notlar bu yönlendirmelerin gerekçelerinin doğruluğunu ve kalan açıkları hedefler.

### Aldığım Notlar

- Tur 7'nin kritik bulgularından biri kapandı: kişi kaynaklı sorunların sıklığını artık yalnızca patronun kalıcı İnsan Yönetimi puanı azaltıyor. Danışman bu yatay kariyer yatırımının yerini tutamaz.
- Dört sözel düzeyden üçe inildi; en derin iki kademe farkı artık tek etiket ("düşük") altında birleşiyor.
- İki 100'lük kart ve iki kartla tam alan kapsamı kullanıcının bilinçli tercihi olarak Karar Özeti'ne gerekçesiyle girdi. Denge artık iki yuva kuralına, nadirliğe ve fiyata dayanıyor.
- Çekirdek kurallar tamamlandı. "FREEZE öncesi" grubunda kalan maddelerin çoğu küçük ve evet/hayır niteliğinde; tek önemli tasarım sorusu İnsan Yönetimi.

### Bulduğum Sakıncalar

- **Üç etiket gizli kademeyi hâlâ kısmen ele veriyor:** "Yüksek" tam 1 kademe, "orta" tam 2 kademe farkı demek; yalnızca "düşük" 3 ile 4+ kademeyi birleştiriyor. Dört olasılık üç etikete dağıtılınca en az iki etiket her zaman tek bir kademeye karşılık gelir; bu matematiksel olarak kaçınılmaz. Karar Özeti'ndeki gerekçe ("dört sözcük dört kademe farkını birebir ele veriyordu") yeni durumu tam karşılamıyor. İki yol var:
  - (a) Kısmi ifşa bilinçli kabul edilir ve gerekçe "yakın bilgi açıklarını sezdirir, derin açıkları gizler" olarak düzeltilir. Bu tematik olarak da savunulabilir: patron bir kademe yukarıdaki sorunu sezer ama çok derindekini sezemez.
  - (b) Tam gizlilik isteniyorsa iki etikete inilir.
  - Claude önerisi: (a). Kullanıcı kararını değiştirmez, yalnızca gerekçeyi doğru kılar.
- **Kart bütçesi gerekçesi matematikle çelişiyor:** Karar Özeti "toplam puan bütçesi zaten geniş kartları sınırlar" diyor. Oysa bütçe alan sayısıyla büyüyor (beş alanlı kartta 300, üç alanlı kartta 180), bu yüzden geniş kartlar hem daha geniş hem daha derin olabiliyor. Bütçe geniş kartları sınırlamıyor, ödüllendiriyor. Kullanıcı kararı korunabilir, ama bu durumda denge tamamen fiyata ve nadirliğe dayanıyor. Öneri: fiyat formülü kartın en yüksek iki puanını ağırlıklı saysın. Böylece 25'lik dolgu alanlar kartı ucuzlatmaz ve iki 100'lük kart gerçekten "çok pahalı" olur. Karar Özeti'ndeki gerekçe de buna göre düzeltilmeli.

### Kafama Yatmayanlar

- **Danışmanın İnsan Yönetimi puanı boşta kalabilir:** Danışmanın İnsan Yönetimi puanı artık yalnızca İnsan Yönetimi alanındaki sorunlarda işe yarıyor. Ama İnsan Yönetimi'nin kendi alan (İK) sorunları hâlâ tanımsız. Tanımlanmazsa kartlardaki İnsan Yönetimi puanı hiçbir şey yapmayan bir sayı olur. İki yol var: İnsan Yönetimi'nin kendi alan sorunları olsun, ya da danışman kartlarında İnsan Yönetimi alanı hiç bulunmasın.
- **İnsan Yönetimi azaltma üst sınırı ve kişi kaynaklı sorunların payı hâlâ açık:** Tur 7'de önerilen %30–40 pay sınırı yanıt bekliyor. Güçlü bir azaltma oranı (%80–90) ancak bu pay sınırlıysa alan yetkinliklerini gölgelemez.
- **Uzun süredir bekleyen küçük kararlar:** aktif kartın havuzdan çıkması (Tur 6'dan beri), açıklanamayan kayıp üzerinden "Düzelt"in hedefi (Tur 3'ten beri), gerçek paranın rolü, terimler ve eksik yetkinliği kapatma listesinin FREEZE'deki durumu. Hepsi evet/hayır sorusu ve tek seferde onaylanabilir.

### Açık Sorular

Tur 9'dan önce kullanıcının karar vermesi önerilen üç konu:

1. Üç etiketin kısmi ifşası bilinçli kabul edilip Karar Özeti gerekçesi düzeltilsin mi (Claude önerisi), yoksa iki etikete mi inilsin?
2. İnsan Yönetimi: azaltma üst sınırı ne olsun (ör. %80–90)? İnsan Yönetimi'nin kendi alan sorunları olsun mu (olmayacaksa danışman kartlarında İnsan Yönetimi alanı bulunmasın)? Kişi kaynaklı sorunların payı %30–40 ile sınırlansın mı?
3. **Onay paketi:** aşağıdaki Claude önerileri tek seferde kabul edilsin mi?
   - Sözleşmedeki kart havuzdan çıkar.
   - Açıklanamayan kayıp üzerinden "Düzelt" en sığ gizli sorunu hedefler; şans o sorunun eşiğine göre hesaplanır.
   - Danışman kartları ve ek kart gerçek parayla satılmaz.
   - Terimler: patron için "Görüş Seviyesi", sorun için "Sorun Derinliği".
   - Eksik yetkinliği kapatma listesi FREEZE'e "onaylanmamış, ileride tasarlanacak" olarak girer.
   - Danışman fiyatı kartın en yüksek iki puanını ağırlıklı sayar; kart bütçesi gerekçesi buna göre düzeltilir.

Bu üç kararla "FREEZE öncesi" grubu kapanır. Sonraki adım, kullanıcı onayıyla FRZ-001 taslağı olabilir.

## Açık Kararlar

### FREEZE öncesi kapanması önerilenler (ilke düzeyinde)

- Üç sözel başarı düzeyinin kesin olasılıklarla eşleşmesi ve oyuncuya yeterince anlaşılır geri bildirim vermesi; %80 yüksek / %40 orta / %15–5 düşük taslak eşlemedir. Üç etiket yakın açığı kısmen sezdirir, derin açığı gizler.
- Kart puan bütçesinin oyuncuya nasıl gösterileceği ve iki tane 100 puan içeren kartın nadirlik/fiyat dengesi; fiyat kartın en yüksek iki puanına ağırlık verir, kesin formül testle belirlenecek.
- Aktif danışman kartı yeniden göründüğünde ikinci teklifin mevcut sözleşmeyi uzatıp uzatmadığı; dördüncü kartın iki para birimindeki fiyatı ve beşinci kartın açılıp açılamayacağı.
- İnsan Yönetimi alanındaki özgül sorunların içeriği, kaynak türü etiketleri ve %80 azaltma / %30–40 kişi kaynaklı sorun payı hedeflerinin testle ayarlanması. Yatay sıklık etkisi yalnızca patronun kalıcı puanına bağlıdır.
- Her sorun kartında kök neden gizliyken hangi belirti ve kayıp bilgisinin gösterileceği; “Düzelt” her zaman basıldığı kartın sorununu hedefler.
- Ortaklık ayrı IDEA'da; dış kaynak, iyi ekip, uzman çalışan ve eğitim henüz tasarlanmamış olası yollar olarak kalır. FREEZE'e onaylı mekanik olarak girmezler.
- Danışman ve dördüncü kart için oyun parası / gerçek para fiyat dengesi; aynı teklifin oyun parasıyla erişilebilirliği ve ücretli ek kartın rekabet avantajı.
- Patron görüşü ve sorun derinliği için ayrı ad gerekip gerekmediği. “Görüş Seviyesi / Sorun Derinliği” yalnızca terim önerisidir; yeni mekanik veya tetikleyici yaratmaz.

### Denge parametreleri ve testle kesinleşecekler

- “Düzelt”in para/zaman maliyetleri.
- Kabul edilen taslak kademe eğrisinin (≈ %80 / %40 / %15 / %5) oyun testlerinde ayarlanması; Tier içinde farklı puanların aynı şansa sahip olmasının uygunluğu.
- Kör denemeyi baskın strateji yapmamak için tekrar denemede aynı mı, artan mı maliyet ve/veya bekleme süresi uygulanacağı.
- Kart havuzunun kesin büyüklüğü (10–15), her ayki 3 kartın seçim yöntemi, güçlü kartların nadirliği; havuzun ezberlenmesine karşı puan varyasyonu veya büyüyen havuz.
- Kesin fiyat formülü ve 1/3/12 ay için A/2,75A/10A örneklerinin kesinleşmesi.
- Uzun süreli çok alanlı danışmanların baskın strateji olup olmadığı; yıllık danışman maliyetinin küçük fabrika net kârına oranı ve kariyer yetkinliğinin değeri.
- İki aktif danışman ve alan sayısı × 60 bütçesinin dengede kariyer yatırımını koruyup korumadığı; iki kartla kapsanabilen en geniş alan kümesi.
- İnsan Yönetimi'nin kişi kaynaklı sorun sıklığını ne kadar azalttığı ve aylık performans raporlarına nasıl yansıdığı.
- Oyun içi açıklanamayan kayıp sinyalinin hesap tanımı ve netlik eşikleri; her sorunun ayrı kartta gösteriminin UI yükü; fabrika başarısızlık raporunun ayrıntı düzeyi ve ara dönem (yıllık) özet olup olmayacağı.
- Kişi kaynaklı sorunda “Düzelt”in hangi sonucu ve maliyeti ürettiğinin oyuncuya nasıl anlatılacağı; ayrı müdür karakteri veya eylemi açılmaz.
- Sorun ertelendiğinde kaybın büyüme hızı.
- İflas borcunun miktarı ve yaklaşık bir oyun yılında toparlanmanın denge hedefi olup olmayacağı; psikoloji düşüşünün süresi ve toparlanma hızı. Claude önerisi: psikoloji belirli sürede kendiliğinden toparlanır, borç ödemesi gelire oranlanır (açık).
- “Acı tecrübe” artışının kesin büyüklüğü ve üst sınırı; karakter başına tek seferlik verilmesinin denge testi.
- Yetkinlik Tier eşikleri (T4–T5 arasındaki 10 puanlık aralığın kademe eğrisiyle birlikte yeniden değerlendirilmesi dahil), kazanılma hızı, düşüşü ve beşinci yıl hedefi.
- Departman başına eşzamanlı problem sayısı.
- Statların öğrenme hızına vereceği azami bonus.

### Ayrı IDEA veya FREEZE sonrası işler

- Satış/talep konusunun ayrı IDEA olarak ele alınması ve mevcut on yetkinlik listesine etkisi.
- Ekip/personel (müdür) sisteminin ayrı IDEA'da tasarlanması.
- `GAME_OVERVIEW` §10'daki müdür modelinin ve §5–6, §25'teki "run" dilinin bu IDEA ile uyumlandırılması (FREEZE sonrası).
- Oyunun süresi ve bitiş koşulu; iflastan sonraki sermaye/borç durumu. Claude önerisi: çekirdek oyun döngüsü IDEA'sına taşınır (açık).
- Fabrika dönemindeki stratejik derinliğin “Düzelt” dışında hangi sistemlerden geleceği.

## Karar Özeti

Kullanıcının yönlendirmeleri (IDEA düzeyinde; henüz FREEZE değil):

- “Düzelt” butonu yetkinlikten bağımsız açık kalır, her deneme para ve zaman harcar; çünkü sorun çözümü ek efor veya mini oyun gerektirmemeli.
- Yetkinlik Tier eşiğine ulaşıyorsa sorun kesin çözülür; ulaşmıyorsa başarı olasılığı yetkinliğe bağlıdır (60/70 için yaklaşık %80 hedefi); çünkü bilgi açığı çözmeyi imkânsız değil, riskli kılmalı.
- Yetkinlik bilgi modeli olarak öncelikle kök neden görünürlüğünü belirler; çünkü seçenek kilitlemek yerine oyuncunun neyi bildiği öne çıkmalı.
- Fabrika batınca aynı karakter devam eder; çünkü başarısızlık sonraki girişime ders taşımalı.
- Ay sonunda 10–15 sabit profilden rastgele 3 danışman kartı açılır, dördüncü kart oyun parası veya gerçek parayla açılır; çünkü oyuncu rapordan sonra seçim yapmalı ve ek kart için ödeme yolu seçebilmeli.
- Her danışman 2–5 alandaki görünür puanıyla fiyatlanır; çünkü farklı bilgi açıkları ve bütçeler için seçenekler olmalı.
- Danışman sözleşmesi süreli ve bütün profil alanları boyunca aktiftir; çünkü oyuncu tek alanlık kısa görev yerine kapsamlı bir danışman seçip süreye bağlanmak istiyor.
- Etkin yetkinlik patron ve aktif danışman puanlarının en yükseğidir, toplama değildir; çünkü çok danışman tutmak 100 üstü puan veya sınırsız güç üretmemeli.
- Aynı anda en fazla iki danışman aktiftir; çünkü tüm alanları sürekli dış destekle kapatmak kariyer yetkinliğinin değerini azaltır.
- Kartta 2–5 alan bulunur, her biri 25–100 puandır ve toplamları alan sayısı × 60'ı aşmaz; çünkü danışman profillerinin puan bütçesi tanımlı olmalı, geniş kartların dengesi ise fiyat ve nadirlikle sağlanmalı.
- Aynı kartta iki ayrı alan 100 puan olabilir ama böyle kartlar çok nadir ve pahalıdır; çünkü kullanıcı güçlü danışman seçeneklerini mümkün tutmak istiyor.
- Danışman puanı 100'e ulaşabilir ve yüksek puan pahalı/nadir olur; çünkü öğrenilmemiş en derin sorun da danışmanla çözülebilmeli ama sürekli dış destek maliyetli olmalı.
- Danışman sözleşme imzalanınca hemen başlar ve ödenen ücret iade edilmez; çünkü oyuncu ay sonu raporundan sonra hemen harekete geçebilmeli, uzun sözleşmenin indirimine de bağlanmalı.
- Etkin yetkinlik eşiğe ulaştığında “Düzelt” kesin sonuç verir; çünkü danışman tutmanın kör denemeye göre somut faydası olmalı.
- Eşik altı başarı ihtimali kademe farkına göre yaklaşık %80 / %40 / %15 / %5 düşer; çünkü derin bilgi açığında kör deneme anlamlı risk taşımalı.
- İflas sonrası karakter borçla ve daha düşük psikolojiyle devam eder; çünkü kayıp hissedilmeli ama toparlanma mümkün olmalı, borç süresi ve yaklaşık %25 psikoloji farkı henüz örnektir.
- İflas yetkinlik kaybettirmez veya genel stat kazanımını hızlandırmaz; bunun yerine karakter başına tek seferlik sınırlı “acı tecrübe” kazandırır, çünkü başarısızlık öğretmeli ve kasıtlı iflas ödül döngüsüne dönüşmemeli.
- “Düzelt” gereken personel işlemlerini de kapsar ve ayrı müdür yetkinliği tanımlanmaz; çünkü oyuncunun yönetim bilgisi İnsan Yönetimi yetkinliği ve aylık sonuçlarda temsil edilmeli.
- İnsan Yönetimi yükseldikçe kişi kaynaklı sorunların sıklığı azalır; çünkü bu yetkinliğin aylık personel sonuçlarında somut karşılığı olmalı.
- İnsan Yönetimi için %50 azaltma tavanı reddedildi, daha güçlü etki önerilecek; çünkü oyuncunun bu yetkinliğe zaman ayırması anlamlı olmalı, kesin oran henüz açık.
- Statlar eşik altı “Düzelt” şansını artırmaz ve gizli sorunlarda şans kaba aralıkla gösterilir; çünkü kariyer bilgisi statla aşılamamalı ve kesin yüzde gizli Tier'ı ele vermemeli.
- Her sorun kendi “Düzelt” butonunu ve yüksek/orta/düşük şans etiketini taşır; çünkü oyuncu hangi soruna müdahale ettiğini ve riskini kart üzerinde görmeli, üç etiket yakın açığı kısmen sezdirirken derin açığı gizler.
- Kişi kaynaklı sorunların sıklığını yalnızca patronun kalıcı İnsan Yönetimi puanı azaltır; çünkü danışman bu yatay kariyer yatırımının yerini almamalı.
- İki danışman kartının birleşince on alanı kapsaması yasaklanmaz; çünkü kapsam tek başına derin sorunlarda kesin çözüm sağlamaz, geniş kartların dengesi fiyat ve nadirlikle kurulmalı.
- Sözleşmesi süren danışman sonraki ay yeniden aday olabilir; çünkü sabit kart havuzundan çekiliş aktif kartları otomatik dışlamaz.
- Danışman sözleşmesi oyun parası veya gerçek parayla ödenebilir; çünkü oyuncuya iki ödeme seçeneği sunulurken gerçek para zorunlu olmamalı.
- Danışman fiyatında en yüksek iki alan puanı daha ağır basar; çünkü iki zirve uzmanlığı olan kart ciddi bir bedel taşımalı.
- İnsan Yönetimi yaklaşık %80'e kadar kişi kaynaklı sorunları azaltır, kendi alan sorunları da vardır ve kişi kaynaklı sorunlar toplamın yaklaşık %30–40'ıdır; çünkü bu yetkinlik güçlü ama diğer alanların yerini almayan bir yatırım olmalı.
- Ayrı müdür/ekip mekaniği IDEA-001'in kapsamı dışındadır ve daha sonra tasarlanabilir; çünkü bugünkü basit “Düzelt” akışı gelecekte ekip kararlarını kapatmamalı.
