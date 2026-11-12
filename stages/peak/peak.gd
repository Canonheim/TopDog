class_name Peak
extends Node3D
## THE PEAK OF DEGAYO: the solo climb (docs/peak/PEAK_DESIGN.md).
##
## The course is data: stages/peak/course/<area>.json, written by tools/peak/areas/*.py
## through tools/peak/peaklib.py. This node builds it and runs it:
##   - solids: cardboard rock, grip or slick (`no_weld`), with the holds that crumble,
##     let go, or get wet;
##   - things (peak_things.gd): movers, ropes, free bodies, fallers, the ones who tried;
##   - zones (peak_zones.gd): water, wind, geysers, bounce, lightning, dark, the finish;
##   - sound (peak_audio.gd): twelve loops in step, mixed by where you are.
## Everything is in the course's local metres under this node, which stands at ORIGIN
## (the trailhead, at the west edge of the plaza's land). Altitude = local y.

const ORIGIN := Vector3(-110.0, -0.9, 0.0)
const COURSE := "res://stages/peak/course/"
const HALF := 1.2  # solids are this thick each side of the play plane
const ACTIVE_PAD := 55.0  # an area's moving things run while the climber is this near its region
const BLEND_M := 14.0  # areas' looks and sounds cross-fade over this far past a region's edge
const SAVE_PATH := "user://peak.cfg"
const SAVE_EVERY_S := 2.0
const FALL_COUNT_M := 15.0  # a drop of this much is a fall on the tally

var game  # Game
var course_dir := COURSE  # (the batteries point it at tests/peak_lab/)
var meta := {}
var areas: Array = []  # the area dictionaries, in climbing order
var challenges: Array = []  # every challenge, in order: {id, name, anchor, d, miss, area}
var clock := 0.0  # the course's own clock: every cycle in the world reads it (saved, so a resume matches)
var things: PeakThings
var zones: PeakZones
var audio: PeakAudio
var backdrop: PeakBackdrop
var player: Climber = null
var active := false
var finished := false
var built := false

# the tally (saved)
var time_s := 0.0
var falls := 0
var best_m := 0.0
var summits := 0
var best_time_s := 0.0
var saved_pose := PackedFloat32Array()
var area_now := ""
var weights := {}  # area id -> 0..1, how much of that area's look and sound is on

var _roots := {}  # area id -> Node3D holding its drawn and moving things
var _area_active := {}
var _save_t := 0.0
var _firm_pose := PackedFloat32Array()  # the last pose with a hand or foot on something
var _high_y := -INF  # the highest the climber has been since it last held on (a fall is measured from it)
var _falling := false
var _yelled := false
var _still_t := 0.0
var _lamp: OmniLight3D
var _lights: Array = []  # [OmniLight3D, base energy, flicker, area id]
var _milestone := 0
var dev_warp := false
var _warp_i := 0

signal area_entered(id: String, name: String, number: int)
signal fell(metres: float)
signal milestone(metres: int)
signal summit(time_s: float, falls: int, best_s: float)


static func v2(a) -> Vector2:
	return Vector2(float(a[0]), float(a[1]))


static func rect_has(r: Array, p: Vector2, pad := 0.0) -> bool:
	return p.x >= float(r[0]) - pad and p.x <= float(r[2]) + pad and p.y >= float(r[1]) - pad and p.y <= float(r[3]) + pad


## A climber's place in the course's own metres.
func local_of(world_p: Vector2) -> Vector2:
	return world_p - Vector2(ORIGIN.x, ORIGIN.y)


func world_of(p: Vector2) -> Vector2:
	return p + Vector2(ORIGIN.x, ORIGIN.y)


func player_at() -> Vector2:
	if player == null or not is_instance_valid(player):
		return Vector2.ZERO
	return local_of(player.centre_of_mass())


# ================================================================ build

