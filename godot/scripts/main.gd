extends Control

const GameState = preload("res://scripts/game_state.gd")
const BG := Color("#101827")
const SURFACE := Color("#1a2739")
const BORDER := Color("#33445b")
const TEXT := Color("#e9f1fa")
const MUTED := Color("#a2b3c8")
const ACCENT := Color("#46d4b0")
const GOLD := Color("#eac47a")

var game = GameState.new()
var selected_job := "cnc"
var selected_secondary := ""
var body: VBoxContainer

func _ready() -> void:
	get_viewport().set_embedding_subwindows(false)
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
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 36)
	scroll.add_child(margin)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	margin.add_child(body)

func _refresh() -> void:
	for child in body.get_children():
		body.remove_child(child)
		child.queue_free()
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 20)
	body.add_child(top)
	var title := _label("the Path / BOSS", 30, TEXT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	top.add_child(_label(_phase_title(), 16, ACCENT))
	_add_card(body, "HİKÂYE", game.notice, GOLD)
	if game.phase == "career":
		_show_career()
	elif game.phase == "founding":
		_show_founding()
	elif game.phase == "offer":
		_show_offer()
	elif game.phase == "report":
		_show_report()
	else:
		_show_end()
	_show_history()
	var footer := _label("Oynanabilir örnek • 3 kariyer ayı + 3 fabrika ayı • rakamlar denge kararı değildir", 12, MUTED)
	body.add_child(footer)

func _phase_title() -> String:
	match game.phase:
		"career": return "KARİYER · AY %d / 3" % game.career_month
		"founding": return "FABRİKA KURULUŞU"
		"offer": return "FABRİKA · AY %d / 3 · İŞ SEÇ" % game.factory_month
		"report": return "FABRİKA · AY %d / 3 · RAPOR" % game.factory_month
	return "DİLİM TAMAMLANDI"

func _show_career() -> void:
	var stats := _card("MEVCUT DURUM")
	_append_card(body, stats)
	stats.add_child(_label("Kişisel kasa: %.0f     Enerji: %d / 6     Mevcut iş: %s" % [game.career_cash, game.energy, GameState.ROLES[game.current_job]["title"] if game.current_job != "" else "Yok"], 17, TEXT))
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 8)
	stats.add_child(grid)
	for skill in GameState.SKILLS:
		grid.add_child(_label("%s  %d" % [skill, game.skills[skill]], 14, MUTED))

	var choices := _card("BU AY NE YAPACAKSIN?")
	_append_card(body, choices)
	choices.add_child(_label("İş seçimi maaşını ve ileride görebileceğin sorunları etkiler.", 15, MUTED))
	var jobs := HBoxContainer.new()
	jobs.add_theme_constant_override("separation", 12)
	choices.add_child(jobs)
	for job_id in GameState.ROLES:
		var role: Dictionary = GameState.ROLES[job_id]
		var button := _button("%s · +%.0f para%s" % [role["title"], role["wage"], "  ✓" if selected_job == job_id else ""])
		button.pressed.connect(_select_job.bind(job_id))
		jobs.add_child(button)
	choices.add_child(_label("Boş zaman: İş değiştirirken ek etkinlik yapamazsın.", 14, MUTED))
	var activities := OptionButton.new()
	activities.add_item("Ek etkinlik yok")
	activities.add_item("Dinlen (+2 enerji)")
	for skill in GameState.SKILLS:
		activities.add_item("%s kursu (+15, 10 para)" % skill)
	var index := 0
	if selected_secondary == "rest":
		index = 1
	elif GameState.SKILLS.has(selected_secondary):
		index = GameState.SKILLS.find(selected_secondary) + 2
	activities.select(index)
	activities.item_selected.connect(_select_secondary)
	choices.add_child(activities)
	choices.add_child(_button("Ayı tamamla  →", _work))

func _show_founding() -> void:
	var card := _card("KENDİ FABRİKANI KUR")
	_append_card(body, card)
	card.add_child(_label("Kariyer kasası: %.0f para" % game.career_cash, 19, TEXT))
	card.add_child(_label("Örnek küçük fabrika: makine 30 para. Kuruluş sonrası en az 70 para gerekir: 50 bilinen gider + 20 gizli sorun güvencesi.", 15, MUTED))
	card.add_child(_button("Küçük fabrikayı kur  →", _found))

func _show_offer() -> void:
	var card := _card("İŞ ALMA")
	_append_card(body, card)
	card.add_child(_label("Şirket kasası %.2f · Makine kapasitesi 100 · Aylık olağan gider 50" % game.cash, 17, TEXT))
	card.add_child(_label("Teklifin bedeli ay sonunda ödenir. Bu ay alınmayan kapasite raporda ayrı görünür.", 14, MUTED))
	for offer_id in GameState.OFFERS:
		var offer: Dictionary = GameState.OFFERS[offer_id]
		card.add_child(_button("%s · hedef %d · birim fiyat %.1f · bilinen maliyet %.0f" % [offer["title"], offer["quantity"], offer["price"], offer["cost"]], _accept_offer.bind(offer_id)))

