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
## - Chair hits are judged by the host and applied to the struck piece on its owner's machine.
##
## Offline, Godot's OfflineMultiplayerPeer makes us peer 1 and the authority, and
## every rpc() with call_local just runs here: one code path for both.

signal announce(text: String, big: bool)
signal lock_effect(effect: String)
signal phase_changed(phase: String)
signal match_over(results: Dictionary)
signal climber_spawned(c: Climber)
signal host_left

const ChairScript := preload("res://game/arena_chair.gd")
const PartnerScript := preload("res://climber/practice_partner.gd")
var chair: ChairScript
var chair_debris: Node3D
var partner: PartnerScript
var partner_last_lock := Vector2(INF, INF)
var partner_attempt := 0
var chair_generation := 0
var chair_spawn_top := Vector2.ZERO
var remote_chair_limbs := {}

const FartVoice := preload("res://audio/fart_voice.gd")
const ClimberScript := preload("res://climber/climber.gd")
const Drivers := preload("res://climber/drivers.gd")
const Layout := preload("res://climber/body_layout.gd")
const PRACTICE_PARTNER_MODEL := preload("res://models/practice_spiral_dog.glb")
const KNIGHT := preload("res://models/defaultio.glb")  # the default 16-piece climber

const LOCK_MARGIN := 0.02  # metres above the line a lock-in must clear
## THE LOCK BUFFER (Parker 11-11: "make sure there is no delay that prevents you from
## locking in once you are over"): a Lock In pressed a moment before you cross stays
## wanted this long, and locks the first tick you're over.
const LOCK_BUFFER_S := 0.3
var _lock_want := {}  # climber id -> seconds the press is still wanted
const STREAM_HZ := 30.0
const CLOCK_HZ := 4.0
const PAUSE_BETWEEN := 1.6  # seconds between turns / rounds
const FREEZE_REPLY_S := 1.5  # how long the host waits for an owner's final pose
const RING_OUT_S := 3.0  # down on the plaza: back in the ring after this long (Parker 11-08)
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
var _shown_line := 0.0  # Del Mar: the rope glides out to `line` after each lock
var _shown_line_v := 0.0  # ...on a spring: it picks up speed, slows, nudges past and settles
var clock := 0.0
var phase := "idle"  # idle | turn | round | between | over
var turn_order: Array = []
var turn_i := -1
var round_n := 0
var round_players: Array = []
var _pairings: Array = []
var _pair_i := 0
var locked := {}  # scramble: pid -> true once locked this round
var best := {}  # pid -> best locked height
var results := {}
var bot_drivers := {}  # pid -> driver (batteries, bots)
var practice := false
var peak: Peak = null  # the solo climb's mountain (stages/peak), built the first time it's played
var peak_on := false

var _cid_next := 1
var _spawn_n := 0
var _last_spawn_sides := {}  # pid -> actual side of their most recent spawn
var _between_t := 0.0
var _clock_t := 0.0
var _stream_t := 0.0
var _seq := 0
var _pending_freeze := {}  # cid -> {"t": float, "verdict_hint": String}
## THE GROW-IN (Parker 11-10): every spawn grows from nothing over Climber.GROW_S,
## pushing whatever is in the way. Batteries that pose climbers the instant they
## spawn turn it off.
static var grow_spawns := true
const LINE_SPRING := 5.0  # Del Mar's buoy glide: stiffness (1/s^2)...
const LINE_DAMP := 3.6  # ...and damping (1/s): a little under critical (4.47), one soft overshoot
var _puppet_buf := {}  # cid -> Array of [time, PackedFloat32Array]
var _last_seq := {}  # cid -> int
var _ring_out := {}  # cid -> seconds until the RING OUT respawn
var _partner_out := 0.0  # the practice partner's ring-out countdown
## DEL MAR'S SINKING (Parker 11-11): the host's clock on each climber gone in the water
## (cid -> seconds); out once it's under (Stage.submerged) or after SINK_MAX_S.
var _sinking := {}
const SINK_MAX_S := 3.5
var _partner_sink := -1.0
var _chair_wet := false  # the chair's splash, once a dunk
var _pulls := {}  # cid -> {piece: [Vector2, time]}
var _remote_grabs := {}  # "cid:limb" -> [target_cid, piece]
var _round_fail_tops := {}  # pid -> top (scramble: who failed this round, how high)
var _fart_fuel := {}  # Seconds remaining, by player across respawns.
var _fart_down := {}
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
## True when the match started (false: not enough players for the mode).
func host_start(p_settings: Dictionary, p_roster: Array) -> bool:
	if p_roster.size() < int(Modes.row(str(p_settings.get("mode", "scramble"))).min_players):
		announce.emit("Classic needs at least two players. Use Practice to climb alone.", false)
		return false
	var match_settings := p_settings.duplicate(true)
	match_settings.seed = randi()  # one seed per match: Del Mar's floaties drift the same everywhere
	var choice := str(match_settings.get("base", "random"))
	match_settings.resolved_base = Modes.STARTING_BASES.pick_random() if choice == "random" else choice
	_rpc_start.rpc(match_settings, p_roster)
	return true


@rpc("authority", "call_local", "reliable")
func _rpc_start(p_settings: Dictionary, p_roster: Array) -> void:
	_clear_arena_props()
	settings = p_settings
	partner_last_lock = Vector2(INF, INF)
	partner_attempt = 0
	mode = Modes.practice_row(str(settings.get("practice_mode", "scramble"))) if settings.get("mode") == "practice" else Modes.row(str(settings.get("mode", "scramble")))
	practice = bool(mode.get("practice", false))
	peak_on = str(mode.get("arena", "")) == "peak"
	if peak_on and peak == null:
		peak = Peak.new()
		world.add_child(peak)
		peak.setup(self)
	elif not peak_on and peak != null:
		peak.leave()
	_fart_fuel.clear()
	_fart_down.clear()
	roster = p_roster
	_clear_climbers()
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
	stage.set_delmar(world, str(mode.get("arena", "")) == "delmar", int(settings.get("seed", 1)))
	stage.set_base(world, str(settings.get("resolved_base", settings.get("base", "barrel"))))
	stage.place_base()
	_shown_line = stage.first_line
	_shown_line_v = 0.0
	Climber.rope_x = stage.ring_half() if str(stage.row.get("dress", "")) == "plaza" and not peak_on else 0.0
	_ring_out.clear()
	if practice and bool(settings.get("practice_npc", false)) and multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		_spawn_partner()
	line = 1.0e9 if peak_on else stage.first_line  # (the Peak has no line and no lock-in)
	turn_order = roster.map(func(r): return int(r.pid))
	_pairings = Modes.round_robin(turn_order)
	_pair_i = 0
	round_players.clear()
	turn_i = -1
	round_n = 0
	_spawn_n = 0
	_last_spawn_sides.clear()
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

## Del Mar's drawn things once a frame, not once a physics tick (120 a second): the
## rope and its streamers, the buoy rocking, the mast, the ships and clouds.
func _process(delta: float) -> void:
	if stage != null and stage.delmar:
		stage.draw_delmar_line(_shown_line, _shown_line_v, delta)
		if stage.scenery != null:
			stage.scenery.tick(delta)


func _physics_process(delta: float) -> void:
	if peak_on and peak != null:
		peak.tick(delta)
	if stage != null and stage.delmar:
		# THE BUOY'S GLIDE (Parker 11-10: "make the buoy have some acceleration or
		# deceleration"): a spring, a touch under-damped, so it eases off, slows into
		# place and settles with a small overshoot.
		_shown_line_v += ((line - _shown_line) * LINE_SPRING - _shown_line_v * LINE_DAMP) * delta
		_shown_line += _shown_line_v * delta
		stage.move_buoy(_shown_line)  # the collider; the rope, mast and scenery are drawn in _process
		if stage.floaties != null:
			stage.floaties.tick(delta)
			# Each machine bounces its own climbers (their physics runs here), and
			# tells the others so the floatie squashes there too.
			for c: Climber in climbers.values():
				if c.state == Climber.State.LIVE and c.owner_peer == me():
					var hit := stage.floaties.bounce(c)
					if hit >= 0:
						var com := c.centre_of_mass()
						_rpc_floatie.rpc(hit, Vector3(com.x, com.y, 0.0))
			if is_instance_valid(partner):
				var hit := stage.floaties.bounce(partner)
				if hit >= 0:
					var com := partner.centre_of_mass()
					_rpc_floatie.rpc(hit, Vector3(com.x, com.y, 0.0))
		# In the drink: each machine's own climbers go limp and sink (their physics runs here).
		for c: Climber in climbers.values():
			if c.state == Climber.State.LIVE and c.owner_peer == me() and not c.sinking and stage.in_sea(c):
				c.sink(Stage.WATER_Y)
	var real_delta := delta / Engine.time_scale
	_now += real_delta
	_tick_fart_meters(real_delta)
	_tick_owned(real_delta)
	_tick_puppets()
	_tick_chair(delta)
	if partner != null and stage.in_sea(partner):
		# The practice partner sinks like anyone, then comes back.
		if _partner_sink < 0.0:
			_partner_sink = 0.0
			partner.sink(Stage.WATER_Y)
			_sea_splash(stage.sea_entry_x(partner), 1.6)
		_partner_sink += real_delta
		if stage.submerged(partner) or _partner_sink > SINK_MAX_S or stage.out_of_bounds(partner.centre_of_mass()):
			_partner_sink = -1.0
			_spawn_partner()
	elif partner != null and stage.out_of_bounds(partner.centre_of_mass()):
		_spawn_partner()
	elif partner != null and stage.ring_out(partner):
		# The partner rings out too: back in the ring after RING_OUT_S.
		_partner_out = (_partner_out if _partner_out > 0.0 else RING_OUT_S) - real_delta
		if _partner_out <= 0.0:
			_partner_out = 0.0
			_spawn_partner()
	else:
		_partner_out = 0.0
	if not is_host():
		return
	match phase:
		"lobby":
			_check_bounds()
		"between":
			_between_t -= real_delta
			if _between_t <= 0.0:
				_next()
		"turn", "round":
			if not practice:
				clock -= real_delta
			_clock_t -= real_delta
			if _clock_t <= 0.0:
				_clock_t = 1.0 / CLOCK_HZ
				_rpc_clock.rpc(clock, line)
			_check_bounds()
			if clock <= 0.0:
				_overtime += real_delta
				_time_up()
			else:
				_overtime = 0.0
			_tick_pending(real_delta)


