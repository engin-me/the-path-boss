extends Control

# Mobile-portrait factory shell (fixed header, sticky bar, page area, fixed
# bottom tabs). UI over MOCK data: rules are NOT wired to BossState and nothing
# here is a FREEZE decision. Proposed rules: docs/ideas/IDEA-015 and IDEA-016.

const Data = preload("res://scripts/shell/shell_data.gd")
const BossState = preload("res://scripts/boss_state.gd")
const ShellBoss = preload("res://scripts/shell/shell_boss.gd")
const SaveStore = preload("res://scripts/shell/save_store.gd")
const Art = preload("res://scripts/shell/art.gd")
const FloorScript = preload("res://scripts/shell/factory_floor.gd")
const AudioDirector = preload("res://scripts/shell/audio_director.gd")

const BG := Color("#0f1720")
const PANEL := Color("#1a232e")
const PANEL_ALT := Color("#222e3b")
const BORDER := Color("#34424f")
const TEXT := Color("#e8eef4")
const MUTED := Color("#93a3b3")
const GREEN := Color("#3ddc84")
const GREEN_DIM := Color("#16382a")
const GOLD := Color("#eac47a")
const YELLOW := Color("#f2d24b")
const RED := Color("#f08080")

const TABS := [
	{"id": "ozet", "icon": "🏠", "title": "Özet"},
	{"id": "isler", "icon": "📋", "title": "İşler"},
	{"id": "tezgah", "icon": "⚙", "title": "Tezgah"},
	{"id": "fabrika", "icon": "🏭", "title": "Fabrika"},
	{"id": "profil", "icon": "👤", "title": "Profil"}
]

var game = ShellBoss.new()
var flash := ""
var page := "ozet"
var subtab := {"ozet": "genel", "isler": "tum", "tezgah": "tezgah", "fabrika": "yerlesim"}
var type_filter := "Tümü"
var detail := ""
var detail_arg := ""
var picked_term := 12
var quote_price := 0.0
var quote_margin := 0.30
var quote_edit := {}   # requirement index -> {scrap_pt, overhead_pct, personnel_pct}: the player's own cost assumptions
var quote_adv := 30
var quote_months := 0
var picked_prepay := false
var selected_listing := -1
var collateral_picks: Array = []
var equip_qty := {}
var pending := Callable()
var press_pos := Vector2.ZERO

var audio: Node
var last_cash := NAN
var last_month := -1
var last_view_key := ""
var fade_tween: Tween
var money_tween: Tween
var header_date: Label
var header_money: Label
var header_hours: Label
var sticky: VBoxContainer
var stage: Control
var background: TextureRect
var content: VBoxContainer
var tab_buttons := {}
var scroll_view: ScrollContainer
var floor_view: Control
var floor_state := {}
var overlay: Control
var safe_top: Control
var safe_bottom: Control
var listing_cards := {}
var area_label: Label
var area_used_bar: ProgressBar
var area_preview_bar: ProgressBar

func _ready() -> void:
	audio = AudioDirector.new()
	add_child(audio)
	_reset_state()
	if SaveStore.exists():
		var loaded := ShellBoss.new()
		var reason: String = loaded.from_save(SaveStore.read())
		if reason == "":
			game = loaded
			flash = "Kayıt yüklendi · %s" % Data.month_label(int(game.month))
		else:
			flash = "Kayıt okunamadı; yeni oyun başladı."
	_build()
	_apply_safe_area()
	_render()

# Android back key: close a dialog, then a detail screen, then go to Özet.
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_autosave()
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if overlay != null and overlay.get_child_count() > 0:
			_confirm_no()
		elif detail != "":
			_back()
		elif page != "ozet":
			_on_tab("ozet")

# Keeps the header and tab bar clear of notches and gesture bars on phones.
func _apply_safe_area() -> void:
	if not OS.has_feature("mobile") or safe_top == null:
		return
	var safe := DisplayServer.get_display_safe_area()
	var window := get_window()
	var scale := float(window.size.x) / maxf(1.0, get_viewport_rect().size.x)
	safe_top.custom_minimum_size = Vector2(0, maxf(0.0, safe.position.y / scale))
	safe_bottom.custom_minimum_size = Vector2(0, maxf(0.0, (window.size.y - safe.end.y) / scale))

func _reset_state(rng_seed := -1) -> void:
	game = ShellBoss.new()
	game.default_setup(rng_seed)
	flash = ""

# ------------------------------------------------------------------ layout

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.add_theme_constant_override("separation", 0)
	add_child(column)
	safe_top = Control.new()
	column.add_child(safe_top)
	column.add_child(_build_header())
	sticky = VBoxContainer.new()
	column.add_child(sticky)
	stage = Control.new()
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.clip_contents = true
	column.add_child(stage)
	background = TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	stage.add_child(background)
	var scroll := ScrollContainer.new()
	scroll_view = scroll
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.scroll_deadzone = 12  # a drag steals the touch from buttons under the finger
	stage.add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 16)
	scroll.add_child(margin)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	margin.add_child(content)
	column.add_child(_build_tab_bar())
	safe_bottom = Control.new()
	column.add_child(safe_bottom)
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

func _build_header() -> Control:
	var bar := PanelContainer.new()
	bar.add_theme_stylebox_override("panel", _box(Color("#151d26"), BORDER, 0, 0))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	bar.add_child(_margin(row, 14, 10))
	header_date = _label("", 15, TEXT, false)
	header_date.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(header_date)
	header_hours = _label("", 14, MUTED, false)
	row.add_child(header_hours)
	var pill := PanelContainer.new()
	pill.add_theme_stylebox_override("panel", _box(GREEN_DIM, GREEN, 8, 1))
	header_money = _label("", 17, GREEN, false)
	pill.add_child(_margin(header_money, 12, 5))
	row.add_child(pill)
	return bar

func _build_tab_bar() -> Control:
	var bar := PanelContainer.new()
	bar.add_theme_stylebox_override("panel", _box(Color("#151d26"), BORDER, 0, 0))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	bar.add_child(_margin(row, 8, 8))
	for tab in TABS:
		var button := Button.new()
		button.text = "%s\n%s" % [tab["icon"], tab["title"]]
		button.custom_minimum_size = Vector2(0, 62)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(_on_tab.bind(tab["id"]))
		_juice(button)
		row.add_child(button)
		tab_buttons[tab["id"]] = button
	return bar

# ------------------------------------------------------------------ helpers

func _label(text: String, size := 14, color := TEXT, wrap := true) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _rich(bbcode: String, size := 16) -> RichTextLabel:
	var rich := RichTextLabel.new()
	rich.bbcode_enabled = true
	rich.fit_content = true
	rich.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rich.scroll_active = false
	rich.text = bbcode
	rich.add_theme_font_size_override("normal_font_size", size)
	rich.add_theme_color_override("default_color", TEXT)
	rich.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return rich

func _box(fill: Color, border: Color, radius := 10, width := 1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	return box

func _margin(child: Control, horizontal: int, vertical: int) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", horizontal)
	margin.add_theme_constant_override("margin_right", horizontal)
	margin.add_theme_constant_override("margin_top", vertical)
	margin.add_theme_constant_override("margin_bottom", vertical)
	margin.add_child(child)
	return margin

# Returns the inner VBox of a new card added to `parent`. `big` doubles the type
# and padding for listing cards (fabrika, tezgah).
func _card(parent: Control, title := "", accent := BORDER, big := false) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_theme_stylebox_override("panel", _box(Color(PANEL.r, PANEL.g, PANEL.b, 0.94), accent, 14, 2 if big else 1))
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 10 if big else 6)
	panel.add_child(_margin(inner, 18 if big else 14, 16 if big else 12))
	parent.add_child(panel)
	if title != "":
		inner.add_child(_label(title, 22 if big else 16, TEXT))
	return inner

func _panel_of(inner: Control) -> PanelContainer:
	return inner.get_parent().get_parent() as PanelContainer

func _button(text: String, callback: Callable, primary := false, disabled := false, big := false) -> Button:
	var button := Button.new()
	button.text = text
	button.disabled = disabled
	button.custom_minimum_size = Vector2(0, 58 if big else 44)
	button.add_theme_font_size_override("font_size", 18 if big else 15)
	if primary:
		button.add_theme_stylebox_override("normal", _box(Color("#1f7a4d"), GREEN, 10, 1))
		button.add_theme_stylebox_override("hover", _box(Color("#26955e"), GREEN, 10, 1))
		button.add_theme_stylebox_override("pressed", _box(Color("#186040"), GREEN, 10, 1))
	button.pressed.connect(callback)
	_juice(button)
	return button

# Tap sound and a small press animation for any button.
func _juice(button: Button) -> void:
	button.pressed.connect(func() -> void: audio.play("tap"))
	button.button_down.connect(func() -> void: _press_scale(button, 0.96))
	button.button_up.connect(func() -> void: _press_scale(button, 1.0))

func _press_scale(button: Button, target: float) -> void:
	if not is_instance_valid(button) or not button.is_inside_tree():
		return
	button.pivot_offset = button.size / 2.0
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2(target, target), 0.07)

func _row(parent: Control, left: String, right: String, color := TEXT, size := 14) -> void:
	var row := HBoxContainer.new()
	row.add_child(_label(left, size, MUTED))
	var value := _label(right, size, color, false)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value)
	parent.add_child(row)

func _bar(value: float, maximum: float, color := GREEN) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.max_value = maxf(maximum, 1.0)
	bar.value = clampf(value, 0.0, maxf(maximum, 1.0))
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 10)
	bar.add_theme_stylebox_override("background", _box(Color("#0b1118"), BORDER, 5, 1))
	bar.add_theme_stylebox_override("fill", _box(color, color, 5, 0))
	return bar

func _chips(parent: Control, options: Array, current: String, callback: Callable) -> void:
	var scroll := ScrollContainer.new()
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(0, 46)
	scroll.scroll_deadzone = 12
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	scroll.add_child(row)
	var active_button: Button = null
	for option in options:
		var button := Button.new()
		button.text = option["title"]
		button.custom_minimum_size = Vector2(0, 40)
		var active: bool = option["id"] == current
		if active:
			active_button = button
		for style_name in ["normal", "hover", "pressed"]:
			var chip := _box(GREEN_DIM if active else PANEL_ALT, GREEN if active else BORDER, 20, 1)
			chip.content_margin_left = 16
			chip.content_margin_right = 16
			button.add_theme_stylebox_override(style_name, chip)
		button.add_theme_color_override("font_color", GREEN if active else TEXT)
		button.pressed.connect(callback.bind(option["id"]))
		_juice(button)
		row.add_child(button)
	parent.add_child(scroll)
	if active_button != null:
		# the row is rebuilt on every render, so bring the selected chip back into view once it has a size
		(func() -> void:
			await get_tree().process_frame
			await get_tree().process_frame
			if is_instance_valid(scroll) and is_instance_valid(active_button):
				scroll.ensure_control_visible(active_button)).call()

# Image slot: loads res://art/<kind>/<id>.png when it exists, else a placeholder.
func _image_slot(kind: String, id: String, tint: Color, height := 250) -> Control:
	var texture: Texture2D = Art.find("res://art/%s/%s" % [kind, id])
	if texture != null:
		var rect := TextureRect.new()
		rect.texture = texture
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		rect.custom_minimum_size = Vector2(0, height)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return rect
	var holder := ColorRect.new()
	holder.color = tint
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.custom_minimum_size = Vector2(0, height)
	var caption := _label("Görsel: art/%s/%s" % [kind, id], 12, Color(1, 1, 1, 0.35), false)
	caption.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	caption.grow_horizontal = Control.GROW_DIRECTION_BOTH
	caption.grow_vertical = Control.GROW_DIRECTION_BOTH
	holder.add_child(caption)
	return holder

# ------------------------------------------------------------------ confirm dialog

