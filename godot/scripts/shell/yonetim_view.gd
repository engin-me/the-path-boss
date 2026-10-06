extends VBoxContainer
# Yönetim > Özet screen, built from the design in docs/design/y_netim.pptx (measures in points, scaled to the 540 px screen).
# Every card shares one frame: 16 pt radius, #182431 fill, #344556 border, header icon + title, 12 pt gaps.

signal go(target: String)
signal shift_toggled(n: int, on: bool)
signal overtime_toggled(n: int, on: bool)

const Data = preload("res://scripts/shell/shell_data.gd")
const Art = preload("res://scripts/shell/art.gd")
const MiniChart = preload("res://scripts/shell/mini_chart.gd")
const GaugeScript = preload("res://scripts/shell/gauge.gd")

const K := 540.0 / 471.7           # design points -> screen pixels
const CARD := Color("#182431")
const INNER := Color("#0f1720")
const BORDER := Color("#344556")
const TRACK := Color("#0b1118")
const TRACK_BORDER := Color("#222e3b")
const TEXT := Color("#e7edf3")
const MUTED := Color("#98a7b6")
const GREEN := Color("#2fd17b")
const GREEN_HI := Color("#4be394")
const AMBER := Color("#e7b75c")
const RED := Color("#e86f6f")
const BLUE := Color("#62a8e5")
const CYAN := Color("#45c7d8")
const DARK := Color("#101b26")
const CARD_RADIUS := 16.0
const INNER_RADIUS := 10.5

var game

static func S(points: float) -> float:
	return points * K

func _font(weight: String) -> Font:
	return Art.font(weight)

func _style(fill: Color, radius: float, border := BORDER, width := 1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(int(roundf(S(radius))))
	return box

func _text(text: String, pt: float, color := TEXT, weight := "Regular", align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", int(roundf(S(pt))))
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_override("font", _font(weight))
	label.horizontal_alignment = align
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _icon(name: String, pt: float) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = Art.find("res://art/ui/yonetim/" + name)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.custom_minimum_size = Vector2(S(pt), S(pt))
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

func _chevron() -> TextureRect:
	var rect := _icon("ok_sag", 14.2)
	rect.custom_minimum_size = Vector2(S(9), S(14.2))
	return rect

func _tap(control: Control, target: String) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_STOP
	control.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			go.emit(target))

# The shared card: icon + title on top, a content box below. Returns the content box.
func _card(title: String, icon_name: String, target := "") -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(CARD, CARD_RADIUS))
	add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, int(S(8)))
	margin.add_theme_constant_override("margin_top", int(S(4)))
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", int(S(6)))
	margin.add_child(column)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", int(S(5)))
	head.add_child(_icon(icon_name, 26))
	var title_label := _text(title, 18)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(title_label)
	column.add_child(head)
	if target != "":
		_tap(head, target)
	return column

func _inner(fill := INNER, radius := INNER_RADIUS) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(fill, radius))
	return panel

func _padded(child: Control, h: float, v: float) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", int(S(h)))
	margin.add_theme_constant_override("margin_right", int(S(h)))
	margin.add_theme_constant_override("margin_top", int(S(v)))
	margin.add_theme_constant_override("margin_bottom", int(S(v)))
	margin.add_child(child)
	return margin

func _usd(units: float) -> String:
	return Data.usd(units).replace("$", "$ ")

# ------------------------------------------------------------------ build

func build(new_game) -> void:
	game = new_game
	for child in get_children():
		remove_child(child)
		child.queue_free()
	add_theme_constant_override("separation", int(S(12)))
	_actions()
	_finance()
	_production()
	_oee()
	_jobs()
	_staff()
	_overview()

