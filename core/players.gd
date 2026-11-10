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
## An ANY-device slot's effective device changed (the player picked up the pad, or
## went back to the mouse): glyphs follow it.
signal device_changed(slot: int)

const KBM := -1
## The one-player slot: whichever device spoke last drives (Practice, Online with
## one local player). Swap between keyboard+mouse and any pad at will.
const ANY := -2
const ACTIONS := ["arm_l", "arm_r", "leg_l", "leg_r", "lock", "pause"]
const ACTION_NAMES := ["Left hand", "Right hand", "Left foot", "Right foot", "Lock in", "Pause"]
const MAX_LOCAL := 8

## Two binds per action per scheme. A bind is {"key": physical keycode},
## {"mouse": button}, {"pad": button} or {"axis": axis} (a trigger).
## The reference game's layout, read off its own controls card and save file on
## 2026-11-07: hands on the diamond's sides, feet on its top and bottom.
##   Pad:      X screen-left hand, A screen-right hand, Y left foot, B right foot,
##             Start ends the turn (Lock in); the left stick steers.
##   Keyboard: A left hand, D right hand, W left foot, S right foot, Space ends the
##             turn; the mouse steers.
## Back / Esc pause (our own; the reference game pauses on Esc too).
const DEFAULT_KBM := {
	"arm_l": [{"key": KEY_A}, {}],
	"arm_r": [{"key": KEY_D}, {}],
	"leg_l": [{"key": KEY_W}, {}],
	"leg_r": [{"key": KEY_S}, {}],
	"lock": [{"key": KEY_SPACE}, {"key": KEY_ENTER}],
	"pause": [{"key": KEY_ESCAPE}, {}],
}
const DEFAULT_PAD := {
	"arm_l": [{"pad": JOY_BUTTON_X}, {}],
	"arm_r": [{"pad": JOY_BUTTON_A}, {}],
	"leg_l": [{"pad": JOY_BUTTON_Y}, {}],
	"leg_r": [{"pad": JOY_BUTTON_B}, {}],
	"fart": [{"pad": JOY_BUTTON_RIGHT_SHOULDER}, {}],
	"lock": [{"pad": JOY_BUTTON_START}, {}],
	"pause": [{"pad": JOY_BUTTON_BACK}, {}],
}
## Saved binds from an older default layout are dropped when this changes.
const BINDS_VERSION := 3
const SAVE := "user://binds.cfg"

var binds := {"kbm": {}, "pad": {}}
## slot -> {"device": int, "name": String, "skin": String, "tint": Color}
var slots: Array = []
## The camera the mouse aims through (set by the game).
var camera: Camera3D = null
## Batteries: fake devices. device id -> {"buttons": {action: bool}, "stick": Vector2}
var fake := {}

## The device that spoke last: KBM or a pad id. ANY slots follow it.
var last_device := KBM
var _native_fallback := false
var _native_buttons := {}
var _native_axes := {}
var _native_event_pads := []

var _lock_prev := {}
var _lock_edge := {}
var _pause_prev := {}
var _pause_edge := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # the pause button must work while paused
	process_physics_priority = -100
	process_priority = -100
	binds.kbm = DEFAULT_KBM.duplicate(true)
	binds.pad = DEFAULT_PAD.duplicate(true)
	_load()
	Input.joy_connection_changed.connect(func(dev: int, connected: bool):
		if not connected:
			_native_event_pads.erase(dev)
			for table in [_native_buttons, _native_axes]:
				for key: Vector2i in table.keys():
					if key.x == dev:
						table.erase(key))


## Which device spoke last, for the ANY slot and its glyphs.
func _input(event: InputEvent) -> void:
	_refresh_native_fallback()
	if _native_fallback:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			if not _native_event_pads.has(event.device):
				_native_event_pads.append(event.device)
		if event is InputEventJoypadButton:
			_native_buttons[Vector2i(event.device, event.button_index)] = event.pressed
		elif event is InputEventJoypadMotion:
			_native_axes[Vector2i(event.device, event.axis)] = event.axis_value
	if (event is InputEventJoypadButton or event is InputEventJoypadMotion) and _steam_live():
		return  # Steam reports the same physical controller through note_device().
	var dev := -99
	if event is InputEventKey or event is InputEventMouseButton:
		dev = KBM
	elif event is InputEventMouseMotion and (event as InputEventMouseMotion).relative.length() > 6.0:
		dev = KBM
	elif event is InputEventJoypadButton:
		dev = (event as InputEventJoypadButton).device
	elif event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > 0.5:
		dev = (event as InputEventJoypadMotion).device
	if dev == -99 or dev == last_device:
		return
	last_device = dev
	for s in slots.size():
		if int(slots[s].device) == ANY:
			device_changed.emit(s)


## The device an ANY slot reads right now (its own device for a fixed slot).
func effective_device(slot: int) -> int:
	if slot < 0 or slot >= slots.size():
		return KBM
	var d := int(slots[slot].device)
	return last_device if d == ANY else d


