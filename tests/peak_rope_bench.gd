extends Node
## THE ROPE BENCH (playtest note 20, Parker 11-12: "we need to fix the rope physics. Make it
## so you can swing back and forth on them better. Right now they like launch you up weird
## but you can't get a good swing on them"). Numbers, so a change to the ropes is not a
## guess. Headless. It hangs two ropes of its own in open sky east of the roots, built by
## the game's own rope builder (a 5 m rope and a 9 m chain, nothing near to hit), and uses
## the mine's real 4.8 m rope as well. Any course rope can be named instead:
##   Godot_console.exe --headless --path . res://tests/peak_rope_bench.tscn [-- --only=cuerda_niebla]
## (a course rope may hang in a shaft: a swing that stops short there is the wall's doing).
## THE SURVEY, "-- --survey [--only=a4]": every rope, chain and vine of the course (or of
## one area), each where it really hangs: a climber on its foot pumps for 20 s and the
## line says how far east and west of the rope's top its gripping hand got, and how long
## a swing takes; a line strung between two points says how far it sags under a climber
## at its middle. About 25 s a rope, so 20 minutes for the mountain.
## For each rope it hangs a climber by one hand near the rope's foot and reports:
##   REST    where the body hangs, and how much the rope stretched under it;
##   SWING   pumped on a script for 30 s (a leg pushed the way the body is going, as a
##           player pumps; one push is one swing to one side): how far out each push
##           took it, in degrees from straight down as seen from the rope's top, the
##           seconds a swing there and back takes, and the fastest the body went up;
##   THROW   let go at the bottom of the swing after 24 s of pumping: the speed and
##           direction the body leaves with;
##   STILL   hanging still, nothing pressed, 4 s: how far the body wanders by itself;
##   LEAN    hanging still, a leg pushed east and held there 8 s, out of time with any
##           swing: how far off straight down that carries the body (can it be hauled
##           sideways?);
##   HAUL    hanging still, the free hand held straight up for 3 s, then (after 5 s to
##           hang still again) a leg held straight down for 3 s: how far the body's middle rises, how far it gets
##           above its own gripping hand, and how far the gripping hand itself is
##           carried up (a rope can't push: a hand that rises was thrown). (The old
##           complaint, 11-12: "if you are attached to a rope you can basically fly".)
##   FLING   hanging still, a leg thrown east and up (45 degrees) and held 0.5, 0.9 and
##           1.4 s, then everything let go: the speed the body leaves with, and how far
##           east of where it hung it is when it has fallen 2 m below where it hung. (No
##           swing first: what one push off a still rope is worth.)
##   CLIMB   hand over hand up the rope: the free hand is pointed at the rope 0.6 m above
##           the gripping one and let go of to take it, then the other, and so on: the
##           seconds it takes to get the body 3 m up (less on a short rope), and how
##           many times a hand took the rope.
const ClimberScript := preload("res://climber/climber.gd")
const Drivers := preload("res://climber/drivers.gd")
const ROPES := ["bench_rope", "bench_chain", "cuerda_minero"]
const OWN := [
	{"id": "bench_rope", "kind": "rope", "at": [-80.0, 330.0], "seg": 0.5, "len": 5.0},
	{"id": "bench_chain", "kind": "chain", "at": [-40.0, 330.0], "seg": 0.5, "len": 9.0},
]

var pk: Peak
var hz := 120.0
var _parts := {}


func _on(part: String) -> bool:
	return _parts.is_empty() or _parts.has(part)


