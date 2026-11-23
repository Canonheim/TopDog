extends Node3D
func _ready() -> void:
 var main=load("res://game/main.tscn").instantiate();add_child(main)
 var prep=main.get_node_or_null("LockEffectPreparation")
 if prep!=null:prep.set_process(false)
 main.local_mode=true
 assert(main.game.host_start({"mode":"practice","stage":"dock","base":"barrel"},[{"pid":0,"peer":1,"slot":0,"name":"Test","appearance":{"effect":"spiders"}}]))
 for i in 3:await get_tree().process_frame
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/match-preload/loading-screen.png")
 var deadline:=Time.get_ticks_msec()+20000
 while main.game.phase=="loading" and Time.get_ticks_msec()<deadline:await get_tree().process_frame
 assert(main.game.phase=="between")
 print("PRELOAD_UI_PASS")
 main.game.end_match();get_tree().quit()
