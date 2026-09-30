extends Control

# Mobile-portrait factory shell (fixed header, sticky bar, page area, fixed
# bottom tabs). UI over MOCK data: rules are NOT wired to BossState and nothing
# here is a FREEZE decision. Proposed rules: docs/ideas/IDEA-015 and IDEA-016.

const Data = preload("res://scripts/shell/shell_data.gd")
const BossState = preload("res://scripts/boss_state.gd")
const ShellBoss = preload("res://scripts/shell/shell_boss.gd")
const SaveStore = preload("res://scripts/shell/save_store.gd")

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
var subtab := {"ozet": "genel", "isler": "tum", "tezgah": "tezgah"}
var type_filter := "Tümü"
var detail := ""
var detail_arg := ""
var picked_term := 12
var picked_prepay := false
var selected_listing := -1
var collateral_picks: Array = []
var equip_qty := {}
var pending := Callable()

var header_date: Label
var header_money: Label
var header_hours: Label
var sticky: VBoxContainer
var stage: Control
var background: TextureRect
var content: VBoxContainer
var tab_buttons := {}
var overlay: Control
var safe_top: Control
var safe_bottom: Control
var listing_cards := {}
var area_label: Label
var area_used_bar: ProgressBar
var area_preview_bar: ProgressBar

func _ready() -> void:
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
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
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
	return button

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
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	scroll.add_child(row)
	for option in options:
		var button := Button.new()
		button.text = option["title"]
		button.custom_minimum_size = Vector2(0, 40)
		var active: bool = option["id"] == current
		for style_name in ["normal", "hover", "pressed"]:
			var chip := _box(GREEN_DIM if active else PANEL_ALT, GREEN if active else BORDER, 20, 1)
			chip.content_margin_left = 16
			chip.content_margin_right = 16
			button.add_theme_stylebox_override(style_name, chip)
		button.add_theme_color_override("font_color", GREEN if active else TEXT)
		button.pressed.connect(callback.bind(option["id"]))
		row.add_child(button)
	parent.add_child(scroll)

# Image slot: loads res://art/<kind>/<id>.png when it exists, else a placeholder.
func _image_slot(kind: String, id: String, tint: Color, height := 170) -> Control:
	var path := "res://art/%s/%s.png" % [kind, id]
	if ResourceLoader.exists(path):
		var rect := TextureRect.new()
		rect.texture = load(path)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		rect.custom_minimum_size = Vector2(0, height)
		return rect
	var holder := ColorRect.new()
	holder.color = tint
	holder.custom_minimum_size = Vector2(0, height)
	var caption := _label("Görsel: art/%s/%s.png" % [kind, id], 12, Color(1, 1, 1, 0.35), false)
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
	background.texture = _background_texture()
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
	if page != "ozet" or detail != "" or game.factory_id == "":
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
		content.add_child(_button("Raporu aç ▶", _open_report, true, false, true))
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
		var warn := _card(content, "Zorunlu ekipman eksik", GOLD)
		warn.add_child(_label("Zorunlu ekipman paketi alınmadan kapasite kullanılamaz.", 13, MUTED))
		warn.add_child(_button("Ekipmana git", _go_equipment, true))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content.add_child(grid)
	var delivered: int = game.delivered().size()
	var transit: int = game.machines.size() - delivered
	var oee := "—"
	if not game.report.is_empty():
		oee = "%%%d" % int(roundf(float(game.report["oee"]) * 100.0))
	var tiles := [
		["Makine", "%d%s" % [delivered, " (+%d yolda)" % transit if transit > 0 else ""]],
		["Yatırım tutarı", Data.usd(float(game.invested))],
		["Güncel değer", Data.usd(float(game.investment_value()))],
		["OEE", oee],
		["Kapasite", "%d birim/ay" % game.capacity_at_least(1)],
		["Boşta makine", str(game.free_machines().size())],
		["Aylık gider", Data.usd(float(game.ordinary_expense()))],
		["Sözleşme", "%d ay kaldı" % int(game.months_left)],
		["Patron zamanı", "%d / %d sa" % [game.hours_left if game.phase == "report" else game.monthly_hours, game.monthly_hours]]
	]
	if game.debt > 0.0:
		tiles.append(["Borç", Data.usd(float(game.debt))])
	for tile in tiles:
		var box := _card(grid, "", BORDER)
		box.add_child(_label(tile[0], 12, MUTED))
		box.add_child(_label(tile[1], 18, TEXT))
		_panel_of(box).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_phase_button()
	if game.phase == "offers" and not game.last_lines.is_empty():
		var last := _card(content, "Geçen ay")
		for line in game.last_lines:
			last.add_child(_label(str(line), 13, MUTED))

