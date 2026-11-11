class_name DelMarScenery
extends Node3D
## DEL MAR'S SCENERY (the TD Environment Maker, 2026-11-10): everything seen and never
## touched, built from the approved district plan (Top Dog Kit\docs\del_mar\
## DEL_MAR_DISTRICT_PLAN.md, del_mar_plan.py, delmar_placements.csv). The game owns
## what climbers touch (the pier's collision, the base, the buoy, the line, the
## mast's growth: Stage); this owns the rest:
## - the ground: the land between the district line and the shore, the beach falling
##   to the waterline, and the sea to the horizon (the land ends at z -300);
## - the headland that closes the plaza's terraces, its cliff stair, El Faro on top;
## - the boardwalk, its light posts and festoons, La Cantinita, the lifeguard tower,
##   umbrellas and chairs on the sand;
## - the beach town: one row of the Building Maker's pieces along the bay to the spit
##   and its lighthouse, palms between;
## - the drifting ships, the islands, the band raft and the clouds over the sea.
## Stage instances it in `delmar_root` when a Del Mar match starts and frees it when the
## match ends: that is the load boundary. Everything stands right of the district line
## B(d), so no plaza camera (clamped to |x| <= 14) ever sees it.
##
## Kit pieces come in by name (LuchaKit.kit_model); where one hasn't landed yet a plain
## stand-in is built in its place, so the scene is whole at every stage.

const GROUND_Y := -0.92  # the plaza land's top: the town's ground meets it exactly
const BEACH_MAX := 16.0  # the beach, from the land's edge down to the waterline, where there's room
const WET_W := 2.6  # the wet sand band above the waterline
const WET_TOP := -1.32  # the wet sand's top edge
const HILL_Z0 := -44.0  # the hillside behind the town starts here (past the headland)
const HILL_MAX := 9.5
const BERM_MAX := 1.2  # the beach's top above the plaza's ground level, behind the town
const HILL_PEAK := 0.14  # its crest, as a fraction of the way from the district line to the beach
const WATER_Y := -1.8  # Stage.WATER_Y
const FAR_SHORE_Z := -300.0  # the land ends here, behind the plaza's mountains
const HORIZON := 2500.0
## The waterline (land to the left and back, sea to the right and front), from the plan.
const COAST := [Vector2(84, 60), Vector2(86, 0), Vector2(90, -40), Vector2(108, -100), Vector2(150, -170),
	Vector2(190, -230), Vector2(225, -270), Vector2(240, -300)]
const LAND := Color("#C9BE92")
const SAND := Color("#E6D1A0")
const WET_SAND := Color("#A99873")
const DUNE := Color("#EBD9A8")
const FOAM := Color("#F4F8FF")
const ROCK := Color("#9C8F80")
const ROCK_DARK := Color("#7E7366")
const BEACH_GRASS := Color("#8FA84A")
const BEACH_GRASS_DARK := Color("#6E8A3A")
const SEA := Color("#2F7FD0")
const SHALLOWS := Color("#3FA9DC")
const SEA_MID := Color("#3792D6")
const HILL_FAR := Color("#86A77C")
## The far hills' rows, front to back: [lit, mid, shade], stepping toward the sky's haze.
const HILL_ROWS := [
	[Color("#8DB257"), Color("#6F9744"), Color("#4F7339")],
	[Color("#97B583"), Color("#7C9C72"), Color("#5E7D63")],
	[Color("#9DB6AE"), Color("#839FA4"), Color("#66809A")],
]
const HAZE_ISLE := [Color("#8FA3C2"), Color("#778BB0"), Color("#5E6F99")]  # darker than the clouds, so they read as land
const HILL_DARK := Color("#6E8A4A")
const STONE := Color("#C2A878")
const BRICK := Color("#8A7662")  # the mortar behind the bricks
const PARAPET := Color("#D6C3A0")
const GRASS := Color("#8E9A5C")
const KERB := Color("#D9CBB0")
const BOARD := Color("#B98A5A")
const POST := Color("#6A4128")
const BULBS := [Color("#E0287A"), Color("#FFC928"), Color("#1FB8AE"), Color("#7CC83A"), Color("#F28A1E"), Color("#8A3FC0")]

## The shore row and the near pieces: [kit stem, x, z, yaw (degrees)], from the CSV.
const PIECES := [
	["lifeguard_tower", 79.0, 7.0, 0], ["beach_bar", 78.2, -7.4, 0],
	["beach_house_b", 78.4, -14.9, 41], ["beach_hut_a", 79.2, -22.4, 33], ["cabana_a", 79.7, -27.7, 29],
	["beach_hut_c", 80.3, -33.7, 25], ["beach_house_a", 80.9, -39.5, 22], ["cabana_b", 83.4, -49.2, 17],
	["stall_coco", 85.2, -55.4, 14], ["beach_hut_b", 87.2, -62.0, 12], ["stall_paletas", 89.0, -67.9, 9],
	["beach_house_b", 90.9, -74.4, 8], ["beach_hut_a", 93.4, -82.7, 5], ["cabana_a", 95.2, -88.6, 4],
	["beach_hut_c", 97.8, -95.1, 2], ["beach_house_a", 102.8, -100.9, 0], ["beach_hut_b", 107.8, -111.2, -2],
	["cabana_b", 111.9, -117.5, -4], ["beach_hut_c", 116.1, -124.4, -6], ["beach_house_b", 121.0, -130.5, -7],
	["beach_hut_a", 125.7, -140.1, -9], ["cabana_a", 130.0, -146.4, -10], ["beach_hut_b", 134.4, -153.8, -11],
	["cabana_b", 138.7, -160.5, -12], ["beach_hut_c", 143.2, -167.9, -13], ["beach_house_b", 148.6, -174.8, -14],
	["beach_hut_a", 153.8, -185.4, -14], ["cabana_a", 158.5, -192.4, -15], ["beach_hut_b", 163.2, -200.6, -16],
	["cabana_b", 168.0, -208.1, -16], ["beach_hut_c", 172.9, -216.2, -17], ["beach_house_b", 178.5, -223.6, -18],
	["beach_hut_a", 184.8, -235.9, -18], ["cabana_a", 190.4, -244.2, -19], ["beach_hut_b", 197.8, -252.6, -20],
	["cabana_b", 204.7, -260.5, -20], ["beach_hut_c", 212.1, -268.9, -21], ["beach_house_b", 217.6, -275.3, -22],
	["beach_hut_a", 223.2, -286.5, -22], ["lighthouse_spit", 222.0, -268.0, 0],
	["surf_rack", 62.0, 6.0, 15], ["surf_rack", 83.0, -3.0, -20],  # dressing on the sand
]
## Stand-in sizes [w, h, d] and colours for pieces that haven't landed.
const STAND_IN := {
	"lifeguard_tower": [2.9, 5.7, 2.9, "#F2E6C8"], "beach_bar": [7.0, 3.75, 3.6, "#1FB8AE"], "beach_house_a": [5.0, 7.8, 4.4, "#F2EEE4"],
	"beach_house_b": [4.8, 7.5, 4.4, "#E86A6A"], "beach_hut_a": [2.6, 3.6, 2.4, "#E86A9A"], "beach_hut_b": [2.8, 3.4, 2.4, "#1FB8AE"],
	"beach_hut_c": [2.9, 3.6, 2.6, "#A8D05A"], "cabana_a": [3.2, 3.2, 3.0, "#F2E6C8"], "cabana_b": [3.1, 4.0, 3.0, "#1FB8AE"],
	"stall_coco": [3.5, 3.0, 1.8, "#A8D05A"], "stall_paletas": [3.2, 2.9, 1.8, "#9DC3E6"], "lighthouse_spit": [4.0, 14.0, 4.0, "#F2EEE4"],
	"el_faro": [3.2, 17.0, 3.2, "#F2EEE4"], "surf_rack": [2.0, 2.0, 0.8, "#E8B14A"],
}
const PALMS := [Vector2(84.6, -10.8), Vector2(82.7, -22.5), Vector2(84.7, -41.6), Vector2(91.3, -63.6), Vector2(99.1, -89.6),
	Vector2(114.1, -120.8), Vector2(133.3, -152.8), Vector2(158.8, -193.1), Vector2(185.9, -233.6), Vector2(62.0, -3.0), Vector2(56.0, -16.0)]
