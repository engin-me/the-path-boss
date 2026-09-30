# IDEA-014 — Patron Operatörlüğünün Aylık Zaman Payı

## Durum/Tur

Durum: DRAFT — Claude Tur 1 incelemesi yazıldı; Codex sentezi ve kullanıcı kararı bekleniyor. [FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md) CURRENT kalır; bu IDEA henüz oyun kuralı değildir.
Tur: 1
Tarih: 2026-09-30
Bağımlılıklar: [FRZ-001 v3](../freeze/FRZ-001_v3_patron_yetkinlikleri.md), [FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md).

## Öneri (GPT)

FRZ-008 v2'deki sabit **8 saat/ay** operatörlük bedeli, patronun o ayki **toplam yönetim saatinin yarısı** olarak değişsin. Patron operatörlük yapmıyorsa bu kesinti olmasın. Operatörlük yalnız ilk makinenin tek vardiyasındaki personel ihtiyacını karşılasın; ilave üretim veya OEE bonusu yaratmasın. Gizli Düzelt için FRZ-001 v3'ün azami saat güvencesi ve erken dönem erişim kabul testi korunmalı.

Mevcut patron prototipinde aylık toplam 40 saattir: operatörlük 20 saat tüketir, başka eylem yoksa yönetim için 20 saat kalır. Küçük ölçekte gizli T3 tavanı 8 saattir; prototipin en derin T5 tavanı 16 saattir. Bu nedenle 40 saatlik örnekte tek bir gizli Düzelt güvencesi saat bakımından korunur. Bu sayılar prototip girdisidir; aylık toplam 40 saat bu IDEA ile dondurulmaz. İleride seçilecek toplam saat veya saat bantları bu güvenceyi bozarsa ayrıca dengelenmelidir.

Değişikliğin gerekçesi: operatörlük ilk fabrika ayında patronun yönetim kapasitesinde belirgin bir fırsat maliyeti yaratsın; sabit 8 saat, toplam zaman değiştiğinde bu maliyeti aynı oranda taşımıyor. Tek makinenin kârlılığı hâlâ alınan iş ve giderlere bağlıdır.

Claude incelemesinde özellikle yarım zamanın FRZ-001 v3 erişim testiyle, farklı fabrika ölçekleriyle ve ilerideki toplam saat kararlarıyla uyumu sınansın. Prototipte 40 saatlik örnek için 8 ve 20 saatlik operatörlük koşulları karşılaştırılabilir; maaş ve kira henüz modellenmediğinden ekonomik sonuç bu testten çıkarılamaz.

## Notlar (Claude)

Tur 1 · 2026-09-30 · Ölçüm: `godot/` patron testi, her yapılandırma 100 tohum × 8 karakter × 12 ay (9 600 ay), %5 büyüme ve taban 3/5 teklif kuralı açık. Orta ve Büyük ölçeği görmek için her karaktere aynı makine parkı (A×1 Küçük, A×3 Orta, A×5 Büyük), 5 000 başlangıç parası ve gerekince farklı aylık toplam saat verildi; para engelini ve toplam saati ayrıştırmak için geçici kopyada yapıldı, depoya işlenmedi. Sayılar prototip girdisidir; aylık toplam 40 saat onaylı kural değildir ve denge kararı değildir. Maaş, kira ve vardiya prototipte yok.

### Aldığım Notlar

