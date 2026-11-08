extends Node
## THE BATTERIES. Run one headless, always with a timeout:
##   Godot_console.exe --headless --path . res://tests/battery.tscn -- --spike
## Flags: --spike (P1 physics gate; --part=NAME runs one part), --grab, --climb,
## --frozen, --tower, --scramble, --devices, --net. Each prints PASS/FAIL lines
## and "RESULT fails=N", then quits with exit code N (capped at 100).

const ClimberScript := preload("res://climber/climber.gd")
const Drivers := preload("res://climber/drivers.gd")
const Layout := preload("res://climber/body_layout.gd")

var fails := 0
var world: Node3D
var _next_id := 1


func t(label: String, ok: bool, extra = "") -> void:
	print(("PASS  " if ok else "FAIL  ") + label + ("" if str(extra) == "" else "  [%s]" % str(extra)))
	if not ok:
		fails += 1


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	world = Node3D.new()
	world.name = "World"
	add_child(world)
	var ran := false
	for a in args:
		if a.begins_with("--part="):
			continue
		var fn := "_run_" + a.trim_prefix("--")
		if has_method(fn):
			ran = true
			print("== ", a)
			var t0 := Time.get_ticks_msec()
			await call(fn)
			print("   (%s took %.1f s wall)" % [a, (Time.get_ticks_msec() - t0) / 1000.0])
			await _clear()
	if not ran:
		print("no battery named; flags: --spike [--part=NAME] --grab --climb --frozen --tower --scramble --devices --net")
	print("RESULT fails=", fails)
	get_tree().quit(mini(fails, 100))


func _clear() -> void:
	for c in get_children():
		if c is Climber:
			c.remove()
	for c in world.get_children():
		c.queue_free()
	await frames(2)


func frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func seconds(s: float) -> void:
	await frames(int(s * Engine.physics_ticks_per_second))


func spawn(feet: Vector2) -> Climber:
	var c: Climber = ClimberScript.new()
	c.climber_id = _next_id
	_next_id += 1
	add_child(c)
	c.build(feet, world, null)
	c.driver = Drivers.ScriptDriver.new()
	return c


func static_box(centre: Vector2, half: Vector2) -> StaticBody3D:
	var sb := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var r := BoxShape3D.new()
	r.size = Vector3(half.x * 2.0, half.y * 2.0, 2.0)
	col.shape = r
	sb.add_child(col)
	sb.collision_layer = Climber.LAYER_WORLD
	sb.collision_mask = 0
	var mat := PhysicsMaterial.new()
	mat.friction = 1.0
	sb.physics_material_override = mat
	sb.position = Vector3(centre.x, centre.y, 0)
	world.add_child(sb)
	Climber.sync_server(sb)
	return sb


func move(sb: CollisionObject3D, p: Vector2) -> void:
	sb.global_position = Vector3(p.x, p.y, 0)
	Climber.sync_server(sb)


func ground() -> StaticBody3D:
	return static_box(Vector2(0, -0.5), Vector2(40, 0.5))


func bar_at(p: Vector2) -> StaticBody3D:
	return static_box(p, Vector2(0.04, 0.04))


func finite_body(c: Climber) -> bool:
	for b in c.bodies.values():
		var p: Vector3 = b.global_position
		if not (is_finite(p.x) and is_finite(p.y)) or b.linear_velocity.length() > 80.0 or absf(p.z) > 0.01:
			return false
	return true


func physics_ms() -> float:
	return Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0


# ================================================================ P1: --spike

const SPIKE_PARTS := ["signs", "limits", "hang", "fling", "limp", "tower", "eight", "chain"]


func _run_spike() -> void:
	var only := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--part="):
			only = a.get_slice("=", 1)
	for part in SPIKE_PARTS:
		if only != "" and part != only:
			continue
		var t0 := Time.get_ticks_msec()
		await call("_spike_" + part)
		print("      (%s took %.1f s wall)" % [part, (Time.get_ticks_msec() - t0) / 1000.0])
		await _clear()


func _pair() -> Array:
	var a := static_box(Vector2(0, 5), Vector2(0.05, 0.05))
	var b := RigidBody3D.new()
	var col := CollisionShape3D.new()
	var bx := BoxShape3D.new()
	bx.size = Vector3(0.6, 0.1, 0.1)
	col.shape = bx
	b.add_child(col)
	b.gravity_scale = 0.0
	b.axis_lock_linear_z = true
	b.axis_lock_angular_x = true
	b.axis_lock_angular_y = true
	b.position = Vector3(0.3, 5, 0)
	world.add_child(b)
	Climber.sync_server(b)
	b.add_collision_exception_with(a)
	var rid := PhysicsServer3D.joint_create()
	PhysicsServer3D.joint_make_hinge(rid, a.get_rid(), Transform3D(Basis(), Vector3.ZERO), b.get_rid(), Transform3D(Basis(), Vector3(-0.3, 0, 0)))
	return [a, b, rid]


