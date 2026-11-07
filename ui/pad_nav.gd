extends Node
## PAD NAV: every connected pad drives the menus. Golemheim's PAD HANDS ON EVERY
## SCREEN, made sturdier.
##
## - Pads are read DIRECTLY (Input.is_joy_button_pressed / get_joy_axis on every
##   connected pad, the same reads the climbing controls use) and turned into
##   ui_up / ui_down / ui_left / ui_right / ui_accept / ui_cancel action events.
##   The stock InputMap pad events are stripped from those actions first, so a
##   press never counts twice and never depends on the stock map.
## - Hold-to-repeat on the d-pad and left stick.
## - ensure focus: the moment a pad speaks, if nothing on the visible screen holds
##   the focus (a mouse click took it, or a screen just opened), the first live
##   control gets it.
## - last_pad / last_input feed the Controls screen's live pad readout.
##
## Only menus listen to this: in a match, players' limbs read their own pads
## through Players, and the menu events are ignored there (no focus on the HUD).

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
## Turned off while a match is being played (limbs own the pads then).
var active := true
var last_pad := -1
var last_input := ""

var _held := {}  # "dev:action" -> true
var _repeat := {}  # "dev:action" -> seconds to the next repeat


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for action in ["ui_up", "ui_down", "ui_left", "ui_right", "ui_accept", "ui_cancel", "ui_select", "ui_focus_next", "ui_focus_prev"]:
		if not InputMap.has_action(action):
			continue
		for ev in InputMap.action_get_events(action):
			if ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
				InputMap.action_erase_event(action, ev)


func _process(delta: float) -> void:
	for dev in Input.get_connected_joypads():
		for action in DIRS:
			var d: Array = DIRS[action]
			var key := "%d:%s" % [dev, action]
			var ax := Input.get_joy_axis(dev, d[1]) * float(d[2])
			var was: bool = _held.get(key, false)
			var down := Input.is_joy_button_pressed(dev, d[0]) or ax > (STICK_OFF if was else STICK_ON)
			if down and not was:
				_fire(dev, action)
				_repeat[key] = REPEAT_FIRST
			elif down and was:
				_repeat[key] = float(_repeat.get(key, REPEAT_FIRST)) - delta
				if _repeat[key] <= 0.0:
					_fire(dev, action)
					_repeat[key] = REPEAT_NEXT
			_held[key] = down
		for action in BUTTONS:
			var key := "%d:%s" % [dev, action]
			var down := Input.is_joy_button_pressed(dev, BUTTONS[action])
			var was: bool = _held.get(key, false)
			if down != was:
				_send(action, down)
				if down:
					_note(dev, action)
					if action == "ui_cancel":
						back_pressed.emit()
			_held[key] = down


func _fire(dev: int, action: String) -> void:
	_note(dev, action)
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
	Input.parse_input_event(e)


func _note(dev: int, action: String) -> void:
	last_pad = dev
	last_input = action.trim_prefix("ui_")
	pad_used.emit(dev, last_input)


## If nothing on the visible screen holds the focus, give it to the first live
## control (buttons first, then sliders, dropdowns and edits).
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
