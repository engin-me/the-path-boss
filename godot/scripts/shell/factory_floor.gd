extends Control
# Technical layout drawing of the rented plant (blueprint style): metre grid, walls, ramps, one dashed slot per
# machine, a symbol per machine kind, the equipment symbols and, while the clock runs, the daily output of every
# working machine. The view opens fitted to the screen; the player zooms in.

signal detail_requested(kind: String)
signal machine_requested(uid: int)   # the arrow beside a machine was tapped
signal layout_changed   # kept for the shell's wiring; the plan is fixed, nothing is rearranged any more

const Data = preload("res://scripts/shell/shell_data.gd")
const Art = preload("res://scripts/shell/art.gd")

const BG_OUT := Color("#07131f")
const BG := Color("#0a1c2c")
const GRID := Color(0.133, 0.275, 0.4, 0.55)
const GRID5 := Color(0.2, 0.43, 0.6, 0.7)
const WALL := Color("#d6e8f4")
const CYAN := Color("#6ec8eb")
const SLOT := Color("#ffbf00")
const TEXT := Color("#e2eef6")
const SELECT := Color("#2fd17b")
const KIND_COLOR := {"Torna": Color("#6ec8eb"), "Freze": Color("#6ee1be"), "Taşlama": Color("#be9ff0"), "Dövme": Color("#f0a064")}
const EQUIP_COLOR := Color("#8fb3c8")
const AMBER := Color("#e7b75c")
const GREEN_OK := Color("#2fd17b")
const RED_BAD := Color("#e86f6f")
const GRAY := Color("#98a7b6")
const HATCH := Color("#3a4961")
const EQUIP_SIZE := {"raf": Vector2(1.2, 3.0), "kasa": Vector2(0.8, 0.8), "transpalet": Vector2(0.7, 1.6), "el_aleti": Vector2(1.8, 0.8),
	"takim": Vector2(1.6, 0.6), "forklift": Vector2(1.2, 2.4), "olcum": Vector2(2.4, 2.4)}
const PLACE_ORDER := ["olcum", "raf", "el_aleti", "takim", "forklift", "transpalet", "kasa"]
const FRAME := 22.0   # the plan pictures have a 22 px frame around the building
const SLOT_INSET := 0.12
const MAX_ZOOM_FACTOR := 12.0   # relative to the fitted view
const MONTH_DAYS := 30.0

var game
var plan_size := Vector2(1000, 1000)
var slots: Array = []   # Rect2 per slot, plan pixels
var doors: Array = []
var equipment: Array = []   # {id, rect (plan pixels)}
var ppm := 50.0   # plan pixels per metre
var meters := Vector2(20, 30)   # building size in metres as drawn (horizontal, vertical)
var zoom := 1.0
var pan := Vector2.ZERO
var fit_zoom := 1.0
var selected := -1
var press_pos := Vector2.ZERO
var pressing := false
var moved := false
var user_adjusted := false
var anim_time := 0.0
var busy := {}
var any_busy := false
var day_frac := -1.0   # share of the month elapsed while the clock runs (-1 = clock off)
var plan_output := {}   # expected output per machine this month
var floaters: Array = []   # {from, to (plan px), age, bad, uid, amount}: a part flying to its counter
var shown := {}   # uid -> [good, scrap] counters as drawn (they grow when a part lands)
var part_texture: Texture2D
var info_panel: PanelContainer
var info_label: Label
var info_button: Button
var info_kind := ""

func setup(game_ref, saved_zoom := 0.0, saved_pan := Vector2.ZERO) -> void:
	game = game_ref
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	plan_size = Data.plan_size(game.factory_id)
	slots.clear()
	for entry in Data.plan_slots(game.factory_id):
		slots.append(Rect2(Vector2(float(entry[0]), float(entry[1])) * plan_size, Vector2(float(entry[2]), float(entry[3])) * plan_size))
	doors = Data.plan_doors(game.factory_id)
	var factory: Dictionary = game.factory()
	var long_side := maxf(float(factory["width"]), float(factory["length"]))
	var short_side := minf(float(factory["width"]), float(factory["length"]))
	meters = Vector2(long_side, short_side) if plan_size.x >= plan_size.y else Vector2(short_side, long_side)
	ppm = (plan_size.x - 2.0 * FRAME) / meters.x
	busy = game.busy_machines()
	plan_output = game.month_plan_output()
	part_texture = Art.find("res://art/cnc_grinding_part")
	shown = {}
	for uid in game.month_counts:
		shown[uid] = (game.month_counts[uid] as Array).duplicate()
	for uid in busy:
		any_busy = any_busy or bool(busy[uid])
	_place_equipment()
	_build_controls()
	resized.connect(_on_resized)
	if saved_zoom > 0.0:
		zoom = saved_zoom
		pan = saved_pan
		user_adjusted = true
		call_deferred("_refresh_fit")
	else:
		call_deferred("fit")

