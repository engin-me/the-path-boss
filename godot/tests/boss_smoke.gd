extends SceneTree

# Drives the boss-only test screen through setup, investment, every month and
# the closing report so each renderer and rule path runs at least once.

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ui: Control = load("res://boss.tscn").instantiate()
	root.add_child(ui)
	if ui.body == null or ui.body.get_child_count() < 3:
		_fail("Boss setup screen did not build")
		return
	var State = load("res://scripts/boss_state.gd")
	if absf(State.chance_for_points(89, 90) - 0.96) > 0.001 or absf(State.chance_for_points(70, 90) - 0.20) > 0.001 or State.chance_for_points(20, 90) != 0.05 or State.chance_for_points(90, 90) != 1.0:
		_fail("Per-point chance must drop 4% per missing point with a 5% floor")
		return
	if State.field_cap("Finans", "") != 30 or State.field_cap("Üretim", "") != 70 or State.field_cap("Planlama", "") != 50 or State.field_cap("Depo & Sevkiyat", "isletme") != 100 or State.field_cap("Finans", "muhendislik") != 30:
		_fail("Diploma caps do not match the draft table")
		return
	var capped = State.new()
	if capped.configure({"Finans": 60}, 600, 400.0, "Test", 1, "") == "":
		_fail("A score above the diploma cap must be refused without clamping")
		return
	ui._set_skill(100, "Üretim")
	if not ui.start_button.disabled:
		_fail("Budget overflow should disable the start button")
		return
	ui._set_skill(60, "Üretim")
	ui._apply_persona(1)
	ui._start()
	if ui.game.phase != "invest" or ui.game.skill_total() > ui.game.budget:
		_fail("Persona setup failed")
		return
	ui._act(ui.game.open_factory({"A": 9}))
	if ui.game.phase != "invest":
		_fail("Opening without the cash reserve must be refused")
		return
	ui._act(ui.game.open_factory(ui.machine_counts))
	if ui.game.phase != "offers":
		_fail("Factory did not open")
		return
	var growth_checked := false
	while ui.game.phase == "offers":
		for index in ui.game.offers.size():
			var trial: Array = ui.selected_jobs.duplicate()
			trial.append(index)
			if ui.game.selection_problem(trial) == "":
				ui._toggle_job(true, index)
		ui._accept()
		if ui.game.phase != "report":
			_fail("Month %d could not start" % ui.game.month)
			return
		if ui.game.candidates.size() > 0 and ui.game.hire_block_reason(0) == "":
			ui._act(ui.game.hire(0))
		for department in ui.game.SKILLS:
			for row in ui.game.active_rows(department):
				if row["blocked"] == "":
					ui._act_fix(row["id"])
		var before := {}
		for id in ui.game.problems:
			if ui.game.problems[id]["active"]:
				before[id] = ui.game.problems[id]["loss"]
		ui._act(ui.game.finish_month())
		for id in before:
			var root: Dictionary = ui.game.problems[id]
			if root["active"]:
				if root["loss"] < before[id] or root["loss"] > root["base_loss"] * 2.0 + 0.001:
					_fail("Unsolved problem loss must grow and stay under twice its start")
					return
				growth_checked = growth_checked or root["loss"] > before[id]
	if not growth_checked:
		_fail("No unsolved problem grew during the run")
		return
	if ui.game.phase != "end" or ui.game.closure.is_empty() or ui.game.lessons().is_empty():
		_fail("Boss run did not reach the closing report")
		return
	print("Boss smoke: chance curve, diploma caps, growth, setup budget, opening reserve, %d months, fixes, consultants and closing report passed (%s)" % [ui.game.month, ui.game.closure["type"]])
	quit(0)

func _fail(message: String) -> void:
	printerr("Boss smoke failed: " + message)
	quit(1)
