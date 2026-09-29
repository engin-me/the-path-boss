extends RefCounted

# Boss-only playtest mode. Structure follows the CURRENT FREEZE files in
# docs/freeze/ plus the DRAFT decisions under test (IDEA-009 / FRZ-007 v2
# diploma caps, FRZ-001 v2 per-point chance, IDEA-010 problem growth).
# Every number below is an illustrative test input, not balance.

const SKILLS := ["Üretim", "Planlama", "Depo & Sevkiyat", "Bakım", "Kalite", "Satın Alma", "Finans", "Ar-Ge / Ür-Ge", "Yatırım", "İnsan Yönetimi"]
const HR_SKILL := "İnsan Yönetimi"

# FRZ-001: Tier thresholds decide visibility and certain fixes.
const TIER_THRESHOLDS := [30, 50, 70, 90, 100]
# FRZ-001 v2 DRAFT: below the root threshold each missing point costs 4%.
const CHANCE_PER_POINT := 0.04
const FLOOR_CHANCE := 0.05

# FRZ-007 v2 DRAFT: without the matching diploma learning stops at the Tier start.
const FIELD_CAPS := {
	"Üretim": 70, "Depo & Sevkiyat": 70, "Bakım": 70, "Kalite": 70,
	"Planlama": 50, "Satın Alma": 50, "İnsan Yönetimi": 50,
	"Finans": 30, "Yatırım": 30, "Ar-Ge / Ür-Ge": 30
}
const DIPLOMAS := {
	"": {"title": "Diploma yok", "fields": []},
	"muhendislik": {"title": "Mühendislik", "fields": ["Üretim", "Bakım", "Kalite", "Ar-Ge / Ür-Ge", "Planlama", "Depo & Sevkiyat"]},
	"isletme": {"title": "İşletme / İktisat", "fields": ["Finans", "Yatırım", "Satın Alma", "İnsan Yönetimi", "Planlama", "Depo & Sevkiyat"]},
	"ikisi": {"title": "Mühendislik + İşletme", "fields": ["Üretim", "Bakım", "Kalite", "Ar-Ge / Ür-Ge", "Planlama", "Depo & Sevkiyat", "Finans", "Yatırım", "Satın Alma", "İnsan Yönetimi"]}
}

# IDEA-010 DRAFT: an unsolved problem's monthly loss grows at the same rate
# for every Tier (so the amount does not reveal depth), up to a cap.
const GROWTH_RATE := 0.05
const GROWTH_CAP := 2.0

# FRZ-004: machine type sets capacity and the jobs it qualifies for.
const MACHINES := {
	"A": {"title": "A tezgâh · temel", "price": 80.0, "capacity": 40, "quality": 1},
	"B": {"title": "B tezgâh · hassas", "price": 140.0, "capacity": 55, "quality": 2},
	"C": {"title": "C tezgâh · nitelikli", "price": 220.0, "capacity": 70, "quality": 3}
}

# FRZ-001 §6 and FRZ-002 v3 §4: visible scale limits new problem depth and
# price bands follow the scale's unit value.
const SCALES := [
	{"name": "Küçük", "min_machines": 1, "max_tier": 3, "factor": 1.0, "consultant_cap": 70},
	{"name": "Orta", "min_machines": 3, "max_tier": 4, "factor": 1.5, "consultant_cap": 90},
	{"name": "Büyük", "min_machines": 5, "max_tier": 5, "factor": 2.0, "consultant_cap": 100}
]

# FRZ-001 §5: non-overlapping money bands, hour bands that do not decrease.
const MONEY_BANDS := {1: [6.0, 10.0], 2: [12.0, 18.0], 3: [25.0, 35.0], 4: [50.0, 70.0], 5: [100.0, 140.0]}
const HOUR_BANDS := {1: [2, 3], 2: [3, 5], 3: [5, 8], 4: [8, 12], 5: [12, 16]}
const TIER_WEIGHTS := {1: 35, 2: 30, 3: 20, 4: 10, 5: 5}

const MONTHLY_HOURS := 40
const BASE_EXPENSE := 30.0
const MACHINE_EXPENSE := 12.0
const DEPRECIATION := 0.015
const CREDIT_AMOUNT := 100.0
const FINANCE_RATE := 0.02
const VOLUNTARY_SALE := 0.70
const FORCED_SALE := 0.50
const DEPARTMENT_CAP := 0.20
const REALIZATION_FLOOR := 0.33
# FRZ-005 v2: person-caused share and maximum prevention at İnsan Yönetimi 100.
const PERSON_SHARE := 0.30
const MAX_PREVENTION := 0.80
# FRZ-006 v2: two active consultants, budget = areas × 60, fee weighted by top two scores.
const MAX_CONSULTANTS := 2
const CONSULTANT_MONTHS := 3
const CONSULTANT_HOUR_FACTOR := 0.7
const DEFAULT_MARGINS := {1: 0.9, 2: 1.2, 3: 1.6}

