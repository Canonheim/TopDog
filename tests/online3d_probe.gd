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
	# PLAY ONLINE is the title's first belt (Play Together is off the title since 11-10)
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
	# Public hosting uses the same full-size button as the rest of this menu.
	_check("online has Public, Join a Friend, Browse Games and Back", online.items.map(func(i): return i.label) == ["HOST PUBLIC", "JOIN A FRIEND", "BROWSE GAMES", "BACK"])
	_check("Public matches the other button types and widths", online.items.all(func(i): return i.kind == "button") and is_equal_approx(float(online.items[0].belt.get_meta("width", Menu3D.BELT_W)), float(online.items[1].belt.get_meta("width", Menu3D.BELT_W))))
	online.focus = 0
	await _tap(JOY_BUTTON_DPAD_RIGHT)
	_check("Public has no Friends or Invite hosting choices", online.items[0].kind == "button" and online.focus == 0)
	var previous_settings: Dictionary = Net.settings.duplicate(true)
	main.preview_base("cactus")
	var base: Node3D = main.game.stage.base_root
	Net.settings.base = "random"
	for timer in Modes.TIMERS:
		Net.settings.timer = timer
		Net.settings_changed.emit()
	_check("clock changes never reroll the random base preview", main.game.stage.base_root == base and main.game.stage.base_id == "cactus")
	main.preview_base("random")
	_check("selecting Random defers selection to match start", main.game.stage.base_root == base)
	Net.settings = previous_settings
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
	# Games as kit rows: isolate the fixture from outstanding Steam search replies.
	Net.lobby_list.disconnect(main.lucha.online._on_lobby_list)
	main.show_screen("browse")
	main.lucha.online._on_lobby_list([
		{"id": 5, "name": "Parker's ring", "count_text": "3/12", "mode_line": "Tower", "joinable": true, "reason": "", "short": ""},
		{"id": 6, "name": "Big Barrel Bash", "count_text": "12/12", "mode_line": "Classic", "joinable": false, "reason": "That game is full.", "short": "Full"},
	])
	await _wait(0.8)
	var br: Menu3D = main.lucha.menus.browse
	_check("games come in as kit rows", br.items.size() >= 4 and br.items[0].kind == "row", br.items.size())
	await _shot("browse_rows")
	Net.lobby_list.connect(main.lucha.online._on_lobby_list)
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
	_check("multiplayer menu has no Say button", not lobby.items.any(func(item): return str(item.get("label", "")) == "SAY"))
	await _shot("lobby")
	for pid in range(3, 12):
		Net.members[pid] = {"name": "Player %d" % (pid + 1), "players": [{"name": "Player %d" % (pid + 1), "tint": NameGen.tint(pid), "slot": 0}], "ready": true}
	main.lucha.online._fill_lobby()
	await _wait(0.5)
	_check("all twelve lobby cards are visible", main.lucha.online._board.get_child_count() == 12)
	await _shot("lobby12")
	var saved_peer: MultiplayerPeer = multiplayer.multiplayer_peer
	var guest := ENetMultiplayerPeer.new()
	guest.create_client("127.0.0.1", 17979)
	multiplayer.multiplayer_peer = guest
	main.lucha.online._fill_lobby()
	var guest_button: Node3D = lobby.items[0].node
	var guest_scale := guest_button.scale
	lobby.focus = 1
	main.lucha.online._on_settings()
	_check("host settings preserve guest buttons, focus and animation", lobby.items[0].node == guest_button and guest_button.scale == guest_scale and lobby.focus == 1)
	multiplayer.multiplayer_peer = saved_peer
	guest.close()
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
