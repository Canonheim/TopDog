extends Node
var folder:="C:/Users/growi/AppData/Local/Temp/topdog-finish-belt-gif"
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(folder)
	var main=load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(2).timeout
	main.lucha.title_attract=false
	main.show_screen("title")
	var payout={"match_id":"gif-only","before_total":7000,"after_total":16950,"total":9950,"awarded":9950,"saved":true,"eligible":true,
		"rows":{"MATCH COMPLETE":2500,"VICTORY":4000,"KNOCKOUTS":0,"LOCK-INS":400,"FIRST LOCK-IN":400,"STUCK THE LANDING":2000,"UPWARD AIRTIME":650}}
	main.game.results={"winner":-1,"best":{},"tower":5,"top":8.5,"local_xp":payout}
	main.show_screen("results")
	for frame in 220:
		await RenderingServer.frame_post_draw
		var picture:=get_viewport().get_texture().get_image()
		picture.resize(960,540,Image.INTERPOLATE_LANCZOS)
		picture.save_png(folder.path_join("%04d.png" % frame))
		await get_tree().process_frame
	print("FINISH BELT CAPTURE COMPLETE")
	get_tree().quit()
