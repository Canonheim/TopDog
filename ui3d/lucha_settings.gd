class_name LuchaSettings
extends Node3D
## CONTROLS AND OPTIONS IN 3D (Parker 11-10; the UI creator's plan, Top Dog Kit\docs\
## ui_upgrade_plan.html, the "final mix"):
##
## CONTROLS  the fight-night poster in front of the camera: the bind board (KEYS 1 /
##           KEYS 2 / PAD tabs, six badge rows of keycaps), the HOW TO WRESTLE list,
##           the ringside pad-check TV, RESET (asks SURE?) and BACK. A keycap flips to
##           PRESS... and listens (Main._rebind_wait / _capture_bind do the binding);
##           the bell dings on bind. A key already in use swaps (Players.set_bind).
## OPTIONS   no table, no panel (Parker 11-10: "the table should be sitting in the ring
##           itself, those objects should spawn in as objects on the actual ring by
##           falling out of the sky ... When you back out, they should fly out of the
##           ring again ... the barrel in the main menu should sink into the floor"):
##           the mixer desk (Master / Music / Effects faders, 5% steps) and the big
##           screen TV (its knob: WINDOWED / FULLSCREEN / WINDOWED FULLSCREEN) drop
##           onto the canvas; the OPTIONS banner and BACK ride the camera.
## The F1 feel panel stays the flat dev panel: nothing here opens it.
##
## Focus moves by direction on screen (pad, arrows) or the mouse (a ray on the UI
## layer); B / Esc go back through Main._back.

const UI_LAYER := Menu3D.UI_LAYER
const ROWS_Y := [1.35, 0.8, 0.25, -0.3, -0.85, -1.4]  # the board's rows (the UI creator's layout)
const CELLS_X := [-1.85, -0.43, 0.99]  # KEYS 1, KEYS 2, PAD
const LABEL_X := -3.97
const TAB_Y := 1.85
const TAB_TINTS := [Color("#D8262E"), Color("#F28A1E"), Color("#1FB8AE")]
const TAB_NAMES := ["KEYS 1", "KEYS 2", "PAD"]
const CELL_SPECS := [["kbm", 0], ["kbm", 1], ["pad", 0]]
const DASH_TINT := Color("#DECCA0")
const LIME := Color("#7CC83A")
const MOVES := ["HOLD A LIMB, STEER IT", "LET GO TO PLANT IT", "PLANT ON A PAL: CLIMB OR PULL", "PULL TOO HARD, IT SNAPS", "BIG HITS KNOCK YOU OUT", "GRAB THE CHAIR, LET GO TO DROP", "LOCK IN ABOVE THE LINE"]
const MOVE_TINTS := [Color("#D8262E"), Color("#F28A1E"), Color("#1FB8AE"), Color("#E0287A"), Color("#8A3FC0"), Color("#2C6BD6"), Color("#7CC83A")]
const BADGES := ["icon_glove", "icon_glove", "icon_boot", "icon_boot", "icon_lock", "icon_pause"]
const BUSES := ["Master", "Music", "Effects"]
const FADER_X := [-1.3, 0.0, 1.3]
const FADER_LABELS := ["label_master", "label_music", "label_fx"]
const FADER_READOUTS := ["readout_master", "readout_music", "readout_fx"]
const FADER_TINTS := [Color("#F28A1E"), Color("#1FB8AE"), Color("#E0287A")]
const FADER_LO := 0.28  # a cap travels y 0.28 .. 1.52 on the desk (the UI creator's numbers)
const FADER_SPAN := 1.24
const VOLUME_STEP := 0.05  # Parker 11-10: "volume should be 5% steps"
const KNOB_DEG := {"windowed": 62.0, "fullscreen": 0.0, "borderless": -62.0}
const STOP_NODES := {"windowed": "tv_stop_windowed", "fullscreen": "tv_stop_fullscreen", "borderless": "tv_stop_borderless"}
const STOP_TEXT := {"windowed": "WINDOWED", "fullscreen": "FULLSCREEN", "borderless": "WINDOWED\nFULLSCREEN"}
const SET_SCALE := 0.62  # the desk and the TV on the canvas
const DROP_FROM := 13.0  # metres above where they land
const SET_Z := 1.2  # the set stands this far in front of the play plane (the apron side of the ring)
const SET_VIEW_DIST := 10.0  # the title camera's distance to it, near enough

var ui: Node  # LuchaUI
var main: Node
var cam: Camera3D
var current := ""
## Tests set this false: the TV's knob then turns without changing the real window.
var apply_window_mode := true

