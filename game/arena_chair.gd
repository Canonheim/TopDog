extends RigidBody3D
## The authoritative loose prop collides with the arena. A carried chair has no physical load.
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
var in_bubble := true
var bubble: MeshInstance3D
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


func setup(draw_model: bool, thresholds: Vector2i) -> void:
	dent_hits = thresholds
	hit_shape.size = SIZE
	var col := CollisionShape3D.new()
	col.shape = hit_shape
	add_child(col)
	if draw_model:
		_show_stage(0)
		bubble = MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.67
		sphere.height = 1.34
		bubble.mesh = sphere
		var surface := StandardMaterial3D.new()
		surface.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		surface.albedo_color = Color(0.47, 0.84, 1.0, 0.21)
		surface.roughness = 0.16
		bubble.material_override = surface
		bubble.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(bubble)
	axis_lock_linear_z = true
	collision_layer = 0
	collision_mask = Climber.LAYER_WORLD | Climber.LAYER_FROZEN
	contact_monitor = true
	max_contacts_reported = 4
	continuous_cd = true
	mass = 0.7
	freeze = true
	collision_mask = 0
	loose_target = transform
	previous = transform


func float_above(top: Vector2) -> void:
	in_bubble = true
	if bubble != null:
		bubble.show()
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
	var p := to_local(Vector3(end.x, end.y, 0))
	return p.distance_to(p.clamp(-SIZE * 0.5, SIZE * 0.5)) <= float(c.limbs[i].end_r) + 0.02


func pick_up(c: Climber, i: int) -> void:
	var end: RigidBody3D = c.bodies[c.limbs[i].def.end]
	grip_point = to_local(end.global_position).clamp(-SIZE * 0.5, SIZE * 0.5)
	carrier_rids.clear()
	for body: RigidBody3D in c.bodies.values():
		carrier_rids.append(body.get_rid())
	last_hand = end.global_position
	in_bubble = false
	if bubble != null:
		bubble.hide()
	holder = c.climber_id
	thrower = -1
	limb = i
	freeze = true
	collision_mask = 0
	previous = global_transform
	carry_velocity = Vector3.ZERO
	carry_spin = 0


func follow(c: Climber, dt: float) -> void:
	var ld: Dictionary = c.limbs[limb].def
	var end: RigidBody3D = c.bodies[ld.end]
	var forearm := end.global_position - (c.bodies[ld.lo] as RigidBody3D).global_position
	var direction := Vector2(forearm.x, forearm.y)
	if grip_point.y > 0:
		direction = -direction
	var facing := Basis(Vector3.BACK, direction.angle() - PI * 0.5)
	var basis_next := global_basis.slerp(facing, 1.0 - exp(-14.0 * dt)).orthonormalized()
	# Follow the steady lower limb rather than the independently spinning wrist.
	# Keep the broad face in front of the body mesh while held.
	var grip := end.global_position + Vector3.BACK * 0.12
	var previous_grip := global_transform * grip_point
	grip = previous_grip.lerp(grip, 1.0 - exp(-55.0 * dt))
	global_transform = Transform3D(basis_next, grip - basis_next * grip_point)
	var hand_velocity := (end.global_position - last_hand) / dt
	carry_velocity = carry_velocity.lerp(hand_velocity, 1.0 - exp(-35.0 * dt))
	last_hand = end.global_position


func drop(c: Climber, dt: float) -> void:
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
	collision_mask = Climber.LAYER_WORLD | Climber.LAYER_FROZEN
	global_position.z = 0
	Climber.sync_server(self)
	linear_velocity = Vector3(carry_velocity.x, carry_velocity.y, 0).limit_length(8)
	angular_velocity = Vector3.BACK * clampf(carry_spin, -10, 10)
	previous = global_transform
	sleeping = false


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
	query.collision_mask = Climber.LAYER_LIVE
	query.exclude = carrier_rids
	for result in get_world_3d().direct_space_state.intersect_shape(query, 128):
		var piece: CollisionObject3D = result.collider
		if piece.has_meta("climber"):
			var owner_climber: Climber = piece.get_meta("climber")
			expired.erase(owner_climber.climber_id)
	for id in expired:
		recent_hits.erase(id)