func setup(p_game) -> void:
	game = p_game
	position = ORIGIN
	name = "Peak"
	if built:
		return
	built = true
	var text := FileAccess.get_file_as_string(course_dir + "_meta.json")
	meta = JSON.parse_string(text) if not text.is_empty() else {}
	if meta.is_empty():
		push_error("Peak: no course meta")
		return
	things = PeakThings.new(self)
	zones = PeakZones.new(self)
	audio = PeakAudio.new()
	audio.name = "PeakAudio"
	add_child(audio)
	audio.setup(self)
	for id in meta.order:
		var t2 := FileAccess.get_file_as_string(course_dir + str(id) + ".json")
		if t2.is_empty():
			continue
		var a: Dictionary = JSON.parse_string(t2)
		areas.append(a)
		_build_area(a)
		for c in a.get("challenges", []):
			var row: Dictionary = (c as Dictionary).duplicate()
			row["area"] = a.id
			challenges.append(row)
	challenges.sort_custom(func(x, y): return _cid_key(str(x.id)) < _cid_key(str(y.id)))
	backdrop = PeakBackdrop.build(self, ORIGIN)  # the far layers: the valley, the ranges, the sea of cloud (the Environment Maker's)
	_lamp = OmniLight3D.new()
	_lamp.light_color = Color("#FFD9A0")
	_lamp.omni_range = 9.0
	_lamp.light_energy = 0.0
	_lamp.shadow_enabled = false
	add_child(_lamp)
	_load()


static func _cid_key(id: String) -> float:
	return float(id.get_slice(".", 0)) * 100.0 + float(id.get_slice(".", 1))


func palette_of(a: Dictionary) -> Dictionary:
	return meta.palettes[a.palette]


func tone(a: Dictionary, slot: String) -> Color:
	if slot.begins_with("#"):
		return Color(slot)
	var pal: Dictionary = palette_of(a)
	return Color(str(pal.get(slot, "#FF00FF")))


func kind_color(a: Dictionary, kind: String) -> Color:
	return tone(a, str(meta.kinds[kind].tone))


func kind_grips(kind: String) -> bool:
	return bool(meta.kinds[kind].grip)


func _build_area(a: Dictionary) -> void:
	var root := Node3D.new()
	root.name = "Area_" + str(a.id)
	add_child(root)
	_roots[a.id] = root
	_area_active[a.id] = true
	# ---- the plain rock: one body of grip, one of slick, one drawn mesh
	var grip := _static_body(1.0)
	var slick := _static_body(0.02)
	slick.set_meta("no_weld", true)
	root.add_child(grip)
	root.add_child(slick)
	var mb := PeakMesh.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(str(a.id))
	for s in a.get("solids", []):
		var kind := str(s.kind)
		var pts := _pts(s.pts)
		var hold = s.get("hold", meta.kinds[kind].get("hold"))
		var z0 := -HALF
		var z1 := HALF
		if s.has("z"):
			z0 = float(s.z[0])
			z1 = float(s.z[1])
		if kind == "void":
			_add_shapes(slick, pts, z0, z1)
			continue
		if hold != null or s.has("tag"):
			# A hold with a behaviour (or a tag): its own body and its own drawn piece.
			var sb := _static_body(1.0)
			root.add_child(sb)
			_add_shapes(sb, pts, z0, z1)
			var mi := MeshInstance3D.new()
			var one := PeakMesh.new()
			one.prism(pts, z0, z1, Vector2.ZERO, Vector2.ZERO)
			mi.mesh = one.commit()
			CelPass.paint(mi, kind_color(a, kind))
			sb.add_child(mi)
			if not kind_grips(kind):
				sb.set_meta("no_weld", true)
			if s.has("tag"):
				sb.set_meta("peak_tag", str(s.tag))
				zones.tag(str(s.tag), sb)
			if hold != null:
				things.add_hold(sb, hold, mi, kind_color(a, kind), tone(a, "slick"), a)
			continue
		var grips := kind_grips(kind)
		_add_shapes(grip if grips else slick, pts, z0, z1)
		var face := AtlasPalette.matte_uv(kind_color(a, kind))
		var edge := AtlasPalette.matte_uv(tone(a, "edge") if grips else kind_color(a, kind).darkened(0.35))
		mb.prism(pts, z0, z1, face, edge)
		if not grips:
			# Slick reads wet: a faint shine along its edges and a few pale drips.
			mb.rim(pts, z1 + 0.008, 0.09, AtlasPalette.matte_uv(kind_color(a, kind).lerp(tone(a, "drip"), 0.22)))
			_drips(mb, pts, z1, AtlasPalette.matte_uv(tone(a, "drip")), rng)
	if not mb.empty():
		var mi := MeshInstance3D.new()
		mi.mesh = mb.commit()
		mi.material_override = CelPass.one()
		mi.name = "Rock"
		root.add_child(mi)
	# ---- the painted cards behind and in front
	for c in a.get("cards", []):
		var pts := _pts(c.pts)
		if Geometry2D.triangulate_polygon(pts).is_empty():
			continue
		var cm := PeakMesh.new()
		var z := float(c.z)
		cm.prism(pts, z - 0.06, z, Vector2.ZERO, Vector2.ZERO)
		var mi := MeshInstance3D.new()
		mi.mesh = cm.commit()
		CelPass.paint(mi, tone(a, str(c.tone)))
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(mi)
	# ---- props
	for d in a.get("decos", []):
		var n := _deco(a, d)
		if n != null:
			root.add_child(n)
	for l in a.get("lights", []):
		var o := OmniLight3D.new()
		o.position = Vector3(float(l.at[0]), float(l.at[1]), float(l.at[2]))
		o.light_color = Color(str(l.color))
		o.omni_range = float(l.range)
		o.light_energy = float(l.energy)
		o.shadow_enabled = false
		o.visible = false
		root.add_child(o)
		_lights.append([o, float(l.energy), bool(l.get("flicker", false)), a.id, randf() * 10.0])
	things.build_area(a, root)
	zones.build_area(a, root)


