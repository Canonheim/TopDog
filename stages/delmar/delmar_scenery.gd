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
const BEACH_W := 10.0  # the beach, from the land's edge down to the waterline
const SAND_LOW := -1.95  # the sand runs on just under the water
const WATER_Y := -1.8  # Stage.WATER_Y
const FAR_SHORE_Z := -300.0  # the land ends here, behind the plaza's mountains
const HORIZON := 2500.0
## The waterline (land to the left and back, sea to the right and front), from the plan.
const COAST := [Vector2(84, 60), Vector2(86, 0), Vector2(90, -40), Vector2(108, -100), Vector2(150, -170),
	Vector2(190, -230), Vector2(225, -270), Vector2(240, -300)]
const LAND := Color("#C9BE92")
const SAND := Color("#E6D1A0")
const WET_SAND := Color("#CDB683")
const SEA := Color("#2F7FD0")
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
	["lifeguard_tower", 79.0, 7.0, 0], ["beach_bar", 71.0, -8.0, 0],
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
]
## Stand-in sizes [w, h, d] and colours for pieces that haven't landed.
const STAND_IN := {
	"lifeguard_tower": [2.9, 5.7, 2.9, "#F2E6C8"], "beach_bar": [7.0, 3.75, 3.6, "#1FB8AE"], "beach_house_a": [5.0, 7.8, 4.4, "#F2EEE4"],
	"beach_house_b": [4.8, 7.5, 4.4, "#E86A6A"], "beach_hut_a": [2.6, 3.6, 2.4, "#E86A9A"], "beach_hut_b": [2.8, 3.4, 2.4, "#1FB8AE"],
	"beach_hut_c": [2.9, 3.6, 2.6, "#A8D05A"], "cabana_a": [3.2, 3.2, 3.0, "#F2E6C8"], "cabana_b": [3.1, 4.0, 3.0, "#1FB8AE"],
	"stall_coco": [3.5, 3.0, 1.8, "#A8D05A"], "stall_paletas": [3.2, 2.9, 1.8, "#9DC3E6"], "lighthouse_spit": [4.0, 14.0, 4.0, "#F2EEE4"],
	"el_faro": [3.2, 17.0, 3.2, "#F2EEE4"],
}
const PALMS := [Vector2(81.3, -8.5), Vector2(82.7, -22.5), Vector2(84.7, -41.6), Vector2(91.3, -63.6), Vector2(99.1, -89.6),
	Vector2(114.1, -120.8), Vector2(133.3, -152.8), Vector2(158.8, -193.1), Vector2(185.9, -233.6), Vector2(62.0, -3.0), Vector2(56.0, -16.0)]
const UMBRELLAS := [Vector3(70, 2, 0), Vector3(74, 9, 1), Vector3(82, 15, 2), Vector3(66, 10, 3), Vector3(60, 4, 4)]
const POSTS := [45.0, 52.0, 59.0, 66.0, 73.0]  # on the boardwalk's back edge
const PIER_ROOT := 74.0  # Stage.PIER_ROOT
const BOARD_Y := -0.6  # the boardwalk's top
## The ships: [kit stem, x0, x1 (the drift), z, length, colour, flip]. They drift slowly
## between x0 and x1, bobbing.
const SHIPS := [
	["brigantine", 140.0, 172.0, -95.0, 24.0, "#B8202C", false], ["brigantine", 160.0, 205.0, -150.0, 24.0, "#2659D8", true],
	["sloop", 124.0, 136.0, -58.0, 12.0, "#FFC928", false], ["sloop", 170.0, 182.0, -72.0, 12.0, "#1FB8AE", true],
	["party_boat", 154.0, 170.0, -46.0, 11.0, "#E0287A", false],
]
## The islands and the raft: [kit stem, x, z, width, colour].
const ISLES := [["isle_palm_hammock", 140.0, -72.0, 10.0, "#7CC83A"], ["isle_lighthouse", 166.0, -125.0, 14.0, "#F2EEE4"],
	["isle_pinata_tree", 196.0, -190.0, 12.0, "#E0287A"], ["isle_band_raft", 145.0, -38.0, 6.0, "#E8B14A"]]
const CAM := Vector2(102.5, 13.1)  # the Del Mar camera (x, z): cut-outs and fronts turn to it
## Clouds over the sea: [x, y, z, width] (each outside the plaza cameras' reach).
const CLOUDS := [Vector4(122, 20, -110, 22), Vector4(152, 26, -150, 30), Vector4(232, 28, -175, 26),
	Vector4(205, 34, -200, 40), Vector4(212, 44, -260, 36), Vector4(262, 48, -330, 52)]

var water: MeshInstance3D = null  # the sea, for the game's splashes
var _ships: Array = []  # [node, x0, x1, phase, speed]
var _clouds: Array = []  # [node, base x]
var _bobbers: Array = []  # [node, base y, phase]
var _t := 0.0
var _rng := RandomNumberGenerator.new()


# ---------------------------------------------------------------- the plan's lines

## The district line: Del Mar owns everything right of it (d is the depth behind the plane).
static func district_line(d: float) -> float:
	return 36.0 + 0.62 * maxf(d, 0.0)


## The waterline's x at depth z (z from +60 to -300).
static func coast_x(z: float) -> float:
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


