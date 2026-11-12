extends Node
## NET: sessions and the lobby. Autoload "Net".
##
## Transports (nothing above this file knows which is in use):
## - Steam: GodotSteam's SteamMultiplayerPeer over a Steam lobby (Valve's relay,
##   no ports). App 480 (Spacewar) with our own lobby tag until our own app exists.
##
## The lobby: every machine sends the host its local players; the host keeps the
## member list, ready flags, chat and match settings, and starts the match through
## Game (game/game.gd), which owns everything after that.
##
## Lifted from Golemheim's net.gd (Steam init, lobby create/join/browse, invites,
## +connect_lobby, the version gate, the ghost-lobby and crossed-join guards), cut
## down to this game. See docs/PROVENANCE.md.

signal status(text: String)
signal members_changed
signal chat_line(who: String, text: String)
signal settings_changed
signal session_started  # we're connected (host or client)
signal session_ended(reason: String)
signal lobby_list(rows: Array)

const LobbyLogic := preload("res://net/lobby_logic.gd")
const SteamInputScript := preload("res://core/steam_input.gd")

const STEAM_APP_ID := 480  # Spacewar (Valve's dev app) until Top Your Pals has its own
const LOBBY_TAG := "topdog"  # must equal lobby_logic.gd GAME_TAG
const GAME_VERSION := "0.3.90"  # bump on every build: RPC tables move between builds
const MAX_MACHINES := 20  # Parker 11-10: "raise loby cap to 20"
const MAX_CLIMBERS := 20
const CHAT_PRESETS := ["Hello!", "Ready!", "Not ready", "Nice one!", "Oops!", "Get off me!", "Hold on!", "GG"]

const VIS_PUBLIC := "public"
const VIS_FRIENDS := "friends"
const VIS_INVITE := "invite"

var steam_ok := false
## Reads controllers through Steam's controller API (core/steam_input.gd); made when Steam starts.
var steam_input: Node = null
var steam_lobby := 0
var online := false
## peer id -> {"name": String, "players": [{name, tint}], "ready": bool}
var members := {}
var settings := Modes.default_settings()
var in_match := false

var _pending_lobby := false
var _joining_lobby := 0
var _join_started_ms := 0
var _awaiting_accept := false
const JOIN_TIMEOUT_MS := 20000
var _hosting := false
var _invite_lobby := 0
var _list_wanted := false
var _chat_times := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Steam starts when Online play opens (ensure_steam), not at boot. PROVEN by
	# Parker on 0.1.3: his pad worked only with Steam off. On the shared dev app
	# (480) Steam applies Spacewar's controller settings, which hand the game
	# nothing. (0.1.1's late start looked like it failed only because Practice was
	# hard-wired to the keyboard then.) Our own app ID ends this. --steam starts it
	# at boot; +connect_lobby starts it for an invite.
	if "--steam" in OS.get_cmdline_user_args():
		_init_steam()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(func(): _end("Couldn't connect"))
	multiplayer.server_disconnected.connect(func(): _end("Host left"))
	var argv := OS.get_cmdline_args()
	for i in argv.size():
		# Steam launches a CLOSED game with +connect_lobby <id> when a friend
		# accepts an invite; join_requested only fires for a running game.
		if argv[i] == "+connect_lobby" and i + 1 < argv.size() and int(argv[i + 1]) > 0:
			_init_steam()
			call_deferred("join_steam", int(argv[i + 1]))


func _process(_delta: float) -> void:
	if steam_ok:
		Steam.run_callbacks()  # every frame, online or not: invites arrive here
	if _hosting and _pending_lobby and Time.get_ticks_msec() - _host_started_ms >= JOIN_TIMEOUT_MS:
		# Steam never answered the lobby request: let the player try again.
		_pending_lobby = false
		_hosting = false
		status.emit("Steam didn't answer. Try hosting again.")
	if _joining_lobby != 0:
		var peer := multiplayer.multiplayer_peer
		if not _awaiting_accept and peer is SteamMultiplayerPeer and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
			_on_connected()
		if Time.get_ticks_msec() - _join_started_ms >= JOIN_TIMEOUT_MS:
			leave()
			status.emit("The host did not finish connecting. Refresh the list and try joining again.")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		leave()


## Cut our connections on the Steam singleton as the tree closes (Golemheim's
## THE STEAM EXIT CUT: GodotSteam's teardown crashed a quit holding them).
func _exit_tree() -> void:
	if not ClassDB.class_exists(&"Steam"):
		return
	for sig in Steam.get_signal_list():
		for c in Steam.get_signal_connection_list(sig.name):
			if c.callable.get_object() == self:
				Steam.disconnect(sig.name, c.callable)


