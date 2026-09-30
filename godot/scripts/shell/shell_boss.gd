extends "res://scripts/boss_state.gd"

# Engine for the mobile factory shell. It reuses BossState's problem, Düzelt,
# consultant, patron-hours and solvency machinery and replaces the economic
# surface (rent, machine market, machine-holding jobs, equipment package,
# mortgage loan, month cycle) with the model proposed in IDEA-015 / IDEA-016.
# Prototype only: the old boss_state.gd behaviour and its tests are untouched.
# Every number is a test input, not a FREEZE decision.

const Data = preload("res://scripts/shell/shell_data.gd")

# IDEA-016 proposal: machine age raises the chance that a Maintenance problem
# is born (0-year park: fewer Maintenance rows). Test toggle.
static var age_maintenance := true
const PHYSICAL_DEPARTMENTS := ["Üretim", "Planlama", "Depo & Sevkiyat", "Bakım", "Kalite"]

var factory_id := ""
var term := 12
var months_left := 0
var prepaid_months := 0
var package_bought := false
var equip: Dictionary = {}
var jobs: Array = []
var loan: Dictionary = {}
var next_uid := 1
var invested := 0.0
var last_lines: Array = []

# ---------------------------------------------------------------- setup

func default_setup(rng_seed := -1) -> String:
	var values := {}
	for skill in SKILLS:
		values[skill] = 60
	var result := configure(values, 600, 400.0, "Manuel", rng_seed, "ikisi", true)
	if result == "":
		phase = "invest"
		notice = "Bir yer kirala; sonra ekipman, tezgah ve iş."
	return result

func factory() -> Dictionary:
	return Data.factory_by_id(factory_id)

# ---------------------------------------------------------------- overrides used by BossState

func scale() -> Dictionary:
	if factory_id == "":
		return SCALES[0]
	match Data.size_class(int(factory()["m2"])):
		"large": return SCALES[2]
		"medium": return SCALES[1]
	return SCALES[0]

func capacity_at_least(quality: int) -> int:
	if not package_bought:
		return 0
	var total := 0
	for machine in delivered():
		if int(machine["level"]) >= quality:
			total += int(machine["capacity"])
	return total

func ordinary_expense() -> float:
	if factory_id == "":
		return 0.0
	var expense := running_cost() + (0.0 if prepaid_months > 0 else base_rent())
	if not loan.is_empty():
		expense += float(loan["installment"])
	return expense

# Known unpaid material tranches for this month-end.
func accepted_cost() -> float:
	var total := 0.0
	for job in jobs:
		total += tranche_due(job)
	return total

func tranche_due(job: Dictionary) -> float:
	var next_elapsed := int(job["elapsed"]) + 1
	if next_elapsed % 6 == 0 and next_elapsed < int(job["months"]) and float(job["material_left"]) > 0.0:
		return minf(float(job["material_left"]), float(job["material_tranche"]))
	return 0.0

# FRZ-003 v2 / FRZ-004 v2: a machine counts toward profit potential only after
# its first full operating month, i.e. once it has been delivered for a month.
func max_gross_profit(park: Array[Dictionary]) -> float:
	var eligible: Array[Dictionary] = []
	for machine in park:
		if int(machine.get("arrive", 0)) < month:
			eligible.append(machine)
	return super.max_gross_profit(eligible)

# ---------------------------------------------------------------- queries

func base_rent() -> float:
	if factory_id == "":
		return 0.0
	return roundf(float(factory()["rent"]) * float(Data.term_by_months(term)["factor"]))

func running_cost() -> float:
	var cost := 0.0
	for machine in delivered():
		cost += float(machine["energy"]) + float(machine["consumables"]) + Data.WAGE * int(machine["personnel"])
	return cost

func delivered() -> Array:
	var list: Array = []
	for machine in machines:
		if int(machine["arrive"]) <= month:
			list.append(machine)
	return list

