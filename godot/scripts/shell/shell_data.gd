extends RefCounted

# Mock data and generators for the mobile factory shell. Every number here is
# an illustrative UI input, not balance and not a rule (see docs/ideas/IDEA-015
# and IDEA-016). Money is in game units; 1 unit = $1.000 when displayed.

const MONEY_UNIT_USD := 1000.0

const LEVELS := ["", "Manuel", "CNC", "Hassas"]   # 1 Manuel (0,1 mm), 2 CNC (0,01 mm), 3 Hassas (0,001 mm)
const TYPES := ["Torna", "Freze", "Taşlama", "Dövme"]
const STATS_LIST := ["Zeka", "Dikkat", "Hız", "Güç", "Yaratıcılık", "Sosyallik", "Görünüm"]
# Real-world inputs from the economy sheet (USD; 1 unit = $1.000). Direct operators by machine kind (experienced class),
# indirect staff (internal logistics, cleaning, warehouse) one per INDIRECT_RATIO direct workers, office staff by machine count.
const WAGE_BY_KIND := {"Torna": 1.0, "Freze": 1.1, "Taşlama": 1.3, "Dövme": 1.5}
static var WAGE := 1.1   # average direct wage, used where no machine kind is known
const INDIRECT_RATIO := 4
const INDIRECT_WAGE := 1.0
# Office roles join in this order of importance once the plant has more than three machines.
const OFFICE_ROLES := [
	{"name": "Muhasebe / ofis", "at": 4, "cost": 1.3}, {"name": "Planlama", "at": 7, "cost": 1.5}, {"name": "Kalite", "at": 10, "cost": 1.6},
	{"name": "Satın alma / depo", "at": 13, "cost": 1.6}, {"name": "Üretim şefi", "at": 16, "cost": 2.0}, {"name": "Yönetici", "at": 20, "cost": 2.5}
]
const OFFICE_EXTRA_EVERY := 4   # after the last role: one more office worker per 4 machines
const OFFICE_EXTRA_COST := 1.5
const RENT_PER_M2 := 4.0   # USD per month
const BUILDING_EXTRA_PER_M2 := 4.0   # tax, service charge, heating, security (USD per month)
const TARIFF := 0.13   # USD per kWh
const LOAD_FACTOR := 0.6
const SHIFT_HOURS_MONTH := 160.0
const CONSUMABLE_SHARE := 0.035   # consumables as a share of production cost
# Steel (units = $1.000 per ton), parts' weights and the raw bar needed per finished kilo.
const STEEL_PRICE := {1: 0.6, 2: 1.0, 3: 1.0}
const PART_WEIGHT := {"Torna": [1.0, 8.0], "Freze": [3.0, 20.0], "Taşlama": [0.5, 5.0], "Dövme": [5.0, 40.0]}
const RAW_FACTOR := {"Torna": 1.6, "Freze": 2.0, "Taşlama": 1.2, "Dövme": 1.4}

static func wage_for(kind: String) -> float:
	return float(WAGE_BY_KIND.get(kind, WAGE))

# ---------------------------------------------------------------- factories

# Rentable buildings: width x length x height (m) from the art table; the image id is
# factory_<n>. Rent is RENT_PER_M2 times the area, +1% per metre of height over 8 m.
const FACTORY_SIZES := [
	[10, 15, 8], [15, 15, 10], [15, 20, 8], [20, 20, 10], [15, 35, 10], [20, 30, 10], [20, 40, 10],
	[20, 50, 12], [30, 50, 15], [40, 50, 15], [50, 50, 15], [50, 60, 15], [50, 70, 15]
]
const FACTORY_NAMES := ["Cedar Lane Workshop", "Maple Street Unit", "Riverside Works", "Oakridge Shop", "Harbor Point Hall", "Millbrook Bay Plant",
	"Granite Yard Factory", "Northfield Plant", "Iron Valley Hangar", "Stonebridge Mill", "Eastport Works", "Lakeshore Industrial", "Summit Ridge Complex"]
const FACTORY_REGIONS := ["Riverside District", "Maple Heights", "Old Harbor", "Oakridge", "Harbor Point", "Millbrook Bay", "Granite Yard",
	"Northfield", "Iron Valley", "Stonebridge", "Eastport", "Lakeshore", "Summit Ridge"]
const FACTORY_AGES := [34, 28, 22, 18, 25, 12, 15, 9, 6, 20, 14, 8, 4]
static var FACTORIES: Array = _build_factories()

# Floor plans (art/floor/plans/<stem>.jpg): one yellow slot per machine, slot rectangles in slots.json as fractions of the picture.
const PLAN_STEMS := ["fabrika_15x10", "fabrika_15x15", "fabrika_15x20", "fabrika_20x20", "fabrika_15x35", "fabrika_30x20", "fabrika_40x20",
	"fabrika_50x20", "fabrika_50x30", "fabrika_50x40", "fabrika_50x50", "fabrika_50x60", "fabrika_50x70"]
const PLAN_SLOTS := [2, 3, 4, 6, 6, 8, 12, 16, 24, 30, 36, 42, 54]
static var _plan_json: Dictionary = {}

static func plan_index(factory_id: String) -> int:
	return clampi(int(factory_id.trim_prefix("factory_")) - 1, 0, PLAN_STEMS.size() - 1)

static func plan_stem(factory_id: String) -> String:
	return PLAN_STEMS[plan_index(factory_id)]

static func slot_count(factory_id: String) -> int:
	return PLAN_SLOTS[plan_index(factory_id)]

