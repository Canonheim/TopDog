extends Node
var game: Game
var fails := 0
var host := false
var seen := false
func _ready():
 host=OS.get_cmdline_user_args().has("--server")
 var peer:=ENetMultiplayerPeer.new()
 if host: peer.create_server(38692,2)
 else: peer.create_client("127.0.0.1",38692)
 multiplayer.multiplayer_peer=peer
 var world:=Node3D.new()
 world.name="World"
 add_child(world)
 game=Game.new()
 game.name="Game"
 game.world=world
 game.dress=false
 add_child(game)
 get_tree().create_timer(18).timeout.connect(func():print("NET TIMEOUT");get_tree().quit(1))
 if host:
  while multiplayer.get_peers().is_empty(): await get_tree().process_frame
  await get_tree().create_timer(.3).timeout
  var remote:int=multiplayer.get_peers()[0]
  game.host_start({"mode":"tower","timer":60.0,"stage":"plaza","base":"barrel"},[{"pid":0,"name":"Host","peer":1,"slot":0,"tint":Color.WHITE},{"pid":1,"name":"Guest","peer":remote,"slot":0,"tint":Color.WHITE}])
  force_roll()
  while not seen: await get_tree().process_frame
  game.set_physics_process(false)
  game.pinata_director._collect.rpc(game.pinata_director.received_generation)
  await get_tree().create_timer(.4).timeout
  game._rpc_phase.rpc("between",0,game.line,0,-1)
  force_roll()
  game._rpc_phase.rpc("turn",60,game.line,1,0)
  await get_tree().create_timer(.5).timeout
  game._rpc_phase.rpc("between",0,game.line,1,-1)
  await get_tree().create_timer(.4).timeout
  _done.rpc()
 else:
  while not is_instance_valid(game.pinata_director.current): await get_tree().process_frame
  var item=game.pinata_director.current
  if item.contact_enabled: fails+=1
  _seen.rpc_id(1,item.position,item.rarity)
  while not item.taken: await get_tree().process_frame
  print("NET client received collection")
func force_roll():
 var r:=RandomNumberGenerator.new()
 for n in 1000:
  r.seed=n
  if r.randf()<.1:
   game.pinata_director.rng.seed=n
   return
@rpc("any_peer","call_remote","reliable")
func _seen(point:Vector3,rarity:int):
 if not host:return
 var item=game.pinata_director.current
 if not is_instance_valid(item) or item.position.distance_to(point)>.001 or item.rarity!=rarity: fails+=1
 seen=true
 print("NET synchronized spawn")
@rpc("authority","call_local","reliable")
func _done():
 if is_instance_valid(game.pinata_director.current): fails+=1
 print("NET ","host" if host else "client"," fails=",fails)
 get_tree().quit(fails)
