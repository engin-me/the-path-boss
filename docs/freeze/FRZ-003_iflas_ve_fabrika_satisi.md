# FRZ-003 — İflas, Tasfiye ve Fabrika Satışı

Status: CURRENT
Date: 2026-09-29
Source: [IDEA-003](../ideas/IDEA-003_iflas_ve_yeniden_baslangic.md), Tur 4; Claude Tur 3 incelemesi ve kullanıcı onayı.
Depends on: [FRZ-001](FRZ-001_patron_yetkinlikleri.md), [FRZ-002 v2](FRZ-002_v2_fabrika_ekonomisi.md).

## Onaylanan Kararlar

### 1. Altı aylık kurtarma gücü ve zorunlu kapanış

**Ne:** Her ay sonunda `borç açığı = max(0, şirket kredisi bakiyesi − kasa)` ve `azami net katkı = max(0, azami aylık brüt kâr − aylık olağan giderler)` hesaplanır. `yatırım değeri`, makine ve diğer satılabilir yatırımların toplam referans değeridir. **Zorunlu kapanış yalnızca `borç açığı > 0,50 × yatırım değeri + 6 × azami net katkı` olduğunda tetiklenir.** Eşitlik kapanış değildir. Azami brüt kâr, son ayın fiili kârı değil; mevcut makine kapasitesi/niteliği ve alınabilir iş havuzunun yakın dönem ortalamasına dayalı potansiyeldir. İş havuzu etkisi yalnızca ay sonunda güncellenir. Eşik yaklaşırken oyuncu açık uyarı görür.

**Neden:** Varlıkların zorunlu satış geliri ve en iyi koşullarda altı ayda borca ayrılabilecek para birlikte kurtarma gücünü gösterir. Tek kötü ay, geçici iş dalgalanması veya kriz kredisi geliri iflas hesabını tek başına yanıltmamalıdır.

### 2. Kriz seçenekleri ve görünür risk

**Ne:** Eşik aşılmadan makine/varlık satışı ve tek seferlik kriz kredisi değerlendirilebilir. Kredi kasayı ve şirket kredi bakiyesini aynı tutarda artırır; net pozisyonu tek başına iyileştirmez. Makine satışının onay ekranı **satış sonrası borç açığını, kaybedilen kapasiteyi ve yeni iflas eşiğini** gösterir. Satış, potansiyeli azaltarak zorunlu kapanışı öne de çekebilir. Eksi şirket net pozisyonuna küçük, önceden görünen aylık finansman gideri uygulanır. İflas sonrası kişisel borca bu gider/faiz uygulanmaz. FRZ-001/FRZ-002 v2'nin Düzelt para ve zaman güvencesi korunur.

**Neden:** Oyuncu ne nakit getirisi yüzünden yanlış bir satışı güvenli sanmalı ne de krediyle yapay biçimde eşiğin uzağına kaçabilmelidir. Görünen küçük finansman maliyeti, müdahale olanağı kalmamış fabrikanın süresiz beklemesini önler.

### 3. Gönüllü tasfiye, zorunlu tasfiye ve borç sınırı

**Ne:** Oyuncu, zorunlu kapanıştan önce yatırımlarını gönüllü olarak satıp fabrikayı kapatabilir. İlk fiyatlama kuralı, varlıkların referans değerinin **%70'i gönüllü satışta**, **%50'si zorunlu tasfiyede** elde edilmesidir. Yatırım ekranı yatırılmış toplamı, bu ay sonundaki tahmini varlık/fabrika satış değerini, şirket borçlarını ve karaktere kalacak net tutarı ayrı gösterir. Gönüllü veya zorunlu kapanışta satış geliri ve şirket kasası önce şirket borçlarını kapatır. **Kapanış sonunda açık yoksa iflas sonuçları uygulanmaz**; zorunlu kapanışta oyuncunun bedeli düşük tasfiye değeridir. Açık kalırsa iflas sonuçları uygulanır. Şirketten karaktere para aktarımı yalnızca **borçlar kapatılmış gönüllü tasfiye veya devir** kapanışında mümkündür; net pozisyon eksiyken kişisel çekim yapılamaz.

