extends Node
## PLAYERS: the local players and their devices. Autoload "Players".
##
## Every local player owns ONE device: the keyboard-and-mouse (device -1) or one
## pad (its joypad id). Nothing reads "any pad" or device 0: every read goes
## through the slot's own device (the fix for Golemheim's device-0 gap). Both
## triggers share one press point, Feel "trigger_press" (the LT/RT gap fix).
##
## Limb order: 0 arm_l, 1 arm_r, 2 leg_l, 3 leg_r (screen sides), then 4 = Lock In.

signal joined(slot: int)
signal left(slot: int)

const KBM := -1
const ACTIONS := ["arm_l", "arm_r", "leg_l", "leg_r", "lock", "pause"]
const ACTION_NAMES := ["Left hand", "Right hand", "Left foot", "Right foot", "Lock in", "Pause"]
const MAX_LOCAL := 8

## Two binds per action per scheme. A bind is {"key": physical keycode},
## {"mouse": button}, {"pad": button} or {"axis": axis} (a trigger).
const DEFAULT_KBM := {
	"arm_l": [{"mouse": MOUSE_BUTTON_LEFT}, {"key": KEY_Q}],
	"arm_r": [{"mouse": MOUSE_BUTTON_RIGHT}, {"key": KEY_E}],
	"leg_l": [{"key": KEY_A}, {"key": KEY_Z}],
	"leg_r": [{"key": KEY_D}, {"key": KEY_C}],
	"lock": [{"key": KEY_SPACE}, {}],
	"pause": [{"key": KEY_ESCAPE}, {}],
}
const DEFAULT_PAD := {
	"arm_l": [{"pad": JOY_BUTTON_LEFT_SHOULDER}, {}],
	"arm_r": [{"pad": JOY_BUTTON_RIGHT_SHOULDER}, {}],
	"leg_l": [{"axis": JOY_AXIS_TRIGGER_LEFT}, {}],
	"leg_r": [{"axis": JOY_AXIS_TRIGGER_RIGHT}, {}],
	"lock": [{"pad": JOY_BUTTON_A}, {}],
	"pause": [{"pad": JOY_BUTTON_START}, {}],
}
const SAVE := "user://binds.cfg"

var binds := {"kbm": {}, "pad": {}}
## slot -> {"device": int, "name": String, "skin": String, "tint": Color}
var slots: Array = []
## The camera the mouse aims through (set by the game).
var camera: Camera3D = null
## Batteries: fake devices. device id -> {"buttons": {action: bool}, "stick": Vector2}
var fake := {}

var _lock_prev := {}
var _lock_edge := {}
var _pause_prev := {}
var _pause_edge := {}


func _ready() -> void:
	process_physics_priority = -100
	process_priority = -100
	binds.kbm = DEFAULT_KBM.duplicate(true)
	binds.pad = DEFAULT_PAD.duplicate(true)
	_load()


func _physics_process(_delta: float) -> void:
	for s in slots.size():
		var dev: int = slots[s].device
		var now := _action(dev, "lock")
		_lock_edge[s] = now and not _lock_prev.get(s, false)
		_lock_prev[s] = now
		var p := _action(dev, "pause")
		_pause_edge[s] = p and not _pause_prev.get(s, false)
		_pause_prev[s] = p


# ---------------------------------------------------------------- slots

func add_player(device: int, pname := "") -> int:
	if slots.size() >= MAX_LOCAL or slot_of_device(device) != -1:
		return -1
	var s := slots.size()
	slots.append({"device": device, "name": pname if pname != "" else NameGen.make(), "skin": "metal_knight", "tint": NameGen.tint(s)})
	joined.emit(s)
	return s


func remove_player(s: int) -> void:
	if s < 0 or s >= slots.size():
		return
	slots.remove_at(s)
	_lock_prev.clear()
	_lock_edge.clear()
	left.emit(s)


func slot_of_device(device: int) -> int:
	for s in slots.size():
		if slots[s].device == device:
			return s
	return -1


func clear_players() -> void:
	slots.clear()


## For a join screen: a device that pressed its Lock In / A just now and has no
## slot yet, or -2 for none.
func poll_join() -> int:
	for dev in devices():
		if slot_of_device(dev) == -1 and _action(dev, "lock"):
			return dev
	return -2


func devices() -> Array:
	var out: Array = [KBM]
	out.append_array(Input.get_connected_joypads())
	out.append_array(fake.keys())
	return out


static func device_label(device: int) -> String:
	if device == KBM:
		return "Keyboard + mouse"
	if device >= 1000:
		return "Test pad %d" % (device - 1000)
	return Input.get_joy_name(device) if Input.get_joy_name(device) != "" else "Pad %d" % device


# ---------------------------------------------------------------- reads

func limb_held(s: int, limb: int) -> bool:
	if s < 0 or s >= slots.size():
		return false
	return _action(slots[s].device, ACTIONS[limb])


func lock_pressed(s: int) -> bool:
	var e: bool = _lock_edge.get(s, false)
	_lock_edge[s] = false
	return e


