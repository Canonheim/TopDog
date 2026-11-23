extends RefCounted
const Base=preload("res://ui3d/crystal_growth/effect.gd")
static func prepare_unit(index: int) -> bool:
 return Base.prepare_unit(index)
static func preview(model: Node3D,_camera: Camera3D) -> Node:
 return Base.attach(model,true,0)
static func attach(actor: Climber,_camera: Camera3D=null,animate:=true) -> Node:
 if not is_instance_valid(actor) or actor.removed or actor.state!=Climber.State.FROZEN:return null
 return Base.attach(actor,animate,0)
