extends Control

# Manual boss-only playtest screen. Rules live in boss_state.gd.

const BossState = preload("res://scripts/boss_state.gd")
const Log = preload("res://scripts/playtest_log.gd")
const BG := Color("#101827")
const SURFACE := Color("#1a2739")
const SURFACE_ALT := Color("#15314f")
const BORDER := Color("#33445b")
const TEXT := Color("#e9f1fa")
const MUTED := Color("#a2b3c8")
const ACCENT := Color("#46d4b0")
const GOLD := Color("#eac47a")
const RED := Color("#f08080")

var game = BossState.new()
var body: VBoxContainer
var personas: Array[Dictionary] = []
var setup_values: Dictionary = {}
var setup_budget := 600
var setup_cash := 400.0
var setup_persona := "Manuel"
var setup_seed := -1
var total_label: Label
var start_button: Button
var machine_counts := {"A": 2, "B": 0, "C": 0}
var selected_jobs: Array = []
var notes_open := false
var note_category := 0
var note_status := ""

func _ready() -> void:
	get_viewport().set_embedding_subwindows(false)
	personas = Log.load_personas()
	for skill in BossState.SKILLS:
		setup_values[skill] = 60
	_build_shell()
	_refresh()

func _build_shell() -> void:
	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 32)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 32)
	scroll.add_child(margin)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	margin.add_child(body)

func _refresh() -> void:
	for child in body.get_children():
		body.remove_child(child)
		child.queue_free()
	_show_header()
	if notes_open:
		_show_notes()
	if game.phase != "setup":
		_add_card(body, "DURUM", game.notice, GOLD)
	match game.phase:
		"setup": _show_setup()
		"invest": _show_invest()
		"offers": _show_offers()
		"report": _show_report()
		_: _show_end()
	_show_history()
	body.add_child(_label("Patron test modu • rakamlar test girdisidir, denge kararı değildir • kurallar docs/freeze", 12, MUTED))

# ---------------------------------------------------------------- header and notes

func _show_header() -> void:
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	body.add_child(top)
	var title := _label("the Path / BOSS · Patron Testi", 26, TEXT, false)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	top.add_child(_label(_phase_title(), 15, ACCENT, false))
	top.add_child(_button("📝 Not ekle" if not notes_open else "Notu kapat", _toggle_notes))
	if game.phase in ["offers", "report"]:
		var status: Dictionary = game.solvency()
		var kpi := HBoxContainer.new()
		kpi.add_theme_constant_override("separation", 26)
		body.add_child(kpi)
		for item in [
			["Kasa", "%.0f" % game.cash, TEXT if game.cash >= 0 else RED],
			["Kullanılabilir", "%.0f" % game.available_cash(), TEXT],
			["Kredi borcu", "%.0f" % game.debt, TEXT],
			["Borç açığı / eşik", "%.0f / %.0f" % [status["gap"], status["threshold"]], RED if status["gap"] > status["threshold"] * 0.7 else TEXT],
			["Ölçek", "%s (≤T%d)" % [game.scale()["name"], game.scale()["max_tier"]], TEXT],
			["Kapasite", "%d" % game.capacity_at_least(1), TEXT],
			["Patron zamanı", "%d / %d sa" % [game.hours_left, BossState.MONTHLY_HOURS], TEXT]
		]:
			var box := VBoxContainer.new()
			box.add_child(_label(item[0], 12, MUTED, false))
			box.add_child(_label(item[1], 18, item[2], false))
			kpi.add_child(box)

func _phase_title() -> String:
	match game.phase:
		"setup": return "KURULUM"
		"invest": return "YATIRIM"
		"offers": return "AY %d / %d · İŞ ALMA" % [game.month, game.max_months]
		"report": return "AY %d / %d · RAPOR" % [game.month, game.max_months]
	return "TEST BİTTİ"

func _toggle_notes() -> void:
	notes_open = not notes_open
	note_status = ""
	_refresh()