## The engine's hinge signs, pinned once: Climber.MOTOR_SIGN and LIMIT_FLIP.
func _spike_signs() -> void:
	var p := _pair()
	var b: RigidBody3D = p[1]
	var rid: RID = p[2]
	PhysicsServer3D.hinge_joint_set_flag(rid, PhysicsServer3D.HINGE_JOINT_FLAG_ENABLE_MOTOR, true)
	PhysicsServer3D.hinge_joint_set_param(rid, PhysicsServer3D.HINGE_JOINT_MOTOR_TARGET_VELOCITY, 2.0 * Climber.MOTOR_SIGN)
	PhysicsServer3D.hinge_joint_set_param(rid, PhysicsServer3D.HINGE_JOINT_MOTOR_MAX_IMPULSE, 10.0)
	await frames(30)
	var ang := rad_to_deg(Climber.angle_of(b))
	t("signs: a +2 rad/s motor (x MOTOR_SIGN) turns the child CCW", ang > 10.0 and ang < 60.0, "%.1f deg after 0.25 s" % ang)
	PhysicsServer3D.hinge_joint_set_flag(rid, PhysicsServer3D.HINGE_JOINT_FLAG_ENABLE_MOTOR, false)
	Climber.set_hinge_limits(rid, -10.0, 30.0)
	for i in 120:
		b.apply_torque(Vector3(0, 0, 3.0))
		await get_tree().physics_frame
	var up := rad_to_deg(Climber.angle_of(b))
	for i in 240:
		b.apply_torque(Vector3(0, 0, -3.0))
		await get_tree().physics_frame
	var lo := rad_to_deg(Climber.angle_of(b))
	t("signs: a CCW push stops at the upper limit (+30)", absf(up - 30.0) < 3.0, "%.1f" % up)
	t("signs: a CW push stops at the lower limit (-10)", absf(lo + 10.0) < 3.0, "%.1f" % lo)
	PhysicsServer3D.free_rid(rid)


## Limits hold: the forearm and head shoved hard past their ends while hanging.
func _spike_limits() -> void:
	var c := spawn(Vector2(1.0, 2.0))
	var bar := bar_at(c.limb_end(1))
	c.attach(1, bar)
	var worst := 0.0
	var fore: RigidBody3D = c.bodies["arm_l_lo"]
	var head: RigidBody3D = c.bodies["head"]
	for i in 240:
		var push := 1.0 if i < 120 else -1.0
		fore.apply_torque(Vector3(0, 0, push * fore.mass * 9.8 * 0.6))  # the arm's weight at reach, x2
		head.apply_torque(Vector3(0, 0, -push * head.mass * 9.8 * 0.4))
		await get_tree().physics_frame
		worst = maxf(worst, c.worst_limit_excess())
	t("limits: joints shoved with 2x an arm's weight overshoot under 8 deg (loose friction joints)", worst < 8.0, "worst %.1f deg" % worst)
	await frames(240)
	t("limits: back inside every limit once let go", c.worst_limit_excess() < 1.0, "%.2f deg" % c.worst_limit_excess())


func _spike_hang() -> void:
	var c := spawn(Vector2(1.0, 2.0))
	var bar := bar_at(c.limb_end(0))
	c.attach(0, bar)
	var worst := 0.0
	for i in int(30.0 * Engine.physics_ticks_per_second):
		await get_tree().physics_frame
		worst = maxf(worst, c.worst_joint_gap())
	t("hang: 30 s by one hand, joints stay under 2 cm", worst < 0.02, "worst %.4f m (%s)" % [worst, c.last_worst_gap_joint])
	t("hang: the hand is still stuck", c.limbs[0].grab.is_valid())
	t("hang: the body settles under the bar (a stiff body is a slow pendulum)", c.linear_speed() < 0.25, "%.3f m/s" % c.linear_speed())
	t("hang: nothing left the plane", finite_body(c))


func _spike_fling() -> void:
	var worst := 0.0
	var worst_lim := 0.0
	var max_speed := 0.0
	var bad := 0
	var flown := 0
	for trial in 20:
		var c := spawn(Vector2(0, 3.0))
		var bar := bar_at(c.limb_end(0))
		c.attach(0, bar)
		var d: Drivers.ScriptDriver = c.driver
		var dir0 := float(trial) * 0.7
		# Pump the swing: sweep the stick round the clock at full push for 1.8 s.
		# Hand 0 is the anchor (never held). The other three are dragged hard out to
		# one side and up (a different side each trial): the body swings out on the
		# anchor arm. Then the anchor lets go: a fling, the reference game's way.
		var side := Vector2.from_angle(dir0).normalized()
		side.y = absf(side.y) * 0.6 + 0.3
		for i in int(1.0 * Engine.physics_ticks_per_second):
			for limb in [1, 2, 3]:
				d.point_limb(limb, true, c.limb_root(limb) + side.normalized() * 2.5)
			await get_tree().physics_frame
			worst = maxf(worst, c.worst_joint_gap())
			worst_lim = maxf(worst_lim, c.worst_limit_excess())
		var before := c.centre_of_mass()
		d.clear()
		c.release(0)
		for i in int(1.2 * Engine.physics_ticks_per_second):
			await get_tree().physics_frame
			worst = maxf(worst, c.worst_joint_gap())
			max_speed = maxf(max_speed, c.linear_speed())
		if c.centre_of_mass().distance_to(before) > 0.5:
			flown += 1
		if not finite_body(c):
			bad += 1
		c.remove()
		bar.queue_free()
		await frames(1)
	t("fling: 20 hard drags and releases, no joint opens past 8 cm", worst < 0.08, "worst %.4f m" % worst)
	t("fling: limits hold under hard drags (under 40 deg over; Jolt's limits give under a full-strength pull)", worst_lim < 40.0, "worst %.1f deg" % worst_lim)
	t("fling: nothing explodes (finite, in the plane, under 40 m/s)", bad == 0 and max_speed < 40.0, "bad %d, top %.1f m/s" % [bad, max_speed])
	t("fling: the swings actually fling (half travel > 0.5 m)", flown >= 10, "%d/20" % flown)


