class_name PeakBackdrop
extends Node3D
## THE PEAK'S BACKDROP (the TD Environment Maker, 2026-11-12): what is far behind the solo
## climb, in the course's local metres (docs/peak/PEAK_DESIGN.md, section 7).
##
##   var backdrop := PeakBackdrop.build(parent, Peak.ORIGIN)   # once
##   backdrop.tick(delta, cam)                                  # every frame
##
## `origin` is the trailhead in the WORLD: the backdrop sets its own place to it
## (top-level), so `parent` can be any node, the Peak itself included.
##
## OUTSIDE (the cliffs up, y 570 and over), all real depth, 1.3 to 3.9 km back, so it
## slides by as a far land should and the climber rises toward the ranges' own height:
##   - a valley floor of fields with a river and a road, the tiny town on it (the kit's
##     `town_far` when it has landed; `town_at()` is where, for the bell's fireworks);
##   - two cardboard ranges on the horizon, the far one snow-capped, and a cardboard sun;
##   - the sea of cloud at y 932: cut-out clouds standing in a white floor that is only
##     drawn from above, so from the cliffs it is a far ceiling of clouds and from the
##     summit it is a sea with the far peaks standing out of it;
##   - the storm's deck, y 872 to 975: dark cut-out clouds close behind the ridge.
## The far land shows while the camera is above OUTSIDE_FROM, or out on the east face
## lower down (a fall down the bare slope), and sinks away toward the trailhead, where
## the plaza's own sky takes over. The clouds show from OUTSIDE_FROM up, and come down
## into place over the next 130 m (inside the chimney, where nobody sees them arrive).
##
## INSIDE: each cavern's deep dark as three card layers (z -18, -36, -60) in the area's
## own back tones, with its own silhouettes (shoring, arches, crystal shards, mushrooms,
## temple steps, pipes), cut to the mountain's outline. NOTE: they stand behind the
## mountain's own card (the course's `st` body card at z -9) and behind any full-room
## back card an area lays, so they only show where those are cut or left out.
##
## Cheap: flat cards on the one atlas material, a few dozen kit clouds, and nothing per
## frame but the clouds' drift and which groups show.

const META := "res://stages/peak/course/_meta.json"
const OUTSIDE_FROM := 430.0  # above this the camera may see out (the chimney's slit, then the cliffs)
const FLOOR_Y := -10.0  # the valley floor
const SEA_Y := 932.0  # the sea of cloud
const TOWN_AT := Vector3(150.0, FLOOR_Y, -3300.0)  # the tiny town (local)
const TOWN_SCALE := 9.0
## The mountain's east face from the summit down: [local x, local y] (tools/peak/areas/st.py).
const EAST := [[-350, 1000], [-334, 962], [-307, 884], [-281, 784], [-251, 684], [-230, 578], [-177, 400],
	[-150, 322], [-130, 260], [-90, 150], [-60, 60], [-34, 5.5], [-16, -40]]
const WEST := [[-372, 950], [-430, 800], [-520, 550], [-620, 250], [-700, 0], [-714, -40]]

## (Albedos: the scene's sun draws a card about 1.3x brighter and bluer than its colour.)
const HAZE_FAR := Color("#A0A6B8")
const HAZE_FAR_SHADE := Color("#8C93A8")
const HAZE_SNOW := Color("#D8DEE8")
const HAZE_MID := Color("#8A8FA0")
const HAZE_MID_SHADE := Color("#787E92")
const HILL := Color("#72866A")
const HILL_SHADE := Color("#61745C")
const FIELDS := [Color("#8E9A76"), Color("#869270"), Color("#9A9E7A"), Color("#A49A7C"), Color("#7C8A6C")]
const RIVER := Color("#86AEC2")
const ROAD := Color("#B4A88C")
const SEA := Color("#A7ABC2")  # (a floor facing the sun draws far brighter: this comes out a pale lavender white)
const SUN := Color("#FFD75A")
const STORM := [Color("#565D6A"), Color("#474E5A"), Color("#5C6470"), Color("#6B7482")]  # the wall, then nearer
## Each cavern: [area id, motif]. Regions and tones come from the course's meta.
const CAVES := [["a1", "mine"], ["a2", "river"], ["a3", "crystal"], ["a4", "fungus"], ["a5", "temple"], ["a6", "chimney"]]
## The course's regions and back tones, should the meta be missing (a test scene).
const FALLBACK := {
	"a1": [[-292, -36, -146, 90], "#6B4A30", "#523824", "#3A2819"],
	"a2": [[-462, 86, -226, 176], "#3F5A63", "#2E454D", "#1F3138"],
	"a3": [[-462, 176, -306, 276], "#55409A", "#3D2C78", "#2A1C58"],
	"a4": [[-294, 264, -182, 376], "#456B40", "#33522F", "#223A20"],
	"a5": [[-440, 364, -306, 484], "#7E5236", "#5E3C28", "#40281B"],
	"a6": [[-294, 476, -214, 588], "#7E3C2A", "#5C2A1E", "#3C1A12"],
}