func _show_notes() -> void:
	var card := _card("NOT EKLE · \"bu saçma olmuş\" dediğin her şey")
	_append_card(body, card)
	card.add_child(_label("Bağlam otomatik eklenir: " + game.context_line(), 13, MUTED))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)
	var category := OptionButton.new()
	for category_name in Log.CATEGORIES:
		category.add_item(category_name)
	category.select(note_category)
	category.item_selected.connect(func(index): note_category = index)
	row.add_child(category)
	var text := TextEdit.new()
	text.custom_minimum_size = Vector2(0, 90)
	text.placeholder_text = "Ne gördün, neden yanlış geldi, nasıl olmalıydı?"
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_child(text)
	card.add_child(_button("Kaydet", func(): _save_note(text.text)))
	if note_status != "":
		card.add_child(_label(note_status, 13, ACCENT))

func _save_note(text: String) -> void:
	if text.strip_edges() == "":
		note_status = "Boş not kaydedilmedi."
	else:
		var path := Log.append_note("Emrah (manuel)", Log.CATEGORIES[note_category], text, game.context_line())
		note_status = "Kaydedildi: " + path if path != "" else "Not dosyasına yazılamadı."
	_refresh()

# ---------------------------------------------------------------- setup

func _show_setup() -> void:
	var intro := _card("PATRONU OLUŞTUR")
	_append_card(body, intro)
	intro.add_child(_label("Kariyer bölümünü atlıyoruz: yetkinlik puanlarını doğrudan dağıt. Her alan 0–100; T eşikleri 30/50/70/90/100. Puan, o alanda hangi derinliğe kadar sorun görebileceğini belirler.", 15, MUTED))
	var presets := HBoxContainer.new()
	presets.add_theme_constant_override("separation", 10)
	intro.add_child(presets)
	presets.add_child(_label("Hazır karakter:", 15, TEXT, false))
	var option := OptionButton.new()
	option.add_item("Kendi dağılımım")
	for persona in personas:
		option.add_item("%s (%s)" % [persona["name"], persona.get("author", "?")])
	option.item_selected.connect(_apply_persona)
	presets.add_child(option)

	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 8)
	intro.add_child(grid)
	for skill in BossState.SKILLS:
		grid.add_child(_label(skill, 16, TEXT, false))
		var spin := SpinBox.new()
		spin.min_value = 0
		spin.max_value = 100
		spin.value = setup_values[skill]
		spin.custom_minimum_size.x = 110
		spin.value_changed.connect(_set_skill.bind(skill))
		grid.add_child(spin)

	var money := HBoxContainer.new()
	money.add_theme_constant_override("separation", 12)
	intro.add_child(money)
	money.add_child(_label("Toplam bütçe", 15, TEXT, false))
	var budget := SpinBox.new()
	budget.min_value = 50
	budget.max_value = 1000
	budget.step = 10
	budget.value = setup_budget
	budget.value_changed.connect(func(v): setup_budget = int(v); _update_total())
	money.add_child(budget)
	money.add_child(_label("Cebindeki para", 15, TEXT, false))
	var cash := SpinBox.new()
	cash.min_value = 0
	cash.max_value = 5000
	cash.step = 10
	cash.value = setup_cash
	cash.value_changed.connect(func(v): setup_cash = v)
	money.add_child(cash)
	total_label = _label("", 17, TEXT, false)
	intro.add_child(total_label)
	start_button = _button("Patron ol  →", _start)
	intro.add_child(start_button)
	intro.add_child(_button("Eski kariyer dilimini aç", func(): get_tree().change_scene_to_file("res://main.tscn")))
	_update_total()

func _apply_persona(index: int) -> void:
	if index == 0:
		setup_persona = "Manuel"
		setup_seed = -1
		return
	var persona: Dictionary = personas[index - 1]
	for skill in BossState.SKILLS:
		setup_values[skill] = int(persona["skills"].get(skill, 0))
	setup_budget = int(persona.get("budget", 600))
	setup_cash = float(persona.get("cash", 400))
	setup_persona = persona["name"]
	setup_seed = int(persona.get("seed", -1))
	var counts: Dictionary = persona.get("machines", {})
	for type in machine_counts:
		machine_counts[type] = int(counts.get(type, 0))
	_refresh()

func _set_skill(value: float, skill: String) -> void:
	setup_values[skill] = int(value)
	_update_total()

func _update_total() -> void:
	var total := 0
	for skill in BossState.SKILLS:
		total += int(setup_values[skill])
	var over := total > setup_budget
	total_label.text = "Toplam %d / %d%s" % [total, setup_budget, "  — bütçe aşıldı" if over else ""]
	total_label.add_theme_color_override("font_color", RED if over else ACCENT)
	start_button.disabled = over