func _pts(arr) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in arr:
		out.append(Vector2(float(p[0]), float(p[1])))
	return out


func _static_body(friction: float) -> StaticBody3D:
	var sb := StaticBody3D.new()
	sb.collision_layer = Climber.LAYER_WORLD
	sb.collision_mask = 0
	var pm := PhysicsMaterial.new()
	pm.friction = friction
	sb.physics_material_override = pm
	sb.set_meta("stage", true)
	return sb


## Collision for a polygon: convex pieces, extruded through the plane.
func _add_shapes(body: CollisionObject3D, pts: PackedVector2Array, z0: float, z1: float, at := Vector2.ZERO) -> void:
	var parts: Array = [pts] if _convex(pts) else Geometry2D.decompose_polygon_in_convex(pts)
	if parts.is_empty():
		var back := pts.duplicate()
		back.reverse()
		parts = Geometry2D.decompose_polygon_in_convex(back)
	if parts.is_empty():
		parts = [pts]
	for part: PackedVector2Array in parts:
		if part.size() < 3:
			continue
		var cv := ConvexPolygonShape3D.new()
		var p3 := PackedVector3Array()
		for p in part:
			p3.append(Vector3(p.x - at.x, p.y - at.y, z0))
			p3.append(Vector3(p.x - at.x, p.y - at.y, z1))
		cv.points = p3
		var col := CollisionShape3D.new()
		col.shape = cv
		body.add_child(col)


static func _convex(pts: PackedVector2Array) -> bool:
	var n := pts.size()
	var sign := 0.0
	for i in n:
		var c := (pts[(i + 1) % n] - pts[i]).cross(pts[(i + 2) % n] - pts[(i + 1) % n])
		if absf(c) < 0.000001:
			continue
		if sign == 0.0:
			sign = signf(c)
		elif signf(c) != sign:
			return false
	return true


## Wet look for slick rock: a few pale drip strokes on its face.
func _drips(mb: PeakMesh, pts: PackedVector2Array, z: float, uv: Vector2, rng: RandomNumberGenerator) -> void:
	var lo := pts[0]
	var hi := pts[0]
	for p in pts:
		lo = lo.min(p)
		hi = hi.max(p)
	var size := hi - lo
	var want := clampi(int(size.x * size.y / 14.0), 0, 10)
	var tries := 0
	while want > 0 and tries < 60:
		tries += 1
		var p := Vector2(rng.randf_range(lo.x, hi.x), rng.randf_range(lo.y, hi.y))
		var h := rng.randf_range(0.35, 1.1)
		if not Geometry2D.is_point_in_polygon(p, pts) or not Geometry2D.is_point_in_polygon(p - Vector2(0, h), pts):
			continue
		want -= 1
		var w := rng.randf_range(0.05, 0.09)
		mb.quad(Vector3(p.x - w, p.y - h, z + 0.012), Vector3(p.x + w, p.y - h, z + 0.012), Vector3(p.x + w, p.y, z + 0.012), Vector3(p.x - w, p.y, z + 0.012), Vector3(0, 0, 1), uv)