func _ready() -> void:
	var only := ""
	var parts := {}  # --parts=swing,haul,climb,lean (all of them when not given)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			only = a.get_slice("=", 1)
		elif a.begins_with("--feel="):  # --feel=rope_pull:2.0 : try a Feel number without editing the table
			Feel.set_k(a.get_slice("=", 1).get_slice(":", 0), float(a.get_slice(":", 1)))
			print("BENCH with Feel %s" % a.get_slice("=", 1))
		elif a.begins_with("--parts="):
			for part in a.get_slice("=", 1).split(","):
				parts[part] = true
	_parts = parts
	hz = float(Engine.physics_ticks_per_second)
	var world := Node3D.new()
	add_child(world)
	pk = Peak.new()
	world.add_child(pk)
	pk.setup(null)
	pk.begin()
	pk.dev_warp = true
	var first_anchor: Node = pk.things._anchors.values()[0]
	var anchor := StaticBody3D.new()
	anchor.collision_layer = 0
	anchor.collision_mask = 0
	first_anchor.get_parent().add_child(anchor)
	Climber.sync_server(anchor)
	pk.things._anchors["bench"] = anchor
	for def: Dictionary in OWN:
		pk.things._build_rope({"id": "bench"}, def, first_anchor.get_parent())
	for i in 4:
		await get_tree().physics_frame
	print("BENCH gravity on a climber: %.2f m/s2 holding on, %.2f m/s2 falling" % [9.8 * Feel.climber_gravity(true), 9.8 * Feel.climber_gravity(false)])
	if OS.get_cmdline_user_args().has("--survey"):
		await _survey(world, only)
		get_tree().quit()
		return
	var list: Array = ROPES if only == "" else [only]
	for id: String in list:
		var rope: Dictionary = {}
		for r in pk.things.ropes:
			if str(r.id) == id:
				rope = r
		if rope.is_empty():
			print("BENCH %s: no such rope" % id)
			continue
		await _bench(world, rope)
	get_tree().quit()


func _step(n: int) -> void:
	for i in n:
		pk.tick(1.0 / hz)
		await get_tree().physics_frame


func _hang(world: Node3D, rope: Dictionary, at_seg := -1) -> Climber:
	var seg: RigidBody3D = rope.segs[at_seg if at_seg >= 0 else rope.segs.size() - 2]
	var c: Climber = ClimberScript.new()
	c.climber_id = 700 + randi() % 100
	add_child(c)
	c.build(Vector2(seg.global_position.x, seg.global_position.y - 2.2), world, null)
	c.driver = Drivers.ScriptDriver.new()
	pk.on_player(c, true)
	c.release_all()
	for l in c.limbs:
		l.regrip = 999.0  # (only the one hand, put there by the bench)
	var d := Vector2(seg.global_position.x, seg.global_position.y) - c.limb_end(0)
	var p := c.pose()
	for k in range(0, p.size(), 3):
		p[k] += d.x
		p[k + 1] += d.y
	c.apply_pose(p)
	c.attach(0, seg)
	return c


func _bench(world: Node3D, rope: Dictionary) -> void:
	var id := str(rope.id)
	var segs: Array = rope.segs
	var top: Vector2 = pk.world_of(rope.top)
	var seg_mass := (segs[0] as RigidBody3D).mass
	print("BENCH %s: %s, %d pieces of %.2f kg (%.1f kg in all, the climber is 22), gravity on it %.2f m/s2, brakes %.2f / %.2f" % [
		id, rope.kind, segs.size(), seg_mass, seg_mass * segs.size(), 9.8 * (segs[0] as RigidBody3D).gravity_scale,
		(segs[0] as RigidBody3D).linear_damp, (segs[0] as RigidBody3D).angular_damp])
	# ---- REST and STILL
	var c := _hang(world, rope)
	await _step(int(3.0 * hz))
	var rest := c.centre_of_mass()
	var hand := c.limb_end(0)
	var slack := top.distance_to(hand)
	var wander := 0.0
	var up_still := 0.0
	for i in int(4.0 * hz):
		await _step(1)
		wander = maxf(wander, c.centre_of_mass().distance_to(rest))
		up_still = maxf(up_still, (c.bodies["chest"] as RigidBody3D).linear_velocity.y)
	print("BENCH %s REST: the hand hangs %.2f m under the rope's top (the rope's length to it is %.2f m); holding on: %s. STILL: in 4 s with nothing pressed the body wandered %.2f m, fastest upward %.2f m/s" % [
		id, slack, float(rope.seg_len) * (segs.size() - 1.5), c.limbs[0].grab_other != null, wander, up_still])
	var d: Drivers.ScriptDriver = c.driver
	if _on("swing"):
		await _swing(id, c, top)
	c.remove()
	await _step(int(1.5 * hz))
	if _on("lean"):
		await _lean(id, world, rope, top)
	if _on("haul"):
		await _haul(id, world, rope)
	if _on("climb"):
		await _climb(id, world, rope, top)
	if _on("fling"):
		await _fling(id, world, rope)


