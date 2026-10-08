# IDEA-024 — Alım Öncesi "Kasa Aylık Gideri Karşılamalı" Korumasının Kaldırılması

## Durum/Tur

Durum: DRAFT — Kullanıcı kararı 2026-10-08 kaydedildi; Claude incelemesi bekliyor. Bu IDEA oyun kuralı değildir; prototip, kararı denemek için uygular. [FRZ-002 v4](../freeze/FRZ-002_v4_fabrika_ekonomisi.md) §3 CURRENT kalır.
Tur: 1
Tarih: 2026-10-08
Bağımlılıklar: FRZ-002 v4 (kullanılabilir nakit), IDEA-021 (finansman gideri görünürlüğü).

## Öneri

**Gözlem.** Mobil prototipte tezgah, ekipman ve yer alımlarında "alımdan sonra kasa bu ayın giderini karşılamalı" koruması vardı. Kullanıcı bu uyarıyı ve kuralı kaldırmak istedi: oyuncu parası yettiği sürece alım yapabilsin; sonuçlar (negatif kasa, finansman gideri, batış) oyunun kendi hesabından gelsin.

**Öneri (kullanıcı kararı).** Alım koruması yalnızca "fiyat nakdi aşamaz" olarak kalır ("Yetersiz nakit."). Gider karşılama koşulu kalkar. Negatif nakdin bedeli ay sonu finansman giderinden gelir (nakit borcun altına inince açığın aylık %2'si) ve bu artık Serbest nakit ekranında ve Aksiyon listesinde görünür.

## Notlar (Claude)

### Aldığım Notlar
- FRZ-002 v4 §3, FRZ-001 güvence kontrolünde "kullanılabilir oyun parası"nı tanımlar; alım korumasını doğrudan zorunlu kılmaz, ancak prototipin alım kuralı bu tanımı kullanıyordu. Kaldırma, güvence kontrolünü etkilemez.

### Bulduğum Sakıncalar
- Oyuncu alımdan sonra o ayın giderlerini ödeyemeyecek duruma gelebilir; "peşinat 0 + yüksek alım" birleşimi hızlı batışa götürür. Bu, kullanıcının istediği "acı tecrübe" ile uyumlu, ama simülasyonla dengesi sınanmalı.
- Batış mektubundaki "serbest nakit negatifti" cümlesi bu durumlarda daha sık çıkar.

### Kafama Yatmayanlar
- Uyarının tamamen kalkması yeni oyuncu için sürpriz batış yaratabilir; Serbest nakit satırındaki kırmızı uyarı yeterli mi, 1. ayda bir kerelik öğretici ipucu gerekir mi?

### Açık Sorular
- Alım sonrası serbest nakit eksiye düşecekse onay penceresinde kısa bir bilgi satırı gösterilsin mi?

## Açık Kararlar

- Onay penceresinde eksi serbest nakit bilgisi.

## Karar Özeti

- Kullanıcı: kasa uyarısı kalksın, kural da gitsin (2026-10-08). Uygulandı; "Yetersiz nakit." koruması duruyor.