var phase := "setup"
var persona := "Manuel"
var budget := 600
var skills: Dictionary = {}
var diploma := ""
var start_cash := 400.0
var cash := 0.0
var debt := 0.0
var credit_used := false
var machines: Array[Dictionary] = []
var month := 1
var max_months := 12
var offers: Array[Dictionary] = []
var offer_history: Array[Dictionary] = []
var accepted: Array[int] = []
var report: Dictionary = {}
var problems: Dictionary = {}
var next_id := 1
var consultants: Array[Dictionary] = []
var candidates: Array[Dictionary] = []
var hours_left := MONTHLY_HOURS
var prevented_this_month := 0
var prevented_total := 0
var history: Array[String] = []
var findings: Array[String] = []
var month_flags: Dictionary = {}
var closure: Dictionary = {}
var notice := "Patron yetkinliklerini dağıt, cebine para koy ve fabrikanı kur."
var rng := RandomNumberGenerator.new()

func _init() -> void:
	rng.randomize()
	for skill in SKILLS:
		skills[skill] = 60

# ---------------------------------------------------------------- helpers

static func reached_tier(skill: int) -> int:
	var tier := 0
	for index in TIER_THRESHOLDS.size():
		if skill >= TIER_THRESHOLDS[index]:
			tier = index + 1
	return tier

static func chance_for_points(skill: int, threshold: int) -> float:
	if skill >= threshold:
		return 1.0
	return maxf(FLOOR_CHANCE, 1.0 - CHANCE_PER_POINT * (threshold - skill))

static func field_cap(field: String, diploma_id: String) -> int:
	if DIPLOMAS[diploma_id]["fields"].has(field):
		return 100
	return int(FIELD_CAPS[field])

static func chance_label(chance: float) -> String:
	if chance >= 1.0:
		return "Kesin"
	if chance >= 0.8:
		return "Yüksek"
	if chance >= 0.4:
		return "Orta"
	return "Düşük"

static func scale_for_count(count: int) -> Dictionary:
	var result: Dictionary = SCALES[0]
	for scale in SCALES:
		if count >= scale["min_machines"]:
			result = scale
	return result

func skill_total() -> int:
	var total := 0
	for skill in SKILLS:
		total += int(skills[skill])
	return total

func scale() -> Dictionary:
	return scale_for_count(machines.size())

func ordinary_expense() -> float:
	return BASE_EXPENSE + MACHINE_EXPENSE * machines.size()

func capacity_at_least(quality: int) -> int:
	var total := 0
	for machine in machines:
		if MACHINES[machine["type"]]["quality"] >= quality:
			total += int(MACHINES[machine["type"]]["capacity"])
	return total

func investment_value() -> float:
	var total := 0.0
	for machine in machines:
		total += machine["reference"]
	return total

func accepted_cost() -> float:
	var total := 0.0
	for index in accepted:
		total += offers[index]["cost"]
	return total

func finance_due() -> float:
	var net := cash - debt
	return maxf(1.0, roundf(-net * FINANCE_RATE)) if net < 0.0 else 0.0

# FRZ-002 v3 §3: usable cash excludes this month's known unpaid costs.
func available_cash() -> float:
	return cash - ordinary_expense() - accepted_cost() - finance_due()

# ---------------------------------------------------------------- setup

func configure(new_skills: Dictionary, new_budget: int, new_cash: float, persona_name: String = "Manuel", rng_seed: int = -1, diploma_id: String = "", clamp_to_caps := false) -> String:
	if phase != "setup":
		return "Kurulum yalnızca başta yapılır."
	if not DIPLOMAS.has(diploma_id):
		return "Bilinmeyen diploma: %s" % diploma_id
	var values := {}
	var clamped: Array[String] = []
	var total := 0
	for skill in SKILLS:
		var value := int(new_skills.get(skill, 0))
		if value < 0 or value > 100:
			return "%s 0–100 arasında olmalı." % skill
		var cap := field_cap(skill, diploma_id)
		if value > cap:
			if not clamp_to_caps:
				return "%s diplomasız en fazla %d olabilir (%s)." % [skill, cap, DIPLOMAS[diploma_id]["title"]]
			clamped.append("%s %d→%d" % [skill, value, cap])
			value = cap
		values[skill] = value
		total += value
	if total > new_budget:
		return "Toplam %d puan bütçeyi (%d) aşıyor." % [total, new_budget]
	for skill in SKILLS:
		skills[skill] = values[skill]
	diploma = diploma_id
	budget = new_budget
	start_cash = new_cash
	cash = new_cash
	persona = persona_name
	if rng_seed >= 0:
		rng.seed = rng_seed
	phase = "invest"
	notice = "Cebinde %.0f para var. Makinelerini seç; kuruluştan sonra ilk ayın giderleri ve gizli sorun güvencesi kadar nakit kalmalı." % cash
	history.append("Patron: %s · %s · toplam yetkinlik %d/%d · başlangıç parası %.0f" % [persona, DIPLOMAS[diploma]["title"], total, budget, cash])
	if not clamped.is_empty():
		history.append("Diploma tavanına kırpıldı: " + ", ".join(clamped))
	return ""

