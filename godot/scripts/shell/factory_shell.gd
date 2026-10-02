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
const GaugeScript = preload("res://scripts/shell/gauge.gd")

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

const FONT_SCALE := 1.12   # the whole UI text is 12 percent larger than the base sizes

const TABS := [
	{"id": "ozet", "icon": "🏠", "title": "Özet"},
	{"id": "ilanlar", "icon": "📋", "title": "İlanlar"},
	{"id": "mail", "icon": "✉", "title": "Mail"},
	{"id": "fabrika", "icon": "🏭", "title": "Fabrika"},
	{"id": "profil", "icon": "👤", "title": "Profil"}
]

var game = ShellBoss.new()
var flash := ""
var page := "ozet"
var subtab := {"ozet": "genel", "ilanlar": "isler", "fabrika": "yerlesim"}
var job_filters: Array = []
var job_sort := "yeni"
var mail_open := -1
var mail_show_offer := false
var quote_details := false
var type_filter := "Tümü"
var detail := ""
var detail_arg := ""
var picked_term := 12
var quote_price := 0.0
var quote_margin := 0.30
var quote_edit := {}   # requirement index -> {scrap_pt, overhead_pct, personnel_pct}: the player's own cost assumptions
var quote_adv := 20
var quote_months := 0
var picked_prepay := false
var selected_listing := -1
var level_filter := 0
var sort_mode := "price_up"
var collateral_picks: Array = []
var equip_qty := {}
var pending := Callable()
var press_pos := Vector2.ZERO

var audio: Node
var last_back_ms := -10000
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
		elif Time.get_ticks_msec() - last_back_ms < 2000:
			_to_background()
		else:
			last_back_ms = Time.get_ticks_msec()
			_say("Arka plana almak için tekrar geri bas.")
			_render()

# Sends the game to the background (Android) without closing it; elsewhere the window is minimised.
func _to_background() -> void:
	_autosave()
	if OS.has_feature("android") and Engine.has_singleton("AndroidRuntime"):
		var runtime = Engine.get_singleton("AndroidRuntime")
		var activity = runtime.getActivity()
		if activity != null:
			activity.moveTaskToBack(true)
			return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

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
	var gear := Button.new()
	gear.flat = true
	gear.custom_minimum_size = Vector2(44, 40)
	var gear_texture := Art.find("res://art/ui/btn_ayarlar")
	if gear_texture != null:
		gear.icon = gear_texture
		gear.expand_icon = true
		gear.add_theme_constant_override("icon_max_width", 30)
	else:
		gear.text = "⚙"
		gear.add_theme_font_size_override("font_size", _fs(20))
	gear.pressed.connect(_open_detail.bind("settings"))
	_juice(gear)
	row.add_child(gear)
	return bar

func _build_tab_bar() -> Control:
	var bar := PanelContainer.new()
	bar.add_theme_stylebox_override("panel", _box(Color("#151d26"), BORDER, 0, 0))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	bar.add_child(_margin(row, 8, 8))
	for tab in TABS:
		var button := Button.new()
		var tab_icon := Art.find("res://art/ui/btn_" + String(tab["id"]))
		if tab_icon != null:
			button.text = tab["title"]
			button.icon = tab_icon
			button.expand_icon = true
			button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
			button.add_theme_constant_override("icon_max_width", 40)
			button.add_theme_constant_override("h_separation", 0)
		else:
			button.text = "%s\n%s" % [tab["icon"], tab["title"]]
		button.custom_minimum_size = Vector2(0, 72)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", _fs(13))
		button.pressed.connect(_on_tab.bind(tab["id"]))
		_juice(button)
		row.add_child(button)
		tab_buttons[tab["id"]] = button
	return bar

# ------------------------------------------------------------------ helpers

static func _fs(size: int) -> int:
	return int(roundf(float(size) * FONT_SCALE))

func _label(text: String, size := 14, color := TEXT, wrap := true) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", _fs(size))
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
	button.add_theme_font_size_override("font_size", _fs(18 if big else 15))
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

func _chips(parent: Control, options: Array, current, callback: Callable, accents := {}) -> void:
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
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
		var active: bool = (current.has(option["id"]) if current is Array else option["id"] == current)
		if active:
			active_button = button
		var accent: Color = accents.get(option["id"], GREEN)
		for style_name in ["normal", "hover", "pressed"]:
			var chip := _box(Color(accent.r, accent.g, accent.b, 0.22) if active or accents.has(option["id"]) else PANEL_ALT, accent if active or accents.has(option["id"]) else BORDER, 20, 1)
			chip.content_margin_left = 16
			chip.content_margin_right = 16
			button.add_theme_stylebox_override(style_name, chip)
		button.add_theme_color_override("font_color", accent if active or accents.has(option["id"]) else TEXT)
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
	if tab_buttons.has("mail"):
		var unread: int = game.unread_mails()
		tab_buttons["mail"].text = "Mail (%d)" % unread if unread > 0 else "Mail"
	for id in tab_buttons:
		var active: bool = id == page
		var button: Button = tab_buttons[id]
		button.add_theme_stylebox_override("normal", _box(Color("#0a2418") if active else Color("#080d13"), GREEN if active else BORDER, 10, 2 if active else 1))
		button.add_theme_stylebox_override("hover", _box(Color("#0a2418") if active else Color("#0d141c"), GREEN if active else BORDER, 10, 2 if active else 1))
		button.add_theme_stylebox_override("pressed", _box(Color("#0a2418"), GREEN, 10, 2))
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
		_chips(sticky, [{"id": "yerlesim", "title": "Yerleşim (üstten)"}, {"id": "isler", "title": "İşler (%d)" % game.jobs.size()}, {"id": "tedarik", "title": "Tedarik"}, {"id": "vardiya", "title": "Vardiya"}, {"id": "sozlesme", "title": "Sözleşme"}], subtab["fabrika"],
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
		"ilanlar": _page_ilanlar()
		"mail": _page_mail()
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

func _phase_button() -> void:
	if game.phase == "offers":
		content.add_child(_button("Ayı çalıştır ▶", _open_report, true, false, true))
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
	if game.phase != "report":
		_say(game.close_block_reason())
		_render()
		return
	_month_animation(_finish_close_month)

func _finish_close_month() -> void:
	var result: String = game.close_month()
	if result != "":
		_say(result)
	subtab["ozet"] = "genel"
	_render()

# Placeholder month-end animation (a loading spinner); the calendar animation replaces it later.
func _month_animation(done: Callable) -> void:
	var layer := ColorRect.new()
	layer.color = Color(0, 0, 0, 0.82)
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.custom_minimum_size = Vector2(320, 0)
	center.add_child(box)
	var spinner := _label("◐", 64, GREEN, false)
	spinner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(spinner)
	var title := _label("Ay kapanıyor…", 22, TEXT, false)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 14)
	bar.max_value = 1.0
	box.add_child(bar)
	var frames := ["◐", "◓", "◑", "◒"]
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_method(func(t: float) -> void:
		spinner.text = frames[int(t * 12.0) % 4]
		bar.value = t, 0.0, 1.0, 1.4)
	tween.chain().tween_callback(func() -> void:
		layer.queue_free()
		done.call())

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
		["Teslim skoru", "%%%d" % int(roundf(float(game.delivery_score) * 100.0)), "tab:ilanlar"],
		["Aktif iş", str(game.jobs.size()), "fabjobs"],
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
			"Kapasite: tezgahın gücüne (kW × 1.500 μ) ve kondisyonuna bağlı; her %10 kondisyon eksiği kapasiteyi %5 düşürür. Hurda: tezgah türü, seviyesi ve kondisyonuna bağlı.",
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
		"fabjobs":
			subtab["fabrika"] = "isler"
			_on_tab("fabrika")
		"sub":
			subtab["ozet"] = parts[1]
			_render()

