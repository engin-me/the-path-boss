extends Control

# Mobile-portrait factory shell (fixed header, page area, fixed bottom tabs).
# UI skeleton over mock data: rules are NOT wired to BossState yet and nothing
# here is a FREEZE decision. See docs/ideas/IDEA-015 for the proposed rules.

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
const RED := Color("#f08080")

const TABS := [
	{"id": "ozet", "icon": "🏠", "title": "Özet"},
	{"id": "isler", "icon": "📋", "title": "İşler"},
	{"id": "tezgah", "icon": "⚙", "title": "Tezgah"},
	{"id": "fabrika", "icon": "🏭", "title": "Fabrika"},
	{"id": "profil", "icon": "👤", "title": "Profil"}
]

var state := {
	"month": 1, "cash": 400.0, "invested": 0.0,
	"factory_id": "", "term": 12, "months_left": 0,
	"machines": {"A": 0, "B": 0, "C": 0},
	"accepted": [], "last_report": "",
	"skills": {}, "credit": 0.0
}
var page := "ozet"
var subtab := {"ozet": "genel", "isler": "teklif"}
var detail := ""
var detail_arg := ""
var picked_term := 12

var header_date: Label
var header_money: Label
var stage: Control
var background: TextureRect
var content: VBoxContainer
var tab_buttons := {}
var overlay: Control

func _ready() -> void:
	var window := get_window()
	if window != null:
		window.content_scale_size = Vector2i(540, 960)
		window.size = Vector2i(540, 960)
	for i in BossState.SKILLS.size():
		state["skills"][BossState.SKILLS[i]] = 40 + (i * 7) % 40
	_build()
	_render()

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
	content.add_theme_constant_override("separation", 10)
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

# Returns the inner VBox of a new card added to `parent`.
func _card(parent: Control, title := "", accent := BORDER) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _box(Color(PANEL.r, PANEL.g, PANEL.b, 0.94), accent, 12, 1))
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 6)
	panel.add_child(_margin(inner, 14, 12))
	parent.add_child(panel)
	if title != "":
		inner.add_child(_label(title, 16, TEXT))
	return inner

func _button(text: String, callback: Callable, primary := false, disabled := false) -> Button:
	var button := Button.new()
	button.text = text
	button.disabled = disabled
	button.custom_minimum_size = Vector2(0, 44)
	button.add_theme_font_size_override("font_size", 15)
	if primary:
		button.add_theme_stylebox_override("normal", _box(Color("#1f7a4d"), GREEN, 10, 1))
		button.add_theme_stylebox_override("hover", _box(Color("#26955e"), GREEN, 10, 1))
		button.add_theme_stylebox_override("pressed", _box(Color("#186040"), GREEN, 10, 1))
	button.pressed.connect(callback)
	return button

func _row(parent: Control, left: String, right: String, color := TEXT) -> void:
	var row := HBoxContainer.new()
	row.add_child(_label(left, 14, MUTED))
	var value := _label(right, 14, color, false)
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

# ------------------------------------------------------------------ state

func _factory() -> Dictionary:
	return Data.factory_by_id(String(state["factory_id"]))

func _rent() -> float:
	var factory := _factory()
	if factory.is_empty():
		return 0.0
	var factor := 1.0
	for term in Data.TERMS:
		if term["months"] == state["term"]:
			factor = term["factor"]
	return roundf(float(factory["rent"]) * factor)

func _capacity_total() -> int:
	var total := 0
	for id in state["machines"]:
		total += int(state["machines"][id]) * int(BossState.MACHINES[id]["capacity"])
	return total

func _capacity_used() -> int:
	var used := 0
	for job in state["accepted"]:
		used += int(job["units"])
	return used

func _best_quality() -> int:
	var best := 0
	for id in state["machines"]:
		if int(state["machines"][id]) > 0:
			best = maxi(best, int(BossState.MACHINES[id]["quality"]))
	return best

func _area_used() -> int:
	var used := 0
	for id in state["machines"]:
		used += int(state["machines"][id]) * int(Data.MACHINE_EXTRA[id]["area"])
	return used