func opening_requirement(counts: Dictionary) -> Dictionary:
	var price := 0.0
	var count := 0
	for type in counts:
		price += MACHINES[type]["price"] * int(counts[type])
		count += int(counts[type])
	var chosen := scale_for_count(count)
	var first_expense := BASE_EXPENSE + MACHINE_EXPENSE * count
	var guarantee: float = MONEY_BANDS[chosen["max_tier"]][1] * chosen["factor"]
	return {"price": price, "count": count, "scale": chosen, "expense": first_expense, "guarantee": guarantee,
		"cash_after": cash - price, "needed": first_expense + guarantee, "ok": count > 0 and cash - price >= first_expense + guarantee}

func open_factory(counts: Dictionary) -> String:
	if phase != "invest":
		return "Fabrika zaten açık."
	var need := opening_requirement(counts)
	if need["count"] == 0:
		return "En az bir makine gerekli."
	if not need["ok"]:
		return "Makinelerden sonra kasa %.0f; en az %.0f gerekli (ilk ay gideri %.0f + gizli sorun güvencesi %.0f)." % [need["cash_after"], need["needed"], need["expense"], need["guarantee"]]
	for type in counts:
		for i in int(counts[type]):
			_add_machine(type, 0)
	cash -= need["price"]
	month = 1
	history.append("Fabrika açıldı: %d makine, ölçek %s, kasa %.0f" % [machines.size(), scale()["name"], cash])
	_generate_problems(2)
	_generate_offers()
	phase = "offers"
	notice = "Fabrika açıldı. Fabrikayı kurmak kolay kısmıydı; şimdi ayakta tutman gerekiyor. Bu ayın işlerini seç."
	return ""

func _add_machine(type: String, bought_month: int) -> void:
	machines.append({"type": type, "reference": MACHINES[type]["price"], "bought_month": bought_month})

# ---------------------------------------------------------------- offers and investment

func _generate_offers() -> void:
	offers.clear()
	accepted.clear()
	var top_quality := 1
	for machine in machines:
		top_quality = maxi(top_quality, int(MACHINES[machine["type"]]["quality"]))
	for i in 5:
		var quality := rng.randi_range(1, 3)
		var quantity := rng.randi_range(3, 9) * 5
		var price: float = snappedf(rng.randf_range(1.2, 1.6) + (quality - 1) * 0.5, 0.05)
		var unit_cost: float = snappedf(rng.randf_range(0.3, 0.45) + (quality - 1) * 0.1, 0.05)
		var offer := {"quality": quality, "quantity": quantity, "price": price, "cost": roundf(quantity * unit_cost), "month": month}
		offers.append(offer)
		offer_history.append(offer)
	while offer_history.size() > 15:
		offer_history.pop_front()

func selection_problem(selection: Array) -> String:
	for quality in [3, 2, 1]:
		var needed := 0
		for index in selection:
			if offers[index]["quality"] >= quality:
				needed += int(offers[index]["quantity"])
		if needed > capacity_at_least(quality):
			return "Seçili işler Q%d ve üstü makine kapasitesini aşıyor (%d > %d)." % [quality, needed, capacity_at_least(quality)]
	# FRZ-004 reserves job costs from Düzelt money; it does not block taking
	# work. A cash shortfall is handled by FRZ-003 v2 (financing, threshold).
	return ""

func selection_warning(selection: Array) -> String:
	var cost := 0.0
	for index in selection:
		cost += offers[index]["cost"]
	var left := cash - ordinary_expense() - finance_due() - cost
	if left < 0.0:
		return "Uyarı: giderler ve iş maliyeti (%.0f) sonrası kasa %.0f'ye iner; ay sonu satış geliri gelmezse eksi kasaya finansman gideri işler." % [cost, left]
	return ""

