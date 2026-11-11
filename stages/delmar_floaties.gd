class_name DelMarFloaties
extends Node3D
## THE FLOATIES (Parker 11-10: "beach balls and large rubber duckies, and life savers
## and innertubes floating in the water that bounce you up if you fall on them like the
## ring ropes, but they send you up and slightly left (back towards the growing climber
## tower bridge), randomly floating around. The buoy passes through them as it moves,
## making them go to the left of the buoy"). The UI creator's float_* pieces.
##
## They're props, not bodies: each drifts on a seeded path (the same on every machine
## for the same match seed), bobs on the water, and is shoved left of the buoy. A
## climber's piece falling onto one's top is thrown up (as a fall into the ring ropes)
## and a little left; the floatie squashes. Not solid, so nobody welds to one.

const KINDS := [
	# [model, half-width, top above the water (the landing face), fallback colour,
	#  the model's tip toward the camera to undo (deg), how far it sinks (m)]
	# IN THE WATER (Parker 11-10: "make the things in the water actually look like they
	# are in the water, like flat in the water instead of standing weirdly up a little
	# facing the camera"): the rings lie flat and half under, the ball and duck sit down.
	["float_beachball", 0.5, 0.62, Color("#E23B3B"), 0.0, 0.18],
	["float_duck", 0.65, 0.75, Color("#FFC928"), 0.0, 0.1],
	["float_lifesaver", 0.6, 0.12, Color("#D8262E"), 30.0, 0.1],
	["float_innertube", 0.7, 0.18, Color("#7CC83A"), 25.0, 0.12],
]
const COUNT := 6
const LEFT_PUSH := 1.5  # m/s back toward the tower on a bounce
const BOUNCE_UP := 1.0  # x the fall speed, as the ring ropes' rope_bounce_up (at least MIN_UP)
const MIN_UP := 3.0
const BUOY_CLEAR := 0.9  # the least gap, buoy centre to floatie centre (the duck's is wider)
const BUOY_HALF := 0.5  # the classic buoy's float, half its width
const COOLDOWN := 0.3

var water_y := -1.8
var x_min := 104.5  # the open water's span, from the pier's end out
var x_max := 135.0
var buoy_x := 108.5
var _items: Array = []  # {node, kind, home, amp, freq, phase, x, squash_t, right}
var _last_buoy := INF
var _t := 0.0
var _cooldown := {}  # climber id -> seconds


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
			"home": rng.randf_range(x_min + 3.0, x_max - 2.0),
			"amp": rng.randf_range(1.5, 4.0), "freq": rng.randf_range(0.05, 0.12),
			"phase": rng.randf_range(0.0, TAU), "bob": rng.randf_range(0.0, TAU),
			"x": 0.0, "squash_t": 9.0, "right": true,
		})
	for it: Dictionary in _items:
		it.right = float(it.home) > buoy_x
	tick(0.0)


## Where the buoy is. The FIRST time (the match's start) every floatie is put out in
## the open water right of it: their sides were judged against a default buoy a
## couple of metres off, which pinned about one in five between the buoy and the pier.
var _placed := false
func set_buoy(x: float) -> void:
	if not _placed:
		_placed = true
		for it: Dictionary in _items:
			var clear := maxf(BUOY_CLEAR, BUOY_HALF + float(it.kind[1]) + 0.1)
			it.home = minf(maxf(float(it.home), x + clear + float(it.amp) + 0.2), x_max - 0.5)
			it.right = true
		_last_buoy = x
	buoy_x = x


func tick(delta: float) -> void:
	_t += delta
	for id in _cooldown.keys():
		_cooldown[id] = float(_cooldown[id]) - delta
		if float(_cooldown[id]) <= 0.0:
			_cooldown.erase(id)
	var buoy_moved := buoy_x > _last_buoy + 0.0005
	_last_buoy = buoy_x
	for it: Dictionary in _items:
		var x: float = float(it.home) + float(it.amp) * sin(_t * float(it.freq) * TAU + float(it.phase))
		var clear := maxf(BUOY_CLEAR, BUOY_HALF + float(it.kind[1]) + 0.1)  # never touching the float
		if bool(it.right):
			if x < buoy_x + clear:
				if buoy_moved:
					# The buoy, gliding out, passes through it: it ends up on the buoy's
					# left, and drifts there from now on.
					it.right = false
					it.home = buoy_x - clear - float(it.amp) - 0.3
				else:
					x = buoy_x + clear  # drifting into the buoy: it bumps and stops
		if not bool(it.right):
			x = minf(x, buoy_x - clear)
		x = clampf(x, x_min + float(it.kind[1]), x_max)
		it.x = x
		var bob := sin(_t * 1.6 + float(it.bob)) * 0.05
		var n: Node3D = it.node
		n.position = Vector3(x, water_y + bob, 0.0)
		n.rotation.z = sin(_t * 1.1 + float(it.bob)) * 0.06
		n.rotation.x = sin(_t * 0.9 + float(it.bob) * 1.3) * 0.05  # rocking on the swell
		n.rotation.y = float(it.bob) * 0.7  # each turned its own way on the water
		# The landing squash: down and wide, then two wobbles back.
		it.squash_t = float(it.squash_t) + delta
		var st: float = it.squash_t
		var sq := 0.0
		if st < 0.08:
			sq = st / 0.08
		elif st < 0.48:
			sq = exp(-(st - 0.08) * 6.0) * cos((st - 0.08) * 16.0)
		var sx := signf(n.scale.x) if n.scale.x != 0.0 else 1.0
		n.scale = Vector3(sx * (1.0 + 0.1 * sq), 1.0 - 0.18 * sq, 1.0 + 0.1 * sq)


## The owner's climbers only (their physics runs here): a piece coming down onto a
## floatie's top is thrown up and a little left. Returns the floatie it hit, or -1.
func bounce(c: Climber) -> int:
	if _cooldown.has(c.climber_id):
		return -1
	for i in _items.size():
		var it: Dictionary = _items[i]
		var half: float = it.kind[1]
		var top: float = water_y + float(it.kind[2])
		for b in c.bodies.values():
			var rb := b as RigidBody3D
			var p := rb.global_position
			if absf(p.x - float(it.x)) > half or p.y > top + 0.25 or p.y < water_y + 0.05 or rb.linear_velocity.y > -0.5:
				continue
			# The whole climber turns round, as the ring ropes throw (Climber.rope_throw):
			# a fall becomes a throw up, plus the push back toward the tower.
			var v := Vector2.ZERO
			for o in c.bodies.values():
				v += Vector2((o as RigidBody3D).linear_velocity.x, (o as RigidBody3D).linear_velocity.y) * (o as RigidBody3D).mass
			v /= maxf(c.total_mass, 0.001)
			var want := Vector2(minf(v.x, 0.0) - LEFT_PUSH, maxf(-v.y * BOUNCE_UP, MIN_UP))
			for o in c.bodies.values():
				var ob := o as RigidBody3D
				ob.linear_velocity.x += want.x - v.x
				ob.linear_velocity.y += want.y - v.y
			_cooldown[c.climber_id] = COOLDOWN
			it.squash_t = 0.0
			return i
	return -1


## Where floatie i floats now (x), for the ripple its squash makes.
func x_of(i: int) -> float:
	return float(_items[i].x) if i >= 0 and i < _items.size() else buoy_x


## Another machine's climber bounced on floatie i: squash it here too.
func squash(i: int) -> void:
	if i >= 0 and i < _items.size():
		_items[i].squash_t = 0.0
