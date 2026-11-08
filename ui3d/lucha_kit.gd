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
const LOGO_SCALE := 1.25  # the title logo, 25% bigger (Parker 11-08)
const LOGO_TILT_DEG := 10.0  # tilted clockwise (Parker 11-08)
const CLOUDS := {"cloud_a": 8.6, "cloud_b": 8.6, "cloud_c": 5.1, "cloud_d": 7.9, "cloud_e": 8.6}  # v2 widths (11-08)

static var _font: Font = null


## Tint one named part of a kit model (a near-white part on the atlas): its own copy
## of the cel material with `color` set, so the shared material stays untouched.
static func tint_part(root: Node, part: String, c: Color) -> void:
	var n := root.find_child(part, true, false)
	if n == null or not (n is MeshInstance3D):
		return
	var mi := n as MeshInstance3D
	for si in mi.mesh.get_surface_count():
		var m := mi.get_active_material(si)
		if m is ShaderMaterial:
			var d: ShaderMaterial = m.duplicate()
			d.set_shader_parameter("color", c)
			mi.set_surface_override_material(si, d)


static func kit_model_exists(name: String) -> bool:
	return ResourceLoader.exists(KIT_DIR + name + ".glb")


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


## The title font (Luckiest Guy, Apache 2.0, res://fonts/luckiest_guy/, see docs/PROVENANCE.md) when
## it's in the project; Godot's default font until then.
const TITLE_FONT := "res://fonts/luckiest_guy/LuckiestGuy-Regular.ttf"
static var _font_checked := false


## THE LETTERS SKIP THE INK (Parker 11-07: "add an alpha channel to just the
## letters so they dont get the outlines"). A UI word is a flat Label3D: alpha,
## unshaded, drawn in the transparent pass, after the house ink (which reads only
## opaque depth and normals), so it is never inked and covers any ink behind it.
## Label3D, not an extruded TextMesh: the title font draws its letters from
## overlapping outlines, which TextMesh fills wrong (ONLINE read ONUNE).
static func text3d(s: String, size: float, c: Color, _depth := 0.06, priority := 1) -> Label3D:
	if not _font_checked:
		_font_checked = true
		if ResourceLoader.exists(TITLE_FONT):
			_font = load(TITLE_FONT)
	var lb := Label3D.new()
	lb.text = s
	lb.font_size = 96
	lb.pixel_size = size / 96.0
	lb.modulate = c
	lb.outline_size = 0
	lb.shaded = false
	lb.double_sided = false
	lb.render_priority = priority
	lb.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	lb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if _font != null:
		lb.font = _font
	return lb


## A whole kit model out of the ink: its atlas colours, unshaded, drawn in the
## transparent pass (after the ink, which reads only opaque depth and normals).
static func skip_ink(root: Node) -> void:
	letters_skip_ink(root, "")


## A kit model's word objects (letters_*) out of the ink: the atlas colours, alpha.
static func letters_skip_ink(root: Node, prefix := "letters_") -> void:
	var m := StandardMaterial3D.new()
	m.albedo_texture = CelPass.ATLAS
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for n in root.find_children(prefix + "*", "MeshInstance3D", true, false):
		(n as MeshInstance3D).material_override = m


## Words with a fat dark backing (the lucha poster look): letters over a deeper,
## slightly larger copy pushed back.
static func poster_text(s: String, size: float, face: Color, back := INK, depth := 0.08) -> Node3D:
	var root := Node3D.new()
	# A drop-shadow copy, down and right, pushed back: the lucha poster's fat edge.
	var b := text3d(s, size, back, depth * 1.5, 0)
	b.position = Vector3(size * 0.05, -size * 0.07, -0.004)
	root.add_child(b)
	var f := text3d(s, size, face, depth, 1)
	f.name = "face"
	root.add_child(f)
	return root


# ---------------------------------------------------------------- the pieces

