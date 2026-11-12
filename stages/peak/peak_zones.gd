class_name PeakZones
extends RefCounted
## The Peak's zones: water (float, current, and the swim), wind and gusts, geysers,
## bounce lines, puffballs, lightning, the dark, the finish; and the drawn effects
## (waterfalls, mist, spores, snow...). Data: docs/peak/AUTHORING.md.

const WATER_DRAG := 1.1  # 1/s: how fast the water takes a floating body to its own speed
const HAND_DRAG := 7.5  # N per (m/s)^2 on a hand or foot moving under the surface: the swim
const FLOAT_DEPTH := 0.16  # a piece rides this far under the surface
const BOUNCE_COOL := 0.3

var peak: Peak
var waters: Array = []
var winds: Array = []
var geysers: Array = []
var bounces: Array = []
var puffs: Array = []
var strikes: Array = []
var darks: Array = []
var finishes: Array = []
var flash := 0.0  # lightning's light, 0..1, read by the look
var _tags := {}  # tag -> Array of bodies
var _bounce_wait := 0.0
var _wet := false
var _splash_wait := 0.0
var _paddle_wait := 0.0


func _init(p: Peak) -> void:
	peak = p


func tag(name: String, body: Object) -> void:
	if not _tags.has(name):
		_tags[name] = []
	(_tags[name] as Array).append(body)


func build_area(a: Dictionary, root: Node3D) -> void:
	for z in a.get("zones", []):
		var row: Dictionary = {"def": z, "area": str(a.id)}
		match str(z.type):
			"water":
				row["vis"] = _water_vis(a, z, root)
				waters.append(row)
			"wind":
				row["fx"] = _wind_fx(a, z, root)
				row["was"] = false
				winds.append(row)
			"geyser":
				row["fx"] = _geyser_fx(a, z, root)
				row["was"] = false
				row["warned"] = -1
				geysers.append(row)
			"bounce":
				bounces.append(row)
			"puff":
				var ball: Node3D = LuchaKit.kit_model("puffball")
				if ball == null:
					ball = LuchaKit.ball(float(z.r), peak.tone(a, "gill"))
				else:
					ball.scale = Vector3.ONE * (float(z.r) / 0.6)
				ball.position = Vector3(float(z.at[0]), float(z.at[1]), 0)
				root.add_child(ball)
				row["vis"] = ball
				row["back"] = -1.0
				puffs.append(row)
			"strike":
				row["n"] = -1
				row["warned"] = -1
				strikes.append(row)
			"dark":
				darks.append(row)
			"finish":
				finishes.append(row)
	for e in a.get("fx", []):
		_effect(a, e, root)


# ================================================================ queries

func in_water(c: Climber) -> bool:
	return c != null and c.float_mode


func darkness(p: Vector2) -> float:
	var d := 0.0
	for row in darks:
		var z: Dictionary = row.def
		if Peak.rect_has(z.rect, p, 2.0):
			var level := float(z.level)
			if z.has("flash"):
				var fl: Dictionary = z.flash
				if fposmod(peak.clock, float(fl.period)) < float(fl.on):
					level *= 0.15
			d = maxf(d, level)
	return d


# ================================================================ tick (physics)

func tick(delta: float) -> void:
	_bounce_wait = maxf(0.0, _bounce_wait - delta)
	_splash_wait = maxf(0.0, _splash_wait - delta)
	_paddle_wait = maxf(0.0, _paddle_wait - delta)
	flash = maxf(0.0, flash - delta * 3.5)
	var c := peak.player
	_tick_strikes(c)
	_tick_puffs()
	if c == null or c.state != Climber.State.LIVE:
		return
	_tick_water(c, delta)
	_tick_wind(c)
	_tick_geysers(c)
	_tick_bounce(c)
	if not peak.finished:
		for row in finishes:
			for i in [0, 1]:
				if Peak.rect_has(row.def.rect, peak.local_of(c.limb_end(i))):
					peak.finish()