func _next() -> void:
	var still := alive_pids()
	if _game_decided(still):
		_finish()
		return
	if stage.row.get("dress", "") == "plaza" and not peak_on:
		_rpc_spawn_chair.rpc(chair_generation + 1, _delmar_chair_spot() if stage.delmar else tower_peak(), Vector2i(randi_range(8, 10), randi_range(11, 13)))
	if mode.live == "turns":
		# Next player still in, in order.
		for k in turn_order.size():
			turn_i = (turn_i + 1) % turn_order.size()
			if alive.get(turn_order[turn_i], false):
				break
		var pid: int = turn_order[turn_i]
		_rpc_phase.rpc("turn", float(settings.get("timer", 60.0)), 1.0e9 if peak_on else (tower_top() if mode.line == "tower" else line), round_n, pid)
		_spawn(pid)
		if practice and bool(settings.get("practice_npc", false)):
			if not is_instance_valid(partner) or partner.state == Climber.State.FROZEN:
				_spawn_partner()
	else:
		round_n += 1
		locked.clear()
		_round_fail_tops.clear()
		_rpc_phase.rpc("round", float(settings.get("timer", 60.0)), line if round_n > 1 else stage.first_line, round_n, -1)
		var pair := _next_pair() if mode.get("round_robin", false) else still
		_rpc_round_players.rpc(pair)
		var sides := _classic_spawn_sides(pair) if mode.get("round_robin", false) else []
		for i in pair.size():
			_spawn(pair[i], sides[i] if not sides.is_empty() else 0)


func round_matchup() -> String:
	if round_players.size() != 2:
		return ""
	return "%s vs %s" % [player_name(round_players[0]).split(" the ")[0], player_name(round_players[1]).split(" the ")[0]]


func _next_pair() -> Array:
	for attempt in _pairings.size():
		var pair: Array = _pairings[_pair_i]
		_pair_i = (_pair_i + 1) % _pairings.size()
		if alive.get(pair[0], false) and alive.get(pair[1], false):
			return pair
	return []


@rpc("authority", "call_local", "reliable")
func _rpc_round_players(players: Array) -> void:
	round_players = players.duplicate()
	# Frozen bodies remain in climbers/tower, but only this pair is active.
	live.clear()
	locked.clear()


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
		# (announced by _rpc_spawn, with the name the new climber gets.) Guests learn
		# whose turn it is here: only the host's _next() moved turn_i, so they read "?".
		if not is_host() and turn_order.has(pid):
			turn_i = turn_order.find(pid)
	elif p == "round":
		announce.emit("Round %d" % p_round, true)


@rpc("authority", "call_local", "unreliable")
func _rpc_clock(p_clock: float, p_line: float) -> void:
	if not is_host():
		clock = p_clock
		line = maxf(line, p_line)


## Resolve on the host before broadcasting. Read body poses directly so a climber
## created earlier in this same physics tick already occupies its space.
func _open_spawn(preferred: Vector2) -> Vector2:
	if stage.delmar:
		return preferred  # the pier's two spawns, 3 m apart (Stage.spawn_point)
	var scale_factor := Feel.get_k("body_scale")
	# Shoulder offset, an outward-folded upper arm, and its capsule radius.
	var half_width := (0.73 + Feel.get_k("shoulder_flare")) * scale_factor
	var height := 2.05 * scale_factor
	var edge := stage.ring_half() - half_width - 0.16
	var inside := stage.barrel_half + half_width + 0.16
	var blocked: Array[Rect2] = []
	var actors := climbers.values()
	if is_instance_valid(partner) and not partner.removed:
		actors.append(partner)
	for c: Climber in actors:
		var bounds := c.pose_bounds(c.pose())
		var buffer: Array = _puppet_buf.get(c.climber_id, [])
		if not buffer.is_empty():
			bounds = bounds.merge(c.pose_bounds(buffer.back()[1]))
		blocked.append(bounds.grow(0.16))
	var y := preferred.y
	while true:
		var candidates := [clampf(preferred.x, -edge, edge), -edge, edge, -inside, inside]
		var spans: Array[Vector2] = []
		var next_y := INF
		for b in blocked:
			if b.end.y < y or b.position.y > y + height:
				continue
			var span := Vector2(b.position.x - half_width, b.end.x + half_width)
			spans.append(span)
			candidates.append(span.x - 0.001)
			candidates.append(span.y + 0.001)
			next_y = minf(next_y, b.end.y + 0.01)
		var distance := INF
		var best := 0.0
		for x: float in candidates:
			if absf(x) < inside or absf(x) > edge or absf(x - preferred.x) >= distance:
				continue
			var free := true
			for span in spans:
				if x >= span.x and x <= span.y:
					free = false
					break
			if free:
				best = x
				distance = absf(x - preferred.x)
		if is_finite(distance):
			return Vector2(best, y)
		# A completely packed floor can still accept a separated spawn above it.
		y = next_y
	return preferred


## Resolve both preferences together so a same-side history becomes a fair coin toss.
func _classic_spawn_sides(pair: Array) -> Array:
	var first := int(_last_spawn_sides.get(pair[0], 0))
	var second := int(_last_spawn_sides.get(pair[1], 0))
	var side: int
	if first != 0 and first != second:
		side = -first
	elif second != 0 and first == 0:
		side = second
	else:
		side = -1 if randf() < 0.5 else 1
	return [side, -side]


func _spawn(pid: int, preferred_side := 0) -> void:
	if phase == "lobby":
		_rpc_spawn.rpc(pid, pid, _open_spawn(stage.spawn_point(_spawn_side())), player_name(pid))
		return
	var side := preferred_side
	if side == 0:
		if mode.get("round_robin", false) and _last_spawn_sides.has(pid):
			side = -int(_last_spawn_sides[pid])
		else:
			side = _spawn_side()
	if practice and stage.delmar and is_instance_valid(partner):
		side = 1  # The NPC uses the other pier spawn.
	var feet := peak.begin() if peak_on else _open_spawn(stage.spawn_point(side))
	var cid := _cid_next
	_cid_next += 1
	# A NEW NAME FOR EVERY CLIMBER (Parker 11-08): a player with a random name gets
	# a fresh one each time they climb; a typed name stays. Online players go by their
	# Steam name but are flagged random, so their climbers get made names too
	# (Parker 11-09). The host picks, so every machine shows the same.
	var r := roster_entry(pid)
	var nm := str(r.get("name", "?"))
	if bool(r.get("random", false)) and _is_new_character(pid):
		nm = NameGen.make()
	_rpc_spawn.rpc(pid, cid, feet, nm)


