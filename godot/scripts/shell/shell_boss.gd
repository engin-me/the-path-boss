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
var month_counts := {}   # uid -> [good, scrapped] pieces made since the month began (floor view counters)
var quote_progress := true   # payment form of the quote being built: monthly progress payments (true) or one payment at delivery
var plan_contract := 0   # 0 = permanent crews on the extra shifts, else fixed-term months (3/6/9)
var plan_contract_end := 0   # first month without the fixed-term crews
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
	data["plan_contract"] = plan_contract
	data["plan_contract_end"] = plan_contract_end
	data["plan_ot"] = plan_ot.duplicate()
	data["plan_patron"] = plan_patron
	data["staff_policy"] = staff_policy
	data["benefits"] = benefits.duplicate()
	data["benefits_next"] = benefits_next.duplicate()
	data["moving_until"] = moving_until
	data["day"] = day
	data["days_run"] = days_run
	data["month_events"] = month_events.duplicate()
	data["month_material_used"] = month_material_used
	data["month_revenue"] = month_revenue
	data["month_late"] = month_late
	data["lifetime_revenue"] = lifetime_revenue
	data["cash_history"] = cash_history.duplicate()
	data["jobs_done"] = jobs_done
	data["committed_history"] = committed_history.duplicate()
	data["free_history"] = free_history.duplicate()
	data["invest_history"] = invest_history.duplicate()
	data["debt_history"] = debt_history.duplicate()
	data["oee_history"] = oee_history.duplicate(true)
	data["event_log"] = event_log.duplicate(true)
	data["revenue_history"] = revenue_history.duplicate()
	data["quotes_sent"] = quotes_sent
	data["quotes_won"] = quotes_won
	data["month_running"] = month_running
	data["rent_markup"] = rent_markup
	data["renewal_term"] = renewal_term
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
	for mail in mails:
		mail.erase("ready_ms")   # a saved mail has long arrived; the clock of a new session starts at zero
	machines.assign(copy["machines"])
	for machine in machines:
		if not machine.has("slot"):
			machine["slot"] = free_slot()
	layout = copy.get("layout", {})
	plan_shifts = int(copy.get("plan_shifts", 1))
	plan_contract = int(copy.get("plan_contract", 0))
	plan_contract_end = int(copy.get("plan_contract_end", 0))
	plan_ot = copy.get("plan_ot", [false, false, false]).duplicate()
	plan_patron = bool(copy.get("plan_patron", true))
	staff_policy = clampi(int(copy.get("staff_policy", 1)), 0, Data.STAFF_POLICIES.size() - 1)
	benefits = copy.get("benefits", Data.default_benefits()).duplicate()
	benefits_next = copy.get("benefits_next", benefits).duplicate()
	moving_until = int(copy.get("moving_until", 0))
	day = int(copy.get("day", 1))
	days_run = int(copy.get("days_run", 0))
	month_events = copy.get("month_events", []).duplicate()
	month_material_used = float(copy.get("month_material_used", 0.0))
	month_revenue = float(copy.get("month_revenue", 0.0))
	month_late = int(copy.get("month_late", 0))
	lifetime_revenue = float(copy.get("lifetime_revenue", 0.0))
	cash_history = copy.get("cash_history", []).duplicate()
	jobs_done = int(copy.get("jobs_done", 0))
	committed_history = copy.get("committed_history", []).duplicate()
	free_history = copy.get("free_history", []).duplicate()
	invest_history = copy.get("invest_history", []).duplicate()
	debt_history = copy.get("debt_history", []).duplicate()
	oee_history = copy.get("oee_history", []).duplicate(true)
	event_log = copy.get("event_log", []).duplicate(true)
	revenue_history = copy.get("revenue_history", []).duplicate()
	quotes_sent = int(copy.get("quotes_sent", 0))
	quotes_won = int(copy.get("quotes_won", 0))
	month_running = float(copy.get("month_running", 0.0))
	if days_run > 0 and not copy.has("month_running") and factory_id != "":
		month_running = running_cost() * float(days_run) / float(Data.MONTH_DAYS)   # save from before the daily accrual: estimate the days already played
	rent_markup = float(copy.get("rent_markup", 0.0))
	renewal_term = int(copy.get("renewal_term", 0))
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

# What the cash on the table is not really yours for: advances held for unfinished jobs, material still to be paid,
# and the month's running costs. `free` is the cash left after the known obligations.
func commitments(with_first := true) -> Dictionary:
	var advances := 0.0
	var material := 0.0
	for job in jobs:
		advances += float(job["advance"])
		var order: Dictionary = job.get("order", {})
		if order.is_empty():
			if not bool(job.get("fason", false)):
				material += float(job["material"]) * float(Data.supplier_by_id(default_supplier)["price"])
		elif not bool(order["paid"]):
			material += float(order["amount"])
	var expense := ordinary_expense()
	var first := {}
	if with_first and not jobs.is_empty():
		var finish := projection_days()
		var best_m := 0
		var best_d := 0
		for id in finish:
			var when: Array = finish[id]
			if best_m == 0 or int(when[0]) < best_m or (int(when[0]) == best_m and int(when[1]) < best_d):
				best_m = int(when[0])
				best_d = int(when[1])
		if best_m > 0:
			first = {"month": best_m, "day": best_d}
	return {"cash": cash, "advances": advances, "material": material, "expense": expense, "free": cash - material - expense, "first": first}

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
	return rent_for_term(term)

# Monthly rent for a contract length at today's market (renewal rises included).
func rent_for_term(months: int) -> float:
	return snappedf(float(factory()["rent"]) * Data.rent_scale * float(Data.term_by_months(months)["factor"]) * (1.0 + rent_markup), 0.001)

# ---------------------------------------------------------------- contract end

var rent_markup := 0.0   # market rises accumulated by renewals nobody answered
var renewal_term := 0    # the length the player chose for the next period (0 = not decided)

# What the rent becomes when the player does not answer the landlord.
func rent_if_unanswered() -> float:
	return snappedf(float(factory()["rent"]) * Data.rent_scale * float(Data.term_by_months(term)["factor"]) * (1.0 + rent_markup + Data.RENEWAL_MARKUP), 0.001)

func in_notice_window() -> bool:
	return factory_id != "" and months_left <= Data.NOTICE_MONTHS

func set_renewal(months: int) -> String:
	if not in_notice_window():
		return "Yenileme, sözleşme bitmeden %d ay önce yapılır." % Data.NOTICE_MONTHS
	if Data.term_by_months(months).is_empty():
		return "Bilinmeyen süre."
	renewal_term = months
	notice = "Sözleşme %d ay yenilenecek (aylık %.0f)." % [months, rent_for_term(months)]
	return ""

# Called when the last month of the contract is over: a chosen renewal keeps the rent, silence means market rent.
func _contract_end() -> String:
	if renewal_term > 0:
		term = renewal_term
		months_left = term
		var line := "Sözleşme %d ay için yenilendi (aylık %.0f)." % [term, base_rent()]
		renewal_term = 0
		return line
	rent_markup += Data.RENEWAL_MARKUP
	months_left = term
	return "Karar vermediğiniz için sözleşme piyasa kirasıyla (+%%%d) %d ay yenilendi; aylık %.0f." % [int(Data.RENEWAL_MARKUP * 100.0), term, base_rent()]

func _notice_mail() -> void:
	post_mail("Sözleşmeniz bitiyor", [
		"Kira sözleşmeniz %d ay sonra sona eriyor." % months_left,
		"Yenilemek için Ofis → Fabrika → Sözleşme bölümünden süre seçin; karar vermezseniz sözleşme piyasa kirasıyla (+%%%d) aynı süre için yenilenir." % int(Data.RENEWAL_MARKUP * 100.0),
		"Son ayda çıkış ya da taşınma için çıkış bedeli alınmaz."], "Mal sahibi")

func running_cost() -> float:
	var cost := plant_fixed_cost()
	for machine in delivered():
		cost += machine_running_cost(machine)
	return cost + moving_wages()

# Crews of machines that are being moved stay on the payroll.
func moving_wages() -> float:
	var wages := 0.0
	for machine in machines:
		if bool(machine.get("moving", false)) and int(machine["arrive"]) > month:
			wages += machine_wages(machine)
	return wages

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
		cost += ((machine_energy(machine) * shift_equiv(machine) + machine_maintenance(machine)) * worked + machine_wages(machine) * (Data.IDLE_WAGE_FLOOR + (1.0 - Data.IDLE_WAGE_FLOOR) * worked)) * service_fraction(machine)
	return cost + moving_wages()

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

# Productive shift-equivalents: later shifts and overtime run at the machine level's shift efficiency (IDEA-022).
func shift_yield(machine: Dictionary) -> float:
	var level := int(machine.get("level", 1))
	var total := 0.0
	for i in clampi(int(machine["shifts"]), 1, 3):
		total += Data.shift_efficiency(level, i + 1)
		if plan_ot[i]:
			total += Data.OT_HOURS_SHARE * Data.shift_efficiency(level, 3)
	return minf(total, 3.0)

func availability(machine: Dictionary) -> float:
	return shift_yield(machine) / 3.0

func _crew_wage_mult(shift: int) -> float:
	return 1.0 + (Data.contract_premium(plan_contract) if shift >= 2 and plan_contract > 0 else 0.0)

# Severance if the plan drops from the current number of shifts to `new_shifts` (permanent crews 2 months of wages,
# fixed-term crews less). Expiry of a fixed-term contract costs nothing.
func severance_for(new_shifts: int) -> float:
	var total := 0.0
	for machine in delivered():
		for shift in range(maxi(2, new_shifts + 1), int(machine["shifts"]) + 1):
			var cut := Data.contract_severance_cut(plan_contract) if plan_contract > 0 else 0.0
			total += Data.wage_for(machine["kind"]) * _crew_wage_mult(shift) * int(machine["personnel"]) * Data.SEVERANCE_MONTHS * (1.0 - cut)
	return total

# Month start: fixed-term crews whose contract ended leave; those shifts close without severance.
func _contract_expiry() -> void:
	if plan_contract <= 0 or month < plan_contract_end:
		return
	if plan_shifts > 1:
		_find("Ay %d: %d aylık sözleşmeli ekip ayrıldı; ikinci/üçüncü vardiya kapandı (tazminat yok)." % [month, plan_contract])
		log_event("Personel", "Sözleşmeli ekip sözleşmesi bitti; vardiya sayısı 1'e indi.")
		last_lines.append("Sözleşmeli ekip ayrıldı: vardiyalar kapandı.")
		plan_shifts = 1
		for i in range(1, 3):
			plan_ot[i] = false
		for machine in machines:
			machine["shifts"] = 1
	plan_contract = 0
	plan_contract_end = 0

# Short month-start brief on the shift plan (shown once per month by the shell).
func plan_brief() -> Array:
	var lines := []
	if plan_shifts <= 1 and not plan_ot.has(true):
		return lines
	var wages := 0.0
	for machine in delivered():
		wages += machine_wages(machine)
	lines.append("Açık vardiya: %d%s · aylık personel gideri %s" % [plan_shifts, " (+mesai)" if plan_ot.has(true) else "", Data.usd(wages)])
	if plan_contract > 0 and plan_shifts > 1:
		lines.append("Sözleşmeli ekip %s ayında ayrılır; o gün vardiyalar kapanır, o tezgahlar boşa düşer." % Data.month_label(plan_contract_end).get_slice(" · ", 0))
	elif plan_shifts > 1:
		lines.append("Kadrolu ekip: vardiyayı kapatırsan %s tazminat çıkar." % Data.usd(severance_for(1)))
	return lines

