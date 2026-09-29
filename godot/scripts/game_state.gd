extends RefCounted

# This is the six-month fixture from game/campaign.py. Values are illustrative.
const SKILLS := ["Üretim", "Planlama", "Depo & Sevkiyat", "Bakım", "Kalite", "Satın Alma", "Finans", "Ar-Ge / Ür-Ge", "Yatırım", "İnsan Yönetimi"]
const ROLES := {
	"cnc": {"title": "CNC Operatörü", "wage": 30.0, "gains": {"Üretim": 18, "Kalite": 4, "Bakım": 2, "Planlama": 2}},
	"lider": {"title": "Takım Lideri", "wage": 24.0, "gains": {"İnsan Yönetimi": 15, "Planlama": 12, "Üretim": 4, "Kalite": 4}}
}
const OFFERS := {
	"temkinli": {"title": "Temkinli iş", "quantity": 70, "price": 1.0, "cost": 8.0},
	"buyuk": {"title": "Büyük iş", "quantity": 100, "price": 1.1, "cost": 20.0}
}
const QUOTES := {
	1: {"estimate": 2.0, "actual": 4.0, "upper": 4.0, "estimate_hours": 1, "actual_hours": 1, "upper_hours": 2},
	2: {"estimate": 5.0, "actual": 12.0, "upper": 20.0, "estimate_hours": 1, "actual_hours": 2, "upper_hours": 3}
}

var phase := "career"
var career_month := 1
var career_cash := 60.0
var energy := 6
var current_job := ""
var skills: Dictionary = {}
var factory_month := 1
var cash := 0.0
var asset_reference := 30.0
var selected_offer := ""
var report: Dictionary = {}
var problems: Dictionary = {}
var hours_left := 6
var history: Array[String] = []
var notice := "İlk işini ve boş zamanını seç. Geçmişin patron yetkinliklerini belirler."
var rng := RandomNumberGenerator.new()

func _init() -> void:
	rng.randomize()
	for skill in SKILLS:
		skills[skill] = 40 if skill == "Üretim" else (25 if skill == "Planlama" else 20)

func work_month(job: String, secondary: String) -> bool:
	if phase != "career" or not ROLES.has(job):
		return false
	var switching := current_job != "" and current_job != job
	var course := SKILLS.has(secondary)
	var time_used := 5 + (2 if switching else 0) + (3 if secondary != "" else 0)
	var energy_used := 3 + (2 if course else 0)
	if time_used > 8:
		notice = "İş değiştirirken kursa veya dinlenmeye zaman kalmıyor."
		return false
	if energy_used > energy:
		notice = "Bu ay için enerjin yetmiyor."
		return false
	if course and career_cash < 10:
		notice = "Kurs için paran yetmiyor."
		return false
	var role: Dictionary = ROLES[job]
	var wage: float = role["wage"] - (5.0 if switching else 0.0)
	career_cash += wage - (10.0 if course else 0.0)
	for skill in role["gains"]:
		skills[skill] = mini(100, skills[skill] + role["gains"][skill])
	if course:
		skills[secondary] = mini(100, skills[secondary] + 15)
	energy = mini(6, energy - energy_used + (2 if secondary == "rest" else 0) + 3)
	current_job = job
	history.append("Kariyer %d: %s, maaş %.0f, kasa %.0f" % [career_month, role["title"], wage, career_cash])
	notice = "%d. ay bitti. %s deneyimi kazandın." % [career_month, role["title"]]
	career_month += 1
	if career_month > 3:
		phase = "founding"
	return true

func found_factory() -> bool:
	if phase != "founding":
		return false
	if career_cash - 30.0 < 70.0:
		notice = "Kuruluş için makine sonrası en az 70 birim kasa gerekli."
		return false
	cash = career_cash - 30.0
	career_cash = 0.0
	problems = {
		"planning_1": {"department": "Planlama", "tier": 2, "loss": 10.0, "active": true, "attempted": 0},
		"production": {"department": "Üretim", "tier": 1, "loss": 10.0, "active": true, "attempted": 0}
	}
	phase = "offer"
	history.append("Küçük fabrika kuruldu: kasa %.0f, makine 30" % cash)
	notice = "Fabrikan hazır. İlk ayın işini seç."
	return true

