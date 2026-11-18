extends RefCounted
## Immutable atlas meshes; one incremental preparation unit per variant.
const COUNT := 72
const TYPES := ["Whole dill", "Whole curved", "Whole gherkin", "Crinkle chip", "Oval chip", "Thick chip", "Dill spear", "Curved spear", "Olive spear"]
const QUOTA := [0,0,1,1,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,7,7,8,8]
static var meshes: Array[ArrayMesh] = []
static var preparation_usec := 0

static func prepare_unit(index: int) -> void:
	if index == 0:
		AtlasPalette.swatch(Color("56712c"))
		CelPass.one()
	else: prepare_variant(index-1)

static func prepare_variant(index: int) -> void:
	if meshes.is_empty(): meshes.resize(9)
	if meshes[index] != null: return
	var started := Time.get_ticks_usec()
	meshes[index] = _build_mesh(index)
	preparation_usec += Time.get_ticks_usec()-started

static func prewarm() -> void:
	for index in 9: prepare_variant(index)

static func _tri(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,uv: Vector2) -> void:
	var normal := (b-a).cross(c-a).normalized()
	for p in [a,c,b]:
		st.set_normal(normal)
		st.set_uv(uv)
		st.add_vertex(p)

static func _quad(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,d: Vector3,uv: Vector2) -> void:
	_tri(st,a,b,c,uv)
	_tri(st,a,c,d,uv)

static func _radius(t: float) -> float:
	return .095*sqrt(maxf(.006,1.0-pow(absf(t),4)))

static func _whole_point(t: float,a: float,variant: int) -> Vector3:
	var r := _radius(t)*(1.0+.025*sin(a*3+t*7))
	var length: float = [.32,.35,.26][variant]
	var bend: float = [.012,.045,-.018][variant]*(1-t*t)
	return Vector3(bend+r*cos(a),t*length,r*sin(a))

static func _whole(st: SurfaceTool,v: int,skin: Vector2,light: Vector2,scar: Vector2) -> void:
	var rows := [-1.0,-.92,-.72,-.36,0.0,.36,.72,.92,1.0]
	for j in range(rows.size()-1):
		for i in 12:
			var a := TAU*i/12
			var b := TAU*(i+1)/12
			_quad(st,_whole_point(rows[j],a,v),_whole_point(rows[j+1],a,v),_whole_point(rows[j+1],b,v),_whole_point(rows[j],b,v),skin)
	for side in [-1.0,1.0]:
		var center := _whole_point(side,0,v)
		center.x = 0
		center.z = 0
		for i in 12:
			var a := _whole_point(side,TAU*i/12,v)
			var b := _whole_point(side,TAU*(i+1)/12,v)
			_tri(st,center,a,b,scar) if side<0 else _tri(st,center,b,a,scar)
	# Broad tiny raised skin bumps, distributed deterministically, not spikes.
	for i in 18:
		var t := -.74+(i%6)*.285
		var a := TAU*(i/6)/3+.39*(i%3)+v*.3
		var center := _whole_point(t,a,v)
		var normal := Vector3(cos(a),0,sin(a))
		var tangent := Vector3(-sin(a),0,cos(a))*.014
		var vertical := Vector3.UP*.018
		var tip := center+normal*.009
		var rim := [center+tangent,center+vertical,center-tangent,center-vertical]
		for j in 4: _tri(st,rim[(j+1)%4],rim[j],tip,light if i%4==0 else skin)

static func _chip_point(radius: float,a: float,side: float,v: int) -> Vector3:
	var r := radius*(1.0+.035*cos(a*12))
	var x := r*cos(a)
	var y := r*sin(a)*(1.18 if v==1 else 1.0)
	var depth := .039 if v==2 else .026
	return Vector3(x,y,side*depth+.003*cos(x*125+v*.6))

static func _chip(st: SurfaceTool,v: int,skin: Vector2,flesh: Vector2,pale: Vector2,seed: Vector2) -> void:
	var radii := [.046,.126,.148]
	for side in [-1.0,1.0]:
		for i in 24:
			var a := TAU*i/24
			var b := TAU*(i+1)/24
			var center := _chip_point(0,0,side,v)
			var p := _chip_point(radii[0],a,side,v)
			var q := _chip_point(radii[0],b,side,v)
			_tri(st,center,p,q,pale) if side>0 else _tri(st,center,q,p,pale)
			for j in 2:
				var pa := _chip_point(radii[j],a,side,v)
				var pb := _chip_point(radii[j+1],a,side,v)
				var pc := _chip_point(radii[j+1],b,side,v)
				var pd := _chip_point(radii[j],b,side,v)
				var tint := skin if j==1 else flesh
				_quad(st,pa,pb,pc,pd,tint) if side>0 else _quad(st,pd,pc,pb,pa,tint)
		# Six pale seeds along the radial seed core; almost flush to the cut face.
		for i in 6:
			var a := TAU*i/6+v*.15
			var center := _chip_point(.067,a,side,v)+Vector3(0,0,side*.008)
			var axis := Vector3(cos(a),sin(a),0)*.017
			var across := Vector3(-sin(a),cos(a),0)*.006
			_quad(st,center-axis,center+across,center+axis,center-across,seed) if side<0 else _quad(st,center-across,center+axis,center+across,center-axis,seed)
	for i in 24:
		var a := TAU*i/24
		var b := TAU*(i+1)/24
		_quad(st,_chip_point(.148,a,-1,v),_chip_point(.148,b,-1,v),_chip_point(.148,b,1,v),_chip_point(.148,a,1,v),skin)

