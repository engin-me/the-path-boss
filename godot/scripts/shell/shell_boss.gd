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
# FRZ-004 v2 §1A analogue: at least this many of the 20 offers fit the delivered park (0 = off).
static var pool_floor := 12
const PHYSICAL_DEPARTMENTS := ["Üretim", "Planlama", "Depo & Sevkiyat", "Bakım", "Kalite"]
const AVAILABILITY_DEPARTMENTS := ["Bakım", "Planlama", "Depo & Sevkiyat"]
# Legacy problem scale: a problem's loss (2-6 units x scale factor) is measured against
# this many units per delivered machine, so 6 units on one machine is 12 percent.
const LOSS_UNITS_PER_MACHINE := 50.0
const LATE_CANCEL_MONTHS := 3

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
var offer_salt := 0
var delivery_score := 0.8
var patron_overtime := false
var auto_order := true
var default_supplier := "nord"

# ---------------------------------------------------------------- save / load

const BASE_FIELDS := ["phase", "persona", "budget", "skills", "diploma", "start_cash", "cash", "debt", "credit_used", "month", "max_months",
	"offer_history", "accepted", "report", "problems", "next_id", "consultants", "candidates", "hours_left", "month_start_hours",
	"prevented_this_month", "prevented_total", "history", "findings", "month_flags", "closure", "notice"]
const SHELL_FIELDS := ["factory_id", "term", "months_left", "prepaid_months", "package_bought", "equip", "jobs", "loan", "next_uid",
	"invested", "last_lines", "offer_salt", "delivery_score", "patron_overtime", "auto_order", "default_supplier"]

func to_save() -> Dictionary:
	var data := {}
	for field in BASE_FIELDS + SHELL_FIELDS:
		data[field] = get(field)
	data["machines"] = machines.duplicate(true)
	data["offers"] = offers.duplicate(true)
	data["rng_seed"] = rng.seed
	data["rng_state"] = rng.state
	return data.duplicate(true)

# Returns "" on success, else the reason the save was rejected.
func from_save(data: Dictionary) -> String:
	for field in BASE_FIELDS + SHELL_FIELDS + ["machines", "offers", "rng_seed", "rng_state"]:
		if not data.has(field):
			return "Kayıtta '%s' alanı yok." % field
	var copy: Dictionary = data.duplicate(true)
	for field in BASE_FIELDS + SHELL_FIELDS:
		set(field, copy[field])
	machines.assign(copy["machines"])
	offers.assign(copy["offers"])
	rng.seed = int(copy["rng_seed"])
	rng.state = int(copy["rng_state"])
	return ""

# ---------------------------------------------------------------- setup

func default_setup(rng_seed := -1) -> String:
	var values := {}
	for skill in SKILLS:
		values[skill] = 60
	var result := configure(values, 600, Data.start_cash, "Manuel", rng_seed, "ikisi", true)
	offer_salt = rng_seed if rng_seed >= 0 else int(Time.get_ticks_usec() % 100000)
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

# Legacy meaning for BossState's problem generator: problem-scale units, not x.
func capacity_at_least(_quality: int) -> int:
	if not package_bought:
		return 0
	return int(LOSS_UNITS_PER_MACHINE * delivered().size())

func ordinary_expense() -> float:
	if factory_id == "":
		return 0.0
	var expense := running_cost() + (0.0 if prepaid_months > 0 else base_rent())
	if not loan.is_empty():
		expense += float(loan["installment"])
	return expense

# Known unpaid material for this month-end (supplier payment terms).
func accepted_cost() -> float:
	var total := 0.0
	for job in jobs:
		total += material_due(job)
	return total

func material_due(job: Dictionary) -> float:
	var order: Dictionary = job.get("order", {})
	if order.is_empty() or order["paid"]:
		return 0.0
	return float(order["amount"]) if int(order["pay_month"]) <= month else 0.0