func _go_equipment() -> void:
	subtab["ilanlar"] = "ekipman"
	_on_tab("ilanlar")

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

func _job_requirement_rows(box: Control, offer: Dictionary, with_load := true) -> void:
	for req in offer["reqs"]:
		var have: bool = game.owns(req)
		var tolerance: String = Data.tolerance_text(float(req["tolerance"])) if req.has("tolerance") else ""
		_row(box, "%s %s%s" % [Data.LEVELS[int(req["level"])], req["kind"], (" · " + tolerance) if tolerance != "" else ""],
			"%d parça × %s = %s" % [req["parts"], Data.mu_text(float(req["difficulty"])), _xfmt(float(req["workload"]))] if with_load else "", TEXT if have else RED, 14)
		box.add_child(_label("%s kg/parça · yaklaşık %s kg %s çelik gerekir" % [str(req["weight"]).trim_suffix(".0").replace(".", ","), str(int(roundf(float(req["tons"]) * 1000.0))), "nitelikli" if int(req["steel"]) > 1 else "standart"], 11, MUTED))
		if not have:
			box.add_child(_label("Makine yok: bu hassasiyet için %s gerekli." % Data.level_needed_text(int(req["level"])), 11, RED))

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
		"Teslim süresi: %d ay" % offer["months"],
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

# ------------------------------------------------------------------ İlanlar

func _job_no(offer: Dictionary) -> int:
	return 261000 + int(offer["id"])

func _kind_list_text(offer: Dictionary) -> String:
	var kinds: Array = []
	for req in offer["reqs"]:
		if not kinds.has(req["kind"]):
			kinds.append(req["kind"])
	if kinds.size() == 1:
		return kinds[0]
	return ", ".join(kinds.slice(0, kinds.size() - 1)) + " ve " + kinds[kinds.size() - 1]

func _offer_photo(offer: Dictionary, height := 170) -> TextureRect:
	var photo := Art.pick_image("res://art/jobs", int(offer["id"]))
	if photo == null:
		return null
	var picture := TextureRect.new()
	picture.texture = photo
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.custom_minimum_size = Vector2(0, height)
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return picture

func _icon_rect(icon_name: String, side: int) -> TextureRect:
	var texture: Texture2D = Art.find("res://art/ui/" + icon_name)
	if texture == null:
		return null
	var icon := TextureRect.new()
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(side, side)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon

func _page_ilanlar() -> void:
	if game.factory_id == "":
		_locked("İlanlar fabrikan olunca açılır: iş, tezgah ve ekipman ilanları.")
		return
	var sub: String = subtab["ilanlar"]
	if sub == "tezgah" or sub == "ekipman":
		_build_area_bar()
	var pick_sub := func(id: String) -> void:
		subtab["ilanlar"] = id
		selected_listing = -1
		_render()
	_chips(content, [
		{"id": "tezgah", "title": "Tezgah"},
		{"id": "ekipman", "title": "Ekipman"},
		{"id": "isler", "title": "Teklif Bekleyen İşler (%d)" % game.offers.size()}], sub, pick_sub, {"isler": GOLD})
	match sub:
		"tezgah": _machines_board()
		"ekipman": _page_equipment()
		_: _jobs_board()

func _jobs_board() -> void:
	if game.phase != "offers":
		content.add_child(_label("Rapor açık: teklif ay başında (rapordan önce) verilir.", 12, GOLD))
	var kind_options: Array = [{"id": "Tümü", "title": "Tümü"}]
	for kind in Data.TYPES:
		kind_options.append({"id": kind, "title": kind})
	kind_options.append({"id": "elimde", "title": "Elimdeki tezgaha göre"})
	var pick_filter := func(id: String) -> void:
		if id == "Tümü":
			job_filters.clear()
		elif job_filters.has(id):
			job_filters.erase(id)
		else:
			job_filters.append(id)
		_render()
	_chips(content, kind_options, job_filters if not job_filters.is_empty() else "Tümü", pick_filter, {"elimde": GREEN})
	var pick_sort := func(id: String) -> void:
		job_sort = id
		_render()
	_chips(content, [{"id": "yeni", "title": "Sıra: ilan"}, {"id": "hassas", "title": "En hassas"}, {"id": "genis", "title": "En geniş tolerans"}], job_sort, pick_sort)
	var shown: Array = []
	for offer in game.offers:
		var ok := true
		for f in job_filters:
			if f == "elimde":
				if game.fit_block_reason(offer["id"]) != "":
					ok = false
			else:
				var uses := false
				for req in offer["reqs"]:
					if req["kind"] == f:
						uses = true
				if not uses:
					ok = false
		if ok:
			shown.append(offer)
	if job_sort != "yeni":
		shown.sort_custom(func(x: Dictionary, y: Dictionary) -> bool:
			var tx := _offer_tolerance(x)
			var ty := _offer_tolerance(y)
			return tx < ty if job_sort == "hassas" else tx > ty)
	for offer in shown:
		_offer_card(offer, game.accept_block_reason(offer["id"]))
	if shown.is_empty():
		content.add_child(_label("Bu filtreye uyan ilan yok.", 14, MUTED))

