# IDEA-009 — Kariyer, Üniversite ve Yetkinlik Yolları

## Durum/Tur

Durum: TUR 3 REVİZYONU — kullanıcı Tier başı tavanları taslak yönü olarak onayladı; [FRZ-007 v3 taslağı](../freeze/FRZ-007_v3_calisanlik_kariyeri.md) DRAFT, v2 CURRENT. Bu IDEA dosyası FREEZE değildir.
Tur: 3
Tarih: 2026-09-29
Bağımlılık: [FRZ-007 v2](../freeze/FRZ-007_v2_calisanlik_kariyeri.md) ve [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md). Önerilen sonuç: [FRZ-007 v3 DRAFT](../freeze/FRZ-007_v3_calisanlik_kariyeri.md).

## Öneri (GPT)

### Tur 3: İş, diploma ve yetkinlik

Yetkinlik puanı iş, görev ve ilgili oyun deneyiminden gelir. Kurs yetkinlik vermez; stat ve sertifika verir. Diploma puan kazandırmaz, yalnız ilgili alanın kalıcı öğrenme tavanını kaldırır. Diplomasız karakterler de mavi yaka ve köprü işleriyle bütün alanlarda öğrenebilir. Takım Lideri Planlama ve İnsan Yönetimi geliştirmeye devam eder; tavanı aşan puan birikmez. Sertifika veya eşdeğer deneyim bu tavanı kaldıramaz. Böylece FRZ-007'deki her alana kalıcı öğrenme yolu korunurken diploma derin uzmanlık için değer taşır.

| Yetkinlik | Diplomasız tavan | Tavanı kaldıran bölüm | Öğrenme yolu örnekleri |
| --- | ---: | --- | --- |
| Üretim | 70 (T3) | Mühendislik | Torna, taşlama |
| Planlama | 50 (T2) | Mühendislik veya İşletme / İktisat | Takım Lideri, planlama işi/oyunu |
| Depo & Sevkiyat | 70 (T3) | Mühendislik veya İşletme / İktisat | Örümcek, depo işi/Optimizasyon oyunu |
| Bakım | 70 (T3) | Mühendislik | Setup, bakım işi/oyunu |
| Kalite | 70 (T3) | Mühendislik | Kalite kontrol / ölçüm operatörü; kalite mühendisi / müdürü |
| Satın Alma | 50 (T2) | İşletme / İktisat | Köprü işi, satın alma işi/karar kartı |
| Finans | 30 (T1) | İşletme / İktisat | Giriş/köprü işi, finans işi/karar kartı |
| Ar-Ge / Ür-Ge | 30 (T1) | Mühendislik | Giriş/köprü işi, Ar-Ge işi/oyunu |
| Yatırım | 30 (T1) | İşletme / İktisat | Giriş/köprü işi, yatırım işi/karar kartı |
| İnsan Yönetimi | 50 (T2) | İşletme / İktisat | Takım Lideri, İK işi/karar kartı |

Depo & Sevkiyat her iki bölümle 70 üstüne çıkabilir. 70/50/30 tavanları Tier'in ilk puanıdır; eski 89/69/49 tavanları FRZ-007 v3 taslağında önerilmez. Aynı Tier içindeki ek puan görünürlüğü değiştirmez ve yeni şans eğrisinde 89 puan diplomanın rolünü zayıflatır. Satın Alma, Finans, Yatırım ve Ar-Ge için köprü işlerinin adları ve getirileri daha sonra belirlenmelidir. FRZ-003 v2'deki tek seferlik “acı tecrübe” artışı da diploma tavanını aşamaz. Arayüz oyuncuya mevcut puanı, tavanı ve açan diplomayı gösterir.

### Üniversite ve zaman