var _outside: Node3D  # the far land: valley, town, ranges, sun
var _sky: Node3D  # the sea of cloud and the storm's deck
var _caves: Array = []  # [node, Rect2 (the region, grown)]
var _clouds: Array = []  # [node, speed m/s, half width, lo x, hi x]
var _town: Node3D


## Build the backdrop under `parent`; `origin` is the course's (0, 0) in the world.
static func build(parent: Node3D, origin: Vector3) -> PeakBackdrop:
	var b := PeakBackdrop.new()
	b.name = "PeakBackdrop"
	b.top_level = true
	b.position = origin
	parent.add_child(b)
	b._build_outside()
	b._build_caves()
	b._outside.visible = false
	b._sky.visible = false
	return b


## Every frame: which groups show, and the clouds' drift.
func tick(delta: float, cam: Camera3D) -> void:
	if cam == null or _outside == null:
		return
	var p := cam.global_position - position
	var out_face := p.x > _x_at(p.y) - 30.0
	var show := p.y > OUTSIDE_FROM or (out_face and p.y > 40.0)
	_outside.visible = show
	if show:
		# Low on the outer slope the whole far land sinks away, so nothing of it stands
		# behind the plaza by the time a fall reaches the trailhead.
		var low := 0.0
		if p.y <= OUTSIDE_FROM:
			low = 1.0 - smoothstep(40.0, 240.0, p.y)
		_outside.position.y = -1800.0 * low
	_sky.visible = p.y > OUTSIDE_FROM
	if _sky.visible:
		# The clouds hang high out of view at OUTSIDE_FROM and are down in place by the
		# cliffs, so a fall past that height never sees them cut out.
		_sky.position.y = 1100.0 * (1.0 - smoothstep(OUTSIDE_FROM, OUTSIDE_FROM + 130.0, p.y))
		for c in _clouds:
			LuchaKit.drift_cloud(c[0], float(c[1]) * delta, float(c[2]), float(c[3]), float(c[4]), cam)
	var at := Vector2(p.x, p.y)
	for c in _caves:
		(c[0] as Node3D).visible = (c[1] as Rect2).has_point(at)


## Where the tiny town stands, in the world (the bell's fireworks go up from here; they
## need to climb past the sea of cloud, y SEA_Y, to be seen from the summit).
func town_at() -> Vector3:
	return position + TOWN_AT


static func _x_at(y: float) -> float:
	for i in EAST.size() - 1:
		var a: Array = EAST[i]
		var b: Array = EAST[i + 1]
		if y >= float(b[1]):
			return lerpf(float(a[0]), float(b[0]), clampf((float(a[1]) - y) / (float(a[1]) - float(b[1])), 0.0, 1.0))
	return float(EAST[EAST.size() - 1][0])


# ================================================================ outside