func is_host() -> bool:
	return multiplayer.multiplayer_peer == null or multiplayer.is_server()


func me() -> int:
	return multiplayer.get_unique_id()


func my_name() -> String:
	if steam_ok:
		return str(Steam.getPersonaName())
	return OS.get_environment("USERNAME") if OS.get_environment("USERNAME") != "" else "Player"


# ================================================================ Steam

var _steam_tried := false


## Start Steam once, on first need (the Online screen).
func ensure_steam() -> void:
	if not _steam_tried:
		_init_steam()


func _init_steam() -> void:
	if _steam_tried:
		return
	_steam_tried = true
	if "--no-steam" in OS.get_cmdline_user_args() or not ClassDB.class_exists(&"Steam"):
		return
	var res: Dictionary = Steam.steamInitEx(STEAM_APP_ID, false)
	if int(res.get("status", -1)) != Steam.STEAM_API_INIT_RESULT_OK:
		print("[Net] Steam init failed (is Steam running?): ", res)
		return
	steam_ok = true
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.join_requested.connect(_on_join_requested)
	Steam.lobby_data_update.connect(_on_lobby_data_update)
	print("[Net] Steam ready: ", Steam.getPersonaName())
	# Steam takes the controllers once it's running here: read them through it.
	steam_input = SteamInputScript.new()
	steam_input.name = "SteamInput"
	add_child(steam_input)
	steam_input.start()


func host_steam(visibility := VIS_PUBLIC, lobby_name := "") -> void:
	if online or _pending_lobby:
		return  # one round-trip at a time: a second createLobby tore the live peer
	if not steam_ok:
		status.emit("Steam isn't running. Start Steam and restart the game.")
		return
	_pending_lobby = true
	_hosting = true
	_host_started_ms = Time.get_ticks_msec()
	_pending_name = lobby_name if lobby_name != "" else "%s's climb" % my_name()
	status.emit("Creating a Steam lobby...")
	var t := Steam.LOBBY_TYPE_PUBLIC
	if visibility == VIS_FRIENDS:
		t = Steam.LOBBY_TYPE_FRIENDS_ONLY
	elif visibility == VIS_INVITE:
		t = Steam.LOBBY_TYPE_PRIVATE
	Steam.createLobby(t, MAX_MACHINES)


var _pending_name := ""
var _host_started_ms := 0


func _on_lobby_created(result: int, lobby_id: int) -> void:
	_pending_lobby = false
	_hosting = false
	if result != Steam.RESULT_OK:
		status.emit("Steam lobby failed (%d)" % result)
		return
	if online:
		Steam.setLobbyJoinable(lobby_id, false)
		Steam.leaveLobby(lobby_id)
		return
	steam_lobby = lobby_id
	Steam.setLobbyData(lobby_id, "game", LOBBY_TAG)
	Steam.setLobbyData(lobby_id, "version", GAME_VERSION)
	Steam.setLobbyData(lobby_id, "name", _pending_name)
	Steam.setLobbyData(lobby_id, "host", my_name())
	Steam.setLobbyData(lobby_id, "mode", str(settings.mode))
	Steam.setLobbyJoinable(lobby_id, true)
	var peer := SteamMultiplayerPeer.new()
	var err = peer.host_with_lobby(lobby_id)
	if err is int and err != OK:
		# NO GHOST LOBBY: never leave a tagged, joinable room nobody serves.
		Steam.setLobbyJoinable(lobby_id, false)
		Steam.leaveLobby(lobby_id)
		steam_lobby = 0
		status.emit("Steam socket failed (%s)" % err)
		return
	multiplayer.multiplayer_peer = peer
	_start_session_as_host()
	status.emit("Hosting on Steam. Invite friends from the overlay (Shift+Tab) or the Invite button.")


func request_lobby_list() -> void:
	if not steam_ok:
		lobby_list.emit([])
		return
	_list_wanted = true
	Steam.addRequestLobbyListStringFilter("game", LOBBY_TAG, Steam.LOBBY_COMPARISON_EQUAL)
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()


func _on_lobby_match_list(lobbies: Array) -> void:
	if not _list_wanted:
		return
	_list_wanted = false
	var raw: Array = []
	for l in lobbies:
		raw.append({
			"id": int(l), "game": Steam.getLobbyData(l, "game"), "version": Steam.getLobbyData(l, "version"),
			"name": Steam.getLobbyData(l, "name"), "host": Steam.getLobbyData(l, "host"),
			"mode": Steam.getLobbyData(l, "mode"), "count": Steam.getNumLobbyMembers(l), "max": Steam.getLobbyMemberLimit(l),
		})
	lobby_list.emit(LobbyLogic.rows_from(raw, GAME_VERSION))


