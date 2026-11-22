extends SceneTree
func _initialize() -> void:
 var surfaces: Dictionary={}
 var scenes: Array=[Wardrobe.CLIMBER]
 scenes.append_array(Wardrobe.HEAD_SCENES)
 for packed in scenes:
  if packed==null:continue
  var root: Node=packed.instantiate()
  for node in root.find_children("*","MeshInstance3D",true,false):
   var mesh: Mesh=node.mesh
   if mesh==null or mesh.get_surface_count()==0 or surfaces.has(mesh.resource_path):continue
   var arr:=mesh.surface_get_arrays(0)
   surfaces[mesh.resource_path]={"vertices":arr[Mesh.ARRAY_VERTEX],"indices":arr[Mesh.ARRAY_INDEX]}
  root.free()
 var data:=Resource.new();data.set_meta("surfaces",surfaces)
 var err:=ResourceSaver.save(data,"res://ui3d/spider_body_geometry.res",ResourceSaver.FLAG_COMPRESS)
 print("SPIDER_GEOMETRY_BAKE ",surfaces.size()," surfaces, error ",err)
 quit(err)
