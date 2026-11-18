extends RefCounted
## 18 unlabelled bottles, 18 detached caps, 54 soda drops. Atlas only, no glass shells.
const Flight = preload("res://ui3d/treasure_effect.gd").TreasureFlight
const TYPES := ["bottle_0","bottle_1","bottle_2","bottle_3","bottle_4","cap_0","cap_1","cap_2","cap_3","cap_4","drop_0","drop_1","drop_2","drop_3","drop_4"]
static var scenes := {}

static func burst(camera: Node3D) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var root := Node3D.new()
	root.name = "SodasBurst"
	var lean := rng.randf_range(-.2,.2)
	var lift := rng.randf_range(.94,1.06)
	var spread := rng.randf_range(.94,1.06)
	var flavor_offset := rng.randi_range(0,4)
	root.set_meta("burst_profile",[lean,lift,spread,flavor_offset,rng.randi()])
	camera.add_child(root)
	for region in 3:
		var choices: Array = []
		for family in 3:
			for i in (18 if family == 2 else 6):
				choices.append({"family":family,"color":(i+flavor_offset)%5,"size":i%3})
		for i in range(29,0,-1):
			var j := rng.randi_range(0,i)
			var swap = choices[i]
			choices[i] = choices[j]
			choices[j] = swap
		for i in 30:
			var choice: Dictionary = choices[i]
			var variant: int = choice.family*5+choice.color
			var key: String = TYPES[variant]
			# Shared scene adapter normally prepares every model before selection.
			# This immediate fallback preserves lock timing if preparation is early.
			if not scenes.has(key): scenes[key] = load("res://kit/models/soda_"+key+".glb")
			var p = SodaDrop.new() if choice.family == 2 else Flight.new()
			p.set_meta("coverage_region",region)
			p.set_meta("family",choice.family)
			p.set_meta("color",choice.color)
			p.set_meta("size_class",choice.size)
			root.add_child(p)
			var model: Node3D = scenes[key].instantiate()
			p.add_child(model)
			CelPass.celify(model)
			for mesh in model.find_children("*","MeshInstance3D",true,false):
				mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			p.position = Vector3(rng.randf_range(-.25,.25),.6,-5)
			p.rotation = Vector3(rng.randf_range(-PI,PI),rng.randf_range(-PI,PI),rng.randf_range(-PI,PI))
			var base: float = [.65,.95,.70][choice.family]
			p.scale = Vector3.ONE*(base+choice.size*.08+rng.randf_range(-.025,.025))
			if choice.family == 2:
				p.scale = Vector3.ONE*([.48,.85,1.28][choice.size]+rng.randf_range(-.035,.035))
			var lane := region*5+i%5
			var layer := i/5
			p.velocity = Vector3(lerpf(-2.7,2.7,(lane+rng.randf_range(.15,.85))/15.0)*spread+lean,lerpf(.6,5.4,(layer+rng.randf_range(.15,.85))/6.0)*lift,rng.randf_range(-.2,.2))
			p.spin = Vector3(rng.randf_range(-3,3),rng.randf_range(-3,3),rng.randf_range(-4,4))
			if choice.family == 2:
				# Rounded local -Y end leads; the pointed +Y tail trails velocity.
				p.quaternion = Quaternion(Vector3.DOWN,p.velocity.normalized())
				p.spin = Vector3.ZERO
			p.delay = rng.randf_range(0,.3)
			p.hide()
	root.get_tree().create_timer(3.2).timeout.connect(root.queue_free)
	return root

class SodaDrop extends Flight:
	const MAX_TURN_RATE := 8.0
	func _process(delta: float) -> void:
		super._process(delta)
		if age <= 0 or is_queued_for_deletion(): return
		# Hold at near-zero speed rather than divide by noisy apex velocity.
		if velocity.length_squared() < .0025: return
		var target := Quaternion(Vector3.DOWN,velocity.normalized())
		var angle := quaternion.angle_to(target)
		if angle < .00001: return
		# Exponential settling plus a hard angular-speed cap avoids apex snaps.
		var weight := minf(1.0-exp(-12.0*delta),MAX_TURN_RATE*delta/angle)
		quaternion = quaternion.slerp(target,clampf(weight,0,1)).normalized()
