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
## OUTSIDE (the cliffs up, y 570 and over), all real depth, 0.3 to 3.9 km back, so it
## slides by as a far land should and the climber rises toward the ranges' own height.
## FAR BACKGROUNDS ARE FLAT FACADE PIECES (Parker 11-13: "that is now the correct way to
## do far backgrounds"; docs/peak/PEAK_DESIGN.md, section 7): every layer here is an
## upright cut-out card. Nothing lies flat: there is no floor of fields and no floor of
## cloud.
##   - the valley, painted on ONE upright card 2.35 km back (the kit's
##     `peak_valley_panorama`): fields, river and road below its horizon line, its hills
##     above. The tiny town (the kit's `town_far`) stands just in front of it, under the
##     hills; `town_at()` is where, for the bell's fireworks;
##   - two painted ranges behind it (the kit's `peak_far_range_near` and `_far`), their
##     feet on that horizon line, the far one snow-capped with a few giants, and a
##     cardboard sun;
##   - the sea of cloud at y 932: seven rows of cut-out clouds, and behind each row a
##     continuous row of cloud banks (the kit's `peak_cloud_bank_a` and `_b`), so from the
##     summit it is rows of white banks with the far peaks standing out of them, and from
##     the cliffs a far ceiling of cloud rows;
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
## Cheap: flat cards on the one atlas material, a few dozen kit clouds and banks, and
## nothing per frame but the clouds' drift and which groups show.

const META := "res://stages/peak/course/_meta.json"
const OUTSIDE_FROM := 430.0  # above this the camera may see out (the chimney's slit, then the cliffs)
## THE VALLEY'S CARD (the kit's `peak_valley_panorama`): 7,200 m wide, its origin at the
## middle of its width on the line where its painted fields meet the feet of its painted
## hills. The fields run 950 m DOWN from that line and the hills rise 110 m above it.
const VALLEY_Z := -2350.0
const VALLEY_W := 7200.0
const VALLEY_DOWN := 950.0
const VALLEY_UP := 110.0
## The height of that line. From El Balcon (y 580) the painted valley is the bottom quarter
## of the picture. It thins away as the climber rises: a strip along the foot of the
## picture at the glacier, and hidden under the banks of cloud from the summit.
const HORIZON_Y := 215.0
const SEA_Y := 932.0  # the sea of cloud
## The tiny town (local): on the card's calm patch, 150 m east of its middle, under the
## hills and a few metres in front of the card. (It stood 3.3 km back at 9x: this is the
## same size on screen.)
const TOWN_AT := Vector3(150.0, HORIZON_Y - 34.0, VALLEY_Z + 12.0)
const TOWN_SCALE := 6.4
## A CLOUD BANK (the kit's `peak_cloud_bank_a` and `_b`): 1,000 m wide, its origin at the
## middle of its width at the height of the dips between its top scallops; the scallops
## stand up to 70 m above that, the body hangs 110 m below and ends in a scalloped
## underside (a straight foot drew a ruled line across the sky from the cliffs).
const BANK_W := 1000.0
const BANK_UP := 70.0
const BANK_DOWN := 110.0
## A row's banks are sized to its distance as its clouds are (the far row at the made
## size), but never smaller than BANK_MIN: seen from the summit, 35 to 75 m above the sea,
## a row's body must hang down past the top of the row in front of it, or the valley shows
## between the rows. At 0.55 (61 m of body) the rows as spaced cover each other with 9 m
## to spare from 75 m up. (Under the nearest row, low at the summit's foot, the storm's
## deck is in front.)
const BANK_FAR := 3100.0
const BANK_MIN := 0.55
## Each row stands a little higher or lower than the last (metres), so that from the
## glacier and the storm ridge, where the camera is level with the bodies, the rows'
## undersides do not fall into one line across the picture.
const BANK_STEP := [0.0, 9.0, -7.0, 6.0, -9.0, 5.0, 0.0]
## The ranges were drawn standing on y 0: their heights are squashed by this and stood on
## the horizon line (the giants keep their own height: they must clear the sea of cloud).
const RANGE_SQUASH := 0.8
## The mountain's east face from the summit down: [local x, local y] (tools/peak/areas/st.py).
const EAST := [[-350, 1000], [-334, 962], [-307, 884], [-281, 784], [-251, 684], [-230, 578], [-177, 400],
	[-150, 322], [-130, 260], [-90, 150], [-60, 60], [-34, 5.5], [-16, -40]]
