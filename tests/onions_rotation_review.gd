extends Node
const OUT = "C:/Users/growi/Documents/ChatGPT/Top dog 2/onions-review/"
func _ready() -> void:
	var mode := "before"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): mode=arg.trim_prefix("--capture=")
	var world := Node3D.new()
	add_child(world)
	var env := WorldEnvironment.new()
	env.environment=Environment.new()
	env.environment.background_mode=Environment.BG_COLOR
	env.environment.background_color=Color("17273b")
	env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color=Color("c5d6ec")
	env.environment.ambient_light_energy=.65
	world.add_child(env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees=Vector3(-28,-25,0)
	light.light_energy=1.25
	world.add_child(light)
	var cam:=Camera3D.new()
	world.add_child(cam)
	cam.position=Vector3(0,0,6)
	cam.projection=Camera3D.PROJECTION_ORTHOGONAL
	cam.size=2.65
	cam.current=true
	CelPass.add_outline_pass(world)
	var models:Array[Node3D]=[]
	var types=preload("res://ui3d/onions_effect.gd").TYPES
	for i in types.size():
		var path: String = ("res://tests/onions_before/onion_" if mode=="before" else "res://kit/models/onion_")+types[i]+".glb"
		var model:Node3D=load(path).instantiate()
		world.add_child(model)
		CelPass.celify(model)
		model.position=Vector3(-1.20+(i%4)*.80,.86-(i/4)*.86,0)
		models.append(model)
		var label:=Label3D.new()
		label.text=["BULB","SLICE","DICE"][i/4]+" "+str(i%4+1)
		label.font_size=20
		label.pixel_size=.002
		label.position=model.position+Vector3(0,-.37,.15)
		world.add_child(label)
	await get_tree().process_frame
	for frame in 144:
		var t=float(frame)/144.0
		for model in models:model.rotation=Vector3(.32+.48*sin(t*TAU),t*TAU,.09*sin(t*TAU))
		await RenderingServer.frame_post_draw
		var pic=get_viewport().get_texture().get_image()
		pic.resize(1400,840)
		pic.save_png(OUT+mode+"_%03d.png"%frame)
		await get_tree().process_frame
	print("ONIONS ROTATION CAPTURE PASS: all 12 models, ",mode)
	get_tree().quit()
