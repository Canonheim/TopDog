extends Node3D
const Loader=preload("res://game/match_effect_preloader.gd")
const Pickup=preload("res://game/cosmetic_pinata.gd")
var rows: Array=[]
func sample(label: String, seconds: float) -> void:
 var gpu: Array=[];var frames: Array=[];var previous:=Time.get_ticks_usec();var deadline:=previous+int(seconds*1000000)
 while Time.get_ticks_usec()<deadline:
  await RenderingServer.frame_post_draw
  var now:=Time.get_ticks_usec();frames.append((now-previous)/1000.);previous=now
  gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(get_viewport().get_viewport_rid()))
 frames.sort();gpu.sort()
 var row={"label":label,"frame_median_ms":frames[frames.size()/2],"frame_p95_ms":frames[int(frames.size()*.95)],"frame_max_ms":frames[-1],"gpu_median_ms":gpu[gpu.size()/2],"gpu_max_ms":gpu[-1]}
 rows.append(row);print("PINATA_FRAME ",JSON.stringify(row))
func _ready() -> void:
 get_window().size=Vector2i(1920,1080);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED);Engine.max_fps=0
 RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(),true)
 var env:=WorldEnvironment.new();env.environment=Environment.new();env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("202b2a");add_child(env)
 var camera:=Camera3D.new();camera.position=Vector3(0,1,8);add_child(camera)
 var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-30,-25,0);add_child(sun)
 var actors: Array=[]
 for i in 50:
  var actor:=Climber.new();actor.climber_id=500+i;add_child(actor);actor.build(Vector2((i%10-5)*1.8,(i/10-2)*2.3),self,Wardrobe.CLIMBER);actor.freeze();actors.append(actor)
 CelPass.celify(self);CelPass.add_outline_pass(self)
 var job:=Loader.new();add_child(job);job.start([{"appearance":{"effect":"pickles"}}],false)
 var prep: Dictionary=await job.completed
 assert(prep.errors.is_empty());job.queue_free();await get_tree().process_frame
 await sample("50-body baseline",.5)
 var timings: Array=[]
 for count in [1,1,3]:
  var pickups: Array=[]
  var tick:=Time.get_ticks_usec()
  for i in count:
   var pickup:=Pickup.new();pickup.rarity=4;pickup.contact_enabled=false;pickup.position=Vector3((i-1)*1.5,1,1);add_child(pickup);pickups.append(pickup)
  var spawn_ms: float=(Time.get_ticks_usec()-tick)/1000.
  await sample(str(count)+" pickup spawn/idle",.4)
  var before:=Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
  tick=Time.get_ticks_usec()
  for pickup in pickups:pickup.collect()
  var collect_ms: float=(Time.get_ticks_usec()-tick)/1000.
  var new_nodes:=Performance.get_monitor(Performance.OBJECT_NODE_COUNT)-before
  await sample(str(count)+" collection through cleanup",2.8)
  timings.append({"count":count,"spawn_ms":spawn_ms,"collect_ms":collect_ms,"collection_new_nodes":new_nodes})
  for pickup in pickups:assert(not is_instance_valid(pickup))
 var result={"gpu":RenderingServer.get_video_adapter_name(),"resolution":"1920x1080","scope":"50 bodies, rendered preload, first/repeated/three simultaneous red Piñatas; driver cache retained","preload":prep,"timings":timings,"rows":rows}
 var f:=FileAccess.open("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/match-preload/pinata-audit.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));f.close()
 print("PINATA_AUDIT ",JSON.stringify(timings))
 for actor in actors:actor.remove()
 await get_tree().process_frame;get_tree().quit()
