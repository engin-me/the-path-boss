extends Control

# Mobile-portrait factory shell (fixed header, sticky bar, page area, fixed
# bottom tabs). UI over MOCK data: rules are NOT wired to BossState and nothing
# here is a FREEZE decision. Proposed rules: docs/ideas/IDEA-015 and IDEA-016.

const Data = preload("res://scripts/shell/shell_data.gd")
const BossState = preload("res://scripts/boss_state.gd")

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

var state := {}
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
var sticky: VBoxContainer
var stage: Control
var background: TextureRect
var content: VBoxContainer
var tab_buttons := {}
var overlay: Control
var listing_cards := {}
var area_label: Label
var area_used_bar: ProgressBar
var area_preview_bar: ProgressBar

func _ready() -> void:
	var window := get_window()
	if window != null:
		window.content_scale_size = Vector2i(540, 960)
		window.size = Vector2i(540, 960)
	_reset_state()
	_build()
	_render()

func _reset_state() -> void:
	state = {
		"month": 1, "cash": 400.0, "invested": 0.0,
		"factory_id": "", "term": 12, "months_left": 0, "prepaid_months": 0,
		"machines": [], "next_uid": 1, "package": false, "equip": {},
		"offers": Data.generate_offers(1), "accepted": [], "last_report": "",
		"skills": {}, "credit": {}
	}
	for i in BossState.SKILLS.size():
		state["skills"][BossState.SKILLS[i]] = 40 + (i * 7) % 40

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

# ------------------------------------------------------------------ state queries

func _factory() -> Dictionary:
	return Data.factory_by_id(String(state["factory_id"]))

func _base_rent() -> float:
	var factory := _factory()
	if factory.is_empty():
		return 0.0
	return roundf(float(factory["rent"]) * float(Data.term_by_months(int(state["term"]))["factor"]))

func _delivered() -> Array:
	var list: Array = []
	for machine in state["machines"]:
		if int(machine["arrive"]) <= int(state["month"]):
			list.append(machine)
	return list

func _free_machines() -> Array:
	var list: Array = []
	for machine in _delivered():
		if int(machine["job"]) == 0:
			list.append(machine)
	return list

func _capacity_total() -> int:
	if not state["package"]:
		return 0
	var total := 0
	for machine in _delivered():
		total += int(machine["capacity"])
	return total

func _package() -> Dictionary:
	var factory := _factory()
	return Data.package_for(int(factory["m2"])) if not factory.is_empty() else {"items": {}, "price": 0.0, "area": 0.0}

func _area_used() -> float:
	var used := 0.0
	for machine in state["machines"]:
		used += float(machine["area"])
	if state["package"]:
		used += float(_package()["area"])
	for id in state["equip"]:
		used += float(Data.EQUIPMENT[id]["area"]) * int(state["equip"][id])
	return used

func _monthly_running() -> float:
	var cost := 0.0
	for machine in _delivered():
		cost += float(machine["energy"]) + float(machine["consumables"]) + Data.WAGE * int(machine["personnel"])
	return cost

func _invested() -> float:
	var total := 0.0
	for machine in state["machines"]:
		total += float(machine["paid"])
	return total

func _current_value(machine: Dictionary) -> float:
	var owned := maxi(0, int(state["month"]) - int(machine["bought"]))
	return roundf(float(machine["paid"]) * pow(0.98, owned))

# Greedy assignment of free delivered machines to a job's requirement list.
func _assign(reqs: Array) -> Dictionary:
	var pool: Array = _free_machines().duplicate()
	var ordered: Array = reqs.duplicate()
	ordered.sort_custom(func(a, b): return int(a["level"]) > int(b["level"]))
	var uids: Array = []
	var missing: Array = []
	for req in ordered:
		var short := int(req["count"])
		for _i in int(req["count"]):
			var best: Dictionary = {}
			for machine in pool:
				if machine["type"] == req["type"] and int(machine["level"]) >= int(req["level"]):
					if best.is_empty() or int(machine["level"]) < int(best["level"]):
						best = machine
			if not best.is_empty():
				uids.append(best["uid"])
				pool.erase(best)
				short -= 1
		if short > 0:
			missing.append("%d× %s %s" % [short, Data.LEVELS[int(req["level"])], req["type"]])
	return {"ok": missing.is_empty(), "uids": uids, "missing": missing}

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

