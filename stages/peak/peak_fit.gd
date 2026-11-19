class_name PeakFit
extends RefCounted
## THE FITTED KIT (Parker 11-12: "see how these things are still just cuboids? They need
## to be some kind of model ... The ground needs to look like a ground and the walls should
## look like walls ... as actual stuff instead of just decorated blockouts").
##
## The course is plain boxes of a kind. This dresses each box in MODULES from the kit,
## by its kind and its shape, repeated and scaled to fit: `cap` (a ledge, a deck, the top
## of a floor), `panel` (a wall, a floor's body), `pole` (a post, a pillar), `bar` (a peg,
## a rung, a rail), `hold` (a knob). The files are kit/models/fit_<material>_<module>.glb,
## with _a/_b/_c variants; the page is docs/peak/FITTED_KIT.md. A module that has not
## landed leaves its boxes drawn the old way. The collision is never touched.
##
## Drawn as instances: one MultiMesh for each module, wetness and tint in an area.

## The kind of a solid -> the kit's material.
const MATERIAL := {
	"wood": "wood", "plank": "wood", "rotten": "rotten",
	"rock": "rock", "rock2": "rock", "wet": "rock", "mud": "rock", "scree": "rock", "slime": "rock", "slag": "rock",
	"brick": "brick", "stone": "stone", "brittle": "stone",
	"iron": "iron", "metal": "iron", "paint": "iron", "grease": "iron",
	"crystal": "crystal", "glass": "crystal",
	"snow": "snow", "snowbridge": "snow", "ice": "ice", "blackice": "ice", "icicle": "ice",
	"bone": "bone", "root": "root", "gill": "gill", "cap": "shroom",
	"hot": "hot", "hotpipe": "hotpipe", "gold": "gold",
}
## Painted neutral by the makers and multiplied by the area's own colour.
const TINTED := ["rock", "stone", "brick", "snow", "ice", "crystal"]
const NEUTRAL := 0.9  # the makers' base grey (#E6E6E6): a tint is the wanted colour over this
## A module's nominal box in the play plane (x, y), and its depth.
const NOMINAL := {
	"cap": Vector3(2.0, 0.5, 2.4), "cap_end": Vector3(0.5, 0.5, 2.4), "panel": Vector3(2.0, 2.0, 2.4),
	"pole": Vector3(0.4, 2.5, 0.4), "bar": Vector3(1.0, 0.12, 0.12), "hold": Vector3(0.5, 0.5, 0.6),
}

## The pieces a course names itself (`fit=`): the box each is made to, in the play plane
## (the ladder's rung is its bar: the arms and feet stand outside it). One not listed
## here is fitted by its mesh's own box.
const NAMED := {"fit_ladder_rung": Vector2(0.94, 0.09), "fit_ladder_rail": Vector2(0.11, 2.0)}

static var _meshes := {}  # file name -> Mesh (null: not landed)
static var _variants := {}  # "fit_wood_cap" -> [file names that exist]
static var _boxes := {}  # file name -> its mesh's box (the pieces fitted by their own size)
static var test_mode := OS.has_environment("PEAK_FIT_TEST")  # dev: plain stand-ins for modules not landed

var peak: Peak
var area: Dictionary
var root: Node3D
var placed := 0  # solids dressed
var tiles := 0
var _others: Array = []  # [Rect2, PackedVector2Array] of every solid in the area
var _batches := {}  # key -> {mesh, xf: Array[Transform3D], wet: String, tint: Color, tinted: bool}
var _cut := {}  # "wet|tint" -> {v, n, uv, wet, tint, tinted}: panels cut to a mass's outline, one mesh
static var _arrays := {}  # file name -> [[verts, normals, uvs, indices], ...] (a module's surfaces, to cut)
var _n := 0


func _init(p_peak: Peak, a: Dictionary, p_root: Node3D) -> void:
	peak = p_peak
	area = a
	root = p_root
	for s in a.get("solids", []):
		if bool(s.get("ghost", false)) or str(s.kind) == "void":
			continue
		var pts: PackedVector2Array = peak._pts(s.pts)
		var box := Rect2(pts[0], Vector2.ZERO)
		for q in pts:
			box = box.expand(q)
		_others.append([box, pts])


## Dress a plain solid: its tiles join the area's batches. False: no module for it (draw
## it the old way).
func place(s: Dictionary, pts: PackedVector2Array, kind: String, z0: float, z1: float) -> bool:
	var plan := _plan(s, pts, kind, z0, z1)
	if plan.is_empty():
		return false
	var wet := "" if peak.kind_grips(kind) else Peak.slick_class(kind)
	var mat := str(MATERIAL.get(kind, ""))
	var tinted := mat in TINTED and wet == ""
	var tint := _tint(kind) if tinted else Color.WHITE
	for t: Array in plan:
		var baked := str(t[0]).contains(BAKED_TAG)  # (an area's own painted variant: drawn in its own colours)
		var t_tint := Color.WHITE if baked else tint
		var key := "%s|%s|%s" % [t[0], wet, t_tint.to_html(false)]
		if not _batches.has(key):
			_batches[key] = {"mesh": _mesh(str(t[0])), "xf": [], "wet": wet, "tint": t_tint, "tinted": tinted and not baked, "name": str(t[0])}
		(_batches[key].xf as Array).append(t[1])
	placed += 1
	tiles += plan.size()
	return true


