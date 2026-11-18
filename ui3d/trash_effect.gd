extends RefCounted
## One can, one lid, and 54 assorted scraps.
static var scenes := {}
static var meshes := {}
const TYPES := ["can","lid","carton","crushed_tin","paper_wad","banana_peel","apple_core","fishbone"]
const PER_THIRD := [0,0,2,3,4,3,3,3]
const PIECES := 56
static func burst(camera: Node3D,big := false) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var root := Node3D.new()
	root.name = "TrashBurst"
	camera.add_child(root)
	var lean := rng.randf_range(-.15,.15)
	var lift := rng.randf_range(.94,1.06)
	root.set_meta("burst_profile",[lean,lift,rng.randi()])
	var can_region := rng.randi_range(0,2)
	var lid_region := (can_region+rng.randi_range(1,2))%3
	for region in 3:
		var choices: Array[int] = []
		for kind in TYPES.size():
			for count in PER_THIRD[kind]: choices.append(kind)
		if region == can_region: choices.append(0)
		if region == lid_region: choices.append(1)
		for i in range(choices.size()-1,0,-1):
			var j := rng.randi_range(0,i)
			var old := choices[i]
			choices[i] = choices[j]
			choices[j] = old
		for i in choices.size():
			var kind := choices[i]
			var key: String = TYPES[kind]
			if not scenes.has(key): scenes[key] = load("res://kit/models/trash_"+key+".glb")
			if not meshes.has(key):
				var sample: Node3D = scenes[key].instantiate()
				var source: MeshInstance3D = sample.find_child("Trash",true,false)
				meshes[key] = source.mesh
				sample.free()
			var item := MeshInstance3D.new()
			item.mesh = meshes[key]
			# Center visible geometry, including off-origin authored props, at launch.
			item.position = -item.mesh.get_aabb().get_center()
			item.material_override = CelPass.one()
			item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var p := JunkFlight.new()
			p.add_child(item)
			root.add_child(p)
			p.set_meta("coverage_region",region)
			p.set_meta("shape",kind)
			p.set_meta("size_class",i%3)
			p.position = Vector3(rng.randf_range(-.25,.25),.4,-5)
			p.rotation = Vector3(rng.randf_range(-.5,.5),rng.randf_range(-.6,.6),rng.randf_range(-1.3,1.3))
			p.base_size = rng.randf_range(.75,.90) if kind==0 else rng.randf_range(.78,1.04)+(i%3)*.10
			p.base_size *= 1.5 if kind < 2 else .9
			p.scale = Vector3.ONE*p.base_size
			# Independent random destinations span the same camera envelope as
			# other camera bursts; bookkeeping regions no longer create clusters.
			var target := Vector2(rng.randf_range(-2.2,2.2),rng.randf_range(.60,2.25))
			p.gravity = 3.1
			# Invert the drag/gravity arc at .7 s, giving broad screen coverage.
			var travel := (1.0-exp(-.58*.7))/.58
			p.velocity = Vector3((target.x-p.position.x)/travel,(target.y-p.position.y+(p.gravity/.58)*(.7-travel))/travel,rng.randf_range(-.07,.07))
			if kind<2:
				# The one can/lid are prominent and stay readable through slower arcs.
				p.position = Vector3(rng.randf_range(-.25,.25),.4,-5)
				p.velocity = Vector3(rng.randf_range(-1.0,1.0),rng.randf_range(1.7,2.15),rng.randf_range(-.04,.04))
				p.gravity = 1.1 if big else 1.4
			p.set_meta("launch_target",target)
			p.spin = Vector3(rng.randf_range(-1.5,1.5),rng.randf_range(-1.6,1.6),rng.randf_range(-2.4,2.4))*(.65 if kind==0 else 1.0)
			p.delay = rng.randf_range(0,.24)
			p.lifetime = 3.2 if big else 2.65
			p.hide()
	root.get_tree().create_timer(3.6 if big else 3.0).timeout.connect(root.queue_free)
	return root

class JunkFlight extends Node3D:
	var velocity := Vector3.ZERO
	var spin := Vector3.ZERO
	var gravity := 1.45
	var delay := 0.0
	var age := 0.0
	var lifetime := 2.65
	var base_size := 1.0
	func _process(dt: float) -> void:
		if delay>0:
			delay -= dt
			return
		show()
		age += dt
		velocity.y -= gravity*dt
		velocity *= exp(-.58*dt)
		position += velocity*dt
		rotate_object_local(Vector3.RIGHT,spin.x*dt)
		rotate_object_local(Vector3.UP,spin.y*dt)
		rotate_object_local(Vector3.BACK,spin.z*dt)
		scale = Vector3.ONE*base_size*clampf((lifetime-age)/.22,0,1)
		if age>=lifetime: queue_free()

