extends Node3D
const Effect=preload("res://tests/deep_freeze_review/freeze.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/deep-freeze/"
var effects: Array=[]
var camera: Camera3D
var rows: Array=[]
const Melon=preload("res://ui3d/watermelon_effect.gd")
func sample(label: String) -> void:
 for frame in 90:await RenderingServer.frame_post_draw
 var values: Array=[]
 for frame in 240:
  if "shine" in label:
   for fx in effects:fx.tick(3.5+fposmod(frame/60.0,.5))
  await RenderingServer.frame_post_draw
  values.append(RenderingServer.viewport_get_measured_render_time_gpu(get_viewport().get_viewport_rid()))
 values.sort()
 var row={"label":label,"median_ms":values[120],"p95_ms":values[228],"max_ms":values[-1],"samples":240}
 rows.append(row);print("GPU_SAMPLE ",JSON.stringify(row))
func enabled(on: bool, mist_on: bool=true) -> void:
 for fx in effects:
  for entry in fx.skins:entry.node.material_override=fx.frost_material if on else entry.original
  for icicle in fx.icicles:icicle.visible=on
  fx.mist.visible=on and mist_on
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
 for actor in actors:
  var fx:=Effect.new();add_child(fx);fx.set_process(false);await fx.setup(actor);fx.tick(5);fx.set_process(true);effects.append(fx)
 camera.size=8;camera.position=Vector3(8.1,6,25);camera.look_at(Vector3(8.1,6,0))
 # Same crowded formation as the earlier GPU test.
 for i in actors.size():
  var offset:=Vector3(-(i%10)*.9,-(i/10)*1.35,0)
  for body in actors[i].bodies.values():body.global_position+=offset;Climber.sync_server(body)
  var fx=effects[i]
  for icicle in fx.icicles:icicle.global_position+=offset
  for site in fx.mist_sites:site.point+=offset
  fx.frost_bottom+=offset.y
 camera.position=Vector3(4.05,3.4,25);camera.look_at(Vector3(4.05,3.4,0))
 enabled(false);await sample("baseline A")
 enabled(true);await sample("50 Deep Freeze")
 enabled(false)
 # Hold representative flight snapshots so GPU sampling excludes spawn CPU and timer cleanup.
 Engine.time_scale=.001
 for count in [1,50]:
  var bursts: Array=[]
  for i in count:
   var root:=Melon.burst(camera);bursts.append(root)
   for flight in root.get_children():flight.set_process(false)
  var previous:=0.0
  for moment in [.4,.9,1.5]:
   for root in bursts:
    for flight in root.get_children():
     for step in int(round((moment-previous)*60)):flight._process(1.0/60.0)
   previous=moment
   await sample("%d Watermelons at %.1fs"%[count,moment])
   if moment==.9:
    get_viewport().get_texture().get_image().save_png(OUT+"watermelon-%d.png"%count)
  for root in bursts:root.free()
 enabled(false);await sample("baseline B")
 var report={"players":50,"resolution":"1920x1080","gpu":RenderingServer.get_video_adapter_name(),"renderer":"Forward+","msaa":get_viewport().msaa_3d,"screen_space_aa":get_viewport().screen_space_aa,"rows":rows,"scope":"isolated 50-player render benchmark, not full match"}
 var f:=FileAccess.open(OUT+"watermelon-gpu.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close();get_tree().quit()
