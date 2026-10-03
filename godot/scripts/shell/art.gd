extends RefCounted

# Art lookup: tries png, jpg, jpeg, webp so art can be dropped in without renaming code.

static var _svg_cache := {}

# An SVG icon is rasterised straight from the file at 96 px (sharp at the 38 px it is shown at, no import step needed).
static func _svg(path: String) -> Texture2D:
	if _svg_cache.has(path):
		return _svg_cache[path]
	var texture: Texture2D = null
	var bytes := FileAccess.get_file_as_bytes(path)
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
