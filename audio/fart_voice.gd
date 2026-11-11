extends Node3D

const COUNT := 7
const CAPACITY := 10.0
var _cutoff: Tween
var _bag: Array[int] = []
var _take := 0
var _body: AudioStreamPlayer3D
var _tail: AudioStreamWAV


func _init() -> void:
	name = "FartVoice"


func active() -> bool:
	return is_instance_valid(_body)


func next_take() -> int:
	if _bag.is_empty():
		_bag.assign(range(1, COUNT + 1))
		_bag.shuffle()
		if _bag.back() == _take:
			_bag.push_front(_bag.pop_back())
	return _bag.pop_back()


static var _clips := {}


func start(take: int, pitch: float, budget: float = CAPACITY) -> void:
	if active():
		return
	_take = take
	var path := "res://audio/sfx/farts/fart_%02d_" % take
	if not _clips.has(path):
		_clips[path] = [load(path + "body.wav"), load(path + "tail.wav")]  # loaded once (was two disk reads a fart, on every listener)
	var loop: AudioStreamWAV = _clips[path][0]
	_tail = _clips[path][1]
	_body = Sound.contact_player(loop, pitch, self)
	_body.play()
	# Schedule the cutoff on each listener so packet latency cannot extend a hold.
	var fade_time := minf(0.045, budget)
	_cutoff = _body.create_tween().set_ignore_time_scale(true)
	_cutoff.tween_interval(budget - fade_time)
	_cutoff.tween_property(_body, "volume_linear", 0.0, fade_time)
	_cutoff.tween_callback(_finish_empty)


func _finish_empty() -> void:
	_body.stop()
	_body.queue_free()
	_body = null
	_cutoff = null


func release() -> void:
	if not active():
		return
	_cutoff.kill()
	_cutoff = null
	var body := _body
	_body = null
	var ending := Sound.contact_player(_tail, body.pitch_scale, self)
	ending.finished.connect(ending.queue_free)
	ending.play()
	var fade := body.create_tween()
	fade.tween_property(body, "volume_linear", 0.0, 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fade.tween_callback(body.queue_free)
