extends Node
const Effect = preload("res://ui3d/salt_effect.gd")
var output := ""
var mode := "gallery"
var frame := 0
var capture := false
func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
		if arg.begins_with("--mode="): mode = arg.trim_prefix("--mode=")
	if output == "": get_tree().quit(2); return
	DirAccess.make_dir_recursive_absolute(output)
	get_window().size = Vector2i(1280,800)
	get_window().content_scale_size = Vector2i(1280,800)
	if mode == "gallery":
		gallery()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(output+"/salt-gallery.png")
		get_tree().quit()
	else:
		var original := Wardrobe.profiles.duplicate(true)
		var main = load("res://game/main.tscn").instantiate()
		add_child(main)
		Wardrobe.profiles[Wardrobe.selected].effect = "salt"
		main._start_practice()
		await get_tree().create_timer(1.2).timeout
		var climber: Climber = main.game.live_climbers()[0]
		main.game._rpc_freeze(climber.climber_id,climber.pose(),"made","locked",2.0,2.0,true)
		RenderingServer.frame_post_draw.connect(take_frame)
		capture = true
		await get_tree().create_timer(3.3).timeout
		Wardrobe.profiles = original
		print("SALT_ACTUAL_MATCH_CAPTURE ",frame)
		await main.quit_game()
func gallery() -> void:
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("172a35")
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color.WHITE
	world.environment.ambient_light_energy = .6
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-25,-20,0)
	add_child(light)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 1.8
	camera.position.z = 4
	add_child(camera)
	for i in 2:
		var model: Node3D = load("res://kit/models/salt_"+Effect.TYPES[i]+".glb").instantiate()
		add_child(model)
		CelPass.celify(model)
		model.position = Vector3((i-.5)*.85,.05,0)
		model.rotation = Vector3(.15,-.14,0)
		model.scale = Vector3.ONE*(1.7 if i==0 else 4.0)
		var label := Label3D.new()
		label.text = ["SHORT SHAKER","SALT GRAIN (enlarged)"][i]
		label.position = Vector3((i-.5)*.85,-.5,0)
		label.font_size = 30
		label.pixel_size = .0015
		add_child(label)
func take_frame() -> void:
	if not capture: return
	var image := get_viewport().get_texture().get_image()
	image.resize(960,600,Image.INTERPOLATE_LANCZOS)
	image.save_png(output+"/%03d.png"%frame)
	frame += 1
	if frame>=180: capture = false