func _offer_tolerance(offer: Dictionary) -> float:
	var tol := 99.0
	for req in offer["reqs"]:
		tol = minf(tol, float(req.get("tolerance", 0.1)))
	return tol

func _offer_card(offer: Dictionary, reason: String) -> void:
	var box := _card(content, "", GREEN if reason == "" else BORDER)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	var photo := _offer_photo(offer, 96)
	if photo != null:
		photo.custom_minimum_size = Vector2(132, 96)
		head.add_child(photo)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 3)
	info.add_child(_label("İş No: %d" % _job_no(offer), 11, MUTED))
	info.add_child(_label(offer["title"], 17, TEXT))
	info.add_child(_label(offer["customer"], 12, MUTED))
	head.add_child(info)
	box.add_child(head)
	var tiles := HBoxContainer.new()
	tiles.add_theme_constant_override("separation", 8)
	var tol := 99.0
	for req in offer["reqs"]:
		tol = minf(tol, float(req.get("tolerance", 0.1)))
	tiles.add_child(_feature_tile("tezgah_ilan_tolerans", "Hassasiyet", Data.tolerance_text(tol)))
	tiles.add_child(_feature_tile("tezgah_ilan_teslimat", "Teslimat", "%d Ay" % int(offer["months"])))
	tiles.add_child(_feature_tile("is_ilani_malzeme", "Malzeme", Data.STEEL_GRADE[int(offer["reqs"][0]["steel"])]))
	box.add_child(tiles)
	box.add_child(_label("Tezgah İhtiyacı: " + _kind_list_text(offer), 13, GOLD))
	box.add_child(_button("Teklif ver" if reason == "" else reason, _open_detail.bind("quote", str(offer["id"])), reason == "", reason != ""))

func _gold_italic(text: String, size := 13) -> Label:
	var label := _label(text, size, GOLD)
	var font := SystemFont.new()
	font.font_italic = true
	label.add_theme_font_override("font", font)
	return label

func _quote_row(parent: Control, left: String, right: String, color := GOLD, size := 14) -> void:
	var row := HBoxContainer.new()
	var name_label := _gold_italic(left, size)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	var value := _label(right, size, color, false)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value)
	parent.add_child(row)

func _slider_row(parent: Control, caption: String, low: int, high: int, value: int, on_change: Callable) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var name_label := _label(caption, 15, TEXT, false)
	name_label.custom_minimum_size = Vector2(86, 0)
	row.add_child(name_label)
	var slider := HSlider.new()
	slider.min_value = low
	slider.max_value = high
	slider.step = 1
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(0, 44)
	row.add_child(slider)
	var shown := _label("", 15, GOLD, false)
	shown.custom_minimum_size = Vector2(66, 0)
	shown.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(shown)
	slider.value_changed.connect(func(v: float) -> void: on_change.call(int(v), shown))
	parent.add_child(row)
	on_change.call(value, shown)
	return shown

# ------------------------------------------------------------------ Teklif

func _open_quote(offer_id: int) -> void:
	var offer: Dictionary = game.offer_by_id(offer_id)
	if offer.is_empty():
		return
	quote_margin = 0.30
	quote_edit = {}
	quote_adv = 20
	quote_months = int(offer["months"])
	quote_details = false

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

func _sum_lines(lines: Array, key: String) -> float:
	var total := 0.0
	for line in lines:
		total += float(line[key])
	return total

# Wait before the offer's machines exist, plus the months the owned capacity needs for the workload.
func _delivery_check(offer: Dictionary, months_offered: int) -> String:
	var wait: int = maxi(0, game.transit_wait(offer))
	var needed := 0
	for req in offer["reqs"]:
		var capacity: float = game.effective_capacity(req["kind"])
		if capacity <= 0.0:
			return "Teslim alınmış %s tezgahı yok; bu süre için yetişmez." % req["kind"]
		needed = maxi(needed, int(ceil(float(req["workload"]) / capacity)))
	var finish := wait + needed
	if finish > months_offered:
		return "Mevcut kapasiteyle tahmini bitiş %d ay; %d ayda yetişmez. Teslim skorun düşer." % [finish, months_offered]
	return ""

