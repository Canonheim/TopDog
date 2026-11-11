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
const PODIUM_HOLD_SECONDS := 3.0
const PODIUM_SHIFT_SECONDS := 3.0
const TOWER_PAN_SPEED := 0.35  # world metres per second
var _results_elapsed := 0.0
var _results_peak := Vector2.ZERO
var _personal_camera := false
const PLAZA_CAM_X := 14.0  # the plaza camera's centre stays within this of the ring (x)
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
var _readout_t := 0.0
var _glyphs_on := true
var _glyphs_n := -1
var _input_health: Label  # F2: what the input system knows right now (Players.health)
var _focus_notice: Label  # shown in a match while the window has lost the focus
## COUCH PLAYERS IN AN ONLINE LOBBY are parked with Play Together (Parker 11-10:
## "first lets only focus on the online multiplayer"). It was also a trap: a host on a
## pad pressing Space or Enter (the keyboard's Lock In, and the menus' accept) made a
## second climber for the keyboard and pinned player one to the pad. The slot
## machinery under it stays (Players._refresh_pad_routes, its batteries).
const COUCH_JOIN_ONLINE := false
var _build_tag: Label  # "BUILD x.y.z" in the title's corner (Parker 11-07: know which build you booted)


func _ready() -> void:
	var display := ConfigFile.new()
	if display.load("user://display.cfg") == OK:
		# The three window modes (Parker 11-10); an older save's fullscreen ON was the
		# borderless kind.
		var legacy := "borderless" if bool(display.get_value("display", "fullscreen", false)) else "windowed"
		set_window_mode(str(display.get_value("display", "window_mode", legacy)), false)
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
	Net.members_changed.connect(_sync_waiting_room)
	Net.chat_line.connect(_on_chat)
	Net.settings_changed.connect(_refresh_lobby)
	Net.settings_changed.connect(func(): preview_base(str(Net.settings.get("base", "random"))))
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
		[{"pid": 0, "name": Players.slots[0].name, "tint": Players.slots[0].tint, "peer": 1, "slot": 0, "appearance": Wardrobe.for_slot(0)}])
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
	var glyphs_on := screen != "pause"
	if glyphs_on != _glyphs_on or game.climbers.size() != _glyphs_n:
		_glyphs_on = glyphs_on
		_glyphs_n = game.climbers.size()
		for cid in game.climbers:
			(game.climbers[cid] as Climber).set_glyphs_visible(glyphs_on)
	if screen == "local":
		var dev := Players.poll_join()
		if dev != -2:
			Players.add_player(dev)
	if COUCH_JOIN_ONLINE and screen == "lobby" and Net.is_host():
		var dev2 := Players.poll_join()
		if dev2 != -2 and Players.slots.size() < 4:
			Players.add_player(dev2)
	for s in Players.slots.size():
		if screen == "lobby" and not Net.is_host() and Players.pause_pressed(s):
			_leave_lobby()
		elif screen in ["hud", "pause"] and Players.pause_pressed(s):
			_toggle_pause()
	if _input_health != null and _input_health.visible:
		_input_health.text = "INPUT (F2 hides)   log: %s
%s" % [ProjectSettings.globalize_path(Players.LOG_PATH), Players.health()]
	if _focus_notice != null:
		_focus_notice.visible = not Players.focused and screen in ["hud", "pause", "lobby"]
	if _build_tag != null:
		_build_tag.visible = screen == "title"
	_readout_t -= delta
	var readout_due := _readout_t <= 0.0
	if readout_due:
		_readout_t = 0.25  # the readout's text is rebuilt four times a second, not every frame
	if _pad_corner != null:
		_pad_corner.visible = screen not in ["hud", "pause"]
		if _pad_corner.visible and readout_due:
			_pad_corner.text = pad_nav.readout()
	if _pad_readout != null and screen == "controls" and readout_due:
		var hint := ""
		if pad_nav.last_pad < 0 and not Input.get_connected_joypads().is_empty():
			hint = "
