class_name DelMarFloaties
extends Node3D
## THE FLOATIES (Parker 11-10: "beach balls and large rubber duckies, and life savers
## and innertubes floating in the water that bounce you up if you fall on them like the
## ring ropes, but they send you up and slightly left (back towards the growing climber
## tower bridge), randomly floating around"). The UI creator's float_* pieces. They drift
## free over the whole open water, on the climbers' plane where a fall lands on them
## (Parker 11-11): the buoy stands back out of their way (Stage.BUOY_Z) and no longer
## herds them.
##
## They're props, not bodies: each drifts from a seeded start (the same on every machine
## for the same match seed), bumps slowly off its neighbours and the ends of the open
## water (Parker 11-12: "the floating things were all phasing through eachother. Make
## them slowly bounce off eachother"), and bobs on the water. A
## climber's piece falling onto one's top is thrown up (as a fall into the ring ropes)
## and a little left; the floatie squashes. Not solid, so nobody welds to one.

const KINDS := [
	# [model, half-width, top above the water (the landing face), fallback colour,
	#  the model's tip toward the camera to undo (deg), how far it sinks (m),
	#  its boing's pitch (the small ball high, the big tube low)]
	# IN THE WATER (Parker 11-10: "make the things in the water actually look like they
	# are in the water, like flat in the water instead of standing weirdly up a little
	# facing the camera"): the rings lie flat and half under, the ball and duck sit down.
	["float_beachball", 0.5, 0.62, Color("#E23B3B"), 0.0, 0.18, 1.22],
	["float_duck", 0.65, 0.75, Color("#FFC928"), 0.0, 0.1, 1.08],
	["float_lifesaver", 0.6, 0.12, Color("#D8262E"), 30.0, 0.1, 0.96],
	["float_innertube", 0.7, 0.18, Color("#7CC83A"), 25.0, 0.12, 0.84],
]
const COUNT := 6
const LEFT_PUSH := 1.5  # m/s back toward the tower on a bounce
## STRONGER (Parker 11-11: "they need to be stronger so they can send you at least as
## far back up as you fell down"): the throw is worked out from the height fallen (the
## highest the climber's centre was since it last held on), with the air drag and the
## free-fall gravity it will rise against, and a margin over it.
const RISE_MARGIN := 1.12  # x the height fallen
const RISE_EXTRA := 0.35  # m on top
const MIN_RISE := 1.6  # m, even off a little hop
const MAX_RISE := 18.0
const MIN_UP := 3.0
const COOLDOWN := 0.3
## THE SQUASH (Parker 11-11: "the bouncy floats should have animation"): a hit dunks the
## floatie, squashes it flat and wide, then it springs up tall and wobbles back, rocking.
const SQUASH_S := 1.1
const SQUASH_DEEP := 0.42  # how flat at the bottom of the squash
const DUNK := 0.26  # m pushed under at the squash

var water_y := -1.8
var x_min := 104.5  # the open water's span, from the pier's end out
var x_max := 135.0
var _items: Array = []  # {node, kind, home, amp, freq, phase, x, squash_t}
var _t := 0.0
var _cooldown := {}  # climber id -> seconds
var _peak := {}  # climber id -> the highest its centre has been since it last held on
const DRIFT_MIN := 0.25  # m/s: how fast a floatie drifts
const DRIFT_MAX := 0.6
const GAP := 0.25  # m of clear water kept between two at the start
var _order: Array = []  # the floaties' indices from the pier out (it never changes)
var drifting := true  # (tests still the water to drop a climber on one floatie)


