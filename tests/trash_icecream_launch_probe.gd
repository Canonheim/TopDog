extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var prep = load("res://ui3d/lock_effect_preparation.gd")
	var cam := Camera3D.new()
	root.add_child(cam)
	cam.position = Vector3(3,4,8)
	cam.rotation = Vector3(-.15,.25,.1)
	var rows := []
	var retained := []
	for id in ["trash","ice_cream_social"]:
		var count := 0
		var minimum_up := INF
		var maximum_origin_x := 0.0
		var first_visible_max_x := 0.0
		var min_spread := INF
		for sample in 24:
			var burst: Node3D = prep.burst(id,cam)
			for p in burst.get_children():
				p.set_process(false)
				var origin: Vector3 = cam.to_local(p.global_position)
				maximum_origin_x=maxf(maximum_origin_x,absf(origin.x))
				minimum_up=minf(minimum_up,p.velocity.y)
				if absf(origin.x)>.251 or absf(origin.y-.4)>.001 or absf(origin.z+5)>.001: failures.append(id+" noncompact origin")
				if p.velocity.y<=0: failures.append(id+" nonupward initial velocity")
				var meshes: Array = [p] if p is MeshInstance3D else p.get_children()
				for mesh in meshes:
					if mesh is MeshInstance3D:
						var visible_origin: Vector3 = cam.to_local(mesh.to_global(mesh.mesh.get_aabb().get_center()))
						if visible_origin.distance_to(origin)>.10: failures.append(id+" off-center visible geometry: "+str(visible_origin-origin))
				var first := true
				for frame in 100:
					p._process(1.0/120.0)
					var at: Vector3 = cam.to_local(p.global_position)
					if not p.visible and at.distance_to(origin)>.001: failures.append(id+" moved before emission")
					if p.visible and first:
						first=false
						first_visible_max_x=maxf(first_visible_max_x,absf(at.x))
						if at.y<=origin.y or at.distance_to(origin)>.10: failures.append(id+" remote/downward first visible frame")
				count+=1
			var left := INF
			var right := -INF
			for p in burst.get_children():
				left=minf(left,cam.to_local(p.global_position).x)
				right=maxf(right,cam.to_local(p.global_position).x)
			min_spread=minf(min_spread,right-left)
			burst.free()
		if min_spread<1.0: failures.append(id+" failed to fan outward")
		rows.append({"id":id,"particles":count,"minimum_up_speed":minimum_up,"max_origin_x":maximum_origin_x,"first_visible_max_x":first_visible_max_x,"minimum_later_spread":min_spread})
		retained.append(prep.burst(id,cam))
	await create_timer(3.4).timeout
	for effect in retained:
		if is_instance_valid(effect): failures.append("Timed cleanup failed")
	print("COMPACT_TOSS ",JSON.stringify({"effects":rows,"errors":failures}))
	quit(0 if failures.is_empty() else 1)
