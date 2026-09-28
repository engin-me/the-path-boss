# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: DRAFT — Tur 5 Claude incelemesi tamamlandı
Tur: 5
Son güncelleme: 2026-09-28
Kaynak: Kullanıcının sağladığı ilk öneri Codex tarafından dosyaya işlendi.
Tur 1–5 Claude incelemeleri: tamamlandı. Kullanıcının yeni yönlendirmeleri Tur 5 önerisine işlendi; `Notlar (Claude)` Tur 5 incelemesidir.
Sıradaki adım: Kullanıcı, `Notlar (Claude)` → `Açık Sorular` altındaki öncelikli üç kararı seçer; ardından Codex Tur 6 sentezini yapar.

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

Tarihçe: Tur 1 inceleme [REV-001](../reviews/REV-001_claude_patron_yetkinlikleri.md) ve bu dosyanın Git geçmişi. Aşağıdakiler Tur 5 `Öneri (GPT)` metninin incelemesidir. `Karar Özeti`'ndeki kullanıcı yönlendirmeleri tartışmaya açılmamış; notlar bu yönlendirmelerin içindeki açıkları ve uygulanma biçimini hedefler.

### Aldığım Notlar

- `max` kuralı üst üste ekleme ve 100'ü aşma sorununu tek satırda kapattı; anlaşılması da toplama kuralından kolay.
- "Acı tecrübe"nin karakter başına bir kez verilmesi kasıtlı iflas istismarını kapattı. Yetkinlik kaybının kaldırılması, Tur 3'teki ölüm sarmalı riskini de azalttı.
- Kişi kaynaklı sorunların "Düzelt" içinde personel işlemiyle kapanması, Tur 3–4'teki "yolsuzluk parayla kapatılıyor" açığını çözdü. T4–T5 örneklerinin "müdür" yerine süreç ve çıkar çatışması diliyle yeniden yazılması, "her departmanda yolsuzluk" riskini (REV-001 I3) de azalttı.
- Satış'ın çıkarılması, §10 tutarsızlığının öneride açıkça yazılması ve Tasarım İlkesi paragrafının yerinin düzeltilmesi doğru.
- Kör deneme ile danışman arasında sağlıklı bir seçim alanı oluştu. Bir kademe açıkta kör deneme (≈ 1,25 kat beklenen maliyet) çoğu zaman danışmandan ucuz. İki veya daha fazla kademede ya da aynı alanda çok sayıda sorun varken danışman kârlı. Bu ayrım korunmalı.

### Bulduğum Sakıncalar

- **Uzun sözleşmeli, çok alanlı danışman REV-001 C2'yi geri getiriyor (kritik):** `max` kuralında danışman patrondan güçlüyse patronun puanı hiç önemli olmuyor. 12 aylık sözleşme indirimi (10A) ve profildeki tüm alanların aktif olması birleşince baskın strateji şu: zayıf alanları kapsayan 1–2 geniş profilli danışmanı yıllık sözleşmeyle sürekli tutmak. Kariyer yetkinliğinin tek değeri, danışman gerektirmeyen alanlardaki maliyet tasarrufu olarak kalıyor. Kullanıcı kararlarını bozmadan önerilen frenler:
  - Danışman puanlarının üst sınırı **90** olsun. T5 kesinliği (100) yalnızca kariyerle kazanılsın. Bu, REV-001 C4'teki "T4–T5 arası 10 puan" sorununu da anlamlı hale getirir: en derin sorunları kesin çözebilen tek kişi o işi yıllarca yapmış patrondur.
  - Fiyat, profilin en yüksek puanıyla doğrusal değil hızlı artsın (ör. 70'lik danışman A ise 90'lık yaklaşık 3A). 10 aday içinde 90'lık puan nadir olsun.
  - Denge testi ölçütü yazılsın: "zayıf bir alanı T3'e taşıyan yıllık danışman maliyeti, tipik küçük fabrikanın yıllık net kârının belirgin bir kısmı olmalı."
- **Danışman aramasında yeniden çekme istismarı:** 10 aday ücretsiz ve sınırsız yenilenebiliyorsa oyuncu ideal 5 alanlı profili bulana kadar aramayı tekrarlar. Arama ya bir bedele ya da bekleme süresine bağlanmalı (ör. ayda bir yeni liste).
- **Danışman frenleri zayıfladı:** Tur 3'te "para, yönetim zamanı ve bekleme harcatır" diye kesinleşen bedel, Tur 5'te yalnızca paraya indi; zaman ve bekleme "değerlendirilecek" durumunda. Geriye tek fren olarak para kalıyor; fabrika kâr ettikçe bu fren de zayıflıyor. En azından göreve başlama beklemesi korunmalı. Böylece acil bir sorunda danışman anında çözüm olmaz, kariyer yetkinliği hazır bilgi olarak değer kazanır.
- **Erken fesih tanımsız:** 12 aylık indirimli sözleşme erken bozulabiliyorsa bağlayıcılık fikri anlamını yitirir; bozulamıyorsa oyuncu işe yaramayan bir danışmana 10A ödemiş olur. Kural yazılmalı (ör. fesih mümkün, kalan tutarın bir kısmı ödenir).
- **İnsan Yönetimi mekaniksiz kalma riski:** Müdür kaldırılınca İnsan Yönetimi'nin etkisi "aylık raporlara yansır" düzeyinde belirsiz kaldı. Diğer dokuz yetkinlik bir departmanın sorunlarını teşhis ederken İnsan Yönetimi'nin ne yaptığı tanımsız. Oyuncu bu alana yatırım yapmaz. Somut öneri: İnsan Yönetimi tüm departmanlarda kişi kaynaklı sorunların **ortaya çıkma sıklığını** azaltsın. Böylece mevcut "Düzelt" kuralına dokunmadan yatay bir değer kazanır.

