extends Node
## Saved cosmetic presets. Collision shapes and gameplay stats never change.
const SavePaths = preload("res://core/save_paths.gd")
## THE NEW CLIMBER (Parker 11-18: "the new character model that will replace
## defaultio"): the body every player wears.
const CLIMBER = preload("res://models/character_cufinalt.glb")
## Defaultio's two heads, worn on the new climber's neck as placeholders (Parker 11-18:
## "There will be may more heads coming in for him in the future, so you can use the
## place holder pug and spiral heads for now too, those are also place holder though").
const PUG = preload("res://models/defaultio.glb")
const SPIRAL = preload("res://models/practice_spiral_dog.glb")
## HEAD: his own first, then the placeholders. A new head is a glb with a "Head" piece
## modelled on his neck (his neck's top is at 1.70 m), added here with its name.
const HEAD_NAMES = ["MOUSTACHE", "PUG", "SPIRAL"]
const HEAD_SCENES = [null, PUG, SPIRAL]
## THE NEW CLIMBER'S COLOURS (Parker 11-18: "make the skin customization tuned for
## this model"): SKIN recolours his skin and its darker muscle lines, SPEEDO his trunks
## and their shade, each shade kept at the model's own ratio to its colour. His hair and
## moustache keep their browns. These are the four atlas colours the model is painted in.
const CLIMBER_SKIN := Color("cdaf7e")
const CLIMBER_SKIN_SHADE := Color("af9069")
const CLIMBER_SUIT := Color("423c38")
const CLIMBER_SUIT_SHADE := Color("2d2826")
const _RECOLOUR := {"cdaf7e": 0, "af9069": 1, "423c38": 2, "2d2826": 3}
const SKIN_NAMES = ["Porcelain", "Sand", "Honey", "Tan", "Copper", "Brown", "Deep", "Blue", "Green", "Pink"]
const SKINS = ["f6dfd1", "e5bb98", "c9905d", "af754a", "965936", "70432e", "422b25", "70cbe0", "99d06c", "ed9bc1"]
const SUIT_NAMES = ["Red", "Gold", "Blue", "Turquoise", "Pink", "Purple", "Green", "Orange", "Black", "White"]
const SUITS = ["f52236", "ffce28", "3264e8", "19c6bd", "ef398e", "8c47c7", "74bb35", "f58125", "252333", "f7f0dc"]
const EFFECTS = ["pickles", "confetti", "roses", "bills", "treasure", "treats", "underwear", "bullets", "pan", "food", "dog_toys", "watermelon", "luck", "autumn_leaves", "math", "sodas", "chocolates", "lipsticks", "space", "railroad_spikes", "lightning", "grass", "salt", "onions", "trash", "popcorn", "fries", "pizza_party", "sushi_roll", "breakfast_club", "pancakes", "pretzel_twist", "cheese_please", "candies", "gummy_bears", "ice_cream_social", "strawberry_fields", "citrus_splash", "banana_bonanza", "pineapple_express", "mushroom_mix", "coffee_break", "tea_time", "nuts_acorns", "game_night", "love_letters", "music_notes", "pencil_case", "playing_cards", "puzzle_pieces", "sewing_kit", "toolbox", "bats", "assorted_bugs", "pinecone_shower", "flower_power", "seashell_shuffle", "autumn_harvest", "birthday_bash", "bees", "vines", "spiders", "gold", "absolute_zero", "petrified", "ruby", "sapphire", "emerald", "quartz", "rose_quartz", "topaz", "amethyst"]
const EFFECT_NAMES = ["Pickles", "Confetti", "Roses", "Money", "Treasure", "Treats", "Underwear", "Bullets", "Pan", "Food", "Dog Toys", "Watermelon", "Luck", "Leaves", "Math", "Sodas", "Death by Chocolate", "Lipsticks", "Space", "Railroad Spikes", "Lightning", "Grass", "Salt", "Onions", "Trash", "Popcorn", "French Fries", "Pizza Party", "Sushi Roll", "Breakfast Club", "Pancakes", "Pretzel Twist", "Cheese Please", "Candies", "Gummy Bears", "Ice Cream Social", "Strawberry Fields", "Citrus Splash", "Banana Bonanza", "Pineapple Express", "Mushroom Mix", "Coffee Break", "Tea Time", "Nuts & Acorns", "Game Night", "Love Letters", "Music Notes", "Pencil Case", "Playing Cards", "Puzzle Pieces", "Sewing Kit", "Toolbox", "Bats", "Assorted Bugs", "Pinecone Shower", "Flower Power", "Seashell Shuffle", "Autumn Harvest", "Birthday Bash", "Bees", "Vines", "Spiders", "Gold", "Absolute Zero", "Ruined", "Ruby", "Sapphire", "Emerald", "Quartz", "Rose Quartz", "Topaz", "Amethyst"]
# Cosmetic tier metadata only: no entitlement/unlock system is implied.
const EFFECT_METADATA := {"ruby":{"rarity":"legendary","available":true,"attachment":"body_surface","lifetime":"persistent"},"sapphire":{"rarity":"legendary","available":true,"attachment":"body_surface","lifetime":"persistent"},"emerald":{"rarity":"legendary","available":true,"attachment":"body_surface","lifetime":"persistent"},"quartz":{"rarity":"legendary","available":true,"attachment":"body_surface","lifetime":"persistent"},"rose_quartz":{"rarity":"legendary","available":true,"attachment":"body_surface","lifetime":"persistent"},"topaz":{"rarity":"legendary","available":true,"attachment":"body_surface","lifetime":"persistent"},"amethyst":{"rarity":"legendary","available":true,"attachment":"body_surface","lifetime":"persistent"},"petrified":{"rarity":"legendary","available":true,"attachment":"body_surface","lifetime":"persistent"},"gold":{"rarity":"legendary","available":true,"attachment":"body_surface","lifetime":"persistent"},"absolute_zero":{"rarity":"legendary","available":true,"attachment":"body_surface","lifetime":"persistent"},"spiders":{"rarity":"legendary","available":true,"attachment":"body_and_tower","lifetime":"persistent"}, "vines":{"available":true,"attachment":"body_surface","lifetime":"persistent"}, "bees":{"rarity":"common","available":true}, "popcorn":{"rarity":"common","available":true}, "fries":{"rarity":"common","available":true}, "pizza_party":{"rarity":"common","available":true}, "sushi_roll":{"rarity":"common","available":true}, "breakfast_club":{"rarity":"common","available":true}, "pancakes":{"rarity":"common","available":true}, "pretzel_twist":{"rarity":"common","available":true}, "cheese_please":{"rarity":"common","available":true}, "candies":{"rarity":"common","available":true}, "gummy_bears":{"rarity":"common","available":true}, "ice_cream_social":{"rarity":"common","available":true}, "strawberry_fields":{"rarity":"common","available":true}, "citrus_splash":{"rarity":"common","available":true}, "banana_bonanza":{"rarity":"common","available":true}, "pineapple_express":{"rarity":"common","available":true}, "mushroom_mix":{"rarity":"common","available":true}, "coffee_break":{"rarity":"common","available":true}, "tea_time":{"rarity":"common","available":true}, "nuts_acorns":{"rarity":"common","available":true}, "game_night":{"rarity":"common","available":true}, "love_letters":{"rarity":"common","available":true}, "music_notes":{"rarity":"common","available":true}, "pencil_case":{"rarity":"common","available":true}, "playing_cards":{"rarity":"common","available":true}, "puzzle_pieces":{"rarity":"common","available":true}, "sewing_kit":{"rarity":"common","available":true}, "toolbox":{"rarity":"common","available":true}, "bats":{"rarity":"common","available":true}, "assorted_bugs":{"rarity":"common","available":true}, "pinecone_shower":{"rarity":"common","available":true}, "flower_power":{"rarity":"common","available":true}, "seashell_shuffle":{"rarity":"common","available":true}, "autumn_harvest":{"rarity":"common","available":true}, "birthday_bash":{"rarity":"common","available":true}, "railroad_spikes":{"rarity":"rare","available":true,"attachment":"limbs"}, "lightning":{"available":true,"attachment":"highest_body_surface","lifetime":"transient"}}
const ATTACHED_EFFECTS := ["railroad_spikes", "lightning", "vines", "spiders", "gold", "absolute_zero", "petrified", "ruby", "sapphire", "emerald", "quartz", "rose_quartz", "topaz", "amethyst"]
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
	if effect == "rainbow_quartz": effect = "quartz"
	return {"head": clampi(int(p.get("head", 0)), 0, HEAD_NAMES.size()-1), "skin": clampi(int(p.get("skin", 1)), 0, SKINS.size()-1), "speedo": clampi(int(p.get("speedo", 0)), 0, SUITS.size()-1), "effect": effect if effect in EFFECTS else "confetti"}

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