const WEST := [[-372, 958], [-505, 958], [-512, 900], [-525, 800], [-545, 700], [-520, 550], [-620, 250], [-700, 0], [-714, -40]]

## (Albedos: the scene's sun draws a card about 1.3x brighter and bluer than its colour.)
const HAZE_FAR := Color("#A0A6B8")
const HAZE_FAR_SHADE := Color("#8C93A8")
const HAZE_SNOW := Color("#D8DEE8")
const HAZE_MID := Color("#8A8FA0")
const HAZE_MID_SHADE := Color("#787E92")
const HILL := Color("#72866A")
const HILL_SHADE := Color("#61745C")
const HILL_FAR := Color("#7E8B85")  # the stand-in card's back row of hills, hazed
const FIELDS := [Color("#8E9A76"), Color("#869270"), Color("#9A9E7A"), Color("#A49A7C"), Color("#7C8A6C")]
const RIVER := Color("#86AEC2")
const ROAD := Color("#B4A88C")
const BANK := Color("#B4BBD0")  # the stand-in banks (a mid value: the light lifts it to a pale lavender white, under the kit's white clouds)
const BANK_BODY := Color("#A6AEC6")
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

var _outside: Node3D  # the far land: the valley's card, town, ranges, sun
var _sky: Node3D  # the sea of cloud (its clouds and banks) and the storm's deck
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
## need to climb past the sea of cloud's banks, about y SEA_Y + 40, to be seen from the
## summit).
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
	# (Each part draws from its own seed, so a kit model landing in place of a stand-in
	# does not reshuffle the ranges or the clouds.)
	var rng := RandomNumberGenerator.new()
	# ---- the valley: ONE upright card, painted (Parker 11-13: far backgrounds are flat
	# facade pieces). Its origin line stands at HORIZON_Y.
	var valley := LuchaKit.kit_model("peak_valley_panorama")
	if valley == null:
		valley = _stand_in_valley()
	valley.name = "Valley"
	valley.position = Vector3(0.0, HORIZON_Y, VALLEY_Z)
	_no_shadow(valley)
	_outside.add_child(valley)
	# ---- the tiny town
	_town = LuchaKit.kit_model("town_far")
	if _town == null:
		_town = _stand_in_town()
	_town.name = "TownFar"
	_town.scale = Vector3.ONE * TOWN_SCALE
	_town.position = TOWN_AT
	_no_shadow(_town)
	_outside.add_child(_town)
	# ---- the ranges behind the valley's card, their feet on its horizon line: the far one
	# high and snow-capped, a lower one before it (low: from the cliffs the climber looks
	# DOWN on them; only a few far giants stand as high as the summit, and those are the
	# peaks that rise out of the sea of cloud)
	# Each is the kit's painted card once it has landed (7,400 m wide, its origin at the
	# middle of its foot, its crests 170 to 400 m and 400 to 700 m above that, running on
	# 900 m below it behind the valley's card); until then, the code's cardboard range.
	rng.seed = 7785
	if not _range_card("peak_far_range_near", -3620.0):
		_range(-3620.0, 170.0, 400.0, 15, 0, HAZE_MID, HAZE_MID_SHADE, false, rng)
	if not _range_card("peak_far_range_far", -3880.0):
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
	# ---- the sea of cloud: cut-out clouds row behind row, each row sized to its distance,
	# and behind each row a continuous row of cloud banks, a and b by turns, their origin
	# line at SEA_Y. No floor: from above, each row's body hides what is under the next.
	rng.seed = 7786
	var which := 0
	var row := 0
	for depth in [240.0, 400.0, 640.0, 1000.0, 1500.0, 2200.0, 3100.0]:
		var w: float = depth * 0.2
		var half_span: float = depth * 0.62 + 320.0
		# The banks stand just behind the row's farthest cloud (and in front of the ranges).
		var bank_z: float = -minf(depth * 1.19, 3600.0)
		var bank_k: float = maxf(BANK_MIN, depth / BANK_FAR)
		var bank_w: float = BANK_W * bank_k
		var bank_half: float = depth * 1.15 + 420.0  # (wider than the clouds' run: a screen up to 32:9, and the camera's own travel)
		var bx: float = -250.0 - bank_half - rng.randf_range(0.0, bank_w)
		var bi := row
		while bx < -250.0 + bank_half:
			var bank := _bank(bi % 2 == 0)
			bank.scale = Vector3.ONE * bank_k
			bank.position = Vector3(bx + bank_w * 0.5, SEA_Y + float(BANK_STEP[row]), bank_z)
			_sky.add_child(bank)
			bx += bank_w
			bi += 1
		row += 1
		var cx: float = -250.0 - half_span + rng.randf_range(0.0, w)
		while cx < -250.0 + half_span:
			var cw := w * rng.randf_range(0.8, 1.25)
			var cloud := LuchaKit.swirl_cloud(cw, which)
			which += 1
			# The far rows lie flatter and wider apart, so the far peaks stand out of the sea.
			var far: float = clampf((depth - 640.0) / 2460.0, 0.0, 1.0)
			cloud.scale.y *= lerpf(1.0, 0.5, far)
			cloud.scale.z *= 0.12  # a kit cloud this big would be 40 m thick: keep it a card
			var cz: float = maxf(-depth + rng.randf_range(-0.17, 0.17) * depth, bank_z + depth * 0.012)  # (in front of its row's banks)
			cloud.position = Vector3(cx, SEA_Y + cw * lerpf(0.2, 0.1, far), cz)
			_sky.add_child(cloud)
			_clouds.append([cloud, depth * 0.004 * rng.randf_range(0.7, 1.3), cw * 0.5, -250.0 - half_span - cw, -250.0 + half_span + cw])
			cx += cw * rng.randf_range(0.95, 1.5) * lerpf(1.0, 1.7, far)
	# ---- the storm's deck: a dark wall of cloud close behind the ridge, and darker
	# cut-outs drifting before it
	var wall := _cloud_poly(1040.0, 46.0, 22, 911, false)
	for i in wall.size():
		wall[i] += Vector2(-260.0, 905.0)
	var deck := _cards([wall], -140.0, STORM[0])
	deck.name = "StormDeck"
	_sky.add_child(deck)
	var layers := [[-84.0, 150.0, 6, 1], [-46.0, 96.0, 6, 2], [-22.0, 56.0, 5, 3]]  # z, width, how many, tone
	for l in layers:
		var lz: float = l[0]
		var lw: float = l[1]
		for i in int(l[2]):
			var cw := lw * rng.randf_range(0.8, 1.25)
			var cloud := _cards([_cloud_poly(cw, cw * 0.2, 6, rng.randi(), false)], 0.0, STORM[int(l[3])])
			cloud.position = Vector3(-620.0 + float(i) / float(l[2]) * 760.0 + rng.randf_range(-30.0, 30.0), rng.randf_range(884.0, 944.0), lz)
			_sky.add_child(cloud)
			_clouds.append([cloud, rng.randf_range(1.2, 2.6), cw * 0.5, -700.0, 180.0])