# FRZ-003 v2 / FRZ-004 v2: a machine counts toward profit potential only after
# its first full operating month. Potential = structural good output at the
# current shifts x price per x x (1 - average material share).
func max_gross_profit(park: Array[Dictionary]) -> float:
	var total := 0.0
	for machine in park:
		if int(machine.get("arrive", 0)) >= month or not package_bought:
			continue
		var good := float(machine["nameplate"]) * availability(machine) * float(machine["perf"]) * (1.0 - float(machine["scrap"]))
		total += good * Data.price_x(machine["kind"]) * 0.5
	return total

# ---------------------------------------------------------------- queries

func base_rent() -> float:
	if factory_id == "":
		return 0.0
	return roundf(float(factory()["rent"]) * Data.rent_scale * float(Data.term_by_months(term)["factor"]))

func running_cost() -> float:
	var cost := 0.0
	for machine in delivered():
		cost += machine_running_cost(machine)
	return cost

func delivered() -> Array:
	var list: Array = []
	for machine in machines:
		if int(machine["arrive"]) <= month:
			list.append(machine)
	return list

# ---------------------------------------------------------------- shifts, patron, OEE (IDEA-018)

func shift_equiv(machine: Dictionary) -> float:
	var shifts := float(machine["shifts"])
	if machine.get("patron", false) and patron_overtime:
		shifts += 0.5
	return minf(shifts, 3.0)

func availability(machine: Dictionary) -> float:
	return shift_equiv(machine) / 3.0

func machine_running_cost(machine: Dictionary) -> float:
	var wages := 0.0
	for shift in range(1, int(machine["shifts"]) + 1):
		if shift == 1 and machine.get("patron", false):
			continue
		wages += Data.WAGE * int(machine["personnel"])
	return (float(machine["energy"]) + float(machine["consumables"])) * shift_equiv(machine) + wages

func patron_machine() -> Dictionary:
	for machine in machines:
		if machine.get("patron", false):
			return machine
	return {}

func patron_hours() -> int:
	if patron_machine().is_empty():
		return 0
	var share: int = monthly_hours / 2
	if patron_overtime:
		share += share / 2
	return share

func _operator_share() -> int:
	return patron_hours()

func hidden_hour_cap() -> int:
	return int(HOUR_BANDS[int(scale()["max_tier"])][1])

func patron_block_reason(uid: int, overtime: bool) -> String:
	var machine := machine_by_uid(uid)
	if machine.is_empty():
		return "Makine bulunamadı."
	if int(machine["personnel"]) != 1:
		return "Bu makine tek kişiyle çalışmaz"
	var share: int = monthly_hours / 2
	if overtime:
		share += share / 2
	if monthly_hours - share < hidden_hour_cap():
		return "Gizli Düzelt için yönetim saati kalmaz (%d sa gerekli)" % hidden_hour_cap()
	return ""

func set_patron(uid: int, on: bool) -> String:
	if phase != "offers":
		return "Vardiya ay başında (rapordan önce) ayarlanır."
	var machine := machine_by_uid(uid)
	if machine.is_empty():
		return "Makine bulunamadı."
	if on:
		var reason := patron_block_reason(uid, patron_overtime)
		if reason != "":
			return reason
		for other in machines:
			other["patron"] = false
	machine["patron"] = on
	if not on:
		patron_overtime = false
	return ""

func set_overtime(on: bool) -> String:
	if phase != "offers":
		return "Mesai ay başında (rapordan önce) ayarlanır."
	var machine := patron_machine()
	if on and machine.is_empty():
		return "Önce bir makineyi sen çalıştırmalısın."
	if on:
		var reason := patron_block_reason(machine["uid"], true)
		if reason != "":
			return reason
	patron_overtime = on
	return ""

func set_shifts(uid: int, shifts: int) -> String:
	if phase != "offers":
		return "Vardiya ay başında (rapordan önce) ayarlanır."
	var machine := machine_by_uid(uid)
	if machine.is_empty():
		return "Makine bulunamadı."
	machine["shifts"] = clampi(shifts, 1, 3)
	return ""

# A solo patron runs the first single-operator machine that arrives.
func _auto_patron() -> void:
	if not patron_machine().is_empty():
		return
	for machine in delivered():
		if int(machine["personnel"]) == 1 and patron_block_reason(machine["uid"], false) == "":
			machine["patron"] = true
			return

