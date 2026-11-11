extends "res://climber/climber.gd"
## Ordinary player inputs only: no extra forces, automatic grips or teleports.
const BotDrivers = preload("res://climber/drivers.gd")
var arena: Node
var difficulty := "stationary"
var intent := "Stationary"
var brain := BotDrivers.ScriptDriver.new()
var selected := -1
var target := Vector2.ZERO
var action_time := 0.0
var settle_time := 0.0
var attack_time := 0.0
var attack_cooldown := 0.0
var swing_phase := 0.0
var disrupt_time := 0.0
var disrupt_cooldown := 0.0
var escape_time := 0.0
var escape_cooldown := 0.0
var last_limb := -1
var last_position := Vector2.ZERO
var stalled := 0.0
var best_height := -INF
var without_height := 0.0
var route_offset := 0.0
var home_side := 1.0
var placement_time := 0.0
var placement_limb := -1
var failed_targets := {}
var failed_limbs := [0, 0, 0, 0]
var replan_wait := 0.0
var route_replans := 0
# Tuning knobs also allow the calibration harness to compare its baseline policy.
var adapt_to_stalls := true
var placement_speed_limit := 5.0

func configure(game: Node, level: String) -> void:
	arena = game
	difficulty = level
	driver = brain
	brain.clear()
	selected = -1
	action_time = 0.0
	settle_time = 0.0
	attack_time = 0.0
	attack_cooldown = 0.0
	disrupt_time = 0.0
	disrupt_cooldown = 0.0
	escape_time = 0.0
	escape_cooldown = 0.0
	best_height = -INF
	without_height = 0.0
	home_side = signf(spawn_at.x - arena.tower_peak().x) if not arena.stage.delmar else -1.0
	if is_zero_approx(home_side):
		home_side = 1.0
	route_offset = randf_range(-0.35, 0.35) if level == "easy" else _launch_route()
	placement_time = 0.0
	failed_targets.clear()
	failed_limbs = [0, 0, 0, 0]
	replan_wait = 0.0
	route_replans = 0
	placement_limb = -1
	intent = "Stationary" if level == "stationary" else "Climb"

func _physics_process(dt: float) -> void:
	if is_instance_valid(arena) and state == State.LIVE and not growing():
		think(dt)
	super._physics_process(dt)