func _machine_count() -> int:
	var count := 0
	for id in state["machines"]:
		count += int(state["machines"][id])
	return count

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
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content.add_child(grid)
	var invested := float(state["invested"])
	var tiles := [
		["Makine", str(_machine_count())],
		["Yatırım tutarı", Data.usd(invested)],
		["Güncel değer", Data.usd(invested * 0.98)],
		["OEE", "—"],
		["Kapasite", "%d / %d" % [_capacity_used(), _capacity_total()]],
		["Sözleşme", "%d ay kaldı" % int(state["months_left"])]
	]
	for tile in tiles:
		var box := _card(grid, "", BORDER)
		box.add_child(_label(tile[0], 12, MUTED))
		box.add_child(_label(tile[1], 18, TEXT))
		box.get_parent().get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var cap := _card(content, "Kapasite kullanımı")
	cap.add_child(_bar(_capacity_used(), _capacity_total()))
	cap.add_child(_label("Boş kapasite: %d birim" % maxi(0, _capacity_total() - _capacity_used()), 13, MUTED))
	content.add_child(_button("Ayı bitir ▶", _end_month, true))

func _end_month() -> void:
	var rent := _rent()
	state["cash"] = float(state["cash"]) - rent
	var report := "Kira: %s" % Data.usd(rent)
	var remaining: Array = []
	for job in state["accepted"]:
		job["left"] = int(job["left"]) - 1
		if int(job["left"]) <= 0:
			state["cash"] = float(state["cash"]) + float(job["revenue"]) - float(job["cost"])
			report += "\nTeslim: %s (+%s)" % [job["title"], Data.usd(float(job["revenue"]) - float(job["cost"]))]
		else:
			remaining.append(job)
	state["accepted"] = remaining
	state["months_left"] = int(state["months_left"]) - 1
	if int(state["months_left"]) <= 0:
		state["months_left"] = int(state["term"])
		report += "\nSözleşme aynı koşulla yenilendi."
	state["month"] = int(state["month"]) + 1
	state["last_report"] = "Mock rapor (kurallar bağlı değil)\n" + report
	_render()

# ------------------------------------------------------------------ İşler

func _page_isler() -> void:
	if state["factory_id"] == "":
		_locked("İş teklifleri fabrikan olunca açılır.")
		return
	_chips(content, [{"id": "teklif", "title": "Teklifler"}, {"id": "kabul", "title": "Kabul edilenler (%d)" % state["accepted"].size()}],
		subtab["isler"], func(id: String) -> void:
			subtab["isler"] = id
			_render())
	var cap := _card(content, "Kapasite")
	cap.add_child(_bar(_capacity_used(), _capacity_total()))
	cap.add_child(_label("Kullanılan %d / %d · boş %d" % [_capacity_used(), _capacity_total(), maxi(0, _capacity_total() - _capacity_used())], 13, MUTED))
	if subtab["isler"] == "kabul":
		if state["accepted"].is_empty():
			content.add_child(_label("Henüz kabul edilmiş iş yok.", 14, MUTED))
		for job in state["accepted"]:
			var box := _card(content, job["title"], GREEN)
			_row(box, "Müşteri", job["customer"])
			_row(box, "Kapasite", "%d birim" % job["units"])
			_row(box, "Teslime", "%d ay" % job["left"])
			_row(box, "Gelir", Data.usd(float(job["revenue"])), GREEN)
		return
	var taken: Array = []
	for job in state["accepted"]:
		taken.append(job["id"])
	for offer in Data.OFFERS:
		if taken.has(offer["id"]):
			continue
		_offer_card(offer)

