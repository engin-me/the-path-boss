# Kabul Senaryoları — Çalışanlıktan Fabrikaya

Bu belge mevcut FREEZE kararlarının birlikte çalışmasını sınamak için hazırlanmış **test verisidir**. Tablolardaki para birimleri, Tier eşikleri, ücretler, süreler ve olay sonuçları denge kararı veya yeni oyun kuralı değildir. Gerçek uygulamada bu örnek değerler değişebilir. Kural çelişkisinde [Karar İndeksi](01_DECISION_INDEX.md) içindeki CURRENT FREEZE geçerlidir.

Kısaltmalar: `K` şirket kasası, `B` ödenmemiş şirket kredisi, `V` eldeki satılabilir yatırımın güncel referans değeri, `N = max(0, azami aylık brüt kâr − aylık olağan gider)`, `D = max(0, B − K)`, `H = 0,50 × V + 6 × N`. Yalnızca `D > H` zorunlu kapanış tetikler ([FRZ-003 v2](freeze/FRZ-003_v2_iflas_ve_fabrika_satisi.md)). Şirket kasası ile karakterin kişisel parası ayrı tutulur.

## 1. İlk fabrika ve ilk üç ay

[GAME_OVERVIEW](03_GAME_OVERVIEW.md) örneğindeki karakterin Üretim 90, Depo & Sevkiyat 80, Planlama 35, Satın Alma 30, İnsan Yönetimi 25 ve Finans 30 yetkinliği vardır. Diğer alanları bu sınama için gerekli değildir. **Test varsayımı:** Küçük ölçekte Planlama T2 eşiği 50, gizli satırın en yüksek para güvencesi 20, her ayın ödenmemiş bilinen olağan/iş gideri toplamı 50, patron zamanı güvenceden fazladır. Bunlar onaylı denge sayıları değildir.

Kuruluş kasası 120 ≥ ilk ayın bilinen gideri 50 + gizli sorun güvencesi 20; kuruluşun nakit şartı sağlanır. Üretim 90 olsa da Planlama 35 ile T2 sorununu teşhis edemez. Test ölçeğinde yalnız T2 gizli kalabiliyorsa çıkarılabilir şans etiketi görünür, kök neden gizli kalır. İlk iki ayın 20 birim kaybı gizli Planlama 10 + görünür Üretim 10; üçüncü ayın 15 birim kaybı yeni gizli Planlama 5 + görünür Üretim 10'dur. Her ay kabul edilmiş işler için beklenen çıktı eşdeğeri 100'dür; teorik ama iş alınmamış kapasite bu sayıya eklenmez. **Bu testte** çıktı eşdeğeri fiziksel teslimata bire bir denk gelir, üretilen her birim aynı ay 0,75 para birimine satılır. Böylece üçüncü aydaki beş ek teslim gelirde de görünür.

| Ay raporu | K (karar öncesi) | Ayrılan bilinen gider | Düzelt'e kullanılabilir | Gizli üst güvence | Beklenen / kayıp / gerçekleşen çıktı | Düzelt olayı | Fiili satış − gider − Düzelt | Ay sonu K |
| --- | ---: | ---: | ---: | ---: | --- | --- | ---: | ---: |
| 1 | 120 | 50 | 70 | 20 | 100 / 20 / 80 | Gizli Planlama kökü denenir, başarısız; tahmin bedeli 5. Aynı kök bu ay kilitli. | 60 − 50 − 5 | 125 |
| 2 | 125 | 50 | 75 | 20 | 100 / 20 / 80 | Aynı kök yeniden denenir, başarılı; gerçek bedel 12. | 60 − 50 − 12 | 123 |
| 3 | 123 | 50 | 73 | 20 | 100 / 15 / 85 | Eski kökün 10 birim kaybı yoktur; yeni bir gizli kök denenir, başarısız; tahmin 5. | 63,75 − 50 − 5 | 131,75 |

**Geçme ölçütü:** Üç ayın her birinde danışmansız en az bir gizli satır para ve patron zamanı güvencesiyle denenebilir ([FRZ-001 §6](freeze/FRZ-001_patron_yetkinlikleri.md)). Başarısızlık aynı kökün bağlı satırlarını yalnızca o ay kilitler; ikinci aydaki başarılı Düzelt'in rapor faydası üçüncü ayda görünür. Gizli satırın bedeli Tier'i ifşa etmez, `tahmin ≤ gerçek ≤ üst` korunur. Kayıp departman başına kabul edilmiş hedefin yaklaşık %20 tavanını ve fabrika geneli %33 gerçekleşme tabanını aşmaz ([FRZ-002 v3](freeze/FRZ-002_v3_fabrika_ekonomisi.md)).

## 2. Kriz: makine satışı, kredi ve kapanış eşiği

