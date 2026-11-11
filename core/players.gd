extends Node
## PLAYERS: the local players and their devices. Autoload "Players".
##
## THE INPUT LAW (the 11-10 rewrite, after a client's pad "randomly stopped working"):
## no single thing may ever silence a player.
##
## 1. A fixed slot owns ONE device: the keyboard-and-mouse (device -1), one raw pad
##    (its joypad id), one Steam controller (3000 + n) or a test pad (1000 + n).
## 2. The ANY slot (Practice, every online player) reads EVERYTHING on the machine
##    at once: the keyboard, every raw pad, every Steam controller. Buttons are
##    OR'd. Nothing is switched by "who spoke last": a Discord push-to-talk key, a
##    bumped mouse or a drifting stick on a second pad can't take the controls away.
## 3. WHO HOLDS A LIMB AIMS IT: a limb held by a pad's button is steered by that pad's
##    stick; a limb held by a key is steered by the mouse. Never the other way round.
## 4. Raw pads are read from Godot's polled state behind THE STALE GUARD (below), so a
##    button that was down when Steam took the pad can't stay "held", and a pad Steam
##    does NOT manage keeps working while Steam is live.
## 5. A press shorter than a frame is LATCHED: one physics tick always sees it.
## 6. A slot index that doesn't exist reads the whole machine (one local player) so a
##    climber is never left without a driver.
## 7. Every device event is written to user://input_log.txt (and health() for the F2
##    overlay), so the next "it stopped working" can be read, not guessed.
##
## last_device is kept for the GLYPHS only (which button pictures to show).
##
## Limb order: 0 arm_l, 1 arm_r, 2 leg_l, 3 leg_r (screen sides), then 4 = Lock In.

signal joined(slot: int)
signal left(slot: int)
## An ANY-device slot's glyph device changed (the player picked up the pad, or went
## back to the keyboard): glyphs follow it. Never used for reading input.
signal device_changed(slot: int)

const KBM := -1
## The one-player slot: every device on this machine drives it (Practice, Online).
const ANY := -2
const NO_DEVICE := -99
const ACTIONS := ["arm_l", "arm_r", "leg_l", "leg_r", "lock", "pause"]
const ACTION_NAMES := ["Left hand", "Right hand", "Left foot", "Right foot", "Lock in", "Pause"]
const MAX_LOCAL := 8
## A stick or mouse move this firm counts as "this player is on that device now",
## for the glyphs (a drifting stick or a nudged mouse doesn't flip them).
const GLYPH_STICK := 0.5
const GLYPH_MOUSE_PX := 12.0
const LOG_PATH := "user://input_log.txt"
const LOG_KEEP := 300

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

## The device that spoke last: KBM or a pad id. FOR THE GLYPHS ONLY.
var last_device := KBM
## False while the game window has lost the focus (Steam hands the pad to its desktop
## layout then, and the keyboard goes to the other window): main shows a notice.
var focused := true

## THE STALE GUARD (Parker 11-09: "the A button on my controller is being registered
## as always held in game, when I am not holding it"): when Steam Input takes a pad,
## Godot stops hearing from it, so whatever was down at that moment stays "down" in
## Godot's state for ever. Each time Steam takes or lists a controller, every raw
## button that is down and every raw axis off centre is marked SUSPECT, and ignored
## until Godot hears from it again (an event, or the polled value changing). A pad
## Steam really took never speaks again and stays ignored; a pad Steam doesn't manage
## speaks on its next move and carries on.
var _suspect_buttons := {}  # Vector2i(dev, button) -> true
var _suspect_axes := {}  # Vector2i(dev, axis) -> the frozen value
var _seen_pads := {}  # raw pads that have spoken through events (listed by Godot or not)
## THE LATCH: presses that arrived as events since the last physics tick. The next
## tick reads them as down even if the button is already up again (a tap shorter
## than a frame, a slow frame): no press is ever lost between polls.
var _latch_next := {}
var _latch := {}
var _steam_ids: Array = []
var _steam_was_live := false

var _lock_prev := {}
var _lock_edge := {}
var _pause_prev := {}
var _pause_edge := {}

