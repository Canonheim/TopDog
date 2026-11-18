extends Node3D
const After = preload("res://ui3d/trash_effect.gd")
const Before = preload("res://tests/trash_before_wide.gd")
const Pan = preload("res://ui3d/pan_effect.gd")
func _ready() -> void:
	var camera := Camera3D.new()
	camera.fov = 34
	add_child(camera)
	var results := {}
	for label in ["before","after","pan"]:
		var effect = {"before":Before,"after":After,"pan":Pan}[label]
		var samples := []
		for trial in 8:
			var burst: Node3D = effect.burst(camera)
			var flights := burst.get_children()
			for flight in flights: flight.set_process(false)
			for frame in 79:
				for flight in flights: flight._process(1.0/60)
				if frame not in [23,41,59,77]: continue
				var low := Vector2(1,1)
				var high := Vector2.ZERO
				var visible := 0
				for flight in flights:
					if not flight.visible: continue
					for mesh: MeshInstance3D in flight.find_children("*","MeshInstance3D",true,false):
						var a := Vector2(INF,INF)
						var b := Vector2(-INF,-INF)
						for corner in 8:
							var p: Vector3 = camera.to_local(mesh.to_global(mesh.mesh.get_aabb().get_endpoint(corner)))
							var hh := -p.z*tan(deg_to_rad(17))
							var uv := Vector2(.5+p.x/(2*hh*1.6),.5-p.y/(2*hh))
							a = a.min(uv)
							b = b.max(uv)
						if b.x<0 or a.x>1 or b.y<0 or a.y>1: continue
						visible += 1
						low = low.min(a.clamp(Vector2.ZERO,Vector2.ONE))
						high = high.max(b.clamp(Vector2.ZERO,Vector2.ONE))
				var size := high-low
				samples.append({"seconds":(frame+1)/60.0,"width":size.x,"height":size.y,"bounds_area":size.x*size.y,"visible":visible})
			burst.queue_free()
			await get_tree().process_frame
		results[label] = samples
	var file := FileAccess.open("C:/Users/growi/Documents/ChatGPT/Top dog 2/trash-preview/coverage.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results))
	file.close()
	print("TRASH_COVERAGE_COMPLETE before/after/Pan, 34deg, 16:10, eight activations each")
	get_tree().quit()
