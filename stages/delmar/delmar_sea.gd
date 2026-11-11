class_name DelMarSea
extends Node
## DEL MAR'S WATER (Parker 11-10: "golemhiem has splashes and sounds for the water we can
## use"): Golemheim's living water on the Environment Maker's sea. Its surface shader
## (sea_surface.gdshader: depth tint, the foam-circle top, shore foam rings round the
## pier's piles and the beach, ripple rings, the clean waterline, the ink replayed) goes
## on the scenery's Sea mesh; this node keeps the ripple ledger and throws the splashes
## (Golemheim's toon-smoke blobs, stages/delmar/fx) with its splash sounds.
##
## Purely visual: nothing here touches the game's rules (the sea line is Stage.WATER_Y).

const SURFACE := preload("res://stages/delmar/sea_surface.gdshader")
const SMOKE_SHADER := preload("res://stages/delmar/fx/toon_smoke.gdshader")
const OUTLINE_SHADER := preload("res://stages/delmar/fx/toon_smoke_outline.gdshader")
const MAX_RIPPLES := 12  # lockstep with the shader's ripples[12]
const RIPPLE_LIFE := 0.8  # s a ring takes to expand out and fade
# Golemheim's ocean day colours (water.gd DAY_WATER_*): the alphas are murk depths.
const SHALLOW := Color(0.27, 0.72, 0.83, 0.45)
const DEEP := Color(0.11, 0.44, 0.74, 0.85)
const SPLASH_TINT := Color(0.82, 0.93, 1.0, 0.85)
const SPLASH_BLOB_SCALE := Vector2(1.2, 2.2)

static var _noise_tex: NoiseTexture2D = null
static var _blob: SphereMesh = null

var water_y := -1.8
var _mat: ShaderMaterial = null
var _ripples: Array[Vector4] = []  # x, z (world), size, progress 0..1
var _ink_tries := 0


## Dress the scenery's sea mesh in the living surface.
func dress(sea: MeshInstance3D, p_water_y: float) -> void:
	water_y = p_water_y
	if sea == null:
		return
	_mat = ShaderMaterial.new()
	_mat.shader = SURFACE
	if _noise_tex == null:
		var fn := FastNoiseLite.new()
		fn.seed = 7  # fixed: the sea shimmers the same on every machine
		_noise_tex = NoiseTexture2D.new()
		_noise_tex.noise = fn
		_noise_tex.seamless = true
	_mat.set_shader_parameter("noise_tex", _noise_tex)
	# One flat sheet out to the horizon: no rim to tuck the swell under, and the
	# scenery's big triangles carry no swell (the fragment look is the water).
	_mat.set_shader_parameter("half_size", Vector2(100000.0, 100000.0))
	_mat.set_shader_parameter("wave_height", 0.0)
	_mat.set_shader_parameter("shallow_color", SHALLOW)
	_mat.set_shader_parameter("deep_color", DEEP)
	_mat.set_shader_parameter("murk_min", 0.55)  # the pier's piles drown a little under the surface
	_mat.set_shader_parameter("murk_max", 0.97)  # open sea: reads blue, never the sky under it
	_mat.set_shader_parameter("foam_tile_m", 14.0)
	_mat.set_shader_parameter("foam_strength", 0.9)
	_mat.set_shader_parameter("foam_edge_m", 1.6)
	_mat.set_shader_parameter("ink_depth_fade", 1.5)
	sea.material_override = _mat
	sea.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_bind_ink()


## The outline pass's ink ledger, so lines crossing open water are repainted on it
## (the compositor stamps them before transparents draw). Retried until it exists.
func _bind_ink() -> void:
	if _mat == null:
		return
	var ink := CelPass.ink_texture()
	var rd := RenderingServer.get_rendering_device()
	if ink == null or rd == null or not rd.texture_is_valid(ink.texture_rd_rid):
		_mat.set_shader_parameter("ink_on_water", 0.0)
		_ink_tries += 1
		if _ink_tries < 120 and is_inside_tree():
			get_tree().process_frame.connect(_bind_ink, CONNECT_ONE_SHOT)
		return
	_mat.set_shader_parameter("outline_ink", ink)
	var fx = CelPass._outline_fx
	var line_color = fx.get("line_color") if fx != null else null
	if line_color is Color:
		_mat.set_shader_parameter("outline_ink_color", line_color)
	_mat.set_shader_parameter("ink_on_water", 1.0)


func _ready() -> void:
	if _mat != null and float(_mat.get_shader_parameter("ink_on_water")) < 0.5:
		_ink_tries = 0
		_bind_ink()


