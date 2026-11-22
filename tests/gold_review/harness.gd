extends Node3D
const Effect=preload("res://tests/gold_review/gold.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/gold/"
var camera: Camera3D
func _ready() -> void:
 get_window().size=Vector2i(1920,1080);get_window().content_scale_size=Vector2i(1920,1080)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED);Engine.max_fps=0
 RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(),true)
 var env:=WorldEnvironment.new();env.environment=Environment.new();env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("202b2a");env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.environment.ambient_light_color=Color.WHITE;env.environment.ambient_light_energy=.45;add_child(env)
 var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-30,-25,0);add_child(sun)
 camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;add_child(camera)
 var actor:=Climber.new();actor.climber_id=190;add_child(actor);actor.build(Vector2.ZERO,self,Wardrobe.CLIMBER);actor.freeze()
 CelPass.celify(self);Wardrobe.apply(self,{"skin":3,"speedo":3,"head":0})
 Effect.prepare()
 var fx:=Effect.new();add_child(fx);fx.set_process(false)
 camera.size=2.8;camera.position=Vector3(0,1.1,5);camera.look_at(Vector3(0,1.1,0))
 DirAccess.make_dir_recursive_absolute(OUT+"frames")
 for frame in 176:
  if frame==25:fx.setup(actor)
  if frame>=25:fx.tick((frame-25)/25.0)
  var angle:=sin(frame/175.0*PI)*.22
  camera.position=Vector3(sin(angle)*5,1.1,cos(angle)*5);camera.look_at(Vector3(0,1.1,0))
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png(OUT+"frames/%03d.png"%frame)
 assert(fx.stars.size()==3)
 var saved:=fx.skins.duplicate();fx.free()
 for entry in saved:assert(entry.node.material_override==entry.original)
 print("GOLD_REVIEW_PASS: atomic gold, 3 stars, original materials restored");get_tree().quit()
