extends Node
## Explicit resource preparation; never emits a hidden burst or changes RNG state.
## Small bounded batches; no await between cache read and write.
const WardrobeScript = preload("res://core/wardrobe.gd")
# The old UI already preloaded these scripts. Keep compilation/resource decoding
# in scene loading, rather than moving it into the first incremental mesh job.
const SCRIPTS := {
 "gold":preload("res://ui3d/gold/gold.gd"),"absolute_zero":preload("res://ui3d/absolute_zero/absolute_zero.gd"),
	"spiders":preload("res://ui3d/spiders_effect.gd"),
	"vines":preload("res://ui3d/vines/vines.gd"),
	"bees":preload("res://ui3d/common_effects/bees.gd"),
	"popcorn":preload("res://ui3d/common_effects/popcorn.gd"),
	"fries":preload("res://ui3d/common_effects/fries.gd"),
	"pizza_party":preload("res://ui3d/common_effects/pizza_party.gd"),
	"sushi_roll":preload("res://ui3d/common_effects/sushi_roll.gd"),
	"breakfast_club":preload("res://ui3d/common_effects/breakfast_club.gd"),
	"pancakes":preload("res://ui3d/common_effects/pancakes.gd"),
	"pretzel_twist":preload("res://ui3d/common_effects/pretzel_twist.gd"),
	"cheese_please":preload("res://ui3d/common_effects/cheese_please.gd"),
	"candies":preload("res://ui3d/common_effects/candies.gd"),
	"gummy_bears":preload("res://ui3d/common_effects/gummy_bears.gd"),
	"ice_cream_social":preload("res://ui3d/common_effects/ice_cream_social.gd"),
	"strawberry_fields":preload("res://ui3d/common_effects/strawberry_fields.gd"),
	"citrus_splash":preload("res://ui3d/common_effects/citrus_splash.gd"),
	"banana_bonanza":preload("res://ui3d/common_effects/banana_bonanza.gd"),
	"pineapple_express":preload("res://ui3d/common_effects/pineapple_express.gd"),
	"mushroom_mix":preload("res://ui3d/common_effects/mushroom_mix.gd"),
	"coffee_break":preload("res://ui3d/common_effects/coffee_break.gd"),
	"tea_time":preload("res://ui3d/common_effects/tea_time.gd"),
	"nuts_acorns":preload("res://ui3d/common_effects/nuts_acorns.gd"),
	"game_night":preload("res://ui3d/common_effects/game_night.gd"),
	"love_letters":preload("res://ui3d/common_effects/love_letters.gd"),
	"music_notes":preload("res://ui3d/common_effects/music_notes.gd"),
	"pencil_case":preload("res://ui3d/common_effects/pencil_case.gd"),
	"playing_cards":preload("res://ui3d/common_effects/playing_cards.gd"),
	"puzzle_pieces":preload("res://ui3d/common_effects/puzzle_pieces.gd"),
	"sewing_kit":preload("res://ui3d/common_effects/sewing_kit.gd"),
	"toolbox":preload("res://ui3d/common_effects/toolbox.gd"),
	"bats":preload("res://ui3d/common_effects/bats.gd"),
	"assorted_bugs":preload("res://ui3d/common_effects/assorted_bugs.gd"),
	"pinecone_shower":preload("res://ui3d/common_effects/pinecone_shower.gd"),
	"flower_power":preload("res://ui3d/common_effects/flower_power.gd"),
	"seashell_shuffle":preload("res://ui3d/common_effects/seashell_shuffle.gd"),
	"autumn_harvest":preload("res://ui3d/common_effects/autumn_harvest.gd"),
	"birthday_bash":preload("res://ui3d/common_effects/birthday_bash.gd"),

	"onions":preload("res://ui3d/onions_effect.gd"),
	"grass":preload("res://ui3d/grass_effect.gd"),
	"lightning":preload("res://ui3d/lightning_effect.gd"),
	"railroad_spikes":preload("res://ui3d/railroad_spikes_effect.gd"),
	"space":preload("res://ui3d/space_effect.gd"),
	"lipsticks":preload("res://ui3d/lipsticks_effect.gd"),
	"pickles":preload("res://ui3d/pickles_effect.gd"),
	"sodas":preload("res://ui3d/sodas_effect.gd"),
	"confetti":preload("res://ui3d/confetti_effect.gd"),
	"roses":preload("res://ui3d/rose_petals.gd"),
	"bills":preload("res://ui3d/peso_bills.gd"),
	"treasure":preload("res://ui3d/treasure_effect.gd"),
	"treats":preload("res://ui3d/dog_treats.gd"),
	"underwear":preload("res://ui3d/underwear_effect.gd"),
	"bullets":preload("res://ui3d/bullet_effect.gd"),
	"pan":preload("res://ui3d/pan_effect.gd"),
	"food":preload("res://ui3d/food_effect.gd"),
	"dog_toys":preload("res://ui3d/dog_toys.gd"),
	"watermelon":preload("res://ui3d/watermelon_effect.gd"),
	"luck":preload("res://ui3d/luck_effect.gd"),
	"autumn_leaves":preload("res://ui3d/autumn_leaves.gd"),
	"math":preload("res://ui3d/math_effect.gd"),
	"chocolates":preload("res://ui3d/chocolates_effect.gd"),
	"salt":preload("res://ui3d/salt_effect.gd"),
	"trash":preload("res://ui3d/trash_effect.gd"),
}
# path, preparation adapter, variant count, normal pieces, triangle ceiling.
# Existing geometry ceilings are reviewed exceptions, not defaults for new effects.
const REGISTRY := {
 "gold":["gold/gold","legendary_material",1,3,24],"absolute_zero":["absolute_zero/absolute_zero","legendary_material",1,9,400],
	"spiders":["spiders_effect","spiders",13,10,10000],
	"vines":["vines/vines","vines",33,21,36893],
	"popcorn":["common_effects/popcorn", "common", 11, 72, 25881],
	"fries":["common_effects/fries", "common", 9, 90, 8203],
	"pizza_party":["common_effects/pizza_party", "common", 12, 72, 11555],
	"sushi_roll":["common_effects/sushi_roll", "common", 11, 72, 25049],
	"breakfast_club":["common_effects/breakfast_club", "common", 10, 72, 11832],
	"pancakes":["common_effects/pancakes", "common", 13, 72, 14818],
	"pretzel_twist":["common_effects/pretzel_twist", "common", 7, 72, 31450],
	"cheese_please":["common_effects/cheese_please", "common", 11, 72, 6519],
	"candies":["common_effects/candies", "common", 10, 72, 10685],
	"gummy_bears":["common_effects/gummy_bears", "common", 7, 72, 31148],
	"ice_cream_social":["common_effects/ice_cream_social", "common", 13, 54, 13413],
	"strawberry_fields":["common_effects/strawberry_fields", "common", 7, 36, 56398],
	"citrus_splash":["common_effects/citrus_splash", "common", 7, 36, 3554],
	"banana_bonanza":["common_effects/banana_bonanza", "common", 4, 36, 50615],
	"pineapple_express":["common_effects/pineapple_express", "common", 7, 36, 16532],
	"mushroom_mix":["common_effects/mushroom_mix", "common", 5, 36, 12569],
	"coffee_break":["common_effects/coffee_break", "common", 6, 36, 5292],
	"tea_time":["common_effects/tea_time", "common", 5, 36, 4965],
	"nuts_acorns":["common_effects/nuts_acorns", "common", 5, 36, 10225],
	"game_night":["common_effects/game_night", "common", 9, 48, 5683],
	"love_letters":["common_effects/love_letters", "common", 17, 48, 8946],
	"music_notes":["common_effects/music_notes", "common", 7, 36, 5192],
	"pencil_case":["common_effects/pencil_case", "common", 9, 48, 4410],
	"playing_cards":["common_effects/playing_cards", "common", 13, 60, 7896],
	"puzzle_pieces":["common_effects/puzzle_pieces", "common", 7, 60, 10836],
	"sewing_kit":["common_effects/sewing_kit", "common", 9, 48, 12424],
	"toolbox":["common_effects/toolbox", "common", 6, 30, 7132],
	"bats":["common_effects/bats", "common", 7, 42, 27342],
	"assorted_bugs":["common_effects/assorted_bugs", "common", 7, 48, 31500],
	"pinecone_shower":["common_effects/pinecone_shower", "common", 12, 56, 14028],
	"flower_power":["common_effects/flower_power", "common", 13, 42, 30644],
	"seashell_shuffle":["common_effects/seashell_shuffle", "common", 9, 24, 42122],
	"autumn_harvest":["common_effects/autumn_harvest", "common", 8, 59, 45988],
	"birthday_bash":["common_effects/birthday_bash", "common", 9, 42, 12323],

	"onions":["onions_effect","scene:onion_",14,81,41769],
	"grass":["grass_effect","scene:grass_",12,90,7300],
	"lightning":["lightning_effect", "lightning", 40, 3, 9350],
	"railroad_spikes":["railroad_spikes_effect","scene:railroad_",1,4,370],
	"space":["space_effect","space",15,72,4300],
	"lipsticks": ["lipsticks_effect", "scene:lipstick_", 12, 72, 21500],
	"pickles":["pickles_effect","pickles",10,72,19800],
	"sodas": ["sodas_effect", "scene:soda_", 15, 90, 14200],
	"confetti": ["confetti_effect", "confetti", 30, 90, 3100],
	"roses": ["rose_petals", "baked:roses", 12, 90, 10300],
	"bills": ["peso_bills", "baked:bills", 18, 72, 130000],
	"treasure": ["treasure_effect", "scene:treasure_", 18, 90, 35000],
	"treats": ["dog_treats", "treats", 9, 90, 12700],
	"underwear": ["underwear_effect", "scene:underwear_", 128, 84, 42000],
	"bullets": ["bullet_effect", "scene:bullet_", 12, 72, 43200],
	"pan": ["pan_effect", "scene:pan_", 15, 72, 121500],
	"food": ["food_effect", "scene:food_", 11, 90, 63807],
	"dog_toys": ["dog_toys", "baked:dog_toys", 18, 90, 153100],
	"watermelon": ["watermelon_effect", "scene:watermelon_", 6, 90, 59300],
	"luck": ["luck_effect", "scene:luck_", 12, 72, 70200],
	"autumn_leaves": ["autumn_leaves", "autumn_leaves", 24, 72, 4100],
	"math": ["math_effect", "math", 12, 24, 48],
	"chocolates": ["chocolates_effect", "scene:chocolate_", 12, 72, 21000],
	"salt":["salt_effect","scene:salt_",2,190,4600],
	"trash":["trash_effect","scene:trash_",8,56,12000],
	"bees":["common_effects/bees", "common", 7, 36, 10000],
}
const PREPARE_STEP_BUDGET_MS := 8.0
const PREPARED_SPAWN_BUDGET_MS := 8.0
const PREPARED_P95_BUDGET_MS := 4.0
const FRAME_TARGET_MS := 2.0
const MAX_UNITS_PER_FRAME := 4
const WINNER_BUDGETS := {"confetti":{"pieces":300,"triangles":10300,"spawn_ms":8.0}}
# Resident mesh ceilings are explicit even for adapters with a single prewarm call.
const CACHE_MESH_LIMITS := {
 "gold":1,"absolute_zero":2,
	"spiders":13,
	"vines":34,
	"popcorn":10,
	"fries":8,
	"pizza_party":11,
	"sushi_roll":10,
	"breakfast_club":9,
	"pancakes":12,
	"pretzel_twist":6,
	"cheese_please":10,
	"candies":9,
	"gummy_bears":6,
	"ice_cream_social":12,
	"strawberry_fields":6,
	"citrus_splash":6,
	"banana_bonanza":3,
	"pineapple_express":6,
	"mushroom_mix":4,
	"coffee_break":5,
	"tea_time":4,
	"nuts_acorns":4,
	"game_night":8,
	"love_letters":16,
	"music_notes":6,
	"pencil_case":8,
	"playing_cards":12,
	"puzzle_pieces":6,
	"sewing_kit":8,
	"toolbox":5,
	"bats":6,
	"assorted_bugs":6,
	"pinecone_shower":11,
	"flower_power":12,
	"seashell_shuffle":8,
	"autumn_harvest":7,
	"birthday_bash":8,

	"onions":14,
	"grass":12,
	"lightning":8,
	"railroad_spikes":1,
	"space":14,
	"lipsticks":12,
	"pickles":9,
	"sodas":15,
	"confetti":30,"roses":12,"bills":18,"treasure":18,"treats":9,
	"underwear":128,"bullets":12,"pan":15,"food":11,"dog_toys":18,
	"watermelon":6,"luck":12,"autumn_leaves":24,"math":12,
	"chocolates":12,
	"salt":2,
	"trash":8,
	"bees":6,
}
const CACHE_ARRAY_BYTE_LIMITS := {
 "gold":10000,"absolute_zero":30000,
	"spiders":1500000,
	"vines":17922274,
	"popcorn":502724,
	"fries":268649,
	"pizza_party":204036,
	"sushi_roll":426720,
	"breakfast_club":232697,
	"pancakes":386266,
	"pretzel_twist":409349,
	"cheese_please":164640,
	"candies":209110,
	"gummy_bears":405418,
	"ice_cream_social":682744,
	"strawberry_fields":1466842,
	"citrus_splash":92888,
	"banana_bonanza":752422,
	"pineapple_express":720897,
	"mushroom_mix":218190,
	"coffee_break":122943,
	"tea_time":114341,
	"nuts_acorns":177568,
	"game_night":148420,
	"love_letters":466536,
	"music_notes":135476,
	"pencil_case":115332,
	"playing_cards":247364,
	"puzzle_pieces":169546,
	"sewing_kit":323686,
	"toolbox":185842,
	"bats":609840,
	"assorted_bugs":614754,
	"pinecone_shower":525740,
	"flower_power":1219680,
	"seashell_shuffle":2191006,
	"autumn_harvest":1231709,
	"birthday_bash":360050,

	"onions":957113,
	"grass":230000,
	"lightning":825615,
	"railroad_spikes":15000,
	"space":405000,
	"lipsticks":560000,
	"pickles":333000,
	"sodas":485000,
	"confetti":206000,"roses":427000,"bills":4880000,"treasure":1376000,
	"treats":184000,"underwear":12540000,"bullets":1123000,"pan":2791000,
	"food":1562266,"dog_toys":4411000,"watermelon":679000,"luck":1827000,
	"autumn_leaves":198000,"math":10000,
	"chocolates":600000,
	"salt":51000,
	"trash":325000,
	"bees":259964,
}
const NORMAL_NODE_LIMITS := {
 "gold":4,"absolute_zero":10,
	"spiders":11,
	"vines":22,
	"popcorn":73,
	"fries":91,
	"pizza_party":73,
	"sushi_roll":73,
	"breakfast_club":73,
	"pancakes":73,
	"pretzel_twist":73,
	"cheese_please":73,
	"candies":73,
	"gummy_bears":73,
	"ice_cream_social":55,
	"strawberry_fields":37,
	"citrus_splash":37,
	"banana_bonanza":37,
	"pineapple_express":37,
	"mushroom_mix":37,
	"coffee_break":37,
	"tea_time":37,
	"nuts_acorns":37,
	"game_night":49,
	"love_letters":49,
	"music_notes":37,
	"pencil_case":49,
	"playing_cards":61,
	"puzzle_pieces":61,
	"sewing_kit":49,
	"toolbox":31,
	"bats":85,
	"assorted_bugs":97,
	"pinecone_shower":113,
	"flower_power":85,
	"seashell_shuffle":49,
	"autumn_harvest":119,
	"birthday_bash":85,

	"onions":244,
	"grass":271,
	"lightning":10,
	"railroad_spikes":5,
	"space":73,
	"lipsticks":217,
	"pickles":73,
	"sodas":271,
	"confetti":91,"roses":55,"bills":73,"treasure":271,"treats":181,
	"underwear":253,"bullets":217,"pan":217,"food":271,"dog_toys":181,
	"watermelon":271,"luck":217,"autumn_leaves":73,"math":25,
	"chocolates":217,
	"salt":381,
	"trash":113,
	"bees":37,
}
# Per retained climber: never treat attached cosmetics as timed camera bursts.
const PERSISTENT_EFFECTS := {"gold":{"meshes_per_climber":3,"triangles_per_climber":24,"nodes_per_climber":4},"absolute_zero":{"meshes_per_climber":9,"triangles_per_climber":400,"nodes_per_climber":10},"spiders":{"meshes_per_climber":10,"triangles_per_climber":10000,"nodes_per_climber":11},"vines":{"meshes_per_climber":21,"triangles_per_climber":35136,"nodes_per_climber":22},"railroad_spikes":{"meshes_per_climber":4,"triangles_per_climber":352,"nodes_per_climber":5}}
const TRANSIENT_ATTACHED_EFFECTS := {"lightning":{"lifetime":1.65,"skin_vertex_bytes":200000}}
static func is_attached(id: String) -> bool:
	return PERSISTENT_EFFECTS.has(id) or TRANSIENT_ATTACHED_EFFECTS.has(id)