func free_machines() -> Array:
	var list: Array = []
	for machine in delivered():
		if int(machine["job"]) == 0:
			list.append(machine)
	return list

func package_info() -> Dictionary:
	if factory_id == "":
		return {"items": {}, "price": 0.0, "area": 0.0}
	return Data.package_for(int(factory()["m2"]))

func area_used() -> float:
	var used := 0.0
	for machine in machines:
		used += float(machine["area"])
	if package_bought:
		used += float(package_info()["area"])
	for id in equip:
		used += float(Data.EQUIPMENT[id]["area"]) * int(equip[id])
	return used

func hidden_guarantee() -> float:
	var current := scale()
	return float(MONEY_BANDS[int(current["max_tier"])][1]) * float(current["factor"])

# Greedy assignment of free delivered machines to a job's requirement list.
func assign(reqs: Array) -> Dictionary:
	var pool: Array = free_machines().duplicate()
	var ordered: Array = reqs.duplicate()
	ordered.sort_custom(func(a, b): return int(a["level"]) > int(b["level"]))
	var uids: Array = []
	var missing: Array = []
	for req in ordered:
		var short := int(req["count"])
		for _i in int(req["count"]):
			var best: Dictionary = {}
			for machine in pool:
				if machine["kind"] == req["kind"] and int(machine["level"]) >= int(req["level"]):
					if best.is_empty() or int(machine["level"]) < int(best["level"]):
						best = machine
			if not best.is_empty():
				uids.append(best["uid"])
				pool.erase(best)
				short -= 1
		if short > 0:
			missing.append("%d× %s %s" % [short, Data.LEVELS[int(req["level"])], req["kind"]])
	return {"ok": missing.is_empty(), "uids": uids, "missing": missing}

func owned_count(req: Dictionary) -> int:
	var count := 0
	for machine in delivered():
		if machine["kind"] == req["kind"] and int(machine["level"]) >= int(req["level"]):
			count += 1
	return count

func first_payment(offer: Dictionary) -> float:
	var months: int = offer["months"]
	if months <= 6:
		return float(offer["material"])
	return roundf(float(offer["material"]) * 6.0 / float(months))

func offer_by_id(id: int) -> Dictionary:
	for offer in offers:
		if offer["id"] == id:
			return offer
	return {}

func listing_by_uid(uid: int) -> Dictionary:
	for listing in Data.machine_listings():
		if listing["uid"] == uid:
			return listing
	return {}

func prepay_quote(id: String, months: int) -> Dictionary:
	var target := Data.factory_by_id(id)
	var period := Data.term_by_months(months)
	var rent := roundf(float(target["rent"]) * float(period["factor"]))
	var half := months / 2
	var discount := float(period["prepay_discount"])
	return {"rent": rent, "half": half, "discount": discount, "amount": snappedf(rent * half * (1.0 - discount), 0.01)}

func average_age() -> float:
	var list := delivered()
	if list.is_empty():
		return 0.0
	var total := 0.0
	for machine in list:
		total += float(machine["age"]) + float(month - int(machine["bought_month"])) / 12.0
	return total / list.size()

# ---------------------------------------------------------------- rent, package, machines

func rent_block_reason(id: String, months: int, prepay: bool) -> String:
	if phase == "end":
		return "Oyun bitti."
	if factory_id != "":
		return "Zaten bir yer kiralık."
	var target := Data.factory_by_id(id)
	if target.is_empty():
		return "Bilinmeyen yer."
	var quote := prepay_quote(id, months)
	var due := float(quote["amount"]) if prepay else 0.0
	var first_rent := 0.0 if prepay else float(quote["rent"])
	# FRZ-002 v3 §4: keep the first month's expense and the hidden-fix guarantee.
	var size_scale := SCALES[2] if Data.size_class(int(target["m2"])) == "large" else (SCALES[1] if Data.size_class(int(target["m2"])) == "medium" else SCALES[0])
	var guarantee: float = float(MONEY_BANDS[int(size_scale["max_tier"])][1]) * float(size_scale["factor"])
	var needed := first_rent + guarantee
	if cash - due < needed:
		return "Kiradan sonra kasa %.0f; ilk ay gideri ve gizli sorun güvencesi için en az %.0f gerekli." % [cash - due, needed]
	return ""