func _spike_limp() -> void:
	var c := spawn(Vector2(0, 6.0))
	var d: Drivers.ScriptDriver = c.driver
	for i in [0, 2, 3]:
		d.set_limb(i, true, Vector2.UP, 1.0)
	await frames(3)
	var any_drive := false
	for l in c.limbs:
		any_drive = any_drive or l.driving
	t("limp: held limbs don't drive while loose in the air", not any_drive and not c.is_attached())
	bar_at(c.limb_end(1))  # the unheld right hand touches a bar
	await frames(3)
	t("limp: an unheld hand touching a bar sticks by itself", c.limbs[1].grab.is_valid())
	await frames(1)
	var all_drive := true
	for i in [0, 2, 3]:
		all_drive = all_drive and c.limbs[i].driving
	t("limp: once something is stuck, every held limb drives", all_drive)
	d.set_limb(1, true, Vector2.UP, 1.0)
	await frames(2)
	t("limp: picking up the last stuck limb drops you (nothing drives)", not c.limbs[1].grab.is_valid() and not c.is_attached())


## 20 climbers dropped in a heap on a block and frozen one by one, then one live.
func _spike_tower() -> void:
	seed(11)
	ground()
	static_box(Vector2(0, 0.8), Vector2(0.7, 0.8))
	var frozen: Array = []
	var top := 1.6
	for n in 20:
		var c := spawn(Vector2(randf_range(-0.3, 0.3), top + 0.2))
		await seconds(1.0)
		c.freeze()
		top = maxf(top, c.top_height())
		frozen.append(c)
	var live := spawn(Vector2(0, top + 0.3))
	var worst_ms := 0.0
	var sum := 0.0
	var n_ticks := 360
	for i in n_ticks:
		await get_tree().physics_frame
		var ms := physics_ms()
		worst_ms = maxf(worst_ms, ms)
		sum += ms
	t("tower: 20 frozen + 1 live, the live one stays sane", finite_body(live))
	t("tower: frozen climbers stay put", frozen[0].bodies["chest"].freeze)
	t("tower: the heap grew (top over 3 m)", top > 3.0, "%.2f m" % top)
	print("      tower: physics frame avg %.3f ms, worst %.3f ms, top %.2f m" % [sum / n_ticks, worst_ms, top])


## Eight live climbers on a block, every limb flailing and grabbing for 20 s.
func _spike_eight() -> void:
	seed(7)  # the flailing is random: a fixed seed makes the run repeatable
	ground()
	static_box(Vector2(0, 0.8), Vector2(0.7, 0.8))
	var cs: Array = []
	for n in 8:
		cs.append(spawn(Vector2(-2.6 + n * 0.75, 1.7 + (n % 2) * 1.2)))
	var worst_gap := 0.0
	var worst_ms := 0.0
	var sum := 0.0
	var ticks := int(20.0 * Engine.physics_ticks_per_second)
	var rival_grabs := [0]
	for c in cs:
		c.grab_made.connect(func(_c, _l, o):
			if o is RigidBody3D and o.has_meta("climber"):
				rival_grabs[0] += 1)
	for i in ticks:
		if i % 30 == 0:
			for c in cs:
				var d: Drivers.ScriptDriver = c.driver
				for limb in 4:
					d.set_limb(limb, randf() < 0.6, Vector2.from_angle(randf() * TAU), randf())
		await get_tree().physics_frame
		var ms := physics_ms()
		worst_ms = maxf(worst_ms, ms)
		sum += ms
		if i % 10 == 0:
			for c in cs:
				worst_gap = maxf(worst_gap, c.worst_joint_gap())
	var ok := true
	for c in cs:
		ok = ok and finite_body(c)
	var avg := sum / ticks
	t("eight live: 20 s welded into a blob (every unheld limb sticks), joints under 12 cm", worst_gap < 0.12, "worst %.4f m" % worst_gap)
	t("eight live: all sane (finite, in the plane)", ok)
	t("eight live: they grabbed each other", rival_grabs[0] > 0, rival_grabs[0])
	t("eight live: physics frame under 6 ms on average (eight welded climbers)", avg < 6.0, "avg %.3f ms, worst %.3f ms" % [avg, worst_ms])