# Staff of one machine: one crew per shift (the owner covers the first shift of his own machine);
# overtime hours cost 1.5x, so a shift with overtime costs 1 + 0.5 x 1.5 = 1.75 crews.
func machine_wages(machine: Dictionary) -> float:
	var wages := 0.0
	for shift in range(1, int(machine["shifts"]) + 1):
		if shift == 1 and machine.get("patron", false):
			continue
		wages += Data.wage_for(machine["kind"]) * _crew_wage_mult(shift) * int(machine["personnel"]) * (1.0 + (Data.OT_HOURS_SHARE * Data.OT_WAGE_MULT if plan_ot[shift - 1] else 0.0))
		wages += staff_cost_per_head() * int(machine["personnel"])
	return wages

# Condition: 40-100, loses 10 points a year. Missing steps (10 points each) cost capacity, energy, maintenance and scrap.
func condition_steps_of(machine: Dictionary) -> float:
	return Data.condition_steps(float(machine.get("condition", 100.0)))

func machine_boost(machine: Dictionary) -> float:
	return float(machine.get("boost", 0)) / 100.0

func machine_energy(machine: Dictionary) -> float:
	var rate := float(Data.ENERGY_STEP_RANGE[0]) + (float(Data.ENERGY_STEP_RANGE[1]) - float(Data.ENERGY_STEP_RANGE[0])) * float(machine.get("roll_e", 0.5))
	return float(machine["energy"]) * (1.0 + condition_steps_of(machine) * rate) * (1.0 + Data.BOOST_ENERGY * machine_boost(machine))

# Maintenance is an operating cost: a share of the price paid for every missing 10 points, a little different every month.
func machine_maintenance(machine: Dictionary) -> float:
	var pct := float(Data.MAINT_STEP_PCT[int(machine["level"])])
	return condition_steps_of(machine) * pct * float(machine["price"]) * (0.8 + 0.4 * float(machine.get("roll_m", 0.5))) * (1.0 + Data.BOOST_MAINT * machine_boost(machine))

func machine_scrap(machine: Dictionary) -> float:
	var rate := float(Data.SCRAP_STEP_RANGE[0]) + (float(Data.SCRAP_STEP_RANGE[1]) - float(Data.SCRAP_STEP_RANGE[0])) * float(machine.get("roll_s", 0.5))
	return float(machine["scrap"]) * (1.0 + condition_steps_of(machine) * rate) * (1.0 + Data.BOOST_SCRAP * machine_boost(machine))

# Speed-up of one machine (0..BOOST_MAX percent): more output, more scrap, maintenance and energy.
func set_boost(uid: int, percent: int) -> void:
	var machine := machine_by_uid(uid)
	if not machine.is_empty():
		machine["boost"] = clampi(percent, 0, Data.BOOST_MAX)

# The same speed-up for every machine of the same kind and level.
func set_boost_group(uid: int, percent: int) -> void:
	var source := machine_by_uid(uid)
	if source.is_empty():
		return
	for machine in machines:
		if machine["kind"] == source["kind"] and int(machine["level"]) == int(source["level"]):
			machine["boost"] = clampi(percent, 0, Data.BOOST_MAX)

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
	return Data.benefit_cost_of(benefits)

func staff_bonus() -> float:
	return Data.benefit_bonus_of(benefits)

# Staff benefits: the levels in force (benefits) and the ones chosen for next month (benefits_next).
var benefits: Array = Data.default_benefits()
var benefits_next: Array = Data.default_benefits()

# Highest level a benefit may be raised to: one above the lowest level of all of them.
func benefit_allowed_max() -> int:
	return mini(3, int(benefits_next.min()) + 1)

func set_benefit(index: int, level: int) -> String:
	if index < 0 or index >= Data.BENEFITS.size() or level < 0 or level > 3:
		return "Geçersiz seçim."
	if bool(Data.BENEFITS[index]["mandatory"]) and level < 1:
		return "%s zorunlu: en az V1." % Data.BENEFITS[index]["name"]
	var current := int(benefits_next[index])
	if level > current and level > benefit_allowed_max():
		return "V%d için önce her yan hak V%d olmalı." % [level, level - 1]
	benefits_next[index] = level
	# lowering one level also pulls higher ones down: nothing may be more than one level above the lowest
	var floor_level := int(benefits_next.min())
	for i in benefits_next.size():
		benefits_next[i] = mini(int(benefits_next[i]), floor_level + 1)
	return ""

func apply_benefit_preset(kind: int) -> void:
	benefits = Data.default_benefits()
	if kind >= 2:
		benefits = [1, 1, 1, 1, 1, 1, 1, 1]
	benefits_next = benefits.duplicate()

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
func set_plan(shifts: int, overtime: Array, patron: bool, contract := -1) -> String:
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
	var severance := severance_for(shifts) if shifts < plan_shifts else 0.0
	if severance > 0.0:
		cash -= severance
		log_event("Personel", "Tazminat ödendi: %s" % Data.usd(severance))
	if shifts > 1 and plan_shifts == 1:
		plan_contract = contract if contract >= 0 and Data.CONTRACTS.has(contract) else 0
		plan_contract_end = month + plan_contract if plan_contract > 0 else 0
	elif shifts <= 1:
		plan_contract = 0
		plan_contract_end = 0
	plan_shifts = shifts
	plan_ot = ot
	patron_overtime = ot[0] and not patron_machine().is_empty()
	for machine in machines:
		machine["shifts"] = shifts
	log_event("Personel", "Vardiya planı: %d vardiya%s%s" % [shifts, ", mesai " + ", ".join(range(1, shifts + 1).filter(func(i): return ot[i - 1]).map(func(i): return "V%d" % i)) if ot.has(true) else "", ", patron operatör" if patron else ""])
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
	var after_perf := after_shift * float(machine["perf"]) * (1.0 + machine_boost(machine))
	var after_scrap := after_perf * (1.0 - machine_scrap(machine))
	var after_phys := after_scrap * float(mults["phys"])
	return {"theoretical": theoretical, "shift": after_shift, "perf": after_perf, "scrap": after_scrap, "phys": after_phys, "net": after_phys * float(mults["non"])}

func machine_output(machine: Dictionary, mults: Dictionary) -> float:
	if not package_bought or int(machine["arrive"]) > month:
		return 0.0
	return float(machine_steps(machine, mults)["net"])

# Net monthly output (current plan, problems included) of every machine that could do this requirement,
# machines still in transit counted as if they stood there.
func requirement_capacity(req: Dictionary) -> float:
	var mults := problem_mults(loss_fractions())
	var total := 0.0
	for machine in machines:
		if machine["kind"] == req["kind"] and int(machine["level"]) >= int(req["level"]):
			total += float(machine_steps(machine, mults)["net"])
	return total

# Capacity and load per tolerance level of one machine kind (net, current plan, transit machines shown apart).
# Load = remaining workload of the accepted jobs spread over the months to their due date. Work fills the machines of its own
# level first; what is left spills up to finer machines. `extra` is a job being quoted (offer) over `extra_months`.
func capacity_chart(kind: String, extra := {}, extra_months := 1) -> Dictionary:
	var mults := problem_mults(loss_fractions())
	var cap := [0.0, 0.0, 0.0]
	var transit := [0.0, 0.0, 0.0]
	for machine in machines:
		if machine["kind"] != kind:
			continue
		var net := float(machine_steps(machine, mults)["net"])
		if int(machine["arrive"]) > month or not package_bought:
			transit[int(machine["level"]) - 1] += net
		else:
			cap[int(machine["level"]) - 1] += net
	var demand := [0.0, 0.0, 0.0]
	for job in jobs:
		# only the months in which production can actually run count: machines, customer preparation and material come first
		var order: Dictionary = job.get("order", {})
		var wait := maxi(maxi(0, int(job["start_month"]) - month), maxi(0, transit_wait(job)))
		if not order.is_empty():
			wait = maxi(wait, int(order["arrive_month"]) - month)
		var months_left := maxi(1, int(job["due_month"]) - month + 1 - wait)
		for req in job["reqs"]:
			if req["kind"] == kind:
				demand[int(req["level"]) - 1] += float(req["remaining"]) / float(months_left)
	var extra_demand := [0.0, 0.0, 0.0]
	if not extra.is_empty():
		var extra_wait := maxi(int(extra.get("start_delay", 0)), maxi(0, transit_wait(extra)))
		if not bool(extra.get("fason", false)):
			extra_wait = maxi(extra_wait, int(material_quote(extra, default_supplier)["lead"]))
		var producing := maxi(1, extra_months - extra_wait)
		for req in extra["reqs"]:
			if req["kind"] == kind:
				extra_demand[int(req["level"]) - 1] += float(req["workload"]) / float(producing)
	var total_cap := [cap[0] + transit[0], cap[1] + transit[1], cap[2] + transit[2]]
	var base := _level_alloc(demand, total_cap)
	var plus := _level_alloc([demand[0] + extra_demand[0], demand[1] + extra_demand[1], demand[2] + extra_demand[2]], total_cap)
	var levels: Array = []
	for i in 3:
		levels.append({"level": i + 1, "tol": Data.tolerance_text(float(Data.PRECISION_MM[i + 1])), "cap": cap[i], "transit": transit[i],
			"load": float(base["used"][i]), "spill": float(base["spill"][i]), "unmet": float(base["unmet"][i]),
			"extra": maxf(0.0, float(plus["used"][i]) - float(base["used"][i])), "extra_unmet": maxf(0.0, float(plus["unmet"][i]) - float(base["unmet"][i]))})
	if not extra.is_empty():
		for lv in levels:
			lv["unmet"] = float(plus["unmet"][int(lv["level"]) - 1])   # with the quoted job: what still has no machine
	return {"kind": kind, "levels": levels}

func _level_alloc(demand: Array, caps: Array) -> Dictionary:
	var left := [float(caps[0]), float(caps[1]), float(caps[2])]
	var used := [0.0, 0.0, 0.0]
	var spill := [0.0, 0.0, 0.0]
	var rest := [0.0, 0.0, 0.0]
	for i in 3:
		var take := minf(float(demand[i]), left[i])
		left[i] -= take
		used[i] += take
		rest[i] = float(demand[i]) - take
	for i in 3:
		for j in range(i + 1, 3):
			var take := minf(rest[i], left[j])
			left[j] -= take
			used[j] += take
			spill[j] += take
			rest[i] -= take
	return {"used": used, "spill": spill, "unmet": rest}

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

func slots_total() -> int:
	return Data.slot_count(factory_id) if factory_id != "" else 0

# Lowest plan slot no machine stands on.
func free_slot() -> int:
	var taken := {}
	for machine in machines:
		if machine.has("slot"):
			taken[int(machine["slot"])] = true
	var slot := 0
	while taken.has(slot):
		slot += 1
	return slot

func machine_area_limit() -> float:
	return float(factory()["m2"]) * Data.MACHINE_AREA_SHARE if factory_id != "" else 0.0

func equipment_owned(id: String) -> int:
	var count := int(equip.get(id, 0))
	if package_bought:
		count += int(package_info()["items"].get(id, 0))
	return count

