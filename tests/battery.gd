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
	Game.grow_spawns = false  # batteries pose climbers the instant they spawn (--grow tests it)
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
	t("limits: joint overshoot stays under 8 deg during a loaded hang", worst < 8.0, "worst %.1f deg" % worst)
	await frames(240)
	t("limits: spine and neck back inside their limits once let go", c.worst_limit_excess() < 1.0, "%.2f deg" % c.worst_limit_excess())


func _spike_hang() -> void:
	var c := spawn(Vector2(1.0, 2.0))
	var bar := bar_at(c.limb_end(0))
	c.attach(0, bar)
	var worst := 0.0
	var worst_at := 0
	var late := 0.0  # the last 20 s: after the drop from the spawn pose has settled
	for i in int(30.0 * Engine.physics_ticks_per_second):
		await get_tree().physics_frame
		var g := c.worst_joint_gap()
		if g > worst:
			worst = g
			worst_at = i
		if i > 10 * Engine.physics_ticks_per_second:
			late = maxf(late, g)
	t("hang: 30 s by one hand, joints stay under 2 cm", worst < 0.02, "worst %.4f m (%s) at tick %d, last 20 s %.4f m" % [worst, c.last_worst_gap_joint, worst_at, late])
	t("hang: the hand is still stuck", (c.limbs[0].grab_other != null))
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
	t("fling: joint limits hold under hard drags (under 40 deg over)", worst_lim < 40.0, "worst %.1f deg" % worst_lim)
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
	t("limp: an unheld hand touching a bar sticks by itself", (c.limbs[1].grab_other != null))
	await frames(1)
	t("limp: simultaneous presses select exactly one limb", c.limbs[0].driving and not c.limbs[2].held and not c.limbs[3].held)
	d.set_limb(2, false)
	await frames(2)
	d.set_limb(2, true)
	await frames(2)
	t("limp: a new press takes over and preserves the passive grip", c.limbs[2].driving and not c.limbs[0].held and (c.limbs[1].grab_other != null))
	var next_bar := bar_at(c.limb_end(0))
	await frames(4)
	t("limp: the deselected hand catches on contact despite its button staying down", c.limbs[0].grab_other == next_bar)
	d.set_limb(2, false)
	await frames(2)
	t("limp: releasing the selection hands control back to the older hand still held (the press stack)", c.limbs[0].held and not (c.limbs[0].grab_other != null) and c.active_limb() == 0)
	next_bar.queue_free()
	d.set_limb(0, false)  # let go of the other buttons: only the stuck hand's press is new
	d.set_limb(3, false)
	await frames(2)  # the bar is gone before anything can catch it again
	c.release(0)
	d.set_limb(1, true, Vector2.UP, 1.0)
	await frames(2)
	t("limp: picking up the last stuck limb drops you (nothing drives)", not (c.limbs[1].grab_other != null) and not c.is_attached())


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
		c.grab_made.connect(func(gc, gl, o):
			if o is RigidBody3D and o.has_meta("climber") and gc.limbs[gl].held:
				rival_grabs[0] += 1)  # a LOOSE limb taking a live climber (held ones may)
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
	t("eight live: steered limbs never stick to live players", rival_grabs[0] == 0, rival_grabs[0])
	t("eight live: physics frame under 6 ms on average (eight welded climbers)", avg < 6.0, "avg %.3f ms, worst %.3f ms" % [avg, worst_ms])


## A hangs from B, B from C, C from a bar. C freezes: nobody drops.
func _spike_chain() -> void:
	var cC := spawn(Vector2(0, 7.0))
	var bar := bar_at(cC.limb_end(0))
	# Measure the built pose before it swings. The model's stored hand is in a T-pose.
	var hand_off := cC.limb_end(0) - cC.spawn_at
	cC.attach(0, bar)
	await seconds(2.0)
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
	t("chain: after C freezes, B and A still hold on", (cB.limbs[0].grab_other != null) and (cA.limbs[0].grab_other != null))
	t("chain: B's hand stays on C's frozen foot (under 6 cm)", worst_slip < 0.06, "%.4f m" % worst_slip)
	t("chain: joints hold through the freeze (under 13 cm, two stiff climbers on one wrist)", worst_gap < 0.13, "%.4f m" % worst_gap)
	t("chain: B still counts as attached (A holds it, it holds C)", cB.is_attached())


# ================================================================ P2: --grab, --frozen

func _run_exertion() -> void:
	var c := spawn(Vector2(0, 4))
	var d: Drivers.ScriptDriver = c.driver
	var chest: RigidBody3D = c.bodies["chest"]
	c.attach(0, bar_at(c.limb_end(0)))
	var events := [0]
	c.exerted.connect(func(): events[0] += 1)
	chest.linear_velocity.y = 5.1
	d.set_limb(3, true, Vector2(0, 1), 1.0)  # Climber input is y-up.
	c._physics_process(0.01)
	t("grunt: two-second opening delay", events[0] == 0 and c._grunt_wait > 1.9)
	c._grunt_wait = -1.0
	d.set_limb(3, false)
	c._physics_process(0.01)
	t("grunt: rising while gripping without steering stays quiet", events[0] == 0)
	d.set_limb(3, true, Vector2(0, 1), 0.5)
	c._physics_process(0.01)
	t("grunt: half input stays quiet", events[0] == 0)
	d.set_limb(3, true, Vector2(0, 1), 1.0)
	chest.linear_velocity.y = 5.0
	c._physics_process(0.01)
	t("grunt: speed threshold is strict", events[0] == 0)
	chest.linear_velocity.y = 5.1
	c._physics_process(0.01)
	t("grunt: rising pull fires once and rolls a 1.5 to 3.5 second cooldown", events[0] == 1 and c._grunt_wait >= 1.5 and c._grunt_wait <= 3.5)
	c._physics_process(0.01)
	t("grunt: continuous pulling respects cooldown", events[0] == 1)
	c._grunt_wait = -1.0
	c.release_all()
	c.remote_grabbed = 1
	c._physics_process(0.01)
	t("grunt: another player's grip alone does not count", events[0] == 1)
	c.attach(0, bar_at(c.limb_end(0)))
	d.point_limb(3, true, c.limb_root(3) + Vector2(0, 2))
	c._physics_process(0.01)
	t("grunt: mouse aim uses upward reach", events[0] == 2)


func _run_grab() -> void:
	ground()
	var c := spawn(Vector2(0, 0.05))
	var d: Drivers.ScriptDriver = c.driver
	await seconds(0.6)  # the feet settle the last few cm onto the deck
	t("grab: unheld feet on the deck stick by themselves (you start standing)", (c.limbs[2].grab_other != null) and (c.limbs[3].grab_other != null))
	d.set_limb(2, true)  # press: pick the left foot up
	await frames(2)
	t("grab: pressing a stuck limb's button picks it up", not (c.limbs[2].grab_other != null))
	await seconds(0.5)
	t("grab: a held limb can't stick while held", not (c.limbs[2].grab_other != null))
	d.set_limb(2, false)
	await frames(4)
	t("grab: letting go over the deck plants it again", (c.limbs[2].grab_other != null))
	# THE SLAP on every catch, held or not (Parker 11-08): a climber dropped from the
	# air, holding nothing, slaps when its limbs catch the deck.
	var sl := spawn(Vector2(-6.0, 2.5))
	var slaps := [0]
	sl.release_contact.connect(func(_at): slaps[0] += 1)
	await seconds(2.0)
	t("grab: a loose limb catching the deck slaps (no button held)", slaps[0] > 0 and sl.stuck_count() > 0, "%d slaps, %d stuck" % [slaps[0], sl.stuck_count()])
	sl.remove()
	# THE PRESS STACK (Parker 11-08): hold A (right hand), press X (left hand): X
	# rules. Let go of X with A still held: A rules again.
	d.set_limb(1, true)
	await frames(2)
	var a_first: bool = c.active_limb() == 1
	d.set_limb(0, true)
	await frames(2)
	var x_takes: bool = c.active_limb() == 0 and c.limbs[0].held and not c.limbs[1].held
	d.set_limb(0, false)
	await frames(2)
	var a_back: bool = c.active_limb() == 1 and c.limbs[1].held
	d.set_limb(1, false)
	await frames(2)
	t("grab: the press stack (hold A, press X: X rules; let go of X: A rules again)", a_first and x_takes and a_back and c.active_limb() == -1, "A %s, X takes %s, A back %s, none after %s" % [a_first, x_takes, a_back, c.active_limb() == -1])
	await seconds(0.5)
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
	t("grab: a frozen climber can be held", (h.limbs[1].grab_other != null))
	h.attach(2, e.bodies["chest"])
	t("grab: a live rival can be held, and counts the grab", (h.limbs[2].grab_other != null) and e.grabbed_by == 1)
	e.release_all()
	await frames(1)
	t("grab: a held climber counts as attached (Parker's rule 10)", e.is_attached() and e.stuck_count() == 0)
	h.release(2)
	t("grab: releasing a rival un-counts it", e.grabbed_by == 0 and e.held_by.is_empty())  # (it still stands on the deck: touching solid counts, 11-08)
	# The practice partner is a live climber too (Parker 11-08: "You should be able
	# to grab him"): a hand that touches him sticks, and he counts the grab.
	var pp: Climber = load("res://climber/practice_partner.gd").new()
	pp.climber_id = _next_id
	_next_id += 1
	add_child(pp)
	pp.build(Vector2(6.0, 3.0), world, null)
	var g2 := spawn(Vector2(6.0, 5.5))
	g2.attach(0, bar_at(g2.limb_end(0)))
	await frames(2)
	g2.attach(1, pp.bodies["chest"])
	t("grab: the practice partner can be grabbed (and counts it)", (g2.limbs[1].grab_other != null) and g2.limbs[1].grab_climber == pp and pp.grabbed_by == 1)
	g2.release_all()
	pp.remove()
	# Start with the hand held away, then allow it to plant on the other player.
	var x1 := spawn(Vector2(10, 6))
	var x2 := spawn(Vector2(10, 6))
	var xd: Drivers.ScriptDriver = x1.driver
	xd.set_limb(0, true)
	await frames(3)
	t("player contact: the steered hand does not grab", x1.limbs[0].grab_other == null)
	xd.set_limb(0, false)
	await frames(2)
	t("player contact: releasing on a live body plants the hand", x1.limbs[0].grab_climber == x2)
	t("player contact: an airborne pair cannot power locomotion", not x1.is_attached() and not x2.is_attached())
	xd.set_limb(0, true)
	await frames(2)
	t("player contact: pressing the limb lifts it off again", x1.limbs[0].grab_other == null)
	x1.remove()
	x2.remove()


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


func make_game(mode_id: String, n: int, timer: float, arena := "dock", draw := false) -> Game:
	var g: Game = GameScript.new()
	g.world = world
	g.dress = draw
	add_child(g)
	var roster: Array = []
	for i in n:
		roster.append({"pid": i, "name": "Bot %d" % i, "tint": Color.WHITE, "peer": 1, "slot": i})
		g.bot_drivers[i] = Drivers.ScriptDriver.new()
	# Always the barrel: lift_and_lock stands a climber on the base's top at x = 0, which
	# only the barrel has (a random donkey left it in the air and the lock was refused).
	g.host_start({"mode": mode_id, "timer": timer, "spawn": "alternate", "stage": arena, "base": "barrel", "practice_npc": mode_id == "practice", "practice_mode": "tower"}, roster)
	return g


func wait_phase(g: Game, ph: String, max_s := 30.0) -> bool:
	var ticks := int(max_s * Engine.physics_ticks_per_second)
	for i in ticks:
		if g.phase == ph:
			return true
		await get_tree().physics_frame
	return false


## Put the lowest piece onto the barrel or the topmost frozen piece, matching
## the geometry on every peer. The "airborne" variant is well clear of the stack.
func lift_and_lock(g: Game, pid: int, above := 0.4, airborne := false, request_lock := true) -> Climber:
	var c: Climber = g.climbers[g.live[pid]]
	c.release_all()
	for l in c.limbs:
		l.regrip = 2.0
	var p := c.pose()
	var support := Vector2(0.0, g.stage.barrel_top)
	for cid in g.tower:
		var frozen: Climber = g.climbers[cid]
		for piece in Layout.ORDER:
			var y := frozen.piece_top(piece)
			if y > support.y:
				support = Vector2(Climber.pos2(frozen.bodies[piece]).x, y)
	var bottom := Vector2(0.0, INF)
	for i in Layout.ORDER.size():
		var k := 3 * i
		var y := -c.top_of(Layout.ORDER[i], Transform2D(p[k + 2] + PI, Vector2(0, -p[k + 1])))
		if y < bottom.y:
			bottom = Vector2(p[k], y)
	if airborne:
		support = Vector2(6.0, g.line + 2.0)
	elif above < 0:
		support = Vector2(-6.0, 0.0)
	var offset := support - bottom - Vector2(0, 0.008)
	for k in range(0, p.size(), 3):
		p[k] += offset.x
		p[k + 1] += offset.y
	c.apply_pose(p)
	(g.bot_drivers[pid] as Drivers.ScriptDriver).lock = request_lock
	if request_lock:
		await frames(3)
	return c


func _run_groundlock() -> void:
	for id in ["tower", "scramble", "practice"]:
		var g := make_game(id, 2 if id == "scramble" else 1, 50.0)
		await wait_phase(g, "round" if id == "scramble" else "turn")
		var c := await lift_and_lock(g, 0, 0.4, true)
		t("%s: an above-line airborne lock is refused" % id, c.state == Climber.State.LIVE and g.tower.is_empty() and g.best[0] == 0.0)
		# WELDED COUNTS (Parker 11-09): a hand welded to the barrel locks in even when
		# the pose itself sits off the barrel (a strained weld hangs a little away).
		var w := await lift_and_lock(g, 0, 0.4, true, false)
		w.attach(0, g.stage.base_bodies[0])
		(g.bot_drivers[0] as Drivers.ScriptDriver).lock = true
		await frames(3)
		t("%s: welded to the barrel (pose clear of it), the lock is accepted" % id, w.state == Climber.State.FROZEN and g.tower.size() == 1, [w.state, g.tower.size()])
		g.end_match()
		g.queue_free()
		await frames(2)
		g = make_game(id, 2 if id == "scramble" else 1, 50.0)
		await wait_phase(g, "round" if id == "scramble" else "turn")
		c = await lift_and_lock(g, 0)
		t("%s: contact with the barrel accepts the lock" % id, c.state == Climber.State.FROZEN and g.tower.size() == 1)
		g.end_match()
		g.queue_free()
		await frames(2)
	for id in ["tower", "scramble"]:
		for airborne in [false, true]:
			var timed := make_game(id, 2 if id == "scramble" else 1, 50.0)
			var active := "round" if id == "scramble" else "turn"
			await wait_phase(timed, active)
			if id == "scramble":
				await lift_and_lock(timed, 1)
			var previous := timed.tower.size()
			await lift_and_lock(timed, 0, 0.4, airborne, false)
			timed._time_up()
			if airborne:
				t("%s timeout: airborne player stays live until supported" % id, timed.alive[0] and timed.best[0] == 0.0 and timed.tower.size() == previous and timed.phase == active)
				await lift_and_lock(timed, 0, 0.4, false, false)
				timed._time_up()
			t("%s timeout: supported above-line player automatically locks in (airborne=%s)" % [id, airborne], timed.alive[0] and timed.best[0] > 0.0 and timed.tower.size() == previous + 1 and timed.phase == "between", [timed.alive, timed.best, timed.tower, timed.phase])
			timed.end_match()
			timed.queue_free()
			await frames(2)

