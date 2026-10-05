extends Control
# Half-circle gauge ("İşi Alma İhtimali"): the arc fills as the value (0..1) grows.

var value := 0.0
var caption := ""
var fill_color := Color("#e7b75c")
var track_color := Color(1, 1, 1, 0.12)

func _init() -> void:
	custom_minimum_size = Vector2(150, 92)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_value(new_value: float) -> void:
	value = clampf(new_value, 0.0, 1.0)
	# green when likely, amber in the middle, red when the customer will probably walk away
	fill_color = Color("#e86f6f").lerp(Color("#e7b75c"), clampf(value * 2.0, 0.0, 1.0)).lerp(Color("#2fd17b"), clampf(value * 2.0 - 1.0, 0.0, 1.0))
	queue_redraw()

func _draw() -> void:
	var radius := minf(size.x * 0.5 - 6.0, size.y - 10.0)
	var center := Vector2(size.x * 0.5, size.y - 6.0)
	var width := radius * 0.34
	var mid := radius - width * 0.5
	draw_arc(center, mid, PI, TAU, 48, track_color, width, true)
	if value > 0.001:
		draw_arc(center, mid, PI, PI + PI * value, 48, fill_color, width, true)
	var font := ThemeDB.fallback_font
	var text := "%%%.0f" % (value * 100.0)
	var font_size := int(radius * 0.42)
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	draw_string(font, Vector2(center.x - text_size.x * 0.5, center.y - radius * 0.12), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, fill_color)
