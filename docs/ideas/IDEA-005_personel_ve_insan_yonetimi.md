# IDEA-005 — Personel ve İnsan Yönetimi

## Durum/Tur

Durum: Tur 2 sentezi; Claude'un önerileri kullanıcı tarafından kabul edildi. Bu dosya henüz FREEZE değildir.
Tur: 2
Date: 2026-09-29
Bağımlılıklar: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md), [FRZ-002 v3](../freeze/FRZ-002_v3_fabrika_ekonomisi.md).

## Öneri (GPT)

**Kapsam.** Ayrı bir müdür karakteri, müdür yetkinliği veya işe al/kov eylem zinciri tanımlanmaz. Personelden kaynaklanan olaylar mevcut departman sorun döngüsünde kök neden olarak görünür. “Düzelt” başarılı olursa gereken konuşma, yaptırım, eğitim veya işten çıkarma çözümün içinde gerçekleşir; sonuç metni **yapılan personel işlemini adıyla** anlatır. FRZ-001'in tek buton, Tier, para/zaman ve başarı kuralları aynen işler.

**İnsan Yönetimi'nin katkısı.** Patronun **kalıcı İnsan Yönetimi puanı**, yeni kişi kaynaklı sorunların oluşma olasılığını bütün departmanlarda azaltır. Danışmanın geçici İnsan Yönetimi puanı bu genel sıklığı azaltmaz; ilgili mevcut sorunu görme ve Düzelt'te FRZ-001'e göre işe yarar. Sorun üretiminde önce kökün kaynak türü belirlenir; kişi kaynaklı oluşum İnsan Yönetimi etkisiyle önlenirse olay **iptal edilir, yerine süreç sorunu üretilmez**. Mevcut sorun kendiliğinden kapanmaz. Kişi kaynaklı köklerin payı **her departmanda ve her Tier'de aynı hedef oranla** dağıtılır; derin Tier'lerde yoğunlaştırılmaz. Böylece İnsan Yönetimi başka alanlardaki derin bilgiyi gereksizleştirmez.

**Denge hedefi.** En yüksek puanda kişi kaynaklı **yeni** sorunların yaklaşık **%80'i** önlensin; başlangıçta kişi kaynaklı köklerin toplam sorun payı yaklaşık **%30** olsun. Bu birleşim toplam sorun oluşumunu yaklaşık **%24 azaltır**; kesin eğri ve oran oyun testinde ayarlanır. Kabul ölçütü: İnsan Yönetimi 100 olan patron, aynı toplam yetkinlik puanını başka alanlara dağıtmış patronu sistematik olarak geçmemeli. İnsan Yönetimi etkisi güçlü kalır ama diğer alanların yerini tutmaz.

**Rapor ve maliyet.** Kişi kaynaklı sorun, kökün ait olduğu tek departmanın Tier satırında FRZ-001'e göre kayıp üretir; başka departmanda ikinci kez yazılmaz. İnsan Yönetimi alanının kendine özgü sorunları da bulunur. Mevcut **gizli** satırda “kişi kaynaklı” etiketi veya sayısı gösterilmez; kök türü ancak ilgili satır görünür olduğunda ya da Düzelt sonucunda açıklanır. İnsan Yönetimi'nin faydası, mevcut satırlardan bağımsız **“bu ay önlenen kişi kaynaklı olay”** sayısıyla aylık raporda gösterilir. Önlenen olay hiç oluşmadığı için gizli kök nedeni sızdırmaz. Olağan personel giderleri FRZ-002 v3'ün bilinen gider/kasa sırasındadır; Düzelt bedeli FRZ-001 kuralıyla ayrıca ödenir.

**Vizyon bağı.** [GAME_OVERVIEW](../03_GAME_OVERVIEW.md) §10 ve §19 adlı müdürler ile işe alma kararlarını daha ayrıntılı anlatır. Kullanıcının önceki sadeleştirme yönü bu taslakta önceliklidir. Bu konu FREEZE olursa overview'daki ayrıntılı müdür kurgusu yürürlükteki tasarımla uyumlu hale getirilmelidir; bugünkü metin sessizce onaylı kural sayılmaz.

## Notlar (Claude)

Tur 1 incelemesi, kısa. Yalnızca **kritik çelişkiler** ve **en fazla üç açık karar** yazıldı. FRZ-001 ve FRZ-002 v3 bağlayıcı kabul edildi. Bu turda yalnızca `Notlar (Claude)` değişti.

### Aldığım Notlar

- Ayrı müdür karakteri açmadan personel işleminin "Düzelt" içinde kalması FRZ-001'in tek eylem kuralıyla ve kullanıcının önceki yönlendirmesiyle tutarlı.
- GAME_OVERVIEW §10 ve §19 ile uyumsuzluğun açıkça yazılmış olması doğru.

### Bulduğum Sakıncalar

**1. İnsan Yönetimi'nin azaltma mekanizması tanımsız; yanlış uygulanırsa etkisi sıfır olur (kritik).**
FRZ-001'e göre departmanda en fazla beş Tier yuvası var. FRZ-002 v3'e göre ise tavana ulaşmış departmanda yeni kayıp sorunu üretilmiyor. Sorun üretimi önce "bir yuvada sorun doğar", sonra "türü kişi mi süreç mi" diye çalışırsa, İnsan Yönetimi yalnızca türü değiştirir. Toplam sorun ve kayıp aynı kalır; yetkinlik fiilen değersizleşir. Tavandaki departmanda ise hiç görünmez. Öneri: **önlenen kişi kaynaklı oluşum olayı iptal edilir; yerine başka sorun üretilmez.** Böylece azaltma, toplam sorun sayısını gerçekten düşürür.

