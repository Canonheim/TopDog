class_name BootScreens
extends CanvasLayer
## THE BOOT SCREENS (Parker 11-11), after Godot's own splash and before the title:
## 1. the DANGADORF studio logo fades in, beats like a heart on its drums (lub-dub,
##    lub-dub), fades out;
## 2. a game pad and "THIS GAME IS BEST EXPERIENCED WITH A CONTROLLER" fade in
##    quickly, hold, fade out;
## 3. the black lifts off the title (in its PRESS ANY BUTTON TO START state).
## Any button at any time skips the rest straight to the title.
##
## Both cards are 3D kit models in a SubViewport with its own world, its own ink, a
## dark backdrop and its own light, so nothing of the plaza shows through.
## Their makers' pieces drop in by name (studio_logo, boot_pad, boot_controller_text);
## until then, plain stand-ins.

signal finished

const STUDIO_IN := 0.5
## A HEARTBEAT (Parker 11-12: "make the Dangadorf drum beat pulse more of a heartbeat
## cadence"): two hearts' beats at 60 a minute, each a deep strong LUB and, a quarter second
## on, a lighter higher DUB; then the long rest.
const HEART := [0.75, 1.75]  # each LUB, seconds after the start
const LUB_DUB := 0.27  # the DUB follows its LUB by this
const STUDIO_OUT_AT := 2.8  # (Parker 11-11: half a second longer)
const STUDIO_OUT := 0.45
const PAD_IN := 0.3  # "fades in quickly"
const PAD_HOLD := 2.9  # (Parker 11-11: a second longer)
const PAD_OUT := 0.4
const LIFT := 0.45  # the black lifting off the title
const PULSE := 1.06  # the word's scale at a beat's peak (the logo keeps its frame clear to 1.08)
const GEAR_RATIO := -16.0 / 12.0  # the copper gear (12 teeth) turns against the brass (16): they stay meshed

var _black: ColorRect
var _view: SubViewportContainer
var _vp: SubViewport
var _cam: Camera3D
var _studio: Node3D
var _studio_word: Node3D
var _gears: Array = []
var _pad: Node3D
var _pad_buttons: Array = []  # [node, rest z]: pressed in turn, as a pad in use
var _tween: Tween
var _skip: AnyPress
var _done := false
var _t := 0.0


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_black = ColorRect.new()
	_black.color = Color.BLACK
	_black.set_anchors_preset(Control.PRESET_FULL_RECT)
	_black.mouse_filter = Control.MOUSE_FILTER_STOP  # nothing under it is clickable yet
	add_child(_black)
	_view = SubViewportContainer.new()
	_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	_view.stretch = true
	_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_view.modulate.a = 0.0
	add_child(_view)
	_vp = SubViewport.new()
	_vp.own_world_3d = true
	_vp.transparent_bg = false
	# The game's own AA (FXAA, no MSAA): the house ink is built for it, and under
	# MSAA it never drew here (Parker 11-11: "make sure our outline shader hits the
	# new screens").
	_vp.msaa_3d = Viewport.MSAA_DISABLED
	_vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	_view.add_child(_vp)
	_build_stage()
	_skip = AnyPress.new()
	_skip.delay = 0.15
	_skip.pressed.connect(skip)
	add_child(_skip)
	_run()


