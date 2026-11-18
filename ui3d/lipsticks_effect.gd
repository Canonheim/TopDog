extends RefCounted
## 72 unbranded tubes: equal red, pink and nude families, cached atlas scenes.
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
	root.name = "LipsticksBurst"
	root.set_meta("burst_profile",[lean,lift,spread,rng.randi()])
	camera.add_child(root)
	for region in 3:
		var choices: Array = []
		for i in 24: choices.append({"variant":i%12,"size":(i/12+i%3+region)%3})
		for i in range(23,0,-1):
			var j := rng.randi_range(0,i)
			var swap = choices[i]
			choices[i] = choices[j]
			choices[j] = swap
		for i in 24:
			var choice: Dictionary = choices[i]
			var key: String = TYPES[choice.variant]
			if not scenes.has(key): scenes[key] = load("res://kit/models/lipstick_"+key+".glb")
			var p := Flight.new()
			p.set_meta("coverage_region",region)
			p.set_meta("variant",choice.variant)
			p.set_meta("family",int(choice.variant)/4)
			p.set_meta("size_class",choice.size)
			p.set_meta("base_color",int(choice.variant)%3)
			root.add_child(p)
			var model: Node3D = scenes[key].instantiate()
			p.add_child(model)
			CelPass.celify(model)
			for mesh in model.find_children("*","MeshInstance3D",true,false): mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			p.position = Vector3(rng.randf_range(-.25,.25),.6,-5)
			p.rotation = Vector3(rng.randf_range(-PI,PI),rng.randf_range(-PI,PI),rng.randf_range(-PI,PI))
			p.scale = Vector3.ONE*(.70+choice.size*.09+rng.randf_range(-.025,.025))
			var lane := region*4+i%4
			var layer := i/4
			p.velocity = Vector3(lerpf(-2.7,2.7,(lane+rng.randf_range(.15,.85))/12.0)*spread+lean,lerpf(.6,5.4,(layer+rng.randf_range(.15,.85))/6.0)*lift,rng.randf_range(-.2,.2))
			p.spin = Vector3(rng.randf_range(-3,3),rng.randf_range(-3,3),rng.randf_range(-4,4))
			p.delay = rng.randf_range(0,.3)
			p.hide()
	root.get_tree().create_timer(3.2).timeout.connect(root.queue_free)
	return root
