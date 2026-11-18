extends SceneTree
var Prep: Script
var camera: Camera3D
var errors: Array[String] = []
var unique_meshes := {}
var unique_materials := {}
var unique_shaders := {}
var unique_textures := {}

func _initialize() -> void:
	call_deferred("audit")

func audit() -> void:
	Prep = load("res://ui3d/lock_effect_preparation.gd")
	var id := ""
	var mode := "prepared"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--effect="): id = arg.trim_prefix("--effect=")
		if arg.begins_with("--mode="): mode = arg.trim_prefix("--mode=")
	errors.append_array(Prep.validation_errors())
	if id == "" or not Prep.REGISTRY.has(id) or not mode in ["cold","prepared"]:
		push_error("Use fresh process per --effect=<Wardrobe key> --mode=cold|prepared")
		quit(2)
		return
	if not errors.is_empty():
		finish({"errors":errors})
		return
	if id == "lightning":
		await load("res://tests/lightning_cost_audit.gd").run(self,mode)
		return
	if id == "railroad_spikes":
		await load("res://tests/railroad_spikes_cost_audit.gd").run(self,mode)
		return
	camera = Camera3D.new()
	root.add_child(camera)
	var memory_before := int(Performance.get_monitor(Performance.MEMORY_STATIC))
	var resources_before := int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
	var prepare_cpu_ms := 0.0
	var prepare_frames := 0
	if mode == "prepared":
		while not Prep.is_prepared(id):
			var start := Time.get_ticks_usec()
			Prep.prepare_step(id)
			prepare_cpu_ms += (Time.get_ticks_usec()-start)/1000.0
			prepare_frames += 1
			if prepare_frames > 3000:
				errors.append("Preparation failed to finish")
				break
			await process_frame
	var memory_ready := int(Performance.get_monitor(Performance.MEMORY_STATIC))
	var resources_ready := int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
	var timings: Array[float] = []
	var peak := {"nodes":0,"meshes":0,"surfaces":0,"triangles":0,"shadow_meshes":0,"emitters":0,"pieces":0}
	var live: Array[Node3D] = []
	# The first burst is the only fresh-process sample. Later samples include warm
	# runtime allocation; cold mode may still discover unseen random variants.
	for trial in 12:
		var start := Time.get_ticks_usec()
		var effect: Node3D = Prep.burst(id,camera)
		timings.append((Time.get_ticks_usec()-start)/1000.0)
		var counts := {"nodes":0,"meshes":0,"surfaces":0,"triangles":0,"shadow_meshes":0,"emitters":0,"pieces":0}
		count_nodes(effect,counts)
		for key in peak: peak[key] = maxi(peak[key],counts[key])
		if counts.pieces != Prep.REGISTRY[id][3]: errors.append("Piece count mismatch: " + str(counts.pieces))
		if counts.triangles > Prep.REGISTRY[id][4]: errors.append("Triangle budget exceeded")
		if counts.nodes > Prep.NORMAL_NODE_LIMITS[id]: errors.append("Node budget exceeded")
		if counts.surfaces > Prep.REGISTRY[id][3]: errors.append("Surface budget exceeded")
		if trial < 9:
			# Let real timers own cleanup: manually freeing roots invalidates captured
			# callbacks in existing effects and creates irrelevant teardown errors.
			if trial == 8:
				await create_timer(4.1).timeout
				await process_frame
			await process_frame
		else:
			live.append(effect)
	# Three simultaneous independent roots, then exercise their real cleanup timers.
	var overlap_roots := camera.get_child_count()
	if overlap_roots != 3: errors.append("Overlapping roots missing")
	await create_timer(4.1).timeout
	await process_frame
	await process_frame
	if camera.get_child_count() != 0: errors.append("Burst cleanup leaked children")
	for effect in live:
		if is_instance_valid(effect): errors.append("Burst root survived cleanup")
	var cached_resources_before := int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
	# Enumerate retained cache independently of random sample coverage. Temporary
	# model instances are freed immediately; account materials via the same cel pass.
	var script = Prep.effect_script(id)
	if str(Prep.REGISTRY[id][1]).begins_with("scene:"):
		for scene: PackedScene in script.scenes.values():
			var sample := scene.instantiate()
			CelPass.celify(sample)
			count_nodes(sample,{"nodes":0,"meshes":0,"surfaces":0,"triangles":0,"shadow_meshes":0,"emitters":0,"pieces":0})
			sample.free()
	else:
		var cache: Variant = script.get("meshes")
		for mesh in (cache.values() if cache is Dictionary else cache):
			if mesh != null: remember_mesh(mesh)
		if id == "roses":
			for mesh in script.rose_meshes:
				if mesh != null: remember_mesh(mesh)
	var mesh_bytes := 0
	var cache_triangles := 0
	for mesh: Mesh in unique_meshes.values():
		for surface in mesh.get_surface_count():
			var arrays := mesh.surface_get_arrays(surface)
			mesh_bytes += var_to_bytes(arrays).size()
			cache_triangles += triangle_count(arrays)
	var sorted := timings.duplicate()
	sorted.sort()
	if str(Prep.REGISTRY[id][1]).begins_with("baked:"):
		var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://kit/effects/prepared/geometry_hashes.json"))
		var source := FileAccess.get_file_as_string("res://ui3d/"+Prep.REGISTRY[id][0]+".gd").replace("\r\n","\n")
		var first := source.find("\t# BAKED_LOOKUP_BEGIN")
		while first >= 0:
			var last := source.find("\t# BAKED_LOOKUP_END",first)+"\t# BAKED_LOOKUP_END\n".length()
			source = source.substr(0,first)+source.substr(last)
			first = source.find("\t# BAKED_LOOKUP_BEGIN")
		if manifest.sources.get(id,"") != source.sha256_text(): errors.append("Stale baked source; regenerate meshes")
		if manifest.palette_map_sha256 != FileAccess.get_file_as_string("res://palette/house_atlas_map.json").sha256_text(): errors.append("Stale baked atlas metadata")
		for index in Prep.REGISTRY[id][2]:
			var mesh: Mesh = script.rose_meshes[index-6] if id == "roses" and index >= 6 else script.meshes[index]
			var hash := HashingContext.new()
			hash.start(HashingContext.HASH_SHA256)
			for surface in mesh.get_surface_count(): hash.update(var_to_bytes(mesh.surface_get_arrays(surface)))
			var path: String = preload("res://ui3d/effect_mesh_cache.gd").path_for(id,index)
			if hash.finish().hex_encode() != manifest.meshes.get(path,""): errors.append("Baked geometry fingerprint mismatch")
	if unique_meshes.size() > Prep.CACHE_MESH_LIMITS[id]: errors.append("Resident mesh budget exceeded")
	if mesh_bytes > Prep.CACHE_ARRAY_BYTE_LIMITS[id]: errors.append("Resident mesh array byte budget exceeded")
	if unique_materials.size() > Prep.CACHE_MESH_LIMITS[id]*4+4: errors.append("Resident material budget exceeded")
	if unique_shaders.size() > 4 or unique_textures.size() > 4: errors.append("Shader/texture resource budget exceeded")
	# Outside the timed section: prove metadata avoids readback without changing
	# even one named palette texel. This also catches stale atlas metadata later.
	var atlas_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://palette/house_atlas_map.json"))
	var atlas_image := CelPass.ATLAS.get_image()
	for cell in atlas_data.cells.values():
		var rgb: Array = cell.srgb
		if atlas_image.get_pixel(int(cell.col)*32+16,int(cell.row)*32+16) != Color8(rgb[0],rgb[1],rgb[2]):
			errors.append("Atlas metadata does not match sampled PNG texel")
	if id == "confetti":
		var start := Time.get_ticks_usec()
		var winner: Node3D = Prep.burst(id,camera,true)
		var winner_ms := (Time.get_ticks_usec()-start)/1000.0
		var counts := {"nodes":0,"meshes":0,"surfaces":0,"triangles":0,"shadow_meshes":0,"emitters":0,"pieces":0}
		count_nodes(winner,counts)
		var budget: Dictionary = Prep.WINNER_BUDGETS[id]
		if counts.pieces != budget.pieces or counts.triangles > budget.triangles or winner_ms > budget.spawn_ms:
			errors.append("Winner burst budget exceeded")
		await create_timer(4.1).timeout
		await process_frame
	if mode == "prepared":
		if sorted[-1] > Prep.PREPARED_SPAWN_BUDGET_MS: errors.append("Prepared maximum CPU spawn budget exceeded")
		if sorted[11] > Prep.PREPARED_P95_BUDGET_MS: errors.append("Prepared p95 CPU spawn budget exceeded")
		if float(Prep.step_max_ms.get(id,0)) > Prep.PREPARE_STEP_BUDGET_MS: errors.append("Preparation step budget exceeded")
	finish({"effect":id,"mode":mode,"renderer":RenderingServer.get_current_rendering_method(),
		"gpu_measured":false,"first_process_burst_cpu_ms":timings[0],"subsequent_cpu_ms":timings.slice(1),
		"p95_cpu_ms":sorted[11],"max_cpu_ms":sorted[-1],"prepare_cpu_ms":prepare_cpu_ms,
		"prepare_frames":prepare_frames,"prepare_max_step_ms":Prep.step_max_ms.get(id,0),
		"peak_normal_burst":peak,"overlap_roots":overlap_roots,"cleanup_remaining":camera.get_child_count(),
		"cache_unique_meshes":unique_meshes.size(),"cache_mesh_serialized_bytes":mesh_bytes,
		"cache_triangles":cache_triangles,"unique_materials":unique_materials.size(),
		"unique_shaders":unique_shaders.size(),"unique_textures":unique_textures.size(),
		"preparation_static_memory_delta_bytes":memory_ready-memory_before,
		"preparation_resource_delta":resources_ready-resources_before,
		"post_cleanup_resource_count":cached_resources_before,"errors":errors})

