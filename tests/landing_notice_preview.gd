extends Node
func _ready() -> void:
	var main=load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(2).timeout
	main.lucha.title_attract=false
	main._start_practice()
	await get_tree().create_timer(1.5).timeout
	var notice=main.find_child("RewardNotices",true,false)
	notice.enqueue("Roses",2)
	notice.enqueue_xp("Lock-in",200)
	notice.enqueue_xp("Stuck the landing",2000)
	await get_tree().create_timer(.4).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("xp-loot-stack.png"))
	main.game.set_physics_process(false)
	main.game.results={"winner":-1,"best":{},"tower":5,"top":8.0,"local_xp":{
		"eligible":true,"saved":true,"total":10150,"awarded":10150,
		"rows":{"MATCH COMPLETE":2500,"VICTORY":4000,"KNOCKOUTS":0,"LOCK-INS":200,"FIRST LOCK-IN":200,"STUCK THE LANDING":3000,"UPWARD AIRTIME":250}}}
	main.show_screen("results")
	await get_tree().create_timer(5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("xp-landing-breakdown.png"))
	print("LANDING STACK PREVIEW COMPLETE")
	get_tree().quit()