# Pieces of an equipment type, new and second-hand together.
func equipment_kind_owned(kind: String) -> int:
	var count := 0
	for id in Data.EQUIPMENT:
		if Data.equipment_kind(id) == kind:
			count += equipment_owned(id)
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

# What each delivered machine is expected to produce this month (the same allocation the report will run,
# without recording it): the basis of the live preview while the clock runs.
func month_plan_output() -> Dictionary:
	var out := {}
	if not package_bought or phase != "offers":
		return out
	var mults := problem_mults(loss_fractions())
	var cap_left := {}
	for machine in delivered():
		cap_left[machine["uid"]] = machine_output(machine, mults)
	var copy: Array = jobs.duplicate(true)
	var before := cap_left.duplicate()
	_allocate(copy, cap_left, month, false)
	for uid in cap_left:
		out[uid] = maxf(0.0, float(before[uid]) - float(cap_left[uid]))
	return out

func area_used() -> float:
	return machine_area_used()

# Fix quotes on the shell's money scale (the base class quotes on its own, larger bands, which would
# demand cash far above the real cost).
func quote_for(root: Dictionary) -> Dictionary:
	var factor: float = root["factor"]
	var department: String = root["department"]
	var low_tier: int = root["tier"]
	var high_tier: int = root["tier"]
	if not is_visible(root):
		low_tier = reach(department) + 1
		high_tier = int(root["scale_tier"])
	return {
		"estimate": snappedf(float(SHELL_MONEY_BANDS[low_tier][0]) * factor, 0.01), "actual": root["actual_money"],
		"upper": snappedf(float(SHELL_MONEY_BANDS[high_tier][1]) * factor, 0.01),
		"estimate_hours": _hours(department, HOUR_BANDS[low_tier][0]), "actual_hours": _hours(department, root["actual_hours"]),
		"upper_hours": _hours(department, HOUR_BANDS[high_tier][1])
	}

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
	day = 1
	days_run = 0
	if prepay:
		cash -= float(quote["amount"])
		prepaid_months = int(quote["half"])
	phase = "offers"
	_generate_offers()
	_generate_problems(2)
	_hist("Yönetim", "Ay %d: %s kiralandı (%d ay, kira %.0f)." % [month, factory()["name"], term, base_rent()])
	notice = "%s kiralandı. Önce gerekli ekipmanı al, sonra tezgah ve iş." % factory()["name"]
	return ""

# ---------------------------------------------------------------- moving to another plant (IDEA-020)

var moving_until := 0   # month in which the machines run again after a move (0 = never moved)

func is_moving() -> bool:
	return moving_until > month

# Production stands still for one month at most, however many machines move.
func move_months() -> int:
	return Data.MOVE_MONTHS

# What the equipment set looks like in the new plant: the old set and every extra item are counted one by one,
# the new class needs its list, the deficit is bought now and the surplus stays as extra items.
func move_equipment_plan(new_id: String) -> Dictionary:
	var target := Data.factory_by_id(new_id)
	var plan := {"deficit": {}, "surplus": {}, "cost": 0.0}
	if not package_bought or target.is_empty():
		return plan
	var old_items: Dictionary = package_info()["items"]
	var new_items: Dictionary = Data.package_for(int(target["m2"]))["items"]
	for id in new_items:
		var have := int(old_items.get(id, 0)) + int(equip.get(id, 0))
		var need := int(new_items[id])
		if have >= need:
			if have > need:
				plan["surplus"][id] = have - need
		else:
			plan["deficit"][id] = need - have
			plan["cost"] = float(plan["cost"]) + float(Data.EQUIPMENT[id]["price"]) * float(need - have)
	return plan

func move_cost(new_id: String, sell_uids: Array = []) -> Dictionary:
	var moving_count := machines.size() - sell_uids.size()
	var transport := Data.MOVE_COST_PER_MACHINE * float(maxi(0, moving_count))
	var extra_set := float(move_equipment_plan(new_id)["cost"])
	var sale := 0.0
	for uid in sell_uids:
		var machine := machine_by_uid(int(uid))
		if not machine.is_empty():
			sale += sale_income(machine)
	var exit_fee := leave_fee()
	return {"exit": exit_fee, "transport": transport, "extra_set": extra_set, "sale": sale, "total": exit_fee + transport + extra_set - sale}

# Machines that do not fit the new plant's slots and must be sold first.
func move_excess(new_id: String) -> int:
	return maxi(0, machines.size() - Data.slot_count(new_id))

func move_block_reason(id: String, months: int, prepay: bool, sell_uids: Array = []) -> String:
	if phase != "offers":
		return "Taşınma ay başında (rapordan önce) yapılır."
	if factory_id == "":
		return "Kiralık yer yok."
	if id == factory_id:
		return "Zaten bu yerdesin."
	if is_moving():
		return "Bir taşınma sürüyor."
	var target := Data.factory_by_id(id)
	if target.is_empty():
		return "Bilinmeyen yer."
	for uid in sell_uids:
		var machine := machine_by_uid(int(uid))
		if machine.is_empty():
			return "Satılacak makine bulunamadı."
		if machine["mortgaged"]:
			return "%s ipotekli: kredi kapanmadan satılamaz." % machine["model"]
	var staying := machines.size() - sell_uids.size()
	if staying > Data.slot_count(id):
		return "Yeni yerde %d yuva var; %d tezgahı daha satman gerekiyor." % [Data.slot_count(id), staying - Data.slot_count(id)]
	for machine in machines:
		if sell_uids.has(machine["uid"]):
			continue
		if float(machine["height"]) > float(target["height"]):
			return "Tavan çok alçak: %s sığmıyor (satabilirsin)." % machine["model"]
	var quote := prepay_quote(id, months)
	var due := float(quote["amount"]) if prepay else 0.0
	var first_rent := 0.0 if prepay else float(quote["rent"])
	var size_scale := SCALES[2] if Data.size_class(int(target["m2"])) == "large" else (SCALES[1] if Data.size_class(int(target["m2"])) == "medium" else SCALES[0])
	var guarantee: float = float(SHELL_MONEY_BANDS[int(size_scale["max_tier"])][1]) * float(size_scale["factor"])
	var costs := move_cost(id, sell_uids)
	if cash - float(costs["total"]) - due < first_rent + guarantee:
		return "Taşınmadan sonra kasa %.0f; çıkış, taşıma, kira ve gizli sorun güvencesi için en az %.0f gerekli." % [cash - float(costs["total"]) - due, first_rent + guarantee]
	return ""

# The machines are taken down, driven over and set up again: for one month they stand still (no production,
# jobs wait, the crews stay on the payroll). The old contract ends with its exit fee and the new rent starts now.
# Machines that do not fit the new plant are sold first (the player chooses which).
func move_factory(id: String, months: int, prepay: bool, sell_uids: Array = []) -> String:
	var reason := move_block_reason(id, months, prepay, sell_uids)
	if reason != "":
		notice = reason
		return reason
	var costs := move_cost(id, sell_uids)
	var equipment_plan := move_equipment_plan(id)
	var quote := prepay_quote(id, months)
	var old_name: String = factory()["name"]
	for uid in sell_uids:
		var sold := machine_by_uid(int(uid))
		cash += sale_income(sold)
		machines.erase(sold)
	cash -= float(costs["exit"]) + float(costs["transport"]) + float(costs["extra_set"])
	invested += float(costs["extra_set"])
	if package_bought:
		# the old set and the extras become single items again: the new class takes its list, the rest stays as extras
		var new_items: Dictionary = Data.package_for(int(Data.factory_by_id(id)["m2"]))["items"]
		var old_items: Dictionary = package_info()["items"]
		for item in new_items:
			equip[item] = int(equipment_plan["surplus"].get(item, 0))
		for item in old_items:
			if not new_items.has(item):
				equip[item] = int(equip.get(item, 0)) + int(old_items[item])
	var arrive := month + move_months()
	var slot := 0
	for machine in machines:
		machine["arrive"] = maxi(int(machine["arrive"]), arrive)
		machine["arrive_day"] = day
		machine["moving"] = true
		machine["slot"] = slot
		slot += 1
	moving_until = arrive
	factory_id = id
	term = months
	months_left = months
	rent_markup = 0.0
	renewal_term = 0
	prepaid_months = 0
	if prepay:
		cash -= float(quote["amount"])
		prepaid_months = int(quote["half"])
	_hist("Yönetim", "Ay %d: %s → %s taşındı (%d ay üretim durur; çıkış %.0f, taşıma %.0f, ek ekipman %.0f, %d tezgah satıldı)." % [month, old_name, factory()["name"], move_months(), costs["exit"], costs["transport"], costs["extra_set"], sell_uids.size()])
	notice = "%s taşındın; tezgahlar %d ay sonra çalışır, personel ücretleri sürer." % [factory()["name"], arrive - month]
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
		refund += job_received(job)
		var order: Dictionary = job.get("order", {})
		if not order.is_empty() and not bool(order.get("paid", false)):
			orders += float(order["amount"])
	return {"jobs": jobs.size(), "penalty": penalty, "refund": refund, "orders": orders, "total": penalty + refund + orders}

func leave_fee() -> float:
	if months_left <= 1:
		return 0.0   # the contract's last month: leaving costs nothing
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
	_hist("Yönetim", "Ay %d: %s bırakıldı (çıkış bedeli %.0f; %d iş bırakıldı: ceza %.0f, peşinat iadesi %.0f, iptal edilemeyen hammadde %.0f)." % [month, factory()["name"], leave_fee(), jobs_cost["jobs"], jobs_cost["penalty"], jobs_cost["refund"], jobs_cost["orders"]])
	factory_id = ""
	rent_markup = 0.0
	renewal_term = 0
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
	return ""

func buy_package() -> String:
	var reason := package_block_reason()
	if reason != "":
		return reason
	var info := package_info()
	cash -= float(info["price"])
	invested += float(info["price"])
	package_bought = true
	_hist("Makine", "Ay %d: gerekli ekipman seti alındı (%.0f)." % [month, info["price"]])
	notice = "Gerekli ekipman tamam; kapasite kullanılabilir."
	return ""

func equipment_block_reason(id: String, qty: int) -> String:
	var item: Dictionary = Data.EQUIPMENT[id]
	if item.has("min_height") and float(factory()["height"]) < float(item["min_height"]):
		return "Tavan çok alçak"
	var reason := spend_block_reason(float(item["price"]) * qty)
	if reason != "":
		return reason
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
	if machines.size() >= slots_total():
		return "Tezgah yuvası dolu (%d/%d)" % [machines.size(), slots_total()]
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
	machine["slot"] = free_slot()
	machine["arrive_day"] = day
	machines.append(machine)
	if machines.size() == 1 and jobs.is_empty() and phase == "offers":
		_generate_offers()   # the first machine is bought: this month already lists small orders it can make
	_hist("Makine", "Ay %d: %s sipariş edildi (%.0f, teslim %d ay)." % [month, listing["model"], listing["price"], listing["delivery"]])
	notice = "%s sipariş edildi; teslimde personel işe başlar." % listing["model"]
	return ""

# ---------------------------------------------------------------- offers and jobs

func _generate_offers() -> void:
	offers.clear()
	if factory_id == "":
		return
	offers.assign(Data.generate_offers(month, offer_salt))
	_apply_pool_floor()
	_add_local_orders()
	Data.balance_pool(offers, rng)
	_add_continuous_offer()

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