func _build_stage() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.035, 0.03, 0.03)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.8, 0.78, 0.76)
	e.ambient_light_energy = 0.6
	e.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.environment = e
	_vp.add_child(env)
	var key := DirectionalLight3D.new()
	key.light_energy = 1.3
	key.rotation_degrees = Vector3(-28, 28, 0)
	_vp.add_child(key)
	var rim := DirectionalLight3D.new()
	rim.light_energy = 0.5
	rim.light_color = Color(1.0, 0.82, 0.6)  # a warm brass back light
	rim.rotation_degrees = Vector3(-15, 200, 0)
	_vp.add_child(rim)
	_cam = Camera3D.new()
	_cam.fov = 30.0
	_cam.position = Vector3(0, 0, 11.0)
	_cam.current = true
	_vp.add_child(_cam)
	CelPass.add_viewport_outlines(_cam)
	# 1. the studio logo
	_studio = LuchaKit.kit_model("studio_logo")
	if _studio != null:
		_studio.scale = Vector3.ONE * 1.25  # built 4.1 m wide
		_studio_word = _studio.find_child("studio_logo_word", true, false) as Node3D
		for g in 4:
			var gear := _studio.find_child("studio_logo_gear_%d" % g, true, false) as Node3D
			if gear != null:
				_gears.append(gear)
	else:
		_studio = _stand_in_studio()
	if _studio_word == null:
		_studio_word = _studio  # the whole crest pulses then
	_studio.visible = false
	_vp.add_child(_studio)
	# 2. the controller card
	_pad = Node3D.new()
	var model := LuchaKit.kit_model("boot_pad")
	if model != null:
		model.scale = Vector3.ONE * 1.3  # built 2.06 m wide (re-cut 11-11: room round every control)
		for b in 4:
			var btn := model.find_child("boot_pad_btn_%d" % b, true, false) as Node3D
			if btn != null:
				_pad_buttons.append([btn, btn.position.z])
	else:
		model = _stand_in_pad()
	model.position = Vector3(0, 0.6, 0)
	_pad.add_child(model)
	var words := LuchaKit.kit_model("boot_controller_text")
	if words == null:
		words = Node3D.new()
		for i in 2:
			var line := LuchaKit.poster_text(["THIS GAME IS BEST EXPERIENCED", "WITH A CONTROLLER"][i], 0.34, LuchaKit.CREAM, LuchaKit.INK, 0.05)
			line.position = Vector3(0, -0.45 * i, 0)
			LuchaKit.center_digits(line)
			words.add_child(line)
	words.position = Vector3(0, -1.35, 0)
	if LuchaKit.kit_model_exists("boot_controller_text"):
		words.scale = Vector3.ONE * 1.5  # built 2.82 m wide, at the pad's own size
	_pad.add_child(words)
	_pad.visible = false
	_vp.add_child(_pad)


## The run: one tween, so a skip just kills it.
func _run() -> void:
	_tween = create_tween()
	_tween.tween_callback(func(): _studio.visible = true)
	_tween.tween_property(_view, "modulate:a", 1.0, STUDIO_IN)
	var at := STUDIO_IN
	for lub: float in HEART:
		_tween.tween_interval(lub - at)
		_tween.tween_callback(_beat.bind(true))
		_tween.tween_interval(LUB_DUB)
		_tween.tween_callback(_beat.bind(false))
		at = lub + LUB_DUB
	_tween.tween_interval(STUDIO_OUT_AT - at)
	_tween.tween_property(_view, "modulate:a", 0.0, STUDIO_OUT)
	_tween.tween_callback(func():
		_studio.visible = false
		_pad.visible = true)
	_tween.tween_property(_view, "modulate:a", 1.0, PAD_IN)
	_tween.tween_interval(PAD_HOLD)
	_tween.tween_property(_view, "modulate:a", 0.0, PAD_OUT)
	_tween.tween_callback(_lift)


var _beat_tw: Tween
var _word_home := Vector3.ZERO


