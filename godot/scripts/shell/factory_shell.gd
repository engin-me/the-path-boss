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
const YonetimView = preload("res://scripts/shell/yonetim_view.gd")
const DesignCanvas = preload("res://scripts/shell/design_canvas.gd")
const PlanGantt = preload("res://scripts/shell/plan_gantt.gd")

# Palette (art/ui/renk_paleti.png)
const BG := Color("#0f1720")          # main screen background (as drawn in the design deck)
const BAR := Color("#101b26")         # header, time bar, bottom nav
const PANEL := Color("#182431")       # cards, panels
const PANEL_ALT := Color("#22303d")   # options, passive areas
const BORDER := Color("#344556")      # card border, divider
const TEXT := Color("#e7edf3")        # titles, important text
const MUTED := Color("#98a7b6")       # captions
const FAINT := Color("#657687")       # disabled, tertiary info
const GREEN := Color("#2fd17b")       # selected, confirm, main call to action
const GREEN_HI := Color("#4be394")    # hover, active highlight
const GREEN_DIM := Color("#123b2a")   # active tab background
const CYAN := Color("#45c7d8")        # technical icons, measures
const GOLD := Color("#e7b75c")        # warning, pending decision
const YELLOW := Color("#e7b75c")
const RED := Color("#e86f6f")         # risk, loss, delay
const BLUE := Color("#62a8e5")        # info, neutral data

# IBM Plex Sans: Regular for running text, Medium for values and buttons, SemiBold for titles, Bold for emphasis.
var FONT_REGULAR: Font = Art.font("Regular")
var FONT_MEDIUM: Font = Art.font("Medium")
var FONT_SEMIBOLD: Font = Art.font("SemiBold")
var FONT_BOLD: Font = Art.font("Bold")

const FONT_SCALE := 1.12   # the whole UI text is 12 percent larger than the base sizes

const TABS := [
	{"id": "ofis", "icon": "🏢", "title": "Yönetim", "file": "yonetim/nav_yonetim"},
	{"id": "satin", "icon": "🛒", "title": "Satın Alma", "file": "yonetim/nav_satin_al"},
	{"id": "teklif", "icon": "✎", "title": "Teklif Ver", "file": "yonetim/nav_teklif"},
	{"id": "mail", "icon": "✉", "title": "Mail", "file": "yonetim/nav_mail"}
]
const OFFICE_PAGES := ["ozet", "fabrika", "profil"]   # everything the Ofis tab holds

var game = ShellBoss.new()
var flash := ""
var page := "ozet"
const CapacityChart := preload("res://scripts/shell/capacity_chart.gd")
var subtab := {"ozet": "genel", "ilanlar": "isler", "fabrika": "yerlesim"}
const MONTH_DAYS := 30
const FLOW_SECONDS_PER_MONTH := 24.0   # one month at 1x
var flow_on := true           # the clock runs day by day (IDEA-019); Ayarlar can switch back to the monthly buttons
var flow_speed := 0           # 0 paused, then 1 / 2 / 4
var flow_resume := 0          # speed to resume after the month report
var flow_day := 0.0
var toast_count := 0
var flow_hint: Label
var clock_bar: Control
var clock_label: Label
var clock_progress: ProgressBar
var clock_buttons := {}
var office_last := "ozet"
var open_offer := -1
var move_sell: Array = []
var job_filters: Array = []
var job_sort := "yeni"
var mail_open := -1
var mail_show_offer := false
var mail_reply_open := false
var quote_details := false
var quote_progress := true
var quote_start_offset := 0
var quote_buffer := 0
var drag_base := 0
var return_to := {}   # where the back bar leads after a shortcut from the quote screen
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
var tab_captions := {}
var mail_badge: PanelContainer
var mail_badge_label: Label
var announced_mails := {}
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
	var ui_theme := Theme.new()
	ui_theme.default_font = FONT_REGULAR   # IBM Plex Sans everywhere unless a label picks another weight
	theme = ui_theme
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
	_load_flow_setting()
	flow_day = float(game.days_run)
	_build()
	_apply_safe_area()
	_update_clock()
	_render()

# Android back key: close a dialog, then a detail screen, then go to Özet.
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_autosave()
		if flow_speed > 0:
			flow_speed = 0
			_update_clock()
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
	flow_day = 0.0
	flow_speed = 0
	flow_resume = 0
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
	clock_bar = _build_clock()
	column.add_child(clock_bar)
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

func _top_icon(name: String, handler: Callable) -> Button:
	var button := Button.new()
	button.flat = true
	button.custom_minimum_size = Vector2(YonetimView.S(34), YonetimView.S(34))
	var texture := Art.find("res://art/ui/yonetim/" + name)
	if texture != null:
		button.icon = texture
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.add_theme_constant_override("icon_max_width", int(YonetimView.S(28.3)))
	button.pressed.connect(handler)
	_juice(button)
	return button

func _build_header() -> Control:
	var bar := PanelContainer.new()
	bar.add_theme_stylebox_override("panel", _box(BAR, BAR, 0, 0))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	bar.add_child(_margin(row, 14, 6))
	header_money = _label("", 18, GREEN, false)
	header_money.add_theme_font_size_override("font_size", YonetimView.F(18))
	header_money.add_theme_font_override("font", FONT_SEMIBOLD)
	row.add_child(header_money)
	header_date = _label("", 11, MUTED, false)
	header_date.add_theme_font_size_override("font_size", YonetimView.F(11))
	header_date.add_theme_font_override("font", FONT_MEDIUM)
	header_date.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_date.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	row.add_child(header_date)
	header_hours = _label("", 12, MUTED, false)
	row.add_child(header_hours)
	row.add_child(_top_icon("ust_gecmis", _open_detail.bind("log")))
	row.add_child(_top_icon("ust_ayarlar", _open_detail.bind("settings")))
	return bar

func _build_clock() -> Control:
	var bar := PanelContainer.new()
	bar.add_theme_stylebox_override("panel", _box(BG, BG, 0, 0))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	bar.add_child(_margin(row, 14, 12))
	clock_label = _label("", 11, TEXT, false)
	clock_label.add_theme_font_size_override("font_size", YonetimView.F(11))
	clock_label.custom_minimum_size = Vector2(YonetimView.S(72), 0)
	row.add_child(clock_label)
	clock_progress = ProgressBar.new()
	clock_progress.show_percentage = false
	clock_progress.max_value = float(MONTH_DAYS)
	clock_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clock_progress.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	clock_progress.custom_minimum_size = Vector2(0, YonetimView.S(14.2))
	clock_progress.add_theme_stylebox_override("background", _box(Color("#0b1118"), Color("#222e3b"), 50, 1))
	clock_progress.add_theme_stylebox_override("fill", _box(GOLD, GOLD, 50, 0))
	row.add_child(clock_progress)
	# play, pause, fast-forward (1st tap 2x, 2nd 4x, 3rd normal) and skip the month: round line icons, no frames
	for spec in [[1, "saat_oynat", "Başlat"], [0, "saat_durdur", "Durdur"], [2, "saat_hizlandir", "Hızlandır"], [-1, "saat_ay_atla", "Ayı atla"]]:
		var button := Button.new()
		button.flat = true
		button.tooltip_text = spec[2]
		button.custom_minimum_size = Vector2(YonetimView.S(36), YonetimView.S(36))
		var icon := Art.find("res://art/ui/yonetim/" + String(spec[1]))
		if icon != null:
			button.icon = icon
			button.expand_icon = true
			button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			button.add_theme_constant_override("icon_max_width", int(YonetimView.S(30)))
		else:
			button.text = {0: "⏸", 1: "▶", 2: "⏩", -1: "⏭"}[int(spec[0])]
		if int(spec[0]) < 0:
			button.pressed.connect(_skip_month)
		else:
			if int(spec[0]) == 2:
				button.pressed.connect(_fast_forward)
			else:
				button.pressed.connect(_set_flow_speed.bind(int(spec[0])))
			clock_buttons[int(spec[0])] = button
		_juice(button)
		row.add_child(button)
	bar.visible = false
	return bar

func _fast_forward() -> void:
	if flow_speed == 2:
		_set_flow_speed(4)
	elif flow_speed == 4:
		_set_flow_speed(1)
	else:
		_set_flow_speed(2)

func _set_flow_speed(speed: int) -> void:
	if game.phase != "offers" and speed > 0:
		return
	flow_speed = speed
	_update_clock()

# The clock stops by itself (month end, a quote or a purchase being decided): a big amber pause icon shrinks and
# fades toward the pause button so the player sees that time stands still.
func _auto_pause() -> void:
	if flow_speed <= 0:
		return
	flow_speed = 0
	_update_clock()
	_pause_focus()

func _pause_focus() -> void:
	var texture: Texture2D = Art.find("res://art/ui/yonetim/saat_durdur")
	if texture == null or not clock_buttons.has(0):
		return
	var target: Button = clock_buttons[0]
	var big := TextureRect.new()
	big.texture = texture
	big.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	big.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	big.size = Vector2(150, 150)
	big.pivot_offset = Vector2(75, 75)
	big.modulate = GOLD
	big.mouse_filter = Control.MOUSE_FILTER_IGNORE
	big.position = size * 0.5 - Vector2(75, 75)
	add_child(big)
	var goal: Vector2 = target.global_position + target.size * 0.5 - Vector2(75, 75)
	var tween := create_tween()
	tween.tween_interval(0.25)
	tween.set_parallel(true)
	tween.tween_property(big, "position", goal, 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(big, "scale", Vector2(0.24, 0.24), 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(big, "modulate:a", 0.0, 0.55).set_delay(0.15)
	tween.chain().tween_callback(func() -> void:
		big.queue_free()
		if is_instance_valid(target):
			var pulse := create_tween()
			pulse.tween_property(target, "scale", Vector2(1.25, 1.25), 0.12)
			pulse.tween_property(target, "scale", Vector2.ONE, 0.18))

# Skip the month: the remaining days run at once, then the month closes with its report.
func _skip_month() -> void:
	if game == null or game.phase != "offers":
		return
	var events: Array = game.finish_month_days()
	for event in events:
		_toast(String(event["text"]), float(event["amount"]))
	_sync_cash()
	flow_day = float(MONTH_DAYS)
	if floor_view != null:
		floor_view.refresh_state()
	_flow_month_end()

func _date_text() -> String:
	return Data.month_label(int(game.month)).get_slice(" · ", 1)   # "Mart 2027"; the day is on the time bar

func _update_mail_badge() -> void:
	if mail_badge == null:
		return
	var unread: int = game.unread_mails()
	mail_badge.visible = unread > 0
	mail_badge_label.text = str(unread) if unread < 10 else "9+"
	# top-right corner of the Mail button
	var button: Button = tab_buttons["mail"]
	mail_badge.position = Vector2(button.size.x - mail_badge.size.x - 6.0, 4.0)

# A customer answer reaches the inbox 5-10 seconds after the quote: a short note, the red badge, no auto-open.
func _check_mail_arrivals() -> void:
	if game == null:
		return
	var news := false
	for mail in game.mails.slice(0, 6):
		var id: int = int(mail["id"])
		if mail.has("ready_ms") and game.mail_arrived(mail) and not announced_mails.has(id):
			announced_mails[id] = true
			news = true
			_toast("✉ Yeni mail: %s" % mail["title"], 0.0)
			audio.play("coin_up")
	if news:
		_update_mail_badge()
		if page == "mail" and detail == "" and mail_open < 0:
			_render_keep_scroll()

func _update_clock() -> void:
	if clock_bar == null:
		return
	clock_bar.visible = flow_on and game.phase != "setup" and game.phase != "end"
	clock_label.text = "Gün: %d/%d" % [mini(MONTH_DAYS, game.day), MONTH_DAYS]
	if header_date != null:
		header_date.text = _date_text()
	if flow_hint != null and is_instance_valid(flow_hint):
		flow_hint.visible = flow_speed == 0 and game.phase == "offers"
	clock_progress.value = flow_day
	for speed in clock_buttons:
		var active: bool = speed == flow_speed or (speed == 2 and flow_speed == 4)
		var button: Button = clock_buttons[speed]
		if speed == 2 and button.icon == null:
			button.text = "⏩4x" if flow_speed == 4 else ("⏩2x" if flow_speed == 2 else "⏩")
		for color_name in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "font_color"]:
			button.add_theme_color_override(color_name, GREEN_HI if active else TEXT)

func _process(delta: float) -> void:
	_check_mail_arrivals()
	if not flow_on or flow_speed <= 0 or game == null or game.phase != "offers":
		return
	if overlay != null and overlay.get_child_count() > 0:
		return
	flow_day = minf(float(MONTH_DAYS), flow_day + delta * float(flow_speed) * float(MONTH_DAYS) / FLOW_SECONDS_PER_MONTH)
	var target := int(flow_day)
	var changed := false
	var events: Array = []
	while game.days_run < target and game.phase == "offers" and game.days_run < MONTH_DAYS:
		var result: Dictionary = game.advance_day()
		changed = true
		if floor_view != null:
			floor_view.day_frac = flow_day / float(MONTH_DAYS)
			floor_view.add_day(result["produced"])
		events.append_array(result["events"])
	if floor_view != null:
		floor_view.day_frac = flow_day / float(MONTH_DAYS)
		floor_view.queue_redraw()
	if changed:
		_update_clock()
		_sync_cash()
		for event in events:
			_toast(String(event["text"]), float(event["amount"]))
		if not events.is_empty():
			if floor_view != null:
				floor_view.refresh_state()
			elif detail == "" and ["ozet", "fabrika"].has(page):
				_render_keep_scroll()
		elif floor_view == null and detail == "" and page == "fabrika" and subtab["fabrika"] == "isler":
			_render_keep_scroll()   # the job bars follow the production of every day
	if game.days_run >= MONTH_DAYS:
		flow_day = float(MONTH_DAYS)
		_flow_month_end()

# Header money follows the days: the cash changes while the clock runs.
func _sync_cash() -> void:
	var cash_now := float(game.cash)
	if not is_nan(last_cash) and absf(cash_now - last_cash) > 0.5:
		audio.play("coin_up" if cash_now > last_cash else "coin_down")
		_animate_money(last_cash, cash_now)
	last_cash = cash_now

# Short note for a day event; they stack at the top for a moment and fade away.
func _toast(text: String, amount: float) -> void:
	var label := _label(text + ((" · " + Data.usd(amount)) if absf(amount) > 0.0005 else ""), 13, GREEN if amount > 0.0 else (RED if amount < 0.0 else TEXT), false)
	label.position = Vector2(14, 120 + 26 * toast_count)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	toast_count += 1
	var tween := create_tween()
	tween.tween_interval(1.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func() -> void:
		toast_count = maxi(0, toast_count - 1)
		label.queue_free())

# The month is over: the clock stops and the report opens (it stays mandatory for now).
func _flow_month_end() -> void:
	flow_resume = flow_speed
	_auto_pause()
	flow_speed = 0
	audio.play("month")
	page = "ozet"
	detail = ""
	_open_report()

func _flow_after_month() -> void:
	flow_day = float(game.days_run)
	flow_speed = flow_resume if game.phase == "offers" else 0
	_update_clock()
	if flow_on:
		_month_banner()
	var brief: Array = game.plan_brief() if game.phase == "offers" else []
	if not brief.is_empty():
		_confirm("Ay başı özeti", brief, "Tamam", Callable())

# Big month number that fades away (the small date stays in the header).
func _month_banner() -> void:
	var banner := _label(Data.month_label(int(game.month)).get_slice(" · ", 0), 72, TEXT, false)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
	banner.grow_vertical = Control.GROW_DIRECTION_BOTH
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(banner)
	banner.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(banner, "modulate:a", 1.0, 0.35)
	tween.tween_interval(0.7)
	tween.tween_property(banner, "modulate:a", 0.0, 0.9)
	tween.tween_callback(banner.queue_free)

func _load_flow_setting() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		flow_on = bool(config.get_value("time", "flow", true))

func _set_flow_on(on: bool) -> void:
	flow_on = on
	flow_speed = 0
	var config := ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("time", "flow", on)
	if audio != null and audio.active():
		config.save("user://settings.cfg")
	_update_clock()
	_render()

func _build_tab_bar() -> Control:
	var bar := PanelContainer.new()
	bar.add_theme_stylebox_override("panel", _box(BAR, BORDER, 0, 0))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(YonetimView.S(5.6)))
	bar.add_child(_margin(row, int(YonetimView.S(6.7)), int(YonetimView.S(4.4))))
	for tab in TABS:
		var button := Button.new()
		var tab_icon := Art.find("res://art/ui/" + String(tab["file"]))
		if tab_icon != null:
			# a fixed icon box above the caption so the four captions line up whatever the icon's shape
			var stack := VBoxContainer.new()
			stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
			stack.alignment = BoxContainer.ALIGNMENT_CENTER
			stack.add_theme_constant_override("separation", 4)
			var holder := TextureRect.new()
			holder.texture = tab_icon
			holder.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			holder.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			holder.custom_minimum_size = Vector2(0, YonetimView.S(42.5))
			holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
			stack.add_child(holder)
			var caption := _label(String(tab["title"]), 12, TEXT, false)
			caption.add_theme_font_size_override("font_size", YonetimView.F(12))
			caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
			caption.add_theme_font_override("font", FONT_MEDIUM)
			stack.add_child(caption)
			button.add_child(stack)
			tab_captions[tab["id"]] = caption
		else:
			button.text = "%s\n%s" % [tab["icon"], tab["title"]]
		button.custom_minimum_size = Vector2(0, YonetimView.S(68))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", _fs(13))
		button.add_theme_font_override("font", FONT_MEDIUM)
		button.pressed.connect(_on_tab.bind(tab["id"]))
		_juice(button)
		row.add_child(button)
		tab_buttons[tab["id"]] = button
		if tab["id"] == "mail":
			mail_badge = PanelContainer.new()
			mail_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			mail_badge.add_theme_stylebox_override("panel", _box(RED, BAR, 12, 2))
			mail_badge_label = _label("0", 11, BG, false)
			mail_badge_label.add_theme_font_override("font", FONT_SEMIBOLD)
			mail_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			mail_badge.add_child(_margin(mail_badge_label, 6, 0))
			mail_badge.custom_minimum_size = Vector2(22, 22)
			button.add_child(mail_badge)
			mail_badge.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
			mail_badge.position = Vector2(button.size.x * 0.0, 0.0)
			mail_badge.visible = false
	return bar