# Small local orders every month: sized to what the plant can really make (about 35-60 percent of one owned
# machine's month), one or two months long, with room for the material to arrive. A small plant always has
# something it can take and deliver on time; the larger customers stay in the mix.
const LOCAL_ORDERS := 3

func _add_local_orders() -> void:
	if machines.is_empty() or offers.size() < LOCAL_ORDERS:
		return
	var mults := {"phys": 1.0, "non": 1.0}
	var taken := 0
	var smallest: Array = offers.duplicate()   # the local orders replace the smallest listings, so the pool's mix of sizes stays
	smallest.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return Data.offer_load(a) < Data.offer_load(b))
	var index := 0
	while taken < LOCAL_ORDERS and index < smallest.size():
		var machine: Dictionary = machines[(month + taken) % machines.size()]
		var offer: Dictionary = smallest[index]
		var duration := 1 + (taken % 2)
		var month_output := float(machine_steps(machine, mults)["net"])
		var level := rng.randi_range(1, int(machine["level"]))
		offer["duration"] = duration
		offer["start_delay"] = 0
		offer["months"] = duration + 2
		offer["urgency"] = rng.randi_range(1, 10)
		Data.fill_offer(offer, [{"kind": machine["kind"], "level": level, "n": 1, "load": month_output * duration * rng.randf_range(0.35, 0.6)}], rng)
		offer["local"] = true
		taken += 1
		index += 1

# Once the delivery record allows it, a standing contract appears in some months: 12 months, 30 percent of one owned machine
# kind, material supplied by the customer, a low steady margin.
func _add_continuous_offer() -> void:
	if machines.is_empty() or delivery_score < float(Data.CONTINUOUS_GATE["score"]) or rng.randf() > 0.5:
		return
	var machine: Dictionary = machines[rng.randi_range(0, machines.size() - 1)]
	var offer := {"id": month * 100 + 90, "customer": Data.CUSTOMERS[rng.randi_range(0, Data.CUSTOMERS.size() - 1)], "duration": Data.CONTINUOUS_MONTHS,
		"start_delay": 0, "months": Data.CONTINUOUS_MONTHS, "urgency": rng.randi_range(1, 5), "fason": true, "continuous": true, "capacity_share": Data.CONTINUOUS_SHARE}
	var month_output := float(machine_steps(machine, {"phys": 1.0, "non": 1.0})["net"])
	Data.fill_offer(offer, [{"kind": machine["kind"], "level": int(machine["level"]), "n": 1, "load": month_output * Data.CONTINUOUS_SHARE * float(Data.CONTINUOUS_MONTHS)}], rng)
	offer["mid"] = Data.CONTINUOUS_MARGIN
	offer["revenue"] = snappedf(float(offer["cost_ref"]) * (1.0 + Data.CONTINUOUS_MARGIN), 0.001)
	for req in offer["reqs"]:
		req["daily_cap"] = float(req["workload"]) / float(Data.CONTINUOUS_MONTHS * Data.MONTH_DAYS) * 1.15
	if Data.continuous_enabled:
		offers.append(offer)

func continuous_block_reason(offer: Dictionary) -> String:
	if not bool(offer.get("continuous", false)):
		return ""
	for job in jobs:
		if bool(job.get("continuous", false)) and job["reqs"][0]["kind"] == offer["reqs"][0]["kind"]:
			return "Bu tezgah türünde zaten bir Sürekli İşin var."
	return ""

func accept_block_reason(id: int) -> String:
	if phase != "offers":
		return "İş, ay başında (rapordan önce) kabul edilir."
	var gate := gate_block_reason(id)
	if gate != "":
		return gate
	var standing := continuous_block_reason(offer_by_id(id))
	if standing != "":
		return standing
	return fit_block_reason(id)

# Big jobs need a record: finished jobs and a delivery score (see Data.JOB_TIERS).
func gate_block_reason(id: int) -> String:
	var gate := Data.job_gate(offer_by_id(id))
	if gate.is_empty() or (jobs_done >= int(gate["jobs"]) and delivery_score >= float(gate["score"])):
		return ""
	return "Bu işe teklif verebilmek için en az %d iş bitirmiş olmalı ve %%%d teslim skorun olmalı (şu an %d iş, %%%d)." % [int(gate["jobs"]), int(roundf(float(gate["score"]) * 100.0)), jobs_done, int(roundf(delivery_score * 100.0))]

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
# Tolerance slack: a job coarser than the machine that would serve it leaves room to trade for speed or scrap.
# 0 = the machine is exactly as precise as the drawing, 1 = at least 5x looser.
func req_slack(job: Dictionary, req: Dictionary) -> float:
	var basis := serving_basis(req["kind"], int(req["level"]))
	var precision := float(Data.PRECISION_MM[int(basis["level"])])
	var tol := float(req.get("tolerance", precision))
	return clampf(log(maxf(1.0, tol / precision)) / log(5.0), 0.0, 1.0)

func slack_of(job: Dictionary) -> float:
	var best := 0.0
	for req in job["reqs"]:
		best = maxf(best, req_slack(job, req))
	return best

# mode: "" none, "speed" (up to +25% output, scrap unchanged), "scrap" (up to -50% scrap, speed unchanged)
func choose_bonus(job_id: int, mode: String) -> void:
	var job := job_by_id(job_id)
	if job.is_empty():
		return
	job["bonus"] = mode
	job["bonus_ask"] = false
	for req in job["reqs"]:
		var slack := req_slack(job, req)
		req["speed_mult"] = 1.0 + Data.SLACK_SPEED * slack if mode == "speed" else 1.0
		req["scrap_mult"] = 1.0 - Data.SLACK_SCRAP * slack if mode == "scrap" else 1.0

func bonus_pending() -> int:
	for job in jobs:
		if bool(job.get("bonus_ask", false)):
			return int(job["id"])
	return -1

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
	job["start_day"] = day
	job["accept_day"] = day
	job["due_month"] = month + due_months - 1
	job["produced"] = 0.0
	job["yield"] = 1.0
	job["advance"] = advance
	job["progress"] = quote_progress or bool(offer.get("continuous", false))
	job["order"] = {}
	if bool(offer.get("fason", false)):
		job["order"] = {"supplier": "customer", "order_month": month, "arrive_month": month, "arrive_day": day, "pay_month": month, "pay_day": day, "amount": 0.0, "paid": true, "delayed": false}
	var scrap_draw := RandomNumberGenerator.new()
	scrap_draw.seed = 31 * int(offer["id"]) + 7 * month + 3
	var draws: Array = []
	for req in job["reqs"]:
		draws.append(scrap_draw.randf())
	job["scrap_draws"] = draws
	job["bonus"] = ""
	job["bonus_ask"] = false
	jobs.append(job)
	offers.erase(offer)
	if slack_of(job) >= Data.SLACK_MIN:
		job["bonus_ask"] = true
	_hist("İşler", "Ay %d: iş kabul edildi: %s (fiyat %.0f, peşinat %.0f)." % [month, job["title"], price, advance])
	notice = "%s kabul edildi; %.0f peşinat kasaya girdi." % [job["title"], advance]
	if auto_order and not bool(offer.get("fason", false)):
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
	var slots := maxf(float(machines.size()), float(slots_total()) if factory_id != "" else 1.0)
	var fixed_pool := base_rent() + plant_fixed_cost() + (float(loan["installment"]) if not loan.is_empty() else 0.0)
	var fixed_share := fixed_pool / maxf(1.0, slots)
	var lines: Array = []
	var total := material
	var base_total := material
	for i in offer["reqs"].size():
		var req: Dictionary = offer["reqs"][i]
		var edit: Dictionary = edits.get(i, {})
		var material_part := float(req.get("material_part", 0.0)) * supplier_price
		var months := float(req["count"]) * float(offer["duration"]) * float(offer.get("capacity_share", 1.0))
		var rate := Data.scrap_rate(req["kind"], int(req["level"]), quality)
		var rate_used := maxf(0.0, rate + float(edit.get("scrap_pt", 0.0)) / 100.0)
		var basis := serving_basis(req["kind"], int(req["level"]))
		var energy_base := months * float(basis["energy"])
		var overhead_base := months * fixed_share
		var personnel_base := months * (Data.wage_for(req["kind"]) + staff_cost_per_head()) * float(basis["personnel"])
		var amort_base := months * float(basis["price"]) / float(Data.AMORT_MONTHS)
		var consumables_base := Data.CONSUMABLE_SHARE * (material_part + personnel_base + energy_base)
		var line := {"kind": req["kind"], "level": req["level"], "count": req["count"], "months": months,
			"material_part": material_part, "scrap_rate": rate, "scrap_rate_used": rate_used, "scrap_range": Data.scrap_range(req["kind"], int(req["level"])),
			"scrap": material_part * rate_used, "overhead": overhead_base * (1.0 + float(edit.get("overhead_pct", 0.0)) / 100.0),
			"energy": energy_base * (1.0 + float(edit.get("overhead_pct", 0.0)) / 100.0),
			"personnel": personnel_base * (1.0 + float(edit.get("personnel_pct", 0.0)) / 100.0),
			"amortization": amort_base * (1.0 + float(edit.get("amortization_pct", 0.0)) / 100.0),
			"consumables": consumables_base * (1.0 + float(edit.get("consumables_pct", 0.0)) / 100.0),
			"serving_level": basis["level"], "serving_owned": basis["owned"]}
		line["subtotal"] = float(line["scrap"]) + float(line["overhead"]) + float(line["energy"]) + float(line["personnel"]) + float(line["amortization"]) + float(line["consumables"])
		total += float(line["subtotal"])
		base_total += material_part * rate + overhead_base + energy_base + personnel_base + amort_base + consumables_base
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
func _boost_scrap_factor(req: Dictionary) -> float:
	var made := float(req.get("made_month", 0.0))
	if made <= 0.0 or not req.has("scrap_w"):
		return 1.0
	return float(req["scrap_w"]) / made

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
		cost += material * share * drawn * float(req.get("scrap_mult", 1.0)) * _boost_scrap_factor(req) * float(req.get("made_month", 0.0)) / maxf(1.0, float(req["workload"]))
	return cost

# The customer's own cost belief (from the reference price and the job's complexity margin).
func customer_cost(offer: Dictionary) -> float:
	return float(offer["cost_ref"])

# Highest price the customer accepts: cost x (1 + margin) where the margin runs from
# (mid - 20 points) for a relaxed customer to (mid + 25 points) for an urgent one, then lowered
# by a weak delivery score, a bigger advance and a later delivery.
const ADVANCE_OVER := 0.012    # beyond the comfortable advance the limit falls 1.2 percent per extra point

# The advance customers accept without a fuss grows with the delivery score (a reliable supplier may ask more).
func advance_comfort() -> int:
	return int(roundf(20.0 + 45.0 * delivery_score))

# A later delivery is refused outright by impatient customers: one month by urgency 8+, two months by urgency 5+.
static func time_refused(urgency: int, months_late: int) -> bool:
	return (months_late >= 2 and urgency >= 5) or (months_late == 1 and urgency >= 8)

const ADVANCE_EFFECT := 0.004   # the customer's limit falls 0.4 percent per point of advance asked (30 is neutral)