func _render() -> void:
	header_date.text = Data.month_label(int(state["month"]))
	header_money.text = Data.usd(float(state["cash"]))
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
	if page != "ozet" or detail != "" or state["factory_id"] == "":
		return null
	var gradient := Gradient.new()
	var tint: Color = _factory()["tint"]
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
	_chips(content, [{"id": "genel", "title": "Genel"}, {"id": "dep", "title": "Departmanlar"}, {"id": "rapor", "title": "Rapor"}],
		subtab["ozet"], func(id: String) -> void:
			subtab["ozet"] = id
			_render())
	if state["factory_id"] == "":
		var empty := _card(content, "Henüz fabrikan yok", GOLD)
		empty.add_child(_label("Önce bir yer kirala. Sonra tezgah alıp iş kabul edebilirsin.", 14, MUTED))
		empty.add_child(_button("Kiralık yerlere bak", _on_tab.bind("fabrika"), true))
		return
	match subtab["ozet"]:
		"dep":
			var box := _card(content, "Departmanlar ve Düzelt")
			box.add_child(_label("Sorun satırları, şans etiketleri ve Düzelt düğmesi burada görünecek (BossState bağlanınca).", 14, MUTED))
		"rapor":
			var box := _card(content, "Ay raporu")
			box.add_child(_label(state["last_report"] if state["last_report"] != "" else "İlk ay: henüz rapor yok.", 14, MUTED))
		_:
			_ozet_general()

func _ozet_general() -> void:
	var factory := _factory()
	content.add_child(_label(factory["name"], 22, TEXT))
	content.add_child(_label("%s · %d m² · %.1f m yükseklik" % [factory["region"], factory["m2"], factory["height"]], 13, MUTED))
	if not state["package"]:
		var warn := _card(content, "Zorunlu ekipman eksik", GOLD)
		warn.add_child(_label("Zorunlu ekipman paketi alınmadan kapasite kullanılamaz.", 13, MUTED))
		warn.add_child(_button("Ekipmana git", _go_equipment, true))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content.add_child(grid)
	var delivered := _delivered().size()
	var transit: int = state["machines"].size() - delivered
	var value := 0.0
	for machine in state["machines"]:
		value += _current_value(machine)
	var running := _monthly_running()
	var credit: Dictionary = state["credit"]
	var tiles := [
		["Makine", "%d%s" % [delivered, " (+%d yolda)" % transit if transit > 0 else ""]],
		["Yatırım tutarı", Data.usd(_invested())],
		["Güncel değer", Data.usd(value)],
		["OEE", "—"],
		["Kapasite", "%d birim/ay" % _capacity_total()],
		["Boşta makine", str(_free_machines().size())],
		["Aylık işletme", Data.usd(running)],
		["Sözleşme", "%d ay kaldı" % int(state["months_left"])]
	]
	if not credit.is_empty():
		tiles.append(["Kredi borcu", Data.usd(float(credit["balance"]))])
	for tile in tiles:
		var box := _card(grid, "", BORDER)
		box.add_child(_label(tile[0], 12, MUTED))
		box.add_child(_label(tile[1], 18, TEXT))
		_panel_of(box).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(_button("Ayı bitir ▶", _end_month, true))

func _go_equipment() -> void:
	subtab["tezgah"] = "ekipman"
	_on_tab("tezgah")

