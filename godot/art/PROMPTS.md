# Gemini istemleri (üstten fabrika sprite'ları)

Önce **bir stil çapası** üretin, sonra diğer istemlerde onu referans verin ("ekteki görselin stilini eşleştir"). Bu, tüm sprite'ların tutarlı görünmesini sağlar.

## Ortak stil bloğu (her istemin sonuna ekleyin)

```
Strict top-down orthographic game sprite, exactly 90 degrees overhead view, no perspective, no horizon.
Soft light from the top-left with a subtle contact shadow toward the bottom-right.
Realistic industrial look, clean slightly stylized game-asset rendering, muted palette of steel gray, deep blue, safety yellow and orange accents.
The front of the object (control panel / operator side) faces the BOTTOM of the image.
Solid pure magenta background (#FF00FF), nothing else in the image, no floor, no text, no watermark, no logo.
Keep about 10% empty margin around each object.
```

Arka plan macenta olduğu için `art_tools.py` onu şeffaf yapar. Gemini arka planı tam macenta vermezse `--tol 90` deneyin.

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
