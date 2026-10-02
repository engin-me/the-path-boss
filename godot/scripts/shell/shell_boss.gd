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
const COUNTER_BAND := 0.10  # prices up to 10 percent above the customer's limit get a counter-offer

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
var quote_mode := true
var mails: Array = []
var next_mail := 1
var plan_shifts := 1   # factory shift plan (applies to every machine; machines can still differ in tests)
var plan_ot := [false, false, false]   # overtime per shift row
var staff_policy := 1   # index into Data.STAFF_POLICIES
var plan_patron := true   # the owner runs the first shift of one single-operator machine
var layout := {}   # factory_id -> item key -> {x, y, rot}: cosmetic floor arrangement (IDEA-013)

# Fix costs of problems scaled to the real-world money of the shell (operator about $1k a month).
const SHELL_MONEY_BANDS := {1: [0.9, 1.5], 2: [1.8, 2.7], 3: [3.75, 5.25], 4: [7.5, 10.5], 5: [15.0, 21.0]}

# ---------------------------------------------------------------- save / load

const BASE_FIELDS := ["phase", "persona", "budget", "skills", "diploma", "start_cash", "cash", "debt", "credit_used", "month", "max_months",
	"offer_history", "accepted", "report", "problems", "next_id", "consultants", "candidates", "hours_left", "month_start_hours",
	"prevented_this_month", "prevented_total", "history", "findings", "month_flags", "closure", "notice"]
const SHELL_FIELDS := ["factory_id", "term", "months_left", "prepaid_months", "package_bought", "equip", "jobs", "loan", "next_uid",
	"invested", "last_lines", "offer_salt", "delivery_score", "patron_overtime", "auto_order", "default_supplier", "quote_mode", "mails", "next_mail"]

func to_save() -> Dictionary:
	var data := {}
	for field in BASE_FIELDS + SHELL_FIELDS:
		data[field] = get(field)
	data["machines"] = machines.duplicate(true)
	data["layout"] = layout.duplicate(true)
	data["plan_shifts"] = plan_shifts
	data["plan_ot"] = plan_ot.duplicate()
	data["plan_patron"] = plan_patron
	data["staff_policy"] = staff_policy
	data["offers"] = offers.duplicate(true)
	data["rng_seed"] = rng.seed
	data["rng_state"] = rng.state
	return data.duplicate(true)

# Returns "" on success, else the reason the save was rejected.
func from_save(data: Dictionary) -> String:
	for field in BASE_FIELDS + SHELL_FIELDS + ["machines", "offers", "rng_seed", "rng_state"]:
		if not data.has(field):
			return "Kayıtta '%s' alanı yok." % field
	var saved_factory := String(data.get("factory_id", ""))
	if saved_factory != "" and Data.factory_by_id(saved_factory).is_empty():
		return "Kayıttaki fabrika ('%s') artık yok; eski sürümden kalmış." % saved_factory
	var copy: Dictionary = data.duplicate(true)
	for field in BASE_FIELDS + SHELL_FIELDS:
		set(field, copy[field])
	machines.assign(copy["machines"])
	layout = copy.get("layout", {})
	plan_shifts = int(copy.get("plan_shifts", 1))
	plan_ot = copy.get("plan_ot", [false, false, false]).duplicate()
	plan_patron = bool(copy.get("plan_patron", true))
	staff_policy = clampi(int(copy.get("staff_policy", 1)), 0, Data.STAFF_POLICIES.size() - 1)
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
		var good := float(machine["nameplate"]) * availability(machine) * float(machine["perf"]) * (1.0 - machine_scrap(machine))
		total += good * Data.price_x(machine["kind"]) * 0.5
	return total

# ---------------------------------------------------------------- queries

func base_rent() -> float:
	if factory_id == "":
		return 0.0
	return snappedf(float(factory()["rent"]) * Data.rent_scale * float(Data.term_by_months(term)["factor"]), 0.001)

func running_cost() -> float:
	var cost := plant_fixed_cost()
	for machine in delivered():
		cost += machine_running_cost(machine)
	return cost

# Building overhead (tax, service charge, heating, security), indirect staff and the office, paid every month.
func building_overhead() -> float:
	return float(factory()["m2"]) * Data.BUILDING_EXTRA_PER_M2 / 1000.0 if factory_id != "" else 0.0

func indirect_count() -> int:
	return staff_count() / Data.INDIRECT_RATIO

func indirect_cost() -> float:
	return float(indirect_count()) * Data.INDIRECT_WAGE

