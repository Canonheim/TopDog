extends Node
const Prep=preload("res://ui3d/lock_effect_preparation.gd")
const Effect=preload("res://ui3d/vines/vines.gd")
var errors: Array[String]=[]
func check(ok: bool, message: String) -> void:
	if not ok: errors.append(message);push_error(message)
func _ready() -> void:
	check(Prep.validation_errors().is_empty(),"Catalog and finite budgets")
	check(Wardrobe.clean({"effect":"vines"}).effect=="vines","Selection survives profile normalization")
	check(Net._clean_players([{"name":"Vines","slot":0,"appearance":{"effect":"vines"}}])[0].appearance.effect=="vines","Network selection survives")
	var main=load("res://game/main.tscn").instantiate()
	add_child(main)
	# Keep this focused test from preparing unrelated cosmetics in the background.
	for node in main.find_children("*","Node",true,false):
		if node.get_script()==Prep: node.set_process(false)
	main.show_screen("customize")
	check("Vines" in main.screens.customize.menu.items[4].options,"Customization menu includes Vines")
	# Request before warm-up completes: deferred preparation must still display it.
	main.lucha.play_lock_effect("vines")
	var deadline:=Time.get_ticks_msec()+10000
	while not main.screens.customize.preview.has_node("Vines") and Time.get_ticks_msec()<deadline: await get_tree().process_frame
	check(main.screens.customize.preview.has_node("Vines"),"Cold customization preview appears")
	while not Prep.is_prepared("vines") and Time.get_ticks_msec()<deadline:
		Prep.prepare_step("vines")
		await get_tree().process_frame
	check(Prep.is_prepared("vines"),"Incremental preparation finishes")
	var profiles: Dictionary={}
	for i in 4:
		main.screens.customize._rebuild_preview(0)
		main.lucha.play_lock_effect("vines")
		var fx=main.screens.customize.preview.get_node_or_null("Vines")
		check(fx!=null,"Repeated preview attaches")
		if fx!=null: profiles[str(fx.get_meta("profile"))]=true
	check(profiles.size()>1,"Repeated preview varies")
	var world:=Node3D.new();add_child(world)
	var game:=Game.new();game.world=world;game.dress=false;add_child(game)
	game.set_process(false);game.set_physics_process(false)
	game.roster=[{"pid":0,"peer":1,"name":"Vines","appearance":{"effect":"vines"}}]
	var actor:=Climber.new();actor.climber_id=42;actor.player_id=0
	game.add_child(actor);actor.build(Vector2.ZERO,world,Wardrobe.CLIMBER)
	actor.make_puppet();actor.set_physics_process(false)
	game.climbers[42]=actor;game.live[0]=42
	game.attached_lock_effect.connect(func(id: String,c: Climber): main.lucha.play_attached_lock_effect(id,c))
	var pose=actor.pose()
	game._rpc_freeze(actor.climber_id,pose,"made","locked",actor.top_height(),game.line,true)
	var fx=actor.get_node_or_null("Vines")
	check(fx!=null,"Actual match freeze dispatch")
	if fx!=null:
		check(fx.wraps.size()==21,"All wraps and bridges present")
		check(Prep.attach("vines",actor,main.cam)==fx,"Duplicate protection")
		await get_tree().create_timer(3.4).timeout
		check(is_instance_valid(fx) and not fx.is_processing(),"Settled vines persist with no idle processing")
		var wraps=fx.wraps.duplicate()
		fx.free()
		await get_tree().process_frame
		for wrap in wraps: check(not is_instance_valid(wrap),"Detached wrap cleanup")
		var restored=Prep.attach("vines",actor,main.cam,false)
		check(restored!=null and not restored.is_processing(),"Settled restoration without replay")
	game.queue_free();world.queue_free();main.queue_free()
	await get_tree().process_frame
	var report={"errors":errors,"preview_profiles":profiles.size(),"cached_meshes":Effect.cache.size()+1,"prepare_max_ms":Prep.step_max_ms.get("vines",0),"build_performed":false}
	var f:=FileAccess.open("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/vines-new-model/installation/integration.json",FileAccess.WRITE)
	f.store_string(JSON.stringify(report,"  "));f.close()
	print("VINES_INTEGRATION ",JSON.stringify(report))
	get_tree().quit(0 if errors.is_empty() else 1)
