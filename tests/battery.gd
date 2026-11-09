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
	t("limp: an unheld hand touching a bar sticks by itself", c.limbs[1].grab.is_valid())
	await frames(1)
	t("limp: simultaneous presses select exactly one limb", c.limbs[0].driving and not c.limbs[2].held and not c.limbs[3].held)
	d.set_limb(2, false)
	await frames(2)
	d.set_limb(2, true)
	await frames(2)
	t("limp: a new press takes over and preserves the passive grip", c.limbs[2].driving and not c.limbs[0].held and c.limbs[1].grab.is_valid())
	var next_bar := bar_at(c.limb_end(0))
	await frames(4)
	t("limp: the deselected hand catches on contact despite its button staying down", c.limbs[0].grab_other == next_bar)
	d.set_limb(2, false)
	await frames(2)
	t("limp: releasing the selection hands control back to the older hand still held (the press stack)", c.limbs[0].held and not c.limbs[0].grab.is_valid() and c.active_limb() == 0)
	next_bar.queue_free()
	d.set_limb(0, false)  # let go of the other buttons: only the stuck hand's press is new
	d.set_limb(3, false)
	await frames(2)  # the bar is gone before anything can catch it again
	c.release(0)
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
		c.grab_made.connect(func(gc, gl, o):
			if o is RigidBody3D and o.has_meta("climber") and not gc.limbs[gl].held:
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
	t("eight live: loose limbs never grab a live climber (only a held limb does, Parker 11-08)", rival_grabs[0] == 0, rival_grabs[0])
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
	t("chain: after C freezes, B and A still hold on", cB.limbs[0].grab.is_valid() and cA.limbs[0].grab.is_valid())
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
	t("grab: unheld feet on the deck stick by themselves (you start standing)", c.limbs[2].grab.is_valid() and c.limbs[3].grab.is_valid())
	d.set_limb(2, true)  # press: pick the left foot up
	await frames(2)
	t("grab: pressing a stuck limb's button picks it up", not c.limbs[2].grab.is_valid())
	await seconds(0.5)
	t("grab: a held limb can't stick while held", not c.limbs[2].grab.is_valid())
	d.set_limb(2, false)
	await frames(4)
	t("grab: letting go over the deck plants it again", c.limbs[2].grab.is_valid())
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
	t("grab: a frozen climber can be held", h.limbs[1].grab.is_valid())
	h.attach(2, e.bodies["chest"])
	t("grab: a live rival can be held, and counts the grab", h.limbs[2].grab.is_valid() and e.grabbed_by == 1)
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
	t("grab: the practice partner can be grabbed (and counts it)", g2.limbs[1].grab.is_valid() and g2.limbs[1].grab_climber == pp and pp.grabbed_by == 1)
	g2.release_all()
	pp.remove()
	# A HELD limb takes hold of a climber it touches and lets go with the button
	# (like the chair); a loose one never does. And THE GROUNDED GROUP: two climbers
	# holding each other in the air can't drive (no flying).
	var x1 := spawn(Vector2(10.0, 6.0))
	var x2 := spawn(Vector2(10.0, 6.0))  # overlapping: x1's hand is inside x2
	var xd: Drivers.ScriptDriver = x1.driver
	await frames(1)
	var loose_grabbed: bool = x1.limbs[0].grab.is_valid() and x1.limbs[0].grab_climber == x2
	xd.set_limb(0, true)
	var held_grabbed := false
	for k in 30:
		await get_tree().physics_frame
		if x1.limbs[0].grab.is_valid() and x1.limbs[0].grab_climber == x2:
			held_grabbed = true
			break
	var air_attached: bool = x1.is_attached() or x2.is_attached()
	xd.set_limb(0, false)
	await frames(2)
	var let_go: bool = x1.limbs[0].grab_climber != x2
	t("grab: a held limb grabs a climber it touches; a loose one doesn't; letting go releases", held_grabbed and not loose_grabbed and let_go, "held %s, loose %s, let go %s" % [held_grabbed, loose_grabbed, let_go])
	t("grab: two climbers holding each other in the air can't drive (the grounded group)", held_grabbed and not air_attached)
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
	g.host_start({"mode": mode_id, "timer": timer, "spawn": "alternate", "stage": arena}, roster)
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
func lift_and_lock(g: Game, pid: int, above := 0.4, airborne := false) -> Climber:
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
	(g.bot_drivers[pid] as Drivers.ScriptDriver).lock = true
	await frames(3)
	return c


func _run_groundlock() -> void:
	for id in ["tower", "scramble", "practice"]:
		var g := make_game(id, 1, 50.0)
		await wait_phase(g, "round" if id == "scramble" else "turn")
		var c := await lift_and_lock(g, 0, 0.4, true)
		t("%s: an above-line airborne lock is refused" % id, c.state == Climber.State.LIVE and g.tower.is_empty() and g.best[0] == 0.0)
		await lift_and_lock(g, 0)
		t("%s: contact with the barrel accepts the lock" % id, c.state == Climber.State.FROZEN and g.tower.size() == 1)
		g.end_match()
		g.queue_free()
		await frames(2)
	var timed := make_game("tower", 1, 50.0)
	await wait_phase(timed, "turn")
	await lift_and_lock(timed, 0, 0.4, true)
	timed._time_up()
	t("timeout: an airborne pose cannot score or become a new platform", not timed.alive[0] and timed.best[0] == 0.0 and timed.tower.is_empty() and timed.live.is_empty())
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
	d.point_limb(0, true, Vector2(bx + 0.25, 1.95))  # pick the near hand up: lift it clear of the side first
	await seconds(0.8)
	d.point_limb(0, true, Vector2(bx - 0.20, 1.95))  # then press it onto the side, high
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
	A.host_start({"mode": "scramble", "timer": 6.0, "spawn": "alternate", "stage": "plaza"}, roster)
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
	# A client makes a contact and holds RB. Both peers hear the same take.
	var grunts := []
	for m in machines:
		var climber: Climber = m.game.climbers[b1.climber_id]
		climber.bodies["chest"].child_entered_tree.connect(func(node):
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
	A.chair.global_position = client_hand.global_position
	Climber.sync_server(A.chair)
	(B.bot_drivers[1] as Drivers.ScriptDriver).set_limb(0, true)
	await seconds(0.25)
	A.chair.set_hit_count(A.chair.dent_hits.y)
	await seconds(0.15)
	t("net: the chair wear count reaches client and spectator", B.chair.dent_hits == A.chair.dent_hits and B.chair.damage_stage() == 2 and machines[2].game.chair.damage_stage() == 2)
	t("net: the remote pickup is shared", A.chair.holder == b1.climber_id and B.chair.holder == b1.climber_id)
	(B.bot_drivers[1] as Drivers.ScriptDriver).set_limb(0, false)
	await seconds(0.25)
	t("net: remote release drops the same chair", A.chair.holder == -1 and B.chair.holder == -1)
	var chair_sounds := []
	for m in machines:
		var heard := []
		chair_sounds.append(heard)
		m.world.child_entered_tree.connect(func(node):
			if node is AudioStreamPlayer3D:
				heard.append(node.stream.resource_path.get_file().get_basename()))
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
	# Grab across machines: the client's hand holds the host climber's puppet.
	b1.attach(0, b0.bodies["chest"])
	await seconds(0.5)
	t("net: the host's climber learns it's held (counts as attached)", a0.remote_grabbed == 1 and a0.is_attached(), a0.remote_grabbed)
	t("net: the holder's pull arrives on the held climber's machine", not a0.remote_pulls.is_empty(), a0.remote_pulls)
	b1.release(0)
	await seconds(0.4)
	t("net: releasing un-counts it on the other machine", a0.remote_grabbed == 0)
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
	# The host's climber runs out the clock: frozen and out, identical on both.
	await wait_phase(A, "over", 10.0)
	await seconds(0.5)
	t("net: the timed-out climber is frozen on both machines", a0.state == Climber.State.FROZEN and b0.state == Climber.State.FROZEN)
	t("net: its frozen body matches across machines", _pose_diff(a0.pose(), b0.pose()) < 0.0001, "%.6f" % _pose_diff(a0.pose(), b0.pose()))
	t("net: both machines agree on the winner (the client)", int(A.results.get("winner", -1)) == 1 and int(B.results.get("winner", -1)) == 1, "%s / %s" % [A.results.get("winner"), B.results.get("winner")])
	for m in machines:
		m.game.set_physics_process(false)
		m.game.end_match()
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
	t("feel: you spawn standing, both feet stuck", head > 1.5 and c.limbs[2].grab.is_valid() and c.limbs[3].grab.is_valid(), "head top %.2f" % head)
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
	t("feel: the feet stay stuck while you reach", c.limbs[2].grab.is_valid() and c.limbs[3].grab.is_valid())
	# 2. Out of reach: the body leans after the hand, the feet hold, nothing flies.
	var com0 := c.centre_of_mass()
	d.point_limb(0, true, S + Vector2(-2.5, 1.5))
	await seconds(1.0)
	var lean := com0.x - c.centre_of_mass().x
	t("feel: out of reach, the body leans after the hand (COM 10 cm or more toward it)", lean > 0.10, "%.2f m" % lean)
	t("feel: out of reach, the feet still hold (no flying)", c.limbs[2].grab.is_valid() and c.limbs[3].grab.is_valid())
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
	t("practice: NPC cannot be used as a grip", not c.limbs[0].grab.is_valid())
	t("chair: rests flat on a broad face", absf(g.chair.global_basis.z.y) > 0.98)
	var foot: RigidBody3D = c.bodies["foot_l"]
	var piece_mass := foot.mass
	d.point_limb(2, true, Climber.pos2(g.chair) + Vector2(0.18, 0.02))
	for tick in 240:
		await frames(1)
		if g.chair.holder == c.climber_id:
			break
	t("chair: reaching with an active foot picks up the flat chair", g.chair.holder == c.climber_id)
	if g.chair.holder == c.climber_id:
		d.set_limb(2, true, Vector2(-1, 1).normalized())
		await frames(30)
		t("chair: held without mass or collision load", foot.mass == piece_mass and g.chair.freeze and g.chair.collision_mask == 0)
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
			t("chair: head recoils and partner temporarily stops balancing", head.linear_velocity.x > before.x + 0.2 and npc.stagger_time > 0)
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
	# Turn the NPC onto its side on the canvas, then allow its balance controller to act.
	var pose := npc.pose()
	var pivot := npc.centre_of_mass()
	for k in range(0, pose.size(), 3):
		var xy := (Vector2(pose[k], pose[k + 1]) - pivot).rotated(PI * 0.5) + Vector2(2.8, 0.38)
		pose[k] = xy.x
		pose[k + 1] = xy.y
		pose[k + 2] += PI * 0.5
	npc.apply_pose(pose)
	await seconds(5)
	t("practice: fallen partner attempts to stand back upright", npc.piece_top("head") > 1.3 and absf(Climber.angle_of(npc.bodies["chest"])) < 0.65, npc.piece_top("head"))
	pose = npc.pose()
	for k in range(0, pose.size(), 3):
		pose[k] += 25
	npc.apply_pose(pose)
	await frames(4)
	t("practice: out-of-bounds partner respawns without advancing the turn", g.partner != null and g.partner != npc and not g.stage.out_of_bounds(g.partner.centre_of_mass()) and g.live[0] == c.climber_id and g.phase == "turn")
	g.end_match()
	t("practice: leaving removes chair and partner", g.chair == null and g.partner == null)
	g.queue_free()
	await frames(2)


func _run_chairwear() -> void:
	var g := make_game("practice", 1, 50.0, "plaza", true)
	await wait_phase(g, "turn")
	var chair := g.chair
	var c: Climber = g.climbers[g.live[0]]
	var head: RigidBody3D = g.partner.bodies["head"]
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
	t("ring: the bounce is told (signal) and has its sound (placeholder boing)", bounces[0] > 0 and Sound._streams.has("rope_boing"), "%d bounces" % bounces[0])
	await seconds(0.6)
	var settled: bool = rope != null and rope.mesh == rope.get_meta("rest_mesh", null)
	var ends_still: bool = rope != null and absf(rope.position.x) < 99.0  # the node never moves: only its middle bends
	t("ring: the side rope's middle bows out with the hit (its ends stay on the posts) and settles back", rope != null and rope_peak > 0.05 and settled and ends_still, "bowed %.2f m, back %s" % [rope_peak, settled])
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
