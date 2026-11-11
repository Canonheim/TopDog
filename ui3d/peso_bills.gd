extends RefCounted
## Fictional peso-inspired paper: atlas ink, borders, seals and denominations.
const COLORS := [Color("a59acb"),Color("86b5d4"),Color("9ebc84"),Color("d59280"),Color("d4a2ba"),Color("c8b88c")]
const VALUES := ["20","50","100","200","500","1000"]
const DIGITS := {"0":["111","101","101","101","111"],"1":["010","110","010","010","111"],"2":["111","001","111","100","111"],"5":["111","100","111","001","111"]}
const NX := 32
const NY := 14
static var meshes := {}

static func bill_mesh(color_index: int, form: int) -> ArrayMesh:
	var key := color_index * 3 + form
	if meshes.has(key):
		return meshes[key]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var base: Color = COLORS[color_index]
	var palette := [AtlasPalette.swatch(base).uv, AtlasPalette.swatch(base.lightened(.43)).uv, AtlasPalette.swatch(base.darkened(.58)).uv, AtlasPalette.swatch(base.darkened(.22)).uv]
	for y in NY:
		for x in NX:
			var uv: Vector2 = palette[_ink(x,y,color_index)]
			var a := _point(x,y,color_index,form)
			var b := _point(x+1,y,color_index,form)
			var c := _point(x+1,y+1,color_index,form)
			var d := _point(x,y+1,color_index,form)
			_triangle(st,a,b,c,uv)
			_triangle(st,a,c,d,uv)
	var mesh := st.commit()
	var mat := StandardMaterial3D.new()
	mat.resource_name = "PALETTE"
	mat.albedo_texture = CelPass.ATLAS
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.roughness = 1.0
	mesh.surface_set_material(0,CelPass.material_for(mat,mesh))
	meshes[key] = mesh
	return mesh

static func _ink(x: int,y: int,index: int) -> int:
	if x == 0 or x == NX-1 or y == 0 or y == NY-1:
		return 1
	if x == 1 or x == NX-2 or y == 1 or y == NY-2:
		return 3
	# Vertical security band and a small repeating woven trim.
	if x in [4,5]:
		return 2 if (y / 2) % 2 == 0 else 3
	var digits: String = VALUES[index]
	var start := NX-3-digits.length()*4
	if x >= start and y >= 3 and y < 8:
		var col := x-start
		var digit := col / 4
		if digit < digits.length() and col % 4 < 3:
			if DIGITS[digits[digit]][y-3][col%4] == "1":
				return 2
	# A geometric sun medallion on the left, distinct from a real portrait.
	var radius := Vector2((x-11.5)/4.2,(y-6.5)/4.3).length()
	if radius < 1.0:
		if radius > .73:
			return 2
		if absi(x-12)+absi(y-7) <= 2:
			return 3
		return 1
	if y in [10,11] and x >= 18 and x <= 28:
		return 3 if y == 10 or x%3 != 0 else 1
	return 0

static func _point(x: int,y: int,index: int,form: int) -> Vector3:
	var u := float(x)/NX*2-1
	var v := float(y)/NY*2-1
	var width := .22 + index*.009
	var height := .105 + (index%3)*.008
	if form == 0:
		# Gentle curl: even the least damaged bills have physical depth.
		return Vector3(u*width,v*height,.025*u*u + .012*sin(v*PI+index))
	if form == 1:
		# Unequal accordion creases, with a lifted corner.
		return Vector3(u*width*.88,v*height,.035*absf(sin(u*PI*1.5))+.02*u*v)
	# A loosely crushed paper wad: curled edges around a visible center panel.
	var angle := u*2.1
	return Vector3(sin(angle)*width*.46, v*height*.65+.018*sin(u*8+v*4), (1-cos(angle))*width*.42+.045*v*v+.012*sin(u*12-v*6))

static func _triangle(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,uv: Vector2) -> void:
	var normal := (b-a).cross(c-a).normalized()
	for back in [false,true]:
		for point in ([a,b,c] if back else [a,c,b]):
			st.set_uv(uv)
			st.set_normal(-normal if back else normal)
			st.add_vertex(point)

static func burst(camera: Node3D) -> Node3D:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var lean := rng.randf_range(-0.30, 0.30)
	var lift := rng.randf_range(0.94, 1.06)
	var spread := rng.randf_range(0.90, 1.10)
	var origin := Vector3(rng.randf_range(-0.16, 0.16), rng.randf_range(-0.05, 0.05), 0)
	var root := Node3D.new()
	root.set_meta("burst_profile", [origin, lean, lift, spread])
	root.name = "PesoBillBurst"
	camera.add_child(root)
	var serial := 0
	for batch in 6:
		for form in 3:
			var count: int = [6,5,1][form]
			for i in count:
				var color_index := batch if i == 0 else rng.randi_range(0, COLORS.size()-1)
				var bill := BillFlight.new()
				bill.name = "Bill%dForm%d_%d" % [color_index,form,i]
				bill.set_meta("form",form)
				bill.set_meta("color_index",color_index)
				bill.mesh = bill_mesh(color_index,form)
				bill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				root.add_child(bill)
				bill.position = Vector3(rng.randf_range(-.3,.3),.6,-5) + origin
				bill.rotation = Vector3(rng.randf_range(-.5,.5),rng.randf_range(-.6,.6),rng.randf_range(-PI,PI))
				bill.scale = Vector3.ONE * rng.randf_range(.5,.85)
				# Stratified lanes and heights prevent random empty patches.
				var lane := (serial * 5) % 12
				var layer := serial / 12
				var vx := lerpf(-2.7, 2.7, (lane + rng.randf_range(.2,.8)) / 12.0)
				var vy := lerpf(0.6, 5.4, (layer + rng.randf_range(.15,.85)) / 6.0)
				bill.velocity = Vector3(vx * spread + lean, vy * lift, rng.randf_range(-.25,.25))
				bill.set_meta("coverage_lane", lane)
				serial += 1
				bill.spin = Vector3(rng.randf_range(-2.0,2.0),rng.randf_range(-2.3,2.3),rng.randf_range(-3.0,3.0))
				bill.delay = rng.randf_range(0,.3)
				bill.hide()
	root.get_tree().create_timer(3.2).timeout.connect(func():
		if is_instance_valid(root):
			root.queue_free())
	return root

class BillFlight extends MeshInstance3D:
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
