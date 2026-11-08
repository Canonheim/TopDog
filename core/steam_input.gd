extends Node
## STEAM INPUT: reading controllers through Steam's controller API.
##
## Why: on the shared dev app (480, Valve's own Steam Input sample game) Steam forces
## its controller layer on, whatever the player's settings say, and the layout it
## applies hands a normal game nothing (Parker 2026-11-07: his pad worked only with
## Steam off, and his global "Steam Input for Xbox" switch was already off). So the
## game hands Steam its OWN layout (an action manifest, written to user:// at start
## and passed to SetInputActionManifestFilePath before Init) and reads the actions
## back each frame. This also stays right when Top Dog has its own app ID.
##
## The layout (every controller type): X left hand, A right hand, Y left foot,
## B right foot, Start lock in, Back pause, the LEFT stick steers (the right is unbound), d-pad and the left
## stick move menus, A selects, B goes back.
##
## Each Steam controller shows up in Players as device STEAM_DEV_BASE + index, read
## by Players._action / Players.stick; the menus read menu_state(). Created by Net
## right after Steam starts; harmless if Steam has no controllers.

const STEAM_DEV_BASE := 3000
const ACTION_SET := "Game"
const DIGITAL := ["arm_l", "arm_r", "leg_l", "leg_r", "lock", "pause", "menu_up", "menu_down", "menu_left", "menu_right", "menu_select", "menu_back"]
const DIR := "user://steam_input"

var ok := false  # Steam Input initialised with our manifest
var manifest_accepted := false
var set_handle := 0
var digital_handles := {}  # action -> handle
var steer_handle := 0
## device id -> {"handle": int, "type": int, "buttons": {action: bool}, "stick": Vector2}
var devices := {}
var last_action := ""
var last_dev := -1
var _order: Array = []  # controller handles in first-seen order (stable device ids)
var _handles: Array = []
var _list_t := 0.0


func start() -> void:
	if not ClassDB.class_exists(&"Steam"):
		return
	var path := _write_files()
	manifest_accepted = bool(Steam.setInputActionManifestFilePath(path))
	ok = bool(Steam.inputInit(false))  # Steam runs the input frame inside run_callbacks
	if not ok:
		print("[SteamInput] init failed")
		return
	set_handle = int(Steam.getActionSetHandle(ACTION_SET))
	for a in DIGITAL:
		digital_handles[a] = int(Steam.getDigitalActionHandle(a))
	steer_handle = int(Steam.getAnalogActionHandle("steer"))
	print("[SteamInput] manifest %s, set %d, steer %d, digital %s" % [manifest_accepted, set_handle, steer_handle, digital_handles])


func shutdown() -> void:
	if ok:
		Steam.inputShutdown()
	ok = false
	devices.clear()


func count() -> int:
	return devices.size()


func _process(delta: float) -> void:
	if not ok:
		return
	# The controller list twice a second, not every frame (GodotSteam logs each call).
	_list_t -= delta
	if _list_t <= 0.0:
		_list_t = 0.5
		_handles = Steam.getConnectedControllers()
	var handles: Array = _handles
	var seen := {}
	for h in handles:
		var handle := int(h)
		if handle == 0:
			continue
		if not _order.has(handle):
			_order.append(handle)
		var dev := STEAM_DEV_BASE + _order.find(handle)
		seen[dev] = true
		if set_handle != 0:
			Steam.activateActionSet(handle, set_handle)
		var d: Dictionary = devices.get(dev, {"handle": handle, "type": int(Steam.getInputTypeForHandle(handle)), "buttons": {}, "stick": Vector2.ZERO})
		for a in DIGITAL:
			var dd: Dictionary = Steam.getDigitalActionData(handle, digital_handles[a])
			var down := bool(dd.get("state", false))
			if down and not d.buttons.get(a, false):
				_note(dev, a)
			d.buttons[a] = down
		var ad: Dictionary = Steam.getAnalogActionData(handle, steer_handle)
		d.stick = Vector2(float(ad.get("x", 0.0)), float(ad.get("y", 0.0)))  # Steam's joystick y is up, as ours
		if d.stick.length() > 0.5 and last_dev != dev:
			_note(dev, "stick")
		devices[dev] = d
	for dev in devices.keys():
		if not seen.has(dev):
			devices.erase(dev)


