extends RefCounted
## THE DRIVERS: what moves a climber. Every driver answers three things:
##   held(limb) -> bool          is that limb's button down
##   aim(climber, limb) -> Variant   null (hold the pose), {"dir": Vector2, "mag": float}
##                                   (a stick, y-up), or {"point": Vector2} (mouse, world m)
##   lock_pressed() -> bool      Lock In pressed this tick
## Limb order everywhere: 0 arm_l, 1 arm_r, 2 leg_l, 3 leg_r (screen sides).


## A local player on one device (Players.gd reads the hardware).
class LocalDriver:
	extends RefCounted
	var slot: int = 0  # Players slot

	func _init(p_slot: int) -> void:
		slot = p_slot

	func held(limb: int) -> bool:
		return Players.limb_held(slot, limb)

	func aim(climber, limb: int):
		return Players.limb_aim(slot, climber, limb)

	func lock_pressed() -> bool:
		return Players.lock_pressed(slot)


## Batteries and bots: set the fields, the climber obeys.
class ScriptDriver:
	extends RefCounted
	var holds := [false, false, false, false]
	var aims := [null, null, null, null]
	var lock := false

	func held(limb: int) -> bool:
		return holds[limb]

	func aim(_climber, limb: int):
		return aims[limb]

	func lock_pressed() -> bool:
		var l := lock
		lock = false
		return l

	func set_limb(limb: int, on: bool, dir := Vector2.ZERO, mag := 1.0) -> void:
		holds[limb] = on
		aims[limb] = null if dir == Vector2.ZERO else {"dir": dir, "mag": mag}

	func point_limb(limb: int, on: bool, point: Vector2) -> void:
		holds[limb] = on
		aims[limb] = {"point": point}

	func clear() -> void:
		holds = [false, false, false, false]
		aims = [null, null, null, null]


## A remote climber: never drives (its own machine does), only answers "not held".
class NullDriver:
	extends RefCounted

	func held(_limb: int) -> bool:
		return false

	func aim(_climber, _limb: int):
		return null

	func lock_pressed() -> bool:
		return false
