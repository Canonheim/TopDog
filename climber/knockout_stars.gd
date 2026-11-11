extends Node3D
## A world-upright carousel, parented to the head for automatic lifetime cleanup.
const AtlasMap := preload("res://scripts/atlas_map.gd")
const COUNT := 6
const TRANSITION := 0.3
const MAX_SCALE := 0.85
var elapsed := 0.0
var duration := 1.6
var remaining := -1.0
var phase := 0.0
var size := 1.0
var stars: Array[MeshInstance3D] = []

func setup(body_scale: float) -> void:
	size = body_scale
	top_level = true
	var material := StandardMaterial3D.new()
	material.resource_name = "PALETTE"
	material.albedo_texture = CelPass.ATLAS
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.roughness = 1.0
	var mesh := _star_mesh()
	mesh.surface_set_material(0, material)
	for i in COUNT:
		var star := MeshInstance3D.new()
		star.mesh = mesh
		star.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		star.scale = Vector3.ONE * size
		add_child(star)
		stars.append(star)
	CelPass.celify(self)
	show_active(false)

func show_active(active: bool, lifetime := 1.6) -> void:
	if active and not visible:
		phase = 0.0
		elapsed = 0.0
		duration = lifetime
		remaining = -1.0
	visible = active
	set_process(active)
	if active:
		_process(0.0)

func set_remaining(seconds_left: float) -> void:
	remaining = seconds_left
	_update_scale()

func _update_scale() -> void:
	var left := maxf(0.0, remaining if remaining >= 0 else duration - elapsed)
	var age := maxf(0.0, duration - left)
	var factor := minf(smoothstep(0.0, TRANSITION, age), smoothstep(0.0, TRANSITION, left))
	for star in stars:
		star.visible = factor > 0.0
		# Keep the transform invertible even at the invisible endpoints.
		star.scale = Vector3.ONE * size * MAX_SCALE * maxf(factor, .0001)

func _process(delta: float) -> void:
	elapsed += delta
	_update_scale()
	phase = fmod(phase + delta * 2.8, TAU)
	global_transform = Transform3D(Basis.IDENTITY, (get_parent() as Node3D).global_position + Vector3.UP * .38 * size)
	for i in stars.size():
		var angle := phase + TAU * i / COUNT
		stars[i].position = Vector3(cos(angle) * .34, sin(angle * 2.0) * .025, sin(angle) * .23) * size
		stars[i].rotation = Vector3(0, .25 * sin(angle), .20 * sin(phase * 1.5 + i))

static func _star_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var face_uv := AtlasMap.uv("cheese_gold")
	var edge_uv := AtlasMap.uv("gold_dark")
	var rim: Array[Vector2] = []
	for i in 10:
		var angle := PI * .5 + TAU * i / 10
		var radius := .105 if i % 2 == 0 else .047
		rim.append(Vector2(cos(angle), sin(angle)) * radius)
	for i in 10:
		var a := rim[i]
		var b := rim[(i + 1) % 10]
		# Godot's clockwise front faces, both caps and the bevel-free edge.
		for z in [-.018, .018]:
			var tri := [Vector3(0, 0, z), Vector3(a.x, a.y, z), Vector3(b.x, b.y, z)]
			if z > 0:
				tri.reverse()
			for p in tri:
				st.set_uv(face_uv)
				st.set_normal(Vector3.BACK if z > 0 else Vector3.FORWARD)
				st.add_vertex(p)
		var edge_normal := Vector3(b.y-a.y, a.x-b.x, 0).normalized()
		for p in [Vector3(b.x,b.y,.018), Vector3(b.x,b.y,-.018), Vector3(a.x,a.y,-.018), Vector3(a.x,a.y,.018), Vector3(b.x,b.y,.018), Vector3(a.x,a.y,-.018)]:
			st.set_uv(edge_uv)
			st.set_normal(edge_normal)
			st.add_vertex(p)
	return st.commit()