## A hangs from B, B from C, C from a bar. C freezes: nobody drops.
func _spike_chain() -> void:
	var cC := spawn(Vector2(0, 7.0))
	var bar := bar_at(cC.limb_end(0))
	cC.attach(0, bar)
	await seconds(2.0)
	var hand_off := Layout.end_point("hand_l") * cC.body_scale
	var cB := spawn(cC.limb_end(2) - hand_off)
	cB.attach(0, cC.bodies["foot_l"])
	await seconds(2.0)
	var cA := spawn(cB.limb_end(2) - hand_off)
	cA.attach(0, cB.bodies["foot_l"])
	await seconds(3.0)
	t("chain: C is held by B, B by A (grabbed_by counts)", cC.grabbed_by >= 1 and cB.grabbed_by >= 1, "%d %d" % [cC.grabbed_by, cB.grabbed_by])
	var b_hand := cB.limb_end(0)
	cC.freeze()
	var worst_slip := 0.0
	var worst_gap := 0.0
	for i in int(3.0 * Engine.physics_ticks_per_second):
		await get_tree().physics_frame
		worst_slip = maxf(worst_slip, cB.limb_end(0).distance_to(b_hand))
		worst_gap = maxf(worst_gap, maxf(cA.worst_joint_gap(), cB.worst_joint_gap()))
	t("chain: after C freezes, B and A still hold on", cB.limbs[0].grab.is_valid() and cA.limbs[0].grab.is_valid())
	t("chain: B's hand stays on C's frozen foot (under 6 cm)", worst_slip < 0.06, "%.4f m" % worst_slip)
	t("chain: joints hold through the freeze (under 13 cm, two stiff climbers on one wrist)", worst_gap < 0.13, "%.4f m" % worst_gap)
	t("chain: B still counts as attached (A holds it, it holds C)", cB.is_attached())


# ================================================================ P2: --grab, --frozen

func _run_grab() -> void:
	ground()
	var c := spawn(Vector2(0, 0.05))
	var d: Drivers.ScriptDriver = c.driver
	await seconds(0.6)  # the feet settle the last few cm onto the deck
	t("grab: unheld feet on the deck stick by themselves (you start standing)", c.limbs[2].grab.is_valid() and c.limbs[3].grab.is_valid())
	d.set_limb(2, true)  # press: pick the left foot up
	await frames(2)
	t("grab: pressing a stuck limb's button picks it up", not c.limbs[2].grab.is_valid())
	await seconds(0.5)
	t("grab: a held limb can't stick while held", not c.limbs[2].grab.is_valid())
	d.set_limb(2, false)
	await frames(4)
	t("grab: letting go over the deck plants it again", c.limbs[2].grab.is_valid())
	# A frozen climber is grabbable, and so is a live one.
	var f := spawn(Vector2(2.0, 0.05))
	await seconds(1.0)
	f.freeze()
	var e := spawn(Vector2(-2.0, 0.05))
	await seconds(1.0)
	var bar := bar_at(Vector2(0, 5))
	var h := spawn(Vector2(0, 3))
	move(bar, h.limb_end(0))
	h.attach(0, bar)
	h.attach(1, f.bodies["chest"])
	t("grab: a frozen climber can be held", h.limbs[1].grab.is_valid())
	h.attach(2, e.bodies["chest"])
	t("grab: a live rival can be held, and counts the grab", h.limbs[2].grab.is_valid() and e.grabbed_by == 1)
	e.release_all()
	await frames(1)
	t("grab: a held climber counts as attached (Parker's rule 10)", e.is_attached() and e.stuck_count() == 0)
	h.release(2)
	t("grab: releasing a rival un-counts it", e.grabbed_by == 0 and not e.is_attached())


func _run_frozen() -> void:
	ground()
	var c := spawn(Vector2(0, 2.0))
	await seconds(0.7)
	var p := c.pose()
	var top_live := c.top_height()
	c.freeze()
	await seconds(1.0)
	var drift := 0.0
	var p2 := c.pose()
	for i in p.size():
		drift = maxf(drift, absf(p[i] - p2[i]))
	t("frozen: a frozen body doesn't move at all", drift < 0.0001, "%.6f" % drift)
	t("frozen: height from the pose equals height from the body", absf(c.pose_top(p) - top_live) < 0.001, "%.4f vs %.4f" % [c.pose_top(p), top_live])
	t("frozen: every piece is static and on the tower layer", c.bodies["head"].freeze and c.bodies["head"].collision_layer == Climber.LAYER_FROZEN)
	var c2 := spawn(Vector2(5, 0.05))
	c2.apply_pose(p)
	c2.freeze()
	await frames(2)
	t("frozen: a pose applied elsewhere builds the same body (the network freeze)", absf(c2.top_height() - c.top_height()) < 0.0001)


# ================================================================ P3: --tower, --scramble

const GameScript := preload("res://game/game.gd")


func make_game(mode_id: String, n: int, timer: float) -> Game:
	var g: Game = GameScript.new()
	g.world = world
	g.dress = false
	add_child(g)
	var roster: Array = []
	for i in n:
		roster.append({"pid": i, "name": "Bot %d" % i, "tint": Color.WHITE, "peer": 1, "slot": i})
		g.bot_drivers[i] = Drivers.ScriptDriver.new()
	g.host_start({"mode": mode_id, "timer": timer, "spawn": "alternate", "stage": "dock"}, roster)
	return g


func wait_phase(g: Game, ph: String, max_s := 30.0) -> bool:
	var ticks := int(max_s * Engine.physics_ticks_per_second)
	for i in ticks:
		if g.phase == ph:
			return true
		await get_tree().physics_frame
	return false


## Lift a live climber so its feet sit `above` metres over the line, and press
## Lock In. (A rules test, not a climbing test: --climb does the climbing.)
func lift_and_lock(g: Game, pid: int, above := 0.4) -> Climber:
	var c: Climber = g.climbers[g.live[pid]]
	c.release_all()
	for l in c.limbs:
		l.regrip = 2.0  # stay loose in the air for the check
	var p := c.pose()
	var low := INF
	for i in range(1, p.size(), 3):
		low = minf(low, p[i])
	var dy := g.line + above - low + 0.2
	for i in range(1, p.size(), 3):
		p[i] += dy
	for i in range(0, p.size(), 3):
		p[i] = p[i] - c.spawn_at.x + 2.5 * signf(c.spawn_at.x)
	c.apply_pose(p)
	(g.bot_drivers[pid] as Drivers.ScriptDriver).lock = true
	await frames(3)
	return c


