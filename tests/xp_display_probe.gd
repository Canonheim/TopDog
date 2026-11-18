extends Node
const Progression = preload("res://core/player_progression.gd")
func _ready() -> void:
	assert(Progression.snapshot(-1).xp == 0)
	assert(Progression.snapshot(499).level == 1)
	assert(Progression.snapshot(500).level == 2 and Progression.snapshot(500).xp == 0)
	assert(Progression.snapshot(1050).level == 3)
	assert(Progression.snapshot(292050).level == 100 and Progression.snapshot(292050).fraction == 1.0)
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(2.0).timeout
	main.lucha.title_attract = false
	main.show_screen("title")
	await get_tree().create_timer(1.5).timeout
	var bar = main.lucha.xp_display
	assert(bar.visible and not bar.fill.visible)
	bar.set_progress(Progression.snapshot(250))
	assert(is_equal_approx(bar.fill.scale.x, bar.meter_width*.5))
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("topdog-xp-half.png"))
	bar.set_progress(Progression.snapshot(292050))
	assert(bar.amount_text.text == "MAX LEVEL")
	main.show_screen("practice_settings")
	assert(not bar.is_visible_in_tree())
	main.show_screen("title")
	await get_tree().create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("topdog-xp-main.png"))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	for window_size in [Vector2i(1280,800),Vector2i(1024,768)]:
		DisplayServer.window_set_size(window_size)
		await get_tree().create_timer(.5).timeout
		var viewport_size := get_viewport().get_visible_rect().size
		assert(absf(viewport_size.x / viewport_size.y - float(window_size.x) / window_size.y) < .02)
		for corner in [Vector3(-2.58,-.99,0),Vector3(2.58,1.08,0)]:
			var pixel: Vector2 = main.cam.unproject_position(bar.to_global(corner))
			assert(pixel.x >= 0 and pixel.x <= viewport_size.x and pixel.y >= 0 and pixel.y <= viewport_size.y)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("topdog-xp-%d.png" % window_size.x))
	print("XP DISPLAY: boundaries, fill, cap, visibility, 16:10 and 4:3 fit PASS")
	get_tree().quit()
