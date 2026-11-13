extends Node
const Pickup := preload("res://game/cosmetic_pinata.gd")
func _ready():
	var main = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().create_timer(.7).timeout
	main.practice_settings.practice_npc = false
	main._start_practice()
	await get_tree().create_timer(.5).timeout
	main.show_screen("effect_capture")
	main.set_process(false)
	main.game.set_physics_process(false)
	main.lucha.set_process(false)
	main._pad_corner.hide()
	for c: Climber in main.game.climbers.values():
		c.set_physics_process(false)
		for body: RigidBody3D in c.bodies.values(): body.freeze = true
	if is_instance_valid(main.game.stage.base_root): main.game.stage.base_root.hide()
	if is_instance_valid(main.game.chair): main.game.chair.hide()
	main.cam.position = Vector3(0,2.7,6.4)
	main.cam.look_at(Vector3(0,2.0,0))
	main.cam.fov = 43
	var item := Pickup.new()
	main.world.add_child(item)
	item.position = Vector3(0,2,0)
	var collected := [false]
	item.collected.connect(func(_body): collected[0]=true)
	for i in 144:
		if i == 54:
			var chair := RigidBody3D.new()
			chair.collision_layer = Climber.LAYER_PROP
			chair.collision_mask = 0
			chair.gravity_scale = 0
			chair.continuous_cd = true
			var shape := CollisionShape3D.new()
			shape.shape = BoxShape3D.new()
			shape.shape.size = Vector3(.45,.7,.18)
			chair.add_child(shape)
			var model = load("res://kit/models/folding_chair.glb").instantiate()
			chair.add_child(model)
			model.scale = Vector3.ONE*.7
			model.position.y = -.35
			CelPass.celify(model)
			main.world.add_child(chair)
			chair.position = Vector3(-3.4,2,0)
			chair.rotation.z = -.4
			chair.linear_velocity = Vector3(5,0,0)
			chair.angular_velocity = Vector3(0,0,-2)
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		img.resize(960,504,Image.INTERPOLATE_LANCZOS)
		img.save_png("C:/Users/growi/Documents/ChatGPT/Top dog 2/kit/pinata-gif/frame%03d.png" % i)
		await get_tree().process_frame
	assert(collected[0],"Thrown chair must actually collect the pinata")
	print("PINATA PREVIEW: actual chair contact collected successfully")
	main.game.end_match()
	get_tree().quit()