# White collar join in order of importance once the plant has more than three machines.
func office_roles() -> Array:
	var count := delivered().size()
	var roles: Array = []
	for role in Data.OFFICE_ROLES:
		if count >= int(role["at"]):
			roles.append(role)
	var last_at: int = int(Data.OFFICE_ROLES[Data.OFFICE_ROLES.size() - 1]["at"])
	if count >= last_at + Data.OFFICE_EXTRA_EVERY:
		var extra := (count - last_at) / Data.OFFICE_EXTRA_EVERY
		for i in extra:
			roles.append({"name": "Ofis çalışanı", "at": last_at + Data.OFFICE_EXTRA_EVERY * (i + 1), "cost": Data.OFFICE_EXTRA_COST})
	return roles

func office_cost() -> float:
	var total := 0.0
	for role in office_roles():
		total += float(role["cost"])
	return total

func plant_fixed_cost() -> float:
	return building_overhead() + indirect_cost() + office_cost() if factory_id != "" else 0.0

# What the month really costs after the report: wages always, energy and consumables only for the share of
# the month a machine actually worked.
func running_cost_actual() -> float:
	var cost := plant_fixed_cost()
	for machine in delivered():
		var potential := float(machine.get("output_last", 0.0))
		var worked := clampf(float(machine.get("used_last", 0.0)) / potential, 0.0, 1.0) if potential > 0.0 else 0.0
		cost += (machine_energy(machine) * shift_equiv(machine) + machine_maintenance(machine)) * worked + machine_wages(machine)
	return cost

func delivered() -> Array:
	var list: Array = []
	for machine in machines:
		if int(machine["arrive"]) <= month:
			list.append(machine)
	return list

# ---------------------------------------------------------------- shifts, patron, OEE (IDEA-018)

func shift_equiv(machine: Dictionary) -> float:
	var equiv := 0.0
	for i in clampi(int(machine["shifts"]), 1, 3):
		equiv += 1.0 + (Data.OT_HOURS_SHARE if plan_ot[i] else 0.0)
	return minf(equiv, 3.0)

func availability(machine: Dictionary) -> float:
	return shift_equiv(machine) / 3.0

# Staff of one machine: one crew per shift (the owner covers the first shift of his own machine);
# overtime hours cost 1.5x, so a shift with overtime costs 1 + 0.5 x 1.5 = 1.75 crews.
func machine_wages(machine: Dictionary) -> float:
	var wages := 0.0
	for shift in range(1, int(machine["shifts"]) + 1):
		if shift == 1 and machine.get("patron", false):
			continue
		wages += Data.wage_for(machine["kind"]) * int(machine["personnel"]) * (1.0 + (Data.OT_HOURS_SHARE * Data.OT_WAGE_MULT if plan_ot[shift - 1] else 0.0))
		wages += staff_cost_per_head() * int(machine["personnel"])
	return wages

# Condition: 40-100, loses 10 points a year. Missing steps (10 points each) cost capacity, energy, maintenance and scrap.
func condition_steps_of(machine: Dictionary) -> float:
	return Data.condition_steps(float(machine.get("condition", 100.0)))

func machine_energy(machine: Dictionary) -> float:
	var rate := float(Data.ENERGY_STEP_RANGE[0]) + (float(Data.ENERGY_STEP_RANGE[1]) - float(Data.ENERGY_STEP_RANGE[0])) * float(machine.get("roll_e", 0.5))
	return float(machine["energy"]) * (1.0 + condition_steps_of(machine) * rate)

# Maintenance is an operating cost: a share of the price paid for every missing 10 points, a little different every month.
func machine_maintenance(machine: Dictionary) -> float:
	var pct := float(Data.MAINT_STEP_PCT[int(machine["level"])])
	return condition_steps_of(machine) * pct * float(machine["price"]) * (0.8 + 0.4 * float(machine.get("roll_m", 0.5)))

func machine_scrap(machine: Dictionary) -> float:
	var rate := float(Data.SCRAP_STEP_RANGE[0]) + (float(Data.SCRAP_STEP_RANGE[1]) - float(Data.SCRAP_STEP_RANGE[0])) * float(machine.get("roll_s", 0.5))
	return float(machine["scrap"]) * (1.0 + condition_steps_of(machine) * rate)

# Value-weighted condition of the delivered park (100 when empty).
func average_condition() -> float:
	var weight := 0.0
	var total := 0.0
	for machine in delivered():
		var w := float(machine["list_price"])
		weight += w
		total += w * float(machine.get("condition", 100.0))
	return total / weight if weight > 0.0 else 100.0

func machine_running_cost(machine: Dictionary) -> float:
	return (machine_energy(machine) * shift_equiv(machine) + machine_maintenance(machine)) + machine_wages(machine)

func staff_cost_per_head() -> float:
	return float(Data.STAFF_POLICIES[staff_policy]["cost"])

