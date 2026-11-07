extends Node
## --pad menu check: real main scene, pad presses fed in as raw joypad state
## (what PadNav reads), focus and screens watched.
func _ready() -> void:
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(1.0).timeout
	var vp := get_viewport()
	var fails := 0
	vp.gui_release_focus()  # as if a mouse click took the focus away
	await _tap(JOY_BUTTON_DPAD_DOWN)
	var f1 := _f(vp)
	print("after D-pad down with no focus: ", f1)
	await _tap(JOY_BUTTON_DPAD_DOWN)
	var f2 := _f(vp)
	print("after D-pad down again: ", f2)
	if f1 != "Play together (this PC)" or f2 != "Play online": fails += 1
	await _stick(1.0)
	print("after stick down: ", _f(vp))
	await _tap(JOY_BUTTON_DPAD_UP)
	await _tap(JOY_BUTTON_DPAD_UP)
	await _tap(JOY_BUTTON_DPAD_UP)
	print("after three ups: ", _f(vp))
	await _tap(JOY_BUTTON_DPAD_DOWN)
	print("focus before A: ", _f(vp))
	await _tap(JOY_BUTTON_A)
	await get_tree().create_timer(0.3).timeout
	print("screen after A: ", main.screen)
	if main.screen != "online": fails += 1
	await _tap(JOY_BUTTON_B)
	await get_tree().create_timer(0.3).timeout
	print("screen after B: ", main.screen)
	if main.screen != "title": fails += 1
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

func _f(vp: Viewport) -> String:
	var f := vp.gui_get_focus_owner()
	return f.text if f is Button else ("none" if f == null else str(f))
