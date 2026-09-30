extends SceneTree

# Headless policy simulation on the ShellBoss engine (IDEA-015/016 economy).
# Usage: --script res://tests/shell_sim.gd -- seeds=100 [months=12]
# All numbers are test inputs, not balance decisions.

const ShellBoss = preload("res://scripts/shell/shell_boss.gd")
const Data = preload("res://scripts/shell/shell_data.gd")

# uid reference: new machines 0-11 (Torna, Freze, Taşlama, Dövme x Standart/Hassas/Nitelikli);
# second hand: 12 Torna-Std 6y, 13 Torna-Has 4y, 14 Freze-Std 8y, 15 Freze-Nit 3y,
# 16 Taşlama-Has 5y, 17 Taşlama-Std 9y, 18 Dövme-Std 7y, 19 Dövme-Has 4y.
const PERSONAS := [
	{"name": "Küçük temkinli", "factory": "ridgeway", "term": 12, "prepay": false, "buys": [[1, 13], [1, 14]]},
	{"name": "Orta ikinci el", "factory": "harbor", "term": 12, "prepay": false, "buys": [[1, 13], [1, 14], [1, 17]]},
	{"name": "Orta peşinci", "factory": "harbor", "term": 12, "prepay": true, "buys": [[1, 13], [1, 14]]},
	{"name": "Orta yeni makine", "factory": "harbor", "term": 12, "prepay": false, "buys": [[1, 1], [1, 4]]},
	{"name": "Tek makine", "factory": "ridgeway", "term": 12, "prepay": false, "buys": [[1, 13]]},
	{"name": "Büyük iddialı", "factory": "millbrook", "term": 24, "prepay": false, "buys": [[1, 13], [1, 14], [1, 16], [2, 12]]}
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
		elif arg.begins_with("rev="):
			Data.revenue_scale = float(arg.trim_prefix("rev="))
		elif arg.begins_with("cash="):
			Data.start_cash = float(arg.trim_prefix("cash="))
		elif arg.begins_with("floor="):
			ShellBoss.pool_floor = int(arg.trim_prefix("floor="))
		elif arg.begins_with("rent="):
			Data.rent_scale = float(arg.trim_prefix("rent="))
	print("| Karakter | Kiralanamadı | Ayakta | Zorunlu kapanış | İflas | Ort. son net kasa | En düşük kasa (ort.) | İlk iş ayı | İşsiz makine-ay | Ort. verim | Düzelt/ay | Gizli satırlı ay | Danışmansız deneme mümkün | Para engeli | Saat engeli |")
	print("| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
	for persona in PERSONAS:
		var agg := {"denied": 0, "alive": 0, "forced": 0, "bankrupt": 0, "net": 0.0, "trough": 0.0, "first_job": 0.0, "first_n": 0, "idle": 0.0, "idle_n": 0,
			"eff": 0.0, "eff_n": 0, "fixes": 0, "game_months": 0, "hidden": 0, "ok": 0, "money": 0, "hours": 0}
		for seed_value in seeds:
			_play(persona, seed_value, months, agg)
		var played: int = seeds - int(agg["denied"])
		var d := float(maxi(1, played))
		print("| %s | %d | %d | %d | %d | %.0f | %.0f | %s | %.1f | %s | %.2f | %d | %d | %d | %d |" % [
			persona["name"], agg["denied"], agg["alive"], agg["forced"], agg["bankrupt"], agg["net"] / d, agg["trough"] / d,
			("%.1f" % (agg["first_job"] / maxf(1.0, agg["first_n"]))) if agg["first_n"] > 0 else "—", agg["idle"] / d,
			("%%%d" % int(100.0 * agg["eff"] / maxf(1.0, agg["eff_n"]))) if agg["eff_n"] > 0 else "—",
			float(agg["fixes"]) / maxf(1.0, agg["game_months"]), agg["hidden"], agg["ok"], agg["money"], agg["hours"]])
	quit(0)

func _play(persona: Dictionary, seed_value: int, months: int, agg: Dictionary) -> void:
	var game = ShellBoss.new()
	game.max_months = months
	game.default_setup(seed_value)
	if game.rent_factory(persona["factory"], persona["term"], persona["prepay"]) != "":
		agg["denied"] += 1
		return
	game.buy_package()
	var queue: Array = persona["buys"].duplicate(true)
	var first_job := 0
	var trough: float = game.cash
	while game.phase == "offers":
		# scheduled purchases (retry until affordable)
		var still: Array = []
		for item in queue:
			if game.month >= int(item[0]) and game.buy_listing(int(item[1])) == "":
				continue
			still.append(item)
		queue = still
		# greedy job acceptance by monthly profit
		var ranked: Array = game.offers.duplicate()
		ranked.sort_custom(func(a, b): return (float(a["revenue"]) - float(a["material"])) / float(a["months"]) > (float(b["revenue"]) - float(b["material"])) / float(b["months"]))
		for offer in ranked:
			if game.accept_block_reason(offer["id"]) != "":
				continue
			if game.cash - game.first_payment(offer) < game.ordinary_expense():
				continue
			game.accept_offer(offer["id"])
			if first_job == 0:
				first_job = game.month
		var idle := 0
		for machine in game.delivered():
			if int(machine["job"]) == 0:
				idle += 1
		agg["idle"] += idle
		game.run_report()
		if game.month <= 3:
			var any_hidden := false
			var any_ok := false
			var money := false
			var hours := false
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
					elif why.begins_with("Kalan"):
						hours = true
			agg["hidden"] += 1 if any_hidden else 0
			agg["ok"] += 1 if any_ok else 0
			agg["money"] += 1 if (any_hidden and not any_ok and money) else 0
			agg["hours"] += 1 if (any_hidden and not any_ok and hours and not money) else 0
		if game.report.get("expected", 0) > 0:
			agg["eff"] += float(game.report["efficiency"])
			agg["eff_n"] += 1
		# Düzelt: visible rows with decent odds first, then hidden ones when cash is comfortable
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
			if game.fix(row["id"])["ok"]:
				agg["fixes"] += 1
		agg["game_months"] += 1
		game.close_month()
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
	if first_job > 0:
		agg["first_job"] += first_job
		agg["first_n"] += 1
