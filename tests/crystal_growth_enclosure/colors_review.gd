extends Node3D
const Effect=preload("res://tests/crystal_growth_enclosure/effect.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/crystal-growth-enclosure/"
func _ready() -> void:
 get_window().size=Vector2i(1200,1000);get_window().content_scale_size=Vector2i(1200,1000)
 var env:=WorldEnvironment.new();env.environment=Environment.new();env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("202b2a");env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.environment.ambient_light_color=Color.WHITE;env.environment.ambient_light_energy=.65;add_child(env)
 var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-30,-25,0);add_child(sun)
 var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=5.5;camera.position=Vector3(0,2.25,8);add_child(camera)
 var actors: Array=[];var effects: Array=[]
 for i in 6:
  var actor:=Climber.new();actor.climber_id=820+i;add_child(actor);actor.build(Vector2((i%3-1)*1.85,2.5 if i<3 else 0.0),self,Wardrobe.CLIMBER);actor.freeze();actors.append(actor)
 CelPass.celify(self);CelPass.add_outline_pass(self)
 await Effect.prepare()
 for i in 6:
  var fx=Effect.attach(actors[i],true)
  while not fx.initialized:await get_tree().process_frame
  fx.set_process(false);fx.shade_index=i;fx.shade_uv=Effect.SHADES.get_meta("uvs")[i]
  for node in fx.batches:
   node.set_instance_shader_parameter("shade_uv",fx.shade_uv);node.set_instance_shader_parameter("tint_boost",1.6 if i in [4,5] else (1.2 if i==1 else 1.0))
  for entry in fx.skins:
   entry.node.set_instance_shader_parameter("shade_uv",fx.shade_uv);entry.node.set_instance_shader_parameter("tint_boost",1.6 if i in [4,5] else (1.2 if i==1 else 1.0))
  fx.aura.set_instance_shader_parameter("shade_uv",fx.shade_uv)
  effects.append(fx)
 var ui:=CanvasLayer.new();add_child(ui)
 for i in 6:
  var label:=Label.new();label.text=Effect.SHADE_NAMES[i];label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_font_size_override("font_size",26)
  label.position=Vector2(200+(i%3-1)*336-150,25 if i<3 else 480)
  label.position.x=600+(i%3-1)*336-150
  label.size=Vector2(300,40);ui.add_child(label)
 DirAccess.make_dir_recursive_absolute(OUT+"color-frames")
 for frame in 81:
  for fx in effects:fx.tick(frame/20.0)
  await get_tree().process_frame;await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png(OUT+"color-frames/%03d.png"%frame)
 print("ALL_SIX_SHADES_RENDERED without enclosure")
 for actor in actors:actor.remove()
 await get_tree().process_frame;get_tree().quit()
