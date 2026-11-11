extends Node
## SOUND: buses, one-shot effects and the music. Autoload "Sound".
## Buses are built in code: Master > Music, Effects. Volumes save to options.cfg.

const RARE_GRAB := "grab_slap_10"
const SFX := {
	"donkey": ["donkey_natural_02", "donkey_natural_03"],
	"knockout": ["knockout_grunt_01", "knockout_oof_01", "knockout_oof_02", "knockout_oof_03", "knockout_oof_04"],
	"bubble_pop": ["bubble_pop_01", "bubble_pop_02", "bubble_pop_03"],
	"chair_light": ["big_slam_01", "big_slam_02"],
	"chair_heavy": ["big_slam_03", "big_slam_04"],
	"chair_break": ["chair_break_01", "chair_break_02", "chair_break_03", "chair_break_04", "chair_break_05", "chair_break_06"],
	"grab": [
		"grab_slap_01", "grab_slap_02", "grab_slap_03", "grab_slap_05", "grab_slap_06",
		"grab_slap_07", "grab_slap_08", "grab_slap_09", RARE_GRAB, "grab_slap_11",
		"grab_slap_12", "grab_slap_13", "grab_slap_14", "grab_slap_15", "grab_slap_16",
		"grab_slap_17", "grab_slap_18", "grab_slap_19", "grab_slap_20",
	],
	"grip": ["grip"],
	"strain": [
		"dog_exertion_02", "dog_exertion_03", "dog_exertion_04", "dog_exertion_05",
		"dog_exertion_07", "dog_exertion_08", "dog_exertion_09", "dog_exertion_10",
		"dog_exertion_11", "dog_exertion_12", "dog_exertion_13", "dog_exertion_14",
		"dog_exertion_15", "dog_exertion_16", "dog_exertion_17", "dog_exertion_18",
	],
	"thud": ["thud", "land_soft", "hit_flesh"],
	"splash": ["splash_big", "leap_splash"],  # Golemheim's (Del Mar: a body into the sea)
	"splash_small": ["splash_step_1", "splash_step_2", "splash_step_3"],
	"rope": ["rope_tension_01", "rope_tension_02", "rope_tension_03", "rope_tension_04", "rope_tension_05"],
	"hurt": ["hurt_1", "hurt_2", "hurt_3", "hurt_4"],
	"fall": ["yell_1", "yell_2", "yell_3"],
	"lock": ["lock_bell"],
	"boot_drum_1": ["boot_drum_1"],  # the studio logo's two beats (the boot screens)
	"boot_drum_2": ["boot_drum_2"],
	"church_bell": ["bell_tower_ring_01", "bell_tower_ring_02", "bell_tower_ring_03", "bell_tower_ring_04", "bell_tower_ring_05", "bell_tower_ring_06", "bell_tower_ring_07", "bell_tower_ring_08", "bell_single_11", "bell_single_12", "bell_single_13", "bell_single_14", "bell_single_15"],
	"tick": ["clock_tick"],
	"clap": ["clap_1", "clap_2"],
	"win": ["match_victory"],
	"out": ["match_defeat"],
	"ui_click": ["ui_click"],
	"ui_hover": ["ui_hover"],
	"ui_open": ["ui_open"],
	"ui_close": ["ui_close"],
}
const MUSIC := {
	"title": "res://audio/music/top_dog_ring_rally_relaxed_2min.wav",
	"climb": "res://audio/music/desert_snake.wav",
}
const OPTIONS := "user://options.cfg"

var _streams := {}
var _grab_bag: Array = []
var _last_grab := ""
var _pool: Array = []
var _pool3d: Array = []
var _music: AudioStreamPlayer
var _music_id := ""
var volumes := {"Master": 0.4, "Music": 0.6, "Effects": 0.9}  # Master defaults to 40% (Parker, 2026-11-07)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for bus in ["Music", "Effects"]:
		if AudioServer.get_bus_index(bus) == -1:
			AudioServer.add_bus()
			var i := AudioServer.bus_count - 1
			AudioServer.set_bus_name(i, bus)
			AudioServer.set_bus_send(i, "Master")
	for k in SFX:
		for f in SFX[k]:
			var path := "res://audio/sfx/%s.wav" % f
			if ResourceLoader.exists(path):
				_streams[f] = load(path)
	for i in 12:
		var p := AudioStreamPlayer.new()
		p.bus = "Effects"
		add_child(p)
		_pool.append(p)
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	add_child(_music)
	_load_options()


func _pick_stream(kind: String, clips: Array) -> AudioStream:
	if kind == "grab":
		return _streams[pick_grab()]
	return _streams.get(clips.pick_random())


func pick_grab() -> String:
	if randi_range(1, 100) == 1:
		return RARE_GRAB
	if _grab_bag.is_empty():
		_grab_bag = SFX["grab"].duplicate()
		_grab_bag.erase(RARE_GRAB)
		_grab_bag.shuffle()
		if _grab_bag.back() == _last_grab:
			_grab_bag.push_front(_grab_bag.pop_back())
	_last_grab = _grab_bag.pop_back()
	return _last_grab


func play(kind: String, volume_db := 0.0, pitch := 1.0) -> void:
	var list: Array = SFX.get(kind, [])
	if list.is_empty():
		return
	var s = _pick_stream(kind, list)
	if s == null:
		return
	for p in _pool:
		var pl: AudioStreamPlayer = p
		if not pl.playing:
			pl.stream = s
			pl.volume_db = volume_db
			pl.pitch_scale = pitch * randf_range(0.94, 1.06)
			pl.play()
			return


