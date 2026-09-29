extends SceneTree

const GameState = preload("res://scripts/game_state.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://main.tscn")
	var ui: Control = scene.instantiate()
	root.add_child(ui)
	if ui.body == null or ui.body.get_child_count() < 3:
		_fail("Initial Godot interface did not build")
		return
	var game = GameState.new()
	for month in range(3):
		if not game.work_month("cnc", "rest"):
			_fail("Career month %d failed" % month)
			return
	if not game.found_factory():
		_fail("Factory founding failed")
		return
	if not game.accept_offer("buyuk"):
		_fail("Factory job acceptance failed")
		return
	if game.report["expected"] != 100 or game.report["realized"] != 80.0:
		_fail("First report differs from the Python fixture")
		return
	# FRZ-001: Planlama 31 reaches T1; the T2 root is hidden and is the only
	# possible hidden Tier at small scale, so its gap label is shown.
	var hidden_row := {}
	for row in game.active_rows():
		if row["id"] == "planning_1":
			hidden_row = row
	if hidden_row.is_empty() or hidden_row["visible"] or hidden_row["chance"] != "Yüksek":
		_fail("Hidden single-Tier row should show the inferable gap label")
		return
	if hidden_row["estimate"] != 5.0 or hidden_row["upper"] != 20.0:
		_fail("Hidden row should use the shared hidden estimate and scale upper guarantee")
		return
	if GameState.chance_for_gap(1) != 0.8 or GameState.chance_for_gap(2) != 0.4 or GameState.chance_for_gap(4) != 0.05:
		_fail("Below-threshold chance must follow missing Tier steps")
		return
	var weak = GameState.new()
	weak.skills["Planlama"] = 20
	var weak_root: Dictionary = weak._new_problem("Planlama", 1, 5.0)
	var weak_quote: Dictionary = weak.quote_for(weak_root)
	if weak.chance_text(weak_root) != "Belirsiz" or weak_quote["estimate"] != 2.0 or weak_quote["upper"] != 20.0:
		_fail("With two possible hidden Tiers the row must not leak its Tier")
		return
	if not game.fix("planning_1"):
		_fail("Hidden problem could not be attempted")
		return
	if not game.finish_month():
		_fail("Factory month could not finish")
		return
	for month in range(2):
		if not game.accept_offer("buyuk") or not game.finish_month():
			_fail("Factory month %d failed" % (month + 2))
			return
	if game.phase != "end" or game.history.size() < 7:
		_fail("The six-month game slice did not reach its end screen")
		return
	var report: Array = game.closing_report()
	if report.size() < 2 or game.lesson() == "":
		_fail("Closing report should explain every root and give a lesson")
		return
	ui._wake_up()
	ui._select_job("cnc")
	ui._work()
	if ui.game.career_month != 2:
		_fail("The Godot UI action did not advance career time")
		return
	# Drive every screen through the UI so each renderer runs at least once.
	ui._restart()
	for month in range(3):
		ui._select_job("lider" if month == 2 else "cnc")
		ui._select_secondary(0 if month == 2 else 1)
		ui._work()
	ui._found()
	for month in range(3):
		ui._accept_offer("buyuk")
		for row in ui.game.active_rows():
			ui._fix(row["id"])
		ui._finish_month()
	if ui.game.phase != "end":
		_fail("The UI walkthrough did not reach the closing report")
		return
	print("Godot smoke: UI loaded; six-month flow, hidden-row rules, closing report and button action passed")
	quit(0)

func _fail(message: String) -> void:
	printerr("Godot smoke failed: " + message)
	quit(1)