## The kit's ground along the open top edges of a piece no module fits (a slope, a
## wedge, one of the mountain's masses): caps laid along each edge a climber could stand
## on, where the air above it is open. The piece's own body is drawn by the caller.
func top_caps(pts: PackedVector2Array, kind: String, z0: float, z1: float) -> void:
	var mat := str(MATERIAL.get(kind, ""))
	if mat == "" or _pick("fit_%s_cap" % mat) == "":
		return
	var out: Array = []
	for e: Array in _cap_edges(pts):
		var mid: Vector2 = e[0]
		var dir: Vector2 = e[1]
		var up: Vector2 = e[2]
		_caps(out, mat, mid - up * 0.25, dir, up, dir.angle(), float(e[3]), 0.5, (z0 + z1) * 0.5, (z1 - z0) / 2.4, false)
	if out.is_empty():
		return
	var wet := "" if peak.kind_grips(kind) else Peak.slick_class(kind)
	var tinted := mat in TINTED and wet == ""
	var tint := _tint(kind) if tinted else Color.WHITE
	for t: Array in out:
		var baked := str(t[0]).contains(BAKED_TAG)  # (an area's own painted variant: drawn in its own colours)
		var t_tint := Color.WHITE if baked else tint
		var key := "%s|%s|%s" % [t[0], wet, t_tint.to_html(false)]
		if not _batches.has(key):
			_batches[key] = {"mesh": _mesh(str(t[0])), "xf": [], "wet": wet, "tint": t_tint, "tinted": tinted and not baked, "name": str(t[0])}
		(_batches[key].xf as Array).append(t[1])
	tiles += out.size()


## The edges of a piece that top_caps lays its ground along: [[mid, dir, up, length], ...].
func _cap_edges(pts: PackedVector2Array) -> Array:
	var edges: Array = []
	var n := pts.size()
	var area := 0.0
	for i in n:
		area += pts[i].cross(pts[(i + 1) % n])
	var side := 1.0 if area > 0.0 else -1.0
	for i in n:
		var a := pts[i]
		var b := pts[(i + 1) % n]
		var length := a.distance_to(b)
		if length < 1.0:
			continue
		var dir := (b - a) / length
		var up := Vector2(dir.y, -dir.x) * side  # out of the piece
		if up.y < 0.62:
			continue  # (steeper than about 50 degrees, or facing down: a wall, not ground)
		if dir.x < 0.0:
			dir = -dir
		var mid := (a + b) * 0.5
		if not _open(mid + up * 0.2, dir, length):
			continue
		edges.append([mid, dir, up, length])
	return edges


## A MASS OF ANOTHER SHAPE (the Director, 11-17: the rubble slope at 1.10 drew as one big
## flat pale shape, the loudest thing in its frame): a rock mass of three sides, or five
## and more, that no module fits wears the kit's panels all the same, laid level and upright
## over it, each one cut to the mass's outline (and short of the band along an open top,
## which is top_caps' ground). Whichever panels have landed are the ones cut. Returns the z
## the caller's plain body may come forward to (behind the panels' faces, so it shows only
## at the cut sides), or INF when it is not dressed.
func clipped(pts: PackedVector2Array, kind: String, z0: float, z1: float) -> float:
	if pts.size() == 4 or pts.size() < 3:
		return INF
	var mat := str(MATERIAL.get(kind, ""))
	var panel_base := "fit_%s_panel" % mat
	if mat == "" or _pick(panel_base) == "":
		return INF
	# The outline the panels are cut to: the mass, less the band its top's ground covers.
	var region: Array = [pts]
	if _pick("fit_%s_cap" % mat) != "":
		for e: Array in _cap_edges(pts):
			var mid: Vector2 = e[0]
			var half: Vector2 = (e[1] as Vector2) * (float(e[3]) * 0.5)
			var inward: Vector2 = -(e[2] as Vector2) * 0.5
			var band := PackedVector2Array([mid - half, mid + half, mid + half + inward, mid - half + inward])
			var left: Array = []
			for r: PackedVector2Array in region:
				for piece: PackedVector2Array in Geometry2D.clip_polygons(r, band):
					if Geometry2D.is_polygon_clockwise(piece) != Geometry2D.is_polygon_clockwise(r):
						continue  # (a hole: never, at an edge)
					left.append(piece)
			region = left
	var lo := pts[0]
	var hi := pts[0]
	for q in pts:
		lo = lo.min(q)
		hi = hi.max(q)
	var size := hi - lo
	var nx := maxi(1, roundi(size.x / 2.0))
	var ny := maxi(1, roundi(size.y / 2.0))
	var pw := size.x / nx
	var ph := size.y / ny
	var zc := (z0 + z1) * 0.5
	var zs := (z1 - z0) / 2.4
	var wet := "" if peak.kind_grips(kind) else Peak.slick_class(kind)
	var tinted := mat in TINTED and wet == ""
	var tint := _tint(kind) if tinted else Color.WHITE
	var front := z1
	var laid := 0
	for iy in ny:
		for ix in nx:
			var a := lo + Vector2(pw * ix, ph * iy)
			var cell := PackedVector2Array([a, a + Vector2(pw, 0), a + Vector2(pw, ph), a + Vector2(0, ph)])
			var pieces: Array = []
			var got := 0.0
			for r: PackedVector2Array in region:
				for piece: PackedVector2Array in Geometry2D.intersect_polygons(cell, r):
					pieces.append(piece)
					got += _area(piece)
			if got < pw * ph * 0.01:
				continue
			var file := _pick(panel_base, ix * 7 + iy * 13)
			var xf := _xf(a + Vector2(pw, ph) * 0.5, 0.0, Vector3(pw / 2.0, ph / 2.0, zs), zc)
			front = minf(front, _face_z(file, xf))
			laid += 1
			if got >= pw * ph * 0.995:
				var key := "%s|%s|%s" % [file, wet, tint.to_html(false)]
				if not _batches.has(key):
					_batches[key] = {"mesh": _mesh(file), "xf": [], "wet": wet, "tint": tint, "tinted": tinted, "name": file}
				(_batches[key].xf as Array).append(xf)
			else:
				_cut_into("%s|%s" % [wet, tint.to_html(false)], file, xf, pieces, wet, tint, tinted)
	if laid == 0:
		return INF
	placed += 1
	tiles += laid
	return front - 0.02