func _run_tower() -> void:
	var g := make_game("tower", 3, 3.0)
	t("tower: the first line is out of a standing reach (barrel top + FIRST_LINE_ABOVE)", absf(g.line - (g.stage.barrel_top + Stage.FIRST_LINE_ABOVE)) < 0.001 and g.tower_top() >= g.line - 0.001, "line %.2f, barrel %.2f" % [g.line, g.stage.barrel_top])
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
	for n in range(2, 21):
		var pairs := Modes.round_robin(range(n))
		var seen := {}
		var counts := {}
		for pair in pairs:
			seen[Vector2i(mini(pair[0], pair[1]), maxi(pair[0], pair[1]))] = true
			for pid in pair:
				counts[pid] = counts.get(pid, 0) + 1
		t("Classic: every pair appears once with %d players" % n, seen.size() == n * (n - 1) / 2 and pairs.size() == seen.size() and counts.values().all(func(c): return c == n - 1))
	t("Classic: exact three-player rotation", Modes.round_robin([0, 1, 2]) == [[0, 1], [1, 2], [2, 0]])
	t("Classic: default mode and twenty-player limits (Parker 11-10)", Modes.default_settings().mode == "scramble" and Modes.row("scramble").name == "Classic" and Net.MAX_CLIMBERS == 20 and Net.MAX_MACHINES == 20)
	var saved_members: Dictionary = Net.members.duplicate(true)
	Net.members = {1: {"players": [{}, {}, {}, {}]}, 2: {"players": [{}, {}, {}, {}]}, 3: {"players": [{}, {}, {}]}, 5: {"players": [{}, {}, {}, {}]}, 6: {"players": [{}, {}, {}, {}]}}
	t("lobby: twentieth player fits, twenty-first is refused", Net.can_fit_players(4, 1) and not Net.can_fit_players(4, 2))
	t("lobby: existing machine may fill but not exceed capacity", Net.can_fit_players(3, 4) and not Net.can_fit_players(3, 5))
	Net.members = saved_members
	var g := make_game("scramble", 3, 50.0)
	for expected in [[0, 1], [1, 2], [2, 0]]:
		t("Classic: next round starts", await wait_phase(g, "round", 5.0))
		t("Classic: only the scheduled pair spawns", g.round_players == expected and g.live_climbers().size() == 2 and g.live.size() == 2, g.round_players)
		var previous := g.tower.size()
		var before := g.line
		await lift_and_lock(g, expected[0])
		t("Classic: first lock raises the line and waits for opponent", g.line > before and g.phase == "round")
		await lift_and_lock(g, expected[1])
		t("Classic: both successes survive; spectators do not block round end", g.phase == "between" and g.alive_pids().size() == 3 and g.tower.size() == previous + 2)
	await wait_phase(g, "round", 5.0)
	t("Classic: surviving pairs repeat after a full rotation", g.round_players == [0, 1])
	await lift_and_lock(g, 0)
	await lift_and_lock(g, 1, -3.0, false, false)
	g._time_up()
	t("Classic: missing the line eliminates only that participant", not g.alive[1] and g.alive[0] and g.alive[2] and g.phase == "between")
	await wait_phase(g, "round", 5.0)
	t("Classic: eliminated opponents are skipped", g.round_players == [2, 0] and g.live.size() == 2)
	await lift_and_lock(g, 0)
	await lift_and_lock(g, 2, -3.0, false, false)
	g._time_up()
	await wait_phase(g, "over", 5.0)
	t("Classic: last survivor wins", int(g.results.get("winner", -1)) == 0)
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
	var log := ["standing at x %.2f: feet stuck %s %s, near hand stuck %s" % [c.centre_of_mass().x, (c.limbs[2].grab_other != null), (c.limbs[3].grab_other != null), (c.limbs[0].grab_other != null)]]
	d.point_limb(0, true, Vector2(bx + 0.25, 1.95))  # pick the near hand up: lift it clear of the side first
	await seconds(0.8)
	d.point_limb(0, true, Vector2(bx - 0.20, 1.95))  # then press it onto the side, high
	await seconds(0.4)
	log.append("hand reaching: end at %s" % c.limb_end(0))
	d.set_limb(0, false)
	await frames(8)
	var hand_on: bool = (c.limbs[0].grab_other != null) and c.limbs[0].grab_other != null and c.limbs[0].grab_other.has_meta("stage")
	log.append("hand stuck on the barrel: %s" % hand_on)
	d.point_limb(2, true, Vector2(bx + 0.12, 0.7))  # near foot up, clear of the side
	await seconds(0.7)
	d.point_limb(2, true, Vector2(bx - 0.03, 0.7))  # then onto it
	await seconds(0.4)
	d.set_limb(2, false)
	await frames(8)
	var foot_on: bool = (c.limbs[2].grab_other != null)
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
	for nm in ["A", "B", "Spectator"]:
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
	var spectator_peer := ENetMultiplayerPeer.new()
	spectator_peer.create_client("127.0.0.1", port)
	machines[2].api.multiplayer_peer = spectator_peer
	for i in 240:
		await get_tree().process_frame
		if machines[1].api.get_peers().size() == 2 and machines[2].api.get_peers().size() == 2:
			break
	var cid_peer: int = machines[1].api.get_unique_id()
	t("net: the client connects", machines[0].api.get_peers().size() == 2, cid_peer)
	var A: Game = machines[0].game
	var B: Game = machines[1].game
	A.bot_drivers[0] = Drivers.ScriptDriver.new()
	B.bot_drivers[1] = Drivers.ScriptDriver.new()
	var roster := [{"pid": 0, "name": "Host bot", "tint": Color.RED, "peer": 1, "slot": 0},
		{"pid": 1, "name": "Client bot", "tint": Color.BLUE, "peer": cid_peer, "slot": 0}]
	A.host_start({"mode": "scramble", "timer": 9.0, "spawn": "alternate", "stage": "plaza", "base": "barrel"}, roster)
	await wait_phase(A, "round", 6.0)
	await wait_phase(B, "round", 3.0)
	await frames(30)
	t("net: all peers use the host-selected starting base", machines.all(func(m): return m.game.stage.base_id == A.settings.resolved_base))
	t("net: actual spawn sides agree across all peers", machines.all(func(m): return m.game._last_spawn_sides == A._last_spawn_sides))
	t("net: all peers receive the same active pair", machines.all(func(m): return m.game.round_players == [0, 1]))
	t("net: both machines start the round", A.phase == "round" and B.phase == "round", "%s %s" % [A.phase, B.phase])
	var a0: Climber = A.climbers.get(A.live.get(0, -1))
	var a1: Climber = A.climbers.get(A.live.get(1, -1))
	var b0: Climber = B.climbers.get(B.live.get(0, -1))
	var b1: Climber = B.climbers.get(B.live.get(1, -1))
	t("net: each machine owns its own climber and puppets the other",
		a0 != null and b1 != null and a0.state == Climber.State.LIVE and b1.state == Climber.State.LIVE
		and a1.state == Climber.State.PUPPET and b0.state == Climber.State.PUPPET)
	# Every approved bell clip reaches host, client and spectator unchanged.
	var bell_audio: Array = []
	for m in machines:
		m.world.child_entered_tree.connect(func(node):
			if node is AudioStreamPlayer3D and node.stream.resource_path.get_file().get_basename() in Sound.SFX["church_bell"]:
				bell_audio.append([node.stream.resource_path.get_file().get_basename(), node.pitch_scale, node.attenuation_model]))
	t("net: all 13 approved bell clips are loaded", Sound.SFX["church_bell"].size() == 13 and Sound.SFX["church_bell"].all(func(clip): return Sound._streams.has(clip)))
	for clip in Sound.SFX["church_bell"]:
		bell_audio.clear()
		B._rpc_bell.rpc(b1.climber_id, b1.bodies["hand_r"].global_position, clip)
		await frames(4)
		t("net: bell clip reaches all peers without pitch or distance changes: " + clip, bell_audio.size() == 3 and bell_audio.all(func(row): return row[0] == clip and row[1] == 1.0 and row[2] == AudioStreamPlayer3D.ATTENUATION_DISABLED))
	bell_audio.clear()
	A.chair.bell_struck.emit(Vector3(0, 1.8, 0))
	await frames(4)
	t("net: chair bell strike reaches all three listeners with the same clip", bell_audio.size() == 3 and bell_audio.all(func(row): return row[0] == bell_audio[0][0]))
	A.chair.bell_struck.emit(Vector3(0, 1.8, 0))
	await frames(2)
	t("net: chair bell cooldown prevents contact chatter", bell_audio.size() == 3)
	var ko_audio: Array = []
	for m in machines:
		m.world.child_entered_tree.connect(func(node):
			if node is AudioStreamPlayer3D and node.stream.resource_path.get_file().get_basename() in Sound.SFX["knockout"]:
				ko_audio.append(node.stream.resource_path))
	B._rpc_exertion.rpc(b1.climber_id, Sound.SFX["strain"][0])
	await frames(2)
	var interrupted_grunts: Array = []
	for m in machines:
		var head: Node3D = m.game.climbers[b1.climber_id].bodies["head"]
		for child in head.get_children():
			if child is AudioStreamPlayer3D and child.has_meta("exertion_voice"):
				interrupted_grunts.append(child)
	t("net: grunts originate at all three heads", interrupted_grunts.size() == 3 and interrupted_grunts.all(func(v): return v.playing and v.position == Vector3.ZERO))
	b1.knock_out()
	await frames(4)
	t("net: knockout stars appear on host, owner and spectator", machines.all(func(m): return is_instance_valid(m.game.climbers[b1.climber_id].knockout_stars) and m.game.climbers[b1.climber_id].knockout_stars.visible))
	t("net: knockout interrupts every active grunt", interrupted_grunts.all(func(v): return not is_instance_valid(v) or not v.playing))
	B._rpc_exertion.rpc(b1.climber_id, Sound.SFX["strain"][0])
	await frames(2)
	var blocked := true
	for m in machines:
		for child in m.game.climbers[b1.climber_id].bodies["head"].get_children():
			if child is AudioStreamPlayer3D and child.has_meta("exertion_voice"):
				blocked = false
	t("net: no grunt restarts during knockout", blocked)
	t("net: knockout selects one approved whimper for every listener", ko_audio.size() == 3 and ko_audio.count(ko_audio[0]) == 3)
	b1.knock_out()
	await frames(2)
	t("net: already knocked-out player does not repeat whimper", ko_audio.size() == 3)
	await seconds(2.5)
	t("net: knockout stars disappear on every peer upon waking", machines.all(func(m): return not m.game.climbers[b1.climber_id].knockout_stars.visible))
	# A client makes a contact and holds RB. Both peers hear the same take.
	var grunts := []
	for m in machines:
		var climber: Climber = m.game.climbers[b1.climber_id]
		climber.bodies["head"].child_entered_tree.connect(func(node):
			if node is AudioStreamPlayer3D:
				grunts.append(node.stream.resource_path.get_file().get_basename()))
	b1.exerted.emit()
	await frames(8)
	t("net: all three peers play the same approved exertion take", grunts.size() == 3 and grunts.count(grunts[0]) == 3 and grunts[0] in Sound.SFX["strain"])
	var slaps := []
	for m in machines:
		m.world.child_entered_tree.connect(func(node):
			if node is AudioStreamPlayer3D:
				slaps.append(node.stream.resource_path))
	b1.release_contact.emit(b1.bodies["hand_r"].global_position)
	Players.fake[1099] = {"buttons": {"fart": true}}
	b1.local_slot = Players.add_player(1099)
	await frames(20)
	t("net: slap reaches all three machines once", slaps.size() == 3 and slaps.count(slaps[0]) == 3)
	var voices := []
	for m in machines:
		var copy: Climber = m.game.climbers[b1.climber_id]
		voices.append(copy.bodies["pelvis"].get_node("FartVoice"))
	var first = voices[0]
	t("net: RB starts the same looping take and pitch everywhere", first.active() and voices.all(func(v):
		return v.active() and v._take == first._take and v._body.pitch_scale == first._body.pitch_scale and v._body.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD))
	Players.fake[1099].buttons.fart = false
	await seconds(0.55)
	t("net: releasing RB clears the sustain and finishes the tail everywhere", voices.all(func(v): return not v.active() and v.get_child_count() == 0))
	# A partly refilled tank must cut off on the owner, host and spectator while RB stays down.
	B._fart_fuel[b1.player_id] = 0.25
	Players.fake[1099].buttons.fart = true
	await seconds(0.10)
	t("net: partial tank plays on every peer", voices.all(func(v): return v.active()))
	await seconds(0.30)
	t("net: tank exhaustion silences every peer until release", B._fart_fuel[b1.player_id] == 0.0 and voices.all(func(v): return not v.active() and v.get_child_count() == 0))
	Players.fake[1099].buttons.fart = false
	b1.local_slot = -1
	Players.fake.erase(1099)
	Players.clear_players()
	# Let the client pick up the host-owned chair using the normal limb selection.
	t("net: the arena chair exists on host and client without a practice NPC", A.chair != null and B.chair != null and A.partner == null and B.partner == null)
	var client_hand: RigidBody3D = a1.bodies["hand_l"]
	var host_standing_pose := a0.pose()
	var standing_pose := b1.pose()
	var setup_pose := standing_pose.duplicate()
	var offset := A.chair.global_position - client_hand.global_position
	for k in range(0, setup_pose.size(), 3):
		setup_pose[k] += offset.x
		setup_pose[k+1] += offset.y
	b1.release_all()
	b1.apply_pose(setup_pose)
	(B.bot_drivers[1] as Drivers.ScriptDriver).set_limb(0, true)
	await seconds(0.25)
	A.chair.set_hit_count(A.chair.dent_hits.y)
	await seconds(0.15)
	t("net: the chair wear count reaches client and spectator", B.chair.dent_hits == A.chair.dent_hits and B.chair.damage_stage() == 2 and machines[2].game.chair.damage_stage() == 2)
	t("net: the remote pickup is shared", A.chair.holder == b1.climber_id and B.chair.holder == b1.climber_id)
	(B.bot_drivers[1] as Drivers.ScriptDriver).set_limb(0, false)
	await seconds(0.25)
	t("net: remote release drops the same chair", A.chair.holder == -1 and B.chair.holder == -1)
	# Isolate the scripted character cues from a real terrain slam on landing.
	A.chair.float_above(Vector2(0, 8))
	var chair_sounds := []
	for m in machines:
		var heard := []
		chair_sounds.append(heard)
		m.world.child_entered_tree.connect(func(node):
			if node is AudioStreamPlayer3D:
				var clip: String = node.stream.resource_path.get_file().get_basename()
				if clip in Sound.SFX.chair_light or clip in Sound.SFX.chair_heavy or clip in Sound.SFX.chair_break:
					heard.append(clip))
	var test_hit := {"piece": "chest", "offset": Vector3.ZERO, "impulse": Vector3.RIGHT, "speed": A.chair.LIGHT_HIT_MAX_SPEED}
	for kind in ["chair_light", "chair_heavy", "chair_break"]:
		for heard in chair_sounds:
			heard.clear()
		if kind == "chair_heavy":
			test_hit.speed += 0.01
		elif kind == "chair_break":
			A.chair.set_hit_count(19)
		var before_hits := A.chair.hit_count
		A._apply_chair_hits({a1.climber_id: test_hit})
		await seconds(0.08)
		if kind != "chair_break":
			var expected := before_hits + int(kind == "chair_heavy")
			t("net: wear matches the slam at the sound boundary", A.chair.hit_count == expected and B.chair.hit_count == expected)
		var expected_cues := ["chair_heavy", "chair_break"] if kind == "chair_break" else [kind]
		for heard in chair_sounds:
			var correct: bool = heard == chair_sounds[0] and heard.size() == expected_cues.size()
			for cue in mini(heard.size(), expected_cues.size()):
				correct = correct and heard[cue] in Sound.SFX[expected_cues[cue]]
			t("net: synchronized chair cue sequence " + kind, correct, heard)
	await seconds(0.12)
	t("net: the final hit removes the chair for host, client and spectator", A.chair == null and B.chair == null and machines[2].game.chair == null)
	# The stream: the client's puppet follows the host's real body.
	await seconds(1.0)
	var lag := a0.centre_of_mass().distance_to(b0.centre_of_mass())
	t("net: the puppet follows the real body (within 25 cm at rest)", lag < 0.25, "%.3f m" % lag)
	# Put the player's left hand against the near side of the remote right hand.
	b1.release_all()
	var near_pose := b1.pose()
	var shift := b0.limb_end(1) + Vector2(0.10, 0) - b1.limb_end(0)
	for k in range(0, near_pose.size(), 3):
		near_pose[k] += shift.x
		near_pose[k + 1] += shift.y
	b1.apply_pose(near_pose)
	for l in b1.limbs:
		l.regrip = 1.2
	b1.attach(0, b0.bodies["hand_r"])
	await seconds(0.12)
	t("net: an owner receives the remote surface contact", a0.remote_grabbed >= 1 and b1.limbs[0].grab_climber == b0, a0.remote_grabbed)
	t("net: a load arrives for the touched body piece", a0.remote_pulls.values().any(func(v): return v.piece == "hand_r"), a0.remote_pulls)
	b1.release_all()
	for l in b1.limbs:
		l.regrip = 1.2
	await seconds(0.2)
	t("net: release clears the remote contact and load", a0.remote_grabbed == 0 and a0.remote_pulls.is_empty())
	# Reset the pose after the impact fixture so the lock check uses a standing
	# player tall enough to clear the line, regardless of their landing angle.
	b1.apply_pose(standing_pose)
	for body: RigidBody3D in b1.bodies.values():
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
	if b1.knockout_left > 0:
		await seconds(b1.knockout_left + 0.1)
	# The client locks in above the line: the host decides, both freeze it the same.
	await lift_and_lock(B, 1, 0.5, true)
	await seconds(0.3)
	t("net: host rejects airborne lock from a remote client", b1.state == Climber.State.LIVE and a1.state == Climber.State.PUPPET and A.tower.is_empty())
	var line_before := A.line
	await lift_and_lock(B, 1, 0.5)
	await seconds(0.5)
	t("net: the client's lock-in froze it on both machines", b1.state == Climber.State.FROZEN and a1.state == Climber.State.FROZEN)
	t("net: the line rose on both machines", A.line > line_before and absf(A.line - B.line) < 0.0001, "%.3f %.3f" % [A.line, B.line])
	t("net: the frozen body is identical on both machines", _pose_diff(a1.pose(), b1.pose()) < 0.0001, "%.6f" % _pose_diff(a1.pose(), b1.pose()))
	# Put the host back on its feet after the contact-load fixture; timeout
	# freezes a supported climber, while an unsupported one is removed.
	# A ring-out during the contact fixture can already have respawned the host.
	a0 = A.climbers[A.live[0]]
	b0 = B.climbers[a0.climber_id]
	a0.release_all()
	a0.apply_pose(host_standing_pose)
	for body: RigidBody3D in a0.bodies.values():
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
	# The host's climber runs out the clock: frozen and out, identical on both.
	await wait_phase(A, "over", 10.0)
	await seconds(0.5)
	t("net: the timed-out climber is frozen on both machines", a0.state == Climber.State.FROZEN and b0.state == Climber.State.FROZEN)
	t("net: its frozen body matches across machines", _pose_diff(a0.pose(), b0.pose()) < 0.0001, "%.6f" % _pose_diff(a0.pose(), b0.pose()))
	t("net: both machines agree on the winner (the client)", int(A.results.get("winner", -1)) == 1 and int(B.results.get("winner", -1)) == 1, "%s / %s" % [A.results.get("winner"), B.results.get("winner")])
	for m in machines:
		m.game.set_physics_process(false)
		m.game.end_match()
		t("net: leaving releases the retired climbers' network state",
			m.game._puppet_buf.is_empty() and m.game._last_seq.is_empty()
			and m.game._pulls.is_empty() and m.game._pending_freeze.is_empty())
	host_peer.close()
	client_peer.close()
	spectator_peer.close()
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
	# THE SWAP (Parker 11-10): binding a key another action uses swaps the two.
	# (set_bind saves: the player's own binds are put back afterwards.)
	var kept_binds: Dictionary = Players.binds.duplicate(true)
	Players.reset_binds()
	Players.set_bind("kbm", "arm_l", 0, {"key": KEY_D})  # D was the right hand's
	t("devices: binding a key that's in use swaps it (left hand D, right hand gets A)", Players.binds.kbm.arm_l[0] == {"key": KEY_D} and Players.binds.kbm.arm_r[0] == {"key": KEY_A}, [Players.binds.kbm.arm_l[0], Players.binds.kbm.arm_r[0]])
	Players.set_bind("pad", "lock", 0, {"pad": JOY_BUTTON_A})  # A was the right hand's
	t("devices: on the pad too (lock gets A, right hand gets Start)", Players.binds.pad.lock[0] == {"pad": JOY_BUTTON_A} and Players.binds.pad.arm_r[0] == {"pad": JOY_BUTTON_START})
	Players.set_bind("kbm", "leg_l", 1, {"key": KEY_ENTER})  # into an empty slot: Lock's second key moves, the other side empties
	t("devices: swapping into an empty slot leaves the other slot empty", Players.binds.kbm.leg_l[1] == {"key": KEY_ENTER} and Players.binds.kbm.lock[1].is_empty())
	Players.binds = kept_binds
	Players.save()
	# AN ONLINE PLAYER (Parker 11-09): goes by the Steam name, but its climbers get
	# made names (the slot is flagged random), and the host names each new climber.
	Players.clear_players()
	var os := Players.add_online_player("SteamPal")
	t("devices: an online player keeps the Steam name and is flagged for made climber names", os == 0 and Players.slots[0].name == "SteamPal" and bool(Players.slots[0].random))
	var ng := make_game("tower", 1, 60.0)
	ng.roster = [{"pid": 0, "name": "SteamPal", "random": true, "tint": Color.WHITE, "peer": 1, "slot": 0}]
	await wait_phase(ng, "turn")
	ng.host_start({"mode": "tower", "timer": 60.0, "spawn": "alternate", "stage": "dock"}, ng.roster)
	await wait_phase(ng, "turn")
	var nc: Climber = ng.live_climbers()[0]
	t("devices: an online player's climber gets a made name, not the Steam name", nc.display_name != "SteamPal" and nc.display_name.contains(" the "), nc.display_name)
	ng.end_match()
	ng.queue_free()
	await frames(2)
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


# ================================================================ --feel (the reference game, as played)

## Each check is something watched in the reference game on 2026-11-07: hold a limb
## and its hand jumps to the cursor, the arm straightens toward it and the body
## leans after it; out of reach the body leans hard but the feet hold; let go and
## the arm keeps its pose; a foot does the same; loose in the air nothing pulls.
var _feel_peak_hand := 0.0


func _run_feel() -> void:
	ground()
	var c := spawn(Vector2(0, 0.05))
	var d: Drivers.ScriptDriver = c.driver
	await seconds(1.0)
	var head := c.piece_top("head")
	t("feel: you spawn standing, both feet stuck", head > 1.5 and (c.limbs[2].grab_other != null) and (c.limbs[3].grab_other != null), "head top %.2f" % head)
	# 1. Hold the left hand with the cursor up and out to the side, within reach.
	var S := c.limb_root(0)
	var reach: float = c.limbs[0].l1 + c.limbs[0].l2
	var goal := S + Vector2(-0.45, 0.35)
	d.point_limb(0, true, goal)
	var peak := 0.0
	for k in int(0.6 * Engine.physics_ticks_per_second):
		await get_tree().physics_frame
		peak = maxf(peak, c.bodies[c.limbs[0].def.end].linear_velocity.length())
	_feel_peak_hand = peak
	print("INFO feel: peak held-hand speed %.2f m/s" % peak)
	t("feel: power, not speed: a held hand never outruns drag_max_speed", peak < Feel.get_k("drag_max_speed") + 1.0, "peak %.2f m/s" % peak)
	var miss := c.limb_end(0).distance_to(goal)
	t("feel: a held hand jumps to the cursor (within 12 cm in 0.6 s)", miss < 0.12, "%.3f m off" % miss)
	t("feel: the feet stay stuck while you reach", (c.limbs[2].grab_other != null) and (c.limbs[3].grab_other != null))
	# 2. Out of reach: the body leans after the hand, the feet hold, nothing flies.
	var com0 := c.centre_of_mass()
	d.point_limb(0, true, S + Vector2(-2.5, 1.5))
	await seconds(1.0)
	var lean := com0.x - c.centre_of_mass().x
	t("feel: out of reach, the body leans after the hand (COM 10 cm or more toward it)", lean > 0.10, "%.2f m" % lean)
	t("feel: out of reach, the feet still hold (no flying)", (c.limbs[2].grab_other != null) and (c.limbs[3].grab_other != null))
	# 3. Let go.
	d.set_limb(0, false)
	await seconds(1.0)
	# 3b. Switching hands under overlapping input keeps the pull within budget.
	d.point_limb(0, true, c.limb_root(0) + Vector2(-2.5, 1.5))
	d.point_limb(1, true, c.limb_root(1) + Vector2(-2.5, 1.5))
	var worst_total := 0.0
	for k in 30:
		await get_tree().physics_frame
		worst_total = maxf(worst_total, c._drag_total)
	var budget: float = Feel.get_k("drag_strength") * c.total_mass * 9.8
	t("feel: overlapping buttons drive one limb within its pull cap", worst_total > 0.0 and worst_total <= budget * 1.001, "%.0f of %.0f N" % [worst_total, budget])
	# 4. A foot, on a fresh climber: lifts off and follows the cursor; the other foot stays.
	d.clear()
	c = spawn(Vector2(-3.0, 0.05))
	d = c.driver
	await seconds(1.0)
	var H := c.limb_root(2)
	var fgoal := H + Vector2(-0.6, -0.35)
	d.point_limb(2, true, fgoal)
	await seconds(0.8)
	t("feel: a held foot lifts off and follows the cursor (within 20 cm)", c.limb_end(2).distance_to(fgoal) < 0.20 and not (c.limbs[2].grab_other != null), "%.3f m off" % c.limb_end(2).distance_to(fgoal))
	t("feel: the other foot stays stuck", (c.limbs[3].grab_other != null))
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
	# 4b. Pull yourself up with ONE limb (Parker 11-07: "I am having trouble moving
	# myself upwards with just a limb"): hang by the left hand from a bar, then
	# drag the right hand straight up, out of reach. The body must rise.
	var hc := spawn(Vector2(-6.0, 3.0))
	var hd: Drivers.ScriptDriver = hc.driver
	var hbar := bar_at(hc.limb_end(0))
	hc.attach(0, hbar)
	await seconds(2.0)
	var y0 := hc.centre_of_mass().y
	var rise := 0.0
	for k in int(1.2 * Engine.physics_ticks_per_second):
		hd.point_limb(1, true, hc.limb_root(1) + Vector2(0.0, 3.0))
		await get_tree().physics_frame
		rise = maxf(rise, hc.centre_of_mass().y - y0)
	print("INFO feel: one-hand pull-up rise %.2f m" % rise)
	t("feel: one held hand pulls the hanging body up (COM rises 25 cm or more)", rise > 0.25, "%.2f m" % rise)
	hd.clear()
	await seconds(0.3)
	# ... and with a FOOT: hang by the left hand, drag the right foot up, out of reach.
	var fc := spawn(Vector2(-9.0, 3.0))
	var fd: Drivers.ScriptDriver = fc.driver
	fc.attach(0, bar_at(fc.limb_end(0)))
	await seconds(2.0)
	var fy0 := fc.centre_of_mass().y
	var frise := 0.0
	for k in int(1.2 * Engine.physics_ticks_per_second):
		fd.point_limb(3, true, fc.limb_root(3) + Vector2(0.0, 3.0))
		await get_tree().physics_frame
		frise = maxf(frise, fc.centre_of_mass().y - fy0)
	print("INFO feel: one-foot pull-up rise %.2f m" % frise)
	t("feel: one held foot lifts the hanging body (COM rises 15 cm or more)", frise > 0.15, "%.2f m" % frise)
	fd.clear()
	await seconds(0.3)
	# THE SOFT FOLD (Parker 11-08): an elbow turns all the way round (no stop), but a
	# deep fold pushes back. Twist a forearm hard and steadily: it must pass 180.
	var tw := spawn(Vector2(14.0, 8.0))
	for b in tw.bodies.values():
		(b as RigidBody3D).gravity_scale = 0.0
	tw.attach(1, bar_at(tw.limb_end(1)))  # the other hand on a bar: attached, so the held arm drives
	(tw.driver as Drivers.ScriptDriver).set_limb(0, true)  # the twisted arm is the one held
	await frames(2)
	var ej: Dictionary = tw.joints["elbow_l"]
	var last := wrapf(Climber.angle_of(ej.b) - Climber.angle_of(ej.a), -PI, PI)
	var start := last
	var turned := 0.0  # the elbow's unwrapped turn
	for k in int(2.0 * Engine.physics_ticks_per_second):
		var fore: RigidBody3D = tw.bodies["arm_l_lo"]
		var up: RigidBody3D = tw.bodies["arm_l_up"]
		var tq := fore.mass * 9.8 * 8.0  # about a held hand's pull at the elbow
		fore.apply_torque(Vector3(0, 0, tq))
		up.apply_torque(Vector3(0, 0, -tq))  # a twist across the elbow, not a spin of the body
		await get_tree().physics_frame
		var rel := wrapf(Climber.angle_of(ej.b) - Climber.angle_of(ej.a), -PI, PI)
		turned += angle_difference(last, rel)
		last = rel
	t("feel: an elbow turns through 180 under a steady twist (360 degrees, no stop)", absf(start + turned) > PI, "turned %.0f deg from %.0f" % [rad_to_deg(turned), rad_to_deg(start)])
	t("feel: a deep fold pushes back (Feel fold_resistance is on)", Feel.get_k("fold_resistance") > 0.0)
	tw.remove()
	# THE ANKLE STOP (Parker 11-09): twist a foot hard both ways; its ankle stays
	# within the 30 degree stop (a few degrees of give under the shove).
	var ak := spawn(Vector2(18.0, 8.0))
	for b in ak.bodies.values():
		(b as RigidBody3D).gravity_scale = 0.0
	await frames(2)
	var aj: Dictionary = ak.joints["ankle_l"]
	var worst_ankle := 0.0
	for k in int(1.6 * Engine.physics_ticks_per_second):
		var foot: RigidBody3D = ak.bodies["foot_l"]
		var shin: RigidBody3D = ak.bodies["leg_l_lo"]
		var tq := foot.mass * 9.8 * 3.0 * (1.0 if k < 96 else -1.0)
		foot.apply_torque(Vector3(0, 0, tq))
		shin.apply_torque(Vector3(0, 0, -tq))
		await get_tree().physics_frame
		worst_ankle = maxf(worst_ankle, absf(rad_to_deg(wrapf(Climber.angle_of(aj.b) - Climber.angle_of(aj.a), -PI, PI))))
	t("feel: a foot twisted hard stays within the ankle stop (30 deg, a little give)", worst_ankle < Climber.ANKLE_LIMIT_DEG + 6.0, "worst %.1f deg" % worst_ankle)
	ak.remove()
	# THE SLIP (Parker 11-09): a stuck foot, then a stuck hand, is twisted hard both
	# ways by its shin / forearm. The limb swings well past the 30 degree stop because
	# the end turns on its hold, and the ankle / wrist itself stays within the stop.
	for case in [[2, "leg_l_lo", "ankle_l", "foot"], [0, "arm_l_lo", "wrist_l", "hand"]]:
		var sc := spawn(Vector2(24.0 + 4.0 * float(case[0]), 8.0))
		for b in sc.bodies.values():
			(b as RigidBody3D).gravity_scale = 0.0
		await frames(2)
		sc.attach(case[0], bar_at(sc.limb_end(case[0])))
		await frames(2)
		var lever: RigidBody3D = sc.bodies[case[1]]
		var sj: Dictionary = sc.joints[case[2]]
		var prev := Climber.angle_of(lever)
		var swung := 0.0
		var most := 0.0
		var least := 0.0
		var back_most := 0.0
		var worst_stop := 0.0
		for k in int(4.0 * Engine.physics_ticks_per_second):
			var tq := lever.mass * 9.8 * 6.0 * (1.0 if k < 2 * Engine.physics_ticks_per_second else -1.0)
			lever.apply_torque(Vector3(0, 0, tq))
			await get_tree().physics_frame
			var now := Climber.angle_of(lever)
			swung += angle_difference(prev, now)
			prev = now
			# Each push measured from where it began (the first can carry the limb a long way round).
			if k < 2 * Engine.physics_ticks_per_second:
				most = maxf(most, swung)
				least = swung
			else:
				back_most = minf(back_most, swung - least)
			worst_stop = maxf(worst_stop, absf(rad_to_deg(wrapf(Climber.angle_of(sj.b) - Climber.angle_of(sj.a), -PI, PI))))
		t("feel: a stuck %s turns on its hold, so the limb swings past the stop both ways (60 deg+)" % case[3], rad_to_deg(most) > 60.0 and rad_to_deg(back_most) < -60.0 and sc.limbs[case[0]].grab.is_valid(), "%+.0f / %+.0f deg" % [rad_to_deg(most), rad_to_deg(back_most)])
		t("feel: ...and its %s stays within the stop meanwhile" % case[2].get_slice("_", 0), worst_stop < 36.0, "worst %.1f deg" % worst_stop)
		sc.remove()
	# THE DRAWN WRIST (Parker 11-09): the hand you steer turns freely, but its mesh is
	# drawn within the 30 degree stop. A climber with the model, its left hand turned 100
	# degrees back about the wrist: the mesh sits 30 degrees off the forearm.
	var dw: Climber = ClimberScript.new()
	dw.climber_id = _next_id
	_next_id += 1
	add_child(dw)
	dw.build(Vector2(40.0, 8.0), world, GameScript.KNIGHT)
	dw.driver = Drivers.ScriptDriver.new()
	for b in dw.bodies.values():
		(b as RigidBody3D).gravity_scale = 0.0
	await frames(2)
	var dwj: Dictionary = dw.joints["wrist_l"]
	var dhand: RigidBody3D = dw.bodies["hand_l"]
	var dw2: Vector2 = Climber.xf2(dwj.a) * (dwj.local_a as Vector2)
	var dpivot := Vector3(dw2.x, dw2.y, 0.0)
	var dbent := Basis(Vector3.BACK, deg_to_rad(100.0))
	dhand.freeze = true
	dhand.global_transform = Transform3D(dbent * dhand.global_basis, dpivot + dbent * (dhand.global_position - dpivot))
	dw._draw_wrists()
	var dmesh: Node3D = dw._hand_meshes["hand_l"][0]
	var phys := rad_to_deg(wrapf(Climber.angle_of(dhand) - Climber.angle_of(dwj.a), -PI, PI))
	var dturn: Transform3D = dmesh.transform * (dw._hand_meshes["hand_l"][1] as Transform3D).affine_inverse()
	var drawn := phys + rad_to_deg(atan2(dturn.basis.x.y, dturn.basis.x.x))
	t("feel: a hand bent past the stop is drawn at the stop (30 deg)", absf(absf(drawn) - Climber.WRIST_LIMIT_DEG) < 3.0 and absf(phys) > 60.0, "drawn %.1f deg, physics %.1f deg" % [drawn, phys])
	dw.remove()
	# 5. Loose in the air, a held limb isn't pulled anywhere.
	var air := spawn(Vector2(4.0, 6.0))
	var ad: Drivers.ScriptDriver = air.driver
	await frames(2)
	var before := air.limb_end(0) - air.limb_root(0)
	ad.point_limb(0, true, air.limb_root(0) + Vector2(-0.6, 0.6))
	await seconds(0.3)
	var moved := (air.limb_end(0) - air.limb_root(0)).distance_to(before)
	t("feel: loose in the air, a held limb isn't pulled (under 10 cm)", moved < 0.10 and not air.is_attached(), "%.3f m" % moved)

