extends Node3D
const Layout=preload("res://climber/body_layout.gd")
const Lod=preload("res://ui3d/lock_effect_lod.gd")
const MATERIAL=preload("res://ui3d/petrified/stone.tres")
const DURATION=2.2
const AUDIO=preload("res://ui3d/petrified/audio.gd")
const FLOWER=preload("res://ui3d/petrified/dandelion.res")
const FLOWER_MATERIAL=preload("res://ui3d/petrified/flower.tres")
const BODY=preload("res://ui3d/spider_body_geometry.res")
const FLOWER_CHANCE=0.05
const GRASS=preload("res://ui3d/petrified/grass.res")
const GRASS_MATERIAL=preload("res://ui3d/petrified/grass.tres")
var grass: Array=[]
var grass_ready:=false
var grass_max_slice_us:=0
static var grass_frame: int=-1
static var grass_used_us: int=0
static var grass_global_max_us: int=0
const GRABS=preload("res://ui3d/petrified/grabs.gd")
const DEBRIS=preload("res://ui3d/petrified/debris.gd")
var debris: Node3D
var grab_watch: Node
var flower_normal:=Vector3.UP
var flower_curve:=Vector2.ZERO
var rng:=RandomNumberGenerator.new()
var stone_seed:=0.0
var pattern:=Vector2.ZERO
var flower: MeshInstance3D
var flower_start:=2.2
var flower_max_slice_us:=0
var force_rare_preview:=false
static var prepared:=false
static var preparing:=false
var skins: Array=[]
var age:=0.0
var setup_us:=0
static func prepare() -> void:
 if preparing:
  while not prepared:await (Engine.get_main_loop() as SceneTree).process_frame
  return
 preparing=true
 var tree:=Engine.get_main_loop() as SceneTree
 await tree.process_frame
 var view:=SubViewport.new();view.size=Vector2i(32,32);view.own_world_3d=true;view.msaa_3d=tree.root.msaa_3d;tree.root.add_child(view)
 var model:=Wardrobe.CLIMBER.instantiate();view.add_child(model)
 var fx:=new();model.add_child(fx);fx.setup(model,false)
 var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=3;camera.position=Vector3(0,1,5);view.add_child(camera)
 var light:=DirectionalLight3D.new();view.add_child(light)
 var dust:=DEBRIS.new();view.add_child(dust);dust.burst(Vector3(0,1,0));
 var sprout:=MeshInstance3D.new();sprout.mesh=FLOWER;sprout.material_override=FLOWER_MATERIAL;sprout.position=Vector3(0,1,1);sprout.scale=Vector3.ONE*8;view.add_child(sprout)
 var blades:=MeshInstance3D.new();blades.mesh=GRASS;blades.material_override=GRASS_MATERIAL;blades.set_instance_shader_parameter("growth",1.0);blades.position=Vector3(.3,1,1);blades.scale=Vector3.ONE*8;view.add_child(blades)
 for frame in 4:await RenderingServer.frame_post_draw
 view.queue_free();prepared=true
static func attach_owner(owner_node: Node,animate:=true,rare_preview:=false) -> Node:
 var old:=owner_node.get_node_or_null("Petrified")
 if old!=null:return old
 var fx:=new();fx.name="Petrified";fx.force_rare_preview=rare_preview;owner_node.add_child(fx);fx.set_process(false);fx.begin(owner_node,animate);return fx
func begin(owner_node: Node,animate: bool) -> void:
 if not prepared:await prepare()
 if not is_instance_valid(self) or not is_instance_valid(owner_node):return
 var begin_start:=Time.get_ticks_usec()
 setup(owner_node,animate);set_meta("ready",true);set_process(animate)
 debris=DEBRIS.new();add_child(debris)
 if owner_node is Climber:grab_watch=GRABS.watch(self,owner_node)
 setup_us=Time.get_ticks_usec()-begin_start
 if not skins.is_empty():place_grass()
 else:grass_ready=true