static func attach(id: String, climber: Climber, camera: Camera3D, animate := true) -> Node:
	if not is_attached(id): return null
	if not is_prepared(id): cold_requests[id] = int(cold_requests.get(id,0))+1
	return effect_script(id).attach(climber,camera,animate)

static var progress := {}
static var pending := {}
static var step_max_ms := {}
static var cold_requests := {}
static var failed_paths := {}
static var failed_effects := {}
static var max_frame_cpu_ms := 0.0
var order: Array = []
var cursor := 0
var selected_turn := false

static func validation_errors() -> Array[String]:
	var errors: Array[String] = []
	for id in WardrobeScript.EFFECTS:
		if not REGISTRY.has(id): errors.append("Effect lacks preparation and budgets: " + id)
	for id in REGISTRY:
		if not id in WardrobeScript.EFFECTS: errors.append("Unregistered preparation: " + id)
		if not SCRIPTS.has(id): errors.append("Missing preloaded script: " + id)
		if not CACHE_MESH_LIMITS.has(id) or int(CACHE_MESH_LIMITS.get(id,0)) <= 0:
			errors.append("Missing finite cache budget: " + id)
		if not CACHE_ARRAY_BYTE_LIMITS.has(id) or int(CACHE_ARRAY_BYTE_LIMITS.get(id,0)) <= 0:
			errors.append("Missing finite mesh storage budget: " + id)
		if not NORMAL_NODE_LIMITS.has(id) or int(NORMAL_NODE_LIMITS.get(id,0)) <= 0:
			errors.append("Missing finite node budget: " + id)
		if REGISTRY[id][2] <= 0 or REGISTRY[id][3] <= 0 or REGISTRY[id][4] <= 0:
			errors.append("Missing finite budget: " + id)
	for id in WardrobeScript.ATTACHED_EFFECTS:
		if not PERSISTENT_EFFECTS.has(id) and not TRANSIENT_ATTACHED_EFFECTS.has(id): errors.append("Attached effect lacks lifetime budgets: "+id)
	for id in PERSISTENT_EFFECTS:
		if not id in WardrobeScript.ATTACHED_EFFECTS or not REGISTRY.has(id): errors.append("Persistent registration mismatch: "+id)
	for id in TRANSIENT_ATTACHED_EFFECTS:
		if not id in WardrobeScript.ATTACHED_EFFECTS or not REGISTRY.has(id): errors.append("Transient registration mismatch: "+id)
		if float(TRANSIENT_ATTACHED_EFFECTS[id].get("lifetime",0))<=0: errors.append("Transient effect needs finite lifetime: "+id)
	return errors

