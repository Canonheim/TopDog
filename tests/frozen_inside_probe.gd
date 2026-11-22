extends Node
## FROZEN-INSIDE PROBE (Parker 11-22: a frozen climber's foot "has penetrated and severed and made
## this guy stuck ... This sort of thing can't happen"). S1: a live climber dropped onto an
## upside-down frozen climber's feet never ends sunk in them. S2: a climber frozen with its foot
## INSIDE a standing live one (as online, where the frozen pose comes from its owner's machine):
## Climber.free_from must leave the live one clear. `-- --old` runs the piece-by-piece nudge alone
## (what it replaced), which left it stuck 8 times in 9.
var world: Node3D
var floor_rid: RID
var next_id := 1
var fails := 0
const Layout := preload("res://climber/body_layout.gd")
const GameScript := preload("res://game/game.gd")


func _ready() -> void:
	get_tree().create_timer(170).timeout.connect(func(): print("TIMEOUT"); get_tree().quit(1))
	world = Node3D.new()
	add_child(world)
	var floor_body := StaticBody3D.new()
	floor_body.collision_layer = Climber.LAYER_WORLD
	floor_body.position.y = -0.1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(60, 0.2, 2)
	shape.shape = box
	floor_body.add_child(shape)
	world.add_child(floor_body)
	floor_rid = floor_body.get_rid()
	var ccd := "--ccd" in OS.get_cmdline_user_args()
	print("CCD on every piece: ", ccd)

	# S1: drops onto an upside-down frozen climber's feet, from several heights and offsets.
	var stuck := 0
	var runs := 0
	for h in [1.0, 2.5, 4.0]:
		for dx in [-0.25, -0.1, 0.0, 0.1, 0.25]:
			var a := await _frozen_upside_down(Vector2(0, 0))
			var foot: Vector3 = a.bodies["foot_l"].global_position
			var b := _climber(Vector2(foot.x + dx - 0.0, foot.y + h), ccd)
			await _ticks(240)
			var d := _deepest(b, a)
			runs += 1
			if d > 0.05:
				stuck += 1
				print("  S1 h %.1f dx %.2f: STUCK %.3f m deep (%s)" % [h, dx, d, _which(b, a)])
			b.remove()
			a.remove()
			await _ticks(2)
	print("S1 drops: %d of %d ended stuck" % [stuck, runs])
	fails += stuck

	# S2: the foot appears inside a standing climber's chest at the freeze.
	stuck = 0
	runs = 0
	for dy in [-0.2, 0.0, 0.2]:
		for dx in [-0.1, 0.0, 0.1]:
			var b := _climber(Vector2(0, 0), ccd)
			await _ticks(120)
			var chest: Vector3 = b.bodies["chest"].global_position
			var a := _climber(Vector2(6, 0), false)
			await _ticks(30)
			var p := _upside_down_pose(a)
			var k := Layout.ORDER.find("foot_l") * 3
			var shift := Vector2(chest.x + dx - p[k], chest.y + dy - p[k + 1])
			for i in range(0, p.size(), 3):
				p[i] += shift.x
				p[i + 1] += shift.y
			a.apply_pose(p)
			a.freeze()
			for body in a.bodies.values():
				Climber.sync_server(body)
			if "--old" in OS.get_cmdline_user_args():
				_free_locked_overlaps(b)
			else:
				b.free_from(a)
			await _ticks(240)
			var d := _deepest(b, a)
			runs += 1
			if d > 0.05:
				stuck += 1
				print("  S2 dx %.2f dy %.2f: STUCK %.3f m deep (%s), stuck limbs %d" % [dx, dy, d, _which(b, a), b.stuck_count()])
			b.remove()
			a.remove()
			await _ticks(2)
	print("S2 freezes inside: %d of %d ended stuck" % [stuck, runs])
	fails += stuck
	print("RESULT fails=", fails)
	get_tree().quit(mini(fails, 100))


func _climber(feet: Vector2, ccd: bool) -> Climber:
	var c := Climber.new()
	c.climber_id = next_id
	next_id += 1
	add_child(c)
	c.build(feet, world, null)
	if ccd:
		for body in c.bodies.values():
			(body as RigidBody3D).continuous_cd = true
	return c


func _ticks(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _upside_down_pose(c: Climber) -> PackedFloat32Array:
	var p := c.pose()
	var k := Layout.ORDER.find("pelvis") * 3
	var piv := Vector2(p[k], p[k + 1])
	for i in range(0, p.size(), 3):
		var at := (Vector2(p[i], p[i + 1]) - piv).rotated(PI) + piv
		p[i] = at.x
		p[i + 1] = at.y
		p[i + 2] += PI
	return p


func _frozen_upside_down(at: Vector2) -> Climber:
	var a := _climber(Vector2(at.x + 6, 0), false)
	await _ticks(20)
	var p := _upside_down_pose(a)
	var lo := INF
	for i in range(1, p.size(), 3):
		lo = minf(lo, p[i])
	for i in range(0, p.size(), 3):
		p[i] += at.x - (a.pose()[Layout.ORDER.find("pelvis") * 3])
		p[i + 1] += 0.25 - lo
	a.apply_pose(p)
	a.freeze()
	for body in a.bodies.values():
		Climber.sync_server(body)
	await _ticks(2)
	return a


func _deepest(who: Climber, into: Climber) -> float:
	var deepest := 0.0
	var holding := {}
	for l in who.limbs:
		if l.grab_other != null and Climber.climber_of(l.grab_other) == into:
			holding[l.def.end] = true  # a hand or foot planted on the frozen climber: its own business
	for pname in who.bodies:
		if not holding.has(pname):
			deepest = maxf(deepest, _depth(who.bodies[pname], into))
	return deepest


func _depth(rb: RigidBody3D, into: Climber) -> float:
	var q := PhysicsTestMotionParameters3D.new()
	q.from = rb.global_transform
	q.motion = Vector3.ZERO
	q.margin = 0.001
	q.recovery_as_collision = true
	var ex: Array[RID] = [floor_rid]
	q.exclude_bodies = ex
	var r := PhysicsTestMotionResult3D.new()
	if PhysicsServer3D.body_test_motion(rb.get_rid(), q, r) and Climber.climber_of(r.get_collider()) == into:
		return r.get_travel().length()
	return 0.0


func _which(who: Climber, into: Climber) -> String:
	var out := []
	for pname in who.bodies:
		if _depth(who.bodies[pname], into) > 0.05:
			out.append(pname + ("(holding)" if who.limbs.any(func(l): return l.def.end == pname and l.grab_other != null) else ""))
	return ",".join(out)


## Game._free_locked_overlaps, as it runs on a freeze.
func _free_locked_overlaps(actor: Climber) -> void:
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
