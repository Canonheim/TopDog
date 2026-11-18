extends SceneTree
var failures: Array[String] = []
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var prep = load("res://ui3d/lock_effect_preparation.gd")
	var ids: Array = load("res://tests/common_effects_match_probe.gd").IDS
	var cam := Camera3D.new()
	root.add_child(cam)
	cam.position = Vector3(3,4,8)
	cam.rotation = Vector3(-.15,.25,.1)
	var rows: Array = []
	for id in ids:
		var count := 0
		var sum := 0.0
		var minimum := INF
		var maximum := -INF
		for sample in 12:
			var burst: Node3D = prep.burst(id,cam)
			for child in burst.get_children():
				if not child is Node3D: continue
				var local: Vector3 = cam.to_local(child.global_position)
				sum += local.y
				count += 1
				minimum = minf(minimum,local.y)
				maximum = maxf(maximum,local.y)
			burst.free()
		var mean := sum/maxi(1,count)
		if count==0 or absf(mean-.4)>.15: failures.append(str(id)+" launch mean "+str(mean))
		rows.append({"id":id,"particles":count,"mean_y":mean,"min_y":minimum,"max_y":maximum})
	var pickles: Node3D = prep.burst("pickles",cam)
	for child in pickles.get_children():
		if child is Node3D and absf(cam.to_local(child.global_position).y-.4)>.001:
			failures.append("Pickles reference changed")
	pickles.free()
	print("COMMON_LAUNCH_HEIGHT "+JSON.stringify({"effects":rows,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
