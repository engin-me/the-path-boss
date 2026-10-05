extends Control
# Capacity vs. load per tolerance level of one machine kind (dark bar = capacity, light bar = load of the accepted jobs).
# Capacity still in transit is hatched; load that spilled up from a coarser level is gold; a quoted job's extra load is an
# outline; demand no machine can take is a red cap.

var data := {}
var color := Color("#6ec8eb")
const GOLD := Color("#e7b75c")
const RED := Color("#e86f6f")
const AXIS := Color(1, 1, 1, 0.35)
const TEXT := Color("#e7edf3")

func _init() -> void:
	custom_minimum_size = Vector2(0, 170)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_data(new_data: Dictionary, new_color: Color) -> void:
	data = new_data
	color = new_color
	queue_redraw()

func _short(value: float) -> String:
	if value >= 10000.0:
		return "%.0fk" % (value / 1000.0)
	if value >= 1000.0:
		return "%.1fk" % (value / 1000.0)
	return str(int(roundf(value)))

func _draw() -> void:
	if data.is_empty():
		return
	var font := ThemeDB.fallback_font
	var left := 30.0
	var bottom := size.y - 22.0
	var top := 16.0
	var plot_h := bottom - top
	var peak := 1.0
	for lv in data["levels"]:
		peak = maxf(peak, maxf(float(lv["cap"]) + float(lv["transit"]), float(lv["load"]) + float(lv["extra"]) + float(lv["unmet"])))
	if peak <= 1.0:
		var none := "tezgah yok"
		var ns := font.get_string_size(none, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
		draw_string(font, Vector2((size.x + left) * 0.5 - ns.x * 0.5, (top + bottom) * 0.5), none, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, AXIS)
	draw_line(Vector2(left, top), Vector2(left, bottom), AXIS, 1.0)
	draw_line(Vector2(left, bottom), Vector2(size.x, bottom), AXIS, 1.0)
	draw_string(font, Vector2(2, top + 4), "μ", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, AXIS)
	var group_w := (size.x - left) / 3.0
	var bar_w := minf(26.0, group_w * 0.32)
	for i in 3:
		var lv: Dictionary = data["levels"][i]
		var gx := left + group_w * i + group_w * 0.5
		var cap := float(lv["cap"])
		var transit := float(lv["transit"])
		var load := float(lv["load"])
		var spill := float(lv["spill"])
		var extra := float(lv["extra"])
		var unmet := float(lv["unmet"])
		# capacity bar (left)
		var cx := gx - bar_w - 2.0
		var ch := plot_h * cap / peak
		if cap > 0.0:
			draw_rect(Rect2(cx, bottom - ch, bar_w, ch), color.darkened(0.25))
		if transit > 0.0:
			var th := plot_h * transit / peak
			var r := Rect2(cx, bottom - ch - th, bar_w, th)
			draw_rect(r, Color(color.r, color.g, color.b, 0.18))
			draw_rect(r, color, false, 1.0)
			var y := r.position.y + 4.0
			while y < r.end.y:
				draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y - 4.0 if y - 4.0 > r.position.y else r.position.y), Color(color.r, color.g, color.b, 0.6), 1.0)
				y += 5.0
		var cap_total := cap + transit
		if cap_total > 0.0:
			var t := _short(cap_total)
			var ts := font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
			draw_string(font, Vector2(cx + bar_w * 0.5 - ts.x * 0.5, bottom - plot_h * cap_total / peak - 3.0), t, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXT)
		# load bar (right): own (light) + spill (gold), then the extra outline, then unmet
		var lx := gx + 2.0
		var own := load - spill
		var oh := plot_h * own / peak
		var sh := plot_h * spill / peak
		var eh := plot_h * extra / peak
		var uh := plot_h * unmet / peak
		if own > 0.0:
			draw_rect(Rect2(lx, bottom - oh, bar_w, oh), color.lightened(0.45))
		if spill > 0.0:
			draw_rect(Rect2(lx, bottom - oh - sh, bar_w, sh), GOLD)
		if extra > 0.0:
			var er := Rect2(lx, bottom - oh - sh - eh, bar_w, eh)
			draw_rect(er, Color(1, 1, 1, 0.12))
			draw_rect(er, TEXT, false, 1.5)
		if unmet > 0.0:
			draw_rect(Rect2(lx, bottom - oh - sh - eh - uh, bar_w, uh), RED)
		var shown := load + extra + unmet
		if shown > 0.0:
			var t2 := _short(shown)
			var ts2 := font.get_string_size(t2, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
			draw_string(font, Vector2(lx + bar_w * 0.5 - ts2.x * 0.5, bottom - plot_h * shown / peak - 3.0), t2, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, RED if unmet > 0.0 else TEXT)
		var label := String(lv["tol"])
		var ls := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
		draw_string(font, Vector2(gx - ls.x * 0.5, size.y - 6.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXT)
