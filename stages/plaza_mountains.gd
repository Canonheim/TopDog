class_name PlazaMountains
extends RefCounted
## THE MOUNTAINS (the TD Environment Maker, 2026-11-10). Parker: "we want to replace the
## cardboard mountains with slightly more modeled ones". Low-poly ranges behind
## the plaza, where the cardboard flats stood: each a faceted massif of a few peaks on a
## ridgeline, built from big flat planes (a coarse height field), three rock tones so
## neighbouring faces never read alike. Behind them, at the left, the Peak of DeGayo
## (the solo mode's mountain: see THE PEAK OF DEGAYO below), the only snow in view. Simple
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
## The row stands well under the Peak of DeGayo (below): it is the great mountain, these
## are its foothills.
const RANGES := [
	[-30.0, -262.0, 200.0, 46.0, 72.0, 0.2, 11, Color("#666D8E"), Color("#7781AB"), Color("#585E8C"), 0.55],
	[120.0, -244.0, 280.0, 50.0, 66.0, -0.24, 23, Color("#666D8E"), Color("#7781AB"), Color("#585E8C"), 0.2],
	[-20.0, -206.0, 240.0, 38.0, 50.0, -0.12, 37, Color("#5F6688"), Color("#6B759F"), Color("#4C5280"), 0.75],
	# a peak to the right of the church, so both sides of it are framed
	[52.0, -232.0, 150.0, 40.0, 52.0, -0.1, 53, Color("#646B8C"), Color("#737DA7"), Color("#545A88"), 0.45],
]
const SNOW := Color("#E8EDF6")
const SNOW_SHADE := Color("#B4BFDA")
const SNOW_LINE := 0.7  # snow on the top 30% of the peaks (each apex is a grid vertex, so the tops are pointed)
const SNOW_JAG := 0.07
const COLS := 15  # the height field: few columns and rows, so the faces are big planes
const ROWS := 7  # odd, so a middle row runs along the ridge


## Build the foothill ranges and the Peak under `parent`, standing on ground_y.
static func build(parent: Node3D, ground_y: float) -> Array:
	var out: Array = []
	for r in RANGES:
		# No snow on the row: the snow line is the Peak's (its glacier's foot, 140 m up
		# at this scale), far above these.
		var mi := massif(float(r[2]), float(r[3]), float(r[4]), int(r[6]), r[7], r[8], r[9], false, float(r[10]))
		mi.position = Vector3(float(r[0]), ground_y - 0.6, float(r[1]))
		mi.rotation.y = float(r[5])
		parent.add_child(mi)
		out.append([mi, mi.position.y, float(r[3]) + 3.0])
	var pk := peak()
	pk.position = Vector3(PEAK_AT.x, ground_y - 1.0, PEAK_AT.z)
	parent.add_child(pk)
	out.append([pk, pk.position.y, PEAK_H + 40.0])
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


# ================================================================ THE PEAK OF DEGAYO
## Parker (11-11): "To the left of the town there is a great mountain called the Peak of
## DeGayo." The solo mode's mountain, seen from the plaza and the title screen: one great
## faceted peak far behind the foothill row, at the left of the view. Its outline is the
## course's own cross-section (tools/peak/areas/st.py, EAST and WEST, in the course's
## local metres), so what the player sees from town is what they climb: the bare slope,
## El Colmillo (the rock fang) standing off the east face with La Garganta between, the
## cableway's thread across to it, the snow head, the storm snagged on the ridge under
## the summit, the mine mouth at the foot.
##
## It is a model of the mountain, not the mountain: 1,000 m shown as PEAK_H, and twice
## as wide as true (a spire that thin read as a pole from the plaza), the fang thicker
## still. `peak_flag(on)` shows the flag on its summit; `peak_shown(on)` hides the whole
## model (the solo mode stands at the real mountain's foot, and must not see this one).
const PEAK_AT := Vector3(-300.0, 0.0, -700.0)  # the summit's x, and how far back it stands
const PEAK_H := 178.0  # the 1,000 m, in the plaza's metres
const PEAK_WIDE := 2.0
## The course's outline from the summit down each side: [local x, local y].
const PEAK_EAST := [[-350, 1000], [-334, 962], [-307, 884], [-281, 784], [-251, 684], [-230, 578], [-177, 400],
	[-150, 322], [-130, 260], [-90, 150], [-60, 60], [-34, 5.5], [-16, -40]]