const UMBRELLAS := [Vector3(70, 2, 0), Vector3(74, 9, 1), Vector3(82, 15, 2), Vector3(66, 10, 3), Vector3(60, 4, 4)]
const POSTS := [45.0, 52.0, 59.0, 66.0, 73.0]  # on the boardwalk's back edge
const PIER_ROOT := 74.0  # Stage.PIER_ROOT
const PIER_END := 104.0  # Stage.PIER_END
const BOARD_Y := -0.6  # the boardwalk's top
## The ships: [kit stem, x0, x1 (the drift), z, length, colour, flip]. They drift slowly
## between x0 and x1, bobbing.
## SPREAD OUT TO THE RIGHT (Parker 11-10: "the ships are too close to eachother, they
## should all be more spread to the right so some are not visible until you climb to the
## right a bit"). At the start the frame's right edge is about x 144 at z -58, 165 at
## z -95 and 195 at z -150: one sloop sails in view, a brigantine noses in at the edge,
## and the party boat, the second sloop and the far brigantine wait further right, coming
## into view as the tower (and the camera with it) moves out.
const SHIPS := [
	["ship_brigantine", 152.0, 174.0, -95.0, 24.0, "#B8202C", false], ["ship_brigantine", 225.0, 262.0, -150.0, 24.0, "#2659D8", true],
	["ship_sloop", 116.0, 128.0, -58.0, 12.0, "#FFC928", false], ["ship_sloop", 178.0, 192.0, -72.0, 12.0, "#1FB8AE", true],
	["ship_party_boat", 152.0, 166.0, -46.0, 11.0, "#E0287A", false],
]
## The islands and the raft: [kit stem, x, z, width, colour].
const ISLES := [["isle_palm_hammock", 140.0, -72.0, 10.0, "#7CC83A"], ["isle_lighthouse", 166.0, -125.0, 14.0, "#F2EEE4"],
	["isle_pinata_tree", 196.0, -190.0, 12.0, "#E0287A"], ["isle_band_raft", 145.0, -38.0, 6.0, "#E8B14A"]]
const CAM := Vector2(102.5, 13.1)  # the Del Mar camera (x, z): cut-outs and fronts turn to it
## Clouds over the sea: [x, y, z, width] (each outside the plaza cameras' reach).
const CLOUDS := [Vector4(122, 20, -110, 22), Vector4(152, 26, -150, 30), Vector4(232, 28, -175, 26),
	Vector4(205, 34, -200, 40), Vector4(212, 44, -260, 36), Vector4(262, 48, -330, 52),
	# a high, small, thin layer up in the empty top of the sky
	Vector4(160, 58, -180, 13), Vector4(196, 66, -232, 17), Vector4(232, 52, -205, 10), Vector4(150, 42, -128, 9)]

var water: MeshInstance3D = null  # the sea, for the game's splashes
var _foam: MeshInstance3D = null
var _piece_at: Array = []  # each placed piece: Vector3(x, its footprint's half-diagonal, z), for clearances
var _ships: Array = []  # [node, x0, x1, phase, speed]
var _clouds: Array = []  # [node, base x, half width]
var _bobbers: Array = []  # [node, base y, phase]
var _t := 0.0
var _rng := RandomNumberGenerator.new()


# ---------------------------------------------------------------- the plan's lines

## The district line: Del Mar owns everything right of it (d is the depth behind the plane).
static func district_line(d: float) -> float:
	return 36.0 + 0.62 * maxf(d, 0.0)


## The waterline's x at depth z (z from +60 to -300).
static func coast_x(z: float) -> float:
	# The plan's polyline, its corners rounded (a 24 m average), so the shore curves.
	var sum := 0.0
	for k in 5:
		sum += _coast_lin(z + (k - 2) * 6.0)
	return sum / 5.0


static func _coast_lin(z: float) -> float:
	z = clampf(z, FAR_SHORE_Z, 60.0)
	for i in COAST.size() - 1:
		var a: Vector2 = COAST[i]
		var b: Vector2 = COAST[i + 1]
		if z <= a.y and z >= b.y:
			return lerpf(a.x, b.x, (z - a.y) / (b.y - a.y))
	return (COAST[COAST.size() - 1] as Vector2).x


## The plaza's land, left of the district line and in front of the far shore, for
## LuchaUI to use in place of its 4000 m box (so the sea can show right of the line;
## no plaza camera sees the change).
static func plaza_land_outline() -> PackedVector2Array:
	var pts := PackedVector2Array([Vector2(-HORIZON, 80.0), Vector2(district_line(0.0), 80.0)])
	var d := 0.0
	while d <= -FAR_SHORE_Z:
		pts.append(Vector2(district_line(d), -d))
		d += 10.0
	pts.append(Vector2(-HORIZON, FAR_SHORE_Z))
	return pts


## The beach's width at depth z: up to BEACH_MAX, never past the district line.
static func beach_w(z: float) -> float:
	return clampf(coast_x(z) - (district_line(-z) + 0.5), 4.0, BEACH_MAX)


## The shore's profile: the ground's height `u` metres in from the waterline (minus is
## under the water): under the water it shelves away, the wet sand rises from the
## waterline, then the dry sand rises gently to meet the land at GROUND_Y.
static func shore_y(u: float, w: float, z := 0.0) -> float:
	var wet := wet_w(z)
	if u <= 0.0:
		return lerpf(WATER_Y, WATER_Y - 0.7, clampf(-u / 4.0, 0.0, 1.0))
	if u <= wet:
		return lerpf(WATER_Y, WET_TOP, u / wet)
	return lerpf(WET_TOP, GROUND_Y + berm(z), smoothstep(0.0, 1.0, (u - wet) / maxf(w - wet, 0.1)))


## The wet band's width, wider and narrower along the shore.
static func wet_w(z: float) -> float:
	return WET_W * (1.0 + 0.32 * sin(z * 0.17) + 0.18 * sin(z * 0.41 + 0.8))


## The berm: how far the beach's top stands above GROUND_Y. Nothing by the pier and the
## boardwalk, up to BERM_MAX behind the town, and nothing where the land behind is too
## narrow to come back down to the plaza's level at the district line.
static func berm(z: float) -> float:
	var strip := (coast_x(z) - beach_w(z)) - district_line(-z)
	return BERM_MAX * smoothstep(-14.0, -30.0, z) * clampf((strip - 1.0) / 5.0, 0.0, 1.0)


## The land's rise above GROUND_Y behind the beach: a hillside behind the town, past
## the headland (z < HILL_Z0). Zero at the district line, so it meets the plaza's flat
## land exactly; it climbs steeply just inside the line (that face is never seen) and
## falls gently to the beach's top, the side the pier looks at.
static func land_h(x: float, z: float) -> float:
	var x0 := district_line(-z)
	var x1 := coast_x(z) - beach_w(z)
	if x1 - x0 < 1.0:
		return 0.0
	var f := clampf((x - x0) / (x1 - x0), 0.0, 1.0)
	if z > HILL_Z0:
		return berm(z) * smoothstep(0.45, 1.0, f)
	var ramp := smoothstep(HILL_Z0, HILL_Z0 - 10.0, z)
	var amp := minf(HILL_MAX, (x1 - x0) * 0.5) * (0.78 + 0.16 * sin(z * 0.21) + 0.1 * sin(z * 0.47 + 1.7))
	var profile := smoothstep(0.0, HILL_PEAK, f) if f < HILL_PEAK else pow(1.0 - (f - HILL_PEAK) / (1.0 - HILL_PEAK), 1.25)
	return ramp * amp * profile + berm(z) * smoothstep(0.45, 1.0, f)


## The ground's height at (x, z).
static func ground_y(x: float, z: float) -> float:
	var w := beach_w(z)
	var u := coast_x(z) - x
	if u >= w:
		return GROUND_Y + land_h(x, z)
	return shore_y(u, w, z)


# ---------------------------------------------------------------- build and tick

func build() -> void:
	name = "DelMarScenery"
	_rng.seed = 2611
	_build_ground()
	_build_far_shore()
	_build_headland()
	_build_boardwalk()
	_build_town()
	_build_shore_dressing()
	_build_sea_life()
	_build_clouds()


