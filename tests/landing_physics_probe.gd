extends Node
const D=preload("res://game/landing_tracker.gd")
const Layout=preload("res://climber/body_layout.gd")
var fails:=0
func check(ok: bool, text: String) -> void:
	if not ok: fails+=1;push_error(text)
func _ready() -> void:
	get_tree().create_timer(15).timeout.connect(func(): push_error("LANDING PHYSICS TIMEOUT");get_tree().quit(1))
	var world:=Node3D.new();add_child(world)
	var floor_body:=StaticBody3D.new()
	floor_body.collision_layer=Climber.LAYER_WORLD
	floor_body.position.y=-.1
	var shape:=CollisionShape3D.new()
	var box:=BoxShape3D.new();box.size=Vector3(20,.2,2)
	shape.shape=box;floor_body.add_child(shape);world.add_child(floor_body)
	var c:=Climber.new();add_child(c);c.build(Vector2.ZERO,world)
	await get_tree().create_timer(.5).timeout
	check(c.is_attached(),"fixture planted on real floor")
	var d=D.new()
	d.observe(c,1.0/120.0)
	check(d.armed,"ground contact arms detector")
	var rest:PackedFloat32Array=c.pose()
	c.release_all();c.set_physics_process(false)
	for body:RigidBody3D in c.bodies.values(): body.freeze=true
	var times:Array=[]
	# Feed full-body transformed poses in genuine physics frames; collision reads stay live.
	for i in range(1,181):
		var angle:=TAU*i/180.0
		var pose:=rest.duplicate()
		for k in range(0,pose.size(),3):
			var at:=Vector2(rest[k],rest[k+1]-1).rotated(angle)+Vector2(0,6)
			pose[k]=at.x;pose[k+1]=at.y;pose[k+2]=rest[k+2]+angle
		c.apply_pose(pose)
		await get_tree().physics_frame
		var start:=Time.get_ticks_usec()
		d.observe(c,1.0/120.0)
		times.append(Time.get_ticks_usec()-start)
	check(d.completed_turn,"real body rotations accumulate a full turn")
	c.apply_pose(rest)
	for body:RigidBody3D in c.bodies.values():
		body.freeze=false;body.linear_velocity=Vector3.ZERO;body.angular_velocity=Vector3.ZERO
	c.set_physics_process(true)
	var awards:=0
	for i in 100:
		await get_tree().physics_frame
		if d.observe(c,1.0/120.0):awards+=1
	check(awards==1,"actual foot contacts/welds complete exactly one stable landing")
	times.sort()
	print("LANDING PHYSICS fails=",fails," detector CPU us: median=",times[times.size()/2]," p95=",times[int(times.size()*.95)]," max=",times[-1])
	c.remove()
	await get_tree().process_frame
	get_tree().quit(fails)
