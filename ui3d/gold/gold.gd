extends Node3D
const TRANSFORM_SOUND := preload("res://audio/sfx/gold_transform.wav")
const Lod=preload("res://ui3d/lock_effect_lod.gd")
static var gold_material: ShaderMaterial=preload("res://ui3d/gold/gold_material.tres")
static var star_material: ShaderMaterial=preload("res://ui3d/gold/star_material.tres")
static var star_mesh: ArrayMesh=preload("res://ui3d/gold/star_mesh.res")
var skins: Array=[]
var sites: Array=[]
var stars: Array=[]
var owner_ref: WeakRef
var age:=0.0
var rng:=RandomNumberGenerator.new()
var clock:=0.0
var lod_clock:=0.0
var interval:=0.0
const BODY_GEOMETRY=preload("res://ui3d/spider_body_geometry.res")
static var extra_geometry: Dictionary={}
static var geometry_readbacks:=0
var setup_us:=0
static var pipeline_started:=false
static var pipeline_ready:=false
static func prepare() -> void:
 pass # Immutable atlas materials and star geometry are loaded with the script.
static func geometry_for(skin: MeshInstance3D) -> Dictionary:
 var mesh:=skin.mesh
 var source: String=mesh.get_meta("lock_geometry_source",mesh.resource_path)
 var baked: Dictionary=BODY_GEOMETRY.get_meta("surfaces")
 if baked.has(source):return baked[source]
 if not extra_geometry.has(mesh):
  geometry_readbacks+=1
  var arr:=mesh.surface_get_arrays(0)
  extra_geometry[mesh]={"vertices":arr[Mesh.ARRAY_VERTEX],"indices":arr[Mesh.ARRAY_INDEX]}
 return extra_geometry[mesh]
func setup(actor: Node, play_sound := true) -> void:
 var started:=Time.get_ticks_usec()
 prepare();rng.randomize();owner_ref=weakref(actor)
 var center:=Vector3.ZERO
 for key in Climber.Layout.ORDER:
  var body: Node=actor.bodies.get(key) if actor is Climber else actor
  if body==null:continue
  var skin: Node=body.find_child(Climber.Layout.PIECES[key].mesh,true,false)
  var meshes: Array=[]
  if skin is MeshInstance3D:meshes=[skin]
  elif skin!=null:meshes=skin.find_children("*","MeshInstance3D",true,false)
  for mesh: MeshInstance3D in meshes:
   skins.append({"node":mesh,"original":mesh.material_override});center+=mesh.global_position
   var geometry:=geometry_for(mesh)
   var verts: PackedVector3Array=geometry.vertices;var ids: PackedInt32Array=geometry.indices
   if ids.is_empty():
    for vertex in verts.size():ids.append(vertex)
   # Choose a surface only when a twinkle begins, rather than generating
   # 192 unused samples on every lock-in. Body parts remain equally likely.
   sites.append({"vertices":verts,"indices":ids,"transform":mesh.global_transform,"front":mesh.global_position.z+mesh.mesh.get_aabb().size.z*.5+.045})
 # One atomic material swap; there is no traveling gold fill or fade.
 for entry in skins:entry.node.material_override=gold_material
 center/=maxi(1,skins.size())
 # Start on the same frame as the atomic gold material swap.
 if play_sound and not skins.is_empty():
  var voice := AudioStreamPlayer3D.new()
  voice.name = "GoldTransformSound"
  voice.stream = TRANSFORM_SOUND
  voice.bus = "Effects"
  voice.unit_size = 6.0
  add_child(voice)
  voice.global_position = center
  voice.finished.connect(voice.queue_free)
  voice.play()
 if actor is Climber:Lod.register(self,Lod.LEGENDARY_GROUP,center,actor)
 for i in 3:
  var star:=MeshInstance3D.new();star.mesh=star_mesh;star.material_override=star_material;star.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(star)
  stars.append({"node":star,"next":.18+i*.55,"start":-10.0,"duration":.6,"size":.04})
 tick(0)
 setup_us=Time.get_ticks_usec()-started