func tick(delta: float) -> void:
	_t += delta
	for s in _ships:
		var n: Node3D = s[0]
		var span: float = float(s[2]) - float(s[1])
		# A slow ping-pong across the drift box (a cosine, so it eases at each end).
		n.position.x = float(s[1]) + span * (0.5 - 0.5 * cos(_t * float(s[4]) + float(s[3])))
		n.position.y = WATER_Y + sin(_t * 0.7 + float(s[3])) * 0.12
		n.rotation.z = sin(_t * 0.55 + float(s[3]) * 1.7) * 0.025
	for b in _bobbers:
		var n2: Node3D = b[0]
		n2.position.y = float(b[1]) + sin(_t * 0.9 + float(b[2])) * 0.08
	for c in _clouds:
		var cn: Node3D = c[0]
		# Drift right 60 m, then back to where the plan placed it, only ever off screen
		# (it jumped back 60 m in plain view every 100 s).
		LuchaKit.drift_cloud(cn, 0.6 * delta, float(c[2]), float(c[1]), float(c[1]) + 60.0)
	if _foam != null:
		# The foam line breathes in and out a little with the swell.
		_foam.position.x = sin(_t * 0.8) * 0.18


## The water node, for the game's splashes.
func water_node() -> Node3D:
	return water


# ---------------------------------------------------------------- the ground and the sea

func _build_ground() -> void:
	# Rows across the shore every 2.5 m from the front (z +60) to the far shore, each of
	# the same 14 points: six over the land from the district line (on the plaza's flat,
	# GROUND_Y) over the hillside to the beach's top, three down the dry sand, then the
	# wet sand's top, its middle, the waterline, and two under the water.
	var rows: Array = []
	var z := 60.0
	while z >= FAR_SHORE_Z - 0.01:
		var cx := coast_x(z)
		var w := beach_w(z)
		var x0 := district_line(-z) if z < 0.0 else district_line(0.0)
		var x1 := cx - w
		var row := PackedVector3Array()
		for f in [0.0, HILL_PEAK, 0.34, 0.56, 0.78, 1.0]:
			var x := lerpf(x0, x1, f)
			row.append(Vector3(x, GROUND_Y + land_h(x, z), z))
		var wet := wet_w(z)
		for u in [wet + (w - wet) * 0.72, wet + (w - wet) * 0.44, wet + (w - wet) * 0.18, wet, wet * 0.5, 0.0, -1.5, -4.0]:
			row.append(Vector3(cx - u, shore_y(u, w, z), z))
		rows.append(row)
		z -= 2.5
	# Surfaces: 0 land, 1 the hillside's grass, 2 dry sand, 3 wet sand.
	var sts: Array = []
	for i in 4:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		sts.append(st)
	for r in rows.size() - 1:
		var a: PackedVector3Array = rows[r]
		var b: PackedVector3Array = rows[r + 1]
		for k in 13:
			var surf := 3
			if k <= 4:
				surf = 1 if (a[k].y + a[k + 1].y + b[k].y + b[k + 1].y) * 0.25 > GROUND_Y + 0.8 else 0
			elif k <= 8:
				surf = 2
			_face(sts[surf], a[k], a[k + 1], b[k + 1])
			_face(sts[surf], a[k], b[k + 1], b[k])
	var ground := MeshInstance3D.new()
	ground.name = "Ground"
	var mesh := ArrayMesh.new()
	var cols := [LAND, GRASS, SAND, WET_SAND]
	for i in 4:
		var before := mesh.get_surface_count()
		(sts[i] as SurfaceTool).commit(mesh)
		if mesh.get_surface_count() > before:
			mesh.surface_set_material(mesh.get_surface_count() - 1, LuchaKit.mat(cols[i]))
	ground.mesh = mesh
	CelPass.unify(ground)  # its tones as atlas UVs, on the one material
	add_child(ground)
	# The foam line: a thin wavy band lying on the water just off the waterline.
	var fst := SurfaceTool.new()
	fst.begin(Mesh.PRIMITIVE_TRIANGLES)
	var fz := 60.0
	var prev_in := Vector3.ZERO
	var prev_out := Vector3.ZERO
	var first := true
	while fz >= FAR_SHORE_Z - 0.01:
		var cx := coast_x(fz)
		var wob := 0.3 + 0.75 * absf(sin(fz * 0.42)) + 0.2 * sin(fz * 1.9 + 0.6)  # scallops
		var pin := Vector3(cx + 0.15, WATER_Y + 0.012, fz)
		var pout := Vector3(cx + 0.15 + wob, WATER_Y + 0.012, fz)
		if not first:
			_face(fst, prev_in, prev_out, pout)
			_face(fst, prev_in, pout, pin)
		prev_in = pin
		prev_out = pout
		first = false
		fz -= 1.5
	_foam = MeshInstance3D.new()
	_foam.name = "Foam"
	_foam.mesh = fst.commit()
	CelPass.paint(_foam, FOAM)
	_foam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_foam)
	# The sea, one flat mesh in two tones that share their edge exactly (so no ink
	# between them): the shallows, a paler band along the shore from under the sand's
	# toe out about 9 m, and the deep beyond, round behind the far shore to the horizon.
	var sh := SurfaceTool.new()
	sh.begin(Mesh.PRIMITIVE_TRIANGLES)
	var mid_st := SurfaceTool.new()
	mid_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pc := Vector3.ZERO
	var edge := PackedVector2Array()  # the shallows' outer edge, front to back
	var sz := 60.0
	var have_prev := false
	var pa := Vector3.ZERO
	var pb := Vector3.ZERO
	while sz >= FAR_SHORE_Z - 0.01:
		var cx := coast_x(sz)
		var out := cx + 5.5 + 2.2 * sin(sz * 0.11) + 1.0 * sin(sz * 0.31 + 0.9)
		var out2 := out + 7.0 + 3.0 * sin(sz * 0.07 + 2.0) + 1.5 * sin(sz * 0.23)
		var a3 := Vector3(cx - 5.0, WATER_Y, sz)
		var b3 := Vector3(out, WATER_Y, sz)
		var c3 := Vector3(out2, WATER_Y, sz)
		edge.append(Vector2(out2, sz))
		if have_prev:
			_tri(sh, pa, pb, b3, Vector3.UP)
			_tri(sh, pa, b3, a3, Vector3.UP)
			_tri(mid_st, pb, pc, c3, Vector3.UP)
			_tri(mid_st, pb, c3, b3, Vector3.UP)
		pa = a3
		pb = b3
		pc = c3
		have_prev = true
		sz -= 5.0
	var deep := PackedVector2Array()
	for p in edge:
		deep.append(p)
	deep.append(Vector2(-HORIZON, FAR_SHORE_Z - 6.0))
	deep.append(Vector2(-HORIZON, -HORIZON))
	deep.append(Vector2(HORIZON, -HORIZON))
	deep.append(Vector2(HORIZON, 60.0))
	var dp := SurfaceTool.new()
	dp.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tris := Geometry2D.triangulate_polygon(deep)
	for k in range(0, tris.size(), 3):
		_tri(dp, Vector3(deep[tris[k]].x, WATER_Y, deep[tris[k]].y), Vector3(deep[tris[k + 1]].x, WATER_Y, deep[tris[k + 1]].y),
			Vector3(deep[tris[k + 2]].x, WATER_Y, deep[tris[k + 2]].y), Vector3.UP)
	var sea_mesh := ArrayMesh.new()
	dp.commit(sea_mesh)
	sea_mesh.surface_set_material(0, LuchaKit.mat(SEA))
	sh.commit(sea_mesh)
	sea_mesh.surface_set_material(1, LuchaKit.mat(SHALLOWS))
	mid_st.commit(sea_mesh)
	sea_mesh.surface_set_material(2, LuchaKit.mat(SEA_MID))
	water = MeshInstance3D.new()
	water.name = "Sea"
	water.mesh = sea_mesh
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(water)


