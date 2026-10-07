# Current State

Project: the Path - Boss

Current phase:
Godot playable slice

Active topic:
IDEA-014 patron operatörlüğünün aylık zaman payı: kullanıcı sabit 8 saat yerine toplam saatin yarısını istedi; Claude incelemesi ve yeni FREEZE sürümü bekleniyor. FRZ-008 v2 CURRENT kalır. IDEA-013'te OEE sunumu, toplam patron saati ve kesin kira/ücret dengesi de açıktır. Yeni yetkinlik/departman taksonomisi ayrı taslak konudur.

Latest freeze:
FRZ-008 v2 (CURRENT, kullanıcı onayı 2026-09-30). FRZ-001 v3, FRZ-002 v4, FRZ-003 v2, FRZ-004 v2, FRZ-005 v2, FRZ-006 v2 ve FRZ-007 v3 de CURRENT.

Pending review:
IDEA-012 kapandı. IDEA-013 Claude Tur 1'in OEE, kadro, patron operatörlüğü ve iş bazlı ekonomi kararları FRZ-008 v2'ye geçti; kalan IDEA-013 kararları açık. IDEA-014'ün yarım zaman önerisi Claude Tur 1 incelemesini bekliyor.

Next step:
IDEA-014'ü Claude incelemesine aç; 40 saatlik mevcut prototipte 20 saat operatörlük ve 20 saat yönetimin FRZ-001 v3 gizli Düzelt erişimiyle uyumunu sına. Sonra IDEA-013'te OEE sunumunu ve farklı iş havuzlarında tek makine/kira dengesini incele; aylık toplam patron saatini ayrıca karara bağla. FRZ-004 v2'nin varsayılan 3/5 teklif kuralıyla Erken Kurucu 100 tohumda 87 kez ayakta kaldı; gizli satırlı 272 ilk üç ayın 245'inde (%90) danışmansız deneme mümkündü, saat engeli yoktu. Danışman fiyatı tipik departmanın 1–2 aylık gizli zararıyla ayrıca dengelenir; FRZ-006 v2 kesin fiyatı açık bırakır. Yeni yetkinlik/departman önerileri ve Strateji & Karar şans bonusu ayrı IDEA konusu olarak ele alınır. Başlangıç 20 yetkinlik + dağıtılabilir 10 bonus ve üç kariyer/üç fabrika ayı kısa dilimin sayısal prototipidir.

Prototype status (2026-10-07, branch claude/elegant-knuth-0zu8x7):
Mobil kabuk prototipinde IDEA-019'dan IDEA-023'e kadar olan taslaklar kodlandı ve sınandı; hiçbiri FREEZE değildir, sayılar prototipte denenen önerilerdir. Kodlananlar: akan zaman ve Yönetim özeti (IDEA-019), hakediş (aylık %80), teslimde tek seferde seçeneği, küçük iş primi, aciliyet etiketi, Sürekli İş, iş önceliği/askıya alma, ilan havuzu 40/40/20 (IDEA-021), vardiya verimi, kadrolu/sözleşmeli ekip, tazminat, ay başı özeti (IDEA-022), teklif Gantt'ı, bağlayıcı plan, teslim öteleme talebi, gecikmeli posta ve rozet (IDEA-023). 36 aylık simülasyon (20 tohum): sermayeli kişilikler 20/20 ayakta; küçük sermayeli kişilikler 11–17/20; küçük vardiyacı en zayıf (9/20 batık, vardiya maliyeti). Açık denge soruları: başlangıç parası normalizasyonu, küçük fabrikada vardiya maliyeti, teslimde tek seferde fiyat oranları. Bekleyen tasarımlar: kokpit, kapasite ekranı, onay ekranları, ay sonu raporu, ilan ekranı.
