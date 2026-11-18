extends Node
const FX = preload("res://ui3d/grass_effect.gd")
const OUT = "C:/Users/growi/Documents/ChatGPT/Top dog 2/grass-review/"
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	await gallery()
	var prep = preload("res://ui3d/lock_effect_preparation.gd")
	while not prep.is_prepared("grass"):
		assert(prep.failed_effects.is_empty())
		prep.prepare_step("grass")
		await get_tree().process_frame
	var camera := Camera3D.new()
	add_child(camera)
	var signatures := {}
	var mesh_ids := {}
	for sample in 3:
		var root: Node3D = FX.burst(camera)
		assert(root.get_child_count() == 90)
		var quotas := [{},{},{}]
		var sizes := [{},{},{}]
		var families := [0,0,0]
		
		for piece in root.get_children():
			var region: int = piece.get_meta("coverage_region")
			var variant: int = piece.get_meta("variant")
			var size: int = piece.get_meta("size_class")
			families[piece.get_meta("family")] += 1
			quotas[region][variant] = quotas[region].get(variant,0)+1
			sizes[region][size] = sizes[region].get(size,0)+1
			for visual in piece.find_children("*","MeshInstance3D",true,false):
				assert(visual.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
				mesh_ids[visual.mesh.get_instance_id()] = true
		assert(families == [54,30,6])
		assert(quotas[0] == quotas[1] and quotas[1] == quotas[2])
		assert(quotas[0].size() == 12 and quotas[0][10] == 1 and quotas[0][11] == 1)
		assert(sizes[0] == sizes[1] and sizes[1] == sizes[2])
		assert(sizes[0].values().all(func(n): return n == 10))
		var signature := str(root.get_meta("burst_profile"))
		assert(not signatures.has(signature))
		signatures[signature] = true
	assert(mesh_ids.size() == 12)
	assert(camera.get_child_count() == 3)
	await get_tree().create_timer(3.5).timeout
	assert(camera.get_child_count() == 0)
	print("GRASS PASS: 90 pieces, 54 clippings / 30 long blades / 6 seed heads, 12 reused meshes, balanced variant/size quotas, 3 overlapping bursts and cleanup")
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
	main.screens.customize._set_choice("effect","grass")
	Wardrobe.load_profiles()
	assert(Wardrobe.profiles[Wardrobe.selected].effect == "grass")
	assert(Net._clean_players([{"name":"Test","slot":0,"appearance":Wardrobe.for_slot(0)}])[0].appearance.effect == "grass")
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
	var rendered_signatures := {}
	for sample in 3:
		label.text = "GRASS / TAKE %d" % (sample+1)
		if sample == 0:
			var c: Climber = main.game.climbers.values()[0]
			main.game.roster_entry(c.player_id)["appearance"] = Wardrobe.clean({"effect":"grass"})
			main.game._rpc_freeze(c.climber_id,c.pose(),"made","locked",2.0,2.0,true)
		else: main.game.lock_effect.emit("grass")
		var burst: Node3D = main.cam.get_node("GrassBurst")
		var signature := str(burst.get_meta("burst_profile"))
		assert(not rendered_signatures.has(signature))
		rendered_signatures[signature] = true
		main.lucha._hud.hide()
		for frame in 84:
			await RenderingServer.frame_post_draw
			var image := get_viewport().get_texture().get_image()
			image.resize(1200,675)
			image.save_png(OUT+"take%d_%03d.png" % [sample,frame])
			await get_tree().process_frame
		await get_tree().create_timer(3.3).timeout
		assert(not is_instance_valid(burst))
		print("GRASS TAKE ",sample+1," cleanup PASS")
	print("GRASS ALL CHECKS PASS: saved/network selection, actual match lock-in, 3 distinct profiles, cleanup")
	get_tree().quit()

func gallery() -> void:
	var world := Node3D.new()
	add_child(world)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("17273b")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("c5d6ec")
	env.environment.ambient_light_energy = .65
	world.add_child(env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-28,-25,0)
	light.light_energy = 1.25
	world.add_child(light)
	var camera := Camera3D.new()
	world.add_child(camera)
	camera.position = Vector3(0,0,5)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.45
	camera.current = true
	CelPass.add_outline_pass(world)
	for variant in 12:
		var model: Node3D = load("res://kit/models/grass_"+str(variant)+".glb").instantiate()
		world.add_child(model)
		CelPass.celify(model)
		model.position = Vector3(-1.05+(variant%4)*.70,.80-(variant/4)*.77,0)
		model.rotation = Vector3(.14,-.45,-.05)
		model.scale = Vector3.ONE*1.0
		var label := Label3D.new()
		label.text = ("CUT" if variant<6 else "BLADE" if variant<10 else "SEED")+" "+str(variant+1)
		label.font_size = 28
		label.pixel_size = .002
		label.position = model.position+Vector3(0,-.37,0)
		world.add_child(label)
	await get_tree().create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	var picture := get_viewport().get_texture().get_image()
	picture.resize(1400,788)
	picture.save_png(OUT+"grass-gallery.png")
	world.queue_free()
	await get_tree().process_frame
