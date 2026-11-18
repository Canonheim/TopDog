extends RefCounted
## Owner-side, fixed-cost recognition. No shape queries, raycasts or spawned nodes.
const STABLE_SECONDS := .30
const MIN_AIR_SECONDS := .35
var armed := false
var flying := false
var landing := false
var last_angle := 0.0
var rotation_sum := 0.0
var completed_turn := false
var air_time := 0.0
var stable_time := 0.0
var landing_time := 0.0

func reset() -> void:
	armed=false; flying=false; landing=false
	rotation_sum=0.0; completed_turn=false; air_time=0.0; stable_time=0.0; landing_time=0.0

## feet: bit 1 left / bit 2 right. bad: any other external contact or grip.
func step(angle: float, feet: int, bad: bool, airborne: bool, upright: bool, dt: float) -> bool:
	if dt<=0.0: return false
	if not flying and not landing:
		if feet!=0 or bad or not airborne:
			armed=true
			last_angle=angle
			return false
		if not armed: return false # spawning in midair is not a takeoff
		flying=true
		rotation_sum=0.0; completed_turn=false; air_time=0.0
	if flying:
		var turn := wrapf(angle-last_angle,-PI,PI)
		last_angle=angle
		if absf(turn)>1.0: # implausible per-tick discontinuity / teleport
			reset()
			return false
		rotation_sum+=turn
		completed_turn=completed_turn or absf(rotation_sum)>=TAU-.01
		air_time+=dt
		if bad:
			reset()
			return false
		if feet!=0:
			landing=completed_turn and air_time>=MIN_AIR_SECONDS
			flying=false; stable_time=0.0; landing_time=0.0
			if not landing:
				armed=true
				return false
		elif not airborne:
			reset()
			return false
	if landing:
		landing_time+=dt
		if bad or feet==0 or not upright or landing_time>1.0:
			reset()
			return false
		# One foot may touch first; both must settle before awarding.
		stable_time=stable_time+dt if feet==3 else 0.0
		if stable_time>=STABLE_SECONDS:
			reset()
			armed=true
			return true
	return false

func observe(c: Climber, dt: float) -> bool:
	if c.growing() or c.sinking or c.knockout_left>0:
		reset()
		return false
	var chest: RigidBody3D = c.bodies["chest"]
	if not flying and not landing and c.is_attached():
		armed=true
		last_angle=chest.rotation.z
		return false
	var feet := 0
	var bad := false
	for name in c.bodies:
		var body: RigidBody3D = c.bodies[name]
		var state := PhysicsServer3D.body_get_direct_state(body.get_rid())
		if state==null: continue
		for i in state.get_contact_count():
			var other := state.get_contact_collider_object(i)
			if other==null or Climber.climber_of(other)==c: continue
			var solid: bool = other is CollisionObject3D and (other.collision_layer & (Climber.LAYER_WORLD|Climber.LAYER_FROZEN))!=0
			var normal: Vector3 = body.global_basis*state.get_contact_local_normal(i)
			if solid and name in ["foot_l","foot_r"] and normal.y>.35:
				feet |= 1 if name=="foot_l" else 2
			else: bad=true
	# Welds disable collisions with their anchor: read existing grip data too.
	for limb in c.limbs:
		var other: Object = limb.grab_other
		if not is_instance_valid(other): continue
		var solid: bool = other is CollisionObject3D and (other.collision_layer & (Climber.LAYER_WORLD|Climber.LAYER_FROZEN))!=0
		var end: String = limb.def.end
		if solid and end in ["foot_l","foot_r"] and c.bodies[end].global_position.y<chest.global_position.y-.3*c.body_scale:
			feet |= 1 if end=="foot_l" else 2
		else: bad=true
	if not c.held_by.is_empty(): bad=true
	var upright := chest.global_basis.y.y>cos(deg_to_rad(40.0)) and absf(chest.linear_velocity.y)<1.0
	return step(chest.rotation.z,feet,bad,not c.is_attached(),upright,dt)
