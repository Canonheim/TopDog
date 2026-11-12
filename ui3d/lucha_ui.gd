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
const LINE_SAG := 0.12  # the flag string's sag at its middle (lifted back onto the line)
const BANNER_KIT_SCALE := 2.0  # the kit's hud_banner at HUD size (notes x0.85)
const BANNER_Y := 2.55  # the turn / announcement banner, high on the HUD (its flags reach the top)
const UI_SCALE := 0.48  # the 3D menus at this size leave the stage and the plaza in view
const OWNED := ["practice_ai", "practice_settings", "customize", "title", "local", "pause", "results", "online", "friends", "browse", "lobby", "online_flat", "controls", "options"]
const CARD_DX := 1.75  # the kit card is 1.6 m with its ribbon tails
const CARD_DY := 2.3  # and 2.05 m with its mask crest
const CARD_ROW := 5  # Play together: one row of five (the UI pass, batch 3)
const CARD_ROW_DX := 1.5  # cards at 0.9 (1.44 wide with their tails): a 0.06 gap
const CARD_ROW_SCALE := 0.9

var main: Node
var cam: Camera3D
var menus := {}  # id -> Menu3D
var current := ""
## The next title opens on PRESS ANY BUTTON TO START (main sets it after the boot screens).
var title_attract := false
var _title_press: AnyPress = null
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
var _steam_tag: Node3D  # the nameplate climber's Steam name, top left (Parker 11-10)
var _steam_text := ""
var _local_start := -1
var _banner: Node3D
var _banner_t := 0.0
var _clock_up := 0.0  # how far the clock and bell are lifted out of the frame
var _clock_drop_t := 0.0
const CLOCK_AT := Vector3(0, 2.25, 0)
const COUNTDOWN_FROM := 10  # the clock pulses and ticks from here down (Parker 11-09)
var _pulse_tween: Tween
const BELL_AT := Vector3(1.05, 2.0, 0.05)
const CLOCK_HIDE_UP := 2.6  # above the top of the frame
var _cards: Node3D
var _mode_card: Node3D = null  # the UI creator's mode_card_delmar, beside MODE while it reads DEL MAR
var _podium: Node3D
var _winner_poster: Node3D
var online: LuchaOnline
var settings: LuchaSettings  # Controls and Options in 3D (Parker 11-10)


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
	settings = LuchaSettings.new(self)
	add_child(settings)
	settings.build()
	_restyle_line()
	main.game.announce.connect(_on_announce)
	main.game.lock_effect.connect(play_lock_effect)
	no_shadows(cam)  # UI never casts shadows into the world (the menus' words ghosted on the apron)
	Players.joined.connect(func(_s): _refresh_cards())
	Players.left.connect(func(_s): _refresh_cards())


## Main calls this from its own show_screen. Returns true when this owns the id
## (main then hides its flat screen for it).
func show_screen(id: String) -> bool:
	current = id
	if id == "pause":
		_fill_pause()
	if _title_press != null and id != "title":
		_title_press.queue_free()
		_title_press = null
	for k in menus:
		if k == id:
			if k == "title" and title_attract:
				menus[k].open_attract()
				_wait_title_press()
			else:
				menus[k].open()
		else:
			menus[k].close()
	_hud.visible = id == "hud"  # hidden under the pause menu (Parker 11-08: the menu in front of everything)
	if id in ["title", "lobby"]:
		_rehang_pinata()  # (the lobby too: online it stayed burst from the first match on)
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
	if id == "title" and not title_attract:
		Sound.play("lock", -4.0)
	if online != null:
		online.on_screen(id)
	if settings != null:
		settings.on_screen(id)
	return id in OWNED


## The title's press: the logo goes to its spot, the belts fall in, the bell rings.
func _wait_title_press() -> void:
	if _title_press != null:
		_title_press.queue_free()
	_title_press = AnyPress.new()
	_title_press.delay = 0.45  # the logo has landed first
	_title_press.pressed.connect(func():
		title_attract = false
		_title_press.queue_free()
		_title_press = null
		Players.mute_edges()
		if current == "title":
			menus.title.leave_attract()
			Sound.play("lock", -4.0))
	add_child(_title_press)


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
		c.set_meta("half_w", w * 0.5)
		sky.add_child(c)
		_clouds.append(c)


## THE HILL TOWN ROUND THE SQUARE (Parker 11-08: "not a perfect half circle, but
## more of like half a football shaped ... make it look like a town with like
## stairs and bricks and stuff instead of just blank terraces, and make sure the
## sides of the church look nice"). Everything is laid out on one shape, a lens
## (half an American football) about ARC_C: wider than deep, its back flat behind
## the church, its curve tightening to points at the sides. Every row and terrace
## is the same lens grown outward by an offset (_lens).
## - the square: the whole lens paved in courses that follow its shape (a paler
##   course every seventh), the setts running straight up to the church's steps;
## - the first row of kit houses faces the square behind a kerbed pavement, a
##   street opening through it each side to stairs up the hill;
## - the church at the back, flanked by raised gardens (a palm, bushes, flowers)
##   with a stairway up beside each to the first terrace;
## - the hill: four terraces, each faced with a brick retaining wall and topped by
##   a parapet and a paved lane with lamps and benches, houses facing the square;
##   stairways climb between the levels, bushes fill the gaps between houses;
## - flat-coloured as Parker liked: setts and bricks are flat quads a few mm proud
##   of their bed, so the ink leaves the joints alone; only kerbs, steps,
##   parapets and the like stand proud.
## Gameplay never touches this: the ring, the deck, the plaza floor collider (on
## the play plane, inside the square), the line poles and the cameras are the
## stage's and main's.
const ARC_C := Vector2(0.0, -2.5)  # the town's centre, (x, z)
const LENS_A := 30.0  # the square's half-width at its points
const LENS_B := 20.5  # its depth behind ARC_C, at the back
const LENS_M := 3.5  # >2 flattens the back (behind the church)
const LENS_K := 0.8  # <1 sharpens the points
const LENS_T1 := 0.985  # rows and terraces stop just short of the points
const WALK_W := 1.6  # the pavement, from the square's edge to the house fronts
const WALK_H := 0.14
const ROW_O := 4.0  # the first row's house centres (offset from the square's edge)
const ROW_X0 := 11.4  # the row starts here each side; the church's gardens inside
const STREET_F := 0.52  # a street opens through the row here (fraction of its length)
const STREET_W := 4.0
const TERRACES := [[8.0, 1.6], [16.0, 4.0], [24.0, 6.6], [32.0, 9.4]]  # [front offset, top above the stones]
const TERRACE_BACK := 12.0  # the last terrace runs back this far
const NOTCH_X := 8.4  # the church's notch through the first two terraces
const LANE_W := 2.6  # the paved lane along each terrace's front, behind its parapet
const PARAPET_W := 0.3
const PARAPET_H := 0.6
const HILL_O := 5.2  # hill house centres, from their terrace's front
const STAIRS := {1: [0.24, 0.66], 2: [0.44, 0.86], 3: [0.3, 0.7]}  # stair flights up each terrace face (fraction of its length)
const CHURCH_SCALE := 1.25
const GARDEN := Rect2(8.5, -26.8, 2.6, 4.0)  # (x, z, w, d) the raised garden beside the church, right side (mirrored)
const HOUSE_W := {"a": 4.8, "b": 5.2, "c": 3.8}
const HOUSE_D := 4.75
const DRY_GRASS := Color("#8E9A5C")  # lit, the cel band reads it a dry green
const LAND := Color("#C9BE92")
## The far mountains are the Environment Maker's (stages/plaza_mountains.gd, built in
## _build_plaza); they sink for Del Mar (mountains_down).
var _mountains: Array = []  # [node, its standing y, how far it sinks]
var _mountains_t := 0.0
const POLE_WOOD := Color("#6A4128")
const POLE_T := [0.32, 0.58, 0.82]  # the papel picado poles round the square (lens t, each side)
const GROUT := Color("#7A6C5A")
const MORTAR := Color("#8A7662")
const KERB := Color("#D9CBB0")
const WALK := Color("#CDBFA4")
const PARAPET := Color("#D6C3A0")
const SOIL := Color("#6E8A45")
const IRON := Color("#2E2A2C")
const STONE_TONES := [Color("#C4B192"), Color("#B9A585"), Color("#AE9978"), Color("#D2C3A6")]  # warm sandstone; the last, paler, is the band course
const BRICK_TONES := [Color("#C49A70"), Color("#B5885E"), Color("#CFA97F"), Color("#A97B55")]
const BUSH_TONES := [Color("#4E8A34"), Color("#5E9C3C"), Color("#3F7A2E")]
const FLOWER_TONES := [Color("#D81E6A"), Color("#FFC928"), Color("#F28A1E"), Color("#E0287A")]


## A point on the lens grown by offset o, at t in -1..1 (0 is the back axis,
## +-1 the points), on its back half. `front` gives the mirror half, toward the camera.
static func _lens(t: float, o: float, front := false) -> Vector2:
	var u := clampf(absf(t), 0.0, 1.0)
	var depth := (LENS_B + o) * pow(1.0 - pow(u, LENS_M), LENS_K)
	return Vector2((LENS_A + o) * t, ARC_C.y + (depth if front else -depth))


## The same lens scaled by s about ARC_C (the square's courses).
static func _lens_s(t: float, s: float, front: bool) -> Vector2:
	var u := clampf(absf(t), 0.0, 1.0)
	var depth := LENS_B * s * pow(1.0 - pow(u, LENS_M), LENS_K)
	return Vector2(LENS_A * s * t, ARC_C.y + (depth if front else -depth))


## The lens at offset o from x0 out to t1 on the right side, sampled finely, with
## its running length: [points, lengths, ts].
static func _path(o: float, x0: float, t1: float) -> Array:
	var t0 := clampf(x0 / (LENS_A + o), 0.0, t1)
	var pts := PackedVector2Array()
	var cum := PackedFloat32Array()
	var ts := PackedFloat32Array()
	var n := 500
	var run := 0.0
	for i in n + 1:
		var t := lerpf(t0, t1, float(i) / n)
		var p := _lens(t, o)
		if i > 0:
			run += p.distance_to(pts[i - 1])
		pts.append(p)
		cum.append(run)
		ts.append(t)
	return [pts, cum, ts]


## The point, unit tangent (toward the point) and inward normal (toward the
## square) a distance d along a path: [pos, tan, nrm, t].
static func _at(path: Array, d: float) -> Array:
	var pts: PackedVector2Array = path[0]
	var cum: PackedFloat32Array = path[1]
	var ts: PackedFloat32Array = path[2]
	d = clampf(d, 0.0, cum[cum.size() - 1])
	var lo := 0
	var hi := cum.size() - 1
	while hi - lo > 1:
		var mid := (lo + hi) / 2
		if cum[mid] < d:
			lo = mid
		else:
			hi = mid
	var seg := maxf(cum[hi] - cum[lo], 0.0001)
	var f := (d - cum[lo]) / seg
	var tan := (pts[hi] - pts[lo]).normalized()
	return [pts[lo].lerp(pts[hi], f), tan, Vector2(-tan.y, tan.x), lerpf(ts[lo], ts[hi], f)]