## A new character climbs (first spawn, or after the last one locked in and froze);
## a respawn after a fall is the same character, keeping the name.
func _is_new_character(pid: int) -> bool:
	if not live.has(pid) or not climbers.has(live[pid]):
		return true
	return (climbers[live[pid]] as Climber).state == Climber.State.FROZEN


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
func _rpc_spawn(pid: int, cid: int, feet: Vector2, nm: String) -> void:
	var r := roster_entry(pid)
	if r.is_empty():
		return
	_last_spawn_sides[pid] = -1 if feet.x < 0.0 else 1
	r.name = nm  # banners, tags and results follow the climber now climbing
	if phase == "turn" and _is_new_character(pid) and not peak_on:
		announce.emit("%s's turn" % nm, true)
	if live.has(pid) and climbers.has(live[pid]):
		var old: Climber = climbers[live[pid]]
		if old.state != Climber.State.FROZEN:
			_drop_climber(live[pid])
	var c: Climber = ClimberScript.new()
	c.climber_id = cid
	c.player_id = pid
	c.owner_peer = int(r.peer)
	c.display_name = nm
	c.tint = r.tint if r.tint is Color else Color.WHITE
	add_child(c)
	var appearance: Dictionary = Wardrobe.clean(r.get("appearance", {}))
	c.build(feet, world, Wardrobe.model(appearance) if dress else null)
	if dress:
		for body in c.bodies.values():
			Wardrobe.apply(body, appearance)
	var voice := FartVoice.new()
	c.bodies["pelvis"].add_child(voice)
	c.froze.connect(func(_cl): voice.release())
	climbers[cid] = c
	live[pid] = cid
	if c.owner_peer == me():
		if bot_drivers.has(pid):
			c.driver = bot_drivers[pid]
		else:
			# THE DRIVER'S SLOT (the input law, 6): the roster's slot if this machine
			# has it, else this climber's place among the machine's own entries. A
			# climber this machine owns is never left without a driver.
			var ordinal := 0
			for other in roster:
				if int(other.peer) == me() and int(other.pid) < pid:
					ordinal += 1
			c.local_slot = Players.resolve_slot(int(r.get("slot", 0)), ordinal)
			c.driver = Drivers.LocalDriver.new(c.local_slot)
			Players.lock_pressed(c.local_slot)  # drop a Lock In pressed while sitting out
			if dress:
				c.set_glyphs(Glyphs.limb_glyphs(c.local_slot))
		c.exerted.connect(func(): _rpc_exertion.rpc(cid, Sound.SFX["strain"].pick_random()))
		c.knockout_changed.connect(func(active: bool): _rpc_knockout_visual.rpc(cid, active))
		c.knocked_out.connect(func(): _rpc_knockout.rpc(cid, Sound.SFX["knockout"].pick_random()))
		c.release_contact.connect(func(at: Vector3):
			_rpc_slap.rpc(cid, at, Sound.pick_grab(), randf_range(0.92, 1.08)))
		c.grab_made.connect(_on_grab_made)
		c.grab_made.connect(func(_c: Climber, limb: int, other: Object):
			# THE BELL (Parker 11-10): a hand or foot sticking to the metal bell rings it.
			if other is Node and (other as Node).has_meta("bell_ring") and _bell_wait.get("%d:%d" % [cid, limb], 0) <= Time.get_ticks_msec():
				_bell_wait["%d:%d" % [cid, limb]] = Time.get_ticks_msec() + BELL_COOLDOWN_MS
				var end: RigidBody3D = c.bodies[c.limbs[limb].def.end]
				_rpc_bell.rpc(cid, end.global_position, Sound.SFX["church_bell"].pick_random()))
		c.grab_made.connect(func(_c: Climber, limb: int, other: Object):
			if other is Node and (other as Node).has_meta("donkey_voice") and _donkey_contact_ready("%d:%d" % [cid, limb]):
				if randf() < DONKEY_CHANCE:
					_rpc_donkey.rpc_id(1, cid, Sound.SFX["donkey"].pick_random()))
		c.grab_lost.connect(_on_grab_lost)
		c.rope_bounced.connect(func(at: Vector3, speed: float): _rpc_rope.rpc(cid, at, speed))
		if chair != null and not is_host():
			c.limb_selected.connect(func(i: int, velocity: Vector3): _rpc_chair_limb.rpc_id(1, cid, i, velocity))
	else:
		c.driver = Drivers.NullDriver.new()
		c.make_puppet()
	if grow_spawns and not peak_on:
		c.grow_in()  # from nothing at the feet (glyphs and all), pushing what stands there aside
	if peak_on and c.owner_peer == me():
		peak.on_player(c, bool(settings.get("peak_fresh", false)))  # where the climb was left, pose and all
	climber_spawned.emit(c)


func _drop_climber(cid: int) -> void:
	_sinking.erase(cid)
	_lock_want.erase(cid)
	if not climbers.has(cid):
		return
	var c: Climber = climbers[cid]
	remote_chair_limbs.erase(cid)
	climbers.erase(cid)
	# Anyone holding it lets go first: never leave a joint on a freed body.
	for o in climbers.values():
		var oc: Climber = o
		for i in oc.limbs.size():
			if oc.limbs[i].grab_climber == c:
				oc.release(i)
	_puppet_buf.erase(cid)
	_last_seq.erase(cid)
	_pulls.erase(cid)
	_last_sent.erase(cid)
	_puppet_at.erase(cid)
	# Never leave the chair's grip joint on a freed hand.
	if chair != null and is_instance_valid(chair) and chair.holder == cid:
		chair.clear_grip()
	c.remove()


# ---------------------------------------------------------------- out of bounds

func _check_bounds() -> void:
	for pid in live.keys():  # (a copy: the sea verdict erases from live inside the loop)
		if not live.has(pid):
			continue
		var cid: int = live[pid]
		if not climbers.has(cid) or _pending_freeze.has(cid):
			continue
		var c: Climber = climbers[cid]
		if c.state == Climber.State.FROZEN:
			continue
		if peak_on:
			# The Peak has no out of bounds: a fall lands somewhere lower. Only a climber
			# that has left the world itself (a bug) is put back on its last firm hold.
			if peak.out_of_world(c.centre_of_mass()):
				peak.rescue()
			continue
		if _ring_out.has(cid):
			_ring_out[cid] = float(_ring_out[cid]) - get_physics_process_delta_time() / maxf(Engine.time_scale, 0.01)  # real seconds, as the partner's count
			if float(_ring_out[cid]) <= 0.0:
				_ring_out.erase(cid)
				_spawn(pid)
			continue
		if stage.in_sea(c) or _sinking.has(cid):
			# Del Mar: "your counted as Out if you fall off the tower into the water". In
			# goes the body with a splash; it's out once it has gone right under.
			if not _sinking.has(cid):
				_sinking[cid] = 0.0
				_rpc_note.rpc("%s fell in the sea!" % c.display_name)
				_rpc_sea_splash.rpc(stage.sea_entry_x(c), 1.6)  # bigger than Golemheim's 1: this camera sits far back
			_sinking[cid] = float(_sinking[cid]) + get_physics_process_delta_time() / maxf(Engine.time_scale, 0.01)
			if stage.submerged(c) or float(_sinking[cid]) > SINK_MAX_S or stage.out_of_bounds(c.centre_of_mass()):
				_sinking.erase(cid)
				# BACK ON THE DOCK (Parker 11-12: "If you fall in the water, you should respawn
				# back on the dock, instead of being out of the game"). It was out, before.
				_spawn(pid)
			continue
		if stage.ring_out(c):
			_ring_out[cid] = RING_OUT_S
			_rpc_note.rpc("RING OUT!")  # every machine: the banner and its sound
			continue
		if stage.out_of_bounds(c.centre_of_mass()):
			# To every machine (its banner carries the fall sound): Parker 11-08, "All
			# people should hear all noises". This runs on the host only.
			_rpc_note.rpc("%s fell off!" % c.display_name)
			_spawn(pid)


# ---------------------------------------------------------------- lock-ins

## Owners: Lock In pressed above the line. The host decides.
func _tick_fart_meters(seconds: float) -> void:
	for player in roster:
		if int(player.peer) != me():
			continue
		var pid := int(player.pid)
		var c: Climber = climbers.get(live.get(pid, -1))
		var can_play := c != null and c.state == Climber.State.LIVE and c.local_slot >= 0
		var slot := c.local_slot if can_play else int(player.get("slot", -1))
		var held := Players.fart_held(slot)
		var fuel: float = _fart_fuel.get(pid, FartVoice.CAPACITY)
		var pressed := held and not _fart_down.has(pid)
		if not held:
			if can_play and fuel > 0.0 and _fart_down.get(pid, -1) == c.climber_id:
				_rpc_fart.rpc(c.climber_id, 0, 1.0, 0.0)
			_fart_down.erase(pid)
			_fart_fuel[pid] = minf(FartVoice.CAPACITY, fuel + seconds * 0.5)
			continue
		if pressed:
			_fart_down[pid] = c.climber_id if can_play else -1
		if not can_play or fuel <= 0.0 or _fart_down[pid] != c.climber_id:
			continue
		if pressed:
			var voice: FartVoice = c.bodies["pelvis"].get_node("FartVoice")
			_rpc_fart.rpc(c.climber_id, voice.next_take(), randf_range(0.84, 1.18), fuel)
		_fart_fuel[pid] = 0.0 if fuel <= seconds + 0.000001 else fuel - seconds


## THE STREAM RATE (20-player lobbies, 11-10): every moving climber's owner streams
## its pose to everyone through the host. Up to four moving climbers stream at the
## full STREAM_HZ; past that the rate falls so the total stays the same (twenty in the
## waiting room stream at STREAM_MIN_HZ), and the puppets' buffer widens to match. A
## match has one or two live climbers, so play itself is always at the full rate.
const STREAM_MIN_HZ := 10.0
const STREAM_KEEPALIVE_S := 0.5
var _last_sent := {}  # cid -> [pose, time, on_support]: the last pose streamed
var _puppet_at := {}  # cid -> the newest sample's time once it has been applied in full


static func _same_pose(a: PackedFloat32Array, b: PackedFloat32Array) -> bool:
	if a.size() != b.size():
		return false
	for i in a.size():
		if absf(a[i] - b[i]) > 0.001:
			return false
	return true

func stream_hz() -> float:
	var moving := 0
	for c: Climber in climbers.values():
		if c.state != Climber.State.FROZEN:
			moving += 1
	return clampf(STREAM_HZ * 4.0 / maxf(float(moving), 4.0), STREAM_MIN_HZ, STREAM_HZ)


