extends Node
const Pickup=preload("res://game/cosmetic_pinata.gd")
func _ready():
 Game.grow_spawns=false
 var main=load("res://game/main.tscn").instantiate()
 add_child(main)
 await get_tree().create_timer(.7).timeout
 main.set_process(false)
 main.lucha.set_process(false)
 main._pad_corner.hide()
 for mode in ["tower","delmar"]:
  seed(11 if mode=="tower" else 47)
  main.practice_settings.practice_mode=mode
  main.practice_settings.base="barrel"
  main.practice_settings.practice_ai="hard"
  main.practice_settings.practice_npc=true
  main._start_practice()
  main.show_screen("effect_capture")
  var g:Game=main.game
  g.judge_by_view=false # Camera is held for capture; AI must use world-space rules.
  g.set_physics_process(true)
  g.set_practice_ai("hard")
  for attempt in 4:
   var bot=g.partner
   for tick in 7200:
    await get_tree().physics_frame
    if bot.state==Climber.State.FROZEN:break
   print("AI BUILD mode=",mode," attempt=",attempt+1," success=",bot.state==Climber.State.FROZEN," frozen=",g.tower.size())
   if bot.state!=Climber.State.FROZEN:break
   if attempt<3:g._next()
  g.set_physics_process(false)
  main.lucha._hud.hide()
  for c in g.climbers.values():
   c.set_physics_process(false)
   for b in c.bodies.values():b.freeze=true
  if is_instance_valid(g.partner):
   g.partner.set_physics_process(false)
   for b in g.partner.bodies.values():b.freeze=true
  if is_instance_valid(g.chair):g.chair.hide()
  var d=g.pinata_director
  var snapshot:Dictionary=d.tower_snapshot()
  for trial in 3:
   d.rng.seed=5100+trial
   var point:Vector3=d.choose_position(snapshot)
   assert(point.is_finite())
   var item:=Pickup.new()
   item.rarity=d.rarity_for_roll(snapshot.distance,d.rng.randf()*100.0)
   item.contact_enabled=false
   item.position=point
   g.world.add_child(item)
   var left:float=minf(snapshot.left,point.x-1.7)-1.0
   var right:float=maxf(snapshot.right,point.x+1.7)+1.0
   var top:float=maxf(snapshot.top,point.y+1.7)+.6
   var bottom:float=snapshot.anchor.y-1.0
   var cx:float=(left+right)/2
   var cy:float=(top+bottom)/2
   var distance:float=maxf(10.0,maxf((right-left)/1.35,(top-bottom)/.70))
   main.cam.position=Vector3(cx,cy+.6,distance)
   main.cam.look_at(Vector3(cx,cy,0))
   main.cam.fov=43
   var layer:=CanvasLayer.new()
   var label:=Label.new()
   label.position=Vector2(28,24)
   label.add_theme_font_size_override("font_size",28)
   label.add_theme_color_override("font_shadow_color",Color.BLACK)
   label.add_theme_constant_override("shadow_offset_x",2)
   label.add_theme_constant_override("shadow_offset_y",2)
   label.text="%s | Hard AI-built tower: %d frozen players\nSpawn sample %d | %.1f units from anchor | No body posing"%["Plaza" if mode=="tower" else "Del Mar",g.tower.size(),trial+1,snapshot.distance]
   layer.add_child(label);add_child(layer)
   await get_tree().create_timer(.35).timeout
   await RenderingServer.frame_post_draw
   var path:="C:/Users/growi/Documents/ChatGPT/Top dog 2/pinata-chaotic-%s-%d.png"%[mode,trial+1]
   get_viewport().get_texture().get_image().save_png(path)
   print("AI PHOTO ",path," point=",point)
   item.queue_free();layer.queue_free()
   await get_tree().process_frame
  g.end_match()
  await get_tree().process_frame
 print("AI CHAOTIC PHOTOS COMPLETE")
 get_tree().quit()