func think(dt: float) -> void:
	brain.clear()
	if difficulty == "stationary" or knockout_left > 0 or arena.phase not in ["turn", "round"]:
		return
	attack_cooldown = maxf(0.0, attack_cooldown - dt)
	disrupt_cooldown = maxf(0.0, disrupt_cooldown - dt)
	escape_cooldown = maxf(0.0, escape_cooldown - dt)
	settle_time = maxf(0.0, settle_time - dt)
	var pos := centre_of_mass()
	without_height += dt
	replan_wait += dt
	if adapt_to_stalls and without_height > 6.0 and replan_wait > (6.0 if difficulty == "hard" else 10.0):
		# A usable shelf may be inaccessible from this side of a new frozen body.
		# Try a different approach rather than repeat the same local moves forever.
		route_replans += 1
		route_offset = [0.6 * home_side, -0.6 * home_side, 0.0][route_replans % 3]
		selected = -1
		action_time = 0.0
		replan_wait = 0.0
	var progress: float = arena.measure(self)
	if progress > best_height + 0.08:
		best_height = progress
		without_height = 0.0
	stalled = stalled + dt if pos.distance_to(last_position) < 0.05 else 0.0
	if pos.distance_to(last_position) >= 0.05:
		last_position = pos
	var danger := false
	var foe: Climber = null
	var nearest := 3.0
	for opponent: Climber in arena.live_climbers():
		if opponent == self:
			continue
		for grip in opponent.limbs:
			if grip.grab_climber == self:
				danger = true
		var distance := pos.distance_to(opponent.centre_of_mass())
		if distance < nearest and opponent.knockout_left <= 0:
			nearest = distance
			foe = opponent
	var can_finish: bool = arena.partner_can_lock()
	var weapon = arena.chair
	var has_weapon: bool = is_instance_valid(weapon) and weapon.holder == climber_id
	var opportunity: bool = is_instance_valid(weapon) and (has_weapon or (weapon.holder == -1 and pos.distance_to(pos2(weapon.collider)) < 2.5))
	var fight: bool = difficulty == "hard" and not danger and foe != null and opportunity and attack_cooldown <= 0 and attack_time < 5.0 and is_attached()
	if can_finish and not fight:
		if difficulty == "hard" and not danger and not _shape_lock(dt):
			return
		arena.lock_partner()
		intent = "Locked in"
		return
	if difficulty == "hard" and danger and escape_cooldown <= 0:
		escape_time += dt
		if escape_time >= 1.2:
			escape_time = 0.0
			escape_cooldown = 2.5
		intent = "Escape grip"
		attack_time = 0.0
		var away := Vector2(0, 1)
		if foe != null:
			away = (pos - foe.centre_of_mass() + Vector2(0, 1.5)).normalized()
		if stuck_count() > 1:
			_choose_step()
			if selected >= 0:
				brain.point_limb(selected, true, target)
		else:
			_drive_free(away)
		return
	if fight:
		attack_time += dt
		if attack_time >= 5.0:
			attack_cooldown = 8.0
		if has_weapon:
			intent = "Chair strike"
			selected = weapon.limb
			swing_phase += dt * 5.0
			var head := pos2(foe.bodies.head)
			var side := signf(head.x - limb_root(selected).x)
			var offset := Vector2(-side * 1.3, 0.8) if fmod(swing_phase, 2.0) < 0.8 else Vector2(side * 1.2, -0.25)
			brain.point_limb(selected, true, head + offset)
		else:
			intent = "Reach chair"
			selected = _nearest_free_hand(pos2(weapon.collider))
			if selected >= 0:
				brain.point_limb(selected, true, pos2(weapon.collider))
		return
	attack_time = 0.0
	# A supported rival about to finish is worth a short disruption; distant or
	# already defeated players are not. Keep the terrain anchor while pulling.
	if difficulty == "hard" and foe != null and welded_to_support() and nearest < 1.5 and arena.measure(foe) > arena.line - 0.35 and disrupt_cooldown <= 0:
		disrupt_time += dt
		intent = "Disrupt rival"
		var holding_rival := false
		for grip in limbs:
			if grip.grab_climber == foe:
				holding_rival = true
		if holding_rival:
			_drive_free((centre_of_mass() - foe.centre_of_mass() + Vector2(0, -0.6)).normalized())
		else:
			var hand := _nearest_free_hand(pos2(foe.bodies.chest))
			if hand >= 0 and limb_end(hand).distance_to(pos2(foe.bodies.chest)) > 0.22:
				brain.point_limb(hand, true, pos2(foe.bodies.chest))
		if disrupt_time >= 2.0:
			disrupt_time = 0.0
			disrupt_cooldown = 8.0
		return
	if settle_time > 0:
		return
	intent = "Climb"
	if selected >= 0 and action_time > 0:
		action_time -= dt
		if limb_end(selected).distance_to(target) < 0.13 or action_time <= 0:
			if adapt_to_stalls and action_time <= 0 and limb_end(selected).distance_to(target) > 0.22:
				var key := Vector2i(roundi(target.x * 4), roundi(target.y * 4))
				failed_targets[key] = mini(int(failed_targets.get(key, 0)) + 1, 5)
				failed_limbs[selected] += 1
			last_limb = selected
			selected = -1
			settle_time = 0.18 if difficulty == "hard" else 0.35
			return
		brain.point_limb(selected, true, target)
		return
	_choose_step()
	if selected >= 0:
		brain.point_limb(selected, true, target)

func _nearest_free_hand(point: Vector2) -> int:
	var best := -1
	var distance := INF
	for i in 2:
		if limbs[i].grab_other != null and stuck_count() <= 1:
			continue
		var d := limb_end(i).distance_to(point)
		if d < distance:
			distance = d
			best = i
	return best

