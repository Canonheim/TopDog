class_name LuchaOnline
extends RefCounted
## THE 3D ONLINE SCREENS (Parker 2026-11-07: "have the UI guy re design the Online
## UI with our new 3d UI. Also Make a Join Friends button."). Owned by LuchaUI; the
## same championship belts as every menu, so pad (ui_* actions, Steam Input
## included), keyboard and mouse all work.
##
## online   HOST (public / friends / invite, flipped left-right), JOIN A FRIEND,
##          BROWSE GAMES, LAN (host / join this PC / type an IP), BACK. A status
##          poster under the header shows Net's status line.
## friends  your Steam friends playing Top Dog (Net.friends_in_game): JOIN their
##          game, or "not in a game"; REFRESH; BACK.
## browse   the lobby list (Net.request_lobby_list -> lobby_list rows from
##          lobby_logic), six at a time; REFRESH; BACK.
## lobby    READY / START (host) / mode, clock and spawn (host) / CHAT presets /
##          INVITE FRIENDS / LEAVE, the players as fight-poster cards with READY
##          stamps, and a chat board.
##
## Typing (an IP, typed chat) still uses the flat Online page ("TYPE AN IP").

const PAGE := 6
const SIGN_W := 4.9  # the status sign, in board units (x UI_SCALE on screen)

var ui: LuchaUI
var main: Node
var status_text := ""
var chat_lines: Array = []
var _friends_page := 0
var _browse_page := 0
var _browse_rows: Array = []
var _lobby_ready_item := -1
var _status_node: Node3D
var _board: Node3D  # cards + chat on the lobby; rows on browse/friends
var _chat_board: Node3D


func _init(p_ui: LuchaUI) -> void:
	ui = p_ui
	main = p_ui.main


func build() -> void:
	# ONLINE
	var o := ui._menu()
	o.set_header(LuchaKit.poster_text("PLAY ONLINE", 0.48, LuchaKit.GOLD, LuchaKit.RED, 0.1), Vector3(-2.4, 2.75, 0))
	o.column_x = -2.4
	o.top_y = 1.25
	o.add_choice_button("HOST", ["PUBLIC", "FRIENDS", "INVITE ONLY"], 0, func(i):
		main._ensure_player()
		Net.host_steam([Net.VIS_PUBLIC, Net.VIS_FRIENDS, Net.VIS_INVITE][i]))
	o.add_button("JOIN A FRIEND", func(): main.show_screen("friends"))
	o.add_button("BROWSE GAMES", func(): main.show_screen("browse"))
	o.add_choice_button("LAN", ["HOST", "JOIN THIS PC", "TYPE AN IP"], 0, _lan)
	o.add_button("BACK", func(): main.show_screen("title"))
	ui.menus.online = o
	# FRIENDS
	var f := ui._menu()
	f.set_header(LuchaKit.poster_text("JOIN A FRIEND", 0.46, LuchaKit.GOLD, LuchaKit.RED, 0.1), Vector3(-2.4, 2.75, 0))
	f.column_x = -2.4
	f.top_y = 1.25
	ui.menus.friends = f
	# BROWSE
	var b := ui._menu()
	b.set_header(LuchaKit.poster_text("BROWSE GAMES", 0.46, LuchaKit.GOLD, LuchaKit.RED, 0.1), Vector3(-2.4, 2.75, 0))
	b.column_x = -2.4
	b.top_y = 1.25
	ui.menus.browse = b
	# LOBBY
	var l := ui._menu()
	l.set_header(LuchaKit.poster_text("LOBBY", 0.5, LuchaKit.GOLD, LuchaKit.RED, 0.1), Vector3(-2.4, 2.75, 0))
	l.column_x = -2.4
	l.top_y = 1.4
	ui.menus.lobby = l
	# The status poster, shared by every online screen, and the lobby's boards.
	_status_node = Node3D.new()
	ui.cam.add_child(_status_node)
	_status_node.position = Vector3(0.0, 1.0, -LuchaUI.MENU_DIST)
	_status_node.scale = Vector3.ONE * LuchaUI.UI_SCALE
	_board = Node3D.new()
	ui.cam.add_child(_board)
	_board.position = Vector3(0.35, 0.9, -LuchaUI.MENU_DIST)
	_board.scale = Vector3.ONE * LuchaUI.UI_SCALE
	_chat_board = Node3D.new()
	ui.cam.add_child(_chat_board)
	_chat_board.position = Vector3(0.6, -1.2, -LuchaUI.MENU_DIST)
	_chat_board.scale = Vector3.ONE * LuchaUI.UI_SCALE
	Net.status.connect(func(t): set_status(t))
	Net.members_changed.connect(_on_members)
	Net.settings_changed.connect(_on_members)
	Net.chat_line.connect(_on_chat)
	Net.lobby_list.connect(_on_lobby_list)


