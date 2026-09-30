# FRZ-008 v2 — Fabrika Operasyon Çekirdeği: OEE, Kadro ve Patron Operatörlüğü

Status: CURRENT — [FRZ-008](FRZ-008_fabrika_operasyon_cekirdegi.md) sürümünü supersede eder. IDEA-013'ün diğer açık kararları sürüyor.
Date: 2026-09-30
Source: [IDEA-013](../ideas/IDEA-013_fabrika_kurulusu_ve_operasyon_cekirdegi.md), Claude Tur 1 ve kullanıcının OEE eşlemesi, operatör saati ve iş bazlı ekonomi kararları.
Depends on: [FRZ-001 v3](FRZ-001_v3_patron_yetkinlikleri.md), [FRZ-002 v4](FRZ-002_v4_fabrika_ekonomisi.md), [FRZ-004 v2](FRZ-004_v2_is_alma_ve_makine_yatirimlari.md), [FRZ-005 v2](FRZ-005_v2_personel_ve_insan_yonetimi.md).

## Onaylanan Kararlar

### 1. OEE fiziksel üretimin rapor göstergesidir

**Ne:** Fiziksel üretim kayıpları mevcut departman sorun satırlarından gelir. OEE, bu kayıpların kullanılabilirlik, performans ve kalite başlıklarıyla raporda okunmasıdır; ayrı bir üretim çarpanı, yeni sorun kaynağı veya kasa hesabı değildir. Fiziksel kayıp, OEE gösterildi diye ikinci kez çıktıdan düşülmez. Finans gibi fiziksel olmayan çıktı eşdeğeri kayıpları OEE dışında raporlanır. FRZ-002 v4'ün toplamsal kayıp hesabı, departman tavanı ve gerçekleşme tabanı korunur. Örneğin kabul edilmiş 100 birimlik işte Bakım kaybı 10 ve Kalite kaybı 5 ise, başka fiziksel kayıp yokken sağlam ürün 85 birimdir; raporun fiziksel OEE göstergesi %85'tir. Fiziksel olmayan kayıp varsa toplam çıktı eşdeğeri göstergesi bundan ayrıca etkilenebilir.

**Neden:** Oyuncu hangi bölümün sağlam ürünü azalttığını görmeli; çarpımsal ikinci hesap aynı zararı tekrar yazmamalı ve mevcut ekonomi kararlarını sessizce değiştirmemelidir.

**Ne:** OEE bileşeni departman adına göre sabitlenmez; sorun satırının fiziksel etkisine göre belirlenir. Makine veya üretim hattı çalışamazsa **kullanılabilirlik**, çalışırken hedeflenen miktarın altında üretirse **performans**, üretilen parça kusurluysa **kalite** başlığında gösterilir. Aynı departmanın farklı sorunları farklı başlıkta görünebilir. Örneğin malzeme gelmediği için makine durursa Depo & Sevkiyat kaybı kullanılabilirlikte görünür; sağlam ürün üretildiği hâlde yalnız sevk veya satış gerçekleşmezse fiziksel OEE düşmez, ilgili satış/çıktı eşdeğeri etkisi kendi sorun satırında kalır. OEE göstergesi mevcut fiziksel satır kayıplarından türetilir; bileşen oranları bağımsız çarpan olarak yeniden uygulanmaz.

**Neden:** Departman etiketi tek başına fiziksel sonucu söylemez. Etkiye göre eşleme oyuncuya duruş, hız ve kusur nedenlerini doğru anlatırken aynı kaybın tekrar hesaplanmasını önler.

### 2. Eksik operatör çalışabilir kapasiteyi azaltır

**Ne:** Dolu ve boş operatör kadrosu iş seçilmeden önce belirlenir ve kabul edilebilecek çalışabilir kapasite buna göre gösterilir. Boş kadro tek başına departman sorun satırı, OEE kaybı veya ayrı gecikme cezası oluşturmaz. Ücret politikası ilk dilimde yalnız kadro doluluğunu ve olağan ücret giderini etkiler; aynı ücret kararı ayrıca yeni kişi kaynaklı sorun olasılığını veya OEE'yi değiştirmez. FRZ-005 v2'nin İnsan Yönetimi ile önleme kuralı kendi alanında geçerlidir.

**Neden:** Aynı personel açığı kapasite, sorun ve OEE üzerinden birden fazla kez cezalandırılmamalı; iş seçimi oyuncunun o ay çalıştırabileceği kadroyu yansıtmalıdır.

### 3. Patronun operatörlüğü yönetim zamanı tüketir

**Ne:** Patron ilk makinenin tek vardiyasında operatör ihtiyacını karşılayabilir. Bu seçim ilgili operatör ücretini azaltır ve aynı ayın patron yönetim zamanından **8 saat** tüketir. Aylık toplam patron saati bu kararla dondurulmaz; mevcut patron prototipinde 40 saat olduğundan, başka eylem yokken operatörlükten sonra 32 saat kalır. Operatörlük, o ay gizli bir satır için FRZ-001 v3'ün gerektirdiği azami Düzelt saatini elde bırakmalıdır; FRZ-001 v3'ün erken dönem danışmansız Düzelt erişim testi korunur. Patronun Üretim yetkinliği operatörlükten ayrıca çıktı veya OEE bonusu yaratmaz.

**Neden:** İlk makinede kendi çalışmak ücret karşılığında yönetim zamanı harcatan bir tercih olmalı; gizli Düzelt'i tümüyle kilitlememeli veya Üretim sorun satırlarının dışında ikinci bir verim hesabı açmamalıdır.

### 4. Tek makinenin ekonomik sonucu işe bağlıdır

**Ne:** Tek makinenin ücretli operatörle her koşulda kârlı veya zararlı olacağına dair sabit sonuç ya da garanti konmaz. Yaşayabilirlik, o ay alınabilen ve kabul edilen işlerin fiili geliri, maliyetleri ve fabrikanın giderleriyle değerlendirilir. Kesin kira ve ücret değerleri daha sonra dengelenir.

**Neden:** Fabrikanın sonucu gerçek iş ve kapasite seçimlerine bağlı olmalı; patronun operatörlüğü önceden zorunlu veya her zaman üstün bir yol olarak belirlenmemelidir.

## Açık Kalan Kararlar

- OEE'nin ekranda sunumu ve fiziksel ürün ile çıktı eşdeğeri uzlaştırmasının sayısal prototip doğrulaması.
- Aylık toplam patron saatinin kesin değeri ve vardiya uygulamasının ayrıntısı; 40 saat mevcut prototip girdisidir.
- Tek makinenin farklı iş havuzlarında yaşayabilirlik dengesi, alan kirasının mevcut sabit giderle ilişkisi ve kesin maaş/kira değerleri.
- Operatör dışındaki dört ücret grubunun ölçek tetikleyicileri, katalog, alan ve diğer IDEA-013 konuları.