func customer_limit(offer: Dictionary, advance_pct: int, months_offered: int, urgency := -1.0) -> float:
	var mid := float(offer["mid"])
	var urgent := float(offer["urgency"]) if urgency < 0.0 else urgency
	var top_margin := mid + 0.25 + Data.SMALL_PREMIUM * Data.small_factor(Data.offer_load(offer))   # small jobs: wider top (IDEA-021)
	var margin := lerpf(maxf(0.05, mid - 0.20), top_margin, (urgent - 1.0) / 9.0)
	if bool(offer.get("continuous", false)):
		margin = Data.CONTINUOUS_MARGIN + 0.08 * (urgent - 1.0) / 9.0   # a framework contract: 14 to 22 percent over cost
	var limit := customer_cost(offer) * (1.0 + margin)
	limit *= 0.90 + 0.15 * delivery_score
	limit *= 1.0 - ADVANCE_EFFECT * float(advance_pct - 30)
	if advance_pct > advance_comfort():
		limit *= 1.0 - ADVANCE_OVER * float(advance_pct - advance_comfort())
	if not quote_progress and not bool(offer.get("continuous", false)):
		limit *= 1.0 + minf(0.10, 0.015 * float(months_offered))   # paying only at delivery suits the customer (IDEA-021)
	var wanted: int = int(offer["months"])
	if months_offered > wanted:
		var late := float(months_offered - wanted)
		limit *= 1.0 - (0.08 * late + 0.07 * late * late)   # one month later costs 15 percent, two months 42 percent
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

const MAX_QUOTE_ROUNDS := 3

# Share of plausible customers (by hidden urgency) who would take, or counter, this offer. Before the customer
# has written, every urgency 1-10 is equally likely; afterwards the reminder count narrows it to +-2.
func accept_probability(offer: Dictionary, price: float, advance_pct: int, months_offered: int, hint_known := false) -> Dictionary:
	var low := 1
	var high := 10
	if hint_known:
		var noisy := Data.urgency_noisy(offer)
		low = maxi(1, noisy - 2)
		high = mini(10, noisy + 2)
	var wanted: int = int(offer["months"])
	var accept := 0
	var counter := 0
	var total := 0
	for u in range(low, high + 1):
		total += 1
		var limit := customer_limit(offer, advance_pct, months_offered, float(u))
		var time_block := months_offered > wanted and time_refused(u, months_offered - wanted)
		if price <= limit and not time_block:
			accept += 1
		elif price <= limit * (1.0 + COUNTER_BAND):
			counter += 1
	return {"accept": float(accept) / float(total), "counter": float(counter) / float(total)}

func _mail(offer: Dictionary, status: String, lines: Array, extra := {}) -> Dictionary:
	var mail := {"id": next_mail, "month": month, "offer_id": offer["id"], "title": offer["title"], "customer": offer["customer"],
		"contact": Data.contact_of(offer), "contact_photo": String(Data.contact_info(offer)["id"]), "contact_role": String(Data.contact_info(offer)["role"]), "status": status, "lines": lines, "offer": offer.duplicate(true), "read": false, "kind": "quote", "round": 1}
	mail.merge(extra, true)
	next_mail += 1
	mails.push_front(mail)
	while mails.size() > 90:
		mails.pop_back()
	return mail

# Plain notice for the mailbox (machine arrived, job delivered, ...).
func post_mail(title: String, lines: Array, sender := "Sistem") -> Dictionary:
	var mail := {"id": next_mail, "month": month, "offer_id": 0, "title": title, "customer": sender, "contact": "", "status": "info",
		"lines": lines, "offer": {}, "read": false, "kind": "system", "round": 1}
	next_mail += 1
	mails.push_front(mail)
	while mails.size() > 90:
		mails.pop_back()
	return mail

# All mails about one job, newest first (the whole bargaining chain); system mails stand alone.
func mail_thread(mail: Dictionary) -> Array:
	if int(mail.get("offer_id", 0)) <= 0:
		return [mail]
	var thread: Array = []
	for other in mails:
		if int(other.get("offer_id", 0)) == int(mail["offer_id"]) and mail_arrived(other):
			thread.append(other)
	thread.sort_custom(func(a, b): return int(a["id"]) > int(b["id"]))
	return thread

# A customer answer travels for 5-10 seconds (real time) before it shows up in the inbox.
func mail_arrived(mail: Dictionary) -> bool:
	return not mail.has("ready_ms") or Time.get_ticks_msec() >= int(mail["ready_ms"])

func delay_mail(mail: Dictionary) -> void:
	mail["ready_ms"] = Time.get_ticks_msec() + randi_range(5000, 10000)

func unread_mails() -> int:
	var count := 0
	for mail in mails:
		if not bool(mail.get("read", true)) and mail_arrived(mail):
			count += 1
	return count

func delete_mail(id: int) -> void:
	for mail in mails:
		if mail["id"] == id:
			mails.erase(mail)
			return

# One reply per quote round. Accepted, countered (price or time) or rejected with an explanatory note.
func submit_quote(offer_id: int, price: float, advance_pct: int, months_offered: int, round := 1) -> Dictionary:
	var reason := quote_block_reason(offer_id, price)
	if reason != "":
		return {"ok": false, "reason": reason}
	var offer := offer_by_id(offer_id)
	if round == 1:
		quotes_sent += 1
	var limit := customer_limit(offer, advance_pct, months_offered)
	var wanted: int = int(offer["months"])
	var cost_total := float(cost_estimate(offer)["total"])
	var base := {"my_price": price, "my_advance": advance_pct, "my_months": months_offered, "cost_total": cost_total, "round": round,
		"mail_no": Data.mail_count(offer, round), "my_progress": quote_progress, "my_margin": price / maxf(0.001, cost_total) - 1.0}
	if price <= limit:
		if months_offered > wanted and time_refused(int(offer["urgency"]), months_offered - wanted) and round >= MAX_QUOTE_ROUNDS:
			var firm := _mail(offer, "rejected", ["Teslim süresi bizim için şart: %d ayda teslim edemeyeceğiniz için bu işte çalışamayacağız." % wanted], base)
			offers.erase(offer)
			return {"ok": true, "status": "rejected", "mail": firm}
		if months_offered > wanted and time_refused(int(offer["urgency"]), months_offered - wanted) and round < MAX_QUOTE_ROUNDS:
			var extra := base.duplicate()
			extra.merge({"price": price, "advance_pct": advance_pct, "months": wanted, "kind_counter": "time"}, true)
			var mail := _mail(offer, "counter", ["Teşekkürler, fiyatınız uygun. Ancak %d ayda teslim istiyoruz; bu süreyi kabul ederseniz anlaşalım." % wanted], extra)
			offers.erase(offer)
			return {"ok": true, "status": "counter", "mail": mail}
		quotes_won += 1
		var job := _create_job(offer, price, float(advance_pct) / 100.0, months_offered)
		var accepted := _mail(offer, "accepted", ["Teklifiniz için teşekkürler, %s fiyatla %d ayda teslim şartıyla anlaştık." % [Data.usd(price), months_offered]], base)
		accepted["read"] = false
		return {"ok": true, "status": "accepted", "mail": accepted, "job": job}
	if round < MAX_QUOTE_ROUNDS and price <= limit * (1.0 + COUNTER_BAND):
		var counter_price := snappedf(limit * rng.randf_range(0.96, 1.0), 0.001)
		var extra2 := base.duplicate()
		extra2.merge({"price": counter_price, "advance_pct": advance_pct, "months": months_offered, "kind_counter": "price",
			"request_pct": 1.0 - counter_price / maxf(0.001, price)}, true)
		var mail2 := _mail(offer, "counter", ["Teşekkürler. Teklifinizi %s olarak güncelleyebilir misiniz?" % Data.usd(counter_price)], extra2)
		offers.erase(offer)
		return {"ok": true, "status": "counter", "mail": mail2}
	var note := "Teklifiniz hedef fiyatımızın üstünde olduğu için bu işte çalışamayacağız.\nNot: firmanın belirlediği tahmini maliyet %s." % Data.usd(customer_cost(offer))
	var rejected := _mail(offer, "rejected", note.split("\n"), base)
	offers.erase(offer)
	return {"ok": true, "status": "rejected", "mail": rejected}

func mail_by_id(id: int) -> Dictionary:
	for mail in mails:
		if mail["id"] == id:
			return mail
	return {}

# The player answers a counter by sending a revised offer (price and, for a time counter, the delivery).
func revise_quote(mail_id: int, price: float, months_offered := -1, advance_pct := -1) -> Dictionary:
	var mail := mail_by_id(mail_id)
	if mail.is_empty() or mail["status"] != "counter":
		return {"ok": false, "reason": "Bu teklif artık yanıt beklemiyor."}
	if phase != "offers":
		return {"ok": false, "reason": "Yanıt ay başında verilir."}
	var offer: Dictionary = mail["offer"].duplicate(true)
	offers.append(offer)
	quote_progress = bool(mail.get("my_progress", true))
	var result := submit_quote(int(offer["id"]), price, int(mail["my_advance"]) if advance_pct < 0 else advance_pct,
		int(mail["my_months"]) if months_offered < 0 else months_offered, int(mail["round"]) + 1)
	if not result["ok"]:
		offers.erase(offer)
		return result
	mail["status"] = "revised"
	mail["read"] = true
	return result

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
	var result := revise_quote(mail_id, float(mail["price"]), int(mail["months"]), int(mail["advance_pct"]))
	if not result["ok"]:
		return String(result["reason"])
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
		"pay_month": month + int(quote["terms"]), "amount": float(quote["amount"]), "paid": false, "delayed": delayed, "arrive_day": day, "pay_day": day}
	job["order"] = order
	job["yield"] = float(quote["yield"])
	if int(quote["terms"]) == 0:
		cash -= float(quote["amount"])
		order["paid"] = true
	_hist("Tedarik", "Ay %d: hammadde siparişi: %s ← %s (%.0f, gelir Ay %d)." % [month, job["title"], quote["supplier"]["name"], quote["amount"], order["arrive_month"]])
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
	if abandon_penalty(job) + job_received(job) > cash:
		return "Yetersiz nakit (ceza + alınan ödemelerin iadesi %.0f)" % (abandon_penalty(job) + job_received(job))
	return ""

# The job is dropped: the advance is refunded, the penalty is paid, material already
# paid or ordered is lost, and the delivery score falls.
func abandon_job(id: int) -> String:
	var reason := abandon_block_reason(id)
	if reason != "":
		return reason
	var job := job_by_id(id)
	var penalty := abandon_penalty(job)
	cash -= penalty + job_received(job)
	jobs.erase(job)
	_score_event(0.0)
	_hist("İşler", "Ay %d: iş bırakıldı: %s (ceza %.0f, alınan ödemeler iade %.0f, hammadde yandı)." % [month, job["title"], penalty, job_received(job)])
	notice = "%s bırakıldı; ceza %.0f, peşinat iade edildi, ödenen hammadde kayıp, teslimat skoru düştü." % [job["title"], penalty]
	return ""

# Delivery score in 0..1: on time pulls toward 1, late toward 0.4, dropped jobs toward 0.
# Days a delivery on (month m, day d) is past the end of its due month; 0 when on time.
func late_days(due_month: int, m: int, d: int) -> int:
	return maxi(0, (m - due_month) * Data.MONTH_DAYS + (d - Data.MONTH_DAYS))

# Delivery-score target of a delivery: 1 on time, falling in a straight line to 0.4 at a month late (and beyond).
func late_target(days: int) -> float:
	return 1.0 - 0.6 * minf(1.0, float(days) / float(Data.MONTH_DAYS))

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
	_hist("Makine", "Ay %d: %s satıldı (+%.0f)." % [month, machine["model"], income])
	notice = "%s satıldı; %.0f nakit girdi, etkin kapasite azaldı." % [machine["model"], income]
	return ""