## A prop: the kit's model if it has landed, else a stand-in box in the area's tones.
func _deco(a: Dictionary, d: Dictionary) -> Node3D:
	var n := LuchaKit.kit_model(str(d.model))
	var at := Vector3(float(d.at[0]), float(d.at[1]), float(d.at[2]))
	if n == null:
		var size := Vector3(0.6, 0.6, 0.3)
		if d.has("size"):
			size = Vector3(float(d.size[0]), float(d.size[1]), float(d.size[2]))
		var c := tone(a, str(d.get("tone", "rock2")))
		n = _standin(str(d.model), size, c)
		n.set_meta("standin", true)
	n.position = at
	n.rotation.z = deg_to_rad(float(d.get("rot", 0.0)))
	var s := float(d.get("scale", 1.0))
	n.scale = Vector3(-s if bool(d.get("flip", false)) else s, s, s)
	n.name = str(d.model)
	return n


## Until a prop's model lands: the common ones drawn simply but as themselves, the rest
## as a flat cardboard cut-out in a quiet tone (never a loud box).
func _standin(model: String, size: Vector3, c: Color) -> Node3D:
	var n := Node3D.new()
	if model.begins_with("papel"):
		var torn := model.contains("tatter")
		var flags := LuchaKit.bunting(Vector3(-size.x * 0.5, size.y, 0), Vector3(size.x * 0.5, size.y, 0), int(size.x / (0.9 if torn else 0.6)), 0.35)
		if torn:
			var i := 0
			for f in flags.get_children():
				i += 1
				if i % 3 == 0:
					(f as Node3D).visible = false
		n.add_child(flags)
		return n
	if model.begins_with("lantern") or model.begins_with("torch"):
		var body := LuchaKit.box(Vector3(0.22, 0.3, 0.22), Color("#F2D27A"), Vector3(0, 0.25, 0))
		n.add_child(body)
		n.add_child(LuchaKit.box(Vector3(0.3, 0.07, 0.3), Color("#6A4A2A"), Vector3(0, 0.44, 0)))
		n.add_child(LuchaKit.box(Vector3(0.3, 0.08, 0.3), Color("#6A4A2A"), Vector3(0, 0.06, 0)))
		return n
	if model.begins_with("sign"):
		n.add_child(LuchaKit.box(Vector3(0.12, size.y, 0.1), Color("#8A6A45"), Vector3(0, size.y * 0.5, 0)))
		n.add_child(LuchaKit.box(Vector3(size.x, size.x * 0.7, 0.08), Color("#E9DCC0"), Vector3(0, size.y - size.x * 0.35, 0.06)))
		n.add_child(LuchaKit.box(Vector3(size.x * 0.4, size.x * 0.34, 0.03), Color("#3A2A20") if model.contains("skull") else Color("#D8262E"), Vector3(0, size.y - size.x * 0.35, 0.12)))
		return n
	var quiet := c.lerp(Color(0.5, 0.47, 0.43), 0.45)
	var card := LuchaKit.box(Vector3(size.x, size.y, minf(size.z, 0.12)), quiet, Vector3(0, size.y * 0.5, 0))
	card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.add_child(card)
	return n


# ================================================================ the run

## A climb begins (or picks up where it was left). Returns where the climber's feet go.
func begin() -> Vector2:
	active = true
	finished = false
	visible = true
	_falling = false
	_high_y = -INF
	audio.begin()
	var feet := v2(areas[0].entry) if not areas.is_empty() else Vector2.ZERO
	for a in areas:
		if str(a.id) == "a0":
			feet = v2(a.entry)
	return world_of(feet)


func leave() -> void:
	if not active:
		return
	save_now()
	active = false
	audio.end()
	player = null
	things.sleep_all()


