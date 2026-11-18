extends RefCounted
## Six cached atlas toy families, three colorways each.
const Treasure = preload("res://ui3d/treasure_effect.gd")
const COLORS = [Color("18b9c4"),Color("f34f8a"),Color("f3d735"),Color("f58029"),Color("733db8"),Color("2675c9")]
static var meshes: Array[ArrayMesh] = []

static func part(st: SurfaceTool, mesh: PrimitiveMesh, at: Vector3, size: Vector3, color: Color, basis := Basis.IDENTITY) -> void:
	var a := mesh.get_mesh_arrays()
	var vertices: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = a[Mesh.ARRAY_NORMAL]
	var indices: PackedInt32Array = a[Mesh.ARRAY_INDEX]
	var uv: Vector2 = AtlasPalette.swatch(color).uv
	for i in indices:
		st.set_normal((basis*(normals[i]/size)).normalized())
		st.set_uv(uv)
		st.add_vertex(at+basis*(vertices[i]*size))

static func ball(st: SurfaceTool, at: Vector3, size: Vector3, color: Color) -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 1
	sphere.height = 2
	sphere.radial_segments = 12
	sphere.rings = 6
	part(st,sphere,at,size,color)

static func tube(st: SurfaceTool, points: Array[Vector3], radius: float, color: Color) -> void:
	var vertices: Array[Vector3] = []
	var normals: Array[Vector3] = []
	for i in points.size():
		var axis := (points[mini(i+1,points.size()-1)]-points[maxi(0,i-1)]).normalized()
		var tangent := axis.cross(Vector3.FORWARD).normalized()
		if tangent.length_squared() < .1: tangent = axis.cross(Vector3.RIGHT).normalized()
		var other := axis.cross(tangent)
		for j in 6:
			var normal := tangent*cos(j*TAU/6)+other*sin(j*TAU/6)
			vertices.append(points[i]+normal*radius)
			normals.append(normal)
	var uv: Vector2 = AtlasPalette.swatch(color).uv
	for i in range(points.size()-1):
		for j in 6:
			var a := i*6+j
			var b := i*6+(j+1)%6
			for index in [a,a+6,b,b,a+6,b+6]:
				st.set_normal(normals[index])
				st.set_uv(uv)
				st.add_vertex(vertices[index])

static func ring(st: SurfaceTool, radius: float, width: float, at: Vector3, color: Color, basis := Basis.IDENTITY) -> void:
	var torus := TorusMesh.new()
	torus.inner_radius = radius-width
	torus.outer_radius = radius+width
	torus.rings = 20
	torus.ring_segments = 6
	part(st,torus,at,Vector3.ONE,color,basis)

static func toy_mesh(kind: int, variant: int) -> ArrayMesh:
	if meshes.is_empty(): meshes.resize(18)
	# BAKED_LOOKUP_BEGIN
	var baked := preload("res://ui3d/effect_mesh_cache.gd").get_mesh("dog_toys",kind*3+variant)
	if baked != null:
		meshes[kind*3+variant] = baked
		return baked
	# BAKED_LOOKUP_END
	if meshes[kind*3+variant] == null:
		meshes[kind*3+variant] = build(kind,variant)
	return meshes[kind*3+variant]