func _run_recovery() -> void:
	var c := spawn(Vector2.ZERO)
	# Lay the climber sideways across a narrow ledge with its ends clear.
	var pivot := (c.bodies["chest"] as RigidBody3D).global_position
	var turn := Basis(Vector3.BACK, PI / 2.0)
	for b: RigidBody3D in c.bodies.values():
		b.global_transform = Transform3D(turn * b.global_basis, turn * (b.global_position - pivot) + Vector3.UP)
		Climber.sync_server(b)
	static_box(Vector2(0, 0.74), Vector2(0.08, 0.10))
	var d: Drivers.ScriptDriver = c.driver
	# Wait for contact instead of assuming a fall time at a particular gravity.
	for tick in 240:
		await frames(1)
		if c._touching_solid():
			break
	var drive_ticks := 0
	var loose_ticks := 0
	for tick in 100:
		d.set_limb(3, true, Vector2.from_angle(TAU * tick / 48.0))
		await frames(1)
		if not c.is_attached():
			loose_ticks += 1
			if c._drag_total > 0.001:
				drive_ticks += 1
	t("recovery: sweeping B while supported without a grip supplies no propulsion", loose_ticks > 0 and drive_ticks == 0, "%d powered ticks out of %d loose" % [drive_ticks, loose_ticks])

func _run_freeflight() -> void:
	var tuned := Feel.get_k("free_gravity_multiplier")
	var rises := []
	for multiplier in [1.0, tuned]:
		Feel.set_k("free_gravity_multiplier", multiplier)
		var c := spawn(Vector2(0, 5))
		var bar := bar_at(c.limb_end(0))
		c.attach(0, bar)
		await frames(3)
		var body: RigidBody3D = c.bodies["chest"]
		t("fling: swing uses latched gravity", is_equal_approx(body.gravity_scale, Feel.get_k("gravity_scale") * Feel.get_k("latched_gravity_multiplier")))
		c.release(0)
		bar.queue_free()
		var start := c.centre_of_mass().y
		var peak := start
		for b: RigidBody3D in c.bodies.values():
			b.linear_velocity = Vector3(2, 4, 0)
		for tick in Engine.physics_ticks_per_second:
			await frames(1)
			peak = maxf(peak, c.centre_of_mass().y)
		t("fling: release switches to free-flight gravity", is_equal_approx(body.gravity_scale, Feel.get_k("gravity_scale") * multiplier))
		rises.append(peak - start)
		var catch_bar := bar_at(c.limb_end(1))
		c.attach(1, catch_bar)
		await frames(2)
		t("fling: catching restores latched gravity", is_equal_approx(body.gravity_scale, Feel.get_k("gravity_scale") * Feel.get_k("latched_gravity_multiplier")))
		c.remove()
		catch_bar.queue_free()
		await frames(2)
	t("fling: same launch rises higher with free-flight gravity", rises[1] > rises[0] * 1.1, "%.2f m -> %.2f m" % rises)


func _run_swing() -> void:
	var c := spawn(Vector2(0, 5))
	var anchor := bar_at(c.limb_end(0))
	c.attach(0, anchor)
	var d: Drivers.ScriptDriver = c.driver
	await seconds(1.0)
	var previous := c.centre_of_mass()
	var release_speed := 0.0
	var peak_speed := 0.0
	# Pump the opposite foot across the bottom and up the far side of the arc.
	for tick in 180:
		var phase := TAU * float(tick) / 96.0
		d.set_limb(3, true, Vector2(cos(phase), sin(phase)))
		await frames(1)
		var centre := c.centre_of_mass()
		release_speed = (centre.y - previous.y) * Engine.physics_ticks_per_second
		previous = centre
		peak_speed = maxf(peak_speed, release_speed)
		if tick > 6 and release_speed > 1.0 and release_speed < peak_speed:
			break
	# Transfer control to the anchor hand to release exactly as a player would.
	d.set_limb(0, true)
	await frames(2)
	t("swing: the last grip releases on the button handoff", not c.is_attached())
	var takeoff := c.centre_of_mass().y
	var peak := takeoff
	for tick in Engine.physics_ticks_per_second * 2:
		await frames(1)
		if c.is_attached():
			break
		peak = maxf(peak, c.centre_of_mass().y)
	t("swing: a single foot pumps an upward launch from one anchored hand", peak > takeoff + 0.18 and release_speed > 1.0, "upward %.2f m/s, rise %.2f m" % [release_speed, peak - takeoff])


func _run_horizontal() -> void:
	await _horizontal_trials()


func _horizontal_trials() -> Array:
	var trials := []
	for anchor_limb in [0, 2]:
		var c := spawn(Vector2(0, 6))
		if anchor_limb == 2:
			# Bend the free leg away so it cannot plant on the same foothold.
			var leg: Dictionary = c.limbs[3].def
			var hip := c.limb_root(3)
			var spread := Basis(Vector3.BACK, PI / 2.0)
			var hip3 := Vector3(hip.x, hip.y, 0)
			for name in [leg.up, leg.lo, leg.end]:
				var piece: RigidBody3D = c.bodies[name]
				piece.global_transform = Transform3D(spread * piece.global_basis, hip3 + spread * (piece.global_position - hip3))
				Climber.sync_server(piece)
		var anchor_pos := c.limb_end(anchor_limb)
		var radius := c.centre_of_mass() - anchor_pos
		var turn := Basis(Vector3.BACK, -radius.angle())
		var pivot := Vector3(anchor_pos.x, anchor_pos.y, 0)
		for body: RigidBody3D in c.bodies.values():
			body.global_transform = Transform3D(turn * body.global_basis, pivot + turn * (body.global_position - pivot))
			Climber.sync_server(body)
		# Touch the outer edge of just this extremity, like a narrow peg.
		var outward := (anchor_pos - c.limb_end(anchor_limb + 1)).normalized()
		var bar := static_box(anchor_pos + outward * c.limbs[anchor_limb].end_r, Vector2(0.015, 0.015))
		c.attach(anchor_limb, bar)
		var start := c.centre_of_mass().y
		var d: Drivers.ScriptDriver = c.driver
		d.set_limb(1, true, Vector2(0, 1))  # The 3D play plane is y-up.
		var release_speed := 0.0
		var lift_ticks := 0
		for tick in 60:
			await frames(1)
			lift_ticks += 1
			if c.centre_of_mass().y > start + 0.25:
				break
		t("horizontal: only the intended extremity holds the peg", c.stuck_count() == 1)
		var rise := c.centre_of_mass().y - start
		d.set_limb(anchor_limb, true)
		await frames(2)
		t("horizontal: switching to the anchor releases it", not c.is_attached())
		# Isolate ballistic rise from any later regrab of the starting peg.
		bar.queue_free()
		var launch := c.centre_of_mass().y
		for body: RigidBody3D in c.bodies.values():
			release_speed += body.mass * body.linear_velocity.y / c.total_mass
		var peak := launch
		for tick in 100:
			if c.is_attached():
				break
			peak = maxf(peak, c.centre_of_mass().y)
			await frames(1)
		trials.append(Vector3(float(lift_ticks) / Engine.physics_ticks_per_second, release_speed, peak - launch))
		t("horizontal: one grip lifts the torso and releases upward", rise > 0.20 and release_speed > 1.5 and peak - launch > 0.3, "anchor %d, lift %.2f m in %d ticks, launch %.2f m/s, airborne rise %.2f m" % [anchor_limb, rise, lift_ticks, release_speed, peak - launch])
		c.remove()
		await frames(2)
	return trials


func _run_floor() -> void:
	ground()
	var c := spawn(Vector2.ZERO)
	# Head and shoulders land first with all four ends clear of the flat deck.
	var head: RigidBody3D = c.bodies["head"]
	var origin := head.global_position
	var turn := Basis(Vector3.BACK, PI - 0.18)
	for piece: RigidBody3D in c.bodies.values():
		piece.global_transform = Transform3D(turn * piece.global_basis, turn * (piece.global_position - origin) + Vector3.UP * 0.22)
		Climber.sync_server(piece)
	var d: Drivers.ScriptDriver = c.driver
	var supported_ticks := 0
	var powered_ticks := 0
	for tick in 480:
		d.set_limb(3, true, Vector2.from_angle(TAU * tick / 48.0))
		await frames(1)
		if c.is_attached():
			break
		if c._touching_solid():
			supported_ticks += 1
			if c.limbs[3].driving or c._drag_total > 0.001:
				powered_ticks += 1
	t("floor: B cannot propel a body resting on the deck without a grip", supported_ticks > 0 and powered_ticks == 0, "%d powered ticks out of %d supported" % [powered_ticks, supported_ticks])
	for tick in 120:
		if c.stuck_count() > 0:
			break
		await frames(1)
	t("floor: an inactive extremity settles into a grip on the deck", c.stuck_count() > 0)


func _run_pace() -> void:
	var main := preload("res://game/main.gd").new()
	main.screen = "hud"
	var baseline := await _horizontal_trials()
	main._on_phase("between")
	main._on_phase("turn")
	await frames(3)
	var slower := await _horizontal_trials()
	for i in baseline.size():
		var before: Vector3 = baseline[i]
		var after: Vector3 = slower[i]
		t("pace: release window expands and launch is preserved", absf(after.x - before.x * 1.25) <= 1.01 / Engine.physics_ticks_per_second and absf(after.y - before.y) < 0.05 and absf(after.z - before.z) < 0.05, "%.0f -> %.0f ms, %.2f -> %.2f m apex" % [before.x * 1000, after.x * 1000, before.z, after.z])
	var g := Game.new()
	add_child(g)
	g.phase = "turn"
	g.clock = 10.0
	g._clock_t = 10.0
	await frames(Engine.physics_ticks_per_second)
	t("pace: the round clock counts real seconds", absf(g.clock - 9.0) < 0.001)
	g.free()
	main._on_phase("over")
	t("pace: ending a match restores the engine clock", Engine.physics_ticks_per_second == 120 and is_equal_approx(Engine.time_scale, 1.0))
	main.free()


func _run_fullreach() -> void:
	await _check_reach(1.0)


func _run_partialreach() -> void:
	for magnitude in [Feel.get_k("stick_deadzone") + 0.001, 0.35, 0.5, 0.65, 0.8, 0.86, 0.88, 0.89, 0.9, 0.91, 0.99]:
		await _check_reach(magnitude)


func _check_reach(magnitude: float) -> void:
	var main := preload("res://game/main.gd").new()
	main.screen = "hud"
	main._on_phase("turn")
	await frames(3)
	# Two holds keep the torso supported without putting the reaching end on a surface.
	for i in 4:
		var c := spawn(Vector2(0, 5))
		var anchors: Array = []
		for j in ([2, 3] if i < 2 else [1 - (i % 2), i ^ 1]):
			var bar := bar_at(c.limb_end(j))
			anchors.append(bar)
			c.attach(j, bar)
		var d: Drivers.ScriptDriver = c.driver
		var dir := Vector2(-1.0 if i % 2 == 0 else 1.0, 0.6 if i < 2 else -0.6).normalized()
		d.set_limb(i, true, dir, magnitude)
		await seconds(2.0)
		var end: RigidBody3D = c.bodies[c.limbs[i].def.end]
		var previous := c.limb_end(i) - c.limb_root(i)
		var last_step := Vector2.ZERO
		var previous_angle := Climber.angle_of(end)
		var last_turn := 0.0
		var jitter := 0.0
		var twist := 0.0
		for tick in 120:
			await frames(1)
			var pos := c.limb_end(i) - c.limb_root(i)
			var step := pos - previous
			var angle := Climber.angle_of(end)
			var turn := angle_difference(previous_angle, angle)
			if tick > 0:
				jitter = maxf(jitter, (step - last_step).length())
				twist = maxf(twist, absf(turn - last_turn))
			previous = pos
			last_step = step
			previous_angle = angle
			last_turn = turn
		var extension := previous.dot(dir) / float(c.limbs[i].l1 + c.limbs[i].l2)
		var minimum := float(c.limbs[i].min_reach) / float(c.limbs[i].l1 + c.limbs[i].l2)
		var expected := clampf(magnitude * Feel.get_k("stick_reach"), minimum, 1.0)
		t("a sustained pull reaches the stick target smoothly", absf(extension - expected) < 0.10 and jitter < 0.003 and twist < deg_to_rad(3.0), "limb %d, %.1f%% stick, %.0f%% reach, %.1f mm and %.1f deg frame-step variation" % [i, 100 * magnitude, 100 * extension, jitter * 1000, rad_to_deg(twist)])
		c.remove()
		for bar in anchors:
			bar.queue_free()
		await frames(2)
	main._on_phase("over")
	main.free()


func _run_neutral() -> void:
	for i in 4:
		var c := spawn(Vector2(0, 5))
		var anchors := []
		for j in ([2, 3] if i < 2 else [1 - (i % 2), i ^ 1]):
			var bar := bar_at(c.limb_end(j))
			anchors.append(bar)
			c.attach(j, bar)
		var d: Drivers.ScriptDriver = c.driver
		var base: RigidBody3D = c.joints[c.limbs[i].def.root].a
		var end: RigidBody3D = c.bodies[c.limbs[i].def.end]
		for action in ["press", "recenter", "reselect bent limb"]:
			if action == "reselect bent limb":
				d.set_limb(i, false)
				await frames(3)
			elif action == "recenter":
				d.set_limb(i, true, Vector2(1 if i % 2 else -1, 0.4), 0.45)
				await frames(40)
				t("neutral: steering resumes without a second press", c._drag_total > 0.0)
			d.set_limb(i, true)
			await frames(2)
			var rest := base.to_local(end.global_position)
			var rotation := Climber.angle_of(end) - Climber.angle_of(base)
			var drift := 0.0
			var twist := 0.0
			var drag := 0.0
			for tick in 120:
				await frames(1)
				drag = maxf(drag, c._drag_total)
				if tick >= 24:
					drift = maxf(drift, rest.distance_to(base.to_local(end.global_position)))
					twist = maxf(twist, absf(angle_difference(rotation, Climber.angle_of(end) - Climber.angle_of(base))))
			t("neutral: selected limb waits in its body-relative pose", drag == 0 and drift < 0.05 and twist < deg_to_rad(12), "limb %d, %s, %.3f m, %.1f deg, %.1f N drag" % [i, action, drift, rad_to_deg(twist), drag])
		c.remove()
		for bar in anchors:
			bar.queue_free()
		await frames(2)


func _run_selffold() -> void:
	for i in 4:
		var c := spawn(Vector2(0, 6))
		var ld: Dictionary = c.limbs[i].def
		c.set_physics_process(false)
		for name in c.bodies:
			var b: RigidBody3D = c.bodies[name]
			b.gravity_scale = 0
			b.freeze = name not in [ld.up, ld.lo, ld.end]
		var root: Dictionary = c.joints[ld.root]
		var mid: Dictionary = c.joints[ld.mid]
		for j in [root, mid]:
			PhysicsServer3D.hinge_joint_set_param(j.rid, PhysicsServer3D.HINGE_JOINT_MOTOR_MAX_IMPULSE, 2.0)
		PhysicsServer3D.hinge_joint_set_param(root.rid, PhysicsServer3D.HINGE_JOINT_MOTOR_TARGET_VELOCITY, 5.0 * Climber.MOTOR_SIGN)
		var previous := Climber.angle_of(root.b)
		var travel := 0.0
		for tick in 220:
			await frames(1)
			var angle := Climber.angle_of(root.b)
			travel += angle_difference(previous, angle)
			previous = angle
		t("fold: the whole limb can revolve past 360 degrees", travel > TAU, "%s %.0f deg" % [ld.id, rad_to_deg(travel)])
		PhysicsServer3D.hinge_joint_set_param(root.rid, PhysicsServer3D.HINGE_JOINT_MOTOR_TARGET_VELOCITY, 0)
		for direction in [1.0, -1.0]:
			PhysicsServer3D.hinge_joint_set_param(mid.rid, PhysicsServer3D.HINGE_JOINT_MOTOR_TARGET_VELOCITY, direction * 7.0 * Climber.MOTOR_SIGN)
			var worst := 0.0
			var at_stop := 0.0
			for tick in 180:
				await frames(1)
				var fold := rad_to_deg(angle_difference(Climber.angle_of(mid.a), Climber.angle_of(mid.b)))
				worst = maxf(worst, absf(fold))
				if tick == 159:
					at_stop = fold
				if tick == 179:
					t("fold: the joint bends then stalls under sustained drive", absf(fold * direction - rad_to_deg(mid.hi)) < 5 and worst < rad_to_deg(mid.hi) + 5 and absf(fold - at_stop) < 3, "%s %.0f deg, max %.0f" % [ld.mid, fold, worst])
		c.remove()
		await frames(2)


func _run_chair() -> void:
	var g := make_game("practice", 1, 50.0, "plaza")
	await wait_phase(g, "turn")
	await seconds(1)
	var c: Climber = g.climbers[g.live[0]]
	var npc := g.partner
	t("practice: chair and upright partner spawn outside the scoring roster", g.chair != null and npc != null and g.live.size() == 1 and npc.piece_top("head") > 1.40, npc.piece_top("head"))
	var d: Drivers.ScriptDriver = c.driver
	c.attach(0, npc.bodies["chest"])
	t("practice: partner can be grappled", (c.limbs[0].grab_other != null))
	c.release_all()
	t("chair: pickup floats over the center line", g.chair.in_bubble and g.chair.freeze and is_zero_approx(g.chair.position.x) and g.chair.position.y > g.line)
	var setup_pose := c.pose()
	var offset := Climber.pos2(g.chair) - c.limb_end(2)
	for k in range(0, setup_pose.size(), 3):
		setup_pose[k] += offset.x
		setup_pose[k+1] += offset.y
	c.apply_pose(setup_pose)
	var foot: RigidBody3D = c.bodies["foot_l"]
	var piece_mass := foot.mass
	d.point_limb(2, true, Climber.pos2(g.chair) + Vector2(0.18, 0.02))
	for tick in 240:
		await frames(1)
		if g.chair.holder == c.climber_id:
			break
	t("chair: reaching with an active foot collects the floating chair", g.chair.holder == c.climber_id)
	if g.chair.holder == c.climber_id:
		d.set_limb(2, true, Vector2(-1, 1).normalized())
		await frames(30)
		t("chair: held without mass or collision load", foot.mass == piece_mass and not g.chair.freeze and g.chair.collision_mask == Climber.SOLID_MASK and g.chair.get_collision_exceptions().has(foot))
		var head: RigidBody3D = npc.bodies["head"]
		# Independently rotating a wrist/ankle in place must never flip the prop.
		for tick in 100:
			g.chair.follow(c, 1.0 / 120)
		var stable := g.chair.global_transform
		var saved := foot.global_transform
		foot.global_basis = Basis(Vector3.BACK, PI) * foot.global_basis
		g.chair.follow(c, 1.0 / 120)
		t("chair: endpoint roll in place cannot flip the carried model", stable.is_equal_approx(g.chair.global_transform))
		foot.global_transform = saved
		var shin: RigidBody3D = npc.bodies["leg_l_lo"]
		g.chair.global_transform = Transform3D(Basis.IDENTITY, shin.global_position + Vector3(-0.30, -0.45, 0))
		g.chair.previous = g.chair.global_transform
		g.chair.previous.origin.x -= 0.065
		var low_hit := g.chair.sweep_hits(1.0 / 120, c.climber_id)
		t("chair: a low strike selects the leg or foot", low_hit.has(-2) and low_hit[-2].piece in ["leg_l_lo", "foot_l", "leg_r_lo", "foot_r"], low_hit)
		g.chair.recent_hits.clear()
		# Graze the side of the head, away from the torso, while sweeping right.
		g.chair.global_transform = Transform3D(Basis.IDENTITY, head.global_position + Vector3(-0.28, 0.51, 0))
		g.chair.previous = g.chair.global_transform
		t("chair: resting contact does not strike", g.chair.sweep_hits(1.0 / 120, c.climber_id).is_empty())
		g.chair.previous.origin.x -= 0.06
		var hits := g.chair.sweep_hits(1.0 / 120, c.climber_id)
		t("chair: head strike carries direction and a local contact point", hits.has(-2) and hits[-2].piece == "head" and hits[-2].impulse.x > 0 and hits[-2].offset.length() > 0.01, hits)
		if hits.has(-2):
			var before := head.linear_velocity
			g._apply_chair_hits(hits)
			await frames(2)
			t("chair: head recoils like a normal player", head.linear_velocity.x > before.x + 0.2)
		for direction in [-1.0, 1.0]:
			g.chair.pick_up(c, 2)
			foot.linear_velocity = Vector3(direction * 3.0, 0.3, 0)
			g.chair.carry_velocity = Vector3(-direction * 3.0, 0, 0)
			g.chair.drop(c, 1.0 / 120)
			t("chair: release follows the limb even after reversal", g.chair.linear_velocity.x * direction > 2.0)
		d.clear()
	# Start the dropped chair balanced on its thin side, not already face-down.
	g.chair.global_transform = Transform3D(Basis(Vector3.BACK, PI / 2), Vector3(-3, 0.28, 0))
	Climber.sync_server(g.chair)
	g.chair.linear_velocity = Vector3.ZERO
	g.chair.angular_velocity = Vector3.ZERO
	g.chair.sleeping = false
	await seconds(4)
	t("chair: an edge landing settles onto a broad face", absf(g.chair.global_basis.z.y) > 0.94, g.chair.global_basis.z.y)
	# Release normal terrain grips before placing the partner outside the arena.
	npc.release_all()
	var pose := npc.pose()
	var player_before: int = g.live[0]
	for k in range(0, pose.size(), 3):
		pose[k] += float(g.stage.row.side_x) + 5.0
	npc.apply_pose(pose)
	await frames(4)
	t("practice: out-of-bounds partner respawns without advancing the turn", g.partner != null and g.partner != npc and not g.stage.out_of_bounds(g.partner.centre_of_mass()) and g.live[0] == player_before and g.phase == "turn", [g.partner != null, g.partner != npc, g.partner.centre_of_mass() if g.partner != null else Vector2.ZERO, g.live[0], player_before, g.phase])
	g.end_match()
	t("practice: leaving removes chair and partner", g.chair == null and g.partner == null)
	g.queue_free()
	await frames(2)


