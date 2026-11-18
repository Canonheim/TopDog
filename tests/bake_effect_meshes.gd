extends SceneTree
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
func _initialize() -> void:
	call_deferred("bake")
func fingerprint(mesh: Mesh) -> String:
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	for surface in mesh.get_surface_count(): hash.update(var_to_bytes(mesh.surface_get_arrays(surface)))
	return hash.finish().hex_encode()
func bake() -> void:
	DirAccess.make_dir_recursive_absolute("res://kit/effects/prepared")
	var manifest := {"meshes":{},"sources":{},"palette_map_sha256":FileAccess.get_file_as_string("res://palette/house_atlas_map.json").sha256_text()}
	for id in ["bills","dog_toys","roses"]:
		# In-memory source removes only the baked lookup so regeneration always
		# runs the original geometry, even when previous baked resources exist.
		var path: String = "res://ui3d/"+Prep.REGISTRY[id][0]+".gd"
		var source := FileAccess.get_file_as_string(path).replace("\r\n","\n")
		var first := source.find("\t# BAKED_LOOKUP_BEGIN")
		while first >= 0:
			var last := source.find("\t# BAKED_LOOKUP_END",first)+"\t# BAKED_LOOKUP_END\n".length()
			source = source.substr(0,first)+source.substr(last)
			first = source.find("\t# BAKED_LOOKUP_BEGIN")
		manifest.sources[id] = source.sha256_text()
		var script := GDScript.new()
		script.source_code = source
		if script.reload() != OK:
			quit(2)
			return
		for index in Prep.REGISTRY[id][2]:
			var mesh: ArrayMesh
			if id == "roses": mesh = script.petal_mesh(index) if index < 6 else script.rose_mesh(index-6)
			else: mesh = script.bill_mesh(index/3,index%3) if id == "bills" else script.toy_mesh(index/3,index%3)
			assert(mesh.surface_get_material(0) == CelPass.one(),"Unexpected material; do not substitute it")
			var output := "res://kit/effects/prepared/%s_%02d.res" % [id,index]
			var bare := mesh.duplicate(false) as ArrayMesh
			for surface in bare.get_surface_count(): bare.surface_set_material(surface,null)
			assert(ResourceSaver.save(bare,output,ResourceSaver.FLAG_COMPRESS) == OK)
			var loaded := ResourceLoader.load(output,"ArrayMesh",ResourceLoader.CACHE_MODE_IGNORE) as ArrayMesh
			var expected := fingerprint(mesh)
			assert(fingerprint(loaded) == expected,"Serialized mesh changed geometry")
			manifest.meshes[output] = expected
			await process_frame
	var file := FileAccess.open("res://kit/effects/prepared/geometry_hashes.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"\t"))
	file.close()
	print("BAKED_EFFECT_MESHES_PASS count=",manifest.meshes.size()," exact_array_hashes=true")
	quit()
