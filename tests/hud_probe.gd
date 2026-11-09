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
	_check("past 99.99 m it holds at 99.99", _near(v, [9.0, 9.0, 9.0, 9.0], 0.02), v)
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
	_check("the nameplate names the climber in full, never clipped", hb._name_shown == "BARTHOLOMEW THE EXCEEDINGLY LONG-NAMED", hb._name_shown)
	_check("the odometer has four drums", hb._drums.size() == 4, hb._drums.size())
	await _shot("hud_bottom")
	main.game.line = -5.0
	await get_tree().create_timer(0.4).timeout
	_check("above the line the LOCK IN tab shows", hb._lock.is_visible_in_tree())
	await _shot("hud_lockin")
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
