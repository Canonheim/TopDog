extends Node
const Pickup = preload("res://game/cosmetic_pinata.gd")
func _ready():
 seed(11)
 Game.grow_spawns=false
 var main=load("res://game/main.tscn").instantiate()
 add_child(main)
 await get_tree().create_timer(.7).timeout
 main.practice_settings.practice_mode="tower"
 main.practice_settings.base="barrel"
 main.practice_settings.practice_ai="hard"
 main.practice_settings.practice_npc=true
 main._start_practice()
 main.show_screen("effect_capture")
 main.set_process(false)
 main.lucha.set_process(false)
 main._pad_corner.hide()
 var g:Game=main.game
 g.set_practice_ai("hard")
 for attempt in 4:
  var bot=g.partner
  for tick in 7200:
   await get_tree().physics_frame
   if bot.state==Climber.State.FROZEN:break
  print("PHOTO AI attempt=",attempt+1," frozen=",bot.state==Climber.State.FROZEN," bodies=",g.tower.size())
  if bot.state!=Climber.State.FROZEN:break
  if attempt<3:g._next()
 g.set_physics_process(false)
 main.lucha._hud.hide()
 var left:float=-1.0
 var right:float=1.0
 var top:float=g.stage.barrel_top
 for c in g.climbers.values():
  c.set_physics_process(false)
  for b in c.bodies.values():
   b.freeze=true
   if c.state==Climber.State.FROZEN:
    left=minf(left,b.global_position.x-.4)
    right=maxf(right,b.global_position.x+.4)
    top=maxf(top,b.global_position.y+.3)
 if is_instance_valid(g.partner):
  g.partner.set_physics_process(false)
  for b in g.partner.bodies.values():b.freeze=true
 if is_instance_valid(g.chair):g.chair.hide()
 var point:=Vector3.ZERO
 for n in 100:
  g.pinata_director.rng.seed=n
  point=g.pinata_director.choose_position()
  if point.is_finite() and point.x<0:break
 assert(point.is_finite())
 left=minf(left,point.x-1.5)
 right=maxf(right,point.x+1.5)
 var cx:float=(left+right)/2
 var cy:float=maxf(top,point.y)*.48
 var distance:float=maxf(10.0,(right-left+2.0)/1.35)
 main.cam.position=Vector3(cx,cy+1.5,distance)
 main.cam.look_at(Vector3(cx,cy,0))
 main.cam.fov=43
 for tier in 5:
  var item:=Pickup.new()
  item.rarity=tier
  item.contact_enabled=false
  item.position=point
  main.world.add_child(item)
  await get_tree().create_timer(.45).timeout
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top dog 2/pinata-tower-%s.png"%["white","green","blue","purple","red"][tier])
  item.queue_free()
  await get_tree().process_frame
 print("PINATA TOWER PHOTOS complete frozen bodies=",g.tower.size()," location=",point)
 g.end_match()
 get_tree().quit()

