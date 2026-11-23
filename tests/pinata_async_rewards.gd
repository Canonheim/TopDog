extends Node
class SlowStore extends RefCounted:
 var backing: RefCounted
 var error := ""
 func collect(event_id,tier,seed_value,players,catalog) -> Array:
  OS.delay_msec(100) # Deliberately slow disk surrogate must not stall the game.
  var result: Array=backing.collect(event_id,tier,seed_value,players,catalog)
  error=backing.error
  return result
func _ready() -> void:
 var world:=Node3D.new();add_child(world)
 var game:=Game.new();game.world=world;game.dress=false;add_child(game)
 game.host_start({"mode":"scramble","timer":60.0,"stage":"plaza","base":"barrel"},[{"pid":0,"peer":1,"slot":0,"name":"Test","tint":Color.WHITE},{"pid":1,"peer":1,"slot":1,"name":"Second","tint":Color.WHITE}])
 while game.phase=="between":await get_tree().process_frame
 game.set_physics_process(false)
 var director=game.pinata_director
 var path:=OS.get_environment("TEMP").path_join("pinata-async-"+str(OS.get_process_id())+".cfg")
 var store:=SlowStore.new();store.backing=load("res://core/pinata_rewards.gd").new(path);director.reward_store=store
 var longest:=0
 for event_id in ["a","a","b"]:
  director.generation+=1;director._spawn(director.generation,Vector3(0,30,0),1)
  var started:=Time.get_ticks_usec()
  director._collect(director.generation,event_id,42)
  longest=maxi(longest,Time.get_ticks_usec()-started)
 var frames_seen:=0
 var deadline:=Time.get_ticks_msec()+5000
 while (director.reward_thread!=null or not director.reward_jobs.is_empty()) and Time.get_ticks_msec()<deadline:
  frames_seen+=1;await get_tree().process_frame
 assert(director.reward_jobs.is_empty() and director.reward_thread==null)
 var cfg:=ConfigFile.new();assert(cfg.load(path)==OK)
 assert(cfg.get_value("rewards","receipts",[]).size()==4)
 assert(frames_seen>3 and longest<10000)
 director.generation+=1;director._spawn(director.generation,Vector3(0,30,0),1)
 director._collect(director.generation,"exit",42)
 game.end_match();game.queue_free();await get_tree().process_frame;await get_tree().process_frame
 cfg=ConfigFile.new();assert(cfg.load(path)==OK)
 assert(cfg.get_value("rewards","receipts",[]).size()==6)
 DirAccess.remove_absolute(path)
 print("ASYNC_REWARDS PASS max_collect_us=",longest," responsive_frames=",frames_seen," receipts preserved on exit")
 get_tree().quit()
