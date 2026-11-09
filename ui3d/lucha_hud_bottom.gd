class_name LuchaHudBottom
extends Node3D
## THE HUD'S BOTTOM (Parker 11-08): "Replace the bottom with a nice UI designer
## made nameplate of the current guy's name and make sure it is long enough to fit
## the longest names. Also have a height counter down there ... built like an old
## Odometer with the rotating wheels with the numbers on them."
##
## nameplate  the climbing climber's name on the kit's hud_nameplate (its
##            nameplate_face), fitted for 33 letters; in Scramble your own climber,
##            else "ROUND N". Its nameplate_lockin tab says LOCK IN! when your
##            climber is above the line.
## odometer   your climber's top height, 00.00 to 99.99 m, on the kit's
##            hud_odometer: four drums (odo_wheel_*), digits 0-9 round each; the
##            right drum turns smoothly and each drum to its left rolls over as the
##            one beside it passes 9 to 0.
## Stand-ins (a plate, four drums) until the kit's parts land; they swap in by name.

const DIGIT_STEP := TAU / 10.0
const PLATE_AT := Vector3(-1.4, -2.8, 0.0)  # HUD units (x UI_SCALE on screen)
const ODO_AT := Vector3(4.55, -2.8, 0.0)
## THE CORNERS (Parker 11-08: "the new name plate in the bottom left of the screen
## and the new odometer height thing in the bottom right"): each frame the plate's
## left edge and the odometer's right edge sit CORNER_MARGIN in from the screen's
## edges, at any aspect. HUD_HALF_H: the HUD's visible half-height in HUD units.
const HUD_HALF_H := 3.8
const CORNER_MARGIN := 0.35
const PLATE_HALF_W := 2.96 * 0.5 * KIT_SCALE  # the kit plate's half-width in HUD units
const ODO_HALF_W := 1.9 * 0.5 * ODO_SCALE
const KIT_SCALE := 2.4  # the kit's plate (2.6 m face) at HUD size
const ODO_SCALE := 1.8  # the kit's odometer at HUD size (the UI creator's number)
const LOCK_AT := Vector3(-3.2, -2.05, 0.0)  # the LOCK IN tab, above the plate's left end
const LOCK_TEXT := "LOCK IN!"
const NAME_DROP := 0.09  # of the face height: the name's capitals on the gems' line

var main: Node
var _plate: Node3D
var _name_node: Node3D
var _name_shown := ""
var _face_w := 6.2
var _face_h := 0.66
var _gems: Node3D  # the kit's nameplate_lockin: red, lime when you can lock in
var _gems_lit := false
var _face_c := Vector3.ZERO  # the name face's centre, plate space
var _lock: Node3D
var _toaster := false  # the kit's tab: pops out of the nameplate's slot
var _pop_tween: Tween
## True while the LOCK IN tab is up (tests read it).
var popped := false
const TAB_X := -0.78  # the toaster tab in plate space (the UI creator's numbers)
const TAB_DOWN_Y := 0.05  # in the pocket, below the lip
const TAB_UP_Y := 0.30  # the face clear, its foot still in the slot
var _lock_text: Node3D
var _odo: Node3D
var _drums: Array = []  # left to right: tens, units, tenths, hundredths (thousands to units past 100 m)
## Tests only: a height to show in place of the climber's (-1 = the climber's).
var test_height := -1.0
var _odo_point: Node3D = null  # the kit's decimal point, hidden past 100 m
var _shown_h := 0.0
var _digit_colour := LuchaKit.INK


func _init(p_main: Node) -> void:
	main = p_main
	name = "HudBottom"


func _ready() -> void:
	_build_plate()
	_build_odometer()
	LuchaUI.no_shadows(self)


# ---------------------------------------------------------------- the nameplate

