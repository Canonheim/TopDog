class_name PlazaMountains
extends RefCounted
## THE MOUNTAINS (the TD Environment Maker, 2026-11-10). Parker: "we want to replace the
## cardboard mountains with slightly more modeled ones". Three low-poly ranges behind
## the plaza, where the cardboard flats stood: each a faceted massif of a few peaks on a
## ridgeline, built from big flat planes (a coarse height field), three rock tones so
## neighbouring faces never read alike, and jagged snow caps on the main peaks. Simple
## shapes in the house cel look, not a realistic range. They sit back by colour (no fog
## in the look): haze blues, the far ones paler.
##
## The plaza calls `PlazaMountains.build(parent, ground_y)` once from _build_plaza. It
## returns [node, standing y, how far it sinks] per mountain, the shape
## LuchaUI.mountains_down() wants (Parker's option B: they sink out of sight for Del
## Mar). Each is one mesh on the one atlas material, casting no shadow.
##
## `massif()` is the shape on its own (Del Mar's far hills use it, without snow).

## [x, z, width, height, depth, yaw, seed, lit, mid, shade, main peak along the range (0..1)]
const RANGES := [
	[-140.0, -262.0, 300.0, 80.0, 72.0, 0.2, 11, Color("#929CC0"), Color("#7781AB"), Color("#585E8C"), 0.62],
	[120.0, -244.0, 280.0, 82.0, 66.0, -0.24, 23, Color("#929CC0"), Color("#7781AB"), Color("#585E8C"), 0.2],
	[-20.0, -206.0, 240.0, 50.0, 50.0, -0.12, 37, Color("#8590B6"), Color("#6B759F"), Color("#4C5280"), 0.75],
	# a peak to the right of the church, so both sides of it are framed
	[52.0, -232.0, 150.0, 68.0, 52.0, -0.1, 53, Color("#8E98BD"), Color("#737DA7"), Color("#545A88"), 0.45],
]
const SNOW := Color("#E8EDF6")
const SNOW_SHADE := Color("#B4BFDA")
const SNOW_LINE := 0.7  # snow on the top 30% of the peaks (each apex is a grid vertex, so the tops are pointed)
const SNOW_JAG := 0.07
const COLS := 15  # the height field: few columns and rows, so the faces are big planes
const ROWS := 7  # odd, so a middle row runs along the ridge


## Build the three ranges under `parent`, standing on ground_y.
static func build(parent: Node3D, ground_y: float) -> Array:
	var out: Array = []
	for r in RANGES:
		var mi := massif(float(r[2]), float(r[3]), float(r[4]), int(r[6]), r[7], r[8], r[9], true, float(r[10]))
		mi.position = Vector3(float(r[0]), ground_y - 0.6, float(r[1]))
		mi.rotation.y = float(r[5])
		parent.add_child(mi)
		out.append([mi, mi.position.y, float(r[3]) + 3.0])
	return out


