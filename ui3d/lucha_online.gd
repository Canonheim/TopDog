class_name LuchaOnline
extends RefCounted
## THE 3D ONLINE SCREENS (Parker 2026-11-07: "have the UI guy re design the Online
## UI with our new 3d UI. Also Make a Join Friends button."). Owned by LuchaUI; the
## same championship belts as every menu, so pad (ui_* actions, Steam Input
## included), keyboard and mouse all work.
##
## online   HOST PUBLIC, JOIN A FRIEND,
##          BROWSE GAMES, BACK. A status
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

const PAGE := 4  # rows per page (friends, games): they fit above REFRESH and BACK
const SIGN_SCALE := 2.05  # the kit sign (2.4 m) at board size
const RIBBON_SCALE := 1.45
const SIGN_W := 2.4 * SIGN_SCALE

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
## Tests only: stand-in friends rows ([{id, name, lobby}]) in place of Steam's.
var test_friends = null


func _init(p_ui: LuchaUI) -> void:
	ui = p_ui
	main = p_ui.main


func build() -> void:
	# ONLINE
	var o := ui._menu()
	o.set_header(LuchaKit.poster_text("PLAY ONLINE", 0.48, LuchaKit.GOLD, LuchaKit.RED, 0.1), Vector3(Menu3D.MENU_COLUMN_X, 3.25, 0))
	o.column_x = Menu3D.MENU_COLUMN_X
	o.top_y = Menu3D.MENU_TOP_Y
	o.add_button("HOST PUBLIC", func():
		main._ensure_player()
		Net.host_steam(Net.VIS_PUBLIC))
	o.add_button("JOIN A FRIEND", func(): main.show_screen("friends"))
	o.add_button("BROWSE GAMES", func(): main.show_screen("browse"))
	o.add_button("BACK", func(): main.show_screen("title"))
	ui.menus.online = o
	# FRIENDS
	var f := ui._menu()
	f.set_header(LuchaKit.poster_text("JOIN A FRIEND", 0.46, LuchaKit.GOLD, LuchaKit.RED, 0.1), Vector3(Menu3D.MENU_COLUMN_X, 3.25, 0))
	f.column_x = Menu3D.MENU_COLUMN_X
	f.top_y = Menu3D.MENU_TOP_Y
	ui.menus.friends = f
	# BROWSE
	var b := ui._menu()
	b.set_header(LuchaKit.poster_text("BROWSE GAMES", 0.46, LuchaKit.GOLD, LuchaKit.RED, 0.1), Vector3(Menu3D.MENU_COLUMN_X, 3.25, 0))
	b.column_x = Menu3D.MENU_COLUMN_X
	b.top_y = Menu3D.MENU_TOP_Y
	ui.menus.browse = b
	# LOBBY
	var l := ui._menu()
	l.set_header(LuchaKit.poster_text("LOBBY", 0.5, LuchaKit.GOLD, LuchaKit.RED, 0.1), Vector3(Menu3D.MENU_COLUMN_X, 3.25, 0))
	l.column_x = Menu3D.MENU_COLUMN_X
	l.top_y = Menu3D.MENU_TOP_Y
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
	Net.settings_changed.connect(_on_settings)
	Net.chat_line.connect(_on_chat)
	Net.lobby_list.connect(_on_lobby_list)


func _on_settings() -> void:
	if ui.current != "lobby":
		return
	if Net.is_host():
		_fill_lobby()
	else:
		_update_guest_settings()


