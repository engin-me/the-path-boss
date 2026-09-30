# Patron testi — nasıl oynanır, nasıl not düşülür

Bu klasör **yalnızca patron bölümünün** oyun testleri içindir. Patron testi, CURRENT [FRZ-001 v2](../../docs/freeze/FRZ-001_v2_patron_yetkinlikleri.md) şans eğrisi ve [FRZ-007 v3](../../docs/freeze/FRZ-007_v3_calisanlik_kariyeri.md) diploma tavanlarıyla birlikte henüz CURRENT olmayan [IDEA-010](../../docs/ideas/IDEA-010_sorun_buyumesi.md) sorun büyümesini de sınar. Ayrıntı: `claude_bulgular.md`, Tur 2. Kariyer atlanır: yetkinlikler doğrudan dağıtılır, cebe para konur, makine alınır, iş alınır, sorunlar yönetilir. Bütün sayılar **test girdisidir**, denge kararı değildir.

Üç test eden aynı oyunu oynar:

| Kim | Nasıl oynar | Nereye yazar |
| --- | --- | --- |
| Emrah (manuel) | Godot'ta `project.godot` → F5. Açılış ekranı patron testidir. | Oyundaki **📝 Not ekle** → `notes/notes.md` |
| Claude | `personas/*.json` karakterleriyle başsız koşucu | `reports/*.md`, `claude_bulgular.md` |
| ChatGPT / Codex | Kendi karakter JSON'unu ekleyip aynı koşucu | `reports/*.md`, `chatgpt_bulgular.md` |

## Manuel oyun

1. Hazır karakter seç ya da on yetkinliği kendin dağıt. Toplam, bütçeyi (varsayılan 600, değiştirilebilir) aşarsa başlatılamaz.
2. Cebindeki parayı gir, makine seç. Kuruluştan sonra kasa, ilk ayın gideri + gizli sorun güvencesi kadar kalmalıdır (FRZ-002 v3 §4).
3. Her ay: iş seç → rapor → Düzelt / danışman / kredi → ayı kapat.
4. "Bu saçma olmuş" dediğin her anda **📝 Not ekle**: kategori seç, yaz, kaydet. Karakter, ay, kasa ve makine bilgisi nota kendiliğinden eklenir.

Notlar `godot/playtests/notes/notes.md` dosyasına eklenir (Godot editöründen çalıştırıldığında). Dışa aktarılmış sürümde Godot'un `user://playtests/notes/` klasörü kullanılır.

## Karakterle başsız oyun

```powershell
# Bütün karakterler, her biri için ayrıntılı rapor
& 'C:\...\Godot_v4.7.2-stable_win64_console.exe' --headless --path godot --script res://tests/persona_run.gd
# Tek karakter
... --script res://tests/persona_run.gd -- persona=01_teknik_usta.json
# 40 farklı tohumla özet (reports/_ozet.md)
... --script res://tests/persona_run.gd -- seeds=40
# Yalnız ChatGPT karakterleri; Claude raporlarına dokunmaz
... --script res://tests/persona_run.gd -- author=ChatGPT seeds=40
# Herkese aynı makine parkı (makine etkisini ayıklamak için; reports/_ozet_ayni_makine.md)
... --script res://tests/persona_run.gd -- seeds=40 machines=A:1,B:1
```

## Karakter dosyası

`personas/` altına yeni bir JSON ekle. `author` alanına kendi adını yaz (`Claude`, `ChatGPT`). Aynı dosya oyunun "Hazır karakter" listesinde de görünür.

```json
{
  "name": "Karakter adı",
  "author": "ChatGPT",
  "description": "Bu patron kim, nasıl davranır?",
  "seed": 77,
  "budget": 600,
  "cash": 400,
  "diploma": "isletme",               // "" (yok) · "muhendislik" · "isletme" · "ikisi"
  "months": 12,
  "skills": {"Üretim": 60, "Planlama": 60, "Depo & Sevkiyat": 60, "Bakım": 60, "Kalite": 60,
             "Satın Alma": 60, "Finans": 60, "Ar-Ge / Ür-Ge": 60, "Yatırım": 60, "İnsan Yönetimi": 60},
  "machines": {"A": 1, "B": 1},
  "policy": {
    "jobs": "greedy",                 // greedy: kapasiteyi doldur · safe: %20 boş bırak
    "fix": "all",                     // all · visible_only · none
    "min_chance": "Orta",             // Belirsiz < Düşük < Orta < Yüksek < Kesin
    "hire_when_hidden_loss": 6,       // bir departmanın gizli kaybı bu kadarsa danışman ara (0 = hiç)
    "credit_when_cash_below": 60,     // kasa bunun altındaysa tek seferlik kredi
    "buy": [{"month": 4, "type": "B"}]
  }
}
```

JSON yorum desteklemez; yukarıdaki `//` açıklamalarını dosyaya yazma.

## Bulgu yazma kuralı

- Bulgu dosyaları (`claude_bulgular.md`, `chatgpt_bulgular.md`) ve `notes/notes.md` **tasarım kararı değildir**. Geçerli bulgu yeni bir IDEA'ya taşınır; FREEZE yalnızca kullanıcı onayıyla değişir.
- Her bulguda: ne görüldü, hangi rapor/tohum, hangi FREEZE maddesiyle ilgili, öneri.
- Test verisinden doğan sorunla (fiyat, olasılık) kuraldan doğan sorunu ayır.