func _enforce_patron() -> void:
	var machine := patron_machine()
	if machine.is_empty():
		return
	if patron_block_reason(machine["uid"], patron_overtime) != "":
		patron_overtime = false
		if patron_block_reason(machine["uid"], false) != "":
			machine["patron"] = false
			_find("Ay %d: yönetim saati yetmediği için patron vardiyası kapandı." % month)

func loss_fractions() -> Dictionary:
	var denom := LOSS_UNITS_PER_MACHINE * maxf(1.0, float(delivered().size()))
	var by_dept := {}
	for root in problems.values():
		if root["active"]:
			by_dept[root["department"]] = float(by_dept.get(root["department"], 0.0)) + float(root["loss"]) / denom
	var capped := false
	for department in by_dept:
		if by_dept[department] > DEPARTMENT_CAP:
			by_dept[department] = DEPARTMENT_CAP
			capped = true
	var avail := 0.0
	var non := 0.0
	for department in by_dept:
		if AVAILABILITY_DEPARTMENTS.has(department):
			avail += by_dept[department]
		elif not PHYSICAL_DEPARTMENTS.has(department):
			non += by_dept[department]
	return {"by_dept": by_dept, "A": avail, "P": float(by_dept.get("Üretim", 0.0)), "Q": float(by_dept.get("Kalite", 0.0)), "N": non, "capped": capped}

# Problem multipliers: physical (availability x performance x quality) and non-physical,
# with the 33 percent realisation floor on their product.
func problem_mults(fr: Dictionary) -> Dictionary:
	var physical := (1.0 - float(fr["A"])) * (1.0 - float(fr["P"])) * (1.0 - float(fr["Q"]))
	var non := 1.0 - float(fr["N"])
	var total := maxf(REALIZATION_FLOOR, physical * non)
	var non_eff := minf(1.0, total / maxf(physical, 0.0001))
	return {"phys": physical, "non": non_eff, "a": 1.0 - float(fr["A"]), "p": 1.0 - float(fr["P"]), "q": 1.0 - float(fr["Q"])}

func machine_steps(machine: Dictionary, mults: Dictionary) -> Dictionary:
	var theoretical := float(machine["nameplate"])
	var after_shift := theoretical * availability(machine)
	var after_perf := after_shift * float(machine["perf"])
	var after_scrap := after_perf * (1.0 - float(machine["scrap"]))
	var after_phys := after_scrap * float(mults["phys"])
	return {"theoretical": theoretical, "shift": after_shift, "perf": after_perf, "scrap": after_scrap, "phys": after_phys, "net": after_phys * float(mults["non"])}

func machine_output(machine: Dictionary, mults: Dictionary) -> float:
	if not package_bought or int(machine["arrive"]) > month:
		return 0.0
	return float(machine_steps(machine, mults)["net"])

func effective_capacity(kind := "") -> float:
	var mults := problem_mults(loss_fractions())
	var total := 0.0
	for machine in delivered():
		if kind == "" or machine["kind"] == kind:
			total += machine_output(machine, mults)
	return total

# Structural capacity waterfall for the delivered park at the current shifts and problems.
func capacity_steps() -> Dictionary:
	var mults := problem_mults(loss_fractions())
	var sums := {"theoretical": 0.0, "shift": 0.0, "perf": 0.0, "scrap": 0.0, "phys": 0.0, "net": 0.0}
	for machine in delivered():
		var steps := machine_steps(machine, mults)
		for key in sums:
			sums[key] += float(steps[key]) if package_bought or key == "theoretical" else 0.0
	sums["used"] = 0.0
	sums["idle"] = sums["net"]
	sums["oee"] = 0.0 if float(sums["theoretical"]) <= 0.0 else float(sums["phys"]) / float(sums["theoretical"])
	return sums

func oee_now() -> float:
	var mults := problem_mults(loss_fractions())
	var theoretical := 0.0
	var good := 0.0
	for machine in delivered():
		var steps := machine_steps(machine, mults)
		theoretical += float(steps["theoretical"])
		good += float(steps["phys"])
	return 0.0 if theoretical <= 0.0 else good / theoretical