func _update_guest_settings() -> void:
	var row := Modes.row(str(Net.settings.get("mode", "scramble")))
	set_status("%s, %d s clock, %s base. Press I'M READY, the host starts." % [str(row.name), int(Net.settings.get("timer", 60)), str(Net.settings.get("base", "random")).capitalize()])


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
	_status_node.visible = id in ["friends", "browse"]
	_board.visible = false
	_chat_board.visible = false
	_place_boards(id)
	match id:
		"online":
			if status_text == "":
				set_status("Steam ready. Host a game or join a friend." if Net.steam_ok else "Start Steam to play online.")
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
	# A short line rides the kit's ribbon; longer news goes on the sign board,
	# wrapped onto its cream face (never cut off).
	var sign := Node3D.new()
	var lines := wrap_words(status_text, 30, 3)
	if lines.size() == 1 and status_text.length() <= 26:
		var rb := LuchaKit.status_ribbon()
		rb.scale = Vector3.ONE * RIBBON_SCALE
		rb.position = Vector3(SIGN_W * 0.5, -0.32, 0)
		sign.add_child(rb)
		var t := LuchaKit.fit_text(lines[0], 2.5 * RIBBON_SCALE, 0.2, LuchaKit.RED, LuchaKit.INK)
		t.position = Vector3(SIGN_W * 0.5, -0.32, 0.04 * RIBBON_SCALE + 0.03)
		sign.add_child(t)
	else:
		var sb := LuchaKit.sign_board()
		sb.scale = Vector3.ONE * SIGN_SCALE
		sb.position = Vector3(SIGN_W * 0.5, -0.3 * SIGN_SCALE, 0)
		sign.add_child(sb)
		var step := 0.27
		var top := -0.3 * SIGN_SCALE + (lines.size() - 1) * step * 0.5
		for i in lines.size():
			var t := LuchaKit.fit_text(lines[i], 1.9 * SIGN_SCALE, 0.19, LuchaKit.RED, LuchaKit.INK)
			t.position = Vector3(SIGN_W * 0.5, top - i * step, 0.05 * SIGN_SCALE + 0.03)
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
	var rows := clampi(ceili(_card_count() / 4.0), 1, 3)
	_board.scale = Vector3.ONE * LuchaUI.UI_SCALE * ([1.0, 0.62, 0.46][rows - 1])
	if id == "lobby":
		_status_node.position = Vector3(0.1, [0.35, 0.05, -0.6][rows - 1], -LuchaUI.MENU_DIST)
		_chat_board.position = Vector3(0.15, [-0.38, -0.62, -1.27][rows - 1], -LuchaUI.MENU_DIST)
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
	var rows: Array = test_friends if test_friends != null else Net.friends_in_game()
	if rows.is_empty() and not Net.steam_ok:
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
		var plate := LuchaKit.friend_row(nm, "IN A GAME" if lobby != 0 else "PLAYING, NOT IN A GAME", lobby != 0)
		_load_avatar(plate, int(fr.get("id", 0)))
		var ri := m.add_row(plate, func(_stop):
			if lobby == 0:
				set_status("%s is playing, but not in a game yet." % str(fr.get("name", "")))
				return
			main._ensure_player()
			set_status("Joining %s..." % str(fr.get("name", "")))
			Net.join_steam(lobby))
		m.items[ri].label = "FRIEND %s" % nm
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
		set_status("")
	elif ui.current == "browse" and status_text != "Looking for games...":
		set_status("No games found. Host one!")
	var start := _browse_page * PAGE
	for k in range(start, mini(_browse_rows.size(), start + PAGE)):
		var r: Dictionary = _browse_rows[k]
		var ok := bool(r.get("joinable", false))
		var plate := LuchaKit.lobby_row(str(r.get("name", "?")).to_upper().left(20), str(r.get("mode_line", "")).to_upper(),
			str(r.get("count_text", "")), "JOIN" if ok else str(r.get("short", "NO")).to_upper().left(6), ok)
		var ri := m.add_row(plate, func(_stop):
			if not ok:
				set_status(str(r.get("reason", r.get("short", "Can't join"))))
				return
			main._ensure_player()
			set_status("Joining %s..." % str(r.get("name", "")))
			Net.join_steam(int(r.get("id", 0))))
		m.items[ri].label = "GAME %s" % str(r.get("name", "?"))
		m.items[ri].layout_position = Vector3(2.4, Menu3D.MENU_TOP_Y - (k - start) * 0.95, 0)
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
		var mode_ids := ["scramble", "tower", "delmar"]
		m.add_choice("MODE", mode_ids.map(func(id): return str(Modes.row(id).name).to_upper()), maxi(0, mode_ids.find(str(Net.settings.get("mode", "scramble")))), func(i):
			var s: Dictionary = Net.settings.duplicate()
			s.mode = mode_ids[i]
			Net.set_settings(s))
		m.add_choice("CLOCK", Modes.TIMER_NAMES, maxi(0, Modes.TIMERS.find(float(Net.settings.get("timer", 60.0)))), func(i):
			var s: Dictionary = Net.settings.duplicate()
			s.timer = Modes.TIMERS[i]
			Net.set_settings(s))
		m.add_choice("BASE", Modes.BASE_NAMES.map(func(n): return n.to_upper()), maxi(0, Modes.BASES.find(str(Net.settings.get("base", "random")))), func(i):
			var s: Dictionary = Net.settings.duplicate()
			s.base = Modes.BASES[i]
			Net.set_settings(s))

		m.add_button("INVITE FRIENDS", func(): Net.invite_friends())
		m.add_button("LEAVE", main._leave_lobby)
	else:
		m.close()
		return
	m.refresh()
	m.focus = clampi(keep, 0, m.items.size() - 1)
	_place_boards("lobby")
	if not host:
		_update_guest_settings()
	elif status_text == "" or status_text.begins_with("Hosting"):
		set_status("You're hosting. Invite friends, then FIGHT! when everyone's ready.")


