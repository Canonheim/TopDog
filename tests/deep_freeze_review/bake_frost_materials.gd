extends SceneTree
const Frost=preload("res://ui3d/absolute_zero/absolute_zero.gd")
func _initialize() -> void:
 Frost.prepare()
 for item in [[Frost.frost_material,"frost_material.tres"],[Frost.mist_material,"mist_material.tres"],[Frost.ice_mesh,"ice_mesh.res"],[Frost.mist_mesh,"mist_mesh.tres"]]:
  var error:=ResourceSaver.save(item[0],"res://ui3d/absolute_zero/"+item[1])
  if error!=OK:quit(error);return
 print("FROST_STATIC_ASSETS_SAVED")
 quit()
