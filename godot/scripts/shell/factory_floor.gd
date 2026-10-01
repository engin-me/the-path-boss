extends Control

# Top-down view of the rented factory: tiled floor, walls, loading ramps, racks and crates,
# pallet trucks, benches, and every machine (ordered ones as ghosts). Placement is automatic and
# cosmetic (IDEA-013: no layout bonus). Missing art falls back to coloured shapes.
# Art lookup (res://art/floor/...): floor.jpg, props/wall, props/door, machines/<tür>_<seviye>,
# equipment/<id>. See godot/art/PROMPTS.md.

signal detail_requested(kind: String)
signal layout_changed

const Data = preload("res://scripts/shell/shell_data.gd")
const Art = preload("res://scripts/shell/art.gd")

const BG_OUT := Color("#0b1118")
const WALL := Color("#2a3038")
const FLOOR_FALLBACK := Color("#46505b")
const SAFETY := Color("#e0a800")
const TEXT := Color("#e8eef4")
const SNAP_M := 0.5   # edit mode: items snap to a 0.5 m grid
const WALL_T := 0.8   # wall thickness (m)
const TILE_M := 2.0   # the floor photo covers 2 x 2 m; a 2 x 2 mirrored composite repeats every 4 m
const MACHINE_LENGTH_M := {"Torna": 3.0, "Freze": 2.6, "Taşlama": 3.2, "Dövme": 3.2}   # real machine length (m), sprite keeps its own aspect

const KIND_COLOR := {"Torna": Color("#5f7a96"), "Freze": Color("#4f8f86"), "Taşlama": Color("#8a6fa8"), "Dövme": Color("#b0764a")}
const EQUIP_COLOR := {"transpalet": Color("#d9a23a"), "kasa": Color("#a47a4b"), "raf": Color("#3b6ea5"), "el_aleti": Color("#7a8591"),
	"takim": Color("#6c7a52"), "forklift": Color("#e0b23a"), "olcum": Color("#8fb4c8"), "vinc": Color("#d96a3a")}
const EQUIP_NAMES := {"transpalet": "Transpalet", "kasa": "Malzeme kasası", "raf": "Depo rafı", "el_aleti": "El aletleri tezgahı",
	"takim": "Takım dolabı", "forklift": "Forklift", "olcum": "Kalite ölçüm odası", "vinc": "Köprü vinç"}

var game
var items: Array = []
var interior := Rect2()
var zoom := 12.0
var pan := Vector2.ZERO
var selected := -1
var floor_tex: Texture2D
var wall_tex: Texture2D
var door_tex: Texture2D
var sprite_cache := {}
var press_pos := Vector2.ZERO
var pressing := false
var moved := false
var info_panel: PanelContainer
var info_label: Label
var info_button: Button
var info_kind := ""
var user_adjusted := false
var edit_mode := false
var drag_item := false
var drag_raw := Vector2.ZERO
var rotate_button: Button
var reset_button: Button
var edit_button: Button

func setup(game_ref, saved_zoom := 0.0, saved_pan := Vector2.ZERO) -> void:
	game = game_ref
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	floor_tex = _mirrored_floor(Art.find("res://art/floor/floor"))
	wall_tex = Art.find("res://art/floor/props/wall")
	door_tex = Art.find("res://art/floor/props/door")
	_layout()
	_build_controls()
	resized.connect(_on_resized)
	if saved_zoom > 0.0:
		zoom = saved_zoom
		pan = saved_pan
		user_adjusted = true
	else:
		call_deferred("fit")

func _on_resized() -> void:
	if not user_adjusted:
		fit()

func view_state() -> Dictionary:
	return {"zoom": zoom, "pan": pan, "factory": game.factory_id if game != null else ""}

# ------------------------------------------------------------------ layout (meters)

func _equipment_counts() -> Dictionary:
	var counts := {}
	if game.package_bought:
		var package: Dictionary = game.package_info()
		for id in package["items"]:
			counts[id] = int(package["items"][id])
	for id in game.equip:
		counts[id] = int(counts.get(id, 0)) + int(game.equip[id])
	return counts

func _add(kind: String, id, rect: Rect2, label: String, extra := {}) -> void:
	var item := {"kind": kind, "id": id, "rect": rect, "label": label, "rot": 0}
	item.merge(extra, true)
	item["key"] = "%s:%s:%s" % [kind, str(id), str(item.get("index", 0))]
	items.append(item)