func _confirm(title: String, lines: Array, ok_text: String, on_ok: Callable, warn := "") -> void:
	_close_overlay()
	pending = on_ok
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.66)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 0)
	panel.add_theme_stylebox_override("panel", _box(PANEL, GOLD, 14, 2))
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(_margin(box, 20, 18))
	box.add_child(_label(title, 20, TEXT))
	for line in lines:
		box.add_child(_label(str(line), 15, MUTED))
	if warn != "":
		box.add_child(_label(warn, 15, GOLD))
	box.add_child(_button(ok_text, _confirm_yes, true))
	box.add_child(_button("Vazgeç", _confirm_no))

func _confirm_yes() -> void:
	audio.play("confirm")
	var action := pending
	_close_overlay()
	if action.is_valid():
		action.call()

func _confirm_no() -> void:
	_close_overlay()

func _close_overlay() -> void:
	pending = Callable()
	for child in overlay.get_children():
		overlay.remove_child(child)
		child.queue_free()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

# ------------------------------------------------------------------ navigation

func _on_tab(id: String) -> void:
	page = id
	detail = ""
	_render()

func _open_detail(kind: String, arg := "") -> void:
	detail = kind
	detail_arg = arg
	if kind == "quote":
		quote_months = 0
	_render()

func _back() -> void:
	detail = ""
	_render()

func _autosave() -> void:
	if game != null and game.phase != "setup":
		SaveStore.write(game.to_save())

func _say(message: String) -> void:
	flash = message

func _render() -> void:
	var key := "%s|%s|%s" % [page, detail, str(subtab.get(page, ""))]
	_render_inner()
	var cash_now := float(game.cash)
	if not is_nan(last_cash) and absf(cash_now - last_cash) > 0.5:
		audio.play("coin_up" if cash_now > last_cash else "coin_down")
		_animate_money(last_cash, cash_now)
	if last_month >= 0 and int(game.month) > last_month:
		audio.play("month")
	last_cash = cash_now
	last_month = int(game.month)
	if last_view_key != "" and key != last_view_key:
		_fade_in()
	last_view_key = key

func _animate_money(from: float, to: float) -> void:
	if money_tween != null and money_tween.is_valid():
		money_tween.kill()
	header_money.modulate = Color(0.7, 1.7, 0.9) if to > from else Color(1.8, 0.65, 0.65)
	money_tween = create_tween()
	money_tween.set_parallel(true)
	money_tween.tween_method(func(value: float) -> void: header_money.text = Data.usd(value), from, to, 0.4)
	money_tween.tween_property(header_money, "modulate", Color.WHITE, 0.6)

# Soft fade when the visible screen changes.
func _fade_in() -> void:
	var target: CanvasItem = floor_view if floor_view != null else content
	if target == null:
		return
	if fade_tween != null and fade_tween.is_valid():
		fade_tween.kill()
	target.modulate.a = 0.0
	fade_tween = create_tween()
	fade_tween.tween_property(target, "modulate:a", 1.0, 0.2)

func _render_inner() -> void:
	_autosave()
	header_date.text = Data.month_label(int(game.month))
	header_money.text = Data.usd(float(game.cash))
	header_hours.text = "⏱ %d/%d sa" % [game.hours_left, game.monthly_hours] if game.phase == "report" else ""
	for id in tab_buttons:
		var active: bool = id == page
		var button: Button = tab_buttons[id]
		button.add_theme_stylebox_override("normal", _box(GREEN_DIM if active else PANEL_ALT, GREEN if active else BORDER, 10, 2 if active else 1))
		button.add_theme_color_override("font_color", GREEN if active else MUTED)
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	for child in sticky.get_children():
		sticky.remove_child(child)
		child.queue_free()
	listing_cards.clear()
	area_label = null
	if floor_view != null:
		floor_state = floor_view.view_state()
		stage.remove_child(floor_view)
		floor_view.queue_free()
		floor_view = null
	var rented: bool = page == "fabrika" and detail == "" and game.factory_id != ""
	var show_floor: bool = rented and subtab["fabrika"] == "yerlesim"
	scroll_view.visible = not show_floor
	if rented:
		_chips(sticky, [{"id": "yerlesim", "title": "Yerleşim (üstten)"}, {"id": "vardiya", "title": "Vardiya"}, {"id": "sozlesme", "title": "Sözleşme"}], subtab["fabrika"],
			func(id: String) -> void:
				subtab["fabrika"] = id
				_render())
	background.texture = _background_texture()
	if show_floor:
		floor_view = FloorScript.new()
		floor_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		stage.add_child(floor_view)
		var keep: bool = floor_state.get("factory", "") == game.factory_id
		floor_view.setup(game, float(floor_state.get("zoom", 0.0)) if keep else 0.0, floor_state.get("pan", Vector2.ZERO) if keep else Vector2.ZERO)
		floor_view.detail_requested.connect(func(kind: String) -> void: _open_detail(kind))
		floor_view.layout_changed.connect(func() -> void:
			audio.play("drop")
			SaveStore.write(game.to_save()))
		if flash != "":
			floor_view.info_label.text = flash
			floor_view.info_button.visible = false
			floor_view.info_panel.visible = true
			flash = ""
		return
	if flash != "":
		var note := _card(content, "", GOLD)
		note.add_child(_label(flash, 14, GOLD))
		flash = ""
	if detail != "":
		_render_detail()
		return
	match page:
		"ozet": _page_ozet()
		"isler": _page_isler()
		"tezgah": _page_tezgah()
		"fabrika": _page_fabrika()
		"profil": _page_profil()

func _background_texture() -> Texture2D:
	if page != "ozet" or detail != "" or game.factory_id == "" or game.factory().is_empty():
		return null
	var gradient := Gradient.new()
	var tint: Color = game.factory()["tint"]
	gradient.colors = PackedColorArray([tint.lightened(0.15), tint, BG])
	gradient.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.5, 0.0)
	texture.fill_to = Vector2(0.5, 1.0)
	texture.width = 8
	texture.height = 256
	return texture

func _locked(message: String) -> void:
	var box := _card(content, "🔒 Kilitli", BORDER)
	box.add_child(_label(message, 14, MUTED))
	box.add_child(_button("Fabrika sayfasına git", _on_tab.bind("fabrika"), true))

# ------------------------------------------------------------------ Özet

func _page_ozet() -> void:
	if game.phase == "end":
		_page_end()
		return
	_chips(content, [{"id": "genel", "title": "Genel"}, {"id": "dep", "title": "Departmanlar"}, {"id": "rapor", "title": "Rapor"}],
		subtab["ozet"], func(id: String) -> void:
			subtab["ozet"] = id
			_render())
	if game.factory_id == "":
		var empty := _card(content, "Henüz fabrikan yok", GOLD)
		empty.add_child(_label("Önce bir yer kirala. Sonra ekipman, tezgah ve iş.", 14, MUTED))
		empty.add_child(_button("Kiralık yerlere bak", _on_tab.bind("fabrika"), true))
		return
	match subtab["ozet"]:
		"dep": _ozet_departments()
		"rapor": _ozet_report()
		_: _ozet_general()

func _skip_month() -> void:
	var result: String = game.run_report()
	if result == "":
		result = game.close_month()
	if result != "":
		_say(result)
	subtab["ozet"] = "genel"
	_render()

func _phase_button() -> void:
	if game.phase == "offers":
		content.add_child(_button("Ayı çalıştır ▶", _open_report, true, false, true))
		if game.delivered().is_empty() and game.jobs.is_empty():
			content.add_child(_button("Ayı atla ⏭ (üretim yok)", _skip_month))
	elif game.phase == "report":
		content.add_child(_button("Ayı bitir ▶", _close_month, true, false, true))

func _open_report() -> void:
	var result: String = game.run_report()
	if result != "":
		_say(result)
	else:
		subtab["ozet"] = "rapor"
	_render()

func _close_month() -> void:
	var result: String = game.close_month()
	if result != "":
		_say(result)
	subtab["ozet"] = "genel"
	_render()

func _ozet_general() -> void:
	var factory: Dictionary = game.factory()
	content.add_child(_label(factory["name"], 22, TEXT))
	content.add_child(_label("%s · %d m² · %.1f m yükseklik" % [factory["region"], factory["m2"], factory["height"]], 13, MUTED))
	if not game.package_bought:
		var warn := _card(content, "Gerekli ekipman eksik", GOLD)
		warn.add_child(_label("Gerekli ekipman seti alınmadan kapasite kullanılamaz.", 13, MUTED))
		warn.add_child(_button("Ekipmana git", _go_equipment, true))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content.add_child(grid)
	var delivered: int = game.delivered().size()
	var transit: int = game.machines.size() - delivered
	var oee := "—"
	if delivered > 0 and game.package_bought:
		oee = "%%%d" % int(roundf(game.oee_now() * 100.0))
	var tiles := [
		["Makine", "%d%s" % [delivered, " (+%d yolda)" % transit if transit > 0 else ""], "detail:machines"],
		["Yatırım tutarı", Data.usd(float(game.invested)), "detail:machines"],
		["Güncel değer", Data.usd(float(game.investment_value())), "detail:machines"],
		["OEE (24 saat)", oee, "detail:oee"],
		["Üretilebilir kapasite", "%s/ay" % _xfmt(game.effective_capacity()), "detail:oee"],
		["Teslim skoru", "%%%d" % int(roundf(float(game.delivery_score) * 100.0)), "tab:isler"],
		["Aktif iş", str(game.jobs.size()), "tab:isler"],
		["Aylık gider", Data.usd(float(game.ordinary_expense())), "detail:costs"],
		["Sözleşme", "%d ay kaldı" % int(game.months_left), "tab:fabrika"],
		["Patron zamanı", "%d / %d sa" % [game.hours_left if game.phase == "report" else game.monthly_hours - game.patron_hours(), game.monthly_hours], "sub:dep"]
	]
	if game.debt > 0.0:
		tiles.append(["Borç", Data.usd(float(game.debt)), "detail:credit"])
	for tile in tiles:
		var box := _card(grid, "", BORDER)
		box.add_child(_label(tile[0] + "  ›", 12, MUTED))
		box.add_child(_label(tile[1], 18, TEXT))
		var tile_panel := _panel_of(box)
		tile_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tile_panel.gui_input.connect(_on_tile_input.bind(tile[2]))
	_phase_button()
	if game.phase == "offers" and not game.last_lines.is_empty():
		var last := _card(content, "Geçen ay")
		for line in game.last_lines:
			last.add_child(_label(str(line), 13, MUTED))

func _ozet_report() -> void:
	if game.phase != "report":
		var box := _card(content, "Ay raporu")
		if game.last_lines.is_empty():
			box.add_child(_label("Rapor, ay başında \"Ayı çalıştır\" ile açılır.", 14, MUTED))
		else:
			box.add_child(_label("Geçen ayın kapanışı:", 13, MUTED))
			for line in game.last_lines:
				box.add_child(_label(str(line), 13, TEXT))
		_phase_button()
		return
	_waterfall_card(content, "Ay %d raporu" % game.month, game.report)
	var report: Dictionary = game.report
	var by_dept: Dictionary = report["by_dept"]
	if not by_dept.is_empty():
		var by_dep := _card(content, "Sorun kaybı — alanlara göre")
		for department in by_dept:
			var physical: bool = ShellBoss.PHYSICAL_DEPARTMENTS.has(department)
			_row(by_dep, "%s%s" % [department, "" if physical else " (OEE dışı)"], "%%%.1f çıktı" % (float(by_dept[department]) * 100.0), TEXT if physical else MUTED, 14)
		if report["capped"]:
			by_dep.add_child(_label("Bir alanın kaybı %20 tavanına kırpıldı.", 12, GOLD))
	var why := _card(content, "Bu sayılar nereden?")
	for line in ["Teorik: makinelerin 3 vardiya (24 saat) çalışırsa üretebileceği x. Tek başına sen bir makinede yalnız bir vardiya çalıştırırsın; bu yüzden \"vardiya kaybı\" büyük görünür.",
			"Performans: tezgah seviyesine bağlı hız (Standart %70, Hassas %80, Nitelikli %90). Hurda: tezgah türü ve seviyesine bağlı.",
			"Sorun kaybı: aktif sorunlar (Bakım/Planlama/Depo → kullanılabilirlik, Üretim → performans, Kalite → hurda; diğer alanlar OEE dışı).",
			"Üretilebilir kapasite, kabul ettiğin işlere FIFO ile dağıtılır; dağıtılan kısım \"gerçek üretim\", artan kısım \"boş kapasite\"dir. İş yoksa üretilebilir kapasite yine de görünür ama gerçek üretim sıfırdır.",
			"OEE (24 saat bazlı) = fiziksel kayıplardan sonra iyi parça / teorik."]:
		why.add_child(_label(line, 12, MUTED))
	_phase_button()

