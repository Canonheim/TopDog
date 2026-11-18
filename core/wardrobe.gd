extends Node
## Saved cosmetic presets. Collision shapes and gameplay stats never change.
const SavePaths = preload("res://core/save_paths.gd")
const PUG = preload("res://models/defaultio.glb")
const SPIRAL = preload("res://models/practice_spiral_dog.glb")
const SKIN_NAMES = ["Porcelain", "Sand", "Honey", "Tan", "Copper", "Brown", "Deep", "Blue", "Green", "Pink"]
const SKINS = ["f6dfd1", "e5bb98", "c9905d", "af754a", "965936", "70432e", "422b25", "70cbe0", "99d06c", "ed9bc1"]
const SUIT_NAMES = ["Red", "Gold", "Blue", "Turquoise", "Pink", "Purple", "Green", "Orange", "Black", "White"]
const SUITS = ["f52236", "ffce28", "3264e8", "19c6bd", "ef398e", "8c47c7", "74bb35", "f58125", "252333", "f7f0dc"]
const EFFECTS = ["pickles", "confetti", "roses", "bills", "treasure", "treats", "underwear", "bullets", "pan", "food", "dog_toys", "watermelon", "luck", "autumn_leaves", "math", "sodas", "chocolates", "lipsticks", "space", "railroad_spikes", "lightning", "grass", "salt", "onions", "trash", "popcorn", "fries", "pizza_party", "sushi_roll", "breakfast_club", "pancakes", "pretzel_twist", "cheese_please", "candies", "gummy_bears", "ice_cream_social", "strawberry_fields", "citrus_splash", "banana_bonanza", "pineapple_express", "mushroom_mix", "coffee_break", "tea_time", "nuts_acorns", "game_night", "love_letters", "music_notes", "pencil_case", "playing_cards", "puzzle_pieces", "sewing_kit", "toolbox", "bats", "assorted_bugs", "pinecone_shower", "flower_power", "seashell_shuffle", "autumn_harvest", "birthday_bash", "bees"]
const EFFECT_NAMES = ["Pickles", "Confetti", "Roses", "Money", "Treasure", "Treats", "Underwear", "Bullets", "Pan", "Food", "Dog Toys", "Watermelon", "Luck", "Leaves", "Math", "Sodas", "Death by Chocolate", "Lipsticks", "Space", "Railroad Spikes", "Lightning", "Grass", "Salt", "Onions", "Trash", "Popcorn", "French Fries", "Pizza Party", "Sushi Roll", "Breakfast Club", "Pancakes", "Pretzel Twist", "Cheese Please", "Candies", "Gummy Bears", "Ice Cream Social", "Strawberry Fields", "Citrus Splash", "Banana Bonanza", "Pineapple Express", "Mushroom Mix", "Coffee Break", "Tea Time", "Nuts & Acorns", "Game Night", "Love Letters", "Music Notes", "Pencil Case", "Playing Cards", "Puzzle Pieces", "Sewing Kit", "Toolbox", "Bats", "Assorted Bugs", "Pinecone Shower", "Flower Power", "Seashell Shuffle", "Autumn Harvest", "Birthday Bash", "Bees"]
# Cosmetic tier metadata only: no entitlement/unlock system is implied.
const EFFECT_METADATA := {"bees":{"rarity":"common","available":true}, "popcorn":{"rarity":"common","available":true}, "fries":{"rarity":"common","available":true}, "pizza_party":{"rarity":"common","available":true}, "sushi_roll":{"rarity":"common","available":true}, "breakfast_club":{"rarity":"common","available":true}, "pancakes":{"rarity":"common","available":true}, "pretzel_twist":{"rarity":"common","available":true}, "cheese_please":{"rarity":"common","available":true}, "candies":{"rarity":"common","available":true}, "gummy_bears":{"rarity":"common","available":true}, "ice_cream_social":{"rarity":"common","available":true}, "strawberry_fields":{"rarity":"common","available":true}, "citrus_splash":{"rarity":"common","available":true}, "banana_bonanza":{"rarity":"common","available":true}, "pineapple_express":{"rarity":"common","available":true}, "mushroom_mix":{"rarity":"common","available":true}, "coffee_break":{"rarity":"common","available":true}, "tea_time":{"rarity":"common","available":true}, "nuts_acorns":{"rarity":"common","available":true}, "game_night":{"rarity":"common","available":true}, "love_letters":{"rarity":"common","available":true}, "music_notes":{"rarity":"common","available":true}, "pencil_case":{"rarity":"common","available":true}, "playing_cards":{"rarity":"common","available":true}, "puzzle_pieces":{"rarity":"common","available":true}, "sewing_kit":{"rarity":"common","available":true}, "toolbox":{"rarity":"common","available":true}, "bats":{"rarity":"common","available":true}, "assorted_bugs":{"rarity":"common","available":true}, "pinecone_shower":{"rarity":"common","available":true}, "flower_power":{"rarity":"common","available":true}, "seashell_shuffle":{"rarity":"common","available":true}, "autumn_harvest":{"rarity":"common","available":true}, "birthday_bash":{"rarity":"common","available":true}, "railroad_spikes":{"rarity":"rare","available":true,"attachment":"limbs"}, "lightning":{"available":true,"attachment":"highest_body_surface","lifetime":"transient"}}
const ATTACHED_EFFECTS := ["railroad_spikes", "lightning"]
var profiles: Array = []
var selected := 0
var save_error := ""

func _ready() -> void:
	load_profiles()

func clean(value: Variant) -> Dictionary:
	var p: Dictionary = value if value is Dictionary else {}
	# Standalone Cherry Bomb was retired into the ice-cream collection.
	var effect: Variant = p.get("effect", "confetti")
	if effect == "cherry_bomb": effect = "ice_cream_social"
	return {"head": clampi(int(p.get("head", 0)), 0, 1), "skin": clampi(int(p.get("skin", 1)), 0, SKINS.size()-1), "speedo": clampi(int(p.get("speedo", 0)), 0, SUITS.size()-1), "effect": effect if effect in EFFECTS else "confetti"}

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
