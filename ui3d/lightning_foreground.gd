extends CanvasLayer
## One shared, idle-disabled pass per gameplay camera. Geometry stays on its owner.
const EFFECT_LAYER := 1 << 19
const META := &"lightning_foreground"
var source: Camera3D
var view: SubViewport
var eye: Camera3D
var display: TextureRect
var active: Array[Node3D] = []

static func ensure(camera: Camera3D) -> CanvasLayer:
	var existing = camera.get_meta(META) if camera.has_meta(META) else null
	if is_instance_valid(existing): return existing
	var overlay = new()
	overlay.source = camera
	camera.add_child(overlay)
	camera.set_meta(META,overlay)
	return overlay

func _ready() -> void:
	name = "LightningForeground"
	layer = 3
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = 100
	source.cull_mask &= ~EFFECT_LAYER
	view = SubViewport.new()
	view.name = "StormViewport"
	view.world_3d = source.get_world_3d()
	view.transparent_bg = true
	view.handle_input_locally = false
	view.gui_disable_input = true
	view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	view.screen_space_aa = source.get_viewport().screen_space_aa
	view.msaa_3d = source.get_viewport().msaa_3d
	add_child(view)
	eye = Camera3D.new()
	eye.cull_mask = EFFECT_LAYER
	view.add_child(eye)
	eye.make_current()
	display = TextureRect.new()
	display.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	display.texture = view.get_texture()
	add_child(display)
	display.hide()
	_sync_camera()
	set_process(false)

func include_effect(effect: Node3D) -> void:
	if effect in active: return
	for child in effect.get_children():
		if child is GeometryInstance3D: child.layers = EFFECT_LAYER
	active.append(effect)
	effect.tree_exiting.connect(_remove_effect.bind(effect),CONNECT_ONE_SHOT)
	_sync_camera()
	display.show()
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	set_process(true)

func _remove_effect(effect: Node3D) -> void:
	active.erase(effect)
	if active.is_empty():
		display.hide()
		view.render_target_update_mode = SubViewport.UPDATE_DISABLED
		set_process(false)

func _process(_delta: float) -> void:
	_sync_camera()

func _sync_camera() -> void:
	var dimensions := Vector2i(source.get_viewport().get_visible_rect().size)
	dimensions = dimensions.max(Vector2i.ONE)
	if view.size != dimensions: view.size = dimensions
	eye.global_transform = source.global_transform
	eye.projection = source.projection
	eye.keep_aspect = source.keep_aspect
	eye.fov = source.fov
	eye.size = source.size
	eye.frustum_offset = source.frustum_offset
	eye.h_offset = source.h_offset
	eye.v_offset = source.v_offset
	eye.near = source.near
	eye.far = source.far
	eye.environment = source.environment
	eye.attributes = source.attributes