func _ozet_report() -> void:
	if game.phase != "report":
		var box := _card(content, "Ay raporu")
		if game.last_lines.is_empty():
			box.add_child(_label("Rapor, ay başında \"Raporu aç\" ile açılır.", 14, MUTED))
		else:
			box.add_child(_label("Geçen ayın kapanışı:", 13, MUTED))
			for line in game.last_lines:
				box.add_child(_label(str(line), 13, TEXT))
		_phase_button()
		return
	var report: Dictionary = game.report
	var box := _card(content, "Ay %d raporu" % game.month, GREEN)
	_row(box, "Beklenen çıktı", "%d birim" % int(report["expected"]), TEXT, 15)
	_row(box, "Gerçekleşen", "%.0f birim (verim %%%d)" % [float(report["realized"]), int(roundf(float(report["efficiency"]) * 100.0))], TEXT, 15)
	_row(box, "Kayıp", "%.1f birim" % float(report["loss"]), RED if float(report["loss"]) > 0.0 else TEXT, 15)
	_row(box, "OEE (fiziksel)", "%%%d" % int(roundf(float(report["oee"]) * 100.0)), TEXT, 15)
	_row(box, "Boş kapasite", "%d birim" % int(report["empty"]), MUTED, 15)
	if report["capped"]:
		box.add_child(_label("Bir departmanın kaybı %20 tavanına kırpıldı.", 12, GOLD))
	var losses: Dictionary = report["losses"]
	if not losses.is_empty():
		var by_dep := _card(content, "Kayıp — departmana göre")
		for department in losses:
			_row(by_dep, department, "%.1f" % float(losses[department]), TEXT, 14)
	box.add_child(_label("Gelir, işler tesliminde verimle orantılı yazılır.", 12, MUTED))
	_phase_button()

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
		if game.accept_block_reason(offer["id"]) == "":
			doable += 1
	_chips(content, [
		{"id": "tum", "title": "Tümü (%d)" % game.offers.size()},
		{"id": "yapabilir", "title": "Yapabileceklerim (%d)" % doable},
		{"id": "kabul", "title": "Kabul edilenler (%d)" % game.jobs.size()}],
		subtab["isler"], func(id: String) -> void:
			subtab["isler"] = id
			_render())
	var box := _card(content, "Makineler")
	var delivered: int = game.delivered().size()
	var free: int = game.free_machines().size()
	box.add_child(_bar(delivered - free, maxi(1, delivered)))
	box.add_child(_label("%d makine işte, %d boşta · zorunlu ekipman: %s" % [delivered - free, free, "tamam" if game.package_bought else "EKSİK"], 13, MUTED if game.package_bought else RED))
	if game.phase != "offers":
		content.add_child(_label("İş kabulü ay başında, rapor açılmadan önce yapılır.", 12, GOLD))
	if subtab["isler"] == "kabul":
		if game.jobs.is_empty():
			content.add_child(_label("Henüz kabul edilmiş iş yok.", 14, MUTED))
		for job in game.jobs:
			var card := _card(content, job["title"], GREEN)
			_row(card, "Müşteri", job["customer"])
			_row(card, "Kalan süre", "%d ay" % (int(job["months"]) - int(job["elapsed"])))
			_row(card, "Gelir (tesliminde, verimle)", Data.usd(float(job["revenue"])), GREEN)
			_row(card, "Ayrılan makine", str(job["uids"].size()))
		return
	for offer in game.offers:
		var reason: String = game.accept_block_reason(offer["id"])
		if subtab["isler"] == "yapabilir" and reason != "":
			continue
		_offer_card(offer, reason)

