extends Node
const P=preload("res://core/player_progression.gd")
var fails:=0
func check(ok: bool, message: String) -> void:
	if not ok:fails+=1;push_error(message)
func _ready() -> void:
	get_tree().create_timer(25).timeout.connect(func():push_error("TALLY TIMEOUT");get_tree().quit(1))
	var main=load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(2).timeout
	main.lucha.title_attract=false
	main.show_screen("title")
	var payout={"match_id":"test-tally","before_total":9750,"after_total":14750,"awarded":5000,"total":5000,"saved":true,"eligible":true,
		"rows":{"MATCH COMPLETE":2500,"VICTORY":0,"LOCK-INS":200,"FIRST LOCK-IN":200,"STUCK THE LANDING":2000,"UPWARD AIRTIME":100}}
	main.game.results={"winner":-1,"best":{},"tower":3,"top":5.0,"local_xp":payout}
	var panel=main.lucha.menus.results.xp_panel
	var levels:Array=[];var categories:Array=[]
	panel.belt.level_celebrated.connect(func(level):levels.append(level))
	panel.category_started.connect(func(title):categories.append(title))
	main.show_screen("results")
	check(panel.belt._shown_total==9750,"starts at pre-match saved progress")
	await get_tree().create_timer(1.2).timeout
	var effects = panel.belt.get_children().filter(func(child): return child.has_meta("xp_sparks"))
	check(effects.size() == 2, "one simultaneous firework group at each results-panel rim")
	for effect in effects:
		check(effect.simultaneous and effect.bursts.size() == 3, "three colors per edge")
		for burst in effect.bursts:
			check(float(burst.delay) == 0.0, "all firework colors launch together")
	main.lucha.xp_display.celebrate(2)
	check(not main.lucha.xp_display.get_children().any(func(child): return child.has_meta("xp_sparks")), "title XP display never creates fireworks")
	check(panel.belt._shown_total>9750 and panel.belt._shown_total<12250,"bar receives XP during category countdown")
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("xp-finish-tally.png"))
	await panel.tally_finished
	check(panel.belt._shown_total==14750 and panel.belt.level_text.text=="2","exact final total across level boundary")
	check(categories==["MATCH COMPLETE","LOCK-INS","FIRST LOCK-IN","STUCK THE LANDING","UPWARD AIRTIME"],"categories sequential, zero rows skipped")
	check(levels==[2],"one celebration per level crossed")
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("xp-finish-complete.png"))
	panel.show_payout(payout)
	check(panel.tally_complete,"same result does not replay")
	var next=payout.duplicate(true);next.match_id="skip";next.before_total=14750;next.after_total=19750
	panel.show_payout(next)
	main.show_screen("title")
	check(panel.tally_complete and panel.belt._shown_total==19750,"leaving early settles entire payout")
	check(not panel._feed_stars.any(func(n):return n.visible),"feed stars cleaned on hide")
	# Failed saves must not animate or claim progress.
	main.show_screen("results")
	var failed=next.duplicate(true);failed.match_id="failed";failed.saved=false;failed.awarded=0;failed.after_total=14750
	panel.show_payout(failed)
	check(panel.tally_complete and panel.belt._shown_total==14750 and panel.row_name.text=="XP SAVE FAILED","failed save preserved")
	var capped=payout.duplicate(true);capped.match_id="cap";capped.before_total=P.MAX_TOTAL-50;capped.after_total=P.MAX_TOTAL;capped.awarded=50;capped.total=500;capped.rows={"MATCH COMPLETE":500}
	panel.show_payout(capped)
	await panel.tally_finished
	check(panel.belt._shown_total==P.MAX_TOTAL and panel.belt.amount_text.text=="MAX LEVEL","cap never overflows")
	print("RESULTS BELT TALLY fails=",fails)
	get_tree().quit(fails)