func _note(dev: int, what: String) -> void:
	last_dev = dev
	last_action = what
	Players.note_device(dev)


func button(dev: int, action: String) -> bool:
	var d: Dictionary = devices.get(dev, {})
	return bool(d.get("buttons", {}).get(action, false))


func stick(dev: int) -> Vector2:
	var d: Dictionary = devices.get(dev, {})
	return d.get("stick", Vector2.ZERO)


## For the menus: ui_* actions held on this Steam controller right now.
func menu_state(dev: int) -> Dictionary:
	var st := stick(dev)
	return {
		"ui_up": button(dev, "menu_up") or st.y > 0.55,
		"ui_down": button(dev, "menu_down") or st.y < -0.55,
		"ui_left": button(dev, "menu_left") or st.x < -0.55,
		"ui_right": button(dev, "menu_right") or st.x > 0.55,
		"ui_accept": button(dev, "menu_select"),
		"ui_cancel": button(dev, "menu_back"),
	}


func readout() -> String:
	if not ok:
		return ""
	var types := devices.values().map(func(d): return _type_name(int(d.type)))
	var s := "Steam Input: %d controller%s %s" % [devices.size(), "" if devices.size() == 1 else "s", str(types) if not types.is_empty() else ""]
	if not manifest_accepted:
		s += " (layout NOT accepted)"
	if last_dev >= 0:
		s += ", last: %s" % last_action
	return s


static func _type_name(t: int) -> String:
	return {1: "Steam Controller", 2: "Xbox 360", 3: "Xbox One", 4: "XInput", 5: "PS4", 10: "Switch Pro", 13: "PS5", 14: "Steam Deck"}.get(t, "type %d" % t)


# ---------------------------------------------------------------- the files Steam reads

func _write_files() -> String:
	DirAccess.make_dir_recursive_absolute(DIR)
	var types := ["controller_xboxone", "controller_xbox360", "controller_generic", "controller_ps4", "controller_ps5", "controller_switch_pro", "controller_steamcontroller_gordon", "controller_neptune"]
	var conf := ""
	for t in types:
		var f := FileAccess.open("%s/top_dog_%s.vdf" % [DIR, t], FileAccess.WRITE)
		f.store_string(_config(t))
		f.close()
		conf += '\t\t"%s"\n\t\t{\n\t\t\t"0"\n\t\t\t{\n\t\t\t\t"path"\t\t"top_dog_%s.vdf"\n\t\t\t}\n\t\t}\n' % [t, t]
	var m := FileAccess.open(DIR + "/top_dog_actions.vdf", FileAccess.WRITE)
	m.store_string(_manifest(conf))
	m.close()
	return ProjectSettings.globalize_path(DIR + "/top_dog_actions.vdf")


func _manifest(configurations: String) -> String:
	var buttons := ""
	for a in DIGITAL:
		buttons += '\t\t\t\t"%s"\t\t"#Action_%s"\n' % [a, a]
	var loc := '\t\t\t"Set_Game"\t\t"Top Dog"\n\t\t\t"Action_steer"\t\t"Steer the held limb"\n'
	var names := {"arm_l": "Left hand", "arm_r": "Right hand", "leg_l": "Left foot", "leg_r": "Right foot", "lock": "Lock in", "pause": "Pause",
		"menu_up": "Menu up", "menu_down": "Menu down", "menu_left": "Menu left", "menu_right": "Menu right", "menu_select": "Menu select", "menu_back": "Menu back"}
	for a in DIGITAL:
		loc += '\t\t\t"Action_%s"\t\t"%s"\n' % [a, names[a]]
	return '"Action Manifest"\n{\n\t"configurations"\n\t{\n' + configurations + '\t}\n' + \
		'\t"actions"\n\t{\n\t\t"Game"\n\t\t{\n\t\t\t"title"\t\t"#Set_Game"\n' + \
		'\t\t\t"StickPadGyro"\n\t\t\t{\n\t\t\t\t"steer"\n\t\t\t\t{\n\t\t\t\t\t"title"\t\t"#Action_steer"\n\t\t\t\t\t"input_mode"\t\t"joystick_move"\n\t\t\t\t}\n\t\t\t}\n' + \
		'\t\t\t"Button"\n\t\t\t{\n' + buttons + '\t\t\t}\n\t\t}\n\t}\n' + \
		'\t"localization"\n\t{\n\t\t"english"\n\t\t{\n' + loc + '\t\t}\n\t}\n}\n'


