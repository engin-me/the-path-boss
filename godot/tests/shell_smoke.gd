extends SceneTree

# Walks the mobile factory shell on the real ShellBoss engine: rent (prepaid),
# equipment package, machine orders and delivery, machine-holding jobs, report
# efficiency scaling revenue, Düzelt through BossState, mortgage loan, exit fee.

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
	shell._reset_state(11)
	shell._render()
	var Data = shell.Data
	var game = shell.game
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
	# nothing before renting
	if game.buy_listing(0) == "" or game.buy_package() == "":
		return _fail("Purchases must be refused before renting")
	# rent Harbor (medium) 12 months with prepaid half term; confirm dialog then charge
	shell._open_detail("factory", "harbor")
	shell._pick_term(12)
	shell._toggle_prepay(true)
	var cash0: float = game.cash
	shell._ask_rent("harbor")
	if shell.overlay.get_child_count() == 0:
		return _fail("Renting must ask for confirmation")
	shell._confirm_yes()
	var quote: Dictionary = game.prepay_quote("harbor", 12)
	if game.factory_id != "harbor" or absf(cash0 - quote["amount"] - game.cash) > 0.001 or game.prepaid_months != 6:
		return _fail("Prepaid rent should be charged and recorded")
	if game.phase != "offers":
		return _fail("After renting the month starts in the offers phase")
	# the opening guarantee must forbid renting when cash is too low
	var poor = shell.ShellBoss.new()
	poor.default_setup(1)
	poor.cash = 100.0
	if poor.rent_block_reason("ironvalley", 12, false) == "":
		return _fail("Renting a large plant with 100 units must be refused")
	# top up for the rest of the flow (test convenience)
	game.cash = 1000.0
	if game.buy_listing(0) != "" or game.buy_listing(3) != "":
		return _fail("Ordering two new machines failed: " + game.notice)
	if game.delivered().size() != 0:
		return _fail("New machines must not be delivered immediately")
	if game.buy_package() != "":
		return _fail("Package purchase failed")
	# no capacity, no problems yet; report and close two months
	for i in 2:
		if game.run_report() != "" or game.close_month() != "":
			return _fail("Month cycle failed at month %d: %s" % [game.month, game.notice])
	if game.delivered().size() != 2 or game.capacity_at_least(1) != 80:
		return _fail("Both machines should be delivered after two months (capacity 80)")
	# one-machine job reserves a machine
	var chosen: Dictionary = {}
	for offer in game.offers:
		if offer["count"] == 1 and game.accept_block_reason(offer["id"]) == "":
			chosen = offer
			break
	if chosen.is_empty():
		return _fail("Expected a doable one-machine offer for the bought park")
	var revenue: float = chosen["revenue"]
	var months: int = chosen["months"]
	game.problems.clear()  # isolate: full efficiency
	if game.accept_offer(chosen["id"]) != "":
		return _fail("Accept failed: " + game.notice)
	if game.jobs.size() != 1 or game.free_machines().size() != 1:
		return _fail("Accepting a job must reserve its machine")
	if game.accept_offer(chosen["id"]) == "":
		return _fail("The same offer must not be accepted twice")
	# efficiency reduces revenue: inject a physical problem and compare
	var cash_before: float = game.cash
	for m in months:
		game.problems.clear()
		if m == 0:
			game.problems["k99"] = {"department": "Bakım", "tier": 1, "loss": 8.0, "base_loss": 8.0, "active": true, "attempted": 0,
				"scale_tier": 4, "factor": 1.5, "actual_money": 12.0, "actual_hours": 2, "total_loss": 0.0, "ever_seen": false, "solved_month": 0, "born": game.month}
		if game.run_report() != "":
			return _fail("Report failed")
		if m == 0:
			if game.report["efficiency"] >= 1.0 or game.report["oee"] >= 1.0:
				return _fail("A physical problem must lower efficiency and OEE")
			# Düzelt goes through BossState: T1 with 60 skill is certain
			var rows: Array = game.active_rows("Bakım")
			if rows.is_empty() or game.fix("k99")["ok"] != true:
				return _fail("Düzelt should work on the injected row")
			shell._on_tab("ozet")
			shell.subtab["ozet"] = "dep"
			shell._render()
			shell.subtab["ozet"] = "rapor"
			shell._render()
		game.close_month()
	if game.jobs.size() != 0 or game.free_machines().size() != 2:
		return _fail("A finished job must release its machines")
	if game.cash - cash_before >= revenue:
		return _fail("With a lost month the delivered revenue must be below the full revenue")
	# area preview
	shell.subtab["tezgah"] = "tezgah"
	shell._on_tab("tezgah")
	shell.selected_listing = 3
	shell._update_area_preview()
	if shell.area_preview_bar.value <= shell.area_used_bar.value:
		return _fail("Selecting a machine must show a yellow area preview")
	# mortgage loan needs collateral of 125% and releases on early close
	shell._open_detail("credit")
	var uids: Array = []
	for machine in game.delivered():
		uids.append(machine["uid"])
	if game.loan_block_reason(uids.slice(0, 1)) == "" and game.current_value(game.delivered()[0]) < 125.0:
		return _fail("One cheap machine must not be enough collateral")
	if game.loan_block_reason(uids) == "":
		var before: float = game.cash
		if game.take_loan(uids) != "" or absf(game.cash - before - 100.0) > 0.001 or game.debt < 100.0:
			return _fail("Loan must pay out and add debt")
		if game.run_report() != "" or game.close_month() != "" or game.loan["left"] != 11:
			return _fail("Installment should reduce the remaining term")
		if game.leave_block_reason() == "":
			return _fail("Leaving with an active loan must be refused")
		if game.close_loan() != "" or not game.loan.is_empty():
			return _fail("Early close must clear the loan")
	# leaving early costs two rents
	var cash_pre: float = game.cash
	var fee: float = game.leave_fee()
	if game.leave_factory() != "" or absf(cash_pre - fee - game.cash) > 0.001 or game.factory_id != "":
		return _fail("Leaving early must charge two rents")
	for screen in ["consultant", "credit"]:
		shell._on_tab("profil")
		shell._open_detail(screen)
		shell._back()
	print("Shell smoke passed")
	quit(0)