static func _len(path: Array) -> float:
	var cum: PackedFloat32Array = path[1]
	return cum[cum.size() - 1]


## A world point from a right-side path point, mirrored for the left (side -1).
static func _w(p: Vector2, side: float, y: float) -> Vector3:
	return Vector3(p.x * side, y, p.y)


## Stand a +Z-facing model at p facing the inward normal n (right-side frame).
func _stand(m: Node3D, p: Vector2, n: Vector2, side: float, y: float) -> void:
	m.position = _w(p, side, y)
	m.rotation.y = atan2(n.x * side, n.y)


## THE MOUNTAINS GO DOWN FOR DEL MAR (Parker 11-10, option B): the sea has no
## mountains behind it, so as the camera pans to the pier the cut-outs sink out of
## sight over 0.8 s, and rise again on the way back. main.gd calls this every frame.
func mountains_down(on: bool, delta: float) -> void:
	var t := move_toward(_mountains_t, 1.0 if on else 0.0, delta / 0.8)
	if t == _mountains_t:
		return
	_mountains_t = t
	var e := smoothstep(0.0, 1.0, t)
	for m in _mountains:
		var n: Node3D = m[0]
		if is_instance_valid(n):
			n.position.y = float(m[1]) - e * float(m[2])
			n.visible = t < 1.0


## A flat ground piece on an (x, z) outline at height y.
func _land_flat(pts: PackedVector2Array, y: float, c: Color) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tris := Geometry2D.triangulate_polygon(pts)
	for k in range(0, tris.size(), 3):
		var a: Vector2 = pts[tris[k]]
		var b: Vector2 = pts[tris[k + 1]]
		var d: Vector2 = pts[tris[k + 2]]
		DelMarScenery._tri(st, Vector3(a.x, y, a.y), Vector3(b.x, y, b.y), Vector3(d.x, y, d.y), Vector3.UP)
	var mi := MeshInstance3D.new()
	mi.name = "Land"
	mi.mesh = st.commit()
	CelPass.paint(mi, c)
	return mi


func _build_plaza() -> void:
	var plaza := Node3D.new()
	plaza.name = "Plaza"
	main.world.add_child(plaza)
	var gy := Stage.PLAZA_GROUND
	var rng := RandomNumberGenerator.new()
	rng.seed = 8
	var kinds := _house_kinds()
	_placed = {}
	var stones: Array = []  # (unused: the paving goes to the one flat paving mesh, _pave_begin)
	_pave_begin()
	var bricks: Array = []
	for t in BRICK_TONES:
		bricks.append([])
	# Land to the horizon, just under the stones, up to Del Mar's district line (the
	# Environment Maker's outline; right of it is the beach town and the sea).
	plaza.add_child(_land_flat(DelMarScenery.plaza_land_outline(), DelMarScenery.GROUND_Y, LAND))
	_pave_square(plaza, gy, stones, rng)
	_church_plot(plaza, gy, stones)
	var church := _church()
	church.scale = Vector3.ONE * CHURCH_SCALE
	var reach := float(church.get_meta("front_reach")) * CHURCH_SCALE
	church.position = Vector3(0, gy, ARC_C.y - LENS_B + 0.05 - reach)
	plaza.add_child(church)
	# The pavement and kerb along the house fronts, broken for the street.
	var row := _path(ROW_O, ROW_X0, LENS_T1)
	var street_d := _len(row) * STREET_F
	var street: Array = _at(row, street_d)
	var street_t: float = street[3]
	for side in [-1.0, 1.0]:
		var walk_x0 := GARDEN.position.x - 0.1
		var t_gap := STREET_W * 0.5 / (LENS_A + ROW_O)
		for rng_t in [[walk_x0 / LENS_A, street_t - t_gap], [street_t + t_gap, LENS_T1]]:
			plaza.add_child(_band(0.0, WALK_W, rng_t[0], rng_t[1], side, gy, gy + WALK_H, WALK, false))
			plaza.add_child(_band(-0.05, 0.25, rng_t[0], rng_t[1], side, gy, gy + WALK_H + 0.02, KERB, false))
	# The first row of houses, facing the square, with the street's gap.
	for side in [-1.0, 1.0]:
		var d := 0.0
		var total := _len(row)
		var last := ""
		while true:
			var kind := _pick_kind(kinds, rng, [last])
			var w := _house_w(kind)
			if d < street_d + STREET_W * 0.5 and d + w > street_d - STREET_W * 0.5:
				d = street_d + STREET_W * 0.5
			if d + w > total:
				break
			var at: Array = _at(row, d + w * 0.5)
			var house := _house(kind)
			_stand(house, at[0], at[2], side, gy)
			house.scale = Vector3(1.0, rng.randf_range(0.92, 1.08), 1.0)  # a little stagger in the roofline
			plaza.add_child(house)
			_log_house(0, _w(at[0], side, 0.0), w, kind)
			last = kind
			d += w + 0.15
		# The street: setts from the pavement through the row, then stairs up the first terrace.
		var axis: Vector2 = street[2]
		var mouth: Vector2 = (street[0] as Vector2) + axis * ROW_O  # from the square's edge
		var t0_face: Vector2 = _lens(street_t, float(TERRACES[0][0]))
		var run := mouth.distance_to(t0_face)
		var stair_len := 2.4
		var bed_c := mouth - axis * ((run - stair_len) * 0.5)
		var bed := LuchaKit.box(Vector3(STREET_W + 0.2, 0.022, run - stair_len + 0.2), GROUT, Vector3(bed_c.x * side, gy + 0.011, bed_c.y))
		bed.rotation.y = atan2(axis.x * side, axis.y)
		plaza.add_child(bed)
		_lay_strip(stones, rng, mouth, -axis, run - stair_len, STREET_W, side, gy + PAVE_Y)
		_stairs(plaza, t0_face, axis, side, gy, gy + float(TERRACES[0][1]), STREET_W - 0.4)
		# Palms in round planters at the street's mouth and at the wing's end.
		for pt in [_lens(street_t - 0.06, -1.1), _lens(street_t + 0.06, -1.1), _lens(0.93, -1.6)]:
			_palm_planter(plaza, _w(pt, side, gy))
	# The church's gardens and their stairs.
	for side in [-1.0, 1.0]:
		_garden(plaza, side, gy, rng)
	# The hill.
	for k in TERRACES.size():
		_terrace(plaza, k, gy, rng, kinds, stones, bricks, street_t)
	_pave_commit(plaza)
	_commit_walls(plaza, bricks, BRICK_TONES)
	# The mountains (Parker 11-10: "replace the cardboard mountains with slightly more
	# modeled ones"): the Environment Maker's low-poly ranges where the cut-outs stood.
	# Each comes back as [node, standing y, how far it sinks] for mountains_down().
	for m in PlazaMountains.build(plaza, gy):
		_mountains.append(m)
	# Papel picado round the square: poles inside its edge, strings between them,
	# and one from each inner pole up to its church tower.
	var tops := {}
	for side in [-1.0, 1.0]:
		for t in POLE_T:
			var p := _lens(float(t), -1.8)
			plaza.add_child(_bunting_pole(_w(p, side, gy)))
			tops[side * float(t)] = _w(p, side, 6.8)
	var ties: Array = church.get_meta("anchors")  # the belfries' outer faces, church-local
	var strings: Array = []
	for side in [-1.0, 1.0]:
		for i in POLE_T.size() - 1:
			strings.append([tops[side * float(POLE_T[i])], tops[side * float(POLE_T[i + 1])], 8, 0.8])
		var tie: Vector3 = church.position + (ties[0 if side < 0 else 1] as Vector3) * CHURCH_SCALE
		strings.append([tops[side * float(POLE_T[0])], tie, 9, 0.7])
	for st in strings:
		var b := LuchaKit.bunting(st[0], st[1], st[2], st[3])
		plaza.add_child(b)
		for f in b.find_children("*", "Node3D", true, false):
			if f.has_meta("sway"):
				_flags.append(f)
	# The pinata mid-span on the right-hand inner string, clear of the HUD clock.
	var pa: Vector3 = tops[float(POLE_T[0])]
	var pb: Vector3 = tops[float(POLE_T[1])]
	var mid := (pa + pb) * 0.5
	_hang_pinata(plaza, Vector3(mid.x, mid.y - 0.85, mid.z))


## The square: a grout bed over the whole lens, then courses that follow its
## shape, each the band between two smaller copies of the edge (so they run
## straight across the flat back and fan out toward the points), down to the
## centre. Every course is sampled at the same t, so neighbouring courses share
## their edge vertex for vertex: one flat, watertight paving.
func _pave_square(parent: Node3D, gy: float, _stones: Array, rng: RandomNumberGenerator) -> void:
	var outline := PackedVector2Array()
	for i in 161:
		outline.append(_lens(lerpf(-1.0, 1.0, float(i) / 160.0), 0.0))
	for i in range(159, 0, -1):
		outline.append(_lens(lerpf(-1.0, 1.0, float(i) / 160.0), 0.0, true))
	parent.add_child(_flat_poly(outline, gy + PAVE_Y - 0.002, GROUT))  # only seen through a hairline, if anywhere
	var ts := PackedFloat32Array()
	for i in 181:
		ts.append(-cos(PI * float(i) / 180.0))  # denser toward the points, where the lens turns fastest
	var ds := 0.62 / LENS_B
	var s_hi := 1.0
	var ci := 0
	while s_hi > 0.0001:
		var s_lo := maxf(s_hi - ds, 0.0)
		if s_lo < ds * 0.6:
			s_lo = 0.0  # the last course runs into the centre
		for front in [false, true]:
			var a := PackedVector3Array()
			var b := PackedVector3Array()
			for t in ts:
				var pa := _lens_s(t, s_hi, front)
				var pb := _lens_s(t, s_lo, front)
				a.append(Vector3(pa.x, gy + PAVE_Y, pa.y))
				b.append(Vector3(pb.x, gy + PAVE_Y, pb.y))
			_pave_band(a, b, rng, 0.95, 0.07, rng.randf(), 3 if ci % 7 == 3 else -1)
		s_hi = s_lo
		ci += 1


## The church's plot: setts in courses from the square's back edge to behind
## the church (so the square's setts run on up to its steps), each course the
## edge's own curve stepped back, led by a course of the paler band stone.
func _church_plot(parent: Node3D, gy: float, _stones: Array) -> void:
	var x0 := -GARDEN.position.x - 0.1
	var x1 := GARDEN.position.x + 0.1
	var z_edge := ARC_C.y - LENS_B
	var z_back := ARC_C.y - LENS_B - 20.0
	parent.add_child(LuchaKit.box(Vector3(x1 - x0, 0.02, z_edge - z_back + 0.6), GROUT, Vector3(0, gy + PAVE_Y - 0.012, (z_edge + z_back) * 0.5 + 0.3)))  # under the paving
	var rng := RandomNumberGenerator.new()
	rng.seed = 41
	var n := 70
	var row := 0
	var back := 0.0
	while back + 0.62 <= z_edge - z_back:
		var a := PackedVector3Array()
		var b := PackedVector3Array()
		for i in n + 1:
			var x := lerpf(x0, x1, float(i) / n)
			var ez := _lens(clampf(x / LENS_A, -1.0, 1.0), 0.0).y
			a.append(Vector3(x, gy + PAVE_Y, ez - back))
			b.append(Vector3(x, gy + PAVE_Y, ez - back - 0.62))
		_pave_band(a, b, rng, 0.95, 0.07, 0.5 if row % 2 == 1 else 0.0, 3 if row == 0 else -1)
		back += 0.62
		row += 1


