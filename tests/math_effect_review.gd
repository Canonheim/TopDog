extends Node
const FX = preload("res://ui3d/math_effect.gd")
const OUT = "C:/Users/growi/Documents/ChatGPT/Top dog 2/math-effect-review/"
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var camera := Camera3D.new()
	add_child(camera)
	var start := Time.get_ticks_usec()
	var cold: Node3D = FX.burst(camera)
	print("COLD CPU spawn_ms=",(Time.get_ticks_usec()-start)/1000.0," prepare_ms=",FX.prewarm_usec/1000.0)
	cold.free()
	var times: Array = []
	for attempt in 21:
		start = Time.get_ticks_usec()
		var root: Node3D = FX.burst(camera)
		times.append((Time.get_ticks_usec()-start)/1000.0)
		assert(root.get_child_count() == 24)
		var quotas := [{},{},{}]
		var sizes := [{},{},{}]
		var variants := {}
		var materials := {}
		var triangles := 0
		var families := {}
		var crossings := {}
		for p in root.get_children():
			var region: int = p.get_meta("cohort")
			var diagram: bool = p.get_meta("diagram")
			var size: int = p.get_meta("size_class")
			var variant: int = p.get_meta("variant")
			quotas[region][diagram] = quotas[region].get(diagram,0)+1
			sizes[region][size] = sizes[region].get(size,0)+1
			variants[variant] = variants.get(variant,0)+1
			materials[p.mesh.surface_get_material(0).get_instance_id()] = true
			triangles += p.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()/3
			assert(p.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
			var family: int = p.get_meta("direction_family")
			families[family] = families.get(family,0)+1
			var pair: int = p.get_meta("pair")
			var at: Vector3 = p.origin+p.velocity*float(p.get_meta("crossing_age"))
			# Compare projected points, since depth is independently varied.
			var projected := Vector2(at.x,at.y)/-at.z
			if crossings.has(pair): assert(projected.distance_to(crossings[pair]) < .00001)
			else: crossings[pair] = projected
			var initial_rotation: Vector3 = p.rotation
			var initial_scale: Vector3 = p.scale
			p._process(p.delay+.4)
			assert(p.position.is_equal_approx(p.origin+p.velocity*.4))
			p._process(.2)
			assert(p.position.is_equal_approx(p.origin+p.velocity*.6))
			assert(p.rotation == initial_rotation and p.scale == initial_scale)
		assert(quotas[0] == quotas[1] and quotas[1] == quotas[2])
		assert(sizes[0] == sizes[1] and sizes[1] == sizes[2])
		assert(variants.size() == 12 and variants.values().all(func(n): return n == 2))
		assert(families.size() == 8 and families.values().all(func(n): return n == 3))
		assert(crossings.size() == 12)
		assert(materials.size() == 1 and triangles == 48)
		root.free()
	times.sort()
	print("PREPARED spawn median_ms=",times[10]," range_ms=",times[0],"..",times[20])
	print("PASS: 24 meshes, 24 surfaces, 48 triangles, 12 cached meshes, one material/texture; fixed trajectories/angles/scales; balanced quotas")
	camera.queue_free()
	var main = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().create_timer(.7).timeout
	var save_path: String = Wardrobe.SavePaths.settings("climbers.cfg")
	var existed := FileAccess.file_exists(save_path)
	var backup := FileAccess.get_file_as_bytes(save_path) if existed else PackedByteArray()
	var original := Wardrobe.profiles.duplicate(true)
	var selected: int = Wardrobe.selected
	main.show_screen("customize")
	main.screens.customize._set_choice("effect","math")
	Wardrobe.load_profiles()
	assert(Wardrobe.profiles[Wardrobe.selected].effect == "math")
	assert(Net._clean_players([{"name":"Test","slot":0,"appearance":Wardrobe.for_slot(0)}])[0].appearance.effect == "math")
	Wardrobe.profiles = original
	Wardrobe.selected = selected
	if existed:
		var file := FileAccess.open(save_path,FileAccess.WRITE)
		file.store_buffer(backup)
		file.close()
	else: DirAccess.remove_absolute(save_path)
	main.practice_settings.practice_npc = false
	main._start_practice()
	await get_tree().create_timer(.7).timeout
	main.show_screen("effect_capture")
	main.set_process(false)
	main.game.set_physics_process(false)
	main.lucha.set_process(false)
	main._pad_corner.hide()
	main.lucha._hud.hide()
	for previous in main.cam.get_children():
		if previous.has_meta("burst_profile"): previous.queue_free()
	await get_tree().process_frame
	Engine.time_scale = 1
	for c in main.game.climbers.values():
		c.set_physics_process(false)
		for body in c.bodies.values(): body.freeze = true
	main.cam.position = Vector3(0,2.5,9.5)
	main.cam.look_at(Vector3(0,2,0))
	var overlay := CanvasLayer.new()
	add_child(overlay)
	var label := Label.new()
	label.position = Vector2(20,20)
	label.add_theme_font_size_override("font_size",28)
	label.add_theme_constant_override("outline_size",5)
	overlay.add_child(label)
	var signatures := {}
	for sample in 3:
		label.text = "MATH / TAKE %d" % (sample+1)
		if sample == 0:
			var c: Climber = main.game.climbers.values()[0]
			main.game.roster_entry(c.player_id)["appearance"] = Wardrobe.clean({"effect":"math"})
			main.game._rpc_freeze(c.climber_id,c.pose(),"made","locked",2.0,2.0,true)
		else: main.game.lock_effect.emit("math")
		var burst: Node3D = main.cam.get_node("MathBurst")
		var signature := str(burst.get_meta("burst_profile"))
		assert(not signatures.has(signature))
		signatures[signature] = true
		main.lucha._hud.hide()
		for frame in 84:
			await RenderingServer.frame_post_draw
			var image := get_viewport().get_texture().get_image()
			image.resize(1200,675)
			image.save_png(OUT+"take%d_%03d.png" % [sample,frame])
			await get_tree().process_frame
		await get_tree().create_timer(3.3).timeout
		assert(not is_instance_valid(burst))
		print("MATH TAKE ",sample+1," cleanup PASS")
	print("MATH ALL CHECKS PASS: saved/network selection, actual match lock-in, 3 distinct profiles, cleanup")
	get_tree().quit()
