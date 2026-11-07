class_name Game
extends Node
## THE GAME: one machine's match. The same node runs offline, as the host, and as
## a client; only the HOST (or the offline machine) makes rule decisions.
##
## Who decides what:
## - The host owns the match: who's live, the clocks, the line, lock-ins (ordered
##   by arrival), who's out, and the results.
## - Each live climber is simulated by the machine its player sits at, and streams
##   its 16 piece poses at 30 Hz. Everyone else shows it as a solid puppet.
## - A freeze is decided by the host, posed by the owner, and broadcast as one pose
##   that every machine builds the same static body from: towers match everywhere.
## - Grabbing a rival on another machine: you ride their puppet at once, and your
##   pull is sent to their machine and applied to their real body (capped).
##
## Offline, Godot's OfflineMultiplayerPeer makes us peer 1 and the authority, and
## every rpc() with call_local just runs here: one code path for both.

signal announce(text: String, big: bool)
signal phase_changed(phase: String)
signal match_over(results: Dictionary)
signal climber_spawned(c: Climber)
signal host_left

const ClimberScript := preload("res://climber/climber.gd")
const Drivers := preload("res://climber/drivers.gd")
const Layout := preload("res://climber/body_layout.gd")
const KNIGHT := preload("res://models/metal_knight.glb")

const LOCK_MARGIN := 0.02  # metres above the line a lock-in must clear
const STREAM_HZ := 30.0
const CLOCK_HZ := 4.0
const PAUSE_BETWEEN := 1.6  # seconds between turns / rounds
const FREEZE_REPLY_S := 1.5  # how long the host waits for an owner's final pose
const PULL_STALE_S := 0.25

var world: Node3D
var dress := true  # build the 3D knights and stage dressing
var stage: Stage
var settings := {}
var mode := {}
var roster: Array = []  # [{pid, name, tint, peer, slot}] slot = local Players slot (on the owning machine)
var alive := {}  # pid -> bool
var climbers := {}  # cid -> Climber
var live := {}  # pid -> cid of that player's live climber
var tower: Array = []  # frozen cids in freeze order
var line := 0.0
var clock := 0.0
var phase := "idle"  # idle | turn | round | between | over
var turn_order: Array = []
var turn_i := -1
var round_n := 0
var locked := {}  # scramble: pid -> true once locked this round
var best := {}  # pid -> best locked height
var results := {}
var bot_drivers := {}  # pid -> driver (batteries, bots)
var practice := false

var _cid_next := 1
var _spawn_n := 0
var _between_t := 0.0
var _clock_t := 0.0
var _stream_t := 0.0
var _seq := 0
var _pending_freeze := {}  # cid -> {"t": float, "verdict_hint": String}
var _puppet_buf := {}  # cid -> Array of [time, PackedFloat32Array]
var _last_seq := {}  # cid -> int
var _pulls := {}  # cid -> {piece: [Vector2, time]}
var _remote_grabs := {}  # "cid:limb" -> [target_cid, piece]
var _com_v := {}  # cid -> previous COM velocity (for pull estimates)
var _round_fail_tops := {}  # pid -> top (scramble: who failed this round, how high)
var _now := 0.0


func _ready() -> void:
	Players.device_changed.connect(func(slot: int) -> void:
		for c in climbers.values():
			var cl: Climber = c
			if cl.local_slot == slot and cl.state == Climber.State.LIVE and dress:
				cl.set_glyphs(Glyphs.limb_glyphs(slot)))
	multiplayer.peer_disconnected.connect(_on_peer_left)
	multiplayer.server_disconnected.connect(func(): host_left.emit())


func is_host() -> bool:
	return multiplayer.multiplayer_peer == null or multiplayer.is_server()


func me() -> int:
	return multiplayer.get_unique_id() if multiplayer.multiplayer_peer != null else 1


# ================================================================ setup

## Host / offline: start a match. roster entries: {pid, name, tint, peer, slot}.
func host_start(p_settings: Dictionary, p_roster: Array) -> void:
	_rpc_start.rpc(p_settings, p_roster)


