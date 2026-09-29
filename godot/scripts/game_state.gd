extends RefCounted

# This is the six-month fixture from game/campaign.py. Values are illustrative.
# Rule structure follows the CURRENT FREEZE files in docs/freeze/.
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
# FRZ-001: Tier thresholds and below-threshold chance by missing Tier steps.
const TIER_THRESHOLDS := [30, 50, 70, 90, 100]
const GAP_CHANCES := {1: 0.80, 2: 0.40, 3: 0.15}
const FLOOR_CHANCE := 0.05
# FRZ-001 §6: the small scale limits new problems to this Tier in the fixture.
const SCALE_MAX_TIER := 2
const ORDINARY_EXPENSE := 50.0
const MACHINE_PRICE := 30.0
const MONTHLY_HOURS := 6
# FRZ-003 v2 §2: visible monthly financing cost on a negative company position.
const FINANCE_COST := 1.0

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
var hours_left := MONTHLY_HOURS
var history: Array[String] = []
var notice := "İlk işini ve boş zamanını seç. Geçmişin patron yetkinliklerini belirler."
var rng := RandomNumberGenerator.new()

func _init() -> void:
	rng.randomize()
	for skill in SKILLS:
		skills[skill] = 40 if skill == "Üretim" else (25 if skill == "Planlama" else 20)

static func reached_tier(skill: int) -> int:
	var tier := 0
	for index in TIER_THRESHOLDS.size():
		if skill >= TIER_THRESHOLDS[index]:
			tier = index + 1
	return tier

static func chance_for_gap(gap: int) -> float:
	if gap <= 0:
		return 1.0
	return float(GAP_CHANCES.get(gap, FLOOR_CHANCE))

static func chance_label(chance: float) -> String:
	if chance >= 1.0:
		return "Kesin"
	if chance >= 0.8:
		return "Yüksek"
	if chance >= 0.4:
		return "Orta"
	return "Düşük"

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
		notice = "Kariyer dönemin bitti. Birikimin ve öğrendiklerinle kendi fabrikanı kurabilirsin."
	return true

func found_factory() -> bool:
	if phase != "founding":
		return false
	if career_cash - MACHINE_PRICE < ORDINARY_EXPENSE + QUOTES[SCALE_MAX_TIER]["upper"]:
		notice = "Kuruluş için makine sonrası en az %.0f birim kasa gerekli." % (ORDINARY_EXPENSE + QUOTES[SCALE_MAX_TIER]["upper"])
		return false
	cash = career_cash - MACHINE_PRICE
	career_cash = 0.0
	problems = {
		"planning_1": _new_problem("Planlama", 2, 10.0),
		"production": _new_problem("Üretim", 1, 10.0)
	}
	phase = "offer"
	history.append("Küçük fabrika kuruldu: kasa %.0f, makine %.0f" % [cash, MACHINE_PRICE])
	notice = "Fabrikan hazır. Fabrikayı kurmak işin kolay kısmıydı; şimdi ayakta tutman gerekiyor. İlk ayın işini seç."
	return true

func _new_problem(department: String, tier: int, loss: float) -> Dictionary:
	return {"department": department, "tier": tier, "loss": loss, "active": true, "attempted": 0, "total_loss": 0.0, "ever_seen": false, "solved_month": 0}

func accept_offer(offer_id: String) -> bool:
	if phase != "offer" or not OFFERS.has(offer_id):
		return false
	var offer: Dictionary = OFFERS[offer_id]
	if factory_month == 3 and not problems["planning_1"]["active"]:
		problems["planning_2"] = _new_problem("Planlama", 2, 5.0)
	selected_offer = offer_id
	var loss := 0.0
	for root in problems.values():
		if root["active"]:
			loss += root["loss"]
			root["total_loss"] += root["loss"]
			if is_visible(root):
				root["ever_seen"] = true
	var realized: float = offer["quantity"] - loss
	report = {"expected": offer["quantity"], "realized": realized, "loss": loss, "revenue": realized * offer["price"], "empty": 100 - offer["quantity"]}
	hours_left = MONTHLY_HOURS
	phase = "report"
	notice = "Ay sonu raporu hazır. Düzelt sonuçları gelecek ayın raporuna yansır."
	return true

func is_visible(root: Dictionary) -> bool:
	return reached_tier(skills[root["department"]]) >= root["tier"]

# Unreachable Tiers that the current scale allows (FRZ-001 §2).
func hidden_tiers(department: String) -> Array[int]:
	var tiers: Array[int] = []
	for tier in range(reached_tier(skills[department]) + 1, SCALE_MAX_TIER + 1):
		tiers.append(tier)
	return tiers

func chance_for(root: Dictionary) -> float:
	return chance_for_gap(root["tier"] - reached_tier(skills[root["department"]]))

# Visible rows and rows with a single possible hidden Tier show a rough label;
# otherwise a hidden row only shows "Belirsiz" so the label cannot leak its Tier.
func chance_text(root: Dictionary) -> String:
	if is_visible(root) or hidden_tiers(root["department"]).size() == 1:
		return chance_label(chance_for(root))
	return "Belirsiz"