static func effect_script(id: String) -> Script:
	return SCRIPTS[id]

static func is_prepared(id: String) -> bool:
	return REGISTRY.has(id) and int(progress.get(id,0)) >= int(REGISTRY[id][2])

static func scene_key(id: String, index: int) -> String:
	var script = effect_script(id)
	if id != "underwear": return script.TYPES[index]
	if index < 96:
		return script.TYPES[index/32] + "_" + str((index/4)%8) + "_" + ["b","c","d","dd"][index%4]
	return script.TYPES[3+(index-96)/8] + "_" + str((index-96)%8)

static func prepare_scene(script, key: String, path: String) -> bool:
	if failed_paths.has(path): return false
	if not script.scenes.has(key):
		if not pending.has(path):
			if not ResourceLoader.exists(path):
				fail_path(path,"missing resource")
				return false
			var error := ResourceLoader.load_threaded_request(path, "PackedScene")
			if error != OK:
				fail_path(path,"request failed: " + str(error))
				return false
			pending[path] = Time.get_ticks_msec()
			return false
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if Time.get_ticks_msec()-int(pending[path]) > 5000: fail_path(path,"load timeout")
			return false
		if status != ResourceLoader.THREAD_LOAD_LOADED:
			fail_path(path,"threaded load failed")
			return false
		script.scenes[key] = ResourceLoader.load_threaded_get(path)
	if pending.has(path):
		# An early live request may already have loaded this same resource.
		if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS: return false
		ResourceLoader.load_threaded_get(path)
		pending.erase(path)
	# Temporary instance is never added to the tree; retain only original PackedScene
	# and CelPass's shared material twins. No duplicate full scene trees or packing.
	var sample: Node = script.scenes[key].instantiate()
	CelPass.celify(sample)
	sample.free()
	return true