func _end_month() -> void:
	var lines: Array = []
	var month: int = state["month"]
	# rent (first half of the term is prepaid when chosen)
	if int(state["prepaid_months"]) > 0:
		state["prepaid_months"] = int(state["prepaid_months"]) - 1
		lines.append("Kira: peşin ödenmişti")
	else:
		state["cash"] = float(state["cash"]) - _base_rent()
		lines.append("Kira: %s" % Data.usd(_base_rent()))
	var running := _monthly_running()
	state["cash"] = float(state["cash"]) - running
	lines.append("Enerji, sarf ve personel: %s" % Data.usd(running))
	# credit installment
	var credit: Dictionary = state["credit"]
	if not credit.is_empty():
		var interest := float(credit["balance"]) * float(credit["rate"])
		var principal := float(credit["installment"]) - interest
		credit["balance"] = maxf(0.0, float(credit["balance"]) - principal)
		credit["left"] = int(credit["left"]) - 1
		state["cash"] = float(state["cash"]) - float(credit["installment"])
		lines.append("Kredi taksidi: %s" % Data.usd(float(credit["installment"])))
		if int(credit["left"]) <= 0:
			state["credit"] = {}
			lines.append("Kredi kapandı; ipotek kalktı.")
	# jobs: material tranches every 6 months, delivery pays revenue
	var remaining: Array = []
	for job in state["accepted"]:
		job["elapsed"] = int(job["elapsed"]) + 1
		if int(job["elapsed"]) % 6 == 0 and float(job["material_left"]) > 0.0 and int(job["elapsed"]) < int(job["months"]):
			var tranche: float = minf(float(job["material_left"]), float(job["material_tranche"]))
			state["cash"] = float(state["cash"]) - tranche
			job["material_left"] = float(job["material_left"]) - tranche
			lines.append("Hammadde dilimi: %s (%s)" % [Data.usd(tranche), job["title"]])
		if int(job["elapsed"]) >= int(job["months"]):
			state["cash"] = float(state["cash"]) + float(job["revenue"])
			lines.append("Teslim: %s (+%s)" % [job["title"], Data.usd(float(job["revenue"]))])
			for machine in state["machines"]:
				if int(machine["job"]) == int(job["id"]):
					machine["job"] = 0
		else:
			remaining.append(job)
	state["accepted"] = remaining
	state["months_left"] = int(state["months_left"]) - 1
	if int(state["months_left"]) <= 0:
		state["months_left"] = int(state["term"])
		lines.append("Sözleşme aynı koşulla yenilendi.")
	state["month"] = month + 1
	state["offers"] = Data.generate_offers(int(state["month"]))
	for machine in state["machines"]:
		if int(machine["arrive"]) == int(state["month"]):
			lines.append("Teslim alındı: %s · %d personel işe başladı" % [machine["model"], machine["personnel"]])
	state["last_report"] = "Mock rapor (kurallar bağlı değil)\n" + "\n".join(lines)
	_render()

# ------------------------------------------------------------------ İşler

func _page_isler() -> void:
	if state["factory_id"] == "":
		_locked("İş teklifleri fabrikan olunca açılır.")
		return
	var offers: Array = state["offers"]
	var taken: Array = []
	for job in state["accepted"]:
		taken.append(job["id"])
	var doable := 0
	for offer in offers:
		if _assign(offer["reqs"])["ok"] and state["package"]:
			doable += 1
	_chips(content, [
		{"id": "tum", "title": "Tümü (%d)" % offers.size()},
		{"id": "yapabilir", "title": "Yapabileceklerim (%d)" % doable},
		{"id": "kabul", "title": "Kabul edilenler (%d)" % state["accepted"].size()}],
		subtab["isler"], func(id: String) -> void:
			subtab["isler"] = id
			_render())
	var box := _card(content, "Makineler")
	var free := _free_machines().size()
	box.add_child(_bar(_delivered().size() - free, maxi(1, _delivered().size())))
	box.add_child(_label("%d makine işte, %d boşta · zorunlu ekipman: %s" % [_delivered().size() - free, free, "tamam" if state["package"] else "EKSİK"], 13, MUTED if state["package"] else RED))
	if subtab["isler"] == "kabul":
		if state["accepted"].is_empty():
			content.add_child(_label("Henüz kabul edilmiş iş yok.", 14, MUTED))
		for job in state["accepted"]:
			var card := _card(content, job["title"], GREEN)
			_row(card, "Müşteri", job["customer"])
			_row(card, "Kalan süre", "%d ay" % (int(job["months"]) - int(job["elapsed"])))
			_row(card, "Gelir (tesliminde)", Data.usd(float(job["revenue"])), GREEN)
			_row(card, "Ayrılan makine", str(job["uids"].size()))
		return
	for offer in offers:
		if taken.has(offer["id"]):
			continue
		var fits: bool = bool(_assign(offer["reqs"])["ok"]) and bool(state["package"])
		if subtab["isler"] == "yapabilir" and not fits:
			continue
		_offer_card(offer)

