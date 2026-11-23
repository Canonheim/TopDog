extends Node
var samples: Array=[]
func _ready() -> void:
 var world:=Node3D.new();add_child(world)
 var cam:=Camera3D.new();world.add_child(cam);cam.position=Vector3(0,0,6);cam.current=true
 for run in 4:
  var pickup=load("res://game/cosmetic_pinata.gd").new();pickup.contact_enabled=false;world.add_child(pickup)
  for i in 40:await get_tree().process_frame
  var before_nodes:=Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
  var started:=Time.get_ticks_usec();pickup.collect()
  var collect_us:=Time.get_ticks_usec()-started
  var after_nodes:=Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
  var emitters:=0
  for child in pickup.burst_root.get_children():
   if child is CPUParticles3D:
    assert(child.emitting);emitters+=1
  assert(emitters==6 and pickup.burst_root.visible)
  var frame_ms: Array=[]
  var previous:=Time.get_ticks_usec()
  for i in 150:
   await get_tree().process_frame
   var now:=Time.get_ticks_usec();frame_ms.append((now-previous)/1000.0);previous=now
  var worst_frame:=frame_ms.find(frame_ms.max())
  frame_ms.sort()
  samples.append({"collect_us":collect_us,"new_nodes":after_nodes-before_nodes,"p95_frame_ms":frame_ms[int(frame_ms.size()*.95)],"max_frame_ms":frame_ms.back(),"worst_frame":worst_frame})
  if is_instance_valid(pickup):pickup.queue_free()
  await get_tree().process_frame
 print("PINATA_PERFORMANCE ",JSON.stringify(samples))
 get_tree().quit()
