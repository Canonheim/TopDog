extends Node
## Persistent cosmetic only. Four meshes owned by the existing limb nodes;
## this controller stops processing after flight. No bodies, joints or forces.
const MODEL_PATH := "res://kit/models/railroad_spike.glb"
const ENDS := ["hand_l", "hand_r", "foot_l", "foot_r"]
const MARKER := "railroad_spikes_visual"
const PRESENTATION := "railroad_spikes_settled_presentation"
const FLIGHT_SECONDS := .095
const MIN_CAMERA_DISTANCE := 1.2
const NEAR_PLANE_MARGIN := .15
const STAGGER_SECONDS := .08
const TIP := Vector3(0,0,-.27)
const TRIANGLES_PER_SPIKE := 88
const MAX_MESHES_PER_CLIMBER := 4
const TYPES := ["spike"]
static var scenes := {}
static var mesh: Mesh
var pins: Array[MeshInstance3D] = []
var targets: Array[Transform3D] = []
var starts: Array[Vector3] = []
var spin_phases: Array[float] = []
var spin_turns: Array[float] = []
var launch_safety: Array = []
var launch_camera: WeakRef
var launch_uvs: Array[Vector2] = []
var launched := [false,false,false,false]
var final_rolls: Array[float] = []
var unrolled_targets: Array[Transform3D] = []
var body_size := 1.0
var launch_axes: Array[Vector3] = []
var age := 0.0
var settled := false
var burst_profile: Array = []

static func prepare() -> void:
	if mesh != null: return
	if not scenes.has("spike"): scenes.spike = load(MODEL_PATH)
	var scene: PackedScene = scenes.spike
	var sample := scene.instantiate()
	var source: MeshInstance3D = sample.find_child("RailroadSpike",true,false)
	mesh = source.mesh
	mesh.surface_set_material(0,CelPass.one())
	sample.free()

static func preview(model: Node3D, camera: Camera3D) -> Node:
	var anchors: Array[Node3D] = []
	for key in ["Hand","L_Hand","Foot","L_Foot"]:
		var part: Node3D = model.find_child(key,true,false)
		if not is_instance_valid(part): return null
		anchors.append(part)
	return attach_anchors(model,anchors,model.global_basis.get_scale().x,camera,true)

static func attach(climber: Climber, camera: Camera3D, animate := true) -> Node:
	if not is_instance_valid(climber) or climber.removed or climber.state != Climber.State.FROZEN:
		return null
	var anchors: Array[Node3D] = []
	for key in ENDS:
		var body: Node3D = climber.bodies.get(key)
		if not is_instance_valid(body): return null
		var skin: Node3D = body.find_child(Climber.Layout.PIECES[key].mesh,true,false)
		anchors.append(skin if is_instance_valid(skin) else body)
	return attach_anchors(climber,anchors,climber.body_scale,camera,animate)