- Öneri yalnız [FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md) §3'ün bedelini (sabit 8 saat → toplamın yarısı) değiştiriyor. [FRZ-001 v3](../freeze/FRZ-001_v3_patron_yetkinlikleri.md) güvencesine ve erken erişim testine dokunmuyor; onlara uyumu koruma şartı doğru konmuş.
- Güvencenin saat tarafı kodda şöyle çalışıyor: gizli satırın "en fazla saat"i, satırın doğduğu ölçek sınıfının en derin Tier tavanıdır. Küçük T3 = 8, Orta T4 = 12, Büyük T5 = 16 saat (danışmanlı departmanda ×0,7 ile yaklaşık 6/8/11). Deneme, kalan patron saati bu tavanın altına düşmediği sürece başlar.
- **40 saatte yarım zaman güvenceyi bozmuyor.** Operatörlük 20 saat tüketince kalan 20 saat üç ölçekte de tavanın üstünde. Ay başında "en az bir gizli satır denenebilir mi" ölçümü (FRZ-001 v3 §6'nın ölçtüğü şey):

  | Park (ölçek, gizli tavan) | Gizli satırlı ay | Saat engeli: 0 sa / 8 sa / 20 sa operatörlük | Ort. Düzelt denemesi (0 / 8 / 20 sa) | Operatörsüz ay sayısı, patron > 20 sa kullanmış |
  | --- | ---: | :---: | :---: | ---: |
  | A×1 Küçük (8 sa) | 1 540 | 0 / 0 / 0 | 15,9 / 15,9 / 15,9 | 11 / 9 600 |
  | A×3 Orta (12 sa) | 1 819 | 0 / 0 / 0 | 28,3 / 27,7 / 24,8 | 645 / 9 600 |
  | A×5 Büyük (16 sa) | 1 990 – 1 993 | 0 / 0 / 0 | 37,6 / 35,3 / 29,5 | 1 508 / 9 600 |

- Erken dönem: fabrika Küçük ölçekte açılır; 20 saat kalan, tavan 8 saatin çok üstündedir. Önceki IDEA-013 ölçümünde 24 saatlik operatörlükte de saat engeli 0 çıkmıştı; 20 saat bu ölçümle de tutarlıdır. FRZ-001 v3 §6'nın saat tarafı 40 saatte kırılmıyor.

### Bulduğum Sakıncalar

1. **Oran kuralı güvenceyi kendiliğinden korumuyor; koruma toplam saate bağlı.** Kalan saat tavana yetmek için toplam saat ≥ 2 × tavan olmalı: Küçük 16, Orta 24, Büyük 32. Eşiğin bir saat altında gizli Düzelt tamamen kapanıyor, kademe yok:

  | Toplam / operatörlük | Ölçek (tavan) | Kalan | Saat engeli / gizli satırlı ay |
  | --- | --- | ---: | ---: |
  | 16 / 8 | Küçük (8) | 8 | 0 / 1 579 |
  | 14 / 7 | Küçük (8) | 7 | 1 578 / 1 629 |
  | 24 / 12 | Orta (12) | 12 | 0 / 1 826 |
  | 22 / 11 | Orta (12) | 11 | 1 726 / 1 834 |
  | 32 / 16 | Büyük (16) | 16 | 0 / 1 995 |
  | 30 / 15 | Büyük (16) | 15 | 1 790 / 2 002 |

  Eşiğin altında FRZ-001 v3 §6'daki "ilk ay %100" testi de kırılır. 40 saatte marj Küçük'te 12, Orta'da 8, Büyük'te yalnız 4 saat. Toplam saat 36'ya inerse Büyük'te marj 2'ye, 32'de 0'a düşer.
2. **Tek sayılı toplamda yuvarlama yönü güvenceyi açıp kapatıyor.** Toplam 31 saat, Büyük ölçek: operatörlük aşağı yuvarlanıp 15 olursa (kalan 16) saat engeli 0 / 1 995; yukarı yuvarlanıp 16 olursa (kalan 15) 1 790 / 2 002. Etki yalnız eşiğin hemen altındaki tek toplamlarda (15, 23, 31) görülür, ama orada tek saat tüm güvenceyi kapatıyor. Prototipte saatler tam sayıdır (`hours_left`, saat bantları), kesirli saat gerekmiyor. **Öneri:** operatörlük ⌊toplam/2⌋, yönetimde kalan ⌈toplam/2⌉ olsun; yani fazla saat her zaman yönetimde kalsın.
3. **"O ayki toplam yönetim saati" iki biçimde okunabilir.** (a) Ay başındaki toplam (40) veya (b) o ana kadar Düzelt vb. harcamalardan sonra kalan saat. (b) sıra oyunudur: önce Düzelt, sonra operatörlüğü kalanın yarısıyla seç → ucuz operatörlük, baskın strateji; ayrıca FRZ-001'in "o ay kalan saat" güvencesiyle çelişir. Kod ay başında düşüyor (`hours_left = MONTHLY_HOURS − operator_hours`); kural da bu okunuşu yazmalı: ay başındaki toplam, ay başında kesilir, ay içinde değişmez.
4. **Fırsat maliyeti ölçekle beklenen yönün tersine işliyor.** Amaç "ilk fabrika ayında belirgin yönetim maliyeti" idi. Küçük ölçekte (ücret tasarrufunun en çok işe yaradığı yerde) operatörsüz patron 9 600 ayın yalnız 11'inde 20 saatten fazla kullanmış; yani 20 saat 8 saat kadar bedelsiz (Düzelt denemesi 15,9 → 15,9). Maliyet Orta'da (645 ay) ve Büyük'te (1 508 ay) hissediliyor; yoğun Düzelt kullanan Finansçı Kumarbaz ve Kör Tamirci Büyük'te ayda ortalama ~21 saat harcıyor ve 20 saat sınırıyla Düzelt denemeleri yarıya yakın azalıyor (Finansçı: 65,7 → 38,2). Sonuç: yarım zaman Küçük'te ucuz, Büyük'te pahalı. Büyükte pahalı olması, tasarruf küçük olduğundan operatörlüğü doğal olarak eler; bu "fabrika kurmak yeni faz" vizyonuyla uyumlu olabilir, ama bilinçli tasarım olarak karara bağlanmalı.
5. **Prototipte fırsat maliyeti henüz zarar olarak görünmüyor.** A×5'te ortalama son net kasa 2 451 → 2 527 → 2 731 (0 / 8 / 20 saat): daha az Düzelt daha çok nakit demek, çünkü 12 aylık pencerede sorun büyümesi tavanlı, maaş/kira yok ve başlangıç parası yüksek (5 000). Bu, yarım zamanın "maliyetsiz" olduğunu kanıtlamaz; maaş, kira ve iş gelirleri eklenince tekrar ölçülmeden fırsat maliyetinin gerçekten oyuncuyu sınayıp sınamadığı bilinemez.
6. **FRZ-008 v2 §3'ün koruma cümlesi yarım kuralla sessizce çiğnenebilir.** §3 operatörlüğün "o ay gizli bir satır için azami Düzelt saatini elde bırakmalı" olduğunu söylüyor. Yarım kural toplam < 2 × tavan olduğunda bunu sağlamıyor (yukarıdaki tablo). Koruma ifadesi yeni sürüme açıkça yazılmalı. Tavan "şimdiki ölçek" değil, mevcut gizli satırların doğduğu ölçeklerin en derini olmalı (FRZ-001 v3 §6): fabrika küçülse de Büyük'te doğmuş bir gizli satır 16 saatlik kalır. Bu son nokta kod okumasına dayanıyor, ayrıca ölçülmedi.
7. **Vardiya sınırı açık kalmalı.** FRZ-008 v2 §3 "ilk makinenin tek vardiyası"nı söylüyor. Yarım-zaman payı ikinci vardiya veya ikinci makine operatörlüğüne genişletilirse pay katlanır ve ilk maddedeki eşik kırılır. Bu IDEA'nın kapsamı yalnız tek vardiya olarak kalmalı.

### Kafama Yatmayanlar

- Öneri metni "başka eylem yokken yönetim için 20 saat kalır" diyor, ama prototipte patron zamanı harcayan tek yönetim eylemi Düzelt; kurs, kariyer, personel vb. saat tüketen başka eylem yok. 20 saatin neye rakip olduğu bilinmeden "belirgin fırsat maliyeti" iddiası ölçülemiyor.
- Oran kuralı toplam saat kararını da dolaylı bağlıyor: Büyük ölçekte operatörlüğün mümkün kalması için toplam ≥ 32 gerekir. Toplam saat sonradan düşürülürse (ör. 30) operatörlük Büyük'te sessizce imkânsızlaşır. Bu istenmiş olabilir; ama toplam saat kararının yan etkisi olarak değil, kuralda yazılı bir sonuç olarak olmalı.
- Gerekçe "sabit 8 saat toplam zaman değişince aynı oranı taşımıyor" toplam saatin değişeceğini varsayıyor; oysa toplam saat henüz karara bağlanmadı. Ölçülen sorun, oranın sabit sayıya göre avantajından çok, iki kararın (oran ve toplam) birbirine bağlanması.

### Uygulanan sınama ve sonraki adım

Önerdiğim kural anahtarı prototipe eklendi (`operator=half`, `hours=`, `cash=`; varsayılan davranış değişmedi): operatörlük ay başında ⌊toplam/2⌋ keser; kalan saat mevcut satırların en derin gizli saat tavanını karşılamıyorsa o ay operatörlük seçilemez (payı kırpmaz). 100 tohum × 8 karakter × 12 ay, 5 000 başlangıç parası:

| Toplam saat | Park (tavan) | Operatörlük | Saat engeli / gizli satırlı ay |
| --- | --- | --- | --- |
| 40 | A×1 / A×3 / A×5 | 20 | 0 / 1 540 · 0 / 1 819 · 0 / 1 993 |
| 32 | A×5 (16) | 16 | 0 / 1 995 |
| 31 | A×5 (16) | 15 (aşağı yuvarlama) | 0 / 1 995 |
| 30 | A×5 (16) | seçilemez (kalan 15 < 16) | 0 / 1 990 |
| 24 / 23 / 22 | A×3 (12) | 12 / 11 / seçilemez | 0 / 1 826 · 0 / 1 826 · 0 / 1 819 |
| 16 / 15 / 14 | A×1 (8) | 8 / 7 / seçilemez | 0 / 1 579 · 0 / 1 579 · 0 / 1 546 |

Bu kural üç önerimi birlikte doğruluyor: aşağı yuvarlama, ay başı taban ve "koruma sağlanamazsa seçilemez". Hiçbir yapılandırmada saat engeli oluşmadı. Bedeli: eşik altında operatörlük hiç mümkün değil (Büyük'te toplam < 32). Karar hâlâ kullanıcıya ait.

Kalan sınamalar:

1. Maaş ve kira prototipe girince operatörlüğün net kasaya etkisini 0 / 8 / yarım zamanla karşılaştır; fırsat maliyetinin zarar olarak görünüp görünmediğine bak.
2. Persona başlangıç parasını ölçek başına gerçekçi tut (şu an Orta/Büyük açılamıyor); geçici 5 000 ölçümü karar girdisi olarak kullanma.

### Açık Sorular

1. Yuvarlama: operatörlük ⌊toplam/2⌋, yönetim ⌈toplam/2⌉ mü (önerim), yoksa başka bir yön mü?
2. Yarım payın tabanı ay başındaki toplam mı (önerim) yoksa harcamalar sonrası kalan mı?
3. Toplam < 2 × (mevcut gizli satırların en derin tavanı) olduğunda operatörlük o ay seçilemesin mi (önerim; oran dürüst kalır), yoksa pay 1 : 1 yerine kırpılsın mı?
4. Yarım zamanın Küçük'te ucuz, Büyük'te pahalı olması bilinçli tasarım niyeti mi?
5. Toplam patron saati bu kararla birlikte mi verilecek? Büyük ölçekte operatörlüğü açık tutmak için toplam ≥ 32 gerekir.
6. Yarım zaman yalnız ilk makinenin tek vardiyası için mi kalıyor (önerim), ikinci vardiya/makine için pay katlanmıyor mu?
7. Kabul edilirse [FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md) §3 için yeni sürüm gerekir; FRZ-001 v3 değişmez. Bu inceleme bir FREEZE değildir.

## Açık Kararlar

- Aylık toplam patron saatinin kesin değeri; 40 saat yalnız mevcut patron prototipinin girdisidir.
- Toplam saat tek sayı olursa yarının saat olarak nasıl yuvarlanacağı.
- İleride toplam saat veya gizli Düzelt üst saati değişirse yarım zaman kuralıyla erişim güvencesinin nasıl birlikte korunacağı.
- 20 saatlik operatörlüğün diğer yönetim eylemleri ve alınan işe göre ekonomik sonucu, personel/maaş/kira prototipiyle sınanacak.
- Claude Tur 1'den: yarım payın yuvarlama yönü ve ay başı tabanı; toplam saat ≥ 2 × gizli tavan (Küçük 16, Orta 24, Büyük 32) koruması ve bunun toplam saat kararıyla birlikte verilmesi; koruma sağlanamayan ayda operatörlüğün seçilememesi; Küçük'te ucuz, Büyük'te pahalı fırsat maliyetinin bilinçli olup olmadığı; yalnız tek vardiya kapsamı. Ayrıntı Notlar (Claude) bölümünde.

## Karar Özeti

- Kullanıcı patron operatörlük yaptığında aylık toplam saatinin yarısını buna ayırmayı istedi; çünkü ücret tasarrufunun yönetim zamanında belirgin bir fırsat maliyeti olması amaçlanıyor. Claude incelemesi ve yeni FREEZE sürümü bekleniyor.