func tick(t: float) -> void:
 age=t
 var camera:=get_viewport().get_camera_3d()
 for data in stars:
  if age>=data.next:
   data.start=age;data.duration=rng.randf_range(.45,.75);data.next=age+data.duration+rng.randf_range(.9,1.8)
   var site: Dictionary=sites[rng.randi_range(0,sites.size()-1)]
   var ids: PackedInt32Array=site.indices;var verts: PackedVector3Array=site.vertices
   var at:=rng.randi_range(0,ids.size()/3-1)*3
   var point: Vector3=site.transform*((verts[ids[at]]+verts[ids[at+1]]+verts[ids[at+2]])/3)
   point.z=maxf(point.z+.045,site.front)
   data.node.position=to_local(point);data.size=rng.randf_range(.025,.050)
  var phase:=clampf((age-data.start)/data.duration,0,1)
  var scale_value: float=sin(phase*PI)*data.size
  data.node.visible=scale_value>.001
  if camera!=null:data.node.global_basis=camera.global_basis.scaled(Vector3.ONE*maxf(.0001,scale_value))
func _process(dt: float) -> void:
 var actor=owner_ref.get_ref() if owner_ref!=null else null
 if not is_instance_valid(actor) or (actor is Climber and actor.removed):queue_free();return
 age+=dt;clock+=dt;lod_clock+=dt
 if lod_clock>=.25:lod_clock=0;interval=Lod.interval(self,Lod.LEGENDARY_GROUP,0)
 if clock>=interval:clock=0;tick(age)
func _exit_tree() -> void:
 for entry in skins:
  if is_instance_valid(entry.node) and entry.node.material_override==gold_material:entry.node.material_override=entry.original

static func warm_pipeline() -> void:
 if pipeline_started:return
 pipeline_started=true
 # Draw only immutable assets in a tiny loading viewport, never a cosmetic burst.
 # Matching real body/star vertex layouts primes the renderer before lock-in.
 var tree:=Engine.get_main_loop() as SceneTree
 await tree.process_frame
 var view:=SubViewport.new();view.size=Vector2i(32,32);view.own_world_3d=true
 view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
 view.msaa_3d=tree.root.msaa_3d
 tree.root.add_child(view)
 var model:=Wardrobe.CLIMBER.instantiate();view.add_child(model)
 for skin in model.find_children("*","MeshInstance3D",true,false):skin.material_override=gold_material
 var light:=DirectionalLight3D.new();view.add_child(light)
 var star:=MeshInstance3D.new();star.mesh=star_mesh;star.material_override=star_material;star.position=Vector3(0,1,1);star.scale=Vector3.ONE*.2;view.add_child(star)
 var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=3;camera.position=Vector3(0,1,5);view.add_child(camera)
 for frame in 4:await RenderingServer.frame_post_draw
 view.queue_free();pipeline_ready=true
static func prepare_unit(_index: int) -> bool:
 prepare()
 if not pipeline_started:warm_pipeline()
 return pipeline_ready
static func preview(model: Node3D,_camera: Camera3D) -> Node:
 return attach_owner(model,true)
static func attach(actor: Climber,_camera: Camera3D=null,animate:=true) -> Node:
 if not is_instance_valid(actor) or actor.removed or actor.state!=Climber.State.FROZEN:return null
 return attach_owner(actor,animate)
static func attach_owner(owner_node: Node,animate: bool) -> Node:
 var existing:=owner_node.get_node_or_null("Gold")
 if existing!=null:return existing
 var effect:=new();effect.name="Gold";effect.set_meta("persistent_lock_effect",true);effect.set_meta("ready",false)
 owner_node.add_child(effect);effect.set_process(false);effect.start(owner_node,animate);return effect
func start(owner_node: Node,animate: bool) -> void:
 # An unusually early request waits for loading readiness without exposing a
 # partially golden model. Normal requests are already prepared in the menu.
 if not pipeline_started:warm_pipeline()
 while not pipeline_ready:
  await get_tree().process_frame
  if not is_instance_valid(self) or not is_instance_valid(owner_node):return
 await setup(owner_node,animate)
 if not is_instance_valid(self) or not is_instance_valid(owner_node):return
 tick(0 if animate else 5);set_meta("ready",true);set_process(true)
