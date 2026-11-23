extends Node
var frames: Array = []
var previous: int = 0
func _process(_delta: float) -> void:
 var now := Time.get_ticks_usec()
 if previous > 0: frames.append((now-previous)/1000.0)
 previous = now
func stats() -> Dictionary:
 var ordered := frames.duplicate()
 ordered.sort()
 return {"median_ms":ordered[ordered.size()/2],"p95_ms":ordered[int(ordered.size()*.95)],"max_ms":ordered.back(),"frames_over_25ms":ordered.filter(func(v):return v>25.0).size()}
func _ready() -> void:
 var warm := "--boot-warm" in OS.get_cmdline_user_args()
 var camera := Camera3D.new();add_child(camera);camera.position=Vector3(0,0,6);camera.current=true
 for i in 60: await get_tree().process_frame
 var script = load("res://game/cosmetic_pinata.gd")
 frames.clear()
 var start := Time.get_ticks_usec()
 if warm: script.warm_at_boot(camera)
 var boot_us := Time.get_ticks_usec()-start
 for i in 40: await get_tree().process_frame
 var boot_stats := stats()
 if warm: assert(script.burst_cache_ready)
 frames.clear()
 start=Time.get_ticks_usec()
 var pickup=script.new();pickup.contact_enabled=false;add_child(pickup)
 var spawn_us := Time.get_ticks_usec()-start
 for i in 40: await get_tree().process_frame
 var spawn_stats := stats()
 frames.clear()
 var nodes := Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
 start=Time.get_ticks_usec();pickup.collect()
 var collect_us := Time.get_ticks_usec()-start
 var new_nodes := Performance.get_monitor(Performance.OBJECT_NODE_COUNT)-nodes
 for i in 150: await get_tree().process_frame
 print("PINATA_PREWARM_PERFORMANCE ",JSON.stringify({"boot_warm":warm,"boot_us":boot_us,"boot_frames":boot_stats,"spawn_us":spawn_us,"spawn_frames":spawn_stats,"collect_us":collect_us,"new_nodes":new_nodes,"collection_frames":stats()}))
 get_tree().quit()