## A raised garden beside the church (right side, mirrored for the left): a stone
## planter of soil with a palm, bushes and flowers, and a stairway behind it up to
## the first terrace.
func _garden(parent: Node3D, side: float, gy: float, rng: RandomNumberGenerator) -> void:
	var g := GARDEN
	var cx := (g.position.x + g.size.x * 0.5) * side
	var cz := g.position.y + g.size.y * 0.5
	parent.add_child(LuchaKit.box(Vector3(g.size.x, 0.5, g.size.y), PARAPET, Vector3(cx, gy + 0.25, cz)))
	parent.add_child(LuchaKit.box(Vector3(g.size.x - 0.3, 0.06, g.size.y - 0.3), SOIL, Vector3(cx, gy + 0.53, cz)))
	var palm := _palm()
	palm.position = Vector3(cx, gy + 0.5, cz - 0.6)
	palm.scale = Vector3.ONE * 0.9
	parent.add_child(palm)
	for i in 4:
		_bush(parent, Vector3(cx + rng.randf_range(-0.8, 0.8), gy + 0.56, cz + rng.randf_range(-1.6, 1.6)), rng, 0.45)
	_flowers(parent, Vector3(cx, gy + 0.56, g.end.y - 0.35), g.size.x - 0.5, rng)
	# The stairway up to the first terrace, behind the garden.
	var sx := (g.position.x + g.size.x * 0.5)
	var t := sx / (LENS_A + float(TERRACES[0][0]))
	var face := _lens(t, float(TERRACES[0][0]))
	_stairs(parent, Vector2(sx, face.y), Vector2(0, 1), side, gy, gy + float(TERRACES[0][1]), 1.9)


## One terrace (k) on both sides: its brick-faced retaining wall, its grass top,
## a parapet broken for the stairs, a paved lane with lamps and benches, the
## houses along it facing the square, bushes in the gaps, and the stairways up
## its face from the level below.
func _terrace(parent: Node3D, k: int, gy: float, rng: RandomNumberGenerator, kinds: Array, stones: Array, bricks: Array, street_t: float) -> void:
	var o: float = TERRACES[k][0]
	var top: float = gy + float(TERRACES[k][1])
	var below: float = gy if k == 0 else gy + float(TERRACES[k - 1][1])
	var o_back: float = o + TERRACE_BACK
	if k + 1 < TERRACES.size():
		o_back = float(TERRACES[k + 1][0])
	var x0 := NOTCH_X if k < 2 else 0.0
	var face_path := _path(o, x0, LENS_T1)
	var flen := _len(face_path)
	# Where stairs land on this terrace (from below), and where the next terrace's
	# stairs come down onto it: no house there.
	var ups: Array = []  # distances along face_path
	if STAIRS.has(k):
		for f in STAIRS[k]:
			ups.append(flen * float(f))
	var downs: Array = []  # world points (right frame) of the next face's stair feet
	if STAIRS.has(k + 1):
		var nxt := _path(float(TERRACES[k + 1][0]), NOTCH_X if k + 1 < 2 else 0.0, LENS_T1)
		for f in STAIRS[k + 1]:
			downs.append((_at(nxt, _len(nxt) * float(f))[0]) as Vector2)
	var landings: Array = []  # world points (right frame) to keep clear of houses
	for d in ups:
		landings.append((_at(face_path, d)[0]) as Vector2)
	if k == 0:
		landings.append(_lens(street_t, o))
		landings.append(Vector2(GARDEN.position.x + GARDEN.size.x * 0.5, _lens(0.3, o).y))
	for side in [-1.0, 1.0]:
		# The wall face (mortar, bricks laid on it) and the grass top.
		var t0_face := x0 / (LENS_A + o)
		parent.add_child(_band(o, o_back, t0_face, LENS_T1, side, below, top, MORTAR, true, x0 > 0.0))
		parent.add_child(_band(o + LANE_W, o_back, t0_face, LENS_T1, side, top, top + 0.012, DRY_GRASS, false))
		_brick_face(bricks, face_path, side, below, top, rng)
		# The parapet, broken where stairs arrive.
		var gaps: Array = []
		for d in ups:
			gaps.append(Vector2(float(d) - 1.3, float(d) + 1.3))
		var d0 := 0.0
		for gp in gaps + [Vector2(flen, flen)]:
			var a: float = d0
			var b: float = (gp as Vector2).x
			if b - a > 0.5:
				var ta: float = _at(face_path, a)[3]
				var tb: float = _at(face_path, b)[3]
				parent.add_child(_band(o, o + PARAPET_W, ta, tb, side, top, top + PARAPET_H, PARAPET, false))
			d0 = (gp as Vector2).y
		# The lane: a grout strip and setts in running bond along the terrace.
		parent.add_child(_band(o + PARAPET_W, o + LANE_W, t0_face, LENS_T1, side, top, top + PAVE_Y - 0.002, GROUT, false))
		var nb := maxi(1, int(round((LANE_W - PARAPET_W) / 0.6)))
		for bi in nb:
			var oa := o + PARAPET_W + (LANE_W - PARAPET_W) * float(bi) / nb
			var ob := o + PARAPET_W + (LANE_W - PARAPET_W) * float(bi + 1) / nb
			_lay_curve(stones, rng, [oa, ob, x0], side, top + PAVE_Y, 0.9, 0.0)
		# Lamps and benches along the lane, clear of the stairs.
		var lane := _path(o + PARAPET_W + 0.35, x0, LENS_T1)
		var dl := 4.0
		var li := 0
		while dl < _len(lane) - 2.0:
			var clear := true
			for d in ups:
				if absf(dl - float(d)) < 2.2:
					clear = false
			if clear:
				var at: Array = _at(lane, dl)
				parent.add_child(_lamp(_w(at[0], side, top)))
				if li % 2 == 1:
					var bench := _bench()
					var bp: Vector2 = (at[0] as Vector2) + (at[1] as Vector2) * 1.4 - (at[2] as Vector2) * 1.7
					_stand(bench, bp, at[2], side, top)
					parent.add_child(bench)
				if li % 3 == 0:
					_flowers(parent, _w((at[0] as Vector2) + (at[1] as Vector2) * 1.6 + (at[2] as Vector2) * 0.5, side, top + PARAPET_H), 1.2, rng, true)
				li += 1
			dl += 11.0
		# The stairs up this face from the level below.
		for d in ups:
			var at: Array = _at(face_path, d)
			_stairs(parent, at[0], at[2], side, below, top, 2.0)
	# The houses along the terrace, facing the square, bushes in the wider gaps.
	var hx0 := (NOTCH_X + 0.4) if k < 2 else 2.8
	var hp := _path(o + HILL_O, hx0, LENS_T1)
	var total := _len(hp)
	var centre_kind := ""  # above the church's notch the two sides meet behind it: their first houses are neighbours too
	for side in [-1.0, 1.0]:
		var d := rng.randf_range(0.0, 1.5)
		var last := centre_kind if k >= 2 else ""
		var first := true
		while true:
			var probe: Array = _at(hp, d + 2.4)
			var avoid := [last] + _in_front(k + 1, _w(probe[0], side, 0.0), 5.2)
			var kind := _pick_kind(kinds, rng, avoid)
			var w := _house_w(kind) * (0.92 - k * 0.04)
			if d + w > total:
				break
			var at: Array = _at(hp, d + w * 0.5)
			var p: Vector2 = at[0]
			var clear := true
			for q in landings + downs:
				if p.distance_to(q as Vector2) < w * 0.5 + 2.3:
					clear = false
			if clear:
				var h := _house(kind)
				_stand(h, p, at[2], side, top)
				h.scale = Vector3.ONE * (0.92 - k * 0.04)  # a touch smaller up the hill, for depth
				parent.add_child(h)
				_log_house(k + 1, _w(p, side, 0.0), w, kind)
				last = kind
				if first:
					first = false
					if centre_kind == "":
						centre_kind = kind
			var gap := rng.randf_range(0.6, 3.4)
			if gap > 1.8 and clear and k < 3:
				var gp: Vector2 = _at(hp, d + w + gap * 0.5)[0]
				if rng.randf() < 0.3:
					var palm := _palm()
					palm.position = _w(gp, side, top)
					palm.scale = Vector3.ONE * 0.8
					parent.add_child(palm)
				else:
					_bush(parent, _w(gp, side, top), rng, 0.6)
			d += w + gap


## A band between two offsets of the lens over t0..t1 on one side, from y0 up to
## y1: its top and inner face (facing the square), and its end faces. `wall`
## marks a retaining wall whose inner face runs only over its exposed height.
## `notch_end` closes the end at t0 (the church's notch).
func _band(o0: float, o1: float, t0: float, t1: float, side: float, y0: float, y1: float, c: Color, wall: bool, notch_end := false) -> MeshInstance3D:
	var n := maxi(4, int(ceil((t1 - t0) * 160.0)))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Each curve runs over its own t, so a band cut at x stays cut at x.
	var ti0 := t0
	var te0 := t0 * (LENS_A + o0) / (LENS_A + o1)
	var inner: Array = []
	var outer: Array = []
	for i in n + 1:
		var f := float(i) / n
		inner.append(_lens(lerpf(ti0, t1, f), o0))
		outer.append(_lens(lerpf(te0, t1, f), o1))
	for i in n:
		var a: Vector2 = inner[i]
		var b: Vector2 = inner[i + 1]
		var c2: Vector2 = outer[i + 1]
		var d: Vector2 = outer[i]
		_quad(st, _w(a, side, y1), _w(b, side, y1), _w(c2, side, y1), _w(d, side, y1), Vector3.UP)
		var tan := (b - a).normalized()
		var nrm := Vector2(-tan.y, tan.x)
		_quad(st, _w(a, side, y0), _w(b, side, y0), _w(b, side, y1), _w(a, side, y1), Vector3(nrm.x * side, 0, nrm.y))
	var ends := [[0, -1.0]] if notch_end else []
	ends.append([n, 1.0])
	for e in ends:
		var i: int = e[0]
		var a: Vector2 = inner[i]
		var b: Vector2 = outer[i]
		var j := i + (1 if i == 0 else -1)
		var along := ((inner[i] as Vector2) - (inner[j] as Vector2)).normalized()
		var nn := Vector3(along.x * side, 0, along.y)
		_quad(st, _w(a, side, y0), _w(b, side, y0), _w(b, side, y1), _w(a, side, y1), nn)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	CelPass.paint(mi, c)
	return mi