func rent_factory(id: String, months: int, prepay: bool) -> String:
	var reason := rent_block_reason(id, months, prepay)
	if reason != "":
		notice = reason
		return reason
	var quote := prepay_quote(id, months)
	factory_id = id
	term = months
	months_left = months
	prepaid_months = 0
	if prepay:
		cash -= float(quote["amount"])
		prepaid_months = int(quote["half"])
	phase = "offers"
	_generate_offers()
	_generate_problems(2)
	history.append("Ay %d: %s kiralandı (%d ay, kira %.0f)." % [month, factory()["name"], term, base_rent()])
	notice = "%s kiralandı. Önce zorunlu ekipmanı al, sonra tezgah ve iş." % factory()["name"]
	return ""

func leave_block_reason() -> String:
	if factory_id == "":
		return "Kiralık yer yok."
	if not loan.is_empty():
		return "İpotekli kredi kapanmadan sözleşme bırakılamaz."
	return ""

func leave_fee() -> float:
	return base_rent() * Data.EXIT_FEE_RENTS

# FRZ-003 v2 direction (IDEA-015): early exit costs two rents; remaining rent debt is 0.
func leave_factory() -> String:
	var reason := leave_block_reason()
	if reason != "":
		return reason
	cash -= leave_fee()
	history.append("Ay %d: %s bırakıldı (çıkış bedeli %.0f)." % [month, factory()["name"], leave_fee()])
	factory_id = ""
	machines.clear()
	jobs.clear()
	offers.clear()
	problems.clear()
	consultants.clear()
	package_bought = false
	equip.clear()
	prepaid_months = 0
	invested = 0.0
	report = {}
	phase = "invest"
	notice = "Sözleşme bırakıldı. Yeni bir yer kiralayabilirsin."
	return ""

func spend_block_reason(price: float) -> String:
	if phase != "offers":
		return "Satın alma yalnızca ay başında (rapordan önce) yapılır."
	if factory_id == "":
		return "Önce bir yer kirala."
	if cash - price < ordinary_expense() + finance_due():
		return "Alımdan sonra kasa bu ayın giderini (%.0f) karşılamıyor." % (ordinary_expense() + finance_due())
	return ""

func package_block_reason() -> String:
	if package_bought:
		return "Paket alındı"
	var info := package_info()
	var reason := spend_block_reason(float(info["price"]))
	if reason != "":
		return reason
	if area_used() + float(info["area"]) > float(factory()["m2"]):
		return "Alan yetmiyor"
	return ""

func buy_package() -> String:
	var reason := package_block_reason()
	if reason != "":
		return reason
	var info := package_info()
	cash -= float(info["price"])
	invested += float(info["price"])
	package_bought = true
	history.append("Ay %d: zorunlu ekipman paketi alındı (%.0f)." % [month, info["price"]])
	notice = "Zorunlu ekipman tamam; kapasite kullanılabilir."
	return ""

func equipment_block_reason(id: String, qty: int) -> String:
	var item: Dictionary = Data.EQUIPMENT[id]
	if item.has("min_height") and float(factory()["height"]) < float(item["min_height"]):
		return "Tavan çok alçak"
	var reason := spend_block_reason(float(item["price"]) * qty)
	if reason != "":
		return reason
	if area_used() + float(item["area"]) * qty > float(factory()["m2"]):
		return "Alan yetmiyor"
	return ""

func buy_equipment(id: String, qty: int) -> String:
	var reason := equipment_block_reason(id, qty)
	if reason != "":
		return reason
	cash -= float(Data.EQUIPMENT[id]["price"]) * qty
	invested += float(Data.EQUIPMENT[id]["price"]) * qty
	equip[id] = int(equip.get(id, 0)) + qty
	return ""