func _detail_quote() -> void:
	var offer: Dictionary = game.offer_by_id(int(detail_arg))
	if offer.is_empty():
		content.add_child(_label("Bu ilan artık yok.", 14, MUTED))
		return
	if quote_months == 0:
		_open_quote(int(detail_arg))
	var wanted: int = int(offer["months"])
	var estimate: Dictionary = game.cost_estimate(offer, quote_edit)
	var lines: Array = estimate["lines"]
	var total: float = float(estimate["total"])
	var box := _card(content, "", GOLD, true)
	var title_row := HBoxContainer.new()
	var no_label := _label("İş No: %d" % _job_no(offer), 18, TEXT, false)
	no_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	no_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	title_row.add_child(no_label)
	box.add_child(title_row)
	var photo := _offer_photo(offer, 190)
	if photo != null:
		box.add_child(photo)
	var who := HBoxContainer.new()
	who.add_theme_constant_override("separation", 10)
	var avatar := _icon_rect("is_ilani_yetkili_kisi", 40)
	if avatar != null:
		who.add_child(avatar)
	who.add_child(_label(offer["customer"], 15, TEXT, false))
	box.add_child(who)
	box.add_child(_label(offer["title"], 24, TEXT))
	var parts := 0
	var load_total := 0.0
	var difficulty := 0.0
	for req in offer["reqs"]:
		parts = maxi(parts, int(req["parts"]))
		load_total += float(req["workload"])
		difficulty = maxf(difficulty, float(req["difficulty"]))
	_row(box, "Parça Sayısı", "%s Ad" % _xfmt(float(parts)), TEXT, 15)
	_row(box, "Parça İş Gücü", Data.mu_text(difficulty), TEXT, 15)
	_row(box, "Teslim Süresi", "%d Ay" % wanted, TEXT, 15)
	var tiles := HBoxContainer.new()
	tiles.add_theme_constant_override("separation", 8)
	var tol := 99.0
	for req in offer["reqs"]:
		tol = minf(tol, float(req.get("tolerance", 0.1)))
	tiles.add_child(_feature_tile("tezgah_ilan_tolerans", "Hassasiyet", Data.tolerance_text(tol)))
	tiles.add_child(_feature_tile("tezgah_ilan_teslimat", "Teslimat", "%d Ay" % wanted))
	tiles.add_child(_feature_tile("is_ilani_malzeme", "Malzeme", Data.STEEL_GRADE[int(offer["reqs"][0]["steel"])]))
	box.add_child(tiles)
	box.add_child(_label("Öngörülen Veriler", 16, GOLD))
	box.add_child(_gold_italic("Tezgah İhtiyacı: " + _kind_list_text(offer), 13))
	var kg := 0
	for req in offer["reqs"]:
		kg += int(roundf(float(req["tons"]) * 1000.0))
	var grade: String = Data.STEEL_GRADE[int(offer["reqs"][0]["steel"])]
	box.add_child(_gold_italic("Hammadde: %d parça için yaklaşık %s kg %s çelik (parça başına %s kg)." % [parts, _xfmt(float(kg)), grade, str(offer["reqs"][0]["weight"]).trim_suffix(".0").replace(".", ",")], 12))
	_quote_row(box, "Gerekli Kapasite", "%s μ" % _xfmt(load_total))
	_quote_row(box, "Enerji Gideri", Data.usd(_sum_lines(lines, "energy")))
	_quote_row(box, "Hammadde Gideri", Data.usd(float(estimate["material"])))
	_quote_row(box, "Hurda Gideri", Data.usd(_sum_lines(lines, "scrap")))
	_quote_row(box, "Sarf Malzeme Gideri", Data.usd(_sum_lines(lines, "consumables")))
	_quote_row(box, "Personel Gideri", Data.usd(_sum_lines(lines, "personnel")))
	_quote_row(box, "Genel Gider + Amortisman", Data.usd(_sum_lines(lines, "overhead") + _sum_lines(lines, "amortization")))
	_quote_row(box, "Toplam Maliyet", Data.usd(total), TEXT, 17)
	var price_label := _label("", 20, GREEN, false)
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var lower := HBoxContainer.new()
	lower.add_theme_constant_override("separation", 10)
	var sliders := VBoxContainer.new()
	sliders.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sliders.add_theme_constant_override("separation", 4)
	lower.add_child(sliders)
	var gauge_box := VBoxContainer.new()
	gauge_box.custom_minimum_size = Vector2(150, 0)
	gauge_box.add_child(_label("İşi Alma İhtimali", 12, MUTED, false))
	var gauge: Control = GaugeScript.new()
	gauge_box.add_child(gauge)
	var gauge_panel := PanelContainer.new()
	gauge_panel.add_theme_stylebox_override("panel", _box(Color(0, 0, 0, 0), Color("#e8eef4"), 12, 1))
	gauge_panel.add_child(_margin(gauge_box, 8, 6))
	var warning := _label("", 12, RED)
	var refresh := func() -> void:
		quote_price = ceilf(total * (1.0 + quote_margin) * 100.0) / 100.0
		price_label.text = "Teklif tutarı: " + Data.usd(quote_price)
		gauge.set_value(float(game.accept_probability(offer, quote_price, quote_adv, quote_months)["accept"]))
		var text: String = _delivery_check(offer, quote_months)
		warning.text = text
		warning.visible = text != ""
	box.add_child(price_label)
	_slider_row(sliders, "Peşinat", 0, 100, quote_adv, func(v: int, shown: Label) -> void:
		quote_adv = v
		shown.text = "%% %d" % v
		if is_instance_valid(gauge): refresh.call())
	_slider_row(sliders, "Teslimat", 1, wanted + 1, clampi(quote_months, 1, wanted + 1), func(v: int, shown: Label) -> void:
		quote_months = v
		shown.text = "%d Ay" % v
		if is_instance_valid(gauge): refresh.call())
	_slider_row(sliders, "Kar Marjı", 0, 100, int(roundf(quote_margin * 100.0)), func(v: int, shown: Label) -> void:
		quote_margin = float(v) / 100.0
		shown.text = "%%%d" % v
		if is_instance_valid(gauge): refresh.call())
	box.add_child(lower)
	lower.add_child(gauge_panel)
	box.add_child(warning)
	refresh.call()
	var reason: String = game.quote_block_reason(int(detail_arg), maxf(quote_price, 0.001))
	var send := _button("TEKLİF VER" if reason == "" else reason, _ask_send_quote.bind(int(detail_arg)), reason == "", reason != "", true)
	box.add_child(send)

	var toggle := _button("Maliyet ayrıntısı %s" % ("▴" if quote_details else "▾"), func() -> void:
		quote_details = not quote_details
		_render())
	content.add_child(toggle)
	if not quote_details:
		return
	content.add_child(_label("Hurda, genel gider, amortisman, sarf ve personel varsayımlarını değiştirebilirsin; maliyet ve teklif tutarı buna göre güncellenir. Hammadde değiştirilemez.", 12, MUTED))
	var material_card := _card(content, "Hammadde", BORDER)
	_row(material_card, "Hammadde (%s)" % Data.supplier_by_id(game.default_supplier)["name"], Data.usd(float(estimate["material"])), TEXT, 14)
	for i in lines.size():
		var line: Dictionary = lines[i]
		var edit: Dictionary = quote_edit.get(i, {})
		var card := _card(content, "%s %s tezgahı · %d makine × %d ay" % [Data.LEVELS[int(line["level"])], line["kind"], int(line["count"]), int(offer["duration"])], BORDER)
		_stepper(card, "Hurda giderleri", "%%%.0f · %s" % [float(line["scrap_rate_used"]) * 100.0, Data.usd(float(line["scrap"]))], i, "scrap_pt", 1.0, edit.has("scrap_pt") and float(edit["scrap_pt"]) != 0.0)
		var span: Array = line["scrap_range"]
		card.add_child(_label("Bu tür iş için olağan aralık %%%d–%%%d (ortalama %%%.1f). Tahmini düşürmek fiyatı indirir, gerçek hurda aynı kalır." % [int(roundf(float(span[0]) * 100.0)), int(roundf(float(span[1]) * 100.0)), float(line["scrap_rate"]) * 100.0], 11, MUTED))
		_stepper(card, "Genel giderler (kira, kredi, enerji)", Data.usd(float(line["overhead"]) + float(line["energy"])), i, "overhead_pct", 10.0, edit.has("overhead_pct") and float(edit["overhead_pct"]) != 0.0)
		_stepper(card, "Amortisman (bedel ÷ %d ay)" % Data.AMORT_MONTHS, Data.usd(float(line["amortization"])), i, "amortization_pct", 10.0, edit.has("amortization_pct") and float(edit["amortization_pct"]) != 0.0)
		if int(line["serving_level"]) > int(line["level"]):
			card.add_child(_label("Bu işi %s tezgâhın yapar: daha pahalı enerji, personel ve amortisman." % Data.LEVELS[int(line["serving_level"])], 11, GOLD))
		_stepper(card, "Sarf malzeme (maliyetin %%%.1f'i)" % (Data.CONSUMABLE_SHARE * 100.0), Data.usd(float(line["consumables"])), i, "consumables_pct", 10.0, edit.has("consumables_pct") and float(edit["consumables_pct"]) != 0.0)
		_stepper(card, "Personel giderleri", Data.usd(float(line["personnel"])), i, "personnel_pct", 10.0, edit.has("personnel_pct") and float(edit["personnel_pct"]) != 0.0)
		_row(card, "Tezgah maliyeti", Data.usd(float(line["subtotal"])), GREEN, 15)
	if total < float(estimate["base_total"]) - 0.5:
		content.add_child(_label("Varsayımların gerçek tahminin %s altında; fark senin cebinden çıkar." % Data.usd(float(estimate["base_total"]) - total), 12, RED))