func join_steam(lobby_id: int) -> void:
	if _pending_lobby:
		if _joining_lobby != 0 and Time.get_ticks_msec() - _join_started_ms >= JOIN_TIMEOUT_MS:
			leave()
		else:
			status.emit("Still connecting to the lobby. Please wait...")
			return
	if online:
		status.emit("Already connected. Leave the current lobby before joining another.")
		return
	if lobby_id == 0:
		status.emit("This lobby is no longer available. Refresh the list.")
		return
	if not steam_ok:
		status.emit("Steam isn't running.")
		return
	_pending_lobby = true
	_joining_lobby = lobby_id
	_join_started_ms = Time.get_ticks_msec()
	_awaiting_accept = false
	status.emit("Joining lobby...")
	Steam.joinLobby(lobby_id)

## THE FRIENDS LIST (lifted from Golemheim's friends_in_game): Steam friends running
## this game right now, [{id, name, lobby}], those in a joinable game first. lobby 0
## means playing but not in a game you can join. Empty without Steam.
func friends_in_game() -> Array:
	var out: Array = []
	ensure_steam()
	if not steam_ok:
		return out
	var app := int(Steam.getAppID())
	var flag := int(Steam.FRIEND_FLAG_IMMEDIATE)
	for i in int(Steam.getFriendCount(flag)):
		var sid := int(Steam.getFriendByIndex(i, flag))
		var gp: Dictionary = Steam.getFriendGamePlayed(sid)
		if gp.is_empty() or int(gp.get("id", 0)) != app:
			continue
		out.append({"id": sid, "name": str(Steam.getFriendPersonaName(sid)), "lobby": int(gp.get("lobby", 0))})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if (int(a.lobby) != 0) != (int(b.lobby) != 0):
			return int(a.lobby) != 0
		return str(a.name).naturalnocasecmp_to(str(b.name)) < 0)
	return out


func invite_friends() -> void:
	if not steam_ok or steam_lobby == 0:
		return
	if Steam.isOverlayEnabled():
		Steam.activateGameOverlayInviteDialog(steam_lobby)
	else:
		status.emit("The Steam overlay isn't available here (launch through Steam). Friends can still join from your Steam profile.")


## A running game: a friend's invite was accepted. Check the build first.
func _on_join_requested(lobby_id: int, _steam_id: int) -> void:
	if online:
		status.emit("Leave this game first, then accept the invite.")
		return
	_invite_lobby = lobby_id
	if not Steam.requestLobbyData(lobby_id):
		_invite_lobby = 0
		status.emit("Couldn't reach the friend's lobby")


func _on_lobby_data_update(_success: bool, lobby_id: int, _member: int) -> void:
	if _invite_lobby == 0 or lobby_id != _invite_lobby or online:
		return
	_invite_lobby = 0
	var v := str(Steam.getLobbyData(lobby_id, "version"))
	if v != GAME_VERSION:
		status.emit("Can't join: they're on version %s (you have %s)" % [v if v != "" else "unknown", GAME_VERSION])
		return
	join_steam(lobby_id)


func _on_lobby_joined(lobby_id: int, _perms: int, _locked: bool, response: int) -> void:
	if lobby_id != _joining_lobby and lobby_id != steam_lobby and not _hosting:
		if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
			Steam.leaveLobby(lobby_id)
		return
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		_pending_lobby = false
		_joining_lobby = 0
		status.emit("Couldn't enter the lobby (%d)" % response)
		return
	if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
		if steam_lobby == 0 and not _hosting:
			# A joiner made owner: the host's leave and our join crossed. Nobody serves it.
			Steam.leaveLobby(lobby_id)
			_pending_lobby = false
			_joining_lobby = 0
			status.emit("That lobby has no host any more")
		return
	if online:
		Steam.leaveLobby(lobby_id)
		_pending_lobby = false
		_joining_lobby = 0
		return
	steam_lobby = lobby_id
	if str(Steam.getLobbyData(lobby_id, "game")) != LOBBY_TAG:
		Steam.leaveLobby(lobby_id)
		steam_lobby = 0
		_pending_lobby = false
		_joining_lobby = 0
		status.emit("That friend is in a different game.")
		return
	var v := str(Steam.getLobbyData(lobby_id, "version"))
	if v != GAME_VERSION:
		Steam.leaveLobby(lobby_id)
		steam_lobby = 0
		_pending_lobby = false
		_joining_lobby = 0
		status.emit("Can't join: they're on version %s (you have %s)" % [v if v != "" else "unknown", GAME_VERSION])
		return
	var peer := SteamMultiplayerPeer.new()
	var err = peer.connect_to_lobby(lobby_id)
	if err is int and err != OK:
		Steam.leaveLobby(lobby_id)
		steam_lobby = 0
		_pending_lobby = false
		_joining_lobby = 0
		status.emit("Steam connect failed (%s)" % err)
		return
	multiplayer.multiplayer_peer = peer
	status.emit("Connecting through Steam...")