var _log: Array = []
var _log_file: FileAccess = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # the pause button must work while paused
	process_physics_priority = -100
	process_priority = -100
	binds.kbm = DEFAULT_KBM.duplicate(true)
	binds.pad = DEFAULT_PAD.duplicate(true)
	_load()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_log_file = FileAccess.open(LOG_PATH, FileAccess.WRITE)
	var names: Array = []
	for d in Input.get_connected_joypads():
		names.append("%d %s" % [d, Input.get_joy_name(d)])
	note("input log starts. raw pads: %s" % [names if not names.is_empty() else "none"])


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		focused = false
		_latch.clear()
		_latch_next.clear()
		note("the game window LOST FOCUS (keys go elsewhere; Steam gives pads its desktop layout)")
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		focused = true
		note("the game window has the focus again")


## One line in the input log: the F2 overlay shows the last few, and the whole
## session is in user://input_log.txt for when something goes wrong.
func note(text: String) -> void:
	var line := "%8.2f  %s" % [Time.get_ticks_msec() / 1000.0, text]
	_log.append(line)
	if _log.size() > LOG_KEEP:
		_log.pop_front()
	if _log_file != null:
		_log_file.store_line(line)
		_log_file.flush()


func _input(event: InputEvent) -> void:
	var dev := NO_DEVICE
	if event is InputEventJoypadButton:
		var jb := event as InputEventJoypadButton
		_seen_pads[jb.device] = true
		_suspect_buttons.erase(Vector2i(jb.device, jb.button_index))  # it speaks: it's live
		if jb.pressed:
			_latch_next["p:%d:%d" % [jb.device, jb.button_index]] = true
			dev = jb.device
	elif event is InputEventJoypadMotion:
		var jm := event as InputEventJoypadMotion
		_seen_pads[jm.device] = true
		var key := Vector2i(jm.device, jm.axis)
		if _suspect_axes.has(key) and jm.axis_value != float(_suspect_axes[key]):
			_suspect_axes.erase(key)
		if absf(jm.axis_value) > GLYPH_STICK and jm.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y]:
			dev = jm.device
	elif event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and not k.echo:
			_latch_next["k:%d" % k.physical_keycode] = true
			dev = KBM
	elif event is InputEventMouseButton:
		if (event as InputEventMouseButton).pressed:
			_latch_next["m:%d" % (event as InputEventMouseButton).button_index] = true
			dev = KBM
	elif event is InputEventMouseMotion and (event as InputEventMouseMotion).relative.length() > GLYPH_MOUSE_PX:
		dev = KBM
	if dev != NO_DEVICE:
		note_device(dev)


## The device whose glyphs an ANY slot shows right now (its own device for a fixed slot).
func effective_device(slot: int) -> int:
	if slot < 0 or slot >= slots.size():
		return KBM
	var d := int(slots[slot].device)
	return last_device if d == ANY else d


func _physics_process(_delta: float) -> void:
	_latch = _latch_next
	_latch_next = {}
	var si = _si()
	if si != null:
		si.tick_latch()
	_watch_steam()
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


## Steam taking or listing a controller is the moment raw state can go stale.
func _watch_steam() -> void:
	var ids := _steam_all()
	ids.sort()
	var live := _steam_live()
	if ids == _steam_ids and live == _steam_was_live:
		return
	note("steam controllers %s, our layout %s" % [ids, "LIVE" if live else "not active"])
	if (live and not _steam_was_live) or ids.size() > _steam_ids.size():
		suspect_raw("Steam took a controller")
	_steam_ids = ids
	_steam_was_live = live


## THE STALE GUARD's mark: everything a raw pad holds down right now is ignored until
## Godot hears from it again.
func suspect_raw(why: String) -> void:
	var n := 0
	for dev in _raw_pads():
		for b in JOY_BUTTON_MAX:
			if Input.is_joy_button_pressed(dev, b):
				_suspect_buttons[Vector2i(dev, b)] = true
				n += 1
		for axis in JOY_AXIS_MAX:
			var v := Input.get_joy_axis(dev, axis)
			if absf(v) > 0.05:
				_suspect_axes[Vector2i(dev, axis)] = v
				n += 1
	if n > 0:
		note("stale guard: %d raw inputs were down when %s; ignored until they change" % [n, why])


## A raw pad's button, through the stale guard (and the latch).
func raw_button(dev: int, button: int) -> bool:
	if _latch.has("p:%d:%d" % [dev, button]):
		return true
	if not Input.is_joy_button_pressed(dev, button):
		if not _suspect_buttons.is_empty():
			_suspect_buttons.erase(Vector2i(dev, button))  # it came up: whatever it was, it's over
		return false
	return not _suspect_buttons.has(Vector2i(dev, button))


