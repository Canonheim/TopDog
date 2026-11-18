extends "res://climber/practice_partner.gd"
func think(dt: float) -> void:
	arena.partner = self
	super.think(dt)
	arena.partner = null
