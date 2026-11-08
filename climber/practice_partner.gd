extends "res://climber/climber.gd"
## Practice partner: balance against the floor; leave hands and feet free on impact.
var stagger_time := 0.0


func _try_grab(_i: int) -> void:
	pass


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if stagger_time > 0:
		stagger_time -= delta
		return
	if removed or state != State.LIVE or not _touching_solid():
		return
	var chest: RigidBody3D = bodies["chest"]
	# Raise a fallen torso against its planted legs. Only help while supported.
	var feet_y := minf(limb_end(2).y, limb_end(3).y)
	var lift := clampf((1.32 * body_scale - (chest.global_position.y - feet_y)) * 18.0 - chest.linear_velocity.y * 4.0, 0, 13.0)
	chest.apply_central_force(Vector3.UP * total_mass * lift)
	for name in ["chest", "pelvis", "leg_l_up", "leg_r_up", "leg_l_lo", "leg_r_lo"]:
		var b: RigidBody3D = bodies[name]
		var error := angle_difference(angle_of(b), 0)
		b.apply_torque(Vector3.BACK * b.mass * clampf(error * 8.0 - b.angular_velocity.z * 1.7, -8.0, 8.0))