const EQUIP_SIZE := {"raf": Vector2(1.8, 3.75), "kasa": Vector2(0.8, 0.8), "el_aleti": Vector2(1.6, 3.2), "takim": Vector2(1.8, 0.9),
	"olcum": Vector2(1.6, 1.6), "transpalet": Vector2(0.8, 1.6), "forklift": Vector2(1.3, 2.6)}
const PLACE_ORDER := ["raf", "machine", "el_aleti", "olcum", "takim", "forklift", "transpalet", "kasa"]
const DOCK_APRON := 3.2   # free strip in front of the ramps

# Floor footprint of a machine (real size from its sprite) plus a 0.5 m work margin on every side.
func _machine_box(machine: Dictionary) -> Vector2:
	var texture := _sprite_for({"kind": "machine", "machine": machine})
	var ratio := 1.3 if texture == null else float(texture.get_width()) / float(texture.get_height())
	var length_m: float = MACHINE_LENGTH_M.get(machine["kind"], 3.0)
	var footprint := Vector2(length_m, length_m / ratio) if ratio >= 1.0 else Vector2(length_m * ratio, length_m)
	return footprint + Vector2(1.0, 1.0)

func _layout() -> void:
	items.clear()
	var factory: Dictionary = game.factory()
	var width := float(factory["width"])
	var length := float(factory["length"])
	interior = Rect2(0, 0, width, length)
	# loading ramps on the front (bottom) wall
	var ramps: int = int(factory["ramps"])
	var door_w := minf(4.0, width / float(ramps) - 1.0)
	for k in ramps:
		var cx := width * (float(k) + 0.5) / float(ramps)
		_add("door", k, Rect2(cx - door_w / 2.0, length, door_w, WALL_T), "Yükleme rampası %d" % (k + 1))
	var counts := _equipment_counts()
	# everything the player owns, in placement order
	var specs: Array = []
	for group in PLACE_ORDER:
		if group == "machine":
			for machine in game.machines:
				specs.append({"kind": "machine", "id": machine["uid"], "index": 0, "box": _machine_box(machine), "label": machine["model"], "machine": machine})
		else:
			for k in int(counts.get(group, 0)):
				specs.append({"kind": "equip", "id": group, "index": k, "box": EQUIP_SIZE[group], "label": EQUIP_NAMES[group]})
	var saved: Dictionary = game.layout.get(factory_id_key(), {})
	var taken: Array = []
	# 1) items that already have a place (kept forever, so buying more never shuffles them)
	for spec in specs:
		var key := "%s:%s:%s" % [spec["kind"], str(spec["id"]), str(spec["index"])]
		spec["key"] = key
		if saved.has(key):
			var entry: Dictionary = saved[key]
			var rot := int(entry.get("rot", 0)) % 4
			var box: Vector2 = spec["box"]
			if rot % 2 == 1:
				box = Vector2(box.y, box.x)
			spec["rot"] = rot
			spec["rect"] = _clamped(Rect2(Vector2(float(entry.get("x", 0.4)), float(entry.get("y", 0.6))), box))
			taken.append({"id": spec["id"], "rect": spec["rect"]})
	# 2) new items: racks form a train along the left wall; the rest is scattered (same seed, same result)
	var rack_step: float = EQUIP_SIZE["raf"].y / 2.0
	var per_column := maxi(1, int(floor((length - 4.6 - EQUIP_SIZE["raf"].y) / rack_step)) + 1)
	var changed := false
	for spec in specs:
		if spec.has("rect"):
			continue
		var box: Vector2 = spec["box"]
		var rect := Rect2()
		var found := false
		if str(spec["id"]) == "raf":
			var column := int(spec["index"]) / per_column
			var row := int(spec["index"]) % per_column
			rect = Rect2(Vector2(0.4 + float(column) * (box.x + 0.4), 0.6 + float(row) * rack_step), box)
			found = interior.encloses(rect) and not _is_taken(rect, taken, true)
		if not found:
			var rng := RandomNumberGenerator.new()
			rng.seed = hash(game.factory_id + str(spec["key"]))
			rect = _auto_spot(box, taken, rng, str(spec["id"]) == "raf")
		spec["rot"] = 0
		spec["rect"] = rect
		taken.append({"id": spec["id"], "rect": rect})
		saved[spec["key"]] = {"x": rect.position.x, "y": rect.position.y, "rot": 0, "auto": true}
		changed = true
	if changed:
		game.layout[game.factory_id] = saved
	for spec in specs:
		var extra := {"index": spec["index"], "rot": spec["rot"]}
		if spec.has("machine"):
			extra["machine"] = spec["machine"]
		_add(spec["kind"], spec["id"], spec["rect"], spec["label"], extra)
	if counts.get("vinc", 0) > 0:
		_add("crane", 0, Rect2(0.0, length * 0.45, width, 0.6), "Köprü vinç")

