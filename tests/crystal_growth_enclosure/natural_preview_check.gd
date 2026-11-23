extends Node
const Prep=preload("res://ui3d/lock_effect_preparation.gd")
func _ready() -> void:
 var saved:=Wardrobe.profiles.duplicate(true);var selected:=Wardrobe.selected
 Wardrobe.profiles=[Wardrobe.clean({"head":0,"skin":1,"effect":"pickles"})];Wardrobe.selected=0
 var main=load("res://game/main.tscn").instantiate();add_child(main);main.show_screen("customize")
 var menu=main.screens.customize
 for id in ["spiders","absolute_zero"]:
  menu.menu.items[4].on_change.call(Wardrobe.EFFECTS.find(id))
  for second in 12:
   await get_tree().create_timer(1.0).timeout
   var fx=menu.preview.get_node_or_null("Spiders" if id=="spiders" else "AbsoluteZero")
   if fx!=null:print("NATURAL ",id," t=",second," age=",fx.age," ready=",fx.get_meta("ready",false)," process=",fx.is_processing()," can=",fx.can_process()," paused=",get_tree().paused)
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/crystal-growth-enclosure/installation/natural-"+id+".png")
 Wardrobe.profiles=saved;Wardrobe.selected=selected;Wardrobe.save()
 main.queue_free();await get_tree().process_frame;get_tree().quit()
