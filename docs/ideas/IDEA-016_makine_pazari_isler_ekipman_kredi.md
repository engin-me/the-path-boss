# IDEA-016 — Makine Pazarı, Makine Gerektiren İşler, Zorunlu Ekipman ve İpotekli Kredi

## Durum/Tur

Durum: DRAFT — Kullanıcının 2026-09-30 tasarım kararları ve Claude önerileri kaydedildi; Claude incelemesi ve Codex sentezi bekleniyor. Bu IDEA oyun kuralı değildir. `godot/factory_shell.tscn` bu önerileri `godot/scripts/shell/shell_boss.gd` motoruyla oynatılabilir hâle getirir (BossState'in alt sınıfı; sorun/Düzelt, danışman, patron saati ve iflas hesabı BossState'ten). Eski patron testi değişmedi.
Tur: 1
Tarih: 2026-09-30
Bağımlılıklar: [FRZ-001 v3](../freeze/FRZ-001_v3_patron_yetkinlikleri.md), [FRZ-002 v4](../freeze/FRZ-002_v4_fabrika_ekonomisi.md), [FRZ-003 v2](../freeze/FRZ-003_v2_iflas_ve_fabrika_satisi.md), [FRZ-004 v2](../freeze/FRZ-004_v2_is_alma_ve_makine_yatirimlari.md), [FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md), [IDEA-015](IDEA-015_fabrika_kiralama_ve_mobil_arayuz.md).

## Öneri (GPT)

Bu bölüm kullanıcının sohbetteki kararlarından ve Claude önerilerinden derlendi; Codex revize edebilir.

**Makine pazarı.** Dört tür (Torna, Freze, Taşlama, Dövme) × üç seviye (Standart, Hassas, Nitelikli). Yeni makine ortalama fiyatı: Torna $80k, Freze $120k, Taşlama $140k, Dövme $300k; seviye çarpanı 0,70 / 1,00 / 1,40. İkinci el makine yaşa göre ucuzdur (yıl başı yaklaşık %7, taban %35); bazı ilanlar indirimlidir (çizili eski fiyat). En az 10 ilan; mock 20 ilan gösterir. Her makinenin alan, yükseklik, kapasite, enerji (liste fiyatla orantılı, yaştan bağımsız), personel sayısı ve teslim süresi vardır. Satın alınca personel makine teslim edilince otomatik işe başlar. Teslim süresi: ikinci el 1 ay; yeni makine seviyeye göre (öneri: 2 / 3 / 5 ay; kullanıcı önerisi 3 / 6 / 9). Markalar ve kuruluşlar yabancı adlıdır. Personel niteliği ve eğitimi kapsam dışı, not olarak kalır.

**Yaş ve bakım.** Öneri: yaş, ayrı bir "bakım gideri" değil, Bakım departmanının sorun oluşum olasılığını etkiler (tek kanal; yeni makinede Bakım sorunu düşük olur). Aylık işletme gideri enerji, sarf (kesici uç, takım) ve personelden oluşur. Prototipteki makine başı 12 birimlik sabit gider bu kalemlerle değiştirilir.

**Makine gerektiren işler.** İlan bir makine ihtiyaç listesi taşır (tür, en az seviye, adet). Kabulde bu makineler işin süresince ayrılır. Aylık 20 ilan: 2 ilan 4 makine, 4 ilan 3, 5 ilan 2, 9 ilan 1 makine ister. Yalnız hammadde maliyeti gösterilir ve gelirin yüzdesidir: `oran = 75% − 45% × (0,5 × (adet−1)/3 + 0,5 × (seviye−1)/2)` ± küçük sapma (30–75%). Oran ilanın istediği makineye bağlıdır; oyuncunun sahip olduğu makineler maliyeti değiştirmez. Hammadde, ≤ 6 aylık işte kabulde tamamen; daha uzun işte ilk 6 ayın payı kabulde, kalanı her 6 ayın başında düşer. Ayrı gecikme cezası yoktur; ilanda teslim riski metni gösterilmez.