func _run_tower() -> void:
	var g := make_game("tower", 3, 3.0)
	var plan := {0: [true, true, true], 1: [true, false], 2: [false]}  # per pid, per turn: lock above?
	var turns := {0: 0, 1: 0, 2: 0}
	var line_before := 0.0
	var line_rose := true
	var order: Array = []
	for step in 8:
		if not await wait_phase(g, "turn", 10.0):
			break
		var pid: int = g.turn_order[g.turn_i]
		order.append(pid)
		var k: int = turns[pid]
		turns[pid] = k + 1
		line_before = g.line
		var ok: bool = plan[pid][k] if k < plan[pid].size() else true
		if ok:
			var c := await lift_and_lock(g, pid)
			t("tower: %s's lock-in froze them" % g.player_name(pid), c.state == Climber.State.FROZEN)
		if not await wait_phase(g, "between", 10.0):
			break
		if ok:
			line_rose = line_rose and g.tower_top() > line_before
		if g.phase == "over" or g.alive_pids().size() <= 1:
			break
		await wait_phase(g, "turn", 5.0)
	await wait_phase(g, "over", 8.0)
	t("tower: turns go in order and skip the out (0 1 2 0 1)", order.slice(0, 5) == [0, 1, 2, 0, 1], order)
	t("tower: the top rises with every lock-in", line_rose)
	t("tower: the timed-out climbers are out", not g.alive[2] and not g.alive[1])
	t("tower: the last one in wins", g.phase == "over" and int(g.results.get("winner", -1)) == 0, g.results)
	t("tower: failed climbers stay in the tower (Parker's rule 2)", g.tower.size() == 5, g.tower.size())
	g.end_match()
	g.queue_free()


func _run_scramble() -> void:
	var g := make_game("scramble", 4, 4.0)
	# Round 1: 0, 1, 2 lock in (each raising the line); 3 never does -> out at the clock.
	t("scramble: round 1 starts", await wait_phase(g, "round", 6.0))
	await frames(10)
	t("scramble: everyone still in is live at once", g.live_climbers().size() == 4, g.live_climbers().size())
	var line0 := g.line
	var lines: Array = [line0]
	for pid in [0, 1, 2]:
		await lift_and_lock(g, pid, 0.4 + pid * 0.3)
		lines.append(g.line)
	var rising := true
	for i in range(1, lines.size()):
		rising = rising and lines[i] > lines[i - 1]
	t("scramble: every lock-in above the line raises it", rising, lines)
	var c3: Climber = g.climbers[g.live[3]]
	await lift_and_lock(g, 3, -3.0)  # head still under the line: refused
	t("scramble: a lock-in under the line is refused", c3.state != Climber.State.FROZEN)
	await wait_phase(g, "between", 8.0)
	t("scramble: whoever didn't lock in by the clock is out", not g.alive[3] and g.alive[0] and g.alive[1] and g.alive[2])
	var r1_max := g.line
	# Round 2: all three lock in -> the round ends early.
	t("scramble: round 2 starts", await wait_phase(g, "round", 6.0))
	await frames(10)
	t("scramble: round 2 starts at round 1's max height", absf(g.line - r1_max) < 0.001, "%.3f vs %.3f" % [g.line, r1_max])
	for pid in [2, 0]:
		await lift_and_lock(g, pid, 0.4)
	var clock_left := g.clock
	await lift_and_lock(g, 1, 0.4)
	t("scramble: the round ends as soon as everyone still in has locked in", g.phase == "between" and clock_left > 1.0, "phase %s, clock was %.2f" % [g.phase, clock_left])
	# Round 3: only 0 locks in -> 1 and 2 are out -> 0 wins.
	await wait_phase(g, "round", 6.0)
	await frames(10)
	await lift_and_lock(g, 0, 0.4)
	await wait_phase(g, "over", 10.0)
	t("scramble: the last one in wins", int(g.results.get("winner", -1)) == 0, g.results)
	g.end_match()
	g.queue_free()


# ================================================================ P2: --climb

