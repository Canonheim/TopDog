extends CompositorEffect
## Adaptive ink: depth/crease detection, connected-stroke cleanup,
## density and analytical coverage. Same PRE-transparent water ledger contract.

var rd: RenderingDevice
var shaders: Array[RID] = []
var pipelines: Array[RID] = []
var sampler: RID
var linear_sampler: RID
var line_width := 3.5
var line_color := Color.BLACK
var density_strength := 1.0
var temporal_strength := 0.0
var speck_min_span := 4.0 # connected seed span in pixels; 0 disables, maximum 4
var _history := {}
var _final_tex: RID
var _final_old: RID
var _final_size := Vector2i.ZERO
var _tex2rd: Texture2DRD

func ink_texture() -> Texture2DRD:
	if _tex2rd == null: _tex2rd = Texture2DRD.new()
	return _tex2rd

func _publish_ink() -> void:
	ink_texture().texture_rd_rid = _final_tex
	if _final_old.is_valid():
		var old := _final_old
		_final_old = RID()
		RenderingServer.call_on_render_thread(func() -> void: rd.free_rid(old))

func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_PRE_TRANSPARENT
	access_resolved_color = true
	access_resolved_depth = true
	needs_normal_roughness = true
	needs_motion_vectors = true
	var w = ProjectSettings.get_setting("shader_globals/outline_width", {})
	if w is Dictionary and w.has("value"): line_width = float(w.value)
	var c = ProjectSettings.get_setting("shader_globals/outline_color", {})
	if c is Dictionary and c.get("value") is Color: line_color = c.value
	rd = RenderingServer.get_rendering_device()
	if rd == null:
		enabled = false
		return
	RenderingServer.call_on_render_thread(_init_compute)

func _init_compute() -> void:
	for name in ["outline_edges", "outline_clean", "outline_downsample", "outline_density", "outline_expand", "outline_resolve"]:
		var file: RDShaderFile = load("res://shaders/cel/%s.glsl" % name)
		if file == null:
			enabled = false
			return
		var spirv := file.get_spirv()
		if not spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_COMPUTE).is_empty():
			push_error(spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_COMPUTE))
			enabled = false
			return
		var shader := rd.shader_create_from_spirv(spirv)
		if not shader.is_valid(): return
		shaders.append(shader)
		pipelines.append(rd.compute_pipeline_create(shader))
	var ss := RDSamplerState.new()
	ss.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	ss.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	ss.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	ss.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler = rd.sampler_create(ss)
	ss.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	ss.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	linear_sampler = rd.sampler_create(ss)

func _image(tex: RID) -> RDUniform:
	var u := RDUniform.new()
	u.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u.binding = 0
	u.add_id(tex)
	return u

func _sample(tex: RID, linear := false) -> RDUniform:
	var u := RDUniform.new()
	u.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	u.binding = 0
	u.add_id(linear_sampler if linear else sampler)
	u.add_id(tex)
	return u

func _dispatch(cl: int, index: int, uniforms: Array, pc: PackedFloat32Array, size: Vector2i) -> void:
	rd.compute_list_bind_compute_pipeline(cl,pipelines[index])
	for set_index in uniforms.size():
		var uset := UniformSetCacheRD.get_cache(shaders[index],set_index,[uniforms[set_index]])
		rd.compute_list_bind_uniform_set(cl,uset,set_index)
	rd.compute_list_set_push_constant(cl,pc.to_byte_array(),pc.size()*4)
	rd.compute_list_dispatch(cl,ceili(float(size.x)/8),ceili(float(size.y)/8),1)

