extends RefCounted

# Mock data and helpers for the mobile factory shell. Every number here is an
# illustrative UI input, not balance and not a rule (see docs/ideas/IDEA-015).

const MONEY_UNIT_USD := 1000.0  # display only: 1 game unit = $1.000

const FACTORIES := [
	{"id": "kucuk", "name": "Tuzla Küçük Atölye", "region": "Tuzla", "m2": 100, "height": 4.0, "rent": 30.0, "tint": Color("#2b3a4a")},
	{"id": "orta", "name": "Gebze Orta Hol", "region": "Gebze", "m2": 150, "height": 5.0, "rent": 45.0, "tint": Color("#2f4a45")},
	{"id": "buyuk", "name": "Dilovası Büyük Hangar", "region": "Dilovası", "m2": 300, "height": 7.0, "rent": 90.0, "tint": Color("#4a3a2b")}
]

# Contract choices: months, rent multiplier. Exit fee is 2 rents (user decision).
const TERMS := [
	{"months": 6, "factor": 1.10},
	{"months": 12, "factor": 1.00},
	{"months": 24, "factor": 0.90}
]
const EXIT_FEE_RENTS := 2

# Height (m) and floor area (m²) are new data fields for machines.
const MACHINE_EXTRA := {
	"A": {"area": 25, "height": 3.0},
	"B": {"area": 30, "height": 3.5},
	"C": {"area": 40, "height": 4.5}
}

const OFFERS := [
	{"id": 1, "title": "Rulman yatağı serisi", "customer": "Anadolu Otomotiv", "quality": 1, "units": 25, "months": 1, "revenue": 34.0, "cost": 20.0},
	{"id": 2, "title": "Şanzıman mili", "customer": "Marmara Aktarma", "quality": 2, "units": 40, "months": 2, "revenue": 78.0, "cost": 48.0},
	{"id": 3, "title": "Hassas piston seti", "customer": "Ege Motor", "quality": 3, "units": 30, "months": 2, "revenue": 92.0, "cost": 55.0},
	{"id": 4, "title": "Flanş ve bağlantı parçaları", "customer": "Kuzey Makine", "quality": 1, "units": 35, "months": 1, "revenue": 44.0, "cost": 27.0},
	{"id": 5, "title": "Büyük parti aks gövdesi", "customer": "Doğu Ağır Sanayi", "quality": 2, "units": 90, "months": 3, "revenue": 190.0, "cost": 120.0}
]

const STATS := ["Zeka", "Dikkat", "Hız", "Güç", "Yaratıcılık", "Sosyallik", "Görünüm"]

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

static func month_label(month: int) -> String:
	var names := ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
	var index := (8 + month - 1) % 12  # the game opens in September 2026
	var year := 2026 + (8 + month - 1) / 12
	return "Ay %d · %s %d" % [month, names[index], year]