## The reference game's limb rule on the barrel: stand against it, pick a hand up
## and press it onto the side above shoulder height, let go (it sticks); pick a foot
## up and plant it on the side too. Three limbs stuck, two of them on the barrel,
## and the body hasn't fallen. (Gaining height is swinging and flinging, which the
## fling test covers; this is the reach-and-stick part a climber does all match.)
func _run_climb() -> void:
	var st := Stage.new("dock")
	st.build(world, false)
	var bx := st.barrel_half
	var c := spawn(Vector2(bx + 1.1, 0.05))
	var d: Drivers.ScriptDriver = c.driver
	await seconds(0.7)
	c.release_all()
	var p := c.pose()
	for k in range(0, p.size(), 3):
		p[k] -= 0.85  # stand against the barrel
	c.apply_pose(p)
	await seconds(0.5)
	var y0 := c.centre_of_mass().y
	var log := ["standing at x %.2f: feet stuck %s %s, near hand stuck %s" % [c.centre_of_mass().x, c.limbs[2].grab.is_valid(), c.limbs[3].grab.is_valid(), c.limbs[0].grab.is_valid()]]
	d.point_limb(0, true, Vector2(bx + 0.12, 1.75))  # pick the near hand up: lift it clear of the side first
	await seconds(0.8)
	d.point_limb(0, true, Vector2(bx - 0.03, 1.75))  # then press it onto the side, high
	await seconds(0.4)
	log.append("hand reaching: end at %s" % c.limb_end(0))
	d.set_limb(0, false)
	await frames(8)
	var hand_on: bool = c.limbs[0].grab.is_valid() and c.limbs[0].grab_other != null and c.limbs[0].grab_other.has_meta("stage")
	log.append("hand stuck on the barrel: %s" % hand_on)
	d.point_limb(2, true, Vector2(bx + 0.12, 0.7))  # near foot up, clear of the side
	await seconds(0.7)
	d.point_limb(2, true, Vector2(bx - 0.03, 0.7))  # then onto it
	await seconds(0.4)
	d.set_limb(2, false)
	await frames(8)
	var foot_on: bool = c.limbs[2].grab.is_valid()
	log.append("near foot stuck: %s at %s" % [foot_on, c.limb_end(2)])
	await seconds(0.5)
	var y1 := c.centre_of_mass().y
	log.append("COM %.2f -> %.2f, stuck %d" % [y0, y1, c.stuck_count()])
	for l in log:
		print("      ", l)
	t("climb: the near hand, lifted and pressed on the barrel, sticks when let go", hand_on)
	t("climb: the near foot plants on the barrel too", foot_on)
	t("climb: three limbs stuck and the body still up (COM within 0.3 m of standing)", c.stuck_count() >= 3 and y1 > y0 - 0.3, "%.2f m, %d stuck" % [y1 - y0, c.stuck_count()])


# ================================================================ P5: --net (two machines, one process)

## A host and a client over real ENet loopback, each with its own multiplayer
## branch and its own physics world (a SubViewport), playing Scramble.
func _run_net() -> void:
	var port := 7790 + randi() % 50
	var machines := []
	for nm in ["A", "B"]:
		var holder := Node.new()
		holder.name = nm
		add_child(holder)
		var vp := SubViewport.new()
		vp.own_world_3d = true
		vp.size = Vector2i(64, 64)
		vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
		holder.add_child(vp)
		var w := Node3D.new()
		vp.add_child(w)
		var api := SceneMultiplayer.new()
		get_tree().set_multiplayer(api, holder.get_path())
		var g: Game = GameScript.new()
		g.name = "Game"
		g.world = w
		g.dress = false
		holder.add_child(g)
		machines.append({"holder": holder, "api": api, "game": g, "world": w})
	var host_peer := ENetMultiplayerPeer.new()
	t("net: the host opens a port", host_peer.create_server(port, 4) == OK)
	machines[0].api.multiplayer_peer = host_peer
	var client_peer := ENetMultiplayerPeer.new()
	client_peer.create_client("127.0.0.1", port)
	machines[1].api.multiplayer_peer = client_peer
	for i in 240:
		await get_tree().process_frame
		if machines[1].api.get_unique_id() > 1 and machines[0].api.get_peers().size() == 1:
			break
	var cid_peer: int = machines[1].api.get_unique_id()
	t("net: the client connects", machines[0].api.get_peers().size() == 1, cid_peer)
	var A: Game = machines[0].game
	var B: Game = machines[1].game
	A.bot_drivers[0] = Drivers.ScriptDriver.new()
	B.bot_drivers[1] = Drivers.ScriptDriver.new()
	var roster := [{"pid": 0, "name": "Host bot", "tint": Color.RED, "peer": 1, "slot": 0},
		{"pid": 1, "name": "Client bot", "tint": Color.BLUE, "peer": cid_peer, "slot": 0}]
	A.host_start({"mode": "scramble", "timer": 6.0, "spawn": "alternate", "stage": "dock"}, roster)
	await wait_phase(A, "round", 6.0)
	await wait_phase(B, "round", 3.0)
	await frames(30)
	t("net: both machines start the round", A.phase == "round" and B.phase == "round", "%s %s" % [A.phase, B.phase])
	var a0: Climber = A.climbers.get(A.live.get(0, -1))
	var a1: Climber = A.climbers.get(A.live.get(1, -1))
	var b0: Climber = B.climbers.get(B.live.get(0, -1))
	var b1: Climber = B.climbers.get(B.live.get(1, -1))
	t("net: each machine owns its own climber and puppets the other",
		a0 != null and b1 != null and a0.state == Climber.State.LIVE and b1.state == Climber.State.LIVE
		and a1.state == Climber.State.PUPPET and b0.state == Climber.State.PUPPET)
	# The stream: the client's puppet follows the host's real body.
	await seconds(1.0)
	var lag := a0.centre_of_mass().distance_to(b0.centre_of_mass())
	t("net: the puppet follows the real body (within 25 cm at rest)", lag < 0.25, "%.3f m" % lag)
	# Grab across machines: the client's hand holds the host climber's puppet.
	b1.attach(0, b0.bodies["chest"])
	await seconds(0.5)
	t("net: the host's climber learns it's held (counts as attached)", a0.remote_grabbed == 1 and a0.is_attached(), a0.remote_grabbed)
	t("net: the holder's pull arrives on the held climber's machine", not a0.remote_pulls.is_empty(), a0.remote_pulls)
	b1.release(0)
	await seconds(0.4)
	t("net: releasing un-counts it on the other machine", a0.remote_grabbed == 0)
	# The client locks in above the line: the host decides, both freeze it the same.
	var line_before := A.line
	await lift_and_lock(B, 1, 0.5)
	await seconds(0.5)
	t("net: the client's lock-in froze it on both machines", b1.state == Climber.State.FROZEN and a1.state == Climber.State.FROZEN)
	t("net: the line rose on both machines", A.line > line_before and absf(A.line - B.line) < 0.0001, "%.3f %.3f" % [A.line, B.line])
	t("net: the frozen body is identical on both machines", _pose_diff(a1.pose(), b1.pose()) < 0.0001, "%.6f" % _pose_diff(a1.pose(), b1.pose()))
	# The host's climber runs out the clock: frozen and out, identical on both.
	await wait_phase(A, "over", 10.0)
	await seconds(0.5)
	t("net: the timed-out climber is frozen on both machines", a0.state == Climber.State.FROZEN and b0.state == Climber.State.FROZEN)
	t("net: its frozen body matches across machines", _pose_diff(a0.pose(), b0.pose()) < 0.0001, "%.6f" % _pose_diff(a0.pose(), b0.pose()))
	t("net: both machines agree on the winner (the client)", int(A.results.get("winner", -1)) == 1 and int(B.results.get("winner", -1)) == 1, "%s / %s" % [A.results.get("winner"), B.results.get("winner")])
	A.end_match()
	B.end_match()
	host_peer.close()
	client_peer.close()
	for m in machines:
		m.holder.queue_free()


