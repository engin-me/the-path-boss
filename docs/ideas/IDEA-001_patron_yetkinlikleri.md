# IDEA-001 — Patron Yetkinlikleri

## Durum/Tur

Durum: DRAFT
Tur: 1
Son güncelleme: 2026-09-28
Kaynak: Kullanıcının sağladığı ilk öneri Codex tarafından dosyaya işlendi.

## Öneri (GPT)

### Amaç

Oyuncunun çalışanlık kariyerinde edindiği deneyimin, fabrika sahibi olduğunda doğrudan anlamlı hale gelmesini sağlamak.

Patronun gücü yalnızca para veya statlardan değil, geçmişte hangi işleri ne kadar öğrendiğinden gelmeli.

### Patron Yetkinlikleri

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

### Temel Mantık

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

### Müdür Etkisi

Müdürün kendi uzmanlığı bazı düşük Tier sorunları patrona ulaşmadan çözebilmelidir.

Kötü müdür + bilgili patron:
Patron sık sık müdahale eder; zaman ve para kaybeder.

İyi müdür + bilgisiz patron:
Sistem çoğunlukla yürür ancak müdürün çözemediği derin problemlerde patron teşhis koyamaz.

İyi müdür + bilgili patron:
İdeal yapı.

Kötü müdür + bilgisiz patron:
Yüksek işletme riski.

### Statların Rolü

Statlar doğrudan yetkinlik puanı veya Tier açmaz.

Statlar:
- yetkinlik kazanma hızını,
- problem çözme süresini,
- problem çözme maliyetini,
- bazı görevlerdeki başarı oranını

etkileyebilir.

Örnek:
Çok yüksek Zeka, hayatında satın almada çalışmamış bir patronun T4 satın alma sorununu otomatik görmesini sağlamaz.

### Kariyerden Patronluğa Geçiş

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

### Eksik Yetkinliği Kapatma Yolları

Oyuncunun her işi yapmış olması zorunlu değildir.

Eksikler şunlarla kapatılabilir:

- iyi müdür
- danışman
- ortak
- uzman çalışan
- dış kaynak
- eğitim / sonradan öğrenme

Danışman özellikle patronun göremediği daha yüksek Tier sorunları geçici olarak teşhis edebilir.

### Tasarım İlkesi

Mükemmel patron her şeyi kendisi yapan kişi değildir.

Neyi bildiğini bilir.
Neyi bilmediğini bilir.
Bilmediği işi kime bırakacağını bilir.

## Notlar (Claude)

Kaynak: İlk ayrıntılı inceleme [REV-001](../reviews/REV-001_claude_patron_yetkinlikleri.md); aşağıdaki son tur notları kullanıcının aktardığı Claude yanıtından özetlendi. Bir sonraki turda Claude bu bölümün içeriğini doğrudan günceller.

### Aldığım Notlar

- GAME_OVERVIEW 9. bölümde oyun içi bilinmeyen sorun sinyali, 23. bölümde fabrika başarısızlık raporu zaten öneriliyor; IDEA ile bağları açık değil.
- Görünürlük sonrasındaki çözüm döngüsü henüz tanımlı değil.

### Bulduğum Sakıncalar

- Ucuz ve sürekli danışman/müdür desteği, kariyerde kazanılan patron yetkinliğini gereksiz kılabilir.
- Gerçek parayla satılan danışmanlık, oyunun yarattığı sorunlara zorunlu çözüm olmamalı.
- Tier eşikleri çözüm döngüsü belli olmadan kesinleştirilmemeli.

### Kafama Yatmayanlar

- Yüzeysel çözümün ne zaman geri döneceği ve patron müdahalesinin zaman maliyeti belirsiz.
- Danışmanın patronun en fazla bir Tier üstünü görmesi önerisi, derin bilgi açığını kapatma amacıyla sınanmalı.

### Açık Sorular

- Teşhisten sonra hangi müdahaleler mümkün?
- Danışmanın kapsamı ve sınırı ne olacak?
- Oyuncuya gizli kayıp ve başarısızlık nedeni hangi ayrıntıda gösterilecek?

## Açık Kararlar

- Teşhis sonrası yeniden kullanılabilir müdahale türleri ve bunların zaman/oyun parası maliyeti.
- Danışman, müdür ve ortağın patron bilgisini hangi kapsamda tamamlayacağı.
- Oyun içi açıklanamayan kayıp sinyalinin ve fabrika başarısızlık raporunun ayrıntı düzeyi.
- Fabrika kapanışından sonra aynı karakterin devam edip etmeyeceği.
- Yetkinlik Tier eşikleri, kazanılma hızı, düşüşü ve beşinci yıl hedefi.
- Müdürlerin sorun çözme matematiği ve departman başına eşzamanlı problem sayısı.
- Statların öğrenme hızına vereceği azami bonus.

## Karar Özeti

Henüz kullanıcı tarafından onaylanmış karar veya FREEZE yok.
