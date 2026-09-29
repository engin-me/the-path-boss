# FRZ-006 — Danışman Pazarı ve Sözleşmeler

Status: CURRENT
Date: 2026-09-29
Source: [IDEA-001](../ideas/IDEA-001_patron_yetkinlikleri.md) içindeki önceki kullanıcı kararları ve [IDEA-006](../ideas/IDEA-006_danisman_pazari.md). Bu konu için kullanıcı tercihiyle yeni Claude turu yapılmadı.
Depends on: [FRZ-001](FRZ-001_patron_yetkinlikleri.md), [FRZ-002 v3](FRZ-002_v3_fabrika_ekonomisi.md).

## Onaylanan Kararlar

### 1. Danışman kartları ve ücret ilkesi

**Ne:** Danışmanlar önceden tanımlı, sınırlı bir profil havuzundan gelir. Bir profilde **2–5 yetkinlik** listelenir. Her listelenen puan **25–100** arasındadır; toplam puan **listelenen alan sayısı × 60** değerini aşamaz. İki alanın 100 olması mümkündür; bu profiller nadir ve pahalıdır. Kart fiyatında özellikle **en yüksek iki puan** daha ağır basar. Fabrika ölçeği adayların gücünü ve erişimini sınırlar.

**Neden:** Danışmanlar farklı bilgi açıklarını kapatmalı; çok güçlü ve geniş profiller ucuz, sürekli kullanılan bir kariyer ikamesine dönüşmemelidir. Kart bütçesi en yüksek puanı ve kapsamı birlikte sınırlar.

### 2. Ay sonu adayları ve ücretli çekim sınırı

**Ne:** Ay sonu raporundan sonra **üç ücretsiz aday** gösterilir. Oyuncu rastgele bir **dördüncü kartı** oyun parası **veya** gerçek paradan biriyle açabilir. İkinci ücretli çekim **beşinci kartı getirir ve dördüncü kartın yerini alır**; ayda en fazla iki ücretli çekim olur. Dördüncü kartın oyuncunun görünen bilgi açığını kapatan bir alan taşıma olasılığı, normal çekime göre **10 yüzde puan daha yüksektir**. Aday seçiminde patronun puanları, oyuncuya görünen departman kayıpları ve fabrika ölçeği kullanılabilir; **gizli kök neden kullanılmaz**. Aynı profil sonraki aylarda tekrar görünebilir, fakat hâlen çalışan danışman aday havuzuna girmez.

**Neden:** Raporu gören oyuncu sınırlı ve anlamlı seçeneklerden danışman seçebilmeli; ücretli çekim küçük bir uygunluk avantajı verebilir ama sınırsız yeniden çevirme veya gizli sorun bilgisini karttan öğrenme yolu olmamalıdır.

### 3. Sözleşme ve aktif danışman sayısı

**Ne:** Aynı anda **en fazla iki danışman** çalışır. Sözleşme imzalandığı anda başlar; profilin bütün alan puanları süresi boyunca aktiftir. Ödenen ücret erken ayrılmada iade edilmez. Sözleşme yalnızca **ilk yarısında** uzatılabilir; uzatma aylık aday çekiminden ayrıdır. Süresi biten profilin yeniden bulunması garanti değildir. Danışmanın bütün etkileri bitişte sona erer.

**Neden:** Oyuncu rapordan sonra acil bilgi açığını hemen kapatabilmeli, fakat süreli ve pahalı danışman kararı bağlayıcı olmalıdır. İki kart ve ilk yarıdaki uzatma sınırı sürekli sınırsız uzman erişimini önler.

### 4. Fabrika sorunlarına etkisi ve ödeme yolu

**Ne:** FRZ-001 uyarınca etkin alan yetkinliği **`max(patron, aktif danışmanlar)`** olur; puanlar toplanmaz ve patrona kalıcı aktarılmaz. Danışman görünürlük ve kesin Düzelt eşiğine katkı sağlayabilir, patron zamanını azaltabilir; **kökü düzeltmenin oyun parası bedelini düşürmez**. Sözleşme ücreti karar anında FRZ-002 v3'ün kasa sırasına göre ödenir. Aynı danışman teklifi oyun parasıyla da alınabilir; gerçek para bir sorunu çözmek için zorunlu değildir. Danışmanın İnsan Yönetimi puanı, FRZ-005'teki patrona özgü genel kişi sorunu önleme etkisini sağlamaz.

**Neden:** Danışman ücretinin karşılığı gerçek bilgi ve zaman desteği olmalı; gerçek para veya çoklu danışman birikimi zorunlu ya da sınırsız çözüm yaratmamalıdır. Patronun kariyerde öğrendiği yetkinlik kalıcı üstünlük olarak kalır.

## Reddedilen yollar

- Patron ve danışman puanlarını toplamak; FRZ-001'in 100 puan sınırını aşar.
- Aktif danışmanı yeni aday olarak göstermek; aday hakkını boşa harcar.
- Aylık sınırsız ücretli kart çekimine izin vermek; en iyi adayı garantilemeye yaklaşır.
- Gizli kök nedenleri aday hedeflemesinde kullanmak; görünmeyen Tier/kök bilgisini kart listesinden sızdırır.
- Danışman analizinden sonra ayrı bir “dinle/dinleme” veya güven/uyum mekaniği açmak; kullanıcının seçtiği tek Düzelt akışını genişletir.

## Açık denge ve uygulama ayrıntıları

- Profil havuzunun ilk sayısı için **10–15**, sözleşme için **1/3/12 ay** ve ücret için **A/2,75A/10A** önceki örneklerdir; kesin fiyat ve süre değildir. Bir aylık sözleşmenin ilk yarı uzatma kuralıyla nasıl bağdaşacağı ayrıca belirlenir.
- +10 yüzde puan uygunluk hesabının ve ölçeğe göre profil seçiminin tam yöntemi, güçlü kartların nadirliği, sözleşme uzatma bedeli ve küçük fabrika kârına göre ücret dengesi test edilir.
- Gerçek parayla rastgele kart çekiminin sunumu, oyun parasıyla makul erişim ve monetizasyon sınırları ayrı değerlendirilir; bu FREEZE fiyat veya dış platform kuralları hakkında karar vermez.
