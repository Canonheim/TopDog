extends Node
## THE ROPE SNAP PROBE (Parker 11-21: "ropes still have a tendency to freak out like crazy and make you fly
## around all weird. I think maybe they are colliding with themself? Also I keep colliding with them kinda,
## even on limbs that are not being controlled"). Headless:
##   Godot_console.exe --headless --path . res://tests/peak_rope_snap_probe.tscn
## A 6 m rope in open sky (the game's own rope builder), a climber driven as a player drives it (the
## buttons, the press stack, the lever rule), and each tick: the fastest climber piece, the body's middle,
## the fastest rope piece, the widest gap at any of the rope's pins, and every contact a climber piece
## reports with a rope piece (there should be none: ropes are passed through).
##   SNAP   the free hand steered to a point beside the rope and held still there, then attached at
##          that distance from the rope's line: what the grab alone does to the rope and the body;
##   ANCHOR the one hand on the rope steered by the stick, four ways;
##   CLIMB  hand over hand by the lever rule (the real reach): every take's distance and what followed;
##   DANGLE one hand on the rope, the other's button held but another limb steered: how often the
##          held, unsteered hand takes the rope by passing it;
##   LETGO  a hand lets go of the rope: its contacts with the rope after.
## -- --only=snap|anchor|climb|dangle|letgo runs one; -- --exc prints the rope's collision exceptions as it goes.
## (SNAP's steering is rough: the "off when attached" figure is what was really tried.)
## FOUND 11-21: on Jolt, the grab's joint (Climber.attach) took away every exception between the hand and the
## rope piece, the Peak's pass-through too, and release took the rest: each piece a limb had held was solid to
## it after. Before the fix, a hand-over-hand climb: 995 contacts with the rope, the body's middle at 9.8 m/s,
## pieces at 26 m/s with a foot; after: 0 contacts, the middle under 1 m/s.
const ClimberScript := preload("res://climber/climber.gd")
const Drivers := preload("res://climber/drivers.gd")
const DEF := {"id": "snap_rope", "kind": "rope", "at": [-80.0, 330.0], "seg": 0.5, "len": 6.0}

var pk: Peak
var hz := 120.0
var world: Node3D
var rope: Dictionary
var segset := {}
var c: Climber
var d: Drivers.ScriptDriver
var t := 0.0
var st := {}


func _ready() -> void:
	hz = float(Engine.physics_ticks_per_second)
	world = Node3D.new()
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
	pk.things._anchors["snap"] = anchor
	pk.things._build_rope({"id": "snap"}, DEF, first_anchor.get_parent())
	for r in pk.things.ropes:
		if str(r.id) == "snap_rope":
			rope = r
	for s in rope.segs:
		segset[s] = true
	for i in 4:
		await get_tree().physics_frame
	print("SNAP rope: %d pieces of %.2f kg, reach %.2f m" % [rope.segs.size(), (rope.segs[0] as RigidBody3D).mass, PeakThings.ROPE_REACH])
	var only := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			only = a.get_slice("=", 1)
	if only == "" or only == "snap":
		for dist: float in [0.02, 0.10, 0.20, 0.29]:
			await _snap(dist)
	if only == "" or only == "anchor":
		await _anchor()
	if only == "" or only == "climb":
		await _climb(false)
		await _climb(true)
	if only == "" or only == "dangle":
		await _dangle()
	if only == "" or only == "letgo":
		await _letgo()
	get_tree().quit()


func _begin(label: String) -> void:
	st = {"label": label, "body_v": 0.0, "body_who": "", "com_v": 0.0, "seg_v": 0.0, "gap": 0.0, "touch": 0, "touch_who": {}, "spikes": []}


func _step(n: int) -> void:
	for i in n:
		pk.tick(1.0 / hz)
		await get_tree().physics_frame
		t += 1.0 / hz
		_measure()


func _measure() -> void:
	if c == null or st.is_empty():
		return
	var bv := 0.0
	var who := ""
	for pname in c.bodies:
		var b: RigidBody3D = c.bodies[pname]
		var s := b.linear_velocity.length()
		if s > bv:
			bv = s
			who = str(pname)
		for o in b.get_colliding_bodies():
			if segset.has(o):
				st.touch += 1
				st.touch_who[pname] = int(st.touch_who.get(pname, 0)) + 1
	var cv := c.velocity().length()
	var sv := 0.0
	var gap := 0.0
	var half := float(rope.seg_len) * 0.5
	var segs: Array = rope.segs
	for i in segs.size():
		var a: RigidBody3D = segs[i]
		sv = maxf(sv, a.linear_velocity.length())
		if i + 1 < segs.size():
			var b: RigidBody3D = segs[i + 1]
			gap = maxf(gap, (a.global_transform * Vector3(0, -half, 0)).distance_to(b.global_transform * Vector3(0, half, 0)))
	if bv > float(st.body_v):
		st.body_v = bv
		st.body_who = who
	st.com_v = maxf(float(st.com_v), cv)
	st.seg_v = maxf(float(st.seg_v), sv)
	st.gap = maxf(float(st.gap), gap)
	if (bv > 10.0 or sv > 10.0 or cv > 5.0) and (st.spikes as Array).size() < 6:
		(st.spikes as Array).append("t%.2f piece %s %.1f, middle %.1f, rope %.1f m/s" % [t, who, bv, cv, sv])


