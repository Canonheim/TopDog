extends Node
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
func _ready() -> void:
 var total := Time.get_ticks_usec()
 Wardrobe.profiles[Wardrobe.selected].effect = "chocolates"
 var main = load("res://game/main.tscn").instantiate()
 add_child(main)
 var startup_ms := (Time.get_ticks_usec()-total)/1000.0
 var started := Time.get_ticks_usec()
 while not Prep.is_prepared("chocolates") and Time.get_ticks_usec()-started < 15000000:
  await get_tree().process_frame
 var ready_ms := (Time.get_ticks_usec()-total)/1000.0
 main.show_screen("customize")
 var samples: Array = []
 for i in 12:
  var t := Time.get_ticks_usec()
  main.lucha.play_lock_effect("chocolates")
  samples.append((Time.get_ticks_usec()-t)/1000.0)
  await get_tree().create_timer(3.3).timeout
 var report := {"startup_including_shared_material_ms":startup_ms,"startup_to_chocolates_ready_ms":ready_ms,"chocolates_ready":Prep.is_prepared("chocolates"),"chocolates_prepare_max_ms":Prep.step_max_ms.get("chocolates",-1),"all_effects_prepare_max_frame_ms":Prep.max_frame_cpu_ms,"rendered_burst_cpu_ms":samples,"remaining":main.cam.find_children("ChocolatesBurst*","Node3D",false,false).size()}
 print("CHOCOLATES_RENDERED ",JSON.stringify(report))
 var f := FileAccess.open("C:/Users/growi/Documents/ChatGPT/Top dog 2/chocolates-preview/rendered-final.json",FileAccess.WRITE)
 f.store_string(JSON.stringify(report,"  "))
 f.close()
 await main.quit_game()
