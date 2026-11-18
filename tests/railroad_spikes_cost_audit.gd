extends RefCounted
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
const Effect = preload("res://ui3d/railroad_spikes_effect.gd")
static func run(tree: SceneTree,mode: String) -> void:
	var errors: Array[String] = []
	var camera := Camera3D.new()
	camera.position.z = 4
	tree.root.add_child(camera)
	var frames := 0
	var preparation := 0.0
	if mode == "prepared":
		while not Prep.is_prepared("railroad_spikes") and frames < 1000:
			var t := Time.get_ticks_usec()
			Prep.prepare_step("railroad_spikes")
			preparation += (Time.get_ticks_usec()-t)/1000.0
			frames += 1
			await tree.process_frame
		if not Prep.is_prepared("railroad_spikes"): errors.append("Preparation did not finish")
	var timings: Array[float] = []
	var owners: Array[Node3D] = []
	var effects: Array = []
	var references: Array = []
	for trial in 12:
		var holder := Node3D.new()
		tree.root.add_child(holder)
		var anchors: Array[Node3D] = []
		for i in 4:
			var limb := Node3D.new()
			holder.add_child(limb)
			limb.position = Vector3((i%2-.5)*.9,float(i/2),0)
			anchors.append(limb)
		var start := Time.get_ticks_usec()
		var effect = Effect.attach_anchors(holder,anchors,.9,camera,true)
		timings.append((Time.get_ticks_usec()-start)/1000.0)
		if effect.pins.size() != 4: errors.append("Four pins required")
		if trial < 9:
			holder.queue_free()
			await tree.process_frame
		else:
			owners.append(holder)
			effects.append(effect)
			references.append_array(effect.pins)
	await tree.create_timer(4.2).timeout
	for effect in effects:
		if not is_instance_valid(effect) or not effect.settled or effect.is_processing(): errors.append("Settled pins must persist without processing")
	var arrays := Effect.mesh.surface_get_arrays(0)
	var indices: Variant = arrays[Mesh.ARRAY_INDEX]
	var triangles: int = (indices.size() if indices != null and indices.size()>0 else arrays[Mesh.ARRAY_VERTEX].size())/3
	var bytes := var_to_bytes(arrays).size()
	if triangles*4 > Prep.REGISTRY.railroad_spikes[4]: errors.append("Triangle ceiling")
	if bytes > Prep.CACHE_ARRAY_BYTE_LIMITS.railroad_spikes: errors.append("Cache bytes ceiling")
	var resident := references.size()
	for holder in owners: holder.queue_free()
	await tree.process_frame
	await tree.process_frame
	var remaining := 0
	for pin in references:
		if is_instance_valid(pin): remaining += 1
	if remaining != 0: errors.append("Climber cleanup leaked pins")
	var sorted := timings.duplicate()
	sorted.sort()
	if mode == "prepared" and sorted[-1] > Prep.PREPARED_P95_BUDGET_MS: errors.append("Prepared p95 CPU exceeded")
	if float(Prep.step_max_ms.get("railroad_spikes",0.0)) > Prep.PREPARE_STEP_BUDGET_MS: errors.append("Preparation unit CPU exceeded")
	var report := {"effect":"railroad_spikes","mode":mode,"lifetime":"climber_owned","first_process_burst_cpu_ms":timings[0],"max_cpu_ms":sorted[-1],"p95_cpu_ms":sorted[-1],"prepare_cpu_ms":preparation,"prepare_max_step_ms":Prep.step_max_ms.get("railroad_spikes",0.0),"normal_meshes":4,"normal_nodes":5,"normal_triangles":triangles*4,"cache_unique_meshes":1,"cache_mesh_serialized_bytes":bytes,"retained_three_climbers":resident,"cleanup_remaining":remaining,"gpu_measured":false,"errors":errors}
	print("LOCK_EFFECT_AUDIT_JSON ",JSON.stringify(report))
	tree.quit(1 if not errors.is_empty() else 0)