## A1: the TOP DOG logo.
static func title_logo() -> Node3D:
	var k := kit_model("title_logo")  # the logo keeps its ink, letters too (Parker 11-07)
	if k != null:
		# Built 3.3 x 1.01 m (r2) with its origin at the bottom centre: scale it up and
		# centre it on the header spot.
		var holder := Node3D.new()
		k.scale = Vector3.ONE * 1.45
		k.position = Vector3(0, -1.006 * 1.45 * 0.5, 0)
		# Parker 11-08: "about 25% bigger and rotated clockwise about 10 degrees",
		# on an inner pivot at the logo's centre, so the menu's wobble-in on the
		# holder never overrides it.
		var pivot := Node3D.new()
		pivot.scale = Vector3.ONE * LOGO_SCALE
		pivot.rotation = Vector3(0, 0, deg_to_rad(-LOGO_TILT_DEG))  # negative z = clockwise as seen
		pivot.add_child(k)
		holder.add_child(pivot)
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
		# Built ~0.71 x 0.49 m, origin the head's centre; the hood is near-white
		# so it takes the player's colour. (The placeholder is ~0.64 tall: match it.)
		tint_part(k, "mask_hood", face)
		k.scale = Vector3.ONE * 1.1
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
		# Built 1.2 x 1.6 m body (origin its centre), a 0.45 m mask crest above, ribbon
		# tails 0.2 m out. The band (and its tails) and the device strip are
		# near-white: they take the player's colour.
		tint_part(k, "card_band", band)
		tint_part(k, "card_strip", band.darkened(0.15))
		tint_part(k, "card_crest", band)  # the mask crest wears the player's colour too
		k.set_meta("kit", true)
		return k
	var root := Node3D.new()
	root.add_child(box(Vector3(1.3, 1.7, 0.05), INK, Vector3(0, 0, -0.03)))
	root.add_child(box(Vector3(1.2, 1.6, 0.05), face, Vector3(0, 0, 0)))
	root.add_child(box(Vector3(1.2, 0.34, 0.07), band, Vector3(0, 0.63, 0.01)))
	root.add_child(box(Vector3(1.2, 0.12, 0.07), band, Vector3(0, -0.74, 0.01)))
	return root


## A4: a papel picado flag (a thin paper rectangle with a scalloped bottom; the
## real ones from the kit have cut patterns).
static func papel_flag(c: Color, which := 0) -> Node3D:
	# The kit file holds five cut flags in a row (flag_a..flag_e, origin at each
	# flag's top centre) and a string: take one flag out and zero its offset.
	var k := kit_model("papel_picado")
	if k != null:
		var nm := "flag_" + "abcde"[which % 5]
		var f := k.find_child(nm, true, false) as Node3D
		if f != null:
			var holder := Node3D.new()
			f.get_parent().remove_child(f)
			holder.add_child(f)
			f.position = Vector3.ZERO
			k.queue_free()
			return holder
		k.queue_free()
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
	# HUNG ON THE STRING (Parker 11-08: the flags "should be following the string as
	# if they were actually hung up"): each flag hangs straight down from the line,
	# its face turned to lie along the string's run, not flat to the screen.
	var run := Vector2(b.x - a.x, b.z - a.z)
	var yaw := -atan2(run.y, run.x) if run.length() > 0.001 else 0.0
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
			# Two nodes: the hanger sits on the string, turned to its run; the flag
			# inside swings only about the string's own axis (its local x), as a
			# flag hinged on a line does (Parker 11-08).
			var hanger := Node3D.new()
			hanger.position = p
			hanger.rotation.y = yaw
			root.add_child(hanger)
			var flag := papel_flag(FLAG_COLOURS[i % FLAG_COLOURS.size()], i)
			flag.set_meta("sway", randf() * TAU)
			hanger.add_child(flag)
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
		# The clouds' own grey line is their outline, curling into the swirls (Parker
		# 11-08): out of the house ink, or a black edge fights it.
		skip_ink(k)
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


# ---------------------------------------------------------------- E: the online parts

const GREY := Color(0.55, 0.55, 0.58)
const ROW_SCALE := 1.25  # kit rows at menu size, like the belts


