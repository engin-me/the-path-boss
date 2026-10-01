# Oyun görselleri (art)

Godot yalnızca `godot/` klasörünün içini görür. Görselleri buraya koyun; kod uzantıyı kendisi bulur (png, jpg, jpeg, webp). Dosya yoksa yer tutucu çizim kullanılır.

| Ne | Yol | Ad |
| --- | --- | --- |
| Kiralık bina ilan görselleri | `art/factories/` | `factory_1` … `factory_13` (fabrika boyutlarına göre: 150, 225, 300, 400, 525, 600, 800, 1000, 1500, 2000, 2500, 3000, 3500 m²) |
| Zemin dokusu (kare, kesintisiz) | `art/floor/` | `floor` (bir döşeme 4 × 4 m) |
| Duvar dokusu (kesintisiz) | `art/floor/props/` | `wall` |
| Yükleme rampası kapısı | `art/floor/props/` | `door` |
| Tezgahlar (üstten) | `art/floor/machines/` | `torna_1`, `torna_2`, `torna_3`, `freze_1` … `taslama_3`, `dovme_3` (sonek: 1 Standart, 2 Hassas, 3 Nitelikli) |
| Ekipman (üstten) | `art/floor/equipment/` | `transpalet`, `kasa`, `raf`, `el_aleti`, `takim`, `forklift`, `olcum`, `vinc` |
| Makine ilan görselleri (isteğe bağlı) | `art/machines/` | `torna_1` … `dovme_3` |

Üstten görünümde **tüm sprite'lar arka planı saydam PNG** olmalı ve **önü (kumanda tarafı) görüntünün altına** bakmalı: fabrikanın rampa tarafı ekranın altındadır. Sprite'lar kendi ayak izine (m²) sığacak şekilde otomatik ölçeklenir; oranı bozmayın.

Yardımcı araç (Python + `pip install pillow`):

```powershell
python tools\art_tools.py slice sayfa.png --cols 3 --rows 1 --names torna_1,torna_2,torna_3 --out godot\art\floor\machines
python tools\art_tools.py key  ham\forklift.png --out godot\art\floor\equipment
python tools\art_tools.py resize godot\art\factories --max 1024
```

Gemini istemleri için `PROMPTS.md`.
