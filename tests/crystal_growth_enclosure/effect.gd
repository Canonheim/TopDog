extends Node3D
const BODY=preload("res://ui3d/spider_body_geometry.res")
const SHELL=preload("res://tests/crystal_growth_enclosure/shell.res")
const SHELL_MATERIAL=preload("res://tests/crystal_growth_enclosure/shell.tres")
var shell: MeshInstance3D
const SHADES=preload("res://tests/crystal_growth_enclosure/shades.res")
const SHADE_NAMES=["White","Blue","Red","Pink","Orange","Green","Purple","Multicolor"]
var shade_index:=0
var shade_uv:=Vector2.ZERO
const AURA=preload("res://tests/crystal_growth_enclosure/aura.tres")
const AURA_COUNT=32
static var aura_mesh:=QuadMesh.new()
var aura: MultiMeshInstance3D
var aura_clock:=0.0
var aura_update_max_us:=0
const SITES=preload("res://tests/crystal_growth_enclosure/roots.res")
const FILM=preload("res://tests/crystal_growth_enclosure/film.tres")
const MESH=preload("res://tests/crystal_growth_enclosure/shard.res")
const MATERIAL=preload("res://tests/crystal_growth_enclosure/crystal.tres")
const Lod=preload("res://ui3d/lock_effect_lod.gd")
const DURATION=1.65
var rng:=RandomNumberGenerator.new()
var batches: Array=[]
var skins: Array=[]
var film_seed:=0.0
var roots: Array=[]
var owner_ref: WeakRef
var age:=0.0
var initialized:=false
var shard_count:=0
var setup_us:=0
var setup_slice_us:=0
var setup_latency_ms:=0.0
static var work_frame: int=-1
static var work_us: int=0
static var shared_peak_us: int=0
static var prepared:=false
static var preparing:=false
static func prepare() -> void:
 if preparing:
  while not prepared:await (Engine.get_main_loop() as SceneTree).process_frame
  return
 preparing=true
 var tree:=Engine.get_main_loop() as SceneTree
 await tree.process_frame
 var view:=SubViewport.new();view.size=Vector2i(64,64);view.own_world_3d=true;view.msaa_3d=tree.root.msaa_3d;tree.root.add_child(view)
 var node:=MultiMeshInstance3D.new();node.multimesh=MultiMesh.new();node.multimesh.transform_format=MultiMesh.TRANSFORM_3D;node.multimesh.use_custom_data=true;node.multimesh.mesh=MESH;node.multimesh.instance_count=1;node.multimesh.set_instance_transform(0,Transform3D(Basis.IDENTITY.scaled(Vector3(.25,1,.25)),Vector3.ZERO));node.multimesh.set_instance_custom_data(0,Color(0,.3,.5,1));node.material_override=MATERIAL;node.set_instance_shader_parameter("age",2.0);view.add_child(node)
 var model:=Wardrobe.CLIMBER.instantiate();view.add_child(model)
 for skin in model.find_children("*","MeshInstance3D",true,false):skin.material_override=FILM;skin.set_instance_shader_parameter("stone_progress",1.0)
 var camera:=Camera3D.new();camera.position=Vector3(0,.5,3);view.add_child(camera)
 var light:=DirectionalLight3D.new();light.rotation_degrees=Vector3(-30,-25,0);view.add_child(light)
 var mist:=MultiMeshInstance3D.new();mist.multimesh=MultiMesh.new();mist.multimesh.transform_format=MultiMesh.TRANSFORM_3D;mist.multimesh.use_custom_data=true;mist.multimesh.mesh=aura_mesh;mist.multimesh.instance_count=2;mist.material_override=AURA;view.add_child(mist)
 for i in 2:
  mist.multimesh.set_instance_transform(i,Transform3D(Basis.IDENTITY,Vector3(i*.4,.5,1)))
  mist.multimesh.set_instance_custom_data(i,Color(.3,.5,float(i),2.))
 mist.set_instance_shader_parameter("aura_age",1.)
 var cover:=MeshInstance3D.new();cover.mesh=SHELL;cover.material_override=SHELL_MATERIAL;view.add_child(cover);cover.set_instance_shader_parameter("shell_growth",1.)
 for i in 4:await RenderingServer.frame_post_draw
 view.queue_free();prepared=true