func _actions() -> void:
	var column := _card("Aksiyon", "baslik_aksiyon")
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", int(S(11)))
	var items: Array = game.action_items()
	if items.is_empty():
		list.add_child(_text("Şu an dikkat isteyen bir şey yok.", 9, MUTED))
	for i in mini(5, items.size()):
		var item: Dictionary = items[i]
		var color: Color = {"red": RED, "amber": AMBER, "blue": BLUE}[item["severity"]]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", int(S(6)))
		row.add_child(_icon({"red": "aksiyon_kirmizi", "amber": "aksiyon_sari", "blue": "aksiyon_mavi"}[item["severity"]], 17))
		var label := _text(String(item["text"]), 9, color)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(label)
		row.add_child(_chevron())
		_tap(row, String(item["target"]))
		list.add_child(row)
	var panel := _inner()
	panel.add_child(_padded(list, 10, 10))
	column.add_child(panel)

func _finance_row(parent: VBoxContainer, label: String, value: float, color: Color, indent := 0.0, target := "finance") -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(S(6)))
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(S(indent), 0)
	row.add_child(spacer)
	var name := _text(label, 9, MUTED)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(name)
	var number := _text(_usd(value), 16, color, "Regular", HORIZONTAL_ALIGNMENT_RIGHT)
	number.custom_minimum_size = Vector2(S(82), 0)
	row.add_child(number)
	row.add_child(_chevron())
	row.custom_minimum_size = Vector2(0, S(28))
	_tap(row, target)
	parent.add_child(row)

func _finance() -> void:
	var column := _card("Finans", "baslik_finans", "finance")
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", int(S(8)))
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.0
	left.add_theme_constant_override("separation", int(S(2)))
	var com: Dictionary = game.commitments()
	_finance_row(left, "Nakit", float(com["cash"]), TEXT)
	_finance_row(left, "Ödemelere Bağlı", float(com["material"]) + float(com["expense"]), AMBER, 20.0)
	_finance_row(left, "Serbest Nakit", float(com["free"]), GREEN if float(com["free"]) >= 0.0 else RED, 20.0)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, S(8))
	left.add_child(gap)
	_finance_row(left, "Yatırımlar", float(game.investment_value()), BLUE)
	var gap2 := Control.new()
	gap2.custom_minimum_size = Vector2(0, S(8))
	left.add_child(gap2)
	var debt := float(game.debt) + (float(game.loan.get("balance", 0.0)) if not game.loan.is_empty() else 0.0)
	_finance_row(left, "Kredi Borçları", debt, RED)
	_finance_row(left, "Leasing Borçları", 0.0, RED)
	body.add_child(left)
	var panel := _inner()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = 0.95
	var charts := VBoxContainer.new()
	charts.add_theme_constant_override("separation", int(S(8)))
	var cash_values: Array = game.cash_history.duplicate()
	cash_values.append(float(game.cash))
	var cash_chart = MiniChart.new()
	cash_chart.custom_minimum_size = Vector2(0, S(92))
	cash_chart.set_data(cash_values.slice(maxi(0, cash_values.size() - 12)), "Nakit (aylık)", CYAN)
	charts.add_child(cash_chart)
	var revenue_chart = MiniChart.new()
	revenue_chart.custom_minimum_size = Vector2(0, S(92))
	revenue_chart.set_data(game.revenue_history.slice(maxi(0, game.revenue_history.size() - 12)), "Gelir (aylık)", GREEN)
	charts.add_child(revenue_chart)
	panel.add_child(_padded(charts, 8, 6))
	body.add_child(panel)
	column.add_child(body)

func _check(label: String, on: bool, enabled: bool, callback: Callable) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(S(4)))
	var box := Panel.new()
	box.custom_minimum_size = Vector2(S(14.2), S(14.2))
	box.add_theme_stylebox_override("panel", _style(GREEN_HI if on else CARD, 3.0))
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(S(14.2), S(14.2))
	holder.add_child(box)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_child(holder)
	var text := _text(label, 9, MUTED)
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(text)
	row.custom_minimum_size = Vector2(0, S(24))
	row.modulate = Color(1, 1, 1, 1.0 if enabled else 0.5)
	if enabled:
		row.mouse_filter = Control.MOUSE_FILTER_STOP
		row.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
				callback.call(not on))
	return row