## One beat of the heart. The LUB is the deep drum (46 Hz), loud, and the word swells to
## its full pulse; the DUB is the higher drum (79 Hz), softer, a smaller swell on top of
## the first one's fall, and then it settles through the rest.
func _beat(lub: bool) -> void:
	Sound.play("boot_drum_2" if lub else "boot_drum_1", 1.5 if lub else -5.0, 1.0 if lub else 1.12)
	var w := _studio_word
	if _word_home == Vector3.ZERO:
		_word_home = w.scale
	if _beat_tw != null and _beat_tw.is_valid():
		_beat_tw.kill()
	_beat_tw = create_tween()
	if lub:
		_beat_tw.tween_property(w, "scale", _word_home * (PULSE + 0.02), 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_beat_tw.tween_property(w, "scale", _word_home * 1.015, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		_beat_tw.tween_property(w, "scale", _word_home * (1.0 + (PULSE - 1.0) * 0.6), 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_beat_tw.tween_property(w, "scale", _word_home, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


## Any button: straight to the title.
func skip() -> void:
	if _done:
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_view, "modulate:a", 0.0, 0.15)
	_tween.tween_callback(_lift)


## The title shows under the black, and the black lifts.
func _lift() -> void:
	if _done:
		return
	_done = true
	_skip.queue_free()
	_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	finished.emit()
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tw := create_tween()
	tw.tween_property(_black, "modulate:a", 0.0, LIFT)
	tw.tween_callback(queue_free)


func _process(delta: float) -> void:
	_t += delta
	for i in _gears.size():
		(_gears[i] as Node3D).rotation.z = _t * 0.9 * (1.0 if i % 2 == 0 else GEAR_RATIO)
	if _pad.visible:
		_pad.rotation.y = sin(_t * 1.1) * 0.08
		_pad.rotation.x = sin(_t * 0.8) * 0.04
		# The face buttons press one after another (0.02 m in, as built).
		for i in _pad_buttons.size():
			var b: Array = _pad_buttons[i]
			var down := fposmod(_t * 2.2 - i * 0.5, 2.0) < 0.22
			(b[0] as Node3D).position.z = float(b[1]) - (0.02 if down else 0.0)


# ---------------------------------------------------------------- stand-ins

func _stand_in_studio() -> Node3D:
	var root := Node3D.new()
	var brass := Color("#B8862E")
	var copper := Color("#A4552A")
	for g in 2:
		var gear := Node3D.new()
		gear.position = Vector3(-1.9 + g * 3.8, 0.35 - g * 0.7, -0.35)
		var r := 0.95 - g * 0.25
		var disc := LuchaKit.cyl(r, 0.14, copper if g == 0 else brass, Vector3.ZERO)
		disc.rotation.x = PI * 0.5
		gear.add_child(disc)
		for k in 10:
			var a := k * TAU / 10.0
			var tooth := LuchaKit.box(Vector3(0.24, 0.3, 0.14), copper if g == 0 else brass, Vector3(cos(a) * r, sin(a) * r, 0))
			tooth.rotation.z = a
			gear.add_child(tooth)
		root.add_child(gear)
		_gears.append(gear)
	var plate := LuchaKit.box(Vector3(4.6, 1.1, 0.16), Color("#3A2A1E"), Vector3(0, 0, -0.12))
	root.add_child(plate)
	var word := LuchaKit.poster_text("DANGADORF", 0.62, brass, LuchaKit.INK, 0.12)
	LuchaKit.center_digits(word)
	var holder := Node3D.new()
	holder.add_child(word)
	root.add_child(holder)
	_studio_word = holder
	return root


func _stand_in_pad() -> Node3D:
	var root := Node3D.new()
	var body := Color("#2C2C34")
	root.add_child(LuchaKit.box(Vector3(1.7, 0.75, 0.32), body, Vector3.ZERO))
	for s in [-1, 1]:
		var grip := LuchaKit.box(Vector3(0.45, 0.8, 0.3), body, Vector3(s * 0.68, -0.38, 0))
		grip.rotation.z = s * 0.35
		root.add_child(grip)
		var stick := LuchaKit.cyl(0.12, 0.12, Color("#55555F"), Vector3(s * 0.32, -0.18, 0.2))
		stick.rotation.x = PI * 0.5
		root.add_child(stick)
		root.add_child(LuchaKit.box(Vector3(0.42, 0.1, 0.26), Color("#45454F"), Vector3(s * 0.55, 0.42, 0)))
	root.add_child(LuchaKit.box(Vector3(0.09, 0.27, 0.06), Color("#55555F"), Vector3(-0.52, 0.12, 0.18)))
	root.add_child(LuchaKit.box(Vector3(0.27, 0.09, 0.06), Color("#55555F"), Vector3(-0.52, 0.12, 0.18)))
	var cols := [Color("#3FA34D"), Color("#D1362F"), Color("#2F6FD1"), Color("#E8B923")]
	var at := [Vector2(0, -0.11), Vector2(0.11, 0), Vector2(-0.11, 0), Vector2(0, 0.11)]
	for i in 4:
		var b := LuchaKit.cyl(0.055, 0.06, cols[i], Vector3(0.52 + at[i].x, 0.12 + at[i].y, 0.18))
		b.rotation.x = PI * 0.5
		root.add_child(b)
	return root