# Section picker at the top of every Ofis screen: summary, plant, jobs, suppliers and the boss profile in one place.
func _office_menu() -> void:
	var current := "ozet"
	if page == "profil":
		current = "profil"
	elif page == "fabrika":
		current = subtab["fabrika"] if ["isler", "tedarik"].has(subtab["fabrika"]) else "fabrika"
	var options: Array = [{"id": "ozet", "title": "Özet"}, {"id": "fabrika", "title": "Fabrika"}]
	if game.factory_id != "":
		options.append({"id": "isler", "title": "İşler (%d)" % game.jobs.size()})
		options.append({"id": "tedarik", "title": "Tedarik"})
	options.append({"id": "profil", "title": "Patron"})
	var pick := func(id: String) -> void:
		match id:
			"ozet", "profil":
				_on_tab(id)
			"fabrika":
				if not ["yerlesim", "vardiya", "sozlesme", "kapasite"].has(subtab["fabrika"]):
					subtab["fabrika"] = "yerlesim"
				_on_tab("fabrika")
			_:
				subtab["fabrika"] = id
				_on_tab("fabrika")
	_chips(sticky, options, current, pick)

# ------------------------------------------------------------------ helpers

static func _fs(size: int) -> int:
	return int(roundf(float(size) * FONT_SCALE))

func _label(text: String, size := 14, color := TEXT, wrap := true) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", _fs(size))
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_override("font", FONT_SEMIBOLD if size >= 20 else (FONT_MEDIUM if size >= 15 else FONT_REGULAR))
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
	rich.add_theme_font_size_override("bold_font_size", size)
	rich.add_theme_font_override("normal_font", FONT_REGULAR)
	rich.add_theme_font_override("bold_font", FONT_BOLD)
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
	if text.length() > 14:
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # a long reason must wrap, never widen the page
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
	bar.add_theme_stylebox_override("background", _box(BG, BORDER, 5, 1))
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

func _confirm(title: String, lines: Array, ok_text: String, on_ok: Callable, warn := "", extras := []) -> void:
	_close_overlay()
	_auto_pause()   # a decision dialog stops the clock
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
	for extra in extras:
		var action: Callable = extra[1]
		box.add_child(_button(str(extra[0]), func() -> void:
			audio.play("confirm")
			_close_overlay()
			action.call()))
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
	return_to = {}
	if id == "satin" or id == "teklif":
		_auto_pause()   # buying and quoting are decided with the clock stopped
	if id == "satin":
		id = "ilanlar"
		if not ["tezgah", "ekipman"].has(subtab["ilanlar"]):
			subtab["ilanlar"] = "tezgah"
	elif id == "teklif":
		id = "ilanlar"
		subtab["ilanlar"] = "isler"
	if id == "ofis":
		id = office_last
	if OFFICE_PAGES.has(id):
		office_last = id
	page = id
	detail = ""
	_render()

func _open_detail(kind: String, arg := "") -> void:
	if kind == "quote" or kind == "order" or kind == "supplier_pick":
		_auto_pause()
	detail = kind
	detail_arg = arg
	if kind == "quote":
		quote_months = 0
	if kind == "factory":
		move_sell = []
	_render()

func _back() -> void:
	if detail == "supplier_pick":
		_open_detail("quote", detail_arg)
		return
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
	if overlay.get_child_count() == 0:
		var slack_job: int = game.bonus_pending()
		if slack_job >= 0:
			_bonus_popup(slack_job)

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
	header_date.text = _date_text()
	_update_clock()
	header_money.text = Data.usd(float(game.cash))
	header_hours.text = "⏱ %d/%d sa" % [game.hours_left, game.monthly_hours] if game.phase == "report" else ""
	if tab_buttons.has("mail"):
		var unread: int = game.unread_mails()
		_update_mail_badge()
	for id in tab_buttons:
		var active: bool = id == page or (id == "ofis" and OFFICE_PAGES.has(page))
		if page == "ilanlar":
			var on_jobs: bool = subtab["ilanlar"] == "isler"
			active = (id == "teklif" and on_jobs) or (id == "satin" and not on_jobs)
		var button: Button = tab_buttons[id]
		var tab_radius := int(YonetimView.S(8.2))
		button.add_theme_stylebox_override("normal", _box(Color("#0a2418") if active else Color("#080d13"), BORDER, tab_radius, 1))
		button.add_theme_stylebox_override("hover", _box(Color("#0a2418") if active else Color("#0d141c"), BORDER, tab_radius, 1))
		button.add_theme_stylebox_override("pressed", _box(Color("#0a2418"), BORDER, tab_radius, 1))
		for color_name in ["font_color", "font_hover_color", "font_pressed_color", "icon_normal_color", "icon_hover_color", "icon_pressed_color"]:
			button.add_theme_color_override(color_name, TEXT if not active else TEXT)
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	for child in sticky.get_children():
		sticky.remove_child(child)
		child.queue_free()
	listing_cards.clear()
	area_label = null
	if not return_to.is_empty() and detail == "":
		_return_bar()
	if floor_view != null:
		floor_state = floor_view.view_state()
		stage.remove_child(floor_view)
		floor_view.queue_free()
		floor_view = null
	var rented: bool = page == "fabrika" and detail == "" and game.factory_id != ""
	var show_floor: bool = rented and subtab["fabrika"] == "yerlesim"
	scroll_view.visible = not show_floor
	if OFFICE_PAGES.has(page) and detail == "":
		_office_menu()   # temporary: the cockpit will replace these chips
	if rented and ["yerlesim", "vardiya", "sozlesme", "kapasite"].has(subtab["fabrika"]):
		_chips(sticky, [{"id": "yerlesim", "title": "Yerleşim (üstten)"}, {"id": "vardiya", "title": "Vardiya"}, {"id": "kapasite", "title": "Kapasite"}, {"id": "sozlesme", "title": "Sözleşme"}], subtab["fabrika"],
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
		floor_view.day_frac = flow_day / float(MONTH_DAYS) if flow_on else -1.0
		floor_view.detail_requested.connect(func(kind: String) -> void: _open_detail(kind))
		floor_view.machine_requested.connect(func(uid: int) -> void: _open_detail("machine", str(uid)))
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
	return null   # the design uses one flat background colour on every screen
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
			_render())   # temporary: the cockpit will replace these chips
	if game.factory_id == "":
		var empty := _card(content, "Henüz fabrikan yok", GOLD)
		empty.add_child(_label("Önce bir yer kirala. Sonra ekipman, tezgah ve iş.", 14, MUTED))
		empty.add_child(_button("Kiralık yerlere bak", _on_tab.bind("fabrika"), true))
		return
	match subtab["ozet"]:
		"dep": _ozet_departments()
		"rapor": _ozet_report()
		_: _ozet_general()

# Sub-screens of Yönetim have one way out: back to the management summary (the cockpit will replace the old chip rows).
func _office_back() -> void:
	var back := _button("‹ Yönetim", func() -> void:
		subtab["ozet"] = "genel"
		_on_tab("ozet"), false)
	back.custom_minimum_size = Vector2(130, 40)
	content.add_child(back)

func _phase_button() -> void:
	if flow_on:
		if game.phase == "offers":
			flow_hint = _label("Zaman duruyor: üstteki ▶ ile başlat. Dururken ilanlara bakabilir, teklif verebilir, tezgah alabilirsin.", 13, GOLD)
			flow_hint.visible = flow_speed == 0
			content.add_child(flow_hint)
		elif game.phase == "report":
			content.add_child(_button("Raporu kapat ve devam et ▶", _close_month, true, false, true))
		return
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
	_flow_after_month()

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

# The management summary, built to the design in docs/design/y_netim.pptx.
func _ozet_general() -> void:
	_phase_button()
	var view = YonetimView.new()
	view.build(game)
	view.go.connect(_yonetim_go)
	view.shift_toggled.connect(func(n: int, on: bool) -> void: _on_shift_tick(on, n))
	view.overtime_toggled.connect(func(n: int, on: bool) -> void: _on_overtime_tick(on, n))
	content.add_child(view)

func _yonetim_go(target: String) -> void:
	match target:
		"finance": _open_detail("credit" if game.debt > 0.0 else "costs")
		"cash": _open_detail("cash")
		"satin": _on_tab("satin")
		"jobs":
			subtab["fabrika"] = "isler"
			_on_tab("fabrika")
		"offers": _on_tab("teklif")
		"capacity":
			subtab["fabrika"] = "kapasite"
			_on_tab("fabrika")
		"oee": _open_detail("oee")
		"dep":
			subtab["ozet"] = "dep"
			_render()
		"contract":
			subtab["fabrika"] = "sozlesme"
			_on_tab("fabrika")
		"mail": _on_tab("mail")
		"fabrika":
			subtab["fabrika"] = "yerlesim"
			_on_tab("fabrika")
		"supply":
			subtab["fabrika"] = "tedarik"
			_on_tab("fabrika")
		"boss": _on_tab("profil")
		"report":
			subtab["ozet"] = "rapor"
			_on_tab("ozet")
		"log": _open_detail("log")

func _ozet_general_old() -> void:
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
	_commitments_card()
	_phase_button()
	if game.phase == "offers" and not game.last_lines.is_empty():
		var last := _card(content, "Geçen ay")
		for line in game.last_lines:
			last.add_child(_label(str(line), 13, MUTED))

# Cash is not the same as spendable cash: the advances of unfinished jobs sit in it, the material and the month's costs are still due.
func _commitments_card() -> void:
	var c: Dictionary = game.commitments()
	var card := _card(content, "Nakit ve taahhütler", RED if float(c["free"]) < 0.0 else BORDER, true)
	_row(card, "Kasa", Data.usd(float(c["cash"])), TEXT, 14)
	_row(card, "  içinde teslim edilmemiş işlerin peşinatı", Data.usd(float(c["advances"])), MUTED, 12)
	_row(card, "Ödenecek hammadde", "-" + Data.usd(float(c["material"])), GOLD, 14)
	_row(card, "Aylık gider", "-" + Data.usd(float(c["expense"])), GOLD, 14)
	_row(card, "Gerçekten harcanabilir", Data.usd(float(c["free"])), RED if float(c["free"]) < 0.0 else GREEN, 16)
	if c["first"].is_empty():
		card.add_child(_label("Bekleyen tahsilat yok: kalan bakiyeler iş tesliminde gelir.", 12, MUTED))
	else:
		card.add_child(_label("İlk tahsilat (kalan bakiye): %s, ilk iş teslim edilince." % Data.date_text(int(c["first"]["month"]), int(c["first"]["day"])), 12, MUTED))

func _ozet_report() -> void:
	if game.phase != "report":
		var box := _card(content, "Ay raporu")
		if game.last_lines.is_empty():
			box.add_child(_label("Rapor, ay sonunda zaman dolunca kendiliğinden açılır." if flow_on else "Rapor, ay başında \"Ayı çalıştır\" ile açılır.", 14, MUTED))
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
			"Kapasite: tezgahın gücüne (kW × 1.500 ω) ve kondisyonuna bağlı; her %10 kondisyon eksiği kapasiteyi %5 düşürür. Hurda: tezgah türü, seviyesi ve kondisyonuna bağlı.",
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
	if game.jobs.is_empty() and float(report["used"]) <= 0.0:
		box.add_child(_label("Kabul edilmiş iş yok; kapasite var ama üretilecek bir şey yok.", 12, GOLD))
	elif game.jobs.is_empty():
		box.add_child(_label("Bu ay işler tamamlanıp teslim edildi; yeni iş kabul edilmedi.", 12, GREEN))
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
	var capacity_before: float = game.effective_capacity()
	var result: Dictionary = game.fix(root_id)
	var line: String = game.notice
	if bool(result.get("ok", false)) and bool(result.get("success", false)):
		var gained: float = game.effective_capacity() - capacity_before
		if gained > 0.5:
			line += " Üretilebilir kapasite +%s/ay." % _xfmt(gained)
	_say(line)
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
	var letter: Dictionary = game.closure.get("letter", {})
	if not letter.is_empty():
		var paper := _card(content, letter["title"], RED, true)
		for line in letter["lines"]:
			paper.add_child(_label(String(line), 13, TEXT))
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
	elif order["supplier"] == "customer":
		_row(card, "Hammadde", "müşteri verdi (fason)", GREEN, 14)
	else:
		var supplier: Dictionary = Data.supplier_by_id(order["supplier"])
		var arrived: bool = int(order["arrive_month"]) <= game.month
		_row(card, "Hammadde", "%s · %s" % [supplier["name"], "geldi" if arrived else "Ay %d gelir" % order["arrive_month"]], GREEN if arrived else GOLD, 14)
		_row(card, "Ödeme", "ödendi" if order["paid"] else "Ay %d · %s" % [order["pay_month"], Data.usd(float(order["amount"]))], MUTED, 13)
		if order["delayed"]:
			card.add_child(_label("Tedarikçi bu siparişi geciktirdi (+1 ay).", 12, RED))
	if game.slack_of(job) >= Data.SLACK_MIN:
		var bonus_names := {"": "kullanılmıyor", "speed": "hızlı işleme", "scrap": "hurda azaltma"}
		_row(card, "Tolerans payı", bonus_names[String(job.get("bonus", ""))], GOLD, 14)
		card.add_child(_button("Tolerans payını değiştir", _bonus_popup.bind(job["id"])))
	_row(card, "Peşinat alındı", Data.usd(float(job["advance"])), MUTED, 13)
	_row(card, "Gelir (tesliminde)", Data.usd(float(job["revenue"])), GREEN, 14)
	var order_index := 0
	for i in game.jobs.size():
		if int(game.jobs[i]["id"]) == int(job["id"]):
			order_index = i + 1
	_row(card, "Öncelik sırası", "%d / %d%s" % [order_index, game.jobs.size(), " · askıda" if bool(job.get("suspended", false)) else ""], RED if bool(job.get("suspended", false)) else MUTED, 13)
	var priority_row := HBoxContainer.new()
	priority_row.add_theme_constant_override("separation", 8)
	var up_button := _button("▲ Öne al", func() -> void:
		game.move_job(int(job["id"]), -1)
		_render_keep_scroll())
	up_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	up_button.disabled = order_index <= 1
	priority_row.add_child(up_button)
	var suspend_button := _button("▶ Devam ettir" if bool(job.get("suspended", false)) else "⏸ Askıya al", func() -> void:
		var result: String = game.set_job_suspended(int(job["id"]), not bool(job.get("suspended", false)))
		if result != "":
			_say(result)
		_render_keep_scroll())
	suspend_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	priority_row.add_child(suspend_button)
	card.add_child(priority_row)
	var postpone_reason: String = game.postpone_block_reason(job["id"])
	if postpone_reason == "":
		card.add_child(_button("Mail at: teslimi ötele", _postpone_popup.bind(job["id"])))
	var reason: String = game.abandon_block_reason(job["id"])
	card.add_child(_button("İşi bırak · ceza %s" % Data.usd(game.abandon_penalty(job)) if reason == "" else reason, _ask_abandon.bind(job["id"]), false, reason != ""))

# Asks the customer to move the delivery date (IDEA-023); the answer comes as mail a few seconds later.
func _postpone_popup(job_id: int) -> void:
	var job: Dictionary = game.job_by_id(job_id)
	if job.is_empty():
		return
	var months_box := [1]
	var discount_box := [0]
	_filter_popup("Teslimi ötele", func(box: VBoxContainer) -> void:
		box.add_child(_label("%s · mevcut teslim: %s" % [job["title"], Data.month_label(int(job["due_month"]))], 13, MUTED))
		box.add_child(_label("Müşteri yanıtı mail olarak gelir. Aciliyet, teslim skorun, istenen süre, teslime kalan zaman ve önceki taleplerin etkiler; ilk talep ücretsizdir, sonrakilerin kabul ihtimali düşer. Fiyat indirimi önermek ihtimali artırır (acil müşteri için pek değil).", 12, MUTED))
		_slider_row(box, "Süre", 1, game.POSTPONE_MAX_MONTHS, 1, func(v: int, shown: Label) -> void:
			months_box[0] = v
			shown.text = "%d ay" % v)
		_slider_row(box, "İndirim", 0, 10, 0, func(v: int, shown: Label) -> void:
			discount_box[0] = v
			shown.text = "%%%d" % v)
		box.add_child(_button("Mail gönder", func() -> void:
			var result: Dictionary = game.request_postpone(job_id, int(months_box[0]), int(discount_box[0]))
			_close_overlay()
			_say("Talebiniz iletildi; müşteri birkaç saniye içinde yanıt verecek." if bool(result["ok"]) else String(result["reason"]))
			_render(), true)))