# ---------------------------------------------------------------- day by day (IDEA-019)

var day := 1                    # day of the current month, 1..MONTH_DAYS
var days_run := 0               # days of this month already produced (0 = the monthly shortcut is still allowed)
var month_events: Array = []    # this month's day events, printed in the closing report
var month_material_used := 0.0  # material of jobs delivered earlier this month
var month_revenue := 0.0        # revenue delivered earlier this month
var jobs_done := 0                 # finished (delivered) jobs: the track record big listings ask for
var committed_history: Array = []  # month-end money already owed (material + the month's costs)
var free_history: Array = []
var invest_history: Array = []
var debt_history: Array = []
var oee_history: Array = []        # [{availability, performance, quality, oee}] of every closed month
var event_log: Array = []          # [{month, day, category, text, amount}]
var cash_history: Array = []      # cash at the end of every month (for the management screen)
var revenue_history: Array = []   # delivered revenue of every month
var quotes_sent := 0
var quotes_won := 0
var lifetime_revenue := 0.0     # all delivered revenue so far (for the closing letter)
var month_late := 0             # late deliveries earlier this month
var month_running := 0.0        # running costs accrued day by day (crews, energy, upkeep, plant) with the plan of each day

func _delivered_on(machine: Dictionary, d: int, m := -1) -> bool:
	var at := month if m < 0 else m
	return int(machine["arrive"]) < at or (int(machine["arrive"]) == at and int(machine.get("arrive_day", 1)) <= d)

func _producing(machine: Dictionary, d: int, m := -1) -> bool:
	return package_bought and _delivered_on(machine, d, m)

func _material_ready_day(job: Dictionary, d: int, m := -1) -> bool:
	var at := month if m < 0 else m
	var order: Dictionary = job.get("order", {})
	if order.is_empty():
		return false
	var arrive_month := int(order["arrive_month"])
	return arrive_month < at or (arrive_month == at and int(order.get("arrive_day", 1)) <= d)

func _job_started_day(job: Dictionary, d: int, m := -1) -> bool:
	var at := month if m < 0 else m
	var start_month := int(job["start_month"])
	return start_month < at or (start_month == at and int(job.get("start_day", 1)) <= d)

# Share of the month a machine that arrived this month is on the payroll (running costs follow production).
func service_fraction(machine: Dictionary) -> float:
	if days_run > 0 and int(machine["arrive"]) == month:
		return clampf(float(Data.MONTH_DAYS - int(machine.get("arrive_day", 1)) + 1) / float(Data.MONTH_DAYS), 0.0, 1.0)
	return 1.0

# One day of production and cash events. Returns {day, produced {uid: amount}, events [{text, amount}], month_end}.
func advance_day() -> Dictionary:
	var result := {"day": day, "produced": {}, "events": [], "month_end": false}
	if phase != "offers" or factory_id == "":
		return result
	if days_run >= Data.MONTH_DAYS:
		result["month_end"] = true
		return result
	if days_run == 0:
		month_events = []
		month_material_used = 0.0
		month_revenue = 0.0
		month_late = 0
		month_running = 0.0
		for machine in machines:
			machine["used_last"] = 0.0
			machine["output_last"] = 0.0
		for job in jobs:
			for req in job["reqs"]:
				req["made_month"] = 0.0
				req["scrap_w"] = 0.0
	var events: Array = result["events"]
	for machine in machines:
		if int(machine["arrive"]) == month and int(machine.get("arrive_day", 1)) == day:
			var text := "%s %s · %d personel işe başladı" % [machine["model"], "yeni yerinde kuruldu" if bool(machine.get("moving", false)) else "teslim alındı", machine["personnel"]]
			events.append({"text": text, "amount": 0.0})
	# supplier payments fall on their day
	for job in jobs:
		var order: Dictionary = job.get("order", {})
		if order.is_empty() or bool(order.get("paid", false)):
			continue
		if int(order["pay_month"]) < month or (int(order["pay_month"]) == month and int(order.get("pay_day", 1)) <= day):
			cash -= float(order["amount"])
			order["paid"] = true
			events.append({"text": "Hammadde ödemesi: %s" % job["title"], "amount": -float(order["amount"])})
	# production of the day
	var mults := problem_mults(loss_fractions())
	var cap_left := {}
	for machine in machines:
		if _producing(machine, day):
			var share := float(machine_steps(machine, mults)["net"]) / float(Data.MONTH_DAYS)
			cap_left[machine["uid"]] = share
			machine["output_last"] = float(machine.get("output_last", 0.0)) + share
	var before := cap_left.duplicate()
	_allocate_day(cap_left)
	for uid in cap_left:
		var made := float(before[uid]) - float(cap_left[uid])
		if made > 0.0001:
			result["produced"][uid] = made
			var machine_now := machine_by_uid(int(uid))
			var rate := clampf(machine_scrap(machine_now), 0.0, 0.9) if not machine_now.is_empty() else 0.0
			var counts: Array = month_counts.get(uid, [0.0, 0.0])
			counts[0] = float(counts[0]) + made
			counts[1] = float(counts[1]) + made * rate / (1.0 - rate)
			month_counts[uid] = counts
	# running costs of the day follow the plan of the day: a shift cut on the last day does not cheapen the month
	var day_cost := plant_fixed_cost() / float(Data.MONTH_DAYS)
	for machine in machines:
		if _delivered_on(machine, day):
			var capacity_today := float(before.get(machine["uid"], 0.0))
			var worked := clampf(float(result["produced"].get(machine["uid"], 0.0)) / capacity_today, 0.0, 1.0) if capacity_today > 0.0 else 0.0
			day_cost += ((machine_energy(machine) * shift_equiv(machine) + machine_maintenance(machine)) * worked + machine_wages(machine) * (Data.IDLE_WAGE_FLOOR + (1.0 - Data.IDLE_WAGE_FLOOR) * worked)) / float(Data.MONTH_DAYS)
		elif bool(machine.get("moving", false)) and int(machine["arrive"]) > month:
			day_cost += machine_wages(machine) / float(Data.MONTH_DAYS)
	month_running += day_cost
	# finished jobs are delivered the same day
	var running: Array = []
	for job in jobs:
		if job_done(job):
			events.append_array(_deliver_job(job))
		else:
			running.append(job)
	jobs = running
	for event in events:
		log_event(_event_category(String(event["text"])), String(event["text"]), float(event["amount"]))
		month_events.append("Gün %d: %s%s" % [day, event["text"], (" (%s)" % Data.usd(float(event["amount"]))) if absf(float(event["amount"])) > 0.0005 else ""])
	days_run += 1
	if day < Data.MONTH_DAYS:
		day += 1
	result["month_end"] = days_run >= Data.MONTH_DAYS
	return result

# Plays the remaining days of the month at once (skipping ahead); returns the events of those days.
func finish_month_days() -> Array:
	var events: Array = []
	var guard := 0
	while phase == "offers" and days_run < Data.MONTH_DAYS and guard < 40:
		events.append_array(advance_day()["events"])
		guard += 1
	return events

# Same allocation as the monthly one (oldest job first), limited to what exists on this day.
func _allocate_day(cap_left: Dictionary) -> void:
	_allocate_at(jobs, cap_left, month, day, true)

func _allocate_at(job_list: Array, cap_left: Dictionary, m: int, d: int, record: bool) -> void:
	for job in job_list:
		if not _job_started_day(job, d, m) or not _material_ready_day(job, d, m):
			continue
		var job_yield := float(job.get("yield", 1.0))
		for req in job["reqs"]:
			var need := minf(float(req["remaining"]), float(req.get("daily_cap", INF)))   # a standing contract takes only its share each day
			if need <= 0.0001:
				continue
			var eligible: Array = []
			for machine in machines:
				if machine["kind"] == req["kind"] and int(machine["level"]) >= int(req["level"]) and _producing(machine, d, m):
					eligible.append(machine)
			eligible.sort_custom(func(a, b): return int(a["level"]) < int(b["level"]))
			for machine in eligible:
				if need <= 0.0001:
					break
				var available := float(cap_left.get(machine["uid"], 0.0))
				if available <= 0.0:
					continue
				var boost := machine_boost(machine)
				var rate_mult := job_yield * minf(float(req.get("speed_mult", 1.0)), Data.SPEED_CAP / (1.0 + boost))
				var use := minf(available, need / rate_mult)
				cap_left[machine["uid"]] = available - use
				var got := use * rate_mult
				need -= got
				req["remaining"] = maxf(0.0, float(req["remaining"]) - got)
				job["produced"] = float(job.get("produced", 0.0)) + got
				if record:
					machine["used_last"] = float(machine.get("used_last", 0.0)) + use
					req["made_month"] = float(req.get("made_month", 0.0)) + got
					req["scrap_w"] = float(req.get("scrap_w", 0.0)) + got * (1.0 + Data.BOOST_SCRAP * boost)

# Day-by-day forecast from today: the date (month, day) every job (and the extra one) would be done, 0 when
# it does not finish within a year. Nothing is changed.
func projection_days(extra := {}) -> Dictionary:
	var copy: Array = jobs.duplicate(true)
	if not extra.is_empty():
		copy.append(extra)
	var mults := problem_mults(loss_fractions())
	var nets := {}
	for machine in machines:
		nets[machine["uid"]] = float(machine_steps(machine, mults)["net"]) / float(Data.MONTH_DAYS)
	var finish := {}
	var m := month
	var d := day
	for _step in range(Data.MONTH_DAYS * 12):
		var cap_left := {}
		for machine in machines:
			if _producing(machine, d, m):
				cap_left[machine["uid"]] = nets[machine["uid"]]
		_allocate_at(copy, cap_left, m, d, false)
		for job in copy:
			if not finish.has(job["id"]) and job_done(job):
				finish[job["id"]] = [m, d]
		d += 1
		if d > Data.MONTH_DAYS:
			d = 1
			m += 1
	return finish

# A job whose workload is done leaves on the day it finishes: the balance comes in, the score moves.
func _deliver_job(job: Dictionary) -> Array:
	var events: Array = []
	var order: Dictionary = job.get("order", {})
	if not order.is_empty() and not bool(order.get("paid", false)):
		cash -= float(order["amount"])
		order["paid"] = true
		events.append({"text": "Hammadde ödemesi (iş bitti): %s" % job["title"], "amount": -float(order["amount"])})
	var scrap_cost := scrap_cost_month(job)
	if scrap_cost > 0.0:
		cash -= scrap_cost
		events.append({"text": "Hurda gideri: %s" % job["title"], "amount": -scrap_cost})
	month_material_used += material_used_month(job)
	var days_late := late_days(int(job["due_month"]), month, day)
	var on_time := days_late == 0
	var remainder := float(job["revenue"]) - job_received(job)
	cash += remainder
	month_revenue += float(job["revenue"])
	_score_event(late_target(days_late))
	jobs_done += 1
	if not on_time:
		month_late += 1
	events.append({"text": "Teslim: %s%s" % [job["title"], "" if on_time else " · %d GÜN GEÇ (skor düştü)" % days_late], "amount": remainder})
	return events

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
			var need := minf(float(req["remaining"]), float(req.get("daily_cap", INF)) * float(Data.MONTH_DAYS))
			if need <= 0.0001:
				continue
			for machine in _eligible(req["kind"], int(req["level"]), t):
				if need <= 0.0001:
					break
				var available := float(cap_left.get(machine["uid"], 0.0))
				if available <= 0.0:
					continue
				var boost := machine_boost(machine)
				var rate_mult := job_yield * minf(float(req.get("speed_mult", 1.0)), Data.SPEED_CAP / (1.0 + boost))
				var use := minf(available, need / rate_mult)
				cap_left[machine["uid"]] = available - use
				var got := use * rate_mult
				need -= got
				req["remaining"] = maxf(0.0, float(req["remaining"]) - got)
				job["produced"] = float(job.get("produced", 0.0)) + got
				if record:
					machine["used_last"] = float(machine.get("used_last", 0.0)) + use
					req["made_month"] = float(req.get("made_month", 0.0)) + got
					req["scrap_w"] = float(req.get("scrap_w", 0.0)) + got * (1.0 + Data.BOOST_SCRAP * boost)

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

