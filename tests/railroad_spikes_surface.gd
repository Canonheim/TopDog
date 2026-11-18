extends Node3D
const Effect = preload("res://ui3d/railroad_spikes_effect.gd")
var failures := 0
func check(ok: bool,label: String) -> void:
	if not ok:
		failures+=1
		push_error(label)
func _ready() -> void:
	Effect.prepare()
	var camera := Camera3D.new()
	add_child(camera)
	var samples := 0
	var axis_samples := 0
	var max_update_usec := 0
	var costs := []
	for skin in [Wardrobe.PUG,Wardrobe.SPIRAL]:
		for size in [.6,.9,1.4]:
			for angle in [0.0,.47,-.81]:
				var model: Node3D = skin.instantiate()
				add_child(model)
				model.scale = Vector3.ONE*size
				camera.global_position=Vector3(sin(angle)*6,1.5,cos(angle)*6)
				camera.look_at(Vector3(0,.7,0),Vector3.UP)
				var anchors: Array[Node3D] = []
				for key in ["Hand","L_Hand","Foot","L_Foot"]:
					var skin_mesh: MeshInstance3D = model.find_child(key,true,false)
					skin_mesh.rotate_x(angle*.3)
					skin_mesh.rotate_y(angle)
					skin_mesh.rotate_z(angle*.7)
					anchors.append(skin_mesh)
				var start := Time.get_ticks_usec()
				var effect = Effect.attach_anchors(model,anchors,size,camera,true)
				costs.append((Time.get_ticks_usec()-start)/1000.0)
				effect.set_process(false)
				for tick in 340:
					if not effect.settled:
						var update_start := Time.get_ticks_usec()
						effect._process(.001)
						max_update_usec=maxi(max_update_usec,Time.get_ticks_usec()-update_start)
					for i in 4:
						var progress: float = (effect.age-i*Effect.STAGGER_SECONDS)/Effect.FLIGHT_SECONDS
						if progress>0 and progress<1 and not effect.settled:
							var pin: MeshInstance3D = effect.pins[i]
							var target: Transform3D = anchors[i].global_transform*effect.targets[i]
							var ray: Vector3 = (target*Effect.TIP-effect.starts[i]).normalized()
							check((-pin.global_basis.z.normalized()).dot(ray)>.9999,"Shaft stays on incoming ray including final flight segment")
							axis_samples+=1
				check(effect.settled,"All angled-view pins settle")
				for i in 4:
					var skin_mesh: MeshInstance3D = anchors[i]
					var pin: MeshInstance3D = effect.pins[i]
					var tip := pin.global_transform*Effect.TIP
					var incoming := -pin.global_basis.z.normalized()
					check(incoming.dot(effect.launch_axes[i])>.9999,"Settled axis equals actual launch axis")
					# Independent world-space ray against real skin, not stored contacts.
					var face := skin_mesh.mesh.get_faces()
					var hit_skin := false
					for j in range(0,face.size(),3):
						var hit: Variant = Geometry3D.ray_intersects_triangle(tip-incoming*.014*size,incoming,skin_mesh.to_global(face[j]),skin_mesh.to_global(face[j+1]),skin_mesh.to_global(face[j+2]))
						if hit != null and tip.distance_to(hit)<=.007*size and (tip-hit).dot(incoming)>0:
							hit_skin=true
							break
					check(hit_skin,"Tip penetrates actual hand/foot surface from incoming side")
					samples+=1
				model.queue_free()
				await get_tree().process_frame
	print("RAILROAD_SURFACE ",JSON.stringify({"failures":failures,"actual_skin_contacts":samples,"incoming_axis_samples":axis_samples,"spawn_ms":costs,"max_flight_update_ms":max_update_usec/1000.0}))
	get_tree().quit(failures)
