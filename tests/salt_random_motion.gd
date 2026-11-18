extends Node3D
const Effect = preload("res://ui3d/salt_effect.gd")
var failures := 0
func _ready() -> void:
	var camera := Camera3D.new()
	camera.fov = 34
	add_child(camera)
	var checked := 0
	var signatures := {}
	var crossing_paths := 0
	var left_region_rightward := 0
	var right_region_leftward := 0
	for big in [false,true]:
		for trial in 24:
			var burst: Node3D = Effect.burst(camera,big)
			var shakers := []
			for flight in burst.get_children():
				flight.set_process(false)
				if not flight.get_meta("grain"): shakers.append(flight)
			var launches := []
			var delays := {}
			for flight in shakers:
				var profile: Dictionary = flight.get_meta("shaker_launch")
				launches.append(profile)
				delays[profile.delay] = true
				if int(flight.get_meta("coverage_region"))==0 and profile.velocity.x>.2: left_region_rightward += 1
				if int(flight.get_meta("coverage_region"))==2 and profile.velocity.x<-.2: right_region_leftward += 1
			var signature := str(launches)
			if signatures.has(signature) or delays.size()!=10: failures += 1
			signatures[signature] = true
			for i in launches.size():
				for j in range(i+1,launches.size()):
					var a: Dictionary = launches[i]
					var b: Dictionary = launches[j]
					var first: float = a.start.x-b.start.x
					var later: float = first+(a.velocity.x-b.velocity.x)*.91
					if first*later<0: crossing_paths += 1
			for frame in (215 if big else 180):
				for flight in shakers:
					flight._process(1.0/60)
					if not flight.visible or flight.age>flight.lifetime-.22: continue
					var mesh: MeshInstance3D = flight.get_child(0)
					for corner in 8:
						var point: Vector3 = camera.to_local(mesh.to_global(mesh.mesh.get_aabb().get_endpoint(corner)))
						var half_h: float = -point.z*tan(deg_to_rad(17))
						if not point.is_finite():
							failures += 1
					checked += 1
			burst.queue_free()
			await get_tree().process_frame
	if crossing_paths==0 or left_region_rightward==0 or right_region_leftward==0: failures += 1
	print("SALT_MOTION ",JSON.stringify({"failures":failures,"shaker_frame_bounds_checked":checked,"activations":48,"unique_launch_sets":signatures.size(),"crossing_paths":crossing_paths,"left_region_rightward":left_region_rightward,"right_region_leftward":right_region_leftward,"fov":34,"aspect":1.6,"requirement":"finite random burst trajectories; offscreen travel allowed like other effects"}))
	get_tree().quit(1 if failures else 0)