static func _plan_data() -> Dictionary:
	if _plan_json.is_empty():
		var file := FileAccess.open("res://art/floor/plans/slots.json", FileAccess.READ)
		if file != null:
			var parsed = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				_plan_json = parsed
	return _plan_json

# Doors of the plan as [edge, from, to] (fractions along that wall).
static func plan_doors(factory_id: String) -> Array:
	return _plan_data().get("doors", {}).get(plan_stem(factory_id), [])

# Picture size in pixels the slot fractions were measured on (the drawing keeps the same aspect).
static func plan_size(factory_id: String) -> Vector2:
	var size: Array = _plan_data().get(plan_stem(factory_id) + "_size", [1000, 1000])
	return Vector2(float(size[0]), float(size[1]))

# Slot rectangles of the factory's plan as [x, y, w, h] fractions (empty when the file is missing).
static func plan_slots(factory_id: String) -> Array:
	if _plan_json.is_empty():
		var file := FileAccess.open("res://art/floor/plans/slots.json", FileAccess.READ)
		if file != null:
			var parsed = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				_plan_json = parsed
	return _plan_json.get(plan_stem(factory_id), [])

static func _build_factories() -> Array:
	var list: Array = []
	for i in FACTORY_SIZES.size():
		var width: int = FACTORY_SIZES[i][0]
		var length: int = FACTORY_SIZES[i][1]
		var height: int = FACTORY_SIZES[i][2]
		var area := width * length
		var rent := RENT_PER_M2 * float(area) / 1000.0 * (1.0 + 0.01 * float(height - 8))
		var tint := Color.from_hsv(0.58 + 0.03 * float(i % 4), 0.25, 0.28 + 0.01 * float(i))
		list.append({"id": "factory_%d" % (i + 1), "name": FACTORY_NAMES[i], "region": FACTORY_REGIONS[i], "m2": area, "width": width, "length": length,
			"height": float(height), "rent": snappedf(rent, 0.05), "age": FACTORY_AGES[i],
			"floor": "Takviyeli beton" if area >= 500 else "Beton, hafif yük", "ramps": clampi(int(roundf(float(area) / 500.0)) + 1, 1, 6),
			"kva": int(float(area) * 1.2), "tint": tint})
	return list

const TERMS := [
	{"months": 6, "factor": 1.10, "prepay_discount": 0.05},
	{"months": 12, "factor": 1.00, "prepay_discount": 0.08},
	{"months": 24, "factor": 0.90, "prepay_discount": 0.12}
]
# Big jobs ask for a track record (measured on the job's load, ω): the biggest quarter of the listings needs 2 finished jobs
# and a 70 % delivery score, the biggest tenth 4 jobs and 80 %.
const JOB_TIERS := [{"load": 11000.0, "jobs": 4, "score": 0.80}, {"load": 6000.0, "jobs": 2, "score": 0.70}]
const PROGRESS_SHARE := 0.8   # progress payment: at every month end 80 % of the work done so far is paid; the rest comes with the final delivery
const MONTH_DAYS := 30   # a month is 30 days in the day-by-day engine
const IDLE_WAGE_FLOOR := 0.5   # share of a crew's wage still paid on a day the machine has no work (short-time work)
const FASON_SHARE := 0.25   # share of the listings that are toll work (customer supplies the material)
const EXIT_FEE_RENTS := 2
const RENEWAL_MARKUP := 0.12   # market rent: an unanswered contract renews with this rise
const NOTICE_MONTHS := 2   # the landlord writes this many months before the contract ends
const MOVE_COST_PER_MACHINE := 1.0   # k$: dismantling, transport and set-up of one machine
const MOVE_MONTHS := 1   # production stands still at most one month, however many machines move
const ABANDON_PENALTY := 0.10  # of the job revenue; paid material is lost (mock)
const SALE_RATE := 0.80  # quick sale: 20 percent under the market value (FRZ-003 v2)

# ---------------------------------------------------------------- machines