static func fail_path(path: String, reason: String) -> void:
	if failed_paths.has(path): return
	failed_paths[path] = reason
	pending.erase(path)
	push_warning("Effect preparation skipped %s: %s" % [path,reason])

static func prepare_baked(id: String, index: int, script) -> bool:
	var cache = preload("res://ui3d/effect_mesh_cache.gd")
	var path: String = cache.path_for(id,index)
	if failed_paths.has(path): return false
	if not cache.meshes.has(path):
		if not pending.has(path):
			if not ResourceLoader.exists(path):
				fail_path(path,"missing baked mesh; run tests/bake_effect_meshes.gd")
				return false
			if ResourceLoader.load_threaded_request(path,"ArrayMesh") != OK:
				fail_path(path,"mesh request failed")
				return false
			pending[path] = Time.get_ticks_msec()
			return false
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if Time.get_ticks_msec()-int(pending[path]) > 5000: fail_path(path,"mesh load timeout")
			return false
		if status != ResourceLoader.THREAD_LOAD_LOADED:
			fail_path(path,"mesh load failed")
			return false
		var mesh := ResourceLoader.load_threaded_get(path) as ArrayMesh
		for surface in mesh.get_surface_count(): mesh.surface_set_material(surface,CelPass.one())
		cache.meshes[path] = mesh
	if pending.has(path):
		if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS: return false
		ResourceLoader.load_threaded_get(path)
		pending.erase(path)
	if id == "roses":
		if index < 6:
			if script.meshes.is_empty(): script.meshes.resize(6)
			script.meshes[index] = cache.meshes[path]
		else:
			if script.rose_meshes.is_empty(): script.rose_meshes.resize(6)
			script.rose_meshes[index-6] = cache.meshes[path]
	else:
		if script.meshes is Array and script.meshes.is_empty(): script.meshes.resize(18)
		script.meshes[index] = cache.meshes[path]
	return true

