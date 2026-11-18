extends Node3D
const Effect = preload("res://ui3d/lightning_effect.gd")
var failures := 0
func check(ok: bool,label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)
func _ready() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0,1,5)
	add_child(camera)
	# Asymmetric triangle: transformed AABB corners are not actual skin points.
	var owner := Node3D.new()
	add_child(owner)
	var head := MeshInstance3D.new()
	head.name = "Head"
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var points := [Vector3(-2,0,0),Vector3(2,0,0),Vector3(-1,1,0)]
	for point in points: st.add_vertex(point)
	head.mesh = st.commit()
	head.rotation.z = -.6
	owner.add_child(head)
	var expected := Vector3(0,-INF,0)
	for point in points:
		var world: Vector3 = head.global_transform*point
		if world.y>expected.y: expected=world
	check(Effect.highest_surface(owner).world.is_equal_approx(expected),"Actual vertex, not AABB corner")
	var decoy := MeshInstance3D.new()
	decoy.name = "UnrelatedCosmetic"
	decoy.mesh = BoxMesh.new()
	decoy.position.y = 100
	owner.add_child(decoy)
	check(Effect.highest_surface(owner).world.is_equal_approx(expected),"Unrelated cosmetics excluded")
	owner.queue_free()
	var timings := []
	for scene in [Wardrobe.PUG,Wardrobe.SPIRAL]:
		for size in [.6,.9,1.4]:
			for turn in [0.0,1.0,PI]:
				var model: Node3D = scene.instantiate()
				add_child(model)
				model.scale = Vector3.ONE*size
				model.rotation = Vector3(.17,.27,turn)
				var hand: Node3D = model.find_child("Hand",true,false)
				if hand != null:
					hand.rotation.z += .8
					hand.position.y += .5
				var target := Effect.highest_surface(model)
				var maximum := -INF
				for mesh in Effect.skin_meshes(model):
					for surface in mesh.mesh.get_surface_count():
						for vertex in mesh.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]:
							var point: Vector3 = mesh.to_global(vertex)
							maximum = maxf(maximum,point.y)
				check(absf(target.world.y-maximum)<.00001,"Both skins and rotated/scaled/raised poses hit maximum surface")
				seed(912)
				var expected_rng := randi()
				seed(912)
				var start := Time.get_ticks_usec()
				var effect = Effect.strike(model,camera,true,true)
				timings.append((Time.get_ticks_usec()-start)/1000.0)
				check(randi()==expected_rng,"Local cosmetic RNG")
				check(effect.bolts.size()==3,"Three main bolt instances")
				check(effect.impact.is_equal_approx(target.world),"Exact same highest endpoint")
				for bolt in effect.bolts:
					check(bolt.global_position.is_equal_approx(target.world),"All bolt origins at same contact")
					check(bolt.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"No shadows")
				check(effect.strikes_started==0,"Clouds form before first strike")
				check(effect.bolts[0].mesh!=effect.bolts[1].mesh and effect.bolts[1].mesh!=effect.bolts[2].mesh,"Different cached paths")
				check(effect.bolts[0].basis.y.x<0 and effect.bolts[2].basis.y.x>0,"Opposite angled incoming channels")
				for speed in [1.0,.25]:
					Engine.time_scale=speed
					effect.age=0.0
					for tick in 310:
						effect._process(.005*speed)
						for index in 3:
							var elapsed: float = effect.age-Effect.STRIKE_START-index*Effect.STAGGER
							check(effect.bolts[index].visible==(elapsed>=0 and elapsed<Effect.FLASH_SECONDS),"Three discrete storm strikes preserve timing under slow motion")
				check(effect.strikes_started==3,"All three staggered strikes started")
				Engine.time_scale=1.0
				check(Effect.strike(model,camera,true,true)==null,"Duplicate event suppressed")
				effect._process(.2)
				check(effect.is_queued_for_deletion(),"Transient cleanup scheduled")
				check(Effect.strike(model,camera,false,true)==null,"Restore never replays")
				model.queue_free()
				await get_tree().process_frame
	print("LIGHTNING_POSE_CHECKS ",JSON.stringify({"failures":failures,"poses":18,"spawn_ms":timings}))
	get_tree().quit(failures)
