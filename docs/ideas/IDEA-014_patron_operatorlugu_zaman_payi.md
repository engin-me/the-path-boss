# IDEA-014 — Patron Operatörlüğünün Aylık Zaman Payı

## Durum/Tur

Durum: DRAFT — Kullanıcının yeni kuralı alındı; Claude incelemesi ve Codex sentezi bekleniyor. [FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md) CURRENT kalır; bu IDEA henüz oyun kuralı değildir.
Tur: 1
Tarih: 2026-09-30
Bağımlılıklar: [FRZ-001 v3](../freeze/FRZ-001_v3_patron_yetkinlikleri.md), [FRZ-008 v2](../freeze/FRZ-008_v2_fabrika_operasyon_cekirdegi.md).

## Öneri (GPT)

FRZ-008 v2'deki sabit **8 saat/ay** operatörlük bedeli, patronun o ayki **toplam yönetim saatinin yarısı** olarak değişsin. Patron operatörlük yapmıyorsa bu kesinti olmasın. Operatörlük yalnız ilk makinenin tek vardiyasındaki personel ihtiyacını karşılasın; ilave üretim veya OEE bonusu yaratmasın. Gizli Düzelt için FRZ-001 v3'ün azami saat güvencesi ve erken dönem erişim kabul testi korunmalı.

Mevcut patron prototipinde aylık toplam 40 saattir: operatörlük 20 saat tüketir, başka eylem yoksa yönetim için 20 saat kalır. Küçük ölçekte gizli T3 tavanı 8 saattir; prototipin en derin T5 tavanı 16 saattir. Bu nedenle 40 saatlik örnekte tek bir gizli Düzelt güvencesi saat bakımından korunur. Bu sayılar prototip girdisidir; aylık toplam 40 saat bu IDEA ile dondurulmaz. İleride seçilecek toplam saat veya saat bantları bu güvenceyi bozarsa ayrıca dengelenmelidir.

Değişikliğin gerekçesi: operatörlük ilk fabrika ayında patronun yönetim kapasitesinde belirgin bir fırsat maliyeti yaratsın; sabit 8 saat, toplam zaman değiştiğinde bu maliyeti aynı oranda taşımıyor. Tek makinenin kârlılığı hâlâ alınan iş ve giderlere bağlıdır.

Claude incelemesinde özellikle yarım zamanın FRZ-001 v3 erişim testiyle, farklı fabrika ölçekleriyle ve ilerideki toplam saat kararlarıyla uyumu sınansın. Prototipte 40 saatlik örnek için 8 ve 20 saatlik operatörlük koşulları karşılaştırılabilir; maaş ve kira henüz modellenmediğinden ekonomik sonuç bu testten çıkarılamaz.

## Notlar (Claude)

Tur 1 incelemesi bekleniyor.

## Açık Kararlar

- Aylık toplam patron saatinin kesin değeri; 40 saat yalnız mevcut patron prototipinin girdisidir.
- Toplam saat tek sayı olursa yarının saat olarak nasıl yuvarlanacağı.
- İleride toplam saat veya gizli Düzelt üst saati değişirse yarım zaman kuralıyla erişim güvencesinin nasıl birlikte korunacağı.
- 20 saatlik operatörlüğün diğer yönetim eylemleri ve alınan işe göre ekonomik sonucu, personel/maaş/kira prototipiyle sınanacak.

## Karar Özeti

- Kullanıcı patron operatörlük yaptığında aylık toplam saatinin yarısını buna ayırmayı istedi; çünkü ücret tasarrufunun yönetim zamanında belirgin bir fırsat maliyeti olması amaçlanıyor. Claude incelemesi ve yeni FREEZE sürümü bekleniyor.