## A panel placed by `xf`, cut to `pieces` (its cell's share of the outline) by its own
## triangles, seen face on: each is clipped in the play plane and its points read back
## from the triangle it came from. A side triangle (edge on to the camera) stays whole
## where its middle is inside, and goes where it is not.
func _cut_into(key: String, file: String, xf: Transform3D, pieces: Array, wet: String, tint: Color, tinted: bool) -> void:
	if not _cut.has(key):
		_cut[key] = {"v": PackedVector3Array(), "n": PackedVector3Array(), "uv": PackedVector2Array(), "wet": wet, "tint": tint, "tinted": tinted, "name": file}
	var into: Dictionary = _cut[key]
	var nb := xf.basis.inverse().transposed()
	for surf: Array in _surfaces(file):
		var verts: PackedVector3Array = surf[0]
		var norms: PackedVector3Array = surf[1]
		var uvs: PackedVector2Array = surf[2]
		var idx: PackedInt32Array = surf[3]
		var has_n := norms.size() == verts.size()
		var has_uv := uvs.size() == verts.size()
		for t in range(0, idx.size() - 2, 3):
			var k0 := idx[t]
			var k1 := idx[t + 1]
			var k2 := idx[t + 2]
			var p0 := xf * verts[k0]
			var p1 := xf * verts[k1]
			var p2 := xf * verts[k2]
			var q0 := Vector2(p0.x, p0.y)
			var q1 := Vector2(p1.x, p1.y)
			var q2 := Vector2(p2.x, p2.y)
			var n0 := norms[k0] if has_n else Vector3.BACK
			var n1 := norms[k1] if has_n else Vector3.BACK
			var n2 := norms[k2] if has_n else Vector3.BACK
			var u0 := uvs[k0] if has_uv else Vector2.ZERO
			var u1 := uvs[k1] if has_uv else Vector2.ZERO
			var u2 := uvs[k2] if has_uv else Vector2.ZERO
			var d := (q1 - q0).cross(q2 - q0)
			if absf(d) < 0.0004:
				# Edge on (an underside, a side): it lies along a line in the play plane. Cut it in
				# its own plane (along that line, and deep) to the stretches of the line inside.
				var along := q1 - q0
				if (q2 - q0).length() > along.length():
					along = q2 - q0
				if (q2 - q1).length() > along.length():
					along = q2 - q1
				if along.length() < 0.0001:
					continue
				along = along.normalized()
				var s0 := q0.dot(along)
				var s1 := q1.dot(along)
				var s2 := q2.dot(along)
				var e0 := Vector2(s0, p0.z)
				var e1 := Vector2(s1, p1.z)
				var e2 := Vector2(s2, p2.z)
				var de := (e1 - e0).cross(e2 - e0)
				if absf(de) < 0.000001:
					continue
				var smin := minf(s0, minf(s1, s2)) - 0.01
				var smax := maxf(s0, maxf(s1, s2)) + 0.01
				var base := q0 - along * s0  # (the line's point at s = 0)
				var line := PackedVector2Array([base + along * smin, base + along * smax])
				var zlo := minf(p0.z, minf(p1.z, p2.z)) - 1.0
				var zhi := maxf(p0.z, maxf(p1.z, p2.z)) + 1.0
				var etri := PackedVector2Array([e0, e1, e2])
				for piece: PackedVector2Array in pieces:
					for seg: PackedVector2Array in Geometry2D.intersect_polyline_with_polygon(line, piece):
						var a0 := seg[0].dot(along)
						var a1 := seg[seg.size() - 1].dot(along)
						var strip := PackedVector2Array([Vector2(minf(a0, a1), zlo), Vector2(maxf(a0, a1), zlo), Vector2(maxf(a0, a1), zhi), Vector2(minf(a0, a1), zhi)])
						for part: PackedVector2Array in Geometry2D.intersect_polygons(etri, strip):
							var fan := Geometry2D.triangulate_polygon(part)
							for f in range(0, fan.size() - 2, 3):
								var ord := [fan[f], fan[f + 1], fan[f + 2]]
								if signf((part[ord[1]] - part[ord[0]]).cross(part[ord[2]] - part[ord[0]])) != signf(de):
									ord = [fan[f], fan[f + 2], fan[f + 1]]
								for o: int in ord:
									var x: Vector2 = part[o]
									var w0 := (e1 - x).cross(e2 - x) / de
									var w1 := (e2 - x).cross(e0 - x) / de
									var w2 := 1.0 - w0 - w1
									into.v.append(p0 * w0 + p1 * w1 + p2 * w2)
									into.n.append((nb * (n0 * w0 + n1 * w1 + n2 * w2)).normalized())
									into.uv.append(u0 * w0 + u1 * w1 + u2 * w2)
				continue
			var tri := PackedVector2Array([q0, q1, q2])
			for piece: PackedVector2Array in pieces:
				for part: PackedVector2Array in Geometry2D.intersect_polygons(tri, piece):
					var fan := Geometry2D.triangulate_polygon(part)
					for f in range(0, fan.size() - 2, 3):
						var ord := [fan[f], fan[f + 1], fan[f + 2]]
						if signf((part[ord[1]] - part[ord[0]]).cross(part[ord[2]] - part[ord[0]])) != signf(d):
							ord = [fan[f], fan[f + 2], fan[f + 1]]  # (wound as the triangle it came from)
						for o: int in ord:
							var x: Vector2 = part[o]
							var w0 := (q1 - x).cross(q2 - x) / d
							var w1 := (q2 - x).cross(q0 - x) / d
							var w2 := 1.0 - w0 - w1
							into.v.append(p0 * w0 + p1 * w1 + p2 * w2)
							into.n.append((nb * (n0 * w0 + n1 * w1 + n2 * w2)).normalized())
							into.uv.append(u0 * w0 + u1 * w1 + u2 * w2)