**Zorunlu ve isteğe bağlı ekipman.** Fabrika ölçeğine göre zorunlu paket (transpalet, malzeme kasası, depo rafı, el aletleri, takım/fikstür) tek seferde alınır; eksikse çalışabilir kapasite kullanılamaz (FRZ-008 v2 eksik operatör çizgisinde). Raf ve kasa alan tüketir. İsteğe bağlı ekipman (forklift, kalite ölçüm seti, köprü vinç, ek raf/kasa) miktarla alınır; etkisi ilgili bölümün sorun olasılığını azaltmaktır ve OEE'ye bu yolla yansır. Kesici uç ve takım sarfı aylık işletme giderindedir.

**Kredi.** Banka yabancı adlıdır (mock: Hartwell Credit Bank). Örnek koşul: $100k, aylık %1,5, 12 ay, taksit ≈ $9.169, teminat kredi tutarının %125'i değerinde ipotek (güncel piyasa değeri; teslim alınmış ve ipoteksiz makine), erken kapatma cezası kalan anaparanın %2'si. Bina satın alma sonradan; bina ipoteği şimdilik kilitli. İpotekli makine satılamaz. Kriz kredisi (tek seferlik, teminatsız, FRZ-003 v2) ayrı araç olarak korunur.

## Notlar (Claude)

Tur 1 incelemesi bekleniyor.

## Açık Kararlar

- Simülasyon (100 tohum, `godot/playtests/reports/_shell_ozet.md`): mock ilk ayarda hiçbir karakter kârlı değildi. Prototip ayarı: başlangıç parası $800k, iş geliri ×2, kiralar $15k–45k. Bu ayarda küçük park kârlı, orta başabaş, büyük zararda; FRZ-001 v3 erken erişim testi orta ikinci elde %61, büyükte %28 (para engeli; saat engeli 0). Bunlar test girdisidir.

- Prototipte iş geliri = ilan geliri × teslimine kadarki aylık verimin ortalaması (verim = gerçekleşen/beklenen çıktı); beklenen çıktı, işe ayrılmış teslim edilmiş makinelerin kapasite toplamıdır. FRZ-002 v4 birim bazlı gelir kuralının çok aylı işe genellemesi olarak onay bekler.
- Sabit gider (30) kiraya dönüştü ve makine başı gider (12) enerji + sarf + personel ile değişti; yeni ekonomi dengesi ölçülmedi.
- Kuruluş güvencesi (FRZ-002 v3 §4) kiralamada ilk ay kirası + ölçeğin gizli Düzelt güvencesi olarak uygulanıyor; makine alımında ay gideri koruması BossState'teki gibi.

- İş–makine modeli FRZ-004 v2'nin tek boyutlu "makine niteliği" ve tek sayılı kapasitesinin yerine geçer mi; 3/5 uygun teklif tabanı 20 ilan ve çok makineli işlerle nasıl yeniden tanımlanır; FRZ-001 v3 erken erişim testi yeniden ölçülmeli.
- Hammadde formülü, bölünmüş ödeme ve teslim edilemeyen birimde hammaddenin kaderi (hurda geri dönüşü var mı).
- Yaşın Bakım sorun olasılığına etkisi (tek kanal) ve makine başı 12 birimlik giderin yerine geçen kalemlerin dengesi.
- Zorunlu ekipman paketinin eksikliğinin kapasiteye etkisi ve paket içerikleri; isteğe bağlı ekipmanın etki büyüklüğü.
- Teslim süreleri (2/3/5 mi 3/6/9 mu) ve FRZ-003 v2 altı aylık kurtarma eşiği ile ilişkisi.
- İpotek: kredi ile alınan makinenin yeniden ipoteklenmesi (kaldıraç döngüsü), FRZ-003 v2 iflas ve tasfiye hesabıyla ilişkisi, kriz kredisiyle birlikte varlığı.
- Personel ücret modeli (mock: kişi başı $3.000/ay) IDEA-013'te açıktır.

## Karar Özeti

- Kullanıcı dört tür × üç seviye makine pazarını, en az 10 (mock 20) ilanı, indirimli ve ikinci el makineyi, yabancı adlı marka/banka/kuruluşları, zorunlu ekipman paketini, hammadde-only iş maliyetini ve ipotekli krediyi istedi; çünkü yatırım kararları somut tür, seviye, yaş ve teminat tercihleri yaratmalı. Onaylı FREEZE yoktur.