# Tolerance slack: the drawing is looser than the machine, so the boss trades the room for speed or for scrap.
func _bonus_popup(job_id: int) -> void:
	var job: Dictionary = game.job_by_id(job_id)
	if job.is_empty():
		return
	game.choose_bonus(job_id, String(job.get("bonus", "")))   # asked once; the choice stays editable on the job card
	_filter_popup("Tolerans payı", func(box: VBoxContainer) -> void:
		box.add_child(_label("%s · müşterinin istediği tolerans, makinenin hassasiyetinden geniş. Bu payı kullanabilirsin:" % job["title"], 13, MUTED))
		for req in job["reqs"]:
			var slack: float = game.req_slack(job, req)
			if slack >= Data.SLACK_MIN:
				_row(box, "%s %s · %s" % [Data.LEVELS[int(req["level"])], req["kind"], Data.tolerance_text(float(req["tolerance"]))],
					"pay %%%d" % int(roundf(slack * 100.0)), GOLD, 13)
		var mode: String = String(job.get("bonus", ""))
		_flow_chips(box, "Payı nasıl kullanalım?", [
			{"id": "", "title": "Kullanma"},
			{"id": "speed", "title": "Hızlı işle (en çok +%%%d)" % int(Data.SLACK_SPEED * 100.0)},
			{"id": "scrap", "title": "Hurdayı azalt (en çok -%%%d)" % int(Data.SLACK_SCRAP * 100.0)}], mode,
			func(id: String) -> void:
				game.choose_bonus(job_id, id)
				_bonus_popup(job_id))
		var line := "Seçim yok: işlem hızı ve hurda normal."
		if mode == "speed":
			line = "Hızlı işlenir; hurda oranı değişmez. İş daha erken biter."
		elif mode == "scrap":
			line = "Hurda azalır; işlem hızı değişmez. Hurda gideri düşer."
		box.add_child(_label(line, 12, GREEN))
		box.add_child(_label("Seçimi İşler ekranındaki iş kartından sonra da değiştirebilirsin.", 11, MUTED)))

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
		box.add_child(_label("%s kg/parça · yaklaşık %s kg %s çelik %s" % [str(req["weight"]).trim_suffix(".0").replace(".", ","), str(int(roundf(float(req["tons"]) * 1000.0))), "nitelikli" if int(req["steel"]) > 1 else "standart", "(müşteri verir)" if bool(offer.get("fason", false)) else "gerekir"], 11, MUTED))
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

func _offer_photo(offer: Dictionary, height := 170) -> Control:
	var photo := Art.pick_image("res://art/jobs", int(offer["id"]))
	if photo == null:
		return null
	return _rounded_photo(photo, Vector2(0, height), 14)

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

# ------------------------------------------------------------------ narrow listing rows

# Small bordered value tile for narrow rows: icon and value only.
func _mini_tile(icon_name: String, value: String, framed := true) -> Control:
	var tile := PanelContainer.new()
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.add_theme_stylebox_override("panel", _box(Color(0, 0, 0, 0), TEXT, 10, 1) if framed else StyleBoxEmpty.new())
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_BEGIN if not framed else BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 6)
	tile.add_child(_margin(row, 6 if framed else 0, 5 if framed else 2))
	var icon := _icon_rect(icon_name, 22 if framed else 20)
	if icon != null:
		if icon_name.begins_with("tezgah_"):
			icon.modulate = CYAN   # the white line icons take the technical cyan
		row.add_child(icon)
	row.add_child(_label(value, 12, TEXT, false))
	return tile

# Photo (cropped around its centre), title block and the right-hand value of a narrow row.
func _row_head(photo: Texture2D, title: String, sub: String, right_bbcode: String) -> HBoxContainer:
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	if photo != null:
		head.add_child(_rounded_photo(photo, Vector2(104, 84), 12))
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	info.add_child(_label(title, 16, TEXT))
	if sub.contains("["):
		var sub_rich := _rich(sub, _fs(11))
		sub_rich.add_theme_color_override("default_color", MUTED)
		sub_rich.fit_content = true
		info.add_child(sub_rich)
	else:
		info.add_child(_label(sub, 11, MUTED))
	head.add_child(info)
	if right_bbcode != "":
		var right := _rich(right_bbcode, 13)
		right.fit_content = true
		right.custom_minimum_size = Vector2(120, 0)
		head.add_child(right)
	return head

const KIND_COLOR := {"Torna": Color("#6ec8eb"), "Freze": Color("#6ee1be"), "Taşlama": Color("#be9ff0"), "Dövme": Color("#f0a064")}

# The machine kinds a job needs, one icon each (art/ui/<kind>_icon.png). Collapsed rows show the icons only; open
# ones add the kind's name. A kind the plant has is drawn in its own colour, a missing one in red (icon and text).
func _need_icons(offer: Dictionary, with_names: bool, icon_px := 38) -> Control:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 14)
	flow.add_theme_constant_override("v_separation", 6)
	var kinds: Array = []
	for req in offer["reqs"]:
		if not kinds.has(req["kind"]):
			kinds.append(req["kind"])
	for kind in kinds:
		var have := true
		var level := 1
		for req in offer["reqs"]:
			if req["kind"] == kind:
				level = maxi(level, int(req["level"]))
				if not game.owns(req):
					have = false
		var color: Color = KIND_COLOR.get(kind, TEXT) if have else RED
		var cell := HBoxContainer.new()
		cell.add_theme_constant_override("separation", 6)
		var icon := _icon_rect(Art.slug(kind) + "_icon", icon_px)
		if icon != null:
			icon.modulate = color
			cell.add_child(icon)
		if with_names or icon == null:
			cell.add_child(_label(("%s %s" % [Data.LEVELS[level], kind]) if not have else kind, 13, color, false))
		flow.add_child(cell)
	return flow

func _tap_panel(box: VBoxContainer, on_tap: Callable) -> void:
	_panel_of(box).gui_input.connect(func(event: InputEvent) -> void:
		if _is_tap(event):
			on_tap.call())

# Keeps the scroll position when a row opens or closes.
func _render_keep_scroll() -> void:
	var keep: int = scroll_view.scroll_vertical
	_render()
	await get_tree().process_frame
	scroll_view.scroll_vertical = keep

# Popup of chips that wrap onto several lines (the filters no longer take space on the page).
func _filter_popup(title: String, build: Callable) -> void:
	_close_overlay()
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.66)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 0)
	panel.add_theme_stylebox_override("panel", _box(PANEL, GREEN, 14, 2))
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(_margin(box, 18, 16))
	box.add_child(_label(title, 20, TEXT))
	build.call(box)
	box.add_child(_button("Tamam", func() -> void:
		_close_overlay()
		_render(), true))

# One chip per filter group (with the current choice in its caption); a tap opens that group's options below.
var filter_open := ""

func _filter_groups(box: VBoxContainer, groups: Array) -> void:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 8)
	flow.add_theme_constant_override("v_separation", 8)
	for group in groups:
		var active: bool = filter_open == group["id"]
		var button := Button.new()
		button.text = "%s: %s" % [group["title"], group["summary"]]
		button.custom_minimum_size = Vector2(0, 38)
		for style_name in ["normal", "hover", "pressed"]:
			var chip := _box(Color(GREEN.r, GREEN.g, GREEN.b, 0.22) if active else PANEL_ALT, GREEN if active else BORDER, 19, 1)
			chip.content_margin_left = 14
			chip.content_margin_right = 14
			button.add_theme_stylebox_override(style_name, chip)
		button.add_theme_color_override("font_color", GREEN if active else TEXT)
		button.add_theme_font_size_override("font_size", _fs(14))
		button.pressed.connect(func() -> void:
			filter_open = "" if active else String(group["id"])
			group["reopen"].call())
		_juice(button)
		flow.add_child(button)
	box.add_child(flow)
	for group in groups:
		if filter_open == group["id"]:
			group["build"].call(box)

func _flow_chips(parent: Control, caption: String, options: Array, current, callback: Callable, accents := {}) -> void:
	if caption != "":
		parent.add_child(_label(caption, 12, MUTED))
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 8)
	flow.add_theme_constant_override("v_separation", 8)
	for option in options:
		var button := Button.new()
		button.text = option["title"]
		button.custom_minimum_size = Vector2(0, 38)
		var active: bool = (current.has(option["id"]) if current is Array else option["id"] == current)
		var accent: Color = accents.get(option["id"], GREEN)
		for style_name in ["normal", "hover", "pressed"]:
			var chip := _box(Color(accent.r, accent.g, accent.b, 0.22) if active else PANEL_ALT, accent if active else BORDER, 19, 1)
			chip.content_margin_left = 14
			chip.content_margin_right = 14
			button.add_theme_stylebox_override(style_name, chip)
		button.add_theme_color_override("font_color", accent if active else TEXT)
		button.add_theme_font_size_override("font_size", _fs(14))
		button.pressed.connect(callback.bind(option["id"]))
		_juice(button)
		flow.add_child(button)
	parent.add_child(flow)

