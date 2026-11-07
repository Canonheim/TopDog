extends Node
## THE FEEL TABLE: every knob that changes how climbing feels, in one place.
## Autoload "Feel". Read as Feel.get_k("name") or Feel.v.name; the dev panel (F1)
## edits the same dictionary live. Units: metres, seconds, degrees, unless named.

signal changed(key: String)

const PPM := 100.0  # 2D physics pixels per metre (the physics world is in px)

## [value, min, max, help]. Order here is the dev panel's order.
const SPEC := {
	"body_scale": [0.9, 0.6, 1.3, "Climber size (1.0 = the knight's modelled 2.02 m)"],
	"gravity_scale": [1.0, 0.2, 2.0, "Gravity on climbers"],
	"arm_strength": [1.15, 0.2, 4.0, "Arm torque cap, in body-weights at full reach"],
	"leg_strength": [1.35, 0.2, 4.0, "Leg torque cap, in body-weights at full reach"],
	"drive_freq": [8.0, 2.0, 30.0, "How fast a held limb chases its aim (rad/s)"],
	"drive_damping": [0.9, 0.2, 2.0, "Held-limb damping ratio (1 = critical)"],
	"hold_strength": [1.2, 0.0, 4.0, "How stiffly limbs you are not moving hold their pose (body-weights at reach)"],
	"wrist_spring": [1.0, 0.0, 3.0, "Wrist and ankle spring back to straight (stiff ankles = a steady stance)"],
	"spine_spring": [0.55, 0.05, 3.0, "Torso flex spring back to straight"],
	"spine_damping": [0.5, 0.0, 2.0, "Torso flex damping ratio"],
	"spine_limit": [12.0, 0.0, 30.0, "Torso flex per spine joint (deg, two joints)"],
	"neck_spring": [0.8, 0.0, 3.0, "Neck spring"],
	"reach_min": [0.5, 0.1, 1.0, "Pad: reach at a light stick push (fraction of limb)"],
	"stick_deadzone": [0.22, 0.05, 0.6, "Pad stick deadzone"],
	"trigger_press": [0.45, 0.1, 0.9, "Pad trigger press point (both triggers)"],
	"regrip_delay": [0.12, 0.0, 0.6, "Seconds before a released limb can stick again"],
	"friction_ends": [1.2, 0.0, 3.0, "Friction of hands and feet"],
	"friction_body": [0.6, 0.0, 3.0, "Friction of the rest of the body"],
	"bounce": [0.0, 0.0, 0.8, "Bounciness of climbers"],
	"linear_damp": [0.05, 0.0, 2.0, "Air drag on every piece"],
	"angular_damp": [0.4, 0.0, 5.0, "Spin drag on every piece"],
	"puppet_delay": [0.1, 0.0, 0.4, "Online: seconds of buffer behind a remote climber"],
	"pull_cap": [1.5, 0.0, 6.0, "Online: cap on a rival's pull, in body-weights"],
}

var v := {}


func _ready() -> void:
	reset()


func reset() -> void:
	for k in SPEC:
		v[k] = SPEC[k][0]


func get_k(key: String) -> float:
	return float(v.get(key, SPEC[key][0] if SPEC.has(key) else 0.0))


func set_k(key: String, value: float) -> void:
	if not SPEC.has(key):
		return
	v[key] = clampf(value, SPEC[key][1], SPEC[key][2])
	changed.emit(key)


## For a battery or a lobby: the whole table as plain data, and back.
func dump() -> Dictionary:
	return v.duplicate()


func load_from(d: Dictionary) -> void:
	for k in d:
		if SPEC.has(k):
			v[k] = clampf(float(d[k]), SPEC[k][1], SPEC[k][2])