**Test varsayımı:** Başlangıçta `K=20`, `B=140`, `V=100`, `N=20`. Elde tutulan varlıkların toplam referans değeri her ay sonunda bu örnekte 2 azalır: `100 → 98 → 96 → 94`. Bu, onaylı amortisman oranı değildir. Satılmak istenen makinenin başlangıçtaki referans değeri 40'tır; gönüllü satış geliri `0,70 × 40 = 28` olur. Bu makine çıkınca potansiyel aylık net katkı 8'e düşer. Örnekteki finansman gideri her borçlu ayda 2'dir; oranı onaylı denge değeri değildir. Gerçek nakit olayları aşağıdaki örneği izler.

| An / ay sonu | Faaliyet / kredi nakit etkisi | Finansman gideri | K | B | V | N | D = max(0, B−K) | H = 0,50V+6N | Sonuç |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| İlk rapor | — | — | 20 | 140 | 100 | 20 | 120 | 170 | Açık eşikten küçük; fabrika sürer. |
| Makine satışı önizlemesi | +28 (varsayımsal) | — | 48 | 140 | 60 | 8 | 92 | 78 | Nakit artsa da `D > H`; oyuncu satıştan önce bu riski görür ve örnekte satışı iptal eder. |
| Kriz kredisi alındığında | +30 | — | 50 | 170 | 100 | 20 | 120 | 170 | Kredi K ve B'yi eşit artırır; borç açığını iyileştirmez. |
| 1. ay sonu | −3 | −2 | 45 | 170 | 98 | 20 | 125 | 169 | Kapanış yok. |
| 2. ay sonu | −41 | −2 | 2 | 170 | 96 | 20 | 168 | 168 | Eşitlik kapanış değildir. |
| 3. ay sonu | +1 | −2 | 1 | 170 | 94 | 20 | 169 | 167 | Zorunlu kapanış tetiklenir. |

**Geçme ölçütü:** Satış onayı sonrası borç açığı, kaybolan kapasite ve yeni eşik gösterilir; satış gelirine bakıp güvenli sanılmaz ([FRZ-003 v2 §2](freeze/FRZ-003_v2_iflas_ve_fabrika_satisi.md)). Kredi yalnızca nakdi artırdığı için kurtarma gücü yaratmış sayılmaz. Negatif net pozisyonun finansman gideri kasadan ayrı düşülür. V her ay azalırken kapanış eşitlikte değil, yalnızca sıkı `>` durumunda olur. `N` bu tabloda sabit tutulan test girdisidir; gerçek oyunda iş havuzu ve makine etkisi FREEZE'deki ay sonu kuralıyla güncellenir.

## 3. İflas, çalışanlığa dönüş ve kişisel borç

İkinci senaryonun kapanışını devralır: `K=1`, `B=170`, `V=94`. Zorunlu tasfiye güncel referansın `0,50 × 94 = 47` tutarını getirir; kapanış hesabı `1 + 47 − 170 = −122` şirket açığı üretir. **Yalnızca bu test için** beklenen çalışan aylık geliri 10, taksit oranı %20 ve yaklaşık bir yıllık kişisel borç tavanı `12 × 10 × 0,20 = 24` alınır. Karaktere geçen borç `min(122, 24) = 24` olur. Hangi maaşın referans alınacağı ve kesin oran henüz kararlaştırılmamıştır.

| Çalışanlık ayı | Aylık gelir | Ödenen kişisel taksit | Kalan kişisel borç | Yeni fabrika uygunluğu |
| --- | ---: | ---: | ---: | --- |
| Dönüş | — | — | 24 | Borç bitmeden kurulamaz. |
| 1 | 10 | 2 | 22 | Hayır |
| 2 | 10 | 2 | 20 | Hayır |
| 3 | 10 | 2 | 18 | Hayır |
| 4 | 10 | 2 | 16 | Hayır |
| 5 | 10 | 2 | 14 | Hayır |
| 6 | 10 | 2 | 12 | Hayır |
| 7 | 10 | 2 | 10 | Hayır |
| 8 | 10 | 2 | 8 | Hayır |
| 9 | 10 | 2 | 6 | Hayır |
| 10 | 10 | 2 | 4 | Hayır |
| 11 | 10 | 2 | 2 | Hayır |
| 12 | 10 | 2 | 0 | Borç engeli kalkar; kuruluş sermayesi ayrıca gerekir. |