func _build_outside() -> void:
	_outside = Node3D.new()
	_outside.name = "Outside"
	add_child(_outside)
	_sky = Node3D.new()
	_sky.name = "Sky"
	add_child(_sky)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7784
	# ---- the valley floor: fields as one flat sheet (the joints are colour only)
	var sts: Array = []
	for k in FIELDS.size():
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_normal(Vector3.UP)
		sts.append(st)
	var x0 := -3600.0
	var z0 := -150.0
	var cell := 130.0
	var nx := 56
	var nz := 29
	var pts: Array = []
	for j in nz + 1:
		var row: Array = []
		for i in nx + 1:
			var edge := i == 0 or i == nx or j == 0 or j == nz
			var jx := 0.0 if edge else rng.randf_range(-36.0, 36.0)
			var jz := 0.0 if edge else rng.randf_range(-36.0, 36.0)
			row.append(Vector3(x0 + i * cell + jx, FLOOR_Y, z0 - j * cell + jz))
		pts.append(row)
	for j in nz:
		for i in nx:
			var st: SurfaceTool = sts[rng.randi() % FIELDS.size()]
			var a: Vector3 = pts[j][i]
			var b: Vector3 = pts[j][i + 1]
			var c: Vector3 = pts[j + 1][i + 1]
			var d: Vector3 = pts[j + 1][i]
			for v in [a, d, c, a, c, b]:  # seen from above
				st.add_vertex(v)
	var floor_mesh := ArrayMesh.new()
	for k in FIELDS.size():
		(sts[k] as SurfaceTool).commit(floor_mesh)
		floor_mesh.surface_set_material(floor_mesh.get_surface_count() - 1, LuchaKit.mat(FIELDS[k]))
	var floor_mi := MeshInstance3D.new()
	floor_mi.name = "Valley"
	floor_mi.mesh = floor_mesh
	floor_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	CelPass.unify(floor_mi)
	_outside.add_child(floor_mi)
	# ---- a river across it, and the road from the mountain's foot to the town
	var river := PackedVector3Array()
	for i in 15:
		var t := float(i) / 14.0
		river.append(Vector3(lerpf(-2900.0, 3100.0, t) + sin(t * 9.0) * 160.0, FLOOR_Y + 1.5, lerpf(-1500.0, -3850.0, t) + sin(t * 5.3 + 1.0) * 220.0))
	_outside.add_child(_ribbon(river, 44.0, RIVER))
	var road := PackedVector3Array()
	for i in 9:
		var t := float(i) / 8.0
		road.append(Vector3(lerpf(-420.0, TOWN_AT.x, t) + sin(t * 6.0) * 90.0, FLOOR_Y + 2.5, lerpf(-1300.0, TOWN_AT.z + 40.0, t)))
	_outside.add_child(_ribbon(road, 11.0, ROAD))
	# ---- low green hills on the floor (under the line of sight to the town)
	var hill_polys: Array = []
	var hill_shade: Array = []
	var hx := -3300.0
	while hx < 3300.0:
		var w := rng.randf_range(260.0, 520.0)
		var h := rng.randf_range(55.0, 110.0)
		if absf(hx + w * 0.5 - TOWN_AT.x) > 420.0:
			hill_polys.append(_mound(hx, w, h, FLOOR_Y))
			hill_shade.append(PackedVector2Array([Vector2(hx, FLOOR_Y), Vector2(hx + w * 0.42, FLOOR_Y + h), Vector2(hx + w * 0.3, FLOOR_Y)]))
		hx += w * rng.randf_range(0.7, 1.5)
	_outside.add_child(_cards(hill_polys, -2350.0, HILL))
	_outside.add_child(_cards(hill_shade, -2348.0, HILL_SHADE))
	# ---- the tiny town
	_town = LuchaKit.kit_model("town_far")
	if _town == null:
		_town = _stand_in_town()
	_town.name = "TownFar"
	_town.scale = Vector3.ONE * TOWN_SCALE
	_town.position = TOWN_AT
	_outside.add_child(_town)
	# ---- the ranges on the horizon: the far one high and snow-capped, a lower one before it
	# (low: from the cliffs the climber looks DOWN on them; only a few far giants stand as
	# high as the summit, and those are the peaks that rise out of the sea of cloud)
	_range(-3620.0, 170.0, 400.0, 15, 0, HAZE_MID, HAZE_MID_SHADE, false, rng)
	_range(-3880.0, 400.0, 700.0, 12, 4, HAZE_FAR, HAZE_FAR_SHADE, true, rng)
	# ---- a cardboard sun, low over the far range
	var sun_pts := PackedVector2Array()
	for i in 24:
		var ang := float(i) / 24.0 * TAU
		sun_pts.append(Vector2(cos(ang), sin(ang)) * (230.0 if i % 2 == 0 else 150.0))
	var sun := _cards([sun_pts], -3930.0, SUN)
	sun.position = Vector3(1500.0, 1560.0, 0.0)
	sun.name = "Sun"
	_outside.add_child(sun)
	# ---- the sea of cloud: a white floor drawn only from above, and cut-out clouds
	# standing in it, row behind row, each row sized to its distance
	var sea := MeshInstance3D.new()
	var sst := SurfaceTool.new()
	sst.begin(Mesh.PRIMITIVE_TRIANGLES)
	sst.set_normal(Vector3.UP)
	var s0 := Vector3(-3600.0, SEA_Y, -150.0)
	var s1 := Vector3(3600.0, SEA_Y, -150.0)
	var s2 := Vector3(3600.0, SEA_Y, -3950.0)
	var s3 := Vector3(-3600.0, SEA_Y, -3950.0)
	for v in [s0, s3, s2, s0, s2, s1]:
		sst.add_vertex(v)
	sea.mesh = sst.commit()
	sea.name = "CloudSea"
	sea.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	CelPass.paint(sea, SEA)
	_sky.add_child(sea)
	var which := 0
	for depth in [240.0, 400.0, 640.0, 1000.0, 1500.0, 2200.0, 3100.0]:
		var w: float = depth * 0.2
		var half_span: float = depth * 0.62 + 320.0
		var cx: float = -250.0 - half_span + rng.randf_range(0.0, w)
		while cx < -250.0 + half_span:
			var cw := w * rng.randf_range(0.8, 1.25)
			var cloud := LuchaKit.swirl_cloud(cw, which)
			which += 1
			# The far rows lie flatter and wider apart, so the far peaks stand out of the sea.
			var far: float = clampf((depth - 640.0) / 2460.0, 0.0, 1.0)
			cloud.scale.y *= lerpf(1.0, 0.5, far)
			cloud.scale.z *= 0.12  # a kit cloud this big would be 40 m thick: keep it a card
			cloud.position = Vector3(cx, SEA_Y + cw * lerpf(0.2, 0.1, far), -depth + rng.randf_range(-0.17, 0.17) * depth)
			_sky.add_child(cloud)
			_clouds.append([cloud, depth * 0.004 * rng.randf_range(0.7, 1.3), cw * 0.5, -250.0 - half_span - cw, -250.0 + half_span + cw])
			cx += cw * rng.randf_range(0.95, 1.5) * lerpf(1.0, 1.7, far)
	# ---- the storm's deck: a dark wall of cloud close behind the ridge, and darker
	# cut-outs drifting before it
	var wall := PackedVector2Array()
	var n_under := 22
	for i in n_under:
		var ccx := -760.0 + (float(i) + 0.5) / n_under * 1000.0
		for k in 5:
			var ang := PI + float(k) / 4.0 * PI
			wall.append(Vector2(ccx + cos(ang) * 1000.0 / n_under * 0.5, 878.0 + sin(ang) * rng.randf_range(4.0, 9.0)))
	var n_top := 11
	for i in n_top:
		var f := 1.0 - (float(i) + 0.5) / n_top
		var ccx := -760.0 + f * 1000.0
		var r := 1000.0 / n_top * rng.randf_range(0.56, 0.74)
		var top := rng.randf_range(958.0, 980.0)
		for k in 9:
			var ang := (float(k) + 0.5) / 9.0 * PI
			wall.append(Vector2(ccx + cos(ang) * r, top - r * 0.7 + sin(ang) * r * 0.7))
	var deck := _cards([wall], -140.0, STORM[0])
	deck.name = "StormDeck"
	_sky.add_child(deck)
	var layers := [[-84.0, 150.0, 6, 1], [-46.0, 96.0, 6, 2], [-22.0, 56.0, 5, 3]]  # z, width, how many, tone
	for l in layers:
		var lz: float = l[0]
		var lw: float = l[1]
		for i in int(l[2]):
			var cw := lw * rng.randf_range(0.8, 1.25)
			var cloud := _cards([_cloud_poly(cw, cw * 0.26, 8, rng.randi())], 0.0, STORM[int(l[3])])
			cloud.position = Vector3(-620.0 + float(i) / float(l[2]) * 760.0 + rng.randf_range(-30.0, 30.0), rng.randf_range(884.0, 944.0), lz)
			_sky.add_child(cloud)
			_clouds.append([cloud, rng.randf_range(1.2, 2.6), cw * 0.5, -700.0, 180.0])


