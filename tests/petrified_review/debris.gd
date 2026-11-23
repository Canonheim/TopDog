extends Node3D
const ROCK=preload("res://tests/petrified_review/rock.res")
const ROCK_MAT=preload("res://tests/petrified_review/rock.tres")
const DUST_MAT=preload("res://tests/petrified_review/dust.tres")
const SPAN=1.15
var rng:=RandomNumberGenerator.new()
var particles: Array=[]
var rocks: MultiMeshInstance3D
var dust: MultiMeshInstance3D
var active:=false
var elapsed:=0.0
var bursts:=0
var burst_us:=0
var update_max_us:=0
func _ready() -> void:
 rng.randomize()
 rocks=pool(ROCK,ROCK_MAT,7,false)
 var quad:=QuadMesh.new();quad.size=Vector2.ONE
 dust=pool(quad,DUST_MAT,18,true)
 set_process(false)
func pool(mesh: Mesh, material: Material, count: int, custom: bool) -> MultiMeshInstance3D:
 var node:=MultiMeshInstance3D.new();node.multimesh=MultiMesh.new()
 node.multimesh.transform_format=MultiMesh.TRANSFORM_3D
 node.multimesh.use_custom_data=custom
 node.multimesh.mesh=mesh;node.multimesh.instance_count=count;node.multimesh.visible_instance_count=0
 node.material_override=material;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(node);return node
func burst(point: Vector3) -> bool:
 # Consume no random values and queue nothing when a reaction is already playing.
 if active:return false
 var start:=Time.get_ticks_usec()
 active=true;elapsed=0;bursts+=1;particles.clear()
 var count:=rng.randi_range(4,7)
 for i in count+18:
  var powder:=i>=count
  var offset:=Vector3(rng.randf_range(-.08,.08),rng.randf_range(-.09,.09),rng.randf_range(.01,.08))
  var velocity:=Vector3(rng.randf_range(-.3,.3),rng.randf_range(-.32,-.04),rng.randf_range(.06,.28))
  var size:=rng.randf_range(.045,.085) if powder else rng.randf_range(.55,1.15)
  particles.append({"dust":powder,"index":i-count if powder else i,"origin":to_local(point+offset),"velocity":global_basis.inverse()*velocity,"spin":Vector3(rng.randf_range(-5,5),rng.randf_range(-5,5),rng.randf_range(-5,5)),"size":size,"life":rng.randf_range(.75,SPAN)})
 rocks.multimesh.visible_instance_count=count;dust.multimesh.visible_instance_count=18
 step(0);set_process(true);burst_us=Time.get_ticks_usec()-start
 return true
func step(t: float) -> void:
 var started:=Time.get_ticks_usec();elapsed=t
 var camera:=get_viewport().get_camera_3d()
 for p in particles:
  var k:=clampf(t/p.life,0,1)
  var gravity:=.36 if p.dust else 2.2
  var pos: Vector3=p.origin+p.velocity*t+global_basis.inverse()*Vector3.DOWN*gravity*t*t*.5
  var basis:=Basis.from_euler(p.spin*t)
  var size: float=p.size
  if p.dust:
   if camera!=null:basis=global_basis.inverse()*camera.global_basis
   size*=1+t*1.7
   dust.multimesh.set_instance_custom_data(p.index,Color(1,1,1,sin(k*PI)))
  else:size*=1-smoothstep(.7,1.,k)
  var transform:=Transform3D(basis.scaled(Vector3.ONE*maxf(.00001,size)),pos)
  (dust if p.dust else rocks).multimesh.set_instance_transform(p.index,transform)
 if t>=SPAN:
  active=false;rocks.multimesh.visible_instance_count=0;dust.multimesh.visible_instance_count=0;particles.clear();set_process(false)
 update_max_us=maxi(update_max_us,Time.get_ticks_usec()-started)
func _process(dt: float) -> void:step(elapsed+dt)
