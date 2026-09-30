# IDEA-018 — OEE'nin Vardiya, Performans ve Hurda ile Hesabı; Vardiya ve Kadro

## Durum/Tur

Durum: DRAFT — Kullanıcının 2026-09-30 oyun testi sonrası önerisi ve Claude'un düzenlemeleri kaydedildi; Claude incelemesi ve Codex sentezi bekleniyor. Bu IDEA oyun kuralı değildir. [FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md) §1 (OEE ayrı çarpan değildir) ve [FRZ-002 v4](../freeze/FRZ-002_v4_fabrika_ekonomisi.md) toplamsal kayıp hesabı CURRENT kalır; bu IDEA onay görürse ikisini de değiştirir.
Tur: 1
Tarih: 2026-09-30
Bağımlılıklar: FRZ-001 v3, FRZ-002 v4, FRZ-005 v2, FRZ-008 v2, [IDEA-014](IDEA-014_patron_operatorlugu_zaman_payi.md), [IDEA-017](IDEA-017_teklif_kapasite_yuku_gantt_tedarik.md).

## Öneri (GPT)

Bu bölüm kullanıcının mesajlarından ve Claude düzenlemelerinden derlendi; Codex revize edebilir.

**Gözlem.** Tek başına, personelsiz patron için ay sonu raporundaki "departman kaybı" anlaşılmıyor. Rapor, çıktının nasıl azaldığını bir şelale olarak göstermeli.

**OEE tanımı (24 saat bazlı).** `OEE = Kullanılabilirlik × Performans × Kalite`.
- **Kullanılabilirlik** = çalışılan vardiya / 3 (24 saat). Tek vardiya 0,33; iki vardiya 0,67; üç vardiya 1,00. Patron tek vardiya kendisi çalıştırır; istersen mesaiyle en fazla %50 uzatır (0,33 → 0,50). İkinci ve üçüncü vardiya için personel gerekir.
- **Performans** tezgah seviyesine bağlıdır (öneri: Standart %70, Hassas %80, Nitelikli %90).
- **Kalite** = 1 − hurda. Hurda tezgah türü ve seviyesine bağlıdır (öneri, Standart için: Torna %3, Freze %4, Taşlama %6, Dövme %9; Hassas −0,5 puan, Nitelikli −1 puan, alt sınır %2). Hammadde kalitesi tedarikçiye göre hurdayı ve fiyatı etkiler (IDEA-017 tedarik dilimi).
- Örnek: Standart torna, tek vardiya: 0,33 × 0,70 × 0,97 ≈ %22,6; mesaiyle 0,50 × 0,70 × 0,97 ≈ %34; üç vardiya ≈ %68.

**Kapasite.** Etkin kapasite = teorik kapasite (x/ay, tezgah türüne göre; öneri: Torna 2000, Freze 1600, Taşlama 1200, Dövme 800) × OEE. Standart torna tek vardiya ≈ 453x/ay, mesaiyle ≈ 679x, iki vardiya ≈ 906x, üç vardiya ≈ 1358x. İş yükü sayıları bu büyüklüğe göre üretilmelidir.

**Sorun satırlarının yeri.** Departman sorunları ayrı toplamsal kayıp olmaz; fiziksel etkisine göre faktörü düşürür (duruş → kullanılabilirlik, hız → performans, kusur → kalite). FRZ-008 v2'nin bileşen eşlemesi korunur; fark, OEE'nin artık yalnız rapor okuması olmayıp etkin kapasiteyi belirlemesidir.

**Rapor şelalesi.** Teorik kapasite → vardiya kaybı → performans kaybı → hurda → sorun kaybı → net iyi parça. Tek başınayken "departman" yerine "alan" denir.

**Vardiya ve kadro.** Oyuncu tezgah başına vardiya sayısını seçer. Patronun kendi vardiyası aylık yönetim saatinden pay alır (FRZ-008 v2 / IDEA-014 mantığı; mesai payı artırır). Ek vardiyalar personel ister; işe alım otomatik kadro ve ücret politikasıyla (FRZ-008 v2 §2) doldurulur, dolmazsa o vardiya çalışmaz. Manuel işe alım sonraki personel dilimine kalır.

## Notlar (Claude)

Tur 1 · 2026-09-30 · Prototipte uygulandı (`shell_boss.gd`); sonuçlar `godot/playtests/reports/_shell_ozet.md`.

- OEE (24 saat) = vardiya/3 × performans × (1 − hurda) × sorun çarpanı doğrulandı: Standart Torna, tek vardiya ≈ %22,6; üç vardiya ≈ %68.
- Sorun satırları artık ayrı kayıp değil: Bakım/Planlama/Depo kullanılabilirliği, Üretim performansı, Kalite hurdayı düşürür; diğer alanlar OEE dışı net çıktıyı düşürür; her alan %20 ile sınırlı, toplam çarpan en az %33.
- Patron vardiyası yönetim saatinden yarım toplam kadar (20 sa) alır, mesai +%50 (30 sa); gizli Düzelt saat güvencesi bozulursa reddedilir (orta ölçekte mesai reddedilir).
- Vardiya sayısı kapasiteyi doğrusal artırıyor ve kârlılığı belirgin değiştiriyor (simülasyon).
- Açık: orta/büyük parkta talep yetersizliği (kullanım %45–60) denge konusu.

## Açık Kararlar

- OEE'nin etkin kapasiteyi belirlemesi (FRZ-008 v2 §1 ve FRZ-002 v4 toplamsal kayıp değişir; yeni FREEZE sürümü gerekir).
- Adlandırma: 24 saat bazlı verim teknik olarak TEEP'tir; oyunda "OEE (24 saat bazlı)" mü?
- Patron vardiyası ile aylık yönetim saati ilişkisi: tam vardiyanın yönetim saatine etkisi ve mesai bedeli.
- Vardiya personeli: otomatik doldurma mı, manuel işe alım mı; ücret ve yedek.
- Performans, hurda, teorik kapasite ve iş yükü ölçek sayıları (hepsi yer tutucu).
- Sorun satırlarının faktörlere eşlenmesi ve %20 departman tavanı/%33 taban kurallarının yeni modelde karşılığı.

## Karar Özeti

- Kullanıcı OEE'yi 24 saat bazlı vardiya × performans × (1 − hurda) olarak hesaplamayı, patronun tek vardiya ve %50'ye kadar mesai yapmasını, ek vardiyalar için personel almayı ve hammadde kalitesinin fiyat ve hurdayı etkilemesini istedi; çünkü büyüme, vardiya ve kadro kararıyla kapasiteyi artırmaktan geçmeli. Onaylı FREEZE yoktur.
