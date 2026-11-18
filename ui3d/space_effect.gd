extends RefCounted
## Immutable atlas meshes; one incremental preparation unit per variant.
const COUNT := 72
const TYPES := ["Ruby rocket", "Scarlet rocket", "Crimson rocket", "Gold star", "Ice star", "Rose star", "Ocean planet", "Ringed planet", "Violet planet", "Copper planet", "Ice planet", "Lava planet", "Jade planet", "Crater moon"]
static var meshes: Array[ArrayMesh] = []
static var preparation_usec := 0

static func prepare_unit(index: int) -> void:
	if index == 0:
		AtlasPalette.swatch(Color("d72c3b"))
		CelPass.one()
	else: prepare_variant(index-1)

static func prepare_variant(index: int) -> void:
	if meshes.is_empty(): meshes.resize(14)
	if meshes[index] != null: return
	var started := Time.get_ticks_usec()
	meshes[index] = _build_mesh(index)
	preparation_usec += Time.get_ticks_usec()-started

static func prewarm() -> void:
	for index in 14: prepare_variant(index)

static func _tri(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,uv: Vector2) -> void:
	var normal := (b-a).cross(c-a).normalized()
	for p in [a,c,b]:
		st.set_normal(normal)
		st.set_uv(uv)
		st.add_vertex(p)

static func _quad(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,d: Vector3,uv: Vector2) -> void:
	_tri(st,a,b,c,uv)
	_tri(st,a,c,d,uv)

static func _uv(hex: String) -> Vector2:
	return AtlasPalette.swatch(Color(hex)).uv

static func _lathe(st: SurfaceTool,profile: Array,uv: Vector2,sides := 12) -> void:
	for row in range(profile.size()-1):
		for i in sides:
			var a := TAU*i/sides
			var b := TAU*(i+1)/sides
			var p: Vector2 = profile[row]
			var q: Vector2 = profile[row+1]
			var pa := Vector3(p.x*cos(a),p.y,p.x*sin(a))
			var pb := Vector3(q.x*cos(a),q.y,q.x*sin(a))
			var pc := Vector3(q.x*cos(b),q.y,q.x*sin(b))
			var pd := Vector3(p.x*cos(b),p.y,p.x*sin(b))
			if q.x > .0001: _tri(st,pa,pb,pc,uv)
			if p.x > .0001: _tri(st,pa,pc,pd,uv)

static func _solid_polygon(st: SurfaceTool,points: PackedVector2Array,depth: float,uv: Vector2,transform := Transform3D.IDENTITY) -> void:
	var indices := Geometry2D.triangulate_polygon(points)
	for side in [-1.0,1.0]:
		for k in range(0,indices.size(),3):
			var a := transform*Vector3(points[indices[k]].x,points[indices[k]].y,side*depth)
			var b := transform*Vector3(points[indices[k+1]].x,points[indices[k+1]].y,side*depth)
			var c := transform*Vector3(points[indices[k+2]].x,points[indices[k+2]].y,side*depth)
			_tri(st,a,b,c,uv) if side>0 else _tri(st,a,c,b,uv)
	for i in points.size():
		var a := points[i]
		var b := points[(i+1)%points.size()]
		_quad(st,transform*Vector3(a.x,a.y,-depth),transform*Vector3(b.x,b.y,-depth),transform*Vector3(b.x,b.y,depth),transform*Vector3(a.x,a.y,depth),uv)

static func _rocket(st: SurfaceTool,variant: int) -> void:
	var red := _uv(["d72c3b","ed3539","ae253b"][variant])
	var metal := _uv("a3b8c2")
	var dark := _uv("293c55")
	_lathe(st,[Vector2(0,-.32),Vector2(.055,-.32),Vector2(.095,-.20),Vector2(.125,0),Vector2(.11,.18),Vector2(.065,.32),Vector2(0,.43)],red)
	_lathe(st,[Vector2(0,-.36),Vector2(.054,-.36),Vector2(.066,-.30),Vector2(0,-.30)],dark)
	for y in [-.20,.19]:
		var radius := .098 if y<0 else .110
		_lathe(st,[Vector2(radius,y-.012),Vector2(radius,y+.012)],metal)
	var fin := PackedVector2Array([Vector2(.065,-.29),Vector2(.25,-.39),Vector2(.23,-.20),Vector2(.10,-.105)])
	for i in 3:
		_solid_polygon(st,fin,.012,metal,Transform3D(Basis(Vector3.UP,TAU*i/3),Vector3.ZERO))
	# Raised opaque glass and a silver bezel on the camera-facing side.
	for side in [-1.0,1.0]:
		var center := Vector3(0,.10,side*.127)
		for i in 12:
			var a := TAU*i/12
			var b := TAU*(i+1)/12
			var oa := center+Vector3(cos(a)*.061,sin(a)*.061,0)
			var ob := center+Vector3(cos(b)*.061,sin(b)*.061,0)
			var ia := center+Vector3(cos(a)*.043,sin(a)*.043,side*.006)
			var ib := center+Vector3(cos(b)*.043,sin(b)*.043,side*.006)
			if side>0:
				_quad(st,ia,oa,ob,ib,metal)
				_tri(st,center+Vector3(0,0,.006),ia,ib,dark)
			else:
				_quad(st,ib,ob,oa,ia,metal)
				_tri(st,center-Vector3(0,0,.006),ib,ia,dark)
	var flash := PackedVector2Array([Vector2(-.021,.111),Vector2(.006,.111),Vector2(.019,.132),Vector2(-.011,.132)])
	_solid_polygon(st,flash,.001,_uv("7fd5e3"),Transform3D(Basis.IDENTITY,Vector3(0,0,.135)))

