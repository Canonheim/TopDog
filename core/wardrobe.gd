extends Node
## Saved cosmetic presets. Collision shapes and gameplay stats never change.
const SavePaths = preload("res://core/save_paths.gd")
const PUG = preload("res://models/defaultio.glb")
const SPIRAL = preload("res://models/practice_spiral_dog.glb")
const SKIN_NAMES = ["Porcelain", "Sand", "Honey", "Tan", "Copper", "Brown", "Deep", "Blue", "Green", "Pink"]
const SKINS = ["f6dfd1", "e5bb98", "c9905d", "af754a", "965936", "70432e", "422b25", "70cbe0", "99d06c", "ed9bc1"]
const SUIT_NAMES = ["Red", "Gold", "Blue", "Turquoise", "Pink", "Purple", "Green", "Orange", "Black", "White"]
const SUITS = ["f52236", "ffce28", "3264e8", "19c6bd", "ef398e", "8c47c7", "74bb35", "f58125", "252333", "f7f0dc"]
var profiles: Array = []
var selected := 0
var save_error := ""

func _ready() -> void:
	load_profiles()

func clean(value: Variant) -> Dictionary:
	var p: Dictionary = value if value is Dictionary else {}
	return {"head": clampi(int(p.get("head", 0)), 0, 1), "skin": clampi(int(p.get("skin", 1)), 0, SKINS.size()-1), "speedo": clampi(int(p.get("speedo", 0)), 0, SUITS.size()-1), "effect": "confetti"}

func load_profiles() -> void:
	profiles.clear()
	var cfg := ConfigFile.new()
	if cfg.load(SavePaths.settings("climbers.cfg")) == OK:
		var saved: Variant = cfg.get_value("wardrobe", "profiles", [])
		if saved is Array:
			for p in saved.slice(0, 100):
				profiles.append(clean(p))
		selected = int(cfg.get_value("wardrobe", "selected", 0))
	if profiles.is_empty():
		profiles.append(clean({}))
	selected = clampi(selected, 0, profiles.size()-1)

func save() -> bool:
	var cfg := ConfigFile.new()
	cfg.set_value("wardrobe", "profiles", profiles)
	cfg.set_value("wardrobe", "selected", selected)
	var err := cfg.save(SavePaths.settings("climbers.cfg"))
	save_error = "" if err == OK else "Could not save climbers. Please check folder permissions."
	return err == OK

func for_slot(slot: int) -> Dictionary:
	return profiles[posmod(selected + slot, profiles.size())].duplicate(true)

func model(p: Dictionary) -> PackedScene:
	return SPIRAL if int(p.get("head", 0)) == 1 else PUG

func apply(root: Node, value: Dictionary) -> void:
	var p := clean(value)
	# THE ONE MATERIAL: the skin's and the suit's atlas cells go to each piece as its own
	# per-instance texel (they were two materials per look).
	var skin: Vector2 = AtlasPalette.swatch(Color(SKINS[p.skin])).uv
	var suit: Vector2 = AtlasPalette.swatch(Color(SUITS[p.speedo])).uv
	_apply_meshes(root, skin, suit)

func _apply_meshes(node: Node, skin: Vector2, suit: Vector2) -> void:
	if node is MeshInstance3D and node.name != "Head":
		# The pelvis is the speedo; keep the heads' atlas colours intact.
		if node.name in ["Pelvis", "Chest", "Navel", "L_Foot", "Foot", "L_Hand", "Hand", "Shoulder", "L_Shoulder", "Wrist", "L_Wrist", "Thigh", "L_Thigh", "Shin", "L_Shin"]:
			CelPass.paint_uv(node, suit if node.name == "Pelvis" else skin)
	for child in node.get_children():
		_apply_meshes(child, skin, suit)