static func prepare_step(id: String) -> bool:
	if is_prepared(id): return true
	var started := Time.get_ticks_usec()
	var index := int(progress.get(id,0))
	var script = effect_script(id)
	var adapter: String = REGISTRY[id][1]
	var finished := true
	if adapter.begins_with("baked:"):
		finished = prepare_baked(id,index,script)
		var path: String = preload("res://ui3d/effect_mesh_cache.gd").path_for(id,index)
		if failed_paths.has(path): failed_effects[id] = failed_paths[path]
	elif adapter.begins_with("scene:"):
		var key := scene_key(id,index)
		var path := "res://kit/models/"+adapter.trim_prefix("scene:")+key+".glb"
		finished = prepare_scene(script,key,path)
		if finished and is_attached(id): script.prepare()
		if failed_paths.has(path): failed_effects[id] = failed_paths[path]
	else:
		match adapter:
			"legendary_material": finished = script.prepare_unit(index)
			"common": script.prepare_unit(index)
			"spiders": finished = script.prepare_unit(index)
			"vines": finished = script.prepare_unit(index)
			"lightning":
				finished = script.prepare_unit(index)
				if not script.preparation_errors.is_empty(): failed_effects[id] = str(script.preparation_errors)
			"space": script.prepare_unit(index)
			"pickles": script.prepare_unit(index)
			"confetti": script.piece_mesh(index/6,index%6)
			"roses":
				if index < 6: script.petal_mesh(index)
				else: script.rose_mesh(index-6)
			"bills": script.bill_mesh(index/3,index%3)
			"treats": script.treat_mesh(index)
			"dog_toys": script.toy_mesh(index/3,index%3)
			"autumn_leaves": script.prepare_variant(index)
			"math": script.prepare_variant(index)
			"prewarm": script.prewarm()
			_:
				push_error("Missing preparation adapter: " + id)
				return false
	var elapsed := (Time.get_ticks_usec()-started)/1000.0
	step_max_ms[id] = maxf(float(step_max_ms.get(id,0.0)),elapsed)
	if elapsed > PREPARE_STEP_BUDGET_MS:
		push_warning("Effect preparation step over budget: %s[%d] %.3f ms" % [id,index,elapsed])
	if finished: progress[id] = index+1
	return is_prepared(id)