func _tick_owned(real_delta: float) -> void:
	_stream_t -= real_delta
	var send := _stream_t <= 0.0
	if send:
		_stream_t += 1.0 / stream_hz()
		_seq += 1
	for cid in climbers.keys():
		var c: Climber = climbers[cid]
		if c.state != Climber.State.LIVE or c.owner_peer != me():
			continue
		var can_lock: bool = c.knockout_left <= 0 and not c.sinking and (phase == "turn" or phase == "round") and not peak_on
		if c.driver != null and c.driver.lock_pressed() and can_lock:
			_lock_want[cid] = LOCK_BUFFER_S
		if _lock_want.has(cid):
			if not can_lock:
				_lock_want.erase(cid)
			elif live_gap(c) > LOCK_MARGIN:
				_lock_want.erase(cid)
				if is_host():
					_judge_lock(cid, c.pose(), c.welded_to_support())
				else:
					_rpc_lock_request.rpc_id(1, cid, c.pose(), c.welded_to_support())
			else:
				_lock_want[cid] = float(_lock_want[cid]) - real_delta
				if float(_lock_want[cid]) <= 0.0:
					_lock_want.erase(cid)
					announce.emit("Get above the line to lock in!", false)
		if send:
			_send_contact_loads(c)
		# (the grow-in plays on every machine by itself: nothing is streamed during it)
		if send and not c.growing() and multiplayer.multiplayer_peer != null and not (multiplayer.multiplayer_peer is OfflineMultiplayerPeer):
			# STANDING STILL SENDS LITTLE: a pose within a millimetre of the last one sent
			# goes out as a keepalive twice a second (a full waiting room of idle climbers
			# was thousands of identical packets a second through the host).
			var now_pose := c.pose()
			var on_support := c.touches_solid()
			var last: Array = _last_sent.get(cid, [])
			if not last.is_empty() and bool(last[2]) == on_support and _now - float(last[1]) < STREAM_KEEPALIVE_S and _same_pose(last[0], now_pose):
				continue
			_last_sent[cid] = [now_pose, _now, on_support]
			_rpc_pose.rpc(cid, _seq, now_pose, on_support)
	# Remote pulls on my climbers that went stale stop pulling.
	for cid in _pulls.keys():
		if not climbers.has(cid):
			_pulls.erase(cid)
			continue
		var pc: Climber = climbers[cid]
		pc.remote_pulls.clear()
		pc.remote_support = false
		for key in _pulls[cid]:
			var sample: Dictionary = _pulls[cid][key]
			if sample.has("time") and _now - float(sample.time) < PULL_STALE_S:
				pc.remote_pulls[key] = sample
				pc.remote_support = pc.remote_support or sample.supported
	if send and chair != null and is_host() and multiplayer.get_peers().size() > 0:
		_rpc_chair_pose.rpc(chair_generation, chair.holder, chair.limb, chair.grip_point, chair.global_transform, chair.hit_count, chair.in_bubble)
@rpc("any_peer", "call_remote", "reliable")
func _rpc_lock_request(cid: int, pose: PackedFloat32Array, welded: bool) -> void:
	if not is_host() or not climbers.has(cid):
		return
	if climbers[cid].owner_peer != multiplayer.get_remote_sender_id():
		return  # only a climber's own machine may lock it in
	_judge_lock(cid, pose, welded)


## Test the submitted pose against this match's permanent supports. A remote
## puppet's displayed transform lags its owner, and welded ends ignore collisions
## with their anchor, so neither puppet position nor contact-monitor lists suffice.
func _pose_on_support(c: Climber, pose: PackedFloat32Array) -> bool:
	if stage == null or pose.size() != Layout.ORDER.size() * 3:
		return false
	var space := world.get_world_3d().direct_space_state
	var query := PhysicsShapeQueryParameters3D.new()
	query.collision_mask = Climber.LAYER_WORLD | Climber.LAYER_FROZEN
	query.margin = 0.022  # Allow solver separation at resting and welded contacts.
	for i in Layout.ORDER.size():
		var body: RigidBody3D = c.bodies[Layout.ORDER[i]]
		var col := body.get_child(0) as CollisionShape3D
		var k := i * 3
		var xf := Transform3D(Basis(Vector3.BACK, pose[k + 2]), Vector3(pose[k], pose[k + 1], 0))
		query.shape = col.shape
		query.transform = xf * col.transform
		for hit in space.intersect_shape(query):
			var other: CollisionObject3D = hit.collider
			if stage.bodies.has(other):
				return true
			if not other.has_meta("climber"):
				continue
			var support := Climber.climber_of(other)
			if support != null and climbers.get(support.climber_id) == support and tower.has(support.climber_id):
				return true
	return false


func _valid_lock_pose(pose: PackedFloat32Array) -> bool:
	if pose.size() != Layout.ORDER.size() * 3:
		return false
	for value in pose:
		if not is_finite(value):
			return false
	return true

## welded: the owner's word that a hand or foot is welded to the arena or the tower
## (Climber.welded_to_support), which counts as touching.
func _judge_lock(cid: int, pose: PackedFloat32Array, welded := false) -> void:
	var c: Climber = climbers.get(cid)
	if c == null or c.state == Climber.State.FROZEN or _pending_freeze.has(cid) or _sinking.has(cid):
		return  # (in the sea: nobody locks in from the water)
	if not (phase == "turn" or phase == "round") or not _valid_lock_pose(pose):
		return
	if pose_gap(c, pose) <= LOCK_MARGIN - _slack(c):
		if c.owner_peer != me():
			_rpc_note.rpc_id(c.owner_peer, "The line moved! Climb higher.")
		else:
			announce.emit("The line moved! Climb higher.", false)
		return
	_broadcast_freeze(cid, pose, "locked", welded)


@rpc("authority", "call_local", "reliable")
func _rpc_note(text: String) -> void:
	announce.emit(text, false)


# ---------------------------------------------------------------- time up and freezes

const OVERTIME_CAP_S := 8.0  # past the clock, how long an airborne climber may take to touch down
var _overtime := 0.0


func _time_up() -> void:
	clock = 0.0
	for pid in live.keys():
		var cid: int = live[pid]
		if not climbers.has(cid) or _pending_freeze.has(cid):
			continue
		var c: Climber = climbers[cid]
		if c.state == Climber.State.FROZEN:
			continue
		# On a support: the pose test, or a weld it can miss (a strained one hangs a
		# few centimetres off), or the owner's own word for a puppet.
		var held_up := (c.owner_peer == me() and c.welded_to_support()) or (c.state == Climber.State.PUPPET and c.puppet_on_support)
		if _overtime > OVERTIME_CAP_S * 2.0 or (not held_up and not _pose_on_support(c, c.pose())):
			if _overtime > OVERTIME_CAP_S:
				# Still in the air (hanging off the loose chair, spinning on a rope) long
				# after the clock: out, so the round can end. It waited for ever before.
				_rpc_note.rpc("%s ran out of time in the air!" % c.display_name)
				_broadcast_freeze(cid, c.pose(), "air")
			continue
		if c.owner_peer == me():
			_broadcast_freeze(cid, c.pose(), "time")
		else:
			_pending_freeze[cid] = {"t": FREEZE_REPLY_S}
			_rpc_freeze_now.rpc_id(c.owner_peer, cid)
	_finish_timeout_if_settled()


@rpc("authority", "call_remote", "reliable")
func _rpc_freeze_now(cid: int) -> void:
	var c: Climber = climbers.get(cid)
	if c == null or c.owner_peer != me():
		return
	var p := c.pose()
	_rpc_final_pose.rpc_id(1, cid, p, c.welded_to_support())


@rpc("any_peer", "call_remote", "reliable")
func _rpc_final_pose(cid: int, pose: PackedFloat32Array, welded := false) -> void:
	if not is_host() or not _pending_freeze.has(cid):
		return
	if climbers.has(cid) and climbers[cid].owner_peer != multiplayer.get_remote_sender_id():
		return
	if not _valid_lock_pose(pose):
		return
	_pending_freeze.erase(cid)
	_broadcast_freeze(cid, pose, "time", welded)
	_finish_timeout_if_settled()


func _tick_pending(delta: float) -> void:
	for cid in _pending_freeze.keys():
		_pending_freeze[cid].t -= delta
		if _pending_freeze[cid].t <= 0.0:
			# The owner never answered: judge only a supported last-known pose.
			_pending_freeze.erase(cid)
			if climbers.has(cid):
				_broadcast_freeze(cid, climbers[cid].pose(), "time")
	_finish_timeout_if_settled()


## Timeout waits for every airborne player to touch solid stage/tower geometry.
func _finish_timeout_if_settled() -> void:
	if clock > 0.0 or not _pending_freeze.is_empty():
		return
	for cid in live.values():
		var c: Climber = climbers.get(cid)
		if c != null and c.state != Climber.State.FROZEN:
			return
	_end_of_play()


## Host: judge a freeze and tell everyone. verdict in: "locked" | "time" | "left".
func _broadcast_freeze(cid: int, pose: PackedFloat32Array, why: String, welded := false) -> void:
	var c: Climber = climbers.get(cid)
	if c == null:
		return
	var top := pose_measure(c, pose)
	# Touching: a weld to the arena or the tower (the owner's report, or this machine's
	# own climber), or the pose test against the supports.
	var grounded := welded or (c.owner_peer == me() and c.welded_to_support()) or _pose_on_support(c, pose)
	if why == "sea" or why == "air":
		grounded = false  # in the water (Del Mar), or never came down after the clock: out, the body leaves
	if why == "time" and not grounded:
		return
	if why == "locked" and not grounded:
		var note := "Touch the stage or the stack to lock in!"
		if c.owner_peer == me():
			announce.emit(note, false)
		else:
			_rpc_note.rpc_id(c.owner_peer, note)
		return
	var made := grounded and pose_gap(c, pose) > LOCK_MARGIN - _slack(c)
	var verdict := "made" if made else "out"
	if why == "left":
		verdict = "out"
	if practice:
		verdict = "made" if made else "short"
	var new_line := line
	if why == "locked" and mode.line == "raise":
		new_line = maxf(line, top + float(mode.get("line_gap", 0.0)))
	_rpc_freeze.rpc(cid, pose, verdict, why, top, new_line, grounded)
	# The host's rule follow-ups.
	var pid := c.player_id
	if verdict == "out":
		alive[pid] = false
		_round_fail_tops[pid] = top if grounded else 0.0
	if made:
		locked[pid] = true
		best[pid] = maxf(float(best.get(pid, 0.0)), top)
	if mode.live == "turns":
		if why == "locked":
			_end_of_play()
	else:
		if why == "sea" or why == "air":
			# Out in the water: the round ends once everyone still in has locked in.
			var all_done := true
			for p in round_players:
				if alive.get(p, false) and not locked.has(p):
					all_done = false
			if all_done:
				_end_of_play()
		if why == "locked":
			locked[pid] = true
			var all_in := true
			for p in round_players:
				if alive.get(p, false) and not locked.has(p):
					all_in = false
			if all_in:
				_end_of_play()


