extends RefCounted
## Ten short atlas shakers and 180 small grains; one surface per cached model.
static var scenes := {}
static var meshes := {}
const TYPES := ["short","grain"]
const PIECES := 190
static func burst(camera: Node3D,big := false) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var lean := rng.randf_range(-.2,.2)
	var lift := rng.randf_range(.94,1.06)
	var spread := rng.randf_range(.94,1.06)
	var root := Node3D.new()
	root.name = "SaltBurst"
	root.set_meta("burst_profile",[lean,lift,spread,rng.randi()])
	camera.add_child(root)
	for region in 3:
		var choices: Array[int] = []
		for i in (4 if region == 1 else 3): choices.append(0)
		for i in 60: choices.append(1)
		for i in range(choices.size()-1,0,-1):
			var j := rng.randi_range(0,i)
			var old := choices[i]
			choices[i] = choices[j]
			choices[j] = old
		for i in choices.size():
			var variant := choices[i]
			var grain := variant == 1
			var key: String = TYPES[variant]
			if not scenes.has(key): scenes[key] = load("res://kit/models/salt_"+key+".glb")
			if not meshes.has(key):
				var sample: Node3D = scenes[key].instantiate()
				var source: MeshInstance3D = sample.find_child("Salt",true,false)
				meshes[key] = source.mesh
				sample.free()
			var item := MeshInstance3D.new()
			item.mesh = meshes[key]
			item.material_override = CelPass.one()
			item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var p := SaltFlight.new()
			p.add_child(item)
			p.set_meta("coverage_region",region)
			p.set_meta("shape",variant)
			p.set_meta("size_class",i%3)
			p.set_meta("grain",grain)
			root.add_child(p)
			p.position = Vector3(rng.randf_range(-.25,.25),.4,-5)
			if big:
				p.position.x += -2.6 if i%2 == 0 else 2.6
				p.position.y = -.6
			# Labels start toward the viewer; varied pitch/roll and modest slow yaw.
			p.rotation = Vector3(rng.randf_range(-.4,.4),rng.randf_range(-.45,.45),rng.randf_range(-1.3,1.3))
			p.base_size = rng.randf_range(.78,.92) if not grain else rng.randf_range(1.4,2.2)
			p.scale = Vector3.ONE*p.base_size
			var lane := region*4+i%4
			var layer := i/4
			p.set_meta("coverage_lane",lane)
			p.velocity = Vector3(lerpf(-3.8,3.8,(lane+rng.randf_range(.1,.9))/12)*spread+lean,lerpf(.8,6.5,(layer+rng.randf_range(.1,.9))/16)*lift,rng.randf_range(-.15,.15))
			if big:
				p.velocity.x -= p.position.x*.55
				p.velocity.y *= 1.18
			p.spin = Vector3(rng.randf_range(-.8,.8),rng.randf_range(-.6,.6),rng.randf_range(-2.0,2.0))*(2.5 if grain else 1.0)
			p.phase = rng.randf_range(0,TAU)
			p.delay = rng.randf_range(0,.24)
			if not grain:
				# Same gravity/drag and broad random throws as the other burst effects.
				# No selected profiles, mirrored pairs, or screen-edge clamping.
				p.velocity = Vector3(rng.randf_range(-3.8,3.8)*spread+lean,rng.randf_range(.8,6.5)*lift,rng.randf_range(-.18,.18))
				if big:
					p.velocity.x -= p.position.x*.55
					p.velocity.y *= 1.18
				p.rotation = Vector3(rng.randf_range(-.8,.8),rng.randf_range(-.8,.8),rng.randf_range(-PI,PI))
				p.spin = Vector3(rng.randf_range(-2.5,2.5),rng.randf_range(-3,3),rng.randf_range(-4,4))
				p.set_meta("shaker_launch",{"start":p.position,"velocity":p.velocity,"gravity":p.gravity,"delay":p.delay,"spin":p.spin,"rotation":p.rotation})
			p.lifetime = 3.2 if big else 2.65
			p.hide()
	root.get_tree().create_timer(3.6 if big else 3.0).timeout.connect(root.queue_free)
	return root

class SaltFlight extends Node3D:
	var velocity := Vector3.ZERO
	var gravity := 3.1
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
		velocity.y -= gravity*dt
		velocity *= exp(-.58*dt)
		position += (velocity+Vector3(sin(age*7+phase)*.035,0,0))*dt
		rotate_object_local(Vector3.RIGHT,spin.x*dt)
		rotate_object_local(Vector3.UP,spin.y*dt)
		rotate_object_local(Vector3.BACK,spin.z*dt)
		scale = Vector3.ONE*base_size*clampf((lifetime-age)/.22,0,1)
		if age >= lifetime: queue_free()


