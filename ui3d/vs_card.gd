class_name VsCard
extends Node3D
## THE VS CARD (Parker 11-22; the design is docs/VS_CARD.md): before every round, two halves of
## a fight poster fly in from the sides, slam together, hold 2 s, then split and fly away into
## the scene. Each half carries its fighters' made names, their Steam names smaller under them,
## and half of the VS medallion (the V left, the S right).
##
## The kit's `vs_half_l` / `vs_half_r` are used when delivered (their nodes `plaque`,
## `steam_strip`, `round_tab` say where the words go); until then the halves are built from kit
## boxes at the design's sizes. Lives in the HUD's near space (LuchaUI.hud_bottom), in HUD units.

const IN_S := 0.35
const SLAM_S := 0.15
const HOLD_S := 2.0
const OUT_S := 0.4
const TOTAL_S := IN_S + SLAM_S + HOLD_S + OUT_S
## The round starts (the host) as the halves leave.
const ROUND_STARTS_AT := IN_S + SLAM_S + HOLD_S + OUT_S * 0.8  # (late in the exit: the spawn's hitch would eat it)

const HALF_W := 5.6
const HALF_H := 3.0
const CARD_Y := 0.05  # the screen's middle, clear of the banner up top
const PLAQUE := Vector2(4.0, 0.95)
const STRIP := Vector2(3.2, 0.42)
## OFF THE WAY THEY CAME (Parker 11-22: "instead of it flying into the background, just have it fly
## back off to the left and right of the screen"; it was launched over the horizon for an hour).
## The kit's halves (Top Dog Kit PARTS.md V): 6.0 long, the medallion 1.7 past the join; the plaque
## and the Steam strip are turned 3 degrees, rising toward the join; navy ink on cream.
const KIT_LEN := 6.0
const KIT_TILT_DEG := 3.0
const NAVY := Color("#241650")

var _halves: Array = []  # [left, right]
var _t := -1.0
var _from_x := 12.0
var _half_h := 3.8
var _slammed := false
var _sparks: Array = []
var _spark_nodes: Array = []  # built hidden in play(), launched at the slam (no instancing on the big frame)
var _call := ""  # what the announcer says at the slam


func playing() -> bool:
	return _t >= 0.0


## left / right: Arrays of {"name": String, "steam": String}.
func play(round_n: int, left: Array, right: Array, half_w: float, half_h := 3.8) -> void:
	_clear()
	_half_h = half_h
	_from_x = half_w + maxf(HALF_W, KIT_LEN) + 0.5
	_halves = [_build_half(-1, left, round_n), _build_half(1, right, round_n)]
	_call = _announcement(left, right)
	_announce()  # (from the throw: the names take longer to say than the card holds)
	for h in _halves:
		add_child(h)
		LuchaUI.no_shadows(h)
	_build_sparks()
	_t = 0.0
	_slammed = false
	visible = true
	set_process(true)
	_pose()


func stop() -> void:
	_clear()
	_t = -1.0
	visible = false
	set_process(false)


func _clear() -> void:
	for h in _halves:
		if is_instance_valid(h):
			(h as Node).queue_free()
	_halves.clear()
	for s in _sparks:
		if is_instance_valid(s.node):
			(s.node as Node).queue_free()
	_sparks.clear()
	for n in _spark_nodes:
		if is_instance_valid(n):
			(n as Node).queue_free()
	_spark_nodes.clear()


func _process(delta: float) -> void:
	if _t < 0.0:
		return
	_t += minf(delta / maxf(Engine.time_scale, 0.001), 0.05)  # (a hitch never skips the show)
	if _t >= TOTAL_S:
		stop()
		return
	_pose()
	_tick_sparks(delta)


