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
## SLICK IS WET MUD (Parker 11-12: "the slick surfaces should be a muddy dark brown and
## metallic max shiney to indicate they are wet"): one colour for everything that can't be
## held, in every area, with the house shader's polished glint and rim.
const SLICK := Color("#3A2616")
const STRETCH := ["hanger_chain", "counterweight_chain", "balloon_tether"]
const FACET := 0.3  # how far a rock face's facets stand out of its body
## ICE AND CRYSTAL ARE EXEMPT (Parker 11-12: "ice and crystal should be exempt"): slick
## glass is dark indigo glass and black ice is blue-black ice, each as glossy as the mud.
## Three kinds of slick, then: "mud" (everything else), "glass", "ice".
const SLICK_GLASS := Color("#160C3E")
const SLICK_ICE := Color("#0C2440")
const SLICK_LOOKS := {
	# colour, the sheen in the sun, the lit rim, the painted edge band, the drips ("" = none),
	# the sheen inside the mountain
	"mud": [SLICK, Color(0.42, 0.31, 0.2, 0.5), Color(0.95, 0.8, 0.6, 0.5), "#8A5E34", "#A87A48", Color(0.78, 0.63, 0.46, 0.5)],
	"glass": [SLICK_GLASS, Color(0.34, 0.27, 0.62, 0.5), Color(0.85, 0.78, 1.0, 0.5), "#6A52C8", "", Color(0.58, 0.48, 0.98, 0.5)],
	"ice": [SLICK_ICE, Color(0.27, 0.45, 0.62, 0.5), Color(0.78, 0.93, 1.0, 0.5), "#4E8FC4", "#8FC8E8", Color(0.48, 0.75, 0.98, 0.5)],
}
static var _slick_mats := {}
## SHINY IN THE CAVES, SOFT IN THE SUN (Parker 11-12, of "metallic max shiney"): inside the
## mountain slick wears its full sheen; out on the cliffs and the ridge, where the same
## sheen went white in full sun, a soft one. Set for each area as it is built; a change
## made later (a hold going wet) sets it from the hold's own area first.
static var shiny := true
var _shiny_of := {}  # area id -> is its slick the shiny kind


static func slick_class(kind: String) -> String:
	if kind in ["glass", "crystal"]:
		return "glass"
	if kind in ["blackice", "ice", "snow", "snowbridge"]:
		return "ice"
	return "mud"


## `cls` may end in "+" or "-": a lighter or a darker shade of the same wet stuff (a slick
## rock face's facets).
static func slick_material(cls := "mud") -> ShaderMaterial:
	var key := cls + ("!" if shiny else "")
	if not _slick_mats.has(key):
		var shade := 1.0
		var base := cls
		if cls.ends_with("+"):
			shade = 1.6
			base = cls.left(-1)
		elif cls.ends_with("-"):
			shade = 0.62
			base = cls.left(-1)
		var look: Array = SLICK_LOOKS[base]
		var m := ShaderMaterial.new()
		m.shader = CelPass.SHADER
		var col: Color = look[0]
		m.set_shader_parameter("color", Color(minf(col.r * shade, 1.0), minf(col.g * shade, 1.0), minf(col.b * shade, 1.0)))
		# A broad sheen where light falls, not white (in this shader a broad bright band
		# whited out every flat face), and a lit rim on the edges.
		m.set_shader_parameter("specular", look[5] if shiny else look[1])
		m.set_shader_parameter("fresnel", look[2])
		m.resource_name = "SLICK_" + key
		_slick_mats[key] = m
	return _slick_mats[key]


## Before a slick look is asked for outside an area's building: whose area is it?
func shine_for(area_id: String) -> void:
	shiny = bool(_shiny_of.get(area_id, true))


## A KIT MODEL FOR THE PEAK, ITS SLICK PARTS WET. The makers paint what can't be held in
## the one slick brown, from the atlas's polished rows; the one atlas material draws those
## rows with a glint so broad a flat face goes white. So the faces painted that brown are
## cut out into a surface of their own and drawn with slick_material(): a model's slick
## part and a slick wall of the course are the same stuff, to the eye. Done once a mesh.
static var _wet_meshes := {}  # the model's Mesh -> {mesh, from: [the old surface of each new one], wet: [its slick kind, or ""]}
static var _wet_texels := {}  # atlas texel -> 0, or 1 + the index of its slick kind in WET_KINDS
const WET_KINDS := ["mud", "glass", "ice"]
static var _wet_atlas: Image


