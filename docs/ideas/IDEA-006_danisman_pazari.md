# IDEA-006 — Danışman Pazarı

## Durum/Tur

Durum: DRAFT — Claude incelemesi bekleniyor; bu dosya FREEZE değildir.
Tur: 1
Date: 2026-09-29
Bağımlılıklar: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md), [FRZ-002 v3](../freeze/FRZ-002_v3_fabrika_ekonomisi.md). Önceki yönlendirmeler [IDEA-001](IDEA-001_patron_yetkinlikleri.md) içindedir.

## Öneri (GPT)

**Kart havuzu ve fiyat.** Başlangıç için yaklaşık 10–15 önceden tanımlı danışman profili olsun. Bir kartta 2–5 yetkinlik listelensin; her listelenen puan 25–100 arasında ve toplam puan en fazla `alan sayısı × 60` olsun. İki alanda 100 mümkündür, ama nadir ve pahalıdır. Fiyat özellikle kartın en yüksek iki puanıyla yükselsin. Güçlü kartlar küçük fabrika havuzunda seyrek olsun; ölçeğin izin verdiği en derin sorunu teşhis edebilecek profil türü havuzdan tümüyle çıkarılmasın. Kesin ücretler ve profil sayısı dengede belirlensin.

**Aylık seçim.** Ay sonu raporundan sonra üç ücretsiz aday gösterilsin. Oyuncu dördüncü rastgele kartı oyun parası **veya** gerçek paradan biriyle açabilir; ikinci ücretli çekim beşinci kartı getirir ve **dördüncü kartın yerini alır**. Ayda en fazla iki ücretli çekim yapılır. Dördüncü çekimde görünen bilgi açığını kapatan aday gelme olasılığı normal çekimden **10 yüzde puan yüksek** olsun. Seçim yalnızca patronun puanları, görünen kayıplar ve fabrika ölçeğiyle hedeflenir; gizli kök neden kart teklifinden sızmaz. Aynı kart ileriki aylarda tekrar çıkabilir, fakat hâlen çalışan danışman aday havuzuna girmez.

**Sözleşme.** Oyuncu en fazla iki aktif danışman tutabilir. Danışman imza anında başlar; listedeki bütün alanları sözleşme boyunca aktiftir. Ödenen sözleşme bedeli iade edilmez. Sözleşme yalnızca **ilk yarısında** uzatılabilir; uzatma yeni aday çekilişinden ayrıdır. Bir aylık ücret `A` ise 3 ay `2,75A`, 12 ay `10A` örnek indirimli sözleşmelerdir, kesin fiyat kuralı değildir. Bir aylık sözleşmenin “ilk yarıda uzatma”ya nasıl uygun olacağı ayrıca netleşmelidir.

**Oyundaki etki ve ödeme sınırı.** Danışmanın alan puanı FRZ-001'deki `max(patron, aktif danışmanlar)` hesabına girer; puan eklenmez. Danışman ilgili sorunu görmeyi ve kesin çözüm eşiğine erişmeyi sağlayabilir, Düzelt'in patron zamanını azaltır ama kökün oyun parası maliyetini düşürmez. Sözleşme ücretinin para çıkışı FRZ-002 v3'ün karar anı hesabına girer. Aynı teklif oyun parasıyla da alınabilmeli; gerçek para bir sorunu çözmenin zorunlu yolu olmamalı. Ücretli **rastgele** kart çekiminin adaleti ve sunumu, monetizasyon incelemesinde ayrıca değerlendirilmelidir.

## Notlar (Claude)

İnceleme bekleniyor. Yalnızca kritik çelişkileri ve en fazla üç açık kararı yaz.

## Açık Kararlar

1. Bir aylık sözleşme için “yalnızca ilk yarıda uzatma” kuralı nasıl işleyecek? Uygulanamıyorsa bu süre uzatılamaz mı?
2. On–on beş sabit profil içinde ölçeğe uygun aday, görünen bilgi açığına hedefleme ve +10 yüzde puanlık dördüncü kart olasılığı gizli bilgiyi sızdırmadan nasıl sağlanacak?
3. Oyun parasıyla makul erişim korunurken gerçek parayla rastgele ek kartın oyuncu adaleti ve fiyat dengesi nasıl sınanacak?

## Karar Özeti

- Bu turda yeni nihai karar yoktur. Önceki kullanıcı yönlendirmesi: sınırlı, farklı uzmanlık kartları ve süreli pahalı sözleşmeler oyuncunun bilgi açığını kapatsın; çünkü danışman kariyer deneyimine alternatif olabilmeli ama onu bedelsiz geçersiz kılmamalıdır. Bu IDEA henüz FREEZE değildir.