func _xfmt(value: float) -> String:
	return Data.x_text(value)

# Waterfall from theoretical capacity to good output, then how much went to jobs.
func _waterfall_card(parent: Control, title: String, report: Dictionary) -> void:
	var box := _card(parent, title, GREEN, true)
	var steps := [["Teorik (3 vardiya)", float(report["theoretical"]), 0.0],
		["Vardiya kaybı", float(report["shift"]), float(report["theoretical"])],
		["Performans kaybı", float(report["perf"]), float(report["shift"])],
		["Hurda", float(report["scrap"]), float(report["perf"])],
		["Sorun kaybı (fiziksel)", float(report["phys"]), float(report["scrap"])],
		["Üretilebilir kapasite", float(report["net"]), float(report["phys"])]]
	for step in steps:
		var loss: float = float(step[2]) - float(step[1])
		var text := _xfmt(float(step[1])) if float(step[2]) == 0.0 else "%s  (−%s)" % [_xfmt(float(step[1])), _xfmt(loss)]
		_row(box, step[0], text, RED if loss > 0.5 and float(step[2]) > 0.0 else TEXT, 15)
		box.add_child(_bar(float(step[1]), maxf(1.0, float(report["theoretical"])), GREEN if step[0] == "Üretilebilir kapasite" else YELLOW))
	_row(box, "Gerçek üretim (işlere giden)", _xfmt(float(report["used"])), GREEN, 16)
	_row(box, "Boş kapasite (iş yok)", _xfmt(float(report["idle"])), MUTED, 15)
	var waiting: Array = []
	for job in game.jobs:
		var why: String = game.job_wait_reason(job)
		if why != "":
			waiting.append("%s: %s" % [job["title"], why])
	for line in waiting:
		box.add_child(_label("Üretilmeyen iş · " + line, 12, GOLD))
	if game.jobs.is_empty():
		box.add_child(_label("Kabul edilmiş iş yok; kapasite var ama üretilecek bir şey yok.", 12, GOLD))
	_row(box, "OEE (24 saat bazlı)", "%%%d" % int(roundf(float(report["oee"]) * 100.0)), TEXT, 16)

func _ozet_departments() -> void:
	var head := _card(content, "Düzelt", BORDER)
	head.add_child(_label("Patron zamanı %d/%d sa · kullanılabilir nakit %s" % [game.hours_left if game.phase == "report" else game.monthly_hours, game.monthly_hours, Data.usd(float(game.available_cash()))], 13, MUTED))
	if game.phase != "report":
		head.add_child(_label("Düzelt, ay raporu açıldıktan sonra yapılır. Şimdilik yalnızca durum görünür.", 12, GOLD))
	var quiet: Array = []
	for department in BossState.SKILLS:
		var rows: Array = game.active_rows(department)
		if rows.is_empty():
			quiet.append(department)
			continue
		_department_card(department, rows)
	if not quiet.is_empty():
		content.add_child(_label("Aktif sorunu olmayan departmanlar: " + ", ".join(quiet), 12, MUTED))
	_phase_button()

func _department_card(department: String, rows: Array) -> void:
	var patron: int = game.skills[department]
	var effective: int = game.effective_skill(department)
	var reach: int = game.reach(department)
	var box := _card(content, department, BORDER)
	box.add_child(_label("Patron %d%s → T%d'ye kadar okur" % [patron, (" · danışmanla %d" % effective) if effective > patron else "", reach], 12, MUTED))
	for row in rows:
		var slot: String = ("T%d" % row["tier"]) if row["visible"] else "Derinlik bilinmiyor"
		var growth: String = " (büyüyor)" if float(row["loss"]) > float(row["base_loss"]) + 0.05 else ""
		box.add_child(_label("%s · %.1f kayıp%s · şans %s" % [slot, row["loss"], growth, row["chance"]], 15, TEXT if row["visible"] else GOLD))
		var text: String = "Bu ay denendi" if row["attempted"] else "Düzelt · tahmin %s / en fazla %s · %d–%d sa" % [Data.usd(float(row["estimate"])), Data.usd(float(row["upper"])), row["estimate_hours"], row["upper_hours"]]
		box.add_child(_button(text, _fix.bind(row["id"]), false, row["attempted"] or row["blocked"] != ""))
		if row["blocked"] != "" and not row["attempted"]:
			box.add_child(_label(row["blocked"], 12, RED))

func _fix(root_id: String) -> void:
	var result: Dictionary = game.fix(root_id)
	_say(game.notice)
	_render()

func _on_tile_input(event: InputEvent, target: String) -> void:
	if not _is_tap(event):
		return
	var parts := target.split(":")
	match parts[0]:
		"detail": _open_detail(parts[1])
		"tab": _on_tab(parts[1])
		"sub":
			subtab["ozet"] = parts[1]
			_render()

func _go_equipment() -> void:
	subtab["tezgah"] = "ekipman"
	_on_tab("tezgah")

func _page_end() -> void:
	var outcome := {"survived": "Fabrika test süresince ayakta kaldı.", "forced": "Zorunlu kapanış: tasfiye borcu kapattı, iflas değil.", "bankrupt": "Zorunlu kapanış ve iflas: tasfiyeden sonra borç kaldı."}
	var box := _card(content, "Kapanış raporu", GOLD, true)
	box.add_child(_label(outcome.get(game.closure.get("type", ""), "Oyun bitti."), 18, TEXT))
	box.add_child(_label("Son kasa %s · borç %s · makine %d" % [Data.usd(float(game.cash)), Data.usd(float(game.debt)), game.machines.size()], 14, MUTED))
	for lesson in game.lessons():
		box.add_child(_label("• " + lesson, 13, TEXT))
	box.add_child(_button("Yeniden başla", _restart, true, false, true))

func _ask_wipe() -> void:
	_confirm("Kaydı sil", ["Kayıtlı oyun kalıcı olarak silinir ve yeni oyun başlar.", "Bu işlem geri alınamaz."], "Sil ve yeni oyun", _wipe_save)

func _wipe_save() -> void:
	SaveStore.erase()
	_reset_state()
	page = "ozet"
	detail = ""
	subtab["ozet"] = "genel"
	_say("Kayıt silindi; yeni oyun.")
	_render()

func _restart() -> void:
	SaveStore.erase()
	_reset_state()
	page = "ozet"
	detail = ""
	_render()

# ------------------------------------------------------------------ İşler

func _page_isler() -> void:
	if game.factory_id == "":
		_locked("İş teklifleri fabrikan olunca açılır.")
		return
	var doable := 0
	for offer in game.offers:
		if game.fit_block_reason(offer["id"]) == "":
			doable += 1
	_chips(content, [
		{"id": "tum", "title": "Tümü (%d)" % game.offers.size()},
		{"id": "yapabilir", "title": "Yapabileceklerim (%d)" % doable},
		{"id": "kabul", "title": "Kabul edilenler (%d)" % game.jobs.size()},
		{"id": "mail", "title": "Mailler (%d)" % _pending_mails()},
		{"id": "tedarik", "title": "Tedarikçiler"}],
		subtab["isler"], func(id: String) -> void:
			subtab["isler"] = id
			_render())
	var box := _card(content, "Üretilebilir kapasite (şu anki vardiyalarla)")
	var any := false
	for kind in Data.TYPES:
		var cap: float = game.effective_capacity(kind)
		if cap > 0.0:
			any = true
			_row(box, kind, "%s/ay" % _xfmt(cap), TEXT, 14)
	if not any:
		box.add_child(_label("Teslim alınmış tezgah yok; gelecekte başlayan işleri şimdiden kabul edebilirsin.", 13, MUTED))
	box.add_child(_label("Gerekli ekipman: %s · Teslim skoru %%%d" % ["tamam" if game.package_bought else "EKSİK", int(roundf(float(game.delivery_score) * 100.0))], 12, MUTED if game.package_bought else RED))
	if game.phase != "offers":
		content.add_child(_label("Rapor açık: iş kabulü yeni ayın başında yapılır. \"Yapabileceklerim\" makinelerine ve nakdine uyan ilanları sayar.", 12, GOLD))
	if subtab["isler"] == "tedarik":
		_page_suppliers()
		return
	if subtab["isler"] == "mail":
		_page_mails()
		return
	if subtab["isler"] == "kabul":
		if game.jobs.is_empty():
			content.add_child(_label("Henüz kabul edilmiş iş yok.", 14, MUTED))
		var finish: Dictionary = game.projection()
		for job in game.jobs:
			_job_card(job, int(finish.get(job["id"], 0)))
		return
	for offer in game.offers:
		var reason: String = game.accept_block_reason(offer["id"])
		if subtab["isler"] == "yapabilir" and game.fit_block_reason(offer["id"]) != "":
			continue
		_offer_card(offer, reason)

func _job_card(job: Dictionary, finish_month: int) -> void:
	var late: bool = finish_month == 0 or finish_month > int(job["due_month"])
	var card := _card(content, job["title"], RED if late and int(job["start_month"]) <= game.month else GREEN)
	_row(card, "Müşteri", job["customer"])
	var total: float = game.job_workload(job)
	var remaining: float = game.job_remaining(job)
	var stage := "Üretimde"
	var stage_color := GREEN
	if job["order"].is_empty():
		stage = "Hammadde bekleniyor (sipariş yok)"
		stage_color = RED
	elif int(job["order"]["arrive_month"]) > game.month:
		stage = "Hammadde yolda · Ay %d" % job["order"]["arrive_month"]
		stage_color = GOLD
	elif int(job["start_month"]) > game.month:
		stage = "Başlamadı · Ay %d" % job["start_month"]
		stage_color = GOLD
	_row(card, "Aşama", stage, stage_color)
	var wait_reason: String = game.job_wait_reason(job)
	if wait_reason != "":
		card.add_child(_label("Neden üretilmiyor: " + wait_reason, 12, GOLD))
	card.add_child(_bar(total - remaining, total))
	_row(card, "Kalan yük", "%s / %s" % [_xfmt(remaining), _xfmt(total)], TEXT, 14)
	for req in job["reqs"]:
		_row(card, "%s %s" % [Data.LEVELS[int(req["level"])], req["kind"]], "%s kaldı" % _xfmt(float(req["remaining"])), MUTED, 13)
	_row(card, "Teslim tarihi", Data.month_label(int(job["due_month"])), TEXT, 14)
	_row(card, "Tahmini bitiş", "Bu kapasiteyle yetişmiyor" if finish_month == 0 else Data.month_label(finish_month), RED if late else GREEN, 14)
	var order: Dictionary = job["order"]
	if order.is_empty():
		_row(card, "Hammadde", "Sipariş verilmedi", RED, 14)
		card.add_child(_button("Hammadde sipariş ver", _open_detail.bind("order", str(job["id"])), true))
	else:
		var supplier: Dictionary = Data.supplier_by_id(order["supplier"])
		var arrived: bool = int(order["arrive_month"]) <= game.month
		_row(card, "Hammadde", "%s · %s" % [supplier["name"], "geldi" if arrived else "Ay %d gelir" % order["arrive_month"]], GREEN if arrived else GOLD, 14)
		_row(card, "Ödeme", "ödendi" if order["paid"] else "Ay %d · %s" % [order["pay_month"], Data.usd(float(order["amount"]))], MUTED, 13)
		if order["delayed"]:
			card.add_child(_label("Tedarikçi bu siparişi geciktirdi (+1 ay).", 12, RED))
	_row(card, "Peşinat alındı", Data.usd(float(job["advance"])), MUTED, 13)
	_row(card, "Gelir (tesliminde)", Data.usd(float(job["revenue"])), GREEN, 14)
	var reason: String = game.abandon_block_reason(job["id"])
	card.add_child(_button("İşi bırak · ceza %s" % Data.usd(game.abandon_penalty(job)) if reason == "" else reason, _ask_abandon.bind(job["id"]), false, reason != ""))

