extends Node
const X=preload("res://game/match_xp.gd")
const P=preload("res://core/player_progression.gd")
var frame:=0
var folder:="C:/Users/growi/AppData/Local/Temp/topdog-xp-gif-20261117"
func capture(count: int) -> void:
	for i in count:
		await RenderingServer.frame_post_draw
		var picture:=get_viewport().get_texture().get_image()
		picture.resize(1200,675,Image.INTERPOLATE_LANCZOS)
		picture.save_png(folder.path_join("%04d.png" % frame))
		frame+=1
		await get_tree().process_frame
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(folder)
	var main=load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(2).timeout
	main.lucha.title_attract=false
	main._start_practice()
	await get_tree().create_timer(1.5).timeout
	main.game.set_physics_process(false)
	var notice=main.find_child("RewardNotices",true,false)
	var x=X.new()
	x.begin([{"pid":0},{"pid":1}],true)
	x.elapsed=60
	x.stats[0].active=10.0
	x.achievement.connect(func(pid,title,amount):
		if pid==0: notice.enqueue_xp(title,amount))
	notice.enqueue("Roses",2)
	x.lock_in(0,1)
	await capture(30)
	x.stuck_landing(0)
	await capture(30)
	x.stuck_landing(0)
	await capture(30)
	x.stats[0].air=10.0
	var payout:Dictionary=x.payouts(0)[0]
	payout.saved=true;payout.awarded=payout.total
	main.game.results={"winner":0,"best":{0:3.5},"tower":2,"top":3.5,"local_xp":payout}
	main.game.phase="over"
	main.show_screen("results")
	# Let live notices fade so the breakdown is clearly visible.
	await get_tree().create_timer(5.2).timeout
	await capture(40)
	main.game.end_match()
	main.show_screen("title")
	var bar=main.lucha.xp_display
	bar._shown_total=0;bar._target_total=0
	bar.set_progress(P.snapshot(0))
	await capture(8)
	bar.animate_to_total(int(payout.total))
	await capture(72)
	print("XP GIF FRAMES=",frame," PAYOUT=",payout.total)
	get_tree().quit()
