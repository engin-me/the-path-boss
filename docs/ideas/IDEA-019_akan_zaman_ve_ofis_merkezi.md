# IDEA-019 — Akan Zaman (Duraklat / Hızlandır) ve Ofis Merkezi

## Durum/Tur

Durum: DRAFT — Kullanıcının 2026-10-02 oyun testi sonrası önerisi kaydedildi; Claude incelemesi ve Codex sentezi bekleniyor. Bu IDEA oyun kuralı değildir. Ay bazlı hesap çekirdeği ([FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md), [IDEA-014](IDEA-014_patron_operatorlugu_zaman_payi.md) aylık saat payı) CURRENT kalır; bu IDEA onay görürse "ay başı karar penceresi" ve "ayın bitişi" anlamını değiştirir.
Tur: 2
Tarih: 2026-10-02
Bağımlılıklar: FRZ-001 (müdahale zamanı), FRZ-002 (ay akışı), FRZ-008 v2, IDEA-014, [IDEA-017](IDEA-017_teklif_kapasite_yuku_gantt_tedarik.md), [IDEA-018](IDEA-018_oee_vardiya_ve_kadro.md).

## Öneri (GPT)

Bu bölüm kullanıcının mesajlarından ve Claude'un düzenlemelerinden derlendi; Codex revize edebilir.

**Gözlem.** Bugün oyuncu yalnızca ay sonunda makinelerin ne yaptığını görüyor; zaman bir "Ayı çalıştır" düğmesiyle atlıyor. Makinelerin çalışma hissi yok ve ay başı/ay sonu karar penceresi yapay bir sınır yaratıyor.

**Öneri.**
- **Akan zaman.** Oyun zamanı gün gün akar. Oyuncu duraklatabilir, normal hızda ya da hızlandırılmış oynatabilir (ör. 1×/2×/4×). Ay değişince tarih alanında "Ay N" büyükçe belirir, solar ve küçük gösterge geri döner.
- **Durdurarak karar.** Araştırma ve yatırım için oyuncu zamanı durdurur: tezgah satın alır, iş ilanlarına bakar, teklif verir, sonra devam ettirir. Ay başında teklif/alım yapma zorunluluğu ve "rapor açıkken teklif verilmez" kısıtı kalkar; teklif, mail ve alım her an mümkündür.
- **Olaylar gün gün.** Mail yanıtları, makinenin teslim alınması, hammaddenin gelmesi, iş teslimi, ödemeler ve tahsilat ayın uygun gününde gerçekleşir ve ekranda görünür (kasa değişimi bildirimi gibi). Tezgahlar çalışırken üretim akışı kuşbakışı planda canlı görünür. Sürekli "+100, +100" gürültüsünü önlemek için ufak olaylar birikmiş kısa bildirime (ör. gün sonu özeti) toplanır; yalnız eşik üstü olaylar anlık gösterilir.
- **Ay sonu.** Ay sonu raporu, süre ayın son gününe ulaşınca otomatik açılır ve zamanı duraklatır. Rapor kapanınca zaman yeniden akabilir.
- **Ofis merkezi.** Özet, Fabrika (plan, vardiya, sözleşme), İşler, Tedarik ve Patron (yetkinlik, statlar, danışman, kredi) tek "Ofis" sekmesinde toplanır; alt bar Ofis, İlanlar, Mail olur. Fabrika ve patron masası fikri (teknik çizimli plan "Fabrikayı göster" ile açılır) bu sekmenin parçasıdır.

**Teknik not (prototipte uygulandı).** Aylık fiyat, kira, maaş ve rapor aylık kalır; üretim ve nakit olayları gün adımıyla çalışır (`advance_day`): tezgah kapasitesi günde 1/30 üretir, tezgah ve hammadde kendi teslim gününde devreye girer (makine alınma günü = teslim günü), tedarikçi ödemesi vade gününde düşer, biten iş aynı gün teslim edilir ve kalan bakiye o gün gelir. Ay ortasında gelen tezgahın işletme gideri varış gününden orantılanır. Gün oynanmadan çağrılan eski aylık `run_report` yolu (testler, simülasyon, akan zaman kapalıyken) aynı sonucu verir; kayıtlar `day` / `days_run` alanlarını isteğe bağlı taşır. Ay içinde vardiya değişikliği ücrete ay sonunda tam ay yansır (orantılı ücret açık konu).

## Notlar (Claude)

Tur 2 · 2026-10-02 · Kullanıcı yönü onayladı; ChatGPT yorumu işlendi.

### Aldığım Notlar
- Yön: oyuncu zamanı durdurup karar verir, devam edince kararın sonucunu yaşar; olaylar gün gün görünür (kullanıcı onayı).
- Ofis ilk görünümü işletmenin durumunu okutmalı: şu an ne çalışıyor/bekliyor, yaklaşan teslim ve ödemeler, kararımı bekleyen konu. Fabrika planı, maliyet ve yetkinlik buradan açılır.

