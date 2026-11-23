extends Node3D
const Effect=preload("res://tests/petrified_review/effect.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/petrified/"
func _ready() -> void:
 var main=load("res://game/main.tscn").instantiate();add_child(main);main.show_screen("customize")
 for node in main.find_children("*","Node",true,false):
  if node.get_script()==preload("res://ui3d/lock_effect_preparation.gd"):node.set_process(false)
 var model: Node3D=main.screens.customize.preview
 for i in 50:await get_tree().process_frame
 await Effect.prepare()
 var fx=Effect.attach(model,true,true);fx.set_process(false)
 for wait in 30:await get_tree().process_frame
 fx.set_process(false)
 print("RARE_FLOWER ",is_instance_valid(fx.flower)," search max us ",fx.flower_max_slice_us)
 print("PETRIFIED_SETUP_US ",fx.setup_us," wraps ",fx.skins.size())
 var triangles:=0
 # Body shell uses original geometry; flower and transient rubble are separate.
 print("PETRIFIED_TRIANGLES ",triangles)
 DirAccess.make_dir_recursive_absolute(OUT+"frames")
 for i in 97:
  fx.tick(i/12.0)
  if i in [48,66]:
   assert(fx.on_grab((fx.skins[4].node.global_transform*fx.skins[4].node.mesh.get_aabb()).get_center()))
   fx.debris.set_process(false)
  if i==50:assert(not fx.on_grab(fx.skins[3].node.global_position))
  if i>=48:
   fx.debris.step((i-(66 if i>=66 else 48))/12.0)
  await get_tree().process_frame
  await RenderingServer.frame_post_draw
  var img=get_viewport().get_texture().get_image()
  img.get_region(Rect2i(1040,320,400,600)).save_png(OUT+"frames/%03d.png"%i)
 if is_instance_valid(fx.flower):print("FLOWER_SCREEN ",main.cam.unproject_position(fx.flower.global_position)," visible ",fx.flower.visible," scale ",fx.flower.scale," gap ",fx.flower.get_meta("crack_gap"))
 print("PETRIFIED_REVIEW_DONE");get_tree().quit()