static func _star(st: SurfaceTool,variant: int) -> void:
	var outline := PackedVector2Array()
	var points := 4 if variant==1 else 5
	for i in points*2:
		var angle := PI/2+TAU*i/(points*2)
		var radius := .19 if i%2==0 else .073
		outline.append(Vector2(cos(angle),sin(angle))*radius)
	_solid_polygon(st,outline,.023,_uv(["ffd34e","a1e7ee","efa2ce"][variant]))

static func _planet_point(lat: float,lon: float,variant := -1) -> Vector3:
	# Smooth continuous boundaries around the sphere, never cell-by-cell colors.
	if variant in [0,4,5]:
		lat += (.15*sin(lon*2)+.075*cos(lon*3+.6))*cos(lat)
	var point := Vector3(cos(lat)*cos(lon),sin(lat),cos(lat)*sin(lon))*.18
	if variant==0: point = Basis(Vector3.FORWARD,.9)*point
	return point

static func _crater(st: SurfaceTool,direction: Vector3) -> void:
	var normal := direction.normalized()
	var tangent := normal.cross(Vector3.UP).normalized()
	var vertical := normal.cross(tangent)
	var center := normal*.181
	for i in 8:
		var a := TAU*i/8
		var b := TAU*(i+1)/8
		var da := tangent*cos(a)+vertical*sin(a)
		var db := tangent*cos(b)+vertical*sin(b)
		var ia := (normal+da*.13).normalized()*.184
		var ib := (normal+db*.13).normalized()*.184
		var oa := (normal+da*.22).normalized()*.184
		var ob := (normal+db*.22).normalized()*.184
		_tri(st,center,ia,ib,_uv("596479"))
		_quad(st,ia,oa,ob,ib,_uv("c4c5bb"))

static func _planet(st: SurfaceTool,variant: int) -> void:
	var palettes := [["3f99d6","70bf82","b5dfdf"],["c99b61","e3c08b","9f7849"],["8874c4","b09cdb","595b9a"],["bb714c","d9a16c","854831"],["abdce9","e7f3ef","638fad"],["55364b","ed6730","a53338"],["379879","afcf75","226057"],["9ba3af","c4c5bb","596479"]]
	for row in 8:
		for i in 12:
			var a := -PI/2+PI*row/8
			var b := -PI/2+PI*(row+1)/8
			var x := TAU*i/12
			var y := TAU*(i+1)/12
			var color_index := row%3
			if variant==0: color_index = 1 if row>=5 or row<=1 else 0
			if variant==4: color_index = 1 if row<=1 or row>=6 else 0
			if variant==5: color_index = 1 if row==3 else (2 if row==4 else 0)
			if variant==6: color_index = [0,0,1,1,0,2,2,0][row]
			if variant==7: color_index = 0
			var uv := _uv(palettes[variant][color_index])
			var pa := _planet_point(a,x,variant)
			var pb := _planet_point(b,x,variant)
			var pc := _planet_point(b,y,variant)
			var pd := _planet_point(a,y,variant)
			if row<7: _tri(st,pa,pb,pc,uv)
			if row>0: _tri(st,pa,pc,pd,uv)
	if variant==7:
		for direction in [Vector3(.3,.3,1),Vector3(-.55,-.4,1),Vector3(1,.3,-.4),Vector3(-.2,-.2,-1)]:
			_crater(st,direction)
	if variant==1:
		var basis := Basis(Vector3.FORWARD,.35)
		for i in 24:
			var a := TAU*i/24
			var b := TAU*(i+1)/24
			var points: Array[Vector3] = []
			for y in [-.009,.009]:
				for polar in [Vector2(.225,a),Vector2(.31,a),Vector2(.31,b),Vector2(.225,b)]:
					points.append(basis*Vector3(polar.x*cos(polar.y),y,polar.x*sin(polar.y)))
			var uv := _uv("e3c08b")
			_quad(st,points[0],points[1],points[2],points[3],uv)
			_quad(st,points[7],points[6],points[5],points[4],uv)
			_quad(st,points[1],points[5],points[6],points[2],uv)
			_quad(st,points[3],points[7],points[4],points[0],uv)

static func _build_mesh(index: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	if index<3: _rocket(st,index)
	elif index<6: _star(st,index-3)
	else: _planet(st,index-6)
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
	root.name = "SpaceBurst"
	root.set_meta("burst_profile",[lean,lift,spread,rng.randi()])
	camera.add_child(root)
	var planets := [6,7,8,9,10,11,12,13]
	for i in range(planets.size()-1,0,-1):
		var j := rng.randi_range(0,i)
		var temporary: int = planets[i]
		planets[i] = planets[j]
		planets[j] = temporary
	var per_region := 24
	var sparse_region := rng.randi_range(0,2)
	var planet_cursor := 0
	var rocket_region := rng.randi_range(0,2)
	var rocket_slot := rng.randi_range(0,19)
	var rocket_variant := rng.randi_range(0,2)
	for region in 3:
		var choices: Array = []
		var planet_count := 2 if region == sparse_region else 3
		for i in per_region:
			var variant: int = 3+i%3
			if i>=24-planet_count:
				variant = planets[planet_cursor]
				planet_cursor += 1
			choices.append(rocket_variant if region == rocket_region and i == rocket_slot else variant)
		for i in range(choices.size()-1,0,-1):
			var j := rng.randi_range(0,i)
			var temp: int = choices[i]
			choices[i] = choices[j]
			choices[j] = temp
		for i in per_region:
			var p := SpaceFlight.new()
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
			if choices[i] in [3,4,5]: p.base_size *= .5
			if choices[i]>=6: p.base_size *= .8+((choices[i]-6)%3)*.22
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

class SpaceFlight extends MeshInstance3D:
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