func _tick_water(c: Climber, _delta: float) -> void:
	var com := peak.local_of(c.centre_of_mass())
	var zone: Dictionary = {}
	for row in waters:
		var z: Dictionary = row.def
		if Peak.rect_has(z.rect, com, 0.6) and com.y < float(z.surface) + 0.7:
			zone = z  # (the last one you're in wins: an eddy laid over the river)
	var wet := not zone.is_empty()
	if wet != _wet:
		_wet = wet
		if wet and _splash_wait <= 0.0:
			_splash_wait = 1.0
			Sound.play_at("splash", Vector3(c.centre_of_mass().x, c.centre_of_mass().y, 0), 0.0)
	c.float_mode = wet
	if not wet:
		return
	var surface := float(zone.surface)
	var flow := Peak.v2(zone.flow)
	var g := 9.8 * Feel.climber_gravity(false)
	for pname in c.bodies:
		var b: RigidBody3D = c.bodies[pname]
		var p := peak.local_of(Climber.pos2(b))
		var depth := surface - p.y
		if depth <= -0.05:
			continue
		var v := Vector2(b.linear_velocity.x, b.linear_velocity.y)
		# Buoyancy: weightless at FLOAT_DEPTH, pushed back toward it either side.
		var lift := b.mass * g * clampf(depth / FLOAT_DEPTH, 0.0, 2.2)
		var drag := (flow - v) * b.mass * WATER_DRAG
		drag.y = -v.y * b.mass * 3.0
		if Climber._is_end(pname) and depth > 0.0:
			# THE SWIM: a hand or foot moving through the water is pushed back by it,
			# hard (quadratic). Circle an arm and the stroke under the surface drives you.
			var rel := v - flow
			var push := -rel * rel.length() * HAND_DRAG
			drag += push.limit_length(420.0)
			if rel.length() > 3.5 and _paddle_wait <= 0.0:
				_paddle_wait = 0.28
				peak.audio.play("water_paddle", p, -6.0)
		b.apply_central_force(Vector3(drag.x, lift + drag.y, 0))


func _gust(z: Dictionary) -> float:
	if not z.has("gust"):
		return 1.0
	var gu: Dictionary = z.gust
	var on := float(gu.get("on", 2.0))
	var off := float(gu.get("off", 3.0))
	var cyc := fposmod(peak.clock + float(gu.get("phase", 0.0)), on + off)
	if cyc >= on:
		return 0.0
	return clampf(minf(cyc, on - cyc) / 0.35, 0.0, 1.0)


func _gust_warn(z: Dictionary) -> bool:
	if not z.has("gust"):
		return false
	var gu: Dictionary = z.gust
	var on := float(gu.get("on", 2.0))
	var off := float(gu.get("off", 3.0))
	var cyc := fposmod(peak.clock + float(gu.get("phase", 0.0)), on + off)
	return cyc > on + off - float(gu.get("warn", 0.8))


func _tick_wind(c: Climber) -> void:
	var com := peak.local_of(c.centre_of_mass())
	for row in winds:
		var z: Dictionary = row.def
		var near := Peak.rect_has(z.rect, com, 30.0)
		var k := _gust(z)
		if near:
			var warn := _gust_warn(z)
			if warn and not bool(row.get("warned", false)):
				peak.audio.play("wind_warn", com, -2.0)
			row["warned"] = warn
			if k > 0.5 and not bool(row.was):
				peak.audio.play("wind_gust", com, 0.0)
			row.was = k > 0.5
		if k <= 0.0 or not Peak.rect_has(z.rect, com, 0.4):
			continue
		var acc := Peak.v2(z.accel) * k
		for b: RigidBody3D in c.bodies.values():
			b.apply_central_force(Vector3(acc.x, acc.y, 0) * b.mass)


func _geyser_on(z: Dictionary) -> bool:
	return fposmod(peak.clock + float(z.get("phase", 0.0)), maxf(0.5, float(z.period))) < float(z.on)


func _tick_geysers(c: Climber) -> void:
	var com := peak.local_of(c.centre_of_mass())
	for row in geysers:
		var z: Dictionary = row.def
		var at := Peak.v2(z.at)
		if at.distance_to(com) > 60.0:
			continue
		var period := maxf(0.5, float(z.period))
		var ph := peak.clock + float(z.get("phase", 0.0))
		var on := _geyser_on(z)
		var n := int(floor(ph / period))
		if int(row.warned) != n and fposmod(ph, period) > period - float(z.get("warn", 1.0)):
			row.warned = n
			peak.audio.play("geyser_warn", at, 2.0)
		if on and not bool(row.was):
			peak.audio.play("geyser_burst", at, 4.0)
		row.was = on
		if not on:
			continue
		var half := float(z.w) * 0.5
		var speed := float(z.speed)
		for b: RigidBody3D in c.bodies.values():
			var p := peak.local_of(Climber.pos2(b))
			if absf(p.x - at.x) > half or p.y < at.y - 0.3 or p.y > at.y + float(z.height):
				continue
			var vy := b.linear_velocity.y
			if vy < speed:
				b.apply_central_force(Vector3(-b.linear_velocity.x * b.mass * 1.5, b.mass * ((speed - vy) * 7.0 + 2.79), 0))