func _ask_abandon(id: int) -> void:
	var job: Dictionary = game.job_by_id(id)
	if job.is_empty():
		return
	var paid: float = float(job["order"]["amount"]) if not job["order"].is_empty() and job["order"]["paid"] else 0.0
	_confirm("İşi bırak", [job["title"] + " · " + job["customer"],
		"Ceza: %s" % Data.usd(game.abandon_penalty(job)),
		"Peşinat iade edilir: %s" % Data.usd(float(job["advance"])),
		"Ödenen/siparişteki hammadde yanar (%s ödendi)." % Data.usd(paid),
		"Gelir yazılmaz; teslimat skoru düşer."], "İşi bırak", _abandon_job.bind(id), "Bu işlem geri alınamaz.")

func _abandon_job(id: int) -> void:
	var result: String = game.abandon_job(id)
	_say(game.notice if result == "" else result)
	_render()

func _offer_card(offer: Dictionary, reason: String) -> void:
	var box := _card(content, offer["title"], GREEN if reason == "" else BORDER)
	box.add_child(_label(offer["customer"], 12, MUTED))
	for req in offer["reqs"]:
		var have: bool = game.owns(req)
		_row(box, "%s %s" % [Data.LEVELS[int(req["level"])], req["kind"]], "%d parça × %s = %s%s" % [req["parts"], Data.mu_text(float(req["difficulty"])), _xfmt(float(req["workload"])), "" if have else "  (makine yok)"], TEXT if have else RED, 14)
	for req in offer["reqs"]:
		box.add_child(_label("%s: %s kg/parça · %.1f t %s çelik" % [req["kind"], str(req["weight"]).trim_suffix(".0"), float(req["tons"]), "nitelikli" if int(req["steel"]) > 1 else "standart"], 11, MUTED))
	_row(box, "Teslim süresi", "%d ay" % offer["months"])
	_row(box, "En erken üretim başlangıcı", "bu ay" if int(offer["start_delay"]) == 0 else "%d ay sonra" % offer["start_delay"], MUTED)
	box.add_child(_label("%s = Parça İşleme Katsayısı (yüksek = zor parça). İş yükü = parça × %s. Daha yüksek seviye tezgâh alt seviye işi de yapabilir (ama daha pahalıya)." % [Data.DIFFICULTY_SYMBOL, Data.DIFFICULTY_SYMBOL], 11, MUTED))
	if game.quote_mode:
		box.add_child(_label(Data.urgency_hint(offer), 12, MUTED))
		box.add_child(_button("Teklif ver" if reason == "" else reason, _open_detail.bind("quote", str(offer["id"])), reason == "", reason != ""))
		return
	_row(box, "Gelir", Data.usd(float(offer["revenue"])), GREEN)
	_row(box, "Peşinat (%%%d, kabulde gelir)" % int(Data.ADVANCE_RATE * 100.0), Data.usd(game.advance_of(offer)), GREEN, 14)
	_row(box, "Tahmini hammadde (%%%d)" % int(roundf(float(offer["share"]) * 100.0)), Data.usd(float(offer["material"])), TEXT, 14)
	box.add_child(_button("Kabul et" if reason == "" else reason, _ask_accept.bind(offer["id"]), reason == "", reason != ""))

func _ask_accept(id: int) -> void:
	var offer: Dictionary = game.offer_by_id(id)
	if offer.is_empty():
		return
	var reqs_text: Array = []
	for req in offer["reqs"]:
		reqs_text.append("%s %s: %s" % [Data.LEVELS[int(req["level"])], req["kind"], _xfmt(float(req["workload"]))])
	var lines: Array = [
		offer["title"] + " · " + offer["customer"],
		"Yük: " + ", ".join(reqs_text),
		"Teslim süresi: %d ay (üretim en erken: %s)" % [offer["months"], "bu ay" if int(offer["start_delay"]) == 0 else "%d ay sonra" % offer["start_delay"]],
		"Kabulde gelen peşinat: %s" % Data.usd(game.advance_of(offer)),
		"Teslimde kalan bakiye: %s" % Data.usd(float(offer["revenue"]) - game.advance_of(offer)),
	]
	if game.auto_order:
		var quote: Dictionary = game.material_quote(offer, game.default_supplier)
		lines.append("Hammadde: %s'ten %s, %d ay sonra gelir, ödeme %s." % [quote["supplier"]["name"], Data.usd(float(quote["amount"])), quote["lead"], "peşin" if int(quote["terms"]) == 0 else "%d ay sonra" % quote["terms"]])
	else:
		lines.append("Hammaddeyi sen sipariş edeceksin.")
	_confirm("İşi kabul et", lines, "Kabul et", _accept_offer.bind(id), "Bırakırsan peşinat iade edilir ve ceza ödersin; geç teslim skoru düşürür.")

func _accept_offer(id: int) -> void:
	var result: String = game.accept_offer(id)
	if result != "":
		_say(result)
	_render()

# ------------------------------------------------------------------ Teklif

func _pending_mails() -> int:
	var count := 0
	for mail in game.mails:
		if mail["status"] == "counter":
			count += 1
	return count

func _open_quote(offer_id: int) -> void:
	var offer: Dictionary = game.offer_by_id(offer_id)
	if offer.is_empty():
		return
	quote_margin = 0.30
	quote_edit = {}
	quote_adv = 30
	quote_months = int(offer["months"])

func _stepper(parent: Control, label_text: String, value_text: String, edit_index: int, key: String, step: float, changed := false) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var label := _label(label_text, 14, GOLD if changed else TEXT)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var minus := _button("−", _edit_cost.bind(edit_index, key, -step))
	minus.custom_minimum_size = Vector2(44, 40)
	row.add_child(minus)
	var value := _label(value_text, 14, GOLD if changed else TEXT)
	value.custom_minimum_size = Vector2(96, 0)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(value)
	var plus := _button("+", _edit_cost.bind(edit_index, key, step))
	plus.custom_minimum_size = Vector2(44, 40)
	row.add_child(plus)
	parent.add_child(row)

func _edit_cost(index: int, key: String, delta: float) -> void:
	var edit: Dictionary = quote_edit.get(index, {})
	edit[key] = float(edit.get(key, 0.0)) + delta
	quote_edit[index] = edit
	_render()

func _detail_quote() -> void:
	var offer: Dictionary = game.offer_by_id(int(detail_arg))
	if offer.is_empty():
		content.add_child(_label("Bu ilan artık yok.", 14, MUTED))
		return
	if quote_months == 0:
		_open_quote(int(detail_arg))
	var head := _card(content, offer["title"], GOLD, true)
	head.add_child(_label(offer["customer"], 13, MUTED))
	head.add_child(_label(Data.urgency_hint(offer), 12, GOLD))
	for req in offer["reqs"]:
		_row(head, "%s %s" % [Data.LEVELS[int(req["level"])], req["kind"]], "%d parça × %s = %s" % [req["parts"], Data.mu_text(float(req["difficulty"])), _xfmt(float(req["workload"]))], TEXT, 14)
	head.add_child(_label("%s = Parça İşleme Katsayısı (yüksek = zor parça). İş yükü = parça × %s." % [Data.DIFFICULTY_SYMBOL, Data.DIFFICULTY_SYMBOL], 11, MUTED))
	_row(head, "Müşterinin istediği teslim", "%d ay" % offer["months"], TEXT, 14)
	var estimate: Dictionary = game.cost_estimate(offer, quote_edit)
	quote_price = ceilf(float(estimate["total"]) * (1.0 + quote_margin))
	var box := _card(content, "Teklifin", GREEN, true)
	_row(box, "Fiyat", Data.usd(quote_price), GREEN, 20)
	_row(box, "Toplam maliyet (ayrıntı aşağıda)", Data.usd(float(estimate["total"])), MUTED, 13)
	_row(box, "Kâr marjı (toplam maliyete göre)", "%%%d" % int(roundf(quote_margin * 100.0)), TEXT if quote_margin >= 0.0 else RED, 15)
	var steps := HBoxContainer.new()
	steps.add_theme_constant_override("separation", 6)
	for delta in [-0.05, -0.01, 0.01, 0.05]:
		var button := _button("%s%%%d" % ["+" if delta > 0 else "−", int(absf(delta) * 100.0)], _bump_price.bind(delta))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		steps.add_child(button)
	box.add_child(steps)
	box.add_child(_label("Peşinat", 13, MUTED))
	var adv_options: Array = []
	for pct in [20, 30, 40, 50]:
		adv_options.append({"id": str(pct), "title": "%%%d" % pct})
	_chips(box, adv_options, str(quote_adv), func(id: String) -> void:
		quote_adv = int(id)
		_render())
	box.add_child(_label("Teslim süresi", 13, MUTED))
	var time_options: Array = []
	for m in [int(offer["months"]) - 1, int(offer["months"]), int(offer["months"]) + 1]:
		if m >= 1:
			time_options.append({"id": str(m), "title": "%d ay" % m})
	_chips(box, time_options, str(quote_months), func(id: String) -> void:
		quote_months = int(id)
		_render())
	box.add_child(_label("Daha hızlı teslim fiyat toleransını biraz artırır, daha yavaş düşürür; yüksek peşinat düşürür. Teslimat skorun (%%%d) de etkiler." % int(roundf(float(game.delivery_score) * 100.0)), 12, MUTED))
	var reason: String = game.quote_block_reason(int(detail_arg), quote_price)
	box.add_child(_button("Teklifi gönder" if reason == "" else reason, _send_quote.bind(int(detail_arg)), reason == "", reason != "", true))

	content.add_child(_label("Maliyet ayrıntısı: hurda, genel gider ve personel varsayımlarını değiştirebilirsin; fiyat toplam maliyete göre güncellenir.", 12, MUTED))
	var material_card := _card(content, "Hammadde", BORDER)
	_row(material_card, "Hammadde (%s)" % Data.supplier_by_id(game.default_supplier)["name"], Data.usd(float(estimate["material"])), TEXT, 14)
	material_card.add_child(_label("Hammadde maliyeti değiştirilemez; tedarikçiyi İşler > Tedarikçiler'den seçersin.", 11, MUTED))
	var lines: Array = estimate["lines"]
	for i in lines.size():
		var line: Dictionary = lines[i]
		var edit: Dictionary = quote_edit.get(i, {})
		var card := _card(content, "%s %s tezgahı · %d makine × %d ay" % [Data.LEVELS[int(line["level"])], line["kind"], int(line["count"]), int(offer["duration"])], BORDER)
		_stepper(card, "Hurda giderleri", "%%%.0f · %s" % [float(line["scrap_rate_used"]) * 100.0, Data.usd(float(line["scrap"]))], i, "scrap_pt", 1.0, edit.has("scrap_pt") and float(edit["scrap_pt"]) != 0.0)
		var span: Array = line["scrap_range"]
		card.add_child(_label("Bu tür iş için olağan aralık %%%d–%%%d (ortalama %%%.1f); oran, parçaya dönüşen malzeme üzerinden hesaplanır (çapak ve talaş hammadde fiyatındadır); işi alınca gerçek oran bu aralıkta çıkar ve ay sonunda üretilen miktara göre kasadan düşer. Tahmini düşürmek fiyatı indirir, gerçek hurda aynı kalır." % [int(roundf(float(span[0]) * 100.0)), int(roundf(float(span[1]) * 100.0)), float(line["scrap_rate"]) * 100.0], 11, MUTED))
		_stepper(card, "Genel giderler (kira, kredi, enerji)", Data.usd(float(line["overhead"])), i, "overhead_pct", 10.0, edit.has("overhead_pct") and float(edit["overhead_pct"]) != 0.0)
		_stepper(card, "Amortisman (bedel ÷ %d ay)" % Data.AMORT_MONTHS, Data.usd(float(line["amortization"])), i, "amortization_pct", 10.0, edit.has("amortization_pct") and float(edit["amortization_pct"]) != 0.0)
		if int(line["serving_level"]) > int(line["level"]):
			card.add_child(_label("Bu işi %s tezgâhın yapar: daha pahalı enerji, personel ve amortisman. Alt seviye tezgâh kullanmak daha ucuzdur." % Data.LEVELS[int(line["serving_level"])], 11, GOLD))
		_stepper(card, "Sarf malzeme (maliyetin %%%.1f'i)" % (Data.CONSUMABLE_SHARE * 100.0), Data.usd(float(line["consumables"])), i, "consumables_pct", 10.0, edit.has("consumables_pct") and float(edit["consumables_pct"]) != 0.0)
		_stepper(card, "Personel giderleri", Data.usd(float(line["personnel"])), i, "personnel_pct", 10.0, edit.has("personnel_pct") and float(edit["personnel_pct"]) != 0.0)
		_row(card, "Tezgah maliyeti", Data.usd(float(line["subtotal"])), GREEN, 15)
	var totals := _card(content, "Toplam maliyet", BORDER)
	_row(totals, "Hammadde + tezgah maliyetleri", Data.usd(float(estimate["total"])), GREEN, 17)
	if float(estimate["total"]) < float(estimate["base_total"]) - 0.5:
		totals.add_child(_label("Varsayımların gerçek tahminin %s altında; fark senin cebinden çıkar." % Data.usd(float(estimate["base_total"]) - float(estimate["total"])), 12, RED))

