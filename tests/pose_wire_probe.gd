extends Node
## POSE WIRE PROBE (the code review, 11-23): a pose packed for the wire (net/pose_wire.gd) comes back
## within an eighth of a millimetre and a 180th of a degree, is 100 bytes, and garbage is refused.
const PoseWire := preload("res://net/pose_wire.gd")
var fails := 0


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var worst_p := 0.0
	var worst_a := 0.0
	for n in 200:
		var pose := PackedFloat32Array()
		var base := Vector2(rng.randf_range(-60, 60), rng.randf_range(-5, 120))
		for i in 16:
			pose.append(base.x + rng.randf_range(-2.9, 2.9))
			pose.append(base.y + rng.randf_range(-2.9, 2.9))
			pose.append(rng.randf_range(-PI, PI))
		var k := preload("res://climber/body_layout.gd").ORDER.find("pelvis") * 3
		pose[k] = base.x
		pose[k + 1] = base.y
		var data := PoseWire.pack(pose)
		if data.size() != 100:
			_fail("packed size %d" % data.size())
		var back := PoseWire.unpack(data)
		for i in range(0, 48, 3):
			worst_p = maxf(worst_p, maxf(absf(back[i] - pose[i]), absf(back[i + 1] - pose[i + 1])))
			worst_a = maxf(worst_a, absf(wrapf(back[i + 2] - pose[i + 2], -PI, PI)))
	print("worst position error %.6f m, worst angle error %.5f deg" % [worst_p, rad_to_deg(worst_a)])
	if worst_p > 0.0002:
		_fail("position error")
	if rad_to_deg(worst_a) > 0.01:
		_fail("angle error")
	if not PoseWire.unpack(PackedByteArray([1, 2, 3])).is_empty():
		_fail("a short packet was accepted")
	var bad := PackedByteArray()
	bad.resize(100)
	bad.encode_float(0, NAN)
	if not PoseWire.unpack(bad).is_empty():
		_fail("a NaN pelvis was accepted")
	print("RESULT fails=", fails)
	get_tree().quit(fails)


func _fail(what: String) -> void:
	fails += 1
	print("FAIL ", what)
