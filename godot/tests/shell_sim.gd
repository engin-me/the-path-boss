extends SceneTree

# Headless policy simulation on the ShellBoss engine (IDEA-015..018 economy).
# Usage: --script res://tests/shell_sim.gd -- seeds=100 [months=12] [price=0.10] [rev=1] [cash=800] [floor=12] [policy=1]
# All numbers are test inputs, not balance decisions.

const ShellBoss = preload("res://scripts/shell/shell_boss.gd")
const Data = preload("res://scripts/shell/shell_data.gd")

static var pm := -1.0   # arg pm=: overrides every persona's quote margin
static var trace := false
static var only := ""
static var adaptive := 0.0   # arg adaptive=0.6: the player prices by the acceptance gauge (highest margin with at least this chance)
static var day_mode := false   # arg days=1: play the month day by day (advance_day) instead of the monthly shortcut
static var staff_policy := 1   # 0 Yok, 1 Standart, 2 İyi (arg policy=)

# uid reference: new machines 0-11 (Torna, Freze, Taşlama, Dövme x Standart/Hassas/Nitelikli);
# second hand: 12 Torna-Std 12y, 13 Torna-Has 8y, 14 Freze-Std 14y, 15 Freze-Nit 5y,
# 16 Taşlama-Has 9y, 17 Taşlama-Std 15y, 18 Dövme-Std 16y, 19 Dövme-Has 10y.
# "grow": add a shift to machines whose backlog is high (when cash allows).
# "expand": used machines bought later, when cash covers the price and three months of expenses.
# "cash": starting money override (the default is the operator's five years of saving).
const PERSONAS := [
	{"name": "Tek makine", "factory": "factory_1", "term": 12, "prepay": false, "buys": [[1, 12]], "expand": [], "grow": false, "supplier": "nord", "margin": 0.70},
	{"name": "Küçük temkinli", "factory": "factory_1", "term": 12, "prepay": false, "buys": [[1, 12]], "expand": [13], "grow": false, "supplier": "pacific", "margin": 0.50},
	{"name": "Küçük vardiyacı", "factory": "factory_1", "term": 12, "prepay": false, "buys": [[1, 12]], "expand": [13, 14], "grow": true, "supplier": "nord", "margin": 0.90},
	{"name": "Orta ikinci el", "factory": "factory_3", "term": 12, "prepay": false, "buys": [[1, 12]], "expand": [13, 14, 17], "grow": true, "supplier": "midland", "margin": 0.70},
	{"name": "Sermayeli yeni makine", "factory": "factory_3", "term": 12, "prepay": false, "buys": [[1, 1], [1, 4]], "expand": [], "grow": true, "supplier": "atlas", "margin": 0.90, "cash": 220.0},
	{"name": "Sermayeli büyük", "factory": "factory_4", "term": 24, "prepay": false, "buys": [[1, 13], [1, 14], [1, 16], [2, 12]], "expand": [], "grow": true, "supplier": "nord", "margin": 0.80, "cash": 300.0}
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var seeds := 100
	var months := 12
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("seeds="):
			seeds = int(arg.trim_prefix("seeds="))
		elif arg.begins_with("months="):
			months = int(arg.trim_prefix("months="))
		elif arg.begins_with("price="):
			Data.price_per_x = float(arg.trim_prefix("price="))
		elif arg.begins_with("rev="):
			Data.revenue_scale = float(arg.trim_prefix("rev="))
		elif arg.begins_with("cash="):
			Data.start_cash = float(arg.trim_prefix("cash="))
		elif arg.begins_with("trace="):
			trace = int(arg.trim_prefix("trace=")) == 1
		elif arg.begins_with("only="):
			only = arg.trim_prefix("only=")
		elif arg.begins_with("pm="):
			pm = float(arg.trim_prefix("pm="))
		elif arg.begins_with("adaptive="):
			adaptive = float(arg.trim_prefix("adaptive="))
		elif arg.begins_with("days="):
			day_mode = int(arg.trim_prefix("days=")) == 1
		elif arg.begins_with("mid="):
			Data.mid_base = float(arg.trim_prefix("mid="))
		elif arg.begins_with("slope="):
			Data.mid_slope = float(arg.trim_prefix("slope="))
		elif arg.begins_with("margin="):
			Data.margin_scale = float(arg.trim_prefix("margin="))
		elif arg.begins_with("wage="):
			Data.WAGE = float(arg.trim_prefix("wage="))
		elif arg.begins_with("rent="):
			Data.rent_scale = float(arg.trim_prefix("rent="))
		elif arg.begins_with("overhead="):
			Data.typical_overhead = float(arg.trim_prefix("overhead="))
		elif arg.begins_with("policy="):
			staff_policy = int(arg.trim_prefix("policy="))
		elif arg.begins_with("floor="):
			ShellBoss.pool_floor = int(arg.trim_prefix("floor="))
	print("| Karakter | Kiralanamadı | Ayakta | Zorunlu kapanış | İflas | Ort. son net kasa | En düşük kasa (ort.) | İlk iş ayı | OEE (24 sa, ort.) | Kapasite kullanımı | Ort. vardiya | Geç teslim / teslim | Bırakılan-iptal | Son skor | Teklif: kabul / karşı / ret | Gizli satırlı ay | Danışmansız deneme mümkün | Para engeli |")
	print("| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
	for persona in PERSONAS:
		if only != "" and not String(persona["name"]).begins_with(only):
			continue
		var agg := {"denied": 0, "alive": 0, "forced": 0, "bankrupt": 0, "net": 0.0, "trough": 0.0, "first_job": 0.0, "first_n": 0,
			"oee": 0.0, "oee_n": 0, "used": 0.0, "net_cap": 0.0, "shifts": 0.0, "shift_n": 0, "late": 0, "delivered": 0, "dropped": 0,
			"score": 0.0, "hidden": 0, "ok": 0, "money": 0, "q_ok": 0, "q_counter": 0, "q_reject": 0}
		for seed_value in seeds:
			_play(persona, seed_value, months, agg)
		var played: int = seeds - int(agg["denied"])
		var d := float(maxi(1, played))
		print("| %s | %d | %d | %d | %d | %.0f | %.0f | %s | %s | %s | %s | %d / %d | %d | %%%d | %d / %d / %d | %d | %d | %d |" % [
			persona["name"], agg["denied"], agg["alive"], agg["forced"], agg["bankrupt"], agg["net"] / d, agg["trough"] / d,
			("%.1f" % (agg["first_job"] / maxf(1.0, agg["first_n"]))) if agg["first_n"] > 0 else "—",
			("%%%d" % int(100.0 * agg["oee"] / maxf(1.0, agg["oee_n"]))) if agg["oee_n"] > 0 else "—",
			("%%%d" % int(100.0 * agg["used"] / maxf(1.0, agg["net_cap"]))) if agg["net_cap"] > 0.0 else "—",
			("%.1f" % (agg["shifts"] / maxf(1.0, agg["shift_n"]))) if agg["shift_n"] > 0 else "—",
			agg["late"], agg["delivered"], agg["dropped"], int(100.0 * agg["score"] / d), agg["q_ok"], agg["q_counter"], agg["q_reject"], agg["hidden"], agg["ok"], agg["money"]])
	quit(0)

# Expected monthly output of machines still on the way (one shift, no problems).
func _future_capacity(game) -> float:
	var total := 0.0
	for machine in game.machines:
		total += float(machine["nameplate"]) / 3.0 * float(machine["perf"]) * (1.0 - float(machine["scrap"]))
	return total

func _play(persona: Dictionary, seed_value: int, months: int, agg: Dictionary) -> void:
	var game = ShellBoss.new()
	game.max_months = months
	game.default_setup(seed_value)
	game.staff_policy = staff_policy
	if persona.has("cash"):
		game.cash = float(persona["cash"])
	var expand: Array = persona.get("expand", []).duplicate()
	if game.rent_factory(persona["factory"], persona["term"], persona["prepay"]) != "":
		agg["denied"] += 1
		return
	game.default_supplier = persona["supplier"]
	game.buy_package()
	var queue: Array = persona["buys"].duplicate(true)
	var first_job := 0
	var trough: float = game.cash
	while game.phase == "offers":
		var still: Array = []
		for item in queue:
			if game.month >= int(item[0]) and game.buy_listing(int(item[1])) == "":
				continue
			still.append(item)
		queue = still
		if not expand.is_empty():
			var listing: Dictionary = game.listing_by_uid(int(expand[0]))
			if game.cash > float(listing["price"]) + 3.0 * game.ordinary_expense() and game.buy_listing(int(expand[0])) == "":
				expand.remove_at(0)
		# grow shifts where the backlog per machine kind is high
		if persona["grow"]:
			for machine in game.delivered():
				var backlog := 0.0
				for job in game.jobs:
					for req in job["reqs"]:
						if req["kind"] == machine["kind"]:
							backlog += float(req["remaining"])
				var monthly := maxf(1.0, game.effective_capacity(machine["kind"]))
				if backlog > 2.0 * monthly and game.cash > 2.0 * game.ordinary_expense() and int(machine["shifts"]) < 3:
					game.set_shifts(machine["uid"], int(machine["shifts"]) + 1)
				elif backlog < 0.5 * monthly and int(machine["shifts"]) > 1:
					game.set_shifts(machine["uid"], int(machine["shifts"]) - 1)
		# greedy acceptance by margin per month; keep one month of expenses
		var ranked: Array = game.offers.duplicate()
		ranked.sort_custom(func(a, b): return (float(a["revenue"]) - float(a["material"])) / float(a["months"]) > (float(b["revenue"]) - float(b["material"])) / float(b["months"]))
		for offer in ranked:
			if game.accept_block_reason(offer["id"]) != "":
				continue
			# cash after the advance, unpaid material of running jobs and this job must still cover a month
			var outstanding := 0.0
			for job in game.jobs:
				if job["order"].is_empty():
					outstanding += float(job["material"])
				elif not job["order"]["paid"]:
					outstanding += float(job["order"]["amount"])
			var this_material: float = float(offer["material"]) * float(Data.supplier_by_id(game.default_supplier)["price"])
			if game.cash + game.advance_of(offer) - outstanding - this_material < game.ordinary_expense():
				continue
			# plan: work already promised plus this job must fit the capacity until its due date
			var capacity_now: float = game.effective_capacity()
			if capacity_now <= 0.0:
				capacity_now = _future_capacity(game)
			var promised := 0.0
			for job in game.jobs:
				promised += game.job_remaining(job)
			var offer_load := 0.0
			for req in offer["reqs"]:
				offer_load += float(req["workload"])
			if promised + offer_load > 0.85 * capacity_now * float(offer["months"]):
				continue
			var estimate: Dictionary = game.cost_estimate(offer)
			var margin_used: float = pm if pm >= 0.0 else float(persona["margin"])
			if adaptive > 0.0:
				margin_used = 0.0
				var try_margin := 1.5
				while try_margin >= 0.0:
					var chance: float = game.accept_probability(offer, float(estimate["total"]) * (1.0 + try_margin), 30, int(offer["months"]))["accept"]
					if chance >= adaptive:
						margin_used = try_margin
						break
					try_margin -= 0.05
			var price := snappedf(float(estimate["total"]) * (1.0 + margin_used), 0.001)
			var result: Dictionary = game.submit_quote(offer["id"], price, 30, int(offer["months"]))
			if not result["ok"]:
				continue
			agg["q_" + {"accepted": "ok", "counter": "counter", "rejected": "reject"}[result["status"]]] += 1
			if result["status"] == "counter" and float(result["mail"]["price"]) >= float(estimate["total"]) * 1.05:
				game.answer_counter(result["mail"]["id"], true)
				result["status"] = "accepted"
			if result["status"] == "accepted" and first_job == 0:
				first_job = game.month
		for machine in game.delivered():
			agg["shifts"] += float(machine["shifts"])
			agg["shift_n"] += 1
		if day_mode:
			game.finish_month_days()
		game.run_report()
		if game.month <= 3:
			var any_hidden := false
			var any_ok := false
			var money := false
			for department in game.SKILLS:
				for row in game.active_rows(department):
					if row["visible"]:
						continue
					any_hidden = true
					var why: String = game.fix_block_reason(row["id"])
					if why == "":
						any_ok = true
					elif why.begins_with("Kullanılabilir"):
						money = true
			agg["hidden"] += 1 if any_hidden else 0
			agg["ok"] += 1 if any_ok else 0
			agg["money"] += 1 if (any_hidden and not any_ok and money) else 0
		if float(game.report.get("theoretical", 0.0)) > 0.0:
			agg["oee"] += float(game.report["oee"])
			agg["oee_n"] += 1
			agg["used"] += float(game.report["used"])
			agg["net_cap"] += float(game.report["net"])
		var attempts: Array = []
		for department in game.SKILLS:
			for row in game.active_rows(department):
				attempts.append(row)
		attempts.sort_custom(func(a, b): return (1 if a["visible"] else 0) > (1 if b["visible"] else 0))
		for row in attempts:
			if row["blocked"] != "" or row["attempted"]:
				continue
			if not row["visible"] and game.cash < 3.0 * float(row["upper"]):
				continue
			game.fix(row["id"])
		var score_before: float = game.delivery_score
		var jobs_before: int = game.jobs.size()
		game.close_month()
		for line in game.last_lines:
			var text := str(line)
			if text.begins_with("Gün "):
				text = text.substr(text.find(": ") + 2)   # day events carry a "Gün N: " prefix
			if text.begins_with("Teslim:"):
				agg["delivered"] += 1
				if text.contains("GEÇ TESLİM"):
					agg["late"] += 1
			elif text.begins_with("İptal:"):
				agg["dropped"] += 1
		if trace and seed_value == 1:
			print("M%d cash %.2f | %s" % [game.month, game.cash, " | ".join(game.last_lines)])
		trough = minf(trough, game.cash - game.debt)
	if game.phase == "end":
		var kind: String = game.closure.get("type", "")
		if kind == "survived":
			agg["alive"] += 1
		elif kind == "forced":
			agg["forced"] += 1
		else:
			agg["bankrupt"] += 1
	agg["net"] += game.cash - game.debt
	agg["trough"] += trough
	agg["score"] += game.delivery_score
	if first_job > 0:
		agg["first_job"] += first_job
		agg["first_n"] += 1