func _offer_card(offer: Dictionary) -> void:
	var check := _assign(offer["reqs"])
	var box := _card(content, offer["title"], GREEN if check["ok"] else BORDER)
	box.add_child(_label(offer["customer"], 12, MUTED))
	for req in offer["reqs"]:
		var own := _own_count(req)
		var enough: bool = own >= int(req["count"])
		_row(box, "Gereken makine" if req == offer["reqs"][0] else "", "%s  %s" % [Data.req_text(req), "✔" if enough else "(%d var)" % own], TEXT if enough else RED)
	_row(box, "Süre", "%d ay" % offer["months"])
	_row(box, "Gelir", Data.usd(float(offer["revenue"])), GREEN)
	_row(box, "Hammadde maliyeti (%%%d)" % int(roundf(float(offer["share"]) * 100.0)), Data.usd(float(offer["material"])))
	var first := _first_payment(offer)
	if first < float(offer["material"]):
		box.add_child(_label("Kabulde %s düşer; kalanı her 6 ayın başında." % Data.usd(first), 12, GOLD))
	else:
		box.add_child(_label("Hammadde kabulde düşer.", 12, GOLD))
	var reason := ""
	if not state["package"]:
		reason = "Zorunlu ekipman eksik"
	elif not check["ok"]:
		reason = "Eksik: " + ", ".join(check["missing"])
	elif first > float(state["cash"]):
		reason = "Yetersiz nakit"
	box.add_child(_button("Kabul et" if reason == "" else reason, _ask_accept.bind(offer["id"]), reason == "", reason != ""))

func _own_count(req: Dictionary) -> int:
	var count := 0
	for machine in _delivered():
		if machine["type"] == req["type"] and int(machine["level"]) >= int(req["level"]):
			count += 1
	return count

# Material for the first 6 months is paid on acceptance; jobs of 6 months or less pay in full.
func _first_payment(offer: Dictionary) -> float:
	var months: int = offer["months"]
	if months <= 6:
		return float(offer["material"])
	return roundf(float(offer["material"]) * 6.0 / float(months))

func _ask_accept(id: int) -> void:
	var offer := _offer_by_id(id)
	if offer.is_empty():
		return
	var reqs_text: Array = []
	for req in offer["reqs"]:
		reqs_text.append(Data.req_text(req))
	_confirm("İşi kabul et", [
		offer["title"] + " · " + offer["customer"],
		"Ayrılacak makineler: " + ", ".join(reqs_text),
		"Kabulde bakiyeden düşen hammadde: %s" % Data.usd(_first_payment(offer)),
		"Gelir tesliminde yazılır: %s (%d ay)" % [Data.usd(float(offer["revenue"])), offer["months"]]
	], "Kabul et", _accept_offer.bind(id))

func _offer_by_id(id: int) -> Dictionary:
	for offer in state["offers"]:
		if offer["id"] == id:
			return offer
	return {}

func _accept_offer(id: int) -> void:
	var offer := _offer_by_id(id)
	if offer.is_empty():
		return
	var check := _assign(offer["reqs"])
	if not check["ok"] or not state["package"]:
		return
	var first := _first_payment(offer)
	state["cash"] = float(state["cash"]) - first
	var job: Dictionary = offer.duplicate(true)
	job["elapsed"] = 0
	job["uids"] = check["uids"]
	job["material_left"] = float(offer["material"]) - first
	job["material_tranche"] = roundf(float(offer["material"]) * 6.0 / float(offer["months"]))
	for machine in state["machines"]:
		if check["uids"].has(machine["uid"]):
			machine["job"] = job["id"]
	state["accepted"].append(job)
	_render()

# ------------------------------------------------------------------ Tezgah

func _page_tezgah() -> void:
	if state["factory_id"] == "":
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
	for type in Data.TYPES:
		type_options.append({"id": type, "title": type})
	_chips(content, type_options, type_filter, func(id: String) -> void:
		type_filter = id
		selected_listing = -1
		_render())
	for listing in Data.machine_listings():
		if type_filter != "Tümü" and listing["type"] != type_filter:
			continue
		_machine_card(listing)
	_update_area_preview()

func _build_area_bar() -> void:
	var factory := _factory()
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
	area_used_bar = _bar(_area_used(), float(factory["m2"]), GREEN)
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
	var factory := _factory()
	var extra := hover_area
	if extra < 0.0:
		extra = 0.0
		if selected_listing >= 0:
			for listing in Data.machine_listings():
				if listing["uid"] == selected_listing:
					extra = float(listing["area"])
	var used := _area_used()
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
	box.add_child(_image_slot("machines", "%s_%d" % [String(listing["type"]).to_lower(), listing["level"]], Color("#26313d")))
	box.add_child(_label(listing["model"], 22, TEXT))
	var age_text := "Yeni (sıfır)" if int(listing["age"]) == 0 else "İkinci el · %d yaşında" % listing["age"]
	box.add_child(_label("%s · %s · %s" % [listing["type"], Data.LEVELS[int(listing["level"])], age_text], 15, MUTED))
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
	var factory := _factory()
	var reason := ""
	if float(listing["price"]) > float(state["cash"]):
		reason = "Yetersiz nakit"
	elif _area_used() + float(listing["area"]) > float(factory["m2"]):
		reason = "Alan yetmiyor"
	elif float(listing["height"]) > float(factory["height"]):
		reason = "Tavan çok alçak"
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

