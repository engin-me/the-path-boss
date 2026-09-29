# IDEA-002 — Fabrika Ekonomisi

## Durum/Tur

Durum: DRAFT — GPT kısa önerisi, Claude incelemesi bekleniyor
Tur: 1
Date: 2026-09-29
Bağımlılık: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md). Bu dosya FREEZE değildir.

## Öneri (GPT)

Ay sonu raporu üç ana sayı göstersin: **beklenen çıktı, gerçekleşen çıktı, çıktı kaybı**. Beklenen çıktı makine kapasitesi, ürün ve talebe göre belirlenir. **Çıktıyı etkileyen** sorun satırlarının kayıpları kendi departman toplamını; bu toplamlar da fabrikanın çıktı kaybını açıklar. Nakit veya gelecekteki fırsatı etkileyen sorunların kaybı kendi birimiyle gösterilir. Aynı kayıp iki kez sayılmaz. İlk sürümde çıktı kayıpları toplanır; çarpımsal hesap kullanılmaz.

Oyuncunun nakit hesabı açık olsun: **önceki nakit + satış geliri − olağan işletme giderleri − danışman sözleşmeleri − Düzelt bedelleri = yeni nakit**. Satış geliri gerçekleşen çıktıya bağlıdır. Tam gider listesi ve tutarları bu fikrin parçası değil, sonraki denge işidir.

“Düzelt” sonucu anında belli olur; **çıktıdaki iyileşme bir sonraki ayın raporuna** yansısın. Böylece oyuncu müdahalenin parasını bu ay öder, faydasını sonraki ay görür. Rapor geçmiş ayı yeniden yazmaz.

İlk ekonomi dengesi, [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md)'deki kabul testini geçmeli: ilk üç ayda gizli sorun varsa oyuncu her ay en az birini oyun parası ve patron zamanıyla, danışmansız deneyebilmeli. Tek kötü ay doğrudan kaçınılmaz iflas yaratmamalı.

## Notlar (Claude)

Tur 1 incelemesi burada yazılacak. Özellikle çift sayılan kayıp, oyuncuya açıklanamayan nakit değişimi ve erken fabrikanın çıkışsız kalması incelensin.

## Açık Kararlar

1. On yetkinlik alanının hangileri **bu ayın üretim çıktısını**, hangileri **nakit veya gelecek fırsatlarını** etkiler?
2. Departmanların kayıp birimlerine katkısı nasıl sınırlandırılır? Önceki taslaktaki **%33 departman performans tabanı** korunacaksa fabrika birimlerine nasıl çevrilir?
3. Ekonomi testinde başlangıç parası, aylık gelir/gider ve Tier fiyat bantlarının sayıları ne olmalı? Bunlar ilke onayından sonra denge çalışmasında belirlensin.

## Karar Özeti

IDEA-002 için henüz kullanıcı tarafından onaylanmış karar yok. Yukarıdaki model inceleme önerisidir; FRZ-001 kuralları geçerlidir.
