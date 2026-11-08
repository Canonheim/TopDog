extends Node
## Screenshots of the 3D screens: -- --open=local|pause|results|hud --shot=PATH
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
		"hud", "pause", "results":
			main._start_practice()
			await get_tree().create_timer(2.0).timeout
			if open == "pause":
				main._toggle_pause()
			elif open == "results":
				main.game.results = {"winner": 0, "best": {0: 6.42}, "tower": 7, "top": 8.1}
				main.show_screen("results")
	await get_tree().create_timer(2.2).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(shot)
	print("SHOT ", shot)
	get_tree().paused = false
	get_tree().quit()