### Bulduğum Sakıncalar
- **Motor aylık kalamaz.** İlk taslaktaki "gün sayacı yalnız sunum" yetersizdi: ayın 20'sinde gelen tezgâh, ayın 25'inde alınan iş, ay ortasında artan vardiya kapasite ve ücreti gün düzeyinde etkiler. Aylık fiyat, bütçe ve rapor korunabilir; üretim, hammadde varışı, teslimat ve ödeme gün veya olay adımıyla hesaplanmalıdır. Mevcut motor ve testlerin aynen geçerli kalacağı varsayımı yapılmamalı.
- **Rapor kesintisi.** Normal hızda bir ayın 20–30 sn olması, ay sonu raporunu her 20–30 sn'de oyunu kesen bir işe çevirir. İlk dönemde aylık raporla durma öğretici olabilir; sonra rapor erişilebilir kalmalı ve oyuncu hangi olaylarda otomatik durulacağını seçebilmeli. Kritik olay durdurur, olağan teslimat ve küçük hareketler toplu özete girer.
- **Patron zamanı.** "Gün gün orantılı tüketim" yetmez: operatörlüğe ayrılmış gelecek saatler bugün Düzelt'e harcanabilir mi? Harcanmış, ayrılmış ve kullanılabilir saatler ayrılmalı. Serbest duraklatma oyun içi zaman maliyetini ortadan kaldırmamalı.
- **Bağımlılıklar.** FRZ-001'in müdahale zamanı ve FRZ-002'nin ay akışı kuralları etkilenir.

### Kafama Yatmayanlar
- Aylık patron saatinin (IDEA-014) akan zamanda nasıl tüketileceği tanımsız.
- Teklif ve mail cevabının ay sonunda sona ermesi akan zamanla uyumsuz.

### Açık Sorular
- Önce küçük bir deneme: tek makine, tek iş, tek tedarikçiyle akan zaman. Teslim, üretim, ödeme ve duraklatmanın hissi görülsün; sonra Ofis düzeni büyütülsün.
- Uygulama arka plana geçince zaman durur (kesin).

## Açık Kararlar

- Hız seçenekleri (1×/2×/4×) ve bir ayın gerçek süresi (öneri: normal hızda yaklaşık 20–30 sn).
- Hangi olaylar anlık gösterilir, hangileri gün sonu özetine girer; eşik değeri.
- Teklif/mail cevap penceresi ve süre dolumu kuralı.
- Patron aylık saatinin akan zamanda tüketimi: harcanmış / ayrılmış / kullanılabilir saat ayrımı.
- Hangi olayların oyunu otomatik durduracağı ve oyuncunun bunu seçebilmesi; ilk dönemde zorunlu aylık rapor duraklaması.
- Ay ortasında vardiya değişiminde ücretin gün orantılı hesabı; teklif cevap süresinin gün sayısıyla ifadesi; patron saatinin gün düzeyinde tüketimi (üretim, hammadde varışı, ödeme ve teslim gün adımına alındı).
- Ofis ilk ekranının içeriği (ne çalışıyor, yaklaşan teslim ve ödemeler, kararımı bekleyenler).
- Arka planda zamanın durması ve açılışta durumun gösterilmesi.
- Ofis içinde Özet'in rolü (rapor akışı) ve patron masası görselinin kapsamı.

## Karar Özeti

- Kullanıcı ayın bitmesi/başlamasının önemini azaltmayı, zamanın akmasını, oyuncunun yatırım/araştırma için zamanı durdurmasını, olayların gün gün görünmesini ve Özet ile Fabrika'nın Ofis ekranında toplanmasını istedi; çünkü bugün makinenin çalıştığı yalnızca ay sonunda görülüyor ve yönetim ekranları dağınık. Onaylı FREEZE yoktur.

## Not: Tolerans payı (kabul sonrası seçim)
Müşterinin toleransı, işi yapacak makinenin hassasiyetinden genişse (log5 ölçeğinde 0–1 pay) kabulde bir seçim çıkar: **hızlı işle** (en çok +%25 çıktı, hurda aynı) ya da **hurdayı azalt** (en çok −%50 hurda, hız aynı). Seçim iş kartından sonradan değiştirilebilir. Hassas makinenin kaba işi alması (CNC'nin 0,3 mm işi) en yüksek payı verir.

## Not: Kapasite grafiği
Fabrika > Kapasite: her tezgah türü için tolerans sınıfı (0,1 / 0,01 / 0,001 mm) başına koyu çubuk = net kapasite, açık çubuk = kabul edilmiş işlerin aylık yükü (kalan iş ÷ teslime kalan ay). İş önce kendi seviyesindeki tezgahı doldurur, taşan yük daha ince tezgaha kayar (altın). Yolda olan tezgah taralı, karşılanamayan yük kırmızı. Teklif ekranında yalnız işin gerektirdiği türler gösterilir; teklifin yükü beyaz çerçevedir.

## Not: Gün bazlı gecikme ve tezgah hızlandırma
- Gecikme gün sayılır (vade = vade ayının 30'u). Teslim skoru hedefi doğrusal düşer: zamanında 1,0 → 30+ gün geç 0,4. Müşterinin fiyat limiti ve ret kuralı hâlâ ay bazlıdır (süreyi oyuncu ay seçer).
- Tezgah hızlandırma (kart üzerinde tik + kaydırıcı, en çok +%25): çıktı artar; hurda ve bakım ×(1+2,4·h), enerji ×(1+1,6·h). Tolerans payı hız bonusuyla birlikte toplam +%35'i geçemez. "Tüm … tezgahlara uygula" aynı tür ve seviyeye kopyalar.

## Not: Batış mektubu
Zorunlu kapanışta (iflas ya da tasfiyeyle kapanma) oyun uyarı vermek yerine sonradan öğretir: "bunun %95 ihtimalle belliydi" diyen, en ağır 3 hatayı (gelir < gider, boş alan, işsiz vardiya, boşta tezgah, borçla kapatma, düşük teslimat skoru) sayan, sonra toparlayan bir mektup yazar. Mektup hem kapanış ekranında hem Mail'de görünür; ardından "Operatör olarak yeniden başla". Başlangıçta uyarı gösterilmez (oyuncu denemek ister; acı tecrübe daha öğretici).
