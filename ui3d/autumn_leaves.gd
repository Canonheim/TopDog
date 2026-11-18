extends RefCounted
## 72 atlas leaves, <=100 triangles each; no physics, shadows or live geometry work.
const COUNT := 72
const COLORS := [Color("e5b93b"),Color("da762b"),Color("ad4631"),Color("763843"),Color("94683d"),Color("7d8c46")]
const COLOR_QUOTA := [0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,3,3,3,4,4,4,5,5]
const SHAPES := ["Maple", "Oak", "Oval", "Serrated"]
static var meshes: Array[ArrayMesh] = []
static var prewarm_usec := 0
static var outlines: Array[PackedVector2Array] = []
static var triangulations: Array[PackedInt32Array] = []

## Public all-variant fallback; the shared scheduler calls prepare_variant instead.
static func prewarm() -> void:
	for index in 24: prepare_variant(index)

static func prepare_variant(index: int) -> void:
	if meshes.is_empty(): meshes.resize(24)
	if meshes[index] != null: return
	var started := Time.get_ticks_usec()
	var shape := index/6
	while outlines.size() <= shape:
		var next := outlines.size()
		outlines.append(_outline(next))
		triangulations.append(Geometry2D.triangulate_polygon(outlines[next]))
	meshes[index] = _build_mesh(shape,index%6)
	prewarm_usec += Time.get_ticks_usec()-started

static func _outline(shape: int) -> PackedVector2Array:
	var left: Array[Vector2] = []
	match shape:
		0:
			left = [Vector2(0,-.23),Vector2(-.10,-.18),Vector2(-.21,-.19),Vector2(-.17,-.07),Vector2(-.30,-.01),Vector2(-.25,.05),Vector2(-.30,.15),Vector2(-.17,.12),Vector2(-.19,.27),Vector2(-.10,.21),Vector2(-.08,.31),Vector2(0,.42)]
		1:
			left = [Vector2(0,-.25),Vector2(-.08,-.20),Vector2(-.12,-.16),Vector2(-.13,-.10),Vector2(-.065,-.055),Vector2(-.17,.005),Vector2(-.175,.065),Vector2(-.09,.10),Vector2(-.18,.17),Vector2(-.17,.23),Vector2(-.075,.245),Vector2(-.09,.32),Vector2(-.045,.38),Vector2(0,.40)]
		2:
			left = [Vector2(0,-.24),Vector2(-.10,-.16),Vector2(-.17,-.04),Vector2(-.18,.09),Vector2(-.145,.21),Vector2(-.08,.31),Vector2(0,.39)]
		3:
			left.append(Vector2(0,-.25))
			for i in range(1,12):
				var t := float(i)/12
				var w := sin(t*PI)*(.16 if i%2 == 1 else .125)
				left.append(Vector2(-w,lerpf(-.25,.40,t)))
			left.append(Vector2(0,.40))
	var points := PackedVector2Array(left)
	for i in range(left.size()-2,0,-1):
		points.append(Vector2(-left[i].x,left[i].y))
	return points

static func _point(p: Vector2,shape: int) -> Vector3:
	# A raised midrib, curled tip and lifted edges survive silhouettes without extra triangles.
	return Vector3(p.x,p.y,.045*absf(p.x)/.3+.045*p.y*p.y*4 + (0.012 if shape%2 == 0 else -.012)*p.x)

static func _triangle(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,uv: Vector2) -> void:
	var n := (b-a).cross(c-a).normalized()
	for point in [a,c,b]:
		st.set_normal(n)
		st.set_uv(uv)
		st.add_vertex(point)

static func _on_surface(p: Vector2,shape: int) -> Vector3:
	var points := outlines[shape]
	var indices := triangulations[shape]
	for i in range(0,indices.size(),3):
		var a := points[indices[i]]
		var b := points[indices[i+1]]
		var c := points[indices[i+2]]
		var denominator := (b-a).cross(c-a)
		var wb := (p-a).cross(c-a)/denominator
		var wc := (b-a).cross(p-a)/denominator
		var wa := 1.0-wb-wc
		if wa >= -.0001 and wb >= -.0001 and wc >= -.0001:
			return Vector3(p.x,p.y,_point(a,shape).z*wa+_point(b,shape).z*wb+_point(c,shape).z*wc)
	return _point(p,shape)

static func _ribbon(st: SurfaceTool,a: Vector2,b: Vector2,width: float,shape: int,uv: Vector2,back := false) -> void:
	var side := (b-a).orthogonal().normalized()*width*.5
	var offset := Vector3(0,0,-.0012 if back else .0012)
	var pa := _on_surface(a-side,shape)+offset
	var pb := _on_surface(a+side,shape)+offset
	var pc := _on_surface(b+side,shape)+offset
	var pd := _on_surface(b-side,shape)+offset
	if back:
		_triangle(st,pa,pb,pc,uv)
		_triangle(st,pa,pc,pd,uv)
	else:
		_triangle(st,pa,pc,pb,uv)
		_triangle(st,pa,pd,pc,uv)

