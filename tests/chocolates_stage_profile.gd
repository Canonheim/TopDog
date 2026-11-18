extends Node
func stamp(label: String, start: int) -> void:
 print("CHOC_STAGE ",label," ",(Time.get_ticks_usec()-start)/1000.0)
func _ready() -> void:
 var path := "res://kit/models/chocolate_milk_drizzle_square.glb"
 var t := Time.get_ticks_usec()
 ResourceLoader.exists(path)
 stamp("exists",t)
 t = Time.get_ticks_usec()
 ResourceLoader.load_threaded_request(path,"PackedScene")
 stamp("request",t)
 while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
  await get_tree().process_frame
 t = Time.get_ticks_usec()
 var scene: PackedScene = ResourceLoader.load_threaded_get(path)
 stamp("get",t)
 t = Time.get_ticks_usec()
 var sample := scene.instantiate()
 stamp("instantiate",t)
 t = Time.get_ticks_usec()
 CelPass.one()
 stamp("one",t)
 t = Time.get_ticks_usec()
 CelPass.celify(sample)
 stamp("celify",t)
 t = Time.get_ticks_usec()
 sample.free()
 stamp("free",t)
 get_tree().quit()