## A springy line: the whole climber is thrown off along its normal, as the ring ropes throw.
func _tick_bounce(c: Climber) -> void:
	if _bounce_wait > 0.0:
		return
	var com_v := Vector2.ZERO
	for b: RigidBody3D in c.bodies.values():
		com_v += Vector2(b.linear_velocity.x, b.linear_velocity.y) * b.mass
	com_v /= maxf(c.total_mass, 0.001)
	var com := peak.local_of(c.centre_of_mass())
	for row in bounces:
		var z: Dictionary = row.def
		var a := Peak.v2(z.a)
		var b2 := Peak.v2(z.b)
		if com.distance_to((a + b2) * 0.5) > a.distance_to(b2) * 0.5 + 3.0:
			continue
		var along := (b2 - a).normalized()
		var n := Vector2(-along.y, along.x)
		var vin := -com_v.dot(n)
		if vin < float(z.get("min_in", 0.6)):
			continue
		var hit := false
		for body: RigidBody3D in c.bodies.values():
			var p := peak.local_of(Climber.pos2(body))
			var s := (p - a).dot(along)
			var d := (p - a).dot(n)
			if s >= -0.15 and s <= a.distance_to(b2) + 0.15 and d > -0.35 and d < 0.42:
				hit = true
				break
		if not hit:
			continue
		var out := float(z.power) + float(z.get("gain", 0.0)) * vin
		var want := com_v - n * com_v.dot(n) + n * out
		c.release_all()
		for l in c.limbs:
			l.regrip = 0.25
		for body: RigidBody3D in c.bodies.values():
			body.linear_velocity += Vector3(want.x - com_v.x, want.y - com_v.y, 0)
		_bounce_wait = BOUNCE_COOL
		var look := str(z.get("look", "cap"))
		peak.audio.play("bounce_rope" if look == "rope" else ("sizzle" if look == "lava" else "mushroom_boing"), com, 3.0, clampf(1.25 - out * 0.035, 0.7, 1.3))
		if bool(z.get("ko", false)):
			c.knock_out()
			Sound.play_at("hurt", Vector3(c.centre_of_mass().x, c.centre_of_mass().y, 0), 0.0)
		return


func _tick_puffs() -> void:
	var c := peak.player
	for row in puffs:
		var z: Dictionary = row.def
		if float(row.back) >= 0.0:
			if peak.clock >= float(row.back):
				row.back = -1.0
				(row.vis as Node3D).visible = true
			continue
		if c == null or c.state != Climber.State.LIVE:
			continue
		var at := Peak.v2(z.at)
		var com := peak.local_of(c.centre_of_mass())
		if com.distance_to(at) > float(z.r) + 2.5:
			continue
		for b: RigidBody3D in c.bodies.values():
			if peak.local_of(Climber.pos2(b)).distance_to(at) < float(z.r) + 0.12:
				var dir := (com - at).normalized() if com.distance_to(at) > 0.05 else Vector2.UP
				c.release_all()
				for l in c.limbs:
					l.regrip = 0.3
				for body: RigidBody3D in c.bodies.values():
					body.linear_velocity = Vector3(dir.x, dir.y, 0) * float(z.power)
				row.back = peak.clock + float(z.get("respawn", 4.0))
				(row.vis as Node3D).visible = false
				peak.audio.play("puffball_pop", at, 3.0)
				break


func _tick_strikes(c: Climber) -> void:
	for row in strikes:
		var z: Dictionary = row.def
		var period := maxf(1.0, float(z.period))
		var warn := float(z.get("warn", 1.5))
		var ph := peak.clock + float(z.get("phase", 0.0))
		var n := int(floor(ph / period))
		var bodies: Array = _tags.get(str(z.tag), [])
		if bodies.is_empty():
			continue
		var at := Vector2((bodies[0] as Node3D).position.x, (bodies[0] as Node3D).position.y)
		if z.has("at"):
			at = Peak.v2(z.at)
		elif bodies[0] is StaticBody3D:
			at = peak.things._body_centre(bodies[0])
		var near := c != null and peak.player_at().distance_to(at) < 70.0
		if near and int(row.warned) != n and fposmod(ph, period) > period - warn:
			row.warned = n
			peak.audio.play("lightning_hum", at, 2.0)
		if n == int(row.n):
			continue
		row.n = n
		if not near:
			continue
		flash = 1.0
		peak.audio.play("lightning_zap", at, 6.0)
		peak.audio.play("thunder", Vector2.INF, 0.0)
		if c == null or c.state != Climber.State.LIVE:
			continue
		for l in c.limbs:
			if l.grab_other != null and bodies.has(l.grab_other):
				c.knock_out()
				for b: RigidBody3D in c.bodies.values():
					b.linear_velocity += Vector3(randf_range(-2.0, 2.0), 2.5, 0)
				break


