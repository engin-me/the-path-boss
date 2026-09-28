# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: DRAFT — Tur 4 GPT sentezi hazır, Claude incelemesi bekleniyor
Tur: 4
Son güncelleme: 2026-09-28
Kaynak: Kullanıcının sağladığı ilk öneri Codex tarafından dosyaya işlendi.
Tur 1, Tur 2 ve Tur 3 Claude incelemeleri: tamamlandı. Kullanıcının yeni yönlendirmeleri Tur 4 önerisine işlendi; `Notlar (Claude)` hâlâ Tur 3 incelemesidir.
Sıradaki adım: Claude, Tur 4 önerisini inceleyip `Notlar (Claude)` bölümünü günceller.

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

Tarihçe: Tur 1 inceleme [REV-001](../reviews/REV-001_claude_patron_yetkinlikleri.md) ve bu dosyanın Git geçmişi. Aşağıdakiler Tur 3 `Öneri (GPT)` metninin incelemesidir. Kullanıcının Tur 3 yönlendirmeleri (`Karar Özeti`) tartışmaya açılmamış; notlar bu yönlendirmelerin içindeki açıkları hedefler.

### Aldığım Notlar

- Tek "Düzelt" eylemi, altı müdahale ailesinden çok daha sade. "Dünya karmaşık, ekran değil" (§27) ilkesine uyuyor ve 10 × 5 içerik yükünü tamamen kaldırıyor.
- Model tutarlı bir çekirdeğe sahip: **bilgi = belirsizliğin ortadan kalkması.** Eşiğe ulaşan patron kesin çözer; ulaşamayan risk alır. Bilgi açığı çözümü imkânsız değil riskli kılıyor. Bu, "cezalandırma değil yönetim açığı" (§27) ilkesiyle uyumlu.
- Satın Alma örneği ("kendi başına teşhis edemez; sinyal görünür kalır") ve danışman bedelinin "harcatır" olarak kesinleşmesi Tur 2 notlarına uygun işlenmiş.
- Başarısız denemede harcanan kaynağın ve sorunun sürdüğünün açıkça gösterilmesi, "oyun beni sebepsiz cezalandırıyor" hissini önler.

### Bulduğum Sakıncalar