func set_staff_policy(index: int) -> String:
	if phase != "offers":
		return "Personel politikası ay başında (rapordan önce) değişir."
	staff_policy = clampi(index, 0, Data.STAFF_POLICIES.size() - 1)
	return ""

# People on the payroll for the current plan.
func staff_count() -> int:
	var count := 0
	for machine in delivered():
		for shift in range(1, int(machine["shifts"]) + 1):
			if shift == 1 and machine.get("patron", false):
				continue
			count += int(machine["personnel"])
	return count

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
	if on and plan_shifts >= 3:
		return "Üç vardiyada mesai olmaz."
	var machine := patron_machine()
	if on and not machine.is_empty():
		var reason := patron_block_reason(machine["uid"], true)
		if reason != "":
			return reason
	plan_ot[0] = on
	patron_overtime = on and not machine.is_empty()
	return ""

# Factory shift plan: `shifts` crews run every machine, `overtime[i]` adds 4 hours to shift i+1
# (never with three shifts) and `patron` lets the owner run the first shift of one single-operator machine.
func set_plan(shifts: int, overtime: Array, patron: bool) -> String:
	if phase != "offers":
		return "Vardiya ve mesai ay başında (rapordan önce) ayarlanır."
	shifts = clampi(shifts, 1, 3)
	var ot := [false, false, false]
	for i in shifts:
		ot[i] = bool(overtime[i]) and shifts < 3
	if patron:
		var machine := patron_machine()
		if machine.is_empty():
			for candidate in delivered():
				if int(candidate["personnel"]) == 1 and patron_block_reason(candidate["uid"], ot[0]) == "":
					machine = candidate
					break
		if not machine.is_empty():
			var reason := patron_block_reason(machine["uid"], ot[0])
			if reason != "":
				return reason
			for other in machines:
				other["patron"] = false
			machine["patron"] = true
	else:
		for other in machines:
			other["patron"] = false
	plan_patron = patron
	plan_shifts = shifts
	plan_ot = ot
	patron_overtime = ot[0] and not patron_machine().is_empty()
	for machine in machines:
		machine["shifts"] = shifts
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
	if not plan_patron or not patron_machine().is_empty():
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
	if by_dept.has("Bakım"):
		by_dept["Bakım"] = float(by_dept["Bakım"]) * (1.0 + (100.0 - average_condition()) / 100.0)
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
	var raw_physical := (1.0 - float(fr["A"])) * (1.0 - float(fr["P"])) * (1.0 - float(fr["Q"]))
	# the realisation floor holds for the whole product, so the physical part alone cannot sink below it either
	var physical := maxf(REALIZATION_FLOOR, raw_physical)
	var non := 1.0 - float(fr["N"])
	var total := maxf(REALIZATION_FLOOR, physical * non)
	var non_eff := minf(1.0, total / physical)
	var spread := pow(physical / maxf(raw_physical, 0.0001), 1.0 / 3.0)
	return {"phys": physical, "non": non_eff, "a": minf(1.0, (1.0 - float(fr["A"])) * spread), "p": minf(1.0, (1.0 - float(fr["P"])) * spread), "q": minf(1.0, (1.0 - float(fr["Q"])) * spread)}

func machine_steps(machine: Dictionary, mults: Dictionary) -> Dictionary:
	var theoretical := float(machine["nameplate"])
	var after_shift := theoretical * availability(machine)
	var after_perf := after_shift * float(machine["perf"])
	var after_scrap := after_perf * (1.0 - machine_scrap(machine))
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

# Months until machines that can do the whole job are delivered (0 = all there, -1 = a needed machine is missing).
func transit_wait(offer: Dictionary) -> int:
	var wait := 0
	for req in offer["reqs"]:
		var best := -1
		for machine in machines:
			if machine["kind"] == req["kind"] and int(machine["level"]) >= int(req["level"]):
				var w := maxi(0, int(machine["arrive"]) - month)
				best = w if best < 0 else mini(best, w)
		if best < 0:
			return -1
		wait = maxi(wait, best)
	return wait

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

func machine_area_used() -> float:
	var used := 0.0
	for machine in machines:
		used += float(machine["area"])
	return used

func machine_area_limit() -> float:
	return float(factory()["m2"]) * Data.MACHINE_AREA_SHARE if factory_id != "" else 0.0

func equipment_owned(id: String) -> int:
	var count := int(equip.get(id, 0))
	if package_bought:
		count += int(package_info()["items"].get(id, 0))
	return count

func machines_owned(kind: String, level: int) -> int:
	var count := 0
	for machine in machines:
		if machine["kind"] == kind and int(machine["level"]) == level:
			count += 1
	return count