# FRZ-001 §5: hidden rows share the shallowest unreachable Tier floor as the
# estimate and the scale's deepest Tier ceiling as the upper guarantee.
func quote_for(root: Dictionary) -> Dictionary:
	var real: Dictionary = QUOTES[root["tier"]]
	if is_visible(root):
		return real
	var shallow: Dictionary = QUOTES[hidden_tiers(root["department"])[0]]
	var deepest: Dictionary = QUOTES[SCALE_MAX_TIER]
	return {
		"estimate": shallow["estimate"], "actual": real["actual"], "upper": deepest["upper"],
		"estimate_hours": shallow["estimate_hours"], "actual_hours": real["actual_hours"], "upper_hours": deepest["upper_hours"]
	}

func available_for_fix() -> float:
	return cash - ORDINARY_EXPENSE - OFFERS[selected_offer]["cost"]

func active_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for root_id in problems:
		var root: Dictionary = problems[root_id]
		if root["active"]:
			var quote := quote_for(root)
			rows.append({
				"id": root_id, "department": root["department"], "tier": root["tier"], "loss": root["loss"],
				"visible": is_visible(root), "attempted": root["attempted"] == factory_month,
				"chance": chance_text(root), "estimate": quote["estimate"], "upper": quote["upper"],
				"estimate_hours": quote["estimate_hours"], "upper_hours": quote["upper_hours"]
			})
	return rows

func fix(root_id: String) -> bool:
	if phase != "report" or not problems.has(root_id):
		return false
	var root: Dictionary = problems[root_id]
	if not root["active"] or root["attempted"] == factory_month:
		notice = "Aynı köke bu ay yeniden müdahale edilemez."
		return false
	var quote := quote_for(root)
	if available_for_fix() < quote["upper"]:
		notice = "Bilinen giderlerden sonra en fazla %.0f bedeli karşılayacak paran yok." % quote["upper"]
		return false
	if hours_left < quote["upper_hours"]:
		notice = "En fazla %d saatlik müdahale için yeterli patron zamanın yok." % quote["upper_hours"]
		return false
	var chance := chance_for(root)
	var success: bool = chance >= 1.0 or rng.randf() < chance
	var paid: float = quote["actual"] if success else quote["estimate"]
	var hours: int = quote["actual_hours"] if success else quote["estimate_hours"]
	cash -= paid
	hours_left -= hours
	root["attempted"] = factory_month
	if success:
		root["active"] = false
		root["solved_month"] = factory_month
	var root_name: String = ("%s T%d" % [root["department"], root["tier"]]) if is_visible(root) else ("%s · derinliği bilinmeyen sorun" % root["department"])
	if success:
		notice = "%s çözüldü. %.0f para ve %d saat harcandı. Etkisini gelecek ayın raporunda göreceksin." % [root_name, paid, hours]
	else:
		notice = "%s çözülemedi. %.0f para ve %d saat harcandı. Bu kök bu ay yeniden denenemez; sorun sürüyor." % [root_name, paid, hours]
	history.append("Fabrika %d: %s Düzelt %s" % [factory_month, root["department"], "başarılı" if success else "başarısız"])
	return true

func finish_month() -> bool:
	if phase != "report":
		return false
	cash += report["revenue"] - ORDINARY_EXPENSE - OFFERS[selected_offer]["cost"]
	var financing := 0.0
	if cash < 0.0:
		financing = FINANCE_COST
		cash -= financing
	asset_reference = maxf(0.0, asset_reference - 1.0)
	var rescue_threshold: float = asset_reference * 0.5 + (70.0 - ORDINARY_EXPENSE) * 6.0
	var debt_gap := maxf(0.0, -cash)
	history.append("Fabrika %d: %.0f / %.0f çıktı, gelir %.2f, kasa %.2f" % [factory_month, report["realized"], report["expected"], report["revenue"], cash])
	notice = "%d. fabrika ayı bitti. Kasa %.2f, borç açığı %.2f, kurtarma eşiği %.2f." % [factory_month, cash, debt_gap, rescue_threshold]
	if financing > 0.0:
		notice += " Eksi kasa için %.0f finansman gideri işledi." % financing
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

# FRZ-003 v2 §6 style closing report: every root, hidden ones included, with the
# competence that would have made its diagnosis and fix certain.
func closing_report() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for root_id in problems:
		var root: Dictionary = problems[root_id]
		var needed: int = TIER_THRESHOLDS[root["tier"] - 1]
		rows.append({
			"department": root["department"], "tier": root["tier"], "total_loss": root["total_loss"],
			"seen": root["ever_seen"], "solved": not root["active"], "needed": needed,
			"skill": skills[root["department"]]
		})
	return rows

func lesson() -> String:
	var worst := {}
	for row in closing_report():
		if row["skill"] < row["needed"] and (worst.is_empty() or row["total_loss"] > worst["total_loss"]):
			worst = row
	if worst.is_empty():
		return "Kariyerin, bu fabrikanın sorunlarını görmeye yetti. Bir sonraki fabrikada daha derin sorunlar seni bekliyor."
	return "Bu sefer %s bilgisini %d'ye taşımadan fabrika kurmayacağım. (Şu an %d.)" % [worst["department"], worst["needed"], worst["skill"]]