func model(_p: Dictionary) -> PackedScene:
	return CLIMBER

## Dress a built climber (each of its bodies in turn) or a whole model (the wardrobe's
## preview, the podium) in a look: the chosen head, and the skin and suit recoloured.
## Only mesh resources change: pieces, poses and collision stay the body's.
func apply(root: Node, value: Dictionary) -> void:
	var p := clean(value)
	var skin: Dictionary = AtlasPalette.swatch(Color(SKINS[p.skin]))
	var suit: Dictionary = AtlasPalette.swatch(Color(SUITS[p.speedo]))
	var uvs: Array = [
		skin.uv,
		AtlasPalette.matte_uv(_shade(skin.color, CLIMBER_SKIN, CLIMBER_SKIN_SHADE)),
		suit.uv,
		AtlasPalette.matte_uv(_shade(suit.color, CLIMBER_SUIT, CLIMBER_SUIT_SHADE)),
	]
	_dress(root, p, uvs, "%d:%d" % [p.skin, p.speedo])


## base darkened the way the model darkens `own` into `own_shade`, channel by channel.
static func _shade(base: Color, own: Color, own_shade: Color) -> Color:
	return Color(base.r * own_shade.r / own.r, base.g * own_shade.g / own.g, base.b * own_shade.b / own.b)