func _on_resized() -> void:
	if not user_adjusted:
		fit()
	else:
		_refresh_fit()

func view_state() -> Dictionary:
	return {"zoom": zoom, "pan": pan, "factory": game.factory_id if game != null else ""}

# ------------------------------------------------------------------ equipment placement

func _equipment_counts() -> Dictionary:
	var counts := {}
	if game.package_bought:
		var package: Dictionary = game.package_info()
		for id in package["items"]:
			counts[id] = int(package["items"][id])
	for id in game.equip:
		var kind: String = Data.equipment_kind(id)
		counts[kind] = int(counts.get(kind, 0)) + int(game.equip[id])
	return counts

# Equipment goes to the free floor nearest the walls, away from the slots and the ramp aprons.
func _place_equipment() -> void:
	equipment.clear()
	var counts := _equipment_counts()
	if counts.is_empty():
		return
	var blocked: Array = []
	for slot in slots:
		blocked.append(Rect2((slot.position - Vector2(FRAME, FRAME)) / ppm, slot.size / ppm).grow(1.0))
	for door in doors:
		var a: float = float(door[1])
		var b: float = float(door[2])
		match String(door[0]):
			"top": blocked.append(Rect2(a * plan_size.x / ppm - 1.0, 0.0, (b - a) * plan_size.x / ppm + 2.0, 3.8))
			"bottom": blocked.append(Rect2(a * plan_size.x / ppm - 1.0, meters.y - 3.8, (b - a) * plan_size.x / ppm + 2.0, 3.8))
			"left": blocked.append(Rect2(0.0, a * plan_size.y / ppm - 1.0, 3.8, (b - a) * plan_size.y / ppm + 2.0))
			"right": blocked.append(Rect2(meters.x - 3.8, a * plan_size.y / ppm - 1.0, 3.8, (b - a) * plan_size.y / ppm + 2.0))
	var spots: Array = []
	var x := 1.0
	while x < meters.x - 0.9:
		var y := 1.0
		while y < meters.y - 0.9:
			spots.append(Vector3(x, y, minf(minf(x, y), minf(meters.x - x, meters.y - y))))
			y += 0.5
		x += 0.5
	spots.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.z < b.z or (a.z == b.z and (a.y < b.y or (a.y == b.y and a.x < b.x))))
	var placed: Array = []
	for id in PLACE_ORDER:
		var size_m: Vector2 = EQUIP_SIZE[id]
		for _n in int(counts.get(id, 0)):
			for spot in spots:
				var rect := Rect2(Vector2(spot.x, spot.y) - size_m / 2.0, size_m)
				if rect.position.x < 0.5 or rect.position.y < 0.5 or rect.end.x > meters.x - 0.5 or rect.end.y > meters.y - 0.5:
					continue
				var clash := false
				for other in blocked:
					if rect.intersects(other):
						clash = true
						break
				if clash:
					continue
				for other in placed:
					if rect.grow(0.15).intersects(other):
						clash = true
						break
				if clash:
					continue
				placed.append(rect)
				equipment.append({"id": id, "rect": Rect2(rect.position * ppm + Vector2(FRAME, FRAME), rect.size * ppm)})
				break

# ------------------------------------------------------------------ view

func _refresh_fit() -> void:
	if size.x <= 0.0:
		return
	fit_zoom = minf((size.x - 16.0) / plan_size.x, (size.y - 64.0) / plan_size.y)

func _s(point: Vector2) -> Vector2:
	return pan + point * zoom

func _to_world(point: Vector2) -> Vector2:
	return (point - pan) / zoom

