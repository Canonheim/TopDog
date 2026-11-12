class_name Modes
extends RefCounted
## THE MODES: each mode is a row. game/game.gd reads the row and runs the hooks
## named in it; nothing in the game assumes one live climber.
##
## live:     "turns"  one climber at a time, in turn order
##           "all"    everyone still in, at once
## line:     "tower"  the tower's top before the turn
##           "raise"  starts at last round's max height, and every lock-in above
##                    it raises it to that climber's top
## round_end "lock"   a turn ends at the climber's lock-in or the clock
##           "all_locked"  a round ends when everyone still in has locked in
## out:      "under"  frozen under the line = out (the body stays in the tower)
## win:      "last"   the last one in wins
## practice: true     nobody is ever out; best height is the score

const ROWS := {
	"tower": {
		"name": "Tower", "blurb": "Take turns. Lock in above the top before the clock runs out.",
		"live": "turns", "line": "tower", "round_end": "lock", "out": "under", "win": "last",
		"min_players": 1,
	},
	"scramble": {
		"name": "Classic", "blurb": "One versus one. Rotate opponents so everyone plays everyone.",
		"live": "all", "line": "raise", "round_end": "all_locked", "out": "under", "win": "last",
		"min_players": 2, "round_robin": true,
	},
	# DEL MAR (Parker 11-10, docs/DEL_MAR.md): Classic's 1v1 rotation off the end of a
	# pier, building out over the sea past a 45 degree rope. arena "delmar" builds the
	# pier; the line runs along (1, 1) and sits line_gap past the tower's furthest point.
	"delmar": {
		"name": "Del Mar", "blurb": "One versus one off the end of the pier. Build out over the sea, past the rope.",
		"live": "all", "line": "raise", "round_end": "all_locked", "out": "under", "win": "last",
		"min_players": 2, "round_robin": true, "arena": "delmar", "line_gap": 0.25,
	},
	# THE PEAK OF DEGAYO (Parker 11-11, docs/peak/PEAK_DESIGN.md): the solo climb. arena
	# "peak" builds the mountain (stages/peak/peak.gd); no clock, no line, no lock-in.
	"peak": {
		"name": "The Peak of DeGayo", "blurb": "Alone, up the mountain. 1,000 metres, no checkpoints.",
		"live": "turns", "line": "tower", "round_end": "lock", "out": "never", "win": "none",
		"min_players": 1, "practice": true, "arena": "peak",
	},
	"practice": {
		"name": "Practice", "blurb": "Climb alone, no clock pressure. Best height counts.",
		"live": "turns", "line": "tower", "round_end": "lock", "out": "never", "win": "none",
		"min_players": 1, "practice": true,
	},
}

const TIMERS := [45.0, 60.0, 90.0, 120.0, 180.0]
const TIMER_NAMES := ["45 S", "1 Min", "1:30", "2 Min", "3 Min"]
const BASES := ["random", "barrel", "cactus", "donkey", "bell"]
const STARTING_BASES := ["barrel", "cactus", "donkey", "bell"]
const BASE_NAMES := ["Random", "Barrel", "Cactus", "Donkey", "Bell"]

const SPAWNS := ["alternate", "left", "right", "random"]
const SPAWN_NAMES := ["Alternating", "Left side", "Right side", "Random"]


static func row(id: String) -> Dictionary:
	return ROWS.get(id, ROWS.scramble)


static func default_settings() -> Dictionary:
	return {"mode": "scramble", "timer": 60.0, "spawn": "alternate", "stage": "plaza", "base": "random"}


## One match for every unordered pair, starting with adjacent lobby players.
## Three players play 1v2, 2v3, 3v1, in that order.
static func round_robin(players: Array) -> Array:
	var pairs: Array = []
	var seen := {}
	for gap in range(1, players.size()):
		for i in players.size():
			var j := (i + gap) % players.size()
			var key := Vector2i(mini(i, j), maxi(i, j))
			if not seen.has(key):
				seen[key] = true
				pairs.append([players[i], players[j]])
	return pairs


## Training keeps the selected game's arena and target-line rules, but runs
## one player indefinitely without a timer, elimination or a 1v1 requirement.
static func practice_row(id: String) -> Dictionary:
	var selected := id if id in ["scramble", "tower", "delmar"] else "scramble"
	var result := row(selected).duplicate(true)
	result.merge({"name": "Practice", "live": "turns", "round_end": "lock", "out": "never", "win": "none", "min_players": 1, "practice": true}, true)
	result.erase("round_robin")
	return result