func _render_callback(_type: int, render_data: RenderData) -> void:
	if rd == null or pipelines.size() != 6: return
	var buffers: RenderSceneBuffersRD = render_data.get_render_scene_buffers()
	if buffers == null: return
	var size := buffers.get_internal_size()
	if size.x == 0 or size.y == 0: return
	if not buffers.has_texture(&"forward_clustered",&"normal_roughness"): return
	var scene: RenderSceneDataRD = render_data.get_render_scene_data()
	if _final_size != size or not _final_tex.is_valid():
		if _final_old.is_valid(): rd.free_rid(_final_old)
		_final_old = _final_tex
		var fmt := RDTextureFormat.new()
		fmt.format = RenderingDevice.DATA_FORMAT_R8_UNORM
		fmt.width = size.x
		fmt.height = size.y
		fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
		_final_tex = rd.texture_create(fmt,RDTextureView.new(),[])
		_final_size = size
		call_deferred("_publish_ink")
	var usage := RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	var small := Vector2i(ceili(float(size.x)/4),ceili(float(size.y)/4))
	for view in buffers.get_view_count():
		var color := buffers.get_color_layer(view)
		var depth := buffers.get_depth_layer(view)
		var nr := buffers.get_texture_slice(&"forward_clustered",&"normal_roughness",view,0,1,1)
		var raw_edges := buffers.create_texture(&"adaptive_ink",StringName("raw_edges_%d" % view),RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT,usage,RenderingDevice.TEXTURE_SAMPLES_1,size,1,1,true,true)
		var edges := buffers.create_texture(&"adaptive_ink",StringName("edges_%d" % view),RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT,usage,RenderingDevice.TEXTURE_SAMPLES_1,size,1,1,true,true)
		var density := buffers.create_texture(&"adaptive_ink",StringName("density_%d" % view),RenderingDevice.DATA_FORMAT_R16_SFLOAT,usage,RenderingDevice.TEXTURE_SAMPLES_1,small,1,1,true,true)
		var raw_density := buffers.create_texture(&"adaptive_ink",StringName("raw_density_%d" % view),RenderingDevice.DATA_FORMAT_R16_SFLOAT,usage,RenderingDevice.TEXTURE_SAMPLES_1,small,1,1,true,true)
		var coverage := buffers.create_texture(&"adaptive_ink",StringName("coverage_%d" % view),RenderingDevice.DATA_FORMAT_R16_SFLOAT,usage,RenderingDevice.TEXTURE_SAMPLES_1,size,1,1,true,true)
		var history_a := buffers.create_texture(&"adaptive_ink",StringName("history_a_%d" % view),RenderingDevice.DATA_FORMAT_R32G32_SFLOAT,usage,RenderingDevice.TEXTURE_SAMPLES_1,size,1,1,true,false)
		var history_b := buffers.create_texture(&"adaptive_ink",StringName("history_b_%d" % view),RenderingDevice.DATA_FORMAT_R32G32_SFLOAT,usage,RenderingDevice.TEXTURE_SAMPLES_1,size,1,1,true,false)
		var key := "%s_%d" % [buffers.get_render_target().get_id(),view]
		var camera := scene.get_cam_transform()
		var projection := scene.get_view_projection(view)
		var valid := _history.has(key)
		var turn := 0
		if valid:
			var h: Dictionary = _history[key]
			valid = h.size == size and h.texture == history_a and h.projection == projection
			valid = valid and camera.origin.distance_to(h.camera.origin) < 1.0
			valid = valid and camera.basis.z.dot(h.camera.basis.z) > 0.95
			valid = valid and Time.get_ticks_msec()-h.time < 250
			turn = h.turn
		var history_read: RID = history_a if turn == 0 else history_b
		var history_write: RID = history_b if turn == 0 else history_a
		# The spatial profile does not request a motion pass. Its resolve
		# never reads velocity; bind depth as an inert sampler in that slot.
		var velocity := buffers.get_velocity_layer(view) if needs_motion_vectors else depth
		var width_px := line_width * float(size.y)/1080.0
		var pc := PackedFloat32Array([float(size.x),float(size.y),width_px,density_strength,line_color.r,line_color.g,line_color.b,line_color.a])
		var pc_a := pc.duplicate()
		var inv := scene.get_view_projection(view).inverse()
		for i in 4:
			var col: Vector4 = inv[i]
			pc_a.append_array(PackedFloat32Array([col.x,col.y,col.z,col.w]))
		var cl := rd.compute_list_begin()
		_dispatch(cl,0,[_image(raw_edges),_sample(depth),_sample(nr)],pc_a,size)
		rd.compute_list_add_barrier(cl)
		var pc_clean := pc.duplicate()
		pc_clean[3] = speck_min_span
		_dispatch(cl,1,[_image(edges),_sample(raw_edges)],pc_clean,size)
		rd.compute_list_add_barrier(cl)
		_dispatch(cl,2,[_image(raw_density),_sample(edges)],pc,small)
		rd.compute_list_add_barrier(cl)
		_dispatch(cl,3,[_image(density),_sample(raw_density)],pc,small)
		rd.compute_list_add_barrier(cl)
		_dispatch(cl,4,[_image(coverage),_sample(edges),_sample(density,true)],pc,size)
		rd.compute_list_add_barrier(cl)
		var pc_resolve := pc.duplicate()
		pc_resolve.append_array(PackedFloat32Array([1.0 if valid else 0.0,temporal_strength,0.0,0.0]))
		_dispatch(cl,5,[_image(color),_sample(coverage),_image(_final_tex),_sample(depth),_sample(velocity),_sample(history_read),_image(history_write)],pc_resolve,size)
		rd.compute_list_end()
		_history[key] = {"size":size,"texture":history_a,"turn":1-turn,"camera":camera,"projection":projection,"time":Time.get_ticks_msec()}

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and rd != null:
		for shader in shaders:
			if shader.is_valid(): rd.free_rid(shader)
		for rid in [sampler,linear_sampler,_final_tex,_final_old]:
			if rid.is_valid(): rd.free_rid(rid)
