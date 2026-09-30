# Decision Index

## Current FREEZE decisions

- [FRZ-001 v2 — Patron Yetkinlikleri ve Fabrika Sorun Döngüsü](freeze/FRZ-001_v2_patron_yetkinlikleri.md) — mevcut bilgi ve Düzelt yapısına eşik farkı başına %4, en az %5 başarı şansı ve Kesin/Yüksek/Orta/Düşük etiketlerini ekler. Source: [IDEA-001](ideas/IDEA-001_patron_yetkinlikleri.md), [IDEA-011](ideas/IDEA-011_duzelt_sans_egrisi.md) ve kullanıcı onayı. Status: CURRENT. Supersedes FRZ-001.
- [FRZ-002 v3 — Fabrika Ekonomisi, İş Hedefi ve Kasa Olayları](freeze/FRZ-002_v3_fabrika_ekonomisi.md) — çıktı eşdeğeri raporu, kabul edilen iş hedefi, ayrı boş kapasite, nakit sırası ve iş maliyeti güvencesi. Source: [IDEA-002](ideas/IDEA-002_fabrika_ekonomisi.md), [IDEA-003](ideas/IDEA-003_iflas_ve_yeniden_baslangic.md), [IDEA-004](ideas/IDEA-004_is_alma_ve_makine_yatirimlari.md). Status: CURRENT. Supersedes FRZ-002 v2.
- [FRZ-003 v2 — İflas, Tasfiye ve Fabrika Satışı](freeze/FRZ-003_v2_iflas_ve_fabrika_satisi.md) — altı aylık kurtarma eşiği, makinenin kazanç hesabına giriş zamanı, yatırım referansı, satış ve iflas sonrası devam. Source: [IDEA-003](ideas/IDEA-003_iflas_ve_yeniden_baslangic.md), [IDEA-004](ideas/IDEA-004_is_alma_ve_makine_yatirimlari.md). Status: CURRENT. Supersedes FRZ-003.
- [FRZ-004 — İş Alma ve Makine Yatırımları](freeze/FRZ-004_is_alma_ve_makine_yatirimlari.md) — sabit koşullu birden çok tam iş, makine uygunluğu, teslim, iş maliyeti ve azami kâr potansiyeli. Source: [IDEA-004](ideas/IDEA-004_is_alma_ve_makine_yatirimlari.md), Tur 2. Status: CURRENT. Depends on FRZ-001, FRZ-002 v3, FRZ-003 v2.
- [FRZ-005 v2 — Personel ve İnsan Yönetimi](freeze/FRZ-005_v2_personel_ve_insan_yonetimi.md) — personel kökleri, İnsan Yönetimi'nin yeni sorunları önlemesi ve kendi departmanında da aynı kişi olayı payı. Source: [IDEA-005](ideas/IDEA-005_personel_ve_insan_yonetimi.md), [IDEA-008](ideas/IDEA-008_tasarim_tutarliligi.md). Status: CURRENT. Supersedes FRZ-005. Depends on FRZ-001 and FRZ-002 v3.
- [FRZ-006 v2 — Danışman Pazarı ve Sözleşmeler](freeze/FRZ-006_v2_danisman_pazari.md) — kart bütçesi, ölçeğe uygun uzman havuzu, ücretli çekimde ödeme yolu eşitliği ve sözleşme uzatma sınırı. Source: [IDEA-006](ideas/IDEA-006_danisman_pazari.md), [IDEA-008](ideas/IDEA-008_tasarim_tutarliligi.md). Status: CURRENT. Supersedes FRZ-006. Depends on FRZ-001 and FRZ-002 v3.
- [FRZ-007 v3 — Çalışanlık Kariyeri, Üniversite ve Yetkinlik Yolları](freeze/FRZ-007_v3_calisanlik_kariyeri.md) — ilgili diploma olmadan 70/50/30 öğrenme tavanları; diğer kariyer, kurs, stat ve eğitim kuralları korunur. Source: [IDEA-009](ideas/IDEA-009_kariyer_egitim_ve_yetkinlik_yollari.md) ve kullanıcı onayı. Status: CURRENT. Supersedes FRZ-007 v2. Depends on FRZ-001 v2, FRZ-002 v3 and FRZ-003 v2.

## Superseded decisions

