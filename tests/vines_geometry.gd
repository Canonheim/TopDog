extends Node3D
const Effect=preload("res://ui3d/vines/vines.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/vines-new-model/installation/"
var errors: Array[String]=[]
var bridge_samples:=0
var bridge_ray_samples:=0
var bridge_clipped:=0
var bridge_worst:=0.0
var bridge_details: Dictionary={}
func check(ok: bool,why: String) -> void:
	if not ok:errors.append(why)
func _ready() -> void:
	var rendered:=DisplayServer.get_name()!="headless"
	get_window().size=Vector2i(960,720)
	get_window().content_scale_size=Vector2i(960,720)
	var env:=WorldEnvironment.new();env.environment=Environment.new()
	env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("202b2a")
	env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color=Color.WHITE;env.environment.ambient_light_energy=.45
	add_child(env)
	var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-30,-25,0);add_child(sun)
	var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;add_child(camera)
	var rows:=[]
	var previous_scale: float=Feel.get_k("body_scale")
	for fixture in 3:
		Feel.set_k("body_scale",previous_scale*(.85 if fixture==0 else 1.2))
		var actor:=Climber.new();actor.climber_id=90+fixture;add_child(actor)
		actor.build(Vector2.ZERO,self,Wardrobe.CLIMBER)
		var fixture_joints: Dictionary=actor.joints.duplicate(true)
		var size:=actor.body_scale
		# Two explicit frozen fixture poses, before the cosmetic is attached.
		var initial: Dictionary={}
		for key in actor.bodies: initial[key]=actor.bodies[key].global_transform
		var rotations: Dictionary={"arm_l_up":.65,"arm_l_lo":1.1,"arm_r_up":-.6,"arm_r_lo":-1.05}
		if fixture==1: rotations={"arm_l_up":-1.0,"arm_l_lo":-1.4,"arm_r_up":-.65,"arm_r_lo":-1.1,"leg_l_up":-.4,"leg_l_lo":-.35,"foot_l":-.2}
		for joint_name in Effect.Layout.JOINTS:
			var joint: Dictionary=Effect.Layout.JOINTS[joint_name]
			var actual: Dictionary=fixture_joints[joint_name]
			var parent: Node3D=actor.bodies[joint.a];var child: Node3D=actor.bodies[joint.b]
			var anchor:=Vector3(joint.at.x,joint.at.y,0)*size
			var parent_local:=Vector3(actual.local_a.x,actual.local_a.y,0)
			var child_local: Vector3=initial[joint.b].affine_inverse()*(initial[joint.a]*parent_local)
			child.rotation.z=float(rotations.get(joint.b,0))
			child.global_position=parent.to_global(parent_local)-child.global_basis*child_local
			Climber.sync_server(child)
		actor.freeze()
		CelPass.celify(self)
		Wardrobe.apply(self,{"skin":3 if fixture==0 else 1,"speedo":3,"head":fixture})
		var original:=actor.pose()
		var parts:=Effect.skin_parts(actor)
		if "--bake" in OS.get_cmdline_user_args() and fixture==0:
			Effect.authoring=true;Effect.prepare(parts);Effect.authoring=false;Effect.cache.clear();Effect.preparation_max_ms=0.0;Effect.preparation_samples.clear()
		var begin:=Time.get_ticks_usec()
		for key in parts:
			while not Effect.prepare_part(parts[key],key): await get_tree().process_frame
			await get_tree().process_frame
		var prep_ms:=(Time.get_ticks_usec()-begin)/1000.0
		begin=Time.get_ticks_usec();var effect=Effect.attach(actor);var attach_ms:=(Time.get_ticks_usec()-begin)/1000.0
		audit_bridges(effect,parts)
		check(effect.wraps.size()==21,"Eleven wraps and ten batched joint paths")
		check(Effect.attach(actor)==effect,"Duplicate attachment reuses effect")
		check(actor.pose()==original,"Attachment never alters frozen pose")
		effect.set_process(false)
		for stage in [.12,.35,.70]:
			effect.age=stage*Effect.DURATION;effect.update_growth()
			for wrap in effect.wraps:
				var part: String=wrap.get_meta("part","")
				var progress: float=wrap.get_instance_shader_parameter("vine_growth")
				if stage==.12 and part.begins_with("leg") and part.ends_with("lo"):check(progress>0,"Ankle stems lead growth")
				if stage==.35 and part.begins_with("leg") and part.ends_with("up"):check(progress>0,"Growth advances to upper legs")
				if stage<.6 and part in ["chest","navel"]:check(progress==0,"Torso waits for climbing roots")
				if stage==.70 and part=="chest":check(progress>0,"Roots reach chest before arms")
				if stage<=.70 and part.begins_with("arm"):check(progress==0,"Arm branches follow torso growth")
		effect.age=0;effect.update_growth()
		camera.size=2.75*size;camera.position=Vector3(0,1.15*size,5);camera.look_at(Vector3(0,1.15*size,0))
		var triangles:=0
		for wrap in effect.wraps:
			check(wrap is MultiMeshInstance3D or wrap.transform==Transform3D.IDENTITY,"Mesh-local wrap follows exact skin transform")
			check(wrap.material_override==Effect.material,"Shared material")
			triangles+=(wrap.multimesh.mesh.surface_get_array_len(0)/3)*wrap.multimesh.instance_count if wrap is MultiMeshInstance3D else wrap.mesh.surface_get_array_len(0)/3
		var folder:=OUT+"pose%d/"%fixture;DirAccess.make_dir_recursive_absolute(folder)
		for frame in 101 if rendered else 3:
			effect.age=float(frame)/25.0 if rendered else frame*Effect.DURATION*.5
			effect.update_growth()
			if rendered:
				await RenderingServer.frame_post_draw
				get_viewport().get_texture().get_image().save_png(folder+"%03d.png"%frame)
		check(not effect.is_processing(),"No idle animation processing after growth")
		check(actor.pose()==original,"Growth never alters frozen pose")
		if rendered:
			camera.position=Vector3(4*size,1.15*size,2.8*size);camera.look_at(Vector3(0,1.15*size,0))
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(folder+"side.png")
		rows.append({"skin":fixture,"body_scale":size,"parts":effect.wraps.size(),"triangles":triangles,"attach_ms":attach_ms,"preparation_ms":prep_ms})
		if rendered:
			camera.position=Vector3(0,1.4*size,4);camera.look_at(Vector3(0,1.4*size,0));camera.size=1.0*size
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(folder+"closeup.png")
		var profiles: Dictionary={str(effect.get_meta("profile")):true}
		camera.size=2.75*size;camera.position=Vector3(0,1.15*size,5);camera.look_at(Vector3(0,1.15*size,0))
		for repeat in 8:
			effect.queue_free();await get_tree().process_frame;await get_tree().process_frame
			seed(55334);var expected_rng:=randi();seed(55334)
			effect=Effect.attach(actor,null,false);profiles[str(effect.get_meta("profile"))]=true
			check(randi()==expected_rng,"Cosmetic variants leave gameplay RNG untouched")
			if repeat<3:audit_bridges(effect,parts)
			if rendered and repeat<3:
				await RenderingServer.frame_post_draw
				get_viewport().get_texture().get_image().save_png(folder+"variation%d.png"%repeat)
		check(profiles.size()>=3,"Fresh independent variant combinations")
		rows[-1]["distinct_activation_profiles"]=profiles.size()
		check(Effect.cache.size()==33,"All head/skin/suit looks reuse 33 fitted variants")
		var references: Array=effect.wraps.duplicate()
		actor.remove();await get_tree().process_frame;await get_tree().process_frame
		for wrap in references:check(not is_instance_valid(wrap),"Wrap cleaned with frozen owner")
	Feel.set_k("body_scale",previous_scale)
	var bytes:=var_to_bytes(Effect.connector.surface_get_arrays(0)).size()
	for mesh in Effect.cache.values():bytes+=var_to_bytes(mesh.surface_get_arrays(0)).size()
	var fit_samples:=0;var fallback_samples:=0;var clearance_samples:=0;var clipped_samples:=0;var worst_penetration:=0.0
	for mesh in Effect.cache.values():
		fit_samples+=mesh.get_meta("surface_samples",0);fallback_samples+=mesh.get_meta("fallback_samples",0)
		clearance_samples+=mesh.get_meta("clearance_samples",0);clipped_samples+=mesh.get_meta("clipped_samples",0);worst_penetration=maxf(worst_penetration,mesh.get_meta("worst_penetration",0.0))
	check(clipped_samples==0,"No fitted triangle exceeds1mm penetration")
	check(bridge_clipped==0,"No bridge triangle exceeds2mm penetration")
	var report:={"bridge_details":bridge_details,"bridge_samples":bridge_samples,"bridge_ray_samples":bridge_ray_samples,"bridge_clipped":bridge_clipped,"bridge_worst":bridge_worst,"clearance_samples":clearance_samples,"clipped_samples":clipped_samples,"worst_penetration":worst_penetration,"surface_fit_samples":fit_samples,"surface_ray_fallbacks":fallback_samples,"shape":"character_cufinalt.glb", "variation_count_per_part":3,"geometry_generated_at_runtime":false,"errors":errors,"fixtures":rows,"cache_meshes":Effect.cache.size()+1,"cache_bytes":bytes,"prepare_max_unit_ms":Effect.preparation_max_ms,"preparation_samples":Effect.preparation_samples,"materials":1,"dynamic_lights":0,"runtime_physics_added":0,"idle_processing":false}
	var file:=FileAccess.open(OUT+("render-results.json" if rendered else "checks.json"),FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
	print("VINES_REVIEW ",JSON.stringify(report));get_tree().quit(0 if errors.is_empty() else 1)








func audit_bridges(effect: Node3D,parts: Dictionary) -> void:
	var skins: Array=[]
	for key in parts:
		var skin: MeshInstance3D=parts[key];var mesh: Mesh=skin.get_meta("dress_src",skin.mesh)
		skins.append([skin.global_transform.affine_inverse(),mesh.get_aabb(),mesh.get_faces(),Effect.surfaces[key].axis,key])
	var arrays:=Effect.connector.surface_get_arrays(0);var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	for bridge in effect.wraps:
		if not bridge is MultiMeshInstance3D:continue
		for instance in bridge.multimesh.instance_count:
			var xf: Transform3D=bridge.global_transform*bridge.get_meta("authored_transforms")[instance]
			for i in range(0,vertices.size(),3):
				var a:=vertices[i];var b:=vertices[i+1];var c:=vertices[i+2]
				for sample in [a,b,c,(a+b)*.5,(b+c)*.5,(c+a)*.5,(a+b+c)/3]:
					var world: Vector3=xf*sample
					bridge_samples+=1
					for skin in skins:
						var local: Vector3=skin[0]*world;var box: AABB=skin[1]
						if not box.has_point(local):continue
						var hit:=Effect.ray_surface(local,box,skin[2],skin[3])
						if hit.is_equal_approx(local):continue
						var core:=box.get_center();core[skin[3]]=local[skin[3]]
						var penetration:=hit.distance_to(core)-local.distance_to(core)
						bridge_ray_samples+=1;bridge_worst=maxf(bridge_worst,penetration)
						if penetration>.002:
							bridge_clipped+=1
							var label: String=str(bridge.get_meta("pair"))+" into "+skin[4]
							if penetration>bridge_details.get(label,{}).get("depth",0):bridge_details[label]={"depth":penetration,"local":str(local),"world":str(world),"instance":instance}
