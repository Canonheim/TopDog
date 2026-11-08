extends Node
## PAD NAV: every connected pad drives the menus. Golemheim's PAD HANDS ON EVERY
## SCREEN, made sturdier, with TWO input paths so one failing can't deafen the menus:
##
## 1. POLLING: Input.is_joy_button_pressed / get_joy_axis on every connected pad
##    (the same reads the climbing controls use), each frame.
## 2. EVENTS: InputEventJoypadButton / InputEventJoypadMotion arriving in _input.
##
## Both update one held-state table, so a press seen by both fires once. Presses
## become ui_up / ui_down / ui_left / ui_right / ui_accept / ui_cancel action events
## (the stock pad events are stripped from those actions first, so nothing counts
## twice). The d-pad and left stick repeat when held. A pad press always lands the
## focus first: with nothing focused on the visible screen, the press only focuses.
##
## last_pad / last_input / last_time / seen_devices feed the on-screen pad readout
## (the title's corner line and the Controls screen), so a deaf pad is visible: if
## the readout never changes while a pad is pressed, the game is getting nothing.
##
## In a match, players' limbs read their own pads through Players; `active` is off
## and the menu events are not sent.

signal pad_used(device: int, what: String)
signal back_pressed

const STICK_ON := 0.55
const STICK_OFF := 0.35
const REPEAT_FIRST := 0.38
const REPEAT_NEXT := 0.11
const DIRS := {
	"ui_up": [JOY_BUTTON_DPAD_UP, JOY_AXIS_LEFT_Y, -1.0],
	"ui_down": [JOY_BUTTON_DPAD_DOWN, JOY_AXIS_LEFT_Y, 1.0],
	"ui_left": [JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1.0],
	"ui_right": [JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1.0],
}
const BUTTONS := {"ui_accept": JOY_BUTTON_A, "ui_cancel": JOY_BUTTON_B}

## The control under which focus is kept (the visible screen); set by main.
var screen_root: Control = null
## Off while a match is being played (limbs own the pads then).
var active := true
var last_pad := -1
var last_input := ""
var last_time := 0  # Time.get_ticks_msec() of the last pad input seen
var seen_devices := {}  # device -> last seen msec (events and polling)
var raw_count := 0  # every joypad event that reached _input, for the readout

var _held := {}  # "dev:action" -> bool
var _repeat := {}  # "dev:action" -> seconds to the next repeat
var _axis := {}  # "dev:axis" -> last value from events


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for action in ["ui_up", "ui_down", "ui_left", "ui_right", "ui_accept", "ui_cancel", "ui_select", "ui_focus_next", "ui_focus_prev"]:
		if not InputMap.has_action(action):
			continue
		for ev in InputMap.action_get_events(action):
			if ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
				InputMap.action_erase_event(action, ev)
	Input.joy_connection_changed.connect(func(dev: int, connected: bool) -> void:
		if connected:
			seen_devices[dev] = Time.get_ticks_msec())


# ---------------------------------------------------------------- path 2: events

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		var e := event as InputEventJoypadButton
		raw_count += 1
		seen_devices[e.device] = Time.get_ticks_msec()
		_note(e.device, _button_name(e.button_index))
		for action in DIRS:
			if DIRS[action][0] == e.button_index:
				_edge(e.device, action, e.pressed, true)
		for action in BUTTONS:
			if BUTTONS[action] == e.button_index:
				_edge(e.device, action, e.pressed, false)
	elif event is InputEventJoypadMotion:
		var m := event as InputEventJoypadMotion
		raw_count += 1
		seen_devices[m.device] = Time.get_ticks_msec()
		if absf(m.axis_value) > STICK_ON:
			_note(m.device, "axis %d" % m.axis)
		_axis["%d:%d" % [m.device, m.axis]] = m.axis_value
		for action in DIRS:
			var d: Array = DIRS[action]
			if d[1] != m.axis:
				continue
			var key := "%d:%s" % [m.device, action]
			var was: bool = _held.get(key, false)
			var v := m.axis_value * float(d[2])
			var down := v > (STICK_OFF if was else STICK_ON)
			# Only the stick side of the held state: a d-pad hold must not be cut by the stick centring.
			if down != was and not Input.is_joy_button_pressed(m.device, d[0]):
				_edge(m.device, action, down, true)


# ---------------------------------------------------------------- path 1: polling

func _process(delta: float) -> void:
	var si = Net.steam_input
	var steam_live: bool = si != null and si.count() > 0
	if steam_live:
		_poll_steam(si, delta)
	var devs := {}
	for dev in Input.get_connected_joypads():
		devs[dev] = true
	for dev in seen_devices:
		devs[dev] = true
	if steam_live:
		devs.clear()  # Steam has the pads: read them through it only, never twice
	for dev in devs:
		for action in DIRS:
			var d: Array = DIRS[action]
			var key := "%d:%s" % [dev, action]
			var was: bool = _held.get(key, false)
			var ax := maxf(Input.get_joy_axis(dev, d[1]) * float(d[2]), float(_axis.get("%d:%d" % [dev, d[1]], 0.0)) * float(d[2]))
			var down := Input.is_joy_button_pressed(dev, d[0]) or ax > (STICK_OFF if was else STICK_ON)
			if down and not was:
				_edge(dev, action, true, true)
				_repeat[key] = REPEAT_FIRST
			elif down and was:
				_repeat[key] = float(_repeat.get(key, REPEAT_FIRST)) - delta
				if _repeat[key] <= 0.0:
					_fire(dev, action)
					_repeat[key] = REPEAT_NEXT
			elif not down and was:
				_held[key] = false
		for action in BUTTONS:
			var down := Input.is_joy_button_pressed(dev, BUTTONS[action])
			if down != bool(_held.get("%d:%s" % [dev, action], false)):
				_edge(dev, action, down, false)