func _swing(id: String, c: Climber, top: Vector2) -> void:
	# ---- SWING: pump for 30 s
	var d: Drivers.ScriptDriver = c.driver
	var turns: Array = []  # how far out each push took it (degrees)
	var crossings: Array = []  # times it passed under the top, going east
	var last_x := c.centre_of_mass().x - top.x
	var going := 0.0  # which way it is swinging (set once it is plainly moving)
	var widest := 0.0  # the widest angle since the last turn
	var fastest_up := 0.0
	var fastest := 0.0
	var t := 0.0
	var t60 := -1.0
	var thrown := false
	var throw_v := Vector2.ZERO
	while t < 30.0:
		var v := c.velocity()  # (the whole body's: a thrown leg jerks the chest about)
		if not thrown:
			d.set_limb(3, true, Vector2(1 if v.x >= 0.0 else -1, 0))
		await _step(1)
		t += 1.0 / hz
		if thrown:
			continue
		var com := c.centre_of_mass()
		var x := com.x - top.x
		var ang := rad_to_deg(absf(atan2(com.x - top.x, top.y - com.y)))
		widest = maxf(widest, ang)
		if ang >= 60.0 and t60 < 0.0:
			t60 = t
		if last_x < 0.0 and x >= 0.0:
			crossings.append(t)
			if t > 24.0:
				# THROW: let go here, at the bottom, going east
				d.clear()
				c.release_all()
				throw_v = c.velocity()
				thrown = true
		if absf(v.x) > 0.12:
			if going != 0.0 and signf(v.x) != going:
				turns.append(widest)
				widest = 0.0
			going = signf(v.x)
		last_x = x
		fastest_up = maxf(fastest_up, v.y)
		fastest = maxf(fastest, v.length())
	var period := 0.0
	if crossings.size() >= 3:
		period = (float(crossings[crossings.size() - 1]) - float(crossings[1])) / (crossings.size() - 2)
	var line: Array = []
	for a: float in turns.slice(0, 12):
		line.append("%.0f" % a)
	print("BENCH %s SWING: how far out each push took it (degrees from straight down): %s. There and back takes %.1f s. Fastest upward %.1f m/s, fastest at all %.1f m/s" % [id, " ".join(line), period, fastest_up, fastest])
	var best := 0.0
	for a: float in turns:
		best = maxf(best, a)
	print("BENCH %s SWING: the fifth push reached %s degrees; the widest in 24 s was %.0f; it first passed 60 degrees %s" % [
		id, ("%.0f" % float(turns[4])) if turns.size() >= 5 else "(fewer than five pushes in the time)", best,
		("after %.1f s" % t60) if t60 >= 0.0 else "never"])
	if thrown:
		print("BENCH %s THROW: let go at the bottom after 24 s: leaves at %.1f m/s, %.0f degrees %s level" % [id, throw_v.length(), absf(rad_to_deg(atan2(throw_v.y, absf(throw_v.x)))), "above" if throw_v.y >= 0.0 else "below"])
	else:
		print("BENCH %s THROW: it never came through the bottom going east after 24 s (no swing to let go of)" % id)


func _lean(id: String, world: Node3D, rope: Dictionary, top: Vector2) -> void:
	# ---- LEAN
	var c := _hang(world, rope)
	var d: Drivers.ScriptDriver = c.driver
	await _step(int(3.0 * hz))
	var lean := 0.0
	var lean_end := 0.0
	d.set_limb(3, true, Vector2(1, 0))
	for i in int(8.0 * hz):
		await _step(1)
		var com2 := c.centre_of_mass()
		var a2 := rad_to_deg(atan2(com2.x - top.x, top.y - com2.y))
		lean = maxf(lean, a2)
		if i >= int(6.0 * hz):
			lean_end += a2 / (2.0 * hz)
	d.clear()
	print("BENCH %s LEAN: a leg pushed east and held 8 s: the body got %.0f degrees off straight down at most, and sat at %.0f on average over the last 2 s" % [id, lean, lean_end])
	c.remove()
	await _step(int(1.5 * hz))


