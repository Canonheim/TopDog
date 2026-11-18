extends Node
func _ready() -> void:
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(2).timeout
	main.lucha.title_attract = false
	main.show_screen("title")
	await get_tree().create_timer(1).timeout
	var bar = main.lucha.xp_display
	var celebrated: Array[int] = []
	bar.level_celebrated.connect(func(level): celebrated.append(level))
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("xp-centered-one.png"))
	bar.animate_to_total(14000)
	await get_tree().create_timer(1.65).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("xp-levelup.png"))
	await bar.gain_finished
	assert(celebrated == [2] and bar.level_text.text == "2" and bar.amount_text.text == "4,000 / 11,000 XP")
	bar.animate_to_total(36000)
	await bar.gain_finished
	assert(celebrated == [2,3,4])
	bar.animate_to_total(44000)
	main.show_screen("practice_settings")
	assert(bar._shown_total == 44000)
	await get_tree().create_timer(2.6).timeout
	assert(not bar.get_children().any(func(n): return n.has_meta("xp_sparks")))
	print("XP GAIN: fill, exact level crossings, multiple levels, hidden cleanup PASS")
	get_tree().quit()