# Machines the current jobs will actually load this month (FIFO on a copy); after the report, the real use.
func busy_machines() -> Dictionary:
	var busy := {}
	if phase == "report" and not report.is_empty():
		for machine in delivered():
			busy[machine["uid"]] = float(machine.get("used_last", 0.0)) > 0.0
		return busy
	if not package_bought:
		return busy
	var mults := problem_mults(loss_fractions())
	var cap_left := {}
	for machine in delivered():
		cap_left[machine["uid"]] = machine_output(machine, mults)
		busy[machine["uid"]] = false
	var copy: Array = jobs.duplicate(true)
	var before := cap_left.duplicate()
	_allocate(copy, cap_left, month, false)
	for uid in cap_left:
		busy[uid] = float(cap_left[uid]) < float(before[uid]) - 0.0001
	return busy

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
	return float(SHELL_MONEY_BANDS[int(current["max_tier"])][1]) * float(current["factor"])

# Cash needed on acceptance: the material order of a cash-on-order supplier, net of the advance.
func first_payment(offer: Dictionary) -> float:
	if not auto_order:
		return 0.0
	var supplier := Data.supplier_by_id(default_supplier)
	if int(supplier["terms"]) > 0:
		return 0.0
	return maxf(0.0, float(offer["material"]) * float(supplier["price"]) - advance_of(offer))

func advance_of(offer: Dictionary) -> float:
	return snappedf(float(offer["revenue"]) * Data.ADVANCE_RATE, 0.001)

func material_quote(job_or_offer: Dictionary, supplier_id: String) -> Dictionary:
	var supplier := Data.supplier_by_id(supplier_id)
	var amount := snappedf(float(job_or_offer["material"]) * float(supplier["price"]), 0.001)
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
	var rent := snappedf(float(target["rent"]) * Data.rent_scale * float(period["factor"]), 0.001)
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
	var guarantee: float = float(SHELL_MONEY_BANDS[int(size_scale["max_tier"])][1]) * float(size_scale["factor"])
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
	notice = "%s kiralandı. Önce gerekli ekipmanı al, sonra tezgah ve iş." % factory()["name"]
	return ""

func leave_block_reason() -> String:
	if factory_id == "":
		return "Kiralık yer yok."
	if not loan.is_empty():
		return "İpotekli kredi kapanmadan sözleşme bırakılamaz."
	return ""

# Leaving drops every running job exactly like abandoning it: penalty, advance refund, and material already
# ordered still has to be paid.
func leave_job_costs() -> Dictionary:
	var penalty := 0.0
	var refund := 0.0
	var orders := 0.0
	for job in jobs:
		penalty += abandon_penalty(job)
		refund += float(job["advance"])
		var order: Dictionary = job.get("order", {})
		if not order.is_empty() and not bool(order.get("paid", false)):
			orders += float(order["amount"])
	return {"jobs": jobs.size(), "penalty": penalty, "refund": refund, "orders": orders, "total": penalty + refund + orders}

func leave_fee() -> float:
	return base_rent() * Data.EXIT_FEE_RENTS

# FRZ-003 v2 direction (IDEA-015): early exit costs two rents; remaining rent debt is 0.
func leave_factory() -> String:
	var reason := leave_block_reason()
	if reason != "":
		return reason
	var jobs_cost := leave_job_costs()
	cash -= leave_fee() + float(jobs_cost["total"])
	for job in jobs:
		_score_event(0.0)
	history.append("Ay %d: %s bırakıldı (çıkış bedeli %.0f; %d iş bırakıldı: ceza %.0f, peşinat iadesi %.0f, iptal edilemeyen hammadde %.0f)." % [month, factory()["name"], leave_fee(), jobs_cost["jobs"], jobs_cost["penalty"], jobs_cost["refund"], jobs_cost["orders"]])
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
	history.append("Ay %d: gerekli ekipman seti alındı (%.0f)." % [month, info["price"]])
	notice = "Gerekli ekipman tamam; kapasite kullanılabilir."
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
	if machine_area_used() + float(listing["area"]) > machine_area_limit():
		return "Makine alanı sınırı (%%%d)" % int(Data.MACHINE_AREA_SHARE * 100.0)
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
	machine["shifts"] = plan_shifts
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
	return fit_block_reason(id)

# Whether the offer suits the plant (equipment, machines, cash), whatever the phase of the month.
func fit_block_reason(id: int) -> String:
	var offer := offer_by_id(id)
	if offer.is_empty():
		return "İlan bulunamadı."
	if not package_bought:
		return "Gerekli ekipman eksik"
	var missing: Array = []
	for req in offer["reqs"]:
		if not owns(req):
			missing.append("%s %s" % [Data.LEVELS[int(req["level"])], req["kind"]])
	if not missing.is_empty():
		return "Makine yok: " + ", ".join(missing)
	if first_payment(offer) > cash:
		return "Yetersiz nakit"
	return ""