## A flat polygon (x, z points) at height y.
func _flat_poly(pts: PackedVector2Array, y: float, c: Color) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tris := Geometry2D.triangulate_polygon(pts)
	for k in range(0, tris.size(), 3):
		_tri(st, Vector3(pts[tris[k]].x, y, pts[tris[k]].y), Vector3(pts[tris[k + 1]].x, y, pts[tris[k + 1]].y), Vector3(pts[tris[k + 2]].x, y, pts[tris[k + 2]].y), Vector3.UP)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	CelPass.paint(mi, c)
	return mi


## Setts along a lane: a flat band between the lens offsets band[0] and band[1],
## from x = band[2] out to the lane's end, stones of length l in running bond.
func _lay_curve(_stones: Array, rng: RandomNumberGenerator, band: Array, side: float, y: float, l: float, _w_unused: float) -> void:
	var oa: float = band[0]
	var ob: float = band[1]
	var x0: float = band[2]
	var a := PackedVector3Array()
	var b := PackedVector3Array()
	var n := 140
	for i in n + 1:
		var f := float(i) / n
		var pa := _lens(lerpf(x0 / (LENS_A + oa), LENS_T1, f), oa)
		var pb := _lens(lerpf(x0 / (LENS_A + ob), LENS_T1, f), ob)
		a.append(Vector3(pa.x * side, y, pa.y))
		b.append(Vector3(pb.x * side, y, pb.y))
	_pave_band(a, b, rng, l, 0.07, rng.randf())


## Setts in running bond over a straight strip from `start` along dir (right
## frame), `length` long and `width` wide: rows across the strip, each a flat band.
func _lay_strip(_stones: Array, rng: RandomNumberGenerator, start: Vector2, dir: Vector2, length: float, width: float, side: float, y: float) -> void:
	var across := Vector2(-dir.y, dir.x)
	var row := 0
	var r := 0.0
	while r + 0.6 <= length + 0.001:
		var a := PackedVector3Array()
		var b := PackedVector3Array()
		for i in 9:
			var x := lerpf(-width * 0.5, width * 0.5, float(i) / 8.0)
			var pa := start + dir * r + across * x
			var pb := start + dir * (r + 0.6) + across * x
			a.append(Vector3(pa.x * side, y, pa.y))
			b.append(Vector3(pb.x * side, y, pb.y))
		_pave_band(a, b, rng, 0.9, 0.07, 0.5 if row % 2 == 1 else 0.0)
		r += 0.6
		row += 1


## THE FLAT PAVING (Parker 11-08: "They should all be the same height as the grout
## under them too, should all be flat, so it looks more like vector art and no ink
## hits the tiles"). All the paving is ONE mesh in one plane: each band (a course
## or a row) is cut into stones and joints that share their edges exactly, the
## joints in grout, the stones in the sandstone tones. Coplanar faces that share
## edges give the ink no depth or normal step, so it draws only the paving's
## outer edge. Five surfaces: four stone tones and the grout.
const PAVE_Y := 0.024  # the paving's plane, above the stones' ground
var _pave_st: Array = []


func _pave_begin() -> void:
	_pave_st = []
	for i in STONE_TONES.size() + 1:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_normal(Vector3.UP)
		_pave_st.append(st)


## One flat triangle into surface i, wound to face up.
func _pave_tri(i: int, a: Vector3, b: Vector3, c: Vector3) -> void:
	var st: SurfaceTool = _pave_st[i]
	if (b - a).cross(c - a).y > 0.0:
		var t := b
		b = c
		c = t
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)


func _pave_quad(i: int, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	_pave_tri(i, a, b, c)
	_pave_tri(i, a, c, d)


## A band between polylines a and b (same count, matched points): a grout border
## along each side (half a joint wide), and between them stones about stone_len
## long (each a random tone, or `tone`) separated by joints, all sharing edges.
## `phase` (0..1) shifts where the first stone starts, for running bond.
func _pave_band(a: PackedVector3Array, b: PackedVector3Array, rng: RandomNumberGenerator, stone_len: float, joint: float, phase: float, tone := -1) -> void:
	var n := a.size()
	if n < 2:
		return
	var grout := STONE_TONES.size()
	var pa := PackedVector3Array()
	var pb := PackedVector3Array()
	var cum := PackedFloat32Array([0.0])
	for k in n:
		var w := a[k].distance_to(b[k])
		var f := clampf(joint * 0.5 / maxf(w, 0.0001), 0.0, 0.45)
		pa.append(a[k].lerp(b[k], f))
		pb.append(a[k].lerp(b[k], 1.0 - f))
		if k > 0:
			cum.append(cum[k - 1] + ((pa[k] + pb[k]) * 0.5).distance_to((pa[k - 1] + pb[k - 1]) * 0.5))
	var total: float = cum[n - 1]
	if total < 0.01:
		return
	# The stones and joints along the band: [start, end, tone or -1 for a joint].
	var runs: Array = []
	var d := -phase * stone_len
	while d < total:
		var e := d + stone_len * rng.randf_range(0.85, 1.15)
		runs.append([d, e, tone if tone >= 0 else rng.randi() % 3])
		runs.append([e, e + joint, -1])
		d = e + joint
	# Stations: every sample and every cut, in order.
	var stations: Array = []
	for k in n:
		stations.append(cum[k])
	for r in runs:
		for x in [float(r[0]), float(r[1])]:
			if x > 0.0 and x < total:
				stations.append(x)
	stations.sort()
	var k := 0
	var ri := 0
	for si in stations.size() - 1:
		var u: float = stations[si]
		var v: float = stations[si + 1]
		if v - u < 0.0005:
			continue
		var m := (u + v) * 0.5
		while ri < runs.size() - 1 and float(runs[ri][1]) < m:
			ri += 1
		var surf: int = int(runs[ri][2])
		if surf < 0:
			surf = grout
		while k < n - 2 and cum[k + 1] < u:
			k += 1
		var ku := k
		var kv := k
		while kv < n - 2 and cum[kv + 1] < v:
			kv += 1
		var fu := clampf((u - cum[ku]) / maxf(cum[ku + 1] - cum[ku], 0.000001), 0.0, 1.0)
		var fv := clampf((v - cum[kv]) / maxf(cum[kv + 1] - cum[kv], 0.000001), 0.0, 1.0)
		var a_u := a[ku].lerp(a[ku + 1], fu)
		var a_v := a[kv].lerp(a[kv + 1], fv)
		var pa_u := pa[ku].lerp(pa[ku + 1], fu)
		var pa_v := pa[kv].lerp(pa[kv + 1], fv)
		var pb_u := pb[ku].lerp(pb[ku + 1], fu)
		var pb_v := pb[kv].lerp(pb[kv + 1], fv)
		var b_u := b[ku].lerp(b[ku + 1], fu)
		var b_v := b[kv].lerp(b[kv + 1], fv)
		_pave_quad(grout, a_u, a_v, pa_v, pa_u)
		_pave_quad(surf, pa_u, pa_v, pb_v, pb_u)
		_pave_quad(grout, pb_u, pb_v, b_v, b_u)


## The paving's surfaces as one mesh: one material per tone, no shadow cast.
func _pave_commit(parent: Node3D) -> void:
	var mesh := ArrayMesh.new()
	var mats: Array = []
	for i in _pave_st.size():
		var st: SurfaceTool = _pave_st[i]
		var before := mesh.get_surface_count()
		st.index()  # shared corners once: the paving was half a million loose vertices
		st.commit(mesh)
		if mesh.get_surface_count() > before:
			mats.append(LuchaKit.mat(STONE_TONES[i] if i < STONE_TONES.size() else GROUT))
	for i in mats.size():
		mesh.surface_set_material(i, mats[i])
	var mi := MeshInstance3D.new()
	mi.name = "Paving"
	mi.mesh = mesh
	CelPass.unify(mi)  # its tones as atlas UVs, on the one material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	_pave_st = []


## Bricks on a retaining wall's exposed face, in running bond, 4 mm proud of
## the mortar: flat quads, so the joints are colour and the ink leaves them alone.
func _brick_face(bricks: Array, path: Array, side: float, y0: float, y1: float, rng: RandomNumberGenerator) -> void:
	var total := _len(path)
	var course := 0.26
	var bl := 0.62
	var y := y0 + 0.05
	var row := 0
	while y + course <= y1 - 0.02:
		var d := (bl * 0.5 if row % 2 == 1 else 0.0) + 0.04
		while d + bl < total:
			var at: Array = _at(path, d + bl * 0.5)
			var p: Vector2 = at[0]
			var tan: Vector2 = at[1]
			var nrm: Vector2 = at[2]
			var pos := Vector3(p.x * side, y + course * 0.5, p.y) + Vector3(nrm.x * side, 0, nrm.y) * 0.004
			var xf := _wall_xf(pos, Vector3(tan.x * side, 0, tan.y), Vector3(nrm.x * side, 0, nrm.y), bl - 0.06, course - 0.06)
			(bricks[rng.randi() % bricks.size()] as Array).append(xf)
			d += bl
		y += course
		row += 1


## A flat quad standing up: the PlaneMesh's +Y turned to face n, its x along tan.
static func _wall_xf(p: Vector3, tan: Vector3, n: Vector3, w: float, h: float) -> Transform3D:
	var x := tan.normalized() * w
	var y := n.normalized()
	var z := Vector3.UP * h
	if x.cross(y).dot(z) < 0.0:
		z = -z
	return Transform3D(Basis(x, y, z), p)


## The bricks as one MultiMesh of upright quads per tone (both faces drawn, so a
## mirrored quad never culls away).
func _commit_walls(parent: Node3D, lots: Array, tones: Array) -> void:
	for i in tones.size():
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
		CelPass.paint(mmi, tones[i])
		parent.add_child(mmi)


## A flight of stairs descending from a terrace's edge at `top_at` toward the
## square along n (right frame), from y_hi down to y_lo, with stepped cheek walls.
func _stairs(parent: Node3D, top_at: Vector2, n: Vector2, side: float, y_lo: float, y_hi: float, width: float) -> void:
	var rise := y_hi - y_lo
	var count := maxi(2, int(ceil(rise / 0.2)))
	var r := rise / count
	var tread := 0.3
	var nw := Vector2(n.x * side, n.y)
	var yaw := atan2(nw.x, nw.y)
	var across := Vector3(nw.y, 0, -nw.x)
	for i in count:
		var h := r * (count - i)
		var c := Vector2(top_at.x * side, top_at.y) + nw * (tread * (i + 0.5))
		var step := LuchaKit.box(Vector3(width, h, tread), KERB, Vector3(c.x, y_lo + h * 0.5, c.y))
		step.rotation.y = yaw
		parent.add_child(step)
		for sgn in [-1.0, 1.0]:
			var cheek := LuchaKit.box(Vector3(0.24, h + 0.4, tread), PARAPET, Vector3(c.x, y_lo + (h + 0.4) * 0.5, c.y) + across * ((width * 0.5 + 0.12) * sgn))
			cheek.rotation.y = yaw
			parent.add_child(cheek)


## A street lamp: the kit's `lamp_post` if delivered, else an iron post with a
## cream lantern (matte: no glow in the look).
func _lamp(at: Vector3) -> Node3D:
	var k := LuchaKit.kit_model("lamp_post")
	if k != null:
		k.position = at
		return k
	var root := Node3D.new()
	root.add_child(LuchaKit.cyl(0.07, 2.6, IRON, Vector3(0, 1.3, 0)))
	root.add_child(LuchaKit.box(Vector3(0.3, 0.4, 0.3), Color("#F2E6C8"), Vector3(0, 2.8, 0)))
	root.add_child(LuchaKit.box(Vector3(0.4, 0.08, 0.4), IRON, Vector3(0, 3.04, 0)))
	root.add_child(LuchaKit.cyl(0.14, 0.12, IRON, Vector3(0, 0.06, 0)))
	root.position = at
	return root


## A bench: the kit's `bench` if delivered, else a wooden seat on iron legs.
func _bench() -> Node3D:
	var k := LuchaKit.kit_model("bench")
	if k != null:
		return k
	var root := Node3D.new()
	root.add_child(LuchaKit.box(Vector3(1.5, 0.08, 0.45), POLE_WOOD, Vector3(0, 0.45, 0)))
	root.add_child(LuchaKit.box(Vector3(1.5, 0.4, 0.07), POLE_WOOD, Vector3(0, 0.72, -0.2)))
	for sx in [-0.65, 0.65]:
		root.add_child(LuchaKit.box(Vector3(0.07, 0.45, 0.4), IRON, Vector3(sx, 0.22, 0)))
	return root


## A bush: the kit's `bush` if delivered, else a cluster of green balls.
func _bush(parent: Node3D, at: Vector3, rng: RandomNumberGenerator, size: float) -> void:
	var k := LuchaKit.kit_model("bush")
	if k != null:
		k.position = at
		k.scale = Vector3.ONE * size / 0.6
		parent.add_child(k)
		return
	for i in 3:
		var r := size * rng.randf_range(0.7, 1.0)
		var off := Vector3(rng.randf_range(-size, size) * 0.6, r * 0.8, rng.randf_range(-size, size) * 0.4)
		parent.add_child(LuchaKit.ball(r, BUSH_TONES[rng.randi() % BUSH_TONES.size()], at + off))


## A row of flowers (little balls over a leafy strip), or draped over a parapet.
func _flowers(parent: Node3D, at: Vector3, length: float, rng: RandomNumberGenerator, drape := false) -> void:
	var n := maxi(3, int(length / 0.22))
	for i in n:
		var x := -length * 0.5 + length * (float(i) + 0.5) / n
		var p := at + Vector3(x, rng.randf_range(0.05, 0.18), rng.randf_range(-0.12, 0.12))
		if drape:
			parent.add_child(LuchaKit.ball(0.14, BUSH_TONES[0], p))
			parent.add_child(LuchaKit.ball(0.09, FLOWER_TONES[0] if rng.randf() < 0.7 else FLOWER_TONES[1], p + Vector3(0, 0.08, 0.06)))
		else:
			parent.add_child(LuchaKit.ball(0.1, BUSH_TONES[1], p))
			parent.add_child(LuchaKit.ball(0.07, FLOWER_TONES[rng.randi() % FLOWER_TONES.size()], p + Vector3(0, 0.08, 0)))


## A palm in a round stone planter.
func _palm_planter(parent: Node3D, at: Vector3) -> void:
	var palm := _palm()
	palm.position = at
	parent.add_child(palm)
	parent.add_child(LuchaKit.cyl(0.7, 0.5, KERB, at + Vector3(0, 0.25, 0)))


## A flat quad a-b-c-d facing n (two triangles, each wound to face n).
static func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, n: Vector3) -> void:
	_tri(st, a, b, c, n)
	_tri(st, a, c, d, n)


