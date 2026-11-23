extends Node3D
const Effect=preload("res://tests/petrified_review/effect.gd")
func _ready() -> void:
 var actor:=Climber.new();actor.climber_id=980;add_child(actor);actor.build(Vector2.ZERO,self,Wardrobe.CLIMBER);actor.freeze()
 await Effect.prepare()
 var fx=Effect.attach(actor,false)
 var seen: Dictionary={}
 var maximum:=0
 for iteration in 24:
  assert(fx.on_grab(actor.bodies.chest.global_position))
  var snapshot:=str(fx.debris.particles)
  seen[snapshot]=true
  assert(not fx.on_grab(actor.bodies.head.global_position))
  assert(snapshot==str(fx.debris.particles))
  assert(fx.debris.rocks.multimesh.visible_instance_count>=4 and fx.debris.rocks.multimesh.visible_instance_count<=7)
  for p in fx.debris.particles:assert(p.velocity.y<0)
  maximum=maxi(maximum,fx.debris.burst_us)
  fx.debris.step(2.)
  assert(not fx.debris.active and not fx.debris.is_processing())
  assert(fx.debris.dust.multimesh.visible_instance_count==0)
 assert(seen.size()==24)
 for normal in [Vector3.UP,Vector3.DOWN,Vector3.LEFT,Vector3.RIGHT,Vector3.FORWARD,Vector3.BACK]:
  var basis:=Effect.surface_basis(normal)
  var angle:=lerpf(.3,1.95,(1-normal.y)*.5)
  for i in range(1,13):
   var h:=i/12.
   var center:=basis*Vector3(.054*(1-cos(angle*h))/angle,.054*sin(angle*h)/angle,0)
   assert(center.dot(normal)>0)
 # Re-selection in the same frame must keep the stable shared listener path.
 fx.free()
 var next=Effect.attach(actor,false)
 assert(next.grab_watch.name=="PetrifiedGrabWatch")
 actor.remove()
 for frame in 3:await get_tree().process_frame
 assert(get_tree().root.get_node_or_null("PetrifiedGrabWatch")==null)
 print("PETRIFIED_BEHAVIOR_PASS random24 blocked24 six_surface_orientations cleanup; burst_max_us ",maximum)
 get_tree().quit()