# Legacy path (quote_mode off): take the listed reference price with the default advance.
func accept_offer(id: int) -> String:
	var reason := accept_block_reason(id)
	if reason != "":
		return reason
	var offer := offer_by_id(id)
	_create_job(offer, float(offer["revenue"]), Data.ADVANCE_RATE, int(offer["months"]))
	return ""

func _create_job(offer: Dictionary, price: float, advance_rate: float, due_months: int) -> Dictionary:
	var advance := snappedf(price * advance_rate, 0.001)
	cash += advance
	var job: Dictionary = offer.duplicate(true)
	job["revenue"] = price
	job["months"] = due_months
	job["elapsed"] = 0
	job["accepted_month"] = month
	job["start_month"] = month + int(offer["start_delay"])
	job["due_month"] = month + due_months - 1
	job["produced"] = 0.0
	job["yield"] = 1.0
	job["advance"] = advance
	job["order"] = {}
	var scrap_draw := RandomNumberGenerator.new()
	scrap_draw.seed = 31 * int(offer["id"]) + 7 * month + 3
	var draws: Array = []
	for req in job["reqs"]:
		draws.append(scrap_draw.randf())
	job["scrap_draws"] = draws
	jobs.append(job)
	offers.erase(offer)
	history.append("Ay %d: iş kabul edildi: %s (fiyat %.0f, peşinat %.0f)." % [month, job["title"], price, advance])
	notice = "%s kabul edildi; %.0f peşinat kasaya girdi." % [job["title"], advance]
	if auto_order:
		var result := order_material(job["id"], default_supplier)
		if result != "":
			notice += " Hammadde otomatik sipariş edilemedi: " + result
	return job

# ---------------------------------------------------------------- quotes (IDEA-017)

# Monthly energy and consumables of one machine of this kind/level on the current shift plan.
# The machine that would do a job needing this kind/level: the lowest sufficient level owned (in transit
# included), else a new one of exactly the needed level. A higher level can do lower-level work, but its
# energy, staffing and write-off are the higher machine's.
func serving_basis(kind: String, level: int) -> Dictionary:
	var best: Dictionary = {}
	for machine in machines:
		if machine["kind"] == kind and int(machine["level"]) >= level:
			if best.is_empty() or int(machine["level"]) < int(best["level"]):
				best = machine
	var equiv := 0.0
	for i in clampi(plan_shifts, 1, 3):
		equiv += 1.0 + (Data.OT_HOURS_SHARE if plan_ot[i] else 0.0)
	equiv = minf(equiv, 3.0)
	if not best.is_empty():
		return {"level": int(best["level"]), "owned": true, "energy": machine_energy(best) * equiv + machine_maintenance(best),
			"price": float(best["price"]), "personnel": int(best["personnel"])}
	var typical := Data.typical_machine_month(kind, level)
	var list: float = Data.list_price(kind, level)
	return {"level": level, "owned": false, "energy": (float(typical["energy"]) - 0.0) * equiv / maxf(1.0, equiv),
		"price": list, "personnel": Data.personnel_for(kind, level)}

# Straight-line write-off per month of everything delivered (accounting only; the cash left when it was bought).
func monthly_amortization() -> float:
	var total := 0.0
	for machine in delivered():
		total += float(machine["price"]) / float(Data.AMORT_MONTHS)
	return total