## Crystal and ice pieces the makers painted in the mud brown (the day slick was one colour
## everywhere): their slick is glass or ice, whatever colour the file carries.
const WET_AS := {"geode_wheel": "glass", "crystal_ring_3": "glass", "crystal_ring_4": "glass", "crystal_ring_4x": "glass",
	"quartz_pendulum": "glass", "crystal_raft": "glass", "crystal_column": "glass", "serac": "ice"}


static func kit(model: String) -> Node3D:
	var n := LuchaKit.kit_model(model)
	if n != null:
		var mud_as := str(WET_AS.get(model, "mud"))
		if n is MeshInstance3D:
			_wet(n as MeshInstance3D, mud_as)
		for mi in n.find_children("*", "MeshInstance3D", true, false):
			_wet(mi as MeshInstance3D, mud_as)
	return n


static func _wet(mi: MeshInstance3D, mud_as := "mud") -> void:
	var src := mi.mesh as ArrayMesh
	if src == null or src.get_blend_shape_count() > 0 or mi.skin != null:
		return
	if not _wet_meshes.has(src):
		_wet_meshes[src] = _wet_cut(src)
	var cut: Dictionary = _wet_meshes[src]
	if cut.is_empty():
		return
	var over: Array = []
	for i in src.get_surface_count():
		over.append(mi.get_surface_override_material(i))
	mi.mesh = cut.mesh
	for i in (cut.from as Array).size():
		var cls := str(cut.wet[i])
		if cls == "mud":
			cls = mud_as
		mi.set_surface_override_material(i, slick_material(cls) if cls != "" else over[int(cut.from[i])])


## The mesh with its slick-brown faces in surfaces of their own; {} when it has none.
static func _wet_cut(src: ArrayMesh) -> Dictionary:
	if _wet_atlas == null:
		_wet_atlas = CelPass.ATLAS.get_image()
		if _wet_atlas.is_compressed():
			_wet_atlas.decompress()
	var w := _wet_atlas.get_width()
	var h := _wet_atlas.get_height()
	var out := ArrayMesh.new()
	var from: Array = []
	var wet: Array = []
	var any := false
	for si in src.get_surface_count():
		var arrays := src.surface_get_arrays(si)
		var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV] if arrays[Mesh.ARRAY_TEX_UV] != null else PackedVector2Array()
		var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
		var parts: Array = [PackedInt32Array(), PackedInt32Array(), PackedInt32Array(), PackedInt32Array()]  # dry, then each of WET_KINDS
		var wet_n := 0
		if src.surface_get_primitive_type(si) == Mesh.PRIMITIVE_TRIANGLES and not uvs.is_empty():
			if idx.is_empty():
				idx.resize(uvs.size())
				for i in uvs.size():
					idx[i] = i
			var flag := PackedByteArray()
			flag.resize(uvs.size())
			for i in uvs.size():
				var px := Vector2i(clampi(int(uvs[i].x * w), 0, w - 1), clampi(int(uvs[i].y * h), 0, h - 1))
				if not _wet_texels.has(px):
					var c := _wet_atlas.get_pixelv(px)
					var which := 0
					if px.y >= AtlasPalette.MATTE_ROWS:
						for k in WET_KINDS.size():
							var want: Color = SLICK_LOOKS[WET_KINDS[k]][0]
							if Vector3(c.r - want.r, c.g - want.g, c.b - want.b).length() < 0.05:
								which = k + 1
								break
					_wet_texels[px] = which
				flag[i] = int(_wet_texels[px])
			for t in range(0, idx.size() - 2, 3):
				var f := flag[idx[t]]
				var to: int = f if (f == flag[idx[t + 1]] and f == flag[idx[t + 2]]) else 0
				var list: PackedInt32Array = parts[to]
				list.append(idx[t])
				list.append(idx[t + 1])
				list.append(idx[t + 2])
				parts[to] = list
				if to > 0:
					wet_n += 1
		if wet_n == 0:
			out.add_surface_from_arrays(src.surface_get_primitive_type(si), arrays)
			out.surface_set_material(out.get_surface_count() - 1, src.surface_get_material(si))
			from.append(si)
			wet.append("")
			continue
		any = true
		for k in parts.size():
			var part: PackedInt32Array = parts[k]
			if part.is_empty():
				continue
			var a2 := arrays.duplicate()
			a2[Mesh.ARRAY_INDEX] = part
			out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, a2)
			var cls: String = "" if k == 0 else str(WET_KINDS[k - 1])
			out.surface_set_material(out.get_surface_count() - 1, slick_material(cls) if cls != "" else src.surface_get_material(si))
			from.append(si)
			wet.append(cls)
	return {"mesh": out, "from": from, "wet": wet} if any else {}


