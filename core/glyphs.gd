class_name Glyphs
extends RefCounted
## GLYPHS: a bind -> its picture (Kenney Input Prompts, CC0, textures/input_prompts).
## The climber wears one on each hand and foot (the reference game's idea: the
## button IS on the limb), and menus can draw them beside words.

const DIR := "res://textures/input_prompts/"
const PAD := {
	JOY_BUTTON_A: "xbox/xbox_button_color_a", JOY_BUTTON_B: "xbox/xbox_button_color_b",
	JOY_BUTTON_X: "xbox/xbox_button_color_x", JOY_BUTTON_Y: "xbox/xbox_button_color_y",
	JOY_BUTTON_LEFT_SHOULDER: "xbox/xbox_lb", JOY_BUTTON_RIGHT_SHOULDER: "xbox/xbox_rb",
	JOY_BUTTON_START: "xbox/xbox_button_start", JOY_BUTTON_BACK: "xbox/xbox_button_back",
	JOY_BUTTON_LEFT_STICK: "xbox/xbox_ls", JOY_BUTTON_RIGHT_STICK: "xbox/xbox_rs",
}
const AXIS := {JOY_AXIS_TRIGGER_LEFT: "xbox/xbox_lt", JOY_AXIS_TRIGGER_RIGHT: "xbox/xbox_rt"}
const MOUSE := {MOUSE_BUTTON_LEFT: "keyboard/mouse_left", MOUSE_BUTTON_RIGHT: "keyboard/mouse_right", MOUSE_BUTTON_MIDDLE: "keyboard/mouse_scroll"}

static var _cache := {}


## The picture for a bind dictionary ({"key"} / {"mouse"} / {"pad"} / {"axis"}), or null.
static func texture_for(b: Dictionary) -> Texture2D:
	var name := ""
	if b.has("pad"):
		name = PAD.get(b.pad, "")
	elif b.has("axis"):
		name = AXIS.get(b.axis, "")
	elif b.has("mouse"):
		name = MOUSE.get(b.mouse, "")
	elif b.has("key"):
		var k := OS.get_keycode_string(b.key).to_lower().replace(" ", "_")
		name = "keyboard/keyboard_" + k
	if name == "":
		return null
	if _cache.has(name):
		return _cache[name]
	var path := DIR + name + ".png"
	var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_cache[name] = tex
	return tex


## The four limb glyphs for a local player slot: [{"tex": Texture2D or null, "text": String}] in
## limb order (arm_l, arm_r, leg_l, leg_r), from that player's own device's binds.
static func limb_glyphs(slot: int) -> Array:
	var out: Array = []
	if slot < 0 or slot >= Players.slots.size():
		return out
	var scheme := "kbm" if int(Players.slots[slot].device) == Players.KBM else "pad"
	for i in 4:
		var binds: Array = Players.binds[scheme].get(Players.ACTIONS[i], [{}, {}])
		var b: Dictionary = binds[0] if not (binds[0] as Dictionary).is_empty() else binds[1]
		out.append({"tex": texture_for(b), "text": Players.bind_label(b)})
	return out
