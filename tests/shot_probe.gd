extends Node
## Screenshots of the 3D screens: -- --open=local|pause|results|hud|clock|pinata|chair --shot=PATH
func _ready() -> void:
	var open := "title"
	var shot := ""
	var wait := 2.2  # --wait=S: seconds before the shot (a banner clears in about 5)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--open="):
			open = a.get_slice("=", 1)
		elif a.begins_with("--shot="):
			shot = a.get_slice("=", 1)
		elif a.begins_with("--wait="):
			wait = float(a.get_slice("=", 1))
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(0.8).timeout
	match open:
		"practice_settings":
			main._open_practice()
		"browse_list":
			main.show_screen("browse")
			main.lucha.online._on_lobby_list([
				{"id": 1, "name": "Canondorf's Climb", "mode_line": "Classic", "count_text": "1/12", "joinable": true},
				{"id": 2, "name": "Second Ring", "mode_line": "Tower", "count_text": "2/12", "joinable": true},
				{"id": 3, "name": "Third Ring", "mode_line": "Classic", "count_text": "3/12", "joinable": true},
				{"id": 4, "name": "Fourth Ring", "mode_line": "Tower", "count_text": "4/12", "joinable": true}
			])
		"pauseinput":
			main._start_practice()
			await get_tree().create_timer(1.2).timeout
			for action in ["Escape", "Select"]:
				# Both mapped inputs arrive through the same consumable pause edge.
				Players._pause_edge[0] = true
				main._process(0.0)
				assert(main.screen == "pause" and get_tree().paused, action + " must open practice pause")
				Players._pause_edge[0] = true
				main._process(0.0)
				assert(main.screen == "hud" and not get_tree().paused, action + " must resume")
			print("PASS practice pause edges open and resume exactly once")
		"lobby":
			Net.online = true
			Net.members = {1: {"name": "Host", "players": [], "ready": true}, 2: {"name": "Guest", "players": [{"name": "Guest", "tint": Color.WHITE, "slot": 0}], "ready": true}}
			main.show_screen("lobby")
			main._sync_waiting_room()
		"customize":
			main.show_screen("customize")
		"options":
			var original := DisplayServer.window_get_mode()
			main.show_screen("options")
			var button: Button = main.screens.options.find_child("FullscreenToggle", true, false)
			assert(button != null and button.toggle_mode and button.focus_mode == Control.FOCUS_ALL)
			main._set_fullscreen(true, false)
			await get_tree().create_timer(0.4).timeout
			assert(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
			main._set_fullscreen(false, false)
			await get_tree().create_timer(0.4).timeout
			assert(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED)
			DisplayServer.window_set_mode(original)
			print("PASS fullscreen and windowed modes toggle correctly")
		"hudfade":
			main._start_practice()
			await get_tree().create_timer(1.2).timeout
			main.set_process(false)
			main.cam.position = Vector3(0, 6, 9)
			main.cam.look_at(Vector3(0, 5.5, 0), Vector3.UP)
			main.game.set_physics_process(false)
			if main.game.partner != null:
				main.game.partner.remove()
				main.game.partner = null
			var c: Climber = main.game.live_climbers()[0]
			c.freeze()
			var plate: Node3D = main.lucha.hud_bottom._plate
			var pixel: Vector2 = main.cam.unproject_position(plate.global_position)
			var target: Vector3 = main.cam.project_position(pixel, 9.0)
			var offset := Vector2(target.x, target.y) - c.centre_of_mass()
			var pose := c.pose()
			for k in range(0, pose.size(), 3):
				pose[k] += offset.x
				pose[k + 1] += offset.y
			c.apply_pose(pose)
			main.lucha._tick_hud_occlusion(1.0)
			var mesh: GeometryInstance3D = plate.find_children("*", "GeometryInstance3D", true, false)[0]
			assert(mesh.transparency > 0.8)
			for k in range(0, pose.size(), 3):
				pose[k] += 100
			c.apply_pose(pose)
			main.lucha._tick_hud_occlusion(1.0)
			assert(mesh.transparency < 0.01)
			for k in range(0, pose.size(), 3):
				pose[k] -= 100
			c.apply_pose(pose)
			c.make_puppet()
			main.lucha._tick_hud_occlusion(1.0)
			assert(mesh.transparency > 0.8)
			print("PASS HUD fades for tower and remote climbers, restores when clear")
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
				main._tick_camera(main.PODIUM_SHIFT_SECONDS * Engine.time_scale)
				assert(main.cam.position.is_equal_approx(Vector3(0, 2, 9)))
				var journey: float = Vector2(0, 1.5).distance_to(Vector2(2, 9)) / main.TOWER_PAN_SPEED
				main._tick_camera(journey * Engine.time_scale)
				assert(main.cam.position.is_equal_approx(Vector3(2, 9.5, 9)))
				main._tick_camera(journey * Engine.time_scale)
				assert(main.cam.position.is_equal_approx(Vector3(0, 2, 9)))
				assert(not main.cam.position.is_equal_approx(initial))
				main._tick_camera(journey * Engine.time_scale)
				assert(main.cam.position.is_equal_approx(Vector3(2, 9.5, 9)))
				main._results_peak = peak
				main._results_elapsed = 0.0
				main._tick_camera(0.0)
	await get_tree().create_timer(wait).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(shot)
	print("SHOT ", shot)
	get_tree().paused = false
	get_tree().quit()
