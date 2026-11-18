extends Node
const Director = preload("res://game/pinata_director.gd")
var fails:=0
var samples:=0
func check(ok:bool,label:String):
 if not ok:fails+=1;print("FAIL ",label)
func _ready():
 for mode in ["tower","delmar"]:
  var world:=Node3D.new()
  add_child(world)
  var g:=Game.new()
  g.world=world
  g.dress=false
  add_child(g)
  g.host_start({"mode":mode,"timer":60.0,"stage":"plaza","base":"barrel"},[{"pid":0,"name":"A","peer":1,"slot":0,"tint":Color.WHITE},{"pid":1,"name":"B","peer":1,"slot":1,"tint":Color.WHITE}])
  g.set_physics_process(false)
  g._next()
  await get_tree().physics_frame
  var d=g.pinata_director
  d._clear()
  var anchor:Vector2=d.base_anchor()
  for base in ["barrel","cactus","donkey","bell"]:
   g.stage.set_base(world,base)
   g.stage.place_base()
   check(d.base_anchor()==anchor,mode+" fixed anchor "+base)
  var c:Climber=g.climbers.values()[0]
  c.set_physics_process(false)
  c.freeze()
  if not g.tower.has(c.climber_id):g.tower.append(c.climber_id)
  for angle in [20.0,45.0,70.0,135.0]:
   var target:=anchor+Vector2.from_angle(deg_to_rad(angle))*10.0
   var offset:=target-c.centre_of_mass()
   var pose:=c.pose()
   for i in range(0,pose.size(),3):pose[i]+=offset.x;pose[i+1]+=offset.y
   c.apply_pose(pose)
   for b in c.bodies.values():Climber.sync_server(b)
   await get_tree().physics_frame
   var snapshot:Dictionary=d.tower_snapshot()
   check(snapshot.distance>9.0,"frozen body surface measured")
   check((snapshot.farthest-anchor).normalized().distance_to(snapshot.direction)<.0001,"frame follows actual furthest point")
   c.state=Climber.State.LIVE
   check(d.tower_snapshot().distance==0,"live body excluded")
   c.state=Climber.State.FROZEN
   var valid:=0
   for n in 100:
    d.rng.seed=n+int(angle)*100
    var point:Vector3=d.choose_position(snapshot)
    if not point.is_finite():continue
    valid+=1;samples+=1
    if mode=="delmar":
     var offset2:=Vector2(point.x,point.y)-anchor
     var perpendicular:float=offset2.dot(snapshot.normal)
     check(point.x-Director.Pickup.PICKUP_RADIUS>Stage.PIER_END,"entire hitbox beyond dock")
     check(point.y-Director.Pickup.PICKUP_RADIUS>=Stage.DECK_Y+4.9999,"Del Mar five-unit deck clearance")
     check(perpendicular-Director.Pickup.PICKUP_RADIUS>=-3.5001,"lower band includes full hitbox")
     check(perpendicular+Director.Pickup.PICKUP_RADIUS<=5.0001,"upper band includes full hitbox")
    else:check(point.y-Director.Pickup.PICKUP_RADIUS>=4.9999,"vertical full-hitbox clearance")
   if mode=="delmar" and angle==135.0: check(valid==0,"backward dock tower skips impossible spawns")
   else: check(valid>90,"spawn candidates available at angle %s"%angle)
  var spacing:float=d.tier_spacing
  g.roster.pop_back()
  d._phase("round")
  check(d.tier_spacing==spacing,"disconnect cannot lower spacing")
  g.end_match();g.queue_free();world.queue_free()
  await get_tree().process_frame
  await get_tree().process_frame
 print("PINATA GEOMETRY samples=",samples," fails=",fails)
 get_tree().quit(fails)