func _build_plate() -> void:
	_plate = LuchaKit.kit_model("hud_nameplate")
	var face: MeshInstance3D = null
	if _plate != null:
		face = _plate.find_child("nameplate_face", true, false) as MeshInstance3D
		_plate.scale = Vector3.ONE * KIT_SCALE
		_gems = _plate.find_child("nameplate_lockin", true, false) as Node3D
	else:
		_plate = Node3D.new()
		_plate.add_child(LuchaKit.box(Vector3(6.9, 0.9, 0.08), LuchaKit.GOLD, Vector3(0, 0, -0.02)))
		face = LuchaKit.box(Vector3(6.5, 0.66, 0.08), LuchaKit.RED, Vector3(0, 0, 0.02))
		_plate.add_child(face)
	_plate.position = PLATE_AT
	add_child(_plate)
	if face != null:
		var box := _local_aabb(face, _plate)
		_face_w = box.size.x * 0.92
		_face_h = box.size.y
		_face_c = box.get_center() + Vector3(0, 0, box.size.z * 0.5 + 0.012)
	_name_node = Node3D.new()
	# A Label3D centres its whole line box (descender room included), so capitals
	# sit high: drop the name a little so it lines up with the end gems (Parker 11-08).
	_name_node.position = _face_c - Vector3(0, _face_h * NAME_DROP, 0)
	_plate.add_child(_name_node)
	# The LOCK IN tab above the plate's left end: the climber's foot glyphs draw
	# over the middle of the screen. The kit's tab sits on the kit plate's top
	# edge (plate space, built at the plate's scale); else a gold box, HUD space.
	var kit_tab := LuchaKit.kit_model("hud_lockin_tab") if _gems != null else null
	if kit_tab != null:
		# THE TOASTER (Parker 11-08: "make the part that says lock in a toaster pop
		# up that comes out of the main name plate"): the tab lives in the plate's
		# slot and only its y moves, down in the pocket or popped up.
		_lock = kit_tab
		_toaster = true
		_lock.position = Vector3(TAB_X, TAB_DOWN_Y, 0.0)
		_plate.add_child(_lock)
		var tf := _lock.find_child("lockin_tab_face", true, false) as MeshInstance3D
		var fc := Vector3(0, 0, 0.072)
		var fw := 1.0
		var fh := 0.116
		if tf != null:
			var fb := _local_aabb(tf, _lock)
			fc = fb.get_center() + Vector3(0, 0, fb.size.z * 0.5 + 0.004)
			fw = fb.size.x * 0.92
			fh = fb.size.y
		# The title font runs narrower than fit_text's guess: let it use the face.
		_lock_text = LuchaKit.fit_text(LOCK_TEXT, fw * 1.1, fh * 0.95, LuchaKit.RED, LuchaKit.INK)
		_lock_text.position = fc
		_lock.add_child(_lock_text)
	else:
		_lock = Node3D.new()
		_lock.position = LOCK_AT
		_lock.add_child(LuchaKit.box(Vector3(3.0, 0.5, 0.08), LuchaKit.GOLD_DARK, Vector3(0, 0, -0.02)))
		_lock.add_child(LuchaKit.box(Vector3(2.85, 0.38, 0.08), LuchaKit.GOLD, Vector3(0, 0, 0.02)))
		_lock_text = LuchaKit.fit_text(LOCK_TEXT, 2.7, 0.3, LuchaKit.RED, LuchaKit.INK)
		_lock_text.position = Vector3(0, 0, 0.075)
		_lock.add_child(_lock_text)
		add_child(_lock)
	_lock.visible = _toaster  # the toaster's tab hides in its slot; the stand-in hides


