extends Node
const Prep=preload("res://ui3d/lock_effect_preparation.gd")
const Effect=preload("res://ui3d/spiders_effect.gd")
var errors: Array[String]=[]
func check(ok: bool,label: String) -> void:
	if not ok:errors.append(label);push_error(label)
func ready_effect(effect: Node) -> void:
	var end:=Time.get_ticks_msec()+15000
	while is_instance_valid(effect) and not effect.get_meta("ready",false) and Time.get_ticks_msec()<end:await get_tree().process_frame
	check(is_instance_valid(effect) and effect.get_meta("ready",false),"Async effect completes")
func _ready() -> void:
	check(Prep.validation_errors().is_empty(),"Catalog and budgets consistent")
	check(Wardrobe.clean({"effect":"spiders"}).effect=="spiders","Profile accepts Spiders")
	check(Net._clean_players([{"name":"Spider","slot":0,"appearance":{"effect":"spiders"}}])[0].appearance.effect=="spiders","Network preserves cosmetic selection")
	var main=load("res://game/main.tscn").instantiate();add_child(main)
	for node in main.find_children("*","Node",true,false):
		if node.get_script()==Prep:node.set_process(false)
	main.show_screen("customize")
	check("Spiders" in main.screens.customize.menu.items[4].options,"Menu display name")
	main.lucha.play_lock_effect("spiders")
	await ready_effect(main.screens.customize.preview.get_node("Spiders"))
	var profiles: Dictionary={}
	for i in 3:
		main.screens.customize._rebuild_preview(0);main.lucha.play_lock_effect("spiders")
		var fx=main.screens.customize.preview.get_node("Spiders")
		await ready_effect(fx);profiles[str(fx.signature)]=true
	check(profiles.size()>1,"Fresh customization arrangements")
	# Rapid menu changes must safely cancel setup coroutines.
	for i in 3:
		main.screens.customize._rebuild_preview(0);main.lucha.play_lock_effect("spiders")
		await get_tree().process_frame
	main.screens.customize._rebuild_preview(0)
	while not Prep.is_prepared("spiders"):Prep.prepare_step("spiders")
	var world:=Node3D.new();add_child(world)
	var game:=Game.new();game.world=world;game.dress=false;add_child(game)
	game.set_process(false);game.set_physics_process(false)
	game.roster=[{"pid":0,"peer":1,"name":"Spider","appearance":{"effect":"spiders"}}]
	game.attached_lock_effect.connect(func(id: String,c: Climber): main.lucha.play_attached_lock_effect(id,c))
	var owners: Array=[];var effects: Array=[]
	for i in 2:
		var actor:=Climber.new();actor.climber_id=42+i;actor.player_id=0;game.add_child(actor)
		actor.build(Vector2(i*.08,0),world,Wardrobe.CLIMBER);actor.make_puppet();actor.set_physics_process(false)
		game.climbers[42+i]=actor;game.live[0]=42+i
		game._rpc_freeze(actor.climber_id,actor.pose(),"made","locked",actor.top_height(),game.line,true)
		var fx=actor.get_node_or_null("Spiders");check(fx!=null,"Match freeze dispatch")
		owners.append(actor);effects.append(fx)
	# Both preparations run concurrently; placement must atomically reserve outlines.
	for fx in effects:await ready_effect(fx)
	var surfaces:=get_tree().get_nodes_in_group(Effect.WEB_GROUP)
	for i in surfaces.size():
		for j in range(i+1,surfaces.size()):
			var a:=PackedVector2Array();var b:=PackedVector2Array()
			for p in surfaces[i].get_meta("web_outline"):
				var q: Vector3=surfaces[i].to_global(p);a.append(Vector2(q.x,q.y))
			for p in surfaces[j].get_meta("web_outline"):
				var q: Vector3=surfaces[j].to_global(p);b.append(Vector2(q.x,q.y))
			check(not Effect.outlines_overlap(a,b),"No cross-player overlap")
	var counts: Array=[];var max_triangles:=0;var max_nodes:=0
	for fx in effects:
		check(fx.webs.size()<=2,"Two-web cap")
		check(fx.spiders.size()<=8,"Eight-spider cap")
		check(Prep.attach("spiders",owners[effects.find(fx)],main.cam)==fx,"Duplicate freeze reuses effect")
		var tris:=0
		for child in fx.get_children():
			if child is MeshInstance3D:tris+=child.mesh.surface_get_array_index_len(0)/3 if child.mesh.surface_get_array_index_len(0)>0 else child.mesh.surface_get_array_len(0)/3
			if child is MultiMeshInstance3D:tris+=child.multimesh.instance_count*2
		max_triangles=maxi(max_triangles,tris);max_nodes=maxi(max_nodes,fx.get_child_count()+1);counts.append(fx.webs.size())
		fx.tick(7.0)
		for web in fx.webs:check(web.visible_instance_count==-1,"Weaving finishes")
	check(max_triangles<=Prep.REGISTRY.spiders[4],"Triangle budget")
	check(max_nodes<=Prep.NORMAL_NODE_LIMITS.spiders,"Node budget")
	var bytes:=var_to_bytes(Effect.thread_mesh.surface_get_arrays(0)).size()
	for mesh in Effect.spider_meshes:bytes+=var_to_bytes(mesh.surface_get_arrays(0)).size()
	check(bytes<=Prep.CACHE_ARRAY_BYTE_LIMITS.spiders,"Cache byte budget")
	game.queue_free();world.queue_free();main.queue_free();await get_tree().process_frame;await get_tree().process_frame
	check(get_tree().get_nodes_in_group(Effect.WEB_GROUP).is_empty(),"Owner removal releases reservations")
	var report={"errors":errors,"match_web_counts":counts,"preview_profiles":profiles.size(),"max_triangles":max_triangles,"max_nodes":max_nodes,"cache_bytes":bytes,"prepare_max_ms":Prep.step_max_ms.get("spiders",0),"build_performed":false}
	var f:=FileAccess.open("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/spider-webs/installation/checks.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close()
	print("SPIDERS_INTEGRATION ",JSON.stringify(report));get_tree().quit(0 if errors.is_empty() else 1)
