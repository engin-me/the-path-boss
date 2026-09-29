# Claude oyun testi bulguları — Tur 1

Test eden: Claude · Tarih: 2026-09-29 · Kaynak: `reports/*.md`, `reports/_ozet.md`, `reports/_ozet_ayni_makine.md` (her karakter 40 tohum, 12 ay).
Bu dosya tasarım kararı değildir. Geçerli bulgular IDEA'ya taşınmalıdır; FREEZE yalnızca kullanıcı onayıyla değişir.

Özet (40 tohum):

| Karakter | Kendi makineleri: ayakta / iflas | Aynı makine (A+B): ayakta / iflas | Görülmeyen kayıp payı |
| --- | --- | --- | ---: |
| Teknik Usta (A×2) | 26 / 14 | 40 / 0 | %46 |
| Dengeli Yönetici (A+B) | 40 / 0 | 40 / 0 | %31 |
| Finansçı Kumarbaz (B, 2. ay C) | 40 / 0 | 40 / 0 | %39 |
| İnsan Yöneticisi (A×2) | 18 / 22 | 40 / 0 | %49 |
| Erken Kurucu (A×2, 300 para) | 2 / 38 | açılamadı (40) | %73 |

## Mantık hataları (bu turda düzeltildi)

1. **Kasa gideri karşılamazsa iş alınamıyordu; oyun kilitleniyordu.** Python prototipi ve Godot dilimi, ay başı kasa giderlerin altındaysa iş almayı reddediyordu. İş alamayan fabrika para kazanamıyor, kasa hiç düzelmiyordu. İlk koşuda 5 karakterden 4'ü bu yüzden takıldı. FRZ-004 iş maliyetini yalnız Düzelt güvencesinden ayırır; FRZ-003 v2 eksi kasaya eşiğe kadar izin verir. Kural kaldırıldı; artık yalnız uyarı gösteriliyor ve eksi kasaya finansman gideri işliyor.
2. **Uygun makinesi olmayan teklif seçilebiliyordu.** Arayüz, onaya basınca hata veriyordu. Artık bu teklifler baştan pasif ve "uygun makinen yok" yazıyor.

## Tasarım bulguları (IDEA'ya taşınmalı)

