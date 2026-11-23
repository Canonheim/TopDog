extends Node3D
const Effect=preload("res://tests/petrified_review/effect.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/petrified/"
func _ready() -> void:
 get_window().size=Vector2i(600,720);get_window().content_scale_size=Vector2i(600,720)
 var env:=WorldEnvironment.new();env.environment=Environment.new();env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("202b2a");env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.environment.ambient_light_color=Color.WHITE;env.environment.ambient_light_energy=.65;add_child(env)
 var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-30,-25,0);add_child(sun)
 var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=2.7;camera.position=Vector3(0,1,5);add_child(camera)
 var actor:=Climber.new();actor.climber_id=800;add_child(actor);actor.build(Vector2.ZERO,self,Wardrobe.CLIMBER);actor.freeze()
 CelPass.celify(self);CelPass.add_outline_pass(self)
 await Effect.prepare()
 var fx=Effect.attach(actor,true,true)
 for frame in 35:await get_tree().process_frame
 while not fx.grass_ready:await get_tree().process_frame
 print("GRASS_REVIEW tufts ",fx.grass.size()," frame budget us ",Effect.grass_global_max_us)
 fx.set_process(false)
 DirAccess.make_dir_recursive_absolute(OUT+"reaction-frames")
 for i in 97:
  fx.tick(i/12.0)
  if i in [48,66]:
   var skin: MeshInstance3D=fx.skins[4 if i==48 else 8].node
   assert(fx.on_grab((skin.global_transform*skin.mesh.get_aabb()).get_center()))
   fx.debris.set_process(false)
  if i==50:assert(not fx.on_grab(actor.bodies.chest.global_position))
  if i>=48:fx.debris.step((i-(66 if i>=66 else 48))/12.0)
  await get_tree().process_frame
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png(OUT+"reaction-frames/%03d.png"%i)
 print("PETRIFIED_REACTIONS_RENDERED bursts ",fx.debris.bursts," setup_us ",fx.setup_us)
 actor.remove();await get_tree().process_frame;get_tree().quit()
