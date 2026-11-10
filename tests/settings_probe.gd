extends Node
## CONTROLS AND OPTIONS IN 3D (windowed): the poster's keycaps listen and bind (a
## key in use swaps), RESET asks SURE?, the faders step 5%, the TV's knob turns
## through the three window modes (without touching the real window), the barrel
## sinks while the options set is in the ring, and BACK returns to the opener.
## The player's own binds and volumes are put back. -- --shots=DIR saves frames.
var fails := 0
var shots := ""


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shots="):
			shots = a.get_slice("=", 1)
	var kept_binds: Dictionary = Players.binds.duplicate(true)
	var kept_volumes: Dictionary = Sound.volumes.duplicate()
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(2.5).timeout
	var st: LuchaSettings = main.lucha.settings
	st.apply_window_mode = false
	Players.reset_binds()
	# CONTROLS from the title.
	main._controls_back = "title"
	main.show_screen("controls")
	await get_tree().create_timer(1.0).timeout
	_check("controls: the 3D poster owns the screen (the flat one hidden)", st.current == "controls" and st._controls.visible and not main.screens.controls.visible)
	_check("controls: 18 keycaps, RESET and BACK are focus stops", st._stops.size() == 20, st._stops.size())
	await _shot("settings_controls")
	# Keycap 0 is Left hand / KEYS 1 (A). Bind it to D: the right hand had D, so it swaps.
	st._activate(0)
	await get_tree().create_timer(0.3).timeout
	_check("controls: a keycap listens (flipped, Main waiting for a key)", st._listening == 0 and not main._rebind_wait.is_empty() and absf(st._stops[0].node.rotation.x - PI) < 0.3)
	await _shot("settings_controls_listening")
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_D
	ev.pressed = true
	main._capture_bind(ev)
	await get_tree().create_timer(0.4).timeout
	_check("controls: the key binds and the keycap flips back", st._listening == -1 and Players.binds.kbm.arm_l[0] == {"key": KEY_D} and absf(st._stops[0].node.rotation.x) < 0.2)
	_check("controls: the key's old owner took the swapped key (right hand A)", Players.binds.kbm.arm_r[0] == {"key": KEY_A})
	_check("controls: the keycaps read the new binds", st._cells["arm_l|kbm|0"].shown == "D" and st._cells["arm_r|kbm|0"].shown == "A", [st._cells["arm_l|kbm|0"].shown, st._cells["arm_r|kbm|0"].shown])
	# Esc while listening cancels (no change).
	st._activate(0)
	await get_tree().create_timer(0.2).timeout
	var esc := InputEventKey.new()
	esc.physical_keycode = KEY_ESCAPE
	esc.pressed = true
	main._capture_bind(esc)
	await get_tree().create_timer(0.3).timeout
	_check("controls: Esc while listening cancels, the bind unchanged", st._listening == -1 and Players.binds.kbm.arm_l[0] == {"key": KEY_D})
	# RESET asks SURE? first.
	var reset_i := -1
	var back_i := -1
	for i in st._stops.size():
		if st._stops[i].kind == "reset":
			reset_i = i
		elif st._stops[i].kind == "back":
			back_i = i
	st._focus = reset_i
	st._activate(reset_i)
	_check("controls: RESET asks SURE? first (nothing reset yet)", st._reset_armed and Players.binds.kbm.arm_l[0] == {"key": KEY_D})
	st._activate(reset_i)
	await get_tree().process_frame
	_check("controls: ...and resets on the second press", not st._reset_armed and Players.binds.kbm.arm_l[0] == {"key": KEY_A})
	# Focus moves by direction on screen: right from the first keycap is KEYS 2.
	st._focus = 0
	st._move(Vector2.RIGHT)
	_check("controls: right from KEYS 1 goes to KEYS 2 in the same row", st._stops[st._focus].get("action", "") == "arm_l" and st._stops[st._focus].get("index", -1) == 1 and st._stops[st._focus].get("scheme", "") == "kbm")
	st._move(Vector2.DOWN)
	_check("controls: down goes to the next row", st._stops[st._focus].get("action", "") == "arm_r", st._stops[st._focus].get("action", ""))
	st._activate(back_i)
	await get_tree().create_timer(0.5).timeout
	_check("controls: BACK returns to the title", main.screen == "title" and not st._controls.visible, main.screen)
	# OPTIONS from the title: the set drops into the ring, the barrel sinks.
	main._options_back = "title"
	main.show_screen("options")
	await get_tree().create_timer(1.4).timeout
	var base: Node3D = main.game.stage.base_root
	_check("options: the desk and the TV stand in the ring (on the canvas)", st._opt_set.visible and absf(st._opt_set.global_position.y) < 0.01 and absf(st._desk.position.y) < 0.01 and absf(st._tv.position.y) < 0.01, [st._opt_set.global_position, st._desk.position.y, st._tv.position.y])
	_check("options: the barrel has sunk into the floor", base.position.y < -3.0, base.position.y)
	await _shot("settings_options")
	var music := 1
	var before: float = Sound.volumes.Music
	st._focus = music
	var up := InputEventAction.new()
	up.action = "ui_up"
	up.pressed = true
	st._unhandled_input(up)
	_check("options: up on a fader raises it 5%", is_equal_approx(Sound.volumes.Music, clampf(snappedf(before + 0.05, 0.05), 0.0, 1.0)), [before, Sound.volumes.Music])
	var knob_i := -1
	for i in st._stops.size():
		if st._stops[i].kind == "knob":
			knob_i = i
	var mode0: String = st._tv.get_meta("mode")
	st._activate(knob_i)
	var mode1: String = st._tv.get_meta("mode")
	st._activate(knob_i)
	st._activate(knob_i)
	_check("options: the knob turns through all three window modes", mode1 != mode0 and st._tv.get_meta("mode") == mode0 and mode1 in main.WINDOW_MODES, [mode0, mode1])
	await get_tree().create_timer(0.4).timeout
	await _shot("settings_options_knob")
	main._back()
	await get_tree().create_timer(1.3).timeout
	_check("options: BACK flies the set out and the barrel rises again", main.screen == "title" and not st._opt_set.visible and absf(base.position.y) < 0.01, [main.screen, st._opt_set.visible, base.position.y])
	# From pause: the set drops in below the camera, and the base stays put.
	main._start_practice()
	await get_tree().create_timer(2.5).timeout
	main._toggle_pause()
	await get_tree().create_timer(0.5).timeout
	main._options_back = "pause"
	main.show_screen("options")
	await get_tree().create_timer(1.4).timeout
	_check("options from pause: the base stays where the tower stands", absf(main.game.stage.base_root.position.y) < 0.01)
	await _shot("settings_options_pause")
	main._back()
	await get_tree().create_timer(0.8).timeout
	_check("options from pause: BACK returns to the pause menu", main.screen == "pause", main.screen)
	# Put the player's own setup back.
	Players.binds = kept_binds
	Players.save()
	for bus in kept_volumes:
		Sound.set_volume(bus, kept_volumes[bus])
	print("SETTINGS RESULT fails=", fails)
	get_tree().paused = false
	get_tree().quit(fails)


func _check(label: String, ok: bool, extra = "") -> void:
	print(("PASS  " if ok else "FAIL  ") + label + ("" if str(extra) == "" else "  [%s]" % str(extra)))
	if not ok:
		fails += 1


func _shot(name: String) -> void:
	if shots == "":
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [shots, name])