## Pop the toast up (above the line) or drop it back in the slot.
func _set_popped(up: bool) -> void:
	if up == popped:
		return
	popped = up
	if not _toaster:
		_lock.visible = up
		return
	if _pop_tween != null and _pop_tween.is_valid():
		_pop_tween.kill()
	_pop_tween = create_tween()
	if up:
		# Out fast, past the top (to about 0.34) and settle at 0.30: ease-out-back.
		_pop_tween.tween_property(_lock, "position:y", TAB_UP_Y, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		Sound.play("lock", -10.0, 1.8)  # a little spring ding
	else:
		_pop_tween.tween_property(_lock, "position:y", TAB_DOWN_Y, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func set_name_text(s: String) -> void:
	s = s.to_upper()
	if s == _name_shown:
		return
	_name_shown = s
	for ch in _name_node.get_children():
		ch.queue_free()
	# The face fits the longest made-up name (33 letters) at full size; longer ones
	# (Steam names) shrink to fit, never clipped; shorter ones grow, up to a cap.
	var t := LuchaKit.fit_text(s, _face_w, _face_h * 0.7, LuchaKit.RED, LuchaKit.INK)
	_name_node.add_child(t)
	LuchaUI.no_shadows(t)


# ---------------------------------------------------------------- the odometer

func _build_odometer() -> void:
	_odo = LuchaKit.kit_model("hud_odometer")
	var wheels: Array = []
	if _odo != null:
		# Godot's importer reads "_wheel" in a name as a car wheel: odo_wheel_0
		# arrives as a VehicleWheel3D called odo_0. Take that, or odo_drum_* / odo_wheel_*.
		for n in _odo.find_children("odo_*", "Node3D", true, false):
			var nm := String(n.name)
			if n is VehicleWheel3D or nm.begins_with("odo_drum_") or nm.begins_with("odo_wheel_"):
				wheels.append(n)
		wheels.sort_custom(func(a, b): return (a as Node3D).global_position.x < (b as Node3D).global_position.x if a.is_inside_tree() else (a as Node3D).position.x < (b as Node3D).position.x)
	if _odo != null and wheels.size() >= 4:
		_odo.scale = Vector3.ONE * ODO_SCALE
		_digit_colour = LuchaKit.CREAM  # the kit's drums are dark wood
	if _odo == null or wheels.size() < 4:
		_odo = _stand_in_odometer()
		wheels.clear()
		for n in _odo.find_children("odo_wheel_*", "Node3D", true, false):
			wheels.append(n)
	_odo.position = ODO_AT
	add_child(_odo)
	for w in wheels.slice(0, 4):
		_drums.append(_dress_drum(w as Node3D))


## A drum's digits: 0-9 round its rim, each facing out, the drum turning about X.
func _dress_drum(wheel: Node3D) -> Node3D:
	var r: float = wheel.get_meta("radius", 0.3)
	var width: float = wheel.get_meta("width", 0.4)
	var mi := wheel as MeshInstance3D
	if mi == null:
		for ch in wheel.get_children():
			if ch is MeshInstance3D:
				mi = ch
				break
	if mi != null and mi.mesh != null and not wheel.has_meta("radius"):
		var bb := mi.mesh.get_aabb()
		r = maxf(bb.size.y, bb.size.z) * 0.5
		width = bb.size.x
	var spin := Node3D.new()
	spin.name = "digits"
	wheel.add_child(spin)
	for k in 10:
		var a := -k * DIGIT_STEP  # the next digit waits below and rolls up, as on a real odometer
		var d := LuchaKit.text3d(str(k), minf(width * 0.75, r * 0.72), _digit_colour, 0.0, 2)
		d.position = Vector3(0, r * sin(a), r * cos(a)) * 1.02
		d.rotation.x = -a
		spin.add_child(d)
	return wheel


func _stand_in_odometer() -> Node3D:
	var root := Node3D.new()
	root.add_child(LuchaKit.box(Vector3(2.5, 0.95, 0.1), Color("#5A2E14"), Vector3(0, 0, -0.32)))
	root.add_child(LuchaKit.box(Vector3(2.62, 1.05, 0.06), LuchaKit.GOLD, Vector3(0, 0, -0.36)))
	for i in 4:
		# A plain holder (the drum turns about its X), the cylinder laid along X inside.
		var w := Node3D.new()
		w.name = "odo_wheel_%d" % (i + 1)
		w.position = Vector3((i - 1.5) * 0.56, 0, 0)
		w.set_meta("radius", 0.3)
		w.set_meta("width", 0.46)
		w.add_child(LuchaKit.cyl(0.3, 0.46, LuchaKit.CREAM, Vector3.ZERO, Vector3.RIGHT))
		root.add_child(w)
	# The decimal point between the units and the tenths.
	var dot := LuchaKit.ball(0.05, LuchaKit.RED, Vector3(0, -0.22, 0.32))
	dot.name = "odo_point"
	root.add_child(dot)
	var m := LuchaKit.fit_text("M", 0.3, 0.3, LuchaKit.GOLD, LuchaKit.INK)
	m.position = Vector3(1.45, -0.18, 0.05)
	root.add_child(m)
	return root


## Drum values (0..10, continuous) for a height: the right drum turns with the
## hundredths; each drum to its left steps on as the one beside it passes 9.
## PAST 100 m (Parker 11-08: "the '.' drop[s] and the meter counter keep[s] going
## at 100 with the decimal places being replaced"): the four drums read whole
## metres, 0100 to 9999, the right drum turning with the metres.
static func drum_values(h: float) -> Array:
	var x := clampf(h, 0.0, 99.99) * 100.0 if h < 100.0 else clampf(h, 100.0, 9999.0)
	var out: Array = [0.0, 0.0, 0.0, 0.0]
	out[3] = fmod(x, 10.0)
	var lower: float = out[3]
	for i in [2, 1, 0]:
		var place := pow(10.0, 3 - i)
		var v := fmod(floorf(x / place), 10.0) + clampf(lower - 9.0, 0.0, 1.0)
		out[i] = v
		lower = v
	return out


func set_height(h: float, delta: float) -> void:
	_shown_h = lerpf(_shown_h, h, 1.0 - exp(-delta * 10.0))
	if absf(_shown_h - h) < 0.0005:
		_shown_h = h
	var vals := drum_values(_shown_h)
	# The decimal point goes away once the drums read whole metres.
	if _odo_point == null and _odo != null:
		_odo_point = _odo.find_child("odo_point", true, false) as Node3D
	if _odo_point != null:
		_odo_point.visible = _shown_h < 100.0
	for i in _drums.size():
		var spin := (_drums[i] as Node3D).get_node("digits") as Node3D
		spin.rotation.x = -float(vals[i]) * DIGIT_STEP


# ---------------------------------------------------------------- the tick

## LuchaUI calls this every frame the HUD shows.
func tick(delta: float) -> void:
	var g: Game = main.game
	visible = g.phase in ["turn", "round", "between"]
	if not visible:
		return
	_to_corners()
	var me := g.me()
	var mine: Climber = null
	var climbing: Climber = null
	for c in g.live_climbers():
		var cl: Climber = c
		if climbing == null:
			climbing = cl
		if cl.owner_peer == me and (mine == null or cl.top_height() > mine.top_height()):
			mine = cl
	var who: Climber = climbing if g.mode.get("live", "turns") == "turns" else mine
	if who != null:
		set_name_text(who.display_name)
	elif g.mode.get("live", "turns") == "all":
		set_name_text("ROUND %d" % g.round_n)
	var h_src: Climber = who if who != null else mine
	if h_src != null:
		set_height(test_height if test_height >= 0.0 else maxf(0.0, h_src.top_height()), delta)
	var above := mine != null and mine.top_height() > g.line + Game.LOCK_MARGIN and mine.touches_solid()
	_set_popped(above)
	if above and not _toaster:
		_lock.scale = Vector3.ONE * (1.0 + 0.05 * sin(Time.get_ticks_msec() / 1000.0 * 8.0))
	if _gems != null and above != _gems_lit:
		_gems_lit = above
		var gm := _gems as MeshInstance3D
		if gm != null:
			gm.material_override = CelPass.cel_material(Color("#7CC83A") if above else Color("#D8262E"))


## A mesh's box in another node's space (both may be scaled kit pieces).
static func _local_aabb(mi: Node3D, space: Node3D) -> AABB:
	var vi := mi as VisualInstance3D
	var box := vi.get_aabb() if vi != null else AABB(Vector3(-0.5, -0.5, 0), Vector3(1, 1, 0.05))
	var xf := space.global_transform.affine_inverse() * mi.global_transform if mi.is_inside_tree() and space.is_inside_tree() else _rel(mi, space)
	return xf * box


static func _rel(n: Node3D, space: Node3D) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var p: Node = n
	while p != null and p != space:
		if p is Node3D:
			xf = (p as Node3D).transform * xf
		p = p.get_parent()
	return xf


func _to_corners() -> void:
	var vp := get_viewport()
	if vp == null:
		return
	var size := vp.get_visible_rect().size
	var half_w := HUD_HALF_H * size.x / maxf(size.y, 1.0)
	if _plate != null:
		_plate.position.x = -half_w + CORNER_MARGIN + PLATE_HALF_W
	if _odo != null:
		_odo.position.x = half_w - CORNER_MARGIN - ODO_HALF_W
	# The plate's bottom on the odometer's bottom AS THE CAMERA SEES THEM (Parker
	# 11-08). The odometer is a deep box, so its front edge is nearer the lens and
	# reads lower: match the two front-bottom edges' screen heights, not model y.
	if _plate != null and _odo != null and main != null and main.cam != null:
		var cam: Camera3D = main.cam
		var inv := cam.global_transform.affine_inverse()
		var ob := _bottom_front(_odo)
		var o := inv * (_odo.global_transform * Vector3(0.0, ob.x, ob.y))
		var pb := _bottom_front(_plate)
		var pp := inv * (_plate.global_transform * Vector3(0.0, pb.x, pb.y))
		if o.z < -0.01 and pp.z < -0.01:
			var target_y := o.y / -o.z * -pp.z  # the plate edge's cam-space y on the odometer's screen line
			var parent_scale := (_plate.get_parent() as Node3D).global_transform.basis.get_scale().y if _plate.get_parent() is Node3D else 1.0
			_plate.position.y += (target_y - pp.y) / maxf(parent_scale, 0.0001)


## The bottom-front edge of a model's meshes, local to it (before its own
## transform): Vector2(lowest y, front z).
static func _bottom_front(root: Node3D) -> Vector2:
	var low := INF
	var front := -INF
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.mesh == null or not m.visible:
			continue
		var xf := Transform3D.IDENTITY
		var cur: Node = m
		while cur != null and cur != root:
			if cur is Node3D:
				xf = (cur as Node3D).transform * xf
			cur = cur.get_parent()
		var bb: AABB = xf * m.mesh.get_aabb()
		low = minf(low, bb.position.y)
		front = maxf(front, bb.end.z)
	return Vector2(low if low < INF else 0.0, front if front > -INF else 0.0)