# New-machine price (units) of the mid level (Hassas) by type; the level multiplier gives Standart and Nitelikli.
const TYPE_PRICE := {"Torna": 75.0, "Freze": 90.0, "Taşlama": 110.0, "Dövme": 150.0}   # Hassas (mid level) new price
const LEVEL_MULT := {1: 0.60, 2: 1.00, 3: 2.40}
const BRANDS := {1: ["Brandt", "Halden"], 2: ["Novak Precision", "Meridian"], 3: ["Aurex", "Kessler"]}
const MODEL_PREFIX := {"Torna": "T", "Freze": "F", "Taşlama": "G", "Dövme": "P"}
const NAMEPLATE := {"Torna": 2000, "Freze": 1600, "Taşlama": 1200, "Dövme": 800}  # x per month at 3 shifts (IDEA-018)
const LEVEL_PERF := {1: 1.0, 2: 1.0, 3: 1.0}   # capacity now comes from power and condition only
# Machine model: power (index, kW) sets capacity and electricity; condition (40-100 %, ages 10 points a year)
# changes capacity, energy, maintenance and scrap; precision decides which jobs the machine may take.
const BOOST_MAX := 25        # machine speed-up, percent
const BOOST_SCRAP := 2.4     # scrap rises 2.4x as fast as the speed-up: +25% speed = scrap x1.6
const BOOST_MAINT := 2.4     # maintenance likewise
const BOOST_ENERGY := 1.6    # energy: +25% speed = x1.4
const SPEED_CAP := 1.35      # machine speed-up and tolerance slack together never exceed +35%
const SLACK_MIN := 0.1       # below this slack no choice is offered
const SLACK_SPEED := 0.25   # best case +25% output
const SLACK_SCRAP := 0.50   # best case -50% scrap
const PRECISION_MM := {1: 0.1, 2: 0.01, 3: 0.001}
const TOLERANCE_CHOICES := {1: [0.5, 0.3, 0.2, 0.1], 2: [0.08, 0.05, 0.03, 0.02], 3: [0.008, 0.005, 0.003, 0.002]}
const POWER_RANGE := {1: [1.3, 1.9], 2: [1.8, 2.2], 3: [1.6, 2.0]}
const KW_CAPACITY := 1500.0   # ω per month at three shifts, per kW
const ENERGY_PER_KW := 0.075   # k$ per month and kW (one shift)
const KIND_CAPACITY_FACTOR := {"Torna": 1.0, "Freze": 0.8, "Taşlama": 0.6, "Dövme": 0.4}   # placeholder until the capacity tables arrive
const CONDITION_MIN := 40.0
const AGING_PER_MONTH := 10.0 / 12.0
const CAPACITY_STEP_LOSS := 0.05      # per missing 10 points
const ENERGY_STEP_RANGE := [0.05, 0.10]
const SCRAP_STEP_RANGE := [0.05, 0.15]   # relative increase per missing 10 points
const MAINT_STEP_PCT := {1: 0.007, 2: 0.010, 3: 0.012}   # of the price paid, per missing 10 points and month
const TYPICAL_CONDITION_STEPS := 2.0   # what customers assume about an ordinary shop

static func condition_steps(condition: float) -> float:
	return (100.0 - condition) / 10.0

# Price of a machine relative to a new one: 30 % at condition 40, 100 % at 100.
static func condition_price_factor(condition: float) -> float:
	return 0.30 + 0.70 * (clampf(condition, CONDITION_MIN, 100.0) - CONDITION_MIN) / (100.0 - CONDITION_MIN)

static func capacity_for(kind: String, power: float, condition: float) -> float:
	return power * KW_CAPACITY * float(KIND_CAPACITY_FACTOR[kind]) * (1.0 - CAPACITY_STEP_LOSS * condition_steps(condition))

static func level_needed_text(level: int) -> String:
	return ["", "herhangi bir tezgâh", "CNC veya Hassas", "Hassas"][level]

static func tolerance_text(mm: float) -> String:
	return ("%s mm" % str(mm)).replace(".", ",")

const SCRAP_BASE := {"Torna": 0.03, "Freze": 0.04, "Taşlama": 0.06, "Dövme": 0.09}  # Standart level
const SCRAP_LEVEL_DELTA := {1: 0.0, 2: -0.005, 3: -0.01}
const SCRAP_FLOOR := 0.02
# Job scrap range by the machine kind and level the job needs (share of the material). The estimate uses the
# middle of the range; the real value is drawn inside it when the job is accepted. Placeholder numbers.
const SCRAP_RANGE := {
	"Torna": {1: [0.01, 0.04], 2: [0.05, 0.08], 3: [0.08, 0.12]},
	"Freze": {1: [0.01, 0.05], 2: [0.06, 0.12], 3: [0.12, 0.16]},
	"Taşlama": {1: [0.01, 0.06], 2: [0.07, 0.14], 3: [0.15, 0.20]},
	"Dövme": {1: [0.08, 0.15], 2: [0.16, 0.24], 3: [0.25, 0.35]}
}
const LEVEL_LETTER := {1: "A", 2: "B", 3: "C"}  # engine machine class (BossState legacy key)
const LEVEL_AREA := {1: 25.0, 2: 30.0, 3: 40.0}
const TYPE_AREA := {"Torna": 1.0, "Freze": 1.2, "Taşlama": 1.1, "Dövme": 2.2}
const LEVEL_HEIGHT := {1: 3.0, 2: 3.5, 3: 4.5}
const TYPE_HEIGHT := {"Torna": 0.0, "Freze": 0.3, "Taşlama": 0.0, "Dövme": 1.5}
const NEW_DELIVERY := {1: 1, 2: 2, 3: 3}  # months; second hand arrives in 1
const AGE_DROP := 0.07
const AGE_FLOOR := 0.35


static func age_factor(age: float) -> float:
	return maxf(AGE_FLOOR, 1.0 - AGE_DROP * age)

static func maintenance_risk(age: int) -> String:
	if age <= 2:
		return "Düşük"
	if age <= 4:
		return "Orta"
	return "Yüksek"

static func personnel_for(type: String, level: int) -> int:
	return 1   # every machine runs with one operator

# Monthly electricity of a machine for one shift (160 h, average load).
static func energy_month(power: float) -> float:
	return snappedf(power * ENERGY_PER_KW, 0.001)

static func list_price(type: String, level: int) -> float:
	return roundf(TYPE_PRICE[type] * LEVEL_MULT[level])

# Deterministic marketplace: 12 new models plus 8 second-hand units, some discounted.
static func machine_listings() -> Array:
	var listings: Array = []
	var uid := 0
	for type in TYPES:
		for level in [1, 2, 3]:
			listings.append(_listing(uid, type, level, 100.0, 0.15 if uid % 5 == 2 else 0.0))
			uid += 1
	var used := [
		["Torna", 1, 40.0, 0.10], ["Torna", 2, 70.0, 0.0], ["Freze", 1, 40.0, 0.10], ["Freze", 3, 80.0, 0.0],
		["Taşlama", 2, 60.0, 0.10], ["Taşlama", 1, 40.0, 0.10], ["Dövme", 1, 40.0, 0.0], ["Dövme", 2, 60.0, 0.10]
	]
	for entry in used:
		listings.append(_listing(uid, entry[0], entry[1], entry[2], entry[3]))
		uid += 1
	return listings

