# Oynanabilir Terminal Prototipi

Bu prototip [CURRENT FREEZE](01_DECISION_INDEX.md) yapısını hızlıca deneyebilmek içindir; içindeki maaş, yetkinlik artışı, süre, fiyat, şans ve iş teklifleri **test girdisidir**. Yeni bir tasarım kararı veya FREEZE değildir.

Proje kökünden çalıştırma:

```powershell
python -B -m game.play_campaign
python -B -m game.play_campaign --auto
python -B -m unittest discover -s tests -v
```

Bu bilgisayarda `python` PATH'te yoksa tam Python çalıştırılabilir yolunu `python` yerine kullanmak gerekir.

İlk üç ayda CNC Operatörü veya Takım Lideri işi ve ek olarak kurs/dinlenme seçilir. İş değişimi zaman ve o ayın maaşından harcar. Kurslar on yetkinliğin her biri için kalıcı öğrenme yolu sunar. Oyuncu küçük fabrikayı yetkinlik eşiğiyle değil, kuruluş nakdiyle açar.

Sonraki üç ayda temkinli veya büyük işi seçer; departman kaybını, mevcut yetkinlikle görünür/gizli sorunları ve `Düzelt` için gereken üst güvenceyi görür. Farklı kökler aynı ay denenebilir; aynı kök aynı ay tekrar denenemez. Düzelt'in rapor faydası sonraki ay görünür. `--auto`, iki kariyer rotasını ve önceki dört [kabul senaryosunu](04_ACCEPTANCE_SCENARIOS.md) çalıştırır.

Danışman pazarı, tam meslek/terfi sistemi, personel olay üretimi ve gerçek para akışı bu kısa oynanabilir dilimin içinde değildir; mevcut FREEZE kararları yürürlüktedir. Terminal sonuçları oyun motoru veya nihai arayüz seçimi anlamına gelmez.
