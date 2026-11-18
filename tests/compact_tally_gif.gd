extends Node
var folder:="C:/Users/growi/AppData/Local/Temp/topdog-plain-xp-restored-gif"
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(folder)
	var main=load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(2).timeout
	main.lucha.title_attract=false
	main.show_screen("title")
	var payout={"match_id":"gif-only","before_total":7000,"after_total":16950,"total":9950,"awarded":9950,"saved":true,"eligible":true,
		"rows":{"MATCH COMPLETE":2500,"VICTORY":4000,"KNOCKOUTS":0,"LOCK-INS":400,"FIRST LOCK-IN":400,"STUCK THE LANDING":2000,"UPWARD AIRTIME":650}}
	# A disposable frozen tower makes the remaining viewing area visible in the demo.
	var roster: Array=[{"pid":0,"name":"Captain Pug","peer":1,"slot":0,"tint":Color.WHITE},{"pid":1,"name":"Spiral","peer":1,"slot":1,"tint":Color.WHITE}]
	main.game.host_start({"mode":"scramble","timer":60,"base":"barrel","stage":"plaza"},roster)
	main.game.set_physics_process(false)
	Game.grow_spawns=false
	for i in 4:
		var cid:=200+i
		var pid:=i%2
		main.game._rpc_spawn(pid,cid,Vector2(-.25 if pid==0 else .25,2.1+i*1.15),str(roster[pid].name))
		var c:Climber=main.game.climbers[cid]
		c.freeze()
		c.set_glyphs([])
		main.game.tower.append(cid)
	main.game.live.clear()
	main.game.phase="over"
	main.game.results={"winner":0,"best":{0:7.3,1:6.2},"tower":4,"top":7.3,"local_xp":payout}
	main.show_screen("results")
	main.banner.text=""
	main.banner_t=0.0
	var board = main.lucha.menus.results
	assert(board.xp_panel.get_parent() == board._space)
	for frame in 220:
		await RenderingServer.frame_post_draw
		var picture:=get_viewport().get_texture().get_image()
		picture.resize(960,540,Image.INTERPOLATE_LANCZOS)
		picture.save_png(folder.path_join("%04d.png" % frame))
		await get_tree().process_frame
	print("COMPACT TALLY CAPTURE COMPLETE")
	get_tree().quit()