## The nearest a module's camera-facing faces come to the back, placed by `xf` (the plain
## body behind a cut mass stops short of it).
func _face_z(file: String, xf: Transform3D) -> float:
	var z := INF
	for surf: Array in _surfaces(file):
		var verts: PackedVector3Array = surf[0]
		var norms: PackedVector3Array = surf[1]
		if norms.size() != verts.size():
			continue
		for i in verts.size():
			if norms[i].z > 0.5:
				z = minf(z, (xf * verts[i]).z)
	return z if z < INF else xf.origin.z


static func _surfaces(file: String) -> Array:
	if _arrays.has(file):
		return _arrays[file]
	var out: Array = []
	var mesh := _mesh(file)
	if mesh != null:
		for si in mesh.get_surface_count():
			var arr := mesh.surface_get_arrays(si)
			var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			var idx := PackedInt32Array()
			if arr[Mesh.ARRAY_INDEX] != null:
				idx = arr[Mesh.ARRAY_INDEX]
			if idx.is_empty():
				for i in verts.size():
					idx.append(i)
			var norms := PackedVector3Array()
			if arr[Mesh.ARRAY_NORMAL] != null:
				norms = arr[Mesh.ARRAY_NORMAL]
			var uvs := PackedVector2Array()
			if arr[Mesh.ARRAY_TEX_UV] != null:
				uvs = arr[Mesh.ARRAY_TEX_UV]
			out.append([verts, norms, uvs, idx])
	_arrays[file] = out
	return out


static func _area(poly: PackedVector2Array) -> float:
	var s := 0.0
	for i in poly.size():
		s += poly[i].cross(poly[(i + 1) % poly.size()])
	return absf(s) * 0.5


## The same for a solid that lives on its own (a hold that crumbles, wets or is tagged):
## a node of its own, to shake, hide and wet. null: no module for it.
func single(s: Dictionary, pts: PackedVector2Array, kind: String, z0: float, z1: float) -> Node3D:
	var plan := _plan(s, pts, kind, z0, z1)
	if plan.is_empty():
		return null
	var wet := "" if peak.kind_grips(kind) else Peak.slick_class(kind)
	var mat := str(MATERIAL.get(kind, ""))
	var holder := Node3D.new()
	holder.set_meta("fitted", true)
	for t: Array in plan:
		var mi := MeshInstance3D.new()
		mi.mesh = _mesh(str(t[0]))
		mi.transform = t[1]
		mi.material_override = _material(str(t[0]), wet)
		if mat in TINTED:
			mi.set_instance_shader_parameter(&"tint", _tint(kind))
		holder.add_child(mi)
	placed += 1
	tiles += plan.size()
	return holder


## A fitted piece goes wet (cls "mud" / "glass" / "ice") or dry again ("").
static func set_wet(holder: Node3D, cls: String) -> void:
	for ch in holder.get_children():
		if ch is MeshInstance3D:
			(ch as MeshInstance3D).material_override = Peak.slick_material(cls) if cls != "" else CelPass.one()