static func _listing(uid: int, type: String, level: int, condition: float, discount: float) -> Dictionary:
	var list: float = list_price(type, level)
	var base: float = roundf(list * condition_price_factor(condition))
	var brand: String = BRANDS[level][uid % 2]
	var area := roundf(float(LEVEL_AREA[level]) * float(TYPE_AREA[type]))
	var roll := RandomNumberGenerator.new()
	roll.seed = 4421 + uid * 97
	var span: Array = POWER_RANGE[level]
	var power := snappedf(roll.randf_range(float(span[0]), float(span[1])), 0.1)
	var nameplate := capacity_for(type, power, condition)
	var steps := condition_steps(condition)
	return {
		"uid": uid, "kind": type, "type": LEVEL_LETTER[level], "level": level, "brand": brand,
		"model": "%s %s-%d" % [brand, MODEL_PREFIX[type], 100 + level * 100 + uid],
		"condition": condition, "age": int(roundf(steps)), "list_price": list, "base_price": base, "discount": discount,
		"price": roundf(base * (1.0 - discount)),
		"power": power, "precision": PRECISION_MM[level],
		"capacity": int(nameplate), "nameplate": nameplate, "base_nameplate": power * KW_CAPACITY * float(KIND_CAPACITY_FACTOR[type]), "perf": float(LEVEL_PERF[level]),
		"scrap": maxf(SCRAP_FLOOR, float(SCRAP_BASE[type]) + float(SCRAP_LEVEL_DELTA[level])),
		"area": area, "height": snappedf(float(LEVEL_HEIGHT[level]) + float(TYPE_HEIGHT[type]), 0.1),
		"personnel": personnel_for(type, level),
		"kw": power, "energy": snappedf(power * ENERGY_PER_KW, 0.001), "consumables": 0.0,
		"roll_e": 0.5, "roll_m": 0.5, "roll_s": 0.5,
		"delivery": 1 if condition < 100.0 else int(NEW_DELIVERY[level])
	}

# ---------------------------------------------------------------- equipment

# Required equipment set per factory size class; optional items are bought singly.
const PACKAGE_CLASSES := {
	"small": {"transpalet": 1, "kasa": 10, "raf": 4, "el_aleti": 2, "takim": 5},
	"medium": {"transpalet": 2, "kasa": 16, "raf": 7, "el_aleti": 3, "takim": 8},
	"large": {"transpalet": 4, "kasa": 30, "raf": 14, "el_aleti": 6, "takim": 15}
}
const EQUIPMENT := {
	"transpalet": {"name": "Transpalet", "price": 0.45, "area": 0.0, "required": true, "note": "Kasa ve palet taşıma"},
	"kasa": {"name": "Malzeme kasası", "price": 0.025, "area": 0.3, "required": true, "note": "Hammadde ve yarı mamul"},
	"raf": {"name": "Depo rafı", "price": 0.35, "area": 3.0, "required": true, "note": "Depolama alanı tüketir"},
	"el_aleti": {"name": "El aletleri seti", "price": 0.5, "area": 1.0, "required": true, "note": "Bakım ve ayar"},
	"takim": {"name": "Takım ve fikstür seti", "price": 0.3, "area": 1.0, "required": true, "note": "Tezgah bağlama takımları"},
	"forklift": {"name": "Forklift", "price": 15.0, "area": 0.0, "required": false, "note": "Depo & Sevkiyat sorun ihtimalini azaltır; OEE'ye yansır (test)"},
	"olcum": {"name": "Kalite ölçüm seti", "price": 8.0, "area": 1.5, "required": false, "note": "Kalite sorun ihtimalini azaltır (test)"},
	"vinc": {"name": "Köprü vinç", "price": 40.0, "area": 0.0, "required": false, "min_height": 5.0, "note": "Ağır parçalar; en az 5,0 m tavan gerekir (test)"}
}
const OPTIONAL_ORDER := ["forklift", "olcum", "vinc", "transpalet", "kasa", "raf"]

static func size_class(m2: int) -> String:
	if m2 >= 1500:
		return "large"
	if m2 >= 500:
		return "medium"
	return "small"

static func package_for(m2: int) -> Dictionary:
	var items: Dictionary = PACKAGE_CLASSES[size_class(m2)]
	var price := 0.0
	var area := 0.0
	for id in items:
		price += float(EQUIPMENT[id]["price"]) * int(items[id])
		area += float(EQUIPMENT[id]["area"]) * int(items[id])
	return {"items": items, "price": snappedf(price, 0.001), "area": area}

# ---------------------------------------------------------------- credit

const CREDIT := {"bank": "Hartwell Credit Bank", "amount": 40.0, "rate": 0.015, "months": 12, "collateral": 1.25, "early_fee": 0.02}

static func installment(amount: float, rate: float, months: int) -> float:
	return amount * rate / (1.0 - pow(1.0 + rate, -months))

# ---------------------------------------------------------------- jobs

