extends RefCounted
## LOBBY LOGIC: the pure half of the lobby browser (lifted from Golemheim's
## scripts/lobby_logic.gd, trimmed). Net hands it raw lobby-data dictionaries;
## these static funcs turn them into display rows. No Steam calls, no scene
## access, no preloads, so a headless battery can feed it fake lobbies.

## MUST MATCH net.gd LOBBY_TAG: on the shared dev app (480) this tag is the only
## thing keeping our lobbies apart from every other game testing there.
const GAME_TAG := "topdog"

const MODE_NAMES := {"tower": "Tower", "scramble": "Classic", "practice": "Practice"}


## in:  [{id, game, version, name, host, mode, count, max}]
## out: [{id, name, host, count_text, mode_line, joinable, reason, short}]
## Other games' lobbies drop; full or other-version lobbies stay visible but
## can't be joined (an empty list reads as a dead game).
static func rows_from(lobbies: Array, my_version: String) -> Array:
	var rows: Array = []
	for entry in lobbies:
		var data: Dictionary = entry
		if str(data.get("game", "")) != GAME_TAG:
			continue
		var count := int(data.get("count", 0))
		var cap := int(data.get("max", 0))
		var version := str(data.get("version", ""))
		var reason := ""
		var short := ""
		if version != my_version:
			reason = "Version %s (you have %s)" % [version if version != "" else "unknown", my_version]
			var order := version_order(version, my_version) if version != "" else 0
			short = "Older version" if order < 0 else ("Newer version" if order > 0 else "Other version")
		elif cap > 0 and count >= cap:
			reason = "Full"
			short = reason
		rows.append({
			"id": int(data.get("id", 0)),
			"name": str(data.get("name", "Unnamed lobby")),
			"host": str(data.get("host", "")),
			"count": count,
			"max": cap,
			"count_text": "%d/%d" % [count, cap],
			"mode_line": str(MODE_NAMES.get(str(data.get("mode", "")), "In the lobby")),
			"joinable": reason == "",
			"reason": reason,
			"short": short,
		})
	return rows


## -1 / 0 / 1: version a older than, the same as, newer than b, part by part.
static func version_order(a: String, b: String) -> int:
	var pa := a.split(".")
	var pb := b.split(".")
	for i in maxi(pa.size(), pb.size()):
		var x := pa[i].to_int() if i < pa.size() else 0
		var y := pb[i].to_int() if i < pb.size() else 0
		if x != y:
			return -1 if x < y else 1
	return 0