## Steam's controllers drive the menus the same way: held table, repeat, focus.
func _poll_steam(si, delta: float) -> void:
	for dev in si.devices.keys():
		var st: Dictionary = si.menu_state(dev)
		for action in DIRS:
			var key := "%d:%s" % [dev, action]
			var was: bool = _held.get(key, false)
			var down: bool = st[action]
			if down and not was:
				_edge(dev, action, true, true)
			elif down and was:
				_repeat[key] = float(_repeat.get(key, REPEAT_FIRST)) - delta
				if _repeat[key] <= 0.0:
					_fire(dev, action)
					_repeat[key] = REPEAT_NEXT
			elif not down and was:
				_held[key] = false
		for action in BUTTONS:
			if bool(st[action]) != bool(_held.get("%d:%s" % [dev, action], false)):
				_edge(dev, action, st[action], false)


# ---------------------------------------------------------------- the one held table

func _edge(dev: int, action: String, down: bool, is_dir: bool) -> void:
	var key := "%d:%s" % [dev, action]
	var was: bool = _held.get(key, false)
	if down == was:
		return
	_held[key] = down
	seen_devices[dev] = Time.get_ticks_msec()
	if is_dir:
		if down:
			_repeat[key] = REPEAT_FIRST
			_fire(dev, action)
	else:
		if down:
			_note(dev, action.trim_prefix("ui_"))
			if action == "ui_cancel":
				back_pressed.emit()
		_send(action, down)


func _fire(dev: int, action: String) -> void:
	_note(dev, action.trim_prefix("ui_"))
	if not active:
		return
	if ensure_focus():
		return  # the first press with nothing focused just lands the focus
	_send(action, true)
	_send(action, false)


func _send(action: String, pressed: bool) -> void:
	if not active:
		return
	if pressed and ensure_focus() and action == "ui_accept":
		return  # A with nothing focused lands the focus instead of pressing blind
	var e := InputEventAction.new()
	e.action = action
	e.pressed = pressed
	Input.call_deferred("parse_input_event", e)


func _note(dev: int, what: String) -> void:
	last_pad = dev
	last_input = what
	last_time = Time.get_ticks_msec()
	pad_used.emit(dev, what)


static func _button_name(b: int) -> String:
	return {JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y",
		JOY_BUTTON_LEFT_SHOULDER: "LB", JOY_BUTTON_RIGHT_SHOULDER: "RB", JOY_BUTTON_START: "Start",
		JOY_BUTTON_BACK: "Back", JOY_BUTTON_DPAD_UP: "D-pad up", JOY_BUTTON_DPAD_DOWN: "D-pad down",
		JOY_BUTTON_DPAD_LEFT: "D-pad left", JOY_BUTTON_DPAD_RIGHT: "D-pad right",
		JOY_BUTTON_LEFT_STICK: "L3", JOY_BUTTON_RIGHT_STICK: "R3", JOY_BUTTON_GUIDE: "Guide"}.get(b, "button %d" % b)


## For the readout: what the game knows about pads right now.
func readout() -> String:
	var pads := Input.get_connected_joypads()
	var names: Array = []
	for d in pads:
		var n := Input.get_joy_name(d)
		names.append("%s (%d)" % [n if n != "" else "pad", d])
	var line := "Pads: %s" % (", ".join(names) if not pads.is_empty() else "none connected")
	var si = Net.steam_input
	if si != null and si.ok:
		line += "   |   " + si.readout()
	if last_pad >= 0:
		line += "   |   last: %s on pad %d, %.1f s ago" % [last_input, last_pad, (Time.get_ticks_msec() - last_time) / 1000.0]
	else:
		line += "   |   no pad input received yet (%d raw events)" % raw_count
	return line


## If nothing on the visible screen holds the focus, give it to the first live
## control (buttons first, then sliders, dropdowns and edits). True when it did.
func ensure_focus() -> bool:
	if screen_root == null or not is_instance_valid(screen_root) or not screen_root.is_visible_in_tree():
		return false
	var owner := screen_root.get_viewport().gui_get_focus_owner()
	if owner != null and owner.is_visible_in_tree() and screen_root.is_ancestor_of(owner):
		return false
	return focus_first(screen_root)


static func focus_first(root: Control) -> bool:
	for cls in ["BaseButton", "Range", "LineEdit"]:
		for c in root.find_children("", cls, true, false):
			var ctl := c as Control
			if ctl.is_visible_in_tree() and ctl.focus_mode != Control.FOCUS_NONE \
					and not (ctl is BaseButton and (ctl as BaseButton).disabled):
				ctl.grab_focus()
				return true
	return false
