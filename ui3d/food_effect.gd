extends RefCounted
static var scenes := {}
const TYPES := ["taco", "tamale", "chile_relleno", "enchilada", "elote", "lime_wedge", "tortilla_chip", "red_salsa", "green_salsa", "yellow_cheese", "white_cheese"]
const QUOTA := [0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,7,8,8,8,9,9,9,9,9,10,10,10,10,10]
static func burst(camera: Node3D,big := false) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var lean := rng.randf_range(-.2,.2)
	var lift := rng.randf_range(.94,1.06)
	var spread := rng.randf_range(.94,1.06)
	var root := Node3D.new()
	root.name = "FoodBurst"
	root.set_meta("burst_profile",[lean,lift,spread,rng.randi()])
	camera.add_child(root)
	var per_region := 30
	for region in 3:
		var choices: Array = []
		for i in per_region:
			choices.append(QUOTA[i])
		for i in range(choices.size()-1,0,-1):
			var j := rng.randi_range(0,i)
			var temp: int = choices[i]
			choices[i] = choices[j]
			choices[j] = temp
		for i in per_region:
			var p := FoodFlight.new()
			var key: String = TYPES[choices[i]]
			if not scenes.has(key):
				scenes[key] = load("res://kit/models/food_"+key+".glb")
			var food: Node3D = scenes[key].instantiate()
			p.add_child(food)
			CelPass.celify(food)
			for mesh: MeshInstance3D in food.find_children("*","MeshInstance3D",true,false):
				mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			p.set_meta("coverage_region",region)
			p.set_meta("shape",choices[i])
			p.set_meta("size_class",i%3)
			root.add_child(p)
			p.position = Vector3(rng.randf_range(-.25,.25),.4,-5)
			if big:
				p.position.x += -2.6 if i%2 == 0 else 2.6
				p.position.y = -.6
			p.rotation = Vector3(rng.randf_range(-.8,.8),rng.randf_range(-.8,.8),rng.randf_range(-PI,PI))
			p.base_size = rng.randf_range(.65,.75)+(i%3)*.10
			p.scale = Vector3.ONE*p.base_size
			var lane := region*5+i%5
			var layer := i/5
			p.velocity = Vector3(lerpf(-3.8,3.8,(lane+rng.randf_range(.1,.9))/15)*spread+lean,lerpf(.8,6.5,(layer+rng.randf_range(.1,.9))/6)*lift,rng.randf_range(-.18,.18))
			if big:
				p.velocity.x -= p.position.x*.55
				p.velocity.y *= 1.18
			p.spin = Vector3(rng.randf_range(-5,5),rng.randf_range(-5,5),rng.randf_range(-6,6))
			p.phase = rng.randf_range(0,TAU)
			p.delay = rng.randf_range(0,.24)
			p.lifetime = 3.2 if big else 2.65
			p.hide()
	root.get_tree().create_timer(3.6 if big else 3.0).timeout.connect(root.queue_free)
	return root

class FoodFlight extends Node3D:
	var velocity := Vector3.ZERO
	var spin := Vector3.ZERO
	var delay := 0.0
	var age := 0.0
	var lifetime := 2.65
	var phase := 0.0
	var base_size := 1.0
	func _process(dt: float) -> void:
		if delay > 0:
			delay -= dt
			return
		show()
		age += dt
		velocity.y -= 3.1*dt
		velocity *= exp(-.58*dt)
		position += velocity*dt
		rotate_object_local(Vector3.RIGHT,spin.x*dt)
		rotate_object_local(Vector3.UP,spin.y*dt)
		rotate_object_local(Vector3.BACK,spin.z*dt)
		scale = Vector3.ONE*base_size*clampf((lifetime-age)/.22,0,1)
		if age >= lifetime:
			queue_free()