## Every batch becomes one drawn thing.
func commit() -> void:
	for key: String in _batches:
		var b: Dictionary = _batches[key]
		var xf: Array = b.xf
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = b.mesh
		mm.instance_count = xf.size()
		# (A slick tile is drawn a hair smaller, so where a grip piece and a slick one lay the
		# same ground the grip one is the one seen: it is the truth about what can be held.)
		var shrink := Transform3D(Basis.from_scale(Vector3(1.0, 0.97, 0.985)), Vector3.ZERO) if str(b.wet) != "" else Transform3D()
		for i in xf.size():
			mm.set_instance_transform(i, (xf[i] as Transform3D) * shrink)
		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		mmi.material_override = _material(str(b.name), str(b.wet))
		if bool(b.tinted):
			mmi.set_instance_shader_parameter(&"tint", b.tint)
		mmi.name = "Fit_" + str(b.name) + ("_" + str(b.wet) if str(b.wet) != "" else "")
		root.add_child(mmi)
	for key: String in _cut:
		var c: Dictionary = _cut[key]
		if (c.v as PackedVector3Array).is_empty():
			continue
		var arr := []
		arr.resize(Mesh.ARRAY_MAX)
		arr[Mesh.ARRAY_VERTEX] = c.v
		arr[Mesh.ARRAY_NORMAL] = c.n
		arr[Mesh.ARRAY_TEX_UV] = c.uv
		var am := ArrayMesh.new()
		am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
		var mi := MeshInstance3D.new()
		mi.mesh = am
		mi.material_override = _material(str(c.name), str(c.wet))
		if bool(c.tinted):
			mi.set_instance_shader_parameter(&"tint", c.tint)
		mi.name = "FitCut" + ("_" + str(c.wet) if str(c.wet) != "" else "")
		root.add_child(mi)


func _tint(kind: String) -> Color:
	var c: Color = peak.kind_color(area, kind)
	return Color(minf(c.r / NEUTRAL, 1.0), minf(c.g / NEUTRAL, 1.0), minf(c.b / NEUTRAL, 1.0))


func _material(file: String, wet: String) -> Material:
	if wet != "":
		return Peak.slick_material(wet)
	if test_mode and not LuchaKit.kit_model_exists(file):
		return CelPass.cel_material(Color.from_hsv(fposmod(float(hash(file) % 1000) / 1000.0, 1.0), 0.45, 0.95))
	return CelPass.one()


# ================================================================ what a solid wears

