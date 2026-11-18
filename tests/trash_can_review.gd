extends Node3D
func _ready() -> void:
	get_window().size = Vector2i(960,800)
	get_window().content_scale_size = Vector2i(960,800)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("182934")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = .55
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-30,-35,0)
	add_child(sun)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = .66
	cam.position.z = 3
	add_child(cam)
	var model: Node3D = load("res://kit/models/trash_can.glb").instantiate()
	add_child(model)
	CelPass.celify(model)
	model.rotation = Vector3(.28,-.4,0)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top dog 2/trash-preview/trash-can-steel.png")
	get_tree().quit()