func machine_by_uid(uid: int) -> Dictionary:
	for machine in machines:
		if machine["uid"] == uid:
			return machine
	return {}

func owns(req: Dictionary) -> bool:
	for machine in machines:
		if machine["kind"] == req["kind"] and int(machine["level"]) >= int(req["level"]):
			return true
	return false

func owned_count(req: Dictionary) -> int:
	var count := 0
	for machine in machines:
		if machine["kind"] == req["kind"] and int(machine["level"]) >= int(req["level"]):
			count += 1
	return count

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

# Cash needed on acceptance: the material order of a cash-on-order supplier, net of the advance.
func first_payment(offer: Dictionary) -> float:
	if not auto_order:
		return 0.0
	var supplier := Data.supplier_by_id(default_supplier)
	if int(supplier["terms"]) > 0:
		return 0.0
	return maxf(0.0, float(offer["material"]) * float(supplier["price"]) - advance_of(offer))

func advance_of(offer: Dictionary) -> float:
	return roundf(float(offer["revenue"]) * Data.ADVANCE_RATE)

func material_quote(job_or_offer: Dictionary, supplier_id: String) -> Dictionary:
	var supplier := Data.supplier_by_id(supplier_id)
	var amount := roundf(float(job_or_offer["material"]) * float(supplier["price"]))
	return {"supplier": supplier, "amount": amount, "lead": int(supplier["lead"]), "terms": int(supplier["terms"]), "delay": float(supplier["delay"]),
		"quality": int(supplier["quality"]), "yield": float(Data.QUALITY_YIELD[int(supplier["quality"])])}

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
	var rent := roundf(float(target["rent"]) * Data.rent_scale * float(period["factor"]))
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
	machine["shifts"] = 1
	machine["patron"] = false
	machine["used_last"] = 0.0
	machine["output_last"] = 0.0
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
	offers.assign(Data.generate_offers(month, offer_salt))
	_apply_pool_floor()

func _feasible(reqs: Array) -> bool:
	for req in reqs:
		if not owns(req):
			return false
	return true

# FRZ-004 v2 §1A analogue: rewrites infeasible offers so that at least `pool_floor`
# fit the owned park (delivered or on order). Workload is sized to the park.
func _apply_pool_floor() -> void:
	if pool_floor <= 0 or machines.is_empty():
		return
	var feasible := 0
	for offer in offers:
		if _feasible(offer["reqs"]):
			feasible += 1
	for offer in offers:
		if feasible >= pool_floor:
			break
		if _feasible(offer["reqs"]):
			continue
		var machine: Dictionary = machines[rng.randi_range(0, machines.size() - 1)]
		var level := rng.randi_range(1, int(machine["level"]))
		var same := 0
		for other in machines:
			if other["kind"] == machine["kind"] and int(other["level"]) >= level:
				same += 1
		Data.fill_offer(offer, [{"kind": machine["kind"], "level": level, "n": mini(maxi(1, int(offer["count"])), same)}], rng)
		feasible += 1

func accept_block_reason(id: int) -> String:
	if phase != "offers":
		return "İş, ay başında (rapordan önce) kabul edilir."
	var offer := offer_by_id(id)
	if offer.is_empty():
		return "İlan bulunamadı."
	if not package_bought:
		return "Zorunlu ekipman eksik"
	var missing: Array = []
	for req in offer["reqs"]:
		if not owns(req):
			missing.append("%s %s" % [Data.LEVELS[int(req["level"])], req["kind"]])
	if not missing.is_empty():
		return "Makine yok: " + ", ".join(missing)
	if first_payment(offer) > cash:
		return "Yetersiz nakit"
	return ""