## [[file name, Transform3D], ...] for a solid; empty when nothing fits it.
func _plan(s: Dictionary, pts: PackedVector2Array, kind: String, z0: float, z1: float) -> Array:
	_n += 1
	var mat := str(MATERIAL.get(kind, ""))
	if mat == "":
		return []
	var out: Array = []
	var zc := (z0 + z1) * 0.5
	var deep := z1 - z0
	var own_z := s.has("z")
	var r := _rect(pts)
	# ---- a piece named by the course (a ladder's rung): fitted by its own size
	if s.has("fit"):
		var named := "fit_" + str(s.fit)
		var file := _pick(named, _n)  # (one of its variants: a ladder's rail is straight or kinked)
		if r.is_empty() or file == "":
			return []
		var box: AABB = _boxes.get(file, AABB(Vector3(-0.5, -0.05, -0.1), Vector3(1.0, 0.1, 0.2)))
		if NAMED.has(named):
			var made: Vector2 = NAMED[named]
			box = AABB(Vector3(-made.x * 0.5, -made.y * 0.5, 0), Vector3(made.x, made.y, 0))
		var long_x := box.size.x >= box.size.y
		var w: float = r.w
		var h: float = r.h
		var ang: float = r.ang
		if long_x != (w >= h):
			# (the piece lies the other way from the box: turn it a quarter)
			ang += PI * 0.5
			var sw := w
			w = h
			h = sw
		var sx := w / maxf(box.size.x, 0.01)
		var sy := h / maxf(box.size.y, 0.01)
		var su := sy if long_x else sx  # (its section keeps its shape: z goes with the thin side)
		out.append([file, _xf(r.c, ang, Vector3(sx, sy, su), 0.0)])
		return out
	# ---- a spike: a triangle that comes to a point (an icicle, a stalagmite, a fang, a
	# crystal's tip) wears the kit's spike: made 0.6 across its base and 1.5 long to its
	# point, its origin the middle of the base; turned to the triangle's point and scaled
	if pts.size() == 3:
		var spike := _pick("fit_ice_icicle" if mat == "ice" else "fit_%s_spike" % mat, _n)
		if spike == "":
			return []
		# (the base is the shortest side; the point is the corner across from it)
		var tip := 0
		var shortest := INF
		for i in 3:
			var side := pts[(i + 1) % 3].distance_to(pts[(i + 2) % 3])
			if side < shortest:
				shortest = side
				tip = i
		var ta := pts[(tip + 1) % 3]
		var tb := pts[(tip + 2) % 3]
		var base_mid := (ta + tb) * 0.5
		var down := pts[tip] - base_mid
		if down.length() < shortest * 0.9 or shortest > 1.7 or down.length() > 4.0:
			return []  # (a flat wedge or one of the mountain's masses, not a spike)
		var k := shortest / 0.6
		out.append([spike, _xf(base_mid, down.angle() + PI * 0.5, Vector3(k, down.length() / 1.5, clampf(k, 0.6, 1.6)), 0.0)])
		return out
	# ---- a single hold: a small polygon of five sides or more, or a small nub
	if r.is_empty():
		if pts.size() < 5:
			return []
		var c := Vector2.ZERO
		for q in pts:
			c += q
		c /= float(pts.size())
		var rad := 0.0
		for q in pts:
			rad = maxf(rad, c.distance_to(q))
		if rad > 0.55:
			return []
		var hf := _pick("fit_%s_hold" % mat)
		if hf == "":
			return []
		var k := rad / 0.25
		out.append([hf, _xf(c, 0.0, Vector3(k, k, clampf(k, 0.7, 1.5)), 0.0)])
		return out
	var w: float = r.w
	var h: float = r.h
	var ax: Vector2 = r.ax
	var ay: Vector2 = r.ay
	var lo := minf(w, h)
	var hi := maxf(w, h)
	if hi <= 0.75:
		var nf := _pick("fit_%s_hold" % mat)
		if nf == "":
			return []
		out.append([nf, _xf(r.c, r.ang, Vector3(w / 0.5, h / 0.5, clampf((w + h) * 0.5 / 0.5, 0.6, 1.4)), 0.0)])
		return out
	# ---- a board walk: a plank, however thin, is a run of the kit's planking. It is drawn
	# no thinner than 0.3 (the boards on their side beam), hung from the top it is stood on.
	if lo <= 0.3 and w >= 1.0 and w > h and _pick("fit_%s_cap" % mat) != "" and (kind in ["plank", "rotten"] or _pick("fit_%s_cap_thin" % mat) != ""):
		var seen := maxf(h, 0.3)
		# (the kit's thin planking, made 0.3 tall, where it has landed for this material)
		var thin := _pick("fit_%s_cap_thin" % mat) != ""
		_caps(out, mat, r.c + ay * ((h - seen) * 0.5), ax, ay, r.ang, w, seen, zc, deep / 2.4, false, "cap_thin" if thin else "cap", 0.3 if thin else 0.5)
		return out
	# ---- a bar: thin, along its long side
	if lo <= 0.3:
		var bf := _pick("fit_%s_bar" % mat)
		if bf == "":
			return []
		var n := maxi(1, roundi(hi / 1.5))
		var seg := hi / n
		var along := ax if w >= h else ay
		var ang: float = r.ang if w >= h else float(r.ang) + PI * 0.5
		for i in n:
			var at: Vector2 = r.c + along * (-hi * 0.5 + seg * (i + 0.5))
			out.append([bf, _xf(at, ang, Vector3(seg / 1.0, lo / 0.12, lo / 0.12), zc if own_z else 0.0)])
		return out
	# ---- a pole: slender and upright
	if lo <= 1.0 and h > w and hi / lo >= 1.4:
		if _pick("fit_%s_pole" % mat) == "":
			return []
		var n := maxi(1, roundi(hi / 3.2))
		var seg := hi / n
		# (The first variant is the whole pole and stacks; the others have a broken top, and
		# stand only where the top is in the open.)
		var top_free := _open(r.c + ay * (hi * 0.5 + 0.25), Vector2.ZERO, 0.0)
		for i in n:
			var at: Vector2 = r.c + ay * (-hi * 0.5 + seg * (i + 0.5))
			var file := _pick("fit_%s_pole" % mat, _n * 3 + 1) if (i == n - 1 and top_free) else str((_variants["fit_%s_pole" % mat] as Array)[0])
			out.append([file, _xf(at, r.ang, Vector3(lo / 0.4, seg / 2.5, lo / 0.4), zc if own_z else 0.0)])
		return out
	var zs := deep / 2.4
	# ---- a deck: thin and lying: caps end to end (an end piece where it stops in the open)
	if lo <= 1.0:
		if _pick("fit_%s_cap" % mat) == "":
			return []
		_caps(out, mat, r.c, ax, ay, r.ang, w, h, zc, zs, true)
		return out
	# ---- a thick mushroom is one fat cap (the kit's is made 2.0 x 1.0), stretched to it
	if mat == "shroom":
		var fat := _pick("fit_shroom_cap_thick", _n)
		if fat == "":
			return []
		out.append([fat, _xf(r.c, r.ang, Vector3(w / 2.0, h / 1.0, zs), zc)])
		return out
	# ---- a thick mass: panels both ways, and caps along its top where that is open air
	var panel_base := "fit_%s_panel" % mat
	if mat == "root" and _pick(panel_base) == "":
		panel_base = "fit_wood_panel_b"  # (a root's mass wears the stump's bark)
	if _pick(panel_base) == "" or (panel_base == "fit_wood_panel_b" and _mesh(panel_base) == null):
		return []
	var body_h := h
	var top_open := _open(r.c + ay * (h * 0.5 + 0.2), ax, w)
	if top_open and _pick("fit_%s_cap" % mat) != "":
		body_h = h - 0.5
		_caps(out, mat, r.c + ay * (h * 0.5 - 0.25), ax, ay, r.ang, w, 0.5, zc, zs, false)
	if buried(pts):
		return out  # (inside a bigger piece: its top alone shows; empty = the caller hides its face)
	var nx := maxi(1, roundi(w / 2.0))
	var ny := maxi(1, roundi(body_h / 2.0))
	var pw := w / nx
	var ph := body_h / ny
	var foot: Vector2 = r.c - ay * (h * 0.5)
	for iy in ny:
		for ix in nx:
			var at: Vector2 = foot + ax * (-w * 0.5 + pw * (ix + 0.5)) + ay * (ph * (iy + 0.5))
			var panel := panel_base if panel_base == "fit_wood_panel_b" else _pick(panel_base, ix * 7 + iy * 13)
			if mat == "wood":
				# (the kit's two timber panels are different things: cribbing for the works of
				# men, a stump's bark in the fungus garden)
				var want := "fit_wood_panel_b" if str(area.get("palette", "")) == "fungus" else "fit_wood_panel_a"
				if _mesh(want) != null:
					panel = want
			out.append([panel, _xf(at, r.ang, Vector3(pw / 2.0, ph / 2.0, zs), zc)])
	return out


