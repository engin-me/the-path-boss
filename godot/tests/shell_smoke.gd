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
		if (not bool(offer.get("fason", false)) and offer["share"] < 0.01) or offer["share"] > 0.80:
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
	if not _near(game.machine_steps(probe, clean)["net"], full / 3.0 * (Data.shift_efficiency(int(probe["level"]), 1) + Data.shift_efficiency(int(probe["level"]), 2) + Data.shift_efficiency(int(probe["level"]), 3)) * (1.0 - float(probe["scrap"])), 0.01):
		return _fail("Three shifts must add the shift efficiencies of the one-shift output")
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
	var shift_gain := 0.0
	var shift_base := 0.0
	for machine in game.delivered():
		var lvl := int(machine["level"])
		shift_gain += game.shift_yield(machine) * float(machine["nameplate"])
		shift_base += float(machine["nameplate"])
		if not _near(game.shift_yield(machine), Data.shift_efficiency(lvl, 1) + Data.shift_efficiency(lvl, 2) + Data.shift_efficiency(lvl, 3), 0.001):
			return _fail("Three shifts add the shift efficiencies")
	if game.effective_capacity() / one_shift < 1.9 or game.effective_capacity() / one_shift > 3.01:
		return _fail("Three shifts must raise the output by the shift efficiencies")
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
	if plan_game.set_plan(2, [false, false, false], false) != "" or int(plan_machine["shifts"]) != 2 or not _near(plan_game.effective_capacity() / plan_base, 1.0 + Data.shift_efficiency(int(plan_machine["level"]), 2), 0.01):
		return _fail("A two-shift plan must run every machine on two shifts")
	if plan_game.set_plan(3, [true, true, true], false) != "" or plan_game.plan_ot.has(true) or int(plan_machine["shifts"]) != 3:
		return _fail("Three shifts must clear every overtime tick")
	plan_game.set_plan(2, [true, true, false], false)
	if not _near(plan_game.shift_equiv(plan_machine), 3.0, 0.001):
		return _fail("Two shifts with overtime equal 3 shift-equivalents")
	var crews := float(plan_machine["personnel"])
	if not _near(plan_game.machine_wages(plan_machine), (Data.wage_for(plan_machine["kind"]) * (1.0 + Data.OT_HOURS_SHARE * Data.OT_WAGE_MULT) + plan_game.staff_cost_per_head()) * crews * 2.0, 0.001):
		return _fail("Overtime hours must cost 1.5x the wage")
	# ---- IDEA-022: fixed-term crews, severance, expiry
	plan_game.set_plan(1, [false, false, false], false)
	var wage_one: float = plan_game.machine_wages(plan_machine)
	plan_game.set_plan(2, [false, false, false], false, 6)
	var wage_fixed: float = plan_game.machine_wages(plan_machine)
	plan_game.set_plan(1, [false, false, false], false)
	plan_game.set_plan(2, [false, false, false], false, 0)
	var wage_perm: float = plan_game.machine_wages(plan_machine)
	if not wage_fixed > wage_perm or wage_perm <= wage_one:
		return _fail("A fixed-term second crew costs more than a permanent one")
	var sev: float = plan_game.severance_for(1)
	var cash_before: float = plan_game.cash
	plan_game.set_plan(1, [false, false, false], false)
	if sev <= 0.0 or not _near(cash_before - plan_game.cash, sev, 0.001):
		return _fail("Closing a permanent shift pays severance")
	plan_game.set_plan(2, [false, false, false], false, 3)
	if plan_game.severance_for(1) >= sev:
		return _fail("Fixed-term severance is lower than permanent severance")
	plan_game.month = plan_game.plan_contract_end
	plan_game._contract_expiry()
	if plan_game.plan_shifts != 1 or plan_game.plan_contract != 0:
		return _fail("A fixed-term contract closes the extra shift when it ends")
	plan_game.set_plan(2, [true, true, false], false)
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
	if int(job_p["order"]["arrive_month"]) < p2.month or not job_p["order"]["paid"] or not _near(job_p["yield"], 1.015, 0.0001):
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
	if shell.content.get_child_count() < 1:
		return _fail("Quote screen did not render")
	shell._send_quote(quote_offer["id"])
	if shell.game.mails.is_empty() or shell.game.mail_arrived(shell.game.mails[0]):
		return _fail("The customer's answer must exist but travel for a few seconds")
	for mail in shell.game.mails:
		mail.erase("ready_ms")   # fast-forward the wait
	shell._on_tab("mail")
	if shell.content.get_child_count() < 1 or shell.game.unread_mails() < 1:
		return _fail("Once it has arrived the mail shows in the inbox")
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
	shell.game.buy_equipment("forklift_70", 1)
	if shell.game.equipment_kind_owned("forklift") != 2 or not float(Data.EQUIPMENT["forklift_70"]["price"]) < float(Data.EQUIPMENT["forklift"]["price"]):
		return _fail("A second-hand forklift is cheaper and counts as a forklift")
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
	plan_view.add_day({shell.game.machines[0]["uid"]: 120.0})
	if plan_view.floaters.is_empty() or bool(plan_view.floaters[0]["bad"]) or absf(float(plan_view.floaters[0]["amount"]) - 120.0) > 0.01:
		return _fail("A working machine must send its daily good parts to the counter while the clock runs")
	plan_view._process(plan_view.FLIGHT_SECONDS + 0.1)
	if float(plan_view.shown[shell.game.machines[0]["uid"]][0]) < 119.0:
		return _fail("A landed part must raise the good counter")
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
	# ---- acceptance gauge: all sliders at the minimum give 100 percent, a high advance and margin lower it, a higher advance never raises it
	var gauge_game = Boss.new()
	gauge_game.default_setup(24)
	gauge_game.cash = 20000.0
	gauge_game.rent_factory("factory_1", 12, false)
	gauge_game.buy_package()
	gauge_game.buy_listing(13)
	gauge_game.run_report()
	gauge_game.close_month()
	gauge_game.run_report()
	gauge_game.close_month()
	for offer in gauge_game.offers:
		var gauge_cost: float = float(gauge_game.cost_estimate(offer)["total"])
		var months_wanted: int = int(offer["months"])
		var gauge_lowest: float = gauge_game.accept_probability(offer, gauge_cost, 0, 1)["accept"]
		var gauge_heavy: float = gauge_game.accept_probability(offer, gauge_cost * 2.0, 100, months_wanted)["accept"]
		var gauge_p30: float = gauge_game.accept_probability(offer, gauge_cost * 1.3, 30, months_wanted)["accept"]
		var gauge_p60: float = gauge_game.accept_probability(offer, gauge_cost * 1.3, 60, months_wanted)["accept"]
		if gauge_lowest < 0.85 or gauge_heavy > 0.001 or gauge_p60 > gauge_p30 + 0.001:
			return _fail("Gauge: min %.2f, gauge_heavy %.2f, advance 30 %.2f vs 60 %.2f" % [gauge_lowest, gauge_heavy, gauge_p30, gauge_p60])
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
	# ---- contract end: notice mail two months before, silence renews at market rent, a chosen term keeps the rent, last month exits free
	var ce = Boss.new()
	ce.default_setup(17)
	ce.cash = 100000.0
	ce.rent_factory("factory_1", 6, false)
	ce.buy_package()
	var rent_before: float = ce.base_rent()
	if ce.set_renewal(12) == "" or ce.leave_fee() <= 0.0:
		return _fail("Renewal is refused before the notice window and early exit costs money")
	for _i in 4:
		ce.run_report()
		ce.close_month()
	if ce.months_left != 2 or not ce.in_notice_window() or ce.unread_mails() < 1:
		return _fail("Two months before the end the landlord writes (months_left %d)" % ce.months_left)
	ce.run_report()
	ce.close_month()
	if ce.leave_fee() != 0.0 or ce.months_left != 1:
		return _fail("The last month has no exit fee")
	ce.run_report()
	ce.close_month()
	if ce.months_left != 6 or ce.base_rent() <= rent_before * 1.11 or ce.rent_markup <= 0.0:
		return _fail("Silence renews at market rent (%.3f vs %.3f)" % [ce.base_rent(), rent_before])
	var ce2 = Boss.new()
	ce2.default_setup(18)
	ce2.cash = 100000.0
	ce2.rent_factory("factory_1", 6, false)
	ce2.buy_package()
	for _i in 4:
		ce2.run_report()
		ce2.close_month()
	if ce2.set_renewal(24) != "":
		return _fail("Renewal must be possible in the notice window")
	for _i in 2:
		ce2.run_report()
		ce2.close_month()
	if ce2.term != 24 or ce2.months_left != 24 or ce2.rent_markup != 0.0:
		return _fail("A chosen renewal takes the chosen term at today's rent")
	# ---- day by day engine: same production as the monthly shortcut, deliveries and payments on their day
	var dd = Boss.new()
	dd.default_setup(23)
	dd.cash = 20000.0
	dd.rent_factory("factory_3", 12, false)
	dd.buy_package()
	dd.buy_listing(13)
	dd.run_report()
	dd.close_month()
	dd.run_report()
	dd.close_month()
	var dd_offer: Dictionary = {}
	for candidate in dd.offers:
		if dd.fit_block_reason(candidate["id"]) == "":
			dd_offer = candidate
			break
	if dd_offer.is_empty():
		return _fail("Expected a doable offer for the day engine test")
	dd._create_job(dd_offer, 5.0, 0.3, int(dd_offer["months"]) + 2)
	dd.close_month() if dd.phase == "report" else null
	for step in 2:
		dd.run_report()
		dd.close_month()
	var snapshot_day: Dictionary = dd.to_save()
	var monthly = Boss.new()
	monthly.from_save(snapshot_day)
	var daily = Boss.new()
	daily.from_save(snapshot_day)
	if monthly.jobs.is_empty():
		return _fail("The day engine test needs a running job")
	monthly.run_report()
	var guard_days := 0
	while daily.days_run < 30 and guard_days < 40:
		var step_result: Dictionary = daily.advance_day()
		guard_days += 1
		if step_result["month_end"]:
			break
	if daily.day != 30 or daily.days_run != 30:
		return _fail("30 days must be run (day %d, run %d)" % [daily.day, daily.days_run])
	daily.run_report()
	var m_left: float = monthly.job_remaining(monthly.jobs[0])
	var d_left: float = daily.job_remaining(daily.jobs[0]) if not daily.jobs.is_empty() else 0.0
	if absf(m_left - d_left) > maxf(1.0, 0.02 * maxf(m_left, 1.0)):
		return _fail("Daily and monthly production must agree (monthly left %.1f, daily left %.1f)" % [m_left, d_left])
	# a small job is delivered on the day it is done
	var quick = Boss.new()
	quick.from_save(snapshot_day)
	for req in quick.jobs[0]["reqs"]:
		req["remaining"] = 0.4
	var cash_quick: float = quick.cash
	var first_day: Dictionary = quick.advance_day()
	if not quick.jobs.is_empty() or quick.cash <= cash_quick:
		return _fail("A finished job must be delivered on the same day, cash %.1f -> %.1f" % [cash_quick, quick.cash])
	var texts: Array = []
	for event in first_day["events"]:
		texts.append(event["text"])
	if not "\n".join(texts).contains("Teslim"):
		return _fail("The delivery must appear among the day's events")
	if not quick.month_events[0].begins_with("Gün 1:"):
		return _fail("Day events are logged for the closing report")
	# ---- regression: wages accrue day by day, a half-played month cannot skip its missing days, sim counts day-event deliveries
	var wg = Boss.new()
	wg.from_save(snapshot_day)
	wg.set_plan(3, [false, false, false], false)
	var wages3: float = wg.machine_wages(wg.machines[0])
	for _i in 29:
		wg.advance_day()
	wg.set_plan(1, [false, false, false], false)
	wg.advance_day()
	var wages1: float = wg.machine_wages(wg.machines[0])
	var accrued_wages: float = wg.month_running
	if wages3 <= wages1 or accrued_wages < 29.0 / 30.0 * wages3 * 0.99:
		return _fail("Wages must accrue by day (3 shifts x29 days): accrued %.2f, three-shift wage %.2f, one-shift wage %.2f" % [accrued_wages, wages3, wages1])
	var halfway = Boss.new()
	halfway.from_save(snapshot_day)
	var fullmonth = Boss.new()
	fullmonth.from_save(snapshot_day)
	for _i in 15:
		halfway.advance_day()
	halfway.run_report()
	for _i in 30:
		fullmonth.advance_day()
	fullmonth.run_report()
	var half_left: float = halfway.job_remaining(halfway.jobs[0]) if not halfway.jobs.is_empty() else 0.0
	var full_left: float = fullmonth.job_remaining(fullmonth.jobs[0]) if not fullmonth.jobs.is_empty() else 0.0
	if halfway.days_run != 30 or absf(half_left - full_left) > 1.0:
		return _fail("Opening the report mid-month must play the missing days (%.1f vs %.1f)" % [half_left, full_left])
	# ---- old mid-month saves (no month_running) estimate the expenses of the days already played
	var legacy: Dictionary = snapshot_day.duplicate(true)
	legacy["days_run"] = 15
	legacy["day"] = 16
	legacy.erase("month_running")
	var legacy_game = Boss.new()
	if legacy_game.from_save(legacy) != "" or legacy_game.month_running < 0.45 * legacy_game.running_cost() or legacy_game.month_running > 0.55 * legacy_game.running_cost():
		return _fail("A mid-month save without month_running must estimate half a month of expenses (%.3f of %.3f)" % [legacy_game.month_running, legacy_game.running_cost()])
	# ---- the quote forecast and the real delivery agree on the day (job taken late in the month)
	var fc = Boss.new()
	fc.from_save(snapshot_day)
	fc.jobs.clear()
	for _i in 24:
		fc.advance_day()
	var fc_offer: Dictionary = {}
	for candidate in fc.offers:
		if fc.fit_block_reason(candidate["id"]) == "":
			fc_offer = candidate.duplicate(true)
			break
	for req in fc_offer["reqs"]:
		req["remaining"] = float(req["remaining"]) * 0.25   # a small job, so the test stays inside the game's 12 months
		req["workload"] = float(req["workload"]) * 0.25
	var fc_months: int = int(fc_offer["months"]) + 3
	fc._create_job(fc_offer.duplicate(true), 5.0, 0.3, fc_months)
	var fc_job_id: int = int(fc_offer["id"])
	fc.problems.clear()
	var fc_delayed: bool = bool(fc.job_by_id(fc_job_id)["order"].get("delayed", false))
	var forecast: Dictionary = fc.quote_projection(fc_offer, fc_months, fc_delayed)
	var delivered_at := [0, 0]
	for _guard in 400:
		var fc_day: Dictionary = fc.advance_day()
		if fc.job_by_id(fc_job_id).is_empty():
			delivered_at = [fc.month, int(fc_day["day"])]
			break
		if fc_day["month_end"]:
			fc.run_report()
			fc.close_month()
			fc.problems.clear()   # the forecast cannot know about problems born later
	var forecast_index: int = int(forecast["finish"]) * 30 + int(forecast["finish_day"])
	var actual_index: int = int(delivered_at[0]) * 30 + int(delivered_at[1])
	if delivered_at[0] == 0 or absi(forecast_index - actual_index) > 2:   # machine ageing moves it by a day or so
		return _fail("Forecast %s/%s but delivered %s/%s" % [forecast["finish"], forecast["finish_day"], delivered_at[0], delivered_at[1]])
	# ---- advance comfort follows the delivery score, a later delivery is expensive, toll (fason) work carries no material
	var tuning = Boss.new()
	tuning.from_save(snapshot_day)
	tuning.delivery_score = 0.5
	var low_comfort: int = tuning.advance_comfort()
	tuning.delivery_score = 1.0
	if tuning.advance_comfort() <= low_comfort + 15:
		return _fail("A higher delivery score must allow a clearly higher advance")
	var tune_offer: Dictionary = tuning.offers[0]
	var on_time: float = tuning.customer_limit(tune_offer, 30, int(tune_offer["months"]))
	var one_late: float = tuning.customer_limit(tune_offer, 30, int(tune_offer["months"]) + 1)
	var two_late: float = tuning.customer_limit(tune_offer, 30, int(tune_offer["months"]) + 2)
	if not (on_time > one_late and one_late > two_late) or two_late > 0.65 * on_time:
		return _fail("Two months late must cut the customer's limit dramatically (%.2f / %.2f / %.2f)" % [on_time, one_late, two_late])
	var over_advance: float = tuning.customer_limit(tune_offer, 100, int(tune_offer["months"]))
	if over_advance > 0.7 * on_time:
		return _fail("An advance far above the comfort level must cut the limit")
	var fason_found := 0
	var fason_offer: Dictionary = {}
	for month_index in range(1, 7):
		for candidate in Data.generate_offers(month_index, 0):
			if bool(candidate.get("fason", false)):
				fason_found += 1
				if fason_offer.is_empty():
					fason_offer = candidate
	if fason_found == 0 or float(fason_offer["material"]) != 0.0:
		return _fail("Some listings must be toll work with no material")
	var fason_game = Boss.new()
	fason_game.from_save(snapshot_day)
	fason_game.jobs.clear()
	fason_game.offers.append(fason_offer.duplicate(true))
	var fason_cost: Dictionary = fason_game.cost_estimate(fason_offer)
	if float(fason_cost["material"]) != 0.0:
		return _fail("Toll work must not price any material")
	var fason_job: Dictionary = fason_game._create_job(fason_offer.duplicate(true), 3.0, 0.3, int(fason_offer["months"]))
	if fason_job["order"].is_empty() or not bool(fason_job["order"]["paid"]) or float(fason_job["order"]["amount"]) != 0.0:
		return _fail("Toll work arrives with the job: no material order, nothing to pay")
	# ---- staff benefits: V2 needs all >= V1, V3 needs all >= V2, changes apply next month
	var bg = Boss.new()
	bg.default_setup(5)
	bg.set_benefit(0, 0)
	if int(bg.benefits_next[0]) < 1:
		return _fail("Mandatory benefits cannot drop below V1")
	bg.set_benefit(4, 2)
	if int(bg.benefits_next[4]) > 1:
		return _fail("V2 needs every benefit at V1 first")
	var cost_before: float = bg.staff_cost_per_head()
	for i in range(8):
		bg.set_benefit(i, 1)
	bg.set_benefit(0, 2)
	if float(bg.staff_cost_per_head()) != cost_before:
		return _fail("Benefit changes apply next month")
	# ---- tolerance slack: speed mode produces more per capacity, scrap mode cuts the scrap bill
	var sl = Boss.new()
	sl.from_save(snapshot_day)
	sl.jobs.clear()
	var slack_offer: Dictionary = fason_offer.duplicate(true)
	for req in slack_offer["reqs"]:
		req["tolerance"] = 0.5 if int(req["level"]) == 1 else 5.0 * float(Data.PRECISION_MM[int(req["level"])])
	var slack_job: Dictionary = sl._create_job(slack_offer, 3.0, 0.3, int(slack_offer["months"]))
	if sl.slack_of(slack_job) < 0.9 or not bool(slack_job["bonus_ask"]) or sl.bonus_pending() != int(slack_job["id"]):
		return _fail("A much looser tolerance must offer the slack choice")
	sl.choose_bonus(int(slack_job["id"]), "speed")
	if bool(slack_job["bonus_ask"]) or sl.bonus_pending() != -1:
		return _fail("Choosing clears the pending question")
	for req in slack_job["reqs"]:
		if not _near(float(req["speed_mult"]), 1.25, 0.001) or not _near(float(req.get("scrap_mult", 1.0)), 1.0, 0.001):
			return _fail("Speed mode: +25%% output, scrap unchanged")
	sl.choose_bonus(int(slack_job["id"]), "scrap")
	for req in slack_job["reqs"]:
		if not _near(float(req["speed_mult"]), 1.0, 0.001) or not _near(float(req["scrap_mult"]), 0.5, 0.001):
			return _fail("Scrap mode: -50%% scrap, speed unchanged")
	# ---- capacity chart: work fills its own level first and spills up to finer machines; a quoted job adds an outline
	var cc = Boss.new()
	cc.from_save(snapshot_day)
	var chart_kind: String = String(fason_offer["reqs"][0]["kind"])
	var base_chart: Dictionary = cc.capacity_chart(chart_kind)
	if base_chart["levels"].size() != 3:
		return _fail("The chart has one group per tolerance level")
	var sum_cap := 0.0
	for lv in base_chart["levels"]:
		sum_cap += float(lv["cap"]) + float(lv["transit"])
	var all_net := 0.0
	for machine in cc.machines:
		if machine["kind"] == chart_kind:
			all_net += float(cc.machine_steps(machine, cc.problem_mults(cc.loss_fractions()))["net"])
	if not _near(sum_cap, all_net, 0.01):
		return _fail("Chart capacity must equal the kind's net capacity (transit included)")
	var spill_alloc: Dictionary = cc._level_alloc([300.0, 0.0, 0.0], [100.0, 150.0, 100.0])
	if not _near(float(spill_alloc["used"][0]), 100.0, 0.001) or not _near(float(spill_alloc["spill"][1]), 150.0, 0.001) or not _near(float(spill_alloc["spill"][2]), 50.0, 0.001) or float(spill_alloc["unmet"][0]) != 0.0:
		return _fail("Coarse work spills up to finer machines when its own level is full")
	var with_extra: Dictionary = cc.capacity_chart(chart_kind, fason_offer, 1)
	var extra_sum := 0.0
	for lv in with_extra["levels"]:
		extra_sum += float(lv["extra"]) + float(lv["extra_unmet"])
	if extra_sum <= 0.0:
		return _fail("A quoted job must add load to the chart")
	# ---- lateness is counted in days: a few days late costs a few days' worth of score
	var ld = Boss.new()
	if ld.late_days(5, 5, 30) != 0 or ld.late_days(5, 6, 7) != 7 or ld.late_days(5, 6, 30) != 30 or ld.late_days(5, 4, 20) != 0:
		return _fail("Late days are counted from the end of the due month")
	if not _near(ld.late_target(0), 1.0, 0.0001) or not _near(ld.late_target(15), 0.7, 0.0001) or not _near(ld.late_target(90), 0.4, 0.0001):
		return _fail("Delivery score target falls linearly to 0.4 at a month late")
	# ---- machine speed-up: more output for more scrap, maintenance and energy; the group button copies it
	var bs = Boss.new()
	bs.from_save(snapshot_day)
	if not bs.machines.is_empty():
		var bm: Dictionary = bs.machines[0]
		var bmults: Dictionary = bs.problem_mults(bs.loss_fractions())
		var out0: float = bs.machine_steps(bm, bmults)["net"]
		var scrap0: float = bs.machine_scrap(bm)
		var maint0: float = bs.machine_maintenance(bm)
		bs.set_boost(int(bm["uid"]), 99)
		if int(bm["boost"]) != Data.BOOST_MAX:
			return _fail("The speed-up is capped at the maximum")
		var out1: float = bs.machine_steps(bm, bmults)["net"]
		if float(out0) > 0.0 and float(out1) <= float(out0) * 1.0:
			return _fail("A speed-up must raise the output")
		if not _near(bs.machine_scrap(bm), scrap0 * 1.6, scrap0 * 0.001 + 0.000001):
			return _fail("+25%% speed means scrap x1.6")
		if maint0 > 0.0 and not _near(bs.machine_maintenance(bm), maint0 * 1.6, maint0 * 0.001):
			return _fail("+25%% speed means maintenance x1.6")
		bs.set_boost_group(int(bm["uid"]), 10)
		for other in bs.machines:
			if other["kind"] == bm["kind"] and int(other["level"]) == int(bm["level"]) and int(other.get("boost", 0)) != 10:
				return _fail("The group button must copy the speed-up to the same kind and level")
	# ---- closing letter after a forced closure
	var cl = Boss.new()
	cl.from_save(snapshot_day)
	cl.debt = 500.0
	cl.cash = 0.0
	cl._close_factory({"gap": 500.0, "threshold": 10.0})
	if cl.phase != "end" or not cl.closure.has("letter"):
		return _fail("A forced closure must carry the closing letter")
	var letter_lines: Array = cl.closure["letter"]["lines"]
	var has_hook := false
	for line in letter_lines:
		if str(line).contains("önündeydi"):
			has_hook = true
	if letter_lines.size() < 4 or not has_hook or cl.mails.is_empty() or cl.mails[0]["title"] != cl.closure["letter"]["title"]:
		return _fail("The letter says the signs were visible, lists the mistakes and also arrives as mail")
	# ---- cash and commitments: the free cash is the cash minus material still to be paid minus the month's costs
	var cm = Boss.new()
	cm.from_save(snapshot_day)
	var com: Dictionary = cm.commitments()
	if not _near(float(com["free"]), float(com["cash"]) - float(com["material"]) - float(com["expense"]), 0.0001):
		return _fail("Free cash = cash - material due - monthly costs")
	var adv_sum := 0.0
	for job in cm.jobs:
		adv_sum += float(job["advance"])
	if not _near(float(com["advances"]), adv_sum, 0.0001):
		return _fail("Commitments list the advances held for unfinished jobs")
	# ---- mail contacts: every customer has three people, each with a portrait file
	var seen_faces := {}
	for company in Data.CUSTOMERS:
		var people: Array = Data.CONTACT_PEOPLE.get(company, [])
		if people.size() != 3:
			return _fail("Every customer has three contacts: " + company)
		for person in people:
			if not FileAccess.file_exists("res://art/contacts/%s.png" % person["id"]) or seen_faces.has(person["id"]):
				return _fail("Every contact has its own portrait: " + String(person["id"]))
			seen_faces[person["id"]] = true
	# ---- progress payment (hakediş): 80 % of the work done is paid at month end, the advance counting against it
	var pp = Boss.new()
	pp.from_save(snapshot_day)
	pp.jobs.clear()
	var pp_job: Dictionary = pp._create_job(fason_offer.duplicate(true), 10.0, 0.3, int(fason_offer["months"]))
	for req in pp_job["reqs"]:
		req["remaining"] = float(req["workload"]) / 2.0
	var cash_pp: float = pp.cash
	var paid_now: float = pp._progress_payment(pp_job)
	var expected_pp: float = (0.8 * 10.0 - 3.0) * 0.5
	if not _near(paid_now, expected_pp, 0.001) or not _near(pp.cash - cash_pp, expected_pp, 0.001):
		return _fail("Progress payment: 80%% of the work done minus the advance, pro rata")
	if pp._progress_payment(pp_job) != 0.0:
		return _fail("No second payment for the same work")
	for req in pp_job["reqs"]:
		req["remaining"] = 0.0
	var cash_before_delivery: float = pp.cash
	pp._deliver_job(pp_job)
	if not _near(pp.cash - cash_before_delivery, 10.0 - 3.0 - expected_pp, 0.001):
		return _fail("The final delivery pays the rest: revenue - advance - progress payments")
	# ---- big listings ask for a track record
	var gt = Boss.new()
	gt.from_save(snapshot_day)
	var big_offer: Dictionary = fason_offer.duplicate(true)
	big_offer["id"] = 987654
	for req in big_offer["reqs"]:
		req["workload"] = 12000.0
	gt.offers.append(big_offer)
	gt.jobs_done = 0
	gt.delivery_score = 0.9
	if gt.gate_block_reason(987654) == "":
		return _fail("A huge listing needs finished jobs first")
	gt.jobs_done = 4
	gt.delivery_score = 0.7
	if gt.gate_block_reason(987654) == "":
		return _fail("The biggest listings also need a high delivery score")
	gt.delivery_score = 0.85
	if gt.gate_block_reason(987654) != "":
		return _fail("With the record the listing opens")
	# ---- the monthly pool is 40 % small, 40 % medium, 20 % large
	var pool_rng := RandomNumberGenerator.new()
	pool_rng.seed = 11
	var pool_counts := {"small": 0, "medium": 0, "large": 0}
	for pool_month in range(3, 27):
		var pool_offers: Array = Data.generate_offers(pool_month, pool_month)
		Data.balance_pool(pool_offers, pool_rng)
		for offer in pool_offers:
			pool_counts[Data.job_class(Data.offer_load(offer))] += 1
	var pool_total := float(pool_counts["small"] + pool_counts["medium"] + pool_counts["large"])
	if absf(float(pool_counts["small"]) / pool_total - 0.4) > 0.05 or absf(float(pool_counts["medium"]) / pool_total - 0.4) > 0.05 or absf(float(pool_counts["large"]) / pool_total - 0.2) > 0.05:
		return _fail("The pool must follow 40/40/20: %s" % str(pool_counts))
	if Data.small_factor(2000.0) != 0.0 or Data.small_factor(300.0) < 0.99 or not Data.small_factor(600.0) > Data.small_factor(1200.0):
		return _fail("The small-job premium grows smoothly as the job shrinks")
	var small_game = Boss.new()
	small_game.from_save(snapshot_day)
	var premium_offer: Dictionary = fason_offer.duplicate(true)
	for req in premium_offer["reqs"]:
		req["workload"] = 3000.0
	var plain_top: float = small_game.customer_limit(premium_offer, 30, int(premium_offer["months"]), 10.0)
	var plain_low: float = small_game.customer_limit(premium_offer, 30, int(premium_offer["months"]), 1.0)
	for req in premium_offer["reqs"]:
		req["workload"] = 400.0
	if not small_game.customer_limit(premium_offer, 30, int(premium_offer["months"]), 10.0) > plain_top * 1.05 or not _near(small_game.customer_limit(premium_offer, 30, int(premium_offer["months"]), 1.0), plain_low, 0.0001):
		return _fail("Small jobs accept higher top prices; the base margin is unchanged")
	if Data.urgency_label({"urgency": 9}) != "Acil" or Data.urgency_label({"urgency": 2}) != "Esnek" or Data.urgency_label({"urgency": 5}) != "Normal":
		return _fail("Urgency labels")
	var pool_game = Boss.new()
	pool_game.from_save(snapshot_day)
	pool_game._generate_offers()
	if pool_game.offers.size() < 10:
		return _fail("The shell still generates a full pool")
	# ---- quote calendar and delayed mail
	var pl = Boss.new()
	pl.from_save(snapshot_day)
	pl.jobs.clear()
	var quote_calendar_offer: Dictionary = {}
	for candidate in pl.offers:
		if pl.fit_block_reason(candidate["id"]) == "" and pl.gate_block_reason(candidate["id"]) == "":
			quote_calendar_offer = candidate
			break
	if quote_calendar_offer.is_empty():
		quote_calendar_offer = fason_offer
	var plan: Dictionary = pl.plan_schedule(quote_calendar_offer, int(quote_calendar_offer["months"]))
	var found_extra := false
	for kind in plan["kinds"]:
		for segment in plan["kinds"][kind]:
			if bool(segment["extra"]) and int(segment["end"]) > int(segment["start"]):
				found_extra = true
	if not found_extra or int(plan["window_end"]) <= 0:
		return _fail("The quote calendar places the quoted job and knows the customer's window")
	var mail_test := {"id": 99999, "read": false}
	pl.mails.push_front(mail_test)
	var unread_before: int = pl.unread_mails()
	pl.delay_mail(mail_test)
	if pl.mail_arrived(mail_test) or pl.unread_mails() != unread_before - 1:
		return _fail("A delayed mail is not in the inbox yet and not counted as unread")
	mail_test["ready_ms"] = 0
	if not pl.mail_arrived(mail_test) or pl.unread_mails() != unread_before:
		return _fail("Once its time has come the mail counts as unread")
	print("Shell smoke passed")
	quit(0)
