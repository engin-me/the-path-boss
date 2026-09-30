extends SceneTree

# Walks the mobile factory shell: every tab, the rent/buy/accept/leave flow.

func _initialize() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error(message)
	print("Shell smoke FAILED: ", message)
	quit(1)

func _run() -> void:
	var shell: Control = load("res://factory_shell.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	for tab in ["ozet", "isler", "tezgah", "fabrika", "profil"]:
		shell._on_tab(tab)
		if shell.content.get_child_count() == 0:
			return _fail("Empty page: " + tab)
	# Locked before renting.
	shell._on_tab("tezgah")
	if shell.state["machines"]["A"] != 0 or shell._machine_count() != 0:
		return _fail("Machines must start at zero")
	# Rent the small workshop for 12 months.
	shell._open_detail("factory", "kucuk")
	shell._pick_term(12)
	shell._rent_factory("kucuk")
	if shell.state["factory_id"] != "kucuk" or shell.page != "ozet":
		return _fail("Renting must open the summary")
	# Buy: A fits height 4.0; C (4.5 m) must not.
	shell._buy("A")
	shell._buy("A")
	if shell._capacity_total() != 80 or shell._area_used() != 50:
		return _fail("Two A machines should give 80 capacity and 50 m2")
	# Accept two jobs at once, within capacity.
	shell._accept_offer(1)
	shell._accept_offer(4)
	if shell._capacity_used() != 60 or shell.state["accepted"].size() != 2:
		return _fail("Multiple jobs must be accepted within capacity")
	shell._on_tab("isler")
	shell._end_month()
	if shell.state["month"] != 2 or shell.state["accepted"].size() != 0:
		return _fail("One-month jobs should deliver after the month ends")
	# Leave early: fee is 2 rents.
	var cash_before: float = shell.state["cash"]
	var fee: float = shell._rent() * 2.0
	shell._open_detail("leave")
	shell._leave_factory(fee)
	if absf(cash_before - fee - shell.state["cash"]) > 0.001 or shell.state["factory_id"] != "":
		return _fail("Leaving early must charge two rents")
	if shell.Data.usd(1285.0) != "$1.285.000":
		return _fail("USD format")
	for screen in ["consultant", "credit"]:
		shell._on_tab("profil")
		shell._open_detail(screen)
		shell._back()
	print("Shell smoke passed")
	quit(0)