@rpc("authority", "call_local", "reliable")
func _rpc_freeze(cid: int, pose: PackedFloat32Array, verdict: String, why: String, top: float, new_line: float, grounded: bool) -> void:
	var c: Climber = climbers.get(cid)
	if c == null:
		return
	var who := c.display_name
	if grounded:
		if c.state == Climber.State.FROZEN:
			c.state = Climber.State.LIVE  # re-pose a body its owner froze early
		c.apply_pose(pose)
		c.freeze()
		_snap_static(c)
		_free_locked_overlaps(c)
		tower.append(cid)
		_puppet_buf.erase(cid)
	else:
		if why == "sea" and stage != null and stage.sea != null:
			# Del Mar: the splash was its going in; gone under, a last bubble.
			var at := Vector3(c.centre_of_mass().x, Stage.WATER_Y, 0.0)
			stage.sea.ripple(at, 0.6)
			Sound.play_at("bubble_pop", at, -6.0, world)
		live.erase(c.player_id)
		_drop_climber(cid)
	line = maxf(line, new_line)
	# Del Mar's measure is along the rope: say how far out past the pier's end.
	var shown := top - Stage.PIER_END if stage != null and stage.delmar else top
	match verdict:
		"made":
			lock_effect.emit(Wardrobe.clean(roster_entry(c.player_id).get("appearance", {})).effect)
			if stage != null and stage.delmar:
				announce.emit("%s locked in %.2f m out!" % [who, shown] if why == "locked" else "%s made it: %.2f m out" % [who, shown], false)
			else:
				announce.emit("%s locked in at %.2f m!" % [who, top] if why == "locked" else "%s made it: %.2f m" % [who, top], false)
		"out":
			announce.emit("%s is out!" % who if why != "left" else "%s left" % who, false)
		"short":
			announce.emit("%s froze at %.2f m" % [who, top], false)


## Recover locally simulated pieces from the newly static tower. Owners stream
## the corrected pose normally, so remote puppets are never moved independently.
func _free_locked_overlaps(locked: Climber) -> void:
	if not is_instance_valid(locked):
		return
	for actor: Climber in climbers.values():
		if actor == locked or actor.state != Climber.State.LIVE or actor.owner_peer != me():
			continue
		for body: RigidBody3D in actor.bodies.values():
			var query := PhysicsTestMotionParameters3D.new()
			query.margin = 0.025
			query.recovery_as_collision = true
			for attempt in 6:
				query.from = body.global_transform
				query.motion = Vector3.ZERO
				var result := PhysicsTestMotionResult3D.new()
				if not PhysicsServer3D.body_test_motion(body.get_rid(), query, result):
					break
				var recovery := result.get_travel()
				recovery.z = 0.0
				if recovery.length_squared() < 0.000001:
					break
				body.global_position += recovery
				Climber.sync_server(body)
				body.sleeping = false

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
	var top := stage.first_line if stage != null else 0.0  # the first line until the tower passes it
	for cid in tower:
		if climbers.has(cid):
			top = maxf(top, measure(climbers[cid]))
	return top


## THE LINE YOU CAN SEE (Parker 11-11): what a lock-in must clear. Del Mar's rope glides
## out to `line` on its spring after each lock (Parker asked for the glide); while it
## glides, a lock is judged by the rope as drawn, never by where it's heading. (The
## plaza's bar shows the line itself: it snaps.)
func lock_line() -> float:
	if stage != null and stage.delmar:
		return minf(line, _shown_line)
	return line


## THE LINE AS SEEN (Parker 11-11: "I wanted only the invisible boundary line that you
## had to get over to be changed to match how it looked from the camera"). The flag
## string and the rope stay where they hang and glide as they always did; the line a
## lock-in must clear is what they cover on screen, carried onto the climbers' plane
## (z = 0) along this machine's sight lines. Main sets these every frame; with no
## camera (or judge_by_view off) it's the plain line.
var view_from := Vector3.INF  # the camera
var shown_bar_y := NAN  # the plaza: the flag string's height as drawn (it glides up)
var shown_bar_z := 0.0  # ...how far behind the plane it hangs
var shown_bar_sag := 0.0  # ...and its sag at its middle
var judge_by_view := true
## A climber owned by another machine: its owner judged by its own camera, which
## frames the same way but may lag a touch; the host gives it this much.
const REMOTE_SLACK := 0.06


func _viewed() -> bool:
	return judge_by_view and view_from.is_finite() and view_from.z > 1.0


func _slack(c: Climber) -> float:
	return REMOTE_SLACK if c.owner_peer != me() else 0.0


func live_gap(c: Climber) -> float:
	return lock_gap(c.reach_points(stage.line_dir()) if stage != null else c.reach_points(Vector2(0, 1)))


func pose_gap(c: Climber, pose: PackedFloat32Array) -> float:
	return lock_gap(c.pose_reach_points(pose, stage.line_dir()) if stage != null else c.pose_reach_points(pose, Vector2(0, 1)))


## How far the furthest of `points` (z = 0) shows past the line on screen (> 0: over).
func lock_gap(points: Array) -> float:
	var delmar := stage != null and stage.delmar
	var best := -INF
	if not _viewed():
		var d := Vector2(1, 1) if delmar else Vector2(0, 1)
		for p: Vector2 in points:
			best = maxf(best, p.dot(d))
		return best - lock_line()
	if delmar:
		var seen := _seen_rope()
		for p: Vector2 in points:
			best = maxf(best, p.x + p.y - _seen_w(seen, p.x - p.y))
	else:
		for p: Vector2 in points:
			best = maxf(best, p.y - _seen_bar_y(p.x))
	return best


## The plaza: the height the flag string shows at, on the plane, over x.
func _seen_bar_y(x: float) -> float:
	var e := view_from
	var zs := shown_bar_z
	if is_nan(shown_bar_y) or e.z <= zs + 0.5:
		return lock_line()
	var t := e.z / (e.z - zs)  # (a point on the string, seen from e, crosses z = 0 this far along)
	var sx := e.x + (x - e.x) / t
	var f := clampf((sx + LuchaUI.LINE_HALF_W) / (2.0 * LuchaUI.LINE_HALF_W), 0.0, 1.0)
	var sy := minf(line, shown_bar_y) - shown_bar_sag * 4.0 * f * (1.0 - f)
	return e.y + (sy - e.y) * t


## Del Mar: the rope as drawn (its eyes, its sag), carried onto the plane: points as
## (u, w) = (x - y, x + y), along the line and across it, in order of u.
func _seen_rope() -> PackedVector2Array:
	var ends: Array = stage.rope_ends(lock_line())
	var a: Vector3 = ends[0]
	var b: Vector3 = ends[1]
	var sag := Stage.ROPE_SAG * (b - a).length()
	var e := view_from
	var out := PackedVector2Array()
	for i in Stage.ROPE_POINTS + 1:
		var s := float(i) / Stage.ROPE_POINTS
		var p := a + (b - a) * s
		p.y -= sag * 4.0 * s * (1.0 - s)
		var q := e + (p - e) * (e.z / maxf(e.z - p.z, 0.01))
		out.append(Vector2(q.x - q.y, q.x + q.y))
	if out[0].x > out[out.size() - 1].x:
		out.reverse()
	return out


## The seen rope's w at u (past its ends, its end stretches on straight).
func _seen_w(seen: PackedVector2Array, u: float) -> float:
	var n := seen.size()
	var i := 0
	while i < n - 2 and seen[i + 1].x < u:
		i += 1
	var p := seen[i]
	var q := seen[i + 1]
	var f := (u - p.x) / (q.x - p.x) if absf(q.x - p.x) > 0.0001 else 0.0
	return p.y + (q.y - p.y) * f


## How far a climber gets toward the line: its top (the plaza), or its reach along the
## 45 degree rope's normal, x + y (Del Mar). A pose's too, as the host judges it.
func measure(c: Climber) -> float:
	return c.reach(stage.line_dir()) if stage != null else c.top_height()


func pose_measure(c: Climber, pose: PackedFloat32Array) -> float:
	return c.pose_reach(pose, stage.line_dir()) if stage != null else c.pose_top(pose)


## Del Mar: where the chair floats, to the right of the tower's furthest point ("The
## Chair bubble will float to the right of the right most point").
func _delmar_chair_spot() -> Vector2:
	var d := stage.line_dir()
	var best := Vector2(Stage.PIER_END, Stage.DECK_Y + stage.barrel_top)
	var best_r := -INF
	for cid in tower:
		var climber: Climber = climbers.get(cid)
		if climber == null:
			continue
		for piece in climber.bodies:
			var p := Climber.pos2(climber.bodies[piece])
			if p.dot(d) > best_r:
				best_r = p.dot(d)
				best = p
	return Vector2(maxf(best.x, line - best.y) + 1.6, best.y - ChairScript.PICKUP_HEIGHT + 0.4)


