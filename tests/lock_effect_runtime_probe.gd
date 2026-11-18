extends Node
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
func _ready() -> void:
	var output := "user://effect-runtime-report.json"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
	var main: Node = preload("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().process_frame
	var start := Time.get_ticks_msec()
	var ready := false
	while Time.get_ticks_msec()-start < 30000:
		ready = true
		for id in Prep.REGISTRY:
			if not Prep.is_prepared(id): ready = false
		if ready: break
		await get_tree().process_frame
	var report := {"all_prepared":ready,"elapsed_ms":Time.get_ticks_msec()-start,"max_frame_cpu_ms":Prep.max_frame_cpu_ms,"max_step_cpu_ms":Prep.step_max_ms,"failed":Prep.failed_effects,"cold_requests":Prep.cold_requests}
	print("RENDERED_PREPARATION_REPORT ",JSON.stringify(report))
	var file := FileAccess.open(output,FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	file.close()
	await main.quit_game()