func finish(result: Dictionary) -> void:
	print("LOCK_EFFECT_AUDIT_JSON ",JSON.stringify(result))
	quit(0 if errors.is_empty() else 1)

func count_nodes(node: Node, counts: Dictionary) -> void:
	counts.nodes += 1
	if node is MeshInstance3D:
		counts.meshes += 1
		counts.pieces += 1
		if node.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF: counts.shadow_meshes += 1
		count_mesh(node.mesh,1,counts)
		for surface in node.mesh.get_surface_count(): remember_material(node.get_active_material(surface))
	if node is CPUParticles3D:
		counts.emitters += 1
		counts.pieces += node.amount
		count_mesh(node.mesh,node.amount,counts)
	for child in node.get_children(): count_nodes(child,counts)

func triangle_count(arrays: Array) -> int:
	var indices: Variant = arrays[Mesh.ARRAY_INDEX]
	return (indices.size() if indices != null and indices.size() > 0 else arrays[Mesh.ARRAY_VERTEX].size())/3

func count_mesh(mesh: Mesh, amount: int, counts: Dictionary) -> void:
	if mesh == null: return
	remember_mesh(mesh)
	counts.surfaces += mesh.get_surface_count()
	for i in mesh.get_surface_count(): counts.triangles += triangle_count(mesh.surface_get_arrays(i))*amount

func remember_mesh(mesh: Mesh) -> void:
	unique_meshes[mesh.get_instance_id()] = mesh
	for i in mesh.get_surface_count(): remember_material(mesh.surface_get_material(i))

func remember_material(material: Material) -> void:
	if material == null: return
	unique_materials[material.get_instance_id()] = material
	if material is ShaderMaterial:
		unique_shaders[material.shader.get_instance_id()] = material.shader
		for name in ["base_texture","surface_texture","emission_texture","glyph_atlas"]:
			var texture: Variant = material.get_shader_parameter(name)
			if texture is Texture: unique_textures[texture.get_instance_id()] = texture
	elif material is StandardMaterial3D and material.albedo_texture != null:
		unique_textures[material.albedo_texture.get_instance_id()] = material.albedo_texture

