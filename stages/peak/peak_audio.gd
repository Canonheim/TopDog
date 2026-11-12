class_name PeakAudio
extends Node
## The Peak's sound. Twelve music loops and twelve ambience beds play in step from the
## moment the climb begins; only their volumes move, by the area weights. One-shots and
## looping emitters are placed in the world. A long fall puts the music under a low-pass
## filter and brings up the wind. Files: audio/music/peak/, audio/sfx/peak/ (any that are
## missing are simply silent).

const MUSIC_DIR := "res://audio/music/peak/"
const SFX_DIR := "res://audio/sfx/peak/"
const MUSIC_DB := -5.0
const AMB_DB := -9.0
const BUS := "PeakMusic"

var peak: Peak
var _music := {}  # area id -> AudioStreamPlayer
var _amb := {}
var _streams := {}  # name -> Array of AudioStream (the variants)
var _fall: AudioStreamPlayer
var _emitters: Array = []  # [AudioStreamPlayer3D, base db]
var _lowpass: AudioEffectLowPassFilter
var _on := false
var _duck := 0.0
var _pending: Array = []  # [time left, name, db]


func setup(p: Peak) -> void:
	peak = p
	process_mode = Node.PROCESS_MODE_ALWAYS
	if AudioServer.get_bus_index(BUS) < 0:
		AudioServer.add_bus()
		var i := AudioServer.bus_count - 1
		AudioServer.set_bus_name(i, BUS)
		AudioServer.set_bus_send(i, "Music" if AudioServer.get_bus_index("Music") >= 0 else "Master")
		_lowpass = AudioEffectLowPassFilter.new()
		_lowpass.cutoff_hz = 20500.0
		AudioServer.add_bus_effect(i, _lowpass)
	else:
		_lowpass = AudioServer.get_bus_effect(AudioServer.get_bus_index(BUS), 0)
	for id in p.meta.order:
		if str(id) == "st":
			continue
		var m := _loop_player(MUSIC_DIR + "peak_" + str(id) + ".ogg", BUS)
		if m != null:
			_music[str(id)] = m
		var a := _loop_player(SFX_DIR + "amb_" + str(id) + ".wav", "Effects")
		if a != null:
			_amb[str(id)] = a
	_fall = _loop_player(SFX_DIR + "fall_wind_loop.wav", "Effects")