## The far shore at z -300 (where the plaza's land ends, behind the lowered mountains):
## a beach shelving into the sea along it, and overlapping low faceted hills just
## inland, so the far side of the bay reads as a coast, not a cut.
func _build_far_shore() -> void:
	var root := Node3D.new()
	root.name = "FarShore"
	add_child(root)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var wst := SurfaceTool.new()
	wst.begin(Mesh.PRIMITIVE_TRIANGLES)
	var x := -600.0
	while x < coast_x(FAR_SHORE_Z) - 0.01:
		var x2 := minf(x + 20.0, coast_x(FAR_SHORE_Z))
		var zs := [FAR_SHORE_Z, FAR_SHORE_Z - 3.5, FAR_SHORE_Z - 5.0, FAR_SHORE_Z - 9.0]
		var ys := [GROUND_Y, WET_TOP, WATER_Y, WATER_Y - 0.7]
		for k in 3:
			var target: SurfaceTool = st if k == 0 else wst
			var a := Vector3(x, ys[k], zs[k])
			var b := Vector3(x2, ys[k], zs[k])
			var c := Vector3(x2, ys[k + 1], zs[k + 1])
			var d := Vector3(x, ys[k + 1], zs[k + 1])
			_face(target, a, b, c)
			_face(target, a, c, d)
		x = x2
	var mesh := ArrayMesh.new()
	st.commit(mesh)
	mesh.surface_set_material(0, LuchaKit.mat(SAND))
	wst.commit(mesh)
	mesh.surface_set_material(1, LuchaKit.mat(WET_SAND))
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	CelPass.unify(mi)  # its two tones as atlas UVs, on the one material
	root.add_child(mi)
	# The hills behind the far shore, in rows that step back by colour (no fog in the
	# look): low sandy dunes, then faceted green hills, then paler blue-green ones, then a
	# hazy blue ridge. Each green row is PlazaMountains' faceted massif (big planes in
	# three tones), so the ridgelines and their shadow sides read; toward the spit the
	# rows come down and end in a rocky point.
	var end_x := coast_x(FAR_SHORE_Z) - 4.0
	for rowi in 4:
		var hx := -170.0 + rowi * 11.0
		while hx < end_x - 6.0:
			var w := _rng.randf_range(22.0, 40.0) * (1.0 + 0.45 * rowi)
			var taper := clampf((end_x - (hx + w * 0.5)) / 60.0, 0.25, 1.0)  # lower toward the spit
			var h: float = [_rng.randf_range(3.0, 5.0), _rng.randf_range(9.0, 14.0), _rng.randf_range(13.0, 18.0), _rng.randf_range(16.0, 22.0)][rowi] * taper
			var hz: float = FAR_SHORE_Z + [9.0, 21.0, 36.0, 52.0][rowi] + _rng.randf_range(0.0, 5.0)
			# Never out over the bay: a hill ends a little inland of the waterline at its depth.
			w = minf(w, maxf((coast_x(hz) - 6.0 - hx) * 1.6, 0.0))
			if w < 12.0:
				break
			if rowi == 0:
				var dn := _mound(Vector3(hx + w * 0.5, GROUND_Y, hz), Vector3(w, h, 12.0), DUNE, 9)
				dn.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				root.add_child(dn)
			else:
				var tones: Array = HILL_ROWS[rowi - 1]
				var hill := PlazaMountains.massif(w, h, 22.0 + rowi * 6.0, _rng.randi(), tones[0], tones[1], tones[2])
				hill.position = Vector3(hx + w * 0.5, GROUND_Y - 0.4, hz)
				hill.rotation.y = _rng.randf_range(-0.12, 0.12)
				root.add_child(hill)
			hx += w * _rng.randf_range(0.5, 0.72)
	# The rocky point the hills end in, and two sea stacks off it (well clear of the
	# play strip, 300 m out).
	for k in 6:
		var s := lerpf(5.5, 2.0, float(k) / 5.0) * _rng.randf_range(0.85, 1.15)
		_rock(root, Vector3(end_x + float(k) * 3.2, WATER_Y, FAR_SHORE_Z + 6.0 - float(k) * 1.6), Vector3(s * 1.4, s * 1.3, s * 1.2), k)
	for sp in [Vector3(end_x + 26.0, 0, FAR_SHORE_Z - 6.0), Vector3(end_x + 37.0, 0, FAR_SHORE_Z + 4.0)]:
		var stack := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 1.6
		cm.bottom_radius = 3.2
		cm.height = 9.0 if sp.z < FAR_SHORE_Z else 6.0
		cm.radial_segments = 6
		cm.rings = 1
		stack.mesh = cm
		CelPass.paint(stack, ROCK_DARK)
		stack.position = Vector3(sp.x, WATER_Y + cm.height * 0.45, sp.z)
		stack.rotation.y = _rng.randf() * TAU
		stack.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(stack)
		_bush(root, Vector3(sp.x, WATER_Y + cm.height * 0.9, sp.z), 0.9)
	# A broken strip of scrub, dune bumps and palms along the foot of the hills, so the
	# far beach doesn't meet them on a ruler line.
	var fx := -150.0
	while fx < end_x:
		var at := Vector3(fx + _rng.randf_range(-2.0, 2.0), GROUND_Y - 0.1, FAR_SHORE_Z + _rng.randf_range(3.0, 7.0))
		var pick := _rng.randf()
		if pick < 0.45:
			var dune := _mound(at, Vector3(_rng.randf_range(4.0, 8.0), _rng.randf_range(0.8, 1.8), 3.0), DUNE, 7)
			dune.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			root.add_child(dune)
		elif pick < 0.8:
			_bush(root, at, _rng.randf_range(0.9, 1.6))
		else:
			var palm := _any_palm()
			palm.position = at
			palm.rotation.y = _rng.randf() * TAU
			palm.scale = Vector3.ONE * _rng.randf_range(1.2, 1.6)
			root.add_child(palm)
		fx += _rng.randf_range(4.0, 9.0)
	# Far islands on the horizon, pale and low, out past the bay to the right (beyond
	# the plaza cameras' reach at their depth: x - half width > 31.4 + 0.5436 d).
	for isle in [[580.0, -880.0, 70.0, 13.0], [705.0, -1100.0, 62.0, 18.0], [640.0, -1010.0, 30.0, 8.0]]:
		var far := PlazaMountains.massif(float(isle[2]), float(isle[3]), float(isle[2]) * 0.4, _rng.randi(), HAZE_ISLE[0], HAZE_ISLE[1], HAZE_ISLE[2])
		far.position = Vector3(float(isle[0]), WATER_Y - 0.6, float(isle[1]))
		root.add_child(far)