# ================================================================ the session

func _start_session_as_host() -> void:
	Players.prepare_online(my_name())
	online = true
	in_match = false
	members.clear()
	members[1] = {"name": my_name(), "players": _local_players(), "ready": false}
	members_changed.emit()
	session_started.emit()


func _on_connected() -> void:
	if _awaiting_accept or online:
		return
	Players.prepare_online(my_name())
	_awaiting_accept = true
	status.emit("Connected to Steam. Waiting for the host to accept your player...")
	_rpc_hello.rpc_id(1, GAME_VERSION, my_name(), _local_players())

func _on_peer_connected(_id: int) -> void:
	pass  # the hello carries everything


func _on_peer_disconnected(id: int) -> void:
	if not is_host():
		return
	if members.has(id):
		var n: String = members[id].name
		members.erase(id)
		_rpc_members.rpc(members)
		_rpc_chat_line.rpc("", "%s left" % n)


func _local_players() -> Array:
	var out: Array = []
	for s in Players.slots.size():
		out.append({"name": str(Players.slots[s].name), "random": bool(Players.slots[s].get("random", false)), "tint": Players.slots[s].tint, "slot": s, "appearance": Wardrobe.for_slot(s)})
	return out


## Re-send our local players (after a local player joins or leaves in the lobby).
func update_local_players() -> void:
	if not online or in_match:
		return
	if is_host():
		var players := _local_players()
		if not can_fit_players(1, players.size()):
			status.emit("That lobby is full (%d players maximum)." % MAX_CLIMBERS)
			return
		members[1].players = players
		_rpc_members.rpc(members)
	else:
		_rpc_players.rpc_id(1, _local_players())


@rpc("any_peer", "call_remote", "reliable")
func _rpc_hello(version: String, pname: String, players: Array) -> void:
	if not is_host():
		return
	var id := multiplayer.get_remote_sender_id()
	if version != GAME_VERSION:
		_rpc_refused.rpc_id(id, "The host is on version %s (you have %s)" % [GAME_VERSION, version])
		return
	if in_match:
		_rpc_refused.rpc_id(id, "That game is mid-match. Try again when it's back in the lobby.")
		return
	var cleaned := _clean_players(players)
	if (not members.has(id) and members.size() >= MAX_MACHINES) or not can_fit_players(id, cleaned.size()):
		_rpc_refused.rpc_id(id, "That lobby is full")
		return
	members[id] = {"name": pname.left(32), "players": cleaned, "ready": false}
	_rpc_members.rpc(members)
	_rpc_settings.rpc_id(id, settings)
	_rpc_chat_line.rpc("", "%s joined" % pname.left(32))


@rpc("any_peer", "call_remote", "reliable")
func _rpc_players(players: Array) -> void:
	var id := multiplayer.get_remote_sender_id()
	if not is_host() or not members.has(id):
		return
	if in_match:
		return
	var cleaned := _clean_players(players)
	if not can_fit_players(id, cleaned.size()):
		_rpc_note_capacity.rpc_id(id)
		return
	members[id].players = cleaned
	members[id].ready = false
	_rpc_members.rpc(members)


func _clean_players(players: Array) -> Array:
	var out: Array = []
	for p in players.slice(0, 4):
		if p is Dictionary:
			out.append({"name": str(p.get("name", "Climber")).left(40), "random": bool(p.get("random", true)), "tint": p.get("tint", Color.WHITE) if p.get("tint") is Color else Color.WHITE, "slot": clampi(int(p.get("slot", 0)), 0, Players.MAX_LOCAL - 1), "appearance": Wardrobe.clean(p.get("appearance", {}))})  # (slot clamped: the waiting room's pid is peer * 16 + slot)
	return out


@rpc("authority", "call_remote", "reliable")
func _rpc_note_capacity() -> void:
	status.emit("That lobby is full (%d players maximum)." % MAX_CLIMBERS)


