extends Node
## MAIN: the app. Builds the world (sky, sun, stage, camera), holds the one Game
## node (at /root/Main/Game on every machine, so its RPCs line up), and runs the
## screens: title, local play, online, lobby, the match HUD, results, pause,
## controls, options and the F1 feel panel. All screen UI, built in code.

const UiKit := preload("res://ui/ui_kit.gd")
const GameScript := preload("res://game/game.gd")
const Layout := preload("res://climber/body_layout.gd")
const PadNavScript := preload("res://ui/pad_nav.gd")

# Keep each simulation step the same length and schedule fewer steps per real second.
const MATCH_PACE := 0.8
var _original_hz := 0
var _original_speed := 1.0

var world: Node3D
var game: Game
var cam: Camera3D
var ui: CanvasLayer
var screens := {}
var screen := ""
var banner: Label
var banner_t := 0.0
var hud_clock: Label
var hud_info: Label
var hud_hint: Label
var line_bar: MeshInstance3D
var local_mode := true  # this match was started from Local play
var paused := false
var feel_panel: Control
const PODIUM_HOLD_SECONDS := 2.5
const TOWER_PAN_SPEED := 0.7  # world metres per second
var _results_elapsed := 0.0
var _results_peak := Vector2.ZERO
var _cam_target := Vector3(0, 2, 14)
var _cam_fov := 34.0
const FOLLOW_HALF_H := 2.05  # in play: the camera shows at least this many metres above and below you
var _last_tick_s := -1
var _lobby_back := "online"
var _lobby_list: VBoxContainer
var _online_status: Label
var _lobby_members: VBoxContainer
var _lobby_chat: RichTextLabel
var _lobby_status: Label
var _local_list: VBoxContainer
var _settings_box: Dictionary = {}
var _results_label: Label
var _rebind_wait := {}  # {"scheme", "action", "index", "button"}
var pad_nav: Node
var lucha: LuchaUI  # Top Dog's 3D front end (ui3d/lucha_ui.gd)
var _pad_readout: Label
var _pad_corner: Label
var _build_tag: Label  # "BUILD x.y.z" in the title's corner (Parker 11-07: know which build you booted)


func _ready() -> void:
	get_tree().auto_accept_quit = false  # the X button runs quit_game too
	# THE PAUSE LAW: the tree pauses the WORLD and the GAME only. Main, its menus,
	# Players and PadNav keep running, or the pause menu can't be clicked and the
	# pause button can't unpause (0.1.2: "quit to menu doesn't work").
	process_mode = Node.PROCESS_MODE_ALWAYS
	_input_defaults()
	_build_world()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	game = GameScript.new()
	game.name = "Game"
	game.world = world
	game.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(game)
	game.announce.connect(_on_announce)
	game.phase_changed.connect(_on_phase)
	game.match_over.connect(_on_over)
	game.climber_spawned.connect(_on_spawned)
	game.host_left.connect(func(): _to_title("The host left the game."))
	Players.camera = cam
	_build_ui()
	Net.session_started.connect(_on_session_started)
	Net.session_ended.connect(func(r): _to_title(r))
	Net.status.connect(func(t):
		if _online_status: _online_status.text = t
		if _lobby_status: _lobby_status.text = t)
	Net.members_changed.connect(_refresh_lobby)
	Net.chat_line.connect(_on_chat)
	Net.settings_changed.connect(_refresh_lobby)
	Net.lobby_list.connect(_fill_lobby_list)
	Players.joined.connect(func(_s): _refresh_local(); Net.update_local_players())
	game.stage = Stage.new("plaza")
	game.stage.build(world, true)
	lucha = LuchaUI.new()
	lucha.name = "LuchaUI"
	add_child(lucha)
	lucha.setup(self)
	show_screen("title")
	if "--demo" in OS.get_cmdline_user_args():
		call_deferred("_demo")
	if "--demo-heap" in OS.get_cmdline_user_args():
		call_deferred("_demo_heap")
	for a2 in OS.get_cmdline_user_args():
		if a2.begins_with("--demo-drag="):
			call_deferred("_demo_drag", a2.get_slice("=", 1))
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shot="):
			_shot(a.get_slice("=", 1))


## Screenshot hook: --shot=PATH[,SECONDS] saves the window to PATH and quits.
func _shot(spec: String) -> void:
	var parts := spec.split(",")
	var wait := float(parts[1]) if parts.size() > 1 else 4.0
	await get_tree().create_timer(wait).timeout
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(parts[0])
	print("SHOT ", parts[0])
	quit_game()  # through the real quit path, so a run with --shot also proves the exit


## Screenshot hook: --demo-heap drops knights on the barrel and freezes each,
## the way a tower builds up over a match.
func _demo_heap() -> void:
	_demo()
	var ClimberScript := load("res://climber/climber.gd")
	var Drivers := load("res://climber/drivers.gd")
	var top := game.stage.barrel_top
	for n in 6:
		var c: Climber = ClimberScript.new()
		c.climber_id = 900 + n
		c.tint = NameGen.tint(n + 1)
		add_child(c)
		c.build(Vector2(randf_range(-0.6, 0.6), top + 0.3), world, Game.KNIGHT)
		c.driver = Drivers.ScriptDriver.new()
		await get_tree().create_timer(1.1).timeout
		c.freeze()
		top = maxf(top, c.top_height())
		game.line = top


