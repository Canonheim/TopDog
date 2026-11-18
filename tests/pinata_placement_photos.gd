extends Node
const Pickup=preload("res://game/cosmetic_pinata.gd")
var records:Array=[]
func _ready():
 Game.grow_spawns=false
 var main=load("res://game/main.tscn").instantiate()
 add_child(main)
 await get_tree().create_timer(.7).timeout
 main.show_screen("effect_capture")
 main.set_process(false)
 main.lucha.set_process(false)
 main._pad_corner.hide()
 var g:Game=main.game
 g.set_physics_process(false)
 for mode in ["tower","scramble","delmar"]:
  for count in [2,7,15]:
   g.host_start({"mode":mode,"timer":INF,"stage":"plaza","base":"barrel"},[{"pid":0,"name":"Trial A","peer":1,"slot":0,"tint":Color("f3b55b")},{"pid":1,"name":"Trial B","peer":1,"slot":1,"tint":Color("78c6c1")}])
   # No ticking match clock or timeouts; only render/physics registration runs.
   g.set_physics_process(false)
   main.lucha._hud.hide()
   g.phase="round"
   var base:Vector3=g.stage.base_root.global_position
   var start:=Vector2(base.x,base.y+g.stage.barrel_top)
   var angle:float=-PI/4 if mode=="delmar" else 0.0
   for i in count:
    var feet:=start+Vector2(sin(i*.7)*.22,i*1.72).rotated(angle)
    g._rpc_spawn(i%2,100+i,feet,"Test tower %d"%i)
    var c:Climber=g.climbers[100+i]
    c.set_physics_process(false)
    var pose:=c.pose()
    for j in range(0,pose.size(),3):
     var point:Vector2=(Vector2(pose[j],pose[j+1])-feet).rotated(angle)+feet
     pose[j]=point.x;pose[j+1]=point.y;pose[j+2]+=angle
    c.apply_pose(pose)
    c.freeze()
    g.tower.append(c.climber_id)
   g.live.clear()
   await get_tree().physics_frame
   var d=g.pinata_director
   var snapshot:Dictionary=d.tower_snapshot()
   d.rng.seed=8100+count+(900 if mode=="delmar" else 0)+(400 if mode=="scramble" else 0)
   var point:Vector3=d.choose_position(snapshot)
   assert(point.is_finite())
   var rarity:int=d.rarity_for_roll(snapshot.distance,d.rng.randf()*100.0,7.0)
   var item:=Pickup.new()
   item.rarity=rarity
   item.contact_enabled=false
   item.position=point
   g.world.add_child(item)
   var anchor:Vector2=snapshot.anchor
   var left:float=minf(snapshot.left,point.x-1.6)-1.2
   var right:float=maxf(snapshot.right,point.x+1.6)+1.2
   var top:float=maxf(snapshot.top,point.y+1.7)+.7
   var bottom:float=anchor.y-1
   var cx:float=(left+right)/2
   var cy:float=(top+bottom)/2
   var distance:float=maxf((right-left)/1.35,(top-bottom)/.70)
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
   label.text="%s | %s tower | %.1f units from anchor | Tier %d\nUnlimited-time placement trial — one sampled spawn"%[{"tower":"Tower / Plaza","scramble":"Classic / Plaza","delmar":"Del Mar"}[mode],{2:"Small",7:"Medium",15:"Tall"}[count],snapshot.distance,d.tier_for_distance(snapshot.distance)+1]
   layer.add_child(label)
   add_child(layer)
   await get_tree().create_timer(.3).timeout
   await RenderingServer.frame_post_draw
   var file:="C:/Users/growi/Documents/ChatGPT/Top dog 2/pinata-trial-%s-%d.png"%[mode,count]
   get_viewport().get_texture().get_image().save_png(file)
   records.append({"mode":mode,"bodies":count,"distance":snapshot.distance,"tier":d.tier_for_distance(snapshot.distance)+1,"rarity":rarity,"spawn":str(point),"file":file})
   print("PHOTO ",JSON.stringify(records[-1]))
   layer.queue_free();item.queue_free()
   g.end_match()
   await get_tree().process_frame
   await get_tree().process_frame
 var output:=FileAccess.open("C:/Users/growi/Documents/ChatGPT/Top dog 2/kit/pinata-placement-trials.json",FileAccess.WRITE)
 output.store_string(JSON.stringify(records,"  "))
 print("ALL PLACEMENT PHOTOS COMPLETE")
 get_tree().quit()
