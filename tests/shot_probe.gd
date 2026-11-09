extends Node
## Screenshots of the 3D screens: -- --open=local|pause|results|hud|clock|pinata|chair --shot=PATH
func _ready() -> void:
	var open := "title"
	var shot := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--open="):
			open = a.get_slice("=", 1)
		elif a.begins_with("--shot="):
			shot = a.get_slice("=", 1)
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(0.8).timeout
	match open:
		"local":
			Players.clear_players()
			Players.fake[1000] = {"buttons": {}, "stick": Vector2.ZERO}
			Players.fake[1001] = {"buttons": {}, "stick": Vector2.ZERO}
			main.show_screen("local")
			Players.add_player(Players.KBM, "Parker the Barrel-Hugger")
			Players.add_player(1000, "Matilda the Goose-Toppler")
			Players.add_player(1001, "Yorick the Anvil-Wrangler")
		"clock":
			Players.clear_players()
			Players.add_player(Players.ANY, "Parker the Barrel-Hugger")
			main.local_mode = true
			main.game.host_start({"mode": "tower", "timer": 60.0, "spawn": "alternate", "stage": "plaza"},
				[{"pid": 0, "name": "Parker the Barrel-Hugger", "tint": Color.RED, "peer": 1, "slot": 0}])
			main.show_screen("hud")
		"pinata":
			# The title, the camera swung back to the plaza, and the pinata burst.
			await get_tree().create_timer(0.6).timeout
			main.lucha.burst_pinata()
		"chair":
			# Practice, then a chair floated in its bubble above the tower (the bubble's ink).
			main._start_practice()
			await get_tree().create_timer(2.0).timeout
			var g = main.game
			g._rpc_spawn_chair(g.chair_generation + 1, g.tower_peak(), Vector2i(9, 12))
			# Floated between the two climbers, at chest height, so it sits in frame.
			var mid := Vector2.ZERO
			for c in g.climbers.values():
				mid += c.centre_of_mass() / float(g.climbers.size())
			g.chair.float_above(mid - Vector2(0.0, g.chair.PICKUP_HEIGHT - 0.6))
		"hud", "pause", "results":
			main._start_practice()
			await get_tree().create_timer(2.0).timeout
			if open == "pause":
				main._toggle_pause()
			elif open == "results":
				main.game.roster = [{"pid": 0, "name": "Parker", "peer": 1, "slot": 0}, {"pid": 1, "name": "Matilda", "peer": 2}, {"pid": 2, "name": "Yorick", "peer": 3}]
				main.game.results = {"winner": 0, "best": {0: 6.42, 1: 5.71, 2: 4.38}, "tower": 7, "top": 8.1}
				main.show_screen("results")
				var peak: Vector2 = main._results_peak
				main._results_peak = Vector2(2, 9)
				var initial: Vector3 = main.cam.position
				main._tick_camera(main.PODIUM_HOLD_SECONDS * Engine.time_scale)
				assert(main.cam.position.is_equal_approx(initial))
				main._tick_camera(1.0 * Engine.time_scale)
				assert(is_equal_approx(initial.distance_to(main.cam.position), main.TOWER_PAN_SPEED))
				var journey: float = Vector2(0, 1.5).distance_to(Vector2(2, 9)) / main.TOWER_PAN_SPEED
				main._tick_camera((journey - 1.0) * Engine.time_scale)
				assert(main.cam.position.is_equal_approx(Vector3(2, 9.5, 9)))
				main._tick_camera(Engine.time_scale)
				assert(main.cam.position.y < 9.5)
				main._tick_camera(journey * Engine.time_scale)
				assert(main.cam.position.is_equal_approx(initial))
				main._results_peak = peak
				main._results_elapsed = 0.0
				main._tick_camera(0.0)
	await get_tree().create_timer(2.2).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(shot)
	print("SHOT ", shot)
	get_tree().paused = false
	get_tree().quit()