func _lan(i: int) -> void:
	main._ensure_player()
	if i == 0:
		Net.host_lan()
	elif i == 1:
		Net.join_lan("127.0.0.1")
	else:
		main.show_screen("online_flat")


func _on_members() -> void:
	if ui.current == "lobby":
		_fill_lobby()


func _on_lobby_list(rows: Array) -> void:
	_browse_rows = rows
	_browse_page = 0
	if ui.current == "browse":
		_fill_browse()


## LuchaUI calls this on every screen change.
func on_screen(id: String) -> void:
	var online_ids := ["online", "friends", "browse", "lobby"]
	_status_node.visible = id in online_ids
	_board.visible = id == "lobby"
	_chat_board.visible = id == "lobby"
	_place_boards(id)
	match id:
		"online":
			if status_text == "":
				set_status("Steam ready. Host a game or join a friend." if Net.steam_ok else "Steam isn't running: LAN only.")
		"friends":
			_friends_page = 0
			_fill_friends()
		"browse":
			_browse_rows = []
			_fill_browse()
			set_status("Looking for games...")
			Net.request_lobby_list()
		"lobby":
			status_text = ""
			_fill_lobby()
		"online_flat":
			# Typing an IP: the flat page, for now.
			main.screens.online.visible = true
			if main.pad_nav != null:
				main.pad_nav.screen_root = main.screens.online
	_redraw_status()


func set_status(t: String) -> void:
	status_text = t
	_redraw_status()


func _redraw_status() -> void:
	if _status_node == null:
		return
	for ch in _status_node.get_children():
		ch.queue_free()
	if status_text == "":
		return
	# A red sign with a gold rim, the words wrapped onto it (never cut off).
	var lines := wrap_words(status_text, 32, 3)
	var h := lines.size() * 0.3 + 0.26
	var sign := Node3D.new()
	sign.add_child(LuchaKit.box(Vector3(SIGN_W + 0.16, h + 0.16, 0.08), LuchaKit.GOLD, Vector3(SIGN_W * 0.5, -h * 0.5, -0.06)))
	sign.add_child(LuchaKit.box(Vector3(SIGN_W, h, 0.1), LuchaKit.RED, Vector3(SIGN_W * 0.5, -h * 0.5, 0)))
	for i in lines.size():
		var t := LuchaKit.poster_text(lines[i], 0.18, LuchaKit.CREAM, LuchaKit.INK, 0.03)
		t.position = Vector3(SIGN_W * 0.5, -0.27 - i * 0.3, 0.07)
		sign.add_child(t)
	_status_node.add_child(sign)
	LuchaUI.no_shadows(sign)


## Words onto lines of at most `width` letters; past `max_lines` the last ends "...".
static func wrap_words(text: String, width: int, max_lines: int) -> PackedStringArray:
	var out := PackedStringArray()
	var line := ""
	for w in text.to_upper().split(" ", false):
		if line != "" and line.length() + 1 + w.length() > width:
			out.append(line)
			line = w
		else:
			line = w if line == "" else line + " " + w
	if line != "":
		out.append(line)
	if out.size() > max_lines:
		out.resize(max_lines)
		out[max_lines - 1] = out[max_lines - 1].left(width - 3) + "..."
	return out


## Where the sign and chat sit: right of the belts; in the lobby, under the cards.
func _place_boards(id: String) -> void:
	var rows := 1 if _card_count() <= 4 else 2
	_board.scale = Vector3.ONE * LuchaUI.UI_SCALE * (1.0 if rows == 1 else 0.62)
	if id == "lobby":
		_status_node.position = Vector3(0.1, 0.35 if rows == 1 else 0.05, -LuchaUI.MENU_DIST)
		_chat_board.position = Vector3(0.15, -0.38 if rows == 1 else -0.62, -LuchaUI.MENU_DIST)
	else:
		_status_node.position = Vector3(0.1, 1.0, -LuchaUI.MENU_DIST)


