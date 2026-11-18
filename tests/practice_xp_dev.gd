extends Node
const P=preload("res://core/player_progression.gd")
var folder := "C:/Users/growi/AppData/Local/Temp/topdog-complete-star-falls-gif"
func key(main: Node, code: int, echo := false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	event.echo = echo
	main._input(event)
func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	get_tree().create_timer(40).timeout.connect(func(): push_error("DEV TEST TIMEOUT"); get_tree().quit(1))
	DirAccess.make_dir_recursive_absolute(folder)
	var main=load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(2).timeout
	main.lucha.title_attract=false
	main.show_screen("title")
	var actual_before=P.load_snapshot()
	var path=OS.get_environment("TEMP").path_join("topdog-dev-test-%s.cfg" % Time.get_ticks_usec())
	main.dev_xp_save_path=path
	assert(P.grant("seed",9500,path).ok)
	key(main,KEY_F4)
	assert(main.dev_mode and main._dev_label.is_visible_in_tree())
	main.show_screen("options")
	assert(main._dev_label.is_visible_in_tree())
	key(main,KEY_KP_ADD)
	assert(P.read_save(path).total==9500)
	main._start_practice()
	await get_tree().create_timer(.5).timeout
	var phase=main.game.phase
	var ids=main.game.climbers.keys()
	key(main,KEY_KP_ENTER)
	assert(main.screen=="results" and get_tree().paused and main._dev_results_preview)
	assert(not main.game.pinata_director.practice_spawn_queued)
	var categories: Array = []
	main.lucha.menus.results.xp_panel.category_started.connect(func(title): categories.append(title))
	key(main,KEY_KP_ADD)
	assert(main._dev_payout.rows.values() == [1500,1500,1500])
	key(main,KEY_KP_ADD,true)
	assert(P.read_save(path).total==14000)
	var capture := not "--no-capture" in OS.get_cmdline_user_args()
	if not capture: await main.lucha.menus.results.xp_panel.tally_finished
	for frame in (220 if capture else 0):
		await RenderingServer.frame_post_draw
		var picture=get_viewport().get_texture().get_image()
		picture.resize(960,540,Image.INTERPOLATE_LANCZOS)
		picture.save_png(folder.path_join("%04d.png" % frame))
		await get_tree().process_frame
	assert(categories == ["DEV REWARD 1", "DEV REWARD 2", "DEV REWARD 3"])
	assert(main.lucha.menus.results.xp_panel.tally_complete)
	assert(main.lucha.menus.results.xp_panel.belt._shown_total==14000)
	main.leave_results()
	assert(main.screen=="hud" and not get_tree().paused)
	assert(main.game.phase==phase and main.game.climbers.keys()==ids)
	assert(main._dev_label.is_visible_in_tree())
	key(main,KEY_KP_ADD)
	assert(P.read_save(path).total==18500)
	key(main,KEY_ENTER)
	assert(main.screen=="hud")
	key(main,KEY_KP_ENTER)
	assert(main._dev_results_preview)
	key(main,KEY_KP_ENTER)
	assert(main.screen=="hud" and not get_tree().paused)
	key(main,KEY_KP_ENTER)
	key(main,KEY_F4,true)
	assert(main.dev_mode)
	key(main,KEY_F4)
	assert(main.screen=="hud" and not get_tree().paused)
	assert(not main.dev_mode and not main._dev_label.visible)
	key(main,KEY_KP_ADD)
	assert(P.read_save(path).total==18500)
	assert(P.load_snapshot()==actual_before)
	DirAccess.remove_absolute(path)
	print("PRACTICE DEV PASS: global indicator, three isolated 1500 rewards, repeat guard, results tally, resume, real save unchanged")
	get_tree().quit()
