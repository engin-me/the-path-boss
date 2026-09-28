# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: DRAFT — Tur 7 Claude incelemesi tamamlandı
Tur: 7
Son güncelleme: 2026-09-28
Kaynak: Kullanıcının sağladığı ilk öneri Codex tarafından dosyaya işlendi.
Tur 1–7 Claude incelemeleri: tamamlandı. Kullanıcının yeni yönlendirmeleri Tur 7 önerisine işlendi; `Notlar (Claude)` Tur 7 incelemesidir.
Sıradaki adım: Kullanıcı, `Notlar (Claude)` → `Açık Sorular` altındaki öncelikli üç kararı seçer; ardından Codex Tur 8 sentezini yapar. Bu üç karar ve `Açık Kararlar` → "FREEZE öncesi" grubunun kapanmasıyla IDEA-001 FREEZE taslağına hazır görünüyor.

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

Önerilen aylık fabrika akışı: **ay sonu raporu → sorun/açıklanamayan kayıp sinyali → danışman kartlarını değerlendirme → “Düzelt” → para ve zaman harcaması → sonuç**. Sorun çözümü için ek efor adımı, mini oyun veya her soruna özel müdahale menüsü yoktur. Patron derin nedeni göremese de “Düzelt” butonu aktiftir. Oyuncu danışman tutmadan da düzeltmeyi deneyebilir.

Etkin yetkinlik sorunun Tier eşiğine ulaşıyorsa “Düzelt” para ve zaman maliyetiyle kesin sonuç verir; eşiğin altındaysa aynı maliyet harcanır ve başarı için olasılık hesabı yapılır. Başarısız denemede sorun devam eder. Örnek: Planlama puanı 20 olan patron ve Planlama puanı 80 olan aktif danışman için etkin değer **max(20, 80) = 80** olur; 70 eşikli Planlama sorunu kesin çözülür. Danışman tutmak tek başına sorunu ortadan kaldırmaz; oyuncu yine “Düzelt”e basar. Eski **20 + 50 = 70** örneği artık geçerli değildir: max(20, 50) = 50, dolayısıyla o sorunda olasılık hesabı yapılır.

“Düzelt”, sorunun gerektirdiği işlemin yapılmış olmasıdır; kişi kaynaklı sorunda konuşma, yaptırım veya işten çıkarma gibi sonucu da kapsayabilir. Oyuncu için ayrıca müdür kovma zinciri veya her soruna özel eylem menüsü açılmaz. Hangi işlemin gerçekleştiği sonuç metninde anlatılabilir; buna ayrı bir müdür karakteri veya müdür yetkinliği gerekmez.

Eşik altı olasılığı **Tier/kademe farkına** göre düşer. Kabul edilen taslak denge: bir kademe eksik ≈ %80, iki kademe ≈ %40, üç kademe ≈ %15, dört veya daha fazla kademe ≈ %5. Örneğin 60/70 bir kademe farktır ve yaklaşık %80 başarı verir. Rakamlar oyun testleriyle ayarlanabilir; Tier eşiklerinin kesin değerleri de henüz FREEZE değildir. Gizli sorunda oyuncuya kesin yüzde yerine **yüksek / orta / düşük / çok düşük** gibi kaba şans aralıkları gösterilir; bunların sınırları ve tekrar deneme maliyeti açık karardır.

Bu akışta yetkinlik, hangi eyleme basılabileceğinden çok **neyin yanlış gittiğini bilme** ve bilinmeyen sorunu çözme şansıyla ilgilidir. Tekrar tekrar kör denemenin teşhis ve danışmanı değersizleştirmemesi denge testinde özellikle incelenmelidir.

### İnsan Yönetimi ve Personel

Bu IDEA'da müdür için ayrı kimlik veya yetkinlik puanı tanımlanmıyor. Bu, gelecekte ekip/personel sisteminin ayrı bir IDEA'da tasarlanmasını engellemez. Patronun **İnsan Yönetimi** yetkinliği yükseldikçe departmanlardaki kişi kaynaklı sorunların ortaya çıkma sıklığı belirgin biçimde azalır; etki aylık performans raporlarına yansır. **%50 azalma tavanı kullanıcı tarafından yetersiz bulundu**; kesin üst sınır henüz kararlaştırılmadı. Tur 7 denge önerisi olarak yüksek yetkinlikte yaklaşık %80–90 azaltma sınanabilir; bu sayı kullanıcı kararı değildir. Kişi kaynaklı bir sorun başarıyla “Düzelt”ildiğinde gereken personel işlemi çözümün içinde sayılır. İnsan Yönetimi'nin kendi alanındaki sorunları ve kişi kaynaklı sorunların hangi Tier'larda bulunacağı açık karardır.

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

