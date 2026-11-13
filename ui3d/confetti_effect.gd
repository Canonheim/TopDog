extends RefCounted
## Folded atlas paper and curled ribbons; fixed quotas before cosmetic jitter.
const COLORS := [Color("f4bd36"), Color("eb604a"), Color("e886cd"), Color("53bdab"), Color("689bdd"), Color("ac79d2")]
const QUOTA := [0,0,0,1,1,2,2,2,3,4]
static var meshes := {}

static func piece_mesh(shape: int, color: int) -> ArrayMesh:
	var key := shape*COLORS.size()+color
	if meshes.has(key):
		return meshes[key]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var uv: Vector2 = AtlasPalette.swatch(COLORS[color]).uv
	if shape in [1,2]:
		var points := 12 if shape == 1 else 10
		for i in points:
			var a := TAU*i/points + PI*.5
			var b := TAU*(i+1)/points + PI*.5
			var ra := .085 if shape == 1 else (.13 if i%2 == 0 else .058)
			var rb := .085 if shape == 1 else (.13 if (i+1)%2 == 0 else .058)
			_triangle(st,Vector3(0,0,.012),Vector3(cos(a)*ra,sin(a)*ra,0),Vector3(cos(b)*rb,sin(b)*rb,0),uv)
	else:
		var steps := 5 if shape == 0 else 20
		for i in steps:
			var t := float(i)/steps
			var u := float(i+1)/steps
			_triangle(st,_edge(shape,t,-1),_edge(shape,u,-1),_edge(shape,u,1),uv)
			_triangle(st,_edge(shape,t,-1),_edge(shape,u,1),_edge(shape,t,1),uv)
	var mesh := st.commit()
	var mat := StandardMaterial3D.new()
	mat.resource_name = "PALETTE"
	mat.albedo_texture = CelPass.ATLAS
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.roughness = 1.0
	mesh.surface_set_material(0,CelPass.material_for(mat,mesh))
	meshes[key] = mesh
	return mesh

static func _edge(shape: int,t: float,side: float) -> Vector3:
	if shape == 0:
		return Vector3((t-.5)*.21,side*.055,.05*sin(t*PI*1.3))
	if shape == 3:
		return Vector3(.12*sin(t*TAU)+side*.027*cos(t*TAU),(t-.5)*.72,.045*cos(t*TAU)+side*.027*sin(t*TAU))
	var angle := t*TAU*1.35
	return Vector3((.105+side*.025)*cos(angle),(t-.5)*.85,(.105+side*.025)*sin(angle))

static func _triangle(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,uv: Vector2) -> void:
	var normal := (b-a).cross(c-a).normalized()
	for back in [false,true]:
		for point in ([a,b,c] if back else [a,c,b]):
			st.set_uv(uv)
			st.set_normal(-normal if back else normal)
			st.add_vertex(point)

static func burst(camera: Node3D,big := false) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var lean := rng.randf_range(-.2,.2)
	var lift := rng.randf_range(.94,1.06)
	var spread := rng.randf_range(.94,1.06)
	var root := Node3D.new()
	root.name = "ConfettiBurst"
	root.set_meta("burst_profile",[lean,lift,spread,rng.randi()])
	camera.add_child(root)
	var per_region := 100 if big else 30
	for region in 3:
		var choices: Array = []
		for i in per_region:
			choices.append(QUOTA[i%10])
		for i in range(choices.size()-1,0,-1):
			var j := rng.randi_range(0,i)
			var temp: int = choices[i]
			choices[i] = choices[j]
			choices[j] = temp
		for i in per_region:
			var p := PaperFlight.new()
			p.mesh = piece_mesh(choices[i],(i+region*2)%COLORS.size())
			p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			p.set_meta("coverage_region",region)
			p.set_meta("shape",choices[i])
			p.set_meta("size_class",i%3)
			root.add_child(p)
			p.position = Vector3(rng.randf_range(-.25,.25),.4,-5)
			if big:
				p.position.x += -2.6 if i%2 == 0 else 2.6
				p.position.y = -.6
			p.rotation = Vector3(rng.randf_range(-.8,.8),rng.randf_range(-.8,.8),rng.randf_range(-PI,PI))
			p.base_size = rng.randf_range(.85,1.0)+(i%3)*.13
			p.scale = Vector3.ONE*p.base_size
			var lane := region*5+i%5
			var layer := (i/5)%6
			p.velocity = Vector3(lerpf(-3.8,3.8,(lane+rng.randf_range(.1,.9))/15)*spread+lean,lerpf(.8,6.5,(layer+rng.randf_range(.1,.9))/6)*lift,rng.randf_range(-.18,.18))
			if big:
				p.velocity.x -= p.position.x*.55
				p.velocity.y *= 1.18
			p.spin = Vector3(rng.randf_range(-2.5,2.5),rng.randf_range(-3,3),rng.randf_range(-4,4))
			p.phase = rng.randf_range(0,TAU)
			p.delay = rng.randf_range(0,.24)
			p.lifetime = 3.2 if big else 2.65
			p.hide()
	root.get_tree().create_timer(3.6 if big else 3.0).timeout.connect(root.queue_free)
	return root

class PaperFlight extends MeshInstance3D:
	var velocity := Vector3.ZERO
	var spin := Vector3.ZERO
	var delay := 0.0
	var age := 0.0
	var lifetime := 2.65
	var phase := 0.0
	var base_size := 1.0
	func _process(dt: float) -> void:
		if delay > 0:
			delay -= dt
			return
		show()
		age += dt
		velocity.y -= 3.1*dt
		velocity *= exp(-.58*dt)
		position += (velocity+Vector3(sin(age*7+phase)*.22,0,0))*dt
		rotate_object_local(Vector3.RIGHT,spin.x*dt)
		rotate_object_local(Vector3.UP,spin.y*dt)
		rotate_object_local(Vector3.BACK,spin.z*dt)
		scale = Vector3.ONE*base_size*clampf((lifetime-age)/.22,0,1)
		if age >= lifetime:
			queue_free()
