extends RefCounted
## Cached mathematical overlays. Fixed angles and analytic, straight trajectories.
const COUNT := 24
const VARIANTS := 12
const ATLAS = preload("res://kit/effects/math_atlas.png")
const SHADER = preload("res://shaders/math_overlay.gdshader")
static var meshes: Array[ArrayMesh] = []
static var shared_material: ShaderMaterial = preload("res://kit/effects/math_effect_material.tres")
static var prewarm_usec := 0

static func prewarm() -> void:
	for variant in VARIANTS: prepare_variant(variant)

static func prepare_variant(variant: int) -> void:
	if meshes.is_empty(): meshes.resize(VARIANTS)
	if meshes[variant] != null: return
	var started := Time.get_ticks_usec()
	if shared_material == null:
		shared_material = ShaderMaterial.new()
		shared_material.shader = SHADER
		shared_material.set_shader_parameter("glyph_atlas",ATLAS)
		shared_material.render_priority = 20
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var left := float(variant%4)/4.0
	var top := float(variant/4)/3.0
	var points := [Vector3(-.5,.25,0),Vector3(.5,.25,0),Vector3(.5,-.25,0),Vector3(-.5,-.25,0)]
	var uv := [Vector2(left,top),Vector2(left+.25,top),Vector2(left+.25,top+1.0/3),Vector2(left,top+1.0/3)]
	for i in [0,1,2,0,2,3]:
		st.set_uv(uv[i])
		st.set_normal(Vector3.BACK)
		st.add_vertex(points[i])
	var mesh := st.commit()
	mesh.surface_set_material(0,shared_material)
	meshes[variant] = mesh
	prewarm_usec += Time.get_ticks_usec()-started

static func burst(camera: Node3D, _big := false) -> Node3D:
	prewarm()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var root := Node3D.new()
	root.name = "MathBurst"
	root.set_meta("burst_profile",[rng.randi(),rng.randf()])
	camera.add_child(root)
	var depth := 5.0
	var half_height := 1.55
	if camera is Camera3D:
		half_height = camera.size*.5 if camera.projection == Camera3D.PROJECTION_ORTHOGONAL else tan(deg_to_rad(camera.fov)*.5)*depth
	var viewport_size := camera.get_viewport().get_visible_rect().size
	var half_width := half_height*viewport_size.x/maxf(viewport_size.y,1)
	# Three staggered cohorts, each with four crossing pairs. Pair intersections
	# are spread across the view instead of forcing every path through its center.
	var families := [0,1,4,5]
	for cohort in 3:
		for pair in 4:
			var target := Vector2((-.43 if pair%2 == 0 else .43)+rng.randf_range(-.16,.16),(.38 if pair/2 == 0 else -.38)+rng.randf_range(-.16,.16))
			var delay := cohort*.62+pair*.065+rng.randf_range(0,.035)
			var crossing_age := rng.randf_range(.62,.82)
			var turn := rng.randf_range(-.18,.18)
			for member in 2:
				var family: int = (families[pair]+member*2+cohort*2)%8
				var angle := family*TAU/8+turn+rng.randf_range(-.10,.10)
				var direction := Vector2(cos(angle),sin(angle))
				var speed := rng.randf_range(1.15,1.45)
				var variant := (cohort*4+pair)%6+member*6
				var piece := MathFlight.new()
				piece.mesh = meshes[variant]
				piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				piece.set_meta("cohort",cohort)
				piece.set_meta("pair",cohort*4+pair)
				piece.set_meta("direction_family",family)
				piece.set_meta("crossing_age",crossing_age)
				piece.set_meta("variant",variant)
				piece.set_meta("diagram",member == 1)
				piece.set_meta("size_class",pair)
				var z := depth+rng.randf_range(-.18,.18)
				var perspective_scale := z/depth if not (camera is Camera3D and camera.projection == Camera3D.PROJECTION_ORTHOGONAL) else 1.0
				var extent := Vector3(half_width,half_height,1)*Vector3(perspective_scale,perspective_scale,1)
				piece.velocity = Vector3(direction.x,direction.y,0)*speed*extent
				piece.origin = Vector3(target.x,target.y,-z)*extent-piece.velocity*crossing_age
				piece.position = piece.origin
				piece.rotation.z = deg_to_rad(rng.randf_range(-24,24))
				piece.scale = Vector3.ONE*half_width*(.41+pair*.02)*perspective_scale
				piece.delay = delay
				piece.set_instance_shader_parameter("opacity",0.0)
				piece.hide()
				root.add_child(piece)
	root.get_tree().create_timer(3.2).timeout.connect(root.queue_free)
	return root

class MathFlight extends MeshInstance3D:
	var origin := Vector3.ZERO
	var velocity := Vector3.ZERO
	var delay := 0.0
	var elapsed := 0.0
	const LIFETIME := 1.45
	func _process(delta: float) -> void:
		elapsed += delta
		var age := elapsed-delay
		if age < 0: return
		if age >= LIFETIME:
			queue_free()
			return
		show()
		# All motion is fixed at spawn. Orientation and scale never change.
		position = origin+velocity*age
		var opacity := minf(smoothstep(0,.16,age),1.0-smoothstep(LIFETIME-.24,LIFETIME,age))
		set_instance_shader_parameter("opacity",opacity*.94)
