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
var _wet_zone: Dictionary = {}  # the water the climber is in (or was last in)
var _paddle_wait := 0.0
var _churns: Array = []  # [the water's row, x0, x1, the next second it sprays]: a waterfall's foot


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
				row["vis"] = _water_vis(a, z, root, row)
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
				# IN A DARK PLACE THE PUFFBALLS ARE THE LIGHT (they are "the eyes"): each
				# casts a pale pool, so the route is drawn in light, and one that has burst
				# is dark until it grows back.
				for dz in a.get("zones", []):
					if str(dz.type) == "dark" and Peak.rect_has(dz.rect, Peak.v2(z.at), 1.0):
						var glow := OmniLight3D.new()
						glow.light_color = Color("#FFF0C8")
						glow.omni_range = 5.5
						glow.light_energy = 1.3
						glow.shadow_enabled = false
						glow.position = Vector3(float(z.at[0]), float(z.at[1]), 1.6)
						root.add_child(glow)
						row["glow"] = glow
						break
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


## The water zone a point is in (the last one laid wins, as for a climber), or null.
func water_at(p: Vector2):
	var zone = null
	for row in waters:
		var z: Dictionary = row.def
		if Peak.rect_has(z.rect, p) and p.y < float(z.surface):
			zone = z
	return zone


## The drawn water (its row) whose surface is nearest a point over or in it, or {}.
func _water_row(p: Vector2) -> Dictionary:
	var best := {}
	var best_d := 2.5
	for row in waters:
		if not row.has("sea"):
			continue
		var z: Dictionary = row.def
		if p.x < float(z.rect[0]) - 0.3 or p.x > float(z.rect[2]) + 0.3:
			continue
		var d := absf(p.y - float(z.surface))
		if d < best_d:
			best_d = d
			best = row
	return best


## SPLASH (Del Mar's own: a fan of pale blobs thrown up and pulled back, two rings on the
## surface, and its sound). Something went into, or came out of, the water at `p`. size 1
## is a climber falling in. Small ones crowding one pool are thinned (a plank breaks into
## two dozen chunks).
func splash_at(p: Vector2, size: float, _speed := 3.0) -> void:
	var row := _water_row(p)
	if row.is_empty():
		Sound.play_at("splash" if size >= 0.7 else "splash_small", Vector3(p.x + Peak.ORIGIN.x, p.y + Peak.ORIGIN.y, 0), 0.0)
		return
	var gap := 0.05 if size >= 0.7 else 0.22
	if peak.clock - float(row.get("splashed", -9.0)) < gap:
		return
	row["splashed"] = peak.clock
	var sea: DelMarSea = row.sea
	sea.splash(p.x + Peak.ORIGIN.x, size, 0.0)
	_pale(sea)


## IN THE DARK THE SPRAY STAYS PALE. Del Mar's blobs are lit by the scene: in its sun they
## are white, in a cave's lamp light their shaded side went smoke grey. The Peak's wear a
## copy of the same blob whose shade is only a little under its light.
static var _pale_blob: SphereMesh = null


func _pale(sea: DelMarSea) -> void:
	if _pale_blob == null:
		_pale_blob = DelMarSea._blob_mesh().duplicate() as SphereMesh
		var m := (_pale_blob.material as ShaderMaterial).duplicate() as ShaderMaterial
		m.set_shader_parameter("shadow_color", DelMarSea.SPLASH_TINT.darkened(0.14))
		_pale_blob.material = m
	for ch in sea.get_children():
		if ch is GPUParticles3D and (ch as GPUParticles3D).draw_pass_1 != _pale_blob:
			(ch as GPUParticles3D).draw_pass_1 = _pale_blob


## THE DARK FADES, AND HAS A FLOOR (Parker 11-12, the garden's Los Ojos: "its way too dark
## in here, it can be a little dim but not this and the lighting needs to fade between the
## places"). A dark box used to apply its whole strength in one frame the moment the
## climber came within 2 m of it, and its strength could be anything up to black. Now it
## deepens over DARK_FADE_M as you come up to the box, any change is eased in time, and no
## dark place on the mountain is stronger than DARK_MAX: the climber and the holds have to
## be readable everywhere.
const DARK_FADE_M := 7.0
const DARK_MAX := 0.55
const DARK_EASE := 3.0  # 1/s
var _dark := 0.0  # the darkness at the climber, eased


## How dark it is at the climber (eased; `frame` keeps it).
func darkness(_p: Vector2) -> float:
	return _dark


