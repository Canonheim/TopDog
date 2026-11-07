extends Node
## MAIN: the app. Builds the world (sky, sun, stage, camera), holds the one Game
## node (at /root/Main/Game on every machine, so its RPCs line up), and runs the
## screens: title, local play, online, lobby, the match HUD, results, pause,
## controls, options and the F1 feel panel. All screen UI, built in code.

const UiKit := preload("res://ui/ui_kit.gd")
const GameScript := preload("res://game/game.gd")
const Layout := preload("res://climber/body_layout.gd")

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
var line_label: Label3D
var tags := {}  # cid -> Label3D
var local_mode := true  # this match was started from Local play
var paused := false
var feel_panel: Control
var _cam_target := Vector3(0, 2, 14)
var _cam_fov := 34.0
var _last_tick_s := -1
var _lobby_list: VBoxContainer
var _online_status: Label
var _lobby_members: VBoxContainer
var _lobby_chat: RichTextLabel
var _lobby_status: Label
var _local_list: VBoxContainer
var _settings_box: Dictionary = {}
var _results_label: Label
var _rebind_wait := {}  # {"scheme", "action", "index", "button"}


func _ready() -> void:
	_input_defaults()
	_build_world()
	game = GameScript.new()
	game.name = "Game"
	game.world = world
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
	game.stage = Stage.new("dock")
	game.stage.build(world, true)
	show_screen("title")
	Sound.music("title")
	if "--demo" in OS.get_cmdline_user_args():
		call_deferred("_demo")
	if "--demo-heap" in OS.get_cmdline_user_args():
		call_deferred("_demo_heap")
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
	get_tree().quit()


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


## A battery/screenshot hook: two local bots on the barrel, no menus.
func _demo() -> void:
	Players.clear_players()
	Players.add_player(Players.KBM, "Parker the Barrel-Hugger")
	local_mode = true
	game.host_start({"mode": "scramble", "timer": 60.0, "spawn": "alternate", "stage": "dock"},
		[{"pid": 0, "name": Players.slots[0].name, "tint": Players.slots[0].tint, "peer": 1, "slot": 0}])
	show_screen("hud")


func _input_defaults() -> void:
	# Stock 4.7.2 has no pad button on ui_accept / ui_cancel: add A and B.
	for pair in [["ui_accept", JOY_BUTTON_A], ["ui_cancel", JOY_BUTTON_B]]:
		var ev := InputEventJoypadButton.new()
		ev.button_index = pair[1]
		ev.device = -1
		if not InputMap.action_has_event(pair[0], ev):
			InputMap.action_add_event(pair[0], ev)


# ================================================================ the world

func _build_world() -> void:
	world = Node3D.new()
	world.name = "World"
	add_child(world)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.32, 0.55, 0.85)
	sm.sky_horizon_color = Color(0.78, 0.86, 0.92)
	sm.ground_horizon_color = Color(0.6, 0.7, 0.75)
	sm.ground_bottom_color = Color(0.15, 0.3, 0.4)
	sm.sun_angle_max = 20.0
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.9
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.fog_enabled = true
	e.fog_light_color = Color(0.75, 0.84, 0.92)
	e.fog_density = 0.0035
	e.fog_aerial_perspective = 0.4
	e.ssao_enabled = true
	e.glow_enabled = true
	e.glow_intensity = 0.4
	env.environment = e
	add_child(env)
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
	# The line: a glowing bar across the deck, and its label.
	line_bar = MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(30, 0.035, 0.05)
	line_bar.mesh = bm
	var lm := StandardMaterial3D.new()
	lm.albedo_color = Color(1.0, 0.85, 0.25)
	lm.emission_enabled = true
	lm.emission = Color(1.0, 0.75, 0.2)
	lm.emission_energy_multiplier = 2.5
	lm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	line_bar.material_override = lm
	line_bar.position = Vector3(0, 1.6, 0.35)
	world.add_child(line_bar)
	line_label = Label3D.new()
	line_label.text = "TOP"
	line_label.font_size = 64
	line_label.pixel_size = 0.006
	line_label.modulate = Color(1, 0.9, 0.4)
	line_label.outline_size = 12
	line_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	world.add_child(line_label)


func _process(delta: float) -> void:
	_tick_camera(delta)
	_tick_hud(delta)
	_tick_tags()
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


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F1:
		feel_panel.visible = not feel_panel.visible
	if not _rebind_wait.is_empty():
		_capture_bind(event)


# ---------------------------------------------------------------- camera

