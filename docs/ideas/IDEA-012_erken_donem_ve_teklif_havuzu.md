# IDEA-012 — Erken Dönem ve Teklif Havuzu

## Durum/Tur

Durum: DRAFT — Claude incelemesi ve kullanıcı kararları bekleniyor; FREEZE değildir.
Tur: 1
Tarih: 2026-09-30
Bağımlılıklar: [FRZ-001 v2](../freeze/FRZ-001_v2_patron_yetkinlikleri.md) §6, [FRZ-002 v3](../freeze/FRZ-002_v3_fabrika_ekonomisi.md) §3–4, [FRZ-003 v2](../freeze/FRZ-003_v2_iflas_ve_fabrika_satisi.md) §1, [FRZ-004](../freeze/FRZ-004_is_alma_ve_makine_yatirimlari.md) §1–5. [IDEA-010](IDEA-010_sorun_buyumesi.md) ile birlikte değerlendirilecek.
Test kaynakları: [Claude bulguları](../../godot/playtests/claude_bulgular.md), [Erken Kurucu ay raporu](../../godot/playtests/reports/05_erken_kurucu.md) ve [100 tohum özeti](../../godot/playtests/reports/_ozet.md). Bunlar prototip gözlemleridir, oyun kuralı değildir.

## Öneri (GPT)

### Sorun

Yalnız A tipi iki tezgâhı olan Erken Kurucu, sorun büyümesi kapalıyken 100 tohumun 89'unda, %5 büyüme açıkken 94'ünde iflas ediyor. Ayrıntılı raporda 2., 5. ve 6. aylardaki iş hedefi sırasıyla 20 / 0 / 20. Tekliflerin parkla uyumsuz gelmesi bazı aylarda alınabilir tam işi sıfırlıyor. Kuruluş kasası kuralı ilk ayın giderini ve gizli müdahalenin üst güvencesini karşılıyor, ancak sonraki aylarda bilinen giderler ve iş maliyetleri ayrılınca Düzelt için kullanılabilir para kalmayabiliyor. FRZ-001 v2 §6'nın ilk üç ay danışmansız gizli sorun deneyebilme kabul testi fiilen tutmayabiliyor.

Bu iki açık kapatılmadan sorun büyümesini CURRENT yapmak, farklı erken kuruluş stratejilerini aynı iflas zincirine sürükleyebilir. Amaç erken fabrikanın iflasını kaldırmak değil; iş seçimi, yatırım ve nakit rezervinin sonucu değiştirmesini sağlamaktır.

### Teklif havuzu için öneri

İlk ayların teklif üretiminde, mevcut **çalışabilir** makine parkıyla gerçekten alınabilecek en az bir **tam iş** bulunması ve parka uygun tekliflerin aylık listenin belirli bir asgari payını oluşturması test edilsin. Uygunluk, FRZ-004'teki makine niteliği, kapasite, teslim süresi ve bilinen iş maliyetlerini dikkate alır. Gelecek yatırım isteyen teklifler görünmeye devam eder, fakat bu ayın alınabilir iş havuzuna ve FRZ-003 iflas potansiyeline uygun değilse katılmaz.

Asgari teklif sayısı/payının kesin değeri A×2, A+B ve B×B parklarıyla aynı tohumlarda ölçülür. Makine teslim/kurulum nedeniyle henüz faal değilse işe uygun teklif garantisi, üretilmeyecek işe gelir yazmaz. Talep riski tümden kaldırılmaz; ilk üç ayda yalnız parkla ilgisiz rastgele teklifler yüzünden işsiz kalma sınanır.

### Nakit güvencesi için öneri

FRZ-002 v3'ün kuruluş anı kasası ile FRZ-001 v2'nin **ilk üç ayın her birinde** gizli deneme erişimi farklı koşullardır. Her ayın karar anında bilinen olağan giderler, kabul edilmiş işin ödenecek maliyeti ve vadesi gelen finansman ayrıldıktan sonra, en az bir gizli satırın oluşum ölçeğine bağlı para ve saat üst güvencesinin karşılanıp karşılanmadığı kaydedilsin.

İki çözüm yolu karşılaştırılsın:

1. **Başlangıç tamponu:** Kuruluş için gereken serbest nakit, ilk üç ayın olası gider ve tek gizli müdahale yükünü karşılayacak düzeye çıkarılır. Bedeli: erken fabrika daha geç mümkün olabilir.
2. **Erken dönem erişimi:** İlk üç ay küçük ölçeğin sorun derinliği, üst güvence veya sınırlı finansman yolu ayarlanır. Bedeli: yapay istisna ya da borç istismarı oluşabilir.

Bu turda hiçbir yol kesinleşmez. Henüz gerçekleşmemiş iş gelirini veya bilinen gider için ayrılmış parayı güvence sayma önerilmez. Patron saati de aynı kabul testine dahildir.

### Kabul testi ve Claude incelemesi

- Aynı Erken Kurucu ve tohumlarla büyüme kapalı/açık karşılaştırılır; ilk üç ayda gizli satır varsa en az bir danışmansız denemenin para **ve** saat açısından mümkün olup olmadığı raporlanır.
- Uygun teklif sayısı, kabul edilen iş hedefi, boş kapasite, nakit nedeniyle engellenen Düzelt, borç açığı ve kapanış nedeni ay ay gösterilir.
- Agresif yatırım, temkinli yatırım ve yüksek nakit rezervi politikaları aynı koşullarda karşılaştırılır. Hangisinin hangi koşulda yaşadığı ölçülür.
- Teklif havuzu değişirse FRZ-003 v2'nin alınabilir iş ortalaması ve azami kâr potansiyeli yalnız ay sonunda yeniden hesaplanır.
- Claude, asgari uygun teklifin pazar riskini silip silmediğini, başlangıç tamponunun erken kuruluşu fazla geciktirip geciktirmediğini ve sınırlı finansmanın istismar yolunu inceler.

## Notlar (Claude)

Tur 1 incelemesi bekleniyor. Önceki oyun testi bulguları yukarıdaki kaynaklarda; bu dosyadaki öneriler henüz incelenmedi.

## Açık Kararlar

- Aylık listede parka uygun asgari tam iş sayısı/payının değeri ve bunun kaç ay geçerli olacağı.
- İlk üç ay para/saat müdahale erişimini sağlayan yöntem ve kuruluş kasası kuralına etkisi.
- FRZ-002 v4 büyümesinin hangi erken dönem çözümüyle aynı anda CURRENT yapılacağı.
- A×2, A+B ve B×B parklarıyla ve 100 tohumla yeniden ölçüm.

## Karar Özeti

- Kullanıcı FRZ-002 v4 sorun büyümesini tek başına dondurmak yerine erken dönem teklif ve kasa erişimiyle birlikte karara bağlamayı onayladı; çünkü büyüme zaten kırılgan fabrikaların iflasını artırırken sorun büyüme olmadan da görülüyor.
- Kullanıcı erken dönem ve teklif havuzu için ayrı IDEA açılmasını onayladı; çünkü FRZ-001'in ilk üç ay gizli deneme testi ile FRZ-004'ün alınabilir iş seçimi birlikte çalışmalı.
