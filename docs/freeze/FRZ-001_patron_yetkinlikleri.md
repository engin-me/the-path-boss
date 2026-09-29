# FRZ-001 — Patron Yetkinlikleri ve Fabrika Sorun Döngüsü

Status: CURRENT
Date: 2026-09-29
Source: [IDEA-001](../ideas/IDEA-001_patron_yetkinlikleri.md), Tur 16 ve kullanıcı onayı.

## Onaylanan Kararlar

### 1. Patron yetkinliği bir bilgi modelidir

**Ne:** Patronun Üretim, Planlama, Depo & Sevkiyat, Bakım, Kalite, Satın Alma, Finans, Ar-Ge / Ür-Ge, Yatırım ve İnsan Yönetimi alanlarında ayrı ayrı 0–100 yetkinliği vardır. Yetkinlik doğrudan üretim bonusu değildir. İlgili alandaki tek yetkinlik puanı sorun Tier eşiğiyle karşılaştırılır; ayrıca “Görüş Seviyesi” tutulmaz.

**Neden:** Çalışanlık kariyerinde öğrenilen işler patronun hangi sorunu anlayabildiğini belirlemeli; aynı bilgiyi ikinci bir puanda tutmak gereksiz karmaşıklık yaratır.

### 2. Departman kartı ve görünürlük

**Ne:** Her departmanda T1–T5 için beş iç yuva ve Tier başına en fazla bir sorun vardır. Kart beş satır gösterir. Etkin yetkinlikle erişilen sorunların Tier'i ve belirtisi görünür. Erişilemeyen dolu yuvalar ayrı adsız satırlarda kayıp miktarı ve “Düzelt” ile görünür; birden fazla gizli Tier mümkünse şans “belirsiz”dir. Yalnızca tek gizli Tier mümkünse oyuncunun çıkarabildiği şans etiketi gösterilir, kök neden gizli kalır. Mümkün ama boş yuva “–”; mevcut ölçeğin dışında kalan **boş** yuva “ölçek dışı”dır. Önceki büyük ölçekte doğmuş dolu satır küçülmeyle kaybolmaz.

**Neden:** Oyuncu kaybı ve müdahale imkânını görmeli; bilemediği nedeni sebepsiz ceza gibi yaşamamalı. Zaten çıkarılabilir bilgi gereksiz yere saklanmamalıdır.

### 3. Danışman katkısı ve tek eylem

**Ne:** Bir alandaki etkin yetkinlik, patron ile o alanda aktif danışmanların puanlarının **en yükseğidir**; puanlar toplanmaz ve danışman patronun kalıcı puanını artırmaz. Danışman ilgili sorunun görülmesini ve kesin çözüm eşiğine ulaşılmasını sağlayabilir. Danışman varken de her sorun için tek eylem “Düzelt”tir; danışman ayrıca patron zamanını azaltabilir, kök müdahalesinin oyun parası bedelini değiştirmez.

**Neden:** Danışman bilgi açığını geçici olarak kapatmalı; çok danışman sınırsız puan yaratmamalı veya her sorun için ayrı bir karar menüsü açmamalıdır.

### 4. Düzelt, ortak kök ve aylık deneme

**Ne:** “Düzelt” yetkinlik eksikken de görünür ve para ile patron zamanı kullanır. Etkin yetkinlik kökün Tier eşiğine ulaşırsa sonuç kesindir; altında başarı olasılıkla belirlenir. Statlar eşik altı “Düzelt” şansını doğrudan artırmaz. Aynı departmandaki farklı Tier satırları en fazla iki kademe aralıkla ortak köke bağlanabilir. Bağlı satırlar **aynı oluşum olayında birlikte doğar**; sonradan köke yeni satır eklenmez. Kök derinliği bağlı satırların en yüksek Tier'idir. Hangi bağlı satırdan basılırsa basılsın başarı şansı ve gerçek çözüm bedeli köke göre hesaplanır. Başarı bütün bağlı satırları kapatır. Başarısızlık kökün bütün satırlarını o ay görünür biçimde kilitler; aynı kök ayda bir kez denenebilir. Fabrika genelinde tek müdahale sınırı yoktur.

**Neden:** Kolay görünen bir satır gizli derin kökü kesin veya daha ucuza çözme yolu olmamalı. Bağlı satırdan tekrar deneme istismarı önlenirken başarısızlık oyuncuya bağlantı hakkında bilgi vermelidir.