const PEAK_WEST := [[-350, 1000], [-372, 950], [-430, 800], [-520, 550], [-620, 250], [-700, 0], [-714, -40]]
const PEAK_LEVELS := [1000.0, 968.0, 930.0, 890.0, 845.0, 792.0, 740.0, 690.0, 630.0, 578.0, 500.0, 400.0, 322.0,
	260.0, 190.0, 120.0, 60.0, 10.0, -30.0]
const PEAK_SNOW_ROW := 7  # the level the snow line zigzags along: the top third is white
const PEAK_COLS := 13  # west outline, five faces, the front arete, five faces, east outline
## Two broad sides and a turn between them: the sunlit east a pale rose stone, the west in
## the foothills' violet shadow. (Albedos: a steep sunlit face draws about 1.3x brighter.)
const PEAK_LIT := Color("#AC9E8E")
const PEAK_MID := Color("#988C92")
const PEAK_SHADE := Color("#807684")
const PEAK_SNOW_SHADE := Color("#8F9DC6")
const FANG_LIT := Color("#9C8E84")
const FANG_SHADE := Color("#6E6478")
const FANG_MID := Color("#85798A")
const STORM_DARK := Color("#3C4159")
const STORM_LIGHT := Color("#61677F")
const BOLT := Color("#FFE600")
const CABLE := Color("#2E2A2C")
const STEEL_RED := Color("#D8392B")
const CREAM_HUT := Color("#EFE3C6")
const MINE_DARK := Color("#1E1A22")
const SPOIL := Color("#C9B79A")
const TIMBER := Color("#C9903F")
const FLAG_RED := Color("#E0241B")
const FLAG_GOLD := Color("#FFE033")

static var _peak: Node3D = null
static var _flag: Node3D = null


## The flag on the Peak's summit: the game shows it once the player has climbed it.
static func peak_flag(on: bool) -> void:
	if is_instance_valid(_flag):
		_flag.visible = on


## Show or hide the whole model of the Peak. (LuchaUI.mountains_down also sets a
## mountain's `visible` while it moves one: call this after it has settled.)
static func peak_shown(on: bool) -> void:
	if is_instance_valid(_peak):
		_peak.visible = on


## A point of the course (local x, y) on the model, z metres toward the camera.
static func _pm(lx: float, ly: float, z := 0.0) -> Vector3:
	var k := PEAK_H / 1000.0
	return Vector3((lx + 350.0) * k * PEAK_WIDE, ly * k, z)


## The outline's x at height y (the line runs from the summit down).
static func _x_at(line: Array, y: float) -> float:
	for i in line.size() - 1:
		var a: Array = line[i]
		var b: Array = line[i + 1]
		if y >= float(b[1]):
			return lerpf(float(a[0]), float(b[0]), clampf((float(a[1]) - y) / (float(a[1]) - float(b[1])), 0.0, 1.0))
	return float(line[line.size() - 1][0])


## How far the body's front stands toward the camera at a point of the course (the
## half cone, without its ribs): where to hang a thing on the face.
static func _front_z(lx: float, ly: float) -> float:
	var xe := _x_at(PEAK_EAST, ly)
	var xw := _x_at(PEAK_WEST, ly)
	var sn := clampf((lx - (xe + xw) * 0.5) / maxf((xe - xw) * 0.5, 0.01), -1.0, 1.0)
	return 0.7 * (xe - xw) * 0.5 * sqrt(1.0 - sn * sn) * PEAK_H / 1000.0 * PEAK_WIDE


