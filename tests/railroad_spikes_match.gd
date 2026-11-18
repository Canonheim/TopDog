extends Node
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
const Effect = preload("res://ui3d/railroad_spikes_effect.gd")
var output := ""
var skin := 0
var frame := 0
var failures := 0
var capture := false
func check(ok: bool,label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)
func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--skin="): skin = int(arg.trim_prefix("--skin="))
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
	var original := Wardrobe.profiles.duplicate(true)
	var main = load("res://game/main.tscn").instantiate()
	add_child(main)
	Wardrobe.profiles[Wardrobe.selected].effect = "railroad_spikes"
	Wardrobe.profiles[Wardrobe.selected].head = skin
	check(Wardrobe.clean(Wardrobe.for_slot(0)).effect == "railroad_spikes","Selection survives sanitization")
	check(Net._clean_players([{"name":"Pins","slot":0,"appearance":Wardrobe.for_slot(0)}])[0].appearance.effect == "railroad_spikes","Network appearance keeps effect")
	check(Wardrobe.EFFECT_METADATA.railroad_spikes.rarity == "rare","Rare metadata")
	main.show_screen("customize")
	check("Railroad Spikes" in main.screens.customize.menu.items[4].options,"Menu name")
	main.lucha.play_lock_effect("railroad_spikes")
	check(main.screens.customize.preview.has_meta(Effect.MARKER),"Menu previews attached effect")
	await get_tree().create_timer(.8).timeout
	main._start_practice()
	await get_tree().create_timer(1.2).timeout
	var players: Array = main.game.live_climbers()
	check(not players.is_empty(),"Actual practice climber")
	if players.is_empty(): get_tree().quit(1); return
	var climber: Climber = players[0]
	check(not climber.has_meta(Effect.MARKER),"No pins before lock")
	check(Effect.attach(climber,main.cam) == null,"Live climber rejects pinning")
	var body_count: int = climber.bodies.size()
	if output != "":
		# Review framing only: actual frozen pose and effect code remain unchanged.
		main.set_process(false)
		var centre: Vector2 = climber.centre_of_mass()
		var focus := Vector3(centre.x,centre.y,0)
		main.cam.global_position = focus+Vector3(0,0,5.6)
		main.cam.look_at(focus,Vector3.UP)
	var pose := climber.pose()
	main.game._rpc_freeze(climber.climber_id,pose,"made","locked",climber.top_height(),main.game.line,true)
	if output != "":
		for overlay in main.cam.get_children():
			if overlay is Node3D: overlay.hide()
	check(climber.has_meta(Effect.MARKER),"Authoritative lock handler attaches pins")
	check(climber.bodies.size() == body_count,"No gameplay bodies added")
	var effect: Node = climber.get_meta(Effect.MARKER)
	check(Prep.attach("railroad_spikes",climber,main.cam) == effect,"Duplicate event reuses pins")
	if output != "":
		DirAccess.make_dir_recursive_absolute(output)
		RenderingServer.frame_post_draw.connect(_capture)
		capture = true
	await get_tree().create_timer(3.3).timeout
	check(effect.settled and effect.pins.size() == 4,"Pins persist after timed effects end")
	if output != "":
		capture = false
		var foot_mid: Vector3 = (climber.bodies.foot_l.global_position+climber.bodies.foot_r.global_position)*.5
		main.cam.global_position = foot_mid+Vector3(0,.06,1.15)
		main.cam.look_at(foot_mid,Vector3.UP)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(output+"/feet.png")
		main.cam.global_position = foot_mid+Vector3(.85,.15,.75)
		main.cam.look_at(foot_mid,Vector3.UP)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(output+"/feet_side.png")
	var poses: Array = effect.targets.duplicate()
	check(Prep.attach("railroad_spikes",climber,main.cam,false) == effect,"Settled restore idempotent")
	check(effect.targets == poses,"Restore leaves pose unchanged")
	var pins: Array = effect.pins.duplicate()
	main.game._drop_climber(climber.climber_id)
	await get_tree().process_frame
	await get_tree().process_frame
	check(pins.all(func(pin): return not is_instance_valid(pin)),"Actual climber removal cleans pins")
	Wardrobe.profiles = original
	print("RAILROAD_MATCH ",JSON.stringify({"failures":failures,"frames":frame,"network_scope":"shared authoritative RPC handler plus appearance serialization; no live two-peer session"}))
	if DisplayServer.get_name() == "headless": get_tree().quit(failures)
	else: await main.quit_game()
func _capture() -> void:
	if not capture: return
	var shot := get_viewport().get_texture().get_image()
	shot.resize(960,540,Image.INTERPOLATE_LANCZOS)
	shot.save_png(output+"/%03d.png" % frame)
	frame += 1
	if frame >= 180: capture = false

