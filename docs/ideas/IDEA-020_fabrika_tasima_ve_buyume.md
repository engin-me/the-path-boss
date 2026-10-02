# IDEA-020 — Fabrika Taşıma ve Büyütme (İkinci Fabrika Ayrı)

## Durum/Tur

Durum: DRAFT — Kullanıcının 2026-10-02 önerisi ve cevapları kaydedildi; Claude incelemesi ve Codex sentezi bekleniyor. Bu IDEA oyun kuralı değildir. [FRZ-003 v2](../freeze/) çıkış bedeli ve [IDEA-015](IDEA-015_fabrika_kiralama_ve_mobil_arayuz.md) kiralama kuralları CURRENT kalır; prototipte "taşınma" bunların üstüne eklenmiştir.
Tur: 1
Tarih: 2026-10-02
Bağımlılıklar: IDEA-015, IDEA-016, IDEA-018, IDEA-019.

## Öneri (GPT)

**Gözlem.** Oyuncu bir fabrika kiraladıktan sonra başka fabrikalara bakamıyor, büyümek istediğinde yalnız sözleşmeyi bırakıp sıfırdan başlayabiliyor.

**Öneri.**
- Fabrika sayfasında oyuncu diğer kiralık yerleri görür.
- **Taşınma:** Daha büyük (ya da farklı) bir fabrikaya taşınılabilir. Tezgahlar yeni plandaki yuvalara kurulur. Üretim en fazla 1 ay durur (tezgah sayısından bağımsız); gerçek hayatta taşıma hızlı yapılır. Büyük park, süreyi değil taşıma bedelini artırır.
- **Maliyet:** Eski sözleşmenin çıkış bedeli (2 kira), tezgah başına taşıma bedeli ($1.000) ve ekipman ayrıştırması. Yeni kira hemen başlar; taşınma süresince işler bekler, teslimler kayabilir ve **personel ücretleri sürer**.
- **Ekipman ayrıştırması:** Eldeki set ve ek ekipmanlar tek tek sayılır; yeni fabrikanın listesi için eksik olan adetler alınır, fazlası ek ekipman olarak kalır.
- **Küçülerek taşınma:** Yeni yerin yuvasına sığmayan tezgahları oyuncu seçip satar; kalanlar taşınır, satılanların personeli düşer.
- **Sözleşme bitişi:** Mal sahibi tezgahları atmaz. Bitimden 2 ay önce Mail'e "Sözleşmeniz bitiyor" bildirimi düşer. Oyuncu Ofis → Fabrika → Sözleşme'den yeni süreyi seçerse (6/12/24 ay) kira bugünkü seviyede kalır (uzun süre indirimli). Karar vermezse sözleşme aynı süre için **piyasa kirasıyla (+%12)** yenilenir ve zam birikir. Sözleşmenin son ayında çıkış ya da taşınma için çıkış bedeli yoktur.
- **Kısıt:** Taşınan tezgah sayısı yeni yerin yuvasını aşmamalı (aşan satılır); tavan makineleri sığdırmalı; kasa, çıkış + taşıma + ilk kira + gizli sorun güvencesini karşılamalı.
- **Fabrika büyütme** (aynı yerde ek alan) ve **ikinci fabrika** (iki yer birlikte, normal tezgah teslimat süreleri) bu IDEA'nın kapsamı dışındadır; ikinci fabrika ayrı bir IDEA olarak ele alınır (devredilmiş yönetim gerekir, aksi halde patron saati yetmez).

## Notlar (Claude)

Henüz incelenmedi. Prototip uygulaması (`shell_boss.gd` `move_factory`) şu kısıtlarla çalışır:

### Bulduğum Sakıncalar
- İpotekli makine satılamadığı için küçülerek taşınmayı engelleyebilir.
- Fazla ekipman iade/satış edilmiyor, yalnız ek ekipman olarak kalıyor.
- Karar verilmeyen yenilemede zam sabit %12; piyasa kirasının dalgalanması (rastgele zam, sektör koşulu) yok.

### Açık Sorular
- Taşınma sırasında hammadde siparişi ve teslim tarihleri nasıl işlesin?
- Yenileme zammı sabit mi olsun, piyasaya göre değişsin mi? Mal sahibi kira artışı pazarlığı?
- Taşınma ay ortasında yapılabilirse (IDEA-019) süre gün düzeyinde nasıl hesaplanır?

## Açık Kararlar

- Taşınma süresi (en fazla 1 ay) ve taşıma bedeli ($1.000 / tezgah).
- Fazla ekipmanın satışı.
- İkinci fabrikanın kapsamı (ayrı IDEA).

## Karar Özeti

- Kullanıcı diğer fabrikalara bakmayı, daha büyük fabrikaya taşınmayı (en fazla 1 ay üretim duruşu, personel ücretleri sürer, küçülürken oyuncu seçtiği tezgahı satar) ve ikinci fabrikayı ayrı düşünmeyi istedi; çünkü büyüme tek fabrikayla sınırlı kalmamalı ve taşıma gerçek hayatta hızlı yapılır. Onaylı FREEZE yoktur.
