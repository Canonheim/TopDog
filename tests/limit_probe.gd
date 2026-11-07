extends Node2D
# Pin-chain stability probe: N links hanging from a static anchor.
func link(pos: Vector2, mass: float, ccd: bool) -> RigidBody2D:
	var b := RigidBody2D.new(); var col := CollisionShape2D.new(); var c := CapsuleShape2D.new()
	c.radius = 7; c.height = 40; col.shape = c; col.rotation = PI / 2; b.add_child(col)
	b.mass = mass; b.can_sleep = false
	if ccd: b.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	b.position = pos; add_child(b); PhysicsServer2D.body_set_state(b.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, b.global_transform)
	return b

func run(n: int, mass_a: float, mass_b: float, ccd: bool, label: String):
	var root := StaticBody2D.new(); add_child(root)
	var links := []
	var joints := []
	for i in n:
		var l := link(Vector2(20 + i * 40, 0), mass_a if i % 2 == 0 else mass_b, ccd)
		links.append(l)
	for i in n:
		var rid := PhysicsServer2D.joint_create()
		var a_rid: RID = root.get_rid() if i == 0 else links[i - 1].get_rid()
		PhysicsServer2D.joint_make_pin(rid, Vector2(i * 40, 0), a_rid, links[i].get_rid())
		PhysicsServer2D.pin_joint_set_param(rid, PhysicsServer2D.PIN_JOINT_SOFTNESS, 0.0)
		joints.append(rid)
	for i in n - 1:
		links[i].add_collision_exception_with(links[i + 1])
	var worst := 0.0
	for f in 360:
		await get_tree().physics_frame
		for i in range(1, n):
			var a: RigidBody2D = links[i - 1]; var b: RigidBody2D = links[i]
			var pa := a.global_transform * Vector2(20, 0); var pb := b.global_transform * Vector2(-20, 0)
			worst = maxf(worst, pa.distance_to(pb))
	print(label, " worst gap px %.2f" % worst)
	for j in joints: PhysicsServer2D.free_rid(j)
	for l in links: l.queue_free()
	root.queue_free()
	await get_tree().physics_frame

func _ready():
	await run(4, 1.0, 1.0, false, "4 links 1kg")
	await run(8, 1.0, 1.0, false, "8 links 1kg")
	await run(8, 3.0, 0.6, false, "8 links 3/0.6kg")
	await run(8, 1.0, 1.0, true, "8 links ccd")
	get_tree().quit()
