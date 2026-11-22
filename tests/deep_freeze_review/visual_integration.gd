extends Node
const Prep=preload("res://ui3d/lock_effect_preparation.gd")
var errors: Array=[]
func check(ok: bool,label: String) -> void:
 if not ok:errors.append(label);push_error(label)
func ready_effect(effect: Node) -> void:
 var end:=Time.get_ticks_msec()+15000
 while is_instance_valid(effect) and not effect.get_meta("ready",false) and Time.get_ticks_msec()<end:
  if effect.name=="AbsoluteZero":check(not effect.visible,"No visible uninitialized icicles")
  if effect.name=="Spiders":
   for web in effect.webs:check(web.visible_instance_count==0,"No complete-web flash during setup")
  await get_tree().process_frame
 check(is_instance_valid(effect) and effect.get_meta("ready",false),"Effect ready")
func _ready() -> void:
 check(Prep.validation_errors().is_empty(),"Catalog budgets "+str(Prep.validation_errors()))
 var main=load("res://game/main.tscn").instantiate();add_child(main)
 for node in main.find_children("*","Node",true,false):
  if node.get_script()==Prep:node.set_process(false)
 main.show_screen("customize")
 var world:=Node3D.new();add_child(world)
 var game:=Game.new();game.world=world;game.dress=false;add_child(game);game.set_process(false);game.set_physics_process(false)
 game.attached_lock_effect.connect(func(id: String,c: Climber):main.lucha.play_attached_lock_effect(id,c))
 var index:=0
 for entry in [["spiders","Spiders","Spiders"]]:
  var id: String=entry[0];var node_name: String=entry[2]
  check(Wardrobe.clean({"effect":id}).effect==id,"Profile "+id)
  check(Net._clean_players([{"name":"Test","slot":0,"appearance":{"effect":id}}])[0].appearance.effect==id,"Network "+id)
  check(entry[1] in main.screens.customize.menu.items[4].options,"Menu "+id)
  while not Prep.is_prepared(id):Prep.prepare_step(id)
  main.screens.customize._rebuild_preview(0);main.screens.customize.menu.items[4].index=Wardrobe.EFFECTS.find(id);main.screens.customize.menu._relabel(4);main.lucha.play_lock_effect(id)
  var preview=main.screens.customize.preview.get_node_or_null(node_name)
  check(preview!=null,"Preview "+id);await ready_effect(preview)
  if is_instance_valid(preview):
   preview.tick(7)
   if id=="spiders":
    check(preview.body_geometry_misses==0,"No GPU mesh readbacks in preview")
    check(preview.webs.size()>0,"Customization has visible web geometry")
    print("SPIDER_SETUP_PROFILE ",preview.setup_max_slice_us," us, ",preview.setup_yields," slices; stage ",preview.setup_max_stage,"; GPU reads ",preview.body_geometry_misses)
   await get_tree().process_frame
   await get_tree().process_frame
   await RenderingServer.frame_post_draw
   get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/legendary-install/menu-"+id+".png")
  # Cancel a fresh preview while asynchronous geometry fitting may still be running.
  main.screens.customize._rebuild_preview(0);main.screens.customize.menu.items[4].index=Wardrobe.EFFECTS.find(id);main.screens.customize.menu._relabel(4);main.lucha.play_lock_effect(id)
  await get_tree().process_frame;main.screens.customize._rebuild_preview(0)
  game.roster=[{"pid":0,"peer":1,"name":"Test","appearance":{"effect":id}}]
  var actor:=Climber.new();actor.climber_id=90+index;actor.player_id=0;game.add_child(actor)
  actor.build(Vector2(index*3,0),world,Wardrobe.CLIMBER);actor.make_puppet();actor.set_physics_process(false)
  game.climbers[actor.climber_id]=actor;game.live[0]=actor.climber_id
  game._rpc_freeze(actor.climber_id,actor.pose(),"made","locked",actor.top_height(),game.line,true)
  var fx=actor.get_node_or_null(node_name);check(fx!=null,"Match dispatch "+id);await ready_effect(fx)
  if is_instance_valid(fx):
   check(Prep.attach(id,actor,main.cam)==fx,"Duplicate attachment "+id);fx.tick(7)
   check(fx.get_child_count()+1<=Prep.NORMAL_NODE_LIMITS[id],"Node budget "+id)
   if id=="spiders":
    print("MATCH_SETUP ",fx.setup_max_slice_us," us ",fx.setup_max_stage,"; GPU reads ",fx.body_geometry_misses)
    check(fx.body_geometry_misses==0,"No GPU mesh readbacks in match")
   if id=="gold":check(fx.stars.size()==3,"Three gold stars")
   if id=="absolute_zero":check(fx.icicles.size()>=4 and fx.icicles.size()<=8 and fx.mist_active,"Absolute Zero icicles and persistent mist")
  game.climbers.erase(actor.climber_id);game.live.clear();actor.remove();await get_tree().process_frame;await get_tree().process_frame
  index+=1
 game.queue_free();world.queue_free();main.queue_free();await get_tree().process_frame;await get_tree().process_frame
 check(get_tree().get_nodes_in_group(&"legendary_locked_lod").is_empty(),"Legendary owner cleanup")
 print("LEGENDARY_INTEGRATION ",JSON.stringify({"errors":errors,"effects":["Gold","Absolute Zero","Spiders"],"build":false}))
 get_tree().quit(0 if errors.is_empty() else 1)