func _offer_card(offer: Dictionary) -> void:
	var free := _capacity_total() - _capacity_used()
	var fits: bool = int(offer["units"]) <= free
	var machine_ok: bool = _best_quality() >= int(offer["quality"])
	var box := _card(content, offer["title"], BORDER)
	box.add_child(_label(offer["customer"], 12, MUTED))
	_row(box, "Gereken makine", ["", "Temel", "Hassas", "Nitelikli"][int(offer["quality"])], TEXT if machine_ok else RED)
	_row(box, "Kapasite kullanımı", "%d birim" % offer["units"], TEXT if fits else RED)
	_row(box, "Teslim süresi", "%d ay" % offer["months"])
	_row(box, "Gelir", Data.usd(float(offer["revenue"])), GREEN)
	_row(box, "Tahmini maliyet", Data.usd(float(offer["cost"])))
	box.add_child(_label("Alırsan boş kapasite: %d birim" % (free - int(offer["units"])) if fits else "Boş kapasiteni aşıyor (%d birim boş)." % free, 13, MUTED if fits else RED))
	box.add_child(_label("Risk: teslim edilemezse gelir yazılmaz, malzeme maliyeti (%s) gider." % Data.usd(float(offer["cost"])), 12, GOLD))
	var reason := ""
	if not machine_ok:
		reason = "Makine niteliği yetmiyor"
	elif not fits:
		reason = "Kapasite yetmiyor"
	box.add_child(_button("Kabul et" if reason == "" else reason, _accept_offer.bind(offer["id"]), reason == "", reason != ""))

func _accept_offer(id: int) -> void:
	for offer in Data.OFFERS:
		if offer["id"] == id:
			var job: Dictionary = offer.duplicate()
			job["left"] = offer["months"]
			state["accepted"].append(job)
	_render()

# ------------------------------------------------------------------ Tezgah

func _page_tezgah() -> void:
	if state["factory_id"] == "":
		_locked("Tezgah almak için önce bir yer kiralamalısın; makineler alan tüketir.")
		return
	var factory := _factory()
	var space := _card(content, "Alan")
	space.add_child(_bar(_area_used(), float(factory["m2"])))
	space.add_child(_label("%d / %d m² kullanılıyor · tavan yüksekliği %.1f m" % [_area_used(), factory["m2"], factory["height"]], 13, MUTED))
	for id in ["A", "B", "C"]:
		var machine: Dictionary = BossState.MACHINES[id]
		var extra: Dictionary = Data.MACHINE_EXTRA[id]
		var box := _card(content, machine["title"], BORDER)
		_row(box, "Fiyat", Data.usd(float(machine["price"])))
		_row(box, "Kapasite", "%d birim/ay" % machine["capacity"])
		_row(box, "Alan", "%d m²" % extra["area"])
		_row(box, "Yükseklik", "%.1f m" % extra["height"])
		_row(box, "Sahip olunan", str(state["machines"][id]))
		var reason := ""
		if float(machine["price"]) > float(state["cash"]):
			reason = "Yetersiz nakit"
		elif _area_used() + int(extra["area"]) > int(factory["m2"]):
			reason = "Alan yetmiyor"
		elif float(extra["height"]) > float(factory["height"]):
			reason = "Tavan çok alçak"
		box.add_child(_button("Satın al" if reason == "" else reason, _buy.bind(id), reason == "", reason != ""))

func _buy(id: String) -> void:
	var price := float(BossState.MACHINES[id]["price"])
	state["cash"] = float(state["cash"]) - price
	state["invested"] = float(state["invested"]) + price
	state["machines"][id] = int(state["machines"][id]) + 1
	_render()

# ------------------------------------------------------------------ Fabrika

func _page_fabrika() -> void:
	if state["factory_id"] != "":
		var factory := _factory()
		var box := _card(content, "Kiraladığın yer", GREEN)
		_row(box, "Fabrika", factory["name"])
		_row(box, "Alan / yükseklik", "%d m² · %.1f m" % [factory["m2"], factory["height"]])
		_row(box, "Aylık kira", Data.usd(_rent()))
		_row(box, "Sözleşme", "%d ay · %d ay kaldı" % [state["term"], state["months_left"]])
		box.add_child(_button("Sözleşmeyi bırak", _open_detail.bind("leave"), false))
		content.add_child(_label("İlk dilimde tek fabrika var; başka bir yer için önce bu sözleşme bırakılır.", 12, MUTED))
		return
	content.add_child(_label("Kiralık yerler", 20, TEXT))
	for factory in Data.FACTORIES:
		var box := _card(content, factory["name"], BORDER)
		var swatch := ColorRect.new()
		swatch.color = factory["tint"]
		swatch.custom_minimum_size = Vector2(0, 70)
		box.add_child(swatch)
		_row(box, "Bölge", factory["region"])
		_row(box, "Alan", "%d m²" % factory["m2"])
		_row(box, "Yükseklik", "%.1f m" % factory["height"])
		_row(box, "Aylık kira (12 ay)", Data.usd(float(factory["rent"])), GREEN)
		box.add_child(_button("İncele", _open_detail.bind("factory", factory["id"]), true))

