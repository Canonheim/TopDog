extends RefCounted
## Cupped rose petals, using the plaza poinsettia's exact red atlas texels.
const AtlasMap := preload("res://scripts/atlas_map.gd")
const TEXELS := [Vector2i(2022,15), Vector2i(2022,28), Vector2i(2022,45)]
const PETAL_COUNT := 72
const ROSE_COUNT := PETAL_COUNT / 4
const VARIANTS := 6
static var rose_meshes: Array[ArrayMesh] = []
static var meshes: Array[ArrayMesh] = []

static func petal_mesh(variant: int) -> ArrayMesh:
	while meshes.size() < VARIANTS:
		meshes.append(_build_petal(meshes.size()))
	return meshes[variant % VARIANTS]

static func _build_petal(variant: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# A tapered attachment, rounded shoulders, shallow notch and curled rim.
	var outline := [Vector2(.015,-.115),Vector2(-.065,-.075),Vector2(-.12,-.005),Vector2(-.125,.065),Vector2(-.09,.115),Vector2(-.035,.135),Vector2(.015,.128),Vector2(.055,.11),Vector2(.10,.085),Vector2(.12,.035),Vector2(.105,-.035),Vector2(.065,-.09)]
	var widths := [.75,1.0,1.18,.83,1.08,.92]
	var lengths := [1.22,.90,.82,1.10,1.05,.95]
	var curls := [.010,.025,.045,.065,.035,.055]
	for j in outline.size():
		var point: Vector2 = outline[j]
		outline[j] = Vector2(point.x * widths[variant] + sin(j * 1.9 + variant) * .012, point.y * lengths[variant])
	var center := Vector3(.012 * sin(variant),-.012,-curls[variant])
	for i in outline.size():
		var a: Vector2 = outline[i]
		var b: Vector2 = outline[(i+1)%outline.size()]
		var points := [center,Vector3(a.x,a.y,.012+absf(a.x)*(.12+variant*.035)),Vector3(b.x,b.y,.012+absf(b.x)*(.12+variant*.035))]
		var normal: Vector3 = (points[1]-points[0]).cross(points[2]-points[0]).normalized()
		var px: Vector2i = TEXELS[(variant + (1 if i < 3 else 0)) % 3]
		for back in [false,true]:
			for j in ([0,2,1] if back else [0,1,2]):
				st.set_uv(AtlasMap.pixel_uv(px.x,px.y))
				st.set_normal(normal if back else -normal)
				st.add_vertex(points[j])
	var mesh := st.commit()
	var mat := StandardMaterial3D.new()
	mat.resource_name = "PALETTE"
	mat.albedo_texture = CelPass.ATLAS
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.roughness = 1.0
	mesh.surface_set_material(0,CelPass.material_for(mat,mesh))
	return mesh

static func rose_mesh(variant := 0) -> ArrayMesh:
	while rose_meshes.size() < VARIANTS:
		rose_meshes.append(_build_rose(rose_meshes.size()))
	return rose_meshes[variant % VARIANTS]

static func _build_rose(variant: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Three overlapping, staggered whorls around a tight central bud.
	for tier in 3:
		var count := 7 - tier * 2 + variant % 2
		var radius: float = [.105,.058,.022][tier] * [.8,1.12,.9,1.0,1.18,.85][variant]
		var scale_factor: float = [.85,.62,.40][tier] * [.9,1.05,.85,1.1,.98,.9][variant]
		for j in count:
			var angle := TAU*j/count + tier*.62 + variant*.37
			var basis := Basis(Vector3.BACK,angle) * Basis(Vector3.RIGHT,.22+tier*.15+variant*.065)
			var at := Vector3(-sin(angle)*radius,cos(angle)*radius,.025+tier*.05)
			st.append_from(petal_mesh((j+tier+variant)%VARIANTS),0,Transform3D(basis.scaled(Vector3.ONE*scale_factor),at))
	# A slim stem with attached thorns; variants have zero, one or two leaves.
	var green := AtlasMap.pixel_uv(717,54)
	var stem_length := .32 + variant*.035
	var lean := (variant-2.5)*.018
	for j in 6:
		var a := TAU*j/6
		var b := TAU*(j+1)/6
		var p0 := Vector3(cos(a)*.012,-.05,sin(a)*.012-.025)
		var p1 := Vector3(cos(b)*.012,-.05,sin(b)*.012-.025)
		var p2 := p1+Vector3(lean,-stem_length,variant*.004)
		var p3 := p0+Vector3(lean,-stem_length,variant*.004)
		_add_face(st,[p0,p1,p2],green)
		_add_face(st,[p0,p2,p3],green)
	# Small hooked triangular thorns alternate along the stem, clear of the bloom.
	for j in 3 + variant % 2:
		var t := .24 + j*.19
		var side := -1.0 if (j+variant)%2 == 0 else 1.0
		var center := Vector3(lean*t,-.05-stem_length*t,-.025+variant*.004*t)
		var a := center+Vector3(side*.009,.014,-.009)
		var b := center+Vector3(side*.009,.014,.009)
		var c := center+Vector3(side*.009,-.018,0)
		var point := center+Vector3(side*(.043+variant*.002),-.022,.004)
		_add_face(st,[a,b,point],green)
		_add_face(st,[b,c,point],AtlasMap.pixel_uv(747,70))
		_add_face(st,[c,a,point],green)
	var leaf_sides: Array = [] if variant%3 == 0 else ([-1] if variant%3 == 1 else [-1,1])
	for side in leaf_sides:
		var base := Vector3(lean*.5,-stem_length*.55+side*.055,-.02)
		var tip := base+Vector3(side*(.10+variant*.012),.09+variant*.008,0)
		var mid := base+Vector3(side*.075,.055,.035)
		_add_face(st,[base,mid,tip],AtlasMap.pixel_uv(717,35))
		_add_face(st,[base,tip,base+Vector3(side*.085,.015,0)],green)
	var full_rose := st.commit()
	full_rose.surface_set_material(0,petal_mesh(0).surface_get_material(0))
	return full_rose

static func _add_face(st: SurfaceTool, points: Array, uv: Vector2) -> void:
	var normal: Vector3 = (points[1]-points[0]).cross(points[2]-points[0]).normalized()
	for back in [false,true]:
		for j in ([0,2,1] if back else [0,1,2]):
			st.set_uv(uv)
			st.set_normal(normal if back else -normal)
			st.add_vertex(points[j])

static func burst(camera: Node3D) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var lean := rng.randf_range(-0.30, 0.30)
	var lift := rng.randf_range(0.94, 1.06)
	var spread := rng.randf_range(0.90, 1.10)
	var origin := Vector3(rng.randf_range(-0.16, 0.16), rng.randf_range(-0.05, 0.05), 0)
	var root := Node3D.new()
	root.set_meta("burst_profile", [origin, lean, lift, spread])
	root.name = "RosePetalBurst"
	camera.add_child(root)
	# Every lane contains all six petal variants, two of each.
	for band in 6:
		for i in VARIANTS:
			var p := CPUParticles3D.new()
			p.name = "Petals%d" % i
			p.one_shot = true
			p.explosiveness = rng.randf_range(.80, .90)
			p.amount = 2
			p.set_meta("coverage_lane", band)
			p.set_meta("shape", i)
			p.lifetime = 2.8
			p.mesh = petal_mesh(i)
			var angle := deg_to_rad(-42.0 + band * 16.8 + rng.randf_range(-2.5,2.5))
			p.direction = Vector3(tan(angle) + lean,1,rng.randf_range(-.06,.06))
			p.spread = 20.0 * spread
			p.initial_velocity_min = 0.8 * lift
			p.initial_velocity_max = 5.4 * lift
			p.gravity = Vector3(0,-3.0,0)
			p.damping_min = .8
			p.damping_max = 1.5
			p.angular_velocity_min = -160 - i*12
			p.angular_velocity_max = 160 + i*12
			p.angle_max = 360
			p.scale_amount_min = .4
			p.scale_amount_max = .8
			p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			root.add_child(p)
			p.position = Vector3((band-2.5)*.075 + rng.randf_range(-.04,.04),.6,-5) + origin
			p.emitting = true
			p.finished.connect(p.queue_free)
	var variant_offset := rng.randi_range(0, VARIANTS-1)
	for i in ROSE_COUNT:
		var rose := RoseFlight.new()
		rose.name = "WholeRose%d" % i
		var lane := (i * 5) % 6
		var layer := i / 6
		# Adjacent lanes share a balanced mix of short, medium and long roses.
		rose.mesh = rose_mesh((layer * 2 + lane % 2 + variant_offset) % VARIANTS)
		rose.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(rose)
		rose.position = Vector3(rng.randf_range(-.2,.2),.6,-5) + origin
		rose.rotation = Vector3(rng.randf_range(-.8,.8),rng.randf_range(-.9,.9),rng.randf_range(-PI,PI))
		rose.scale = Vector3.ONE * rng.randf_range(.67,.73)
		var vx := lerpf(-2.8, 2.8, (lane + rng.randf_range(.2,.8)) / 6.0)
		var vy := lerpf(0.6, 5.4, (layer + rng.randf_range(.15,.85)) / 3.0)
		rose.velocity = Vector3(vx * spread + lean, vy * lift, rng.randf_range(-.45,.45))
		rose.set_meta("coverage_lane", lane)
		rose.spin = Vector3(rng.randf_range(-1.8,1.8),rng.randf_range(-2,2),rng.randf_range(-3.0,3.0))
		rose.delay = rng.randf_range(0,.3)
		rose.hide()
	# Finished signals may arrive in one frame, before queued children disappear.
	root.get_tree().create_timer(3.2).timeout.connect(func():
		if is_instance_valid(root):
			root.queue_free())
	return root


class RoseFlight extends MeshInstance3D:
	var velocity := Vector3.ZERO
	var spin := Vector3.ZERO
	var delay := 0.0
	var age := 0.0

	func _process(delta: float) -> void:
		if delay > 0:
			delay -= delta
			return
		show()
		age += delta
		velocity += Vector3(0,-3,0)*delta
		velocity *= exp(-.45*delta)
		position += velocity*delta
		rotate_object_local(Vector3.RIGHT,spin.x*delta)
		rotate_object_local(Vector3.UP,spin.y*delta)
		rotate_object_local(Vector3.BACK,spin.z*delta)
		if age >= 2.8:
			queue_free()
