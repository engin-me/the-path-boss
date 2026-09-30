# IDEA-012 — Erken Dönem ve Teklif Havuzu

## Durum/Tur

Durum: DRAFT — Claude Tur 1 notları yazıldı; kullanıcı kararı bekleniyor; FREEZE değildir.
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

Tur 1 · 2026-09-30 · Ölçüm: `godot/` patron testi, 100 tohum, %5 büyüme açık (FRZ-002 v4 taslağı), diğer kurallar CURRENT. Sayılar prototip girdisidir; denge kararı değildir. Anahtarlar `persona_run.gd` içinde: `pool=K:M`, `buffer=N`, `early=N`, `growth=r` (varsayılanlar eski davranışı korur, `exp=etiket` raporlara dokunmaz).

### Aldığım Notlar

- Teşhis doğru: Erken Kurucu (A×2, kasa 300) 6/94 (ayakta/iflas); ilk üç ayda kabul edilen iş kapasitenin yalnız %53'ü, 300 ayın 38'inde hiç iş alınamıyor. Sebep sorun büyümesi değil teklif üretimi: kalite 1–3 park bakılmadan eşit çekiliyor, yalnız Q1 üretebilen parka Q2/Q3 teklifleri işe yaramıyor (beklenen kullanılabilir teklif ≈ 5×⅓).
- İlk ayın para güvencesi çalışıyor: ölçülen sekiz karakterin hiçbirinde ay 1'de gizli Düzelt para nedeniyle engellenmedi. **Patron saati hiç engel olmadı** (0 ay; aylık kullanım ortalama 1–8 saat, azami 27/40).
- Danışmansız gizli deneme ilk üç ayda Erken Kurucu için: 269 gizli satırlı ayın 183'ünde (%68) mümkün, 86'sı yalnız paradan engelli (ay 2: 37, ay 3: 49); tohum bazında 67/100'de en az bir ay engelli.

### Bulduğum Sakıncalar

1. **"Erken dönem" çerçevesi yetersiz: sorun yapısal.** Havuz taban kuralı yalnız ilk 3 ay uygulanırsa Erken Kurucu 25/75, ilk 6 ay 51/49; her ay uygulanırsa 87/13. Erken aylar sonrası eski havuzla A×2 yine çöküyor. Kural "ilk üç ay" değil "her ay, çalışabilir parka uyumlu asgari teklif payı" olmalı.
2. **Tam iş = yalnız kalite değil, miktar da.** Prototipte miktar 15–45; tek A tezgâhı (kapasite 40) için 45'lik teklif "uyumlu" görünür ama alınamaz. Uyumluluk tanımı FRZ-004'e uyup kalite + kapasite içinde miktarı da kapsamalı.
3. **Pazar riski silinmiyor ama daralıyor.** 5 tekliften 3'ü parka uyumlu çekilince fiyat/miktar rastgeleliği duruyor, 2 teklif serbest; doluluk %53→%86 (Q1 teklif fiyatları değişmedi). Riski istemiyorsanız pay 2 ile 3 arasında oynar (aşağıdaki tablo).
4. **FRZ-003 v2 potansiyeli teklif geçmişinden hesaplanıyor.** Havuz A parkına Q1 ağırlıklı kayarsa geçmişte Q2 marjı ölçülmez ve varsayılan marj devreye girer; makine alım anındaki azami kâr tahmini bu yüzden oynar. Havuz kuralı geçmiş penceresine nasıl yazılacağı kararlaştırılmalı.
5. **Makine kalitesi hâlâ baskın.** Taban kuralıyla bile sıra A×2 < A+B < B×2 (Dengeli net kasa −123 / 103 / 258). Bu IDEA-012'nin işi değil (FRZ-004 fiyat/kapasite/marj); ama "çeşitlilik peşinen kazanan değil" ilkesi için ayrıca bakılmalı.
6. **Para güvencesinde tampon knife-edge.** Kuruluşta 2 ayın gideri ayrılırsa Erken Kurucu (300, A×2) açılamıyor (gereken 2×54+35=143, makineden sonra 140): 100/100 açılamadı. Tampon kural eşiği sayıya aşırı duyarlı, geç kuruluşu cezalandırır.

### Kafama Yatmayanlar

- "Yalnız para engeli" kısmen oyuncunun kendi harcaması: ay 2–3'te Düzelt ve gider kasayı eritince güvence (üst bedel 35) sağlanamıyor. Bu, güvencenin çalıştığının işareti; FRZ-001 §6 testini "her ay %100 mümkün" diye okumak bunu sahte bir garantiye çevirir.
- Erken dönem sınırlı finansman yolu (önerideki 2. yol) kredi/borç istismarı riski taşıyor; ölçümde gerekli olmadı, önermiyorum.

### Ölçümler (100 tohum, %5 büyüme, kendi makine parkı)