## The climber is in the world: put it where it was saved, pose and all.
func on_player(c: Climber, fresh: bool) -> void:
	player = c
	things.on_player(c)
	_firm_pose = PackedFloat32Array()
	if not fresh and saved_pose.size() == c.pose().size():
		c.apply_pose(saved_pose)
		_firm_pose = saved_pose
	_high_y = player_at().y
	_tick_weights(0.0, true)


func tick(delta: float) -> void:
	if not active or meta.is_empty():
		return
	clock += delta
	if not is_instance_valid(player):
		player = null  # (a freed climber is not null by itself)
	var p := player_at()
	for a in areas:
		var on: bool = player == null or rect_has(a.region, p, ACTIVE_PAD) or str(a.id) == "st"
		if on != bool(_area_active[a.id]):
			_area_active[a.id] = on
			things.set_area_active(str(a.id), on)
			(_roots[a.id] as Node3D).visible = on
	things.tick(delta)
	zones.tick(delta)
	if player == null:
		return
	if not finished:
		time_s += delta
	_tick_fall(delta, p)
	_tick_softlock(delta)
	_save_t -= delta
	if _save_t <= 0.0:
		_save_t = SAVE_EVERY_S
		if player.touches_solid() and player.linear_speed() < 1.5 and not player.sinking:
			_firm_pose = player.pose()
			saved_pose = _firm_pose
			_save()
	if p.y > best_m:
		best_m = p.y
		if int(best_m / 100.0) > _milestone:
			_milestone = int(best_m / 100.0)
			milestone.emit(_milestone * 100)
			audio.play("new_best_chime", Vector2.INF, 2.0)


func frame(delta: float, cam: Camera3D) -> void:
	if not active:
		return
	_tick_weights(delta, false)
	audio.frame(delta, weights, _fall_speed(), _drop_under())
	things.frame(delta)
	zones.frame(delta, cam)
	if backdrop != null:
		backdrop.tick(delta, cam)
	# The lanterns near the climber burn; the rest are off.
	var p := player_at()
	for row in _lights:
		var o: OmniLight3D = row[0]
		var near := Vector2(o.position.x, o.position.y).distance_to(p) < 34.0
		o.visible = near
		if near and bool(row[2]):
			o.light_energy = float(row[1]) * (0.86 + 0.14 * sin(clock * 9.0 + float(row[4])) * sin(clock * 5.3 + float(row[4]) * 2.0))
	if player != null:
		var inside := inside_now()
		_lamp.position = Vector3(p.x, p.y + 0.6, 2.2)
		_lamp.light_energy = 1.1 * inside


func _fall_speed() -> float:
	if player == null or player.is_attached():
		return 0.0
	var chest: RigidBody3D = player.bodies.get("chest")
	return maxf(0.0, -chest.linear_velocity.y) if chest != null else 0.0


func _drop_under() -> float:
	return 0.0


# ---------------------------------------------------------------- falls, the softlock net, the bounds

func _tick_fall(_delta: float, p: Vector2) -> void:
	var holding := player.touches_solid()
	if holding or player.support_extra:
		if _falling:
			var drop := _high_y - p.y
			_falling = false
			if drop >= FALL_COUNT_M:
				falls += 1
				fell.emit(drop)
				audio.landed(drop)
		_high_y = p.y
		_yelled = false
	else:
		_high_y = maxf(_high_y, p.y)
		if _high_y - p.y > 3.0:
			_falling = true
		if _high_y - p.y > FALL_COUNT_M and not _yelled:
			_yelled = true
			Sound.play("fall", -4.0)


## A climber lying on slick with nothing to hold can't move at all (limbs only work
## while something grips). After a few still seconds it may scramble: a weak pull that
## drags it along the ground, never lifts it.
func _tick_softlock(delta: float) -> void:
	if zones.in_water(player):
		_still_t = 0.0
		return
	if player.touches_solid() or player.linear_speed() > 0.35:
		_still_t = 0.0
		if player.scramble and player.touches_solid():
			player.scramble = false
		return
	_still_t += delta
	if _still_t > 3.5 and not player.scramble:
		player.scramble = true


## Outside the world (a bug, never a design): back to the last firm hold.
func out_of_world(world_p: Vector2) -> bool:
	var p := local_of(world_p)
	return p.y < -60.0 or p.y > 1060.0 or p.x < -480.0 or p.x > 30.0


