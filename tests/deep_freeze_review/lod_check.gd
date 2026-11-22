extends Node3D
const Lod=preload("res://ui3d/lock_effect_lod.gd")
const Spiders=preload("res://ui3d/spiders_effect.gd")
const Frost=preload("res://tests/deep_freeze_review/freeze.gd")
var errors: Array=[]
func check(ok: bool, message: String) -> void:
 if not ok:errors.append(message)
func _ready() -> void:
 var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;add_child(camera);camera.current=true;camera.position=Vector3(0,0,25)
 for group in [Spiders.LOD_GROUP,Frost.LOD_GROUP]:
  var normal:=0.0 if group==Spiders.LOD_GROUP else 1.0/15.0
  var nodes: Array=[]
  for i in 20:
   var node:=Node3D.new();add_child(node);Lod.register(node,group,Vector3(15,0,0));nodes.append(node)
  check(is_equal_approx(Lod.interval(nodes[0],group,normal),normal),"20 retain normal rate")
  var extra:=Node3D.new();add_child(extra);Lod.register(extra,group,Vector3.ZERO)
  check(is_equal_approx(Lod.interval(nodes[0],group,normal),.2),"21 very distant rate 5Hz")
  nodes[0].set_meta("lod_center",Vector3(8,0,0))
  check(is_equal_approx(Lod.interval(nodes[0],group,normal),.1),"distant rate 10Hz")
  nodes[0].set_meta("lod_center",Vector3(2,0,0))
  check(is_equal_approx(Lod.interval(nodes[0],group,normal),normal),"near rate unchanged")
  extra.free();Lod.counts.clear();nodes[0].set_meta("lod_center",Vector3(15,0,0))
  check(is_equal_approx(Lod.interval(nodes[0],group,normal),normal),"rate restored at 20")
  for node in nodes:node.free()
 # Mixed types share one character count; multiple registrations do not double count.
 var owners: Array=[];var handles: Array=[]
 for i in 21:
  var owner_node:=Node.new();add_child(owner_node);owners.append(owner_node)
  var handle:=Node3D.new();owner_node.add_child(handle);handles.append(handle)
  Lod.register(handle,&"spiders" if i<10 else &"frost",Vector3(15,0,0),owner_node)
 check(is_equal_approx(Lod.interval(handles[0],&"spiders",0),.2),"10 spiders plus 11 frost trigger shared threshold")
 owners[-1].free();Lod.counts.clear()
 Lod.register(handles[0],&"vines",Vector3(15,0,0),owners[0])
 check(is_equal_approx(Lod.interval(handles[0],&"spiders",0),0),"same owner counted once at 20")
 for i in 20:owners[i].free()
 print("LOD_CHECK ",JSON.stringify(errors));get_tree().quit(0 if errors.is_empty() else 1)