## A cardboard range across the horizon at depth z: a zigzag of peaks and saddles, each
## peak's left flank a shade darker, snow on the tops if asked.
func _range(z: float, crest_lo: float, crest_hi: float, peaks: int, giant_every: int, col: Color, shade: Color, snow: bool, rng: RandomNumberGenerator) -> void:
	var x0 := -3700.0
	var x1 := 3700.0
	var base := FLOOR_Y - 30.0
	var line := PackedVector2Array()  # the ridge, left to right: saddle, peak, saddle, peak ...
	var step := (x1 - x0) / peaks
	line.append(Vector2(x0, crest_lo * 0.45))
	for i in peaks:
		var px := x0 + (float(i) + 0.5 + rng.randf_range(-0.18, 0.18)) * step
		var ph := rng.randf_range(crest_lo, crest_hi)
		if giant_every > 0 and i % giant_every == 1:
			ph = rng.randf_range(1080.0, 1260.0)  # a giant
		line.append(Vector2(px, ph))
		var sx := x0 + (float(i) + 1.0 + rng.randf_range(-0.12, 0.12)) * step if i < peaks - 1 else x1
		line.append(Vector2(sx, minf(ph, crest_lo) * rng.randf_range(0.5, 0.72)))
	var body := PackedVector2Array([Vector2(x0, base)])
	body.append_array(line)
	body.append(Vector2(x1, base))
	# (the outline runs clockwise here; _cards faces every triangle to the camera)
	_outside.add_child(_cards([body], z, col))
	var shades: Array = []
	var snows: Array = []
	for i in peaks:
		var left := line[i * 2]
		var top := line[i * 2 + 1]
		var right := line[i * 2 + 2]
		shades.append(PackedVector2Array([left, top, Vector2(top.x + (right.x - top.x) * rng.randf_range(0.1, 0.3), base), Vector2(left.x, base)]))
		if snow and top.y > 640.0:
			var k := 0.24
			var a := top.lerp(left, k)
			var b := top.lerp(right, k)
			snows.append(PackedVector2Array([a, top, b, a.lerp(b, 0.75) + Vector2(0, 40.0), a.lerp(b, 0.5) - Vector2(0, 50.0), a.lerp(b, 0.25) + Vector2(0, 35.0)]))
	_outside.add_child(_cards(shades, z + 2.0, shade))
	if not snows.is_empty():
		_outside.add_child(_cards(snows, z + 4.0, HAZE_SNOW))