var _stops: Array = []  # this screen's focus stops: {node, area, kind, ...}
var _focus := 0
var _listening := -1  # the keycap stop waiting for a key, or -1
var _listen_before := {}  # its bind before, so a cancel (Esc) doesn't ding
var _reset_armed := false
var _drag := -1  # the fader stop being dragged with the mouse

var _controls: Node3D
var _cells := {}  # "action|scheme|index" -> {node, text, face}
var _reset: Dictionary = {}
var _monitor: Node3D
var _monitor_text: Node3D
var _monitor_shown := ""
var _bubble: Node3D

var _opt_hud: Node3D
var _opt_set: Node3D  # the desk and the TV, in the world
var _desk: Node3D
var _tv: Node3D
var _faders: Array = []  # per bus: {model, cap, fill, focus, readout_text}
var _knob: Node3D
var _screen_text: Node3D
var _base_sunk := false
var _set_tween: Tween


func _init(p_ui: Node) -> void:
	ui = p_ui
	main = ui.main
	cam = ui.cam
	process_mode = Node.PROCESS_MODE_ALWAYS


func build() -> void:
	_build_controls()
	_build_options()


# ================================================================ show / hide

## LuchaUI.show_screen calls this for every screen change.
func on_screen(id: String) -> void:
	if id == current:
		return
	var was := current
	current = id if id in ["controls", "options"] else ""
	if was == "controls":
		_controls.visible = false
		_cancel_listen()
	if was == "options":
		_close_options()
	_stops = []
	_focus = 0
	_reset_armed = false
	_drag = -1
	if current == "controls":
		_stops = _controls.get_meta("stops")
		_refresh_cells()
		_controls.visible = true
		_controls.position.y = 4.0
		create_tween().tween_property(_controls, "position:y", 0.0, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	elif current == "options":
		_stops = _opt_set.get_meta("stops")
		_open_options(str(main._options_back))  # "title" or "pause": where it opened from
	_set_pickable()
	_show_focus()


func _set_pickable() -> void:
	for root in [_controls, _opt_set, _opt_hud]:
		for st: Dictionary in root.get_meta("stops", []):
			(st.area as Area3D).collision_layer = UI_LAYER if (_stops.has(st)) else 0


# ================================================================ CONTROLS

func _build_controls() -> void:
	_controls = Node3D.new()
	_controls.name = "ControlsPoster"
	cam.add_child(_controls)
	# In front of everything, like the pause menu (it opens from pause too).
	var holder := _controls
	holder.position = Vector3.ZERO
	var frame := Node3D.new()
	_controls.add_child(frame)
	frame.position = Vector3(0, 0, -LuchaUI.PAUSE_DIST)
	frame.scale = Vector3.ONE * LuchaUI.UI_SCALE * LuchaUI.PAUSE_DIST / LuchaUI.MENU_DIST
	_controls.visible = false
	var stops: Array = []
	frame.add_child(_banner("CONTROLS", Vector3(0, 3.0, 0)))
	var board := LuchaKit.kit_model("board_poster")
	if board == null:
		board = LuchaKit.box(Vector3(11.84, 5.34, 0.24), LuchaKit.CREAM)
	board.position = Vector3(0, -0.35, 0)
	frame.add_child(board)
	var flags := LuchaKit.bunting(Vector3(-5.5, 2.45, 0.08), Vector3(5.5, 2.45, 0.08), 22, 0.1)
	board.add_child(flags)
	# The column tabs.
	for c in 3:
		var tab := _kit("bind_col_tab", Vector3(1.22, 0.4, 0.05), TAB_TINTS[c])
		tab.position = Vector3(CELLS_X[c], TAB_Y, 0.07)
		LuchaKit.tint_part(tab, "bind_col_face", TAB_TINTS[c])
		board.add_child(tab)
		var tt := LuchaKit.fit_text(TAB_NAMES[c], 0.95, 0.2, LuchaKit.CREAM, LuchaKit.INK)
		tt.position = Vector3(0, 0, 0.09)
		LuchaKit.center_digits(tt)
		tab.add_child(tt)
	# The rows: a badge label, then three keycaps.
	for r in Players.ACTIONS.size():
		var action: String = Players.ACTIONS[r]
		var y: float = ROWS_Y[r]
		var label := _kit("bind_label", Vector3(2.7, 0.46, 0.04), LuchaKit.INK)
		label.position = Vector3(LABEL_X, y, 0.07)
		board.add_child(label)
		var badge := _kit(BADGES[r], Vector3(0.4, 0.4, 0.05), LuchaKit.GOLD)
		badge.position = Vector3(-1.05, 0, 0.05)
		if action.ends_with("_r"):
			badge.scale.x = -1.0  # the right hand and foot: the left's badge, mirrored
		label.add_child(badge)
		var lt := LuchaKit.fit_text(str(Players.ACTION_NAMES[r]).to_upper(), 1.8, 0.2, LuchaKit.CREAM, LuchaKit.INK)
		lt.position = Vector3(0.235, 0, 0.07)
		LuchaKit.center_digits(lt)
		label.add_child(lt)
		for c in 3:
			var cell := _kit("bind_cell", Vector3(1.22, 0.43, 0.08), LuchaKit.CREAM)
			cell.position = Vector3(CELLS_X[c], y, 0.08)
			board.add_child(cell)
			var focus := cell.find_child("cell_focus", true, false) as Node3D
			if focus != null:
				focus.visible = false
			var text := Node3D.new()
			text.position = Vector3(0, 0, 0.065)
			cell.add_child(text)
			var back := LuchaKit.fit_text("PRESS...", 0.95, 0.18, LuchaKit.CREAM, LuchaKit.INK)
			back.position = Vector3(0, 0, -0.065)
			back.rotation.x = PI  # readable once the cap has flipped over
			LuchaKit.center_digits(back)
			cell.add_child(back)
			var key := "%s|%s|%d" % [action, CELL_SPECS[c][0], CELL_SPECS[c][1]]
			_cells[key] = {"node": cell, "text": text, "shown": null}
			stops.append(_stop(cell, Vector3(1.3, 0.5, 0.3), "cell", {"action": action, "scheme": CELL_SPECS[c][0], "index": CELL_SPECS[c][1], "focus": focus, "key": key}))
	# RESET and BACK on the kit's small belts.
	var reset := _belt_small("RESET", Vector3(-3.1, -2.05, 0.08))
	board.add_child(reset.node)
	_reset = reset
	stops.append(_stop(reset.node, Vector3(1.3, 0.5, 0.3), "reset", {"focus": reset.focus, "text": reset.text}))
	var back_b := _belt_small("BACK", Vector3(-0.4, -2.05, 0.08))
	board.add_child(back_b.node)
	stops.append(_stop(back_b.node, Vector3(1.3, 0.5, 0.3), "back", {"focus": back_b.focus, "text": back_b.text}))
	# HOW TO WRESTLE: the numbered move list.
	var head := LuchaKit.poster_text("HOW TO WRESTLE", 0.3, LuchaKit.RED, LuchaKit.INK, 0.05)
	head.position = Vector3(3.8, 1.66, 0.2)  # under the papel picado's points
	board.add_child(head)
	for i in MOVES.size():
		var yy := 1.3 - i * 0.44
		var g := _kit("pad_glyph", Vector3(0.28, 0.28, 0.04), MOVE_TINTS[i])
		LuchaKit.tint_part(g, "pad_glyph_face", MOVE_TINTS[i])
		g.position = Vector3(2.3, yy, 0.07)
		board.add_child(g)
		var n := LuchaKit.poster_text(str(i + 1), 0.15, LuchaKit.CREAM, LuchaKit.INK, 0.02)
		n.position = Vector3(0, 0, 0.05)
		LuchaKit.center_digits(n)
		g.add_child(n)
		var mt := _left_text(MOVES[i], 0.15, LuchaKit.INK, LuchaKit.CREAM)
		mt.position = Vector3(2.55, yy, 0.08)
		LuchaKit.center_digits(mt)
		board.add_child(mt)
	# The ringside pad-check TV, and its advice bubble when a pad is silent.
	_monitor = _kit("pad_monitor", Vector3(2.0, 1.22, 0.44), LuchaKit.GOLD)
	_monitor.scale = Vector3.ONE * 0.62
	_monitor.position = Vector3(4.75, -2.05, 0.12)
	board.add_child(_monitor)
	_monitor_text = Node3D.new()
	_monitor_text.position = Vector3(-0.22, 0, 0.04)
	_monitor.add_child(_monitor_text)
	_bubble = LuchaKit.kit_model("chat_bubble")
	if _bubble == null:
		_bubble = LuchaKit.box(Vector3(1.88, 0.78, 0.03), LuchaKit.CREAM)
	_bubble.scale = Vector3.ONE * 0.8
	_bubble.position = Vector3(2.95, -2.05, 0.2)  # beside the TV, under the move list
	board.add_child(_bubble)
	var tip := LuchaKit.poster_text("PAD SILENT? CLOSE STEAM,\nOR LAUNCH FROM STEAM", 0.13, LuchaKit.INK, LuchaKit.CREAM, 0.02)
	tip.position = Vector3(0, 0.03, 0.06)
	LuchaKit.center_digits(tip)
	_bubble.add_child(tip)
	_bubble.visible = false
	# The footer hint.
	var hint := LuchaKit.poster_text("MOVE: STICK / ARROWS     A: PICK     B: BACK", 0.2, LuchaKit.GOLD, LuchaKit.INK, 0.03)
	hint.position = Vector3(0, -3.25, 0.1)
	frame.add_child(hint)
	LuchaUI.no_shadows(_controls)
	_controls.set_meta("stops", stops)


func _refresh_cells() -> void:
	for key in _cells:
		var parts: PackedStringArray = (key as String).split("|")
		var b: Dictionary = Players.binds[parts[1]][parts[0]][int(parts[2])]
		var label := Players.bind_label(b).to_upper()
		var c: Dictionary = _cells[key]
		if c.shown == label:
			continue
		c.shown = label
		for ch in (c.text as Node3D).get_children():
			ch.queue_free()
		var t := LuchaKit.fit_text(label if label.length() <= 10 else label.left(10), 0.95, 0.2, LuchaKit.RED if label != "-" else LuchaKit.LEATHER, LuchaKit.INK)
		LuchaKit.center_digits(t)
		(c.text as Node3D).add_child(t)
		LuchaKit.tint_part(c.node, "cell_face", DASH_TINT if label == "-" else LuchaKit.CREAM)


func _listen(i: int) -> void:
	var st: Dictionary = _stops[i]
	_listening = i
	_listen_before = (Players.binds[st.scheme][st.action][st.index] as Dictionary).duplicate()
	main._rebind_wait = {"scheme": st.scheme, "action": st.action, "index": st.index, "button": null}
	var cell: Node3D = st.node
	create_tween().tween_property(cell, "rotation:x", PI, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Sound.play("ui_open", -8.0)


func _cancel_listen() -> void:
	if _listening >= 0:
		main._rebind_wait = {}
		_end_listen(false)


func _end_listen(bound: bool) -> void:
	if _listening < 0 or _listening >= _stops.size():
		_listening = -1
		return
	var cell: Node3D = _stops[_listening].node
	_listening = -1
	create_tween().tween_property(cell, "rotation:x", 0.0, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_refresh_cells()
	if bound:
		Sound.play("lock", -6.0)  # the bell dings on bind


func _tick_monitor() -> void:
	var pads := Input.get_connected_joypads()
	var heard: bool = main.pad_nav != null and main.pad_nav.last_pad >= 0
	var state := "none"
	if not pads.is_empty():
		state = "ok" if heard else "silent"
	var line: String = {"none": "NO PAD", "ok": "PAD OK", "silent": "PAD SILENT"}[state]
	if line == _monitor_shown:
		return
	_monitor_shown = line
	for ch in _monitor_text.get_children():
		ch.queue_free()
	var t := LuchaKit.poster_text("PAD CHECK\n" + line, 0.19, LuchaKit.GOLD, LuchaKit.INK, 0.02)
	LuchaKit.center_digits(t)
	_monitor_text.add_child(t)
	LuchaKit.tint_part(_monitor, "monitor_lamp", {"none": Color("#8A8A8A"), "ok": LIME, "silent": LuchaKit.RED}[state])
	_bubble.visible = state == "silent"


# ================================================================ OPTIONS

func _build_options() -> void:
	# The banner and BACK ride the camera; the desk and the TV live in the world.
	_opt_hud = Node3D.new()
	_opt_hud.name = "OptionsHud"
	cam.add_child(_opt_hud)
	var frame := Node3D.new()
	_opt_hud.add_child(frame)
	frame.position = Vector3(0, 0, -LuchaUI.PAUSE_DIST)
	frame.scale = Vector3.ONE * LuchaUI.UI_SCALE * LuchaUI.PAUSE_DIST / LuchaUI.MENU_DIST
	frame.add_child(_banner("OPTIONS", Vector3(0, 3.0, 0)))
	var back_b := _belt_small("BACK", Vector3(0, -3.05, 0.08))
	back_b.node.scale = Vector3.ONE * 1.3
	frame.add_child(back_b.node)
	var hint := LuchaKit.poster_text("LEFT / RIGHT: PICK     UP / DOWN: SLIDE     A: TURN THE KNOB     B: BACK", 0.13, LuchaKit.GOLD, LuchaKit.INK, 0.03)
	hint.position = Vector3(0, -3.55, 0)
	frame.add_child(hint)
	LuchaUI.no_shadows(_opt_hud)
	_opt_hud.visible = false
	_opt_set = Node3D.new()
	_opt_set.name = "OptionsSet"
	main.world.add_child(_opt_set)
	_opt_set.visible = false
	var stops: Array = []
	# The mixer desk.
	_desk = _kit("mixer_desk", Vector3(4.2, 2.5, 0.47), LuchaKit.INK)
	_desk.scale = Vector3.ONE * SET_SCALE
	_desk.position = Vector3(-2.35, 0, 0)
	_opt_set.add_child(_desk)
	for b in BUSES.size():
		var bus: String = BUSES[b]
		var lab := _desk.find_child(FADER_LABELS[b], true, false) as Node3D
		if lab != null:
			var lt := LuchaKit.fit_text(bus.to_upper(), 0.8, 0.17, LuchaKit.INK, LuchaKit.CREAM)
			lt.position = Vector3(0, 0, 0.02)
			LuchaKit.center_digits(lt)
			lab.add_child(lt)
		var model := _kit("fader_cap", Vector3(0.66, 0.3, 0.135), LuchaKit.GOLD)
		model.position = Vector3(FADER_X[b], 0, 0.14)
		_desk.add_child(model)
		var cap := model.find_child("fader_cap", true, false) as Node3D
		var fill := model.find_child("fader_fill", true, false) as Node3D
		var focus := model.find_child("fader_focus", true, false) as Node3D
		if fill != null:
			LuchaKit.tint_part(model, "fader_fill", FADER_TINTS[b])
		if focus != null:
			focus.position = Vector3(0, 1.0, -0.02)
			focus.scale = Vector3(1, 0.85, 1)  # the ring inside the desk: from its foot to under the label
			focus.visible = false
		var readout := _desk.find_child(FADER_READOUTS[b], true, false) as Node3D
		var rt := Node3D.new()
		if readout != null:
			rt.position = Vector3(0, 0, 0.02)
			readout.add_child(rt)
		var fd := {"model": model, "cap": cap, "fill": fill, "focus": focus, "readout": rt, "shown": -1}
		_faders.append(fd)
		var area_node := Node3D.new()
		area_node.position = Vector3(FADER_X[b], FADER_LO + FADER_SPAN * 0.5, 0.2)
		_desk.add_child(area_node)
		stops.append(_stop(area_node, Vector3(1.1, 2.0, 0.4), "fader", {"bus": bus, "fader": b, "focus": focus}))
	# The big screen TV.
	_tv = _kit("big_screen_tv", Vector3(3.0, 3.5, 0.56), LuchaKit.GOLD)
	_tv.scale = Vector3.ONE * SET_SCALE
	_tv.position = Vector3(2.45, 0, 0)
	_opt_set.add_child(_tv)
	for mode in STOP_NODES:
		var sn := _tv.find_child(STOP_NODES[mode], true, false) as Node3D
		if sn != null:
			var st := LuchaKit.poster_text(STOP_TEXT[mode], 0.105 if mode == "borderless" else 0.12, LuchaKit.INK, LuchaKit.CREAM, 0.015)
			st.position = Vector3(0, 0, 0.02)
			LuchaKit.center_digits(st)
			sn.add_child(st)
	_knob = _tv.find_child("tv_knob", true, false) as Node3D
	var screen := _tv.find_child("tv_screen", true, false) as Node3D
	_screen_text = Node3D.new()
	if screen != null:
		_screen_text.position = Vector3(0, 0, 0.02)
		screen.add_child(_screen_text)
	var knob_area := Node3D.new()
	knob_area.position = Vector3(0, 1.4, 0.3)
	_tv.add_child(knob_area)
	var knob_focus := LuchaKit.cursor_star()
	knob_focus.scale = Vector3.ONE * 0.9
	knob_focus.position = Vector3(0, 3.85, 0.2)
	_tv.add_child(knob_focus)
	stops.append(_stop(knob_area, Vector3(3.0, 3.2, 0.6), "knob", {"focus": knob_focus}))
	# BACK (on the camera, but a stop of this screen too).
	stops.append(_stop(back_b.node, Vector3(1.3, 0.5, 0.3), "back", {"focus": back_b.focus, "text": back_b.text}))
	_opt_set.set_meta("stops", stops)
	_opt_hud.set_meta("stops", [])


## Where the set lands: on the ring canvas in front of the barrel from the title; from
## pause (the camera may be up the tower) just below the middle of the view.
func _set_home(from: String) -> Vector3:
	var x := cam.global_position.x
	if from == "pause":
		var d := maxf(1.0, cam.global_position.z - SET_Z)
		return Vector3(x, cam.global_position.y - 0.19 * d, SET_Z)
	return Vector3(x, 0.0, SET_Z)


## From pause the follow camera may be close: the set shrinks to take the same share
## of the view as it does from the title (SET_VIEW_DIST away).
func _set_scale(from: String) -> float:
	if from != "pause":
		return 1.0
	return clampf((cam.global_position.z - SET_Z) / SET_VIEW_DIST, 0.25, 1.5)


func _open_options(from: String) -> void:
	_refresh_faders()
	_refresh_knob(main.window_mode(), false)
	_opt_hud.visible = true
	var home := _set_home(from)
	if _set_tween != null and _set_tween.is_valid():
		_set_tween.kill()
	_opt_set.visible = true
	_opt_set.global_position = home
	_opt_set.scale = Vector3.ONE * _set_scale(from)
	# Out of the sky, one then the other, a thump and a bounce.
	_set_tween = create_tween().set_parallel(true)
	var k := 0
	for piece: Node3D in [_desk, _tv]:
		var land := piece.position
		piece.position = land + Vector3(0, DROP_FROM, 0)
		piece.rotation.z = (0.4 if k == 0 else -0.4)
		_set_tween.tween_property(piece, "position", land, 0.75).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(0.12 * k)
		_set_tween.tween_property(piece, "rotation:z", 0.0, 0.75).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT).set_delay(0.12 * k)
		k += 1
	_set_tween.tween_callback(func() -> void: Sound.play("thud", -6.0)).set_delay(0.45)
	# The barrel (or the cactus, the donkey) sinks into the canvas, from the title only:
	# in a match the tower may stand on it.
	_base_sunk = false
	if from == "title" and main.game != null and main.game.stage != null and is_instance_valid(main.game.stage.base_root):
		var base: Node3D = main.game.stage.base_root
		_base_sunk = true
		create_tween().tween_property(base, "position:y", -4.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _close_options() -> void:
	_opt_hud.visible = false
	if _set_tween != null and _set_tween.is_valid():
		_set_tween.kill()
	_drag = -1
	# Back up into the sky, then gone; the barrel rises again.
	_set_tween = create_tween().set_parallel(true)
	var k := 0
	for piece: Node3D in [_desk, _tv]:
		var home: Vector3 = Vector3(-2.35 if piece == _desk else 2.45, 0, 0)
		_set_tween.tween_property(piece, "position", home + Vector3(0, DROP_FROM + 4.0, 0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).set_delay(0.06 * k)
		k += 1
	_set_tween.chain().tween_callback(func() -> void:
		_opt_set.visible = false
		_desk.position = Vector3(-2.35, 0, 0)
		_tv.position = Vector3(2.45, 0, 0))
	if _base_sunk and main.game != null and main.game.stage != null and is_instance_valid(main.game.stage.base_root):
		create_tween().tween_property(main.game.stage.base_root, "position:y", 0.0, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.25)
	_base_sunk = false


func _refresh_faders() -> void:
	for b in _faders.size():
		var fd: Dictionary = _faders[b]
		var v: float = clampf(float(Sound.volumes.get(BUSES[b], 0.0)), 0.0, 1.0)
		if fd.cap != null:
			(fd.cap as Node3D).position = Vector3(0, FADER_LO + FADER_SPAN * v, 0)
		if fd.fill != null:
			(fd.fill as Node3D).position = Vector3(0, FADER_LO, 0.01)
			(fd.fill as Node3D).scale = Vector3(1, maxf(0.001, FADER_SPAN * v), 1)
		var pct := int(round(v * 100.0))
		if pct != int(fd.shown):
			fd.shown = pct
			for ch in (fd.readout as Node3D).get_children():
				ch.queue_free()
			var t := LuchaKit.fit_text("%d%%" % pct, 0.62, 0.17, LuchaKit.GOLD, LuchaKit.INK)
			LuchaKit.center_digits(t)
			(fd.readout as Node3D).add_child(t)


func _set_volume(b: int, v: float) -> void:
	v = clampf(snappedf(v, VOLUME_STEP), 0.0, 1.0)
	if is_equal_approx(v, float(Sound.volumes.get(BUSES[b], 0.0))):
		return
	Sound.set_volume(BUSES[b], v)
	_refresh_faders()
	Sound.play("ui_click", -10.0)


## The knob's mode: turned, its stop lit lime, its name on the big screen.
func _refresh_knob(mode: String, animate := true) -> void:
	if _knob != null:
		var deg: float = KNOB_DEG.get(mode, 0.0)
		if animate:
			create_tween().tween_property(_knob, "rotation:z", deg_to_rad(deg), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			_knob.rotation.z = deg_to_rad(deg)
	for m in STOP_NODES:
		LuchaKit.tint_part(_tv, STOP_NODES[m], LIME if m == mode else LuchaKit.CREAM)
	for ch in _screen_text.get_children():
		ch.queue_free()
	var t := LuchaKit.fit_text(STOP_TEXT[mode].replace("\n", " "), 2.0, 0.3, LuchaKit.GOLD, LuchaKit.INK)
	LuchaKit.center_digits(t)
	_screen_text.add_child(t)
	_tv.set_meta("mode", mode)


func _turn_knob(dir := 1) -> void:
	var modes: Array = main.WINDOW_MODES
	var now: String = _tv.get_meta("mode", main.window_mode())
	var next: String = modes[wrapi(modes.find(now) + dir, 0, modes.size())]
	if apply_window_mode:
		main.set_window_mode(next)
	_refresh_knob(next)
	Sound.play("ui_click", -6.0)


# ================================================================ focus and input

func _stop(node: Node3D, size: Vector3, kind: String, data := {}) -> Dictionary:
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 0
	area.monitoring = false
	var col := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	col.shape = bs
	area.add_child(col)
	node.add_child(area)
	var st := data.duplicate()
	st.node = node
	st.area = area
	st.kind = kind
	return st


func _show_focus() -> void:
	for i in _stops.size():
		var st: Dictionary = _stops[i]
		var f = st.get("focus")
		if f != null and is_instance_valid(f):
			(f as Node3D).visible = i == _focus


func _screen_pos(i: int) -> Vector2:
	return cam.unproject_position((_stops[i].node as Node3D).global_position)


## Focus to the nearest stop that way on screen.
func _move(dir: Vector2) -> void:
	if _stops.is_empty():
		return
	var from := _screen_pos(_focus)
	var best := -1
	var best_score := INF
	for i in _stops.size():
		if i == _focus:
			continue
		var d := _screen_pos(i) - from
		var along := d.dot(dir)
		if along <= 4.0:
			continue
		var score := along + absf(d.cross(dir)) * 2.5
		if score < best_score:
			best_score = score
			best = i
	if best >= 0:
		_set_focus(best)


func _set_focus(i: int) -> void:
	if i == _focus:
		return
	_focus = i
	if _reset_armed:
		_reset_armed = false
		_relabel_belt(_reset, "RESET")
	_show_focus()
	Sound.play("ui_hover", -12.0)


func _activate(i: int) -> void:
	if i < 0 or i >= _stops.size():
		return
	var st: Dictionary = _stops[i]
	match st.kind:
		"cell":
			_listen(i)
		"reset":
			if not _reset_armed:
				_reset_armed = true
				_relabel_belt(_reset, "SURE?")
				Sound.play("ui_click", -6.0)
			else:
				_reset_armed = false
				Players.reset_binds()
				_refresh_cells()
				_relabel_belt(_reset, "RESET")
				Sound.play("lock", -6.0)
		"back":
			main._back()
		"knob":
			_turn_knob(1)
		"fader":
			pass


func _unhandled_input(event: InputEvent) -> void:
	if current == "" or _stops.is_empty():
		return
	if _listening >= 0:
		return  # Main._capture_bind has the next key or button
	var st: Dictionary = _stops[_focus]
	var handled := true
	if event.is_action_pressed("ui_up", true):
		if st.kind == "fader":
			_set_volume(st.fader, float(Sound.volumes[st.bus]) + VOLUME_STEP)
		else:
			_move(Vector2.UP)
	elif event.is_action_pressed("ui_down", true):
		if st.kind == "fader":
			_set_volume(st.fader, float(Sound.volumes[st.bus]) - VOLUME_STEP)
		else:
			_move(Vector2.DOWN)
	elif event.is_action_pressed("ui_left", true):
		_move(Vector2.LEFT)
	elif event.is_action_pressed("ui_right", true):
		_move(Vector2.RIGHT)
	elif event.is_action_pressed("ui_accept"):
		_activate(_focus)
	elif event is InputEventMouseMotion:
		var h := _pick((event as InputEventMouseMotion).position)
		if _drag >= 0:
			_drag_fader(_drag, (event as InputEventMouseMotion).position)
		elif h >= 0:
			_set_focus(h)
		handled = h >= 0 or _drag >= 0
	elif event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb := event as InputEventMouseButton
		if not mb.pressed:
			handled = _drag >= 0
			_drag = -1
		else:
			var h := _pick(mb.position)
			handled = h >= 0
			if h >= 0:
				_set_focus(h)
				if _stops[h].kind == "fader":
					_drag = h
					_drag_fader(h, mb.position)
				else:
					_activate(h)
	else:
		handled = false
	if handled:
		get_viewport().set_input_as_handled()


func _pick(screen_pos: Vector2) -> int:
	var from := cam.project_ray_origin(screen_pos)
	var to := from + cam.project_ray_normal(screen_pos) * 80.0
	var q := PhysicsRayQueryParameters3D.create(from, to, UI_LAYER)
	q.collide_with_areas = true
	q.collide_with_bodies = false
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return -1
	for i in _stops.size():
		if _stops[i].area == hit.collider:
			return i
	return -1


## A fader under the mouse: the cap goes where the pointer is on the desk's face.
func _drag_fader(i: int, screen_pos: Vector2) -> void:
	var st: Dictionary = _stops[i]
	var from := cam.project_ray_origin(screen_pos)
	var dir := cam.project_ray_normal(screen_pos)
	var plane := Plane(_desk.global_transform.basis.z.normalized(), _desk.global_position)
	var p = plane.intersects_ray(from, dir)
	if p == null:
		return
	var local: Vector3 = _desk.global_transform.affine_inverse() * (p as Vector3)
	_set_volume(st.fader, (local.y - FADER_LO) / FADER_SPAN)


func _process(_delta: float) -> void:
	if current == "controls":
		if _listening >= 0 and (main._rebind_wait as Dictionary).is_empty():
			var st: Dictionary = _stops[_listening]
			_end_listen(Players.binds[st.scheme][st.action][st.index] != _listen_before)
		if _listening >= 0:
			var cell: Node3D = _stops[_listening].node
			cell.scale = Vector3.ONE * (1.0 + 0.06 * sin(Time.get_ticks_msec() / 1000.0 * 10.0))
		_tick_monitor()
	var t := Time.get_ticks_msec() / 1000.0
	for i in _stops.size():
		var st: Dictionary = _stops[i]
		if st.kind in ["reset", "back"]:
			var n: Node3D = st.node
			var want := 1.12 if i == _focus else 1.0
			if n.get_parent() != null and n.get_parent().get_parent() == _opt_hud:
				want *= 1.3
			n.scale = n.scale.lerp(Vector3.ONE * want, 0.2)
			n.rotation.z = sin(t * 5.0) * 0.03 if i == _focus else 0.0
		elif st.kind == "knob":
			var f: Node3D = st.focus
			if f != null:
				f.rotation.z = sin(t * 6.0) * 0.18


# ================================================================ pieces

## Poster text that starts at its origin and runs right (a list's lines).
func _left_text(s_: String, size: float, face: Color, back: Color) -> Node3D:
	var t := LuchaKit.poster_text(s_, size, face, back, 0.02)
	for lb in t.find_children("*", "Label3D", true, false):
		(lb as Label3D).horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	LuchaKit.center_digits(t)
	return t


## A kit part by name, or a plain box of its size while it's missing.
func _kit(name_s: String, size: Vector3, c: Color) -> Node3D:
	var k := LuchaKit.kit_model(name_s)
	if k != null:
		return k
	var root := Node3D.new()
	root.add_child(LuchaKit.box(size, c))
	return root


func _banner(text_s: String, at: Vector3) -> Node3D:
	var b := LuchaKit.kit_model("hud_banner")
	var root := Node3D.new()
	root.position = at
	if b != null:
		b.scale = Vector3.ONE * 1.6
		root.add_child(b)
		var t := LuchaKit.fit_text(text_s, 3.12 * 1.6 * 0.85, 0.26 * 1.6 * 0.85, LuchaKit.RED, LuchaKit.INK)
		t.position = Vector3(0, 0, 0.07 * 1.6 + 0.02)
		LuchaKit.center_digits(t)
		root.add_child(t)
	else:
		root.add_child(LuchaKit.poster_text(text_s, 0.6, LuchaKit.GOLD, LuchaKit.RED, 0.12))
	return root


func _belt_small(text_s: String, at: Vector3) -> Dictionary:
	var k := LuchaKit.kit_model("belt_small")
	var root := Node3D.new()
	root.position = at
	if k == null:
		k = LuchaKit.box(Vector3(1.24, 0.42, 0.07), LuchaKit.RED)
	k.scale = Vector3.ONE * 1.25
	root.add_child(k)
	var focus := k.find_child("belt_small_focus", true, false) as Node3D
	if focus != null:
		focus.visible = false
	var text := Node3D.new()
	text.position = Vector3(0, 0, 0.065 * 1.25)
	root.add_child(text)
	var d := {"node": root, "focus": focus, "text": text}
	_relabel_belt(d, text_s)
	return d


func _relabel_belt(d: Dictionary, text_s: String) -> void:
	if d.is_empty():
		return
	for ch in (d.text as Node3D).get_children():
		ch.queue_free()
	var t := LuchaKit.fit_text(text_s, 0.8 * 1.25, 0.15 * 1.25)
	LuchaKit.center_digits(t)
	(d.text as Node3D).add_child(t)