var fit_placed := 0  # solids wearing the fitted kit, and the tiles they took (the batteries read these)
var fit_tiles := 0
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
	shiny = float(palette_of(a).get("inside", 1.0)) >= 0.5
	_shiny_of[str(a.id)] = shiny
	# ---- the plain rock: one body of grip, one of slick, one drawn mesh
	var grip := _static_body(1.0)
	var slick := _static_body(0.02)
	slick.set_meta("no_weld", true)
	root.add_child(grip)
	root.add_child(slick)
	var mb := PeakMesh.new()
	var ms := {}  # the slick rock, a mesh for each kind of slick: "mud" / "glass" / "ice" -> PeakMesh
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(str(a.id))
	# THE FITTED KIT: a box wears the kit's modules where they have landed (peak_fit.gd).
	var fit := PeakFit.new(self, a, root)
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
		# SLIM BARS (Parker 11-12: ladders were "big chunky squares"): a rung, a peg or a
		# small nub is drawn slim through the plane, a bar and not a shelf 2.4 m deep. Its
		# collision keeps the full depth.
		var vz0 := z0
		var vz1 := z1
		if not s.has("z"):
			var lo := pts[0]
			var hi := pts[0]
			for p in pts:
				lo = lo.min(p)
				hi = hi.max(p)
			var size := hi - lo
			if minf(size.x, size.y) <= 0.3 and maxf(size.x, size.y) <= 1.5:
				vz0 = -0.2
				vz1 = 0.2
			elif maxf(size.x, size.y) <= 0.75:
				vz0 = -0.3
				vz1 = 0.3
			elif bool(s.get("ghost", false)):
				vz0 = -0.26
				vz1 = -0.14  # (a ladder's rails stand just behind the rungs)
		# A SKIN: once its model has landed, the model is this solid's look (the deco that
		# places it has skin = true) and the solid is only its collision.
		var skinned: bool = s.has("skin") and LuchaKit.kit_model_exists(str(s.skin))
		if bool(s.get("ghost", false)):
			# Drawn only: nothing touches it.
			if not skinned and not fit.place(s, pts, kind, vz0, vz1):
				mb.prism(pts, vz0, vz1, AtlasPalette.matte_uv(kind_color(a, kind).darkened(0.12)), AtlasPalette.matte_uv(tone(a, "edge")))
			continue
		if hold != null or s.has("tag"):
			# A hold with a behaviour (or a tag): its own body and its own drawn piece.
			var sb := _static_body(1.0)
			root.add_child(sb)
			_add_shapes(sb, pts, z0, z1)
			var piece: Node3D = fit.single(s, pts, kind, vz0, vz1)
			var mi: MeshInstance3D = null
			if piece == null:
				mi = MeshInstance3D.new()
				var one := PeakMesh.new()
				one.prism(pts, vz0, vz1, Vector2.ZERO, Vector2.ZERO)
				mi.mesh = one.commit()
				CelPass.paint(mi, kind_color(a, kind))
				piece = mi
			sb.add_child(piece)
			sb.set_meta("peak_pts", pts)
			sb.set_meta("peak_z", Vector2(vz0, vz1))
			sb.set_meta("slick_class", slick_class(kind))  # (what it looks like when it turns slick)
			if not kind_grips(kind):
				sb.set_meta("no_weld", true)
				if mi != null:
					mi.material_override = slick_material(slick_class(kind))
			if s.has("tag"):
				sb.set_meta("peak_tag", str(s.tag))
				zones.tag(str(s.tag), sb)
			if hold != null:
				things.add_hold(sb, hold, piece, kind_color(a, kind), tone(a, "slick"), a)
			continue
		var grips := kind_grips(kind)
		_add_shapes(grip if grips else slick, pts, z0, z1)
		if skinned or fit.place(s, pts, kind, vz0, vz1):
			continue
		# A ROCK FACE: a big piece of rock, ice or crystal that no module fits (a slope, a
		# wedge, the mountain's own masses) is cut into facets, and wears the kit's ground
		# along its open top edges once that has landed.
		var rocky := false
		if str(PeakFit.MATERIAL.get(kind, "")) in ["rock", "ice", "crystal"] and not s.has("z"):
			var blo := pts[0]
			var bhi := pts[0]
			for p in pts:
				blo = blo.min(p)
				bhi = bhi.max(p)
			rocky = minf(bhi.x - blo.x, bhi.y - blo.y) >= 1.2
		var front := vz1 - (FACET if rocky else 0.0)
		if rocky and fit.buried(pts):
			# A core set inside a bigger mass (grip rock in a slick wall: only its top is
			# grip). The mass's face is the face; this one stands back behind it.
			rocky = false
			front = vz1 - FACET - 0.02
			fit.top_caps(pts, kind, vz0, vz1)
		if rocky:
			fit.top_caps(pts, kind, vz0, vz1)
		if not grips:
			var cls := slick_class(kind)
			if not ms.has(cls):
				ms[cls] = PeakMesh.new()
			(ms[cls] as PeakMesh).prism(pts, vz0, front, Vector2.ZERO, Vector2.ZERO)
			if rocky:
				for shade in ["+", "-"]:
					if not ms.has(cls + shade):
						ms[cls + shade] = PeakMesh.new()
				(ms[cls] as PeakMesh).facets(pts, front, vz1, [], [ms[cls + "+"], ms[cls], ms[cls + "-"]])
			# Painted wet: a paler band along its edges and runs of drips.
			var look: Array = SLICK_LOOKS[cls]
			mb.rim(pts, front + 0.006, 0.09, AtlasPalette.matte_uv(Color(str(look[3]))))
			if str(look[4]) != "" and not rocky:
				_drips(mb, pts, vz1, AtlasPalette.matte_uv(Color(str(look[4]))), rng)
			continue
		var face_c: Color = kind_color(a, kind)
		mb.prism(pts, vz0, front, AtlasPalette.matte_uv(face_c), AtlasPalette.matte_uv(tone(a, "edge")))
		if rocky:
			mb.facets(pts, front, vz1, [AtlasPalette.matte_uv(face_c.lightened(0.1)), AtlasPalette.matte_uv(face_c), AtlasPalette.matte_uv(face_c.darkened(0.12))], [], 0.04)
		else:
			PeakDress.dress(mb, pts, vz1 + 0.007, kind, face_c, rng)
	fit.commit()
	fit_placed += fit.placed
	fit_tiles += fit.tiles
	if not mb.empty():
		var mi := MeshInstance3D.new()
		mi.mesh = mb.commit()
		mi.material_override = CelPass.one()
		mi.name = "Rock"
		root.add_child(mi)
	for cls: String in ms:
		if (ms[cls] as PeakMesh).empty():
			continue
		var mi := MeshInstance3D.new()
		mi.mesh = (ms[cls] as PeakMesh).commit()
		mi.material_override = slick_material(cls)
		mi.name = "Slick_" + cls
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


