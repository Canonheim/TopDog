extends Node3D
const Effect=preload("res://ui3d/crystal_growth/effect.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/crystal-growth-enclosure/seven-finished-frames/"
func _ready() -> void:
 get_window().size=Vector2i(1440,1000);get_window().content_scale_size=Vector2i(1440,1000)
 var env:=WorldEnvironment.new();env.environment=Environment.new();env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("202b35");env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.environment.ambient_light_color=Color.WHITE;env.environment.ambient_light_energy=.65;add_child(env)
 var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-30,-25,0);add_child(sun)
 var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=5.6;camera.position=Vector3(0,2.25,8);add_child(camera)
 var names=["Ruby","Sapphire","Emerald","Quartz","Rose Quartz","Topaz","Amethyst"]
 var shades=[2,1,5,0,3,4,6];var actors: Array=[];var effects: Array=[]
 for i in 7:
  var x: float=(i%4-1.5)*1.9 if i<4 else (i-5)*1.9
  var actor:=Climber.new();actor.climber_id=850+i;add_child(actor);actor.build(Vector2(x,2.5 if i<4 else 0.0),self,Wardrobe.CLIMBER);actor.freeze();actors.append(actor)
 CelPass.celify(self);Wardrobe.apply(self,Wardrobe.clean({"head":0,"skin":0,"speedo":0}));CelPass.add_outline_pass(self)
 await Effect.prepare()
 for i in 7:
  var fx=Effect.attach(actors[i],true,shades[i])
  while not fx.initialized:await get_tree().process_frame
  fx.set_process(false)
  for batch in fx.batches:assert(is_equal_approx(batch.get_instance_shader_parameter("color_strength"),1.0 if i==6 else 1.1))
  effects.append(fx)
 var ui:=CanvasLayer.new();add_child(ui)
 for i in 7:
  var label:=Label.new();label.text=names[i];label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_font_size_override("font_size",26)
  var x: float=(i%4-1.5)*1.9 if i<4 else (i-5)*1.9
  label.position=Vector2(720+x*(1000.0/5.6)-160,45 if i<4 else 490);label.size=Vector2(320,40);ui.add_child(label)
 DirAccess.make_dir_recursive_absolute(OUT)
 for frame in 101:
  for fx in effects:fx.tick(frame/20.0)
  await get_tree().process_frame;await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png(OUT+"%03d.png"%frame)
 print("SEVEN_FINISHED_RENDERED; quartz contrast; six spike colors +10%; Amethyst unchanged")
 for actor in actors:actor.remove()
 await get_tree().process_frame;get_tree().quit()
