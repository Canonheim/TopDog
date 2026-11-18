extends Node
const Roses = preload("res://ui3d/rose_petals.gd")
const Bills = preload("res://ui3d/peso_bills.gd")
var signatures := {}

func _ready() -> void:
	var output := OS.get_environment("TEMP").path_join("topdog-effect-frames-balanced")
	DirAccess.make_dir_recursive_absolute(output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(960, 540))
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(1.5).timeout
	main.practice_settings.practice_npc = false
	main._start_practice()
	await get_tree().create_timer(2.0).timeout
	main.show_screen("effect_capture")
	main.set_process(false)
	main.game.set_physics_process(false)
	main.lucha.set_process(false)
	main._pad_corner.hide()
	for c: Climber in main.game.climbers.values():
		c.set_physics_process(false)
		for body: RigidBody3D in c.bodies.values():
			body.freeze = true
	main.cam.position = Vector3(0, 2.5, 9.5)
	main.cam.look_at(Vector3(0, 2.0, 0))
	# Build the finite mesh cache before the recordings.
	for i in Roses.VARIANTS:
		Roses.rose_mesh(i)
	for i in Bills.COLORS.size():
		for form in 3:
			Bills.bill_mesh(i, form)
	var overlay := CanvasLayer.new()
	add_child(overlay)
	var label := Label.new()
	label.position = Vector2(20, 18)
	label.add_theme_font_override("font", load(LuchaKit.TITLE_FONT))
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_constant_override("outline_size", 8)
	overlay.add_child(label)
	for sample in range(1,4):
		label.text = "DOG TOYS / TAKE %d" % sample
		if sample == 1:
			var c: Climber = main.game.climbers.values()[0]
			main.game.roster_entry(c.player_id)["appearance"] = Wardrobe.clean({"effect":"dog_toys"})
			main.game._rpc_freeze(c.climber_id,c.pose(),"made","locked",2.0,2.0,true)
		else:
			main.game.lock_effect.emit("dog_toys")
		var root = main.cam.get_node("DogToysBurst")
		assert(root.get_child_count() == 90)
		var signature := str(root.get_meta("burst_profile"))
		assert(not signatures.has(signature))
		signatures[signature] = true
		var quotas := [{},{},{}]
		for piece in root.get_children():
			var region: int = piece.get_meta("coverage_region")
			var toy: int = piece.get_meta("toy")
			quotas[region][toy] = quotas[region].get(toy,0)+1
		assert(quotas[0] == quotas[1] and quotas[1] == quotas[2])
		assert(quotas[0].size() == 18)
		assert(Wardrobe.clean({"effect":"dog_toys"}).effect == "dog_toys")
		var directory := output.path_join("dog_toys_%d" % sample)
		DirAccess.make_dir_recursive_absolute(directory)
		for frame in 48:
			await RenderingServer.frame_post_draw
			var shot := get_viewport().get_texture().get_image()
			shot.resize(960,540)
			shot.save_png(directory.path_join("%03d.png" % frame))
			await get_tree().process_frame
		await get_tree().create_timer(3.3).timeout
		assert(not is_instance_valid(root))
		print("DOG TOYS TAKE ",sample," PASS")
	get_tree().quit()
