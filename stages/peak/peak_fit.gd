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
	"snow": "snow", "snowbridge": "snow", "ice": "ice", "blackice": "ice",
	"bone": "bone", "root": "root", "gill": "gill",
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
		var key := "%s|%s|%s" % [t[0], wet, tint.to_html(false)]
		if not _batches.has(key):
			_batches[key] = {"mesh": _mesh(str(t[0])), "xf": [], "wet": wet, "tint": tint, "tinted": tinted, "name": str(t[0])}
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
		_caps(out, mat, mid - up * 0.25, dir, up, dir.angle(), length, 0.5, (z0 + z1) * 0.5, (z1 - z0) / 2.4, false)
	if out.is_empty():
		return
	var wet := "" if peak.kind_grips(kind) else Peak.slick_class(kind)
	var tinted := mat in TINTED and wet == ""
	var tint := _tint(kind) if tinted else Color.WHITE
	for t: Array in out:
		var key := "%s|%s|%s" % [t[0], wet, tint.to_html(false)]
		if not _batches.has(key):
			_batches[key] = {"mesh": _mesh(str(t[0])), "xf": [], "wet": wet, "tint": tint, "tinted": tinted, "name": str(t[0])}
		(_batches[key].xf as Array).append(t[1])
	tiles += out.size()


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
	if lo <= 0.3 and w >= 1.0 and w > h and kind in ["plank", "rotten"] and _pick("fit_%s_cap" % mat) != "":
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
	# ---- a thick mass: panels both ways, and caps along its top where that is open air
	if _pick("fit_%s_panel" % mat) == "":
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
			out.append([_pick("fit_%s_panel" % mat, ix * 7 + iy * 13), _xf(at, r.ang, Vector3(pw / 2.0, ph / 2.0, zs), zc)])
	return out


func _caps(out: Array, mat: String, c: Vector2, ax: Vector2, _ay: Vector2, ang: float, w: float, h: float, zc: float, zs: float, ends: bool, module := "cap", made_h := 0.5) -> void:
	var x0 := -w * 0.5
	var x1 := w * 0.5
	var end_file := _pick("fit_%s_cap_end" % mat)
	if ends and end_file != "" and w >= 2.0:
		var ew := 0.5 * clampf(h / 0.5, 0.7, 1.4)
		if _open(c + ax * (w * 0.5 + 0.2), Vector2.ZERO, 0.0):
			out.append([end_file, _xf(c + ax * (x1 - ew * 0.5), ang, Vector3(ew / 0.5, h / 0.5, zs), zc)])
			x1 -= ew
		if _open(c - ax * (w * 0.5 + 0.2), Vector2.ZERO, 0.0):
			# (turned round about its upright: the same piece, facing left)
			out.append([end_file, _xf(c + ax * (x0 + ew * 0.5), ang, Vector3(ew / 0.5, h / 0.5, zs), zc, true)])
			x0 += ew
	var run := x1 - x0
	var n := maxi(1, roundi(run / 2.0))
	var seg := run / n
	for i in n:
		var at := c + ax * (x0 + seg * (i + 0.5))
		out.append([_pick("fit_%s_%s" % [mat, module], i), _xf(at, ang, Vector3(seg / 2.0, h / made_h, zs), zc)])


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
	if absf(e0.dot(e1)) > 0.02 * l0 * l1:
		return {}
	if (pts[2] - pts[3]).distance_to(e0) > 0.03 or (pts[3] - pts[0]).distance_to(e1) > 0.03:
		return {}
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


# ================================================================ the kit's files

## One of the variants of a module that have landed ("" when none has).
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