func setup(seed_value: int, p_water_y: float, p_x_min: float, p_x_max: float) -> void:
	water_y = p_water_y
	x_min = p_x_min
	x_max = p_x_max
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in COUNT:
		var kind: Array = KINDS[i % KINDS.size()]
		var model := LuchaKit.kit_model(str(kind[0]))
		var node := Node3D.new()  # the drifting pivot at the waterline; the model sits in it
		if model != null:
			# Shaded smooth (Parker 11-10: "shade the floating bouncy things smooth"): they're
			# inflated rubber, not faceted.
			for mi in model.find_children("*", "MeshInstance3D", true, false):
				LuchaKit.smooth_normals(mi as MeshInstance3D)
			if model is MeshInstance3D:
				LuchaKit.smooth_normals(model as MeshInstance3D)
			model.rotation.x = -deg_to_rad(float(kind[4]))  # lie flat on the water
			model.position.y = -float(kind[5])
			node.add_child(model)
		else:
			var m := MeshInstance3D.new()
			var sph := SphereMesh.new()
			sph.radius = float(kind[1])
			sph.height = float(kind[1]) * 1.2
			m.mesh = sph
			CelPass.paint(m, kind[3])
			m.position.y = float(kind[2]) * 0.5
			node.add_child(m)
		if str(kind[0]) == "float_duck" and rng.randf() < 0.5:
			node.scale.x = -1.0  # a left-facing duck
		add_child(node)
		_items.append({
			"node": node, "kind": kind,
			"v": rng.randf_range(DRIFT_MIN, DRIFT_MAX) * (1.0 if rng.randf() < 0.5 else -1.0),
			"bob": rng.randf_range(0.0, TAU),
			"x": 0.0, "squash_t": 9.0, "hit_dir": 1.0, "bump_t": 9.0, "bump_dir": 1.0,
		})
	# Set out along the water in a seeded order, a seeded gap between each: never one
	# inside another. They keep this order for the whole match (they bump, they don't pass).
	var order: Array = range(COUNT)
	for i in range(COUNT - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap = order[i]
		order[i] = order[j]
		order[j] = swap
	_order = order
	var widths := 0.0
	for it: Dictionary in _items:
		widths += float(it.kind[1]) * 2.0
	var spare := maxf(0.0, (x_max - x_min) - widths - GAP * (COUNT + 1))
	var cuts: Array = []
	for i in COUNT + 1:
		cuts.append(rng.randf())
	var total := 0.0
	for c in cuts:
		total += float(c)
	var x := x_min
	for k in COUNT:
		var it: Dictionary = _items[int(_order[k])]
		x += GAP + spare * float(cuts[k]) / maxf(total, 0.001) + float(it.kind[1])
		it.x = x
		x += float(it.kind[1])
	tick(0.0)


func tick(delta: float) -> void:
	_t += delta
	for id in _cooldown.keys():
		_cooldown[id] = float(_cooldown[id]) - delta
		if float(_cooldown[id]) <= 0.0:
			_cooldown.erase(id)
	_drift(delta)
	for it: Dictionary in _items:
		var x: float = it.x
		it.bump_t = float(it.bump_t) + delta
		var bob := sin(_t * 1.6 + float(it.bob)) * 0.05
		var n: Node3D = it.node
		# The landing: squashed flat and dunked in 0.07 s, then a springy rebound (tall
		# and thin, flat again, smaller each time) and a rock away from the hit.
		it.squash_t = float(it.squash_t) + delta
		var st: float = it.squash_t
		var sq := 0.0  # 1 = squashed flat, -1 = stretched tall
		var rock := 0.0
		if st < 0.07:
			sq = st / 0.07
		elif st < SQUASH_S:
			var u := st - 0.07
			sq = exp(-u * 4.2) * cos(u * 15.0)
			rock = exp(-u * 3.5) * sin(u * 11.0) * 0.32 * float(it.hit_dir)
		var dunk := maxf(sq, 0.0) * DUNK - maxf(-sq, 0.0) * DUNK * 0.35
		n.position = Vector3(x, water_y + bob - dunk, 0.0)
		# (a bump off a neighbour: a small rock away from it, dying off)
		var bt: float = it.bump_t
		if bt < 1.2:
			rock += exp(-bt * 3.0) * sin(bt * 9.0) * 0.16 * float(it.bump_dir)
		n.rotation.z = sin(_t * 1.1 + float(it.bob)) * 0.06 + rock
		n.rotation.x = sin(_t * 0.9 + float(it.bob) * 1.3) * 0.05  # rocking on the swell
		n.rotation.y = float(it.bob) * 0.7  # each turned its own way on the water
		var sx := signf(n.scale.x) if n.scale.x != 0.0 else 1.0
		var wide := 1.0 + (0.28 if sq > 0.0 else 0.16) * sq
		var tall := 1.0 - (SQUASH_DEEP if sq > 0.0 else 0.3) * sq
		n.scale = Vector3(sx * wide, tall, wide)


## The drift, in fixed steps of the physics clock, so every machine's water agrees: each
## floatie moves at its own slow speed, turns back at the pier's end and the far end, and
## where two meet they bounce: the heavier (wider) one is turned less.
func _drift(delta: float) -> void:
	if delta <= 0.0 or not drifting or _order.size() != _items.size():
		return
	for it: Dictionary in _items:
		it.x = float(it.x) + float(it.v) * delta
		var r: float = it.kind[1]
		if float(it.x) < x_min + r:
			it.x = x_min + r
			it.v = absf(float(it.v))
		elif float(it.x) > x_max - r:
			it.x = x_max - r
			it.v = -absf(float(it.v))
	for k in _order.size() - 1:
		var a: Dictionary = _items[int(_order[k])]
		var b: Dictionary = _items[int(_order[k + 1])]
		var ra: float = a.kind[1]
		var rb: float = b.kind[1]
		var over := float(a.x) + ra + rb - float(b.x)
		if over <= 0.0:
			continue
		# Apart again, each by its share; and if they are closing, the bounce.
		var ma := ra * ra
		var mb := rb * rb
		a.x = float(a.x) - over * mb / (ma + mb)
		b.x = float(b.x) + over * ma / (ma + mb)
		var va: float = a.v
		var vb: float = b.v
		if va > vb:
			a.v = ((ma - mb) * va + 2.0 * mb * vb) / (ma + mb)
			b.v = ((mb - ma) * vb + 2.0 * ma * va) / (ma + mb)
			a.bump_t = 0.0
			a.bump_dir = 1.0
			b.bump_t = 0.0
			b.bump_dir = -1.0
	# (never becalmed: a floatie the bumps have all but stopped is given its slow way back)
	for it: Dictionary in _items:
		if absf(float(it.v)) < DRIFT_MIN * 0.5:
			it.v = DRIFT_MIN * (1.0 if float(it.v) >= 0.0 else -1.0)


## The owner's climbers only (their physics runs here): a piece coming down onto a
## floatie's top is thrown up and a little left. Returns the floatie it hit, or -1.
func bounce(c: Climber) -> int:
	var com := c.centre_of_mass()
	if c.is_attached() or not _peak.has(c.climber_id):
		_peak[c.climber_id] = com.y
	else:
		_peak[c.climber_id] = maxf(float(_peak[c.climber_id]), com.y)
	if _cooldown.has(c.climber_id) or c.sinking:
		return -1
	for i in _items.size():
		var it: Dictionary = _items[i]
		var half: float = it.kind[1]
		var top: float = water_y + float(it.kind[2])
		for b in c.bodies.values():
			var rb := b as RigidBody3D
			var p := rb.global_position
			if absf(p.x - float(it.x)) > half or p.y > top + 0.3 or p.y < water_y - 0.12 or rb.linear_velocity.y > -0.5:
				continue
			# The whole climber turns round, as the ring ropes throw (Climber.rope_throw):
			# a fall becomes a throw up, plus the push back toward the tower.
			var v := Vector2.ZERO
			for o in c.bodies.values():
				v += Vector2((o as RigidBody3D).linear_velocity.x, (o as RigidBody3D).linear_velocity.y) * (o as RigidBody3D).mass
			v /= maxf(c.total_mass, 0.001)
			var fall := maxf(0.0, float(_peak[c.climber_id]) - com.y)
			var rise := clampf(fall * RISE_MARGIN + RISE_EXTRA, MIN_RISE, MAX_RISE)
			var want := Vector2(minf(v.x, 0.0) - LEFT_PUSH, maxf(maxf(-v.y, MIN_UP), up_speed_for(rise, rb)))
			for o in c.bodies.values():
				var ob := o as RigidBody3D
				ob.linear_velocity.x += want.x - v.x
				ob.linear_velocity.y += want.y - v.y
			_cooldown[c.climber_id] = COOLDOWN
			it.squash_t = 0.0
			it.hit_dir = -1.0 if p.x > float(it.x) else 1.0
			return i
	return -1


## The speed straight up that rises `rise` metres against this body's gravity and air
## drag (Godot's linear damp is a drag k on the speed: h(v) = v/k - g/k^2 ln(1 + k v/g)).
## Free-fall gravity: once thrown, the climber holds nothing.
static func up_speed_for(rise: float, rb: RigidBody3D) -> float:
	var g: float = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)) * Feel.climber_gravity(false)
	var k := rb.linear_damp
	if rb.linear_damp_mode == RigidBody3D.DAMP_MODE_COMBINE:
		k += float(ProjectSettings.get_setting("physics/3d/default_linear_damp", 0.1))
	g = maxf(g, 0.01)
	if k < 0.0001:
		return sqrt(2.0 * g * rise)
	var lo := 0.0
	var hi := 80.0
	for _n in 40:
		var v := (lo + hi) * 0.5
		var h := v / k - g / (k * k) * log(1.0 + k * v / g)
		if h < rise:
			lo = v
		else:
			hi = v
	return hi


## Its boing's pitch.
func pitch_of(i: int) -> float:
	return float(_items[i].kind[6]) if i >= 0 and i < _items.size() else 1.0


## Where floatie i floats now (x), for the ripple its squash makes.
func x_of(i: int) -> float:
	return float(_items[i].x) if i >= 0 and i < _items.size() else x_min


## Another machine's climber bounced on floatie i: squash it here too.
func squash(i: int) -> void:
	if i >= 0 and i < _items.size():
		_items[i].squash_t = 0.0