## Comparison hook: --demo-drag=DIR plays the same moves made on the reference game
## (hold the left hand with the cursor up-left; then the right hand far up-right;
## then the left foot out to the side) with a script inside the game, and saves a
## frame every 0.5 s to DIR. No keys go through Windows.
func _demo_drag(dir: String) -> void:
	_demo()
	await get_tree().create_timer(1.2).timeout
	var c: Climber = null
	for cl in game.live_climbers():
		c = cl
	if c == null:
		return
	var D = load("res://climber/drivers.gd")
	var d = D.ScriptDriver.new()
	c.driver = d
	var plan := [
		[0.0, func(): d.point_limb(0, true, c.limb_root(0) + Vector2(-0.55, 0.55))],
		[2.0, func(): d.set_limb(0, false)],
		[2.5, func(): d.point_limb(1, true, c.limb_root(1) + Vector2(2.6, 1.8))],
		[5.0, func(): d.set_limb(1, false)],
		[5.5, func(): d.point_limb(2, true, c.limb_root(2) + Vector2(-0.7, -0.25))],
		[7.7, func(): d.set_limb(2, false)],
	]
	var t := 0.0
	var k := 0
	var shot := 0
	while t < 9.0:
		while k < plan.size() and t >= float(plan[k][0]):
			(plan[k][1] as Callable).call()
			k += 1
		await RenderingServer.frame_post_draw
		if int(t * 2.0) >= shot:
			get_viewport().get_texture().get_image().save_png("%s/drag_%02d.png" % [dir, shot])
			shot += 1
		t += get_process_delta_time()
	print("DEMO-DRAG done, %d frames" % shot)
	quit_game()


## A battery/screenshot hook: two local bots on the barrel, no menus.
func _demo() -> void:
	Players.clear_players()
	Players.add_player(Players.ANY, "Parker the Barrel-Hugger")
	local_mode = true
	game.host_start({"mode": "scramble", "timer": 60.0, "spawn": "alternate", "stage": "plaza"},
		[{"pid": 0, "name": Players.slots[0].name, "tint": Players.slots[0].tint, "peer": 1, "slot": 0}])
	show_screen("hud")


## Menus: PadNav (ui/pad_nav.gd) reads every pad directly and drives ui_* itself.
func _input_defaults() -> void:
	pad_nav = PadNavScript.new()
	pad_nav.name = "PadNav"
	add_child(pad_nav)
	pad_nav.back_pressed.connect(_back)


# ================================================================ the world

func _build_world() -> void:
	world = Node3D.new()
	world.name = "World"
	add_child(world)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	# A bright cartoon sea-adventure blue (Parker 11-07): deep clean blue overhead,
	# lighter toward the horizon, no grey haze.
	sm.sky_top_color = Color("#1E6BFF")
	sm.sky_horizon_color = Color("#8FD0FF")
	sm.ground_horizon_color = Color("#8FD0FF")
	sm.ground_bottom_color = Color("#1E5FD0")
	sm.sky_curve = 0.12
	sm.sun_angle_max = 20.0
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	# The matte cel look (Parker 11-07: "so much bloom"): NO GLOW, no fog, ambient
	# from a light grey half mixed with the sky (Golemheim's island). Linear, not
	# Golemheim's AgX: AgX drained the poster reds, golds and the cartoon sky.
	e.ambient_light_color = Color(0.85, 0.845, 0.853)
	e.ambient_light_sky_contribution = 0.5
	e.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	e.fog_enabled = false
	e.glow_enabled = false
	env.environment = e
	add_child(env)
	CelPass.add_outline_pass(self)  # the house ink (Forward+ only; headless runs get none)
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 60.0
	sun.rotation_degrees = Vector3(-38, 35, 0)  # from the front-left: side light that shows the knights' volume
	add_child(sun)
	cam = Camera3D.new()
	cam.fov = _cam_fov
	cam.position = _cam_target
	cam.current = true
	add_child(cam)
	# The line: a bright bar across the deck (unshaded, no emission), and its label.
	line_bar = MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(30, 0.035, 0.05)
	line_bar.mesh = bm
	var lm := StandardMaterial3D.new()
	lm.albedo_color = Color(1.0, 0.85, 0.25)
	lm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	line_bar.material_override = lm
	line_bar.position = Vector3(0, 1.6, 0.35)
	world.add_child(line_bar)


func _process(delta: float) -> void:
	_tick_camera(delta)
	_tick_hud(delta)
	for cid in game.climbers:
		var climber: Climber = game.climbers[cid]
		climber.set_glyphs_visible(screen != "pause")
	if screen == "local":
		var dev := Players.poll_join()
		if dev != -2:
			Players.add_player(dev)
	if screen == "lobby":
		var dev2 := Players.poll_join()
		if dev2 != -2 and Players.slots.size() < 4:
			Players.add_player(dev2)
	for s in Players.slots.size():
		if Players.pause_pressed(s) and screen in ["hud", "pause"]:
			_toggle_pause()
	if _build_tag != null:
		_build_tag.visible = screen == "title"
	if _pad_corner != null:
		_pad_corner.visible = screen not in ["hud", "pause"]
		if _pad_corner.visible:
			_pad_corner.text = pad_nav.readout()
	if _pad_readout != null and screen == "controls":
		var hint := ""
		if pad_nav.last_pad < 0 and not Input.get_connected_joypads().is_empty():
			hint = "
