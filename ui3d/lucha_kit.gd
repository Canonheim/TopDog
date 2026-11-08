class_name LuchaKit
extends RefCounted
## LUCHA KIT: the Top Dog look in one place. Colours, and the pieces of the 3D UI.
##
## Every piece first looks in the Top Dog Kit (`res://kit/models/<name>.glb`, copied
## in from `Desktop\Clod Things\Top Dog Kit\models`). Until the UI creator delivers a
## part, a placeholder is built here from primitives in the same size and colours,
## so the menus work today and the real models drop in by file name.
## All of it is cel-shaded (CelPass) and inked by the outline pass.

const KIT_DIR := "res://kit/models/"
const BELT_KIT_SCALE := 1.25  # the kit belt (1.82 m) at menu size: a 1.25 m label face

# The palette: lucha poster colours, matched to the Top Dog Kit as built (the UI
# creator's sRGB values, 2026-11-07).
const GOLD := Color("#FFC928")  # letter gold
const GOLD_METAL := Color("#F2BC36")
const GOLD_LIGHT := Color("#FFDF70")
const GOLD_DARK := Color("#B8862A")
const RED := Color("#B8202C")  # label red
const MAGENTA := Color("#D81E6A")  # banner magenta
const BLUE := Color("#2659D8")  # mask blue
const STRAP_BLUE := Color("#2F5FB8")  # belt strap
const TURQUOISE := Color("#1FB8AE")
const CREAM := Color("#FFF2D0")
const PINK := MAGENTA
const GREEN := Color(0.2, 0.7, 0.35)
const INK := Color(0.12, 0.08, 0.06)
const LEATHER := RED  # belt-plate lettering
const SILVER := Color(0.82, 0.84, 0.88)
const FLAG_COLOURS := [RED, GOLD, BLUE, MAGENTA, TURQUOISE, GREEN, Color(1.0, 0.55, 0.15)]
## The kit's cloud cards and their built widths (m), for scaling to a wanted width.
const CLOUDS := {"cloud_a": 8.3, "cloud_b": 10.45, "cloud_c": 4.25, "cloud_d": 9.6, "cloud_e": 5.6}

static var _font: Font = null


## A kit model if it's been delivered, else null.
static func kit_model(name: String) -> Node3D:
	var p := KIT_DIR + name + ".glb"
	if not ResourceLoader.exists(p):
		return null
	var n: Node3D = (load(p) as PackedScene).instantiate()
	CelPass.celify(n)
	return n


static func mat(c: Color) -> Material:
	return CelPass.cel_material(c)