| Kural | Erken Kurucu | Teknik Usta | İnsan Yön. | Dengeli |
| --- | --- | --- | --- | --- |
| Mevcut (havuz kuralı yok) | 6/94 | 46/54 | 41/59 | 100/0 |
| Taban 3/5, ilk 3 ay | 25/75 | 92/8 | 58/42 | 100/0 |
| Taban 3/5, ilk 6 ay | 51/49 | 97/3 | 80/20 | 100/0 |
| Taban 1/5, her ay | 31/69 | 94/6 | 78/22 | 100/0 |
| Taban 2/5, her ay | 70/30 | 100/0 | 91/9 | 100/0 |
| **Taban 3/5, her ay** | **87/13** | 100/0 | 94/6 | 100/0 |
| Taban 4/5, her ay | 88/12 | 100/0 | 98/2 | 100/0 |
| Taban 3/5, her ay, büyüme kapalı | 95/5 | 100/0 | 98/2 | 100/0 |

- Aynı park herkese (A×2, taban 0→3/5 her ay): Dengeli 22→86 ayakta, Temkinli 23→93, Kör Tamirci 46→100. A+B ve B×2 zaten 100/100 ayakta, yalnız net kasa artıyor (A+B Dengeli 22→103, B×2 126→258).
- Tek A tezgâhı (A×1): taban kuralı Teknik Usta'yı 65→90 ayağa kaldırıyor, Dengeli ve İnsan Yöneticisi 0/100 kalıyor (bkz. IDEA-013: tek makine kendi sabit giderini karşılamıyor).
- Büyümenin tek başına bedeli, taban kuralıyla: Erken Kurucu 95→87 ayakta; diğerleri değişmedi.
- Para tarafı (taban 3/5 her ay): Erken Kurucu gizli satırlı 272 ayın 245'inde (%90) danışmansız deneme mümkün, 27'si para engelli (ay 2: 8, ay 3: 19), saat engeli 0. `early=3` (ilk 3 ayda kabul edilmiş iş maliyetini Düzelt güvencesinden ayırmamak): 268/272 (%98), engelli tohum 21→4, hayatta kalma 87→88 (fark yok).

### Önerilen en basit sınama (100 tohum)

1. **Havuz:** her ay 5 tekliften **3'ü** çalışabilir parkın üretebildiği kalite ve kapasiteye sığan miktarda çekilir (`pool=3:99`); kalan 2 serbest. Aynı tohumlarda A×2, A+B, B×2 (B×2 için kasa 400) ve A×1 koşulur.
2. **Para:** kural değiştirme. Tampon (`buffer`) ve finansman yolu denenmedi/önerilmiyor. FRZ-001 §6 testini "ay 1'de gizli satır varsa danışmansız Düzelt mümkün (%100); ay 2–3'te gizli satırlı ayların en az %90'ında mümkün, engel oyuncunun kendi harcamasından geliyorsa kabul" biçiminde ölçülebilir hâle getirin. Daha sıkı istenirse tek küçük istisna: ilk 3 ayda kabul edilmiş iş maliyeti güvenceden düşülmez (`early=3`); borç istismarı yolu yok çünkü gelir aynı ay içinde iş teslimiyle geliyor, ama yapay istisna sayılır ve kullanıcı kararı gerektirir.
3. **Kabul ölçütü:** Erken Kurucu ≥ %80 ayakta (ölçülen 87), Teknik Usta ve İnsan Yöneticisi ≥ %90, A×2 ile B×2 arasındaki net kasa farkının kapanmadığı (ölçülen fark sürüyor) ve işsiz ay sayısının 0'a yakın olduğu doğrulansın; FRZ-002 v4 ancak bu sonuçla birlikte CURRENT olur.

### Açık Sorular

1. Havuz kuralı her ay mı (önerim, ölçüm bunu gösteriyor) yoksa yalnız erken aylarda mı geçerli olsun? İkincisi Erken Kurucu'yu kurtarmıyor (25/75).
2. Asgari pay 2/5 mi (%70 ayakta) 3/5 mi (%87)? Pazar riski iştahı ile tolerans arasında kullanıcı kararı.
3. FRZ-001 §6 kabul testi "mümkün" mü yoksa "%90+ mümkün" mü okunacak; `early=3` istisnası kabul edilir mi?
4. Makine kalitesinin baskınlığı (A×2 < A+B < B×2) ayrı bir FRZ-004 denge turuna mı taşınacak?

## Açık Kararlar

- Aylık listede parka uygun asgari tam iş sayısı/payının değeri ve bunun kaç ay geçerli olacağı.
- İlk üç ay para/saat müdahale erişimini sağlayan yöntem ve kuruluş kasası kuralına etkisi.
- FRZ-002 v4 büyümesinin hangi erken dönem çözümüyle aynı anda CURRENT yapılacağı.
- A×2, A+B ve B×B parklarıyla ve 100 tohumla yeniden ölçüm.

## Karar Özeti

- Kullanıcı FRZ-002 v4 sorun büyümesini tek başına dondurmak yerine erken dönem teklif ve kasa erişimiyle birlikte karara bağlamayı onayladı; çünkü büyüme zaten kırılgan fabrikaların iflasını artırırken sorun büyüme olmadan da görülüyor.
- Kullanıcı erken dönem ve teklif havuzu için ayrı IDEA açılmasını onayladı; çünkü FRZ-001'in ilk üç ay gizli deneme testi ile FRZ-004'ün alınabilir iş seçimi birlikte çalışmalı.