## One triangle facing n: Godot's front faces wind clockwise seen from the front,
## so the cross product of the edges must point away from n.
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


## One flat stone: a unit quad scaled to w x d, turned by yaw, at p.
static func _stone_xf(p: Vector3, w: float, d: float, yaw: float) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(Vector3(w, 1.0, d)), p)


## The stones as one MultiMesh of flat quads per tone.
func _commit_stones(parent: Node3D, lots: Array, tones: Array) -> void:
	for i in tones.size():
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
		CelPass.paint(mmi, tones[i])
		parent.add_child(mmi)


## THE PLANTS ON BUILDINGS (Parker 11-08: the Building Maker models no plants; it
## marks where they go and the UI creator builds them): every marker object named
## plant_<kind>_N on a building (box, pot, vine...) gets one of the kit's
## plant_<kind>_a/b/c... as its child, so the building's scale and place carry
## over. Variants rotate so neighbours on one building differ. Markers with no
## delivered plant of their kind stay empty. The 4 cm marker discs are hidden.
var _plant_turn := 0
func _plant_markers(building: Node3D) -> void:
	for n in building.find_children("plant_*", "Node3D", true, false):
		var marker := n as Node3D
		var parts := marker.name.split("_")
		if parts.size() < 3 or not parts[2].is_valid_int():
			continue  # a plant itself, or a name that isn't a marker
		var kind := parts[1]
		var ways: Array = []
		for v in ["a", "b", "c", "d", "e"]:
			if LuchaKit.kit_model_exists("plant_%s_%s" % [kind, v]):
				ways.append(v)
		if marker is MeshInstance3D:
			(marker as MeshInstance3D).mesh = null
		if ways.is_empty():
			continue
		var plant := LuchaKit.kit_model("plant_%s_%s" % [kind, ways[_plant_turn % ways.size()]])
		_plant_turn += 1
		if plant != null:
			marker.add_child(plant)


## The house styles to build with: a, b and c always (kit or stand-in), plus any
## later kit style (d, e...) that's been delivered. A new style mixes in by name.
func _house_kinds() -> Array:
	var out := ["a", "b", "c"]
	for k in ["d", "d_tan", "e", "f"]:  # d_tan: house d in tan (Parker 11-08), its own style
		if LuchaKit.kit_model_exists("plaza_house_" + k):
			out.append(k)
	return out


## NO TWO NEIGHBOURS ALIKE (Parker 11-08: "make sure no 2 buildings right next to
## each other are the same"): a style other than the last house placed in the
## same row, including across a gap left for stairs or a street. Only a different
## style counts; a rescaled or mirrored copy would still look the same.
## How often each building family comes up, relative to 1 (Parker 11-08:
## "there's too many of those green and tan houses"): the flat-roofed d family
## (d and d_tan together) at half the others.
const HOUSE_WEIGHT := {"d": 0.5}


## Wall colours that read alike in the sun, beyond the same building (Parker
## 11-08: "a yellow house with a yellow house behind it? We dont want that"):
## d_tan's tan sits between a's cream and b's ochre.
const HOUSE_LOOKALIKE := {"d_tan": ["a", "b"], "a": ["d_tan"], "b": ["d_tan"]}


## Do two house styles look the same: the same building (d and d_tan), or wall
## colours that read alike?
static func _clash(a: String, b: String) -> bool:
	if a == "" or b == "":
		return false
	if a.get_slice("_", 0) == b.get_slice("_", 0):
		return true
	return b in HOUSE_LOOKALIKE.get(a, []) or a in HOUSE_LOOKALIKE.get(b, [])


## A house style unlike every one in `avoid` (the last house in the row, and
## whatever stands just in front of or behind this spot): a building family is
## picked by weight among those that clash with none, then a colourway in it. If
## every family clashes, only the row's last house (avoid[0]) is kept apart.
func _pick_kind(kinds: Array, rng: RandomNumberGenerator, avoid: Array) -> String:
	for strict in [true, false]:
		var pool: Array = []
		for k in kinds:
			var ok := true
			for a in (avoid if strict else avoid.slice(0, 1)):
				if _clash(str(k), str(a)):
					ok = false
			if ok:
				pool.append(str(k))
		if pool.is_empty():
			continue
		var families := {}
		for k in pool:
			var fam := str(k).get_slice("_", 0)
			if not families.has(fam):
				families[fam] = []
			(families[fam] as Array).append(k)
		var total := 0.0
		for fam in families:
			total += float(HOUSE_WEIGHT.get(fam, 1.0))
		var roll := rng.randf() * total
		var chosen: String = families.keys()[0]
		for fam in families:
			chosen = fam
			roll -= float(HOUSE_WEIGHT.get(fam, 1.0))
			if roll <= 0.0:
				break
		var ways: Array = families[chosen]
		return str(ways[rng.randi() % ways.size()])
	return str(kinds[rng.randi() % kinds.size()])


## The houses placed so far, by row (0 the square's row, k + 1 terrace k): each
## [the angle it's seen at from the play camera, its half-width in angle, kind],
## so a row can see what stands in front of it on screen.
const VIEW_FROM := Vector2(0.0, 7.0)  # the play camera's place, about (x, z)
const VIEW_MARGIN := 0.07  # radians: houses that only touch on screen count too
var _placed := {}
static func _view(at: Vector3, w: float) -> Vector2:
	var dx := at.x - VIEW_FROM.x
	var dz := VIEW_FROM.y - at.z
	return Vector2(atan2(dx, dz), (w * 0.5) / maxf(Vector2(dx, dz).length(), 0.1))


func _log_house(row: int, at: Vector3, w: float, kind: String) -> void:
	if not _placed.has(row):
		_placed[row] = []
	var v := _view(at, w)
	(_placed[row] as Array).append([v.x, v.y, kind])


## The styles of the houses in the two rows in front (row - 1, row - 2) that a
## spot at `at` (w wide) overlaps as the play camera sees it: they stand stacked
## one above the other on screen, so they mustn't look alike.
func _in_front(row: int, at: Vector3, w: float) -> Array:
	var v := _view(at, w)
	var out: Array = []
	for r in [row - 1, row - 2]:
		for h in _placed.get(r, []):
			if absf(float(h[0]) - v.x) < float(h[1]) + v.y + VIEW_MARGIN:
				out.append(str(h[2]))
	return out


## A house style's width along the street: the known kit widths, or measured from
## the model's meshes for a newer style.
var _house_w_cache := {}
func _house_w(kind: String) -> float:
	if HOUSE_W.has(kind):
		return float(HOUSE_W[kind])
	if not _house_w_cache.has(kind):
		var m := LuchaKit.kit_model("plaza_house_" + kind)
		_house_w_cache[kind] = _local_aabb(m).size.x if m != null else 4.8
		if m != null:
			m.free()
	return float(_house_w_cache[kind])


## A kit plaza house (a, b, c or a later style), or a plain stand-in.
func _house(kind: String) -> Node3D:
	var k := LuchaKit.kit_model("plaza_house_" + kind)
	if k != null:
		_plant_markers(k)
		return k
	var w := float(HOUSE_W.get(kind, 4.8))
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
		_pot_church(k)
		_plant_markers(k)
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