func _ask_send_quote(offer_id: int) -> void:
	var offer: Dictionary = game.offer_by_id(offer_id)
	if offer.is_empty():
		return
	_confirm("Teklifi gönder", [
		"%s · %s" % [offer["title"], offer["customer"]],
		"Teklif tutarı: %s (maliyet %s, marj %%%d)" % [Data.usd(quote_price), Data.usd(float(game.cost_estimate(offer, quote_edit)["total"])), int(roundf(quote_margin * 100.0))],
		"Peşinat %%%d · Teslimat %d ay" % [quote_adv, quote_months]], "Teklif ver", _send_quote.bind(offer_id),
		"Müşteri yanıtı hemen Mail kutuna düşer. Anlaşırsan iş fabrikana eklenir.")

func _send_quote(offer_id: int) -> void:
	var result: Dictionary = game.submit_quote(offer_id, quote_price, quote_adv, quote_months)
	quote_months = 0
	if not result["ok"]:
		_say(result["reason"])
		_render()
		return
	detail = ""
	page = "mail"
	mail_open = int(result["mail"]["id"])
	mail_show_offer = false
	_say({"accepted": "Teklif kabul edildi.", "counter": "Müşteri karşı teklif gönderdi.", "rejected": "Teklif reddedildi."}[result["status"]])
	_render()

# ------------------------------------------------------------------ Mail

func _open_mail(id: int) -> void:
	mail_open = id
	mail_show_offer = false
	page = "mail"
	detail = ""
	_render()

func _mail_status_text(mail: Dictionary) -> String:
	return {"accepted": "Anlaşıldı", "counter": "Yanıt bekliyor", "rejected": "Reddedildi", "declined": "Vazgeçtiniz", "expired": "Süresi doldu", "revised": "Güncellendi", "info": "Bilgi"}.get(mail["status"], "")

func _page_mail() -> void:
	if mail_open >= 0:
		var mail: Dictionary = game.mail_by_id(mail_open)
		if mail.is_empty():
			mail_open = -1
		else:
			_mail_detail(mail)
			return
	if game.mails.is_empty():
		content.add_child(_label("Mail kutun boş. Bir ilana teklif verince müşteri burada yanıt verir; sistem bildirimleri de buraya düşer.", 14, MUTED))
		return
	for mail in game.mails:
		_mail_row(mail)

func _mail_row(mail: Dictionary) -> void:
	var unread: bool = not bool(mail.get("read", true))
	var colors := {"accepted": GREEN, "counter": GOLD, "rejected": RED}
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _box(Color(PANEL.r, PANEL.g, PANEL.b, 0.94), colors.get(mail["status"], BORDER) if unread else BORDER, 14, 2 if unread else 1))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(_margin(row, 12, 10))
	var envelope := Control.new()
	envelope.custom_minimum_size = Vector2(52, 52)
	var icon := _icon_rect("btn_mail", 48)
	if icon != null:
		envelope.add_child(icon)
	if unread:
		var dot := ColorRect.new()
		dot.color = Color("#e84b3c")
		dot.custom_minimum_size = Vector2(14, 14)
		dot.size = Vector2(14, 14)
		dot.position = Vector2(0, 0)
		envelope.add_child(dot)
	row.add_child(envelope)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	info.add_child(_label(mail["title"], 16, TEXT if unread else MUTED))
	info.add_child(_label("%s · %s" % [mail["customer"], _mail_status_text(mail)], 12, colors.get(mail["status"], MUTED)))
	info.add_child(_label("Ay %d" % mail["month"], 11, MUTED))
	row.add_child(info)
	if not mail.get("offer", {}).is_empty():
		var photo := _offer_photo(mail["offer"], 64)
		if photo != null:
			photo.custom_minimum_size = Vector2(88, 64)
			row.add_child(photo)
	panel.gui_input.connect(func(event: InputEvent) -> void:
		if _is_tap(event):
			_open_mail(mail["id"]))
	content.add_child(panel)

