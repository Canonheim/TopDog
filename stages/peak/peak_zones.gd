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
var locks: Array = []  # water rows whose surface rises and falls on a clock (note 146: La Esclusa)
var pipes: Array = []  # whirlpools that take a body down a pipe and out at its mouth (note 146)
var winds: Array = []
var geysers: Array = []
var bounces: Array = []
var puffs: Array = []
var strikes: Array = []
var darks: Array = []
var finishes: Array = []
var rides: Array = []  # (a drop through one of these is a ride, not a fall: peak.gd _tick_fall)
var drip_lines: Array = []  # {def, area, nodes}: fat drips running down a line (La Cortina)
var flash := 0.0  # lightning's light, 0..1, read by the look
var _tags := {}  # tag -> Array of bodies
var _bounce_wait := 0.0
var _wet := false
var _wet_zone: Dictionary = {}  # the water the climber is in (or was last in)
var _paddle_wait := 0.0
var _churns: Array = []  # [the water's row, x0, x1, the next second it sprays]: a waterfall's foot
var water_bodies: Array = []  # the DRAWN water: one per connected stretch (see _build_bodies)
var _sheds: Array = []  # wheels that lift water and drop it
var _drip_until := 0.0  # the climber, just out of the water, drips until this second
var _drip_next := 0.0


func _init(p: Peak) -> void:
	peak = p


func tag(name: String, body: Object) -> void:
	if not _tags.has(name):
		_tags[name] = []
	(_tags[name] as Array).append(body)


func build_area(a: Dictionary, root: Node3D) -> void:
	var body_of := _build_bodies(a, root)
	var zi := -1
	for z in a.get("zones", []):
		zi += 1
		var row: Dictionary = {"def": z, "area": str(a.id)}
		match str(z.type):
			"water":
				if z.has("lock"):
					row["lock_vis"] = _lock_vis(a, z, root)
					locks.append(row)
				if body_of.has(zi):
					row["body"] = body_of[zi]
					row["sea"] = (body_of[zi] as Dictionary).sea
				waters.append(row)
			"pipe":
				row["next"] = 0.0
				pipes.append(row)
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
				if z.has("model"):
					_bounce_vis(a, z, root, row)
				elif z.has("squash_tag"):
					_bounce_squash(z, root, row)
				elif str(z.get("look", "")) == "rope":
					_rope_band(z, root, row)
				bounces.append(row)
			"drips":
				_drips_vis(z, root, row)
				drip_lines.append(row)
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
			"ride":
				rides.append(row)
	for e in a.get("fx", []):
		_effect(a, e, root)
	_finish_bodies(str(a.id))
	_find_sheds(a, root)


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
## Is p inside a ride (a drop that is the course's reward, not a fall)?
func in_ride(p: Vector2) -> bool:
	for row in rides:
		if Peak.rect_has(row.def.rect, p, 0.0):
			return true
	return false


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
	_tick_locks()
	if c == null or c.state != Climber.State.LIVE:
		return
	_tick_pipes(c)
	_tick_water(c, delta)
	_tick_wind(c)
	_tick_geysers(c)
	_tick_bounce(c)
	if not peak.finished:
		for row in finishes:
			for i in [0, 1]:
				if Peak.rect_has(row.def.rect, peak.local_of(c.limb_end(i))):
					peak.finish()


## A LOCK (note 146, La Esclusa; Parker: "keep it 14 s"): its water rises from `low` to `high` in `rise` s,
## holds `hold` s, drains in `drain` s, and at once rises again (`low_hold` s at the bottom, 0 here). The
## zone's rect reaches its highest water; its surface is moved every tick, so swimming, floating and the
## drain taking you down are the water's own.
func lock_level(lk: Dictionary, t: float) -> float:
	var lo := float(lk.low)
	var hi := float(lk.high)
	var r := float(lk.get("rise", 6.0))
	var h := float(lk.get("hold", 3.0))
	var d := float(lk.get("drain", 5.0))
	var b := float(lk.get("low_hold", 0.0))
	var cyc := fposmod(t + float(lk.get("phase", 0.0)), r + h + d + b)
	if cyc < r:
		return lerpf(lo, hi, cyc / r)
	if cyc < r + h:
		return hi
	if cyc < r + h + d:
		return lerpf(hi, lo, (cyc - r - h) / d)
	return lo


func _tick_locks() -> void:
	for row in locks:
		var z: Dictionary = row.def
		_lock_warn(row, z.lock)
		var level := lock_level(z.lock, peak.clock)
		z.surface = level
		z["vy"] = (lock_level(z.lock, peak.clock + 0.05) - level) / 0.05  # its speed, up or down
		_lock_falls(row, z, level)
		var vis: Node3D = row.get("lock_vis")
		if vis != null and is_instance_valid(vis) and vis.has_meta("front"):
			var floor_y := float(z.rect[1])
			(vis.get_meta("front") as Node3D).scale.y = maxf(0.02, level + 0.16 - floor_y)  # (its top 0.16 over, as a body's: the waterline's wave)
			(vis.get_meta("top") as Node3D).position.y = level
			(vis.get_meta("mat") as ShaderMaterial).set_shader_parameter("surface_y", level + Peak.ORIGIN.y)
			(vis.get_meta("sea") as DelMarSea).water_y = level + Peak.ORIGIN.y
			if vis.has_meta("float"):
				(vis.get_meta("float") as Node3D).position.y = level
			if vis.has_meta("wheel"):
				var wd: Dictionary = z.lock.wheel
				var m: Dictionary = peak.things.movers.get(str(wd.mover), {})
				var f := clampf(float(m.get("zoff", 0.0)) / float(wd.get("travel", -3.0)), 0.0, 1.0)  # (the flap's travel, already eased)
				(vis.get_meta("wheel") as Node3D).rotation.z = -f * float(wd.get("turns", 2.0)) * TAU  # (clockwise as it opens)


## A FALL INTO A LOCK ENDS AT ITS SURFACE (the reviewer's q26, 11-18: the fill's white sheet was drawn on down through
## the deep water under it). Every fall drawn inside the lock's chamber is clipped at the level each tick, broken white
## where it meets it, with rings on the surface where it lands; once the level is over its mouth it is drowned: it
## shows only a faint boil, a slow ring now and then on the surface over the mouth.
var fall_sheets: Array = []  # every fall drawn: {area, x, top, foot, mat, node}


func _lock_falls(row: Dictionary, z: Dictionary, level: float) -> void:
	if not row.has("falls"):
		var r: Array = z.rect
		var mine: Array = []
		for f: Dictionary in fall_sheets:
			if str(f.area) == str(row.area) and float(f.x) >= float(r[0]) and float(f.x) <= float(r[2]) \
					and float(f.foot) >= float(r[1]) - 0.5 and float(f.foot) <= float(r[3]):
				mine.append(f)
		row["falls"] = mine
		row["ring_t"] = 0.0
	var vis: Node3D = row.get("lock_vis")
	var sea: DelMarSea = vis.get_meta("sea") if vis != null and is_instance_valid(vis) and vis.has_meta("sea") else null
	for f: Dictionary in row.falls:
		var drowned := level >= float(f.top) - 0.05
		(f.mat as ShaderMaterial).set_shader_parameter("clip_y", level + Peak.ORIGIN.y)
		(f.node as Node3D).visible = not drowned
		if sea != null and peak.clock >= float(row.ring_t):
			# where it lands, a ring as each slug of water hits; drowned, a slow faint boil over the mouth
			row.ring_t = peak.clock + (1.1 if drowned else 0.35)
			sea.ripple(Vector3(float(f.x) + Peak.ORIGIN.x, level + Peak.ORIGIN.y, 0.0), 0.45 if drowned else 0.8)