func _listing_by_uid(uid: int) -> Dictionary:
	for listing in Data.machine_listings():
		if listing["uid"] == uid:
			return listing
	return {}

func _ask_buy(uid: int) -> void:
	var listing := _listing_by_uid(uid)
	if listing.is_empty():
		return
	var arrive: int = int(state["month"]) + int(listing["delivery"])
	_confirm("Satın alma onayı", [
		"%s · %s %s" % [listing["model"], Data.LEVELS[int(listing["level"])], listing["type"]],
		"Ödeme şimdi: %s" % Data.usd(float(listing["price"])),
		"Teslim: %d ay sonra (%s). Teslime kadar kapasite artmaz." % [listing["delivery"], Data.month_label(arrive)],
		"Teslimde %d personel otomatik işe başlar (kişi başı %s/ay)." % [listing["personnel"], Data.usd(Data.WAGE)],
		"Aylık işletme: %s enerji + %s sarf" % [Data.usd(float(listing["energy"])), Data.usd(float(listing["consumables"]))],
		"Alan: %d m²" % listing["area"]
	], "Satın al", _buy.bind(uid))

func _buy(uid: int) -> void:
	var listing := _listing_by_uid(uid)
	if listing.is_empty():
		return
	state["cash"] = float(state["cash"]) - float(listing["price"])
	var machine: Dictionary = listing.duplicate()
	machine["uid"] = state["next_uid"]
	machine["paid"] = float(listing["price"])
	machine["bought"] = state["month"]
	machine["arrive"] = int(state["month"]) + int(listing["delivery"])
	machine["job"] = 0
	machine["mortgaged"] = false
	state["next_uid"] = int(state["next_uid"]) + 1
	state["machines"].append(machine)
	selected_listing = -1
	_render()

# ------------------------------------------------------------------ Ekipman

func _page_equipment() -> void:
	var factory := _factory()
	var package := _package()
	var box := _card(content, "Zorunlu ekipman paketi" + (" ✔" if state["package"] else ""), GREEN if state["package"] else GOLD, true)
	box.add_child(_label("%s fabrika için: üretim yapabilmek şart. Eksikse kapasite kullanılamaz." % Data.size_class(int(factory["m2"])).capitalize(), 14, MUTED))
	for id in package["items"]:
		var item: Dictionary = Data.EQUIPMENT[id]
		_row(box, "%s × %d" % [item["name"], package["items"][id]], Data.usd(float(item["price"]) * int(package["items"][id])), TEXT, 15)
	_row(box, "Alan", "%d m²" % int(package["area"]), TEXT, 15)
	_row(box, "Paket fiyatı", Data.usd(float(package["price"])), GREEN, 17)
	var reason := ""
	if state["package"]:
		reason = "Paket alındı"
	elif float(package["price"]) > float(state["cash"]):
		reason = "Yetersiz nakit"
	elif _area_used() + float(package["area"]) > float(factory["m2"]):
		reason = "Alan yetmiyor"
	box.add_child(_button("Paketi satın al" if reason == "" else reason, _ask_package, reason == "", reason != "", true))
	content.add_child(_label("İsteğe bağlı ekipman", 20, TEXT))
	content.add_child(_label("Kesici uç ve takım sarfı tezgahın aylık işletme giderine dahildir.", 12, MUTED))
	for id in Data.OPTIONAL_ORDER:
		_equipment_card(id, factory)

func _equipment_card(id: String, factory: Dictionary) -> void:
	var item: Dictionary = Data.EQUIPMENT[id]
	var qty: int = equip_qty.get(id, 1)
	var box := _card(content, "%s  (sahip: %d)" % [item["name"], state["equip"].get(id, 0)], BORDER, true)
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
	var total_price := float(item["price"]) * qty
	var total_area := float(item["area"]) * qty
	var reason := ""
	if item.has("min_height") and float(factory["height"]) < float(item["min_height"]):
		reason = "Tavan çok alçak"
	elif total_price > float(state["cash"]):
		reason = "Yetersiz nakit"
	elif _area_used() + total_area > float(factory["m2"]):
		reason = "Alan yetmiyor"
	box.add_child(_button("Satın al · %s" % Data.usd(total_price) if reason == "" else reason, _ask_equipment.bind(id), reason == "", reason != "", true))

