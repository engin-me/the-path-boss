extends SceneTree

# Walks the mobile factory shell: tabs, rent/prepay, equipment package, machine
# purchase with delivery, multi-machine jobs, credit with mortgage, exit fee.

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
	var Data = shell.Data
	for tab in ["ozet", "isler", "tezgah", "fabrika", "profil"]:
		shell._on_tab(tab)
		if shell.content.get_child_count() == 0:
			return _fail("Empty page: " + tab)
	# data shape
	if Data.machine_listings().size() < 10:
		return _fail("At least 10 machine listings are required")
	var offers: Array = Data.generate_offers(1)
	var by_count := {1: 0, 2: 0, 3: 0, 4: 0}
	for offer in offers:
		by_count[offer["count"]] += 1
		if offer["share"] < 0.3 - 0.0001 or offer["share"] > 0.75 + 0.0001:
			return _fail("Material share out of 30-75%")
	if offers.size() != 20 or by_count != {1: 9, 2: 5, 3: 4, 4: 2}:
		return _fail("Offer mix must be 20 = 9x1, 5x2, 4x3, 2x4 machines: " + str(by_count))
	if absf(Data.cost_share(4, 3, 0.0) - 0.30) > 0.001 or absf(Data.cost_share(1, 1, 0.0) - 0.75) > 0.001:
		return _fail("Cost share endpoints must be 30% and 75%")
	if Data.usd(1285.0) != "$1.285.000" or Data.list_price("Dövme", 2) != 300.0 or Data.list_price("Torna", 2) != 80.0:
		return _fail("Currency or price averages")
	# rent 12 months with prepay: cash drops by half-term discounted rent, ceza only in confirm
	shell._open_detail("factory", "harbor")
	shell._pick_term(12)
	shell._toggle_prepay(true)
	var cash0: float = shell.state["cash"]
	shell._ask_rent("harbor")
	if shell.overlay.get_child_count() == 0:
		return _fail("Renting must ask for confirmation")
	shell._confirm_yes()
	var quote: Dictionary = shell._prepay_quote(Data.factory_by_id("harbor"), 12)
	if shell.state["factory_id"] != "harbor" or absf(cash0 - quote["amount"] - shell.state["cash"]) > 0.001 or shell.state["prepaid_months"] != 6:
		return _fail("Prepaid rent should be charged and recorded")
	# machines need the package; jobs blocked until then
	shell.state["cash"] = 1000.0  # test convenience: rent prepay already verified above
	shell._buy(0)  # Torna Standart, new -> delivered after 2 months
	shell._buy(3)  # Freze Standart, new -> delivered after 2 months
	if shell._delivered().size() != 0:
		return _fail("New machines must not be delivered immediately")
	shell._ask_package()
	shell._confirm_yes()
	if not shell.state["package"]:
		return _fail("Package purchase failed")
	for i in 2:
		shell._end_month()
	if shell._delivered().size() != 2:
		return _fail("Machines should arrive after their delivery months")
	if shell._capacity_total() <= 0:
		return _fail("Delivered machines with the package must give capacity")
	# find a doable single-machine job and accept it
	var accepted := false
	for offer in shell.state["offers"]:
		if offer["count"] == 1 and shell._assign(offer["reqs"])["ok"] and shell._first_payment(offer) <= shell.state["cash"]:
			shell._ask_accept(offer["id"])
			shell._confirm_yes()
			accepted = true
			break
	if not accepted:
		return _fail("Expected at least one doable one-machine offer for the bought park")
	if shell.state["accepted"].size() != 1 or shell._free_machines().size() != 1:
		return _fail("Accepting a job must reserve its machine")
	# area preview
	shell.subtab["tezgah"] = "tezgah"
	shell._on_tab("tezgah")
	shell.selected_listing = 3
	shell._update_area_preview()
	if shell.area_preview_bar.value <= shell.area_used_bar.value:
		return _fail("Selecting a machine must show a yellow area preview")
	# credit needs collateral
	shell._open_detail("credit")
	shell._toggle_collateral(true, shell.state["machines"][0]["uid"])
	shell._toggle_collateral(true, shell.state["machines"][1]["uid"])
	var picked := 0.0
	for machine in shell.state["machines"]:
		if shell.collateral_picks.has(machine["uid"]):
			picked += shell._current_value(machine)
	if picked >= 125.0:
		var before: float = shell.state["cash"]
		shell._take_credit()
		if absf(shell.state["cash"] - before - 100.0) > 0.001 or shell.state["credit"].is_empty():
			return _fail("Credit must pay out the principal")
		shell._end_month()
		if shell.state["credit"]["left"] != 11:
			return _fail("Installment should reduce the remaining term")
		shell._close_credit()
		if not shell.state["credit"].is_empty():
			return _fail("Early close must clear the credit")
	# leaving early costs two rents
	var cash_before: float = shell.state["cash"]
	var fee: float = shell._base_rent() * 2.0
	shell._open_detail("leave")
	shell._leave_factory(fee)
	if absf(cash_before - fee - shell.state["cash"]) > 0.001 or shell.state["factory_id"] != "":
		return _fail("Leaving early must charge two rents")
	for screen in ["consultant", "credit"]:
		shell._on_tab("profil")
		shell._open_detail(screen)
		shell._back()
	print("Shell smoke passed")
	quit(0)