func _report(extra := "") -> void:
	print("SNAP %s: fastest piece %.1f m/s (%s), middle %.1f, rope %.1f m/s, widest pin gap %.3f m, rope contacts %d %s%s" % [
		st.label, st.body_v, st.body_who, st.com_v, st.seg_v, st.gap, st.touch, st.touch_who if int(st.touch) > 0 else "", extra])
	for s in st.spikes:
		print("SNAP   %s" % s)
	st = {}


## A climber hung by hand 0 on the piece second from the foot, its button held (the lever rule).
func _hang() -> void:
	if c != null:
		c.remove()
		for i in int(0.5 * hz):
			pk.tick(1.0 / hz)
			await get_tree().physics_frame
	var seg: RigidBody3D = rope.segs[rope.segs.size() - 2]
	c = ClimberScript.new()
	c.climber_id = 700 + randi() % 100
	add_child(c)
	c.build(Vector2(seg.global_position.x, seg.global_position.y - 2.2), world, null)
	d = Drivers.ScriptDriver.new()
	c.driver = d
	pk.on_player(c, true)
	if OS.get_cmdline_user_args().has("--exc"):
		_exc("after on_player")
	c.release_all()
	var dd := Vector2(seg.global_position.x, seg.global_position.y) - c.limb_end(0)
	var p := c.pose()
	for k in range(0, p.size(), 3):
		p[k] += dd.x
		p[k + 1] += dd.y
	c.apply_pose(p)
	d.set_limb(0, true)
	await _step(1)
	c.attach(0, seg)
	if OS.get_cmdline_user_args().has("--exc"):
		_exc("after attach")
	for l in c.limbs:
		l.regrip = 0.0
	await _step(int(3.0 * hz))
	if OS.get_cmdline_user_args().has("--exc"):
		_exc("after 3 s")


func _exc(when: String) -> void:
	var seg: RigidBody3D = rope.segs[3]
	var foot: RigidBody3D = c.bodies["foot_r"]
	print("SNAP exc %s: piece 3 excepts %d bodies (foot_r: %s); foot_r excepts %d (piece 3: %s); climber bodies %d, ropes %d" % [
		when, seg.get_collision_exceptions().size(), seg.get_collision_exceptions().has(foot), foot.get_collision_exceptions().size(),
		foot.get_collision_exceptions().has(seg), c.bodies.size(), pk.things.ropes.size()])


## [the rope piece nearest p, its distance from p to the rope's line]
func _nearest(p: Vector2) -> Array:
	var best: RigidBody3D = null
	var best_d := INF
	var half := float(rope.seg_len) * 0.5
	for seg: RigidBody3D in rope.segs:
		var sp := Vector2(seg.global_position.x, seg.global_position.y)
		var axis := Vector2(seg.global_basis.y.x, seg.global_basis.y.y)
		var along := clampf((p - sp).dot(axis), -half, half)
		var dd := p.distance_to(sp + axis * along)
		if dd < best_d:
			best_d = dd
			best = seg
	return [best, best_d]


func _snap(dist: float) -> void:
	await _hang()
	# the free hand pressed (it is the active limb), kept from the lever's own take, steered beside the rope
	d.set_limb(1, true)
	await _step(1)
	c.limbs[1].regrip = 999.0
	var g := c.limb_end(0)
	var aim := g + Vector2(dist, 0.5)
	var settle := 0.0
	while settle < 3.0:
		d.point_limb(1, true, aim)
		await _step(1)
		settle += 1.0 / hz
		var e := c.bodies[c.limbs[1].def.end] as RigidBody3D
		if settle > 1.0 and c.limb_end(1).distance_to(aim) < 0.03 and e.linear_velocity.length() < 0.3:
			break
	var near: Array = _nearest(c.limb_end(1))
	_begin("grab %.2f m off the line (the hand %.3f m off when attached)" % [dist, near[1]])
	c.attach(1, near[0])
	c.limbs[1].regrip = 0.0
	await _step(int(0.6 * hz))
	_report()


