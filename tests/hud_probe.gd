extends Node
## The HUD bottom (windowed): the nameplate shows the climber, the odometer's drums
## read the height and roll over like a real one, and the lock-in tab shows above
## the line. -- --shots=DIR saves hud_bottom.png and hud_lockin.png there.
var fails := 0
var shots := ""


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shots="):
			shots = a.get_slice("=", 1)
	# The drum maths first: 12.34 m reads 1 2 3 4; 9.995 m is mid-roll on every drum.
	var v: Array = LuchaHudBottom.drum_values(12.34)
	_check("12.34 m reads 1 2 3 4", _near(v, [1.0, 2.0, 3.0, 4.0], 0.02), v)
	v = LuchaHudBottom.drum_values(9.995)
	_check("9.995 m rolls every drum halfway (0.5 9.5 9.5 9.5)", _near(v, [0.5, 9.5, 9.5, 9.5], 0.02), v)
	v = LuchaHudBottom.drum_values(150.0)
	_check("past 100 m the drums read whole metres: 150 m reads 0 1 5 0", _near(v, [0.0, 1.0, 5.0, 0.0], 0.02), v)
	v = LuchaHudBottom.drum_values(1234.0)
	_check("1234 m reads 1 2 3 4", _near(v, [1.0, 2.0, 3.0, 4.0], 0.02), v)
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(0.8).timeout
	Players.clear_players()
	Players.add_player(Players.ANY, "Bartholomew the Exceedingly Long-Named")
	main.local_mode = true
	main.game.host_start({"mode": "tower", "timer": 60.0, "spawn": "alternate", "stage": "plaza"},
		[{"pid": 0, "name": "Bartholomew the Exceedingly Long-Named", "tint": Color.RED, "peer": 1, "slot": 0}])
	main.show_screen("hud")
	await get_tree().create_timer(2.0).timeout
	var hb: LuchaHudBottom = main.lucha.hud_bottom
	_check("the bottom shows in a turn", hb.is_visible_in_tree())
	# Parker 11-10: the plate holds the made name only; the Steam name goes top left.
	_check("the nameplate names the climber in full, never clipped", hb._name_shown == "BARTHOLOMEW THE EXCEEDINGLY LONG-NAMED", hb._name_shown)
	await get_tree().create_timer(3.0).timeout
	_check("...and keeps it (no cycling)", hb._name_shown == "BARTHOLOMEW THE EXCEEDINGLY LONG-NAMED", hb._name_shown)
	_check("offline there's no Steam name (top left stays empty)", hb.steam_shown == "" and main.lucha._steam_tag.get_child_count() == 0, hb.steam_shown)
	# Online, the climber's player's Steam name shows top left.
	Net.online = true
	Net.members[1] = {"name": "SteamPal", "players": [], "ready": true}
	await get_tree().create_timer(0.3).timeout
	_check("online, the Steam name shows top left", hb.steam_shown == "SteamPal" and main.lucha._steam_text == "STEAMPAL" and main.lucha._steam_tag.get_child_count() > 0, main.lucha._steam_text)
	await _shot("hud_steam_tag")
	Net.online = false
	Net.members.erase(1)
	_check("the odometer has four drums", hb._drums.size() == 4, hb._drums.size())
	_check("below the line the toast is down in its slot, and hidden", not hb.popped and hb._lock.position.y < 0.1 and not hb._lock.visible, hb._lock.position.y)
	# Uncovered, the plate is fully opaque again (exactly 0), so the screen ink outlines it.
	var plate_meshes: Array = hb._plate.find_children("*", "MeshInstance3D", true, false)
	main.cam.position += Vector3(0, 6, 0)
	main.set_process(false)
	await get_tree().create_timer(1.0).timeout
	_check("uncovered, the nameplate is fully opaque (inked)", plate_meshes.all(func(m): return m.transparency == 0.0), plate_meshes.map(func(m): return m.transparency))
	main.set_process(true)
	await get_tree().create_timer(0.5).timeout
	await _shot("hud_bottom")
	# A banner up top lifts the clock out of the frame; it drops back after.
	main.lucha._on_announce("Winifred the Drawbridge-Scrambler's turn", true)
	await get_tree().create_timer(0.6).timeout
	_check("with a banner up, the clock waits above the frame", main.lucha._clock_up > 2.0, main.lucha._clock_up)
	await _shot("hud_banner_up")
	main.lucha._on_announce("The line moved! Climb higher.", false)
	await get_tree().create_timer(0.6).timeout
	await _shot("hud_banner_note")
	await get_tree().create_timer(4.0).timeout
	_check("after the banner flies out, the clock is back", main.lucha._clock_up == 0.0 and not main.lucha._banner.visible, main.lucha._clock_up)
	main.game.line = -5.0
	await get_tree().create_timer(0.4).timeout
	_check("above the line the LOCK IN toast pops up", hb.popped and hb._lock.position.y > 0.25 and hb._lock.visible, hb._lock.position.y)
	await _shot("hud_lockin")
	# THE COUNTDOWN PULSE (Parker 11-09): at 10 the number lands big and thumps back.
	var clock_text: Node3D = main.lucha._clock_text
	_check("above 10 the clock rests at its size", is_equal_approx(clock_text.scale.x, 1.0), clock_text.scale.x)
	main.game.clock = 9.95  # just inside 10, a whole second before 9 pulses
	var peak_scale := 0.0  # the springy pulse crosses 1.0 as it settles: take its biggest
	for k in 12:
		await get_tree().process_frame
		peak_scale = maxf(peak_scale, clock_text.scale.x)
	# It starts at 1.6x; how much of that a check sees depends on the frame time.
	_check("at 10 the clock number pulses big", peak_scale > 1.1 and main.lucha._pulse_tween != null, peak_scale)
	await get_tree().create_timer(0.45).timeout
	_check("...and settles back", absf(clock_text.scale.x - 1.0) < 0.05, clock_text.scale.x)
	_check("the countdown ticks from 10", LuchaUI.COUNTDOWN_FROM == 10)
	var player: Climber = main.game.live_climbers()[0]
	player.release_all()
	player.set_physics_process(false)
	for body: RigidBody3D in player.bodies.values():
		body.freeze = true
		body.global_position += Vector3(0, 15, 0)
		Climber.sync_server(body)
	await get_tree().create_timer(0.4).timeout
	_check("airborne above the line hides LOCK IN", not hb.popped)
	var rival: Climber = preload("res://climber/climber.gd").new()
	main.world.add_child(rival)
	player.limbs[0].grab_other = rival
	player.limbs[0].grab_climber = rival
	hb.tick(0.5)
	_check("holding a live climber hides LOCK IN", not hb.popped)
	rival.state = Climber.State.FROZEN
	await get_tree().physics_frame  # (touches_solid answers once per physics frame since the 11-10 sweep)
	hb.tick(0.5)
	_check("holding the frozen tower shows LOCK IN", hb.popped)
	# THE STEADY TAB (Parker 11-09: "flashing oddly"): a hold flickering live / frozen
	# every frame at the line never drops the tab.
	var flips := 0
	var was: bool = hb.popped
	for k in 30:
		rival.state = Climber.State.LIVE if k % 2 == 0 else Climber.State.FROZEN
		hb.tick(1.0 / 60.0)
		if hb.popped != was:
			flips += 1
			was = hb.popped
	_check("a lock-in flickering every frame doesn't flash the tab", flips == 0, "%d flips" % flips)
	rival.state = Climber.State.FROZEN
	player.limbs[0].grab_other = null
	player.limbs[0].grab_climber = null
	rival.queue_free()
	# Past 100 m: whole metres, the decimal point hidden.
	hb.test_height = 150.0
	await get_tree().create_timer(1.2).timeout
	_check("past 100 m the decimal point hides", hb._odo_point == null or not hb._odo_point.visible)
	await _shot("hud_odo_150")
	print("HUD RESULT fails=", fails)
	get_tree().quit(fails)


func _near(a: Array, b: Array, eps: float) -> bool:
	for i in a.size():
		if absf(float(a[i]) - float(b[i])) > eps:
			return false
	return true


func _check(label: String, ok: bool, extra = "") -> void:
	print(("PASS  " if ok else "FAIL  ") + label + ("" if str(extra) == "" else "  [%s]" % str(extra)))
	if not ok:
		fails += 1


func _shot(n: String) -> void:
	if shots == "":
		return
	await get_tree().create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(shots.path_join(n + ".png"))
