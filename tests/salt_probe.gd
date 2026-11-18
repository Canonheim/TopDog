extends Node
const Effect = preload("res://ui3d/salt_effect.gd")
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
var failures := 0
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)
func inspect_burst(burst: Node3D) -> void:
	check(burst.get_child_count()==190,"Ten shakers plus 180 grains")
	var counts := [[0,0],[0,0],[0,0]]
	var triangles := 0
	var materials := {}
	var variants := [0]
	for flight in burst.get_children():
		var region: int = flight.get_meta("coverage_region")
		var grain: bool = flight.get_meta("grain")
		counts[region][1 if grain else 0] += 1
		if not grain: variants[int(flight.get_meta("shape"))] += 1
		check(flight.find_children("*","CollisionObject3D",true,false).is_empty(),"No physics")
		for mesh: MeshInstance3D in flight.find_children("*","MeshInstance3D",true,false):
			check(mesh.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"No shadows")
			check(mesh.mesh.get_surface_count()==1,"One surface")
			var arrays := mesh.mesh.surface_get_arrays(0)
			var indices: Variant = arrays[Mesh.ARRAY_INDEX]
			triangles += (indices.size() if indices != null and indices.size()>0 else arrays[Mesh.ARRAY_VERTEX].size())/3
			materials[mesh.get_active_material(0).get_instance_id()] = true
			if grain: check(mesh.mesh.get_aabb().size.length()*flight.base_size<.09,"Salt grains stay small")
	check(counts==[[3,60],[4,60],[3,60]],"Shakers and grains in all thirds")
	check(variants==[10],"Ten short shakers")
	check(triangles==4480 and materials.size()==1,"Geometry/shared material budget")
func _ready() -> void:
	check(Prep.validation_errors().is_empty(),"Registration complete")
	var camera := Node3D.new()
	add_child(camera)
	seed(4102)
	var expected := randi()
	seed(4102)
	var first := Prep.burst("salt",camera)
	check(randi() == expected,"Global gameplay RNG preserved")
	inspect_burst(first)
	var scene_ids := Effect.scenes.values().map(func(scene): return scene.get_instance_id())
	var profiles := {str(first.get_meta("burst_profile")):true}
	for attempt in 2:
		var next := Prep.burst("salt",camera)
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
	# Isolate this headless integration test from unrelated background loading.
	for child in main.get_children():
		if child.get_script() == Prep: child.set_process(false)
	await get_tree().create_timer(.8).timeout
	main.show_screen("customize")
	var editor: Control = main.screens.customize
	check("Salt" in editor.menu.items[4].options,"Customization menu option")
	editor._set_choice("effect","salt")
	Wardrobe.load_profiles()
	check(Wardrobe.profiles[Wardrobe.selected].effect == "salt","Saved selection")
	check(Net._clean_players([{"name":"Test","slot":0,"appearance":Wardrobe.for_slot(0)}])[0].appearance.effect == "salt","Network appearance")
	main._start_practice()
	await get_tree().create_timer(.8).timeout
	var climbers: Array = main.game.live_climbers()
	check(not climbers.is_empty(),"Practice climber exists")
	if not climbers.is_empty():
		var climber: Climber = climbers[0]
		var emitted: Array = []
		main.game.lock_effect.connect(func(effect): emitted.append(effect))
		main.game._rpc_freeze(climber.climber_id,climber.pose(),"made","locked",2.0,2.0,true)
		check(emitted == ["salt"],"Actual successful lock-in dispatch")
		check(not main.cam.find_children("SaltBurst*","Node3D",false,false).is_empty(),"Match renders selected salt")
	await get_tree().create_timer(3.4).timeout
	check(main.cam.find_children("SaltBurst*","Node3D",false,false).is_empty(),"Match effect cleans up")
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
	print("SALT_CHECKS ","PASS" if failures == 0 else "FAIL")
	get_tree().quit(failures)

