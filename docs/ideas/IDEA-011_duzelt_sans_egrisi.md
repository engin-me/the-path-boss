# IDEA-011 — Düzelt Şans Eğrisi

## Durum/Tur

Durum: DRAFT — kullanıcı taslak yönünü onayladı; [FRZ-001 v2 taslağı](../freeze/FRZ-001_v2_patron_yetkinlikleri.md) henüz CURRENT değildir.
Tur: 1
Tarih: 2026-09-29
Bağımlılık: [FRZ-001](../freeze/FRZ-001_patron_yetkinlikleri.md) §2–4 ve [IDEA-009](IDEA-009_kariyer_egitim_ve_yetkinlik_yollari.md).

## Öneri (GPT)

Etkin yetkinlik ilgili kökün Tier eşiğine (T1=30, T2=50, T3=70, T4=90, T5=100) ulaşırsa Düzelt kesindir. Altındaysa yüzde şans `max(5, 100 − 4 × (eşik − etkin yetkinlik))` olur. 89 → T4 %96, 70 → T4 %20 ve 50 → T3 %20 örnekleridir. Etkin yetkinlik FRZ-001'deki `max(patron, aktif danışmanlar)` ile bulunur; statlar şansı doğrudan değiştirmez. Prototipin yaklaşık %80/%40/%15/%5 kademe kuralı kaldırılır.

Görünürlük yapısı değişmez: oyuncunun erişemediği dolu satır ayrı adsız satır kalır. Birden fazla gizli Tier mümkünse şans etiketi **Belirsiz**; tek olası gizli Tier varsa çıkarılabilen şans etiketi gösterilir. Görünür satırda etiketler **Kesin** (%100), **Yüksek** (≥%80 ve <%100), **Orta** (%40–79), **Düşük** (<%40; taban %5) olur. Bağlı kökün en derin Tier'i şans hesabında kullanılmaya devam eder.

Sürekli eğri her puanı anlamlı kılar. Kullanıcının aktardığı patron testinde Kör Tamirci başarı oranı %80'den %58'e, net kasa 191'den 106'ya düştü; bu gözlem kör deneme baskısının yönünü gösterir, kesin denge sonucu değildir. Diplomasız tavanın Tier başına inmesi [FRZ-007 v3 taslağı](../freeze/FRZ-007_v3_calisanlik_kariyeri.md) ile birlikte değerlendirilir.

## Notlar (Claude)

Yeni tur incelemesi henüz yapılmadı. Claude'un güncel patron testi bu bölümde kaydedilebilir.

## Açık Kararlar

- Yeni eğri, diploma tavanları ve sorun büyümesi birlikte test edilecek; erken fabrika ve danışmansız gizli deneme imkânının sürüp sürmediği ölçülecek.
- Örnek prototip sonuçlarının tekrarlanabilirliği ve net kasa hesabı test raporunda doğrulanacak.

## Karar Özeti

- Kullanıcı kademe şansı yerine eşik altı her puan farkı için yüzde dört düşen, en az %5 şans bırakan eğriyi taslak yönü olarak onayladı; çünkü her yetkinlik puanı anlamlı olmalı ve kör deneme aşırı ödüllendirilmemeli.
- Kullanıcı eşik ve üstünde kesin çözümü, statların şansa etkisizliğini ve mevcut görünürlük kurallarını korumayı onayladı; çünkü bilgi ve danışman desteği kesin çözümün kaynağı kalmalı, gizli Tier etiketle sızmamalı.
- Kullanıcı görünür olasılık etiketlerini Kesin/Yüksek/Orta/Düşük olarak belirledi; çünkü oyuncu yüzdeyi görmeden müdahalenin risk düzeyini anlayabilmeli.