func _tick_camera(delta: float) -> void:
	var pts: Array = []
	for c in game.live_climbers():
		pts.append((c as Climber).centre_of_mass())
	var top := game.tower_top() if game.stage != null else 1.6
	var line_y := game.line if game.phase != "idle" else top
	if pts.is_empty():
		pts.append(Vector2(0, top))
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for p in pts + [Vector2(-2.0, maxf(0.0, line_y - 3.0)), Vector2(2.0, line_y + 0.8)]:
		lo = lo.min(p)
		hi = hi.max(p)
	lo -= Vector2(1.6, 1.0)
	hi += Vector2(1.6, 1.4)
	var centre := (lo + hi) * 0.5
	var aspect := 16.0 / 9.0
	if get_viewport() != null:
		var vs := get_viewport().get_visible_rect().size
		aspect = vs.x / maxf(vs.y, 1.0)
	var half_h := maxf((hi.y - lo.y) * 0.5, (hi.x - lo.x) * 0.5 / aspect)
	half_h = maxf(half_h, 3.2)
	var dist := half_h / tan(deg_to_rad(_cam_fov * 0.5))
	_cam_target = Vector3(centre.x, centre.y + 0.3, dist)
	cam.position = cam.position.lerp(_cam_target, 1.0 - exp(-delta * 2.5))
	cam.look_at(Vector3(cam.position.x, cam.position.y - 0.3, 0.0), Vector3.UP)
	line_bar.position.y = lerpf(line_bar.position.y, line_y, 1.0 - exp(-delta * 8.0))
	line_bar.visible = game.phase in ["turn", "round", "between"]
	line_label.visible = line_bar.visible
	line_label.position = Vector3(cam.position.x - half_h * aspect * 0.62, line_bar.position.y + 0.3, 0.4)
	line_label.text = "LINE  %.2f m" % line_y


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
		if cl.owner_peer == game.me() and cl.top_height() > game.line + Game.LOCK_MARGIN:
			hint = "Above the line! Lock in: Space / A"
	hud_hint.text = hint


func _tick_tags() -> void:
	for cid in tags.keys():
		var c: Climber = game.climbers.get(cid)
		var tag: Label3D = tags[cid]
		if c == null or not is_instance_valid(c) or c.bodies.is_empty():
			tag.queue_free()
			tags.erase(cid)
			continue
		var head: RigidBody3D = c.bodies["head"]
		tag.global_position = head.global_position + Vector3(0, 0.38, 0.3)
		tag.visible = c.state != Climber.State.FROZEN


func _on_spawned(c: Climber) -> void:
	var tag := Label3D.new()
	tag.text = c.display_name
	tag.font_size = 40
	tag.pixel_size = 0.005
	tag.outline_size = 10
	tag.modulate = c.tint.lightened(0.3)
	tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag.no_depth_test = true
	world.add_child(tag)
	tags[c.climber_id] = tag
	c.grab_made.connect(func(cl, limb, _o): Sound.play_at("grab", Vector3(cl.limb_end(limb).x, cl.limb_end(limb).y, 0), -4.0, world))
	c.grab_lost.connect(func(_cl, _l): Sound.play("grip", -14.0))
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


func _on_phase(p: String) -> void:
	if p in ["turn", "round", "between"] and screen not in ["hud", "pause"]:
		show_screen("hud")
		Sound.music("climb")


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
	screen = id
	for k in screens:
		screens[k].visible = k == id
	paused = false
	var sc: Control = screens.get(id)
	if sc != null:
		var first := UiKit.first_focus(sc)
		if first != null:
			first.call_deferred("grab_focus")
	if id == "local":
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


func _screen_title() -> Control:
	var c := UiKit.panel_screen("TOP YOUR PALS", "Grab, fling, freeze. Climb the tower of everyone who went before you.")
	var box: VBoxContainer = c.get_meta("box")
	UiKit.button(box, "Play together (this PC)", func(): show_screen("local"))
	UiKit.button(box, "Play online", func(): show_screen("online"))
	UiKit.button(box, "Practice", _start_practice)
	UiKit.button(box, "Controls", func(): _controls_back = "title"; show_screen("controls"))
	UiKit.button(box, "Options", func(): _options_back = "title"; show_screen("options"))
	UiKit.button(box, "Quit", func(): get_tree().quit())
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
		roster.append({"pid": s, "name": Players.slots[s].name, "tint": Players.slots[s].tint, "peer": 1, "slot": s})
	game.host_start(Net.settings.duplicate(), roster)
	show_screen("hud")


func _start_practice() -> void:
	if Players.slots.is_empty():
		Players.add_player(Players.KBM)
	local_mode = true
	var s := Net.settings.duplicate()
	s.mode = "practice"
	game.host_start(s, [{"pid": 0, "name": Players.slots[0].name, "tint": Players.slots[0].tint, "peer": 1, "slot": 0}])
	show_screen("hud")


func _screen_online() -> Control:
	var c := UiKit.panel_screen("Play online", "Through Steam, or on your local network.")
	var box: VBoxContainer = c.get_meta("box")
	var row := HBoxContainer.new()
	box.add_child(row)
	UiKit.button(row, "Host (public)", func(): _ensure_player(); Net.host_steam(Net.VIS_PUBLIC))
	UiKit.button(row, "Host (friends)", func(): _ensure_player(); Net.host_steam(Net.VIS_FRIENDS))
	UiKit.button(row, "Host (invite only)", func(): _ensure_player(); Net.host_steam(Net.VIS_INVITE))
	UiKit.button(box, "Refresh the lobby list", func(): Net.request_lobby_list())
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


func _ensure_player() -> void:
	if Players.slots.is_empty():
		Players.add_player(Players.KBM, Net.my_name())


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
	UiKit.button(actions, "Leave", func(): Net.leave(); _to_title(""))
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
	c.add_child(hud_hint)
	var help := Label.new()
	help.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	help.position = Vector2(32, -60)
	help.text = "Hold a limb (LMB/RMB/A/D or LB/RB/LT/RT) and steer it. Held hands and feet stick. Esc / Start: pause."
	help.add_theme_font_size_override("font_size", 20)
	help.modulate = Color(1, 1, 1, 0.7)
	c.add_child(help)
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
	var c := UiKit.panel_screen("Controls", "Hold a limb's button to drive it; it sticks to whatever it touches. You can only drive while something of yours is stuck, or a pal is holding you. Steer with the stick or the mouse. Lock in above the line!")
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