func factory_id_key() -> String:
	return game.factory_id

func _is_taken(rect: Rect2, taken: Array, is_rack: bool) -> bool:
	for other in taken:
		if is_rack and str(other["id"]) == "raf":
			continue
		if rect.intersects(other["rect"]):
			return true
	return false

# A free spot for a box: random tries first, then a grid scan, then the plant's last gap.
func _auto_spot(box: Vector2, taken: Array, rng: RandomNumberGenerator, is_rack: bool) -> Rect2:
	var width := interior.size.x
	var length := interior.size.y
	var max_x := maxf(0.4, width - 0.4 - box.x)
	var max_y := maxf(0.6, length - DOCK_APRON - box.y)
	for attempt in 160:
		var pos := Vector2(snappedf(rng.randf_range(0.4, max_x), SNAP_M), snappedf(rng.randf_range(0.6, max_y), SNAP_M))
		var rect := Rect2(pos, box)
		if interior.encloses(rect) and not _is_taken(rect.grow(0.3), taken, is_rack):
			return rect
	for pad in [0.3, 0.0]:
		var limit_y: float = length - DOCK_APRON if pad > 0.0 else length - 0.2
		var y := 0.4
		while y + box.y <= limit_y:
			var x := 0.4
			while x + box.x <= width - 0.2:
				var scan := Rect2(Vector2(x, y), box)
				if not _is_taken(scan.grow(pad), taken, is_rack):
					return scan
				x += 1.0
			y += 1.0
	return _clamped(Rect2(Vector2(0.4, 0.6), box))

# Player-moved / rotated items (saved per factory in game.layout).
func _editable(item: Dictionary) -> bool:
	return item["kind"] == "equip" or item["kind"] == "machine"

func _overlaps(rect: Rect2, ignore: int) -> bool:
	var ignore_id: String = str(items[ignore]["id"]) if ignore >= 0 and ignore < items.size() else ""
	for i in items.size():
		if i == ignore or not _editable(items[i]):
			continue
		if ignore_id == "raf" and str(items[i]["id"]) == "raf":
			continue   # racks may overlap each other, like cars of a train
		if rect.intersects(items[i]["rect"]):
			return true
	return false

func _snapped_position(point: Vector2) -> Vector2:
	return (point / SNAP_M).round() * SNAP_M

# Nearest overlap-free spot for a box, searched on the snap grid around `around` (null when the plant is full).
func _free_spot(box: Vector2, around: Vector2, ignore: int):
	var best = null
	var best_distance := INF
	var steps := int(6.0 / SNAP_M)
	for dy in range(-steps, steps + 1):
		for dx in range(-steps, steps + 1):
			var candidate := _clamped(Rect2(_snapped_position(around + Vector2(dx, dy) * SNAP_M), box))
			if _overlaps(candidate, ignore):
				continue
			var distance := candidate.position.distance_to(around)
			if distance < best_distance:
				best_distance = distance
				best = candidate
	return best

func _clamped(rect: Rect2) -> Rect2:
	rect.position.x = clampf(rect.position.x, 0.0, maxf(0.0, interior.size.x - rect.size.x))
	rect.position.y = clampf(rect.position.y, 0.0, maxf(0.0, interior.size.y - rect.size.y))
	return rect

func _store_override(index: int) -> void:
	var item: Dictionary = items[index]
	var saved: Dictionary = game.layout.get(game.factory_id, {})
	var rect: Rect2 = item["rect"]
	saved[item["key"]] = {"x": rect.position.x, "y": rect.position.y, "rot": int(item["rot"])}
	game.layout[game.factory_id] = saved
	layout_changed.emit()

