extends Node
## The Online page under a STEAM controller: once Steam is up it owns the pad, and
## the menus must work from Steam's actions alone. A stand-in Steam Input (the real
## script, its device table filled by hand) presses d-pad down / right, A and B.
const SteamInputScript := preload("res://core/steam_input.gd")
var si: Node
var fails := 0

func _ready() -> void:
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(1.0).timeout
	si = SteamInputScript.new()
	Net.add_child(si)
	Net.steam_input = si
	si.devices[3000] = {"handle": 1, "type": 3, "buttons": {}, "stick": Vector2.ZERO}
	main.show_screen("online")
	await get_tree().create_timer(0.4).timeout
	var vp := get_viewport()
	var seen: Array = [_f(vp)]
	for step in ["menu_down", "menu_right", "menu_down", "menu_down", "menu_up"]:
		await _press(step)
		seen.append(_f(vp))
	print("focus path: ", seen)
	var distinct := {}
	for s in seen:
		distinct[s] = true
	if distinct.size() < 4:
		fails += 1
		print("FAIL the Steam pad didn't move through the Online page")
	# The stick moves menus too.
	si.devices[3000].stick = Vector2(0, -0.9)
	await get_tree().create_timer(0.1).timeout
	si.devices[3000].stick = Vector2.ZERO
	await get_tree().create_timer(0.1).timeout
	print("after stick down: ", _f(vp))
	# B goes back to the title.
	await _press("menu_back")
	await get_tree().create_timer(0.3).timeout
	print("screen after B: ", main.screen)
	if main.screen != "title":
		fails += 1
		print("FAIL B didn't go back")
	print("ONLINE PAD RESULT fails=", fails)
	get_tree().quit(fails)

func _press(action: String) -> void:
	si.devices[3000].buttons[action] = true
	for i in 3: await get_tree().process_frame
	si.devices[3000].buttons[action] = false
	for i in 3: await get_tree().process_frame

func _f(vp: Viewport) -> String:
	var f := vp.gui_get_focus_owner()
	return f.text if f is Button else ("none" if f == null else f.get_class())