# Money already received for a job: the advance plus progress payments.
func job_received(job: Dictionary) -> float:
	return float(job["advance"]) + float(job.get("paid_progress", 0.0))

# Progress payment (hakediş): at month end the customer pays 80 % of the work done so far, the advance counting
# against it; the remaining 20 % and any rest come with the final delivery.
func _progress_payment(job: Dictionary) -> float:
	if not bool(job.get("progress", true)):
		return 0.0
	var workload := job_workload(job)
	if workload <= 0.0:
		return 0.0
	var share := clampf(1.0 - job_remaining(job) / workload, 0.0, 1.0)
	var target := maxf(0.0, Data.PROGRESS_SHARE * float(job["revenue"]) - float(job["advance"])) * share
	var due := target - float(job.get("paid_progress", 0.0))
	if due < 0.0005:
		return 0.0
	job["paid_progress"] = float(job.get("paid_progress", 0.0)) + due
	cash += due
	return due

func job_workload(job: Dictionary) -> float:
	var total := 0.0
	for req in job["reqs"]:
		total += float(req["workload"])
	return total

# Projected finish month for each job at today's capacity (0 = not within a year).
func projection(extra := {}) -> Dictionary:
	var copy: Array = jobs.duplicate(true)
	if not extra.is_empty():
		copy.append(extra)
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

# When a quoted offer would finish if accepted now: queue behind the accepted jobs, material from the default
# supplier (optionally one month late), the offer's own start delay, and the machines that exist or are in transit.
# The job as it would run if it were accepted today (delivery in `months_offered`, material from the default supplier).
func _quote_job(offer: Dictionary, months_offered: int, delayed := false) -> Dictionary:
	var job: Dictionary = offer.duplicate(true)
	var quote := material_quote(offer, default_supplier)
	job["months"] = months_offered
	job["start_month"] = month + int(offer["start_delay"])
	job["start_day"] = day
	job["due_month"] = month + months_offered - 1
	job["produced"] = 0.0
	job["yield"] = float(quote["yield"])
	job["order"] = {"supplier": default_supplier, "order_month": month, "arrive_month": month + int(quote["lead"]) + (1 if delayed else 0), "arrive_day": day,
		"pay_month": month + int(quote["terms"]), "pay_day": day, "amount": float(quote["amount"]), "paid": false, "delayed": delayed}
	if bool(offer.get("fason", false)):
		job["order"] = {"supplier": "customer", "arrive_month": month, "arrive_day": day, "pay_month": month, "pay_day": day, "amount": 0.0, "paid": true, "delayed": false}
	return job

func quote_projection(offer: Dictionary, months_offered: int, delayed := false) -> Dictionary:
	var job := _quote_job(offer, months_offered, delayed)
	var quote := material_quote(offer, default_supplier)
	var done: Array = projection_days(job).get(job["id"], [])
	var finish_month: int = int(done[0]) if not done.is_empty() else 0
	var finish_day: int = int(done[1]) if not done.is_empty() else 0
	return {"finish": finish_month, "finish_day": finish_day, "due": int(job["due_month"]), "late": finish_month == 0 or late_days(int(job["due_month"]), finish_month, finish_day) > 0,
		"late_days": 0 if finish_month == 0 else late_days(int(job["due_month"]), finish_month, finish_day), "delay_chance": float(quote["delay"])}

# Calendar of the machine kinds a quote needs, in days from today: {kind: {segments: [{id, title, start, end, extra}], window_end}}.
# The accepted jobs run first (oldest first); the quoted job takes what is left. `late_days` is the quoted job's lateness.
func plan_schedule(offer: Dictionary, months_offered: int) -> Dictionary:
	var extra := _quote_job(offer, months_offered)
	var copy: Array = jobs.duplicate(true)
	copy.append(extra.duplicate(true))
	var mults := problem_mults(loss_fractions())
	var nets := {}
	for machine in machines:
		nets[machine["uid"]] = float(machine_steps(machine, mults)["net"]) / float(Data.MONTH_DAYS)
	var first := {}
	var last := {}
	var m := month
	var d := day
	var steps := Data.MONTH_DAYS * 14
	for step in range(steps):
		var before := {}
		for job in copy:
			for i in job["reqs"].size():
				before["%d|%d" % [job["id"], i]] = float(job["reqs"][i]["remaining"])
		var cap_left := {}
		for machine in machines:
			if _producing(machine, d, m):
				cap_left[machine["uid"]] = nets[machine["uid"]]
		_allocate_at(copy, cap_left, m, d, false)
		for job in copy:
			for i in job["reqs"].size():
				if float(job["reqs"][i]["remaining"]) < float(before["%d|%d" % [job["id"], i]]) - 0.0001:
					var key := "%d|%s" % [job["id"], job["reqs"][i]["kind"]]
					if not first.has(key):
						first[key] = step
					last[key] = step + 1
		d += 1
		if d > Data.MONTH_DAYS:
			d = 1
			m += 1
	var kinds: Array = []
	for req in offer["reqs"]:
		if not kinds.has(req["kind"]):
			kinds.append(req["kind"])
	var window_end := (int(extra["due_month"]) - month) * Data.MONTH_DAYS + (Data.MONTH_DAYS - day + 1)
	var result := {"kinds": {}, "window_end": window_end, "late_days": 0}
	for kind in kinds:
		var segments: Array = []
		for job in copy:
			var key := "%d|%s" % [job["id"], kind]
			if first.has(key):
				segments.append({"id": job["id"], "title": job["title"], "start": int(first[key]), "end": int(last[key]), "extra": job["id"] == extra["id"]})
		result["kinds"][kind] = segments
	var done: Array = projection_days(extra).get(extra["id"], [])
	if not done.is_empty():
		result["late_days"] = late_days(int(extra["due_month"]), int(done[0]), int(done[1]))
	else:
		result["late_days"] = 999
	return result

# ---------------------------------------------------------------- report

func run_report() -> String:
	if phase != "offers":
		return "Rapor ay başından sonra açılır."
	if factory_id == "":
		return "Önce bir yer kirala."
	if days_run > 0 and days_run < Data.MONTH_DAYS:
		finish_month_days()   # switching to the monthly buttons mid-month still plays the missing days
	_auto_patron()
	_enforce_patron()
	var fr := loss_fractions()
	var mults := problem_mults(fr)
	var cap_left := {}
	var played := days_run > 0   # the days were produced one by one: keep what they made
	var sums := {"theoretical": 0.0, "shift": 0.0, "perf": 0.0, "scrap": 0.0, "phys": 0.0, "net": 0.0}
	for machine in delivered():
		var steps := machine_steps(machine, mults)
		var output := float(steps["net"]) if package_bought else 0.0
		if not played:
			machine["used_last"] = 0.0
			machine["output_last"] = output
		cap_left[machine["uid"]] = output
		for key in sums:
			sums[key] += float(steps[key]) if package_bought or key == "theoretical" else 0.0
	if not played:
		for job in jobs:
			for req in job["reqs"]:
				req["made_month"] = 0.0
				req["scrap_w"] = 0.0
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
	if jobs.is_empty() and used <= 0.0 and month_revenue <= 0.0:
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
	var running := month_running if days_run > 0 else running_cost_actual()
	cash -= running
	lines.append("Personel, enerji (yalnızca çalışan tezgahlar), bina işletme, dolaylı ve ofis kadrosu: %s" % Data.usd(running))
	var material_used := month_material_used
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
	var delivered_revenue := month_revenue
	report["undelivered"] = int(report.get("undelivered", 0)) + month_late
	lines.append_array(month_events)
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
			var days_late := late_days(int(job["due_month"]), month, Data.MONTH_DAYS)
			var on_time := days_late == 0
			var remainder := float(job["revenue"]) - job_received(job)
			cash += remainder
			delivered_revenue += float(job["revenue"])
			_score_event(late_target(days_late))
			jobs_done += 1
			lines.append("Teslim: %s (+%s kalan bakiye)%s" % [job["title"], Data.usd(remainder), "" if on_time else " · GEÇ TESLİM (skor düştü)"])
			if not on_time:
				report["undelivered"] = int(report.get("undelivered", 0)) + 1
		elif month > int(job["due_month"]) + LATE_CANCEL_MONTHS:
			var penalty := abandon_penalty(job)
			cash -= penalty + job_received(job)
			_score_event(0.0)
			lines.append("İptal: %s müşteri tarafından iptal edildi (ceza %s, peşinat iade %s, hammadde yandı)" % [job["title"], Data.usd(penalty), Data.usd(job_received(job))])
		else:
			var progress := _progress_payment(job)
			if progress > 0.0:
				lines.append("Hakediş tahsilatı: %s (+%s)" % [job["title"], Data.usd(progress)])
				log_event("Finans", "Hakediş tahsilatı: %s" % job["title"], progress)
			running_jobs.append(job)
	jobs = running_jobs
	report["revenue"] = delivered_revenue
	lifetime_revenue += delivered_revenue
	revenue_history.append(delivered_revenue)
	cash -= finance
	cash_history.append(cash)
	var com_end := commitments(false)
	committed_history.append(float(com_end["material"]) + float(com_end["expense"]))
	free_history.append(float(com_end["free"]))
	invest_history.append(float(investment_value()))
	debt_history.append(float(debt))   # debt already includes the loan balance
	var steps_now := report
	if float(steps_now.get("theoretical", 0.0)) > 0.0 and float(steps_now.get("shift", 0.0)) > 0.0 and float(steps_now.get("perf", 0.0)) > 0.0:
		var theo := float(steps_now["theoretical"])
		var shift_v := float(steps_now["shift"])
		var perf_v := float(steps_now["perf"])
		var phys_v := float(steps_now.get("phys", 0.0))
		var scrap_v := float(steps_now.get("scrap", 0.0))
		var rm: Dictionary = steps_now.get("mults", {"a": 1.0, "p": 1.0, "q": 1.0})
		# physical OEE (FRZ-008 v2: finance/non-physical losses stay outside); the three parts multiply to it
		var a_part := clampf(shift_v / theo * float(rm["a"]), 0.0, 1.0)
		var p_part := clampf(perf_v / shift_v * float(rm["p"]), 0.0, 1.0)
		var q_part := clampf(scrap_v / perf_v * float(rm["q"]), 0.0, 1.0)
		oee_history.append({"availability": a_part, "performance": p_part, "quality": q_part, "oee": clampf(phys_v / theo, 0.0, 1.0)})
	else:
		oee_history.append({"availability": 0.0, "performance": 0.0, "quality": 0.0, "oee": 0.0})
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
			_hist("Personel", "Ay %d: %s sözleşmesi bitti; bilgisi fabrikada kalmadı." % [month, consultant["name"]])
	consultants = still_active
	_grow_problems()
	var status := solvency()
	log_event("Finans", "Ay %d kapandı: gelir %s, kasa %s" % [month, Data.usd(delivered_revenue), Data.usd(cash)], delivered_revenue)
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
		last_lines.append(_contract_end())
	elif months_left == Data.NOTICE_MONTHS:
		_notice_mail()
	if days_run == 0:
		for machine in machines:
			if int(machine["arrive"]) == month:
				last_lines.append("Teslim alındı: %s · %d personel işe başladı" % [machine["model"], machine["personnel"]])
	day = 1
	days_run = 0
	month_events = []
	month_counts = {}
	month_material_used = 0.0
	month_revenue = 0.0
	month_late = 0
	month_running = 0.0
	benefits = benefits_next.duplicate()   # a change of the staff benefits starts with the new month
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
		if rng.randf() < PERSON_SHARE and rng.randf() < MAX_PREVENTION * skills[HR_SKILL] / 100.0 + staff_bonus():
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
	_hist("Finans", "Ay %d: %s kredisi %.0f alındı (%d makine ipotekli)." % [month, Data.CREDIT["bank"], terms["amount"], uids.size()])
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