## A raw pad's axis, through the stale guard.
func raw_axis(dev: int, axis: int) -> float:
	var v := Input.get_joy_axis(dev, axis)
	if not _suspect_axes.is_empty():
		var key := Vector2i(dev, axis)
		if _suspect_axes.has(key):
			if v == float(_suspect_axes[key]):
				return 0.0
			_suspect_axes.erase(key)
	return v


# ---------------------------------------------------------------- slots

## Invites can connect before any menu creates a player. A solo online climber
## reads every device on the machine while keeping its roster index and identity.
func prepare_online(pname: String) -> void:
	if slots.is_empty():
		add_online_player(pname)
	elif slots.size() == 1:
		slots[0].device = ANY
		slots[0].erase("native_pad")
		slots[0].erase("disconnected")
		device_changed.emit(0)
	note("online: %d local player%s, %s" % [slots.size(), "" if slots.size() == 1 else "s", slots.map(func(sl): return device_label(int(sl.device)))])
	_refresh_pad_routes()


## When several local players join online, preserve distinct slots as Steam
## takes over the physical pads. Keep their native IDs for fallback on disconnect.
func _refresh_pad_routes() -> void:
	if slots.is_empty() or (slots.size() == 1 and slots[0].device == ANY):
		return
	var si = _si()
	if si == null:
		return
	var available := steam_devices()
	available.sort()
	for slot in slots:
		if slot.has("native_pad") and not available.has(slot.device):
			note("steam controller %s went away: its player is back on raw pad %s" % [slot.device, slot.native_pad])
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
				if (si.devices.get(dev, {}) as Dictionary).get("gamepad_index", -1) == raw:
					route = dev
					break
			if route < 0:
				if exact_match:
					continue
				route = available.front()
			slot.native_pad = raw
			slot.device = route
			available.erase(route)
			note("player %d: raw pad %d is steam controller %d now" % [s + 1, raw, route])
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
	if device >= 0 and device < 1000:
		slots[s].pad_guid = Input.get_joy_guid(device) if Input.get_connected_joypads().has(device) else ""
	note("player %d joins on %s" % [s + 1, device_label(device)])
	joined.emit(s)
	return s


func remove_player(s: int) -> void:
	if s < 0 or s >= slots.size():
		return
	slots.remove_at(s)
	_lock_prev.clear()
	_lock_edge.clear()
	_pause_prev.clear()
	_pause_edge.clear()
	note("player %d removed (%d left)" % [s + 1, slots.size()])
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


## THE DRIVER'S SLOT (law 6): the local slot that drives a climber this machine owns.
## `want` is the roster's slot index, `ordinal` this climber's place among the
## machine's own roster entries. A machine with no slot gets one (every device); an
## index that isn't there falls back to the ordinal, and is logged.
func resolve_slot(want: int, ordinal := 0) -> int:
	if slots.is_empty():
		add_player(ANY)
		note("a climber needed a driver and no local player existed: made one (every device)")
	if want >= 0 and want < slots.size():
		return want
	var s := clampi(ordinal, 0, slots.size() - 1)
	note("roster slot %d doesn't exist here (%d local): driven by local player %d" % [want, slots.size(), s + 1])
	return s


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
			note("player %d pinned to %s (a second device joined)" % [any_slot + 1, device_label(primary)])
			device_changed.emit(any_slot)
		return dev
	return -2


## The devices a NEW fixed-slot player can join on: while Steam has the pads, only
## its controllers (a raw pad and its Steam twin must not join as two players).
func devices() -> Array:
	var out: Array = [KBM]
	if not _steam_live():
		out.append_array(_raw_pads())
	out.append_array(steam_devices())
	out.append_array(fake.keys())
	return out


func _si():
	return Net.steam_input if Net.get("steam_input") != null else null


## Steam controllers our layout is live on (when Steam is running).
func steam_devices() -> Array:
	var si = _si()
	return si.active_devices("gameplay_active") if si != null else []


## Every controller Steam lists, live layout or not.
func _steam_all() -> Array:
	var si = _si()
	return si.devices.keys() if si != null else []


func _is_steam_dev(dev: int) -> bool:
	return dev >= 3000 and dev < 3100


func _steam_live() -> bool:
	return not steam_devices().is_empty()


