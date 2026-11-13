extends Node
const Pickup := preload("res://game/cosmetic_pinata.gd")
var failures := 0
func _ready():
	var world := Node3D.new()
	add_child(world)
	for layer in [Climber.LAYER_LIVE,Climber.LAYER_FROZEN,Climber.LAYER_PROP]:
		var item := Pickup.new()
		world.add_child(item)
		var hits := [0]
		item.collected.connect(func(_body): hits[0]+=1)
		var body := RigidBody3D.new()
		body.freeze = true
		body.collision_layer = layer
		body.collision_mask = 0
		var shape := CollisionShape3D.new()
		shape.shape = SphereShape3D.new()
		shape.shape.radius = .1
		body.add_child(shape)
		world.add_child(body)
		body.position = Vector3(.68,0,0)
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		if not item.taken or hits[0]!=1: failures+=1
		item._touch(body)
		if hits[0]!=1: failures+=1
		if item.visual.visible: failures+=1
		for spark in item.burst_root.get_children():
			if spark is Pickup.Spark:
				if spark.head.get_instance_shader_parameter("swatch_uv") != spark.tail.get_instance_shader_parameter("swatch_uv"): failures+=1
		body.queue_free()
		await get_tree().create_timer(2.2).timeout
		if is_instance_valid(item): failures+=1
	print("PINATA CONTACT / SINGLE TRIGGER / MATCHED TRAILS / CLEANUP fails=",failures)
	get_tree().quit(failures)