## Incoming angles are local cosmetic presentation, so viewers may differ.
## Same-owner restores reuse stored skin-local poses; fresh restores without
## presentation use a deterministic surface attachment and never replay flight.
static func attach_anchors(owner_node: Node, anchors: Array[Node3D], size: float,
		camera: Camera3D, animate := true) -> Node:
	if anchors.size() != 4 or not owner_node.is_inside_tree(): return null
	if owner_node.has_meta(MARKER):
		var old: Node = owner_node.get_meta(MARKER)
		if is_instance_valid(old) and not old.is_queued_for_deletion():
			if not animate: old.settle()
			return old
	prepare()
	var effect := new()
	effect.name = "RailroadSpikes"
	effect.body_size = size
	owner_node.add_child(effect)
	owner_node.set_meta(MARKER,effect)
	effect.set_meta("persistent_lock_effect",true)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var ring_phase := rng.randf_range(-PI,PI)
	var sectors := [0,1,2,3]
	for j in range(3,0,-1):
		var k := rng.randi_range(0,j)
		var previous: int = sectors[j]
		sectors[j] = sectors[k]
		sectors[k] = previous
	var can_fly := animate and is_instance_valid(camera) and camera.is_inside_tree()
	if can_fly: effect.launch_camera = weakref(camera)
	for i in 4:
		var anchor := anchors[i]
		var unrolled := _anchor_transform(anchor,size)
		var final_roll := settled_roll(owner_node,i)
		var target := unrolled*Transform3D(Basis(Vector3.BACK,final_roll),Vector3.ZERO)
		var saved: Array = owner_node.get_meta(PRESENTATION,[])
		if not can_fly and saved.size()==4 and saved[i] is Transform3D:
			target = saved[i]
			unrolled = target*Transform3D(Basis(Vector3.BACK,-final_roll),Vector3.ZERO)
		effect.launch_axes.append(Vector3.ZERO)
		effect.final_rolls.append(final_roll)
		effect.unrolled_targets.append(unrolled)
		var pin := MeshInstance3D.new()
		pin.name = "RailroadSpike"
		pin.mesh = mesh
		pin.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		anchor.add_child(pin)
		pin.transform = target
		effect.pins.append(pin)
		effect.targets.append(target)
		if can_fly:
			# Rotating, jittered ring: four directions, no fixed limb/quadrant pairing.
			var angle: float = ring_phase+sectors[i]*TAU/4.0+rng.randf_range(-.45,.45)
			var uv := Vector2(.5,.5)+Vector2(cos(angle),sin(angle))*rng.randf_range(.27,.43)
			var pixel := uv*camera.get_viewport().get_visible_rect().size
			var ray := camera.project_ray_normal(pixel)
			var origin := camera.project_ray_origin(pixel)
			var forward := -camera.global_basis.z.normalized()
			# Bounding sphere encloses every spin orientation. Its closest point
			# stays >=1.2m from camera and >=.15m beyond the near plane at launch.
			var bounds := mesh.get_aabb()
			var radius := 0.0
			for corner in 8: radius = maxf(radius,bounds.get_endpoint(corner).length()*size)
			var depth := maxf(MIN_CAMERA_DISTANCE+radius,camera.near+radius+NEAR_PLANE_MARGIN)+rng.randf_range(0,.35)
			var start := origin+ray*((depth-(origin-camera.global_position).dot(forward))/maxf(ray.dot(forward),.001))
			effect.starts.append(start)
			effect.launch_uvs.append(uv)
			var phase: float = sectors[i]*TAU/4.0+rng.randf_range(-.2,.2)
			var turns := rng.randf_range(1.0,1.65)*(-1.0 if rng.randf()<.5 else 1.0)
			effect.spin_phases.append(phase)
			effect.spin_turns.append(turns)
			effect.launch_safety.append({"radius":radius,"depth":depth,"distance":start.distance_to(camera.global_position)})
			effect.burst_profile.append([uv,phase,turns,depth])
			pin.visible = false
	if not can_fly: effect.settle()
	return effect

static func settled_roll(owner_node: Node, limb_index: int) -> float:
	# Existing replicated identity determines the settled roll. Neither the local
	# camera nor cosmetic RNG can alter it; snapshot restoration needs no new RPC.
	var stable := RandomNumberGenerator.new()
	var cid := 0
	var pid := 0
	if owner_node is Climber:
		cid = owner_node.climber_id
		pid = owner_node.player_id
	stable.seed = 1729+cid*73856093+pid*19349663
	var phase := stable.randf_range(-PI,PI)
	var jitter := 0.0
	for i in range(limb_index+1): jitter = stable.randf_range(-.03,.03)
	return phase+limb_index*TAU/32.0+jitter  # distinct even modulo octagonal-head symmetry

static func _anchor_transform(anchor: Node3D, size: float, launch := Vector3.INF) -> Transform3D:
	# Intersect actual skin triangles, not a bounding-box plane. The attachment
	# is skin-local so it follows the rendered extremity as well as its body.
	var faces: Array[Vector3] = []
	var meshes := anchor.find_children("*","MeshInstance3D",true,false)
	if anchor is MeshInstance3D: meshes.append(anchor)
	for item: MeshInstance3D in meshes:
		if item.mesh == null or item.name == "RailroadSpike": continue
		var local := anchor.global_transform.affine_inverse()*item.global_transform
		for vertex in item.mesh.get_faces(): faces.append(local*vertex)
	var normal := (anchor.global_basis.inverse()*Vector3.BACK).normalized()
	var local_launch := anchor.to_local(launch) if launch.is_finite() else Vector3.INF
	var local_scale := size/maxf(absf(anchor.global_basis.get_scale().x),.001)
	var contact := normal*.12*local_scale
	if not faces.is_empty():
		var low := faces[0]
		var high := faces[0]
		for vertex in faces:
			low = low.min(vertex)
			high = high.max(vertex)
		var centre_bounds := (low+high)*.5
		var origin := centre_bounds+normal*((high-low).length()+1.0)
		if local_launch.is_finite():
			origin = local_launch
			normal = (origin-centre_bounds).normalized()
		var nearest := INF
		# A triangle centroid is a guaranteed on-surface fallback for concave skins.
		var front := -INF
		for i in range(0,faces.size(),3):
			var centre := (faces[i]+faces[i+1]+faces[i+2])/3.0
			if centre.dot(normal)>front:
				front = centre.dot(normal)
				contact = centre
		for i in range(0,faces.size(),3):
			var hit: Variant = Geometry3D.ray_intersects_triangle(origin,-normal,faces[i],faces[i+1],faces[i+2])
			if hit != null and origin.distance_squared_to(hit)<nearest:
				nearest = origin.distance_squared_to(hit)
				contact = hit
		if nearest == INF:
			# Concave centre-ray miss: cast toward an actual triangle centroid,
			# then use the FIRST surface along that ray, never an occluded back face.
			var ray := (contact-origin).normalized()
			for i in range(0,faces.size(),3):
				var hit: Variant = Geometry3D.ray_intersects_triangle(origin,ray,faces[i],faces[i+1],faces[i+2])
				if hit != null and origin.distance_squared_to(hit)<nearest:
					nearest = origin.distance_squared_to(hit)
					contact = hit
		if local_launch.is_finite(): normal = (origin-contact).normalized()
	var up := Vector3.UP if absf(normal.dot(Vector3.UP)) < .95 else Vector3.RIGHT
	var basis := Basis.looking_at(-normal,up).scaled(Vector3.ONE*local_scale)
	# Six millimetres of tip penetration; compensate the model's off-origin tip.
	return Transform3D(basis,contact-normal*.006*local_scale-basis*TIP)