# One slim line above a list: opens the filter popup, shows how many filters are on.
func _filter_bar(active_count: int, chips: Array, on_open: Callable, on_clear: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var open := _button("Filtre", on_open, false)
	open.custom_minimum_size = Vector2(96, 38)
	if active_count > 0:
		# active filters: a green frame only (a filled button grabs too much attention)
		for style_name in ["normal", "hover", "pressed"]:
			open.add_theme_stylebox_override(style_name, _box(PANEL_ALT if style_name != "normal" else BG, GREEN, 10, 1))
		for color_name in ["font_color", "font_hover_color", "font_pressed_color", "icon_normal_color", "icon_hover_color", "icon_pressed_color"]:
			open.add_theme_color_override(color_name, TEXT)
	var filter_icon := Art.find("res://art/ui/filtre")
	if filter_icon != null:
		open.icon = filter_icon
		open.expand_icon = true
		open.add_theme_constant_override("icon_max_width", 18)
	row.add_child(open)
	# the active filters sit next to the icon as small chips: "Tür: Torna", "Seviye: CNC"
	var flow := HFlowContainer.new()
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow.add_theme_constant_override("h_separation", 6)
	flow.add_theme_constant_override("v_separation", 6)
	if chips.is_empty():
		flow.add_child(_label("Filtre yok", 12, FAINT, false))
	for text in chips:
		var chip := PanelContainer.new()
		chip.add_theme_stylebox_override("panel", _box(GREEN_DIM, GREEN, 14, 1))
		chip.add_child(_margin(_label(String(text), 12, GREEN_HI, false), 10, 3))
		flow.add_child(chip)
	row.add_child(flow)
	if active_count > 0:
		var clear := _button("Temizle", on_clear)
		clear.custom_minimum_size = Vector2(80, 38)
		row.add_child(clear)
	content.add_child(row)

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
	if sub != "isler":
		_chips(content, [{"id": "tezgah", "title": "Tezgah"}, {"id": "ekipman", "title": "Ekipman"}], sub, pick_sub)
	match sub:
		"tezgah": _machines_board()
		"ekipman": _page_equipment()
		_: _jobs_board()

func _jobs_board() -> void:
	if game.phase != "offers":
		content.add_child(_label("Rapor açık: teklif ay başında (rapordan önce) verilir.", 12, GOLD))
	var sort_names := {"yeni": "ilan sırası", "hassas": "en hassas önce", "genis": "en geniş tolerans önce"}
	var job_chips: Array = []
	if not job_filters.is_empty():
		job_chips.append("Tezgah: " + ", ".join(job_filters.map(func(f): return "elimde olan" if f == "elimde" else f)))
	if job_sort != "yeni":
		job_chips.append("Sıra: " + sort_names[job_sort])
	_filter_bar(job_filters.size(), job_chips,
		_open_job_filters, func() -> void:
			job_filters.clear()
			_render())
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

func _open_job_filters() -> void:
	_filter_popup("Filtre ve sıralama", func(box: VBoxContainer) -> void:
		var kind_options: Array = []
		for kind in Data.TYPES:
			kind_options.append({"id": kind, "title": kind})
		kind_options.append({"id": "elimde", "title": "Elimdeki tezgaha göre"})
		var sort_names := {"yeni": "ilan sırası", "hassas": "en hassas", "genis": "en geniş tolerans"}
		_filter_groups(box, [
			{"id": "tezgah", "title": "Tezgah", "summary": ", ".join(job_filters) if not job_filters.is_empty() else "hepsi", "reopen": _open_job_filters,
				"build": func(b: VBoxContainer) -> void:
					_flow_chips(b, "Birden fazla seçilirse hepsini içeren işler gelir", kind_options, job_filters, func(id: String) -> void:
						if job_filters.has(id):
							job_filters.erase(id)
						else:
							job_filters.append(id)
						_open_job_filters(), {"elimde": GREEN})},
			{"id": "sira", "title": "Sıralama", "summary": sort_names[job_sort], "reopen": _open_job_filters,
				"build": func(b: VBoxContainer) -> void:
					_flow_chips(b, "", [{"id": "yeni", "title": "İlan sırası"}, {"id": "hassas", "title": "En hassas"}, {"id": "genis", "title": "En geniş tolerans"}], job_sort, func(id: String) -> void:
						job_sort = id
						_open_job_filters())}]))

func _offer_tolerance(offer: Dictionary) -> float:
	var tol := 99.0
	for req in offer["reqs"]:
		tol = minf(tol, float(req.get("tolerance", 0.1)))
	return tol

# ------------------------------------------------------------------ Teklif ekranları (teklif_ekrani.pptx)

func _offer_stats(offer: Dictionary) -> Dictionary:
	var parts := 0
	var difficulty := 0.0
	var load_total := 0.0
	var kg := 0
	for req in offer["reqs"]:
		parts = maxi(parts, int(req["parts"]))
		load_total += float(req["workload"])
		difficulty = maxf(difficulty, float(req["difficulty"]))
		kg += int(roundf(float(req["tons"]) * 1000.0))
	return {"parts": parts, "difficulty": difficulty, "load": load_total, "kg": kg,
		"parts_text": "%s Ad" % Data.usd(float(parts) / 1000.0).trim_prefix("$"),
		"size_text": "%s Ad  x  %s" % [Data.usd(float(parts) / 1000.0).trim_prefix("$"), Data.mu_text(difficulty).replace("ω ", "ω ")]}

# The customer block of a listing: logo-less portrait and four lines of text (company, name, e-mail, phone).
func _contact_block(c: DesignCanvas, offer: Dictionary, x: float, y: float) -> void:
	var info: Dictionary = Data.contact_info(offer)
	var portrait: Texture2D = Art.find("res://art/contacts/" + String(info["id"])) if String(info["id"]) != "" else null
	if portrait != null:
		c.picture(portrait, x, y, 49, 50, Color.WHITE, true, 10.0)
	c.text(x + 49, y, 140, "%s\n%s\n%s\n%s" % [offer["customer"], Data.contact_of(offer), Data.contact_email(offer), Data.contact_phone(offer)], 9.0, DesignCanvas.MUTED, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 51.0)

func _offer_card(offer: Dictionary, reason: String) -> void:
	var doable: bool = game.fit_block_reason(offer["id"]) == "" and game.gate_block_reason(int(offer["id"])) == ""
	var stats: Dictionary = _offer_stats(offer)
	var c := DesignCanvas.new()
	c.setup(Vector2(9, 9), 437.0, 508.0, 216.0, 12.0)
	content.add_child(c)
	var photo := Art.pick_image("res://art/jobs", int(offer["id"]))
	c.picture(photo, 17, 15, 73, 60, Color.WHITE, true, 8.0)
	c.text(98, 15, 250, String(offer["title"]), 16.0, DesignCanvas.TEXT, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 27.0)
	c.text(340, 19, 100, "İş No: %d" % _job_no(offer), 11.0, DesignCanvas.AMBER, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 21.0)
	c.text(250, 43, 190, String(stats["size_text"]), 16.0, DesignCanvas.GREEN, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 27.0)
	if bool(offer.get("continuous", false)):
		c.text(98, 43, 150, "Sürekli İş · %d ay" % Data.CONTINUOUS_MONTHS, 10.5, DesignCanvas.AMBER, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 21.0)
	c.text(318, 104, 70, "Tolerans", 10.5, DesignCanvas.MUTED, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 21.0)
	c.text(384, 104, 56, Data.tolerance_text(_offer_tolerance(offer)), 11.0, DesignCanvas.CYAN, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 21.0)
	c.text(318, 128, 70, "Teslimat", 10.5, DesignCanvas.MUTED, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 21.0)
	c.text(384, 128, 56, "%d Ay" % int(offer["months"]), 11.0, DesignCanvas.CYAN, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 21.0)
	var kinds: Array = []
	for req in offer["reqs"]:
		if not kinds.has(req["kind"]):
			kinds.append(req["kind"])
	for i in kinds.size():
		var have := true
		for req in offer["reqs"]:
			if req["kind"] == kinds[i] and not game.owns(req):
				have = false
		c.icon(Art.slug(kinds[i]) + "_icon", 17.0 + 40.0 * i, 115, 34, 32, DesignCanvas.TEXT if have else DesignCanvas.RED)
	c.line(23, 158, 407)
	_contact_block(c, offer, 17, 168)
	c.button(346, 186, 91, 30, "İncele", func() -> void: _open_detail("quote", str(offer["id"])))

func _gold_italic(text: String, size := 13) -> Label:
	var label := _label(text, size, GOLD)
	var font := SystemFont.new()
	font.font_italic = true
	label.add_theme_font_override("font", font)
	return label

# Fills the quote calendar from the engine: one lane per machine kind the job needs.
func _update_gantt(gantt: Control, offer: Dictionary, months: int) -> void:
	var plan: Dictionary = game.plan_schedule(offer, months)
	var lanes: Array = []
	var horizon := float(plan["window_end"]) + 30.0
	for kind in plan["kinds"]:
		var segments: Array = plan["kinds"][kind]
		for segment in segments:
			horizon = maxf(horizon, float(segment["end"]) + 15.0)
		lanes.append({"kind": kind, "icon": Art.find("res://art/ui/" + Art.slug(kind) + "_icon"), "color": KIND_COLOR.get(kind, TEXT), "segments": segments, "window_end": plan["window_end"]})
	gantt.set_data(lanes, minf(horizon, 420.0), mini(int(plan["late_days"]), 999))

func _quote_row(parent: Control, left: String, right: String, color := GOLD, size := 14) -> void:
	var row := HBoxContainer.new()
	var name_label := _gold_italic(left, size) if color == GOLD else _label(left, size, MUTED, false)
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
	quote_progress = true
	quote_start_offset = 0
	quote_buffer = 0
	quote_adv = 30
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

# Delivery forecast for the quote: the engine's own queue projection (accepted jobs first, material arrival,
# the offer's start delay, machines in transit), plus the case where the supplier is a month late.
# Why the forecast looks the way it does: real monthly output (not the 24-hour theoretical figure), the material wait
# and the load of this job.
func _capacity_note(offer: Dictionary, months_offered: int) -> String:
	var lead: int = int(game.material_quote(offer, game.default_supplier)["lead"])
	var parts: Array = []
	for req in offer["reqs"]:
		parts.append("%s: iş yükü %s ω, net kapasite ~%s ω/ay" % [req["kind"], Data.usd(float(req["workload"]) / 1000.0).trim_prefix("$"), Data.usd(game.requirement_capacity(req) / 1000.0).trim_prefix("$")])
	return "%s. Hammadde %d ay sonra gelir; üretime %d ay kalır. Net kapasite, teorik kapasitenin vardiya payı, performans, hurda ve sorun kayıpları düşülmüş halidir (1 vardiya ≈ teorik / 3)." % [" · ".join(parts), lead, maxi(0, months_offered - lead)]

func _delivery_check(offer: Dictionary, months_offered: int) -> Array:
	var plan: Dictionary = game.quote_projection(offer, months_offered)
	var finish: int = int(plan["finish"])
	var due: int = int(plan["due"])
	if finish == 0:
		return ["Mevcut tezgahlarla 12 ay içinde bitmiyor (makine, ekipman ya da hammadde eksik olabilir).", RED]
	var days_late: int = int(plan["late_days"])
	var when := "Tahmini bitiş: %s. İstenen teslim: %s." % [Data.date_text(finish, int(plan["finish_day"])), Data.month_end_text(due)]
	if days_late > 0:
		var drop := 12.0 * float(days_late) / float(Data.MONTH_DAYS) if days_late < Data.MONTH_DAYS else 12.0
		return [when + " %d gün geç kalırsın; teslim skorun yaklaşık %s puan düşer (gün başına ~%s)." % [days_late, str(snappedf(drop, 0.1)).replace(".", ","), str(snappedf(12.0 / float(Data.MONTH_DAYS), 0.01)).replace(".", ",")], GOLD if days_late <= 7 else RED]
	var risk: Dictionary = game.quote_projection(offer, months_offered, true)
	if float(plan["delay_chance"]) > 0.0 and int(risk["late_days"]) > 0:
		return [when + " Tedarikçi hammaddeyi geciktirirse (%%%d ihtimal) iş %s tarihine kayar, %d gün geç kalırsın." % [int(roundf(float(plan["delay_chance"]) * 100.0)), Data.date_text(int(risk["finish"]), int(risk["finish_day"])), int(risk["late_days"])], GOLD]
	return [when + " Zamanında yetişir.", GREEN]

# Opens another page from the quote screen and remembers where to come back to (the quote with its settings).
func _goto_with_return(target_page: String, sub_key: String, sub_value: String) -> void:
	return_to = {"page": page, "detail": detail, "arg": detail_arg, "ilanlar": subtab["ilanlar"], "label": "Teklife dön"}
	detail = ""
	page = target_page
	subtab[sub_key] = sub_value
	_render()

func _return_bar() -> void:
	var row := HBoxContainer.new()
	var back := _button("‹ %s" % String(return_to["label"]), func() -> void:
		var saved: Dictionary = return_to
		return_to = {}
		page = String(saved["page"])
		detail = String(saved["detail"])
		detail_arg = String(saved["arg"])
		subtab["ilanlar"] = String(saved["ilanlar"])
		_render())
	back.custom_minimum_size = Vector2(190, 46)
	row.add_child(back)
	content.add_child(row)

func _check_icon(c: DesignCanvas, on: bool, color: Color) -> Texture2D:
	var k: float = c.scale_k
	var side := int(roundf(14.0 * k))
	return c.shape_texture(side, color if on else DesignCanvas.CARD, color if on else DesignCanvas.BORDER, 3.0 * k)

func _design_check(c: DesignCanvas, x: float, y: float, caption: String, checked: bool, color: Color, enabled: bool, on_toggle := Callable(), text_color := DesignCanvas.MUTED) -> void:
	var on_icon: Texture2D = _check_icon(c, true, color)
	var off_icon: Texture2D = _check_icon(c, false, color if color != DesignCanvas.GREEN else DesignCanvas.BORDER)
	if enabled:
		var toggle := Button.new()
		toggle.flat = true
		toggle.toggle_mode = true
		toggle.button_pressed = checked
		toggle.icon = on_icon if checked else off_icon
		toggle.expand_icon = false
		toggle.focus_mode = Control.FOCUS_NONE
		toggle.toggled.connect(func(on: bool) -> void:
			toggle.icon = on_icon if on else off_icon
			if on_toggle.is_valid():
				on_toggle.call(on))
		c.place(toggle, x - 4.0, y - 4.0, 22, 22)
	else:
		var mark := TextureRect.new()
		mark.texture = on_icon if checked else off_icon
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.place(mark, x, y, 14, 14)
	c.text(x + 19.0, y - 3.0, 150, caption, 9.0, text_color, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 18.0)

func _design_slider(c: DesignCanvas, x: float, y: float, caption: String, low: int, high: int, value: int, unit: String, on_change: Callable) -> void:
	c.text(x, y - 3.0, 70, caption, 11.0, DesignCanvas.TEXT, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 21.0)
	var shown := c.text(x + 230.0, y - 3.0, 43, "", 11.0, DesignCanvas.TEXT, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 21.0)
	var k: float = c.scale_k
	var slider := HSlider.new()
	slider.min_value = low
	slider.max_value = high
	slider.step = 1
	slider.value = value
	var track := c.style(DesignCanvas.INNER, 7.0, DesignCanvas.INNER_BORDER)
	track.content_margin_top = 6.0 * k
	track.content_margin_bottom = 6.0 * k
	var filled := c.style(DesignCanvas.MUTED, 7.0, DesignCanvas.MUTED, 0)
	filled.content_margin_top = 6.0 * k
	filled.content_margin_bottom = 6.0 * k
	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", filled)
	slider.add_theme_stylebox_override("grabber_area_highlight", filled)
	var knob: Texture2D = c.shape_texture(int(roundf(21.0 * k)), DesignCanvas.TEXT, DesignCanvas.TEXT, 10.5 * k)
	slider.add_theme_icon_override("grabber", knob)
	slider.add_theme_icon_override("grabber_highlight", knob)
	slider.add_theme_icon_override("grabber_disabled", knob)
	c.place(slider, x + 59.0, y - 4.0, 170, 22)
	slider.value_changed.connect(func(v: float) -> void:
		shown.text = unit % int(v)
		on_change.call(int(v)))
	shown.text = unit % value
	on_change.call(value)

func _detail_quote() -> void:
	var offer: Dictionary = game.offer_by_id(int(detail_arg))
	if offer.is_empty():
		content.add_child(_label("Bu ilan artık yok.", 14, MUTED))
		return
	if quote_months == 0:
		_open_quote(int(detail_arg))
	game.quote_progress = quote_progress
	game.quote_start_offset = quote_start_offset
	var wanted: int = int(offer["months"])
	var estimate: Dictionary = game.cost_estimate(offer, quote_edit)
	var lines: Array = estimate["lines"]
	var total: float = float(estimate["total"])
	var stats: Dictionary = _offer_stats(offer)
	var fason: bool = bool(offer.get("fason", false))
	var grade: String = Data.STEEL_GRADE[int(offer["reqs"][0]["steel"])]
	# Positions are the design's own (card top-left = 9, 234); the title row adds 32 points under the picture.
	var shift := 32.0
	var c := DesignCanvas.new()
	c.setup(Vector2(9, 234), 437.0, 508.0, 1100.0, 14.0)
	content.add_child(c)
	c.picture(Art.pick_image("res://art/jobs", int(offer["id"])), 17, 243, 419, 158, Color.WHITE, true, 12.0)
	c.text(17, 411, 419, String(offer["title"]), 16.0, DesignCanvas.TEXT, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 22.0)
	_contact_block(c, offer, 17, 411.0 + shift)
	c.text(340, 412.0 + shift, 96, "İş No: %d" % _job_no(offer), 11.0, DesignCanvas.AMBER, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 21.0)
	c.text(250, 437.0 + shift, 186, String(stats["size_text"]), 16.0, DesignCanvas.GREEN, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 27.0)
	if bool(offer.get("continuous", false)):
		c.text(250, 463.0 + shift, 186, "Sürekli İş · %d ay" % Data.CONTINUOUS_MONTHS, 10.5, DesignCanvas.AMBER, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 21.0)
	c.line(23, 472.0 + shift, 407)
	var y0 := 490.0 + shift
	c.text(17, y0, 120, "Parça Sayısı", 12.0, DesignCanvas.MUTED)
	c.text(132, y0, 65, String(stats["parts_text"]), 12.0, DesignCanvas.GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	c.text(257, y0, 100, "Hammadde", 12.0, DesignCanvas.MUTED)
	c.text(357, y0, 80, "müşteri verir" if fason else grade, 12.0, DesignCanvas.MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
	c.text(17, y0 + 36.0, 120, "Parça İş Gücü (ω)", 12.0, DesignCanvas.MUTED)
	c.text(132, y0 + 36.0, 65, str(stats["difficulty"]).trim_suffix(".0").replace(".", ","), 12.0, DesignCanvas.TEXT, HORIZONTAL_ALIGNMENT_RIGHT)
	c.text(257, y0 + 36.0, 100, "Tolerans (mm)", 12.0, DesignCanvas.MUTED)
	c.text(357, y0 + 36.0, 80, Data.tolerance_text(_offer_tolerance(offer)).trim_suffix(" mm"), 12.0, DesignCanvas.MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
	c.text(17, y0 + 72.0, 120, "İstenen Teslim", 12.0, DesignCanvas.MUTED)
	c.text(132, y0 + 72.0, 65, "%d Ay" % wanted, 12.0, DesignCanvas.TEXT, HORIZONTAL_ALIGNMENT_RIGHT)
	c.line(23, 602.0 + shift, 407)
	var y := 616.0 + shift
	c.text(17, y, 200, "Öngörülen Veriler", 12.0, DesignCanvas.BLUE)
	y += 30.0
	if not fason:
		var supplier_now: Dictionary = Data.supplier_by_id(game.default_supplier)
		c.text(17, y, 200, "Hammadde Tedarikçisi", 12.0, DesignCanvas.TEXT)
		c.text(250, y, 170, String(supplier_now["name"]), 12.0, DesignCanvas.TEXT, HORIZONTAL_ALIGNMENT_RIGHT)
		c.chevron(425, y + 4.0)
		c.tap(17, y - 4.0, 420, 30, func() -> void: _goto_supplier_pick(offer))
		y += 27.0
		c.text(17, y, 200, "Hammadde Gideri", 12.0, DesignCanvas.AMBER)
		c.text(375, y, 62, Data.usd(float(estimate["material"])), 12.0, DesignCanvas.AMBER, HORIZONTAL_ALIGNMENT_RIGHT)
		y += 20.0
		c.text(28, y, 250, "%s kg x %s = %s kg" % [str(offer["reqs"][0]["weight"]).trim_suffix(".0").replace(".", ","), String(stats["parts_text"]), Data.usd(float(stats["kg"]) / 1000.0).trim_prefix("$")], 12.0, DesignCanvas.AMBER)
		y += 23.0
	var cost_rows := [["Hurda Gideri", fason_free(fason, _sum_lines(lines, "scrap"))],
		["Enerji, Personel, Sarf Malzeme", _sum_lines(lines, "energy") + _sum_lines(lines, "personnel") + _sum_lines(lines, "consumables")],
		["Genel Gider & Amortisman", _sum_lines(lines, "overhead") + _sum_lines(lines, "amortization")]]
	for row in cost_rows:
		c.text(17, y, 250, String(row[0]), 12.0, DesignCanvas.AMBER)
		c.text(355, y, 82, Data.usd(float(row[1])), 12.0, DesignCanvas.AMBER, HORIZONTAL_ALIGNMENT_RIGHT)
		y += 27.0
	c.text(17, y, 200, "Toplam Gider", 12.0, DesignCanvas.RED)
	c.text(355, y, 82, Data.usd(total), 12.0, DesignCanvas.RED, HORIZONTAL_ALIGNMENT_RIGHT)
	var line_y := y + 38.0
	c.line(23, line_y, 407)
	# shifts (information only; the arrow opens the factory's shift page)
	for n in [1, 2, 3]:
		var col_x: float = [19.0, 165.0, 317.0][n - 1]
		_design_check(c, col_x, line_y + 19.0, "Vardiya %d" % n, game.plan_shifts >= n, DesignCanvas.GREEN, false)
		_design_check(c, col_x, line_y + 44.0, "Mesai + 4 sa", bool(game.plan_ot[n - 1]), DesignCanvas.GREEN, false)
	c.chevron(425, line_y + 35.0, func() -> void: _goto_with_return("fabrika", "fabrika", "vardiya"))
	# calendar
	var gantt = PlanGantt.new()
	var gantt_top := line_y + 78.0
	var gantt_h := 64.0
	c.box(19, gantt_top, 417, gantt_h, DesignCanvas.CARD, 8.0, DesignCanvas.BORDER)
	c.place(gantt, 22, gantt_top + 2.0, 395, gantt_h - 4.0)
	c.chevron(425, gantt_top + gantt_h * 0.5 - 7.0, func() -> void: _goto_with_return("fabrika", "fabrika", "kapasite"))
	var after_gantt := gantt_top + gantt_h + 19.0
	c.line(23, after_gantt, 407)
	var sliders_top := after_gantt + 23.0
	var price_label := c.text(350, sliders_top + 147.0, 87, "", 16.0, DesignCanvas.TEXT, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 27.0)
	var cost_label := c.text(375, sliders_top + 175.0, 62, Data.usd(total), 12.0, DesignCanvas.RED, HORIZONTAL_ALIGNMENT_RIGHT)
	var profit_label := c.text(375, sliders_top + 199.0, 62, "", 12.0, DesignCanvas.GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	var gauge_box := c.box(305, sliders_top - 1.0, 132, 98, DesignCanvas.INNER, 9.0, DesignCanvas.INNER_BORDER)
	c.text(313, sliders_top, 120, "İşi Alma İhtimali", 11.0, DesignCanvas.TEXT, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 21.0)
	var gauge: Control = GaugeScript.new()
	c.place(gauge, 312, sliders_top + 22.0, 118, 70)
	var refresh := func() -> void:
		quote_price = ceilf(total * (1.0 + quote_margin) * 100.0) / 100.0
		price_label.text = Data.usd(quote_price)
		profit_label.text = Data.usd(quote_price - total)
		game.quote_progress = quote_progress
		game.quote_start_offset = quote_start_offset
		gauge.set_value(float(game.accept_probability(offer, quote_price, quote_adv, quote_months)["accept"]))
		_update_gantt(gantt, offer, quote_months)
	_design_slider(c, 19, sliders_top, "Peşinat", 0, 100, quote_adv, "%% %d", func(v: int) -> void:
		quote_adv = v
		if is_instance_valid(gauge): refresh.call())
	_design_slider(c, 19, sliders_top + 38.0, "Teslimat", 1, wanted + 2, clampi(quote_months, 1, wanted + 2), "%d Ay", func(v: int) -> void:
		quote_months = v
		if is_instance_valid(gauge): refresh.call())
	_design_slider(c, 19, sliders_top + 77.0, "Kar Marjı", 0, 100, int(roundf(quote_margin * 100.0)), "%% %d", func(v: int) -> void:
		quote_margin = float(v) / 100.0
		if is_instance_valid(gauge): refresh.call())
	gantt.drag_started.connect(func() -> void: drag_base = quote_start_offset)
	gantt.start_dragged.connect(func(delta: int) -> void:
		quote_start_offset = maxi(0, drag_base + delta)
		refresh.call())
	gantt.lane_tapped.connect(func(kind: String) -> void: _plan_popup(offer, kind))
	_design_check(c, 27, sliders_top + 117.0, "Her ay ödeme yapılsın", quote_progress, DesignCanvas.AMBER, true, func(on: bool) -> void:
		quote_progress = on
		refresh.call(), DesignCanvas.AMBER)
	c.text(177, sliders_top + 147.0, 100, "Teklif Ver".replace("Teklif Ver", "Teklif Tutarı"), 12.0, DesignCanvas.TEXT)
	c.text(177, sliders_top + 175.0, 190, "Öngörülen Giderler Toplamı", 12.0, DesignCanvas.RED)
	c.text(177, sliders_top + 199.0, 190, "Öngörülen Kar Tutarı", 12.0, DesignCanvas.GREEN)
	refresh.call()
	var reason: String = game.quote_block_reason(int(detail_arg), maxf(quote_price, 0.001))
	var send := c.button(346, sliders_top + 234.0, 91, 30, "Teklif Ver", func() -> void:
		if reason == "":
			_ask_send_quote(int(detail_arg))
		else:
			_say(reason)
			_render(), 12.0, reason == "")
	send.disabled = false
	if reason != "":
		c.text(19, sliders_top + 234.0, 320, reason, 9.0, DesignCanvas.RED, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 30.0).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c.set_height(sliders_top + 234.0 + 30.0 + 12.0 - 234.0 + 0.0)
	gauge_box.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fason_free(fason: bool, value: float) -> float:
	return 0.0 if fason else value

func _goto_supplier_pick(offer: Dictionary) -> void:
	_open_detail("supplier_pick", str(offer["id"]))


# The plan window of one machine kind: workload, the daily capacity of today's settings, the computed duration, the start day
# and a safety margin that stretches the delivery time offered (IDEA-023).
func _plan_popup(offer: Dictionary, kind: String) -> void:
	_close_overlay()
	_auto_pause()
	var plan: Dictionary = game.plan_schedule(offer, quote_months)
	var segment := {}
	for item in plan["kinds"].get(kind, []):
		if bool(item.get("extra", false)):
			segment = item
	if segment.is_empty():
		return
	var load_total := 0.0
	var per_day := 0.0
	for req in offer["reqs"]:
		if req["kind"] == kind:
			load_total += float(req["workload"])
			per_day += game.requirement_capacity(req) / float(Data.MONTH_DAYS)
	var work_days := int(ceilf(load_total / maxf(0.001, per_day)))
	var start_day_n := int(segment["start"])
	var end_day_n := int(segment["end"])
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
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	panel.add_child(_margin(column, 20, 18))
	column.add_child(_label("Plan · %s" % kind, 20, TEXT))
	_row(column, "İş yükü", Data.mu_text(load_total), TEXT, 15)
	_row(column, "Günlük kapasite", "%s/gün" % _xfmt(per_day), TEXT, 15)
	column.add_child(_label("Vardiya, mesai ve hızlandırma Yönetim ayarlarından otomatik gelir.", 11, MUTED))
	_row(column, "Hesaplanan süre", "%d gün" % work_days, GREEN, 15)
	_row(column, "Başlangıç", "%s (bugünden %d gün sonra)" % [Data.date_text(int(game._date_after(start_day_n)[0]), int(game._date_after(start_day_n)[1])), start_day_n], TEXT, 14)
	var offered_label := _label("", 14, GOLD, false)
	var buffer_value := _label("", 15, GOLD, false)
	var slider_row := HBoxContainer.new()
	slider_row.add_child(_label("Güvenlik payı", 15, TEXT, false))
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 30
	slider.step = 1
	slider.value = quote_buffer
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(0, 44)
	slider_row.add_child(slider)
	buffer_value.custom_minimum_size = Vector2(56, 0)
	slider_row.add_child(buffer_value)
	column.add_child(slider_row)
	column.add_child(offered_label)
	var update := func(v: float) -> void:
		var days := int(ceilf(float(end_day_n) * (1.0 + v / 100.0)))
		buffer_value.text = "%%%d" % int(v)
		offered_label.text = "Teslim önerisi: %d gün sonra (%d ay)" % [days, maxi(1, int(ceilf(float(days) / float(Data.MONTH_DAYS))))]
	slider.value_changed.connect(update)
	update.call(slider.value)
	column.add_child(_button("Planı uygula", func() -> void:
		quote_buffer = int(slider.value)
		var offered_days := int(ceilf(float(end_day_n) * (1.0 + float(quote_buffer) / 100.0)))
		quote_months = clampi(int(ceilf(float(offered_days) / float(Data.MONTH_DAYS))), 1, int(offer["months"]) + 2)
		_close_overlay()
		_render(), true))
	column.add_child(_button("Vazgeç", _confirm_no))

func _quote_line() -> Control:
	var line := ColorRect.new()
	line.color = Color(BORDER.r, BORDER.g, BORDER.b, 0.8)
	line.custom_minimum_size = Vector2(0, 1)
	return line

# Two label/value pairs side by side (the compact spec grid of the quote screen).
func _quote_pair(parent: Control, left: Array, right: Array) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	for pair in [left, right]:
		var half := HBoxContainer.new()
		half.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_label := _label(String(pair[0]), 13, MUTED, false)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		half.add_child(name_label)
		var value := _label(String(pair[1]), 14, TEXT, false)
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		half.add_child(value)
		row.add_child(half)
	parent.add_child(row)

func _ask_send_quote(offer_id: int) -> void:
	var offer: Dictionary = game.offer_by_id(offer_id)
	if offer.is_empty():
		return
	_confirm("Teklifi gönder", [
		"%s · %s" % [offer["title"], offer["customer"]],
		"Teklif tutarı: %s (maliyet %s, marj %%%d)" % [Data.usd(quote_price), Data.usd(float(game.cost_estimate(offer, quote_edit)["total"])), int(roundf(quote_margin * 100.0))],
		"Peşinat %%%d · Teslimat %d ay" % [quote_adv, quote_months]], "Teklif ver", _send_quote.bind(offer_id),
		"Müşteri yanıtı birkaç saniye içinde Mail kutuna düşer. Anlaşırsan iş fabrikana eklenir.")

func _send_quote(offer_id: int) -> void:
	game.quote_progress = quote_progress
	game.quote_start_offset = quote_start_offset
	var result: Dictionary = game.submit_quote(offer_id, quote_price, quote_adv, quote_months)
	quote_months = 0
	if not result["ok"]:
		_say(result["reason"])
		_render()
		return
	game.delay_mail(result["mail"])
	detail = ""
	_say("Teklifiniz gönderildi; müşteri birkaç saniye içinde yanıt verecek.")
	_render()

# ------------------------------------------------------------------ Mail

func _open_mail(id: int) -> void:
	mail_open = id
	mail_show_offer = false
	mail_reply_open = false
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
			_mail_detail(game.mail_thread(mail)[0])   # opening any message shows the whole chain, newest on top
			return
	var arrived := 0
	for mail in game.mails:
		if game.mail_arrived(mail):
			arrived += 1
	if arrived == 0:
		content.add_child(_label("Mail kutun boş. Bir ilana teklif verince müşteri burada yanıt verir; sistem bildirimleri de buraya düşer.", 14, MUTED))
		return
	var shown_jobs := {}
	for mail in game.mails:
		if not game.mail_arrived(mail):
			continue
		var job_id: int = int(mail.get("offer_id", 0))
		if job_id > 0:
			if shown_jobs.has(job_id):
				continue
			shown_jobs[job_id] = true
		_mail_row(game.mail_thread(mail)[0], game.mail_thread(mail))

# Face of the person who wrote (art/contacts), the old envelope only for system mails.
func _mail_person(mail: Dictionary) -> Dictionary:
	if String(mail.get("contact_photo", "")) != "":
		return {"id": String(mail["contact_photo"]), "name": String(mail.get("contact", "")), "role": String(mail.get("contact_role", ""))}
	var offer: Dictionary = mail.get("offer", {})
	if not offer.is_empty():
		return Data.contact_info(offer)   # mails saved before the portraits existed get theirs from the job's customer
	return {"id": "", "name": String(mail.get("contact", "")), "role": ""}

func _contact_face(mail: Dictionary, side: int) -> Control:
	var photo_id: String = String(_mail_person(mail)["id"])
	var texture: Texture2D = Art.find("res://art/contacts/" + photo_id) if photo_id != "" else null
	if texture != null:
		return _rounded_photo(texture, Vector2(side, side), int(side * 0.22))
	var holder := _icon_rect("is_ilani_yetkili_kisi", side)
	return holder if holder != null else Control.new()

func _mail_row(mail: Dictionary, thread := []) -> void:
	var unread: bool = not bool(mail.get("read", true))
	var colors := {"accepted": GREEN, "counter": GOLD, "rejected": RED}
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _box(Color(PANEL.r, PANEL.g, PANEL.b, 0.94), colors.get(mail["status"], BORDER) if unread else BORDER, 14, 2 if unread else 1))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(_margin(row, 12, 10))
	var face_holder := Control.new()
	face_holder.custom_minimum_size = Vector2(76, 76)
	var face := _contact_face(mail, 72)
	face.position = Vector2(0, 0)
	face_holder.add_child(face)
	if unread:
		var dot := ColorRect.new()
		dot.color = RED
		dot.custom_minimum_size = Vector2(14, 14)
		dot.size = Vector2(14, 14)
		dot.position = Vector2(-3, -3)
		face_holder.add_child(dot)
	row.add_child(face_holder)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	info.add_child(_label(mail["title"], 16, TEXT if unread else MUTED))
	info.add_child(_label("%s · %s" % [mail["customer"], _mail_status_text(mail)], 12, colors.get(mail["status"], MUTED)))
	var thread_note: String = " · %d mesaj" % thread.size() if thread.size() > 1 else ""
	info.add_child(_label("Ay %d%s" % [mail["month"], thread_note], 11, MUTED))
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
		mail_reply_open = false
		_render())
	back.custom_minimum_size = Vector2(150, 44)
	top.add_child(back)
	content.add_child(top)
	var offer: Dictionary = mail.get("offer", {})
	var is_quote: bool = mail.get("kind", "quote") == "quote" and not offer.is_empty()
	var box := _card(content, "", GOLD, true)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	head.add_child(_contact_face(mail, 70))
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var person: Dictionary = _mail_person(mail)
	info.add_child(_label(Data.month_label(int(mail["month"])).get_slice(" · ", 0), 13, MUTED, false))
	if is_quote:
		info.add_child(_label("Konu: İş No: %d teklifiniz hk." % _job_no(offer), 14, TEXT))
		info.add_child(_label("Kimden: %s <%s>" % [person["name"], Data.contact_email(offer)], 12, MUTED))
	else:
		info.add_child(_label(mail["title"], 17, TEXT))
		info.add_child(_label("Kimden: %s" % String(mail["customer"]), 12, MUTED))
	head.add_child(info)
	box.add_child(head)
	box.add_child(_quote_line())
	var status: String = mail["status"]
	if not is_quote:
		for line in mail["lines"]:
			box.add_child(_label(str(line), 14, TEXT))
		return
	var wanted_price: float = float(mail.get("price", 0.0))
	box.add_child(_label("Merhaba,", 14, TEXT))
	box.add_child(_label("Teklifiniz için teşekkür ederiz.", 14, TEXT))
	var kind_counter: String = String(mail.get("kind_counter", ""))
	if status == "accepted":
		box.add_child(_label("Belirttiğiniz koşulların bizler için uygun olduğunu bildirmek isteriz. Ürünlerimizi aşağıdaki şartlarda teslim almayı hedefliyoruz;", 14, TEXT))
		var price: float = float(mail["my_price"])
		var advance: float = price * float(mail["my_advance"]) / 100.0
		var due_month: int = int(mail["month"]) + int(mail["my_months"]) - 1
		box.add_child(_label("Proje Bedeli: %s" % Data.usd(price), 14, TEXT))
		box.add_child(_label("Teslimat: %s (%d Ay)" % [Data.date_text(due_month, Data.MONTH_DAYS), int(mail["my_months"])], 14, TEXT))
		box.add_child(_label("Peşinat: %s (Hesabınıza aktarıldı)" % Data.usd(advance), 14, TEXT))
		var rest := "Her ay yapılan işin %%%d'i ödenir, kalanı son teslimatta" % int(Data.PROGRESS_SHARE * 100.0) if bool(mail.get("my_progress", true)) else "Teslimde tek seferde"
		box.add_child(_label("Kalan Ödeme: %s (%s)" % [Data.usd(price - advance), rest], 14, TEXT))
	elif status == "counter" and kind_counter == "price":
		box.add_child(_label("Hedef fiyatımız bu fiyatın (%s) biraz üzerinde kalıyor. Teklifinizi revize etmeniz mümkün mü? Beklediğimiz teklif tutarı: %s (− %s, − %%%s)" % [
			Data.usd(float(mail["my_price"])), Data.usd(wanted_price), Data.usd(float(mail["my_price"]) - wanted_price), ("%.1f" % (float(mail["request_pct"]) * 100.0)).replace(".", ",")], 14, TEXT))
	elif status == "rejected" and not String(mail["lines"][0]).begins_with("Teslim süresi"):
		box.add_child(_label("Ancak, hedef fiyatımızın üzerinde kaldığınız için sizinle çalışamayacağımızı üzülerek bildirmek isteriz.", 14, TEXT))
	else:
		for line in mail["lines"]:
			box.add_child(_label(str(line), 14, TEXT))
	box.add_child(_label("Saygılar\n%s" % person["name"], 14, TEXT))
	var editable: bool = status == "counter" and game.phase == "offers"
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	var show := _button("TEKLİFİ GÖSTER" if not mail_show_offer else "TEKLİFİ GİZLE", func() -> void:
		mail_show_offer = not mail_show_offer
		_render())
	show.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(show)
	if status == "counter":
		var reply := _button("Yanıtla", func() -> void:
			mail_reply_open = not mail_reply_open
			_render(), true)
		reply.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buttons.add_child(reply)
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
	if status == "counter" and mail_reply_open:
		box.add_child(_quote_line())
		if not editable:
			box.add_child(_label("Yanıt ay başında (rapordan önce) verilir.", 12, GOLD))
		else:
			var prob_label := _label("", 14, GOLD, false)
			var prob_row := HBoxContainer.new()
			var prob_name := _label("İşi Alma İhtimali", 14, MUTED, false)
			prob_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			prob_row.add_child(prob_name)
			prob_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			prob_row.add_child(prob_label)
			box.add_child(prob_row)
			var update_prob := func(price: float) -> void:
				var months_now: int = int(mail["months"]) if kind_counter == "time" else int(mail["my_months"])
				game.quote_progress = bool(mail.get("my_progress", true))
				prob_label.text = "%%%d" % int(roundf(float(game.accept_probability(offer, price, int(mail["my_advance"]), months_now, true)["accept"]) * 100.0))
			var start_price: float = wanted_price if kind_counter == "price" else float(mail["my_price"])
			update_prob.call(start_price)
			var price_edit := LineEdit.new()
			price_edit.text = str(int(roundf(start_price * Data.MONEY_UNIT_USD)))
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
			box.add_child(_button("Vazgeç", func() -> void:
				_answer_counter(mail["id"], false)))
	if mail_show_offer:
		_mail_offer_snapshot(mail)
	_mail_older_messages(mail)

# The earlier mails of the same bargaining chain, newest first, each behind a thin separator.
func _mail_older_messages(mail: Dictionary) -> void:
	var thread: Array = game.mail_thread(mail)
	for other in thread:
		if int(other["id"]) >= int(mail["id"]):
			continue
		var separator := HBoxContainer.new()
		separator.add_theme_constant_override("separation", 10)
		var line_a := ColorRect.new()
		line_a.color = BORDER
		line_a.custom_minimum_size = Vector2(0, 1)
		line_a.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line_a.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		separator.add_child(line_a)
		separator.add_child(_label("Önceki mesaj · Ay %d" % int(other["month"]), 11, FAINT, false))
		var line_b := ColorRect.new()
		line_b.color = BORDER
		line_b.custom_minimum_size = Vector2(0, 1)
		line_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line_b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		separator.add_child(line_b)
		content.add_child(separator)
		var card := _card(content, "", BORDER)
		var head := HBoxContainer.new()
		head.add_theme_constant_override("separation", 10)
		head.add_child(_contact_face(other, 48))
		var who := VBoxContainer.new()
		who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		who.add_child(_label("%s · %s" % [String(_mail_person(other)["name"]), _mail_status_text(other)], 13, TEXT))
		who.add_child(_label("Ay %d" % int(other["month"]), 11, MUTED))
		head.add_child(who)
		card.add_child(head)
		for line in other["lines"]:
			card.add_child(_label(str(line), 13, MUTED))
		if other.has("my_price"):
			card.add_child(_label("Teklifiniz: %s · peşinat %%%d · %d ay" % [Data.usd(float(other["my_price"])), int(other.get("my_advance", 0)), int(other.get("my_months", 0))], 12, GOLD))

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
	game.delay_mail(result["mail"])
	mail_open = -1
	mail_show_offer = false
	_say("Güncel teklifiniz gönderildi; müşteri birkaç saniye içinde yanıt verecek.")
	_render()

func _answer_counter(mail_id: int, yes: bool) -> void:
	var result: String = game.answer_counter(mail_id, yes)
	if result != "":
		_say(result)
	_render()

# Supplier picker of the quote screen: the current supplier on top, the others compared with it.
func _detail_supplier_pick() -> void:
	var offer: Dictionary = game.offer_by_id(int(detail_arg))
	var current: Dictionary = Data.supplier_by_id(game.default_supplier)
	var intro := _card(content, "Hammaddeyi kimden alalım?", GOLD, true)
	intro.add_child(_label("Fiyat, teslim süresi ve tedarikçi skoru birlikte karar verir: ucuz ve hızlı olan çoğu zaman güvenilir değildir. Skor, malzemenin söz verilen günde gelme olasılığıdır; gelmezse iş bir ay kayar.", 12, MUTED))
	var ordered: Array = [current]
	for supplier in Data.SUPPLIERS:
		if supplier["id"] != current["id"]:
			ordered.append(supplier)
	for supplier in ordered:
		var is_current: bool = supplier["id"] == current["id"]
		var card := _card(content, "", GOLD if is_current else BORDER, true)
		var head := HBoxContainer.new()
		var name_label := _label(supplier["name"], 20, TEXT, false)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(name_label)
		if is_current:
			head.add_child(_label("(mevcut tedarikçi)", 13, GOLD, false))
		card.add_child(head)
		_row(card, "Teslim", Data.lead_text(int(supplier["lead"])), TEXT, 15)
		var diff: float = float(supplier["price"]) / float(current["price"]) - 1.0
		if is_current:
			_row(card, "Fiyat", "mevcut", MUTED, 15)
		else:
			_row(card, "Fiyat", "%%%d %s" % [int(roundf(absf(diff) * 100.0)), "pahalı" if diff > 0.0 else "ucuz"], RED if diff > 0.0 else GREEN, 15)
		var score: int = Data.supplier_score(supplier)
		_row(card, "Tedarikçi skoru", "%%%d" % score, GREEN if score >= 90 else (GOLD if score >= 80 else RED), 15)
		_row(card, "Kalite", "%s (verim %%%.1f)" % [Data.QUALITY_NAMES[int(supplier["quality"])], float(Data.QUALITY_YIELD[int(supplier["quality"])]) * 100.0], TEXT, 14)
		_row(card, "Ödeme", "peşin" if int(supplier["terms"]) == 0 else "%d ay vadeli" % supplier["terms"], TEXT, 14)
		if not offer.is_empty():
			var quote: Dictionary = game.material_quote(offer, supplier["id"])
			_row(card, "Bu işin hammaddesi", Data.usd(float(quote["amount"])), GOLD, 15)
		if not is_current:
			card.add_child(_button("Bu tedarikçiyi seç", _choose_supplier.bind(supplier["id"]), true))

func _choose_supplier(id: String) -> void:
	game.default_supplier = id
	_open_detail("quote", detail_arg)

# ------------------------------------------------------------------ Tedarik

func _supplier_card(supplier: Dictionary, quote: Dictionary, job_id := 0) -> void:
	var is_default: bool = supplier["id"] == game.default_supplier
	var card := _card(content, supplier["name"] + ("  (varsayılan)" if is_default and job_id == 0 else ""), GREEN if is_default and job_id == 0 else BORDER, true)
	card.add_child(_label(supplier["note"], 13, MUTED))
	if not quote.is_empty():
		_row(card, "Hammadde bedeli", Data.usd(float(quote["amount"])), TEXT, 16)
		_row(card, "Gelir", "Ay %d" % (game.month + int(quote["lead"])), TEXT, 15)
	_row(card, "Fiyat", "%%%d" % int(roundf(float(supplier["price"]) * 100.0)), GREEN if float(supplier["price"]) < 1.0 else RED if float(supplier["price"]) > 1.0 else TEXT, 15)
	_row(card, "Temin süresi", Data.lead_text(int(supplier["lead"])), TEXT, 15)
	_row(card, "Tedarikçi skoru", "%%%d" % Data.supplier_score(supplier), TEXT, 15)
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
	var active := (1 if type_filter != "Tümü" else 0) + (1 if level_filter != 0 else 0)
	var sort_names := {"price_up": "fiyat ↑", "price_down": "fiyat ↓", "cond_up": "kondisyon ↑", "cond_down": "kondisyon ↓"}
	var machine_chips: Array = []
	if type_filter != "Tümü":
		machine_chips.append("Tür: " + type_filter)
	if level_filter != 0:
		machine_chips.append("Seviye: " + Data.LEVELS[level_filter])
	if sort_mode != "price_up":
		machine_chips.append("Sıra: " + sort_names[sort_mode])
	_filter_bar(active, machine_chips,
		_open_machine_filters, func() -> void:
			type_filter = "Tümü"
			level_filter = 0
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
		if listing["uid"] == selected_listing:
			_machine_card(listing)
		else:
			_machine_row(listing)
	_update_area_preview()

func _open_machine_filters() -> void:
	_filter_popup("Filtre ve sıralama", func(box: VBoxContainer) -> void:
		var type_options: Array = [{"id": "Tümü", "title": "Tümü"}]
		for kind in Data.TYPES:
			type_options.append({"id": kind, "title": kind})
		var level_options: Array = [{"id": "0", "title": "Tüm seviyeler"}]
		for level in [1, 2, 3]:
			level_options.append({"id": str(level), "title": Data.LEVELS[level]})
		var sort_names := {"price_up": "fiyat ↑", "price_down": "fiyat ↓", "cond_up": "kondisyon ↑", "cond_down": "kondisyon ↓"}
		_filter_groups(box, [
			{"id": "tur", "title": "Tür", "summary": type_filter, "reopen": _open_machine_filters,
				"build": func(b: VBoxContainer) -> void:
					_flow_chips(b, "", type_options, type_filter, func(id: String) -> void:
						type_filter = id
						selected_listing = -1
						_open_machine_filters())},
			{"id": "seviye", "title": "Seviye", "summary": "hepsi" if level_filter == 0 else Data.LEVELS[level_filter], "reopen": _open_machine_filters,
				"build": func(b: VBoxContainer) -> void:
					_flow_chips(b, "", level_options, str(level_filter), func(id: String) -> void:
						level_filter = int(id)
						selected_listing = -1
						_open_machine_filters())},
			{"id": "sira", "title": "Sıralama", "summary": sort_names.get(sort_mode, sort_mode), "reopen": _open_machine_filters,
				"build": func(b: VBoxContainer) -> void:
					_flow_chips(b, "", [{"id": "price_up", "title": "Fiyat ↑"}, {"id": "price_down", "title": "Fiyat ↓"}, {"id": "cond_up", "title": "Kondisyon ↑"}, {"id": "cond_down", "title": "Kondisyon ↓"}], sort_mode, func(id: String) -> void:
						sort_mode = id
						selected_listing = -1
						_open_machine_filters())}]))

func _build_area_bar() -> void:
	var factory: Dictionary = game.factory()
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _box(BAR, BORDER, 0, 0))
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
	var text := "Yuva: %d / %d tezgah · Alan: %d / %d m² · tavan %.1f m" % [game.machines.size(), game.slots_total(), int(used), factory["m2"], factory["height"]]
	if extra > 0.0:
		text += "  (+%d m² → %d m²)" % [int(extra), int(used + extra)]
	area_label.text = text
	area_label.add_theme_color_override("font_color", YELLOW if extra > 0.0 else MUTED)

# The "required area" icon: gerekli_alan.svg when the artist has supplied it, else the floor-measure icon of the plant listings.
func _area_icon() -> String:
	return "gerekli_alan" if Art.find("res://art/ui/gerekli_alan") != null else "fabrika_zemin"

# One cell of the spec grid: line icon (tinted), name, value on the right.
func _spec_cell(icon_name: String, title: String, value: String, tint: Color, value_color := TEXT) -> Control:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8)
	var icon := _icon_rect(icon_name, 24)
	if icon != null:
		icon.modulate = tint
		row.add_child(icon)
	var name_label := _label(title, 13, tint if tint == GOLD else TEXT, false)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	row.add_child(_label(value, 13, value_color, false))
	return row

func _feature_tile(icon_name: String, title: String, value: String) -> Control:
	var tile := PanelContainer.new()
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
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

func _price_block(listing: Dictionary, size := 18) -> String:
	if float(listing["discount"]) > 0.0:
		return "[right][s][color=#98a7b6]%s[/color][/s]\n[color=#e7b75c]-%%%d[/color]  [color=#2fd17b][b]%s[/b][/color][/right]" % [Data.usd(float(listing["base_price"])), int(roundf(float(listing["discount"]) * 100.0)), Data.usd(float(listing["price"]))]
	return "[right][color=#2fd17b][b]%s[/b][/color][/right]" % Data.usd(float(listing["price"]))

func _machine_row(listing: Dictionary) -> void:
	var box := _card(content, "", BORDER)
	box.add_child(_row_head(Art.machine_photo(listing["kind"], int(listing["level"]), float(listing.get("condition", 100.0))), "%s %s" % [Data.LEVELS[int(listing["level"])], listing["kind"]], listing["model"], _price_block(listing)))
	var tiles := HBoxContainer.new()
	tiles.add_theme_constant_override("separation", 4)
	tiles.add_child(_mini_tile("tezgah_guc", ("%.1f kW" % float(listing["power"])).replace(".", ","), false))
	tiles.add_child(_mini_tile("tezgah_tolerans", Data.tolerance_text(float(listing["precision"])), false))
	tiles.add_child(_mini_tile("tezgah_kondisyon", "%% %d" % int(listing["condition"]), false))
	tiles.add_child(_mini_tile("tezgah_teslim", "%d Ay" % int(listing["delivery"]), false))
	box.add_child(tiles)
	_tap_panel(box, func() -> void:
		selected_listing = int(listing["uid"])
		_render_keep_scroll())

func _machine_card(listing: Dictionary) -> void:
	var selected: bool = listing["uid"] == selected_listing
	var box := _card(content, "", GOLD if selected else BORDER, true)
	box.add_theme_constant_override("separation", 16)
	var panel := _panel_of(box)
	listing_cards[listing["uid"]] = panel
	var level_name: String = Data.LEVELS[int(listing["level"])]
	var photo := Art.machine_photo(listing["kind"], int(listing["level"]), float(listing["condition"]))
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	if photo != null:
		var frame := _rounded_photo(photo, Vector2(0, 190), 16)
		frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		frame.size_flags_stretch_ratio = 3.0
		top.add_child(frame)
	else:
		var slot := _image_slot("machines", "%s_%d" % [Art.slug(listing["kind"]), listing["level"]], Color("#26313d"), 190)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.size_flags_stretch_ratio = 3.0
		top.add_child(slot)
	var side := VBoxContainer.new()
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side.size_flags_stretch_ratio = 2.0
	side.add_child(_label("%s %s" % [level_name, listing["kind"]], 18, TEXT))
	side.add_child(_label(String(listing["model"]), 13, MUTED))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(spacer)
	side.add_child(_rich(_price_block(listing), 20))
	top.add_child(side)
	box.add_child(top)
	# data in two columns: icon, name, value (technical cyan icons)
	var data_grid := GridContainer.new()
	data_grid.columns = 2
	data_grid.add_theme_constant_override("h_separation", 14)
	data_grid.add_theme_constant_override("v_separation", 18)
	for entry in [
		["tezgah_guc", "Motor Gücü", ("%.1f kW" % float(listing["power"])).replace(".", ",")],
		[_area_icon(), "Gerekli Alan", ("%d m² x %.1fm" % [int(listing["area"]), float(listing["height"])]).replace(".0m", "m").replace(".", ",")],
		["tezgah_tolerans", "Hassasiyet", Data.tolerance_text(float(listing["precision"]))],
		["tezgah_teslim", "Teslim Süresi", "%d Ay" % int(listing["delivery"])],
		["tezgah_kondisyon", "Kondisyon", "%% %d" % int(listing["condition"])]]:
		data_grid.add_child(_spec_cell(entry[0], entry[1], entry[2], CYAN))
	box.add_child(data_grid)
	# forecast, 3 shifts (amber icons)
	box.add_child(_label("Öngörülen Veriler (3 vardiya)", 15, GOLD, false))
	var energy: float = _listing_energy(listing)   # the listing shows the low end; operation rolls 5-10 percent a step
	var maintenance: float = _listing_maintenance(listing)
	var forecast_grid := GridContainer.new()
	forecast_grid.columns = 2
	forecast_grid.add_theme_constant_override("h_separation", 14)
	forecast_grid.add_theme_constant_override("v_separation", 18)
	for entry in [
		["tezgah_ongoru_bakim", "Bakım Gideri", "-%s /ay" % Data.usd(maintenance), RED],
		["tezgah_ongoru_kapasite", "Kapasite", "%s/ay" % _xfmt(float(listing["nameplate"])), GREEN],
		["tezgah_ongoru_enerji", "Enerji Gideri", "-%s /ay" % Data.usd(energy * 3.0), RED]]:
		forecast_grid.add_child(_spec_cell(entry[0], entry[1], entry[2], GOLD, entry[3]))
	box.add_child(forecast_grid)
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
		selected_listing = -1
		_render_keep_scroll()

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
		"Aylık işletme: %s enerji (3 vardiya) + %s bakım" % [Data.usd(_listing_energy(listing) * 3.0), Data.usd(_listing_maintenance(listing))],
		"Teorik kapasite %s/ay (3 vardiya); tek vardiyada bunun yaklaşık üçte biri." % _xfmt(float(listing["nameplate"])),
		"Alan: %d m²" % listing["area"]
	], "Satın al", _buy.bind(uid))