A pad is connected but nothing has arrived. If pressing changes nothing here, something outside the game (Steam Input's desktop layout, or another app) is holding the pad: try closing Steam, or add the game to Steam and launch it from there."
		_pad_readout.text = pad_nav.readout() + hint


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F1:
		feel_panel.visible = not feel_panel.visible
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F2 and _input_health != null:
		_input_health.visible = not _input_health.visible
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE 			and _rebind_wait.is_empty() and screen not in ["hud", "pause"]:
		_back()
	if event is InputEventKey and event.pressed and not event.echo and pad_nav != null 			and event.physical_keycode in [KEY_UP, KEY_DOWN, KEY_TAB]:
		pad_nav.ensure_focus()
	if not _rebind_wait.is_empty():
		_capture_bind(event)


# ---------------------------------------------------------------- camera

func results_podium_focus() -> Vector2:
	# Del Mar's results stand on the pier (Parker 11-10: "at pier"), on the deck just
	# shore-side of the base, the tower reaching out over the sea beside them.
	if game.stage != null and game.stage.delmar:
		return Vector2(game.stage.base_root.position.x - game.stage.barrel_half - 2.8, 1.5)
	return Vector2((game.stage.barrel_half if game.stage != null else 1.0) + 2.8, 1.5)


func _tick_camera(delta: float) -> void:
	if screen == "lobby":
		var focus := Vector2(-5.5, 4.85)
		var viewport_size := get_viewport().get_visible_rect().size
		var aspect := viewport_size.x / maxf(1.0, viewport_size.y)
		var distance := maxf(31.0, 16.5 / (tan(deg_to_rad(cam.fov * 0.5)) * aspect))
		if not Net.is_host():
			for actor: Climber in game.live_climbers():
				if actor.owner_peer == game.me():
					focus = actor.centre_of_mass()
					distance = 9.0
					break
		cam.position = cam.position.lerp(Vector3(focus.x, focus.y + 1.0, distance), 1.0 - exp(-delta * 3.0))
		cam.look_at(Vector3(cam.position.x, cam.position.y - 1.0, 0), Vector3.UP)
		line_bar.visible = false
		return
	if screen == "customize":
		cam.position = Vector3(-1.1, 2.2, 7.2)
		cam.look_at(Vector3(-1.1, 1.7, 0), Vector3.UP)
		line_bar.visible = false
		return
	if screen == "results":
		_results_elapsed += delta / Engine.time_scale
		var start := Vector2(0, 1.5)
		if game.stage != null and game.stage.delmar:
			start.x = game.stage.base_root.position.x  # the tower's foot, at the pier's end
		var end := Vector2(_results_peak.x, maxf(start.y, _results_peak.y))
		var elapsed := maxf(0.0, _results_elapsed - PODIUM_HOLD_SECONDS)
		var focus := results_podium_focus().lerp(start, smoothstep(0.0, PODIUM_SHIFT_SECONDS, elapsed))
		if elapsed >= PODIUM_SHIFT_SECONDS:
			var length := start.distance_to(end)
			var distance := (elapsed - PODIUM_SHIFT_SECONDS) * TOWER_PAN_SPEED
			var travel := 0.0
			if length > 0.001:
				var cycle := fposmod(distance, length * 2.0)
				travel = cycle if cycle <= length else 2.0 * length - cycle
			focus = start.move_toward(end, travel)
		cam.position = Vector3(focus.x, focus.y + 0.5, 9.0)
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
	var delmar: bool = game.stage != null and game.stage.delmar
	if lucha != null:
		lucha.mountains_down(delmar, delta)
	if not follow and delmar:
		# Del Mar between rounds: the pier's end and the rope where it meets the tower.
		lo = Vector2(Stage.PIER_END - 7.0, -1.0)
		hi = Vector2(maxf(Stage.PIER_END + 3.0, game.line - Stage.DECK_Y - 1.0), 4.0)
	elif not follow:
		for point in [Vector2(-2.0, maxf(0.0, line_y - 3.0)), Vector2(2.0, line_y + 0.8)]:
			lo = lo.min(point)
			hi = hi.max(point)
	if follow and Net.online:
		var spread := hi - lo
		var distance := maxf(spread.x / 1.6, spread.y)
		_personal_camera = distance > (13.5 if _personal_camera else 18.0)
		if _personal_camera:
			var target: Climber = null
			for candidate: Climber in live:
				if candidate.owner_peer == game.me():
					target = candidate
					break
			# Once locked in, follow the next active player in roster order.
			if target == null:
				var local_index := -1
				for i in game.roster.size():
					if int(game.roster[i].peer) == game.me():
						local_index = i
						break
				for offset in range(1, game.roster.size() + 1):
					var pid := int(game.roster[(local_index + offset) % game.roster.size()].pid)
					for candidate: Climber in live:
						if candidate.player_id == pid:
							target = candidate
							break
					if target != null:
						break
			if target != null:
				lo = target.centre_of_mass()
				hi = lo
	else:
		_personal_camera = false
	if follow and delmar:
		# DEL MAR'S MATCH VIEW (the Environment Maker's plan): the climbers, the pier's
		# end and the buoy where the rope meets the sea, so you see where to build.
		var buoy_x := game.line - Stage.WATER_Y
		lo = lo.min(Vector2(Stage.PIER_END - 4.0, Stage.WATER_Y - 0.4))
		hi = hi.max(Vector2(buoy_x + 1.5, Stage.DECK_Y + 2.6))
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
	if delmar:
		half_h = clampf(half_h, 4.0, 9.5)
	var dist := half_h / tan(deg_to_rad(_cam_fov * 0.5))
	# THE PLAZA CLAMP (Parker 11-10, the Environment Maker's plan): the camera's centre
	# stays within PLAZA_CAM_X of the ring, so a climber flung out across the 60 m floor
	# can't swing it round to the beach town (Del Mar, off to the right).
	if not delmar:
		centre.x = clampf(centre.x, -PLAZA_CAM_X, PLAZA_CAM_X)
	_cam_target = Vector3(centre.x, centre.y + 0.3, dist)
	cam.position = cam.position.lerp(_cam_target, 1.0 - exp(-delta * 2.5))
	cam.look_at(Vector3(cam.position.x, cam.position.y - 0.3, 0.0), Vector3.UP)
	line_bar.position.y = lerpf(line_bar.position.y, line_y, 1.0 - exp(-delta * 8.0))
	line_bar.visible = game.phase in ["turn", "round", "between"] and not delmar  # Del Mar's line is the rope


# ---------------------------------------------------------------- HUD

func _tick_hud(delta: float) -> void:
	banner_t -= delta
	if banner:
		banner.modulate.a = clampf(banner_t, 0.0, 1.0)
	if screen != "hud" and screen != "pause":
		return
	if not hud_info.is_visible_in_tree():
		# The 3D HUD draws all of this; the flat labels are hidden. Only the countdown's
		# tick sound lives here (Parker 11-09).
		if game.phase in ["turn", "round"] and not game.practice:
			var sec := int(ceil(game.clock))
			if sec != _last_tick_s and sec <= LuchaUI.COUNTDOWN_FROM and sec >= 1:
				Sound.play("tick")
			_last_tick_s = sec
		return
	var info := ""
	match game.phase:
		"turn":
			var pid: int = game.turn_order[game.turn_i] if game.turn_i >= 0 else -1
			info = "%s climbing" % game.player_name(pid)
		"round":
			info = "Round %d: %s" % [game.round_n, game.round_matchup()]
		"between":
			info = "Get ready..."
	if game.practice:
		info += "   (Practice)"
	hud_info.text = info
	if game.phase in ["turn", "round"] and not game.practice:
		var s := int(ceil(game.clock))
		hud_clock.text = "%d" % maxi(s, 0)
		hud_clock.modulate = Color(1, 0.35, 0.3) if game.clock <= 10.0 else Color.WHITE
		# THE COUNTDOWN (Parker 11-09: "you should hear it counting down starting at 10").
		if s != _last_tick_s and s <= LuchaUI.COUNTDOWN_FROM and s >= 1:
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
	var from_pause := (screen == "controls" and _controls_back == "pause") or (screen == "options" and _options_back == "pause")
	if p in ["turn", "round", "between"] and screen not in ["hud", "pause", "practice_ai"] and not from_pause:
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
	show_screen("results")
	Net.set_in_match(false)


# ================================================================ screens

func preview_base(choice: String) -> void:
	if game == null or game.stage == null or game.phase != "idle":
		return
	# Random is resolved by the host at match start, never by menu updates.
	if choice == "random":
		return
	game.stage.set_base(world, choice)


func show_screen(id: String) -> void:
	Players.mute_edges()  # the press that changed the screen isn't read again on the next one
	if id != "controls":
		_rebind_wait = {}  # a rebind left waiting would eat the next key in play
	if game != null and game.chair != null and (id == "results" or screen == "results"):
		game.chair.visible = id != "results"
	screen = id
	if id == "pause":
		for button in screens.pause.get_meta("box").get_children():
			if button.has_meta("practice_ai_button"):
				button.visible = game.practice
	if id in ["local", "lobby"]:
		preview_base(str(Net.settings.get("base", "random")))
	if id == "results":
		_results_elapsed = 0.0
		_results_peak = game.tower_peak()
		_tick_camera(0.0)
	Sound.music("climb" if id in ["hud", "pause", "practice_ai"] else "title")  # the match music plays on through a pause
	for k in screens:
		screens[k].visible = k == id
	if pad_nav != null:
		pad_nav.screen_root = screens.get(id)
		pad_nav.active = id != "hud" and not (id == "lobby" and not Net.is_host())
	# Screens the 3D front end owns: its menu shows, the flat one stays hidden.
	if lucha != null and lucha.show_screen(id):
		if screens.has(id):
			screens[id].visible = false
		if pad_nav != null and id != "online_flat":
			pad_nav.screen_root = null
	if screens.has("customize"):
		screens.customize.on_screen(id)
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
	screens.practice_ai = _screen_practice_ai()
	screens.controls = _screen_controls()
	screens.options = _screen_options()
	screens.customize = preload("res://ui/customization.gd").new(self)
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
	# F2: THE INPUT READOUT (the 11-10 input rewrite): devices, Steam's state, each
	# player's device and what it holds, the stale guard, the last log lines.
	_input_health = Label.new()
	_input_health.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_input_health.position = Vector2(12, 90)
	_input_health.add_theme_font_size_override("font_size", 15)
	_input_health.add_theme_constant_override("outline_size", 6)
	_input_health.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03))
	_input_health.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_input_health.visible = false
	root.add_child(_input_health)
	# The window lost the focus mid-match: keys go to the other window and Steam hands
	# the pad to its desktop layout. Nothing the game can read; say so, loudly.
	_focus_notice = Label.new()
	_focus_notice.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_focus_notice.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_focus_notice.position.y = 150
	_focus_notice.text = "CLICK THE GAME WINDOW