func _rotate_selected() -> void:
	if selected < 0 or not _editable(items[selected]):
		return
	var item: Dictionary = items[selected]
	var rect: Rect2 = item["rect"]
	var center := rect.get_center()
	var box := Vector2(rect.size.y, rect.size.x)
	var turned := _clamped(Rect2(_snapped_position(center - box / 2.0), box))
	if _overlaps(turned, selected):
		var spot = _free_spot(box, turned.position, selected)
		if spot == null:
			info_label.text = "Burada döndürmeye yer yok; önce komşu öğeyi kaydır."
			return
		turned = spot
	item["rect"] = turned
	item["rot"] = (int(item["rot"]) + 1) % 4
	_store_override(selected)
	queue_redraw()

func _reset_layout() -> void:
	game.layout.erase(game.factory_id)
	selected = -1
	_layout()
	_show_info()
	layout_changed.emit()
	queue_redraw()

func _on_edit_toggled(on: bool) -> void:
	edit_mode = on
	reset_button.visible = on
	_show_info()
	queue_redraw()

# 2 x 2 mirrored composite of the floor photo: tiling it has no visible seams.
func _mirrored_floor(source: Texture2D) -> Texture2D:
	if source == null:
		return null
	var image := source.get_image()
	if image == null or image.is_empty():
		return source
	if image.is_compressed():
		image.decompress()
	image.convert(Image.FORMAT_RGB8)
	var w := image.get_width()
	var h := image.get_height()
	var flipped_x := image.duplicate() as Image
	flipped_x.flip_x()
	var flipped_y := image.duplicate() as Image
	flipped_y.flip_y()
	var flipped_xy := flipped_x.duplicate() as Image
	flipped_xy.flip_y()
	var composite := Image.create(w * 2, h * 2, false, Image.FORMAT_RGB8)
	composite.blit_rect(image, Rect2i(0, 0, w, h), Vector2i(0, 0))
	composite.blit_rect(flipped_x, Rect2i(0, 0, w, h), Vector2i(w, 0))
	composite.blit_rect(flipped_y, Rect2i(0, 0, w, h), Vector2i(0, h))
	composite.blit_rect(flipped_xy, Rect2i(0, 0, w, h), Vector2i(w, h))
	return ImageTexture.create_from_image(composite)

# ------------------------------------------------------------------ view

func _to_screen(point: Vector2) -> Vector2:
	return pan + point * zoom

func _to_world(point: Vector2) -> Vector2:
	return (point - pan) / zoom

func fit() -> void:
	if size.x <= 0.0 or interior.size.x <= 0.0:
		return
	var margin := 24.0
	zoom = clampf(minf((size.x - margin) / (interior.size.x + 2.0 * WALL_T), (size.y - 120.0) / (interior.size.y + 2.0 * WALL_T)), 2.0, 40.0)
	pan = Vector2((size.x - interior.size.x * zoom) / 2.0, 54.0)
	queue_redraw()

