# ChatGPT oyun testi bulguları — Tur 2

Test eden: ChatGPT · Tarih: 2026-09-30 · Kaynak: `reports/06_danisman_arayan.md`, `07_kor_tamirci.md`, `08_temkinli_patron.md` ve `reports/_ozet_chatgpt.md`. Her karakter 12 ay ve 100 farklı tohumla `author=ChatGPT seeds=100` üzerinden oynandı. Bu dosya **tasarım kararı değildir**.

Üç karaktere `"diploma": "ikisi"` eklendi. Bu seçim, eski karakterlerin verdiği puanları diploma tavanında kırpmadan aynı profilleri karşılaştırır; **diplomasız rotayı test etmez**. Danışman Arayan ve Kör Tamirci aynı puan, makine ve başlangıç parasıyla karşılaştırılır. Koşu, güncel patron testindeki %4 şans eğrisi, %5 sorun büyümesi ve ayarlanmış danışman ücretiyle yapıldı; yalnız tek değişkenin etkisi olarak yorumlanmamalıdır.

| Karakter | Ayakta / 100 | Ortalama son net kasa | Ortalama Düzelt denemesi | Başarı | Ortalama danışman | Görülmeyen kayıp payı |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Danışman Arayan | 100 | 94 | 11,3 | %100 | 4,0 | %71 |
| Kör Tamirci | 100 | 65 | 21,2 | %56 | 0 | %71 |
| Temkinli Patron | 100 | 31 | 11,6 | %100 | 0 | %60 |

## Bulgular

1. **Danışman rotası bu karakter çiftinde kör denemeden daha iyi:** Ortalama net kasa 94'e karşı 65. Ancak danışman dört sözleşme kullanıyor; kalıcı kariyer yetkinliğinin yerini alacak kadar sürekli kullanılıp kullanılmadığı 24–36 ayda incelenmeli. Kaynak: FRZ-001 v2 §3–4, FRZ-006 v2 §3–4. Eski 40 tohumlu 63'e karşı 191 karşılaştırması, kod ve tohum düzeltmeleri nedeniyle artık geçerli denge kanıtı değildir.
2. **Gizli kayıp sürüyor:** Danışman Arayan ile Kör Tamirci'nin görülmeyen kayıp payı yaklaşık %71; danışmanlık ve kör deneme aynı sorunu farklı bedelle yönetiyor, otomatik olarak ortadan kaldırmıyor. Kaynak: FRZ-001 v2 §2–5, IDEA-010.
3. **Üçü de 12 ay ayakta kaldı:** Bu, 100/100 iflas etmeme sonucudur; uzun vadeli kârlılık veya bütün makine parklarının yaşaması anlamına gelmez. Üç karakterin de A+B parkı ve 400 başlangıç parası var. Erken Kurucu'nun A×2 parkındaki sıkışma için IDEA-012 ve `claude_bulgular.md` esas alınmalı. Kaynak: FRZ-003 v2 §1, FRZ-004 §4–5.
4. **Temkinli rota bu üçlüde en düşük net kasada:** Görünür sorunları kesin çözmesine rağmen ortalama son net kasa 31. Gizli sorunu ertelemenin uzun dönem etkisi, büyüme ve teklif havuzu düzeltmesi birlikte test edilmeden kesin denge kararı sayılmamalı. Kaynak: IDEA-010 ve IDEA-012.

## Test sınırları

- Raporlar yalnız ChatGPT karakterlerinin çıktısıdır; Claude karakter raporları ve bulguları değiştirilmedi.
- İki diplomalı karakterler 70/50/30 tavanlarının diplomasız oyuncu üzerindeki etkisini ölçmez. Bu etki Claude'un diplomasız Teknik Usta ve Erken Kurucu testleriyle ayrıca sınanır.
- Yüzdeler ve para tutarları prototip verisidir; katalog, teklif üretimi ve danışman fiyatı kesin FREEZE dengesi değildir.
