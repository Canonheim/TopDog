extends RefCounted
## 81 atlas onion pieces: 9 whole bulbs, 18 halves, 27 crescents and 27 diced chunks.
const Flight = preload("res://ui3d/treasure_effect.gd").TreasureFlight
const TYPES := ["0","1","2","3","4","5","6","7","8","9","10","11","12","13"]
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
		var sequence := [0,1,2,3,0,1,12,13,12,13,12,13,4,5,6,7,4,5,6,7,4,8,9,10,11,8,9,10,11,8]
		for i in 30: choices.append({"variant":(i+region)%4 if i<3 else sequence[i],"size":(i+region)%3,"emit":not (i>=3 and i<6)})
		for i in range(29,0,-1):
			var j := rng.randi_range(0,i)
			var swap = choices[i]
			choices[i] = choices[j]
			choices[j] = swap
		for i in 30:
			var choice: Dictionary = choices[i]
			# Sample every original slot, including omitted bulbs, preserving the other trajectories.
			var start_position=Vector3(rng.randf_range(-.25,.25),.6,-5)
			var start_rotation=Vector3(rng.randf_range(-PI,PI),rng.randf_range(-PI,PI),rng.randf_range(-PI,PI))
			var start_scale=Vector3.ONE*(.70+choice.size*.09+rng.randf_range(-.025,.025))
			var lane := region*5+i%5
			var layer := i/5
			var launch_velocity=Vector3(lerpf(-2.7,2.7,(lane+rng.randf_range(.15,.85))/15.0)*spread+lean,lerpf(.6,5.4,(layer+rng.randf_range(.15,.85))/6.0)*lift,rng.randf_range(-.2,.2))
			var launch_spin=Vector3(rng.randf_range(-1.7,1.7),rng.randf_range(-1.7,1.7),rng.randf_range(-2.4,2.4))
			var launch_delay=rng.randf_range(0,.3)
			if not choice.emit:continue
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
			p.position=start_position
			p.rotation=start_rotation
			p.scale=start_scale
			p.velocity=launch_velocity
			p.spin=launch_spin
			p.delay=launch_delay
			p.hide()
	root.get_tree().create_timer(3.2).timeout.connect(root.queue_free)
	return root
