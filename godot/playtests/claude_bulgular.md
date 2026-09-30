# Claude oyun testi bulguları — Tur 1

Test eden: Claude · Tarih: 2026-09-29 · Kaynak: `reports/*.md`, `reports/_ozet.md`, `reports/_ozet_ayni_makine.md` (her karakter 40 tohum, 12 ay).
Bu dosya tasarım kararı değildir. Geçerli bulgular IDEA'ya taşınmalıdır; FREEZE yalnızca kullanıcı onayıyla değişir.

Özet (40 tohum):

| Karakter | Kendi makineleri: ayakta / iflas | Aynı makine (A+B): ayakta / iflas | Görülmeyen kayıp payı |
| --- | --- | --- | ---: |
| Teknik Usta (A×2) | 26 / 14 | 40 / 0 | %46 |
| Dengeli Yönetici (A+B) | 40 / 0 | 40 / 0 | %31 |
| Finansçı Kumarbaz (B, 2. ay C) | 40 / 0 | 40 / 0 | %39 |
| İnsan Yöneticisi (A×2) | 18 / 22 | 40 / 0 | %49 |
| Erken Kurucu (A×2, 300 para) | 2 / 38 | açılamadı (40) | %73 |

## Mantık hataları (bu turda düzeltildi)

1. **Kasa gideri karşılamazsa iş alınamıyordu; oyun kilitleniyordu.** Python prototipi ve Godot dilimi, ay başı kasa giderlerin altındaysa iş almayı reddediyordu. İş alamayan fabrika para kazanamıyor, kasa hiç düzelmiyordu. İlk koşuda 5 karakterden 4'ü bu yüzden takıldı. FRZ-004 iş maliyetini yalnız Düzelt güvencesinden ayırır; FRZ-003 v2 eksi kasaya eşiğe kadar izin verir. Kural kaldırıldı; artık yalnız uyarı gösteriliyor ve eksi kasaya finansman gideri işliyor.
2. **Uygun makinesi olmayan teklif seçilebiliyordu.** Arayüz, onaya basınca hata veriyordu. Artık bu teklifler baştan pasif ve "uygun makinen yok" yazıyor.

## Tasarım bulguları (IDEA'ya taşınmalı)