func _mail_detail(mail: Dictionary) -> void:
	mail["read"] = true
	var top := HBoxContainer.new()
	var back := _button("‹ Mail kutusu", func() -> void:
		mail_open = -1
		_render())
	back.custom_minimum_size = Vector2(150, 44)
	top.add_child(back)
	content.add_child(top)
	var offer: Dictionary = mail.get("offer", {})
	var box := _card(content, "", GOLD, true)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	var envelope := _icon_rect("btn_mail", 56)
	if envelope != null:
		head.add_child(envelope)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(_label(mail["title"], 20, TEXT))
	var who := HBoxContainer.new()
	who.add_theme_constant_override("separation", 8)
	var avatar := _icon_rect("is_ilani_yetkili_kisi", 30)
	if avatar != null:
		who.add_child(avatar)
	who.add_child(_label("%s%s" % [mail["customer"], (" · " + String(mail["contact"])) if String(mail.get("contact", "")) != "" else ""], 13, MUTED, false))
	info.add_child(who)
	head.add_child(info)
	box.add_child(head)
	if not offer.is_empty():
		var photo := _offer_photo(offer, 170)
		if photo != null:
			box.add_child(photo)
		box.add_child(_label("Konu: %d nolu işe verdiğiniz teklif hk." % _job_no(offer), 14, TEXT))
	if mail.get("kind", "quote") == "quote":
		box.add_child(_label("Bu işle ilgili %d. mesaj" % int(mail.get("mail_no", 1)), 11, MUTED))
	var status: String = mail["status"]
	if status == "counter" and mail.get("kind_counter", "") == "price":
		var body := RichTextLabel.new()
		body.bbcode_enabled = true
		body.fit_content = true
		body.scroll_active = false
		body.add_theme_font_size_override("normal_font_size", _fs(15))
		body.text = "Merhaba, Teklifinizi [color=#3ddc84]%s[/color] olarak güncelleyebilir misiniz?" % Data.usd(float(mail["price"]))
		box.add_child(body)
	else:
		for line in mail["lines"]:
			box.add_child(_label(str(line), 14, TEXT))
	if mail.get("kind", "quote") != "quote":
		return
	var wanted_price: float = float(mail.get("price", 0.0))
	var prob_label := _label("", 14, GOLD, false)
	_quote_row(box, "Teklif Tutarı", Data.usd(float(mail["my_price"])))
	if status == "counter" and mail.get("kind_counter", "") == "price":
		_quote_row(box, "Talep Edilen İndirim", "%%%d – %s" % [int(roundf(float(mail["request_pct"]) * 100.0)), Data.usd(float(mail["my_price"]) - wanted_price)])
	elif status == "counter":
		_quote_row(box, "Talep Edilen Teslimat", "%d Ay (sizin teklifiniz %d Ay)" % [int(mail["months"]), int(mail["my_months"])])
	_quote_row(box, "Proje Maliyeti (Öngörü)", Data.usd(float(mail["cost_total"])))
	var prob_row := HBoxContainer.new()
	var prob_name := _gold_italic("İşi Alma İhtimali", 14)
	prob_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prob_row.add_child(prob_name)
	prob_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	prob_row.add_child(prob_label)
	box.add_child(prob_row)
	var editable: bool = status == "counter" and game.phase == "offers"
	var update_prob := func(price: float) -> void:
		var months_now: int = int(mail["months"]) if mail.get("kind_counter", "") == "time" else int(mail["my_months"])
		prob_label.text = "%%%d" % int(roundf(float(game.accept_probability(offer, price, int(mail["my_advance"]), months_now, true)["accept"]) * 100.0))
	update_prob.call(wanted_price if status == "counter" and mail.get("kind_counter", "") == "price" else float(mail["my_price"]))
	if editable:
		var price_edit := LineEdit.new()
		price_edit.text = str(int(roundf((wanted_price if mail.get("kind_counter", "") == "price" else float(mail["my_price"])) * Data.MONEY_UNIT_USD)))
		price_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
		price_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
		price_edit.custom_minimum_size = Vector2(0, 54)
		price_edit.add_theme_font_size_override("font_size", _fs(20))
		price_edit.text_changed.connect(func(text: String) -> void:
			if text.is_valid_float():
				update_prob.call(float(text) / float(Data.MONEY_UNIT_USD)))
		box.add_child(_label("Yeni teklif tutarı ($)", 12, MUTED))
		box.add_child(price_edit)
		box.add_child(_button("TEKLİFİ GÜNCELLE", func() -> void:
			var value: float = float(price_edit.text) / float(Data.MONEY_UNIT_USD) if price_edit.text.is_valid_float() else 0.0
			_revise_mail(mail["id"], value), true, false, true))
	elif status == "counter":
		box.add_child(_label("Yanıt ay başında (rapordan önce) verilir.", 12, GOLD))
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	var show := _button("TEKLİFİ GÖSTER" if not mail_show_offer else "TEKLİFİ GİZLE", func() -> void:
		mail_show_offer = not mail_show_offer
		_render())
	show.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(show)
	if status == "counter":
		var no := _button("Vazgeç", func() -> void:
			_answer_counter(mail["id"], false))
		no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buttons.add_child(no)
	var trash := Button.new()
	trash.custom_minimum_size = Vector2(52, 44)
	var trash_icon: Texture2D = Art.find("res://art/ui/btn_delete")
	if trash_icon != null:
		trash.icon = trash_icon
		trash.expand_icon = true
	else:
		trash.text = "🗑"
	trash.pressed.connect(func() -> void:
		game.delete_mail(mail["id"])
		mail_open = -1
		_render())
	_juice(trash)
	buttons.add_child(trash)
	box.add_child(buttons)
	if mail_show_offer:
		_mail_offer_snapshot(mail)

func _mail_offer_snapshot(mail: Dictionary) -> void:
	var offer: Dictionary = mail["offer"]
	var card := _card(content, "Verdiğiniz teklif", BORDER)
	_job_requirement_rows(card, offer)
	_row(card, "Teklif tutarı", Data.usd(float(mail["my_price"])), GREEN, 15)
	_row(card, "Peşinat", "%%%d" % int(mail["my_advance"]), TEXT, 14)
	_row(card, "Teslimat", "%d ay (müşteri %d ay istedi)" % [int(mail["my_months"]), int(offer["months"])], TEXT, 14)
	_row(card, "Proje maliyeti (öngörü)", Data.usd(float(mail["cost_total"])), TEXT, 14)
	_row(card, "Kâr marjı", "%%%d" % int(roundf(float(mail["my_margin"]) * 100.0)), TEXT, 14)