func machine_price_ok(type: String) -> String:
	if phase != "offers":
		return "Makine yalnızca iş seçmeden önce alınır."
	var price: float = MACHINES[type]["price"]
	var next_expense := ordinary_expense() + MACHINE_EXPENSE
	if cash - price < next_expense:
		return "Alımdan sonra kasa bu ayın giderini (%.0f) karşılamıyor." % next_expense
	return ""

func buy_machine(type: String) -> String:
	var reason := machine_price_ok(type)
	if reason != "":
		return reason
	cash -= MACHINES[type]["price"]
	_add_machine(type, month)
	history.append("Ay %d: %s alındı (%.0f). Kâr potansiyeline ilk tam ayından sonra girer." % [month, MACHINES[type]["title"], MACHINES[type]["price"]])
	notice = "%s alındı. Kapasite arttı; iflas eşiğine katkısı ilk tam faaliyet ayından sonra sayılır." % MACHINES[type]["title"]
	return ""

func sale_preview(index: int) -> Dictionary:
	var machine: Dictionary = machines[index]
	var income: float = roundf(machine["reference"] * VOLUNTARY_SALE)
	var remaining: Array[Dictionary] = machines.duplicate()
	remaining.remove_at(index)
	var cash_after := cash + income
	var value_after: float = investment_value() - machine["reference"]
	var expense_after := BASE_EXPENSE + MACHINE_EXPENSE * remaining.size()
	var n_after := maxf(0.0, max_gross_profit(remaining) - expense_after)
	var gap_after := maxf(0.0, debt - cash_after)
	var threshold_after: float = 0.5 * value_after + 6.0 * n_after
	return {"income": income, "gap": gap_after, "threshold": threshold_after, "closes": gap_after > threshold_after,
		"capacity_lost": MACHINES[machine["type"]]["capacity"]}

func sell_machine(index: int) -> String:
	if phase != "offers" or index < 0 or index >= machines.size():
		return "Makine yalnızca iş seçmeden önce satılır."
	if machines.size() == 1:
		return "Son makineyi satmak fabrikayı kapatmak demektir; bu testte kapanış ayrı yapılmaz."
	var preview := sale_preview(index)
	var machine: Dictionary = machines[index]
	cash += preview["income"]
	machines.remove_at(index)
	history.append("Ay %d: %s satıldı (+%.0f). Yeni eşik %.0f, açık %.0f." % [month, MACHINES[machine["type"]]["title"], preview["income"], preview["threshold"], preview["gap"]])
	notice = "Makine satıldı. Kapasite %d azaldı." % preview["capacity_lost"]
	return ""

func take_credit() -> String:
	if credit_used:
		return "Kriz kredisi tek seferliktir."
	if phase != "offers" and phase != "report":
		return "Kredi yalnızca fabrika açıkken alınır."
	credit_used = true
	cash += CREDIT_AMOUNT
	debt += CREDIT_AMOUNT
	history.append("Ay %d: kriz kredisi %.0f alındı; borç açığı değişmedi." % [month, CREDIT_AMOUNT])
	notice = "Kredi kasayı ve borcu aynı tutarda artırdı; net pozisyonun değişmedi."
	return ""

# ---------------------------------------------------------------- month report

func accept_jobs(selection: Array) -> String:
	if phase != "offers":
		return "Önce ay başı iş seçimi yapılır."
	var reason := selection_problem(selection)
	if reason != "":
		return reason
	accepted.clear()
	for index in selection:
		accepted.append(int(index))
	var expected := 0
	for index in accepted:
		expected += int(offers[index]["quantity"])
	var losses: Dictionary = {}
	for root in problems.values():
		if root["active"]:
			losses[root["department"]] = float(losses.get(root["department"], 0.0)) + root["loss"]
			root["total_loss"] += root["loss"]
			if is_visible(root):
				root["ever_seen"] = true
	var total_loss := 0.0
	var capped := false
	for department in losses:
		var cap := expected * DEPARTMENT_CAP
		if losses[department] > cap:
			losses[department] = cap
			capped = true
		total_loss += losses[department]
	var realized := maxf(expected - total_loss, expected * REALIZATION_FLOOR)
	# Deliver the best paying complete jobs first.
	var order := accepted.duplicate()
	order.sort_custom(func(a, b): return offers[a]["price"] > offers[b]["price"])
	var units_left := realized
	var revenue := 0.0
	var undelivered := 0
	for index in order:
		var delivered := minf(units_left, float(offers[index]["quantity"]))
		revenue += delivered * offers[index]["price"]
		units_left -= delivered
		if delivered < offers[index]["quantity"]:
			undelivered += 1
	report = {"expected": expected, "loss": expected - realized, "realized": realized, "revenue": revenue,
		"losses": losses, "empty": capacity_at_least(1) - expected, "capped": capped, "undelivered": undelivered}
	hours_left = MONTHLY_HOURS
	month_flags = {"fix_blocked_money": 0, "fix_blocked_hours": 0, "fixes": 0}
	_generate_candidates()
	phase = "report"
	notice = "Ay raporu hazır. Kararların (Düzelt, danışman) bu ayın raporunu değiştirmez; etkisi gelecek ay görünür."
	if expected == 0:
		_find("Ay %d: hiç iş alınmadı; bütün kapasite boş kaldı." % month)
	if cash < ordinary_expense() + accepted_cost():
		_find("Ay %d: ay başı kasa (%.0f) giderleri (%.0f) karşılamıyor; oyuncu satış gelirine güvenerek çalışıyor." % [month, cash, ordinary_expense() + accepted_cost()])
	return ""