func accept_offer(id: int) -> String:
	var reason := accept_block_reason(id)
	if reason != "":
		return reason
	var offer := offer_by_id(id)
	var advance := advance_of(offer)
	cash += advance
	var job: Dictionary = offer.duplicate(true)
	job["elapsed"] = 0
	job["accepted_month"] = month
	job["start_month"] = month + int(offer["start_delay"])
	job["due_month"] = month + int(offer["months"]) - 1
	job["produced"] = 0.0
	job["yield"] = 1.0
	job["advance"] = advance
	job["order"] = {}
	jobs.append(job)
	offers.erase(offer)
	history.append("Ay %d: iş kabul edildi: %s (peşinat %.0f)." % [month, job["title"], advance])
	notice = "%s kabul edildi; %.0f peşinat kasaya girdi." % [job["title"], advance]
	if auto_order:
		var result := order_material(job["id"], default_supplier)
		if result != "":
			notice += " Hammadde otomatik sipariş edilemedi: " + result
	return ""

func order_block_reason(job_id: int, supplier_id: String) -> String:
	var job := job_by_id(job_id)
	if job.is_empty():
		return "İş bulunamadı."
	if not job["order"].is_empty():
		return "Hammadde zaten sipariş edildi."
	if phase != "offers" and phase != "report":
		return "Şu an sipariş verilemez."
	var quote := material_quote(job, supplier_id)
	if int(quote["terms"]) == 0 and float(quote["amount"]) > cash:
		return "Yetersiz nakit (peşin %.0f)" % float(quote["amount"])
	return ""

# Orders the job's material from a supplier: it arrives after the lead time (+1 month when delayed),
# is paid after the payment terms, and its quality grade sets the job's yield.
func order_material(job_id: int, supplier_id: String) -> String:
	var reason := order_block_reason(job_id, supplier_id)
	if reason != "":
		return reason
	var job := job_by_id(job_id)
	var quote := material_quote(job, supplier_id)
	var delayed := rng.randf() < float(quote["delay"])
	var order := {"supplier": supplier_id, "order_month": month, "arrive_month": month + int(quote["lead"]) + (1 if delayed else 0),
		"pay_month": month + int(quote["terms"]), "amount": float(quote["amount"]), "paid": false, "delayed": delayed}
	job["order"] = order
	job["yield"] = float(quote["yield"])
	if int(quote["terms"]) == 0:
		cash -= float(quote["amount"])
		order["paid"] = true
	history.append("Ay %d: hammadde siparişi: %s ← %s (%.0f, gelir Ay %d)." % [month, job["title"], quote["supplier"]["name"], quote["amount"], order["arrive_month"]])
	return ""

func abandon_penalty(job: Dictionary) -> float:
	return roundf(float(job["revenue"]) * Data.ABANDON_PENALTY)

func job_by_id(id: int) -> Dictionary:
	for job in jobs:
		if job["id"] == id:
			return job
	return {}

func abandon_block_reason(id: int) -> String:
	var job := job_by_id(id)
	if job.is_empty():
		return "İş bulunamadı."
	if phase != "offers" and phase != "report":
		return "İş şu an bırakılamaz."
	if abandon_penalty(job) + float(job["advance"]) > cash:
		return "Yetersiz nakit (ceza + peşinat iadesi %.0f)" % (abandon_penalty(job) + float(job["advance"]))
	return ""

# The job is dropped: the advance is refunded, the penalty is paid, material already
# paid or ordered is lost, and the delivery score falls.
func abandon_job(id: int) -> String:
	var reason := abandon_block_reason(id)
	if reason != "":
		return reason
	var job := job_by_id(id)
	var penalty := abandon_penalty(job)
	cash -= penalty + float(job["advance"])
	jobs.erase(job)
	_score_event(0.0)
	history.append("Ay %d: iş bırakıldı: %s (ceza %.0f, peşinat iade %.0f, hammadde yandı)." % [month, job["title"], penalty, job["advance"]])
	notice = "%s bırakıldı; ceza %.0f, peşinat iade edildi, ödenen hammadde kayıp, teslimat skoru düştü." % [job["title"], penalty]
	return ""

# Delivery score in 0..1: on time pulls toward 1, late toward 0.4, dropped jobs toward 0.
func _score_event(target: float) -> void:
	delivery_score = clampf(delivery_score * 0.8 + target * 0.2, 0.0, 1.0)

func sale_income(machine: Dictionary) -> float:
	return roundf(float(machine["reference"]) * Data.SALE_RATE)

