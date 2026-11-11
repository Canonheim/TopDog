extends Node
var failures := 0
func check(ok: bool, label: String) -> void:
	print(("PASS " if ok else "FAIL ") + label)
	if not ok:
		failures += 1
func _ready() -> void:
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(1.0).timeout
	check(main.lucha.menus.practice_settings.items.size() == 4, "Practice setup contains only Fight, Mode, Base and Leave")
	main.game.practice = false
	main.show_screen("pause")
	check(not main.lucha.menus.pause.items.any(func(item): return item.get("label", "") == "AI SETTINGS"), "AI settings absent from normal match pause")
	main.game.practice = true
	main.show_screen("pause")
	check(main.lucha.menus.pause.items.any(func(item): return item.get("label", "") == "AI SETTINGS"), "AI settings present in practice pause")
	get_tree().paused = true
	main.show_screen("practice_ai")
	check(main.lucha.menus.practice_ai.visible and get_tree().paused, "AI settings retain paused world")
	var labels: Array = main.lucha.menus.practice_ai.items.map(func(item): return item.get("label", ""))
	check(labels == ["NO NPC", "STATIONARY", "CLIMB EASY", "CLIMB HARD", "BACK"], "All difficulty choices available")
	main._back()
	check(main.screen == "pause" and get_tree().paused, "Back returns to pause without resuming")
	main._toggle_pause()
	check(not get_tree().paused and main.screen == "hud", "Resume restores play")
	main._start_practice()
	await get_tree().create_timer(1.2).timeout
	main._toggle_pause()
	main.show_screen("practice_ai")
	for level in ["stationary", "easy", "hard"]:
		main.lucha.menus.practice_ai.items[0].cb.call()
		check(main.game.partner == null and main.screen == "practice_ai", "No NPC applies without closing AI menu")
		var index: int = ["none", "stationary", "easy", "hard"].find(level)
		main.lucha.menus.practice_ai.items[index].cb.call()
		check(main.screen == "practice_ai" and main.game.partner.difficulty == level, level + " applies without closing AI menu")
		var bot = main.game.partner
		var head: RigidBody3D = bot.bodies.head
		check(not bot.growing() and head.global_position.y - bot.spawn_at.y > 1.2, "Paused " + level + " spawn is full size immediately")
		check(not head.freeze and head.collision_layer == Climber.LAYER_LIVE, "Paused " + level + " spawn has live physics ready for resume")
		await get_tree().create_timer(0.1).timeout
		check(get_tree().paused and main.game.partner == bot, "NPC spawning leaves match paused")
	var existing = main.game.partner
	main.lucha.menus.practice_ai.items[1].cb.call()
	check(main.game.partner == existing and existing.difficulty == "stationary" and main.screen == "practice_ai", "Changing mode updates existing NPC and keeps menu open")
	main._back()
	main._toggle_pause()
	await get_tree().create_timer(0.3).timeout
	check(main.game.partner != null and not main.game.partner.growing(), "NPC stays fully spawned after resume")
	main.game.set_practice_ai("none")
	main.game.set_practice_ai("stationary")
	check(main.game.partner.growing(), "Live NPC spawn keeps normal grow-in animation")
	await get_tree().create_timer(1.0).timeout
	check(not main.game.partner.growing(), "Live NPC grow-in completes normally")
	main.game.end_match()
	get_tree().quit(failures)