# ---------------------------------------------------------------- problems

func _generate_problems(events: int) -> void:
	prevented_this_month = 0
	var current: Dictionary = scale()
	var capacity := capacity_at_least(1)
	for i in events:
		if rng.randf() < PERSON_SHARE and rng.randf() < MAX_PREVENTION * skills[HR_SKILL] / 100.0:
			prevented_this_month += 1
			prevented_total += 1
			continue
		var department: String = SKILLS[rng.randi_range(0, SKILLS.size() - 1)]
		var free: Array[int] = []
		var weights := 0
		for tier in range(1, int(current["max_tier"]) + 1):
			if not _slot_taken(department, tier):
				free.append(tier)
				weights += int(TIER_WEIGHTS[tier])
		if free.is_empty():
			continue
		var loss: float = float(rng.randi_range(2, 6)) * current["factor"]
		if _department_loss(department) + loss > capacity * DEPARTMENT_CAP:
			continue
		var pick := rng.randi_range(1, weights)
		var tier := free[0]
		for candidate in free:
			pick -= int(TIER_WEIGHTS[candidate])
			if pick <= 0:
				tier = candidate
				break
		var band: Array = MONEY_BANDS[tier]
		var hour_band: Array = HOUR_BANDS[tier]
		problems["k%d" % next_id] = {
			"department": department, "tier": tier, "loss": loss, "base_loss": loss, "active": true, "attempted": 0,
			"scale_tier": int(current["max_tier"]), "factor": float(current["factor"]),
			"actual_money": roundf(rng.randf_range(band[0], band[1]) * current["factor"]),
			"actual_hours": rng.randi_range(hour_band[0], hour_band[1]),
			"total_loss": 0.0, "ever_seen": false, "solved_month": 0, "born": month
		}
		next_id += 1

func _slot_taken(department: String, tier: int) -> bool:
	for root in problems.values():
		if root["active"] and root["department"] == department and root["tier"] == tier:
			return true
	return false

func _department_loss(department: String) -> float:
	var total := 0.0
	for root in problems.values():
		if root["active"] and root["department"] == department:
			total += root["loss"]
	return total

func consultant_score(department: String) -> int:
	var best := 0
	for consultant in consultants:
		best = maxi(best, int(consultant["scores"].get(department, 0)))
	return best

func effective_skill(department: String) -> int:
	return maxi(int(skills[department]), consultant_score(department))

func reach(department: String) -> int:
	return reached_tier(effective_skill(department))

func is_visible(root: Dictionary) -> bool:
	return reach(root["department"]) >= root["tier"]

func possible_hidden_tiers(root: Dictionary) -> int:
	return maxi(0, int(root["scale_tier"]) - reach(root["department"]))

func chance_for(root: Dictionary) -> float:
	return chance_for_points(effective_skill(root["department"]), TIER_THRESHOLDS[root["tier"] - 1])

func chance_text(root: Dictionary) -> String:
	if is_visible(root) or possible_hidden_tiers(root) == 1:
		return chance_label(chance_for(root))
	return "Belirsiz"

func _hours(department: String, value: int) -> int:
	if consultant_score(department) > 0:
		return maxi(1, int(roundf(value * CONSULTANT_HOUR_FACTOR)))
	return value

# FRZ-001 §5: hidden rows share the shallowest unreachable floor and the
# deepest ceiling of the scale class they were born in.
func quote_for(root: Dictionary) -> Dictionary:
	var factor: float = root["factor"]
	var department: String = root["department"]
	var low_tier: int = root["tier"]
	var high_tier: int = root["tier"]
	if not is_visible(root):
		low_tier = reach(department) + 1
		high_tier = int(root["scale_tier"])
	return {
		"estimate": roundf(MONEY_BANDS[low_tier][0] * factor), "actual": root["actual_money"],
		"upper": roundf(MONEY_BANDS[high_tier][1] * factor),
		"estimate_hours": _hours(department, HOUR_BANDS[low_tier][0]), "actual_hours": _hours(department, root["actual_hours"]),
		"upper_hours": _hours(department, HOUR_BANDS[high_tier][1])
	}