func sell_block_reason(uid: int) -> String:
	var machine := machine_by_uid(uid)
	if machine.is_empty():
		return "Makine bulunamadı."
	if phase != "offers" and phase != "report":
		return "Makine şu an satılamaz."
	if int(machine["arrive"]) > month:
		return "Henüz teslim alınmadı"
	if machine["mortgaged"]:
		return "İpotekli (kredi kapanmadan satılamaz)"
	return ""

func sell_machine_uid(uid: int) -> String:
	var reason := sell_block_reason(uid)
	if reason != "":
		return reason
	var machine := machine_by_uid(uid)
	var income := sale_income(machine)
	cash += income
	machines.erase(machine)
	history.append("Ay %d: %s satıldı (+%.0f)." % [month, machine["model"], income])
	notice = "%s satıldı; %.0f nakit girdi, etkin kapasite azaldı." % [machine["model"], income]
	return ""

# ---------------------------------------------------------------- production (FIFO load on machines)

func material_ready(job: Dictionary, t: int) -> bool:
	var order: Dictionary = job.get("order", {})
	return not order.is_empty() and int(order["arrive_month"]) <= t

func _eligible(kind: String, level: int, t: int) -> Array:
	var list: Array = []
	for machine in machines:
		if machine["kind"] == kind and int(machine["level"]) >= level and int(machine["arrive"]) <= t:
			list.append(machine)
	list.sort_custom(func(a, b): return int(a["level"]) < int(b["level"]))
	return list

# FIFO: jobs take capacity in acceptance order; each requirement draws from
# eligible machines of its kind, lowest sufficient level first.
func _allocate(job_list: Array, cap_left: Dictionary, t: int, record: bool) -> void:
	for job in job_list:
		if int(job["start_month"]) > t or not material_ready(job, t):
			continue
		var job_yield := float(job.get("yield", 1.0))
		for req in job["reqs"]:
			var need := float(req["remaining"])
			if need <= 0.0001:
				continue
			for machine in _eligible(req["kind"], int(req["level"]), t):
				if need <= 0.0001:
					break
				var available := float(cap_left.get(machine["uid"], 0.0))
				if available <= 0.0:
					continue
				var use := minf(available, need / job_yield)
				cap_left[machine["uid"]] = available - use
				var got := use * job_yield
				need -= got
				req["remaining"] = maxf(0.0, need)
				job["produced"] = float(job.get("produced", 0.0)) + got
				if record:
					machine["used_last"] = float(machine.get("used_last", 0.0)) + use

func job_done(job: Dictionary) -> bool:
	for req in job["reqs"]:
		if float(req["remaining"]) > 0.5:
			return false
	return true

func job_remaining(job: Dictionary) -> float:
	var total := 0.0
	for req in job["reqs"]:
		total += float(req["remaining"])
	return total

func job_workload(job: Dictionary) -> float:
	var total := 0.0
	for req in job["reqs"]:
		total += float(req["workload"])
	return total

# Projected finish month for each job at today's capacity (0 = not within a year).
func projection() -> Dictionary:
	var copy: Array = jobs.duplicate(true)
	var mults := problem_mults(loss_fractions())
	var finish := {}
	for t in range(month, month + 13):
		var cap_left := {}
		for machine in machines:
			if int(machine["arrive"]) <= t:
				cap_left[machine["uid"]] = machine_output(machine, mults) if package_bought else 0.0
		# machine_output gates on arrival <= current month; recompute for future arrivals
		for machine in machines:
			if int(machine["arrive"]) <= t and package_bought:
				var steps := machine_steps(machine, mults)
				cap_left[machine["uid"]] = float(steps["net"])
		_allocate(copy, cap_left, t, false)
		for job in copy:
			if not finish.has(job["id"]) and job_done(job):
				finish[job["id"]] = t
	for job in copy:
		if not finish.has(job["id"]):
			finish[job["id"]] = 0
	return finish

# ---------------------------------------------------------------- report

