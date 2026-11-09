extends Node
## The 3D online screens with the pad (windowed): title -> PLAY ONLINE -> JOIN A
## FRIEND -> back -> BROWSE GAMES -> back, then a lobby with stand-in members.
## -- --shots=DIR also saves online.png, friends.png, browse.png, lobby.png there.
var fails := 0
var shots := ""


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shots="):
			shots = a.get_slice("=", 1)
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(1.2).timeout
	await _tap(JOY_BUTTON_DPAD_DOWN)  # PLAY ONLINE
	await _tap(JOY_BUTTON_A)
	await _wait(0.6)
	_check("A on PLAY ONLINE opens the 3D online screen", main.screen == "online" and main.lucha.menus.online.visible, main.screen)
	_check("the flat online page stays hidden", not main.screens.online.visible)
	await _shot("online")
	await _tap(JOY_BUTTON_DPAD_DOWN)  # JOIN A FRIEND
	await _tap(JOY_BUTTON_A)
	await _wait(0.6)
	_check("JOIN A FRIEND opens the friends screen", main.screen == "friends" and main.lucha.menus.friends.visible, main.screen)
	_check("the friends screen always has REFRESH and BACK", main.lucha.menus.friends.items.size() >= 2)
	await _shot("friends")
	await _tap(JOY_BUTTON_B)
	await _wait(0.5)
	_check("B on friends goes back to online", main.screen == "online", main.screen)
	var online: Menu3D = main.lucha.menus.online
	online.focus = 2  # BROWSE GAMES
	await _tap(JOY_BUTTON_A)
	await _wait(0.6)
	_check("BROWSE GAMES opens the browse screen", main.screen == "browse", main.screen)
	await _shot("browse")
	await _tap(JOY_BUTTON_B)
	await _wait(0.5)
	_check("B on browse goes back to online", main.screen == "online", main.screen)
	# HOST flips left / right before it hosts.
	online.focus = 0
	await _wait(0.3)
	_check("HOST shows its focus ring on PUBLIC", _ring_on(online, 0, 0))
	await _tap(JOY_BUTTON_DPAD_RIGHT)
	_check("right walks HOST to the FRIENDS belt and its ring", online.items[0].stop == 1 and _ring_on(online, 0, 1), online.items[0].stop)
	await _tap(JOY_BUTTON_DPAD_LEFT)
	# Friends as kit rows: two stops each (the row, then JOIN).
	main.lucha.online.test_friends = [{"id": 0, "name": "Matilda", "lobby": 77}, {"id": 0, "name": "Yorick", "lobby": 0}]
	main.show_screen("friends")
	await _wait(0.8)
	var fr: Menu3D = main.lucha.menus.friends
	_check("friends come in as kit rows", fr.items.size() >= 4 and fr.items[0].kind == "row", fr.items.size())
	fr.focus = 0
	await _tap(JOY_BUTTON_DPAD_RIGHT)
	_check("right on a friend row lands on its JOIN plate", fr.items[0].stop == 1 and _ring_on(fr, 0, 1))
	await _shot("friends_rows")
	main.lucha.online.test_friends = null
	await _tap(JOY_BUTTON_B)
	await _wait(0.5)
	# Games as kit rows.
	main.show_screen("browse")
	Net.lobby_list.emit([
		{"id": 5, "name": "Parker's ring", "count_text": "3/8", "mode_line": "Tower", "joinable": true, "reason": "", "short": ""},
		{"id": 6, "name": "Big Barrel Bash", "count_text": "8/8", "mode_line": "Scramble", "joinable": false, "reason": "That game is full.", "short": "Full"},
	])
	await _wait(0.8)
	var br: Menu3D = main.lucha.menus.browse
	_check("games come in as kit rows", br.items.size() >= 4 and br.items[0].kind == "row", br.items.size())
	await _shot("browse_rows")
	await _tap(JOY_BUTTON_B)
	await _wait(0.5)
	# A lobby with stand-in members (offline we're the host).
	Net.members = {
		1: {"name": "Parker", "players": [{"name": "Parker the Barrel-Hugger", "tint": NameGen.tint(0), "slot": 0}], "ready": true},
		2: {"name": "Pal", "players": [{"name": "Matilda the Goose-Toppler", "tint": NameGen.tint(1), "slot": 0}, {"name": "Yorick the Anvil-Wrangler", "tint": NameGen.tint(2), "slot": 1}], "ready": false},
	}
	main._on_session_started()
	Net.chat_line.emit("Pal", "Hello!")
	Net.chat_line.emit("Parker", "Ready!")
	Net.chat_line.emit("", "Pal joined")
	await _wait(1.2)
	_check("the 3D lobby opens with a card per player", main.screen == "lobby" and main.lucha.online._board.get_child_count() == 3, main.lucha.online._board.get_child_count())
	var lobby: Menu3D = main.lucha.menus.lobby
	_check("the host's lobby leads with FIGHT!", lobby.items.size() > 0 and str(lobby.items[0].label) == "FIGHT!")
	await _shot("lobby")
	await _tap(JOY_BUTTON_B)
	_check("raw B leaves the lobby and returns to its opener", main.screen == "online" and not Net.online, main.screen)
	Net.members = {}
	print("ONLINE3D RESULT fails=", fails)
	get_tree().quit(fails)


func _ring_on(m: Menu3D, i: int, stop: int) -> bool:
	var rings: Array = (m.items[i].belt as Node3D).get_meta("focus_nodes", [])
	if rings.size() <= stop:
		return false
	for k in rings.size():
		if (rings[k] as Node3D).visible != (k == stop):
			return false
	return true


func _check(label: String, ok: bool, extra = "") -> void:
	print(("PASS  " if ok else "FAIL  ") + label + ("" if str(extra) == "" else "  [%s]" % str(extra)))
	if not ok:
		fails += 1


func _wait(s: float) -> void:
	await get_tree().create_timer(s).timeout


func _shot(name: String) -> void:
	if shots == "":
		return
	await _wait(0.8)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(shots.path_join(name + ".png"))


func _tap(btn: int) -> void:
	var e := InputEventJoypadButton.new(); e.device = 0; e.button_index = btn; e.pressed = true
	Input.parse_input_event(e)
	for i in 3: await get_tree().process_frame
	var u := InputEventJoypadButton.new(); u.device = 0; u.button_index = btn; u.pressed = false
	Input.parse_input_event(u)
	for i in 3: await get_tree().process_frame
