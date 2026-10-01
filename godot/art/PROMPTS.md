# Gemini istemleri (üstten fabrika sprite'ları)

Ayrı bir çapa istemi yoktur: **ilk beğendiğiniz Torna sheet'i stil çapasıdır.** Aynı sohbette devam edin, her sonraki isteme "Match the style of the previous image exactly (photorealistic, same lighting, palette, detail level; magenta background, no floor)" ekleyin. Yeni sohbet açarsanız Torna görselini yükleyin.

## Ortak stil bloğu (her istemin sonuna ekleyin)

```
Strict top-down orthographic game sprite, exactly 90 degrees overhead view, no perspective, no horizon.
PHOTOREALISTIC, not illustrated and not a 3D render: it must look like a real photograph taken from directly above with a drone or ceiling camera. Real paint with slight wear, scratches, oil stains, dust, metal reflections, visible bolts, welds, cables and coolant residue, natural film grain, uneven real-world lighting. No cartoon look, no vector look, no clean CGI smoothness, no outlines.
Soft light from the top-left with only a tiny soft contact shadow right under each object.
Muted palette of steel gray, deep blue, safety yellow and orange accents.
The front of the object (control panel / operator side) faces the BOTTOM of the image.
Solid pure magenta background (#FF00FF) filling the ENTIRE canvas, including around and between the objects. No floor, no concrete, no gray patch behind any object, no text, no watermark, no logo.
Keep about 10% empty margin around each object.
```

Arka plan macenta olduğu için `art_tools.py` onu tona göre şeffaf yapar ve kenardaki pembeyi temizler (saf `#FF00FF` olması gerekmez). Gemini görselin altına gri zemin koyarsa 'remove the gray floor, magenta fills the entire canvas' diye düzelttirin. Pembe kalırsa `--tol 50`, makine silinirse `--tol 90` deneyin.

## 1. Tezgahlar (4 tür × 3 seviye; her tür için bir istem)

Seviyeler: **Standart** = eski, yıpranmış, yeşil-gri boya, elle kumanda; **Hassas** = daha yeni, mavi-gri boya, kapalı kabin, küçük panel; **Nitelikli** = modern, beyaz-siyah, tam kapalı, büyük dokunmatik ekran, güvenlik camı, sarı detaylar.

**Torna** (3 yan yana):
```
A row of THREE top-down sprites of the same CNC lathe at three quality tiers, left to right on one wide canvas with equal spacing:
1) Standart: older worn manual-looking lathe, gray-green paint, exposed chuck and long bed.
2) Hassas: newer enclosed CNC lathe, blue-gray paint, small control panel.
3) Nitelikli: modern premium fully enclosed turning center, white and black, large touchscreen, safety glass window, yellow accents.
Each machine seen from above: chuck on the left, tailstock on the right, chip conveyor, control panel at the bottom edge. About 1.2:1 width to depth.
[ORTAK STİL BLOĞU]
```
Kesme: `python tools\art_tools.py slice torna.png --cols 3 --rows 1 --names torna_1,torna_2,torna_3 --out godot\art\floor\machines`

**Freze** (`freze_1..3`):
```
THREE top-down sprites of the same CNC vertical milling machine at three tiers (Standart, Hassas, Nitelikli) in a row, equal spacing. Square footprint, moving table and tool changer visible from above, enclosure doors and control panel at the bottom edge. Tier looks: Standart worn gray-green and open; Hassas blue-gray semi-enclosed; Nitelikli white-black fully enclosed with big touchscreen and yellow accents.
[ORTAK STİL BLOĞU]
```

**Taşlama** (`taslama_1..3`):
```
THREE top-down sprites of the same grinding machine at three tiers (Standart, Hassas, Nitelikli) in a row, equal spacing. Long table, grinding wheel head with a yellow guard, coolant tank at the side, control panel at the bottom edge. Standart worn and open; Hassas blue-gray enclosed; Nitelikli white-black with glass enclosure and touchscreen.
[ORTAK STİL BLOĞU]
```

