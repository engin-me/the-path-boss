extends RefCounted

# Art lookup: tries png, jpg, jpeg, webp so art can be dropped in without renaming code.

static func find(base: String) -> Texture2D:
	for ext in ["png", "jpg", "jpeg", "webp"]:
		var path := "%s.%s" % [base, ext]
		if ResourceLoader.exists(path):
			return load(path)
	return null

static func slug(text: String) -> String:
	var out := text.to_lower()
	for pair in [["ş", "s"], ["ö", "o"], ["ü", "u"], ["ğ", "g"], ["ı", "i"], ["ç", "c"], ["â", "a"]]:
		out = out.replace(pair[0], pair[1])
	return out.replace(" ", "_").replace("&", "").replace("__", "_")
