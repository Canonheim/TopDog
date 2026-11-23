extends Node3D
const Loader=preload("res://game/match_effect_preloader.gd")
func wait_frame() -> void:await get_tree().process_frame
func _ready() -> void:
 # Compile the actual UI entry point, not just isolated effect fixtures.
 assert(load("res://game/main.gd")!=null)
 var game:=Game.new();game.world=self;game.dress=false;add_child(game)
 var roster=[{"pid":0,"peer":1,"slot":0,"name":"Test","appearance":{"effect":"pickles"}}]
 assert(game.host_start({"mode":"practice","stage":"dock","base":"barrel"},roster))
 assert(game.phase=="loading")
 var deadline:=Time.get_ticks_msec()+30000
 while game.phase=="loading" and Time.get_ticks_msec()<deadline:
  assert(game.climbers.is_empty())
  await wait_frame()
 assert(game.phase=="between")
 assert(game.effect_load_report.errors.is_empty())
 print("PRELOAD_OFFLINE_PASS ",JSON.stringify(game.effect_load_report))
 game.end_match();game.queue_free();await wait_frame()
 var machines: Array=[]
 for name in ["Host","Client"]:
  var holder:=Node.new();holder.name=name;add_child(holder)
  var world:=Node3D.new();holder.add_child(world)
  var api:=SceneMultiplayer.new();get_tree().set_multiplayer(api,holder.get_path())
  var g:=Game.new();g.name="Game";g.world=world;g.dress=false;holder.add_child(g)
  machines.append({"holder":holder,"api":api,"game":g})
 var hp:=ENetMultiplayerPeer.new();assert(hp.create_server(19988)==OK);machines[0].api.multiplayer_peer=hp
 var cp:=ENetMultiplayerPeer.new();assert(cp.create_client("127.0.0.1",19988)==OK);machines[1].api.multiplayer_peer=cp
 for i in 180:
  if cp.get_connection_status()==MultiplayerPeer.CONNECTION_CONNECTED:break
  await wait_frame()
 assert(cp.get_connection_status()==MultiplayerPeer.CONNECTION_CONNECTED)
 for i in 12:await wait_frame()
 var host: Game=machines[0].game;var client: Game=machines[1].game
 roster=[{"pid":0,"peer":1,"slot":0,"name":"Host","appearance":{"effect":"pickles"}},{"pid":1,"peer":cp.get_unique_id(),"slot":0,"name":"Client","appearance":{"effect":"gold"}}]
 assert(host.host_start({"mode":"scramble","stage":"dock","base":"barrel"},roster))
 host.effect_load_pending[999]=true
 deadline=Time.get_ticks_msec()+30000
 while host.effect_load_pending.size()>1 and Time.get_ticks_msec()<deadline:
  assert(host.climbers.is_empty())
  await wait_frame()
 assert(host.phase=="loading" and client.phase=="loading")
 host._rpc_effects_ready("stale token",true)
 assert(host.effect_load_pending.has(999))
 host._on_peer_left(999)
 for i in 12:await wait_frame()
 assert(host.phase=="between" and client.phase=="between")
 print("PRELOAD_ENET_PASS both clients prepared, no early gameplay, stale ack rejected, disconnected waiter removed")
 host.end_match();client.end_match();cp.close();hp.close()
 for machine in machines:machine.holder.queue_free()
 await wait_frame();get_tree().quit()
