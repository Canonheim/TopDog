extends Node
## THE RAIN TEST: where does a miss land? For every challenge, three bodies are dropped
## beside and just above its start and followed down the real mountain. A body stops when it
## touches grip (a climber would catch there), floats off down any water it meets, and is
## reported as a POCKET if it comes to rest on slick (a softlock) or LOST if it leaves the
## world. Writes docs/peak/FALLS.md (the designed cost beside what happened).
##   Godot_console.exe --headless --path . res://tests/peak_falls.tscn
const R := 0.4
const MAX_S := 150.0

var pk: Peak
var balls: Array = []


func _ready() -> void:
	var world := Node3D.new()
	add_child(world)
	pk = Peak.new()
	world.add_child(pk)
	pk.setup(null)
	pk.begin()
	pk.dev_warp = true
	for i in 3:
		await get_tree().physics_frame  # (the world's bodies must be in the space before it is asked)
	for c in pk.challenges:
		var a := Peak.v2(c.anchor)
		for off in [Vector2(-2.5, 3.0), Vector2(2.5, 3.0), Vector2(0.0, 4.5)]:
			var at: Vector2 = a + off
			if _in_rock(at):
				at = a + Vector2(0.0, 2.2)  # (that spot is inside the rock: drop from just over the start)
			if not _in_rock(at):
				_drop(c, at)
	await get_tree().physics_frame
	print("RAIN %d bodies over %d challenges" % [balls.size(), pk.challenges.size()])
	var hz := Engine.physics_ticks_per_second
	var t := 0.0
	while t < MAX_S:
		pk.tick(1.0 / hz)
		await get_tree().physics_frame
		t += 1.0 / hz
		var live := 0
		for b in balls:
			if str(b.end) == "":
				live += 1
				_step(b, t, 1.0 / hz)
		if live == 0:
			break
	_report()
	get_tree().quit()


func _in_rock(at: Vector2) -> bool:
	var q := PhysicsShapeQueryParameters3D.new()
	var sph := SphereShape3D.new()
	sph.radius = R
	q.shape = sph
	q.transform = Transform3D(Basis(), Vector3(at.x, at.y, 0) + pk.global_position)
	q.collision_mask = Climber.LAYER_WORLD
	return not pk.get_world_3d().direct_space_state.intersect_shape(q, 1).is_empty()


func _drop(c: Dictionary, at: Vector2) -> void:
	var rb := RigidBody3D.new()
	rb.mass = 22.0
	rb.gravity_scale = 9.8 * Feel.climber_gravity(false) / 9.8
	rb.linear_damp = 0.05
	rb.collision_layer = Climber.LAYER_PROP
	rb.collision_mask = Climber.LAYER_WORLD
	rb.axis_lock_linear_z = true
	rb.axis_lock_angular_x = true
	rb.axis_lock_angular_y = true
	rb.contact_monitor = true
	rb.max_contacts_reported = 4
	rb.can_sleep = false
	var pm := PhysicsMaterial.new()
	pm.friction = 0.6
	rb.physics_material_override = pm
	var cs := CollisionShape3D.new()
	var s := SphereShape3D.new()
	s.radius = R
	cs.shape = s
	rb.add_child(cs)
	pk.add_child(rb)
	rb.position = Vector3(at.x, at.y, 0)
	balls.append({"rb": rb, "from": str(c.id), "miss": str(c.miss), "start": at, "end": "", "at": at, "still": 0.0, "low": at.y, "water": false, "born": 0.0})


func _step(b: Dictionary, t: float, dt: float) -> void:
	var rb: RigidBody3D = b.rb
	var p := Vector2(rb.position.x, rb.position.y)
	b.low = minf(float(b.low), p.y)
	if p.y < -70.0 or p.y > 1070.0 or p.x < -490.0 or p.x > 40.0:
		_end(b, "LOST", p)
		return
	# Water: float at the surface and ride the current.
	for row in pk.zones.waters:
		var z: Dictionary = row.def
		if Peak.rect_has(z.rect, p, 0.3) and p.y < float(z.surface) + 0.2:
			var flow := Peak.v2(z.flow)
			b.water = true
			if flow.length() < 0.15:
				_end(b, "water", p)
				return
			rb.linear_velocity = Vector3(flow.x, clampf((float(z.surface) - p.y) * 4.0, -2.0, 2.0) + flow.y, 0)
			return
	if t < 0.25:
		return
	for o in rb.get_colliding_bodies():
		if o == null or not is_instance_valid(o):
			continue
		if not (o as Node).has_meta("no_weld"):
			_end(b, "grip", p)
			return
	if rb.linear_velocity.length() < 0.12:
		b.still = float(b.still) + dt
		if float(b.still) > 2.5:
			_end(b, "POCKET", p)
	else:
		b.still = 0.0


func _end(b: Dictionary, how: String, p: Vector2) -> void:
	b.end = how
	b.at = p
	(b.rb as RigidBody3D).freeze = true


func _nearest(p: Vector2) -> Dictionary:
	var best := {}
	var best_d := INF
	for c in pk.challenges:
		var d := Peak.v2(c.anchor).distance_to(p)
		if d < best_d:
			best_d = d
			best = c
	return best


func _report() -> void:
	var lines: Array = ["# Where a miss lands (the rain test)", "",
		"Three bodies dropped beside and above every challenge's start, followed down the real mountain (`tests/peak_falls.tscn`). A body stops at the first grip it touches (a climber could catch there), rides any current it meets, and is flagged **POCKET** if it comes to rest on slick (a softlock) or **LOST** if it leaves the world. `Lost` is the height given up. The designed cost is the `Miss` column of CHALLENGES.md.", "",
		"| From | Designed | Ends (3 drops) | Lost (m) |", "|---|---|---|---|"]
	var by := {}
	var pockets := 0
	var lost := 0
	var running := 0
	for b in balls:
		if not by.has(b.from):
			by[b.from] = []
		(by[b.from] as Array).append(b)
	for c in pk.challenges:
		var id := str(c.id)
		var ends: Array = []
		var drops: Array = []
		for b in by.get(id, []):
			var how := str(b.end)
			var p: Vector2 = b.at
			if how == "":
				how = "still moving"
				running += 1
				p = Vector2((b.rb as RigidBody3D).position.x, (b.rb as RigidBody3D).position.y)
			if how == "POCKET":
				pockets += 1
			if how == "LOST":
				lost += 1
			var near := _nearest(p)
			var via := " via water" if bool(b.water) and how != "water" else ""
			ends.append("%s near %s at (%d, %d)%s" % [how, str(near.get("id", "?")), int(p.x), int(p.y), via])
			drops.append("%d" % int((b.start as Vector2).y - p.y))
		lines.append("| %s %s | %s | %s | %s |" % [id, str(c.name), str(c.miss), "; ".join(ends), ", ".join(drops)])
	lines.append("")
	lines.append("**Totals:** %d bodies, %d pockets (softlocks), %d lost from the world, %d still moving after %d s." % [balls.size(), pockets, lost, running, int(MAX_S)])
	var f := FileAccess.open("res://docs/peak/FALLS.md", FileAccess.WRITE)
	f.store_string("\n".join(lines) + "\n")
	f.close()
	print("RAIN done: %d pockets, %d lost, %d still moving" % [pockets, lost, running])
	for b in balls:
		if str(b.end) in ["POCKET", "LOST"]:
			print("RAIN %s from %s at %s" % [b.end, b.from, b.at])