@rpc("authority", "call_local", "reliable")
func _rpc_start(p_settings: Dictionary, p_roster: Array) -> void:
	settings = p_settings
	mode = Modes.row(str(settings.get("mode", "tower")))
	practice = bool(mode.get("practice", false))
	roster = p_roster
	for c in climbers.values():
		c.remove()
	climbers.clear()
	live.clear()
	tower.clear()
	alive.clear()
	best.clear()
	locked.clear()
	results.clear()
	for r in roster:
		alive[int(r.pid)] = true
		best[int(r.pid)] = 0.0
	if stage == null:
		stage = Stage.new(str(settings.get("stage", "dock")))
		stage.build(world, dress)
	line = stage.barrel_top
	turn_order = roster.map(func(r): return int(r.pid))
	turn_i = -1
	round_n = 0
	_spawn_n = 0
	phase = "between"
	_between_t = 0.8
	phase_changed.emit(phase)
	announce.emit(str(mode.name), true)


func roster_entry(pid: int) -> Dictionary:
	for r in roster:
		if int(r.pid) == pid:
			return r
	return {}


func player_name(pid: int) -> String:
	return str(roster_entry(pid).get("name", "?"))


# ================================================================ the host's rules

func _physics_process(delta: float) -> void:
	_now += delta
	_tick_owned(delta)
	_tick_puppets()
	if not is_host():
		return
	match phase:
		"between":
			_between_t -= delta
			if _between_t <= 0.0:
				_next()
		"turn", "round":
			if not practice:
				clock -= delta
			_clock_t -= delta
			if _clock_t <= 0.0:
				_clock_t = 1.0 / CLOCK_HZ
				_rpc_clock.rpc(clock, line)
			_check_bounds()
			if clock <= 0.0:
				_time_up()
			_tick_pending(delta)


func _next() -> void:
	var still := alive_pids()
	if _game_decided(still):
		_finish()
		return
	if mode.live == "turns":
		# Next player still in, in order.
		for k in turn_order.size():
			turn_i = (turn_i + 1) % turn_order.size()
			if alive.get(turn_order[turn_i], false):
				break
		var pid: int = turn_order[turn_i]
		_rpc_phase.rpc("turn", float(settings.get("timer", 60.0)), tower_top(), round_n, pid)
		_spawn(pid)
	else:
		round_n += 1
		locked.clear()
		_round_fail_tops.clear()
		_rpc_phase.rpc("round", float(settings.get("timer", 60.0)), line if round_n > 1 else stage.barrel_top, round_n, -1)
		var n := 0
		for pid in still:
			_spawn(pid, n)
			n += 1


func _game_decided(still: Array) -> bool:
	if practice:
		return false
	if roster.size() >= 2:
		return still.size() <= 1
	return still.is_empty()


@rpc("authority", "call_local", "reliable")
func _rpc_phase(p: String, p_clock: float, p_line: float, p_round: int, pid: int) -> void:
	phase = p
	clock = p_clock
	line = p_line
	round_n = p_round
	phase_changed.emit(phase)
	if p == "turn":
		announce.emit("%s's turn" % player_name(pid), true)
	elif p == "round":
		announce.emit("Round %d" % p_round, true)


@rpc("authority", "call_local", "unreliable")
func _rpc_clock(p_clock: float, p_line: float) -> void:
	if not is_host():
		clock = p_clock
		line = maxf(line, p_line)


func _spawn(pid: int, index := 0) -> void:
	var side := _spawn_side()
	var feet := stage.spawn_point(side)
	feet.x += signf(feet.x) * float(index / 2) * 1.1  # Scramble: pairs fan out along each side
	var cid := _cid_next
	_cid_next += 1
	_rpc_spawn.rpc(pid, cid, feet)


func _spawn_side() -> int:
	var how := str(settings.get("spawn", "alternate"))
	_spawn_n += 1
	match how:
		"left":
			return -1
		"right":
			return 1
		"random":
			return 1 if randf() < 0.5 else -1
	return 1 if _spawn_n % 2 == 1 else -1