## How dark a point is by the boxes alone, before easing.
func dark_at(p: Vector2) -> float:
	var d := 0.0
	for row in darks:
		var z: Dictionary = row.def
		var r: Array = z.rect
		var out := Vector2(maxf(maxf(float(r[0]) - p.x, p.x - float(r[2])), 0.0), maxf(maxf(float(r[1]) - p.y, p.y - float(r[3])), 0.0)).length()
		var near := clampf(1.0 - out / DARK_FADE_M, 0.0, 1.0)
		if near <= 0.0:
			continue
		var level := minf(float(z.level), DARK_MAX) * near * near * (3.0 - 2.0 * near)
		if z.has("flash"):
			var fl: Dictionary = z.flash
			if fposmod(peak.clock, float(fl.period)) < float(fl.on):
				level *= 0.15
		d = maxf(d, level)
	return d


# ================================================================ tick (physics)

func tick(delta: float) -> void:
	_bounce_wait = maxf(0.0, _bounce_wait - delta)
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
		if wet:
			# In: the faster you hit it, the bigger.
			_wet_zone = zone
			splash_at(Vector2(com.x, float(zone.surface)), clampf(0.75 + c.linear_speed() * 0.07, 0.75, 1.5))
		elif not _wet_zone.is_empty():
			# Out: a smaller one, where you left it.
			splash_at(Vector2(clampf(com.x, float(_wet_zone.rect[0]), float(_wet_zone.rect[2])), float(_wet_zone.surface)), 0.5)
	if wet:
		_wet_zone = zone
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
		# The blast tears you off whatever you hold inside its column (feet stuck to the
		# grate would hold the whole body down: you ride a geyser, you don't resist it).
		for i in c.limbs.size():
			if c.limbs[i].grab_other == null:
				continue
			var e := peak.local_of(c.limb_end(i))
			if absf(e.x - at.x) <= half + 0.25 and e.y >= at.y - 0.6 and e.y <= at.y + float(z.height):
				c.release(i)
				c.limbs[i].regrip = 0.6
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
				if row.has("glow"):
					(row.glow as OmniLight3D).visible = true
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
				if row.has("glow"):
					(row.glow as OmniLight3D).visible = false
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
	var dark_want := dark_at(peak.player_at()) if peak.player != null else 0.0
	_dark = lerpf(_dark, dark_want, 1.0 - exp(-_delta * DARK_EASE))
	if absf(_dark - dark_want) < 0.002:
		_dark = dark_want
	for ch in _churns:
		if peak.clock < float(ch[3]) or not bool(peak._area_active.get(ch[4], true)):
			continue
		ch[3] = peak.clock + randf_range(0.12, 0.22)
		var z: Dictionary = (ch[0] as Dictionary).def
		var at := Vector2(randf_range(float(ch[1]), float(ch[2])), float(z.surface))
		if peak.player == null or peak.player_at().distance_to(at) > 40.0:
			continue
		var sea: DelMarSea = (ch[0] as Dictionary).sea
		var world := Vector3(at.x + Peak.ORIGIN.x, at.y + Peak.ORIGIN.y, randf_range(-0.9, 0.9))
		sea.spray(world, randf_range(0.9, 1.5))
		_pale(sea)
		if randf() < 0.35:
			sea.ripple(world, randf_range(0.6, 1.1))
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


## THE WATER'S COLOUR, IN ONE PLACE. Parker's call is open (11-12): Del Mar's own bright
## day blue in the caves, or that blue tinted dark to fit each cave (Las Aguas Negras is
## the black waters). Built TINTED. To see Del Mar's blue everywhere, make this false.
const WATER_TINTED := true
const WATER_FRONT := preload("res://stages/peak/peak_water_front.gdshader")
const WATER_DEPTH := Peak.HALF * 2.4  # how far through the play plane a pool reaches


## [shallow, deep] for an area's water: Del Mar's two blues, pulled toward the area's own
## dark when tinted. (The alphas are how much the front hides what is in the water.)
func water_colors(a: Dictionary) -> Array:
	var shallow := DelMarSea.SHALLOW
	var deep := DelMarSea.DEEP
	if WATER_TINTED:
		var dark: Color = peak.tone(a, "back2")
		shallow = shallow.lerp(dark, 0.5)
		deep = deep.lerp(dark, 0.72)
	return [Color(shallow.r, shallow.g, shallow.b, 0.42), Color(deep.r, deep.g, deep.b, 0.74)]


