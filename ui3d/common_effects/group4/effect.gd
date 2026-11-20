extends RefCounted
const Launch = preload("res://ui3d/common_effects/launch_frame.gd")
const DATA = preload("res://ui3d/common_effects/group4/manifest_data.gd")
static var cached := {}
static func prepare_variant(effect: String, index: int) -> void:
	CelPass.one()
	var key := effect+"_"+str(index)
	if cached.has(key): return
	var scene: PackedScene = load("res://ui3d/common_effects/group4/models/"+key+".glb")
	var instance := scene.instantiate()
	var meshes := instance.find_children("*", "MeshInstance3D", true, false)
	assert(meshes.size()==1)
	cached[key] = meshes[0].mesh
	instance.free()
static func burst(camera: Node3D, effect: String) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var root := Node3D.new()
	root.name = effect+"Burst"
	camera.add_child(root)
	Launch.align(root, -.625)
	root.set_meta("burst_profile",effect)
	var sequence: Array = DATA.EFFECTS[effect].sequence.duplicate()
	for i in range(sequence.size()-1,0,-1):
		var j := rng.randi_range(0,i)
		var swap = sequence[i]
		sequence[i] = sequence[j]
		sequence[j] = swap
	for i in sequence.size():
		var variant: int = sequence[i]
		prepare_variant(effect,variant)
		var flight := Flight.new()
		root.add_child(flight)
		var model := MeshInstance3D.new()
		model.mesh = cached[effect+"_"+str(variant)]
		model.material_override = CelPass.one()
		model.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		flight.add_child(model)
		flight.set_meta("variant",variant)
		flight.position = Vector3(rng.randf_range(-.5,.5),rng.randf_range(-.9,-.35),-5)
		var target := Vector2(rng.randf_range(-2.25,2.25),rng.randf_range(-.45,1.35))
		flight.gravity = rng.randf_range(1.3,2.0) if effect=="dog_fur" else rng.randf_range(2.4,3.2)
		var t := rng.randf_range(.7,.9)
		var travel := (1-exp(-.38*t))/.38
		flight.velocity = Vector3((target.x-flight.position.x)/travel,(target.y-flight.position.y+(flight.gravity/.38)*(t-travel))/travel,rng.randf_range(-.12,.12))
		flight.rotation = Vector3(rng.randf_range(-.7,.7),rng.randf_range(-.8,.8),rng.randf_range(-PI,PI))
		flight.spin = Vector3(rng.randf_range(-1.8,1.8),rng.randf_range(-2.0,2.0),rng.randf_range(-3.0,3.0))
		flight.base_size = rng.randf_range(.65,1.05) if effect=="bats" else rng.randf_range(.8,1.25)
		if effect=="bats":flight.base_size*=.8
		flight.scale = Vector3.ONE*flight.base_size
		flight.delay = rng.randf_range(0,.3)
		flight.hide()
	root.get_tree().create_timer(3.3).timeout.connect(root.queue_free)
	return root
class Flight extends Node3D:
	var velocity := Vector3.ZERO
	var spin := Vector3.ZERO
	var gravity := 3.1
	var delay := 0.0
	var age := 0.0
	var base_size := 1.0
	func _process(dt:float) -> void:
		if delay>0:
			delay-=dt
			return
		show()
		age+=dt
		velocity.y-=gravity*dt
		velocity*=exp(-.38*dt)
		position+=velocity*dt
		rotate_object_local(Vector3.RIGHT,spin.x*dt)
		rotate_object_local(Vector3.UP,spin.y*dt)
		rotate_object_local(Vector3.BACK,spin.z*dt)
		scale=Vector3.ONE*base_size*clampf((2.8-age)/.25,0,1)
		if age>=2.8:queue_free()


static func effect_meshes(effect: String) -> Array:
	var result: Array = []
	for key in cached:
		if key.begins_with(effect+"_"):
			result.append(cached[key])
	return result
