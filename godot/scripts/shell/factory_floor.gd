extends Control
# Bird's-eye view of the rented plant: the factory's floor-plan picture with one yellow slot per machine.
# A bought machine sits in the centre of its slot. The view opens fitted to the screen; the player zooms in.

signal detail_requested(kind: String)
signal layout_changed   # kept for the shell's wiring; the plan is fixed, nothing is rearranged any more

const Data = preload("res://scripts/shell/shell_data.gd")
const Art = preload("res://scripts/shell/art.gd")

const BG_OUT := Color("#0b1118")
const TEXT := Color("#e8eef4")
const SELECT := Color("#3ddc84")
const KIND_COLOR := {"Torna": Color("#5f7a96"), "Freze": Color("#4f8f86"), "Taşlama": Color("#8a6fa8"), "Dövme": Color("#b0764a")}
const SLOT_INSET := 0.10   # the machine fills the slot minus this share on every side
const MAX_ZOOM_FACTOR := 10.0   # relative to the fitted view

var game
var plan_tex: Texture2D
var plan_size := Vector2.ONE   # picture size in pixels: the world unit of this view
var slots: Array = []   # Rect2 per slot, in picture pixels
var zoom := 1.0
var pan := Vector2.ZERO
var fit_zoom := 1.0
var selected := -1   # slot index
var sprite_cache := {}
var press_pos := Vector2.ZERO
var pressing := false
var moved := false
var user_adjusted := false
var anim_time := 0.0
var busy := {}
var day_frac := -1.0   # share of the month elapsed while the clock runs (-1 = clock off)
var plan_output := {}   # expected output per machine this month
var any_busy := false
var info_panel: PanelContainer
var info_label: Label
var info_button: Button
var info_kind := ""

func setup(game_ref, saved_zoom := 0.0, saved_pan := Vector2.ZERO) -> void:
	game = game_ref
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	plan_tex = Art.find("res://art/floor/plans/" + Data.plan_stem(game.factory_id))
	plan_size = plan_tex.get_size() if plan_tex != null else Vector2(1000, 1000)
	slots.clear()
	for entry in Data.plan_slots(game.factory_id):
		slots.append(Rect2(Vector2(float(entry[0]), float(entry[1])) * plan_size, Vector2(float(entry[2]), float(entry[3])) * plan_size))
	busy = game.busy_machines()
	plan_output = game.month_plan_output()
	for uid in busy:
		any_busy = any_busy or bool(busy[uid])
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

# ------------------------------------------------------------------ view

func _refresh_fit() -> void:
	if size.x <= 0.0:
		return
	fit_zoom = minf((size.x - 16.0) / plan_size.x, (size.y - 64.0) / plan_size.y)

func _to_screen(point: Vector2) -> Vector2:
	return pan + point * zoom

func _to_world(point: Vector2) -> Vector2:
	return (point - pan) / zoom

# Whole plant on screen (first look).
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
	selected = _slot_at(_to_world(screen_point))
	_show_info()
	queue_redraw()

func _slot_text(slot: int) -> String:
	var machine := machine_in_slot(slot)
	if machine.is_empty():
		return "Boş tezgah yuvası (%d / %d dolu)\nTezgah ilanlarından satın aldığın tezgah buraya yerleşir." % [game.machines.size(), slots.size()]
	var status := "Boşta · iş bekliyor"
	if int(machine["arrive"]) > game.month:
		status = "Yolda · %d ay sonra teslim" % (int(machine["arrive"]) - game.month)
	elif bool(busy.get(machine["uid"], false)):
		status = "Çalışıyor"
	var extra := ""
	if int(machine["arrive"]) <= game.month:
		extra = " · %d vardiya%s · %s/ay" % [machine["shifts"], " (patron)" if machine.get("patron", false) else "", Data.x_text(game.machine_output(machine, game.problem_mults(game.loss_fractions())))]
	return "%s · %s %s\n%s%s" % [machine["model"], Data.LEVELS[int(machine["level"])], machine["kind"], status, extra]

func _show_info() -> void:
	if selected < 0:
		info_panel.visible = false
		return
	info_label.text = _slot_text(selected)
	info_kind = "machines" if not machine_in_slot(selected).is_empty() else ""
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

# ------------------------------------------------------------------ drawing

func _process(delta: float) -> void:
	if game == null or not any_busy or not is_visible_in_tree():
		return
	anim_time += delta
	queue_redraw()

func _sprite_for(machine: Dictionary) -> Texture2D:
	var key := "res://art/floor/machines/%s_%d" % [Art.slug(machine["kind"]), machine["level"]]
	if not sprite_cache.has(key):
		sprite_cache[key] = Art.find(key)
	return sprite_cache[key]

func _screen_rect(rect: Rect2) -> Rect2:
	return Rect2(_to_screen(rect.position), rect.size * zoom)

# Machine sprite fitted (aspect kept) into the middle of the slot.
func _draw_sprite_fit(texture: Texture2D, rect: Rect2, modulate_color := Color.WHITE) -> void:
	var texture_size := texture.get_size()
	var factor := minf(rect.size.x / texture_size.x, rect.size.y / texture_size.y)
	var fitted := texture_size * factor
	draw_texture_rect(texture, Rect2(rect.position + (rect.size - fitted) / 2.0, fitted), false, modulate_color)

