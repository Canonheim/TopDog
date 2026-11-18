extends Node
const Rewards = preload("res://core/pinata_rewards.gd")
func _ready() -> void:
	call_deferred("run")
func run() -> void:
	var path := OS.get_environment("TEMP").path_join("topdog-reward-test-" + str(OS.get_process_id()) + ".cfg")
	var store := Rewards.new(path)
	var players := [{"pid":0,"slot":0,"name":"A"},{"pid":1,"slot":1,"name":"B"}]
	var rules := {"rarity_weights": Rewards.table().rarity_weights, "items": []}
	assert(store.collect("first", 2, 918, players, rules).is_empty())
	var cfg := ConfigFile.new()
	assert(cfg.load(path) == OK)
	assert(cfg.get_value("rewards", "pending").size() == 2)
	assert(store.collect("first", 2, 918, players, rules).is_empty())
	cfg.load(path)
	assert(cfg.get_value("rewards", "pending").size() == 2)
	for rarity in 5:
		for i in 5:
			rules.items.append({"id":"r%d_%d" % [rarity,i],"name":"Test Reward","rarity":rarity})
	var grants := store.collect("first", 2, 918, players, rules)
	assert(grants.size() == 2)
	assert(grants[0].slot != grants[1].slot)
	assert(store.collect("first", 2, 918, players, rules).is_empty())
	for event in 40:
		store.collect("next" + str(event), 2, event, players, rules)
	cfg.load(path)
	var owned: Dictionary = cfg.get_value("rewards", "owned")
	for slot in ["0","1"]:
		assert(owned[slot].size() == 15) # Blue cannot yield purple or red.
		var unique := {}
		for id in owned[slot]: unique[id] = true
		assert(unique.size() == owned[slot].size())
	assert(cfg.get_value("rewards", "pending").size() > 0)
	assert(Rewards.roll(0, [], 2, rules).rarity == 0)
	assert(Rewards.roll(2, owned["0"], 3, rules).is_empty())
	assert(Rewards.roll(2, [], 918, rules) == Rewards.roll(2, [], 918, rules))
	DirAccess.remove_absolute(path)
	print("REWARDS PASS: independent local recipients, persistence, collection replay protection, banked empty pools, no duplicates, exhausted pools, tier boundaries, deterministic rolls")
	get_tree().quit()
