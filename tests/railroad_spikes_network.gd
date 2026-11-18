extends Node
## Two isolated MultiplayerAPI branches / actual ENet loopback, one Godot process.
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
const Effect = preload("res://ui3d/railroad_spikes_effect.gd")
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
	game.roster = [{"pid":0,"peer":1,"name":"Test","appearance":{"effect":"railroad_spikes"}}]
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
	if server.create_server(38977,2) != OK or client.create_client("127.0.0.1",38977) != OK:
		push_error("Loopback port unavailable")
		get_tree().quit(2)
		return
	var host_api := SceneMultiplayer.new()
	host_api.multiplayer_peer = server
	var guest_api := SceneMultiplayer.new()
	guest_api.multiplayer_peer = client
	var host := replica("Host",host_api,-.7)
	var guest := replica("Guest",guest_api,.7)
	var deadline := Time.get_ticks_msec()+4000
	while host_api.get_peers().is_empty() and Time.get_ticks_msec()<deadline:
		await get_tree().process_frame
	check(not host_api.get_peers().is_empty(),"Actual ENet connection")
	var actor: Climber = host.climbers[42]
	var remote: Climber = guest.climbers[42]
	host._rpc_freeze.rpc(42,actor.pose(),"made","locked",2.0,2.0,true)
	await get_tree().create_timer(1.8).timeout
	check(actor.has_meta(Effect.MARKER) and remote.has_meta(Effect.MARKER),"Both peers received authoritative pin event")
	if actor.has_meta(Effect.MARKER) and remote.has_meta(Effect.MARKER):
		var a = actor.get_meta(Effect.MARKER)
		var b = remote.get_meta(Effect.MARKER)
		check(a.settled and b.settled,"Both peers settle")
		check(a.burst_profile != b.burst_profile,"Each viewer gets local flight profile")
		for i in 4:
			check((-a.pins[i].global_basis.z.normalized()).dot(a.launch_axes[i])>.9999,"Host retains own incoming angle")
			check((-b.pins[i].global_basis.z.normalized()).dot(b.launch_axes[i])>.9999,"Guest retains own incoming angle")
		check(not a.targets[0].is_equal_approx(b.targets[0]),"Different viewers may retain different cosmetic incoming directions")
		host._rpc_freeze.rpc(42,actor.pose(),"made","locked",2.0,2.0,true)
		await get_tree().create_timer(.2).timeout
		check(actor.get_meta(Effect.MARKER)==a and remote.get_meta(Effect.MARKER)==b,"Duplicate network event never creates extra pins")
		var expected: Array = []
		for pin in a.pins: expected.append(pin.global_transform)
		actor.remove_meta(Effect.MARKER)
		a.queue_free()
		await get_tree().process_frame
		a = Prep.attach("railroad_spikes",actor,null,false)
		check(a.settled and a.starts.is_empty(),"Fresh settled restoration skips replay")
		for i in 4: check(a.pins[i].global_transform.is_equal_approx(expected[i]),"Same-owner stored presentation restores exact final roll and tip")
		var references: Array = a.pins.duplicate()+b.pins.duplicate()
		host._drop_climber(42)
		guest._drop_climber(42)
		await get_tree().process_frame
		await get_tree().process_frame
		check(references.all(func(pin): return not is_instance_valid(pin)),"Both peers clean attachment ownership")
	server.close()
	client.close()
	print("RAILROAD_NETWORK ",JSON.stringify({"failures":failures,"transport":"ENet loopback; two MultiplayerAPI branches; one process","late_join":"not enabled; settled restore separately tested"}))
	get_tree().quit(failures)
