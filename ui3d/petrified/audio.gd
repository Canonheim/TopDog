extends RefCounted
const ENCASING = [
 preload("res://audio/sfx/stone_encasing_01.wav"),
 preload("res://audio/sfx/stone_encasing_02.wav"),
 preload("res://audio/sfx/stone_encasing_03.wav"),
]
const CRUMBLE = [
 preload("res://audio/sfx/stone_crumble_01.wav"),
 preload("res://audio/sfx/stone_crumble_02.wav"),
 preload("res://audio/sfx/stone_crumble_03.wav"),
 preload("res://audio/sfx/stone_crumble_04.wav"),
 preload("res://audio/sfx/stone_crumble_05.wav"),
 preload("res://audio/sfx/stone_crumble_06.wav"),
 preload("res://audio/sfx/stone_crumble_07.wav"),
 preload("res://audio/sfx/stone_crumble_08.wav"),
 preload("res://audio/sfx/stone_crumble_09.wav"),
 preload("res://audio/sfx/stone_crumble_10.wav"),
]
static func play(parent: Node3D, point: Vector3, encasing: bool) -> AudioStreamPlayer3D:
 var clips: Array = ENCASING if encasing else CRUMBLE
 var voice := AudioStreamPlayer3D.new()
 voice.name = "StoneEncasingSound" if encasing else "StoneCrumbleSound"
 # Uniform independent selection: 1/3 encasing, 1/10 crumble.
 voice.stream = clips[randi_range(0, clips.size()-1)]
 voice.pitch_scale = 1.15 if encasing else 1.0
 voice.bus = "Effects"
 voice.unit_size = 6.0
 parent.add_child(voice)
 voice.global_position = point
 voice.finished.connect(voice.queue_free)
 voice.play()
 return voice