func _caps(out: Array, mat: String, c: Vector2, ax: Vector2, _ay: Vector2, ang: float, w: float, h: float, zc: float, zs: float, ends: bool, module := "cap", made_h := 0.5) -> void:
	var x0 := -w * 0.5
	var x1 := w * 0.5
	var end_file := _area_pick("fit_%s_cap_end" % mat)
	# (From 1 m long, so long as half a metre of cap is left between: a shorter deck's open end showed the cap's raw
	# cut face, pale, at La Esclusa's east landing (1.9 m: the reviewer's q20, note 4).)
	if ends and end_file != "" and w >= 1.0:
		var ew := 0.5 * clampf(h / 0.5, 0.7, 1.4)
		if _open(c + ax * (w * 0.5 + 0.2), Vector2.ZERO, 0.0) and x1 - x0 - ew >= 0.5:
			out.append([end_file, _xf(c + ax * (x1 - ew * 0.5), ang, Vector3(ew / 0.5, h / 0.5, zs), zc)])
			x1 -= ew
		if _open(c - ax * (w * 0.5 + 0.2), Vector2.ZERO, 0.0) and x1 - x0 - ew >= 0.5:
			# (turned round about its upright: the same piece, facing left)
			out.append([end_file, _xf(c + ax * (x0 + ew * 0.5), ang, Vector3(ew / 0.5, h / 0.5, zs), zc, true)])
			x0 += ew
	var run := x1 - x0
	var n := maxi(1, roundi(run / 2.0))
	if mat == "shroom":
		n = 1  # (a mushroom's cap is one thing, rim to rim: it is stretched, never repeated)
	var seg := run / n
	for i in n:
		var at := c + ax * (x0 + seg * (i + 0.5))
		out.append([_area_pick("fit_%s_%s" % [mat, module], i), _xf(at, ang, Vector3(seg / 2.0, h / made_h, zs), zc)])


## A tile's place: at `at` in the play plane, turned `ang`, scaled. `about_face`: turned
## half round its upright (a right-hand end piece used at a left end).
static func _xf(at: Vector2, ang: float, scale: Vector3, z: float, about_face := false) -> Transform3D:
	var b := Basis(Vector3(0, 0, 1), ang)
	if about_face:
		b = b * Basis(Vector3(0, 1, 0), PI)
	return Transform3D(b.scaled_local(scale), Vector3(at.x, at.y, z))


## Does this piece lie wholly inside one bigger piece (a core of grip rock set in a slick
## mass, so that only its top is grip)? Its face is then the bigger piece's face.
func buried(pts: PackedVector2Array) -> bool:
	var c := Vector2.ZERO
	var box := Rect2(pts[0], Vector2.ZERO)
	for q in pts:
		c += q
		box = box.expand(q)
	c /= float(pts.size())
	for o: Array in _others:
		var ob: Rect2 = o[0]
		if ob.get_area() <= box.get_area() * 1.2 or not ob.has_point(c):
			continue
		var all_in := Geometry2D.is_point_in_polygon(c, o[1])
		for q in pts:
			if not all_in:
				break
			all_in = Geometry2D.is_point_in_polygon(q.move_toward(c, 0.2), o[1])
		if all_in:
			return true
	return false


## Is the air open just past an edge? `mid` is a point 0.2 outside the edge's middle;
## with `along` and `length` it is tested at three points along the edge.
func _open(mid: Vector2, along: Vector2, length: float) -> bool:
	var open := 0
	var tests := [0.0] if length <= 0.0 else [-0.3, 0.0, 0.3]
	for f: float in tests:
		var p: Vector2 = mid + along * (length * f)
		var inside := false
		for o: Array in _others:
			if (o[0] as Rect2).has_point(p) and Geometry2D.is_point_in_polygon(p, o[1]):
				inside = true
				break
		if not inside:
			open += 1
	return open * 2 > tests.size()


## {c, ax, ay, w, h, ang} when the polygon is a rectangle: ax its side nearer the level
## (pointing right), ay the other (pointing up). Empty when it is not one.
static func _rect(pts: PackedVector2Array) -> Dictionary:
	if pts.size() != 4:
		return {}
	var e0 := pts[1] - pts[0]
	var e1 := pts[2] - pts[1]
	var l0 := e0.length()
	var l1 := e1.length()
	if l0 < 0.01 or l1 < 0.01:
		return {}
	if absf(e0.dot(e1)) > 0.02 * l0 * l1 or (pts[2] - pts[3]).distance_to(e0) > 0.03 or (pts[3] - pts[0]).distance_to(e1) > 0.03:
		return _near_rect(pts)
	var ax := e0 / l0
	var w := l0
	var h := l1
	if absf(ax.x) < absf(ax.y):
		ax = e1 / l1
		w = l1
		h = l0
	if ax.x < 0.0:
		ax = -ax
	var ay := Vector2(-ax.y, ax.x)
	return {"c": (pts[0] + pts[1] + pts[2] + pts[3]) * 0.25, "ax": ax, "ay": ay, "w": w, "h": h, "ang": ax.angle()}


