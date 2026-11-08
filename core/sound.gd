extends Node
## SOUND: buses, one-shot effects and the music. Autoload "Sound".
## Buses are built in code: Master > Music, Effects. Volumes save to options.cfg.

const SFX := {
	"grab": ["slap_1", "slap_2", "slap_3", "slap_4"],
	"grip": ["grip"],
	"strain": ["grunt_jump_1", "grunt_jump_2", "grunt_jump_3"],
	"thud": ["thud", "land_soft", "hit_flesh"],
	"hurt": ["hurt_1", "hurt_2", "hurt_3", "hurt_4"],
	"fall": ["yell_1", "yell_2", "yell_3"],
	"lock": ["lock_bell"],
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
	"title": "res://audio/music/top_dog_theme.ogg",
	"climb": "res://audio/music/desert_snake.wav",
}
const OPTIONS := "user://options.cfg"

var _streams := {}
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


func play(kind: String, volume_db := 0.0, pitch := 1.0) -> void:
	var list: Array = SFX.get(kind, [])
	if list.is_empty():
		return
	var s = _streams.get(list.pick_random())
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


## A positioned effect in the 3D world.
func play_at(kind: String, where: Vector3, volume_db := 0.0, parent: Node = null) -> void:
	var list: Array = SFX.get(kind, [])
	if list.is_empty():
		return
	var s = _streams.get(list.pick_random())
	if s == null:
		return
	var host: Node = parent if parent != null else get_tree().current_scene
	if host == null:
		play(kind, volume_db)
		return
	var p := AudioStreamPlayer3D.new()
	p.bus = "Effects"
	p.stream = s
	p.volume_db = volume_db
	p.pitch_scale = randf_range(0.92, 1.08)
	p.unit_size = 6.0
	host.add_child(p)
	p.global_position = where
	p.play()
	p.finished.connect(p.queue_free)


func music(id: String) -> void:
	if id == _music_id:
		return
	_music_id = id
	var path: String = MUSIC.get(id, "")
	if path == "" or not ResourceLoader.exists(path):
		_music.stop()
		return
	var st = load(path)
	if st is AudioStreamOggVorbis:
		st.loop = true
	_music.stream = st
	_music.play()


func set_volume(bus: String, v: float) -> void:
	volumes[bus] = clampf(v, 0.0, 1.0)
	var i := AudioServer.get_bus_index(bus)
	if i >= 0:
		AudioServer.set_bus_volume_db(i, linear_to_db(maxf(volumes[bus], 0.0001)))
		AudioServer.set_bus_mute(i, volumes[bus] <= 0.001)
	_save_options()


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
