# IDEA-017 — Teklif Süreci, Kapasite Yükü, Teslim Planı (Gantt) ve Tedarik

## Durum/Tur

Durum: DRAFT — Kullanıcının 2026-09-30 oyun testi sonrası önerdiği büyük tasarım kaydedildi; Claude incelemesi (özet aşağıda) ve Codex sentezi bekleniyor. Bu IDEA oyun kuralı değildir. Mevcut prototip (ShellBoss) işi "makine ayırma" modeliyle oynatır; bu IDEA onun yerine geçmeyi önerir.
Tur: 1
Tarih: 2026-09-30
Bağımlılıklar: [FRZ-002 v4](../freeze/FRZ-002_v4_fabrika_ekonomisi.md), [FRZ-004 v2](../freeze/FRZ-004_v2_is_alma_ve_makine_yatirimlari.md), [FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md), [IDEA-016](IDEA-016_makine_pazari_isler_ekipman_kredi.md).

## Öneri (GPT)

Bu bölüm kullanıcının mesajlarından Claude tarafından derlendi; Codex revize edebilir.

**İş ilanı yük ve teslim tarihi taşır.** İlan fiyatı yerine iş içeriği verilir: makine türü/seviyesi, parça adedi, teslim süresi (ör. 2 ayda 400 parça, 3 ayda 1000, 6 ayda 5000). Her işin parça başı işleme zorluğu çarpanı vardır (x); iş hacmi = adet × çarpan (400×2x = 800x, 1000×x = 1000x, 5000×2,5x = 12.500x). İşin ne kadar kapasite harcadığı ilanda yazmaz; oyuncu hesaplar. Makine kapasitesi x/ay cinsindendir (ör. standart torna 2000x/ay × OEE = 1500x/ay); toplam yük kapasiteyi aşarsa teslimat gecikir. Gecikmenin doğrudan cezası yoktur (FRZ-004 v2 korunur); zamanında teslimat skoru, sonraki tekliflerde müşterinin fiyat toleransını düşürür.

**Teklif verme.** İlanda fiyat yoktur; oyuncu fiyat, peşinat (%30 sabit veya seçilebilir) ve teslim süresi teklif eder. Oyun işin maliyetini bilir (örn. hammadde 100k + %15 hurda, genel gider payı 25k, personel 30k = 170k) ve iş seviyesine/makineye bağlı kâr marjıyla müşterinin hedef fiyat aralığını belirler (ör. 250–290k). Gizli aciliyet zarı (1–10) aralığın neresinden ödeneceğini belirler. Cevap e-postayla gelir: kabul, "fiyatı 280k'ya çekebilir misiniz?", "2 ayda teslim istiyoruz" veya ret. Retten sonra not: oyunun hesapladığı maliyet ve aciliyet durumu yazılır ki oyuncu mekaniği öğrensin. Aciliyet için ipuçları verilir (örn. "A firmasından Mary hanım 4 kez aradı").

**Kullanıcı kararları (2. tur):** Teklif revizyonunu müşteri ister; oyuncunun yanıtı yalnız evet/hayır (karşı teklif yok). Gantt telefonda pahalı olduğu için **FIFO** kabul edildi; bu durumda operasyon sırasının anlamı kalmaz: bir iş aynı anda ilgili bütün tezgahlarda yük oluşturur ve her tezgah türü kendi kuyruğunu FIFO ile eritir. Bırakılan iş ve geç teslim zamanında-teslimat skorunu düşürür, skor müşteri fiyat toleransını etkiler. Yük (x) işin özelliğidir: adet × zorluk çarpanı; tezgah seviyesi yükü değil, hızı (performans), hurdayı ve hangi işlerin alınabildiğini (en az seviye) belirler. Sıra: (1) yük + teslim tarihi + FIFO havuz + OEE/vardiya ([IDEA-018](IDEA-018_oee_vardiya_ve_kadro.md)), (2) tedarik, (3) teklif.

**Planlama (eski öneri, yerine FIFO geçti).** Kabul edilen işler bir Gantt görünümünde makine şeritlerine dizilir; oyuncu düzenlemezse oyun FIFO ile peş peşe dizer. İşler gelecekte başlayabilir; bu, makine teslimini beklerken de iş kabul etmeyi mümkün kılar.

**Tedarik.** İş alırken hammadde peşin düşmez. Hammadde kataloğu ve tedarikçiler vardır (A firması: 30 gün ödeme vadesi, %5 düşük fiyat, 7 gün gecikme riski vb.). Oyuncu, işin başlangıcına göre hammaddeyi ne zaman sipariş edeceğini Gantt'a göre planlar; temin süresi plana girer.