const CUSTOMERS := ["Ridgeway Motors", "Northgate Hydraulics", "Bluewater Marine", "Ironbridge Rail", "Summit Agri", "Carlisle Pumps", "Redfield Auto", "Halvorsen Gear"]
const TITLES := {
	"Torna": ["Mil ve şaft serisi", "Burç ve manşon partisi", "Flanş bağlantı seti"],
	"Freze": ["Gövde işleme partisi", "Kalıp plakası", "Dişli kutusu kapağı"],
	"Taşlama": ["Hassas rulman yatağı", "Piston taşlama serisi", "Valf yuvası"],
	"Dövme": ["Krank mili dövme", "Flanş dövme partisi", "Aks dövme serisi"]
}
static var price_per_x := 0.0135  # units (k$) per ω for a Torna; other kinds scale with machine price and nameplate (used for the capacity-value estimate)
static var revenue_scale := 1.0  # calibration input for simulations (not a rule)
static var rent_scale := 1.0  # kept at 1.0; rents in FACTORIES are already the calibrated values
static var start_cash := 30.0   # five years of saving $400 a month as an operator, plus a little family help
# Suppliers (foreign names). price = factor on the job's material estimate; lead = months until
# the material arrives; terms = months after ordering until payment is due; delay = chance of +1 month;
# quality 1..3 changes the job's yield (scrap): 1 Ekonomik, 2 Standart, 3 Premium.
const SUPPLIERS := [
	{"id": "nord", "name": "Nordhaus Steel", "price": 0.95, "lead": 1, "terms": 1, "delay": 0.10, "quality": 2, "note": "Dengeli: 30 gün vade, 1 ay sonra teslim"},
	{"id": "atlas", "name": "Atlas Premium", "price": 1.10, "lead": 0, "terms": 0, "delay": 0.05, "quality": 3, "note": "Hemen teslim, pahalı, peşin, yüksek kalite"},
	{"id": "spot", "name": "Spot Alloy", "price": 0.90, "lead": 0, "terms": 0, "delay": 0.35, "quality": 1, "note": "Hemen teslim, ucuz ama güvensiz, peşin"},
	{"id": "pacific", "name": "Pacific Alloy", "price": 0.85, "lead": 2, "terms": 2, "delay": 0.12, "quality": 1, "note": "2 ay sonra teslim, ucuz, uzun vadeli"},
	{"id": "midland", "name": "Midland Metals", "price": 1.00, "lead": 1, "terms": 1, "delay": 0.12, "quality": 2, "note": "Liste fiyatı, 30 gün vade"}
]

# Supplier score shown to the player: how reliably the material arrives on its day.
static func supplier_score(supplier: Dictionary) -> int:
	return int(roundf((1.0 - float(supplier["delay"])) * 100.0))

static func lead_text(lead: int) -> String:
	return "Hemen teslim" if lead <= 0 else "%d ay sonra teslim" % lead

# Staff benefits (IDEA-018 personnel): level 0 = none, V1..V3. Cost is per head per month, k$ at V1, scaled by
# the V1/V2/V3 multipliers; "bonus" is the share of person-related problems prevented before they start.
# The first four are mandatory (at least V1). A higher level anywhere needs every benefit one level higher first.
const BENEFITS := [
	{"id": "yol", "name": "Yol", "cost": 0.030, "bonus": 0.015, "mult": [1.0, 1.0, 1.0], "effect": [1.0, 1.0, 1.0], "mandatory": true},
	{"id": "yemek", "name": "Yemek", "cost": 0.045, "bonus": 0.025, "mult": [1.0, 1.4, 1.9], "effect": [1.0, 1.5, 2.0], "mandatory": true},
	{"id": "sigorta", "name": "Sigorta", "cost": 0.045, "bonus": 0.030, "mult": [1.0, 1.6, 2.2], "effect": [1.0, 1.5, 2.0], "mandatory": true},
	{"id": "izin", "name": "Yıllık İzin", "cost": 0.030, "bonus": 0.030, "mult": [1.0, 1.2, 1.6], "effect": [1.0, 1.5, 2.0], "mandatory": true},
	{"id": "ikramiye", "name": "İkramiye", "cost": 0.040, "bonus": 0.030, "mult": [1.0, 1.5, 2.0], "effect": [1.0, 1.5, 2.0], "mandatory": false},
	{"id": "egitim", "name": "Eğitim", "cost": 0.030, "bonus": 0.025, "mult": [1.0, 1.3, 1.8], "effect": [1.0, 1.5, 2.0], "mandatory": false},
	{"id": "sosyal", "name": "Sosyal Etkinlik", "cost": 0.020, "bonus": 0.015, "mult": [1.0, 1.2, 1.8], "effect": [1.0, 1.5, 2.0], "mandatory": false},
	{"id": "aile", "name": "Aile Desteği", "cost": 0.025, "bonus": 0.020, "mult": [1.0, 1.3, 1.8], "effect": [1.0, 1.5, 2.0], "mandatory": false}
]
const BENEFIT_BONUS_CAP := 0.40
static func default_benefits() -> Array:
	return [1, 1, 1, 1, 0, 0, 0, 0]

static func benefit_cost_of(levels: Array) -> float:
	var total := 0.0
	for i in BENEFITS.size():
		var level := int(levels[i])
		if level > 0:
			total += float(BENEFITS[i]["cost"]) * float(BENEFITS[i]["mult"][level - 1])
	return total

static func benefit_bonus_of(levels: Array) -> float:
	var total := 0.0
	for i in BENEFITS.size():
		var level := int(levels[i])
		if level > 0:
			total += float(BENEFITS[i]["bonus"]) * float(BENEFITS[i]["effect"][level - 1])
	return minf(total, BENEFIT_BONUS_CAP)
