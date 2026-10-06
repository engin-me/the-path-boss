extends Control
# A small multi-line chart (finance panel of the management screen): legend on top, lines below, a zero line when values go negative.

var series: Array = []   # [{name, values, color}]
var text_color := Color("#98a7b6")
var font_px := 12

func _init() -> void:
	custom_minimum_size = Vector2(0, 80)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_series(new_series: Array) -> void:
	series = new_series
	queue_redraw()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	# legend
	var x_legend := 2.0
	for item in series:
		draw_circle(Vector2(x_legend + 3.0, 7.0), 3.0, item["color"])
		var name := String(item["name"])
		draw_string(font, Vector2(x_legend + 10.0, 11.0), name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_px - 2, text_color)
		x_legend += 14.0 + font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_px - 2).x + 6.0
	var top := 22.0
	var bottom := size.y - 4.0
	var longest := 0
	var low := 0.0
	var high := 0.0
	var any := false
	for item in series:
		longest = maxi(longest, item["values"].size())
		for v in item["values"]:
			low = minf(low, float(v))
			high = maxf(high, float(v))
			any = true
	if not any or longest < 2:
		draw_string(font, Vector2(2, (top + bottom) * 0.5 + 4.0), "ilk ay kapanınca çizilir", HORIZONTAL_ALIGNMENT_LEFT, -1, font_px - 1, Color(1, 1, 1, 0.3))
		draw_line(Vector2(0, bottom), Vector2(size.x, bottom), Color(1, 1, 1, 0.12), 1.0)
		return
	var span := maxf(0.0001, high - low)
	var zero_y := bottom - (bottom - top) * (0.0 - low) / span
	draw_line(Vector2(0, zero_y), Vector2(size.x, zero_y), Color(1, 1, 1, 0.18), 1.0)
	for item in series:
		var values: Array = item["values"]
		if values.size() < 2:
			continue
		var points := PackedVector2Array()
		for i in values.size():
			var px := size.x * float(i) / float(maxi(1, longest - 1))
			var py := bottom - (bottom - top) * (float(values[i]) - low) / span
			points.append(Vector2(px, py))
		draw_polyline(points, item["color"], 1.6, true)
		draw_circle(points[points.size() - 1], 2.4, item["color"])