## The ground's height at (x, z): the land's flat top, falling across the beach to
## just under the water at the waterline.
static func ground_y(x: float, z: float) -> float:
	var cx := coast_x(z)
	var w := cx - maxf(cx - BEACH_W, district_line(-z) + 0.5)
	var inland := cx - x
	if inland >= w:
		return GROUND_Y
	return lerpf(SAND_LOW, GROUND_Y, clampf(inland / maxf(w, 0.1), 0.0, 1.0))


# ---------------------------------------------------------------- build and tick

func build() -> void:
	name = "DelMarScenery"
	_rng.seed = 2611
	_build_ground()
	_build_headland()
	_build_boardwalk()
	_build_town()
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
		# Drift right, wrap back to the start: never left of where the plan placed it.
		cn.position.x = float(c[1]) + fposmod(_t * 0.6, 60.0)


## The water node, for the game's splashes.
func water_node() -> Node3D:
	return water


# ---------------------------------------------------------------- the ground and the sea

func _build_ground() -> void:
	var land := PackedVector2Array()
	# From the district line at the front, across to the beach's inner edge, back along
	# the shore to the far shore, and home along the district line.
	var shore_in: Array = []  # the beach's inner edge, front to back
	var shore_out: Array = []  # the waterline
	var z := 60.0
	while z >= FAR_SHORE_Z:
		var cx := coast_x(z)
		# The beach's inner edge never crosses the district line (the far shore is
		# narrow: there the beach runs right up to the line).
		shore_in.append(Vector2(maxf(cx - BEACH_W, district_line(-z) + 0.5), z))
		shore_out.append(Vector2(cx, z))
		z -= 5.0
	land.append(Vector2(district_line(0.0), 60.0))
	for p in shore_in:
		land.append(p)
	var d := -FAR_SHORE_Z
	while d >= 0.0:
		land.append(Vector2(district_line(d), -d))
		d -= 10.0
	add_child(_flat(land, GROUND_Y, LAND, "Land"))
	# The beach: a strip falling from the land's edge to just under the waterline.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in shore_in.size() - 1:
		var a: Vector2 = shore_in[i]
		var b: Vector2 = shore_in[i + 1]
		var c: Vector2 = shore_out[i + 1]
		var e: Vector2 = shore_out[i]
		var la := Vector3(a.x, GROUND_Y, a.y)
		var lb := Vector3(b.x, GROUND_Y, b.y)
		var wc := Vector3(c.x, SAND_LOW, c.y)
		var we := Vector3(e.x, SAND_LOW, e.y)
		var n := (lb - la).cross(we - la).normalized()
		if n.y < 0.0:
			n = -n
		_quad(st, la, lb, wc, we, n)
	var beach := MeshInstance3D.new()
	beach.name = "Beach"
	beach.mesh = st.commit()
	beach.material_override = LuchaKit.mat(SAND)
	add_child(beach)
	# The sea: right of the waterline in front of the far shore, everywhere behind it.
	var sea := PackedVector2Array([Vector2(coast_x(60.0) - 3.0, 60.0)])
	for p in shore_out:
		sea.append((p as Vector2) + Vector2(-3.0, 0.0))  # under the sand's toe, no gap
	sea.append(Vector2(-HORIZON, FAR_SHORE_Z))
	sea.append(Vector2(-HORIZON, -HORIZON))
	sea.append(Vector2(HORIZON, -HORIZON))
	sea.append(Vector2(HORIZON, 60.0))
	water = _flat(sea, WATER_Y, SEA, "Sea")
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(water)


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
	# The pier's root: three steps from the boardwalk (-0.6) up to the deck (0).
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
			um.rotation.y = _rng.randf() * TAU
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
			cone.material_override = LuchaKit.mat(BULBS[int(u.z) % BULBS.size()])
			cone.position = p + Vector3(0, 2.3, 0)
			root.add_child(cone)
		var chair := LuchaKit.kit_model("beach_chair_" + ("a" if int(u.z) % 2 == 0 else "b"))
		if chair != null:
			chair.position = p + Vector3(0.9, 0.0, 0.6)
			chair.rotation.y = deg_to_rad(_rng.randf_range(-25.0, 25.0))
			root.add_child(chair)


# ---------------------------------------------------------------- the beach town

func _build_town() -> void:
	var root := Node3D.new()
	root.name = "BeachTown"
	add_child(root)
	for p in PIECES:
		var x: float = p[1]
		var z: float = p[2]
		_place(root, str(p[0]), Vector3(x, ground_y(x, z), z), deg_to_rad(float(p[3])))
	for i in PALMS.size():
		var q: Vector2 = PALMS[i]
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
		root.add_child(cloud)
		_clouds.append([cloud, c.x])


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
	mi.material_override = LuchaKit.mat(c)
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
	mi.material_override = LuchaKit.mat(c)
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
func _lay_wall(lots: Array, a: Vector2, b: Vector2, y0: float, y1: float, bl: float, course: float) -> void:
	var run := a.distance_to(b)
	var tan2 := (b - a) / run
	var n := Vector3(tan2.y, 0, -tan2.x)
	var mid := (a + b) * 0.5
	if Vector2(n.x, n.z).dot(mid - Vector2(58, -24)) < 0.0:  # outward from the headland's middle
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
		mmi.material_override = LuchaKit.mat(WALL_TONES[i])
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
