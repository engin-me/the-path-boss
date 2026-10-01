extends Control

# Top-down view of the rented factory: tiled floor, walls, loading ramps, racks and crates,
# pallet trucks, benches, and every machine (ordered ones as ghosts). Placement is automatic and
# cosmetic (IDEA-013: no layout bonus). Missing art falls back to coloured shapes.
# Art lookup (res://art/floor/...): floor.jpg, props/wall, props/door, machines/<tür>_<seviye>,
# equipment/<id>. See godot/art/PROMPTS.md.

signal detail_requested(kind: String)

const Data = preload("res://scripts/shell/shell_data.gd")
const Art = preload("res://scripts/shell/art.gd")

const BG_OUT := Color("#0b1118")
const WALL := Color("#2a3038")
const FLOOR_FALLBACK := Color("#46505b")
const SAFETY := Color("#e0a800")
const TEXT := Color("#e8eef4")
const WALL_T := 0.8   # wall thickness (m)
const TILE_M := 2.0   # one floor texture covers 2 x 2 m (alternate tiles are mirrored to hide seams)

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

func setup(game_ref, saved_zoom := 0.0, saved_pan := Vector2.ZERO) -> void:
	game = game_ref
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	floor_tex = Art.find("res://art/floor/floor")
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
	var item := {"kind": kind, "id": id, "rect": rect, "label": label}
	item.merge(extra)
	items.append(item)

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
	# racks and crates along the back wall
	var y_cursor := 0.6
	var racks: int = counts.get("raf", 0)
	var x := 0.8
	var row_bottom := y_cursor
	for k in racks:
		if x + 1.2 > width - 0.8:
			x = 0.8
			y_cursor = row_bottom + 0.6
		_add("equip", "raf", Rect2(x, y_cursor, 1.2, 2.5), "Depo rafı", {"index": k})
		row_bottom = maxf(row_bottom, y_cursor + 2.5)
		x += 1.5
	y_cursor = row_bottom + 0.5
	var crates: int = counts.get("kasa", 0)
	x = 0.8
	var crate_bottom := y_cursor
	for k in crates:
		if x + 0.55 > width - 0.8:
			x = 0.8
			y_cursor += 0.7
		_add("equip", "kasa", Rect2(x, y_cursor, 0.55, 0.55), "Malzeme kasası", {"index": k})
		crate_bottom = maxf(crate_bottom, y_cursor + 0.55)
		x += 0.7
	var machine_top := crate_bottom + 1.2
	# benches along the left wall, cabinets and measuring rooms along the right wall
	var left_y := machine_top
	for k in counts.get("el_aleti", 0):
		_add("equip", "el_aleti", Rect2(0.4, left_y, 0.8, 1.6), "El aletleri tezgahı", {"index": k})
		left_y += 1.9
	var right_y := machine_top
	for k in counts.get("takim", 0):
		_add("equip", "takim", Rect2(width - 1.6, right_y, 1.2, 0.6), "Takım dolabı", {"index": k})
		right_y += 1.0
	for k in counts.get("olcum", 0):
		_add("equip", "olcum", Rect2(width - 2.0, right_y, 1.6, 1.6), "Kalite ölçüm odası", {"index": k})
		right_y += 2.0
	# pallet trucks and forklifts near the first ramp
	var dock_y := length - 3.2
	for k in counts.get("transpalet", 0):
		_add("equip", "transpalet", Rect2(1.2 + 1.0 * float(k % 8), dock_y - 1.8 * float(k / 8), 0.8, 1.6), "Transpalet", {"index": k})
	for k in counts.get("forklift", 0):
		_add("equip", "forklift", Rect2(width / 2.0 + 1.5 * float(k), dock_y - 1.0, 1.3, 2.6), "Forklift", {"index": k})
	# machines in rows between the side equipment and the dock
	var x0 := 2.4
	var x1 := width - 2.4
	var y0 := machine_top
	var y1 := length - 6.0
	var machine_list: Array = game.machines
	var scale := 1.0
	var placed: Array = []
	for attempt in 8:
		placed = _place_machines(machine_list, x0, x1, y0, y1, scale)
		if not placed.is_empty() and placed[placed.size() - 1].get("fits", true):
			break
		scale *= 0.85
	for entry in placed:
		_add("machine", entry["uid"], entry["rect"], entry["label"], {"machine": entry["machine"]})
	if counts.get("vinc", 0) > 0:
		_add("crane", 0, Rect2(0.0, length * 0.45, width, 0.6), "Köprü vinç")

# Width/depth of the machine sprite (1.0 when there is no art); the footprint keeps its area.
func _machine_aspect(machine: Dictionary) -> float:
	var texture := _sprite_for({"kind": "machine", "machine": machine})
	if texture == null:
		return 1.0
	return clampf(float(texture.get_width()) / float(texture.get_height()), 0.6, 1.8)