## The poinsettia pots on the church towers' ledges (the UI creator's
## pot_poinsettia_a/b/c on the Building Maker's pot_spot_1..4 markers): each pot a
## child of its marker, so the church's scale and place carry over. Neighbours differ.
const CHURCH_POTS := ["a", "b", "c", "a"]
func _pot_church(church: Node3D) -> void:
	for i in CHURCH_POTS.size():
		var spot := church.find_child("pot_spot_%d" % (i + 1), true, false) as Node3D
		if spot == null:
			continue
		var pot := LuchaKit.kit_model("pot_poinsettia_" + str(CHURCH_POTS[i]))
		if pot == null:
			continue
		spot.add_child(pot)
		if spot is MeshInstance3D:
			(spot as MeshInstance3D).mesh = null  # the 4 cm marker disc: the pot stands on it


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
	CelPass.paint(cap, Color("#D2643A"))
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


## THE PALMS VARY (Parker 11-08: "make the palm trees not all face exactly the
## same way or have the BM make some more palm trees"): each palm is a kit style
## (palm, palm_b, palm_c... whichever are delivered) turned to its own heading,
## leaned a little and sized a little, from a running seed, so no two match.
var _palm_rng: RandomNumberGenerator = null
var _palm_last := ""
func _palm() -> Node3D:
	if _palm_rng == null:
		_palm_rng = RandomNumberGenerator.new()
		_palm_rng.seed = 77
	var styles: Array = []
	for nm in ["palm", "palm_b", "palm_c", "palm_d"]:
		if LuchaKit.kit_model_exists(nm):
			styles.append(nm)
	if not styles.is_empty():
		var nm := str(styles[_palm_rng.randi() % styles.size()])
		while nm == _palm_last and styles.size() > 1:
			nm = str(styles[_palm_rng.randi() % styles.size()])
		_palm_last = nm
		var k := LuchaKit.kit_model(nm)
		# A holder takes the caller's position, rotation and scale; the palm inside
		# keeps its own heading, lean and size.
		var holder := Node3D.new()
		holder.add_child(k)
		k.rotation = Vector3(_palm_rng.randf_range(-0.06, 0.06), _palm_rng.randf() * TAU, _palm_rng.randf_range(-0.06, 0.06))
		k.scale = Vector3.ONE * _palm_rng.randf_range(0.85, 1.15)
		return holder
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
	m.add_to_group(UI_ROOT)
	cam.add_child(m)
	m.position = Vector3(0, 0, -MENU_DIST)
	m.scale = Vector3.ONE * UI_SCALE
	return m


func _build_menus() -> void:
	# THE TITLE
	var t := _menu()
	var logo_shift := cam.project_position(Vector2(10, 0), MENU_DIST).distance_to(cam.project_position(Vector2.ZERO, MENU_DIST)) / UI_SCALE
	t.set_header(LuchaKit.title_logo(), Vector3(3.0 + logo_shift, 2.4, 0))
	t.header_tilt = -0.07
	t.anchor_header = true
	t.column_x = Menu3D.MENU_COLUMN_X
	t.top_y = Menu3D.MENU_TOP_Y
	# PLAY TOGETHER is off the title for now (Parker 11-10: "completely remove play
	# together as a mode... first lets only focus on the online multiplayer"). Its
	# screen below stays built for when local play comes back.
	t.add_button("PLAY ONLINE", func(): main.show_screen("online"))
	t.add_button("PRACTICE", main._open_practice)
	t.add_button("CUSTOMIZE", func(): main.show_screen("customize"))
	t.add_button("CONTROLS", func(): main._controls_back = "title"; main.show_screen("controls"))
	t.add_button("OPTIONS", func(): main._options_back = "title"; main.show_screen("options"))
	t.add_button("QUIT", main.quit_game)
	# PRESS ANY BUTTON TO START, under the big logo (Parker 11-11).
	var press := LuchaKit.kit_model("title_press_any")
	if press == null:
		press = LuchaKit.poster_text("PRESS ANY BUTTON TO START", 0.36, LuchaKit.GOLD, LuchaKit.RED, 0.06)
		LuchaKit.center_digits(press)
	var press_holder := Node3D.new()
	press_holder.add_child(press)
	press_holder.position = Vector3(0, -2.35, 0.1)
	press_holder.visible = false
	t.add_child(press_holder)
	t.attract_plate = press_holder
	t.attract_tilt = deg_to_rad(LuchaKit.LOGO_TILT_DEG)  # level on the press screen; the menu keeps its tilt
	menus.title = t
	# Practice choices are independent of multiplayer settings.
	var training := _menu()
	training.set_header(LuchaKit.banner("PRACTICE"), Vector3(0, 3.2, 0))
	training.add_button("FIGHT!", main._start_practice)
	var practice_modes := ["scramble", "tower", "delmar"]
	training.add_choice("MODE", ["CLASSIC", "TOWER", "DEL MAR"], 0, func(i): main.practice_settings.practice_mode = practice_modes[i])
	training.add_choice("BASE", Modes.BASE_NAMES.map(func(n): return n.to_upper()), 1, func(i): main.practice_settings.base = Modes.BASES[i])
	training.add_button("LEAVE", func(): main.show_screen("title"))
	menus.practice_settings = training
	# PLAY TOGETHER
	var l := _menu()
	l.set_header(LuchaKit.banner("PLAY TOGETHER"), Vector3(0, 3.2, 0))
	l.column_x = Menu3D.MENU_COLUMN_X
	l.top_y = Menu3D.MENU_TOP_Y
	var mode_ids := ["scramble", "tower", "delmar"]
	l.add_choice("MODE", mode_ids.map(func(id): return str(Modes.row(id).name).to_upper()), maxi(0, mode_ids.find(str(Net.settings.get("mode", "scramble")))), func(i):
		Net.settings.mode = mode_ids[i]
		_refresh_cards())
	l.add_choice("CLOCK", Modes.TIMER_NAMES, maxi(0, Modes.TIMERS.find(float(Net.settings.get("timer", 60.0)))), func(i): Net.settings.timer = Modes.TIMERS[i])
	l.add_choice("SPAWN", ["SWAP", "LEFT", "RIGHT", "RANDOM"], maxi(0, Modes.SPAWNS.find(str(Net.settings.get("spawn", "alternate")))), func(i): Net.settings.spawn = Modes.SPAWNS[i])
	l.add_choice("BASE", Modes.BASE_NAMES.map(func(n): return n.to_upper()), maxi(0, Modes.BASES.find(str(Net.settings.get("base", "random")))), func(i):
		Net.settings.base = Modes.BASES[i]
		main.preview_base(Modes.BASES[i]))

	_mode_card = _build_mode_card()
	if _mode_card != null:
		l.add_child(_mode_card)
	_local_start = l.add_button("FIGHT!", main._start_local)
	l.add_button("REMOVE LAST", func():
		if not Players.slots.is_empty():
			Players.remove_player(Players.slots.size() - 1)
		_refresh_cards())
	l.add_button("BACK", func(): main.show_screen("title"))
	menus.local = l
	# PAUSE
	var p := _menu()
	p.set_header(LuchaKit.banner("TIME OUT!"), Vector3(0, 3.2, 0))
	p.column_x = Menu3D.MENU_COLUMN_X
	p.top_y = Menu3D.MENU_TOP_Y
	# IN FRONT OF EVERYTHING (Parker 11-08: "make the menu draw in front of everything
	# when paused"): the follow camera sits close to the play, so the pause menu
	# rides PAUSE_DIST from the lens instead of MENU_DIST, scaled to the same size on
	# screen: nothing in the world can come between it and the camera.
	p.position = Vector3(0, 0, -PAUSE_DIST)
	p.scale = Vector3.ONE * UI_SCALE * PAUSE_DIST / MENU_DIST
	menus.pause = p
	var ai := _menu()
	ai.column_x = Menu3D.MENU_COLUMN_X
	ai.top_y = Menu3D.MENU_TOP_Y
	ai.set_header(LuchaKit.banner("PRACTICE AI"), Vector3(0, 3.2, 0))
	for level in ["none", "stationary", "easy", "hard"]:
		var choice: String = level
		ai.add_button("NO NPC" if choice == "none" else ("STATIONARY" if choice == "stationary" else "CLIMB " + choice.to_upper()), func(): main.game.set_practice_ai(choice))
	ai.add_button("BACK", func(): main.show_screen("pause"))
	ai.position = p.position
	ai.scale = p.scale
	menus.practice_ai = ai
	# RESULTS: the UI creator's board on the left (PARTS.md J): TOP DOG and the winner
	# pinned, the rolling leaderboard, REMATCH! and BACK in its footer.
	var r := ResultsBoard.new(cam)
	r.lucha = self
	r.add_to_group(UI_ROOT)
	cam.add_child(r)
	r.position = Vector3(0, 0, -MENU_DIST)
	r.scale = Vector3.ONE * UI_SCALE
	r.set_buttons(func():
		if main.local_mode:
			main.game.host_start(Net.settings.duplicate() if main.game.settings.mode != "practice" else main.game.settings, main.game.roster)
			main.show_screen("hud")
		elif Net.is_host():
			if main.game.host_start(Net.settings.duplicate(), Net.build_roster()):
				Net.set_in_match(true)
		else:
			main._on_announce("The host starts the next game.", false), main.leave_results)
	menus.results = r
	# Player cards (Play together) and the podium (results) hang in the same frame.
	_cards = Node3D.new()
	_cards.add_to_group(UI_ROOT)
	_cards.set_meta("follow_column", true)  # beside the column: it moves with it
	cam.add_child(_cards)
	_cards.position = Vector3(0.2, 0.30, -MENU_DIST)  # (the UI pass, batch 3: the crests clear the banner)
	_cards.scale = Vector3.ONE * UI_SCALE
	_cards.visible = false
	_podium = Node3D.new()
	main.world.add_child(_podium)
	_podium.position = Vector3(0, 0, 1.08)
	_podium.scale = Vector3.ONE * 1.15
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


## THE DEL MAR CARD (the UI creator's mode_card_delmar, PARTS.md G10): its sea scene in
## a gold frame; the game writes the name on its red plate and the blurb on its navy bar.
func _build_mode_card(row_y := Menu3D.MENU_TOP_Y) -> Node3D:
	var card := LuchaKit.kit_model("mode_card_delmar")
	if card == null:
		return null
	card.name = "ModeCardDelMar"
	var nm := LuchaKit.fit_text("DEL MAR", 1.7, 0.26, LuchaKit.GOLD, LuchaKit.INK)
	nm.position = Vector3(0, -0.74, 0.1)
	card.add_child(nm)
	var lines := ["ONE VERSUS ONE, OUT OVER THE SEA.", "GET PAST THE ROPE TO LOCK IN. DON'T FALL IN!"]
	for i in lines.size():
		var t := LuchaKit.fit_text(lines[i], 2.15, 0.1, LuchaKit.CREAM, LuchaKit.INK)
		t.position = Vector3(0, -1.15 - 0.15 * i, 0.05)
		card.add_child(t)
	# Beside the MODE belt (row_y: that row's height), its top just under the header.
	card.position = Vector3(Menu3D.MENU_COLUMN_X + Menu3D.BELT_W * 0.5 + 1.5, row_y - 0.5, 0.0)
	card.scale = Vector3.ONE * 0.8
	card.rotation.z = -0.04
	card.visible = false
	return card


