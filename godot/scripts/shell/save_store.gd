extends RefCounted

# Save file helper for the factory shell. One slot, binary Variant format so
# integer keys and 64-bit RNG state survive. Delete with erase().

const PATH := "user://savegame.dat"
const TEMP := "user://savegame.tmp"
const VERSION := 1

# Off in headless runs (tests, simulations) so they never touch a real save.
static var enabled := true

static func active() -> bool:
	return enabled and DisplayServer.get_name() != "headless"

static func exists() -> bool:
	return active() and FileAccess.file_exists(PATH)

static func write(data: Dictionary) -> bool:
	if not active():
		return false
	var file := FileAccess.open(TEMP, FileAccess.WRITE)
	if file == null:
		return false
	file.store_var({"version": VERSION, "data": data})
	file.close()
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(TEMP), ProjectSettings.globalize_path(PATH)) == OK

# Returns {} when there is no usable save.
static func read() -> Dictionary:
	if not exists():
		return {}
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		return {}
	var payload = file.get_var()
	file.close()
	if typeof(payload) != TYPE_DICTIONARY or int(payload.get("version", 0)) != VERSION or typeof(payload.get("data")) != TYPE_DICTIONARY:
		return {}
	return payload["data"]

static func erase() -> void:
	for path in [PATH, TEMP]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
