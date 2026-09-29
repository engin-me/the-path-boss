# IDEA-009 — Kariyer, Üniversite ve Yetkinlik Yolları

## Durum/Tur

Durum: TUR 2 SENTEZİ — kullanıcı Claude önerilerini kabul etti; FRZ-007 v2 ayrı taslaktır. Bu dosya FREEZE değildir.
Tur: 2
Tarih: 2026-09-29
Bağımlılık: [FRZ-007](../freeze/FRZ-007_calisanlik_kariyeri.md) ve [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md). Kullanıcı kurs ve diploma tavanı değişikliğini onayladı; [FRZ-007 v2 taslağı](../freeze/FRZ-007_v2_calisanlik_kariyeri.md) hazırlandı. Mevcut FRZ-007, v2 sonuçlandırılana kadar CURRENT kalır.

## Öneri (GPT)

### Tur 2: İş, diploma ve yetkinlik

Yetkinlik puanı iş, görev ve ilgili oyun deneyiminden gelir. Kurs yetkinlik vermez; stat ve sertifika verir. Diploma puan kazandırmaz, yalnız ilgili alanın kalıcı öğrenme tavanını kaldırır. Diplomasız karakterler de mavi yaka ve köprü işleriyle bütün alanlarda öğrenebilir. Takım Lideri Planlama ve İnsan Yönetimi geliştirmeye devam eder; tavanı aşan puan birikmez. Sertifika veya eşdeğer deneyim bu tavanı kaldıramaz. Böylece FRZ-007'deki her alana kalıcı öğrenme yolu korunurken diploma derin uzmanlık için değer taşır.

| Yetkinlik | Diplomasız tavan | Tavanı kaldıran bölüm | Öğrenme yolu örnekleri |
| --- | ---: | --- | --- |
| Üretim | 89 (T3) | Mühendislik | Torna, taşlama |
| Planlama | 69 (T2) | Mühendislik veya İşletme / İktisat | Takım Lideri, planlama işi/oyunu |
| Depo & Sevkiyat | 89 (T3) | Henüz bölüm belirlenmedi | Örümcek, depo işi/oyunu |
| Bakım | 89 (T3) | Mühendislik | Setup, bakım işi/oyunu |
| Kalite | 89 (T3) | Mühendislik | Kalite kontrol / ölçüm operatörü; kalite mühendisi / müdürü |
| Satın Alma | 69 (T2) | İşletme / İktisat | Köprü işi, satın alma işi/karar kartı |
| Finans | 49 (T1) | İşletme / İktisat | Giriş/köprü işi, finans işi/karar kartı |
| Ar-Ge / Ür-Ge | 49 (T1) | Mühendislik | Giriş/köprü işi, Ar-Ge işi/oyunu |
| Yatırım | 49 (T1) | İşletme / İktisat | Giriş/köprü işi, yatırım işi/karar kartı |
| İnsan Yönetimi | 69 (T2) | İşletme / İktisat | Takım Lideri, İK işi/karar kartı |

Depo & Sevkiyat iki bölümün de listesinde yoktur. Bu alanın 89 üstüne hangi eğitimle çıkılacağı açık karardır; listeyi sessizce genişletmedik. Satın Alma, Finans, Yatırım ve Ar-Ge için köprü işlerinin adları ve getirileri de daha sonra belirlenmelidir.

### Üniversite ve zaman

Üniversite birikimli 24 aylık tam zamanlı çalışma karşılığıdır; ara verme, iş kaybı veya iflas birikimi silmez. Tam zamanlı eğitimde maaş yoktur ve zaman uygunsa kurs alınabilir. Çalışarak eğitim ayda yaklaşık 2 saat kullanır; aynı ay kurs alınamaz ve daha yavaş ilerlediği için bitiş 24 takvim ayını aşabilir. Kesin saat, ilerleme ve ücret formülü dengeye bırakılır. Mühendislik Üretim, Bakım, Kalite, Ar-Ge ve Planlama; İşletme / İktisat Finans, Yatırım, Satın Alma, İnsan Yönetimi ve Planlama tavanlarını kaldırır. İlgili ikinci bölüm veya yüksek lisans öteki grubu açabilir. Diploma tek başına puan vermez.