func _card_count() -> int:
	var n := 0
	for id in Net.members:
		n += (Net.members[id].get("players", []) as Array).size()
	return n


# ---------------------------------------------------------------- friends

func _fill_friends() -> void:
	var m: Menu3D = ui.menus.friends
	m.clear_items()
	var rows: Array = Net.friends_in_game() if Net.has_method("friends_in_game") else []
	if not Net.steam_ok:
		set_status("Steam isn't running: start Steam and restart to play with friends.")
	elif rows.is_empty():
		set_status("No friends playing Top Dog right now. Invite one from Steam!")
	else:
		set_status("%d friend%s playing. Pick one to join their game." % [rows.size(), "" if rows.size() == 1 else "s"])
	var start := _friends_page * PAGE
	for k in range(start, mini(rows.size(), start + PAGE)):
		var fr: Dictionary = rows[k]
		var nm := str(fr.get("name", "?")).to_upper().left(16)
		var lobby := int(fr.get("lobby", 0))
		if lobby != 0:
			m.add_button("JOIN %s" % nm, func():
				main._ensure_player()
				set_status("Joining %s..." % str(fr.get("name", "")))
				Net.join_steam(lobby))
		else:
			m.add_button("%s (NOT IN A GAME)" % nm, func(): set_status("%s is playing, but not in a game yet." % str(fr.get("name", ""))))
	if rows.size() > start + PAGE:
		m.add_button("MORE FRIENDS", func(): _friends_page += 1; _fill_friends())
	if Net.steam_ok:
		m.add_button("INVITE FROM STEAM", func():
			if Steam.isOverlayEnabled():
				Steam.activateGameOverlay("Friends")
			else:
				set_status("The Steam overlay isn't up here: launch through Steam to invite."))
	m.add_button("REFRESH", func(): _friends_page = 0; _fill_friends())
	m.add_button("BACK", func(): main.show_screen("online"))
	m.refresh()


# ---------------------------------------------------------------- browse

func _fill_browse() -> void:
	var m: Menu3D = ui.menus.browse
	m.clear_items()
	if not _browse_rows.is_empty():
		set_status("%d game%s found." % [_browse_rows.size(), "" if _browse_rows.size() == 1 else "s"])
	elif ui.current == "browse" and status_text != "Looking for games...":
		set_status("No games found. Host one!")
	var start := _browse_page * PAGE
	for k in range(start, mini(_browse_rows.size(), start + PAGE)):
		var r: Dictionary = _browse_rows[k]
		var label := "%s  %s  %s" % [str(r.get("name", "?")).to_upper().left(14), str(r.get("count_text", "")), str(r.get("mode_line", "")).to_upper()]
		if bool(r.get("joinable", false)):
			m.add_button(label, func():
				main._ensure_player()
				set_status("Joining %s..." % str(r.get("name", "")))
				Net.join_steam(int(r.get("id", 0))))
		else:
			m.add_button(label, func(): set_status(str(r.get("reason", r.get("short", "Can't join")))))
	if _browse_rows.size() > start + PAGE:
		m.add_button("MORE GAMES", func(): _browse_page += 1; _fill_browse())
	m.add_button("REFRESH", func():
		set_status("Looking for games...")
		Net.request_lobby_list())
	m.add_button("BACK", func(): main.show_screen("online"))
	m.refresh()


# ---------------------------------------------------------------- lobby