# What the player can work out: material at the default supplier plus, per machine kind the job
# needs, a scrap allowance, the plant overhead and the personnel it occupies. `edits[i]` lets the
# player change the assumptions of requirement i (scrap in points, overhead and personnel in percent);
# material is never editable.
func cost_estimate(offer: Dictionary, edits := {}) -> Dictionary:
	var supplier := Data.supplier_by_id(default_supplier)
	var supplier_price := float(supplier["price"])
	var quality := int(supplier["quality"])
	var material := float(offer["material"]) * supplier_price
	# fixed plant costs (rent, building overhead, indirect staff, office, loan) are shared by the machines the
	# plant is sized for (area / a typical 30 m2 work zone), or by the machines owned when there are more of them
	var slots := maxf(float(machines.size()), floorf(float(factory()["m2"]) / 30.0) if factory_id != "" else 1.0)
	var fixed_pool := base_rent() + plant_fixed_cost() + (float(loan["installment"]) if not loan.is_empty() else 0.0)
	var fixed_share := fixed_pool / maxf(1.0, slots)
	var lines: Array = []
	var total := material
	var base_total := material
	for i in offer["reqs"].size():
		var req: Dictionary = offer["reqs"][i]
		var edit: Dictionary = edits.get(i, {})
		var material_part := float(req.get("material_part", 0.0)) * supplier_price
		var months := float(req["count"]) * float(offer["duration"])
		var rate := Data.scrap_rate(req["kind"], int(req["level"]), quality)
		var rate_used := maxf(0.0, rate + float(edit.get("scrap_pt", 0.0)) / 100.0)
		var basis := serving_basis(req["kind"], int(req["level"]))
		var energy_base := months * float(basis["energy"])
		var overhead_base := months * fixed_share + energy_base
		var personnel_base := months * (Data.wage_for(req["kind"]) + staff_cost_per_head()) * float(basis["personnel"])
		var amort_base := months * float(basis["price"]) / float(Data.AMORT_MONTHS)
		var consumables_base := Data.CONSUMABLE_SHARE * (material_part + personnel_base + energy_base)
		var line := {"kind": req["kind"], "level": req["level"], "count": req["count"], "months": months,
			"material_part": material_part, "scrap_rate": rate, "scrap_rate_used": rate_used, "scrap_range": Data.scrap_range(req["kind"], int(req["level"])),
			"scrap": material_part * rate_used, "overhead": overhead_base * (1.0 + float(edit.get("overhead_pct", 0.0)) / 100.0),
			"personnel": personnel_base * (1.0 + float(edit.get("personnel_pct", 0.0)) / 100.0),
			"amortization": amort_base * (1.0 + float(edit.get("amortization_pct", 0.0)) / 100.0),
			"consumables": consumables_base * (1.0 + float(edit.get("consumables_pct", 0.0)) / 100.0),
			"serving_level": basis["level"], "serving_owned": basis["owned"]}
		line["subtotal"] = float(line["scrap"]) + float(line["overhead"]) + float(line["personnel"]) + float(line["amortization"]) + float(line["consumables"])
		total += float(line["subtotal"])
		base_total += material_part * rate + overhead_base + personnel_base + amort_base + consumables_base
		lines.append(line)
	return {"material": material, "lines": lines, "total": total, "base_total": base_total}

# Raw material turned into parts this month (for the consumables share of the production cost).
func material_used_month(job: Dictionary) -> float:
	var order: Dictionary = job.get("order", {})
	var supplier := Data.supplier_by_id(String(order.get("supplier", default_supplier)))
	var material: float = float(order["amount"]) if order.has("amount") else float(job["material"]) * float(supplier["price"])
	var weight_sum := 0.0
	for req in job["reqs"]:
		weight_sum += float(req.get("material_part", 0.0))
	var used := 0.0
	for req in job["reqs"]:
		var share := float(req.get("material_part", 0.0)) / maxf(0.001, weight_sum)
		used += material * share * float(req.get("made_month", 0.0)) / maxf(1.0, float(req["workload"]))
	return used

# Material scrapped this month: the drawn rate of each requirement, on the material of the parts
# that were actually made (flash and chips are already inside the raw-material price).
func scrap_cost_month(job: Dictionary) -> float:
	var order: Dictionary = job.get("order", {})
	var supplier := Data.supplier_by_id(String(order.get("supplier", default_supplier)))
	var quality := int(supplier["quality"])
	var material: float = float(order["amount"]) if order.has("amount") else float(job["material"]) * float(supplier["price"])
	var weight_sum := 0.0
	for req in job["reqs"]:
		weight_sum += float(req.get("material_part", 0.0))
	var cost := 0.0
	var draws: Array = job.get("scrap_draws", [])
	for i in job["reqs"].size():
		var req: Dictionary = job["reqs"][i]
		var share := float(req.get("material_part", 0.0)) / maxf(0.001, weight_sum)
		var drawn: float = Data.scrap_at(req["kind"], int(req["level"]), Data.scrap_position(float(draws[i]), quality)) if i < draws.size() else Data.scrap_rate(req["kind"], int(req["level"]), quality)
		cost += material * share * drawn * float(req.get("made_month", 0.0)) / maxf(1.0, float(req["workload"]))
	return cost

# The customer's own cost belief (from the reference price and the job's complexity margin).
func customer_cost(offer: Dictionary) -> float:
	return float(offer["cost_ref"])

# Highest price the customer accepts: cost x (1 + margin) where the margin runs from
# (mid - 20 points) for a relaxed customer to (mid + 25 points) for an urgent one, then lowered
# by a weak delivery score, a bigger advance and a later delivery.
func customer_limit(offer: Dictionary, advance_pct: int, months_offered: int) -> float:
	var mid := float(offer["mid"])
	var margin := lerpf(maxf(0.05, mid - 0.20), mid + 0.25, (float(offer["urgency"]) - 1.0) / 9.0)
	var limit := customer_cost(offer) * (1.0 + margin)
	limit *= 0.90 + 0.15 * delivery_score
	limit *= 1.0 - 0.002 * float(advance_pct - 30)
	var wanted: int = int(offer["months"])
	if months_offered > wanted:
		limit *= 1.0 - 0.07 * float(months_offered - wanted)
	else:
		limit *= 1.0 + 0.04 * float(wanted - months_offered)
	return limit

