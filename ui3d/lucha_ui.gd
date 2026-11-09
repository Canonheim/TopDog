class_name LuchaUI
extends Node3D
## LUCHA UI: Top Dog's 3D front end and festive world. Main builds one and calls
## show_screen(id) whenever its screen changes; the screens this owns are drawn as
## 3D menus in the world (Menu3D), and main's flat screen for the same id is hidden.
##
## Owns: the title (the TOP DOG logo and championship-belt buttons), Play together
## (fight-poster cards for joined players, belt pickers for mode / clock / spawns),
## pause, results (a podium and the winner on a poster), the match HUD (the clock on a
## belt buckle, banner slams on papel picado, the height line as a ring rope), and
## the festive world (2D swirl clouds in the sky, the plaza behind the stage, papel
## picado strung across it).
##
## Screens still flat, for now: online, lobby, controls, options and the F1 panel
## (forms with text fields, lists and sliders; next round they go onto posters).
##
## Every piece comes from the Top Dog Kit when delivered, else a placeholder
## (LuchaKit), so the real models drop in by file name.

const MENU_DIST := 6.0  # in front of the ring's apron at every camera distance
const PAUSE_DIST := 1.2  # the pause menu, nearer than anything in the world
const LINE_HALF_W := 12.0  # the line's flag string spans the ring and the tower
const LINE_Z := -0.8  # behind the play plane (the line node sits at z 0.35)
const BANNER_KIT_SCALE := 2.0  # the kit's hud_banner at HUD size (notes x0.85)
const BANNER_Y := 2.55  # the turn / announcement banner, high on the HUD (its flags reach the top)
const UI_SCALE := 0.48  # the 3D menus at this size leave the stage and the plaza in view
const OWNED := ["title", "local", "pause", "results", "online", "friends", "browse", "lobby", "online_flat"]
const CARD_DX := 1.75  # the kit card is 1.6 m with its ribbon tails
const CARD_DY := 2.3  # and 2.05 m with its mask crest

var main: Node
var cam: Camera3D
var menus := {}  # id -> Menu3D
var current := ""
var _clouds: Array = []
var _flags: Array = []
var _line_poles: Array = []  # the two growing poles holding up the line's flag string
var _bell: Node3D  # the ring bell beside the clock (the kit's bell)
var _bell_t := -1.0  # seconds since it was struck; < 0 = still
var _pinata: Node3D  # the pinata over the plaza (the kit's pinata)
var _pinata_burst := false
const PAPEL := [Color("#E0287A"), Color("#1FB8AE"), Color("#FFC928"), Color("#7CC83A"), Color("#8A3FC0"), Color("#F28A1E")]
var _hud: Node3D
var hud_bottom: LuchaHudBottom
var _clock_text: Node3D
var _clock_val := -1
var _info: Node3D
var _info_text := ""
var _banner: Node3D
var _banner_t := 0.0
var _clock_up := 0.0  # how far the clock and bell are lifted out of the frame
var _clock_drop_t := 0.0
const CLOCK_AT := Vector3(0, 2.25, 0)
const BELL_AT := Vector3(1.05, 2.0, 0.05)
const CLOCK_HIDE_UP := 2.6  # above the top of the frame
var _cards: Node3D
var _podium: Node3D
var _winner_poster: Node3D
var online: LuchaOnline


func setup(p_main: Node) -> void:
	main = p_main
	cam = main.cam
	process_mode = Node.PROCESS_MODE_ALWAYS
	# No bloom anywhere (Parker 11-07): the matte cel look.
	for ch in main.get_children():
		if ch is WorldEnvironment and (ch as WorldEnvironment).environment != null:
			(ch as WorldEnvironment).environment.glow_enabled = false
	_build_sky()
	_build_plaza()
	_build_menus()
	online = LuchaOnline.new(self)
	online.build()
	_build_hud()
	_restyle_line()
	main.game.announce.connect(_on_announce)
	no_shadows(cam)  # UI never casts shadows into the world (the menus' words ghosted on the apron)
	Players.joined.connect(func(_s): _refresh_cards())
	Players.left.connect(func(_s): _refresh_cards())


## Main calls this from its own show_screen. Returns true when this owns the id
## (main then hides its flat screen for it).
func show_screen(id: String) -> bool:
	current = id
	for k in menus:
		if k == id:
			menus[k].open()
		else:
			menus[k].close()
	_hud.visible = id == "hud"  # hidden under the pause menu (Parker 11-08: the menu in front of everything)
	if id == "title":
		_rehang_pinata()
	_cards.visible = id == "local"
	_podium.visible = id == "results"
	if _winner_poster != null:
		_winner_poster.visible = id == "results"
	if id == "local":
		_refresh_cards()
	if id == "results":
		_fill_results()
		_raise_podium()
	no_shadows(cam)
	if id == "title":
		Sound.play("lock", -4.0)
	if online != null:
		online.on_screen(id)
	return id in OWNED


# ================================================================ the sky and the plaza

## 2D swirl clouds, far back, drifting. Flat cards facing the camera.
func _build_sky() -> void:
	var sky := Node3D.new()
	sky.name = "SwirlSky"
	main.world.add_child(sky)
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for i in 9:
		var w := rng.randf_range(9.0, 18.0)
		var c := LuchaKit.swirl_cloud(w, i)
		c.position = Vector3(rng.randf_range(-70.0, 70.0), rng.randf_range(9.0, 26.0), rng.randf_range(-95.0, -70.0))
		c.set_meta("speed", rng.randf_range(0.4, 1.0))
		sky.add_child(c)
		_clouds.append(c)


## THE TOWN (the environment pass, 2026-11-08). The follow camera sits 6.7 m out
## and climbs with the climber, so the town has to fill the frame at every height:
## - the plaza row: the kit houses edge to edge at z -16 to -18, set back by turns;
## - the church at the centre back: a code facade between two of the kit's
##   `bell_tower`s, the landmark at 10 to 19 m; the climber keeps the facade and the
##   sky between the towers behind him (the kit's `plaza_church`, if it ever lands,
##   replaces the whole thing);
## - the hill town: four terraces climbing behind the plaza with houses on each,
##   so rooftops pass you as you climb (to about 18 m);
## - land to the horizon and far ridges (the sky's dark lower half read as sea);
## - the papel picado on poles at z -12.6: one span each side, and a string from
##   each inner pole up to its church tower, so no string crosses the climbing
##   column; the pinata hangs mid-span on the right, in front of a wall.
const PLAZA_ROW := [  # [x centre, kit house (a 4.8, b 5.2, c 3.8 wide), z, height scale]
	[-31.95, "b", -17.2, 1.04], [-26.85, "a", -16.4, 0.94], [-22.25, "c", -17.8, 1.08], [-17.45, "b", -16.6, 0.96],
	[-12.15, "a", -17.6, 1.06], [-7.55, "c", -16.2, 0.92], [-2.75, "b", -17.0, 0.95], [2.6, "a", -16.4, 0.93],
	[7.2, "c", -17.6, 1.05], [11.95, "b", -16.2, 0.94], [17.25, "a", -17.4, 1.08], [21.85, "c", -16.6, 0.96],
	[26.65, "b", -17.8, 1.06], [31.75, "a", -16.6, 0.95],
]
const HOUSE_W := {"a": 4.8, "b": 5.2, "c": 3.8}
const HILL_TERRACES := [  # [front z, depth, top above the stones, half-width]
	[-22.0, 7.0, 2.0, 38.0], [-29.0, 7.0, 4.6, 32.0], [-36.0, 7.0, 7.4, 25.0], [-43.0, 7.0, 10.4, 18.0],
]
const CHURCH_CLEAR := 8.5  # no hill houses within this of x 0 on the first two terraces
const STONE := Color("#C2A878")
const DRY_GRASS := Color("#8E9A5C")  # lit, the cel band reads it a dry green
const LAND := Color("#C9BE92")
const RIDGE_NEAR := Color("#B4C9EC")  # haze blues: the far ridges sit back by colour (no fog in the look)
const RIDGE_FAR := Color("#CCDBF3")
## The far mountains: [x, z, width, height, fallback colour, yaw].
const FAR_RIDGES := [
	[-140.0, -260.0, 300.0, 52.0, RIDGE_FAR, 0.2],
	[120.0, -240.0, 280.0, 44.0, RIDGE_FAR, -0.24],
	[-20.0, -200.0, 240.0, 32.0, RIDGE_NEAR, -0.12],
]
const POLE_WOOD := Color("#6A4128")
const BUNTING_Z := -12.6  # the houses' awnings reach about z -13.4
const BUNTING_POLES := [-18.0, -6.0, 6.0, 18.0]