it lost the focus, so your controls are off"
	_focus_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_focus_notice.add_theme_font_size_override("font_size", 34)
	_focus_notice.add_theme_color_override("font_color", Color("#FFC928"))
	_focus_notice.add_theme_constant_override("outline_size", 12)
	_focus_notice.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.05))
	_focus_notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_focus_notice.visible = false
	root.add_child(_focus_notice)
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
	# Play together is off the title for now (Parker 11-10: online first).
	UiKit.button(box, "Play online", func(): show_screen("online"))
	UiKit.button(box, "Practice", _open_practice)
	UiKit.button(box, "Customize", func(): show_screen("customize"))
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
	_settings_box = UiKit.settings_rows(box, Net.settings, func(s): Net.settings = s; preview_base(str(s.get("base", "random"))))
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
	if Modes.row(str(Net.settings.get("mode", "scramble"))).get("round_robin", false) and Players.slots.size() < 2:
		_on_announce("Classic needs two players. Use Practice to climb alone.", false)
		return
	if Players.slots.is_empty():
		Players.add_player(Players.KBM)
	local_mode = true
	var roster: Array = []
	for s in Players.slots.size():
		roster.append({"pid": s, "name": Players.slots[s].name, "random": Players.slots[s].get("random", false), "tint": Players.slots[s].tint, "peer": 1, "slot": s, "appearance": Wardrobe.for_slot(s)})
	game.host_start(Net.settings.duplicate(), roster)
	show_screen("hud")


