extends Node
## Match-scoped barrier job: only equipped effects, immutable render warmup, no live bursts.
signal completed(report: Dictionary)
const Prep=preload("res://ui3d/lock_effect_preparation.gd")
const Pickup=preload("res://game/cosmetic_pinata.gd")
var report: Dictionary={"effects":[],"errors":[],"max_unit_ms":0.0,"gpu_samples":0,"pinata_ms":0.0}
var view: SubViewport
var camera: Camera3D
var label: Label
var overlay: CanvasLayer
var cancelled:=false
var started:=0
static var rendered: Dictionary={}
static var pinata_rendered: Dictionary={}
static func selected(roster: Array) -> Array[String]:
 var ids: Array[String]=[]
 for row in roster:
  var id: String=Wardrobe.clean(row.get("appearance",{})).effect
  if not ids.has(id):ids.append(id)
 ids.sort()
 return ids
func start(roster: Array, show_ui:=true) -> void:
 started=Time.get_ticks_msec()
 if show_ui:
  overlay=CanvasLayer.new();overlay.layer=100;add_child(overlay)
  var bg:=ColorRect.new();bg.color=Color(0.025,.035,.04,.94);bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);overlay.add_child(bg)
  label=Label.new();label.text="Preparing match…";label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);bg.add_child(label)
 report.effects=selected(roster)
 await get_tree().process_frame
 view=SubViewport.new();view.size=Vector2i(64,64);view.own_world_3d=true;view.msaa_3d=get_viewport().msaa_3d;add_child(view)
 camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=3;camera.position=Vector3(0,0,5);view.add_child(camera)
 var sun:=DirectionalLight3D.new();view.add_child(sun)
 for id in report.effects:
  if cancelled:return
  if is_instance_valid(label):label.text="Preparing match… %d / %d" % [report.effects.find(id)+1,report.effects.size()+1]
  while not Prep.is_prepared(id):
   if cancelled:return
   if Time.get_ticks_msec()-started>90000 or Prep.failed_effects.has(id):
    report.errors.append("Could not prepare "+id);finish();return
   var tick:=Time.get_ticks_usec()
   Prep.prepare_step(id)
   report.max_unit_ms=maxf(report.max_unit_ms,(Time.get_ticks_usec()-tick)/1000.0)
   await get_tree().process_frame
  var render_key: String=str(id)+":"+str(view.msaa_3d)
  if not rendered.has(render_key):
   await warm_effect(id)
   if cancelled:return
   if not report.errors.is_empty():finish();return
   rendered[render_key]=true
 var pinata_key:=str(view.msaa_3d)
 if not pinata_rendered.has(pinata_key):
  if is_instance_valid(label):label.text="Preparing match… Piñata"
  # Five rarity styles plus collection pipelines. Silent, separate world, never a live pickup.
  for rarity in 5:
   var tick:=Time.get_ticks_usec()
   var pickup:=Pickup.new();pickup.contact_enabled=false;pickup.monitoring=false;pickup.rarity=rarity
   view.add_child(pickup)
   report.pinata_ms=maxf(report.pinata_ms,(Time.get_ticks_usec()-tick)/1000.0)
   # Explicitly draw normal sized particles and ribbons, not subpixel primitives.
   pickup.burst_root.show();pickup.burst_root.scale=Vector3.ONE
   for child in pickup.burst_root.get_children():
    if child is CPUParticles3D:child.emitting=true
    elif child is Pickup.Spark:
     child.ribbon.visible_instance_count=1
     child.ribbon.set_instance_transform(0,Transform3D(Basis.IDENTITY.scaled(Vector3(.1,.2,1)),Vector3.ZERO))
   await frames(5)
   if cancelled:return
   pickup.free()
   await get_tree().process_frame
  pinata_rendered[pinata_key]=true
 finish()
func frames(count: int) -> void:
 for i in count:
  if cancelled:return
  if DisplayServer.get_name()=="headless":await get_tree().process_frame
  else:await RenderingServer.frame_post_draw
func gather(value: Variant, meshes: Array, scenes: Array) -> void:
 if value is Mesh:
  if not meshes.has(value):meshes.append(value)
 elif value is PackedScene:
  if not scenes.has(value):scenes.append(value)
 elif value is Dictionary:
  for item in value.values():gather(item,meshes,scenes)
 elif value is Array:
  for item in value:gather(item,meshes,scenes)