## A four-sided piece that is nearly a box (a stub cut on the skew, a wedge-ended step):
## the box along its longest side that holds it, when the piece fills most of that box.
static func _near_rect(pts: PackedVector2Array) -> Dictionary:
	var best := 0
	var longest := 0.0
	var area := 0.0
	for i in 4:
		var e := pts[(i + 1) % 4] - pts[i]
		area += pts[i].cross(pts[(i + 1) % 4])
		if e.length() > longest:
			longest = e.length()
			best = i
	area = absf(area) * 0.5
	var ax := (pts[(best + 1) % 4] - pts[best]).normalized()
	if absf(ax.x) < absf(ax.y):
		ax = Vector2(-ax.y, ax.x)  # (its long side stands: the box's level axis is across it)
	if ax.x < 0.0:
		ax = -ax
	var ay := Vector2(-ax.y, ax.x)
	var a0 := INF
	var a1 := -INF
	var b0 := INF
	var b1 := -INF
	for q in pts:
		a0 = minf(a0, q.dot(ax))
		a1 = maxf(a1, q.dot(ax))
		b0 = minf(b0, q.dot(ay))
		b1 = maxf(b1, q.dot(ay))
	var w := a1 - a0
	var h := b1 - b0
	if w < 0.01 or h < 0.01 or area < 0.72 * w * h or maxf(w, h) > 3.2:
		return {}
	return {"c": ax * ((a0 + a1) * 0.5) + ay * ((b0 + b1) * 0.5), "ax": ax, "ay": ay, "w": w, "h": h, "ang": ax.angle()}


# ================================================================ the kit's files

## One of the variants of a module that have landed ("" when none has).
## THE MINE'S OWN CAPS (the reviewer's q41, 11-19: the fitted rock caps held 8 of the mine's 10 scenes under 9). The
## caps are painted neutral and tinted by the area's palette, and the mine's held rock (#D9C7A2) made every floor and
## landing in it the brightest flat in its frames, a different stone from the mine round it. In an area named here a
## module has its own counterpart, painted in its own colours (BAKED_TAG in its name: drawn untinted), used once it has
## landed; until then, and everywhere else, the tinted original.
const AREA_SWAP := {"a1": {"fit_rock_cap": "fit_rock_cap_mine", "fit_rock_cap_end": "fit_rock_cap_mine_end"}}
const BAKED_TAG := "_mine"


func _area_pick(base: String, salt := 0) -> String:
	var swap := str((AREA_SWAP.get(str(area.get("id", "")), {}) as Dictionary).get(base, ""))
	if swap != "":
		var f := _pick(swap, salt)
		if f != "":
			return f
	return _pick(base, salt)


static func _pick(base: String, salt := 0) -> String:
	if not _variants.has(base):
		var have: Array = []
		for suffix in ["", "_a", "_b", "_c", "_d"]:
			if _mesh(base + suffix) != null:
				have.append(base + suffix)
		_variants[base] = have
	var list: Array = _variants[base]
	if list.is_empty():
		return ""
	return str(list[absi(hash(salt * 31 + base.length())) % list.size()])


static func _mesh(file: String) -> Mesh:
	if _meshes.has(file):
		return _meshes[file]
	var mesh: Mesh = null
	if LuchaKit.kit_model_exists(file):
		var n := LuchaKit.kit_model(file)
		if n != null:
			var mi: MeshInstance3D = n as MeshInstance3D if n is MeshInstance3D else null
			if mi == null:
				var found := n.find_children("*", "MeshInstance3D", true, false)
				if not found.is_empty():
					mi = found[0]
			if mi != null:
				mesh = mi.mesh
				_boxes[file] = mi.get_aabb()
			n.free()
	elif test_mode:
		mesh = _stand_in(file)
	_meshes[file] = mesh
	return mesh


## Dev only (PEAK_FIT_TEST): a plain shape of the module's nominal size, to see the fit.
static func _stand_in(file: String) -> Mesh:
	var module := ""
	for m in ["cap_end", "cap", "panel", "pole", "bar", "hold"]:
		if file.contains("_" + m):
			module = m
			break
	if module == "" or file.ends_with("_b") or file.ends_with("_c") or file.ends_with("_a"):
		return null
	var size: Vector3 = NOMINAL[module]
	match module:
		"pole":
			var cyl := CylinderMesh.new()
			cyl.top_radius = size.x * 0.4
			cyl.bottom_radius = size.x * 0.5
			cyl.height = size.y
			cyl.radial_segments = 10
			return cyl
		"hold":
			var ball := SphereMesh.new()
			ball.radius = 0.25
			ball.height = 0.5
			ball.radial_segments = 8
			ball.rings = 4
			return ball
		"cap_end":
			var prism := PrismMesh.new()
			prism.size = size
			prism.left_to_right = 0.0
			return prism
	var box := BoxMesh.new()
	box.size = size
	return box