# ================================================================ drawn

func frame(_delta: float, _cam: Camera3D) -> void:
	for row in winds:
		var fx: CPUParticles3D = row.get("fx")
		if fx != null:
			fx.emitting = _gust(row.def) > 0.2 and bool(peak._area_active.get(row.area, true))
	for row in geysers:
		var fx: CPUParticles3D = row.get("fx")
		if fx != null:
			fx.emitting = _geyser_on(row.def) and bool(peak._area_active.get(row.area, true))


static func _flat(c: Color, alpha: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(c.r, c.g, c.b, alpha)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


func _water_vis(a: Dictionary, z: Dictionary, root: Node3D) -> Node3D:
	var r: Array = z.rect
	var w := float(r[2]) - float(r[0])
	var surface := float(z.surface)
	var h := surface - float(r[1])
	if w <= 0.0 or h <= 0.0:
		return null
	var n := Node3D.new()
	var body := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(w, h, Peak.HALF * 2.4)
	body.mesh = bm
	var deep: Color = peak.tone(a, "slick").lerp(Color("#1C5C8C"), 0.55)
	body.material_override = _flat(deep, 0.62)
	body.position = Vector3((float(r[0]) + float(r[2])) * 0.5, surface - h * 0.5, 0)
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.add_child(body)
	var top := MeshInstance3D.new()
	var tm := BoxMesh.new()
	tm.size = Vector3(w, 0.07, Peak.HALF * 2.42)
	top.mesh = tm
	top.material_override = _flat(Color("#CFEFFF"), 0.75)
	top.position = Vector3((float(r[0]) + float(r[2])) * 0.5, surface, 0)
	top.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.add_child(top)
	var flow := Peak.v2(z.flow)
	if flow.length() > 0.2:
		# Foam flecks riding the current, so its speed can be read.
		var p := _particles(Color("#E8F6FF"), 0.8, int(clampf(w * 0.8, 6, 60)), 5.0)
		p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		p.emission_box_extents = Vector3(w * 0.5, 0.05, Peak.HALF)
		p.direction = Vector3(flow.x, flow.y, 0).normalized()
		p.spread = 4.0
		p.initial_velocity_min = flow.length() * 0.9
		p.initial_velocity_max = flow.length() * 1.1
		p.gravity = Vector3.ZERO
		p.scale_amount_min = 0.5
		p.scale_amount_max = 1.4
		p.position = Vector3((float(r[0]) + float(r[2])) * 0.5, surface + 0.05, 0.2)
		n.add_child(p)
	root.add_child(n)
	return n


func _particles(c: Color, size: float, amount: int, life: float) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(0.12, 0.12) * size
	p.mesh = q
	var m := _flat(c, 0.8)
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	p.material_override = m
	p.amount = maxi(1, amount)
	p.lifetime = life
	p.preprocess = life
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return p


func _wind_fx(_a: Dictionary, z: Dictionary, root: Node3D) -> CPUParticles3D:
	var r: Array = z.rect
	var w := float(r[2]) - float(r[0])
	var h := float(r[3]) - float(r[1])
	var acc := Peak.v2(z.accel)
	if acc.length() < 0.1:
		return null
	var p := _particles(Color("#FFFFFF"), 0.7, int(clampf(w * h / 9.0, 8, 90)), 1.6)
	(p.mesh as QuadMesh).size = Vector2(0.9, 0.04)
	(p.material_override as StandardMaterial3D).billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(w * 0.5, h * 0.5, Peak.HALF)
	p.direction = Vector3(acc.x, acc.y, 0).normalized()
	p.spread = 3.0
	p.initial_velocity_min = 5.0 + acc.length()
	p.initial_velocity_max = 8.0 + acc.length() * 1.5
	p.gravity = Vector3.ZERO
	p.preprocess = 0.0
	p.position = Vector3((float(r[0]) + float(r[2])) * 0.5, (float(r[1]) + float(r[3])) * 0.5, 0.6)
	p.rotation.z = 0.0 if absf(acc.x) >= absf(acc.y) else PI * 0.5
	root.add_child(p)
	return p


func _geyser_fx(_a: Dictionary, z: Dictionary, root: Node3D) -> CPUParticles3D:
	var p := _particles(Color("#F4F8FF"), 3.0, 70, maxf(0.4, float(z.height) / maxf(1.0, float(z.speed))))
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(float(z.w) * 0.4, 0.1, 0.5)
	p.direction = Vector3.UP
	p.spread = 6.0
	p.initial_velocity_min = float(z.speed) * 0.8
	p.initial_velocity_max = float(z.speed) * 1.1
	p.gravity = Vector3(0, -1.5, 0)
	p.preprocess = 0.0
	p.position = Vector3(float(z.at[0]), float(z.at[1]), 0.2)
	root.add_child(p)
	return p


## The drawn effects an area asks for by name.
func _effect(a: Dictionary, e: Dictionary, root: Node3D) -> void:
	var r: Array = e.rect
	var w := float(r[2]) - float(r[0])
	var h := float(r[3]) - float(r[1])
	var mid := Vector3((float(r[0]) + float(r[2])) * 0.5, (float(r[1]) + float(r[3])) * 0.5, float(e.get("z", -0.4)))
	var kind := str(e.type)
	var density := float(e.get("density", 1.0))
	if kind == "waterfall":
		var sheet := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(w, h, 0.5)
		sheet.mesh = bm
		sheet.material_override = _flat(Color("#BFE4F6"), 0.55)
		sheet.position = mid
		sheet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(sheet)
		var p := _particles(Color("#FFFFFF"), 2.2, int(clampf(h * 1.2 * density, 10, 140)), clampf(h / 14.0, 0.6, 6.0))
		(p.mesh as QuadMesh).size = Vector2(0.14, 1.6)
		p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		p.emission_box_extents = Vector3(w * 0.45, 0.2, 0.3)
		p.direction = Vector3.DOWN
		p.spread = 1.0
		p.initial_velocity_min = 12.0
		p.initial_velocity_max = 16.0
		p.gravity = Vector3(0, -4, 0)
		p.position = Vector3(mid.x, float(r[3]), mid.z + 0.3)
		root.add_child(p)
		peak.audio.emitter("waterfall_loop", Vector2(mid.x, float(r[1]) + minf(h * 0.3, 12.0)), 1.0, 40.0)
		return
	var cfg := {
		"mist": [Color("#DCEFF8"), 5.0, 0.25, Vector3(0.2, 0.5, 0), 4.0, 0.35],
		"drips": [Color("#BFD8E6"), 0.6, 0.05, Vector3(0, -6.0, 0), 1.6, 0.9],
		"spores": [peak.tone(a, "accent"), 0.7, 0.10, Vector3(0.15, 0.45, 0), 7.0, 0.8],
		"snow": [Color("#FFFFFF"), 0.8, 0.14, Vector3(-0.8, -1.6, 0), 6.0, 0.9],
		"steam": [Color("#F2F2F2"), 4.0, 0.12, Vector3(0, 2.2, 0), 2.5, 0.3],
		"embers": [Color("#FF8A2A"), 0.6, 0.10, Vector3(0.1, 1.4, 0), 3.5, 0.9],
		"dust": [Color("#F2E6C8"), 0.6, 0.07, Vector3(0.1, -0.1, 0), 8.0, 0.5],
		"rain": [Color("#C8D4E0"), 0.5, 0.40, Vector3(-3.0, -16.0, 0), 1.2, 0.7],
		"clouds": [Color("#FFFFFF"), 14.0, 0.012, Vector3(0.5, 0, 0), 30.0, 0.5],
	}
	if not cfg.has(kind):
		return
	var c: Array = cfg[kind]
	var p := _particles(c[0], float(c[1]), int(clampf(w * h * float(c[2]) * density, 4, 220)), float(c[4]))
	(p.material_override as StandardMaterial3D).albedo_color.a = float(c[5])
	if kind == "rain" or kind == "drips":
		(p.mesh as QuadMesh).size = Vector2(0.03, 0.5 if kind == "rain" else 0.16)
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(w * 0.5, h * 0.5, Peak.HALF * 1.5)
	var vel: Vector3 = c[3]
	p.direction = vel.normalized() if vel.length() > 0.01 else Vector3.UP
	p.spread = 25.0 if kind in ["spores", "dust", "mist", "embers"] else 4.0
	p.initial_velocity_min = vel.length() * 0.6
	p.initial_velocity_max = vel.length() * 1.3
	p.gravity = Vector3.ZERO
	p.position = mid
	root.add_child(p)
