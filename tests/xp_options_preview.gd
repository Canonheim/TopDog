extends Node
const Progression = preload("res://core/player_progression.gd")
func _ready() -> void:
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(2.0).timeout
	main.lucha.title_attract = false
	main.show_screen("title")
	await get_tree().create_timer(1.5).timeout
	var original = main.lucha.xp_display
	original.hide()
	var bar = preload("res://ui3d/xp_layout_options.gd").new()
	original.get_parent().add_child(bar)
	bar.transform = original.transform
	bar.position.y += 0.0
	var output := "C:/Users/growi/Documents/ChatGPT/Top dog 2/xp-belt-refined"
	DirAccess.make_dir_recursive_absolute(output)
	for i in [1]:
		bar.set_style(i)
		bar.set_progress(Progression.snapshot(250))
		await get_tree().create_timer(.3).timeout
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		img.save_png(output.path_join("option_%d_full.png" % (i+1)))
		var a: Vector2 = main.cam.unproject_position(bar.to_global(Vector3(-2.85,1.20,.25)))
		var b: Vector2 = main.cam.unproject_position(bar.to_global(Vector3(2.85,-1.12,.25)))
		img.get_region(Rect2i(Vector2i(a),Vector2i(b-a))).save_png(output.path_join("option_%d.png" % (i+1)))
		assert(bar.next_text.text == "Next Level Up Reward:\nComing soon.")
		print("XP OPTION ",i+1," PASS")
	get_tree().quit()
