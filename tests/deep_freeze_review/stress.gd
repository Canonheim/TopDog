extends Node3D
const Effect=preload("res://tests/deep_freeze_review/freeze.gd")
var errors: Array[String]=[]
func check(ok: bool,label: String) -> void:
	if not ok:errors.append(label)
func _ready() -> void:
	var owners: Array=[];var effects: Array=[]
	for i in 20:
		var actor:=Climber.new();actor.climber_id=100+i;add_child(actor);actor.build(Vector2(i*3,0),self,Wardrobe.CLIMBER);actor.freeze();owners.append(actor)
		var fx:=Effect.new();add_child(fx);fx.set_process(false);effects.append(fx);fx.setup(actor)
	var deadline:=Time.get_ticks_msec()+20000
	var ready:=false
	while not ready and Time.get_ticks_msec()<deadline:
		ready=true
		for fx in effects:if not fx.get_meta("ready",false):ready=false
		await get_tree().process_frame
	check(ready,"Twenty concurrent setup jobs completed")
	var active:=0;var puffs:=0;var maximum:=0
	for fx in effects:
		maximum=maxi(maximum,fx.icicles.size());check(fx.icicles.size()>=4 and fx.icicles.size()<=8,"Icicle cap")
		if fx.mist_active:active+=1;puffs+=fx.mist.multimesh.instance_count
	check(active==20 and puffs<=120,"Six reused puffs per player")
	var samples: Array=[]
	for frame in 60:
		var begin:=Time.get_ticks_usec()
		for fx in effects:fx.tick(5+frame*.07)
		samples.append((Time.get_ticks_usec()-begin)/1000.0)
	for fx in effects:fx.tick(5)
	await get_tree().process_frame
	check(get_tree().get_nodes_in_group(Effect.MIST_GROUP).size()==20,"Mist remains after animation")
	for fx in effects:check(fx.settled and fx.mist_active,"Settled frost keeps faint mist")
	for fx in effects:fx.free()
	check(get_tree().get_nodes_in_group(Effect.MIST_GROUP).is_empty(),"Mist owners cleaned up")
	for actor in owners:actor.remove()
	await get_tree().process_frame
	samples.sort()
	var report={"errors":errors,"players":20,"active_mist_sources":active,"puffs_total":puffs,"max_icicles_per_player":maximum,"twenty_player_update_p95_ms":samples[56],"twenty_player_update_max_ms":samples[-1],"gpu_measured":false}
	var f:=FileAccess.open("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/deep-freeze/stress.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close()
	print("FREEZE_STRESS ",JSON.stringify(report));get_tree().quit(0 if errors.is_empty() else 1)
