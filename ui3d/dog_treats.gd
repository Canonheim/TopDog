extends RefCounted
## Atlas-baked biscuit assortment; 84 small treats and only six large chews.
const Treasure := preload("res://ui3d/treasure_effect.gd")
const COLORS := [Color("d8a255"),Color("eed6a0"),Color("b95d42"),Color("87964e"),Color("805137")]
const TYPES := ["bone","cream_bone","filled_round","heart","biscuit","green_bite","filled_roll","large_bone","chew_stick"]
static var meshes: Array[ArrayMesh] = []

static func _face(st: SurfaceTool, points: Array, color: Color) -> void:
	var normal: Vector3 = (points[1]-points[0]).cross(points[2]-points[0]).normalized()
	var uv: Vector2 = AtlasPalette.swatch(color).uv
	for j in [2,1,0]:
		st.set_normal(normal)
		st.set_uv(uv)
		st.add_vertex(points[j])

static func _disc(st: SurfaceTool, at: Vector3, radius: float, color: Color, side := 1.0) -> void:
	for j in 8:
		var a := TAU*j/8
		var b := TAU*(j+1)/8
		var pts := [at,at+Vector3(cos(a)*radius,sin(a)*radius,0),at+Vector3(cos(b)*radius,sin(b)*radius,0)]
		if side < 0: pts.reverse()
		_face(st,pts,color)

static func treat_mesh(kind: int) -> ArrayMesh:
	while meshes.size() < TYPES.size(): meshes.append(_build(meshes.size()))
	return meshes[kind]

static func _build(kind: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var outline := PackedVector2Array()
	var color: Color = COLORS[[0,1,1,2,0,3,0,0,2][kind]]
	var depth := .034
	if kind in [0,1,7]:
		outline = PackedVector2Array([Vector2(-.15,0),Vector2(-.17,-.035),Vector2(-.16,-.068),Vector2(-.13,-.084),Vector2(-.10,-.075),Vector2(-.075,-.045),Vector2(.075,-.045),Vector2(.10,-.075),Vector2(.13,-.084),Vector2(.16,-.068),Vector2(.17,-.035),Vector2(.15,0),Vector2(.17,.035),Vector2(.16,.068),Vector2(.13,.084),Vector2(.10,.075),Vector2(.075,.045),Vector2(-.075,.045),Vector2(-.10,.075),Vector2(-.13,.084),Vector2(-.16,.068),Vector2(-.17,.035)])
		if kind == 7:
			for j in outline.size(): outline[j] *= 1.35
	elif kind == 3:
		outline = PackedVector2Array([Vector2(0,-.11),Vector2(.10,-.015),Vector2(.115,.05),Vector2(.075,.10),Vector2(.025,.10),Vector2(0,.07),Vector2(-.025,.10),Vector2(-.075,.10),Vector2(-.115,.05),Vector2(-.10,-.015)])
	elif kind in [4,8]:
		var x := .09 if kind == 4 else .035
		var y := .11 if kind == 4 else .25
		outline = PackedVector2Array([Vector2(-x+.02,-y),Vector2(x-.02,-y),Vector2(x,-y+.02),Vector2(x,y-.02),Vector2(x-.02,y),Vector2(-x+.02,y),Vector2(-x,y-.02),Vector2(-x,-y+.02)])
	else:
		for j in 12:
			var a := TAU*j/12
			outline.append(Vector2(cos(a)*.085,sin(a)*(.07 if kind==5 else .085)))
		depth = .065 if kind == 6 else .042
	var cap := PackedVector2Array()
	for v in outline: cap.append(v*.88)
	var indices := Geometry2D.triangulate_polygon(cap)
	for side in [-1.0,1.0]:
		for j in range(0,indices.size(),3):
			var pts: Array = []
			for k in 3:
				var v := cap[indices[j+k]]
				pts.append(Vector3(v.x,v.y,side*depth))
			if side < 0: pts.reverse()
			_face(st,pts,color)
		for j in outline.size():
			var k := (j+1)%outline.size()
			var a := Vector3(cap[j].x,cap[j].y,side*depth)
			var b := Vector3(outline[j].x,outline[j].y,side*(depth-.012))
			var c := Vector3(outline[k].x,outline[k].y,side*(depth-.012))
			var d := Vector3(cap[k].x,cap[k].y,side*depth)
			var pts := [a,b,c,d]
			if side < 0: pts.reverse()
			_face(st,[pts[0],pts[1],pts[2]],color.darkened(.12))
			_face(st,[pts[0],pts[2],pts[3]],color.darkened(.12))
	for j in outline.size():
		var k := (j+1)%outline.size()
		var a := Vector3(outline[j].x,outline[j].y,-depth+.012)
		var b := Vector3(outline[k].x,outline[k].y,-depth+.012)
		var c := Vector3(outline[k].x,outline[k].y,depth-.012)
		var d := Vector3(outline[j].x,outline[j].y,depth-.012)
		_face(st,[a,b,c],color.darkened(.24))
		_face(st,[a,c,d],color.darkened(.24))
	for side in [-1.0,1.0]:
		if kind in [2,6]:
			_disc(st,Vector3(0,0,side*(depth+.0005)),.044,COLORS[4],side)
		elif kind in [0,1,7,4]:
			for x in [-.05,0,.05]:
				_disc(st,Vector3(x,0,side*(depth+.0005)),.009,color.darkened(.40),side)
	var mesh := st.commit()
	var mat := StandardMaterial3D.new()
	mat.resource_name = "PALETTE"
	mat.albedo_texture = CelPass.ATLAS
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.roughness = 1
	mesh.surface_set_material(0,CelPass.material_for(mat,mesh))
	return mesh

static func burst(camera: Node3D) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var lean := rng.randf_range(-.2,.2)
	var lift := rng.randf_range(.94,1.06)
	var spread := rng.randf_range(.94,1.06)
	var root := Node3D.new()
	root.name = "DogTreatBurst"
	root.set_meta("burst_profile",[lean,lift,spread,rng.randf()])
	camera.add_child(root)
	# Each third receives four of every small type and one of each large type.
	for lane in 3:
		for serial in 30:
			var kind := serial/4 if serial < 28 else serial-21
			var large := kind >= 7
			var flight := Treasure.TreasureFlight.new()
			flight.set_meta("treat_type",TYPES[kind])
			flight.set_meta("coverage_lane",lane)
			flight.set_meta("large",large)
			root.add_child(flight)
			var visual := MeshInstance3D.new()
			visual.mesh = treat_mesh(kind)
			visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			flight.add_child(visual)
			flight.position = Vector3(rng.randf_range(-.25,.25),.6,-5)
			flight.rotation = Vector3(rng.randf_range(-PI,PI),rng.randf_range(-PI,PI),rng.randf_range(-PI,PI))
			flight.scale = Vector3.ONE * ((.66 if large else .49+(serial%4)*.065)+rng.randf_range(-.025,.025))
			var layer := (serial+lane*2)%6
			var vx := lerpf(-2.7,2.7,(lane+rng.randf_range(.05,.95))/3.0)
			var vy := lerpf(.6,5.4,(layer+rng.randf_range(.15,.85))/6.0)
			flight.velocity = Vector3(vx*spread+lean,vy*lift,rng.randf_range(-.22,.22))
			flight.spin = Vector3(rng.randf_range(-3,3),rng.randf_range(-3,3),rng.randf_range(-4,4))
			flight.delay = rng.randf_range(0,.3)
			flight.hide()
	root.get_tree().create_timer(3.2).timeout.connect(func():
		if is_instance_valid(root): root.queue_free())
	return root