Üniversite birikimli 24 aylık tam zamanlı çalışma karşılığıdır; ara verme, iş kaybı veya iflas birikimi silmez. Tam zamanlı eğitimde maaş yoktur ve zaman uygunsa kurs alınabilir. Çalışarak eğitim ayda yaklaşık 2 saat kullanır; aynı ay kurs alınamaz ve daha yavaş ilerlediği için bitiş 24 takvim ayını aşabilir. Kesin saat, ilerleme ve ücret formülü dengeye bırakılır. Mühendislik Üretim, Depo & Sevkiyat, Bakım, Kalite, Ar-Ge ve Planlama; İşletme / İktisat Depo & Sevkiyat, Finans, Yatırım, Satın Alma, İnsan Yönetimi ve Planlama tavanlarını kaldırır. İlgili ikinci bölüm veya yüksek lisans öteki grubu açabilir. Diploma tek başına puan vermez.

### Statlar, kurs, sertifika ve odak

Statlar doğrudan yetkinlik puanı veya Tier vermez; işte öğrenme hızını en fazla ×1,3 çarpanıyla, iş ve oyun performansını, patronken aşağıdaki etkileri sağlar. Eşik altındaki Düzelt şansını etkilemez. Statın Düzelt para indirimi, indirimsiz kök bedeli ilgili Tier bandından seçildikten sonra para tahmini, gerçek bedel ve üst güvenceye aynı oranda uygulanır; kaynak kontrolü indirimli üst bedelle yapılır. Böylece tahmin ≤ gerçek ≤ üst korunur. Kurs zaman ve oyun parası karşılığında ilgili statı artırır ve ilgili sertifikayı verir; farklı sertifika türleri az sayıda tutulur. Sertifikalar ilgili ileri işlerin başvuru koşuludur, diploma tavanını aşmaz. Odak ay başında ücretsiz seçilir, yalnız o ayın işiyle ilgili statı yavaşça artırır; kurs daha hızlıdır ve sertifika verir.

Claude'un Tur 2 notlarındaki ve kullanıcının onayladığı tam tablo:

| Stat | Öğrenme çarpanı (en fazla ×1,3) | İş / oyun performansı | Patronluk etkisi |
| --- | --- | --- | --- |
| Zeka | Finans, Yatırım, Planlama, Ar-Ge / Ür-Ge | Planlama bulmacası | Düzelt süresi |
| Dikkat | Kalite, Bakım, Üretim | Hata payı | Düzelt maliyeti; üç para değerine aynı oran |
| Hız | Üretim, Depo & Sevkiyat | Tempo | Aylık patron saati biraz artar |
| Güç | Depo & Sevkiyat | Örümcek, forklift | — |
| Yaratıcılık | Ar-Ge / Ür-Ge | Tasarım bulmacası | — |
| Sosyallik | İnsan Yönetimi, Satın Alma | Görüşme, pazarlık | Danışman sözleşme ücreti |
| Görünüm | — (öğrenme çarpanı yok) | İş görüşmesi, terfi şansı | İş teklifi kalitesi |

Tablo ilgili statın öğrenme çarpanına veya performansa nerede girebileceğini gösterir; hiçbir satır statın yetkinlik puanını kendiliğinden artıracağı anlamına gelmez.

### Oyun şablonları ve aylık getiri

Dokuz ayrı oyun yerine üç yeniden kullanılabilir şablon vardır: Optimizasyon (Planlama, Ar-Ge, Depo & Sevkiyat yükleme/sevkiyat planlaması); Teşhis (Bakım, Kalite); Karar kartı (Satın Alma, Finans, Yatırım, İnsan Yönetimi). İlk aşamada her şablondan bir örnek yapılır. Üretim torna/taşlamayla, Depo örümcekle, Bakım setup ile de öğrenilebilir. Oyunlar ilgili iş/görev deneyiminin parçasıdır; tek başına bütün kariyer yollarının yerini almaz.

İş ve görev getirileri aylık işlenir; aynı işte öğrenme zamanla azalır. Ortalama performans da yetkinlik kazandırır, başarısız performans daha az kazandırabilir. Terfi ve performans değerlendirmesi yıllıktır. Kesin aylık puanlar ve azalma eğrisi henüz dengelenmemiştir.

## Notlar (Claude)