var practice_settings := {"practice_mode": "scramble", "base": "barrel", "practice_npc": false}


func _open_practice() -> void:
	show_screen("practice_settings")


func _start_practice() -> void:
	Players.clear_players()
	Players.add_player(Players.ANY)  # keyboard, mouse or any pad, swapped at will
	local_mode = true
	var s := Net.settings.duplicate()
	s.mode = "practice"
	s.merge(practice_settings, true)
	game.host_start(s, [{"pid": 0, "name": Players.slots[0].name, "random": Players.slots[0].get("random", false), "tint": Players.slots[0].tint, "peer": 1, "slot": 0, "appearance": Wardrobe.for_slot(0)}])
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
	_online_status = Label.new()
	_online_status.text = "Steam ready." if Net.steam_ok else "Start Steam and restart to play online."
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
		Players.add_online_player(Net.my_name())  # Steam name for the player, made names for its climbers


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
	# An invite accepted during a (paused) Practice: that match ends here.
	get_tree().paused = false
	if local_mode and game.phase != "idle":
		game.end_match()
	local_mode = false
	show_screen("lobby")
	_sync_waiting_room()


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
	if game.host_start(Net.settings.duplicate(), Net.build_roster()):
		Net.set_in_match(true)  # only once it has really started: a refused start left the lobby shut


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
			if game.host_start(Net.settings.duplicate(), Net.build_roster()):
				Net.set_in_match(true)
		else:
			_lobby_status.text = "The host starts the next game.")
	UiKit.button(box, "Back", leave_results)
	return c