func _pose_diff(a: PackedFloat32Array, b: PackedFloat32Array) -> float:
	var d := 0.0
	for i in mini(a.size(), b.size()):
		d = maxf(d, absf(a[i] - b[i]))
	return d


# ================================================================ P4: --devices

## Four fake pads drive four players with no crosstalk; the triggers share one
## press point; the keyboard player is its own device.
func _run_devices() -> void:
	Players.clear_players()
	Players.fake.clear()
	for k in 4:
		Players.fake[1000 + k] = {"buttons": {}, "stick": Vector2.ZERO}
	for k in 4:
		t("devices: pad %d joins as player %d" % [k, k], Players.add_player(1000 + k) == k)
	t("devices: a pad can't join twice", Players.add_player(1000) == -1)
	Players.fake[1002].buttons = {"arm_r": true}
	Players.fake[1002].stick = Vector2(0.9, 0.1)
	var crosstalk := false
	for s in 4:
		for limb in 4:
			var want := s == 2 and limb == 1
			if Players.limb_held(s, limb) != want:
				crosstalk = true
	t("devices: one pad's button moves only its own player's limb", not crosstalk)
	var aim = Players.limb_aim(2, null, 1)
	t("devices: that pad's stick aims only its own player", aim != null and Players.limb_aim(0, null, 1) == null)
	await frames(2)
	Players.lock_pressed(1)  # drain anything from before
	Players.fake[1001].buttons = {"lock": true}
	await frames(2)
	t("devices: Lock In is an edge (one press, one lock)", Players.lock_pressed(1) and not Players.lock_pressed(1))
	t("devices: the keyboard is its own device", Players.slot_of_device(Players.KBM) == -1)
	Players.fake.clear()
	Players.clear_players()


# ================================================================ --bend

## The reference game's bendy limbs: hang by one hand and steer the other hand in a
## circle that passes close to the shoulder (the elbow must fold to follow it), and
## swing a leg's foot the same way (the knee must fold). Free limbs flop both ways.
func _run_bend() -> void:
	var c := spawn(Vector2(0, 3.0))
	var bar := bar_at(c.limb_end(1))
	c.attach(1, bar)
	var d: Drivers.ScriptDriver = c.driver
	await seconds(1.0)
	var lo := {"elbow_l": INF, "knee_l": INF, "knee_r": INF}
	var hi := {"elbow_l": -INF, "knee_l": -INF, "knee_r": -INF}
	for i in int(5.0 * Engine.physics_ticks_per_second):
		var ang := float(i) / Engine.physics_ticks_per_second * TAU * 0.5
		var S := c.limb_root(0)
		var H := c.limb_root(2)
		d.point_limb(0, true, S + Vector2(0.15, 0.0) + Vector2.from_angle(ang) * 0.42)
		d.point_limb(2, true, H + Vector2(-0.1, -0.2) + Vector2.from_angle(-ang) * 0.45)
		await get_tree().physics_frame
		for jn in lo:
			var j: Dictionary = c.joints[jn]
			var rel := rad_to_deg(wrapf(Climber.angle_of(j.b) - Climber.angle_of(j.a), -PI, PI))
			lo[jn] = minf(lo[jn], rel)
			hi[jn] = maxf(hi[jn], rel)
	t("bend: a steered elbow folds to follow the hand (past 60 deg)", maxf(absf(lo.elbow_l), absf(hi.elbow_l)) > 60.0, "%.0f .. %.0f deg" % [lo.elbow_l, hi.elbow_l])
	t("bend: a steered knee folds to follow the foot (past 60 deg)", maxf(absf(lo.knee_l), absf(hi.knee_l)) > 60.0, "%.0f .. %.0f deg" % [lo.knee_l, hi.knee_l])
	# A pad: the stick moves the hand, and a resting stick leaves it there.
	var start := c.limb_end(0)
	d.set_limb(2, false)
	d.point_limb(0, true, c.limb_root(0) + Vector2(-0.15, -0.35))  # hand low and inside its reach
	await seconds(0.8)
	d.set_limb(0, true, Vector2.ZERO)  # pick up the stick there
	await seconds(0.3)
	var rest_hand := c.limb_end(0)
	d.set_limb(0, true, Vector2(0, 1), 1.0)  # stick UP in our y-up world (Godot's Vector2.UP is y-down)
	await seconds(0.25)
	d.set_limb(0, true, Vector2.ZERO)
	await seconds(0.4)
	var moved := c.limb_end(0) - rest_hand
	t("bend: a pushed stick moves the hand that way, a resting stick holds it", moved.y > 0.15, "moved %s (from %s)" % [moved, start])