func fit() -> void:
	if size.x <= 0.0:
		return
	_refresh_fit()
	zoom = fit_zoom
	pan = Vector2((size.x - plan_size.x * zoom) / 2.0, 54.0 + (size.y - 64.0 - plan_size.y * zoom) / 2.0)
	queue_redraw()

func _zoom_by(factor: float, around: Vector2) -> void:
	user_adjusted = true
	var before := _to_world(around)
	zoom = clampf(zoom * factor, fit_zoom * 0.9, fit_zoom * MAX_ZOOM_FACTOR)
	pan = around - before * zoom
	queue_redraw()

func _on_zoom_button(factor: float) -> void:
	if factor == 0.0:
		user_adjusted = false
		fit()
	else:
		_zoom_by(factor, size / 2.0)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_by(1.15, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_by(1.0 / 1.15, event.position)
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

# ------------------------------------------------------------------ slots and machines

func machine_in_slot(slot: int) -> Dictionary:
	for machine in game.machines:
		if int(machine.get("slot", -1)) == slot:
			return machine
	return {}

func _slot_at(world: Vector2) -> int:
	for i in slots.size():
		if (slots[i] as Rect2).has_point(world):
			return i
	return -1

func _pick(screen_point: Vector2) -> void:
	var world := _to_world(screen_point)
	var hit := _slot_at(world)
	if hit >= 0 and not machine_in_slot(hit).is_empty() and (_arrow_rect(slots[hit]) as Rect2).has_point(world):
		selected = hit
		queue_redraw()
		machine_requested.emit(int(machine_in_slot(hit)["uid"]))
		return
	selected = hit
	_show_info()
	queue_redraw()

func _slot_text(slot: int) -> String:
	var machine := machine_in_slot(slot)
	if machine.is_empty():
		return "T-%02d · boş tezgah yuvası (%d / %d dolu)\nTezgah ilanlarından satın aldığın tezgah buraya yerleşir." % [slot + 1, game.machines.size(), slots.size()]
	var status := "Boşta · iş bekliyor"
	if int(machine["arrive"]) > game.month:
		status = "Yolda · %d ay sonra teslim" % (int(machine["arrive"]) - game.month)
	elif bool(busy.get(machine["uid"], false)):
		status = "Çalışıyor"
	var extra := ""
	if int(machine["arrive"]) <= game.month:
		extra = " · %d vardiya%s · %s/ay" % [machine["shifts"], " (patron)" if machine.get("patron", false) else "", Data.x_text(game.machine_output(machine, game.problem_mults(game.loss_fractions())))]
	return "T-%02d · %s · %s %s\n%s%s" % [slot + 1, machine["model"], Data.LEVELS[int(machine["level"])], machine["kind"], status, extra]

func _show_info() -> void:
	# The detail opens from the arrow beside a machine; selecting a slot only frames it.
	info_panel.visible = false
	queue_redraw()

func _build_controls() -> void:
	for child in get_children():
		child.queue_free()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	box.position = Vector2(-60, 8)
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	for spec in [["+", 1.5], ["−", 1.0 / 1.5], ["⤢", 0.0]]:
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

# ------------------------------------------------------------------ daily output (clock running)

# One day passed: every machine that produced sends its good parts to the upper box and its scrap to the lower one.
func add_day(produced: Dictionary) -> void:
	if day_frac < 0.0:
		return
	for i in slots.size():
		var machine := machine_in_slot(i)
		if machine.is_empty() or not produced.has(machine["uid"]):
			continue
		var amount := float(produced[machine["uid"]])
		if amount <= 0.0:
			continue
		var slot: Rect2 = slots[i]
		var rate := clampf(game.machine_scrap(machine), 0.0, 0.9)
		var bad := amount * rate / (1.0 - rate)
		floaters.append({"from": slot.get_center(), "to": _box_rect(slot, false).get_center(), "age": 0.0, "bad": false, "uid": machine["uid"], "amount": amount})
		if bad >= 0.5:
			floaters.append({"from": slot.get_center(), "to": _box_rect(slot, true).get_center(), "age": -0.12, "bad": true, "uid": machine["uid"], "amount": bad})
	queue_redraw()

const FLIGHT_SECONDS := 0.55

func _box_rect(slot: Rect2, bad: bool) -> Rect2:
	return Rect2(slot.position + Vector2(slot.size.x * 0.051, slot.size.y * (0.335 if bad else 0.067)), Vector2(slot.size.x * 0.19, slot.size.y * 0.21))

func _arrow_rect(slot: Rect2) -> Rect2:
	return Rect2(slot.position + Vector2(slot.size.x * 0.78, slot.size.y * 0.3), Vector2(slot.size.x * 0.22, slot.size.y * 0.4))

# Machines changed state (arrived, finished a job): recompute who works and what is expected.
func refresh_state() -> void:
	busy = game.busy_machines()
	plan_output = game.month_plan_output()
	queue_redraw()

func _process(delta: float) -> void:
	if game == null or not is_visible_in_tree():
		return
	var animate := any_busy and day_frac >= 0.0
	if animate:
		anim_time += delta
	if floaters.is_empty():
		if animate:
			queue_redraw()
		return
	var alive: Array = []
	for flight in floaters:
		flight["age"] = float(flight["age"]) + delta
		if float(flight["age"]) >= FLIGHT_SECONDS:
			var counts: Array = shown.get(flight["uid"], [0.0, 0.0])
			counts[1 if bool(flight["bad"]) else 0] = float(counts[1 if bool(flight["bad"]) else 0]) + float(flight["amount"])
			shown[flight["uid"]] = counts
		else:
			alive.append(flight)
	floaters = alive
	queue_redraw()

# ------------------------------------------------------------------ drawing helpers (plan pixel space)

func _lw(px: float) -> float:
	return px / zoom

func _line(a: Vector2, b: Vector2, color: Color, px := 1.5) -> void:
	draw_line(a, b, color, _lw(px))

func _frame(rect: Rect2, color: Color, px := 1.5) -> void:
	draw_rect(rect, color, false, _lw(px))

func _dashed(rect: Rect2, color: Color, px: float, dash: float, gap: float) -> void:
	var corners := [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y), rect.position]
	for i in 4:
		var a: Vector2 = corners[i]
		var b: Vector2 = corners[i + 1]
		var length := a.distance_to(b)
		var direction := (b - a) / length
		var t := 0.0
		while t < length:
			draw_line(a + direction * t, a + direction * minf(t + dash, length), color, _lw(px))
			t += dash + gap

