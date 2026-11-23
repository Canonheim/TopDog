extends Node
# One event listener for all Petrified owners, never one polling loop per statue.
var effects: Dictionary={}
var actors: Array[WeakRef]=[]
static func watch(effect: Node, owner_node: Climber) -> Node:
 var tree:=effect.get_tree()
 var watcher:=tree.root.get_node_or_null("PetrifiedGrabWatch")
 if watcher!=null and watcher.is_queued_for_deletion():
  tree.root.remove_child(watcher);watcher=null
 if watcher==null:
  watcher=load("res://ui3d/petrified/grabs.gd").new()
  watcher.name="PetrifiedGrabWatch";tree.root.add_child(watcher)
 watcher.effects[owner_node.get_instance_id()]=weakref(effect)
 return watcher
func _ready() -> void:
 get_tree().node_added.connect(track)
 for node in get_tree().root.find_children("*","Node",true,false):track(node)
func track(node: Node) -> void:
 if node is Climber and node.multiplayer==multiplayer and not node.grab_made.is_connected(on_grab):
  node.grab_made.connect(on_grab)
  # Freed climbers drop off the list (the code review, 11-23: it only ever grew).
  for i in range(actors.size()-1,-1,-1):
   if not is_instance_valid(actors[i].get_ref()):actors.remove_at(i)
  actors.append(weakref(node))
func on_grab(source: Climber, _limb: int, other: Object) -> void:
 if not is_instance_valid(other) or not other.has_meta("climber"):return
 var target:=Climber.climber_of(other)
 if target==null or source==target:return
 var ref: WeakRef=effects.get(target.get_instance_id())
 if ref==null:return
 var effect: Node=ref.get_ref()
 if is_instance_valid(effect):
  effect.on_grab(source.bodies[source.limbs[_limb].def.end].global_position)
  if multiplayer.has_multiplayer_peer() and source.owner_peer==multiplayer.get_unique_id():
   remote_grab.rpc(source.climber_id,target.climber_id,_limb,str(other.get_meta("piece","")))
@rpc("any_peer","call_remote","reliable")
func remote_grab(source_id: int,target_id: int,limb: int,piece: String) -> void:
 var sender:=multiplayer.get_remote_sender_id()
 if sender<=0 or limb<0 or limb>=4:return
 var source: Climber
 var target: Climber
 for ref in actors:
  var actor=ref.get_ref()
  if not is_instance_valid(actor):continue
  if actor.climber_id==source_id and actor.owner_peer==sender:source=actor
  if actor.climber_id==target_id:target=actor
 if source==null or target==null or source==target or target.state!=Climber.State.FROZEN:return
 if not target.bodies.has(piece):return
 var ref: WeakRef=effects.get(target.get_instance_id())
 if ref==null:return
 var effect: Node=ref.get_ref()
 if is_instance_valid(effect):effect.on_grab(target.bodies[piece].global_position)
func unwatch(effect: Node) -> void:
 for key in effects.keys():
  var node=effects[key].get_ref()
  if node==null or node==effect:effects.erase(key)
 if effects.is_empty():queue_free()