func _zoom_by(factor: float, around: Vector2) -> void:
	user_adjusted = true
	var before := _to_world(around)
	zoom = clampf(zoom * factor, 2.0, 60.0)
	pan = around - before * zoom
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_by(1.12, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_by(1.0 / 1.12, event.position)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pressing = true
				moved = false
				press_pos = event.position
				drag_item = false
				if edit_mode:
					var hit := _item_at(_to_world(event.position))
					if hit >= 0 and _editable(items[hit]):
						selected = hit
						drag_item = true
						drag_raw = (items[hit]["rect"] as Rect2).position
						_show_info()
						queue_redraw()
			else:
				pressing = false
				if drag_item:
					drag_item = false
					if moved:
						_store_override(selected)
				elif not moved:
					_pick(event.position)
	elif event is InputEventMouseMotion and pressing:
		if event.position.distance_to(press_pos) > 10.0:
			moved = true
		if moved and drag_item and selected >= 0:
			var item: Dictionary = items[selected]
			var current: Rect2 = item["rect"]
			drag_raw += event.relative / zoom
			var wanted := _clamped(Rect2(_snapped_position(drag_raw), current.size))
			for candidate in [wanted, Rect2(Vector2(wanted.position.x, current.position.y), current.size), Rect2(Vector2(current.position.x, wanted.position.y), current.size)]:
				if not _overlaps(candidate, selected):
					item["rect"] = candidate
					break
			queue_redraw()
		elif moved:
			user_adjusted = true
			pan += event.relative
			queue_redraw()
	elif event is InputEventMagnifyGesture:
		_zoom_by(event.factor, event.position)
	elif event is InputEventPanGesture:
		pan -= event.delta * 8.0
		queue_redraw()

func _item_at(world: Vector2) -> int:
	for i in range(items.size() - 1, -1, -1):
		if items[i]["kind"] == "crane":
			continue
		if (items[i]["rect"] as Rect2).grow(0.4).has_point(world):
			return i
	return -1

func _pick(screen_point: Vector2) -> void:
	selected = _item_at(_to_world(screen_point))
	_show_info()
	queue_redraw()

func _item_text(item: Dictionary) -> String:
	match item["kind"]:
		"machine":
			var machine: Dictionary = item["machine"]
			var status := "Boşta"
			if int(machine["arrive"]) > game.month:
				status = "Yolda · %d ay sonra teslim" % (int(machine["arrive"]) - game.month)
			elif float(machine.get("used_last", 0.0)) > 0.0:
				status = "Üretimde"
			var extra := ""
			if int(machine["arrive"]) <= game.month:
				extra = " · %d vardiya%s · %s/ay" % [machine["shifts"], " (patron)" if machine.get("patron", false) else "", Data.x_text(game.machine_output(machine, game.problem_mults(game.loss_fractions())))]
			return "%s · %s %s\\n%s%s" % [machine["model"], Data.LEVELS[int(machine["level"])], machine["kind"], status, extra]
		"equip":
			var note: String = Data.EQUIPMENT[item["id"]]["note"]
			return "%s\\n%s" % [item["label"], note]
		"door":
			return "%s\\nTır ve forklift girişi" % item["label"]
	return item["label"]

func _show_info() -> void:
	if selected < 0:
		info_panel.visible = false
		return
	var item: Dictionary = items[selected]
	info_label.text = _item_text(item).replace("\\n", "\n")
	info_kind = "machines" if item["kind"] == "machine" else ""
	info_button.visible = info_kind != "" and not edit_mode
	rotate_button.visible = edit_mode and _editable(item)
	info_panel.visible = true

func _build_controls() -> void:
	for child in get_children():
		child.queue_free()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	box.position = Vector2(-60, 8)
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	for spec in [["+", 1.3], ["−", 1.0 / 1.3], ["⤢", 0.0]]:
		var button := Button.new()
		button.text = spec[0]
		button.custom_minimum_size = Vector2(48, 48)
		button.add_theme_font_size_override("font_size", 20)
		button.pressed.connect(_on_zoom_button.bind(float(spec[1])))
		box.add_child(button)
	edit_button = Button.new()
	edit_button.text = "✎"
	edit_button.toggle_mode = true
	edit_button.button_pressed = edit_mode
	edit_button.custom_minimum_size = Vector2(48, 48)
	edit_button.add_theme_font_size_override("font_size", 20)
	edit_button.toggled.connect(_on_edit_toggled)
	box.add_child(edit_button)
	reset_button = Button.new()
	reset_button.text = "↺"
	reset_button.visible = edit_mode
	reset_button.custom_minimum_size = Vector2(48, 48)
	reset_button.add_theme_font_size_override("font_size", 20)
	reset_button.pressed.connect(_reset_layout)
	box.add_child(reset_button)
	info_panel = PanelContainer.new()
	info_panel.visible = false
	info_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	info_panel.offset_top = -120
	info_panel.offset_left = 12
	info_panel.offset_right = -12
	info_panel.offset_bottom = -10
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.14, 0.18, 0.95)
	style.border_color = Color("#34424f")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	info_panel.add_theme_stylebox_override("panel", style)
	add_child(info_panel)
	var row := HBoxContainer.new()
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	info_panel.add_child(margin)
	margin.add_child(row)
	info_label = Label.new()
	info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.add_theme_font_size_override("font_size", 14)
	row.add_child(info_label)
	rotate_button = Button.new()
	rotate_button.text = "⟳ Döndür"
	rotate_button.visible = false
	rotate_button.custom_minimum_size = Vector2(110, 44)
	rotate_button.pressed.connect(_rotate_selected)
	row.add_child(rotate_button)
	info_button = Button.new()
	info_button.text = "Detay ›"
	info_button.custom_minimum_size = Vector2(96, 44)
	info_button.pressed.connect(func() -> void: detail_requested.emit(info_kind))
	row.add_child(info_button)