## One ring stamped into the surface at the world point (size 1 = a body falling in).
func ripple(at: Vector3, size_scale: float) -> void:
	if _ripples.size() >= MAX_RIPPLES:
		_ripples.pop_front()
	_ripples.append(Vector4(at.x, at.z, size_scale, 0.0))


func _process(delta: float) -> void:
	if _ripples.is_empty() or _mat == null:
		return
	var alive: Array[Vector4] = []
	var packed: Array = []
	for r in _ripples:
		r.w += delta / RIPPLE_LIFE
		if r.w < 1.0:
			alive.append(r)
			packed.append(Vector4(r.x, r.y, r.w * 1.3 * r.z, r.w))
	_ripples = alive
	_mat.set_shader_parameter("ripple_count", packed.size())
	while packed.size() < MAX_RIPPLES:
		packed.append(Vector4.ZERO)
	_mat.set_shader_parameter("ripples", PackedVector4Array(packed))


## A body hits the water at x (size 1 = a climber falling in): Golemheim's splash, a
## fan of pale blobs thrown up and pulled back down, two rings, and the splash sound.
func splash(x: float, size_scale: float, z := 0.0) -> void:
	var at := Vector3(x, water_y + 0.02, z)
	_puff(at, int(clampf(10.0 + size_scale * 14.0, 10.0, 34.0)), 0.55, Vector2(1.6, 3.2) * size_scale, 0.12 + 0.18 * size_scale)
	ripple(at, size_scale * 1.2)
	ripple(at + Vector3(0.3, 0, 0), size_scale * 0.7)
	Sound.play_at("splash" if size_scale >= 0.7 else "splash_small", at, 0.0, self)


func _puff(at: Vector3, count: int, life: float, speed: Vector2, radius: float) -> void:
	var p := GPUParticles3D.new()
	p.add_to_group("splash_fx")
	p.one_shot = true
	p.emitting = false
	p.amount = maxi(count, 1)
	p.lifetime = life
	p.explosiveness = 1.0
	p.local_coords = false
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3.UP
	pm.spread = 55.0
	pm.initial_velocity_min = speed.x
	pm.initial_velocity_max = speed.y
	pm.gravity = Vector3(0.0, -9.8, 0.0)
	pm.damping_min = 0.8
	pm.damping_max = 1.6
	pm.scale_min = SPLASH_BLOB_SCALE.x
	pm.scale_max = SPLASH_BLOB_SCALE.y
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = radius
	# Golemheim's blob rules: a random angle (the shader's per-blob noise seed) and the
	# swell curve (born small, full at a third of its life, gone by the end).
	pm.angle_min = -180.0
	pm.angle_max = 180.0
	var c := Curve.new()
	c.add_point(Vector2(0.0, 0.0))
	c.add_point(Vector2(0.333, 1.0))
	c.add_point(Vector2(1.0, 0.02))
	var ct := CurveTexture.new()
	ct.curve = c
	pm.scale_curve = ct
	p.process_material = pm
	p.draw_pass_1 = _blob_mesh()
	add_child(p)
	p.global_position = at
	p.emitting = true
	get_tree().create_timer(life + 0.6).timeout.connect(p.queue_free)


static func _blob_mesh() -> SphereMesh:
	if _blob != null:
		return _blob
	var m := ShaderMaterial.new()
	m.shader = SMOKE_SHADER
	m.set_shader_parameter("smoke_color", SPLASH_TINT)
	m.set_shader_parameter("highlight_color", SPLASH_TINT.lightened(0.55))
	m.set_shader_parameter("shadow_color", SPLASH_TINT.darkened(0.55))
	m.set_shader_parameter("displacementStrength", 0.1)
	m.set_shader_parameter("displacementSpeed", 0.1)
	m.set_shader_parameter("noiseDensity", 8.0)
	var o := ShaderMaterial.new()
	o.shader = OUTLINE_SHADER
	o.set_shader_parameter("outline_color", Color(0, 0, 0, 1))
	o.set_shader_parameter("outline_width", 2.0)
	o.set_shader_parameter("displacementStrength", 0.1)
	o.set_shader_parameter("displacementSpeed", 0.1)
	o.set_shader_parameter("noiseDensity", 8.0)
	m.next_pass = o
	_blob = SphereMesh.new()
	_blob.radius = 0.1
	_blob.height = 0.2
	_blob.radial_segments = 40
	_blob.rings = 20
	_blob.material = m
	return _blob
