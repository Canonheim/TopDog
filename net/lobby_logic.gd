extends RefCounted
## LOBBY LOGIC (Online-Lobbies.md §3/§7, 2026-07-07) — the PURE half of
## the Wizard's lobby browser. Net.request_lobby_list delivers raw
## lobby-data Dictionaries; these static funcs turn them into display
## rows and pick Quick Play's target. DELIBERATELY DEPENDENCY-FREE: no
## Steam calls, no scene access, no preloads (a preload of net.gd or
## game_modes.gd drags the whole fighter chain into the headless battery,
## where autoload identifiers don't compile) — so scripts/lobby_test.gd
## can push fake lobby dicts straight through, per the spec's headless
## caveat. The UI (hub_menu_multiplayer.gd) routes through here too:
## one brain, drawn and tested.

## MUST MATCH net.gd LOBBY_TAG (both sides carry this law): the "game"
## lobby-data key that keeps Golemheim lobbies apart from every other
## build on the shared dev appid (480 in the appid-480 days; the game's
## own 5196400 since the Steamworks move) — §4.
const GAME_TAG := "golemheim"  # the retitle, 2026-08-26 — must equal
							   # net.gd's LOBBY_TAG (THE DRIFT LAW pin)

## Browser names for the mode ids. The keys are Modes' MODE_* values —
## literal here (not ModesScript.MODE_FFA) to keep this file preload-free;
## a new mode means one entry here beside its game_modes.gd const.
const MODE_NAMES := {
	"ffa": "Free-for-All",
	"elim": "Elimination",
	"tdm": "Team Deathmatch",  # was missing (2026-07-14) — browsers showed "Tdm"
	"dom": "Domination",
	"muster": "The Muster",    # THE MUSTER (2026-09-27)
	"powder": "War Domination",  # WAR DOMINATION (2026-09-29, named 2026-09-30; powder_data.MODE_NAME)
	"haul": "The Haul",          # THE HAUL (2026-10-07; docs/THE-HAUL.md)
}
const MODE_PRACTICE := "practice"  # mirrors Modes.MODE_PRACTICE
const MAP_HUB := "hub"             # the hub's id in Modes.MAPS


## Lobby-data dicts -> browser rows, one per Golemheim lobby.
## in:  {id, game, version, name, host, mode, map, map_name, count, max}
## out: {id, name, host, count, max, count_text "3/8", mode_line,
##       joinable, reason ("" when joinable), short (the reason in a word or
##       two, for the row's Join slot: "Full", "Older version", "Newer
##       version" — round 1's review, 2026-09-30)}
## `my_version` is a PARAMETER, not a global read, so the battery can test
## mismatches. Wrong-game lobbies drop outright — the dev appid was shared
## with every dev on earth (§4); full/mismatched Golemheim lobbies stay VISIBLE but
## unjoinable (players should see activity — an empty list reads as a
## dead game). `parked` = the mode and map ids this build hasn't got (THE HAUL PARKED, 2026-11-01: the caller
## passes Modes.parked_keys()): a lobby playing one, or standing on one, drops outright like a wrong-game lobby.
static func rows_from(lobbies: Array, my_version: String, parked: Array = []) -> Array:
	var rows: Array = []
	for entry in lobbies:
		var data: Dictionary = entry
		if str(data.get("game", "")) != GAME_TAG:
			continue
		if str(data.get("mode", "")) in parked or str(data.get("map", "")) in parked:
			continue
		var count := int(data.get("count", 0))
		var cap := int(data.get("max", 0))
		var version := str(data.get("version", ""))
		var reason := ""
		var short := ""
		if version != my_version:
			reason = "Version %s (you have %s)" % [
					version if version != "" else "unknown", my_version]
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
			"mode_line": mode_line(str(data.get("mode", "")),
					str(data.get("map", "")), str(data.get("map_name", ""))),
			"joinable": reason == "",
			"reason": reason,
			"short": short,
		})
	return rows


## -1 / 0 / 1: version `a` older than, the same as, newer than `b`, part by
## dotted part ("0.1.5" < "0.1.7" < "0.2"; a part that isn't a number reads 0).
static func version_order(a: String, b: String) -> int:
	var pa := a.split(".")
	var pb := b.split(".")
	for i in maxi(pa.size(), pb.size()):
		var x := pa[i].to_int() if i < pa.size() else 0
		var y := pb[i].to_int() if i < pb.size() else 0
		if x != y:
			return -1 if x < y else 1
	return 0


## The row's what-are-they-doing line: "In the hub", "Free-for-All on
## Brawl Flats", "Free-for-All at the hub" (any mode CAN run at the hub).
## `map_name` is the display name the HOST wrote from its Modes.MAPS
## registry (the one source of truth); a missing one — old build, hand-fed
## battery dict — prettifies the id instead ("brawl_flats" -> "Brawl
## Flats"). "" mode (a lobby older than its host's first mode write)
## reads as hub.
static func mode_line(mode: String, map: String, map_name := "") -> String:
	if mode == "" or mode == MODE_PRACTICE:
		return "In the hub"
	var mode_text := str(MODE_NAMES.get(mode, mode.capitalize()))
	if map == "" or map == MAP_HUB:
		return "%s at the hub" % mode_text
	return "%s on %s" % [mode_text,
			map_name if map_name != "" else map.capitalize()]


## Quick Play's brain (§3): the best JOINABLE row — most players first
## (fuller games are better games at this scale; ping-region filtering is
## a later nicety). {} = nothing joinable, offer Host Now instead.
static func pick_quick_play(rows: Array) -> Dictionary:
	var best := {}
	for entry in rows:
		var row: Dictionary = entry
		if not bool(row.get("joinable", false)):
			continue
		if best.is_empty() or int(row.get("count", 0)) > int(best.get("count", 0)):
			best = row
	return best