func quote_block_reason(offer_id: int, price: float) -> String:
	if phase != "offers":
		return "Teklif ay başında (rapordan önce) verilir."
	var reason := accept_block_reason(offer_id)
	if reason != "":
		return reason
	if price <= 0.0:
		return "Fiyat girin."
	return ""

func _mail(offer: Dictionary, status: String, lines: Array, extra := {}) -> Dictionary:
	var mail := {"id": next_mail, "month": month, "offer_id": offer["id"], "title": offer["title"], "customer": offer["customer"],
		"status": status, "lines": lines, "offer": offer.duplicate(true)}
	mail.merge(extra)
	next_mail += 1
	mails.push_front(mail)
	while mails.size() > 12:
		mails.pop_back()
	return mail

# One quote per offer. Accepted, countered (yes/no) or rejected with an explanatory note.
func submit_quote(offer_id: int, price: float, advance_pct: int, months_offered: int) -> Dictionary:
	var reason := quote_block_reason(offer_id, price)
	if reason != "":
		return {"ok": false, "reason": reason}
	var offer := offer_by_id(offer_id)
	var limit := customer_limit(offer, advance_pct, months_offered)
	var wanted: int = int(offer["months"])
	var contact: String = Data.CONTACTS[int(offer["id"]) % Data.CONTACTS.size()]
	if price <= limit:
		if months_offered > wanted and int(offer["urgency"]) >= 8:
			var mail := _mail(offer, "counter", ["Teşekkürler, fiyatınız uygun. Ancak %d ayda teslim istiyoruz; bu süreyi kabul ederseniz anlaşalım." % wanted],
				{"price": price, "advance_pct": advance_pct, "months": wanted, "kind": "time"})
			offers.erase(offer)
			return {"ok": true, "status": "counter", "mail": mail}
		var job := _create_job(offer, price, float(advance_pct) / 100.0, months_offered)
		var accepted := _mail(offer, "accepted", ["Teklifiniz için teşekkürler, %s fiyatla %d ayda teslim şartıyla anlaştık." % [Data.usd(price), months_offered]])
		return {"ok": true, "status": "accepted", "mail": accepted, "job": job}
	if price <= limit * (1.0 + COUNTER_BAND):
		var counter_price := snappedf(limit * rng.randf_range(0.96, 1.0), 0.001)
		var mail := _mail(offer, "counter", ["Teklifiniz için teşekkürler. Fiyatı %s'ye çekebilir misiniz?" % Data.usd(counter_price)],
			{"price": counter_price, "advance_pct": advance_pct, "months": months_offered, "kind": "price"})
		offers.erase(offer)
		return {"ok": true, "status": "counter", "mail": mail}
	var note := "Teklifiniz hedef fiyatımızın üstünde olduğu için bu işte çalışamayacağız.\nNot: firmanın belirlediği tahmini maliyet %s ve işin aciliyet durumu %d/10.\n(%s bu hafta %s.)" % [
		Data.usd(customer_cost(offer)), int(offer["urgency"]), contact, "yeniden arayacak" if int(offer["urgency"]) >= 7 else "aramadı"]
	var rejected := _mail(offer, "rejected", note.split("\n"))
	offers.erase(offer)
	return {"ok": true, "status": "rejected", "mail": rejected}

func mail_by_id(id: int) -> Dictionary:
	for mail in mails:
		if mail["id"] == id:
			return mail
	return {}

func answer_counter(mail_id: int, yes: bool) -> String:
	var mail := mail_by_id(mail_id)
	if mail.is_empty() or mail["status"] != "counter":
		return "Bu teklif artık yanıt beklemiyor."
	if phase != "offers":
		return "Yanıt ay başında verilir."
	if not yes:
		mail["status"] = "declined"
		mail["lines"].append("Yanıtınız: hayır. Anlaşma olmadı.")
		return ""
	var offer: Dictionary = mail["offer"]
	var probe := offer.duplicate(true)
	probe["id"] = offer["id"]
	if not package_bought:
		return "Gerekli ekipman eksik"
	for req in offer["reqs"]:
		if not owns(req):
			return "Makine yok"
	offers.append(offer)
	_create_job(offer, float(mail["price"]), float(mail["advance_pct"]) / 100.0, int(mail["months"]))
	mail["status"] = "accepted"
	mail["lines"].append("Yanıtınız: evet. %s ve %d ay ile anlaştık." % [Data.usd(float(mail["price"])), mail["months"]])
	return ""