func _press(input: String, actions: Array) -> String:
	var b := ""
	for a in actions:
		b += '\t\t\t\t\t\t\t"binding"\t\t"game_action Game %s, , "\n' % a
	return '\t\t\t"%s"\n\t\t\t{\n\t\t\t\t"activators"\n\t\t\t\t{\n\t\t\t\t\t"Full_Press"\n\t\t\t\t\t{\n\t\t\t\t\t\t"bindings"\n\t\t\t\t\t\t{\n%s\t\t\t\t\t\t}\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t}\n' % [input, b]


func _group(id: int, mode: String, inputs: String, game_action := "") -> String:
	var ga := ""
	if game_action != "":
		ga = '\t\t"gameactions"\n\t\t{\n\t\t\t"Game"\t\t"%s"\n\t\t}\n' % game_action
	return '\t"group"\n\t{\n\t\t"id"\t\t"%d"\n\t\t"mode"\t\t"%s"\n\t\t"name"\t\t""\n\t\t"description"\t\t""\n\t\t"inputs"\n\t\t{\n%s\t\t}\n%s\t}\n' % [id, mode, inputs, ga]


func _config(controller_type: String) -> String:
	var diamond := _press("button_x", ["arm_l"]) + _press("button_a", ["arm_r", "menu_select"]) + \
		_press("button_y", ["leg_l"]) + _press("button_b", ["leg_r", "menu_back"])
	var dpad := _press("dpad_north", ["menu_up"]) + _press("dpad_south", ["menu_down"]) + \
		_press("dpad_west", ["menu_left"]) + _press("dpad_east", ["menu_right"])
	# Start and Back: Steam names them button_escape (Start / Menu) and button_menu (Back / View).
	var switches := _press("button_escape", ["lock"]) + _press("button_menu", ["pause"])
	return '"controller_mappings"\n{\n\t"version"\t\t"3"\n\t"revision"\t\t"1"\n\t"title"\t\t"Top Dog"\n\t"description"\t\t"Top Dog default layout"\n' + \
		'\t"creator"\t\t"0"\n\t"progenitor"\t\t""\n\t"url"\t\t""\n\t"export_type"\t\t"unknown"\n\t"controller_type"\t\t"%s"\n' % controller_type + \
		'\t"major_revision"\t\t"0"\n\t"minor_revision"\t\t"0"\n\t"Timestamp"\t\t"0"\n' + \
		'\t"actions"\n\t{\n\t\t"Game"\n\t\t{\n\t\t\t"title"\t\t"#Set_Game"\n\t\t\t"legacy_set"\t\t"0"\n\t\t}\n\t}\n' + \
		'\t"action_layers"\n\t{\n\t}\n' + \
		'\t"localization"\n\t{\n\t\t"english"\n\t\t{\n\t\t\t"Set_Game"\t\t"Top Dog"\n\t\t}\n\t}\n' + \
		_group(0, "four_buttons", diamond) + _group(1, "dpad", dpad) + \
		_group(2, "joystick_move", "", "steer") + _group(3, "switches", switches) + \
		'\t"preset"\n\t{\n\t\t"id"\t\t"0"\n\t\t"name"\t\t"Game"\n\t\t"group_source_bindings"\n\t\t{\n' + \
		'\t\t\t"0"\t\t"button_diamond active"\n\t\t\t"1"\t\t"dpad active"\n\t\t\t"2"\t\t"left_joystick active"\n\t\t\t"3"\t\t"switch active"\n' + \
		'\t\t}\n\t}\n\t"settings"\n\t{\n\t}\n}\n'