func _run_wrestling() -> void:
	var floor_body := static_box(Vector2(0,-0.2), Vector2(8,0.2))
	var c := spawn(Vector2(0,0.05))
	var ground := spawn(Vector2(3,0.05))
	ground.freeze()
	c.attach(2,ground.bodies["chest"])
	for i in 5:
		c._incoming_pull = c.total_mass * 9.8 * 0.5
		c._physics_process(0.01)
	t("wrestling: a light tug preserves a tower grip", (c.limbs[2].grab_other != null))
	for i in 12:
		c._incoming_pull = c.total_mass * 9.8 * 3.0
		c._physics_process(0.01)
	t("wrestling: old break force no longer detaches a terrain grip", c.limbs[2].grab_other != null)
	c._pull_load = 0.0
	for i in 12:
		c._incoming_pull = c.total_mass * 9.8 * 6.0
		c._physics_process(0.01)
	t("wrestling: a sustained hard pull peels the live grip", not (c.limbs[2].grab_other != null) and c.limbs[2].regrip > 0)
	var attacker := spawn(Vector2(0.6, 0.05))
	attacker.attach(2, floor_body)
	var end: RigidBody3D = attacker.bodies["hand_l"]
	var target: RigidBody3D = c.bodies["chest"]
	attacker.attach(0, target)
	var original := target.global_position
	target.global_position.x += 0.035
	attacker._tick_live_contact(0, 1.0 / 120)
	t("player contact: a modest tug transfers force and holds", attacker.limbs[0].grab_climber == c and attacker.limbs[0].contact_force.x < -1.0)
	# Load the connection enough to peel the target from its footing while
	# the live contact remains intact. Hold the displacement fixed for this load test.
	c.attach(2, ground.bodies["chest"])
	var pull_per_metre := (attacker.limbs[0].contact_force as Vector3).length() / 0.035
	target.global_position = original + Vector3.RIGHT * (2.8 * c.total_mass * 9.8 / pull_per_metre)
	for tick in 100:
		if c.limbs[2].grab_other == null or attacker.limbs[0].grab_other == null:
			break
		attacker._tick_live_contact(0, 1.0 / 120)
		c._physics_process(1.0 / 120)
	t("player contact: a sustained shove can peel the opponent off their footing", c.limbs[2].grab_other == null and attacker.limbs[0].grab_climber == c, "foot free %s, contact load %.1f N" % [c.limbs[2].grab_other == null, attacker.limbs[0].contact_force.length()])
	target.global_position = original + Vector3.RIGHT * 0.54
	for tick in 24:
		if attacker.limbs[0].grab_other == null:
			break
		attacker._tick_live_contact(0, 1.0 / 120)
	t("player contact: continued tension peels only the loaded live contact", attacker.limbs[0].grab_other == null and attacker.limbs[0].regrip > 0 and attacker.limbs[2].grab_other == floor_body)
	target.global_position = original
	attacker.release_all()
	c.attach(2,floor_body)
	c.knock_out()
	t("KO: all grips release and steering stops", c.knockout_left > 0 and c.stuck_count() == 0 and c.active_limb() == -1)
	await seconds(2)
	t("KO: player recovers", c.knockout_left == 0)
	var faller := spawn(Vector2(-3, 3))
	var upside_down := faller.pose()
	for k in range(0,upside_down.size(),3):
		upside_down[k] = -6.0 - upside_down[k]
		upside_down[k+1] = 7.8 - upside_down[k+1]
		upside_down[k+2] += PI
	faller.apply_pose(upside_down)
	faller.live_time = 1
	for body: RigidBody3D in faller.bodies.values():
		body.linear_velocity = Vector3.DOWN * 11.0
	var knocked_down := false
	for tick in 100:
		await frames(1)
		if faller.knockout_left > 0:
			knocked_down = true
			break
	t("KO: a hard head-first landing leaves the climber conscious", not knocked_down and faller.bodies["head"].global_position.y < 1.0)
	ground.knock_out()
	t("wrestling: locked pieces stay frozen", ground.state == Climber.State.FROZEN and ground.knockout_left == 0)


func _run_chairwear() -> void:
	var g := make_game("practice", 1, 50.0, "plaza", true)
	await wait_phase(g, "turn")
	var chair := g.chair
	var c: Climber = g.climbers[g.live[0]]
	var head: RigidBody3D = g.partner.bodies["head"]
	g._chair_impact(g.partner, "head", Vector3.ZERO, Vector3.RIGHT * head.mass * 5.0)
	t("KO: a hard chair strike knocks out the practice partner", g.partner.knockout_left > 0)
	var rival := spawn(Vector2(-3, 5))
	rival.climber_id = 99
	g.climbers[rival.climber_id] = rival
	t("wear: both dent thresholds fall in their allowed windows", chair.dent_hits.x in [8,9,10] and chair.dent_hits.y in [11,12,13])
	var contact := Transform3D(Basis.IDENTITY, head.global_position + Vector3(-0.28, 0.51, 0))
	var clear := contact
	clear.origin.x -= 2.0
	var paths := ["folding_chair.glb", "folding_chair_damage_1.glb", "folding_chair_damage_2.glb"]
	chair.pick_up(c, 0)
	for n in range(1, 21):
		var victim_head: RigidBody3D = head if n % 2 else rival.bodies["head"]
		contact.origin = victim_head.global_position + Vector3(-0.28, 0.51, 0)
		chair.global_transform = clear
		chair.previous = clear
		chair.sweep_hits(0.4, c.climber_id)
		chair.global_transform = contact
		chair.previous = contact
		chair.previous.origin.x -= 0.025  # 3 m/s: a real light hit, above the contact threshold.
		var light := chair.sweep_hits(1.0 / 120, c.climber_id)
		g._apply_chair_hits(light)
		t("wear: a light impact lands without advancing wear", light.size() == 1 and chair.hit_count == n - 1)
		chair.global_transform = clear
		chair.previous = clear
		chair.sweep_hits(0.4, c.climber_id)
		chair.global_transform = contact
		chair.previous = contact
		chair.previous.origin.x -= 0.06
		var ignore_id := chair.holder if chair.holder != -1 else chair.thrower
		if chair.holder == -1:
			g._tick_chair(1.0 / 120)
		else:
			g._apply_chair_hits(chair.sweep_hits(1.0 / 120, ignore_id))
		if n == 20:
			t("wear: twentieth hit removes the playable chair immediately", g.chair == null)
			t("wear: separate pieces of the damaged model scatter", is_instance_valid(g.chair_debris) and g.chair_debris.get_child_count() >= 3)
			break
		var stage := int(n >= chair.dent_hits.x) + int(n >= chair.dent_hits.y)
		t("wear: qualifying impact shows the correct model", chair.hit_count == n and chair.model.scene_file_path.get_file() == paths[stage], "hit %d: %s" % [n, chair.model.scene_file_path])
		chair.sweep_hits(0.5, ignore_id)
		chair.previous.origin.x -= 0.06
		t("wear: sustained contact cannot count a second hit", chair.sweep_hits(1.0 / 120, ignore_id).is_empty())
		if n in [1, 19]:
			chair.drop(c, 1.0 / 120)
		if n == 3:
			chair.pick_up(c, 0)
	await seconds(1.6)
	t("wear: fragments despawn and the chair stays gone", not is_instance_valid(g.chair_debris) and g.chair == null)
	g.end_match()
	g.queue_free()
	await frames(2)


# ================================================================ --ring (Parker 11-08)
## The side ropes throw you back harder than you hit them; the plaza floor outside
## the ring is RING OUT, and 3 s later you're back in the ring.
func _run_ring() -> void:
	var g := make_game("tower", 1, 60.0, "plaza", true)  # dressed: the kit ring and its ropes
	var notes: Array = []
	g.announce.connect(func(text, _big): notes.append(str(text)))
	if not await wait_phase(g, "turn", 10.0):
		t("ring: a turn starts", false)
		return
	t("ring: the plaza sets the rope line at the ring's edge", absf(Climber.rope_x - g.stage.ring_half()) < 0.001, "%.2f" % Climber.rope_x)
	var c: Climber = g.live_climbers()[0]
	var bounces := [0]
	c.rope_bounced.connect(func(_at, _sp): bounces[0] += 1)
	var rope: MeshInstance3D = g.stage.ring_kit.find_child("ring_ropes_right", true, false) if g.stage.ring_kit != null else null
	var rest_w := rope.mesh.get_aabb().size.x if rope != null else 0.0
	var rope_peak := 0.0  # how far the rope's middle bows out (mesh width growth)
	# Throw it at the right-hand ropes: standing near them, every piece moving out at 4 m/s.
	c.release_all()
	var shift := Vector3(7.6 - c.centre_of_mass().x, 0.4, 0.0)
	for b in c.bodies.values():
		var rb := b as RigidBody3D
		rb.global_position += shift
		Climber.sync_server(rb)
		rb.linear_velocity = Vector3(4.0, 0.0, 0.0)
	var back := 0.0
	for k in int(1.0 * Engine.physics_ticks_per_second):
		await get_tree().physics_frame
		var v := Vector2.ZERO
		for b in c.bodies.values():
			v += Vector2(b.linear_velocity.x, b.linear_velocity.y) * b.mass
		back = minf(back, v.x / c.total_mass)
		if rope != null:
			rope_peak = maxf(rope_peak, rope.mesh.get_aabb().size.x - rest_w)
	t("ring: the ropes throw you back harder than you hit them (in at 4 m/s)", back < -4.0, "back at %.2f m/s" % back)
	t("ring: the bounce is told (signal) and has five tension sounds", bounces[0] > 0 and Sound.SFX["rope"].size() == 5 and Sound._streams.has("rope_tension_05"), "%d bounces" % bounces[0])
	# BACK THE WAY YOU CAME (Parker 11-09): falling into the ropes at an angle (out at
	# 3 m/s, down at 4 m/s), the bounce throws you back in AND up.
	await seconds(0.5)
	c.release_all()
	var shift2 := Vector3(7.6 - c.centre_of_mass().x, 1.0 - c.centre_of_mass().y, 0.0)
	for b in c.bodies.values():
		var rb := b as RigidBody3D
		rb.global_position += shift2
		Climber.sync_server(rb)
		rb.linear_velocity = Vector3(3.0, -4.0, 0.0)
	var up := -99.0
	var inward := 0.0
	for k in int(0.5 * Engine.physics_ticks_per_second):
		await get_tree().physics_frame
		var v2 := Vector2.ZERO
		for b in c.bodies.values():
			v2 += Vector2(b.linear_velocity.x, b.linear_velocity.y) * b.mass
		v2 /= c.total_mass
		if v2.x < inward:
			inward = v2.x
			up = v2.y
	t("ring: falling into the ropes at an angle bounces you back in and up (out 3, down 4 m/s)", inward < -3.0 and up > 2.0, "back at (%.2f, %.2f) m/s" % [inward, up])
	# ONLY EVER LIFT (Parker 11-09): rising into the ropes you keep rising, never sent down.
	var rising := Climber.rope_throw(Vector2(3.0, 3.0), 1.0)
	var falling := Climber.rope_throw(Vector2(-3.0, -4.0), -1.0)
	t("ring: the rope throw only ever adds lift (rising stays rising, falling turns up)", rising.x < -3.0 and is_equal_approx(rising.y, 3.0) and falling.x > 3.0 and falling.y > 3.9, "%s / %s" % [rising, falling])
	await seconds(0.6)
	var settled: bool = rope != null and rope.mesh == rope.get_meta("rest_mesh", null)
	var rope_voice := rope.get_node_or_null("TensionSound") as AudioStreamPlayer3D
	t("ring: creak stops when rope settles", rope_voice != null and not rope_voice.playing)
	var ends_still: bool = rope != null and absf(rope.position.x) < 99.0  # the node never moves: only its middle bends
	t("ring: the side rope's middle bows out with the hit (its ends stay on the posts) and settles back", rope != null and rope_peak > 0.05 and settled and ends_still, "bowed %.2f m, back %s" % [rope_peak, settled])
	# Inspect the strands halfway from the centre badges to each fixed post.
	for side in [-1, 1]:
		g.stage.bounce_rope(side, 4.0)
	await seconds(0.055)
	t("ring: creak plays while rope is stretched", rope_voice != null and rope_voice.playing and rope_voice.volume_db > -20.0)
	for side in [-1, 1]:
		var strand_mesh: MeshInstance3D = g.stage.ring_kit.find_child("ring_ropes_right" if side > 0 else "ring_ropes_left", true, false)
		var rest: Mesh = strand_mesh.get_meta("rest_mesh")
		var peaks := PackedFloat32Array([0, 0, 0])
		for si in rest.get_surface_count():
			var before: PackedVector3Array = rest.surface_get_arrays(si)[Mesh.ARRAY_VERTEX]
			var after: PackedVector3Array = strand_mesh.mesh.surface_get_arrays(si)[Mesh.ARRAY_VERTEX]
			for j in before.size():
				var point := before[j]
				if absf(point.z) > 0.4 and absf(point.z) < 1.1:
					var tier := clampi(roundi((point.y - 0.5) / 0.45), 0, 2)
					peaks[tier] = maxf(peaks[tier], side * (after[j].x - point.x))
		t("ring: all three side strands flex beyond their centre fittings", peaks[0] > 0.05 and peaks[1] > 0.05 and peaks[2] > 0.05, peaks)
	# Drop it outside the ring onto the plaza stones.
	c.release_all()
	var drop := Vector3(12.0 - c.centre_of_mass().x, 0.5 - c.centre_of_mass().y, 0.0)
	for b in c.bodies.values():
		var rb := b as RigidBody3D
		rb.global_position += drop
		Climber.sync_server(rb)
		rb.linear_velocity = Vector3.ZERO
	var cid0 := c.climber_id
	var t_out := -1.0
	var t_back := -1.0
	var tt := 0.0
	while tt < 6.0:
		await get_tree().physics_frame
		tt += 1.0 / Engine.physics_ticks_per_second
		if t_out < 0.0 and "RING OUT!" in notes:
			t_out = tt
		var now: Array = g.live_climbers()
		if t_out >= 0.0 and not now.is_empty() and (now[0] as Climber).climber_id != cid0:
			t_back = tt
			break
	t("ring: landing on the plaza says RING OUT!", t_out >= 0.0, "%.2f s" % t_out)
	t("ring: back in the ring about 3 s later", t_back > 0.0 and absf((t_back - t_out) - Game.RING_OUT_S) < 0.3, "%.2f s after" % (t_back - t_out))
	if t_back > 0.0:
		var nc: Climber = g.live_climbers()[0]
		t("ring: the respawn stands in the ring", absf(nc.centre_of_mass().x) < g.stage.ring_half(), "x %.2f" % nc.centre_of_mass().x)
	g.end_match()
	g.queue_free()


func _run_roundchair() -> void:
	for mode_id in ["tower", "scramble"]:
		var g := make_game(mode_id, 2, 30.0, "plaza")
		g.host_start({"mode": mode_id, "timer": 30.0, "stage": "plaza", "base": "barrel"}, g.roster)
		var active_phase := "turn" if mode_id == "tower" else "round"
		if not await wait_phase(g, active_phase, 5.0):
			t("opening phase starts", false, mode_id)
			return
		var generation := g.chair_generation
		var c: Climber = g.climbers[g.live[0]]
		c.set_glyphs([{"text": "X"}])
		t("live climber displays its glyph", c._glyphs[0].visible)
		g.chair.in_bubble = false
		g.chair.global_position = Vector3(30, -10, 0)
		g._tick_chair(1.0 / 120.0)
		t("out-of-bounds chair stays retired until the next round", g.chair == null)
		await lift_and_lock(g, 0)
		c.set_glyphs_visible(true)
		t("locked climber has no glyphs after visibility refresh", c._glyphs.is_empty())
		if mode_id == "scramble":
			t("first lock does not replenish the chair mid-round", g.chair == null)
			await lift_and_lock(g, 1)
		await wait_phase(g, active_phase, 5.0)
		t("next play restores a fresh chair", g.chair != null and g.chair_generation == generation + 1, mode_id)
		if g.chair != null:
			t("bubble floats over the frozen tower", g.chair.in_bubble and g.chair.hit_count == 0 and is_equal_approx(g.chair.position.y, g.tower_top() + g.chair.PICKUP_HEIGHT))
			g._rpc_chair_pose(generation, -1, -1, Vector3.ZERO, Transform3D.IDENTITY, 10, false)
			t("late chair pose cannot damage the new chair", g.chair.in_bubble and g.chair.hit_count == 0)
		g.end_match()
		g.queue_free()
		await frames(2)


func _run_teamtoss() -> void:
	var base := spawn(Vector2(0, 7))
	base.attach(0, bar_at(base.limb_end(0)))
	var partner := spawn(Vector2(0, 5))
	var pose := partner.pose()
	# One hand on the anchor player's foot, the rest of the partner below it.
	for k in range(0, pose.size(), 3):
		var local := (Vector2(pose[k], pose[k + 1]) - partner.limb_end(0)).rotated(PI)
		var p := base.limb_end(3) + local + Vector2(0.07, -0.02)
		pose[k] = p.x
		pose[k + 1] = p.y
		pose[k + 2] += PI
	partner.apply_pose(pose)
	for l in partner.limbs:
		l.regrip = 3.0
	for l in base.limbs:
		l.regrip = 3.0
	partner.attach(0, base.bodies["foot_r"])
	var drive: Drivers.ScriptDriver = base.driver
	var release_speed := -INF
	drive.set_limb(3, true, Vector2(0, 1))
	for tick in 150:
		await frames(1)
		if partner.limbs[0].grab_other == null:
			break
		release_speed = 0
		for body: RigidBody3D in partner.bodies.values():
			release_speed += body.linear_velocity.y * body.mass / partner.total_mass
		if release_speed > 0.6:
			break
	var connected: bool = partner.limbs[0].grab_other == base.bodies["foot_r"]
	(partner.driver as Drivers.ScriptDriver).set_limb(0, true)
	await frames(2)
	var launch := partner.centre_of_mass().y
	var peak := launch
	for tick in 60:
		await frames(1)
		peak = maxf(peak, partner.centre_of_mass().y)
	t("team toss: a planted teammate gains lift and coasts after button release", connected and release_speed > 0.5 and peak > launch + 0.035, "upward %.2f m/s, free rise %.2f m" % [release_speed, peak - launch])


func _run_spawnspacing() -> void:
	for side in ["left", "right", "random", "alternate"]:
		var g := make_game("scramble", 8, 60, "plaza")
		g.settings.spawn = side
		await wait_phase(g, "round")
		var occupied := []
		var clear := true
		for c: Climber in g.live_climbers():
			for feet: Vector2 in occupied:
				clear = clear and c.spawn_at.distance_to(feet) >= 1.0
			occupied.append(c.spawn_at)
		t("spawn: Classic entrants have separate positions", clear and occupied.size() == 2, side)
		# Respawn one entrant while another is standing on the preferred spawn.
		g.settings.spawn = "right"
		var blocker: Climber = g.climbers[g.live[0]]
		var p := blocker.pose()
		var slide := g.stage.spawn_point(1).x - blocker.spawn_at.x
		for k in range(0, p.size(), 3):
			p[k] += slide
		blocker.apply_pose(p)
		g._spawn(1)
		var respawn: Climber = g.climbers[g.live[1]]
		t("spawn: a respawn avoids another player's current pose", respawn.spawn_at.distance_to(g.stage.spawn_point(1)) >= 1.0, respawn.spawn_at)
		g.end_match()
		g.queue_free()
		await frames(2)


func _run_practicespacing() -> void:
	var g := make_game("practice", 1, 60, "plaza")
	await wait_phase(g, "turn")
	var player: Climber = g.climbers[g.live[0]]
	var shape := player.pose()
	var delta_x := 3.2 - player.spawn_at.x
	for k in range(0, shape.size(), 3):
		shape[k] += delta_x
	player.apply_pose(shape)
	g._spawn_partner()
	t("spawn: practice partner avoids the current player", not g.partner.pose_bounds(g.partner.pose()).intersects(player.pose_bounds(player.pose())))
	# A previous turn's frozen climber still occupies the preferred spawn position.
	shape = player.pose()
	for k in range(0, shape.size(), 3):
		shape[k] += 5.5 - 3.2
	player.apply_pose(shape)
	player.freeze()
	g.tower.append(player.climber_id)
	g.settings.spawn = "right"
	g._spawn(0)
	var next: Climber = g.climbers[g.live[0]]
	t("spawn: next turn clears the frozen player too", not next.pose_bounds(next.pose()).intersects(player.pose_bounds(player.pose())))
	g.end_match()
	g.queue_free()
	await frames(2)


func _run_chairsolid() -> void:
	var g := make_game("practice", 1, 60, "plaza")
	await wait_phase(g, "turn")
	var chair := g.chair
	var c: Climber = g.climbers[g.live[0]]
	var hand: RigidBody3D = c.bodies["hand_r"]
	t("chair solid: floating pickup passes through bodies and terrain", chair.in_bubble and chair.collision_layer == 0 and chair.collision_mask == 0)
	c.attach(0, chair)
	t("chair solid: a chair contact never creates a climbing anchor", c.limbs[0].grab_other != chair)
	var wall := static_box(Vector2(-4, 3), Vector2(0.05, 2))
	g.set_physics_process(false)
	c.release_all()
	var move := Vector3(-4.72, 3, 0) - hand.global_position
	for body: RigidBody3D in c.bodies.values():
		body.global_position += move
		Climber.sync_server(body)
		body.linear_velocity = Vector3.RIGHT * 3
	chair.global_transform = Transform3D(Basis.IDENTITY, hand.global_position + Vector3.RIGHT * 0.19)
	Climber.sync_server(chair)
	await frames(2)  # let the teleported kinematic pickup settle before grabbing
	chair.pick_up(c, 1)
	var grip_gap := 0.0
	# Pull across a wall for half a second. The prop must stay on its near side.
	var reached_barrier := false
	for tick in 60:
		hand.apply_central_force(Vector3.RIGHT * 50)
		chair.follow(c, 1.0 / 120)
		await frames(1)
		grip_gap = maxf(grip_gap, hand.global_position.distance_to(chair.to_global(chair.grip_point)))
		reached_barrier = reached_barrier or chair.get_colliding_bodies().has(wall)
	t("chair solid: a held chair cannot be steered through scenery", reached_barrier and chair.global_position.x < -4.0, chair.global_position)
	t("chair solid: a blocked prop stays at the gripping hand", grip_gap < 0.06, grip_gap)
	chair.drop(c, 1.0 / 120)
	chair.global_position = Vector3(-6, 6, 0)
	Climber.sync_server(chair)
	await frames(2)
	chair.release_carrier_when_clear()
	t("chair solid: former carrier collides again after separation", not chair.get_collision_exceptions().has(hand))
	var terrain_hits := []
	chair.terrain_struck.connect(func(_at, speed): terrain_hits.append(speed))
	var wear_before := chair.hit_count
	wall.global_position = Vector3(-14, 6, 0)
	Climber.sync_server(wall)
	wall.collision_layer = Climber.LAYER_FROZEN
	chair.global_transform = Transform3D(Basis.IDENTITY, Vector3(-14.8, 6, 0))
	chair.angular_velocity = Vector3.ZERO
	Climber.sync_server(chair)
	chair.linear_velocity = Vector3.RIGHT * 12.0
	await frames(18)
	t("chair solid: a thrown chair is stopped by the frozen layer", chair.global_position.x < -14.0)
	t("chair solid: a frozen obstacle plays one heavy terrain slam without wear", terrain_hits.size() == 1 and terrain_hits[0] > chair.LIGHT_HIT_MAX_SPEED and chair.hit_count == wear_before, terrain_hits)
	terrain_hits.clear()
	wall.collision_layer = Climber.LAYER_WORLD
	chair.global_transform = Transform3D(Basis.IDENTITY, Vector3(-15, 6, 0))
	Climber.sync_server(chair)
	chair.linear_velocity = Vector3.RIGHT * 3
	chair.angular_velocity = Vector3.ZERO
	await frames(40)
	t("chair solid: scenery plays one light slam without wear", terrain_hits.size() == 1 and terrain_hits[0] <= chair.LIGHT_HIT_MAX_SPEED and chair.hit_count == wear_before, terrain_hits)
	# A real throw at a live target should generate a solid contact and heavy hit.
	var head: RigidBody3D = g.partner.bodies["head"]
	chair.global_transform = Transform3D(Basis.IDENTITY, head.global_position + Vector3(-0.85, 0.36, 0))
	Climber.sync_server(chair)
	chair.previous = chair.global_transform
	chair.linear_velocity = Vector3.RIGHT * 8
	chair.angular_velocity = Vector3.ZERO
	var contact := false
	var heavy := false
	for tick in 35:
		await frames(1)
		for other in chair.get_colliding_bodies():
			if other.has_meta("climber") and other.get_meta("climber") == g.partner:
				contact = true
		var hits := chair.sweep_hits(1.0 / 120, c.climber_id)
		if hits.has(-2):
			heavy = heavy or hits[-2].speed > chair.LIGHT_HIT_MAX_SPEED
	t("chair solid: a throw collides with a live body and registers a heavy hit", contact and heavy, [contact, heavy])
	chair.global_position = Vector3(Climber.rope_x - 0.3, 0.8, 0)
	chair.linear_velocity = Vector3.RIGHT * 4
	chair.tick_ropes(1.0 / 120)
	t("chair solid: an outward throw rebounds in the rope band", chair.linear_velocity.x < -4)
	# THE SAME ROPE RULES AS PEOPLE (Parker 11-09): a falling chair goes back in and up.
	chair.rope_wait = 0.0
	chair.global_position = Vector3(Climber.rope_x - 0.3, 0.8, 0)
	chair.linear_velocity = Vector3(3.0, -4.0, 0)
	chair.tick_ropes(1.0 / 120)
	t("chair solid: a chair falling into the ropes bounces back in and up, as people do", chair.linear_velocity.x < -3.0 and chair.linear_velocity.y > 3.0, Vector2(chair.linear_velocity.x, chair.linear_velocity.y))
	g.end_match()
	g.queue_free()
	await frames(2)