## The shore's dressing: a ridge of low dunes with beach grass behind the row, palms and
## bushes on the hillside, a rocky point at the bay's bend, rocks in the surf, boulders
## at the headland's foot and round the spit's lighthouse. Nothing stands in the pier's
## strip (z -2 to +2 right of x 74) or the bridge's open water.
func _build_shore_dressing() -> void:
	var root := Node3D.new()
	root.name = "ShoreDressing"
	add_child(root)
	# The dune ridge, behind and between the row's pieces along the beach's top.
	var z := -10.0
	while z > -292.0:
		var w := beach_w(z)
		if w >= 7.0:
			var u := w - _rng.randf_range(0.6, 1.8)
			var x := coast_x(z) - u
			if _clear_of_pieces(x, z, 2.6):
				var size := Vector3(_rng.randf_range(3.5, 6.5), _rng.randf_range(0.7, 1.5), _rng.randf_range(2.2, 3.4))
				var at := Vector3(x, ground_y(x, z) - 0.15, z)
				var dune := _mound(at, size, DUNE, 7)
				dune.rotation.y = _rng.randf_range(-0.5, 0.5)
				root.add_child(dune)
				_grass(root, at + Vector3(0, size.y * 0.8, 0), size.x * 0.32, 4 + _rng.randi() % 3)
		z -= _rng.randf_range(3.5, 6.5) * (1.0 + 0.5 * (-z / 250.0))
	# Front dunes on the near beach, left of the pier's root (seen in the pan).
	for p in [Vector3(58, 0, 14), Vector3(66, 0, 22), Vector3(54, 0, 28), Vector3(72, 0, 34)]:
		var at := Vector3(p.x, ground_y(p.x, p.z) - 0.15, p.z)
		var sz := Vector3(_rng.randf_range(4.0, 6.0), _rng.randf_range(0.8, 1.4), _rng.randf_range(2.5, 3.5))
		var dn := _mound(at, sz, DUNE, 7)
		dn.rotation.y = _rng.randf_range(-0.6, 0.6)
		root.add_child(dn)
		_grass(root, at + Vector3(0, sz.y * 0.8, 0), sz.x * 0.32, 5)
	# Palms and bushes on the hillside behind the town.
	var hz := HILL_Z0 - 6.0
	while hz > -78.0:
		var x0 := district_line(-hz)
		var x1 := coast_x(hz) - beach_w(hz)
		if x1 - x0 > 4.0:
			var hx := lerpf(x0, x1, _rng.randf_range(0.3, 0.8))
			var at := Vector3(hx, ground_y(hx, hz), hz)
			if _rng.randf() < 0.55:
				var palm := _any_palm()
				palm.position = at - Vector3(0, 0.1, 0)
				palm.rotation.y = _rng.randf() * TAU
				palm.scale = Vector3.ONE * _rng.randf_range(0.8, 1.05)
				root.add_child(palm)
			else:
				_bush(root, at, _rng.randf_range(0.6, 0.9))
		hz -= _rng.randf_range(2.5, 4.5)
	# The rocky point at the bay's bend: big boulders stepping out into the sea.
	var bend := Vector2(coast_x(-100.0), -100.0)
	for k in 9:
		var out := float(k) * 1.2 + _rng.randf_range(-0.4, 0.4)
		var s := lerpf(3.4, 1.0, float(k) / 8.0) * _rng.randf_range(0.8, 1.15)
		_rock(root, Vector3(bend.x + 0.5 + out, WATER_Y, bend.y + _rng.randf_range(-2.6, 2.6) - out * 0.35), Vector3(s * 1.5, s, s * 1.2), k)
	# Rocks in the surf, in clusters along the shore.
	for rz in [-24.0, -47.0, -72.0, -128.0, -163.0, -206.0, -246.0, -284.0]:
		var cx := coast_x(rz)
		for k in 3 + _rng.randi() % 3:
			var u := _rng.randf_range(-2.2, 0.8)
			var zz: float = rz + _rng.randf_range(-2.4, 2.4)
			var s := _rng.randf_range(0.5, 1.2)
			_rock(root, Vector3(cx - u, WATER_Y - 0.05, zz), Vector3(s * 1.6, s * 0.8, s * 1.2), k)
	# Boulders at the headland's foot, where its rocks meet the sand.
	for p in [Vector3(66.5, 0, -7.0), Vector3(67.5, 0, -11.5), Vector3(70.5, 0, -17.0), Vector3(43.0, 0, -15.5), Vector3(71.5, 0, -26.0), Vector3(72.0, 0, -36.0)]:
		var s := _rng.randf_range(0.9, 1.6)
		_rock(root, Vector3(p.x, ground_y(p.x, p.z), p.z), Vector3(s * 1.5, s, s * 1.2), int(p.z))
	# A rocky knoll round the spit lighthouse's foot.
	for k in 7:
		var a := float(k) / 7.0 * TAU
		var s := _rng.randf_range(1.2, 2.2)
		var px := 222.0 + cos(a) * 3.6
		var pz := -268.0 + sin(a) * 3.6
		_rock(root, Vector3(px, ground_y(px, pz), pz), Vector3(s * 1.5, s, s * 1.2), k)


func _clear_of_pieces(x: float, z: float, r: float) -> bool:
	for at in _piece_at:
		if Vector2((at as Vector3).x - x, (at as Vector3).z - z).length() < r + (at as Vector3).y:
			return false
	for q in PALMS:
		if (q as Vector2).distance_to(Vector2(x, z)) < r:
			return false
	return true


## A low faceted mound (a dune, a hill) `size` across and `size.y` tall, flat shaded.
func _mound(at: Vector3, size: Vector3, c: Color, segs: int) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.5
	sm.height = 0.5  # a regular hemisphere, 0.5 tall
	sm.radial_segments = segs
	sm.rings = 3
	sm.is_hemisphere = true
	mi.mesh = sm
	CelPass.paint(mi, c)
	mi.scale = Vector3(size.x, size.y * 2.0, size.z)
	mi.position = at
	return mi


## A boulder: a squashed low-poly ball, a third of it sunk in the ground, turned every
## which way so no two read alike.
func _rock(parent: Node3D, at: Vector3, size: Vector3, i: int) -> void:
	# Never against a building (Parker 11-10: "rocks clipping a house"): a rock keeps
	# its own half-width plus a metre off every piece's footprint, or it isn't placed.
	if not _clear_of_pieces(at.x, at.z, maxf(size.x, size.z) * 0.5 + 1.0):
		return
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.5
	sm.height = 1.0
	sm.radial_segments = 6
	sm.rings = 3
	mi.mesh = sm
	CelPass.paint(mi, ROCK if i % 3 != 1 else ROCK_DARK)
	mi.scale = size
	mi.rotation = Vector3(_rng.randf_range(-0.35, 0.35), _rng.randf() * TAU, _rng.randf_range(-0.35, 0.35))
	mi.position = at + Vector3(0, size.y * 0.18, 0)
	parent.add_child(mi)


## One of the kit's palms, or a stand-in.
func _any_palm() -> Node3D:
	var styles := []
	for nm in ["palm", "palm_b", "palm_c"]:
		if LuchaKit.kit_model_exists(nm):
			styles.append(nm)
	if not styles.is_empty():
		return LuchaKit.kit_model(str(styles[_rng.randi() % styles.size()]))
	var palm := Node3D.new()
	palm.add_child(LuchaKit.cyl(0.18, 4.6, Color("#8E5A2C"), Vector3(0, 2.3, 0)))
	palm.add_child(LuchaKit.ball(1.3, Color("#48892B"), Vector3(0, 4.8, 0)))
	return palm


## Beach grass: tufts of thin blades on a dune.
func _grass(parent: Node3D, at: Vector3, spread: float, n: int) -> void:
	for i in n:
		var tuft := Node3D.new()
		tuft.position = at + Vector3(_rng.randf_range(-spread, spread), _rng.randf_range(-0.12, 0.0), _rng.randf_range(-0.5, 0.5))
		for b in 3:
			var blade := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 0.0
			cm.bottom_radius = 0.06
			cm.height = _rng.randf_range(0.5, 0.9)
			cm.radial_segments = 3
			blade.mesh = cm
			CelPass.paint(blade, BEACH_GRASS if b != 1 else BEACH_GRASS_DARK)
			blade.position = Vector3(0, cm.height * 0.45, 0)
			blade.rotation = Vector3(_rng.randf_range(-0.35, 0.35), _rng.randf() * TAU, _rng.randf_range(-0.35, 0.35))
			tuft.add_child(blade)
		parent.add_child(tuft)


