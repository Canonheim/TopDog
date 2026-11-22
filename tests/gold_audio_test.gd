extends Node3D
const Gold = preload("res://ui3d/gold/gold.gd")
var fails := 0
func check(label: String, ok: bool) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: fails+=1
func model() -> Node3D:
 var actor:=Node3D.new()
 add_child(actor)
 var mesh:=MeshInstance3D.new()
 mesh.name=Climber.Layout.PIECES[Climber.Layout.ORDER[0]].mesh
 mesh.mesh=BoxMesh.new()
 actor.add_child(mesh)
 return actor
func _ready() -> void:
 var actor:=model()
 var effect=Gold.attach_owner(actor,true)
 var voice=effect.get_node_or_null("GoldTransformSound")
 check("sound begins with gold material applied", voice!=null and voice.playing and effect.skins[0].node.material_override==Gold.gold_material)
 check("approved sound at authored pitch on Effects bus", voice.stream==Gold.TRANSFORM_SOUND and voice.pitch_scale==1.0 and voice.bus=="Effects")
 check("repeated attach does not replay transformation", Gold.attach_owner(actor,true)==effect and effect.get_node("GoldTransformSound")==voice)
 var restored:=model()
 var silent=Gold.attach_owner(restored,false)
 check("restoring existing gold is silent", silent.get_node_or_null("GoldTransformSound")==null)
 actor.queue_free()
 restored.queue_free()
 await get_tree().process_frame
 await get_tree().process_frame
 print("RESULT fails=",fails)
 get_tree().quit(fails)
