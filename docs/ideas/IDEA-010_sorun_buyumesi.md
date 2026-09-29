# IDEA-010 — Çözülmeyen Sorunların Büyümesi

## Durum/Tur

Durum: DRAFT — kullanıcı taslak yönünü onayladı; [FRZ-002 v4 taslağı](../freeze/FRZ-002_v4_fabrika_ekonomisi.md) henüz CURRENT değildir.
Tur: 1
Tarih: 2026-09-29
Bağımlılık: [FRZ-002 v3](../freeze/FRZ-002_v3_fabrika_ekonomisi.md) §1–2 ve [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md) §4.

## Öneri (GPT)

### Sorunun bedeli zamanla artar

Çözülmeyen her sorun satırının aylık potansiyel kaybı, oluşum ayındaki kaybına göre izlenir. Karar ayı sonunda hâlâ açık olan satır sonraki ay için %5 büyür; büyüme başlangıç kaybının iki katında durur. Oran bütün Tier'lerde aynıdır. Bağlı satırlar birlikte oluşmaya devam eder; büyüme mevcut satırları etkiler, yeni bağlı satır doğurmaz. Bir kök çözülürse bağlı bütün kayıpları sonraki raporda kalkar.

Bu öneri [IDEA-001](IDEA-001_patron_yetkinlikleri.md) içinde açık bırakılan “ertelenen sorunun büyüme hızı” sorusunu kapatmak içindir; geçerli FREEZE dosyalarını kendi başına değiştirmez.

Büyüyen potansiyel kayıp rapora yazılmadan önce mevcut departman yaklaşık %20 kayıp tavanı ve fabrika genelinde en az %33 gerçekleşme tabanıyla sınırlanır. Rapor hâlâ FRZ-002 v3'teki çıktı eşdeğeri birimini kullanır; nakit ve rapor kaybı iki kez sayılmaz. Böylece gizli satırın büyüme oranı Tier'ini ele vermez ve eski ekonomik sınırlar korunur.

### Gerekçe ve test

[Claude patron testi](../../godot/playtests/claude_bulgular.md) derin sorunu düzeltmenin çoğu zaman ekonomik olmadığını, gizli satırların biriktiğini ve danışmanın az kullanıldığını gösterdi. [ChatGPT patron testi](../../godot/playtests/chatgpt_bulgular.md) kör denemenin danışman yolundan güçlü kaldığını ve orta bilgi düzeyinin gizli sorun birikimini durdurmadığını gösterdi. Sayılar prototip girdileridir; sorun büyümesinin kesin denge etkisi yeniden oynanarak ölçülür.

### Danışman fiyatı ayrı denge işi

Büyüme uygulandıktan sonra tipik bir departmanın 1–2 aylık gizli zararı, danışman sözleşme fiyatı için patron testinde karşılaştırma düzeyi olsun. Bu bir fiyat FREEZE'i değildir; [FRZ-006 v2](../freeze/FRZ-006_v2_danisman_pazari.md) ücretin kesin değerini açık bırakmaya devam eder.

## Notlar (Claude)

Yeni tur incelemesi henüz yapılmadı. Claude'un patron testi kod ve sonuç çalışması bu bölümde tasarım değerlendirmesi olarak kaydedilebilir.

## Açık Kararlar

- %5 ve iki kat sınırının uzun oyunlarda nakit/iflas döngüsüne etkisi oynanarak sınanacak; değişmesi gerekirse yeni IDEA turu açılacak.
- Birden çok satır departman tavanına çarptığında sınırlı rapor kaybının satırlara dağıtım ayrıntısı, toplam tavan ve Tier gizliliğini koruyacak biçimde uygulanacak.
- Danışman fiyatının 1–2 aylık kayıp düzeyine göre kesin tutarı denge konusudur; FRZ-006 v2'yi bu IDEA değiştirmez.

## Karar Özeti

- Kullanıcı çözülmeyen satırın aylık zararını her ay %5 büyütüp başlangıcın iki katında durdurmayı taslak yönü olarak onayladı; çünkü derin sorunları süresiz ertelemek bedelsiz kalmamalı.
- Kullanıcı aynı büyüme oranını bütün Tier'lere uygulamayı ve mevcut %20 departman ile %33 gerçekleşme sınırlarını korumayı onayladı; çünkü gizli Tier kayıp hızından anlaşılmamalı ve işletme kaybı sınırsızlaşmamalı.
- Kullanıcı büyümenin yeni bağlı satır yaratmamasını onayladı; çünkü FRZ-001'in bütün bağlı satırların aynı olayda doğması kuralı korunmalı.
- Kullanıcı danışman fiyatını büyümeden sonra tipik 1–2 aylık gizli zararla test etmeyi, fiyatı henüz FREEZE etmemeyi seçti; çünkü ekonomideki yeni kayıp hızı görülmeden kesin ücret dengelenemez.
