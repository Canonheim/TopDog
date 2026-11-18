extends Node
const Effect = preload("res://ui3d/chocolates_effect.gd")
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
var failures := 0
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)
func inspect_burst(burst: Node3D) -> void:
	check(burst.get_child_count() == 72,"72 chocolates")
	var variants := [{},{},{}]
	var shapes := [{},{},{}]
	var colors := [{},{},{}]
	var sizes := [{},{},{}]
	var lanes := {}
	var layers := {}
	var materials := {}
	var triangles := 0
	var instances := 0
	for flight in burst.get_children():
		var region: int = flight.get_meta("coverage_region")
		for pair in [[variants,"variant"],[shapes,"shape"],[colors,"color"],[sizes,"size_class"]]:
			var rows: Array = pair[0]
			var key: int = flight.get_meta(pair[1])
			rows[region][key] = rows[region].get(key,0)+1
		var lane: int = flight.get_meta("coverage_lane")
		var layer: int = flight.get_meta("height_layer")
		lanes[lane] = lanes.get(lane,0)+1
		layers[layer] = layers.get(layer,0)+1
		check(flight.find_children("*","CollisionObject3D",true,false).is_empty(),"No physics bodies/colliders")
		for mesh: MeshInstance3D in flight.find_children("*","MeshInstance3D",true,false):
			instances += 1
			check(mesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"No shadows")
			check(mesh.mesh.get_surface_count() == 1,"One surface per chocolate")
			var arrays := mesh.mesh.surface_get_arrays(0)
			var indices: Variant = arrays[Mesh.ARRAY_INDEX]
			triangles += (indices.size() if indices != null and indices.size() > 0 else arrays[Mesh.ARRAY_VERTEX].size())/3
			materials[mesh.get_active_material(0).get_instance_id()] = true
	for region in 3:
		check(variants[region].size() == 12 and variants[region].values().all(func(n): return n == 2),"All 12 variants balanced")
		check(shapes[region].size() == 6 and shapes[region].values().all(func(n): return n == 4),"Six shapes balanced")
		check(colors[region] == {0:8,1:8,2:8},"Milk/dark/white quotas")
		check(sizes[region] == {0:8,1:8,2:8},"Size quotas")
	check(lanes.size() == 12 and lanes.values().all(func(n): return n == 6),"Direction coverage")
	check(layers.size() == 6 and layers.values().all(func(n): return n == 12),"Height coverage")
	check(instances == 72 and triangles == 20064 and materials.size() == 1,"Geometry and shared material budgets")
	print("CHOCOLATES_GEOMETRY ",triangles," triangles; ",instances," instances; ",materials.size()," active material")
func _ready() -> void:
	check(Prep.validation_errors().is_empty(),"Registration complete")
	var camera := Node3D.new()
	add_child(camera)
	seed(4102)
	var expected := randi()
	seed(4102)
	var first := Prep.burst("chocolates",camera)
	check(randi() == expected,"Global gameplay RNG preserved")
	inspect_burst(first)
	var scene_ids := Effect.scenes.values().map(func(scene): return scene.get_instance_id())
	var profiles := {str(first.get_meta("burst_profile")):true}
	for attempt in 2:
		var next := Prep.burst("chocolates",camera)
		inspect_burst(next)
		var profile := str(next.get_meta("burst_profile"))
		check(not profiles.has(profile),"Fresh randomized profiles")
		profiles[profile] = true
	check(camera.get_child_count() == 3,"Three overlapping bursts")
	check(scene_ids == Effect.scenes.values().map(func(scene): return scene.get_instance_id()),"Stable cached models")
	await get_tree().create_timer(3.3).timeout
	check(camera.get_child_count() == 0,"Normal cleanup removes all bursts")
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
	check("Death by Chocolate" in editor.menu.items[4].options,"Customization menu option")
	editor._set_choice("effect","chocolates")
	Wardrobe.load_profiles()
	check(Wardrobe.profiles[Wardrobe.selected].effect == "chocolates","Saved selection")
	check(Net._clean_players([{"name":"Test","slot":0,"appearance":Wardrobe.for_slot(0)}])[0].appearance.effect == "chocolates","Network appearance")
	main._start_practice()
	await get_tree().create_timer(.8).timeout
	var climbers: Array = main.game.live_climbers()
	check(not climbers.is_empty(),"Practice climber exists")
	if not climbers.is_empty():
		var climber: Climber = climbers[0]
		var emitted: Array = []
		main.game.lock_effect.connect(func(effect): emitted.append(effect))
		main.game._rpc_freeze(climber.climber_id,climber.pose(),"made","locked",2.0,2.0,true)
		check(emitted == ["chocolates"],"Actual successful lock-in dispatch")
		check(not main.cam.find_children("ChocolatesBurst*","Node3D",false,false).is_empty(),"Match renders selected chocolates")
	await get_tree().create_timer(3.4).timeout
	check(main.cam.find_children("ChocolatesBurst*","Node3D",false,false).is_empty(),"Match effect cleans up")
	main.game.end_match()
	Wardrobe.profiles = original
	Wardrobe.selected = original_selected
	if existed:
		var file := FileAccess.open(save_path,FileAccess.WRITE)
		file.store_buffer(backup)
		file.close()
	else: DirAccess.remove_absolute(save_path)
	# Finish unrelated background loader tickets before headless renderer teardown.
	for child in main.get_children():
		if child.get_script() == Prep: child.set_process(false)
	for path in Prep.pending.keys():
		while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
		if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
			ResourceLoader.load_threaded_get(path)
	Prep.pending.clear()
	print("CHOCOLATES_CHECKS ","PASS" if failures == 0 else "FAIL")
	get_tree().quit(failures)
