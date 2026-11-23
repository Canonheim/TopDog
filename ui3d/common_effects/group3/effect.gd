extends RefCounted
const Launch = preload("res://ui3d/common_effects/launch_frame.gd")
## Approved motion with shared immutable native meshes and the house atlas.
const DATA = preload("res://ui3d/common_effects/group3/data.gd")
static var meshes := {}
# The preparer loads variant_path() on a worker thread, then hands the mesh to
# install_variant() on the main thread. prepare_variant() stays the synchronous
# fallback for a cold live burst.
const RESOURCE_TYPE := "Mesh"
static func variant_path(effect: String,index: int) -> String:
	return DATA.EFFECTS[effect].variants[index]
static func has_variant(effect: String,index: int) -> bool:
	return meshes.has(variant_path(effect,index))
static func prepare_variant(effect: String,index: int) -> void:
	if has_variant(effect,index): return
	var source: Mesh = load(variant_path(effect,index))
	install_variant(effect,index,source)
static func install_variant(effect: String,index: int,source: Mesh) -> void:
	var path := variant_path(effect,index)
	if meshes.has(path): return
	assert(source != null)
	for surface in source.get_surface_count(): source.surface_set_material(surface,CelPass.one())
	meshes[path] = source
static func effect_meshes(effect: String) -> Array:
	var result: Array = []
	for path in DATA.EFFECTS[effect].variants:
		if meshes.has(path): result.append(meshes[path])
	return result
static func make_mesh(effect: String,index: int) -> MeshInstance3D:
	prepare_variant(effect,index)
	var item := MeshInstance3D.new()
	item.mesh = meshes[DATA.EFFECTS[effect].variants[index]]
	item.material_override = CelPass.one()
	item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return item
static func burst(camera: Node3D,effect: String) -> Node3D:
	var root := Burst.new()
	root.name = effect+"Burst"
	camera.add_child(root)
	Launch.align(root, -.75)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in int(DATA.EFFECTS[effect].pieces):
		var item := make_mesh(effect,i%DATA.EFFECTS[effect].variants.size())
		root.add_child(item)
		item.position = Vector3(rng.randf_range(-.3,.3),rng.randf_range(-.85,-.65),-5)
		item.rotation = Vector3(rng.randf_range(-.45,.45),rng.randf_range(-.6,.6),rng.randf_range(-3.14,3.14))
		var size := rng.randf_range(.85,1.25)
		item.scale = Vector3.ONE*size
		var target := Vector2(rng.randf_range(-2.1,2.1),rng.randf_range(-.45,1.1))
		var travel := (1.0-exp(-.58*.7))/.58
		item.set_meta("velocity",Vector3((target.x-item.position.x)/travel,(target.y-item.position.y+(3.1/.58)*(.7-travel))/travel,0))
		item.set_meta("spin",Vector3(rng.randf_range(-2.1,2.1),rng.randf_range(-2.1,2.1),rng.randf_range(-3,3)))
		item.set_meta("age",-rng.randf_range(0,.22))
		item.set_meta("size",size)
		item.hide()
	root.set_meta("burst_profile",rng.state)
	root.get_tree().create_timer(3.1).timeout.connect(root.queue_free)
	return root

class Burst extends Node3D:
	func _process(dt: float) -> void:
		for item in get_children():
			var age: float = item.get_meta("age")+dt
			item.set_meta("age",age)
			if age<0: continue
			item.show()
			var v: Vector3 = item.get_meta("velocity")
			v.y -= 3.1*dt
			v *= exp(-.58*dt)
			item.position += v*dt
			item.set_meta("velocity",v)
			item.rotation += item.get_meta("spin")*dt
			item.scale = Vector3.ONE*float(item.get_meta("size"))*clampf((2.8-age)/.3,0,1)