func _production() -> void:
	var column := _card("Üretim Hattı", "baslik_uretim")
	var editable: bool = game.phase == "offers"
	var checks := HBoxContainer.new()
	for n in [1, 2, 3]:
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_theme_constant_override("separation", 0)
		cell.add_child(_check("Vardiya %d" % n, game.plan_shifts >= n, editable and n > 1, func(on: bool) -> void: shift_toggled.emit(n, on)))
		cell.add_child(_check("Mesai + 4 sa", bool(game.plan_ot[n - 1]), editable and n <= game.plan_shifts and game.plan_shifts < 3, func(on: bool) -> void: overtime_toggled.emit(n, on)))
		checks.add_child(cell)
	column.add_child(checks)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, S(6))
	column.add_child(spacer)
	var bars := HBoxContainer.new()
	bars.add_theme_constant_override("separation", int(S(10)))
	for row in game.production_line():
		bars.add_child(_machine_bar(row))
	column.add_child(bars)

func _machine_bar(row: Dictionary) -> Control:
	var cap: float = row["cap"]
	var load: float = row["load"]
	var share := 0.0 if cap <= 0.0 else load / cap
	var fill_color: Color = BLUE if share < 0.8 else (AMBER if share < 0.95 else RED)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", int(S(3)))
	var cap_label := _text("%s %s" % [Data.x_text(cap).replace(" " + Data.DIFFICULTY_SYMBOL, ""), Data.DIFFICULTY_SYMBOL], 9, CYAN, "Regular", HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(cap_label)
	var track := Panel.new()
	track.custom_minimum_size = Vector2(S(53.2), S(252.6))
	track.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	track.add_theme_stylebox_override("panel", _style(DARK, 13.851 * 53.2 / 100.0 * 1.0 + 0.0))
	column.add_child(track)
	# the usable height above the machine picture is 173 pt; 100 % fills 150 pt of it (as drawn in the design)
	var fill_h := S(150.0) * clampf(share, 0.0, 1.0)
	var fill_bottom := S(173.3)
	if fill_h > 1.0:
		var fill := Panel.new()
		var box := _style(fill_color, 4.0, fill_color, 0)
		box.corner_radius_bottom_left = 0
		box.corner_radius_bottom_right = 0
		fill.add_theme_stylebox_override("panel", box)
		fill.position = Vector2(S(1.9), fill_bottom - fill_h)
		fill.size = Vector2(S(49.5), fill_h)
		track.add_child(fill)
		var pct := _text("%%%d" % int(roundf(share * 100.0)), 9, DARK, "Medium", HORIZONTAL_ALIGNMENT_CENTER)
		pct.position = Vector2(S(1.9), fill_bottom - fill_h + S(2))
		pct.size = Vector2(S(49.5), S(16))
		track.add_child(pct)
		var load_label := _text("%s %s" % [Data.x_text(load).replace(" " + Data.DIFFICULTY_SYMBOL, ""), Data.DIFFICULTY_SYMBOL], 9, MUTED, "Regular", HORIZONTAL_ALIGNMENT_CENTER)
		load_label.position = Vector2(-S(6), fill_bottom - fill_h - S(18))
		load_label.size = Vector2(S(65), S(16))
		track.add_child(load_label)
	var picture := TextureRect.new()
	picture.texture = Art.find("res://art/ui/yonetim/tur_" + Art.slug(String(row["kind"])))
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.position = Vector2(S(8), S(193))
	picture.size = Vector2(S(37), S(34))
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_child(picture)
	var name := _text(String(row["kind"]), 9, MUTED, "Regular", HORIZONTAL_ALIGNMENT_CENTER)
	name.position = Vector2(0, S(229))
	name.size = Vector2(S(53.2), S(18))
	track.add_child(name)
	_tap(track, "capacity")
	return column

func _oee() -> void:
	var column := _card("OEE (Overall Equipment Efficiency)", "baslik_oee", "oee")
	var parts: Dictionary = game.oee_parts()
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", int(S(8)))
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 2.0
	left.add_theme_constant_override("separation", int(S(10)))
	for entry in [["Kalite", float(parts["quality"])], ["Performans", float(parts["performance"])], ["Kullanılabilirlik", float(parts["availability"])]]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", int(S(6)))
		var name := _text(String(entry[0]), 9, MUTED)
		name.custom_minimum_size = Vector2(S(78), 0)
		name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(name)
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.max_value = 1.0
		bar.value = clampf(entry[1], 0.0, 1.0)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bar.custom_minimum_size = Vector2(0, S(9))
		bar.add_theme_stylebox_override("background", _style(TRACK, 50.0, TRACK_BORDER))
		bar.add_theme_stylebox_override("fill", _style(AMBER, 50.0, AMBER, 0))
		row.add_child(bar)
		var value := _text(("%.1f%%" % (float(entry[1]) * 100.0)).replace(".", ","), 10.5, MUTED, "Regular", HORIZONTAL_ALIGNMENT_RIGHT)
		value.custom_minimum_size = Vector2(S(46), 0)
		row.add_child(value)
		row.add_child(_chevron())
		_tap(row, "oee")
		left.add_child(row)
	body.add_child(left)
	var panel := _inner()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(S(103.3), S(90.2))
	var gauge = GaugeScript.new()
	gauge.custom_minimum_size = Vector2(S(80), S(60))
	gauge.set_value(float(parts["oee"]))
	var center := CenterContainer.new()
	center.add_child(gauge)
	panel.add_child(center)
	body.add_child(panel)
	column.add_child(body)

func _job_tile(icon_name: String, label: String, value: int, color: Color, target: String) -> Control:
	var panel := _inner()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0, S(70.7))
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(0, S(66))
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", int(S(4)))
	head.add_child(_icon(icon_name, 19.8))
	var caption := _text(label, 9, color)
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(caption)
	head.position = Vector2(S(3), S(6))
	holder.add_child(head)
	var number := _text(str(value), 32, color, "Regular", HORIZONTAL_ALIGNMENT_RIGHT)
	number.size = Vector2(S(100), S(46))
	number.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	number.offset_left = -S(125)
	number.offset_top = -S(48)
	number.offset_right = -S(24)
	number.offset_bottom = S(0)
	holder.add_child(number)
	var arrow := _chevron()
	arrow.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	arrow.offset_left = -S(12)
	arrow.offset_right = -S(4)
	arrow.offset_top = -S(5)
	arrow.offset_bottom = S(9)
	holder.add_child(arrow)
	panel.add_child(holder)
	_tap(panel, target)
	return panel