func _haul(id: String, world: Node3D, rope: Dictionary) -> void:
	# ---- HAUL
	var c := _hang(world, rope)
	var d: Drivers.ScriptDriver = c.driver
	await _step(int(3.0 * hz))
	var base := c.centre_of_mass()
	var grip0 := c.limb_end(0)
	var rise := 0.0
	var side := 0.0
	var up_v := 0.0
	var over := -9.0
	var grip_up := 0.0
	d.set_limb(1, true, Vector2(0, 1))  # the free hand, straight up
	for i in int(3.0 * hz):
		await _step(1)
		rise = maxf(rise, c.centre_of_mass().y - base.y)
		side = maxf(side, absf(c.centre_of_mass().x - base.x))
		over = maxf(over, c.centre_of_mass().y - c.limb_end(0).y)
		grip_up = maxf(grip_up, c.limb_end(0).y - grip0.y)
		up_v = maxf(up_v, (c.bodies["chest"] as RigidBody3D).linear_velocity.y)
	d.set_limb(1, false)
	await _step(int(5.0 * hz))  # (let it hang still again)
	var base2 := c.centre_of_mass()
	var rise2 := 0.0
	d.set_limb(2, true, Vector2(0, -1))  # a leg, straight down
	for i in int(3.0 * hz):
		await _step(1)
		rise2 = maxf(rise2, c.centre_of_mass().y - base2.y)
		over = maxf(over, c.centre_of_mass().y - c.limb_end(0).y)
		grip_up = maxf(grip_up, c.limb_end(0).y - grip0.y)
		up_v = maxf(up_v, (c.bodies["chest"] as RigidBody3D).linear_velocity.y)
	d.clear()
	print("BENCH %s HAUL: the free hand held straight up 3 s: the body's middle rose %.2f m at most and went %.2f m sideways; then, hanging still again, a leg held straight down 3 s: rose %.2f m. The body's middle got %.2f m above its gripping hand at most (hanging, it is %.2f m below it); the gripping hand itself was carried %.2f m up. Fastest upward %.1f m/s. Still holding on: %s" % [
		id, rise, side, rise2, over, grip0.y - base.y, grip_up, up_v, c.limbs[0].grab_other != null])
	c.remove()
	await _step(int(1.5 * hz))


func _climb(id: String, world: Node3D, rope: Dictionary, top: Vector2) -> void:
	# ---- CLIMB
	var c := _hang(world, rope)
	var d: Drivers.ScriptDriver = c.driver
	await _step(int(3.0 * hz))
	var from := c.centre_of_mass()
	var want := minf(3.0, top.y - from.y - 1.6)  # (never into the rope's own top)
	var takes := 0
	var grip := 0  # the hand holding on
	var tc := 0.0
	var lost := false
	var done_t := -1.0
	var highest := 0.0
	while tc < 25.0 and not lost and done_t < 0.0:
		var free := 1 - grip
		c.limbs[free].regrip = 0.0
		# point the free hand at the rope, 0.6 m above the gripping hand, for up to 1.2 s
		var held_for := 0.0
		while held_for < 1.2:
			var g := c.limb_end(grip)
			var up := (top - g).normalized()
			d.point_limb(free, true, g + up * 0.6)
			await _step(1)
			held_for += 1.0 / hz
			tc += 1.0 / hz
			highest = maxf(highest, c.centre_of_mass().y - from.y)
			if highest >= want and done_t < 0.0:
				done_t = tc
			if c.limb_end(free).distance_to(g + up * 0.6) < 0.08 and held_for > 0.25:
				break
		d.set_limb(free, false)
		await _step(int(0.25 * hz))
		tc += 0.25
		if OS.get_cmdline_user_args().has("--trace"):
			print("BENCH trace t=%.2f held %.2f took=%s free hand %.2f above grip, middle %.2f below grip, up %.2f" % [tc, held_for, c.limbs[free].grab_other != null, c.limb_end(free).y - c.limb_end(grip).y, c.limb_end(grip).y - c.centre_of_mass().y, c.centre_of_mass().y - from.y])
		if c.limbs[free].grab_other != null:
			takes += 1
			grip = free
			# let go with the lower hand: pressing it does that, the next round
		elif c.limbs[grip].grab_other == null:
			lost = true
	d.clear()
	print("BENCH %s CLIMB: hand over hand, to get the body's middle %.1f m up: %s; a hand took the rope %d times%s" % [
		id, want, ("%.1f s" % done_t) if done_t >= 0.0 else ("not in %.0f s (it got %.2f m)" % [tc, highest]), takes, " (it lost the rope)" if lost else ""])
	c.remove()
	await _step(int(1.5 * hz))