func _bump_price(delta: float) -> void:
	quote_margin = snappedf(quote_margin + delta, 0.01)
	_render()

func _send_quote(offer_id: int) -> void:
	var result: Dictionary = game.submit_quote(offer_id, quote_price, quote_adv, quote_months)
	quote_months = 0
	if not result["ok"]:
		_say(result["reason"])
		_render()
		return
	detail = ""
	page = "isler"
	subtab["isler"] = "mail" if result["status"] != "accepted" else "kabul"
	_say({"accepted": "Teklif kabul edildi.", "counter": "Müşteri karşı teklif gönderdi; Mailler'e bak.", "rejected": "Teklif reddedildi; nedeni Mailler'de."}[result["status"]])
	_render()

func _page_mails() -> void:
	if game.mails.is_empty():
		content.add_child(_label("Henüz yazışma yok. Bir ilana teklif verince müşteri burada yanıt verir.", 14, MUTED))
		return
	for mail in game.mails:
		var colors := {"accepted": GREEN, "counter": GOLD, "rejected": RED, "declined": MUTED, "expired": MUTED}
		var box := _card(content, "%s · %s" % [mail["title"], mail["customer"]], colors.get(mail["status"], BORDER))
		box.add_child(_label({"accepted": "Kabul", "counter": "Yanıt bekliyor", "rejected": "Reddedildi", "declined": "Siz reddettiniz", "expired": "Süresi doldu"}[mail["status"]] + " · Ay %d" % mail["month"], 12, colors.get(mail["status"], MUTED)))
		for line in mail["lines"]:
			box.add_child(_label(str(line), 13, TEXT))
		if mail["status"] == "counter":
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 10)
			var yes := _button("Evet", _answer_counter.bind(mail["id"], true), true, game.phase != "offers")
			var no := _button("Hayır", _answer_counter.bind(mail["id"], false), false, game.phase != "offers")
			yes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(yes)
			row.add_child(no)
			box.add_child(row)

func _answer_counter(mail_id: int, yes: bool) -> void:
	var result: String = game.answer_counter(mail_id, yes)
	if result != "":
		_say(result)
	_render()

# ------------------------------------------------------------------ Tedarik

func _supplier_card(supplier: Dictionary, quote: Dictionary, job_id := 0) -> void:
	var is_default: bool = supplier["id"] == game.default_supplier
	var card := _card(content, supplier["name"] + ("  (varsayılan)" if is_default and job_id == 0 else ""), GREEN if is_default and job_id == 0 else BORDER, true)
	card.add_child(_label(supplier["note"], 13, MUTED))
	if not quote.is_empty():
		_row(card, "Hammadde bedeli", Data.usd(float(quote["amount"])), TEXT, 16)
		_row(card, "Gelir", "Ay %d" % (game.month + int(quote["lead"])), TEXT, 15)
	_row(card, "Fiyat", "%%%d" % int(roundf(float(supplier["price"]) * 100.0)), GREEN if float(supplier["price"]) < 1.0 else RED if float(supplier["price"]) > 1.0 else TEXT, 15)
	_row(card, "Temin süresi", "%d ay" % supplier["lead"], TEXT, 15)
	_row(card, "Ödeme", "peşin" if int(supplier["terms"]) == 0 else "%d ay vadeli" % supplier["terms"], TEXT, 15)
	_row(card, "Gecikme riski", "%%%d (+1 ay)" % int(roundf(float(supplier["delay"]) * 100.0)), TEXT, 15)
	_row(card, "Kalite", "%s (verim %%%.1f)" % [Data.QUALITY_NAMES[int(supplier["quality"])], float(Data.QUALITY_YIELD[int(supplier["quality"])]) * 100.0], TEXT, 15)
	if job_id != 0:
		var reason: String = game.order_block_reason(job_id, supplier["id"])
		card.add_child(_button("Sipariş ver" if reason == "" else reason, _order_material.bind(job_id, supplier["id"]), reason == "", reason != "", true))
	else:
		card.add_child(_button("Varsayılan yap" if not is_default else "Varsayılan", _set_default_supplier.bind(supplier["id"]), false, is_default))

func _page_suppliers() -> void:
	var box := _card(content, "Hammadde tedarikçileri")
	box.add_child(_label("Hammadde, işin üretimi başlamadan gelmelidir. Uzun vadeli ve ucuz tedarikçi yavaş ve riskli; peşin tedarikçi pahalı ama hızlı ve kaliteli.", 12, MUTED))
	var auto := CheckBox.new()
	auto.text = "Kabulde varsayılan tedarikçiden otomatik sipariş ver"
	auto.add_theme_font_size_override("font_size", 14)
	auto.custom_minimum_size = Vector2(0, 48)
	auto.button_pressed = game.auto_order
	auto.toggled.connect(_toggle_auto_order)
	box.add_child(auto)
	for supplier in Data.SUPPLIERS:
		_supplier_card(supplier, {})

func _toggle_auto_order(on: bool) -> void:
	game.auto_order = on
	_render()

func _set_default_supplier(id: String) -> void:
	game.default_supplier = id
	_render()

func _order_material(job_id: int, supplier_id: String) -> void:
	var result: String = game.order_material(job_id, supplier_id)
	if result != "":
		_say(result)
	detail = ""
	_render()

func _detail_order() -> void:
	var job: Dictionary = game.job_by_id(int(detail_arg))
	if job.is_empty():
		content.add_child(_label("İş bulunamadı.", 14, MUTED))
		return
	var head := _card(content, "Hammadde siparişi", GOLD)
	head.add_child(_label("%s · işin en erken başlangıcı Ay %d, teslim tarihi Ay %d. Hammadde ondan önce gelmezse üretim başlamaz." % [job["title"], job["start_month"], job["due_month"]], 13, MUTED))
	for supplier in Data.SUPPLIERS:
		_supplier_card(supplier, game.material_quote(job, supplier["id"]), int(job["id"]))

# ------------------------------------------------------------------ Tezgah

func _page_tezgah() -> void:
	if game.factory_id == "":
		_locked("Tezgah almak için önce bir yer kiralamalısın; makineler alan tüketir.")
		return
	_build_area_bar()
	_chips(content, [{"id": "tezgah", "title": "Tezgahlar"}, {"id": "ekipman", "title": "Ekipman"}],
		subtab["tezgah"], func(id: String) -> void:
			subtab["tezgah"] = id
			selected_listing = -1
			_render())
	if subtab["tezgah"] == "ekipman":
		_page_equipment()
		return
	var type_options: Array = [{"id": "Tümü", "title": "Tümü"}]
	for kind in Data.TYPES:
		type_options.append({"id": kind, "title": kind})
	_chips(content, type_options, type_filter, func(id: String) -> void:
		type_filter = id
		selected_listing = -1
		_render())
	for listing in Data.machine_listings():
		if type_filter != "Tümü" and listing["kind"] != type_filter:
			continue
		_machine_card(listing)
	_update_area_preview()

func _build_area_bar() -> void:
	var factory: Dictionary = game.factory()
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _box(Color("#151d26"), BORDER, 0, 0))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(_margin(box, 16, 8))
	area_label = _label("", 13, MUTED)
	box.add_child(area_label)
	var stack := Control.new()
	stack.custom_minimum_size = Vector2(0, 12)
	area_preview_bar = _bar(0, float(factory["m2"]), YELLOW)
	area_preview_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	area_used_bar = _bar(game.area_used(), float(factory["m2"]), GREEN)
	area_used_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	area_used_bar.add_theme_stylebox_override("background", StyleBoxEmpty.new())
	stack.add_child(area_preview_bar)
	stack.add_child(area_used_bar)
	box.add_child(stack)
	sticky.add_child(panel)
	_update_area_preview()

# Sticky bar: green = used area, yellow = area the hovered or selected card would add.
func _update_area_preview(hover_area := -1.0) -> void:
	if area_label == null:
		return
	var factory: Dictionary = game.factory()
	var extra := hover_area
	if extra < 0.0:
		extra = 0.0
		if selected_listing >= 0:
			var chosen: Dictionary = game.listing_by_uid(selected_listing)
			if not chosen.is_empty():
				extra = float(chosen["area"])
	var used: float = game.area_used()
	area_used_bar.value = used
	area_preview_bar.value = used + extra
	var text := "Alan: %d / %d m² kullanılıyor · tavan %.1f m" % [int(used), factory["m2"], factory["height"]]
	if extra > 0.0:
		text += "  (+%d m² → %d m²)" % [int(extra), int(used + extra)]
	area_label.text = text
	area_label.add_theme_color_override("font_color", YELLOW if extra > 0.0 else MUTED)

func _machine_card(listing: Dictionary) -> void:
	var selected: bool = listing["uid"] == selected_listing
	var box := _card(content, "", GOLD if selected else BORDER, true)
	var panel := _panel_of(box)
	listing_cards[listing["uid"]] = panel
	box.add_child(_image_slot("machines", "%s_%d" % [Art.slug(listing["kind"]), listing["level"]], Color("#26313d")))
	box.add_child(_label(listing["model"], 22, TEXT))
	var age_text := "Yeni (sıfır)" if int(listing["age"]) == 0 else "İkinci el · %d yaşında" % listing["age"]
	box.add_child(_label("%s · %s · %s" % [listing["kind"], Data.LEVELS[int(listing["level"])], age_text], 15, MUTED))
	box.add_child(_label("Mevcut: %d ad (%s %s)" % [game.machines_owned(listing["kind"], int(listing["level"])), Data.LEVELS[int(listing["level"])], listing["kind"]], 13, GOLD if game.machines_owned(listing["kind"], int(listing["level"])) > 0 else MUTED))
	if float(listing["discount"]) > 0.0:
		box.add_child(_rich("[s][color=#93a3b3]%s[/color][/s]  [color=#3ddc84][b]%s[/b][/color]  [color=#eac47a](-%%%d)[/color]" % [
			Data.usd(float(listing["base_price"])), Data.usd(float(listing["price"])), int(roundf(float(listing["discount"]) * 100.0))], 22))
	else:
		box.add_child(_rich("[b]%s[/b]" % Data.usd(float(listing["price"])), 22))
	_row(box, "Teorik kapasite", "%s/ay (3 vardiya)" % _xfmt(float(listing["nameplate"])), TEXT, 16)
	_row(box, "Performans / hurda", "%%%d · %%%.1f" % [int(roundf(float(listing["perf"]) * 100.0)), float(listing["scrap"]) * 100.0], TEXT, 16)
	_row(box, "Tek vardiya etkin", "≈ %s/ay" % _xfmt(float(listing["nameplate"]) / 3.0 * float(listing["perf"]) * (1.0 - float(listing["scrap"]))), GREEN, 16)
	_row(box, "Alan / yükseklik", "%d m² · %.1f m" % [listing["area"], listing["height"]], TEXT, 16)
	_row(box, "Enerji", "%d kW · %s/ay" % [listing["kw"], Data.usd(float(listing["energy"]))], TEXT, 16)
	_row(box, "Personel", "%d kişi (teslimde işe başlar)" % listing["personnel"], TEXT, 16)
	_row(box, "Teslim", "%d ay" % listing["delivery"], TEXT, 16)
	_row(box, "Bakım riski (yaş)", Data.maintenance_risk(int(listing["age"])), TEXT, 16)
	var reason: String = game.listing_block_reason(listing["uid"])
	box.add_child(_button("Satın al" if reason == "" else reason, _ask_buy.bind(listing["uid"]), reason == "", reason != "", true))
	if not OS.has_feature("mobile"):
		panel.mouse_entered.connect(func() -> void: _update_area_preview(float(listing["area"])))
		panel.mouse_exited.connect(func() -> void: _update_area_preview())
	panel.gui_input.connect(_on_card_input.bind(listing["uid"]))