func _circle(center: Vector2, radius: float, color: Color, px := 1.5) -> void:
	draw_arc(center, radius, 0.0, TAU, 28, color, _lw(px))

# Screen-space text anchored at a plan point.
func _text(point: Vector2, text: String, font_size: int, color: Color, centered := false, width := -1.0) -> void:
	var font := ThemeDB.fallback_font
	var at := _s(point)
	var align := HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_string_outline(font, at, text, align, width, font_size, 4, Color(0.03, 0.08, 0.13, 0.95))
	draw_string(font, at, text, align, width, font_size, color)
	draw_set_transform(pan, 0.0, Vector2(zoom, zoom))

# ------------------------------------------------------------------ machine symbols (top view)

func _symbol(kind: String, level: int, area: Rect2, color: Color, working: bool) -> void:
	var b := area
	var w := b.size.x
	var h := b.size.y
	var c := b.get_center()
	if working:
		draw_rect(b.grow(-w * 0.04), Color(color.r, color.g, color.b, 0.12))
	match kind:
		"Torna":
			_frame(Rect2(b.position.x, c.y - h * 0.16, w, h * 0.32), color)
			_frame(Rect2(b.position.x, c.y - h * 0.27, w * 0.24, h * 0.54), color)
			_circle(Vector2(b.position.x + w * 0.24, c.y), h * 0.12, color)
			_frame(Rect2(b.end.x - w * 0.14, c.y - h * 0.12, w * 0.14, h * 0.24), color)
			_frame(Rect2(b.position.x + w * 0.5, c.y - h * 0.23, w * 0.16, h * 0.46), color)
			_line(Vector2(b.position.x - w * 0.03, c.y), Vector2(b.end.x + w * 0.03, c.y), color, 1.0)
		"Freze":
			_frame(Rect2(c.x - w * 0.2, b.position.y, w * 0.4, h * 0.28), color)
			_frame(Rect2(c.x - w * 0.36, c.y - h * 0.02, w * 0.72, h * 0.36), color)
			for k in 3:
				var ty := c.y + h * (0.06 + 0.09 * k)
				_line(Vector2(c.x - w * 0.33, ty), Vector2(c.x + w * 0.33, ty), color, 1.0)
			_circle(Vector2(c.x, c.y - h * 0.1), h * 0.07, color)
			_circle(Vector2(c.x - w * 0.42, c.y + h * 0.26), h * 0.05, color)
			_circle(Vector2(c.x + w * 0.42, c.y + h * 0.26), h * 0.05, color)
		"Taşlama":
			_frame(Rect2(b.position.x, c.y + h * 0.04, w, h * 0.26), color)
			_circle(Vector2(c.x, c.y - h * 0.14), h * 0.17, color)
			_circle(Vector2(c.x, c.y - h * 0.14), h * 0.05, color)
			draw_arc(Vector2(c.x, c.y - h * 0.14), h * 0.23, PI * 1.05, PI * 1.95, 18, SLOT, _lw(2.0))
			_frame(Rect2(b.end.x - w * 0.2, b.position.y, w * 0.2, h * 0.18), color)
		"Dövme":
			_frame(Rect2(c.x - w * 0.3, c.y - h * 0.3, w * 0.6, h * 0.6), color, 2.5)
			_frame(Rect2(c.x - w * 0.24, c.y - h * 0.24, w * 0.48, h * 0.48), color)
			_circle(c, h * 0.15, color)
			_frame(Rect2(c.x - w * 0.07, c.y - h * 0.07, w * 0.14, h * 0.14), color)
			_frame(Rect2(b.position.x, c.y - h * 0.14, w * 0.16, h * 0.28), color)
			_line(Vector2(b.position.x + w * 0.03, c.y - h * 0.08), Vector2(b.position.x + w * 0.13, c.y + h * 0.08), color, 1.0)
			_circle(Vector2(b.end.x - w * 0.06, c.y - h * 0.14), h * 0.05, color)
			_circle(Vector2(b.end.x - w * 0.06, c.y + h * 0.14), h * 0.05, color)
	if level >= 2:   # CNC: dashed enclosure and a control panel; Hassas: solid double enclosure
		if level == 2:
			_dashed(b.grow(w * 0.03), color, 1.2, w * 0.05, w * 0.03)
		else:
			_frame(b.grow(w * 0.03), color, 1.2)
			_frame(b.grow(w * 0.055), color, 1.0)
		_frame(Rect2(c.x - w * 0.1, b.end.y + w * 0.065, w * 0.2, h * 0.07), color)

