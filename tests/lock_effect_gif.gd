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
	for effect in ["confetti", "roses"]:
		for sample in range(1,4):
			label.text = "%s / TAKE %d" % [effect.to_upper(), sample]
			var before: Array = main.cam.get_children()
			main.lucha.play_lock_effect(effect)
			var emitted: Array = []
			for node in main.cam.get_children():
				if node not in before:
					emitted.append(node)
			assert(emitted.size() == 1)
			var root: Node = emitted[0]
			var signature := str(root.get_meta("burst_profile"))
			assert(not signatures.has(signature))
			signatures[signature] = true
			if effect == "confetti":
				var count := 0
				assert(root.get_child_count() == 28)
				var band_shapes := {}
				for particles in root.get_children():
					count += particles.amount
					assert(particles.amount in [2,3] and is_equal_approx(particles.lifetime, 2.2))
					var key := str(particles.get_meta("coverage_lane")) + ":" + str(particles.get_meta("shape"))
					assert(not band_shapes.has(key))
					band_shapes[key] = true
				assert(count == 70)
			elif effect == "roses":
				var petals := 0
				var roses := 0
				var petal_shapes := {}
				for child in root.get_children():
					if child is CPUParticles3D:
						petals += child.amount
						assert(child.amount == 2)
						var key := str(child.get_meta("coverage_lane")) + ":" + str(child.get_meta("shape"))
						assert(not petal_shapes.has(key))
						petal_shapes[key] = true
					else:
						roses += 1
				assert(petals == 72 and roses == 18 and petal_shapes.size() == 36)
			else:
				assert(root.get_child_count() == 72)
				var lanes := {}
				for bill in root.get_children():
					var lane: int = bill.get_meta("coverage_lane")
					lanes[lane] = lanes.get(lane, 0) + 1
				assert(lanes.size() == 12 and lanes.values().all(func(n): return n == 6))
			var directory := output.path_join("%s_%d" % [effect, sample])
			DirAccess.make_dir_recursive_absolute(directory)
			for frame in 64:
				await RenderingServer.frame_post_draw
				var picture := get_viewport().get_texture().get_image()
				picture.save_png(directory.path_join("%03d.png" % frame))
				await get_tree().process_frame
			await get_tree().create_timer(0.7).timeout
			assert(not is_instance_valid(root), "Effect must clean itself up")
			print("CAPTURE ", effect, " ", sample, " budget and uniqueness PASS")
	print("ALL BALANCED CAPTURES PASS")
	get_tree().quit()