1. **Derin sorunu düzeltmek ekonomik değil (kritik).** Kayıp Tier'den bağımsız (FRZ-002 v3, gizlilik için doğru), ama bedel Tier ile artıyor (FRZ-001 §5). Test verisinde her satır ayda 2–6 kayıp yaratıyor; T3 düzeltmesi 25–35, T5 100–140 para. Sorunlar zamanla büyümediği için rasyonel patron derin sorunları hiç çözmüyor. Bilmediği derin sorun da onu yalnızca sığ bir sorun kadar yakıyor. Öneri: açık kalan "ertelenen sorunun büyüme hızı" kararı kapatılsın. Bütün sorunlar Tier'den bağımsız aynı oranda büyüsün ya da çözülmeyen kök yeni bağlı satır doğursun. İki yol da gizli Tier'i sızdırmaz.
2. **Gizli sorunlar birikiyor; erken erişim yalnız açılış ayında garanti (kritik).** Erken Kurucu 40 tohumun 38'inde iflas etti; kaybının %73'ü hiç görülmedi. Gizli satırın üst güvencesi ölçeğin en derin Tier tavanı (küçük ölçekte T3 = 35). İlk aydan sonra kasa 87–106 bandında kalıyor; giderler (54) ve iş maliyeti düşülünce kullanılabilir nakit çoğu ay bu güvencenin altında. Gizli satırlar kendiliğinden kaybolmuyor: 2. ayda 1 olan gizli satır sayısı 10. ayda 9'a çıkıyor, 7–10. aylarda her deneme güvenceye takılıyor (ayrıntı: `reports/05_erken_kurucu.md`). FRZ-002 v3 §4 yalnız kuruluş anının kasasını garanti ediyor; FRZ-001 §6'daki "ilk üç ayın her birinde deneyebilmeli" testi 2. ve 3. aylarda tutmuyor. Öneri: erken dönem için ya güvence ay ay korunmalı ya da küçük ölçekte ilk aylarda oluşan sorunların derinliği sınırlanmalı.
3. **Makine niteliği yetkinlikten baskın.** Aynı makine parkıyla dört karakter de 40/40 ayakta; kendi A×2 makineleriyle Teknik Usta 26/40, İnsan Yöneticisi 18/40. Neden: iş teklifleri fabrikanın makinelerinden bağımsız rastgele nitelikte geliyor ve yalnız A tezgâhı olan fabrika tekliflerin yaklaşık üçte ikisini alamıyor. FRZ-004, teklif havuzunda oyuncunun makinelerine uygun en az kaç teklif olacağını söylemiyor. Oyunun kimliği ("kariyer geçmişi patronu belirler") açısından risk: yetkinlik dağılımı makine seçiminin gölgesinde kalıyor. Öneri: teklif havuzunda parka uygun asgari teklif payı tanımlansın, ya da nitelikli işlerin getirisi yetkinliğe (ör. Kalite, Satın Alma) de bağlansın.
4. **Danışman neredeyse hiç kullanılmıyor.** 12 ayda ortalama 0–0,5 sözleşme. Tek satırın kaybı ayda 2–6 iken 3 aylık sözleşme 30–45 para tutuyor. Adayların çoğu patronun zaten okuyabildiği seviyede puan taşıyor. Danışman ancak aynı departmanda çok satır birikince anlamlı. Öneri: aday üretiminde "en az bir alanda patrondan bir Tier yukarıda" şartı düşünülsün; sözleşme fiyatı ile tipik kayıp aynı ölçekte dengelensin (FRZ-006 v2 fiyat açık).
5. **Kayıp mutlak birimde; az iş alan ay orantısız etkileniyor.** Satır kaybı iş hacminden bağımsız. Departman %20 tavanı kabul edilen işe göre hesaplandığı için az iş alınan ayda kayıp sert kırpılıyor (ör. 15 birimlik ayda departman başına en fazla 3). Bu, az iş alarak kaybı küçültme gibi ters bir teşvik yaratabilir. FRZ-002 v3, sorun kaybının iş hacmiyle ölçeklenip ölçeklenmeyeceğini tanımlamıyor.
6. **İnsan Yönetimi 100'ün etkisi zor hissediliyor.** Ayda 1–2 yeni olayın yaklaşık %30'u kişi kaynaklı; %80 önlemeyle ayda yaklaşık 0,4 olay önleniyor. Aynı makinede İnsan Yöneticisinin net kasası (52), Dengeli'den biraz iyi (37) ama Teknik Usta'dan kötü (66); görülmeyen kayıp payı da en yüksek (%49). FRZ-005 v2'nin "İnsan Yönetimi 100, diğer dağılımları sistematik geçmemeli" ölçütü sağlanıyor, ama yatırımın oyuncuya görünür karşılığı zayıf. "Önlenen olay" satırı tek başına yetmeyebilir.
7. **Kör deneme fazla iyi ödüllendiriliyor olabilir.** "Belirsiz" satırları da deneyen Finansçı, aynı makinede en yüksek net kasaya ulaştı (216; diğerleri 37–66). Gizli satırın tahmini ucuz (en sığ Tier tabanı) ve küçük ölçekte olası Tier'ler dar (T2–T3), bu yüzden şans %40–80. Bu FRZ-001'in "bilgi açığı imkânsız değil, riskli olmalı" ilkesiyle uyumlu mu, yoksa fazla cömert mi? Karar verilmeli; oran testte ayarlanabilir.

## Test verisi varsayımları (kural değil)

- Makineler (A/B/C: 80/140/220 para, 40/55/70 kapasite, Q1/Q2/Q3). Bir iş, kendi niteliğinde veya daha iyi makinede yapılır.
- Ölçek: 1–2 makine küçük (≤T3), 3–4 orta (≤T4), 5+ büyük (≤T5).
- Aylık gider 30 + makine başına 12. Patron zamanı ayda 40 saat.
- Yeni sorun sayısı ayda 1–2, büyüdükçe artar. Satır kaybı 2–6 × ölçek çarpanı; kişi kaynaklı pay %30.
- Danışman sözleşmesi 3 ay. Kriz kredisi 100, finansman gideri net açığın %2'si.
- Kayıp birimi test kolaylığı için fiziksel teslimatla bire bir alındı.