static func unshaded(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m


static func box(size: Vector3, c: Color, at := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat(c)
	mi.position = at
	return mi


static func cyl(r: float, h: float, c: Color, at := Vector3.ZERO, axis := Vector3.UP) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = r
	cm.bottom_radius = r
	cm.height = h
	cm.radial_segments = 16
	mi.mesh = cm
	mi.material_override = mat(c)
	mi.position = at
	if axis == Vector3.RIGHT:
		mi.rotation = Vector3(0, 0, PI * 0.5)
	elif axis == Vector3.BACK:
		mi.rotation = Vector3(PI * 0.5, 0, 0)
	return mi


static func ball(r: float, c: Color, at := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	mi.mesh = sm
	mi.material_override = mat(c)
	mi.position = at
	return mi


## Extruded 3D letters (real geometry, so they're lit and inked like everything else).
static func text3d(s: String, size: float, c: Color, depth := 0.06) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var tm := TextMesh.new()
	tm.text = s
	tm.font_size = 64
	tm.pixel_size = size / 64.0
	tm.depth = depth
	tm.curve_step = 1.5
	if _font != null:
		tm.font = _font
	mi.mesh = tm
	mi.material_override = mat(c)
	return mi


## Words with a fat dark backing (the lucha poster look): letters over a deeper,
## slightly larger copy pushed back.
static func poster_text(s: String, size: float, face: Color, back := INK, depth := 0.08) -> Node3D:
	var root := Node3D.new()
	# A drop-shadow copy, down and right, pushed back: the lucha poster's fat edge.
	var b := text3d(s, size, back, depth * 1.5)
	b.position = Vector3(size * 0.05, -size * 0.07, -depth * 0.9)
	root.add_child(b)
	var f := text3d(s, size, face, depth)
	f.name = "face"
	root.add_child(f)
	return root


# ---------------------------------------------------------------- the pieces

## A1: the TOP DOG logo.
static func title_logo() -> Node3D:
	var k := kit_model("title_logo")
	if k != null:
		# Built 3.3 x 1.01 m (r2) with its origin at the bottom centre: scale it up and
		# centre it on the header spot.
		var holder := Node3D.new()
		k.scale = Vector3.ONE * 1.45
		k.position = Vector3(0, -1.006 * 1.45 * 0.5, 0)
		holder.add_child(k)
		return holder
	var root := Node3D.new()
	var slab := box(Vector3(4.3, 1.55, 0.18), RED, Vector3(0, 0.05, -0.2))
	root.add_child(slab)
	var slab2 := box(Vector3(4.55, 1.8, 0.12), GOLD, Vector3(0, 0.05, -0.32))
	root.add_child(slab2)
	var top := poster_text("TOP", 0.62, GOLD, INK, 0.14)
	top.position = Vector3(-0.95, 0.32, 0)
	root.add_child(top)
	var dog := poster_text("DOG", 0.9, CREAM, INK, 0.16)
	dog.position = Vector3(0.55, -0.18, 0)
	root.add_child(dog)
	var m := mask_icon(BLUE, GOLD)
	m.scale = Vector3.ONE * 0.55
	m.position = Vector3(-0.95, -0.38, 0.05)
	root.add_child(m)
	for sx in [-1.0, 1.0]:
		var star := star_mesh(0.22, GOLD)
		star.position = Vector3(sx * 2.0, 0.62, 0.02)
		root.add_child(star)
	return root


## A5: a luchador mask emblem (placeholder: a rounded face with eye cut-outs).
static func mask_icon(face := RED, trim := GOLD) -> Node3D:
	var k := kit_model("mask_icon")
	if k != null:
		return k
	var root := Node3D.new()
	var head := ball(0.32, face)
	head.scale = Vector3(1.0, 1.15, 0.45)
	root.add_child(head)
	for sx in [-1.0, 1.0]:
		var eye := ball(0.085, CREAM, Vector3(sx * 0.12, 0.05, 0.13))
		eye.scale = Vector3(1.3, 0.9, 0.4)
		root.add_child(eye)
		var ring := ball(0.11, trim, Vector3(sx * 0.12, 0.05, 0.11))
		ring.scale = Vector3(1.35, 1.0, 0.35)
		root.add_child(ring)
		var ear := ball(0.1, face, Vector3(sx * 0.24, 0.3, -0.02))
		ear.scale = Vector3(0.8, 1.3, 0.5)
		root.add_child(ear)
	var mouth := ball(0.07, INK, Vector3(0, -0.17, 0.13))
	mouth.scale = Vector3(1.6, 0.7, 0.4)
	root.add_child(mouth)
	var stripe := box(Vector3(0.07, 0.5, 0.06), trim, Vector3(0, 0.12, 0.12))
	root.add_child(stripe)
	return root


## A five-point star (flat, extruded).
static func star_mesh(r: float, c: Color) -> MeshInstance3D:
	var pts := PackedVector2Array()
	for i in 10:
		var a := PI * 0.5 + i * TAU / 10.0
		var rr := r if i % 2 == 0 else r * 0.45
		pts.append(Vector2(cos(a), sin(a)) * rr)
	return _extrude(pts, 0.05, c)


static func _extrude(pts: PackedVector2Array, depth: float, c: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = _prism(pts, depth)
	mi.material_override = mat(c)
	return mi


## A flat polygon extruded along z (front at +depth/2).
static func _prism(pts: PackedVector2Array, depth: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tris := Geometry2D.triangulate_polygon(pts)
	var hz := depth * 0.5
	for face in [1.0, -1.0]:
		st.set_normal(Vector3(0, 0, face))
		for k in range(0, tris.size(), 3):
			var idx := [tris[k], tris[k + 1], tris[k + 2]]
			if face < 0:
				idx = [tris[k], tris[k + 2], tris[k + 1]]
			for i in idx:
				st.add_vertex(Vector3(pts[i].x, pts[i].y, hz * face))
	for i in pts.size():
		var a := pts[i]
		var b := pts[(i + 1) % pts.size()]
		var n := Vector3(b.y - a.y, a.x - b.x, 0).normalized()
		st.set_normal(n)
		for v in [Vector3(a.x, a.y, hz), Vector3(b.x, b.y, hz), Vector3(b.x, b.y, -hz), Vector3(a.x, a.y, hz), Vector3(b.x, b.y, -hz), Vector3(a.x, a.y, -hz)]:
			st.add_vertex(v)
	return st.commit()


## A2: a championship-belt plate button (placeholder): gold plate, darker rim,
## red leather strap out both sides, studs.
static func belt_button(width := 2.2) -> Node3D:
	var k := kit_model("belt_button")
	if k != null:
		# Built: plate + a 1 m strap segment, 1.82 m across; the label face is flat,
		# 1.0 x 0.26 m at z 0.046; the pug crest (belt_crest) stands 0.5 m above.
		var holder := Node3D.new()
		var s := BELT_KIT_SCALE
		k.scale = Vector3.ONE * s
		holder.add_child(k)
		var crest := k.find_child("belt_crest", true, false)
		holder.set_meta("face_z", 0.046 * s)
		holder.set_meta("face_w", 1.0 * s)
		holder.set_meta("height", 0.614 * s)  # the plate, top rim to bottom point (-0.345..+0.269), crest hidden
		holder.set_meta("width", 1.82 * s)
		holder.set_meta("text_color", CREAM)  # the kit's label face is red: cream letters
		holder.set_meta("text_back", INK)
		if crest != null:
			holder.set_meta("crest", crest)
			(crest as Node3D).visible = false
		return holder
	var root := Node3D.new()
	var strap := box(Vector3(width + 1.2, 0.26, 0.05), LEATHER, Vector3(0, 0, -0.04))
	root.add_child(strap)
	for sx in [-1.0, 1.0]:
		for i in 3:
			root.add_child(ball(0.03, GOLD, Vector3(sx * (width * 0.5 + 0.15 + i * 0.18), 0, 0.0)))
	var rim := box(Vector3(width + 0.1, 0.56, 0.06), GOLD_DARK, Vector3(0, 0, -0.01))
	root.add_child(rim)
	var plate := box(Vector3(width, 0.46, 0.08), GOLD, Vector3(0, 0, 0.02))
	plate.name = "plate"
	root.add_child(plate)
	for sx in [-1.0, 1.0]:
		var gem := ball(0.055, RED, Vector3(sx * (width * 0.5 - 0.12), 0, 0.07))
		root.add_child(gem)
	return root


## A6: a fight-poster card (player slots).
static func card_frame(face := CREAM, band := RED) -> Node3D:
	var k := kit_model("card_frame")
	if k != null:
		return k
	var root := Node3D.new()
	root.add_child(box(Vector3(1.3, 1.7, 0.05), INK, Vector3(0, 0, -0.03)))
	root.add_child(box(Vector3(1.2, 1.6, 0.05), face, Vector3(0, 0, 0)))
	root.add_child(box(Vector3(1.2, 0.34, 0.07), band, Vector3(0, 0.63, 0.01)))
	root.add_child(box(Vector3(1.2, 0.12, 0.07), band, Vector3(0, -0.74, 0.01)))
	return root


## A4: a papel picado flag (a thin paper rectangle with a scalloped bottom; the
## real ones from the kit have cut patterns).
static func papel_flag(c: Color) -> Node3D:
	var k := kit_model("papel_picado")
	if k != null:
		return k
	var pts := PackedVector2Array([Vector2(-0.22, 0), Vector2(0.22, 0)])
	for i in range(6, -1, -1):
		var x := -0.22 + i * (0.44 / 6.0)
		pts.append(Vector2(x, -0.52 - (0.05 if i % 2 == 0 else 0.0)))
	var flag := _extrude(pts, 0.012, c)
	var root := Node3D.new()
	root.add_child(flag)
	var hole := ball(0.06, CREAM, Vector3(0, -0.24, 0.0))
	hole.scale = Vector3(1, 1, 0.25)
	root.add_child(hole)
	return root


## A string of papel picado between two points (in the parent's frame).
static func bunting(a: Vector3, b: Vector3, n: int, sag := 0.5) -> Node3D:
	var root := Node3D.new()
	var prev := a
	for i in n + 1:
		var f := float(i) / n
		var p := a.lerp(b, f) + Vector3(0, -sag * 4.0 * f * (1.0 - f), 0)
		if i > 0:
			var seg := cyl(0.008, prev.distance_to(p), INK)
			seg.position = (prev + p) * 0.5
			seg.look_at_from_position(seg.position, p, Vector3.UP)
			seg.rotate_object_local(Vector3.RIGHT, PI * 0.5)
			root.add_child(seg)
		if i > 0 and i < n:
			var flag := papel_flag(FLAG_COLOURS[i % FLAG_COLOURS.size()])
			flag.position = p
			flag.rotation.z = randf_range(-0.08, 0.08)
			flag.set_meta("sway", randf() * TAU)
			root.add_child(flag)
		prev = p
	return root


## C1: a flat swirl cloud card (the stylized sky): overlapping cream lobes with
## spiral curls on the top, all flat, inked by the outline pass.
static func swirl_cloud(width: float, which := 0) -> Node3D:
	var names := CLOUDS.keys()
	var nm: String = names[which % names.size()]
	var k := kit_model(nm)
	if k != null:
		k.scale = Vector3.ONE * (width / float(CLOUDS[nm]))
		return k
	var root := Node3D.new()
	var lobes := int(clampf(width / 1.8, 3, 7))
	for i in lobes:
		var f := (float(i) + 0.5) / lobes - 0.5
		var r := width * (0.16 + 0.08 * sin(i * 2.1 + 0.5)) * (1.0 - absf(f) * 0.6)
		var lobe := _disc(r, CREAM)
		lobe.position = Vector3(f * width * 0.85, r * 0.35 - absf(f) * width * 0.08, 0.0)
		root.add_child(lobe)
	var base := _extrude(PackedVector2Array([Vector2(-width * 0.5, 0), Vector2(width * 0.5, 0), Vector2(width * 0.45, -width * 0.07), Vector2(-width * 0.45, -width * 0.07)]), 0.02, CREAM)
	root.add_child(base)
	# The curls: little spirals on two of the lobes.
	for i in [1, lobes - 2]:
		var f := (float(i) + 0.5) / lobes - 0.5
		var c := _spiral(width * 0.07, Color(0.55, 0.62, 0.78))
		c.position = Vector3(f * width * 0.85, width * 0.12, 0.03)
		root.add_child(c)
	return root


static func _disc(r: float, c: Color) -> MeshInstance3D:
	var pts := PackedVector2Array()
	for i in 28:
		var a := i * TAU / 28.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	var mi := _extrude(pts, 0.02, c)
	mi.material_override = unshaded(c)
	return mi


static func _spiral(r: float, c: Color) -> Node3D:
	var root := Node3D.new()
	var prev := Vector2.ZERO
	for i in range(1, 40):
		var a := i * 0.32
		var p := Vector2(cos(a), sin(a)) * r * (float(i) / 40.0)
		var seg := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(prev.distance_to(p) + 0.01, r * 0.09, 0.01)
		seg.mesh = bm
		seg.material_override = unshaded(c)
		seg.position = Vector3((prev.x + p.x) * 0.5, (prev.y + p.y) * 0.5, 0)
		seg.rotation.z = (p - prev).angle()
		root.add_child(seg)
		prev = p
	return root
