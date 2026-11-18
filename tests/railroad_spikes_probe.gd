extends Node3D
## Standalone draft. Install/run only after Captain releases the packaging hold.
const Effect = preload("res://ui3d/railroad_spikes_effect.gd")
var failures := 0
func check(ok: bool,label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)

func fixture(size: float) -> Node3D:
	var holder := Node3D.new()
	add_child(holder)
	for i in 4:
		var limb := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(.14,.16,.24)*size
		limb.mesh = box
		limb.position = Vector3((i%2-.5)*1.1,(1-i/2)*1.1,0)
		limb.rotation = Vector3(.12*i,-.16*i,.7*i)
		holder.add_child(limb)
	return holder

func _ready() -> void:
	var original := Wardrobe.profiles.duplicate(true)
	var path: String = Wardrobe.SavePaths.settings("climbers.cfg")
	var existed := FileAccess.file_exists(path)
	var backup := FileAccess.get_file_as_bytes(path) if existed else PackedByteArray()
	Wardrobe.profiles[Wardrobe.selected].effect = "railroad_spikes"
	check(Wardrobe.save(),"Save selected cosmetic")
	Wardrobe.load_profiles()
	check(Wardrobe.for_slot(0).effect == "railroad_spikes","Reload selected cosmetic")
	Wardrobe.profiles = original
	if existed:
		var f := FileAccess.open(path,FileAccess.WRITE)
		f.store_buffer(backup)
		f.close()
	else: DirAccess.remove_absolute(path)
	var camera := Camera3D.new()
	camera.position = Vector3(0,.5,4)
	add_child(camera)
	var t := Time.get_ticks_usec()
	Effect.prepare()
	var prep_ms := (Time.get_ticks_usec()-t)/1000.0
	var mesh_id := Effect.mesh.get_instance_id()
	var arrays := Effect.mesh.surface_get_arrays(0)
	var indices: Variant = arrays[Mesh.ARRAY_INDEX]
	var tris: int = (indices.size() if indices != null and indices.size() > 0 else arrays[Mesh.ARRAY_VERTEX].size())/3
	check(tris == 88 and tris*4 <= 500,"352 total triangles")
	check(Effect.mesh.get_surface_count() == 1,"Single shared surface")
	var times: Array = []
	for size in [.6,.9,1.4]:
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL if size == .6 else Camera3D.PROJECTION_PERSPECTIVE
		camera.near = 1.8 if size == 1.4 else .05
		camera.rotation = Vector3(.08,.12,0)
		var holder := fixture(size)
		var anchors: Array[Node3D] = []
		for child in holder.get_children(): anchors.append(child)
		seed(874)
		var expected := randi()
		seed(874)
		t = Time.get_ticks_usec()
		var effect = Effect.attach_anchors(holder,anchors,size,camera,true)
		times.append((Time.get_ticks_usec()-t)/1000.0)
		check(randi() == expected,"Cosmetic local RNG only")
		check(effect.pins.size() == 4,"Exactly four spikes")
		check(is_equal_approx(Effect.FLIGHT_SECONDS,.095),"Four times original travel speed")
		var unique := {}
		for i in 4:
			var safety: Dictionary = effect.launch_safety[i]
			check(safety.distance-safety.radius >= Effect.MIN_CAMERA_DISTANCE-.0001,"Whole spike minimum camera distance")
			check(safety.depth-safety.radius >= camera.near+Effect.NEAR_PLANE_MARGIN-.0001,"Whole spike near-plane safety")
			unique[effect.spin_phases[i]] = true
		check(unique.size()==4,"Four independent spin phases")
		var final_angles := {}
		for i in 4:
			final_angles[effect.final_rolls[i]] = true
			check(effect.targets[i].basis.z.is_equal_approx(effect.unrolled_targets[i].basis.z),"Settled roll preserves shaft direction")
			check((effect.targets[i]*Vector3(0,0,-.27)).is_equal_approx(effect.unrolled_targets[i]*Vector3(0,0,-.27)),"Settled tip centre unchanged")
		check(final_angles.size()==4,"Distinct retained axial rolls")
		check(is_equal_approx(3*Effect.STAGGER_SECONDS,.24),"First-to-last impact spans .24 seconds")
		for i in 4:
			for j in range(i+1,4):
				check(absf(wrapf(effect.final_rolls[i]-effect.final_rolls[j],-PI/8,PI/8))>.05,"Rolls distinct modulo octagon symmetry")



		check(Effect.attach_anchors(holder,anchors,size,camera,true) == effect,"Duplicate event reuses effect")
		check(effect.pins[0].mesh.get_instance_id() == mesh_id,"Shared cache reused")
		# Independently inspect actual transformed vertices during the spin, rather
		# than relying solely on recorded launch metrics.
		for sample in 6:
			effect._process(.015)
			for i in 4:
				var pin: MeshInstance3D = effect.pins[i]
				var flight_progress: float = clampf((effect.age-i*Effect.STAGGER_SECONDS)/Effect.FLIGHT_SECONDS,0,1)
				if flight_progress>0 and flight_progress<1.0:
					var target: Transform3D = pin.get_parent().global_transform*effect.targets[i]
					var along: Vector3 = (target*Effect.TIP-effect.starts[i]).normalized()
					check((-pin.global_basis.z.normalized()).dot(along)>.9999,"Flight rotation is axial drill roll only")

				if not pin.visible: continue
				for corner in 8:
					var world: Vector3 = pin.global_transform*pin.mesh.get_aabb().get_endpoint(corner)
					check(world.distance_to(camera.global_position) >= Effect.MIN_CAMERA_DISTANCE-.0001,"Spinning mesh stays outside camera safety radius")
					check((world-camera.global_position).dot(-camera.global_basis.z) >= camera.near+Effect.NEAR_PLANE_MARGIN-.0001,"Spinning mesh clears near plane")
		await get_tree().create_timer(1.7).timeout
		var targets: Array = effect.targets.duplicate()
		check(effect.settled and not effect.is_processing(),"Settled effect consumes no per-frame update")
		for i in 4:
			check(effect.pins[i].transform.is_equal_approx(targets[i]),"Exact final local pose")
			anchors[i].rotation.z += .3
			check(effect.pins[i].transform.is_equal_approx(targets[i]),"Attached pin follows limb rotation")
			check(effect.pins[i].cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"No shadow cost")
		check(holder.find_children("*","CollisionObject3D",true,false).is_empty(),"No effect physics")
		var pins: Array = effect.pins.duplicate()
		holder.queue_free()
		await get_tree().process_frame
		check(pins.all(func(pin): return not is_instance_valid(pin)),"Owner cleanup removes pins")
		var restored := fixture(size)
		anchors.clear()
		for child in restored.get_children(): anchors.append(child)
		var restore = Effect.attach_anchors(restored,anchors,size,camera,false)
		check(restore.settled and restore.starts.is_empty() and not restore.is_processing(),"Snapshot restore never replays flight")
		for i in 4: check(restore.pins[i].transform.is_equal_approx(Effect._anchor_transform(anchors[i],size)*Transform3D(Basis(Vector3.BACK,restore.final_rolls[i]),Vector3.ZERO)),"Fresh restore without presentation uses deterministic surface fallback")
		restored.queue_free()
		await get_tree().process_frame
	var profiles := {}
	var first_positions: Array[Vector3] = []
	for activation in 12:
		var holder := fixture(.9)
		var anchors: Array[Node3D] = []
		for child in holder.get_children(): anchors.append(child)
		var fresh = Effect.attach_anchors(holder,anchors,.9,camera,true)
		var signature := str(fresh.starts)
		check(not profiles.has(signature),"Fresh launch positions for each activation")
		profiles[signature] = true
		first_positions.append(fresh.starts[0])
		holder.queue_free()
		await get_tree().process_frame
	var spread := 0.0
	for point in first_positions: spread = maxf(spread,point.distance_to(first_positions[0]))
	check(spread>.1,"No recurring first-limb launch point")
	var timed_owner := fixture(.9)
	var timed_anchors: Array[Node3D] = []
	for child in timed_owner.get_children(): timed_anchors.append(child)
	var timed = Effect.attach_anchors(timed_owner,timed_anchors,.9,camera,true)
	timed.set_process(false)
	var arrivals := [-1.0,-1.0,-1.0,-1.0]
	for step in 345:
		if step in [0,70,150,230]: camera.position.z -= .1
		timed._process(.001)
		if step in [0,81,161,241]:
			var index: int = step/80
			var radius: float = timed.launch_safety[index].radius
			check(timed.starts[index].distance_to(camera.global_position)-radius>=Effect.MIN_CAMERA_DISTANCE-.0001,"Moving camera launch distance")
			check((timed.starts[index]-camera.global_position).dot(-camera.global_basis.z)-radius>=camera.near+Effect.NEAR_PLANE_MARGIN-.0001,"Moving camera near-plane launch safety")
		for i in 4:
			if arrivals[i]<0 and timed.pins[i].visible and timed.pins[i].transform.is_equal_approx(timed.targets[i]): arrivals[i] = timed.age
	check(absf(arrivals[3]-arrivals[0]-.24)<.002,"Observed first-to-last impact is .24 seconds")
	for i in 4: check(absf(arrivals[i]-(.095+i*.08))<.002,"Observed staggered arrival time")
	timed_owner.queue_free()
	await get_tree().process_frame
	print("RAILROAD_SPIKES_PROBE ",JSON.stringify({"failures":failures,"prepare_ms":prep_ms,"spawn_ms":times,"triangles_per_climber":tris*4}))
	get_tree().quit(failures)