# ------------------------------------------------------------------ Profil

func _page_profil() -> void:
	var skills := _card(content, "Yetkinlikler")
	for name in BossState.SKILLS:
		var row := HBoxContainer.new()
		row.add_child(_label(name, 13, MUTED))
		var value := _label(str(state["skills"][name]), 13, TEXT, false)
		row.add_child(value)
		skills.add_child(row)
		skills.add_child(_bar(float(state["skills"][name]), 100.0))
	var stats := _card(content, "Statlar")
	for stat in Data.STATS:
		_row(stats, stat, "—")
	stats.add_child(_label("Statlar yetkinlik puanı vermez (FRZ-007 v3).", 12, MUTED))
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
			var box := _card(content)
			box.add_child(_label("Mock kredi: $100.000 nakit. Teşvik ilk dilimde yok.", 14, MUTED))
			box.add_child(_button("Kredi al", _take_credit, true))

func _detail_factory(factory: Dictionary) -> void:
	var swatch := ColorRect.new()
	swatch.color = factory["tint"]
	swatch.custom_minimum_size = Vector2(0, 120)
	content.add_child(swatch)
	var specs := _card(content)
	_row(specs, "Bölge", factory["region"])
	_row(specs, "Alan", "%d m²" % factory["m2"])
	_row(specs, "Yükseklik", "%.1f m" % factory["height"])
	var terms := _card(content, "Sözleşme süresi")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	terms.add_child(row)
	for term in Data.TERMS:
		var chosen: bool = term["months"] == picked_term
		var button := Button.new()
		button.text = "%d ay\n%s" % [term["months"], Data.usd(roundf(float(factory["rent"]) * float(term["factor"])))]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 56)
		button.add_theme_stylebox_override("normal", _box(GREEN_DIM if chosen else PANEL_ALT, GREEN if chosen else BORDER, 10, 2 if chosen else 1))
		button.pressed.connect(_pick_term.bind(term["months"]))
		row.add_child(button)
	var rent := roundf(float(factory["rent"]) * _factor_for(picked_term))
	terms.add_child(_label("Erken çıkarsan %d kira (%s) ceza ödersin." % [Data.EXIT_FEE_RENTS, Data.usd(rent * Data.EXIT_FEE_RENTS)], 13, GOLD))
	content.add_child(_button("%s / ay ile kirala" % Data.usd(rent), _rent_factory.bind(factory["id"]), true, rent > float(state["cash"])))

func _factor_for(months: int) -> float:
	for term in Data.TERMS:
		if term["months"] == months:
			return float(term["factor"])
	return 1.0

func _pick_term(months: int) -> void:
	picked_term = months
	_render()

func _rent_factory(id: String) -> void:
	state["factory_id"] = id
	state["term"] = picked_term
	state["months_left"] = picked_term
	detail = ""
	page = "ozet"
	_render()

func _detail_leave() -> void:
	var fee := _rent() * Data.EXIT_FEE_RENTS
	var box := _card(content, "Emin misin?", GOLD)
	box.add_child(_label("Sözleşmeyi erken bırakırsan %d kira (%s) ceza ödersin. Makinelerin ve kabul edilmiş işlerin bu mock'ta silinir." % [Data.EXIT_FEE_RENTS, Data.usd(fee)], 14, TEXT))
	box.add_child(_button("Vazgeç", _back))
	box.add_child(_button("Bırak ve %s öde" % Data.usd(fee), _leave_factory.bind(fee), true, fee > float(state["cash"])))

func _leave_factory(fee: float) -> void:
	state["cash"] = float(state["cash"]) - fee
	state["factory_id"] = ""
	state["machines"] = {"A": 0, "B": 0, "C": 0}
	state["accepted"] = []
	state["invested"] = 0.0
	detail = ""
	page = "fabrika"
	_render()

func _take_credit() -> void:
	state["cash"] = float(state["cash"]) + 100.0
	state["credit"] = float(state["credit"]) + 100.0
	_render()
