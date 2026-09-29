extends RefCounted

# Playtest notes and reports live inside the project so every tester (manual
# play, Claude, ChatGPT/Codex) writes to files the repository can review.
const NOTES_PATH := "res://playtests/notes/notes.md"
const REPORT_DIR := "res://playtests/reports/"
const PERSONA_DIR := "res://playtests/personas/"
const CATEGORIES := ["Tasarım", "Mantık hatası", "Denge", "Arayüz", "Soru / fikir"]

static func _writable(path: String) -> String:
	var dir := path.get_base_dir()
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir)) == OK:
		return path
	# Exported builds cannot write into res://; keep notes in user:// instead.
	var fallback := "user://" + path.trim_prefix("res://")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(fallback.get_base_dir()))
	return fallback

static func append_note(author: String, category: String, text: String, context: String) -> String:
	var path := _writable(NOTES_PATH)
	var exists := FileAccess.file_exists(path)
	var file := FileAccess.open(path, FileAccess.READ_WRITE if exists else FileAccess.WRITE)
	if file == null:
		return ""
	file.seek_end()
	if not exists:
		file.store_line("# Oyun testi notları\n\nHer satır: zaman · yazan · kategori · bağlam. Tasarım kararı değildir; IDEA'ya taşınacak bulgulardır.\n")
	var stamp := Time.get_datetime_string_from_system(false, true)
	file.store_line("- **%s · %s · %s** — %s\n  - Bağlam: %s" % [stamp, author, category, text.strip_edges().replace("\n", " "), context])
	file.close()
	return ProjectSettings.globalize_path(path)

static func write_report(file_name: String, content: String) -> String:
	var path := _writable(REPORT_DIR + file_name)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(content)
	file.close()
	return ProjectSettings.globalize_path(path)

static func load_personas() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var dir := DirAccess.open(PERSONA_DIR)
	if dir == null:
		return result
	var names: Array = []
	for file_name in dir.get_files():
		if file_name.ends_with(".json"):
			names.append(file_name)
	names.sort()
	for file_name in names:
		var data = JSON.parse_string(FileAccess.get_file_as_string(PERSONA_DIR + file_name))
		if data is Dictionary:
			data["file"] = file_name
			result.append(data)
	return result