# Same figures as the listing card: energy and upkeep of the machine's condition (a missing 10 points costs more).
func _listing_energy(listing: Dictionary) -> float:
	return float(listing["energy"]) * (1.0 + Data.condition_steps(float(listing["condition"])) * float(Data.ENERGY_STEP_RANGE[0]))

func _listing_maintenance(listing: Dictionary) -> float:
	return Data.condition_steps(float(listing["condition"])) * float(Data.MAINT_STEP_PCT[int(listing["level"])]) * float(listing["price"])

func _buy(uid: int) -> void:
	var result: String = game.buy_listing(uid)
	if result != "":
		_say(result)
	selected_listing = -1
	_render()

# ------------------------------------------------------------------ Ekipman

const EQUIPMENT_PHOTO := {"transpalet": "transpalet", "kasa": "malzeme_kasası", "raf": "depo_rafi", "forklift": "forklift_100", "forklift_70": "forklift_70", "forklift_40": "forklift_40", "olcum": "kalite_olcum_100", "vinc": "kopru_vinc"}

# Photo (left) and title/price (right) of an equipment card, the same layout as the machine cards.
func _equipment_head(box: VBoxContainer, photo_name: String, title: String, subtitle: String, price: float) -> void:
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	var photo := Art.find("res://art/" + photo_name)
	if photo != null:
		var frame := _rounded_photo(photo, Vector2(0, 150), 16)
		frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		frame.size_flags_stretch_ratio = 3.0
		top.add_child(frame)
	var side := VBoxContainer.new()
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side.size_flags_stretch_ratio = 2.0
	side.add_child(_label(title, 18, TEXT))
	if subtitle != "":
		side.add_child(_label(subtitle, 12, MUTED))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(spacer)
	side.add_child(_label("Fiyat", 12, MUTED, false))
	side.add_child(_label(Data.usd(price), 22, GREEN, false))
	top.add_child(side)
	box.add_child(top)

