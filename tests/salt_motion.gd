extends Node3D
const Effect = preload("res://ui3d/salt_effect.gd")
var failures := 0
func _ready() -> void:
	var camera := Camera3D.new()
	camera.fov = 34
	add_child(camera)
	var checked := 0
	for big in [false,true]:
		for trial in 12:
			var burst: Node3D = Effect.burst(camera,big)
			var shakers := []
			for flight in burst.get_children():
				flight.set_process(false)
				if not flight.get_meta("grain"): shakers.append(flight)
			for frame in (191 if big else 158):
				for flight in shakers:
					flight._process(1.0/60)
					if not flight.visible or flight.age>flight.lifetime-.22: continue
					var mesh: MeshInstance3D = flight.get_child(0)
					for corner in 8:
						var point: Vector3 = camera.to_local(mesh.to_global(mesh.mesh.get_aabb().get_endpoint(corner)))
						var half_h: float = -point.z*tan(deg_to_rad(17))
						if absf(point.y)>half_h*.95 or absf(point.x)>half_h*1.6*.95:
							failures += 1
					checked += 1
			burst.queue_free()
			await get_tree().process_frame
	print("SALT_MOTION ",JSON.stringify({"failures":failures,"shaker_frame_bounds_checked":checked,"activations":24,"fov":34,"aspect":1.6,"requirement":"entire shaker within 95% viewport until fade starts"}))
	get_tree().quit(1 if failures else 0)