func run_report() -> String:
	if phase != "offers":
		return "Rapor ay başından sonra açılır."
	if factory_id == "":
		return "Önce bir yer kirala."
	_auto_patron()
	_enforce_patron()
	var fr := loss_fractions()
	var mults := problem_mults(fr)
	var cap_left := {}
	var sums := {"theoretical": 0.0, "shift": 0.0, "perf": 0.0, "scrap": 0.0, "phys": 0.0, "net": 0.0}
	for machine in delivered():
		var steps := machine_steps(machine, mults)
		var output := float(steps["net"]) if package_bought else 0.0
		machine["used_last"] = 0.0
		machine["output_last"] = output
		cap_left[machine["uid"]] = output
		for key in sums:
			sums[key] += float(steps[key]) if package_bought or key == "theoretical" else 0.0
	_allocate(jobs, cap_left, month, true)
	var used := 0.0
	for machine in delivered():
		used += float(machine["used_last"])
	for root in problems.values():
		if root["active"]:
			root["total_loss"] += root["loss"]
			if is_visible(root):
				root["ever_seen"] = true
	var theoretical: float = sums["theoretical"]
	report = {"theoretical": theoretical, "shift": sums["shift"], "perf": sums["perf"], "scrap": sums["scrap"], "phys": sums["phys"], "net": sums["net"],
		"used": used, "idle": maxf(0.0, float(sums["net"]) - used), "oee": 0.0 if theoretical <= 0.0 else float(sums["phys"]) / theoretical,
		"by_dept": fr["by_dept"], "capped": fr["capped"], "revenue": 0.0, "undelivered": 0,
		"mults": mults, "score": delivery_score}
	hours_left = monthly_hours - _operator_share()
	month_start_hours = hours_left
	month_flags = {"fix_blocked_money": 0, "fix_blocked_hours": 0, "fixes": 0}
	_generate_candidates()
	phase = "report"
	notice = "Ay raporu hazır. Düzelt ve danışman kararlarının etkisi gelecek ay görünür."
	if jobs.is_empty():
		_find("Ay %d: kabul edilmiş iş yok; bütün kapasite boş kaldı." % month)
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
	if prepaid_months > 0:
		prepaid_months -= 1
		lines.append("Kira: peşin ödenmişti")
	else:
		cash -= base_rent()
		lines.append("Kira: %s" % Data.usd(base_rent()))
	var running := running_cost()
	cash -= running
	lines.append("Enerji, sarf ve personel: %s" % Data.usd(running))
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
	# jobs: supplier payments, delivery when the workload is done, cancellation when very late
	var running_jobs: Array = []
	var delivered_revenue := 0.0
	for job in jobs:
		var due := material_due(job)
		if due > 0.0:
			cash -= due
			job["order"]["paid"] = true
			lines.append("Hammadde ödemesi: %s (%s)" % [Data.usd(due), job["title"]])
		job["elapsed"] = int(job["elapsed"]) + 1
		if job_done(job):
			var on_time := month <= int(job["due_month"])
			var remainder := float(job["revenue"]) - float(job["advance"])
			cash += remainder
			delivered_revenue += float(job["revenue"])
			_score_event(1.0 if on_time else 0.4)
			lines.append("Teslim: %s (+%s kalan bakiye)%s" % [job["title"], Data.usd(remainder), "" if on_time else " · GEÇ TESLİM (skor düştü)"])
			if not on_time:
				report["undelivered"] = int(report.get("undelivered", 0)) + 1
		elif month > int(job["due_month"]) + LATE_CANCEL_MONTHS:
			var penalty := abandon_penalty(job)
			cash -= penalty + float(job["advance"])
			_score_event(0.0)
			lines.append("İptal: %s müşteri tarafından iptal edildi (ceza %s, peşinat iade %s, hammadde yandı)" % [job["title"], Data.usd(penalty), Data.usd(float(job["advance"]))])
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
	history.append("Ay %d: OEE %%%d, gelir %.0f, kasa %.0f, borç açığı %.0f / eşik %.0f" % [month, int(roundf(float(report.get("oee", 0.0)) * 100.0)), delivered_revenue, cash, status["gap"], status["threshold"]])
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
	_auto_patron()
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
