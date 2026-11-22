extends Node
const Prep=preload("res://ui3d/lock_effect_preparation.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/spider-webs/"
func _ready() -> void:
 var main=load("res://game/main.tscn").instantiate();add_child(main)
 for node in main.find_children("*","Node",true,false):
  if node.get_script()==Prep:node.set_process(false)
 main.show_screen("customize")
 for version in ["before","after"]:
  var script=load("res://tests/deep_freeze_review/spiders_"+version+".gd")
  for i in 13:
   script.prepare_unit(i)
   await get_tree().process_frame
  main.screens.customize._rebuild_preview(0)
  await get_tree().process_frame
  var fx=script.preview(main.screens.customize.preview,main.lucha.cam)
  var frame:=0
  # Capture initialization as rendered, retaining elapsed time for the GIF.
  var times: Array=[];var last:=Time.get_ticks_msec()
  while not fx.get_meta("ready",false):
   await RenderingServer.frame_post_draw
   capture(version,frame);frame+=1
   var now:=Time.get_ticks_msec();times.append(maxi(20,now-last));last=now
   await get_tree().process_frame
  fx.set_process(false)
  if version=="after":print("SETUP ",fx.setup_max_slice_us," us ",fx.setup_max_stage)
  for i in 91:
   fx.tick(i/10.0)
   await get_tree().process_frame
   await RenderingServer.frame_post_draw
   capture(version,frame);frame+=1;times.append(100)
  var file=FileAccess.open(OUT+version+"-times.json",FileAccess.WRITE);file.store_string(JSON.stringify(times));file.close()
  print("CAPTURED ",version," ",frame)
  fx.free()
 main.queue_free()
 await get_tree().process_frame
 get_tree().quit()
func capture(version: String,index: int) -> void:
 var img=get_viewport().get_texture().get_image()
 img.get_region(Rect2i(1060,350,360,520)).save_png(OUT+version+"-frames/%04d.png"%index)