1. **Derin sorunu düzeltmek ekonomik değil (kritik).** Kayıp Tier'den bağımsız (FRZ-002 v3, gizlilik için doğru), ama bedel Tier ile artıyor (FRZ-001 §5). Test verisinde her satır ayda 2–6 kayıp yaratıyor; T3 düzeltmesi 25–35, T5 100–140 para. Sorunlar zamanla büyümediği için rasyonel patron derin sorunları hiç çözmüyor. Bilmediği derin sorun da onu yalnızca sığ bir sorun kadar yakıyor. Öneri: açık kalan "ertelenen sorunun büyüme hızı" kararı kapatılsın. Bütün sorunlar Tier'den bağımsız aynı oranda büyüsün ya da çözülmeyen kök yeni bağlı satır doğursun. İki yol da gizli Tier'i sızdırmaz.
2. **Gizli sorunlar birikiyor; erken erişim yalnız açılış ayında garanti (kritik).** Erken Kurucu 40 tohumun 38'inde iflas etti; kaybının %73'ü hiç görülmedi. Gizli satırın üst güvencesi ölçeğin en derin Tier tavanı (küçük ölçekte T3 = 35). İlk aydan sonra kasa 87–106 bandında kalıyor; giderler (54) ve iş maliyeti düşülünce kullanılabilir nakit çoğu ay bu güvencenin altında. Gizli satırlar kendiliğinden kaybolmuyor: 2. ayda 1 olan gizli satır sayısı 10. ayda 9'a çıkıyor, 7–10. aylarda her deneme güvenceye takılıyor (ayrıntı: `reports/05_erken_kurucu.md`). FRZ-002 v3 §4 yalnız kuruluş anının kasasını garanti ediyor; FRZ-001 §6'daki "ilk üç ayın her birinde deneyebilmeli" testi 2. ve 3. aylarda tutmuyor. Öneri: erken dönem için ya güvence ay ay korunmalı ya da küçük ölçekte ilk aylarda oluşan sorunların derinliği sınırlanmalı.
3. **Makine niteliği yetkinlikten baskın.** Aynı makine parkıyla dört karakter de 40/40 ayakta; kendi A×2 makineleriyle Teknik Usta 26/40, İnsan Yöneticisi 18/40. Neden: iş teklifleri fabrikanın makinelerinden bağımsız rastgele nitelikte geliyor ve yalnız A tezgâhı olan fabrika tekliflerin yaklaşık üçte ikisini alamıyor. FRZ-004, teklif havuzunda oyuncunun makinelerine uygun en az kaç teklif olacağını söylemiyor. Oyunun kimliği ("kariyer geçmişi patronu belirler") açısından risk: yetkinlik dağılımı makine seçiminin gölgesinde kalıyor. Öneri: teklif havuzunda parka uygun asgari teklif payı tanımlansın, ya da nitelikli işlerin getirisi yetkinliğe (ör. Kalite, Satın Alma) de bağlansın.
4. **Danışman neredeyse hiç kullanılmıyor.** 12 ayda ortalama 0–0,5 sözleşme. Tek satırın kaybı ayda 2–6 iken 3 aylık sözleşme 30–45 para tutuyor. Adayların çoğu patronun zaten okuyabildiği seviyede puan taşıyor. Danışman ancak aynı departmanda çok satır birikince anlamlı. Öneri: aday üretiminde "en az bir alanda patrondan bir Tier yukarıda" şartı düşünülsün; sözleşme fiyatı ile tipik kayıp aynı ölçekte dengelensin (FRZ-006 v2 fiyat açık).
5. **Kayıp mutlak birimde; az iş alan ay orantısız etkileniyor.** Satır kaybı iş hacminden bağımsız. Departman %20 tavanı kabul edilen işe göre hesaplandığı için az iş alınan ayda kayıp sert kırpılıyor (ör. 15 birimlik ayda departman başına en fazla 3). Bu, az iş alarak kaybı küçültme gibi ters bir teşvik yaratabilir. FRZ-002 v3, sorun kaybının iş hacmiyle ölçeklenip ölçeklenmeyeceğini tanımlamıyor.
6. **İnsan Yönetimi 100'ün etkisi zor hissediliyor.** Ayda 1–2 yeni olayın yaklaşık %30'u kişi kaynaklı; %80 önlemeyle ayda yaklaşık 0,4 olay önleniyor. Aynı makinede İnsan Yöneticisinin net kasası (52), Dengeli'den biraz iyi (37) ama Teknik Usta'dan kötü (66); görülmeyen kayıp payı da en yüksek (%49). FRZ-005 v2'nin "İnsan Yönetimi 100, diğer dağılımları sistematik geçmemeli" ölçütü sağlanıyor, ama yatırımın oyuncuya görünür karşılığı zayıf. "Önlenen olay" satırı tek başına yetmeyebilir.
7. **Kör deneme fazla iyi ödüllendiriliyor olabilir.** "Belirsiz" satırları da deneyen Finansçı, aynı makinede en yüksek net kasaya ulaştı (216; diğerleri 37–66). Gizli satırın tahmini ucuz (en sığ Tier tabanı) ve küçük ölçekte olası Tier'ler dar (T2–T3), bu yüzden şans %40–80. Bu FRZ-001'in "bilgi açığı imkânsız değil, riskli olmalı" ilkesiyle uyumlu mu, yoksa fazla cömert mi? Karar verilmeli; oran testte ayarlanabilir.

## Test verisi varsayımları (kural değil)

- Makineler (A/B/C: 80/140/220 para, 40/55/70 kapasite, Q1/Q2/Q3). Bir iş, kendi niteliğinde veya daha iyi makinede yapılır.
- Ölçek: 1–2 makine küçük (≤T3), 3–4 orta (≤T4), 5+ büyük (≤T5).
- Aylık gider 30 + makine başına 12. Patron zamanı ayda 40 saat.
- Yeni sorun sayısı ayda 1–2, büyüdükçe artar. Satır kaybı 2–6 × ölçek çarpanı; kişi kaynaklı pay %30.
- Danışman sözleşmesi 3 ay. Kriz kredisi 100, finansman gideri net açığın %2'si.
- Kayıp birimi test kolaylığı için fiziksel teslimatla bire bir alındı.

Bulgu 3 ve 4'ün bir kısmı bu sayılardan kaynaklanabilir. Bulgu 1, 2 ve 5 ise kural yapısından geliyor.