static func build(kind: int, variant: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var color: Color = COLORS[(variant*2+kind)%6]
	if kind == 0: # Open, interwoven rubber ball, not a solid sphere.
		for loop in 4:
			var points: Array[Vector3] = []
			var basis := Basis(Vector3.UP,loop*PI/4)
			for j in 33:
				var a := TAU*j/32
				points.append(basis*Vector3(.115*cos(a),.115*sin(a),.023*sin(a*3+loop)))
			tube(st,points,.021,COLORS[(variant*2+loop)%6])
	elif kind == 1: # Three rounded lobes and a visible dark opening.
		for j in 3:
			var radius := .105-j*.022
			ball(st,Vector3(0,-.085+j*.087,0),Vector3(radius,.072,radius),color)
		ring(st,.027,.009,Vector3(0,.151,0),color)
		ball(st,Vector3(0,.146,0),Vector3(.022,.003,.022),Color("492337"))
	elif kind == 2: # Three twisted strands and two wrapped knots.
		for strand in 3:
			var c: Color = COLORS[(variant*2+strand)%6] if strand != 2 else Color("b9eee2")
			var points: Array[Vector3] = []
			for j in 25:
				var a := j*.63+strand*TAU/3
				points.append(Vector3(.018*cos(a),lerpf(-.12,.12,j/24.0),.018*sin(a)))
			tube(st,points,.016,c)
			for end in [-1,1]:
				var knot: Array[Vector3] = []
				for j in 33:
					var a := j*TAU/32
					var twist := 3*a+strand*TAU/3
					knot.append(Vector3((.041+.019*cos(twist))*cos(a),end*.13+(.041+.019*cos(twist))*sin(a),.019*sin(twist)))
				tube(st,knot,.012,c)
	elif kind == 3:
		ball(st,Vector3.ZERO,Vector3(.115,.041,.043),color)
		for x in [-.12,.12]:
			for y in [-.033,.033]: ball(st,Vector3(x,y,0),Vector3(.057,.042,.05),color)
		for j in 7:
			ring(st,.044,.005,Vector3(-.09+j*.03,0,0),color.lightened(.16),Basis(Vector3.FORWARD,PI/2))
	elif kind == 4:
		ball(st,Vector3.ZERO,Vector3(.135,.016,.135),color)
		ring(st,.128,.013,Vector3.ZERO,color)
		ring(st,.095,.003,Vector3(0,.012,0),color.lightened(.2))
	else: # Lime-green tennis felt with a continuous curved ivory seam.
		ball(st,Vector3.ZERO,Vector3.ONE*.105,Color("8cdb30"))
		var seam: Array[Vector3] = []
		for j in 65:
			var a := j*TAU/64
			var latitude := .60*sin(2*a)
			seam.append(Vector3(cos(a)*cos(latitude),sin(latitude),sin(a)*cos(latitude))*.105)
		tube(st,seam,.0055,Color("fff3cb"))
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
	var root := Node3D.new()
	root.name = "DogToysBurst"
	root.set_meta("burst_profile",[lean,lift,rng.randf()])
	camera.add_child(root)
	for region in 3:
		var choices: Array[int] = []
		for kind in 6:
			for i in 5: choices.append(kind*3+i%3)
		for i in range(29,0,-1):
			var j := rng.randi_range(0,i)
			var swap := choices[i]
			choices[i] = choices[j]
			choices[j] = swap
		for i in 30:
			var kind: int = choices[i]/3
			var variant: int = choices[i]%3
			var flight := Treasure.TreasureFlight.new()
			flight.set_meta("coverage_region",region)
			flight.set_meta("toy",choices[i])
			flight.set_meta("size_class",i%3)
			root.add_child(flight)
			var visual := MeshInstance3D.new()
			visual.mesh = toy_mesh(kind,variant)
			visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			flight.add_child(visual)
			flight.position = Vector3(rng.randf_range(-.25,.25),.6,-5)
			flight.rotation = Vector3(rng.randf_range(-PI,PI),rng.randf_range(-PI,PI),rng.randf_range(-PI,PI))
			flight.scale = Vector3.ONE*rng.randf_range(.55+(i%3)*.10,.62+(i%3)*.10)
			var lane := region*5+i%5
			var layer: int = i/5
			flight.velocity = Vector3(lerpf(-2.7,2.7,(lane+rng.randf_range(.15,.85))/15.0)+lean,lerpf(.6,5.4,(layer+rng.randf_range(.15,.85))/6.0)*lift,rng.randf_range(-.2,.2))
			flight.spin = Vector3(rng.randf_range(-3,3),rng.randf_range(-3,3),rng.randf_range(-4,4))
			flight.delay = rng.randf_range(0,.3)
			flight.hide()
	root.get_tree().create_timer(3.2).timeout.connect(func():
		if is_instance_valid(root): root.queue_free())
	return root
