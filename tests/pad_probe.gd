extends Node
## Pad check on the 3D menus (windowed: the menus are 3D). Raw pad state is fed
## in (what PadNav reads); the title's focused belt and the screens are watched.
func _ready() -> void:
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(1.2).timeout
	var fails := 0
	var title: Menu3D = main.lucha.menus.title
	print("title open %s, focus %d" % [title.visible, title.focus])
	await _tap(JOY_BUTTON_DPAD_DOWN)
	print("after D-pad down: focus %d" % title.focus)
	if title.focus != 1: fails += 1
	await _stick(1.0)
	print("after stick down: focus %d" % title.focus)
	if title.focus != 2: fails += 1
	await _tap(JOY_BUTTON_DPAD_UP)
	await _tap(JOY_BUTTON_DPAD_UP)
	print("after two ups: focus %d" % title.focus)
	if title.focus != 0: fails += 1
	await _tap(JOY_BUTTON_A)  # PLAY ONLINE (Play Together is off the title since 11-10)
	await get_tree().create_timer(0.4).timeout
	print("screen after A: ", main.screen)
	if main.screen != "online": fails += 1
	await _tap(JOY_BUTTON_B)
	await get_tree().create_timer(0.4).timeout
	print("screen after B: ", main.screen)
	if main.screen != "title": fails += 1
	var k := InputEventKey.new()
	k.physical_keycode = KEY_DOWN
	k.keycode = KEY_DOWN
	k.pressed = true
	Input.parse_input_event(k)
	await get_tree().process_frame
	var ku := k.duplicate()
	ku.pressed = false
	Input.parse_input_event(ku)
	await get_tree().create_timer(0.2).timeout
	print("after keyboard down: focus %d" % title.focus)
	if title.focus != 1: fails += 1
	print("PAD RESULT fails=", fails)
	get_tree().quit(fails)


func _tap(btn: int) -> void:
	var e := InputEventJoypadButton.new(); e.device = 0; e.button_index = btn; e.pressed = true
	Input.parse_input_event(e)
	for i in 3: await get_tree().process_frame
	var u := InputEventJoypadButton.new(); u.device = 0; u.button_index = btn; u.pressed = false
	Input.parse_input_event(u)
	for i in 3: await get_tree().process_frame


func _stick(v: float) -> void:
	var m := InputEventJoypadMotion.new(); m.device = 0; m.axis = JOY_AXIS_LEFT_Y; m.axis_value = v
	Input.parse_input_event(m)
	for i in 3: await get_tree().process_frame
	var z := InputEventJoypadMotion.new(); z.device = 0; z.axis = JOY_AXIS_LEFT_Y; z.axis_value = 0.0
	Input.parse_input_event(z)
	for i in 3: await get_tree().process_frame
