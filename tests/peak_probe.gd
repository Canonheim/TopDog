extends Node
## THE PEAK'S MEASURES: what a climber can reach and how far a pumped swing throws it.
## The solo climb (docs/peak/PEAK_DESIGN.md) is laid out against these numbers.
##   Godot_console.exe --headless --path . res://tests/peak_probe.tscn
const ClimberScript := preload("res://climber/climber.gd")
const Drivers := preload("res://climber/drivers.gd")

var world: Node3D
var _next_id := 700


func frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func spawn(feet: Vector2) -> Climber:
	var c: Climber = ClimberScript.new()
	c.climber_id = _next_id
	_next_id += 1
	add_child(c)
	c.build(feet, world, null)
	c.driver = Drivers.ScriptDriver.new()
	return c


func static_box(centre: Vector2, half: Vector2) -> StaticBody3D:
	var sb := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var r := BoxShape3D.new()
	r.size = Vector3(half.x * 2.0, half.y * 2.0, 2.0)
	col.shape = r
	sb.add_child(col)
	sb.collision_layer = Climber.LAYER_WORLD
	sb.collision_mask = 0
	sb.position = Vector3(centre.x, centre.y, 0)
	world.add_child(sb)
	Climber.sync_server(sb)
	return sb


func _ready() -> void:
	world = Node3D.new()
	add_child(world)
	var hz := Engine.physics_ticks_per_second
	var g := 9.8 * Feel.climber_gravity(false)
	print("PEAK gravity free %.3f m/s2, latched %.3f, hz %d" % [g, 9.8 * Feel.climber_gravity(true), hz])
	# ---- A. standing measures
	var floor_sb := static_box(Vector2(0, -0.5), Vector2(40, 0.5))
	var c := spawn(Vector2(0, 0))
	await frames(int(0.8 * hz))
	var d: Drivers.ScriptDriver = c.driver
	print("PEAK standing: head top %.2f, com %.2f, hand rest y %.2f, arm reach %.2f, leg reach %.2f, mass %.1f" % [c.top_height(), c.centre_of_mass().y, c.limb_end(0).y, c.limbs[0].l1 + c.limbs[0].l2, c.limbs[2].l1 + c.limbs[2].l2, c.total_mass])
	d.set_limb(1, true, Vector2(0, 1))
	await frames(int(1.0 * hz))
	print("PEAK standing reach up: hand y %.2f (root y %.2f)" % [c.limb_end(1).y, c.limb_root(1).y])
	d.set_limb(1, true, Vector2(1, 0))
	await frames(int(1.0 * hz))
	print("PEAK standing reach side: hand x %.2f" % c.limb_end(1).x)
	c.remove()
	floor_sb.queue_free()
	await frames(2)
	# ---- B. the pumped swing from one hand: release when rising at about 45 degrees
	for pump_s in [0.6, 1.0, 1.5, 2.0, 3.0, 4.5]:
		for want_deg in [30.0, 45.0, 60.0, 80.0]:
			c = spawn(Vector2(0, 20.0))
			var bar := static_box(c.limb_end(0), Vector2(0.04, 0.04))
			var bar_p := c.limb_end(0)
			c.attach(0, bar)
			d = c.driver
			var t := 0.0
			var released := false
			var rel_v := Vector2.ZERO
			var rel_p := Vector2.ZERO
			var peak_speed := 0.0
			for i in int(12.0 * hz):
				var com := c.centre_of_mass()
				var chest: RigidBody3D = c.bodies["chest"]
				var v := Vector2(chest.linear_velocity.x, chest.linear_velocity.y)
				var r := com - bar_p
				var tangent := r.normalized().orthogonal()
				var along := v.dot(tangent)
				var push := tangent * (1.0 if along >= 0.0 else -1.0)
				if v.length() < 0.3:
					push = Vector2(1, 0)
				d.set_limb(3, true, push)
				peak_speed = maxf(peak_speed, c.linear_speed())
				t += 1.0 / hz
				if t >= pump_s and v.x > 0.5 and v.y > 0.0 and rad_to_deg(atan2(v.y, v.x)) >= want_deg - 6.0 and rad_to_deg(atan2(v.y, v.x)) <= want_deg + 6.0:
					rel_v = v
					rel_p = com
					released = true
					break
				await get_tree().physics_frame
			if not released:
				print("PEAK fling pump %.1f s want %d: never reached the release window (peak speed %.1f)" % [pump_s, want_deg, peak_speed])
				c.remove()
				bar.queue_free()
				await frames(2)
				continue
			d.clear()
			c.release(0)
			bar.queue_free()
			var apex := rel_p.y
			var x_same := NAN  # x travelled when the centre falls back to its release height
			var x_m3 := NAN  # ... 3 m under it
			var x_m6 := NAN
			for i in int(14.0 * hz):
				await get_tree().physics_frame
				var p := c.centre_of_mass()
				apex = maxf(apex, p.y)
				var vy: float = (c.bodies["chest"] as RigidBody3D).linear_velocity.y
				if vy < 0.0:
					if is_nan(x_same) and p.y <= rel_p.y:
						x_same = p.x - rel_p.x
					if is_nan(x_m3) and p.y <= rel_p.y - 3.0:
						x_m3 = p.x - rel_p.x
					if is_nan(x_m6) and p.y <= rel_p.y - 6.0:
						x_m6 = p.x - rel_p.x
						break
			print("PEAK fling pump %.1f s at %2d deg: release speed %.1f (peak %.1f), com %.2f under the bar and %.2f out; rise %.2f, out %.1f at the same height, %.1f at -3 m, %.1f at -6 m" % [pump_s, want_deg, rel_v.length(), peak_speed, bar_p.y - rel_p.y, rel_p.x - bar_p.x, apex - rel_p.y, x_same, x_m3, x_m6])
			c.remove()
			await frames(2)
	print("PEAK done")
	get_tree().quit()
