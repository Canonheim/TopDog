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
 for i in 50:
  var actor:=Climber.new();actor.climber_id=200+i;add_child(actor);actor.build(Vector2((i%10)*1.8,(i/10)*2.5),self,Wardrobe.CLIMBER);actor.freeze();actors.append(actor)
 CelPass.celify(self)
 camera.size=15;camera.position=Vector3(8.1,6,25);camera.look_at(Vector3(8.1,6,0))
 for actor in actors:effects.append(Effect.attach_owner(actor,false,false))
 var ready:=false
 while not ready:
  ready=true
  for fx in effects:if not fx.get_meta("ready",false):ready=false
  await get_tree().process_frame
 var total:=0;var moving:=0;var web_count:=0
 for fx in effects:
  fx.set_process(false);fx.tick(10);total+=fx.spiders.size();web_count+=fx.webs.size()
  for spider in fx.spiders:if not spider.weaving:moving+=1
 for i in actors.size():
  var offset:=Vector3(-(i%10)*.9,-(i/10)*1.35,0)
  for body in actors[i].bodies.values():body.global_position+=offset;Climber.sync_server(body)
  effects[i].position+=offset
 camera.size=8;camera.position=Vector3(4.05,3.4,25);camera.look_at(Vector3(4.05,3.4,0))
 for fx in effects:fx.hide()
 await sample("no effect baseline")
 for fx in effects:fx.show()
 await sample("stationary A")
 await sample("crawling A")
 await sample("stationary B")
 await sample("crawling B")
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png(OUT+"spiders-50-gpu.png")
 var report={"players":50,"spiders":total,"moving_spiders":moving,"webs":web_count,"resolution":"1920x1080","gpu":RenderingServer.get_video_adapter_name(),"renderer":"Forward+","msaa":get_viewport().msaa_3d,"screen_space_aa":get_viewport().screen_space_aa,"rows":rows,"scope":"isolated 50-player render benchmark, not full match"}
 var f:=FileAccess.open(OUT+"spiders-gpu.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close();get_tree().quit()