func listing_block_reason(uid: int) -> String:
	var listing := listing_by_uid(uid)
	if listing.is_empty():
		return "Bilinmeyen ilan."
	var reason := spend_block_reason(float(listing["price"]))
	if reason != "":
		return reason
	if area_used() + float(listing["area"]) > float(factory()["m2"]):
		return "Alan yetmiyor"
	if float(listing["height"]) > float(factory()["height"]):
		return "Tavan çok alçak"
	return ""

func buy_listing(uid: int) -> String:
	var reason := listing_block_reason(uid)
	if reason != "":
		return reason
	var listing := listing_by_uid(uid)
	var machine: Dictionary = listing.duplicate()
	machine["uid"] = next_uid
	machine["reference"] = float(listing["price"])
	machine["bought_month"] = month
	machine["arrive"] = month + int(listing["delivery"])
	machine["job"] = 0
	machine["mortgaged"] = false
	next_uid += 1
	cash -= float(listing["price"])
	invested += float(listing["price"])
	machines.append(machine)
	history.append("Ay %d: %s sipariş edildi (%.0f, teslim %d ay)." % [month, listing["model"], listing["price"], listing["delivery"]])
	notice = "%s sipariş edildi; teslimde personel işe başlar." % listing["model"]
	return ""

# ---------------------------------------------------------------- offers and jobs

func _generate_offers() -> void:
	offers.clear()
	if factory_id == "":
		return
	offers.assign(Data.generate_offers(month))

func accept_block_reason(id: int) -> String:
	if phase != "offers":
		return "İş, ay başında (rapordan önce) kabul edilir."
	var offer := offer_by_id(id)
	if offer.is_empty():
		return "İlan bulunamadı."
	if not package_bought:
		return "Zorunlu ekipman eksik"
	var check := assign(offer["reqs"])
	if not check["ok"]:
		return "Eksik: " + ", ".join(check["missing"])
	if first_payment(offer) > cash:
		return "Yetersiz nakit"
	return ""

func accept_offer(id: int) -> String:
	var reason := accept_block_reason(id)
	if reason != "":
		return reason
	var offer := offer_by_id(id)
	var check := assign(offer["reqs"])
	var first := first_payment(offer)
	cash -= first
	var job: Dictionary = offer.duplicate(true)
	job["elapsed"] = 0
	job["eff_sum"] = 0.0
	job["uids"] = check["uids"]
	job["material_left"] = float(offer["material"]) - first
	job["material_tranche"] = roundf(float(offer["material"]) * 6.0 / float(offer["months"]))
	for machine in machines:
		if check["uids"].has(machine["uid"]):
			machine["job"] = job["id"]
	jobs.append(job)
	offers.erase(offer)
	history.append("Ay %d: iş kabul edildi: %s (hammadde %.0f)." % [month, job["title"], first])
	notice = "%s kabul edildi; hammadde %.0f düştü." % [job["title"], first]
	return ""

# ---------------------------------------------------------------- report