# A tap selects; a drag (scrolling) does not.
func _is_tap(event: InputEvent) -> bool:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			press_pos = event.global_position
		else:
			return event.global_position.distance_to(press_pos) < 12.0
	return false

func _on_card_input(event: InputEvent, uid: int) -> void:
	if _is_tap(event):
		selected_listing = uid
		for id in listing_cards:
			var panel: PanelContainer = listing_cards[id]
			panel.add_theme_stylebox_override("panel", _box(Color(PANEL.r, PANEL.g, PANEL.b, 0.94), GOLD if id == uid else BORDER, 14, 2))
		_update_area_preview()

func _ask_buy(uid: int) -> void:
	var listing: Dictionary = game.listing_by_uid(uid)
	if listing.is_empty():
		return
	var arrive: int = int(game.month) + int(listing["delivery"])
	_confirm("Satın alma onayı", [
		"%s · %s %s" % [listing["model"], Data.LEVELS[int(listing["level"])], listing["kind"]],
		"Ödeme şimdi: %s" % Data.usd(float(listing["price"])),
		"Teslim: %d ay sonra (%s). Teslime kadar kapasite artmaz." % [listing["delivery"], Data.month_label(arrive)],
		"Teslimde %d personel otomatik işe başlar (kişi başı %s/ay)." % [listing["personnel"], Data.usd(Data.wage_for(listing["kind"]))],
		"Aylık işletme: %s enerji + %s sarf" % [Data.usd(float(listing["energy"])), Data.usd(float(listing["consumables"]))],
		"Alan: %d m²" % listing["area"]
	], "Satın al", _buy.bind(uid))

func _buy(uid: int) -> void:
	var result: String = game.buy_listing(uid)
	if result != "":
		_say(result)
	selected_listing = -1
	_render()

# ------------------------------------------------------------------ Ekipman

func _page_equipment() -> void:
	var package: Dictionary = game.package_info()
	var box := _card(content, "Gerekli ekipman seti" + (" ✔" if game.package_bought else ""), GREEN if game.package_bought else GOLD, true)
	box.add_child(_label("Üretim yapabilmek için şart. Eksikse kapasite kullanılamaz.", 14, MUTED))
	for id in package["items"]:
		var item: Dictionary = Data.EQUIPMENT[id]
		_row(box, "%s × %d" % [item["name"], package["items"][id]], Data.usd(float(item["price"]) * int(package["items"][id])), TEXT, 15)
	_row(box, "Alan", "%d m²" % int(package["area"]), TEXT, 15)
	_row(box, "Set fiyatı", Data.usd(float(package["price"])), GREEN, 17)
	var reason: String = game.package_block_reason()
	box.add_child(_button("Seti satın al" if reason == "" else reason, _ask_package, reason == "", reason != "", true))
	content.add_child(_label("İsteğe bağlı ekipman", 20, TEXT))
	content.add_child(_label("Kesici uç ve takım sarfı tezgahın aylık işletme giderine dahildir.", 12, MUTED))
	for id in Data.OPTIONAL_ORDER:
		_equipment_card(id)

func _equipment_card(id: String) -> void:
	var item: Dictionary = Data.EQUIPMENT[id]
	var qty: int = equip_qty.get(id, 1)
	var box := _card(content, "%s  (Mevcut: %d ad)" % [item["name"], game.equipment_owned(id)], BORDER, true)
	box.add_child(_label(item["note"], 13, MUTED))
	_row(box, "Birim fiyat", Data.usd(float(item["price"])), TEXT, 16)
	_row(box, "Alan / adet", "%.1f m²" % float(item["area"]) if float(item["area"]) > 0.0 else "Alan tüketmez", TEXT, 16)
	var stepper := HBoxContainer.new()
	stepper.add_theme_constant_override("separation", 10)
	stepper.add_child(_button("−", _change_qty.bind(id, -1)))
	var count := _label(str(qty), 20, TEXT, false)
	count.custom_minimum_size = Vector2(60, 0)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stepper.add_child(count)
	stepper.add_child(_button("+", _change_qty.bind(id, 1)))
	box.add_child(stepper)
	var reason: String = game.equipment_block_reason(id, qty)
	box.add_child(_button("Satın al · %s" % Data.usd(float(item["price"]) * qty) if reason == "" else reason, _ask_equipment.bind(id), reason == "", reason != "", true))

func _change_qty(id: String, delta: int) -> void:
	equip_qty[id] = maxi(1, int(equip_qty.get(id, 1)) + delta)
	_render()

func _ask_package() -> void:
	var package: Dictionary = game.package_info()
	_confirm("Gerekli seti al", ["Ödeme: %s" % Data.usd(float(package["price"])), "Kaplanan alan: %d m²" % int(package["area"])], "Satın al", _buy_package)

func _buy_package() -> void:
	var result: String = game.buy_package()
	if result != "":
		_say(result)
	_render()

func _ask_equipment(id: String) -> void:
	var item: Dictionary = Data.EQUIPMENT[id]
	var qty: int = equip_qty.get(id, 1)
	_confirm("Ekipman satın al", ["%s × %d" % [item["name"], qty], "Ödeme: %s" % Data.usd(float(item["price"]) * qty)], "Satın al", _buy_equipment.bind(id, qty))

func _buy_equipment(id: String, qty: int) -> void:
	var result: String = game.buy_equipment(id, qty)
	if result != "":
		_say(result)
	equip_qty[id] = 1
	_render()

# ------------------------------------------------------------------ Fabrika

func _page_fabrika() -> void:
	if game.factory_id != "" and subtab["fabrika"] == "vardiya":
		_page_shifts()
		return
	if game.factory_id != "":
		var factory: Dictionary = game.factory()
		var box := _card(content, "Kiraladığın yer", GREEN, true)
		box.add_child(_image_slot("factories", factory["id"], factory["tint"]))
		_row(box, "Fabrika", factory["name"], TEXT, 16)
		_row(box, "Alan / yükseklik", "%d m² · %.1f m" % [factory["m2"], factory["height"]], TEXT, 16)
		_row(box, "Aylık kira", Data.usd(game.base_rent()), TEXT, 16)
		_row(box, "Sözleşme", "%d ay · %d ay kaldı" % [game.term, game.months_left], TEXT, 16)
		if int(game.prepaid_months) > 0:
			_row(box, "Peşin ödenmiş kira", "%d ay" % game.prepaid_months, GREEN, 16)
		box.add_child(_button("Sözleşmeyi bırak", _open_detail.bind("leave"), false, false, true))
		content.add_child(_label("İlk dilimde tek fabrika var; başka bir yer için önce bu sözleşme bırakılır.", 12, MUTED))
		return
	content.add_child(_label("Kiralık yerler", 22, TEXT))
	for factory in Data.FACTORIES:
		var box := _card(content, factory["name"], BORDER, true)
		box.add_child(_image_slot("factories", factory["id"], factory["tint"]))
		_row(box, "Bölge", factory["region"], TEXT, 16)
		_row(box, "Alan", "%d m²" % factory["m2"], TEXT, 16)
		_row(box, "Tavan yüksekliği", "%.1f m" % factory["height"], TEXT, 16)
		_row(box, "Aylık kira (Sözleşme: 12 Ay)", Data.usd(float(factory["rent"])), GREEN, 18)
		box.add_child(_button("İncele", _open_detail.bind("factory", factory["id"]), true, false, true))

# ------------------------------------------------------------------ Vardiya

func _page_shifts() -> void:
	var editable: bool = game.phase == "offers"
	var box := _card(content, "Vardiya planı", GREEN, true)
	box.add_child(_label("Plan tüm tezgahlar için geçerlidir. 1. vardiya her zaman açıktır. Mesai bir vardiyaya +4 saat ekler, saatlik ücret 1,5 katıdır; üç vardiyada mesai olmaz.", 12, MUTED))
	if not editable:
		box.add_child(_label("Vardiya ve mesai ay başında (rapordan önce) değiştirilir.", 12, GOLD))
	for n in [1, 2, 3]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var tick := CheckBox.new()
		tick.text = "Vardiya %d" % n
		tick.add_theme_font_size_override("font_size", 15)
		tick.custom_minimum_size = Vector2(0, 48)
		tick.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tick.button_pressed = game.plan_shifts >= n
		tick.disabled = n == 1 or not editable
		tick.toggled.connect(_on_shift_tick.bind(n))
		row.add_child(tick)
		var overtime := CheckBox.new()
		overtime.text = "Mesai (+4 sa)"
		overtime.add_theme_font_size_override("font_size", 14)
		overtime.custom_minimum_size = Vector2(0, 48)
		overtime.button_pressed = bool(game.plan_ot[n - 1])
		overtime.disabled = not editable or n > game.plan_shifts or game.plan_shifts >= 3
		overtime.toggled.connect(_on_overtime_tick.bind(n))
		row.add_child(overtime)
		box.add_child(row)
	var patron := CheckBox.new()
	patron.text = "Patron operatörlük yapar"
	patron.add_theme_font_size_override("font_size", 15)
	patron.custom_minimum_size = Vector2(0, 52)
	patron.button_pressed = game.plan_patron
	patron.disabled = not editable
	patron.toggled.connect(_on_patron_tick)
	box.add_child(patron)
	box.add_child(_label("Patron tek operatörlü bir tezgahın 1. vardiyasını kendisi çalıştırır (otomatik atanır); o tezgahta 2 vardiya için tek personel yeter. Yönetim saatinden %d sa harcar." % game.patron_hours(), 12, MUTED))
	var care := _card(content, "Personel politikası (yemek, servis…)", BORDER)
	care.add_child(_label("Kişi başı aylık yan gider. Güçlü politika, insanla ilgili sorunların başlamadan önlenme şansını artırır.", 12, MUTED))
	var care_options: Array = []
	for i in Data.STAFF_POLICIES.size():
		var policy: Dictionary = Data.STAFF_POLICIES[i]
		care_options.append({"id": str(i), "title": "%s · %s" % [policy["name"], Data.usd(float(policy["cost"]))]})
	_chips(care, care_options, str(game.staff_policy), func(id: String) -> void:
		var result: String = game.set_staff_policy(int(id))
		if result != "":
			_say(result)
		_render())
	care.add_child(_label("%s Önleme şansı +%%%d puan." % [Data.STAFF_POLICIES[game.staff_policy]["note"], int(roundf(float(Data.STAFF_POLICIES[game.staff_policy]["bonus"]) * 100.0))], 12, MUTED))
	var summary := _card(content, "Sonuç", BORDER)
	_row(summary, "Personel (otomatik istihdam)", "%d kişi" % game.staff_count(), TEXT, 15)
	var wages := 0.0
	for machine in game.delivered():
		wages += game.machine_wages(machine)
	_row(summary, "Aylık personel gideri", Data.usd(wages), TEXT, 15)
	_row(summary, "Dolaylı personel", "%d kişi · %s" % [game.indirect_count(), Data.usd(game.indirect_cost())], TEXT, 15)
	_row(summary, "Ofis kadrosu", "%d kişi · %s" % [game.office_roles().size(), Data.usd(game.office_cost())], TEXT, 15)
	_row(summary, "Üretilebilir kapasite", "%s/ay" % _xfmt(game.effective_capacity()), GREEN, 15)
	summary.add_child(_label("Personel, makineler teslim alındığında kadroya girer; vardiya artınca otomatik işe alınır.", 12, MUTED))

