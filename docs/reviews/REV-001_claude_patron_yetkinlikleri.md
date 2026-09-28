# REV-001 — Claude Review: IDEA-001 Patron Yetkinlikleri

Reviewed file: `docs/ideas/IDEA-001_patron_yetkinlikleri.md`
Reviewer: Claude
Status: REVIEW (bu dosya bir eleştiridir, karar değildir)
Date: 2026-09-27

Not: Bu inceleme IDEA-001'i yeniden yazmaz. Aşağıdaki maddeler bulgu + sınıflandırmadır. Düzeltme önerisi yalnızca gerçekten gerekli görülen yerlerde verilmiştir.

---

## CRITICAL

### C1. "Görme" ile "çözme" birbirine karıştırılmış — çözüm mekaniği tanımsız
Doküman yalnızca patronun bir sorunu **görüp göremeyeceğini** tanımlıyor. Sorunu gördükten sonra ne olur? Otomatik mi çözülür, bir aksiyon/kaynak/zaman mı gerekir, başarısızlık ihtimali var mı? Bu, tüm sistemin çekirdek oyun döngüsü olacağı için en kritik boşluk. "Görünürlük = çözüm" varsayımıyla ilerlenirse, yetkinlik tek başına hem teşhis hem tedavi anlamına gelir ki bu, müdür/danışman sistemlerini daha da anlamsızlaştırır (bkz. C2).

### C2. Danışman (ve iyi müdür), patron yetkinliğini fiilen devre dışı bırakabilir — dominant strateji riski
Danışman "geçici olarak" patronun göremediği yüksek Tier sorunları teşhis edebiliyor. Eğer danışman maliyeti oyun ekonomisine göre düşükse, rasyonel strateji şu hale gelir: yetkinlik biriktirmek yerine "iyi müdür + sürekli danışman" kombinasyonuyla ilerlemek. Bu, IDEA-001'in temel amacını ("kariyer deneyimi patronlukta anlamlı olmalı") doğrudan çürütür. Danışmanın etkisinin *neden* geçici, *ne kadar* pahalı ve *hangi limitlerle* sınırlı olduğu netleşmeden bu risk somut bir tehdit olarak kalır.

Öneri (yalnızca gerekli görüldüğü için): Danışman/iyi müdür telafisine sert bir üst sınır ve artan maliyet eğrisi (kullanım arttıkça pahalılaşan, azalan getiri) eklenmesi gerekir; aksi halde sistem "yetkinlik biriktir" yerine "parayla yetkinliği satın al"a kayar.

### C3. İlk fabrika başarısızlığında oyuncuya hangi sinyal veriliyor, belirsiz — "adil olmayan ceza" riski
Örnek profil (Finans 30, İnsan Yönetimi 25 vb.) kasıtlı olarak dengesiz. Doküman "oyuncunun ilk başarısızlığı hangi alanda deneyim eksik olduğunu öğretmeli" diyor, ama aynı zamanda "yetkinlik yetersizse gerçek neden bulanık/gizli kalır" da diyor. Bu iki cümle birlikte okunduğunda çelişkili bir tasarım hedefi ortaya çıkıyor: sistem kasıtlı olarak nedeni gizliyorsa, oyuncu nasıl öğrenecek? Eğer iflasın gerçek kök nedenini (örn. T4 satın alma yolsuzluğu) oyuncu hiç göremiyorsa, bu "öğretici başarısızlık" değil, "opak başarısızlık" olur — istenmeyen türde gereksiz ceza. Post-mortem / özet ekranı gibi bir telafi mekanizması (tam Tier detayını değil ama "hangi departman zayıftı" seviyesinde bir sinyal) olmadan bu madde çelişkili kalır.