Tur 2 incelemesi: IDEA-009 Tur 2 sentezi ve [FRZ-007 v2 taslağı](../freeze/FRZ-007_v2_calisanlik_kariyeri.md). FRZ-001, FRZ-003 v2, FRZ-006 v2 ve CURRENT FRZ-007 bağlayıcı kabul edildi. Bu turda yalnızca bu bölüm değişti; FREEZE dosyalarına dokunulmadı.

### Aldığım Notlar

- Kullanıcı kararları taslağa doğru ve eksiksiz işlenmiş: 89/69/49 tavanları, diplomanın puan değil tavan açması, eşdeğer deneyim kapısının olmaması, birikimli 24 ay, kurs = stat + sertifika, ücretsiz odak, Kalite yolu, üç şablon, aylık getiri ve yıllık terfi.
- FRZ-007 §3'teki "her alana danışmandan bağımsız öğrenme yolu" ve §4'teki psikoloji koruması korunmuş. Üniversite ilerlemesinin iş kaybıyla silinmemesi de doğru biçimde eklenmiş.
- Taslak ayrı dosyada, DRAFT durumunda; Decision Index'e CURRENT olarak girmemiş. Süreç kurala uygun.
- **Depo & Sevkiyat boşluğu benim hatam.** Önerdiğim bölüm listelerine bu alanı eklemeyi unuttum; GPT'nin listeyi sessizce genişletmemesi doğru.

### Bulduğum Sakıncalar

**1. Depo & Sevkiyat kalıcı olarak 89'da kilitli (FREEZE öncesi kapanmalı).**
İki bölüm de bu alanı açmıyor. Bu durumda Depo & Sevkiyat'ta T4–T5'e hiçbir yoldan çıkılamaz; büyük ölçekte bu alanın derin sorunları yalnız danışmanla görülebilir. Bu, FRZ-007 §3'ün reddettiği "yalnız danışmanla erişilebilir" duruma derin Tier'ler için geri dönüyor. **Öneri:** Depo & Sevkiyat, Planlama gibi **iki bölüm listesine de** girsin (lojistik ve tedarik zinciri, hem endüstri mühendisliğinin hem işletmenin konusu). Yeni depo oyunu **Optimizasyon** şablonuna girsin (yükleme ve sevkiyat planlama); mevcut örümcek oyunu rota ve yerleştirme deneyimi olarak kalır.

**2. Stat maliyet indirimi FRZ-001 §5 değişmezini bozabilir.**
Taslak §4, statın "Düzelt'in oyun parası maliyetine" etki edebileceğini söylüyor. FRZ-001 §5'te gerçek bedel kendi Tier bandından seçilir ve "tahmin ≤ gerçek ≤ üst" korunur. Stat yalnız gerçek bedeli düşürürse, gerçek bedel tahminin altına inebilir ya da bant dışına çıkabilir. Ayrıca FRZ-006 v2 §4 danışmanın para bedelini düşürmediğini söylüyor; statın düşürmesi bu ayrımı açıklamalı. **Öneri:** "Stat indirimi tahmin, gerçek ve üst değerlere aynı oranla uygulanır; güvence kontrolü indirimli üst değerle yapılır" cümlesi eklensin (FRZ-001 §5'teki danışman saat kuralıyla aynı yapı).

**3. "Acı tecrübe" ile tavan ilişkisi tanımsız.**
FRZ-003 v2 §5 iflastan sonra küçük bir yetkinlik artışı veriyor. Taslak "tavanı aşan puan birikmez" diyor, ama bu artışın tavana tabi olup olmadığını söylemiyor. İflası diplomasız tavanı aşmanın yolu yapmamak için **"acı tecrübe de diploma tavanına tabidir"** yazılmalı.

**4. Tavanlar erken fabrikayı zorlaştırıyor; patron testinde sınanmalı.**
Diplomasız patron Finans, Yatırım ve Ar-Ge'de yalnız T1'i görür. Küçük ölçekte bile T2–T3 sorunlar oluşabildiği için bu alanlar hep gizli kalır. Patron testinde gizli sorunların birikmesi zaten en büyük bulguydu (`godot/playtests/claude_bulgular.md`, bulgu 2). İki kural birleşince diplomasız rota fiilen yaşanmaz hale gelebilir. Bu bir çelişki değil, denge riski. Ama FREEZE öncesinde patron testine **diploma seçimi eklenip** diplomasız karakterlerle sınanmalı. Mevcut test karakterlerinin çoğu (ör. Finansçı Kumarbaz, Finans 90) diplomasız tavanı zaten aşıyor.

