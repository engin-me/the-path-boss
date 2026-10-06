extends Control
# A small line chart (finance panel of the management screen): caption on top, line with a soft area below it.

var values: Array = []
var caption := ""
var line_color := Color("#45c7d8")
var text_color := Color("#98a7b6")

func _init() -> void:
	custom_minimum_size = Vector2(0, 80)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_data(new_values: Array, new_caption: String, color: Color) -> void:
	values = new_values
	caption = new_caption
	line_color = color
	queue_redraw()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(2, 11), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, text_color)
	var top := 18.0
	var bottom := size.y - 4.0
	draw_line(Vector2(0, bottom), Vector2(size.x, bottom), Color(1, 1, 1, 0.12), 1.0)
	if values.size() < 2:
		draw_string(font, Vector2(2, (top + bottom) * 0.5 + 4.0), "veri birikiyor", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1, 1, 1, 0.3))
		return
	var low := float(values[0])
	var high := float(values[0])
	for v in values:
		low = minf(low, float(v))
		high = maxf(high, float(v))
	var span := maxf(0.0001, high - low)
	var points := PackedVector2Array()
	for i in values.size():
		var x := size.x * float(i) / float(values.size() - 1)
		var y := bottom - (bottom - top) * (float(values[i]) - low) / span
		points.append(Vector2(x, y))
	var area := PackedVector2Array(points)
	area.append(Vector2(size.x, bottom))
	area.append(Vector2(0, bottom))
	draw_colored_polygon(area, Color(line_color.r, line_color.g, line_color.b, 0.14))
	draw_polyline(points, line_color, 1.6, true)
	draw_circle(points[points.size() - 1], 2.6, line_color)