func _physics_process(_delta: float) -> void:
	_refresh_native_fallback()
	_refresh_pad_routes()
	for s in slots.size():
		var dev: int = slots[s].device
		# A press is kept until something reads it (an edge must never be lost
		# because the reader ticked a frame late).
		var now := _action(dev, "lock")
		if now and not _lock_prev.get(s, false):
			_lock_edge[s] = true
		_lock_prev[s] = now
		var p := _action(dev, "pause")
		if p and not _pause_prev.get(s, false):
			_pause_edge[s] = true
		_pause_prev[s] = p


# ---------------------------------------------------------------- slots

## Invites can connect before any menu creates a player. A solo online climber
## follows the active backend while keeping its roster index and identity.
func prepare_online(pname: String) -> void:
	if slots.is_empty():
		add_online_player(pname)
	elif slots.size() == 1:
		slots[0].device = ANY
		slots[0].erase("native_pad")
		device_changed.emit(0)
	_refresh_pad_routes()


## When several local players join online, preserve distinct slots as Steam
## takes over the physical pads. Keep their native IDs for fallback on disconnect.
func _refresh_pad_routes() -> void:
	if slots.is_empty() or (slots.size() == 1 and slots[0].device == ANY):
		return
	var available := steam_devices()
	available.sort()
	for slot in slots:
		if slot.has("native_pad") and not available.has(slot.device):
			slot.device = slot.native_pad
			slot.erase("native_pad")
	for slot in slots:
		available.erase(slot.device)
	for exact_match in [true, false]:
		for s in slots.size():
			var slot: Dictionary = slots[s]
			var raw := int(slot.device)
			if raw < 0 or raw >= 1000 or available.is_empty():
				continue
			var route := -1
			for dev: int in available:
				if Net.steam_input.devices[dev].get("gamepad_index", -1) == raw:
					route = dev
					break
			if route < 0:
				if exact_match:
					continue
				route = available.front()
			slot.native_pad = raw
			slot.device = route
			available.erase(route)
			device_changed.emit(s)

## AN ONLINE PLAYER (Parker 11-09: the nameplate "is just showing steam names"): the
## player goes by their Steam name (lobby, results, "X CLIMBING"), but each climber
## they play gets a made-up name, like everyone else's; the nameplate cycles the
## made name, the round and the Steam name.
func add_online_player(steam_name: String) -> int:
	var s := add_player(ANY, steam_name)
	if s >= 0:
		slots[s].random = true
	return s


func add_player(device: int, pname := "") -> int:
	if slots.size() >= MAX_LOCAL or slot_of_device(device) != -1:
		return -1
	var s := slots.size()
	slots.append({"device": device, "name": pname if pname != "" else NameGen.make(), "random": pname == "", "skin": "defaultio", "tint": NameGen.tint(s)})
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
	_lock_prev.clear()
	_lock_edge.clear()
	_pause_prev.clear()
	_pause_edge.clear()


## For a join screen: a device that pressed its Lock In / A just now and has no
## slot yet, or -2 for none.
func poll_join() -> int:
	var connected := devices()
	var any_slot := slot_of_device(ANY)
	for dev in connected:
		if slot_of_device(dev) != -1 or not _action(dev, "lock"):
			continue
		if any_slot >= 0:
			# Start on the primary pad must not create a second climber. Pin
			# the solo slot only when a genuinely different device joins.
			var pads := connected.duplicate()
			pads.erase(KBM)
			var primary: int = pads.front() if not pads.is_empty() else KBM
			if dev == primary:
				continue
			slots[any_slot].device = primary
			device_changed.emit(any_slot)
		return dev
	return -2


func devices() -> Array:
	var out: Array = [KBM]
	out.append_array(_raw_pads())  # while Steam has the pads, only its devices join
	out.append_array(steam_devices())
	out.append_array(fake.keys())
	return out


## Controllers read through Steam's controller API (when Steam is running).
func steam_devices() -> Array:
	var si = Net.steam_input if Net.get("steam_input") != null else null
	return si.active_devices("gameplay_active") if si != null else []


func _is_steam_dev(dev: int) -> bool:
	return dev >= 3000 and dev < 3100


## A Steam controller spoke (it makes no InputEvents): the ANY slot follows it.
func note_device(dev: int) -> void:
	if dev == last_device:
		return
	last_device = dev
	for s in slots.size():
		if int(slots[s].device) == ANY:
			device_changed.emit(s)


static func device_label(device: int) -> String:
	if device == KBM:
		return "Keyboard + mouse"
	if device == ANY:
		return "Any device"
	if device >= 3000 and device < 3100:
		return "Steam controller %d" % (device - 3000)
	if device >= 1000:
		return "Test pad %d" % (device - 1000)
	return Input.get_joy_name(device) if Input.get_joy_name(device) != "" else "Pad %d" % device


# ---------------------------------------------------------------- reads