@rpc("authority", "call_local", "reliable")
func _rpc_spawn(pid: int, cid: int, feet: Vector2) -> void:
	var r := roster_entry(pid)
	if r.is_empty():
		return
	if live.has(pid) and climbers.has(live[pid]):
		var old: Climber = climbers[live[pid]]
		if old.state != Climber.State.FROZEN:
			_drop_climber(live[pid])
	var c: Climber = ClimberScript.new()
	c.climber_id = cid
	c.player_id = pid
	c.owner_peer = int(r.peer)
	c.display_name = str(r.name)
	c.tint = r.tint if r.tint is Color else Color.WHITE
	add_child(c)
	c.build(feet, world, KNIGHT if dress else null)
	climbers[cid] = c
	live[pid] = cid
	if c.owner_peer == me():
		if bot_drivers.has(pid):
			c.driver = bot_drivers[pid]
		else:
			c.local_slot = int(r.get("slot", 0))
			c.driver = Drivers.LocalDriver.new(c.local_slot)
			if dress:
				c.set_glyphs(Glyphs.limb_glyphs(c.local_slot))
		c.grab_made.connect(_on_grab_made)
		c.grab_lost.connect(_on_grab_lost)
	else:
		c.driver = Drivers.NullDriver.new()
		c.make_puppet()
	climber_spawned.emit(c)


func _drop_climber(cid: int) -> void:
	if not climbers.has(cid):
		return
	var c: Climber = climbers[cid]
	climbers.erase(cid)
	# Anyone holding it lets go first: never leave a joint on a freed body.
	for o in climbers.values():
		var oc: Climber = o
		for i in oc.limbs.size():
			if oc.limbs[i].grab_climber == c:
				oc.release(i)
	_puppet_buf.erase(cid)
	c.remove()


# ---------------------------------------------------------------- out of bounds

func _check_bounds() -> void:
	for pid in live:
		var cid: int = live[pid]
		if not climbers.has(cid) or _pending_freeze.has(cid):
			continue
		var c: Climber = climbers[cid]
		if c.state == Climber.State.FROZEN:
			continue
		if stage.out_of_bounds(c.centre_of_mass()):
			announce.emit("%s fell off!" % c.display_name, false)
			_spawn(pid)


# ---------------------------------------------------------------- lock-ins

## Owners: Lock In pressed above the line. The host decides.
func _tick_owned(delta: float) -> void:
	_stream_t -= delta
	var send := _stream_t <= 0.0
	if send:
		_stream_t = 1.0 / STREAM_HZ
		_seq += 1
	for cid in climbers.keys():
		var c: Climber = climbers[cid]
		if c.state != Climber.State.LIVE or c.owner_peer != me():
			continue
		if c.driver != null and c.driver.lock_pressed() and (phase == "turn" or phase == "round"):
			if c.top_height() > line + LOCK_MARGIN:
				if is_host():
					_judge_lock(cid, c.pose())
				else:
					_rpc_lock_request.rpc_id(1, cid, c.pose())
			else:
				announce.emit("Get above the line to lock in!", false)
		_tick_pulls_out(c, delta, send)
		if send and multiplayer.multiplayer_peer != null and not (multiplayer.multiplayer_peer is OfflineMultiplayerPeer):
			_rpc_pose.rpc(cid, _seq, c.pose())
	# Remote pulls on my climbers that went stale stop pulling.
	for cid in _pulls.keys():
		if not climbers.has(cid):
			_pulls.erase(cid)
			continue
		var c: Climber = climbers[cid]
		c.remote_pulls.clear()
		for piece in _pulls[cid].keys():
			var e: Array = _pulls[cid][piece]
			if _now - float(e[1]) < PULL_STALE_S:
				c.remote_pulls[piece] = e[0]


@rpc("any_peer", "call_remote", "reliable")
func _rpc_lock_request(cid: int, pose: PackedFloat32Array) -> void:
	if not is_host() or not climbers.has(cid):
		return
	if climbers[cid].owner_peer != multiplayer.get_remote_sender_id():
		return  # only a climber's own machine may lock it in
	_judge_lock(cid, pose)


func _judge_lock(cid: int, pose: PackedFloat32Array) -> void:
	var c: Climber = climbers.get(cid)
	if c == null or c.state == Climber.State.FROZEN or _pending_freeze.has(cid):
		return
	if not (phase == "turn" or phase == "round"):
		return
	var top := c.pose_top(pose)
	if top <= line + LOCK_MARGIN:
		if c.owner_peer != me():
			_rpc_note.rpc_id(c.owner_peer, "The line moved! Climb higher.")
		else:
			announce.emit("The line moved! Climb higher.", false)
		return
	_broadcast_freeze(cid, pose, "locked")