func _fill_lobby() -> void:
	var m: Menu3D = ui.menus.lobby
	var keep := m.focus
	m.clear_items()
	var host := Net.is_host()
	var me: Dictionary = Net.members.get(Net.me(), {})
	if host:
		m.add_button("FIGHT!", _start)
		var mode_ids := ["tower", "scramble"]
		m.add_choice("MODE", mode_ids.map(func(id): return str(Modes.row(id).name).to_upper()), maxi(0, mode_ids.find(str(Net.settings.get("mode", "tower")))), func(i):
			var s: Dictionary = Net.settings.duplicate()
			s.mode = mode_ids[i]
			Net.set_settings(s))
		m.add_choice("CLOCK", ["40 S", "1 MIN", "1:30"], maxi(0, Modes.TIMERS.find(float(Net.settings.get("timer", 60.0)))), func(i):
			var s: Dictionary = Net.settings.duplicate()
			s.timer = Modes.TIMERS[i]
			Net.set_settings(s))
	else:
		_lobby_ready_item = m.add_button("I'M READY!" if not bool(me.get("ready", false)) else "NOT READY", func():
			Net.set_ready(not bool(Net.members.get(Net.me(), {}).get("ready", false))))
	m.add_choice_button("SAY", Net.CHAT_PRESETS.map(func(t): return str(t).to_upper()), 0, func(i): Net.send_chat(Net.CHAT_PRESETS[i]))
	m.add_button("INVITE FRIENDS", func(): Net.invite_friends())
	m.add_button("LEAVE", func():
		Net.leave()
		main._to_title(""))
	m.refresh()
	m.focus = clampi(keep, 0, m.items.size() - 1)
	_fill_cards()
	_fill_chat()
	_place_boards("lobby")
	if not host:
		var mrow := Modes.row(str(Net.settings.get("mode", "tower")))
		set_status("%s, %d s clock. Press I'M READY, the host starts." % [str(mrow.name), int(Net.settings.get("timer", 60))])
	elif status_text == "" or status_text.begins_with("Hosting"):
		set_status("You're hosting. Invite friends, then FIGHT! when everyone's ready.")


func _start() -> void:
	if not Net.is_host():
		set_status("Only the host can start.")
		return
	if not Net.all_ready():
		set_status("Waiting for everyone to press READY.")
		return
	main._start_online()


func _fill_cards() -> void:
	for ch in _board.get_children():
		ch.queue_free()
	var ids: Array = Net.members.keys()
	ids.sort()
	var n := 0
	for id in ids:
		var mem: Dictionary = Net.members[id]
		var ready: bool = id == 1 or bool(mem.get("ready", false))
		for p in mem.get("players", []):
			if n >= 8:
				break
			var tint: Color = p.get("tint", Color.WHITE) if p.get("tint") is Color else Color.WHITE
			var card := LuchaKit.card_frame(LuchaKit.CREAM, tint)
			card.position = Vector3((n % 4) * LuchaUI.CARD_DX, -(n / 4) * LuchaUI.CARD_DY, 0)
			var num := LuchaKit.poster_text("HOST" if id == 1 else "P%d" % (n + 1), 0.2, LuchaKit.CREAM, LuchaKit.INK, 0.04)
			num.position = Vector3(0, 0.56, 0.06)
			card.add_child(num)
			var mask := LuchaKit.mask_icon(tint, LuchaKit.GOLD)
			mask.position = Vector3(0, -0.04, 0.12)
			card.add_child(mask)
			var who := LuchaKit.poster_text(str(p.get("name", "?")).split(" the ")[0].to_upper(), 0.13, LuchaKit.INK, LuchaKit.CREAM, 0.02)
			who.position = Vector3(0, -0.4, 0.06)
			card.add_child(who)
			var stamp := LuchaKit.poster_text("READY!" if ready else "...", 0.11, LuchaKit.CREAM, LuchaKit.INK, 0.02)
			stamp.position = Vector3(0, -0.63, 0.06)
			card.add_child(stamp)
			_board.add_child(card)
			n += 1
	LuchaUI.no_shadows(_board)


func _on_chat(who: String, text: String) -> void:
	chat_lines.append(("%s: %s" % [who, text]) if who != "" else text)
	while chat_lines.size() > 3:
		chat_lines.pop_front()
	if ui.current == "lobby":
		_fill_chat()


func _fill_chat() -> void:
	for ch in _chat_board.get_children():
		ch.queue_free()
	var y := 0.0
	for line in chat_lines:
		var s: String = line if line.length() <= 40 else line.left(37) + "..."
		var t := LuchaKit.poster_text(s.to_upper(), 0.17, LuchaKit.CREAM, LuchaKit.INK, 0.02)
		t.position = Vector3(s.length() * 0.053, y, 0)
		_chat_board.add_child(t)
		y -= 0.27
	LuchaUI.no_shadows(_chat_board)