## A row plate grown to menu size: its metas (width, height, stop_x) grow with it.
static func _scale_row(root: Node3D, s: float) -> Node3D:
	root.scale = Vector3.ONE * s
	root.set_meta("width", float(root.get_meta("width")) * s)
	root.set_meta("height", float(root.get_meta("height")) * s)
	var xs: Array = []
	for x in root.get_meta("stop_x"):
		xs.append(float(x) * s)
	root.set_meta("stop_x", xs)
	return root


## Words fitted to a face `w` wide (letters shrink to fit, never past `max_size`).
static func fit_text(s: String, w: float, max_size: float, face := CREAM, back := INK) -> Node3D:
	var size := minf(max_size, w * 0.94 / maxf(1.0, s.length() * 0.62))
	return poster_text(s, size, face, back, 0.02)


## The focus rings of a kit part, hidden (Menu3D shows the focused one).
static func _focus_rings(root: Node3D, names: Array) -> Array:
	var out: Array = []
	for n in names:
		var f := root.find_child(n, true, false) as Node3D
		if f == null:
			f = box(Vector3(0.1, 0.1, 0.01), MAGENTA)  # a stand-in so the stop still exists
			root.add_child(f)
		f.visible = false
		out.append(f)
	return out


## A placeholder plate for a missing part: a gold rim and a coloured face.
static func _plate(w: float, h: float, c: Color) -> Node3D:
	var r := Node3D.new()
	r.add_child(box(Vector3(w + 0.08, h + 0.08, 0.04), GOLD, Vector3(0, 0, 0.02)))
	r.add_child(box(Vector3(w, h, 0.04), c, Vector3(0, 0, 0.04)))
	return r


## E6: a row of small belts (HOST: PUBLIC / FRIENDS / INVITE), a tag above, one
## focus stop per belt. Menu3D row plate: metas width, height, stop_x, focus_nodes.
static func belt_small_row(tag: String, options: Array) -> Node3D:
	var root := Node3D.new()
	var n := options.size()
	var gap := 1.3
	var xs: Array = []
	var rings: Array = []
	for i in n:
		var x := (i - (n - 1) * 0.5) * gap
		xs.append(x)
		var k := kit_model("belt_small")
		if k == null:
			k = _plate(1.2, 0.4, RED)
		k.position = Vector3(x, 0, 0)
		root.add_child(k)
		rings.append_array(_focus_rings(k, ["belt_small_focus"]))
		var t := fit_text(str(options[i]), 0.8, 0.15)
		t.position = Vector3(x, 0, 0.065)
		root.add_child(t)
	var tg := poster_text(tag, 0.17, GOLD, RED, 0.03)
	tg.position = Vector3(xs[0] - 0.6 + tag.length() * 0.05, 0.36, 0.04)
	root.add_child(tg)
	root.set_meta("width", gap * n)
	root.set_meta("height", 0.72)
	root.set_meta("stop_x", xs)
	root.set_meta("focus_nodes", rings)
	return _scale_row(root, 1.1)


## E2: a Join a Friend row: avatar disc, name, a JOIN plate (or WAIT, greyed).
static func friend_row(name_s: String, sub: String, can_join: bool) -> Node3D:
	var k := kit_model("friend_row")
	var root := Node3D.new()
	if k == null:
		k = _plate(3.0, 0.58, Color("#1E2C5C"))
	root.add_child(k)
	var rings := _focus_rings(k, ["friend_row_focus", "friend_join_focus"])
	if not can_join:
		tint_part(k, "friend_join_face", GREY)
	var nm := fit_text(name_s, 1.4, 0.2, RED, INK)
	nm.position = Vector3(-0.08, 0.07, 0.065)
	root.add_child(nm)
	var sb := fit_text(sub, 1.4, 0.11, INK, CREAM)
	sb.position = Vector3(-0.08, -0.11, 0.065)
	root.add_child(sb)
	var j := fit_text("JOIN" if can_join else "WAIT", 0.55, 0.16)
	j.position = Vector3(1.01, 0, 0.07)
	root.add_child(j)
	# The avatar disc: the name's first letter on it until Steam's picture comes.
	var initial := poster_text(name_s.left(1), 0.2, INK, CREAM, 0.02)
	initial.position = Vector3(-1.1, 0, 0.065)
	initial.name = "initial"
	root.add_child(initial)
	root.set_meta("avatar", k.find_child("friend_avatar", true, false))
	root.set_meta("width", 3.0)
	root.set_meta("height", 0.56)
	root.set_meta("stop_x", [-0.3, 1.01])
	root.set_meta("focus_nodes", rings)
	return _scale_row(root, ROW_SCALE)


