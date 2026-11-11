extends Node
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _ready() -> void:
	var save_path: String = Wardrobe.SavePaths.settings("climbers.cfg")
	var existed := FileAccess.file_exists(save_path)
	var backup := FileAccess.get_file_as_bytes(save_path) if existed else PackedByteArray()
	var original := Wardrobe.profiles.duplicate(true)
	var original_selected: int = Wardrobe.selected
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(1.0).timeout
	main.show_screen("customize")
	var editor: Control = main.screens.customize
	check(editor.stage.get_parent() == main.world, "Preview is in the real ring")
	check(not main.game.stage.base_root.visible, "Base hidden during customization")
	check(editor.menu.items[0].label == "CLIMBER", "Climber selector is first")
	check(editor.stage.get_node("DisplayPlatform") != null, "Unnumbered platform present")
	check(editor.find_children("*", "SubViewport", true, false).is_empty(), "No isolated viewport")
	main.show_screen("customize")
	main.show_screen("title")
	check(main.game.stage.base_root.visible and not editor.stage.visible, "Base restored and preview hidden on exit")
	main.show_screen("customize")
	Wardrobe.profiles = [Wardrobe.clean({})]
	Wardrobe.selected = 0
	editor._refresh()
	editor._add_climber()
	check(Wardrobe.profiles.size() == 2 and Wardrobe.selected == 1, "Add climber")
	editor._set_choice("head", 1)
	editor._set_choice("skin", 5)
	editor._set_choice("speedo", 3)
	editor._set_choice("effect", "roses")
	Wardrobe.load_profiles()
	check(Wardrobe.selected == 1 and Wardrobe.profiles[1] == {"head":1,"skin":5,"speedo":3,"effect":"roses"}, "Persist all cosmetic choices")
	editor._cycle(1)
	check(Wardrobe.selected == 0, "Next wraps")
	editor._cycle(-1)
	check(Wardrobe.selected == 1, "Previous wraps")
	check(Wardrobe.profiles[0].skin == 1, "Presets remain independent")
	var clean: Array = Net._clean_players([{"name":"Test", "slot":0, "appearance":Wardrobe.for_slot(0)}])
	check(clean[0].appearance.head == 1 and clean[0].appearance.skin == 5 and clean[0].appearance.effect == "roses", "Network preserves cosmetics")
	check(Wardrobe.clean({"head":999,"skin":-1,"speedo":999,"effect":"invalid"}) == {"head":1,"skin":0,"speedo":9,"effect":"confetti"}, "Network clamps unknown cosmetics")
	check(editor.menu.items[4].options == ["Confetti", "Roses", "Money", "Treasure", "Treats"] and editor.menu.items[4].index == 1, "Roses is selectable and restored")
	editor._set_choice("effect", "bills")
	Wardrobe.load_profiles()
	check(Wardrobe.profiles[Wardrobe.selected].effect == "bills", "Money choice persists")
	check(Wardrobe.clean({"effect":"bills"}).effect == "bills", "Money survives network sanitization")
	var bill_fx := preload("res://ui3d/peso_bills.gd").burst(main.cam)
	var bill_count := 0
	var wads := 0
	for emitter in bill_fx.get_children():
		bill_count += 1
		if emitter.get_meta("form") == 2:
			wads += 1
	check(bill_count == 72 and wads == 6, "Six bill colors with only six crumpled wads per burst")
	var rose_fx := preload("res://ui3d/rose_petals.gd").burst(main.cam)
	check(rose_fx.find_children("WholeRose*", "MeshInstance3D", false, false).size() == 18, "One whole rose per four of 72 petals")
	editor._set_choice("effect", "treasure")
	Wardrobe.load_profiles()
	check(Wardrobe.profiles[Wardrobe.selected].effect == "treasure", "Treasure saves per climber")
	check(Net._clean_players([{"name":"Test","slot":0,"appearance":Wardrobe.for_slot(0)}])[0].appearance.effect == "treasure", "Network preserves Treasure")
	editor._set_choice("effect", "treats")
	Wardrobe.load_profiles()
	check(Wardrobe.profiles[Wardrobe.selected].effect == "treats", "Treats saves per climber")
	check(Net._clean_players([{"name":"Test","slot":0,"appearance":Wardrobe.for_slot(0)}])[0].appearance.effect == "treats", "Network preserves Treats")
	var treat_profiles := {}
	for attempt in 3:
		var fx := preload("res://ui3d/dog_treats.gd").burst(main.cam)
		check(fx.get_child_count() == 90, "Treats has fixed 90-object budget")
		var signature := str(fx.get_meta("burst_profile"))
		check(not treat_profiles.has(signature), "Treats activation varies")
		treat_profiles[signature] = true
		var quotas := {}
		var large := 0
		for obj in fx.get_children():
			var key := str(obj.get_meta("coverage_lane"))+":"+str(obj.get_meta("treat_type"))
			quotas[key] = quotas.get(key,0)+1
			large += int(obj.get_meta("large"))
		check(large == 6 and quotas.size() == 27, "Only six large treats, with every type in every lane")
		for key in quotas:
			check(quotas[key] == (1 if key.ends_with("large_bone") or key.ends_with("chew_stick") else 4), "Balanced Treats quotas")
		fx.queue_free()
	var profiles_seen := {}
	for sample in 4:
		var treasure := preload("res://ui3d/treasure_effect.gd").burst(main.cam)
		var signature := str(treasure.get_meta("burst_profile"))
		check(not profiles_seen.has(signature), "Fresh randomized treasure burst profile")
		profiles_seen[signature] = true
		var lanes := {}
		var types := {}
		var regions := [{},{},{}]
		var sizes := [{},{},{}]
		for item in treasure.get_children():
			var lane: int = item.get_meta("coverage_lane")
			lanes[lane] = lanes.get(lane,0)+1
			types[item.get_meta("treasure_type")] = true
			var region: int = item.get_meta("coverage_region")
			var kind: String = item.get_meta("treasure_type")
			var size_class: int = item.get_meta("size_class")
			regions[region][kind] = regions[region].get(kind,0)+1
			sizes[region][size_class] = sizes[region].get(size_class,0)+1
		check(treasure.get_child_count() == 90 and types.size() == 18, "Treasure includes all 18 final models")
		check(lanes.size() == 15 and lanes.values().all(func(n): return n == 6), "Treasure randomization retains balanced coverage")
		check(regions[0] == regions[1] and regions[1] == regions[2], "Every treasure type balanced left center right")
		check(sizes.all(func(row): return row == {0:10,1:10,2:10}), "All three size classes balanced by screen third")
		treasure.queue_free()
	main._start_practice()
	await get_tree().create_timer(0.8).timeout
	var climbers: Array = main.game.live_climbers()
	check(not climbers.is_empty(), "Practice spawns")
	if not climbers.is_empty():
		var c: Climber = climbers[0]
		check(c.bodies.size() == 16, "All physical body pieces retained")
		var pelvis: MeshInstance3D = c.bodies.pelvis.find_child("Pelvis", true, false)
		check((pelvis.get_instance_shader_parameter("swatch_uv") as Vector2).is_equal_approx(AtlasPalette.swatch(Color(Wardrobe.SUITS[3])).uv), "Match speedo color")
		var chest: MeshInstance3D = c.bodies.chest.find_child("Chest", true, false)
		check((chest.get_instance_shader_parameter("swatch_uv") as Vector2).is_equal_approx(AtlasPalette.swatch(Color(Wardrobe.SKINS[5])).uv), "Match skin color")
		var model: Node = Wardrobe.SPIRAL.instantiate()
		check(c.bodies.head.find_child("Head", true, false).mesh == model.find_child("Head", true, false).mesh, "Match Spiral head")
		model.free()
		var effects: Array = []
		main.game.lock_effect.connect(func(effect): effects.append(effect))
		main.game._rpc_freeze(c.climber_id, c.pose(), "made", "locked", 2.0, 2.0, true)
		check(effects == ["treats"], "Successful lock uses the locking climber's Treats preset")
		check(main.cam.find_children("DogTreatBurst", "Node3D", false, false).size() > 0, "Lock emits Treats in game")
		main.lucha.play_lock_effect("confetti")
		check(main.cam.find_children("ConfettiBurst", "Node3D", false, false).size() > 0 and main.cam.find_children("*", "CPUParticles3D", true, false).size() > 0, "Original confetti remains available")
	main.show_screen("customize")
	check(editor._climber_names() == ["1", "2"], "Selector uses numbers only")
	editor._ask_delete()
	check(Wardrobe.profiles.size() == 2 and editor.confirming, "Delete waits for confirmation")
	main._back()
	check(Wardrobe.profiles.size() == 2 and not editor.confirming and main.screen == "customize", "Back cancels deletion")
	editor._ask_delete()
	editor._confirm_delete()
	check(Wardrobe.profiles.size() == 1 and Wardrobe.selected == 0, "Confirmed deletion keeps selection valid")
	editor._ask_delete()
	editor._confirm_delete()
	check(Wardrobe.profiles.size() == 1 and Wardrobe.profiles[0] == Wardrobe.clean({}), "Deleting last climber creates default")
	await get_tree().create_timer(1.0).timeout
	var item: Dictionary = editor.menu.items[1]
	for action in [[1.36, 1], [-1.36, 0], [-0.3, 1]]:
		var pixel: Vector2 = main.cam.unproject_position(item.node.to_global(Vector3(action[0], 0, 0)))
		check(editor.menu._pick(pixel) == 1, "Mouse reaches selector and arrows")
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = true
		click.position = pixel
		editor.menu._unhandled_input(click)
		check(Wardrobe.profiles[0].head == action[1], "Arrow direction and central next click")
		await get_tree().create_timer(0.3).timeout
	main.game.end_match()
	main.show_screen("customize")
	main._back()
	check(main.screen == "title", "Back returns to title")
	Wardrobe.profiles = original
	Wardrobe.selected = original_selected
	if existed:
		var file := FileAccess.open(save_path, FileAccess.WRITE)
		file.store_buffer(backup)
		file.close()
	else:
		DirAccess.remove_absolute(save_path)
	print("CUSTOMIZATION CHECKS: ", "PASS" if failures == 0 else "FAIL")
	get_tree().quit(failures)