## A range's painted card stood on the horizon line at depth z, if the kit has it.
func _range_card(model: String, z: float) -> bool:
	var card := LuchaKit.kit_model(model)
	if card == null:
		return false
	card.position = Vector3(0.0, HORIZON_Y, z)
	_no_shadow(card)
	_outside.add_child(card)
	return true


## A cardboard range across the horizon at depth z: a zigzag of peaks and saddles, each
## peak's left flank a shade darker, snow on the tops if asked.
func _range(z: float, crest_lo: float, crest_hi: float, peaks: int, giant_every: int, col: Color, shade: Color, snow: bool, rng: RandomNumberGenerator) -> void:
	var x0 := -3700.0
	var x1 := 3700.0
	# The card runs on far below the horizon line, behind the valley's card: seen from
	# above, a card this much farther back shows its foot higher than the valley's line.
	var base := HORIZON_Y - 900.0
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
	# Stood on the horizon line (the heights above were drawn standing on y 0).
	var snow_from := HORIZON_Y + 640.0 * RANGE_SQUASH
	for i in line.size():
		if line[i].y < 1000.0:
			line[i].y = HORIZON_Y + line[i].y * RANGE_SQUASH
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
		if snow and top.y > snow_from:
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


## THE VALLEY'S CARD until the kit's `peak_valley_panorama` lands, in that model's own
## frame (origin at the middle of the horizon line, face at z 0): a patchwork of fields
## whose rows thin toward the line, a river and a road across them, and two rows of low
## hills above, the back row hazed. Flush colour regions on one plane: the layers are a
## few centimetres apart, far too little for the ink to take as an edge at 2 km.
func _stand_in_valley() -> Node3D:
	var root := Node3D.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7784
	var half := VALLEY_W * 0.5
	var sts: Array = []
	for k in FIELDS.size():
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_normal(Vector3(0, 0, 1))
		sts.append(st)
	var rows := 15
	for j in rows:
		var y0 := -VALLEY_DOWN * pow(1.0 - float(j) / rows, 1.7)
		var y1 := -VALLEY_DOWN * pow(1.0 - float(j + 1) / rows, 1.7)
		var cell := lerpf(340.0, 110.0, float(j) / (rows - 1))
		var lean := rng.randf_range(-0.5, 0.5) * cell
		var x := -half
		var lo := x  # the cell's left edge along the row's foot, and along its top
		var hi := x
		while x < half:
			var w := cell * rng.randf_range(0.6, 1.4)
			var last := x + w >= half
			var lo1 := half if last else x + w
			var hi1 := half if last else minf(maxf(x + w + lean + rng.randf_range(-0.2, 0.2) * cell, hi + 1.0), half)
			var st: SurfaceTool = sts[rng.randi() % FIELDS.size()]
			for v in [Vector2(lo, y0), Vector2(hi, y1), Vector2(hi1, y1), Vector2(lo, y0), Vector2(hi1, y1), Vector2(lo1, y0)]:  # facing the camera
				st.add_vertex(Vector3(v.x, v.y, 0.0))
			lo = lo1
			hi = hi1
			x += w
	var fields := ArrayMesh.new()
	for k in FIELDS.size():
		(sts[k] as SurfaceTool).commit(fields)
		fields.surface_set_material(fields.get_surface_count() - 1, LuchaKit.mat(FIELDS[k]))
	var fields_mi := MeshInstance3D.new()
	fields_mi.mesh = fields
	CelPass.unify(fields_mi)
	root.add_child(fields_mi)
	# the river, wide at the card's foot and a thread at the line; the road from the
	# mountain's foot to the town
	var river: Array = []
	for i in 22:
		var t := float(i) / 21.0
		river.append([Vector2(lerpf(-2900.0, 3100.0, t) + sin(t * 9.0) * 160.0, lerpf(-640.0, -46.0, pow(t, 0.7)) + sin(t * 5.3 + 1.0) * 30.0 * (1.0 - t)), lerpf(64.0, 7.0, pow(t, 0.6))])
	root.add_child(_cards(_strip(river), 0.04, RIVER))
	var road: Array = []
	for i in 12:
		var t := float(i) / 11.0
		road.append([Vector2(lerpf(-420.0, 150.0, t) + sin(t * 6.0) * 90.0 * (1.0 - t), lerpf(-VALLEY_DOWN, -40.0, pow(t, 0.55))), lerpf(30.0, 4.0, pow(t, 0.5))])
	root.add_child(_cards(_strip(road), 0.08, ROAD))
	# the hills on the line: a hazed row behind, then a nearer row with shade flanks,
	# left open where the town stands
	var far_hills: Array = []
	var hx := -half
	while hx < half:
		var w := rng.randf_range(420.0, 760.0)
		far_hills.append(_mound(hx, minf(w, half - hx), rng.randf_range(70.0, VALLEY_UP), 0.0))
		hx += w * rng.randf_range(0.55, 0.8)
	root.add_child(_cards(far_hills, 0.04, HILL_FAR))
	var hills: Array = []
	var shades: Array = []
	hx = -half
	while hx < half:
		var w := minf(rng.randf_range(260.0, 520.0), half - hx)
		var h := rng.randf_range(34.0, 78.0)
		if absf(hx + w * 0.5 - 150.0) > 430.0 and w > 120.0:
			hills.append(_mound(hx, w, h, 0.0))
			shades.append(PackedVector2Array([Vector2(hx, 0.0), Vector2(hx + w * 0.42, h * 0.97), Vector2(hx + w * 0.3, 0.0)]))
		hx += w * rng.randf_range(0.7, 1.4)
	root.add_child(_cards(hills, 0.08, HILL))
	root.add_child(_cards(shades, 0.12, HILL_SHADE))
	return root