**Dövme** (`dovme_1..3`):
```
THREE top-down sprites of the same hydraulic forging press at three tiers (Standart, Hassas, Nitelikli) in a row, equal spacing. Large square press frame seen from above with the ram cylinder on top, an anvil base, hydraulic accumulator tanks and a small induction furnace beside it, control panel at the bottom edge. Standart rough dark-orange and open; Hassas heavy blue-gray; Nitelikli modern gray-white with safety light curtains and yellow accents.
[ORTAK STİL BLOĞU]
```

## 2. Ekipman (iki sayfa, her biri 4 nesne)

**Sayfa A** (`transpalet, kasa, raf, el_aleti`):
```
FOUR separate top-down sprites in a row with equal spacing:
1) A manual pallet jack with a wooden pallet of boxes, forks pointing DOWN, handle at the top, about 0.8 x 1.6 proportion.
2) A small stack of plastic material crates seen from above, nearly square.
3) One industrial pallet rack seen from above: a tall narrow rectangle (about 1:2.1) with boxes on shelves, blue frame, orange beams.
4) A workbench with tool boards seen from above, a long rectangle (about 1:2), tools laid out neatly.
[ORTAK STİL BLOĞU]
```
`python tools\art_tools.py slice ekipman_a.png --cols 4 --rows 1 --names transpalet,kasa,raf,el_aleti --out godot\art\floor\equipment`

**Sayfa B** (`takim, forklift, olcum, vinc`):
```
FOUR separate top-down sprites in a row with equal spacing:
1) A tool and fixture cabinet seen from above, a wide narrow rectangle (about 2:1), gray steel with yellow handles.
2) A yellow-orange counterbalance forklift seen from above, forks pointing DOWN, about 1:2 proportion.
3) A small glass-walled metrology (CMM) cabin seen from above with a granite measuring table inside, nearly square.
4) A bridge crane: a long yellow beam with a hoist trolley and hook seen from above, very wide and thin (about 10:1).
[ORTAK STİL BLOĞU]
```
`python tools\art_tools.py slice ekipman_b.png --cols 4 --rows 1 --names takim,forklift,olcum,vinc --out godot\art\floor\equipment`

## 3. Duvar, kapı

Duvar (kesintisiz doku, **macenta arka plan yok**, düz kare):
```
Seamless tileable top-down texture of an industrial factory wall cap: dark gray concrete blocks with a subtle lighter top edge, square image, no perspective, no text, seamless in all directions.
```
Kaydet: `godot/art/floor/props/wall.jpg`

Yükleme rampası kapısı (4 : 0.8 oran):
```
A top-down sprite of a sectional loading dock door with a dock leveler plate, seen from above, wide thin rectangle about 5:1, yellow-black hazard stripes on the edges, gray steel plate in the middle.
[ORTAK STİL BLOĞU]
```
Kaydet: `python tools\art_tools.py key kapi.png --out godot\art\floor\props` → `door.png`

## Notlar

- Gemini her seferinde farklı çıkarsa **ilk beğendiğiniz sprite'ı referans** olarak yükleyip "match this style exactly" yazın.
- Sprite oranı ayak izine yakın olsun; oyun görseli ayak izine **oranı bozmadan sığdırır**.
- Boyut: tezgah ve ekipman sprite'ları 512 px, doku 1024 px yeter (`--max` varsayılanı 512).
- Görseller bittiğinde `git add godot/art` ve push edin; ben bakıp ölçek/konum ayarını yaparım.

## 4. Makine ilan kartı görselleri (16:9 fotoğraf, `art/machines/<tür>_<seviye>.jpg`)

Ortak stil (her istemin sonuna ekleyin):
```
Photorealistic industrial photograph, 16:9, three-quarter front view from slightly above eye level, the machine centered, a real machine shop in the background softly blurred (concrete floor, other machines far away), natural window light, muted palette of steel gray, deep blue, safety yellow and orange accents. No text, no logo, no people, no watermark.
```
İlk beğendiğiniz görselden sonra her istemin başına "Match the style of the previous image exactly." ekleyin.

