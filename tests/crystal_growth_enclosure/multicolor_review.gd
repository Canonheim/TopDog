extends Node3D
const Effect=preload("res://tests/crystal_growth_enclosure/effect.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/crystal-growth-enclosure/"
func _ready() -> void:
 get_window().size=Vector2i(600,720);get_window().content_scale_size=Vector2i(600,720)
 var env:=WorldEnvironment.new();env.environment=Environment.new();env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("202b2a");env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.environment.ambient_light_color=Color.WHITE;env.environment.ambient_light_energy=.65;add_child(env)
 var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-30,-25,0);add_child(sun)
 var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=2.7;camera.position=Vector3(0,1,5);add_child(camera)
 var actor:=Climber.new();actor.climber_id=800;add_child(actor);actor.build(Vector2.ZERO,self,Wardrobe.CLIMBER);actor.freeze()
 CelPass.celify(self);CelPass.add_outline_pass(self)
 await Effect.prepare()
 var fx=Effect.attach(actor,true)
 while not fx.initialized:await get_tree().process_frame
 fx.set_process(false)
 fx.shade_index=7;fx.shade_uv=Effect.SHADES.get_meta("uvs")[7]
 for node in fx.batches:
  node.set_instance_shader_parameter("multicolor",1.0);node.set_instance_shader_parameter("shade_uv",fx.shade_uv);node.set_instance_shader_parameter("tint_boost",1.2)
 for entry in fx.skins:
  entry.node.set_instance_shader_parameter("multicolor",1.0);entry.node.set_instance_shader_parameter("shade_uv",fx.shade_uv);entry.node.set_instance_shader_parameter("tint_boost",1.2)
 fx.aura.set_instance_shader_parameter("multicolor",1.0);fx.aura.set_instance_shader_parameter("shade_uv",fx.shade_uv)
 DirAccess.make_dir_recursive_absolute(OUT+"multicolor-frames")
 for i in 121:
  fx.tick(i/24.0)
  await get_tree().process_frame
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png(OUT+"multicolor-frames/%03d.png"%i)
 print("CRYSTAL_RENDERED shards ",fx.shard_count," batches ",fx.batches.size()," slice_us ",fx.setup_slice_us," latency_ms ",fx.setup_latency_ms)
 actor.remove();await get_tree().process_frame;get_tree().quit()
