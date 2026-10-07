# IDEA-022 — Vardiya, Personel Sözleşmesi ve Tazminat; Vardiya Verimi; Ay Başı Uyarısı

## Durum/Tur

Durum: DRAFT — Kullanıcının 2026-10-06 notları ve cevapları kaydedildi; Claude incelemesi ve kullanıcı onayı bekleniyor. Bu IDEA oyun kuralı değildir. [FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md) (patron ilk makinenin tek vardiyasında operatörlük yapar; eksik operatör kapasiteyi düşürür) ve [FRZ-005 v2](../freeze/FRZ-005_v2_personel_ve_insan_yonetimi.md) CURRENT kalır. [IDEA-018](IDEA-018_oee_vardiya_ve_kadro.md) vardiya/kadro/OEE konusunu açan taslaktır.
Tur: 1
Tarih: 2026-10-06
Bağımlılıklar: FRZ-008 v2, FRZ-005 v2, IDEA-014, IDEA-018, IDEA-019, IDEA-021.

## Öneri

**Gözlem.** Prototipte patron, tek operatörlü tezgahta "2 vardiya için tek personel yeter" kuralıyla tek başına iki vardiya ve mesai yapabiliyor; bu FRZ-008 v2'nin "tek vardiya" ilkesiyle çelişir ve gerçekçi değil. İkinci vardiya ve mesai hafif bir ayar; ciddi bir karar olmalı. Gece vardiyaları gerçekte daha verimsiz.

### 1. Kim hangi vardiyayı çalıştırır
- **Patron = 1. vardiya + (varsa) onun mesaisi.** İkinci vardiya patronla olmaz.
- **2. vardiya = yeni personel; 3. vardiya = bir personel daha.** Tezgah başına vardiya başına **1 kişi** (tek operatörlü tezgahlar; çok personelli tezgahlarda tezgahın personel sayısı kadar).
- Mesaide çalışan personele mesai ücreti ödenir (mevcut 1,5× saatlik ücret).

### 2. Vardiya açmak ve kapatmak
- Vardiyayı açmak **hemen** başlar (bekleme yok) ama onay penceresi uyarır: "Bu vardiya için 1 personel istihdam edilecek. Vardiyayı kapatmak tazminat ödemenize sebep olur."
- İstihdam türü seçimi:
  - **Kadrolu:** normal maaş; vardiyayı kapatırsan **tazminat** öder.
  - **Sözleşmeli:** maaş **+%30**, tazminat **−%60**; sözleşme süresi (öneri 3/6/12 ay) bitince vardiya kendiliğinden kapanır ve ek tazminat çıkmaz.
- **Denge (öneri):** tazminat 3 aylık maaş alınırsa kadrolu tazminat 3, sözleşmeli 1,2 maaş; fark 1,8 maaş, sözleşmelinin ek maliyeti ayda %0,3 maaş → başa baş süre ≈ **6 ay**. Vardiya 6 aydan kısa sürecekse sözleşmeli, uzunsa kadrolu avantajlı. Tazminat süresi kullanıcı kararıdır (2–3 maaş).

