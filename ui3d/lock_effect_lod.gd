extends RefCounted
# Population is cached per world and effect, not rescanned by every character.
const LEGENDARY_GROUP=&"legendary_locked_lod"
static var counts: Dictionary={}
static func register(effect: Node3D, group: StringName, center: Vector3, owner_node: Node=null) -> void:
 effect.set_meta("lod_center",center);effect.set_meta("lod_registered",true)
 var member: Node=owner_node if owner_node!=null else effect
 member.set_meta("lod_world",effect.get_world_3d().get_instance_id());member.add_to_group(LEGENDARY_GROUP);counts.clear()
static func interval(effect: Node3D, group: StringName, normal: float) -> float:
 if not effect.get_meta("lod_registered",false):return normal
 var world:=effect.get_world_3d();var key:=str(world.get_instance_id())+str(LEGENDARY_GROUP)
 var now:=Time.get_ticks_msec()
 if not counts.has(key) or now-int(counts[key].at)>=250:
  var count:=0
  for node in effect.get_tree().get_nodes_in_group(LEGENDARY_GROUP):
   if node.get_meta("lod_world",0)==world.get_instance_id():count+=1
  counts[key]={"at":now,"count":count}
 if int(counts[key].count)<=20:return normal
 var camera:=effect.get_viewport().get_camera_3d()
 if camera==null:return normal
 var center: Vector3=effect.get_meta("lod_center",effect.global_position)
 var delta:=camera.to_local(center)
 # Orthographic camera depth does not represent apparent distance in this game.
 var distance:=Vector2(delta.x,delta.y).length() if camera.projection==Camera3D.PROJECTION_ORTHOGONAL else delta.length()*.5
 if distance>=12.0:return maxf(normal,.2)
 if distance>=6.0:return maxf(normal,.1)
 return normal