A pad is connected but nothing has arrived. If pressing changes nothing here, something outside the game (Steam Input's desktop layout, or another app) is holding the pad: try closing Steam, or add the game to Steam and launch it from there."
		_pad_readout.text = pad_nav.readout() + hint


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F1:
		feel_panel.visible = not feel_panel.visible
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE 			and _rebind_wait.is_empty() and screen not in ["hud", "pause"]:
		_back()
	if event is InputEventKey and event.pressed and not event.echo and pad_nav != null 			and event.physical_keycode in [KEY_UP, KEY_DOWN, KEY_TAB]:
		pad_nav.ensure_focus()
	if not _rebind_wait.is_empty():
		_capture_bind(event)


# ---------------------------------------------------------------- camera

func _tick_camera(delta: float) -> void:
	if screen == "results":
		_results_elapsed += delta / Engine.time_scale
		var start := Vector2(0, 1.5)
		var end := Vector2(_results_peak.x, maxf(start.y, _results_peak.y))
		var distance := maxf(0.0, _results_elapsed - PODIUM_HOLD_SECONDS) * TOWER_PAN_SPEED
		var focus := start.move_toward(end, distance)
		# Leave the left side of the frame free for the results and menu.
		cam.position = Vector3(focus.x - 1.45, focus.y + 0.5, 9.0)
		cam.look_at(Vector3(cam.position.x, focus.y, 0), Vector3.UP)
		line_bar.visible = false
		return
	var live := game.live_climbers()
	var top := 1.6
	if game.stage != null and (live.is_empty() or game.phase == "idle"):
		top = game.tower_top()
	var line_y := top if game.phase == "idle" else game.line
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	# THE FOLLOW CAMERA (Parker 11-07: "it looks at you, not at you and the whole
	# structure", as the reference game does): in play the camera frames only the
	# live climbers, close. With nobody live (menus, between turns) it frames the
	# tower top and the line as before, so the 3D menus riding the camera stay put.
	var follow := not live.is_empty() and game.phase in ["turn", "round"]
	for climber: Climber in live:
		var point := climber.centre_of_mass()
		lo = lo.min(point)
		hi = hi.max(point)
	if live.is_empty():
		lo = Vector2(0, top)
		hi = lo
	if not follow:
		for point in [Vector2(-2.0, maxf(0.0, line_y - 3.0)), Vector2(2.0, line_y + 0.8)]:
			lo = lo.min(point)
			hi = hi.max(point)
	if follow:
		lo -= Vector2(1.2, 1.15)
		hi += Vector2(1.2, 1.35)
	else:
		lo -= Vector2(1.6, 1.0)
		hi += Vector2(1.6, 1.4)
	var centre := (lo + hi) * 0.5
	var aspect := 16.0 / 9.0
	if get_viewport() != null:
		var vs := get_viewport().get_visible_rect().size
		aspect = vs.x / maxf(vs.y, 1.0)
	var half_h := maxf((hi.y - lo.y) * 0.5, (hi.x - lo.x) * 0.5 / aspect)
	half_h = maxf(half_h, FOLLOW_HALF_H if follow else 3.2)
	var dist := half_h / tan(deg_to_rad(_cam_fov * 0.5))
	_cam_target = Vector3(centre.x, centre.y + 0.3, dist)
	cam.position = cam.position.lerp(_cam_target, 1.0 - exp(-delta * 2.5))
	cam.look_at(Vector3(cam.position.x, cam.position.y - 0.3, 0.0), Vector3.UP)
	line_bar.position.y = lerpf(line_bar.position.y, line_y, 1.0 - exp(-delta * 8.0))
	line_bar.visible = game.phase in ["turn", "round", "between"]


# ---------------------------------------------------------------- HUD

func _tick_hud(delta: float) -> void:
	banner_t -= delta
	if banner:
		banner.modulate.a = clampf(banner_t, 0.0, 1.0)
	if screen != "hud" and screen != "pause":
		return
	var info := ""
	match game.phase:
		"turn":
			var pid: int = game.turn_order[game.turn_i] if game.turn_i >= 0 else -1
			info = "%s climbing" % game.player_name(pid)
		"round":
			info = "Round %d  -  %d climbing" % [game.round_n, game.alive_pids().size() - game.locked.size()]
		"between":
			info = "Get ready..."
	if game.practice:
		info += "   (Practice)"
	hud_info.text = info
	if game.phase in ["turn", "round"] and not game.practice:
		var s := int(ceil(game.clock))
		hud_clock.text = "%d" % maxi(s, 0)
		hud_clock.modulate = Color(1, 0.35, 0.3) if game.clock <= 10.0 else Color.WHITE
		if s != _last_tick_s and s <= 5 and s >= 1:
			Sound.play("tick")
		_last_tick_s = s
	else:
		hud_clock.text = ""
	# The lock-in hint for local climbers above the line.
	var hint := ""
	for c in game.live_climbers():
		var cl: Climber = c
		if cl.owner_peer == game.me() and cl.top_height() > game.line + Game.LOCK_MARGIN and cl.touches_solid():
			hint = "Above the line! Lock in: Space / Start"
			break
	hud_hint.text = hint


func _on_spawned(c: Climber) -> void:
	c.froze.connect(func(_cl): Sound.play("thud", -6.0))


func _on_announce(text: String, big: bool) -> void:
	if banner == null:
		return
	banner.text = text
	banner.add_theme_font_size_override("font_size", 72 if big else 44)
	banner_t = 2.6 if big else 2.0
	if text.contains("locked in") or text.contains("made it"):
		Sound.play("lock")
	elif text.contains("is out"):
		Sound.play("out", -6.0)
	elif text.contains("fell off"):
		Sound.play("fall")
	elif text.contains("turn") or text.begins_with("Round"):
		Sound.play("clap")


func _set_match_pace(active: bool) -> void:
	if active and _original_hz == 0:
		_original_hz = Engine.physics_ticks_per_second
		_original_speed = Engine.time_scale
		var match_hz := maxi(1, roundi(_original_hz * MATCH_PACE))
		Engine.physics_ticks_per_second = match_hz
		Engine.time_scale = _original_speed * match_hz / _original_hz
	elif not active and _original_hz > 0:
		Engine.physics_ticks_per_second = _original_hz
		Engine.time_scale = _original_speed
		_original_hz = 0


func _exit_tree() -> void:
	_set_match_pace(false)


func _on_phase(p: String) -> void:
	_set_match_pace(p in ["turn", "round", "between"])
	if p in ["turn", "round", "between"] and screen not in ["hud", "pause"]:
		show_screen("hud")


func _on_over(res: Dictionary) -> void:
	Sound.play("win")
	var w := int(res.get("winner", -1))
	var lines := []
	lines.append(("%s tops their pals!" % game.player_name(w)) if w >= 0 else "Game over")
	lines.append("")
	var best: Dictionary = res.get("best", {})
	var order := best.keys()
	order.sort_custom(func(a, b): return float(best[a]) > float(best[b]))
	for pid in order:
		lines.append("%s  -  best %.2f m" % [game.player_name(int(pid)), float(best[pid])])
	lines.append("")
	lines.append("Tower: %d climbers, %.2f m tall" % [int(res.get("tower", 0)), float(res.get("top", 0.0))])
	_results_label.text = "\n".join(lines)
	await get_tree().create_timer(2.2).timeout
	show_screen("results")
	Net.set_in_match(false)


# ================================================================ screens

func show_screen(id: String) -> void:
	if game != null and game.chair != null and (id == "results" or screen == "results"):
		game.chair.visible = id != "results"
	screen = id
	if id == "results":
		_results_elapsed = 0.0
		_results_peak = game.tower_peak()
		_tick_camera(0.0)
	Sound.music("climb" if id in ["hud", "pause"] else "title")  # the match music plays on through a pause
	for k in screens:
		screens[k].visible = k == id
	if pad_nav != null:
		pad_nav.screen_root = screens.get(id)
		pad_nav.active = id != "hud"
	# Screens the 3D front end owns: its menu shows, the flat one stays hidden.
	if lucha != null and lucha.show_screen(id):
		if screens.has(id):
			screens[id].visible = false
		if pad_nav != null and id != "online_flat":
			pad_nav.screen_root = null
	if id == "online":
		Net.ensure_steam()
	paused = false
	var sc: Control = screens.get(id)
	if sc != null:
		var first := UiKit.first_focus(sc)
		if first != null:
			first.call_deferred("grab_focus")
	if id == "local":
		# Play together wants one device per player: an ANY slot from Practice goes.
		for s in range(Players.slots.size() - 1, -1, -1):
			if int(Players.slots[s].device) == Players.ANY:
				Players.remove_player(s)
		_refresh_local()
	if id == "lobby":
		_refresh_lobby()
	Sound.play("ui_open", -10.0)


func _build_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	var theme := UiKit.make_theme()
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = theme
	ui.add_child(root)
	screens.title = _screen_title()
	screens.local = _screen_local()
	screens.online = _screen_online()
	screens.lobby = _screen_lobby()
	screens.hud = _screen_hud()
	screens.results = _screen_results()
	screens.pause = _screen_pause()
	screens.controls = _screen_controls()
	screens.options = _screen_options()
	for k in screens:
		root.add_child(screens[k])
	banner = Label.new()
	banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner.position = Vector2(-700, 150)
	banner.size = Vector2(1400, 120)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_font_size_override("font_size", 64)
	banner.add_theme_constant_override("outline_size", 14)
	banner.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.05))
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(banner)
	feel_panel = _feel_panel()
	feel_panel.visible = false
	root.add_child(feel_panel)
	_pad_corner = Label.new()
	_pad_corner.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_pad_corner.offset_top = -36
	_pad_corner.offset_bottom = -6
	_pad_corner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pad_corner.add_theme_font_size_override("font_size", 18)
	_pad_corner.modulate = Color(0.85, 0.92, 1.0, 0.95)
	_pad_corner.add_theme_constant_override("outline_size", 8)  # readable on the light plaza floor
	_pad_corner.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.05))
	_pad_corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_pad_corner)
	_build_tag = Label.new()
	_build_tag.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_build_tag.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_build_tag.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_build_tag.offset_right = -18
	_build_tag.offset_bottom = -8
	_build_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_build_tag.text = "BUILD " + Net.GAME_VERSION
	_build_tag.add_theme_font_size_override("font_size", 22)
	_build_tag.add_theme_constant_override("outline_size", 8)
	_build_tag.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.05))
	_build_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_build_tag)