## Raw pads: the ones Godot lists, and any that have spoken through events.
func _raw_pads() -> Array:
	var pads: Array = Input.get_connected_joypads()
	for dev in _seen_pads:
		if not pads.has(dev):
			pads.append(dev)
	return pads


## Every pad of every kind: what the ANY slot reads.
func _all_pads() -> Array:
	var out: Array = _raw_pads()
	out.append_array(_steam_all())
	out.append_array(fake.keys())
	return out


## A device spoke: the ANY slot's GLYPHS follow it (reads never do).
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

## The device a slot reads. A slot that doesn't exist reads the whole machine when
## the machine has at most one local player (law 6), and nothing otherwise.
func _dev(s: int) -> int:
	if s >= 0 and s < slots.size():
		return int(slots[s].device)
	return ANY if slots.size() <= 1 else NO_DEVICE


func _edge_slot(s: int) -> int:
	return 0 if (s < 0 or s >= slots.size()) and slots.size() == 1 else s


func limb_held(s: int, limb: int) -> bool:
	return _action(_dev(s), ACTIONS[limb])


func fart_held(s: int) -> bool:
	return _action(_dev(s), "fart")


func lock_pressed(s: int) -> bool:
	s = _edge_slot(s)
	var e: bool = _lock_edge.get(s, false)
	_lock_edge[s] = false
	return e


func pause_pressed(s: int) -> bool:
	s = _edge_slot(s)
	var e: bool = _pause_edge.get(s, false)
	_pause_edge[s] = false
	return e


## WHO HOLDS A LIMB AIMS IT (law 3). A fixed pad aims with its LEFT stick, the
## keyboard player with the mouse on the play plane. The ANY slot: the pads holding
## this limb's button steer it with their stick (the firmest push wins; a centred
## stick holds the pose); held by a key only, the mouse steers it.
func limb_aim(s: int, _climber, limb: int):
	var dev := _dev(s)
	if dev == NO_DEVICE:
		return null
	if dev == KBM:
		return _mouse_aim()
	if dev != ANY:
		return _stick_aim(stick(dev))
	var action: String = ACTIONS[limb]
	var best := Vector2.ZERO
	var pad_holds := false
	for p in _all_pads():
		if _action(p, action):
			pad_holds = true
			var st := stick(p)
			if st.length() > best.length():
				best = st
	if pad_holds:
		return _stick_aim(best)
	if _action(KBM, action):
		return _mouse_aim()
	return _stick_aim(stick(ANY))  # nobody holds it this instant: any firm stick, else the pose


func _stick_aim(st: Vector2):
	if st.length() < Feel.get_k("stick_deadzone"):
		return null  # the hand stays where it was steered
	return {"dir": st.normalized(), "mag": minf(st.length(), 1.0)}  # the push is the reach


## The device's stick, y-up, radial deadzone left to the caller. ANY: the firmest
## push of any pad on the machine.
func stick(dev: int) -> Vector2:
	if dev == ANY:
		var best := Vector2.ZERO
		for p in _all_pads():
			var st := stick(p)
			if st.length() > best.length():
				best = st
		return best
	if dev == KBM or dev == NO_DEVICE:
		return Vector2.ZERO
	if _is_steam_dev(dev):
		var si = _si()
		return si.stick(dev) if si != null else Vector2.ZERO
	if fake.has(dev):
		return fake[dev].get("stick", Vector2.ZERO)
	# The LEFT stick steers; the right stick does nothing (Parker 2026-11-07).
	return Vector2(raw_axis(dev, JOY_AXIS_LEFT_X), -raw_axis(dev, JOY_AXIS_LEFT_Y))


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
	if dev == NO_DEVICE:
		return false
	if dev == ANY:
		if _action(KBM, action):
			return true
		for p in _all_pads():
			if _action(p, action):
				return true
		return false
	if _is_steam_dev(dev):
		var si = _si()
		return si != null and si.button(dev, action)
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
		return dev == KBM and (Input.is_physical_key_pressed(b.key) or _latch.has("k:%d" % int(b.key)))
	if b.has("mouse"):
		return dev == KBM and (Input.is_mouse_button_pressed(b.mouse) or _latch.has("m:%d" % int(b.mouse)))
	if dev == KBM:
		return false
	if b.has("pad"):
		return raw_button(dev, b.pad)
	if b.has("axis"):
		return raw_axis(dev, b.axis) >= Feel.get_k("trigger_press")
	return false