Bulgu 3 ve 4'ün bir kısmı bu sayılardan kaynaklanabilir. Bulgu 1, 2 ve 5 ise kural yapısından geliyor.

---

# Claude oyun testi bulguları — Tur 2 (taslak kurallarla)

Patron testine, kullanıcının onayladığı ama henüz FREEZE olmayan kurallar **test için** eklendi. Her karakter **100 tohumla** oynandı (`reports/_ozet.md`, `reports/_ozet_ayni_makine.md`).

| Kural | Test değeri | Kaynak |
| --- | --- | --- |
| Diplomasız tavan | Saha alanları 70 (T3); Planlama / Satın Alma / İnsan Yönetimi 50 (T2); Finans / Yatırım / Ar-Ge 30 (T1) | IDEA-009, FRZ-007 v2 taslağı |
| Diploma bölümleri | Mühendislik: Üretim, Bakım, Kalite, Ar-Ge, Planlama, Depo & Sevkiyat · İşletme/İktisat: Finans, Yatırım, Satın Alma, İnsan Yönetimi, Planlama, Depo & Sevkiyat · ikisi birden | IDEA-009 |
| Eşik altı şans | Her eksik puan −%4, en az %5 | FRZ-001 v2 taslağı |
| Sorun büyümesi | Çözülmeyen sorunun zararı her ay %5 artar, başlangıcın en fazla 2 katı; bütün Tier'lerde aynı | IDEA-010 taslağı |
| Danışman ücreti | Aylık 2 + (en yüksek iki puan)/30; 3 aylık sözleşme ≈ 15–24 | Denge girdisi; üç formül karşılaştırıldı |

Karakterlere diploma verildi: Teknik Usta ve Erken Kurucu **diplomasız**, Dengeli Yönetici **iki diploma**, Finansçı Kumarbaz ve İnsan Yöneticisi **İşletme/İktisat**. Tavanı aşan puanlar kırpıldı.

**Tekrarlanabilirlik düzeltmesi:** Danışman adayları karıştırılırken tohumdan bağımsız genel rastgele üreteç kullanılıyordu. Bu yüzden Tur 1'de aynı tohum farklı sonuç verebiliyordu (ör. aynı kodla 87 ve 98). Düzeltildi; iki ardışık koşu artık birebir aynı özeti üretiyor. Tur 1 sayıları farklı rastgele akışla üretildiği için aşağıda yalnız yön olarak karşılaştırılıyor.

## Aynı makine parkıyla (A+B), 100 tohum

| Karakter | Ort. son net kasa | Düzelt başarısı | Ort. danışman | Görülmeyen kayıp payı |
| --- | ---: | ---: | ---: | ---: |
| Finansçı Kumarbaz (kör dener) | 124 | %57 | 0 | %58 |
| **Danışman Arayan** | **80** | %100 | 4,1 | %71 |
| İnsan Yöneticisi | 53 | %100 | 0,7 | %53 |
| Dengeli Yönetici | 22 | %90 | 0 | %33 |
| **Kör Tamirci** | **9** | %48 | 0 | %75 |
| Temkinli Patron | −15 | %100 | 0 | %73 |
| Teknik Usta (diplomasız) | −32 | %100 | 1,0 | %55 |

Danışman ücreti karşılaştırması (aynı kod, 100 tohum; Danışman Arayan / Kör Tamirci net kasa): eski ücret 4 + puan/12 → **12 / 9** · seçilen 2 + puan/30 → **80 / 9** · 1 + puan/40 → **107 / 9**. Seçilen formül danışmanı değerli kılıyor; en ucuzu fazla cazip.

Kendi makineleriyle ayakta kalma (100 tohum): Teknik Usta (A×2) 46, İnsan Yöneticisi (A×2) 41, Erken Kurucu (A×2) 6; diğerleri 100.

## Bulgular