func _change_qty(id: String, delta: int) -> void:
	equip_qty[id] = maxi(1, int(equip_qty.get(id, 1)) + delta)
	_render()

func _ask_package() -> void:
	var package := _package()
	_confirm("Zorunlu paketi al", ["Ödeme: %s" % Data.usd(float(package["price"])), "Kaplanan alan: %d m²" % int(package["area"])], "Satın al", _buy_package)

func _buy_package() -> void:
	state["cash"] = float(state["cash"]) - float(_package()["price"])
	state["invested"] = float(state["invested"]) + float(_package()["price"])
	state["package"] = true
	_render()

func _ask_equipment(id: String) -> void:
	var item: Dictionary = Data.EQUIPMENT[id]
	var qty: int = equip_qty.get(id, 1)
	_confirm("Ekipman satın al", ["%s × %d" % [item["name"], qty], "Ödeme: %s" % Data.usd(float(item["price"]) * qty)], "Satın al", _buy_equipment.bind(id, qty))

func _buy_equipment(id: String, qty: int) -> void:
	state["cash"] = float(state["cash"]) - float(Data.EQUIPMENT[id]["price"]) * qty
	state["equip"][id] = int(state["equip"].get(id, 0)) + qty
	equip_qty[id] = 1
	_render()

# ------------------------------------------------------------------ Fabrika

func _page_fabrika() -> void:
	if state["factory_id"] != "":
		var factory := _factory()
		var box := _card(content, "Kiraladığın yer", GREEN, true)
		box.add_child(_image_slot("factories", factory["id"], factory["tint"]))
		_row(box, "Fabrika", factory["name"], TEXT, 16)
		_row(box, "Alan / yükseklik", "%d m² · %.1f m" % [factory["m2"], factory["height"]], TEXT, 16)
		_row(box, "Aylık kira", Data.usd(_base_rent()), TEXT, 16)
		_row(box, "Sözleşme", "%d ay · %d ay kaldı" % [state["term"], state["months_left"]], TEXT, 16)
		if int(state["prepaid_months"]) > 0:
			_row(box, "Peşin ödenmiş kira", "%d ay" % state["prepaid_months"], GREEN, 16)
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

func _prepay_quote(factory: Dictionary, months: int) -> Dictionary:
	var term := Data.term_by_months(months)
	var rent := roundf(float(factory["rent"]) * float(term["factor"]))
	var half := months / 2
	var discount := float(term["prepay_discount"])
	return {"rent": rent, "half": half, "discount": discount, "amount": snappedf(rent * half * (1.0 - discount), 0.01)}

# ------------------------------------------------------------------ Profil

func _page_profil() -> void:
	var skills := _card(content, "Yetkinlikler")
	for name in BossState.SKILLS:
		var row := HBoxContainer.new()
		row.add_child(_label(name, 13, MUTED))
		row.add_child(_label(str(state["skills"][name]), 13, TEXT, false))
		skills.add_child(row)
		skills.add_child(_bar(float(state["skills"][name]), 100.0))
	var stats := _card(content, "Statlar")
	for stat in Data.STATS_LIST:
		_row(stats, stat, "—")
	stats.add_child(_label("Statlar yetkinlik puanı vermez (FRZ-007 v3). Personel niteliği ve eğitimi şimdilik kapsam dışı (not).", 12, MUTED))
	var actions := _card(content, "Yönetim")
	actions.add_child(_button("Danışman Ara", _open_detail.bind("consultant")))
	actions.add_child(_button("Kredi", _open_detail.bind("credit")))

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
			var box := _card(content)
			box.add_child(_label("Danışman pazarı (FRZ-006 v2) burada açılacak.", 14, MUTED))
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
	var quote := _prepay_quote(factory, picked_term)
	var prepay := CheckBox.new()
	prepay.text = "İlk %d ayın kirasını peşin öde (%%%d indirim)" % [quote["half"], int(roundf(float(quote["discount"]) * 100.0))]
	prepay.add_theme_font_size_override("font_size", 15)
	prepay.button_pressed = picked_prepay
	prepay.toggled.connect(_toggle_prepay)
	terms.add_child(prepay)
	if picked_prepay:
		terms.add_child(_label("Şimdi ödenecek: %s" % Data.usd(float(quote["amount"])), 15, GREEN))
	var due := float(quote["amount"]) if picked_prepay else 0.0
	content.add_child(_button("Kirala", _ask_rent.bind(factory["id"]), true, due > float(state["cash"]), true))