Patron kök nedeni göremese bile departman kartı **açıklanamayan kayıp** sinyali verir (`GAME_OVERVIEW` §9). Sinyal, oyuncunun “Düzelt” denemesi veya danışman çağırması için dayanak sağlar; gerçek nedeni otomatik ifşa etmez. Başarısız deneme sonrasında harcanan para ve zaman ile sorunun sürdüğü açıkça gösterilmelidir. Kaybın büyüklüğünün ve kategori ipuçlarının hangi düzeyde gösterileceği açık karardır.

Fabrika battıktan sonra **aynı karakterle devam edilir** ve karakter borç yüküyle yeniden başlar. Borç, toparlanmanın mümkün olduğu ölçekte olmalıdır; **yaklaşık bir oyun yılında toparlanma** kullanıcı tarafından örnek ufuk olarak verildi, kesin süre değildir. Psikoloji, yeni başlayan bir karakterinkinden yaklaşık **%25 düşük** başlayabilir; bu da taslak örnektir, sabit denge değeri değildir. Düşüş kalıcı bir başarısızlık sarmalı yaratmamalıdır.

İflas **yetkinlik kaybettirmez** ve genel stat kazanımını hızlandırmaz. Bunun yerine karakter, kayba en çok yol açan alanda küçük, üst sınırı olan **“acı tecrübe” yetkinlik artışını karakter başına bir kez** alır. Böylece iflastan öğrenilirken kasıtlı tekrar iflasla bonus biriktirme engellenir. Kalıcı bedel borç ve harcanan zamandır; psikoloji düşüşü geçicidir. Kesin artış, borç miktarı ve psikolojinin toparlanma süresi denge kararlarıdır.

Değerlendirme raporu fabrikanın ömrünü, en çok kayıp yaratan departmanları, görülen/görülmeyen sorunları ve dikkate alınmayan uyarıları özetleyebilir (`GAME_OVERVIEW` §23). Rapor oyuncuya sonraki girişimde neyi öğrenmesi veya kime yetki vermesi gerektiğini anlatmalıdır. Aynı karakterle devam etme tercihi, `GAME_OVERVIEW` §5–6 ve §25'teki “ikinci kariyer / sonraki run” dilini netleştirmeyi gerektirir; bu IDEA aşamasında vizyon belgesi değiştirilmez.

### Eksik Yetkinliği Kapatma Yolları

Oyuncunun her işi yapmış olması zorunlu değildir.

Danışman bu IDEA'da mekanikleştirilen yoldur. Aşağıdakiler diğer olası yolları gösterir; bunların kuralları ayrı IDEA'larda tasarlanmadıkça onaylanmış mekanik sayılmaz:

- iyi ekip ve personel düzeni
- danışman
- ortak
- uzman çalışan
- dış kaynak
- eğitim / sonradan öğrenme

Oyunda önceden tanımlı **10–15 danışman kartı** bulunur. Her danışmanın mevcut patron yetkinliklerinden **2–5 alandaki puanı** vardır. Ay sonu raporu görüldükten sonra bu havuzdan rastgele **3 kart açılır**; oyuncu görünen profiller arasından seçim yapar. Listeyi sınırsız veya ücretsiz yeniden çekemez. **Dördüncü kartı açmak oyun içi para ister**; daha fazla kart açılabilip açılamayacağı ve bedeli açık karardır. Önceki taslaktaki **Satış** örneği, mevcut on yetkinlik arasında olmadığı için çıkarıldı; satış/talep tasarımı ayrı konu olarak ele alınabilir.