## THE WORLD BURST (Parker 11-14: "when you lock in in the vs modes, the confetti
## explosion should stay where the character locked in, not change with the camera, so
## it should be worldspace not screen space"; 11-19: "my lock in confetti is not coming
## out of me, it is sill coming out of screen space"). Every effect builds its burst
## under the camera, its pieces moving in the burst's own frame. For a lock-in the burst
## then leaves the camera for the world: scaled about the camera so in that first frame
## it looks the size it was made at, moved so it bursts from the climber (a little in
## front, so the body and the stage don't hide it), and left there as the camera moves.
const WORLD_BURST_FRONT := 0.8  # metres toward the camera from the climber's centre


static func into_world(root: Node3D, camera: Node3D, parent: Node3D, at: Vector3) -> void:
	if root == null or not is_instance_valid(root) or not root.is_inside_tree() or parent == null or not at.is_finite():
		return
	# The burst's own centre: where its pieces start, in its frame.
	var centre := Vector3.ZERO
	var n := 0
	for child in root.get_children():
		if child is Node3D:
			centre += (child as Node3D).position
			n += 1
	if n > 0:
		centre /= float(n)
	var from: Transform3D = root.global_transform  # the camera's frame, as built
	var eye: Vector3 = camera.global_position
	var forward: Vector3 = -(camera.global_basis.z.normalized())
	var made_depth: float = (from * centre - eye).dot(forward)
	if made_depth < 0.5:
		made_depth = 5.0
	var spot := at - forward * WORLD_BURST_FRONT
	var k := clampf((spot - eye).dot(forward) / made_depth, 0.5, 20.0)
	var basis := from.basis.scaled(Vector3.ONE * k)
	root.reparent(parent, false)
	root.global_transform = Transform3D(basis, spot - basis * centre)
	root.set_meta("world_burst", spot)  # where it bursts from


