extends Node
const Pickup := preload("res://game/cosmetic_pinata.gd")
func _ready():
 var camera := Camera3D.new()
 add_child(camera)
 camera.make_current()
 var failures := 0
 for projection in [Camera3D.PROJECTION_PERSPECTIVE, Camera3D.PROJECTION_ORTHOGONAL]:
  camera.projection = projection
  for pos in [Vector3(0,3,8),Vector3(6,5,4),Vector3(-5,1,6)]:
   camera.position = pos
   camera.look_at(Vector3.ZERO)
   for tier in 5:
    var item := Pickup.new()
    item.rarity = tier
    item.position = Vector3((tier-2)*1.2,.5,0)
    add_child(item)
    item._face_camera()
    var center := camera.unproject_position(item.spinner.global_position)
    for star in item.stars:
     var error := center.distance_to(camera.unproject_position(star.global_position))
     if error > .01:
      failures += 1
      print("Center error: ",error)
    item.free()
 print("PINATA CAMERA CENTERING failures=",failures)
 get_tree().quit(failures)