## One massif, origin at its base centre: a height field of peaks along a ridgeline,
## each a faceted pyramid, cut into flat-shaded triangles in up to five one-colour
## surfaces (rock lit, mid and shade by which way a face looks; snow and snow shade),
## then put on the one material. `main_at` places the tallest peak along the width.
static func massif(w: float, h: float, d: float, seed: int, lit: Color, mid: Color, shade: Color, snow_on := false, main_at := 0.5) -> MeshInstance3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var peaks: Array = []  # [x, z, height, half-width, half-depth]
	var n := 3 + rng.randi() % 2
	for i in n:
		var px := lerpf(-w * 0.4, w * 0.4, (float(i) + rng.randf_range(-0.2, 0.2)) / (n - 1))
		var ph := h * rng.randf_range(0.5, 0.74)
		peaks.append([px, rng.randf_range(-d * 0.1, d * 0.1), ph, ph * rng.randf_range(1.5, 2.0), d * rng.randf_range(0.42, 0.52)])
	peaks.append([lerpf(-w * 0.5, w * 0.5, main_at), 0.0, h, h * 1.45, d * 0.5])  # the main peak
	# Each peak's apex is a vertex of the grid (the column nearest it slides onto it, in
	# the middle row), so the summits come to points instead of being cut flat.
	var apex_col := {}
	for p in peaks:
		var ci := int(round((float(p[0]) / w + 0.5) * (COLS - 1)))
		if ci > 0 and ci < COLS - 1:
			apex_col[ci] = float(p[0])
	var grid: Array = []
	for j in ROWS:
		var row: Array = []
		for i in COLS:
			var edge := i == 0 or i == COLS - 1 or j == 0 or j == ROWS - 1
			var x := lerpf(-w * 0.5, w * 0.5, float(i) / (COLS - 1)) + (0.0 if edge else rng.randf_range(-0.18, 0.18) * w / COLS)
			var z := lerpf(-d * 0.5, d * 0.5, float(j) / (ROWS - 1)) + (0.0 if edge else rng.randf_range(-0.15, 0.15) * d / ROWS)
			if apex_col.has(i) and not edge:
				x = float(apex_col[i])
				if j == ROWS / 2:
					z = 0.0
			var y := 0.0
			for p in peaks:
				var dx := absf(x - float(p[0])) / float(p[3])
				var dz := absf(z - float(p[1])) / float(p[4])
				var t := 1.0 - maxf(dx, dz * 0.85 + dx * 0.15)
				if t > 0.0:
					y = maxf(y, float(p[2]) * pow(t, 1.25))
			row.append(Vector3(x, -2.0 if edge else y, z))
		grid.append(row)
	var sts: Array = []
	for k in 5:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		sts.append(st)
	for j in ROWS - 1:
		for i in COLS - 1:
			var a: Vector3 = grid[j][i]
			var b: Vector3 = grid[j][i + 1]
			var c: Vector3 = grid[j + 1][i + 1]
			var e: Vector3 = grid[j + 1][i]
			# Split each cell along whichever diagonal keeps the ridge (the higher pair).
			var tris := [[a, b, c], [a, c, e]] if a.y + c.y >= b.y + e.y else [[a, b, e], [b, c, e]]
			for t in tris:
				var jag := SNOW_JAG * h * sin(float(i) * 2.3 + float(j) * 1.7 + float(seed))
				_face(sts, t[0], t[1], t[2], h, snow_on, h * SNOW_LINE + jag)
	var mesh := ArrayMesh.new()
	var cols := [lit, mid, shade, SNOW, SNOW_SHADE]
	for k in 5:
		var before := mesh.get_surface_count()
		(sts[k] as SurfaceTool).commit(mesh)
		if mesh.get_surface_count() > before:
			mesh.surface_set_material(mesh.get_surface_count() - 1, LuchaKit.mat(cols[k]))
	var mi := MeshInstance3D.new()
	mi.name = "Massif"
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	CelPass.unify(mi)
	return mi


## One flat-shaded triangle into the surface its way of looking picks: rock lit (toward
## the sun on the right and up), mid (toward the camera), shade (away); snow above the
## jagged snow line unless it's a cliff.
static func _face(sts: Array, a: Vector3, b: Vector3, c: Vector3, h: float, snow_on: bool, snow_y: float) -> void:
	var n := (b - a).cross(c - a)
	if n.length() < 0.0001:
		return
	n = n.normalized()
	if n.y < 0.0:
		n = -n
	var mid_y := (a.y + b.y + c.y) / 3.0
	var k := 1
	if n.x > 0.18:
		k = 0
	elif n.x < -0.12:
		k = 2
	if snow_on and mid_y > snow_y and n.y > 0.35:
		k = 3 if k != 2 else 4
	var st: SurfaceTool = sts[k]
	if (b - a).cross(c - a).dot(n) > 0.0:
		var t := b
		b = c
		c = t
	for v in [a, b, c]:
		st.set_normal(n)
		st.add_vertex(v)
