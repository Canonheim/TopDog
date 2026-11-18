extends Node
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
var errors: Array[String] = []
func check(ok: bool, label: String) -> void:
	if not ok:
		errors.append(label)
		push_error(label)
func prepare(id: String) -> void:
	var started := Time.get_ticks_msec()
	while not Prep.is_prepared(id) and Time.get_ticks_msec()-started<15000:
		Prep.prepare_step(id)
		await get_tree().process_frame
	check(Prep.is_prepared(id),id+" prepared")
func _ready() -> void:
	var save_path: String = Wardrobe.SavePaths.settings("climbers.cfg")
	var existed := FileAccess.file_exists(save_path)
	var saved := FileAccess.get_file_as_bytes(save_path) if existed else PackedByteArray()
	var original: Array = Wardrobe.profiles.duplicate(true)
	var selected: int = Wardrobe.selected
	check(not "cherry_bomb" in Wardrobe.EFFECTS,"retired from choices")
	check(not Prep.REGISTRY.has("cherry_bomb") and not Prep.SCRIPTS.has("cherry_bomb"),"retired from preparation")
	check(Prep.validation_errors().is_empty(),"registry matches choices")
	check(Wardrobe.clean({"effect":"cherry_bomb"}).effect == "ice_cream_social","old effect migrates")
	check(Wardrobe.clean({"effect":"unknown"}).effect == "confetti","invalid effect fallback unchanged")
	var net_players: Array = Net._clean_players([{"name":"Test","slot":0,"appearance":{"effect":"cherry_bomb"}}])
	check(net_players[0].appearance.effect == "ice_cream_social","network migration")
	Wardrobe.profiles[Wardrobe.selected].effect = "cherry_bomb"
	Wardrobe.save()
	Wardrobe.load_profiles()
	check(Wardrobe.for_slot(0).effect == "ice_cream_social","saved profile migration")
	var main = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().create_timer(.6).timeout
	for child in main.get_children():
		if child.get_script() == Prep: child.set_process(false)
	main.show_screen("customize")
	var editor = main.screens.customize
	await prepare("popcorn")
	editor._set_choice("effect","popcorn")
	check(editor.menu.items[4].kind == "choice_button","effect is replayable choice")
	check(editor.menu.items[4].on_change.is_valid(),"arrows retain change callback")
	var profiles: Array = []
	for trial in 4:
		var before: Array = main.cam.get_children()
		editor.menu.focus = 4
		editor.menu._activate(4)
		check(Wardrobe.for_slot(0).effect == "popcorn","activation keeps selected effect")
		var roots: Array = main.cam.get_children().filter(func(n): return n not in before and n is Node3D)
		check(roots.size()==1,"activation emits new root")
		if roots.size()==1:
			var p = roots[0].get_child(0)
			profiles.append(str([p.position,p.rotation,p.velocity,p.scale]))
	check(profiles.size()==4,"four fresh bursts")
	for i in profiles.size():
		for j in range(i): check(profiles[i]!=profiles[j],"randomized replay trajectories")
	# Isolate the visual burst from Sound.play (which owns its existing pitch RNG).
	seed(4721)
	var expected := randi()
	seed(4721)
	Prep.burst("popcorn",main.cam)
	check(randi()==expected,"direct cosmetic burst preserves gameplay RNG")
	editor.menu.focus = 4
	editor.menu._cycle(1)
	check(Wardrobe.for_slot(0).effect == "fries","right arrow selects next effect")
	Wardrobe.load_profiles()
	check(Wardrobe.for_slot(0).effect == "fries","arrow selection saves")
	editor.menu._cycle(-1)
	check(Wardrobe.for_slot(0).effect == "popcorn","left arrow selects previous effect")
	for id in ["railroad_spikes","lightning"]:
		await prepare(id)
		editor._set_choice("effect",id)
		var first_model: Node3D = editor.preview
		var first = first_model.get_node("RailroadSpikes" if id=="railroad_spikes" else "LightningStrike")
		var signature: String = str(first.burst_profile) if id=="railroad_spikes" else str(first.get_child(0).basis)
		editor.menu.focus = 4
		editor.menu._activate(4)
		check(not is_instance_valid(first_model),id+" replay replaces preview owner")
		var second = editor.preview.get_node("RailroadSpikes" if id=="railroad_spikes" else "LightningStrike")
		var next_signature: String = str(second.burst_profile) if id=="railroad_spikes" else str(second.get_child(0).basis)
		check(signature != next_signature,id+" replay fresh random flight")
		check(Wardrobe.for_slot(0).effect==id,id+" replay keeps selection")
	await get_tree().create_timer(3.6).timeout
	check(main.cam.get_children().filter(func(n): return n.has_meta("burst_profile")).is_empty(),"timed preview bursts clean up")
	Wardrobe.profiles = original
	Wardrobe.selected = selected
	if existed:
		var file := FileAccess.open(save_path,FileAccess.WRITE)
		file.store_buffer(saved)
		file.close()
	else: DirAccess.remove_absolute(save_path)
	print("EFFECT_PREVIEW_REPLAY_RESULT ",JSON.stringify({"errors":errors,"replays":4,"attached_effects":2,"available_effects":Wardrobe.EFFECTS.size()}))
	get_tree().quit(0 if errors.is_empty() else 1)