func rescue() -> void:
	if player == null:
		return
	if _firm_pose.size() == player.pose().size():
		player.release_all()
		player.apply_pose(_firm_pose)
		for b: RigidBody3D in player.bodies.values():
			b.linear_velocity = Vector3.ZERO
			b.angular_velocity = Vector3.ZERO


# ---------------------------------------------------------------- where am I: areas, looks, the camera

func _tick_weights(delta: float, snap: bool) -> void:
	var p := player_at()
	var raw := {}
	var total := 0.0
	var best := ""
	var best_w := 0.0
	for a in areas:
		if str(a.id) == "st":
			continue
		var r: Array = a.region
		var dx := maxf(maxf(float(r[0]) - p.x, p.x - float(r[2])), 0.0)
		var dy := maxf(maxf(float(r[1]) - p.y, p.y - float(r[3])), 0.0)
		var w := clampf(1.0 - Vector2(dx, dy).length() / BLEND_M, 0.0, 1.0)
		if w > 0.0:
			raw[a.id] = w
			total += w
			if w > best_w or (w == best_w and best == ""):
				best_w = w
				best = str(a.id)
	if total <= 0.0:
		# Between areas (a long fall down the well or the throat): the nearest by height.
		var near := ""
		var near_d := INF
		for a in areas:
			if str(a.id) == "st":
				continue
			var r: Array = a.region
			var d := absf(clampf(p.y, float(r[1]), float(r[3])) - p.y) + absf(clampf(p.x, float(r[0]), float(r[2])) - p.x) * 0.3
			if d < near_d:
				near_d = d
				near = str(a.id)
		raw[near] = 1.0
		total = 1.0
		best = near
	var k := 1.0 if snap else 1.0 - exp(-delta * 1.6)
	for a in areas:
		var id := str(a.id)
		if id == "st":
			continue
		var want: float = float(raw.get(id, 0.0)) / total
		weights[id] = lerpf(float(weights.get(id, 0.0)), want, k)
	# The area you're in is the one whose region holds you (a deeper one wins a tie).
	var inside_id := ""
	for a in areas:
		if str(a.id) != "st" and rect_has(a.region, p):
			inside_id = str(a.id)
	if inside_id == "":
		inside_id = best
	if inside_id != area_now and inside_id != "":
		area_now = inside_id
		if not snap:
			var n := 0
			for i in areas.size():
				if str(areas[i].id) == inside_id:
					area_entered.emit(inside_id, str(areas[i].name), int(inside_id.substr(1)))
					n = i


## The look right now: {sky, amb, sun, inside}, blended by the areas you're in or near.
func look() -> Dictionary:
	var sky := Color(0, 0, 0)
	var amb := Color(0, 0, 0)
	var sun := 0.0
	var inside := 0.0
	var total := 0.0
	for a in areas:
		var w: float = float(weights.get(str(a.id), 0.0))
		if w <= 0.0005:
			continue
		var pal: Dictionary = palette_of(a)
		sky += Color(str(pal.sky)) * w
		amb += Color(str(pal.amb)) * w
		sun += float(pal.sun) * w
		inside += float(pal.inside) * w
		total += w
	if total <= 0.0:
		return {"sky": Color("#8FD0FF"), "amb": Color(0.85, 0.85, 0.85), "sun": 1.25, "inside": 0.0}
	var dark: float = zones.darkness(player_at())
	var flash: float = zones.flash
	var out := {"sky": sky / total, "amb": amb / total, "sun": sun / total, "inside": maxf(inside / total, dark)}
	out.sun = lerpf(float(out.sun), 0.12, dark) + flash * 2.5
	out.amb = (out.amb as Color).lerp(Color(0.05, 0.05, 0.07), dark * 0.8) + Color(1, 1, 1) * flash * 0.6
	out.sky = (out.sky as Color).lerp(Color(0.02, 0.02, 0.03), dark * 0.9) + Color(1, 1, 1) * flash * 0.5
	return out


func inside_now() -> float:
	var inside := 0.0
	var total := 0.0
	for a in areas:
		var w: float = float(weights.get(str(a.id), 0.0))
		inside += float(palette_of(a).inside) * w
		total += w
	return maxf(inside / maxf(total, 0.001), zones.darkness(player_at()))


