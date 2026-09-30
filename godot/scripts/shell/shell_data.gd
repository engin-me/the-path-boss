extends RefCounted

# Mock data and generators for the mobile factory shell. Every number here is
# an illustrative UI input, not balance and not a rule (see docs/ideas/IDEA-015
# and IDEA-016). Money is in game units; 1 unit = $1.000 when displayed.

const MONEY_UNIT_USD := 1000.0

const LEVELS := ["", "Standart", "Hassas", "Nitelikli"]
const TYPES := ["Torna", "Freze", "Taşlama", "Dövme"]
const STATS_LIST := ["Zeka", "Dikkat", "Hız", "Güç", "Yaratıcılık", "Sosyallik", "Görünüm"]
const WAGE := 3.0  # per person per month (mock; wage model is open in IDEA-013)

# ---------------------------------------------------------------- factories

const FACTORIES := [
	{"id": "ridgeway", "name": "Ridgeway Workshop", "region": "Riverside District", "m2": 100, "height": 4.0, "rent": 15.0,
		"age": 34, "floor": "Beton, hafif yük", "ramps": 1, "kva": 150, "tint": Color("#2b3a4a")},
	{"id": "harbor", "name": "Harbor Point Hall", "region": "Harbor Point", "m2": 150, "height": 5.0, "rent": 22.5,
		"age": 18, "floor": "Beton, orta yük", "ramps": 2, "kva": 250, "tint": Color("#2f4a45")},
	{"id": "millbrook", "name": "Millbrook Bay Plant", "region": "Millbrook Bay", "m2": 200, "height": 6.0, "rent": 30.0,
		"age": 25, "floor": "Takviyeli beton", "ramps": 2, "kva": 320, "tint": Color("#3a3f52")},
	{"id": "ironvalley", "name": "Iron Valley Hangar", "region": "Iron Valley", "m2": 300, "height": 7.0, "rent": 45.0,
		"age": 6, "floor": "Takviyeli beton, ağır yük", "ramps": 4, "kva": 600, "tint": Color("#4a3a2b")}
]

const TERMS := [
	{"months": 6, "factor": 1.10, "prepay_discount": 0.05},
	{"months": 12, "factor": 1.00, "prepay_discount": 0.08},
	{"months": 24, "factor": 0.90, "prepay_discount": 0.12}
]
const EXIT_FEE_RENTS := 2
const ABANDON_PENALTY := 0.10  # of the job revenue; paid material is lost (mock)
const SALE_RATE := 0.70  # voluntary sale of a machine (FRZ-003 v2)

# ---------------------------------------------------------------- machines

# New-machine average price (units), by type; level multiplier keeps the
# average at the user's figures (Torna 80k, Freze 120k, Taşlama 140k, Dövme 300k).
const TYPE_PRICE := {"Torna": 80.0, "Freze": 120.0, "Taşlama": 140.0, "Dövme": 300.0}
const LEVEL_MULT := {1: 0.70, 2: 1.00, 3: 1.40}
const BRANDS := {1: ["Brandt", "Halden"], 2: ["Novak Precision", "Meridian"], 3: ["Aurex", "Kessler"]}
const MODEL_PREFIX := {"Torna": "T", "Freze": "F", "Taşlama": "G", "Dövme": "P"}
const NAMEPLATE := {"Torna": 2000, "Freze": 1600, "Taşlama": 1200, "Dövme": 800}  # x per month at 3 shifts (IDEA-018)
const LEVEL_PERF := {1: 0.70, 2: 0.80, 3: 0.90}
const SCRAP_BASE := {"Torna": 0.03, "Freze": 0.04, "Taşlama": 0.06, "Dövme": 0.09}  # Standart level
const SCRAP_LEVEL_DELTA := {1: 0.0, 2: -0.005, 3: -0.01}
const SCRAP_FLOOR := 0.02
const LEVEL_LETTER := {1: "A", 2: "B", 3: "C"}  # engine machine class (BossState legacy key)
const LEVEL_AREA := {1: 25.0, 2: 30.0, 3: 40.0}
const TYPE_AREA := {"Torna": 1.0, "Freze": 1.2, "Taşlama": 1.1, "Dövme": 2.2}
const LEVEL_HEIGHT := {1: 3.0, 2: 3.5, 3: 4.5}
const TYPE_HEIGHT := {"Torna": 0.0, "Freze": 0.3, "Taşlama": 0.0, "Dövme": 1.5}
const NEW_DELIVERY := {1: 1, 2: 2, 3: 3}  # months; second hand arrives in 1
const AGE_DROP := 0.07
const AGE_FLOOR := 0.35
const ENERGY_RATE := 0.01  # of new list price per month
const CONSUMABLE_RATE := 0.005  # cutting inserts and tools, per month

