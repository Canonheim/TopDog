extends Node
const Director = preload("res://game/pinata_director.gd")
var fails := 0
func check(ok: bool,label: String):
 if not ok: fails+=1; print("FAIL ",label)
func _ready():
 check(Director.WEIGHTS==[[0,100,0,0,0],[0,100,0,0,0],[0,80,20,0,0],[0,65,25,10,0],[0,55,25,15,5]],"white spawn odds merged into green without changing higher rarities")
 for distance in [0.0,6.999,7.0,13.999,14.0,20.999,21.0,27.999,28.0,100.0]:
  var counts := [0,0,0,0,0]
  for roll in 100: counts[Director.rarity_for_roll(distance,roll+.5)]+=1
  check(counts==Director.WEIGHTS[clampi(int(floor(distance/7.0)),0,4)],"distance rarity boundary %s"%distance)
 check(Director.SPAWN_CHANCE==.10,"10 percent")
 check(Director.rarity_for_roll(0,100.0)==1,"inclusive RNG endpoint remains green")
 check(Director.spacing_for_players(3)==10.5 and Director.spacing_for_players(12)==42.0,"future player scaling")
 var forced_seed := 0
 var r:=RandomNumberGenerator.new()
 for n in 1000:
  r.seed=n
  if r.randf()<.10: forced_seed=n; break
 for mode in ["tower","scramble","delmar","practice"]:
  var world:=Node3D.new()
  add_child(world)
  var game:=Game.new()
  game.world=world
  game.dress=false
  add_child(game)
  game.host_start({"mode":mode,"timer":60.0,"stage":"plaza","base":"barrel"},[{"pid":0,"name":"A","peer":1,"slot":0,"tint":Color.WHITE},{"pid":1,"name":"B","peer":1,"slot":1,"tint":Color.WHITE}])
  game.pinata_director.rng.seed=forced_seed
  while game.phase=="between": await get_tree().physics_frame
  game.set_physics_process(false)
  var director=game.pinata_director
  if mode=="practice": check(not is_instance_valid(director.current),"practice excluded")
  else:
   check(is_instance_valid(director.current),mode+" actual round spawn")
   check(director.round_index==1,mode+" first round")
   if is_instance_valid(director.current):
    check(director.current.rarity==1,mode+" initial green")
    if mode!="delmar": check(director.current.position.y-Director.Pickup.PICKUP_RADIUS>=4.9999,mode+" five-unit ground clearance")
    director._collect(director.received_generation-1)
    check(not director.current.taken,"stale collection rejected")
    var old=director.current
    game._rpc_phase("between",0,game.line,game.round_n,-1)
    await get_tree().physics_frame
    check(not is_instance_valid(old),mode+" round despawn")
    director.rng.seed=forced_seed
    game._rpc_phase("round",60,game.line,2,-1)
    check(director.round_index==2,mode+" round increment")
    check(is_instance_valid(director.current),"second spawn")
    director.current.contact_enabled=false
    var body:=StaticBody3D.new()
    body.collision_layer=Climber.LAYER_LIVE
    director.current._touch(body)
    check(not director.current.taken,"client contact ignored")
    body.free()
    director._collect(director.received_generation)
    var burst=director.current.burst_root
    director._collect(director.received_generation)
    check(director.current.taken and director.current.burst_root==burst,"single replicated burst")
    director.current.queue_free()
  game.end_match()
  check(director.round_index==0 and director.current==null,"match cleanup")
  game.queue_free()
  world.queue_free()
  await get_tree().process_frame
  await get_tree().process_frame
 print("PINATA INTEGRATION fails=",fails)
 get_tree().quit(fails)