func _build_plaza() -> void:
	var plaza := Node3D.new()
	plaza.name = "Plaza"
	main.world.add_child(plaza)
	var gy := Stage.PLAZA_GROUND
	# Land to the horizon (just under the stones), and the plaza floor out to the hill.
	plaza.add_child(LuchaKit.box(Vector3(4000, 0.2, 4000), LAND, Vector3(0, gy - 0.12, -1980)))
	plaza.add_child(LuchaKit.box(Vector3(80, 0.4, 20), Color(0.86, 0.78, 0.6), Vector3(0, gy - 0.2, -14)))
	_pave(plaza, gy)
	# The plaza row.
	for row in PLAZA_ROW:
		var house := _house(str(row[1]))
		house.position = Vector3(float(row[0]), gy, float(row[2]))
		house.scale = Vector3(1.0, float(row[3]), 1.0)  # a little stagger in the roofline
		plaza.add_child(house)
	for px in [-20.2, -9.7, 9.4, 20.0]:
		var palm := _palm()
		palm.position = Vector3(px, gy, -12.8)
		plaza.add_child(palm)
	# The hill town: terraces with a stone face and a dry-grass top, houses along each.
	var rng := RandomNumberGenerator.new()
	rng.seed = 8
	for k in HILL_TERRACES.size():
		var t: Array = HILL_TERRACES[k]
		var zf: float = t[0]
		var d: float = t[1]
		var top: float = t[2]
		var hw: float = t[3]
		plaza.add_child(LuchaKit.box(Vector3(hw * 2.0, top + 0.5, d), STONE, Vector3(0, gy + (top - 0.5) * 0.5, zf - d * 0.5)))
		plaza.add_child(LuchaKit.box(Vector3(hw * 2.0 - 0.4, 0.12, d - 0.2), DRY_GRASS, Vector3(0, gy + top + 0.06, zf - d * 0.5 - 0.1)))
		var x := -hw + 3.0 + rng.randf_range(0.0, 2.0)
		while x < hw - 3.0:
			var kind: String = ["a", "b", "c"][rng.randi() % 3]
			# The church's spot on the first two terraces stays clear.
			if not (k < 2 and absf(x) < CHURCH_CLEAR):
				var h := _house(kind)
				h.position = Vector3(x, gy + top, zf - 2.7 - rng.randf_range(0.0, 0.8))
				h.scale = Vector3.ONE * (0.92 - k * 0.04)  # a touch smaller up the hill, for depth
				plaza.add_child(h)
			var gap := rng.randf_range(1.0, 3.6)
			if gap > 2.6 and k < 3:  # a palm in the wider gaps
				var palm := _palm()
				palm.position = Vector3(x + float(HOUSE_W[kind]) * 0.5 + gap * 0.5, gy + top, zf - 1.6)
				palm.scale = Vector3.ONE * 0.85
				plaza.add_child(palm)
			x += float(HOUSE_W[kind]) + gap
	# The church at the centre back, on the first terrace: its foremost part (the
	# kit's steps, the stand-in's towers) stops at the terrace's front edge.
	var church := _church()
	var reach := float(church.get_meta("front_reach"))
	church.position = Vector3(0, gy + float(HILL_TERRACES[0][2]), float(HILL_TERRACES[0][0]) - reach - 0.05)
	plaza.add_child(church)
	# Far mountains (Parker 11-08: "large cardboard cut outs of mountains"): the
	# kit's mountain_cutout_a/b/c, scaled to each ridge's width and height, stood
	# with a slight yaw and lean like set dressing propped on the horizon. If the
	# kit pieces are missing, plain flat cards in the haze blues stand in.
	for i in FAR_RIDGES.size():
		var r: Array = FAR_RIDGES[i]
		var w: float = r[2]
		var rh: float = r[3]
		var cut := LuchaKit.kit_model("mountain_cutout_" + "abc"[i])
		if cut != null:
			var bb := _local_aabb(cut)
			var sx := w / maxf(bb.size.x, 0.01)
			var sy := rh / maxf(bb.size.y, 0.01)
			cut.scale = Vector3(sx, sy, (sx + sy) * 0.5)
			cut.rotation = Vector3(-0.04, float(r[5]), 0.0)  # leaned back a touch, turned enough to show the kraft edge
			cut.position = Vector3(r[0], gy - 0.2 - bb.position.y * sy, r[1])
			plaza.add_child(cut)
			continue
		var pts := PackedVector2Array([Vector2(-w * 0.5, 0), Vector2(-w * 0.3, rh * 0.55), Vector2(-w * 0.12, rh * 0.8),
			Vector2(0, rh), Vector2(w * 0.1, rh * 0.72), Vector2(w * 0.28, rh * 0.85), Vector2(w * 0.5, 0)])
		var ridge := LuchaKit._extrude(pts, 4.0, r[4])
		ridge.position = Vector3(r[0], gy - 0.2, r[1])
		plaza.add_child(ridge)
	# Papel picado strung between poles, a little back from the stage.
	for px in BUNTING_POLES:
		plaza.add_child(_bunting_pole(Vector3(px, gy, BUNTING_Z)))
	var ties: Array = church.get_meta("anchors")  # the belfries' outer faces, church-local
	var strings := [
		[Vector3(-18.0, 6.5, BUNTING_Z), Vector3(-6.0, 6.8, BUNTING_Z), 9, 0.9],
		[Vector3(6.0, 6.8, BUNTING_Z), Vector3(18.0, 6.5, BUNTING_Z), 9, 0.9],
		[Vector3(-6.0, 6.8, BUNTING_Z), church.position + (ties[0] as Vector3), 8, 0.6],
		[Vector3(6.0, 6.8, BUNTING_Z), church.position + (ties[1] as Vector3), 8, 0.6],
	]
	for st in strings:
		var b := LuchaKit.bunting(st[0], st[1], st[2], st[3])
		plaza.add_child(b)
		for f in b.find_children("*", "Node3D", true, false):
			if f.has_meta("sway"):
				_flags.append(f)
	# Mid-span on the right, where the string sags lowest: it hangs in front of a
	# house wall, not on a roof ridge, and clear of the HUD clock.
	_hang_pinata(plaza, Vector3(12.0, 5.75, BUNTING_Z))