1. **Danışman artık anlamlı (Tur 1 bulgu 4 çözüldü).** Büyüme ve yeni ücretle danışman tutmak kör denemeyi açıkça geçiyor (80'e 9). Ancak Danışman Arayan 12 ayda ortalama 4,1 sözleşme yapıyor; iki yuva neredeyse hiç boş kalmıyor. FRZ-006 v2'nin "sürekli danışman, kariyer yetkinliğinin yerini almamalı" gerekçesiyle gerilim oluşabilir; 24–36 aylık testte izlenmeli.
2. **Kör denemenin aşırı ödülü kalktı (Tur 1 bulgu 7).** Kör deneyenlerin başarısı Tur 1'deki %80–86'dan %48–57'ye indi. Kör Tamirci artık zar zor kâr ediyor (9). Finansçı Kumarbaz hâlâ önde, ama nedeni kör deneme değil: İşletme diploması ve 2. ayda aldığı C tezgâhı.
3. **Derin sorunu görmezden gelmek artık bedava değil (Tur 1 bulgu 1).** Yalnız görünür sorunu düzelten Temkinli Patron eksiye düştü (−15); görülmeyen kayıp payı %73.
4. **Gizli sorun birikimi hâlâ çözülmedi; büyüme onu ağırlaştırdı (Tur 1 bulgu 2, en acil).** Erken Kurucu 100 tohumun 94'ünde iflas ediyor. Çoğu karakterde görülmeyen kayıp payı %53–75. Erken dönemde gizli satırları deneyecek nakit güvencesi sorunu şimdi daha kritik. Büyüme kuralı bu çözülmeden FREEZE olursa erken fabrikalar daha hızlı batar.
5. **Diplomasız rota zor ama oynanabilir.** Diplomasız Teknik Usta A+B parkıyla 100/100 ayakta kalıyor ama 12 ayı eksi net kasayla (−32) bitiriyor; A×2 parkıyla yalnız 46/100. Kullanıcının "teoriyi bilmeden derine inemesin" hedefi tutuyor. Diplomasız rotanın yaşayabilmesi büyük ölçüde danışmana bağlı.
6. **Makine baskınlığı sürüyor (Tur 1 bulgu 3).** A×2 ile Teknik Usta 46/100, İnsan Yöneticisi 41/100 ayakta; A+B ile hepsi 100/100.
7. **Genel ekonomi sıkılaştı.** Dengeli ve Temkinli karakterler 12 ayı sıfır civarında net kasayla bitiriyor. Bu bir denge işi: iş fiyatları ve giderler, taslak kurallar kesinleşince yeniden ayarlanmalı.
8. **ChatGPT karakterlerinde diploma yok.** Diploma alanı olmayan karakterler diplomasız sayıldı ve tavana kırpıldı (ör. Temkinli Patron'un Finans, Yatırım, Ar-Ge değerleri 60 → 30). `reports/06–08` bu koşuda yeniden üretildi; `_ozet_chatgpt.md` ve `chatgpt_bulgular.md` eski kurallara göredir. ChatGPT kendi karakterlerine `"diploma"` alanı eklemeli.

## Tur 3 — IDEA-012 / IDEA-013 ölçümleri (100 tohum, %5 büyüme)

Ayrıntı ve tablolar IDEA-012 ve IDEA-013 dosyalarındaki `Notlar (Claude)` bölümlerindedir; kuralları değiştirmeden `exp=` anahtarlarıyla ölçüldü (bkz. `README.md`).

1. Erken Kurucu iflasının sebebi teklif havuzu: park bakılmadan çekilen kalite. Her ay 5 tekliften 3'ünü parka uyumlu yapmak 6/94 → 87/13; yalnız ilk 3 ay 25/75.
2. Danışmansız gizli Düzelt: ay 1'de hiçbir karakterde para engeli yok; ay 2–3'te taban kuralıyla gizli satırlı ayların %90'ında mümkün; patron saati hiç engel değil.
3. Tek A tezgâhı kendi sabit giderini karşılamıyor (≈41 < 42): operatör maaşı eklenirse patron operatör olmak zorunda kalır.
4. Patron operatör saati 0–32 saat bedelsiz, 33+ saatte bütün gizli denemeler kilitleniyor (FRZ-001 üst saat güvencesi): kademeli değil, uçurum.