func _drive_free(direction: Vector2) -> void:
	# Change the driving limb when progress stalls instead of pulling a blocked hand forever.
	var start := int(without_height / (2.0 if difficulty == "hard" else 4.0)) % 4 if adapt_to_stalls else 0
	for n in 4:
		var i := (n + start) % 4
		if limbs[i].grab_other == null:
			brain.set_limb(i, true, direction)
			return
	var lowest := 0
	for i in 4:
		if limb_end(i).y < limb_end(lowest).y:
			lowest = i
	if stuck_count() > 1:
		brain.set_limb(lowest, true, direction)

func _choose_step() -> void:
	selected = -1
	var goal: Vector2 = arena.tower_peak() + Vector2(route_offset, 0.5)
	if arena.stage.delmar:
		goal = Vector2(arena.line - centre_of_mass().y + 0.8 + route_offset * 0.25, centre_of_mass().y + 1.0)
	# Unweight trailing grips before reaching: several floor welds pin the torso.
	# Each is lifted through the normal activator, then released away from the floor.
	if stuck_count() > 1:
		var trailing := -1
		var worst := -INF
		for i in 4:
			if limbs[i].grab_other == null:
				continue
			var score := limb_end(i).distance_to(goal) + (0.3 if i >= 2 else 0.0) - minf(failed_limbs[i] * 0.4, 1.6)
			if arena.stage.delmar and without_height > 3.0 and i == last_limb:
				score -= 2.0  # cycle pinned anchors instead of repeatedly lifting the same regripping hand
			if score > worst:
				worst = score
				trailing = i
		if trailing >= 0:
			selected = trailing
			var reach: float = limbs[trailing].l1 + limbs[trailing].l2
			var side := signf(goal.x - centre_of_mass().x)
			if limb_end(trailing).y > 0.25 and (not arena.stage.delmar or limbs[trailing].grab_climber == null or limbs[trailing].grab_climber.state == State.FROZEN):
				side = -side  # clear the wall before swinging, rather than push through it
			target = limb_root(trailing) + Vector2(side * 0.85, 0.55).normalized() * reach
			action_time = 0.75
			return
	# Walk the supporting foot toward the base before reaching above it.
	if absf(goal.x - centre_of_mass().x) > 1.35 and centre_of_mass().y < 1.5 and not arena.stage.delmar and _ground_anchor():
		for i in [2, 3]:
			if limbs[i].grab_other == null:
				selected = i
				var reach: float = limbs[i].l1 + limbs[i].l2
				target = Vector2(limb_root(i).x + signf(goal.x - centre_of_mass().x) * reach * 0.65, 0.045)
				action_time = 0.9
				return
	if not arena.stage.delmar and stuck_count() == 1 and without_height > 1.5:
		for anchor in limbs:
			if anchor.grab_other == null:
				continue
			var pivot := pos2(bodies[anchor.def.end])
			if pivot.y > 0.3:
				var radial := (centre_of_mass() - pivot).normalized()
				var side := signf(goal.x - pivot.x)
				if is_zero_approx(side):
					side = -1.0
				_drive_free(radial.orthogonal() * side)
				intent = "Build swing"
				return
	var best_score := -INF
	var excludes: Array[RID] = []
	for b: RigidBody3D in bodies.values():
		excludes.append(b.get_rid())
	for i in 4:
		if limbs[i].grab_other != null and stuck_count() <= 1:
			continue
		var root := limb_root(i)
		var reach: float = limbs[i].l1 + limbs[i].l2
		for sample in 32:
			var direction := Vector2.from_angle(TAU * sample / 32.0)
			var end := root + direction * reach * 1.12
			var query := PhysicsRayQueryParameters3D.create(Vector3(root.x, root.y, 0), Vector3(end.x, end.y, 0), LAYER_WORLD | LAYER_FROZEN, excludes)
			var hit: Dictionary = bodies.chest.get_world_3d().direct_space_state.intersect_ray(query)
			if hit.is_empty() or hit.collider.has_meta("no_weld"):
				continue
			var point := Vector2(hit.position.x, hit.position.y)
			var climb_axis: Vector2 = arena.stage.line_dir().normalized()
			if point.distance_to(limb_end(i)) < 0.22 or point.y < root.y - 0.15:
				continue
			var progress := limb_end(i).distance_to(goal) - point.distance_to(goal)
			var key := Vector2i(roundi(point.x * 4), roundi(point.y * 4))
			var score := progress * 2.0 + (point - limb_end(i)).dot(climb_axis) * 0.8 - float(failed_targets.get(key, 0)) * 0.5
			if i == last_limb:
				score -= 0.65
			if limbs[i].grab_other != null:
				score -= 0.25
			if score > best_score:
				best_score = score
				selected = i
				target = point - Vector2(hit.normal.x, hit.normal.y) * 0.03
	if selected >= 0 and best_score > 0.1:
		action_time = 0.8 if difficulty == "hard" else 1.1
	else:
		selected = -1
		var direction := (goal - centre_of_mass()).normalized()
		if arena.stage.delmar and stuck_count() == 1 and without_height > 1.5:
			# Look for a transferable hold first; only pump when none is reachable.
			for anchor in limbs:
				if anchor.grab_other != null:
					var pivot := pos2(bodies[anchor.def.end])
					var radial := (centre_of_mass() - pivot).normalized()
					direction = radial.orthogonal() * signf(goal.x - pivot.x)
					intent = "Build swing"
		elif stalled > 1.5:
			direction = Vector2(direction.x, 1.0).normalized()
		_drive_free(direction)






