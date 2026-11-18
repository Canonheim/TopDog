extends Node
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
const IDS = ["bees","popcorn","fries","pizza_party","sushi_roll","breakfast_club","pancakes","pretzel_twist","cheese_please","candies","gummy_bears","ice_cream_social","strawberry_fields","citrus_splash","banana_bonanza","pineapple_express","mushroom_mix","coffee_break","tea_time","nuts_acorns","puzzle_pieces","game_night","playing_cards","pencil_case","sewing_kit","toolbox","music_notes","love_letters","bats","assorted_bugs","pinecone_shower","flower_power","seashell_shuffle","autumn_harvest","birthday_bash"]
var failures: Array[String] = []
var emitted: Array = []
func check(ok: bool, label: String) -> void:
	if not ok:
		failures.append(label)
		push_error(label)
func _ready() -> void:
	var path: String = Wardrobe.SavePaths.settings("climbers.cfg")
	var existed := FileAccess.file_exists(path)
	var backup := FileAccess.get_file_as_bytes(path) if existed else PackedByteArray()
	var original: Array = Wardrobe.profiles.duplicate(true)
	var selected: int = Wardrobe.selected
	check(Prep.validation_errors().is_empty(), "Complete preparation registry")
	for cancelled in ["dog_fur","snow_day","bouncy_balls","cherry_bomb"]:
		check(not cancelled in Wardrobe.EFFECTS, "Excluded "+cancelled)
	check(Wardrobe.clean({"effect":"cherry_bomb"}).effect == "ice_cream_social", "Retired cherry selection migrates to ice cream")
	var main = load("res://game/main.tscn").instantiate()
	add_child(main)
	for child in main.get_children():
		if child.get_script() == Prep: child.set_process(false)
	await get_tree().create_timer(.8).timeout
	main.game.lock_effect.connect(func(effect): emitted.append(effect))
	var render_review := "--render-review" in OS.get_cmdline_user_args()
	for id in IDS:
		if render_review and id not in ["breakfast_club","ice_cream_social","toolbox","love_letters","seashell_shuffle"]: continue
		check(id in Wardrobe.EFFECTS, id+" registered")
		check(Wardrobe.EFFECT_METADATA.get(id,{}).get("rarity","") == "common", id+" common tier")
		if not Prep.REGISTRY.has(id): continue
		var started := Time.get_ticks_msec()
		while not Prep.is_prepared(id) and Time.get_ticks_msec()-started < 15000:
			Prep.prepare_step(id)
			await get_tree().process_frame
		check(Prep.is_prepared(id),id+" prepares")
		main.show_screen("customize")
		var editor = main.screens.customize
		editor._set_choice("effect",id)
		Wardrobe.load_profiles()
		check(Wardrobe.for_slot(0).effect == id,id+" selection persisted")
		check(editor.menu.items[4].options[Wardrobe.EFFECTS.find(id)] == Wardrobe.EFFECT_NAMES[Wardrobe.EFFECTS.find(id)],id+" menu label")
		var players: Array = Net._clean_players([{"name":"Test","slot":0,"appearance":Wardrobe.for_slot(0)}])
		check(players[0].appearance.effect == id,id+" network appearance preserved")
		main._start_practice()
		await get_tree().create_timer(.8).timeout
		var climbers: Array = main.game.live_climbers()
		check(not climbers.is_empty(),id+" practice climber spawned")
		if not climbers.is_empty():
			var c: Climber = climbers[0]
			var before: Array = main.cam.get_children()
			emitted.clear()
			main.game._rpc_freeze(c.climber_id,c.pose(),"made","locked",2.0,2.0,true)
			check(emitted == [id],id+" actual lock dispatch")
			var roots: Array = main.cam.get_children().filter(func(n): return n not in before and n is Node3D)
			check(roots.size() == 1,id+" exactly one effect root")
			if roots.size() == 1:
				check(not roots[0].find_children("*","MeshInstance3D",true,false).is_empty(),id+" contains rendered meshes")
				if render_review:
					await get_tree().create_timer(.85).timeout
					await RenderingServer.frame_post_draw
					get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top dog 2/common-effects-review/integration/"+id+"-match.png")
				roots[0].queue_free()
		main.game.end_match()
		await get_tree().process_frame
		print("COMMON_MATCH_CHECK ",id)
	Wardrobe.profiles = original
	Wardrobe.selected = selected
	if existed:
		var file := FileAccess.open(path,FileAccess.WRITE)
		file.store_buffer(backup)
		file.close()
	else: DirAccess.remove_absolute(path)
	main.queue_free()
	await get_tree().process_frame
	print("COMMON_MATCH_RESULT ",JSON.stringify({"effects":IDS.size(),"errors":failures}))
	get_tree().quit(0 if failures.is_empty() else 1)
