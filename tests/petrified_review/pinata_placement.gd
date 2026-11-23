extends Node3D
func _ready() -> void:
 var game:=Game.new();game.world=self;game.dress=false;add_child(game)
 game.stage=Stage.new("dock");game.stage.build(self,false)
 for i in 50:
  var actor:=Climber.new();actor.climber_id=i;add_child(actor);actor.build(Vector2((i%5)*.6,(i/5)*1.7),self,Wardrobe.CLIMBER);actor.freeze()
  game.climbers[i]=actor;game.tower.append(i)
 for i in 3:await get_tree().physics_frame
 var director=game.pinata_director
 var started:=Time.get_ticks_usec()
 var snapshot: Dictionary=await director.tower_snapshot_async()
 var total_ms: float=(Time.get_ticks_usec()-started)/1000.
 assert(snapshot.points.size()>0 and snapshot.top>10)
 var point: Vector3=await director.choose_position_async(snapshot)
 print("PINATA_PLACEMENT_AUDIT ",JSON.stringify({"bodies":50,"points":snapshot.points.size(),"snapshot_total_ms":total_ms,"snapshot_max_slice_ms":director.snapshot_max_slice_us/1000.,"placement_max_slice_ms":director.placement_max_slice_us/1000.,"position_valid":point.is_finite()}))
 assert(director.snapshot_max_slice_us<8000 and director.placement_max_slice_us<8000)
 game.end_match();game.queue_free();await get_tree().process_frame;get_tree().quit()