static func _looped(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		return null
	var s: AudioStream = load(path)
	if s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = true
	elif s is AudioStreamWAV:
		var w := s as AudioStreamWAV
		var bytes := 2 if w.format == AudioStreamWAV.FORMAT_16_BITS else 1
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = w.data.size() / (bytes * (2 if w.stereo else 1))
	return s


func _loop_player(path: String, bus: String) -> AudioStreamPlayer:
	var s := _looped(path)
	if s == null:
		return null
	var pl := AudioStreamPlayer.new()
	pl.stream = s
	pl.bus = bus
	pl.volume_db = -80.0
	add_child(pl)
	return pl


func begin() -> void:
	_on = true
	_duck = 0.0
	Sound.music("")  # the menu's and the match's music stop: the mountain has its own
	for pl: AudioStreamPlayer in _music.values():
		pl.volume_db = -80.0
		pl.play()
	for pl: AudioStreamPlayer in _amb.values():
		pl.volume_db = -80.0
		pl.play(randf() * 3.0)
	if _fall != null:
		_fall.volume_db = -80.0
		_fall.play()
	for row in _emitters:
		(row[0] as AudioStreamPlayer3D).play()


func end() -> void:
	_on = false
	for pl: AudioStreamPlayer in _music.values():
		pl.stop()
	for pl: AudioStreamPlayer in _amb.values():
		pl.stop()
	if _fall != null:
		_fall.stop()
	for row in _emitters:
		(row[0] as AudioStreamPlayer3D).stop()
	if _lowpass != null:
		_lowpass.cutoff_hz = 20500.0
	_pending.clear()


func frame(delta: float, weights: Dictionary, fall_speed: float, _drop: float) -> void:
	if not _on:
		return
	# Under water while you fall: the music goes dull past 7 m/s down, and comes back.
	var want := clampf((fall_speed - 7.0) / 9.0, 0.0, 1.0)
	_duck = lerpf(_duck, want, 1.0 - exp(-delta * (5.0 if want > _duck else 1.2)))
	if _lowpass != null:
		_lowpass.cutoff_hz = lerpf(20500.0, 420.0, pow(_duck, 0.6))
	for id in _music:
		var w := float(weights.get(id, 0.0))
		(_music[id] as AudioStreamPlayer).volume_db = MUSIC_DB + linear_to_db(maxf(sqrt(w), 0.0001)) if w > 0.002 else -80.0
	for id in _amb:
		var w := float(weights.get(id, 0.0))
		(_amb[id] as AudioStreamPlayer).volume_db = AMB_DB + linear_to_db(maxf(sqrt(w), 0.0001)) if w > 0.002 else -80.0
	if _fall != null:
		var f := clampf((fall_speed - 3.0) / 22.0, 0.0, 1.0)
		_fall.volume_db = linear_to_db(maxf(f, 0.0001)) + 2.0 if f > 0.01 else -80.0
		_fall.pitch_scale = 0.75 + f * 0.9
	for i in range(_pending.size() - 1, -1, -1):
		_pending[i][0] = float(_pending[i][0]) - delta
		if float(_pending[i][0]) <= 0.0:
			var row: Array = _pending[i]
			_pending.remove_at(i)
			if str(row[1]) == "donkey":
				Sound.play("donkey", float(row[2]))
			else:
				play(str(row[1]), Vector2.INF, float(row[2]))


func _variants(name: String) -> Array:
	if _streams.has(name):
		return _streams[name]
	var out: Array = []
	if ResourceLoader.exists(SFX_DIR + name + ".wav"):
		out.append(load(SFX_DIR + name + ".wav"))
	for i in range(1, 9):
		var p := "%s%s_%02d.wav" % [SFX_DIR, name, i]
		if not ResourceLoader.exists(p):
			break
		out.append(load(p))
	_streams[name] = out
	return out


## A one-shot. `at` is in the course's metres (Vector2.INF: not placed, heard everywhere).
func play(name: String, at := Vector2.INF, db := 0.0, pitch := 1.0) -> void:
	if not _on:
		return
	var list := _variants(name)
	if list.is_empty():
		return
	var s: AudioStream = list[randi() % list.size()]
	if not at.is_finite():
		var pl := AudioStreamPlayer.new()
		pl.stream = s
		pl.bus = "Effects"
		pl.volume_db = db
		pl.pitch_scale = pitch
		add_child(pl)
		pl.finished.connect(pl.queue_free)
		pl.play()
		return
	var p3 := AudioStreamPlayer3D.new()
	p3.stream = s
	p3.bus = "Effects"
	p3.volume_db = db + 6.0
	p3.pitch_scale = pitch * randf_range(0.96, 1.04)
	p3.unit_size = 9.0
	p3.max_distance = 70.0
	p3.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	peak.add_child(p3)
	p3.position = Vector3(at.x, at.y, 0)
	p3.finished.connect(p3.queue_free)
	p3.play()


## A looping sound standing in the world (a waterfall, a wheel).
func emitter(name: String, at: Vector2, db := 0.0, reach := 40.0) -> void:
	var s := _looped(SFX_DIR + name + ".wav")
	if s == null:
		return
	var p3 := AudioStreamPlayer3D.new()
	p3.stream = s
	p3.bus = "Effects"
	p3.volume_db = db + 4.0
	p3.unit_size = reach * 0.3
	p3.max_distance = reach * 2.0
	peak.add_child(p3)
	p3.position = Vector3(at.x, at.y, 0)
	_emitters.append([p3, db])
	if _on:
		p3.play()


## You've landed after falling `drop` metres.
func landed(drop: float) -> void:
	play("land_thud_big", Vector2.INF, clampf(-6.0 + drop * 0.1, -6.0, 4.0))
	if drop >= 60.0:
		_pending.append([1.1, "peak_fall_wah", -2.0])
		_pending.append([3.0, "donkey", -14.0])
	elif drop >= 30.0:
		_pending.append([1.0, "peak_fall_wah", -8.0])


func finale() -> void:
	play("summit_bell", Vector2.INF, 2.0)
	_pending.append([1.4, "summit_bell", 0.0])
	_pending.append([2.2, "peak_summit_fanfare", 2.0])
	_pending.append([2.8, "summit_bell", -2.0])
