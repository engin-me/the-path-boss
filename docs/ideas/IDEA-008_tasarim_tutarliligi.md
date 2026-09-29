# IDEA-008 — Mevcut FREEZE Kararlarının Tutarlılığı

## Durum/Tur

Durum: Kullanıcı kararıyla kapandı; [FRZ-005 v2](../freeze/FRZ-005_v2_personel_ve_insan_yonetimi.md) ve [FRZ-006 v2](../freeze/FRZ-006_v2_danisman_pazari.md) CURRENT.
Tur: 1
Date: 2026-09-29
Kapsam: FRZ-005 ve FRZ-006. Eski FREEZE metinleri tarihsel kayıt olarak kalır.

## Öneri (GPT)

- **Danışman erişimi:** Fabrika ölçeğinin izin verdiği en derin sorun Tier'inin eşiğine ulaşan en az bir profil türü, o ölçekte her departman için aday havuzunda bulunur. Her ay gösterilmesi veya oyuncunun onu ödeyebilmesi garanti edilmez. Böylece danışman yolu sistem tarafından tamamen kapatılmaz.
- **Kart bütçesi:** `alan sayısı × 60` sınırı korunur. İki alanlı 55+70 ve 75+65 örnekleri geçersizdir; iki alanda 100 puan, ancak yeterli başka alan içeren ve toplam bütçeyi aşmayan kartta mümkündür. Bu, örnekleri kurala uydurur; sınırı büyütmez.
- **Ücretli rastgele kart:** Dördüncü/beşinci çekim oyun parası veya gerçek paradan biriyle alınabilir; ödeme yolu aynı kart havuzunu, olasılığı ve +10 yüzde puan uygunluk kuralını değiştirmez. Oyun parasıyla erişim sıradan oynanışta makul kalmalı, gerçek para zorunlu çözüm olmamalıdır. Kesin fiyat ve sunum ayrı denge/monetizasyon kararıdır.
- **İnsan Yönetimi departmanı:** Bu departmanın da kişi ve süreç/organizasyon kaynaklı sorunları bulunur. Kişi kaynaklı aday payı, diğer departmanlarla aynı yaklaşık %30 başlangıç hedefine uyar. Patronun kalıcı İnsan Yönetimi puanı kendi departmanında da yalnızca yeni kişi olaylarını önler; görünürlük/Düzelt etkisi FRZ-001'e tabidir.
- **Bir aylık sözleşme:** Önceki 1/3/12 ay sayıları bağlayıcı değildi. Bir aylık seçenek uygulanırsa aylık karar ritminde ilk yarısında uzatma fırsatı olmadığı için uzatılamaz. Daha uzun sözleşmelerde ilk yarı kuralı sürer; kesin süre seçenekleri ve fiyatlar açık kalır.

## Notlar (Claude)

Kullanıcının bu turda aktardığı Claude dosya karşılaştırması: (1) en derin Tier'e erişen profil türü havuz garantisi FRZ-006'ya taşınmamış, (2) iki örnek kart puan bütçesini aşıyor, (3) gerçek parayla rastgele dördüncü kart GAME_OVERVIEW §26 ile gerilim taşıyor, (4) İnsan Yönetimi departmanının kendi sorunları eşit kişi payıyla bağdaştırılmalı, (5) bir aylık sözleşmenin ilk yarı uzatması aylık ritimde işlemiyor. Claude dosyaya bu turda yazmadığını belirtti; özet kullanıcı tarafından iletilen incelemenin kaydıdır.

## Açık Kararlar

- Danışman fiyatlarının ve oyun parası erişim ölçütünün kesin sayıları.
- Kart havuzu büyüklüğü, sözleşme süreleri ve ücretli çekim sunumunun son dengesi.
- Kişi kaynaklı sorun oranlarının son test değerleri.

## Karar Özeti

- Danışman havuzunda her departmanın ölçekçe mümkün en derin sorununu teşhis edebilen profil türü korunur; çünkü bilgi açığı için danışman yolu sistemsel olarak kapanmamalıdır.
- Kart puan bütçesi korunur ve sınırı aşan örnekler geçersiz sayılır; çünkü örnekler onaylı kuralı değiştirmez.
- Oyun parası ve gerçek para aynı ücretli kart olasılıklarını kullanır, oyun parası yolu makul kalır; çünkü bilgi açığının çözümü gerçek paraya bağlanmamalıdır.
- İnsan Yönetimi departmanı aynı kişi olayı payı hedefine uyar; çünkü yatay önleme etkisi tek departmanda iki kat avantaj yaratmamalıdır.
- Bir aylık sözleşme seçilirse uzatılamaz; çünkü aylık karar ritmi ilk yarıda yeni bir karar fırsatı sunmaz.