**Geçme ölçütü:** Şirket açığının tamamı karaktere yüklenmez; kişisel borca faiz işlemez, işsiz ayda taksit durur ve birikmiş yetkinlikler/statlar silinmez ([FRZ-003 v2 §5](freeze/FRZ-003_v2_iflas_ve_fabrika_satisi.md)). İflas raporu gizli kökleri açıklar, fakat bilgi kendiliğinden yetkinlik puanına dönüşmez; yalnızca bir defalık sınırlı “acı tecrübe” artışı işler. İşten çıkarılma kaynaklı psikoloji düşüşü sonraki deneme süresinde tek başına yeni iş kaybı yaratmaz ([FRZ-007](freeze/FRZ-007_calisanlik_kariyeri.md)).

## 4. Başarılı devir ve daha güçlü yeni fabrika

**Test varsayımı:** Kârlı eski fabrikada `K=200`, `B=20`, güncel satılabilir yatırım referansı 100'dür. Kanıtlanmış kâra dayalı işletme satış değeri 160, aynı fabrikayı yeniden kurma bedeli 180'dir; `160 ≤ 180`. Yeni fabrikanın daha nitelikli makinesi **230**, hazırlık gideri **20**; toplam yeni kuruluş maliyeti **250 > 180** olur. Makine daha niteliklidir ancak bu testte görünür fabrika ölçeği hâlâ **küçük** sınıftadır. Bu nedenle ilk faaliyet ayının bilinen gideri 40 ve küçük ölçekteki olası en derin gizli sorun güvencesi 20 kullanılır. Hazırlık süresi olarak bir ay yalnızca test girdisidir.

| Ay / adım | Karaktere geçen net satış | Yeni fabrikanın K'sı | Bilinen gelecek gider + gizli üst güvence | Olay ve sonuç |
| --- | ---: | ---: | ---: | --- |
| Eski fabrikanın satış kararı | `200 + 160 − 20 = 340` | — | — | Şirket borcu kapanır; iflas sonuçları tetiklenmez. |
| 1. ay, yeni makine ve hazırlık | 340 | `340 − 230 − 20 = 90` | `40 + 20 = 60` | Hazırlıkta üretim/satış yok; kuruluş kasası şartı yine sağlanır. |
| 2. ay, ilk faaliyet kararı | — | 90 | 60 | Bilinen giderler ayrılınca Düzelt'e kullanılabilir 50 ≥ güvence 20; kabul edilen işler başlanabilir. |
| 2. ay sonu örnek gerçekleşme | — | `90 + 50 − 40 − 10 = 90` | — | Fiili satış 50, olağan/iş giderleri 40, Düzelt 10; gelir iki kez sayılmaz. |

**Geçme ölçütü:** Devir bedeli yeniden kurma tavanını aşmaz; yeni ve daha nitelikli fabrikanın kurulum bedeli eski satış fiyatından yüksektir. Eski fabrikanın 60 birimlik referans üstü değeri kanıtlanmış faaliyet kârına dayanır; yeni fabrika hazırlıkta veya ilk gününde aynı primi kazanmaz. Kasadaki para ve satış bedeli ayrı kapanış hesabında borca mahsup edilir, hazırlık süresi atlanmaz ve ilk faaliyet ayında kuruluş nakdi korunur ([FRZ-003 v2 §4](freeze/FRZ-003_v2_iflas_ve_fabrika_satisi.md), [FRZ-002 v3 §4](freeze/FRZ-002_v3_fabrika_ekonomisi.md)). Borçsuz devir psikoloji cezası veya iflasın “acı tecrübe” artışını vermez.

## Senaryoların açığa çıkardığı denge girdileri

- FRZ-006 v2 her alanın en derin erişilebilir Tier'i için havuzda danışman türü gerektirir. 10–15 **sabit profil** örneği ile güçlü kartların nadirliği birlikte sınanmalıdır; profil sayısı veya kart üretim modeli henüz karar değildir.
- FRZ-003 v2'deki kişisel borç tavanı için “beklenen çalışan geliri”nin hangi maaştan hesaplandığı belirlenmelidir. Üçüncü senaryodaki 10 ve %20 yalnızca test girdisidir.
- FRZ-002 v3 kuruluş kasası güvencesini küçük ölçek için tanımlar. Büyük ölçekte doğrudan kurulan fabrikaya uygulanacak güvence ayrıca kararlaştırılmalıdır; dördüncü senaryo küçük ölçekte kalır.
- FRZ-003 v2 satış değerini eski fabrikayı yeniden kurma bedeliyle sınırlar; farklı teknolojili yeni fabrikanın maliyetini karşılaştırma kuralı tanımlamaz. Dördüncü senaryo fiyat istismarını içermez, fakat başka fiyat kombinasyonlarında devir/yeniden kuruluş döngüsü denge testinde ayrıca aranmalıdır.
- Gerçek parayla rastgele kartın nihai sunumu ve geçerli platform koşulları monetizasyon aşamasında doğrulanmalıdır; bu senaryolar ödeme ekranını onaylamaz.