static func _build_mesh(shape: int,color: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var base: Color = COLORS[color]
	var uv: Vector2 = AtlasPalette.swatch(base).uv
	var pale: Vector2 = AtlasPalette.swatch(base.lightened(.18)).uv
	var vein: Vector2 = AtlasPalette.swatch(base.darkened(.28)).uv
	var points := outlines[shape]
	var indices := triangulations[shape]
	for i in range(0,indices.size(),3):
		var a := _point(points[indices[i]],shape)
		var b := _point(points[indices[i+1]],shape)
		var c := _point(points[indices[i+2]],shape)
		_triangle(st,a,b,c,uv if (a.x+b.x+c.x)<0 else pale)
		_triangle(st,a,c,b,uv)
	# One two-sided stem and three midrib/branch ribbons on each face.
	for back in [false,true]:
		_ribbon(st,Vector2(.015,-.35),Vector2(0,-.22),.014,shape,vein,back)
		_ribbon(st,Vector2(0,-.23),Vector2(0,.32),.008,shape,vein,back)
		_ribbon(st,Vector2(0,-.04),Vector2(-.12,.16),.0045,shape,vein,back)
		_ribbon(st,Vector2(0,-.04),Vector2(.12,.16),.0045,shape,vein,back)
	var mesh := st.commit()
	mesh.surface_set_material(0,CelPass.one())
	mesh.set_meta("triangle_count",mesh.surface_get_array_len(0)/3)
	assert(int(mesh.get_meta("triangle_count")) <= 100)
	return mesh

static func burst(camera: Node3D) -> Node3D:
	prewarm()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var lean := rng.randf_range(-.25,.25)
	var spread := rng.randf_range(.94,1.06)
	var lift := rng.randf_range(.95,1.05)
	var root := Node3D.new()
	root.name = "AutumnLeavesBurst"
	root.set_meta("burst_profile",[lean,spread,lift])
	camera.add_child(root)
	for region in 3:
		# Reserve six of each shape and warm-dominant color quotas in each third.
		var colors: Array = COLOR_QUOTA.duplicate()
		for i in range(23,0,-1):
			var j := rng.randi_range(0,i)
			var swap: int = colors[i]
			colors[i] = colors[j]
			colors[j] = swap
		var order: Array[int] = []
		for i in 24:
			order.append((i%4)*6+int(colors[i]))
		for i in range(23,0,-1):
			var j := rng.randi_range(0,i)
			var swap := order[i]
			order[i] = order[j]
			order[j] = swap
		for i in 24:
			var leaf := LeafFlight.new()
			leaf.mesh = meshes[order[i]]
			leaf.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			leaf.set_meta("coverage_region",region)
			leaf.set_meta("shape",order[i]/6)
			leaf.set_meta("color",order[i]%6)
			leaf.set_meta("size_class",i%3)
			var lane := region*4+i%4
			leaf.set_meta("coverage_lane",lane)
			leaf.set_meta("height_layer",i/4)
			root.add_child(leaf)
			leaf.position = Vector3(rng.randf_range(-.24,.24),.35,-5)
			leaf.start_rotation = Vector3(rng.randf_range(-.5,.5),rng.randf_range(-.7,.7),rng.randf_range(-PI,PI))
			leaf.rotation = leaf.start_rotation
			leaf.base_size = rng.randf_range(.50,.57)+(i%3)*.12
			leaf.scale = Vector3.ONE*leaf.base_size
			leaf.velocity = Vector3(lerpf(-3.8,3.8,(lane+rng.randf_range(.12,.88))/12)*spread+lean,lerpf(.65,5.8,(i/4+rng.randf_range(.1,.9))/6)*lift,rng.randf_range(-.12,.12))
			leaf.spin = Vector3(rng.randf_range(-1.5,1.5),rng.randf_range(-1.8,1.8),rng.randf_range(-2.3,2.3))
			leaf.phase = rng.randf_range(0,TAU)
			leaf.flutter_rate = rng.randf_range(5.5,8.5)
			leaf.drift = rng.randf_range(.18,.34)
			leaf.delay = rng.randf_range(0,.20)
			leaf.hide()
	root.get_tree().create_timer(3.15).timeout.connect(func():
		if is_instance_valid(root):
			root.queue_free())
	return root

class LeafFlight extends MeshInstance3D:
	var velocity := Vector3.ZERO
	var spin := Vector3.ZERO
	var start_rotation := Vector3.ZERO
	var delay := 0.0
	var age := 0.0
	var phase := 0.0
	var flutter_rate := 7.0
	var drift := .25
	var base_size := 1.0
	func _process(dt: float) -> void:
		if delay > 0:
			delay -= dt
			return
		show()
		age += dt
		velocity.y -= 2.65*dt
		velocity *= exp(-.70*dt)
		position += (velocity+Vector3(sin(age*flutter_rate+phase)*drift,0,cos(age*4+phase)*.055))*dt
		var flutter := sin(age*flutter_rate+phase)*.30
		rotation = start_rotation+spin*age+Vector3(flutter,cos(age*flutter_rate*.7+phase)*.18,flutter*.15)
		scale = Vector3.ONE*base_size*clampf((2.9-age)/.23,0,1)
		if age >= 2.9:
			queue_free()