func _pick_term(months: int) -> void:
	picked_term = months
	_render()

func _toggle_prepay(on: bool) -> void:
	picked_prepay = on
	_render()

func _ask_rent(id: String) -> void:
	var factory := Data.factory_by_id(id)
	var quote := _prepay_quote(factory, picked_term)
	var lines: Array = [
		"%s · %d m² · %.1f m" % [factory["name"], factory["m2"], factory["height"]],
		"Aylık kira: %s · sözleşme %d ay" % [Data.usd(float(quote["rent"])), picked_term]
	]
	if picked_prepay:
		lines.append("Şimdi ödenecek peşin kira (%d ay, %%%d indirimli): %s. Peşin ödenen kira iade edilmez." % [quote["half"], int(roundf(float(quote["discount"]) * 100.0)), Data.usd(float(quote["amount"]))])
	_confirm("Kiralama onayı", lines, "Kirala", _rent_factory.bind(id),
		"Sözleşmeyi erken bırakırsan %d kira (%s) ceza ödersin." % [Data.EXIT_FEE_RENTS, Data.usd(float(quote["rent"]) * Data.EXIT_FEE_RENTS)])

func _rent_factory(id: String) -> void:
	var factory := Data.factory_by_id(id)
	var quote := _prepay_quote(factory, picked_term)
	state["factory_id"] = id
	state["term"] = picked_term
	state["months_left"] = picked_term
	state["prepaid_months"] = 0
	if picked_prepay:
		state["cash"] = float(state["cash"]) - float(quote["amount"])
		state["prepaid_months"] = int(quote["half"])
	detail = ""
	page = "ozet"
	_render()

func _detail_leave() -> void:
	var fee := _base_rent() * Data.EXIT_FEE_RENTS
	var box := _card(content, "Emin misin?", GOLD)
	box.add_child(_label("Sözleşmeyi erken bırakırsan %d kira (%s) ceza ödersin; peşin ödenen kira iade edilmez. Makineler ve kabul edilmiş işler bu mock'ta silinir." % [Data.EXIT_FEE_RENTS, Data.usd(fee)], 14, TEXT))
	box.add_child(_button("Vazgeç", _back))
	box.add_child(_button("Bırak ve %s öde" % Data.usd(fee), _leave_factory.bind(fee), true, fee > float(state["cash"])))

func _leave_factory(fee: float) -> void:
	state["cash"] = float(state["cash"]) - fee
	state["factory_id"] = ""
	state["machines"] = []
	state["accepted"] = []
	state["package"] = false
	state["equip"] = {}
	state["prepaid_months"] = 0
	state["credit"] = {}
	detail = ""
	page = "fabrika"
	_render()

# ------------------------------------------------------------------ Kredi

func _detail_credit() -> void:
	var offer: Dictionary = Data.CREDIT
	var credit: Dictionary = state["credit"]
	if not credit.is_empty():
		_credit_active(credit)
		return
	var installment := Data.installment(float(offer["amount"]), float(offer["rate"]), int(offer["months"]))
	var need := float(offer["amount"]) * float(offer["collateral"])
	var box := _card(content, offer["bank"], BORDER, true)
	_row(box, "Kredi tutarı", Data.usd(float(offer["amount"])), GREEN, 18)
	_row(box, "Faiz", "%%%.1f / ay" % (float(offer["rate"]) * 100.0), TEXT, 16)
	_row(box, "Vade", "%d ay" % offer["months"], TEXT, 16)
	_row(box, "Aylık taksit", Data.usd(installment), TEXT, 16)
	_row(box, "Gereken teminat", "%s değerinde ipotek (%%%d)" % [Data.usd(need), int(float(offer["collateral"]) * 100.0)], GOLD, 16)
	_row(box, "Erken kapatma cezası", "kalan anaparanın %%%d'si" % int(float(offer["early_fee"]) * 100.0), TEXT, 16)
	box.add_child(_label("Teminat olarak teslim alınmış ve ipoteksiz makineler gösterilir; değer güncel piyasa değeridir. İpotekli makine satılamaz.", 12, MUTED))
	var pick := _card(content, "Teminat seç", BORDER, true)
	var total := 0.0
	var any := false
	for machine in _delivered():
		if machine["mortgaged"]:
			continue
		any = true
		var value := _current_value(machine)
		var check := CheckBox.new()
		check.text = "%s · %s" % [machine["model"], Data.usd(value)]
		check.add_theme_font_size_override("font_size", 15)
		check.button_pressed = collateral_picks.has(machine["uid"])
		check.toggled.connect(_toggle_collateral.bind(machine["uid"]))
		pick.add_child(check)
		if collateral_picks.has(machine["uid"]):
			total += value
	if not any:
		pick.add_child(_label("İpoteklenebilir makine yok (teslim alınmış tezgah gerekir).", 13, MUTED))
	pick.add_child(_label("Bina (satın alma yakında) — kilitli", 13, MUTED))
	_row(pick, "Seçilen teminat", Data.usd(total), GREEN if total >= need else RED, 16)
	content.add_child(_button("Krediyi al" if total >= need else "Teminat yetersiz (%s gerek)" % Data.usd(need), _ask_credit, true, total < need, true))
	content.add_child(_label("Kriz kredisi (tek seferlik, teminatsız) ayrı bir araçtır; sonra bağlanacak.", 12, MUTED))