## A low rounded hill's outline, standing on y.
func _mound(x: float, w: float, h: float, y: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 9:
		var t := float(i) / 8.0
		pts.append(Vector2(x + w * t, y + h * sin(t * PI) * (0.85 + 0.15 * sin(t * 7.0))))
	return pts


## The tiny town until the kit's `town_far` lands: 40 m wide before scaling, cream and
## pink houses with red roofs, the church's twin towers, the ring a dot of colour.
func _stand_in_town() -> Node3D:
	var root := Node3D.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 55
	var walls := [Color("#F1E4C8"), Color("#F2B8A8"), Color("#F5E08A"), Color("#BFE3EA")]
	for i in 26:
		var w := rng.randf_range(1.6, 2.8)
		var h := rng.randf_range(1.6, 3.4)
		var x := rng.randf_range(-19.0, 19.0 - w)
		if absf(x + w * 0.5) < 4.0:
			continue
		var z := rng.randf_range(-0.9, 0.9)
		root.add_child(_box(Vector3(w, h, 0.2), walls[i % walls.size()], Vector3(x + w * 0.5, h * 0.5, z)))
		root.add_child(_box(Vector3(w + 0.3, 0.6, 0.3), Color("#E0492E"), Vector3(x + w * 0.5, h + 0.3, z)))
	for sx in [-2.4, 2.4]:
		root.add_child(_box(Vector3(1.6, 9.0, 0.2), Color("#F2A99B"), Vector3(sx, 4.5, -0.4)))
		root.add_child(_box(Vector3(1.9, 1.0, 0.3), Color("#E0492E"), Vector3(sx, 9.5, -0.4)))
	root.add_child(_box(Vector3(3.4, 6.0, 0.2), Color("#F2A99B"), Vector3(0, 3.0, -0.4)))
	root.add_child(_box(Vector3(2.6, 0.9, 0.3), Color("#FF3D8B"), Vector3(0, 0.45, 0.95)))  # the ring
	return root


# ================================================================ inside

func _build_caves() -> void:
	var meta := {}
	var text := FileAccess.get_file_as_string(META) if FileAccess.file_exists(META) else ""
	if not text.is_empty():
		var parsed = JSON.parse_string(text)
		if parsed is Dictionary:
			meta = parsed
	var rng := RandomNumberGenerator.new()
	# The mountain's outline, drawn in 10 m: nothing of a cavern may stand outside it
	# (a deep card slides toward the camera's axis, so it needs the margin).
	var body := PackedVector2Array()
	for i in range(EAST.size() - 1, -1, -1):
		body.append(Vector2(float(EAST[i][0]), float(EAST[i][1])))
	for w in WEST:
		body.append(Vector2(float(w[0]), float(w[1])))
	var inset: Array = Geometry2D.offset_polygon(body, -10.0)
	if not inset.is_empty():
		body = inset[0]
	for cave in CAVES:
		var id: String = cave[0]
		var fb: Array = FALLBACK[id]
		var region: Array = fb[0]
		var tones := [Color(str(fb[1])), Color(str(fb[2])), Color(str(fb[3]))]
		if meta.has("frame") and (meta.frame as Dictionary).has(id):
			region = meta.frame[id].region
		if meta.has("palettes") and (meta.palettes as Dictionary).has(cave[1]):
			var pal: Dictionary = meta.palettes[cave[1]]
			tones = [Color(str(pal.back)), Color(str(pal.back2)), Color(str(pal.back3))]
		rng.seed = hash(id)
		var r := Rect2(float(region[0]), float(region[1]), float(region[2]) - float(region[0]), float(region[3]) - float(region[1]))
		var node := Node3D.new()
		node.name = "Cave_" + id
		add_child(node)
		# the deep dark, then two layers of silhouettes before it
		var deep := r.grow(60.0)
		node.add_child(_cards(_cut([PackedVector2Array([deep.position, Vector2(deep.end.x, deep.position.y), deep.end, Vector2(deep.position.x, deep.end.y)])], body), -60.0, tones[2]))
		node.add_child(_cards(_cut(_cave_layer(r.grow(34.0), str(cave[1]), 1.6, rng), body), -36.0, tones[1]))
		node.add_child(_cards(_cut(_cave_layer(r.grow(16.0), str(cave[1]), 1.0, rng), body), -18.0, tones[0]))
		node.visible = false
		_caves.append([node, r.grow(80.0)])


## One layer of a cavern's far wall: rock teeth down from the roof and up from the
## floor, a few columns, and the area's own shapes. `k` scales it (the deeper, the bigger).
func _cave_layer(r: Rect2, motif: String, k: float, rng: RandomNumberGenerator) -> Array:
	var out: Array = []
	var x := r.position.x
	while x < r.end.x:  # the roof's teeth
		var w := rng.randf_range(9.0, 20.0) * k
		var d := rng.randf_range(6.0, 18.0) * k
		out.append(PackedVector2Array([Vector2(x - 2.0, r.end.y + 4.0), Vector2(x + w + 2.0, r.end.y + 4.0), Vector2(x + w * rng.randf_range(0.35, 0.65), r.end.y - d)]))
		x += w * rng.randf_range(0.7, 1.0)
	x = r.position.x
	while x < r.end.x:  # the floor's
		var w := rng.randf_range(12.0, 26.0) * k
		var d := rng.randf_range(4.0, 13.0) * k
		out.append(PackedVector2Array([Vector2(x - 2.0, r.position.y - 4.0), Vector2(x + w * rng.randf_range(0.35, 0.65), r.position.y + d), Vector2(x + w + 2.0, r.position.y - 4.0)]))
		x += w * rng.randf_range(0.7, 1.0)
	var n := int(r.size.x / (46.0 * k)) + 1
	for i in n:
		var cx := r.position.x + (float(i) + rng.randf_range(0.2, 0.8)) / n * r.size.x
		var base := r.position.y - 4.0
		match motif:
			"mine":  # shoring: two posts and a cap, a brace
				var h := rng.randf_range(16.0, 30.0) * k
				var w := rng.randf_range(10.0, 16.0) * k
				var t := 1.3 * k
				out.append(_rect(cx - w * 0.5, base, t, h))
				out.append(_rect(cx + w * 0.5 - t, base, t, h))
				out.append(_rect(cx - w * 0.5 - t, base + h, w + t * 2.0, t * 1.2))
				out.append(PackedVector2Array([Vector2(cx - w * 0.5, base + h * 0.6), Vector2(cx - w * 0.5 + t, base + h * 0.6), Vector2(cx - w * 0.5 + w * 0.3 + t, base + h), Vector2(cx - w * 0.5 + w * 0.3, base + h)]))
			"river":  # an arch pier, flared at the head, the full height of the room
				var w := rng.randf_range(5.0, 8.0) * k
				var top := r.end.y + 4.0
				out.append(PackedVector2Array([Vector2(cx - w * 0.5, base), Vector2(cx + w * 0.5, base), Vector2(cx + w * 0.5, top - w * 2.6), Vector2(cx + w * 2.4, top), Vector2(cx - w * 2.4, top), Vector2(cx - w * 0.5, top - w * 2.6)]))
			"crystal":  # leaning shards, from the floor or the roof
				var h := rng.randf_range(18.0, 44.0) * k
				var w := rng.randf_range(4.0, 8.0) * k
				var lean := rng.randf_range(-0.35, 0.35) * h
				if rng.randf() < 0.6:
					out.append(PackedVector2Array([Vector2(cx - w * 0.5, base), Vector2(cx + w * 0.5, base), Vector2(cx + w * 0.5 + lean, base + h * 0.82), Vector2(cx + lean, base + h), Vector2(cx - w * 0.5 + lean, base + h * 0.86)]))
				else:
					var top := r.end.y + 4.0
					out.append(PackedVector2Array([Vector2(cx - w * 0.5, top), Vector2(cx - w * 0.5 + lean, top - h * 0.86), Vector2(cx + lean, top - h), Vector2(cx + w * 0.5 + lean, top - h * 0.82), Vector2(cx + w * 0.5, top)]))
			"fungus":  # a mushroom: a stalk and a cap
				var h := rng.randf_range(14.0, 36.0) * k
				var w := rng.randf_range(2.0, 3.6) * k
				var capw := rng.randf_range(9.0, 17.0) * k
				out.append(_rect(cx - w * 0.5, base, w, h))
				var cap := PackedVector2Array([Vector2(cx - capw, base + h), Vector2(cx + capw, base + h)])
				for i2 in 7:
					var ang := (float(i2) + 0.5) / 7.0 * PI
					cap.append(Vector2(cx + cos(ang) * capw, base + h + sin(ang) * capw * 0.55))
				out.append(cap)
			"temple":  # a stepped pyramid, or a column with a head
				if i % 2 == 0:
					var w := rng.randf_range(26.0, 40.0) * k
					var steps := 5
					var sh := rng.randf_range(4.0, 6.5) * k
					for s in steps:
						var sw := w * (1.0 - float(s) / steps * 0.8)
						out.append(_rect(cx - sw * 0.5, base + s * sh, sw, sh + 0.5))
				else:
					var w := rng.randf_range(3.0, 4.6) * k
					var h := r.size.y + 8.0
					out.append(_rect(cx - w * 0.5, base, w, h))
					out.append(_rect(cx - w, base + h - w * 1.2, w * 2.0, w * 1.2))
					out.append(_rect(cx - w * 0.9, base, w * 1.8, w))
			_:  # the chimney: pipes up the wall, with a collar and an elbow
				var w := rng.randf_range(2.6, 4.4) * k
				var h := r.size.y * rng.randf_range(0.5, 1.0)
				out.append(_rect(cx - w * 0.5, base, w, h))
				out.append(_rect(cx - w * 0.8, base + h * 0.5, w * 1.6, w * 0.7))
				out.append(_rect(cx - w * 0.5, base + h - w, w * rng.randf_range(4.0, 9.0), w))
	return out


## Outlines cut to what lies inside `body`.
static func _cut(polys: Array, body: PackedVector2Array) -> Array:
	var out: Array = []
	for poly in polys:
		for piece in Geometry2D.intersect_polygons(poly, body):
			if not Geometry2D.is_polygon_clockwise(piece):
				out.append(piece)
	return out


# ================================================================ pieces

static func _rect(x: float, y: float, w: float, h: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x, y), Vector2(x + w, y), Vector2(x + w, y + h), Vector2(x, y + h)])