func _equipment_symbol(id: String, rect: Rect2) -> void:
	_hatch(rect, Color(GRAY.r, GRAY.g, GRAY.b, 0.5), maxf(5.0, minf(rect.size.x, rect.size.y) * 0.3), 1.0)
	var color := EQUIP_COLOR
	var c := rect.get_center()
	match id:
		"raf":
			_frame(rect, color)
			for k in 3:
				var ty := rect.position.y + rect.size.y * (0.25 + 0.25 * k)
				_line(Vector2(rect.position.x, ty), Vector2(rect.end.x, ty), color, 1.0)
		"kasa":
			_frame(rect, color)
			_line(rect.position, rect.end, color, 1.0)
		"transpalet":
			_frame(Rect2(rect.position.x, rect.position.y, rect.size.x * 0.34, rect.size.y), color)
			_frame(Rect2(rect.end.x - rect.size.x * 0.34, rect.position.y, rect.size.x * 0.34, rect.size.y), color)
		"el_aleti":
			_frame(rect, color)
			for k in 4:
				var tx := rect.position.x + rect.size.x * (0.15 + 0.23 * k)
				_line(Vector2(tx, rect.position.y), Vector2(tx, rect.position.y + rect.size.y * 0.35), color, 1.0)
		"takim":
			_frame(rect, color)
			_line(Vector2(c.x, rect.position.y), Vector2(c.x, rect.end.y), color, 1.0)
		"forklift":
			_frame(Rect2(rect.position.x, rect.position.y + rect.size.y * 0.3, rect.size.x, rect.size.y * 0.7), SLOT)
			_line(Vector2(rect.position.x + rect.size.x * 0.2, rect.position.y), Vector2(rect.position.x + rect.size.x * 0.2, rect.position.y + rect.size.y * 0.3), SLOT, 1.5)
			_line(Vector2(rect.end.x - rect.size.x * 0.2, rect.position.y), Vector2(rect.end.x - rect.size.x * 0.2, rect.position.y + rect.size.y * 0.3), SLOT, 1.5)
		"olcum":
			_frame(rect, color)
			_frame(rect.grow(-rect.size.x * 0.18), color)
			_circle(c, rect.size.x * 0.1, color)