func _page_equipment() -> void:
	var package: Dictionary = game.package_info()
	var box := _card(content, "", GREEN if game.package_bought else GOLD, true)
	box.add_theme_constant_override("separation", 12)
	_equipment_head(box, "ekipman_resim", "Gerekli Ekipman Seti" + (" ✔" if game.package_bought else ""), "Üretim için şart; eksikse kapasite kullanılamaz.", float(package["price"]))
	for id in package["items"]:
		var item: Dictionary = Data.EQUIPMENT[id]
		_row(box, "%s x %d" % [item["name"], package["items"][id]], Data.usd(float(item["price"]) * int(package["items"][id])), TEXT, 14)
	_row(box, "Set Fiyatı", Data.usd(float(package["price"])), GREEN, 16)
	var reason: String = game.package_block_reason()
	box.add_child(_button("Satın Al" if reason == "" else reason, _ask_package, reason == "", reason != "", true))
	content.add_child(_label("İsteğe bağlı ekipman", 20, TEXT))
	content.add_child(_label("Kesici uç ve takım sarfı tezgahın aylık işletme giderine dahildir.", 12, MUTED))
	for id in Data.OPTIONAL_ORDER:
		_equipment_card(id)

func _equipment_card(id: String) -> void:
	var item: Dictionary = Data.EQUIPMENT[id]
	var qty: int = equip_qty.get(id, 1)
	var box := _card(content, "", BORDER, true)
	box.add_theme_constant_override("separation", 12)
	_equipment_head(box, String(EQUIPMENT_PHOTO.get(id, "ekipman_resim")), String(item["name"]), "", float(item["price"]))
	_row(box, "Durum", "Yeni" if not item.has("condition") else "İkinci El - %%%d" % int(item["condition"]), TEXT, 14)
	_row(box, "Gerekli Alan", "%s m²" % str(item["area"]).replace(".", ",") if float(item["area"]) > 0.0 else "alan tüketmez", TEXT, 14)
	_row(box, "Mevcut", "%d ad" % game.equipment_owned(id), TEXT, 14)
	box.add_child(_label(item["note"], 12, MUTED))
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
	box.add_child(_button("Satın Al · %s" % Data.usd(float(item["price"]) * qty) if reason == "" else reason, _ask_equipment.bind(id), reason == "", reason != "", true))

func _change_qty(id: String, delta: int) -> void:
	equip_qty[id] = maxi(1, int(equip_qty.get(id, 1)) + delta)
	_render()

func _ask_package() -> void:
	var package: Dictionary = game.package_info()
	_confirm("Gerekli seti al", ["Ödeme: %s" % Data.usd(float(package["price"]))], "Satın al", _buy_package)

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

# One chart (icon, name, bars) of a machine kind; `offer` adds the quoted job's load as an outline.
func _capacity_chart_box(kind: String, offer := {}, months := 1) -> Control:
	var color: Color = KIND_COLOR.get(kind, TEXT)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var head := HBoxContainer.new()
	head.alignment = BoxContainer.ALIGNMENT_BEGIN   # icon and name sit at the left, over the chart's y axis
	head.add_theme_constant_override("separation", 6)
	var icon := _icon_rect(Art.slug(kind) + "_icon", 28)
	if icon != null:
		icon.modulate = color
		head.add_child(icon)
	head.add_child(_label(kind, 15, color, false))
	box.add_child(head)
	var chart = CapacityChart.new()
	chart.set_data(game.capacity_chart(kind, offer, months), color)
	box.add_child(chart)
	return box

func _capacity_legend(parent: Control, with_extra: bool) -> void:
	var text := "Koyu çubuk: kapasite · açık çubuk: kabul edilmiş işlerin yükü · taralı: yolda olan tezgah · altın: ince tezgahın kaba işe kaymış yükü · kırmızı: yapacak tezgahı olmayan yük"
	if with_extra:
		text += " · beyaz çerçeve: bu teklifin yükü"
	parent.add_child(_label(text, 11, MUTED))

