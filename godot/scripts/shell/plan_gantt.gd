extends Control
# Calendar of one quote: per machine kind a lane with the accepted jobs (blue), the window the customer allows (amber)
# and where this job would sit with today's settings (green when it fits the window, red when it is late).

signal lane_tapped(kind: String)
signal drag_started
signal start_dragged(delta_days: int)   # the player slides this job's bar: days moved since the press

const BLUE := Color("#62a8e5")
const AMBER := Color("#e7b75c")
const GREEN := Color("#2fd17b")
const RED := Color("#e86f6f")
const GRID := Color(1, 1, 1, 0.85)
const TEXT := Color("#98a7b6")
const LANE_H := 58.0
const LEFT := 58.0

var lanes: Array = []        # [{kind, icon, color, segments: [{start, end, extra}], window_end}]
var horizon := 180.0         # days shown
var late_days := 0

var dragging := false
var drag_from_x := 0.0

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func set_data(new_lanes: Array, new_horizon: float, new_late: int) -> void:
	lanes = new_lanes
	horizon = maxf(90.0, new_horizon)
	late_days = new_late
	custom_minimum_size = Vector2(0, LANE_H * lanes.size() + 26.0)
	queue_redraw()

func _x(day: float) -> float:
	return LEFT + (size.x - LEFT - 6.0) * clampf(day / horizon, 0.0, 1.0)

# True when `point` lies on this job's own bar (the green or red one, lower half of a lane).
func _on_own_bar(point: Vector2) -> bool:
	var index := int(point.y / LANE_H)
	if index < 0 or index >= lanes.size() or point.y - LANE_H * index < LANE_H * 0.5:
		return false
	for segment in lanes[index]["segments"]:
		if bool(segment.get("extra", false)) and point.x >= _x(float(segment["start"])) - 10.0 and point.x <= _x(float(segment["end"])) + 10.0:
			return true
	return false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _on_own_bar(event.position):
				dragging = true
				drag_from_x = event.position.x
				drag_started.emit()
				accept_event()
		elif dragging:
			dragging = false
			accept_event()
		else:
			var index := int(event.position.y / LANE_H)
			if event.position.x < LEFT and index >= 0 and index < lanes.size():
				lane_tapped.emit(String(lanes[index]["kind"]))
	elif event is InputEventMouseMotion and dragging:
		var per_day := (size.x - LEFT - 6.0) / horizon
		start_dragged.emit(int(roundf((event.position.x - drag_from_x) / maxf(0.01, per_day))))
		accept_event()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var months := int(horizon / 30.0)
	var body := LANE_H * lanes.size()
	for m in range(0, months + 1):
		var x := _x(float(m) * 30.0)
		draw_line(Vector2(x, 4.0), Vector2(x, body - 4.0), GRID, 1.5 if m > 0 else 2.0)
		if m > 0 and m % 3 == 0:
			var label := str(m)
			draw_string(font, Vector2(x - font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x * 0.5, body + 16.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, TEXT)
	for i in lanes.size():
		var lane: Dictionary = lanes[i]
		var top := LANE_H * i
		var icon: Texture2D = lane.get("icon", null)
		if icon != null:
			var texture_size := icon.get_size()
			var fit := minf(46.0 / texture_size.x, 38.0 / texture_size.y)
			draw_texture_rect(icon, Rect2(Vector2(6, top + LANE_H * 0.5 - texture_size.y * fit * 0.5), texture_size * fit), false, Color.WHITE)
		draw_line(Vector2(LEFT, top + LANE_H * 0.5), Vector2(size.x - 6.0, top + LANE_H * 0.5), Color(1, 1, 1, 0.95), 1.5)
		# customer window (lower half), then this job over it
		var window_end := float(lane.get("window_end", 0.0))
		draw_rect(Rect2(_x(0), top + LANE_H * 0.5, _x(window_end) - _x(0), LANE_H * 0.5 - 6.0), AMBER)
		var extra_end := 0.0
		for segment in lane["segments"]:
			var a := _x(float(segment["start"]))
			var b := _x(float(segment["end"]))
			if bool(segment.get("extra", false)):
				var fits: bool = float(segment["end"]) <= window_end + 0.5
				draw_rect(Rect2(a, top + LANE_H * 0.5, maxf(2.0, b - a), LANE_H * 0.5 - 6.0), GREEN if fits else RED)
				extra_end = b
			else:
				draw_rect(Rect2(a, top + 5.0, maxf(2.0, b - a), LANE_H * 0.5 - 5.0), BLUE)
		if late_days > 0 and extra_end > 0.0:
			var text := "%d gün geç" % late_days
			var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
			draw_string(font, Vector2(minf(size.x - w - 6.0, extra_end + 4.0), top + LANE_H - 4.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, RED)
