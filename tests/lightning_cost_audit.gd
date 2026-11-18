extends RefCounted
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
const Effect = preload("res://ui3d/lightning_effect.gd")
static func run(tree: SceneTree,mode: String) -> void:
	var errors: Array[String] = []
	var camera := Camera3D.new()
	camera.position = Vector3(0,1,5)
	tree.root.add_child(camera)
	var prepare_ms := 0.0
	var frames := 0
	if mode == "prepared":
		while not Prep.is_prepared("lightning") and frames<100:
			var started := Time.get_ticks_usec()
			Prep.prepare_step("lightning")
			prepare_ms += (Time.get_ticks_usec()-started)/1000.0
			frames += 1
			await tree.process_frame
		if not Prep.is_prepared("lightning"): errors.append("Preparation did not finish")
	for index in 32:
		if not FileAccess.file_exists("res://kit/effects/lightning_vertices/part_%02d.bin" % index): errors.append("Missing skin vertex bake")
	for index in 6:
		if not ResourceLoader.exists(Effect.mesh_path(index)): errors.append("Missing bolt bake")
	if not Effect.preparation_errors.is_empty(): errors.append(str(Effect.preparation_errors))
	var times: Array[float] = []
	var owners: Array[Node] = []
	var effects: Array[Node] = []
	var max_triangles := 0
	for trial in 12:
		var scene: PackedScene = Wardrobe.PUG if trial%2==0 else Wardrobe.SPIRAL
		var owner := scene.instantiate() as Node3D
		tree.root.add_child(owner)
		owner.rotation.z = trial*.37
		owner.scale = Vector3.ONE*(.6+(trial%3)*.4)
		var start := Time.get_ticks_usec()
		var effect = Effect.strike(owner,camera,true,true)
		times.append((Time.get_ticks_usec()-start)/1000.0)
		if effect == null:
			errors.append("No visible skin target")
			owner.queue_free()
			continue
		if effect.bolts.size()!=3: errors.append("Exactly three main bolts required")
		if effect.cloud_sources.size()!=3: errors.append("Decorative clouds must not create bolt sources")
		for cloud in effect.clouds:
			if cloud.mesh!=Effect.cloud_mesh or cloud.material_override!=Effect.weather_material: errors.append("Weather resources must be shared")
		var triangles := 0
		for bolt in effect.bolts:
			triangles += bolt.mesh.surface_get_array_len(0)/3
			if bolt.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF: errors.append("Unexpected shadows")
		if effect.clouds.size()!=5: errors.append("Five weather clouds required; two are decorative")
		for cloud in effect.clouds:
			triangles += mesh_triangles(cloud.mesh)
			if cloud.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF: errors.append("Unexpected cloud shadows")
		if effect.rain == null or effect.rain.multimesh.instance_count != 24: errors.append("Rain instance budget mismatch")
		else:
			triangles += mesh_triangles(effect.rain.multimesh.mesh)*effect.rain.multimesh.instance_count
			if effect.rain.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF: errors.append("Unexpected rain shadows")
		if effect.get_child_count()+1>Prep.NORMAL_NODE_LIMITS.lightning: errors.append("Node budget exceeded")
		max_triangles = maxi(max_triangles,triangles)
		if Effect.strike(owner,camera,true,true)!=null: errors.append("Duplicate effect replayed")
		if trial<9:
			owner.queue_free()
			await tree.process_frame
		else:
			owners.append(owner)
			effects.append(effect)
	var overlap := effects.size()
	await tree.create_timer(Effect.TOTAL_SECONDS+.25).timeout
	var remaining := 0
	for effect in effects:
		if is_instance_valid(effect): remaining += 1
	for owner in owners: owner.queue_free()
	await tree.process_frame
	for index in 6:
		if Effect.meshes[index] != null:
			var authored := Effect._bolt_mesh(index)
			if var_to_bytes(authored.surface_get_arrays(0))!=var_to_bytes(Effect.meshes[index].surface_get_arrays(0)): errors.append("Stale Lightning bolt bake")
	var bytes := 0
	var cached_meshes := 0
	for mesh in Effect.meshes+[Effect.cloud_mesh,Effect.rain_mesh]:
		if mesh != null:
			cached_meshes += 1
			bytes += var_to_bytes(mesh.surface_get_arrays(0)).size()
	# Validate every baked point against current skin geometry, outside timing.
	for mesh in Effect.vertex_cache:
		var original := PackedVector3Array()
		for surface in mesh.get_surface_count(): original.append_array(mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX])
		if original != Effect.vertex_cache[mesh]: errors.append("Stale Lightning skin vertex bake")
	var vertex_bytes := 0
	for points in Effect.vertex_cache.values(): vertex_bytes += points.size()*12
	if max_triangles>Prep.REGISTRY.lightning[4]: errors.append("Geometry budget exceeded")
	if cached_meshes>Prep.CACHE_MESH_LIMITS.lightning: errors.append("Cached mesh count exceeded")
	if bytes>Prep.CACHE_ARRAY_BYTE_LIMITS.lightning: errors.append("Mesh cache budget exceeded")
	if vertex_bytes>int(Prep.TRANSIENT_ATTACHED_EFFECTS.lightning.skin_vertex_bytes): errors.append("Skin vertex cache budget exceeded")
	if remaining!=0 or overlap!=3: errors.append("Overlap/cleanup failed")
	var sorted := times.duplicate()
	sorted.sort()
	if mode=="prepared" and sorted[-1]>4.0: errors.append("Prepared p95 exceeded")
	if float(Prep.step_max_ms.get("lightning",0))>8.0: errors.append("Preparation unit exceeded")
	print("LOCK_EFFECT_AUDIT_JSON ",JSON.stringify({"effect":"lightning","mode":mode,"errors":errors,"first_process_burst_cpu_ms":times[0],"max_cpu_ms":sorted[-1],"p95_cpu_ms":sorted[-1],"prepare_cpu_ms":prepare_ms,"prepare_frames":frames,"prepare_max_step_ms":Prep.step_max_ms.get("lightning",0),"normal_triangles":max_triangles,"normal_meshes":9,"normal_nodes":10,"cache_unique_meshes":cached_meshes,"cache_mesh_serialized_bytes":bytes,"skin_vertex_cache_bytes":vertex_bytes,"skin_meshes":Effect.vertex_cache.size(),"overlap_roots":overlap,"cleanup_remaining":remaining,"gpu_measured":false}))
	tree.quit(0 if errors.is_empty() else 1)

static func mesh_triangles(mesh: Mesh) -> int:
	var count := 0
	for surface in mesh.get_surface_count():
		var indices: int = mesh.surface_get_array_index_len(surface)
		count += int((indices if indices>0 else mesh.surface_get_array_len(surface))/3)
	return count
