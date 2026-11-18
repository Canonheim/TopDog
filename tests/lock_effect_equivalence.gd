extends Node
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
var prepared := false
var output := ""
var scripts := {}
var cameras := {}
var viewports := {}
var gpu_samples := {}
var prepare_max_ms := {}
var initial_states := {}
var flights: Array[Node] = []
var native_particles: Array[CPUParticles3D] = []
var frame := 0
var capturing := false
func _ready() -> void:
	# Native particle requests receive explicit simulation time below; freeze the
	# engine contribution so the renderer's first-frame delta cannot add a step.
	Engine.time_scale = 0.0
	get_window().mode = Window.MODE_WINDOWED
	get_window().size = Vector2i(1280,992)
	get_window().content_scale_size = Vector2i(1280,992)
	for arg in OS.get_cmdline_user_args():
		if arg == "--prepared": prepared = true
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
	if output == "":
		get_tree().quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output)
	var serial := 0
	for id in Prep.REGISTRY:
		var source := FileAccess.get_file_as_string("res://ui3d/"+Prep.REGISTRY[id][0]+".gd").replace("\r\n","\n")
		# Fixed cosmetic RNG only in isolated in-memory test scripts, never the game.
		source = source.replace("rng.randomize()","rng.seed = 730145")
		if not prepared:
			var first := source.find("\t# BAKED_LOOKUP_BEGIN")
			while first >= 0:
				var last := source.find("\t# BAKED_LOOKUP_END",first)+"\t# BAKED_LOOKUP_END\n".length()
				source = source.substr(0,first)+source.substr(last)
				first = source.find("\t# BAKED_LOOKUP_BEGIN")
			# Reconstruct the four original eager cache wrappers. Builders, motion,
			# quotas and all other source remain byte-for-byte unchanged.
			if id == "autumn_leaves":
				var start := source.find("## Public all-variant fallback")
				var end := source.find("static func _outline(",start)
				source = source.substr(0,start)+"## Called in UI setup before menus become interactive. Builds resources, never emits nodes.\nstatic func prewarm() -> void:\n\tif not meshes.is_empty():\n\t\treturn\n\tvar started := Time.get_ticks_usec()\n\tfor shape in 4:\n\t\toutlines.append(_outline(shape))\n\t\ttriangulations.append(Geometry2D.triangulate_polygon(outlines[shape]))\n\t\tfor color in 6:\n\t\t\tmeshes.append(_build_mesh(shape,color))\n\tprewarm_usec = Time.get_ticks_usec()-started\n\n"+source.substr(end)
			if id == "math":
				var start := source.find("static func prewarm()")
				var end := source.find("static func burst(",start)
				source = source.substr(0,start)+"static func prewarm() -> void:\n\tif not meshes.is_empty(): return\n\tvar started := Time.get_ticks_usec()\n\tshared_material = ShaderMaterial.new()\n\tshared_material.shader = SHADER\n\tshared_material.set_shader_parameter(\"glyph_atlas\",ATLAS)\n\tshared_material.render_priority = 20\n\tfor variant in VARIANTS:\n\t\tvar st := SurfaceTool.new()\n\t\tst.begin(Mesh.PRIMITIVE_TRIANGLES)\n\t\tvar left := float(variant%4)/4.0\n\t\tvar top := float(variant/4)/3.0\n\t\tvar points := [Vector3(-.5,.25,0),Vector3(.5,.25,0),Vector3(.5,-.25,0),Vector3(-.5,-.25,0)]\n\t\tvar uv := [Vector2(left,top),Vector2(left+.25,top),Vector2(left+.25,top+1.0/3),Vector2(left,top+1.0/3)]\n\t\tfor i in [0,1,2,0,2,3]:\n\t\t\tst.set_uv(uv[i])\n\t\t\tst.set_normal(Vector3.BACK)\n\t\t\tst.add_vertex(points[i])\n\t\tvar mesh := st.commit()\n\t\tmesh.surface_set_material(0,shared_material)\n\t\tmeshes.append(mesh)\n\tprewarm_usec = Time.get_ticks_usec()-started\n\n"+source.substr(end)
			if id == "dog_toys":
				source = source.replace("if meshes.is_empty(): meshes.resize(18)\n\tif meshes[kind*3+variant] == null:\n\t\tmeshes[kind*3+variant] = build(kind,variant)","if meshes.is_empty():\n\t\tfor k in 6:\n\t\t\tfor v in 3: meshes.append(build(k,v))")
			if id == "treats":
				source = source.replace("if meshes.is_empty(): meshes.resize(TYPES.size())\n\tif meshes[kind] == null: meshes[kind] = _build(kind)","while meshes.size() < TYPES.size(): meshes.append(_build(meshes.size()))")
			if id == "roses":
				for pair in [["meshes","_build_petal"],["rose_meshes","_build_rose"]]:
					var cache: String = pair[0]
					var build: String = pair[1]
					source = source.replace("if %s.is_empty(): %s.resize(VARIANTS)\n\tvariant %%= VARIANTS\n\tif %s[variant] == null: %s[variant] = %s(variant)" % [cache,cache,cache,cache,build],"while %s.size() < VARIANTS:\n\t\t%s.append(%s(%s.size()))" % [cache,cache,build,cache])
		var script := GDScript.new()
		script.source_code = source
		if script.reload() != OK:
			push_error("Equivalence clone failed: " + id)
			get_tree().quit(2)
			return
		scripts[id] = script
		var viewport := SubViewport.new()
		viewport.size = Vector2i(320,220)
		viewport.own_world_3d = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(viewport)
		viewports[id] = viewport
		gpu_samples[id] = []
		if ClassDB.class_has_method("RenderingServer","viewport_set_measure_render_time"):
			RenderingServer.call("viewport_set_measure_render_time",viewport.get_viewport_rid(),true)
		var camera := Camera3D.new()
		camera.fov = 48
		viewport.add_child(camera)
		cameras[id] = camera
		var environment := WorldEnvironment.new()
		environment.environment = Environment.new()
		environment.environment.background_mode = Environment.BG_COLOR
		environment.environment.background_color = Color("172c38")
		environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		environment.environment.ambient_light_color = Color.WHITE
		environment.environment.ambient_light_energy = .65
		viewport.add_child(environment)
		var light := DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-35,-25,0)
		viewport.add_child(light)
		var display := TextureRect.new()
		display.texture = viewport.get_texture()
		display.position = Vector2((serial%4)*320,(serial/4)*248+28)
		display.size = Vector2(320,220)
		add_child(display)
		var label := Label.new()
		label.text = id
		label.position = Vector2((serial%4)*320+10,(serial/4)*248+3)
		add_child(label)
		serial += 1
	if prepared:
		for id in scripts:
			var script = scripts[id]
			var adapter: String = Prep.REGISTRY[id][1]
			for index in Prep.REGISTRY[id][2]:
				var start := Time.get_ticks_usec()
				if adapter.begins_with("scene:"):
					var key := Prep.scene_key(id,index)
					while not Prep.prepare_scene(script,key,"res://kit/models/"+adapter.trim_prefix("scene:")+key+".glb"):
						await get_tree().process_frame
				else:
					match adapter:
						"confetti": script.piece_mesh(index/6,index%6)
						"baked:roses":
							if index < 6: script.petal_mesh(index)
							else: script.rose_mesh(index-6)
						"baked:bills": script.bill_mesh(index/3,index%3)
						"treats": script.treat_mesh(index)
						"baked:dog_toys": script.toy_mesh(index/3,index%3)
						"autumn_leaves": script.prepare_variant(index)
						"math": script.prepare_variant(index)
						"prewarm": script.prewarm()
				prepare_max_ms[id] = maxf(float(prepare_max_ms.get(id,0)),(Time.get_ticks_usec()-start)/1000.0)
				await get_tree().process_frame
	await get_tree().process_frame
	for id in scripts:
		var burst: Node = scripts[id].burst(cameras[id])
		fix_particle_seeds(burst)
		collect_flights(burst)
	RenderingServer.frame_post_draw.connect(capture)
	capturing = true

