extends RefCounted
const Launch = preload("res://ui3d/common_effects/launch_frame.gd")
## Shared cached props; motion matches the approved common-effect previews.
const DATA = preload("res://ui3d/common_effects/group2/data.gd")
static var meshes := {}
static var preparation_usec := {}
static func data() -> Dictionary:
	return {"effects":DATA.EFFECTS}
static func prepare_variant(effect: String,index: int) -> void:
	prepare_one(DATA.EFFECTS[effect].variants[index])
static func effect_meshes(effect: String) -> Array:
	var result: Array = []
	for name in DATA.EFFECTS[effect].variants:
		if meshes.has(name): result.append(meshes[name])
	return result
static func prepare_one(name: String) -> void:
	if meshes.has(name): return
	var start := Time.get_ticks_usec()
	var scene: PackedScene = load("res://ui3d/common_effects/group2/assets/"+name+".glb")
	var temporary := scene.instantiate()
	var sources := temporary.find_children("*","MeshInstance3D",true,false)
	if temporary is MeshInstance3D: sources.append(temporary)
	assert(sources.size()==1,"Exactly one mesh per baked prop")
	var mesh: Mesh = sources[0].mesh
	assert(mesh.get_surface_count()==1)
	mesh.surface_set_material(0,CelPass.one())
	meshes[name]=mesh
	temporary.free()
	preparation_usec[name]=Time.get_ticks_usec()-start
static func burst(camera: Camera3D,id: String) -> Node3D:
	var config: Dictionary = data().effects[id]
	var quota: Array = config.quota
	for name: String in quota: prepare_one(name)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var root := Node3D.new()
	root.name=id+"_review_burst"
	root.set_meta("burst_profile",[rng.randi(),rng.randf_range(-.18,.18),rng.randf_range(.92,1.08)])
	camera.add_child(root)
	Launch.align(root, .4 if id in ["nuts_acorns","tea_time","coffee_break","ice_cream_social"] else -.525)
	var gentle := id in ["tea_time","coffee_break"]
	var compact_toss := gentle or id in ["nuts_acorns","ice_cream_social"]
	var n := quota.size()
	for region in 3:
		var choices := quota.duplicate()
		for i in range(n-1,0,-1):
			var j := rng.randi_range(0,i)
			var swap: String = choices[i]
			choices[i]=choices[j]
			choices[j]=swap
		for i in n:
			var p := Flight.new()
			p.mesh=meshes[choices[i]]
			p.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			p.set_meta("region",region)
			p.set_meta("family",choices[i])
			p.set_meta("size_class",i%3)
			p.base_size=rng.randf_range(.92,1.10)+(i%3)*.18
			root.add_child(p)
			p.position=Vector3(rng.randf_range(-1.25,1.25),rng.randf_range(-1.3,.25),rng.randf_range(-5.2,-4.8))
			if compact_toss:
				p.position=Vector3(rng.randf_range(-.25,.25),.4,-5)
			p.rotation=Vector3(rng.randf_range(-PI,PI),rng.randf_range(-PI,PI),rng.randf_range(-PI,PI))
			var lane := region*4+i%4
			var layers := int(ceil(float(n)/4.0))
			p.velocity=Vector3(lerpf(-7.3,7.3,(lane+rng.randf_range(.05,.95))/12.0),lerpf((1.4 if gentle else .8) if compact_toss else -1.2,6.6,(int(i/4)+rng.randf_range(.1,.9))/layers),rng.randf_range(-.22,.22))
			if gentle:
				p.velocity*=.58
				p.gravity=2.0
			p.velocity.x+=float(root.get_meta("burst_profile")[1])
			p.velocity.y*=float(root.get_meta("burst_profile")[2])
			p.spin=Vector3(rng.randf_range(-4.3,4.3),rng.randf_range(-4.3,4.3),rng.randf_range(-5.2,5.2))
			if gentle: p.spin*=.48
			if choices[i].begins_with("tea_bag"):
				p.flutter=.30
				p.phase=rng.randf_range(0,TAU)
				p.spin*=.55
			p.delay=rng.randf_range(0,.28)
			p.scale=Vector3.ONE*p.base_size
			p.hide()
	root.get_tree().create_timer(3.2).timeout.connect(root.queue_free)
	return root
class Flight extends MeshInstance3D:
	var velocity := Vector3.ZERO
	var spin := Vector3.ZERO
	var delay := 0.0
	var age := 0.0
	var base_size := 1.0
	var gravity := 3.1
	var flutter := 0.0
	var phase := 0.0
	func _process(dt: float) -> void:
		if delay>0:
			delay-=dt
			return
		show()
		age+=dt
		velocity.y-=gravity*dt
		velocity*=exp(-.55*dt)
		position+=velocity*dt
		rotate_object_local(Vector3.RIGHT,spin.x*dt)
		rotate_object_local(Vector3.UP,spin.y*dt)
		rotate_object_local(Vector3.BACK,(spin.z+flutter*cos(age*3.2+phase))*dt)
		scale=Vector3.ONE*base_size*maxf(.0001,clampf((2.85-age)/.22,0,1))
		if age>=2.85: queue_free()
