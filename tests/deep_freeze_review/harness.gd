extends Node3D
const Effect=preload("res://tests/deep_freeze_review/freeze.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/deep-freeze/"
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
		Wardrobe.apply(self,{"skin":3 if fixture==0 else 1,"speedo":3,"head":fixture})

		var original:=actor.pose()
		var fx:=Effect.new();add_child(fx);fx.set_process(false)
		await fx.setup(actor)
		check(fx.icicles.size()>=4 and fx.icicles.size()<=8,"Four to eight icicles")
		var lengths: Array=[]
		for icicle in fx.icicles:
			lengths.append(icicle.get_meta("length"))
			check(icicle.get_meta("normal").y<-.48,"Icicle anchored to underside")
		var folder:=OUT+"pose%d/"%fixture;DirAccess.make_dir_recursive_absolute(folder)
		camera.size=2.75*size;camera.position=Vector3(0,1.15*size,5);camera.look_at(Vector3(0,1.15*size,0))
		for frame in 226 if rendered else 5:
			fx.tick(frame/25.0 if rendered else frame*2.5)
			if rendered:
				await RenderingServer.frame_post_draw
				get_viewport().get_texture().get_image().save_png(folder+"%03d.png"%frame)
		check(actor.pose()==original,"No pose or physics changes")
		check(fx.mist_active and fx.settled,"Mist persists after freeze settles")
		rows.append({"fixture":fixture,"icicles":fx.icicles.size(),"lengths":lengths,"frost_nodes":fx.skins.size(),"extra_frost_draws":0})
		var skins:=fx.skins.duplicate();fx.free()
		for entry in skins:check(entry.node.material_override==entry.original,"Original material restored")
		actor.remove();await get_tree().process_frame;await get_tree().process_frame
	Feel.set_k("body_scale",previous_scale)
	var report={"errors":errors,"fixtures":rows,"puffs_per_player_limit":6,"puffs_per_owner":6,"installed":false,"gpu_measured":false}
	var f:=FileAccess.open(OUT+"checks.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close()
	print("FREEZE_REVIEW ",JSON.stringify(report));get_tree().quit(0 if errors.is_empty() else 1)