func _screen_title() -> Control:
	var c := UiKit.panel_screen("TOP DOG", "Grab, fling, freeze. Climb the tower of everyone who went before you.")
	var box: VBoxContainer = c.get_meta("box")
	UiKit.button(box, "Play together (this PC)", func(): show_screen("local"))
	UiKit.button(box, "Play online", func(): show_screen("online"))
	UiKit.button(box, "Practice", _start_practice)
	UiKit.button(box, "Controls", func(): _controls_back = "title"; show_screen("controls"))
	UiKit.button(box, "Options", func(): _options_back = "title"; show_screen("options"))
	UiKit.button(box, "Quit", quit_game)
	return c


var _controls_back := "title"
var _options_back := "title"


func _screen_local() -> Control:
	var c := UiKit.panel_screen("Play together", "Each player: press A on your pad, or Space on the keyboard, to join.")
	var box: VBoxContainer = c.get_meta("box")
	_local_list = VBoxContainer.new()
	box.add_child(_local_list)
	_settings_box = UiKit.settings_rows(box, Net.settings, func(s): Net.settings = s)
	UiKit.button(box, "Start", _start_local)
	UiKit.button(box, "Remove last player", func():
		if not Players.slots.is_empty():
			Players.remove_player(Players.slots.size() - 1)
		_refresh_local())
	UiKit.button(box, "Back", func(): show_screen("title"))
	return c


