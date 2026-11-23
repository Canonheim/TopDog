extends Node
const Prep=preload("res://ui3d/lock_effect_preparation.gd")
const Base=preload("res://ui3d/crystal_growth/effect.gd")
const Loader=preload("res://game/match_effect_preloader.gd")
const VARIANTS=[["ruby","Ruby",2],["sapphire","Sapphire",1],["emerald","Emerald",5],["quartz","Quartz",0],["rose_quartz","Rose Quartz",3],["topaz","Topaz",4],["amethyst","Amethyst",6],["rainbow_quartz","Rainbow Quartz",7]]
var errors: Array=[]
func check(ok: bool,label: String) -> void:
 if not ok:errors.append(label);push_error(label)
func wait_fx(fx: Node) -> void:
 var end:=Time.get_ticks_msec()+20000
 while is_instance_valid(fx) and not fx.initialized and Time.get_ticks_msec()<end:await get_tree().process_frame
 check(is_instance_valid(fx) and fx.initialized,"Initialized")
func _ready() -> void:
 check(Prep.validation_errors().is_empty(),str(Prep.validation_errors()))
 check(Wardrobe.EFFECTS.size()==Wardrobe.EFFECT_NAMES.size(),"Catalog name alignment")
 var roster: Array=[]
 for item in VARIANTS:roster.append({"appearance":{"effect":item[0]}})
 var job:=Loader.new();add_child(job);job.start(roster,false)
 var report: Dictionary=await job.completed
 check(report.errors.is_empty(),"Preload errors");print("CRYSTAL_INSTALLED_PRELOAD ",JSON.stringify(report));job.queue_free()
 var main=load("res://game/main.tscn").instantiate();add_child(main)
 for node in main.find_children("*","Node",true,false):
  if node.get_script()==Prep:node.set_process(false)
 main.show_screen("customize")
 var world:=Node3D.new();add_child(world)
 var game:=Game.new();game.world=world;game.dress=false;add_child(game);game.set_process(false);game.set_physics_process(false)
 game.attached_lock_effect.connect(func(id: String,c: Climber):main.lucha.play_attached_lock_effect(id,c))
 for item in VARIANTS:
  var id: String=item[0];var color_index: int=item[2]
  Wardrobe.profiles[Wardrobe.selected].effect=id
  check(item[1] in main.screens.customize.menu.items[4].options,"Menu "+id)
  check(Wardrobe.clean({"effect":id}).effect==id,"Saved selection "+id)
  check(Net._clean_players([{"name":"Test","slot":0,"appearance":{"effect":id}}])[0].appearance.effect==id,"Network "+id)
  var patterns: Array=[]
  for replay in 2:
   main.screens.customize._rebuild_preview(0)
   main.screens.customize.menu.items[4].index=Wardrobe.EFFECTS.find(id);main.screens.customize.menu._relabel(4)
   var begin:=Time.get_ticks_usec();main.lucha.play_lock_effect(id)
   print("CRYSTAL_MENU_US ",id," ",Time.get_ticks_usec()-begin)
   var fx=main.screens.customize.preview.get_node_or_null("CrystalGrowth");check(fx!=null,"Preview "+id);await wait_fx(fx)
   check(fx.shade_index==color_index,"Preview color "+id);patterns.append(fx.film_seed);fx.tick(3)
   check(fx.aura.multimesh.instance_count==32,"32 sparkles, no fog")
   check(fx.get_node_or_null("Shell")==null,"No enclosure")
   for batch in fx.batches:check(batch.get_instance_shader_parameter("multicolor")==float(color_index==7),"Spectrum mode")
  check(patterns[0]!=patterns[1],"Randomized growth "+id)
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/crystal-growth-enclosure/installation/menu-"+id+".png")
  game.roster=[{"pid":0,"peer":1,"name":"Test","appearance":{"effect":id}}]
  var actor:=Climber.new();actor.climber_id=990;actor.player_id=0;game.add_child(actor);actor.build(Vector2.ZERO,world,Wardrobe.CLIMBER);actor.make_puppet();actor.set_physics_process(false)
  game.climbers[990]=actor;game.live[0]=990
  var begin:=Time.get_ticks_usec();game._rpc_freeze(990,actor.pose(),"made","locked",actor.top_height(),game.line,true)
  print("CRYSTAL_FREEZE_US ",id," ",Time.get_ticks_usec()-begin)
  var fx=actor.get_node_or_null("CrystalGrowth");check(fx!=null,"Match dispatch "+id);await wait_fx(fx)
  check(fx.shade_index==color_index,"Match color "+id);check(Prep.attach(id,actor,main.cam)==fx,"No duplicate")
  check(fx.setup_slice_us<1500,"Setup slice budget "+id);check(fx.batches.size()+2<=18,"Node budget")
  fx.tick(3)
  var skin=fx.skins[0].node;var original=fx.skins[0].original
  fx.queue_free();await get_tree().process_frame;await get_tree().process_frame
  check(skin.material_override==original,"Material restored")
  var restored=Prep.attach(id,actor,main.cam,false);await wait_fx(restored);check(restored.shade_index==color_index,"Restored color")
  game.climbers.clear();game.live.clear();actor.remove();await get_tree().process_frame
 main.screens.customize._rebuild_preview(0);main.lucha.play_lock_effect("ruby");await get_tree().process_frame;main.screens.customize._rebuild_preview(0)
 game.queue_free();world.queue_free();main.queue_free();await get_tree().process_frame;await get_tree().process_frame
 check(get_tree().get_nodes_in_group(&"legendary_locked_lod").is_empty(),"Legendary cleanup")
 print("CRYSTAL_INSTALL_RESULT ",JSON.stringify(errors));get_tree().quit(0 if errors.is_empty() else 1)