### Statlar, kurs, sertifika ve odak

Statlar doğrudan yetkinlik puanı veya Tier vermez; işte öğrenme hızını en fazla ×1,3 çarpanıyla, iş ve oyun performansını, patronken Düzelt'in zaman ve para maliyetini etkiler. Eşik altındaki Düzelt şansını etkilemez. Kurs zaman ve oyun parası karşılığında ilgili statı artırır ve ilgili sertifikayı verir; farklı sertifika türleri az sayıda tutulur. Sertifikalar ilgili ileri işlerin başvuru koşuludur, diploma tavanını aşmaz. Odak ay başında ücretsiz seçilir, yalnız o ayın işiyle ilgili statı yavaşça artırır; kurs daha hızlıdır ve sertifika verir.

Claude notlarında tam bir stat–yetkinlik tablosu bulunmuyor. Notlarında açıkça geçen eşlemeyi çekirdek alıp kalan satırları **GPT'nin incelemeye açık tamamlama önerisi** olarak ayırıyoruz:

| Stat | İlişkili yetkinlikler | Kaynak |
| --- | --- | --- |
| Zeka | Finans, Yatırım, Planlama, Ar-Ge / Ür-Ge | Kullanıcı tarafından aktarılan Claude örneği |
| Dikkat | Kalite, Bakım, Üretim | Kullanıcı tarafından aktarılan Claude örneği |
| Yaratıcılık | Ar-Ge / Ür-Ge, Planlama | GPT tamamlama önerisi |
| Güç | Üretim, Depo & Sevkiyat, Bakım | GPT tamamlama önerisi |
| Hız | Üretim, Depo & Sevkiyat, Planlama | GPT tamamlama önerisi |
| Sosyallik | İnsan Yönetimi, Satın Alma | GPT tamamlama önerisi |
| Görünüm | İnsan Yönetimi, Satın Alma iş performansı; öğrenme bağı ayrıca incelenecek | GPT tamamlama önerisi |

Tablo ilgili statın öğrenme çarpanına veya iş performansına nerede girebileceğini gösterir; hiçbir satır statın yetkinlik puanını kendiliğinden artıracağı anlamına gelmez.

### Oyun şablonları ve aylık getiri

Dokuz ayrı oyun yerine üç yeniden kullanılabilir şablon vardır: Optimizasyon (Planlama, Ar-Ge); Teşhis (Bakım, Kalite); Karar kartı (Satın Alma, Finans, Yatırım, İnsan Yönetimi). İlk aşamada her şablondan bir örnek yapılır. Depo & Sevkiyat için önerilen yeni oyunun hangi şablona gireceği açık kalır. Üretim torna/taşlamayla, Depo örümcekle, Bakım setup ile de öğrenilebilir. Oyunlar ilgili iş/görev deneyiminin parçasıdır; tek başına bütün kariyer yollarının yerini almaz.

İş ve görev getirileri aylık işlenir; aynı işte öğrenme zamanla azalır. Ortalama performans da yetkinlik kazandırır, başarısız performans daha az kazandırabilir. Terfi ve performans değerlendirmesi yıllıktır. Kesin aylık puanlar ve azalma eğrisi henüz dengelenmemiştir.

## Notlar (Claude)

Tur 1 incelemesi. FRZ-001 ve FRZ-007 bağlayıcı kabul edildi; GAME_OVERVIEW §2, §13–17 ve §24 ile karşılaştırıldı. Bu turda yalnızca `Notlar (Claude)` değişti.

**Kayıt kontrolü (kullanıcının soruları):** Depoda sertifika listesi, "üst seviye iş sertifika ister" kuralı, odak mekaniği ve üniversite **hiç tanımlanmamış**. Statların yetkinliğe etkisi yalnız GAME_OVERVIEW §13'te var: "Stat = öğrenme ve uygulama kapasitesi, yetkinlik = gerçekten bildiğin şey". Statlar öğrenme hızını, çözüm süresini, maliyeti ve görev başarısını etkileyebilir; Tier açmaz (FRZ-001 §4, FRZ-007 §2). Meslek getirileri prototipte **aylık** işleniyor; kesin formül FRZ-007'de açık bırakılmış.

