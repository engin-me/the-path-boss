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
	for tab in ["ozet", "ilanlar", "mail", "fabrika", "profil"]:
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
		if offer["share"] < 0.01 or offer["share"] > 0.80:
			return _fail("Material share out of 1-80%")
		for req in offer["reqs"]:
			if req["parts"] <= 0 or absf(float(req["parts"]) * float(req["difficulty"]) - float(req["workload"])) > 0.01:
				return _fail("workload must equal parts x difficulty")
	if offers.size() != 20 or by_count != {1: 9, 2: 5, 3: 4, 4: 2}:
		return _fail("Offer mix must be 20 = 9x1, 5x2, 4x3, 2x4: " + str(by_count))
	if Data.usd(1285.0) != "$1.285.000" or Data.list_price("Dövme", 2) != 150.0 or Data.list_price("Torna", 2) != 75.0:
		return _fail("Currency or price averages")
	# ---- OEE formula: a new Manuel Torna, one shift, no problems -> power x 1500 x 1/3 x (1 - scrap)
	var probe: Dictionary = Data.machine_listings()[0].duplicate()
	probe["shifts"] = 1
	probe["patron"] = false
	probe["arrive"] = 0
	var clean: Dictionary = game.problem_mults({"A": 0.0, "P": 0.0, "Q": 0.0, "N": 0.0})
	var steps: Dictionary = game.machine_steps(probe, clean)
	var full: float = float(probe["power"]) * Data.KW_CAPACITY
	if not _near(float(probe["nameplate"]), full, 0.01) or not _near(steps["net"], full / 3.0 * (1.0 - float(probe["scrap"])), 0.01):
		return _fail("One-shift new Manuel Torna must give power x 1500 / 3 x (1 - scrap): %s" % str(steps))
	probe["shifts"] = 3
	if not _near(game.machine_steps(probe, clean)["net"], full * (1.0 - float(probe["scrap"])), 0.01):
		return _fail("Three shifts must triple the one-shift output")
	# ---- condition: every missing 10 points costs 5 percent capacity, more energy, maintenance and scrap
	var worn: Dictionary = Data.machine_listings()[12].duplicate()
	worn["shifts"] = 1
	worn["patron"] = false
	worn["arrive"] = 0
	var worn_steps: float = Data.condition_steps(float(worn["condition"]))
	if not _near(float(worn["nameplate"]), float(worn["base_nameplate"]) * (1.0 - 0.05 * worn_steps), 0.01):
		return _fail("Capacity must fall 5 percent per missing 10 points")
	if game.machine_energy(worn) <= float(worn["energy"]) or game.machine_maintenance(worn) <= 0.0 or game.machine_scrap(worn) <= float(worn["scrap"]):
		return _fail("A worn machine must cost more energy, maintenance and scrap")
	if float(Data.machine_listings()[0]["precision"]) != 0.1 or float(Data.machine_listings()[2]["precision"]) != 0.001:
		return _fail("Precision per level is 0.1 / 0.01 / 0.001 mm")
	# ---- nothing before renting
	if game.buy_listing(0) == "" or game.buy_package() == "":
		return _fail("Purchases must be refused before renting")
	# ---- rent Harbor (medium) with prepaid half term and a confirmation
	shell._open_detail("factory", "factory_5")
	shell._pick_term(12)
	shell._toggle_prepay(true)
	game.cash = 300.0   # the default 24k start is too thin for a medium plant's hidden-fix guarantee
	var cash0: float = game.cash
	shell._ask_rent("factory_5")
	if shell.overlay.get_child_count() == 0:
		return _fail("Renting must ask for confirmation")
	shell._confirm_yes()
	var quote: Dictionary = game.prepay_quote("factory_5", 12)
	if game.factory_id != "factory_5" or not _near(cash0 - quote["amount"], game.cash, 0.001) or game.prepaid_months != 6:
		return _fail("Prepaid rent should be charged and recorded")
	var poor = Boss.new()
	poor.default_setup(1)
	poor.cash = 30.0
	if poor.rent_block_reason("factory_9", 12, false) == "":
		return _fail("Renting a large plant with 30 units must be refused")
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
	# ---- factory shift plan: every machine follows it; overtime is +0.5 shift at 1.5x pay and never with three shifts
	var plan_game = Boss.new()
	plan_game.default_setup(9)
	plan_game.cash = 2000.0
	plan_game.rent_factory("factory_1", 12, false)
	plan_game.buy_package()
	plan_game.buy_listing(13)
	plan_game.run_report()
	plan_game.close_month()
	plan_game.problems.clear()
	var plan_machine: Dictionary = plan_game.delivered()[0]
	var plan_base: float = plan_game.effective_capacity()
	if plan_game.set_plan(2, [false, false, false], false) != "" or int(plan_machine["shifts"]) != 2 or not _near(plan_game.effective_capacity() / plan_base, 2.0, 0.01):
		return _fail("A two-shift plan must run every machine on two shifts")
	if plan_game.set_plan(3, [true, true, true], false) != "" or plan_game.plan_ot.has(true) or int(plan_machine["shifts"]) != 3:
		return _fail("Three shifts must clear every overtime tick")
	plan_game.set_plan(2, [true, true, false], false)
	if not _near(plan_game.shift_equiv(plan_machine), 3.0, 0.001):
		return _fail("Two shifts with overtime equal 3 shift-equivalents")
	var crews := float(plan_machine["personnel"])
	if not _near(plan_game.machine_wages(plan_machine), (Data.wage_for(plan_machine["kind"]) * (1.0 + Data.OT_HOURS_SHARE * Data.OT_WAGE_MULT) + plan_game.staff_cost_per_head()) * crews * 2.0, 0.001):
		return _fail("Overtime hours must cost 1.5x the wage")
	var plan_copy = Boss.new()
	if plan_copy.from_save(plan_game.to_save()) != "" or plan_copy.plan_shifts != 2 or not bool(plan_copy.plan_ot[1]):
		return _fail("The shift plan must survive the save round trip")
	# ---- the realisation floor holds for heavy physical problems too (A, P and Q at their caps)
	var heavy: Dictionary = plan_game.problem_mults({"A": 0.6, "P": 0.2, "Q": 0.2, "N": 0.3})
	if float(heavy["phys"]) * float(heavy["non"]) < 0.33 - 0.0001:
		return _fail("The 33 percent realisation floor must hold for heavy physical problems: %.3f" % (float(heavy["phys"]) * float(heavy["non"])))
	# ---- leaving the plant drops running jobs like abandoning them: advances come back, penalties apply
	var exit_game = Boss.new()
	exit_game.default_setup(12)
	exit_game.cash = 2000.0
	exit_game.rent_factory("factory_1", 12, false)
	exit_game.buy_package()
	exit_game.buy_listing(13)
	exit_game.run_report()
	exit_game.close_month()
	var offer_for_exit: Dictionary = exit_game.offers[0]
	exit_game.accept_offer(offer_for_exit["id"])
	var cash_before_exit: float = exit_game.cash
	var advance_taken: float = exit_game.advance_of(offer_for_exit)
	var exit_costs: Dictionary = exit_game.leave_job_costs()
	if int(exit_costs["jobs"]) != 1 or float(exit_costs["refund"]) < advance_taken - 1.0:
		return _fail("Leaving must hand back the advance of every running job")
	exit_game.leave_factory()
	if exit_game.cash > cash_before_exit - exit_game.leave_fee() - advance_taken * 1.0 + 0.5:
		return _fail("Leaving with running jobs must not keep their advances")
	# ---- waiting reasons and the "can do" filter do not depend on the phase of the month
	var wait_game = Boss.new()
	wait_game.default_setup(21)
	wait_game.cash = 2000.0
	wait_game.rent_factory("factory_1", 12, false)
	wait_game.buy_package()
	wait_game.buy_listing(13)
	wait_game.run_report()
	wait_game.close_month()
	var fit_id := -1
	for candidate in wait_game.offers:
		if wait_game.fit_block_reason(candidate["id"]) == "":
			fit_id = int(candidate["id"])
			break
	if fit_id < 0:
		return _fail("An offer that fits the Torna must exist for this check")
	wait_game.accept_offer(fit_id)
	var waiting_job: Dictionary = wait_game.jobs[0]
	if wait_game.job_wait_reason(waiting_job) == "" and int(waiting_job["order"]["arrive_month"]) > wait_game.month:
		return _fail("A job waiting for material must say why")
	wait_game.run_report()
	for candidate in wait_game.offers:
		if wait_game.fit_block_reason(candidate["id"]) == "" and wait_game.accept_block_reason(candidate["id"]) == "":
			return _fail("During the report the phase, not the fit, must block accepting")
	# ---- a higher level machine serves lower-level work but at its own energy and write-off
	var basis_low: Dictionary = plan_game.serving_basis("Torna", 1)
	var basis_exact: Dictionary = plan_game.serving_basis("Torna", int(plan_machine["level"]))
	if int(basis_low["level"]) != int(plan_machine["level"]) or not _near(float(basis_low["price"]), float(plan_machine["price"]), 0.001):
		return _fail("A Torna Hassas must serve Standart work with its own price")
	if not _near(float(basis_exact["energy"]), float(basis_low["energy"]), 0.001):
		return _fail("Serving lower-level work must cost the serving machine's energy")
	if not _near(plan_game.monthly_amortization(), float(plan_machine["price"]) / float(Data.AMORT_MONTHS), 0.001):
		return _fail("Monthly write-off is price / 120")
	# ---- job scrap: drawn inside the table range, charged at delivery
	var plan_offer: Dictionary = plan_game.offers[0]
	var estimate: Dictionary = plan_game.cost_estimate(plan_offer)
	for line in estimate["lines"]:
		var span: Array = line["scrap_range"]
		if float(line["scrap_rate"]) < float(span[0]) - 0.0001 or float(line["scrap_rate"]) > float(span[1]) + 0.0001:
			return _fail("The scrap estimate must sit inside the table range")
	# ---- FIFO workload and on-time delivery
	var fresh = Boss.new()
	fresh.default_setup(5)
	fresh.cash = 1500.0
	fresh.rent_factory("factory_1", 12, false)
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
	p2.rent_factory("factory_1", 12, false)
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
	# ---- phase 3: quotes, hidden urgency, yes/no counters, delivery score
	var q = Boss.new()
	q.default_setup(91)
	q.cash = 1500.0
	q.rent_factory("factory_5", 12, false)
	q.buy_package()
	q.buy_listing(13)
	q.buy_listing(14)
	q.run_report()
	q.close_month()
	q.run_report()
	q.close_month()
	q.problems.clear()
	var doable: Array = []
	for candidate in q.offers:
		if q.accept_block_reason(candidate["id"]) == "":
			doable.append(candidate)
	if doable.size() < 4:
		return _fail("Need at least four doable offers for the quote test")
	var o1: Dictionary = doable[0]
	var low_u: Dictionary = o1.duplicate(true)
	var high_u: Dictionary = o1.duplicate(true)
	low_u["urgency"] = 1
	high_u["urgency"] = 10
	if q.customer_limit(high_u, 30, int(o1["months"])) <= q.customer_limit(low_u, 30, int(o1["months"])):
		return _fail("An urgent customer must tolerate a higher price")
	var keep_score: float = q.delivery_score
	var limit_ok: float = q.customer_limit(o1, 30, int(o1["months"]))
	q.delivery_score = 0.1
	if q.customer_limit(o1, 30, int(o1["months"])) >= limit_ok:
		return _fail("A weak delivery score must lower the price the customer accepts")
	q.delivery_score = keep_score
	if q.customer_limit(o1, 50, int(o1["months"])) >= limit_ok or q.customer_limit(o1, 30, int(o1["months"]) + 1) >= limit_ok:
		return _fail("A bigger advance or a later delivery must lower the accepted price")
	# accepted: price at or below the limit
	var cash_q: float = q.cash
	var win: Dictionary = q.submit_quote(o1["id"], floorf(limit_ok), 30, int(o1["months"]))
	if not win["ok"] or win["status"] != "accepted" or q.jobs.size() != 1 or q.offer_by_id(o1["id"]) != {}:
		return _fail("A quote within the limit must be accepted: " + str(win))
	if q.cash - cash_q < floorf(limit_ok) * 0.3 - 1.0:
		return _fail("The advance must be paid on acceptance")
	if q.submit_quote(o1["id"], 10.0, 30, 3)["ok"]:
		return _fail("Only one quote per offer")
	# counter: within 10% above the limit, then yes/no
	var o2: Dictionary = doable[1]
	var limit2: float = q.customer_limit(o2, 30, int(o2["months"]))
	var cn: Dictionary = q.submit_quote(o2["id"], limit2 * 1.05, 30, int(o2["months"]))
	if cn["status"] != "counter" or float(cn["mail"]["price"]) > limit2 + 0.5:
		return _fail("A price slightly above the limit must get a counter at or below the limit")
	var jobs_before: int = q.jobs.size()
	if q.answer_counter(cn["mail"]["id"], true) != "" or q.jobs.size() != jobs_before + 1:
		return _fail("Saying yes to a counter must create the job")
	# no: the deal is lost
	var o3: Dictionary = doable[2]
	var cn3: Dictionary = q.submit_quote(o3["id"], q.customer_limit(o3, 30, int(o3["months"])) * 1.05, 30, int(o3["months"]))
	if q.answer_counter(cn3["mail"]["id"], false) != "" or q.jobs.size() != jobs_before + 1 or q.mail_by_id(cn3["mail"]["id"])["status"] != "declined":
		return _fail("Saying no must end the negotiation")
	# reject: far above the limit; the note reveals the customer's cost
	var o4: Dictionary = doable[3]
	var rj: Dictionary = q.submit_quote(o4["id"], q.customer_limit(o4, 30, int(o4["months"])) * 1.6, 30, int(o4["months"]))
	var note_text := "\n".join(rj["mail"]["lines"])
	if rj["status"] != "rejected" or not note_text.contains("tahmini maliyet"):
		return _fail("A rejection must explain the customer's cost estimate")
	# counters left unanswered expire at month end
	var leftover: Dictionary = {}
	for candidate in q.offers:
		if q.accept_block_reason(candidate["id"]) == "":
			leftover = candidate
			break
	if not leftover.is_empty():
		var cn5: Dictionary = q.submit_quote(leftover["id"], q.customer_limit(leftover, 30, int(leftover["months"])) * 1.05, 30, int(leftover["months"]))
		q.run_report()
		q.close_month()
		if q.mail_by_id(cn5["mail"]["id"])["status"] != "expired":
			return _fail("An unanswered counter must expire")
	# quote screens render
	shell._reset_state(4)
	shell.game.cash = 1200.0
	shell.game.rent_factory("factory_5", 12, false)
	shell.game.buy_package()
	shell.game.buy_listing(13)
	shell.game.run_report()
	shell.game.close_month()
	shell.game.run_report()
	shell.game.close_month()
	var quote_offer: Dictionary = {}
	for candidate in shell.game.offers:
		if shell.game.accept_block_reason(candidate["id"]) == "":
			quote_offer = candidate
			break
	if quote_offer.is_empty():
		return _fail("Expected a doable offer for the quote screens")
	shell.subtab["ilanlar"] = "isler"
	shell._on_tab("ilanlar")
	shell._open_detail("quote", str(quote_offer["id"]))
	if shell.content.get_child_count() < 3:
		return _fail("Quote screen did not render")
	shell._send_quote(quote_offer["id"])
	shell._on_tab("mail")
	if shell.game.mails.is_empty() or shell.content.get_child_count() < 2:
		return _fail("Sending a quote must create a mail and show it")
	shell._open_mail(shell.game.mails[0]["id"])
	if shell.content.get_child_count() < 2 or not shell.game.mails[0]["read"]:
		return _fail("Opening a mail must render it and mark it read")
	shell.job_filters = ["Torna", "Freze"]
	shell.job_sort = "hassas"
	shell.subtab["ilanlar"] = "isler"
	shell._on_tab("ilanlar")
	shell.job_filters = []
	shell.subtab["ilanlar"] = "tezgah"
	shell._on_tab("ilanlar")
	shell.subtab["fabrika"] = "isler"
	shell._on_tab("fabrika")
	shell.subtab["fabrika"] = "tedarik"
	shell._on_tab("fabrika")
	# ---- top-down factory view: the plan picture with one slot per machine
	shell._reset_state(8)
	shell.game.cash = 1500.0
	shell.game.rent_factory("factory_5", 12, false)
	shell.game.buy_package()
	for uid in [13, 14, 17, 16]:
		shell.game.buy_listing(uid)
	shell.game.buy_equipment("forklift", 1)
	shell.subtab["fabrika"] = "yerlesim"
	shell._on_tab("fabrika")
	var plan_view = shell.floor_view
	if plan_view == null or plan_view.slots.size() != Data.slot_count("factory_5"):
		return _fail("The floor view must build one slot per plan slot (%d)" % Data.slot_count("factory_5"))
	var seen_slots := {}
	for machine in shell.game.machines:
		var slot := int(machine["slot"])
		if slot < 0 or slot >= plan_view.slots.size() or seen_slots.has(slot):
			return _fail("Every machine needs its own plan slot")
		seen_slots[slot] = true
	for i in Data.PLAN_STEMS.size():
		if Data.plan_slots("factory_%d" % (i + 1)).size() != Data.PLAN_SLOTS[i]:
			return _fail("slots.json must hold %d slots for factory_%d" % [Data.PLAN_SLOTS[i], i + 1])
	plan_view.fit()
	if plan_view.zoom <= 0.0 or plan_view._s(Vector2.ZERO).x < -1.0:
		return _fail("The plan must open fitted to the screen")
	if plan_view.doors.is_empty() or plan_view.equipment.is_empty():
		return _fail("The technical drawing needs ramps and equipment symbols")
	plan_view.day_frac = 0.5
	plan_view.busy = {shell.game.machines[0]["uid"]: true}
	plan_view.plan_output = {shell.game.machines[0]["uid"]: 3000.0}
	plan_view.add_day(5)
	if plan_view.floaters.is_empty() or not str(plan_view.floaters[0]["text"]).begins_with("+"):
		return _fail("A working machine must show its daily output while the clock runs")
	# slots are a hard cap
	var cap_game = Boss.new()
	cap_game.default_setup(9)
	cap_game.cash = 5000.0
	cap_game.rent_factory("factory_1", 12, false)
	cap_game.buy_package()
	var bought := 0
	for uid in [13, 14, 15, 16]:
		if cap_game.buy_listing(uid) == "":
			bought += 1
	if bought != 2 or cap_game.machines.size() != 2:
		return _fail("The smallest plant has two slots (bought %d)" % bought)
	var slot_copy = Boss.new()
	if slot_copy.from_save(cap_game.to_save()) != "" or int(slot_copy.machines[1]["slot"]) != int(cap_game.machines[1]["slot"]):
		return _fail("Machine slots must survive the save round trip")
	shell.subtab["fabrika"] = "sozlesme"
	shell._on_tab("fabrika")
	if shell.floor_view != null or not shell.scroll_view.visible:
		return _fail("The contract tab must show the scrolling page, not the floor")
	shell.subtab["fabrika"] = "yerlesim"
	# ---- abandon and sell
	var g2 = Boss.new()
	g2.default_setup(31)
	g2.cash = 1000.0
	g2.rent_factory("factory_5", 12, false)
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
	g3.rent_factory("factory_5", 12, false)
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
		if g3.take_loan(uids) != "" or not _near(g3.cash - before, float(Data.CREDIT["amount"]), 0.001) or g3.debt < float(Data.CREDIT["amount"]):
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
	shell.game.rent_factory("factory_5", 12, false)
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
	a.rent_factory("factory_1", 12, false)
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
	# ---- regression: fix quotes use the shell money scale, fixed costs split over the plan slots, firm_q delivery terms
	var rg = Boss.new()
	rg.default_setup(21)
	rg.cash = 600.0
	rg.rent_factory("factory_1", 12, false)
	rg.buy_package()
	rg.buy_listing(13)
	for _i in 3:
		rg.run_report()
		rg.close_month()
	for root in rg.problems.values():
		var fix_q: Dictionary = rg.quote_for(root)
		if float(fix_q["upper"]) > float(rg.SHELL_MONEY_BANDS[5][1]) * float(root["factor"]) + 0.01 or float(fix_q["upper"]) < float(fix_q["actual"]) - 0.01 and rg.is_visible(root):
			return _fail("Fix quotes must use the shell money bands: %s" % str(fix_q))
	var line_a: Dictionary = rg.cost_estimate(rg.offers[0])["lines"][0]
	var pool_share: float = float(line_a["overhead"]) / maxf(1.0, float(rg.offers[0]["duration"]))
	if pool_share < rg.plant_fixed_cost() / float(rg.slots_total()) - 0.001:
		return _fail("Fixed costs must be split over the 2 plan slots, not more (share %.3f, pool %.3f)" % [pool_share, rg.plant_fixed_cost()])
	for offer in rg.offers:
		if int(offer["urgency"]) >= 8 and rg.accept_block_reason(offer["id"]) == "":
			offer["urgency"] = 9
			var firm_q: Dictionary = rg.submit_quote(offer["id"], rg.customer_limit(offer, 30, int(offer["months"]) + 1) * 0.5, 30, int(offer["months"]) + 1, rg.MAX_QUOTE_ROUNDS)
			if firm_q["status"] != "rejected":
				return _fail("An urgent customer must refuse a late delivery in the last round")
			break
	# ---- experimental flowing time: runs only while playing, stops for dialogs and at month end, resumes after the report
	shell._reset_state(12)
	shell.game.cash = 2000.0
	shell.game.rent_factory("factory_1", 12, false)
	shell.game.buy_package()
	shell.game.buy_listing(13)
	shell.flow_on = true
	shell._update_clock()
	shell._process(5.0)
	if shell.flow_day != 0.0:
		return _fail("The clock must not run while paused")
	shell._set_flow_speed(2)
	shell._process(6.0)
	if shell.flow_day < 14.9 or shell.flow_day > 15.1 or shell.game.phase != "offers":
		return _fail("2x speed advances 15 days in 6 s (day %.2f)" % shell.flow_day)
	shell._ask_buy(13)
	if shell.flow_speed != 0:
		return _fail("A decision dialog must stop the clock")
	shell._close_overlay()
	shell._set_flow_speed(4)
	shell._process(30.0)
	if shell.game.phase != "report" or shell.flow_speed != 0 or shell.flow_resume != 4:
		return _fail("At day 30 the report opens and the clock stops (phase %s)" % shell.game.phase)
	shell._finish_close_month()
	if shell.flow_day != 0.0 or shell.flow_speed != 4 or shell.game.phase != "offers":
		return _fail("After the report the clock restarts at the same speed")
	shell.flow_on = false
	shell._update_clock()
	# ---- moving to another plant (IDEA-020): production stops for ceil(machines / 10) months, costs are paid, slots follow
	var mv = Boss.new()
	mv.default_setup(14)
	mv.cash = 4000.0
	mv.rent_factory("factory_1", 12, false)
	mv.buy_package()
	mv.buy_listing(13)
	mv.buy_listing(14)
	mv.run_report()
	mv.close_month()
	var cash_before_move: float = mv.cash
	if mv.move_block_reason("factory_1", 12, false) == "" or mv.move_block_reason("factory_3", 12, false) != "":
		return _fail("Moving to the same plant must be refused and to another plant allowed")
	var move_costs: Dictionary = mv.move_cost("factory_3")
	if mv.move_factory("factory_3", 12, false) != "" or mv.factory_id != "factory_3" or not mv.is_moving():
		return _fail("The move must switch the plant and start a stop")
	if mv.cash > cash_before_move - float(move_costs["total"]) + 0.01 or mv.effective_capacity() != 0.0:
		return _fail("A move costs exit and transport money and stops production")
	if int(mv.moving_until) - int(mv.month) != 1 or mv.move_months() != 1:
		return _fail("A move stops production for one month at most")
	var wage_stop: float = mv.moving_wages()
	if wage_stop <= 0.0:
		return _fail("Crews of moving machines stay on the payroll")
	mv.machines = mv.machines + mv.machines + mv.machines + mv.machines + mv.machines
	if mv.move_months() != 1:
		return _fail("Even many machines move in one month")
	# downsizing: machines beyond the new slots must be sold, the player picks which
	var dn = Boss.new()
	dn.default_setup(16)
	dn.cash = 6000.0
	dn.rent_factory("factory_3", 12, false)
	dn.buy_package()
	for uid in [13, 14, 15, 16]:
		dn.buy_listing(uid)
	if dn.machines.size() != 4 or dn.move_excess("factory_1") != 2:
		return _fail("Moving 4 machines into 2 slots leaves an excess of 2")
	if dn.move_block_reason("factory_1", 12, false) == "":
		return _fail("A downsizing move without selling must be refused")
	var picks: Array = [dn.machines[1]["uid"], dn.machines[3]["uid"]]
	var stays: int = dn.machines[0]["uid"]
	if dn.move_block_reason("factory_1", 12, false, picks) != "" or dn.move_factory("factory_1", 12, false, picks) != "":
		return _fail("Selling the excess machines must allow the move: " + dn.move_block_reason("factory_1", 12, false, picks))
	if dn.machines.size() != 2 or dn.machine_by_uid(stays).is_empty() or int(dn.machines[1]["slot"]) != 1:
		return _fail("Only the unsold machines move, into the first slots")
	if dn.equipment_owned("raf") < int(Data.package_for(150)["items"]["raf"]):
		return _fail("The smaller plant keeps at least its own equipment list")
	shell._reset_state(15)
	shell.game.cash = 2000.0
	shell.game.rent_factory("factory_1", 12, false)
	shell._open_detail("factory", "factory_3")
	if shell.content.get_child_count() < 3:
		return _fail("The move screen did not render")
	shell._ask_move("factory_3")
	shell._confirm_no()
	shell.subtab["fabrika"] = "sozlesme"
	shell._back()
	shell._on_tab("fabrika")
	print("Shell smoke passed")
	quit(0)