func fix_block_reason(root_id: String) -> String:
	if phase != "report" or not problems.has(root_id):
		return "Düzelt yalnızca ay raporunda yapılır."
	var root: Dictionary = problems[root_id]
	if not root["active"]:
		return "Sorun zaten çözüldü."
	if root["attempted"] == month:
		return "Aynı köke bu ay yeniden müdahale edilemez."
	var quote := quote_for(root)
	if available_cash() < quote["upper"]:
		return "Kullanılabilir nakit (%.0f) en fazla bedeli (%.0f) karşılamıyor." % [available_cash(), quote["upper"]]
	if hours_left < quote["upper_hours"]:
		return "Kalan patron zamanı (%d sa) en fazla süreyi (%d sa) karşılamıyor." % [hours_left, quote["upper_hours"]]
	return ""

func fix(root_id: String) -> Dictionary:
	var reason := fix_block_reason(root_id)
	if reason != "":
		if reason.begins_with("Kullanılabilir"):
			month_flags["fix_blocked_money"] = int(month_flags.get("fix_blocked_money", 0)) + 1
		elif reason.begins_with("Kalan"):
			month_flags["fix_blocked_hours"] = int(month_flags.get("fix_blocked_hours", 0)) + 1
		notice = reason
		return {"ok": false, "reason": reason}
	var root: Dictionary = problems[root_id]
	var quote := quote_for(root)
	var visible_before := is_visible(root)
	if not (quote["estimate"] <= quote["actual"] and quote["actual"] <= quote["upper"]):
		_find("Ay %d: tahmin ≤ gerçek ≤ üst bozuldu (%s T%d)." % [month, root["department"], root["tier"]])
	var chance := chance_for(root)
	var success: bool = chance >= 1.0 or rng.randf() < chance
	var paid: float = quote["actual"] if success else quote["estimate"]
	var hours: int = quote["actual_hours"] if success else quote["estimate_hours"]
	cash -= paid
	hours_left -= hours
	root["attempted"] = month
	month_flags["fixes"] = int(month_flags.get("fixes", 0)) + 1
	var root_name: String = ("%s T%d" % [root["department"], root["tier"]]) if visible_before else ("%s · derinliği bilinmeyen sorun" % root["department"])
	if success:
		root["active"] = false
		root["solved_month"] = month
		notice = "%s çözüldü: %.0f para, %d saat. Kayıp gelecek ayın raporundan kalkar." % [root_name, paid, hours]
	else:
		notice = "%s çözülemedi: %.0f para, %d saat. Bu kök bu ay kilitli; sorun sürüyor." % [root_name, paid, hours]
	history.append("Ay %d: Düzelt %s → %s (%.0f para, %d sa)" % [month, root_name, "başarılı" if success else "başarısız", paid, hours])
	return {"ok": true, "success": success, "paid": paid, "hours": hours}

func active_rows(department: String) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for root_id in problems:
		var root: Dictionary = problems[root_id]
		if root["active"] and root["department"] == department:
			var quote := quote_for(root)
			var row := quote.duplicate()
			row.merge({"id": root_id, "tier": root["tier"], "loss": root["loss"], "base_loss": root["base_loss"], "visible": is_visible(root),
				"chance": chance_text(root), "attempted": root["attempted"] == month, "blocked": fix_block_reason(root_id)})
			rows.append(row)
	rows.sort_custom(func(a, b): return a["tier"] < b["tier"] if a["visible"] and b["visible"] else a["visible"] and not b["visible"])
	return rows

# ---------------------------------------------------------------- consultants

