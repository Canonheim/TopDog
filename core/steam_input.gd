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
const DIGITAL := ["fart", "arm_l", "arm_r", "leg_l", "leg_r", "lock", "pause", "menu_up", "menu_down", "menu_left", "menu_right", "menu_select", "menu_back"]
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
		Players.note("Steam Input failed to start: raw pads only")
		return
	# From this moment Steam may hold the pads: whatever a raw pad has down right now
	# (the A that just clicked PLAY ONLINE) can never be seen coming up.
	Players.suspect_raw("Steam Input started")
	Players.note("Steam Input started (layout file %s)" % ("accepted" if manifest_accepted else "REFUSED"))
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


## THE GRACE TIMES (the 11-10 input rewrite: no blip may drop a held limb).
## HOLD_MS: an action Steam reports "inactive" keeps its last state this long. Steam
## flickers actions inactive for a frame or two when it reloads a layout or the
## overlay stirs; without the hold a held hand let go by itself.
## FORGET_MS: a controller missing from Steam's list this long is really gone (the
## list can come back empty for a poll while Steam reshuffles).
## LIVE_MS: "our layout is live on this controller" stays true this long after the
## last frame it was, so the raw-pad fallback doesn't flap on and off.
const HOLD_MS := 250
const FORGET_MS := 1600
const LIVE_MS := 1500
const LIMBS := ["arm_l", "arm_r", "leg_l", "leg_r"]


func _process(delta: float) -> void:
	if not ok:
		return
	var now := Time.get_ticks_msec()
	# The controller list twice a second, not every frame (GodotSteam logs each call).
	_list_t -= delta
	if _list_t <= 0.0:
		_list_t = 0.5
		_handles = Steam.getConnectedControllers()
		# The manifest can finish loading after an invite or overlay handoff.
		if set_handle == 0:
			set_handle = int(Steam.getActionSetHandle(ACTION_SET))
		if steer_handle == 0:
			steer_handle = int(Steam.getAnalogActionHandle("steer"))
		for action in DIGITAL:
			if digital_handles.get(action, 0) == 0:
				digital_handles[action] = int(Steam.getDigitalActionHandle(action))
		for h in _handles:
			var handle := int(h)
			if handle == 0:
				continue
			if not _order.has(handle):
				var free_at := _order.find(0)  # a forgotten controller's place is reused: ids stay under 3100
				if free_at >= 0:
					_order[free_at] = handle
				else:
					_order.append(handle)
			var dev := STEAM_DEV_BASE + _order.find(handle)
			if not devices.has(dev):
				devices[dev] = {"handle": handle, "type": int(Steam.getInputTypeForHandle(handle)), "buttons": {}, "stick": Vector2.ZERO,
					"gameplay_active": false, "menu_active": false,
					"gamepad_index": Steam.getGamepadIndexForController(handle) if Steam.has_method("getGamepadIndexForController") else -1}
				Players.note("steam controller %d appears (%s)" % [dev, _type_name(int(devices[dev].type))])
			devices[dev].listed_ms = now
		for dev in devices.keys():
			if (devices[dev] as Dictionary).has("handle") and now - int(devices[dev].get("listed_ms", now)) > FORGET_MS:
				Players.note("steam controller %d is gone" % dev)
				var at := _order.find(int(devices[dev].handle))
				if at >= 0:
					_order[at] = 0
				devices.erase(dev)
	for dev in devices.keys():
		var d: Dictionary = devices[dev]
		if not d.has("handle"):
			continue  # a battery's hand-made device
		_read(dev, d, now)


## One controller, one frame: every action through the hold, the sticky live flags,
## and a latch so a press between two physics ticks is still seen by one.
func _read(dev: int, d: Dictionary, now: int) -> void:
	var handle := int(d.handle)
	if set_handle != 0:
		Steam.activateActionSet(handle, set_handle)
	var limbs_active := false
	var menu_active := false
	for a in DIGITAL:
		var dd: Dictionary = Steam.getDigitalActionData(handle, digital_handles.get(a, 0))
		var active := bool(dd.get("active", false))
		if a in LIMBS:
			limbs_active = limbs_active or active
		if a == "menu_select":
			menu_active = active
		if feed_digital(d, a, active, bool(dd.get("state", false)), now):
			_note(dev, a)
	var ad: Dictionary = Steam.getAnalogActionData(handle, steer_handle)
	var steer_active := bool(ad.get("active", false))
	feed_steer(d, steer_active, Vector2(float(ad.get("x", 0.0)), float(ad.get("y", 0.0))), now)  # Steam's joystick y is up, as ours
	feed_flags(dev, d, limbs_active and steer_active, menu_active, now)
	if (d.stick as Vector2).length() > Players.GLYPH_STICK and Players.last_device != dev:
		_note(dev, "stick")


