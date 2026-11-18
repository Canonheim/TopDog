extends Node3D
const Effect = preload("res://ui3d/railroad_spikes_effect.gd")
func _ready() -> void:
	var output := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
	if output.is_empty(): get_tree().quit(2); return
	get_window().mode = Window.MODE_WINDOWED
	get_window().size = Vector2i(1200,800)
	get_window().content_scale_size = Vector2i(1200,800)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("19252c")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = .4
	add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-25,-35,0)
	add_child(light)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 1.55
	camera.position.z = 4
	add_child(camera)
	Effect.prepare()
	for i in 3:
		var model := MeshInstance3D.new()
		model.mesh = Effect.mesh
		model.position = Vector3((i-1)*.73,.08,0)
		model.rotation = Vector3(-.45,[.48,1.4,2.4][i],-.3)
		model.scale = Vector3.ONE*1.65
		model.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(model)
		var label := Label3D.new()
		label.text = ["FORGED HEAD","SQUARE SHANK","CHISEL POINT"][i]
		label.position = Vector3(model.position.x,-.39,0)
		label.pixel_size = .001
		label.font_size = 27
		add_child(label)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(output)
	print("RAILROAD_GALLERY_COMPLETE")
	get_tree().quit()