func _refresh_local() -> void:
	if _local_list == null:
		return
	for ch in _local_list.get_children():
		ch.queue_free()
	if Players.slots.is_empty():
		var l := Label.new()
		l.text = "(nobody yet)"
		_local_list.add_child(l)
	for s in Players.slots.size():
		var l := Label.new()
		l.text = "%d.  %s   [%s]" % [s + 1, Players.slots[s].name, Players.device_label(Players.slots[s].device)]
		l.add_theme_color_override("font_color", (Players.slots[s].tint as Color).lightened(0.35))
		_local_list.add_child(l)


func _start_local() -> void:
	if Players.slots.is_empty():
		Players.add_player(Players.KBM)
	local_mode = true
	var roster: Array = []
	for s in Players.slots.size():
		roster.append({"pid": s, "name": Players.slots[s].name, "random": Players.slots[s].get("random", false), "tint": Players.slots[s].tint, "peer": 1, "slot": s})
	game.host_start(Net.settings.duplicate(), roster)
	show_screen("hud")


func _start_practice() -> void:
	Players.clear_players()
	Players.add_player(Players.ANY)  # keyboard, mouse or any pad, swapped at will
	local_mode = true
	var s := Net.settings.duplicate()
	s.mode = "practice"
	game.host_start(s, [{"pid": 0, "name": Players.slots[0].name, "random": Players.slots[0].get("random", false), "tint": Players.slots[0].tint, "peer": 1, "slot": 0}])
	show_screen("hud")


func _screen_online() -> Control:
	var c := UiKit.panel_screen("Play online", "Through Steam, or on your local network.")
	var box: VBoxContainer = c.get_meta("box")
	var row := HBoxContainer.new()
	box.add_child(row)
	UiKit.button(row, "Host (public)", func(): _ensure_player(); Net.host_steam(Net.VIS_PUBLIC))
	UiKit.button(row, "Host (friends)", func(): _ensure_player(); Net.host_steam(Net.VIS_FRIENDS))
	UiKit.button(row, "Host (invite only)", func(): _ensure_player(); Net.host_steam(Net.VIS_INVITE))
	var finds := HBoxContainer.new()
	box.add_child(finds)
	UiKit.button(finds, "Join a friend", func(): _ensure_player(); _fill_friends())
	UiKit.button(finds, "Refresh the lobby list", func(): Net.request_lobby_list())
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(900, 260)
	box.add_child(sc)
	_lobby_list = VBoxContainer.new()
	_lobby_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(_lobby_list)
	var lan := HBoxContainer.new()
	box.add_child(lan)
	UiKit.button(lan, "Host on LAN", func(): _ensure_player(); Net.host_lan())
	var ip := LineEdit.new()
	ip.placeholder_text = "Host's IP (blank = this PC)"
	ip.custom_minimum_size = Vector2(380, 0)
	lan.add_child(ip)
	UiKit.button(lan, "Join on LAN", func(): _ensure_player(); Net.join_lan(ip.text.strip_edges()))
	_online_status = Label.new()
	_online_status.text = "Steam ready." if Net.steam_ok else "Steam isn't running: LAN only. (Start Steam and restart to play over Steam.)"
	_online_status.autowrap_mode = TextServer.AUTOWRAP_WORD
	_online_status.custom_minimum_size = Vector2(900, 0)
	box.add_child(_online_status)
	UiKit.button(box, "Back", func(): show_screen("title"))
	return c


