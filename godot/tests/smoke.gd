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
	ui._select_job("cnc")
	ui._work()
	if ui.game.career_month != 2:
		_fail("The Godot UI action did not advance career time")
		return
	print("Godot smoke: UI loaded; six-month flow, hidden fix and button action passed")
	quit(0)

func _fail(message: String) -> void:
	printerr("Godot smoke failed: " + message)
	quit(1)
