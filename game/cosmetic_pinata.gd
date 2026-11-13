extends Area3D
## Preview-only collectible. No spawn policy or cosmetic rewards are assigned here.
signal collected(body: Node3D)
const PINATA := preload("res://kit/models/pinata.glb")
const COLORS := [Color("ff365c"),Color("ffd533"),Color("22d9ce"),Color("a758ef"),Color("ff852e"),Color("70d94d")]
var taken := false
var pulse_time := 0.0
var visual: Node3D
var spinner: Node3D
var stars: Array[MeshInstance3D] = []
var burst_root: Node3D

func _ready() -> void:
	collision_layer = 0
	collision_mask = Climber.LAYER_LIVE | Climber.LAYER_FROZEN | Climber.LAYER_PROP
	monitorable = false
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = .64
	shape.shape = sphere
	add_child(shape)
	visual = Node3D.new()
	add_child(visual)
	spinner = Node3D.new()
	visual.add_child(spinner)
	var model := PINATA.instantiate()
	spinner.add_child(model)
	model.scale = Vector3.ONE*.72
	model.position.y = .56
	CelPass.celify(model)
	for i in 2:
		var star := MeshInstance3D.new()
		star.mesh = _star(1.0 if i == 0 else .84)
		star.position.z = -.55 if i == 0 else -.48
		star.rotation.z = .28 if i == 0 else -.20
		star.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		visual.add_child(star)
		CelPass.paint(star,Color("ffc928") if i == 0 else Color("ff852e"))
		stars.append(star)
	_update_star_pulse()
	body_entered.connect(_touch)

static func _star(radius: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 10:
		var a := PI*.5+TAU*i/10
		var b := PI*.5+TAU*(i+1)/10
		var ra := radius if i%2==0 else radius*.45
		var rb := radius if (i+1)%2==0 else radius*.45
		for v in [Vector3.ZERO,Vector3(cos(b)*rb,sin(b)*rb,0),Vector3(cos(a)*ra,sin(a)*ra,0)]:
			st.set_normal(Vector3.BACK)
			st.add_vertex(v)
	return st.commit()

func _process(delta: float) -> void:
	if taken: return
	pulse_time += delta
	_update_star_pulse()
	spinner.rotation.y += delta*.85
	stars[0].rotation.z += delta*.43
	stars[1].rotation.z -= delta*.77

func _update_star_pulse() -> void:
	# Opposite phases; the gold star stays larger even at its smallest point.
	# Separate depth planes keep the rotating meshes from intersecting.
	var pulse := sin(pulse_time * TAU / 1.8)
	stars[0].scale = Vector3.ONE * (1.10 + .12*pulse)
	stars[1].scale = Vector3.ONE * (.83 - .12*pulse)


func _touch(body: Node3D) -> void:
	if taken or not body is CollisionObject3D: return
	if not (body.collision_layer & collision_mask): return
	taken = true
	visual.hide()
	set_deferred("monitoring",false)
	set_process(false)
	_burst()
	collected.emit(body)

func _burst() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	burst_root = Node3D.new()
	burst_root.name = "PinataCollectionBurst"
	get_parent().add_child(burst_root)
	burst_root.global_position = global_position
	# Paper comes from the same center, with a dense quick burst and a falling tail.
	for i in 6:
		var paper := CPUParticles3D.new()
		paper.amount = 12
		paper.lifetime = 1.65
		paper.one_shot = true
		paper.explosiveness = 1.0
		paper.direction = Vector3(cos(TAU*i/6),sin(TAU*i/6),.05)
		paper.spread = 38
		paper.initial_velocity_min = 1.0
		paper.initial_velocity_max = 3.3
		paper.gravity = Vector3(0,-2.5,0)
		paper.damping_min = .5
		paper.damping_max = 1.2
		paper.angular_velocity_min = -300
		paper.angular_velocity_max = 300
		paper.angle_max = 360
		paper.scale_amount_min = .55
		paper.scale_amount_max = 1.25
		var card := BoxMesh.new()
		card.size = Vector3(.075,.12,.008)
		paper.mesh = card
		paper.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		CelPass.paint(paper,COLORS[i])
		burst_root.add_child(paper)
		paper.emitting = true
	# Stratified angles leave no blank sector; each entire spark uses one swatch.
	for i in 24:
		var spark := Spark.new()
		spark.tint = COLORS[i%COLORS.size()]
		var angle := TAU*(i+rng.randf_range(-.4,.4))/24
		spark.velocity = Vector3(cos(angle),sin(angle),rng.randf_range(-.18,.18))*rng.randf_range(2.0,4.0)
		spark.bend = rng.randf_range(-1.5,1.5)
		spark.lifetime = rng.randf_range(.8,1.35)
		burst_root.add_child(spark)
	get_tree().create_timer(2.0).timeout.connect(func():
		if is_instance_valid(burst_root): burst_root.queue_free()
		queue_free())

class Spark extends Node3D:
	var tint := Color.WHITE
	var velocity := Vector3.ZERO
	var bend := 0.0
	var lifetime := 1.0
	var age := 0.0
	var head: MeshInstance3D
	var tail: MeshInstance3D
	var ribbon := ImmediateMesh.new()
	var history: Array[Vector3] = []
	var history_time := 0.0
	func _ready() -> void:
		head = MeshInstance3D.new()
		var ball := SphereMesh.new()
		ball.radius = .045
		ball.height = .09
		ball.radial_segments = 8
		ball.rings = 4
		head.mesh = ball
		head.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(head)
		CelPass.paint(head,tint)
		tail = MeshInstance3D.new()
		tail.mesh = ribbon
		tail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(tail)
		CelPass.paint(tail,tint)
		history.append(Vector3.ZERO)
	func _process(delta: float) -> void:
		age += delta
		if age >= lifetime:
			queue_free()
			return
		velocity = velocity.rotated(Vector3.BACK,bend*delta)
		velocity *= exp(-.55*delta)
		head.position += velocity*delta
		head.scale = Vector3.ONE*maxf(.03,1.0-smoothstep(lifetime*.65,lifetime,age))
		history_time += delta
		if history_time >= 1.0/60:
			history_time = 0
			history.push_front(head.position)
			if history.size()>13: history.pop_back()
		ribbon.clear_surfaces()
		if history.size()<2: return
		ribbon.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in history.size()-1:
			var direction := (history[i]-history[i+1]).normalized()
			var across := Vector3(-direction.y,direction.x,0).normalized()
			var width := .027*(1.0-float(i)/history.size())*head.scale.x
			var next_width := .027*(1.0-float(i+1)/history.size())*head.scale.x
			var a := history[i]+across*width
			var b := history[i]-across*width
			var c := history[i+1]-across*next_width
			var d := history[i+1]+across*next_width
			for v in [a,b,c,a,c,d,c,b,a,d,c,a]:
				ribbon.surface_set_normal(Vector3.BACK)
				ribbon.surface_add_vertex(v)
		ribbon.surface_end()

func _exit_tree() -> void:
	if is_instance_valid(burst_root): burst_root.queue_free()