func limb_held(s: int, limb: int) -> bool:
	if s < 0 or s >= slots.size():
		return false
	return _action(slots[s].device, ACTIONS[limb])


func fart_held(s: int) -> bool:
	return s >= 0 and s < slots.size() and _action(slots[s].device, "fart")


func lock_pressed(s: int) -> bool:
	var e: bool = _lock_edge.get(s, false)
	_lock_edge[s] = false
	return e


func pause_pressed(s: int) -> bool:
	var e: bool = _pause_edge.get(s, false)
	_pause_edge[s] = false
	return e


## A pad aims with its LEFT stick; the
## keyboard player aims with the mouse on the play plane.
func limb_aim(s: int, climber, limb: int):
	if s < 0 or s >= slots.size():
		return null
	var dev: int = slots[s].device
	if dev == KBM:
		return _mouse_aim()
	var st := stick(dev)
	if dev == ANY and st.length() < Feel.get_k("stick_deadzone"):
		return _mouse_aim() if last_device == KBM else null
	if st.length() < Feel.get_k("stick_deadzone"):
		return null  # the hand stays where it was steered
	var mag := minf(st.length(), 1.0)  # the push is the reach: half a push, half way out
	return {"dir": st.normalized(), "mag": mag}


## The device's stick, y-up, radial deadzone left to the caller.
func stick(dev: int) -> Vector2:
	if dev == ANY:
		var best := Vector2.ZERO
		for p in _raw_pads() + steam_devices():
			var v := stick(p)
			if v.length() > best.length():
				best = v
		return best
	if _is_steam_dev(dev):
		return Net.steam_input.stick(dev) if Net.steam_input != null else Vector2.ZERO
	if fake.has(dev):
		return fake[dev].get("stick", Vector2.ZERO)
	if _steam_live():
		return Vector2.ZERO  # stale while Steam reads the pad
	# The LEFT stick steers; the right stick does nothing (Parker 2026-11-07).
	return Vector2(_axis_value(dev, JOY_AXIS_LEFT_X), -_axis_value(dev, JOY_AXIS_LEFT_Y))


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


## THE STALE PAD (Parker 11-09: "the A button on my controller is being registered as
## always held in game, when I am not holding it"): once Steam Input has the pads, it
## reads them itself and Godot's own joypad state stops updating. A button that was
## down when Steam took over stays "pressed" forever in Input. So while Steam has
## controllers, the raw joypads are not read at all (PadNav does the same): Steam's
## per-frame action state is the only truth, and it sees releases.
func _steam_live() -> bool:
	var si = Net.steam_input if Net.get("steam_input") != null else null
	return si != null and not si.active_devices("gameplay_active").is_empty()


func _refresh_native_fallback() -> void:
	var detected: bool = Net.steam_input != null and Net.steam_input.count() > 0
	var fallback: bool = detected and not _steam_live()
	if fallback != _native_fallback:
		_native_fallback = fallback
		_native_buttons.clear()
		_native_axes.clear()
		_native_event_pads.clear()


func _axis_value(dev: int, axis: int) -> float:
	if _native_fallback:
		return float(_native_axes.get(Vector2i(dev, axis), 0.0))
	return Input.get_joy_axis(dev, axis)


func _raw_pads() -> Array:
	if _steam_live():
		return []
	var pads: Array = Input.get_connected_joypads()
	for dev in _native_event_pads:
		if not pads.has(dev):
			pads.append(dev)
	return pads


func _action(dev: int, action: String) -> bool:
	if dev == ANY:
		if _action(KBM, action):
			return true
		for p in _raw_pads():
			if _action(p, action):
				return true
		for p in steam_devices():
			if _action(p, action):
				return true
		return false
	if _is_steam_dev(dev):
		return Net.steam_input != null and Net.steam_input.button(dev, action)
	if fake.has(dev):
		return fake[dev].get("buttons", {}).get(action, false)
	if dev != KBM and _steam_live():
		return false  # a raw pad's state is stale while Steam reads it (above)
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
		if _native_fallback:
			return bool(_native_buttons.get(Vector2i(dev, b.pad), false))
		return Input.is_joy_button_pressed(dev, b.pad)
	if b.has("axis"):
		return _axis_value(dev, b.axis) >= Feel.get_k("trigger_press")
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
	cf.set_value("binds", "version", BINDS_VERSION)
	cf.set_value("binds", "kbm", binds.kbm)
	cf.set_value("binds", "pad", binds.pad)
	cf.save(SAVE)


func _load() -> void:
	var cf := ConfigFile.new()
	if cf.load(SAVE) != OK:
		return
	if int(cf.get_value("binds", "version", 0)) != BINDS_VERSION:
		return  # binds saved under an older default layout: start from the new defaults
	for scheme in ["kbm", "pad"]:
		var d = cf.get_value("binds", scheme, null)
		if d is Dictionary:
			for a in ACTIONS:
				if d.has(a) and d[a] is Array and d[a].size() == 2:
					binds[scheme][a] = d[a]
