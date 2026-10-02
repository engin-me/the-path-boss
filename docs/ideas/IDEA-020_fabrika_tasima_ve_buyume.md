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
- **Taşınma:** Daha büyük (ya da farklı) bir fabrikaya taşınılabilir. Tezgahlar yeni plandaki yuvalara kurulur. Üretim durur: 10 tezgaha kadar 1 ay, 20'ye kadar 2 ay, 30'a kadar 3 ay (`ceil(tezgah / 10)`). Gerçek hayatta taşıma hızlı yapıldığı için süre tezgah sayısıyla doğrusal ama kısa tutulur.
- **Maliyet:** Eski sözleşmenin çıkış bedeli (2 kira), tezgah başına taşıma bedeli ($1.000), fabrika sınıfı büyüyorsa gerekli ekipman setinin farkı. Yeni kira hemen başlar; taşınma süresince işler bekler ve teslimler kayabilir.
- **Kısıt:** Yeni yerin yuva sayısı mevcut tezgahı karşılamalı; tavan makineleri sığdırmalı; kasa, çıkış + taşıma + ilk kira + gizli sorun güvencesini karşılamalı.
- **Fabrika büyütme** (aynı yerde ek alan) ve **ikinci fabrika** (iki yer birlikte, normal tezgah teslimat süreleri) bu IDEA'nın kapsamı dışındadır; ikinci fabrika ayrı bir IDEA olarak ele alınır (devredilmiş yönetim gerekir, aksi halde patron saati yetmez).

## Notlar (Claude)

Henüz incelenmedi. Prototip uygulaması (`shell_boss.gd` `move_factory`) şu kısıtlarla çalışır:

### Bulduğum Sakıncalar
- Taşınma sırasında tezgahlar "yolda" sayıldığından personel ücreti ödenmiyor; gerçek hayatta maaş sürer. Bedel yalnız çıkış + taşıma + gecikmeler.
- Eski fabrikadaki kredi/ipotek durumu taşınmayı engellemiyor (makineler ipotekli kalabilir).
- Yeni fabrikaya geçişte ekipman setinin fazlası (küçülürken) iade edilmiyor.

### Açık Sorular
- Taşınma sırasında maaşlar ve hammadde siparişi nasıl işlesin?
- Küçülerek taşınmada fazla tezgah satışı zorunlu mu?
- Taşınma ay ortasında yapılabilirse (IDEA-019) süre gün düzeyinde nasıl hesaplanır?

## Açık Kararlar

- Taşınma süresi formülü (`ceil(tezgah / 10)`) ve taşıma bedeli ($1.000 / tezgah).
- Ekipman farkının ödenmesi ve küçülme durumunda iade.
- İkinci fabrikanın kapsamı (ayrı IDEA).

## Karar Özeti

- Kullanıcı diğer fabrikalara bakmayı, daha büyük fabrikaya taşınmayı (1 ay üretim duruşu, tezgah sayısına göre 10'a kadar 1 ay, 20'ye kadar 2 ay) ve ikinci fabrikayı ayrı düşünmeyi istedi; çünkü büyüme tek fabrikayla sınırlı kalmamalı ve taşıma gerçek hayatta hızlı yapılır. Onaylı FREEZE yoktur.