## One triangle into st, facing up out of the ground (flat shaded: the house look).
static func _face(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	var n := (b - a).cross(c - a)
	if n.length() < 0.000001:
		return
	n = n.normalized()
	if n.y < 0.0:
		n = -n
	_tri(st, a, b, c, n)


## A beach piece's turn (Parker 11-10: "face the water a little more, not just the
## camera directly"): part-way from facing the Del Mar camera toward facing the sea
## across the shore, a little different each piece, never more than 55 degrees off
## the camera so its front still reads from the pier.
func _face_yaw(x: float, z: float, max_deg := 55.0) -> float:
	var t := Vector2(coast_x(z - 1.0) - coast_x(z), -1.0).normalized()
	var sea := Vector2(-t.y, t.x)  # the shore's normal...
	if sea.x < 0.0:
		sea = -sea  # ...pointing out to sea (toward +x)
	var to_sea := atan2(sea.x, sea.y)
	var to_cam := atan2(CAM.x - x, CAM.y - z)
	var d := wrapf(to_sea - to_cam, -PI, PI)
	var blend := _rng.randf_range(0.42, 0.88)  # some nearly face the sea, some still half to the lens
	d = clampf(d * blend, deg_to_rad(-max_deg), deg_to_rad(max_deg))
	return to_cam + d + deg_to_rad(_rng.randf_range(-12.0, 12.0))


## A palm's place, slid along the shore if it would stand between the pier's camera and
## a building's front (a trunk across a door reads as a mistake).
func _unblock(q: Vector2) -> Vector2:
	for tries in 5:
		var blocked := false
		for at in _piece_at:
			var c := Vector2((at as Vector3).x, (at as Vector3).z)
			var to_c := c - CAM
			var along := (q - CAM).dot(to_c.normalized())
			if along > 0.0 and along < to_c.length() and absf((q - CAM).cross(to_c.normalized())) < (at as Vector3).y * 0.7:
				blocked = true
		if not blocked:
			return q
		q += Vector2(0.9, -4.0)
	return q


# ---------------------------------------------------------------- the headland

## The plaza's terraces end against the headland: low rocks in front, then the
## terraces' brick walls closing and stepping up behind, a parapet on each step, El
## Faro on the top, and a stone stair cut into the rocks from the boardwalk.
func _build_headland() -> void:
	var root := Node3D.new()
	root.name = "Headland"
	add_child(root)
	root.add_child(_prism([Vector2(40, -4.5), Vector2(64, -4.5), Vector2(66, -14), Vector2(44, -14)], GROUND_Y, 0.65, STONE))
	var lots: Array = [[], [], [], []]
	# The rocks' front and right faces in big stone blocks, the brick steps in brick.
	_lay_wall(lots, Vector2(40, -4.5), Vector2(64, -4.5), GROUND_Y, 0.65, 1.1, 0.5)
	_lay_wall(lots, Vector2(64, -4.5), Vector2(66, -14), GROUND_Y, 0.65, 1.1, 0.5)
	var steps := [[-14.0, -23.0, 3.1], [-23.0, -32.0, 5.7], [-32.0, -42.0, 7.6]]
	for s in steps:
		var z0: float = s[0]
		var z1: float = s[1]
		var top: float = s[2]
		var xl0 := lerpf(46.0, 56.0, (-z0 - 14.0) / 28.0)
		var xl1 := lerpf(46.0, 56.0, (-z1 - 14.0) / 28.0)
		var xr0 := lerpf(66.0, 70.0, (-z0 - 14.0) / 28.0)
		var xr1 := lerpf(66.0, 70.0, (-z1 - 14.0) / 28.0)
		root.add_child(_prism([Vector2(xl0, z0), Vector2(xr0, z0), Vector2(xr1, z1), Vector2(xl1, z1)], GROUND_Y, top, BRICK))
		_lay_wall(lots, Vector2(xl0, z0), Vector2(xr0, z0), GROUND_Y if s == steps[0] else float(steps[steps.find(s) - 1][2]), top, 0.62, 0.26)
		_lay_wall(lots, Vector2(xr0, z0), Vector2(xr1, z1), GROUND_Y, top, 0.62, 0.26)
		root.add_child(_prism([Vector2(xl0, z0), Vector2(xr0, z0), Vector2(xr0, z0 - 0.3), Vector2(xl0, z0 - 0.3)], top, top + 0.55, PARAPET))
		root.add_child(_prism([Vector2(xl0 + 0.2, z0 - 0.3), Vector2(xr0 - 0.2, z0 - 0.3), Vector2(xr1 - 0.2, z1), Vector2(xl1 + 0.2, z1)], top, top + 0.01, GRASS))
	# The plaza's terraces end in raw mortar faces along the lens's cut (no plaza camera
	# sees them; the pan to Del Mar does): brick them and cap each with a parapet.
	var offs: Array = []
	for t in LuchaUI.TERRACES:
		offs.append(float(t[0]))
	offs.append(float(offs[offs.size() - 1]) + LuchaUI.TERRACE_BACK)
	for k in LuchaUI.TERRACES.size():
		var ea: Vector2 = LuchaUI._lens(LuchaUI.LENS_T1, float(offs[k]))
		var eb: Vector2 = LuchaUI._lens(LuchaUI.LENS_T1, float(offs[k + 1]))
		var etop: float = Stage.PLAZA_GROUND + float(LuchaUI.TERRACES[k][1])
		var fwd := Vector2(-(eb - ea).y, (eb - ea).x).normalized()
		if fwd.y < 0.0:
			fwd = -fwd  # out of the face, toward the camera
		_lay_wall(lots, ea + fwd * 0.01, eb + fwd * 0.01, GROUND_Y, etop, 0.62, 0.26, fwd)
		root.add_child(_prism([ea + fwd * 0.12, eb + fwd * 0.12, eb - fwd * 0.2, ea - fwd * 0.2], etop, etop + 0.55, PARAPET))
	_commit_walls(root, lots)
	# A few bushes along the rock top and the steps.
	for p in [Vector3(48, 0.65, -9), Vector3(58, 0.65, -11), Vector3(52, 3.1, -19), Vector3(63, 5.7, -27), Vector3(58, 7.6, -37)]:
		_bush(root, p, 0.55)
	# The stair: seven stone steps from the boardwalk (y -0.6) up onto the rocks (+0.65).
	var rise := (0.65 - -0.6) / 7.0
	for i in 7:
		var zc := -4.1 - 0.29 * (i + 0.5)
		var h := (-0.6 + rise * (i + 1)) - GROUND_Y
		root.add_child(LuchaKit.box(Vector3(4.0, h, 0.29), KERB, Vector3(47.0, GROUND_Y + h * 0.5, zc)))
	# El Faro on the top step.
	_place(root, "el_faro", Vector3(61.0, 7.6, -24.0), 0.0)


# ---------------------------------------------------------------- the boardwalk and the beach

func _build_boardwalk() -> void:
	var root := Node3D.new()
	root.name = "Boardwalk"
	add_child(root)
	var bw := LuchaKit.kit_model("boardwalk")  # the Carpenter's: 30 m from its left end, top at its origin
	if bw != null:
		bw.position = Vector3(PIER_ROOT - 30.0, BOARD_Y, 0.0)
		root.add_child(bw)
	else:
		root.add_child(LuchaKit.box(Vector3(30.0, 0.32, 3.6), BOARD, Vector3(PIER_ROOT - 15.0, GROUND_Y + 0.16, -2.3)))
	# The pier (the Carpenter's: origin at its end, x -30.65 to 0, its steps down to
	# the boardwalk's landing at the root). Its collision is Stage's; this is the look.
	var pier := LuchaKit.kit_model("pier")
	if pier != null:
		pier.position = Vector3(PIER_END, 0.0, 0.0)
		root.add_child(pier)
	else:
		for i in 3:
			var h := 0.2 * (i + 1) + 0.32
			root.add_child(LuchaKit.box(Vector3(0.35, h, 3.2), BOARD, Vector3(73.2 + 0.35 * i - 0.7, GROUND_Y + h * 0.5, 0.0)))
	# Light posts and festoons between them.
	var ends: Array = []  # [left hang, right hang] per post
	for px in POSTS:
		var at := Vector3(px, BOARD_Y, -3.9)
		var post := LuchaKit.kit_model("light_post")  # the Carpenter's, with hang_l / hang_r
		if post != null:
			post.position = at
			root.add_child(post)
			var hl := post.find_child("hang_l", true, false) as Node3D
			var hr := post.find_child("hang_r", true, false) as Node3D
			if hl != null and hr != null:
				ends.append([at + _local_of(post, hl), at + _local_of(post, hr)])
				continue
		else:
			root.add_child(LuchaKit.cyl(0.09, 4.5, POST, at + Vector3(0, 2.25, 0)))
			root.add_child(LuchaKit.ball(0.14, LuchaKit.GOLD, at + Vector3(0, 4.55, 0)))
		ends.append([at + Vector3(0, 4.3, 0), at + Vector3(0, 4.3, 0)])
	for i in ends.size() - 1:
		_festoon(root, ends[i][1], ends[i + 1][0], 0.7)
	# Umbrellas and chairs on the sand.
	for u in UMBRELLAS:
		var p := Vector3(u.x, ground_y(u.x, u.y), u.y)
		var um := LuchaKit.kit_model("beach_umbrella_" + "abcde"[int(u.z) % 5])
		if um == null:
			um = LuchaKit.kit_model("beach_umbrella")
		if um != null:
			um.position = p
			um.rotation.y = _face_yaw(u.x, u.y) + _rng.randf_range(-0.4, 0.4)
			root.add_child(um)
		else:
			root.add_child(LuchaKit.cyl(0.04, 2.3, Color("#F2EEE4"), p + Vector3(0, 1.15, 0)))
			var cone := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 0.02
			cm.bottom_radius = 1.25
			cm.height = 0.55
			cm.radial_segments = 8
			cone.mesh = cm
			CelPass.paint(cone, BULBS[int(u.z) % BULBS.size()])
			cone.position = p + Vector3(0, 2.3, 0)
			root.add_child(cone)
		var chair := LuchaKit.kit_model("beach_chair_" + ("a" if int(u.z) % 2 == 0 else "b"))
		if chair != null:
			chair.rotation.y = _face_yaw(u.x, u.y)
			var off := Vector3(0.9, 0.0, 0.6).rotated(Vector3.UP, chair.rotation.y)
			chair.position = Vector3(p.x + off.x, ground_y(p.x + off.x, p.z + off.z), p.z + off.z)
			root.add_child(chair)


# ---------------------------------------------------------------- the beach town

func _build_town() -> void:
	var root := Node3D.new()
	root.name = "BeachTown"
	add_child(root)
	for p in PIECES:
		var x: float = p[1]
		var z: float = p[2]
		# Turned part-way to the sea (the table's yaw was the camera's). Stood at the
		# ground's lower, seaward side so no corner floats over the sloping sand.
		var stem := str(p[0])
		# The two-storey houses stand back up the beach where it's wide, the huts and
		# cabanas forward: no single baseline (and the houses a metre higher).
		if stem.begins_with("beach_house") and beach_w(z) >= 15.0:
			x -= 3.4
		var yaw := _face_yaw(x, z, 24.0 if stem in ["beach_house_a", "lifeguard_tower", "beach_bar"] else 55.0) if stem != "lighthouse_spit" else 0.0
		_place(root, stem, Vector3(x, minf(ground_y(x, z), ground_y(x + 1.2, z)), z), yaw)
		var fp: Array = STAND_IN.get(stem, [3.0, 3.5, 3.0, ""])
		_piece_at.append(Vector3(x, Vector2(float(fp[0]), float(fp[2])).length() * 0.5, z))
	for i in PALMS.size():
		var q: Vector2 = _unblock(PALMS[i])
		var styles := []
		for nm in ["palm", "palm_b", "palm_c"]:
			if LuchaKit.kit_model_exists(nm):
				styles.append(nm)
		var palm: Node3D = LuchaKit.kit_model(str(styles[i % styles.size()])) if not styles.is_empty() else null
		if palm == null:
			palm = Node3D.new()
			palm.add_child(LuchaKit.cyl(0.18, 4.6, Color("#8E5A2C"), Vector3(0, 2.3, 0)))
			palm.add_child(LuchaKit.ball(1.3, Color("#48892B"), Vector3(0, 4.8, 0)))
		palm.position = Vector3(q.x, ground_y(q.x, q.y), q.y)
		palm.rotation = Vector3(_rng.randf_range(-0.06, 0.06), _rng.randf() * TAU, _rng.randf_range(-0.06, 0.06))
		palm.scale = Vector3.ONE * _rng.randf_range(0.85, 1.15)
		root.add_child(palm)


## A kit piece at `at`, turned by yaw, with its hang_* festoons and plant_pot_* pots,
## or a stand-in block if the piece hasn't landed.
func _place(parent: Node3D, stem: String, at: Vector3, yaw: float) -> Node3D:
	var k := LuchaKit.kit_model(stem)
	if k == null:
		var s: Array = STAND_IN.get(stem, [3.0, 3.5, 3.0, "#F2E6C8"])
		k = Node3D.new()
		k.add_child(LuchaKit.box(Vector3(s[0], s[1], s[2]), Color(str(s[3])), Vector3(0, float(s[1]) * 0.5, 0)))
		k.add_child(LuchaKit.box(Vector3(float(s[0]) + 0.4, 0.35, float(s[2]) + 0.4), Color("#D2643A"), Vector3(0, float(s[1]) + 0.17, 0)))
	k.position = at
	k.rotation.y = yaw
	parent.add_child(k)
	# Festoons between the piece's hang markers, in its own frame.
	var hangs: Array = []
	for n in k.find_children("hang_*", "Node3D", true, false):
		hangs.append(n)
	hangs.sort_custom(func(a, b): return str(a.name) < str(b.name))
	# (Festoons only on the near pieces: past 100 m a bulb is under a pixel.)
	for i in range(0, hangs.size() - 1 if at.z > -100.0 else 0, 2):
		_festoon(k, k.to_local((hangs[i] as Node3D).global_position) if k.is_inside_tree() else _local_of(k, hangs[i]),
			k.to_local((hangs[i + 1] as Node3D).global_position) if k.is_inside_tree() else _local_of(k, hangs[i + 1]), 0.25)
	# The life ring on the lifeguard tower's spot (the UI creator's).
	var ring_spot := k.find_child("ring_spot", true, false) as Node3D
	if ring_spot != null:
		var ring := LuchaKit.kit_model("life_ring")
		if ring != null:
			ring_spot.add_child(ring)
		if ring_spot is MeshInstance3D:
			(ring_spot as MeshInstance3D).mesh = null
	# Pots on its plant_pot markers (the UI creator's, each carrying its own pot).
	var turn := 0
	for n in k.find_children("plant_pot_*", "Node3D", true, false):
		var pot := LuchaKit.kit_model("plant_pot_" + "abc"[turn % 3])
		turn += 1
		if pot != null:
			(n as Node3D).add_child(pot)
		if n is MeshInstance3D:
			(n as MeshInstance3D).mesh = null
	return k


static func _local_of(root: Node3D, n: Node3D) -> Vector3:
	var xf := Transform3D.IDENTITY
	var cur: Node = n
	while cur != null and cur != root:
		if cur is Node3D:
			xf = (cur as Node3D).transform * xf
		cur = cur.get_parent()
	return xf.origin


## A string of festoon bulbs (the UI creator's `festoon_bulb`, or little balls) hung
## between a and b with a sag, in `parent`'s frame.
func _festoon(parent: Node3D, a: Vector3, b: Vector3, sag: float) -> void:
	var n := maxi(3, int(a.distance_to(b) / 0.6))
	var prev := a
	for i in n + 1:
		var f := float(i) / n
		var p := a.lerp(b, f) + Vector3(0, -sag * 4.0 * f * (1.0 - f), 0)
		if i > 0:
			# The wire between two bulbs, in the parent's own frame: a thin cylinder
			# whose axis (its Y) runs from prev to p.
			var seg := LuchaKit.cyl(0.012, prev.distance_to(p), LuchaKit.INK)
			var yax := (p - prev).normalized()
			var xax := yax.cross(Vector3.BACK)
			if xax.length() < 0.01:
				xax = yax.cross(Vector3.RIGHT)
			xax = xax.normalized()
			seg.transform = Transform3D(Basis(xax, yax, xax.cross(yax)), (prev + p) * 0.5)
			parent.add_child(seg)
		if i > 0 and i < n:
			var bulb := LuchaKit.kit_model("festoon_bulb")
			if bulb != null:
				bulb.position = p
				LuchaKit.tint_part(bulb, "bulb_globe", BULBS[i % BULBS.size()])
				parent.add_child(bulb)
			else:
				parent.add_child(LuchaKit.ball(0.07, BULBS[i % BULBS.size()], p - Vector3(0, 0.08, 0)))
		prev = p


# ---------------------------------------------------------------- the sea's life

func _build_sea_life() -> void:
	var root := Node3D.new()
	root.name = "SeaLife"
	add_child(root)
	for i in SHIPS.size():
		var s: Array = SHIPS[i]
		var ship := LuchaKit.kit_model(str(s[0]))
		if ship == null:
			ship = _ship_stand_in(float(s[4]), Color(str(s[5])))
		if bool(s[6]):
			ship.rotation.y = PI
		ship.position = Vector3(float(s[1]), WATER_Y, float(s[3]))
		root.add_child(ship)
		# About a minute end to end for the big ones, a little quicker for the small.
		_ships.append([ship, s[1], s[2], _rng.randf() * TAU, 0.05 + 0.02 * (i % 3)])
	for isle in ISLES:
		var k := LuchaKit.kit_model(str(isle[0]))
		var w: float = isle[3]
		if k == null:
			k = Node3D.new()
			if str(isle[0]) == "isle_band_raft":
				k.add_child(LuchaKit.box(Vector3(w, 0.4, w), BOARD, Vector3(0, 0.2, 0)))
				k.add_child(LuchaKit.box(Vector3(w * 0.6, 2.6, w * 0.6), Color(str(isle[4])), Vector3(0, 1.7, 0)))
			else:
				var disc := LuchaKit.cyl(w * 0.5, 0.9, SAND, Vector3(0, 0.3, 0))
				(disc.mesh as CylinderMesh).radial_segments = 24
				k.add_child(disc)
				var palm := LuchaKit.kit_model("palm")
				if palm != null:
					palm.position = Vector3(-w * 0.15, 0.75, 0)
					k.add_child(palm)
				k.add_child(LuchaKit.box(Vector3(1.4, w * 0.5, 1.4), Color(str(isle[4])), Vector3(w * 0.18, 0.75 + w * 0.25, 0)))
		k.position = Vector3(float(isle[1]), WATER_Y, float(isle[2]))
		k.rotation.y = atan2(CAM.x - float(isle[1]), CAM.y - float(isle[2]))  # the flat faces the pier
		root.add_child(k)
		if str(isle[0]) == "isle_band_raft":
			_bobbers.append([k, WATER_Y, _rng.randf() * TAU])


func _ship_stand_in(length: float, sail: Color) -> Node3D:
	var root := Node3D.new()
	root.add_child(LuchaKit.box(Vector3(length, 1.6, length * 0.25), Color("#6A4128"), Vector3(0, 0.6, 0)))
	root.add_child(LuchaKit.box(Vector3(length * 0.9, 0.3, length * 0.25), Color("#F2E6C8"), Vector3(0, 1.5, 0)))
	var masts := 2 if length > 15.0 else 1
	for m in masts:
		var mx := (m - (masts - 1) * 0.5) * length * 0.35
		root.add_child(LuchaKit.cyl(0.12, length * 0.6, POST, Vector3(mx, 1.6 + length * 0.3, 0)))
		root.add_child(LuchaKit.box(Vector3(length * 0.28, length * 0.36, 0.08), sail, Vector3(mx, 1.6 + length * 0.36, 0.1)))
	return root


func _build_clouds() -> void:
	var root := Node3D.new()
	root.name = "SeaClouds"
	add_child(root)
	for i in CLOUDS.size():
		var c: Vector4 = CLOUDS[i]
		var cloud := LuchaKit.swirl_cloud(c.w, i + 3)
		cloud.position = Vector3(c.x, c.y, c.z)
		cloud.rotation.y = deg_to_rad(_rng.randf_range(-12.0, 12.0))
		root.add_child(cloud)
		_clouds.append([cloud, c.x, c.w * 0.5])


# ---------------------------------------------------------------- mesh helpers

## A flat polygon (x, z points) at height y, facing up.
func _flat(pts: PackedVector2Array, y: float, c: Color, nm := "") -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tris := Geometry2D.triangulate_polygon(pts)
	for k in range(0, tris.size(), 3):
		_tri(st, Vector3(pts[tris[k]].x, y, pts[tris[k]].y), Vector3(pts[tris[k + 1]].x, y, pts[tris[k + 1]].y), Vector3(pts[tris[k + 2]].x, y, pts[tris[k + 2]].y), Vector3.UP)
	var mi := MeshInstance3D.new()
	if nm != "":
		mi.name = nm
	mi.mesh = st.commit()
	CelPass.paint(mi, c)
	return mi


## A solid standing on its floor-plan outline (x, z points), from y0 up to y1: its top
## and every side, flat per face (no bottom: it stands on the ground).
func _prism(outline: Array, y0: float, y1: float, c: Color) -> MeshInstance3D:
	var pts := PackedVector2Array()
	for p in outline:
		pts.append(p)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tris := Geometry2D.triangulate_polygon(pts)
	for k in range(0, tris.size(), 3):
		_tri(st, Vector3(pts[tris[k]].x, y1, pts[tris[k]].y), Vector3(pts[tris[k + 1]].x, y1, pts[tris[k + 1]].y), Vector3(pts[tris[k + 2]].x, y1, pts[tris[k + 2]].y), Vector3.UP)
	var centre := Vector2.ZERO
	for p in pts:
		centre += p
	centre /= pts.size()
	for i in pts.size():
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[(i + 1) % pts.size()]
		var e := b - a
		var n := Vector3(e.y, 0, -e.x).normalized()
		var mid := (a + b) * 0.5
		if Vector2(n.x, n.z).dot(mid - centre) < 0.0:
			n = -n
		_quad(st, Vector3(a.x, y0, a.y), Vector3(b.x, y0, b.y), Vector3(b.x, y1, b.y), Vector3(a.x, y1, a.y), n)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	CelPass.paint(mi, c)
	return mi


static func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, n: Vector3) -> void:
	_tri(st, a, b, c, n)
	_tri(st, a, c, d, n)