func _generate_candidates() -> void:
	candidates.clear()
	var cap := int(scale()["consultant_cap"])
	var weakest: Array = SKILLS.duplicate()
	weakest.sort_custom(func(a, b): return skills[a] < skills[b])
	for i in 3:
		var areas := rng.randi_range(2, 5)
		var pool: Array = SKILLS.duplicate()
		# Seeded shuffle: Array.shuffle() uses the global generator and made
		# persona runs irreproducible for the same seed.
		for index in range(pool.size() - 1, 0, -1):
			var other := rng.randi_range(0, index)
			var held = pool[index]
			pool[index] = pool[other]
			pool[other] = held
		# Targeting uses only visible information: the patron's weak fields.
		var focus: String = weakest[rng.randi_range(0, 3)]
		pool.erase(focus)
		pool.push_front(focus)
		var chosen: Array = pool.slice(0, areas)
		var remaining := areas * 60
		var scores: Dictionary = {}
		for index in chosen.size():
			var left_after := chosen.size() - index - 1
			var high := mini(cap, remaining - left_after * 25)
			var low := 25
			var value := rng.randi_range(maxi(low, high - 30), high) if index == 0 else rng.randi_range(low, maxi(low, mini(high, 75)))
			value = mini(value, high)
			scores[chosen[index]] = value
			remaining -= value
		var values: Array = scores.values()
		values.sort()
		values.reverse()
		# Calibrated in the boss test: a 3-month contract ≈ 1–2 months of one
		# department's hidden loss (IDEA-010 draft, balance input).
		var fee: float = roundf(2.0 + (values[0] + values[1]) / 30.0)
		candidates.append({"name": "Aday %d-%d" % [month, i + 1], "scores": scores, "monthly": fee, "total": fee * CONSULTANT_MONTHS})

func hire_block_reason(index: int) -> String:
	if phase != "report" or index < 0 or index >= candidates.size():
		return "Danışman ay raporundan sonra seçilir."
	if consultants.size() >= MAX_CONSULTANTS:
		return "Aynı anda en fazla %d danışman çalışabilir." % MAX_CONSULTANTS
	if available_cash() < candidates[index]["total"]:
		return "Sözleşme bedeli (%.0f) kullanılabilir nakdi (%.0f) aşıyor." % [candidates[index]["total"], available_cash()]
	return ""

func hire(index: int) -> String:
	var reason := hire_block_reason(index)
	if reason != "":
		notice = reason
		return reason
	var candidate: Dictionary = candidates[index]
	cash -= candidate["total"]
	consultants.append({"name": candidate["name"], "scores": candidate["scores"], "months_left": CONSULTANT_MONTHS, "total": candidate["total"]})
	candidates.remove_at(index)
	history.append("Ay %d: %s %d ay için tutuldu (%.0f)." % [month, candidate["name"], CONSULTANT_MONTHS, candidate["total"]])
	notice = "%s hemen başladı. Etkin yetkinlik = max(patron, danışman); bilgisi patrona kalıcı geçmez." % candidate["name"]
	return ""

# ---------------------------------------------------------------- month end

func max_gross_profit(park: Array[Dictionary]) -> float:
	var margins := {}
	var counts := {}
	for offer in offer_history:
		var quality: int = offer["quality"]
		var margin: float = offer["price"] - offer["cost"] / offer["quantity"]
		margins[quality] = float(margins.get(quality, 0.0)) + margin
		counts[quality] = int(counts.get(quality, 0)) + 1
	var total := 0.0
	for machine in park:
		if machine["bought_month"] >= month:
			continue  # FRZ-003 v2: counts after its first full month.
		var quality: int = MACHINES[machine["type"]]["quality"]
		var best := 0.0
		for q in range(1, quality + 1):
			var average: float = margins[q] / counts[q] if counts.has(q) else DEFAULT_MARGINS[q]
			best = maxf(best, average)
		total += best * MACHINES[machine["type"]]["capacity"]
	return total

func solvency() -> Dictionary:
	var net := maxf(0.0, max_gross_profit(machines) - ordinary_expense())
	var gap := maxf(0.0, debt - cash)
	var threshold := 0.5 * investment_value() + 6.0 * net
	return {"gap": gap, "threshold": threshold, "net": net, "value": investment_value(), "closes": gap > threshold}

func finish_month() -> String:
	if phase != "report":
		return "Önce işleri seçip raporu aç."
	var finance := finance_due()
	cash += report["revenue"] - ordinary_expense() - accepted_cost() - finance
	for machine in machines:
		machine["reference"] = roundf(machine["reference"] * (1.0 - DEPRECIATION) * 100.0) / 100.0
	for consultant in consultants:
		consultant["months_left"] -= 1
	var still_active: Array[Dictionary] = []
	for consultant in consultants:
		if consultant["months_left"] > 0:
			still_active.append(consultant)
		else:
			history.append("Ay %d: %s sözleşmesi bitti; bilgisi fabrikada kalmadı." % [month, consultant["name"]])
	consultants = still_active
	_grow_problems()
	var status := solvency()
	history.append("Ay %d: %.0f/%d çıktı, gelir %.0f, kasa %.0f, borç açığı %.0f / eşik %.0f" % [month, report["realized"], report["expected"], report["revenue"], cash, status["gap"], status["threshold"]])
	_check_month()
	notice = "%d. ay kapandı. Kasa %.0f. Borç açığı %.0f, kurtarma eşiği %.0f." % [month, cash, status["gap"], status["threshold"]]
	if finance > 0.0:
		notice += " Eksi net pozisyon için %.0f finansman gideri işledi." % finance
	report = {}
	if status["closes"]:
		_close_factory(status)
		return ""
	month += 1
	if month > max_months:
		phase = "end"
		closure = {"type": "survived"}
		notice += " Test süresi bitti; fabrika ayakta."
		return ""
	var events := rng.randi_range(1, 2) + (1 if machines.size() >= 3 else 0) + (1 if machines.size() >= 5 else 0)
	_generate_problems(events)
	_generate_offers()
	phase = "offers"
	return ""

