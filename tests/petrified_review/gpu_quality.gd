extends Node3D
const Gold=preload("res://tests/petrified_review/effect.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/petrified/"
var actors: Array=[]
var effects: Array=[]
var rows: Array=[]
func sample(label: String, count: int=180) -> void:
 var gpu: Array=[];var frames: Array=[];var previous:=Time.get_ticks_usec()
 for frame in count:
  await RenderingServer.frame_post_draw
  var now:=Time.get_ticks_usec();frames.append((now-previous)/1000.0);previous=now
  gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(get_viewport().get_viewport_rid()))
 gpu.sort();frames.sort()
 var row={"label":label,"gpu_median_ms":gpu[count/2],"gpu_p95_ms":gpu[int(count*.95)],"gpu_max_ms":gpu[-1],"frame_median_ms":frames[count/2],"frame_p95_ms":frames[int(count*.95)],"frame_max_ms":frames[-1]}
 rows.append(row);print("PETRIFIED_GPU ",JSON.stringify(row))
func _ready() -> void:
 get_window().size=Vector2i(1920,1080);get_window().content_scale_size=Vector2i(1920,1080)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED);Engine.max_fps=0
 RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(),true)
 var env:=WorldEnvironment.new();env.environment=Environment.new();env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("202b2a");env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.environment.ambient_light_color=Color.WHITE;env.environment.ambient_light_energy=.45;add_child(env)
 var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-30,-25,0);add_child(sun)
 var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;add_child(camera);camera.size=15;camera.position=Vector3(8.1,6,25);camera.look_at(Vector3(8.1,6,0))
 for i in 50:
  var actor:=Climber.new();actor.climber_id=600+i;add_child(actor);actor.build(Vector2((i%10)*1.8,(i/10)*2.5),self,Wardrobe.CLIMBER);actor.freeze();actors.append(actor)
 CelPass.celify(self);CelPass.add_outline_pass(self)
 await Gold.prepare()
 for i in 90:await RenderingServer.frame_post_draw
 await sample("50 bodies baseline")
 var cpu: Array=[]
 for count in [1,3,50]:
  var batch:=Time.get_ticks_usec()
  while effects.size()<count:
   var fx=Gold.attach(actors[effects.size()],true,effects.is_empty());effects.append(fx);cpu.append(fx.setup_us/1000.0)
  print("PETRIFIED_BATCH ",count," total_ms ",(Time.get_ticks_usec()-batch)/1000.0)
  await sample(str(count)+" petrified including first draw")
  var deadline:=Time.get_ticks_msec()+30000
  while effects.any(func(fx):return not fx.grass_ready) and Time.get_ticks_msec()<deadline:
   await get_tree().process_frame
  assert(effects.all(func(fx):return fx.grass_ready))
  for fx in effects:fx.tick(100)
  await sample(str(count)+" petrified settled")
 # Exercise a real local grab against a frozen body, including ignored repeat.
 var grabber:=Climber.new();grabber.climber_id=999;add_child(grabber);grabber.build(Vector2(0,1),self,Wardrobe.CLIMBER)
 var target: RigidBody3D=actors[0].bodies["chest"]
 grabber.attach(0,target)
 assert(effects[0].debris.bursts==1)
 grabber.release(0);grabber.attach(0,target)
 assert(effects[0].debris.bursts==1)
 grabber.release(0)
 effects[0].debris.step(2)
 grabber.attach(0,target)
 assert(effects[0].debris.bursts==2)
 grabber.release(0);grabber.remove()
 for fx in effects:fx.debris.step(2)
 var burst_max:=0
 for fx in effects:
  assert(fx.on_grab(fx.skins[3].node.global_position))
  burst_max=maxi(burst_max,fx.debris.burst_us)
 await sample("50 simultaneous grab reactions")
 for fx in effects:fx.debris.step(2)
 print("PETRIFIED_GRABS real attach passed; max burst us ",burst_max)
 for normal in [Vector3.UP,Vector3.DOWN,Vector3.LEFT,Vector3.RIGHT,Vector3.FORWARD,Vector3.BACK]:
  var basis:=Gold.surface_basis(normal)
  assert(basis.y.dot(normal)>.999)
  assert(absf(basis.determinant()-1)<.001)
 print("PETRIFIED_FLOWER orientation six axes passed")
 var tufts:=0
 for fx in effects:
  assert(fx.grass.size()<=22)
  print("GRASS_COUNT ",fx.grass.size())
  for tuft in fx.grass:
   assert(tuft.gap<=.018 and tuft.patch>=.46)
   tufts+=1
 print("PETRIFIED_GRASS tufts ",tufts," shared search max us ",Gold.grass_global_max_us)
 var seeds: Dictionary={}
 var flowers:=0
 for fx in effects:
  seeds[fx.stone_seed]=true
  if is_instance_valid(fx.flower):
   flowers+=1
   assert(fx.flower.get_meta("crack_gap")<=.008)
 print("PETRIFIED_VARIATION seeds ",seeds.size()," flowers ",flowers)
 assert(seeds.size()==50)
 var visible:=0
 for fx in effects:
  if not fx.is_processing():visible+=1
 print("PETRIFIED_DISTANT_THROTTLED ",visible)
 for fx in effects:fx.free()
 await get_tree().process_frame
 await sample("50 bodies baseline after cleanup")
 cpu.sort()
 var report={"gpu":RenderingServer.get_video_adapter_name(),"resolution":"1920x1080","renderer":"Forward+","scope":"isolated 50-body scene with 1,3,50 active Petrified; engine first draw measured, driver cache not cleared","rows":rows,"setup_median_ms":cpu[25],"setup_max_ms":cpu[-1],"geometry_readbacks":0,"grass_tufts":tufts,"grass_search_frame_max_ms":Gold.grass_global_max_us/1000.,"settled_processing_stopped":visible,"burst_max_ms":burst_max/1000.0}
 var file=FileAccess.open(OUT+"gpu-quality.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
 for actor in actors:actor.remove()
 await get_tree().process_frame
 get_tree().quit()