func _start() -> void:
	var error: String = game.configure(setup_values, setup_budget, setup_cash, setup_persona, setup_seed)
	if error != "":
		game.notice = error
	_refresh()

# ---------------------------------------------------------------- invest

func _show_invest() -> void:
	var card := _card("MAKİNE YATIRIMI")
	_append_card(body, card)
	card.add_child(_label("Makine sayısı ölçeği belirler: 1–2 küçük (sorunlar en fazla T3), 3–4 orta (T4), 5+ büyük (T5). Nitelikli makine, nitelik isteyen işleri alabilir.", 14, MUTED))
	for type in BossState.MACHINES:
		var machine: Dictionary = BossState.MACHINES[type]
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 12)
		card.add_child(line)
		var label := _label("%s · fiyat %.0f · kapasite %d · nitelik Q%d" % [machine["title"], machine["price"], machine["capacity"], machine["quality"]], 16, TEXT)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(label)
		var spin := SpinBox.new()
		spin.min_value = 0
		spin.max_value = 8
		spin.value = machine_counts[type]
		spin.value_changed.connect(func(v): machine_counts[type] = int(v); _refresh())
		line.add_child(spin)
	var need: Dictionary = game.opening_requirement(machine_counts)
	card.add_child(_label("Makine toplamı %.0f · kalan kasa %.0f · ölçek %s · ilk ay gideri %.0f + gizli sorun güvencesi %.0f = gereken %.0f" % [need["price"], need["cash_after"], need["scale"]["name"], need["expense"], need["guarantee"], need["needed"]], 15, ACCENT if need["ok"] else RED))
	var open := _button("Fabrikayı aç  →", func(): _act(game.open_factory(machine_counts)))
	open.disabled = not need["ok"]
	card.add_child(open)

# ---------------------------------------------------------------- offers

func _show_offers() -> void:
	var card := _card("BU AYIN İŞ TEKLİFLERİ")
	_append_card(body, card)
	card.add_child(_label("Tam işler seçilir, parçalı iş yok. Q nitelik şartıdır; yalnız o nitelikte veya daha iyi makineler o işi yapabilir. İş maliyeti ay sonunda ödenir.", 14, MUTED))
	for index in game.offers.size():
		var offer: Dictionary = game.offers[index]
		var margin: float = offer["price"] * offer["quantity"] - offer["cost"]
		var check := CheckBox.new()
		var eligible: bool = game.capacity_at_least(offer["quality"]) > 0
		check.text = "Q%d · %d birim · birim fiyat %.2f · maliyet %.0f · brüt katkı %.0f%s" % [offer["quality"], offer["quantity"], offer["price"], offer["cost"], margin, "" if eligible else " · uygun makinen yok"]
		check.button_pressed = selected_jobs.has(index)
		check.disabled = not eligible
		check.add_theme_font_size_override("font_size", 16)
		check.toggled.connect(_toggle_job.bind(index))
		card.add_child(check)
	var used := 0
	for index in selected_jobs:
		used += int(game.offers[index]["quantity"])
	var problem: String = game.selection_problem(selected_jobs)
	var warning: String = game.selection_warning(selected_jobs)
	card.add_child(_label("Seçili %d birim · kapasite Q1+ %d / Q2+ %d / Q3+ %d" % [used, game.capacity_at_least(1), game.capacity_at_least(2), game.capacity_at_least(3)], 15, TEXT))
	if problem != "":
		card.add_child(_label(problem, 14, RED))
	if warning != "":
		card.add_child(_label(warning, 14, GOLD))
	var accept := _button("İşleri onayla, ayı başlat  →", _accept)
	accept.disabled = problem != ""
	card.add_child(accept)

	var invest := _card("YATIRIM VE FİNANSMAN")
	_append_card(body, invest)
	for type in BossState.MACHINES:
		var machine: Dictionary = BossState.MACHINES[type]
		var reason: String = game.machine_price_ok(type)
		var buy := _button("%s al · %.0f" % [machine["title"], machine["price"]], func(): _act(game.buy_machine(type)))
		buy.disabled = reason != ""
		buy.tooltip_text = reason
		invest.add_child(buy)
	for index in game.machines.size():
		var machine: Dictionary = game.machines[index]
		var preview: Dictionary = game.sale_preview(index)
		var line := HBoxContainer.new()
		invest.add_child(line)
		var bought: String = "kuruluşta alındı" if machine["bought_month"] == 0 else "ay %d'de alındı" % machine["bought_month"]
		var label := _label("%s · referans %.0f · %s" % [BossState.MACHINES[machine["type"]]["title"], machine["reference"], bought], 14, TEXT)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(label)
		var sell := _button("Sat · +%.0f → açık %.0f / eşik %.0f%s" % [preview["income"], preview["gap"], preview["threshold"], " ⚠ kapanış" if preview["closes"] else ""], func(): _act(game.sell_machine(index)))
		sell.disabled = game.machines.size() == 1
		line.add_child(sell)
	var credit := _button("Tek seferlik kriz kredisi al · %.0f" % BossState.CREDIT_AMOUNT, func(): _act(game.take_credit()))
	credit.disabled = game.credit_used
	invest.add_child(credit)