## Join a friend: your Steam friends playing Top Dog, each with a Join button for
## the game they're in (a friend not in a game says so).
func _fill_friends() -> void:
	for ch in _lobby_list.get_children():
		ch.queue_free()
	var friends: Array = Net.friends_in_game()
	if friends.is_empty():
		var l := Label.new()
		l.text = "No friends are playing Top Dog right now." if Net.steam_ok else "Steam isn't running."
		_lobby_list.add_child(l)
		return
	for f in friends:
		var row := HBoxContainer.new()
		_lobby_list.add_child(row)
		var l := Label.new()
		l.text = str(f.name) + ("" if int(f.lobby) != 0 else "   (playing, not in a game)")
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		var b := UiKit.button(row, "Join", func(): Net.join_steam(int(f.lobby)))
		b.disabled = int(f.lobby) == 0
	call_deferred("_focus_first_in", _lobby_list)


func _focus_first_in(n: Control) -> void:
	var f := UiKit.first_focus(n)
	if f != null:
		f.grab_focus()


func _ensure_player() -> void:
	if Players.slots.is_empty():
		Players.add_player(Players.ANY, Net.my_name())


func _fill_lobby_list(rows: Array) -> void:
	for ch in _lobby_list.get_children():
		ch.queue_free()
	if rows.is_empty():
		var l := Label.new()
		l.text = "No games found. Host one!"
		_lobby_list.add_child(l)
	for r in rows:
		var row := HBoxContainer.new()
		_lobby_list.add_child(row)
		var l := Label.new()
		l.text = "%s   %s   %s" % [r.name, r.mode_line, r.count_text]
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		var b := UiKit.button(row, "Join" if r.joinable else str(r.short), func(): _ensure_player(); Net.join_steam(int(r.id)))
		b.disabled = not r.joinable


func _on_session_started() -> void:
	_lobby_back = screen if screen in ["online", "online_flat", "friends", "browse", "title"] else "online"
	local_mode = false
	show_screen("lobby")


func _screen_lobby() -> Control:
	var c := UiKit.panel_screen("Lobby", "More players on this PC can press A / Space to join here too.")
	var box: VBoxContainer = c.get_meta("box")
	var cols := HBoxContainer.new()
	box.add_child(cols)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(520, 0)
	cols.add_child(left)
	_lobby_members = VBoxContainer.new()
	left.add_child(_lobby_members)
	var set_holder := VBoxContainer.new()
	set_holder.name = "Settings"
	left.add_child(set_holder)
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(560, 0)
	cols.add_child(right)
	_lobby_chat = RichTextLabel.new()
	_lobby_chat.custom_minimum_size = Vector2(560, 260)
	_lobby_chat.scroll_following = true
	right.add_child(_lobby_chat)
	var presets := HFlowContainer.new()
	right.add_child(presets)
	for p in Net.CHAT_PRESETS:
		UiKit.button(presets, p, func(): Net.send_chat(p), 22)
	var say := LineEdit.new()
	say.placeholder_text = "Say something (Enter)"
	say.text_submitted.connect(func(t): Net.send_chat(t); say.clear())
	right.add_child(say)
	var actions := HBoxContainer.new()
	box.add_child(actions)
	UiKit.button(actions, "Ready", func(): Net.set_ready(not bool(Net.members.get(Net.me(), {}).get("ready", false))))
	UiKit.button(actions, "Start", _start_online)
	UiKit.button(actions, "Invite friends", func(): Net.invite_friends())
	UiKit.button(actions, "Leave", _leave_lobby)
	_lobby_status = Label.new()
	_lobby_status.autowrap_mode = TextServer.AUTOWRAP_WORD
	_lobby_status.custom_minimum_size = Vector2(1000, 0)
	box.add_child(_lobby_status)
	c.set_meta("settings_holder", set_holder)
	return c


func _refresh_lobby() -> void:
	if _lobby_members == null:
		return
	for ch in _lobby_members.get_children():
		ch.queue_free()
	var ids := Net.members.keys()
	ids.sort()
	for id in ids:
		var m: Dictionary = Net.members[id]
		var l := Label.new()
		var names: Array = m.players.map(func(p): return str(p.name))
		l.text = "%s%s  %s\n    %s" % ["(host) " if id == 1 else "", m.name, "READY" if m.ready or id == 1 else "not ready", ", ".join(names)]
		_lobby_members.add_child(l)
	var holder: VBoxContainer = screens.lobby.get_meta("settings_holder")
	for ch in holder.get_children():
		ch.queue_free()
	if Net.is_host():
		UiKit.settings_rows(holder, Net.settings, func(s): Net.set_settings(s))
	else:
		var l := Label.new()
		var mrow := Modes.row(str(Net.settings.mode))
		l.text = "%s  -  %d s clock  -  spawns %s" % [mrow.name, int(Net.settings.timer), str(Net.settings.spawn)]
		holder.add_child(l)


func _on_chat(who: String, text: String) -> void:
	if _lobby_chat:
		if who == "":
			_lobby_chat.append_text("[i]%s[/i]\n" % text)
		else:
			_lobby_chat.append_text("[b]%s:[/b] %s\n" % [who, text])