## The bright points of light on wet mud: short slanted dashes, sparse.
func _glints(mb: PeakMesh, pts: PackedVector2Array, z: float, uv: Vector2, rng: RandomNumberGenerator) -> void:
	var lo := pts[0]
	var hi := pts[0]
	for p in pts:
		lo = lo.min(p)
		hi = hi.max(p)
	var size := hi - lo
	var want := clampi(int(size.x * size.y / 9.0), 0, 14)
	var tries := 0
	while want > 0 and tries < 80:
		tries += 1
		var p := Vector2(rng.randf_range(lo.x, hi.x), rng.randf_range(lo.y, hi.y))
		var q := p + Vector2(0.22, 0.16) * rng.randf_range(0.7, 1.5)
		if not Geometry2D.is_point_in_polygon(p, pts) or not Geometry2D.is_point_in_polygon(q, pts):
			continue
		want -= 1
		var n := (q - p).normalized().orthogonal() * 0.022
		mb.quad(Vector3(p.x - n.x, p.y - n.y, z + 0.014), Vector3(q.x - n.x, q.y - n.y, z + 0.014), Vector3(q.x + n.x, q.y + n.y, z + 0.014), Vector3(p.x + n.x, p.y + n.y, z + 0.014), Vector3(0, 0, 1), uv)