func _offer_card(offer: Dictionary, reason: String) -> void:
	var box := _card(content, offer["title"], GREEN if reason == "" else BORDER)
	box.add_child(_label(offer["customer"], 12, MUTED))
	var first := true
	for req in offer["reqs"]:
		var own: int = game.owned_count(req)
		var enough: bool = own >= int(req["count"])
		_row(box, "Gereken makine" if first else "", "%s  %s" % [Data.req_text(req), "✔" if enough else "(%d var)" % own], TEXT if enough else RED)
		first = false
	_row(box, "Süre", "%d ay" % offer["months"])
	_row(box, "Gelir", Data.usd(float(offer["revenue"])), GREEN)
	_row(box, "Hammadde maliyeti (%%%d)" % int(roundf(float(offer["share"]) * 100.0)), Data.usd(float(offer["material"])))
	var payment: float = game.first_payment(offer)
	if payment < float(offer["material"]):
		box.add_child(_label("Kabulde %s düşer; kalanı her 6 ayın başında." % Data.usd(payment), 12, GOLD))
	else:
		box.add_child(_label("Hammadde kabulde düşer.", 12, GOLD))
	box.add_child(_button("Kabul et" if reason == "" else reason, _ask_accept.bind(offer["id"]), reason == "", reason != ""))

func _ask_accept(id: int) -> void:
	var offer: Dictionary = game.offer_by_id(id)
	if offer.is_empty():
		return
	var reqs_text: Array = []
	for req in offer["reqs"]:
		reqs_text.append(Data.req_text(req))
	_confirm("İşi kabul et", [
		offer["title"] + " · " + offer["customer"],
		"Ayrılacak makineler: " + ", ".join(reqs_text),
		"Kabulde bakiyeden düşen hammadde: %s" % Data.usd(game.first_payment(offer)),
		"Gelir tesliminde yazılır: %s (%d ay), üretim verimiyle orantılı" % [Data.usd(float(offer["revenue"])), offer["months"]]
	], "Kabul et", _accept_offer.bind(id))

func _accept_offer(id: int) -> void:
	var result: String = game.accept_offer(id)
	if result != "":
		_say(result)
	_render()

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
	box.add_child(_image_slot("machines", "%s_%d" % [String(listing["kind"]).to_lower(), listing["level"]], Color("#26313d")))
	box.add_child(_label(listing["model"], 22, TEXT))
	var age_text := "Yeni (sıfır)" if int(listing["age"]) == 0 else "İkinci el · %d yaşında" % listing["age"]
	box.add_child(_label("%s · %s · %s" % [listing["kind"], Data.LEVELS[int(listing["level"])], age_text], 15, MUTED))
	if float(listing["discount"]) > 0.0:
		box.add_child(_rich("[s][color=#93a3b3]%s[/color][/s]  [color=#3ddc84][b]%s[/b][/color]  [color=#eac47a](-%%%d)[/color]" % [
			Data.usd(float(listing["base_price"])), Data.usd(float(listing["price"])), int(roundf(float(listing["discount"]) * 100.0))], 22))
	else:
		box.add_child(_rich("[b]%s[/b]" % Data.usd(float(listing["price"])), 22))
	_row(box, "Kapasite", "%d birim/ay" % listing["capacity"], TEXT, 16)
	_row(box, "Alan / yükseklik", "%d m² · %.1f m" % [listing["area"], listing["height"]], TEXT, 16)
	_row(box, "Enerji", "%d kW · %s/ay" % [listing["kw"], Data.usd(float(listing["energy"]))], TEXT, 16)
	_row(box, "Personel", "%d kişi (teslimde işe başlar)" % listing["personnel"], TEXT, 16)
	_row(box, "Teslim", "%d ay" % listing["delivery"], TEXT, 16)
	_row(box, "Bakım riski (yaş)", Data.maintenance_risk(int(listing["age"])), TEXT, 16)
	var reason: String = game.listing_block_reason(listing["uid"])
	box.add_child(_button("Satın al" if reason == "" else reason, _ask_buy.bind(listing["uid"]), reason == "", reason != "", true))
	panel.mouse_entered.connect(func() -> void: _update_area_preview(float(listing["area"])))
	panel.mouse_exited.connect(func() -> void: _update_area_preview())
	panel.gui_input.connect(_on_card_input.bind(listing["uid"]))