## The camera's frame at the climber: [half height, bias].
func cam_frame() -> Array:
	var p := player_at()
	var half := 4.2
	var bias := Vector2.ZERO
	var best_area := INF
	for a in areas:
		if not rect_has(a.region, p, 30.0):
			continue
		for c in a.get("cams", []):
			var r: Array = c.rect
			if rect_has(r, p):
				var size := (float(r[2]) - float(r[0])) * (float(r[3]) - float(r[1]))
				if size < best_area:  # the smallest zone you're in wins
					best_area = size
					half = float(c.half_h)
					bias = v2(c.bias)
	return [half, bias]


# ---------------------------------------------------------------- the ending

func finish() -> void:
	if finished:
		return
	finished = true
	summits += 1
	if best_time_s <= 0.0 or time_s < best_time_s:
		best_time_s = time_s
	audio.finale()
	summit.emit(time_s, falls, best_time_s)
	_save()


## Start the whole climb again from the trailhead (after a summit, or by choice).
func reset_run() -> void:
	saved_pose = PackedFloat32Array()
	_firm_pose = PackedFloat32Array()
	time_s = 0.0
	falls = 0
	finished = false
	_save()


# ---------------------------------------------------------------- the warp keys (dev)

## Put the climber at a challenge's start. id "" steps by `step`.
func warp(id: String, step := 0) -> String:
	if challenges.is_empty() or player == null:
		return ""
	if id != "":
		for i in challenges.size():
			if str(challenges[i].id) == id:
				_warp_i = i
	else:
		_warp_i = posmod(_warp_i + step, challenges.size())
	var c: Dictionary = challenges[_warp_i]
	var feet := world_of(v2(c.anchor)) + Vector2(0, 0.05)
	player.release_all()
	var p := player.pose()
	var com := player.centre_of_mass()
	var low := INF
	for b: RigidBody3D in player.bodies.values():
		low = minf(low, b.global_position.y)
	var shift := Vector2(feet.x - com.x, feet.y - low + 0.12)
	for k in range(0, p.size(), 3):
		p[k] += shift.x
		p[k + 1] += shift.y
	player.apply_pose(p)
	for b: RigidBody3D in player.bodies.values():
		b.linear_velocity = Vector3.ZERO
		b.angular_velocity = Vector3.ZERO
	_high_y = player_at().y
	_falling = false
	return "%s %s" % [c.id, c.name]


# ---------------------------------------------------------------- save

func save_now() -> void:
	if player != null and is_instance_valid(player) and player.touches_solid():
		saved_pose = player.pose()
	_save()


func _save() -> void:
	if dev_warp:
		return  # a warped run never overwrites the real climb
	var cf := ConfigFile.new()
	cf.set_value("peak", "pose", saved_pose)
	cf.set_value("peak", "clock", clock)
	cf.set_value("peak", "time", time_s)
	cf.set_value("peak", "falls", falls)
	cf.set_value("peak", "best_m", best_m)
	cf.set_value("peak", "summits", summits)
	cf.set_value("peak", "best_time", best_time_s)
	cf.save(SAVE_PATH)


func _load() -> void:
	var cf := ConfigFile.new()
	if cf.load(SAVE_PATH) != OK:
		return
	saved_pose = cf.get_value("peak", "pose", PackedFloat32Array())
	clock = float(cf.get_value("peak", "clock", 0.0))
	time_s = float(cf.get_value("peak", "time", 0.0))
	falls = int(cf.get_value("peak", "falls", 0))
	best_m = float(cf.get_value("peak", "best_m", 0.0))
	summits = int(cf.get_value("peak", "summits", 0))
	best_time_s = float(cf.get_value("peak", "best_time", 0.0))
	_milestone = int(best_m / 100.0)


static func has_save() -> bool:
	var cf := ConfigFile.new()
	if cf.load(SAVE_PATH) != OK:
		return false
	return (cf.get_value("peak", "pose", PackedFloat32Array()) as PackedFloat32Array).size() > 0


static func summited() -> bool:
	var cf := ConfigFile.new()
	return cf.load(SAVE_PATH) == OK and int(cf.get_value("peak", "summits", 0)) > 0
