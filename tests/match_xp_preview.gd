extends Node
func _ready() -> void:
	var main=load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(2).timeout
	main.lucha.title_attract=false
	main.show_screen("title")
	main.lucha.xp_display.set_progress(preload("res://core/player_progression.gd").snapshot(6750))
	await get_tree().create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("xp-new-curve.png"))
	main.game.results={"winner":-1,"best":{},"tower":5,"top":8.0,"local_xp":{
		"eligible":true,"saved":true,"total":10150,"awarded":10150,
		"rows":{"MATCH COMPLETE":2500,"VICTORY":4000,"KNOCKOUTS":0,"LOCK-INS":200,"FIRST LOCK-IN":200,"STUCK THE LANDING":3000,"UPWARD AIRTIME":250}}}
	main.show_screen("results")
	await get_tree().create_timer(2).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("xp-match-payout.png"))
	print("XP PAYOUT PREVIEW COMPLETE")
	get_tree().quit()