func _revise_mail(mail_id: int, price: float) -> void:
	var mail: Dictionary = game.mail_by_id(mail_id)
	var months_wanted := -1
	if mail.get("kind_counter", "") == "time":
		months_wanted = int(mail["months"])
	var result: Dictionary = game.revise_quote(mail_id, price, months_wanted)
	if not result["ok"]:
		_say(result["reason"])
		_render()
		return
	mail_open = int(result["mail"]["id"])
	mail_show_offer = false
	_say({"accepted": "Teklif kabul edildi.", "counter": "Müşteri yine karşı teklif gönderdi.", "rejected": "Teklif reddedildi."}[result["status"]])
	_render()

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
	auto.add_theme_font_size_override("font_size", _fs(14))
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
	head.add_child(_label("%s · teslim tarihi Ay %d. Hammadde gelmeden üretim başlamaz." % [job["title"], job["due_month"]], 13, MUTED))
	for supplier in Data.SUPPLIERS:
		_supplier_card(supplier, game.material_quote(job, supplier["id"]), int(job["id"]))

# ------------------------------------------------------------------ Tezgah

func _machines_board() -> void:
	var type_options: Array = [{"id": "Tümü", "title": "Tümü"}]
	for kind in Data.TYPES:
		type_options.append({"id": kind, "title": kind})
	_chips(content, type_options, type_filter, func(id: String) -> void:
		type_filter = id
		selected_listing = -1
		_render())
	var level_options: Array = [{"id": "0", "title": "Tüm seviyeler"}]
	for level in [1, 2, 3]:
		level_options.append({"id": str(level), "title": Data.LEVELS[level]})
	_chips(content, level_options, str(level_filter), func(id: String) -> void:
		level_filter = int(id)
		selected_listing = -1
		_render())
	_chips(content, [{"id": "price_up", "title": "Fiyat ↑"}, {"id": "price_down", "title": "Fiyat ↓"}, {"id": "cond_up", "title": "Kondisyon ↑"}, {"id": "cond_down", "title": "Kondisyon ↓"}],
		sort_mode, func(id: String) -> void:
			sort_mode = id
			selected_listing = -1
			_render())
	var shown: Array = []
	for listing in Data.machine_listings():
		if type_filter != "Tümü" and listing["kind"] != type_filter:
			continue
		if level_filter != 0 and int(listing["level"]) != level_filter:
			continue
		shown.append(listing)
	shown.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		match sort_mode:
			"price_down":
				return float(a["price"]) > float(b["price"])
			"cond_up":
				return float(a["condition"]) < float(b["condition"])
			"cond_down":
				return float(a["condition"]) > float(b["condition"])
		return float(a["price"]) < float(b["price"]))
	for listing in shown:
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

func _feature_tile(icon_name: String, title: String, value: String) -> Control:
	var tile := PanelContainer.new()
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.add_theme_stylebox_override("panel", _box(Color(0, 0, 0, 0), Color("#e8eef4"), 12, 1))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	tile.add_child(_margin(column, 4, 8))
	var texture := Art.find("res://art/ui/" + icon_name)
	if texture != null:
		var icon := TextureRect.new()
		icon.texture = texture
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(0, 38)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(icon)
	var caption := _label(title, 11, MUTED, false)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(caption)
	var number := _label(value, 12, TEXT, false)
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number.clip_text = true
	column.add_child(number)
	return tile

func _machine_card(listing: Dictionary) -> void:
	var selected: bool = listing["uid"] == selected_listing
	var box := _card(content, "", GOLD if selected else BORDER, true)
	var panel := _panel_of(box)
	listing_cards[listing["uid"]] = panel
	var level_name: String = Data.LEVELS[int(listing["level"])]
	box.add_child(_image_slot("machines", "%s_%d" % [Art.slug(listing["kind"]), listing["level"]], Color("#26313d")))
	# title on the left, price on the right
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	var names := VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	names.add_child(_label("%s %s" % [level_name, listing["kind"]], 24, TEXT, false))
	names.add_child(_label(listing["model"], 14, MUTED, false))
	head.add_child(names)
	var price_box := VBoxContainer.new()
	price_box.alignment = BoxContainer.ALIGNMENT_END
	if float(listing["discount"]) > 0.0:
		var old := _rich("[right][s][color=#93a3b3]%s[/color][/s][/right]" % Data.usd(float(listing["base_price"])), 14)
		price_box.add_child(old)
		price_box.add_child(_rich("[right][color=#eac47a]-%%%d[/color]  [color=#3ddc84][b]%s[/b][/color][/right]" % [int(roundf(float(listing["discount"]) * 100.0)), Data.usd(float(listing["price"]))], 22))
	else:
		price_box.add_child(_rich("[right][color=#3ddc84][b]%s[/b][/color][/right]" % Data.usd(float(listing["price"])), 22))
	price_box.custom_minimum_size = Vector2(190, 0)
	head.add_child(price_box)
	box.add_child(head)
	# five feature tiles
	var tiles := HBoxContainer.new()
	tiles.add_theme_constant_override("separation", 6)
	tiles.add_child(_feature_tile("tezgah_ilan_motor_gucu", "Güç", ("%.1f kW" % float(listing["power"])).replace(".", ",")))
	tiles.add_child(_feature_tile("tezgah_ilan_tolerans", "Hassasiyet", Data.tolerance_text(float(listing["precision"]))))
	tiles.add_child(_feature_tile("tezgah_ilan_kondisyon", "Kondisyon", "%% %d" % int(listing["condition"])))
	tiles.add_child(_feature_tile("tezgah_ilan_olculer", "Ölçüler", ("%d m² x %.1fm" % [int(listing["area"]), float(listing["height"])]).replace(".0m", "m").replace(".", ",")))
	tiles.add_child(_feature_tile("tezgah_ilan_teslimat", "Teslimat", "%d Ay" % int(listing["delivery"])))
	box.add_child(tiles)
	# forecast for one shift
	box.add_child(_label("Öngörülen Veriler (1 Vardiya)", 15, GOLD, false))
	var steps: float = Data.condition_steps(float(listing["condition"]))
	var energy: float = float(listing["energy"]) * (1.0 + steps * float(Data.ENERGY_STEP_RANGE[0]))   # the listing shows the low end; operation rolls 5-10 percent a step
	var maintenance: float = steps * float(Data.MAINT_STEP_PCT[int(listing["level"])]) * float(listing["price"])
	for entry in [["Kapasite", "%s/ay" % _xfmt(float(listing["nameplate"]) / 3.0)], ["Enerji Gideri", "%s /ay" % Data.usd(energy)], ["Bakım Masrafı", "%s /ay" % Data.usd(maintenance)]]:
		var line := HBoxContainer.new()
		var name_label := _label("○  " + String(entry[0]), 15, GOLD, false)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(name_label)
		line.add_child(_label(entry[1], 15, GOLD, false))
		box.add_child(line)
	var owned: int = game.machines_owned(listing["kind"], int(listing["level"]))
	var reason: String = game.listing_block_reason(listing["uid"])
	box.add_child(_button("Satın al" if reason == "" else reason, _ask_buy.bind(listing["uid"]), reason == "", reason != "", true))
	box.add_child(_label("Mevcut: %d ad (%s %s)" % [owned, level_name, listing["kind"]], 13, GOLD if owned > 0 else MUTED))
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
	if game.factory_id != "" and subtab["fabrika"] == "isler":
		_page_jobs()
		return
	if game.factory_id != "" and subtab["fabrika"] == "tedarik":
		_page_suppliers()
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