func _pose() -> void:
	for i in _halves.size():
		var half: Node3D = _halves[i]
		var side := -1.0 if i == 0 else 1.0
		var at := Vector3(0, CARD_Y, 0)
		var roll := 0.0
		var sc := Vector3.ONE
		if _t < IN_S:
			# Thrown in, speeding up, tilted until it lands.
			var e := pow(_t / IN_S, 1.8)
			at.x = side * lerpf(_from_x, 0.0, e)
			roll = side * deg_to_rad(6.0) * (1.0 - e)
		elif _t < IN_S + SLAM_S:
			var u := (_t - IN_S) / SLAM_S
			sc.x = 1.0 - 0.06 * sin(PI * u)
			at.y += 0.07 * sin(u * 38.0) * (1.0 - u)
			if not _slammed:
				_slammed = true
				_slam()
		elif _t < IN_S + SLAM_S + HOLD_S:
			pass
		else:
			# Apart, then back off the way they came: a little kick toward the middle, then
			# out to the sides, speeding up, tilting the other way.
			var u := (_t - IN_S - SLAM_S - HOLD_S) / OUT_S
			var e := pow(u, 1.8)
			at.x = side * (lerpf(0.0, _from_x, e) - 0.12 * sin(PI * minf(u * 3.0, 1.0)))
			roll = -side * deg_to_rad(6.0) * e
		half.position = at
		half.rotation.z = roll
		half.scale = sc


## THE ANNOUNCER, A STAND-IN (Parker 11-22: "have an announcer say 'STINKY TONY THE TEETH TICKLER! VS!
## AGNES THE WRETCH!'"; "I can do all the voice recordings my self but do option 1 first for now as a
## place holder"): the system's own text-to-speech voice reads the call. Parker's recordings of
## the names' words replace it. Needs audio/general/text_to_speech on (project.godot).
const ANNOUNCER_RATE := 1.35  # quicker than talking: a ring announcer's pace
const ANNOUNCER_PITCH := 0.85  # a little lower


func _announcement(left: Array, right: Array) -> String:
	var sides: Array = []
	for list in [left, right]:
		var names: Array = []
		for f in list:
			names.append(str(f.get("name", "")))
		sides.append(" and ".join(names))
	return "%s! Versus! %s!" % [sides[0], sides[1]]


func _announce() -> void:
	if _call == "" or not DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		return
	var voices := DisplayServer.tts_get_voices_for_language("en")
	if voices.is_empty():
		return
	DisplayServer.tts_stop()
	# The game's master volume, as the speech's 0..100.
	var master := AudioServer.get_bus_index("Master")
	var vol := 1.0 if master < 0 or AudioServer.is_bus_mute(master) == false else 0.0
	if master >= 0:
		vol *= db_to_linear(AudioServer.get_bus_volume_db(master))
	DisplayServer.tts_speak(_call, voices[0], int(clampf(vol, 0.0, 1.0) * 100.0), ANNOUNCER_PITCH, ANNOUNCER_RATE)


func _slam() -> void:
	Sound.play("lock", -3.0, 0.8)
	Sound.play("thud", -2.0)
	for i in _spark_nodes.size():
		if not is_instance_valid(_spark_nodes[i]):
			continue
		var star: Node3D = _spark_nodes[i]
		var a := TAU * i / 10.0 + 0.2
		star.position = Vector3(0, CARD_Y, 0.4)
		star.scale = Vector3.ONE * 0.5
		star.visible = true
		_sparks.append({"node": star, "dir": Vector3(cos(a), sin(a), 0.0), "life": 0.0})
	_spark_nodes.clear()  # (now in _sparks, which frees them)


## The slam's ten sparks, instanced and celified up front (hidden) so the slam frame only
## shows them: a hitch there landed on the card's big moment.
func _build_sparks() -> void:
	for i in 10:
		var star := LuchaKit.kit_model("vs_spark")
		if star == null:
			star = LuchaKit.kit_model("xp_burst_star")
		if star == null:
			return
		star.position = Vector3(0, CARD_Y, 0.4)
		star.scale = Vector3.ONE * 0.5
		star.visible = false
		add_child(star)
		LuchaUI.no_shadows(star)
		_spark_nodes.append(star)