func _start_online() -> void:
	if not Net.is_host():
		_lobby_status.text = "Only the host can start. Press Ready!"
		return
	if not Net.all_ready():
		_lobby_status.text = "Waiting for everyone to press Ready."
		return
	Net.set_in_match(true)
	game.host_start(Net.settings.duplicate(), Net.build_roster())


func _screen_hud() -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_clock = Label.new()
	hud_clock.set_anchors_preset(Control.PRESET_CENTER_TOP)
	hud_clock.position = Vector2(-150, 20)
	hud_clock.size = Vector2(300, 100)
	hud_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_clock.add_theme_font_size_override("font_size", 84)
	hud_clock.add_theme_constant_override("outline_size", 16)
	hud_clock.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.05))
	c.add_child(hud_clock)
	hud_info = Label.new()
	hud_info.position = Vector2(32, 24)
	hud_info.add_theme_font_size_override("font_size", 34)
	hud_info.add_theme_constant_override("outline_size", 10)
	hud_info.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.05))
	c.add_child(hud_info)
	hud_hint = Label.new()
	hud_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hud_hint.position = Vector2(-600, -110)
	hud_hint.size = Vector2(1200, 60)
	hud_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_hint.add_theme_font_size_override("font_size", 36)
	hud_hint.add_theme_color_override("font_color", Color(1, 0.88, 0.4))
	hud_hint.add_theme_constant_override("outline_size", 10)
	hud_hint.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.05))
	hud_hint.visible = false  # the flat prompt is gone (Parker 11-08); the 3D nameplate shows lock-in
	c.add_child(hud_hint)
	var help := Label.new()
	help.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	help.position = Vector2(32, -60)
	help.text = "Hold a limb's button to drag it (pad: X A hands, Y B feet; keyboard: A D hands, W S feet) and steer with the stick or mouse. Let go and it sticks. Start / Space: lock in. Back / Esc: pause."
	help.add_theme_font_size_override("font_size", 20)
	help.modulate = Color(1, 1, 1, 0.95)
	help.add_theme_constant_override("outline_size", 8)  # readable on the light plaza floor
	help.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.05))
	# Parker 11-08: "The tooltips and dev stuff? Get rid of it." The controls live on
	# the Controls screen; the bottom becomes the 3D nameplate and odometer.
	help.free()
	return c


func _screen_results() -> Control:
	var c := UiKit.panel_screen("Results", "")
	var box: VBoxContainer = c.get_meta("box")
	_results_label = Label.new()
	_results_label.add_theme_font_size_override("font_size", 34)
	box.add_child(_results_label)
	UiKit.button(box, "Play again", func():
		if local_mode:
			game.host_start(Net.settings.duplicate() if game.settings.mode != "practice" else game.settings, game.roster)
			show_screen("hud")
		elif Net.is_host():
			Net.set_in_match(true)
			game.host_start(Net.settings.duplicate(), Net.build_roster())
		else:
			_lobby_status.text = "The host starts the next game.")
	UiKit.button(box, "Back", func():
		game.end_match()
		if local_mode:
			show_screen("title")
		else:
			show_screen("lobby"))
	return c


func _screen_pause() -> Control:
	var c := UiKit.panel_screen("Paused", "")
	var box: VBoxContainer = c.get_meta("box")
	UiKit.button(box, "Resume", _toggle_pause)
	UiKit.button(box, "Controls", func(): _controls_back = "pause"; show_screen("controls"))
	UiKit.button(box, "Options", func(): _options_back = "pause"; show_screen("options"))
	UiKit.button(box, "Quit to the menu", func():
		get_tree().paused = false
		game.end_match()
		if Net.online:
			Net.leave()
		_to_title(""))
	return c


var _quitting := false


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()


## THE QUIT. Godot 4.7.2's exported release build crashes (exit 139) about two
## seconds into its own shutdown here, with or without Steam (the editor binary
## exits clean; Golemheim's record 755 and the style kit saw the same crash). A
## crashing teardown can leave a frozen window or a crash dialog, which is what
## "quit doesn't work" looked like. So: leave the session, shut Steam down, pull the
## ink pass off the world, give the renderer two frames, and then an exported build
## ends its own process instead of walking into the crash. Options and binds are
## saved the moment they change, so nothing is lost. The editor still quits normally.
func quit_game() -> void:
	if _quitting:
		return
	_quitting = true
	Net.shutdown()
	for child in get_children():
		if child is WorldEnvironment:
			var we := child as WorldEnvironment
			if we.compositor != null:
				for fx in we.compositor.compositor_effects:
					if fx != null:
						fx.enabled = false
				we.compositor.compositor_effects = []
				we.compositor = null
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	if OS.has_feature("template") and not ("--slow-quit" in OS.get_cmdline_user_args()):
		OS.kill(OS.get_process_id())
	get_tree().quit()


func _leave_lobby() -> void:
	Net.leave()
	game.end_match()
	local_mode = true
	show_screen(_lobby_back)