func refresh_launch(index: int) -> void:
	var camera: Camera3D = launch_camera.get_ref() if launch_camera != null else null
	if not is_instance_valid(camera): return
	var radius: float = launch_safety[index].radius
	var depth := maxf(float(launch_safety[index].depth),camera.near+radius+NEAR_PLANE_MARGIN)
	var pixel := launch_uvs[index]*camera.get_viewport().get_visible_rect().size
	var ray := camera.project_ray_normal(pixel)
	var origin := camera.project_ray_origin(pixel)
	var forward := -camera.global_basis.z.normalized()
	starts[index] = origin+ray*((depth-(origin-camera.global_position).dot(forward))/maxf(ray.dot(forward),.001))
	launch_safety[index].depth = depth
	launch_safety[index].distance = starts[index].distance_to(camera.global_position)
	# Compute once at actual delayed launch, after camera safety has been refreshed.
	var anchor: Node3D = pins[index].get_parent()
	unrolled_targets[index] = _anchor_transform(anchor,body_size,starts[index])
	targets[index] = unrolled_targets[index]*Transform3D(Basis(Vector3.BACK,final_rolls[index]),Vector3.ZERO)
	launch_axes[index] = -(anchor.global_transform*targets[index]).basis.z.normalized()

func _process(delta: float) -> void:
	age += delta
	for i in pins.size():
		var pin := pins[i]
		if not is_instance_valid(pin):
			queue_free()
			return
		var t := clampf((age-i*STAGGER_SECONDS)/FLIGHT_SECONDS,0,1)
		pin.visible = age >= i*STAGGER_SECONDS
		if not pin.visible: continue
		if not launched[i]:
			refresh_launch(i)
			launched[i] = true
		if t >= 1:
			pin.transform = targets[i]
			continue
		var final_world: Transform3D = pin.get_parent().global_transform*targets[i]
		var final_tip := final_world*TIP
		var direction := final_tip-starts[i]
		var start_tip := starts[i]+direction.normalized()*.27*final_world.basis.get_scale().z
		var tip_position := start_tip.lerp(final_tip,pow(t,1.35))
		var unrolled_world: Transform3D = pin.get_parent().global_transform*unrolled_targets[i]
		# Incoming aim remains the embedded aim. Only roll changes during flight.
		var forward_rotation := unrolled_world.basis.orthonormalized().get_rotation_quaternion()
		var cycles := maxf(1.0,roundf(absf(spin_turns[i])))
		var delta_roll := fposmod(final_rolls[i]-spin_phases[i],TAU)+TAU*cycles
		if spin_turns[i]<0: delta_roll = -fposmod(spin_phases[i]-final_rolls[i],TAU)-TAU*cycles
		var roll := spin_phases[i]+delta_roll*t
		var rotation := Basis(forward_rotation*Quaternion(Vector3.BACK,roll)).scaled(final_world.basis.get_scale())
		pin.global_transform = Transform3D(rotation,tip_position-rotation*TIP)
	if age >= FLIGHT_SECONDS+3*STAGGER_SECONDS: settle()

func settle() -> void:
	for i in pins.size():
		if is_instance_valid(pins[i]):
			if launch_camera != null and not launched[i]:
				refresh_launch(i)
				launched[i] = true
			pins[i].transform = targets[i]
			pins[i].visible = true
	get_parent().set_meta(PRESENTATION,targets.duplicate())
	settled = true
	starts.clear()
	launch_camera = null
	set_process(false)

func _exit_tree() -> void:
	# Also handles removing the controller while the climber itself survives.
	for pin in pins:
		if is_instance_valid(pin) and not pin.is_queued_for_deletion(): pin.queue_free()