static func age_factor(age: float) -> float:
	return maxf(AGE_FLOOR, 1.0 - AGE_DROP * age)

static func maintenance_risk(age: int) -> String:
	if age <= 2:
		return "Düşük"
	if age <= 6:
		return "Orta"
	return "Yüksek"

static func personnel_for(type: String, level: int) -> int:
	if type == "Dövme":
		return 2 if level == 3 else 3
	return 1

static func list_price(type: String, level: int) -> float:
	return roundf(TYPE_PRICE[type] * LEVEL_MULT[level])

# Deterministic marketplace: 12 new models plus 8 second-hand units, some discounted.
static func machine_listings() -> Array:
	var listings: Array = []
	var uid := 0
	for type in TYPES:
		for level in [1, 2, 3]:
			listings.append(_listing(uid, type, level, 0, 0.15 if uid % 5 == 2 else 0.0))
			uid += 1
	var used := [
		["Torna", 1, 6, 0.10], ["Torna", 2, 4, 0.0], ["Freze", 1, 8, 0.15], ["Freze", 3, 3, 0.0],
		["Taşlama", 2, 5, 0.10], ["Taşlama", 1, 9, 0.20], ["Dövme", 1, 7, 0.0], ["Dövme", 2, 4, 0.10]
	]
	for entry in used:
		listings.append(_listing(uid, entry[0], entry[1], entry[2], entry[3]))
		uid += 1
	return listings

static func _listing(uid: int, type: String, level: int, age: int, discount: float) -> Dictionary:
	var list: float = list_price(type, level)
	var base: float = roundf(list * age_factor(age))
	var brand: String = BRANDS[level][uid % 2]
	var area := roundf(float(LEVEL_AREA[level]) * float(TYPE_AREA[type]))
	return {
		"uid": uid, "kind": type, "type": LEVEL_LETTER[level], "level": level, "brand": brand,
		"model": "%s %s-%d" % [brand, MODEL_PREFIX[type], 100 + level * 100 + uid],
		"age": age, "list_price": list, "base_price": base, "discount": discount,
		"price": roundf(base * (1.0 - discount)),
		"capacity": int(NAMEPLATE[type]), "nameplate": int(NAMEPLATE[type]), "perf": float(LEVEL_PERF[level]),
		"scrap": maxf(SCRAP_FLOOR, float(SCRAP_BASE[type]) + float(SCRAP_LEVEL_DELTA[level])),
		"area": area, "height": snappedf(float(LEVEL_HEIGHT[level]) + float(TYPE_HEIGHT[type]), 0.1),
		"personnel": personnel_for(type, level),
		"kw": int(list / 4.0), "energy": snappedf(list * ENERGY_RATE, 0.01),
		"consumables": snappedf(list * CONSUMABLE_RATE, 0.01),
		"delivery": 1 if age > 0 else int(NEW_DELIVERY[level])
	}

# ---------------------------------------------------------------- equipment

# Mandatory package per factory size class; optional items are bought singly.
const PACKAGE_CLASSES := {
	"small": {"transpalet": 1, "kasa": 10, "raf": 8, "el_aleti": 2, "takim": 2},
	"medium": {"transpalet": 2, "kasa": 16, "raf": 14, "el_aleti": 3, "takim": 3},
	"large": {"transpalet": 4, "kasa": 30, "raf": 28, "el_aleti": 6, "takim": 6}
}
const EQUIPMENT := {
	"transpalet": {"name": "Transpalet", "price": 5.0, "area": 0.0, "required": true, "note": "Kasa ve palet taşıma"},
	"kasa": {"name": "Malzeme kasası", "price": 0.4, "area": 0.3, "required": true, "note": "Hammadde ve yarı mamul"},
	"raf": {"name": "Depo rafı", "price": 3.0, "area": 3.0, "required": true, "note": "Depolama alanı tüketir"},
	"el_aleti": {"name": "El aletleri seti", "price": 10.0, "area": 1.0, "required": true, "note": "Bakım ve ayar"},
	"takim": {"name": "Takım ve fikstür seti", "price": 25.0, "area": 1.0, "required": true, "note": "Tezgah bağlama takımları"},
	"forklift": {"name": "Forklift", "price": 40.0, "area": 0.0, "required": false, "note": "Depo & Sevkiyat sorun ihtimalini azaltır; OEE'ye yansır (test)"},
	"olcum": {"name": "Kalite ölçüm seti", "price": 20.0, "area": 1.5, "required": false, "note": "Kalite sorun ihtimalini azaltır (test)"},
	"vinc": {"name": "Köprü vinç", "price": 90.0, "area": 0.0, "required": false, "min_height": 5.0, "note": "Ağır parçalar; en az 5,0 m tavan gerekir (test)"}
}
const OPTIONAL_ORDER := ["forklift", "olcum", "vinc", "transpalet", "kasa", "raf"]