func _grow_problems() -> void:
	for root in problems.values():
		if root["active"]:
			root["loss"] = minf(root["base_loss"] * GROWTH_CAP, snappedf(root["loss"] * (1.0 + GROWTH_RATE), 0.01))

func _close_factory(status: Dictionary) -> void:
	var proceeds := roundf(investment_value() * FORCED_SALE)
	var shortfall := maxf(0.0, debt - cash - proceeds)
	closure = {"type": "bankrupt" if shortfall > 0.0 else "forced", "proceeds": proceeds, "shortfall": shortfall, "gap": status["gap"], "threshold": status["threshold"]}
	phase = "end"
	notice += " Borç açığı eşiği aştı: zorunlu kapanış. " + ("Tasfiye sonrası %.0f açık kaldı; iflas." % shortfall if shortfall > 0.0 else "Tasfiye borcu kapattı; iflas değil.")
	history.append(notice)

func _check_month() -> void:
	if int(month_flags.get("fix_blocked_money", 0)) > 0 and int(month_flags.get("fixes", 0)) == 0:
		_find("Ay %d: Düzelt denendi ama nakit güvencesi hiçbir müdahaleye izin vermedi." % month)
	if int(month_flags.get("fix_blocked_hours", 0)) > 0:
		_find("Ay %d: patron zamanı yüzünden müdahale engellendi." % month)
	if report.get("undelivered", 0) > 0:
		_find("Ay %d: kayıplar yüzünden %d iş tam teslim edilemedi; ayrı ceza yok (FRZ-004)." % [month, report["undelivered"]])
	if report.get("capped", false):
		_find("Ay %d: departman kayıp tavanı (%%20) devreye girdi." % month)

func _find(text: String) -> void:
	if not findings.has(text):
		findings.append(text)

# ---------------------------------------------------------------- closing report

func closing_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for root_id in problems:
		var root: Dictionary = problems[root_id]
		rows.append({"department": root["department"], "tier": root["tier"], "total_loss": root["total_loss"],
			"seen": root["ever_seen"], "solved": not root["active"], "needed": TIER_THRESHOLDS[root["tier"] - 1],
			"skill": skills[root["department"]], "cap": field_cap(root["department"], diploma)})
	rows.sort_custom(func(a, b): return a["total_loss"] > b["total_loss"])
	return rows

func lessons() -> Array[String]:
	var by_department := {}
	for row in closing_rows():
		if row["skill"] < row["needed"]:
			var entry: Dictionary = by_department.get(row["department"], {"loss": 0.0, "needed": 0})
			entry["loss"] += row["total_loss"]
			entry["needed"] = maxi(entry["needed"], row["needed"])
			by_department[row["department"]] = entry
	var names: Array = by_department.keys()
	names.sort_custom(func(a, b): return by_department[a]["loss"] > by_department[b]["loss"])
	var result: Array[String] = []
	for department in names.slice(0, 2):
		var needed: int = by_department[department]["needed"]
		var line := "Bu sefer %s bilgisini %d'ye taşımadan fabrika kurmayacağım. (Sende %d, bu alanın görülmeyen kaybı %.0f.)" % [department, needed, skills[department], by_department[department]["loss"]]
		if needed > field_cap(department, diploma):
			line += " Bunun için önce ilgili diploma gerekir; diplomasız tavan %d." % field_cap(department, diploma)
		result.append(line)
	if result.is_empty():
		result.append("Yetkinliklerin bu fabrikanın sorunlarını görmeye yetti.")
	if prevented_total > 0:
		result.append("İnsan Yönetimi %d kişi kaynaklı olayı daha doğmadan önledi." % prevented_total)
	return result

# ---------------------------------------------------------------- notes

func context_line() -> String:
	var where := "Kurulum" if phase == "setup" else ("Yatırım" if phase == "invest" else "Ay %d · %s" % [month, phase])
	return "%s · %s · kasa %.0f · borç %.0f · makine %d" % [persona, where, cash, debt, machines.size()]