func setup(owner_node: Node,animate: bool) -> void:
 var start:=Time.get_ticks_usec();var bottom:=INF;var top:=-INF;var center:=Vector3.ZERO
 for key in Layout.ORDER:
  var body: Node=owner_node.bodies.get(key) if owner_node is Climber else owner_node
  if body==null:continue
  var skin:=body.find_child(Layout.PIECES[key].mesh,true,false) as MeshInstance3D
  if skin==null:continue
  var box: AABB=skin.global_transform*skin.mesh.get_aabb()
  bottom=minf(bottom,box.position.y);top=maxf(top,box.end.y);center+=skin.global_position
  skins.append({"node":skin,"original":skin.material_override})
 rng.randomize();stone_seed=rng.randf()*100;pattern=Vector2(rng.randf()*TAU,rng.randf_range(5.5,9.0))
 for entry in skins:
  entry.node.set_instance_shader_parameter("stone_floor",bottom)
  entry.node.set_instance_shader_parameter("stone_height",maxf(.1,top-bottom))
  entry.node.set_instance_shader_parameter("stone_seed",stone_seed)
  entry.node.set_instance_shader_parameter("stone_pattern",pattern)
  entry.node.set_instance_shader_parameter("stone_progress",0.0 if animate else 1.0)
  entry.node.material_override=MATERIAL
 if owner_node is Climber:Lod.register(self,Lod.LEGENDARY_GROUP,center/maxi(1,skins.size()),owner_node)
 if animate and not skins.is_empty():AUDIO.play(self,center/skins.size(),true)
 set_meta("persistent_lock_effect",true);tick(0.0 if animate else DURATION)
 setup_us=Time.get_ticks_usec()-start
 if force_rare_preview or rng.randf()<FLOWER_CHANCE:place_flower()
func tick(t: float) -> void:
 age=t
 for entry in skins:
  if is_instance_valid(entry.node):entry.node.set_instance_shader_parameter("stone_progress",clampf(age/DURATION,0.0,1.0))
 if is_instance_valid(flower):
  var growth:=smoothstep(flower_start,flower_start+1.3,age)
  flower.set_instance_shader_parameter("growth",growth)
  flower.visible=growth>.001
 var done:=age>=maxf(DURATION,flower_start+1.3 if is_instance_valid(flower) else DURATION)
 for tuft in grass:
  if not is_instance_valid(tuft.node):continue
  var growth:=smoothstep(tuft.start,tuft.start+1.1,age)
  tuft.node.set_instance_shader_parameter("growth",growth)
  tuft.node.visible=growth>.001
  if growth<1.0:done=false
 if done:set_process(false)
func _process(dt: float) -> void:tick(age+dt)
func on_grab(point: Vector3) -> bool:
 if not is_instance_valid(debris) or age<DURATION:return false
 var nearest:=point;var distance:=INF
 for entry in skins:
  if not is_instance_valid(entry.node):continue
  var box: AABB=entry.node.global_transform*entry.node.mesh.get_aabb()
  var candidate:=point.clamp(box.position,box.end)
  var d:=candidate.distance_squared_to(point)
  if d<distance:
   distance=d;nearest=candidate
   nearest.z=box.end.z+.012
 if not debris.burst(nearest):return false
 AUDIO.play(self,nearest,false)
 return true
func _exit_tree() -> void:
 if is_instance_valid(grab_watch):grab_watch.unwatch(self)
 if is_instance_valid(flower):flower.queue_free()
 for tuft in grass:
  if is_instance_valid(tuft.node):tuft.node.queue_free()
 for entry in skins:
  if is_instance_valid(entry.node) and entry.node.material_override==MATERIAL:entry.node.material_override=entry.original

static func hash_bits(value: int) -> int:
 value=(((value>>16)^value)*0x45d9f3b)&0xffffffff
 value=(((value>>16)^value)*0x45d9f3b)&0xffffffff
 return ((value>>16)^value)&0xffffffff
static func cell_hash(p: Vector2i) -> Vector2:
 var value:=((p.x*73856093)^(p.y*19349663))&0xffffffff
 return Vector2(hash_bits(value)&0xffffff,hash_bits(value^0x9e3779b9)&0xffffff)/16777216.0
