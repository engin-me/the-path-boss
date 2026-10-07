# IDEA-021 — Ödeme Koşulları (Peşinat + Hakediş), Sürekli İş, Aciliyet Etiketi, Küçük İş Primi ve İş Önceliği/Askıya Alma

## Durum/Tur

Durum: DRAFT — Kullanıcının 2026-10-06 notları ve cevapları kaydedildi; Claude incelemesi ve kullanıcı onayı bekleniyor. Bu IDEA oyun kuralı değildir. [FRZ-004 v2](../freeze/FRZ-004_v2_is_alma_ve_makine_yatirimlari.md) teklif/iş alma kuralları ve [IDEA-017](IDEA-017_teklif_kapasite_yuku_gantt_tedarik.md) (teklif, aciliyet, tedarikçi vadesi) CURRENT/ilgili kalır; prototip bu IDEA'daki sayıları denemek için kullanılabilir.
Tur: 1
Tarih: 2026-10-06
Bağımlılıklar: FRZ-004 v2, IDEA-017, IDEA-019 (akan zaman, gün bazlı gecikme), IDEA-022 (vardiya ve personel).

## Öneri

**Gözlem (oyun notları).** Teklifte peşinatı 0'a çekmek işi alma ihtimalini yükseltiyor ve kâr marjı yüksek tutulabiliyor; nakdin bir bedeli olmadığı için bu bedava kazanç. Oyuncu kabul edilmiş işi gerektiğinde araya yeni, daha kârlı işi alamıyor. Küçük işlerde yüksek marj gerçek hayatta normal ama oyunda aynı eğriye bağlı. Müşterinin aciliyeti gizli bir sayı; oyuncu neden bazı işlerde "teslim uzatılamaz" tepkisi aldığını bilmiyor.

### 1. Ödeme koşulları: peşinat + hakediş
- Teklifte iki seçim: **peşinat** (%0–100) ve **kalan bakiyenin ödeme biçimi**: *Teslimde tek seferde* ya da *Hakediş* (üretilen iş yükü oranında her ay).
- Müşteri açısından en rahat koşul teslimde tek seferde ödeme, sonra hakediş, sonra yüksek peşinat. Müşterinin ödeyeceği üst fiyat buna göre oynar (öneri: teslimde tek seferde +%4, hakediş nötr; peşinatın etkisi puan başına %0,4'ten %0,25'e inerek yumuşar).
- **Nakdin bedeli:** serbest nakit (Yönetim ekranındaki "Gerçekten harcanabilir") eksiye düşünce otomatik kısa vadeli borç ve aylık faiz (öneri %3/ay) devreye girer. Böylece "peşinat 0, marj yüksek" artık ücretsiz değil; hakediş uzun işlerde hammadde yükünü dengeler.
- Mevcut yardımcı: kasa kartı ve `commitments()` (kasa − ödenecek hammadde − aylık gider) bu hesabın girdisidir.

### 2. Sürekli İş (çerçeve sözleşme)
- İlanlarda "Sürekli İş" etiketli işler: 12 ay, **aylık sabit iş yükü**, düşük ama garantili marj, her ay hakedişle ödeme.
- Bir tezgah türünün kapasitesinin bir kısmını (öneri %20–40) bağlar; teslimat bozulursa sözleşme biter ve ceza oluşur.
- Küçük fabrikaya istikrarlı taban ve zorluk azaltıcı olarak açılır; ne zaman ilan edileceği teslimat skoruna ve fabrika büyüklüğüne bağlı olabilir (öneri: skor ≥ %70).

### 3. Aciliyet etiketi
- Gizli aciliyet sayısı (1–10) aynen kalır; ilanda yalnız **Acil / Normal / Esnek** etiketi gösterilir.
- Kural açık yazılır: acil müşteri **fiyata daha toleranslı, gecikmeye hiç toleranslı değil**. Teslim süresi uzatılamıyorsa fiyat limiti yükselir (mevcut davranış) ve oyuncu bunu görür.

### 4. Küçük iş primi (gizli kural)
- **Küçük** = iş yükü eşiğinin altı. Kural arayüzde yazılmaz; oyuncu kabul ihtimali göstergesini oynatınca keşfeder.
- Küçük işte marj arttıkça kabul ihtimali **yavaş** düşer (müşterinin kabul ettiği üst fiyat dağılımı geniş); normal işte hızlı düşer. Baz marj değişmez. Marj tavanı %100 kalır.
- Büyük iş statüsü: Sürekli İş ile örtüşür (düşük marj, garanti).

### 5. İş önceliği ve askıya alma
- Kabul edilmiş işlere **öncelik sırası**; oyuncu sıra değiştirebilir ve bir işi **askıya alabilir**. Askıdaki işin kapasitesi sıradaki işe gider.
- Maliyeti doğal olarak gecikmeden gelir (gün bazlı gecikme: teslim skoru gün başına doğrusal düşer). Acil müşteri etiketli iş askıya alınırsa skor kaybı ek olabilir (açık).
- Hammadde ve peşinat işlemleri değişmez.

