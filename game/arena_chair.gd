extends RigidBody3D
## The chair and its gripping limb share a fixed physics joint until release.
signal terrain_struck(at: Vector3, speed: float)
signal rope_struck(at: Vector3, speed: float)

var grip_joint := RID()
var terrain_contacts := {}
var incoming_linear := Vector3.ZERO
var incoming_angular := Vector3.ZERO
const MODELS := [
	preload("res://kit/models/folding_chair.glb"),
	preload("res://kit/models/folding_chair_damage_1.glb"),
	preload("res://kit/models/folding_chair_damage_2.glb"),
]
const BREAK_HITS := 20
var dent_hits: Vector2i
var hit_count := 0
var model: Node3D
const SIZE := Vector3(0.49, 1.08, 0.13)
const PICKUP_HEIGHT := 0.76
const TURN_RATE := TAU / 12.0
const BOB_HEIGHT := 0.045
const BOB_RATE := TAU / 2.8
var float_time := 0.0
var in_bubble := true:
	set(value):
		if in_bubble == value:
			return
		if not value and bubble != null and is_inside_tree():
			var burst := preload("res://game/bubble_pop.gd").new()
			get_parent().add_child(burst)
			burst.global_transform = bubble.global_transform
			Sound.play_at("bubble_pop", bubble.global_position, 0.0, get_parent(), Sound.SFX["bubble_pop"].pick_random())
		in_bubble = value
		collision_layer = 0 if value else Climber.LAYER_PROP
		collision_mask = 0 if value else Climber.SOLID_MASK
		float_time = 0.0
		if bubble != null:
			bubble.visible = value
			_pose_pickup()
		set_physics_process(value)
		if collider != null and not value:
			collider.transform = Transform3D.IDENTITY
var bubble: MeshInstance3D
const BUBBLE_INK := 0.015  # the bubble's outline width, metres
const HIT_SPEED := 1.8
const LIGHT_HIT_MAX_SPEED := 4.5  # Contact-point speed in m/s.
var holder := -1
var thrower := -1
var limb := -1
var grip_point := Vector3.ZERO
var hit_shape := BoxShape3D.new()
var previous := Transform3D.IDENTITY
var recent_hits := {}
var carry_velocity := Vector3.ZERO
var carry_spin := 0.0
var last_hand := Vector3.ZERO
var carrier_rids: Array[RID] = []
var loose_target := Transform3D.IDENTITY
var rope_wait := 0.0
var exceptions: Array[PhysicsBody3D] = []
var collider: CollisionShape3D


func setup(draw_model: bool, thresholds: Vector2i) -> void:
	dent_hits = thresholds
	hit_shape.size = SIZE
	collider = CollisionShape3D.new()
	collider.shape = hit_shape
	add_child(collider)
	if draw_model:
		_show_stage(0)
		bubble = MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.67
		sphere.height = 1.34
		bubble.mesh = sphere
		var surface := ShaderMaterial.new()
		surface.shader = preload("res://shaders/pickup_bubble.gdshader")
		bubble.material_override = surface
		bubble.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(bubble)
		# THE BUBBLE'S INK (Parker 11-09): an inverse hull, a slightly bigger sphere drawn
		# inside-out; the shader keeps only the rim ring so the chair still shows through.
		var hull := MeshInstance3D.new()
		hull.name = "BubbleHull"
		var shell := SphereMesh.new()
		shell.radius = sphere.radius + BUBBLE_INK
		shell.height = shell.radius * 2.0
		hull.mesh = shell
		var ink := ShaderMaterial.new()
		ink.shader = preload("res://shaders/bubble_hull.gdshader")
		ink.set_shader_parameter("inner_radius", sphere.radius)
		ink.set_shader_parameter("ink", Color.WHITE)  # white, Parker 11-09
		hull.material_override = ink
		hull.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		bubble.add_child(hull)
	axis_lock_linear_z = true
	collision_layer = 0 if in_bubble else Climber.LAYER_PROP
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	contact_monitor = true
	max_contacts_reported = 24
	continuous_cd = true
	mass = 0.7
	freeze = true
	collision_mask = 0 if in_bubble else Climber.SOLID_MASK
	loose_target = transform
	previous = transform


func _ready() -> void:
	set_physics_process(in_bubble)


func _physics_process(delta: float) -> void:
	float_time += delta
	_pose_pickup()