## THE HOLD, one button (no Steam calls: the batteries drive these three directly).
## Active: Steam's state is the truth. Inactive: the last state stands for HOLD_MS,
## then it's up. True on a fresh press (and the press is latched for one tick).
func feed_digital(d: Dictionary, a: String, active: bool, state: bool, now: int) -> bool:
	if not d.has("act_ms"):
		d.act_ms = {}
		d.latch_next = {}
		d.latch = {}
	if not d.has("buttons"):
		d.buttons = {}
	var was := bool(d.buttons.get(a, false))
	var down := was
	if active:
		down = state
		d.act_ms[a] = now
	elif now - int(d.act_ms.get(a, -1000000)) > HOLD_MS:
		down = false
	d.buttons[a] = down
	if down and not was:
		d.latch_next[a] = true
		return true
	return false


## THE HOLD, the stick.
func feed_steer(d: Dictionary, active: bool, value: Vector2, now: int) -> void:
	if active:
		d.stick = value
		d.steer_ms = now
	elif now - int(d.get("steer_ms", -1000000)) > HOLD_MS:
		d.stick = Vector2.ZERO


## The sticky flags: "our layout is live here" outlasts a blip by LIVE_MS.
func feed_flags(dev: int, d: Dictionary, game_active: bool, menu_active: bool, now: int) -> void:
	if game_active:
		d.game_ms = now
	var live := now - int(d.get("game_ms", -1000000)) <= LIVE_MS
	if live != bool(d.get("gameplay_active", false)):
		Players.note("steam controller %d: our layout is %s" % [dev, "LIVE" if live else "NOT ACTIVE (overlay open, window unfocused, or another layout)"])
	d.gameplay_active = live
	if menu_active:
		d.menu_ms = now
	d.menu_active = now - int(d.get("menu_ms", -1000000)) <= LIVE_MS


## Players calls this at the top of each physics tick: the presses latched since the
## last tick become readable for exactly this one.
func tick_latch() -> void:
	for d: Dictionary in devices.values():
		if d.has("latch_next"):
			d.latch = d.latch_next
			d.latch_next = {}


func active_devices(flag: String) -> Array:
	return devices.keys().filter(func(dev): return devices[dev].get(flag, true))


func _note(dev: int, what: String) -> void:
	last_dev = dev
	last_action = what
	Players.note_device(dev)


func button(dev: int, action: String) -> bool:
	var d: Dictionary = devices.get(dev, {})
	return bool(d.get("buttons", {}).get(action, false)) or bool(d.get("latch", {}).get(action, false))


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
	var names := {"fart": "Fart", "arm_l": "Left hand", "arm_r": "Right hand", "leg_l": "Left foot", "leg_r": "Right foot", "lock": "Lock in", "pause": "Pause",
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


## Steam's source names: the LEFT stick is "joystick" (the right is "right_joystick").
## "left_joystick" is not a source: Steam dropped the binding silently and the
## stick read nothing online (found 11-07 with getAnalogActionOrigins: []).
func _config(controller_type: String) -> String:
	var diamond := _press("button_x", ["arm_l"]) + _press("button_a", ["arm_r", "menu_select"]) + \
		_press("button_y", ["leg_l"]) + _press("button_b", ["leg_r", "menu_back"])
	var dpad := _press("dpad_north", ["menu_up"]) + _press("dpad_south", ["menu_down"]) + \
		_press("dpad_west", ["menu_left"]) + _press("dpad_east", ["menu_right"])
	# Start and Back: Steam names them button_escape (Start / Menu) and button_menu (Back / View).
	var switches := _press("right_bumper", ["fart"]) + _press("button_escape", ["lock"]) + _press("button_menu", ["pause"])
	return '"controller_mappings"\n{\n\t"version"\t\t"3"\n\t"revision"\t\t"1"\n\t"title"\t\t"Top Dog"\n\t"description"\t\t"Top Dog default layout"\n' + \
		'\t"creator"\t\t"0"\n\t"progenitor"\t\t""\n\t"url"\t\t""\n\t"export_type"\t\t"unknown"\n\t"controller_type"\t\t"%s"\n' % controller_type + \
		'\t"major_revision"\t\t"0"\n\t"minor_revision"\t\t"0"\n\t"Timestamp"\t\t"0"\n' + \
		'\t"actions"\n\t{\n\t\t"Game"\n\t\t{\n\t\t\t"title"\t\t"#Set_Game"\n\t\t\t"legacy_set"\t\t"0"\n\t\t}\n\t}\n' + \
		'\t"action_layers"\n\t{\n\t}\n' + \
		'\t"localization"\n\t{\n\t\t"english"\n\t\t{\n\t\t\t"Set_Game"\t\t"Top Dog"\n\t\t}\n\t}\n' + \
		_group(0, "four_buttons", diamond) + _group(1, "dpad", dpad) + \
		_group(2, "joystick_move", "", "steer") + _group(3, "switches", switches) + \
		'\t"preset"\n\t{\n\t\t"id"\t\t"0"\n\t\t"name"\t\t"Game"\n\t\t"group_source_bindings"\n\t\t{\n' + \
		'\t\t\t"0"\t\t"button_diamond active"\n\t\t\t"1"\t\t"dpad active"\n\t\t\t"2"\t\t"joystick active"\n\t\t\t"3"\t\t"switch active"\n' + \
		'\t\t}\n\t}\n\t"settings"\n\t{\n\t}\n}\n'
