extends Node
## One shared non-repeating pool for the entire results presentation.
const LAUNCH := preload("res://audio/sfx/xp_firework_launch.wav")
const CLIPS := [
	preload("res://audio/sfx/xp_firework_01.wav"),
	preload("res://audio/sfx/xp_firework_02.wav"),
	preload("res://audio/sfx/xp_firework_03.wav"),
	preload("res://audio/sfx/xp_firework_04.wav"),
	preload("res://audio/sfx/xp_firework_05.wav"),
	preload("res://audio/sfx/xp_firework_06.wav"),
	preload("res://audio/sfx/xp_firework_07.wav"),
	preload("res://audio/sfx/xp_firework_08.wav"),
	preload("res://audio/sfx/xp_firework_09.wav"),
	preload("res://audio/sfx/xp_firework_10.wav")
]
var remaining: Array = []
var voices: Array[AudioStreamPlayer] = []
func _ready() -> void:
	reset()
func reset() -> void:
	for voice in voices:
		if is_instance_valid(voice):
			voice.stop()
			voice.queue_free()
	voices.clear()
	remaining = CLIPS.duplicate()
	remaining.shuffle()
func take_clip() -> AudioStream:
	# Do not refill during a presentation: a used pop cannot recur.
	return null if remaining.is_empty() else remaining.pop_back()
func play_burst() -> void:
	var clip := take_clip()
	if clip == null: return
	_play(clip)
func play_launch(offset := 0.0) -> void:
	if offset >= 0.0 and offset < .38:
		_play(LAUNCH, offset)
func _play(clip: AudioStream, offset := 0.0) -> void:
	var voice := AudioStreamPlayer.new()
	voice.bus = "Effects"
	voice.stream = clip
	add_child(voice)
	voices.append(voice)
	voice.finished.connect(func():
		voices.erase(voice)
		voice.queue_free())
	voice.play(offset)