func _pose_pickup() -> void:
	# The solid box turns with the folded model; the bubble is decorative.
	var offset := global_basis.inverse() * Vector3.UP * (BOB_HEIGHT * sin(float_time * BOB_RATE))
	var angle := fmod(float_time * TURN_RATE, TAU)
	collider.transform = Transform3D(Basis(Vector3.UP, angle), offset)
	if bubble != null:
		bubble.position = offset
		model.position = offset + Vector3.DOWN * SIZE.y * 0.5
		model.rotation.y = angle

func float_above(top: Vector2) -> void:
	in_bubble = true
	clear_grip()
	terrain_contacts.clear()
	set_carrier(null)
	collision_layer = 0
	freeze = true
	collision_mask = 0
	thrower = -1
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_transform = Transform3D(Basis(Vector3.BACK, -0.18), Vector3(top.x, top.y + PICKUP_HEIGHT, 0))
	previous = global_transform
	loose_target = global_transform


func set_hit_count(count: int) -> void:
	var old_stage := damage_stage()
	hit_count = clampi(count, 0, BREAK_HITS)
	if model != null and damage_stage() != old_stage:
		_show_stage(damage_stage())


func damage_stage() -> int:
	if hit_count >= dent_hits.y:
		return 2
	return 1 if hit_count >= dent_hits.x else 0


## Scatter the actual frame, seat, legs and hardware around their own centers.
## Fragments can bounce off the scenery and never deal hits or accept grips.
func break_apart(pose: Transform3D, impact: Vector3) -> Node3D:
	if model == null:
		return null
	global_transform = pose
	if damage_stage() != 2:
		_show_stage(2)
	var debris := Node3D.new()
	get_parent().add_child(debris)
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		var bounds := mesh.get_aabb()
		var center := mesh.to_global(bounds.get_center())
		var fragment := RigidBody3D.new()
		fragment.collision_layer = 0
		fragment.collision_mask = Climber.LAYER_WORLD | Climber.LAYER_FROZEN
		var shape := BoxShape3D.new()
		shape.size = (bounds.size * mesh.global_basis.get_scale().abs()).max(Vector3.ONE * 0.015)
		var col := CollisionShape3D.new()
		col.shape = shape
		fragment.add_child(col)
		debris.add_child(fragment)
		fragment.global_transform = Transform3D(mesh.global_basis.orthonormalized(), center)
		mesh.reparent(fragment, true)
		var radial := (center - pose.origin).normalized()
		fragment.linear_velocity = impact.limit_length(1.5) + radial * 1.6 + Vector3.UP
		fragment.angular_velocity = Vector3(radial.y, -radial.x, radial.x + radial.y) * 5.0
	var timer := debris.create_tween()
	timer.tween_interval(0.9)
	timer.tween_callback(debris.queue_free)
	return debris

func _show_stage(stage: int) -> void:
	if model != null:
		remove_child(model)
		model.queue_free()
	model = MODELS[stage].instantiate() as Node3D
	model.position.y = -SIZE.y * 0.5
	add_child(model)


func can_reach(c: Climber, i: int) -> bool:
	var end := c.limb_end(i)
	var p := collider.to_local(Vector3(end.x, end.y, 0))
	return p.distance_to(p.clamp(-SIZE * 0.5, SIZE * 0.5)) <= float(c.limbs[i].end_r) + 0.02


func pick_up(c: Climber, i: int) -> void:
	var end: RigidBody3D = c.bodies[c.limbs[i].def.end]
	var pickup_pose := collider.global_transform
	in_bubble = false
	global_transform = pickup_pose
	grip_point = to_local(end.global_position).clamp(-SIZE * 0.5, SIZE * 0.5)
	set_carrier(c)
	last_hand = end.global_position
	holder = c.climber_id
	thrower = -1
	limb = i
	freeze = false
	gravity_scale = 0.0
	collision_layer = Climber.LAYER_PROP
	collision_mask = Climber.SOLID_MASK
	sleeping = false
	previous = global_transform
	carry_velocity = Vector3.ZERO
	carry_spin = 0
	lock_grip(end)