### C4. Tier eşik aralıkları tutarsız ve dengelemeye açık değil
Eşikler: 30→T1, 50→T2, 70→T3, 90→T4, 100→T5. İlk üç kademe 20 puan aralıklarla ilerlerken, T4→T5 sadece 10 puanlık nominal fark. Ancak yetkinlik kazanımı muhtemelen doğrusal değil (90'dan 100'e çıkmak 0'dan 30'a çıkmaktan çok daha zor olabilir — dokümanda bu varsayım da yok). Sonuç: T5 (en derin, en "hikaye değeri yüksek" sorunlar — yolsuzluk, komisyon vb.) pratikte hiçbir oyuncunun ulaşamayacağı bir eşik olabilir. Bu hem içerik israfı (10 departman × T5 senaryosu hiç görülmeyebilir) hem de dengeleme riski.

---

## IMPORTANT

### I1. Yetkinlik düşebilir mi sorusu açık — ama bu, tekrar oynanabilirliği doğrudan etkiliyor
Doküman bunu zaten "kesinleşmemiş konular" altında listelemiş, doğru. Ancak şunu ekliyorum: eğer yetkinlik hiç düşmüyorsa, optimal strateji "birkaç yetkinliği erken maksimuma çıkar, sonra rahatla" olur ve bu her run'da yakınsayan tek bir strateji yaratır (tekrar oynanabilirliği azaltır). Yetkinliğin department kullanılmadığında yavaşça erimesi (skill rust) ya da yetkinliğin yalnızca *aktif olarak o departmanla ilgilenildiğinde* korunması, farklı run'larda farklı uzmanlaşma yollarını teşvik edebilir.

### I2. Müdür/danışman/ortak/uzman çalışan/dış kaynak/eğitim — altı farklı telafi yolu var ama hiçbiri parametrik olarak ayrışmamış
Şu an hepsi işlevsel olarak eşdeğer görünüyor: "eksik yetkinliği kapatır." Maliyet, hız, güvenilirlik, risk (örn. kötü niyetli danışman/ortak ihtimali) gibi eksenlerde ayrışmazlarsa, oyuncu tek bir "en verimli" seçeneği bulup diğer beşini hiç kullanmaz (scope creep: 6 sistem tasarlanır, 1 tanesi oynanır).

### I3. Tier senaryosu şablonu (fiyat → termin → tek tedarikçi → kayırma → komisyon) 10 departmanda tekrarlanacaksa, "her yerde yolsuzluk" temasına indirgenme riski
Satın Alma örneği çok iyi kurulmuş (bkz. GOOD/KEEP), ama bu şablon Bakım, Ar-Ge, İnsan Yönetimi gibi departmanlara birebir uyarlanırsa (T5 = her zaman "birileri para çalıyor") tekrarlayıcı ve inandırıcılıktan uzak hissettirebilir. Bakımda T5 belki "ekipman sabotajı" değil "kritik arıza verisi gizleniyor" gibi departmana özgü bir doku istiyor olabilir. Bu, 10 × 5 = 50 benzersiz senaryo yazım yükü doğurur — implementasyon riski olarak da işaretliyorum.

### I4. Kariyer → patronluk geçişinde yetkinliğin kalıcılığı belirsiz
"Oyuncunun ilk başarısızlığı sonraki kariyerinde ne öğrenmesi gerektiğini öğretmeli" ifadesi, başarısızlık sonrası yeni bir kariyere (muhtemelen sıfırlanmış ya da kısmen sıfırlanmış yetkinliklerle) başlandığını ima ediyor. Ama "eğitim/sonradan öğrenme" fabrika sahibiyken de yetkinlik kazanılabileceğini ima ediyor. İkisi çelişmiyor olabilir ama doküman bunu açıkça ayırmıyor: iflas = oyun sonu / yeni run mu, yoksa aynı karakterle devam mı? Bu, temel oyun döngüsünün (roguelike-vari mi, tek-hayat simülasyon mu) belirlenmesi için önce netleşmesi gereken bir karar.

### I5. Statlar ile yetkinlik arasındaki etkileşim formülsüz
"Statlar öğrenme hızını, çözüm süresini/maliyetini, başarı oranını etkiler" deniyor ama hiçbir sayısal ilişki yok. Bu aşamada normal (IDEA seviyesi), ama ileride dengeleme için erken uyarı: 10 yetkinlik × birden fazla stat × 4 etki kanalı (hız/süre/maliyet/başarı) kombinasyonu hızla kontrol edilemez hale gelebilir.

