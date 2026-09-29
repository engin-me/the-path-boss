# FRZ-002 — Fabrika Ekonomisinin Çekirdeği

Status: CURRENT
Date: 2026-09-29
Source: [IDEA-002](../ideas/IDEA-002_fabrika_ekonomisi.md), Tur 2 ve kullanıcının Claude önerilerini kabulü.
Depends on: [FRZ-001](FRZ-001_patron_yetkinlikleri.md).

## Onaylanan Kararlar

### 1. Ortak rapor birimi ve kayıp hesabı

**Ne:** Ay sonu raporu beklenen, gerçekleşen ve kaybedilen **çıktı eşdeğeri birimi** gösterir. On yetkinlik alanının fiziksel üretim, para veya ilk sürümde gelecek fırsatı kaybı bu ortak rapor birimine çevrilir. Çıktı eşdeğeri, fiziksel satılan ürün sayısı değildir. Her kayıp birimi yalnızca **bir sorun satırına ve kökün bulunduğu bir departmana** aittir. Ortak köke bağlı farklı satırların ayrı kayıpları toplanır; başarılı Düzelt hepsini kaldırır. Departmanların eşdeğer kayıpları toplanır, çarpımsal hesap kullanılmaz.

**Neden:** Gizli satırın kayıp birimi Tier'ini ele vermemeli; rapor toplamı anlaşılır olmalı ve aynı malzeme veya para kaybı iki departmanda sayılmamalıdır.

### 2. Basit sınırlar

**Ne:** Raporun gerçekleşen çıktı eşdeğeri, beklenenin **en az %33'ü** olur. Bir departmanın eşdeğer kaybı, beklenenin **yaklaşık %20'si** düzeyinde bir üst sınırla tutulur; bu oran ilk denge hedefidir. Tavana ulaşmış departmanda ek kayıp sorunu üretilmez. Ayrı bir departman ağırlıkları tablosu kurulmaz.

**Neden:** Fabrika performansı eksiye veya çıkışsız seviyeye inmemeli; bölüm kayıpları okunur kalmalı ve karmaşık ağırlık hesabı gerekmemelidir.

### 3. Ay akışı ve kullanılabilir nakit

**Ne:** Sıra **rapor → danışman ve Düzelt kararları → ayın satışları ile olağan giderleri → sonraki rapor** şeklindedir. FRZ-001'in güvence kontrolündeki kullanılabilir oyun parası, **mevcut nakit eksi bu ayın henüz ödenmemiş bilinen olağan giderleridir**; gerçekleşmemiş satış geliri eklenmez. Danışman ve Düzelt bedelleri FRZ-001'e göre karar anında ödenir. Ay sonu kasa, önceki kasa + fiili satış geliri − fiili olağan giderler − danışman sözleşmeleri − Düzelt bedelleriyle açıklanır.

**Ne:** Gerçek satış geliri fiziksel olarak satılan üründen hesaplanır. Nakit kaybının çıktı eşdeğerine çevrilmesi **yalnızca rapor ölçüsüdür**; aynı gerçek gider kasa hesabından ikinci kez düşülmez.

**Neden:** Oyuncu ay sonu zorunlu giderleri müdahaleye harcayamamalı, henüz kazanmadığı satış gelirine dayanarak karar vermemeli ve rapor dönüşümü nakit kaybını iki kez yazmamalıdır.

### 4. Müdahale faydası ve erken erişim

**Ne:** Düzelt sonucu ve bedeli anında belli olur; kaldırılan kaybın rapor etkisi **sonraki ay** görünür. Tier fiyat bantları fabrika ölçeğinin aylık birim değeriyle orantılı tutulur. Kuruluş sonrasındaki kasa en az **ilk ayın bilinen olağan giderleri + küçük ölçekteki olası en derin Tier'in üst güvence bedeli** kadar olmalıdır. FRZ-001'in ilk üç ay danışmansız gizli sorun deneme testi ayrıca sınanır.

**Neden:** Geçmiş raporlar yeniden yazılmamalı; küçük fabrikada da bilgi açığını oyun parasıyla deneme yolu açık kalmalıdır.

## Reddedilen Yollar

- Gizli sorunlarda nakit ve fiziksel çıktı kaybını farklı rapor birimleriyle göstermek; Tier veya sorun türü birimden anlaşılabilir.
- Aynı kaybı farklı departmanlarda tekrar saymak; toplam raporu ve müdahale etkisini şişirir.
- Gelecek satış gelirini Düzelt güvencesine eklemek; henüz gerçekleşmemiş kazanca dayanarak zorunlu gider parasının harcanmasına yol açabilir.
- Departman ağırlıkları ve çarpımsal kayıp hesabıyla başlamak; ilk ekonomi modelini gereksiz karmaşıklaştırır.

## Bağımlılıklar ve Kapsam Dışı Konular

- Çıktı eşdeğerine çevirme değeri, para/saat tutarları, kuruluş sonrası kasa miktarı ve yaklaşık %20 departman sınırının kesin dengesi testle belirlenecektir.
- Beklenmeyen giderler, tek kötü ay sonrası toparlanma ve iflas tetikleyicisi ayrı ekonomi/iflas tasarımına aittir; bilinen giderleri ayırma kuralı tüm belirsizlikleri ortadan kaldırmaz.
- Ar-Ge ve Yatırım'ın gerçek uzun vadeli etkileri ayrıca tasarlanır; ilk sürümde aylık çıktı eşdeğeriyle raporlanabilir.
- Danışman kartlarının fiyatları ve gerçek para seçenekleri bu FREEZE kapsamında değildir.
