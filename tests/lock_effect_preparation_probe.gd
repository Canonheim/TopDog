extends SceneTree
var Prep: Script
class Host extends Node:
	var screen := "title"
	var cam: Camera3D
var failures: Array[String] = []
func _initialize() -> void:
	call_deferred("probe")
func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func probe() -> void:
	Prep = load("res://ui3d/lock_effect_preparation.gd")
	var host := Host.new()
	root.add_child(host)
	host.cam = Camera3D.new()
	host.add_child(host.cam)
	# Before any background preparation: immediate request remains a real burst.
	var start := Time.get_ticks_usec()
	var early: Node3D = Prep.burst("bills",host.cam)
	var early_cpu_ms := (Time.get_ticks_usec()-start)/1000.0
	check(is_instance_valid(early) and early.get_child_count() == 72,"Early request dropped or changed quota")
	check(Prep.cold_requests.get("bills",0) == 1,"Cold fallback not reported")
	# Threaded request + live synchronous fallback target the same model cache.
	var script = Prep.effect_script("luck")
	var key: String = script.TYPES[0]
	var path := "res://kit/models/luck_"+key+".glb"
	Prep.prepare_scene(script,key,path)
	var concurrent: Node3D = Prep.burst("luck",host.cam)
	check(concurrent.get_child_count() == 72,"Concurrent load dropped a live effect")
	var done := false
	for _frame in 120:
		done = Prep.prepare_scene(script,key,path)
		if done: break
		await process_frame
	check(done and not Prep.pending.has(path),"Concurrent load did not drain")
	var saved: PackedScene = script.scenes[key]
	Prep.prepare_scene(script,key,path)
	check(script.scenes[key] == saved,"Preparation replaced an already shared model")
	# A missing resource reports once, is removed from pending, and stays terminal.
	var missing := "res://kit/models/__missing_effect_probe__.glb"
	var failures_before: int = Prep.failed_paths.size()
	for _retry in 4: Prep.prepare_scene(script,"__missing",missing)
	check(Prep.failed_paths.size() == failures_before+1,"Missing load not terminal")
	check(not Prep.pending.has(missing),"Missing load left a pending request")
	# Invalid/stale threaded handle also transitions to terminal failure.
	var invalid := "res://kit/models/__invalid_thread_probe__.glb"
	Prep.pending[invalid] = Time.get_ticks_msec()
	Prep.prepare_scene(script,"__invalid",invalid)
	check(Prep.failed_paths.has(invalid) and not Prep.pending.has(invalid),"Failed thread remained pending")
	await create_timer(4.1).timeout
	await process_frame
	check(host.cam.get_child_count() == 0,"Early/concurrent effects failed cleanup")
	var scheduler: Node = Prep.new()
	host.add_child(scheduler)
	scheduler.set_process(false)
	# A failed large effect cannot prevent round-robin preparation of other entries.
	Prep.failed_effects["underwear"] = "injected probe failure"
	for _frame in 32:
		scheduler._process(1.0/60)
		await process_frame
	check(int(Prep.progress.get("confetti",0)) > 0,"Scheduler failed to progress")
	check(int(Prep.progress.get("math",0)) > 0,"Failed effect starved later effects")
	Prep.failed_effects.erase("underwear")
	var before: Dictionary = Prep.progress.duplicate(true)
	host.screen = "hud"
	scheduler._process(1.0/60)
	check(Prep.progress == before,"Preparation ran during gameplay")
	print("LOCK_EFFECT_PREPARATION_PROBE ",JSON.stringify({"early_bills_cpu_ms":early_cpu_ms,"short_menu_progress":Prep.progress,"errors":failures}))
	host.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