## Back one level: B on any pad, or Escape.
func _back() -> void:
	if not _rebind_wait.is_empty():
		return
	match screen:
		"local", "online":
			show_screen("title")
		"lobby":
			_leave_lobby()
		"friends", "browse", "online_flat":
			show_screen("online")
		"controls":
			show_screen(_controls_back)
		"options":
			show_screen(_options_back)
		"pause":
			_toggle_pause()
		"results":
			game.end_match()
			show_screen("title" if local_mode else "lobby")
	Sound.play("ui_close", -8.0)


func _toggle_pause() -> void:
	if screen == "hud":
		show_screen("pause")
		if not Net.online:
			get_tree().paused = true
	elif screen == "pause":
		get_tree().paused = false
		show_screen("hud")


func _to_title(reason: String) -> void:
	get_tree().paused = false
	game.end_match()
	show_screen("title")
	if reason != "":
		_on_announce(reason, false)


func _screen_controls() -> Control:
	var c := UiKit.panel_screen("Controls", "Hold a limb button and steer with the stick or mouse. Release to plant it. Plant a hand or foot on another player to climb or pull together. Hard tension breaks the contact. Hard hits can knock you out. Grab the floating chair with a held limb and release to drop it. Lock in above the line while touching the stage or stack.")
	var box: VBoxContainer = c.get_meta("box")
	var grid := GridContainer.new()
	grid.columns = 5
	box.add_child(grid)
	for h in ["", "Keyboard 1", "Keyboard 2", "Pad", ""]:
		var l := Label.new()
		l.text = h
		grid.add_child(l)
	for ai in Players.ACTIONS.size():
		var action: String = Players.ACTIONS[ai]
		var l := Label.new()
		l.text = Players.ACTION_NAMES[ai]
		grid.add_child(l)
		for spec in [["kbm", 0], ["kbm", 1], ["pad", 0]]:
			var b := Button.new()
			b.custom_minimum_size = Vector2(220, 0)
			b.text = Players.bind_label(Players.binds[spec[0]][action][spec[1]])
			b.pressed.connect(func():
				_rebind_wait = {"scheme": spec[0], "action": action, "index": spec[1], "button": b}
				b.text = "press...")
			grid.add_child(b)
		grid.add_child(Control.new())
	UiKit.button(box, "Reset to defaults", func(): Players.reset_binds(); _rebuild_controls())
	UiKit.button(box, "Back", func(): show_screen(_controls_back))
	_pad_readout = Label.new()
	_pad_readout.add_theme_font_size_override("font_size", 22)
	_pad_readout.modulate = Color(0.8, 0.9, 1.0)
	box.add_child(_pad_readout)
	return c


func _rebuild_controls() -> void:
	var old: Control = screens.controls
	var parent := old.get_parent()
	screens.controls = _screen_controls()
	parent.add_child(screens.controls)
	old.queue_free()
	show_screen("controls")


func _capture_bind(event: InputEvent) -> void:
	var w := _rebind_wait
	var b := {}
	if w.scheme == "kbm":
		if event is InputEventKey and event.pressed:
			if event.physical_keycode == KEY_ESCAPE and w.action != "pause":
				_rebind_wait = {}
				_rebuild_controls()
				return
			b = {"key": event.physical_keycode}
		elif event is InputEventMouseButton and event.pressed:
			b = {"mouse": event.button_index}
	else:
		if event is InputEventJoypadButton and event.pressed:
			b = {"pad": event.button_index}
		elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.6 and event.axis in [JOY_AXIS_TRIGGER_LEFT, JOY_AXIS_TRIGGER_RIGHT]:
			b = {"axis": event.axis}
		elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
			_rebind_wait = {}
			_rebuild_controls()
			return
	if b.is_empty():
		return
	get_viewport().set_input_as_handled()
	Players.set_bind(w.scheme, w.action, w.index, b)
	_rebind_wait = {}
	_rebuild_controls()


func _screen_options() -> Control:
	var c := UiKit.panel_screen("Options", "")
	var box: VBoxContainer = c.get_meta("box")
	for bus in ["Master", "Music", "Effects"]:
		UiKit.slider(box, "%s volume" % bus, Sound.volumes[bus], 0.0, 1.0, func(v): Sound.set_volume(bus, v))
	var fs := CheckButton.new()
	fs.text = "Fullscreen"
	fs.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fs.toggled.connect(func(on): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_MAXIMIZED))
	box.add_child(fs)
	UiKit.button(box, "Feel panel (F1)", func(): feel_panel.visible = not feel_panel.visible)
	UiKit.button(box, "Back", func(): show_screen(_options_back))
	return c


func _feel_panel() -> Control:
	var p := PanelContainer.new()
	p.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	p.position = Vector2(-560, 0)
	p.custom_minimum_size = Vector2(560, 0)
	var sc := ScrollContainer.new()
	p.add_child(sc)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(box)
	var title := Label.new()
	title.text = "THE FEEL TABLE (F1)  -  new climbers pick up body changes"
	box.add_child(title)
	for k in Feel.SPEC:
		var spec: Array = Feel.SPEC[k]
		UiKit.slider(box, "%s: %s" % [k, spec[3]], Feel.get_k(k), spec[1], spec[2], func(v): Feel.set_k(k, v), 16)
	UiKit.button(box, "Reset all", func(): Feel.reset(); feel_panel.queue_free(); feel_panel = _feel_panel(); ui.get_child(0).add_child(feel_panel))
	return p
