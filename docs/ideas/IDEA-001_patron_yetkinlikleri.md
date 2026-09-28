# IDEA-001 — Patron Yetkinlikleri

Status: DRAFT
Date: 2026-09-27
Öneriyi dosyaya işleyen: Codex (kullanıcının verdiği metinden)

## Amaç

Oyuncunun çalışanlık kariyerinde edindiği deneyimin, fabrika sahibi olduğunda doğrudan anlamlı hale gelmesini sağlamak.

Patronun gücü yalnızca para veya statlardan değil, geçmişte hangi işleri ne kadar öğrendiğinden gelmeli.

## Patron Yetkinlikleri

Her yetkinlik 0-100 arasındadır.

1. Üretim
2. Planlama
3. Depo & Sevkiyat
4. Bakım
5. Kalite
6. Satın Alma
7. Finans
8. Ar-Ge / Ür-Ge
9. Yatırım
10. İnsan Yönetimi

Toplam teorik maksimum: 1000.

## Temel Mantık

Yetkinlik doğrudan üretim/verim bonusu değildir.

Yetkinlik, patronun ilgili departmandaki sorunları ne kadar derinden görebildiğini belirler.

Önerilen görünürlük eşikleri:

- 30 -> Tier 1
- 50 -> Tier 2
- 70 -> Tier 3
- 90 -> Tier 4
- 100 -> Tier 5

Yetkinlik yetersizse daha yüksek Tier sorunların varlığı hissedilebilir ancak gerçek neden bulanık/gizli kalır.

Örnek:

Satın Alma performansı düşüktür.

- T1: Fiyatlar piyasanın üzerinde
- T2: Tedarikçi termin performansı kötü
- T3: Tek tedarikçiye aşırı bağımlılık
- T4: Satın alma müdürü belirli tedarikçiyi kayırıyor
- T5: Müdür tedarikçiden kişisel ödeme/komisyon alıyor

Satın Alma yetkinliği 70 olan patron T1-T3 sorunlarını görebilir; T4-T5'i teşhis edemez.

## Müdür Etkisi

Müdürün kendi uzmanlığı bazı düşük Tier sorunları patrona ulaşmadan çözebilmelidir.

Kötü müdür + bilgili patron:
Patron sık sık müdahale eder; zaman ve para kaybeder.

İyi müdür + bilgisiz patron:
Sistem çoğunlukla yürür ancak müdürün çözemediği derin problemlerde patron teşhis koyamaz.

İyi müdür + bilgili patron:
İdeal yapı.

Kötü müdür + bilgisiz patron:
Yüksek işletme riski.

## Statların Rolü

Statlar doğrudan yetkinlik puanı veya Tier açmaz.

Statlar:
- yetkinlik kazanma hızını,
- problem çözme süresini,
- problem çözme maliyetini,
- bazı görevlerdeki başarı oranını

etkileyebilir.

Örnek:
Çok yüksek Zeka, hayatında satın almada çalışmamış bir patronun T4 satın alma sorununu otomatik görmesini sağlamaz.

## Kariyerden Patronluğa Geçiş

Oyuncunun fabrika kurması için bütün yetkinliklerinin yüksek olması gerekmez.

Oyuncu erken fabrika kurabilir ve eksik altyapısının sonuçlarını yaşayabilir.

Örnek ilk oyun:

- Üretim: 90
- Depo & Sevkiyat: 80
- Planlama: 35
- Bakım: 35
- Kalite: 35
- Satın Alma: 30
- Finans: 30
- Ar-Ge / Ür-Ge: 25
- Yatırım: 30
- İnsan Yönetimi: 25

Bu oyuncunun fabrikayı kurabilmesi mümkündür ancak işletmenin uzun süre ayakta kalması zor olabilir.

Oyuncunun ilk başarısızlığı sonraki kariyerinde hangi alanlarda deneyim kazanması gerektiğini öğretmelidir.

## Eksik Yetkinliği Kapatma Yolları

Oyuncunun her işi yapmış olması zorunlu değildir.

Eksikler şunlarla kapatılabilir:

- iyi müdür
- danışman
- ortak
- uzman çalışan
- dış kaynak
- eğitim / sonradan öğrenme

Danışman özellikle patronun göremediği daha yüksek Tier sorunları geçici olarak teşhis edebilir.

## Tasarım İlkesi

Mükemmel patron her şeyi kendisi yapan kişi değildir.

Neyi bildiğini bilir.
Neyi bilmediğini bilir.
Bilmediği işi kime bırakacağını bilir.

## Henüz Kesinleşmeyen Konular

- Yetkinlik Tier eşikleri kesin mi?
- Yetkinliklerin kariyer boyunca kazanılma hızı
- 5 oyun yılında hedef toplam yetkinlik seviyesi
- Müdürlerin Tier çözme matematiği
- Danışmanların fiyatlandırılması ve etki süresi
- Statların öğrenme hızına vereceği maksimum bonus
- Bir departmanda aynı anda kaç problem bulunabileceği
- Yetkinlik düşebilir mi, yoksa yalnızca artar mı?