func warm_effect(id: String) -> void:
 var script: Script=Prep.effect_script(id)
 var meshes: Array=[];var scenes: Array=[];var materials: Array=[]
 var adapter: String=Prep.REGISTRY[id][1]
 if adapter.begins_with("scene:"):
  gather(script.scenes,meshes,scenes)
 elif id in ["ruby", "sapphire", "emerald", "quartz", "rose_quartz", "topaz", "amethyst"]:
  # Shared crystal preparation draws skin, shards and sparkle pipelines.
  await frames(2);report.gpu_samples+=1
  return
 elif id=="petrified":
  # Petrified.prepare_unit renders body, grass, flower and both debris pools.
  await frames(2);report.gpu_samples+=1
  return
 elif id=="gold":
  gather(script.star_mesh,meshes,scenes);materials=[script.star_material]
 elif id=="absolute_zero":
  gather([script.ice_mesh,script.mist_mesh],meshes,scenes);materials=[script.frost_material,script.mist_material]
 elif id=="spiders":
  gather([script.thread_mesh,script.spider_meshes],meshes,scenes);materials=[script.web_material,script.spider_material]
 elif id=="vines":
  gather([script.cache,script.connector],meshes,scenes);materials=[script.material]
 else:
  gather(script.meshes,meshes,scenes)
  if id=="roses":gather(script.rose_meshes,meshes,scenes)
  if id=="lightning":
   gather([script.cloud_mesh,script.rain_mesh],meshes,scenes);materials=[script.weather_material,script.material]
  if id=="math":materials=[script.shared_material]
 if id in ["absolute_zero","gold"]:
  var body:=Wardrobe.CLIMBER.instantiate();view.add_child(body)
  for skin in body.find_children("*","MeshInstance3D",true,false):
   skin.material_override=script.frost_material if id=="absolute_zero" else script.gold_material
   if id=="absolute_zero":skin.set_instance_shader_parameter("frost_progress",1.0)
  camera.position=Vector3(0,1,5);camera.size=3
  await frames(3);report.gpu_samples+=1;body.free()
 # A static script property list varies by adapter; all common effects expose meshes.
 if meshes.is_empty() and scenes.is_empty():
  report.errors.append("No render warmup assets found: "+id)
  return
 for scene in scenes:
  if cancelled:return
  var model: Node3D=scene.instantiate();view.add_child(model);CelPass.celify(model)
  var box:=AABB();var first:=true
  for mesh_node in model.find_children("*","MeshInstance3D",true,false):
   var bound: AABB=mesh_node.global_transform*mesh_node.mesh.get_aabb()
   box=bound if first else box.merge(bound);first=false
  camera.position=box.get_center()+Vector3(0,0,maxf(3.,box.size.length()*2.))
  camera.size=maxf(.1,box.size.length()*1.2)
  await frames(2);report.gpu_samples+=1;model.free()
 for mesh in meshes:
  if cancelled:return
  var list: Array=materials if not materials.is_empty() else [null]
  for material in list:
   var node:=MeshInstance3D.new();node.mesh=mesh;node.material_override=material;view.add_child(node)
   if material==null and mesh.get_surface_count()>0 and mesh.surface_get_material(0)==null:node.material_override=CelPass.one()
   var box: AABB=mesh.get_aabb();camera.position=box.get_center()+Vector3(0,0,maxf(3.,box.size.length()*2.));camera.size=maxf(.05,box.size.length()*1.2)
   # Draw both ordinary and instanced layouts; webs and other effects use MultiMesh.
   var inst:=MultiMeshInstance3D.new();inst.multimesh=MultiMesh.new();inst.multimesh.transform_format=MultiMesh.TRANSFORM_3D;inst.multimesh.mesh=mesh;inst.multimesh.instance_count=1;inst.multimesh.set_instance_transform(0,Transform3D.IDENTITY);inst.material_override=node.material_override;view.add_child(inst)
   await frames(2);report.gpu_samples+=1;node.free();inst.free()
func finish() -> void:
 report.total_ms=Time.get_ticks_msec()-started
 if is_instance_valid(view):view.queue_free()
 if is_instance_valid(label):label.text="Waiting for players…"
 completed.emit(report)
func fail() -> void:
 if is_instance_valid(label):label.text="Match preparation failed. Return to the lobby and retry."
 if is_instance_valid(overlay):
  var button:=Button.new();button.text="Return";button.position=Vector2(40,40);overlay.add_child(button)
  button.pressed.connect(func():
   var main=get_parent().get_parent()
   if main.has_method("leave_results"):main.leave_results())
func _exit_tree() -> void:cancelled=true
