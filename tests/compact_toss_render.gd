extends Node
const OUT := "C:/Users/growi/Documents/ChatGPT/Top dog 2/common-effects-review/integration/compact-toss-previews/"
func _ready() -> void:
	var prep = load("res://ui3d/lock_effect_preparation.gd")
	var main = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().create_timer(.5).timeout
	main.show_screen("effect_capture")
	main.set_process(false)
	main.lucha.set_process(false)
	main.cam.position = Vector3(0,2.5,9.5)
	main.cam.look_at(Vector3(0,2,0))
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.position = Vector2(25,20)
	label.add_theme_font_size_override("font_size",32)
	label.add_theme_constant_override("outline_size",8)
	layer.add_child(label)
	DirAccess.make_dir_recursive_absolute(OUT)
	Engine.time_scale = .01
	for id in ["pickles","nuts_acorns","tea_time","coffee_break","autumn_harvest"]:
		while not prep.is_prepared(id):
			prep.prepare_step(id)
			await get_tree().process_frame
		var burst: Node3D = prep.burst(id,main.cam)
		for p in burst.get_children(): p.set_process(false)
		var elapsed := 0.0
		for target in [.05,.25,.75,1.25]:
			while elapsed<target-.0001:
				for p in burst.get_children(): p._process(.01)
				elapsed+=.01
			label.text = id.replace("_"," ").to_upper()+" / %.2f s" % target
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(OUT+id+"-%.2f.png" % target)
		burst.free()
	Engine.time_scale=1.0
	main.queue_free()
	await get_tree().process_frame
	print("COMPACT_TOSS_RENDER_COMPLETE")
	get_tree().quit()