# ---------------------------------------------------------------- event log

const LOG_CATEGORIES := ["İşler", "Finans", "Makine", "Tedarik", "Personel", "Yönetim"]

func _event_category(text: String) -> String:
	if text.begins_with("Teslim:") or text.begins_with("İptal:") or text.begins_with("İş "):
		return "İşler"
	if text.begins_with("Hammadde"):
		return "Tedarik"
	if text.contains("teslim alındı") or text.contains("kuruldu") or text.contains("tezgah"):
		return "Makine"
	if text.begins_with("Hurda") or text.begins_with("Kira") or text.begins_with("Finansman") or text.begins_with("Personel"):
		return "Finans"
	return "Yönetim"

func _hist(category: String, text: String) -> void:
	history.append(text)
	var clean: String = text.get_slice(": ", 1) if text.begins_with("Ay ") and text.contains(": ") else text
	var first := clean.substr(0, 1)
	log_event(category, ("İ" if first == "i" else first.to_upper()) + clean.substr(1))

func log_event(category: String, text: String, amount := 0.0) -> void:
	event_log.append({"month": month, "day": day, "category": category, "text": text, "amount": amount})
	if event_log.size() > 600:
		event_log.pop_front()

# ---------------------------------------------------------------- management screen data

# Capacity and load of every machine kind this month: {kind: {cap, load, count}} (net, current plan).
func production_line() -> Array:
	var rows: Array = []
	for kind in Data.TYPES:
		var chart := capacity_chart(kind)
		var cap := 0.0
		var load := 0.0
		for lv in chart["levels"]:
			cap += float(lv["cap"])
			load += float(lv["load"])
		var count := 0
		for machine in delivered():
			if machine["kind"] == kind:
				count += 1
		rows.append({"kind": kind, "cap": cap, "load": minf(load, cap), "count": count})
	return rows

# OEE split: availability (shifts, stoppages), performance and quality of the delivered park, weighted by capacity.
func oee_parts() -> Dictionary:
	var mults := problem_mults(loss_fractions())
	var weight := 0.0
	var avail := 0.0
	var perf := 0.0
	var quality := 0.0
	for machine in delivered():
		var w := float(machine["nameplate"])
		weight += w
		avail += w * availability(machine) * float(mults["non"])
		perf += w * float(machine["perf"]) * float(mults["phys"])
		quality += w * (1.0 - machine_scrap(machine))
	if weight <= 0.0:
		return {"availability": 0.0, "performance": 0.0, "quality": 0.0, "oee": 0.0}
	return {"availability": avail / weight, "performance": perf / weight, "quality": quality / weight, "oee": oee_now()}

# Staff by group: blue collar (machine crews), white collar (indirect), managers (office roles), consultants.
func staff_groups() -> Dictionary:
	return {"blue": staff_count(), "white": indirect_count(), "managers": office_roles().size(), "consultants": consultants.size()}

func quote_win_rate() -> float:
	return 0.0 if quotes_sent <= 0 else float(quotes_won) / float(quotes_sent)

# Jobs whose forecast finish is past their due date.
func risky_jobs() -> int:
	if jobs.is_empty():
		return 0
	var finish := projection_days()
	var risky := 0
	for job in jobs:
		var when: Array = finish.get(job["id"], [])
		if when.is_empty() or late_days(int(job["due_month"]), int(when[0]), int(when[1])) > 0:
			risky += 1
	return risky

# Things worth a look, most urgent first: [{severity: "red"|"amber"|"blue", text, target}].
func action_items() -> Array:
	var items: Array = []
	var com := commitments()
	if float(com["free"]) < 0.0:
		items.append({"severity": "red", "text": "Harcanabilir nakit negatif: ödemeler kasayı aşıyor", "target": "finance"})
	if factory_id != "" and (machines.is_empty() or not package_bought):
		var first_step := "İlk adım: ekipman paketini satın al" if not package_bought else "Sıradaki adım: tezgah satın al, sonra uygun işe teklif ver"
		items.append({"severity": "blue", "text": first_step, "target": "satin"})
		return items
	var risky := risky_jobs()
	if risky > 0:
		items.append({"severity": "red", "text": "%d işte teslim riski var" % risky, "target": "jobs"})
	for row in production_line():
		if float(row["cap"]) > 0.0:
			var share: float = float(row["load"]) / float(row["cap"])
			if share >= 0.85:
				items.append({"severity": "red" if share >= 0.95 else "amber", "text": "%s kapasitesi %%%d dolu" % [row["kind"], int(roundf(share * 100.0))], "target": "capacity"})
	var unordered := 0
	for job in jobs:
		if job.get("order", {}).is_empty():
			unordered += 1
	if unordered > 0:
		items.append({"severity": "amber", "text": "%d işin hammaddesi sipariş edilmedi" % unordered, "target": "jobs"})
	if in_notice_window():
		items.append({"severity": "amber", "text": "Kira sözleşmesi %d ay sonra bitiyor" % months_left, "target": "contract"})
	var unread := unread_mails()
	if unread > 0:
		items.append({"severity": "blue", "text": "%d okunmamış mail" % unread, "target": "mail"})
	if not offers.is_empty():
		items.append({"severity": "blue", "text": "%d teklif bekleyen iş ilanı" % offers.size(), "target": "offers"})
	var order := {"red": 0, "amber": 1, "blue": 2}
	items.sort_custom(func(a, b): return int(order[a["severity"]]) < int(order[b["severity"]]))
	return items

# ---------------------------------------------------------------- closing letter

# After a forced closure the game writes the player a letter: what was visible in advance, said sharply, then a way back.
func _close_factory(status: Dictionary) -> void:
	super._close_factory(status)
	var letter := closing_letter()
	closure["letter"] = letter
	post_mail(letter["title"], letter["lines"], "Alacaklılar adına")

func closing_letter() -> Dictionary:
	var months_played := maxi(1, month)
	var avg_revenue := lifetime_revenue / float(months_played)
	var expense := ordinary_expense()
	var machine_count := machines.size()
	var idle := 0
	var shift_sum := 0.0
	for machine in delivered():
		shift_sum += float(machine["shifts"])
		if float(machine.get("used_last", 0.0)) <= 0.0:
			idle += 1
	var avg_shifts := shift_sum / maxf(1.0, float(delivered().size()))
	var findings: Array = []   # [weight, text]
	if expense > avg_revenue * 1.05:
		findings.append([expense - avg_revenue, "Ayda ortalama %s kazandın, ayda %s harcadın. Bu fark kasadan eridi; bunu bir tablo değil, bir takvim görseydin ilk aydan fark ederdin." % [Data.usd(avg_revenue), Data.usd(expense)]])
	if factory_id != "" and machine_count > 0 and float(factory()["m2"]) / float(machine_count) > 90.0:
		findings.append([float(factory()["m2"]) / float(machine_count), "%d m²'lik yeri %d tezgahla tuttun. Kira ve bina giderleri, işlik dolu olsun boş olsun akar. O alanı dolduracak işi ve sermayeyi hesaba katmadın." % [int(factory()["m2"]), machine_count]])
	if avg_shifts >= 2.0 and jobs.size() <= 2:
		findings.append([avg_shifts * 3.0, "Tezgahları ortalama %s vardiya çalıştırdın ama elinde %d iş vardı. Vardiya ücreti iş olsun olmasın ödenir; kapasite satış değildir." % [str(snappedf(avg_shifts, 0.1)).replace(".", ","), jobs.size()]])
	if idle > 0:
		findings.append([float(idle) * 2.0, "%d tezgahın bu ay hiç iş görmedi. Duran tezgah kendi kendine para kazanmaz." % idle])
	if debt > 0.0 or not loan.is_empty():
		findings.append([debt, "Nakit açığını borçla kapatmaya çalıştın. Faiz, açığı küçültmedi; büyüttü."])
	if delivery_score < 0.7:
		findings.append([(0.7 - delivery_score) * 100.0, "Teslimat skorun %%%d'e düştü. Geç teslim eden fabrikaya müşteri geri gelmez, fiyat pazarlığı da onlardan yana işler." % int(roundf(delivery_score * 100.0))])
	findings.sort_custom(func(a, b): return float(a[0]) > float(b[0]))
	var lines: Array = []
	var type := String(closure.get("type", "forced"))
	lines.append("Sayın operatör,")
	if type == "bankrupt":
		lines.append("Faaliyetin Ay %d itibarıyla sonlandırılmıştır. Tasfiye sonrası %s açık kaldı." % [month, Data.usd(float(closure.get("shortfall", 0.0)))])
	else:
		lines.append("Faaliyetin Ay %d itibarıyla sonlandırılmıştır. Tasfiye borcu kapattı; kayıtlara iflas olarak geçmeyecek." % month)
	var negative_months := 0
	for value in free_history:
		if float(value) < 0.0:
			negative_months += 1
	if negative_months > 0:
		lines.append("Serbest nakit son %d ayın %d tanesinde negatifti. İşaret ekranındaydı; her ay önündeydi." % [free_history.size(), negative_months])
	else:
		lines.append("Rakamlar her ay önündeydi; sorun tek bir ayda değil, birikerek büyüdü.")
	for i in mini(3, findings.size()):
		lines.append("• " + String(findings[i][1]))
	if findings.is_empty():
		lines.append("• Tek tek bakınca büyük bir hata yok; küçük hatalar üst üste bindi. Bazen bir fabrikayı bitiren şey tek bir karar değil, hiç bakılmayan bir aydır.")
	lines.append("Ama şunu da söyleyelim: bu fabrikayı kuran da, batıran da sendin. Bu seni yarı yolda bırakacak bir şey değil; çoğu yönetici ilk fabrikasını böyle öğrenir. Neyi bilmediğini artık biliyorsun.")
	lines.append("Yeniden başlayabilirsin. Önce küçük kur, işin nasıl geldiğini gör, sonra büyü. Kolay gelsin.")
	return {"title": "Faaliyet sonlandırma bildirimi", "lines": lines}
