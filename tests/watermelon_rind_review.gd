extends Node3D
const FX = preload("res://ui3d/watermelon_effect.gd")
const OUT = "C:/Users/growi/Documents/ChatGPT/Top dog 2/watermelon-rind-review/"
func picture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.resize(1200,675)
	image.save_png(OUT+filename)
func _ready() -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("17273b")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("c5d6ec")
	env.environment.ambient_light_energy = .65
	add_child(env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-28,-25,0)
	light.light_energy = 1.25
	add_child(light)
	var camera := Camera3D.new()
	add_child(camera)
	camera.position = Vector3(0,0,8)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.2
	camera.current = true
	CelPass.add_outline_pass(self)
	var gallery := Node3D.new()
	add_child(gallery)
	var assets: Array[Node3D] = []
	for row in 2:
		var kind: String = ["whole_round","whole_oval"][row]
		for column in 2:
			var path := "res://tests/watermelon_rind_before/"+kind+".glb" if column == 0 else "res://kit/models/watermelon_"+kind+".glb"
			var model: Node3D = load(path).instantiate()
			gallery.add_child(model)
			CelPass.celify(model)
			model.position = Vector3(-.68+column*1.36,.5-row*.92,0)
			model.scale = Vector3.ONE*1.7
			assets.append(model)
			var label := Label3D.new()
			label.text = ("BEFORE / " if column == 0 else "AFTER / ")+kind.replace("whole_", "").to_upper()
			label.font_size = 32
			label.pixel_size = .002
			label.position = model.position+Vector3(0,-.43,0)
			gallery.add_child(label)
	await get_tree().create_timer(.5).timeout
	for angle in 3:
		for model in assets: model.rotation = Vector3(.18+angle*.36,angle*.8,.08)
		await get_tree().process_frame
		await picture("closeup_%d.png" % angle)
	gallery.hide()
	# Measure the unchanged burst path for both sets of whole-melon assets.
	for version in ["before","after"]:
		FX.scenes.clear()
		if version == "before":
			for kind in ["whole_round","whole_oval"]:
				FX.scenes[kind] = load("res://tests/watermelon_rind_before/"+kind+".glb")
		var timings: Array = []
		for trial in 11:
			var t := Time.get_ticks_usec()
			var burst: Node3D = FX.burst(camera)
			timings.append((Time.get_ticks_usec()-t)/1000.0)
			if trial == 1:
				var triangles := 0
				var surfaces := 0
				var meshes := burst.find_children("*","MeshInstance3D",true,false)
				for mesh in meshes:
					surfaces += mesh.mesh.get_surface_count()
					for surface in mesh.mesh.get_surface_count():
						var array = mesh.mesh.surface_get_arrays(surface)
						triangles += (array[Mesh.ARRAY_INDEX].size() if array[Mesh.ARRAY_INDEX] != null and array[Mesh.ARRAY_INDEX].size()>0 else array[Mesh.ARRAY_VERTEX].size())/3
				print("GEOMETRY ",version," triangles=",triangles," meshes=",meshes.size()," surfaces=",surfaces)
			burst.free()
		print("TIMING ",version," spawn_ms=",timings)
	camera.queue_free()
	gallery.queue_free()
	light.queue_free()
	env.queue_free()
	await get_tree().process_frame
	var main = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().create_timer(.7).timeout
	main.practice_settings.practice_npc = false
	main._start_practice()
	await get_tree().create_timer(.7).timeout
	main.show_screen("effect_capture")
	main.set_process(false)
	main.game.set_physics_process(false)
	main.lucha.set_process(false)
	main._pad_corner.hide()
	main.lucha._hud.hide()
	for c in main.game.climbers.values():
		c.set_physics_process(false)
		for body in c.bodies.values(): body.freeze = true
	main.cam.position = Vector3(0,2.5,9.5)
	main.cam.look_at(Vector3(0,2,0))
	for version in ["before","after"]:
		FX.scenes.clear()
		if version == "before":
			for kind in ["whole_round","whole_oval"]: FX.scenes[kind] = load("res://tests/watermelon_rind_before/"+kind+".glb")
		var root: Node3D = FX.burst(main.cam)
		assert(root.get_child_count() == 90)
		var quota := [{},{},{}]
		for piece in root.get_children():
			var region: int = piece.get_meta("coverage_region")
			var shape: int = piece.get_meta("shape")
			quota[region][shape] = quota[region].get(shape,0)+1
		assert(quota[0] == quota[1] and quota[1] == quota[2])
		for frame in 72:
			await get_tree().process_frame
			await picture("%s_%03d.png" % [version,frame])
		await get_tree().create_timer(3.1).timeout
		assert(not is_instance_valid(root))
		print("RENDER ",version," quotas and cleanup PASS")
	print("WATERMELON RIND REVIEW COMPLETE")
	get_tree().quit()