func accept_offer(offer_id: String) -> bool:
	if phase != "offer" or not OFFERS.has(offer_id):
		return false
	var offer: Dictionary = OFFERS[offer_id]
	if cash < 50.0 + offer["cost"]:
		notice = "Bilinen aylık giderleri karşılayacak kasa yok."
		return false
	if factory_month == 3 and not problems["planning_1"]["active"]:
		problems["planning_2"] = {"department": "Planlama", "tier": 2, "loss": 5.0, "active": true, "attempted": 0}
	selected_offer = offer_id
	var loss := 0.0
	for root in problems.values():
		if root["active"]:
			loss += root["loss"]
	var realized: float = offer["quantity"] - loss
	report = {"expected": offer["quantity"], "realized": realized, "loss": loss, "revenue": realized * offer["price"], "empty": 100 - offer["quantity"]}
	hours_left = 6
	phase = "report"
	notice = "Ay sonu raporu hazır. Düzelt sonuçları gelecek ayın raporuna yansır."
	return true

func active_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for root_id in problems:
		var root: Dictionary = problems[root_id]
		if root["active"]:
			var threshold := 30 if root["tier"] == 1 else 50
			rows.append({"id": root_id, "department": root["department"], "tier": root["tier"], "loss": root["loss"], "visible": skills[root["department"]] >= threshold, "attempted": root["attempted"] == factory_month})
	return rows

func fix(root_id: String) -> bool:
	if phase != "report" or not problems.has(root_id):
		return false
	var root: Dictionary = problems[root_id]
	if not root["active"] or root["attempted"] == factory_month:
		return false
	var quote: Dictionary = QUOTES[root["tier"]]
	if cash - 50.0 - OFFERS[selected_offer]["cost"] < quote["upper"]:
		notice = "Bilinen giderlerden sonra üst güvence için yeterli paran yok."
		return false
	if hours_left < quote["upper_hours"]:
		notice = "Üst güvence için yeterli patron zamanın yok."
		return false
	var threshold := 30 if root["tier"] == 1 else 50
	var certain: bool = skills[root["department"]] >= threshold
	var success: bool = certain or rng.randf() < 0.40
	var paid: float = quote["actual"] if success else quote["estimate"]
	var hours: int = quote["actual_hours"] if success else quote["estimate_hours"]
	cash -= paid
	hours_left -= hours
	root["attempted"] = factory_month
	if success:
		root["active"] = false
	notice = "%s: %s. %.0f para ve %d saat harcandı." % [root["department"], "çözüldü" if success else "başarısız", paid, hours]
	history.append("Fabrika %d: %s Düzelt %s" % [factory_month, root["department"], "başarılı" if success else "başarısız"])
	return true

func finish_month() -> bool:
	if phase != "report":
		return false
	cash += report["revenue"] - 50.0 - OFFERS[selected_offer]["cost"]
	asset_reference = maxf(0.0, asset_reference - 1.0)
	var rescue_threshold: float = asset_reference * 0.5 + (70.0 - 50.0) * 6.0
	var debt_gap := maxf(0.0, -cash)
	history.append("Fabrika %d: %.0f / %.0f çıktı, gelir %.2f, kasa %.2f" % [factory_month, report["realized"], report["expected"], report["revenue"], cash])
	notice = "%d. fabrika ayı bitti. Kasa %.2f, borç açığı %.2f, kurtarma eşiği %.2f." % [factory_month, cash, debt_gap, rescue_threshold]
	factory_month += 1
	selected_offer = ""
	report = {}
	if debt_gap > rescue_threshold:
		phase = "end"
		notice += " Fabrika kapandı."
	elif factory_month > 3:
		phase = "end"
		notice += " Oynanabilir dilimin sonuna geldin."
	else:
		phase = "offer"
	return true
