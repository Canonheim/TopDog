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
		"name": "Scramble", "blurb": "Everyone at once. Every lock-in raises the line. Race to the easy spots.",
		"live": "all", "line": "raise", "round_end": "all_locked", "out": "under", "win": "last",
		"min_players": 1,
	},
	"practice": {
		"name": "Practice", "blurb": "Climb alone, no clock pressure. Best height counts.",
		"live": "turns", "line": "tower", "round_end": "lock", "out": "never", "win": "none",
		"min_players": 1, "practice": true,
	},
}

const TIMERS := [40.0, 60.0, 90.0]
const TIMER_NAMES := ["Short (40 s)", "Normal (1 min)", "Long (1 min 30)"]
const SPAWNS := ["alternate", "left", "right", "random"]
const SPAWN_NAMES := ["Alternating", "Left side", "Right side", "Random"]


static func row(id: String) -> Dictionary:
	return ROWS.get(id, ROWS.tower)


static func default_settings() -> Dictionary:
	return {"mode": "tower", "timer": 60.0, "spawn": "alternate", "stage": "plaza"}