# Run these two probes in separate processes so both real Net autoloads take the
# normal handshake path and the client drives an owned climber through LocalDriver.
func _run_joinpadhost() -> void:
	var game := GameScript.new()
	game.world = world
	game.dress = false
	add_child(game)
	var test_peer := ENetMultiplayerPeer.new()
	assert(test_peer.create_server(7788, 12) == OK)
	Net.multiplayer.multiplayer_peer = test_peer
	Net._start_session_as_host()
	for tick in 1800:
		if Net.members.size() >= 2:
			break
		await frames(1)
	var roster := Net.build_roster()
	t("join pad: host receives a playable client slot", roster.size() == 2)
	if roster.size() == 2:
		game.host_start({"mode":"scramble","timer":60.0,"stage":"dock"}, roster)
		for tick in 1500:
			if Net.members.size() < 2:
				break
			await frames(1)
	game.end_match()
	Net.leave()


func _run_joinpadclient() -> void:
	var game := GameScript.new()
	game.world = world
	game.dress = false
	add_child(game)
	var si := preload("res://core/steam_input.gd").new()
	Net.add_child(si)
	Net.steam_input = si
	si.devices[3000] = {"buttons": {}, "stick": Vector2.ZERO, "gameplay_active":false, "menu_active":false}
	Players.clear_players()
	var test_peer := ENetMultiplayerPeer.new()
	assert(test_peer.create_client("127.0.0.1", 7788) == OK)
	Net.multiplayer.multiplayer_peer = test_peer
	await wait_phase(game, "round", 12.0)
	var mine: Climber
	# The round announcement can arrive one packet before the spawn RPC.
	for tick in 180:
		for c: Climber in game.live_climbers():
			if c.owner_peer == Net.me():
				mine = c
		if mine != null:
			break
		await frames(1)
	t("join pad: direct join creates a local driver for the client", mine != null and mine.driver is Drivers.LocalDriver and Players.slots.size() == 1)
	if mine != null:
		var b := InputEventJoypadButton.new()
		b.device = 7
		b.button_index = JOY_BUTTON_X
		b.pressed = true
		Input.parse_input_event(b)
		var axis := InputEventJoypadMotion.new()
		axis.device = 7
		axis.axis = JOY_AXIS_LEFT_X
		axis.axis_value = 0.8
		Input.parse_input_event(axis)
		await frames(4)
		t("join pad: native events steer when Steam has no active bindings", mine.active_limb() == 0 and mine.driver.aim(mine,0).dir.x > 0.9)
		b.pressed = false
		Input.parse_input_event(b)
		await frames(3)
		t("join pad: native release clears the limb", mine.active_limb() == -1)
		si.devices[3000].gameplay_active = true
		si.devices[3000].buttons = {"arm_r":true, "lock":true}
		si.devices[3000].stick = Vector2(0, 0.85)
		Players.note_device(3000)
		t("join pad: primary controller cannot also join as a couch player", Players.poll_join() == -2)
		si.devices[3000].buttons.erase("lock")
		await frames(4)
		t("join pad: activating Steam hands off buttons and aim", mine.active_limb() == 1 and mine.driver.aim(mine,1).dir.y > 0.9)
		si.devices[3000].buttons.clear()
		await frames(3)
		t("join pad: Steam release clears the limb", mine.active_limb() == -1)
	game.end_match()
	Players.clear_players()
	Players.add_player(0, "Returning pad")
	Players.prepare_online("Client")
	t("join pad: a single returning native player works on Steam", Players.slots.size() == 1 and Players.slots[0].device == Players.ANY and Players.slots[0].name == "Returning pad")
	Players.clear_players()
	Players.add_player(1)
	Players.add_player(0)
	si.devices[3000].gameplay_active = true
	si.devices[3000].gamepad_index = 0
	si.devices[3000].buttons = {"arm_l":true}
	si.devices[3001] = {"buttons": {"leg_r":true}, "stick": Vector2.RIGHT, "gamepad_index":1}
	Players.prepare_online("Client")
	t("join pad: separate local slots keep their own controller after takeover", Players.limb_held(0,3) and not Players.limb_held(0,0) and Players.limb_held(1,0) and not Players.limb_held(1,3))
	Net.leave()
	Net.steam_input = null
	si.queue_free()


## THE BELL BASE (Parker 11-10): its collision stands where the model does (the
## bell's hull up at the bell, not on the canvas), only bell_body rings, a limb that
## sticks to the bell rings it and pulses it, and one stuck to the pedestal doesn't.
func _run_bell() -> void:
	var g := make_game("tower", 1, 60.0, "plaza", true)
	g.host_start({"mode": "tower", "timer": 60.0, "spawn": "alternate", "stage": "plaza", "base": "bell"}, g.roster)
	await wait_phase(g, "turn")
	var st: Stage = g.stage
	var ringers := st.base_bodies.filter(func(b): return b.has_meta("bell_ring"))
	t("bell: the bell base is up, 2.20 m tall, first line FIRST_LINE_ABOVE above", st.base_id == "bell" and absf(st.barrel_top - 2.20) < 0.02 and is_equal_approx(st.first_line, st.barrel_top + Stage.FIRST_LINE_ABOVE), "top %.3f line %.3f" % [st.barrel_top, st.first_line])
	t("bell: one hull rings (bell_body), and it sits up at the bell", ringers.size() == 1 and _hull_mid_y(ringers[0]) > 1.2, "%d ringers, mid y %.2f" % [ringers.size(), _hull_mid_y(ringers[0]) if ringers.size() > 0 else -1.0])
	t("bell: the model's bell node is found for the pulse", st.bell_node != null)
	var c: Climber = g.live_climbers()[0]
	var before := g.bell_rings
	c.attach(0, ringers[0])
	await frames(2)
	t("bell: a hand stuck to the metal bell rings it", g.bell_rings == before + 1, g.bell_rings - before)
	await frames(4)
	t("bell: ...and the bell pulses", st.bell_node.scale.x > 1.01, st.bell_node.scale.x)
	c.release(0)
	var stone: Object = st.base_bodies.filter(func(b): return not b.has_meta("bell_ring"))[0]
	before = g.bell_rings
	c.attach(1, stone)
	await frames(2)
	t("bell: a hand on the stone doesn't ring it", g.bell_rings == before)
	c.release(1)
	g.end_match()
	g.queue_free()
	await frames(2)


func _hull_mid_y(body: StaticBody3D) -> float:
	var pts: PackedVector3Array = ((body.get_child(0) as CollisionShape3D).shape as ConvexPolygonShape3D).points
	var lo := INF
	var hi := -INF
	for p in pts:
		lo = minf(lo, p.y)
		hi = maxf(hi, p.y)
	return (lo + hi) * 0.5


## THE PLAZA FLOOR (Parker 11-10: "the ground outside the ring is not solid in places,
## fix that so you don't fall through the ground if ringed out"): climbers dropped all
## along the plaza outside the ring, both sides, land on the stones.
func _run_plazafloor() -> void:
	var st := Stage.new("plaza")
	st.build(world, false)
	var xs := []
	for x in [9.05, 9.3, 10.0, 12.0, 14.0, 15.5, 16.5, 18.0, 22.0, 28.0]:
		xs.append(x)
		xs.append(-x)
	var holes := []
	var lows := {}
	for x in xs:
		var c := spawn(Vector2(x, 1.5))
		c.release_all()
		await seconds(1.6)
		var low := INF
		for b in c.bodies.values():
			low = minf(low, (b as Node3D).global_position.y)
		lows[x] = snappedf(low, 0.01)
		if low < Stage.PLAZA_GROUND - 0.6:
			holes.append(x)
		c.remove()
	print("INFO plaza floor lows: ", lows)
	t("plazafloor: a climber falling anywhere outside the ring lands on the stones", holes.is_empty(), "holes at %s" % str(holes))


## DEL MAR (Parker 11-10, docs/DEL_MAR.md): the pier, the base at its end, the 45 degree
## line along x + y starting 0.75 past the base, spawns 3 m apart on the deck, a lock
## over the line moving it to 0.25 past the tower, the buoy never held, and a fall into
## the sea is out. Back to the plaza when the match ends.
func _run_delmar() -> void:
	Stage.warm_delmar()  # MODE reads DEL MAR: its pieces start loading in the background
	var asked: int = Stage._warming.size()
	var g := make_game("delmar", 2, 50.0, "plaza")
	if not await wait_phase(g, "round"):
		t("delmar: a round starts", false)
		return
	t("delmar: picking it loads its pieces on background threads, collected when the match starts", Stage._warming.is_empty() and (asked > 0 and Stage._warm.size() >= asked or asked == 0), [asked, Stage._warm.size()])
	var st: Stage = g.stage
	var base_right := st.base_root.position.x + st.barrel_half
	t("delmar: the pier is built and the base stands flush on its end", st.delmar and is_instance_valid(st.delmar_root) and absf(base_right - Stage.PIER_END) < 0.05, "base right %.2f" % base_right)
	var reach := -INF
	for b in st.base_bodies:
		for q: Vector3 in ((b.get_child(0) as CollisionShape3D).shape as ConvexPolygonShape3D).points:
			reach = maxf(reach, q.x + q.y + st.base_root.position.x)
	t("delmar: the line starts 0.75 past the base along the rope (x + y)", is_equal_approx(g.line, reach + 0.75) and is_equal_approx(st.first_line, g.line), "line %.2f, base reach %.2f" % [g.line, reach])
	var xs: Array = g.live_climbers().map(func(c): return snappedf(c.centre_of_mass().x, 0.01))
	xs.sort()
	t("delmar: two spawns on the pier, about 3 m apart near its end", xs.size() == 2 and absf(xs[1] - xs[0] - 3.0) < 0.4 and xs[1] < Stage.PIER_END and xs[1] > Stage.PIER_END - 6.0, xs)
	await frames(10)
	var eye := st.buoy_body.global_position + Stage.BUOY_EYE
	t("delmar: the buoy floats on the water with the rope's eye on the line", absf(st.buoy_body.global_position.y - Stage.WATER_Y) < 0.01 and absf(eye.x + eye.y - g.line) < 0.3, "eye x+y %.2f vs line %.2f" % [eye.x + eye.y, g.line])
	# The buoy is never held.
	var c0: Climber = g.climbers[g.live[0]]
	c0.attach(0, st.buoy_body)
	t("delmar: a hand can't weld to the buoy", c0.limbs[0].grab_other != st.buoy_body)
	# Lock in: stand climber 0 on the base's top; it reaches over the rope.
	c0.release_all()
	for l in c0.limbs:
		l.regrip = 2.0
	var p := c0.pose()
	var low := INF
	var low_x := 0.0
	for i in Layout.ORDER.size():
		var k := 3 * i
		var y := -c0.top_of(Layout.ORDER[i], Transform2D(p[k + 2] + PI, Vector2(0, -p[k + 1])))
		if y < low:
			low = y
			low_x = p[k]
	var spot := Vector2(st.base_root.position.x, st.barrel_top)
	for k in range(0, p.size(), 3):
		p[k] += spot.x - low_x
		p[k + 1] += spot.y - low - 0.008
	c0.apply_pose(p)
	var before := g.line
	var reached := g.measure(c0)
	(g.bot_drivers[0] as Drivers.ScriptDriver).lock = true
	await frames(4)
	(g.bot_drivers[0] as Drivers.ScriptDriver).lock = false
	t("delmar: over the rope and on the base, the lock is accepted", c0.state == Climber.State.FROZEN, "reach %.2f vs line %.2f" % [reached, before])
	t("delmar: the line moves to 0.25 past the tower's furthest point", absf(g.line - (reached + 0.25)) < 0.05 and g.line > before, "line %.2f, reach %.2f" % [g.line, reached])
	# A climber under the line is refused (climber 1, standing on the deck).
	var c1: Climber = g.climbers[g.live[1]]
	var refused_before := c1.state
	t("delmar: standing on the deck is under the line", g.measure(c1) < g.line, "%.2f < %.2f" % [g.measure(c1), g.line])
	# A chair into the sea: its splash once, then it sinks slowly (not a stone). The round still runs.
	g._rpc_spawn_chair(g.chair_generation + 1, Vector2(116.0, Stage.WATER_Y + 1.2), Vector2i(8, 11))
	await frames(1)
	var ch: RigidBody3D = g.chair
	ch.in_bubble = false
	ch.global_position = Vector3(116.0, Stage.WATER_Y + 0.6, 0.0)
	Climber.sync_server(ch)
	ch.freeze = false
	ch.linear_velocity = Vector3(0, -7.0, 0)
	var was_wet := g._chair_wet
	await seconds(0.5)
	t("delmar: a chair falling in the sea splashes, then sinks slowly", not was_wet and g._chair_wet and is_instance_valid(ch) and ch.linear_velocity.y > -2.5 and ch.global_position.y < Stage.WATER_Y, "wet %s, v %.2f, y %.2f" % [g._chair_wet, ch.linear_velocity.y if is_instance_valid(ch) else 0.0, ch.global_position.y if is_instance_valid(ch) else 0.0])
	# The sea: climber 1 falls in and is out.
	var drop := Vector3(0, Stage.WATER_Y - 1.0 - c1.centre_of_mass().y, 0)
	c1.release_all()
	for b in c1.bodies.values():
		var rb := b as RigidBody3D
		rb.global_position += drop + Vector3(6.0, 0, 0)
		Climber.sync_server(rb)
	await frames(6)
	# IN THE DRINK (Parker 11-11): limp and sinking first, out only once right under.
	var c1_id := c1.climber_id
	var all_let_go := c1.limbs.all(func(l): return not l.grab.is_valid())
	t("delmar: in the sea the climber goes limp and sinks; not out yet", c1.sinking and all_let_go and g.live.has(1) and g._sinking.has(c1_id), [c1.sinking, all_let_go, g.live.keys()])
	var highest := INF
	for k in int(5.0 * Engine.physics_ticks_per_second):
		if not g.live.has(1):
			break
		highest = -INF
		for b in c1.bodies.values():
			highest = maxf(highest, (b as Node3D).global_position.y)
		await get_tree().physics_frame
	t("delmar: falling in the sea is out, once the whole body has gone under (and then some)", not g.alive[1] and not g.live.has(1) and highest < Stage.WATER_Y - 1.0, "alive %s, highest piece %.2f m (water %.2f)" % [g.alive, highest, Stage.WATER_Y])
	# The water (the battery's stage is undressed, so on a sheet of its own): Golemheim's
	# living surface goes on the sea, and a body going in throws a splash.
	var sea := DelMarSea.new()
	add_child(sea)
	var sheet := MeshInstance3D.new()
	add_child(sheet)
	sea.dress(sheet, Stage.WATER_Y)
	sea.splash(110.0, 1.0)
	var sheet_mat := sheet.material_override as ShaderMaterial
	t("delmar: the sea wears the cheaper living water, and a fall splashes", sheet_mat != null and sheet_mat.shader != null and sheet_mat.shader.resource_path == DelMarSea.FAST_PATH and get_tree().get_nodes_in_group("splash_fx").size() > 0, get_tree().get_nodes_in_group("splash_fx").size())
	sea.queue_free()
	sheet.queue_free()
	# The floaties drift free on the climbers' plane; the buoy stands back out of their way.
	var fl: DelMarFloaties = st.floaties
	t("delmar: six floaties drift on the climbers' plane in the open water", fl != null and fl._items.size() == DelMarFloaties.COUNT and fl._items.all(func(it): return absf((it.node as Node3D).global_position.z) < 0.01 and float(it.x) >= Stage.FLOAT_X.x and float(it.x) <= Stage.FLOAT_X.y), fl._items.map(func(it): return snappedf(float(it.x), 0.1)) if fl != null else [])
	t("delmar: the buoy floats back behind the play plane, clear of every floatie", absf(st.buoy_body.global_position.z - Stage.BUOY_Z) < 0.01 and Stage.BUOY_Z < -1.5, st.buoy_body.global_position.z)
	# The clouds never pop (Parker 11-11): drifting past a real camera, a cloud only
	# ever jumps while every part of it is off screen, and lands off screen.
	var sky_root := Node3D.new()
	add_child(sky_root)
	var sky_cam := Camera3D.new()
	sky_root.add_child(sky_cam)
	sky_cam.position = Vector3(0, 6, 13)
	sky_cam.current = true
	var puff := Node3D.new()
	sky_root.add_child(puff)
	puff.position = Vector3(-30.0, 18.0, -80.0)
	var pops := 0
	var wraps := 0
	for k in 3000:
		var was := puff.position.x
		var seen_before := LuchaKit.cloud_seen(sky_cam, puff, was + 0.5, 8.0)  # where it would be
		LuchaKit.drift_cloud(puff, 0.5, 8.0, -30.0, 40.0, sky_cam)
		if puff.position.x < was:
			wraps += 1
			if seen_before or LuchaKit.cloud_seen(sky_cam, puff, puff.position.x, 8.0):
				pops += 1
	t("delmar: a drifting cloud wraps round only off screen (no popping in or out)", wraps > 0 and pops == 0, "wraps %d, seen %d" % [wraps, pops])
	sky_root.queue_free()
	fl._items[0].amp = 0.0  # hold this one still: it drifts out from under a test fall
	fl.tick(0.0)
	var spare := spawn(Vector2(float(fl._items[0].x), Stage.WATER_Y + 3.0))
	spare.release_all()
	await frames(1)
	var hit := -1
	for k in 60:
		for b in spare.bodies.values():
			(b as RigidBody3D).linear_velocity.y = minf((b as RigidBody3D).linear_velocity.y, -4.0)
		hit = fl.bounce(spare)
		if hit >= 0:
			break
		await get_tree().physics_frame
	var vv := Vector2.ZERO
	for b in spare.bodies.values():
		vv += Vector2((b as RigidBody3D).linear_velocity.x, (b as RigidBody3D).linear_velocity.y) * (b as RigidBody3D).mass
	vv /= spare.total_mass
	t("delmar: a fall onto a floatie throws you up and back toward the tower", hit >= 0 and vv.y > 2.5 and vv.x < -1.0, "hit %d, v (%.2f, %.2f)" % [hit, vv.x, vv.y])
	spare.remove()
	# STRONGER (Parker 11-11: "send you at least as far back up as you fell down"): a
	# plain fall from 5 m over a floatie comes back up at least that high.
	for drop_h in [3.0, 6.0]:
		var faller := spawn(Vector2(float(fl._items[0].x), Stage.WATER_Y + float(fl._items[0].kind[2]) + drop_h))
		faller.release_all()
		for l in faller.limbs:
			l.regrip = 99.0
		await frames(1)
		var start_y := faller.centre_of_mass().y
		var bounced := false
		var apex := -INF
		for k in int(8.0 * Engine.physics_ticks_per_second):
			await get_tree().physics_frame
			var com := faller.centre_of_mass()
			if not bounced:
				bounced = fl.bounce(faller) >= 0
				continue
			apex = maxf(apex, com.y)
			var vy := 0.0
			for b in faller.bodies.values():
				vy += (b as RigidBody3D).linear_velocity.y * (b as RigidBody3D).mass
			if vy < 0.0:
				break
		t("delmar: dropped %.0f m onto a floatie, you're thrown back at least as high as you fell from" % drop_h, bounced and apex >= start_y, "apex %.2f vs start %.2f" % [apex, start_y])
		faller.remove()
	# THE SQUASH: a hit dunks and flattens the floatie, then it springs back.
	fl._items[0].squash_t = 0.0
	var n0: Node3D = fl._items[0].node
	fl.tick(0.07)
	var flat := n0.scale.y
	fl.tick(2.0)
	t("delmar: a floatie that's hit squashes flat, then springs back", flat < 0.7 and absf(n0.scale.y - 1.0) < 0.01, "flat %.2f, back %.2f" % [flat, n0.scale.y])
	t("delmar: the floatie's boing is in the sound kit", Sound.SFX.has("floatie") and Sound.SFX.floatie.all(func(c): return ResourceLoader.exists("res://audio/sfx/%s.wav" % c)))
	g.end_match()
	await frames(2)
	t("delmar: after the match the pier is gone and the base is back on the canvas", not st.delmar and not is_instance_valid(st.delmar_root) and st.base_root.position.is_zero_approx())
	g.queue_free()
	await frames(2)


## THE LINE YOU CAN SEE (Parker 11-11: "there are times in both modes where my hand
## seems to be over the line but I cannot lock in"): a press a moment early still locks
## once over, a lock while Del Mar's rope glides is judged by the rope as drawn, and the
## line a lock must clear is what the string and rope cover on screen (Parker 11-11: the
## flags, rope and buoy stay where they were; only the invisible line follows the view).
func _run_lockline() -> void:
	var g := make_game("delmar", 2, 60.0, "plaza")
	if not await wait_phase(g, "round"):
		t("lockline: a round starts", false)
		return
	var st: Stage = g.stage
	var notes: Array = []
	g.announce.connect(func(text, _big): notes.append(str(text)))
	var c0: Climber = g.climbers[g.live[0]]
	var c1: Climber = g.climbers[g.live[1]]
	var d0 := g.bot_drivers[0] as Drivers.ScriptDriver
	var d1 := g.bot_drivers[1] as Drivers.ScriptDriver
	var r0 := _stand_on_base(c0, st, -0.3)
	var r1 := _stand_on_base(c1, st, 0.3)
	g.judge_by_view = false  # (1-3 test the press and the glide on the plain line; 4-5 the view)
	await frames(2)
	r0 = g.measure(c0)
	r1 = g.measure(c1)
	# 1. A press with the line out of reach: held for the buffer, then "get above".
	_set_line(g, r0 + 0.6, r0 + 0.6)
	d0.lock = true
	await frames(2)
	var held := g._lock_want.has(c0.climber_id) and c0.state == Climber.State.LIVE and not notes.has("Get above the line to lock in!")
	await seconds(Game.LOCK_BUFFER_S + 0.1)
	t("lockline: a press under the line waits a moment, then says get above", held and not g._lock_want.has(c0.climber_id) and notes.has("Get above the line to lock in!") and c0.state == Climber.State.LIVE, [held, notes])
	_set_line(g, r0 - 0.4, r0 - 0.4)
	await frames(3)
	t("lockline: ...and once it ran out, crossing later doesn't lock by itself", c0.state == Climber.State.LIVE)
	# 2. A press a hair before crossing: it locks the first tick you're over.
	_set_line(g, r0 + 0.6, r0 + 0.6)
	notes.clear()
	d0.lock = true
	await frames(6)  # 0.05 s under the line, the press waiting
	_set_line(g, r0 - 0.4, r0 - 0.4)
	await frames(3)
	t("lockline: a press just before crossing locks once you're over (no second press)", c0.state == Climber.State.FROZEN and not notes.has("Get above the line to lock in!"), [c0.state, notes])
	# 3. Del Mar's rope gliding out after a lock: judged by the rope as drawn.
	_set_line(g, r1 + 0.5, r1 + 0.5)
	d1.lock = true
	await frames(3)
	t("lockline: Del Mar: short of the drawn rope, refused", c1.state == Climber.State.LIVE)
	await seconds(Game.LOCK_BUFFER_S + 0.05)
	_set_line(g, r1 + 1.5, r1 - 0.4)  # the line moved out; the rope is still gliding behind
	d1.lock = true
	await frames(3)
	t("lockline: Del Mar: past the gliding rope as drawn (the line already further out), the lock is taken", c1.state == Climber.State.FROZEN, [c1.state, g.line, g._shown_line, r1])
	# 4. Del Mar: the rope as drawn, seen from the camera, IS the line.
	g.judge_by_view = true
	var worst := 0.0
	var shifted := 0.0
	for view in [Vector3(108.0, 3.0, 14.0), Vector3(99.0, 6.5, 9.0), Vector3(118.0, -0.5, 20.0)]:
		g.view_from = view
		var c: float = g.lock_line()
		var ends: Array = st.rope_ends(c)
		var a: Vector3 = ends[0]
		var b: Vector3 = ends[1]
		for sv in [0.2, 0.5, 0.8]:
			var pt: Vector3 = a + (b - a) * sv
			pt.y -= Stage.ROPE_SAG * (b - a).length() * 4.0 * sv * (1.0 - sv)
			var hit: Vector3 = view + (pt - view) * (view.z / (view.z - pt.z))  # where its sight line meets z = 0
			worst = maxf(worst, absf(g.lock_gap([Vector2(hit.x, hit.y)])))
			shifted = maxf(shifted, absf(hit.x + hit.y - c))
	t("lockline: Del Mar: a hand where the rope shows on screen is exactly on the line", worst < 0.005, "worst %.5f, the view moves it up to %.2f" % [worst, shifted])
	var ends0: Array = st.rope_ends(100.0)
	t("lockline: Del Mar: the rope, mast and buoy stay where they were (eyes behind the plane, the sag back)", Stage.ROPE_SAG > 0.0 and (ends0[1] as Vector3).is_equal_approx(Vector3(Stage.MAST_X, 100.0 - Stage.MAST_X, Stage.MAST_EYE_Z)) and is_equal_approx((ends0[0] as Vector3).z, Stage.BUOY_Z) and not ("view_from" in st))
	# 5. The plaza: a hand where the flag string shows on screen is exactly on the line.
	g.view_from = Vector3(1.0, 3.5, 12.0)
	g.shown_bar_y = g.line - 0.3  # (still gliding up to it)
	g.shown_bar_z = -0.45
	g.shown_bar_sag = LuchaUI.LINE_SAG
	var pworst := 0.0
	for sx in [-6.0, 0.0, 3.0]:
		var f: float = (sx + LuchaUI.LINE_HALF_W) / (2.0 * LuchaUI.LINE_HALF_W)
		var sp := Vector3(sx, g.shown_bar_y - LuchaUI.LINE_SAG * 4.0 * f * (1.0 - f), -0.45)
		var e: Vector3 = g.view_from
		var hit: Vector3 = e + (sp - e) * (e.z / (e.z - sp.z))
		pworst = maxf(pworst, absf(hit.y - g._seen_bar_y(hit.x)))
	t("lockline: the plaza: where the gliding, sagging flag string shows is the line", pworst < 0.002, "worst %.5f" % pworst)
	g.queue_free()
	await frames(2)