func crack_query(point: Vector3) -> Vector2:
 var p:=point+Vector3(stone_seed,0,stone_seed*.37)
 var q:=Vector2(p.x+p.z*.41,p.y).rotated(pattern.x)*pattern.y
 var base:=Vector2i(floori(q.x),floori(q.y));var f:=q-Vector2(base)
 var nearest:=INF;var second:=INF
 for y in range(-1,2):
  for x in range(-1,2):
   var offset:=Vector2i(x,y);var delta:=Vector2(offset)+cell_hash(base+offset)-f
   var d:=delta.length_squared()
   if d<nearest:second=nearest;nearest=d
   else:second=minf(second,d)
 return Vector2(second-nearest,cell_hash(base).x)
func place_flower() -> void:
 var started:=Time.get_ticks_usec()
 var camera:=get_viewport().get_camera_3d()
 var baked: Dictionary=BODY.get_meta("surfaces")
 for attempt in (4096 if force_rare_preview else 512):
  if Time.get_ticks_usec()-started>=1000:
   flower_max_slice_us=maxi(flower_max_slice_us,Time.get_ticks_usec()-started)
   await get_tree().process_frame
   if not is_instance_valid(self):return
   started=Time.get_ticks_usec()
  var skin: MeshInstance3D=skins[rng.randi_range(0,skins.size()-1)].node
  if not is_instance_valid(skin):return
  var source: String=skin.mesh.get_meta("lock_geometry_source",skin.mesh.resource_path)
  if not baked.has(source):continue
  var geo: Dictionary=baked[source];var vv: PackedVector3Array=geo.vertices;var ids: PackedInt32Array=geo.indices;var nn: PackedVector3Array=geo.normals
  var i:=rng.randi_range(0,ids.size()/3-1)*3
  var u:=sqrt(rng.randf());var v:=rng.randf();var weights:=Vector3(1-u,u*(1-v),u*v)
  var point:=skin.to_global(vv[ids[i]]*weights.x+vv[ids[i+1]]*weights.y+vv[ids[i+2]]*weights.z)
  var normal: Vector3=(skin.global_basis.inverse().transposed()*(nn[ids[i]]*weights.x+nn[ids[i+1]]*weights.y+nn[ids[i+2]]*weights.z)).normalized()
  if camera!=null and normal.dot((camera.global_position-point).normalized())<.25:continue
  var crack:=crack_query(point)
  if crack.x>.008 or crack.y<.55:continue
  flower=MeshInstance3D.new();flower.mesh=FLOWER;flower.material_override=FLOWER_MATERIAL;flower.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  flower.visible=false;skin.add_child(flower)
  flower.global_position=point+normal*.001
  flower_normal=normal
  flower.global_basis=surface_basis(normal)
  var bend:=Vector3.UP-normal*normal.dot(Vector3.UP)
  if bend.length_squared()<.02:bend=flower.global_basis.x
  bend=bend.normalized()
  flower_curve=Vector2(bend.dot(flower.global_basis.x),bend.dot(flower.global_basis.z)).normalized()
  var bend_angle:=lerpf(.3,1.95,(1-normal.y)*.5)*rng.randf_range(.9,1.05)
  flower.set_instance_shader_parameter("stem_bend",bend_angle)
  flower.set_instance_shader_parameter("stem_curve",flower_curve)
  flower.set_instance_shader_parameter("growth",0.0)
  flower.set_meta("crack_gap",crack.x);flower.set_meta("crack_strength",crack.y)
  flower_start=maxf(2.2,age+.05);set_process(true)
  break
 flower_max_slice_us=maxi(flower_max_slice_us,Time.get_ticks_usec()-started)

static func surface_basis(normal: Vector3) -> Basis:
 var helper:=Vector3.FORWARD if absf(normal.dot(Vector3.FORWARD))<.9 else Vector3.RIGHT
 var right:=normal.cross(helper).normalized()
 return Basis(right,normal,right.cross(normal)).orthonormalized()

static func moss_noise(p: Vector2) -> float:
 var cell:=Vector2i(floori(p.x),floori(p.y))
 var f:=p-Vector2(cell)
 f=f*f*(Vector2.ONE*3.-f*2.)
 return lerpf(lerpf(cell_hash(cell).y,cell_hash(cell+Vector2i(1,0)).y,f.x),lerpf(cell_hash(cell+Vector2i(0,1)).y,cell_hash(cell+Vector2i(1,1)).y,f.x),f.y)