func _start() -> void:
	if not Net.is_host():
		set_status("Only the host can start.")
		return
	if Net._climber_count() < int(Modes.row(str(Net.settings.get("mode", "scramble"))).min_players):
		set_status("Classic needs at least two players.")
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
			if n >= Net.MAX_CLIMBERS:
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
			var stamp := LuchaKit.ready_stamp(ready)
			stamp.position = Vector3(0.5, -0.8, 0.12)
			stamp.scale = Vector3.ONE * 0.85
			stamp.rotation.z = -0.18
			card.add_child(stamp)
			_board.add_child(card)
			n += 1
	LuchaUI.no_shadows(_board)


func _on_chat(who: String, text: String) -> void:
	chat_lines.append([who, text])
	while chat_lines.size() > 3:
		chat_lines.pop_front()
	if ui.current == "lobby":
		_fill_chat()


func _fill_chat() -> void:
	for ch in _chat_board.get_children():
		ch.queue_free()
	# The last three lines as the kit's bubbles, side by side, newest on the right.
	for i in chat_lines.size():
		var who: String = str(chat_lines[i][0]).to_upper()
		var text: String = str(chat_lines[i][1]).to_upper()
		if text.length() > 22:
			text = text.left(20) + "..."
		var b := LuchaKit.chat_bubble(who.split(" THE ")[0].left(16), text, i % 2 == 1)
		b.position = Vector3(0.95 + i * 2.0, 0, 0)
		_chat_board.add_child(b)
	LuchaUI.no_shadows(_chat_board)


# ---------------------------------------------------------------- avatars

## The friend's Steam picture on the row's avatar disc, when Steam hands it over
## (GodotSteam: getPlayerAvatar -> avatar_loaded). Until then the initial shows.
var _avatar_wait := {}  # steam id -> [plate]


func _load_avatar(plate: Node3D, sid: int) -> void:
	if sid == 0 or not Net.steam_ok or not Steam.has_signal("avatar_loaded") or not Steam.has_method("getPlayerAvatar"):
		return
	if not Steam.is_connected("avatar_loaded", _on_avatar):
		Steam.connect("avatar_loaded", _on_avatar)
	if not _avatar_wait.has(sid):
		_avatar_wait[sid] = []
	_avatar_wait[sid].append(plate)
	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, sid)


func _on_avatar(sid: int, size: int, data: PackedByteArray) -> void:
	if not _avatar_wait.has(sid) or size <= 0 or data.size() < size * size * 4:
		return
	var img := Image.create_from_data(size, size, false, Image.FORMAT_RGBA8, data)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = ImageTexture.create_from_image(img)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for plate in _avatar_wait[sid]:
		if not is_instance_valid(plate):
			continue
		var disc = plate.get_meta("avatar") if plate.has_meta("avatar") else null
		if disc is MeshInstance3D:
			(disc as MeshInstance3D).material_override = mat
			var ini := (plate as Node3D).get_node_or_null("initial")
			if ini != null:
				ini.visible = false
	_avatar_wait.erase(sid)
