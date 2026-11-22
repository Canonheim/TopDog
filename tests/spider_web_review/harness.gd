extends Node3D
const Effect=preload("res://tests/spider_web_review/webs.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/spider-webs/"
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
	get_viewport().msaa_3d=Viewport.MSAA_4X;get_window().size=Vector2i(960,720)
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
	for fixture in 4:
		Feel.set_k("body_scale",previous_scale*(.85 if fixture==0 else 1.0))
		var actor:=Climber.new();actor.climber_id=90+fixture;add_child(actor)
		actor.build(Vector2.ZERO,self,Wardrobe.CLIMBER)
		var fixture_joints: Dictionary=actor.joints.duplicate(true)
		var size:=actor.body_scale
		# Two explicit frozen fixture poses, before the cosmetic is attached.
		var initial: Dictionary={}
		for key in actor.bodies: initial[key]=actor.bodies[key].global_transform
		var rotations: Dictionary={"arm_l_up":.65,"arm_l_lo":1.1,"arm_r_up":-.6,"arm_r_lo":-1.05}
		if fixture==1: rotations={"arm_l_up":-1.0,"arm_l_lo":-1.4,"arm_r_up":-.65,"arm_r_lo":-1.1,"leg_l_up":-.4,"leg_l_lo":-.35,"foot_l":-.2}
		for joint_name in Climber.Layout.JOINTS:
			var joint: Dictionary=Climber.Layout.JOINTS[joint_name]
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
		Wardrobe.apply(self,{"skin":3 if fixture==0 else 1,"speedo":3,"head":fixture%3})

		var tower_nodes: Array=[]
		var layouts: Array=[]
		if fixture%2==0:layouts=[[Vector3(.73*size,.72*size,0),Vector3(.16*size,1.45*size,.36)]]
		else:layouts=[[Vector3(-.62*size,.62*size,0),Vector3(.16*size,1.25*size,.36)],[Vector3(0,-.03*size,0),Vector3(1.45*size,.12*size,.36)]]
		for layout in layouts:
			var body:=StaticBody3D.new();body.collision_layer=1;body.collision_mask=0;body.position=layout[0];add_child(body)
			var shape:=CollisionShape3D.new();var box:=BoxShape3D.new();box.size=layout[1];shape.shape=box;body.add_child(shape)
			var mesh:=MeshInstance3D.new();var box_mesh:=BoxMesh.new();box_mesh.size=layout[1];mesh.mesh=box_mesh;body.add_child(mesh);CelPass.paint(mesh,Color("6f7780"));tower_nodes.append(body)
		await get_tree().physics_frame

		var original:=actor.pose()
		var effect:=Effect.new();add_child(effect);effect.set_process(false)
		var begin:=Time.get_ticks_usec();await effect.setup(actor)
		var setup_ms:=(Time.get_ticks_usec()-begin)/1000.0
		check(effect.spiders.size()>=4,"Surface crawling spiders")
		for mesh in Effect.spider_meshes:check(mesh.get_meta("leg_count")==8 and is_equal_approx(mesh.get_meta("leg_length_scale"),.9),"Eight legs shortened ten percent")
		check(effect.webs.size()==mini(2,int(effect.get_meta("viable_pockets"))),"Exactly two when available")
		check(actor.pose()==original,"Frozen pose unchanged")
		var folder:=OUT+"pose%d/"%fixture;DirAccess.make_dir_recursive_absolute(folder)
		camera.size=2.5*size;camera.position=Vector3(0,1.1*size,5);camera.look_at(Vector3(0,1.1*size,0))
		for frame in 176 if rendered else 3:
			effect.tick(frame/25.0 if rendered else frame*3.5)
			if rendered:
				await RenderingServer.frame_post_draw
				get_viewport().get_texture().get_image().save_png(folder+"%03d.png"%frame)
		rows.append({"fixture":fixture,"webs":effect.webs.size(),"spiders":effect.spiders.size(),"signature":effect.signature,"setup_ms":setup_ms,"tower_webs":effect.tower_webs,"tower_queries":effect.tower_queries,"viable_pockets":effect.get_meta("viable_pockets")})
		for tower in tower_nodes:tower.queue_free()
		effect.queue_free();actor.remove();await get_tree().process_frame;await get_tree().process_frame
	Feel.set_k("body_scale",previous_scale)
	var report={"errors":errors,"fixtures":rows,"installed":false}
	var file:=FileAccess.open(OUT+"checks.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
	print("SPIDER_REVIEW ",JSON.stringify(report));get_tree().quit(0 if errors.is_empty() else 1)