Kartın listelediği her alan **en az 25, en fazla 100** puandır. **Kartın toplam puanı ≤ listelenen alan sayısı × 60**. Örnek: beş alanlı kartın bütçesi en fazla 300'dür; iki alan 25'er puansa kalan üç alana toplam 250 puan dağıtılabilir (ör. **25 + 25 + 83 + 83 + 84 = 300**). İki alanlı kartta bütçe 120 olduğu için bir alanın 100 olması, diğer alanın en az 25 olma şartıyla mümkün değildir; iki alanlı üst sınır örneği **95 + 25 = 120**. 100 puanlık uzmanlık en az üç alanlı profilde mümkündür. Bu sonuçlar önerilen üç kuralın matematiksel sonucudur.

Danışmanların ilgili alan puanı **100'e ulaşabilir**; 90'lık sabit üst sınır yoktur. En güçlü profiller nadir ve pahalı olmalıdır; ücret özellikle yüksek yetkinlik puanlarında hızla artar. Böylece oyuncu kendi kariyerinde öğrenmediği en derin sorunu da danışman aracılığıyla kesin çözebilir, ama bunu sürekli yapmak ağır bir oyun içi maliyet doğurur. Kesin fiyat formülü, güçlü kartların havuzdaki sayısı ve küçük fabrika kârına göre maliyet dengesi açık karardır.

Danışman **belirli süreli sözleşmeyle** tutulur ve işe alındığı anda başlar; profilindeki bütün alanlar sözleşme boyunca aktiftir. **Aynı anda en fazla iki danışman** aktif olabilir. Örnek fiyatlama: o danışmanın bir aylık ücreti **A** ise 3 ay **2,75A**, 12 ay **10A**. Süreler ve çarpanlar bağlayıcılık/indirim fikrini gösteren taslak değerlerdir. Ödenen sözleşme ücreti, danışman erken bırakılırsa da iade edilmez. İki danışman aynı anda çalışsa bile ilgili alanda **etkin yetkinlik = max(patronun puanı, aktif danışmanların o alandaki puanları)**; puanlar birbirine eklenmez ve 100'ü aşmaz. Etkin değer sorunun eşiğine ulaşırsa kök neden görünür ve “Düzelt” kesin başarı verir. Danışman ayrılınca patronun kalıcı puanı artmış sayılmaz.

Danışman tutmak oyun içi para ve sözleşme yükü doğurur. Ay sonu kart açılışı dışında ek bekleme yoktur; danışman hemen göreve başlar. Sürekli danışman tutmanın kariyer deneyimini değersizleştirmemesi için sözleşme fiyatları ve gelir dengesi sınanmalıdır. Oyunun ürettiği bir sorunu çözmek için gerçek para harcamak zorunlu olamaz.

### Tasarım İlkesi

Mükemmel patron her şeyi kendisi yapan kişi değildir.

Neyi bildiğini bilir.
Neyi bilmediğini bilir.
Bilmediği işi kime bırakacağını bilir.

“Düzelt” sade bir operasyon eylemidir; fabrika döneminin stratejisi danışman seçimi, personel sonuçları, bütçe, zaman ve diğer yönetim kararlarında kurulmalıdır. Bu sistemlerin kapsamı ayrıca tasarlanacaktır.

## Notlar (Claude)

Tarihçe: Tur 1 inceleme [REV-001](../reviews/REV-001_claude_patron_yetkinlikleri.md) ve bu dosyanın Git geçmişi. Aşağıdakiler Tur 7 `Öneri (GPT)` metninin incelemesidir. `Karar Özeti`'ndeki kullanıcı yönlendirmeleri tartışmaya açılmamış; notlar bu yönlendirmelerin içindeki açıkları ve uygulanma biçimini hedefler.

### Aldığım Notlar

- Tur 6'nın kritik bulgusu kapandı: aynı anda en fazla iki danışman. Sözleşmelerin iade edilmemesiyle birlikte bu iki yuva gerçek bir kaynağa dönüştü. 12 aylık bir danışman bir yuvayı kilitler; başka alanda yeni bir sorun çıkarsa oyuncu ya bekler ya da ödediği ücreti yakarak yer açar. Anlamlı bir karar.
- Statların eşik altı şansı etkilememesi ve kaba şans aralıkları Karar Özeti'ne girdi. Tur 4'ten beri bekleyen iki çekirdek ilke kapandı.
- Aylık akış (ay sonu raporu → sinyal → kart → Düzelt) öneride açıkça yazıldı. "Danışman tutmadan da denenebilir" cümlesi kör denemeyi meşru bir seçenek olarak koruyor.
- `Eksik Yetkinliği Kapatma Yolları` listesi "onaylanmış mekanik sayılmaz" diye işaretlendi. FREEZE'in tanımsız sistemleri onaylama riski kapandı.
- Kart bütçesinin matematiği doğrulandı: iki alanlı kartta en yüksek puan 95'tir (95 + 25 = 120). Üç alanlı kartta 100 mümkündür (100 + 25 + 25 = 150 ≤ 180). Öneride yazılan sonuçlar doğru.

