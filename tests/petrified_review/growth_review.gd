extends Node3D
const Effect=preload("res://tests/petrified_review/effect.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/petrified/"
func _ready() -> void:
 get_window().size=Vector2i(960,480);get_window().content_scale_size=Vector2i(960,480)
 var env:=WorldEnvironment.new();env.environment=Environment.new();env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("202b2a");add_child(env)
 var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=.43;camera.position=Vector3(.14,0,1);add_child(camera)
 var flowers: Array=[]
 var normals: Array=[Vector3.UP,Vector3.RIGHT,Vector3.DOWN]
 for i in 3:
  var root:=Vector3(i*.14,0,0)
  var stem:=MeshInstance3D.new();stem.mesh=Effect.FLOWER;stem.material_override=Effect.FLOWER_MATERIAL
  add_child(stem);stem.position=root;stem.basis=Effect.surface_basis(normals[i])
  var direction: Vector3=Vector3.UP-normals[i]*Vector3.UP.dot(normals[i])
  if direction.length_squared()<.02:direction=stem.basis.x
  direction=direction.normalized()
  stem.set_instance_shader_parameter("stem_curve",Vector2(direction.dot(stem.basis.x),direction.dot(stem.basis.z)))
  stem.set_instance_shader_parameter("stem_bend",lerpf(.3,1.95,(1-normals[i].y)*.5))
  flowers.append(stem)
  var block:=MeshInstance3D.new();var mesh:=BoxMesh.new();mesh.size=Vector3(.045,.008,.025);block.mesh=mesh
  var material:=StandardMaterial3D.new();material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;material.albedo_color=Color("91958e");block.material_override=material
  add_child(block);block.basis=stem.basis;block.position=root-normals[i]*.004
  var label:=Label3D.new();label.text=["UPRIGHT","SIDEWAYS","UPSIDE DOWN"][i];label.font_size=32;label.pixel_size=.00024;add_child(label);label.position=Vector3(i*.14,-.085,0)
 DirAccess.make_dir_recursive_absolute(OUT+"growth-frames")
 for frame in 49:
  for flower in flowers:flower.set_instance_shader_parameter("growth",smoothstep(0.,1.3,frame/24.0))
  await get_tree().process_frame
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png(OUT+"growth-frames/%03d.png"%frame)
 print("FLOWER_ORIENTATIONS_RENDERED");get_tree().quit()