@rpc("authority", "call_local", "reliable")
func _rpc_note(text: String) -> void:
	announce.emit(text, false)


# ---------------------------------------------------------------- time up and freezes

func _time_up() -> void:
	clock = 0.0
	for pid in live.keys():
		var cid: int = live[pid]
		if not climbers.has(cid) or _pending_freeze.has(cid):
			continue
		var c: Climber = climbers[cid]
		if c.state == Climber.State.FROZEN:
			continue
		if c.owner_peer == me():
			_broadcast_freeze(cid, c.pose(), "time")
		else:
			_pending_freeze[cid] = {"t": FREEZE_REPLY_S}
			_rpc_freeze_now.rpc_id(c.owner_peer, cid)
	if _pending_freeze.is_empty():
		_end_of_play()


@rpc("authority", "call_remote", "reliable")
func _rpc_freeze_now(cid: int) -> void:
	var c: Climber = climbers.get(cid)
	if c == null or c.owner_peer != me():
		return
	var p := c.pose()
	c.freeze()  # stop here; the host's broadcast snaps every machine to this pose
	_rpc_final_pose.rpc_id(1, cid, p)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_final_pose(cid: int, pose: PackedFloat32Array) -> void:
	if not is_host() or not _pending_freeze.has(cid):
		return
	if climbers.has(cid) and climbers[cid].owner_peer != multiplayer.get_remote_sender_id():
		return
	_pending_freeze.erase(cid)
	_broadcast_freeze(cid, pose, "time")
	if _pending_freeze.is_empty():
		_end_of_play()


func _tick_pending(delta: float) -> void:
	for cid in _pending_freeze.keys():
		_pending_freeze[cid].t -= delta
		if _pending_freeze[cid].t <= 0.0:
			# The owner never answered: freeze the puppet where we last saw it.
			_pending_freeze.erase(cid)
			if climbers.has(cid):
				_broadcast_freeze(cid, climbers[cid].pose(), "time")
			if _pending_freeze.is_empty():
				_end_of_play()


## Host: judge a freeze and tell everyone. verdict in: "locked" | "time" | "left".
func _broadcast_freeze(cid: int, pose: PackedFloat32Array, why: String) -> void:
	var c: Climber = climbers.get(cid)
	if c == null:
		return
	var top := c.pose_top(pose)
	var made := top > line + LOCK_MARGIN
	var verdict := "made" if made else "out"
	if why == "left":
		verdict = "out"
	if why == "time" and mode.live == "all":
		verdict = "out"  # Scramble: not locked in when the clock runs out = out
	if practice:
		verdict = "made" if made else "short"
	var new_line := line
	if why == "locked" and mode.line == "raise":
		new_line = maxf(line, top)
	_rpc_freeze.rpc(cid, pose, verdict, why, top, new_line)
	# The host's rule follow-ups.
	var pid := c.player_id
	if verdict == "out":
		alive[pid] = false
		_round_fail_tops[pid] = top
	if made:
		best[pid] = maxf(float(best.get(pid, 0.0)), top)
	if mode.live == "turns":
		if why == "locked":
			_end_of_play()
	else:
		if why == "locked":
			locked[pid] = true
			var all_in := true
			for p in alive_pids():
				if not locked.has(p):
					all_in = false
			if all_in:
				_end_of_play()


@rpc("authority", "call_local", "reliable")
func _rpc_freeze(cid: int, pose: PackedFloat32Array, verdict: String, why: String, top: float, new_line: float) -> void:
	var c: Climber = climbers.get(cid)
	if c == null:
		return
	if c.state == Climber.State.FROZEN:
		c.state = Climber.State.LIVE  # re-pose a body its owner froze early
	c.apply_pose(pose)
	c.freeze()
	_snap_static(c)
	tower.append(cid)
	_puppet_buf.erase(cid)
	line = maxf(line, new_line)
	var who := c.display_name
	match verdict:
		"made":
			announce.emit("%s locked in at %.2f m!" % [who, top] if why == "locked" else "%s made it: %.2f m" % [who, top], false)
		"out":
			announce.emit("%s is out!" % who if why != "left" else "%s left" % who, false)
		"short":
			announce.emit("%s froze at %.2f m" % [who, top], false)