func set_carrier(c: Climber) -> void:
	for body in exceptions:
		if is_instance_valid(body):
			remove_collision_exception_with(body)
	exceptions.clear()
	carrier_rids.clear()
	if c != null:
		for body: RigidBody3D in c.bodies.values():
			add_collision_exception_with(body)
			exceptions.append(body)
			carrier_rids.append(body.get_rid())


func follow(c: Climber, dt: float) -> void:
	var ld: Dictionary = c.limbs[limb].def
	var end: RigidBody3D = c.bodies[ld.end]
	var hand_velocity := (end.global_position - last_hand) / dt
	carry_velocity = carry_velocity.lerp(hand_velocity, 1.0 - exp(-35.0 * dt))
	last_hand = end.global_position


func lock_grip(end: RigidBody3D) -> void:
	clear_grip()
	freeze = false
	gravity_scale = 0.0
	sleeping = false
	# Equal hinge limits lock the final rotational axis. The solver can now
	# transmit a blocked chair's reaction directly into the hand or foot.
	Climber.sync_server(self)
	grip_joint = PhysicsServer3D.joint_create()
	var chair_frame := Transform3D(global_basis.inverse() * end.global_basis, grip_point)
	PhysicsServer3D.joint_make_hinge(grip_joint, end.get_rid(), Transform3D.IDENTITY, get_rid(), chair_frame)
	PhysicsServer3D.hinge_joint_set_param(grip_joint, PhysicsServer3D.HINGE_JOINT_LIMIT_LOWER, 0.0)
	PhysicsServer3D.hinge_joint_set_param(grip_joint, PhysicsServer3D.HINGE_JOINT_LIMIT_UPPER, 0.0)
	PhysicsServer3D.hinge_joint_set_flag(grip_joint, PhysicsServer3D.HINGE_JOINT_FLAG_USE_LIMIT, true)


func clear_grip() -> void:
	if grip_joint.is_valid():
		PhysicsServer3D.free_rid(grip_joint)
		grip_joint = RID()


func _exit_tree() -> void:
	clear_grip()


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if in_bubble or not terrain_struck.has_connections():
		return
	var touching := {}
	var strongest := 0.0
	var at := Vector3.ZERO
	for i in state.get_contact_count():
		var other := state.get_contact_collider_object(i) as PhysicsBody3D
		if other == null or not (other.collision_layer & (Climber.LAYER_WORLD | Climber.LAYER_FROZEN)):
			continue
		var id := other.get_instance_id()
		touching[id] = true
		if terrain_contacts.has(id):
			continue
		var point := state.get_contact_local_position(i)
		var velocity := incoming_linear + incoming_angular.cross(point - state.transform.origin)
		var relative := velocity - state.get_contact_collider_velocity_at_position(i)
		var speed := -relative.dot(state.get_contact_local_normal(i))
		if speed > strongest:
			strongest = speed
			at = point
	terrain_contacts = touching
	incoming_linear = state.linear_velocity
	incoming_angular = state.angular_velocity
	if strongest >= HIT_SPEED:
		terrain_struck.emit(at, strongest)


func drop(c: Climber, dt: float) -> void:
	clear_grip()
	if c != null and not c.removed:
		var end: RigidBody3D = c.bodies[c.limbs[limb].def.end]
		var measured := (end.global_position - last_hand) / dt
		if c.state == Climber.State.LIVE:
			measured = end.linear_velocity
		# A last-moment reversal takes priority over the short smoothing history.
		if measured.dot(carry_velocity) < 0 or measured.length_squared() > 0.01:
			carry_velocity = measured
	thrower = holder
	holder = -1
	limb = -1
	freeze = false
	gravity_scale = 1.0
	collision_mask = Climber.SOLID_MASK
	collision_layer = Climber.LAYER_PROP
	Climber.sync_server(self)
	linear_velocity = Vector3(carry_velocity.x, carry_velocity.y, 0).limit_length(8)
	angular_velocity = Vector3.BACK * clampf(carry_spin, -10, 10)
	previous = global_transform
	sleeping = false


func release_carrier_when_clear() -> void:
	if exceptions.is_empty():
		return
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = hit_shape
	query.transform = global_transform
	query.margin = 0.025
	query.collision_mask = Climber.LAYER_LIVE | Climber.LAYER_FROZEN
	for contact in get_world_3d().direct_space_state.intersect_shape(query, 128):
		if carrier_rids.has(contact.rid):
			return
	set_carrier(null)