func pause_pressed(s: int) -> bool:
	var e: bool = _pause_edge.get(s, false)
	_pause_edge[s] = false
	return e


## A pad aims with its stick (either stick, whichever is pushed further); the
## keyboard player aims with the mouse on the play plane.
func limb_aim(s: int, climber, limb: int):
	if s < 0 or s >= slots.size():
		return null
	var dev: int = slots[s].device
	if dev == KBM:
		return _mouse_aim()
	var st := stick(dev)
	if st.length() < Feel.get_k("stick_deadzone"):
		return null
	var mag := inverse_lerp(Feel.get_k("stick_deadzone"), 1.0, minf(st.length(), 1.0))
	return {"dir": st.normalized(), "mag": mag}


## The device's stick, y-up, radial deadzone left to the caller.
func stick(dev: int) -> Vector2:
	if fake.has(dev):
		return fake[dev].get("stick", Vector2.ZERO)
	var l := Vector2(Input.get_joy_axis(dev, JOY_AXIS_LEFT_X), -Input.get_joy_axis(dev, JOY_AXIS_LEFT_Y))
	var r := Vector2(Input.get_joy_axis(dev, JOY_AXIS_RIGHT_X), -Input.get_joy_axis(dev, JOY_AXIS_RIGHT_Y))
	return l if l.length() >= r.length() else r


func _mouse_aim():
	if camera == null or not is_instance_valid(camera):
		return null
	var vp := camera.get_viewport()
	var mp := vp.get_mouse_position()
	var o := camera.project_ray_origin(mp)
	var n := camera.project_ray_normal(mp)
	if absf(n.z) < 0.0001:
		return null
	var k := -o.z / n.z
	var hit := o + n * k
	return {"point": Vector2(hit.x, hit.y)}


func _action(dev: int, action: String) -> bool:
	if fake.has(dev):
		return fake[dev].get("buttons", {}).get(action, false)
	var scheme: String = "kbm" if dev == KBM else "pad"
	for b in binds[scheme].get(action, []):
		if _bind_down(dev, b):
			return true
	return false


func _bind_down(dev: int, b: Dictionary) -> bool:
	if b.is_empty():
		return false
	if b.has("key"):
		return dev == KBM and Input.is_physical_key_pressed(b.key)
	if b.has("mouse"):
		return dev == KBM and Input.is_mouse_button_pressed(b.mouse)
	if dev == KBM:
		return false
	if b.has("pad"):
		return Input.is_joy_button_pressed(dev, b.pad)
	if b.has("axis"):
		return Input.get_joy_axis(dev, b.axis) >= Feel.get_k("trigger_press")
	return false


# ---------------------------------------------------------------- rebinding

func set_bind(scheme: String, action: String, index: int, b: Dictionary) -> void:
	var list: Array = binds[scheme][action]
	# One input, one action: clear it anywhere else in the scheme first.
	if not b.is_empty():
		for a in binds[scheme]:
			for i in binds[scheme][a].size():
				if binds[scheme][a][i] == b:
					binds[scheme][a][i] = {}
	list[index] = b
	save()


func reset_binds() -> void:
	binds.kbm = DEFAULT_KBM.duplicate(true)
	binds.pad = DEFAULT_PAD.duplicate(true)
	save()


static func bind_label(b: Dictionary) -> String:
	if b.is_empty():
		return "-"
	if b.has("key"):
		return OS.get_keycode_string(b.key)
	if b.has("mouse"):
		return {MOUSE_BUTTON_LEFT: "Left mouse", MOUSE_BUTTON_RIGHT: "Right mouse", MOUSE_BUTTON_MIDDLE: "Middle mouse"}.get(b.mouse, "Mouse %d" % b.mouse)
	if b.has("pad"):
		return {JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y",
			JOY_BUTTON_LEFT_SHOULDER: "LB", JOY_BUTTON_RIGHT_SHOULDER: "RB", JOY_BUTTON_START: "Start",
			JOY_BUTTON_BACK: "Back", JOY_BUTTON_LEFT_STICK: "L3", JOY_BUTTON_RIGHT_STICK: "R3"}.get(b.pad, "Button %d" % b.pad)
	if b.has("axis"):
		return {JOY_AXIS_TRIGGER_LEFT: "LT", JOY_AXIS_TRIGGER_RIGHT: "RT"}.get(b.axis, "Axis %d" % b.axis)
	return "?"


func save() -> void:
	var cf := ConfigFile.new()
	cf.set_value("binds", "kbm", binds.kbm)
	cf.set_value("binds", "pad", binds.pad)
	cf.save(SAVE)


func _load() -> void:
	var cf := ConfigFile.new()
	if cf.load(SAVE) != OK:
		return
	for scheme in ["kbm", "pad"]:
		var d = cf.get_value("binds", scheme, null)
		if d is Dictionary:
			for a in ACTIONS:
				if d.has(a) and d[a] is Array and d[a].size() == 2:
					binds[scheme][a] = d[a]