## E1: a Browse row: name + mode, count, and JOIN / FULL / OLDER.
static func lobby_row(name_s: String, mode_s: String, count_s: String, join_s: String, can_join: bool) -> Node3D:
	var k := kit_model("lobby_row")
	var root := Node3D.new()
	if k == null:
		k = _plate(3.2, 0.44, Color("#1E2C5C"))
	root.add_child(k)
	var rings := _focus_rings(k, ["lobby_row_focus", "lobby_join_focus"])
	if not can_join:
		tint_part(k, "lobby_join_face", GREY)
	var nm := fit_text(name_s, 1.9, 0.16, RED, INK)
	nm.position = Vector3(-0.5, 0.07, 0.06)
	root.add_child(nm)
	var md := fit_text(mode_s, 1.9, 0.11, INK, CREAM)
	md.position = Vector3(-0.5, -0.11, 0.06)
	root.add_child(md)
	var ct := fit_text(count_s, 0.38, 0.16)
	ct.position = Vector3(0.78, 0, 0.065)
	root.add_child(ct)
	var j := fit_text(join_s, 0.42, 0.13)
	j.position = Vector3(1.265, 0, 0.065)
	root.add_child(j)
	root.set_meta("width", 3.2)
	root.set_meta("height", 0.54)
	root.set_meta("stop_x", [-0.3, 1.265])
	root.set_meta("focus_nodes", rings)
	return _scale_row(root, ROW_SCALE)


## E3: the READY badge; grey seal and WAIT when not ready.
static func ready_stamp(ready: bool) -> Node3D:
	var k := kit_model("ready_stamp")
	var root := Node3D.new()
	if k == null:
		k = _plate(0.68, 0.2, TURQUOISE)
	root.add_child(k)
	if not ready:
		tint_part(k, "ready_seal", GREY)
	var t := fit_text("READY" if ready else "WAIT", 0.62, 0.13, RED, CREAM)
	t.position = Vector3(0, 0, 0.07)
	root.add_child(t)
	return root


## E4: a chat bubble, speaker over message (mirror = tail on the right).
static func chat_bubble(who: String, text: String, mirror := false) -> Node3D:
	var k := kit_model("chat_bubble")
	var root := Node3D.new()
	if k == null:
		k = _plate(1.8, 0.5, CREAM)
	if mirror:
		k.scale.x = -1.0
	root.add_child(k)
	if who != "":
		var w := fit_text(who, 1.5, 0.14, RED, INK)
		w.position = Vector3(0, 0.11, 0.06)
		root.add_child(w)
	var t := fit_text(text, 1.55, 0.17, INK, CREAM)
	t.position = Vector3(0, -0.08 if who != "" else 0.0, 0.06)
	root.add_child(t)
	return root


## E8 / E5: the status sign (a few lines) and ribbon (one short line).
static func sign_board() -> Node3D:
	var k := kit_model("sign_board")
	return k if k != null else _plate(2.4, 0.6, RED)


static func status_ribbon() -> Node3D:
	var k := kit_model("status_ribbon")
	return k if k != null else _plate(3.4, 0.4, Color("#1E2C5C"))


## E7: the < > cue beside a picker; points +X (dir -1 turns it round).
static func picker_arrow(dir := 1) -> Node3D:
	var k := kit_model("picker_arrow")
	if k == null:
		k = star_mesh(0.14, GOLD) as Node3D
	var root := Node3D.new()
	root.add_child(k)
	if dir < 0:
		root.rotation.z = PI
	return root