### Bulduğum Sakıncalar

- **Dört şans aralığı dört kademeyle birebir eşleşiyor (kritik):** Eşik altı olasılığı yalnızca dört değer alıyor (≈ %80 / %40 / %15 / %5). Arayüzdeki dört aralık da (yüksek / orta / düşük / çok düşük) bunlarla bire bir eşleşiyor. Oyuncu "orta" gördüğünde sorunun tam iki kademe yukarıda olduğunu anlar. Yani kaba aralık, kesin yüzde kadar gizli Tier'ı ele verir ve Karar Özeti'ndeki "gizli Tier'ı ele vermemeli" gerekçesi boşa çıkar. Öneri: gizli sorunlarda en fazla iki geniş aralık gösterilsin ("makul risk" = %80–40, "yüksek risk" = %15–5), ya da yalnızca "belirsiz" yazsın. Kesin başarı ve görünür sorunlar olduğu gibi kalabilir.
- **Beş alanlı kartta iki tane 100 mümkün:** Bütçe alan sayısıyla büyüdüğü için 100 + 100 + 50 + 25 + 25 = 300 geçerli bir kart. Tur 6'daki "süper kart" riski azaldı ama kapanmadı. Ayrıca bütçe geniş kartları derin kartlardan da güçlü kılıyor: 25'lik dolgu alanlar bütçe açıyor, bu yüzden beş alanlı kart üç alanlı karttan hem daha geniş hem daha derin olabiliyor. Bu da "derin uzman ile geniş genelci arasında seçim" gerekçesini zayıflatıyor. Öneri, mevcut kurallara tek ekleme: **bir kartta en fazla bir alan 90 veya üstü olabilir.**
- **İki geniş kartla on alanın tamamı kapsanabilir:** İki yuva ve beş alanlı kartlarla, alanları çakışmayan iki kart on departmanın tamamını en az 25, çoğunu 50 ve üstünde kapsar. Kariyer yetkinliğinin 50'nin altındaki kısmı o süre boyunca etkisiz kalır. Öneri (içerik kuralı): havuzda alanları birleştiğinde on alanın tamamını kapsayan iki kart bulunmasın. Denge testinde "iki kartla kapsanabilen en geniş alan kümesi" ölçülsün.
- **Danışmanın İnsan Yönetimi puanı sıklık etkisine sayılıyor mu? (kritik):** Öneride sıklık etkisi "patronun İnsan Yönetimi yetkinliği" ile tanımlı, ama etkin yetkinlik kuralı `max(patron, danışman)`. Bu kural sıklık etkisine de uygulanırsa, İnsan Yönetimi 100 olan tek bir danışman tüm departmanlarda kişi kaynaklı sorunları %80–90 azaltır. Bu, iki yuvadan birini neredeyse zorunlu hale getiren baskın bir seçim olur. Öneri: sıklık etkisi yalnızca patronun **kalıcı** İnsan Yönetimi puanıyla hesaplansın. Danışmanın İnsan Yönetimi puanı yalnızca İnsan Yönetimi alanındaki sorunların çözümüne katılsın.
- **Güçlü İnsan Yönetimi etkisi alan yetkinliklerini gölgeleyebilir:** %80–90 azaltma ile kişi kaynaklı sorunlar en derin kademelerde yoğunlaşırsa, yüksek İnsan Yönetimi, alan yetkinliklerinde 90–100'e çıkma ihtiyacının büyük kısmını ortadan kaldırır. Güçlü etki kullanıcının tercihi. Bu tercihin güvenli kalması için kişi kaynaklı sorunlar her kademeye dağılmalı ve toplam sorunların sınırlı bir payı olmalı (ör. %30–40). Bu oran içerik yazımının kuralıdır.

### Kafama Yatmayanlar