### 6. Fason işler
- Fason işte müşteri malzemeyi verir; teklif işleme maliyeti üstüne marjdır, malzeme üstüne marj yoktur. Kullanıcı fasonun diğer işlerden (öneri ≈ %30) az kazandırmasını istedi. **Önce ölçülür:** makine saati başına kâr fason ve normal işte karşılaştırılır; fark zaten kuralın doğal sonucuysa ek ceza konmaz (kullanıcı: kurgu yeterli görünüyorsa pas geçilebilir).

## Notlar (Claude)

### Aldığım Notlar
- Peşinat etkisi (30 puan nötr, puan başı %0,4) ve teslim gecikmesi limiti (1 ay %15, 2 ay %42; aciliyet ≥ 8'de ret) prototipte çalışıyor. Hakediş yalnız başına "peşinat 0" sorununu çözmez; nakdin faizi şart.
- Gün bazlı gecikme (IDEA-019) askıya almanın bedelini zaten taşıyor.

### Bulduğum Sakıncalar
- Hakediş + Sürekli İş birlikte ay sonu kasa akışını karmaşıklaştırır; Özet kasa kartı ve Log buna hazır olmalı.
- Faiz çok sert olursa oyun daha da zorlaşır (kullanıcı oyunun zor olduğunu söyledi); eşik ve oran simülasyonla ayarlanmalı.
- Küçük iş primi tek bir eşiğe bağlanırsa sınırda marj sıçraması olur; yumuşak (log ölçekli) eğri önerilir.
- Askıya alma FIFO tahsisini bozar; projeksiyon (teslim tahmini) ve kapasite grafiği öncelik sırasını okumalı.

### Kafama Yatmayanlar
- Aciliyeti etiketle açmak oyuncuya fiyat ipucu verir; kural "acil = daha yüksek fiyat kabulü" olduğu için bu, ihtimal göstergesinden zaten okunabilir. Zarar küçük görünüyor.

### Açık Sorular
- Hakedişin müşteri etkisi tam olarak ne olsun (+%4 teslimde tek seferde önerisi)?
- Kısa vadeli borç faizi ve limiti; iflas eşiği (FRZ-003 v2) ile ilişkisi.
- Sürekli İş ne zaman çıksın, kaç tane aynı anda olabilir, iptal cezası?
- Küçük iş eşiği kaç μ/ω-ay olsun?
- Askıya alma ücretsiz mi, acil müşteri ek ceza alsın mı?

## Açık Kararlar

- Hakediş müşteri etkisi, faiz oranı ve limiti.
- Sürekli İş parametreleri.
- Küçük iş eşiği ve eğrisi.
- Askıya alma cezası.
- Fason için ek ceza gerekip gerekmediği (önce ölçüm).

## Karar Özeti

- Kullanıcı peşinatın (özellikle küçük işte) alınmamasını bir seçenek olarak görüyor ve ödemeyi teslimde tek seferde yerine **hakedişe** bağlamayı makul buluyor; nakde bedel konmalı.
- Aciliyet bilgisi oyuncuya etiketle gösterilebilir; teslim uzatılamayan acil işte fiyat limiti yükselmeli.
- Çalışan işi askıya alma / öncelik fikri kullanıcıdan geldi.
- Küçük işler iş yükü ile tanımlanır, kural yazılmaz; oyuncu keşfeder; marj yükseldikçe kabul ihtimali küçük işte yavaş düşer. Büyük/sürekli iş: 12 ay, düşük garantili marj, "Sürekli İş" etiketi.
- Fason için ek ceza kurgu yeterliyse gerekmez (kullanıcı pas geçti).
- 2026-10-07 kullanıcı onayı: küçük iş/büyük iş/Sürekli İş kurgusu ve marj eğrisi uygundur. Büyük ilanlar listede görünür, ama **işin hacmine göre** bir iş geçmişi ve teslim skoru ister; ilan üzerinde "bu işe teklif verebilmek için en az X iş bitirmiş olmalı ve %Y teslim skorun olmalı" yazar. Prototip: iş yükü ≥ 6.000 ω → 2 iş ve %70; ≥ 11.000 ω → 4 iş ve %80 (ilanların en büyük %25 ve %10'u).
- 2026-10-07 prototip: hakediş (parçalı tahsilat) etkin; ay sonunda yapılan işin %80'i tahsil edilir, peşinat mahsup edilir, kalan teslimde gelir. Teslimde tek seferde seçeneği ve fiyat farkı henüz karara bağlanmadı.
- Onaylı FREEZE yoktur.