func _on_card_input(event: InputEvent, uid: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
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
		"Teslimde %d personel otomatik işe başlar (kişi başı %s/ay)." % [listing["personnel"], Data.usd(Data.WAGE)],
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
	var box := _card(content, "Zorunlu ekipman paketi" + (" ✔" if game.package_bought else ""), GREEN if game.package_bought else GOLD, true)
	box.add_child(_label("Üretim yapabilmek için şart. Eksikse kapasite kullanılamaz.", 14, MUTED))
	for id in package["items"]:
		var item: Dictionary = Data.EQUIPMENT[id]
		_row(box, "%s × %d" % [item["name"], package["items"][id]], Data.usd(float(item["price"]) * int(package["items"][id])), TEXT, 15)
	_row(box, "Alan", "%d m²" % int(package["area"]), TEXT, 15)
	_row(box, "Paket fiyatı", Data.usd(float(package["price"])), GREEN, 17)
	var reason: String = game.package_block_reason()
	box.add_child(_button("Paketi satın al" if reason == "" else reason, _ask_package, reason == "", reason != "", true))
	content.add_child(_label("İsteğe bağlı ekipman", 20, TEXT))
	content.add_child(_label("Kesici uç ve takım sarfı tezgahın aylık işletme giderine dahildir.", 12, MUTED))
	for id in Data.OPTIONAL_ORDER:
		_equipment_card(id)

func _equipment_card(id: String) -> void:
	var item: Dictionary = Data.EQUIPMENT[id]
	var qty: int = equip_qty.get(id, 1)
	var box := _card(content, "%s  (sahip: %d)" % [item["name"], game.equip.get(id, 0)], BORDER, true)
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
	_confirm("Zorunlu paketi al", ["Ödeme: %s" % Data.usd(float(package["price"])), "Kaplanan alan: %d m²" % int(package["area"])], "Satın al", _buy_package)

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
		_row(box, "Aylık kira (12 ay)", Data.usd(float(factory["rent"])), GREEN, 18)
		box.add_child(_button("İncele", _open_detail.bind("factory", factory["id"]), true, false, true))

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

func _detail_factory(factory: Dictionary) -> void:
	var hero := _card(content, "", BORDER, true)
	hero.add_child(_image_slot("factories", factory["id"], factory["tint"], 200))
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
	box.add_child(_label("Sözleşmeyi erken bırakırsan %d kira (%s) ceza ödersin; peşin ödenen kira iade edilmez. Makineler, ekipman ve kabul edilmiş işler kaybolur." % [Data.EXIT_FEE_RENTS, Data.usd(fee)], 14, TEXT))
	if reason != "":
		box.add_child(_label(reason, 13, RED))
	box.add_child(_button("Vazgeç", _back))
	box.add_child(_button("Bırak ve %s öde" % Data.usd(fee), _leave_factory, true, reason != "" or fee > float(game.cash)))

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