static func prepare_unit(_index: int) -> bool:
 if not preparing:prepare()
 return prepared
static func attach(owner_node: Node,animate:=true) -> Node:
 var existing:=owner_node.get_node_or_null("CrystalGrowth")
 if existing!=null:return existing
 var fx:=new();fx.name="CrystalGrowth";owner_node.add_child(fx);fx.set_process(false);fx.begin(owner_node,animate);return fx
func begin(owner_node: Node,animate: bool) -> void:
 var start:=Time.get_ticks_usec()
 if not prepared:await prepare()
 if not is_instance_valid(self) or not is_instance_valid(owner_node):return
 rng.randomize();shade_index=rng.randi_range(0,SHADE_NAMES.size()-1);shade_uv=SHADES.get_meta("uvs")[shade_index];film_seed=rng.randf()*100.;owner_ref=weakref(owner_node)
 set_meta("persistent_lock_effect",true)
 if owner_node is Climber:Lod.register(self,Lod.LEGENDARY_GROUP,owner_node.bodies.chest.global_position,owner_node)
 setup_us=Time.get_ticks_usec()-start
 var setup_start:=Time.get_ticks_usec()
 for key in Climber.Layout.ORDER:
  if work_frame!=Engine.get_process_frames():work_frame=Engine.get_process_frames();work_us=0
  while work_us>=1000:
   await get_tree().process_frame
   if work_frame!=Engine.get_process_frames():work_frame=Engine.get_process_frames();work_us=0
  var slice:=Time.get_ticks_usec()
  var body: Node=owner_node.bodies.get(key) if owner_node is Climber else owner_node
  if body!=null:
   var skin:=body.find_child(Climber.Layout.PIECES[key].mesh,true,false) as MeshInstance3D
   if skin!=null:populate(skin,key)
  var elapsed:=Time.get_ticks_usec()-slice
  setup_slice_us=maxi(setup_slice_us,elapsed);work_us+=elapsed;shared_peak_us=maxi(shared_peak_us,work_us)
 create_aura()
 # Large enclosure disabled for this comparison.
 initialized=true;set_meta("ready",true);setup_latency_ms=(Time.get_ticks_usec()-setup_start)/1000.
 tick(0.0 if animate else DURATION);set_process(true)
