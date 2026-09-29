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
		ui._act(ui.game.finish_month())
	if ui.game.phase != "end" or ui.game.closure.is_empty() or ui.game.lessons().is_empty():
		_fail("Boss run did not reach the closing report")
		return
	print("Boss smoke: setup budget, opening reserve, %d months, fixes, consultants and closing report passed (%s)" % [ui.game.month, ui.game.closure["type"]])
	quit(0)

func _fail(message: String) -> void:
	printerr("Boss smoke failed: " + message)
	quit(1)