static func _spear_point(t: float,a: float,v: int) -> Vector3:
	var r := _radius(t)
	return Vector3(r*sin(a)+.025*(v-1)*(1-t*t),t*(.32+v*.015),-r*cos(a))

static func _spear(st: SurfaceTool,v: int,skin: Vector2,flesh: Vector2,pale: Vector2,seed: Vector2) -> void:
	var rows := [-1.0,-.86,-.5,0.0,.5,.86,1.0]
	for j in range(rows.size()-1):
		for i in 6:
			var a := lerpf(-1.1,1.1,i/6.0)
			var b := lerpf(-1.1,1.1,(i+1)/6.0)
			_quad(st,_spear_point(rows[j+1],a,v),_spear_point(rows[j+1],b,v),_spear_point(rows[j],b,v),_spear_point(rows[j],a,v),skin)
		for side in [-1.0,1.0]:
			var a := _spear_point(rows[j],side*1.1,v)
			var b := _spear_point(rows[j+1],side*1.1,v)
			var c := Vector3(.025*(v-1)*(1-rows[j+1]*rows[j+1]),b.y,.008)
			var d := Vector3(.025*(v-1)*(1-rows[j]*rows[j]),a.y,.008)
			_quad(st,a,b,c,d,flesh) if side>0 else _quad(st,d,c,b,a,flesh)
	for side in [-1.0,1.0]:
		for i in 6:
			var t := -.65+i*.26
			var edge := _spear_point(t,side*1.1,v)
			var ridge := Vector3(.025*(v-1)*(1-t*t),edge.y,.008)
			var center := ridge.lerp(edge,.37)+Vector3(0,0,.002)
			var axis := Vector3.UP*.020
			var across := Vector3(.005,0,side*-.003)
			_quad(st,center-axis,center+across,center+axis,center-across,seed)
	for end in [-1.0,1.0]:
		var ridge := Vector3(0,end*(.32+v*.015),.008)
		for i in 6:
			var a := _spear_point(end,lerpf(-1.1,1.1,i/6.0),v)
			var b := _spear_point(end,lerpf(-1.1,1.1,(i+1)/6.0),v)
			_tri(st,ridge,b,a,pale) if end>0 else _tri(st,ridge,a,b,pale)

static func _build_mesh(index: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var v := index%3
	var skin: Vector2 = AtlasPalette.swatch([Color("56712c"),Color("6f7c30"),Color("637e37")][v]).uv
	var light: Vector2 = AtlasPalette.swatch(Color("879348")).uv
	var flesh: Vector2 = AtlasPalette.swatch([Color("becd73"),Color("c5ce7e"),Color("afb963")][v]).uv
	var pale: Vector2 = AtlasPalette.swatch(Color("d2d68c")).uv
	var seed: Vector2 = AtlasPalette.swatch(Color("e8dfa0")).uv
	var scar: Vector2 = AtlasPalette.swatch(Color("72723c")).uv
	match index/3:
		0: _whole(st,v,skin,light,scar)
		1: _chip(st,v,skin,flesh,pale,seed)
		2: _spear(st,v,skin,flesh,pale,seed)
	var mesh := st.commit()
	mesh.surface_set_material(0,CelPass.one())
	return mesh

static func burst(camera: Node3D,big := false) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var lean := rng.randf_range(-.2,.2)
	var lift := rng.randf_range(.94,1.06)
	var spread := rng.randf_range(.94,1.06)
	var root := Node3D.new()
	root.name = "PicklesBurst"
	root.set_meta("burst_profile",[lean,lift,spread,rng.randi()])
	camera.add_child(root)
	var per_region := 24
	for region in 3:
		var choices: Array = []
		for i in per_region:
			choices.append(QUOTA[i])
		for i in range(choices.size()-1,0,-1):
			var j := rng.randi_range(0,i)
			var temp: int = choices[i]
			choices[i] = choices[j]
			choices[j] = temp
		for i in per_region:
			var p := PickleFlight.new()
			prepare_variant(choices[i])
			p.mesh = meshes[choices[i]]
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
			p.base_size = rng.randf_range(.68,.78)+(i%3)*.11
			p.scale = Vector3.ONE*p.base_size
			var lane := region*4+i%4
			var layer := i/4
			p.set_meta("coverage_lane",lane)
			p.set_meta("height_layer",layer)
			p.velocity = Vector3(lerpf(-3.8,3.8,(lane+rng.randf_range(.1,.9))/12)*spread+lean,lerpf(.8,6.5,(layer+rng.randf_range(.1,.9))/6)*lift,rng.randf_range(-.18,.18))
			if big:
				p.velocity.x -= p.position.x*.55
				p.velocity.y *= 1.18
			p.spin = Vector3(rng.randf_range(-5,5),rng.randf_range(-5,5),rng.randf_range(-6,6))
			p.phase = rng.randf_range(0,TAU)
			p.delay = rng.randf_range(0,.24)
			p.lifetime = 3.2 if big else 2.65
			p.hide()
	root.get_tree().create_timer(3.6 if big else 3.0).timeout.connect(root.queue_free)
	return root

class PickleFlight extends MeshInstance3D:
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
		position += velocity*dt
		rotate_object_local(Vector3.RIGHT,spin.x*dt)
		rotate_object_local(Vector3.UP,spin.y*dt)
		rotate_object_local(Vector3.BACK,spin.z*dt)
		scale = Vector3.ONE*base_size*clampf((lifetime-age)/.22,0,1)
		if age >= lifetime:
			queue_free()