func _on_shift_tick(on: bool, n: int) -> void:
	_apply_plan(n if on else n - 1, game.plan_ot.duplicate(), game.plan_patron)

func _on_overtime_tick(on: bool, n: int) -> void:
	var overtime: Array = game.plan_ot.duplicate()
	overtime[n - 1] = on
	_apply_plan(game.plan_shifts, overtime, game.plan_patron)

func _on_patron_tick(on: bool) -> void:
	_apply_plan(game.plan_shifts, game.plan_ot.duplicate(), on)

func _apply_plan(shifts: int, overtime: Array, patron: bool) -> void:
	var result: String = game.set_plan(shifts, overtime, patron)
	if result != "":
		_say(result)
	_render()

# ------------------------------------------------------------------ Profil

func _page_profil() -> void:
	var sound := _card(content, "Ses")
	for entry in [["Müzik", audio.music_on, audio.set_music], ["Ses efektleri", audio.sfx_on, audio.set_sfx], ["Titreşim (telefon)", audio.haptics_on, audio.set_haptics]]:
		var tick := CheckBox.new()
		tick.text = entry[0]
		tick.add_theme_font_size_override("font_size", 15)
		tick.custom_minimum_size = Vector2(0, 48)
		tick.button_pressed = entry[1]
		tick.toggled.connect(entry[2])
		sound.add_child(tick)
	sound.add_child(_label("Müzik dosyası: godot/audio/music/main.ogg (yoksa sessiz). Efektler kodla üretilir.", 11, MUTED))
	var skills := _card(content, "Yetkinlikler")
	for name in BossState.SKILLS:
		var row := HBoxContainer.new()
		row.add_child(_label(name, 13, MUTED))
		var effective: int = game.effective_skill(name)
		var own: int = game.skills[name]
		row.add_child(_label(str(own) if effective == own else "%d → %d (danışman)" % [own, effective], 13, TEXT if effective == own else GREEN, false))
		skills.add_child(row)
		skills.add_child(_bar(float(effective), 100.0))
	var stats := _card(content, "Statlar")
	for stat in Data.STATS_LIST:
		_row(stats, stat, "—")
	stats.add_child(_label("Statlar yetkinlik puanı vermez (FRZ-007 v3). Personel niteliği ve eğitimi şimdilik kapsam dışı (not).", 12, MUTED))
	var actions := _card(content, "Yönetim")
	actions.add_child(_button("Danışman Ara", _open_detail.bind("consultant")))
	actions.add_child(_button("Kredi", _open_detail.bind("credit")))
	var save := _card(content, "Kayıt")
	save.add_child(_label("Oyun her adımda otomatik kaydedilir." if SaveStore.active() else "Bu ortamda kayıt kapalı.", 13, MUTED))
	save.add_child(_button("Kaydı sil ve yeni oyun", _ask_wipe, false, not SaveStore.active() and game.phase == "setup"))

# ------------------------------------------------------------------ detail screens

func _render_detail() -> void:
	var top := HBoxContainer.new()
	var back := _button("‹ Geri", _back)
	back.custom_minimum_size = Vector2(96, 44)
	top.add_child(back)
	var title := _label("", 18, TEXT)
	top.add_child(title)
	content.add_child(top)
	match detail:
		"factory":
			var factory := Data.factory_by_id(detail_arg)
			title.text = "  " + String(factory["name"])
			_detail_factory(factory)
		"leave":
			title.text = "  Sözleşmeyi bırak"
			_detail_leave()
		"consultant":
			title.text = "  Danışman Ara"
			_detail_consultants()
		"credit":
			title.text = "  Kredi"
			_detail_credit()
		"machines":
			title.text = "  Makineler"
			_detail_machines()
		"oee":
			title.text = "  OEE ve kapasite"
			_detail_oee()
		"costs":
			title.text = "  Aylık gider"
			_detail_costs()
		"order":
			title.text = "  Hammadde"
			_detail_order()
		"quote":
			title.text = "  Teklif"
			_detail_quote()

func _detail_factory(factory: Dictionary) -> void:
	var hero := _card(content, "", BORDER, true)
	hero.add_child(_image_slot("factories", factory["id"], factory["tint"], 270))
	_row(hero, "Bölge", factory["region"], TEXT, 16)
	_row(hero, "Alan", "%d m²" % factory["m2"], TEXT, 16)
	_row(hero, "Tavan yüksekliği", "%.1f m" % factory["height"], TEXT, 16)
	_row(hero, "Bina yaşı", "%d yıl" % factory["age"], MUTED, 15)
	_row(hero, "Zemin", factory["floor"], MUTED, 15)
	_row(hero, "Yükleme rampası", str(factory["ramps"]), MUTED, 15)
	_row(hero, "Elektrik altyapısı", "%d kVA" % factory["kva"], MUTED, 15)
	hero.add_child(_label("Bina bilgileri şimdilik bilgi amaçlıdır.", 12, MUTED))
	var terms := _card(content, "Sözleşme süresi", BORDER, true)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	terms.add_child(row)
	for term in Data.TERMS:
		var chosen: bool = term["months"] == picked_term
		var button := Button.new()
		button.text = "%d ay\n%s" % [term["months"], Data.usd(roundf(float(factory["rent"]) * float(term["factor"])))]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 66)
		button.add_theme_font_size_override("font_size", 17)
		button.add_theme_stylebox_override("normal", _box(GREEN_DIM if chosen else PANEL_ALT, GREEN if chosen else BORDER, 10, 2 if chosen else 1))
		button.pressed.connect(_pick_term.bind(term["months"]))
		row.add_child(button)
	var quote: Dictionary = game.prepay_quote(factory["id"], picked_term)
	var prepay := CheckBox.new()
	prepay.text = "İlk %d ayın kirasını peşin öde (%%%d indirim)" % [quote["half"], int(roundf(float(quote["discount"]) * 100.0))]
	prepay.add_theme_font_size_override("font_size", 15)
	prepay.custom_minimum_size = Vector2(0, 48)
	prepay.button_pressed = picked_prepay
	prepay.toggled.connect(_toggle_prepay)
	terms.add_child(prepay)
	if picked_prepay:
		terms.add_child(_label("Şimdi ödenecek: %s" % Data.usd(float(quote["amount"])), 15, GREEN))
	var reason: String = game.rent_block_reason(factory["id"], picked_term, picked_prepay)
	if reason != "":
		content.add_child(_label(reason, 13, RED))
	content.add_child(_button("Kirala", _ask_rent.bind(factory["id"]), true, reason != "", true))

func _pick_term(months: int) -> void:
	picked_term = months
	_render()

func _toggle_prepay(on: bool) -> void:
	picked_prepay = on
	_render()

func _ask_rent(id: String) -> void:
	var factory := Data.factory_by_id(id)
	var quote: Dictionary = game.prepay_quote(id, picked_term)
	var lines: Array = [
		"%s · %d m² · %.1f m" % [factory["name"], factory["m2"], factory["height"]],
		"Aylık kira: %s · sözleşme %d ay" % [Data.usd(float(quote["rent"])), picked_term]
	]
	if picked_prepay:
		lines.append("Şimdi ödenecek peşin kira (%d ay, %%%d indirimli): %s. Peşin ödenen kira iade edilmez." % [quote["half"], int(roundf(float(quote["discount"]) * 100.0)), Data.usd(float(quote["amount"]))])
	_confirm("Kiralama onayı", lines, "Kirala", _rent_factory.bind(id),
		"Sözleşmeyi erken bırakırsan %d kira (%s) ceza ödersin." % [Data.EXIT_FEE_RENTS, Data.usd(float(quote["rent"]) * Data.EXIT_FEE_RENTS)])

func _rent_factory(id: String) -> void:
	var result: String = game.rent_factory(id, picked_term, picked_prepay)
	if result != "":
		_say(result)
		_render()
		return
	detail = ""
	page = "ozet"
	subtab["ozet"] = "genel"
	_render()

func _detail_leave() -> void:
	var fee: float = game.leave_fee()
	var reason: String = game.leave_block_reason()
	var box := _card(content, "Emin misin?", GOLD)
	box.add_child(_label("Sözleşmeyi erken bırakırsan %d kira (%s) ceza ödersin; peşin ödenen kira iade edilmez. Makineler ve ekipman kaybolur." % [Data.EXIT_FEE_RENTS, Data.usd(fee)], 14, TEXT))
	var jobs_cost: Dictionary = game.leave_job_costs()
	if int(jobs_cost["jobs"]) > 0:
		box.add_child(_label("%d aktif iş bırakılır: ceza %s, alınan peşinatların iadesi %s, ödenmemiş hammadde siparişleri %s. Toplam %s." % [jobs_cost["jobs"], Data.usd(float(jobs_cost["penalty"])), Data.usd(float(jobs_cost["refund"])), Data.usd(float(jobs_cost["orders"])), Data.usd(float(jobs_cost["total"]))], 13, RED))
	if reason != "":
		box.add_child(_label(reason, 13, RED))
	box.add_child(_button("Vazgeç", _back))
	box.add_child(_button("Bırak ve %s öde" % Data.usd(fee + float(jobs_cost["total"])), _leave_factory, true, reason != "" or fee + float(jobs_cost["total"]) > float(game.cash)))

func _leave_factory() -> void:
	var result: String = game.leave_factory()
	if result != "":
		_say(result)
	detail = ""
	page = "fabrika"
	_render()

# ------------------------------------------------------------------ Danışman

func _detail_consultants() -> void:
	var head := _card(content, "Danışmanlar · en fazla %d" % BossState.MAX_CONSULTANTS, BORDER)
	head.add_child(_label("Etkin yetkinlik = max(patron, danışman); bilgi patrona kalıcı geçmez. Danışman ay raporundan sonra tutulur.", 12, MUTED))
	for consultant in game.consultants:
		head.add_child(_label("✓ %s · %s · kalan %d ay" % [consultant["name"], _scores(consultant["scores"]), consultant["months_left"]], 14, GREEN))
	if game.phase != "report":
		content.add_child(_label("Adaylar rapor açıldığında görünür.", 13, GOLD))
	for index in game.candidates.size():
		var candidate: Dictionary = game.candidates[index]
		var reason: String = game.hire_block_reason(index)
		var card := _card(content, candidate["name"], BORDER)
		card.add_child(_label(_scores(candidate["scores"]), 13, MUTED))
		_row(card, "Sözleşme", "%d ay · %s" % [BossState.CONSULTANT_MONTHS, Data.usd(float(candidate["total"]))])
		card.add_child(_button("Tut" if reason == "" else reason, _hire.bind(index), reason == "", reason != ""))

func _scores(scores: Dictionary) -> String:
	var parts: Array = []
	for key in scores:
		parts.append("%s %d" % [key, scores[key]])
	return ", ".join(parts)

func _hire(index: int) -> void:
	game.hire(index)
	_say(game.notice)
	_render()

# ------------------------------------------------------------------ Kredi

