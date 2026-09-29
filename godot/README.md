# Godot oynanabilir dilim

`project.godot` dosyasını Godot 4 ile açıp **F5 / Run Project** ile oyunu başlatın.

## Patron testi (açılış ekranı)

Kariyeri atlayıp yalnız patron bölümünü test etmek için: on yetkinliği bir puan bütçesiyle (varsayılan 600) dağıt, cebine para koy, makine al, her ay iş seç, raporu incele, Düzelt / danışman / kredi / makine alım-satım kararlarını ver. Her ekranda **📝 Not ekle** ile "bu saçma olmuş" notu düşebilirsin. Hazır karakterler, başsız koşucu ve not dosyaları için bkz. [`playtests/README.md`](playtests/README.md).

Kontroller:

```powershell
& '...\Godot_v4.7.2-stable_win64_console.exe' --headless --path godot --script res://tests/boss_smoke.gd
& '...\Godot_v4.7.2-stable_win64_console.exe' --headless --path godot --script res://tests/persona_run.gd -- seeds=40
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
