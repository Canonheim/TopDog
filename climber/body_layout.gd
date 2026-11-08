extends RefCounted
## THE BODY LAYOUT: the climber's 16 pieces and 15 joints, measured from the Metal
## Knight's 16 Defaultio pieces (models/metal_knight.glb, T-pose, metres).
##
## Coordinates here are SCREEN-SIDE, y-up metres at body_scale 1.0: the knight
## faces the camera, so its own right arm (mesh "Hand", model +x) is on the
## SCREEN-LEFT, x < 0. Every name below is the screen side: arm_l is the one the
## player sees on the left. Joint limits are degrees, counter-clockwise positive,
## of the child relative to the parent, measured from the T-pose.

## Piece: mesh name in the glb, shape, mass (kg). Shapes:
##   ["circle", centre, r] / ["capsule", a, b, r] / ["box", centre, half_extents]
const PIECES := {
	"head": {"mesh": "Head", "shape": ["circle", Vector2(0.0, 1.86), 0.135], "mass": 3.0},
	"chest": {"mesh": "Chest", "shape": ["box", Vector2(0.0, 1.59), Vector2(0.20, 0.20)], "mass": 3.5},
	"navel": {"mesh": "Navel", "shape": ["box", Vector2(0.0, 1.30), Vector2(0.16, 0.095)], "mass": 2.0},
	"pelvis": {"mesh": "Pelvis", "shape": ["box", Vector2(0.0, 1.085), Vector2(0.22, 0.115)], "mass": 2.5},

	"arm_l_up": {"mesh": "Shoulder", "shape": ["capsule", Vector2(-0.25, 1.582), Vector2(-0.60, 1.582), 0.075], "mass": 2.0},
	"arm_l_lo": {"mesh": "Wrist", "shape": ["capsule", Vector2(-0.64, 1.582), Vector2(-0.90, 1.582), 0.07], "mass": 1.4},
	"hand_l": {"mesh": "Hand", "shape": ["circle", Vector2(-0.997, 1.592), 0.068], "mass": 0.6},
	"arm_r_up": {"mesh": "L_Shoulder", "shape": ["capsule", Vector2(0.25, 1.582), Vector2(0.60, 1.582), 0.075], "mass": 2.0},
	"arm_r_lo": {"mesh": "L_Wrist", "shape": ["capsule", Vector2(0.64, 1.582), Vector2(0.90, 1.582), 0.07], "mass": 1.4},
	"hand_r": {"mesh": "L_Hand", "shape": ["circle", Vector2(0.997, 1.592), 0.068], "mass": 0.6},

	"leg_l_up": {"mesh": "Thigh", "shape": ["capsule", Vector2(-0.093, 0.99), Vector2(-0.093, 0.62), 0.08], "mass": 2.8},
	"leg_l_lo": {"mesh": "Shin", "shape": ["capsule", Vector2(-0.09, 0.56), Vector2(-0.09, 0.19), 0.075], "mass": 2.0},
	"foot_l": {"mesh": "Foot", "shape": ["box", Vector2(-0.09, 0.075), Vector2(0.072, 0.072)], "mass": 0.8},
	"leg_r_up": {"mesh": "L_Thigh", "shape": ["capsule", Vector2(0.093, 0.99), Vector2(0.093, 0.62), 0.08], "mass": 2.8},
	"leg_r_lo": {"mesh": "L_Shin", "shape": ["capsule", Vector2(0.09, 0.56), Vector2(0.09, 0.19), 0.075], "mass": 2.0},
	"foot_r": {"mesh": "L_Foot", "shape": ["box", Vector2(0.09, 0.075), Vector2(0.072, 0.072)], "mass": 0.8},
}