## Is this water laid wholly over another with the same surface (an eddy in a river)?
func _water_over(a: Dictionary, z: Dictionary) -> bool:
	for o in a.get("zones", []):
		if str(o.type) != "water" or o == z or not is_equal_approx(float(o.surface), float(z.surface)):
			continue
		if float(o.rect[0]) <= float(z.rect[0]) and float(o.rect[2]) >= float(z.rect[2]) and float(o.rect[2]) - float(o.rect[0]) > float(z.rect[2]) - float(z.rect[0]):
			return true
	return false


## A POOL, A RIVER, THE SUMP (Parker 11-12: "the water should use the water shader and
## splash effects we use in del mar"). Its top is Del Mar's own surface, dressed by Del
## Mar's own DelMarSea (the foam circles, the ripple rings a splash stamps in, the ink
## replayed), which also throws this pool's splashes. Its front is a clean tint with the
## waterline (peak_water_front.gdshader): these pools are looked INTO, from the side.
## A river keeps its flecks, so the current can be read.
func _water_vis(a: Dictionary, z: Dictionary, root: Node3D, row: Dictionary = {}) -> Node3D:
	var r: Array = z.rect
	var w := float(r[2]) - float(r[0])
	var surface := float(z.surface)
	var h := surface - float(r[1])
	if w <= 0.0 or h <= 0.0:
		return null
	var n := Node3D.new()
	var mid_x := (float(r[0]) + float(r[2])) * 0.5
	var cols: Array = water_colors(a)
	var flow := Peak.v2(z.flow)
	if _water_over(a, z):
		# An eddy: the river's own water, stiller. A darker patch of the front, no more.
		var still := MeshInstance3D.new()
		var sq := QuadMesh.new()
		sq.size = Vector2(w, h)
		still.mesh = sq
		still.material_override = _flat((cols[1] as Color).darkened(0.35), 0.3)
		still.position = Vector3(mid_x, surface - h * 0.5 - 0.03, WATER_DEPTH * 0.5 + 0.02)
		still.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		n.add_child(still)
		root.add_child(n)
		return n
	var top := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(w, WATER_DEPTH)
	top.mesh = pm
	top.position = Vector3(mid_x, surface, 0)
	n.add_child(top)
	var sea := DelMarSea.new()
	n.add_child(sea)
	sea.dress(top, surface + Peak.ORIGIN.y)
	var tm := top.material_override as ShaderMaterial
	if tm != null:
		tm.set_shader_parameter("shallow_color", cols[0])
		tm.set_shader_parameter("deep_color", cols[1])
		tm.set_shader_parameter("foam_tile_m", 7.0)  # (a strip 3 m deep, seen edge on: smaller marks than a sea's)
		tm.set_shader_parameter("foam_edge_m", 0.3)
		tm.set_shader_parameter("murk_min", 0.8)
		tm.set_shader_parameter("murk_max", 0.97)
	var front := MeshInstance3D.new()
	var fq := QuadMesh.new()
	fq.size = Vector2(w, h)
	front.mesh = fq
	var fm := ShaderMaterial.new()
	fm.shader = WATER_FRONT
	fm.set_shader_parameter("shallow_color", cols[0])
	fm.set_shader_parameter("deep_color", cols[1])
	fm.set_shader_parameter("depth_m", h)
	fm.set_shader_parameter("flow", flow.x)
	fm.render_priority = 1  # (over the surface's underside, seen from below the waterline)
	front.material_override = fm
	front.position = Vector3(mid_x, surface - h * 0.5, WATER_DEPTH * 0.5)
	front.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.add_child(front)
	row["sea"] = sea
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


static var _puff_tex: GradientTexture2D


## A soft round blob, bright in the middle and gone at the rim.
static func _puff() -> GradientTexture2D:
	if _puff_tex == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.6), Color(1, 1, 1, 0)])
		_puff_tex = GradientTexture2D.new()
		_puff_tex.gradient = g
		_puff_tex.fill = GradientTexture2D.FILL_RADIAL
		_puff_tex.fill_from = Vector2(0.5, 0.5)
		_puff_tex.fill_to = Vector2(1.0, 0.5)
		_puff_tex.width = 64
		_puff_tex.height = 64
	return _puff_tex


func _particles(c: Color, size: float, amount: int, life: float) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(0.12, 0.12) * size
	p.mesh = q
	var m := _flat(c, 0.8)
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	if size >= 2.0:
		m.albedo_texture = _puff()  # (mist, steam, cloud: a soft round puff, not a grey square)
	p.material_override = m
	p.amount = maxi(1, amount)
	p.lifetime = life
	p.preprocess = life
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return p