func _credit_active(credit: Dictionary) -> void:
	var offer: Dictionary = Data.CREDIT
	var fee := float(credit["balance"]) * float(offer["early_fee"])
	var box := _card(content, offer["bank"] + " · aktif kredi", GOLD, true)
	_row(box, "Kalan anapara", Data.usd(float(credit["balance"])), TEXT, 16)
	_row(box, "Aylık taksit", Data.usd(float(credit["installment"])), TEXT, 16)
	_row(box, "Kalan vade", "%d ay" % credit["left"], TEXT, 16)
	_row(box, "İpotekli makine", str(credit["uids"].size()), TEXT, 16)
	_row(box, "Erken kapatma cezası", Data.usd(fee), GOLD, 16)
	var total_due := float(credit["balance"]) + fee
	box.add_child(_button("Erken kapat · %s" % Data.usd(total_due), _ask_close_credit, false, total_due > float(state["cash"]), true))

func _toggle_collateral(on: bool, uid: int) -> void:
	if on and not collateral_picks.has(uid):
		collateral_picks.append(uid)
	elif not on:
		collateral_picks.erase(uid)
	_render()

func _ask_credit() -> void:
	var offer: Dictionary = Data.CREDIT
	var installment := Data.installment(float(offer["amount"]), float(offer["rate"]), int(offer["months"]))
	_confirm("Kredi onayı", [
		"%s · %s · %d ay · %%%.1f/ay" % [offer["bank"], Data.usd(float(offer["amount"])), offer["months"], float(offer["rate"]) * 100.0],
		"Aylık taksit: %s" % Data.usd(installment),
		"İpotek: %d makine (kredi kapanana kadar satılamaz)" % collateral_picks.size(),
		"Erken kapatma cezası: kalan anaparanın %%%d'si" % int(float(offer["early_fee"]) * 100.0)
	], "Krediyi al", _take_credit)

func _take_credit() -> void:
	var offer: Dictionary = Data.CREDIT
	var installment := Data.installment(float(offer["amount"]), float(offer["rate"]), int(offer["months"]))
	state["credit"] = {"balance": float(offer["amount"]), "rate": float(offer["rate"]), "installment": installment,
		"left": int(offer["months"]), "uids": collateral_picks.duplicate()}
	for machine in state["machines"]:
		if collateral_picks.has(machine["uid"]):
			machine["mortgaged"] = true
	state["cash"] = float(state["cash"]) + float(offer["amount"])
	collateral_picks = []
	_render()

func _ask_close_credit() -> void:
	var credit: Dictionary = state["credit"]
	var fee := float(credit["balance"]) * float(Data.CREDIT["early_fee"])
	_confirm("Krediyi erken kapat", ["Kalan anapara: %s" % Data.usd(float(credit["balance"])), "Erken kapatma cezası: %s" % Data.usd(fee), "İpotek kalkar."],
		"Öde ve kapat", _close_credit)

func _close_credit() -> void:
	var credit: Dictionary = state["credit"]
	state["cash"] = float(state["cash"]) - float(credit["balance"]) * (1.0 + float(Data.CREDIT["early_fee"]))
	for machine in state["machines"]:
		machine["mortgaged"] = false
	state["credit"] = {}
	_render()