func _set_line(g: Game, true_line: float, shown: float) -> void:
	g.line = true_line
	g._shown_line = shown
	g._shown_line_v = 0.0


## Stand a climber on the base's top, dx from its middle, arms down; returns its reach.
func _stand_on_base(c: Climber, st: Stage, dx: float) -> float:
	c.release_all()
	for l in c.limbs:
		l.regrip = 99.0
	var p := c.pose()
	var low := INF
	var low_x := 0.0
	for i in Layout.ORDER.size():
		var k := 3 * i
		var y := -c.top_of(Layout.ORDER[i], Transform2D(p[k + 2] + PI, Vector2(0, -p[k + 1])))
		if y < low:
			low = y
			low_x = p[k]
	var spot := Vector2(st.base_root.position.x + dx, st.barrel_top)
	for k in range(0, p.size(), 3):
		p[k] += spot.x - low_x
		p[k + 1] += spot.y - low - 0.008
	c.apply_pose(p)
	return 0.0


## THE GROW-IN (Parker 11-10): a spawn grows from nothing at its feet over 0.3 s, held
## and not colliding meanwhile, then stands at full size; and its growing block pushes a
## climber standing on the spot out of the way instead of spawning inside it.
func _run_grow() -> void:
	Game.grow_spawns = true
	var g := make_game("scramble", 2, 60.0, "plaza")
	if not await wait_phase(g, "round"):
		t("grow: a round starts", false)
		Game.grow_spawns = false
		return
	var c0: Climber = g.climbers[g.live[0]]
	var pel: RigidBody3D = c0.bodies["pelvis"]
	var head: RigidBody3D = c0.bodies["head"]
	var feet_y := c0.spawn_at.y
	await frames(3)
	t("grow: a fresh climber starts small at its feet, held and passing through", c0.growing() and pel.freeze and pel.collision_layer == 0 and head.global_position.y - feet_y < 1.0, "head %.2f above the feet" % (head.global_position.y - feet_y))
	await seconds(0.4)
	t("grow: after 0.3 s it stands at full size, live and solid", not c0.growing() and not pel.freeze and pel.collision_layer == Climber.LAYER_LIVE and head.global_position.y - feet_y > 1.2, "head %.2f above the feet" % (head.global_position.y - feet_y))
	# Climber 1 respawns right where climber 0 stands: climber 0 is shoved aside.
	await seconds(0.6)
	var spot := c0.spawn_at
	var before := c0.centre_of_mass()
	g._rpc_spawn(1, 77, Vector2(before.x, spot.y), "Grower")
	await seconds(0.5)
	var c1: Climber = g.climbers.get(77)
	var after := c0.centre_of_mass()
	t("grow: a spawn on top of someone pushes them out of the way", c1 != null and not c1.growing() and absf(after.x - before.x) > 0.25, "moved %.2f m" % absf(after.x - before.x))
	g.queue_free()
	await frames(2)
	Game.grow_spawns = false


func _run_startingbase() -> void:
	var g := make_game("tower", 1, 60, "plaza", true)
	await wait_phase(g, "turn")
	var selected: String = g.stage.base_id
	t("base: host resolves random once", selected in Modes.STARTING_BASES and g.settings.resolved_base == selected)
	var resolved := {}
	for i in 24:
		g.host_start({"mode": "tower", "timer": 60.0, "stage": "plaza", "base": "random"}, g.roster)
		resolved[g.stage.base_id] = true
	t("base: random can choose every support", resolved.size() == Modes.STARTING_BASES.size())
	for choice in Modes.STARTING_BASES:
		g.host_start({"mode": "tower", "timer": 60.0, "stage": "plaza", "base": choice}, g.roster)
		await wait_phase(g, "turn")
		var support: Node3D = g.stage.base_root
		var highest: float = {"barrel": 2.016, "cactus": 1.796, "donkey": 2.117581, "bell": 2.20}[choice]
		t("base: forced choice uses matching support height", g.stage.base_id == choice and is_equal_approx(g.stage.barrel_top, highest) and is_equal_approx(g.stage.first_line, highest + Stage.FIRST_LINE_ABOVE), choice)
		t("base: support has live stage collisions", not g.stage.base_bodies.is_empty() and g.stage.base_bodies.all(func(b): return g.stage.bodies.has(b) and b.is_inside_tree()), choice)
		if choice == "donkey":
			await frames(2)
			var space := world.get_world_3d().direct_space_state
			var back_ray := PhysicsRayQueryParameters3D.create(Vector3(0,1.7,0), Vector3(0,0.6,0), Climber.LAYER_WORLD)
			var gap_ray := PhysicsRayQueryParameters3D.create(Vector3(-0.3,0.4,0), Vector3(0.15,0.4,0), Climber.LAYER_WORLD)
			t("base: donkey back supports climbing with an open gap below", not space.intersect_ray(back_ray).is_empty() and space.intersect_ray(gap_ray).is_empty())
			t("base: donkey remains stationary", g.stage.base_bodies.all(func(b): return b is StaticBody3D))
		g._next()
		t("base: a new turn keeps the same base", is_instance_valid(support) and g.stage.base_root == support and g.stage.base_id == choice, choice)
	g.end_match()
	g.queue_free()
	await frames(2)


func _run_classicdisconnect() -> void:
	var solo := make_game("scramble", 1, 50.0)
	t("Classic: refuses a solo match", solo.phase == "idle" and solo.roster.is_empty())
	solo.queue_free()
	for leaver in [1, 2]:
		var g := make_game("scramble", 4, 50.0)
		await wait_phase(g, "round", 5.0)
		g.roster[leaver].peer = 99
		await lift_and_lock(g, 0)
		g._on_peer_left(99)
		if leaver == 1:
			t("Classic: opponent disconnect completes a settled duel", g.phase == "between")
		else:
			t("Classic: spectator disconnect leaves the duel running", g.phase == "round")
			await lift_and_lock(g, 1)
		await wait_phase(g, "round", 5.0)
		t("Classic: rotation skips disconnected players", not g.round_players.has(leaver) and g.live_climbers().size() == 2)
		g.end_match()
		g.queue_free()
		await frames(2)


func _run_classicspawns() -> void:
	var g := make_game("scramble", 2, 50.0)
	g.host_start({"mode": "scramble", "timer": 50.0, "stage": "dock", "base": "barrel"}, g.roster)
	await wait_phase(g, "round", 5.0)
	var first := g._last_spawn_sides.duplicate()
	t("Classic spawns: first duel starts on opposite sides", first[0] == -first[1])
	for pid in [0, 1]:
		await lift_and_lock(g, pid)
	await wait_phase(g, "round", 5.0)
	t("Classic spawns: both entrants lock before rematch", g.round_n == 2)
	t("Classic spawns: rematch swaps each player's actual previous side", g._last_spawn_sides[0] == -first[0] and g._last_spawn_sides[1] == -first[1])
	g.set_physics_process(false)
	g._last_spawn_sides = {0: -1, 1: 1}
	t("Classic spawns: histories follow player IDs, not pair order", g._classic_spawn_sides([1, 0]) == [-1, 1])
	g._last_spawn_sides = {0: -1}
	t("Classic spawns: newcomer accommodates returning player's swap", g._classic_spawn_sides([0, 1]) == [1, -1] and g._classic_spawn_sides([1, 0]) == [-1, 1])
	for previous in [-1, 1]:
		g._last_spawn_sides = {0: previous, 1: previous}
		var seen := {}
		var opposite := true
		for attempt in 128:
			var sides := g._classic_spawn_sides([0, 1])
			seen[sides[0]] = true
			opposite = opposite and sides[0] == -sides[1]
		t("Classic spawns: same-side history randomly assigns opposite sides", opposite and seen.size() == 2)
	g._last_spawn_sides = {0: -1, 1: 1}
	g._spawn(0)
	var respawn: Climber = g.climbers[g.live[0]]
	t("Classic spawns: history records collision-resolved position", g._last_spawn_sides[0] == (-1 if respawn.spawn_at.x < 0 else 1))
	g.host_start(g.settings, g.roster)
	t("Classic spawns: new match clears previous sides", g._last_spawn_sides.is_empty())
	g.end_match()
	g.queue_free()

func _run_lockrecovery() -> void:
	var g := make_game("scramble", 2, 60.0)
	await wait_phase(g, "round")
	var locked: Climber = g.climbers[g.live[0]]
	var actor: Climber = g.climbers[g.live[1]]
	locked.release_all()
	actor.release_all()
	var chest: RigidBody3D = actor.bodies["chest"]
	chest.global_position = locked.bodies["chest"].global_position + Vector3(0.03, 0, 0)
	Climber.sync_server(chest)
	locked.freeze()
	g._snap_static(locked)
	var before := chest.global_position
	g._free_locked_overlaps(locked)
	t("lock recovery: overlapping live chest moves clear of frozen player", chest.global_position.distance_to(before) > 0.025)
	t("lock recovery: frozen player remains frozen", locked.state == Climber.State.FROZEN)
	g.end_match()
	g.queue_free()
	await frames(2)
func _run_personalcamera() -> void:
	var g := make_game("scramble", 2, 60.0)
	await wait_phase(g, "round")
	var mine: Climber = g.climbers[g.live[0]]
	var other: Climber = g.climbers[g.live[1]]
	other.owner_peer = 2
	for piece: RigidBody3D in other.bodies.values():
		piece.global_position += Vector3(0, 45, 0)
		Climber.sync_server(piece)
	var main = load("res://game/main.gd").new()
	# Exercise camera logic without starting another application scene.
	main.game = g
	main.cam = Camera3D.new()
	add_child(main.cam)
	main.line_bar = MeshInstance3D.new()
	add_child(main.line_bar)
	main.screen = "hud"
	var was_online := Net.online
	Net.online = true
	main._tick_camera(1.0)
	t("camera: distant online players get a personal view", main._personal_camera and absf(main._cam_target.y - mine.centre_of_mass().y) < 1.0)
	mine.freeze()
	main._tick_camera(1.0)
	t("camera: locked player follows the next active climber", absf(main._cam_target.y - other.centre_of_mass().y) < 1.0)
	Net.online = false
	main._tick_camera(1.0)
	t("camera: local matches retain shared camera", not main._personal_camera)
	Net.online = was_online
	main.cam.queue_free()
	main.line_bar.queue_free()
	main.free()
	g.end_match()
	g.queue_free()
	await frames(2)
func _run_waitingroom() -> void:
	var g := GameScript.new()
	g.world = world
	g.dress = false
	add_child(g)
	var guests := [{"pid": 32, "peer": 2, "slot": 0, "name": "Guest", "tint": Color.WHITE}]
	g._rpc_waiting_room(guests, {})
	t("lobby: new bell model is the waiting ring base", g.stage.base_id == "bell" and not g.stage.base_bodies.is_empty())
	t("lobby: authenticated guest appears without a host body", g.phase == "lobby" and g.climbers.size() == 1 and g.live.has(32))
	var first: Climber = g.climbers[32]
	var expanded := guests.duplicate()
	expanded.append({"pid": 48, "peer": 3, "slot": 0, "name": "Second", "tint": Color.WHITE})
	g._rpc_waiting_room(expanded, {})
	t("lobby: new guest preserves the first climber", g.climbers.size() == 2 and g.climbers[32] == first)
	g._rpc_waiting_room([expanded[1]], {})
	t("lobby: leaving guest is removed", g.climbers.size() == 1 and not g.live.has(32))
	g._rpc_start({"mode": "scramble", "stage": "plaza", "base": "barrel"}, expanded)
	t("lobby: match start clears waiting actors and button", g.phase == "between" and g.climbers.is_empty())
	g.end_match()
	g.queue_free()
	await frames(2)
func _run_waitinghost() -> void:
	var g := GameScript.new()
	g.name = "WaitingGame"
	g.world = world
	g.dress = false
	add_child(g)
	Net.members_changed.connect(g.sync_waiting_room)
	var peer := ENetMultiplayerPeer.new()
	assert(peer.create_server(7789, 12) == OK)
	Net.multiplayer.multiplayer_peer = peer
	Net._start_session_as_host()
	for tick in 1200:
		if Net.members.size() > 1 and not g.climbers.is_empty():
			break
		await frames(1)
	t("network lobby: host sees one fully joined guest", g.climbers.size() == 1 and g.phase == "lobby")
	if not g.climbers.is_empty():
		var c: Climber = g.climbers.values()[0]
		t("network lobby: host remains a spectator", c.owner_peer != 1)
		await seconds(2.0)
		t("network lobby: guest pose reaches host", g._last_seq.has(c.climber_id))
		Net.set_in_match(true)
		g.host_start(Net.settings.duplicate(), Net.build_roster())
		await wait_phase(g, "round", 5.0)
		t("network lobby: host starts match without ready menus", g.phase == "round" and g.live_climbers().size() == 2)
		await seconds(2.0)
	Net.members_changed.disconnect(g.sync_waiting_room)
	g.end_match()
	Net.leave()
	g.queue_free()
	await frames(2)


func _run_waitingclient() -> void:
	var g := GameScript.new()
	g.name = "WaitingGame"
	g.world = world
	g.dress = false
	add_child(g)
	var peer := ENetMultiplayerPeer.new()
	assert(peer.create_client("127.0.0.1", 7789) == OK)
	Net.multiplayer.multiplayer_peer = peer
	await wait_phase(g, "lobby", 10.0)
	t("network lobby: guest enters waiting ring", g.phase == "lobby" and g.climbers.size() == 1)
	if not g.climbers.is_empty():
		var c: Climber = g.climbers.values()[0]
		t("network lobby: guest owns playable limbs", c.state == Climber.State.LIVE and c.driver is Drivers.LocalDriver)
		c.bodies["chest"].apply_central_impulse(Vector3(25, 0, 0))
		await wait_phase(g, "round", 8.0)
		t("network lobby: guest transitions to match", g.phase == "round")
		await seconds(1.0)
	g.end_match()
	Net.leave()
	g.queue_free()
	await frames(2)
func _run_joinrecovery() -> void:
	var messages: Array[String] = []
	var capture := func(message: String): messages.append(message)
	Net.status.connect(capture)
	Net._pending_lobby = true
	Net._joining_lobby = 42
	Net._join_started_ms = Time.get_ticks_msec()
	Net.join_steam(42)
	t("join: duplicate attempt reports progress instead of silently returning", not messages.is_empty())
	Net._join_started_ms = Time.get_ticks_msec() - Net.JOIN_TIMEOUT_MS - 1
	Net._process(0.0)
	t("join: stalled attempt releases pending state for retry", not Net._pending_lobby and Net._joining_lobby == 0 and not Net.online)
	Net._awaiting_accept = true
	Net._pending_lobby = true
	Net._joining_lobby = 42
	Net._rpc_members({Net.me(): {"name": "Accepted", "players": [], "ready": false}})
	t("join: host membership acceptance completes the join", Net.online and not Net._pending_lobby and not Net._awaiting_accept)
	Net.leave()
	Net.status.disconnect(capture)
## THE INPUT LAW (the 11-10 rewrite, after a client's pad "randomly stopped working"):
## each protection in core/players.gd and core/steam_input.gd, proven on fake and
## synthetic devices. No single thing may silence a player.
func _run_input() -> void:
	await _run_hotswap()  # (hot swapping is part of every input run)
	var cam := Camera3D.new()
	cam.position = Vector3(0, 2, 10)
	add_child(cam)
	Players.camera = cam
	Players.fake.clear()
	Players.clear_players()
	Players.add_player(Players.ANY)
	Players.fake[1000] = {"buttons": {}, "stick": Vector2.ZERO}
	Players.fake[1001] = {"buttons": {}, "stick": Vector2.ZERO}
	# 1. The ANY slot reads everything at once.
	Players.fake[1001].buttons = {"leg_r": true}
	t("input: the one-player slot reads every pad on the machine at once", Players.limb_held(0, 3) and not Players.limb_held(0, 0))
	Players.fake[1001].buttons = {}
	# 2. Nothing "spoke last" can take a pad player's controls: a key press (push to
	#    talk), a mouse move.
	Players.fake[1000].buttons = {"arm_l": true}
	Players.fake[1000].stick = Vector2(0.9, 0.0)
	var key := InputEventKey.new()
	key.physical_keycode = KEY_V
	key.keycode = KEY_V
	key.pressed = true
	Input.parse_input_event(key)
	var mm := InputEventMouseMotion.new()
	mm.relative = Vector2(40, 0)
	Input.parse_input_event(mm)
	Input.flush_buffered_events()
	var aim = Players.limb_aim(0, null, 0)
	t("input: a key press and a mouse move don't take a pad player's aim (glyphs may flip, reads don't)", Players.last_device == Players.KBM and Players.limb_held(0, 0) and aim is Dictionary and aim.has("dir") and aim.dir.x > 0.9, [Players.last_device, aim])
	key = key.duplicate()
	key.pressed = false
	Input.parse_input_event(key)
	Input.flush_buffered_events()
	# 3. A keyboard player is never steered by a second pad's drifting stick.
	Players.fake[1000].buttons = {}
	Players.fake[1000].stick = Vector2(0.45, 0.1)  # drift, past the deadzone
	var ka := InputEventKey.new()
	ka.physical_keycode = int(Players.binds.kbm.arm_l[0].key)
	ka.keycode = ka.physical_keycode
	ka.pressed = true
	Input.parse_input_event(ka)
	Input.flush_buffered_events()
	await frames(2)
	aim = Players.limb_aim(0, null, 0)
	t("input: a limb held by a key is aimed by the mouse, never by a pad's drifting stick", Players.limb_held(0, 0) and aim is Dictionary and aim.has("point"), aim)
	# ...and held on both, the pad's stick has it.
	Players.fake[1000].buttons = {"arm_l": true}
	aim = Players.limb_aim(0, null, 0)
	t("input: held on a pad as well, that pad's stick aims it", aim is Dictionary and aim.has("dir"))
	ka = ka.duplicate()
	ka.pressed = false
	Input.parse_input_event(ka)
	Input.flush_buffered_events()
	Players.fake[1000].buttons = {}
	Players.fake[1000].stick = Vector2.ZERO
	await frames(2)
	# 4. THE LATCH: a press and release inside one frame is still seen by one tick.
	var jb := InputEventJoypadButton.new()
	jb.device = 7
	jb.button_index = int(Players.binds.pad.arm_l[0].pad)
	jb.pressed = true
	Input.parse_input_event(jb.duplicate())
	var up := jb.duplicate()
	up.pressed = false
	Input.parse_input_event(up.duplicate())
	Input.flush_buffered_events()
	var godot_says := Input.is_joy_button_pressed(7, jb.button_index)
	await get_tree().physics_frame  # (we run before Players each tick: it latched in the tick just gone)
	var latched := Players.limb_held(0, 0)
	await get_tree().physics_frame
	t("input: a tap shorter than a frame is latched for exactly one physics tick", not godot_says and latched and not Players.limb_held(0, 0), [godot_says, latched])
	# 5. THE STALE GUARD: what a raw pad held when Steam took it never reads as held.
	Input.parse_input_event(jb.duplicate())
	var axis := InputEventJoypadMotion.new()
	axis.device = 7
	axis.axis = JOY_AXIS_LEFT_X
	axis.axis_value = 0.8
	Input.parse_input_event(axis)
	Input.flush_buffered_events()
	await frames(3)
	var before := Players.limb_held(0, 0) and Players.stick(7).x > 0.7
	Players.suspect_raw("the battery's Steam took the pad")
	var stale_ignored := not Players.limb_held(0, 0) and Players.stick(7) == Vector2.ZERO and Input.is_joy_button_pressed(7, jb.button_index)
	t("input: a button and stick down when Steam takes the pad are ignored (Godot still says held)", before and stale_ignored, [before, stale_ignored])
	# The pad speaks again (it wasn't taken after all): it carries straight on.
	axis = axis.duplicate()
	axis.axis_value = 0.6
	Input.parse_input_event(axis)
	Input.parse_input_event(up.duplicate())
	Input.parse_input_event(jb.duplicate())
	Input.flush_buffered_events()
	await frames(3)
	t("input: a pad that speaks again is live again at once", Players.limb_held(0, 0) and is_equal_approx(Players.stick(7).x, 0.6), [Players.limb_held(0, 0), Players.stick(7)])
	Input.parse_input_event(up.duplicate())
	axis = axis.duplicate()
	axis.axis_value = 0.0
	Input.parse_input_event(axis)
	Input.flush_buffered_events()
	Players._on_joy_connection_changed(7, false)
	await frames(3)
	# 6. STEAM'S HOLD: an action going "inactive" for a blink never drops a held limb.
	var si := preload("res://core/steam_input.gd").new()
	var d := {"buttons": {}, "stick": Vector2.ZERO}
	si.devices[3000] = d
	var pressed_edge := si.feed_digital(d, "arm_r", true, true, 1000)
	si.feed_steer(d, true, Vector2(0.0, 0.9), 1000)
	si.feed_flags(3000, d, true, true, 1000)
	si.feed_digital(d, "arm_r", false, false, 1100)  # the blink: Steam says "inactive"
	si.feed_steer(d, false, Vector2.ZERO, 1100)
	si.feed_flags(3000, d, false, false, 1100)
	var through_blink := si.button(3000, "arm_r") and si.stick(3000).y > 0.8 and bool(d.gameplay_active)
	si.feed_digital(d, "arm_r", true, true, 1150)  # back
	var still := si.button(3000, "arm_r")
	si.feed_digital(d, "arm_r", false, false, 1160)
	si.feed_digital(d, "arm_r", false, false, 1160 + si.HOLD_MS + 20)  # really gone: it lets go
	si.feed_steer(d, false, Vector2.ZERO, 1160 + si.HOLD_MS + 20)
	si.feed_flags(3000, d, false, false, 1160 + si.HOLD_MS + 20)
	var let_go := not si.button(3000, "arm_r") and si.stick(3000) == Vector2.ZERO
	var live_kept := bool(d.gameplay_active)
	si.feed_flags(3000, d, false, false, 1150 + si.LIVE_MS + 500)
	t("input: Steam's one-frame 'inactive' blink doesn't drop a held limb or the stick", pressed_edge and through_blink and still, [pressed_edge, through_blink, still])
	t("input: an action really gone is released after the hold, and the layout's 'live' flag outlasts a blink", let_go and live_kept and not bool(d.gameplay_active), [let_go, live_kept, d.gameplay_active])
	# Steam's own latch: a press between two physics ticks.
	var d2 := {"buttons": {}, "stick": Vector2.ZERO}
	si.devices[3001] = d2
	si.feed_digital(d2, "lock", true, true, 5000)
	si.feed_digital(d2, "lock", true, false, 5008)  # up again before any physics tick
	si.tick_latch()
	var seen_once := si.button(3001, "lock")
	si.tick_latch()
	t("input: a Steam press between two physics ticks is seen by exactly one", seen_once and not si.button(3001, "lock"))
	si.free()
	# 7. THE DRIVER'S SLOT: a climber this machine owns always has a driver.
	Players.clear_players()
	var made := Players.resolve_slot(3, 0)
	t("input: a machine with no local player gets one when a climber needs a driver", made == 0 and Players.slots.size() == 1 and int(Players.slots[0].device) == Players.ANY)
	Players.fake[1000].buttons = {"leg_l": true}
	t("input: a slot index that doesn't exist reads the whole machine (one local player)", Players.limb_held(5, 2) and Players.resolve_slot(5, 0) == 0)
	Players.fake[1000].buttons = {"lock": true}
	await frames(2)
	t("input: ...and its Lock In edge arrives too", Players.lock_pressed(5) and not Players.lock_pressed(5))
	Players.fake[1000].buttons = {}
	# 8. The window's focus is known (main shows the notice), and the log has it all.
	Players._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	var lost := not Players.focused
	Players._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	t("input: losing the window's focus is noticed and logged", lost and Players.focused and Players.health().contains("PLAYER 1") and FileAccess.file_exists(Players.LOG_PATH) and Players._log.any(func(l): return str(l).contains("LOST FOCUS")))
	Players.fake.clear()
	Players.clear_players()
	Players.camera = null
	cam.queue_free()
	# 8b. NO GHOSTS: a piece whose climber is gone must not silence a climber that
	#     touches it (the typed read of the freed climber was a script error inside
	#     the tick: no grabs, no "touching the ground", no steering).
	var floor := static_box(Vector2(0, -0.5), Vector2(6, 0.5))
	var alive := spawn(Vector2(0, 0.05))
	await seconds(0.6)
	var stood := alive.touches_solid()
	var dead: Climber = ClimberScript.new()
	dead.climber_id = 9001
	add_child(dead)
	var ghost := RigidBody3D.new()
	var gcol := CollisionShape3D.new()
	var gshape := SphereShape3D.new()
	gshape.radius = 0.25
	gcol.shape = gshape
	ghost.add_child(gcol)
	ghost.collision_layer = Climber.LAYER_LIVE
	ghost.collision_mask = 0
	ghost.freeze = true
	ghost.set_meta("climber", dead)
	ghost.set_meta("piece", "torso")
	world.add_child(ghost)
	ghost.global_position = alive.bodies["hand_l"].global_position
	Climber.sync_server(ghost)
	dead.free()  # the climber is gone; its piece stands in the world with its name on it
	await frames(6)
	var touching_ghost: bool = (alive.bodies["hand_l"] as RigidBody3D).get_colliding_bodies().has(ghost)
	t("ghosts: a piece whose climber is gone reads as nobody's (no error)", Climber.climber_of(ghost) == null and Climber.is_ghost(ghost) and not Climber.is_ghost(floor))
	(alive.driver as Drivers.ScriptDriver).set_limb(1, true, Vector2.UP)
	await frames(4)
	t("ghosts: a climber touching one still stands, grabs and steers", stood and touching_ghost and alive.touches_solid() and alive.active_limb() == 1 and alive.limbs[0].grab_other != ghost, [stood, touching_ghost, alive.touches_solid(), alive.active_limb()])
	# A climber freed any way but remove() takes its pieces with it.
	var doomed := spawn(Vector2(4, 0.05))
	var pieces: Array = doomed.bodies.values()
	doomed.free()
	await frames(2)
	t("ghosts: a climber freed under the game leaves no pieces behind", pieces.all(func(b): return not is_instance_valid(b)))
	alive.remove()
	ghost.queue_free()
	floor.queue_free()
	await frames(2)
	# 9. TWENTY: the lobby takes twenty climbers and no more, a 20-player match starts,
	#    and the waiting room's stream slows to keep the host's load level.
	Net.members.clear()
	for i in 19:
		Net.members[i + 1] = {"name": "M%d" % i, "players": [{"name": "P%d" % i, "tint": Color.WHITE, "slot": 0}], "ready": true}
	t("twenty: a lobby of 19 takes a 20th climber and refuses a 21st", Net.MAX_CLIMBERS == 20 and Net.MAX_MACHINES == 20 and Net.can_fit_players(99, 1) and not Net.can_fit_players(99, 2))
	t("twenty: the roster for 19 machines has 19 climbers, each on its own machine's slot 0", Net.build_roster().size() == 19 and Net.build_roster().all(func(r): return int(r.slot) == 0))
	Net.members.clear()
	var g := make_game("tower", 20, 30.0, "plaza")
	t("twenty: a 20-player Tower match starts", await wait_phase(g, "turn") and g.roster.size() == 20)
	t("twenty: one live climber streams at the full rate", is_equal_approx(g.stream_hz(), Game.STREAM_HZ))
	g.queue_free()
	await frames(2)
	var g2 := make_game("scramble", 20, 30.0, "plaza")
	t("twenty: a 20-player Classic starts its first one-versus-one", await wait_phase(g2, "round") and g2.live.size() == 2, g2.live.size())
	# Twenty moving at once (the waiting room): the rate falls to the floor.
	for k in 18:
		g2._rpc_spawn(2 + k if g2.roster.size() > 2 + k else 0, 500 + k, Vector2(-7.0 + 0.7 * k, 0.05), "W%d" % k)
	await frames(2)
	var moving := g2.climbers.values().filter(func(c): return c.state != Climber.State.FROZEN).size()
	t("twenty: with twenty moving climbers the stream falls to %d a second" % int(Game.STREAM_MIN_HZ), moving >= 20 and is_equal_approx(g2.stream_hz(), Game.STREAM_MIN_HZ), [moving, g2.stream_hz()])
	g2.queue_free()
	await frames(2)


