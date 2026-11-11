class_name LuchaHudBottom
extends Node3D
## THE HUD'S BOTTOM (Parker 11-08): "Replace the bottom with a nice UI designer
## made nameplate of the current guy's name and make sure it is long enough to fit
## the longest names." (The height odometer that sat beside it is out of the game:
## Parker 11-10, "hud odometer is no longer in the game".)
##
## nameplate  on the kit's hud_nameplate (its nameplate_face), fitted for 33
##            letters: the climber's made-up name only (the climbing climber in
##            turns modes, your own in Classic). Its player's Steam name shows in
##            the HUD's top-left corner instead (steam_shown, Parker 11-10). Its
##            nameplate_lockin tab says LOCK IN! when your climber is above the
##            line, held a moment either way so it never flickers.
## A stand-in plate until the kit's part lands; it swaps in by name.

const PLATE_AT := Vector3(-1.4, -2.8, 0.0)  # HUD units (x UI_SCALE on screen)
## THE CORNER (Parker 11-08: "the new name plate in the bottom left of the screen"):
## each frame the plate's left edge sits CORNER_MARGIN in from the screen's edge, at
## any aspect. HUD_HALF_H: the HUD's visible half-height in HUD units.
const HUD_HALF_H := 3.8
const CORNER_MARGIN := 0.35
const PLATE_HALF_W := 2.96 * 0.5 * KIT_SCALE  # the kit plate's half-width in HUD units
const KIT_SCALE := 2.4  # the kit's plate (2.6 m face) at HUD size
const LOCK_AT := Vector3(-3.2, -2.05, 0.0)  # the LOCK IN tab, above the plate's left end
const LOCK_TEXT := "LOCK IN!"
## The Steam name of the nameplate's climber's player (online only, else ""), which
## LuchaUI shows in the top-left corner (Parker 11-10: "the name plate should now only
## have the built names and the name of the steam name should show in the upper left").
var steam_shown := ""
## THE STEADY TAB (Parker 11-09: the lock-in "was flashing oddly"): your climber must be
## above the line this long before the tab pops, and off it this long before it drops,
## so a hand flickering on and off a hold at the line doesn't flash it.
const LOCK_UP_S := 0.12
const LOCK_DOWN_S := 0.35
var _lock_hold := 0.0  # how long the raw lock-in state has disagreed with the tab
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


func _init(p_main: Node) -> void:
	main = p_main
	name = "HudBottom"


func _ready() -> void:
	_build_plate()
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
		# The capitals sat high in the toaster (Parker 11-10): centre them by the font's
		# letter height, not its line box.
		LuchaKit.center_digits(_lock_text)
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
	# Hidden while down (Parker 11-09: "when the toaster is not up, have it despawn, so
	# you can't see it when the object is transparent"): it shows only while popped.
	_lock.visible = false
	# While the plate fades (a climber behind it) it draws in the alpha pass, where pieces
	# sort by their centres: the gold body landed in front of the cream face and turned it
	# orange (Parker 11-09: "why the background keep turing orange"). The face, gems and
	# the tab's face always draw after the body they sit in.
	for g in _plate.find_children("*", "GeometryInstance3D", true, false):
		if not (g.name in ["hud_nameplate", "lockin_tab"]):
			(g as GeometryInstance3D).sorting_offset = 0.5


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
		_lock.visible = true
		# Out fast, past the top (to about 0.34) and settle at 0.30: ease-out-back.
		_pop_tween.tween_property(_lock, "position:y", TAB_UP_Y, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		Sound.play("lock", -10.0, 1.8)  # a little spring ding
	else:
		_pop_tween.tween_property(_lock, "position:y", TAB_DOWN_Y, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		_pop_tween.tween_callback(func() -> void: _lock.visible = false)  # gone once it's in the slot


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
	set_name_text(who.display_name if who != null else "")
	steam_shown = steam_name(who.owner_peer if who != null else g.me())
	var raw := mine != null and g.measure(mine) > g.line + Game.LOCK_MARGIN and mine.touches_solid()
	if raw == popped:
		_lock_hold = 0.0
	else:
		_lock_hold += delta
		if _lock_hold >= (LOCK_UP_S if raw else LOCK_DOWN_S):
			_lock_hold = 0.0
			_set_popped(raw)
	var above := popped
	if above and not _toaster:
		_lock.scale = Vector3.ONE * (1.0 + 0.05 * sin(Time.get_ticks_msec() / 1000.0 * 8.0))
	if _gems != null and above != _gems_lit:
		_gems_lit = above
		var gm := _gems as MeshInstance3D
		if gm != null:
			CelPass.paint(gm, Color("#7CC83A") if above else Color("#D8262E"))


## A machine's Steam name, from the lobby's member list: online only. Offline (practice,
## local play) there's none to show (Parker 11-09: practice cycled "part of the email
## address", the Windows user name the offline fallback used).
static func steam_name(peer: int) -> String:
	if Net.online and Net.members.has(peer):
		return str(Net.members[peer].get("name", ""))
	return ""


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
	# Keep the nameplate and its child lock-in tab low, with an eight-pixel
	# bottom margin at any resolution.
	if _plate != null and main != null and main.cam != null:
		var cam: Camera3D = main.cam
		var inv := cam.global_transform.affine_inverse()
		var pb := _bottom_front(_plate)
		var pp := inv * (_plate.global_transform * Vector3(0.0, pb.x, pb.y))
		if pp.z < -0.01:
			var target := inv * cam.project_position(Vector2(size.x * 0.5, size.y - 8.0), -pp.z)
			var parent_scale := (_plate.get_parent() as Node3D).global_transform.basis.get_scale().y
			_plate.position.y += (target.y - pp.y) / maxf(parent_scale, 0.0001)


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
