extends Node
const Leaves = preload("res://ui3d/pickles_effect.gd")
var failures := 0
func check(ok: bool,label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)

func inspect_burst(root: Node3D) -> int:
	check(root.get_child_count() == 72,"72 leaf budget")
	var shapes := [{},{},{}]
	var sizes := [{},{},{}]
	var lanes := {}
	var layers := {}
	var triangles := 0
	var surfaces := 0
	var mats := {}
	for leaf in root.get_children():
		check(leaf is MeshInstance3D and not leaf is PhysicsBody3D,"Mesh-only leaves")
		check(leaf.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"No leaf shadows")
		var mesh: ArrayMesh = leaf.mesh
		check(mesh.get_surface_count() == 1,"One surface per leaf")
		var tris := mesh.surface_get_array_len(0)/3
		check(tris <= 400,"Per-leaf triangle budget")
		triangles += tris
		surfaces += mesh.get_surface_count()
		mats[mesh.surface_get_material(0).get_instance_id()] = true
		var region: int = leaf.get_meta("coverage_region")
		var shape: int = leaf.get_meta("shape")
		var size_class: int = leaf.get_meta("size_class")
		var lane: int = leaf.get_meta("coverage_lane")
		var layer: int = leaf.get_meta("height_layer")
		shapes[region][shape] = shapes[region].get(shape,0)+1
		sizes[region][size_class] = sizes[region].get(size_class,0)+1
		lanes[lane] = lanes.get(lane,0)+1
		layers[layer] = layers.get(layer,0)+1
	check(shapes.all(func(row): return row == {0:2,1:2,2:2,3:4,4:4,5:4,6:2,7:2,8:2}),"Balanced silhouettes")
	check(sizes.all(func(row): return row == {0:8,1:8,2:8}),"Balanced size classes")
	check(lanes.size() == 12 and lanes.values().all(func(n): return n == 6),"12 overlapping direction lanes")
	check(layers.size() == 6 and layers.values().all(func(n): return n == 12),"Six overlapping height layers")
	check(triangles <= 30000 and surfaces == 72 and mats.size() == 1,"Burst geometry/material budget")
	print("PICKLES_GEOMETRY triangles=",triangles," instances=72 surfaces=",surfaces," materials=",mats.size()," cached_meshes=",Leaves.meshes.size())
	return triangles

func check_spear_winding() -> void:
	for variant in 3:
		var arrays := Leaves.meshes[6+variant].surface_get_arrays(0)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		for row in 6:
			for triangle in 12:
				var offset := (row*16+triangle)*3
				var center := (vertices[offset]+vertices[offset+1]+vertices[offset+2])/3.0
				var t := center.y/(.32+variant*.015)
				var outward := Vector3(center.x-.025*(variant-1)*(1-t*t),0,center.z)
				check(normals[offset].dot(outward)>0,"Spear rind faces outward")
		for triangle in 12:
			var offset := vertices.size()-36+triangle*3
			check(normals[offset].y*vertices[offset].y>0,"Spear ends face outward")

func _ready() -> void:
	var camera := Node3D.new()
	add_child(camera)
	# Benchmark cold CPU preparation and spawn separately from gameplay startup.
	seed(5412)
	var expected_rng := randi()
	seed(5412)
	check(Leaves.meshes.is_empty(),"Cold benchmark starts with empty Autumn cache")
	var started := Time.get_ticks_usec()
	var cold := Leaves.burst(camera)
	var cold_ms := (Time.get_ticks_usec()-started)/1000.0
	check(randi() == expected_rng,"Cosmetic randomness leaves global RNG untouched")
	check_spear_winding()
	inspect_burst(cold)
	print("PICKLES_COLD_SPAWN_MS ",cold_ms," PREWARM_MS ",Leaves.preparation_usec/1000.0)
	var mesh_ids := Leaves.meshes.map(func(mesh): return mesh.get_instance_id())
	var unique := {str(cold.get_meta("burst_profile")):true}
	await get_tree().create_timer(3.3).timeout
	check(not is_instance_valid(cold),"Cold burst cleans up")
	var warm_times := []
	for attempt in 3:
		started = Time.get_ticks_usec()
		var warm := Leaves.burst(camera)
		warm_times.append((Time.get_ticks_usec()-started)/1000.0)
		inspect_burst(warm)
		var profile := str(warm.get_meta("burst_profile"))
		check(not unique.has(profile),"Fresh bounded burst profile")
		unique[profile] = true
		check(Leaves.meshes.map(func(mesh): return mesh.get_instance_id()) == mesh_ids,"Warm activations reuse meshes")
		await get_tree().create_timer(3.3).timeout
		check(not is_instance_valid(warm),"Warm burst cleans up by 3.3 seconds")
	print("PICKLES_WARM_SPAWN_MS ",warm_times)
	camera.queue_free()
	var original: Array = Wardrobe.profiles.duplicate(true)
	var original_selected: int = Wardrobe.selected
	var save_path: String = Wardrobe.SavePaths.settings("climbers.cfg")
	var existed := FileAccess.file_exists(save_path)
	var backup := FileAccess.get_file_as_bytes(save_path) if existed else PackedByteArray()
	var main = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().create_timer(.8).timeout
	main.show_screen("customize")
	var editor: Control = main.screens.customize
	check("Pickles" in editor.menu.items[4].options,"Pickles menu option")
	editor._set_choice("effect","pickles")
	Wardrobe.load_profiles()
	check(Wardrobe.profiles[Wardrobe.selected].effect == "pickles","Pickles saved selection")
	check(Net._clean_players([{"name":"Test","slot":0,"appearance":Wardrobe.for_slot(0)}])[0].appearance.effect == "pickles","Network preserves Pickles")
	main._start_practice()
	await get_tree().create_timer(.8).timeout
	var climbers: Array = main.game.live_climbers()
	check(not climbers.is_empty(),"Practice climber exists")
	if not climbers.is_empty():
		var climber: Climber = climbers[0]
		var emitted: Array = []
		main.game.lock_effect.connect(func(effect): emitted.append(effect))
		main.game._rpc_freeze(climber.climber_id,climber.pose(),"made","locked",2.0,2.0,true)
		check(emitted == ["pickles"],"Actual match dispatch uses selected Pickles")
		check(not main.cam.find_children("PicklesBurst*","Node3D",false,false).is_empty(),"Actual match creates Pickles")
	await get_tree().create_timer(3.4).timeout
	check(main.cam.find_children("PicklesBurst*","Node3D",false,false).is_empty(),"Match effect cleans up")
	main.game.end_match()
	Wardrobe.profiles = original
	Wardrobe.selected = original_selected
	if existed:
		var file := FileAccess.open(save_path,FileAccess.WRITE)
		file.store_buffer(backup)
		file.close()
	else:
		DirAccess.remove_absolute(save_path)
	print("PICKLES CHECKS: ","PASS" if failures == 0 else "FAIL")
	get_tree().quit(failures)