func _on_zoom_button(factor: float) -> void:
	if factor == 0.0:
		user_adjusted = false
		fit()
	else:
		_zoom_by(factor, size / 2.0)

# ------------------------------------------------------------------ drawing

func _sprite_for(item: Dictionary) -> Texture2D:
	var key := ""
	match item["kind"]:
		"machine":
			var machine: Dictionary = item["machine"]
			key = "res://art/floor/machines/%s_%d" % [Art.slug(machine["kind"]), machine["level"]]
		"equip":
			key = "res://art/floor/equipment/" + String(item["id"])
		_:
			return null
	if not sprite_cache.has(key):
		sprite_cache[key] = Art.find(key)
	return sprite_cache[key]

func _screen_rect(rect: Rect2) -> Rect2:
	return Rect2(_to_screen(rect.position), rect.size * zoom)

func _draw_sprite_fit(texture: Texture2D, rect: Rect2, modulate_color := Color.WHITE) -> void:
	var texture_size := texture.get_size()
	var factor := minf(rect.size.x / texture_size.x, rect.size.y / texture_size.y)
	var fitted := texture_size * factor
	draw_texture_rect(texture, Rect2(rect.position + (rect.size - fitted) / 2.0, fitted), false, modulate_color)

# Draws the sprite fitted to rect, turned by rot quarter turns (rect is the already-rotated box).
func _draw_rotated(texture: Texture2D, rect: Rect2, rot: int, modulate_color := Color.WHITE) -> void:
	if rot % 4 == 0:
		_draw_sprite_fit(texture, rect, modulate_color)
		return
	var unrotated := Vector2(rect.size.y, rect.size.x) if rot % 2 == 1 else rect.size
	draw_set_transform(rect.get_center(), float(rot % 4) * PI / 2.0, Vector2.ONE)
	_draw_sprite_fit(texture, Rect2(-unrotated / 2.0, unrotated), modulate_color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# Fills the rect without distortion by cropping the texture centre.
func _draw_sprite_cover(texture: Texture2D, rect: Rect2) -> void:
	var texture_size := texture.get_size()
	var factor := maxf(rect.size.x / texture_size.x, rect.size.y / texture_size.y)
	var source_size := rect.size / factor
	var source := Rect2((texture_size - source_size) / 2.0, source_size)
	draw_texture_rect_region(texture, rect, source)

func _draw() -> void:
	if game == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), BG_OUT)
	# floor
	var floor_rect := _screen_rect(interior)
	if floor_tex != null:
		var texture_size := floor_tex.get_size()
		var period := TILE_M * 2.0   # composite = texture + its mirror images
		var tiles_x := int(ceil(interior.size.x / period))
		var tiles_y := int(ceil(interior.size.y / period))
		for ty in tiles_y:
			for tx in tiles_x:
				var width_m := minf(period, interior.size.x - float(tx) * period)
				var height_m := minf(period, interior.size.y - float(ty) * period)
				var dest := Rect2(_to_screen(Vector2(float(tx) * period, float(ty) * period)), Vector2(width_m, height_m) * zoom)
				if dest.end.x < 0.0 or dest.end.y < 0.0 or dest.position.x > size.x or dest.position.y > size.y:
					continue
				var src := Rect2(Vector2.ZERO, Vector2(width_m / period * texture_size.x, height_m / period * texture_size.y))
				draw_texture_rect_region(floor_tex, dest, src)
	else:
		draw_rect(floor_rect, FLOOR_FALLBACK)
		var step := 5.0
		var gx := step
		while gx < interior.size.x:
			draw_line(_to_screen(Vector2(gx, 0)), _to_screen(Vector2(gx, interior.size.y)), Color(1, 1, 1, 0.05), 1.0)
			gx += step
		var gy := step
		while gy < interior.size.y:
			draw_line(_to_screen(Vector2(0, gy)), _to_screen(Vector2(interior.size.x, gy)), Color(1, 1, 1, 0.05), 1.0)
			gy += step
	# columns every 10 m
	var cx := 10.0
	while cx < interior.size.x - 1.0:
		var cy := 10.0
		while cy < interior.size.y - 1.0:
			draw_rect(_screen_rect(Rect2(cx - 0.3, cy - 0.3, 0.6, 0.6)), Color("#1d232a"))
			cy += 10.0
		cx += 10.0
	# walls
	var outer := Rect2(-WALL_T, -WALL_T, interior.size.x + 2.0 * WALL_T, interior.size.y + 2.0 * WALL_T)
	var wall_parts := [
		Rect2(outer.position, Vector2(outer.size.x, WALL_T)),
		Rect2(Vector2(outer.position.x, interior.size.y), Vector2(outer.size.x, WALL_T)),
		Rect2(Vector2(outer.position.x, 0), Vector2(WALL_T, interior.size.y)),
		Rect2(Vector2(interior.size.x, 0), Vector2(WALL_T, interior.size.y))]
	for part in wall_parts:
		var screen := _screen_rect(part)
		if wall_tex != null:
			draw_texture_rect(wall_tex, screen, true)
		else:
			draw_rect(screen, WALL)
	if edit_mode and zoom >= 6.0:
		var gx_m := 1.0
		while gx_m < interior.size.x:
			draw_line(_to_screen(Vector2(gx_m, 0)), _to_screen(Vector2(gx_m, interior.size.y)), Color(0.3, 0.65, 1.0, 0.12), 1.0)
			gx_m += 1.0
		var gy_m := 1.0
		while gy_m < interior.size.y:
			draw_line(_to_screen(Vector2(0, gy_m)), _to_screen(Vector2(interior.size.x, gy_m)), Color(0.3, 0.65, 1.0, 0.12), 1.0)
			gy_m += 1.0
	# items
	for i in items.size():
		_draw_item(i)
	# selection frame
	if selected >= 0:
		draw_rect(_screen_rect(items[selected]["rect"]).grow(3.0), Color("#4aa8ff") if edit_mode else Color("#3ddc84"), false, 3.0)
	if edit_mode:
		var font := ThemeDB.fallback_font
		var hint := "DÜZENLE: öğeyi sürükle · ⟳ ile döndür"
		draw_string_outline(font, Vector2(10, 22), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 5, Color(0.05, 0.07, 0.09, 0.95))
		draw_string(font, Vector2(10, 22), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#4aa8ff"))
	# title
	var factory: Dictionary = game.factory()
	var title := "%s · %d × %d m · %d m²" % [factory["name"], factory["width"], factory["length"], factory["m2"]]
	draw_string(ThemeDB.fallback_font, Vector2(14, 28), title, HORIZONTAL_ALIGNMENT_LEFT, size.x - 80.0, 15, TEXT)
	draw_string(ThemeDB.fallback_font, Vector2(14, 46), "Sürükle: kaydır · +/−: yakınlaştır · dokun: ayrıntı", HORIZONTAL_ALIGNMENT_LEFT, size.x - 80.0, 11, Color(1, 1, 1, 0.5))

func _draw_item(index: int) -> void:
	var item: Dictionary = items[index]
	var rect: Rect2 = _screen_rect(item["rect"])
	var font := ThemeDB.fallback_font
	match item["kind"]:
		"door":
			if door_tex != null:
				_draw_sprite_cover(door_tex, rect)
			else:
				draw_rect(rect, SAFETY)
				var stripes := int(rect.size.x / maxf(6.0, zoom * 0.5))
				for s in stripes:
					if s % 2 == 0:
						draw_rect(Rect2(rect.position.x + float(s) * rect.size.x / float(maxi(1, stripes)), rect.position.y, rect.size.x / float(maxi(1, stripes)), rect.size.y), Color("#1a1a1a"))
		"crane":
			draw_rect(rect, Color(SAFETY, 0.55))
			var rail_pos := rect.position + Vector2(8, rect.size.y + 14)
			draw_string_outline(font, rail_pos, "Köprü vinç rayı", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, 4, Color(0.05, 0.07, 0.09, 0.95))
			draw_string(font, rail_pos, "Köprü vinç rayı", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#ffd24a"))
		"equip":
			var texture := _sprite_for(item)
			if texture != null:
				_draw_rotated(texture, rect, int(item["rot"]))
			else:
				var color: Color = EQUIP_COLOR.get(item["id"], Color.GRAY)
				draw_rect(rect, color)
				draw_rect(rect, color.darkened(0.45), false, 1.0)
		"machine":
			var machine: Dictionary = item["machine"]
			var transit: bool = int(machine["arrive"]) > game.month
			var working: bool = float(machine.get("used_last", 0.0)) > 0.0
			var frame := rect
			var fade := 0.4 if transit else 1.0
			# work zone = yellow floor-tape corners only (no filled box)
			var tape := Color(SAFETY, 0.75 * fade)
			var corner := minf(minf(frame.size.x, frame.size.y) * 0.22, zoom * 0.9)
			var tape_w := maxf(1.5, zoom * 0.1)
			for corner_pos in [frame.position, Vector2(frame.end.x, frame.position.y), Vector2(frame.position.x, frame.end.y), frame.end]:
				var dx: float = corner if corner_pos.x == frame.position.x else -corner
				var dy: float = corner if corner_pos.y == frame.position.y else -corner
				draw_line(corner_pos, corner_pos + Vector2(dx, 0), tape, tape_w)
				draw_line(corner_pos, corner_pos + Vector2(0, dy), tape, tape_w)
			var body := frame.grow(-zoom * 0.5)
			var texture := _sprite_for(item)
			var tint := Color(1, 1, 1, 0.45) if transit else Color.WHITE
			var machine_rect := body
			if texture != null:
				# the sprite is drawn at the real machine size inside its work zone
				var length_m: float = MACHINE_LENGTH_M.get(machine["kind"], 3.0)
				var ratio := float(texture.get_width()) / float(texture.get_height())
				var real := (Vector2(length_m, length_m / ratio) if ratio >= 1.0 else Vector2(length_m * ratio, length_m)) * zoom
				if int(item["rot"]) % 2 == 1:
					real = Vector2(real.y, real.x)
				var shrink := minf(1.0, minf(body.size.x / real.x, body.size.y / real.y))
				real *= shrink
				var top_left := Vector2(body.position.x + (body.size.x - real.x) / 2.0, body.position.y + (body.size.y - real.y) * 0.35)
				machine_rect = Rect2(top_left, real)
				_draw_rotated(texture, Rect2(top_left + Vector2(zoom * 0.14, zoom * 0.2), real), int(item["rot"]), Color(0, 0, 0, 0.3 * fade))
				_draw_rotated(texture, machine_rect, int(item["rot"]), tint)
				draw_rect(machine_rect.grow(zoom * 0.25), Color(SAFETY, 0.55 * fade), false, maxf(1.0, zoom * 0.07))
			else:
				var base: Color = KIND_COLOR.get(machine["kind"], Color.GRAY).lightened(0.08 * float(int(machine["level"]) - 1))
				base.a = 0.45 if transit else 1.0
				draw_rect(body, base)
				draw_rect(body, base.darkened(0.5), false, 2.0)
				draw_rect(Rect2(body.position + body.size * Vector2(0.12, 0.12), body.size * Vector2(0.76, 0.28)), base.darkened(0.25))
			var dot := Color("#3ddc84") if working else (Color("#eac47a") if transit else Color("#93a3b3"))
			draw_circle(Vector2(machine_rect.end.x, machine_rect.position.y) + Vector2(zoom * 0.25, -zoom * 0.25), maxf(3.5, zoom * 0.28), dot)
			if zoom >= 7.0:
				var label := "%s%s" % [String(machine["model"]).get_slice(" ", String(machine["model"]).count(" ")), "  ×%d" % machine["shifts"] if not transit else "  (yolda)"]
				var label_size := clampi(int(zoom * 0.8), 9, 16)
				var label_pos := Vector2(frame.position.x, minf(machine_rect.end.y + zoom * 0.25 + float(label_size) + 3.0, frame.end.y - 3.0))
				draw_string_outline(font, label_pos, label, HORIZONTAL_ALIGNMENT_CENTER, frame.size.x, label_size, 5, Color(0.05, 0.07, 0.09, 0.95))
				draw_string(font, label_pos, label, HORIZONTAL_ALIGNMENT_CENTER, frame.size.x, label_size, TEXT)
