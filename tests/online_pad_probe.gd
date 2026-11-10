extends Node
## The Online page under a STEAM controller: once Steam is up it owns the pad, and
## the menus must work from Steam's actions alone. A stand-in Steam Input (the real
## script, its device table filled by hand) presses d-pad down / right, A and B.
const SteamInputScript := preload("res://core/steam_input.gd")
var si: Node
var fails := 0
var _main: Node

func _ready() -> void:
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(1.0).timeout
	main.show_screen("online")
	si = SteamInputScript.new()
	Net.add_child(si)
	Net.steam_input = si
	si.devices[3000] = {"handle": 1, "type": 3, "buttons": {}, "stick": Vector2.ZERO}
	await get_tree().create_timer(0.4).timeout
	var vp := get_viewport()
	_main = main
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
	for origin in ["online", "friends", "browse", "online_flat"]:
		main.show_screen(origin)
		main._on_session_started()
		await _press("menu_back")
		if main.screen != origin:
			fails += 1
			print("FAIL lobby B from ", origin, " returned to ", main.screen)
		else:
			print("PASS lobby B returns to ", origin)
	main.show_screen("online")
	main._ensure_player()
	var test_peer := ENetMultiplayerPeer.new()
	assert(test_peer.create_server(7788, 12) == OK)
	Net.multiplayer.multiplayer_peer = test_peer
	Net._start_session_as_host()
	if main.screen != "lobby" or not Net.online:
		fails += 1
		print("FAIL test host lobby did not open")
	await _press("menu_back")
	if main.screen != "online" or Net.online:
		fails += 1
		print("FAIL host B did not leave the session and return to Online")
	else:
		print("PASS host B left the test lobby and returned to Online")
	print("ONLINE PAD RESULT fails=", fails)
	get_tree().quit(fails)

func _press(action: String) -> void:
	si.devices[3000].buttons[action] = true
	for i in 3: await get_tree().process_frame
	si.devices[3000].buttons[action] = false
	for i in 3: await get_tree().process_frame

## The focused item: the 3D belt menu's when one owns the screen, else the flat page's.
func _f(vp: Viewport) -> String:
	var lucha = _main.get("lucha") if _main != null else null
	if lucha != null and lucha.menus.has(_main.screen) and lucha.menus[_main.screen].visible:
		var m = lucha.menus[_main.screen]
		if m.focus < 0 or m.focus >= m.items.size():
			return "3d:?"
		var it: Dictionary = m.items[m.focus]
		return "3d:%d %s%s" % [m.focus, str(it.label), (" stop %d" % int(it.stop)) if it.kind == "row" else ""]
	var f := vp.gui_get_focus_owner()
	return f.text if f is Button else ("none" if f == null else f.get_class())