## A BURST: a puff of something at a point, once. One table for every kind the mountain
## uses, so they speak the same language (the playtest of 11-12 asked again and again for
## "obvious effects": Parker, "we can use particle effects if we need it").
##   colour, size, how many, life s, speed lo, speed hi, gravity, spread deg, soft blob?
const BURSTS := {
	"dust": [Color("#E9DCC0"), 2.6, 14, 0.9, 0.5, 1.6, Vector3(0, -0.6, 0), 60.0, true],
	"steam": [Color("#F4F8FF"), 3.6, 16, 0.9, 0.8, 2.4, Vector3(0, 1.6, 0), 40.0, true],
	"smoke": [Color("#5A5048"), 3.0, 10, 1.1, 0.4, 1.2, Vector3(0, 1.2, 0), 35.0, true],
	"sparks": [Color("#FFB03A"), 0.55, 22, 0.55, 2.0, 5.5, Vector3(0, -7.0, 0), 75.0, false],
	"embers": [Color("#FF7A2A"), 0.5, 6, 0.8, 0.5, 1.6, Vector3(0, 1.0, 0), 50.0, false],
	"glitter": [Color("#F2E8FF"), 0.5, 26, 0.7, 1.2, 4.0, Vector3(0, -5.0, 0), 80.0, false],
	"spores": [Color("#F2A040"), 0.8, 22, 1.1, 1.0, 3.2, Vector3(0, 0.8, 0), 70.0, false],
	"drops": [Color("#BFE4F6"), 0.5, 8, 0.6, 0.6, 2.0, Vector3(0, -6.0, 0), 50.0, false],
	"frost": [Color("#DFF4FF"), 0.5, 18, 0.7, 0.8, 2.6, Vector3(0, -2.0, 0), 80.0, false],
}


func burst(at: Vector2, kind: String, scale := 1.0, dir := Vector2.UP, z := 0.5) -> void:
	if not BURSTS.has(kind) or DisplayServer.get_name() == "headless":
		return
	var b: Array = BURSTS[kind]
	var p := _particles(b[0], float(b[1]) * (0.75 + 0.25 * scale), int(round(float(b[2]) * scale)), float(b[3]))
	if not bool(b[8]):
		(p.material_override as StandardMaterial3D).albedo_texture = null
	p.one_shot = true
	p.explosiveness = 0.92
	p.preprocess = 0.0
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.12 * scale
	p.direction = Vector3(dir.x, dir.y, 0).normalized()
	p.spread = float(b[7])
	p.initial_velocity_min = float(b[4])
	p.initial_velocity_max = float(b[5]) * (0.7 + 0.3 * scale)
	p.gravity = b[6]
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.3
	var fade := Curve.new()
	fade.add_point(Vector2(0.0, 0.6))
	fade.add_point(Vector2(0.25, 1.0))
	fade.add_point(Vector2(1.0, 0.0))
	p.scale_amount_curve = fade
	p.position = Vector3(at.x, at.y, z)
	peak.add_child(p)
	p.emitting = true
	peak.get_tree().create_timer(float(b[3]) + 0.4).timeout.connect(p.queue_free)


func _wind_fx(_a: Dictionary, z: Dictionary, root: Node3D) -> CPUParticles3D:
	var r: Array = z.rect
	var w := float(r[2]) - float(r[0])
	var h := float(r[3]) - float(r[1])
	var acc := Peak.v2(z.accel)
	if acc.length() < 0.1:
		return null
	var p := _particles(Color("#FFFFFF"), 0.7, int(clampf(w * h / 9.0, 8, 90)), 1.6)
	# The streak lies along the wind. (Turning the emitter to stand it up also turned the
	# box it is born in and the way it flies: the mine's 6 x 112 m down-draught drew as a
	# band 112 m wide across the cavern, its streaks sliding sideways. Parker 11-12:
	# "there is wind in the mine at this part that seams to do nothing".)
	var upright := absf(acc.y) > absf(acc.x)
	(p.mesh as QuadMesh).size = Vector2(0.04, 0.9) if upright else Vector2(0.9, 0.04)
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
		# Where it lands in a pool it churns it: Del Mar's spray and rings, for as long as
		# the climber is near enough to see.
		var foot := _water_row(Vector2(mid.x, float(r[1])))
		if not foot.is_empty():
			_churns.append([foot, float(r[0]), float(r[2]), 0.0, str(a.id)])
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
