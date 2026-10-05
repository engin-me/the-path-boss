extends RefCounted

# Art lookup: tries png, jpg, jpeg, webp so art can be dropped in without renaming code.

static var _font_cache := {}

# IBM Plex Sans by weight name. Loaded straight from the file when the editor has not imported it yet, so a fresh
# checkout never shows a blank screen because of a missing import.
static func font(weight: String) -> Font:
	if _font_cache.has(weight):
		return _font_cache[weight]
	var path := "res://art/fonts/IBMPlexSans-%s.ttf" % weight
	var result: Font = null
	if ResourceLoader.exists(path):
		result = load(path)
	elif FileAccess.file_exists(path):
		var data := FileAccess.get_file_as_bytes(path)
		if not data.is_empty():
			var file := FontFile.new()
			file.data = data
			result = file
	if result == null:
		result = ThemeDB.fallback_font
	_font_cache[weight] = result
	return result

static var _svg_cache := {}

# An SVG icon is rasterised straight from the file at 96 px (sharp at the 38 px it is shown at, no import step needed).
static func _svg(path: String) -> Texture2D:
	if _svg_cache.has(path):
		return _svg_cache[path]
	var texture: Texture2D = null
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.is_empty() and ResourceLoader.exists(path):
		# an exported build (phone) packs the imported texture, not the raw .svg file
		var imported = load(path)
		if imported is Texture2D:
			texture = imported
	if not bytes.is_empty():
		var probe := Image.new()
		if probe.load_svg_from_buffer(bytes, 1.0) == OK and probe.get_width() > 0:
			var scale := 96.0 / float(maxi(probe.get_width(), probe.get_height()))
			var image := Image.new()
			if image.load_svg_from_buffer(bytes, scale) == OK:
				texture = ImageTexture.create_from_image(image)
	_svg_cache[path] = texture
	return texture

static func find(base: String) -> Texture2D:
	var svg_path := base + ".svg"
	if FileAccess.file_exists(svg_path) or ResourceLoader.exists(svg_path):
		var vector := _svg(svg_path)
		if vector != null:
			return vector
	for ext in ["png", "jpg", "jpeg", "webp"]:
		var path := "%s.%s" % [base, ext]
		if ResourceLoader.exists(path):
			return load(path)
		# a picture just dropped into the folder that the editor has not imported yet: read the file directly
		if FileAccess.file_exists(path):
			var image := Image.load_from_file(path)
			if image != null and not image.is_empty():
				return ImageTexture.create_from_image(image)
	return null

# Machine photo by kind, level and condition: art/machines/<kind>_<level>_<100|70|40>, e.g. torna_manuel_100.
# Condition 85+ shows the 100 picture, 60+ the 70 one, below 60 the 40 one; the old <kind>_<level number> picture is the fallback.
static func machine_photo(kind: String, level: int, condition: float) -> Texture2D:
	var names := ["", "manuel", "cnc", "hassas"]
	var bucket := 100 if condition >= 85.0 else (70 if condition >= 60.0 else 40)
	var texture := find("res://art/machines/%s_%s_%d" % [slug(kind), names[clampi(level, 1, 3)], bucket])
	if texture == null:
		texture = find("res://art/machines/%s_%d" % [slug(kind), level])
	return texture

static func slug(text: String) -> String:
	var out := text.to_lower()
	for pair in [["ş", "s"], ["ö", "o"], ["ü", "u"], ["ğ", "g"], ["ı", "i"], ["ç", "c"], ["â", "a"]]:
		out = out.replace(pair[0], pair[1])
	return out.replace(" ", "_").replace("&", "").replace("__", "_")

static var _image_cache := {}

# A deterministic image from a folder of unnamed pictures (job photos): the same key always gets the same one.
static func pick_image(folder: String, key: int) -> Texture2D:
	if not _image_cache.has(folder):
		var names: Array = []
		var dir := DirAccess.open(folder)
		if dir != null:
			for file in dir.get_files():
				var clean: String = file.trim_suffix(".import")
				if clean.get_extension().to_lower() in ["jpg", "jpeg", "png", "webp"] and not names.has(clean):
					names.append(clean)
			names.sort()
		_image_cache[folder] = names
	var list: Array = _image_cache[folder]
	if list.is_empty():
		return null
	var path := "%s/%s" % [folder, list[absi(key) % list.size()]]
	return load(path) if ResourceLoader.exists(path) else null