- **Danışman işlevsizleşiyor (kritik):** Düzelt'in başarısı yalnızca patron yetkinliğine bağlıysa danışman raporu hiçbir mekanik sonuç doğurmaz. Oyuncu kök nedeni bilmeden de aynı ihtimalle Düzelt'e basabilir. Danışman parası ve beklemesi boşa gider, kimse çağırmaz. Öneri: danışman teşhisi o sorun için patronu "eşiğe ulaşmış" sayar ve başarı kesinleşir. Böylece seçim temiz ve dengelenebilir hale gelir: danışman ücreti ve bekleme mi, yoksa kör denemelerin beklenen ek maliyeti (≈ 1/p) mi?
- **Eşik altı eğrisi yetkinliği değersizleştirebilir (kritik):** 60/70 ≈ %80 ise ortalama maliyet yalnızca ≈ 1,25 katına çıkar. Eğri yumuşak kalırsa 30 yetkinlikli patron her sorunu birkaç denemeyle çözer; kariyer yatırımı ve görünürlük sistemi anlamını yitirir. Öneri: ihtimal puan farkına değil **kademe farkına** göre sert düşsün. Örnek başlangıç: 1 kademe altı ≈ %80, 2 kademe ≈ %40, 3 kademe ≈ %15, 4+ kademe ≈ %5. Tekrar deneme bu eğriyle doğal olarak pahalılaşır; ek bir ceza kuralına gerek kalmaz.
- **Kişi kaynaklı sorunda "Düzelt" ne anlama geliyor?** T4–T5 örnekleri (müdür kayırması, komisyon) bir kişiden kaynaklanıyor. Düzelt para ve zamanla çözüyorsa müdür yerinde kalır, kaynak sürer ve sorun yeniden doğmalıdır. Aksi halde yolsuzluk parayla "kapatılmış" olur. Ya Düzelt bu tür sorunlarda soyut bir personel sonucunu da içermeli (müdür değişir, yeni müdür alışma maliyeti otomatik gelir), ya da müdürü kovmak ayrı eylem olmalı. Bu karar Tur 3'te açık bırakılmış, ama kişi kaynaklı sorunların anlamı buna bağlı.
- **Müdür yetkinliği Düzelt'e katılıyor mu?** Tanımsız. Katılıyorsa (ör. patron ile müdürün yüksek olanı), iyi müdür patron yetkinliğinin yerini tümüyle tutar ve REV-001 C2 geri döner. Öneri: müdürün yetkinliği sayılsın, ancak kaynağı müdürün kendisi olan sorunlarda sayılmasın. Bu, 2x2 matrisi mekanik olarak işletir.
- **Statlar yetkinliği atlatabilir:** `Statların Rolü` bölümü hâlâ "bazı görevlerdeki başarı oranını" etkiliyor diyor. Bu, eşik altı Düzelt'e uygulanırsa yüksek Zeka bilgi açığını kapatır ve "Zeka T4 görmez" ilkesi delinir. Öneri: statlar yalnızca Düzelt'in süresini ve maliyetini etkilesin, eşik altı ihtimali etkilemesin.
- **İflas sonrası yetkinlik kaybı ölüm sarmalı riski taşıyor:** §20'de "kovulma → psikoloji → performans → kovulma" sarmalı zaten bir kez yaşanmış. İflas → yetkinlik kaybı → daha zayıf ikinci fabrika → ikinci iflas aynı yapıda. Ayrıca yetkinlik kaybı "başarısızlık öğretmeli" ilkesiyle çelişiyor: oyuncu tam da batırdığı alanda geriler. Öneri: kalıcı bedel para, borç, zaman veya itibardan gelsin; psikoloji ve stat kaybı geçici olsun. Yetkinlik kaybı yerine "acı tecrübe" verilsin: en çok kayıp yaratan departmanda küçük bir yetkinlik artışı.
- **Fabrika dönemi "Düzelt'e tıkla" döngüsüne inme riski:** Tek eylemle sorun çözümü sadeleşti; bu yüzden fabrika dönemindeki stratejik derinlik başka sistemlerden gelmek zorunda (işe alma, ortaklık, satın alma kararları, bütçe ve zaman önceliklendirme). Aksi halde oyun genel bir tycoon'a kayar (CLAUDE.md guardrail). Bu bağımlılık IDEA'da yazılı olmalı.

### Kafama Yatmayanlar

- **Açıklanamayan kayıpta Düzelt neyi hedefliyor?** Sinyal nedeni göstermiyor. Aynı departmanda birden fazla gizli sorun varsa, sinyal üzerinden basılan Düzelt hangisine uygulanır ve ihtimal hangi eşiğe göre hesaplanır? Öneri: önce en sığ gizli sorunu hedeflesin, ihtimal o sorunun eşiğine göre hesaplansın. Bu, eşzamanlı sorun sayısı kararına bağlı.
- **İhtimalin gösterimi bilgi modeliyle uyumlu olmalı:** Kesin yüzde gösterilirse oyuncu kök nedeni bilmeden sorunun derinliğini çıkarabilir (%80 görürse "1 kademe yukarıda" anlar). Bu, görünürlük sistemini arka kapıdan açar. Öneri: yalnızca kaba bir aralık gösterilsin (yüksek / orta / düşük / çok düşük).
- **GAME_OVERVIEW ile tutarsızlık:** "Aynı karakterle devam" yönlendirmesi, GAME_OVERVIEW §5–6 ve §25'teki "ikinci kariyer / ilk run / sonraki run" diliyle çelişiyor. Bu bir FREEZE çatışması değil. Ancak karar dondurulursa, proje kuralı gereği GAME_OVERVIEW güncellenmeli.
- **Oyunun bitişi tanımsız:** Karakter iflastan sonra devam ediyorsa oyunun süresi ne olacak (açılıştaki "10 yıl sonra" ufku mu)? İflastan sonra ikinci bir fabrika için kalan zaman, sermaye ve borç durumu da belli değil. Replay döngüsü ("bu sefer daha iyi hazırlanacağım") aynı run içinde mi, yeni run'da mı yaşanacak?
- `Statların Rolü` ve "Toplam teorik maksimum: 1000" satırları Tur 3 modeline göre güncellenmemiş (REV-001 M1).

### Açık Sorular

Tur 4'ten önce kullanıcının karar vermesi önerilen öncelikli üç konu:

1. Danışman teşhisi Düzelt'i kesinleştirir mi (Claude önerisi), yoksa başka ne kazandırır?
2. Eşik altı ihtimal kademe farkına göre sert mi düşsün (Claude önerisi), yoksa puana göre yumuşak mı?
3. İflas bedeli yetkinlik kaybı mı, yoksa para/borç/zaman ile geçici psikoloji ve stat kaybı mı? "Acı tecrübe" önerisi kabul edilir mi?

Diğerleri:
- Müdür yetkinliği Düzelt ihtimaline katılır mı; müdürün kaynak olduğu sorunlarda ne olur?
- Kişi kaynaklı sorunda Düzelt müdür değişimini de kapsar mı?
- Başarı ihtimali oyuncuya yüzde olarak mı, kaba aralık olarak mı gösterilir?
- Oyunun süresi ve iflastan sonraki sermaye/borç durumu ne olacak?

## Açık Kararlar

- “Düzelt”in para/zaman maliyetleri ve ihtimalin oyuncuya nasıl gösterileceği; kesin yüzde gizli Tier'ı ele verebilir. Kaba aralık gösterimi Claude önerisidir (açık).
- Kabul edilen taslak kademe eğrisinin (≈ %80 / %40 / %15 / %5) oyun testlerinde ayarlanması; Tier içinde farklı puanların aynı şansa sahip olmasının uygunluğu.
- Kör denemeyi baskın strateji yapmamak için tekrar denemede aynı mı, artan mı maliyet ve/veya bekleme süresi uygulanacağı.
- Statların eşik altı “Düzelt” olasılığını etkileyip etkilemeyeceği; Tur 4 önerisi yalnızca süre ve maliyeti etkilemeleri.
- Danışman katkılarının kesin fiyat formülü, görev süresi, eşzamanlı çalışma ve üst üste eklenme kuralı; katkının geçerli olduğu alan dışındaki bilginin kapsamı.
- Danışmanın örnek profilindeki Satış'ın yeni yetkinlik mi yoksa mevcut bir alanın karşılığı mı olduğu.
- Müdür yetkinliğinin “Düzelt” ihtimaline katılıp katılmayacağı; müdürün kendisinin kaynak olduğu sorunlarda istisna.
- Açıklanamayan kayıp sinyali üzerinden basılan “Düzelt”in hangi gizli sorunu hedeflediği.
- Danışman seviyesi ve bulunabilirliği.
- Müdür raporlarının çarpıtılıp çarpıtılamayacağı ve bunun hangi yetkinlikle fark edileceği.
- Gerçek paranın danışmanlık sistemindeki rolü (yalnızca kolaylık mı, hiç mi).
- Oyun içi açıklanamayan kayıp sinyalinin hesap tanımı ve netlik eşikleri; fabrika başarısızlık raporunun ayrıntı düzeyi ve ara dönem (yıllık) özet olup olmayacağı.
- Müdürü kovma, yenisini alma ve alışma sürecinin basit bir ayrı eylem mi yoksa daha ayrıntılı bir sistem mi olacağı; kişi kaynaklı sorunlarda “Düzelt”in bu personel sonucunu kapsayıp kapsamadığı.
- Sorun ertelendiğinde kaybın büyüme hızı.
- İflas borcunun miktarı ve yaklaşık bir oyun yılında toparlanmanın denge hedefi olup olmayacağı; psikoloji düşüşünün süresi ve toparlanma hızı.
- Stat kazanımını hızlandırma veya kazanım başına +1 önerisinden hangisinin, hangi sınırlarla uygulanacağı; önceki yetkinlik kaybı isteğinin korunup korunmayacağı ve “acı tecrübe” önerisi.
- Oyunun süresi ve bitiş koşulu; iflastan sonraki sermaye/borç durumu; karar dondurulursa GAME_OVERVIEW'daki "run" dilinin güncellenmesi.
- Fabrika dönemindeki stratejik derinliğin “Düzelt” dışında hangi sistemlerden geleceği.
- Ortak, uzman çalışan, dış kaynak ve eğitim yollarının ayrıştırılması: bu IDEA'da mı, ayrı IDEA'da mı?
- Patron görüş seviyesi ile sorun derinliği için ayrı terimler.
- Yetkinlik Tier eşikleri, kazanılma hızı, düşüşü ve beşinci yıl hedefi.
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