## Claude İncelemesi — 2026-09-27 (önceki inceleme)

Kaynak: [REV-001](../reviews/REV-001_claude_patron_yetkinlikleri.md). Özgün incelemenin tamamı orada duruyor; ana bulgular önerinin yanında da görülebilsin diye buraya aktarıldı. Bu bölüm eleştiridir, onaylanmış karar değildir.

- **C1:** Patronun sorunu ne zaman teşhis edebildiği açıklanıyor; teşhisten sonra gereken aksiyon, zaman, maliyet ve başarısızlık riski açıklanmıyor. Görünürlük sorunu kendiliğinden çözmemeli.
- **C2:** Ucuz ve tekrar kullanılabilir danışman/müdür desteği, kariyerde kazanılan yetkinliği gereksiz kılabilir. İnceleme, monetizasyon ilkesini gözeterek sınır ve artan maliyet önerdi.
- **C3:** Oyuncu oyun sırasında bir sinyal ve başarısızlık sonrasında geri bildirim almazsa gizli kök nedenler erken fabrika kaybını keyfî hissettirebilir.
- **C4:** Önerilen Tier eşikleri ve ilerleme, çözüm döngüsü tanımlandıktan sonra sınanmalı.

## Claude Devam Notu — 2026-09-28 (kullanıcı tarafından aktarıldı)

Kullanıcı Claude'un bulut oturumundaki yanıtını iletti. Bu bölüm henüz Claude tarafından doğrudan dosyaya yazılmadı.

- **C1 önerisi:** Yüzeysel müdahale, derindeki neden sürüyorsa sorunun geri dönmesine yol açabilir. Patron müdahalesi sınırlı yönetim zamanı harcamalı. Her soruna özgü seçenek yazmanın içerik yükü nedeniyle ertelenmesi önerildi.
- **C2 önerisi:** Danışmanın erişimi patronun bir Tier üstüyle sınırlanabilir; derin sorunun kaynağı müdürün kendisi de olabilir. Gerçek parayla satılan danışmanlık, oyunun yarattığı sorunlara zorunlu çözüm olmamalı.
- **C3 önerisi:** Oyun sırasında departman düzeyinde açıklanamayan kayıp, fabrika başarısızlığından sonra değerlendirme raporu gösterilebilir. İkisi de `docs/03_GAME_OVERVIEW.md` dosyasının 9. ve 23. bölümlerinde var; IDEA ile bağları açık değil.
- **Bağımlılık:** Fabrika başarısızlığının yeni bir oyunu mu başlattığı, yoksa aynı karakterin mi devam ettiği açık.

## Codex Yanıtı — 2026-09-28

- **C1:** Teşhisten sonra oyuncunun bir karar vermesi gerekiyor. Az sayıda yeniden kullanılabilir müdahale türü, her sorun için ayrı seçenek yazmadan bunu sağlayabilir. Zaman ve oyun parası maliyetleri `GAME_OVERVIEW` 22. bölümle uyumlu. Sorun, keyfî bir sayaç yüzünden değil, çözülemeyen kök neden yüzünden geri gelmeli.
- **C2:** Evrensel `patron Tier + 1` tavanı, patronun bilmediği işi uzmana bırakabilmesi ilkesiyle çatışabilir. Danışman daha derin bir sorunu teşhis edebilir; rapor kapsamı, süre, oyun içi kaynaklar ve ayrıca müdahale kararı gerekliliği onu sınırlar. Sorunun bazen müdürden kaynaklanması tek başına baskın strateji riskini çözmez. Gerçek para zorunlu çare olmamalı.
- **C3:** `GAME_OVERVIEW` 9. ve 23. bölümler oyun içi sinyal ile başarısızlık raporunu zaten öneriyor. Bunların ayrıntı düzeyi tasarlanmalı. Raporun biçimi, fabrika kapanışından sonra karakterin devam edip etmeyeceği kararı verilmeden de ele alınabilir.

## Karar Kaydı

Durum: AÇIK — kullanıcı tarafından onaylanan karar ve bu konuya ait FREEZE yok.

Sonraki inceleme için önerilen yön: teşhisi müdahaleden ayırmak; kariyer deneyimini gereksiz kılmadan uzmanların gerçek bilgi açığını kapatmasına izin vermek; gizli kayıpları oyun sırasında ve fabrika kapanışından sonra anlaşılır kılmak.

Açık seçenekler: yeniden kullanılabilir müdahale türleri; danışman kapsamı ve oyun içi maliyeti; gizli kaybın ne kadarının gösterileceği; rapor ayrıntısı; fabrika kapanışından sonra karakterin devamı; Tier eşikleri.