func _screen_practice_ai() -> Control:
	var c := UiKit.panel_screen("Practice AI", "Choose how the practice partner behaves.")
	var box: VBoxContainer = c.get_meta("box")
	for level in ["none", "stationary", "easy", "hard"]:
		var choice: String = level
		UiKit.button(box, "No NPC" if choice == "none" else ("Stationary" if choice == "stationary" else "Climb " + choice.capitalize()), func(): game.set_practice_ai(choice))
	UiKit.button(box, "Back", func(): show_screen("pause"))
	return c

func _screen_pause() -> Control:
	var c := UiKit.panel_screen("Paused", "")
	var box: VBoxContainer = c.get_meta("box")
	UiKit.button(box, "Resume", _toggle_pause)
	var ai_button := UiKit.button(box, "AI Settings", func(): show_screen("practice_ai"))
	ai_button.set_meta("practice_ai_button", true)
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
		"customize":
			if screens.customize.confirming:
				screens.customize._cancel_delete()
			else:
				show_screen("title")
		"local", "online", "practice_settings":
			show_screen("title")
		"lobby":
			_leave_lobby()
		"friends", "browse", "online_flat":
			show_screen("online")
		"controls":
			show_screen(_controls_back)
		"options":
			show_screen(_options_back)
		"practice_ai":
			show_screen("pause")
		"pause":
			_toggle_pause()
		"results":
			leave_results()
	Sound.play("ui_close", -8.0)


func _toggle_pause() -> void:
	if screen == "hud":
		show_screen("pause")
		if not Net.online:
			get_tree().paused = true
	elif screen == "pause":
		get_tree().paused = false
		show_screen("hud")


## Back from the results: the title after a local match; online, the lobby with its
## waiting room (the host sends it again; a guest keeps the room the host already sent).
func leave_results() -> void:
	if local_mode or Net.is_host() or game.phase != "lobby":
		game.end_match()
	show_screen("title" if local_mode else "lobby")
	_sync_waiting_room()


func _to_title(reason: String) -> void:
	get_tree().paused = false
	if screen == "title" and game.phase == "idle":
		if reason != "":
			_on_announce(reason, false)
		return  # already there (the host leaving reports twice)
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


## THE WINDOW MODES (Parker 11-10: the TV's knob, "Windowed, Full screen, and Windowed
## Full screen"): "windowed" (a maximised window), "fullscreen" (exclusive) and
## "borderless" (windowed fullscreen). Saved between launches.
const WINDOW_MODES := ["windowed", "fullscreen", "borderless"]


func set_window_mode(mode: String, save := true) -> void:
	if not mode in WINDOW_MODES:
		mode = "windowed"
	DisplayServer.window_set_mode({
		"windowed": DisplayServer.WINDOW_MODE_MAXIMIZED,
		"fullscreen": DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
		"borderless": DisplayServer.WINDOW_MODE_FULLSCREEN,
	}[mode])
	if save:
		var display := ConfigFile.new()
		display.load("user://display.cfg")
		display.set_value("display", "window_mode", mode)
		display.set_value("display", "fullscreen", mode != "windowed")
		display.save("user://display.cfg")


func window_mode() -> String:
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			return "fullscreen"
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			return "borderless"
	return "windowed"


func _set_fullscreen(on: bool, save := true) -> void:
	set_window_mode("borderless" if on else "windowed", save)


func _screen_options() -> Control:
	var c := UiKit.panel_screen("Options", "")
	var box: VBoxContainer = c.get_meta("box")
	for bus in ["Master", "Music", "Effects"]:
		UiKit.slider(box, "%s volume" % bus, Sound.volumes[bus], 0.0, 1.0, func(v): Sound.set_volume(bus, v))
	var fs := Button.new()
	fs.name = "FullscreenToggle"
	fs.toggle_mode = true
	fs.custom_minimum_size = Vector2(0, 56)
	var refresh_display := func():
		var on := DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
		fs.set_pressed_no_signal(on)
		fs.text = "Fullscreen: ON" if on else "Fullscreen: OFF"
	refresh_display.call()
	fs.toggled.connect(func(on):
		_set_fullscreen(on)
		refresh_display.call())
	c.visibility_changed.connect(refresh_display)
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

func _sync_waiting_room() -> void:
	if screen == "lobby" and Net.is_host() and not Net.in_match:
		game.sync_waiting_room.call_deferred()