func _anchor() -> void:
	await _hang()
	for dir: Vector2 in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
		_begin("anchor hand steered %s" % dir)
		d.set_limb(0, true, dir)
		await _step(int(1.5 * hz))
		d.set_limb(0, true)
		await _step(int(1.0 * hz))
		_report(" (holding: %s)" % (c.limbs[0].grab_other != null))


func _climb(feet: bool) -> void:
	await _hang()
	var top: Vector2 = pk.world_of(rope.top)
	var grip := 0
	var takes: Array = []
	var tc := 0.0
	_begin("climb hand over hand%s" % (", a foot taking the rope below each time" if feet else ""))
	while tc < 14.0:
		var free := 1 - grip
		var g := c.limb_end(grip)
		var up := (top - g).normalized()
		var was := false
		var held_for := 0.0
		while held_for < 1.5:
			d.point_limb(free, true, g + up * 0.6)
			await _step(1)
			held_for += 1.0 / hz
			if c.limbs[free].grab_other != null and not was:
				was = true
				var near: Array = _nearest(c.limb_end(free))
				takes.append("%.2f" % float(near[1]))
				break
		if c.limbs[free].grab_other == null:
			d.set_limb(free, false)
			await _step(int(0.3 * hz))
			tc += held_for + 0.3
			if c.limbs[grip].grab_other == null:
				break
			continue
		d.set_limb(free, true)  # keep its button down: it keeps the rope
		await _step(int(0.2 * hz))
		if feet:
			var gl := c.limb_end(free)
			var fh := 0.0
			var took := false
			while fh < 1.0 and not took:
				d.point_limb(2, true, gl + Vector2(0, -1.3))
				await _step(1)
				fh += 1.0 / hz
				took = c.limbs[2].grab_other != null
			if took:
				takes.append("foot %.2f" % float(_nearest(c.limb_end(2))[1]))
			d.set_limb(2, false)
			await _step(int(0.2 * hz))
			tc += fh + 0.2
		d.set_limb(grip, false)  # the lower hand lets go
		await _step(int(0.3 * hz))
		tc += held_for + 0.5
		grip = free
		if c.limbs[grip].grab_other == null:
			break
	d.clear()
	_report(" (takes, metres off the line: %s; still holding: %s)" % [", ".join(takes), c.stuck_count() > 0])


func _dangle() -> void:
	await _hang()
	# hand 1 pressed and held (lifted, a dangling limb), then a leg pressed on top of it and pumped
	d.set_limb(1, true)
	await _step(int(0.1 * hz))
	var took := 0
	var had := false
	_begin("dangle: hand 1's button held, a leg steered on top of it")
	var tt := 0.0
	while tt < 8.0:
		var v := c.velocity()
		d.set_limb(3, true, Vector2(1 if v.x >= 0.0 else -1, 0.3))
		await _step(1)
		tt += 1.0 / hz
		var on: bool = c.limbs[1].grab_other != null
		if on and not had:
			took += 1
		had = on
	d.clear()
	d.set_limb(0, true)
	await _step(2)
	_report(" (the held, unsteered hand took the rope %d times)" % took)


func _missing(label: String) -> void:
	var end: RigidBody3D = c.bodies[c.limbs[1].def.end]
	var miss: Array = []
	for i in rope.segs.size():
		if not (rope.segs[i] as PhysicsBody3D).get_collision_exceptions().has(end):
			miss.append(i)
	print("SNAP exc %s: rope pieces not passing %s through: %s (hand 1 holds piece %d)" % [label, end.name, miss, rope.segs.find(c.limbs[1].grab_other)])


func _letgo() -> void:
	await _hang()
	if OS.get_cmdline_user_args().has("--exc"):
		_missing("hung")
	var g := c.limb_end(0)
	var held_for := 0.0
	while held_for < 1.5 and c.limbs[1].grab_other == null:
		d.point_limb(1, true, g + Vector2(0, 0.5))
		await _step(1)
		held_for += 1.0 / hz
	var seg = c.limbs[1].grab_other
	if OS.get_cmdline_user_args().has("--exc"):
		_missing("hand 1 took it")
	d.set_limb(1, true)
	await _step(int(0.5 * hz))
	var end: RigidBody3D = c.bodies[c.limbs[1].def.end]
	var before := "hand excepts the piece %s, the piece excepts the hand %s" % [end.get_collision_exceptions().has(seg), (seg as PhysicsBody3D).get_collision_exceptions().has(end) if seg != null else false]
	_begin("let go with hand 1 (it took the rope: %s)" % (seg != null))
	d.set_limb(1, false)
	await _step(int(1.5 * hz))
	var after := "hand excepts the piece %s, the piece excepts the hand %s" % [end.get_collision_exceptions().has(seg), (seg as PhysicsBody3D).get_collision_exceptions().has(end) if seg != null else false]
	_report(" (before: %s; after: %s)" % [before, after])