# Customer contacts: every company has three people with a fixed face (art/contacts/<id>.png), name and role,
# so the player learns to recognise who writes from the photo.
const CONTACT_PEOPLE := {
	"Ridgeway Motors": [{"id": "p04", "name": "Marco Bellini", "role": "Satın Alma Müdürü"}, {"id": "p13", "name": "Rosa Delgado", "role": "Kalite Müdürü"}, {"id": "p18", "name": "Richard Voss", "role": "Üretim Planlama"}],
	"Northgate Hydraulics": [{"id": "p02", "name": "Gordon Hale", "role": "Genel Müdür"}, {"id": "p06", "name": "Amara Okafor", "role": "Satın Alma Uzmanı"}, {"id": "p21", "name": "Lucia Moreau", "role": "Kalite Müdürü"}],
	"Bluewater Marine": [{"id": "p03", "name": "Sophie Lindqvist", "role": "Satın Alma Müdürü"}, {"id": "p12", "name": "Isaac Mensah", "role": "Üretim Planlama"}, {"id": "p15", "name": "Edmund Thorne", "role": "Genel Müdür"}],
	"Ironbridge Rail": [{"id": "p05", "name": "Walter Kessler", "role": "Genel Müdür"}, {"id": "p09", "name": "Fiona McAllister", "role": "Satın Alma Müdürü"}, {"id": "p24", "name": "Samuel Boateng", "role": "Üretim Planlama"}],
	"Summit Agri": [{"id": "p07", "name": "Ingrid Solberg", "role": "Satın Alma Müdürü"}, {"id": "p10", "name": "Daniel Wu", "role": "Satın Alma Uzmanı"}, {"id": "p22", "name": "Ben Carter", "role": "Üretim Planlama"}],
	"Carlisle Pumps": [{"id": "p01", "name": "Elena Marlowe", "role": "Satın Alma Müdürü"}, {"id": "p14", "name": "Arjun Mehta", "role": "Kalite Uzmanı"}, {"id": "p20", "name": "Beatrice Okoye", "role": "Genel Müdür"}],
	"Redfield Auto": [{"id": "p08", "name": "Karim Haddad", "role": "Satın Alma Müdürü"}, {"id": "p17", "name": "Hana Kobayashi", "role": "Kalite Müdürü"}, {"id": "p19", "name": "Alex Rowan", "role": "Üretim Planlama"}],
	"Halvorsen Gear": [{"id": "p11", "name": "Margaret Doyle", "role": "Genel Müdür"}, {"id": "p16", "name": "Naomi Adeyemi", "role": "Satın Alma Müdürü"}, {"id": "p23", "name": "Hiroshi Nakamura", "role": "Üretim Planlama"}]
}

# Hidden urgency (1-10) leaks through one small signal only: how many reminders the customer has sent about the job.
static func urgency_noisy(offer: Dictionary) -> int:
	return clampi(int(offer["urgency"]) + (int(offer["id"]) % 3) - 1, 1, 10)

# Number of mails the customer has sent about this job when it answers a quote (1 = relaxed, 4 = pressing); every
# revision round adds one.
static func mail_count(offer: Dictionary, round: int) -> int:
	return 1 + int(floor(float(urgency_noisy(offer) - 1) / 3.0)) + (round - 1)

static func offer_load(offer: Dictionary) -> float:
	var total := 0.0
	for req in offer.get("reqs", []):
		total += float(req["workload"])
	return total

# The track record a listing asks for: {} when it is open to everyone.
static func job_gate(offer: Dictionary) -> Dictionary:
	var load := offer_load(offer)
	for tier in JOB_TIERS:
		if load >= float(tier["load"]):
			return tier
	return {}

static func contact_info(offer: Dictionary) -> Dictionary:
	var people: Array = CONTACT_PEOPLE.get(String(offer.get("customer", "")), [])
	if people.is_empty():
		return {"id": "", "name": "", "role": ""}
	return people[int(offer["id"]) % people.size()]

static func contact_of(offer: Dictionary) -> String:
	return String(contact_info(offer)["name"])

# Portrait id of a contact by name (mails saved before the portraits existed).
static func contact_photo_of(name: String) -> String:
	for company in CONTACT_PEOPLE:
		for person in CONTACT_PEOPLE[company]:
			if person["name"] == name:
				return String(person["id"])
	return ""

const STEEL_GRADE := {1: "HR42", 2: "42CrMo4", 3: "42CrMo4"}

const QUALITY_NAMES := ["", "Ekonomik", "Standart", "Premium"]
const QUALITY_YIELD := {1: 0.96, 2: 1.0, 3: 1.015}
static var typical_overhead := 0.45   # customers' belief of plant overhead per machine-month (rent, building, office), k$
static var mid_base := 0.40   # customer reference margin over the typical cost of a plain job (covers capital return and overhead)
static var mid_slope := 0.30  # extra margin of the most complex job
static var margin_scale := 1.0   # calibration input: scales the customer margin band
const ADVANCE_RATE := 0.30  # customer advance on acceptance (proposal; fixed in the first slice)

static func supplier_by_id(id: String) -> Dictionary:
	for supplier in SUPPLIERS:
		if supplier["id"] == id:
			return supplier
	return SUPPLIERS[0]

const OFFER_MIX := [4, 4, 3, 3, 3, 3, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1]  # 2×4, 4×3, 5×2, 9×1 machines