## Flat cut-outs on (x, y) outlines at depth z, all in one mesh and one colour, every
## triangle facing the camera (+z) with its normal that way, so the scene's light and
## the house ink treat it as a card.
static func _cards(polys: Array, z: float, col: Color) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3(0, 0, 1))
	for poly in polys:
		var pts: PackedVector2Array = poly
		var tris := Geometry2D.triangulate_polygon(pts)
		for k in range(0, tris.size(), 3):
			var a := pts[tris[k]]
			var b := pts[tris[k + 1]]
			var c := pts[tris[k + 2]]
			if (b - a).cross(c - a) > 0.0:  # counter-clockwise from the front: turn it
				var t := b
				b = c
				c = t
			for v in [a, b, c]:
				st.add_vertex(Vector3(v.x, v.y, z))
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	CelPass.paint(mi, col)
	return mi


## A flat strip along `pts` on the ground, `width` wide, seen from above.
static func _ribbon(pts: PackedVector3Array, width: float, col: Color) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	var left := PackedVector3Array()
	var right := PackedVector3Array()
	for i in pts.size():
		var dir := (pts[mini(i + 1, pts.size() - 1)] - pts[maxi(i - 1, 0)]).normalized()
		var side := Vector3(-dir.z, 0.0, dir.x) * width * 0.5
		left.append(pts[i] - side)
		right.append(pts[i] + side)
	for i in pts.size() - 1:
		for tri in [[left[i], left[i + 1], right[i + 1]], [left[i], right[i + 1], right[i]]]:
			var a: Vector3 = tri[0]
			var b: Vector3 = tri[1]
			var c: Vector3 = tri[2]
			if (b - a).cross(c - a).y > 0.0:  # counter-clockwise from above: turn it
				var t := b
				b = c
				c = t
			for v in [a, b, c]:
				st.add_vertex(v)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	CelPass.paint(mi, col)
	return mi


static func _box(size: Vector3, col: Color, at: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = at
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	CelPass.paint(mi, col)
	return mi


## A cut-out cloud's outline, origin at its middle: round bumps along the top, smaller
## ones hanging along the bottom.
static func _cloud_poly(w: float, h: float, lobes: int, seed: int) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var pts := PackedVector2Array()
	var under := lobes + 2
	for i in under:
		var cx := (float(i) + 0.5) / under * w - w * 0.5
		var r := w * 0.5 / under
		var sag := h * rng.randf_range(0.12, 0.25)
		for k in 5:
			var ang := PI + float(k) / 4.0 * PI
			pts.append(Vector2(cx + cos(ang) * r, sin(ang) * sag))
	for i in lobes:
		var f := 1.0 - (float(i) + 0.5) / lobes
		var cx := (f - 0.5) * w * 0.92
		var r := w * 0.5 / lobes * 1.25
		var top := h * (0.45 + 0.55 * sin(f * PI)) * rng.randf_range(0.85, 1.1)
		for k in 8:
			var ang := (float(k) + 0.5) / 8.0 * PI
			pts.append(Vector2(cx + cos(ang) * r, maxf(0.6, top - r + sin(ang) * r)))
	return pts