func _refresh_cards() -> void:
	if _mode_card != null:
		var on := str(Net.settings.get("mode", "scramble")) == "delmar"
		if on:
			Stage.warm_delmar()
		if on and not _mode_card.visible:
			_mode_card.scale = Vector3.ONE * 0.08
			create_tween().tween_property(_mode_card, "scale", Vector3.ONE * 0.8, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_mode_card.visible = on
	if _local_start >= 0 and menus.has("local"):
		var minimum := int(Modes.row(str(Net.settings.get("mode", "scramble"))).min_players)
		menus.local.set_label(_local_start, "JOIN 2 TO FIGHT" if Players.slots.size() < minimum else "FIGHT!")
	if _cards == null:
		return
	for ch in _cards.get_children():
		ch.queue_free()
	var n := maxi(Players.slots.size(), 1)
	for s in mini(Players.slots.size(), 8):
		var slot: Dictionary = Players.slots[s]
		var card := LuchaKit.card_frame(LuchaKit.CREAM, slot.tint)
		card.position = _card_at(s)
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
		create_tween().tween_property(card, "scale", Vector3.ONE * CARD_ROW_SCALE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if Players.slots.size() < 8:
		var s := Players.slots.size()
		var empty := LuchaKit.card_frame(Color(0.9, 0.86, 0.78), LuchaKit.INK)
		empty.position = _card_at(s)
		var join := LuchaKit.poster_text("PRESS A\nOR SPACE", 0.12, LuchaKit.RED, LuchaKit.CREAM, 0.02)
		join.position = Vector3(0, 0.05, 0.05)
		empty.add_child(join)
		empty.set_meta("pulse", true)
		empty.scale = Vector3.ONE * CARD_ROW_SCALE
		_cards.add_child(empty)
	no_shadows(_cards)


## A Play together card's place: one row of five, 1.35 apart, a second row only past five.
func _card_at(s: int) -> Vector3:
	return Vector3(-1.45 + (s % CARD_ROW) * CARD_ROW_DX, -(s / CARD_ROW) * CARD_DY * CARD_ROW_SCALE, 0)


# ================================================================ narrow windows

## THE NARROW-WINDOW RULE (the UI pass, batch 7). Every camera-hung UI root is in the
## group UI_ROOT. From 16:10 up the column menus anchor to the screen's left edge (7a).
## Narrower, the whole UI shrinks by k = half_w / 6.11 about the screen's centre and
## lays out exactly as at 16:10 (7b): the edge anchors use virtual_half_w / _h.
const UI_ROOT := &"ui_root"
const NARROWEST_HALF_W := 6.11  # 16:10, in menu units
var ui_k := 1.0
var virtual_half_w := 6.79
var virtual_half_h := 3.82
var column_shift := {}  # menu id -> how far its column moved right (its own units)
var _narrow_aspect := -1.0


func _tick_narrow() -> void:
	var vs: Vector2 = main.get_viewport().get_visible_rect().size
	var aspect := vs.x / maxf(1.0, vs.y)
	var half_h := tan(deg_to_rad(cam.fov * 0.5)) * MENU_DIST / UI_SCALE
	var half_w := half_h * aspect
	ui_k = minf(1.0, half_w / NARROWEST_HALF_W)
	virtual_half_w = half_w / ui_k
	virtual_half_h = half_h / ui_k
	var roots := get_tree().get_nodes_in_group(UI_ROOT)
	for n in roots:
		_capture_home(n as Node3D)
	if absf(aspect - _narrow_aspect) > 0.001:
		_narrow_aspect = aspect
		for id in menus:
			var m = menus[id]
			if m is ResultsBoard or not (m is Menu3D):
				continue
			var hp: Vector3 = (m as Node3D).get_meta("ui_home_p", (m as Node3D).position)
			var hs: Vector3 = (m as Node3D).get_meta("ui_home_s", (m as Node3D).scale)
			var local := virtual_half_w * UI_SCALE * (absf(hp.z) / MENU_DIST) / maxf(hs.x, 0.001)
			column_shift[id] = (m as Menu3D).anchor_to(local)
	var shift: float = float(column_shift.get(current, 0.0))
	for n in roots:
		var nd := n as Node3D
		var hp: Vector3 = nd.get_meta("ui_home_p")
		var hs: Vector3 = nd.get_meta("ui_home_s")
		var dx := shift * UI_SCALE if nd.get_meta("follow_column", false) else 0.0
		nd.position = Vector3((hp.x + dx) * ui_k, hp.y * ui_k, hp.z)
		nd.scale = hs * ui_k
		nd.set_meta("ui_applied_p", nd.position)
		nd.set_meta("ui_applied_s", nd.scale)


## A root's own place and size, as its code set them (re-read whenever code moves it).
static func _capture_home(n: Node3D) -> void:
	if n.get_meta("ui_code_home", false):
		return  # (it writes its own ui_home_p / _s)
	if not n.has_meta("ui_home_p") or not n.position.is_equal_approx(n.get_meta("ui_applied_p", n.position)):
		n.set_meta("ui_home_p", n.position)
	if not n.has_meta("ui_home_s") or not n.scale.is_equal_approx(n.get_meta("ui_applied_s", n.scale)):
		n.set_meta("ui_home_s", n.scale)


## Where the free space right of the results board is centred, in NDC x (the camera
## shifts the podium there). 2.25 is the board's right edge (4.5) halved, in menu units.
func board_free_centre_ndc() -> float:
	return 2.25 / maxf(virtual_half_w, 0.01)


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
		step.position = home + Vector3(0, -7.0, 0)
		var tw := create_tween()
		tw.tween_interval(0.25 + k * 0.3)
		tw.tween_property(step, "position", home, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		k += 1


func _fill_results() -> void:
	_podium.position.x = main.results_podium_focus().x
	var res: Dictionary = main.game.results
	var g: Game = main.game
	var w := int(res.get("winner", -1))
	var best: Dictionary = res.get("best", {})
	var order := best.keys()
	order.sort_custom(func(a, b): return float(best[a]) > float(best[b]))
	# Everyone in the lobby: a player who never set a height still has a row.
	for e in g.roster:
		if not order.has(int(e.pid)) and not order.has(e.pid):
			order.append(int(e.pid))
	if w >= 0:
		order.erase(w)
		order.push_front(w)
	for i in 3:
		var step := _podium.find_child("podium_%d" % (i+1), true, false) as Node3D
		if step == null:
			continue
		var old := step.get_node_or_null("Finisher")
		if old != null:
			step.remove_child(old)
			old.queue_free()
		if i >= order.size():
			continue
		var figure := Game.KNIGHT.instantiate() as Node3D
		figure.name = "Finisher"
		figure.rotation.y = PI
		figure.scale = Vector3.ONE * Feel.get_k("body_scale") / _podium.scale.x
		figure.position.y = [1.0, 0.7, 0.5][i]
		for side in [1, -1]:
			var pivot := Vector3(side * 0.225, 1.582, 0)
			var turn := Basis(Vector3.BACK, side * (0.82 if i == 0 else deg_to_rad(-42.0)))
			var shoulder_pose := Transform3D(turn, pivot - turn * pivot)
			var forearm_pose := shoulder_pose
			if i > 0:
				# Fold the forearm back toward the hip around the posed elbow.
				var elbow := Vector3(side * 0.625, pivot.y, 0)
				var forearm_turn := Basis(Vector3.BACK, side * deg_to_rad(-138.0))
				forearm_pose = Transform3D(forearm_turn, shoulder_pose * elbow - forearm_turn * elbow)
			for limb_name in ["Shoulder", "Wrist", "Hand"]:
				var limb := figure.find_child(("" if side == 1 else "L_") + limb_name, true, false) as Node3D
				if limb != null:
					limb.transform = (shoulder_pose if limb_name == "Shoulder" else forearm_pose) * limb.transform
		CelPass.celify(figure)
		step.add_child(figure)
	# THE BOARD (PARTS.md J): the winner's plate and everyone else's row, in order.
	var delmar: bool = g.stage != null and g.stage.delmar
	# Del Mar's heights are metres out along the rope; only the winner's plate says OUT.
	var height_of := func(v: float) -> String:
		return "%.2f M" % (maxf(0.0, v - Stage.PIER_END) if delmar else v)
	var who := func(pid: int) -> Dictionary:
		var e: Dictionary = g.roster_entry(pid)
		var tc = e.get("tint", Color.WHITE)
		return {"name": str(g.player_name(pid)).split(" the ")[0].to_upper(),
			"height": height_of.call(float(best.get(pid, 0.0))),
			"tint": tc if tc is Color else Color(str(tc)),
			"own": not main.local_mode and int(e.get("peer", -1)) == g.me(),
			# Its machine's Steam name, for the name flip (none offline or for a local game).
			"steam": str(Net.members.get(int(e.get("peer", -1)), {}).get("name", "")) if Net.online and Net.steam_ok and not main.local_mode else ""}
	var winner := {}
	var others: Array = []
	for pid in order:
		if int(pid) == w and w >= 0:
			winner = who.call(int(pid))
			if delmar:
				winner.height = str(winner.height) + " OUT"
		else:
			others.append(who.call(int(pid)))
	var top_s: String = height_of.call(float(res.get("top", 0.0)))
	(menus.results as ResultsBoard).fill(winner, others, "TOWER " + top_s, not main.local_mode and not Net.is_host())


# ================================================================ the match HUD

func _build_hud() -> void:
	_hud = Node3D.new()
	_hud.add_to_group(UI_ROOT)
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
	_clock_text.reparent(hud_bottom, false)
	_hud.get_node("Buckle").reparent(hud_bottom, false)
	_info.reparent(hud_bottom, false)
	_steam_tag = Node3D.new()
	_steam_tag.name = "SteamTag"
	hud_bottom.add_child(_steam_tag)
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
	var string := LuchaKit.bunting(Vector3(-LINE_HALF_W, 0.0, LINE_Z), Vector3(LINE_HALF_W, 0.0, LINE_Z), int(LINE_HALF_W * 2.0 / 0.55), LINE_SAG)
	string.name = "LineFlags"
	# The string's middle, over the ring and the tower, sits ON the line (Parker 11-11:
	# "being over the line more closely matches what you can see"): it's lifted by its
	# sag, so only the far ends, out by the poles, ride a little high.
	string.position.y = LINE_SAG
	bar.add_child(string)
	for f in string.find_children("*", "Node3D", true, false):
		if f.has_meta("sway"):
			_flags.append(f)
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
	if low.contains("tops") or low.contains("top dog"):
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
func play_lock_effect(effect: String) -> void:
	if effect == "treats":
		preload("res://ui3d/dog_treats.gd").burst(cam)
		Sound.play("clap", -4.0)
	elif effect == "treasure":
		preload("res://ui3d/treasure_effect.gd").burst(cam)
		Sound.play("clap", -4.0)
	elif effect == "bills":
		preload("res://ui3d/peso_bills.gd").burst(cam)
		Sound.play("clap", -4.0)
	elif effect == "roses":
		preload("res://ui3d/rose_petals.gd").burst(cam)
		Sound.play("clap", -4.0)
	else:
		confetti()


func confetti(big := false) -> void:
	# A fresh burst profile varies the silhouette without extra particles or per-frame work.
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var lean := rng.randf_range(-0.18, 0.18)
	var lift := rng.randf_range(0.94, 1.06)
	var origin := Vector3(rng.randf_range(-0.18, 0.18), rng.randf_range(-0.06, 0.06), 0)
	var root := Node3D.new()
	root.name = "ConfettiBurst"
	root.set_meta("burst_profile", [origin, lean, lift])
	cam.add_child(root)
	for side in ([-1.0, 1.0] if big else [0.0]):
		for band in 7:
			for shape in 4:
				var p := CPUParticles3D.new()
				p.one_shot = true
				p.explosiveness = rng.randf_range(0.80, 0.90)
				var band_count := (23 if band < 6 else 22) if big else 10
				p.amount = band_count / 4 + (1 if (shape + band) % 4 < band_count % 4 else 0)
				p.lifetime = 3.2 if big else 2.2
				p.mesh = _confetti_mesh(shape)
				p.set_meta("coverage_lane", band)
				p.set_meta("shape", shape)
				var m := StandardMaterial3D.new()
				m.vertex_color_use_as_albedo = true
				m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				m.cull_mode = BaseMaterial3D.CULL_DISABLED
				p.material_override = m
				var grad := Gradient.new()
				grad.offsets = PackedFloat32Array([0.0, 0.17, 0.34, 0.5, 0.67, 0.84])
				var colors := PAPEL.duplicate()
				for i in range(colors.size()-1, 0, -1):
					var j := rng.randi_range(0, i)
					var swap: Color = colors[i]
					colors[i] = colors[j]
					colors[j] = swap
				grad.colors = PackedColorArray(colors)
				grad.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
				p.color_initial_ramp = grad
				var angle := deg_to_rad(-42.0 + band * 14.0 + rng.randf_range(-2.5, 2.5))
				p.direction = Vector3(-side * 0.6 + tan(angle) + lean, 1.0, rng.randf_range(-0.04, 0.04))
				p.spread = rng.randf_range(17.0, 20.0)
				p.initial_velocity_min = 0.8 * lift
				p.initial_velocity_max = 7.0 * lift
				p.gravity = Vector3(0, -4.0, 0)
				p.damping_min = 1.0
				p.damping_max = 2.0
				p.angular_velocity_min = rng.randf_range(-400.0, -300.0)
				p.angular_velocity_max = rng.randf_range(300.0, 400.0)
				p.angle_max = 360.0
				p.scale_amount_min = 0.85
				p.scale_amount_max = 1.45
				root.add_child(p)
				p.position = Vector3(side * 2.6, -0.6 if big else 0.6, -5.0) + origin
				p.set_meta("burst_profile", [origin, lean, lift, p.spread])
				p.emitting = true
				p.finished.connect(p.queue_free)
	root.get_tree().create_timer(4.2 if big else 3.0).timeout.connect(func():
		if is_instance_valid(root):
			root.queue_free())
	Sound.play("clap", -4.0)


func _process(delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	_tick_narrow()
	_festive_tick(delta, t)
	for c in _clouds:
		var n: Node3D = c
		# (It jumped from x 80 to -80 in plain view: it wraps only off screen now.)
		LuchaKit.drift_cloud(n, float(n.get_meta("speed")) * delta, float(n.get_meta("half_w")), -80.0, 80.0)
	_tick_hud_occlusion(delta)
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
		hud_bottom.get_node("Buckle").visible = show
		var half_h := virtual_half_h  # (the HUD's own space, which shrinks in narrow windows)
		var half_w := virtual_half_w
		hud_bottom.get_node("Buckle").position = Vector3(half_w - 1.15, half_h - 1.05, 0)
		_clock_text.position = hud_bottom.get_node("Buckle").position + Vector3(0, 0, 0.075)
		_info.position = Vector3(half_w - 0.95, -half_h + 0.45, 0)
		_steam_tag.position = Vector3(-half_w + 0.3, half_h - 0.4, 0)
		# The who's-climbing label repeats the banner's news, and its tail covers it:
		# it waits too.
		_info.visible = not (_banner != null and _banner.visible)
		hud_bottom.tick(delta)
		if _bell != null:
			_bell.visible = false
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
		# The Steam name, top left, read from its left edge (online only).
		var steam := hud_bottom.steam_shown.to_upper() if show else ""
		if steam != _steam_text:
			_steam_text = steam
			for ch in _steam_tag.get_children():
				ch.queue_free()
			if steam != "":
				var st := LuchaKit.poster_text(steam, 0.26, LuchaKit.GOLD, LuchaKit.INK, 0.05)
				st.position = Vector3(steam.length() * 0.09, 0, 0)
				_steam_tag.add_child(st)
				no_shadows(st)
		if info != _info_text:
			_info_text = info
			for ch in _info.get_children():
				ch.queue_free()
			if info.begins_with("ROUND") or info == "PRACTICE":
				# THE ROUND TAB (the UI pass, 1d): a cream tab, label-red words.
				var tab := LuchaKit.kit_model("bind_col_tab")
				if tab == null:
					tab = LuchaKit._plate(1.22, 0.4, Color("#E6D8B4"))
				else:
					for mi in tab.find_children("*", "MeshInstance3D", true, false):
						(mi as MeshInstance3D).set_instance_shader_parameter(&"tint", Color("#E6D8B4"))
				_info.add_child(tab)
				var tt := LuchaKit.fit_text(info, 1.0, 0.2, LuchaKit.RED, LuchaKit.CREAM)
				tt.position = Vector3(0, 0, 0.08)
				LuchaKit.center_digits(tt)
				_info.add_child(tt)
				no_shadows(_info)
			elif info != "":
				# The other match lines on a plate (the UI pass, 4c): the Controls row label,
				# its right end against where the ROUND tab stands.
				var plate := LuchaKit.kit_model("bind_label")
				if plate == null:
					plate = LuchaKit._plate(2.7, 0.46, Color("#1E2C5C"))
				var hold := Node3D.new()
				hold.position = Vector3(-1.8, 0, 0)
				plate.scale = Vector3.ONE * 0.8
				hold.add_child(plate)
				var it := LuchaKit.fit_words(info, 1.5, 0.22, LuchaKit.CREAM, LuchaKit.INK)
				it.position = Vector3(0, 0, 0.08)
				LuchaKit.center_digits(it)
				hold.add_child(it)
				_info.add_child(hold)
				no_shadows(hold)
		var v := int(ceil(g.clock)) if show else -1
		if v != _clock_val:
			_clock_val = v
			for ch in _clock_text.get_children():
				ch.queue_free()
			if v >= 0:
				var on_kit := LuchaKit.kit_model_exists("clock_buckle")
				var col := LuchaKit.RED if v <= 10 else (LuchaKit.INK if on_kit else LuchaKit.GOLD)
				var num := LuchaKit.text3d(str(v), 0.34 if on_kit else 0.42, col, 0.03)
				LuchaKit.center_digits(num)  # dead centre on the face (Parker 11-09)
				_clock_text.add_child(num)
				no_shadows(num)
				# THE COUNTDOWN PULSE (Parker 11-09: "start pulsing each number at 10"):
				# from 10 down each number lands big and thumps back, and the buckle bumps
				# with it; the tick sounds with each one (main.gd).
				if v <= COUNTDOWN_FROM:
					if _pulse_tween != null and _pulse_tween.is_valid():
						_pulse_tween.kill()
					var buckle_node := hud_bottom.get_node("Buckle") as Node3D
					_clock_text.scale = Vector3.ONE * 1.6
					buckle_node.scale = Vector3.ONE * 1.08
					_pulse_tween = create_tween().set_parallel(true)
					# Eased back over half a second (an elastic curve left 1.6 within a frame or two,
					# so the pulse barely showed).
					_pulse_tween.tween_property(_clock_text, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
					_pulse_tween.tween_property(buckle_node, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
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


## Fade each HUD section whenever any player's body overlaps it on screen.
func _tick_hud_occlusion(delta: float) -> void:
	if _hud == null or not _hud.is_visible_in_tree():
		return
	var actors: Array[Rect2] = []
	var climbers: Array = main.game.climbers.values()
	if is_instance_valid(main.game.partner):
		climbers.append(main.game.partner)
	for c: Climber in climbers:
		if c.removed or c.state not in [Climber.State.LIVE, Climber.State.PUPPET]:
			continue
		var bounds := c.pose_bounds(c.pose())
		var projected := Rect2()
		var first := true
		for point in [bounds.position, Vector2(bounds.end.x, bounds.position.y), bounds.end, Vector2(bounds.position.x, bounds.end.y)]:
			var world_point := Vector3(point.x, point.y, 0)
			if cam.is_position_behind(world_point):
				continue
			var pixel := cam.unproject_position(world_point)
			projected = Rect2(pixel, Vector2.ZERO) if first else projected.expand(pixel)
			first = false
		if not first:
			actors.append(projected.grow(8.0))
	var groups: Array = hud_bottom.get_children()
	groups.erase(_clock_text)
	groups.erase(hud_bottom.get_node("Buckle"))
	for group: Node3D in groups:
		if not group.is_visible_in_tree():
			continue
		var meshes: Array = group.find_children("*", "GeometryInstance3D", true, false)
		if group is GeometryInstance3D:
			meshes.append(group)
		var covered := false
		for mesh: GeometryInstance3D in meshes:
			if not mesh.is_visible_in_tree():
				continue
			var box := mesh.get_aabb()
			var rect := Rect2()
			for i in 8:
				var pixel := cam.unproject_position(mesh.global_transform * box.get_endpoint(i))
				rect = Rect2(pixel, Vector2.ZERO) if i == 0 else rect.expand(pixel)
			for actor in actors:
				if rect.intersects(actor):
					covered = true
					break
			if covered:
				break
		for mesh: GeometryInstance3D in meshes:
			var fade := lerpf(mesh.transparency, 0.85 if covered else 0.0, 1.0 - exp(-delta * 18.0))
			# Snap the last bit back to exactly 0: any transparency above 0 keeps a mesh in
			# the alpha pass, off the screen ink (the plate lost its outlines for good once it
			# had faded once, and its face sorted under its body, Parker 11-09).
			if not covered and fade < 0.01:
				fade = 0.0
			mesh.transparency = fade

func _fill_pause() -> void:
	var p: Menu3D = menus.pause
	p.clear_items()
	p.add_button("RESUME", main._toggle_pause)
	if main.game.practice:
		p.add_button("AI SETTINGS", func(): main.show_screen("practice_ai"))
	p.add_button("CONTROLS", func(): main._controls_back = "pause"; main.show_screen("controls"))
	p.add_button("OPTIONS", func(): main._options_back = "pause"; main.show_screen("options"))
	p.add_button("QUIT TO MENU", func():
		get_tree().paused = false
		main.game.end_match()
		if Net.online:
			Net.leave()
		main._to_title(""))
