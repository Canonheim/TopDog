extends Node
const Effect = preload("res://ui3d/chocolates_effect.gd")
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
var output := ""
var mode := "burst"
var frame := 0
var capturing := false
func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
		if arg.begins_with("--mode="): mode = arg.trim_prefix("--mode=")
	if output == "":
		get_tree().quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output)
	get_window().mode = Window.MODE_WINDOWED
	get_window().size = Vector2i(1200,900)
	get_window().content_scale_size = Vector2i(1200,900)
	# Burst previews follow real game startup; account for shared material initialization.
	var main: Node = null
	if mode != "gallery":
		var startup := Time.get_ticks_usec()
		main = load("res://game/main.tscn").instantiate()
		add_child(main)
		print("CHOCOLATES_PREVIEW_STARTUP_MS ",(Time.get_ticks_usec()-startup)/1000.0)
	while not Prep.is_prepared("chocolates"):
		Prep.prepare_step("chocolates")
		await get_tree().process_frame
	if mode == "gallery":
		build_gallery()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(output+"/chocolates-gallery.png")
		print("CHOCOLATES_GALLERY_COMPLETE")
		get_tree().quit()
	else:
		await get_tree().create_timer(.8).timeout
		Wardrobe.profiles[Wardrobe.selected].effect = "chocolates"
		main.show_screen("customize")
		main.lucha.play_lock_effect("chocolates")
		RenderingServer.frame_post_draw.connect(capture)
		capturing = true

func build_gallery() -> void:
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("19252c")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = .45
	add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-22,-28,0)
	light.light_energy = .9
	add_child(light)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.15
	camera.position.z = 4
	add_child(camera)
	var names := ["Milk chocolate\nVanilla drizzle","Dark chocolate\nRaised ridges","White chocolate\nDark lattice","Milk chocolate\nCaramel spiral","Dark chocolate\nSea-salt flakes","White chocolate\nPistachio dome","Milk chocolate\nAlmond praline","Dark chocolate\nRaspberry sprinkles","White chocolate\nDrizzled heart","Milk chocolate\nScroll heart","Dark chocolate\nHazelnut cluster","White chocolate\nCrunch cluster"]
	for i in Effect.TYPES.size():
		var item: Node3D = Effect.scenes[Effect.TYPES[i]].instantiate()
		CelPass.celify(item)
		item.position = Vector3((i%4-1.5)*.67,(1-i/4)*.68+.10,0)
		item.rotation = Vector3(-.38,-.30,0)
		item.scale = Vector3.ONE*1.35
		add_child(item)
		var label := Label3D.new()
		label.text = names[i]
		label.position = Vector3(item.position.x,item.position.y-.31,.12)
		label.pixel_size = .0012
		label.font_size = 24
		label.outline_size = 4
		add_child(label)

func capture() -> void:
	if not capturing: return
	get_viewport().get_texture().get_image().save_png(output+"/%03d.png" % frame)
	frame += 1
	if frame >= 84:
		capturing = false
		print("CHOCOLATES_CAPTURE_COMPLETE")
		get_tree().quit()
