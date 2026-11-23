extends Node
func _ready() -> void:
 var fx=load("res://ui3d/spiders_effect.gd")
 fx.prepare()
 var cache:=Resource.new()
 cache.set_meta("thread",fx.thread_mesh)
 cache.set_meta("web_material",fx.web_material)
 cache.set_meta("spider_material",fx.spider_material)
 cache.set_meta("gaits",fx.spider_meshes)
 var err:=ResourceSaver.save(cache,"res://ui3d/spider_prepared.res")
 assert(err==OK)
 var restored=load("res://ui3d/spider_prepared.res")
 assert(restored.get_meta("gaits").size()==12)
 for i in 12:
  assert(var_to_bytes(restored.get_meta("gaits")[i].surface_get_arrays(0))==var_to_bytes(fx.spider_meshes[i].surface_get_arrays(0)))
 print("SPIDER_CACHE_VERIFIED 12 identical gait meshes and original materials")
 get_tree().quit()