## Quads along a painted line on a card: [[point, width there], ...] (the width is up
## and down the card).
static func _strip(line: Array) -> Array:
	var out: Array = []
	for i in line.size() - 1:
		var a: Vector2 = line[i][0]
		var b: Vector2 = line[i + 1][0]
		var ha := Vector2(0.0, float(line[i][1]) * 0.5)
		var hb := Vector2(0.0, float(line[i + 1][1]) * 0.5)
		out.append(PackedVector2Array([a - ha, b - hb, b + hb, a + ha]))
	return out


## One cloud bank: the kit's model, or until it lands a plain card of its measure: top
## scallops standing out of the origin line, a calm body hanging below, and both ends
## cut square at the line so a row of them is one unbroken bank.
func _bank(first: bool) -> Node3D:
	var k := LuchaKit.kit_model("peak_cloud_bank_a" if first else "peak_cloud_bank_b")
	if k != null:
		_no_shadow(k)
		return k
	var rng := RandomNumberGenerator.new()
	rng.seed = 311 if first else 947
	var half := BANK_W * 0.5
	var foot := -BANK_DOWN * 0.86
	var pts := PackedVector2Array()
	# the top, left to right: round heads, a dip to the line between each
	var x := -half
	while x < half - 1.0:
		var w := minf(rng.randf_range(110.0, 230.0), half - x)
		if half - (x + w) < 90.0:
			w = half - x
		var h := BANK_UP * rng.randf_range(0.45, 1.0) * clampf(w / 170.0, 0.5, 1.0)
		for i in 9:
			var ang := PI - float(i) / 8.0 * PI
			pts.append(Vector2(x + w * 0.5 + cos(ang) * w * 0.5, sin(ang) * h))
		x += w
	# the underside, right to left: shallow bellies
	var under := PackedVector2Array()
	x = half
	while x > -half + 1.0:
		var w := minf(rng.randf_range(140.0, 260.0), x + half)
		if (x - w) + half < 110.0:
			w = x + half
		var sag := (BANK_DOWN + foot) * rng.randf_range(0.5, 1.0)
		for i in 7:
			var ang := float(i) / 6.0 * PI
			under.append(Vector2(x - w * 0.5 + cos(ang) * w * 0.5, foot - sin(ang) * sag))
		x -= w
	pts.append_array(under)
	var root := Node3D.new()
	root.add_child(_cards([_clean(pts)], 0.0, BANK))
	# the calm body: a darker band along the underside, flush
	var band := PackedVector2Array()
	for i in 13:
		var t := float(i) / 12.0
		band.append(Vector2(lerpf(-half, half, t), foot + 46.0 + sin(t * TAU * (2.0 if first else 3.0)) * 16.0))
	band.append_array(under)
	root.add_child(_cards([_clean(band)], 0.03, BANK_BODY))
	return root


