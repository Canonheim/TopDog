extends Node
const Effect = preload("res://ui3d/lightning_effect.gd")
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
var failures := 0
func check(ok: bool,label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)
func _ready() -> void:
	var output := ""
	var skin := 0
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output=arg.trim_prefix("--output=")
		if arg.begins_with("--skin="): skin=int(arg.trim_prefix("--skin="))
	var original := Wardrobe.profiles.duplicate(true)
	var selected := Wardrobe.selected
	var path: String = Wardrobe.SavePaths.settings("climbers.cfg")
	var existed := FileAccess.file_exists(path)
	var backup := FileAccess.get_file_as_bytes(path) if existed else PackedByteArray()
	Wardrobe.profiles[selected].effect = "lightning"
	Wardrobe.profiles[selected].head = skin
	check(Wardrobe.save(),"Selection saved")
	Wardrobe.load_profiles()
	check(Wardrobe.for_slot(0).effect=="lightning","Selection reload")
	check(Net._clean_players([{"name":"Lightning","slot":0,"appearance":Wardrobe.for_slot(0)}])[0].appearance.effect=="lightning","Network appearance retains selection")
	var main = load("res://game/main.tscn").instantiate()
	add_child(main)
	main.show_screen("customize")
	check("Lightning" in main.screens.customize.menu.items[4].options,"Menu option")
	while not Prep.is_prepared("lightning"):
		await get_tree().process_frame
	main.lucha.play_lock_effect("lightning")
	check(main.screens.customize.preview.has_node("LightningStrike"),"Menu preview attaches transient")
	await get_tree().create_timer(Effect.TOTAL_SECONDS+.25).timeout
	main._start_practice()
	await get_tree().create_timer(1).timeout
	var climber: Climber = main.game.live_climbers()[0]
	check(Effect.attach(climber,main.cam)==null,"No strikes before successful freeze")
	if output!="":
		DirAccess.make_dir_recursive_absolute(output)
		main.set_process(false)
		var centre: Vector2 = climber.centre_of_mass()
		var focus := Vector3(centre.x,centre.y+.4,0)
		main.cam.global_position=focus+Vector3(0,0,5.6)
		main.cam.look_at(focus,Vector3.UP)
	var body_count: int = climber.bodies.size()
	main.game._rpc_freeze(climber.climber_id,climber.pose(),"made","locked",climber.top_height(),main.game.line,true)
	var effect = climber.get_node_or_null("LightningStrike")
	check(effect!=null,"Actual match handler attaches lightning")
	check(climber.bodies.size()==body_count,"No gameplay bodies changed")
	if effect!=null:
		check(effect.impact.is_equal_approx(Effect.highest_surface(climber).world),"Match highest skin endpoint")
		check(Prep.attach("lightning",climber,main.cam)==null,"Duplicate event ignored")
	var maximum_strikes := 0
	var timeline := []
	var onsets := 0
	var previous_visible := -1
	var frame := 0
	# Cover the entire cloud formation, three strikes and weather fade at 60 fps.
	# Faster rendering also continues until cleanup, with a bounded failure exit.
	while frame<600 and (frame<120 or is_instance_valid(effect)):
		await get_tree().process_frame
		var active := -1
		var active_count := 0
		var effect_age := -1.0
		if is_instance_valid(effect):
			maximum_strikes=maxi(maximum_strikes,effect.strikes_started)
			effect_age=effect.age
			for i in 3:
				if effect.bolts[i].visible:
					active=i
					active_count+=1
		if is_instance_valid(effect):
			for index in 3:
				var elapsed: float = effect.age-Effect.STRIKE_START-index*Effect.STAGGER
				check(effect.bolts[index].visible==(elapsed>=0 and elapsed<Effect.FLASH_SECONDS),"Correct subtly staggered visibility")
		if active>=0 and active!=previous_visible: onsets+=1
		previous_visible=active
		timeline.append({"frame":frame,"age":effect_age,"visible_bolt":active})
		if output!="":
			await RenderingServer.frame_post_draw
			var image := get_viewport().get_texture().get_image()
			image.resize(960,540,Image.INTERPOLATE_LANCZOS)
			image.save_png(output+"/%03d.png" % frame)
		else: await get_tree().create_timer(.025).timeout
		frame += 1
	check(onsets==3,"Three subtly staggered bolt onsets")
	if output!="":
		var timeline_file := FileAccess.open(output+"/timeline.json",FileAccess.WRITE)
		timeline_file.store_string(JSON.stringify(timeline,"  "))
		timeline_file.close()
	check(maximum_strikes==3,"Exactly three distinct strikes executed")
	check(not is_instance_valid(effect),"Transient root fully cleaned")
	check(Prep.attach("lightning",climber,main.cam)==null,"Duplicate after cleanup cannot replay")
	check(Prep.attach("lightning",climber,main.cam,false)==null,"Snapshot restore skips transient")
	main.game.end_match()
	Wardrobe.profiles=original
	Wardrobe.selected=selected
	if existed:
		var file := FileAccess.open(path,FileAccess.WRITE)
		file.store_buffer(backup)
		file.close()
	else: DirAccess.remove_absolute(path)
	print("LIGHTNING_MATCH ",JSON.stringify({"failures":failures,"strikes":maximum_strikes,"skin":skin}))
	if DisplayServer.get_name()=="headless": get_tree().quit(failures)
	else: await main.quit_game()