var kind_pictures := {}

# The flat illustration of a machine kind (art/ui/<kind>_icon_new); null while it is not in the project.
func _kind_picture(kind: String) -> Texture2D:
	if not kind_pictures.has(kind):
		kind_pictures[kind] = Art.find("res://art/ui/" + Art.slug(kind) + "_icon_new")
	return kind_pictures[kind]

# Picture fitted into the middle of the slot, right of the counters and above the name.
func _machine_picture(slot: Rect2, picture: Texture2D, transit: bool) -> void:
	var area := Rect2(slot.position + Vector2(slot.size.x * 0.27, slot.size.y * 0.12), Vector2(slot.size.x * 0.58, slot.size.y * 0.62))
	var texture_size := picture.get_size()
	var scale_to := minf(area.size.x / texture_size.x, area.size.y / texture_size.y)
	var drawn := texture_size * scale_to
	var at := area.position + (area.size - drawn) * 0.5
	draw_texture_rect(picture, Rect2(at, drawn), false, Color(1, 1, 1, 0.45 if transit else 1.0))

# Diagonal hatch inside a rectangle (the plan's fill for machines and equipment).
func _hatch(rect: Rect2, color: Color, spacing: float, px := 1.0) -> void:
	var t := -rect.size.y
	while t < rect.size.x:
		var a := Vector2(rect.position.x + t, rect.end.y)
		var b := Vector2(rect.position.x + t + rect.size.y, rect.position.y)
		if a.x < rect.position.x:
			var shift := rect.position.x - a.x
			a += Vector2(shift, -shift)
		if b.x > rect.end.x:
			var shift2 := b.x - rect.end.x
			b -= Vector2(shift2, -shift2)
		if a.x < b.x:
			_line(a, b, color, px)
		t += spacing

# Status dot, the two piece counters, the gear and the detail arrow of one occupied slot.
func _slot_overlay(slot: Rect2, machine: Dictionary, transit: bool, working: bool) -> void:
	var w := slot.size.x
	var h := slot.size.y
	var dot_color := GREEN_OK if working else (AMBER if transit else GRAY)
	var dot_center := slot.position + Vector2(w * 0.926, h * 0.07)
	draw_circle(dot_center, w * 0.04, dot_color)
	var counts: Array = shown.get(machine["uid"], [0.0, 0.0])
	for bad in [false, true]:
		var box := _box_rect(slot, bad)
		draw_rect(box, Color(HATCH.r, HATCH.g, HATCH.b, 0.35))
		_frame(box, AMBER, 1.2)
		var value := int(roundf(float(counts[1 if bad else 0])))
		var text := ("−%d" if bad else "+%d") % value
		_text(Vector2(box.position.x, box.get_center().y + box.size.y * 0.18), text, clampi(int(box.size.x * zoom * 0.38), 8, 15), RED_BAD if bad else GREEN_OK, true, box.size.x * zoom)
	_gear(slot.position + Vector2(w * 0.11, h * 0.86), w * 0.075, working)
	var arrow_center := slot.position + Vector2(w * 0.915, h * 0.52)
	var arrow := w * 0.035
	_line(arrow_center + Vector2(-arrow * 0.5, -arrow * 1.2), arrow_center + Vector2(arrow * 0.5, 0), TEXT, 2.0)
	_line(arrow_center + Vector2(arrow * 0.5, 0), arrow_center + Vector2(-arrow * 0.5, arrow * 1.2), TEXT, 2.0)

