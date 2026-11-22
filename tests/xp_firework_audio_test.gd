extends Node
var fails := 0
var pops := 0
var launches := 0
func check(label: String, ok: bool) -> void:
	print(("PASS " if ok else "FAIL ")+label)
	if not ok: fails += 1
func _ready() -> void:
	var audio = load("res://ui3d/xp_firework_audio.gd").new()
	add_child(audio)
	var seen := {}
	for i in 10:
		var clip: AudioStream = audio.take_clip()
		if clip != null: seen[clip.resource_path] = true
	check("ten distinct approved sounds before exhaustion", seen.size() == 10)
	check("extra fireworks cannot repeat a used sound", audio.take_clip() == null)
	audio.reset()
	check("new presentation restores all ten", audio.remaining.size() == 10)
	audio.play_launch(.1)
	check("launch does not consume unique pops", audio.remaining.size() == 10 and audio.voices[0].stream == audio.LAUNCH)
	audio.reset()
	audio.play_launch(.4)
	check("late frames cannot play hiss after explosion", audio.voices.is_empty())
	audio.play_burst()
	check("firework uses Effects bus and authored pitch", audio.voices.size() == 1 and audio.voices[0].playing and audio.voices[0].bus == "Effects" and audio.voices[0].pitch_scale == 1)
	audio.reset()
	check("reset stops remaining audio", audio.voices.is_empty())
	var effect = load("res://ui3d/xp_fireworks.gd").new()
	add_child(effect)
	effect.set_process(false)
	effect.popped.connect(func(): pops += 1)
	effect.launched.connect(func(_offset: float): launches += 1)
	effect._process(.37)
	check("ascent launches hiss without explosion sound", pops == 0 and launches == 2)
	effect._process(.02)
	check("first explosion emits one pop", pops == 1)
	effect._process(.01)
	check("no duplicate pop or launch next frame", pops == 1 and launches == 2)
	effect._process(.5)
	check("each of three fireworks emits exactly once", pops == 3)
	effect.queue_free()
	audio.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	print("RESULT fails=", fails)
	get_tree().quit(fails)