- **İnsan Yönetimi'nin kendi alan sorunları hâlâ tanımsız:** Diğer dokuz alanın Tier sorunları var; İnsan Yönetimi'nin yalnızca yatay bir etkisi mi var, yoksa bir İK departmanı ve kendi sorunları da mı? Danışmanın İnsan Yönetimi puanının neye yarayacağı bu cevaba bağlı.
- **Açıklanamayan kayıpta "Düzelt"in hedefi:** Tur 3'ten beri açık. Kaba aralık kuralı yazıldıktan sonra artık zorunlu: şans hangi gizli sorunun eşiğine göre hesaplanıyor? Öneri: en sığ gizli sorun hedeflensin.
- **Gerçek para ve dördüncü kart:** Dördüncü kart oyun içi para istiyor. İleride gerçek parayla satılırsa, ücretli yeniden çekme mekanizmasına dönüşür ve GAME_OVERVIEW §26 ilkesiyle çelişir. FREEZE metninde "danışman kartları ve ek kart gerçek parayla satılmaz" diye açıkça yazılması öneriliyor.
- **Terimler:** "Tier" hâlâ hem patron hem sorun için kullanılıyor. FREEZE metni bu terimlerle yazılacağı için artık seçilmeli. Öneri: patron için "Görüş Seviyesi", sorun için "Sorun Derinliği" (REV-001 M2).

### Açık Sorular

Tur 8'den önce kullanıcının karar vermesi önerilen öncelikli üç konu:

1. Gizli sorunlarda şans kaç aralıkla gösterilsin? Dört aralık gizli kademeyi birebir ele veriyor. Claude önerisi: iki geniş aralık ya da yalnızca "belirsiz".
2. İnsan Yönetimi'nin sıklık etkisi yalnızca patronun kalıcı puanıyla mı hesaplansın (Claude önerisi), yoksa danışman puanı da sayılsın mı? Kişi kaynaklı sorunların toplam içindeki payı sınırlansın mı?
3. Kart bütçesine "bir kartta en fazla bir alan 90 veya üstü" kuralı eklensin mi? Havuzda iki kartla on alanın tamamını kapsayan kombinasyon olmasın mı?

Diğerleri:
- Sözleşmedeki kart havuzdan çıksın mı?
- Açıklanamayan kayıp üzerinden "Düzelt" en sığ gizli sorunu mu hedeflesin?
- Terimler "Görüş Seviyesi" ve "Sorun Derinliği" olsun mu?
- Danışman kartları ve dördüncü kart gerçek parayla satılmasın mı?

## Açık Kararlar

### FREEZE öncesi kapanması önerilenler (ilke düzeyinde)

- Kaba başarı aralıklarının UI eşikleri ve oyuncuya yeterince anlaşılır geri bildirim vermesi. Claude notu: dört aralık dört kademe farkıyla birebir eşleşiyor ve gizli Tier'ı ele veriyor. Claude önerisi: gizli sorunlarda en fazla iki geniş aralık ("makul risk" %80–40, "yüksek risk" %15–5) ya da yalnızca "belirsiz" (açık).
- Kart toplam puan bütçesinin 2–5 alanın her birindeki en az 25 kuralıyla tutarlılığı ve oyuncunun bunu nasıl göreceği; iki alanlı kartta 100 puan çıkmaması özellikle doğrulanmalı. Claude doğrulaması: iki alanlı kartta en yüksek puan 95; ancak beş alanlı kartta iki tane 100 mümkün (100 + 100 + 50 + 25 + 25). Claude önerisi: bir kartta en fazla bir alan 90 veya üstü; havuzda iki kartla on alanın tamamı kapsanamaz (açık).
- Sözleşmedeki kartın havuzdan çıkıp çıkmadığı; dördüncü kartın fiyatı ve beşinci kartın açılıp açılamayacağı. Claude önerisi: aktif kart havuzdan çıkar (açık).
- İnsan Yönetimi'nin kişi kaynaklı sorunları azaltma üst sınırı (%50 kullanıcıya düşük geldi; %80–90 yalnızca Tur 7 denge önerisi); kendi alanındaki sorunları ve kaynak türü etiketleri. Danışmanın İnsan Yönetimi puanının sıklık etkisine sayılıp sayılmadığı. Claude önerisi: sıklık etkisi yalnızca patronun kalıcı puanıyla hesaplanır; kişi kaynaklı sorunlar her kademeye dağılır ve toplam sorunların sınırlı bir payıdır (ör. %30–40) (açık).
- Açıklanamayan kayıp sinyali üzerinden basılan “Düzelt”in hangi gizli sorunu hedeflediği. Claude önerisi: en sığ gizli sorun; şans o sorunun eşiğine göre hesaplanır (açık).
- `Eksik Yetkinliği Kapatma Yolları`ndaki ekip, ortak, uzman çalışan, dış kaynak ve eğitim maddelerinin FREEZE'de "ileride tasarlanacak" olarak mı yer alacağı; bunların ayrıştırılmasının bu IDEA'da mı ayrı IDEA'da mı yapılacağı. Claude notu: Tur 7 önerisi bunları "onaylanmış mekanik sayılmaz" diye işaretledi; kullanıcı onayıyla kapanabilir.
- Gerçek paranın danışmanlık sistemindeki rolü (yalnızca kolaylık mı, hiç mi). Claude önerisi: danışman kartları ve ek kart gerçek parayla satılmaz (açık).
- Patron görüş seviyesi ile sorun derinliği için ayrı terimler. Claude önerisi: "Görüş Seviyesi" ve "Sorun Derinliği" (açık).

