extends Node
## Two isolated MultiplayerAPI branches / actual ENet loopback, one Godot process.
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
const Effect = preload("res://ui3d/lightning_effect.gd")
var failures := 0
func check(ok: bool,label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)
func replica(label: String, api: SceneMultiplayer, camera_x: float) -> Game:
	var branch := Node.new()
	branch.name = label
	add_child(branch)
	get_tree().set_multiplayer(api,branch.get_path())
	var world := Node3D.new()
	branch.add_child(world)
	var camera := Camera3D.new()
	world.add_child(camera)
	camera.position = Vector3(camera_x,1,5)
	var game := Game.new()
	game.name = "Game"
	game.world = world
	game.dress = false
	branch.add_child(game)
	game.set_process(false)
	game.set_physics_process(false)
	game.roster = [{"pid":0,"peer":1,"name":"Test","appearance":{"effect":"lightning"}}]
	var actor := Climber.new()
	actor.climber_id = 42
	actor.player_id = 0
	game.add_child(actor)
	actor.build(Vector2.ZERO,world,Wardrobe.PUG)
	actor.make_puppet()
	actor.set_physics_process(false)
	game.climbers[42] = actor
	game.live[0] = 42
	game.attached_lock_effect.connect(func(id: String, c: Climber): Prep.attach(id,c,camera))
	return game
func _ready() -> void:
	var server := ENetMultiplayerPeer.new()
	var client := ENetMultiplayerPeer.new()
	if server.create_server(38978,2)!=OK or client.create_client("127.0.0.1",38978)!=OK:
		push_error("Loopback port unavailable")
		get_tree().quit(2)
		return
	var host_api := SceneMultiplayer.new()
	host_api.multiplayer_peer=server
	var guest_api := SceneMultiplayer.new()
	guest_api.multiplayer_peer=client
	var host := replica("Host",host_api,-.7)
	var guest := replica("Guest",guest_api,.7)
	var deadline := Time.get_ticks_msec()+4000
	while host_api.get_peers().is_empty() and Time.get_ticks_msec()<deadline: await get_tree().process_frame
	check(not host_api.get_peers().is_empty(),"Actual ENet connection")
	var actor: Climber = host.climbers[42]
	var remote: Climber = guest.climbers[42]
	host._rpc_freeze.rpc(42,actor.pose(),"made","locked",2.0,2.0,true)
	await get_tree().create_timer(.1).timeout
	var a = actor.get_node_or_null("LightningStrike")
	var b = remote.get_node_or_null("LightningStrike")
	check(a!=null and b!=null,"Both peers receive transient strike event")
	if a!=null and b!=null:
		check(a.impact.is_equal_approx(b.impact),"Host and guest share exact highest impact point")
		check(a.bolts.size()==3 and b.bolts.size()==3,"Three bolts per peer")
	await get_tree().create_timer(Effect.TOTAL_SECONDS+.25).timeout
	check(not is_instance_valid(a) and not is_instance_valid(b),"Both peers clean transient effect")
	host._rpc_freeze.rpc(42,actor.pose(),"made","locked",2.0,2.0,true)
	await get_tree().create_timer(.1).timeout
	check(not actor.has_node("LightningStrike") and not remote.has_node("LightningStrike"),"Repeated network freeze cannot replay strikes")
	check(Prep.attach("lightning",actor,null,false)==null,"Snapshot restoration does not replay")
	host._drop_climber(42)
	guest._drop_climber(42)
	server.close()
	client.close()
	print("LIGHTNING_NETWORK ",JSON.stringify({"failures":failures,"transport":"ENet loopback; two MultiplayerAPI branches","late_join":"not enabled; snapshot no-replay verified"}))
	get_tree().quit(failures)
