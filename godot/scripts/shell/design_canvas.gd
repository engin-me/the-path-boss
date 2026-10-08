extends Control
# A card laid out in the design file's coordinates: every element is placed at (x, y) of the slide (points), and the
# card scales them to the phone width. `y` grows as rows are added; `finish()` sets the card's height.

const Art = preload("res://scripts/shell/art.gd")

const CARD := Color("#182431")
const INNER := Color("#0b1118")
const INNER_BORDER := Color("#222e3b")
const BORDER := Color("#344556")
const TEXT := Color("#e7edf3")
const MUTED := Color("#98a7b6")
const GREEN := Color("#2fd17b")
const BUTTON_GREEN := Color("#1f7a4d")
const AMBER := Color("#e7b75c")
const RED := Color("#e86f6f")
const BLUE := Color("#62a8e5")
const CYAN := Color("#45c7d8")
const TEXT_INSET := 7.2

var scale_k := 1.0        # screen pixels per design point
var origin := Vector2.ZERO   # design coordinates of the card's top-left corner
var card_size := Vector2(437, 100)   # design points

static var _textures := {}

func setup(card_origin: Vector2, card_width_pt: float, screen_width: float, height_pt: float, radius_pt := 14.0) -> void:
	origin = card_origin
	card_size = Vector2(card_width_pt, height_pt)
	scale_k = screen_width / card_width_pt
	custom_minimum_size = Vector2(screen_width, height_pt * scale_k)
	add_theme_stylebox_override("panel", style(CARD, radius_pt, BORDER))

func to_px(x: float, y: float) -> Vector2:
	return Vector2((x - origin.x) * scale_k, (y - origin.y) * scale_k)

func set_height(height_pt: float) -> void:
	card_size.y = height_pt
	custom_minimum_size = Vector2(card_size.x * scale_k, height_pt * scale_k)

func font_px(pt: float) -> int:
	return int(roundf(maxf(pt * scale_k, 12.0 + (pt - 9.0) * 0.5)))

func style(fill: Color, radius_pt: float, border := BORDER, width := 1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(int(roundf(radius_pt * scale_k)))
	return box

func _draw() -> void:
	draw_style_box(style(CARD, 14.0, BORDER), Rect2(Vector2.ZERO, size))

func place(node: Control, x: float, y: float, w: float, h: float) -> Control:
	add_child(node)
	node.position = to_px(x, y)
	node.size = Vector2(w, h) * scale_k
	node.custom_minimum_size = node.size
	return node

# Text in a box (x, y, w, h in design points); alignment left, center or right.
func text(x: float, y: float, w: float, content: String, pt: float, color := TEXT, align := HORIZONTAL_ALIGNMENT_LEFT, weight := "Regular", h := 22.0) -> Label:
	var label := Label.new()
	label.text = content
	label.add_theme_font_size_override("font_size", font_px(pt))
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_override("font", Art.font(weight))
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_constant_override("line_spacing", -3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(label, x + TEXT_INSET, y, maxf(4.0, w - 2.0 * TEXT_INSET), h)   # PowerPoint text boxes keep a 7.2 pt side inset
	return label

# Same box rules as text(), with colour tags ([color=#e7b75c]...[/color]).
func rich(x: float, y: float, w: float, content: String, pt: float, color := TEXT, h := 22.0) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.scroll_active = false
	label.text = content
	label.add_theme_font_size_override("normal_font_size", font_px(pt))
	label.add_theme_color_override("default_color", color)
	label.add_theme_font_override("normal_font", Art.font("Regular"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(label, x + TEXT_INSET, y, maxf(4.0, w - 2.0 * TEXT_INSET), h)
	return label

func box(x: float, y: float, w: float, h: float, fill: Color, radius_pt: float, border := BORDER, width := 1) -> Panel:
	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel", style(fill, radius_pt, border, width))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(panel, x, y, w, h)
	return panel

func line(x: float, y: float, w: float, color := BORDER) -> ColorRect:
	var rect := ColorRect.new()
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(rect, x, y, w, 0.6)
	rect.custom_minimum_size = Vector2(w * scale_k, 1.0)
	rect.size = Vector2(w * scale_k, 1.0)
	return rect

func picture(texture: Texture2D, x: float, y: float, w: float, h: float, tint := Color.WHITE, keep_aspect := true, round_pt := 0.0) -> Control:
	if texture == null:
		return null
	if round_pt > 0.0:
		var frame := PanelContainer.new()
		frame.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
		frame.add_theme_stylebox_override("panel", style(INNER, round_pt, INNER, 0))
		var inner := TextureRect.new()
		inner.texture = texture
		inner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		inner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.add_child(inner)
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		place(frame, x, y, w, h)
		return frame
	var rect := TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if keep_aspect else TextureRect.STRETCH_SCALE
	rect.modulate = tint
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(rect, x, y, w, h)
	return rect

func icon(name: String, x: float, y: float, w: float, h: float, tint := MUTED) -> Control:
	return picture(Art.find("res://art/ui/" + name), x, y, w, h, tint)

# Round or rounded-square texture for the sliders' knob and the check boxes.
func shape_texture(size_px: int, fill: Color, border: Color, radius_px: float) -> Texture2D:
	var key := "%d|%s|%s|%d" % [size_px, fill.to_html(), border.to_html(), int(radius_px)]
	if _textures.has(key):
		return _textures[key]
	var image := Image.create(size_px, size_px, false, Image.FORMAT_RGBA8)
	var half := float(size_px) / 2.0
	for px in size_px:
		for py in size_px:
			var dx := absf(float(px) + 0.5 - half)
			var dy := absf(float(py) + 0.5 - half)
			var inner_x := half - radius_px
			var inner_y := half - radius_px
			var dist := 0.0
			if dx > inner_x and dy > inner_y:
				dist = Vector2(dx - inner_x, dy - inner_y).length()
			else:
				dist = maxf(dx - inner_x, dy - inner_y) + radius_px if maxf(dx - inner_x, dy - inner_y) > 0.0 else 0.0
			if dist <= radius_px - 1.5:
				image.set_pixel(px, py, fill)
			elif dist <= radius_px:
				image.set_pixel(px, py, border)
	var texture := ImageTexture.create_from_image(image)
	_textures[key] = texture
	return texture

func button(x: float, y: float, w: float, h: float, caption: String, on_press: Callable, pt := 12.0, primary := true, radius_pt := 7.0) -> Button:
	var b := Button.new()
	b.text = caption
	b.add_theme_font_size_override("font_size", font_px(pt))
	b.add_theme_font_override("font", Art.font("Regular"))
	b.add_theme_color_override("font_color", TEXT)
	b.add_theme_color_override("font_hover_color", TEXT)
	b.add_theme_color_override("font_pressed_color", TEXT)
	var fill := BUTTON_GREEN if primary else CARD
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		if state == "focus":
			b.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		else:
			b.add_theme_stylebox_override(state, style(fill, radius_pt, BORDER))
	b.pressed.connect(on_press)
	place(b, x, y, w, h)
	return b

# A tap area over a rectangle (an arrow, a row, a lane).
func tap(x: float, y: float, w: float, h: float, on_tap: Callable) -> Control:
	var area := Control.new()
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			on_tap.call())
	place(area, x, y, w, h)
	return area

func chevron(x: float, y: float, on_tap := Callable()) -> void:
	icon("tasarim/ok_sag", x, y, 8, 14, TEXT)
	if on_tap.is_valid():
		tap(x - 14.0, y - 10.0, 36, 34, on_tap)