func live_climbers() -> Array:
	var out: Array = []
	for pid in live:
		var cid: int = live[pid]
		if climbers.has(cid) and climbers[cid].state != Climber.State.FROZEN:
			out.append(climbers[cid])
	if is_instance_valid(partner) and partner.state == Climber.State.LIVE and not partner.removed:
		out.append(partner)
	return out


# ================================================================ the stream and puppets

@rpc("any_peer", "call_remote", "unreliable")
func _rpc_pose(cid: int, seq: int, pose: PackedFloat32Array, on_support: bool) -> void:
	var c: Climber = climbers.get(cid)
	if c == null or c.state != Climber.State.PUPPET:
		return
	if c.owner_peer != multiplayer.get_remote_sender_id():
		return  # only the owner streams a climber
	if c.growing():
		return  # still growing in: a pose in flight is the fallen body's (a respawn keeps its id)
	if seq <= int(_last_seq.get(cid, -1)) or not _valid_lock_pose(pose):
		return  # stale or duplicate: unreliable lanes arrive out of order
	c.puppet_on_support = on_support
	_last_seq[cid] = seq
	if not _puppet_buf.has(cid):
		_puppet_buf[cid] = []
	_puppet_buf[cid].append([_now, pose])
	while _puppet_buf[cid].size() > 12:
		_puppet_buf[cid].pop_front()


## Puppets play back the stream Feel "puppet_delay" seconds behind, interpolated.
func _tick_puppets() -> void:
	var delay := maxf(Feel.get_k("puppet_delay"), 1.25 / stream_hz())  # never less than a sample and a bit
	for cid in _puppet_buf.keys():
		var c: Climber = climbers.get(cid)
		if c == null or c.state != Climber.State.PUPPET or c.growing():
			continue  # a growing puppet grows here on its own clock
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
		var at_newest := t >= float(buf[-1][0])
		if at_newest and float(_puppet_at.get(cid, -1.0)) == float(buf[-1][0]):
			continue  # already standing on the newest sample: 16 transforms a tick saved per idle puppet
		c.apply_pose(_lerp_pose(a[1], b[1], f))
		if at_newest:
			_puppet_at[cid] = float(buf[-1][0])
		else:
			_puppet_at.erase(cid)


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


# The owner selects the take and pitch once for every listener.
func _audio_climber(cid: int) -> Climber:
	var c: Climber = climbers.get(cid)
	if c == null or c.removed or c.state == Climber.State.FROZEN:
		return null
	var sender := multiplayer.get_remote_sender_id()
	return c if c.owner_peer == (sender if sender != 0 else me()) else null


@rpc("any_peer", "call_remote", "reliable")
func _rpc_knockout_visual(cid: int, active: bool) -> void:
	var c := _audio_climber(cid)
	if c != null and c.state == Climber.State.PUPPET:
		c.set_knockout_visual(active)


@rpc("any_peer", "call_local", "reliable")
func _rpc_knockout(cid: int, clip: String) -> void:
	var c := _audio_climber(cid)
	if c != null and clip in Sound.SFX["knockout"]:
		Sound.stop_exertion(c.bodies["head"])
		Sound.play_at("knockout", c.bodies["head"].global_position, 0.0, world, clip)


@rpc("any_peer", "call_local", "reliable")
func _rpc_exertion(cid: int, clip: String) -> void:
	var c := _audio_climber(cid)
	if c != null:
		Sound.play_exertion(clip, c.bodies["head"])


## A rope bounce, on every machine: the placeholder boing at the rope, and the
## rope's spring (Parker 11-08).
@rpc("any_peer", "call_local", "reliable")
func _rpc_rope(cid: int, at: Vector3, speed: float) -> void:
	if _audio_climber(cid) == null or not at.is_finite() or not is_finite(speed):
		return
	_play_rope(at, speed)


@rpc("authority", "call_local", "reliable")
func _rpc_chair_rope(at: Vector3, speed: float) -> void:
	_play_rope(at, speed)


func _play_rope(at: Vector3, speed: float) -> void:
	if stage != null:
		stage.bounce_rope(signf(at.x), clampf(speed, 0.0, 20.0))


## The bell broadcasts one of the 13 approved strikes, at its authored pitch,
## to every listener alongside the existing visual pulse.
## Something went into Del Mar's sea at x: the splash and its sound on every machine.
@rpc("authority", "call_local", "reliable")
func _rpc_sea_splash(x: float, size: float) -> void:
	_sea_splash(x, size)


func _sea_splash(x: float, size: float) -> void:
	if stage != null and stage.sea != null and is_finite(x):
		stage.sea.splash(x, clampf(size, 0.3, 2.5))


## A floatie bounced someone: it squashes and boings on every machine.
@rpc("any_peer", "call_local", "reliable")
func _rpc_floatie(i: int, at: Vector3) -> void:
	if stage == null or stage.floaties == null or not at.is_finite():
		return
	if multiplayer.get_remote_sender_id() != me():
		stage.floaties.squash(i)
	# The rubber boing (Parker 11-11: "a sound effect when you hit them"), pitched to the
	# floatie's size, and the water it shoves.
	var boing := Sound.play_at("floatie", at, 2.0, world)
	if boing != null:
		boing.pitch_scale *= stage.floaties.pitch_of(i)
	if stage.sea != null:
		var fx := Vector3(stage.floaties.x_of(i), Stage.WATER_Y, 0.0)
		stage.sea.ripple(fx, 1.0)
		stage.sea.ripple(fx + Vector3(0.25, 0, 0), 0.6)
		stage.sea.spray(fx + Vector3(0.5, 0.0, 0.2), 0.45)
		stage.sea.spray(fx + Vector3(-0.5, 0.0, 0.2), 0.45)


const BELL_COOLDOWN_MS := 300  # per limb: a grip flickering on and off doesn't peal
var _bell_wait := {}
var bell_rings := 0  # rings heard on this machine (the batteries count them)


@rpc("any_peer", "call_local", "reliable")
func _rpc_bell(cid: int, at: Vector3, clip: String) -> void:
	if _audio_climber(cid) == null or not at.is_finite() or not clip in Sound.SFX["church_bell"]:
		return
	_play_bell(at, clip)


const DONKEY_CHANCE := 0.10
var _donkey_wait := {}
var _donkey_voice: AudioStreamPlayer3D


func _donkey_contact_ready(key: String) -> bool:
	if _donkey_busy() or stage == null or stage.base_id != "donkey" or _donkey_wait.get(key, 0) > Time.get_ticks_msec():
		return false
	_donkey_wait[key] = Time.get_ticks_msec() + BELL_COOLDOWN_MS
	return true


func _donkey_busy() -> bool:
	return is_instance_valid(_donkey_voice) and _donkey_voice.playing


@rpc("any_peer", "call_local", "reliable")
func _rpc_donkey(cid: int, clip: String) -> void:
	# Only the host accepts requests, so simultaneous peers cannot start two brays.
	if is_host() and _audio_climber(cid) != null and not _donkey_busy() and clip in Sound.SFX["donkey"]:
		_rpc_donkey_play.rpc(clip, false)


func _on_chair_donkey() -> void:
	if is_host() and _donkey_contact_ready("chair") and randf() < DONKEY_CHANCE:
		_rpc_donkey_play.rpc(Sound.SFX["donkey"].pick_random(), true)


@rpc("authority", "call_local", "reliable")
func _rpc_donkey_play(clip: String, chair_hit: bool) -> void:
	_play_donkey(clip, chair_hit)


func _play_donkey(clip: String, chair_hit := false) -> void:
	if not _donkey_busy() and stage != null and stage.base_id == "donkey" and clip in Sound.SFX["donkey"]:
		_donkey_voice = Sound.play_at("donkey", stage.base_root.to_global(stage.donkey_head), linear_to_db(2.0) if chair_hit else 0.0, stage.base_root, clip)


func _on_chair_bell(at: Vector3) -> void:
	if not is_host() or _bell_wait.get("chair", 0) > Time.get_ticks_msec():
		return
	_bell_wait["chair"] = Time.get_ticks_msec() + BELL_COOLDOWN_MS
	_rpc_chair_bell.rpc(at, Sound.SFX["church_bell"].pick_random())


@rpc("authority", "call_local", "reliable")
func _rpc_chair_bell(at: Vector3, clip: String) -> void:
	if not at.is_finite() or clip not in Sound.SFX["church_bell"]:
		return
	_play_bell(at, clip, linear_to_db(2.0))


func _play_bell(at: Vector3, clip: String, extra_gain_db := 0.0) -> void:
	Sound.play_at("church_bell", at, extra_gain_db, world, clip)
	bell_rings += 1
	if stage != null:
		stage.pulse_bell()


@rpc("any_peer", "call_local", "reliable")
func _rpc_slap(cid: int, at: Vector3, clip: String, pitch: float) -> void:
	if _audio_climber(cid) != null and at.is_finite() and pitch >= 0.92 and pitch <= 1.08:
		Sound.play_grab(clip, at, pitch, world)


