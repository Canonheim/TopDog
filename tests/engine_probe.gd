extends Node
# Same stress, two engines: an 8-link chain (masses 3/1 kg, 0.4 m links) hangs
# from a static point; every tick each joint gets a big alternating internal
# torque (both directions, equal and opposite). Report the worst joint gap.
const N := 8
const L := 0.4
var mode := ""

func _ready():
	await run2d()
	await run3d(false)
	await run3d(true)
	get_tree().quit()

func torque_at(f: int, i: int) -> float:
	return (1.0 if (f / 40 + i) % 2 == 0 else -1.0) * 120.0  # N*m (a strong shoulder)

func run2d():
	var root := Node2D.new(); add_child(root)
	var anchor := StaticBody2D.new(); root.add_child(anchor)
	var links := []
	for i in N:
		var b := RigidBody2D.new(); var col := CollisionShape2D.new(); var c := CapsuleShape2D.new()
		c.radius = 7; c.height = L * 100; col.shape = c; col.rotation = PI / 2; b.add_child(col)
		b.mass = 3.0 if i % 2 == 0 else 1.0; b.can_sleep = false
		b.position = Vector2((i + 0.5) * L * 100, 0); root.add_child(b)
		PhysicsServer2D.body_set_state(b.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, b.global_transform)
		links.append(b)
	for i in N:
		var rid := PhysicsServer2D.joint_create()
		PhysicsServer2D.joint_make_pin(rid, Vector2(i * L * 100, 0), anchor.get_rid() if i == 0 else links[i - 1].get_rid(), links[i].get_rid())
		PhysicsServer2D.pin_joint_set_param(rid, PhysicsServer2D.PIN_JOINT_SOFTNESS, 0.0)
	for i in N - 1:
		links[i].add_collision_exception_with(links[i + 1])
	var worst := 0.0
	var lim_over := 0.0
	for f in 600:
		for i in range(1, N):
			var tq := torque_at(f, i) * 10000.0  # N*m -> kg*px^2/s^2
			links[i].apply_torque(tq); links[i - 1].apply_torque(-tq)
		await get_tree().physics_frame
		for i in range(1, N):
			worst = maxf(worst, (links[i - 1].global_transform * Vector2(L * 50, 0)).distance_to(links[i].global_transform * Vector2(-L * 50, 0)) / 100.0)
	print("GODOT 2D pins: worst gap %.3f m" % worst)
	root.queue_free()
	await get_tree().physics_frame

func run3d(limits: bool):
	var root := Node3D.new(); add_child(root)
	var anchor := StaticBody3D.new(); root.add_child(anchor)
	var links := []
	for i in N:
		var b := RigidBody3D.new(); var col := CollisionShape3D.new(); var c := CapsuleShape3D.new()
		c.radius = 0.07; c.height = L; col.shape = c; col.rotation = Vector3(0, 0, PI / 2); b.add_child(col)
		b.mass = 3.0 if i % 2 == 0 else 1.0; b.can_sleep = false
		b.axis_lock_linear_z = true; b.axis_lock_angular_x = true; b.axis_lock_angular_y = true
		b.position = Vector3((i + 0.5) * L, 0, 0); root.add_child(b)
		links.append(b)
	await get_tree().physics_frame
	for i in N:
		var h := HingeJoint3D.new()
		root.add_child(h)
		h.global_transform = Transform3D(Basis(), Vector3(i * L, 0, 0))  # hinge axis = local z
		h.node_a = (anchor if i == 0 else links[i - 1]).get_path()
		h.node_b = links[i].get_path()
		if limits:
			h.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)
			h.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, deg_to_rad(-30.0))
			h.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, deg_to_rad(30.0))
	for i in N - 1:
		links[i].add_collision_exception_with(links[i + 1])
	var worst := 0.0
	var lim_over := 0.0
	for f in 600:
		for i in range(1, N):
			var tq := torque_at(f, i)
			links[i].apply_torque(Vector3(0, 0, tq)); links[i - 1].apply_torque(Vector3(0, 0, -tq))
		await get_tree().physics_frame
		for i in range(1, N):
			worst = maxf(worst, (links[i - 1].global_transform * Vector3(L * 0.5, 0, 0)).distance_to(links[i].global_transform * Vector3(-L * 0.5, 0, 0)))
			if limits:
				var rel: float = rad_to_deg(wrapf(links[i].rotation.z - links[i - 1].rotation.z, -PI, PI))
				lim_over = maxf(lim_over, absf(rel) - 30.0)
	var over := 0.0
	for i in range(1, N):
		pass
	var zdrift := 0.0
	for b in links: zdrift = maxf(zdrift, absf(b.global_position.z))
	print("JOLT 3D hinges, plane-locked, limits=%s: worst gap %.3f m, z drift %.4f m, limit overshoot %.1f deg" % [limits, worst, zdrift, lim_over])
	root.queue_free()
	await get_tree().physics_frame