## A point on the face, `out` metres proud of it.
static func _on_face(lx: float, ly: float, out := 1.0) -> Vector3:
	return _pm(lx, ly, _front_z(lx, ly) + out)


## The Peak, origin on the ground under its summit.
static func peak() -> Node3D:
	var root := Node3D.new()
	root.name = "PeakOfDeGayo"
	_peak = root
	var rng := RandomNumberGenerator.new()
	rng.seed = 1000
	var sts: Array = []  # rock lit, mid, shade; snow, snow shade; the fang's lit and shade
	for k in 8:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		sts.append(st)
	# The body: half a cone on the outline. Each level is a half ring from the west
	# outline round the front to the east outline. The middle column is the arete that
	# comes down toward the camera: everything east of it is the sunlit side, everything
	# west the shaded side, and a face only takes the middle tone where a rib turns it
	# the other way. Two broad sides, a few turned planes: not a patchwork.
	var kz := PEAK_H / 1000.0 * PEAK_WIDE
	var mid := PEAK_COLS / 2
	var wander := 0.0
	var grid: Array = []
	for r in PEAK_LEVELS.size():
		var row: Array = []
		wander = clampf(wander + rng.randf_range(-0.1, 0.1), -0.2, 0.2)
		for c in PEAK_COLS:
			var y: float = PEAK_LEVELS[r]
			var inner := c > 0 and c < PEAK_COLS - 1
			var last := r == PEAK_LEVELS.size() - 1
			if r == 0:
				row.append(_pm(-350.0, 1000.0))
				continue
			if r == PEAK_SNOW_ROW:
				y += (-30.0 if c % 2 == 1 else 26.0) + rng.randf_range(-7.0, 7.0)
			elif not last:
				y += rng.randf_range(-10.0, 10.0) if inner else rng.randf_range(-4.0, 4.0)
			var xe := _x_at(PEAK_EAST, y)
			var xw := _x_at(PEAK_WEST, y)
			var u := float(c) / (PEAK_COLS - 1) * 2.0 - 1.0
			var sn := sin(u * PI * 0.5)
			var z := 0.0
			if inner:
				sn = clampf(sn + (wander + rng.randf_range(-0.03, 0.03)) * (1.0 - sn * sn), -0.97, 0.97)
				var rib := 1.0
				if c == mid:
					rib = 1.1
				elif c == 3 or c == PEAK_COLS - 4:
					rib = 1.2  # one buttress each side
				elif c % 2 == 1:
					rib = 0.95
				z = 0.7 * (xe - xw) * 0.5 * cos(u * PI * 0.5) * rib * rng.randf_range(0.96, 1.04) * kz
			row.append(_pm(lerpf(xw, xe, 0.5 + 0.5 * sn), y, z))
		grid.append(row)
	for r in PEAK_LEVELS.size() - 1:
		for c in PEAK_COLS - 1:
			var a: Vector3 = grid[r][c]
			var b: Vector3 = grid[r][c + 1]
			var d: Vector3 = grid[r + 1][c + 1]
			var e: Vector3 = grid[r + 1][c]
			var tris := [[a, b, d], [a, d, e]] if a.y + d.y >= b.y + e.y else [[a, b, e], [b, d, e]]
			for t in tris:
				var n := _front_normal(t[0], t[1], t[2])
				var east := c >= mid
				var k := 0 if east else 2
				if c == PEAK_COLS - 5 or c == 3:
					k = 1  # the buttress's far flank: one long plane in the middle tone, a spur
				elif (east and n.x < -0.2) or (not east and n.x > 0.2):
					k = 1
				if r < PEAK_SNOW_ROW:
					k = 3 if east else 4
				_ptri(sts[k], t[0], t[1], t[2])
	# El Colmillo: the rock fang standing on the east slope, far thicker than true so it
	# reads as a tooth and not a pole, in a darker stone so it stands off the face.
	# [local y, centre x, half width]
	# Three faces round its front (sunlit, turned, shaded), a kink half way up, and a
	# chipped tip: the point stands east of a lower broken shoulder.
	var fang := [[290.0, -158.0, 50.0, 0.0], [440.0, -168.0, 35.0, 0.1], [575.0, -164.0, 23.0, -0.15], [668.0, -168.0, 13.0, 0.1], [700.0, -166.0, 8.0, 0.0]]
	var rings: Array = []
	for f in fang:
		var hw: float = f[2]
		var dz: float = hw * kz * 0.55
		var cx: float = f[1]
		var y: float = f[0]
		var skew: float = float(f[3]) * hw
		rings.append([_pm(cx + hw, y, 0.6), _pm(cx + hw * 0.4 + skew, y + 6.0, 0.6 + dz), _pm(cx - hw * 0.45 + skew, y - 5.0, 0.6 + dz * 0.8), _pm(cx - hw, y, 0.6)])
	for k in rings.size() - 1:
		for side in 3:
			var fs: SurfaceTool = sts[[5, 7, 6][side]]
			_ptri(fs, rings[k][side], rings[k][side + 1], rings[k + 1][side + 1])
			_ptri(fs, rings[k][side], rings[k + 1][side + 1], rings[k + 1][side])
	var crown: Array = rings[rings.size() - 1]
	var tip_pt := _pm(-161.0, 729.0, 0.6)
	var chip := _pm(-171.0, 707.0, 0.6)
	_ptri(sts[5], crown[0], crown[1], tip_pt)
	_ptri(sts[7], crown[1], crown[2], tip_pt)
	_ptri(sts[6], crown[2], chip, tip_pt)
	_ptri(sts[6], crown[2], crown[3], chip)
	var mesh := ArrayMesh.new()
	var cols := [PEAK_LIT, PEAK_MID, PEAK_SHADE, SNOW, PEAK_SNOW_SHADE, FANG_LIT, FANG_SHADE, FANG_MID]
	for k in sts.size():
		var before := mesh.get_surface_count()
		(sts[k] as SurfaceTool).commit(mesh)
		if mesh.get_surface_count() > before:
			mesh.surface_set_material(mesh.get_surface_count() - 1, LuchaKit.mat(cols[k]))
	var body := MeshInstance3D.new()
	body.name = "Body"
	body.mesh = mesh
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	CelPass.unify(body)
	root.add_child(body)
	_peak_dress(root)
	return root


