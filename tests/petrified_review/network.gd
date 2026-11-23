extends Node3D
const Effect=preload("res://tests/petrified_review/effect.gd")
const Watch=preload("res://tests/petrified_review/grabs.gd")
func _ready() -> void:
 var server_root:=Node3D.new();server_root.name="ServerWorld";add_child(server_root)
 var client_root:=Node3D.new();client_root.name="ClientWorld";add_child(client_root)
 var server:=SceneMultiplayer.new();var client:=SceneMultiplayer.new()
 get_tree().set_multiplayer(server,server_root.get_path());get_tree().set_multiplayer(client,client_root.get_path())
 var sp:=ENetMultiplayerPeer.new();assert(sp.create_server(19987)==OK);server.multiplayer_peer=sp
 var cp:=ENetMultiplayerPeer.new();assert(cp.create_client("127.0.0.1",19987)==OK);client.multiplayer_peer=cp
 for frame in 180:
  if cp.get_connection_status()==MultiplayerPeer.CONNECTION_CONNECTED:break
  await get_tree().process_frame
 assert(cp.get_connection_status()==MultiplayerPeer.CONNECTION_CONNECTED)
 await Effect.prepare()
 var targets: Array=[]
 var watches: Array=[]
 var actors: Array=[]
 for root in [server_root,client_root]:
  var source:=Climber.new();source.climber_id=991;source.owner_peer=cp.get_unique_id();root.add_child(source);source.build(Vector2(5,0),root,Wardrobe.CLIMBER);source.freeze();actors.append(source)
  var target:=Climber.new();target.climber_id=992;target.owner_peer=1;root.add_child(target);target.build(Vector2(8,0),root,Wardrobe.CLIMBER);target.freeze();actors.append(target)
  var effect=Effect.attach(target,false);targets.append(effect)
  var watch:=Watch.new();watch.name="ReactionWatch";root.add_child(watch);watch.effects[target.get_instance_id()]=weakref(effect);watches.append(watch)
 for frame in 12:await get_tree().process_frame
 watches[1].remote_grab.rpc(991,992,0,"chest")
 for frame in 10:await get_tree().process_frame
 assert(targets[0].debris.bursts==1)
 watches[1].remote_grab.rpc(991,992,0,"chest")
 for frame in 10:await get_tree().process_frame
 assert(targets[0].debris.bursts==1)
 targets[0].debris.step(2.)
 watches[1].remote_grab.rpc(991,992,0,"chest")
 for frame in 10:await get_tree().process_frame
 assert(targets[0].debris.bursts==2)
 targets[0].debris.step(2.)
 watches[1].remote_grab.rpc(888,992,0,"chest")
 for frame in 10:await get_tree().process_frame
 assert(targets[0].debris.bursts==2)
 print("PETRIFIED_ENET_PASS remote grab, suppression, later retrigger, invalid source rejected")
 for actor in actors:actor.remove()
 cp.close();sp.close()
 await get_tree().process_frame
 get_tree().quit()
