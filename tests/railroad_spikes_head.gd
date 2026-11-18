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
	camera.size = .5
	camera.position.z = 4
	add_child(camera)
	Effect.prepare()
	for i in 1:
		var model := MeshInstance3D.new()
		model.mesh = Effect.mesh
		model.position = Vector3(-.03,-.025,0)
		model.rotation = Vector3(-.12,.18,0)
		model.scale = Vector3.ONE*2.0
		model.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(model)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(output)
	print("RAILROAD_GALLERY_COMPLETE")
	get_tree().quit()
