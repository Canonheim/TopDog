extends Node3D

const COUNT := 7
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


func start(take: int, pitch: float) -> void:
	if active():
		return
	_take = take
	var path := "res://audio/sfx/farts/fart_%02d_" % take
	var loop: AudioStreamWAV = load(path + "body.wav")
	_tail = load(path + "tail.wav")
	_body = Sound.contact_player(loop, pitch, self)
	_body.play()


func release() -> void:
	if not active():
		return
	var body := _body
	_body = null
	var ending := Sound.contact_player(_tail, body.pitch_scale, self)
	ending.finished.connect(ending.queue_free)
	ending.play()
	var fade := body.create_tween()
	fade.tween_property(body, "volume_linear", 0.0, 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fade.tween_callback(body.queue_free)
