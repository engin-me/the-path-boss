# IDEA-019 — Akan Zaman (Duraklat / Hızlandır) ve Ofis Merkezi

## Durum/Tur

Durum: DRAFT — Kullanıcının 2026-10-02 oyun testi sonrası önerisi kaydedildi; Claude incelemesi ve Codex sentezi bekleniyor. Bu IDEA oyun kuralı değildir. Ay bazlı hesap çekirdeği ([FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md), [IDEA-014](IDEA-014_patron_operatorlugu_zaman_payi.md) aylık saat payı) CURRENT kalır; bu IDEA onay görürse "ay başı karar penceresi" ve "ayın bitişi" anlamını değiştirir.
Tur: 1
Tarih: 2026-10-02
Bağımlılıklar: FRZ-008 v2, IDEA-014, [IDEA-017](IDEA-017_teklif_kapasite_yuku_gantt_tedarik.md), [IDEA-018](IDEA-018_oee_vardiya_ve_kadro.md).

## Öneri (GPT)

Bu bölüm kullanıcının mesajlarından ve Claude'un düzenlemelerinden derlendi; Codex revize edebilir.

**Gözlem.** Bugün oyuncu yalnızca ay sonunda makinelerin ne yaptığını görüyor; zaman bir "Ayı çalıştır" düğmesiyle atlıyor. Makinelerin çalışma hissi yok ve ay başı/ay sonu karar penceresi yapay bir sınır yaratıyor.

**Öneri.**
- **Akan zaman.** Oyun zamanı gün gün akar. Oyuncu duraklatabilir, normal hızda ya da hızlandırılmış oynatabilir (ör. 1×/2×/4×). Ay değişince tarih alanında "Ay N" büyükçe belirir, solar ve küçük gösterge geri döner.
- **Durdurarak karar.** Araştırma ve yatırım için oyuncu zamanı durdurur: tezgah satın alır, iş ilanlarına bakar, teklif verir, sonra devam ettirir. Ay başında teklif/alım yapma zorunluluğu ve "rapor açıkken teklif verilmez" kısıtı kalkar; teklif, mail ve alım her an mümkündür.
- **Olaylar gün gün.** Mail yanıtları, makinenin teslim alınması, hammaddenin gelmesi, iş teslimi, ödemeler ve tahsilat ayın uygun gününde gerçekleşir ve ekranda görünür (kasa değişimi bildirimi gibi). Tezgahlar çalışırken üretim akışı kuşbakışı planda canlı görünür. Sürekli "+100, +100" gürültüsünü önlemek için ufak olaylar birikmiş kısa bildirime (ör. gün sonu özeti) toplanır; yalnız eşik üstü olaylar anlık gösterilir.
- **Ay sonu.** Ay sonu raporu, süre ayın son gününe ulaşınca otomatik açılır ve zamanı duraklatır. Rapor kapanınca zaman yeniden akabilir.
- **Ofis merkezi.** Özet, Fabrika (plan, vardiya, sözleşme), İşler, Tedarik ve Patron (yetkinlik, statlar, danışman, kredi) tek "Ofis" sekmesinde toplanır; alt bar Ofis, İlanlar, Mail olur. Fabrika ve patron masası fikri (teknik çizimli plan "Fabrikayı göster" ile açılır) bu sekmenin parçasıdır.

**Teknik not.** Hesap çekirdeği aylık kalabilir: gün sayacı yalnız sunum ve olay zamanlaması için eklenir, ay sınırında motor mevcut ay adımını çalıştırır. Böylece kayıtlar, simülasyon ve testler korunur; aylık patron saati (IDEA-014) ayın günleriyle orantılı tüketilir.

## Notlar (Claude)

Henüz incelenmedi. İlk gözlemler:

- **Aylık saat bütçesi.** Patron saati ayda sabit (FRZ-008 v2/IDEA-014); zaman akarken bu bütçenin ne zaman düştüğü tanımlanmalı (gün gün orantılı mı, ay başında mı).
- **Karar baskısı.** Duraklatma serbest olduğu için baskı oyuncuya kalır; ama hızlı modda teklif ve mail süresinin dolması ("firma başka tedarikçiye yöneldi") yeniden tanımlanmalı.
- **Teklifin geçerliliği.** Bugün teklif cevabı ay sonunda sona eriyor; akan zamanda "cevap penceresi" gün sayısıyla ifade edilmeli.
- **Test ve sim.** Motor aylık kaldığı sürece mevcut testler geçerli; gün düzeyinde olay sırası için yeni test gerekir.
- **Mobil.** Sürekli akan zaman pil ve dikkat tüketir; uygulama arka plana atılınca duraklatılmalı.

## Açık Kararlar

- Hız seçenekleri (1×/2×/4×) ve bir ayın gerçek süresi (öneri: normal hızda yaklaşık 20–30 sn).
- Hangi olaylar anlık gösterilir, hangileri gün sonu özetine girer; eşik değeri.
- Teklif/mail cevap penceresi ve süre dolumu kuralı.
- Patron aylık saatinin akan zamanda tüketimi.
- Arka planda zamanın durması ve açılışta durumun gösterilmesi.
- Ofis içinde Özet'in rolü (rapor akışı) ve patron masası görselinin kapsamı.

## Karar Özeti

- Kullanıcı ayın bitmesi/başlamasının önemini azaltmayı, zamanın akmasını, oyuncunun yatırım/araştırma için zamanı durdurmasını, olayların gün gün görünmesini ve Özet ile Fabrika'nın Ofis ekranında toplanmasını istedi; çünkü bugün makinenin çalıştığı yalnızca ay sonunda görülüyor ve yönetim ekranları dağınık. Onaylı FREEZE yoktur.
