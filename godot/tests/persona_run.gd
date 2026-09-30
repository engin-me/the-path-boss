extends SceneTree

# Plays the boss-only mode with persona JSON files and writes a Markdown
# report per persona to res://playtests/reports/.
# Usage:  godot --headless --path godot --script res://tests/persona_run.gd -- [persona=01_teknik_usta.json] [months=12] [seeds=30]
# With seeds=N each persona also plays N extra seeds and _ozet.md summarises them.

const BossState = preload("res://scripts/boss_state.gd")
const Log = preload("res://scripts/playtest_log.gd")
const CHANCE_RANK := {"Belirsiz": 0, "Düşük": 1, "Orta": 2, "Yüksek": 3, "Kesin": 4}

var machine_override := {}
var experiment := ""          # exp=label: print-only run; no report files touched
var diag_lines: Array[String] = []
var hours_agg := {}
var diag := {}                # IDEA-012 early-period counters for the seed being played

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var only := ""
	var author_filter := ""
	var months := 0
	var seeds := 0
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("seeds="):
			seeds = int(arg.trim_prefix("seeds="))
		elif arg.begins_with("exp="):
			experiment = arg.trim_prefix("exp=")
		elif arg.begins_with("pool="):
			# pool=K:M -> at least K of 5 offers fit the park for the first M months
			BossState.pool_min = int(arg.trim_prefix("pool=").get_slice(":", 0))
			BossState.pool_months = int(arg.trim_prefix("pool=").get_slice(":", 1))
		elif arg.begins_with("growth="):
			BossState.growth_rate = float(arg.trim_prefix("growth="))
		elif arg.begins_with("operator="):
			BossState.operator_hours = int(arg.trim_prefix("operator="))
		elif arg.begins_with("buffer="):
			BossState.open_buffer = int(arg.trim_prefix("buffer="))
		elif arg.begins_with("early="):
			BossState.early_months = int(arg.trim_prefix("early="))
		elif arg.begins_with("machines="):
			# machines=A:1,B:1 gives every persona the same park for fair comparison.
			machine_override = {}
			for part in arg.trim_prefix("machines=").split(","):
				machine_override[part.get_slice(":", 0)] = int(part.get_slice(":", 1))
		if arg.begins_with("author="):
			author_filter = arg.trim_prefix("author=")
		elif arg.begins_with("persona="):
			only = arg.trim_prefix("persona=")
		elif arg.begins_with("months="):
			months = int(arg.trim_prefix("months="))
	var personas := Log.load_personas()
	if not machine_override.is_empty():
		for persona in personas:
			persona["machines"] = machine_override.duplicate()
	var ran := 0
	var summary_lines: Array[String] = ["# Çoklu tohum özeti", "", "Her karakter %d farklı tohumla oynandı. Test girdisidir, denge kararı değildir." % seeds, "",
		"| Karakter | Ayakta | Zorunlu kapanış | İflas | Açılamadı | Ort. son net kasa | Ort. Düzelt denemesi | Ort. başarı | Ort. danışman | Ort. görülmeyen kayıp payı |", "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"]
	for persona in personas:
		if only != "" and persona["file"] != only:
			continue
		if author_filter != "" and persona.get("author", "") != author_filter:
			continue
		if experiment == "":
			print(play(persona, months))
		ran += 1
		if seeds > 0:
			summary_lines.append(_many(persona, months, seeds))
	if seeds > 0:
		if not machine_override.is_empty():
			summary_lines.insert(3, "Bütün karakterlere aynı makine parkı verildi: %s. Kendi makine seçimleri ve alım planları yok sayılmadı (planlı alımlar sürer)." % JSON.stringify(machine_override))
		var summary_name := "_ozet.md" if machine_override.is_empty() else "_ozet_ayni_makine.md"
		if author_filter != "":
			summary_name = "_ozet_%s.md" % author_filter.to_lower() if machine_override.is_empty() else "_ozet_%s_ayni_makine.md" % author_filter.to_lower()
		if experiment != "":
			print("\n".join(summary_lines))
			print("\n| Karakter | Oynanan | İlk 3 ay doluluk (iş/kapasite) | İşsiz ay | Gizli satırlı ay | Danışmansız deneme mümkün ay | Yalnız para engeli ay | Yalnız saat engeli ay |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
			print("\n".join(diag_lines))
		else:
			print(Log.write_report(summary_name, "\n".join(summary_lines) + "\n"))
	if ran == 0:
		printerr("Persona bulunamadı: " + only)
		quit(1)
		return
	quit(0)

func _many(persona: Dictionary, months_override: int, seeds: int) -> String:
	var outcomes := {"survived": 0, "forced": 0, "bankrupt": 0, "stuck": 0, "not_opened": 0}
	var cash := 0.0
	var tries := 0.0
	var wins := 0.0
	var hires := 0.0
	var hidden_share := 0.0
	var sums := {"hidden_months": 0, "hidden_ok": 0, "hidden_money": 0, "hidden_hours": 0, "expected": 0.0, "capacity": 0.0, "no_job": 0, "months": 0, "m1": 0, "m2": 0, "m3": 0, "seed_blocked": 0}
	for i in seeds:
		var copy := persona.duplicate(true)
		copy["seed"] = int(persona.get("seed", 1)) * 1000 + i
		var game = _simulate(copy, months_override)
		if game.phase == "invest" or game.phase == "setup":
			outcomes["not_opened"] += 1
			continue
		for key in sums:
			sums[key] += diag[key]
		for key in ["hours_sum", "hours_n", "h15", "h20", "h25", "h30"]:
			hours_agg[key] = int(hours_agg.get(key, 0)) + int(diag.get(key, 0))
		hours_agg["hours_max"] = maxi(int(hours_agg.get("hours_max", 0)), int(diag.get("hours_max", 0)))
		outcomes[game.closure.get("type", "stuck")] += 1
		cash += game.cash - game.debt
		var total := 0.0
		var unseen := 0.0
		for row in game.closing_rows():
			total += row["total_loss"]
			if not row["seen"]:
				unseen += row["total_loss"]
		hidden_share += unseen / total if total > 0.0 else 0.0
		for event in game.history:
			if event.contains("Düzelt"):
				tries += 1
				wins += 1 if event.contains("başarılı") else 0
			if event.contains("tutuldu"):
				hires += 1
	var played := maxi(1, seeds - outcomes["not_opened"])
	diag_lines.append("saat %s: ort %.1f/ay · >15: %d · >20: %d · >25: %d · >30: %d · azami %d · ay %d" % [persona["name"], float(hours_agg.get("hours_sum", 0)) / maxf(1.0, hours_agg.get("hours_n", 0)), hours_agg.get("h15", 0), hours_agg.get("h20", 0), hours_agg.get("h25", 0), hours_agg.get("h30", 0), hours_agg.get("hours_max", 0), hours_agg.get("hours_n", 0)])
	hours_agg = {}
	diag_lines.append("| %s | %d | %.0f%% | %d | %d | %d | %d | %d | ay1/2/3: %d/%d/%d · tohum %d |" % [persona["name"], played, 100.0 * sums["expected"] / maxf(1.0, sums["capacity"]), sums["no_job"], sums["hidden_months"], sums["hidden_ok"], sums["hidden_money"], sums["hidden_hours"], sums["m1"], sums["m2"], sums["m3"], sums["seed_blocked"]])
	return "| %s | %d | %d | %d | %d | %.0f | %.1f | %%%.0f | %.1f | %%%.0f |" % [persona["name"], outcomes["survived"], outcomes["forced"], outcomes["bankrupt"] + outcomes["stuck"], outcomes["not_opened"], cash / played, tries / played, 100.0 * wins / maxf(1.0, tries), hires / played, 100.0 * hidden_share / played]

func _simulate(persona: Dictionary, months_override: int):
	diag = {"hidden_months": 0, "hidden_ok": 0, "hidden_money": 0, "hidden_hours": 0, "expected": 0.0, "capacity": 0.0, "no_job": 0, "months": 0, "m1": 0, "m2": 0, "m3": 0, "seed_blocked": 0}
	var game = BossState.new()
	var policy: Dictionary = persona.get("policy", {})
	game.max_months = months_override if months_override > 0 else int(persona.get("months", 12))
	if game.configure(persona["skills"], int(persona.get("budget", 600)), float(persona.get("cash", 400)), persona["name"], int(persona.get("seed", 1)), String(persona.get("diploma", "")), true) != "":
		return game
	if game.open_factory(persona.get("machines", {"A": 1})) != "":
		return game
	while game.phase == "offers":
		_play_month(game, policy)
	return game

func play(persona: Dictionary, months_override: int) -> String:
	var game = BossState.new()
	var policy: Dictionary = persona.get("policy", {})
	if months_override > 0:
		game.max_months = months_override
	else:
		game.max_months = int(persona.get("months", 12))
	var error: String = game.configure(persona["skills"], int(persona.get("budget", 600)), float(persona.get("cash", 400)), persona["name"], int(persona.get("seed", 1)), String(persona.get("diploma", "")), true)
	var rows: Array[String] = []
	if error != "":
		return _write(persona, game, rows, "Kurulum hatası: " + error)
	error = game.open_factory(persona.get("machines", {"A": 1}))
	if error != "":
		return _write(persona, game, rows, "Açılış hatası: " + error)
	while game.phase == "offers":
		rows.append(_play_month(game, policy))
	return _write(persona, game, rows, "")

func _play_month(game, policy: Dictionary) -> String:
	var month: int = game.month
	for plan in policy.get("buy", []):
		if int(plan["month"]) == month:
			game.buy_machine(plan["type"])
	if game.cash < float(policy.get("credit_when_cash_below", -INF)):
		game.take_credit()
	var selection := _choose_jobs(game, policy)
	var error: String = game.accept_jobs(selection)
	if error != "":
		game.history.append("Ay %d: seçim reddedildi (%s); iş alınmadan devam." % [month, error])
		error = game.accept_jobs([])
	if error != "":
		game.history.append("Ay %d: hiç iş almadan bile ay başlatılamadı (%s)." % [month, error])
		game.phase = "end"
		game.closure = {"type": "stuck"}
		return "| %d | — | — | — | — | — | — | — | %.0f | oyun kilitlendi: %s |" % [month, game.cash, error]
	var hidden := 0
	var visible := 0
	for department in BossState.SKILLS:
		for row in game.active_rows(department):
			if row["visible"]:
				visible += 1
			else:
				hidden += 1
	if month <= 3 and not diag.is_empty():
		diag["months"] += 1
		diag["expected"] += float(game.report["expected"])
		diag["capacity"] += float(game.capacity_at_least(1))
		diag["no_job"] += 1 if int(game.report["expected"]) == 0 else 0
		var any_hidden := false
		var any_ok := false
		var money := false
		var hours := false
		for department in BossState.SKILLS:
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
		diag["hidden_months"] += 1 if any_hidden else 0
		diag["hidden_ok"] += 1 if any_ok else 0
		diag["hidden_money"] += 1 if (any_hidden and not any_ok and money) else 0
		if any_hidden and not any_ok and money:
			diag["m%d" % month] = int(diag.get("m%d" % month, 0)) + 1
			diag["seed_blocked"] = 1
		diag["hidden_hours"] += 1 if (any_hidden and not any_ok and hours and not money) else 0
	_hire(game, policy)
	var tries := 0
	var successes := 0
	var blocked := 0
	for root_id in _fix_order(game, policy):
		var result: Dictionary = game.fix(root_id)
		if result["ok"]:
			tries += 1
			successes += 1 if result["success"] else 0
		else:
			blocked += 1
	var report: Dictionary = game.report
	var consultants: Array[String] = []
	for consultant in game.consultants:
		consultants.append(consultant["name"])
	var line := "| %d | %d/%d | %.0f | %.0f | %d görünür / %d gizli | %d/%d (engel %d) | %s | %d |" % [
		month, int(report["realized"]), int(report["expected"]), report["loss"], report["revenue"],
		visible, hidden, successes, tries, blocked, ", ".join(consultants) if not consultants.is_empty() else "—", game.prevented_this_month]
	if not diag.is_empty():
		var used: int = BossState.MONTHLY_HOURS - BossState.operator_hours - game.hours_left
		diag["hours_sum"] = int(diag.get("hours_sum", 0)) + used
		diag["hours_n"] = int(diag.get("hours_n", 0)) + 1
		for limit in [15, 20, 25, 30]:
			if used > limit:
				diag["h%d" % limit] = int(diag.get("h%d" % limit, 0)) + 1
		diag["hours_max"] = maxi(int(diag.get("hours_max", 0)), used)
	game.finish_month()
	var status: Dictionary = game.solvency()
	return line + " %.0f | %.0f / %.0f |" % [game.cash, status["gap"], status["threshold"]]

func _choose_jobs(game, policy: Dictionary) -> Array:
	var order: Array = range(game.offers.size())
	order.sort_custom(func(a, b):
		var ma: float = game.offers[a]["price"] - game.offers[a]["cost"] / game.offers[a]["quantity"]
		var mb: float = game.offers[b]["price"] - game.offers[b]["cost"] / game.offers[b]["quantity"]
		return ma > mb)
	var limit: float = game.capacity_at_least(1) * (0.8 if policy.get("jobs", "greedy") == "safe" else 1.0)
	var selection: Array = []
	var used := 0
	for index in order:
		var trial := selection.duplicate()
		trial.append(index)
		if used + int(game.offers[index]["quantity"]) <= limit and game.selection_problem(trial) == "":
			selection = trial
			used += int(game.offers[index]["quantity"])
	return selection

func _hire(game, policy: Dictionary) -> void:
	var threshold := float(policy.get("hire_when_hidden_loss", 0))
	if threshold <= 0.0:
		return
	var hidden_loss := {}
	for department in BossState.SKILLS:
		for row in game.active_rows(department):
			if not row["visible"]:
				hidden_loss[department] = float(hidden_loss.get(department, 0.0)) + row["loss"]
	var departments: Array = hidden_loss.keys()
	departments.sort_custom(func(a, b): return hidden_loss[a] > hidden_loss[b])
	for department in departments:
		if hidden_loss[department] < threshold:
			break
		var best := -1
		var best_score: int = game.effective_skill(department)
		for index in game.candidates.size():
			var score := int(game.candidates[index]["scores"].get(department, 0))
			if BossState.reached_tier(score) > BossState.reached_tier(best_score):
				best = index
				best_score = score
		if best >= 0 and game.hire_block_reason(best) == "":
			game.hire(best)

func _fix_order(game, policy: Dictionary) -> Array:
	var mode: String = policy.get("fix", "visible_only")
	if mode == "none":
		return []
	var min_rank := int(CHANCE_RANK.get(policy.get("min_chance", "Orta"), 2))
	var picks: Array = []
	for department in BossState.SKILLS:
		for row in game.active_rows(department):
			if mode == "visible_only" and not row["visible"]:
				continue
			if int(CHANCE_RANK[row["chance"]]) < min_rank:
				continue
			picks.append(row)
	picks.sort_custom(func(a, b): return a["loss"] > b["loss"])
	var ids: Array = []
	for row in picks:
		ids.append(row["id"])
	return ids

func _write(persona: Dictionary, game, rows: Array[String], error: String) -> String:
	var lines: Array[String] = []
	lines.append("# Oyun testi — %s" % persona["name"])
	lines.append("")
	lines.append("Yazan: %s · Persona dosyası: `%s` · Tohum: %s · Bu rapor test girdisidir, tasarım kararı değildir." % [persona.get("author", "?"), persona["file"], str(persona.get("seed", "?"))])
	lines.append("")
	lines.append("> %s" % persona.get("description", ""))
	lines.append("")
	var skill_text: Array[String] = []
	for skill in BossState.SKILLS:
		skill_text.append("%s %d" % [skill, int(persona["skills"].get(skill, 0))])
	lines.append("**Yetkinlikler:** " + ", ".join(skill_text))
	lines.append("")
	lines.append("**Diploma:** %s (tavanı aşan puanlar kırpılır; ayrıntı olay geçmişinde)" % BossState.DIPLOMAS.get(String(persona.get("diploma", "")), {"title": "?"})["title"])
	lines.append("")
	lines.append("**Başlangıç:** para %s, makineler %s, politika `%s`" % [str(persona.get("cash")), JSON.stringify(persona.get("machines", {})), JSON.stringify(persona.get("policy", {}))])
	lines.append("")
	if error != "":
		lines.append("**Sonuç:** " + error)
	else:
		lines.append("## Aylar")
		lines.append("")
		lines.append("| Ay | Çıktı | Kayıp | Gelir | Düzelt öncesi sorun satırları | Düzelt başarı/deneme | Danışman | Önlenen | Ay sonu kasa | Açık / eşik |")
		lines.append("| --- | --- | ---: | ---: | --- | --- | --- | ---: | ---: | --- |")
		lines.append_array(rows)
		lines.append("")
		lines.append("## Sonuç")
		lines.append("")
		var outcome := {"survived": "Fabrika test süresince ayakta kaldı.", "forced": "Zorunlu kapanış; tasfiye borcu kapattı, iflas değil.", "bankrupt": "Zorunlu kapanış ve iflas."}
		lines.append("- %s Son kasa %.0f, borç %.0f." % [outcome.get(game.closure.get("type", ""), "?"), game.cash, game.debt])
		for lesson in game.lessons():
			lines.append("- " + lesson)
		lines.append("")
		lines.append("## Kapanış raporu")
		lines.append("")
		for row in game.closing_rows():
			lines.append("- %s T%d · toplam kayıp %.0f · %s · %s · kesin çözüm için %d (patron %d)" % [row["department"], row["tier"], row["total_loss"], "görüldü" if row["seen"] else "görülmedi", "çözüldü" if row["solved"] else "sürüyor", row["needed"], row["skill"]])
		lines.append("")
		lines.append("## Otomatik bulgular")
		lines.append("")
		if game.findings.is_empty():
			lines.append("- Otomatik kontrol bulgusu yok.")
		for finding in game.findings:
			lines.append("- " + finding)
		lines.append("")
		lines.append("## Olay geçmişi")
		lines.append("")
		for event in game.history:
			lines.append("- " + event)
	lines.append("")
	lines.append("## Test eden yorumu")
	lines.append("")
	lines.append("_Bu bölümü oynayan kişi/yapay zekâ doldurur: tasarım sorunu, mantık hatası, \"bu saçma olmuş\" noktaları._")
	lines.append("")
	var path := Log.write_report(persona["file"].get_basename() + ".md", "\n".join(lines))
	return "%s → %s (%s)" % [persona["name"], game.closure.get("type", error), path]
