extends RefCounted
const Launch = preload("res://ui3d/common_effects/launch_frame.gd")
## Standalone only: cached exact atlas assets, no live catalog dependency.
const DATA = preload("res://ui3d/common_effects/group1/manifest_data.gd")
static var cached := {}
static var preparation_timings := {}
static func source_transform(mesh_node: Node3D, root: Node3D) -> Transform3D:
	if mesh_node==root:return mesh_node.transform
	var result := mesh_node.transform
	var ancestor := mesh_node.get_parent()
	while ancestor != null:
		if ancestor is Node3D: result = ancestor.transform * result
		if ancestor == root: break
		ancestor = ancestor.get_parent()
	return result
# The preparer loads variant_path() on a worker thread, then hands the scene to
# install_variant() on the main thread. prepare_variant() stays the synchronous
# fallback for a cold live burst.
const RESOURCE_TYPE := "PackedScene"
static func variant_path(effect: String,index: int) -> String:
	return "res://ui3d/common_effects/group1/models/"+effect+"_"+str(index)+".glb"
static func has_variant(effect: String,index: int) -> bool:
	return cached.has(effect+"_"+str(index))
static func prepare_variant(effect: String,index: int) -> void:
	if has_variant(effect,index): return
	var start := Time.get_ticks_usec()
	var scene: PackedScene = load(variant_path(effect,index))
	install_variant(effect,index,scene,Time.get_ticks_usec()-start)
static func install_variant(effect: String,index: int,scene: PackedScene,load_usec := 0) -> void:
	var key := effect+"_"+str(index)
	if cached.has(key): return
	assert(scene != null)
	var loaded := Time.get_ticks_usec()
	var start := loaded-load_usec
	var instance: Node3D = scene.instantiate()
	var instantiated := Time.get_ticks_usec()
	CelPass.celify(instance)
	var meshes := instance.find_children("*","MeshInstance3D",true,false)
	if instance is MeshInstance3D: meshes.push_front(instance)
	assert(meshes.size()==1, "Single-mesh particle asset required")
	var source: MeshInstance3D = meshes[0]
	var materials: Array[Material] = []
	for surface in source.mesh.get_surface_count():
		var material := source.get_active_material(surface)
		assert(material == CelPass.one())
		materials.append(material)
	cached[key]={"mesh":source.mesh,"materials":materials,"transform":source_transform(source,instance)}
	var extracted := Time.get_ticks_usec()
	instance.free()
	preparation_timings[key]={"resource_load_ms":(loaded-start)/1000.0,"instantiate_ms":(instantiated-loaded)/1000.0,"material_and_extract_ms":(extracted-instantiated)/1000.0,"total_ms":(Time.get_ticks_usec()-start)/1000.0}
static func configure_mesh(target: MeshInstance3D, key: String) -> void:
	var data: Dictionary = cached[key]
	target.mesh=data.mesh
	for surface in data.materials.size():target.set_surface_override_material(surface,data.materials[surface])
	target.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
static func burst(camera: Node3D,effect: String) -> Node3D:
	var rng:=RandomNumberGenerator.new()
	rng.randomize()
	var root:=Node3D.new()
	root.name=effect+"Burst"
	camera.add_child(root)
	Launch.align(root, -.45)
	root.set_meta("burst_profile",effect)
	root.set_meta("signature",[rng.randi(),rng.randf(),rng.randf()])
	var region_sequences: Array=DATA.EFFECTS[effect].sequences
	for region in 3:
		var sequence: Array=region_sequences[region]
		var choices: Array=[]
		for i in sequence.size(): choices.append({"variant":sequence[i],"size":i%3})
		for i in range(choices.size()-1,0,-1):
			var j:=rng.randi_range(0,i)
			var old=choices[i]
			choices[i]=choices[j]
			choices[j]=old
		for choice in choices:
			var variant: int=choice.variant
			prepare_variant(effect,variant)
			var p:=Flight.new()
			root.add_child(p)
			var key := effect+"_"+str(variant)
			configure_mesh(p,key)
			p.source_transform=cached[key].transform
			p.set_meta("region",region)
			p.set_meta("variant",variant)
			p.set_meta("size_class",choice.size)
			p.position=Vector3(rng.randf_range(-.48,.48),rng.randf_range(-.75,-.15),-5)
			var target_x:=rng.randf_range(-4.5+region*3.0,-1.5+region*3.0)
			var target_y:=rng.randf_range(-.8,2.6)
			var travel:=rng.randf_range(.70,.95)
			p.gravity=rng.randf_range(2.8,3.6)
			p.velocity=Vector3((target_x-p.position.x)/travel,(target_y-p.position.y+.5*p.gravity*travel*travel)/travel,rng.randf_range(-.3,.3))
			p.rotation=Vector3(rng.randf_range(-PI,PI),rng.randf_range(-PI,PI),rng.randf_range(-PI,PI))
			p.spin=Vector3(rng.randf_range(-3,3),rng.randf_range(-4,4),rng.randf_range(-5,5))
			p.base_size=.76+float(choice.size)*.15+rng.randf_range(-.045,.045)
			if effect=="breakfast_club":p.base_size*=1.8
			if effect=="pancakes":p.base_size*=1.8 if variant<6 else 1.6
			p.scale=Vector3.ONE*p.base_size
			p.delay=rng.randf_range(0,.3)
			p.motion_transform=p.transform
			p.transform=p.motion_transform*p.source_transform
			p.hide()
	root.get_tree().create_timer(3.3).timeout.connect(root.queue_free)
	return root
class Flight extends MeshInstance3D:
	var source_transform:=Transform3D.IDENTITY
	var motion_transform:=Transform3D.IDENTITY
	var velocity:=Vector3.ZERO
	var spin:=Vector3.ZERO
	var gravity:=3.1
	var delay:=0.0
	var age:=0.0
	var base_size:=1.0
	func _process(dt:float) -> void:
		if delay>0:
			delay-=dt
			return
		show()
		transform=motion_transform
		age+=dt
		velocity.y-=gravity*dt
		velocity*=exp(-.22*dt)
		position+=velocity*dt
		rotate_object_local(Vector3.RIGHT,spin.x*dt)
		rotate_object_local(Vector3.UP,spin.y*dt)
		rotate_object_local(Vector3.BACK,spin.z*dt)
		scale=Vector3.ONE*base_size*clampf((2.8-age)/.22,0,1)
		motion_transform=transform
		transform=motion_transform*source_transform
		if age>=2.8:queue_free()

static func effect_meshes(effect: String) -> Array:
	var result: Array = []
	for key in cached:
		if key.begins_with(effect+"_"):
			result.append(cached[key].mesh)
	return result