func _draw() -> void:
	if game == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), BG_OUT)
	if plan_tex != null:
		draw_texture_rect(plan_tex, _screen_rect(Rect2(Vector2.ZERO, plan_size)), false)
	else:
		draw_rect(_screen_rect(Rect2(Vector2.ZERO, plan_size)), Color("#46505b"))
		for rect in slots:
			draw_rect(_screen_rect(rect), Color("#e0a800"), false, 2.0)
	var font := ThemeDB.fallback_font
	for i in slots.size():
		var machine := machine_in_slot(i)
		if machine.is_empty():
			continue
		var frame := _screen_rect(slots[i])
		var body := frame.grow_individual(-frame.size.x * SLOT_INSET, -frame.size.y * SLOT_INSET, -frame.size.x * SLOT_INSET, -frame.size.y * SLOT_INSET)
		var transit: bool = int(machine["arrive"]) > game.month
		var working: bool = bool(busy.get(machine["uid"], false))
		var texture := _sprite_for(machine)
		if texture != null:
			_draw_sprite_fit(texture, Rect2(body.position + Vector2(frame.size.x, frame.size.y) * 0.02, body.size), Color(0, 0, 0, 0.28))
			_draw_sprite_fit(texture, body, Color(1, 1, 1, 0.45) if transit else Color.WHITE)
		else:
			var base: Color = KIND_COLOR.get(machine["kind"], Color.GRAY).lightened(0.08 * float(int(machine["level"]) - 1))
			base.a = 0.45 if transit else 1.0
			draw_rect(body, base)
			draw_rect(body, base.darkened(0.5), false, 2.0)
		var dot := Color("#3ddc84") if working else (Color("#eac47a") if transit else Color("#93a3b3"))
		var radius := maxf(3.0, frame.size.x * 0.045)
		draw_circle(frame.position + Vector2(frame.size.x - radius * 2.2, radius * 2.2), radius, dot)
		if working:
			var pulse := 0.5 + 0.5 * sin(anim_time * 3.0)
			draw_arc(frame.position + Vector2(frame.size.x - radius * 2.2, radius * 2.2), radius * (1.6 + pulse), 0.0, TAU, 20, Color(dot, 0.5 * (1.0 - pulse)), 1.5)
		if working and day_frac >= 0.0 and plan_output.has(machine["uid"]) and frame.size.x >= 40.0:
			var bar := Rect2(frame.position + Vector2(frame.size.x * 0.12, frame.size.y * 0.035), Vector2(frame.size.x * 0.76, maxf(4.0, frame.size.y * 0.035)))
			draw_rect(bar, Color(0, 0, 0, 0.55))
			draw_rect(Rect2(bar.position, Vector2(bar.size.x * day_frac, bar.size.y)), SELECT)
			var made := "~%d µ" % int(roundf(float(plan_output[machine["uid"]]) * day_frac))
			var made_size := clampi(int(frame.size.x * 0.1), 8, 16)
			draw_string_outline(font, bar.position + Vector2(0, -3), made, HORIZONTAL_ALIGNMENT_LEFT, -1, made_size, 4, Color(0.05, 0.07, 0.09, 0.95))
			draw_string(font, bar.position + Vector2(0, -3), made, HORIZONTAL_ALIGNMENT_LEFT, -1, made_size, TEXT)
		if frame.size.x >= 60.0:
			var label := String(machine["model"])
			var label_size := clampi(int(frame.size.x * 0.92 / (0.56 * float(label.length()))), 8, 18)
			var label_pos := Vector2(frame.position.x, frame.end.y - frame.size.y * 0.04)
			draw_string_outline(font, label_pos, label, HORIZONTAL_ALIGNMENT_CENTER, frame.size.x, label_size, 5, Color(0.05, 0.07, 0.09, 0.95))
			draw_string(font, label_pos, label, HORIZONTAL_ALIGNMENT_CENTER, frame.size.x, label_size, TEXT)
	if selected >= 0 and selected < slots.size():
		draw_rect(_screen_rect(slots[selected]).grow(3.0), SELECT, false, 3.0)
	var factory: Dictionary = game.factory()
	var title := "%s · %d × %d m · %d m² · %d / %d tezgah" % [factory["name"], factory["width"], factory["length"], factory["m2"], game.machines.size(), slots.size()]
	draw_string_outline(font, Vector2(14, 28), title, HORIZONTAL_ALIGNMENT_LEFT, size.x - 80.0, 15, 5, Color(0.05, 0.07, 0.09, 0.95))
	draw_string(font, Vector2(14, 28), title, HORIZONTAL_ALIGNMENT_LEFT, size.x - 80.0, 15, TEXT)
	draw_string(font, Vector2(14, 46), "Sürükle: kaydır · +/−: yakınlaştır · dokun: ayrıntı", HORIZONTAL_ALIGNMENT_LEFT, size.x - 80.0, 11, Color(1, 1, 1, 0.5))