func _page_capacity() -> void:
	var box := _card(content, "Kapasite ve yük (ω/ay)", GREEN, true)
	box.add_child(_label("Her tolerans sınıfında kapasite ile kabul ettiğin işlerin aylık yükü. İnce bir tezgah, kendi seviyesindeki iş bitince kaba işleri de alır.", 12, MUTED))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 14)
	for kind in Data.TYPES:
		grid.add_child(_capacity_chart_box(kind))
	box.add_child(grid)
	_capacity_legend(box, false)

func _page_fabrika() -> void:
	if game.factory_id != "" and subtab["fabrika"] == "vardiya":
		_page_shifts()
		return
	if game.factory_id != "" and subtab["fabrika"] == "kapasite":
		_page_capacity()
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
		if game.in_notice_window():
			_renewal_card(factory)
		if game.is_moving():
			content.add_child(_label("Taşınma sürüyor: tezgahlar %d ay sonra çalışır." % (game.moving_until - game.month), 14, GOLD))
		content.add_child(_label("Taşın ya da büyü", 20, TEXT))
		content.add_child(_label("Başka bir yere taşınırsan çıkış ve taşıma bedeli ödersin; üretim en fazla 1 ay durur, personel ücretleri sürer.", 12, MUTED))
		for other in Data.FACTORIES:
			if other["id"] == game.factory_id:
				continue
			var row := _factory_row(other)
			_tap_panel(row, _open_detail.bind("factory", other["id"]))
		return
	content.add_child(_label("Kiralık yerler", 22, TEXT))
	for factory in Data.FACTORIES:
		var box := _factory_row(factory)
		_tap_panel(box, _open_detail.bind("factory", factory["id"]))

# Contract end: the player picks the next period, or does nothing and the rent follows the market.
# Contract options as shown: 12 months first (the usual), then 6, then 24.
func _terms_in_order() -> Array:
	var ordered: Array = []
	for months in [12, 6, 24]:
		for term in Data.TERMS:
			if int(term["months"]) == months:
				ordered.append(term)
	return ordered

func _renewal_card(factory: Dictionary) -> void:
	var card := _card(content, "Sözleşme bitiyor · %d ay kaldı" % game.months_left, GOLD, true)
	card.add_child(_label("Süreyi seç: seçtiğin süre için kira bugünkü seviyede kalır. Karar vermezsen sözleşme aynı süre için piyasa kirasıyla (+%%%d) yenilenir. Son ayda çıkış ya da taşınma için çıkış bedeli yoktur." % int(Data.RENEWAL_MARKUP * 100.0), 13, MUTED))
	for entry in _terms_in_order():
		var months: int = entry["months"]
		var chosen: bool = game.renewal_term == months
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var info := _label("%s%d ay · aylık %s" % ["✔ " if chosen else "", months, Data.usd(game.rent_for_term(months))], 15, GREEN if chosen else TEXT)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var pick := _button("Seçili" if chosen else "Bu süreyi seç", _set_renewal.bind(months), not chosen, chosen)
		pick.custom_minimum_size = Vector2(150, 44)
		row.add_child(pick)
		card.add_child(row)
	if game.renewal_term == 0:
		card.add_child(_label("Karar yok: bitişte aylık %s ile yenilenir." % Data.usd(game.rent_if_unanswered()), 12, GOLD))

func _set_renewal(months: int) -> void:
	var result: String = game.set_renewal(months)
	if result != "":
		_say(result)
	else:
		_say(game.notice)
	_render()

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
	box.add_child(_label("İşi olmayan günlerde tezgahın ekibi maaşın yarısını alır (kısa çalışma); iş olan gün tam öder.", 12, GOLD))
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
	_benefits_card()
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

# Staff benefits: one 3-step slider per benefit. Optional ones start at "none"; a higher step anywhere needs every
# benefit one step higher first. A change starts with the next month.
func _benefits_card() -> void:
	var care := _card(content, "Yan haklar (sonraki aydan geçerli)", BORDER, true)
	care.add_child(_label("İlk dört yan hak zorunludur (en az V1). Başka bir hakta V2 için her hakkın en az V1, V3 için en az V2 olması gerekir. Değişiklik bir sonraki ay başında uygulanır.", 12, MUTED))
	for i in Data.BENEFITS.size():
		var item: Dictionary = Data.BENEFITS[i]
		var level: int = int(game.benefits_next[i])
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation", 2)
		var top := HBoxContainer.new()
		var name_label := _label("%d. %s%s" % [i + 1, item["name"], "  (zorunlu)" if bool(item["mandatory"]) else ""], 15, TEXT, false)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top.add_child(name_label)
		var value_label := _label(_benefit_text(i, level), 13, GOLD if level > 0 else MUTED, false)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		top.add_child(value_label)
		row.add_child(top)
		var slider := HSlider.new()
		slider.min_value = 1 if bool(item["mandatory"]) else 0
		slider.max_value = 3
		slider.step = 1
		slider.value = level
		slider.custom_minimum_size = Vector2(0, 40)
		slider.value_changed.connect(func(v: float) -> void: value_label.text = _benefit_text(i, int(v)))
		slider.drag_ended.connect(func(changed: bool) -> void:
			if not changed:
				return
			var result: String = game.set_benefit(i, int(slider.value))
			if result != "":
				_say(result)
			_render_keep_scroll())
		row.add_child(slider)
		care.add_child(row)
	var total_now: float = Data.benefit_cost_of(game.benefits)
	var total_next: float = Data.benefit_cost_of(game.benefits_next)
	_row(care, "Kişi başı aylık gider (şimdi → sonraki ay)", "%s → %s" % [Data.usd(total_now), Data.usd(total_next)], GOLD, 14)
	_row(care, "Sorun önleme payı (şimdi → sonraki ay)", "+%%%d → +%%%d puan" % [int(roundf(Data.benefit_bonus_of(game.benefits) * 100.0)), int(roundf(Data.benefit_bonus_of(game.benefits_next) * 100.0))], GOLD, 14)
	care.add_child(_label("Güçlü yan haklar insanla ilgili sorunların başlamadan önlenme şansını artırır; yükselen kademe maliyeti daha hızlı artırır.", 12, MUTED))

func _benefit_text(index: int, level: int) -> String:
	if level <= 0:
		return "Yok"
	var item: Dictionary = Data.BENEFITS[index]
	return "V%d · %s/kişi · +%%%.1f" % [level, Data.usd(float(item["cost"]) * float(item["mult"][level - 1])), float(item["bonus"]) * float(item["effect"][level - 1]) * 100.0]

func _on_shift_tick(on: bool, n: int) -> void:
	var target := n if on else n - 1
	if target > game.plan_shifts and game.plan_shifts == 1 and game.phase == "offers":
		_ask_open_shift(target)
		return
	var severance: float = game.severance_for(target) if target < game.plan_shifts else 0.0
	if severance > 0.0:
		_confirm("Vardiyayı kapat", ["Ekip işten çıkarılır; tazminat: %s." % Data.usd(severance)], "Kapat ve öde",
			func() -> void: _apply_plan(target, game.plan_ot.duplicate(), game.plan_patron), "Sözleşmeli ekipte süre bitince tazminat çıkmaz.")
		_render()
		return
	_apply_plan(target, game.plan_ot.duplicate(), game.plan_patron)

# Opening the second shift hires a new crew per machine: permanent or fixed-term (IDEA-022).
func _ask_open_shift(target: int) -> void:
	var wage := 0.0
	for machine in game.delivered():
		wage += Data.wage_for(machine["kind"]) * int(machine["personnel"])
	var extras := []
	for months in Data.CONTRACTS:
		var premium: float = Data.contract_premium(months)
		var cut: float = Data.contract_severance_cut(months)
		extras.append(["%d ay sözleşmeli · maaş +%%%d · tazminat −%%%d" % [months, int(premium * 100.0), int(cut * 100.0)],
			func() -> void: _apply_plan(target, game.plan_ot.duplicate(), game.plan_patron, months)])
	_confirm("%d. vardiyayı aç" % target, ["Tezgah başına yeni personel işe alınır (ekip maaşı yaklaşık %s/ay)." % Data.usd(wage),
		"Kadrolu: normal maaş, kapatınca 2 aylık tazminat. Sözleşmeli: süre bitince vardiya kendiliğinden kapanır, tazminat yok/az."],
		"Kadrolu aç", func() -> void: _apply_plan(target, game.plan_ot.duplicate(), game.plan_patron, 0),
		"Gece ve ek vardiyalar daha verimsizdir (Manuel %85/75, CNC %95/90, Hassas kayıpsız).", extras)
	_render()

func _on_overtime_tick(on: bool, n: int) -> void:
	var overtime: Array = game.plan_ot.duplicate()
	overtime[n - 1] = on
	_apply_plan(game.plan_shifts, overtime, game.plan_patron)

func _on_patron_tick(on: bool) -> void:
	_apply_plan(game.plan_shifts, game.plan_ot.duplicate(), on)

func _apply_plan(shifts: int, overtime: Array, patron: bool, contract := -1) -> void:
	var result: String = game.set_plan(shifts, overtime, patron, contract)
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
		"machine":
			title.text = "  Tezgah"
			_detail_machine(int(detail_arg))
		"oee":
			title.text = "  OEE ve kapasite"
			_detail_oee()
		"costs":
			title.text = "  Aylık gider"
			_detail_costs()
		"cash":
			title.text = "  Serbest nakit"
			_detail_cash()
		"order":
			title.text = "  Hammadde"
			_detail_order()
		"quote":
			title.text = "  Teklif"
			_detail_quote()
		"settings":
			title.text = "  Ayarlar"
			_detail_settings()
		"history", "log":
			title.text = "  Log"
			_detail_log()
		"supplier_pick":
			title.text = "  Tedarikçi seç"
			_detail_supplier_pick()

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
	var time_card := _card(content, "Zaman (deneme)", GOLD, true)
	var flow := CheckBox.new()
	flow.text = "Akan zaman"
	flow.add_theme_font_size_override("font_size", _fs(16))
	flow.custom_minimum_size = Vector2(0, 52)
	flow.button_pressed = flow_on
	flow.toggled.connect(_set_flow_on)
	time_card.add_child(flow)
	time_card.add_child(_label("Açıkken zaman gün gün akar; ⏸ ▶ ⏩ ⏭ ile durdurur, hızlandırırsın. Karar penceresi (onay, teklif) saati durdurur; ay bitince rapor açılır. Üretim sonuçları hâlâ ay sonunda işlenir; çalışan tezgahın ilerleyişi tahminidir. Kapatırsan eski \"Ayı çalıştır\" düğmeleri döner. IDEA-019 deneme sürümü.", 12, MUTED))

func _detail_factory(factory: Dictionary) -> void:
	var moving: bool = game.factory_id != "" and factory["id"] != game.factory_id
	var hero := _card(content, "", BORDER, true)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	var big: Texture2D = Art.find("res://art/factories/" + String(factory["id"]))
	var photo_side: Control = _rounded_photo(big, Vector2(0, 230), 18) if big != null else _image_slot("factories", factory["id"], factory["tint"], 230)
	photo_side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	photo_side.size_flags_stretch_ratio = 3.0
	top.add_child(photo_side)
	if not moving:
		var terms_side := _terms_column(factory)
		terms_side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		terms_side.size_flags_stretch_ratio = 2.6
		top.add_child(terms_side)
	hero.add_child(top)
	hero.add_child(_label(String(factory["name"]), 20, TEXT, false))
	hero.add_child(_label(String(factory["region"]), 13, MUTED, false))
	var floor_size: String = ("%d m²" % int(factory["m2"]))
	for spec in [["fabrika_zemin", "Zemin Ölçüleri", floor_size, ""],
			["fabrika_slot", "Makine Slot Sayısı", str(Data.slot_count(factory["id"])), "1 slot = 1 makine"],
			["fabrika_cati", "Çatı Yüksekliği", ("%.1f m" % float(factory["height"])).replace(".0 m", " m").replace(".", ","), ""]]:
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 12)
		var icon := _icon_rect(String(spec[0]), 32)
		if icon != null:
			icon.modulate = CYAN
			line.add_child(icon)
		var title := _label(String(spec[1]), 15, TEXT, false)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line.add_child(title)
		var value_box := VBoxContainer.new()
		value_box.alignment = BoxContainer.ALIGNMENT_CENTER
		value_box.add_theme_constant_override("separation", 0)
		var value_label := _label(String(spec[2]), 15, TEXT, false)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_box.add_child(value_label)
		if spec[3] != "":
			var note_label := _label(String(spec[3]), 12, BLUE, false)
			note_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			value_box.add_child(note_label)
		line.add_child(value_box)
		hero.add_child(line)
	hero.add_child(_label("Bina yaşı %d yıl · zemin %s · %d rampa · %d kVA" % [factory["age"], factory["floor"], factory["ramps"], factory["kva"]], 12, MUTED))
	if moving:
		_move_section(factory)
		return
	var reason: String = game.rent_block_reason(factory["id"], picked_term, picked_prepay)
	if reason != "":
		content.add_child(_label(reason, 13, RED))
	content.add_child(_button("Kirala", _ask_rent.bind(factory["id"]), true, reason != "", true))

# Right-hand column of the open plant card: the contract options and the prepay choice.
func _terms_column(factory: Dictionary) -> Control:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	column.add_child(_label("Sözleşme Süresi", 16, TEXT))
	var base_rent: float = float(factory["rent"]) * Data.rent_scale
	var group := ButtonGroup.new()
	for term in _terms_in_order():
		var months: int = term["months"]
		var chosen: bool = months == picked_term
		var price := snappedf(base_rent * float(term["factor"]), 0.001)
		var button := Button.new()
		button.toggle_mode = true
		button.button_group = group
		button.button_pressed = chosen
		button.custom_minimum_size = Vector2(0, 58)
		for style_name in ["normal", "hover", "pressed", "hover_pressed"]:
			button.add_theme_stylebox_override(style_name, _box(GREEN_DIM if chosen else BG, GREEN if chosen else BORDER, 10, 1))
		var label := RichTextLabel.new()
		label.bbcode_enabled = true
		label.fit_content = false
		label.scroll_active = false
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.offset_left = 12
		label.offset_right = -8
		label.offset_top = 8
		label.add_theme_font_size_override("normal_font_size", _fs(15))
		label.add_theme_font_size_override("bold_font_size", _fs(15))
		label.add_theme_font_override("normal_font", FONT_REGULAR)
		label.add_theme_font_override("bold_font", FONT_MEDIUM)
		var note := ""
		var pct := int(roundf(absf(float(term["factor"]) - 1.0) * 100.0))
		if float(term["factor"]) > 1.0:
			note = "[color=#e86f6f]+%%%d[/color]" % pct
		elif float(term["factor"]) < 1.0:
			note = "[color=#e7b75c]-%%%d[/color]" % pct
		label.text = "%d Ay x [color=#2fd17b][b]%s[/b][/color] /ay%s" % [months, Data.usd(price), ("\n[font_size=12]" + note + "[/font_size]") if note != "" else ""]
		button.add_child(label)
		button.pressed.connect(_pick_term.bind(months))
		_juice(button)
		column.add_child(button)
	var quote: Dictionary = game.prepay_quote(factory["id"], picked_term)
	var prepay_row := HBoxContainer.new()
	prepay_row.add_theme_constant_override("separation", 6)
	var prepay := CheckBox.new()
	prepay.button_pressed = picked_prepay
	prepay.toggled.connect(_toggle_prepay)
	prepay_row.add_child(prepay)
	var prepay_text := VBoxContainer.new()
	prepay_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prepay_text.add_theme_constant_override("separation", 0)
	prepay_text.add_child(_label("%d aylık kirayı peşin öde" % int(quote["half"]), 13, TEXT))
	prepay_text.add_child(_label("%%%d indirim" % int(roundf(float(quote["discount"]) * 100.0)), 12, GREEN))
	if picked_prepay:
		prepay_text.add_child(_label("Şimdi: %s" % Data.usd(float(quote["amount"])), 12, GREEN_HI))
	prepay_row.add_child(prepay_text)
	column.add_child(prepay_row)
	return column

