# ChatGPT oyun testi bulguları — Tur 1

Test eden: ChatGPT · Tarih: 2026-09-29 · Kaynak: `reports/06_danisman_arayan.md`, `07_kor_tamirci.md`, `08_temkinli_patron.md` ve `reports/_ozet_chatgpt.md`. Her karakter 12 ay ve 40 farklı tohumla oynandı. Bu dosya **tasarım kararı değildir**; geçerli değişiklikler IDEA ve kullanıcı onayı gerektirir.

| Karakter | Ayakta / 40 | Ortalama son net kasa | Ortalama Düzelt denemesi | Başarı | Ortalama danışman | Görülmeyen kayıp payı |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Danışman Arayan | 40 | 63 | 10,0 | %100 | 3,2 | %61 |
| Kör Tamirci | 40 | 191 | 18,8 | %80 | 0 | %54 |
| Temkinli Patron | 40 | 69 | 11,8 | %100 | 0 | %60 |

## Bulgular

1. **Danışman, kör müdahaleye göre zayıf kalıyor.** İlk iki karakterin yetkinlikleri, başlangıç parası, A+B makine parkı ve tohumları aynı. Danışman Arayan gizli kayıp 3'e ulaşınca danışman arıyor ve yalnız görünür sorunları düzeltiyor; Kör Tamirci danışman tutmadan gizli sorunları da deniyor. 40 tohumda ikisi de 40 kez ayakta kaldı; ortalama net kasa **63'e karşı 191**, danışman kullanımı **3,2'ye karşı 0**. Tek tohum raporunda danışman rotası 12. ayı **−4 kasa, 100 borç** ile, kör rota **243 kasa, sıfır borç** ile bitirdi. İlgili kararlar: FRZ-001 §3–5, FRZ-006 v2 §3–4. Bu, Claude'un danışman değeri ve kör deneme bulgularını destekliyor. **Öneri:** Sözleşme ücretini, adayların gerçekten açtığı Tier'i ve tipik sorun kaybını aynı ölçek üzerinde denge testine sokalım. Bu sonuç tek başına FREEZE değişikliği gerektirmez. İki rota farklı müdahaleler yaptığı için rastgele sayı tüketimi de ayrışıyor; gerçek neden-sonuç ölçümü için sabit olay akışıyla eşlenmiş test gerekir.

2. **Orta bilgi düzeyi gizli sorun birikimini durdurmuyor.** On alanın tamamı 60 olan Temkinli Patron'un örnek tohumunda 12. ay raporu **26/60 kayıp** ve **dört gizli satır** gösteriyor; 40 tohumda görülmeyen kayıp payı **%60**. Görünür sorunları kesin düzeltebilmesine rağmen derin T3 kökler birikiyor. İlgili kararlar: FRZ-001 §2, §6; FRZ-002 v3 §1–2. Claude'un “ertelenen sorun” bulgusuyla aynı yönde. **Öneri:** Sorunların oluşma, sürme ve büyüme hızını ayrıca test edelim; gizli Tier'i ele vermeden oyuncuya danışman/deneme için anlamlı bir yol kalmalı.

3. **“Ayakta” etiketi sağlıklı işletmeyi anlatmıyor.** Üç karakter de 40/40 kapanmadan 12. aya ulaştı; ancak Danışman Arayan'ın örnek oyunu eksi kasa ve borçla bitti. FRZ-003 v2 §1'deki altı aylık kurtarma eşiği henüz aşılmadığı için sonuç teknik olarak doğru. **Öneri:** Raporlarda “ayakta” yanında nakit, borç, son üç ayın faaliyet sonucu ve müdahale kapasitesi de gösterilsin. 24–36 aylık test, yavaş krizleri 12 aylık testten daha iyi ayırır. Eşiğin kendisini değiştirme kararı için bu veri henüz yeterli değil.

4. **Makine seçimi karşılaştırmaları sınırlıyor.** Bu üç karakterin hepsinde A+B var; hepsi 40/40 ayakta. Claude'un aynı makine tablosunda da dört karakter 40/40 ayakta kalmıştı. Bu, A+B parkının mevcut teklif üretimi altında güçlü bir başlangıç olabileceğini gösteriyor; yetkinlik etkisini ölçmek için makine parkını sabit tutmak yararlı, fakat yalnız bu parkla genel denge kararı verilmemeli. İlgili karar: FRZ-004 §1, §4–5. **Öneri:** A×2 ve B×1 ile aynı karakter/politika için ayrı testler; makineye uygun teklif payını ayrıca raporlama.

## Koşucu düzeltmesi ve sınırlar

- Koşucu önce sorun satırlarını **Düzelt sonrasında** sayıyor, aynı satırdaki kaybı ise müdahale öncesi rapordan alıyordu. Bu yüzden kayıp varken “0 görünür / 0 gizli” görülebiliyordu. Sayım müdahale öncesine taşındı; bu yalnız rapor doğruluğu düzeltmesidir, oyun kuralı değildir.
- `author=ChatGPT` filtresi eklendi. ChatGPT raporları ayrı `_ozet_chatgpt.md` dosyasına yazılır; Claude'un bulgu ve raporları korunur.
- Bütün para, makine, olasılık ve süre değerleri prototip test girdisidir. Yukarıdaki gözlemler onaylı denge değerleri veya FREEZE değişikliği değildir.
