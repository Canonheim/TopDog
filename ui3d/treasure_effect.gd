extends RefCounted
## Atlas treasure with fresh burst profiles and balanced screen coverage.
const TYPES := ["gold_shilling","silver_coin","gold_doubloon","ruby","sapphire","emerald","amethyst","diamond","amber","pearl_necklace","gold_chain","silver_goblet","royal_chalice","jeweled_ring","gold_ingot","crown","gold_key","pearl_drop"]
static var scenes := {}

static func burst(camera: Node3D) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var lean := rng.randf_range(-.30,.30)
	var lift := rng.randf_range(.94,1.06)
	var spread := rng.randf_range(.90,1.10)
	var origin := Vector3(rng.randf_range(-.16,.16),rng.randf_range(-.05,.05),0)
	var root := Node3D.new()
	root.name = "TreasureBurst"
	root.set_meta("burst_profile",[origin,lean,lift,spread])
	camera.add_child(root)
	# Each screen third receives every type, plus the same coin/gem quota.
	var choices: Array = []
	for region in 3:
		var group: Array = TYPES.duplicate()
		for i in 12:
			group.append(TYPES[i%9])
		for i in range(group.size()-1,0,-1):
			var j := rng.randi_range(0,i)
			var swap: String = group[i]
			group[i] = group[j]
			group[j] = swap
		choices.append_array(group)
	for serial in 90:
		var key: String = choices[serial]
		if not scenes.has(key):
			scenes[key] = load("res://kit/models/treasure_"+key+".glb")
		var flight := TreasureFlight.new()
		flight.name = "Treasure%d" % serial
		flight.set_meta("treasure_type",key)
		root.add_child(flight)
		var model: Node3D = scenes[key].instantiate()
		flight.add_child(model)
		CelPass.celify(model)
		for mesh: MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		flight.position = Vector3(rng.randf_range(-.3,.3),.6,-5)+origin
		flight.rotation = Vector3(rng.randf_range(-PI,PI),rng.randf_range(-PI,PI),rng.randf_range(-PI,PI))
		var region := serial/30
		var local_index := serial%30
		var size_class := local_index%3
		flight.scale = Vector3.ONE*rng.randf_range(.5+size_class*.115,.6+size_class*.115)
		flight.set_meta("coverage_region",region)
		flight.set_meta("size_class",size_class)
		var lane := region*5+(local_index*3)%5
		var layer := local_index/5
		var vx := lerpf(-2.7,2.7,(lane+rng.randf_range(.2,.8))/15.0)
		var vy := lerpf(.6,5.4,(layer+rng.randf_range(.15,.85))/6.0)
		flight.velocity = Vector3(vx*spread+lean,vy*lift,rng.randf_range(-.25,.25))
		flight.set_meta("coverage_lane",lane)
		flight.spin = Vector3(rng.randf_range(-3,3),rng.randf_range(-3,3),rng.randf_range(-4,4))
		flight.delay = rng.randf_range(0,.3)
		flight.hide()
	root.get_tree().create_timer(3.2).timeout.connect(func():
		if is_instance_valid(root):
			root.queue_free())
	return root

class TreasureFlight extends Node3D:
	var velocity := Vector3.ZERO
	var spin := Vector3.ZERO
	var delay := 0.0
	var age := 0.0
	func _process(delta: float) -> void:
		if delay > 0:
			delay -= delta
			return
		show()
		age += delta
		velocity += Vector3(0,-3,0)*delta
		velocity *= exp(-.45*delta)
		position += velocity*delta
		rotate_object_local(Vector3.RIGHT,spin.x*delta)
		rotate_object_local(Vector3.UP,spin.y*delta)
		rotate_object_local(Vector3.BACK,spin.z*delta)
		if age >= 2.8:
			queue_free()