### Denge parametreleri ve testle kesinleşecekler

- “Düzelt”in para/zaman maliyetleri.
- Kabul edilen taslak kademe eğrisinin (≈ %80 / %40 / %15 / %5) oyun testlerinde ayarlanması; Tier içinde farklı puanların aynı şansa sahip olmasının uygunluğu.
- Kör denemeyi baskın strateji yapmamak için tekrar denemede aynı mı, artan mı maliyet ve/veya bekleme süresi uygulanacağı.
- Kart havuzunun kesin büyüklüğü (10–15), her ayki 3 kartın seçim yöntemi, güçlü kartların nadirliği; havuzun ezberlenmesine karşı puan varyasyonu veya büyüyen havuz.
- Kesin fiyat formülü ve 1/3/12 ay için A/2,75A/10A örneklerinin kesinleşmesi.
- Uzun süreli çok alanlı danışmanların baskın strateji olup olmadığı; yıllık danışman maliyetinin küçük fabrika net kârına oranı ve kariyer yetkinliğinin değeri.
- İki aktif danışman ve alan sayısı × 60 bütçesinin dengede kariyer yatırımını koruyup korumadığı; iki kartla kapsanabilen en geniş alan kümesi.
- İnsan Yönetimi'nin kişi kaynaklı sorun sıklığını ne kadar azalttığı ve aylık performans raporlarına nasıl yansıdığı.
- Oyun içi açıklanamayan kayıp sinyalinin hesap tanımı ve netlik eşikleri; fabrika başarısızlık raporunun ayrıntı düzeyi ve ara dönem (yıllık) özet olup olmayacağı.
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
- Ay sonunda 10–15 sabit profilden rastgele 3 danışman kartı açılır, dördüncü kart oyun içi para ister; çünkü oyuncu rapordan sonra seçim yapmalı ve sınırsız ücretsiz yeniden çekme olmamalı.
- Her danışman 2–5 alandaki görünür puanıyla fiyatlanır; çünkü farklı bilgi açıkları ve bütçeler için seçenekler olmalı.
- Danışman sözleşmesi süreli ve bütün profil alanları boyunca aktiftir; çünkü oyuncu tek alanlık kısa görev yerine kapsamlı bir danışman seçip süreye bağlanmak istiyor.
- Etkin yetkinlik patron ve aktif danışman puanlarının en yükseğidir, toplama değildir; çünkü çok danışman tutmak 100 üstü puan veya sınırsız güç üretmemeli.
- Aynı anda en fazla iki danışman aktiftir; çünkü tüm alanları sürekli dış destekle kapatmak kariyer yetkinliğinin değerini azaltır.
- Kartta 2–5 alan bulunur, her biri 25–100 puandır ve toplamları alan sayısı × 60'ı aşmaz; çünkü güçlü uzman ile geniş profilli danışman arasında seçim olmalı.
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
- Ayrı müdür/ekip mekaniği IDEA-001'in kapsamı dışındadır ve daha sonra tasarlanabilir; çünkü bugünkü basit “Düzelt” akışı gelecekte ekip kararlarını kapatmamalı.
