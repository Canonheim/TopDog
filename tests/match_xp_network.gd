extends Node
var host_game: Game
var guest_game: Game
var fails := 0
var received := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		fails+=1
		push_error(message)
func branch(label: String, server: bool) -> Game:
	var root := Node.new()
	root.name=label
	add_child(root)
	var api:=SceneMultiplayer.new()
	get_tree().set_multiplayer(api,root.get_path())
	var peer:=ENetMultiplayerPeer.new()
	if server: check(peer.create_server(38726,2)==OK,"server")
	else: check(peer.create_client("127.0.0.1",38726)==OK,"client")
	api.multiplayer_peer=peer
	var world:=Node3D.new()
	root.add_child(world)
	var g:=Game.new()
	g.name="Game"; g.world=world; g.dress=false
	root.add_child(g)
	return g
func _ready() -> void:
	get_tree().create_timer(20).timeout.connect(func(): push_error("XP NETWORK TIMEOUT");get_tree().quit(1))
	Game.grow_spawns=false
	host_game=branch("Server",true)
	guest_game=branch("Client",false)
	while host_game.multiplayer.get_peers().is_empty(): await get_tree().process_frame
	await get_tree().create_timer(.2).timeout
	var guest_id:int=host_game.multiplayer.get_peers()[0]
	var roster: Array=[{"pid":0,"name":"A","peer":1,"slot":0,"tint":Color.WHITE},{"pid":1,"name":"B","peer":guest_id,"slot":0,"tint":Color.WHITE}]
	check(host_game.host_start({"mode":"scramble","timer":60,"base":"barrel","stage":"plaza"},roster),"start")
	while guest_game.live.size()<2: await get_tree().process_frame
	host_game.set_physics_process(false); guest_game.set_physics_process(false)
	var notices: Array=[]
	guest_game.xp_achievement.connect(func(title,amount,_player): notices.append([title,amount]))
	var cid:int=guest_game.live[1]
	var other:int=host_game.live[0]
	var victim:Climber=guest_game.climbers[cid]
	guest_game._rpc_pose.rpc(cid,999,victim.pose(),false,true)
	await get_tree().create_timer(.1).timeout
	check(host_game._xp_airborne.get(cid,false),"guest airborne flag reached host")
	# Host judges a real chair impact; owner confirms the resulting knockout.
	host_game.chair.holder=other
	host_game._apply_chair_hits({cid:{"piece":"head","speed":10.0,"offset":Vector3.ZERO,"impulse":Vector3(10,0,0)*victim.bodies["head"].mass}})
	await get_tree().create_timer(.2).timeout
	check(victim.knockout_left>0,"owner receives knockout")
	check(host_game.xp_tracker.stats[0].knockouts==1,"host credits confirmed attacker")
	guest_game._rpc_knockout.rpc(cid,Sound.SFX["knockout"][0])
	await get_tree().create_timer(.1).timeout
	check(host_game.xp_tracker.stats[0].knockouts==1,"duplicate KO cannot earn twice")
	guest_game._rpc_stuck_landing.rpc_id(1,cid,1)
	await get_tree().create_timer(.1).timeout
	check(host_game.xp_tracker.stats[1].landings==1,"owner landing accepted")
	check(notices.has(["Stuck the landing",2000]),"owner receives live achievement")
	guest_game._rpc_stuck_landing.rpc_id(1,cid,1)
	guest_game._rpc_stuck_landing.rpc_id(1,other,2)
	await get_tree().create_timer(.1).timeout
	check(host_game.xp_tracker.stats[1].landings==1 and host_game.xp_tracker.stats[0].landings==0,"duplicate and forged-owner landings rejected")
	host_game.xp_tracker.elapsed=30
	host_game.xp_tracker.stats[0].active=10.0
	host_game.xp_tracker.stats[1].active=10.0
	host_game.xp_tracker.lock_in(0,1)
	host_game.alive[1]=false
	guest_game.match_over.connect(func(_res): received+=1)
	host_game._finish()
	await get_tree().create_timer(.2).timeout
	check(received==1,"guest gets one result")
	check(guest_game.results.xp[0].total==8400 and guest_game.results.xp[1].total==4500,"host payout reaches guest")
	check(guest_game.results.xp_match_id==host_game.settings.xp_match_id,"shared match ID")
	host_game._rpc_over.rpc(host_game.results)
	await get_tree().create_timer(.1).timeout
	check(received==1,"duplicate result suppressed")
	print("MATCH XP NETWORK fails=",fails)
	host_game.multiplayer.multiplayer_peer.close()
	guest_game.multiplayer.multiplayer_peer.close()
	get_tree().quit(fails)
