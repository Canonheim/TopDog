extends Node
const Prep=preload("res://ui3d/lock_effect_preparation.gd")
const Fx=preload("res://ui3d/petrified/effect.gd")
const Loader=preload("res://game/match_effect_preloader.gd")
var errors: Array=[]
func check(ok: bool,label: String) -> void:
 if not ok:errors.append(label);push_error(label)
func wait_fx(fx: Node) -> void:
 var end:=Time.get_ticks_msec()+20000
 while is_instance_valid(fx) and (not fx.get_meta("ready",false) or not fx.grass_ready) and Time.get_ticks_msec()<end:await get_tree().process_frame
 check(is_instance_valid(fx) and fx.get_meta("ready",false) and fx.grass_ready,"Effect ready and grass placed")
func _ready() -> void:
 check(Prep.validation_errors().is_empty(),str(Prep.validation_errors()))
 check(Wardrobe.EFFECTS.size()==Wardrobe.EFFECT_NAMES.size(),"Catalog name alignment")
 var job:=Loader.new();add_child(job);job.start([{"appearance":{"effect":"petrified"}}],false)
 var report: Dictionary=await job.completed
 check(report.errors.is_empty(),"Match preload "+str(report));print("PETRIFIED_PRELOAD ",JSON.stringify(report));job.queue_free()
 var main=load("res://game/main.tscn").instantiate();add_child(main)
 for node in main.find_children("*","Node",true,false):
  if node.get_script()==Prep:node.set_process(false)
 main.show_screen("customize")
 check("Petrified" in main.screens.customize.menu.items[4].options,"Menu name")
 check(Wardrobe.clean({"effect":"petrified"}).effect=="petrified","Saved selection")
 check(Net._clean_players([{"name":"Test","slot":0,"appearance":{"effect":"petrified"}}])[0].appearance.effect=="petrified","Network selection")
 var seeds: Array=[]
 for i in 2:
  main.screens.customize._rebuild_preview(0)
  main.screens.customize.menu.items[4].index=Wardrobe.EFFECTS.find("petrified")
  main.screens.customize.menu._relabel(4);main.lucha.play_lock_effect("petrified")
  var fx=main.screens.customize.preview.get_node_or_null("Petrified")
  check(fx!=null,"Menu effect");await wait_fx(fx);seeds.append(fx.stone_seed);fx.tick(100)
  check(fx.grass.size()>0 and fx.grass.size()<=22,"Bounded grass")
  check(not fx.is_processing(),"Settled stops processing")
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/petrified/installation/menu.png")
 check(seeds[0]!=seeds[1],"Fresh pattern each preview")
 main.screens.customize._rebuild_preview(0);main.lucha.play_lock_effect("petrified")
 await get_tree().process_frame;main.screens.customize._rebuild_preview(0)
 var world:=Node3D.new();add_child(world)
 var game:=Game.new();game.world=world;game.dress=false;add_child(game);game.set_process(false);game.set_physics_process(false)
 game.attached_lock_effect.connect(func(id: String,c: Climber):main.lucha.play_attached_lock_effect(id,c))
 game.roster=[{"pid":0,"peer":1,"name":"Test","appearance":{"effect":"petrified"}}]
 var actor:=Climber.new();actor.climber_id=90;actor.player_id=0;game.add_child(actor)
 actor.build(Vector2.ZERO,world,Wardrobe.CLIMBER);actor.make_puppet();actor.set_physics_process(false)
 game.climbers[90]=actor;game.live[0]=90
 var started:=Time.get_ticks_usec()
 game._rpc_freeze(90,actor.pose(),"made","locked",actor.top_height(),game.line,true)
 print("PETRIFIED_FREEZE_US ",Time.get_ticks_usec()-started)
 var fx=actor.get_node_or_null("Petrified");check(fx!=null,"Actual freeze dispatch");await wait_fx(fx)
 check(Prep.attach("petrified",actor,main.cam)==fx,"No duplicate attachment")
 fx.tick(100);check(not fx.is_processing(),"Match settles")
 check(fx.on_grab(Vector3(0,1,0)),"Grab debris starts");check(not fx.on_grab(Vector3(0,1,0)),"Grab overlap suppressed")
 var skin=fx.skins[0].node;var original=fx.skins[0].original
 fx.queue_free();await get_tree().process_frame;await get_tree().process_frame
 check(skin.material_override==original,"Material restored")
 var restored=Prep.attach("petrified",actor,main.cam,false);await wait_fx(restored);restored.tick(100)
 check(restored.grass.size()>0,"Restored frozen actor receives grass")
 game.climbers.clear();game.live.clear();actor.remove();await get_tree().process_frame
 game.queue_free();world.queue_free();main.queue_free();await get_tree().process_frame;await get_tree().process_frame
 check(get_tree().get_nodes_in_group(&"legendary_locked_lod").is_empty(),"Legendary cleanup")
 print("PETRIFIED_INSTALL_RESULT ",JSON.stringify(errors))
 get_tree().quit(0 if errors.is_empty() else 1)