func _tick_sparks(delta: float) -> void:
	for s in _sparks:
		if not is_instance_valid(s.node):
			continue
		s.life += delta / 0.45
		var star: Node3D = s.node
		star.position += (s.dir as Vector3) * delta * 9.0 * maxf(0.0, 1.0 - s.life)
		star.rotation.z += delta * 6.0
		star.scale = Vector3.ONE * 0.5 * maxf(0.0, 1.0 - s.life)
		star.visible = s.life < 1.0


# ---------------------------------------------------------------- one half

## side -1: the left (red corner, the V); +1: the right (blue corner, the S). Origin at the join.
func _build_half(side: int, fighters: Array, round_n: int) -> Node3D:
	var root := Node3D.new()
	root.name = "VsHalfL" if side < 0 else "VsHalfR"
	var kit := LuchaKit.kit_model("vs_half_l" if side < 0 else "vs_half_r")
	var out := float(side)  # +x is outward on the right half
	var plaque_at := Vector3(out * 3.4, 0.3, 0.12)  # clear of the medallion (1.15 wide a side)
	var strip_at := Vector3(out * 3.4, -0.52, 0.12)
	var tab_at := Vector3(out * 4.6, 1.72, 0.1)
	var face_z := 0.02
	var tilt := 0.0
	var name_cap := 0.46
	var name_fit := PLAQUE.x - 0.3
	var name_h := PLAQUE.y - 0.12
	var steam_fit := STRIP.x - 0.25
	var ink := LuchaKit.INK
	if kit != null:
		root.add_child(kit)
		tilt = deg_to_rad(KIT_TILT_DEG) * -out
		name_cap = 0.5
		name_fit = 3.35
		name_h = 1.15
		steam_fit = 2.6
		ink = NAVY
		for pair in [["plaque", "p"], ["steam_strip", "s"], ["round_tab", "t"]]:
			var n := kit.find_child(pair[0], true, false) as Node3D
			if n == null:
				continue
			var at: Vector3 = LuchaUI._local_xf(kit, n).origin
			match pair[1]:
				"p": plaque_at = at
				"s": strip_at = at
				"t": tab_at = at
		var strip := kit.find_child("steam_strip", true, false) as Node3D
		if strip != null:
			strip.visible = fighters.any(func(f): return str(f.get("steam", "")) != "")
	else:
		var main_c := LuchaKit.MAGENTA if side < 0 else Color("#19C6E6")
		var deep_c := LuchaKit.RED if side < 0 else LuchaKit.BLUE
		root.add_child(LuchaKit.box(Vector3(HALF_W, HALF_H, 0.14), deep_c, Vector3(out * HALF_W * 0.5, 0, 0)))
		root.add_child(LuchaKit.box(Vector3(HALF_W - 0.3, HALF_H - 0.9, 0.14), main_c, Vector3(out * HALF_W * 0.5, 0.15, 0.03)))
		for y in [HALF_H * 0.5 - 0.09, -HALF_H * 0.5 + 0.09]:
			root.add_child(LuchaKit.box(Vector3(HALF_W, 0.18, 0.2), LuchaKit.GOLD, Vector3(out * HALF_W * 0.5, y, 0.02)))
		root.add_child(LuchaKit.box(Vector3(0.18, HALF_H, 0.2), LuchaKit.GOLD, Vector3(out * (HALF_W - 0.09), 0, 0.02)))
		root.add_child(LuchaKit.box(Vector3(PLAQUE.x, PLAQUE.y, 0.1), LuchaKit.CREAM, plaque_at - Vector3(0, 0, 0.05)))
		if fighters.any(func(f): return str(f.get("steam", "")) != ""):
			root.add_child(LuchaKit.box(Vector3(STRIP.x, STRIP.y, 0.1), LuchaKit.INK, strip_at - Vector3(0, 0, 0.05)))
		# Half of the medallion: gold, a red face, its letter.
		root.add_child(LuchaKit.box(Vector3(1.15, 2.3, 0.2), LuchaKit.GOLD, Vector3(out * 0.575, 0, 0.1)))
		root.add_child(LuchaKit.box(Vector3(0.95, 1.9, 0.2), LuchaKit.RED, Vector3(out * 0.5, 0, 0.14)))
		var letter := LuchaKit.poster_text("V" if side < 0 else "S", 1.5, LuchaKit.CREAM, LuchaKit.INK, 0.06)
		letter.position = Vector3(out * 0.52, 0, 0.27)
		root.add_child(letter)
		root.add_child(LuchaKit.box(Vector3(1.5, 0.44, 0.1), LuchaKit.CREAM, tab_at - Vector3(0, 0, 0.04)))
	# The words: the made names on the plaque, the Steam names under them, the round on its tab.
	var names: Array = []
	var steams: Array = []
	for f in fighters:
		names.append(str(f.get("name", "?")).to_upper())
		if str(f.get("steam", "")) != "":
			steams.append(str(f.steam).to_upper())
	var turn := Basis(Vector3.BACK, tilt)
	# THE FULL NAME (Parker 11-22: "we do want the FULL name of the climber, not just the small
	# version"). One fighter: two lines, the name big and its "THE ..." title under it, so a long
	# made name still reads large. More than one a side: a full name a line.
	var lines: Array = []  # [text, cap]
	if names.size() == 1 and (names[0] as String).contains(" THE "):
		var cut := (names[0] as String).find(" THE ")
		lines = [[(names[0] as String).substr(0, cut), name_cap * 0.9], [(names[0] as String).substr(cut + 1), name_cap * 0.62]]
		if kit != null:
			# The kit's taller plaque (3.7 x 1.3, PARTS.md V, round 4): the name at 0.5, 0.27 above
			# the plaque's centre; its title at 0.36, 0.30 below.
			lines = [[lines[0][0], 0.5, 0.27], [lines[1][0], 0.36, -0.30]]
	else:
		var rows := maxi(names.size(), 1)
		for nm in names:
			lines.append([nm, minf(name_cap, name_h / rows)])
	var total := 0.0
	for ln in lines:
		total += float(ln[1]) * 1.08
	var y := total * 0.5
	for ln in lines:
		var cap: float = ln[1]
		var lb := LuchaKit.text3d(ln[0], cap, ink)
		_fit(lb, cap, name_fit)
		y -= cap * 0.54
		var line_y: float = float(ln[2]) if (ln as Array).size() > 2 else y
		lb.transform = Transform3D(turn, plaque_at + turn * Vector3(0, line_y, face_z))
		y -= cap * 0.54
		root.add_child(lb)
	if not steams.is_empty():
		var sl := LuchaKit.text3d("  ".join(steams), 0.22, LuchaKit.CREAM)
		_fit(sl, 0.2 if kit != null else 0.22, steam_fit)
		sl.transform = Transform3D(turn, strip_at + Vector3(0, 0, face_z))
		root.add_child(sl)
	var tab := LuchaKit.text3d("ROUND %d" % round_n, 0.2 if kit != null else 0.24, LuchaKit.RED)
	_fit(tab, 0.2 if kit != null else 0.24, 1.3)
	tab.position = tab_at + Vector3(0, 0, face_z)
	root.add_child(tab)
	return root


static func _fit(lb: Label3D, cap: float, width: float) -> void:
	lb.pixel_size = cap / 96.0
	var font: Font = lb.font if lb.font != null else ThemeDB.fallback_font
	var w := font.get_string_size(lb.text, HORIZONTAL_ALIGNMENT_LEFT, -1, lb.font_size).x * lb.pixel_size
	if w > width:
		lb.pixel_size *= width / w