**2. Kişi kaynaklı kökler derin Tier'lerde yoğunlaşırsa, İnsan Yönetimi bütün departmanlarda derin yetkinliğin yerini tutar (kritik; FRZ-001 bilgi modeliyle çelişki).**
Mevcut örneklerde kişi kaynaklı kökler derin Tier'lerde: Satın Alma T4 "kayırma", T5 "çıkar çatışması". İçerik bu yönde üretilirse, İnsan Yönetimi 100 olan patron her departmanda T4–T5 sorunlarının büyük kısmını hiç yaşamaz. Bu, "derin sorunu görmek için o alanın kariyer bilgisi gerekir" ilkesini arka kapıdan deler. Öneri: **kişi kaynaklı pay her Tier'de ve her departmanda aynı olsun.** Böylece İnsan Yönetimi sorunları Tier'den bağımsız olarak eşit oranda azaltır.

**3. "Kişi kaynaklı" bilgisi gizli satırın kök nedenini sızdırabilir (kritik; FRZ-001 §2 ile çelişki).**
Rapor, İnsan Yönetimi'nin etkisini göstermek için mevcut satırlarda "kişi kaynaklı" sayısı ya da etiketi gösterirse, gizli satırın kök türü ortaya çıkar. Öneri:
- Kök türü yalnızca görünür satırlarda veya Düzelt sonucunda gösterilsin.
- İnsan Yönetimi'nin değeri, var olan satırlardan bağımsız bir **"bu ay önlenen kişi kaynaklı olay"** satırıyla gösterilsin. Önlenen olay hiç oluşmadığı için gizli bilgi içermez.

### Kafama Yatmayanlar

- Kapsam gereği bu turda ayrıca not yazılmadı.

### Açık Sorular

`Açık Kararlar` 1–3 için öneriler:

1. **Yalnızca yeni sorunlar mı?** Evet. Mevcut sorunun kendiliğinden kapanması hem Düzelt'i atlatır hem de hangi gizli satırın kişi kaynaklı olduğunu sızdırır.
2. **Denge:** Yaklaşık %80 azaltma, kullanıcının önceki kararıyla uyumlu (%50 tavan reddedilmişti). Ancak bu oran %30–40 payla birleşince, en yüksek İnsan Yönetimi **toplam sorunları yaklaşık %24–32 azaltır**. Bu etki on departmanın hepsine birden yayılıyor; diğer yetkinlikler ise yalnızca kendi departmanlarında görünürlük sağlıyor. Öneri:
   - Başlangıç payı alt uçta (~%30) tutulsun.
   - Test ölçütü konsun: İnsan Yönetimi 100 olan patron, aynı toplam puanı başka alanlara dağıtmış patronu sistematik olarak geçmemeli.
3. **Anlaşılırlık:** Ayrı karakter ekranı olmadan yeterli olur, iki koşulla:
   - Düzelt sonuç metni yapılan personel işlemini adıyla söylesin ("satın alma sorumlusu değiştirildi" gibi).
   - Aylık raporda "önlenen kişi kaynaklı olay" satırı bulunsun.

## Açık Kararlar

1. Yaklaşık %80 azaltma, %30 başlangıç payı ve eşit Tier/departman dağılımının kesin değerleri denge testinde belirlenecektir.
2. Önlenen olay sayısının raporda sunumu ve personel işlemi sonuç metinleri içerik/arayüz testinde sınanacaktır.
3. FREEZE sonrasında GAME_OVERVIEW §10 ve §19'daki ayrıntılı müdür/aday anlatımı yürürlükteki sade personel tasarımıyla uyumlu hale getirilmelidir.

## Karar Özeti

- Ayrı müdür karakteri veya müdür yetkinliği açılmaz; gerekli personel işlemi Düzelt sonucu olarak adıyla anlatılır, çünkü yönetim sorunu tek eylem akışında anlaşılır kalmalıdır.
- Patronun kalıcı İnsan Yönetimi puanı yalnızca **yeni** kişi kaynaklı oluşumu önler ve önlenen olay yerine başka sorun doğmaz; çünkü yetkinlik toplam sorun sayısını gerçekten azaltmalı ama mevcut sorunları bedelsiz çözmemelidir.
- Kişi kaynaklı pay bütün Tier ve departmanlarda eşit hedeflenir; çünkü İnsan Yönetimi diğer alanların derin sorunlarını topluca devre dışı bırakmamalıdır.
- Yaklaşık %80 önleme ve yaklaşık %30 başlangıç payı ilk hedeftir; çünkü İnsan Yönetimi güçlü olmalı ama eşit toplam puanlı diğer kariyer rotalarını sistematik olarak geçmemelidir.
- Gizli satırın kişi kaynaklı olduğu açıklanmaz, fayda ayrı “önlenen olay” sayısıyla gösterilir; çünkü kök nedeni sızdırmadan oyuncu yetkinliğin işe yaradığını görmelidir.