### Kafama Yatmayanlar

- **Müdür katmanının kalkması çekirdek kimliğe dokunuyor:** CLAUDE.md'nin korunan kimlik maddesi "a great boss … knows who should handle it" ve GAME_OVERVIEW §10 (2x2 matris) ile §22 ("iyi ekip patronun zamanını büyümeye ayırır") kalıcı ekip üzerine kurulu. Tur 5'te "kime bırakacağını bilmek" yalnızca "hangi danışmanı tutacağını bilmek"e indi. Öneri: IDEA-001 "müdür yetkinliği yoktur" diye dondurulmasın; "ekip/müdür katmanı IDEA-001'in kapsamı dışındadır, ayrı IDEA'da tasarlanacaktır" diye dondurulsun. Böylece bugünkü sadeleştirme korunur, gelecekteki ekip tasarımının yolu kapanmaz.
- `Eksik Yetkinliği Kapatma Yolları` listesindeki "iyi ekip ve personel düzeni", ortak, uzman çalışan, dış kaynak ve eğitim maddelerinin hâlâ hiçbir mekaniği yok. Yalnızca danışman tanımlı. Liste ya "ileride tasarlanacak" diye işaretlensin ya da FREEZE kapsamından çıkarılsın; aksi halde FREEZE tanımsız sistemleri onaylamış olur.
- `Statların Rolü` bölümündeki "eşik altı ihtimali etkilemesin" önerisi hâlâ kullanıcı kararı bekliyor. `max` kuralıyla birlikte FREEZE öncesinde kapanması gereken son çekirdek kurallardan biri.
- Başarı ihtimalinin gösterimi (yüzde mi, kaba aralık mı) ve oyunun süresi/bitişi hâlâ açık. İkisi de FREEZE öncesinde en azından ilke düzeyinde kapanmalı.

### Açık Sorular

Tur 6'dan önce kullanıcının karar vermesi önerilen öncelikli üç konu:

1. Danışman puanlarına 90 üst sınırı konsun mu, yani T5 kesinliği yalnızca kariyerle mi kazanılsın (Claude önerisi)? Fiyat en yüksek puanla hızla artsın mı?
2. Danışman frenlerinden hangileri olsun: arama yenileme sınırı, göreve başlama beklemesi, erken fesih kuralı?
3. Müdür/ekip katmanı IDEA-001'de "yok" diye mi dondurulsun, yoksa "kapsam dışı, ayrı IDEA" diye mi (Claude önerisi)? İnsan Yönetimi kişi kaynaklı sorunların sıklığını mı azaltsın?

Diğerleri:
- Statlar eşik altı ihtimali etkilemesin önerisi onaylanıyor mu?
- Başarı ihtimali yüzde olarak mı, kaba aralık olarak mı gösterilecek?
- Oyunun süresi ve bitiş koşulu ne olacak?

## Açık Kararlar

- “Düzelt”in para/zaman maliyetleri ve ihtimalin oyuncuya nasıl gösterileceği; kesin yüzde gizli Tier'ı ele verebilir. Kaba aralık gösterimi Claude önerisidir (açık).
- Kabul edilen taslak kademe eğrisinin (≈ %80 / %40 / %15 / %5) oyun testlerinde ayarlanması; Tier içinde farklı puanların aynı şansa sahip olmasının uygunluğu.
- Kör denemeyi baskın strateji yapmamak için tekrar denemede aynı mı, artan mı maliyet ve/veya bekleme süresi uygulanacağı.
- Statların eşik altı “Düzelt” olasılığını etkileyip etkilemeyeceği; Tur 4 önerisi yalnızca süre ve maliyeti etkilemeleri.
- Danışman adaylarının nasıl yenilendiği, aynı anda tutulabilecek sayı ve fiyat formülü; 1/3/12 ay ile A/2,75A/10A örneklerinin kesinleşmesi. Claude önerisi: aday listesi ücretsiz sınırsız yenilenemez (bedel veya bekleme); fiyat en yüksek puanla hızla artar (açık).
- Uzun süreli çok alanlı danışmanların baskın strateji olup olmayacağı ve fiyat/erişilebilirlik dengesi. Claude önerisi: danışman puanı en fazla 90, T5 kesinliği yalnızca kariyerle; denge ölçütü yıllık danışman maliyetinin fabrika net kârına oranı (açık).
- Danışmanın göreve başlama beklemesi ve yönetim zamanı maliyeti; erken fesih kuralı. Claude önerisi: en azından göreve başlama beklemesi korunur (açık).
- Satış/talep konusunun ayrı IDEA olarak ele alınması ve mevcut on yetkinlik listesine etkisi.
- İnsan Yönetimi yetkinliğinin aylık performans raporlarına nasıl yansıdığı; `GAME_OVERVIEW` §10'daki müdür modelinin yeni yönle uyumlandırılması. Claude önerisi: İnsan Yönetimi kişi kaynaklı sorunların ortaya çıkma sıklığını azaltır; ekip/müdür katmanı "kapsam dışı, ayrı IDEA" olarak işaretlenir (açık).
- `Eksik Yetkinliği Kapatma Yolları`ndaki ekip, ortak, uzman çalışan, dış kaynak ve eğitim maddelerinin FREEZE kapsamında mı, "ileride tasarlanacak" olarak mı yer alacağı.
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