func run_report() -> String:
	if phase != "offers":
		return "Rapor ay başından sonra açılır."
	if factory_id == "":
		return "Önce bir yer kirala."
	var expected := 0
	for machine in delivered():
		if int(machine["job"]) != 0 and package_bought:
			expected += int(machine["capacity"])
	var losses: Dictionary = {}
	for root in problems.values():
		if root["active"]:
			losses[root["department"]] = float(losses.get(root["department"], 0.0)) + root["loss"]
			root["total_loss"] += root["loss"]
			if is_visible(root):
				root["ever_seen"] = true
	var total_loss := 0.0
	var physical_loss := 0.0
	var capped := false
	for department in losses:
		var cap := expected * DEPARTMENT_CAP
		if losses[department] > cap:
			losses[department] = cap
			capped = true
		total_loss += losses[department]
		if PHYSICAL_DEPARTMENTS.has(department):
			physical_loss += losses[department]
	var realized := maxf(expected - total_loss, expected * REALIZATION_FLOOR)
	var efficiency := 1.0 if expected == 0 else realized / float(expected)
	for job in jobs:
		job["eff_sum"] = float(job["eff_sum"]) + efficiency
	report = {"expected": expected, "loss": expected - realized, "realized": realized, "revenue": 0.0, "losses": losses,
		"empty": capacity_at_least(1) - expected, "capped": capped, "undelivered": 0, "efficiency": efficiency,
		"oee": 1.0 if expected == 0 else clampf(1.0 - physical_loss / float(expected), 0.0, 1.0), "physical_loss": physical_loss}
	hours_left = monthly_hours - _operator_share()
	month_start_hours = hours_left
	month_flags = {"fix_blocked_money": 0, "fix_blocked_hours": 0, "fixes": 0}
	_generate_candidates()
	phase = "report"
	notice = "Ay raporu hazır. Düzelt ve danışman kararlarının etkisi gelecek ay görünür."
	if expected == 0:
		_find("Ay %d: hiç iş yapılmadı; bütün kapasite boş kaldı." % month)
	return ""

func close_block_reason() -> String:
	if phase != "report":
		return "Önce raporu aç."
	return ""

func close_month() -> String:
	if phase != "report":
		return close_block_reason()
	var lines: Array = []
	var finance := finance_due()
	# rent
	if prepaid_months > 0:
		prepaid_months -= 1
		lines.append("Kira: peşin ödenmişti")
	else:
		cash -= base_rent()
		lines.append("Kira: %s" % Data.usd(base_rent()))
	var running := running_cost()
	cash -= running
	lines.append("Enerji, sarf ve personel: %s" % Data.usd(running))
	# loan installment
	if not loan.is_empty():
		var interest := float(loan["balance"]) * float(loan["rate"])
		var principal := float(loan["installment"]) - interest
		loan["balance"] = maxf(0.0, float(loan["balance"]) - principal)
		debt = maxf(0.0, debt - principal)
		loan["left"] = int(loan["left"]) - 1
		cash -= float(loan["installment"])
		lines.append("Kredi taksidi: %s" % Data.usd(float(loan["installment"])))
		if int(loan["left"]) <= 0:
			debt = maxf(0.0, debt - float(loan["balance"]))
			_release_collateral()
			loan = {}
			lines.append("Kredi kapandı; ipotek kalktı.")
	# jobs: tranches, then delivery paid by average efficiency
	var running_jobs: Array = []
	var delivered_revenue := 0.0
	for job in jobs:
		var tranche := tranche_due(job)
		if tranche > 0.0:
			cash -= tranche
			job["material_left"] = float(job["material_left"]) - tranche
			lines.append("Hammadde dilimi: %s (%s)" % [Data.usd(tranche), job["title"]])
		job["elapsed"] = int(job["elapsed"]) + 1
		if int(job["elapsed"]) >= int(job["months"]):
			var share := clampf(float(job["eff_sum"]) / float(job["months"]), 0.0, 1.0)
			var earned := roundf(float(job["revenue"]) * share)
			cash += earned
			delivered_revenue += earned
			lines.append("Teslim: %s (+%s%s)" % [job["title"], Data.usd(earned), "" if share >= 0.999 else ", verimle %%%d" % int(roundf(share * 100.0))])
			if share < 0.999:
				report["undelivered"] = int(report.get("undelivered", 0)) + 1
			for machine in machines:
				if int(machine["job"]) == int(job["id"]):
					machine["job"] = 0
		else:
			running_jobs.append(job)
	jobs = running_jobs
	report["revenue"] = delivered_revenue
	cash -= finance
	if finance > 0.0:
		lines.append("Finansman gideri: %s" % Data.usd(finance))
	for machine in machines:
		machine["reference"] = roundf(float(machine["reference"]) * (1.0 - DEPRECIATION) * 100.0) / 100.0
	var still_active: Array[Dictionary] = []
	for consultant in consultants:
		consultant["months_left"] -= 1
		if consultant["months_left"] > 0:
			still_active.append(consultant)
		else:
			history.append("Ay %d: %s sözleşmesi bitti; bilgisi fabrikada kalmadı." % [month, consultant["name"]])
	consultants = still_active
	_grow_problems()
	var status := solvency()
	history.append("Ay %d: verim %%%d, gelir %.0f, kasa %.0f, borç açığı %.0f / eşik %.0f" % [month, int(roundf(float(report.get("efficiency", 1.0)) * 100.0)), delivered_revenue, cash, status["gap"], status["threshold"]])
	_check_month()
	notice = "%d. ay kapandı. Kasa %.0f. Borç açığı %.0f, kurtarma eşiği %.0f." % [month, cash, status["gap"], status["threshold"]]
	last_lines = lines
	report = {}
	if status["closes"]:
		_close_factory(status)
		return ""
	month += 1
	months_left -= 1
	if months_left <= 0:
		months_left = term
		last_lines.append("Sözleşme aynı koşulla yenilendi.")
	for machine in machines:
		if int(machine["arrive"]) == month:
			last_lines.append("Teslim alındı: %s · %d personel işe başladı" % [machine["model"], machine["personnel"]])
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