**Neden:** Kötü gidişi erken gören oyuncu daha değerli satış yapabilmeli; bütün borcunu ödeyen oyuncu iflas cezası almamalıdır. Kişisel çekim sınırı, kriz kredisi alıp parayı karaktere aktarma ve şirket borcunu kişisel tavanın üstünde bırakma istismarını kapatır.

### 4. Başarılı fabrikanın çalışır işletme olarak devri

**Ne:** Oyuncu kârlı fabrikasını çalışır işletme olarak satıp net geliri yeni fabrika sermayesi yapabilir. Değerleme makine değerine ek olarak **yeterli faaliyet geçmişinde kanıtlanmış, mevcut sorunların kayıpları düşülmüş gerçekleşen kârı** ve iş alma kapasitesini dikkate alır. Satış değeri **aynı fabrikayı yeniden kurma bedelini aşmaz**; şirket borçları satış hesabından düşülür. Yeni fabrikanın üretim başlamadan bir hazırlık süresi vardır ve FRZ-002'nin kuruluş kasası şartı uygulanır. Sorun oluşumu fabrikanın yaşına değil ölçeğine bağlı tasarlanır. Borçsuz devir iflasın psikoloji ve “acı tecrübe” sonuçlarını tetiklemez.

**Neden:** Başarılı işletmeyi sermayeye çevirmek yeni bir büyüme yolu sunar; gerçekleşmiş kâr ve hazırlık bedeli, sorunlu fabrikayı primle satıp temiz fabrikayı anında kurma döngüsünü önler.

### 5. İflas sonrası karakter ve öğrenme

**Ne:** Şirket borcu ile kişisel borç ayrıdır. Zorunlu tasfiye gelirinden sonra kalan açığın karaktere geçen kısmı, beklenen çalışan gelirinin sabit bir yüzdesiyle **yaklaşık bir oyun yılında** ödenebilecek tavanla sınırlanır. Aynı karakter çalışanlık kariyerine döner; yetkinlikleri ve mevcut statları silinmez. Taksit çalışan gelirinin sabit yüzdesidir, işsiz ayda durur, kişisel borca faiz işlemez. Kişisel iflas borcu bitmeden yeni fabrika kurulamaz. İflas kaynaklı psikoloji düşüşü zamanla kendiliğinden iyileşir ve işten çıkarılma bu özel iyileşmeyi geriye sarmaz. Yaklaşık %25 psikoloji farkı denge örneğidir. Karakter başına bir kez, en çok kayba neden olan alanda küçük ve sınırlı “acı tecrübe” yetkinlik artışı olur; genel stat kazanım hızı artmaz.

**Neden:** İflas zaman, sermaye ve psikoloji bedeli yaratmalı; fakat büyük bir fabrikanın borcu sonraki kariyeri kalıcı olarak kilitlememeli. Öğrenme ödülü, kasıtlı tekrarlı iflasla puan toplama yoluna dönüşmemelidir.

### 6. Kapanış raporu

**Ne:** İflas raporu fabrika ömrünü, en büyük kayıp alanlarını, görülen/gizli sorunları ve ihmal edilmiş uyarıları gösterir. Gizli kökler alan, Tier, kök neden, toplam kayıp ve kesin teşhis/çözüm için gereken yetkinlikle tam açıklanır. Rapor karakterin mevcut puanını kendiliğinden artırmaz; sonraki fabrikanın sorunları yeniden oluşur.

**Neden:** Oyuncu başarısızlıktan sonraki kariyerinde hangi bilgiyi öğrenmesi veya hangi desteği araması gerektiğini anlamalıdır.

## Sınırlar ve ertelenen denge

- Yatırım referans değerinin yöntemi, alınabilir iş havuzu ortalamasının penceresi, finansman giderinin oranı, kişisel borç tavanının maaş varsayımı ve devir priminin faaliyet süresi İş Alma/yatırım dengesiyle belirlenecektir.
- Makine markaları, ihale şartları, kredi tutarı ve yeni fabrikanın hazırlık süresinin sayısal uzunluğu ayrıca tasarlanır. Karakterin yaşlanması/ölümü ayrı çekirdek döngü kararıdır.
- FRZ-002 v2 ile birlikte yürürlüğe girer; önceki FRZ-002 tarihsel kayıttır.
