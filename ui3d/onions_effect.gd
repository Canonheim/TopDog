extends RefCounted
## 90 atlas onion pieces: 18 bulbs, 36 crescents and 36 diced chunks.
const Flight = preload("res://ui3d/treasure_effect.gd").TreasureFlight
const TYPES := ["0","1","2","3","4","5","6","7","8","9","10","11"]
static var scenes := {}
static func burst(camera: Node3D) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var lean := rng.randf_range(-.2,.2)
	var lift := rng.randf_range(.94,1.06)
	var spread := rng.randf_range(.94,1.06)
	var root := Node3D.new()
	root.name = "OnionsBurst"
	root.set_meta("burst_profile",[lean,lift,spread,rng.randi()])
	camera.add_child(root)
	for region in 3:
		var choices: Array = []
		var sequence := [0,1,2,3,0,1,4,5,6,7,4,5,6,7,4,5,6,7,8,9,10,11,8,9,10,11,8,9,10,11]
		for i in 30: choices.append({"variant":sequence[i],"size":(i+region)%3})
		for i in range(29,0,-1):
			var j := rng.randi_range(0,i)
			var swap = choices[i]
			choices[i] = choices[j]
			choices[j] = swap
		for i in 30:
			var choice: Dictionary = choices[i]
			var key: String = TYPES[choice.variant]
			if not scenes.has(key): scenes[key] = load("res://kit/models/onion_"+key+".glb")
			var p := Flight.new()
			p.set_meta("coverage_region",region)
			p.set_meta("variant",choice.variant)
			p.set_meta("family",int(choice.variant)/4)
			p.set_meta("size_class",choice.size)
			root.add_child(p)
			var model: Node3D = scenes[key].instantiate()
			p.add_child(model)
			CelPass.celify(model)
			for mesh in model.find_children("*","MeshInstance3D",true,false): mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			p.position = Vector3(rng.randf_range(-.25,.25),.6,-5)
			p.rotation = Vector3(rng.randf_range(-PI,PI),rng.randf_range(-PI,PI),rng.randf_range(-PI,PI))
			p.scale = Vector3.ONE*(.70+choice.size*.09+rng.randf_range(-.025,.025))
			var lane := region*5+i%5
			var layer := i/5
			p.velocity = Vector3(lerpf(-2.7,2.7,(lane+rng.randf_range(.15,.85))/15.0)*spread+lean,lerpf(.6,5.4,(layer+rng.randf_range(.15,.85))/6.0)*lift,rng.randf_range(-.2,.2))
			p.spin = Vector3(rng.randf_range(-1.7,1.7),rng.randf_range(-1.7,1.7),rng.randf_range(-2.4,2.4))
			p.delay = rng.randf_range(0,.3)
			p.hide()
	root.get_tree().create_timer(3.2).timeout.connect(root.queue_free)
	return root