## One triangle facing n (Godot's front faces wind clockwise seen from the front).
static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, n: Vector3) -> void:
	if (b - a).cross(c - a).dot(n) > 0.0:
		var t := b
		b = c
		c = t
	st.set_normal(n)
	st.add_vertex(a)
	st.set_normal(n)
	st.add_vertex(b)
	st.set_normal(n)
	st.add_vertex(c)


## Bricks (or stone blocks) laid on a wall face from a to b (floor plan), y0 to y1:
## flat quads 4 mm proud of the face, in running bond, so the joints are colour and
## the ink leaves them alone (the paving law). Each goes into one of four tone lots.
const WALL_TONES := [Color("#C49A70"), Color("#B5885E"), Color("#CFA97F"), Color("#A97B55")]
func _lay_wall(lots: Array, a: Vector2, b: Vector2, y0: float, y1: float, bl: float, course: float, facing := Vector2.ZERO) -> void:
	var run := a.distance_to(b)
	var tan2 := (b - a) / run
	var n := Vector3(tan2.y, 0, -tan2.x)
	var mid := (a + b) * 0.5
	var want := facing if facing != Vector2.ZERO else mid - Vector2(58, -24)  # outward from the headland's middle
	if Vector2(n.x, n.z).dot(want) < 0.0:
		n = -n
	var tan := Vector3(tan2.x, 0, tan2.y)
	var y := y0 + 0.04
	var row := 0
	while y + course <= y1 - 0.02:
		var d := (bl * 0.5 if row % 2 == 1 else 0.0) + 0.04
		while d + bl < run:
			var c2 := a + tan2 * (d + bl * 0.5)
			var pos := Vector3(c2.x, y + course * 0.5, c2.y) + n * 0.004
			var bx := tan * (bl - 0.06)
			var bz := Vector3.UP * (course - 0.06)
			if bx.cross(n).dot(bz) < 0.0:
				bz = -bz
			(lots[_rng.randi() % 4] as Array).append(Transform3D(Basis(bx, n, bz), pos))
			d += bl
		y += course
		row += 1


func _commit_walls(parent: Node3D, lots: Array) -> void:
	for i in WALL_TONES.size():
		var xs: Array = lots[i]
		if xs.is_empty():
			continue
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		var pm := PlaneMesh.new()
		pm.size = Vector2.ONE
		mm.mesh = pm
		mm.instance_count = xs.size()
		for k in xs.size():
			mm.set_instance_transform(k, xs[k])
		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		CelPass.paint(mmi, WALL_TONES[i])
		parent.add_child(mmi)


## A bush: the kit's `bush` if delivered, else a cluster of green balls.
func _bush(parent: Node3D, at: Vector3, size: float) -> void:
	var k := LuchaKit.kit_model("bush")
	if k != null:
		k.position = at
		k.scale = Vector3.ONE * size / 0.6
		parent.add_child(k)
		return
	for i in 3:
		var r := size * _rng.randf_range(0.7, 1.0)
		parent.add_child(LuchaKit.ball(r, [Color("#4E8A34"), Color("#5E9C3C"), Color("#3F7A2E")][i], at + Vector3(_rng.randf_range(-size, size) * 0.6, r * 0.8, _rng.randf_range(-size, size) * 0.4)))
