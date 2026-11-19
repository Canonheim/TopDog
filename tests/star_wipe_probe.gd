extends Node
## THE STAR WIPE, WATCHED (Parker 11-20): the real game from its title, the solo climb started through
## main.start_peak_wiped(), the screen saved as the star closes, while it is black, and as it opens on the
## station. Run it with APPDATA pointed at a scratch folder (main reads the player's own settings):
##   Godot --path . --audio-driver Dummy res://tests/star_wipe_probe.tscn -- --no-steam --out=DIR
var out := "user://star_wipe"
var main: Node
var n := 0


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.get_slice("=", 1)
	DirAccess.make_dir_recursive_absolute(out)
	main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(1.5).timeout
	get_window().size = Vector2i(1280, 720)
	await get_tree().create_timer(0.5).timeout
	await shot("0_title")
	main.start_peak_wiped()
	var t0 := Time.get_ticks_msec()
	var marks := [0.15, 0.3, 0.45]
	for m in marks:
		while (Time.get_ticks_msec() - t0) / 1000.0 < m:
			await get_tree().process_frame
		await shot("1_closing_%03d" % int(m * 1000))
	while main._wiping and main._wipe.material.get_shader_parameter("open") > 0.02:
		await get_tree().process_frame
	await shot("2_black")
	while main._wiping and main._wipe.material.get_shader_parameter("open") < 0.25:
		await get_tree().process_frame
	await shot("3_opening_a")
	while main._wiping and main._wipe.material.get_shader_parameter("open") < 0.6:
		await get_tree().process_frame
	await shot("3_opening_b")
	while main._wiping:
		await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	await shot("4_station")
	print("WIPE done in %.2f s" % ((Time.get_ticks_msec() - t0) / 1000.0))
	get_tree().quit()


func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.resize(640, 360, Image.INTERPOLATE_BILINEAR)
	img.save_jpg(out.path_join(name + ".jpg"), 0.85)
	print("WIPE shot ", name)
