extends SceneTree

# Read-only review harness: policies are hypotheses about player behaviour,
# not human playtests or approved design decisions. Uses current ShellBoss.
const Boss = preload("res://scripts/shell/shell_boss.gd")
const Data = preload("res://scripts/shell/shell_data.gd")
const OUT = "C:/Users/emrah.engin/.codex/visualizations/2026/09/30/01a0f1f3-1311-7962-b796-4f5f8fefa396/player_experience_results.json"
const PERSONAS = [
 {"name":"Aceleci acemi", "factory":"factory_1", "buys":[12], "safe":false, "limit":3, "fix_limit":1},
 {"name":"Seyrek ilgilenen", "factory":"factory_1", "buys":[12], "safe":true, "limit":1, "fix_limit":1, "every":2},
 {"name":"Temkinli küçük işletmeci", "factory":"factory_1", "buys":[12], "safe":true, "limit":3, "fix_limit":2, "adaptive":true},
 {"name":"Üretimden gelen usta", "factory":"factory_1", "buys":[12], "safe":true, "limit":3, "fix_limit":2, "skills":"01_teknik_usta", "expand":[13]},
 {"name":"Acele büyüyen", "factory":"factory_3", "buys":[12], "safe":false, "limit":3, "fix_limit":2, "expand":[13,14,17], "grow":true, "reserve":1.0},
 {"name":"Hesapçı büyüyen", "factory":"factory_1", "buys":[12], "safe":true, "limit":20, "fix_limit":20, "adaptive":true, "expand":[13,14], "grow":true, "reserve":3.0, "hidden":true, "bonus":true},
 {"name":"Sermayeli hesapçı", "factory":"factory_3", "cash":220.0, "buys":[1,4], "safe":true, "limit":20, "fix_limit":20, "adaptive":true, "grow":true, "hidden":true, "bonus":true},
 {"name":"Erken kurucu", "factory":"factory_1", "buys":[12], "safe":true, "limit":3, "fix_limit":2, "adaptive":true, "skills":"05_erken_kurucu"}
]

func _initialize():
 call_deferred("_run")

func _run():
 var output = []
 for p in PERSONAS:
  var runs = []
  for s in 20:
   runs.append(_play(p,s))
  var a = {"name":p.name,"survived":0,"bankrupt":0,"runs":runs}
  for key in ["months","net","first_delivery_day","quoted","accepted","rejected","counter","delivered","late","cancelled","idle_months","read_offers","fit_offers","fixes","fix_failed","fix_blocked","machines","roles","expand_month","shift_changes","empty_end","months_no_new","max_no_new_streak","oee","util"]:
   var total = 0.0
   var n = 0
   for r in runs:
    if key == "first_delivery_day" and r[key] == 0:
     continue
    if key == "expand_month" and r[key] == 0:
     continue
    total += float(r[key])
    n += 1
   a[key] = total / max(1,n)
  for r in runs:
   if r.closure == "survived": a.survived += 1
   else: a.bankrupt += 1
  output.append(a)
  var brief = a.duplicate()
  brief.erase("runs")
  print(JSON.stringify(brief))
 var file = FileAccess.open(OUT,FileAccess.WRITE)
 file.store_string(JSON.stringify(output,"  "))
 quit()