# Cog that turns while the machine works, with a metal glint running along its rim.
func _gear(center: Vector2, radius: float, working: bool) -> void:
	var angle := anim_time * 2.4 if working else 0.0
	var color := GRAY if working else Color(GRAY.r, GRAY.g, GRAY.b, 0.6)
	var points := PackedVector2Array()
	var teeth := 8
	for k in teeth * 4:
		var step := TAU * float(k) / float(teeth * 4) + angle
		var outer: bool = (k % 4) < 2
		var r := radius if outer else radius * 0.78
		points.append(center + Vector2(cos(step), sin(step)) * r)
	points.append(points[0])
	draw_polyline(points, color, _lw(1.6))
	draw_arc(center, radius * 0.32, 0.0, TAU, 16, color, _lw(1.4))
	if working:
		var glint_angle := anim_time * 4.8
		var glint := center + Vector2(cos(glint_angle), sin(glint_angle)) * radius * 0.9
		var pulse := 0.55 + 0.45 * sin(anim_time * 9.0)
		draw_circle(glint, radius * 0.32, Color(1, 1, 1, 0.16 * pulse))
		var ray := radius * (0.34 + 0.2 * pulse)
		_line(glint - Vector2(ray, 0), glint + Vector2(ray, 0), Color(1, 1, 1, 0.9), 1.4)
		_line(glint - Vector2(0, ray), glint + Vector2(0, ray), Color(1, 1, 1, 0.9), 1.4)

# Parts flying from the machine to the good or scrap counter.
func _draw_flights() -> void:
	for flight in floaters:
		var age: float = float(flight["age"])
		if age < 0.0:
			continue
		var t := clampf(age / FLIGHT_SECONDS, 0.0, 1.0)
		var at: Vector2 = (flight["from"] as Vector2).lerp(flight["to"], t * t * (3.0 - 2.0 * t))
		var side: float = (slots[0] as Rect2).size.x * 0.08 if not slots.is_empty() else 12.0
		var tint := RED_BAD if bool(flight["bad"]) else Color.WHITE
		if part_texture != null:
			draw_texture_rect(part_texture, Rect2(at - Vector2(side, side) * 0.5, Vector2(side, side)), false, tint)
		else:
			draw_rect(Rect2(at - Vector2(side, side) * 0.4, Vector2(side, side) * 0.8), GRAY if not bool(flight["bad"]) else RED_BAD)