# ---------------------------------------------------------------- the readout

## What the input system knows right now (the F2 overlay, and the Controls screen).
func health() -> String:
	var lines: Array = []
	lines.append("WINDOW: %s" % ("focused" if focused else "NOT FOCUSED - click the game"))
	var raws: Array = []
	for d in _raw_pads():
		raws.append("%d %s" % [d, Input.get_joy_name(d) if Input.get_joy_name(d) != "" else "(events only)"])
	lines.append("RAW PADS: %s" % (", ".join(raws) if not raws.is_empty() else "none"))
	var si = _si()
	if si == null:
		lines.append("STEAM INPUT: not started")
	else:
		var parts: Array = []
		for d in si.devices:
			var e: Dictionary = si.devices[d]
			parts.append("%d %s" % [d, "live" if e.get("gameplay_active", false) else "layout NOT active"])
		lines.append("STEAM INPUT: %s%s" % [", ".join(parts) if not parts.is_empty() else "no controllers", "" if si.manifest_accepted or not si.ok else "  (layout file refused)"])
	for s in slots.size():
		var d := int(slots[s].device)
		var held: Array = []
		for i in 4:
			if _action(d, ACTIONS[i]):
				held.append(ACTIONS[i])
		lines.append("PLAYER %d: %s%s  held %s  stick %s" % [s + 1, device_label(d), "  (glyphs: %s)" % device_label(last_device) if d == ANY else "", held, stick(d).snapped(Vector2(0.01, 0.01))])
	if not _suspect_buttons.is_empty() or not _suspect_axes.is_empty():
		lines.append("STALE GUARD: ignoring %d raw buttons, %d raw axes" % [_suspect_buttons.size(), _suspect_axes.size()])
	for l in _log.slice(maxi(0, _log.size() - 5)):
		lines.append(l)
	return "\n".join(lines)


# ---------------------------------------------------------------- rebinding

func set_bind(scheme: String, action: String, index: int, b: Dictionary) -> void:
	var list: Array = binds[scheme][action]
	# One input, one action. An input already bound elsewhere in the scheme SWAPS
	# (Parker 11-10: "a key that is bound over another one swaps it"): that slot takes
	# this slot's old input.
	var old: Dictionary = list[index]
	if not b.is_empty():
		for a in binds[scheme]:
			for i in binds[scheme][a].size():
				if binds[scheme][a][i] == b and not (a == action and i == index):
					binds[scheme][a][i] = old
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

## A pad was plugged in or pulled. Unplugged: its guard marks go, its fixed slot is
## flagged, its queued presses are dropped. Plugged in: a disconnected fixed slot gets
## it back (matching GUIDs first; a single missing pad also accepts a replacement).
func _on_joy_connection_changed(dev: int, connected: bool) -> void:
	note("raw pad %d %s%s" % [dev, "CONNECTED" if connected else "DISCONNECTED", (" (" + Input.get_joy_name(dev) + ")") if connected else ""])
	if not connected:
		_seen_pads.erase(dev)
		for table in [_suspect_buttons, _suspect_axes]:
			for key: Vector2i in table.keys():
				if key.x == dev:
					table.erase(key)
		for s in slots.size():
			if int(slots[s].get("native_pad", slots[s].device)) == dev:
				slots[s].disconnected = true
				_lock_prev.erase(s)
				_lock_edge.erase(s)
				_pause_prev.erase(s)
				_pause_edge.erase(s)
		if last_device == dev:
			note_device(KBM)
		return
	if slot_of_device(dev) >= 0 and not slots[slot_of_device(dev)].get("disconnected", false):
		return
	var missing: Array = []
	for s in slots.size():
		if slots[s].get("disconnected", false):
			missing.append(s)
	var guid := Input.get_joy_guid(dev) if Input.get_connected_joypads().has(dev) else ""
	var selected := -1
	for s in missing:
		if guid != "" and slots[s].get("pad_guid", "") == guid:
			selected = s
			break
	if selected < 0 and missing.size() == 1:
		selected = missing[0]
	if selected >= 0:
		var slot: Dictionary = slots[selected]
		slot.device = dev
		slot.pad_guid = guid
		slot.erase("native_pad")
		slot.erase("disconnected")
		note("player %d has pad %d back" % [selected + 1, dev])
		device_changed.emit(selected)