## What stands on the Peak: the cableway, the storm, the mine mouth, the flag.
static func _peak_dress(root: Node3D) -> void:
	# The cableway: one taut line from the fang's top up to the high station on the
	# face, two cars hanging from it, a hut at each end.
	var tip := _pm(-161.0, 730.0, 2.2)
	var high := _pm(_x_at(PEAK_EAST, 786.0) - 5.0, 786.0, 2.2)
	var pts := PackedVector3Array()
	for i in 9:
		var t := float(i) / 8.0
		pts.append(tip.lerp(high, t) - Vector3(0, 1.1 * sin(t * PI), 0))
	root.add_child(_thread(pts, 0.34, CABLE))
	for t in [0.3, 0.68]:
		var at: Vector3 = tip.lerp(high, t) - Vector3(0, 1.1 * sin(t * PI), 0)
		root.add_child(_pbox(Vector3(0.45, 2.6, 0.45), CABLE, at + Vector3(0, -1.3, 0)))
		root.add_child(_pbox(Vector3(3.4, 2.6, 1.8), STEEL_RED, at + Vector3(0, -3.8, 0)))
		root.add_child(_pbox(Vector3(3.7, 0.6, 2.0), CREAM_HUT, at + Vector3(0, -2.5, 0)))
	for hut in [high + Vector3(-1.0, 0, 0), tip + Vector3(0, -1.6, 0)]:
		var hp: Vector3 = hut
		root.add_child(_pbox(Vector3(5.0, 3.2, 2.4), CREAM_HUT, hp + Vector3(0, 0.0, -0.6)))
		root.add_child(_pbox(Vector3(6.0, 1.0, 3.0), STEEL_RED, hp + Vector3(0, 2.1, -0.6)))
	# The storm: a cut-out cloud wrapped across the ridge under the summit (the course's
	# Cresta de la Tormenta, y 884 to 966), the horn standing clear above it. A dark card
	# with a paler one behind, and one cardboard bolt.
	var storm := Node3D.new()
	storm.name = "Storm"
	storm.position = _pm(-322.0, 822.0, _front_z(-350.0, 822.0) + 5.0)
	root.add_child(storm)
	var back := _card(_cloud_pts(86.0, 17.0, 7, 3), STORM_LIGHT)
	back.position = Vector3(4.0, 2.6, -0.8)
	storm.add_child(back)
	var front := _card(_cloud_pts(76.0, 11.5, 6, 9), STORM_DARK)
	storm.add_child(front)
	var bolt := _card(PackedVector2Array([Vector2(0.0, 0.0), Vector2(3.2, 0.0), Vector2(1.2, -5.0), Vector2(3.6, -5.0),
		Vector2(-1.6, -13.5), Vector2(-0.2, -7.0), Vector2(-2.4, -7.0)]), BOLT)
	bolt.scale = Vector3(1.3, 1.6, 1.3)
	bolt.position = Vector3(8.0, -2.5, 1.0)
	bolt.rotation = Vector3(deg_to_rad(-34.0), deg_to_rad(35.0), 0.0)  # faced to the sun: a card square to the camera draws at 0.6 of its yellow
	storm.add_child(bolt)
	for n in [back, front, bolt]:
		(n as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# The mine mouth on the east slope's foot: a dark arch in a timber set, the pale
	# spoil fanned out below it.
	var mlx := _x_at(PEAK_EAST, 52.0) - 62.0
	var foot := _on_face(mlx, 52.0, 0.4)
	var arch := PackedVector2Array([Vector2(-4.0, 0.0), Vector2(4.0, 0.0), Vector2(4.0, 6.0)])
	for i in 7:
		var ang := float(i) / 6.0 * PI
		arch.append(Vector2(cos(ang) * 4.0, 6.0 + sin(ang) * 4.0))
	arch.append(Vector2(-4.0, 6.0))
	var hole := _card(arch, MINE_DARK)
	hole.position = foot
	root.add_child(hole)
	for sx in [-5.0, 5.0]:
		root.add_child(_pbox(Vector3(1.3, 11.5, 1.3), TIMBER, foot + Vector3(sx, 5.2, 1.4)))
	root.add_child(_pbox(Vector3(13.0, 1.5, 1.5), TIMBER, foot + Vector3(0, 11.4, 1.4)))
	var fan := _card(PackedVector2Array([Vector2(-4.5, 0.0), Vector2(4.5, 0.0), Vector2(12.0, -12.0), Vector2(-8.0, -12.0)]), SPOIL)
	fan.position = foot + Vector3(0, 0, 3.4)
	fan.rotation.x = deg_to_rad(-22.0)
	root.add_child(fan)
	for n in [hole, fan]:
		(n as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# The flag: a pole on the summit and a swallowtail banner, hidden until the player
	# has rung the bell.
	var flag := Node3D.new()
	flag.name = "SummitFlag"
	flag.position = _pm(-350.0, 1000.0, 0.5)
	flag.add_child(_pbox(Vector3(0.6, 13.0, 0.6), TIMBER, Vector3(0, 6.0, 0)))
	var cloth := _card(PackedVector2Array([Vector2(0, 0), Vector2(12.0, 0), Vector2(9.0, -3.0), Vector2(12.0, -6.0), Vector2(0, -6.0)]), FLAG_RED)
	cloth.position = Vector3(0.3, 12.4, 0.0)
	flag.add_child(cloth)
	var star := PackedVector2Array()
	for i in 10:
		var ang := PI * 0.5 + float(i) * TAU / 10.0
		star.append(Vector2(cos(ang), sin(ang)) * (2.2 if i % 2 == 0 else 0.95))
	var badge := _card(star, FLAG_GOLD)
	badge.position = Vector3(4.4, 9.4, 0.15)
	flag.add_child(badge)
	for n in [cloth, badge]:
		(n as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	flag.rotation.y = deg_to_rad(30.0)  # flying toward the sun, so its colours stay bright
	flag.visible = false
	root.add_child(flag)
	_flag = flag


## A triangle's normal, turned toward the camera.
static func _front_normal(a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	var n := (b - a).cross(c - a)
	if n.length() < 0.0001:
		return Vector3.BACK
	n = n.normalized()
	return n if n.z >= 0.0 else -n


## One flat-shaded triangle, facing the camera, into a surface.
static func _ptri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	if (b - a).cross(c - a).length() < 0.0001:
		return
	var n := _front_normal(a, b, c)
	if (b - a).cross(c - a).dot(n) > 0.0:
		var t := b
		b = c
		c = t
	for v in [a, b, c]:
		st.set_normal(n)
		st.add_vertex(v)


## A flat cut-out card on an outline, facing the camera (+z), with its normal that way
## too, so the sun lights it. (LuchaKit._extrude shows a far cut-out its unlit side.)
static func _card(pts: PackedVector2Array, col: Color) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tris := Geometry2D.triangulate_polygon(pts)
	for k in range(0, tris.size(), 3):
		_ptri(st, Vector3(pts[tris[k]].x, pts[tris[k]].y, 0.0), Vector3(pts[tris[k + 1]].x, pts[tris[k + 1]].y, 0.0), Vector3(pts[tris[k + 2]].x, pts[tris[k + 2]].y, 0.0))
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	CelPass.paint(mi, col)
	return mi


## A flat ribbon along `pts`, `thick` wide, facing the camera: a cable.
static func _thread(pts: PackedVector3Array, thick: float, col: Color) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3(0, 0, 1))
	for i in pts.size() - 1:
		var a := pts[i]
		var b := pts[i + 1]
		if b.x < a.x:
			var sw := a
			a = b
			b = sw
		var side := Vector3(-(b.y - a.y), b.x - a.x, 0.0).normalized() * thick * 0.5  # up, for a run to the right
		for v in [a + side, b + side, b - side, a + side, b - side, a - side]:
			st.add_vertex(v)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	CelPass.paint(mi, col)
	return mi


static func _pbox(size: Vector3, col: Color, at: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = at
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	CelPass.paint(mi, col)
	return mi


## A cut-out cloud's outline, origin at the middle of its bottom: `lobes` round bumps
## along the top, taller in the middle, and smaller ones hanging along the bottom.
static func _cloud_pts(w: float, h: float, lobes: int, seed: int) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var pts := PackedVector2Array()
	var under := lobes + 2
	for i in under:  # the bottom, left to right
		var cx := (float(i) + 0.5) / under * w - w * 0.5
		var r := w * 0.5 / under
		var sag := h * rng.randf_range(0.1, 0.22)
		for k in 5:
			var ang := PI + float(k) / 4.0 * PI
			pts.append(Vector2(cx + cos(ang) * r, sin(ang) * sag))
	for i in lobes:  # the top, right to left
		var f := 1.0 - (float(i) + 0.5) / lobes
		var cx := (f - 0.5) * w * 0.92
		var r := w * 0.5 / lobes * 1.25
		var top := h * (0.45 + 0.55 * sin(f * PI)) * rng.randf_range(0.85, 1.1)
		for k in 5:
			var ang := (float(k) + 0.5) / 5.0 * PI
			pts.append(Vector2(cx + cos(ang) * r, maxf(0.6, top - r + sin(ang) * r)))
	return pts