### Kafama Yatmayanlar

- **Tavandaki oyuncu ne görür?** Takım Lideri olarak 69'a gelen oyuncu, aynı işte yıllarca çalışıp hiçbir şey kazanmayabilir. Arayüz tavanı ve nedenini göstermeli ("Planlama 69/69 — daha derini için Mühendislik veya İşletme diploması"). Yoksa oyuncu bunu hata sanır.
- **Taslağın `docs/freeze/` içinde durması** kural açısından sorun değil; durum satırı açık. Ama CLAUDE.md "FREEZE dosyaları yetkilidir" dediği için okuyucu karıştırabilir. Onaya kadar dosya adında da `_DRAFT` olması daha güvenli olabilir.

### Açık Sorular

`Açık Kararlar` için önerilerim:

1. **Depo & Sevkiyat (Karar 1):** İki bölüm listesine de eklensin; yeni depo oyunu Optimizasyon şablonuna girsin.
2. **Stat eşlemesi (Karar 2):** Kullanıcıya sohbette önerdiğim tam tablo aşağıda. GPT'nin tamamlama satırlarından Güç → Üretim/Bakım, Hız → Planlama, Yaratıcılık → Planlama ve Görünüm → öğrenme bağları bu tabloda **yok**.

   | Stat | Öğrenme çarpanı (en fazla ×1,3) | İş / oyun performansı | Patronluk etkisi |
   | --- | --- | --- | --- |
   | Zeka | Finans, Yatırım, Planlama, Ar-Ge / Ür-Ge | Planlama bulmacası | Düzelt süresi |
   | Dikkat | Kalite, Bakım, Üretim | Hata payı | Düzelt maliyeti (Sakınca 2'deki oransal kural ile) |
   | Hız | Üretim, Depo & Sevkiyat | Tempo | Aylık patron saati biraz artar |
   | Güç | Depo & Sevkiyat | Örümcek, forklift | — |
   | Yaratıcılık | Ar-Ge / Ür-Ge | Tasarım bulmacası | — |
   | Sosyallik | İnsan Yönetimi, Satın Alma | Görüşme, pazarlık | Danışman ücreti |
   | Görünüm | — (öğrenme çarpanı yok) | İş görüşmesi, terfi şansı | İş teklifi kalitesi |

   Görünüm'ü öğrenme çarpanından çıkarmayı öneriyorum: görünüşün bilgiyi hızlandırması hem gerçekçi değil hem de "yetkinlik = gerçekten bildiğin şey" ilkesini zayıflatır. Kullanıcı hangi tabloyu seçerse o işlenmeli.
3. **Acı tecrübe:** Diploma tavanına tabi olsun (Sakınca 3).
4. **Stat maliyet indirimi:** Oransal ve üç değere birden uygulansın (Sakınca 2).
5. **Test:** Patron testine diploma seçimi (yok / Mühendislik / İşletme-İktisat / ikisi) eklensin ve tavan uygulansın. Böylece FREEZE öncesinde diplomasız rota sınanır.

**FREEZE durumu:** 1–4 birer cümlelik düzeltme. Kullanıcı onaylarsa FRZ-007 v2 bu eklerle CURRENT yapılabilir. 5 bir test işi; FREEZE'i beklemesine gerek yok, ama sonucu tavan sayılarını değiştirebilir.

## Açık Kararlar

1. Üniversitenin tam zamanlı/çalışarak aylık saat, ücret ve ilerleme oranı; ilgili ikinci bölüm/yüksek lisansın süresi ve koşulları denge çalışmasında belirlenir.
2. Hangi az sayıdaki sertifika hangi ileri işi açar; ilgili köprü işlerinin isimleri ve giriş koşulları belirlenir.
3. İş ve oyunların aylık puan formülü, aynı işte azalma eğrisi, başarısız ay getirisi, kurs/odak stat artış miktarı ve stat etkilerinin kesin büyüklükleri belirlenir.
4. Diplomasız patronların 30/50/70 tavanlarıyla fabrika kurup yaşama şansı oynanabilir patron testinde sınanır; gerekirse sayısal tavanlar yeni bir IDEA turuyla gözden geçirilir.

## Karar Özeti

- Kullanıcı diplomasız alan tavanlarını eski 89/69/49 yerine Tier başından 70/50/30 olarak taslak revizyonuna aldı; çünkü aynı Tier içindeki puan görünürlüğü değiştirmez ve eski yüksek tavanlar yeni şans eğrisinde diplomanın değerini azaltır.
- Kullanıcı Mühendislik ve İşletme / İktisat bölümlerinin belirtilen alan tavanlarını kaldırmasına, ikinci bölüm veya yüksek lisansla diğer grubun açılmasına karar verdi; çünkü diploma bilgi puanı vermeden uzmanlık yolunu belirlemeli.
- Kullanıcı üniversiteyi ara verilebilen birikimli 24 aylık eğitim yapmaya, tam zamanlı ve çalışarak modları ayırmaya karar verdi; çünkü iş kaybı ilerlemeyi silmemeli ve çalışma ile eğitim arasında zaman/gelir bedeli olmalı.
- Kullanıcı statları en fazla ×1,3 öğrenme çarpanı ile Claude'un tablosundaki iş, oyun ve patronluk etkileriyle sınırlamaya karar verdi; çünkü stat bilgi veya Tier yaratmamalı, eşik altı Düzelt şansını satın almamalı.
- Kullanıcı kursun yetkinlik yerine stat ve az sayıda ileri iş sertifikası vermesine, ücretsiz aylık odağın ise işle ilgili statı yavaş geliştirmesine karar verdi; çünkü iş deneyimi bilginin asıl kaynağı kalmalı, kurs ile odağın bedel ve hız farkı olmalı.
- Kullanıcı Kalite için mavi yakada kalite kontrol/ölçüm operatörü, beyaz yakada kalite mühendisi/müdürü yolunu seçti; çünkü kurs yetkinlik vermezken Kalite'nin kalıcı iş yolu bulunmalı.
- Kullanıcı dokuz ayrı yeni oyun yerine Optimizasyon, Teşhis ve Karar kartı şablonlarını ve önce her birinden bir örnek yapmayı seçti; çünkü kariyer–patron döngüsü kapsam yükü yüzünden gecikmemeli.
- Kullanıcı yetkinlik getirisini aylık ve aynı işte azalan, terfi ile değerlendirmeyi yıllık yapmaya ve ortalama performansa da puan vermeye karar verdi; çünkü düzenli deneyim ödüllendirilmeli ve kötü aylar ilerlemeyi bütünüyle kesmemeli.
- Kullanıcı Depo & Sevkiyat tavanını iki üniversite bölümünün de kaldırmasına ve yeni depo oyununu Optimizasyon şablonuna bağlamaya karar verdi; çünkü derin depo bilgisini yalnız danışmana bırakmadan mevcut üç şablonu yeniden kullanmak istiyor.
- Kullanıcı stat kaynaklı Düzelt para indirimini tahmin, gerçek ve üst tutara aynı oranla uygulamaya ve güvenceyi indirimli üstten kontrol etmeye karar verdi; çünkü FRZ-001'in tahmin ≤ gerçek ≤ üst kuralı korunmalı.
- Kullanıcı iflasın “acı tecrübe” puanını da diploma tavanına tabi kılmaya karar verdi; çünkü iflas diplomasız derin yetkinlik sınırını aşma kestirmesi olmamalı.
- Kullanıcı Claude'un tam stat tablosunu ve Görünüm'ün öğrenme çarpanına girmemesini onayladı; çünkü statların etki alanları belirli olmalı ve görünüş bilgi kazanımı sayılmamalı.
