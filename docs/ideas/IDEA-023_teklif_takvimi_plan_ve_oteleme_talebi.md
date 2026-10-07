# IDEA-023 — Teklif Takvimi (Gantt), Bağlayıcı Plan, Teslim Öteleme Talebi ve Gecikmeli Posta

## Durum/Tur

Durum: DRAFT — Kullanıcının 2026-10-07 cevapları kaydedildi; Claude incelemesi ve kullanıcı onayı bekleniyor. Bu IDEA oyun kuralı değildir. [IDEA-017](IDEA-017_teklif_kapasite_yuku_gantt_tedarik.md) (teklif, kapasite yükü, Gantt/FIFO) ve [IDEA-019](IDEA-019_akan_zaman_ve_ofis_merkezi.md) (akan zaman, gün bazlı gecikme) ilgili kalır.
Tur: 1
Tarih: 2026-10-07
Bağımlılıklar: IDEA-017, IDEA-019, IDEA-021, IDEA-022.

## Öneri

**Gözlem.** Teklif ekranındaki aylık ortalama kapasite grafiği oyuncuyu korkutuyor ("kapasitemi aşıyor mu?") ve ne zaman bitireceğini göstermiyor. Tek tezgahla çoğu ilan tek başına birkaç ay yer kaplıyor; sıradaki işler görünmediği için oyuncu üçüncü işi alamıyor.

### 1. Teklif takvimi (Gantt)
- Teklif ekranının altında, işin gerektirdiği her tezgah türü için bir şerit: **mavi** = kabul edilmiş işlerin tezgahtaki yeri, **sarı** = müşterinin izin verdiği süre (bugünden istenen teslime), **yeşil/kırmızı** = bu işin bugünkü ayarlarla yeri (süre içinde yeşil, geç kalıyorsa kırmızı ve "N gün geç"). Zaman ekseni aylarla (3, 6, 9, 12).
- Eski altta çıkan uyarı satırı ve aylık kapasite grafiği teklif ekranından kalkar; kapasite (Kapasite sekmesi) ayrı tasarımla yenilenir.
- Takvim motorun gerçek hesabından gelir: eski işler sırayla (en eski ilk), hammadde gelişi ve müşteri hazırlığı dahil, üretim gün gün simüle edilir (prototip: `plan_schedule`).

### 2. Bağlayıcı plan (kullanıcı onayı)
- Kullanıcı tezgah ikonuna dokunur, **basit bir pencere** açılır. Oyuncuya karışık gelmemesi için girdiler az: iş yükü, mevcut ayarlarla günlük kapasite (vardiya, mesai, hızlandırma Yönetim'den otomatik gelir ve burada salt okunur gösterilir), hesaplanan süre, **güvenlik payı** (%0–30) ve **başlangıç günü** (çubuk sürüklenerek).
- Plan **bağlayıcıdır**: teklif kabul edilirse plan kaydolur; iş planlanan başlangıçtan önce üretime girmez, aralık rezerve görünür ve sonraki ttekliflerde dolu çıkar. Plan bozulursa (vardiya düşürüldü gibi) ay başı penceresi uyarır ([IDEA-022](IDEA-022_vardiya_personel_sozlesmesi_ve_tazminat.md)).
- Teslim süresi planın bitişinden gelir; müşteri planı bilmez, yalnız teklif edilen süreyi görür (mevcut fiyat limiti/gecikme kuralları geçerli).
- Plan **gün düzeyinde** saklanır (gün bazlı gecikmeyle uyumlu).

### 3. Teslim öteleme talebi (kabul edilmiş işlerde)
- Fabrika > İşler'de bir işi seç, "Mail at": **teslim tarihini X ay ötelemek** iste. Yanıt mail zinciriyle gelir (kabul / ret / indirimli karşı teklif).
- Müşterinin kabul olasılığı: **aciliyet** (acil müşteri hiç esnemez, esnek ≈ 2 aya kadar), **teslim skoru**, **istenen süre** (her ek ay hızla düşürür), **teslime ne kadar kaldığı** (uzak kolay, son ay zor), **geçmiş talepler** (ilk talep ücretsiz, sonrakiler olasılığı düşürür), **tazminat** (indirim önerisi olasılığı artırır; ör. ayda %2).
- Kabulde teslim tarihi kayar ve gecikme cezası doğmaz; retle bir şey değişmez ama talep sayacı artar.

### 4. Posta akışı
- Müşteri yanıtı teklif gönderildikten **5–10 saniye** sonra gelir (gerçek zaman); mail kendiliğinden açılmaz. Alt menüde **Mail simgesinin üstünde kırmızı rozet** okunmamış sayısını gösterir; yeni mail gelince kısa bildirim çıkar. Oyuncu rozete dokunup maili kendisi açar.

## Notlar (Claude)

### Aldığım Notlar
- Prototipte takvim, posta gecikmesi ve rozet çalışır; bağlayıcı plan penceresi, rezervasyon ve öteleme talebi henüz yoktur.
- Mevcut iş sırası FIFO'dur ve motor planı kendisi yürütür; bağlayıcı plan için `_job_started_day`'e planlanan başlangıç ve rezervasyon eklenmelidir.

### Bulduğum Sakıncalar
- Rezervasyon tek tezgahlı fabrikada esnekliği azaltır; boş aralık "kaybolabilir" (plana yazılan boşluk başka iş alınmasını engeller). Askıya alma ([IDEA-021](IDEA-021_odeme_kosullari_surekli_is_ve_is_onceligi.md)) bunu hafifletir.
- Güvenlik payı oyuncunun teslim sözüne yazdığı ek süredir; çok bol payla her zaman "güvenli" teklif verilebilir ve müşteri fiyat limitini düşürür, bu denge ayrıca sınanmalı.

### Kafama Yatmayanlar
- Plan penceresinde vardiya/mesai salt okunur kalırsa oyuncu "ya 2. vardiya olsaydı?" sorusunu deneyemez; kısa bir "dene" anahtarı sonradan eklenebilir.

### Açık Sorular
- Öteleme talebi için gün sınırı: son kaç gün içinde yapılamaz?
- Plan rezervasyonu iptal edilirse (iş askıya alındı) boşluk hemen açılsın mı?
- Güvenlik payının üst sınırı ve fiyat limitine etkisi.

## Açık Kararlar

- Güvenlik payı üst sınırı ve etkisi.
- Öteleme talebinin zaman sınırı ve tazminat oranı.
- Plan rezervasyonunun iptal kuralı.

## Karar Özeti

- Kullanıcı: Gantt'ı teklifin altında göster, **plan bağlayıcı olsun**, **gün düzeyinde saklansın**, öteleme talebi **teslim tarihi** için olsun, öteleme faktörleri ve "ilk talep ücretsiz" kuralı uygundur. Plan penceresindeki girdi listesi çok karışık bulundu; sade tutulur (güvenlik payı ve başlangıç günü).
- Mailler 5–10 saniye gecikmeli gelir, kendiliğinden açılmaz, Mail simgesinde bildirim rozeti olur.
- Altta çıkan eski gecikme uyarısı Gantt gelince kalkar.
- Onaylı FREEZE yoktur.