func can_fit_players(id: int, count: int) -> bool:
	var previous: Array = members.get(id, {}).get("players", [])
	return _climber_count() - previous.size() + count <= MAX_CLIMBERS


func _climber_count() -> int:
	var n := 0
	for m in members.values():
		n += m.players.size()
	return n


@rpc("authority", "call_remote", "reliable")
func _rpc_refused(reason: String) -> void:
	_end(reason)


@rpc("authority", "call_local", "reliable")
func _rpc_members(m: Dictionary) -> void:
	members = m
	if _awaiting_accept and members.has(me()):
		_awaiting_accept = false
		_pending_lobby = false
		_joining_lobby = 0
		online = true
		session_started.emit()
	members_changed.emit()


func set_ready(on: bool) -> void:
	if is_host():
		members[1].ready = on
		_rpc_members.rpc(members)
	else:
		_rpc_ready.rpc_id(1, on)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_ready(on: bool) -> void:
	var id := multiplayer.get_remote_sender_id()
	if is_host() and members.has(id):
		members[id].ready = on
		_rpc_members.rpc(members)


func all_ready() -> bool:
	for id in members:
		if id != 1 and not members[id].ready:
			return false
	return _climber_count() >= int(Modes.row(str(settings.get("mode", "scramble"))).min_players) and _climber_count() <= MAX_CLIMBERS


func send_chat(text: String) -> void:
	text = text.strip_edges().left(140)
	if text == "":
		return
	if is_host():
		_relay_chat(1, text)
	else:
		_rpc_chat.rpc_id(1, text)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_chat(text: String) -> void:
	if is_host() and members.has(multiplayer.get_remote_sender_id()):
		_relay_chat(multiplayer.get_remote_sender_id(), text.left(140))


func _relay_chat(id: int, text: String) -> void:
	var now := Time.get_ticks_msec()
	if now - int(_chat_times.get(id, 0)) < 400:
		return  # rate limit
	_chat_times[id] = now
	var who: String = members[id].name if members.has(id) else "?"
	_rpc_chat_line.rpc(who, text)


@rpc("authority", "call_local", "reliable")
func _rpc_chat_line(who: String, text: String) -> void:
	chat_line.emit(who, text)


func set_settings(s: Dictionary) -> void:
	if not is_host():
		return
	settings = s
	if online:
		_rpc_settings.rpc(s)
		if steam_ok and steam_lobby != 0:
			Steam.setLobbyData(steam_lobby, "mode", str(s.mode))
	else:
		settings_changed.emit()


@rpc("authority", "call_local", "reliable")
func _rpc_settings(s: Dictionary) -> void:
	settings = s
	settings_changed.emit()


## Host: the roster for Game.host_start, one entry per climber across machines.
func build_roster() -> Array:
	var roster: Array = []
	var pid := 0
	var ids := members.keys()
	ids.sort()
	for id in ids:
		for p in members[id].players:
			roster.append({"pid": pid, "name": p.name, "random": bool(p.get("random", false)), "tint": p.tint, "peer": id, "slot": p.slot, "appearance": Wardrobe.clean(p.get("appearance", {}))})
			pid += 1
	return roster


func set_in_match(on: bool) -> void:
	in_match = on
	if is_host() and steam_ok and steam_lobby != 0:
		Steam.setLobbyJoinable(steam_lobby, not on)


## The way out: leave, cut every Steam signal, shut the Steam API down. GodotSteam's
## own teardown on process exit is where Golemheim's quit crashed and this game's
## quit hung (0.1.1); shutting it down ourselves first lets the engine exit clean.
func shutdown() -> void:
	leave()
	if steam_input != null:
		steam_input.shutdown()
	if ClassDB.class_exists(&"Steam"):
		for sig in Steam.get_signal_list():
			for c in Steam.get_signal_connection_list(sig.name):
				Steam.disconnect(sig.name, c.callable)
		if steam_ok:
			Steam.steamShutdown()
	steam_ok = false


func leave() -> void:
	if steam_ok and steam_lobby != 0:
		if is_host():
			Steam.setLobbyJoinable(steam_lobby, false)
		Steam.leaveLobby(steam_lobby)
		steam_lobby = 0
	if multiplayer.multiplayer_peer != null and not (multiplayer.multiplayer_peer is OfflineMultiplayerPeer):
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	online = false
	_joining_lobby = 0
	_awaiting_accept = false
	_hosting = false
	in_match = false
	_pending_lobby = false
	members.clear()


func _end(reason: String) -> void:
	var was := online
	leave()
	status.emit(reason)
	if was or reason != "":
		session_ended.emit(reason)
