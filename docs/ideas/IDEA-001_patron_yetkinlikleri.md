# IDEA-001 — Patron Yetkinlikleri

Status: DRAFT
Date: 2026-09-27

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