static func burst(id: String, camera: Node3D, big := false) -> Node3D:
	if not is_instance_valid(camera) or not camera.is_inside_tree(): return null
	if not REGISTRY.has(id): id = "confetti"
	if is_attached(id): return null
	if not is_prepared(id): cold_requests[id] = int(cold_requests.get(id,0))+1
	# Immediate fallback preserves event timing. Never silently drop, queue, reseed,
	# or finish all preparation synchronously when the player requests an effect.
	var script = effect_script(id)
	if id == "confetti": return script.burst(camera,big)
	return script.burst(camera)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for error in validation_errors(): push_error(error)
	order = REGISTRY.keys()
	var wardrobe := get_node_or_null("/root/Wardrobe")
	if wardrobe != null:
		var selected: String = wardrobe.for_slot(0).effect
		order.erase(selected)
		order.push_front(selected)

func _process(_dt: float) -> void:
	# No background geometry work in a live match or over a visible celebration.
	var main := get_parent()
	if str(main.get("screen")) in ["hud","results"]: return
	var camera: Node = main.get("cam")
	if camera != null:
		for child in camera.get_children():
			if child.has_meta("burst_profile"): return
	var started := Time.get_ticks_usec()
	for _unit in MAX_UNITS_PER_FRAME:
		if (Time.get_ticks_usec()-started)/1000.0 >= FRAME_TARGET_MS: break
		_schedule_one()
	var elapsed := (Time.get_ticks_usec()-started)/1000.0
	max_frame_cpu_ms = maxf(max_frame_cpu_ms,elapsed)
	if elapsed > PREPARE_STEP_BUDGET_MS:
		push_warning("Effect preparation frame over budget: %.3f ms" % elapsed)

func _schedule_one() -> void:
	# Alternate selected-effect priority with round-robin work. Large variant sets
	# and failed/slow loaders cannot starve the other local or remote choices.
	selected_turn = not selected_turn
	var wardrobe := get_node_or_null("/root/Wardrobe")
	if selected_turn and wardrobe != null:
		var selected: String = wardrobe.for_slot(0).effect
		if REGISTRY.has(selected) and not is_prepared(selected) and not failed_effects.has(selected):
			prepare_step(selected)
			return
	for _attempt in order.size():
		var id: String = order[cursor]
		cursor = (cursor+1)%order.size()
		if not is_prepared(id) and not failed_effects.has(id):
			prepare_step(id)
			return
	set_process(false)

func _exit_tree() -> void:
	# Release completed threaded-loader tickets when a menu/test scene is removed.
	# Never wait on IO during scene teardown; unfinished work stays tracked so a
	# replacement preparation node can resume it rather than duplicate the request.
	for path in pending.keys():
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			ResourceLoader.load_threaded_get(path)
			pending.erase(path)
		elif status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pending.erase(path)