### Aldığım Notlar

- **"İş öğretir, kurs kapı açar ve hızlandırır, stat kapasitedir" ayrımı güçlü.** Yetkinliği yalnız iş/görev deneyimine bağlamak GAME_OVERVIEW §13 ve §14'ün özüyle ("gerçekten bildiğin şey") uyumlu. Kursun stat ve sertifika vermesi, "kursla her şeyi hızla öğren" kestirmesini kapatır.
- **Üniversitenin aylık saat bedeli** GAME_OVERVIEW §2'deki "bugün kazandığın şey için nelerden vazgeçtin?" temasına doğrudan hizmet ediyor. Çalışma + okul + kurs aynı ay sığmaz; seçim anlamlı olur.
- GPT'nin "diploma belirli pozisyonların başvuru koşulu olsun, bütün öğrenmeyi kilitlemesin" yorumuna katılıyorum.

### Bulduğum Sakıncalar

**1. Diploma kilidi FRZ-007'deki onaylı örnekle doğrudan çelişiyor (kritik).**
FRZ-007 §1'de Takım Lideri (mavi yaka) "ağırlıkla İnsan Yönetimi ve Planlama geliştirir" diye dondurulmuş. Tabloda Planlama ve İnsan Yönetimi "beyaz yaka" olarak işaretli. "Mezun değilsen bu yetkinlikler gelişmez" kuralı bu FREEZE örneğini geçersiz kılar. GAME_OVERVIEW §16 da mavi yakadan beyaz yakaya geçişi "deneyim, eğitim, liderlik, kariyer fırsatı" ile tarif ediyor; eğitim tek yol değil.

**2. Diploma kilidi ile "kurs yetkinlik vermez" birleşince mezun olmayan patron altı alanı hiç öğrenemez (kritik).**
Kurs yetkinlik vermez ve beyaz yaka işleri diploma isterse, mezun olmayan karakter Planlama, Satın Alma, Finans, Ar-Ge, Yatırım ve İnsan Yönetimi'ni hiçbir yoldan öğrenemez. Tek yol danışman kalır. Bu, FRZ-007 §3'ün ("on alanın her biri için kalıcı öğrenme yolu; danışman tek erişim yolu olarak kullanılmaz") ve Reddedilen Yollar'daki "Bir alanı yalnızca geçici danışmanla erişilebilir kılmak" maddesinin ta kendisi. İki öneriden en az biri yumuşamalı.

**3. Kalite için kalıcı öğrenme yolu yok.**
Tabloda Kalite'nin işi boş; kurs yetkinlik vermezse Kalite yalnız "+1 yeni oyun"a kalıyor. Oyun bir işin parçası değilse FRZ-007 §3 yine sağlanmaz. Kalite'nin doğal bir mavi yaka işi var: kalite kontrol / ölçüm operatörü.

**4. Dokuz yeni oyun GAME_OVERVIEW §17 ve CLAUDE.md korkuluğuyla çelişiyor (kapsam riski).**
§17: "Her departmana ayrı mini oyun yapmak zorunda değiliz"; Satın Alma, Finans, İnsan Yönetimi ve Yatırım "karar → zaman → sonuç" ile oynanır. CLAUDE.md de oyunun "birbirinden kopuk mini oyunlar koleksiyonuna" dönüşmemesini istiyor. Mevcut dört oyunla (torna, taşlama, örümcek, setup) birlikte 13 oyun, her biri ayrı tasarım, arayüz ve denge işi demek. Bu, çekirdek döngüyü (kariyer → patron) aylarca geciktirir.

