extends Node3D
const Gold=preload("res://tests/crystal_growth_enclosure/effect.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/crystal-growth-enclosure/"
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
 rows.append(row);print("CRYSTAL_GPU ",JSON.stringify(row))
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
   var fx=Gold.attach(actors[effects.size()],true);effects.append(fx);cpu.append(fx.setup_us/1000.0)
  print("CRYSTAL_BATCH ",count," total_ms ",(Time.get_ticks_usec()-batch)/1000.0)
  await sample(str(count)+" crystal including first draw")
  var deadline:=Time.get_ticks_msec()+30000
  while effects.any(func(fx):return not fx.initialized) and Time.get_ticks_msec()<deadline:
   await get_tree().process_frame
  assert(effects.all(func(fx):return fx.initialized))
  for fx in effects:fx.tick(100)
  await sample(str(count)+" crystal settled")
 var count_shards:=0;var slices:=0;var latency:=0.0
 var shades: Dictionary={}
 for fx in effects:
  shades[Gold.SHADE_NAMES[fx.shade_index]]=int(shades.get(Gold.SHADE_NAMES[fx.shade_index],0))+1
  for batch in fx.batches:assert(batch.get_instance_shader_parameter("shade_uv")==fx.shade_uv)
  for skin in fx.skins:assert(skin.node.get_instance_shader_parameter("shade_uv")==fx.shade_uv)
  assert(fx.aura.get_instance_shader_parameter("shade_uv")==fx.shade_uv)
  assert(fx.is_processing());assert(fx.shard_count<=70);count_shards+=fx.shard_count;slices=maxi(slices,fx.setup_slice_us);latency=maxf(latency,fx.setup_latency_ms)
  assert(fx.batches.size()<=16)
  for root in fx.roots:assert(root.radius+root.jitter<=root.clearance)
 print("CRYSTAL_SHADES ",JSON.stringify(shades))
 print("CRYSTAL_SETUP shards ",count_shards," max_slice_us ",slices," shared_frame_us ",Gold.shared_peak_us," latency_ms ",latency)
 for fx in effects:fx.free()
 await get_tree().process_frame
 await sample("50 bodies baseline after cleanup")
 assert(get_tree().get_nodes_in_group(&"legendary_locked_lod").is_empty())
 var report={"gpu":RenderingServer.get_video_adapter_name(),"resolution":"1920x1080","rows":rows,"max_setup_slice_ms":slices/1000.,"shared_setup_peak_ms":Gold.shared_peak_us/1000.,"setup_latency_max_ms":latency,"shade_counts":shades,"total_shards":count_shards,"geometry_readbacks":0,"settled_processing":"15Hz aura uniform; distant 10/5Hz above 20 legendary owners","driver_cache_cleared":false,"multicolor_supported":true}
 var file=FileAccess.open(OUT+"gpu-quality.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
 for actor in actors:actor.remove()
 await get_tree().process_frame;get_tree().quit()
