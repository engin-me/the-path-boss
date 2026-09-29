# Godot oynanabilir dilim

`project.godot` dosyasını Godot 4 ile açıp **F5 / Run Project** ile oyunu başlatın.

Bu sürümde üç kariyer ayı oynanır. Oyuncu iş ve uygun olduğunda kurs veya dinlenme seçer; ardından küçük fabrikayı kurup üç ay iş alır, departman raporlarını inceler ve sorunlara `Düzelt` uygular. Kariyer yetkinliği, sorunun görünmesini ve çözümün kesin olup olmamasını etkiler. Müdahalenin faydası bir sonraki ayın raporunda görülür. Son ekranda başka rota için yeniden başlanabilir.

Rakamlar `game/campaign.py` içindeki **örnek denge girdileridir**; nihai oyun dengesi olarak onaylanmış değillerdir. Bu dilimde yalnızca iki meslek, iki iş teklifi ve iki departmanın örnek sorunları vardır. Danışman pazarı, daha uzun kariyer, kredi/devir/iflas sonrası dönüş ve diğer kabul senaryoları henüz Godot arayüzünde yoktur. Onaylı kurallar için `docs/freeze/` geçerlidir.

Godot motoruyla kısa otomatik kontrol:

```powershell
& 'C:\Users\emrah.engin\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path godot --script res://tests/smoke.gd
```