## Frozen pieces were static already; push their final transforms to the server.
func _snap_static(c: Climber) -> void:
	for b in c.bodies.values():
		Climber.sync_server(b)


func _end_of_play() -> void:
	if phase != "turn" and phase != "round":
		return
	# Freeze anyone still live whose round just ended without them (turns: none).
	if mode.live == "all" and clock > 0.0:
		pass
	_rpc_phase.rpc("between", 0.0, maxf(line, tower_top()) if mode.line == "tower" else line, round_n, -1)
	_between_t = PAUSE_BETWEEN


func _finish() -> void:
	var still := alive_pids()
	var winner := -1
	if still.size() == 1:
		winner = still[0]
	elif still.is_empty() and not _round_fail_tops.is_empty():
		var top := -INF
		for pid in _round_fail_tops:
			if _round_fail_tops[pid] > top:
				top = _round_fail_tops[pid]
				winner = pid
	var res := {"winner": winner, "best": best.duplicate(), "tower": tower.size(), "top": tower_top()}
	_rpc_over.rpc(res)


@rpc("authority", "call_local", "reliable")
func _rpc_over(res: Dictionary) -> void:
	phase = "over"
	results = res
	phase_changed.emit(phase)
	var w := int(res.get("winner", -1))
	announce.emit(("%s tops their pals!" % player_name(w)) if w >= 0 else "Game over", true)
	match_over.emit(res)


func alive_pids() -> Array:
	var out: Array = []
	for r in roster:
		if alive.get(int(r.pid), false):
			out.append(int(r.pid))
	return out


func tower_top() -> float:
	var top := stage.barrel_top if stage != null else 0.0
	for cid in tower:
		if climbers.has(cid):
			top = maxf(top, climbers[cid].top_height())
	return top


func live_climbers() -> Array:
	var out: Array = []
	for pid in live:
		var cid: int = live[pid]
		if climbers.has(cid) and climbers[cid].state != Climber.State.FROZEN:
			out.append(climbers[cid])
	return out


# ================================================================ the stream and puppets

@rpc("any_peer", "call_remote", "unreliable")
func _rpc_pose(cid: int, seq: int, pose: PackedFloat32Array) -> void:
	var c: Climber = climbers.get(cid)
	if c == null or c.state != Climber.State.PUPPET:
		return
	if c.owner_peer != multiplayer.get_remote_sender_id():
		return  # only the owner streams a climber
	if seq <= int(_last_seq.get(cid, -1)):
		return  # stale or duplicate: unreliable lanes arrive out of order
	_last_seq[cid] = seq
	if not _puppet_buf.has(cid):
		_puppet_buf[cid] = []
	_puppet_buf[cid].append([_now, pose])
	while _puppet_buf[cid].size() > 12:
		_puppet_buf[cid].pop_front()


## Puppets play back the stream Feel "puppet_delay" seconds behind, interpolated.
func _tick_puppets() -> void:
	var delay := Feel.get_k("puppet_delay")
	for cid in _puppet_buf.keys():
		var c: Climber = climbers.get(cid)
		if c == null or c.state != Climber.State.PUPPET:
			continue
		var buf: Array = _puppet_buf[cid]
		if buf.is_empty():
			continue
		var t := _now - delay
		var a: Array = buf[0]
		var b: Array = buf[-1]
		for i in range(buf.size() - 1):
			if float(buf[i][0]) <= t and float(buf[i + 1][0]) >= t:
				a = buf[i]
				b = buf[i + 1]
				break
		if t >= float(buf[-1][0]):
			a = buf[-1]
			b = buf[-1]
		var span := float(b[0]) - float(a[0])
		var f := 0.0 if span <= 0.0 else clampf((t - float(a[0])) / span, 0.0, 1.0)
		c.apply_pose(_lerp_pose(a[1], b[1], f))


static func _lerp_pose(a: PackedFloat32Array, b: PackedFloat32Array, f: float) -> PackedFloat32Array:
	if f <= 0.0:
		return a
	if f >= 1.0:
		return b
	var out := a.duplicate()
	for i in range(0, out.size(), 3):
		out[i] = lerpf(a[i], b[i], f)
		out[i + 1] = lerpf(a[i + 1], b[i + 1], f)
		out[i + 2] = lerp_angle(a[i + 2], b[i + 2], f)
	return out