func collect_flights(node: Node) -> void:
	if node.get_script() != null and node.has_method("_process"):
		node.set_process(false)
		flights.append(node)
	for child in node.get_children(): collect_flights(child)

func _process(_delta: float) -> void:
	if not capturing: return
	for flight in flights:
		if is_instance_valid(flight): flight.call("_process",1.0/24.0)
	for particle in native_particles:
		if is_instance_valid(particle): particle.request_particles_process(1.0/24.0)

func fix_particle_seeds(node: Node) -> void:
	if node is CPUParticles3D:
		var properties := {}
		for property in node.get_property_list(): properties[property.name] = true
		if properties.has("use_fixed_seed"):
			node.set("use_fixed_seed",true)
			node.set("seed",730145+node.get_index())
			node.restart()
		if properties.has("fixed_fps"): node.set("fixed_fps",24)
		if properties.has("fract_delta"): node.set("fract_delta",false)
		node.set_process_internal(false)
		native_particles.append(node)
	for child in node.get_children(): fix_particle_seeds(child)

func capture() -> void:
	if not capturing: return
	if frame == 18:
		for id in cameras:
			var children: Array = cameras[id].get_children()
			if not children.is_empty() and children[0].get_child_count() > 0:
				var piece: Node3D = children[0].get_child(0)
				initial_states[id] = [piece.position.x,piece.position.y,piece.position.z,piece.rotation.x,piece.rotation.y,piece.rotation.z]
	if ClassDB.class_has_method("RenderingServer","viewport_get_measured_render_time_gpu"):
		for id in viewports:
			gpu_samples[id].append(RenderingServer.call("viewport_get_measured_render_time_gpu",viewports[id].get_viewport_rid()))
	get_viewport().get_texture().get_image().save_png(output+"/%03d.png" % frame)
	frame += 1
	if frame >= 80:
		capturing = false
		var file := FileAccess.open(output+"/render_metrics.json",FileAccess.WRITE)
		file.store_string(JSON.stringify({"prepared":prepared,"frame18_transforms":initial_states,"gpu_ms_per_subviewport":gpu_samples,"preparation_wall_ms_including_loader_waits":prepare_max_ms},"\t"))
		file.close()
		print("EQUIVALENCE_CAPTURE_COMPLETE prepared=",prepared)
		get_tree().quit()