## THE PAVING (Parker 11-08: "a paved street in front of the houses", like
## Golemheim's; then "flat like in the image so ink doesnt hit it"): a street of
## small setts in running bond in front of the houses, a raised kerb, then the
## square in big slabs. The stones are FLAT quads 5 mm over a grout bed, so the
## joints are colour only and the ink, which draws depth and normal edges, leaves
## them alone. Only the kerb stands proud. One MultiMesh per stone tone.
const STREET_Z := Vector2(-13.8, -9.95)  # the street, from the house fronts to the kerb
const SQUARE_Z := Vector2(-9.55, 16.2)  # the square, from the kerb to past the camera
const PAVE_HALF_X := 42.0
const GROUT := Color("#7A6C5A")
const KERB := Color("#D9CBB0")
const STONE_TONES := [Color("#C4B192"), Color("#B9A585"), Color("#AE9978"), Color("#CBBB9E")]  # warm sandstone: the sun lifts these a step


func _pave(parent: Node3D, gy: float) -> void:
	var z0 := STREET_Z.x - 0.1
	var z1 := SQUARE_Z.y + 0.1
	parent.add_child(LuchaKit.box(Vector3(PAVE_HALF_X * 2.0 + 0.4, 0.02, z1 - z0), GROUT, Vector3(0, gy + 0.01, (z0 + z1) * 0.5)))
	var kz := (STREET_Z.y + SQUARE_Z.x) * 0.5
	parent.add_child(LuchaKit.box(Vector3(PAVE_HALF_X * 2.0, 0.12, SQUARE_Z.x - STREET_Z.y - 0.06), KERB, Vector3(0, gy + 0.08, kz)))
	var rng := RandomNumberGenerator.new()
	rng.seed = 31
	var lots: Array = []
	for t in STONE_TONES:
		lots.append([])
	# The street: setts 0.9 x 0.6, each row shifted half a sett.
	_lay(lots, rng, gy, STREET_Z, Vector2(0.9, 0.6), true)
	# The square: slabs 1.6 m, in a straight grid.
	_lay(lots, rng, gy, SQUARE_Z, Vector2(1.6, 1.6), false)
	for i in STONE_TONES.size():
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
		mmi.material_override = LuchaKit.mat(STONE_TONES[i])
		parent.add_child(mmi)


## One stone per cell over a z band, each a flat unit quad scaled to the cell
## less the joint, sorted into a tone's lot. `bond` shifts every other row half a stone.
func _lay(lots: Array, rng: RandomNumberGenerator, gy: float, band: Vector2, cell: Vector2, bond: bool) -> void:
	var joint := 0.07
	var rows := int(floor((band.y - band.x) / cell.y))
	var dz := (band.y - band.x) / rows
	for r in rows:
		var zc := band.x + (r + 0.5) * dz
		var shift := cell.x * 0.5 if bond and r % 2 == 1 else 0.0
		var x := -PAVE_HALF_X - shift
		while x < PAVE_HALF_X:
			var xa := maxf(x, -PAVE_HALF_X)
			var xb := minf(x + cell.x, PAVE_HALF_X)
			if xb - xa > joint * 2.0:
				var basis := Basis.from_scale(Vector3(xb - xa - joint, 1.0, dz - joint))
				var xf := Transform3D(basis, Vector3((xa + xb) * 0.5, gy + 0.025, zc))  # flush: 5 mm over the grout
				(lots[rng.randi() % lots.size()] as Array).append(xf)
			x += cell.x


## A kit plaza house (a, b or c), or a plain stand-in.
func _house(kind: String) -> Node3D:
	var k := LuchaKit.kit_model("plaza_house_" + kind)
	if k != null:
		return k
	var w := float(HOUSE_W[kind])
	var h := 5.4 if kind == "a" else (5.8 if kind == "b" else 6.8)
	var house := Node3D.new()
	house.add_child(LuchaKit.box(Vector3(w, h, 4.6), Color(0.92, 0.82, 0.62), Vector3(0, h * 0.5, 0)))
	house.add_child(LuchaKit.box(Vector3(w + 0.5, 0.5, 5.0), Color(0.78, 0.32, 0.2), Vector3(0, h + 0.2, 0)))
	return house


const CHURCH_TOWER_X := 5.0
const CHURCH_STONE := Color("#C98E7A")
const CHURCH_TRIM := Color("#E6D8B4")


## THE CHURCH: the plaza's landmark at the centre back. The kit's `plaza_church`
## (the Building Maker's, 11-08: origin at the nave's centre on the ground, the
## steps reaching local z +4.95, the bunting tied at the belfries' outer faces,
## (+-6.2, 14.6, 2.0)); else two `bell_tower`s (kit or stand-in) at x +-5 with a
## nave and a gabled facade between them, built here, origin at the facade's foot.
## Either way the node carries metas `front_reach` (its foremost local z) and
## `anchors` (the two string ties, local).
## The foremost local z of a model's meshes (its front, for a +Z-facing building).
static func _front_z(root: Node3D) -> float:
	var front := -INF
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.mesh == null:
			continue
		var xf := root.global_transform.affine_inverse() * m.global_transform if root.is_inside_tree() else _local_xf(root, m)
		var bb: AABB = xf * m.mesh.get_aabb()
		front = maxf(front, bb.end.z)
	return front if front > -INF else 0.0


