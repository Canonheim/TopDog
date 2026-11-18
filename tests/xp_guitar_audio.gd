extends Node
var fails := 0
func check(label: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ") + label)
	if not ok: fails += 1
func _ready() -> void:
	var summary = load("res://ui3d/xp_match_summary.gd").new()
	add_child(summary)
	for category in 3:
		summary._begin_category("CATEGORY", 10, true)
		check("category introduction is silent", summary._xp_voices.is_empty())
		summary._feed(0.0, category*10, category*10+10, 10)
		check("first tick starts on departure", summary._xp_voices.size() == 1 and summary._xp_voices[0].stream == summary.XP_TICK)
		summary._feed(0.0, category*10, category*10+10, 10)
		check("same frame does not duplicate tick", summary._xp_voices.size() == 1)
		summary._feed(1.0, category*10, category*10+10, 10)
		check("sixteen launches, no premature finish", summary._xp_voices.size() == 16 and summary._xp_voices.all(func(v): return v.stream == summary.XP_TICK))
		summary._end_category(10)
		check("every cluster gets completion tick", summary._xp_voices.size() == 17 and summary._xp_voices[16].stream == summary.XP_FINISH)
		summary._end_category(0)
		check("completion cannot duplicate", summary._xp_voices.size() == 17)
		check("30 percent boost retained", summary._xp_voices.all(func(v): return is_equal_approx(db_to_linear(v.volume_db), 1.3)))
		summary._stop_xp_audio()
	summary._begin_category("CAPPED", 10, false)
	summary._feed(1.0, 30, 30, 10)
	summary._end_category(10)
	check("no ticks for no transfer", summary._xp_voices.is_empty())
	summary._begin_category("HIDE", 10, true)
	summary._feed(0.0, 30, 40, 10)
	summary.hide()
	check("leaving stops audio", summary._xp_voices.is_empty())
	summary.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	print("RESULT fails=", fails)
	get_tree().quit(fails)