func moss_patch(point: Vector3) -> float:
 var p:=point+Vector3(stone_seed,0,stone_seed*.37)
 var coord:=Vector2(p.x+p.z*.41,p.y).rotated(pattern.x)
 return moss_noise(coord*11.+Vector2(17.2,43.8))
func place_grass() -> void:
 await get_tree().process_frame
 var camera:=get_viewport().get_camera_3d()
 var baked: Dictionary=BODY.get_meta("surfaces")
 var desired:=rng.randi_range(16,22)
 var attempts:=0
 while attempts<16384 and grass.size()<desired:
  var frame:=Engine.get_process_frames()
  if grass_frame!=frame:
   grass_frame=frame;grass_used_us=0
  if grass_used_us>=1000:
   await get_tree().process_frame
   continue
  var started:=Time.get_ticks_usec()
  attempts+=1
  try_grass(baked,camera)
  var elapsed:=Time.get_ticks_usec()-started
  grass_used_us+=elapsed
  grass_max_slice_us=maxi(grass_max_slice_us,elapsed)
  grass_global_max_us=maxi(grass_global_max_us,grass_used_us)
 grass_ready=true

func try_grass(baked: Dictionary,camera: Camera3D) -> void:
 var skin: MeshInstance3D=skins[rng.randi_range(0,skins.size()-1)].node
 if not is_instance_valid(skin):return
 var source: String=skin.mesh.get_meta("lock_geometry_source",skin.mesh.resource_path)
 if not baked.has(source):return
 var geo: Dictionary=baked[source];var vv: PackedVector3Array=geo.vertices;var ids: PackedInt32Array=geo.indices;var nn: PackedVector3Array=geo.normals
 var i:=rng.randi_range(0,ids.size()/3-1)*3
 var u:=sqrt(rng.randf());var v:=rng.randf();var weights:=Vector3(1-u,u*(1-v),u*v)
 var point:=skin.to_global(vv[ids[i]]*weights.x+vv[ids[i+1]]*weights.y+vv[ids[i+2]]*weights.z)
 var normal: Vector3=(skin.global_basis.inverse().transposed()*(nn[ids[i]]*weights.x+nn[ids[i+1]]*weights.y+nn[ids[i+2]]*weights.z)).normalized()
 if camera!=null and normal.dot((camera.global_position-point).normalized())<.25:return
 var crack:=crack_query(point)
 var patch:=moss_patch(point)
 if crack.x>.018 or crack.y<.65 or patch<.46:return
 var crowded:=false
 for tuft in grass:
  if tuft.point.distance_to(point)<.045:crowded=true
 if crowded:return
 var node:=MeshInstance3D.new();node.mesh=GRASS;node.material_override=GRASS_MATERIAL
 node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;node.visible=false;skin.add_child(node)
 node.global_position=point+normal*.001
 node.global_basis=surface_basis(normal)*Basis(Vector3.UP,rng.randf()*TAU)
 node.scale*=rng.randf_range(.8,1.15)
 var bend:=Vector3.UP-normal*normal.dot(Vector3.UP)
 if bend.length_squared()<.02:bend=node.global_basis.x
 bend=bend.normalized()
 node.set_instance_shader_parameter("grass_curve",Vector2(bend.dot(node.global_basis.x),bend.dot(node.global_basis.z))*.035)
 node.set_instance_shader_parameter("growth",0.)
 grass.append({"node":node,"point":point,"start":maxf(DURATION+rng.randf_range(.05,.45),age+.05),"gap":crack.x,"patch":patch})
 set_process(true)

static func prepare_unit(_index: int) -> bool:
 if not preparing:prepare()
 return prepared
static func preview(model: Node3D,_camera: Camera3D) -> Node:
 return attach_owner(model,true)
static func attach(actor: Climber,_camera: Camera3D=null,animate:=true) -> Node:
 if not is_instance_valid(actor) or actor.removed or actor.state!=Climber.State.FROZEN:return null
 return attach_owner(actor,animate)