**5. 24 ay, 5 yıllık hedefin yarısına yakın.**
GAME_OVERVIEW §24'e göre küçük fabrika yaklaşık 5 oyun yılında kurulabilmeli. Tam zamanlı 2 yıllık okul bu sürenin %40'ı. Çalışarak okumak mümkünse (paralel) zaman kaybı değil, fırsat maliyeti olur; bu doğru. Ama okul sırasında kurs hiç alınamazsa sertifika gerektiren ileri işler 2 yıl daha ertelenir; rota çok yavaşlayabilir.

### Kafama Yatmayanlar

- **Kurstan gelen stat genel bir güç olabilir.** Statlar bütün alanlarda öğrenmeyi hızlandırıyorsa, kurs yoluyla stat biriktirmek her kariyeri hızlandıran baskın bir strateji olabilir. Stat katkısının bir tavanı olmalı ya da kurs yalnız ilgili statı sınırlı artırmalı.
- **Odak ile kurs aynı işi yapıyor.** İkisi de statı destekliyorsa aralarındaki fark tanımlanmalı. Öneri: odak bedava ama yavaş ve yalnız o ayın işine bağlı; kurs paralı, hızlı ve sertifika veriyor.
- **Fabrikada öğrenme hiç tanımlı değil.** Patron olarak fabrikayı yönetmek bir alanı öğretir mi? Tanımlı değil (FRZ-003 v2'deki tek seferlik "acı tecrübe" hariç). Finans ve Yatırım için mavi yaka yolu zor olduğundan, bu soru "öğrenme yolu" kararını etkiler.

### Açık Sorular

`Açık Kararlar` için önerilerim:

1. **Diploma (Karar 1):** Diploma öğrenmeyi değil, **pozisyonu** kilitlesin. Önerilen yapı:
   - Beyaz yaka uzman/yönetici işleri diploma **veya** eşdeğer deneyim + sertifika ister.
   - Mavi yaka köprü işleri (Takım Lideri, Formen, ambar/mal kabul sorumlusu, kalite kontrolcü) ilgili alanları öğretir ama bir **tavana** kadar (ör. 50–70, T2–T3).
   - T4–T5 için beyaz yaka işi (diploma veya deneyim + sertifika) gerekir.
   - Böylece mezun olmayan patron her alanı bir ölçüde öğrenir, derin bilgi için okul fırsat maliyeti taşır. FRZ-007 §1 ve §3 bozulmaz.
2. **Üniversite zamanı (Karar 2):** **Birikimli 24 ay** olsun; iş kaybı, iflas veya ara verme okulu sıfırlamasın. İki mod önerilir:
   - Tam zamanlı: maaş yok, kurs mümkün, 24 ay.
   - Çalışarak okuma: ayda örneğin 2 saat, aynı ay kurs yok; süre de uzayabilir (ör. 30–36 ay).
3. **Kurs, sertifika, odak (Karar 3 ve 5):**
   - Kurs = stat + sertifika; yetkinlik vermez. Onaylanırsa FRZ-007 §1–3 için yeni FREEZE sürümü gerekir.
   - Sertifikalar az sayıda ve ileri pozisyonlara bağlı olsun (ör. "Satın Alma Uzmanı sertifikası → Satın Alma Müdürü başvurusu").
   - Odak: ayda bir seçilir, bedava, yalnız o ayın işiyle ilgili statı yavaşça artırır.
4. **Dokuz oyun (Karar 4'e ek):** Dokuz ayrı oyun yerine §17'deki türlerden **üç yeniden kullanılabilir oyun şablonu**:
   - Optimizasyon/bulmaca: Planlama, Ar-Ge.
   - Teşhis: Bakım (setup'ın devamı), Kalite.
   - Karar kartı ("karar → zaman → sonuç"): Satın Alma, Finans, Yatırım, İnsan Yönetimi.
   - Her şablonun içeriği alana göre değişir. İlk adımda her şablondan yalnız bir örnek yapılsın ve kariyer–patron döngüsü onlarla sınansın.
5. **Getiri hızı (Karar 4):** Getiri aylık kalsın. Aynı işte kazanım zamanla azalsın (FRZ-007'de açık). Terfi ve performans değerlendirmesi yıllık olsun. Ortalama performans da puan kazandırsın, başarısız ay daha az kazandırsın; hiç kazanç vermemek FRZ-007 §4'teki sarmal korumasıyla çatışabilir.
6. **Kalite (Karar 6):** Mavi yaka: kalite kontrol / ölçüm operatörü (teşhis şablonu). Beyaz yaka: kalite mühendisi / kalite müdürü (diploma veya deneyim + sertifika).

## Açık Kararlar

1. Depo & Sevkiyat tavanı 89 iken hangi bölüm veya eğitim yolu 90–100 aralığını açar? Üç şablondan hangisi yeni depo oyununu karşılar?
2. Claude notlarında tam stat–yetkinlik eşleme tablosu yok. GPT'nin tamamladığı Yaratıcılık, Güç, Hız, Sosyallik ve Görünüm satırları ayrıca incelenecek; Görünüm öğrenme çarpanına mı, yalnız iş performansına mı girecek?
3. Üniversitenin tam zamanlı/çalışarak aylık saat, ücret ve ilerleme oranı; ilgili ikinci bölüm/yüksek lisansın süresi ve koşulları nedir?
4. Hangi az sayıdaki sertifika hangi ileri işi açar; ilgili köprü işlerinin isimleri ve giriş koşulları nelerdir?
5. İş ve oyunların aylık puan formülü, aynı işte azalma eğrisi, başarısız ay getirisi, kurs/odak stat artış miktarı ve stat–alan çarpan ağırlıkları denge çalışmasında belirlenir.

## Karar Özeti

- Kullanıcı diploma öğrenmeyi sıfırdan kilitlemek yerine diplomasız alan tavanlarını 89/69/49 yapmaya karar verdi; çünkü mavi yaka deneyimi bütün alanlarda bilgi kazandırmalı, derin bilgi için üniversite anlamlı olmalı.
- Kullanıcı Mühendislik ve İşletme / İktisat bölümlerinin belirtilen alan tavanlarını kaldırmasına, ikinci bölüm veya yüksek lisansla diğer grubun açılmasına karar verdi; çünkü diploma bilgi puanı vermeden uzmanlık yolunu belirlemeli.
- Kullanıcı üniversiteyi ara verilebilen birikimli 24 aylık eğitim yapmaya, tam zamanlı ve çalışarak modları ayırmaya karar verdi; çünkü iş kaybı ilerlemeyi silmemeli ve çalışma ile eğitim arasında zaman/gelir bedeli olmalı.
- Kullanıcı statları en fazla ×1,3 öğrenme çarpanı, iş/oyun performansı ve Düzelt süresi/maliyetiyle sınırlamaya karar verdi; çünkü stat bilgi veya Tier yaratmamalı, eşik altı Düzelt şansını satın almamalı.
- Kullanıcı kursun yetkinlik yerine stat ve az sayıda ileri iş sertifikası vermesine, ücretsiz aylık odağın ise işle ilgili statı yavaş geliştirmesine karar verdi; çünkü iş deneyimi bilginin asıl kaynağı kalmalı, kurs ile odağın bedel ve hız farkı olmalı.
- Kullanıcı Kalite için mavi yakada kalite kontrol/ölçüm operatörü, beyaz yakada kalite mühendisi/müdürü yolunu seçti; çünkü kurs yetkinlik vermezken Kalite'nin kalıcı iş yolu bulunmalı.
- Kullanıcı dokuz ayrı yeni oyun yerine Optimizasyon, Teşhis ve Karar kartı şablonlarını ve önce her birinden bir örnek yapmayı seçti; çünkü kariyer–patron döngüsü kapsam yükü yüzünden gecikmemeli.
- Kullanıcı yetkinlik getirisini aylık ve aynı işte azalan, terfi ile değerlendirmeyi yıllık yapmaya ve ortalama performansa da puan vermeye karar verdi; çünkü düzenli deneyim ödüllendirilmeli ve kötü aylar ilerlemeyi bütünüyle kesmemeli.