func _dress(node: Node, p: Dictionary, uvs: Array, key: String) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		# The piece's own mesh, kept the first time, so a second dressing starts from it.
		if not mi.has_meta("dress_src"):
			mi.set_meta("dress_src", mi.mesh)
		var src: Mesh = mi.get_meta("dress_src")
		var head: int = p.head
		if mi.name == "Head" and head > 0:
			mi.mesh = _head_mesh(head)  # a placeholder head keeps its own colours
		elif src != null:
			mi.mesh = _recoloured(src, uvs, key)
		for si in mi.mesh.get_surface_count():
			var m := mi.mesh.surface_get_material(si)
			if m is StandardMaterial3D:
				mi.set_surface_override_material(si, CelPass.material_for(m, mi.mesh, si))
	for child in node.get_children():
		_dress(child, p, uvs, key)


static var _heads := {}


static func _head_mesh(i: int) -> Mesh:
	if not _heads.has(i):
		var scene: Node = (HEAD_SCENES[i] as PackedScene).instantiate()
		var piece := scene.find_child("Head", true, false) as MeshInstance3D
		_heads[i] = piece.mesh if piece != null else null
		scene.free()
	return _heads[i]


## Each source mesh's vertices sorted once by the atlas colour under them (-1: keep),
## then one recoloured copy per look, shared by everyone wearing it.
static var _classes := {}
static var _looks := {}
static var _atlas: Image = null


static func _recoloured(src: Mesh, uvs: Array, key: String) -> Mesh:
	var look_key := "%d|%s" % [src.get_instance_id(), key]
	if _looks.has(look_key):
		return _looks[look_key]
	var classes: Array = _classes_of(src)
	var out: Mesh = src
	if not classes.is_empty():
		var made := ArrayMesh.new()
		# UV recolouring preserves geometry: let fitted cosmetics use its CPU bake.
		made.set_meta("lock_geometry_source",src.resource_path)
		for si in src.get_surface_count():
			var arrays := src.surface_get_arrays(si)
			var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
			var cls: PackedInt32Array = classes[si]
			for i in uv.size():
				if cls[i] >= 0:
					uv[i] = uvs[cls[i]]
			arrays[Mesh.ARRAY_TEX_UV] = uv
			made.add_surface_from_arrays(src.surface_get_primitive_type(si), arrays)
			made.surface_set_material(si, src.surface_get_material(si))
		out = made
	_looks[look_key] = out
	return out


static func _classes_of(src: Mesh) -> Array:
	var id := src.get_instance_id()
	if _classes.has(id):
		return _classes[id]
	if _atlas == null:
		_atlas = CelPass.ATLAS.get_image()
		if _atlas.is_compressed():
			_atlas.decompress()
	var w := _atlas.get_width()
	var h := _atlas.get_height()
	var out: Array = []
	var any := false
	for si in src.get_surface_count():
		var arrays := src.surface_get_arrays(si)
		var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV] if arrays[Mesh.ARRAY_TEX_UV] != null else PackedVector2Array()
		var cls := PackedInt32Array()
		cls.resize(uv.size())
		for i in uv.size():
			var px := _atlas.get_pixel(clampi(int(uv[i].x * w), 0, w - 1), clampi(int(uv[i].y * h), 0, h - 1))
			cls[i] = int(_RECOLOUR.get(px.to_html(false), -1))
			any = any or cls[i] >= 0
		out.append(cls)
	if not any:
		out = []
	_classes[id] = out
	return out