func _place_machines(list: Array, x0: float, x1: float, y0: float, y1: float, scale: float) -> Array:
	var out: Array = []
	var cursor := Vector2(x0, y0)
	var row_h := 0.0
	var fits := true
	for machine in list:
		var side := sqrt(float(machine["area"])) * scale
		var aspect := _machine_aspect(machine)
		var box := Vector2(side * sqrt(aspect), side / sqrt(aspect))
		if cursor.x + box.x > x1 and cursor.x > x0:
			cursor.x = x0
			cursor.y += row_h + 1.0
			row_h = 0.0
		var rect := Rect2(cursor, box)
		if rect.end.y > y1:
			fits = false
		out.append({"uid": machine["uid"], "rect": rect, "label": machine["model"], "machine": machine, "fits": true})
		cursor.x += box.x + 1.0
		row_h = maxf(row_h, box.y)
	if not out.is_empty():
		out[out.size() - 1]["fits"] = fits
	return out

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
			else:
				pressing = false
				if not moved:
					_pick(event.position)
	elif event is InputEventMouseMotion and pressing:
		if event.position.distance_to(press_pos) > 10.0:
			moved = true
		if moved:
			user_adjusted = true
			pan += event.relative
			queue_redraw()
	elif event is InputEventMagnifyGesture:
		_zoom_by(event.factor, event.position)
	elif event is InputEventPanGesture:
		pan -= event.delta * 8.0
		queue_redraw()

func _pick(screen_point: Vector2) -> void:
	var world := _to_world(screen_point)
	selected = -1
	for i in range(items.size() - 1, -1, -1):
		var rect: Rect2 = items[i]["rect"]
		if items[i]["kind"] == "crane":
			continue
		if rect.grow(0.4).has_point(world):
			selected = i
			break
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
	info_button.visible = info_kind != ""
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

func _draw() -> void:
	if game == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), BG_OUT)
	# floor
	var floor_rect := _screen_rect(interior)
	if floor_tex != null:
		var tiles_x := int(ceil(interior.size.x / TILE_M))
		var tiles_y := int(ceil(interior.size.y / TILE_M))
		var texture_size := floor_tex.get_size()
		for ty in tiles_y:
			for tx in tiles_x:
				var width_m := minf(TILE_M, interior.size.x - float(tx) * TILE_M)
				var height_m := minf(TILE_M, interior.size.y - float(ty) * TILE_M)
				var dest := Rect2(_to_screen(Vector2(float(tx) * TILE_M, float(ty) * TILE_M)), Vector2(width_m, height_m) * zoom)
				if dest.end.x < 0.0 or dest.end.y < 0.0 or dest.position.x > size.x or dest.position.y > size.y:
					continue
				var frac_x := width_m / TILE_M
				var frac_y := height_m / TILE_M
				var src := Rect2(Vector2.ZERO, Vector2(frac_x * texture_size.x, frac_y * texture_size.y))
				if tx % 2 == 1:
					src.position.x = texture_size.x - src.size.x
					dest = Rect2(Vector2(dest.end.x, dest.position.y), Vector2(-dest.size.x, dest.size.y))
				if ty % 2 == 1:
					src.position.y = texture_size.y - src.size.y
					dest = Rect2(Vector2(dest.position.x, dest.end.y), Vector2(dest.size.x, -dest.size.y))
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
	# items
	for i in items.size():
		_draw_item(i)
	# selection frame
	if selected >= 0:
		draw_rect(_screen_rect(items[selected]["rect"]).grow(3.0), Color("#3ddc84"), false, 3.0)
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
				draw_texture_rect(door_tex, rect, false)
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
				_draw_sprite_fit(texture, rect)
			else:
				var color: Color = EQUIP_COLOR.get(item["id"], Color.GRAY)
				draw_rect(rect, color)
				draw_rect(rect, color.darkened(0.45), false, 1.0)
		"machine":
			var machine: Dictionary = item["machine"]
			var transit: bool = int(machine["arrive"]) > game.month
			var working: bool = float(machine.get("used_last", 0.0)) > 0.0
			var frame := rect
			draw_rect(frame, Color(SAFETY, 0.14 if not transit else 0.05))
			draw_rect(frame, Color(0.1, 0.1, 0.1, 0.55 if not transit else 0.25), false, maxf(2.5, zoom * 0.16))
			draw_rect(frame.grow(-maxf(1.0, zoom * 0.04)), Color(SAFETY, 1.0 if not transit else 0.45), false, maxf(1.5, zoom * 0.12))
			var body := frame.grow(-minf(frame.size.x, frame.size.y) * 0.07)
			var texture := _sprite_for(item)
			var tint := Color(1, 1, 1, 0.45) if transit else Color.WHITE
			if texture != null:
				_draw_sprite_fit(texture, body, tint)
			else:
				var base: Color = KIND_COLOR.get(machine["kind"], Color.GRAY).lightened(0.08 * float(int(machine["level"]) - 1))
				base.a = 0.45 if transit else 1.0
				draw_rect(body, base)
				draw_rect(body, base.darkened(0.5), false, 2.0)
				draw_rect(Rect2(body.position + body.size * Vector2(0.12, 0.12), body.size * Vector2(0.76, 0.28)), base.darkened(0.25))
			var dot := Color("#3ddc84") if working else (Color("#eac47a") if transit else Color("#93a3b3"))
			draw_circle(frame.position + Vector2(frame.size.x - 8.0, 8.0), maxf(4.0, zoom * 0.3), dot)
			if zoom >= 7.0:
				var label := "%s%s" % [String(machine["model"]).get_slice(" ", String(machine["model"]).count(" ")), "  ×%d" % machine["shifts"] if not transit else "  (yolda)"]
				var label_pos := frame.position + Vector2(4, frame.size.y - 5)
				var label_size := clampi(int(zoom * 0.8), 9, 16)
				draw_string_outline(font, label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, frame.size.x - 6.0, label_size, 5, Color(0.05, 0.07, 0.09, 0.95))
				draw_string(font, label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, frame.size.x - 6.0, label_size, TEXT)
