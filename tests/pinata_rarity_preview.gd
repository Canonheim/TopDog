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
	main.cam.position = Vector3(0,4.1,12.5)
	main.cam.look_at(Vector3(0,3.8,0))
	main.cam.fov = 43
	for tier in 5:
		var item := Pickup.new()
		item.rarity = tier
		main.world.add_child(item)
		item.position = Vector3((tier-2)*2.3,3.8,0)
		var label := Label3D.new()
		label.text = ["WHITE", "GREEN", "BLUE", "PURPLE", "RED"][tier]
		label.font_size = 64
		label.pixel_size = .006
		label.outline_size = 10
		label.position = item.position + Vector3(0,-1.5,0)
		main.world.add_child(label)
	for i in 144:
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		img.resize(1440,756,Image.INTERPOLATE_LANCZOS)
		img.save_png("C:/Users/growi/Documents/ChatGPT/Top dog 2/kit/pinata-rarity-gif/frame%03d.png" % i)
		await get_tree().process_frame
	print("PINATA RARITY PREVIEW completed")
	main.game.end_match()
	get_tree().quit()
