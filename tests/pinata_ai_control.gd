extends Node
func _ready():
 Game.grow_spawns=false
 seed(11)
 var world:=Node3D.new()
 add_child(world)
 var g:=Game.new()
 g.world=world
 g.dress=false
 add_child(g)
 g.host_start({"mode":"practice","practice_mode":"tower","practice_npc":true,"practice_ai":"hard","base":"barrel","stage":"plaza","timer":60.0},[{"pid":0,"name":"Observer","tint":Color.WHITE,"peer":1,"slot":0}])
 while g.phase!="turn": await get_tree().physics_frame
 var wins:=0
 for attempt in 16:
  var bot=g.partner
  for tick in 7200:
   await get_tree().physics_frame
   if bot.state==Climber.State.FROZEN: break
  var success:bool=bot.state==Climber.State.FROZEN
  if success: wins+=1
  print("CONTROL round=",attempt+1," success=",success," tower_bodies=",g.tower.size()," top=",g.tower_top()," intent=",bot.intent," pos=",bot.centre_of_mass())
  if not success: break
  if attempt<15: g._next()
 print("CONTROL successful_consecutive_rounds=",wins)
 g.end_match()
 g.queue_free()
 world.queue_free()
 await get_tree().process_frame
 get_tree().quit()