func _page_jobs() -> void:
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
	if game.jobs.is_empty():
		content.add_child(_label("Henüz kabul edilmiş iş yok. İlanlar sekmesinden teklif ver.", 14, MUTED))
	var finish: Dictionary = game.projection()
	for job in game.jobs:
		_job_card(job, int(finish.get(job["id"], 0)))

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
		tick.add_theme_font_size_override("font_size", _fs(15))
		tick.custom_minimum_size = Vector2(0, 48)
		tick.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tick.button_pressed = game.plan_shifts >= n
		tick.disabled = n == 1 or not editable
		tick.toggled.connect(_on_shift_tick.bind(n))
		row.add_child(tick)
		var overtime := CheckBox.new()
		overtime.text = "Mesai (+4 sa)"
		overtime.add_theme_font_size_override("font_size", _fs(14))
		overtime.custom_minimum_size = Vector2(0, 48)
		overtime.button_pressed = bool(game.plan_ot[n - 1])
		overtime.disabled = not editable or n > game.plan_shifts or game.plan_shifts >= 3
		overtime.toggled.connect(_on_overtime_tick.bind(n))
		row.add_child(overtime)
		box.add_child(row)
	var patron := CheckBox.new()
	patron.text = "Patron operatörlük yapar"
	patron.add_theme_font_size_override("font_size", _fs(15))
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
		"settings":
			title.text = "  Ayarlar"
			_detail_settings()

func _detail_settings() -> void:
	var box := _card(content, "Ses", GREEN, true)
	var music := CheckBox.new()
	music.text = "Müzik"
	music.add_theme_font_size_override("font_size", _fs(16))
	music.custom_minimum_size = Vector2(0, 52)
	music.button_pressed = audio.music_on
	music.toggled.connect(audio.set_music)
	box.add_child(music)
	box.add_child(_label("Müzik ses yüksekliği", 13, MUTED))
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = audio.music_volume
	slider.custom_minimum_size = Vector2(0, 40)
	slider.value_changed.connect(audio.set_music_volume)
	box.add_child(slider)
	var click := CheckBox.new()
	click.text = "Click ve efekt sesleri"
	click.add_theme_font_size_override("font_size", _fs(16))
	click.custom_minimum_size = Vector2(0, 52)
	click.button_pressed = audio.sfx_on
	click.toggled.connect(audio.set_sfx)
	box.add_child(click)

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
	var base_rent: float = float(factory["rent"]) * Data.rent_scale
	var group := ButtonGroup.new()
	for term in Data.TERMS:
		var months: int = term["months"]
		var chosen: bool = months == picked_term
		var price := snappedf(base_rent * float(term["factor"]), 0.001)
		var button := Button.new()
		button.toggle_mode = true
		button.button_group = group
		button.button_pressed = chosen
		button.custom_minimum_size = Vector2(0, 60)
		for style_name in ["normal", "hover", "pressed", "hover_pressed"]:
			button.add_theme_stylebox_override(style_name, _box(GREEN_DIM if chosen else PANEL_ALT, GREEN if chosen else BORDER, 10, 2 if chosen else 1))
		var label := RichTextLabel.new()
		label.bbcode_enabled = true
		label.fit_content = false
		label.scroll_active = false
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.offset_left = 14
		label.offset_right = -10
		label.offset_top = 14
		label.add_theme_font_size_override("normal_font_size", _fs(17))
		label.add_theme_font_size_override("bold_font_size", _fs(17))
		var struck := "" if is_equal_approx(float(term["factor"]), 1.0) else "[s][color=#93a3b3]%s[/color][/s]  " % Data.usd(base_rent)
		var tint := "#f08080" if float(term["factor"]) > 1.0 else ("#3ddc84" if float(term["factor"]) < 1.0 else "#e8eef4")
		label.text = "%s [b]%d ay[/b] × %s[color=%s][b]%s[/b][/color] /ay" % ["◉" if chosen else "○", months, struck, tint, Data.usd(price)]
		button.add_child(label)
		button.pressed.connect(_pick_term.bind(months))
		_juice(button)
		terms.add_child(button)
	var quote: Dictionary = game.prepay_quote(factory["id"], picked_term)
	var prepay := CheckBox.new()
	prepay.text = "İlk %d ayın kirasını peşin öde (%%%d indirim)" % [quote["half"], int(roundf(float(quote["discount"]) * 100.0))]
	prepay.add_theme_font_size_override("font_size", _fs(15))
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
		check.add_theme_font_size_override("font_size", _fs(15))
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
		_row(box, "Kondisyon", "%% %d" % int(roundf(float(machine["condition"]))), TEXT, 15)
		_row(box, "Teorik kapasite · hurda", "%s · %%%.1f" % [_xfmt(float(machine["nameplate"])), game.machine_scrap(machine) * 100.0], TEXT, 14)
		_row(box, "Aylık enerji + bakım (1 vardiya)", Data.usd(game.machine_energy(machine) + game.machine_maintenance(machine)), TEXT, 14)
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