# ================================================================ --feel (the reference game, as played)

## Each check is something watched in the reference game on 2026-11-07: hold a limb
## and its hand jumps to the cursor, the arm straightens toward it and the body
## leans after it; out of reach the body leans hard but the feet hold; let go and
## the arm keeps its pose; a foot does the same; loose in the air nothing pulls.
func _run_feel() -> void:
	ground()
	var c := spawn(Vector2(0, 0.05))
	var d: Drivers.ScriptDriver = c.driver
	await seconds(1.0)
	var head := c.piece_top("head")
	t("feel: you spawn standing, both feet stuck", head > 1.5 and c.limbs[2].grab.is_valid() and c.limbs[3].grab.is_valid(), "head top %.2f" % head)
	# 1. Hold the left hand with the cursor up and out to the side, within reach.
	var S := c.limb_root(0)
	var reach: float = c.limbs[0].l1 + c.limbs[0].l2
	var goal := S + Vector2(-0.45, 0.35)
	d.point_limb(0, true, goal)
	await seconds(0.6)
	var miss := c.limb_end(0).distance_to(goal)
	t("feel: a held hand jumps to the cursor (within 12 cm in 0.6 s)", miss < 0.12, "%.3f m off" % miss)
	t("feel: the feet stay stuck while you reach", c.limbs[2].grab.is_valid() and c.limbs[3].grab.is_valid())
	# 2. Out of reach: the body leans after the hand, the feet hold, nothing flies.
	var com0 := c.centre_of_mass()
	d.point_limb(0, true, S + Vector2(-2.5, 1.5))
	await seconds(1.0)
	var lean := com0.x - c.centre_of_mass().x
	t("feel: out of reach, the body leans after the hand (COM 10 cm or more toward it)", lean > 0.10, "%.2f m" % lean)
	t("feel: out of reach, the feet still hold (no flying)", c.limbs[2].grab.is_valid() and c.limbs[3].grab.is_valid())
	# 3. Let go: the arm keeps its pose.
	var hand_rel := c.limb_end(0) - c.limb_root(0)
	d.set_limb(0, false)
	await seconds(1.0)
	var drift := (c.limb_end(0) - c.limb_root(0)).distance_to(hand_rel)
	t("feel: let go, and the arm holds its new pose (hand drifts under 25 cm)", drift < 0.25, "%.3f m" % drift)
	t("feel: after the big lean the body is still up (head top over 1.3 m)", c.piece_top("head") > 1.3, "%.2f" % c.piece_top("head"))
	# 4. A foot, on a fresh climber: lifts off and follows the cursor; the other foot stays.
	d.clear()
	c = spawn(Vector2(-3.0, 0.05))
	d = c.driver
	await seconds(1.0)
	var H := c.limb_root(2)
	var fgoal := H + Vector2(-0.6, -0.35)
	d.point_limb(2, true, fgoal)
	await seconds(0.8)
	t("feel: a held foot lifts off and follows the cursor (within 20 cm)", c.limb_end(2).distance_to(fgoal) < 0.20 and not c.limbs[2].grab.is_valid(), "%.3f m off" % c.limb_end(2).distance_to(fgoal))
	t("feel: the other foot stays stuck", c.limbs[3].grab.is_valid())
	var lo := INF
	var hi := -INF
	for k in 120:
		var j: Dictionary = c.joints["knee_r"]
		var rel := rad_to_deg(wrapf(Climber.angle_of(j.b) - Climber.angle_of(j.a), -PI, PI))
		lo = minf(lo, rel)
		hi = maxf(hi, rel)
		await get_tree().physics_frame
	t("feel: the standing knee buckles sideways under the lean (past 10 deg)", maxf(absf(lo), absf(hi)) > 10.0, "%.0f .. %.0f deg" % [lo, hi])
	d.clear()
	await seconds(0.5)
	# 5. Loose in the air, a held limb isn't pulled anywhere.
	var air := spawn(Vector2(4.0, 6.0))
	var ad: Drivers.ScriptDriver = air.driver
	await frames(2)
	var before := air.limb_end(0) - air.limb_root(0)
	ad.point_limb(0, true, air.limb_root(0) + Vector2(-0.6, 0.6))
	await seconds(0.3)
	var moved := (air.limb_end(0) - air.limb_root(0)).distance_to(before)
	t("feel: loose in the air, a held limb isn't pulled (under 10 cm)", moved < 0.10 and not air.is_attached(), "%.3f m" % moved)