**Kısa vadeli düzeltmeler (prototipe girdi).** Kabul edilmiş iş bırakılabilir (ceza + ödenen hammadde yanar); makine her an satılabilir; zorunlu ekipman listesi ve fiyatları yükseltildi (1 transpalet, 10 kasa, 8 raf).

## Notlar (Claude)

Tur 1 · 2026-09-30 · Kısa özet; ayrıntı sohbette.

### Aldığım Notlar

- Yön tutarlı ve mevcut prototipten daha gerçekçi: yük bazlı kapasite (x/ay × OEE) "işin süresi boyunca makine tutma" modelinden daha doğru ve OEE ile doğal bağlanır. Mevcut model iş yükünü göstermiyor; işler yalnız makine ayırıyor.
- Hammadde peşin düşmesi ve peşinat, simülasyonda bulunan işletme sermayesi tuzağının (hammadde kabulde çıkar, gelir teslimde gelir) doğru ilacı: [`_shell_ozet.md`](../../godot/playtests/reports/_shell_ozet.md).
- Makine teslimini beklerken yapılacak iş sorusu da aynı çözümle kapanır: gelecekte başlayan işler ve tedarik planı.

### Bulduğum Sakıncalar

1. FRZ-004 v2 fiyat pazarlığını ve hammadde/iş kabul zamanını ilk sürümün dışında bırakıyor; bu IDEA ikisini de değiştirir (yeni FRZ-004 sürümü gerekir). FRZ-002 v4'ün nakit sırası (hammadde ayırma, gelirin teslim ayında yazılması) peşinat ve tedarikçi vadesiyle yeniden yazılmalı.
2. Fiyat aralığı ikili aramaya açıktır (oyuncu fiyat düşürüp dener). Teklif revizyonu sayısı sınırlı olmalı; her turda müşteri sabrı/fiyat toleransı düşmeli; ret notu hedef aralığın tamamını değil, yalnız maliyeti ve aciliyeti göstermeli.
3. Yük (x) × zorluk çarpanı, makine seviyesi ve çok makineli işler (4 makine isteyen iş) ile nasıl birleşir: rota (operasyon sırası) mı, makine tutma mı? İlk dilim için tek operasyonlu işler önerilir.
4. Gantt dokunmatik ekranda pahalı bir arayüzdür. İlk dilim salt okunur zaman çizelgesi ve "yukarı/aşağı taşı" ile otomatik FIFO; sürükle-bırak sonra.
5. Kapsam genişliyor (tedarikçi, stok, teklif yazışması, Gantt). Sıra önerisi: (1) iş yükü + teslim tarihi + otomatik FIFO, (2) tedarik ve hammadde vadesi, (3) teklif ve pazarlık.
6. İş yükü parça sayısı, zorluk çarpanı ve OEE ile değişken; tek kalem "x" yerine eşlenik gösterimi (parça, x, ay) FRZ-002 v4 çıktı eşdeğeri ile uzlaştırılmalı.

### Kafama Yatmayanlar

- Prototipte Faz 2 uygulandı: müşteri peşinatı %30 kabulde, hammadde tedarikçiden sipariş edilir (temin süresi, ödeme vadesi, gecikme riski, kalite/verim), gelmeden üretim başlamaz, işi bırakmak peşinatı iade ettirir. Sonuçlar `godot/playtests/reports/_shell_ozet.md`.
- Hammadde ödemesi başlangıca bağlandığında, işi erken kabul etmek ücretsiz bir seçenek olur; teslim ve iptal/bırakma kuralları bu açığı kapatmalı.

### Açık Sorular

1. Zamanında teslimat skoru nasıl hesaplanır, ne kadar hızlı değişir, fiyat toleransını hangi aralıkta etkiler?
2. Bırakılan iş skoru etkiler mi; ceza sabit %10 mu?
3. Peşinat sabit %30 mu yoksa oyuncu seçimi mi; peşinat iade edilir mi?
4. İlk dilimde kaç revizyon turu?

## Açık Kararlar

- Yük modeli (x/ay), iş zorluk çarpanı ve çok makineli işlerin temsili.
- Teklif mekaniği (aralık, aciliyet zarı, revizyon sınırı, ret notu).
- Tedarikçi modeli (vade, fiyat, gecikme) ve stok.
- FIFO havuz kuralı (tezgah türü başına kuyruk, en az seviye kapısı, aynı anda çok türlü iş yükü) ve sonradan Gantt.
- Zamanında teslimat skorunun fiyat toleransına etkisi.

## Karar Özeti

- Kullanıcı işin hacim ve teslim süresiyle ilan edilmesini, fiyatın teklifle belirlenmesini, hammaddenin tedarikçi vadesiyle planlanmasını ve işlerin Gantt'ta FIFO ile dizilmesini önerdi; çünkü planlama ve nakit akışı gerçek üretim yönetimini yansıtmalı. Onaylı FREEZE yoktur.