## Joint: parent, child, anchor, [lower, upper] degrees, kind.
## kind: "spine" (passive torso flex), "neck", "root" / "mid" (driven limb joints),
## "end" (wrist / ankle springs).
const JOINTS := {
	"neck": {"a": "chest", "b": "head", "at": Vector2(0.0, 1.70), "lim": [-35.0, 35.0], "kind": "neck"},
	"spine_hi": {"a": "chest", "b": "navel", "at": Vector2(0.0, 1.3741), "lim": [-12.0, 12.0], "kind": "spine"},
	"spine_lo": {"a": "navel", "b": "pelvis", "at": Vector2(0.0, 1.1926), "lim": [-12.0, 12.0], "kind": "spine"},

	"shoulder_l": {"a": "chest", "b": "arm_l_up", "at": Vector2(-0.225, 1.582), "lim": [-170.0, 170.0], "kind": "root"},
	"elbow_l": {"a": "arm_l_up", "b": "arm_l_lo", "at": Vector2(-0.625, 1.582), "lim": [-120.0, 120.0], "kind": "mid"},
	"wrist_l": {"a": "arm_l_lo", "b": "hand_l", "at": Vector2(-0.93, 1.582), "lim": [-50.0, 50.0], "kind": "end"},
	"shoulder_r": {"a": "chest", "b": "arm_r_up", "at": Vector2(0.225, 1.582), "lim": [-170.0, 170.0], "kind": "root"},
	"elbow_r": {"a": "arm_r_up", "b": "arm_r_lo", "at": Vector2(0.625, 1.582), "lim": [-120.0, 120.0], "kind": "mid"},
	"wrist_r": {"a": "arm_r_lo", "b": "hand_r", "at": Vector2(0.93, 1.582), "lim": [-50.0, 50.0], "kind": "end"},

	"hip_l": {"a": "pelvis", "b": "leg_l_up", "at": Vector2(-0.0906, 1.0187), "lim": [-150.0, 90.0], "kind": "root"},
	"knee_l": {"a": "leg_l_up", "b": "leg_l_lo", "at": Vector2(-0.09, 0.587), "lim": [-115.0, 115.0], "kind": "mid"},
	"ankle_l": {"a": "leg_l_lo", "b": "foot_l", "at": Vector2(-0.09, 0.1465), "lim": [-40.0, 40.0], "kind": "end"},
	"hip_r": {"a": "pelvis", "b": "leg_r_up", "at": Vector2(0.0906, 1.0187), "lim": [-90.0, 150.0], "kind": "root"},
	"knee_r": {"a": "leg_r_up", "b": "leg_r_lo", "at": Vector2(0.09, 0.587), "lim": [-115.0, 115.0], "kind": "mid"},
	"ankle_r": {"a": "leg_r_lo", "b": "foot_r", "at": Vector2(0.09, 0.1465), "lim": [-40.0, 40.0], "kind": "end"},
}

## The four limbs. root/mid joints, the upper and lower bones, the grab end, the
## rest direction of the bone in the T-pose (deg, y-up CCW), and the elbow/knee
## bend side for the two-bone solve (+1 = bend counter-clockwise).
const LIMBS := [
	{"id": "arm_l", "root": "shoulder_l", "mid": "elbow_l", "up": "arm_l_up", "lo": "arm_l_lo", "end": "hand_l", "rest_deg": 180.0, "bend": -1.0, "arm": true},
	{"id": "arm_r", "root": "shoulder_r", "mid": "elbow_r", "up": "arm_r_up", "lo": "arm_r_lo", "end": "hand_r", "rest_deg": 0.0, "bend": 1.0, "arm": true},
	{"id": "leg_l", "root": "hip_l", "mid": "knee_l", "up": "leg_l_up", "lo": "leg_l_lo", "end": "foot_l", "rest_deg": -90.0, "bend": -1.0, "arm": false},
	{"id": "leg_r", "root": "hip_r", "mid": "knee_r", "up": "leg_r_up", "lo": "leg_r_lo", "end": "foot_r", "rest_deg": -90.0, "bend": 1.0, "arm": false},
]

## The order pieces are streamed and frozen in. Never reorder: the network and
## saved towers index by it.
const ORDER := [
	"head", "chest", "navel", "pelvis",
	"arm_l_up", "arm_l_lo", "hand_l", "arm_r_up", "arm_r_lo", "hand_r",
	"leg_l_up", "leg_l_lo", "foot_l", "leg_r_up", "leg_r_lo", "foot_r",
]


## The reach point of the end piece: hand-ball or foot centre, y-up metres
## (with the shoulder shift for a hand).
static func end_point(end_name: String) -> Vector2:
	var s: Array = PIECES[end_name].shape
	return s[1] + shift(end_name)


## THE WIDE SHOULDERS (Golemheim's SHOULDER_FLARE, Parker 2026-11-07: "make the
## shoulders wider and a little lower"): every arm piece and arm joint (shoulder,
## elbow, wrist) sits Feel shoulder_flare further OUT and shoulder_drop LOWER than
## the model, the arm meshes riding along. The chest stays put. Body-scale 1 metres,
## screen side (arm_l is screen-left). Zero for everything else.
const _LEFT_ARM := ["arm_l_up", "arm_l_lo", "hand_l", "shoulder_l", "elbow_l", "wrist_l"]
const _RIGHT_ARM := ["arm_r_up", "arm_r_lo", "hand_r", "shoulder_r", "elbow_r", "wrist_r"]


static func shift(name: String) -> Vector2:
	var side := -1.0 if _LEFT_ARM.has(name) else (1.0 if _RIGHT_ARM.has(name) else 0.0)
	if side == 0.0:
		return Vector2.ZERO
	return Vector2(side * Feel.get_k("shoulder_flare"), -Feel.get_k("shoulder_drop"))