func _expire_mails() -> void:
	for mail in mails:
		if mail["status"] == "counter":
			mail["status"] = "expired"
			mail["lines"].append("Yanıt verilmediği için firma başka tedarikçiye yöneldi.")

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
	return snappedf(float(job["revenue"]) * Data.ABANDON_PENALTY, 0.001)

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
	return snappedf(float(machine["reference"]) * Data.SALE_RATE, 0.001)

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
					req["made_month"] = float(req.get("made_month", 0.0)) + got

# Why an accepted job is not being produced (empty when it is, or will be, loaded this month).
func job_wait_reason(job: Dictionary) -> String:
	var order: Dictionary = job.get("order", {})
	if order.is_empty():
		return "Hammadde siparişi verilmedi"
	if int(order["arrive_month"]) > month:
		return "Hammadde Ay %d'de gelir" % int(order["arrive_month"])
	if int(job["start_month"]) > month:
		return "Müşteri hazırlığı sürüyor; üretim Ay %d'de başlar" % int(job["start_month"])
	var missing: Array = []
	for req in job["reqs"]:
		if float(req["remaining"]) > 0.5 and _eligible(req["kind"], int(req["level"]), month).is_empty():
			missing.append("%s %s" % [Data.LEVELS[int(req["level"])], req["kind"]])
	if not missing.is_empty():
		return "Teslim alınmış tezgah yok: " + ", ".join(missing)
	if not package_bought:
		return "Gerekli ekipman eksik"
	if phase == "report" and not report.is_empty():
		var made := 0.0
		for req in job["reqs"]:
			made += float(req.get("made_month", 0.0))
		if made <= 0.0001 and not job_done(job):
			return "Bu ayın kapasitesi önceki işlere gitti (FIFO sırası)"
	return ""

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
	for job in jobs:
		for req in job["reqs"]:
			req["made_month"] = 0.0
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
	var running := running_cost_actual()
	cash -= running
	lines.append("Personel, enerji (yalnızca çalışan tezgahlar), bina işletme, dolaylı ve ofis kadrosu: %s" % Data.usd(running))
	var material_used := 0.0
	for job in jobs:
		material_used += material_used_month(job)
	var consumables := Data.CONSUMABLE_SHARE * (running + material_used)
	cash -= consumables
	lines.append("Sarf malzeme (üretim maliyetinin %%%.1f'i): %s" % [Data.CONSUMABLE_SHARE * 100.0, Data.usd(consumables)])
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
		var scrap_cost := scrap_cost_month(job)
		if scrap_cost > 0.0:
			cash -= scrap_cost
			lines.append("Hurda gideri: %s (%s)" % [Data.usd(scrap_cost), job["title"]])
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
		_age_machine(machine)
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
	_expire_mails()
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
		if rng.randf() < PERSON_SHARE and rng.randf() < MAX_PREVENTION * skills[HR_SKILL] / 100.0 + float(Data.STAFF_POLICIES[staff_policy]["bonus"]):
			prevented_this_month += 1
			prevented_total += 1
			continue
		var department: String = SKILLS[rng.randi_range(0, SKILLS.size() - 1)]
		if age_maintenance and department == "Bakım":
			var accept_chance := clampf(0.4 + (100.0 - average_condition()) / 100.0, 0.4, 1.0)
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
		var band: Array = SHELL_MONEY_BANDS[tier]
		var hour_band: Array = HOUR_BANDS[tier]
		problems["k%d" % next_id] = {
			"department": department, "tier": tier, "loss": loss, "base_loss": loss, "active": true, "attempted": 0,
			"scale_tier": int(current["max_tier"]), "factor": float(current["factor"]),
			"actual_money": snappedf(rng.randf_range(band[0], band[1]) * current["factor"], 0.01),
			"actual_hours": rng.randi_range(hour_band[0], hour_band[1]),
			"total_loss": 0.0, "ever_seen": false, "solved_month": 0, "born": month
		}
		next_id += 1

# ---------------------------------------------------------------- mortgage loan

# One month older: condition falls 10 points a year (floor 40); capacity, value and the monthly random rolls follow.
func _age_machine(machine: Dictionary) -> void:
	var condition := maxf(Data.CONDITION_MIN, float(machine.get("condition", 100.0)) - Data.AGING_PER_MONTH)
	machine["condition"] = condition
	machine["age"] = int(roundf(Data.condition_steps(condition)))
	machine["nameplate"] = float(machine["base_nameplate"]) * (1.0 - Data.CAPACITY_STEP_LOSS * Data.condition_steps(condition))
	machine["reference"] = snappedf(float(machine["list_price"]) * Data.condition_price_factor(condition), 0.001)
	machine["roll_e"] = rng.randf()
	machine["roll_m"] = rng.randf()
	machine["roll_s"] = rng.randf()

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
