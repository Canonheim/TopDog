extends Node
const X=preload("res://game/match_xp.gd")
const P=preload("res://core/player_progression.gd")
var frame:=130
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
	var main=load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(2).timeout
	main.lucha.title_attract=false
	main.show_screen("title")
	await get_tree().create_timer(.5).timeout
	var bar=main.lucha.xp_display
	bar._shown_total=0;bar._target_total=0
	bar.set_progress(P.snapshot(0))
	await capture(8)
	bar.animate_to_total(10150)
	await capture(72)
	print("CLEAN TITLE GIF COMPLETE")
	get_tree().quit()