---

## MINOR

### M1. "Toplam teorik maksimum: 1000" sayısının oyun içi bir anlamı şu an yok
Doküman bunu zaten "kesinleşmemiş konular"da not etmiş (5 oyun yılında hedef toplam seviye). Şu haliyle sadece dekoratif bir toplam; bir hedef/skor olarak kullanılmayacaksa hiç belirtilmemesi daha sade olur.

### M2. Tier isimlendirmesi iki farklı anlamda kullanılıyor
"Tier" hem "patronun görünürlük seviyesi" hem de "sorunun derinlik seviyesi" için kullanılıyor. Bunlar aynı sayı olsa da kavramsal olarak iki farklı şey (biri patronun özelliği, biri sorunun özelliği). İleride "Tier 3 patron" ile "Tier 3 sorun" ifadeleri karışabilir; ayrı terimler (örn. "Görüş Seviyesi" vs "Sorun Derinliği") karışıklığı azaltabilir.

### M3. "Bir departmanda aynı anda kaç problem bulunabilir" sorusu zaten açık madde olarak listelenmiş — buna ek olarak, farklı departmanlardaki sorunların birbirini tetikleyip tetiklemeyeceği (örn. Satın Alma T4 → Kalite T2) de netleşmeli, çünkü örnek ilk-oyun profilinde birçok düşük yetkinlik birden var ve gerçekçi bir simülasyonda bunlar birbirini besleyebilir.

---

## GOOD / KEEP

### G1. 2x2 müdür/patron matrisi (iyi/kötü müdür × bilgili/bilgisiz patron) net ve sezgisel
Bu çerçeve hem tasarımcı için hem oyuncuya öğretmek için güçlü bir zihinsel model. Korunmalı.

### G2. "Mükemmel patron her şeyi kendisi yapan değildir" tasarım ilkesi tutarlı ve tematik olarak güçlü
Gerçek KOBİ/üretim yönetimi mantığıyla örtüşüyor (bilmediğini bilmek, doğru kişiye devretmek). Bu ilke, projenin genel "the Boss" temasıyla iyi hizalanmış.

### G3. Satın Alma T1→T5 örnek eskalasyonu (fiyat → termin → tek tedarikçi bağımlılığı → kayırma → komisyon) gerçekçi ve iyi kurgulanmış
Diğer departmanlar için şablon olarak kullanılabilir, ancak I3'te belirtildiği gibi birebir kopyalanmamalı.

### G4. Oyuncunun her işi bilmesinin zorunlu olmaması ve erken fabrika kurabilme özgürlüğü
Bu, oyunun "tek doğru yol" hissi vermesini engelliyor ve farklı stil oyunculara (yetkinlik-ağırlıklı vs. yönetim-ağırlıklı) alan açıyor — replayability açısından olumlu, I1'deki riskle dengelenmesi gerekiyor.

---

## Özet

Sistemin **temel felsefesi** (yetkinlik = görüş derinliği, statlar = hız/verim çarpanı, müdür/danışman = telafi ama ikame değil) sağlam ve orijinal. Ancak üç şey netleşmeden implementasyona geçilmesi riskli:

1. Görünürlük sonrası **çözüm mekaniği** (C1) — şu an tamamen tanımsız.
2. Danışman/iyi müdürün patron yetkinliğini **ikame etmesini önleyecek** somut bir maliyet/limit modeli (C2).
3. Başarısızlık sonrası oyuncuya **en azından departman düzeyinde** bir geri bildirim sinyali (C3) — aksi halde "öğretici kayıp" yerine "opak kayıp" olur.

Bunlar çözülmeden Tier eşiklerinin (C4) kesinleştirilmesi anlamsız, çünkü eşiklerin "doğru" olup olmadığı ancak çözüm mekaniği belliyken test edilebilir.