func _toggle_job(pressed: bool, index: int) -> void:
	if pressed and not selected_jobs.has(index):
		selected_jobs.append(index)
	elif not pressed:
		selected_jobs.erase(index)
	_refresh()

func _accept() -> void:
	var error: String = game.accept_jobs(selected_jobs)
	if error == "":
		selected_jobs.clear()
	else:
		game.notice = error
	_refresh()

# ---------------------------------------------------------------- report

func _show_report() -> void:
	var report: Dictionary = game.report
	var summary := _card("AY RAPORU")
	_append_card(body, summary)
	summary.add_child(_label("Beklenen %d · Gerçekleşen %.0f · Kayıp %.0f · Boş kapasite %d · Tahmini satış %.0f" % [report["expected"], report["realized"], report["loss"], report["empty"], report["revenue"]], 18, TEXT))
	summary.add_child(_label("Bu ay önlenen kişi kaynaklı olay: %d (İnsan Yönetimi %d)" % [game.prevented_this_month, game.skills[BossState.HR_SKILL]], 14, MUTED))
	if report.get("capped", false):
		summary.add_child(_label("Bir departmanın kaybı %20 tavanına kırpıldı.", 14, GOLD))

	var quiet: Array[String] = []
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	body.add_child(grid)
	for department in BossState.SKILLS:
		var rows: Array[Dictionary] = game.active_rows(department)
		if rows.is_empty():
			quiet.append(department)
			continue
		grid.add_child(_department_card(department, rows))
	if not quiet.is_empty():
		body.add_child(_label("Aktif sorunu olmayan departmanlar: " + ", ".join(quiet), 14, MUTED))

	var advisors := _card("DANIŞMANLAR · en fazla 2 · etkin yetkinlik = max(patron, danışman)")
	_append_card(body, advisors)
	for consultant in game.consultants:
		advisors.add_child(_label("✓ %s · %s · kalan %d ay" % [consultant["name"], _scores(consultant["scores"]), consultant["months_left"]], 15, ACCENT))
	for index in game.candidates.size():
		var candidate: Dictionary = game.candidates[index]
		var reason: String = game.hire_block_reason(index)
		var hire := _button("%s · %s · %d ay %.0f para" % [candidate["name"], _scores(candidate["scores"]), BossState.CONSULTANT_MONTHS, candidate["total"]], func(): _act(game.hire(index)))
		hire.disabled = reason != ""
		hire.tooltip_text = reason
		advisors.add_child(hire)
	var credit := _button("Tek seferlik kriz kredisi al · %.0f" % BossState.CREDIT_AMOUNT, func(): _act(game.take_credit()))
	credit.disabled = game.credit_used
	body.add_child(credit)
	body.add_child(_button("Kararları bitir, ayı kapat  →", func(): _act(game.finish_month())))