func _show_report() -> void:
	var summary := _card("AY SONU RAPORU")
	_append_card(body, summary)
	summary.add_child(_label("Beklenen  %.0f       Gerçekleşen  %.0f       Kayıp  %.0f       Boş kapasite  %.0f" % [game.report["expected"], game.report["realized"], game.report["loss"], game.report["empty"]], 18, TEXT))
	summary.add_child(_label("Tahmini satış geliri %.2f · Şirket kasası %.2f · Patron zamanı %d / 6 saat" % [game.report["revenue"], game.cash, game.hours_left], 15, MUTED))
	summary.add_child(_label("Düzelt başarılı olsa bile bu ayın raporu değişmez. Faydayı gelecek ay görürsün.", 13, GOLD))
	var by_department: Dictionary = {}
	for row in game.active_rows():
		if not by_department.has(row["department"]):
			by_department[row["department"]] = []
		by_department[row["department"]].append(row)
	for department in ["Planlama", "Üretim"]:
		var card := _card("%s KARTI" % department.to_upper())
		_append_card(body, card)
		for tier in [1, 2, 3, 4, 5]:
			var found := false
			for row in by_department.get(department, []):
				if row["tier"] != tier:
					continue
				found = true
				var line := HBoxContainer.new()
				line.add_theme_constant_override("separation", 14)
				card.add_child(line)
				var label_text := "T%d · %.0f kayıp" % [tier, row["loss"]] if row["visible"] else "Derinlik bilinmiyor · %.0f kayıp" % row["loss"]
				var label := _label(label_text, 15, TEXT if row["visible"] else GOLD)
				label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				line.add_child(label)
				var probability := "Kesin" if row["visible"] else "Düşük"
				line.add_child(_label(probability, 13, ACCENT if row["visible"] else GOLD))
				var button := _button("Düzelt" if not row["attempted"] else "Bu ay denendi", _fix.bind(row["id"]))
				button.disabled = row["attempted"]
				line.add_child(button)
			if not found and tier <= 2:
				card.add_child(_label("T%d  —" % tier, 14, MUTED))
			elif not found:
				card.add_child(_label("T%d  ölçek dışı" % tier, 14, MUTED))
	body.add_child(_button("Kararları bitir, ayı kapat  →", _finish_month))

func _show_end() -> void:
	var card := _card("BU OYUN DİLİMİNİN SONU")
	_append_card(body, card)
	card.add_child(_label("Son şirket kasası %.2f" % game.cash, 21, ACCENT))
	card.add_child(_label("Kariyer seçiminin fabrika raporuna etkisini gördün. Farklı bir rota için yeniden başlat.", 16, MUTED))
	card.add_child(_button("Yeniden başla", _restart))

func _show_history() -> void:
	if game.history.is_empty():
		return
	var card := _card("GEÇMİŞ")
	_append_card(body, card)
	for event in game.history:
		card.add_child(_label("• " + event, 13, MUTED))

func _card(title: String) -> VBoxContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = SURFACE
	style.border_color = BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", style)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 12)
	panel.add_child(inner)
	inner.add_child(_label(title, 14, ACCENT))
	return _attachable_card(panel, inner)

func _attachable_card(panel: PanelContainer, inner: VBoxContainer) -> VBoxContainer:
	# The panel is inserted wherever its inner container is inserted.
	inner.set_meta("card_panel", panel)
	return inner

func _add_card(parent: Node, title: String, description: String, color: Color) -> void:
	var card := _card(title)
	_append_card(parent, card)
	card.add_child(_label(description, 17, color))

func _append_card(parent: Node, card: VBoxContainer) -> void:
	parent.add_child(card.get_meta("card_panel"))

func _label(value: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(value: String, callback: Callable = Callable()) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size.y = 42
	if callback.is_valid():
		button.pressed.connect(callback)
	return button

func _select_job(job_id: String) -> void:
	selected_job = job_id
	_refresh()

func _select_secondary(index: int) -> void:
	selected_secondary = "" if index == 0 else ("rest" if index == 1 else GameState.SKILLS[index - 2])

func _work() -> void:
	game.work_month(selected_job, selected_secondary)
	selected_secondary = ""
	_refresh()

func _found() -> void:
	game.found_factory()
	_refresh()

func _accept_offer(offer_id: String) -> void:
	game.accept_offer(offer_id)
	_refresh()

func _fix(root_id: String) -> void:
	game.fix(root_id)
	_refresh()

func _finish_month() -> void:
	game.finish_month()
	_refresh()

func _restart() -> void:
	game = GameState.new()
	selected_job = "cnc"
	selected_secondary = ""
	_refresh()