# ================================================================ grabbing across machines

func _on_grab_made(c: Climber, limb: int, other: Object) -> void:
	if not (other is RigidBody3D and other.has_meta("climber")):
		return
	var oc: Climber = other.get_meta("climber")
	if oc.state != Climber.State.PUPPET or oc.owner_peer == me():
		return
	_remote_grabs["%d:%d" % [c.climber_id, limb]] = [oc.climber_id, str(other.get_meta("piece"))]
	_rpc_grabbed.rpc_id(oc.owner_peer, oc.climber_id, 1)


func _on_grab_lost(c: Climber, limb: int) -> void:
	var key := "%d:%d" % [c.climber_id, limb]
	if not _remote_grabs.has(key):
		return
	var g: Array = _remote_grabs[key]
	_remote_grabs.erase(key)
	var oc: Climber = climbers.get(g[0])
	if oc != null:
		_rpc_grabbed.rpc_id(oc.owner_peer, g[0], -1)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_grabbed(cid: int, delta_n: int) -> void:
	var c: Climber = climbers.get(cid)
	if c == null or c.owner_peer != me() or c.state != Climber.State.LIVE:
		return
	c.remote_grabbed = maxi(0, c.remote_grabbed + clampi(delta_n, -1, 1))


## My climber hangs on a rival's puppet: estimate the pull through each such grab
## (my weight and acceleration, shared over my attachments) and send it to the
## rival's machine, which applies it to their real body.
func _tick_pulls_out(c: Climber, delta: float, send: bool) -> void:
	var mine: Array = []
	for i in c.limbs.size():
		var key := "%d:%d" % [c.climber_id, i]
		if _remote_grabs.has(key) and c.limbs[i].grab.is_valid():
			mine.append(_remote_grabs[key])
	var v := Vector2.ZERO
	for b in c.bodies.values():
		v += Vector2(b.linear_velocity.x, b.linear_velocity.y) * b.mass
	v /= maxf(c.total_mass, 0.001)
	var prev: Vector2 = _com_v.get(c.climber_id, v)
	_com_v[c.climber_id] = v
	if mine.is_empty() or not send:
		return
	var accel := (v - prev) / maxf(delta, 0.0001)
	var g := Vector2(0, -9.8 * Feel.get_k("gravity_scale"))
	# What holds me up: m (a - g), shared over every attachment I have.
	var n := maxi(1, c.stuck_count())
	var hold := c.total_mass * (accel - g) / float(n)
	var cap := Feel.get_k("pull_cap") * c.total_mass * 9.8
	var pull := (-hold).limit_length(cap)  # what I do to what I hold
	for g2 in mine:
		var oc: Climber = climbers.get(g2[0])
		if oc != null:
			_rpc_pull.rpc_id(oc.owner_peer, int(g2[0]), str(g2[1]), pull)


@rpc("any_peer", "call_remote", "unreliable")
func _rpc_pull(cid: int, piece: String, force: Vector2) -> void:
	var c: Climber = climbers.get(cid)
	if c == null or c.owner_peer != me() or c.state != Climber.State.LIVE:
		return
	var cap := Feel.get_k("pull_cap") * c.total_mass * 9.8
	if not _pulls.has(cid):
		_pulls[cid] = {}
	_pulls[cid][piece] = [force.limit_length(cap), _now]


# ================================================================ leaving

func _on_peer_left(id: int) -> void:
	if not is_host():
		return
	for r in roster:
		if int(r.peer) != id:
			continue
		var pid := int(r.pid)
		alive[pid] = false
		if live.has(pid) and climbers.has(live[pid]):
			var cid: int = live[pid]
			var c: Climber = climbers[cid]
			_pending_freeze.erase(cid)
			if c.state != Climber.State.FROZEN:
				_broadcast_freeze(cid, c.pose(), "left")
	if mode.get("live", "") == "turns" and phase == "turn":
		var cur: int = turn_order[turn_i] if turn_i >= 0 else -1
		if not alive.get(cur, true):
			_end_of_play()
	if phase != "over" and _game_decided(alive_pids()):
		_finish()


func end_match() -> void:
	for c in climbers.values():
		c.remove()
	climbers.clear()
	live.clear()
	tower.clear()
	phase = "idle"