@rpc("any_peer", "call_local", "reliable")
func _rpc_fart(cid: int, take: int, pitch: float, budget: float) -> void:
	var c := _audio_climber(cid)
	if c == null:
		return
	var voice: FartVoice = c.bodies["pelvis"].get_node("FartVoice")
	if take == 0:
		voice.release()
	elif take >= 1 and take <= FartVoice.COUNT and pitch >= 0.84 and pitch <= 1.18:
		if budget > 0.0 and budget <= FartVoice.CAPACITY:
			voice.start(take, pitch, budget)


# ================================================================ grabbing across machines

func _on_grab_made(c: Climber, limb: int, other: Object) -> void:
	if not (other is RigidBody3D and other.has_meta("climber")):
		return
	var oc := Climber.climber_of(other)
	if oc == null or oc.state != Climber.State.PUPPET or oc.owner_peer == me():
		return
	_remote_grabs["%d:%d" % [c.climber_id, limb]] = [oc.climber_id, str(other.get_meta("piece"))]
	_rpc_grabbed.rpc_id(oc.owner_peer, oc.climber_id, c.climber_id, limb, true)


func _on_grab_lost(c: Climber, limb: int) -> void:
	var key := "%d:%d" % [c.climber_id, limb]
	if not _remote_grabs.has(key):
		return
	var g: Array = _remote_grabs[key]
	_remote_grabs.erase(key)
	var oc: Climber = climbers.get(g[0])
	if oc != null:
		_rpc_grabbed.rpc_id(oc.owner_peer, g[0], c.climber_id, limb, false)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_grabbed(cid: int, source_id: int, limb: int, connected: bool) -> void:
	var c: Climber = climbers.get(cid)
	var source: Climber = climbers.get(source_id)
	if c == null or source == null or c.owner_peer != me() or source.owner_peer != multiplayer.get_remote_sender_id() or limb < 0 or limb >= 4:
		return
	var key := Vector2i(source_id, limb)
	if not _pulls.has(cid):
		_pulls[cid] = {}
	if connected:
		_pulls[cid][key] = {}
	else:
		_pulls[cid].erase(key)
		c.remote_pulls.erase(key)
	c.remote_grabbed = _pulls[cid].size()


func _send_contact_loads(c: Climber) -> void:
	for i in c.limbs.size():
		var l: Dictionary = c.limbs[i]
		var target: Climber = l.grab_climber
		if is_instance_valid(target) and target.state == Climber.State.PUPPET:
			_rpc_pull.rpc_id(target.owner_peer, target.climber_id, c.climber_id, i, l.grab_piece, l.contact_offset, l.contact_force, c.grounded_locally(), c.touches_solid())


@rpc("any_peer", "call_remote", "unreliable")
func _rpc_pull(cid: int, source_id: int, limb: int, piece: String, offset: Vector3, force: Vector3, supported: bool, directly_supported: bool = false) -> void:
	var c: Climber = climbers.get(cid)
	var source: Climber = climbers.get(source_id)
	var key := Vector2i(source_id, limb)
	if c == null or source == null or c.owner_peer != me() or source.owner_peer != multiplayer.get_remote_sender_id() or c.state != Climber.State.LIVE:
		return
	if not _pulls.has(cid) or not _pulls[cid].has(key) or not c.bodies.has(piece) or not offset.is_finite() or not force.is_finite():
		return
	var cap := Feel.get_k("pull_cap") * c.total_mass * 9.8
	_pulls[cid][key] = {"piece": piece, "offset": offset, "force": force.limit_length(cap), "supported": supported, "directly_supported": directly_supported, "time": _now}

# ================================================================ leaving

func _on_peer_left(id: int) -> void:
	if phase not in ["turn", "round", "between", "over"]:
		return  # (the lobby's waiting room follows the member list; idle has no match)
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
	elif phase == "round":
		var settled := true
		for pid in round_players:
			if alive.get(pid, false) and not locked.has(pid):
				settled = false
		if settled:
			_end_of_play()


func tower_peak() -> Vector2:
	if stage != null and stage.delmar:
		# Del Mar's tower reaches out along the rope: its furthest piece along (1, 1).
		var far := Vector2(stage.base_root.position.x, 1.5)
		var best_d := -INF
		var dir := stage.line_dir()
		for cid in tower:
			var cl: Climber = climbers[cid]
			for piece in cl.bodies:
				var p3: Vector3 = (cl.bodies[piece] as RigidBody3D).global_position
				var d := Vector2(p3.x, p3.y).dot(dir)
				if d > best_d:
					best_d = d
					far = Vector2(p3.x, p3.y)
		return far
	var highest := Vector2(0, -INF)
	for cid in tower:
		var climber: Climber = climbers[cid]
		for piece in climber.bodies:
			var height := climber.piece_top(piece)
			if height > highest.y:
				var body: RigidBody3D = climber.bodies[piece]
				highest = Vector2(body.global_position.x, height)
	return Vector2(0, stage.first_line) if tower.is_empty() else highest


@rpc("authority", "call_local", "reliable")
func _rpc_spawn_chair(generation: int, top: Vector2, dent_hits: Vector2i) -> void:
	_clear_chair()
	_chair_wet = false
	chair_generation = generation
	chair_spawn_top = top
	chair = ChairScript.new()
	if is_host():
		chair.terrain_struck.connect(_play_chair_impact_sound)
		chair.bell_struck.connect(_on_chair_bell)
		chair.donkey_struck.connect(_on_chair_donkey)
		chair.rope_struck.connect(func(at: Vector3, speed: float): _rpc_chair_rope.rpc(at, speed))
	chair.setup(dress, dent_hits)
	world.add_child(chair)
	chair.float_above(top)


func _clear_chair() -> void:
	if is_instance_valid(chair_debris):
		chair_debris.queue_free()
	chair_debris = null
	if is_instance_valid(chair):
		chair.queue_free()
		chair = null
	remote_chair_limbs.clear()


func _clear_arena_props() -> void:
	_clear_chair()
	if is_instance_valid(partner):
		_remove_partner()


func _remove_partner() -> void:
	# Locked NPCs are permanent tower pieces, just like locked human climbers.
	# Retire the active reference without removing their geometry or grips.
	if partner.state == Climber.State.FROZEN and tower.has(partner.climber_id):
		partner = null
		return
	# Anyone holding the partner lets go first: never leave a joint on a freed body.
	for o in climbers.values():
		var oc: Climber = o
		for i in oc.limbs.size():
			if oc.limbs[i].grab_climber == partner:
				oc.release(i)
	if is_instance_valid(chair) and chair.holder == -2:
		chair.drop(partner, get_physics_process_delta_time())
	climbers.erase(-2)
	tower.erase(-2)
	partner.remove()
	partner = null


func set_practice_ai(level: String) -> void:
	if not practice or level not in ["none", "stationary", "easy", "hard"]:
		return
	settings["practice_ai"] = level
	settings["practice_npc"] = level != "none"
	if level == "none":
		if is_instance_valid(partner):
			_remove_partner()
		_partner_out = 0.0
		return
	if not is_instance_valid(partner) or partner.state != Climber.State.LIVE:
		_spawn_partner()
	else:
		partner.configure(self, level)

func partner_can_lock() -> bool:
	return practice and is_instance_valid(partner) and partner.state == Climber.State.LIVE and partner.knockout_left <= 0 and phase in ["turn", "round"] and live_gap(partner) > LOCK_MARGIN and (partner.welded_to_support() or _pose_on_support(partner, partner.pose()))

func lock_partner() -> void:
	if not partner_can_lock():
		return
	if is_instance_valid(chair) and chair.holder == -2:
		chair.drop(partner, get_physics_process_delta_time())
	partner.freeze()
	_snap_static(partner)
	_free_locked_overlaps(partner)
	partner.climber_id = _cid_next
	_cid_next += 1
	climbers[partner.climber_id] = partner
	tower.append(partner.climber_id)
	partner_last_lock = partner.centre_of_mass()
	if mode.line == "raise":
		line = maxf(line, measure(partner) + float(mode.get("line_gap", 0.0)))
	announce.emit("Practice partner locked in!", false)

func _spawn_partner() -> void:
	if is_instance_valid(partner):
		_remove_partner()
	partner_attempt += 1
	var side := 1.0
	if str(settings.get("practice_ai", "stationary")) == "easy" and partner_attempt > 1:
		side = -1.0 if randf() < 0.5 else 1.0
	var feet := _open_spawn(stage.spawn_point(-1) if stage.delmar else Vector2(side * 3.2, 0.05))
	partner = PartnerScript.new()
	partner.climber_id = -2
	partner.player_id = -2
	partner.owner_peer = me()
	partner.display_name = "Practice partner"
	add_child(partner)
	partner.build(feet, world, PRACTICE_PARTNER_MODEL if dress else null)
	partner.configure(self, str(settings.get("practice_ai", "stationary")))
	partner.rope_bounced.connect(_play_rope)
	partner.release_contact.connect(func(at: Vector3): Sound.play_grab(Sound.pick_grab(), at, randf_range(0.92, 1.08), world))
	# The pause menu cannot advance a physics-driven grow animation. Build at
	# full size there; live respawns keep the normal animated entrance.
	if grow_spawns and not get_tree().paused:
		partner.grow_in()
	partner.knocked_out.connect(func():
		Sound.stop_exertion(partner.bodies["head"])
		Sound.play_at("knockout", partner.bodies["head"].global_position, 0.0, world, Sound.SFX["knockout"].pick_random()))