### 5. Maliyet, zaman ve güvence

**Ne:** Kök türünün oyun parası bedeli kendi Tier'inin **örtüşmeyen, artan fiyat bandı** içinden seçilir; kayıp miktarı bedeli belirlemez. Gizli satırın para tahmini, oluştuğu ölçek sınıfında mümkün ve etkin yetkinlikle erişilemeyen en sığ Tier bandının tabanıdır. Görünür satırın tahmini, şans etiketinden anlaşılan kök Tier bandının tabanıdır. Saat aralıkları örtüşebilir; Tier yükselirken saat tabanı ve tavanı azalmaz. Danışman saat indirimi uygulanıyorsa tahmini, gerçek ve üst saate aynı oran uygulanır.

**Ne:** Gizli satırın “en fazla” para ve saati, **gerçek sorunlara bakmadan satırın oluştuğu aydaki ölçek sınıfının olası en derin Tier tavanından** hesaplanır. Görünür satırda bilinen kök Tier'inin tavanı kullanılır. Deneme ancak mevcut oyun parası ve bu ay kalan patron saati bu iki üst tutarı karşılıyorsa başlar. Sonuç anında belirlenir: başarısızlıkta tahmin, başarıda gerçek kök bedeli aynı ay harcanır. Her iki kaynak için **tahmin ≤ gerçek ≤ üst** korunur; sonraki aya saat borcu veya sürpriz para borcu aktarılmaz.

**Neden:** Maliyet gerçek kök işiyle ilişkili kalırken gizli Tier ödeme ekranından sızmamalı. Başarı oyuncuyu karşılayamayacağı ek fatura veya sonraki ay yönetim felciyle cezalandırmamalıdır.

### 6. Fabrika ölçeği ve erken erişim

**Ne:** Görünür fabrika ölçeği, yeni sorunların ulaşabileceği en derin Tier'i sınırlar. Satır doğduktan sonra fabrika büyüse veya küçülse de Tier'i ve oluşum ölçeğine bağlı güvence tavanı değişmez. İlk oyun örneğinde, ilk üç ayın her birinde gizli sorun varsa oyuncu danışman tutmadan en az bir gizli satırı oyun parası ve patron zamanıyla deneyebilmelidir.

**Neden:** Büyüme yeni sorun derinliği getirebilir; mevcut sorunların kuralları sessizce değişmemeli. Bilgi açığı erken fabrikada çözümü imkânsızlaştırmamalı veya danışmanı fiilen zorunlu kılmamalıdır.

## Reddedilen Yollar

- Patron ve danışman puanlarını toplamak; 100 üzeri etkin yetkinlik ve birden fazla danışmanla sınırsız güç yaratır.
- Yetkinlik eksikken “Düzelt”i kapatmak veya her sorun için ayrı müdahale menüsü açmak; bilgi açığını risk yerine kilide, arayüzü içerik yüküne dönüştürür.
- Tekrar hakkını satıra bağlamak; aynı kökün bağlı satırlarından aynı ay birden fazla deneme yapılabilir.
- Üst güvenceyi gerçek gizli duruma veya fabrikanın **şimdiki** ölçeğine bağlamak; gizli bilgi sızdırabilir veya ölçek değişince mevcut sorunun erişimini bozabilir.
- Başarılı müdahalenin para/saat farkını borç olarak sonraki aya taşımak; başarıdan sonra sürpriz borç ve yönetim sıkışması yaratır.

## Bağımlılıklar ve Kapsam Dışı Konular

- Kesin Tier eşikleri, başarı yüzdeleri, para/saat bantları ve fabrika ölçeği sınırları ayrı denge ve ekonomi kararlarıdır. Buradaki yapısal kurallar bu sayılardan bağımsızdır.
- Danışman kart piyasası, sözleşme fiyatları ve gerçek para seçenekleri bu FREEZE kapsamında değildir; oyun parasıyla makul erişim ve monetizasyon dengesi ayrıca incelenir.
- Departman kaybının fabrika çıktısına dönüşümü, %33 performans tabanı, iflas parametreleri, personel/müdür sistemi ve stratejik müdahaleler ayrıca tasarlanır.
- `docs/03_GAME_OVERVIEW.md` içindeki müdür sistemi ve eski akış anlatımı, sonraki ilgili tasarım kararlarıyla uyum açısından gözden geçirilmelidir. Çelişki halinde bu FREEZE'in **kapsamındaki** kararlar geçerlidir.