func _detail_credit() -> void:
	var crisis := _card(content, "Kriz kredisi", BORDER)
	crisis.add_child(_label("Tek seferlik, teminatsız. Kasayı ve borcu aynı tutarda artırır; borç açığını tek başına düzeltmez (FRZ-003 v2).", 12, MUTED))
	crisis.add_child(_button("Kriz kredisi al · %s" % Data.usd(BossState.CREDIT_AMOUNT), _take_crisis, false, game.credit_used or (game.phase != "offers" and game.phase != "report")))
	var offer: Dictionary = Data.CREDIT
	if not game.loan.is_empty():
		_credit_active(game.loan)
		return
	var terms: Dictionary = game.loan_terms()
	var box := _card(content, offer["bank"], BORDER, true)
	_row(box, "Kredi tutarı", Data.usd(float(offer["amount"])), GREEN, 18)
	_row(box, "Faiz", "%%%.1f / ay" % (float(offer["rate"]) * 100.0), TEXT, 16)
	_row(box, "Vade", "%d ay" % offer["months"], TEXT, 16)
	_row(box, "Aylık taksit", Data.usd(float(terms["installment"])), TEXT, 16)
	_row(box, "Gereken teminat", "%s değerinde ipotek (%%%d)" % [Data.usd(float(terms["need"])), int(float(offer["collateral"]) * 100.0)], GOLD, 16)
	_row(box, "Erken kapatma cezası", "kalan anaparanın %%%d'si" % int(float(offer["early_fee"]) * 100.0), TEXT, 16)
	box.add_child(_label("Teminat olarak teslim alınmış ve ipoteksiz makineler gösterilir; değer güncel piyasa değeridir. İpotekli makine satılamaz.", 12, MUTED))
	var pick := _card(content, "Teminat seç", BORDER, true)
	var total := 0.0
	var any := false
	for machine in game.delivered():
		if machine["mortgaged"]:
			continue
		any = true
		var value: float = game.current_value(machine)
		var check := CheckBox.new()
		check.text = "%s · %s" % [machine["model"], Data.usd(value)]
		check.add_theme_font_size_override("font_size", 15)
		check.custom_minimum_size = Vector2(0, 48)
		check.button_pressed = collateral_picks.has(machine["uid"])
		check.toggled.connect(_toggle_collateral.bind(machine["uid"]))
		pick.add_child(check)
		if collateral_picks.has(machine["uid"]):
			total += value
	if not any:
		pick.add_child(_label("İpoteklenebilir makine yok (teslim alınmış tezgah gerekir).", 13, MUTED))
	pick.add_child(_label("Bina (satın alma yakında) — kilitli", 13, MUTED))
	_row(pick, "Seçilen teminat", Data.usd(total), GREEN if total >= float(terms["need"]) else RED, 16)
	var reason: String = game.loan_block_reason(collateral_picks)
	content.add_child(_button("Krediyi al" if reason == "" else reason, _ask_loan, true, reason != "", true))

func _credit_active(credit: Dictionary) -> void:
	var offer: Dictionary = Data.CREDIT
	var box := _card(content, offer["bank"] + " · aktif kredi", GOLD, true)
	_row(box, "Kalan anapara", Data.usd(float(credit["balance"])), TEXT, 16)
	_row(box, "Aylık taksit", Data.usd(float(credit["installment"])), TEXT, 16)
	_row(box, "Kalan vade", "%d ay" % credit["left"], TEXT, 16)
	_row(box, "İpotekli makine", str(credit["uids"].size()), TEXT, 16)
	_row(box, "Erken kapatma cezası", Data.usd(float(credit["balance"]) * float(offer["early_fee"])), GOLD, 16)
	var total_due: float = game.loan_close_cost()
	box.add_child(_button("Erken kapat · %s" % Data.usd(total_due), _ask_close_loan, false, total_due > float(game.cash), true))

func _take_crisis() -> void:
	game.take_credit()
	_say(game.notice)
	_render()

func _toggle_collateral(on: bool, uid: int) -> void:
	if on and not collateral_picks.has(uid):
		collateral_picks.append(uid)
	elif not on:
		collateral_picks.erase(uid)
	_render()

func _ask_loan() -> void:
	var offer: Dictionary = Data.CREDIT
	var terms: Dictionary = game.loan_terms()
	_confirm("Kredi onayı", [
		"%s · %s · %d ay · %%%.1f/ay" % [offer["bank"], Data.usd(float(offer["amount"])), offer["months"], float(offer["rate"]) * 100.0],
		"Aylık taksit: %s" % Data.usd(float(terms["installment"])),
		"İpotek: %d makine (kredi kapanana kadar satılamaz)" % collateral_picks.size(),
		"Erken kapatma cezası: kalan anaparanın %%%d'si" % int(float(offer["early_fee"]) * 100.0)
	], "Krediyi al", _take_loan)

func _take_loan() -> void:
	var result: String = game.take_loan(collateral_picks)
	if result != "":
		_say(result)
	collateral_picks = []
	_render()

func _ask_close_loan() -> void:
	var loan: Dictionary = game.loan
	var fee := float(loan["balance"]) * float(Data.CREDIT["early_fee"])
	_confirm("Krediyi erken kapat", ["Kalan anapara: %s" % Data.usd(float(loan["balance"])), "Erken kapatma cezası: %s" % Data.usd(fee), "İpotek kalkar."],
		"Öde ve kapat", _close_loan)

func _close_loan() -> void:
	var result: String = game.close_loan()
	if result != "":
		_say(result)
	_render()

# ------------------------------------------------------------------ summary details

func _detail_machines() -> void:
	if game.machines.is_empty():
		var empty := _card(content, "Henüz makine yok")
		empty.add_child(_label("Tezgah sekmesinden makine sipariş edebilirsin.", 13, MUTED))
		return
	var mults: Dictionary = game.problem_mults(game.loss_fractions())
	var overtime_done := false
	for machine in game.machines:
		var status := "Boşta"
		var accent := BORDER
		var delivered: bool = int(machine["arrive"]) <= game.month
		if not delivered:
			status = "Yolda · %d ay sonra teslim" % (int(machine["arrive"]) - game.month)
			accent = GOLD
		elif machine["mortgaged"]:
			status = "İpotekli"
			accent = GOLD
		elif float(machine.get("used_last", 0.0)) > 0.0:
			status = "Üretimde"
			accent = GREEN
		var box := _card(content, machine["model"], accent, true)
		_row(box, "Durum", status, TEXT, 15)
		_row(box, "Tür / seviye", "%s · %s" % [machine["kind"], Data.LEVELS[int(machine["level"])]], TEXT, 15)
		_row(box, "Yaş", "%d yıl" % machine["age"], TEXT, 15)
		_row(box, "Teorik · performans · hurda", "%s · %%%d · %%%.1f" % [_xfmt(float(machine["nameplate"])), int(roundf(float(machine["perf"]) * 100.0)), float(machine["scrap"]) * 100.0], TEXT, 14)
		_row(box, "Güncel değer", Data.usd(game.current_value(machine)), TEXT, 15)
		if delivered:
			_row(box, "Vardiya", "%d%s%s" % [machine["shifts"], " (+mesai)" if game.plan_ot[0] else "", " · 1. vardiya patron" if machine.get("patron", false) else ""], TEXT, 15)
			_row(box, "Etkin çıktı", "%s/ay" % _xfmt(game.machine_output(machine, mults)), GREEN, 15)
			_row(box, "Aylık işletme", Data.usd(game.machine_running_cost(machine)), TEXT, 15)
			box.add_child(_label("Vardiya ve mesai Fabrika > Vardiya bölümünden ayarlanır.", 12, MUTED))
		var reason: String = game.sell_block_reason(machine["uid"])
		box.add_child(_button("Sat · +%s" % Data.usd(game.sale_income(machine)) if reason == "" else reason, _ask_sell.bind(machine["uid"]), false, reason != ""))

func _ask_sell(uid: int) -> void:
	var machine: Dictionary = game.machine_by_uid(uid)
	if machine.is_empty():
		return
	_confirm("Makineyi sat", [machine["model"], "Satış geliri: %s (güncel değerin %%%d'i)" % [Data.usd(game.sale_income(machine)), int(Data.SALE_RATE * 100.0)],
		"Etkin kapasite azalır; personel işten çıkar."], "Sat", _sell_machine.bind(uid), "Bu işlem geri alınamaz.")

func _sell_machine(uid: int) -> void:
	var result: String = game.sell_machine_uid(uid)
	_say(game.notice if result == "" else result)
	_render()

func _detail_oee() -> void:
	var data: Dictionary = game.report if game.phase == "report" and not game.report.is_empty() else game.capacity_steps()
	if float(data["theoretical"]) <= 0.0:
		var empty := _card(content, "Teslim alınmış tezgah yok")
		empty.add_child(_label("Makine teslim alındığında kapasite şelalesi burada görünür.", 13, MUTED))
	else:
		_waterfall_card(content, "Bu ayın kapasitesi" if game.phase == "report" else "Şu anki vardiyalarla kapasite", data)
	if not game.package_bought:
		content.add_child(_label("Gerekli ekipman eksik: çıktı sıfır.", 13, RED))
	var cap := _card(content, "Makine başına etkin çıktı", BORDER)
	var mults: Dictionary = game.problem_mults(game.loss_fractions())
	for machine in game.delivered():
		_row(cap, machine["model"], "%s/ay · %d vardiya" % [_xfmt(game.machine_output(machine, mults)), machine["shifts"]], TEXT, 14)
	var how := _card(content, "OEE nasıl hesaplanır?")
	how.add_child(_label("OEE (24 saat) = vardiya/3 × performans × (1 − hurda) × sorun çarpanı. Tek vardiya = 1/3; bir vardiyaya mesai (+4 sa) 0,5 vardiya ekler; üç vardiya = 1. Sorunlar: Bakım/Planlama/Depo → kullanılabilirlik, Üretim → performans, Kalite → hurda. Finans gibi alanlar OEE dışı net çıktıyı düşürür.", 12, MUTED))

func _detail_costs() -> void:
	var box := _card(content, "Aylık gider dökümü", BORDER, true)
	_row(box, "Kira", "peşin ödenmiş" if int(game.prepaid_months) > 0 else Data.usd(game.base_rent()), TEXT, 15)
	var energy := 0.0
	var wages := 0.0
	for machine in game.delivered():
		wages += game.machine_wages(machine)
		energy += float(machine["energy"]) * game.shift_equiv(machine)
		_row(box, machine["model"], Data.usd(game.machine_running_cost(machine)), MUTED, 13)
	_row(box, "Enerji (tam çalışma varsayımı)", Data.usd(energy), TEXT, 15)
	_row(box, "Personel (patron vardiyası ücretsiz)", Data.usd(wages), TEXT, 15)
	_row(box, "Bina işletme (vergi, aidat, ısıtma, güvenlik)", Data.usd(game.building_overhead()), TEXT, 15)
	_row(box, "Dolaylı personel (%d kişi)" % game.indirect_count(), Data.usd(game.indirect_cost()), TEXT, 15)
	var roles: Array = game.office_roles()
	var role_names: Array = []
	for role in roles:
		role_names.append(role["name"])
	_row(box, "Ofis kadrosu (%d kişi)" % roles.size(), Data.usd(game.office_cost()), TEXT, 15)
	if not role_names.is_empty():
		box.add_child(_label(", ".join(role_names), 12, MUTED))
	box.add_child(_label("Sarf malzeme ayrıca ay sonunda üretim maliyetinin %%%.1f'i kadar düşer." % (Data.CONSUMABLE_SHARE * 100.0), 12, MUTED))
	if not game.loan.is_empty():
		_row(box, "Kredi taksidi", Data.usd(float(game.loan["installment"])), TEXT, 15)
	_row(box, "Toplam (nakit)", Data.usd(game.ordinary_expense()), GREEN, 17)
	_row(box, "Amortisman (kâğıt üstü, nakit değil)", Data.usd(game.monthly_amortization()), MUTED, 13)
	box.add_child(_label("Teslim alınmamış makineler gider yaratmaz; personel teslimde işe başlar.", 12, MUTED))

