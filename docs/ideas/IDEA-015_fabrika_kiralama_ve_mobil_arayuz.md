# IDEA-015 — Fabrika Kiralama Sözleşmesi ve Mobil Arayüz İskeleti

## Durum/Tur

Durum: DRAFT — Kullanıcının 2026-09-30 tasarım kararları kaydedildi; Claude incelemesi ve Codex sentezi bekleniyor. Bu IDEA oyun kuralı değildir. Arayüz iskeleti (`godot/factory_shell.tscn`) mock veriyle çalışır ve kuralları BossState'e bağlamaz.
Tur: 1
Tarih: 2026-09-30
Bağımlılıklar: [FRZ-003 v2](../freeze/FRZ-003_v2_iflas_ve_fabrika_satisi.md), [FRZ-004 v2](../freeze/FRZ-004_v2_is_alma_ve_makine_yatirimlari.md), [FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md); açık [IDEA-013](IDEA-013_fabrika_kurulusu_ve_operasyon_cekirdegi.md) alan/kira konuları.

## Öneri (GPT)

Bu bölüm kullanıcının sohbetteki kararlarından Claude tarafından derlendi; Codex revize edebilir.

**Arayüz.** Dikey mobil. Üstte tarih ve oyun parası; altta sabit beş ana sekme: Özet, İşler, Tezgah, Fabrika, Profil. Sayfa içi alt sekmeler yatay kaydırılan çip satırıdır; ana çubuk kaydırılmaz. Detay ekranları (ilan detayı, Danışman Ara, Kredi) sekme çubuğu görünürken açılır ve "Geri" taşır. Fabrika kiralanana kadar İşler ve Tezgah kilitlidir. Özet, kiralanan fabrikanın görselini arka plan yapar ve son ay raporunu (makine, yatırım, güncel değer, OEE, kapasite) gösterir. Departmanlar ve Düzelt, Özet'in alt sekmesidir. Oyuncuya ay sonu için sabit "Ayı bitir" eylemi verilir; saat gösterilmez.

**Para birimi.** Oyun parası USD gösterilir. İlk denemede yalnız gösterim çarpanıdır (1 oyun birimi = $1.000); kural ve denge değişmez.

**Fabrika ilanı.** Kullanılabilir m², tavan yüksekliği, aylık kira, sözleşme süresi (6/12/24 ay; uzun sözleşme daha ucuz kira), bölge adı (mekanik etkisi yok) ve görsel. Erken çıkışta 2 kira ceza ödenir; çıkarken hatırlatılır. İflasta kalan kira borcu 0 olur. Makineye de yükseklik gereksinimi eklenir; makine yükseklik ve alan yetmezse kurulamaz. Kira ve alan değerleri örnektir; kiranın mevcut sabit giderle ilişkisi IDEA-013'te açıktır.

**İş ilanı.** Ayrı gecikme cezası gösterilmez (FRZ-004 v2 korunur). İlan riski şöyle yazar: teslim edilemezse gelir yazılmaz, malzeme maliyeti gider. Oyuncu kapasitesi elverdiği sürece aynı anda birden çok iş alır (FRZ-004 v2 ile uyumlu; kapasiteyi aşma sonradan yeniden ele alınacak). Kabul öncesi önizleme boş kapasiteyi gösterir.

**Kapsam dışı.** Teşvik, depozito, altyapı/elektrik, bölgenin mekanik etkisi, yerleşim.

## Notlar (Claude)

Tur 1 incelemesi bekleniyor.

## Açık Kararlar

- Erken çıkışın kalan sözleşmeyle ilişkisi: sabit 2 kira ilk ayda çıkışı ucuz yapar (12 kira yerine 2); sözleşmenin gerçek kilit olup olmayacağı.
- Kira ve sözleşme kuralının FRZ-003 v2 tasfiye ve satış hesabına nasıl girdiği; iflasta kira borcunun 0 olması.
- Makine yükseklik gereksiniminin kurulum kuralı olarak dondurulup dondurulmayacağı ve değerleri.
- Kiranın mevcut sabit gider (30) yerine mi üstüne mi geldiği (IDEA-013).
- USD gösterim çarpanının kalıcı olup olmayacağı.

## Karar Özeti

- Kullanıcı fabrika kiralama için 6/12/24 ay sözleşme, 2 kira erken çıkış cezası, iflasta kira borcunun sıfırlanması, makine ve fabrikada yükseklik bilgisi, USD para birimi, ayrı gecikme cezası olmaması ve aynı anda birden çok iş kabulünü istedi; çünkü kiralama gerçek bir esneklik/ucuzluk tercihi yaratmalı, arayüz ise kural eklemeden mobil akışı göstermeli. Onaylı FREEZE yoktur.