func populate(skin: MeshInstance3D,key: String) -> void:
 var source: String=skin.mesh.get_meta("lock_geometry_source",skin.mesh.resource_path)
 var baked: Dictionary=BODY.get_meta("surfaces")
 if not baked.has(source):return
 var candidates: Array=SITES.get_meta("sites").get(source,[])
 if candidates.is_empty():return
 var count:=rng.randi_range(5,7) if key in ["chest","belly"] else rng.randi_range(3,4)
 var positions: Array=[];var transforms: Array=[];var custom: Array=[]
 skins.append({"node":skin,"original":skin.material_override})
 skin.set_instance_shader_parameter("stone_progress",0.0);skin.set_instance_shader_parameter("stone_seed",film_seed)
 skin.material_override=FILM
 skin.set_instance_shader_parameter("shade_uv",shade_uv)
 skin.set_instance_shader_parameter("multicolor",1.0 if shade_index==7 else 0.0)
 skin.set_instance_shader_parameter("tint_boost",1.6 if shade_index in [4,5] else (1.2 if shade_index in [1,6,7] else 1.0))
 for attempt in 128:
  if transforms.size()>=count:break
  var site: Dictionary=candidates[rng.randi_range(0,candidates.size()-1)]
  var normal: Vector3=site.normal
  var world_normal: Vector3=(skin.global_basis.inverse().transposed()*normal).normalized()
  if world_normal.z<-.2:continue
  var point: Vector3=site.origin
  if positions.any(func(p):return p.distance_to(point)<.045):continue
  var helper:=Vector3.FORWARD if absf(normal.z)<.9 else Vector3.RIGHT
  var right:=normal.cross(helper).normalized()
  var tangent:=right.cross(normal).normalized()
  var jitter: Vector3=(right*rng.randf_range(-.1,.1)+tangent*rng.randf_range(-.1,.1))*float(site.clearance)
  point+=jitter
  var safe_radius: float=site.clearance-jitter.length()
  var axis: Vector3=(normal+right*rng.randf_range(-.18,.18)+tangent*rng.randf_range(-.18,.18)).normalized()
  right=axis.cross(helper).normalized()
  var basis:=Basis(right,axis,right.cross(axis)).orthonormalized()*Basis(Vector3.UP,rng.randf()*TAU)
  var world_scale: float=(skin.global_basis*axis).length()
  var length:=rng.randf_range(.26,.46) if transforms.is_empty() else rng.randf_range(.10,.28)
  if key.contains("foot") or key=="head":length*=.7
  var desired_radius: float=0.0
  # The complete base disc stays inside a verified interior sphere, including jitter.
  var max_scale: float=maxf(skin.global_basis.get_scale().abs().x,maxf(skin.global_basis.get_scale().abs().y,skin.global_basis.get_scale().abs().z))
  desired_radius=length*rng.randf_range(.08,.14)/maxf(.001,max_scale)
  var radius:=minf(desired_radius,safe_radius*rng.randf_range(.68,.90))
  # Reduce the entire shard proportionally if the origin cannot contain its base.
  length*=minf(1.0,radius/maxf(.00001,desired_radius))
  if length<.035:continue
  var local_length: float=length/world_scale+site.depth
  transforms.append(Transform3D(basis.scaled_local(Vector3(radius,local_length,radius)),point))
  custom.append(Color(rng.randf_range(.10,.95),rng.randf_range(.30,.60),rng.randf(),1))
  positions.append(point)
  roots.append({"point":skin.to_global(point),"normal":world_normal,"length":length,"radius":radius,"safe_radius":safe_radius,"jitter":jitter.length(),"clearance":site.clearance,"surface":skin.to_global(site.surface),"crystal_transform":skin.global_transform*transforms[-1]})
 if transforms.is_empty():return
 var node:=MultiMeshInstance3D.new();node.multimesh=MultiMesh.new();node.multimesh.transform_format=MultiMesh.TRANSFORM_3D;node.multimesh.use_custom_data=true;node.multimesh.mesh=MESH
 node.multimesh.instance_count=transforms.size();node.multimesh.visible_instance_count=0
 node.material_override=MATERIAL;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 for i in transforms.size():node.multimesh.set_instance_transform(i,transforms[i]);node.multimesh.set_instance_custom_data(i,custom[i])
 node.set_instance_shader_parameter("shade_uv",shade_uv)
 node.set_instance_shader_parameter("multicolor",1.0 if shade_index==7 else 0.0)
 node.set_instance_shader_parameter("tint_boost",1.6 if shade_index in [4,5] else (1.2 if shade_index in [1,6,7] else 1.0))
 skin.add_child(node);batches.append(node);shard_count+=transforms.size()
func tick(t: float) -> void:
 age=t
 if is_instance_valid(shell):shell.set_instance_shader_parameter("shell_growth",smoothstep(.18,1.4,age))
 for entry in skins:
  if is_instance_valid(entry.node):entry.node.set_instance_shader_parameter("stone_progress",clampf(age/.8,0.,1.))
 for node in batches:
  node.set_instance_shader_parameter("age",age)
  node.multimesh.visible_instance_count=node.multimesh.instance_count if age>.001 else 0
 if is_instance_valid(aura):aura.set_instance_shader_parameter("aura_age",age)
func _process(dt: float) -> void:
 if age<DURATION:
  tick(age+dt)
 else:
  age+=dt;aura_clock+=dt
  if aura_clock>=Lod.interval(self,Lod.LEGENDARY_GROUP,1.0/15.0):
   aura_clock=0.0
   var start:=Time.get_ticks_usec()
   if is_instance_valid(aura):aura.set_instance_shader_parameter("aura_age",age)
   aura_update_max_us=maxi(aura_update_max_us,Time.get_ticks_usec()-start)