func _draw() -> void:
	if game == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), BG_OUT)
	draw_set_transform(pan, 0.0, Vector2(zoom, zoom))
	var building := Rect2(Vector2(FRAME, FRAME), plan_size - Vector2(FRAME, FRAME) * 2.0)
	draw_rect(Rect2(Vector2.ZERO, plan_size), BG)
	# metre grid (minor lines only when they are far enough apart on screen)
	var minor: bool = ppm * zoom >= 7.0
	var gx := 0
	while float(gx) <= meters.x + 0.001:
		var five: bool = gx % 5 == 0
		if five or minor:
			var px := building.position.x + float(gx) * ppm
			_line(Vector2(px, building.position.y), Vector2(px, building.end.y), GRID5 if five else GRID, 1.0)
		gx += 1
	var gy := 0
	while float(gy) <= meters.y + 0.001:
		var five_y: bool = gy % 5 == 0
		if five_y or minor:
			var py := building.position.y + float(gy) * ppm
			_line(Vector2(building.position.x, py), Vector2(building.end.x, py), GRID5 if five_y else GRID, 1.0)
		gy += 1
	# walls and ramps
	_frame(building, WALL, 3.5)
	_frame(building.grow(-8.0), WALL, 1.2)
	for door in doors:
		var a: float = float(door[1])
		var b: float = float(door[2])
		var horizontal: bool = door[0] == "top" or door[0] == "bottom"
		var span_a: float = a * (plan_size.x if horizontal else plan_size.y)
		var span_b: float = b * (plan_size.x if horizontal else plan_size.y)
		var rect: Rect2
		match String(door[0]):
			"top": rect = Rect2(span_a, building.position.y - 9.0, span_b - span_a, 18.0)
			"bottom": rect = Rect2(span_a, building.end.y - 9.0, span_b - span_a, 18.0)
			"left": rect = Rect2(building.position.x - 9.0, span_a, 18.0, span_b - span_a)
			_: rect = Rect2(building.end.x - 9.0, span_a, 18.0, span_b - span_a)
		draw_rect(rect, BG)
		_frame(rect, SLOT, 2.0)
		var steps := int((rect.size.x if horizontal else rect.size.y) / 16.0)
		for k in steps:
			var offset := 16.0 * float(k)
			if horizontal:
				_line(rect.position + Vector2(offset, 0), rect.position + Vector2(offset + 12.0, rect.size.y), SLOT, 1.0)
			else:
				_line(rect.position + Vector2(0, offset), rect.position + Vector2(rect.size.x, offset + 12.0), SLOT, 1.0)
	# equipment
	for entry in equipment:
		_equipment_symbol(entry["id"], entry["rect"])
	# slots and machines
	for i in slots.size():
		var slot: Rect2 = slots[i]
		_dashed(slot, SLOT, 3.0, slot.size.x * 0.07, slot.size.x * 0.04)
		var corner := slot.size.x * 0.08
		for corner_spec in [[slot.position, 1.0, 1.0], [Vector2(slot.end.x, slot.position.y), -1.0, 1.0], [Vector2(slot.position.x, slot.end.y), 1.0, -1.0], [slot.end, -1.0, -1.0]]:
			var origin: Vector2 = corner_spec[0]
			_line(origin, origin + Vector2(corner * float(corner_spec[1]), 0), SLOT, 4.0)
			_line(origin, origin + Vector2(0, corner * float(corner_spec[2])), SLOT, 4.0)
		var center := slot.get_center()
		var machine := machine_in_slot(i)
		if machine.is_empty():
			_line(center - Vector2(slot.size.x * 0.04, 0), center + Vector2(slot.size.x * 0.04, 0), CYAN, 1.0)
			_line(center - Vector2(0, slot.size.x * 0.04), center + Vector2(0, slot.size.x * 0.04), CYAN, 1.0)
			continue
		var transit: bool = int(machine["arrive"]) > game.month
		var working: bool = bool(busy.get(machine["uid"], false))
		var color: Color = KIND_COLOR.get(machine["kind"], CYAN)
		if transit:
			color = Color(color.r, color.g, color.b, 0.4)
		_hatch(slot, HATCH, slot.size.x * 0.06, 1.0)
		_frame(slot, AMBER, 3.0)
		var picture := _kind_picture(String(machine["kind"]))
		if picture != null:
			_machine_picture(slot, picture, transit)
		else:
			var body := slot.grow_individual(-slot.size.x * SLOT_INSET, -slot.size.y * SLOT_INSET, -slot.size.x * SLOT_INSET, -slot.size.y * SLOT_INSET)
			_symbol(machine["kind"], int(machine["level"]), body, color, working)
		_slot_overlay(slot, machine, transit, working)
	if selected >= 0 and selected < slots.size():
		_frame((slots[selected] as Rect2).grow(5.0), SELECT, 3.0)
	# slot labels, daily output bars (screen-space text)
	for i in slots.size():
		var slot: Rect2 = slots[i]
		var machine := machine_in_slot(i)
		var screen_w: float = slot.size.x * zoom
		if screen_w >= 38.0 and machine.is_empty():
			_text(slot.position + Vector2(slot.size.x * 0.05, slot.size.y * 0.02) + Vector2(0, 14.0 / zoom), "T-%02d" % (i + 1), clampi(int(screen_w * 0.11), 9, 16), SLOT)
		if machine.is_empty():
			continue
		if screen_w >= 60.0:
			var label := String(machine["model"]) + ("  (yolda)" if int(machine["arrive"]) > game.month else "")
			_text(Vector2(slot.position.x, slot.end.y - slot.size.y * 0.02), label, clampi(int(screen_w * 0.09), 8, 15), TEXT, true, screen_w)
	_draw_flights()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var font := ThemeDB.fallback_font
	var factory: Dictionary = game.factory()
	var title := "%s · %d × %d m · %s m² · %d / %d tezgah" % [factory["name"], factory["width"], factory["length"], Data.thousands(int(factory["m2"])), game.machines.size(), slots.size()]
	draw_string_outline(font, Vector2(14, 28), title, HORIZONTAL_ALIGNMENT_LEFT, size.x - 80.0, 15, 5, Color(0.03, 0.08, 0.13, 0.95))
	draw_string(font, Vector2(14, 28), title, HORIZONTAL_ALIGNMENT_LEFT, size.x - 80.0, 15, TEXT)
	draw_string(font, Vector2(14, 46), "Sürükle: kaydır · +/−: yakınlaştır · dokun: ayrıntı", HORIZONTAL_ALIGNMENT_LEFT, size.x - 80.0, 11, Color(1, 1, 1, 0.5))