func _jobs() -> void:
	var column := _card("İşler", "baslik_isler", "jobs")
	var producing := 0
	for job in game.jobs:
		if not job.get("order", {}).is_empty() and int(job["order"]["arrive_month"]) <= game.month and int(job["start_month"]) <= game.month:
			producing += 1
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", int(S(10)))
	grid.add_theme_constant_override("v_separation", int(S(10)))
	grid.add_child(_job_tile("is_aktif", "Aktif İş", game.jobs.size(), AMBER, "jobs"))
	grid.add_child(_job_tile("is_teklifte", "Teklifte", game.offers.size(), CYAN, "offers"))
	grid.add_child(_job_tile("is_uretimde", "Üretimde", producing, GREEN, "jobs"))
	grid.add_child(_job_tile("is_risk", "Teslim Riski", game.risky_jobs(), RED, "jobs"))
	column.add_child(grid)

func _staff() -> void:
	var column := _card("Personel", "baslik_personel", "dep")
	var groups: Dictionary = game.staff_groups()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(S(8.8)))
	for entry in [["p_mavi", "Mavi Yaka", int(groups["blue"]), BLUE], ["p_beyaz", "Beyaz Yaka", int(groups["white"]), TEXT], ["p_yonetici", "Yönetici", int(groups["managers"]), AMBER], ["p_danisman", "Danışman", int(groups["consultants"]), RED]]:
		var tile := _inner()
		tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var stack := VBoxContainer.new()
		stack.alignment = BoxContainer.ALIGNMENT_CENTER
		stack.add_theme_constant_override("separation", int(S(0)))
		var icon := _icon(String(entry[0]), 28.3)
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		stack.add_child(icon)
		stack.add_child(_text(String(entry[1]), 9, entry[3], "Regular", HORIZONTAL_ALIGNMENT_CENTER))
		stack.add_child(_text(str(entry[2]), 18, entry[3], "Regular", HORIZONTAL_ALIGNMENT_CENTER))
		tile.add_child(_padded(stack, 2, 5))
		_tap(tile, "dep")
		row.add_child(tile)
	column.add_child(row)