## The merged box of a model's meshes in its own frame (before it's in the tree).
static func _local_aabb(root: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.mesh == null:
			continue
		var bb: AABB = _local_xf(root, m) * m.mesh.get_aabb()
		out = bb if first else out.merge(bb)
		first = false
	return out


static func _local_xf(root: Node3D, n: Node3D) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var cur: Node = n
	while cur != null and cur != root:
		if cur is Node3D:
			xf = (cur as Node3D).transform * xf
		cur = cur.get_parent()
	return xf


func _church() -> Node3D:
	var k := LuchaKit.kit_model("plaza_church")
	if k != null:
		# Measured from the model, not assumed: its foremost point (the steps) is the
		# front, whatever origin the file has (the Building Maker moved it from the
		# nave's centre to the facade's foot, 11-08). The string ties sit on the
		# belfries' outer faces, 2.95 m behind that front, 14.6 m up.
		var front := _front_z(k)
		k.set_meta("front_reach", front)
		k.set_meta("anchors", [Vector3(-6.2, 14.6, front - 2.95), Vector3(6.2, 14.6, front - 2.95)])
		return k
	var root := Node3D.new()
	root.set_meta("front_reach", 0.55)  # the towers' fronts
	root.set_meta("anchors", [Vector3(-CHURCH_TOWER_X, 10.6, 0.0), Vector3(CHURCH_TOWER_X, 10.6, 0.0)])
	var face_w := CHURCH_TOWER_X * 2.0 - 3.4  # between the towers
	var body_h := 9.0
	# The nave behind, and the facade: a stone wall, a cream cornice, a gable.
	root.add_child(LuchaKit.box(Vector3(face_w + 1.0, body_h - 1.0, 14.0), CHURCH_STONE, Vector3(0, (body_h - 1.0) * 0.5, -7.5)))
	root.add_child(LuchaKit.box(Vector3(face_w, body_h, 0.8), CHURCH_STONE, Vector3(0, body_h * 0.5, -0.4)))
	root.add_child(LuchaKit.box(Vector3(face_w + 0.3, 0.4, 1.0), CHURCH_TRIM, Vector3(0, body_h + 0.2, -0.4)))
	var gable := LuchaKit._extrude(PackedVector2Array([Vector2(-face_w * 0.5, 0), Vector2(face_w * 0.5, 0), Vector2(0, 2.6)]), 0.8, CHURCH_STONE)
	gable.position = Vector3(0, body_h + 0.4, -0.4)
	root.add_child(gable)
	root.add_child(LuchaKit.ball(0.25, LuchaKit.GOLD, Vector3(0, body_h + 3.15, -0.4)))
	# The door (an arched dark opening in a cream surround) and the round window.
	root.add_child(LuchaKit.box(Vector3(2.6, 3.9, 0.12), CHURCH_TRIM, Vector3(0, 1.95, 0.04)))
	root.add_child(LuchaKit.box(Vector3(2.0, 3.0, 0.14), Color("#4A2C1A"), Vector3(0, 1.5, 0.06)))
	var arch := LuchaKit.cyl(1.0, 0.14, Color("#4A2C1A"), Vector3(0, 3.0, 0.06), Vector3.BACK)
	root.add_child(arch)
	root.add_child(LuchaKit.cyl(1.25, 0.12, CHURCH_TRIM, Vector3(0, 6.6, 0.04), Vector3.BACK))
	root.add_child(LuchaKit.cyl(0.95, 0.14, Color("#2A3A6A"), Vector3(0, 6.6, 0.06), Vector3.BACK))
	# The towers.
	for sx in [-1.0, 1.0]:
		var t := _bell_tower()
		t.position = Vector3(sx * CHURCH_TOWER_X, 0, -1.2)  # the towers stand a little proud of the facade
		root.add_child(t)
	return root


## The plaza's bell tower: the kit's `bell_tower` when it lands, else a stand-in
## built here (a stone shaft, a cornice, a belfry with dark openings and a bell, a
## tiled pyramid cap). Origin at the footprint centre on the ground, front +Z.
func _bell_tower() -> Node3D:
	var k := LuchaKit.kit_model("bell_tower")
	if k != null:
		return k
	var stone := Color("#C98E7A")
	var trim := Color("#F2E6C8")
	var root := Node3D.new()
	root.add_child(LuchaKit.box(Vector3(4.2, 1.0, 4.2), trim, Vector3(0, 0.5, 0)))
	root.add_child(LuchaKit.box(Vector3(3.6, 11.0, 3.6), stone, Vector3(0, 6.5, 0)))
	for y in [5.0, 9.0]:
		root.add_child(LuchaKit.box(Vector3(0.8, 1.4, 0.1), Color("#2A3A6A"), Vector3(0, y, 1.81)))
	root.add_child(LuchaKit.box(Vector3(4.0, 0.4, 4.0), trim, Vector3(0, 12.2, 0)))
	root.add_child(LuchaKit.box(Vector3(3.4, 3.4, 3.4), stone, Vector3(0, 14.1, 0)))
	for f in 4:
		var a := f * PI * 0.5
		var opening := LuchaKit.box(Vector3(1.5, 2.2, 0.12), Color("#3A2A30"), Vector3(sin(a) * 1.71, 14.0, cos(a) * 1.71))
		opening.rotation.y = a
		root.add_child(opening)
	root.add_child(LuchaKit.ball(0.55, Color("#C8A040"), Vector3(0, 13.9, 1.2)))
	root.add_child(LuchaKit.box(Vector3(3.9, 0.35, 3.9), trim, Vector3(0, 15.95, 0)))
	var cap := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.0
	cm.bottom_radius = 2.6
	cm.height = 2.8
	cm.radial_segments = 4
	cap.mesh = cm
	cap.material_override = LuchaKit.mat(Color("#D2643A"))
	cap.position = Vector3(0, 17.5, 0)
	cap.rotation.y = PI * 0.25
	root.add_child(cap)
	root.add_child(LuchaKit.ball(0.3, Color("#E8B14A"), Vector3(0, 19.1, 0)))
	return root


## A wooden pole the papel picado hangs from: a post with a crossbar and a gold
## ball at the top, on a stone foot.
func _bunting_pole(at: Vector3) -> Node3D:
	var root := Node3D.new()
	var top := 7.0 - at.y  # the strings tie on at about 6.5 to 6.8 m
	root.add_child(LuchaKit.cyl(0.09, top, POLE_WOOD, Vector3(0, top * 0.5, 0)))
	root.add_child(LuchaKit.cyl(0.05, 0.8, POLE_WOOD, Vector3(0, top - 0.45, 0), Vector3.RIGHT))
	root.add_child(LuchaKit.ball(0.16, LuchaKit.GOLD, Vector3(0, top + 0.12, 0)))
	root.add_child(LuchaKit.cyl(0.22, 0.3, Color("#9EA6A6"), Vector3(0, 0.15, 0)))
	root.position = at
	return root


func _palm() -> Node3D:
	var k := LuchaKit.kit_model("palm")
	if k != null:
		return k
	var p := Node3D.new()
	var trunk := Color(0.6, 0.42, 0.24)
	var y := 0.0
	for s in 6:
		var seg := LuchaKit.cyl(0.18 - s * 0.015, 0.9, trunk, Vector3(sin(s * 0.3) * 0.25, y + 0.45, 0))
		seg.rotation.z = -0.08
		p.add_child(seg)
		y += 0.85
	for f in 7:
		var a := f * TAU / 7.0
		var frond := LuchaKit.box(Vector3(2.2, 0.08, 0.5), Color(0.25, 0.6, 0.3), Vector3(cos(a) * 1.0, y + 0.1 - absf(sin(a)) * 0.3, sin(a) * 1.0))
		frond.rotation = Vector3(0, -a, -0.35)
		p.add_child(frond)
	return p


# ================================================================ the menus

func _menu() -> Menu3D:
	var m := Menu3D.new(cam)
	cam.add_child(m)
	m.position = Vector3(0, 0, -MENU_DIST)
	m.scale = Vector3.ONE * UI_SCALE
	return m


func _build_menus() -> void:
	# THE TITLE
	var t := _menu()
	t.set_header(LuchaKit.title_logo(), Vector3(2.4, 2.0, 0))
	t.column_x = -3.6
	t.top_y = 1.8
	t.add_button("PLAY TOGETHER", func(): main.show_screen("local"))
	t.add_button("PLAY ONLINE", func(): main.show_screen("online"))
	t.add_button("PRACTICE", main._start_practice)
	t.add_button("CONTROLS", func(): main._controls_back = "title"; main.show_screen("controls"))
	t.add_button("OPTIONS", func(): main._options_back = "title"; main.show_screen("options"))
	t.add_button("QUIT", main.quit_game)
	menus.title = t
	# PLAY TOGETHER
	var l := _menu()
	l.set_header(LuchaKit.poster_text("PLAY TOGETHER", 0.42, LuchaKit.GOLD, LuchaKit.RED, 0.1), Vector3(-2.4, 2.75, 0))
	l.column_x = -2.4
	l.top_y = 1.25
	var mode_ids := ["tower", "scramble"]
	l.add_choice("MODE", mode_ids.map(func(id): return str(Modes.row(id).name).to_upper()), maxi(0, mode_ids.find(str(Net.settings.get("mode", "tower")))), func(i): Net.settings.mode = mode_ids[i])
	l.add_choice("CLOCK", ["40 S", "1 MIN", "1:30"], maxi(0, Modes.TIMERS.find(float(Net.settings.get("timer", 60.0)))), func(i): Net.settings.timer = Modes.TIMERS[i])
	l.add_choice("SPAWN", ["SWAP", "LEFT", "RIGHT", "RANDOM"], maxi(0, Modes.SPAWNS.find(str(Net.settings.get("spawn", "alternate")))), func(i): Net.settings.spawn = Modes.SPAWNS[i])
	l.add_button("FIGHT!", main._start_local)
	l.add_button("REMOVE LAST", func():
		if not Players.slots.is_empty():
			Players.remove_player(Players.slots.size() - 1)
		_refresh_cards())
	l.add_button("BACK", func(): main.show_screen("title"))
	menus.local = l
	# PAUSE
	var p := _menu()
	p.set_header(LuchaKit.poster_text("TIME OUT!", 0.6, LuchaKit.GOLD, LuchaKit.RED, 0.12), Vector3(0, 1.9, 0))
	p.column_x = 0.0
	p.top_y = 0.9
	p.add_button("RESUME", main._toggle_pause)
	p.add_button("CONTROLS", func(): main._controls_back = "pause"; main.show_screen("controls"))
	p.add_button("OPTIONS", func(): main._options_back = "pause"; main.show_screen("options"))
	p.add_button("QUIT TO MENU", func():
		get_tree().paused = false
		main.game.end_match()
		if Net.online:
			Net.leave()
		main._to_title(""))
	# IN FRONT OF EVERYTHING (Parker 11-08: "make the menu draw in front of everything
	# when paused"): the follow camera sits close to the play, so the pause menu
	# rides PAUSE_DIST from the lens instead of MENU_DIST, scaled to the same size on
	# screen: nothing in the world can come between it and the camera.
	p.position = Vector3(0, 0, -PAUSE_DIST)
	p.scale = Vector3.ONE * UI_SCALE * PAUSE_DIST / MENU_DIST
	menus.pause = p
	# RESULTS
	var r := _menu()
	r.column_x = -2.6
	r.top_y = -0.6
	r.add_button("REMATCH!", func():
		if main.local_mode:
			main.game.host_start(Net.settings.duplicate() if main.game.settings.mode != "practice" else main.game.settings, main.game.roster)
			main.show_screen("hud")
		elif Net.is_host():
			Net.set_in_match(true)
			main.game.host_start(Net.settings.duplicate(), Net.build_roster()))
	r.add_button("BACK", func():
		main.game.end_match()
		main.show_screen("title" if main.local_mode else "lobby"))
	menus.results = r
	# Player cards (Play together) and the podium (results) hang in the same frame.
	_cards = Node3D.new()
	cam.add_child(_cards)
	_cards.position = Vector3(0.2, 0.75, -MENU_DIST)
	_cards.scale = Vector3.ONE * UI_SCALE
	_cards.visible = false
	_podium = Node3D.new()
	cam.add_child(_podium)
	_podium.position = Vector3(1.4, -1.15, -MENU_DIST)
	_podium.scale = Vector3.ONE * UI_SCALE
	_podium.visible = false
	var pod := LuchaKit.kit_model("podium")
	if pod == null:
		pod = Node3D.new()
		pod.add_child(LuchaKit.box(Vector3(1.0, 1.0, 0.9), LuchaKit.GOLD, Vector3(0, 0.5, 0)))
		pod.add_child(LuchaKit.box(Vector3(0.9, 0.65, 0.9), LuchaKit.SILVER, Vector3(-0.95, 0.33, 0)))
		pod.add_child(LuchaKit.box(Vector3(0.9, 0.45, 0.9), Color(0.8, 0.5, 0.25), Vector3(0.95, 0.23, 0)))
		var one := LuchaKit.poster_text("1", 0.55, LuchaKit.RED, LuchaKit.INK, 0.08)
		one.position = Vector3(0, 0.55, 0.47)
		pod.add_child(one)
	_podium.add_child(pod)


func _refresh_cards() -> void:
	if _cards == null:
		return
	for ch in _cards.get_children():
		ch.queue_free()
	var n := maxi(Players.slots.size(), 1)
	for s in mini(Players.slots.size(), 8):
		var slot: Dictionary = Players.slots[s]
		var card := LuchaKit.card_frame(LuchaKit.CREAM, slot.tint)
		card.position = Vector3((s % 4) * CARD_DX, -(s / 4) * CARD_DY, 0)
		card.rotation.z = sin(s * 1.7) * 0.05
		var num := LuchaKit.poster_text("P%d" % (s + 1), 0.24, LuchaKit.CREAM, LuchaKit.INK, 0.04)
		num.position = Vector3(0, 0.56, 0.06)  # on the band (y 0.37..0.71)
		card.add_child(num)
		var m := LuchaKit.mask_icon(slot.tint, LuchaKit.GOLD)
		m.scale = Vector3.ONE * 0.75
		m.position = Vector3(0, -0.04, 0.12)  # on the panel (y -0.50..0.25)
		card.add_child(m)
		var nm := str(slot.name).split(" the ")
		var who := LuchaKit.poster_text(nm[0].to_upper(), 0.13, LuchaKit.INK, LuchaKit.CREAM, 0.02)
		who.position = Vector3(0, -0.4, 0.06)
		card.add_child(who)
		var dev := LuchaKit.poster_text(Players.device_label(int(slot.device)).to_upper(), 0.07, LuchaKit.CREAM, LuchaKit.INK, 0.015)
		dev.position = Vector3(0, -0.63, 0.06)  # on the strip (y -0.71..-0.55)
		card.add_child(dev)
		_cards.add_child(card)
		card.scale = Vector3.ONE * 0.01
		create_tween().tween_property(card, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if Players.slots.size() < 8:
		var s := Players.slots.size()
		var empty := LuchaKit.card_frame(Color(0.9, 0.86, 0.78), LuchaKit.INK)
		empty.position = Vector3((s % 4) * CARD_DX, -(s / 4) * CARD_DY, 0)
		var join := LuchaKit.poster_text("PRESS A\nOR SPACE", 0.12, LuchaKit.RED, LuchaKit.CREAM, 0.02)
		join.position = Vector3(0, 0.05, 0.05)
		empty.add_child(join)
		empty.set_meta("pulse", true)
		_cards.add_child(empty)
	no_shadows(_cards)


## Everything under `n` stops casting shadows (UI pieces hang in the sun's light).
static func no_shadows(n: Node) -> void:
	if n is GeometryInstance3D:
		(n as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for ch in n.get_children():
		no_shadows(ch)


## The kit podium's three steps rise one at a time (3rd, 2nd, then the winner's),
## each from its own base, with a bounce.
func _raise_podium() -> void:
	var k := 0
	for nm in ["podium_3", "podium_2", "podium_1"]:
		var step := _podium.find_child(nm, true, false) as Node3D
		if step == null:
			continue
		if not step.has_meta("home"):
			step.set_meta("home", step.position)
		var home: Vector3 = step.get_meta("home")
		step.position = home + Vector3(0, -1.2, 0)
		var tw := create_tween()
		tw.tween_interval(0.25 + k * 0.3)
		tw.tween_property(step, "position", home, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		k += 1


func _fill_results() -> void:
	if _winner_poster != null:
		_winner_poster.queue_free()
	var res: Dictionary = main.game.results
	var w := int(res.get("winner", -1))
	var title := ("%s IS TOP DOG!" % str(main.game.player_name(w)).split(" the ")[0].to_upper()) if w >= 0 else "GAME OVER"
	_winner_poster = Node3D.new()
	var big := LuchaKit.poster_text(title, 0.45 if title.length() < 18 else 0.32, LuchaKit.GOLD, LuchaKit.RED, 0.12)
	big.position = Vector3(0, 2.1, 0)
	_winner_poster.add_child(big)
	var best: Dictionary = res.get("best", {})
	var order := best.keys()
	order.sort_custom(func(a, b): return float(best[a]) > float(best[b]))
	var y := 1.2
	for pid in order.slice(0, 4):
		var line := LuchaKit.poster_text("%s  %.2f M" % [str(main.game.player_name(int(pid))).split(" the ")[0].to_upper(), float(best[pid])], 0.24, LuchaKit.CREAM, LuchaKit.INK, 0.04)
		line.position = Vector3(0.0, y, 0)
		_winner_poster.add_child(line)
		y -= 0.32
	cam.add_child(_winner_poster)
	_winner_poster.position = Vector3(0, 0, -MENU_DIST)
	_winner_poster.scale = Vector3.ONE * UI_SCALE
	_winner_poster.visible = true
	var tw := create_tween()
	_winner_poster.scale = Vector3.ONE * 0.2
	tw.tween_property(_winner_poster, "scale", Vector3.ONE * UI_SCALE, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


# ================================================================ the match HUD

func _build_hud() -> void:
	_hud = Node3D.new()
	cam.add_child(_hud)
	_hud.position = Vector3(0, 0, -MENU_DIST)
	_hud.scale = Vector3.ONE * UI_SCALE
	_hud.visible = false
	var buckle := LuchaKit.kit_model("clock_buckle")
	if buckle == null:
		buckle = Node3D.new()
		buckle.add_child(LuchaKit.box(Vector3(1.5, 0.3, 0.05), LuchaKit.LEATHER, Vector3(0, 0, -0.05)))
		buckle.add_child(LuchaKit.box(Vector3(1.0, 0.72, 0.1), LuchaKit.GOLD_DARK, Vector3(0, 0, -0.01)))
		buckle.add_child(LuchaKit.box(Vector3(0.9, 0.62, 0.1), LuchaKit.GOLD, Vector3(0, 0, 0.02)))
		buckle.add_child(LuchaKit.box(Vector3(0.7, 0.44, 0.1), LuchaKit.INK, Vector3(0, 0, 0.04)))
	buckle.position = Vector3(0, 2.25, 0)
	buckle.name = "Buckle"
	_hud.add_child(buckle)
	# The ring bell right of the clock: struck at every turn and round.
	_bell = LuchaKit.kit_model("bell")
	if _bell == null:
		_bell = Node3D.new()
		var dome := LuchaKit.ball(0.14, LuchaKit.GOLD, Vector3(0, 0.23, 0.02))
		dome.name = "bell_dome"
		_bell.add_child(dome)
	_bell.scale = Vector3.ONE * 1.15
	_bell.position = Vector3(1.05, 2.0, 0.05)
	_bell.visible = false
	_hud.add_child(_bell)
	_info = Node3D.new()
	_info.position = Vector3(-5.6, 2.55, 0)
	_hud.add_child(_info)
	_clock_text = Node3D.new()
	_clock_text.position = Vector3(0, 2.25, 0.075)  # just proud of the kit's face (z 0.06)
	_hud.add_child(_clock_text)
	# The bottom: the climber's nameplate and the height odometer (Parker 11-08).
	hud_bottom = LuchaHudBottom.new(main)
	_hud.add_child(hud_bottom)
	# 1.3 m from the lens, shrunk to match: the same place on screen, but in front
	# of the ring's apron, which the follow camera brings nearer than the HUD.
	var near := 1.3
	hud_bottom.position = Vector3(0, 0, (MENU_DIST - near) / UI_SCALE)
	hud_bottom.scale = Vector3.ONE * near / MENU_DIST
	_banner = Node3D.new()
	_banner.position = Vector3(0, 1.2, 0.3)
	_banner.visible = false
	_hud.add_child(_banner)


## The height line becomes a red ring rope with knotted ends.
## THE LINE IS A STRING OF FLAGS (Parker 11-08: "get rid of the big red and yellow
## line height indicator. Make the line a string of flags"): papel picado across
## the ring at the line's height, riding the line node up and down, hung just behind
## the play plane so the flags don't cover the climbers. No bar, no LINE label.
func _restyle_line() -> void:
	var bar: MeshInstance3D = main.line_bar
	bar.mesh = null
	bar.material_override = null
	var string := LuchaKit.bunting(Vector3(-LINE_HALF_W, 0.0, LINE_Z), Vector3(LINE_HALF_W, 0.0, LINE_Z), int(LINE_HALF_W * 2.0 / 0.55), 0.12)
	string.name = "LineFlags"
	bar.add_child(string)
	for f in string.find_children("*", "Node3D", true, false):
		if f.has_meta("sway"):
			_flags.append(f)
	(main.line_label as Label3D).visible = false
	# THE LINE POLES (Parker 11-08: "long decorative poles on either side of the
	# ring holding up the line and those poles constantly grow as the line moves
	# up"): a pole at each end of the string, standing on the plaza, its shaft
	# stretched every frame to the line's height (_tick_line_poles).
	for sx in [-1.0, 1.0]:
		var pole := Node3D.new()
		pole.position = Vector3(sx * LINE_HALF_W, Stage.PLAZA_GROUND, bar.position.z + LINE_Z)
		var shaft := LuchaKit.cyl(0.11, 1.0, POLE_WOOD, Vector3(0, 0.5, 0))
		shaft.name = "shaft"
		var stripes := Node3D.new()  # gold bands every metre, added as the pole grows
		stripes.name = "bands"
		var cap := LuchaKit.ball(0.2, LuchaKit.GOLD, Vector3.ZERO)
		cap.name = "cap"
		pole.add_child(LuchaKit.cyl(0.26, 0.35, Color("#9EA6A6"), Vector3(0, 0.175, 0)))  # the stone foot
		pole.add_child(shaft)
		pole.add_child(stripes)
		pole.add_child(cap)
		main.world.add_child(pole)
		_line_poles.append(pole)


func _on_announce(text: String, big: bool) -> void:
	if _banner == null:
		return
	var low := text.to_lower()
	if low.ends_with("'s turn") or low.begins_with("round "):
		ring_bell()
	if low.contains("tops") or low.contains("top dog"):
		burst_pinata()
	if low.contains("locked in") or low.contains("made it") or low.contains("tops") or low.contains("top dog"):
		confetti(low.contains("tops") or low.contains("top dog"))
	for ch in _banner.get_children():
		ch.queue_free()
	var t := text.to_upper()
	# The UI creator's wrestling-show title card (Parker 11-08: "have UI guy
	# redesign it"): red for the big calls, royal blue for the notes; the words
	# fitted to banner_face, so long lines shrink.
	var kit := LuchaKit.kit_model("hud_banner" if big else "hud_banner_note")
	if kit == null and not big:
		kit = LuchaKit.kit_model("hud_banner")
	if kit != null:
		kit.scale = Vector3.ONE * (BANNER_KIT_SCALE if big else BANNER_KIT_SCALE * 0.85)
		_banner.add_child(kit)
		var face := kit.find_child("banner_face", true, false) as MeshInstance3D
		var fc := Vector3(0, 0, 0.08)
		var fw := 3.0
		var fh := 0.3
		if face != null:
			var fb: AABB = LuchaHudBottom._rel(face, kit) * face.get_aabb()
			fc = fb.get_center() + Vector3(0, 0, fb.size.z * 0.5 + 0.006)
			fw = fb.size.x * 0.94
			fh = fb.size.y
		var words := LuchaKit.fit_text(t, fw * 1.1, fh * 0.8, LuchaKit.RED if big else Color("#1E2C5C"), LuchaKit.INK)
		words.position = fc
		kit.add_child(words)
	else:
		var size := (0.42 if big else 0.26) * (1.0 if t.length() < 22 else 0.7)
		var band := LuchaKit.box(Vector3(minf(t.length() * size * 0.62 + 0.8, 8.0), size * 1.9, 0.04), LuchaKit.RED if big else LuchaKit.BLUE, Vector3(0, 0, -0.08))
		_banner.add_child(band)
		# The flags hang from a string ABOVE the band.
		var top := size * 0.95 + 0.62
		var flagline := LuchaKit.bunting(Vector3(-band.mesh.size.x * 0.5, top, -0.05), Vector3(band.mesh.size.x * 0.5, top, -0.05), int(band.mesh.size.x / 0.5), 0.05)
		_banner.add_child(flagline)
		var words := LuchaKit.poster_text(t, size, LuchaKit.GOLD if big else LuchaKit.CREAM, LuchaKit.INK, 0.06)
		_banner.add_child(words)
	_banner.visible = true
	no_shadows(_banner)
	# High on the screen, above the climber's head (Parker 11-08). It drops in from
	# above the frame with a slam and a little swing, and later flies back up.
	_banner.position = Vector3(0, BANNER_Y + 2.2, 0.3)
	_banner.rotation.z = randf_range(-0.08, 0.08)  # the tails read best within about 6 degrees
	_banner.scale = Vector3.ONE
	var tw := create_tween()
	tw.tween_property(_banner, "position", Vector3(0, BANNER_Y, 0.3), 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_banner, "scale", Vector3(1.08, 0.9, 1.0), 0.06)
	tw.tween_property(_banner, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_banner_t = 2.4 if big else 1.8


## A burst of confetti and streamers from the top of the frame (a lock-in, or a
## bigger, longer one for the winner). Kit confetti pieces replace the paper when
## delivered.
func confetti(big := false) -> void:
	for side in ([-1.0, 1.0] if big else [0.0]):
		var p := CPUParticles3D.new()
		p.one_shot = true
		p.explosiveness = 0.85
		p.amount = 160 if big else 70
		p.lifetime = 3.2 if big else 2.2
		p.mesh = _confetti_mesh(int(randi() % 4))
		var m := StandardMaterial3D.new()
		m.vertex_color_use_as_albedo = true
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		p.material_override = m
		var grad := Gradient.new()
		grad.offsets = PackedFloat32Array([0.0, 0.17, 0.34, 0.5, 0.67, 0.84])
		grad.colors = PackedColorArray(PAPEL)
		grad.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
		p.color_initial_ramp = grad
		p.direction = Vector3(-side * 0.6, 1.0, 0.0)
		p.spread = 55.0
		p.initial_velocity_min = 3.0
		p.initial_velocity_max = 7.0
		p.gravity = Vector3(0, -4.0, 0)
		p.damping_min = 1.0
		p.damping_max = 2.0
		p.angular_velocity_min = -360.0
		p.angular_velocity_max = 360.0
		p.angle_max = 360.0
		p.scale_amount_min = 0.7
		p.scale_amount_max = 1.6
		cam.add_child(p)
		p.position = Vector3(side * 2.6, -0.6 if big else 0.6, -5.0)
		p.emitting = true
		p.finished.connect(p.queue_free)
	Sound.play("clap", -4.0)


func _process(delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	_festive_tick(delta, t)
	for c in _clouds:
		var n: Node3D = c
		n.position.x += float(n.get_meta("speed")) * delta
		if n.position.x > 80.0:
			n.position.x = -80.0
	_tick_line_poles()
	for f in _flags:
		var n: Node3D = f
		# Swing about the string only (the hanger's local x): no sideways rock.
		n.rotation.x = sin(t * 1.7 + float(n.get_meta("sway")) * 1.3) * 0.25
	# The join card pulses.
	if _cards != null and _cards.visible:
		for ch in _cards.get_children():
			if ch.has_meta("pulse"):
				(ch as Node3D).scale = Vector3.ONE * (1.0 + sin(t * 5.0) * 0.04)
	# HUD: the clock on the buckle; the banner rides up and away when its time is done.
	if _hud != null and _hud.visible:
		main.hud_clock.visible = false
		main.banner.visible = false
		main.hud_info.visible = false
		var g: Game = main.game
		var show := g.phase in ["turn", "round"] and not g.practice
		_hud.get_node("Buckle").visible = show
		# Parker 11-08: "The clock does not come down from the top of the screen
		# until the banner leaves." While a banner shows, the clock and bell wait
		# above the frame; after it flies out they drop back in with a bounce.
		var want_up := CLOCK_HIDE_UP if (_banner != null and _banner.visible) else 0.0
		if want_up > _clock_up:
			_clock_up = minf(want_up, _clock_up + delta * 14.0)  # out of the way fast
		elif want_up < _clock_up:
			_clock_drop_t += delta
			# Falls in, overshoots a touch and settles (a short damped bounce).
			_clock_up = maxf(0.0, _clock_up - delta * 9.0)
		if want_up > 0.0:
			_clock_drop_t = 0.0
		var bounce := 0.0
		if _clock_up == 0.0 and _clock_drop_t > 0.0 and _clock_drop_t < 0.6:
			bounce = sin(_clock_drop_t * 18.0) * 0.12 * exp(-_clock_drop_t * 7.0)
		var lift := Vector3(0, _clock_up + bounce, 0)
		_hud.get_node("Buckle").position = CLOCK_AT + lift
		_clock_text.position = CLOCK_AT + Vector3(0, 0, 0.075) + lift
		if _bell != null:
			_bell.position = BELL_AT + lift
		# The who's-climbing label repeats the banner's news, and its tail covers it:
		# it waits too.
		_info.visible = not (_banner != null and _banner.visible)
		hud_bottom.tick(delta)
		if _bell != null:
			_bell.visible = show
		# The who's-climbing line, as a small poster at the top left.
		var info := ""
		match g.phase:
			"turn":
				info = "%s CLIMBING" % str(g.player_name(g.turn_order[g.turn_i] if g.turn_i >= 0 else -1)).split(" the ")[0].to_upper()
			"round":
				info = "ROUND %d" % g.round_n
			"between":
				info = "GET READY..."
		if g.practice:
			info = "PRACTICE"
		if info != _info_text:
			_info_text = info
			for ch in _info.get_children():
				ch.queue_free()
			if info != "":
				var it := LuchaKit.poster_text(info, 0.26, LuchaKit.GOLD, LuchaKit.INK, 0.05)
				it.position = Vector3(info.length() * 0.09, 0, 0)
				_info.add_child(it)
				no_shadows(it)
		var v := int(ceil(g.clock)) if show else -1
		if v != _clock_val:
			_clock_val = v
			for ch in _clock_text.get_children():
				ch.queue_free()
			if v >= 0:
				var on_kit := LuchaKit.kit_model_exists("clock_buckle")
				var col := LuchaKit.RED if v <= 10 else (LuchaKit.INK if on_kit else LuchaKit.GOLD)
				var num := LuchaKit.text3d(str(v), 0.34 if on_kit else 0.42, col, 0.03)
				_clock_text.add_child(num)
				no_shadows(num)
				if v <= 10:
					_clock_text.scale = Vector3.ONE * 1.35
					create_tween().tween_property(_clock_text, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	if _banner != null and _banner.visible:
		_banner_t -= delta
		_banner.rotation.z = lerpf(_banner.rotation.z, sin(t * 3.0) * 0.03, 0.05)
		if _banner_t <= 0.0:
			# Flies back up out of the top of the frame, quickening.
			_banner.position.y += delta * (6.0 + (_banner.position.y - BANNER_Y) * 12.0)
			if _banner.position.y > BANNER_Y + 2.5:
				_banner.visible = false


# ---------------------------------------------------------------- the festive pieces

var _confetti_meshes: Array = []


## A kit confetti piece's mesh (a..d); a small card when the kit has none.
func _confetti_mesh(i: int) -> Mesh:
	if _confetti_meshes.is_empty():
		var k := LuchaKit.kit_model("confetti")
		if k != null:
			for n in ["confetti_a", "confetti_b", "confetti_c", "confetti_d"]:
				var mi := k.find_child(n, true, false) as MeshInstance3D
				if mi != null and mi.mesh != null:
					_confetti_meshes.append(mi.mesh)
			k.free()
		if _confetti_meshes.is_empty():
			var qm := QuadMesh.new()
			qm.size = Vector2(0.09, 0.05)
			_confetti_meshes.append(qm)
	return _confetti_meshes[i % _confetti_meshes.size()]


func ring_bell() -> void:
	_bell_t = 0.0
	Sound.play("lock", -6.0, 1.25)


func _hang_pinata(parent: Node3D, at: Vector3) -> void:
	_pinata = LuchaKit.kit_model("pinata")
	if _pinata == null:
		_pinata = Node3D.new()
		_pinata.add_child(LuchaKit.ball(0.55, LuchaKit.MAGENTA, Vector3(0, -0.7, 0)))
	_pinata.scale = Vector3.ONE * 1.2
	_pinata.position = at
	parent.add_child(_pinata)


## A win: the pinata bursts into confetti; it hangs again on the next game.
func burst_pinata() -> void:
	if _pinata == null or _pinata_burst:
		return
	_pinata_burst = true
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = 80
	p.lifetime = 4.0
	p.mesh = _confetti_mesh(2)
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	p.material_override = m
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.17, 0.34, 0.5, 0.67, 0.84])
	grad.colors = PackedColorArray(PAPEL)
	grad.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	p.color_initial_ramp = grad
	p.direction = Vector3.DOWN
	p.spread = 180.0
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 5.0
	p.gravity = Vector3(0, -3.0, 0)
	p.angular_velocity_min = -360.0
	p.angular_velocity_max = 360.0
	p.angle_max = 360.0
	p.scale_amount_min = 1.2
	p.scale_amount_max = 2.2
	_pinata.get_parent().add_child(p)
	p.position = _pinata.position + Vector3(0, -0.9, 0)
	p.emitting = true
	p.finished.connect(p.queue_free)
	for n in ["pinata_body", "pinata_tassels"]:
		var part := _pinata.find_child(n, true, false) as Node3D
		if part != null:
			part.visible = false


func _rehang_pinata() -> void:
	if _pinata == null or not _pinata_burst:
		return
	_pinata_burst = false
	for ch in _pinata.find_children("*", "Node3D", true, false):
		(ch as Node3D).visible = true


## The bell's hammer swing and dome shake, and the pinata's slow sway.
func _festive_tick(delta: float, t: float) -> void:
	if _bell != null and _bell_t >= 0.0:
		_bell_t += delta
		var hammer := _bell.find_child("bell_hammer", true, false) as Node3D
		var dome := _bell.find_child("bell_dome", true, false) as Node3D
		if hammer != null:
			# -40 degrees back, then a 0.12 s strike to +10, then home.
			var a := 0.0
			if _bell_t < 0.12:
				a = lerpf(-40.0, 10.0, _bell_t / 0.12)
			elif _bell_t < 0.4:
				a = lerpf(10.0, 0.0, (_bell_t - 0.12) / 0.28)
			hammer.rotation.z = deg_to_rad(a)
		if dome != null:
			dome.rotation.z = (sin(_bell_t * 90.0) * 0.12) if _bell_t > 0.1 and _bell_t < 0.3 else 0.0
		if _bell_t > 0.5:
			_bell_t = -1.0
	if _pinata != null:
		_pinata.rotation.z = deg_to_rad(6.0) * sin(t * TAU / 3.0)


## The line poles reach the line's height (from the plaza), carry a gold band every
## metre of their height, and hide with the line between matches.
func _tick_line_poles() -> void:
	if _line_poles.is_empty():
		return
	var bar: MeshInstance3D = main.line_bar
	var top: float = bar.position.y + 0.05
	for p in _line_poles:
		var pole: Node3D = p
		pole.visible = bar.visible
		if not pole.visible:
			continue
		var h := maxf(top - pole.position.y, 0.5)
		var shaft := pole.get_node("shaft") as Node3D
		shaft.scale = Vector3(1.0, h, 1.0)
		shaft.position.y = h * 0.5
		(pole.get_node("cap") as Node3D).position.y = h + 0.14
		var bands := pole.get_node("bands") as Node3D
		var want := int(h)  # one band per whole metre
		while bands.get_child_count() < want:
			var k := bands.get_child_count() + 1
			bands.add_child(LuchaKit.cyl(0.125, 0.12, LuchaKit.GOLD, Vector3(0, float(k), 0)))
		for i in bands.get_child_count():
			(bands.get_child(i) as Node3D).visible = i < want