# Age proposal (IDEA-016): Maintenance rows are born less often on a young park.
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
		if age_maintenance and department == "Bakım":
			var accept_chance := clampf(0.4 + 0.1 * average_age(), 0.4, 1.0)
			if rng.randf() > accept_chance:
				continue
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

# ---------------------------------------------------------------- mortgage loan

func current_value(machine: Dictionary) -> float:
	return float(machine["reference"])

func loan_terms() -> Dictionary:
	var offer: Dictionary = Data.CREDIT
	return {"amount": float(offer["amount"]), "installment": Data.installment(float(offer["amount"]), float(offer["rate"]), int(offer["months"])),
		"need": float(offer["amount"]) * float(offer["collateral"])}

func loan_block_reason(uids: Array) -> String:
	if not loan.is_empty():
		return "Aktif bir kredi var."
	if phase != "offers" and phase != "report":
		return "Kredi yalnızca fabrika açıkken alınır."
	var total := 0.0
	for machine in delivered():
		if uids.has(machine["uid"]) and not machine["mortgaged"]:
			total += current_value(machine)
	if total < float(loan_terms()["need"]):
		return "Teminat yetersiz (%.0f gerek)" % float(loan_terms()["need"])
	return ""

func take_loan(uids: Array) -> String:
	var reason := loan_block_reason(uids)
	if reason != "":
		return reason
	var terms := loan_terms()
	loan = {"balance": float(terms["amount"]), "rate": float(Data.CREDIT["rate"]), "installment": float(terms["installment"]),
		"left": int(Data.CREDIT["months"]), "uids": uids.duplicate()}
	for machine in machines:
		if uids.has(machine["uid"]):
			machine["mortgaged"] = true
	cash += float(terms["amount"])
	debt += float(terms["amount"])
	history.append("Ay %d: %s kredisi %.0f alındı (%d makine ipotekli)." % [month, Data.CREDIT["bank"], terms["amount"], uids.size()])
	notice = "Kredi alındı; kasa ve borç aynı tutarda arttı."
	return ""

func loan_close_cost() -> float:
	if loan.is_empty():
		return 0.0
	return float(loan["balance"]) * (1.0 + float(Data.CREDIT["early_fee"]))

func close_loan() -> String:
	if loan.is_empty():
		return "Aktif kredi yok."
	if loan_close_cost() > cash:
		return "Yetersiz nakit"
	cash -= loan_close_cost()
	debt = maxf(0.0, debt - float(loan["balance"]))
	_release_collateral()
	loan = {}
	notice = "Kredi erken kapatıldı; ipotek kalktı."
	return ""

func _release_collateral() -> void:
	for machine in machines:
		machine["mortgaged"] = false