func _ground_anchor() -> bool:
	for i in 4:
		if limbs[i].grab_other != null and limb_end(i).y < 0.2:
			return true
	return false

## Prefer an upward-facing shelf on our approach side. Avoid repeating the last
## placement when two similarly usable shelves exist; no imagined support points.
func _launch_route() -> float:
	if bodies.is_empty() or arena.stage.delmar:
		return home_side * 0.2
	var peak: Vector2 = arena.tower_peak()
	var best := -INF
	var offset := home_side * 0.25
	for x in [-0.6, -0.3, 0.0, 0.3, 0.6]:
		var start := Vector3(peak.x + x, peak.y + 1.0, 0)
		var query := PhysicsRayQueryParameters3D.create(start, start - Vector3(0, 2.0, 0), LAYER_WORLD | LAYER_FROZEN)
		var hit: Dictionary = bodies.chest.get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty() or hit.collider.has_meta("no_weld"):
			continue
		var score: float = hit.normal.y * 1.5 + hit.position.y * 0.4 + x * home_side * 0.5
		if arena.partner_last_lock.is_finite():
			score += minf(absf(hit.position.x - arena.partner_last_lock.x), 0.6) * 0.6
		if score > best:
			best = score
			offset = x
	return offset

## Spend at most 1.2 seconds arranging free limbs, while keeping a real support.
## An outward foot makes a launch shelf; an arm across the rival side overhangs
## their approach. Actual limb reach, collisions and lock rules still decide.
func _shape_lock(dt: float) -> bool:
	placement_time += dt
	if placement_time >= 1.2 or linear_speed() > placement_speed_limit:
		return true  # bank a legal position rather than sacrifice it for a pose
	var foot_phase := placement_time < 0.6
	var choices := [2, 3] if foot_phase else [0, 1]
	placement_limb = -1
	for i in choices:
		if limbs[i].grab_other == null:
			placement_limb = i
			break
	if placement_limb < 0:
		return false
	var direction := Vector2(home_side, 0.2) if foot_phase else Vector2(-home_side, 0.05)
	brain.set_limb(placement_limb, true, direction.normalized(), 0.95)
	intent = "Build launch shelf" if foot_phase else "Obstruct rival approach"
	return false