static func cost_share(count: int, best_level: int, jitter: float) -> float:
	var score := 0.5 * float(count - 1) / 3.0 + 0.5 * float(best_level - 1) / 2.0
	return clampf(0.75 - 0.45 * score + jitter, 0.30, 0.75)

# Good x per month of one Standart machine on one shift (reference size for jobs).
static func ref_output(kind: String) -> float:
	return capacity_for(kind, 1.6, 100.0) / 3.0 * (1.0 - float(SCRAP_BASE[kind]))

static func price_x(kind: String) -> float:
	return price_per_x * revenue_scale * float(TYPE_PRICE[kind]) / 80.0 * 2000.0 / float(NAMEPLATE[kind])

const DIFFICULTY_SYMBOL := "ω"   # Parça İşleme Katsayısı: higher = harder part
# Staff care (meals, shuttle, ...): monthly cost per head and the extra chance that a people-related
# problem is prevented before it starts. Placeholder numbers.
const STAFF_POLICIES := [
	{"name": "Yok", "cost": 0.0, "bonus": 0.0, "note": "Gider yok; kimse korunmaz."},
	{"name": "Standart", "cost": 0.15, "bonus": 0.10, "note": "Yemek ve servis."},
	{"name": "İyi", "cost": 0.3, "bonus": 0.20, "note": "Yemek, servis, sağlık ve prim."}
]
const MACHINE_AREA_SHARE := 0.51   # machines (listing area) may cover at most this share of the plant
const AMORT_MONTHS := 240   # straight-line machine write-off over 20 years; accounting cost, not cash
const OT_HOURS_SHARE := 0.5   # overtime adds 4 h to an 8 h shift
const OT_WAGE_MULT := 1.5     # overtime hours cost 1.5x the hourly wage

static func mu_text(value: float) -> String:
	return "%s %s" % [DIFFICULTY_SYMBOL, str(value).trim_suffix(".0")]

static func scrap_range(kind: String, level: int) -> Array:
	return SCRAP_RANGE[kind][level]

# Where inside the range the drawn scrap lands: a Premium supplier pushes it to the lower half,
# an Ekonomik one to the upper half (quality 1..3).
const SCRAP_POSITION := {1: 0.75, 2: 0.5, 3: 0.25}

static func scrap_at(kind: String, level: int, position: float) -> float:
	var span: Array = SCRAP_RANGE[kind][level]
	return lerpf(float(span[0]), float(span[1]), clampf(position, 0.0, 1.0))

# Expected job scrap for a supplier quality.
static func scrap_rate(kind: String, level: int, quality := 2) -> float:
	return scrap_at(kind, level, float(SCRAP_POSITION[quality]))

# A raw draw u in 0..1 becomes a position that leans with the supplier quality.
static func scrap_position(u: float, quality: int) -> float:
	return clampf(u * 0.5 + float(SCRAP_POSITION[quality]) - 0.25, 0.0, 1.0)

static func difficulty(level: int, rng: RandomNumberGenerator) -> float:
	var pool := {1: [1.0, 1.5], 2: [1.5, 2.0], 3: [2.0, 2.5]}
	return float(pool[level][rng.randi_range(0, 1)])

# Typical cost of one machine-month of this kind/level in an ordinary shop (what customers believe it costs):
# direct crew with its share of indirect staff, electricity, write-off and plant overhead, k$.
static func typical_machine_month(kind: String, level: int) -> Dictionary:
	var list: float = list_price(kind, level)
	var span: Array = POWER_RANGE[level]
	var power := (float(span[0]) + float(span[1])) / 2.0
	var crew := float(personnel_for(kind, level))
	var labor := (wage_for(kind) + INDIRECT_WAGE / float(INDIRECT_RATIO)) * crew
	var energy := energy_month(power) * (1.0 + TYPICAL_CONDITION_STEPS * 0.075)
	var maintenance := TYPICAL_CONDITION_STEPS * float(MAINT_STEP_PCT[level]) * list * 0.7
	return {"labor": labor, "energy": energy + maintenance, "amort": list / float(AMORT_MONTHS), "overhead": typical_overhead}