## OUT COLD, STILL BOUNCED (Parker 11-10: "knocked out climbers should bounce off the
## ropes and the floating things in Del Mar"): knocked out and thrown at the ring ropes,
## the climber comes back; knocked out and dropped on a floatie, it's thrown up.
func _run_korope() -> void:
	var g := make_game("tower", 1, 60.0, "plaza")
	if not await wait_phase(g, "turn", 10.0):
		t("korope: a turn starts", false)
		return
	var c: Climber = g.live_climbers()[0]
	await seconds(0.6)
	c.release_all()
	c._impact_guard = 0.0
	c.knock_out()
	var shift_ko := Vector3(7.6 - c.centre_of_mass().x, 0.4, 0.0)
	for b in c.bodies.values():
		var rb := b as RigidBody3D
		rb.global_position += shift_ko
		Climber.sync_server(rb)
		rb.linear_velocity = Vector3(4.0, 0.0, 0.0)
	var was_out := c.knockout_left > 0.0
	var back_ko := 0.0
	for k in int(0.8 * Engine.physics_ticks_per_second):
		await get_tree().physics_frame
		var v := Vector2.ZERO
		for b in c.bodies.values():
			v += Vector2(b.linear_velocity.x, b.linear_velocity.y) * b.mass
		back_ko = minf(back_ko, v.x / c.total_mass)
	t("korope: a knocked-out climber bounces off the ring ropes", was_out and back_ko < -3.0 and c.centre_of_mass().x < Climber.rope_x, "back at %.2f m/s, x %.2f" % [back_ko, c.centre_of_mass().x])
	g.end_match()
	g.queue_free()
	await frames(2)
	# The floaties: a knocked-out climber falling onto one is thrown up like anyone.
	var fl := DelMarFloaties.new()
	add_child(fl)
	fl.setup(5, Stage.WATER_Y, 104.5, 135.0)
	fl.tick(0.0)
	var k2 := spawn(Vector2(float(fl._items[0].x), Stage.WATER_Y + 0.6))
	k2._impact_guard = 0.0
	k2.knock_out()
	for b in k2.bodies.values():
		(b as RigidBody3D).linear_velocity = Vector3(0, -4.0, 0)
	var hit := -1
	for k in 40:
		await get_tree().physics_frame
		hit = fl.bounce(k2)
		if hit >= 0:
			break
	var up := 0.0
	for b in k2.bodies.values():
		up += (b as RigidBody3D).linear_velocity.y * (b as RigidBody3D).mass
	t("korope: a knocked-out climber bounces off a floatie", k2.knockout_left > 0.0 and hit >= 0 and up / k2.total_mass > 2.0, "hit %d, up %.2f m/s" % [hit, up / k2.total_mass])
	k2.remove()
	fl.queue_free()
	await frames(2)


## HOT SWAPPING (Parker 11-11: "some games are weird and dont let you hot swap
## between a newly plugged in controller and your keyboard. Make sure we can"). The
## one-player slot (Practice, and every player online) on a pad plugged in mid-session,
## mid-hold, unplugged mid-hold, and back on the keyboard, with the glyphs following.
func _run_hotswap() -> void:
	var cam := Camera3D.new()
	cam.position = Vector3(0, 2, 10)
	add_child(cam)
	Players.camera = cam
	Players.fake.clear()
	Players.clear_players()
	Players.add_online_player("Hot Swapper")  # the online player: the ANY slot
	Players.prepare_online("Hot Swapper")
	t("hotswap: the online player reads every device (one slot, ANY)", Players.slots.size() == 1 and int(Players.slots[0].device) == Players.ANY)
	var arm_l_key := int(Players.binds.kbm.arm_l[0].key)
	var press := func(code: int, down: bool) -> void:
		var e := InputEventKey.new()
		e.physical_keycode = code
		e.keycode = code
		e.pressed = down
		Input.parse_input_event(e)
		Input.flush_buffered_events()
	# 1. On the keyboard, no pad on the machine.
	press.call(arm_l_key, true)
	await frames(2)
	var aim = Players.limb_aim(0, null, 0)
	t("hotswap: keyboard first: the key holds the hand, the mouse aims it", Players.limb_held(0, 0) and aim is Dictionary and aim.has("point"), aim)
	# 2. A pad is plugged in MID-HOLD and grabs the same hand: its stick takes the
	#    hand that very frame (the pad list is rebuilt when the count moves).
	Players.fake[1005] = {"buttons": {"arm_l": true}, "stick": Vector2(0.0, 0.95)}
	aim = Players.limb_aim(0, null, 0)
	t("hotswap: a pad plugged in mid-hold steers the hand at once", Players.limb_held(0, 0) and aim is Dictionary and aim.has("dir") and aim.dir.y > 0.9, aim)
	# 3. The key lets go while the pad still holds: the hand never drops.
	press.call(arm_l_key, false)
	await frames(2)
	t("hotswap: the key letting go doesn't drop a hand the pad holds", Players.limb_held(0, 0) and Players.limb_aim(0, null, 0).has("dir"))
	# 4. Every limb and Lock In work from the new pad.
	Players.fake[1005].buttons = {"arm_r": true, "leg_l": true, "leg_r": true}
	var all_limbs: bool = not Players.limb_held(0, 0) and Players.limb_held(0, 1) and Players.limb_held(0, 2) and Players.limb_held(0, 3)
	Players.fake[1005].buttons = {}
	await frames(2)
	Players.lock_pressed(0)  # (drop anything queued)
	Players.fake[1005].buttons = {"lock": true}
	await frames(2)
	var locked := Players.lock_pressed(0)
	Players.fake[1005].buttons = {}
	await frames(2)
	t("hotswap: every limb and Lock In work from the newly plugged pad", all_limbs and locked, [all_limbs, locked])
	# 5. Back to the keyboard with the pad still plugged in and its stick resting off
	#    centre: the key's hand is aimed by the mouse, and Lock In works from the keyboard.
	Players.fake[1005].stick = Vector2(0.4, 0.2)
	press.call(arm_l_key, true)
	await frames(2)
	aim = Players.limb_aim(0, null, 0)
	t("hotswap: back on the keyboard, the mouse aims (the resting pad doesn't)", Players.limb_held(0, 0) and aim is Dictionary and aim.has("point"), aim)
	press.call(arm_l_key, false)
	await frames(2)
	Players.lock_pressed(0)
	press.call(int(Players.binds.kbm.lock[0].key), true)
	await frames(2)
	var kb_lock := Players.lock_pressed(0)
	press.call(int(Players.binds.kbm.lock[0].key), false)
	await frames(2)
	t("hotswap: Lock In from the keyboard with a pad plugged in", kb_lock)
	# 6. Unplugged MID-HOLD while the key holds the same hand: no error, the hand stays
	#    held, the mouse takes the aim back.
	press.call(arm_l_key, true)
	Players.fake[1005].buttons = {"arm_l": true}
	await frames(2)
	Players.fake.erase(1005)
	aim = Players.limb_aim(0, null, 0)
	t("hotswap: the pad unplugged mid-hold leaves the key's hand held, the mouse aiming", Players.limb_held(0, 0) and aim is Dictionary and aim.has("point"), aim)
	press.call(arm_l_key, false)
	await frames(2)
	t("hotswap: ...and let go, nothing is left held", not Players.limb_held(0, 0) and not Players.limb_held(0, 1))
	# 7. A REAL raw pad appearing (Godot's connect signal and its first events) never
	#    makes a second player or turns the online player into a pad-only one.
	Players._on_joy_connection_changed(6, true)
	var jb := InputEventJoypadButton.new()
	jb.device = 6
	jb.button_index = int(Players.binds.pad.arm_r[0].pad)
	jb.pressed = true
	Input.parse_input_event(jb.duplicate())
	Input.flush_buffered_events()
	await frames(2)
	var raw_holds := Players.limb_held(0, 1)
	var glyph_dev := Players.effective_device(0)
	var pad_glyphs := Glyphs.limb_glyphs(0)
	jb.pressed = false
	Input.parse_input_event(jb.duplicate())
	Input.flush_buffered_events()
	await frames(2)
	t("hotswap: a raw pad plugged in mid-session drives the online player at once", raw_holds and Players.slots.size() == 1 and int(Players.slots[0].device) == Players.ANY, [raw_holds, Players.slots.size()])
	# (The left hand: X on the pad, A on the keys. The pad's right hand is A too.)
	t("hotswap: the glyphs switch to the pad's buttons on its first press", glyph_dev == 6 and str(pad_glyphs[0].text) == Players.bind_label(Players.binds.pad.arm_l[0]) and str(pad_glyphs[0].text) != Players.bind_label(Players.binds.kbm.arm_l[0]), [glyph_dev, pad_glyphs[0].text])
	press.call(arm_l_key, true)
	await frames(2)
	var kbm_glyphs := Glyphs.limb_glyphs(0)
	press.call(arm_l_key, false)
	await frames(2)
	t("hotswap: ...and back to the keys' letters on a key press", Players.effective_device(0) == Players.KBM and str(kbm_glyphs[0].text) == Players.bind_label(Players.binds.kbm.arm_l[0]), kbm_glyphs[0].text)
	Players._on_joy_connection_changed(6, false)
	t("hotswap: the raw pad unplugged leaves the online player whole (still ANY, not 'disconnected')", Players.slots.size() == 1 and int(Players.slots[0].device) == Players.ANY and not Players.slots[0].get("disconnected", false))
	# 8. A Steam controller appearing mid-session (Steam lists them twice a second)
	#    is read by the one-player slot too: the battery fakes its device entry.
	var si = Net.steam_input
	var stand_in: bool = si == null  # (--no-steam: a bare Steam Input with no Steam behind it)
	if stand_in:
		si = load("res://core/steam_input.gd").new()
		Net.steam_input = si
	if si != null:
		si.devices[3007] = {"buttons": {"arm_l": true}, "stick": Vector2(0.9, 0.0), "gameplay_active": true, "menu_active": true}
		aim = Players.limb_aim(0, null, 0)
		var steam_holds := Players.limb_held(0, 0)
		si.devices.erase(3007)
		t("hotswap: a Steam controller appearing mid-session holds and steers", steam_holds and aim is Dictionary and aim.has("dir"), [steam_holds, aim])
	if stand_in:
		Net.steam_input = null
		si.free()
	Players.fake.clear()
	Players.clear_players()
	cam.queue_free()


func _run_inputreconnect() -> void:
	var cleaned := Net._clean_players([{"name": "Steam Guest", "random": true, "slot": 0}])
	t("names: host preserves guest randomized character flag", cleaned[0].random)
	t("names: explicit custom name remains supported", not Net._clean_players([{"name": "Custom", "random": false}])[0].random)
	Players.clear_players()
	Players.add_player(0, "Pad player")
	Players.add_player(1, "Other pad")
	Players._pause_edge[0] = true
	Players._on_joy_connection_changed(0, false)
	t("input: disconnect clears queued pause press", not Players.pause_pressed(0))
	Players._on_joy_connection_changed(2, true)
	t("input: reconnect under new ID restores original player", Players.slots[0].device == 2 and Players.slots[1].device == 1)
	Players._pause_edge[1] = true
	Players.remove_player(0)
	t("input: removing a slot clears stale pause indexes", not Players.pause_pressed(0) and not Players.pause_pressed(1))
	Players.clear_players()
	Players.add_player(Players.ANY)
	Players.fake[1000] = {"buttons": {}, "stick": Vector2.RIGHT}
	Players.last_device = Players.KBM
	# (the 11-10 input law: who HOLDS a limb aims it; "who spoke last" only picks glyphs)
	var idle = Players.limb_aim(0, null, 0)
	t("input: an idle controller's stick is still read (nothing is switched off by the last device)", Players.stick(Players.ANY) == Vector2.RIGHT and idle is Dictionary and idle.has("dir"))
	Players.fake[1000].buttons = {"arm_l": true}
	var held = Players.limb_aim(0, null, 0)
	t("input: a limb held on the pad is aimed by that pad's stick whatever spoke last", held is Dictionary and held.has("dir") and held.dir == Vector2.RIGHT)
	Players.fake.erase(1000)
	Players.clear_players()
func _run_chairbodyhits() -> void:
	var g := make_game("practice", 1, 60.0, "plaza", true)
	await wait_phase(g, "turn")
	var victim: Climber = g.partner
	for piece_name in victim.bodies:
		if piece_name == "head":
			continue
		g.chair.set_hit_count(0)
		var piece: RigidBody3D = victim.bodies[piece_name]
		var hit := {"piece": piece_name, "offset": Vector3.ZERO, "impulse": Vector3.RIGHT * piece.mass * 9.0, "speed": 8.0}
		g._apply_chair_hits({-2: hit})
		t("chair: heavy hit to %s damages chair without knockout" % piece_name, g.chair.hit_count == 1 and victim.knockout_left == 0)
		hit.speed = 3.0
		g._apply_chair_hits({-2: hit})
		t("chair: light hit to %s preserves durability" % piece_name, g.chair.hit_count == 1 and victim.knockout_left == 0)
	var head: RigidBody3D = victim.bodies["head"]
	g._apply_chair_hits({-2: {"piece": "head", "offset": Vector3.ZERO, "impulse": Vector3.RIGHT * head.mass * 9.0, "speed": 8.0}})
	t("chair: heavy head hit still damages chair and knocks out victim", g.chair.hit_count == 2 and victim.knockout_left > 0)
	g.end_match()
	g.queue_free()
	await frames(2)

func _run_kostars() -> void:
	var g := make_game("practice", 1, 50.0, "plaza", true)
	await wait_phase(g, "turn")
	var c: Climber = g.partner
	var head: RigidBody3D = c.bodies["head"]
	var events := [0]
	c.knocked_out.connect(func(): events[0] += 1)
	g._chair_impact(c, "head", Vector3.ZERO, Vector3.RIGHT * head.mass * 5)
	t("KO stars: head hit shows six atlas stars immediately", is_instance_valid(c.knockout_stars) and c.knockout_stars.visible and c.knockout_stars.stars.size() == 6)
	var halo = c.knockout_stars
	var first: Vector3 = halo.stars[0].position
	halo._process(.2)
	t("KO stars: carousel advances", first.distance_to(halo.stars[0].position) > .05)
	c.set_physics_process(false)
	t("KO stars: begin invisible at individual orbit positions", halo.stars.all(func(star): return not star.visible) and halo.stars[0].position.length() > .1)
	c._physics_process(.15)
	t("KO stars: grow halfway in 0.15 seconds", is_equal_approx(halo.stars[0].scale.x, c.body_scale * .85 * .5))
	c._physics_process(.15)
	t("KO stars: reach 15 percent smaller full size at 0.3 seconds", is_equal_approx(halo.stars[0].scale.x, c.body_scale * .85))
	c._physics_process(.3)
	var remaining := c.knockout_left
	var guard := c._impact_guard
	for i in 8:
		g._chair_impact(c, "head", Vector3.ZERO, Vector3.RIGHT * head.mass * 6)
	t("KO: repeated chair hits cannot refresh timer or guard", c.knockout_left == remaining and c._impact_guard == guard and events[0] == 1)
	c._physics_process(remaining - .3)
	t("KO stars: hold full size until last 0.3 seconds", is_equal_approx(halo.stars[0].scale.x, c.body_scale * .85))
	c._physics_process(.15)
	t("KO stars: shrink halfway with 0.15 seconds left", is_equal_approx(halo.stars[0].scale.x, c.body_scale * .85 * .5))
	c._physics_process(c.knockout_left)
	t("KO stars: disappear on exact wake tick", c.knockout_left == 0 and not halo.visible)
	c._physics_process(.81)
	g._chair_impact(c, "head", Vector3.ZERO, Vector3.RIGHT * head.mass * 5)
	t("KO: new knockout allowed after waking and recovery guard", c.knockout_left == Climber.KNOCKOUT_DURATION and halo.visible and events[0] == 2)
	head.global_position += Vector3(1,2,0)
	head.rotation.z = PI
	halo._process(0)
	t("KO stars: follow fallen head while staying world upright", halo.global_position.y > head.global_position.y and halo.global_basis.is_equal_approx(Basis.IDENTITY))
	c.freeze()
	t("KO stars: freeze removes halo", not halo.visible)
	g.end_match()
	g.queue_free()
	await frames(2)


func _run_donkey() -> void:
	var g := make_game("tower", 1, 60, "plaza", true)
	g.host_start({"mode": "tower", "timer": 60.0, "stage": "plaza", "base": "donkey"}, g.roster)
	await wait_phase(g, "turn")
	t("donkey: collision hulls activate contact trigger", g.stage.base_bodies.all(func(b): return b.has_meta("donkey_voice")))
	var head: MeshInstance3D = g.stage.base_root.find_child("head", true, false)
	t("donkey: sound origin matches visible head", head != null and g.stage.base_root.to_global(g.stage.donkey_head).distance_to(head.to_global(head.mesh.get_aabb().get_center())) < 0.001)
	t("donkey: contact cooldown prevents repeated rolls", g._donkey_contact_ready("test") and not g._donkey_contact_ready("test"))
	t("donkey: chance is ten percent", is_equal_approx(g.DONKEY_CHANCE, 0.10))
	for clip in Sound.SFX["donkey"]:
		g._play_donkey(clip)
		var voices := g.stage.base_root.get_children().filter(func(n): return n is AudioStreamPlayer3D and n.stream.resource_path.contains(clip))
		t("donkey: approved clip plays once from head", voices.size() == 1 and voices[0].playing and voices[0].global_position.distance_to(g.stage.base_root.to_global(g.stage.donkey_head)) < 0.001, clip)
		var active: AudioStreamPlayer3D = g._donkey_voice
		g._play_donkey(clip, true)
		t("donkey: repeated proc cannot overlap or interrupt", g._donkey_voice == active and not g._donkey_contact_ready("busy"))
		t("donkey: normal volume matches bell gain", is_equal_approx(active.volume_db, linear_to_db(2.0)))
		await seconds(2.1)
		t("donkey: natural finish unlocks playback", not g._donkey_busy())
		g._play_donkey(clip, true)
		t("donkey: chair adds same double volume as bell", g._donkey_busy() and is_equal_approx(g._donkey_voice.volume_db, linear_to_db(4.0)))
		await seconds(2.1)
	g.stage.set_base(g.world, "bell")
	t("donkey: bell contacts cannot activate donkey", not g._donkey_contact_ready("other"))
	g.end_match()
	g.queue_free()
	await frames(2)


