extends Node
const Prep=preload("res://ui3d/lock_effect_preparation.gd")
const Loader=preload("res://game/match_effect_preloader.gd")
var errors: Array=[]
func check(ok: bool,label: String) -> void:
 if not ok:errors.append(label);push_error(label)
func _ready() -> void:
 var ids=["spiders","absolute_zero","ruby","sapphire","emerald","quartz","rose_quartz","topaz","amethyst","rainbow_quartz"]
 var roster: Array=[]
 for id in ids:roster.append({"appearance":{"effect":id}})
 var loader:=Loader.new();add_child(loader);loader.start(roster,false)
 var report: Dictionary=await loader.completed
 print("MENU_FIX_PRELOAD ",JSON.stringify(report));check(report.errors.is_empty(),"Preload");loader.queue_free()
 var main=load("res://game/main.tscn").instantiate();add_child(main)
 for node in main.find_children("*","Node",true,false):
  if node.get_script()==Prep:node.set_process(false)
 for id in ids:
  Wardrobe.profiles[Wardrobe.selected].effect=id
  main.show_screen("title");main.show_screen("customize")
  var menu=main.screens.customize
  var node_name="Spiders" if id=="spiders" else ("AbsoluteZero" if id=="absolute_zero" else "CrystalGrowth")
  for replay in 2:
   if replay==1:menu._refresh(1)
   var deadline:=Time.get_ticks_msec()+20000
   var fx: Node=null
   while Time.get_ticks_msec()<deadline:
    fx=menu.preview.get_node_or_null(node_name)
    if fx!=null and fx.get_meta("ready",false):break
    await get_tree().process_frame
   check(fx!=null and fx.get_meta("ready",false),"Automatic preview "+id)
   if fx==null:continue
   fx.tick(7)
   if id=="spiders":
    check(fx.webs.size()>0,"Spiders visible web");check(fx.body_geometry_misses==0,"Spiders cached geometry")
    print("SPIDERS webs ",fx.webs.size()," slice_us ",fx.setup_max_slice_us)
   elif id=="absolute_zero":
    check(fx.skins.size()>0 and fx.icicles.size()>=6,"Frost skin and icicles")
    print("FROST icicles ",fx.icicles.size()," slice_us ",fx.setup_max_slice_us)
   else:check(fx.shard_count>30,"Crystal coverage "+id)
   await get_tree().create_timer(.6).timeout
   await RenderingServer.frame_post_draw
   get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/crystal-growth-enclosure/installation/tuned-"+id+".png")
 main.queue_free();await get_tree().process_frame;await get_tree().process_frame
 print("MENU_FIX_RESULT ",JSON.stringify(errors));get_tree().quit(0 if errors.is_empty() else 1)
