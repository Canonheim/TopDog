extends Node3D
const Effect=preload("res://ui3d/spiders_effect.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/deep-freeze/"
var effects: Array=[]
var camera: Camera3D
var rows: Array=[]
func sample(label: String) -> void:
 for frame in 90:await RenderingServer.frame_post_draw
 var values: Array=[];var cpu: Array=[]
 for frame in 300:
  var begin:=Time.get_ticks_usec()
  if "crawling" in label:
   for fx in effects:fx._process(1.0/60.0)
  cpu.append((Time.get_ticks_usec()-begin)/1000.0)
  await RenderingServer.frame_post_draw
  values.append(RenderingServer.viewport_get_measured_render_time_gpu(get_viewport().get_viewport_rid()))
 values.sort();cpu.sort()
 var row={"label":label,"gpu_median_ms":values[150],"gpu_p95_ms":values[285],"cpu_update_median_ms":cpu[150],"cpu_update_p95_ms":cpu[285],"cpu_update_max_ms":cpu[-1],"samples":300}
 rows.append(row);print("SPIDER_SAMPLE ",JSON.stringify(row))
func _ready() -> void:
 get_window().size=Vector2i(1920,1080);get_window().content_scale_size=Vector2i(1920,1080)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED);Engine.max_fps=0
 RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(),true)
 var env:=WorldEnvironment.new();env.environment=Environment.new();env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("202b2a");env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.environment.ambient_light_color=Color.WHITE;env.environment.ambient_light_energy=.45;add_child(env)
 var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-30,-25,0);add_child(sun)
 camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;add_child(camera)
 var actors: Array=[]
 for i in 1:
  var actor:=Climber.new();actor.climber_id=200+i;add_child(actor);actor.build(Vector2((i%10)*1.8,(i/10)*2.5),self,Wardrobe.CLIMBER);actor.freeze();actors.append(actor)
 CelPass.celify(self)
 camera.size=15;camera.position=Vector3(8.1,6,25);camera.look_at(Vector3(8.1,6,0))
 for actor in actors:effects.append(Effect.attach_owner(actor,false,false))
 var ready:=false
 while not ready:
  ready=true
  for fx in effects:if not fx.get_meta("ready",false):ready=false
  await get_tree().process_frame
 var fx=effects[0];fx.set_process(false);fx.tick(10)
 camera.size=2.65;camera.position=Vector3(0,1.1,25);camera.look_at(Vector3(0,1.1,0))
 # Align the independently randomized routes at their joins for this review only.
 # Paths and geometry remain the actual generated ones.
 for data in fx.spiders:
  if not data.weaving:data.offset=.91
 var folder:=OUT+"spider-loop-preview"
 DirAccess.make_dir_recursive_absolute(folder)
 for frame in 151:
  fx.tick(frame/25.0)
  for web in fx.webs:web.visible_instance_count=-1
  for data in fx.spiders:
   data.node.visible=true
   if data.weaving:data.node.visible=false
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png(folder+"/%03d.png"%frame)
 print("LOOP_PREVIEW_COMPLETE");get_tree().quit()