func _run_ropesides() -> void:
	var old_rope := Climber.rope_x
	Climber.rope_x = 8.0
	var c: Climber = ClimberScript.new()
	add_child(c)
	c.build(Vector2.ZERO, world)
	c.set_physics_process(false)
	var bounces := [0]
	c.rope_bounced.connect(func(_at, _speed): bounces[0] += 1)
	for side in [-1.0, 1.0]:
		for speed in [-3.0, 0.0, 3.0]:
			for body: RigidBody3D in c.bodies.values():
				body.global_position = Vector3(side * (Climber.rope_x + 0.18), 0.8, 0)
				body.linear_velocity = Vector3(side * speed, -4.0, 0)
				Climber.sync_server(body)
			c._rope_wait = 0.0
			var before: int = bounces[0]
			c._tick_ropes(1.0 / 120)
			t("outside rope: left/right, incoming/outgoing/falling launches inward and up", c.bodies.chest.linear_velocity.x * side < 0 and c.bodies.chest.linear_velocity.y > 0 and bounces[0] == before + 1, [side, speed])
			c._tick_ropes(1.0 / 120)
			t("outside rope: cooldown prevents repeated launch events", bounces[0] == before + 1)
		for body: RigidBody3D in c.bodies.values():
			body.global_position = Vector3(side * (Climber.rope_x - 0.1), 0.8, 0)
			body.linear_velocity = Vector3(-side * 3.0, 2.0, 0)
			Climber.sync_server(body)
		c._rope_wait = 0.0
		var before: int = bounces[0]
		c._tick_ropes(1.0 / 120)
		t("inside rope: moving away stays unchanged", bounces[0] == before and c.bodies.chest.linear_velocity.is_equal_approx(Vector3(-side * 3.0, 2.0, 0)))
	c.remove()
	c.queue_free()
	Climber.rope_x = old_rope
	await frames(2)


func _run_practicesettings() -> void:
	for game_type in ["scramble", "tower", "delmar"]:
		var g: Game = GameScript.new()
		g.world = world
		g.dress = false
		add_child(g)
		g.bot_drivers[0] = Drivers.ScriptDriver.new()
		var roster := [{"pid": 0, "name": "Practice", "tint": Color.WHITE, "peer": 1, "slot": 0}]
		var options := {"mode": "practice", "practice_mode": game_type, "base": "cactus", "stage": "plaza", "timer": 45.0}
		t("practice setup: starts solo " + game_type, g.host_start(options, roster))
		await wait_phase(g, "turn")
		t("practice setup: defaults to no NPC", g.partner == null)
		t("practice setup: selected arena and base", g.stage.delmar == (game_type == "delmar") and g.stage.base_id == "cactus")
		var clock := g.clock
		await seconds(0.25)
		t("practice setup: untimed and non-eliminating", is_equal_approx(clock, g.clock) and g.practice and not g._game_decided([0]))
		if game_type == "delmar":
			var c: Climber = g.live_climbers()[0]
			var old_id := c.climber_id
			c.bodies.head.global_position.y = Stage.WATER_Y - 1.0
			g._check_bounds()
			# (in the drink it sinks first: back once under, or after Game.SINK_MAX_S)
			for k in int((Game.SINK_MAX_S + 1.0) * Engine.physics_ticks_per_second):
				if g.live[0] != old_id:
					break
				await get_tree().physics_frame
			t("practice setup: sea fall respawns without elimination", g.live[0] != old_id and g.alive[0] and g.phase == "turn")
		g.end_match()
		options.practice_npc = true
		g.host_start(options, roster)
		await wait_phase(g, "turn")
		var npc: Climber = g.partner
		t("practice setup: NPC opt-in creates standard climber", npc != null and npc.bodies.size() == 16 and npc.driver is Drivers.ScriptDriver)
		t("practice setup: stationary NPC uses passive inputs", npc.driver != null and npc.active_limb() == -1)
		var c: Climber = g.live_climbers()[0]
		t("practice setup: NPC mass matches player", is_equal_approx(npc.total_mass, c.total_mass))
		npc.attach(0, c.bodies.chest)
		t("practice setup: NPC can grip a player", npc.limbs[0].grab_other == c.bodies.chest)
		npc.knock_out()
		t("practice setup: NPC knockout releases grips", npc.knockout_left > 0 and npc.stuck_count() == 0)
		g.end_match()
		t("practice setup: leaving removes NPC", g.partner == null)
		g.queue_free()
		await frames(2)

func _run_practiceai() -> void:
	for level in ["easy", "hard"]:
		var g := make_game("practice", 1, 60.0, "plaza")
		await wait_phase(g, "turn")
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--ai-base=") or arg.begins_with("--ai-mode="):
				var options := g.settings.duplicate()
				options["base" if arg.begins_with("--ai-base=") else "practice_mode"] = arg.get_slice("=", 1)
				g.host_start(options, g.roster)
				await wait_phase(g, "turn")
		g.set_practice_ai(level)
		var peak := 0.0
		var invalid_inputs := false
		for tick in 3600:
			await frames(1)
			var bot = g.partner
			peak = maxf(peak, bot.top_height())
			var pressed := 0
			for held in bot.brain.holds:
				pressed += int(held)
			invalid_inputs = invalid_inputs or pressed > 1
			if bot.state == Climber.State.FROZEN:
				break
		t("AI " + level + ": only one active limb", not invalid_inputs)
		t("AI " + level + ": climbs and locks under normal rules", g.partner.state == Climber.State.FROZEN, "peak=" + str(peak))
		g.end_match()
		g.queue_free()
		await frames(3)
		await _clear()


func _run_practiceairules() -> void:
	var g := make_game("practice", 1, 60.0, "plaza")
	await wait_phase(g, "turn")
	var bot = g.partner
	await frames(30)
	t("AI stationary: no active limb", bot.active_limb() == -1)
	g.set_practice_ai("hard")
	t("AI setting: changes live partner without respawning", g.partner == bot and bot.difficulty == "hard")
	bot.set_physics_process(false)
	bot.release_all()
	var pose: PackedFloat32Array = bot.pose()
	for i in range(0, pose.size(), 3):
		pose[i] += 5.0
		pose[i + 1] += 8.0
	bot.apply_pose(pose)
	t("AI airborne: cannot lock above line", not g.partner_can_lock())
	g.lock_partner()
	t("AI airborne: lock request leaves NPC live", bot.state == Climber.State.LIVE)
	g.set_practice_ai("stationary")
	g._spawn_partner()
	t("AI respawn: preserves chosen setting", g.partner.difficulty == "stationary")
	bot = g.partner
	await frames(20)
	g.chair.pick_up(bot, 0)
	bot.brain.set_limb(0, true, Vector2(1, 0))
	bot._select_active_limb()
	g._tick_chair(1.0 / 120.0)
	t("AI chair: negative NPC id remains a valid carrier", g.chair.holder == -2 and g.chair.grip_joint.is_valid())
	g.set_practice_ai("none")
	t("AI none: removes NPC and releases carried chair", g.partner == null and g.chair.holder == -1 and not g.settings.practice_npc)
	await frames(30)
	t("AI none: stays removed", g.partner == null)
	g.set_practice_ai("easy")
	t("AI re-enable: spawns selected difficulty", g.partner != null and g.partner.difficulty == "easy")
	g.end_match()
	t("AI cleanup: no partner or stale tower id", g.partner == null and not g.climbers.has(-2) and not g.tower.has(-2))
	g.queue_free()
	await frames(3)

func _run_practiceaicombat() -> void:
	var g := make_game("practice", 1, 60.0, "plaza")
	await wait_phase(g, "turn")
	await frames(20)
	var bot = g.partner
	var rival: Climber = g.climbers[g.live[0]]
	rival.release_all()
	var pose := rival.pose()
	var shift := bot.centre_of_mass().x + 1.25 - rival.centre_of_mass().x
	for i in range(0, pose.size(), 3):
		pose[i] += shift
	rival.apply_pose(pose)
	g.set_practice_ai("hard")
	bot.brain.set_limb(1, true, Vector2(1, 0))
	bot._select_active_limb()
	g.chair.pick_up(bot, 1)
	var struck := false
	var attacked := false
	for tick in 720:
		await frames(1)
		attacked = attacked or bot.intent == "Chair strike"
		struck = struck or rival.knockout_left > 0
		if struck:
			break
	t("AI hard: uses carried chair against nearby rival", attacked)
	t("AI hard: physical head strike can knock rival out", struck)
	g.end_match()
	g.queue_free()
	await frames(3)

func _run_practiceairounds() -> void:
	var g := make_game("practice", 1, 60.0, "plaza")
	await wait_phase(g, "turn")
	await frames(30)
	var stationary = g.partner
	g._next()
	t("AI rounds: Stationary persists without replacement", g.partner == stationary and g.partner.difficulty == "stationary")
	for level in ["easy", "hard"]:
		g.set_practice_ai(level)
		g.partner.set_physics_process(false)
		g.line = -100.0  # legal floor fixture isolates lifecycle from route planning
		await frames(180)
		var old = g.partner
		g.lock_partner()
		var old_id: int = old.climber_id
		t("AI rounds: locked NPC has unique tower id", old.state == Climber.State.FROZEN and old_id >= 0 and g.tower.has(old_id))
		g._next()
		t("AI rounds: " + level + " returns next round", g.partner != old and g.partner.state == Climber.State.LIVE and g.partner.difficulty == level)
		t("AI rounds: previous NPC remains climbable", is_instance_valid(old) and not old.removed and g.climbers.get(old_id) == old and g.tower.has(old_id))
	g.set_practice_ai("none")
	var tower_count := g.tower.size()
	g._next()
	t("AI rounds: No NPC remains disabled", g.partner == null)
	t("AI rounds: disabling NPC preserves built tower", g.tower.size() == tower_count)
	g.end_match()
	t("AI rounds: ending practice clears archived NPCs", g.climbers.is_empty() and g.tower.is_empty())
	g.queue_free()
	await frames(3)

func _run_aicalibration() -> void:
	var base := "barrel"
	var mode_id := "tower"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ai-base="):
			base = arg.get_slice("=", 1)
		if arg.begins_with("--ai-mode="):
			mode_id = arg.get_slice("=", 1)
	var trial_seeds := [11, 29]
	var levels := ["easy", "hard"]
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ai-seed="):
			trial_seeds = [int(arg.get_slice("=", 1))]
		if arg.begins_with("--ai-level="):
			levels = [arg.get_slice("=", 1)]
	for trial_seed in trial_seeds:
		for level in levels:
			seed(trial_seed)
			var g := make_game("practice", 1, 60.0, "plaza")
			var options := g.settings.duplicate()
			options.base = base
			options.practice_mode = mode_id
			options.practice_ai = level
			g.host_start(options, g.roster)
			await wait_phase(g, "turn")
			for attempt in 2:
				var start := Time.get_ticks_msec()
				var bot = g.partner
				bot.adapt_to_stalls = not OS.get_cmdline_user_args().has("--ai-baseline")
				bot.placement_speed_limit = 5.0 if bot.adapt_to_stalls else 2.5
				var initial_height := g.measure(bot)
				var highest := initial_height
				var shelf := false
				var obstruction := false
				for tick in 4800:
					await frames(1)
					bot = g.partner
					highest = maxf(highest, g.measure(bot))
					if OS.get_cmdline_user_args().has("--ai-trace") and tick % 600 == 0:
						print("AI_TRACE ", JSON.stringify({"level":level,"round":attempt+1,"tick":tick,"pos":str(bot.centre_of_mass()),"measure":g.measure(bot),"line":g.line,"intent":bot.intent,"grips":bot.stuck_count(),"target":str(bot.target),"ends":[str(bot.limb_end(0)),str(bot.limb_end(1)),str(bot.limb_end(2)),str(bot.limb_end(3))]}))
					shelf = shelf or bot.intent == "Build launch shelf"
					obstruction = obstruction or bot.intent == "Obstruct rival approach"
					if bot.state == Climber.State.FROZEN:
						break
				var success: bool = bot.state == Climber.State.FROZEN
				if OS.get_cmdline_user_args().has("--ai-require-success"):
					t("AI replay: %s %s seed %d round %d locks legally" % [mode_id, level, trial_seed, attempt + 1], success)
				print("AI_TRIAL ", JSON.stringify({"policy":"baseline" if OS.get_cmdline_user_args().has("--ai-baseline") else "tuned","base":base,"mode":mode_id,"seed":trial_seed,"level":level,"round":attempt+1,"success":success,"seconds":(Time.get_ticks_msec()-start)/1000.0,"height_gain":highest-initial_height,"position":str(bot.centre_of_mass()),"shelf":shelf,"obstruction":obstruction,"intent":bot.intent}))
				if attempt == 0:
					g._next()
			g.end_match()
			g.queue_free()
			await frames(3)
			await _clear()  # each trial must start with exactly one arena, not old overlapping stage colliders


# ================================================================ THE PEAK (the solo climb): --peak, --peakride

## The lab: one of each of the mountain's mechanics on a flat floor (tools/peak/areas/lab.py).
func _peak(dir := "") -> Peak:
	var pk := Peak.new()
	world.add_child(pk)
	if dir != "":
		pk.course_dir = dir
	pk.setup(null)
	pk.begin()
	pk.dev_warp = true  # a battery never writes the save
	return pk


func pticks(pk: Peak, n: int) -> void:
	for i in n:
		pk.tick(1.0 / Engine.physics_ticks_per_second)
		await get_tree().physics_frame


func psec(pk: Peak, s: float) -> void:
	await pticks(pk, int(s * Engine.physics_ticks_per_second))


func _peak_climber(pk: Peak, x: float, y: float) -> Climber:
	var c := spawn(pk.world_of(Vector2(x, y)))
	pk.on_player(c, true)
	return c


## Move the whole climber so limb `i`'s end sits on a world point.
func _put_hand(c: Climber, i: int, at: Vector2) -> void:
	var d := at - c.limb_end(i)
	var p := c.pose()
	for k in range(0, p.size(), 3):
		p[k] += d.x
		p[k + 1] += d.y
	c.apply_pose(p)


func _free(c: Climber) -> void:
	c.release_all()
	for l in c.limbs:
		l.regrip = 99.0  # (it won't catch anything until told)


func _run_peak() -> void:
	var pk := _peak("res://tests/peak_lab/")
	var hz := Engine.physics_ticks_per_second
	t("peak: the lab loads (1 area, movers, ropes, zones)", pk.areas.size() == 1 and pk.things.movers.size() == 5 and pk.things.ropes.size() == 2 and pk.zones.waters.size() == 2)
	# ---- the rope holds a hanging climber
	var rope: Dictionary = pk.things.ropes[0]
	var seg: RigidBody3D = rope.segs[rope.segs.size() - 2]
	var c := _peak_climber(pk, -70, 6)
	_free(c)
	_put_hand(c, 0, Vector2(seg.global_position.x, seg.global_position.y))
	c.attach(0, seg)
	await psec(pk, 4.0)
	var top := pk.world_of(Vector2(-70, 12))
	var stretch := Vector2(seg.global_position.x, seg.global_position.y).distance_to(top)
	t("peak rope: it holds a hanging climber for 4 s and doesn't stretch", c.limbs[0].grab_other == seg and stretch < 8.0 and finite_body(c), "hand %.2f m under the top (rope 8 m), joints %.3f" % [stretch, c.worst_joint_gap()])
	t("peak rope: hanging on a rope counts as holding on (limbs work)", c.is_attached())
	# ---- and swings when pumped
	var d: Drivers.ScriptDriver = c.driver
	var x0 := c.centre_of_mass().x
	var swing := 0.0
	for i in int(5.0 * hz):
		var chest: RigidBody3D = c.bodies["chest"]
		var v := Vector2(chest.linear_velocity.x, chest.linear_velocity.y)
		d.set_limb(3, true, Vector2(1 if v.x >= 0.0 else -1, 0))
		pk.tick(1.0 / hz)
		await get_tree().physics_frame
		swing = maxf(swing, absf(c.centre_of_mass().x - x0))
	t("peak rope: pumping swings it", swing > 0.8, "%.2f m" % swing)
	d.clear()
	c.remove()
	await pticks(pk, 2)
	# ---- water: float, drift, swim
	c = _peak_climber(pk, -42, 5.2)
	_free(c)
	await psec(pk, 5.0)
	var fy := pk.local_of(c.centre_of_mass()).y
	t("peak water: a body floats at the surface", c.float_mode and fy > 4.2 and fy < 5.3, "centre at %.2f (surface 5.0)" % fy)
	c.remove()
	await pticks(pk, 2)
	var drift := []
	for mode in [0, 1, -1]:
		c = _peak_climber(pk, -30, 5.0)
		_free(c)
		await psec(pk, 1.5)
		d = c.driver
		var xs := pk.local_of(c.centre_of_mass()).x
		for i in int(5.0 * hz):
			if mode != 0:
				d.set_limb(1, true, Vector2.from_angle(-mode * TAU * 1.3 * float(i) / hz))
			pk.tick(1.0 / hz)
			await get_tree().physics_frame
		drift.append(pk.local_of(c.centre_of_mass()).x - xs)
		d.clear()
		c.remove()
		await pticks(pk, 2)
	t("peak water: the current carries a still body (1.5 m/s for 5 s)", drift[0] > 4.0, "%.1f m" % drift[0])
	t("peak water: THE SWIM: circling an arm one way goes with the current, the other way fights it", absf(drift[1] - drift[2]) > 1.5, "still %.1f m, clockwise %.1f m, counter %.1f m" % drift)
	# ---- a platform carries a standing climber
	c = _peak_climber(pk, 0, 5)
	var plat: Dictionary = pk.things.movers["plat"]
	var pn: Node3D = plat.nodes[0]
	var feet := Vector2(pn.global_position.x, pn.global_position.y + 0.22)
	var low := INF
	for b: RigidBody3D in c.bodies.values():
		low = minf(low, b.global_position.y)
	var p := c.pose()
	for k in range(0, p.size(), 3):
		p[k] += feet.x - c.centre_of_mass().x
		p[k + 1] += feet.y - low + 0.08
	c.apply_pose(p)
	await psec(pk, 7.0)
	var off := absf(c.centre_of_mass().x - pn.global_position.x)
	t("peak mover: a platform carries the climber standing on it", off < 1.2 and c.touches_solid(), "%.2f m from its middle after 7 s" % off)
	c.remove()
	await pticks(pk, 2)
	# ---- crumble and timed holds
	var rotten: Dictionary = {}
	var ice: Dictionary = {}
	var burro: Dictionary = {}
	for h in pk.things.holds:
		if str(h.type) == "crumble":
			rotten = h
		elif str(h.type) == "timed":
			ice = h
		elif str(h.type) == "kick":
			burro = h
	c = _peak_climber(pk, 14, 6)
	_free(c)
	_put_hand(c, 0, pk.world_of(Vector2(14, 3.95)))
	c.attach(0, rotten.body)
	await psec(pk, 0.6)
	var held: bool = c.limbs[0].grab_other == rotten.body
	await psec(pk, 1.0)
	t("peak hold: a rotten ledge holds, then breaks under the hand (1.2 s)", held and c.limbs[0].grab_other == null and (rotten.body as CollisionObject3D).collision_layer == 0)
	await psec(pk, 8.5)
	t("peak hold: ...and grows back", (rotten.body as CollisionObject3D).collision_layer != 0 and (rotten.vis as Node3D).visible)
	c.remove()
	await pticks(pk, 2)
	c = _peak_climber(pk, 18, 6)
	_free(c)
	_put_hand(c, 0, pk.world_of(Vector2(18, 3.95)))
	c.attach(0, ice.body)
	await psec(pk, 1.5)
	held = c.limbs[0].grab_other == ice.body
	await psec(pk, 0.8)
	t("peak hold: ice holds for 2 s, then lets go of you", held and c.limbs[0].grab_other == null)
	c.remove()
	await pticks(pk, 2)
	# ---- the cap throws
	c = _peak_climber(pk, 24, 5)
	_free(c)
	var up := 0.0
	for i in int(4.0 * hz):
		pk.tick(1.0 / hz)
		await get_tree().physics_frame
		up = maxf(up, (c.bodies["chest"] as RigidBody3D).linear_velocity.y)
	t("peak bounce: a cap throws a falling climber up at its power (8 m/s)", up > 6.5 and up < 9.5, "%.1f m/s" % up)
	c.remove()
	await pticks(pk, 2)
	# ---- geyser and wind
	c = _peak_climber(pk, 30, 0.02)
	_free(c)
	var high := 0.0
	for i in int(6.0 * hz):
		pk.tick(1.0 / hz)
		await get_tree().physics_frame
		high = maxf(high, pk.local_of(c.centre_of_mass()).y)
	t("peak geyser: it carries a climber up its column", high > 5.0, "to %.1f m" % high)
	c.remove()
	await pticks(pk, 2)
	c = _peak_climber(pk, 35, 4)
	_free(c)
	await psec(pk, 1.2)
	var wx := pk.local_of(c.centre_of_mass()).x
	t("peak wind: it pushes a falling climber (4 m/s2)", wx > 36.5, "%.1f m in 1.2 s" % (wx - 35.0))
	c.remove()
	await pticks(pk, 2)
	# ---- slick: nothing sticks, a slope pours you off; the softlock net
	c = _peak_climber(pk, 49.5, 5.2)
	await psec(pk, 5.0)
	var sx := pk.local_of(c.centre_of_mass())
	t("peak slick: a wet slope can't be held: the climber slides off it", sx.y < 2.6 and sx.x < 49.0, "now at %s" % sx)
	c.remove()
	await pticks(pk, 2)
	c = _peak_climber(pk, 59, 0.45)
	await psec(pk, 6.0)
	t("peak softlock: lying on flat slick, the scramble wakes (or a hand found grip)", c.scramble or c.touches_solid(), "scramble %s, holding %s" % [c.scramble, c.touches_solid()])
	c.remove()
	await pticks(pk, 2)
	# ---- the burro kicks
	c = _peak_climber(pk, -76, 4)
	_free(c)
	_put_hand(c, 1, pk.world_of(Vector2(-76.86, 1.2)))
	c.attach(1, burro.body)
	await pticks(pk, 3)
	var kv: Vector3 = (c.bodies["chest"] as RigidBody3D).linear_velocity
	t("peak kick: grabbing the burro throws you", kv.y > 5.0 and c.limbs[1].grab_other == null, "%s" % kv)
	c.remove()
	await pticks(pk, 2)
	# ---- the ones who tried: frozen and solid
	var st: Climber = pk.things.statues[0]
	t("peak statue: one of the ones who tried hangs frozen", st.state == Climber.State.FROZEN)
	c = _peak_climber(pk, -20, 3)
	_free(c)
	var foot: RigidBody3D = st.bodies["foot_l"]
	_put_hand(c, 0, Vector2(foot.global_position.x, foot.global_position.y - 0.1))
	c.attach(0, foot)
	await psec(pk, 2.0)
	t("peak statue: you can hang off him", c.limbs[0].grab_other == foot and c.is_attached())
	c.remove()
	pk.leave()
	await pticks(pk, 2)


## The first ride: in the cart at the trailhead, into the mountain, out at the buffer.
func _run_peakride() -> void:
	var pk := _peak()
	t("peak course: the mountain loads", pk.areas.size() >= 2 and pk.challenges.size() >= 3, "%d areas, %d challenges" % [pk.areas.size(), pk.challenges.size()])
	var cart: Dictionary = pk.things.movers.get("cart0", {})
	if cart.is_empty():
		t("peak ride: the cart exists", false)
		return
	var c := _peak_climber(pk, -9.0, 2.8)
	await psec(pk, 2.5)
	t("peak ride: in the cart for a moment and it rolls", bool(cart.run), "boarded %.2f s" % float(cart.board_t))
	var worst := 0.0
	for i in int(24.0 * Engine.physics_ticks_per_second):
		pk.tick(1.0 / Engine.physics_ticks_per_second)
		await get_tree().physics_frame
		if bool(cart.run):
			worst = maxf(worst, pk.local_of(c.centre_of_mass()).distance_to((cart.home as Vector2) + (cart.offset as Vector2)))
		elif float(cart.arrived) >= 0.0:
			break
	var at := pk.local_of(c.centre_of_mass())
	t("peak ride: the cart reaches the buffer in the mine", float(cart.arrived) >= 0.0 and ((cart.home as Vector2) + (cart.offset as Vector2)).x < -147.0)
	t("peak ride: the climber rode it all the way (never more than 2.5 m from it)", worst < 2.5 and at.x < -140.0, "worst %.2f m, now at %s" % [worst, at])
	c.remove()
	pk.leave()
	await pticks(pk, 2)
