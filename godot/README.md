# Godot oynanabilir dilim

`project.godot` dosyasını Godot 4 ile açıp **F5 / Run Project** ile oyunu başlatın.

## Patron testi (açılış ekranı)

Kariyeri atlayıp yalnız patron bölümünü test etmek için: on yetkinliği bir puan bütçesiyle (varsayılan 600) dağıt, cebine para koy, makine al, her ay iş seç, raporu incele, Düzelt / danışman / kredi / makine alım-satım kararlarını ver. Her ekranda **📝 Not ekle** ile "bu saçma olmuş" notu düşebilirsin. Hazır karakterler, başsız koşucu ve not dosyaları için bkz. [`playtests/README.md`](playtests/README.md).

Kontroller:

```powershell
& '...\Godot_v4.7.2-stable_win64_console.exe' --headless --path godot --script res://tests/boss_smoke.gd
& '...\Godot_v4.7.2-stable_win64_console.exe' --headless --path godot --script res://tests/persona_run.gd -- seeds=40
```

## Mobil fabrika arayüzü (iskelet)

`factory_shell.tscn` dikey mobil (540×960) fabrika kabuğudur: sabit üst şerit, beş ana sekme (Özet, İşler, Tezgah, Fabrika, Profil), fabrika kiralama (6/12/24 ay, 2 kira erken çıkış), tezgah alma (alan ve yükseklik kontrolü), birden çok iş kabulü ve Profil. **Motor `scripts/shell/shell_boss.gd`** (BossState'in alt sınıfı): sorun/Düzelt, danışman, patron saati ve iflas hesabı BossState'ten gelir; kira, makine pazarı (teslim süreli), makine ayıran işler, zorunlu ekipman, ipotekli kredi ve ay döngüsü (Raporu aç → Düzelt → Ayı bitir) yeni modeldir. Eski `boss_state.gd` ve patron testi değişmedi. Kurallar IDEA-015/016 önerisidir, FREEZE değildir. Öneriler için `docs/ideas/IDEA-015` ve `IDEA-016`. Görseller `godot/art/factories/<id>.png` ve `godot/art/machines/<tür>_<seviye>.png` (örn. `torna_1.png`) yoluna konursa arayüz yer tutucu yerine onları gösterir. Önizlemeler `ui_previews/` altında.

**Android APK için `ANDROID.md`.** **Oyun akışı (prototip):** kira → zorunlu ekipman → tezgah (teslim süreli) → vardiya/patron ayarı → ilana teklif (fiyat, peşinat, süre) → müşteri yanıtı (kabul / evet-hayır karşı teklif / ret) → hammadde siparişi (tedarikçi) → FIFO üretim → rapor şelalesi (teorik → vardiya → performans → hurda → sorun → net) → teslim ve bakiye. Kurallar IDEA-015..018 önerileridir.

**Kayıt:** oyun otomatik kaydedilir; Profil → "Kaydı sil ve yeni oyun" ile silinir. Başsız testlerde kayıt kapalıdır.

**F5 artık bu arayüzü açar.** Eski patron test ekranı için `boss.tscn` dosyasını açıp F6 ile çalıştırın.

Simülasyon: `... --script res://tests/shell_sim.gd -- seeds=100` (isteğe bağlı `rev=2 rent=1 cash=800 floor=12`); son sonuçlar `playtests/reports/_shell_ozet.md`.

```powershell
# Sahneyi Godot editöründe factory_shell.tscn açıp F6 ile çalıştırın; başsız kontrol:
... --headless --path godot --script res://tests/shell_smoke.gd
```

## Eski kariyer dilimi

Patron testi ekranındaki "Eski kariyer dilimini aç" düğmesiyle açılır (`main.tscn`).

Bu sürümde üç kariyer ayı oynanır. Oyuncu iş ve uygun olduğunda kurs veya dinlenme seçer; ardından küçük fabrikayı kurup üç ay iş alır, departman raporlarını inceler ve sorunlara `Düzelt` uygular. Kariyer yetkinliği, sorunun görünmesini ve çözümün kesin olup olmamasını etkiler. Müdahalenin faydası bir sonraki ayın raporunda görülür. Son ekranda başka rota için yeniden başlanabilir.

Oyun, 10 yıl sonraki halinin anlattığı kısa bir rüyayla açılır. İş kartları maaşın yanında hangi patron yetkinliğini geliştirdiğini gösterir; yetkinlik tablosu her alanda hangi Tier'e kadar sorun görebileceğini söyler. Fabrika kartlarında FREEZE kuralları uygulanır:

- Patronun okuyabildiği Tier'ler adıyla, okuyamadığı ölçek içi yuvalar sırasız ve adsız **“Derinlik bilinmiyor”** satırı olarak görünür; ölçek dışı yuvalar ayrıca işaretlenir.
- Başarı şansı kademe farkına göre düşer (≈ %80 / %40 / %15 / %5). Birden fazla gizli Tier mümkünse şans **“Belirsiz”**, tek gizli Tier mümkünse çıkarılabilir etiket gösterilir.
- Gizli satırlar ortak tahmin (erişilemeyen en sığ Tier tabanı) ve ölçeğin en derin Tier tavanı olan üst güvenceyi gösterir; düğme tahmini, en fazla bedeli ve saat aralığını söyler.
- Eksi kasada küçük finansman gideri işler.
- Dilim sonunda **kapanış raporu** gizli kökleri, kesin çözüm için gereken yetkinliği ve bir sonraki kariyer için dersi gösterir.

Rakamlar `game/campaign.py` içindeki **örnek denge girdileridir**; nihai oyun dengesi olarak onaylanmış değillerdir. Bu dilimde yalnızca iki meslek, iki iş teklifi ve iki departmanın örnek sorunları vardır. Danışman pazarı, daha uzun kariyer, kredi/devir/iflas sonrası dönüş ve diğer kabul senaryoları henüz Godot arayüzünde yoktur. Onaylı kurallar için `docs/freeze/` geçerlidir.

Godot motoruyla kısa otomatik kontrol:

```powershell
& 'C:\Users\emrah.engin\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path godot --script res://tests/smoke.gd
```

## Fabrika kabuğu: son eklemeler (test aşaması, yer tutucu sayılar)

- **Üstten yerleşim:** başlangıç eşyaları bina içinde sabit tohumla dağılır (raflar sol duvarda yarı yarıya binen "tren"), konumlar kayda yazılır. ✎ düzenleme modu: sürükle (0,5 m ızgara, üst üste binmez), ⟳ döndür, ↺ sıfırla. Yerleşimin oyuna etkisi yoktur (IDEA-013).
- **Vardiya planı (Fabrika > Vardiya):** 1. vardiya hep açık; 2. ve 3. vardiya ardışık; mesai bir vardiyaya +4 sa (+0,5 vardiya, saatlik ücret 1,5×), üç vardiyada mesai yok; "Patron operatörlük yapar" tek operatörlü bir tezgahın 1. vardiyasını otomatik atar.
- **Teklif maliyeti:** hammadde sabit; her tezgah türü için ayrı kart (hurda, genel gider, personel). Hurda aralığı tablo ile verilir (`SCRAP_RANGE`), tahmin orta noktadır, gerçek oran işi alınca aralıkta çekilir ve tesliminde hammaddeden düşülür. Oyuncu kendi varsayımlarını değiştirebilir; fiyat = toplam maliyet × (1 + marj).
- **μ (Parça İşleme Katsayısı):** yüksek = zor parça; iş yükü = parça × μ, birim "x".
- **Yerleşim (güncel):** makineler fabrikanın ortasına, ekipman duvarlara yaslanarak dizilir (raflar sol duvarda tren, tezgah/kasa üstte, takım dolabı sağda, transpalet/forklift rampa tarafında). Makineler liste alanıyla en çok fabrika alanının %51'ini kaplar. Yerleşim sekmesinde transpalet/forklift iş varken gezinir, her tezgahta gerekli sayıda operatör durur; işi olmayan tezgahın başında "?" çıkar. ✎ modunda sürüklerken öğeler birbirinin üstünden geçebilir; bırakınca en yakın boş yere oturur.
- **Personel politikası** (Fabrika > Vardiya): Yok / Standart / İyi; kişi başı aylık yan gider, insan kaynaklı sorunların önlenme şansını artırır.
- **Birim:** iş yükü ve kapasite μ cinsindendir ("8000 μ/ay"); μ = Parça İşleme Katsayısı. Özetteki "Ayı çalıştır ▶" planlamayı kapatıp ayın raporunu açar; "Ayı bitir ▶" ayı kapatır.
