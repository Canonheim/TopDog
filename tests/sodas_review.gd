extends Node
const FX = preload("res://ui3d/sodas_effect.gd")
const OUT = "C:/Users/growi/Documents/ChatGPT/Top dog 2/sodas-review/"
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	await gallery()
	var prep = preload("res://ui3d/lock_effect_preparation.gd")
	while not prep.is_prepared("sodas"):
		assert(prep.failed_effects.is_empty())
		prep.prepare_step("sodas")
		await get_tree().process_frame
	var camera := Camera3D.new()
	add_child(camera)
	var signatures := {}
	var mesh_ids := {}
	for sample in 3:
		var root: Node3D = FX.burst(camera)
		assert(root.get_child_count() == 90)
		var quotas := [{},{},{}]
		var counts := [0,0,0]
		for piece in root.get_children():
			var region: int = piece.get_meta("coverage_region")
			var family: int = piece.get_meta("family")
			counts[family] += 1
			if family == 2:
				assert(piece.spin == Vector3.ZERO)
				var expected_size: float = [.48,.85,1.28][piece.get_meta("size_class")]
				assert(absf(piece.scale.x-expected_size) <= .036)
				piece.delay = 0
				var stable_time := 0.0
				for tick in 114:
					var previous: Quaternion = piece.quaternion
					piece._process(.025)
					assert(piece.quaternion.is_finite())
					assert(previous.angle_to(piece.quaternion) <= .201)
					stable_time = stable_time+.025 if piece.velocity.length() > .75 else 0.0
					if stable_time > .5 and not piece.is_queued_for_deletion():
						assert((-piece.basis.y.normalized()).dot(piece.velocity.normalized()) > .8)
				assert(piece.is_queued_for_deletion())
			var key := str(family)+":"+str(piece.get_meta("color"))+":"+str(piece.get_meta("size_class"))
			quotas[region][key] = quotas[region].get(key,0)+1
			for visual in piece.find_children("*","MeshInstance3D",true,false):
				assert(visual.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
				mesh_ids[visual.mesh.get_instance_id()] = true
		assert(counts == [18,18,54])
		assert(quotas[0] == quotas[1] and quotas[1] == quotas[2])
		var signature := str(root.get_meta("burst_profile"))
		assert(not signatures.has(signature))
		signatures[signature] = true
	assert(mesh_ids.size() == 15)
	assert(camera.get_child_count() == 3)
	await get_tree().create_timer(3.5).timeout
	assert(camera.get_child_count() == 0)
	print("SODAS PASS: three overlapping bursts, 18 bottles/18 caps/54 drops, balanced family-color-size quotas, 15 reused meshes, velocity-following droplets with bounded turns/size quotas over full lifespan, and cleanup")
	camera.queue_free()
	# Degenerate and near-vertical apex cases must remain finite and turn smoothly.
	for initial in [Vector3.ZERO,Vector3(0,.01,0),Vector3(0,1,0),Vector3(.001,1,0)]:
		var drop := FX.SodaDrop.new()
		add_child(drop)
		drop.velocity = initial
		if initial.length_squared() > .000001: drop.quaternion = Quaternion(Vector3.DOWN,initial.normalized())
		for tick in 114:
			var previous := drop.quaternion
			drop._process(.025)
			assert(drop.quaternion.is_finite())
			assert(previous.angle_to(drop.quaternion) <= .201)
		assert(drop.is_queued_for_deletion())
	await get_tree().process_frame
	var main = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().create_timer(.7).timeout
	var save_path: String = Wardrobe.SavePaths.settings("climbers.cfg")
	var existed := FileAccess.file_exists(save_path)
	var backup := FileAccess.get_file_as_bytes(save_path) if existed else PackedByteArray()
	var original := Wardrobe.profiles.duplicate(true)
	var selected: int = Wardrobe.selected
	main.show_screen("customize")
	main.screens.customize._set_choice("effect","sodas")
	Wardrobe.load_profiles()
	assert(Wardrobe.profiles[Wardrobe.selected].effect == "sodas")
	assert(Net._clean_players([{"name":"Test","slot":0,"appearance":Wardrobe.for_slot(0)}])[0].appearance.effect == "sodas")
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
		label.text = "SODAS / TAKE %d" % (sample+1)
		if sample == 0:
			var c: Climber = main.game.climbers.values()[0]
			main.game.roster_entry(c.player_id)["appearance"] = Wardrobe.clean({"effect":"sodas"})
			main.game._rpc_freeze(c.climber_id,c.pose(),"made","locked",2.0,2.0,true)
		else: main.game.lock_effect.emit("sodas")
		var burst: Node3D = main.cam.get_node("SodasBurst")
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
		print("SODAS TAKE ",sample+1," cleanup PASS")
	print("SODAS ALL CHECKS PASS: saved/network selection, actual match lock-in, 3 distinct profiles, cleanup")
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
	camera.position = Vector3(0,.02,5)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 1.8
	camera.current = true
	CelPass.add_outline_pass(world)
	for color in 5:
		for family in 3:
			var path: String = "res://kit/models/soda_"+["bottle_","cap_","drop_"][family]+str(color)+".glb"
			var model: Node3D = load(path).instantiate()
			world.add_child(model)
			CelPass.celify(model)
			model.position = Vector3(-1.16+color*.58,.28 if family==0 else -.40,0)
			model.rotation = Vector3(.12,-.4,-.05) if family==0 else Vector3(.9,.15,.1)
			model.scale = Vector3.ONE*(1.8 if family==0 else 2.1)
			if family == 1: model.position.x -= .12
			if family == 2: model.position.x += .15
		var label := Label3D.new()
		label.text = ["ORANGE","LIME","GREEN","GOLD","RED"][color]
		label.font_size = 28
		label.pixel_size = .002
		label.position = Vector3(-1.16+color*.58,-.64,0)
		world.add_child(label)
	await get_tree().create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	var picture := get_viewport().get_texture().get_image()
	picture.resize(1400,788)
	picture.save_png(OUT+"sodas-gallery.png")
	world.queue_free()
	await get_tree().process_frame