### 3. Vardiya verimi
- Her vardiyanın verim çarpanı tezgah seviyesine bağlı: **Manuel 1. vardiya %100, 2. %85, 3. %75; CNC %100 / %95 / %90; Hassas %100 / %100 / %100.** Kapasite buna göre azalır (üç vardiyalı manuel tezgah teorik kapasitenin ≈ %87'sini verir).
- Mesai saatleri aynı vardiya çarpanını alır (öneri; kullanıcıya açık soru). Çarpan yalnız kapasiteyi etkiler; hurda etkisi ayrı karardır.
- OEE'nin performans bileşeni buna bağlanır ([IDEA-018](IDEA-018_oee_vardiya_ve_kadro.md)).

### 4. Ay başı uyarısı ve kalıcılık
- Vardiya ve mesai ayarı ay ay **kalır** (varsayılan olarak devam eder); ancak **Ayı başlat**'a basınca kısa bilgi penceresi gösterilir: açık vardiya sayısı, mesai durumu, **şu tarihte boşa düşecek tezgah** (sözleşmeli bitişi), sözleşmeli personelin hâlâ çalıştığı, aylık maliyet.
- Üçüncü vardiya ve mesai her ay yeniden onay ister (öneri).
- Yeni arayüzde açık vardiya ay başlamadan da ekranda görünür (Üretim Hattı ve Kapasite ekranı).

### 5. Park edilenler
- Personel yönetim ekranı (tek tek işe alma/çıkarma, kadro listesi) ve Sözleşmeler altında personel bölümü **park edildi**; bu IDEA yalnız vardiya kararına bağlı istihdam, tazminat ve sözleşmeli seçeneğini kapsar.

## Notlar (Claude)

### Aldığım Notlar
- Mevcut prototip: plan tüm tezgahlara uygulanır; patron ilk vardiyada tek operatörlü bir tezgahı çalıştırır, FRZ-008 v2 ile uyumsuz biçimde o tezgahta "2 vardiya için tek personel yeter" der. Bu IDEA bunu düzeltir.
- Patron saati prototipte 250 saat/ay (10 sa × 25 gün); Düzelt süreleri aynı oranda (×6,25) büyütüldü, FRZ-001 v3 gizli Düzelt erişimi simülasyonla ayrıca doğrulanmalı.

### Bulduğum Sakıncalar
- Tek tezgahlı oyuncuda personel ve tazminat sistemi hissedilmeyebilir; denge ve eğlence 3+ tezgahlı senaryoda sınanmalı.
- Vardiya verimi + tazminat + sözleşmeli seçeneği tek karar ekranında yoğunlaşırsa "yorucu oyun" şikâyeti büyür; açma onayı kısa ve net olmalı.
- Kadrolu/sözleşmeli ayrımı, FRZ-005 v2'nin personel kök olayı payıyla (kişi başı sorun) birlikte düşünülmeli: sözleşmeli personel sorun olasılığını değiştirir mi?

### Kafama Yatmayanlar
- "+%30 maaş, −%60 tazminat" başa baş süresi tazminat süresine çok bağlı; tazminat 2 maaş olursa başa baş 4 aya iner. Tek bir sihirli sayıya dayanmasın.

### Açık Sorular
- Tazminat kaç aylık maaş (2 mi 3 mü)?
- Sözleşmeli süresi seçenekleri ve süre bitiminde yenileme/uzatma?
- Mesai verim çarpanı vardiyayla aynı mı, ayrı mı?
- Patron mesai yaparsa saat tüketimi ve FRZ-001 v3 gizli Düzelt güvencesi.
- Hassas tezgahta vardiya verimi gerçekten kayıpsız mı?

## Açık Kararlar

- Tazminat süresi (2–3 maaş), sözleşmeli maaş/tazminat oranları.
- Sözleşmeli süre seçenekleri ve bitişte davranış.
- Vardiya verim çarpanlarının kesin değerleri ve mesaiye uygulanması.
- Üçüncü vardiya/mesai için aylık yeniden onay.

## Karar Özeti

- Kullanıcı: **patron = vardiya + mesai; ikinci vardiya = yeni personel (mesai yaparsa personele ödenir); üçüncü vardiya da aynı**. Her vardiya tezgah başına 1 personel; vardiya hemen açılır, kapatmak tazminat doğurur; açarken uyarı gösterilir.
- Kullanıcı sözleşmeli personel seçeneğini önerdi: maaş %30 fazla, tazminat %60 az.
- Kullanıcı vardiya verimini istedi: Manuel %100/85/75, CNC %100/95/90, Hassas kayıpsız.
- Ay başlatırken kısa bilgi penceresi (açık vardiya, mesai, boşa düşecek tezgah ve tarihi, sözleşmeli personel durumu).
- Personel yönetim ekranı ve sözleşmeler altında personel bölümü park edildi.
- 2026-10-07 kullanıcı onayı: patron/vardiya/mesai/yeni personel kurgusu ve vardiya verim çarpanları uygundur; sözleşmeli personel (maaş +%30, tazminat −%60) kurgusu da uygundur. Tazminat süresi, sözleşmeli süresi ve mesai verimi sayıları prototipte denenerek ayarlanır.
- Onaylı FREEZE yoktur.
