extends Node
var fails:=0
func check(ok:bool,label:String):
 if not ok:fails+=1;print("FAIL ",label)
func _ready():
 var w:=Node3D.new();add_child(w)
 var g:=Game.new();g.world=w;g.dress=false;add_child(g)
 g.host_start({"mode":"delmar","stage":"plaza","base":"barrel","timer":60.0},[{"pid":0,"name":"A","peer":1,"slot":0,"tint":Color.WHITE},{"pid":1,"name":"B","peer":1,"slot":1,"tint":Color.WHITE}])
 g.set_physics_process(false);g._next()
 await get_tree().physics_frame
 var c:Climber=g.climbers.values()[0]
 var cid:=c.climber_id
 g.view_from=Vector3(0,2,10)
 g._shown_line=0.0
 g.line=0.0
 check(g.live_gap(c)<0,"stale camera cannot approve dock pose")
 g._judge_lock(cid,c.pose(),true)
 check(c.state!=Climber.State.FROZEN,"dock lock rejected")
 g._broadcast_freeze(cid,c.pose(),"time",true)
 check(not g.tower.has(cid) and not g.climbers.has(cid),"failed dock body removed from supports")
 g.judge_by_view=false
 check(g.lock_gap([Vector2(Stage.PIER_END+3,8)])>0,"forward supported region remains eligible")
 var anchor:Vector2=g.pinata_director.base_anchor()
 check(absf(anchor.x-g.stage.base_root.global_position.x)<.001 and anchor.y==Stage.DECK_Y,"anchor matches barrel center at deck level")
 g.end_match();g.queue_free();w.queue_free()
 await get_tree().process_frame
 print("DELMAR DOCK GUARD fails=",fails)
 get_tree().quit(fails)