@rpc("any_peer", "call_remote", "reliable")
func _rpc_chair_limb(cid: int, selected: int, release_velocity: Vector3) -> void:
	var c: Climber = climbers.get(cid)
	if not is_host() or c == null or c.owner_peer != multiplayer.get_remote_sender_id() or selected < -1 or selected >= 4:
		return
	remote_chair_limbs[cid] = selected
	if chair != null and chair.holder == cid and selected != chair.limb:
		chair.drop(c, get_physics_process_delta_time())
		if release_velocity.is_finite():
			chair.linear_velocity = Vector3(release_velocity.x, release_velocity.y, 0).limit_length(8.0)


func _tick_chair(dt: float) -> void:
	if chair == null or phase not in ["turn", "round", "between"]:
		return
	var carrier: Climber = partner if chair.holder == -2 else climbers.get(chair.holder)
	if not is_host():
		if chair.grip_joint.is_valid():
			return
		if not chair.in_bubble:
			chair.global_transform = chair.global_transform.interpolate_with(chair.loose_target, 1.0 - exp(-30.0 * dt))
		return
	if chair.holder != -1:
		if carrier == null or carrier.state == Climber.State.FROZEN or _chair_limb(carrier) != chair.limb:
			chair.drop(carrier, dt)
		else:
			chair.follow(carrier, dt)
			chair.tick_ropes(dt)
			_apply_chair_hits(chair.sweep_hits(dt, carrier.climber_id))
	elif stage.out_of_bounds(Climber.pos2(chair)):
		_rpc_retire_chair.rpc(chair_generation)
	elif stage.delmar and not chair.in_bubble and chair.global_position.y < Stage.WATER_Y:
		# The chair in the sea (Parker 11-11: "chairs all create splashes"): a splash going
		# in, then it sinks slowly away; out of bounds under the water, it's retired.
		if not _chair_wet:
			_chair_wet = true
			_rpc_sea_splash.rpc(chair.global_position.x, 1.1)
		var k := 1.0 - exp(-10.0 * dt)  # water stops a chair fast
		var v := chair.linear_velocity
		v.y += 9.8 * chair.gravity_scale * dt * 0.85  # the water bears most of its weight
		chair.linear_velocity = v.lerp(Vector3(v.x * 0.25, -1.4, 0.0), k)
		chair.angular_velocity *= 1.0 - k * 0.5
	else:
		if not chair.in_bubble:
			chair.release_carrier_when_clear()
			chair.tick_ropes(dt)
			chair.settle()
		if chair.thrower != -1:
			_apply_chair_hits(chair.sweep_hits(dt, chair.thrower))
			if chair == null:
				return
		for c: Climber in live_climbers():
			var selected := _chair_limb(c)
			if selected >= 0 and chair.can_reach(c, selected):
				chair.pick_up(c, selected)
				break


@rpc("authority", "call_local", "reliable")
func _rpc_retire_chair(generation: int) -> void:
	if generation == chair_generation:
		_clear_chair()

func _chair_limb(c: Climber) -> int:
	return c.active_limb() if c.owner_peer == me() else int(remote_chair_limbs.get(c.climber_id, -1))


func _apply_chair_hits(hits: Dictionary) -> void:
	for id in hits:
		var victim: Climber = partner if id == -2 else climbers.get(id)
		if victim == null:
			continue
		var hit: Dictionary = hits[id]
		var heavy: bool = hit.speed > ChairScript.LIGHT_HIT_MAX_SPEED
		if heavy:
			chair.set_hit_count(chair.hit_count + 1)
		if victim == partner or victim.owner_peer == me():
			_chair_impact(victim, hit.piece, hit.offset, hit.impulse)
		else:
			_rpc_chair_impact.rpc_id(victim.owner_peer, id, hit.piece, hit.offset, hit.impulse)
		var at: Vector3 = victim.bodies[hit.piece].to_global(hit.offset)
		_play_chair_impact_sound(at, hit.speed)
		if chair.hit_count == ChairScript.BREAK_HITS:
			_rpc_chair_broke.rpc(chair.global_transform, hit.impulse, Sound.SFX["chair_break"].pick_random())
			return


func _play_chair_impact_sound(at: Vector3, speed: float) -> void:
	var kind := "chair_heavy" if speed > ChairScript.LIGHT_HIT_MAX_SPEED else "chair_light"
	_rpc_chair_sound.rpc(kind, Sound.SFX[kind].pick_random(), at)


@rpc("authority", "call_local", "reliable")
func _rpc_chair_sound(kind: String, clip: String, at: Vector3) -> void:
	Sound.play_at(kind, at, 0.0, world, clip)


@rpc("authority", "call_local", "reliable")
func _rpc_chair_broke(pose: Transform3D, impact: Vector3, clip: String) -> void:
	if chair == null:
		return
	chair_debris = chair.break_apart(pose, impact)
	Sound.play_at("chair_break", pose.origin, 0.0, world, clip)
	chair.hide()
	chair.queue_free()
	chair = null


func _chair_impact(victim: Climber, piece_name: String, local_offset: Vector3, impulse: Vector3) -> void:
	var piece: RigidBody3D = victim.bodies.get(piece_name)
	if piece == null:
		return
	if piece_name == "head" and victim.knockout_left <= 0 and impulse.length() / piece.mass >= 4.5:
		victim.knock_out()
	var offset := piece.global_basis * local_offset
	piece.apply_impulse(impulse, offset)


@rpc("authority", "call_remote", "reliable")
func _rpc_chair_impact(cid: int, piece: String, local_offset: Vector3, impulse: Vector3) -> void:
	var victim: Climber = climbers.get(cid)
	if victim != null and victim.owner_peer == me() and victim.state == Climber.State.LIVE:
		_chair_impact(victim, piece, local_offset, impulse)


@rpc("authority", "call_remote", "unreliable_ordered")
func _rpc_chair_pose(generation: int, cid: int, limb: int, point: Vector3, pose: Transform3D, hit_count: int, in_bubble: bool) -> void:
	if chair == null or generation != chair_generation:
		return
	# Capture the old floating bubble position before applying the carried pose.
	chair.in_bubble = in_bubble
	if chair.holder != cid or chair.limb != limb:
		chair.clear_grip()
		chair.freeze = true  # loose replicas follow the host snapshots
		chair.global_transform = pose
		if cid >= 0 or in_bubble:
			chair.set_carrier(climbers.get(cid))
	if cid < 0 and not in_bubble:
		chair.release_carrier_when_clear()
	chair.holder = cid
	chair.limb = limb
	chair.grip_point = point
	var carrier: Climber = climbers.get(cid)
	if carrier != null and limb >= 0 and not chair.grip_joint.is_valid():
		var end: RigidBody3D = carrier.bodies[carrier.limbs[limb].def.end]
		chair.global_position = end.global_position - pose.basis * point
		chair.lock_grip(end)
	chair.loose_target = pose
	chair.set_hit_count(hit_count)

func _clear_climbers() -> void:
	if is_instance_valid(partner):
		_remove_partner()
	for c in climbers.values():
		c.remove()
	climbers.clear()
	live.clear()
	tower.clear()
	_puppet_buf.clear()
	_last_seq.clear()
	_pulls.clear()
	_pending_freeze.clear()
	_last_sent.clear()
	_puppet_at.clear()
	_overtime = 0.0


func end_match() -> void:
	if peak != null:
		peak.leave()  # (it saves where the climber is)
	peak_on = false
	if stage != null and stage.delmar:
		stage.set_delmar(world, false)  # the pier, the sea and the rope go with the match
		stage.place_base()
	if phase == "lobby" and stage != null:
		stage.set_base(world, str(Net.settings.get("base", "barrel")))
	_clear_arena_props()
	_clear_climbers()
	phase = "idle"
	phase_changed.emit(phase)


## Host sends only authenticated members, after Net's completed handshake.
func sync_waiting_room() -> void:
	if not is_host() or Net.in_match:
		return
	var guests: Array = []
	for entry in Net.build_roster():
		if int(entry.peer) != 1:
			entry.pid = int(entry.peer) * 16 + int(entry.slot)
			if bool(entry.get("random", false)):
				entry.name = climbers[live[entry.pid]].display_name if live.has(entry.pid) and climbers.has(live[entry.pid]) else NameGen.make()
			guests.append(entry)
	var snapshot := {}
	for cid in climbers:
		snapshot[cid] = climbers[cid].pose()
	_rpc_waiting_room.rpc(guests, snapshot)


@rpc("authority", "call_local", "reliable")
func _rpc_waiting_room(guests: Array, snapshot: Dictionary) -> void:
	if phase != "lobby":
		_clear_arena_props()
		_clear_climbers()
		settings = {"mode": "practice", "stage": "plaza", "spawn": "alternate"}
		mode = Modes.row("practice")
		practice = true
		phase = "lobby"
		_ring_out.clear()
		if stage == null:
			stage = Stage.new("plaza")
			stage.build(world, dress)
		Climber.rope_x = stage.ring_half()
		stage.set_delmar(world, false)
		stage.set_base(world, "bell")
		stage.place_base()
	roster = guests
	var ids := guests.map(func(r): return int(r.pid))
	for pid in live.keys():
		if pid not in ids:
			_drop_climber(live[pid])
			live.erase(pid)
	for i in guests.size():
		var r: Dictionary = guests[i]
		var pid := int(r.pid)
		if live.has(pid):
			continue
		_rpc_spawn(pid, pid, _open_spawn(Vector2(-6.5 + (i % 6) * 2.6, (i / 6) * 2.5)), str(r.name))
		if snapshot.has(pid):
			climbers[pid].apply_pose(snapshot[pid])