## THE KEEPER HAULS HIS LEVER (note 146, page 1.13: "one second before each fill he hauls it over: that is the
## warning, as every danger on the mountain warns before it acts"): `warn` s before each rise the lever by his
## booth swings over with an iron clank; it eases back as the water comes.
func _lock_warn(row: Dictionary, lk: Dictionary) -> void:
	var warn := float(lk.get("warn", 0.0))
	if warn <= 0.0:
		return
	var period := float(lk.get("rise", 6.0)) + float(lk.get("hold", 3.0)) + float(lk.get("drain", 5.0)) + float(lk.get("low_hold", 0.0))
	var cyc := fposmod(peak.clock + float(lk.get("phase", 0.0)), period)
	var prev := float(row.get("prev_cyc", cyc))
	row["prev_cyc"] = cyc
	var at := period - warn
	if not (prev < at and cyc >= at):
		return
	var vis: Node3D = row.get("lock_vis")
	var lever: Node3D = vis.get_meta("lever") if vis != null and is_instance_valid(vis) and vis.has_meta("lever") else null
	var p := Peak.v2(lk.get("lever", [0, 0]))
	peak.audio.play("hammer_clang", p, -2.0, 0.7)
	peak.audio.play("plank_creak", p, -6.0, 0.8)
	if lever != null:
		# (MINE_PASS F-C1: 25 degrees back in 0.4 s; held through the rise; forward in 0.4 s as the flap shuts, 5.6 .. 6.0 s)
		var shut_at := float(lk.get("rise", 6.0)) - 0.4
		var tw := lever.create_tween()
		tw.tween_property(lever, "rotation:z", deg_to_rad(25.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_interval(maxf(0.1, warn + shut_at - 0.4))
		tw.tween_property(lever, "rotation:z", 0.0, 0.4).set_trans(Tween.TRANS_SINE)


## The lock's water, drawn as the rest of the mountain's water is (a body's: _body_vis): Del Mar's surface on top
## and one front across the play space carrying the waterline, the depth (shallow and see-through near the top,
## darker down) and the still water's ripple. Its level moves: every tick the front is stretched to it and the
## surface set on it (_tick_locks). (Till 11-18 a flat panel of the river's colour behind the climb with a pale line
## on top: it read as a painted card, not deep water: the reviewer's q25.)
func _lock_vis(a: Dictionary, z: Dictionary, root: Node3D) -> Node3D:
	var x0 := float(z.rect[0])
	var x1 := float(z.rect[2])
	var floor_y := float(z.rect[1])
	var level := float(z.surface)
	var cols: Array = water_colors(a)
	var n := Node3D.new()
	# the front: x0 .. x1, 0 .. 1 high, stretched to the level every tick
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var still := Color(0.5, 1.0, 0.0, 1.0)  # (no current, a still patch: the body shader's vertex colour)
	var steps := maxi(1, int(ceil((x1 - x0) / 0.5)))
	for i in steps:
		var xl := lerpf(x0, x1, float(i) / steps)
		var xr := lerpf(x0, x1, float(i + 1) / steps)
		for v: Vector3 in [Vector3(xl, 1, 0), Vector3(xr, 1, 0), Vector3(xr, 0, 0), Vector3(xl, 1, 0), Vector3(xr, 0, 0), Vector3(xl, 0, 0)]:
			st.set_color(still)
			st.add_vertex(v)
	var front := MeshInstance3D.new()
	front.mesh = st.commit()
	var fm := ShaderMaterial.new()
	fm.shader = WATER_BODY
	fm.set_shader_parameter("shallow_color", cols[0])
	fm.set_shader_parameter("deep_color", cols[1])
	fm.set_shader_parameter("surface_y", level + Peak.ORIGIN.y)
	fm.set_shader_parameter("mean_flow", 0.0)
	fm.render_priority = 1
	front.material_override = fm
	front.position = Vector3(0, floor_y, WATER_DEPTH * 0.5)
	front.scale.y = maxf(0.02, level + 0.16 - floor_y)
	front.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	front.extra_cull_margin = 16.0  # (stretched every tick: never culled by its first size)
	n.add_child(front)
	# the top: Del Mar's surface, riding the level
	var top := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(x1 - x0, WATER_DEPTH)
	top.mesh = pm
	top.position = Vector3((x0 + x1) * 0.5, level, 0)
	n.add_child(top)
	var sea := DelMarSea.new()
	n.add_child(sea)
	sea.dress(top, level + Peak.ORIGIN.y)
	var tm := top.material_override as ShaderMaterial
	if tm != null:
		tm.set_shader_parameter("shallow_color", cols[0])
		tm.set_shader_parameter("deep_color", cols[1])
		tm.set_shader_parameter("foam_tile_m", 7.0)
		tm.set_shader_parameter("foam_edge_m", 0.3)
		tm.set_shader_parameter("murk_min", 0.8)
		tm.set_shader_parameter("murk_max", 0.97)
	n.set_meta("front", front)
	n.set_meta("top", top)
	n.set_meta("mat", fm)
	n.set_meta("sea", sea)
	root.add_child(n)
	if (z.lock as Dictionary).has("lever"):
		# the keeper's lever by his booth (a stand-in until the booth is made): an iron arm with a brass knob
		var at := Peak.v2(z.lock.lever)
		var pivot := Node3D.new()
		pivot.position = Vector3(at.x, at.y, -1.5)
		var made: Node3D = Peak.kit("esclusa_keeper_lever")  # (frog and lever, one model, its origin the pivot)
		if made != null:
			pivot.add_child(made)
		else:
			var lean := Node3D.new()
			lean.rotation.z = -0.3  # (at rest it leans toward the chamber; hauled, it comes back past upright)
			var arm := LuchaKit.box(Vector3(0.08, 1.3, 0.08), Color("#3A3532"), Vector3(0, 0.65, 0))
			arm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			lean.add_child(arm)
			lean.add_child(LuchaKit.ball(0.11, Color("#C9A24A"), Vector3(0, 1.32, 0)))
			pivot.add_child(lean)
			root.add_child(LuchaKit.box(Vector3(0.5, 0.25, 0.3), Color("#3A3532"), Vector3(at.x, at.y + 0.12, -1.5)))
		root.add_child(pivot)
		n.set_meta("lever", pivot)
	var lk: Dictionary = z.lock
	if lk.has("wheel"):
		# THE GATE WHEEL (MINE_PASS F22): turned on the flap's own travel (_tick_locks). Its model's origin is the hub.
		var wd: Dictionary = lk.wheel
		var hub := Node3D.new()
		hub.name = "GateWheel"
		var wat := Peak.v2(wd.at)
		hub.position = Vector3(wat.x, wat.y, float(wd.z))
		var wheel: Node3D = Peak.kit("esclusa_gate_wheel")
		if wheel != null:
			hub.add_child(wheel)
		else:
			# (a stand-in: an iron rim of twelve lengths, two spokes across, the boss)
			var r := float(wd.get("d", 1.4)) * 0.5
			var iron := Color("#3A3532")
			for k in 12:
				var ang := TAU * k / 12.0
				var seg := LuchaKit.box(Vector3(TAU * r / 12.0 + 0.02, 0.07, 0.07), iron, Vector3(cos(ang) * r, sin(ang) * r, 0))
				seg.rotation.z = ang + PI * 0.5
				seg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				hub.add_child(seg)
			for ang: float in [0.0, PI * 0.5]:
				var spoke := LuchaKit.box(Vector3(r * 2.0, 0.05, 0.05), iron, Vector3.ZERO)
				spoke.rotation.z = ang
				spoke.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				hub.add_child(spoke)
			hub.add_child(LuchaKit.ball(0.09, Color("#C9A24A"), Vector3(0, 0, 0.04)))
		root.add_child(hub)
		n.set_meta("wheel", hub)
	if lk.has("gauge"):
		# THE GAUGE BOARD'S FLOAT (MINE_PASS F23): it rides the water (_tick_locks). Its model's origin is its waterline.
		var gd: Dictionary = lk.gauge
		var fl := Node3D.new()
		fl.name = "GaugeFloat"
		fl.position = Vector3(float(gd.x), float(z.surface), float(gd.z))
		var made_f: Node3D = Peak.kit("esclusa_gauge_float")
		if made_f != null:
			fl.add_child(made_f)
		else:
			var cork := LuchaKit.box(Vector3(0.7, 0.22, 0.18), Color("#C9B48E"), Vector3(0, 0.03, 0))  # (a stand-in: a pale float, a third under)
			cork.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			fl.add_child(cork)
		root.add_child(fl)
		n.set_meta("float", fl)
	return n


## A WHIRLPOOL AND ITS PIPE (note 146; Parker 11-14: "Put a little whirl pool that goes to a pipe. If you get
## sucked in, you go in the pipe and get popped out in the little alcove"): a body whose middle is under the
## water in `rect` is taken: it lets go of everything and comes out of the pipe's mouth at `to`, moving at
## `vel`, with a splash at each end. (A ride zone round both, in the area file, keeps it from counting as
## a fall.)
func _tick_pipes(c: Climber) -> void:
	var com := peak.local_of(c.centre_of_mass())
	for row in pipes:
		var z: Dictionary = row.def
		if peak.clock < float(row.next) or not Peak.rect_has(z.rect, com):
			continue
		row.next = peak.clock + 1.5
		var to := Peak.v2(z.to)
		var vel := Peak.v2(z.get("vel", [0, 0]))
		splash_at(com, 1.0)
		c.release_all()
		var p := c.pose()
		var shift := to - com
		for k in range(0, p.size(), 3):
			p[k] += shift.x
			p[k + 1] += shift.y
		c.apply_pose(p)
		for b: RigidBody3D in c.bodies.values():
			b.linear_velocity = Vector3(vel.x, vel.y, 0)
			b.angular_velocity = Vector3.ZERO
		burst(to, "drops", 1.4, vel.normalized() if vel.length() > 0.01 else Vector2.UP)
		splash_at(to, 0.8)
		return


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
			# Out: a smaller one, where you left it. And the body drips for a moment.
			splash_at(Vector2(clampf(com.x, float(_wet_zone.rect[0]), float(_wet_zone.rect[2])), float(_wet_zone.surface)), 0.5)
			_drip_until = peak.clock + 1.6
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
		drag.y = (float(zone.get("vy", 0.0)) - v.y) * b.mass * 3.0  # (a lock's water carries you up and down with it)
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
		if z.has("throw"):
			want = Peak.v2(z.throw)  # (a pad that puts you somewhere: the same throw however you arrive)
			out = want.length()
		row["squash_t"] = 0.0
		c.release_all()
		for l in c.limbs:
			l.regrip = 0.25
		for body: RigidBody3D in c.bodies.values():
			body.linear_velocity += Vector3(want.x - com_v.x, want.y - com_v.y, 0)
		_bounce_wait = BOUNCE_COOL
		var look := str(z.get("look", "cap"))
		if look == "cap":
			# a puff of spores from under the cap's rim as it throws (a4_dress item 9)
			burst((a + b2) * 0.5 - n * 0.35, "spores", clampf(out / 6.0, 0.6, 1.6), -n)
		if look == "ring":
			Sound.play_at("floatie", Vector3(com.x + Peak.ORIGIN.x, com.y + Peak.ORIGIN.y, 0), 2.0)  # (Del Mar's own boing)
		else:
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
		row["at"] = at
		row["humming"] = near and fposmod(ph, period) > period - warn
		row["hum_f"] = clampf((fposmod(ph, period) - (period - warn)) / maxf(warn, 0.01), 0.0, 1.0)
		if near and int(row.warned) != n and fposmod(ph, period) > period - warn:
			row.warned = n
			peak.audio.play("lightning_hum", at, 2.0)
		# The hand on the metal buzzes through the hum (note 95).
		if c != null:
			for i in c.limbs.size():
				var o = c.limbs[i].grab_other
				peak.things.buzz[i] = bool(row.humming) and o != null and bodies.has(o)
		if n == int(row.n):
			continue
		row.n = n
		if not near:
			continue
		flash = 1.0
		row["struck"] = peak.clock
		_frame_strikes(0.0)  # (finds the metal's tip, the first time)
		_bolt(row, row.get("tip", at))
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


## LIGHTNING SAYS WHAT IT IS (playtest note 95; Parker 11-13: "what is happenin here? We
## keep getting konocked out"). Through the hum, sparks crawl up the mast's metal from its
## foot to the tip, faster and thicker toward the strike. Then a drawn bolt hits the tip
## and the metal is lit (the house tint, not a glow) for the strike's `on` seconds. The
## button mark of a limb on the metal buzzes through the hum (peak_things' glyphs).
const BOLT_COL := Color("#FFE600")
const METAL_LIT := Color(1.9, 2.0, 2.4)


func _frame_strikes(_delta: float) -> void:
	var t := peak.clock
	for row in strikes:
		var bodies: Array = _tags.get(str(row.def.tag), [])
		if bodies.is_empty() or not row.has("at"):
			continue
		if not row.has("foot"):
			# The metal's own reach: its lowest point and its highest (the tip the bolt takes).
			var lo := Vector2(0, INF)
			var hi := Vector2(0, -INF)
			for b in bodies:
				if b is StaticBody3D:
					for ch in (b as Node).get_children():
						if ch is CollisionShape3D and (ch as CollisionShape3D).shape is ConvexPolygonShape3D:
							for q in ((ch as CollisionShape3D).shape as ConvexPolygonShape3D).points:
								var w := Vector2(q.x + (b as Node3D).position.x, q.y + (b as Node3D).position.y)
								if w.y < lo.y:
									lo = w
								if w.y > hi.y:
									hi = w
			row["foot"] = lo if lo.y < INF else (row.at as Vector2) - Vector2(0, 10)
			row["tip"] = hi if hi.y > -INF else (row.at as Vector2)
		var tip: Vector2 = row.tip
		var foot := Vector2(tip.x, (row.foot as Vector2).y)
		if bool(row.get("humming", false)) and t >= float(row.get("spark_next", 0.0)):
			var f := float(row.get("hum_f", 0.0))
			row["spark_next"] = t + lerpf(0.09, 0.03, f)
			# a crawl that climbs the mast faster as the strike comes, and a few on the metal
			var climb := fposmod(t * lerpf(0.8, 3.0, f), 1.0)
			burst(foot.lerp(tip, climb) + Vector2(randf_range(-0.25, 0.25), 0.0), "sparks", lerpf(0.35, 0.9, f))
			if randf() < f:
				burst(foot.lerp(tip, randf()) + Vector2(randf_range(-0.3, 0.3), 0.0), "sparks", 0.4)
		var lit := t - float(row.get("struck", -9.0)) < float(row.def.get("on", 0.4))
		if lit != bool(row.get("lit", false)):
			row["lit"] = lit
			for b in bodies:
				# (every mesh of the piece: a worn skin is the piece's child, a10_dress item 5)
				for ch in (b as Node).find_children("*", "GeometryInstance3D", true, false):
					(ch as GeometryInstance3D).set_instance_shader_parameter(&"tint", METAL_LIT if lit else Color(1, 1, 1))
		var bolt: Node3D = row.get("bolt")
		if bolt != null and is_instance_valid(bolt):
			bolt.visible = t - float(row.get("struck", -9.0)) < 0.28


## The bolt: a jagged fork from the cloud down onto the tip, drawn in the bolt's yellow.
func _bolt(row: Dictionary, tip: Vector2) -> void:
	var old: Node3D = row.get("bolt")
	if old != null and is_instance_valid(old):
		old.queue_free()
	var root := Node3D.new()
	var pts := PackedVector2Array([tip])
	var p := tip
	for i in 9:
		p += Vector2(randf_range(-1.6, 1.6), randf_range(2.6, 4.2))
		pts.append(p)
	# THE BOLT COMES FROM BEHIND (a10_dress 6d): from `bolt_z` back it comes forward as it comes down,
	# and reaches the play space only in its last 3 m at the tip.
	var back := float(row.def.get("bolt_z", 0.0))
	var zs := PackedFloat32Array([0.0])
	var run := 0.0
	var total := 0.0
	for i in pts.size() - 1:
		total += pts[i].distance_to(pts[i + 1])
	for i in range(1, pts.size()):
		run += pts[i - 1].distance_to(pts[i])
		zs.append(lerpf(0.0, back, clampf((run - 3.0) / maxf(total - 3.0, 0.1), 0.0, 1.0)))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3(0, 0, 1))
	for i in pts.size() - 1:
		var a := pts[i]
		var b := pts[i + 1]
		var side := Vector2(-(b - a).y, (b - a).x).normalized() * lerpf(0.12, 0.3, float(i) / pts.size())
		var za := zs[i]
		var zb := zs[i + 1]
		for k in 12:
			var v: Vector2 = [a - side, b - side, b + side, a - side, b + side, a + side, a - side, b + side, b - side, a - side, a + side, b + side][k]
			st.add_vertex(Vector3(v.x, v.y, za if k in [0, 3, 5, 6, 9, 10] else zb))  # (both windings: it is seen from the front, whichever way it zigzags)
	# a fork off its middle
	var fork := pts[4]
	var fz := zs[4]
	var fp := fork
	for i in 3:
		var nxt := fp + Vector2(randf_range(0.8, 2.0) * (1.0 if tip.x < fork.x else -1.0), randf_range(-0.6, 1.4))
		var side2 := Vector2(-(nxt - fp).y, (nxt - fp).x).normalized() * 0.1
		for v in [fp - side2, nxt - side2, nxt + side2, fp - side2, nxt + side2, fp + side2, fp - side2, nxt + side2, nxt - side2, fp - side2, fp + side2, nxt + side2]:
			st.add_vertex(Vector3(v.x, v.y, fz))
		fp = nxt
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	CelPass.paint(mi, BOLT_COL)
	root.add_child(mi)
	root.position = Vector3(0, 0, -0.35)
	var body: Node3D = (_tags.get(str(row.def.tag), []) as Array)[0]
	body.get_parent().add_child(root)
	row["bolt"] = root
	burst(tip, "sparks", 2.0)


# ================================================================ drawn

func frame(_delta: float, _cam: Camera3D) -> void:
	_frame_bounces(_delta)
	_frame_drips()
	_frame_sheds()
	if peak.clock < _drip_until and peak.clock >= _drip_next and peak.player != null and not _wet:
		_drip_next = peak.clock + 0.11
		var parts: Array = peak.player.bodies.values()
		var part: RigidBody3D = parts[randi() % parts.size()]
		burst(peak.local_of(Climber.pos2(part)), "drops", 0.45, Vector2.DOWN, 0.4)
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
		var fx: MeshInstance3D = row.get("fx")
		if fx != null:
			var on := bool(peak._area_active.get(row.area, true))
			fx.visible = on
			if on:
				var mat := fx.material_override as ShaderMaterial
				mat.set_shader_parameter("gust", _gust(row.def))
				mat.set_shader_parameter("warn", 1.0 if _gust_warn(row.def) else 0.0)
	_frame_streamers()
	_frame_strikes(_delta)
	for row in geysers:
		var fx: CPUParticles3D = row.get("fx")
		if fx != null:
			fx.emitting = _geyser_on(row.def) and bool(peak._area_active.get(row.area, true))
		# Between blasts a vent seeps a little steam (note 62: a grate looks like a vent).
		if not _geyser_on(row.def) and bool(peak._area_active.get(row.area, true)) and peak.clock >= float(row.get("seep_at", 0.0)):
			row["seep_at"] = peak.clock + randf_range(0.35, 0.7)
			var at := Peak.v2(row.def.at)
			if peak.player != null and peak.player_at().distance_to(at) < 30.0:
				burst(at + Vector2(randf_range(-0.3, 0.3) * float(row.def.w), 0.15), "steam", 0.3)


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
const WATER_BODY := preload("res://stages/peak/peak_water_body.gdshader")
const WATER_FALL := preload("res://stages/peak/peak_water_fall.gdshader")
const FALL_G := 7.0  # m/s2: the pull a fall is DRAWN under (a look, not a rule)
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


## ONE BODY OF WATER PER CONNECTED STRETCH (playtest note 22, Parker 11-12: "water will
## need a full visual overhaul, it is in weird cubes and it doesn't pour off things or look
## like water"). The RULES are boxes and stay boxes (a river, its quick end, the still
## patch behind each pillar: every one its own current) and are never drawn. What is drawn
## is one body for every run of rules that touch at one surface: the joined outline, so
## there is no seam between two currents, no darker box where a still patch lies over a
## river, and no glass wall where a pool ends. Each body has Del Mar's own surface on top
## (DelMarSea: its foam circles, the rings a splash stamps in, its ink), and one front
## (peak_water_body.gdshader) that carries the waterline, the depth, the current and the
## foam. Returns {index of a water rule in the area's zones -> its body}.
func _build_bodies(a: Dictionary, root: Node3D) -> Dictionary:
	var all: Array = a.get("zones", [])
	var groups: Array = []
	for i in all.size():
		if str(all[i].type) != "water" or (all[i] as Dictionary).has("lock"):
			continue  # (a lock's water is drawn by _lock_vis: its surface moves)
		var mine: Array = [i]
		var keep: Array = []
		for g: Array in groups:
			var touches := false
			for j: int in g:
				if _water_touch(all[i], all[j]):
					touches = true
					break
			if touches:
				mine.append_array(g)
			else:
				keep.append(g)
		keep.append(mine)
		groups = keep
	var out := {}
	for g: Array in groups:
		g.sort()
		var zs: Array = []
		for i: int in g:
			zs.append(all[i])
		var body := _body_vis(a, zs, root)
		if body.is_empty():
			continue
		for i: int in g:
			out[i] = body
	return out


static func _water_touch(p: Dictionary, q: Dictionary) -> bool:
	return is_equal_approx(float(p.surface), float(q.surface)) and float(p.rect[0]) <= float(q.rect[2]) + 0.05 and float(q.rect[0]) <= float(p.rect[2]) + 0.05


## The current at x in a body: [m/s along x, how still a patch it is 0..1]. The rule laid
## last wins, as it does for a climber.
static func _flow_at(zs: Array, x: float, fast: float) -> Vector2:
	var flow := 0.0
	var still := 0.0
	for z: Dictionary in zs:
		if x >= float(z.rect[0]) and x <= float(z.rect[2]):
			flow = float(z.flow[0])
			still = 1.0 if (str(z.get("look", "")) == "eddy" or (absf(flow) < 0.45 and fast >= 1.0)) else 0.0
	return Vector2(flow, still)


func _in_rock(area: String, p: Vector2) -> bool:
	for row: Array in peak.things._rock.get(area, []):
		if (row[0] as Rect2).has_point(p) and Geometry2D.is_point_in_polygon(p, row[1]):
			return true
	return false


func _body_vis(a: Dictionary, zs: Array, root: Node3D) -> Dictionary:
	var surface := float(zs[0].surface)
	var x0 := INF
	var x1 := -INF
	var low := INF
	var fast := 0.0
	var edges: Array = []
	for z: Dictionary in zs:
		x0 = minf(x0, float(z.rect[0]))
		x1 = maxf(x1, float(z.rect[2]))
		low = minf(low, float(z.rect[1]))
		fast = maxf(fast, absf(float(z.flow[0])))
		edges.append(float(z.rect[0]))
		edges.append(float(z.rect[2]))
	var w := x1 - x0
	if w <= 0.0 or surface - low <= 0.0:
		return {}
	edges.sort()
	var n := Node3D.new()
	var mid_x := (x0 + x1) * 0.5
	var cols: Array = water_colors(a)
	# the top: Del Mar's surface, once for the whole body
	var top := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	# (its back edge at the play space's depth, or further back where a rule says: the flume's surface runs into its
	# tunnel's mouth, on the wall's face, so its edge is not drawn in the mouth: the reviewer's q20)
	var back := -WATER_DEPTH * 0.5
	for z: Dictionary in zs:
		if z.has("back"):
			back = minf(back, float(z.back))
	pm.size = Vector2(w, WATER_DEPTH * 0.5 - back)
	top.mesh = pm
	top.position = Vector3(mid_x, surface, (WATER_DEPTH * 0.5 + back) * 0.5)
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
	# the front: one mesh along the joined outline, the bed stepping where the rules' beds do
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var sum_flow := 0.0
	var sum_w := 0.0
	for k in edges.size() - 1:
		var xa: float = edges[k]
		var xb: float = edges[k + 1]
		if xb - xa < 0.01:
			continue
		var bed := low
		var covered := false
		var here := INF
		for z: Dictionary in zs:
			if (xa + xb) * 0.5 >= float(z.rect[0]) and (xa + xb) * 0.5 <= float(z.rect[2]):
				here = minf(here, float(z.rect[1]))
				covered = true
		if not covered:
			continue
		bed = here
		var f_mid := _flow_at(zs, (xa + xb) * 0.5, fast)
		sum_flow += f_mid.x * (xb - xa) * (1.0 - f_mid.y)
		sum_w += (xb - xa) * (1.0 - f_mid.y)
		var steps := maxi(1, int(ceil((xb - xa) / 0.5)))
		for i in steps:
			var xl := lerpf(xa, xb, float(i) / steps)
			var xr := lerpf(xa, xb, float(i + 1) / steps)
			var cl := _body_color(zs, xl, x0, x1, fast)
			var cr := _body_color(zs, xr, x0, x1, fast)
			var tl := Vector3(xl, surface + 0.16, 0)
			var tr := Vector3(xr, surface + 0.16, 0)
			var bl := Vector3(xl, bed, 0)
			var br := Vector3(xr, bed, 0)
			for row: Array in [[tl, cl], [tr, cr], [br, cr], [tl, cl], [br, cr], [bl, cl]]:
				st.set_color(row[1])
				st.add_vertex(row[0])
	var front := MeshInstance3D.new()
	front.mesh = st.commit()
	var fm := ShaderMaterial.new()
	fm.shader = WATER_BODY
	fm.set_shader_parameter("shallow_color", cols[0])
	fm.set_shader_parameter("deep_color", cols[1])
	fm.set_shader_parameter("surface_y", surface + Peak.ORIGIN.y)
	fm.set_shader_parameter("mean_flow", sum_flow / maxf(sum_w, 0.01))
	fm.render_priority = 1  # (over the surface's underside, seen from below the waterline)
	front.material_override = fm
	front.position = Vector3(0, 0, WATER_DEPTH * 0.5)
	front.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	front.extra_cull_margin = 1.0
	n.add_child(front)
	root.add_child(n)
	var body := {"area": str(a.id), "x0": x0, "x1": x1, "surface": surface, "zs": zs, "sea": sea, "mat": fm, "node": n, "foams": [], "first": []}
	# FOAM WHERE THE WATER MEETS SOMETHING: its two ends, and every pile or pillar that
	# stands through the waterline. (A lip and the foot of a fall add theirs: _fall_vis.)
	var area := str(a.id)
	body.foams.append(Vector3(x0, 0.55, 1.0))
	body.foams.append(Vector3(x1, 0.55, 1.0))
	var was := false
	var x := x0 + 0.15
	while x < x1 - 0.15:
		var now := _in_rock(area, Vector2(x, surface - 0.08))
		if now != was:
			body.foams.append(Vector3(x - 0.05 if now else x, 0.45, 0.9))
			was = now
		x += 0.1
	water_bodies.append(body)
	return body


## A vertex's colour for the body's shader: r the flow (smoothed over a metre, so a quick
## end and a still patch run into the river with no line), g how still.
static func _body_color(zs: Array, x: float, x0: float, x1: float, fast: float) -> Color:
	var acc := Vector2.ZERO
	for d: float in [-0.6, -0.3, 0.0, 0.3, 0.6]:
		acc += _flow_at(zs, clampf(x + d, x0 + 0.01, x1 - 0.01), fast)
	acc /= 5.0
	return Color(clampf(acc.x / 8.0 + 0.5, 0.0, 1.0), acc.y, 0.0, 1.0)


## The foam is known only once the area's falls are (a lip, a foot): hand each body its list.
func _finish_bodies(area: String) -> void:
	for body: Dictionary in water_bodies:
		if str(body.area) != area:
			continue
		var list: Array = (body.first as Array) + (body.foams as Array)
		var packed := PackedVector3Array()
		for i in mini(list.size(), 12):
			var f: Vector3 = list[i]
			packed.append(Vector3(f.x + Peak.ORIGIN.x, f.y, f.z))
		var count := packed.size()
		while packed.size() < 12:
			packed.append(Vector3.ZERO)
		(body.mat as ShaderMaterial).set_shader_parameter("foam_count", count)
		(body.mat as ShaderMaterial).set_shader_parameter("foams", packed)


## The water rule in this area that pours into a fall's box: {x the lip, dir +1 east / -1
## west, surface, flow m/s, depth m, body}, or {} (a fall that comes out of the rock, or
## carries on from the area above).
func _fall_lip(a: Dictionary, r: Array) -> Dictionary:
	var top := float(r[3])
	var all: Array = a.get("zones", [])
	for i in all.size():
		var z: Dictionary = all[i]
		if str(z.type) != "water":
			continue
		var s := float(z.surface)
		if s < top - 0.3 or s > top + 1.6:
			continue
		var f := float(z.flow[0])
		var hit := {}
		if f >= 0.0 and absf(float(z.rect[2]) - float(r[0])) <= 0.8:
			hit = {"x": float(z.rect[2]), "dir": 1.0}
		elif f <= 0.0 and absf(float(z.rect[0]) - float(r[2])) <= 0.8:
			hit = {"x": float(z.rect[0]), "dir": -1.0}
		if hit.is_empty():
			continue
		hit["surface"] = s
		hit["flow"] = absf(f)
		hit["depth"] = s - float(z.rect[1])
		for row in waters:
			if row.def == z and row.has("body"):
				hit["body"] = row.body
		return hit
	return {}


## WATER THAT POURS. A fall is a ribbon along the water's own path, seen from the side as
## everything here is: out of its pool over the lip in a bend, then down to whatever it
## lands on, with broken white over the lip, streaks that speed up as they fall, and
## white, mist and churn at its foot. (It was a pale slab the width of its whole shaft,
## standing beside the pool it came from.) The box in the data is the shaft it falls in.
## In the data: "x" places a fall that no pool in this area feeds, "head" (0..1) is how
## white its top is then, "through" says it carries on into the area below (no foot),
## "density" under 1 is a thinner one.
func _fall_vis(a: Dictionary, e: Dictionary, root: Node3D) -> void:
	var r: Array = e.rect
	var density := float(e.get("density", 1.0))
	var w := float(r[2]) - float(r[0])
	var top_y := float(r[3])
	var foot_y := float(r[1])
	var lip := _fall_lip(a, r)
	var width := float(e.get("width", clampf(0.42 * density + 0.14, 0.2, 0.6)))
	var xr := float(e.get("x", (float(r[0]) + float(r[2])) * 0.5))
	var v0 := 1.4
	var mid: Array = []  # the ribbon's middle line, and at each point its normal and width
	if lip.is_empty():
		mid.append([Vector2(xr, top_y), Vector2(1, 0), width])
		mid.append([Vector2(xr, foot_y), Vector2(1, 0), width * 0.8])
	else:
		# THE WHOLE DEPTH OF THE POOL GOES OVER: the ribbon starts as thick as the pool is
		# deep, its top the waterline and its bottom the bed's corner, and thins as it
		# speeds up, as falling water does (thickness x speed stays the same). So the
		# pool has no end wall: its end IS the fall.
		var dir := float(lip.dir)
		var depth := float(lip.depth)
		v0 = maxf(float(lip.flow), 1.0)
		var out := clampf(v0 * 0.9, 0.5, maxf(0.5, w - 0.3))  # how far out from the lip it ends up
		var c0 := Vector2(float(lip.x), float(lip.surface) - depth * 0.5)
		var t_end := sqrt(2.0 * maxf(0.1, c0.y - foot_y) / FALL_G)
		var times: Array = []
		var t := 0.0
		while t < minf(1.2, t_end):
			times.append(t)
			t += 0.06
		while t < t_end:
			times.append(t)
			t += 0.3
		times.append(t_end)
		for tt: float in times:
			var c := Vector2(c0.x + dir * out * (1.0 - exp(-v0 * tt / out)), c0.y - 0.5 * FALL_G * tt * tt)
			var tan := Vector2(dir * v0 * exp(-v0 * tt / out), -FALL_G * tt).normalized()
			var nrm := Vector2(-tan.y, tan.x) * dir
			var thick := clampf(depth * v0 / sqrt(v0 * v0 + FALL_G * FALL_G * tt * tt), 0.13, depth)
			mid.append([c, nrm, thick])
		xr = (mid[mid.size() - 1][0] as Vector2).x
		width = float(mid[mid.size() - 1][2])
	# the ribbon: UV.x runs across it from its outer edge, UV.y is metres along it
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var along := 0.0
	var left: Array = []
	var right: Array = []
	var dist: Array = []
	for i in mid.size():
		var c: Vector2 = mid[i][0]
		if i > 0:
			along += c.distance_to(mid[i - 1][0])
		left.append(c + (mid[i][1] as Vector2) * float(mid[i][2]) * 0.5)
		right.append(c - (mid[i][1] as Vector2) * float(mid[i][2]) * 0.5)
		dist.append(along)
	for i in mid.size() - 1:
		for row: Array in [[left[i], 0.0, dist[i]], [right[i], 1.0, dist[i]], [right[i + 1], 1.0, dist[i + 1]],
				[left[i], 0.0, dist[i]], [right[i + 1], 1.0, dist[i + 1]], [left[i + 1], 0.0, dist[i + 1]]]:
			st.set_uv(Vector2(float(row[1]), float(row[2])))
			st.add_vertex(Vector3((row[0] as Vector2).x, (row[0] as Vector2).y, 0))
	var sheet := MeshInstance3D.new()
	sheet.mesh = st.commit()
	var cols: Array = water_colors(a)
	var fm := ShaderMaterial.new()
	fm.shader = WATER_FALL
	var wc: Color = (cols[0] as Color).lerp(Color("#DDF2FB"), 0.62)
	fm.set_shader_parameter("water_color", Color(wc.r, wc.g, wc.b, 0.66))
	fm.set_shader_parameter("head_color", (cols[0] as Color).lerp(cols[1], 0.35) if not lip.is_empty() else Color(wc.r, wc.g, wc.b, 0.66))
	fm.set_shader_parameter("length_m", along)
	fm.set_shader_parameter("width_m", width)
	fm.set_shader_parameter("v0", v0)
	fm.set_shader_parameter("top_white", 1.0 if not lip.is_empty() else float(e.get("head", 0.5)))
	var through := bool(e.get("through", false))  # it carries on into the area below: no foot here
	fm.set_shader_parameter("foot_white", 0.0 if through else 1.0)
	sheet.material_override = fm
	fall_sheets.append({"area": str(a.id), "x": xr, "top": top_y, "foot": foot_y, "mat": fm, "node": sheet})
	# A fall that leaves a pool is drawn where the pool's front is, so the two are one
	# piece of water (and it is in front of the climber, as the pool is). One that comes
	# out of the rock stays behind the climb unless the data says "front".
	var in_front := not lip.is_empty() or bool(e.get("front", false))
	sheet.position = Vector3(0, 0, WATER_DEPTH * 0.5 - 0.01 if in_front else float(e.get("z", -0.4)))
	sheet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sheet.extra_cull_margin = 1.0
	root.add_child(sheet)
	peak.audio.emitter("waterfall_loop", Vector2(xr, foot_y + minf((top_y - foot_y) * 0.3, 12.0)), 1.0, 40.0)
	if lip.has("body"):
		# (no foam piled against a wall at this end: there is no wall, it goes over)
		var kept: Array = []
		for f: Vector3 in (lip.body as Dictionary).foams:
			if absf(f.x - float(lip.x)) > 0.3:
				kept.append(f)
		(lip.body as Dictionary).foams = kept
	if through:
		return
	# Where it lands in a pool it churns it: foam on the waterline, Del Mar's spray and
	# rings for as long as the climber is near enough to see, and a mist over it.
	var foot := _water_row(Vector2(xr, foot_y))
	if not foot.is_empty():
		_churns.append([foot, xr - 0.45, xr + 0.45, 0.0, str(a.id)])
		if foot.has("body"):
			((foot.body as Dictionary).first as Array).append(Vector3(xr, 1.3, 1.6))
	if top_y - foot_y > 2.5:
		var mist := _particles(Color("#EAF6FC"), 5.0, int(clampf(7.0 * density + 4.0, 5.0, 14.0)), 2.6)
		(mist.material_override as StandardMaterial3D).albedo_color.a = 0.26
		mist.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		mist.emission_box_extents = Vector3(0.55, 0.12, 0.4)
		mist.direction = Vector3.UP
		mist.spread = 35.0
		mist.initial_velocity_min = 0.25
		mist.initial_velocity_max = 0.8
		mist.gravity = Vector3.ZERO
		mist.position = Vector3(xr, foot_y + 0.3, 0.9)
		root.add_child(mist)
	if foot.is_empty():
		# it lands on a floor: it spatters
		var sp := _drops(int(clampf(10.0 * density, 5.0, 14.0)), 0.55)
		sp.direction = Vector3.UP
		sp.spread = 65.0
		sp.initial_velocity_min = 0.9
		sp.initial_velocity_max = 2.4
		sp.position = Vector3(xr, foot_y + 0.06, 0.2)
		root.add_child(sp)


## Round water drops under the game's slow gravity (never a square speck).
func _drops(amount: int, life: float) -> CPUParticles3D:
	var p := _particles(Color("#D6EEF9"), 0.55, amount, life)
	(p.material_override as StandardMaterial3D).albedo_texture = _dot()
	p.gravity = Vector3(0, -7.0, 0)
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.3
	return p


static var _dot_tex: GradientTexture2D = null


static func _dot() -> GradientTexture2D:
	if _dot_tex == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.82, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
		_dot_tex = GradientTexture2D.new()
		_dot_tex.gradient = g
		_dot_tex.fill = GradientTexture2D.FILL_RADIAL
		_dot_tex.fill_from = Vector2(0.5, 0.5)
		_dot_tex.fill_to = Vector2(1.0, 0.5)
		_dot_tex.width = 32
		_dot_tex.height = 32
	return _dot_tex


## THINGS SHED WATER: a wheel that turns over a body of water lifts it and drops it. Each
## paddle carries a little emitter; it runs while that paddle is on its way up out of the
## water, for the first couple of metres.
func _find_sheds(a: Dictionary, root: Node3D) -> void:
	for m: Dictionary in a.get("movers", []):
		var mo: Dictionary = m.get("motion", {})
		if str(mo.get("type", "")) != "spin" or not str(m.get("model", "")).contains("wheel"):
			continue
		var c := Peak.v2(m.at)
		var r := 0.0
		for sh: Dictionary in m.get("shapes", []):
			for pt in sh.pts:
				r = maxf(r, Vector2(float(pt[0]), float(pt[1])).length())
		for body: Dictionary in water_bodies:
			if str(body.area) != str(a.id) or c.x < float(body.x0) or c.x > float(body.x1):
				continue
			var surface := float(body.surface)
			if c.y < surface or c.y - r > surface + 0.9:
				continue
			var ems: Array = []
			for k in 6:
				var e := _drops(7, 0.75)
				e.local_coords = false
				e.direction = Vector3.DOWN
				e.spread = 25.0
				e.initial_velocity_min = 0.1
				e.initial_velocity_max = 0.7
				e.emitting = false
				root.add_child(e)
				ems.append(e)
			_sheds.append({"id": str(m.id), "c": c, "r": r, "surface": surface, "area": str(a.id), "em": ems})
			break


func _frame_sheds() -> void:
	for sh: Dictionary in _sheds:
		var on_area := bool(peak._area_active.get(sh.area, true))
		var mv: Dictionary = peak.things.movers.get(sh.id, {})
		var ems: Array = sh.em
		if mv.is_empty() or not on_area:
			for e: CPUParticles3D in ems:
				e.emitting = false
			continue
		var turn := float((mv.mo as Dictionary).get("rpm", 0.0))
		var c: Vector2 = sh.c
		for k in ems.size():
			var ang := float(mv.angle) + float(k) * TAU / ems.size()
			var tip := c + Vector2(cos(ang), sin(ang)) * float(sh.r)
			var rising := turn * cos(ang) > 0.0
			var e: CPUParticles3D = ems[k]
			e.position = Vector3(tip.x, tip.y, 0.3)
			e.emitting = rising and tip.y < float(sh.surface) + 2.6


## A BOUNCE PAD YOU CAN SEE WORK (Parker 11-12: "add a bouncy lifesaver here", "these
## mushrooms need to have bounce animations"). A pad that names a model is drawn lying
## along its line and squashes when it throws someone, by Del Mar's floats' own recipe:
## flat in 0.07 s, then a spring that rings down (tall and thin, flat again, smaller each
## time) over a second.
const SQUASH_S := 1.1
const SQUASH_DEEP := 0.42


func _bounce_vis(_a: Dictionary, z: Dictionary, root: Node3D, row: Dictionary) -> void:
	var n := Peak.kit(str(z.model))
	if n == null:
		return
	var a := Peak.v2(z.a)
	var b := Peak.v2(z.b)
	var pivot := Node3D.new()
	pivot.position = Vector3((a.x + b.x) * 0.5, (a.y + b.y) * 0.5, 0)
	pivot.rotation.z = (b - a).angle()
	n.scale = Vector3.ONE * float(z.get("model_scale", 1.0))
	pivot.add_child(n)
	root.add_child(pivot)
	row["vis"] = pivot
	row["squash_t"] = 9.0


## A CAP THAT SQUASHES (note 36: "squash and spring, the stalk rocking"): a bounce that names
## the tagged solid it lies on (`squash_tag`) takes that solid's own drawn piece under a pivot
## at the bounce line's middle, turned along it, so the squash flattens the cap about its face.
func _bounce_squash(z: Dictionary, root: Node3D, row: Dictionary) -> void:
	var bodies: Array = _tags.get(str(z.squash_tag), [])
	if bodies.is_empty():
		return
	var sb: Node = bodies[0]
	var piece: Node3D = null
	for ch in sb.get_children():
		if ch is Node3D and not (ch is CollisionShape3D):
			piece = ch
			break
	if piece == null:
		return
	var a := Peak.v2(z.a)
	var b := Peak.v2(z.b)
	var pivot := Node3D.new()
	pivot.position = Vector3((a.x + b.x) * 0.5, (a.y + b.y) * 0.5, 0)
	pivot.rotation.z = (b - a).angle()
	root.add_child(pivot)
	piece.reparent(pivot, true)
	row["vis"] = pivot
	row["squash_t"] = 9.0


## A RING ROPE THAT HAS NO MODEL IS STILL DRAWN (playtest note 98; Parker 11-13: "oh there
## is invisible bouncy stuff"): a thick band lying exactly along its bouncing line, a
## padded cushion at each end, in the ring's colours by turn (red, cream, jade), standing
## proud of the rock. It squashes and springs when it throws you, as a cap does. The real
## rope model replaces it later.
const ROPE_COLS := [Color("#D8262E"), Color("#EFE3C6"), Color("#2FA37C")]
const ROPE_THICK := 0.2
const ROPE_PAD := 0.42
var _ropes_drawn := 0


func _rope_band(z: Dictionary, root: Node3D, row: Dictionary) -> void:
	var a := Peak.v2(z.a)
	var b := Peak.v2(z.b)
	var len := a.distance_to(b)
	var pivot := Node3D.new()
	pivot.position = Vector3((a.x + b.x) * 0.5, (a.y + b.y) * 0.5, 0.0)
	pivot.rotation.z = (b - a).angle()
	var col: Color = ROPE_COLS[_ropes_drawn % ROPE_COLS.size()]
	_ropes_drawn += 1
	var band := LuchaKit.box(Vector3(len, ROPE_THICK, ROPE_THICK * 1.4), col)
	band.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pivot.add_child(band)
	for e in [-1.0, 1.0]:
		var pad := LuchaKit.box(Vector3(ROPE_PAD * 0.8, ROPE_PAD, ROPE_PAD), Color("#2E2A2C"))
		pad.position = Vector3(e * len * 0.5, 0.0, 0.0)
		pivot.add_child(pad)
	root.add_child(pivot)
	row["vis"] = pivot
	row["squash_t"] = 9.0


static func squash_curve(st: float) -> float:
	if st < 0.07:
		return st / 0.07
	if st < SQUASH_S:
		var u := st - 0.07
		return exp(-u * 4.2) * cos(u * 15.0)
	return 0.0


func _frame_bounces(delta: float) -> void:
	for row in bounces:
		if not row.has("vis") or float(row.get("squash_t", 9.0)) > SQUASH_S + 0.1:
			continue
		row.squash_t = float(row.squash_t) + delta
		var sq := squash_curve(float(row.squash_t))  # 1 = squashed flat, -1 = stretched tall
		var wide := 1.0 + (0.28 if sq > 0.0 else 0.16) * sq
		var tall := 1.0 - (SQUASH_DEEP if sq > 0.0 else 0.3) * sq
		(row.vis as Node3D).scale = Vector3(wide, tall, wide)


## FAT DRIPS RUNNING DOWN A LINE (La Cortina's two columns of holds; Parker 11-12: "maybe
## like a slow moving water drip you can watch fall down and get them wet"). The drip is
## the tell AND the cause: a hold on the line turns wet as a drip reaches it (its own
## `wet` clock is set to this line's by the course: peaklib's drip_phase).
func _drips_vis(z: Dictionary, root: Node3D, row: Dictionary) -> void:
	var length := Peak.v2(z.a).distance_to(Peak.v2(z.b))
	var count := int(ceil(length / maxf(1.0, float(z.gap)))) + 1
	var nodes: Array = []
	for i in count:
		var drop := Node3D.new()
		var ball := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.17
		sm.height = 0.34
		ball.mesh = sm
		ball.scale = Vector3(1.0, 1.45, 1.0)
		ball.material_override = _flat(Color("#CFEFFF"), 0.92)
		ball.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		drop.add_child(ball)
		var shine := MeshInstance3D.new()
		var hm := SphereMesh.new()
		hm.radius = 0.055
		hm.height = 0.11
		shine.mesh = hm
		shine.material_override = _flat(Color("#FFFFFF"), 1.0)
		shine.position = Vector3(-0.05, 0.08, 0.14)
		drop.add_child(shine)
		var tail := MeshInstance3D.new()  # the wet it leaves behind it
		var qm := QuadMesh.new()
		qm.size = Vector2(0.1, 1.5)
		tail.mesh = qm
		tail.material_override = _flat(Color("#9FD0F0"), 0.45)
		tail.position = Vector3(0, 0.95, -0.02)
		drop.add_child(tail)
		drop.visible = false
		root.add_child(drop)
		nodes.append(drop)
	row["nodes"] = nodes


func _frame_drips() -> void:
	for row in drip_lines:
		var on: bool = bool(peak._area_active.get(row.area, true)) and peak.player != null
		var z: Dictionary = row.def
		var a := Peak.v2(z.a)
		var b := Peak.v2(z.b)
		if on:
			on = Geometry2D.get_closest_point_to_segment(peak.player_at(), a, b).distance_to(peak.player_at()) < 40.0
		var length := a.distance_to(b)
		var gap := maxf(1.0, float(z.gap))
		var head := fposmod(float(z.speed) * (peak.clock + float(z.get("phase", 0.0))), gap)
		var nodes: Array = row.nodes
		for i in nodes.size():
			var s := head + gap * i
			var n: Node3D = nodes[i]
			n.visible = on and s <= length
			if n.visible:
				var p := a.lerp(b, s / length)
				n.position = Vector3(p.x, p.y, 0.42)
				n.rotation.z = (b - a).angle() + PI * 0.5


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
		(p.material_override as StandardMaterial3D).albedo_texture = _dot() if kind == "drops" else null
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


const WIND_LOOK := preload("res://stages/peak/peak_wind.gdshader")
var _wind_seed := 0.0


func _wind_fx(a: Dictionary, z: Dictionary, root: Node3D) -> MeshInstance3D:
	var r: Array = z.rect
	var w := float(r[2]) - float(r[0])
	var h := float(r[3]) - float(r[1])
	var acc := Peak.v2(z.accel)
	if acc.length() < 0.1:
		return null
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(w, h)
	mi.mesh = q
	var mat := ShaderMaterial.new()
	mat.shader = WIND_LOOK
	mat.set_shader_parameter("size", Vector2(w, h))
	mat.set_shader_parameter("dir", acc.normalized())
	mat.set_shader_parameter("speed", 3.0 + acc.length() * 1.6)
	mat.set_shader_parameter("seed", _wind_seed)
	mat.set_shader_parameter("gust", 0.0)
	_wind_seed += 1.37
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = Vector3((float(r[0]) + float(r[2])) * 0.5, (float(r[1]) + float(r[3])) * 0.5, 0.6)
	root.add_child(mi)
	_streamers_in(a, z, root)
	return mi


## ...AND THE WORLD STREAMS IN IT (note 89, "the flag"): every pole of the area standing in a
## wind's box flies a streamer from its top, which streams the wind's way while it blows
## and hangs slack between gusts. A chain of short painted pieces on the one material,
## laid out every frame (frame()).
const STREAMER_POLES := ["streamer_pole", "flag_pole", "pole_flag", "wind_sock", "cane_flag", "tormenta_wind_sock"]
const STREAMER_COLS := [Color("#D8262E"), Color("#FFD23F"), Color("#2FA37C"), Color("#EFE3C6")]
const STREAMER_N := 6
const STREAMER_SEG := 0.26  # m a piece
var streamers: Array = []  # {"at": Vector2, "z", "pieces": [Node3D], "wind": the wind's zone def, "area", "phase"}


func _streamers_in(a: Dictionary, z: Dictionary, root: Node3D) -> void:
	for d in a.get("decos", []):
		var model := str(d.get("model", ""))
		if not STREAMER_POLES.has(model):
			continue
		var top := Vector2(float(d.at[0]), float(d.at[1]) + float((d.get("size", [0, 2.0]) as Array)[1]) * 0.96)
		if not Peak.rect_has(z.rect, top):
			continue
		var pieces: Array = []
		var col: Color = STREAMER_COLS[streamers.size() % STREAMER_COLS.size()]
		for i in STREAMER_N:
			var p := LuchaKit.box(Vector3(STREAMER_SEG * 1.08, lerpf(0.16, 0.08, float(i) / STREAMER_N), 0.02), col)
			p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			root.add_child(p)
			pieces.append(p)
		streamers.append({"at": top, "z": float(d.at[2]) if (d.at as Array).size() > 2 else 0.0, "pieces": pieces,
			"wind": z, "area": str(a.id), "phase": randf() * TAU})


func _frame_streamers() -> void:
	var t := peak.clock
	for st: Dictionary in streamers:
		if not bool(peak._area_active.get(st.area, true)):
			continue
		var z: Dictionary = st.wind
		var k := _gust(z)
		var acc := Peak.v2(z.accel)
		var hang := -PI * 0.5
		var blow := acc.angle()
		var base := lerp_angle(hang + 0.25 * signf(acc.x), blow, clampf(k, 0.0, 1.0))
		var p: Vector2 = st.at
		for i in (st.pieces as Array).size():
			var u := float(i) / STREAMER_N
			var flutter := (sin(t * 11.0 - float(i) * 0.95 + float(st.phase)) * 0.32 * k + sin(t * 2.1 + float(i) + float(st.phase)) * 0.07) * (0.3 + u)
			var ang := base + flutter
			var step := Vector2(cos(ang), sin(ang)) * STREAMER_SEG
			var piece: Node3D = st.pieces[i]
			piece.position = Vector3(p.x + step.x * 0.5, p.y + step.y * 0.5, float(st.z) + 0.05)
			piece.rotation = Vector3(0, 0, ang)
			p += step


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
		_fall_vis(a, e, root)
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
	var c: Array = (cfg[kind] as Array).duplicate()
	if e.has("tone"):  # (an effect may name its colour: a hex, or one of the area's tones)
		var t := str(e.tone)
		c[0] = Color(t) if t.begins_with("#") else peak.tone(a, t)
	if e.has("speed"):  # (and how fast it drifts, as a share of its kind's own)
		c[3] = (c[3] as Vector3) * float(e.speed)
	if e.has("size"):  # (a mote's size, m)
		c[1] = float(e.size)
	if e.has("alpha"):  # (and how solid it is)
		c[5] = float(e.alpha)
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
	if e.has("z"):
		# a thin layer at its own depth (the wisps over La Nube: behind the climb, never in front)
		p.position.z = float(e.z)
		p.emission_box_extents.z = 0.12
	root.add_child(p)