| Dosya | İstem (stil bloğundan önce) |
| --- | --- |
| `torna_1` | An older worn manual-looking engine lathe, gray-green paint, exposed chuck, long bed, oil stains |
| `torna_2` | A newer enclosed CNC lathe, blue-gray paint, small control panel, half-open sliding door |
| `torna_3` | A modern premium fully enclosed CNC turning center, white and black, large touchscreen, safety glass window, yellow accents |
| `freze_1` | An older open vertical milling machine, gray-green paint, exposed table and manual handwheels |
| `freze_2` | A newer semi-enclosed CNC vertical milling machine, blue-gray paint, tool changer visible |
| `freze_3` | A modern premium fully enclosed 5-axis machining center, white and black, big touchscreen, yellow accents |
| `taslama_1` | An older open surface grinding machine, gray-green paint, long table, yellow wheel guard, coolant tank |
| `taslama_2` | A newer enclosed CNC grinding machine, blue-gray paint, small control panel |
| `taslama_3` | A modern premium fully enclosed CNC grinder, white and black, glass enclosure, touchscreen, yellow accents |
| `dovme_1` | A rough dark-orange hydraulic forging press, open frame, anvil, hydraulic tanks, small induction furnace beside it |
| `dovme_2` | A heavy blue-gray hydraulic forging press with guarded frame and control cabinet |
| `dovme_3` | A modern gray-white servo forging press with safety light curtains, glass guard, yellow accents |

Kaydet: `godot/art/machines/<ad>.jpg` ve `python tools\art_tools.py resize godot\art\machines --max 1024`.

## 5. İşçi (üstten, saydam PNG)

```
A single factory worker seen strictly from above (top-down orthographic), standing, blue work overalls, yellow hard hat, safety vest, arms slightly forward as if operating a machine. Solid pure magenta background (#FF00FF) filling the whole canvas, no floor, no shadow rectangle, photorealistic, about 0.6 x 0.6 m footprint, front of the body faces the BOTTOM of the image.
```
Kesme: `python tools\art_tools.py key worker.png --out godot\art\floor\props` → `worker.png` (oyun yoksa çizilmiş yer tutucu kullanır).

## 6. Müzik (isteğe bağlı) — `godot/audio/music/main.ogg`

Oyun, bu dosya varsa ilk dokunuştan sonra döngüyle çalar; yoksa sessizdir. Dosya `main.mp3`, `main.ogg` ya da `main.wav` olabilir (ffmpeg şart değil; MP3 doğrudan çalışır, ancak döngü noktasında kısa bir boşluk duyarsan OGG'ye çevir). Ses efektleri (dokunma, onay, para girişi/çıkışı, ay sonu) kodla üretilir, dosya gerekmez. Profil > Ses'ten kapatılır.

Suno/Udio benzeri bir müzik üreticisi için istem (tek parça, 2–3 dakika, kesintisiz döngüye uygun):
```
Instrumental background music for a calm business management game about running a small factory. Relaxed focused mood, around 90 BPM, warm electric piano and soft analog synth pads, gentle muted bass, light percussion with subtle mechanical ticks and soft clicks, faint industrial hum in the background, optimistic but serious. No vocals, no sudden loud parts, ends in a way that loops seamlessly.
```
İkinci (isteğe bağlı) parça — baskı/kriz anları için: aynı istem, "slightly tense, 110 BPM, minor key, pulsing low synth".

Lisans: üreticinin kullanım koşullarını kontrol edin (ticari kullanım çoğu zaman ücretli plan ister). Alternatif: CC0 / ticari kullanıma açık müzik arşivleri; lisansı dosyayla birlikte saklayın.

Dönüştürme (ffmpeg): `ffmpeg -i parca.mp3 -c:a libvorbis -q:a 4 godot\audio\music\main.ogg` (yaklaşık 3 MB altı hedefleyin).