- [FRZ-001 — Patron Yetkinlikleri ve Fabrika Sorun Döngüsü](freeze/FRZ-001_patron_yetkinlikleri.md) — historical version. Status: SUPERSEDED by FRZ-001 v2.
- [FRZ-002 — Fabrika Ekonomisinin Çekirdeği](freeze/FRZ-002_fabrika_ekonomisi.md) — historical version. Status: SUPERSEDED by FRZ-002 v2.
- [FRZ-002 v2 — Fabrika Ekonomisinin Çekirdeği ve Kasa Olayları](freeze/FRZ-002_v2_fabrika_ekonomisi.md) — historical version. Status: SUPERSEDED by FRZ-002 v3.
- [FRZ-003 — İflas, Tasfiye ve Fabrika Satışı](freeze/FRZ-003_iflas_ve_fabrika_satisi.md) — historical version. Status: SUPERSEDED by FRZ-003 v2.
- [FRZ-005 — Personel ve İnsan Yönetimi](freeze/FRZ-005_personel_ve_insan_yonetimi.md) — historical version. Status: SUPERSEDED by FRZ-005 v2.
- [FRZ-006 — Danışman Pazarı ve Sözleşmeler](freeze/FRZ-006_danisman_pazari.md) — historical version. Status: SUPERSEDED by FRZ-006 v2.
- [FRZ-007 — Çalışanlık Kariyeri ve Yetkinlik Kazanımı](freeze/FRZ-007_calisanlik_kariyeri.md) — historical version. Status: SUPERSEDED by FRZ-007 v2.
- [FRZ-007 v2 — Çalışanlık Kariyeri, Üniversite ve Yetkinlik Yolları](freeze/FRZ-007_v2_calisanlik_kariyeri.md) — historical version. Status: SUPERSEDED by FRZ-007 v3.

## Open design work

- [IDEA-012 Erken Dönem ve Teklif Havuzu](ideas/IDEA-012_erken_donem_ve_teklif_havuzu.md): küçük parkın uygun iş bulması ve ilk üç ay gizli Düzelt erişimi için Tur 1 taslak; Claude incelemesi bekleniyor.
- [IDEA-010 Çözülmeyen Sorunların Büyümesi](ideas/IDEA-010_sorun_buyumesi.md) → [FRZ-002 v4 DRAFT](freeze/FRZ-002_v4_fabrika_ekonomisi.md): %5 aylık büyüme, başlangıç kaybının iki katı sınırı; IDEA-012 erken dönem çözümüyle birlikte onaylanacak. FRZ-002 v3 CURRENT kalır.
- [IDEA-013 Fabrika Kuruluşu ve Operasyon Çekirdeği](ideas/IDEA-013_fabrika_kurulusu_ve_operasyon_cekirdegi.md): kiralık alan, makine kataloğu, otomatik kadro, ücret politikası, patronun operatörlüğü ve OEE'nin mevcut kayıp hesabıyla ilişkisi için Tur 1 taslak; Claude incelemesi bekleniyor.
- Kullanıcının önerdiği yeni yetkinlik/departman listesi, Kalite'nin yalnız yan mesleklerden kazanılması, İK Asistanı İnsan Yönetimi v2 ve Strateji & Karar yetkinliğinin diploma tavanı/şans bonusu henüz yeni IDEA/Claude incelemesi ile FREEZE yapılmadı. Strateji için konuşulan taslak: diplomasız tavan 50, iki bölümden biri tavanı açar, %100 puanda şans ×1,5 ve zar gereken sonuçlarda %95 üst sınır. FRZ-001 v2 ve FRZ-007 v3 bu değişiklikleri içermez.
- Kesin sayısal denge, danışman ücretleri/gerçek para sunumu, teklif sayısı, makine fiyat/kapasite değerleri, personel etkisinin kesin eğrisi ve kariyer ilerleme formülleri henüz FREEZE kapsamında değildir. Danışman profil havuzunun ölçeği, kişisel borç tavanındaki referans maaş, büyük ölçekte doğrudan fabrika kuruluşunun güvence tutarı ve farklı teknolojiyle yeniden kuruluşta devir fiyatı istismarı da açıktır. [Kabul senaryoları](04_ACCEPTANCE_SCENARIOS.md) bu kararların yerini almaz.