func create_aura() -> void:
 if roots.is_empty():return
 aura=MultiMeshInstance3D.new();aura.multimesh=MultiMesh.new();aura.multimesh.transform_format=MultiMesh.TRANSFORM_3D;aura.multimesh.use_custom_data=true
 aura.multimesh.mesh=aura_mesh;aura.multimesh.instance_count=AURA_COUNT;aura.multimesh.visible_instance_count=0
 aura.material_override=AURA;aura.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(aura)
 for i in AURA_COUNT:
  var root: Dictionary=roots[rng.randi_range(0,roots.size()-1)]
  var dust:=true
  var size:=rng.randf_range(.008,.027) if dust else rng.randf_range(.12,.26)
  var spawn: Vector3=root.surface
  var outward: Vector3=root.normal.normalized()
  var on_spike:=i>=AURA_COUNT/2
  if on_spike:
   # Sample the actual six-sided crystal crown, not a surrounding box.
   var side_index:=rng.randi_range(0,5)
   var a:=TAU*side_index/6.;var b:=TAU*(side_index+1)/6.
   var left:=Vector3(cos(a)*.88,.72+sin(a)*.07,sin(a)*.88)
   var right:=Vector3(cos(b)*.88,.72+sin(b)*.07,sin(b)*.88)
   var tip:=Vector3(.12,1.0,-.08)
   var u:=sqrt(rng.randf());var v:=rng.randf()
   var sample_point:=left*(1-u)+right*u*(1-v)+tip*u*v
   var transform: Transform3D=root.crystal_transform
   spawn=transform*sample_point
   var normal: Vector3=(tip-left).cross(right-left).normalized()
   if normal.dot(Vector3(cos(a+.5*(b-a)),0,sin(a+.5*(b-a))))<0:normal=-normal
   outward=(transform.basis.inverse().transposed()*normal).normalized()

  var helper:=Vector3.UP if absf(outward.y)<.9 else Vector3.RIGHT
  var side:=helper.cross(outward).normalized()
  var emission_basis:=Basis(side,outward.cross(side).normalized(),outward)
  aura.multimesh.set_instance_transform(i,Transform3D(global_basis.inverse()*emission_basis.scaled(Vector3.ONE*size),to_local(spawn+outward*.008)))
  aura.multimesh.set_instance_custom_data(i,Color(rng.randf(),rng.randf(),2.0 if on_spike else 1.0,rng.randf_range(1.4,2.8)))
 aura.set_instance_shader_parameter("shade_uv",shade_uv)
 aura.set_instance_shader_parameter("multicolor",1.0 if shade_index==7 else 0.0)
 aura.set_instance_shader_parameter("aura_age",0.)
 aura.multimesh.visible_instance_count=AURA_COUNT

func _exit_tree() -> void:
 for entry in skins:
  if is_instance_valid(entry.node) and entry.node.material_override==FILM:entry.node.material_override=entry.original
 var actor: Node=owner_ref.get_ref() if owner_ref!=null else null
 if is_instance_valid(actor):
  var another:=false
  for child in actor.get_children():
   if child!=self and child.get_meta("lod_registered",false):another=true
  if not another:actor.remove_from_group(Lod.LEGENDARY_GROUP);Lod.counts.clear()
 for node in batches:
  if is_instance_valid(node):node.queue_free()



func create_shell() -> void:
 if skins.is_empty():return
 var bounds:=AABB();var first:=true
 for entry in skins:
  var box: AABB=entry.node.global_transform*entry.node.mesh.get_aabb()
  bounds=box if first else bounds.merge(box);first=false
 shell=MeshInstance3D.new();shell.mesh=SHELL;shell.material_override=SHELL_MATERIAL;shell.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 shell.set_instance_shader_parameter("shade_uv",shade_uv);shell.set_instance_shader_parameter("shell_growth",0.)
 add_child(shell)
 shell.global_position=bounds.get_center()+Vector3(0,0,.07)
 shell.global_basis=Basis.IDENTITY.scaled(Vector3(bounds.size.x*1.12,bounds.size.y*.96,maxf(.65,bounds.size.z+.42)))
