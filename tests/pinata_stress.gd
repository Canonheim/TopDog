extends Node
const MatchGame = preload("res://tests/pinata_stress_game.gd")
const Pickup = preload("res://game/cosmetic_pinata.gd")
var output := []
var targets: Array = []
var offers: Array = []
var game
var rounds := 0
var rolls := 0
var h := 1.8
var rng := RandomNumberGenerator.new()
func _ready():
 h = 1.995 * Feel.get_k("body_scale")
 var trials := 3
 for a in OS.get_cmdline_user_args():
  if a.begins_with("--trials="): trials=int(a.get_slice("=",1))
 for mode in ["tower","scramble","delmar"]:
  for trial in trials:
   await run_match(mode,trial)
 var file := FileAccess.open("C:/Users/growi/Documents/ChatGPT/Top dog 2/kit/pinata-stress-results.json",FileAccess.WRITE)
 file.store_string(JSON.stringify({"climber_height":h,"matches":output},"  "))
 print("STRESS COMPLETE matches=",output.size())
 get_tree().quit()
func clear_targets():
 for item in targets:
  if is_instance_valid(item): item.queue_free()
 targets.clear()
func phase_change(p: String):
 clear_targets()
 if p not in ["turn","round"]: return
 rounds+=1
 if rng.randf()<.05: rolls+=1
 var peak := actual_top()
 var left: float = game.stage.base_root.position.x - 1.0
 var right: float = game.stage.base_root.position.x + 1.0
 for cid in game.tower:
  if not game.climbers.has(cid): continue
  for body in game.climbers[cid].bodies.values():
   left=minf(left,body.position.x-.25)
   right=maxf(right,body.position.x+.25)
 var y := maxf(1.0,peak-.25*h)
 for side in [-1,1]:
  for distance in [2,3,4]:
   var point := Vector3((left if side<0 else right)+side*distance*h,y,0)
   var item := Pickup.new()
   item.position=point
   game.world.add_child(item)
   targets.append(item)
   var record := {"round":rounds,"distance_lengths":distance,"side":side,"x":point.x,"y":point.y,"collected":false,"nearest_body_center":999.0}
   offers.append(record)
   item.collected.connect(func(_body): record.collected=true)
func actual_top() -> float:
 var top: float = game.stage.barrel_top
 for cid in game.tower:
  if not game.climbers.has(cid): continue
  for body in game.climbers[cid].bodies.values(): top=maxf(top,body.position.y+.135*h/1.995)
 return top
func run_match(mode: String,trial: int):
 seed(13000+trial)
 rng.seed=53000+trial
 rounds=0
 rolls=0
 offers=[]
 var world := Node3D.new()
 add_child(world)
 game=MatchGame.new()
 game.world=world
 game.dress=false
 add_child(game)
 game.climber_spawned.connect(func(c): c.configure(game,"hard"))
 game.phase_changed.connect(phase_change)
 var roster: Array=[]
 for i in 2: roster.append({"pid":i,"name":"Hard %d"%i,"tint":Color.WHITE,"peer":1,"slot":i})
 game.host_start({"mode":mode,"timer":60.0,"spawn":"alternate","stage":"plaza","base":"barrel"},roster)
 var base: float=game.stage.barrel_top
 var peak := base
 var sampled_sum := 0.0
 var samples := 0
 var max_bodies := 0
 var elapsed := 0.0
 var tick := 0
 var ticks := Engine.physics_ticks_per_second
 while elapsed<600 and game.phase!="over":
  await get_tree().physics_frame
  tick+=1
  elapsed+=1.0/ticks
  if tick%ticks!=0: continue
  var top := actual_top()
  peak=maxf(peak,top)
  sampled_sum+=maxf(0,top-base)
  samples+=1
  max_bodies=maxi(max_bodies,game.tower.size())
  for rec in offers:
   if rec.round!=rounds or rec.collected: continue
   var point := Vector3(rec.x,rec.y,0)
   for c in game.live_climbers():
    for b in c.bodies.values(): rec.nearest_body_center=minf(rec.nearest_body_center,b.position.distance_to(point))
  if tick%(ticks*120)==0: print("PROGRESS ",mode," seed=",trial," seconds=",elapsed," rounds=",rounds," peak=",peak)
 var row := {"mode":mode,"trial":trial,"sim_seconds":elapsed,"completed":game.phase=="over","rounds":rounds,"base_height":base,"peak_tower_height":peak,"peak_above_base":peak-base,"peak_climber_lengths":(peak-base)/h,"time_average_above_base":sampled_sum/maxi(1,samples),"max_frozen_bodies":max_bodies,"five_percent_roll_hits":rolls,"offers":offers.duplicate(true)}
 output.append(row)
 var checkpoint := FileAccess.open("C:/Users/growi/Documents/ChatGPT/Top dog 2/kit/pinata-stress-results.json",FileAccess.WRITE)
 checkpoint.store_string(JSON.stringify({"climber_height":h,"matches":output},"  "))
 checkpoint.close()
 print("MATCH ",JSON.stringify({"mode":mode,"trial":trial,"seconds":elapsed,"rounds":rounds,"peak_lengths":row.peak_climber_lengths,"bodies":max_bodies,"offers":offers.size(),"collected":offers.filter(func(r):return r.collected).size()}))
 clear_targets()
 game.end_match()
 game.queue_free()
 world.queue_free()
 await get_tree().process_frame
 await get_tree().process_frame



