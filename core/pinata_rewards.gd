extends RefCounted
## Independent local reward inventory. Empty authoring pools bank pulls, never invent items.
const SavePaths = preload("res://core/save_paths.gd")
var path := ""
var error := ""
func _init(save_path := "") -> void:
	var account := str(Steam.getSteamID()) if Net.steam_ok else "offline"
	path = save_path if not save_path.is_empty() else SavePaths.settings("pinata_rewards_" + account + ".cfg")

static func table() -> Dictionary:
	var value = JSON.parse_string(FileAccess.get_file_as_string("res://data/pinata_rewards.json"))
	return value if value is Dictionary else {}

## Roll rarity among nonempty, unowned pools, then choose an item within that rarity.
static func roll(tier: int, owned: Array, seed_value: int, catalog: Dictionary) -> Dictionary:
	var rows: Array = catalog.get("rarity_weights", [])
	if tier < 0 or tier >= rows.size(): return {}
	var pools := [[], [], [], [], []]
	var seen := {}
	for item in catalog.get("items", []):
		if not item is Dictionary: continue
		var id := str(item.get("id", ""))
		var rarity := int(item.get("rarity", -1))
		if id.is_empty() or id in owned or seen.has(id) or rarity < 0 or rarity > 4 or str(item.get("name", "")).is_empty(): continue
		seen[id] = true
		pools[rarity].append(item)
	var total := 0.0
	for rarity in 5:
		if not pools[rarity].is_empty(): total += maxf(0, rows[tier][rarity])
	if total <= 0: return {}
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var remaining := rng.randf() * total
	for rarity in 5:
		if pools[rarity].is_empty(): continue
		var weight := maxf(0, rows[tier][rarity])
		if weight <= 0: continue
		remaining -= weight
		if remaining < 0:
			return pools[rarity][rng.randi_range(0, pools[rarity].size()-1)].duplicate(true)
	return {}

func collect(event_id: String, tier: int, seed_value: int, players: Array, catalog: Dictionary = {}) -> Array:
	error = ""
	if event_id.is_empty() or tier < 0 or tier > 4: return []
	var cfg := ConfigFile.new()
	var loaded := cfg.load(path)
	if loaded != OK and loaded != ERR_FILE_NOT_FOUND:
		error = "Could not read piñata reward save."
		return []
	var receipts: Array = cfg.get_value("rewards", "receipts", [])
	var pending: Array = cfg.get_value("rewards", "pending", [])
	var owned: Dictionary = cfg.get_value("rewards", "owned", {})
	for player in players:
		var slot := str(int(player.get("slot", 0)))
		var receipt := event_id + ":" + str(player.pid)
		if receipt in receipts: continue
		receipts.append(receipt)
		pending.append({"slot": slot, "name": str(player.get("name", "")), "tier": tier, "seed": int(hash(str(seed_value) + ":" + str(player.pid)))})
	var grants := []
	var waiting := []
	var rules := table() if catalog.is_empty() else catalog
	for pull in pending:
		var slot: String = pull.slot
		var inventory: Array = owned.get(slot, [])
		var reward := roll(pull.tier, inventory, pull.seed, rules)
		if reward.is_empty():
			waiting.append(pull)
			continue
		inventory.append(str(reward.id))
		owned[slot] = inventory
		reward["player"] = pull.name if players.size() > 1 else ""
		reward["slot"] = slot
		grants.append(reward)
	cfg.set_value("rewards", "receipts", receipts)
	cfg.set_value("rewards", "pending", waiting)
	cfg.set_value("rewards", "owned", owned)
	var temporary := path + ".tmp"
	if cfg.save(temporary) != OK or DirAccess.rename_absolute(temporary, path) != OK:
		error = "Could not save piñata rewards."
		return []
	return grants
