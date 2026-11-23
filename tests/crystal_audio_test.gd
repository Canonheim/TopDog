extends Node3D
const FX=preload("res://ui3d/crystal_growth/effect.gd")
const NAMES=["ruby","sapphire","emerald","quartz","rose_quartz","topaz","amethyst","rainbow_quartz"]
var fails:=0
func check(label: String,ok: bool) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok:fails+=1
func _ready() -> void:
 FX.prepared=true;FX.preparing=true
 check("approved clip matches full growth duration",absf(FX.GROWTH_SOUND.get_length()-FX.DURATION)<.0001)
 for mineral in NAMES:
  var model:=Wardrobe.CLIMBER.instantiate();add_child(model)
  var wrapper=load("res://ui3d/crystal_growth/"+mineral+".gd")
  var fx=wrapper.preview(model,null)
  for frame in 240:
   if fx.initialized:break
   check("no sound during geometry preparation",fx.get_node_or_null("CrystalGrowthSound")==null)
   await get_tree().process_frame
  var voice=fx.get_node_or_null("CrystalGrowthSound")
  check(mineral+" begins with growth",fx.initialized and fx.age<.1 and voice!=null and voice.playing)
  if voice!=null:check(mineral+" exact clip and pitch",voice.stream==FX.GROWTH_SOUND and voice.pitch_scale==1.0 and voice.bus=="Effects")
  check(mineral+" duplicate attach does not replay",FX.attach(model,true)==fx)
  model.queue_free();await get_tree().process_frame
 var restored:=Wardrobe.CLIMBER.instantiate();add_child(restored)
 var silent=FX.attach(restored,false,0)
 for frame in 240:
  if silent.initialized:break
  await get_tree().process_frame
 check("restored crystals are silent",silent.initialized and silent.get_node_or_null("CrystalGrowthSound")==null)
 restored.queue_free();await get_tree().process_frame
 print("RESULT fails=",fails);get_tree().quit(fails)