func tick_ropes(dt: float) -> void:
	rope_wait = maxf(0.0, rope_wait - dt)
	if Climber.rope_x <= 0:
		return
	var p := global_position
	var half := SIZE * 0.5
	var extent := global_basis.x.abs() * half.x + global_basis.y.abs() * half.y + global_basis.z.abs() * half.z
	var edge := absf(p.x) + extent.x
	var side := signf(p.x)
	if edge < Climber.rope_x - 0.12 or absf(p.x) > Climber.rope_x + 0.3 or p.y + extent.y < Climber.ROPE_LOW or p.y - extent.y > Climber.ROPE_HIGH:
		return
	if rope_wait > 0:
		if holder >= 0 and linear_velocity.x * side > 0:
			linear_velocity.x = 0.0
		return
	if linear_velocity.x * side > 0.3:
		var speed := absf(linear_velocity.x)
		linear_velocity.x *= -Feel.get_k("rope_bounce")
		rope_wait = Climber.ROPE_COOLDOWN
		rope_struck.emit(Vector3(side * Climber.rope_x, p.y, 0), speed)


func settle() -> void:
	if linear_velocity.length_squared() > 1.0 or get_colliding_bodies().is_empty():
		return
	var face := global_basis.z
	if face.y < 0:
		face = -face
	if face.y < 0.99:
		sleeping = false
		apply_torque(face.cross(Vector3.UP) * 2.5 - angular_velocity * 0.15)
	elif sleeping:
		thrower = -1


func sweep_hits(dt: float, excluded_id: int) -> Dictionary:
	var current := global_transform
	var displacement := current.origin - previous.origin
	var q := (current.basis * previous.basis.inverse()).orthonormalized().get_rotation_quaternion()
	if q.w < 0:
		q = -q
	var angle := q.get_angle()
	var omega := q.get_axis() * angle / dt if angle > 0.0001 else Vector3.ZERO
	if holder >= 0:
		carry_spin = omega.z
	_expire_hits(dt)
	var hits := {}
	var travel := displacement.length() + angle * SIZE.length() * 0.5
	if travel / dt >= HIT_SPEED:
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = hit_shape
		query.margin = 0.012  # Include resting separation at a physical impact.
		query.collision_mask = Climber.LAYER_LIVE
		var space := get_world_3d().direct_space_state
		var steps := clampi(ceili(travel / 0.06), 1, 24)
		for step in range(1, steps + 1):
			query.transform = previous.interpolate_with(current, float(step) / steps)
			var ignored: Array[RID] = carrier_rids.duplicate()
			for contact in 32:
				query.exclude = ignored
				var hit := space.get_rest_info(query)
				if hit.is_empty():
					break
				ignored.append(hit.rid)
				var piece := instance_from_id(hit.collider_id) as RigidBody3D
				if piece == null or not piece.has_meta("climber"):
					continue
				var victim: Climber = piece.get_meta("climber")
				var id := victim.climber_id
				if id == excluded_id or victim.removed or victim.state == Climber.State.FROZEN or recent_hits.has(id):
					continue
				var point: Vector3 = hit.point
				var speed := displacement / dt + omega.cross(point - query.transform.origin)
				speed.z = 0
				if speed.length() >= HIT_SPEED:
					var impulse := speed.normalized() * minf(victim.total_mass * 0.75, piece.mass * speed.length() * 0.85)
					hits[id] = {"piece": piece.get_meta("piece"), "offset": piece.to_local(point), "impulse": impulse, "speed": speed.length()}
					recent_hits[id] = 0.35
	previous = current
	return hits


# A long scrape across several pieces of one ragdoll is still a single impact.
func _expire_hits(dt: float) -> void:
	var expired := []
	for id in recent_hits:
		recent_hits[id] -= dt
		if recent_hits[id] <= 0:
			expired.append(id)
	if expired.is_empty():
		return
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = hit_shape
	query.transform = global_transform
	query.margin = 0.025
	query.collision_mask = Climber.LAYER_LIVE
	query.exclude = carrier_rids
	for result in get_world_3d().direct_space_state.intersect_shape(query, 128):
		var piece: CollisionObject3D = result.collider
		if piece.has_meta("climber"):
			var owner_climber: Climber = piece.get_meta("climber")
			expired.erase(owner_climber.climber_id)
	for id in expired:
		recent_hits.erase(id)