func _survey(world: Node3D, only: String) -> void:
	for rope: Dictionary in pk.things.ropes:
		var id := str(rope.id)
		if bool(rope.planks) or id.begins_with("bench_") or (only != "" and str(rope.area) != only and id != only):
			continue
		var segs: Array = rope.segs
		var first: RigidBody3D = segs[0]
		var last: RigidBody3D = segs[segs.size() - 1]
		var strung := not _hangs(rope)
		var c: Climber
		if strung:
			# a line between two points: hang from its middle, and see how far it sags
			var a0 := Vector2(first.global_position.x, first.global_position.y)
			var b0 := Vector2(last.global_position.x, last.global_position.y)
			c = _hang(world, rope, segs.size() / 2)
			await _step(int(5.0 * hz))
			var h := c.limb_end(0)
			var on_line := a0.lerp(b0, clampf((h.x - a0.x) / (b0.x - a0.x), 0.0, 1.0)) if absf(b0.x - a0.x) > 0.01 else a0
			print("SURVEY %s %s %s %.1f m, strung between two points %.1f m apart: under a climber at its middle the hand hangs %.2f m below the straight line; holding on: %s" % [
				rope.area, id, rope.kind, float(rope.seg_len) * segs.size(), a0.distance_to(b0), on_line.y - h.y, c.limbs[0].grab_other != null])
			c.remove()
			await _step(int(1.0 * hz))
			continue
		c = _hang(world, rope)
		await _step(int(3.0 * hz))
		var d: Drivers.ScriptDriver = c.driver
		var east := 0.0
		var west := 0.0
		var east_deg := 0.0
		var west_deg := 0.0
		var crossings: Array = []
		var last_x := 0.0
		var t := 0.0
		while t < 20.0:
			var v := c.velocity()
			d.set_limb(3, true, Vector2(1 if v.x >= 0.0 else -1, 0))
			await _step(1)
			t += 1.0 / hz
			var top := Vector2(first.global_position.x, first.global_position.y) + Vector2(first.global_basis.y.x, first.global_basis.y.y) * float(rope.seg_len) * 0.5
			var h := c.limb_end(0)
			var x := h.x - top.x
			var deg := rad_to_deg(atan2(x, top.y - h.y))
			east = maxf(east, x)
			west = maxf(west, -x)
			east_deg = maxf(east_deg, deg)
			west_deg = maxf(west_deg, -deg)
			if last_x < 0.0 and x >= 0.0:
				crossings.append(t)
			last_x = x
		var period := 0.0
		if crossings.size() >= 3:
			period = (float(crossings[crossings.size() - 1]) - float(crossings[1])) / (crossings.size() - 2)
		print("SURVEY %s %s %s %.1f m%s: pumped 20 s, the gripping hand got %.1f m east (%.0f deg) and %.1f m west (%.0f deg) of the rope's top; there and back %s; holding on: %s" % [
			rope.area, id, rope.kind, float(rope.seg_len) * segs.size(), " with a weight on its end" if rope.bob != null else "",
			east, east_deg, west, west_deg, ("%.1f s" % period) if period > 0.0 else "(too few swings to time)", c.limbs[0].grab_other != null])
		c.remove()
		await _step(int(1.0 * hz))


## A rope that hangs from one point (the far end free, or a weight on it), not one strung
## between two.
func _hangs(rope: Dictionary) -> bool:
	return (rope.joints as Array).size() == (rope.segs as Array).size() + (1 if rope.bob != null else 0)


func _fling(id: String, world: Node3D, rope: Dictionary) -> void:
	var out: Array = []
	for hold_s: float in [0.5, 0.9, 1.4]:
		var c := _hang(world, rope)
		var d: Drivers.ScriptDriver = c.driver
		await _step(int(3.0 * hz))
		var from := c.centre_of_mass()
		d.set_limb(3, true, Vector2(1, 1).normalized())
		await _step(int(hold_s * hz))
		d.clear()
		c.release_all()
		for l in c.limbs:
			l.regrip = 999.0
		var v := c.velocity()
		var far := 0.0
		for i in int(6.0 * hz):
			await _step(1)
			var p := c.centre_of_mass()
			far = p.x - from.x
			if p.y < from.y - 2.0:
				break
		out.append("held %.1f s: leaves at %.1f m/s (%.1f east, %.1f up), comes down %.1f m east" % [hold_s, v.length(), v.x, v.y, far])
		c.remove()
		await _step(int(1.0 * hz))
	print("BENCH %s FLING: from a still hang, a leg thrown east and up: %s" % [id, "; ".join(out)])
