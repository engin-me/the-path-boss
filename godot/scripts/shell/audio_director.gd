extends Node

# Sound for the factory shell: short effects are synthesised in code (no asset files), music is an
# optional loop dropped into res://audio/music/ (main.ogg, main.mp3 or main.wav). Settings live in
# user://settings.cfg. Everything is off in headless runs.

const RATE := 22050
const CONFIG_PATH := "user://settings.cfg"
const MUSIC_BASES := ["res://audio/music/main"]

var sfx_on := true
var music_on := true
var haptics_on := true
var sounds := {}
var pool: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
var music_started := false

static func active() -> bool:
	return DisplayServer.get_name() != "headless"

func _ready() -> void:
	if not active():
		return
	_load_settings()
	for i in 6:
		var player := AudioStreamPlayer.new()
		add_child(player)
		pool.append(player)
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -14.0
	add_child(music_player)
	sounds = {
		"tap": _make([[1250.0, 0.035, 0.30], [650.0, 0.03, 0.15]]),
		"confirm": _make([[660.0, 0.07, 0.35], [880.0, 0.10, 0.35]]),
		"coin_up": _make([[1320.0, 0.06, 0.30], [1760.0, 0.12, 0.30]]),
		"coin_down": _make([[440.0, 0.06, 0.28], [330.0, 0.10, 0.28]]),
		"error": _make([[170.0, 0.16, 0.30]], true),
		"month": _make([[523.0, 0.09, 0.32], [659.0, 0.09, 0.32], [784.0, 0.09, 0.32], [1046.0, 0.22, 0.34]]),
		"drop": _make([[500.0, 0.05, 0.28], [380.0, 0.07, 0.28]])
	}

func _unhandled_input(event: InputEvent) -> void:
	if not active() or music_started:
		return
	if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventKey:
		start_music()

# [[frequency, seconds, volume], ...] played one after another, each with a fast decay.
func _make(notes: Array, buzz := false) -> AudioStreamWAV:
	var data := PackedByteArray()
	for note in notes:
		var count := int(float(RATE) * float(note[1]))
		for i in count:
			var t := float(i) / float(RATE)
			var phase := TAU * float(note[0]) * t
			var wave := sin(phase)
			if buzz:
				wave = signf(wave) * 0.6 + sin(phase * 0.5) * 0.3
			var envelope := pow(1.0 - float(i) / float(count), 1.6)
			var sample := int(clampf(wave * envelope * float(note[2]), -1.0, 1.0) * 32767.0)
			data.append(sample & 0xff)
			data.append((sample >> 8) & 0xff)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = data
	return stream

func play(name: String) -> void:
	if not active() or not sfx_on or not sounds.has(name):
		return
	for player in pool:
		if not player.playing:
			player.stream = sounds[name]
			player.play()
			break
	if haptics_on and OS.has_feature("mobile"):
		Input.vibrate_handheld(10 if name == "tap" else 25)

func start_music() -> void:
	music_started = true
	if not music_on or music_player == null or music_player.playing:
		return
	for base in MUSIC_BASES:
		for ext in ["ogg", "mp3", "wav"]:
			var path := "%s.%s" % [base, ext]
			if ResourceLoader.exists(path):
				var stream = load(path)
				if "loop" in stream:
					stream.loop = true
				music_player.stream = stream
				music_player.play()
				return

func set_music(on: bool) -> void:
	music_on = on
	if music_player == null:
		return
	if on:
		start_music()
	else:
		music_player.stop()
	_save_settings()

func set_sfx(on: bool) -> void:
	sfx_on = on
	_save_settings()

func set_haptics(on: bool) -> void:
	haptics_on = on
	_save_settings()

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	sfx_on = bool(config.get_value("audio", "sfx", true))
	music_on = bool(config.get_value("audio", "music", true))
	haptics_on = bool(config.get_value("audio", "haptics", true))

func _save_settings() -> void:
	if not active():
		return
	var config := ConfigFile.new()
	config.set_value("audio", "sfx", sfx_on)
	config.set_value("audio", "music", music_on)
	config.set_value("audio", "haptics", haptics_on)
	config.save(CONFIG_PATH)