## An outline without doubled points (where one round head ends and the next begins).
static func _clean(pts: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		if out.is_empty() or out[out.size() - 1].distance_to(p) > 0.01:
			out.append(p)
	if out.size() > 1 and out[0].distance_to(out[out.size() - 1]) <= 0.01:
		out.remove_at(out.size() - 1)
	return out


## Nothing this far back casts a shadow.
static func _no_shadow(n: Node) -> void:
	for mi: MeshInstance3D in n.find_children("*", "MeshInstance3D", true, false):
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if n is MeshInstance3D:
		(n as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


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


static func _box(size: Vector3, col: Color, at: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = at
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	CelPass.paint(mi, col)
	return mi


## A cut-out cloud's outline, origin at the middle of its base: `lobes` round heads run
## together, the tall ones in the middle (h is the tallest head's radius). `flat` cuts
## the bottom level; otherwise the heads' own round undersides hang down.
static func _cloud_poly(w: float, h: float, lobes: int, seed: int, flat := true) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var acc := PackedVector2Array()
	for i in lobes:
		var t := float(i) / float(maxi(lobes - 1, 1))
		var r := h * (0.55 + 0.45 * sin(t * PI)) * rng.randf_range(0.82, 1.1)
		var c := Vector2(lerpf(-w * 0.5 + r, w * 0.5 - r, t), r * rng.randf_range(0.35, 0.6))
		var head := PackedVector2Array()
		for k in 20:
			var ang := float(k) / 20.0 * TAU
			head.append(c + Vector2(cos(ang), sin(ang)) * r)
		if acc.is_empty():
			acc = head
			continue
		var best := acc
		var best_area := -1.0
		for piece in Geometry2D.merge_polygons(acc, head):
			if Geometry2D.is_polygon_clockwise(piece):
				continue
			var lo := Vector2(INF, INF)
			var hi := Vector2(-INF, -INF)
			for q in piece:
				lo = lo.min(q)
				hi = hi.max(q)
			var area := (hi.x - lo.x) * (hi.y - lo.y)
			if area > best_area:
				best_area = area
				best = piece
		acc = best
	if flat:
		var cut := Geometry2D.intersect_polygons(acc, PackedVector2Array([Vector2(-w, -h * 0.1), Vector2(w, -h * 0.1), Vector2(w, h * 4.0), Vector2(-w, h * 4.0)]))
		if not cut.is_empty():
			acc = cut[0]
	return acc
