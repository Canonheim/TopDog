extends RefCounted
## THE POSE ON THE WIRE (the code review, 11-23: a pose went out as 48 floats, 200 bytes, to every
## peer at up to 30 Hz). Packed to 100 bytes: the pelvis as two floats, the other pieces as 16-bit
## offsets from it (1/8000 m steps, +-4.09 m: a whole body is within 3 m of its pelvis, see
## Game.POSE_BODY_SPAN), every angle as a 16-bit share of a half turn. Errors: an eighth of a
## millimetre, a 180th of a degree.

const Layout := preload("res://climber/body_layout.gd")
const STEP := 1.0 / 8000.0
const PIECES := 16
const SIZE := 8 + (PIECES - 1) * 4 + PIECES * 2


static func pack(pose: PackedFloat32Array) -> PackedByteArray:
	var out := PackedByteArray()
	if pose.size() != PIECES * 3:
		return out
	out.resize(SIZE)
	var p := Layout.ORDER.find("pelvis") * 3
	var px := pose[p]
	var py := pose[p + 1]
	out.encode_float(0, px)
	out.encode_float(4, py)
	var at := 8
	for i in range(0, pose.size(), 3):
		if i == p:
			continue
		out.encode_s16(at, clampi(roundi((pose[i] - px) / STEP), -32767, 32767))
		out.encode_s16(at + 2, clampi(roundi((pose[i + 1] - py) / STEP), -32767, 32767))
		at += 4
	for i in range(0, pose.size(), 3):
		out.encode_s16(at, clampi(roundi(wrapf(pose[i + 2], -PI, PI) / PI * 32767.0), -32767, 32767))
		at += 2
	return out


## An empty array if `data` isn't a packed pose.
static func unpack(data: PackedByteArray) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	if data.size() != SIZE:
		return out
	out.resize(PIECES * 3)
	var p := Layout.ORDER.find("pelvis") * 3
	var px := data.decode_float(0)
	var py := data.decode_float(4)
	if not is_finite(px) or not is_finite(py):
		return PackedFloat32Array()
	out[p] = px
	out[p + 1] = py
	var at := 8
	for i in range(0, out.size(), 3):
		if i == p:
			continue
		out[i] = px + data.decode_s16(at) * STEP
		out[i + 1] = py + data.decode_s16(at + 2) * STEP
		at += 4
	for i in range(0, out.size(), 3):
		out[i + 2] = data.decode_s16(at) / 32767.0 * PI
		at += 2
	return out