func _play(p:Dictionary,s:int) -> Dictionary:
 var g = Boss.new()
 g.max_months = 36
 g.default_setup(s)
 g.apply_benefit_preset(1)
 if p.has("cash"): g.cash = float(p.cash)
 if p.has("skills"):
  var input = JSON.parse_string(FileAccess.get_file_as_string("res://playtests/personas/%s.json" % p.skills))
  g.skills = input.skills.duplicate()
 var r = {"seed":s,"months":0,"net":0.0,"closure":"","first_delivery_day":0,"quoted":0,"accepted":0,"rejected":0,"counter":0,"delivered":0,"late":0,"cancelled":0,"idle_months":0,"read_offers":0,"fit_offers":0,"fixes":0,"fix_failed":0,"fix_blocked":0,"machines":0,"roles":0,"expand_month":0,"shift_changes":0,"empty_end":0,"months_no_new":0,"max_no_new_streak":0,"oee":0.0,"util":0.0,"timeline":[]}
 var rent_error = g.rent_factory(p.factory,12,false)
 if rent_error != "":
  r.closure = rent_error
  return r
 g.default_supplier = "nord"
 if p.name == "Sermayeli hesapçı": g.default_supplier = "atlas"
 g.buy_package()
 for uid in p.buys: g.buy_listing(uid)
 var expand:Array = p.get("expand",[]).duplicate()
 var streak = 0
 var used = 0.0
 var capacity = 0.0
 while g.phase == "offers":
  var old_accept = r.accepted
  var old_deliver = r.delivered
  var old_fixes = r.fixes
  var active_turn = (g.month-1) % int(p.get("every",1)) == 0
  if active_turn and g.in_notice_window(): g.set_renewal(12)
  if active_turn and not expand.is_empty():
   var listing = g.listing_by_uid(expand[0])
   if g.cash > listing.price + float(p.get("reserve",3.0)) * g.ordinary_expense():
    if g.buy_listing(expand[0]) == "":
     expand.remove_at(0)
     if r.expand_month == 0: r.expand_month = g.month
  if active_turn and p.get("grow",false):
   for machine in g.delivered():
    var backlog = 0.0
    for job in g.jobs:
     for req in job.reqs:
      if req.kind == machine.kind: backlog += req.remaining
    var monthly = maxf(1.0,g.effective_capacity(machine.kind))
    if backlog > 2*monthly and g.cash > 2*g.ordinary_expense() and machine.shifts < 3:
     if g.set_shifts(machine.uid,machine.shifts+1) == "": r.shift_changes += 1
    elif backlog < 0.5*monthly and machine.shifts > 1:
     if g.set_shifts(machine.uid,machine.shifts-1) == "": r.shift_changes += 1
  r.read_offers += g.offers.size() if active_turn else 0
  for o in g.offers:
   if g.accept_block_reason(o.id) == "": r.fit_offers += 1 if active_turn else 0
  if active_turn:
   var ranked = g.offers.duplicate()
   if p.safe:
    ranked.sort_custom(func(a,b): return (a.revenue-a.material)/a.months > (b.revenue-b.material)/b.months)
   var attempts = 0
   for o in ranked:
    if attempts >= int(p.limit): break
    if g.accept_block_reason(o.id) != "": continue
    if p.safe:
     if g.quote_projection(o,o.months).late: continue
     var outstanding = 0.0
     for job in g.jobs:
      if job.order.is_empty(): outstanding += job.material
      elif not job.order.paid: outstanding += job.order.amount
     if g.cash + g.advance_of(o) - outstanding - o.material * Data.supplier_by_id(g.default_supplier).price < g.ordinary_expense(): continue
     var cap = g.effective_capacity()
     if cap <= 0:
      for machine in g.machines: cap += machine.nameplate / 3.0 * machine.perf * (1-machine.scrap)
     var load = 0.0
     for job in g.jobs: load += g.job_remaining(job)
     for req in o.reqs: load += req.workload
     if load > 0.85*cap*o.months: continue
    var estimate = g.cost_estimate(o)
    var margin = 0.3
    if p.get("adaptive",false):
     # Quote UI permits at most 100% margin. Do not use stock bot's 150%.
     for step in range(20,-1,-1):
      var candidate = step*0.05
      if g.accept_probability(o,estimate.total*(1+candidate),30,o.months).accept >= 0.6:
       margin = candidate
       break
    var result = g.submit_quote(o.id,snappedf(estimate.total*(1+margin),0.001),30,o.months)
    if not result.ok: continue
    attempts += 1
    r.quoted += 1
    if result.status == "rejected": r.rejected += 1
    if result.status == "counter":
     r.counter += 1
     if not p.safe or result.mail.price >= estimate.total*1.05:
      if g.answer_counter(result.mail.id,true) == "": r.accepted += 1
    elif result.status == "accepted": r.accepted += 1
   if p.get("bonus",false):
    for job in g.jobs:
     if job.bonus_ask: g.choose_bonus(job.id,"speed")
  for day_index in 30:
   var ev = g.advance_day()
   for event in ev.events:
    if event.text.begins_with("Teslim:"):
     r.delivered += 1
     if r.first_delivery_day == 0: r.first_delivery_day = (g.month-1)*30+ev.day
     if event.text.contains("GEÇ TESLİM"): r.late += 1
  g.run_report()
  r.oee += g.report.oee
  used += g.report.used
  capacity += g.report.net
  if g.report.used <= 0.0001: r.idle_months += 1
  if g.jobs.is_empty(): r.empty_end += 1
  if active_turn:
   var repairs = []
   for department in g.SKILLS: repairs.append_array(g.active_rows(department))
   repairs.sort_custom(func(a,b): return (1 if a.visible else 0) > (1 if b.visible else 0))
   var fixed = 0
   for row in repairs:
    if fixed >= int(p.fix_limit): break
    if not row.visible and not (p.get("hidden",false) and g.cash > 3*row.upper): continue
    if g.fix_block_reason(row.id) != "":
     r.fix_blocked += 1
     continue
    var repair = g.fix(row.id)
    if repair.ok:
     fixed += 1
     r.fixes += 1
     if not repair.success: r.fix_failed += 1
  var entry = {"month":g.month,"cash":g.cash,"accepted":r.accepted-old_accept,"delivered":r.delivered-old_deliver,"fixes":r.fixes-old_fixes,"machines":g.machines.size(),"running_jobs":g.jobs.size(),"roles":g.office_roles().size()}
  r.roles = maxi(r.roles,g.office_roles().size())
  g.close_month()
  entry["cash_after"] = g.cash
  r.timeline.append(entry)
  for line in g.last_lines:
   if str(line).begins_with("İptal:"): r.cancelled += 1
  r.months += 1
  if old_accept == r.accepted:
   r.months_no_new += 1
   streak += 1
   r.max_no_new_streak = maxi(r.max_no_new_streak,streak)
  else: streak = 0
 r.net = g.cash-g.debt
 r.closure = g.closure.get("type","unknown")
 r.machines = g.machines.size()
 r.oee /= max(1,r.months)
 r.util = used/maxf(0.001,capacity)
 return r