static func size_class(m2: int) -> String:
	if m2 >= 250:
		return "large"
	if m2 >= 150:
		return "medium"
	return "small"

static func package_for(m2: int) -> Dictionary:
	var items: Dictionary = PACKAGE_CLASSES[size_class(m2)]
	var price := 0.0
	var area := 0.0
	for id in items:
		price += float(EQUIPMENT[id]["price"]) * int(items[id])
		area += float(EQUIPMENT[id]["area"]) * int(items[id])
	return {"items": items, "price": snappedf(price, 0.01), "area": area}

# ---------------------------------------------------------------- credit

const CREDIT := {"bank": "Hartwell Credit Bank", "amount": 100.0, "rate": 0.015, "months": 12, "collateral": 1.25, "early_fee": 0.02}

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
static var price_per_x := 0.13  # units (k$) per x for a Torna; other kinds scale with machine price and nameplate
static var revenue_scale := 1.0  # calibration input for simulations (not a rule)
static var rent_scale := 1.0  # kept at 1.0; rents in FACTORIES are already the calibrated values
static var start_cash := 800.0
const OFFER_MIX := [4, 4, 3, 3, 3, 3, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1]  # 2×4, 4×3, 5×2, 9×1 machines

static func cost_share(count: int, best_level: int, jitter: float) -> float:
	var score := 0.5 * float(count - 1) / 3.0 + 0.5 * float(best_level - 1) / 2.0
	return clampf(0.75 - 0.45 * score + jitter, 0.30, 0.75)

# Good x per month of one Standart machine on one shift (reference size for jobs).
static func ref_output(kind: String) -> float:
	return float(NAMEPLATE[kind]) / 3.0 * float(LEVEL_PERF[1]) * (1.0 - float(SCRAP_BASE[kind]))

static func price_x(kind: String) -> float:
	return price_per_x * revenue_scale * float(TYPE_PRICE[kind]) / 80.0 * 2000.0 / float(NAMEPLATE[kind])

static func difficulty(level: int, rng: RandomNumberGenerator) -> float:
	var pool := {1: [1.0, 1.5], 2: [1.5, 2.0], 3: [2.0, 2.5]}
	return float(pool[level][rng.randi_range(0, 1)])

# Builds (or rebuilds) an offer's requirements and money from a spec:
# specs = [{"kind", "level", "n"}], n = machine-equivalents of one-shift demand.
static func fill_offer(offer: Dictionary, specs: Array, rng: RandomNumberGenerator) -> void:
	var total_n := 0
	var best := 1
	var reqs: Array = []
	var revenue := 0.0
	for spec in specs:
		var level: int = spec["level"]
		var utilisation := rng.randf_range(0.55, 1.15)
		var load_x: float = float(spec["n"]) * ref_output(spec["kind"]) * utilisation * float(offer["duration"])
		var z := difficulty(level, rng)
		var parts := maxi(10, int(roundf(load_x / z / 10.0)) * 10)
		var workload := float(parts) * z
		reqs.append({"kind": spec["kind"], "level": level, "count": int(spec["n"]), "parts": parts, "difficulty": z, "workload": workload, "remaining": workload})
		revenue += workload * price_x(spec["kind"])
		total_n += int(spec["n"])
		best = maxi(best, level)
	revenue = roundf(revenue * (1.0 + 0.15 * (best - 1)) * rng.randf_range(0.92, 1.08))
	var share := cost_share(total_n, best, rng.randf_range(-0.04, 0.04))
	offer["reqs"] = reqs
	offer["count"] = total_n
	offer["best"] = best
	offer["revenue"] = revenue
	offer["share"] = share
	offer["material"] = roundf(revenue * share)
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
		var delay := rng.randi_range(0, 2)
		var offer := {"id": month * 100 + i, "customer": CUSTOMERS[rng.randi_range(0, CUSTOMERS.size() - 1)], "duration": duration,
			"start_delay": delay, "months": delay + duration + rng.randi_range(0, 1)}
		fill_offer(offer, specs, rng)
		offers.append(offer)
	return offers

static func _level(rng: RandomNumberGenerator) -> int:
	var roll := rng.randf()
	return 1 if roll < 0.5 else (2 if roll < 0.85 else 3)

# ---------------------------------------------------------------- helpers

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

static func month_label(month: int) -> String:
	var names := ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
	var index := (8 + month - 1) % 12  # the game opens in September 2026
	var year := 2026 + (8 + month - 1) / 12
	return "Ay %d · %s %d" % [month, names[index], year]
