extends Node3D
const Loader=preload("res://game/match_effect_preloader.gd")
func _ready() -> void:
 var job:=Loader.new();add_child(job)
 var roster: Array=[]
 var ids: Array=["pickles","spiders","absolute_zero","gold","lightning","watermelon","vines","pancakes"]
 ids=preload("res://ui3d/lock_effect_preparation.gd").REGISTRY.keys()
 for id in ids:roster.append({"appearance":{"effect":id}})
 job.start(roster,false)
 var report: Dictionary=await job.completed
 print("MATCH_PRELOAD_REPORT ",JSON.stringify(report))
 var f:=FileAccess.open("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/match-preload/preload-report.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close()
 assert(report.errors.is_empty())
 job.queue_free();await get_tree().process_frame;get_tree().quit()
