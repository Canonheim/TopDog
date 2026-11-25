extends Node
func _ready() -> void:
 var mesh=load("res://ui3d/crystal_growth/shard.res")
 var a=mesh.surface_get_arrays(0)
 var v: PackedVector3Array=a[Mesh.ARRAY_VERTEX]
 var n: PackedVector3Array=a[Mesh.ARRAY_NORMAL]
 var idx: PackedInt32Array=PackedInt32Array()
 var inward:=0;var outward:=0
 for i in v.size():
  if v[i].y<.01 or v[i].y>.9:continue
  var radial=Vector3(v[i].x,0,v[i].z).normalized()
  if n[i].dot(radial)<0:inward+=1
  else:outward+=1
 print("SHARD_NORMALS inward=",inward," outward=",outward," vertices=",v.size()," indices=",idx.size())
 get_tree().quit()