func _department_card(department: String, rows: Array[Dictionary]) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(SURFACE))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	var patron: int = game.skills[department]
	var effective: int = game.effective_skill(department)
	var reach: int = game.reach(department)
	var head := "%s · patron %d%s → T%d'ye kadar okur" % [department.to_upper(), patron, (" · danışmanla %d" % effective) if effective > patron else "", reach]
	box.add_child(_label(head, 14, ACCENT))
	for row in rows:
		var slot_name: String = ("T%d" % row["tier"]) if row["visible"] else "Derinlik bilinmiyor"
		box.add_child(_label("%s · %.0f kayıp · şans %s" % [slot_name, row["loss"], row["chance"]], 15, TEXT if row["visible"] else GOLD))
		var text: String = "Bu ay denendi" if row["attempted"] else "Düzelt · tahmin %.0f / en fazla %.0f · %d–%d sa" % [row["estimate"], row["upper"], row["estimate_hours"], row["upper_hours"]]
		var button := _button(text, func(): _act_fix(row["id"]))
		button.disabled = row["attempted"] or row["blocked"] != ""
		button.tooltip_text = row["blocked"]
		box.add_child(button)
		if row["blocked"] != "" and not row["attempted"]:
			box.add_child(_label(row["blocked"], 12, RED))
	return panel

func _scores(scores: Dictionary) -> String:
	var parts: Array[String] = []
	for key in scores:
		parts.append("%s %d" % [key, scores[key]])
	return ", ".join(parts)

# ---------------------------------------------------------------- end

func _show_end() -> void:
	var card := _card("KAPANIŞ RAPORU")
	_append_card(body, card)
	var outcome := {"survived": "Fabrika test süresince ayakta kaldı.", "forced": "Zorunlu kapanış: tasfiye borcu kapattı, iflas değil.", "bankrupt": "Zorunlu kapanış ve iflas: tasfiyeden sonra borç kaldı."}
	card.add_child(_label(outcome.get(game.closure.get("type", ""), "Test bitti."), 20, ACCENT))
	card.add_child(_label("Son kasa %.0f · kredi borcu %.0f · makine %d" % [game.cash, game.debt, game.machines.size()], 16, TEXT))
	for row in game.closing_rows():
		card.add_child(_label("%s · T%d · toplam kayıp %.0f · %s · %s · kesin çözüm için %d (sende %d)" % [row["department"], row["tier"], row["total_loss"], "gördün" if row["seen"] else "göremedin", "çözüldü" if row["solved"] else "sürüyor", row["needed"], row["skill"]], 14, TEXT if row["seen"] else GOLD))
	for lesson in game.lessons():
		card.add_child(_label("“%s”" % lesson, 17, GOLD))
	if not game.findings.is_empty():
		var auto := _card("OTOMATİK BULGULAR")
		_append_card(body, auto)
		for finding in game.findings:
			auto.add_child(_label("• " + finding, 14, MUTED))
	body.add_child(_button("Yeni patronla yeniden başla", _restart))

func _restart() -> void:
	game = BossState.new()
	selected_jobs.clear()
	_refresh()

# ---------------------------------------------------------------- shared

func _act(error: String) -> void:
	if error != "":
		game.notice = error
	_refresh()

func _act_fix(root_id: String) -> void:
	game.fix(root_id)
	_refresh()

func _show_history() -> void:
	if game.history.is_empty():
		return
	var card := _card("GEÇMİŞ")
	_append_card(body, card)
	var start := maxi(0, game.history.size() - 12)
	for index in range(game.history.size() - 1, start - 1, -1):
		card.add_child(_label("• " + game.history[index], 13, MUTED))

func _style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	for side in ["left", "right", "top", "bottom"]:
		style.set("content_margin_" + side, 16)
	return style

func _card(title: String) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(SURFACE))
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 10)
	panel.add_child(inner)
	inner.add_child(_label(title, 14, ACCENT))
	inner.set_meta("card_panel", panel)
	return inner

func _append_card(parent: Node, card: VBoxContainer) -> void:
	parent.add_child(card.get_meta("card_panel"))

func _add_card(parent: Node, title: String, description: String, color: Color) -> void:
	var card := _card(title)
	_append_card(parent, card)
	card.add_child(_label(description, 16, color))

func _label(value: String, size: int, color: Color, wrap := true) -> Label:
	var label := Label.new()
	label.text = value
	# Wrapping labels inside unsized boxes collapse to one letter per line.
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(value: String, callback: Callable = Callable()) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size.y = 38
	if callback.is_valid():
		button.pressed.connect(callback)
	return button