func _pair(left_label: String, value: String, color := TEXT, align := HORIZONTAL_ALIGNMENT_RIGHT) -> Control:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.custom_minimum_size = Vector2(0, S(28))
	var label := _text(left_label, 9, MUTED)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)
	var number := _text(value, 12, color, "Regular", align)
	number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(number)
	return row

func _overview() -> void:
	var column := _card("Genel Bakış", "baslik_genel", "contract")
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", int(S(14)))
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 0)
	left.add_child(_pair("Tarih", _date_text()))
	left.add_child(_pair("Geçen Zaman", "%d ay" % maxi(0, int(game.month) - 1)))
	left.add_child(_pair("Patron Saati", "%d/%d sa" % [game.monthly_hours - game.patron_hours() if game.phase != "report" else game.hours_left, game.monthly_hours]))
	top.add_child(left)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 0)
	var income := 0.0
	if not game.revenue_history.is_empty():
		income = float(game.revenue_history[game.revenue_history.size() - 1])
	right.add_child(_pair("Şirket Değeri", _usd(float(game.investment_value())), AMBER))
	right.add_child(_pair("Aylık Gelir", _usd(income) + "/ay", GREEN))
	right.add_child(_pair("Aylık Gider", _usd(float(game.ordinary_expense())) + "/ay", RED))
	top.add_child(right)
	column.add_child(top)
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", int(S(14)))
	var factory: Dictionary = game.factory()
	var photo_frame := PanelContainer.new()
	photo_frame.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	photo_frame.custom_minimum_size = Vector2(0, S(151.7))
	photo_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	photo_frame.add_theme_stylebox_override("panel", _style(INNER, 9.0, INNER, 0))
	var texture: Texture2D = Art.find("res://art/factories/" + String(factory.get("id", "")))
	if texture != null:
		var rect := TextureRect.new()
		rect.texture = texture
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		photo_frame.add_child(rect)
	bottom.add_child(photo_frame)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 0)
	var delivered: int = game.delivered().size()
	var transit: int = game.machines.size() - delivered
	var slots: int = Data.slot_count(game.factory_id)
	var groups: Dictionary = game.staff_groups()
	details.add_child(_pair("Fabrika", String(factory.get("region", "—"))))
	details.add_child(_pair("Slot Durumu", "%d/%d" % [game.machines.size(), slots]))
	details.add_child(_pair("Personel Sayısı", str(int(groups["blue"]) + int(groups["white"]) + int(groups["managers"]))))
	details.add_child(_pair("Tezgah Sayısı", "%d%s" % [delivered, (" (+%d)" % transit) if transit > 0 else ""]))
	details.add_child(_pair("Aktif İşler", str(game.jobs.size())))
	details.add_child(_pair("Teslim Skoru", "%%%d" % int(roundf(float(game.delivery_score) * 100.0))))
	details.add_child(_pair("Teklif Kazanma", "%%%d" % int(roundf(game.quote_win_rate() * 100.0))))
	bottom.add_child(details)
	column.add_child(bottom)

func _date_text() -> String:
	var parts: Array = Data.date_text(int(game.month), int(game.day)).split(" ")
	var names := ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
	return "%02d.%02d.%s" % [int(parts[0]), names.find(parts[1]) + 1, parts[2]]
