class_name AnyPress
extends Node
## ANY BUTTON: one signal for "the player pressed something", for the boot screens and
## the title's PRESS ANY BUTTON TO START (Parker 11-11). Counts a key, a mouse button,
## any Godot pad button, and the menu actions PadNav sends (a Steam pad's A or d-pad
## arrives that way). A button already held when it arms only counts once let go
## and pressed again, so the press that ended one screen never ends the next.

signal pressed

## Seconds after arming before a press counts.
var delay := 0.25
var _armed_at := 0
var _held := {}  # "dev:button" -> true while down (polled)
var _fired := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_armed_at = Time.get_ticks_msec() + int(delay * 1000.0)
	# Whatever is down now is old news.
	for dev in Input.get_connected_joypads():
		for b in JOY_BUTTON_SDL_MAX:
			if Input.is_joy_button_pressed(dev, b):
				_held["%d:%d" % [dev, b]] = true


func _live() -> bool:
	return not _fired and Time.get_ticks_msec() >= _armed_at


func _input(event: InputEvent) -> void:
	var hit := false
	if event is InputEventKey:
		hit = event.pressed and not event.echo
	elif event is InputEventMouseButton:
		hit = event.pressed
	elif event is InputEventJoypadButton:
		var key := "%d:%d" % [event.device, event.button_index]
		if event.pressed:
			hit = not _held.get(key, false)
			_held[key] = true
		else:
			_held.erase(key)
	elif event is InputEventAction:
		hit = event.pressed and event.action in ["ui_accept", "ui_cancel", "ui_up", "ui_down", "ui_left", "ui_right"]
	if hit and _live():
		get_viewport().set_input_as_handled()  # the press that ends a screen does nothing else
		_fire()


func _process(_delta: float) -> void:
	# Polling too, as PadNav does: a pad whose events don't arrive still counts.
	for dev in Input.get_connected_joypads():
		for b in JOY_BUTTON_SDL_MAX:
			var key := "%d:%d" % [dev, b]
			var down := Input.is_joy_button_pressed(dev, b)
			if down and not _held.get(key, false):
				_held[key] = true
				if _live():
					_fire()
					return
			elif not down:
				_held.erase(key)


func _fire() -> void:
	_fired = true
	pressed.emit()
