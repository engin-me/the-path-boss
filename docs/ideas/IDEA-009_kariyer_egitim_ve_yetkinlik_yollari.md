# IDEA-009 — Kariyer, Üniversite ve Yetkinlik Yolları

## Durum/Tur

Durum: REVIEW BEKLİYOR — kullanıcı yönlendirmeleri ve açık kararlar. Bu dosya FREEZE değildir.
Tur: 1
Tarih: 2026-09-29
Bağımlılık: [FRZ-007](../freeze/FRZ-007_calisanlik_kariyeri.md) ve [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md). Kursun doğrudan yetkinlik kazandırmaması onaylanırsa FRZ-007 için yeni sürüm gerekir.

## Öneri (GPT)

### Kullanıcının önerdiği yetkinlik yolları

| Yetkinlik | İş / mevcut oyun | Kurs | Tasarlanacak oyun |
| --- | --- | --- | --- |
| Üretim | Torna, taşlama | — | — |
| Planlama | Beyaz yaka işi | Var | +1 |
| Depo & Sevkiyat | Örümcek | — | +1 |
| Bakım | Setup | — | +1 |
| Kalite | Henüz iş belirtilmedi | Var | +1 |
| Satın Alma | Beyaz yaka işi | Var | +1 |
| Finans | Beyaz yaka işi | Var | +1 |
| Ar-Ge / Ür-Ge | Beyaz yaka işi | Var | +1 |
| Yatırım | Beyaz yaka işi | Var | +1 |
| İnsan Yönetimi | Beyaz yaka işi | Var | +1 |

“+1” denilen dokuz oyun daha sonra ayrı tasarlanacak. Kullanıcının kurs yönü önerisine göre kurslar bu alanların yetkinlik puanını doğrudan artırmaz; stat ve sertifika verir. Bu ayrım henüz onaylı kural değildir. Kalite için kalıcı yetkinlik kazandıran iş veya oyun yolunun nasıl işleyeceği netleşmelidir.

### Üniversite, kurs, sertifika ve odak

- **Üniversite önerisi:** İki oyun yılı / 24 ay sürer ve her ay birleşik zaman havuzundan saat kullanır. Mevcut kısa dilimde ayda 8 eylem saati var; örnek olarak üniversite 2 saat, iş 5 saat, kurs 3 saat olursa çalışan öğrenci aynı ay kursa gidemez. Bu oran denge önerisidir, karar değildir.
- **Kullanıcının üniversite sorusu:** Beyaz yaka olarak işaretlenen işler üniversite mezuniyeti istesin mi; mezun olmayan karakterlerin ilgili yetkinlikleri hiç gelişmesin mi? Kullanıcı iki oyun yılı üniversite ve aylık zaman bedeli önerdi; çalışma ve üniversite bir aradayken kursa fazla zaman kalmamalı.
- **GPT değerlendirmesi:** Diploma belirli beyaz yaka pozisyonlarına başvuru koşulu olabilir. Bütün ilgili yetkinlik artışını diploma ile kilitlemek önerilmez: mavi yaka liderlik deneyimi veya fabrika işletme tecrübesi de bilgi kazandırabilir. Claude bu ayrımı ve mavi yakadan beyaz yakaya geçişi değerlendirsin.
- **Kurs yönü:** Kullanıcı, kursun doğrudan yetkinlik yerine stat gelişimi ve sertifika vermesini önerdi. Yetkinliği iş/görev/oyun deneyimi kazandırır; stat öğrenme hızını veya görev performansını etkileyebilir, tek başına Tier açmaz. Bu yön FRZ-007 §1–3'teki kursla yetkinlik kazanımı kuralını değiştirir; Claude bu çatışmayı ve on alanın kalıcı öğrenme yollarını özellikle incelemeli. Onaydan sonra yeni FREEZE sürümü gerekir.
- **Sertifika:** Kullanıcı, üst seviye işlerde sertifika şartı olmasını hatırlıyor. Mevcut CURRENT FREEZE'lerde sertifika listesi veya hangi işin hangisini istediği yok. GPT önerisi: yalnız ilgili ileri pozisyonlarda belirli sertifika aransın; her beyaz yaka işine aynı sertifika kapısı konmasın.
- **Odak:** Kullanıcı odağın statları desteklemesini istiyor; kayıtlarda onaylı mekanik yok. GPT önerisi: oyuncu ay başında bir stat odağı seçer; o ayki uygun çalışma/oyun eylemleri ilgili statın gelişimini destekler. Odak yetkinlik puanını doğrudan artırmaz.
- **Zaman ölçeği:** Mevcut oynanabilir dilimde iş maaşı, yetkinlik getirisi, enerji ve kurs bedeli aylık işleniyor. Yıllık yetkinlik ödülü tanımlanmamış. Uzun kariyerde tekrar eden aylık puanların hızı ayrıca dengelenmeli.

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

1. Üniversite diploması hangi beyaz yaka pozisyonlarında zorunlu olacak? Denk deneyim/terfi yolu bulunacak mı?
2. Üniversitenin aylık saat ve para bedeli ile çalışırken devam koşulu ne olacak? İki yıl kesintisiz mi, birikimli 24 ay mı?
3. Hangi kurs hangi statı ve sertifikayı verir; ileri işler hangi sertifikayı arar?
4. İş, mini oyun ve görev sonuçları yetkinliği hangi hızda artırır? Başarısız veya ortalama performans puan kazandırır mı?
5. Odak stat gelişimini nasıl etkiler ve ne sıklıkla değiştirilebilir?
6. Kalite için mavi yaka/beyaz yaka kariyer yolları nasıl ayrılır?

## Karar Özeti

Henüz kullanıcı onayından ve Claude incelemesinden geçmiş yeni karar yok. Bu dosya mevcut önerileri kaydeder; FRZ-007 yürürlüktedir.
