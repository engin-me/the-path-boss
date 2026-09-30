extends SceneTree

# Mobile factory shell on the ShellBoss engine: rent (prepaid), equipment gate,
# machine orders, shifts/OEE/performance/scrap, FIFO workload, late delivery score,
# abandon/sell, mortgage loan, exit fee, save round trip.

func _initialize() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error(message)
	print("Shell smoke FAILED: ", message)
	quit(1)

func _near(a: float, b: float, tolerance := 0.5) -> bool:
	return absf(a - b) <= tolerance

func _run() -> void:
	var shell: Control = load("res://factory_shell.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	shell._reset_state(11)
	shell._render()
	var Data = shell.Data
	var Boss = shell.ShellBoss
	var game = shell.game
	for tab in ["ozet", "isler", "tezgah", "fabrika", "profil"]:
		shell._on_tab(tab)
		if shell.content.get_child_count() == 0:
			return _fail("Empty page: " + tab)
	# ---- data shape
	if Data.machine_listings().size() < 10:
		return _fail("At least 10 machine listings are required")
	var offers: Array = Data.generate_offers(1)
	var by_count := {1: 0, 2: 0, 3: 0, 4: 0}
	for offer in offers:
		by_count[offer["count"]] += 1
		if offer["share"] < 0.3 - 0.0001 or offer["share"] > 0.75 + 0.0001:
			return _fail("Material share out of 30-75%")
		for req in offer["reqs"]:
			if req["parts"] <= 0 or absf(float(req["parts"]) * float(req["difficulty"]) - float(req["workload"])) > 0.01:
				return _fail("workload must equal parts x difficulty")
	if offers.size() != 20 or by_count != {1: 9, 2: 5, 3: 4, 4: 2}:
		return _fail("Offer mix must be 20 = 9x1, 5x2, 4x3, 2x4: " + str(by_count))
	if Data.usd(1285.0) != "$1.285.000" or Data.list_price("Dövme", 2) != 300.0 or Data.list_price("Torna", 2) != 80.0:
		return _fail("Currency or price averages")
	# ---- OEE formula: Standart Torna, one shift, no problems -> 2000 x 1/3 x 0.70 x 0.97
	var probe: Dictionary = Data.machine_listings()[0].duplicate()
	probe["shifts"] = 1
	probe["patron"] = false
	probe["arrive"] = 0
	var clean: Dictionary = game.problem_mults({"A": 0.0, "P": 0.0, "Q": 0.0, "N": 0.0})
	var steps: Dictionary = game.machine_steps(probe, clean)
	if not _near(steps["net"], 2000.0 / 3.0 * 0.70 * 0.97, 0.01) or not _near(steps["net"] / 2000.0, 0.2263, 0.0005):
		return _fail("One-shift Standart Torna must be ~22.6%% OEE: %s" % str(steps))
	probe["shifts"] = 3
	if not _near(game.machine_steps(probe, clean)["net"], 2000.0 * 0.70 * 0.97, 0.01):
		return _fail("Three shifts must be ~68%%")
	# ---- nothing before renting
	if game.buy_listing(0) == "" or game.buy_package() == "":
		return _fail("Purchases must be refused before renting")
	# ---- rent Harbor (medium) with prepaid half term and a confirmation
	shell._open_detail("factory", "harbor")
	shell._pick_term(12)
	shell._toggle_prepay(true)
	var cash0: float = game.cash
	shell._ask_rent("harbor")
	if shell.overlay.get_child_count() == 0:
		return _fail("Renting must ask for confirmation")
	shell._confirm_yes()
	var quote: Dictionary = game.prepay_quote("harbor", 12)
	if game.factory_id != "harbor" or not _near(cash0 - quote["amount"], game.cash, 0.001) or game.prepaid_months != 6:
		return _fail("Prepaid rent should be charged and recorded")
	var poor = Boss.new()
	poor.default_setup(1)
	poor.cash = 100.0
	if poor.rent_block_reason("ironvalley", 12, false) == "":
		return _fail("Renting a large plant with 100 units must be refused")
	# ---- machines, equipment gate, delivery
	game.cash = 1000.0
	if game.buy_listing(13) != "" or game.buy_listing(14) != "":
		return _fail("Ordering two machines failed: " + game.notice)
	if game.delivered().size() != 0 or game.effective_capacity() != 0.0:
		return _fail("Ordered machines must not produce")
	# offers can be accepted while machines are still on the way (future start)
	game.buy_package()
	var early: Dictionary = {}
	for offer in game.offers:
		if game.accept_block_reason(offer["id"]) == "":
			early = offer
			break
	if early.is_empty():
		return _fail("Expected a doable offer while machines are in transit")
	if game.accept_offer(early["id"]) != "":
		return _fail("Accepting while in transit failed: " + game.notice)
	for i in 2:
		if game.run_report() != "" or game.close_month() != "":
			return _fail("Month cycle failed at month %d: %s" % [game.month, game.notice])
	if game.delivered().size() != 2 or game.effective_capacity() <= 0.0:
		return _fail("Both machines should be delivered and produce")
	if game.patron_machine().is_empty():
		return _fail("The solo patron should run the first single-operator machine")
	# ---- shifts triple output; patron overtime respects the hidden-fix hour guarantee
	game.problems.clear()
	var one_shift: float = game.effective_capacity()
	for machine in game.delivered():
		game.set_shifts(machine["uid"], 3)
	if not _near(game.effective_capacity() / one_shift, 3.0, 0.01):
		return _fail("Three shifts must triple the output")
	for machine in game.delivered():
		game.set_shifts(machine["uid"], 1)
	if game.set_overtime(true) == "":
		return _fail("Overtime on a medium plant must be refused (hidden-fix hour guarantee)")
	# ---- FIFO workload and on-time delivery
	var fresh = Boss.new()
	fresh.default_setup(5)
	fresh.cash = 1500.0
	fresh.rent_factory("ridgeway", 12, false)
	fresh.buy_package()
	fresh.buy_listing(13)
	fresh.run_report()
	fresh.close_month()
	fresh.run_report()
	fresh.close_month()
	fresh.problems.clear()
	var cap_month: float = fresh.effective_capacity("Torna")
	var req_a := {"kind": "Torna", "level": 1, "count": 1, "parts": 100, "difficulty": 1.0, "workload": cap_month * 0.8, "remaining": cap_month * 0.8}
	var req_b := {"kind": "Torna", "level": 1, "count": 1, "parts": 100, "difficulty": 1.0, "workload": cap_month * 0.8, "remaining": cap_month * 0.8}
	var base_job := {"elapsed": 0, "accepted_month": fresh.month, "start_month": fresh.month, "produced": 0.0, "yield": 1.0, "revenue": 50.0, "material": 10.0, "advance": 0.0,
		"order": {"supplier": "nord", "order_month": 0, "arrive_month": 0, "pay_month": 0, "amount": 0.0, "paid": true, "delayed": false},
		"months": 2, "customer": "Test", "title": "Test"}
	var job_a: Dictionary = base_job.duplicate(true)
	job_a["id"] = 9001
	job_a["reqs"] = [req_a]
	job_a["due_month"] = fresh.month
	var job_b: Dictionary = base_job.duplicate(true)
	job_b["id"] = 9002
	job_b["reqs"] = [req_b]
	job_b["due_month"] = fresh.month
	fresh.jobs = [job_a, job_b]
	fresh.run_report()
	if float(job_a["reqs"][0]["remaining"]) > 0.5 or not (float(job_b["reqs"][0]["remaining"]) > 0.5):
		return _fail("FIFO: the first job must be served before the second")
	var score_before: float = fresh.delivery_score
	fresh.close_month()  # job A done this month (on time), job B still running (late next)
	if fresh.delivery_score <= score_before:
		return _fail("An on-time delivery must raise the score")
	fresh.problems.clear()
	var score_mid: float = fresh.delivery_score
	fresh.run_report()
	fresh.close_month()  # job B finishes after its due month -> late
	if fresh.delivery_score >= score_mid or not fresh.jobs.is_empty():
		return _fail("A late delivery must lower the score and finish the job")
	# ---- phase 2: advance, supplier orders, payment terms, quality yield
	var p2 = Boss.new()
	p2.default_setup(77)
	p2.cash = 1500.0
	p2.rent_factory("ridgeway", 12, false)
	p2.buy_package()
	p2.buy_listing(13)
	p2.run_report()
	p2.close_month()
	p2.run_report()
	p2.close_month()
	p2.problems.clear()
	p2.auto_order = false
	var pick: Dictionary = {}
	for candidate in p2.offers:
		if p2.accept_block_reason(candidate["id"]) == "":
			pick = candidate
			break
	if pick.is_empty():
		return _fail("Expected a doable offer for the supplier test")
	var cash_p: float = p2.cash
	if p2.accept_offer(pick["id"]) != "":
		return _fail("Accept failed: " + p2.notice)
	var advance: float = p2.advance_of(pick)
	if not _near(p2.cash - cash_p, advance, 0.001) or not _near(advance, pick["revenue"] * 0.30, 1.0):
		return _fail("Acceptance must bring a 30%% advance")
	var job_p: Dictionary = p2.jobs[0]
	p2.run_report()
	if float(job_p["produced"]) > 0.0:
		return _fail("A job without a material order must not be produced")
	p2.close_month()
	# order from Atlas (cash on order) and from a slow supplier; arrival and payment follow the terms
	var atlas_quote: Dictionary = p2.material_quote(job_p, "atlas")
	var cash_o: float = p2.cash
	if p2.order_material(job_p["id"], "atlas") != "" or not _near(cash_o - atlas_quote["amount"], p2.cash, 0.001):
		return _fail("Atlas is cash on order")
	if int(job_p["order"]["arrive_month"]) < p2.month + 1 or not job_p["order"]["paid"] or not _near(job_p["yield"], 1.015, 0.0001):
		return _fail("Order must arrive after the lead time, be paid and set the premium yield")
	if p2.order_material(job_p["id"], "nord") == "":
		return _fail("A job can be ordered only once")
	var before_arrival: float = job_p["produced"]
	p2.run_report()
	if int(job_p["order"]["arrive_month"]) > p2.month and float(job_p["produced"]) != before_arrival:
		return _fail("No production before the material arrives")
	p2.close_month()
	var terms_quote: Dictionary = p2.material_quote(job_p, "pacific")
	if int(terms_quote["terms"]) != 2 or int(terms_quote["lead"]) != 2:
		return _fail("Pacific Alloy has a 2-month lead and 2-month terms")
	# ---- abandon and sell
	var g2 = Boss.new()
	g2.default_setup(31)
	g2.cash = 1000.0
	g2.rent_factory("harbor", 12, false)
	g2.buy_package()
	g2.buy_listing(13)
	g2.buy_listing(14)
	g2.run_report()
	g2.close_month()
	g2.run_report()
	g2.close_month()
	var take: Dictionary = {}
	for candidate in g2.offers:
		if g2.accept_block_reason(candidate["id"]) == "":
			take = candidate
			break
	if take.is_empty():
		return _fail("Expected a doable offer for the abandon test")
	g2.accept_offer(take["id"])
	var cash_a: float = g2.cash
	var penalty: float = g2.abandon_penalty(g2.jobs[0])
	var refund: float = g2.jobs[0]["advance"]
	var score_a: float = g2.delivery_score
	if g2.abandon_job(g2.jobs[0]["id"]) != "" or not _near(cash_a - penalty - refund, g2.cash, 0.001) or not g2.jobs.is_empty() or g2.delivery_score >= score_a:
		return _fail("Abandoning must refund the advance, charge the penalty, drop the job and lower the score")
	var sell_uid: int = g2.machines[0]["uid"]
	var income: float = g2.sale_income(g2.machine_by_uid(sell_uid))
	var cash_b: float = g2.cash
	g2.run_report()
	if g2.sell_machine_uid(sell_uid) != "" or not _near(g2.cash - cash_b, income, 0.001) or g2.machines.size() != 1:
		return _fail("Selling must pay the sale income")
	# ---- mortgage loan: collateral 125%, installments, early close, no sale while mortgaged
	var g3 = Boss.new()
	g3.default_setup(41)
	g3.cash = 1200.0
	g3.rent_factory("harbor", 12, false)
	g3.buy_package()
	g3.buy_listing(0)
	g3.buy_listing(3)
	g3.buy_listing(13)
	for i in 3:
		g3.run_report()
		g3.close_month()
	var uids: Array = []
	for machine in g3.delivered():
		uids.append(machine["uid"])
	if g3.loan_block_reason(uids.slice(0, 1)) == "":
		return _fail("One machine must not be enough collateral")
	if g3.loan_block_reason(uids) == "":
		var before: float = g3.cash
		if g3.take_loan(uids) != "" or not _near(g3.cash - before, 100.0, 0.001) or g3.debt < 100.0:
			return _fail("Loan must pay out and add debt")
		if g3.sell_block_reason(uids[0]) == "":
			return _fail("A mortgaged machine must not be sellable")
		g3.run_report()
		g3.close_month()
		if g3.loan["left"] != 11 or g3.leave_block_reason() == "":
			return _fail("Installments and the exit block must work")
		if g3.close_loan() != "" or not g3.loan.is_empty():
			return _fail("Early close must clear the loan")
	# ---- exit fee
	var cash_pre: float = g3.cash
	var fee: float = g3.leave_fee()
	if g3.leave_factory() != "" or not _near(cash_pre - fee, g3.cash, 0.001) or g3.factory_id != "":
		return _fail("Leaving early must charge two rents")
	# ---- summary details render
	shell._reset_state(2)
	shell.game.cash = 900.0
	shell.game.rent_factory("harbor", 12, false)
	shell.game.buy_package()
	shell.game.buy_listing(13)
	for kind in ["machines", "oee", "costs"]:
		shell._on_tab("ozet")
		shell._open_detail(kind)
		if shell.content.get_child_count() < 2:
			return _fail("Detail did not render: " + kind)
	shell.game.run_report()
	shell.subtab["ozet"] = "rapor"
	shell._on_tab("ozet")
	if shell.content.get_child_count() < 3:
		return _fail("Report tab did not render")
	# ---- save / load round trip
	var a = Boss.new()
	a.default_setup(21)
	a.rent_factory("ridgeway", 12, false)
	a.buy_package()
	a.buy_listing(13)
	a.buy_listing(14)
	for i in 3:
		a.run_report()
		a.close_month()
	var snapshot: Dictionary = a.to_save()
	var b = Boss.new()
	if b.from_save(snapshot) != "":
		return _fail("Save must load")
	if b.cash != a.cash or b.month != a.month or b.machines.size() != a.machines.size() or b.problems.size() != a.problems.size() or b.delivery_score != a.delivery_score:
		return _fail("Loaded state differs from the saved one")
	for i in 3:
		a.run_report()
		a.close_month()
		b.run_report()
		b.close_month()
	if not _near(a.cash, b.cash, 0.001) or a.problems.size() != b.problems.size() or a.month != b.month:
		return _fail("A loaded game must continue exactly like the original")
	var broken: Dictionary = snapshot.duplicate()
	broken.erase("cash")
	if Boss.new().from_save(broken) == "":
		return _fail("A save with missing fields must be refused")
	if shell.SaveStore.active():
		return _fail("Saving must be off in headless runs")
	print("Shell smoke passed")
	quit(0)
