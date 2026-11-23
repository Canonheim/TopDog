extends Node
func _ready() -> void:
 var camera:=Camera3D.new();add_child(camera);camera.current=true
 var script=load("res://game/cosmetic_pinata.gd")
 var holder=script.warm_at_boot(camera)
 assert(holder!=null)
 var warm=holder.get_child(0)
 assert(not warm.contact_enabled and not warm.monitoring)
 var voice=warm.burst_root.get_node("PinataBreakSound")
 assert(not voice.playing)
 for i in 12:await get_tree().process_frame
 assert(script.burst_cache_ready and not holder.visible and holder.process_mode==Node.PROCESS_MODE_DISABLED)
 assert(not voice.playing and not warm.taken)
 var pickup=script.new();pickup.contact_enabled=false;add_child(pickup)
 assert(not pickup.burst_root.visible)
 assert(pickup.burst_root.get_node("PinataBreakSound").playing==false)
 var before:=Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
 pickup.collect()
 assert(pickup.burst_root.get_node("PinataBreakSound").playing)
 assert(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)==before)
 print("PINATA_BOOT_WARM PASS: ready before match; retained resources; silent preparation; zero pickup node allocations")
 get_tree().quit()
