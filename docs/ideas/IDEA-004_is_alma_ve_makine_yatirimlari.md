# IDEA-004 — İş Alma ve Makine Yatırımları

## Durum/Tur

Durum: DRAFT — Claude incelemesi bekleniyor; bu dosya FREEZE değildir.
Tur: 1
Date: 2026-09-29
Bağımlılıklar: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md), [FRZ-002 v2](../freeze/FRZ-002_v2_fabrika_ekonomisi.md), [FRZ-003](../freeze/FRZ-003_iflas_ve_fabrika_satisi.md).

## Öneri (GPT)

**İş Alma.** Oyuncu ay sonunda sınırlı sayıda iş/ihale teklifi görür. Her teklifte gereken makine niteliği, iş miktarı, teslim süresi, beklenen gelir, tahmini maliyet ve kapasite kullanımı açık olur. Oyuncu hangi işlere gireceğini seçer; kabul edilen işler makine kapasitesini ve teslim zamanını bağlar. İlk sürümde sabit koşullu teklif seçimi yeterli olabilir; teklif fiyatı pazarlığı daha sonra değerlendirilebilir.

**Makine yatırımı.** Makine markası/modeli yalnızca ad değildir: aylık kapasiteyi, uygun olunabilen işleri ve birim maliyeti etkiler. Örnek A/B/C torna tezgâhının 10/15/17 birim üretmesi yalnızca tasarım örneğidir. Daha nitelikli tezgâh, belli şartları olan niş işlere erişim sağlayabilir; yüksek alış fiyatı, sonraki kâr fırsatı ve yeniden satış değeriyle birlikte değerlendirilir. Teklif ekranı oyuncunun mevcut makinelerle işi yapıp yapamayacağını ve kabulden sonra boş kapasiteyi gösterir.

**Azami kazanç ve iflas bağlantısı.** FRZ-003'teki azami aylık brüt kâr, oyuncunun **mevcut makine parkıyla teknik olarak alabileceği işlerden**, kapasite sınırı içinde ulaşılabilir en iyi aylık iş bileşimidir. Oyuncunun o ay gerçekten kabul ettiği iş veya son ayın gerçekleşen kârı değildir. Hesap, piyasada alınabilir tekliflerin yakın dönem ortalamasını kullanır ve ay sonunda güncellenir; sınırsız hayalî sipariş varsayılmaz. Yeni fabrikada geçmiş ay yoksa başlangıç iş havuzu kullanılır. Kesin havuz ve süre değerleri denge konusudur.

**Yatırım değeri ve çıkış.** Yatırım ekranı her makinenin alış bedelini, güncel referans değerini, bu ay normal satış tutarını ve zorunlu tasfiye tutarını ayrı gösterir. FRZ-003'teki `yatırım değeri`, mevcut satılabilir varlıkların **güncel referans değerleri toplamıdır**; alınmış ama artık elde olmayan makineler sayılmaz. Normal %70 / zorunlu %50 çarpanları aynı referansa uygulanır. Satış önizlemesi kapasite, alınabilir işler, azami net katkı ve iflas eşiğindeki değişimi birlikte gösterir.

## Notlar (Claude)

İnceleme bekleniyor. Lütfen yalnızca kritik çelişkileri ve en fazla üç açık kararı yaz.

## Açık Kararlar

1. İlk sürümde sabit koşullu iş seçimi yeterli mi; fiyat pazarlığı ne zaman gerekli olur?
2. Kısmi kapasiteyle birden çok iş alınabilir mi, yoksa önce tek iş akışıyla mı başlanmalı?
3. Azami kâr için “alınabilir teklif” havuzu ve yatırım referans değeri nasıl hesaplanmalı ki piyasa şoku iflası rastgele tetiklemesin ve makine al-sat istismarı oluşmasın?

## Karar Özeti

- Bu turda yeni nihai karar yoktur. Önceki kullanıcı yönlendirmesi: farklı makineler kapasiteyi, kârlılığı ve erişilen ihaleleri etkilesin; çünkü yatırım seçimi hem fabrika işlerini hem sonraki büyüme yolunu değiştirmelidir. Kesin kural ancak kullanıcı onayıyla FREEZE olur.