# Builds (or rebuilds) an offer's requirements and money from a spec:
# specs = [{"kind", "level", "n"}], n = machine-equivalents of one-shift demand.
# Material comes from tonnage (parts x weight x raw bar per finished kilo x steel price); the customer's cost
# belief adds scrap, the typical machine-month cost and consumables; the reference price is that cost plus a margin.
static func fill_offer(offer: Dictionary, specs: Array, rng: RandomNumberGenerator) -> void:
	var total_n := 0
	var best := 1
	var reqs: Array = []
	var material := 0.0
	var cost := 0.0
	for spec in specs:
		var level: int = spec["level"]
		var kind: String = spec["kind"]
		var utilisation := rng.randf_range(0.55, 1.15)
		var load_x: float = float(spec["n"]) * ref_output(kind) * utilisation * float(offer["duration"])
		if spec.has("load"):
			load_x = float(spec["load"])   # a local order sized to the plant's own capacity
		var z := difficulty(level, rng)
		var parts := maxi(10, int(roundf(load_x / z / 10.0)) * 10)
		var workload := float(parts) * z
		var tol_choices: Array = TOLERANCE_CHOICES[level]
		var tolerance: float = float(tol_choices[rng.randi_range(0, tol_choices.size() - 1)])
		var span: Array = PART_WEIGHT[kind]
		var weight := snappedf(rng.randf_range(float(span[0]), float(span[1])), 0.5)
		var tons := float(parts) * weight * float(RAW_FACTOR[kind]) / 1000.0
		var material_part := 0.0 if bool(offer.get("fason", false)) else tons * float(STEEL_PRICE[level])   # toll work: the customer supplies the steel
		var months := float(spec["n"]) * float(offer["duration"])
		var machine := typical_machine_month(kind, level)
		var running := months * (float(machine["labor"]) + float(machine["energy"]) + float(machine["amort"]) + float(machine["overhead"]))
		var consumables := CONSUMABLE_SHARE * (material_part + months * (float(machine["labor"]) + float(machine["energy"])))
		cost += material_part * (1.0 + scrap_rate(kind, level)) + running + consumables   # toll work carries no material and no scrap on it
		material += material_part
		reqs.append({"kind": kind, "level": level, "count": int(spec["n"]), "parts": parts, "difficulty": z, "workload": workload, "remaining": workload,
			"weight": weight, "tons": tons, "steel": level, "material_part": material_part, "tolerance": tolerance})
		total_n += int(spec["n"])
		best = maxi(best, level)
	# Margin grows with complexity (machines needed and level): a plain one-machine Standart job pays the
	# smallest margin, a four-machine Nitelikli job the largest.
	var complexity := 0.5 * float(total_n - 1) / 3.0 + 0.5 * float(best - 1) / 2.0
	var mid := (mid_base + mid_slope * complexity) * margin_scale
	var cost_ref := cost * rng.randf_range(0.95, 1.05) * revenue_scale
	var revenue := roundf(cost_ref * (1.0 + mid) * 1000.0) / 1000.0
	offer["reqs"] = reqs
	offer["count"] = total_n
	offer["best"] = best
	offer["revenue"] = revenue
	offer["mid"] = mid
	offer["cost_ref"] = cost_ref
	offer["material"] = snappedf(material, 0.001)
	offer["share"] = material / maxf(0.001, revenue)
	offer["title"] = TITLES[specs[0]["kind"]][rng.randi_range(0, 2)]

static func generate_offers(month: int, salt := 0) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7919 * month + 13 + 104729 * salt
	var mix: Array = OFFER_MIX.duplicate()
	for i in range(mix.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap = mix[i]
		mix[i] = mix[j]
		mix[j] = swap
	var offers: Array = []
	for i in mix.size():
		var count: int = mix[i]
		var primary: String = TYPES[rng.randi_range(0, TYPES.size() - 1)]
		var specs: Array = []
		if count >= 2 and rng.randf() < 0.45:
			var secondary: String = TYPES[(TYPES.find(primary) + rng.randi_range(1, 3)) % 4]
			var first := int(ceil(count / 2.0))
			specs.append({"kind": primary, "level": _level(rng), "n": first})
			specs.append({"kind": secondary, "level": _level(rng), "n": count - first})
		else:
			specs.append({"kind": primary, "level": _level(rng), "n": count})
		var duration := mini(rng.randi_range(count, 3 * count) if count > 1 else rng.randi_range(1, 3), 10)
		var delay := 0   # the customer does not wait for machines in transit; the earliest start is shown instead
		var offer := {"id": month * 100 + i, "customer": CUSTOMERS[rng.randi_range(0, CUSTOMERS.size() - 1)], "duration": duration,
			"start_delay": delay, "months": delay + duration + rng.randi_range(1, 2), "urgency": rng.randi_range(1, 10),
			"fason": rng.randf() < FASON_SHARE}
		fill_offer(offer, specs, rng)
		offers.append(offer)
	return offers

static func _level(rng: RandomNumberGenerator) -> int:
	var roll := rng.randf()
	return 1 if roll < 0.5 else (2 if roll < 0.85 else 3)

# ---------------------------------------------------------------- helpers

static func x_text(value: float) -> String:
	return "%d %s" % [int(roundf(value)), DIFFICULTY_SYMBOL]

static func usd(units: float) -> String:
	var value := int(roundf(absf(units) * MONEY_UNIT_USD))
	var digits := str(value)
	var out := ""
	for i in digits.length():
		if i > 0 and (digits.length() - i) % 3 == 0:
			out += "."
		out += digits[i]
	return ("-$" if units < 0.0 else "$") + out

static func factory_by_id(id: String) -> Dictionary:
	for factory in FACTORIES:
		if factory["id"] == id:
			return factory
	return {}

static func term_by_months(months: int) -> Dictionary:
	for term in TERMS:
		if term["months"] == months:
			return term
	return TERMS[1]

static func req_text(req: Dictionary) -> String:
	return "%d× %s %s" % [req["count"], LEVELS[int(req["level"])], req["kind"]]

# "8 Aralık 2026" for a game date (month number and day of the month).
static func date_text(month: int, day: int) -> String:
	var names := ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
	var index := (8 + month - 1) % 12
	return "%d %s %d" % [day, names[index], 2026 + (8 + month - 1) / 12]

# "Kasım 2026 sonu" for the end of a game month.
static func month_end_text(month: int) -> String:
	var names := ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
	var index := (8 + month - 1) % 12
	return "%s %d sonu" % [names[index], 2026 + (8 + month - 1) / 12]

static func month_label(month: int) -> String:
	var names := ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
	var index := (8 + month - 1) % 12  # the game opens in September 2026
	var year := 2026 + (8 + month - 1) / 12
	return "Ay %d · %s %d" % [month, names[index], year]