func play_exertion(clip: String, head: Node3D) -> void:
	if clip not in SFX["strain"] or Time.get_ticks_msec() < int(head.get_meta("grunt_block_until", 0)):
		return
	var player := contact_player(_streams[clip], 1.0, head)
	player.set_meta("exertion_voice", true)
	player.finished.connect(player.queue_free)
	player.play()


func stop_exertion(head: Node3D) -> void:
	# Applied on each listener, including puppets whose local KO timer is not updated.
	head.set_meta("grunt_block_until", Time.get_ticks_msec() + 1600)
	for child in head.get_children():
		if child is AudioStreamPlayer3D and child.has_meta("exertion_voice"):
			child.stop()
			child.queue_free()


func play_grab(clip: String, at: Vector3, pitch: float, host: Node) -> void:
	if clip not in SFX["grab"]:
		return
	var player := contact_player(_streams[clip], pitch, host)
	player.global_position = at
	player.finished.connect(player.queue_free)
	player.play()


func contact_player(stream: AudioStream, pitch: float, host: Node) -> AudioStreamPlayer3D:
	var player := AudioStreamPlayer3D.new()
	player.bus = "Effects"
	player.stream = stream
	player.volume_db = -4.0 + linear_to_db(10.5)
	player.max_db += linear_to_db(8.4)
	player.unit_size = 6.0
	player.pitch_scale = pitch
	host.add_child(player)
	return player


## A positioned effect in the 3D world.
func play_at(kind: String, where: Vector3, volume_db := 0.0, parent: Node = null, clip := "") -> AudioStreamPlayer3D:
	var list: Array = SFX.get(kind, [])
	if list.is_empty():
		return null
	var s = _pick_stream(kind, list) if clip.is_empty() else _streams.get(clip)
	if s == null or (not clip.is_empty() and clip not in list):
		return null
	var chair_boost_db := linear_to_db(5.0) if kind in ["chair_light", "chair_heavy", "chair_break"] else 0.0
	if kind == "chair_heavy":
		chair_boost_db += linear_to_db(1.2)
	if kind == "bubble_pop":
		chair_boost_db += linear_to_db(3.0)
	if kind in ["church_bell", "donkey"]:
		chair_boost_db += linear_to_db(2.0)
	if kind == "knockout":
		# Match measured short-block loudness to the two big slams, with their 6x gain.
		var trims := {"knockout_grunt_01": 1.9132}
		var selected: String = s.resource_path.get_file().get_basename()
		chair_boost_db += linear_to_db(6.0) + float(trims.get(selected, 0.0))
	volume_db += chair_boost_db
	var host: Node = parent if parent != null else get_tree().current_scene
	if host == null:
		play(kind, volume_db)
		return null
	var p := AudioStreamPlayer3D.new()
	p.bus = "Effects"
	p.stream = s
	p.volume_db = volume_db
	p.max_db += chair_boost_db
	p.pitch_scale = randf_range(0.92, 1.08) if clip.is_empty() else 1.0
	p.unit_size = 6.0
	if kind in ["church_bell", "donkey"]:
		p.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
		p.max_db += maxf(0.0, volume_db - chair_boost_db)  # Allow the chair-only bell boost.
	if kind == "grab":
		p.max_db += linear_to_db(8.4)  # Preserve the gain increase at close range.
	host.add_child(p)
	p.global_position = where
	p.play()
	p.finished.connect(p.queue_free)
	return p


var _music_streams := {}
var _save_due := false


func music(id: String) -> void:
	if id == _music_id:
		return
	_music_id = id
	var path: String = MUSIC.get(id, "")
	if path == "" or not ResourceLoader.exists(path):
		_music.stop()
		return
	# Both tracks stay loaded once heard: the 8 MB climb track was re-read from disk at
	# every match start.
	if not _music_streams.has(path):
		_music_streams[path] = load(path)
	var st = _music_streams[path]
	if st is AudioStreamOggVorbis:
		st.loop = true
	# Match climb (-22.0073 LUFS) to title (-16.3000 LUFS), then apply the shared 15% boost.
	_music.volume_db = linear_to_db(1.15) + (5.7073 if id == "climb" else 0.0)
	_music.stream = st
	_music.play()


func set_volume(bus: String, v: float) -> void:
	volumes[bus] = clampf(v, 0.0, 1.0)
	var i := AudioServer.get_bus_index(bus)
	if i >= 0:
		AudioServer.set_bus_volume_db(i, linear_to_db(maxf(volumes[bus], 0.0001)))
		AudioServer.set_bus_mute(i, volumes[bus] <= 0.001)
	# A dragged fader calls this every mouse move: one save half a second after the last.
	if not _save_due and is_inside_tree():
		_save_due = true
		get_tree().create_timer(0.5, true, false, true).timeout.connect(func() -> void:
			_save_due = false
			_save_options())


func _load_options() -> void:
	var cf := ConfigFile.new()
	if cf.load(OPTIONS) == OK:
		for b in volumes:
			volumes[b] = float(cf.get_value("audio", b, volumes[b]))
	for b in volumes:
		var i := AudioServer.get_bus_index(b)
		if i >= 0:
			AudioServer.set_bus_volume_db(i, linear_to_db(maxf(volumes[b], 0.0001)))


func _save_options() -> void:
	var cf := ConfigFile.new()
	cf.load(OPTIONS)
	for b in volumes:
		cf.set_value("audio", b, volumes[b])
	cf.save(OPTIONS)
