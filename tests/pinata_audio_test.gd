extends Node3D
var fails := 0
func check(label: String, ok: bool) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: fails += 1
func _ready() -> void:
 var pinata = load("res://game/cosmetic_pinata.gd").new()
 pinata.contact_enabled = false
 add_child(pinata)
 pinata.position = Vector3(2,3,0)
 check("unbroken pinata is silent", pinata.burst_root == null)
 pinata.collect()
 var root = pinata.burst_root
 var voice = root.get_node_or_null("PinataBreakSound")
 check("sound begins with collection burst", pinata.taken and not pinata.visual.visible and voice != null and voice.playing)
 check("approved combined four-note clip at original pitch", voice.stream == pinata.BREAK_SOUND and voice.pitch_scale == 1.0 and voice.bus == "Effects")
 check("sound comes from pinata position", voice.global_position.is_equal_approx(pinata.global_position))
 pinata.collect()
 check("repeated collection cannot duplicate playback", pinata.burst_root == root and root.get_node("PinataBreakSound") == voice)
 await get_tree().create_timer(1.3).timeout
 check("whole cue finishes before burst cleanup", not is_instance_valid(voice))
 await get_tree().create_timer(.9).timeout
 check("burst cleans up normally", not is_instance_valid(root))
 print("RESULT fails=", fails)
 get_tree().quit(fails)