## A prop: the kit's model if it has landed, else a stand-in box in the area's tones.
## Lines of flags are units that TILE end to end (their cords meet); they are never stretched.
const LINE_UNITS := {"papel_string": 8.0, "papel_tatters": 8.0, "papel_line": 8.0, "pennant_line": 6.0, "marigold_garland": 4.0}


func _deco(a: Dictionary, d: Dictionary) -> Node3D:
	var model := str(d.model)
	if model == "temple_banner" and d.has("size") and float(d.size[1]) > 8.0:
		model = "temple_banner_long"
	var n := kit(model)
	var at := Vector3(float(d.at[0]), float(d.at[1]), float(d.at[2]))
	if n == null and bool(d.get("skin", false)):
		return null  # (a skin not landed yet: its solids are drawn instead)
	if n != null and LINE_UNITS.has(model) and d.has("size"):
		var unit := float(LINE_UNITS[model])
		var span := float(d.size[0])
		var count := maxi(1, int(round(span / unit)))
		var row := Node3D.new()
		for i in count:
			var piece: Node3D = n if i == 0 else kit(model)
			piece.position.x = -span * 0.5 + (float(i) + 0.5) * span / count
			piece.scale.x = span / (count * unit)
			row.add_child(piece)
		row.position = at
		row.rotation.z = deg_to_rad(float(d.get("rot", 0.0)))
		var ls := float(d.get("scale", 1.0))
		row.scale = Vector3(ls, ls, ls)
		row.name = model
		return row
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
	# A landed model far from the size the author drew for (a mask asked for at 21 m,
	# modelled at 10) is scaled to it; within a quarter either way it is left as made.
	if not n.has_meta("standin") and d.has("size") and not bool(d.get("skin", false)):
		var box := _model_box(n)
		var want := Vector2(float(d.size[0]), float(d.size[1]))
		if box.size.x > 0.05 and box.size.y > 0.05:
			var wide := want.x > want.y * 2.0
			var ratio := (want.x / box.size.x) if wide else (want.y / box.size.y)
			if ratio > 1.3 or ratio < 0.75:
				s *= ratio
	n.scale = Vector3(-s if bool(d.get("flip", false)) else s, s, s)
	# A chain or a tether runs exactly from one end of its span to the other: stretched
	# along its length alone (one model, many spans).
	if model in STRETCH and not n.has_meta("standin") and d.has("size"):
		var tall := _model_box(n).size.y
		if tall > 0.05:
			n.scale.y = float(d.size[1]) / tall
	n.name = str(d.model)
	if model.contains("torch") and not n.has_meta("standin"):
		_light_torch(n)
	return n


## A TORCH BURNS with Golemheim's 3D metaball fire (Parker 11-12: "for torches and fires,
## we can use the 3d metaball fire we use in golemheim"): the flame alone, sized to the
## torch's head. The course's own light is the torch's glow, so the fire's is off.
const FIRE := preload("res://scenes/effects/flame_metaball_3d.tscn")


func _light_torch(torch: Node3D) -> void:
	var box := _model_box(torch)
	for old in torch.find_children("*lame*", "MeshInstance3D", true, false):
		(old as Node3D).visible = false  # (a modelled flame steps aside for the real one)
	var fire: Node3D = FIRE.instantiate()
	fire.set("light_energy", 0.0)
	fire.set("flicker", 0.0)
	var wide := clampf(maxf(box.size.x, box.size.z), 0.25, 1.2)
	fire.scale = Vector3.ONE * (wide / 2.8) * 2.8
	fire.position = Vector3(box.get_center().x, box.end.y - box.size.y * 0.42, box.get_center().z)  # (over the modelled flame)
	torch.add_child(fire)
	var glow := fire.get_node_or_null("Glow") as OmniLight3D
	if glow != null:
		glow.visible = false


static func _model_box(root: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.mesh == null:
			continue
		var xf := Transform3D()
		var node: Node = m
		while node != null and node != root:
			xf = (node as Node3D).transform * xf
			node = node.get_parent()
		var b := xf * m.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


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
	if not is_instance_valid(player) or player.removed:
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
	out.sun = lerpf(float(out.sun), 0.12, dark) + flash * 0.9  # (a flash lights the scene: it must not white it out)
	out.amb = (out.amb as Color).lerp(Color(0.05, 0.05, 0.07), dark * 0.8) + Color(1, 1, 1) * flash * 0.25
	out.sky = (out.sky as Color).lerp(Color(0.02, 0.02, 0.03), dark * 0.9) + Color(1, 1, 1) * flash * 0.3
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