# Moving from the rented plant into this one (bigger, smaller or just different).
func _move_section(factory: Dictionary) -> void:
	var excess: int = game.move_excess(factory["id"])
	var valid: Array = []
	for uid in move_sell:
		if not game.machine_by_uid(int(uid)).is_empty():
			valid.append(uid)
	move_sell = valid
	var costs: Dictionary = game.move_cost(factory["id"], move_sell)
	var equipment_plan: Dictionary = game.move_equipment_plan(factory["id"])
	var card := _card(content, "Buraya taşın", GOLD, true)
	card.add_child(_label("Tezgahlar sökülüp taşınır ve yeni yuvalara kurulur. Üretim 1 ay durur, işler bekler, personel ücretleri sürer; eski sözleşme çıkış bedeliyle biter, yeni kira hemen başlar.", 13, MUTED))
	_row(card, "Yeni yer", "%s · %d yuva" % [factory["name"], Data.slot_count(factory["id"])], TEXT, 15)
	_row(card, "Taşınan tezgah", "%d / %d" % [game.machines.size() - move_sell.size(), game.machines.size()], TEXT, 15)
	_row(card, "Üretim durur", "%d ay" % game.move_months(), RED, 15)
	_row(card, "Çıkış bedeli (%d kira)" % Data.EXIT_FEE_RENTS, Data.usd(float(costs["exit"])), TEXT, 14)
	_row(card, "Taşıma bedeli", Data.usd(float(costs["transport"])), TEXT, 14)
	if float(costs["sale"]) > 0.0:
		_row(card, "Satılan tezgahlardan gelir", "-" + Data.usd(float(costs["sale"])), GREEN, 14)
	_row(card, "Yeni aylık kira (12 ay)", Data.usd(float(factory["rent"])), TEXT, 14)
	_row(card, "Şimdi çıkacak", Data.usd(float(costs["total"])), GOLD, 17)
	if not equipment_plan["deficit"].is_empty() or not equipment_plan["surplus"].is_empty():
		var equip_card := _card(content, "Ekipman ayrıştırması", BORDER)
		equip_card.add_child(_label("Eldeki ekipman tek tek sayılır: yeni fabrikanın listesi için eksik olanlar alınır, fazlası ek ekipman olarak kalır.", 12, MUTED))
		for id in equipment_plan["deficit"]:
			_row(equip_card, "%s: %d adet alınır" % [Data.EQUIPMENT[id]["name"], equipment_plan["deficit"][id]], Data.usd(float(Data.EQUIPMENT[id]["price"]) * float(equipment_plan["deficit"][id])), TEXT, 13)
		for id in equipment_plan["surplus"]:
			_row(equip_card, "%s: %d adet fazla kalır" % [Data.EQUIPMENT[id]["name"], equipment_plan["surplus"][id]], "ek", MUTED, 13)
	if excess > 0:
		var pick_card := _card(content, "Küçülüyorsun: %d tezgah sat" % excess, RED)
		pick_card.add_child(_label("Yeni yerde %d yuva var. Satacağın tezgahları sen seç; kalanlarla devam edersin, satılanların personeli düşer." % Data.slot_count(factory["id"]), 12, MUTED))
		for machine in game.machines:
			var check := CheckBox.new()
			check.text = "%s · %s %s · satış %s" % [machine["model"], Data.LEVELS[int(machine["level"])], machine["kind"], Data.usd(game.sale_income(machine))]
			check.add_theme_font_size_override("font_size", _fs(14))
			check.custom_minimum_size = Vector2(0, 46)
			check.button_pressed = move_sell.has(machine["uid"])
			check.toggled.connect(func(on: bool) -> void:
				if on and not move_sell.has(machine["uid"]):
					move_sell.append(machine["uid"])
				elif not on:
					move_sell.erase(machine["uid"])
				_render_keep_scroll())
			pick_card.add_child(check)
	var reason: String = game.move_block_reason(factory["id"], 12, false, move_sell)
	if reason != "":
		content.add_child(_label(reason, 13, RED))
	content.add_child(_button(("Sat ve taşın" if move_sell.size() > 0 else "Taşın") if reason == "" else "Taşınılamaz", _ask_move.bind(factory["id"]), reason == "", reason != "", true))

func _ask_move(id: String) -> void:
	var factory := Data.factory_by_id(id)
	var costs: Dictionary = game.move_cost(id, move_sell)
	var lines: Array = [
		"%s → %s" % [game.factory()["name"], factory["name"]],
		"%d tezgah taşınır; üretim %d ay durur, personel ücretleri sürer." % [game.machines.size() - move_sell.size(), game.move_months()],
		"Şimdi çıkacak: %s (çıkış %s, taşıma %s, ek ekipman %s%s)." % [Data.usd(float(costs["total"])), Data.usd(float(costs["exit"])), Data.usd(float(costs["transport"])), Data.usd(float(costs["extra_set"])), (", satıştan -" + Data.usd(float(costs["sale"]))) if move_sell.size() > 0 else ""]]
	_confirm("Taşınma onayı", lines, "Taşın", _move_factory.bind(id), "Bu işlem geri alınamaz; taşınma süresince işler bekler.")

func _move_factory(id: String) -> void:
	var result: String = game.move_factory(id, 12, false, move_sell)
	if result != "":
		_say(result)
		_render()
		return
	_say(game.notice)
	move_sell = []
	detail = ""
	page = "ozet"
	subtab["ozet"] = "genel"
	_render()

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
	if fee <= 0.0:
		box.add_child(_label("Sözleşmenin son ayındasın: çıkış bedeli yok. Makineler ve ekipman kaybolur.", 14, GREEN))
	else:
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

const KIND_PICTURE_SUFFIX := "_icon_new"

# One machine, laid out exactly like the design file (tezgah_detay.pptx): photo and specs, capacity / maintenance / energy /
# condition rows with their formulas, and the selling price with the Sat button.
func _detail_machine(uid: int) -> void:
	var machine: Dictionary = game.machine_by_uid(uid)
	if machine.is_empty():
		content.add_child(_label("Bu tezgah artık yok.", 14, MUTED))
		return
	var c := DesignCanvas.new()
	c.setup(Vector2(27, 0), 452.0, 508.0, 464.0)
	content.add_child(c)
	var delivered: bool = int(machine["arrive"]) <= game.month
	var mults: Dictionary = game.problem_mults(game.loss_fractions())
	c.picture(Art.machine_photo(machine["kind"], int(machine["level"]), float(machine["condition"])), 37, 9, 244, 183, Color.WHITE, true, 9.0)
	c.text(318, 9, 150, "%s Tezgahı" % machine["kind"], 14.0, DesignCanvas.TEXT)
	c.text(318, 27, 150, "T-%02d\n%s" % [int(machine.get("slot", 0)) + 1, machine["model"]], 9.0, DesignCanvas.AMBER, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 36.0)
	c.picture(Art.find("res://art/ui/" + Art.slug(machine["kind"]) + KIND_PICTURE_SUFFIX), 288, 14, 29, 28)
	var power_text := ("%.1f kW" % float(machine["power"])).replace(".", ",") if machine.has("power") else "—"
	var area_text := ("%d m2 x %s m" % [int(machine["area"]), str(machine["height"]).replace(".", ",")]) if machine.has("area") else "—"
	var specs := [
		["tasarim/detay_seviye", 62, "Seviye", Data.LEVELS[int(machine["level"])]],
		["tasarim/detay_kondisyon", 90, "Kondisyon", "%% %d" % int(roundf(float(machine["condition"])))],
		["tasarim/detay_motor", 118, "Motor Gücü", power_text],
		["tasarim/detay_tolerans", 146, "Tolerans", Data.tolerance_text(float(machine.get("precision", 0.1))) if machine.has("precision") else "—"],
		["tasarim/detay_alan", 174, "Gerekli Alan", area_text]]
	for spec in specs:
		c.icon(spec[0], 301, float(spec[1]), 15, 14, DesignCanvas.MUTED)
		c.text(318, float(spec[1]) - 4.0, 100, spec[2], 9.0, DesignCanvas.MUTED, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 18.0)
		c.text(373, float(spec[1]) - 4.0, 100, spec[3], 9.0, DesignCanvas.TEXT, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 18.0)
	c.line(37, 208, 427)
	var output: float = game.machine_output(machine, mults) if delivered else 0.0
	var energy: float = game.machine_energy(machine) * game.shift_equiv(machine)
	var rows := [
		[225, "tasarim/detay_kapasite", "Kapasite", "Teorik × vardiya × verim", "%d Vardiya" % int(machine["shifts"]), "%s/ay" % _xfmt(output), DesignCanvas.GREEN],
		[271, "tasarim/detay_bakim", "Bakım Gideri", "Fiyat × bakım oranı", "Aylık, sabit", "−" + Data.usd(game.machine_maintenance(machine)), DesignCanvas.RED],
		[318, "tasarim/detay_enerji", "Enerji Gideri", "Motor gücü × vardiya", "Çalışmaya bağlı", "−" + Data.usd(energy), DesignCanvas.RED]]
	for row in rows:
		var y: float = float(row[0])
		c.icon(row[1], 37, y, 28, 28, DesignCanvas.MUTED)
		c.text(75, y + 4.0, 95, row[2], 9.0, DesignCanvas.MUTED, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 18.0)
		c.text(171, y + 4.0, 146, row[3], 8.0, DesignCanvas.MUTED, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 18.0)
		c.text(318, y + 4.0, 90, row[4], 9.0, DesignCanvas.AMBER, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 18.0)
		c.text(400, y + 4.0, 73, row[5], 9.0, row[6], HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 18.0)
	c.line(37, 259, 429)
	c.line(37, 311, 429)
	c.line(37, 353, 429)
	c.icon("tasarim/detay_kondisyon", 41, 364, 24, 21, DesignCanvas.MUTED)
	c.text(75, 364, 95, "Kondisyon", 9.0, DesignCanvas.MUTED, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 18.0)
	c.text(171, 364, 146, "Yılda −10 puan", 8.0, DesignCanvas.MUTED, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 18.0)
	c.text(318, 364, 90, "Aylık değişim", 9.0, DesignCanvas.AMBER, HORIZONTAL_ALIGNMENT_LEFT, "Regular", 18.0)
	c.text(400, 364, 73, "−0,8 puan", 9.0, DesignCanvas.RED, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 18.0)
	c.line(37, 399, 427)
	c.text(200, 414, 122, "Güncel Satış Fiyatı", 11.0, DesignCanvas.TEXT, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 21.0)
	c.text(323, 411, 81, Data.usd(game.sale_income(machine)).replace("$", "$ "), 16.0, DesignCanvas.GREEN, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 27.0)
	var sell_reason: String = game.sell_block_reason(uid)
	c.button(418, 409, 54, 45, "Sat", func() -> void:
		if sell_reason != "":
			_say(sell_reason)
			_render()
		else:
			_ask_sell(uid), 12.0, sell_reason == "")
	c.text(232, 436, 91, "Değer × %%%d satış oranı" % int(Data.SALE_RATE * 100.0), 8.0, DesignCanvas.MUTED, HORIZONTAL_ALIGNMENT_RIGHT, "Regular", 18.0)
	if delivered:
		var extra := _card(content, "", BORDER)
		_boost_controls(extra, machine)
		extra.add_child(_label("Vardiya ve mesai Fabrika > Vardiya bölümünden ayarlanır.", 12, MUTED))

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
			_boost_controls(box, machine)
			box.add_child(_label("Vardiya ve mesai Fabrika > Vardiya bölümünden ayarlanır.", 12, MUTED))
		var reason: String = game.sell_block_reason(machine["uid"])
		box.add_child(_button("Sat · +%s" % Data.usd(game.sale_income(machine)) if reason == "" else reason, _ask_sell.bind(machine["uid"]), false, reason != ""))

# Per-machine speed-up: a tick opens a slider; the price is more scrap, maintenance and energy.
func _boost_controls(box: Control, machine: Dictionary) -> void:
	var uid: int = machine["uid"]
	var check := CheckButton.new()
	check.text = "Çalışma hızını yükselt"
	check.button_pressed = int(machine.get("boost", 0)) > 0
	check.add_theme_font_size_override("font_size", _fs(14))
	check.toggled.connect(func(on: bool) -> void:
		game.set_boost(uid, 10 if on else 0)
		_render_keep_scroll())
	box.add_child(check)
	if int(machine.get("boost", 0)) <= 0:
		return
	_slider_row(box, "Hız", 1, Data.BOOST_MAX, int(machine["boost"]), func(v: int, shown: Label) -> void:
		shown.text = "+%%%d" % v
		if int(machine.get("boost", 0)) != v:
			game.set_boost(uid, v))
	var b: float = game.machine_boost(machine)
	box.add_child(_label("Hurda ×%s · bakım ×%s · enerji ×%s" % [str(snappedf(1.0 + Data.BOOST_SCRAP * b, 0.01)).replace(".", ","), str(snappedf(1.0 + Data.BOOST_MAINT * b, 0.01)).replace(".", ","), str(snappedf(1.0 + Data.BOOST_ENERGY * b, 0.01)).replace(".", ",")], 12, GOLD))
	box.add_child(_button("Tüm %s %s tezgahlara uygula" % [Data.LEVELS[int(machine["level"])], machine["kind"]], func() -> void:
		game.set_boost_group(uid, int(machine["boost"]))
		_render_keep_scroll()))

# Photo with rounded corners (the panel's shape clips the picture).
func _rounded_photo(texture: Texture2D, size: Vector2, radius := 14) -> Control:
	var frame := PanelContainer.new()
	frame.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	frame.custom_minimum_size = size
	frame.add_theme_stylebox_override("panel", _box(PANEL_ALT, PANEL_ALT, radius, 0))
	var rect := TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(rect)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return frame

# A small line-icon + value chip (cyan icon, white value) used on the plant rows.
func _icon_value(icon_name: String, value: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var icon := _icon_rect(icon_name, 21)
	if icon != null:
		icon.modulate = CYAN
		row.add_child(icon)
	row.add_child(_label(value, 14, TEXT, false))
	return row

# Closed plant listing: photo, name and district, rent on the right, then floor, slots, height and contract in icons.
func _factory_row(factory: Dictionary) -> Control:
	var box := _card(content, "", BORDER)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	var texture: Texture2D = Art.find("res://art/factories/" + String(factory["id"]))
	if texture != null:
		top.add_child(_rounded_photo(texture, Vector2(112, 96)))
	var names := VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	names.add_child(_label(String(factory["name"]), 18, TEXT, false))
	names.add_child(_label(String(factory["region"]), 13, MUTED, false))
	top.add_child(names)
	top.add_child(_rich("[right][color=#2fd17b][b]%s[/b][/color] /ay[/right]" % Data.usd(float(factory["rent"])), 16))
	box.add_child(top)
	var chips := HBoxContainer.new()
	chips.add_theme_constant_override("separation", 6)
	chips.add_child(_icon_value("fabrika_zemin", "%d m²" % int(factory["m2"])))
	chips.add_child(_icon_value("fabrika_slot", "%d slot" % Data.slot_count(factory["id"])))
	chips.add_child(_icon_value("fabrika_cati", ("%.1f m" % float(factory["height"])).replace(".0 m", " m").replace(".", ",")))
	chips.add_child(_icon_value("fabrika_sozlesme", "12 Ay"))
	box.add_child(chips)
	return box

var log_filter := "Tümü"

# Every event of the game, newest first, with a category filter.
func _detail_log() -> void:
	var options: Array = [{"id": "Tümü", "title": "Tümü"}]
	for category in ShellBoss.LOG_CATEGORIES:
		options.append({"id": category, "title": category})
	_chips(content, options, log_filter, func(id: String) -> void:
		log_filter = id
		_render())
	var box := _card(content, "", BORDER, true)
	var shown := 0
	for i in range(game.event_log.size() - 1, -1, -1):
		var entry: Dictionary = game.event_log[i]
		if log_filter != "Tümü" and entry["category"] != log_filter:
			continue
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var when := _label(Data.date_text(int(entry["month"]), int(entry["day"])).get_slice(" ", 0) + " " + Data.date_text(int(entry["month"]), int(entry["day"])).get_slice(" ", 1), 11, FAINT, false)
		when.custom_minimum_size = Vector2(62, 0)
		row.add_child(when)
		var text := _label(String(entry["text"]), 13, TEXT)
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text)
		if absf(float(entry["amount"])) > 0.0005:
			row.add_child(_label(Data.usd(float(entry["amount"])), 13, GREEN if float(entry["amount"]) > 0.0 else RED, false))
		box.add_child(row)
		shown += 1
		if shown >= 150:
			break
	if shown == 0:
		box.add_child(_label("Bu filtrede kayıt yok.", 13, MUTED))

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

# Free cash: what the cash is already promised to (material with its due month, the month's expenses) and what comes in.
func _detail_cash() -> void:
	var com: Dictionary = game.commitments()
	var box := _card(content, "Serbest nakit nereden gelir?", BORDER, true)
	_row(box, "Nakit", Data.usd(float(com["cash"])), TEXT, 15)
	var material := 0.0
	for job in game.jobs:
		var order: Dictionary = job.get("order", {})
		var amount := 0.0
		var when := ""
		if order.is_empty():
			if bool(job.get("fason", false)):
				continue
			amount = float(job["material"]) * float(Data.supplier_by_id(game.default_supplier)["price"])
			when = "sipariş edilmedi (tahmini)"
		elif not bool(order["paid"]):
			amount = float(order["amount"])
			when = "vade: %s" % Data.month_label(int(order["pay_month"])).get_slice(" · ", 0)
		else:
			continue
		material += amount
		_row(box, "Hammadde · %s" % job["title"], "%s · %s" % [Data.usd(amount), when], GOLD, 13)
	_row(box, "Ödenecek hammadde", Data.usd(material), GOLD, 15)
	_row(box, "Bu ayın gideri", Data.usd(float(com["expense"])), GOLD, 15)
	_row(box, "Serbest nakit", Data.usd(float(com["free"])), GREEN if float(com["free"]) >= 0.0 else RED, 17)
	var finance_now: float = game.finance_due()
	if finance_now > 0.0:
		_row(box, "Finansman gideri (ay sonu)", Data.usd(finance_now), RED, 14)
	box.add_child(_label("Nakit borcun altına inerse açığın aylık %%%d'si finansman gideri olarak ay sonunda düşer." % int(game.FINANCE_RATE * 100.0), 12, MUTED))
	var first: Dictionary = com["first"]
	if not first.is_empty():
		var soonest := {}
		var finish: Dictionary = game.projection_days()
		for job in game.jobs:
			var due_when: Array = finish.get(job["id"], [])
			if not due_when.is_empty() and int(due_when[0]) == int(first["month"]) and int(due_when[1]) == int(first["day"]):
				soonest = job
				break
		if not soonest.is_empty():
			_row(box, "Beklenen ilk tahsilat", "%s · %s · %s" % [soonest["title"], Data.usd(float(soonest["revenue"]) - game.job_received(soonest)), Data.month_label(int(first["month"])).get_slice(" · ", 0)], GREEN, 13)
	else:
		box.add_child(_label("Henüz tahsilat bekleyen iş yok.", 12, MUTED))
	box.add_child(_label("Serbest nakit = nakit − ödenecek hammadde − bu ayın gideri. Peşinat ve hakediş zaten nakde girdi veya teslimde gelir; serbest nakde sayılmaz.", 12, MUTED))

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
