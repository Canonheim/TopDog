extends Node
const Gold=preload("res://ui3d/gold/gold.gd")
func _ready() -> void:
 Gold.prepare()
 for item in [[Gold.gold_material,"gold_material.tres"],[Gold.star_material,"star_material.tres"],[Gold.star_mesh,"star_mesh.res"]]:
  var error:=ResourceSaver.save(item[0],"res://ui3d/gold/"+item[1])
  if error!=OK:get_tree().quit(error);return
 print("GOLD_STATIC_ASSETS_SAVED")
 get_tree().quit()
