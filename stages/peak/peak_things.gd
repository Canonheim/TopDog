class_name PeakThings
extends RefCounted
## The Peak's moving things: movers (bodies on a clock or a trigger), physics ropes, free
## bodies, the things that fall on a timer, the holds with behaviours (crumble, let go,
## get wet, kick), and the ones who tried (frozen climbers). Data: docs/peak/AUTHORING.md.

const ClimberScript := preload("res://climber/climber.gd")
const Layout := preload("res://climber/body_layout.gd")
const SEG_R := 0.065
## Per half-metre segment. Three times what they were (Parker 11-12: "the ropes need to be
## about 3x heavier": holding one, a climber could haul it anywhere and nearly fly).
## THE ROPES SWING WITH YOU (playtest note 20, Parker 11-12: "Make it so you can swing back
## and forth on them better. Right now they like launch you up weird but you can't get a
## good swing on them"). A rope is a string of half-metre pieces. Each weighs a fraction
## of the climber (22 kg), falls at the climber's own slow gravity so the two swing as one
## pendulum, and is barely braked. The old rope outweighed its climber six to one, fell
## three and a half times as fast and lost a quarter of its speed every second. What
## keeps a climber from hauling a light rope about and flying (Parker, earlier on 11-12,
## which is why these were once tripled) is in the climber: Feel rope_pull, and a pull
## paid by its own hands (Climber._tick_joints). tests/peak_rope_bench.tscn has the numbers.
const ROPE_MASS := {"rope": 0.3, "chain": 0.5, "vine": 0.3, "cable": 0.5, "banner": 0.25, "thread": 0.5}
const PLANK_MASS := 7.2  # a bridge's planks are stood on, not swung on: as they were
const ROPE_DAMP := 0.03
const ROPE_SPIN_DAMP := 0.15
const ROPE_REACH := 0.17  # a free hand or foot this near a rope takes it
const ROPE_TONE := {"rope": "#C9A36A", "chain": "#B5532A", "vine": "#7FA04A", "cable": "#B9B2A6", "banner": "#C9A36A",
	"thread": "#C3A6EE"}  # (thread: the crystal cave's grown threads of lilac crystal, page 3.3; a chain's weight)
const BOARD_S := 0.7  # in the cart this long and it rolls
## joints in parent-before-child order, with every piece that hangs off each one
const POSE_TREE := [
	["neck", ["head"]],
	["spine_hi", ["navel", "pelvis", "leg_l_up", "leg_l_lo", "foot_l", "leg_r_up", "leg_r_lo", "foot_r"]],
	["spine_lo", ["pelvis", "leg_l_up", "leg_l_lo", "foot_l", "leg_r_up", "leg_r_lo", "foot_r"]],
	["shoulder_l", ["arm_l_up", "arm_l_lo", "hand_l"]], ["elbow_l", ["arm_l_lo", "hand_l"]], ["wrist_l", ["hand_l"]],
	["shoulder_r", ["arm_r_up", "arm_r_lo", "hand_r"]], ["elbow_r", ["arm_r_lo", "hand_r"]], ["wrist_r", ["hand_r"]],
	["hip_l", ["leg_l_up", "leg_l_lo", "foot_l"]], ["knee_l", ["leg_l_lo", "foot_l"]], ["ankle_l", ["foot_l"]],
	["hip_r", ["leg_r_up", "leg_r_lo", "foot_r"]], ["knee_r", ["leg_r_lo", "foot_r"]], ["ankle_r", ["foot_r"]],
]
## Statue poses: joint turns in degrees (counter-clockwise) from the T-pose (arms straight out).
const POSES := {
	"stand": {"shoulder_l": 80, "shoulder_r": -80},
	"reach": {"shoulder_l": -85, "shoulder_r": -70, "elbow_r": -20, "knee_l": 15, "hip_l": -10},
	"hang": {"shoulder_l": -88, "shoulder_r": 88},
	"sit": {"shoulder_l": 70, "shoulder_r": -70, "elbow_l": -30, "elbow_r": 30, "hip_l": 85, "hip_r": 85, "knee_l": -85, "knee_r": -85, "neck": -15},
	"star": {"shoulder_l": -35, "shoulder_r": 35, "hip_l": -38, "hip_r": 38},
	"cling": {"shoulder_l": -70, "shoulder_r": 60, "elbow_l": -35, "elbow_r": 50, "hip_l": -60, "knee_l": 95, "hip_r": 20},
	"fall": {"shoulder_l": -40, "shoulder_r": 115, "elbow_r": 40, "hip_l": -55, "knee_l": 70, "hip_r": 30, "knee_r": -40, "neck": 20},
	"bridge": {"shoulder_l": -88, "shoulder_r": 88, "hip_l": 0, "hip_r": 0},
}

var peak: Peak
var movers := {}  # id -> Dictionary
var ropes: Array = []
var _leaf_ok := true  # (the vine leaf's model is there; once missing, not looked for again)
var bodies := {}  # id -> {rb, last_angle, turned, area}
var holds: Array = []  # Dictionary per hold with a behaviour
var spawners: Array = []
var boards: Array = []  # the boards a rock fall leaves by: {def, area, pts, pivot, reach}
var statues: Array = []
var _anchors := {}  # area id -> StaticBody3D the joints tie to
var _rock := {}  # area id -> [[Rect2, outline], ...]: every solid of the area ("is this point inside rock?")
var _grip_on := {}  # limb index -> the timed hold it's on
var _grip_t := {}
var _grip_warned := {}
var _last_grab := {}  # limb index -> what it held last tick (new grabs: kicks, creaks)
var _ko_wait := 0.0


func _init(p: Peak) -> void:
	peak = p


# ================================================================ build

func build_area(a: Dictionary, root: Node3D) -> void:
	var anchor := StaticBody3D.new()
	anchor.collision_layer = 0
	anchor.collision_mask = 0
	root.add_child(anchor)
	Climber.sync_server(anchor)
	_anchors[a.id] = anchor
	var rock: Array = []
	for s in a.get("solids", []):
		if bool(s.get("ghost", false)):
			continue
		var outline: PackedVector2Array = peak._pts(s.pts)
		var box := Rect2(outline[0], Vector2.ZERO)
		for p in outline:
			box = box.expand(p)
		rock.append([box, outline])
	_rock[str(a.id)] = rock
	for m in a.get("movers", []):
		_build_mover(a, m, root)
	for b in a.get("bodies", []):
		_build_body(a, b, root)
	for r in a.get("ropes", []):
		_build_rope(a, r, root)
	for s in a.get("spawners", []):
		spawners.append({"def": s, "area": str(a.id), "root": root, "n": -1, "live": [], "warned": -1})
	for l in a.get("levers", []):
		_build_lever(a, l, root)
	for b in a.get("boards", []):
		_build_board(a, b, root)
	for s in a.get("statues", []):
		_build_statue(a, s, root)


func add_hold(body: CollisionObject3D, def: Dictionary, vis: Node3D, col: Color, slick: Color, a: Dictionary) -> void:
	var h := {"body": body, "def": def, "vis": vis, "col": col, "slick": slick, "area": str(a.id),
		"type": str(def.type), "break_at": -1.0, "back_at": -1.0, "wet": false, "layer": body.collision_layer}
	if body.has_meta("peak_cracks"):
		h["cracks"] = body.get_meta("peak_cracks")  # the cracks that spread once it is touched
	h["kind"] = str(body.get_meta("peak_kind", ""))
	body.set_meta("peak_hold", h)
	holds.append(h)


func _shapes_mesh(a: Dictionary, shapes: Array) -> MeshInstance3D:
	var mb := PeakMesh.new()
	var ms := {}  # slick kind -> PeakMesh
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for sh in shapes:
		var kind := str(sh.kind)
		var pts: PackedVector2Array = peak._pts(sh.pts)
		if not peak.kind_grips(kind):
			var cls := Peak.slick_class(kind)
			if not ms.has(cls):
				ms[cls] = PeakMesh.new()
			(ms[cls] as PeakMesh).prism(pts, -Peak.HALF * 0.85, Peak.HALF * 0.85, Vector2.ZERO, Vector2.ZERO)
			continue
		var c: Color = peak.kind_color(a, kind)
		mb.prism(pts, -Peak.HALF * 0.85, Peak.HALF * 0.85, AtlasPalette.matte_uv(c), AtlasPalette.matte_uv(peak.tone(a, "edge")))
		PeakDress.dress(mb, pts, Peak.HALF * 0.85 + 0.007, kind, c, rng)
	var mi := MeshInstance3D.new()
	if not mb.empty():
		mi.mesh = mb.commit()
		mi.material_override = CelPass.one()
	for cls: String in ms:
		var wet := MeshInstance3D.new()
		wet.mesh = (ms[cls] as PeakMesh).commit()
		wet.material_override = Peak.slick_material(cls)
		mi.add_child(wet)
	return mi


func _build_mover(a: Dictionary, def: Dictionary, root: Node3D) -> void:
	var home := Peak.v2(def.at)
	var grip_shapes: Array = []
	var slick_shapes: Array = []
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for sh in def.shapes:
		if peak.kind_grips(str(sh.kind)):
			grip_shapes.append(sh)
		else:
			slick_shapes.append(sh)
		for p in sh.pts:
			lo = lo.min(Peak.v2(p))
			hi = hi.max(Peak.v2(p))
	var nodes: Array = []
	for group in [grip_shapes, slick_shapes]:
		if group.is_empty():
			continue
		var ab := AnimatableBody3D.new()
		ab.sync_to_physics = false
		ab.collision_layer = Climber.LAYER_WORLD
		ab.collision_mask = 0
		var pm := PhysicsMaterial.new()
		pm.friction = 1.0 if group == grip_shapes else 0.02
		ab.physics_material_override = pm
		if group == slick_shapes:
			ab.set_meta("no_weld", true)
		for sh in group:
			peak._add_shapes(ab, peak._pts(sh.pts), -Peak.HALF, Peak.HALF)
		ab.position = Vector3(home.x, home.y, 0)
		root.add_child(ab)
		Climber.sync_server(ab)
		if def.has("tag"):
			ab.set_meta("peak_tag", str(def.tag))
			peak.zones.tag(str(def.tag), ab)
		nodes.append(ab)
	if nodes.is_empty():
		return
	var vis: Node3D = Peak.kit(str(def.model)) if def.has("model") else null
	if vis == null:
		vis = _shapes_mesh(a, def.shapes)
	elif def.has("model_scale"):
		vis.scale = Vector3.ONE * float(def.model_scale)
	elif bool(def.get("model_flip", false)):
		vis.scale.x = -1.0
	if def.has("model") and def.has("model_at"):
		# Where the model's own zero sits against the collision's (the ore bucket's is its
		# middle; its collision's is its floor).
		var off := Peak.v2(def.model_at)
		# (a third number sets the model back from the play plane: the mask's jaw stood a
		# metre in front of whoever rode it)
		vis.position = Vector3(off.x, off.y, float(def.model_at[2]) if (def.model_at as Array).size() > 2 else 0.0)
	(nodes[0] as Node3D).add_child(vis)
	if def.has("model") and def.has("drawn"):
		# WHAT CAN BE TOUCHED IS DRAWN (note 77): shapes the model lacks, as plain pieces.
		var extra: Array = []
		for k in def.drawn:
			if int(k) < (def.shapes as Array).size():
				extra.append(def.shapes[int(k)])
		if not extra.is_empty():
			(nodes[0] as Node3D).add_child(_shapes_mesh(a, extra))
	var mo: Dictionary = def.motion
	var m := {"id": str(def.id), "def": def, "area": str(a.id), "home": home, "nodes": nodes, "vis": vis, "mo": mo, "type": str(mo.type),
		"offset": Vector2.ZERO, "angle": 0.0, "lo": lo, "hi": hi, "run": false, "dist": 0.0, "v": 0.0, "arrived": -1.0,
		"board_t": 0.0, "tip_t": -1.0, "prog": 0.0, "prev": home, "speed": 0.0, "active": true}
	if def.has("string"):
		# A KITE'S STRING (a10_dress 6e): a dark thread from the kite's back to its reel behind, drawn
		# each frame as the kite flies; never solid.
		var cord := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.018
		cm.bottom_radius = 0.018
		cm.height = 1.0
		cm.radial_segments = 6
		cord.mesh = cm
		cord.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		CelPass.paint(cord, Color("#2A2622"))
		(nodes[0] as Node3D).get_parent().add_child(cord)
		strings.append([m, cord, Vector3(float(def.string[0]), float(def.string[1]), float(def.string[2]))])
	if m.type == "path":
		var pts := PackedVector2Array()
		for p in mo.pts:
			pts.append(Peak.v2(p))
		if str(mo.get("mode", "loop")) == "loop":
			pts.append(pts[0])
		var cum := PackedFloat32Array([0.0])
		for i in range(1, pts.size()):
			cum.append(cum[i - 1] + pts[i - 1].distance_to(pts[i]))
		m["pts"] = pts
		m["cum"] = cum
		if mo.has("hop"):
			# where on the road it leaves it: the path's point at the crest's x
			var hx := float((mo.hop as Dictionary).x)
			for i in pts.size():
				if absf(pts[i].x - hx) < 0.01:
					m["hop_d"] = cum[i]
	if def.has("hold"):
		add_hold(nodes[0], def.hold, vis, Color.WHITE, peak.tone(a, "slick"), a)
	if def.has("winch"):
		_build_winch(m, a)
	if (def.motion as Dictionary).has("chock"):
		_build_chock(m, def.motion.chock, root)
	movers[m.id] = m
	for node: Node in nodes:
		_mover_of[node.get_instance_id()] = m
	if def.has("walker") and m.type == "path":
		_build_walker(m)


func _build_body(a: Dictionary, def: Dictionary, root: Node3D) -> void:
	var at := Peak.v2(def.at)
	var rb := RigidBody3D.new()
	rb.mass = float(def.mass)
	rb.collision_layer = Climber.LAYER_WORLD
	rb.collision_mask = Climber.LAYER_WORLD
	rb.axis_lock_linear_z = true
	rb.axis_lock_angular_x = true
	rb.axis_lock_angular_y = true
	rb.angular_damp = float(def.get("damp", 0.4))
	rb.linear_damp = 0.1
	rb.can_sleep = false
	var grips := false
	for sh in def.shapes:
		peak._add_shapes(rb, peak._pts(sh.pts), -Peak.HALF * 0.8, Peak.HALF * 0.8)
		grips = grips or peak.kind_grips(str(sh.kind))
	if not grips:
		rb.set_meta("no_weld", true)
	rb.position = Vector3(at.x, at.y, 0)
	root.add_child(rb)
	Climber.sync_server(rb)
	var vis: Node3D = Peak.kit(str(def.model)) if def.has("model") else null
	if vis == null:
		vis = _shapes_mesh(a, def.shapes)
	rb.add_child(vis)
	if def.has("hinge"):
		var h := Peak.v2(def.hinge)
		var rid := PhysicsServer3D.joint_create()
		var anchor: StaticBody3D = _anchors[a.id]
		PhysicsServer3D.joint_make_hinge(rid, rb.get_rid(), Transform3D(Basis(), Vector3(h.x - at.x, h.y - at.y, 0)), anchor.get_rid(), Transform3D(Basis(), Vector3(h.x, h.y, 0)))
		if def.has("limits"):
			Climber.set_hinge_limits(rid, float(def.limits[0]), float(def.limits[1]))
		rb.set_meta("peak_joint", rid)
	if def.has("tag"):
		rb.set_meta("peak_tag", str(def.tag))
		peak.zones.tag(str(def.tag), rb)
	bodies[str(def.id)] = {"rb": rb, "last": 0.0, "turned": 0.0, "area": str(a.id), "home": rb.transform}


## A ROPE OF LAID HEMP (a rope's `look: "hemp"`; the reviewer's q28, La Cortina's rope read as a thin pole): each piece a
## round strand 11 cm across in the held honey, three darker twist bands slanting round it (one every 17 cm on a
## 0.5 m piece), and at its foot a whipping of twine and a short frayed tuft. The drawing only: the piece's body,
## its length and its grip are a rope's as ever.
const HEMP := Color("#C9903F")
const HEMP_TWIST := Color("#AB7221")  # (30 levels under the strand: #8C5F27 read as a hazard stripe at true size, q29)


func _hemp_piece(mi: MeshInstance3D, rb: RigidBody3D, seg_len: float, last: bool) -> void:
	var cm := CylinderMesh.new()
	cm.top_radius = 0.055
	cm.bottom_radius = 0.055
	cm.height = seg_len + 0.02
	cm.radial_segments = 10
	cm.rings = 1
	mi.mesh = cm
	CelPass.paint(mi, HEMP)
	for k in 3:
		var band := MeshInstance3D.new()
		var bm := CylinderMesh.new()
		bm.top_radius = 0.06
		bm.bottom_radius = 0.06
		bm.height = 0.025
		bm.radial_segments = 10
		bm.rings = 1
		band.mesh = bm
		band.position = Vector3(0, -seg_len * 0.5 + (k + 0.5) * seg_len / 3.0, 0)
		band.rotation.z = 0.38  # (slanted: the lay's spiral, seen from the front)
		CelPass.paint(band, HEMP_TWIST)
		rb.add_child(band)
	if last:
		var whip := MeshInstance3D.new()
		var wm := CylinderMesh.new()
		wm.top_radius = 0.062
		wm.bottom_radius = 0.062
		wm.height = 0.07
		wm.radial_segments = 10
		wm.rings = 1
		whip.mesh = wm
		whip.position = Vector3(0, -seg_len * 0.5 + 0.09, 0)
		CelPass.paint(whip, HEMP_TWIST)
		rb.add_child(whip)
		for f: float in [-0.5, -0.2, 0.15, 0.45]:
			var strand := LuchaKit.box(Vector3(0.018, 0.13, 0.018), HEMP, Vector3.ZERO)
			strand.rotation.z = f
			strand.position = Vector3(sin(f) * 0.06, -seg_len * 0.5 - 0.055, 0)
			rb.add_child(strand)


func _build_rope(a: Dictionary, def: Dictionary, root: Node3D) -> void:
	var top := Peak.v2(def.at)
	var kind := str(def.kind)
	var seg := float(def.seg)
	var length := float(def.len)
	var both := def.has("to")
	var end := Peak.v2(def.to) if both else top + Vector2(0, -length)
	var n := maxi(2, int(ceil(length * (float(def.get("slack", 1.0)) if both else 1.0) / seg)))
	var planks := both and int(def.get("planks", 0)) > 0
	var col := Color(str(ROPE_TONE.get(kind, "#C9A36A")))
	if kind == "vine":
		col = peak.tone(a, "root")
	var segs: Array = []
	var prev: PhysicsBody3D = _anchors[a.id]
	var prev_local := Vector3(top.x, top.y, 0)
	if def.has("anchor") and movers.has(str(def.anchor)):
		var mv: Dictionary = movers[str(def.anchor)]
		prev = mv.nodes[0]
		prev_local = Vector3(top.x - (mv.home as Vector2).x, top.y - (mv.home as Vector2).y, 0)
	var joints: Array = []
	var dir := (end - top).normalized() if both else Vector2(0, -1)
	var step := (end - top) / float(n) if both else Vector2(0, -seg)
	var seg_len := step.length()
	for i in n:
		var rb := RigidBody3D.new()
		rb.mass = PLANK_MASS if planks else float(ROPE_MASS.get(kind, 0.3))
		rb.collision_layer = Climber.LAYER_WORLD
		rb.collision_mask = 0
		rb.axis_lock_linear_z = true
		rb.axis_lock_angular_x = true
		rb.axis_lock_angular_y = true
		rb.linear_damp = 0.25 if planks else ROPE_DAMP
		rb.angular_damp = 1.2 if planks else ROPE_SPIN_DAMP
		if not planks:
			rb.gravity_scale = Feel.climber_gravity(true)
		rb.can_sleep = false
		var cs := CollisionShape3D.new()
		var mi := MeshInstance3D.new()
		var plank_vis: Node3D = null
		if planks:
			var bx := BoxShape3D.new()
			bx.size = Vector3(0.12, maxf(0.1, seg_len - 0.06), 1.0)
			cs.shape = bx
			# A bridge's planks can wear a model (page 4.8: shelf-fungus treads), its length
			# along the rope: the model's own x is laid along the plank's y.
			plank_vis = Peak.kit(str(def.plank_model)) if def.has("plank_model") else null
			if plank_vis != null:
				plank_vis.rotation.z = PI * 0.5
			else:
				var bm := BoxMesh.new()
				bm.size = Vector3(0.1, maxf(0.1, seg_len - 0.08), 0.9)
				mi.mesh = bm
				CelPass.paint(mi, Color("#B07A32"))
		else:
			var cap := CapsuleShape3D.new()
			cap.radius = SEG_R
			cap.height = seg_len + SEG_R * 2.0
			cs.shape = cap
			if str(def.get("look", "")) == "hemp":
				_hemp_piece(mi, rb, seg_len, i == n - 1)
			else:
				var bm := BoxMesh.new()
				var wide := 0.085 if kind != "chain" else (0.11 if i % 2 == 0 else 0.07)
				bm.size = Vector3(wide, seg_len + 0.02, wide)
				mi.mesh = bm
				CelPass.paint(mi, col)
			if def.has("ladder"):
				# A HANGING HALF OF A ROPE BRIDGE (page 7.4): two side ropes 0.3 m apart as the camera
				# sees them, a honey board across every piece but the missing ones (plain boards
				# until riscos_bridge_half lands)
				var lw := float(def.ladder.get("w", 0.3))
				mi.visible = false
				for sx in [-lw * 0.5, lw * 0.5]:
					rb.add_child(LuchaKit.box(Vector3(0.06, seg_len + 0.02, 0.06), col, Vector3(sx, 0.0, 0.0)))
				if not (def.ladder.get("missing", []) as Array).has(i):
					rb.add_child(LuchaKit.box(Vector3(lw + 0.08, 0.07, 0.3), Color("#C89048"), Vector3(0.0, 0.0, 0.0)))
		rb.add_child(cs)
		rb.add_child(plank_vis if plank_vis != null else mi)
		if planks and bool(def.get("cords", false)):
			# the bridge's two white mycelium cords, along every tread (page 4.8)
			for zc in [-0.36, 0.36]:
				var cord := LuchaKit.box(Vector3(0.07, seg_len + 0.04, 0.07), Color("#F0ECE2"), Vector3(0.0, 0.0, zc))
				rb.add_child(cord)
		if kind == "vine" and not planks:
			if i % 2 == 1 and _leaf_ok:
				# a vine hangs leaves (a4_dress item 8), turned to either side by turns
				var leaf: Node3D = Peak.kit("vine_leaf")
				if leaf == null:
					_leaf_ok = false
				else:
					leaf.scale = Vector3.ONE * 0.5
					leaf.rotation.z = 0.5 if i % 4 == 1 else -0.5
					leaf.position.z = 0.06
					rb.add_child(leaf)
			if def.has("gold_end") and (n - i) * seg_len <= float(def.gold_end) + 0.01:
				CelPass.paint(mi, Color("#E8C25A"))  # (furred gold with spores, the lift's vines' last metre)
		if kind == "banner" and i % 2 == 1:
			var flag := LuchaKit.papel_flag([Color("#E0287A"), Color("#1FB8AE"), Color("#F28A1E"), Color("#7CC83A"), Color("#8A3FC0"), Color("#FFC928")][i / 2 % 6], i / 2)
			flag.scale = Vector3.ONE * 0.8
			flag.rotation.z = PI * 0.5 if both else 0.0
			rb.add_child(flag)
		var c := top + step * (float(i) + 0.5)
		# The segment's long axis is its own y: hang it along the rope.
		rb.transform = Transform3D(Basis(Vector3.BACK, dir.angle() + PI * 0.5), Vector3(c.x, c.y, 0))
		rb.set_meta("peak_rope", true)
		if not both:
			rb.set_meta("peak_swing", [segs[0] if i > 0 else rb, seg_len * 0.5])
		root.add_child(rb)
		Climber.sync_server(rb)
		var j := PhysicsServer3D.joint_create()
		PhysicsServer3D.joint_make_pin(j, prev.get_rid(), prev_local, rb.get_rid(), Vector3(0, seg_len * 0.5, 0))
		joints.append(j)
		prev = rb
		prev_local = Vector3(0, -seg_len * 0.5, 0)
		segs.append(rb)
	var bob: RigidBody3D = null
	if both:
		var j := PhysicsServer3D.joint_create()
		var anchor: StaticBody3D = _anchors[a.id]
		PhysicsServer3D.joint_make_pin(j, prev.get_rid(), prev_local, anchor.get_rid(), Vector3(end.x, end.y, 0))
		joints.append(j)
	elif def.has("bob"):
		var bd: Dictionary = def.bob
		var w := float(bd.w)
		var h := float(bd.h)
		bob = RigidBody3D.new()
		bob.mass = float(bd.get("mass", 12.0))
		bob.collision_layer = Climber.LAYER_WORLD
		bob.collision_mask = 0
		bob.axis_lock_linear_z = true
		bob.axis_lock_angular_x = true
		bob.axis_lock_angular_y = true
		bob.linear_damp = ROPE_DAMP
		bob.angular_damp = 1.0
		bob.gravity_scale = Feel.climber_gravity(true)
		bob.set_meta("peak_swing", [segs[0], seg_len * 0.5])
		bob.can_sleep = false
		var cs := CollisionShape3D.new()
		var bx := BoxShape3D.new()
		bx.size = Vector3(w, h, Peak.HALF * 1.4)
		cs.shape = bx
		bob.add_child(cs)
		var bkind := str(bd.get("kind", "iron"))
		var vis: Node3D = Peak.kit(str(bd.model)) if bd.has("model") else null
		if vis == null:
			vis = LuchaKit.box(Vector3(w, h, Peak.HALF * 1.2), peak.kind_color(a, bkind))
		else:
			vis.position.y = h * 0.5  # (a hung model's origin is its hanging point)
			if bd.has("model_scale"):
				vis.scale = Vector3.ONE * float(bd.model_scale)
		bob.add_child(vis)
		if not peak.kind_grips(bkind):
			bob.set_meta("no_weld", true)
		var bc := top + Vector2(0, -(seg_len * n + h * 0.5))
		bob.position = Vector3(bc.x, bc.y, 0)
		root.add_child(bob)
		Climber.sync_server(bob)
		var j := PhysicsServer3D.joint_create()
		PhysicsServer3D.joint_make_pin(j, prev.get_rid(), prev_local, bob.get_rid(), Vector3(0, h * 0.5, 0))
		joints.append(j)
	ropes.append({"id": str(def.id), "segs": segs, "bob": bob, "joints": joints, "area": str(a.id), "kind": kind, "creak": 0.0,
		"planks": planks, "seg_len": seg_len, "top": top, "reach": length + 2.0,
		"bell": str(def.get("bell", "")), "bell_mover": str(def.get("bell_mover", "")), "root": root, "wide": float(def.get("wide", 0.0))})


## One of the ones who tried: a climber built, posed by joint turns from the T-pose, and frozen.
func _build_statue(a: Dictionary, def: Dictionary, root: Node3D) -> void:
	var c: Climber = ClimberScript.new()
	c.climber_id = 9000 + statues.size()
	c.display_name = ""
	root.add_child(c)
	var at := peak.world_of(Peak.v2(def.at))
	c.build(at, root, Game.KNIGHT if peak.game == null or peak.game.dress else null)
	var s := c.body_scale
	var angles: Dictionary = POSES.get(str(def.pose), POSES.stand)
	var flip := bool(def.get("flip", false))
	var xf := {}
	for pname in Layout.ORDER:
		xf[pname] = Transform2D.IDENTITY
	for row in POSE_TREE:
		var jn: String = row[0]
		var src := jn
		if flip:  # mirror the pose: the other side's turn, the other way
			src = jn.replace("_l", "_#").replace("_r", "_l").replace("_#", "_r")
		var deg := float(angles.get(src, 0.0)) * (-1.0 if flip else 1.0)
		if deg == 0.0:
			continue
		var jd: Dictionary = Layout.JOINTS[jn]
		var anchor: Vector2 = (xf[jd.a] as Transform2D) * (((jd.at as Vector2) + Layout.shift(jn)) * s)
		var th := deg_to_rad(deg)
		var turn := Transform2D(th, anchor - anchor.rotated(th))
		for piece in row[1]:
			xf[piece] = turn * (xf[piece] as Transform2D)
	# The whole body turned about the pelvis, and the pelvis put on the point.
	var pelvis_rest: Vector2 = c._piece_rest_centre("pelvis")
	var pelvis_now: Vector2 = (xf["pelvis"] as Transform2D) * pelvis_rest
	var rot := deg_to_rad(float(def.get("rot", 0.0)))
	var world := Transform2D(rot, at - pelvis_now.rotated(rot))
	var pose := PackedFloat32Array()
	for pname in Layout.ORDER:
		var t: Transform2D = world * (xf[pname] as Transform2D)
		var p: Vector2 = t * c._piece_rest_centre(pname)
		pose.append(p.x)
		pose.append(p.y)
		pose.append(t.get_rotation())
	c.apply_pose(pose)
	c.freeze()
	statues.append(c)


# ================================================================ the player

func on_player(c: Climber) -> void:
	_grip_on.clear()
	_grip_t.clear()
	_last_grab.clear()
	# NOTHING COLLIDES WITH A ROPE (Parker 11-12: "You should not have collision with ropes,
	# only sticky hands and feet should grab them"): every piece passes through it, and a
	# free hand or foot that comes within reach takes hold (_tick_rope_grabs). A bridge's
	# planks are the exception: feet stand on those.
	for r in ropes:
		for seg: RigidBody3D in r.segs:
			for pname in c.bodies:
				if not bool(r.planks) or not Climber._is_end(pname):
					seg.add_collision_exception_with(c.bodies[pname])


func set_area_active(area: String, on: bool) -> void:
	for r in ropes:
		if r.area == area:
			for seg: RigidBody3D in r.segs:
				seg.freeze = not on
			if r.bob != null:
				(r.bob as RigidBody3D).freeze = not on
	for id in bodies:
		if bodies[id].area == area:
			(bodies[id].rb as RigidBody3D).freeze = not on
	for id in movers:
		if movers[id].area == area:
			movers[id].active = on
			if movers[id].get("loose") != null:
				(movers[id].loose as RigidBody3D).freeze = not on


func sleep_all() -> void:
	for sp in spawners:
		for row in sp.live:
			if is_instance_valid(row[0]):
				(row[0] as Node).queue_free()
		sp.live.clear()


# ================================================================ tick

var _rope_g := -1.0


func tick(delta: float) -> void:
	_ko_wait = maxf(0.0, _ko_wait - delta)
	var rope_g := Feel.climber_gravity(true)
	if not is_equal_approx(rope_g, _rope_g):
		_rope_g = rope_g  # (the F1 panel changed the climber's gravity: the ropes follow)
		for r in ropes:
			if bool(r.planks):
				continue
			for seg: RigidBody3D in r.segs:
				seg.gravity_scale = rope_g
			if r.bob != null:
				(r.bob as RigidBody3D).gravity_scale = rope_g
	for id in bodies:
		var b: Dictionary = bodies[id]
		var ang := (b.rb as RigidBody3D).rotation.z
		b.turned = absf(angle_difference(float(b.last), ang))
		b.last = ang
	for id in movers:
		var m: Dictionary = movers[id]
		if m.active:
			_tick_mover(m, delta)
	_tick_rope_grabs()
	_tick_bells(delta)
	_tick_levers(delta)
	_tick_winches()
	_tick_strain(delta)
	_tick_crunch(delta)
	_tick_holds(delta)
	_tick_burns()
	_tick_strays()
	_tick_debris()
	_tick_spawners(delta)
	_tick_wettings()


func frame(delta: float) -> void:
	_fly_thrown(delta)
	_fly_kicked(delta)
	_frame_glyphs()
	_frame_followers()
	_frame_strings()


## The kites' strings: [mover, its cord, its reel].
var strings: Array = []


func _frame_strings() -> void:
	for row in strings:
		var cord: MeshInstance3D = row[1]
		if not is_instance_valid(cord):
			continue
		var at := _mover_at(row[0])
		var a := Vector3(at.x, at.y, -0.3)  # (the kite's back)
		var b: Vector3 = row[2]
		var d := b - a
		var ln := d.length()
		if ln < 0.01:
			continue
		var up := d / ln
		var side := up.cross(Vector3.FORWARD if absf(up.z) < 0.9 else Vector3.RIGHT).normalized()
		cord.transform = Transform3D(Basis(side, up, side.cross(up)).scaled(Vector3(1.0, ln, 1.0)), (a + b) * 0.5)


## DECOS THAT MOVE WITH A MOVER (a1_dress item 9, a2_dress item 8: the water wheels turn
## with the wheels you ride, the pulley with the lift, each gate's leaf with its ram):
## [node, {mover, how, r}, its own position, its own turn].
var followers: Array = []


func _frame_followers() -> void:
	for f in followers:
		var n: Node3D = f[0]
		if not is_instance_valid(n):
			continue
		var how: Dictionary = f[1]
		if str(how.how) == "mallet":
			# THE DRUM'S MALLET (page 5.9): it lifts before each count of the bar and strikes on it,
			# hardest on the first. period = the bar, count = a count, lift = the first's lift (rad).
			var per := float(how.get("period", 5.0))
			var cnt := float(how.get("count", 1.25))
			var t := fmod(peak.clock, per)
			var k := int(t / cnt)
			var to_next := cnt - fmod(t, cnt)
			var next_k := (k + 1) % int(round(per / cnt))
			var amp := float(how.get("lift", 0.8)) * (1.0 if next_k == 0 else 0.5)
			var up := clampf((0.45 - to_next) / 0.45, 0.0, 1.0) if to_next < 0.45 else 0.0
			n.rotation.z = float(f[3]) + amp * up
			continue
		var m: Dictionary = movers.get(str(how.mover), {})
		if m.is_empty():
			continue
		var off: Vector2 = m.get("offset", Vector2.ZERO)
		var sc := float(how.get("scale", 1.0))
		match str(how.how):
			"spin":
				n.rotation.z = float(f[3]) + float(m.get("angle", 0.0))
			"ride":
				n.position = (f[2] as Vector3) + Vector3(off.x, off.y, 0.0) * sc
			"roll":
				n.rotation.z = float(f[3]) - (off.x + off.y) / maxf(0.05, float(how.r))
			"tip":
				# a balance beam over two linked pans: its east end `rise` above its west at rest,
				# the mover's pan going down by off.y and the other coming up by as much
				n.rotation.z = atan2(float(how.get("rise", 0.0)) + 2.0 * off.y * sc, maxf(0.1, float(how.get("span", 1.0))))
			"hang":
				# a chain from a fixed top down to a weight that rides: it stretches as the weight drops
				var ln := maxf(0.1, float(how.get("len", 1.0)))
				var d := -off.y * sc
				n.position = (f[2] as Vector3) + Vector3(0.0, -d * 0.5, 0.0)
				n.scale.y = maxf(0.05, float(f[4]) * (ln + d) / ln)


## A LEVER A HAND TAKES AND DRAWS OVER (playtest note 72, Parker 11-13: "make it so you
## have to pull the lever to start the cart, regardless of if you are in the cart. If you
## pull the lever it goes. It controls like the chair whaere you are hlding the activated
## limb"). It is taken as the arena's chair is: by the limb whose button is DOWN, when that
## hand or foot comes to its grip, and it is kept for as long as the button is held. While
## it is held it follows the hand round its pivot, between its two notches. Drawn all the
## way it drops into the second notch with a clunk and starts its mover, and stays there
## until the mover is home again. Let go short of that and it springs back. It stands
## behind the climb and is never solid: nothing sticks to it and nothing is stopped by it.
## (Note 25's winch will want the same taking and keeping.)
const LEVER_TAKE := 0.3  # m: a held hand this near the grip takes it
const LEVER_LOSE := 0.8  # m: further than this from the grip, it is let go of
const LEVER_FOLLOW := 26.0  # 1/s: how closely it follows the hand
const LEVER_SPRING := 12.0  # 1/s: how fast it springs back
const LEVER_CHOCK_M := 0.42  # m: how far the rod draws the chock out, the lever fully over
var levers: Array = []


func _build_lever(a: Dictionary, def: Dictionary, root: Node3D) -> void:
	var at := Peak.v2(def.at)
	var length := float(def.len)
	var z := float(def.get("z", -0.45))
	var base: Node3D = Peak.kit(str(def.get("base", "")))
	if base == null:
		# (a stand-in until the Kit's quadrant lands: a plain block where the pivot is)
		base = LuchaKit.box(Vector3(0.6, 0.3, 0.22), Color("#3A3F4A"))
		base.position.y = 0.15
	var base_at := Node3D.new()
	base_at.position = Vector3(at.x, at.y, z)
	base_at.add_child(base)
	root.add_child(base_at)
	# THE ROD AND THE CHOCK (the Kit's base carries them as its own object): the rod runs
	# from the lever to a chock under the cart's near wheel. Drawing the lever over draws
	# the chock out from under the wheel, and it goes back with the lever.
	var rod := base.find_child("stn_lever_rod", true, false) as Node3D
	var turn := Node3D.new()  # the arm turns about the pivot
	turn.position = Vector3(at.x, at.y, z)
	var arm: Node3D = Peak.kit(str(def.get("arm", "")))
	if arm == null:
		# (a stand-in until the Kit's arm lands: an iron bar with a red grip on its top)
		arm = Node3D.new()
		var bar := LuchaKit.box(Vector3(0.09, length, 0.09), Color("#6A7078"))
		bar.position.y = length * 0.5
		arm.add_child(bar)
		var grip := LuchaKit.box(Vector3(0.14, float(def.get("grip", 0.4)), 0.14), Color("#C8322E"))
		grip.position.y = length - float(def.get("grip", 0.4)) * 0.5
		arm.add_child(grip)
	turn.add_child(arm)
	root.add_child(turn)
	var rest := deg_to_rad(float(def.get("rest", 12.0)))
	turn.rotation.z = rest
	levers.append({"id": str(def.id), "area": str(a.id), "at": at, "len": length, "grip": float(def.get("grip", 0.4)),
		"rest": rest, "pull": deg_to_rad(float(def.get("pull", -12.0))), "ang": rest, "starts": str(def.get("starts", "")),
		"limb": -1, "thrown": false, "turn": turn, "rod": rod, "rod_x": rod.position.x if rod != null else 0.0})


## Where a lever's handle is (the middle of its grip), in the course's metres.
func lever_handle(lv: Dictionary) -> Vector2:
	var r := float(lv.len) - float(lv.grip) * 0.5
	return (lv.at as Vector2) + Vector2(-sin(float(lv.ang)), cos(float(lv.ang))) * r


func _tick_levers(delta: float) -> void:
	var c := peak.player
	for lv: Dictionary in levers:
		if not bool(peak._area_active.get(lv.area, true)):
			continue
		var m: Dictionary = movers.get(lv.starts, {})
		var rest := float(lv.rest)
		var pull := float(lv.pull)
		var held := -1
		if c != null and c.state == Climber.State.LIVE and c.knockout_left <= 0.0:
			held = c.active_limb()
		var want := rest
		if bool(lv.thrown):
			# In its second notch until what it started is home again.
			want = pull
			lv.limb = -1
			if m.is_empty() or (not bool(m.run) and float(m.arrived) < 0.0 and float(m.dist) <= 0.0 and not bool(m.get("pulled", false))):
				lv.thrown = false
				peak.audio.play("lever_clunk", lever_handle(lv), -5.0)
		else:
			var handle := lever_handle(lv)
			if int(lv.limb) >= 0 and (held != int(lv.limb) or peak.local_of(c.limb_end(held)).distance_to(handle) > LEVER_LOSE):
				lv.limb = -1  # the button came up, or the hand left it: it springs back
			if int(lv.limb) < 0 and held >= 0:
				# along the grip: its top `grip` metres
				var dir := Vector2(-sin(float(lv.ang)), cos(float(lv.ang)))
				var h := peak.local_of(c.limb_end(held))
				var along := clampf((h - (lv.at as Vector2)).dot(dir), float(lv.len) - float(lv.grip), float(lv.len))
				if h.distance_to((lv.at as Vector2) + dir * along) <= LEVER_TAKE:
					lv.limb = held
					Sound.play_at("grip", Vector3(c.limb_end(held).x, c.limb_end(held).y, 0), -2.0)
			if int(lv.limb) >= 0:
				var h2 := peak.local_of(c.limb_end(int(lv.limb))) - (lv.at as Vector2)
				want = clampf(atan2(-h2.x, h2.y), minf(rest, pull), maxf(rest, pull))
		var rate := LEVER_FOLLOW if int(lv.limb) >= 0 else LEVER_SPRING
		lv.ang = lerp_angle(float(lv.ang), want, 1.0 - exp(-delta * rate))
		if not bool(lv.thrown) and int(lv.limb) >= 0 and absf(float(lv.ang) - pull) < 0.025:
			# all the way: into the second notch
			lv.ang = pull
			lv.thrown = true
			lv.limb = -1
			peak.audio.play("lever_clunk", lever_handle(lv), 0.0)
			if not m.is_empty():
				m["pulled"] = true
		(lv.turn as Node3D).rotation.z = float(lv.ang)
		if lv.rod != null and not is_equal_approx(rest, pull):
			(lv.rod as Node3D).position.x = float(lv.rod_x) + LEVER_CHOCK_M * clampf((rest - float(lv.ang)) / (rest - pull), 0.0, 1.0)


## THE WINCH THAT RIDES ITS LIFT (playtest note 25; Parker 11-13: "stand in the elevator and
## spin the winch"; "it connects to the hand like the chair does"). The handle is taken by
## the limb whose button is held, when that hand comes within LEVER_TAKE of it, and kept
## while the button is held and the hand stays near; while it is held the crank follows the
## hand round its hub, and every bit it turns (either way) winds the lift up. Nothing to
## weld: the hand steers, the crank follows. A plain stand-in (a hub, an arm, a red grip)
## until its model lands.
func _build_winch(m: Dictionary, _a: Dictionary) -> void:
	var w: Dictionary = (m.def as Dictionary).winch
	var r := float(w.get("r", 0.35))
	var at := Peak.v2(w.at)
	var hub := Node3D.new()
	hub.position = Vector3(at.x, at.y, -0.15)
	var drum := LuchaKit.cyl(0.16, 0.3, Color("#4A4F58"), Vector3.ZERO, Vector3.BACK)
	hub.add_child(drum)
	var arm := Node3D.new()
	var bar := LuchaKit.box(Vector3(r, 0.07, 0.07), Color("#6A7078"))
	bar.position = Vector3(r * 0.5, 0, 0.12)
	arm.add_child(bar)
	var grip := LuchaKit.cyl(0.06, 0.32, Color("#C8322E"), Vector3(r, 0, 0.22), Vector3.BACK)
	arm.add_child(grip)
	hub.add_child(arm)
	(m.nodes[0] as Node3D).add_child(hub)
	m["w_arm"] = arm
	m["w_ang"] = 0.0
	m["w_limb"] = -1
	m["w_turned"] = 0.0


## Where a winch's hub and handle are, in the course's metres.
func winch_hub(m: Dictionary) -> Vector2:
	return (m.home as Vector2) + (m.offset as Vector2) + Peak.v2((m.def as Dictionary).winch.at)


func winch_handle(m: Dictionary) -> Vector2:
	var r := float((m.def as Dictionary).winch.get("r", 0.35))
	return winch_hub(m) + Vector2(cos(float(m.w_ang)), sin(float(m.w_ang))) * r


func _tick_winches() -> void:
	var c := peak.player
	for m: Dictionary in movers.values():
		if not m.has("w_arm") or not bool(m.active):
			continue
		var held := -1
		if c != null and c.state == Climber.State.LIVE and c.knockout_left <= 0.0:
			held = c.active_limb()
		var limb := int(m.w_limb)
		if limb >= 0 and (held != limb or peak.local_of(c.limb_end(limb)).distance_to(winch_handle(m)) > LEVER_LOSE):
			m.w_limb = -1
			limb = -1
		if limb < 0 and held >= 0 and peak.local_of(c.limb_end(held)).distance_to(winch_handle(m)) <= LEVER_TAKE:
			m.w_limb = held
			limb = held
			Sound.play_at("grip", Vector3(c.limb_end(held).x, c.limb_end(held).y, 0), -2.0)
		if limb >= 0:
			var h := peak.local_of(c.limb_end(limb)) - winch_hub(m)
			if h.length() > 0.05:
				var want := atan2(h.y, h.x)
				var d := angle_difference(float(m.w_ang), want)
				m.w_ang = want
				m.w_turned = float(m.w_turned) + absf(d)
				# the pawl clicks every quarter turn
				m["w_click"] = float(m.get("w_click", 0.0)) + absf(d)
				if float(m.w_click) > PI * 0.5:
					m.w_click = 0.0
					peak.audio.play("lever_clunk", winch_hub(m), -14.0, 1.6)
		(m.w_arm as Node3D).rotation.z = float(m.w_ang)


## THE DYNAMITE RUNG (playtest note 58; Parker 11-13: "make the second one from the top a
## stick of dynamite and explode if you hold it, it's fuse lights and it fuckin blows up").
## A hold of type "dynamite": touched, its fuse burns `fuse` s (a spark running along it, the
## stick shaking), and letting go does not stop it. Then it blows: smoke, flying sparks and
## dust, a flash, a bang and a jolt of the camera; everything of the climber within
## BLAST_R is thrown away from it, and the climber is knocked out if any part of it is within
## BLAST_KO (holding it, certainly). The stick is gone, and a fresh one is there `respawn` s
## later. A plain red stand-in (a stick, a fuse) until its model lands.
const BLAST_R := 2.6
const BLAST_KO := 1.3
const BLAST_V := 7.0  # m/s at the middle, falling to 0 at BLAST_R


func _build_dynamite(h: Dictionary) -> void:
	var body: Node3D = h.body
	var mid := _hold_middle(body)
	var stick := Node3D.new()
	stick.position = Vector3(mid.x, mid.y, 0.0)
	var made: Node3D = Peak.kit("forja_dynamite_stick")  # (its model, when it lands: a6_dress item 8)
	if made != null:
		stick.add_child(made)
	else:
		stick.add_child(LuchaKit.cyl(0.13, 0.82, Color("#C8322E"), Vector3.ZERO, Vector3.RIGHT))
		for e in [-0.25, 0.25]:
			stick.add_child(LuchaKit.cyl(0.135, 0.06, Color("#2E2A2C"), Vector3(e, 0, 0), Vector3.RIGHT))  # its paper bands
		var fuse := LuchaKit.box(Vector3(0.3, 0.03, 0.03), Color("#3A2E26"), Vector3(0.52, 0.08, 0.0))
		fuse.rotation.z = 0.6
		stick.add_child(fuse)
	body.add_child(stick)
	(h.vis as Node3D).visible = false
	h["stick"] = stick
	h["mid"] = mid


func _tick_dynamite(h: Dictionary, t: float) -> void:
	if not h.has("stick"):
		_build_dynamite(h)
	var body: CollisionObject3D = h.body
	var stick: Node3D = h.stick
	var mid: Vector2 = h.mid
	var def: Dictionary = h.def
	var lit := float(h.get("lit_at", -1.0))
	if float(h.get("back_at", -1.0)) >= 0.0:
		if t >= float(h.back_at):
			h.back_at = -1.0
			body.collision_layer = int(h.layer)
			stick.visible = true
			stick.scale = Vector3.ONE * 0.05
			stick.create_tween().tween_property(stick, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		return
	if lit < 0.0:
		return
	var fuse := float(def.get("fuse", 1.0))
	var f := clampf((t - lit) / maxf(fuse, 0.05), 0.0, 1.0)
	stick.position = Vector3(mid.x + randf_range(-1.0, 1.0) * 0.04 * f, mid.y + randf_range(-1.0, 1.0) * 0.04 * f, 0.0)
	if t >= float(h.get("spark_at", 0.0)):
		h["spark_at"] = t + 0.05
		peak.zones.burst(mid + Vector2(0.62 - 0.4 * f, 0.22 - 0.12 * f), "sparks", 0.35)
	if f < 1.0:
		return
	# it blows
	h["lit_at"] = -1.0
	h["back_at"] = t + float(def.get("respawn", 10.0))
	_release_from([body])
	body.collision_layer = 0
	stick.visible = false
	stick.position = Vector3(mid.x, mid.y, 0.0)
	for k in ["smoke", "dust", "sparks", "sparks"]:
		peak.zones.burst(mid, k, 2.6)
	peak.zones.flash = maxf(peak.zones.flash, 0.7)
	peak.cam_kick = 0.6
	peak.audio.play("rock_crumble", mid, 6.0, 0.7)
	peak.audio.play("cart_crash", mid, 6.0, 0.6)
	var c := peak.player
	if c == null or c.state != Climber.State.LIVE:
		return
	var nearest := INF
	for b: RigidBody3D in c.bodies.values():
		nearest = minf(nearest, peak.local_of(Climber.pos2(b)).distance_to(mid))
	# The whole climber is thrown one way, away from the stick through its middle (thrown
	# part by part, the parts either side of the stick cancelled each other out).
	if nearest < BLAST_R:
		var com := peak.local_of(c.centre_of_mass())
		var away := (com - mid).normalized() if com.distance_to(mid) > 0.05 else Vector2.UP
		var push := Vector3(away.x, away.y + 0.35, 0.0).normalized() * BLAST_V * (1.0 - nearest / BLAST_R)
		for b: RigidBody3D in c.bodies.values():
			b.linear_velocity += push
	if nearest < BLAST_KO and c.knockout_left <= 0.0:
		_ko_wait = 2.5
		c.knock_out()
		peak.audio.play("knock_out_bonk", mid, 3.0)
	blasts += 1


var blasts := 0  # (for the probes: how many sticks have blown)


## A GRIP BREAKS BEFORE THE BODY DOES (Parker 11-12: "a certain amount of force should
## break your welds ... if I grip a moving thing, it pulls me and stretches me across the
## map instead of me losing my grip on something"). When the climber's joints are pulled
## open, a grip lets go. THE MOVING THING WINS: the grip that goes is the one on whatever
## is moving least (the dock you stand on when you take a gondola's rail, the wall your
## hand brushes while you ride a lift), so you go with the ride. Stretched only by its
## own swinging on fixed holds, nothing breaks: that's the climber's own doing.
const STRAIN_GAP := 0.07  # joints open this far (m) for STRAIN_S, or STRAIN_SNAP at once
const STRAIN_SNAP := 0.12
const STRAIN_S := 0.05
var _strain_t := 0.0


func _tick_strain(delta: float) -> void:
	var c := peak.player
	if c == null or c.state != Climber.State.LIVE:
		return
	var slowest := -1
	var slowest_v := INF
	var fastest_v := 0.0
	var stuck := 0
	var vs: Array = []
	for i in c.limbs.size():
		if c.limbs[i].grab_other == null:
			continue
		stuck += 1
		var vv: Vector3 = (c.bodies[c.limbs[i].def.end] as RigidBody3D).linear_velocity
		var v := vv.length()
		vs.append(vv)
		fastest_v = maxf(fastest_v, v)
		if v < slowest_v:
			slowest_v = v
			slowest = i
	# (How differently the grips move: two things going opposite ways at one speed differ
	# as much as one moving and one still. Speeds alone called that "no strain" (note 83).)
	var apart := 0.0
	for x in vs.size():
		for y in range(x + 1, vs.size()):
			apart = maxf(apart, ((vs[x] as Vector3) - (vs[y] as Vector3)).length())
	if stuck < 2 or fastest_v < 0.4 or apart < 0.3:
		_strain_t = 0.0
		return
	var gap := c.worst_joint_gap()
	if gap < STRAIN_GAP:
		_strain_t = 0.0
		return
	_strain_t += delta
	if gap < STRAIN_SNAP and _strain_t < STRAIN_S:
		return
	_strain_t = 0.0
	# HELD BETWEEN TWO MOVING THINGS (playtest note 83; Parker 11-13: "when 2 things are
	# grabbed and moving, the one higher up should have priority, or the one you have more
	# limbs connected to"; settled: "More limbs first"). The limbs are sorted by what they
	# hold. When two or more of those things are moving, the one that loses is the one with
	# FEWER of your limbs on it, and on a tie the LOWER one; every limb on it lets go
	# together. With only one thing moving, the moving thing wins as before (below).
	var things := _held_things(c)
	var moving: Array = []
	for th: Dictionary in things.values():
		if float(th.v) >= STRAIN_MOVING:
			moving.append(th)
	if moving.size() >= 2:
		var lose: Dictionary = {}
		for th: Dictionary in moving:
			if lose.is_empty() or (th.limbs as Array).size() < (lose.limbs as Array).size() \
					or ((th.limbs as Array).size() == (lose.limbs as Array).size() and float(th.y) < float(lose.y)):
				lose = th
		var first: int = (lose.limbs as Array)[0]
		var at0 := peak.local_of(c.limb_end(first))
		last_strain = ["two moving", lose.limbs.duplicate(), things.values().map(func(th): return [th.limbs, snappedf(float(th.v), 0.01), snappedf(float(th.y), 0.01)])]
		for i: int in lose.limbs:
			c.release(i)
			c.limbs[i].regrip = 0.5
		Sound.play_at("grip", Vector3(c.limb_end(first).x, c.limb_end(first).y, 0), -2.0)
		peak.audio.play("rope_creak", at0, -6.0)
		return
	var at := peak.local_of(c.limb_end(slowest))
	last_strain = ["slowest", [slowest], things.values().map(func(th): return [th.limbs, snappedf(float(th.v), 0.01), snappedf(float(th.y), 0.01)])]
	c.release(slowest)
	c.limbs[slowest].regrip = 0.5
	Sound.play_at("grip", Vector3(c.limb_end(slowest).x, c.limb_end(slowest).y, 0), -2.0)
	peak.audio.play("rope_creak", at, -6.0)


const STRAIN_MOVING := 0.4  # m/s: a held thing moving at least this fast counts as moving
var last_strain: Array = []  # (for the batteries: what the strain rule last did and why)


## What the climber's limbs hold, thing by thing: a mover is one thing however many bodies
## it is made of; anything else is itself. {key: {"limbs": [limb indices], "v": how fast
## the thing itself moves (m/s; a mover by its own speed and turn, a loose body by its
## velocity, anything fixed 0: the hands on it lag behind it, so they don't say), "y": how
## high the held points are (the mean)}}.
func _held_things(c: Climber) -> Dictionary:
	var out := {}
	for i in c.limbs.size():
		var o = c.limbs[i].grab_other
		if o == null or not is_instance_valid(o):
			continue
		var m = _mover_of.get((o as Object).get_instance_id())
		var key: String = ("m:" + str(m.id)) if m != null else ("b:%d" % (o as Object).get_instance_id())
		if not out.has(key):
			out[key] = {"limbs": [], "v": 0.0, "y": 0.0}
		var end: RigidBody3D = c.bodies[c.limbs[i].def.end]
		(out[key].limbs as Array).append(i)
		var v := 0.0
		if m != null:
			var r := Vector2(end.global_position.x, end.global_position.y).distance_to(Vector2((o as Node3D).global_position.x, (o as Node3D).global_position.y))
			v = float(m.get("speed", 0.0)) + float(m.get("spin", 0.0)) * r
		elif o is RigidBody3D:
			v = Vector2((o as RigidBody3D).linear_velocity.x, (o as RigidBody3D).linear_velocity.y).length()
		out[key].v = maxf(float(out[key].v), v)
		out[key].y = float(out[key].y) + end.global_position.y
	for th: Dictionary in out.values():
		th.y = float(th.y) / float((th.limbs as Array).size())
	return out


## A CRUNCH KNOCKS YOU OUT (playtest notes 49 and 78; Parker 11-13, of the temple's gears:
## "Make them knock you out if you get crunched by them"; of El Pilon's sheave: "Make it
## knock you out if you get crunched"; settled: "Head or body only"). When the head, the
## chest or the hips are caught between a moving piece and anything solid (or between two
## moving pieces) with no room left, you are knocked out, with the stars and the sound, and
## you drop. A trapped hand or foot slips free as before. One rule for gears, sheaves,
## pistons and counterweights: a small ball inside each of the three parts (well inside
## its own shape) must be touched by both, for CRUNCH_S. Resting against a wall while a
## piece carries you past it does not do it: the wall has to be inside you.
const CRUNCH_PARTS := ["head", "chest", "pelvis"]
const CRUNCH_IN := 0.62  # the ball's size against the part's own (a circle's radius, a box's shorter half)
const CRUNCH_S := 0.08  # s: held so long
const CRUNCH_MOVING := 0.15  # m/s or rad/s: a piece moving this much is moving
var _crunch_t := 0.0
var _crunch_q: PhysicsShapeQueryParameters3D = null
var _mover_of := {}  # a mover's body (instance id) -> the mover


func _mover_moving(m: Dictionary) -> bool:
	return float(m.get("speed", 0.0)) > CRUNCH_MOVING or float(m.get("spin", 0.0)) > CRUNCH_MOVING


func _tick_crunch(delta: float) -> void:
	var c := peak.player
	if c == null or c.state != Climber.State.LIVE or c.knockout_left > 0.0 or _ko_wait > 0.0:
		_crunch_t = 0.0
		return
	if _crunch_q == null:
		_crunch_q = PhysicsShapeQueryParameters3D.new()
		_crunch_q.shape = SphereShape3D.new()
		_crunch_q.collision_mask = Climber.LAYER_WORLD
	var space := peak.get_world_3d().direct_space_state
	var geo: Dictionary = c.get("_shape_geo")
	var caught := ""
	for pname: String in CRUNCH_PARTS:
		var b: RigidBody3D = c.bodies.get(pname)
		if b == null or not geo.has(pname):
			continue
		var g: Array = geo[pname]
		var r := 0.1
		match str(g[0]):
			"circle":
				r = float(g[1])
			"box":
				r = minf((g[1] as Vector2).x, (g[1] as Vector2).y)
			"capsule":
				r = float(g[3])
		(_crunch_q.shape as SphereShape3D).radius = maxf(0.03, r * CRUNCH_IN)
		_crunch_q.transform = Transform3D(Basis(), b.global_position)
		var moving := {}
		var still := 0
		for hit: Dictionary in space.intersect_shape(_crunch_q, 8):
			var o: Object = hit.get("collider")
			if o == null or (o as Node).has_meta("peak_rope") or (o as Node).has_meta("peak_swing"):
				continue
			var m = _mover_of.get(o.get_instance_id())
			if m != null and (m as Dictionary).has("walk"):
				continue  # (the cave's beetle throws you; he never crushes you: note 120)
			if m != null and _mover_moving(m):
				moving[str(m.id)] = true
			else:
				still += 1
		if moving.size() >= 2 or (moving.size() >= 1 and still >= 1):
			caught = pname
			break
	if caught == "":
		_crunch_t = 0.0
		return
	_crunch_t += delta
	if _crunch_t < CRUNCH_S:
		return
	_crunch_t = 0.0
	_ko_wait = 2.5
	var at := peak.local_of(Climber.pos2(c.bodies[caught]))
	c.knock_out()
	peak.audio.play("knock_out_bonk", at, 3.0)
	peak.audio.play("rock_hit", at, 0.0, 0.8)
	peak.zones.burst(at, "dust", 0.8)
	crunches += 1


var crunches := 0  # (for the batteries: how many crunches have knocked the climber out)


## THE HAND TELLS YOU (playtest notes 84 and 95). Parker 11-13, of the timed ice: "make the
## glyph shiver harder until you loose grip". The button mark on a limb that holds timed
## ice shivers, harder as its seconds run out, until the hand lets go, and a little while
## that hand cannot grip again. The same mark buzzes while a limb is on metal that the
## lightning is about to take (`buzz`, set by the zones during the hum).
const SHIVER_MIN := 0.006  # m: the mark's shake as the hand takes the ice
const SHIVER_MAX := 0.05  # m: as the seconds run out
const SHIVER_AFTER := 0.008  # m: while the frozen hand can't grip again
const BUZZ := 0.03  # m: on metal during the hum
var buzz := {}  # limb index -> true while that limb is on metal under the hum
var _shivered := {}  # limb index -> true while its mark is shaken
var _cold_after := {}  # limb index -> until when it shivers after letting go of ice


func _frame_glyphs() -> void:
	var c := peak.player
	if c == null:
		return
	var glyphs: Array = c.get("_glyphs")
	if glyphs == null:
		return
	var t := peak.clock
	for i in mini(glyphs.size(), c.limbs.size()):
		var g = glyphs[i]
		if not is_instance_valid(g):
			continue
		var amp := 0.0
		var fast := false
		var o = c.limbs[i].grab_other
		if o != null and is_instance_valid(o) and (o as Node).has_meta("peak_hold") and _grip_on.get(i) == o:
			var h: Dictionary = (o as Node).get_meta("peak_hold")
			var limit := float((h.def as Dictionary).get("t", 0.0))
			if str(h.type) == "timed" and limit >= 1.8:
				var used := clampf(float(_grip_t.get(i, 0.0)) / maxf(limit, 0.05), 0.0, 1.0)
				amp = lerpf(SHIVER_MIN, SHIVER_MAX, used * used)
				_cold_after[i] = t + float((h.def as Dictionary).get("rearm", 0.6)) + 0.05
		elif t < float(_cold_after.get(i, -1.0)) and o == null:
			amp = SHIVER_AFTER
		if bool(buzz.get(i, false)):
			amp = maxf(amp, BUZZ)
			fast = true
		if amp > 0.0:
			var k := randf_range(0.6, 1.0) if fast else 1.0
			(g as Node3D).position = Vector3(randf_range(-amp, amp) * k, randf_range(-amp, amp) * k, 0.3)
			_shivered[i] = true
		elif bool(_shivered.get(i, false)):
			(g as Node3D).position = Vector3(0.0, 0.0, 0.3)
			_shivered[i] = false


## A free hand or foot (not held, holding nothing, past its regrip wait) within reach of
## a rope takes it, as it would stick to anything it touched.
func _tick_rope_grabs() -> void:
	var c := peak.player
	if c == null or c.state != Climber.State.LIVE or c.knockout_left > 0.0 or c.sinking:
		return
	var com := peak.local_of(c.centre_of_mass())
	for i in c.limbs.size():
		var l: Dictionary = c.limbs[i]
		if bool(l.held) or l.grab_other != null or float(l.regrip) > 0.0:
			continue
		var end: RigidBody3D = c.bodies[l.def.end]
		var p := Vector2(end.global_position.x, end.global_position.y)
		var best: RigidBody3D = null
		var best_d := ROPE_REACH
		var best_reach := ROPE_REACH
		for r in ropes:
			if bool(r.planks) or not bool(peak._area_active.get(r.area, true)):
				continue
			if com.distance_to(r.top) > float(r.reach) + 30.0:
				continue  # (a rope on a mover wanders: a wide net, then the real test)
			var half: float = float(r.seg_len) * 0.5
			for seg: RigidBody3D in r.segs:
				var sp := Vector2(seg.global_position.x, seg.global_position.y)
				if absf(sp.x - p.x) > half + 0.3 or absf(sp.y - p.y) > half + 0.3:
					continue
				var axis := Vector2(seg.global_basis.y.x, seg.global_basis.y.y)
				var along := clampf((p - sp).dot(axis), -half, half)
				# (a rope that is a whole hanging half, two side ropes 0.3 m apart edge-on, is taken
				# anywhere across that width: note 66)
				var d := p.distance_to(sp + axis * along) - float(r.get("wide", 0.0)) * 0.5
				if d < best_d:
					best_d = d
					best = seg
		if best != null:
			c.attach(i, best)
			peak.audio.play("rope_creak", peak.local_of(p), -4.0)


## THE BELL RINGS (playtest note 100; Parker 11-13: "make it so you can actually ring the bell
## when you are dangling on the rope", "like the dangle part needs to move not be static").
## A rope whose def names a `bell` deco swings that bell on its hanging point, and a clapper
## (a plain stand-in rod and ball until the bell's model has one) under it. The bell follows
## the rope's swing at BELL_FOLLOW of its angle on a soft spring, so it lags and rocks to
## rest; the clapper follows the rope itself on a quicker one, and where it meets the bell's
## side (BELL_GAP apart) it strikes and the bell tolls, louder the harder. A climber's weight
## coming onto the rope tips the bell and tolls it at once, loudest for a fast catch (the
## last leap's). The three tolls at the belt stay the finish (peak_audio.gd).
const BELL_FOLLOW := 0.7
const BELL_MOST := 0.5  # rad the bell is led to at most (29 degrees)
const BELL_STOP := 0.6  # rad it can ever tip (34 degrees: its yoke stops it)
const BELL_K := 10.0  # the bell's spring (1/s2) and its damping (1/s)
const BELL_DAMP := 3.0
const CLAP_K := 45.0
const CLAP_DAMP := 4.0
const BELL_GAP := 0.1  # rad between clapper and bell where the clapper meets its side
const TOLL_HIT := 0.5  # rad/s of meeting below which the clapper only touches
## A 10 m rope swings slowly (7 s a swing at the climber's gravity), too slowly for the
## clapper to lag on its own: at each turn of a swing at least SWING_TOLL each side, the
## clapper is thrown on the way it was going, and strikes.
const SWING_TOLL := 0.09  # rad (5 degrees)


func _tick_bells(delta: float) -> void:
	for r in ropes:
		if str(r.get("bell", "")) == "" or not bool(peak._area_active.get(r.area, true)):
			continue
		if not r.has("bell_node") or not is_instance_valid(r.bell_node):
			_find_bell(r)
			if r.bell_node == null:
				continue
		var bell: Node3D = r.bell_node
		var clap: Node3D = r.clapper
		var end: RigidBody3D = r.bob if r.bob != null else (r.segs as Array).back()
		var v := peak.local_of(Climber.pos2(end)) - (r.top as Vector2)
		var swing := atan2(v.x, -v.y) if v.length() > 0.3 else 0.0
		var b_ang := float(r.b_ang)
		var c_ang := float(r.c_ang)
		var b_w := float(r.b_w)
		var c_w := float(r.c_w)
		# a climber's weight coming onto the rope
		var nodes: Array = (r.segs as Array) + ([r.bob] if r.bob != null else [])
		var on := _player_limbs_on(nodes)
		if on and not bool(r.was_on):
			var hit := 0.0  # (the climber's fastest part, m/s: a leap's catch is fast)
			for pb: RigidBody3D in peak.player.bodies.values():
				hit = maxf(hit, pb.linear_velocity.length())
			var push := signf(v.x) if absf(v.x) > 0.05 else (1.0 if end.linear_velocity.x >= 0.0 else -1.0)
			b_w += push * clampf(0.6 + hit * 0.15, 0.6, 1.6)
			c_w += push * clampf(1.5 + hit * 0.4, 1.5, 4.0)
			_toll(r, clampf(-4.0 + hit * 1.5, -4.0, 4.0))
		r.was_on = on
		# the turn of a swing throws the clapper on
		var sw_v := (swing - float(r.prev_swing)) / maxf(delta, 0.001)
		r.prev_swing = swing
		if absf(sw_v) > 0.02:
			var dir := signf(sw_v)
			if dir != float(r.sw_dir):
				var amp := absf(swing - float(r.extreme)) * 0.5
				if float(r.sw_dir) != 0.0 and amp > SWING_TOLL:
					c_w += float(r.sw_dir) * clampf(2.0 + amp * 8.0, 2.0, 6.0)
				r.extreme = swing
				r.sw_dir = dir
		b_w += (BELL_K * (clampf(swing * BELL_FOLLOW, -BELL_MOST, BELL_MOST) - b_ang) - BELL_DAMP * b_w) * delta
		b_ang += b_w * delta
		if absf(b_ang) > BELL_STOP:
			b_ang = BELL_STOP * signf(b_ang)
			b_w = 0.0
		c_w += (CLAP_K * (clampf(swing, -0.9, 0.9) - c_ang) - CLAP_DAMP * c_w) * delta
		c_ang += c_w * delta
		var rel := c_ang - b_ang
		if absf(rel) > BELL_GAP:
			var meet := (c_w - b_w) * signf(rel)
			c_ang = b_ang + BELL_GAP * signf(rel)
			if meet > 0.0:
				if meet > TOLL_HIT and peak.clock >= float(r.next_toll):
					_toll(r, clampf(-14.0 + meet * 5.0, -14.0, 0.0))
				b_w += meet * 0.15 * signf(rel)
				c_w = b_w - meet * 0.35 * signf(rel)
		r.b_ang = b_ang
		r.c_ang = c_ang
		r.b_w = b_w
		r.c_w = c_w
		if r.has("bell_m"):
			(r.bell_m as Dictionary).angle = b_ang  # (a solid bell: its mover turns, and whoever is on it with it)
		else:
			bell.rotation.z = b_ang
		clap.rotation.z = c_ang


func _toll(r: Dictionary, db: float) -> void:
	r.next_toll = peak.clock + 0.35
	r.tolls = int(r.get("tolls", 0)) + 1
	var at := peak.local_of(Climber.pos2(r.bell_node))
	peak.audio.play("summit_bell", at, db)
	bell_tolls += 1


var bell_tolls := 0  # (for the probes: how many times a rope has rung its bell)


func _find_bell(r: Dictionary) -> void:
	r["bell_node"] = null
	var root: Node3D = r.root
	if not is_instance_valid(root):
		return
	var bell: Node3D = null
	var drop := 1.2
	if str(r.get("bell_mover", "")) != "" and movers.has(str(r.bell_mover)):
		# A SOLID BELL (note 100): a mover on its pin, turned by the swing (a11_dress 6b).
		var m: Dictionary = movers[str(r.bell_mover)]
		bell = m.nodes[0]
		r["bell_m"] = m
		drop = 2.5
	else:
		for n in root.get_children():
			if n is Node3D and str((n as Node).get_meta("deco", "")) == str(r.bell):
				bell = n
				break
		if bell != null:
			var box := Peak._model_box(bell)
			drop = maxf(0.6, (box.size.y if box.size.y > 0.05 else 1.2) * bell.scale.y)
	if bell == null:
		return
	# The clapper: hung from the bell's hanging point, down to a hand's breadth under its lip (its own
	# model, `cumbre_bell_clapper`, origin the pin, once it lands).
	var clap := Node3D.new()
	clap.name = "clapper"
	clap.position = Vector3(bell.position.x, bell.position.y, 0.0)
	var made: Node3D = Peak.kit("cumbre_bell_clapper")
	if made != null:
		clap.add_child(made)
	else:
		var iron := Color("#3A3532")
		clap.add_child(LuchaKit.cyl(0.05, drop, iron, Vector3(0, -drop * 0.5, 0.0)))
		clap.add_child(LuchaKit.ball(0.17, iron, Vector3(0, -drop - 0.1, 0.0)))
	bell.get_parent().add_child(clap)
	r["bell_node"] = bell
	r["clapper"] = clap
	r["b_ang"] = 0.0
	r["c_ang"] = 0.0
	r["b_w"] = 0.0
	r["c_w"] = 0.0
	r["was_on"] = false
	r["next_toll"] = 0.0
	r["prev_swing"] = 0.0
	r["sw_dir"] = 0.0
	r["extreme"] = 0.0


func _player_limbs_on(nodes: Array) -> bool:
	var c := peak.player
	if c == null:
		return false
	for l in c.limbs:
		if l.grab_other != null and nodes.has(l.grab_other):
			return true
	return false


func _player_aboard(m: Dictionary) -> bool:
	var c := peak.player
	if c == null:
		return false
	var pelvis: RigidBody3D = c.bodies.get("pelvis")
	if pelvis == null:
		return false
	var p := peak.local_of(Climber.pos2(pelvis)) - ((m.home as Vector2) + (m.offset as Vector2))
	p = p.rotated(-float(m.angle))
	return p.x > (m.lo as Vector2).x and p.x < (m.hi as Vector2).x and p.y > (m.lo as Vector2).y - 0.2 and p.y < (m.hi as Vector2).y + 1.3


func _release_from(nodes: Array) -> void:
	var c := peak.player
	if c == null:
		return
	for i in c.limbs.size():
		if c.limbs[i].grab_other != null and nodes.has(c.limbs[i].grab_other):
			c.release(i)
			c.limbs[i].regrip = 0.3


static func _ease(f: float) -> float:
	return f * f * (3.0 - 2.0 * f)


func _along(m: Dictionary, d: float) -> Array:
	var pts: PackedVector2Array = m.pts
	var cum: PackedFloat32Array = m.cum
	d = clampf(d, 0.0, cum[cum.size() - 1])
	var i := 1
	while i < cum.size() - 1 and cum[i] < d:
		i += 1
	var span := cum[i] - cum[i - 1]
	var f := (d - cum[i - 1]) / span if span > 0.0001 else 0.0
	return [pts[i - 1].lerp(pts[i], f), (pts[i] - pts[i - 1]).normalized()]


## A path mover's speed at `d` along its road, from its `speeds` (one per point), in a line
## between the points either side.
func _speed_along(m: Dictionary, mo: Dictionary, d: float) -> float:
	var cum: PackedFloat32Array = m.cum
	var sp: Array = mo.speeds
	d = clampf(d, 0.0, cum[cum.size() - 1])
	var i := 1
	while i < cum.size() - 1 and cum[i] < d:
		i += 1
	var span := cum[i] - cum[i - 1]
	var f := (d - cum[i - 1]) / span if span > 0.0001 else 0.0
	return lerpf(float(sp[mini(i - 1, sp.size() - 1)]), float(sp[mini(i, sp.size() - 1)]), f)


func _tick_mover(m: Dictionary, delta: float) -> void:
	var mo: Dictionary = m.mo
	var t := peak.clock
	var jumped := false
	if m.get("loose") != null:
		_tick_loose(m)
		return
	match str(m.type):
		"path":
			var total: float = (m.cum as PackedFloat32Array)[(m.cum as PackedFloat32Array).size() - 1]
			var speed := maxf(0.05, float(mo.get("speed", 2.0)))
			var mode := str(mo.get("mode", "loop"))
			var wait := float(mo.get("wait", 0.0))
			var tt := t + float(mo.get("phase", 0.0))
			var d := 0.0
			match mode:
				"loop":
					d = fposmod(tt * speed, total)
				"wrap":
					var was: float = m.dist
					d = fposmod(tt * speed, total + wait * speed)
					jumped = d < was - 1.0
					m.vis.visible = d <= total
					d = minf(d, total)
					if mo.has("loose"):
						# IT GOES OVER THE END FOR REAL (Parker 11-12, the pool's barrels: "the
						# barrels should fall not despawn on screen"). Past `loose` metres the
						# piece on the line is gone and a loose body with its look has taken
						# its place, with whoever was on it (see _let_stray).
						var gone := d >= float(mo.loose)
						if gone and not bool(m.get("shed", false)) and not jumped:
							_let_stray(m, d)
						m["shed"] = gone
						m.vis.visible = not gone
					if mo.has("emerge"):
						# IT ARRIVES, IT DOESN'T APPEAR ("they should come out of some modeled
						# cove"): over its first metres it floats forward out of the back
						# wall, and can't be touched until it is in the play plane. With
						# `back` it slides back in over its last metres too (note 74's spikes).
						var em: Dictionary = mo.emerge
						var gone := d
						if bool(em.get("back", false)):
							gone = minf(d, total - d)
						var f := clampf(gone / maxf(0.1, float(em.over)), 0.0, 1.0)
						m["zoff"] = float(em.depth) * (1.0 - _ease(f))
					if mo.has("blink"):
						# IN AND OUT ON ITS WAY (note 34; Parker 11-13: "harder"): on its own
						# clock along the line (seconds since it set out), it shakes for `warn`
						# then goes in for `in` of every `period`, under your hand or not.
						var bl: Dictionary = mo.blink
						var per := maxf(0.5, float(bl.period))
						var cyc := fposmod(d / speed + float(bl.get("phase", 0.0)), per)
						var tin := float(bl.get("in", 1.5))
						var vis_n: Node3D = m.vis
						if cyc >= per - tin:
							m["zoff"] = minf(float(m.get("zoff", 0.0)), float((mo.get("emerge", {}) as Dictionary).get("depth", -1.2)))
							vis_n.position = Vector3.ZERO
						elif cyc >= per - tin - float(bl.get("warn", 0.5)):
							vis_n.position = Vector3(randf_range(-0.04, 0.04), randf_range(-0.04, 0.04), 0.0)
						else:
							vis_n.position = Vector3.ZERO
					var solid := not bool(m.get("shed", false)) and absf(float(m.get("zoff", 0.0))) < 0.45
					if not solid and bool(m.get("was_solid", true)):
						_release_from(m.nodes)  # (it went in under the hand)
					m["was_solid"] = solid
					for node: AnimatableBody3D in m.nodes:
						node.collision_layer = Climber.LAYER_WORLD if solid else 0
				"pingpong":
					var leg := total / speed
					var cyc := fposmod(tt, 2.0 * (leg + wait))
					if cyc < leg:
						d = cyc * speed
					elif cyc < leg + wait:
						d = total
					elif cyc < 2.0 * leg + wait:
						d = total - (cyc - leg - wait) * speed
					else:
						d = 0.0
					if bool(mo.get("ease", true)) and wait > 0.0:
						d = _ease(d / total) * total
				"once":
					var trig := str(mo.get("trigger", "board"))
					if not m.run and float(m.arrived) < 0.0:
						var go := false
						if trig == "grab":
							go = _player_limbs_on(m.nodes)
						elif trig == "lever":
							go = bool(m.get("pulled", false))  # (only its lever starts it: _tick_levers)
							m["pulled"] = false
						else:
							m.board_t = float(m.board_t) + delta if _player_aboard(m) else 0.0
							go = float(m.board_t) >= BOARD_S or (_player_limbs_on(m.nodes) and bool(mo.get("grab_starts", false)))
						if go:
							m.run = true
							m.v = 0.0
							peak.audio.play("cart_start" if m.id.begins_with("cart") else "zip_whirr", _mover_at(m))
							_kick_chock(m)
					if m.run and m.has("fly"):
						# in the air over the broken rail (note 73): no road under it
						if _tick_hop(m, mo, delta):
							return
					elif m.run:
						var acc := float(mo.get("accel", 0.0))
						m.v = speed if acc <= 0.0 else minf(speed, float(m.v) + acc * delta)
						if mo.has("speeds"):
							# a speed for each stretch of its road (note 103's cart): it gathers to
							# its first speed at `accel`, then takes the road's speed where it is
							var want := _speed_along(m, mo, float(m.dist))
							m.v = want if want > speed + 0.01 or float(m.v) > want else minf(want, float(m.v) + maxf(acc, 0.5) * delta)
						if mo.has("decel"):
							# a gentle stop at the end of its road (note 82's zip line)
							var left := maxf(0.0, total - float(m.dist))
							m.v = minf(float(m.v), maxf(0.6, sqrt(2.0 * float(mo.decel) * left)))
						var was_d := float(m.dist)
						m.dist = float(m.dist) + float(m.v) * delta
						if mo.has("hop") and was_d < float(m.get("hop_d", INF)) and float(m.dist) >= float(m.get("hop_d", INF)):
							_start_hop(m, mo)
							if _tick_hop(m, mo, 0.0):
								return
						if mo.has("loose") and float(m.dist) >= float(mo.loose):
							_let_loose(m)
							return
						if float(m.dist) >= total:
							m.dist = total
							m.run = false
							m.arrived = t
							peak.audio.play("cart_crash" if m.id.begins_with("cart") else "gondola_clunk", _mover_at(m))
					elif float(m.arrived) >= 0.0:
						# Home again once nobody is near (or the wait is long over).
						var away := peak.player == null or peak.player_at().distance_to((m.home as Vector2) + (m.offset as Vector2)) > 22.0
						var reset := float(mo.get("reset", 10.0))
						if (t - float(m.arrived) > reset and away) or (t - float(m.arrived) > reset * 3.0 and not _player_limbs_on(m.nodes) and not _player_aboard(m)):
							m.dist = 0.0
							m.arrived = -1.0
							m.board_t = 0.0
							jumped = true
							_reset_chock(m)
					d = float(m.dist)
			if mode != "once":
				m.dist = d
			var at: Array = _along(m, d)
			m.offset = (at[0] as Vector2) - (m.home as Vector2)
			if bool(mo.get("tilt", false)):
				var dir: Vector2 = at[1]
				var want := atan2(dir.y, dir.x)
				if absf(want) > PI * 0.5:
					want -= signf(want) * PI
				m.angle = lerp_angle(float(m.angle), want, 1.0 - exp(-delta * float(mo.get("tilt_rate", 6.0))))
		"spin":
			m.angle = deg_to_rad(float(mo.get("phase", 0.0))) + t * float(mo.rpm) * TAU / 60.0
		"swing":
			m.angle = deg_to_rad(float(mo.amp)) * sin(TAU * (t / maxf(0.1, float(mo.period)) + float(mo.get("phase", 0.0))))
		"cycle":
			var t_out := float(mo.get("t_out", 0.5))
			var h_out := float(mo.get("hold_out", 1.0))
			var t_in := float(mo.get("t_in", 0.5))
			var h_in := float(mo.get("hold_in", 1.0))
			var cyc := fposmod(t + float(mo.get("phase", 0.0)), t_out + h_out + t_in + h_in)
			var f := 0.0
			if cyc < t_out:
				f = _ease(cyc / maxf(t_out, 0.001))
			elif cyc < t_out + h_out:
				f = 1.0
			elif cyc < t_out + h_out + t_in:
				f = 1.0 - _ease((cyc - t_out - h_out) / maxf(t_in, 0.001))
			m.offset = Peak.v2(mo.to) * f
			if mo.has("zto"):
				m["zoff"] = float(mo.zto) * f  # (it opens back, out of the play plane: La Esclusa's flap)
		"sink":
			var to := Peak.v2(mo.to)
			var loaded := _player_limbs_on(m.nodes)
			var rate := (float(mo.get("speed", 1.0)) if loaded else -float(mo.get("back", 0.6))) / maxf(to.length(), 0.01)
			m.prog = clampf(float(m.prog) + rate * delta, 0.0, 1.0)
			m.offset = to * float(m.prog)
		"link":
			var other: Dictionary = movers.get(str(mo.to), {})
			if not other.is_empty():
				m.offset = (other.offset as Vector2) * float(mo.get("scale", -1.0))
		"tip":
			if mo.has("shatter"):
				jumped = _tick_tip_fall(m, mo, t)
			elif float(m.tip_t) < 0.0:
				if _player_limbs_on(m.nodes):
					m.tip_t = t
					peak.audio.play("ice_crack", _mover_at(m))
			else:
				var el := t - float(m.tip_t)
				var dur := maxf(0.2, float(mo.get("time", 4.0)))
				var f := clampf(el / dur, 0.0, 1.0)
				m.angle = deg_to_rad(float(mo.angle)) * f * f
				if el > dur + float(mo.get("reset", 10.0)) and not _player_limbs_on(m.nodes):
					m.tip_t = -1.0
					m.angle = 0.0
					jumped = true
		"winch":
			var to := Peak.v2(mo.to)
			var w: Dictionary = (m.def as Dictionary).winch
			var turned := float(m.get("w_turned", 0.0))
			m["w_turned"] = 0.0
			var rate := turned / TAU * float(w.get("per_turn", 0.6)) - float(w.get("fall", 0.3)) * delta * (0.0 if turned > 0.004 else 1.0)
			m.prog = clampf(float(m.prog) + rate / maxf(to.length(), 0.01), 0.0, 1.0)
			m.offset = to * float(m.prog)
		"crank":
			var to := Peak.v2(mo.to)
			var b: Dictionary = bodies.get(str(mo.body), {})
			var turned := float(b.get("turned", 0.0))
			var rate := turned / TAU * float(mo.get("per_turn", 0.8)) - float(mo.get("fall", 0.25)) * delta * (0.0 if turned > 0.004 else 1.0)
			m.prog = clampf(float(m.prog) + rate / maxf(to.length(), 0.01), 0.0, 1.0)
			m.offset = to * float(m.prog)
	var pos := (m.home as Vector2) + (m.offset as Vector2)
	if str(m.id).begins_with("cart"):
		_cart_sound(m)
	if jumped:
		_release_from(m.nodes)
	m.speed = 0.0 if jumped else pos.distance_to(m.prev) / maxf(delta, 0.0001)
	m.prev = pos
	m["spin"] = 0.0 if jumped else absf(angle_difference(float(m.get("prev_ang", m.angle)), float(m.angle))) / maxf(delta, 0.0001)
	m["prev_ang"] = m.angle
	for node: AnimatableBody3D in m.nodes:
		node.transform = Transform3D(Basis(Vector3.BACK, float(m.angle)), Vector3(pos.x, pos.y, float(m.get("zoff", 0.0))))
	if bool((m.def as Dictionary).get("ko", false)):
		_mover_ko(m)
	if m.has("walk"):
		_tick_walker(m, delta)
	if str(m.type) in ["cycle", "path"]:
		_wall_wipe(m)
		if (m.def as Dictionary).has("socket") and str(m.type) == "cycle":
			_socket_tell(m)


## THE CART HOPS THE BROKEN RAIL (playtest note 73; Parker 11-13: "real hop and make dust come
## off the wheels when it lands"). A "once" path with `hop` {"x": the crest's x, "g": m/s2}
## leaves its road where it passes the crest, at its own speed along the road there, and
## flies under `g` until its floor is back on the road; there it lands with a bang, dust off
## the wheels and a jolt of the camera, and runs on from that point. Hands and feet on it go
## with it (the welds are to the cart). The rider is lighter in the air than the cart (the
## climber's own gravity is 2.79): hold on.
func _start_hop(m: Dictionary, mo: Dictionary) -> void:
	var at: Array = _along(m, float(m.hop_d))
	m["fly"] = {"p": at[0], "v": (at[1] as Vector2) * float(m.v), "t": 0.0}
	m.dist = float(m.hop_d)


## The road's height at x, past the crest (the road runs one way in x there), or INF.
func _road_y(m: Dictionary, x: float) -> float:
	var pts: PackedVector2Array = m.pts
	for i in range(1, pts.size()):
		var a := pts[i - 1]
		var b := pts[i]
		if (x - a.x) * (x - b.x) <= 0.0 and absf(b.x - a.x) > 0.001:
			return lerpf(a.y, b.y, (x - a.x) / (b.x - a.x))
	return INF


func _road_dist(m: Dictionary, x: float) -> float:
	var pts: PackedVector2Array = m.pts
	var cum: PackedFloat32Array = m.cum
	for i in range(1, pts.size()):
		var a := pts[i - 1]
		var b := pts[i]
		if (x - a.x) * (x - b.x) <= 0.0 and absf(b.x - a.x) > 0.001 and cum[i - 1] >= float(m.hop_d) - 0.01:
			return cum[i - 1] + a.distance_to(b) * clampf((x - a.x) / (b.x - a.x), 0.0, 1.0)
	return float(m.hop_d)


## One tick of the flight. True when the mover's own tick is done for this frame.
func _tick_hop(m: Dictionary, mo: Dictionary, delta: float) -> bool:
	var fly: Dictionary = m.fly
	var g := float((mo.hop as Dictionary).get("g", 8.9))
	var v: Vector2 = fly.v
	var p: Vector2 = fly.p
	v.y -= g * delta
	p += v * delta
	fly.t = float(fly.t) + delta
	var road := _road_y(m, p.x)
	if float(fly.t) > 0.05 and p.y <= road:
		# down: back on the road where it touched, at its speed along it
		m.erase("fly")
		m.dist = _road_dist(m, p.x)
		var at: Array = _along(m, float(m.dist))
		m.v = clampf(v.dot(at[1]), 1.0, float(mo.get("speed", 9.0)))
		m.offset = (at[0] as Vector2) - (m.home as Vector2)
		var c := (at[0] as Vector2)
		for e: float in [-0.9, 0.9]:
			var wheel: Vector2 = c + (at[1] as Vector2) * e + Vector2(0, -0.35)
			peak.zones.burst(wheel, "dust", 1.4, Vector2(-signf(e) * 0.4, 1.0))
		peak.audio.play("cart_crash", c, 2.0)
		peak.cam_kick = 0.35
		return false
	fly.v = v
	fly.p = p
	m.offset = p - (m.home as Vector2)
	# it noses over in the air: the floor follows the flight
	var want := atan2(v.y, v.x)
	if absf(want) > PI * 0.5:
		want -= signf(want) * PI
	m.angle = lerp_angle(float(m.angle), want, 1.0 - exp(-delta * 5.0))
	var pos := (m.home as Vector2) + (m.offset as Vector2)
	m.speed = pos.distance_to(m.prev) / maxf(delta, 0.0001)
	m.prev = pos
	for node: AnimatableBody3D in m.nodes:
		node.transform = Transform3D(Basis(Vector3.BACK, float(m.angle)), Vector3(pos.x, pos.y, 0.0))
	_cart_sound(m)
	return true


## THE SERAC FALLS ALL THE WAY (playtest note 88; Parker 11-13: "Make it fall all the way
## and then shatter in the hole so it dumps you down there. That way you have to run across
## it while it rotates"; then: "the new serac needs to grow into place by the way"). A tip
## with `shatter` (degrees) does not stop: it keeps to its curve (angle x (t / time)^2)
## through level until it reaches `shatter`, where it breaks into pieces and lets go of
## whoever is on it. After `regrow_wait` s a new one grows up out of the ice where it stood,
## over `grow` s, and can be touched only at full height.
func _tick_tip_fall(m: Dictionary, mo: Dictionary, t: float) -> bool:
	var st := str(m.get("tip_state", "up"))
	match st:
		"up":
			if _player_limbs_on(m.nodes):
				m.tip_t = t
				m["tip_state"] = "fall"
				peak.audio.play("ice_crack", _mover_at(m))
		"fall":
			var el := t - float(m.tip_t)
			var dur := maxf(0.2, float(mo.get("time", 4.0)))
			var want := deg_to_rad(float(mo.angle)) * (el / dur) * (el / dur)
			var end := deg_to_rad(float(mo.shatter))
			if absf(want) >= absf(end):
				_shatter_mover(m)
				m.angle = 0.0
				m["tip_state"] = "gone"
				m["gone_t"] = t
				_tip_piece_show(m, "stump", true)
				return true
			m.angle = want
		"gone":
			if t - float(m.gone_t) >= float(mo.get("regrow_wait", 3.0)):
				m["tip_state"] = "grow"
				m["grow_t"] = t
				# (the tower that grows is the bare one, if it has landed; else the tower itself)
				if not _tip_piece_show(m, "bare", true):
					(m.vis as Node3D).visible = true
				peak.audio.play("ice_crack", _mover_at(m), -6.0, 0.7)
		"grow":
			var f := clampf((t - float(m.grow_t)) / maxf(0.1, float(mo.get("grow", 3.0))), 0.0, 1.0)
			var base: Vector3 = m.get("vis_scale", Vector3.ONE)
			var bare: Node3D = (m.get("tip_pieces", {}) as Dictionary).get("bare")
			var grows: Node3D = bare if bare != null and bare.visible else (m.vis as Node3D)
			grows.scale = Vector3(base.x * lerpf(0.6, 1.0, f), base.y * maxf(0.02, _ease(f)), base.z * lerpf(0.6, 1.0, f))
			if f >= 1.0:
				m["tip_state"] = "up"
				m.tip_t = -1.0
				# Full height: the bare tower is the tower with its snow side and cap, and can be held.
				_tip_piece_show(m, "bare", false)
				_tip_piece_show(m, "stump", false)
				(m.vis as Node3D).scale = base
				(m.vis as Node3D).visible = true
				for node: AnimatableBody3D in m.nodes:
					node.collision_layer = Climber.LAYER_WORLD
	return false


## A tipping tower's other looks (a9_dress item 8): `bare`, the tower with no snow, shown while the
## next one grows; `stump`, the broken foot left at the pivot while it is gone and while the next
## grows. Each is the motion's stem, made lazily; false if it has none or it has not landed.
func _tip_piece_show(m: Dictionary, key: String, on: bool) -> bool:
	var mo: Dictionary = m.mo
	if not mo.has(key):
		return false
	if not m.has("tip_pieces"):
		m["tip_pieces"] = {}
	var pieces: Dictionary = m.tip_pieces
	if not pieces.has(key):
		var n: Node3D = Peak.kit(str(mo[key]))
		pieces[key] = n
		if n != null:
			var body := m.nodes[0] as Node3D
			if key == "bare":
				n.position = (m.vis as Node3D).position
				n.scale = m.get("vis_scale", (m.vis as Node3D).scale)
				body.add_child(n)  # (it stands where the tower stood, and turns with it as it will)
			else:
				n.position = Vector3(body.position.x, body.position.y, 0.0)
				body.get_parent().add_child(n)  # (it stays at the pivot)
	var piece: Node3D = pieces[key]
	if piece == null:
		return false
	piece.visible = on
	return true


## A ROTTEN RUNG SWINGS DOWN ON ITS LAST BOLT (a10_dress 6c): `hang` = [the bolt's x, y, the angle it
## hangs at]. Broken, it hangs flat against the face (its `hang_model` if that has landed, else its own
## piece turned about the bolt); whole again, it is put back. False for a hold that does not hang.
func _hang_rung(h: Dictionary, on: bool) -> bool:
	var def: Dictionary = h.def
	if not def.has("hang"):
		return false
	var hg: Array = def.hang
	var piv := Vector3(float(hg[0]), float(hg[1]), 0.0)
	var pivot: Node3D = h.get("hang_look")
	if pivot == null:
		pivot = Node3D.new()
		pivot.position = piv
		var model: Node3D = Peak.kit(str(def.hang_model)) if def.has("hang_model") else null
		if model != null:
			h["hang_made"] = true  # (made hanging: shown as it is)
			pivot.add_child(model)
		else:
			var copy := (h.vis as Node3D).duplicate() as Node3D
			copy.visible = true
			copy.position = -piv
			pivot.add_child(copy)
		(h.vis as Node3D).get_parent().add_child(pivot)
		h["hang_look"] = pivot
	if not on:
		pivot.visible = false
		return true
	pivot.visible = true
	if bool(h.get("hang_made", false)):
		pivot.rotation.z = 0.0
	else:
		pivot.rotation.z = 0.0
		var tw := pivot.create_tween()
		tw.tween_property(pivot, "rotation:z", deg_to_rad(float(hg[2])) + 0.12, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_property(pivot, "rotation:z", deg_to_rad(float(hg[2])), 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	return true


## A broken piece's look: on the glacier `glaciar_ice_shard` (made 0.45 x 0.6 x 0.4), scaled to the
## piece; elsewhere, or until it lands, a box.
const SHARD_SIZE := Vector3(0.45, 0.6, 0.4)


func _chunk_look(size: Vector3, col: Color, area: String) -> Node3D:
	if area == "a9":
		var shard := LuchaKit.kit_model("glaciar_ice_shard")
		if shard != null:
			shard.scale = size / SHARD_SIZE
			return shard
	return LuchaKit.box(size, col)


## A mover breaks: whoever is on it lets go, its pieces fall, it is gone (unseen, untouchable).
func _shatter_mover(m: Dictionary) -> void:
	_release_from(m.nodes)
	var c := peak.player
	if c != null:
		for l in c.limbs:
			l.regrip = maxf(float(l.regrip), 0.4)
	var root: Node3D = (m.nodes[0] as Node3D).get_parent()
	var xf := Transform2D(float(m.angle), _mover_at(m))
	var area: Dictionary = {}
	for a in peak.areas:
		if str(a.id) == str(m.area):
			area = a
	for sh in (m.def as Dictionary).shapes:
		var pts: PackedVector2Array = peak._pts(sh.pts)
		var lo := pts[0]
		var hi := pts[0]
		for p in pts:
			lo = lo.min(p)
			hi = hi.max(p)
		var size := hi - lo
		var nx := clampi(int(size.x / 0.7), 1, 4)
		var ny := clampi(int(size.y / 0.7), 1, 10)
		var cell := Vector2(size.x / nx, size.y / ny)
		var col: Color = peak.kind_color(area, str(sh.kind)) if not area.is_empty() else Color("#BFE8F6")
		for ix in nx:
			for iy in ny:
				var cp := lo + Vector2((ix + 0.5) * cell.x, (iy + 0.5) * cell.y)
				if not Geometry2D.is_point_in_polygon(cp, pts):
					continue
				var w := xf * cp
				var rb := RigidBody3D.new()
				rb.collision_layer = 0
				rb.collision_mask = Climber.LAYER_WORLD
				rb.mass = 3.0
				rb.gravity_scale = 0.75
				var chunk := Vector3(cell.x * randf_range(0.7, 0.95), cell.y * randf_range(0.7, 0.95), 0.7)
				var cs := CollisionShape3D.new()
				var bx := BoxShape3D.new()
				bx.size = chunk
				cs.shape = bx
				rb.add_child(cs)
				rb.add_child(_chunk_look(chunk, col.darkened(randf_range(0.0, 0.12)), str(m.area)))
				rb.position = Vector3(w.x, w.y, randf_range(-0.2, 0.2))
				rb.rotation = Vector3(0, 0, float(m.angle) + randf_range(-0.3, 0.3))
				rb.linear_velocity = Vector3(randf_range(-1.0, 1.0), randf_range(-1.5, 0.8), randf_range(-0.5, 0.5))
				rb.angular_velocity = Vector3(randf_range(-4, 4), randf_range(-4, 4), randf_range(-5, 5))
				root.add_child(rb)
				_debris.append([rb, peak.clock])
	for node: AnimatableBody3D in m.nodes:
		node.collision_layer = 0
	if not m.has("vis_scale"):
		m["vis_scale"] = (m.vis as Node3D).scale
	(m.vis as Node3D).visible = false
	var at := _mover_at(m)
	peak.zones.burst(at + Vector2(3.0, -1.0), "glitter", 2.0)
	peak.zones.burst(at + Vector2(3.0, -1.0), "frost", 1.6)
	peak.audio.play("ice_shatter", at + Vector2(3.0, -1.0), 4.0)


## A HOLD THAT GOES INTO A WALL LETS GO OF YOU AT THE WALL'S FACE (Parker 11-12, of the
## temple's pistons: "when it goes into a wall and your hand is on it, it should not let you
## still be grabbed on"). A hand or foot on a sliding piece is let go the moment the point
## it holds passes into solid rock. Further out along the piece it keeps its hold until
## that part reaches the wall too: you can ride a piston toward the wall, never into it.
func _wall_wipe(m: Dictionary) -> void:
	var c := peak.player
	if c == null:
		return
	for i in c.limbs.size():
		var o = c.limbs[i].grab_other
		if o == null or not m.nodes.has(o):
			continue
		var p := peak.local_of(c.limb_end(i))
		for row: Array in _rock.get(m.area, []):
			if (row[0] as Rect2).has_point(p) and Geometry2D.is_point_in_polygon(p, row[1]):
				c.release(i)
				c.limbs[i].regrip = 0.35
				Sound.play_at("grip", Vector3(c.limb_end(i).x, c.limb_end(i).y, 0), -3.0)
				break


## ...AND YOU CAN SEE IT COMING: a piece that lives in a socket grinds and puffs dust at
## the socket's mouth just before it starts back in. (`socket`: where the mouth is.)
const SOCKET_TELL_S := 0.5


func _socket_tell(m: Dictionary) -> void:
	var mo: Dictionary = m.mo
	var t_out := float(mo.get("t_out", 0.5))
	var h_out := float(mo.get("hold_out", 1.0))
	var total := t_out + h_out + float(mo.get("t_in", 0.5)) + float(mo.get("hold_in", 1.0))
	var ph := peak.clock + float(mo.get("phase", 0.0))
	var cyc := fposmod(ph, total)
	var n := int(floor(ph / total))
	if int(m.get("told", -1)) == n or cyc < t_out + h_out - SOCKET_TELL_S or cyc > t_out + h_out:
		return
	m["told"] = n
	var at := Peak.v2((m.def as Dictionary).socket)
	if peak.player == null or peak.player_at().distance_to(at) > 26.0:
		return
	peak.audio.play("dust_trickle", at, -2.0, 1.25)
	peak.zones.burst(at, "dust")


## OFF THE END OF ITS ROAD A MOVER IS A LOOSE THING (Parker 11-12, of the cart that runs
## off the broken trestle: it "falls too slow and should instead have physics a little
## after it falls". It never fell: it was slid down a drawn curve to the Sump at 5 m/s,
## fifteen seconds of glide). A path with `loose` in its motion is followed only that many
## metres; there the mover becomes a rigid body with the speed and the lean it had, and
## tips, falls and knocks about as the world decides. Hands and feet on it stay on it
## (the welds are made again on the new body, which stands exactly where the old one
## did). It goes home after its usual `reset`.
func _let_loose(m: Dictionary) -> void:
	var mo: Dictionary = m.mo
	var def: Dictionary = m.def
	var at: Array = _along(m, float(m.dist))
	var pos: Vector2 = at[0]
	var dir: Vector2 = at[1]
	var rb := RigidBody3D.new()
	rb.mass = float(mo.get("mass", 140.0))
	rb.collision_layer = Climber.LAYER_WORLD
	rb.collision_mask = Climber.LAYER_WORLD
	rb.axis_lock_linear_z = true
	rb.axis_lock_angular_x = true
	rb.axis_lock_angular_y = true
	rb.gravity_scale = float(mo.get("fall_g", LOOSE_G))
	rb.linear_damp = 0.03
	rb.angular_damp = 0.25
	rb.can_sleep = false
	rb.contact_monitor = true  # (is it lying on something: see _tick_loose)
	rb.max_contacts_reported = 6
	var pm := PhysicsMaterial.new()
	pm.friction = 0.7
	pm.bounce = 0.3
	rb.physics_material_override = pm
	var grips := false
	for sh in def.shapes:
		peak._add_shapes(rb, peak._pts(sh.pts), -Peak.HALF, Peak.HALF)
		grips = grips or peak.kind_grips(str(sh.kind))
	if not grips:
		rb.set_meta("no_weld", true)
	rb.transform = Transform3D(Basis(Vector3.BACK, float(m.angle)), Vector3(pos.x, pos.y, 0))
	var first: Node3D = m.nodes[0]
	first.get_parent().add_child(rb)
	rb.linear_velocity = Vector3(dir.x, dir.y, 0) * float(m.v)
	rb.angular_velocity = Vector3(0, 0, float(mo.get("tip", 0.9)) * (1.0 if dir.x < 0.0 else -1.0))  # (nose down)
	Climber.sync_server(rb)  # THE LATE TRANSFORM LAW: the welds below anchor where it is
	(m.vis as Node3D).reparent(rb, false)
	# It falls past ropes and chains, never onto them (a rope's pieces are solid to
	# anything that looks for the world, and a hanging chain would catch a falling cart).
	for r in ropes:
		if r.area == m.area:
			for seg: RigidBody3D in r.segs:
				rb.add_collision_exception_with(seg)
			if r.bob != null:
				rb.add_collision_exception_with(r.bob)
	var c := peak.player
	if c != null:
		for i in c.limbs.size():
			if c.limbs[i].grab_other != null and m.nodes.has(c.limbs[i].grab_other):
				c.release(i)
				c.limbs[i].regrip = 0.0
				c.attach(i, rb)
	for node: AnimatableBody3D in m.nodes:
		node.collision_layer = 0
	m["loose"] = rb
	m["loose_v"] = rb.linear_velocity
	m["loose_bang"] = 0.0
	m["loose_wet"] = false
	m.run = false
	m.arrived = peak.clock
	m.speed = 0.0
	if str(m.id).begins_with("cart"):
		_cart_sound(m)  # (its roll on the rails stops)


const LOOSE_G := 0.55  # a loose mover's gravity against the engine's (a faller's: 5.4 m/s2)


## A wrapping mover's loose double: a rigid body where the piece was, with a copy of its
## look, a little speed and a tip forward. Hands and feet on the piece go with it. The
## piece itself carries on round its line unseen and comes back at its start. The stray
## splashes where it lands, sinks, and is taken away once nobody holds it.
var _strays: Array = []  # [body, born, went under at (-1: dry)]


func _let_stray(m: Dictionary, d: float) -> void:
	var mo: Dictionary = m.mo
	var def: Dictionary = m.def
	var at: Array = _along(m, d)
	var pos: Vector2 = at[0]
	var dir: Vector2 = at[1]
	var rb := RigidBody3D.new()
	rb.mass = float(mo.get("mass", 60.0))
	rb.collision_layer = Climber.LAYER_WORLD
	rb.collision_mask = Climber.LAYER_WORLD
	rb.axis_lock_linear_z = true
	rb.axis_lock_angular_x = true
	rb.axis_lock_angular_y = true
	rb.gravity_scale = float(mo.get("fall_g", LOOSE_G))
	rb.linear_damp = 0.03
	rb.angular_damp = 0.25
	rb.can_sleep = false
	var pm := PhysicsMaterial.new()
	pm.friction = 0.6
	pm.bounce = 0.35
	rb.physics_material_override = pm
	var grips := false
	for sh in def.shapes:
		peak._add_shapes(rb, peak._pts(sh.pts), -Peak.HALF * 0.5, Peak.HALF * 0.5)
		grips = grips or peak.kind_grips(str(sh.kind))
	if not grips:
		rb.set_meta("no_weld", true)
	rb.transform = Transform3D(Basis(Vector3.BACK, float(m.angle)), Vector3(pos.x, pos.y, 0))
	var first: Node3D = m.nodes[0]
	first.get_parent().add_child(rb)
	rb.set_meta("area", str(m.area))  # (a board of its area may kick it: note 146)
	var push := float(mo.get("push", 1.2))
	rb.linear_velocity = Vector3(dir.x, dir.y, 0) * maxf(push, float(mo.get("speed", 1.0)))
	rb.angular_velocity = Vector3(0, 0, float(mo.get("tip", 1.4)) * (1.0 if dir.x < 0.0 else -1.0))
	Climber.sync_server(rb)  # THE LATE TRANSFORM LAW
	var look: Node3D = Peak.kit(str(def.model)) if def.has("model") else null
	if look == null:
		look = _shapes_mesh(peak.areas[0], def.shapes)
	rb.add_child(look)
	for r in ropes:
		if r.area == m.area:
			for seg: RigidBody3D in r.segs:
				rb.add_collision_exception_with(seg)
	var c := peak.player
	if c != null:
		for i in c.limbs.size():
			if c.limbs[i].grab_other != null and m.nodes.has(c.limbs[i].grab_other):
				c.release(i)
				c.limbs[i].regrip = 0.0
				c.attach(i, rb)
	_strays.append([rb, peak.clock, -1.0])


func _tick_strays() -> void:
	var t := peak.clock
	for k in range(_strays.size() - 1, -1, -1):
		var row: Array = _strays[k]
		var rb: RigidBody3D = row[0]
		if not is_instance_valid(rb):
			_strays.remove_at(k)
			continue
		var here := Vector2(rb.position.x, rb.position.y)
		# THE KICKER (note 146, Los Barriles): a loose barrel that meets a board of its area is thrown up and
		# back into the background, never into the falls, as a rock is off note 91's board.
		var board := _board_under(str(rb.get_meta("area", "")), here, 0.9)
		if not board.is_empty() and not _player_limbs_on([rb]):
			_kick_stray(board, rb)
			_strays.remove_at(k)
			continue
		if float(row[2]) < 0.0 and peak.zones.water_at(here) != null:
			row[2] = t
			rb.linear_damp = 2.4
			rb.angular_damp = 2.0
			rb.gravity_scale *= 0.4
			peak.zones.splash_at(here, 1.3, rb.linear_velocity.length())
		# Gone once it has lain in the water a while, or long after it left, and nobody has it.
		var done := (float(row[2]) >= 0.0 and t - float(row[2]) > 5.0) or t - float(row[1]) > 20.0 or here.y < -70.0
		if done and not _player_limbs_on([rb]):
			if rb.scale.x > 0.12:
				rb.scale *= 0.9  # (it shrinks away, as a broken plank's pieces do)
			else:
				rb.queue_free()
				_strays.remove_at(k)


## A kicked stray, flown as a thrown rock is: [its look, velocity, spin, depth, gone under y, when].
var _kicked: Array = []


func _kick_stray(board: Dictionary, rb: RigidBody3D) -> void:
	var def: Dictionary = board.def
	var fly := Node3D.new()
	fly.transform = rb.transform
	rb.get_parent().add_child(fly)
	for ch in rb.get_children():
		if not ch is CollisionShape3D:
			rb.remove_child(ch)
			fly.add_child(ch)
	rb.queue_free()
	var v := Vector3(float(def.throw[0]) * randf_range(0.8, 1.25), float(def.throw[1]) * randf_range(0.92, 1.1), float(def.throw[2]) * randf_range(0.9, 1.1))
	var spin := Vector3(randf_range(-2.0, 2.0), randf_range(-1.5, 1.5), randf_range(2.0, 5.0))
	_kicked.append([fly, v, spin, float(def.depth), float(def.gone), peak.clock])
	var at := Vector2(fly.position.x, fly.position.y)
	peak.audio.play("kick_thwack", at, -5.0, randf_range(0.8, 0.95))
	peak.zones.splash_at(at, 0.8)


func _fly_kicked(delta: float) -> void:
	for k in range(_kicked.size() - 1, -1, -1):
		var row: Array = _kicked[k]
		var n: Node3D = row[0]
		if not is_instance_valid(n) or peak.clock - float(row[5]) > 6.0:
			if is_instance_valid(n):
				n.queue_free()
			_kicked.remove_at(k)
			continue
		var v: Vector3 = row[1]
		v.y -= 9.8 * FALLER_G * delta
		var p := n.position + v * delta
		if p.z <= float(row[3]):
			p.z = float(row[3])
			v.z = 0.0
		row[1] = v
		n.position = p
		n.rotation += (row[2] as Vector3) * delta
		var s := lerpf(1.0, 0.6, clampf(p.z / minf(float(row[3]), -0.01), 0.0, 1.0))
		n.scale = Vector3(s, s, s)
		if p.y < float(row[4]) and v.y < 0.0:
			n.queue_free()
			_kicked.remove_at(k)


func _tick_loose(m: Dictionary) -> void:
	var rb: RigidBody3D = m.loose
	var mo: Dictionary = m.mo
	var t := peak.clock
	var here := Vector2(rb.position.x, rb.position.y)
	# It bangs on what it hits (a sudden change of speed), not more than twice a second.
	var v := rb.linear_velocity
	if (v - (m.loose_v as Vector3)).length() > 3.0 and t - float(m.loose_bang) > 0.5:
		m.loose_bang = t
		peak.audio.play("cart_crash" if str(m.id).begins_with("cart") else "gondola_clunk", here, clampf(-8.0 + (v - (m.loose_v as Vector3)).length(), -8.0, 3.0))
	m.loose_v = v
	# Water takes its speed and lets it sink (it is iron and oak).
	var wet: bool = peak.zones.water_at(here) != null
	if wet != bool(m.loose_wet):
		m.loose_wet = wet
		rb.linear_damp = 2.2 if wet else 0.03
		rb.angular_damp = 2.0 if wet else 0.25
		rb.gravity_scale = float(mo.get("fall_g", LOOSE_G)) * (0.45 if wet else 1.0)
		if wet:
			peak.zones.splash_at(here, 1.6, v.length())
	# A FALLING CART IS HEAVIER THAN YOUR GRIP. Holding only the cart, you go with it.
	# Holding something else as well (a hand found the chain as you went under it), you
	# keep that and lose the cart: without this a 22 kg climber on a chain held 140 kg of
	# cart up by the feet. Lying on the rock or in the water it pulls on nobody.
	var held := _player_limbs_on([rb])
	if held and not wet and rb.get_colliding_bodies().is_empty():
		for l in peak.player.limbs:
			if l.grab_other != null and l.grab_other != rb:
				_release_from([rb])
				held = false
				break
	# Home again, as a cart at the end of its road goes: once its wait is over and nobody
	# is near it or on it (or the wait is long over and nobody is on it).
	var away := peak.player == null or peak.player_at().distance_to(here) > 22.0
	var reset := float(mo.get("reset", 10.0))
	var since := t - float(m.arrived)
	if (since > reset and away and not held) or (since > reset * 3.0 and not held) or here.y < -70.0:
		_loose_home(m)


## THE CHOCK (a1_dress item 7, page 1.7): a wooden wedge under a cart's wheel, at `chock`
## (x, y from the cart's home: on the rail). It is scenery, never solid. When the cart
## starts it jumps out, tumbling, and lies where it falls; it is back when the cart is.
func _build_chock(m: Dictionary, at: Array, root: Node3D) -> void:
	var n: Node3D = Peak.kit("mine_chock")
	if n == null:
		n = LuchaKit.box(Vector3(0.45, 0.32, 0.3), Color("#8A5A32"), Vector3(0, 0.16, 0))
	var home: Vector2 = (m.home as Vector2) + Vector2(float(at[0]), float(at[1]))
	n.position = Vector3(home.x, home.y, 0.0)
	root.add_child(n)
	m["chock"] = n
	m["chock_home"] = n.position


func _kick_chock(m: Dictionary) -> void:
	var n: Node3D = m.get("chock")
	if n == null or not n.visible:
		return
	var away := signf(n.position.x - ((m.home as Vector2).x)) if absf(n.position.x - (m.home as Vector2).x) > 0.01 else 1.0
	var tw := n.create_tween()
	tw.set_parallel(true)
	tw.tween_property(n, "position:x", n.position.x + away * 1.6, 0.7)
	tw.tween_property(n, "position:y", n.position.y + 0.9, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(n, "position:y", n.position.y - 6.0, 0.6).set_delay(0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(n, "rotation:z", -away * TAU * 1.5, 0.85)
	tw.chain().tween_callback(func() -> void: n.visible = false)


func _reset_chock(m: Dictionary) -> void:
	var n: Node3D = m.get("chock")
	if n == null:
		return
	n.position = m.chock_home
	n.rotation = Vector3.ZERO
	n.visible = true


func _loose_home(m: Dictionary) -> void:
	var rb: RigidBody3D = m.loose
	_release_from([rb])
	(m.vis as Node3D).reparent(m.nodes[0], false)
	rb.queue_free()
	m.erase("loose")
	m.dist = 0.0
	m.v = 0.0
	m.arrived = -1.0
	m.board_t = 0.0
	_reset_chock(m)
	m.angle = 0.0
	m.offset = Vector2.ZERO
	m.prev = m.home
	m.speed = 0.0
	for node: AnimatableBody3D in m.nodes:
		node.transform = Transform3D(Basis(), Vector3((m.home as Vector2).x, (m.home as Vector2).y, 0))
		node.collision_layer = Climber.LAYER_WORLD
		Climber.sync_server(node)


## A cart's own voice: the roll while it runs, a clack at every rail joint (4 m).
func _cart_sound(m: Dictionary) -> void:
	var node: Node3D = m.nodes[0]
	var roll: AudioStreamPlayer3D = m.get("roll")
	if roll == null:
		var s := PeakAudio._looped(PeakAudio.SFX_DIR + "cart_roll_loop.wav")
		if s == null:
			return
		roll = AudioStreamPlayer3D.new()
		roll.stream = s
		roll.bus = "Effects"
		roll.unit_size = 9.0
		roll.max_distance = 60.0
		node.add_child(roll)
		m["roll"] = roll
		m["clack_at"] = 0.0
	if bool(m.run) and not roll.playing:
		roll.play()
	elif not bool(m.run) and roll.playing:
		roll.stop()
	if bool(m.run):
		roll.pitch_scale = clampf(0.6 + float(m.v) * 0.07, 0.6, 1.5)
		roll.volume_db = clampf(-8.0 + float(m.v) * 1.2, -8.0, 6.0)
		if float(m.dist) - float(m.clack_at) > 4.0:
			m.clack_at = m.dist
			peak.audio.play("cart_clack", _mover_at(m), 0.0)
	else:
		m.clack_at = m.dist


func _mover_at(m: Dictionary) -> Vector2:
	return (m.home as Vector2) + (m.offset as Vector2)


## THE CRYSTAL RHINO BEETLE (playtest note 120; Parker 11-14: "add a little crystal rhino beetle
## that walks back and forth along this area's floor and if he runs into you, he knocks you
## slightly up and launches you in the direction he is facing. He turns around at each end").
## A pingpong `path` mover whose def has `walker`:
## - his model faces the way he walks and turns round on the spot in his pause at each end (his
##   face toward the camera halfway round, over `turn` s);
## - six legs (the `legs` model hung at `hips`, mirrored to the far side) step in two tripods as
##   far as he walks (a cycle every `stride` m), and his body bobs;
## - a piece of the climber he walks INTO (in front of his face, below his back: a piece on his
##   back is riding him) throws the whole climber his way, as the bounce caps throw: every grip
##   let go, the body's middle sent `v` m/s forward and `up` m/s up, a thwack and a chime, dust
##   and a glint. Never a knock-out (the crunch rule passes him by too);
## - ONE THROW A MEETING: after a throw he is a ghost to you (not solid, throws nobody) for at
##   least `cool` s and until you are behind him, he has turned round, or you are far off; and
##   while he passes he steps round you, behind the play plane. Without it he would catch you
##   again where you landed and herd you the length of the floor.
const WALK_BACK := 0.33  # m over his foot: a piece above this, over his shell, is on his back
const WALK_HORN := 0.55  # m: in front of his face the horn reaches this high
const WALK_SIDESTEP := -0.6  # m: how far behind the play plane he steps round you while a ghost
var bumps := 0  # (for the probes: how many times the beetle has thrown the climber)
var last_bump := {}


func _build_walker(m: Dictionary) -> void:
	var w: Dictionary = (m.def as Dictionary).walker
	var body: Node3D = m.nodes[0]
	var vis: Node3D = m.vis
	var root := Node3D.new()
	root.name = "Walker"
	body.remove_child(vis)
	root.add_child(vis)
	body.add_child(root)
	var legs: Array = []
	var hips: Array = w.get("hips", [])
	var n := hips.size()
	for side: float in [1.0, -1.0]:
		for i in n:
			var h: Array = hips[i]
			var pivot := Node3D.new()
			pivot.position = Vector3(float(h[0]), float(h[1]), float(h[2]) * side)
			var leg: Node3D = Peak.kit(str(w.legs)) if w.has("legs") else null
			if leg == null:
				leg = LuchaKit.box(Vector3(0.03, 0.03, 0.17), Color("#4A3892"), Vector3(0.0, -0.05, 0.08))
			pivot.add_child(leg)
			vis.add_child(pivot)
			# front legs splay forward, rear legs back; the far side's are turned round
			var splay := float(w.get("splay", 0.55)) * ((1.0 - 2.0 * float(i) / float(n - 1)) if n > 1 else 0.0)
			var base := splay if side > 0.0 else PI - splay
			legs.append({"n": pivot, "base": base, "s": side, "off": PI * float((i + (0 if side > 0.0 else 1)) % 2), "y": pivot.position.y})
			pivot.rotation.y = base
	m["walk"] = {"legs": legs, "root": root, "vis": vis, "bob_y": vis.position.y, "yaw": 0.0, "set": false, "face": 1.0,
		"phase": 0.0, "prev": _mover_at(m), "ghost": false, "hit_t": -INF, "ghost_face": 1.0, "side_z": 0.0}


func _tick_walker(m: Dictionary, delta: float) -> void:
	var w: Dictionary = (m.def as Dictionary).walker
	var st: Dictionary = m.walk
	var pts: PackedVector2Array = m.pts
	var cum: PackedFloat32Array = m.cum
	var total := cum[cum.size() - 1]
	var d := float(m.dist)
	var pos := _mover_at(m)
	var moved: Vector2 = pos - (st.prev as Vector2)
	st.prev = pos
	var out := signf(pts[pts.size() - 1].x - pts[0].x)  # (the way he walks from his road's first point)
	var face := float(st.face)
	if d >= total - 0.001:
		face = -out  # (at the far end: he turns to go back)
	elif d <= 0.001:
		face = out
	elif absf(moved.x) > 0.0005:
		face = signf(moved.x)
	st.face = face
	# he turns round on the spot, face to the camera halfway (yaw 0: east; -PI: west)
	var want := 0.0 if face > 0.0 else -PI
	var yaw := float(st.yaw)
	if not bool(st.set):
		yaw = want
		st.set = true
	var new_yaw := move_toward(yaw, want, PI / maxf(0.1, float(w.get("turn", 0.7))) * delta)
	var dyaw := absf(new_yaw - yaw)
	st.yaw = new_yaw
	var root: Node3D = st.root
	root.rotation.y = new_yaw
	# the legs step as far as he goes (and as he turns), in two tripods; his body bobs on each step
	var stride := maxf(0.05, float(w.get("stride", 0.24)))
	st.phase = fposmod(float(st.phase) + TAU * (moved.length() + dyaw * 0.17) / stride, TAU)
	var ph := float(st.phase)
	var amp := float(w.get("swing", 0.35))
	var lift := float(w.get("lift", 0.018))
	for L: Dictionary in st.legs:
		var a := ph + float(L.off)
		var pv: Node3D = L.n
		pv.rotation.y = float(L.base) + float(L.s) * amp * sin(a)
		pv.position.y = float(L.y) + lift * maxf(0.0, cos(a))
	(st.vis as Node3D).position.y = float(st.bob_y) + float(w.get("bob", 0.008)) * absf(sin(ph))
	# THE THROW
	var t := peak.clock
	var c := peak.player
	var live := c != null and c.state == Climber.State.LIVE
	var nearest := INF
	var hit := Vector2.INF
	var behind := true
	var inside := false
	if live:
		var front := float(w.get("front", 0.33))
		var reach := float(w.get("reach", 0.08))
		for b: RigidBody3D in c.bodies.values():
			var p := peak.local_of(Climber.pos2(b)) - pos
			nearest = minf(nearest, p.length())
			if p.x * face > -0.4:
				behind = false
		if nearest < 2.5:
			# what he walks INTO: the climber's shapes in a box in front of him up to under his back's top
			# (a piece lying on his back is riding), and in front of his face up to his horn's point
			hit = _walker_touch(pos, face, 0.0, front + reach, 0.02, WALK_BACK - 0.06)
			if not hit.is_finite():
				hit = _walker_touch(pos, face, front - 0.04, front + reach + 0.04, 0.02, WALK_HORN)
			if bool(st.ghost):
				inside = _walker_touch(pos, 1.0, -front - 0.05, front + 0.05, 0.0, WALK_BACK + 0.05).is_finite()
	if bool(st.ghost):
		var cool := t - float(st.hit_t) >= float(w.get("cool", 1.2))
		if cool and (not live or behind or face != float(st.ghost_face) or nearest > 6.0) and not inside:
			st.ghost = false
			for node: AnimatableBody3D in m.nodes:
				node.collision_layer = Climber.LAYER_WORLD
	elif live and hit.is_finite() and moved.length() / maxf(delta, 0.0001) > 0.3:
		_walker_throw(m, c, face, hit, pos)
	# while a ghost he steps round you, behind the play plane
	var side_want := WALK_SIDESTEP if bool(st.ghost) and nearest < 1.8 else 0.0
	st.side_z = move_toward(float(st.side_z), side_want, 1.6 * delta)
	root.position.z = float(st.side_z)


var _walk_q: PhysicsShapeQueryParameters3D = null


## The climber's piece in a box beside the walker (x0 .. x1 along his facing from his middle, y0 .. y1
## over his foot), as the physics has its shapes; INF if none.
func _walker_touch(pos: Vector2, face: float, x0: float, x1: float, y0: float, y1: float) -> Vector2:
	if _walk_q == null:
		_walk_q = PhysicsShapeQueryParameters3D.new()
		_walk_q.shape = BoxShape3D.new()
		_walk_q.collision_mask = Climber.LAYER_LIVE
	(_walk_q.shape as BoxShape3D).size = Vector3(x1 - x0, y1 - y0, 1.0)
	var mid := peak.world_of(pos + Vector2(face * (x0 + x1) * 0.5, (y0 + y1) * 0.5))
	_walk_q.transform = Transform3D(Basis(), Vector3(mid.x, mid.y, 0.0))
	var mine: Array = peak.player.bodies.values()
	for h: Dictionary in peak.get_world_3d().direct_space_state.intersect_shape(_walk_q, 8):
		var o: Object = h.get("collider")
		if o != null and mine.has(o):
			return peak.local_of(Climber.pos2(o as RigidBody3D))
	return Vector2.INF


func _walker_throw(m: Dictionary, c: Climber, face: float, hit: Vector2, pos: Vector2) -> void:
	var w: Dictionary = (m.def as Dictionary).walker
	var st: Dictionary = m.walk
	var com_v := c.velocity()
	var want := Vector2(face * maxf(float(w.get("v", 3.0)), com_v.x * face), maxf(float(w.get("up", 1.8)), com_v.y))
	c.release_all()
	for l in c.limbs:
		l.regrip = 0.3
	for b: RigidBody3D in c.bodies.values():
		b.linear_velocity += Vector3(want.x - com_v.x, want.y - com_v.y, 0.0)
	st.ghost = true
	st.hit_t = peak.clock
	st.ghost_face = face
	for node: AnimatableBody3D in m.nodes:
		node.collision_layer = 0
	peak.audio.play("kick_thwack", hit, 2.0, 1.15)
	peak.audio.play("crystal_chime", hit, -3.0, 1.3)
	peak.zones.burst(Vector2(hit.x, pos.y + 0.05), "dust", 0.7, Vector2(face, 1.0))
	peak.zones.burst(pos + Vector2(face * 0.36, 0.32), "glitter", 0.6, Vector2(face, 1.0))
	peak.cam_kick = maxf(peak.cam_kick, 0.25)
	bumps += 1
	last_bump = {"at": hit, "face": face, "v": want, "t": peak.clock}


## A mover that hits hard knocks you out: any piece inside its box while it moves fast.
func _mover_ko(m: Dictionary) -> void:
	var c := peak.player
	if c == null or _ko_wait > 0.0 or c.knockout_left > 0.0:
		return
	var tip_speed := float(m.speed)
	if str(m.type) in ["spin", "swing"]:
		tip_speed = 3.0  # (its arms sweep: judged by the hit below)
	if tip_speed < 2.5:
		return
	for pname in ["head", "chest", "pelvis"]:
		var b: RigidBody3D = c.bodies.get(pname)
		if b == null:
			continue
		var p := (peak.local_of(Climber.pos2(b)) - _mover_at(m)).rotated(-float(m.angle))
		for sh in (m.def as Dictionary).shapes:
			if Geometry2D.is_point_in_polygon(p, peak._pts(sh.pts)):
				var rel := Vector2(b.linear_velocity.x, b.linear_velocity.y).length()
				if str(m.type) in ["spin", "swing"] and rel < 1.0 and p.length() * absf(float((m.mo as Dictionary).get("rpm", 6.0))) * TAU / 60.0 < 2.0:
					continue
				_ko_wait = 2.5
				c.knock_out()
				peak.audio.play("knock_out_bonk", peak.local_of(Climber.pos2(b)), 3.0)
				return


# ---------------------------------------------------------------- holds with behaviours

func _tick_holds(delta: float) -> void:
	var t := peak.clock
	var c := peak.player
	if c != null:
		for i in c.limbs.size():
			var l: Dictionary = c.limbs[i]
			var o = l.grab_other
			var fresh: bool = o != null and _last_grab.get(i) != o
			_last_grab[i] = o
			if o == null or not is_instance_valid(o):
				_grip_on.erase(i)
				continue
			if not (o as Node).has_meta("peak_hold"):
				_grip_on.erase(i)
				continue
			var h: Dictionary = (o as Node).get_meta("peak_hold")
			var def: Dictionary = h.def
			var at := peak.local_of(c.limb_end(i))
			match str(h.type):
				"timed":
					if _grip_on.get(i) != o:
						_grip_on[i] = o
						_grip_t[i] = 0.0
						_grip_warned[i] = false
					_grip_t[i] = float(_grip_t[i]) + delta
					var limit := float(def.t)
					var hot := limit < 1.8
					var tell: Dictionary = _tell_of(h)
					var used := float(_grip_t[i]) / maxf(limit, 0.05)
					if not tell.is_empty():
						# You watch the time run out: the hold heats (see the holds' own loop
						# below) and the hand on it smokes, thicker and thicker.
						h["heat"] = maxf(float(h.get("heat", 0.0)), used)
						h["held_at"] = t
						if t - float(_tell_t.get(i, -9.0)) > lerpf(0.2, 0.07, used):
							_tell_t[i] = t
							peak.zones.burst(at, str(tell.hand_puff), 0.35 + 0.9 * used)
							if float(_grip_t[i]) > limit - 0.5:
								peak.zones.burst(_hold_at(h), str(tell.spit), 0.6)
					if not bool(_grip_warned[i]) and float(_grip_t[i]) > limit - 0.5:
						_grip_warned[i] = true
						peak.audio.play("sizzle" if hot else "ice_tick", at)
					if float(_grip_t[i]) >= limit:
						var end: RigidBody3D = c.bodies[l.def.end]
						c.release(i)
						l.regrip = float(def.get("rearm", 0.6))
						_grip_on.erase(i)
						peak.audio.play("steam_hiss" if hot else "ice_crack", at, -3.0)
						if not tell.is_empty():
							# It lets go with a bang you can't miss, flicks the hand off, and
							# the hand shows why it won't take the next hold yet.
							for kind in tell.go:
								peak.zones.burst(at, str(kind), 1.5)
							var away := (at - _hold_at(h))
							away = away.normalized() if away.length() > 0.02 else Vector2.UP
							end.apply_central_impulse(Vector3(away.x, away.y + 0.4, 0) * end.mass * 1.6)
							_burn_hand(i, end, tell, float(def.get("rearm", 0.6)))
				"crumble":
					if float(h.break_at) < 0.0 and float(h.back_at) < 0.0:
						h.break_at = t + float(def.t)
						var note := str((o as Node).get_meta("peak_tag", ""))
						if note.begins_with("chime"):
							# THE SCALE, IN ORDER (the design asked for a rising scale up the
							# prism's eight shelves; the eight notes were there, and the game
							# picked one at random every time): each shelf plays its own.
							peak.audio.play("crystal_chime_%02d" % clampi(int(note.substr(5)), 1, 8), at, 2.0)
						elif str(h.get("kind", "")) == "rusty":
							peak.audio.play("plank_creak", at, 0.0, 0.7)
						else:
							peak.audio.play("plank_creak" if str(h.area) in ["a0", "a1", "a7"] else ("crystal_chime" if str(h.area) == "a3" else "ice_tick"), at)
				"dynamite":
					if fresh and float(h.get("lit_at", -1.0)) < 0.0 and float(h.get("back_at", -1.0)) < 0.0:
						h["lit_at"] = t  # its fuse lights (note 58)
						peak.audio.play("sizzle", at, 2.0)
				"kick":
					if fresh:
						var v := Peak.v2(def.v)
						c.release_all()
						for lm in c.limbs:
							lm.regrip = 0.45
						for b: RigidBody3D in c.bodies.values():
							b.linear_velocity = Vector3(v.x, v.y, 0)
						peak.audio.play("kick_thwack", at, 2.0)
						Sound.play_at("donkey", Vector3(c.limb_end(i).x, c.limb_end(i).y, 0), -2.0)
	for h in holds:
		var body: CollisionObject3D = h.body
		match str(h.type):
			"crumble":
				if float(h.break_at) >= 0.0 and t < float(h.break_at):
					# It shudders before it goes.
					var left := float(h.break_at) - t
					var amp := 0.035 * clampf(1.0 - left / maxf(0.2, float((h.def as Dictionary).t)), 0.2, 1.0)
					(h.vis as Node3D).position = Vector3(randf_range(-amp, amp), randf_range(-amp, amp), 0)
					if h.has("cracks"):
						# Touched, the cracks spread and it sheds: you watch it go.
						(h.cracks as Node3D).visible = true
						if t >= float(h.get("chip_at", 0.0)):
							h["chip_at"] = t + 0.22
							var mid := _hold_at(h)
							peak.zones.burst(mid + Vector2(randf_range(-0.4, 0.4), -0.1), "glitter" if str(h.kind) == "crazed" else "dust", 0.35, Vector2.DOWN)
				if float(h.break_at) >= 0.0 and t >= float(h.break_at):
					h.break_at = -1.0
					h.back_at = t + float((h.def as Dictionary).get("respawn", 8.0))
					_release_from([body])
					body.collision_layer = 0
					(h.vis as Node3D).visible = false
					(h.vis as Node3D).position = Vector3.ZERO
					var hangs := _hang_rung(h, true)
					if h.has("cracks"):
						(h.cracks as Node3D).visible = false  # (it comes back cracked as it was, no worse)
						var mid2 := _hold_at(h)
						peak.zones.burst(mid2, "glitter" if str(h.kind) == "crazed" else "dust", 1.6)
						if str(h.kind) == "rusty":
							peak.zones.burst(mid2, "sparks", 0.8)
							peak.audio.play("hammer_clang", mid2, -4.0, 0.8)
					if not hangs:
						_crumble(h)
					var at := Vector2(body.global_position.x, body.global_position.y)
					if body is StaticBody3D and body.get_child_count() > 0:
						at = _body_centre(body)
					var area := str(h.area)
					peak.audio.play("plank_snap" if area in ["a0", "a1", "a7"] else ("crystal_shatter" if area == "a3" else ("ice_shatter" if area in ["a8", "a9"] else "rock_crumble")), at, 1.0)
				elif float(h.back_at) >= 0.0 and t >= float(h.back_at):
					h.back_at = -1.0
					body.collision_layer = int(h.layer)
					var v: Node3D = h.vis
					v.visible = true
					if _hang_rung(h, false):
						# A gust knocks it back into its socket with a clank and a puff of rust: it is whole at once.
						var mid0 := _hold_middle(body)
						v.scale = Vector3.ONE
						v.position = Vector3.ZERO
						peak.audio.play("hammer_clang", mid0, -4.0, 0.8)
						peak.zones.burst(mid0, "dust", 0.8)
						continue
					# It grows back from its own middle. (Its drawn piece is laid out in the
					# area's own metres, so a bare scale grew it from the area's zero point: a
					# plank 180 m from there flew in across the mine and shot past its place.
					# Parker 11-12: "respawn with weird graphical glitches".)
					var mid := _hold_middle(body)
					var grow := func(s: float) -> void:
						if is_instance_valid(v):
							v.scale = Vector3(s, s, 1.0)
							v.position = Vector3(mid.x * (1.0 - s), mid.y * (1.0 - s), 0)
					grow.call(0.05)
					v.create_tween().tween_method(grow, 0.05, 1.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			"timed":
				_tick_tell(h, delta)
			"dynamite":
				_tick_dynamite(h, t)
			"wet":
				var def: Dictionary = h.def
				var on := float(def.get("on", 2.0))
				var wet := fposmod(t + float(def.get("phase", 0.0)), on + float(def.get("off", 3.0))) < on
				var showy: bool = def.has("look")  # (it drips, and says so)
				var near_me: bool = showy and peak.player != null and peak.player_at().distance_to(_hold_at(h)) < 16.0
				if wet != bool(h.wet):
					h.wet = wet
					if wet:
						body.set_meta("no_weld", true)
						_release_from([body])
					else:
						body.remove_meta("no_weld")
					peak.shine_for(str(h.area))
					var cls := str(def.get("look", body.get_meta("slick_class", "mud")))
					if (h.vis as Node).has_meta("fitted"):
						PeakFit.set_wet(h.vis, cls if wet else "")
					elif h.vis is GeometryInstance3D:
						if wet:
							(h.vis as GeometryInstance3D).material_override = Peak.slick_material(cls)
						else:
							(h.vis as GeometryInstance3D).material_override = null
							CelPass.paint(h.vis, h.col as Color)
					else:
						# a hold that wears its skin (a model): its meshes go wet and dry
						for g in (h.vis as Node).find_children("*", "GeometryInstance3D", true, false):
							(g as GeometryInstance3D).material_override = Peak.slick_material(cls) if wet else null
					if near_me:
						# The drip lands on it (a splash of drops, a drip's sound); or the
						# last drops fall as it dries, and its colour comes back over a moment.
						peak.zones.burst(_hold_at(h), "drops", 1.0 if wet else 0.6)
						if wet:
							peak.audio.play("drip", _hold_at(h), -4.0)
						else:
							h["dry_at"] = t
				if near_me and wet and t >= float(h.get("drop_at", 0.0)):
					h["drop_at"] = t + 0.6  # (fewer and smaller, so the drip's streak is the tell, not a spray of dots: q29)
					peak.zones.burst(_hold_at(h) + Vector2(randf_range(-0.15, 0.15), -0.2), "drops", 0.2, Vector2.DOWN)
				if showy and h.has("dry_at"):
					var f := clampf((t - float(h.dry_at)) / 0.45, 0.0, 1.0)
					_hold_tint(h, Color(0.62, 0.8, 1.0).lerp(Color(1, 1, 1), f))
					if f >= 1.0:
						h.erase("dry_at")


## WHAT FALLS IN WATER SPLASHES (Parker 11-12: "the water should use the water shader and
## splash effects we use in del mar"): the rocks of a rock fall, the chunks of a broken
## plank, a loose barrel or boulder. (The climber's own splash is the zones'; a cart let
## loose makes its own.)
var _wet_things := {}  # instance id -> true while it is under a surface


func _tick_wettings() -> void:
	for sp in spawners:
		if not bool(peak._area_active.get(sp.area, true)):
			continue
		for row: Array in sp.live:
			if float(row[2]) < 0.0 and row[0] != null and is_instance_valid(row[0]):
				_wetting(row[0], float((sp.def as Dictionary).get("r", 0.45)) * 2.2)
	for row: Array in _debris:
		if is_instance_valid(row[0]):
			_wetting(row[0], 0.3)
	for id in bodies:
		var b: Dictionary = bodies[id]
		if bool(peak._area_active.get(b.area, true)):
			_wetting(b.rb, clampf((b.rb as RigidBody3D).mass / 40.0, 0.5, 1.4))
	if _wet_things.size() > 400:
		for id in _wet_things.keys():
			if not is_instance_id_valid(id):
				_wet_things.erase(id)


func _wetting(n: Node3D, size: float) -> void:
	var p := Vector2(n.position.x, n.position.y)
	var id := n.get_instance_id()
	if peak.zones.water_at(p) != null:
		if not _wet_things.has(id):
			_wet_things[id] = true
			peak.zones.splash_at(p, size)
	elif _wet_things.has(id):
		_wet_things.erase(id)


## A HOLD THAT LETS GO OF YOU ON A TIMER SHOWS IT (Parker 11-12, of the hot pipe joints:
## "what is the deal with this? There is no visual for what is going on", then "make it so
## there is obvious effects and stuff for what is going on, we can use particle effects if
## we need it"; and of the chimney's hot rock: "these have no indication of what is going
## on and no leading indicator"). A hot hold was a still orange knob with a sizzle half a
## second before your hand let go for no visible reason. One language for every such hold:
##   at rest     it pulses in colour and breathes a wisp now and then: it LOOKS hot;
##   held        it brightens toward white as the time runs out, the hand on it smokes
##               thicker and thicker, and in the last half second it spits and shudders;
##   it lets go  with a burst, the hand is flicked off, and the hand stays marked and
##               smoking for as long as it can't hold anything.
## No glowing materials (the house rule): heat is colour (the house shader's tint), steam
## and sparks. `cold` is the same language for the ice holds of the cableway and the
## glacier (frost, a crack, then it lets go): written, and NOT switched on, because Parker
## has not played those areas yet (TELL_COLD).
const TELLS := {
	"hot": {"rest": [Color(1.1, 1.2, 1.15), Color(1.07, 2.0, 2.3)], "full": Color(1.1, 2.9, 7.0),
		"wisp": "steam", "spit": "sparks", "hand_puff": "steam", "go": ["steam", "sparks", "sparks"], "after": "smoke",
		"hand": Color(1.0, 0.22, 0.08)},
	"cold": {"rest": [Color(1.0, 1.0, 1.0), Color(1.08, 1.12, 1.18)], "full": Color(1.5, 1.7, 1.9),
		"wisp": "frost", "spit": "frost", "hand_puff": "frost", "go": ["frost", "glitter"], "after": "frost",
		"hand": Color(0.6, 0.85, 1.0)},
}
const TELL_COLD := false
const TELL_NEAR := 28.0  # a hold this far from the climber is not animated
var _tell_t := {}  # limb index -> when it last smoked
var _burns: Array = []  # [the mark on the hand, the limb's end, until, the tell, next puff]


func _tell_of(h: Dictionary) -> Dictionary:
	if str(h.type) != "timed":
		return {}
	if float((h.def as Dictionary).t) < 1.8:
		return TELLS.hot
	return TELLS.cold if TELL_COLD else {}


## Where a hold is, in the course's metres.
func _hold_at(h: Dictionary) -> Vector2:
	var body: Node3D = h.body
	if body.has_meta("peak_pts"):
		return _hold_middle(body)
	return peak.local_of(Vector2(body.global_position.x, body.global_position.y))


func _hold_tint(h: Dictionary, c: Color) -> void:
	var was: Color = h.get("tint", Color(1, 1, 1))
	if absf(was.r - c.r) + absf(was.g - c.g) + absf(was.b - c.b) < 0.04:
		return
	h["tint"] = c
	var v: Node = h.vis
	var list: Array = v.get_children()
	list.append(v)
	for g in list:
		if g is GeometryInstance3D:
			(g as GeometryInstance3D).set_instance_shader_parameter(&"tint", c)


func _tick_tell(h: Dictionary, delta: float) -> void:
	var tell := _tell_of(h)
	if tell.is_empty() or peak.player == null or not bool(peak._area_active.get(h.area, true)):
		return
	var at := _hold_at(h)
	if peak.player_at().distance_to(at) > TELL_NEAR:
		return
	var t := peak.clock
	var heat := float(h.get("heat", 0.0))
	if t - float(h.get("held_at", -9.0)) > 0.05:
		heat = maxf(0.0, heat - delta / 0.5)  # (let go of, it cools in half a second)
		h["heat"] = heat
	var rest: Array = tell.rest
	var pulse := 0.5 + 0.5 * sin(t * 4.2 + at.x * 1.7 + at.y * 0.9)
	_hold_tint(h, (rest[0] as Color).lerp(rest[1], pulse).lerp(tell.full, heat * heat))
	var limit := float((h.def as Dictionary).t)
	var v: Node3D = h.vis
	if heat > 1.0 - 0.5 / maxf(limit, 0.6):
		v.position = Vector3(randf_range(-0.03, 0.03), randf_range(-0.03, 0.03), 0)  # the last half second: it shudders
		h["shook"] = true
	elif bool(h.get("shook", false)):
		v.position = Vector3.ZERO
		h["shook"] = false
	if t >= float(h.get("wisp_at", 0.0)):
		h["wisp_at"] = t + randf_range(1.0, 2.4)
		peak.zones.burst(at + Vector2(0, 0.15), str(tell.wisp), 0.5)
		if randf() < 0.35:
			peak.zones.burst(at, str(tell.spit), 0.3)


## The hand that was let go: marked (red for a burn, pale blue for cold) and smoking for
## as long as it can't hold anything.
func _burn_hand(i: int, end: RigidBody3D, tell: Dictionary, seconds: float) -> void:
	var mark := MeshInstance3D.new()
	var ball := SphereMesh.new()
	ball.radius = 0.15
	ball.height = 0.3
	mark.mesh = ball
	var col: Color = tell.hand
	mark.material_override = PeakZones._flat(col, 0.8)
	mark.position.z = 0.25
	mark.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	end.add_child(mark)
	_burns.append([mark, end, peak.clock + seconds, tell, 0.0])


func _tick_burns() -> void:
	var t := peak.clock
	for k in range(_burns.size() - 1, -1, -1):
		var row: Array = _burns[k]
		if not is_instance_valid(row[0]) or not is_instance_valid(row[1]) or t >= float(row[2]):
			if is_instance_valid(row[0]):
				(row[0] as Node).queue_free()
			_burns.remove_at(k)
			continue
		if t >= float(row[4]):
			row[4] = t + 0.09
			var end: RigidBody3D = row[1]
			peak.zones.burst(peak.local_of(Vector2(end.global_position.x, end.global_position.y)), str((row[3] as Dictionary).after), 0.5)


## IT CRUMBLES AWAY (Parker 11-12: "make the breaking floors crumble away instead of
## despawning"): the piece breaks into chunks that tumble and fall, knock about on the
## rock below, shrink and are gone. They touch the world, never the climber.
const DEBRIS_S := 2.6
var _debris: Array = []  # [RigidBody3D, born]


func _crumble(h: Dictionary) -> void:
	var body: Node3D = h.body
	if not body.has_meta("peak_pts"):
		return
	var pts: PackedVector2Array = body.get_meta("peak_pts")
	var zz: Vector2 = body.get_meta("peak_z", Vector2(-0.4, 0.4))
	var lo := pts[0]
	var hi := pts[0]
	for p in pts:
		lo = lo.min(p)
		hi = hi.max(p)
	var size := hi - lo
	var nx := clampi(int(size.x / 0.42), 1, 7)
	var ny := clampi(int(size.y / 0.42), 1, 4)
	var cell := Vector2(size.x / nx, size.y / ny)
	var depth := clampf(zz.y - zz.x, 0.3, 1.2)
	var col: Color = h.col
	var root: Node3D = body.get_parent()
	for ix in nx:
		for iy in ny:
			var c := lo + Vector2((ix + 0.5) * cell.x, (iy + 0.5) * cell.y)
			if not Geometry2D.is_point_in_polygon(c, pts):
				continue
			for half in 2:  # two chunks deep, so it breaks through its thickness too
				var rb := RigidBody3D.new()
				rb.collision_layer = 0
				rb.collision_mask = Climber.LAYER_WORLD
				rb.mass = 2.0
				rb.gravity_scale = 0.75
				rb.angular_damp = 0.3
				var chunk := Vector3(cell.x * randf_range(0.7, 0.95), cell.y * randf_range(0.7, 0.95), depth * 0.45)
				var cs := CollisionShape3D.new()
				var bx := BoxShape3D.new()
				bx.size = chunk
				cs.shape = bx
				rb.add_child(cs)
				rb.add_child(_chunk_look(chunk, col.darkened(randf_range(0.0, 0.14)), str(h.area)))
				rb.position = Vector3(c.x, c.y, (float(half) - 0.5) * depth * 0.5)
				rb.rotation = Vector3(randf_range(-0.3, 0.3), randf_range(-0.3, 0.3), randf_range(-0.5, 0.5))
				rb.linear_velocity = Vector3(randf_range(-1.2, 1.2), randf_range(-0.4, 1.4), randf_range(-0.6, 0.6))
				rb.angular_velocity = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-6, 6))
				root.add_child(rb)
				_debris.append([rb, peak.clock])
	while _debris.size() > 160:
		var old: Array = _debris.pop_front()
		if is_instance_valid(old[0]):
			(old[0] as Node).queue_free()


func _tick_debris() -> void:
	for i in range(_debris.size() - 1, -1, -1):
		var row: Array = _debris[i]
		var rb: RigidBody3D = row[0]
		if not is_instance_valid(rb):
			_debris.remove_at(i)
			continue
		var age := peak.clock - float(row[1])
		if age > DEBRIS_S:
			rb.queue_free()
			_debris.remove_at(i)
		elif age > DEBRIS_S - 0.6:
			rb.scale = Vector3.ONE * maxf(0.05, (DEBRIS_S - age) / 0.6)


## The middle of a hold's drawn piece, in its body's own space: its outline's box if it
## has one (a solid of the course), else its collision's (a mover's hold).
func _hold_middle(body: Node3D) -> Vector2:
	if body.has_meta("peak_pts"):
		var pts: PackedVector2Array = body.get_meta("peak_pts")
		if not pts.is_empty():
			var lo := pts[0]
			var hi := pts[0]
			for p in pts:
				lo = lo.min(p)
				hi = hi.max(p)
			return (lo + hi) * 0.5
	if body.get_child_count() > 0:
		return _body_centre(body)
	return Vector2.ZERO


func _body_centre(body: Node3D) -> Vector2:
	var lo := Vector3(INF, INF, INF)
	var hi := Vector3(-INF, -INF, -INF)
	for ch in body.get_children():
		if ch is CollisionShape3D and (ch as CollisionShape3D).shape is ConvexPolygonShape3D:
			for p in ((ch as CollisionShape3D).shape as ConvexPolygonShape3D).points:
				lo = lo.min(p)
				hi = hi.max(p)
	var mid := (lo + hi) * 0.5
	return Vector2(mid.x, mid.y)


# ---------------------------------------------------------------- the things that fall

## How many drops a source has made by second `ph` of the course's clock, and how long
## until its next: on a steady `period`, or on its WRITTEN RHYTHM (`times`: the seconds
## of a `loop`-second loop at which it drops. Parker 11-12 asked for a second more between
## the cave-in's rocks and a half more after a double: two free timers can't say that,
## a written list can).
static func _drops(def: Dictionary, ph: float) -> Array:
	if def.has("times"):
		var times: Array = def.times
		var loop := maxf(0.5, float(def.loop))
		var cyc := floorf(ph / loop)
		var within := ph - cyc * loop
		var k := 0
		while k < times.size() and float(times[k]) <= within:
			k += 1
		var next := (float(times[k]) - within) if k < times.size() else (loop - within + float(times[0]))
		return [int(cyc) * times.size() + k, next]
	var period := maxf(0.5, float(def.period))
	return [int(floor(ph / period)), period - fposmod(ph, period)]


const FALLER_G := 0.55  # a faller's gravity, against the engine's


## A live faller's row: [body (once thrown: just its look), the second it gives up, the second a board threw it (-1:
## not yet), its thrown velocity, its thrown spin, how long it has lain still, the depth
## it settles at, the height it is gone under].
func _tick_spawners(delta: float) -> void:
	var t := peak.clock
	var c := peak.player
	for sp in spawners:
		if not bool(peak._area_active.get(sp.area, true)):
			continue
		var def: Dictionary = sp.def
		var at := Peak.v2(def.at)
		var drops: Array = _drops(def, t + float(def.get("phase", 0.0)))
		var n: int = drops[0]
		var warn := float(def.get("warn", 1.2))
		var near := c != null and peak.player_at().distance_to(at) < 45.0
		if near and int(sp.warned) != n and float(drops[1]) < warn:
			sp.warned = n
			peak.audio.play("dust_trickle" if str(def.kind) in ["rock", "boulder"] else "ice_tick", at, 2.0)
		if int(sp.n) == -1:
			sp.n = n  # (the first tick only takes its place in the rhythm: every source used to drop at once on a load)
		if n != int(sp.n):
			sp.n = n
			if near:
				_spawn_faller(sp, def, at)
		_tick_coming(sp, def, at, float(drops[1]), near)
		var r := float(def.get("r", 0.45))
		var has_board := not _area_boards(str(sp.area)).is_empty()
		var keep: Array = []
		for row: Array in sp.live:
			if row[0] == null or not is_instance_valid(row[0]):
				continue
			if float(row[2]) >= 0.0:
				# Thrown by a board: it is scenery now (frame() flies it). The net under one
				# that never dropped out of sight:
				if t - float(row[2]) > 6.0:
					(row[0] as Node).queue_free()
					continue
				keep.append(row)
				continue
			var rb: RigidBody3D = row[0]
			var fp := Vector2(rb.position.x, rb.position.y)
			if has_board:
				# (a slab is a long box: it meets a board with its end, half its length from its middle)
				var board := _board_under(str(sp.area), fp, r * 3.0 if str(def.kind) == "slab" else r)
				if not board.is_empty():
					_board_throw(board, row)
					keep.append(row)
					continue
				# Where the fall has a board, nothing blinks out: a rock that gave up or came
				# to rest short of it breaks up where it lies.
				row[5] = (float(row[5]) + delta) if rb.linear_velocity.length() < 0.35 else 0.0
				if t > float(row[1]) or float(row[5]) > 1.5:
					_break_faller(rb, r)
					continue
			elif t > float(row[1]):
				if str(def.kind) == "icicle":
					_shatter_ice(rb, r)
				else:
					rb.queue_free()
				continue
			if c != null and _ko_wait <= 0.0 and c.knockout_left <= 0.0 and rb.linear_velocity.length() > 2.2:
				for pname in ["head", "chest", "pelvis"]:
					var b: RigidBody3D = c.bodies.get(pname)
					if b != null and peak.local_of(Climber.pos2(b)).distance_to(fp) < float(def.get("hit", r + 0.32)):
						_ko_wait = 2.5
						c.knock_out()
						peak.audio.play("rock_hit", fp, 3.0)
						peak.audio.play("knock_out_bonk", fp, 2.0)
						break
			# AN ICICLE SHATTERS ON THE FIRST SOLID THING IT LANDS ON (playtest note 86; Parker
			# 11-13: "Make them shatter on the floor"): nothing is left lying, so nothing can pin.
			if str(def.kind) == "icicle" and t - (float(row[1]) - float(def.get("life", 8.0))) > 0.05 \
					and not rb.get_colliding_bodies().is_empty():
				_shatter_ice(rb, r)
				continue
			keep.append(row)
		sp.live = keep


# ---------------------------------------------------------------- the board a rock fall leaves by

## A LITTLE MESSED UP BOARD (Parker 11-12: "the rocks shouldnt despawn, they should bounce
## into the background off a little messed up board"). A snapped board propped at the foot
## of a rock fall: solid grip to a climber, and a falling thing that touches it is thrown
## up and back behind the climb, where it can hit nobody, and is removed only once it has
## dropped out of sight. Data: `A.board(...)` in tools/peak/peaklib.py.
func _build_board(a: Dictionary, def: Dictionary, root: Node3D) -> void:
	var pts: Array = [Peak.v2(def.a), Peak.v2(def.b)]
	if def.has("c"):
		pts.append(Peak.v2(def.c))
	var thick := float(def.get("t", 0.13))
	var sb: StaticBody3D = peak._static_body(1.0)
	if str(def.get("kind", "wood")) != "wood":
		sb.set_meta("no_weld", true)  # (a lip of ice: nothing holds it)
	root.add_child(sb)
	# It dips about its prop when a rock lands on it: the drawn pieces hang off a pivot there.
	var pivot := Node3D.new()
	pivot.position = Vector3((pts[1] as Vector2).x, (pts[1] as Vector2).y, 0)
	root.add_child(pivot)
	for i in pts.size() - 1:
		var p0: Vector2 = pts[i]
		var p1: Vector2 = pts[i + 1]
		var along := (p1 - p0).normalized()
		if along.x < 0.0:
			along = -along  # (a board has no front: lay the model left to right)
		var half := Vector2(-along.y, along.x) * thick * 0.5
		peak._add_shapes(sb, PackedVector2Array([p0 - half, p1 - half, p1 + half, p0 + half]) if p1.x > p0.x else PackedVector2Array([p1 - half, p0 - half, p0 + half, p1 + half]), -0.45, 0.45)
		var mid := (p0 + p1) * 0.5
		var piece: Node3D = Peak.kit(str(def.get("model", "plank")))
		if piece != null:
			# (the kit's board is 2 m long, its zero the middle of its underside; a board's own model
			# says the length it was made to)
			piece.scale = Vector3(p0.distance_to(p1) / float(def.get("made", 2.0)), 1.0, 1.0)
			piece.position = Vector3(mid.x - half.x, mid.y - half.y, 0) - pivot.position
		else:
			piece = LuchaKit.box(Vector3(p0.distance_to(p1), thick, 0.9), peak.kind_color(a, str(def.get("kind", "wood"))).darkened(0.1 * i))
			piece.position = Vector3(mid.x, mid.y, 0) - pivot.position
		piece.rotation.z = atan2(along.y, along.x)
		pivot.add_child(piece)
	boards.append({"def": def, "area": str(a.id), "pts": pts, "pivot": pivot, "reach": thick * 0.5 + 0.1})


func _area_boards(area: String) -> Array:
	var out: Array = []
	for b in boards:
		if str(b.area) == area:
			out.append(b)
	return out


## The board a falling thing at `p` (radius r) is touching, or {}.
func _board_under(area: String, p: Vector2, r: float) -> Dictionary:
	for b in boards:
		if str(b.area) != area:
			continue
		var pts: Array = b.pts
		for i in pts.size() - 1:
			var near := Geometry2D.get_closest_point_to_segment(p, pts[i], pts[i + 1])
			if near.distance_to(p) < r + float(b.reach):
				return b
	return {}


func _board_throw(board: Dictionary, row: Array) -> void:
	var rb: RigidBody3D = row[0]
	var def: Dictionary = board.def
	# From here it is a drawn thing only: its look goes on without its body, so nothing
	# can touch it and the physics has no say in its flight.
	var fly := Node3D.new()
	fly.transform = rb.transform
	rb.get_parent().add_child(fly)
	for ch in rb.get_children():
		if not ch is CollisionShape3D:
			rb.remove_child(ch)
			fly.add_child(ch)
	rb.queue_free()
	row[0] = fly
	row[2] = peak.clock
	row[3] = Vector3(float(def.throw[0]) * randf_range(0.8, 1.25), float(def.throw[1]) * randf_range(0.92, 1.1), float(def.throw[2]) * randf_range(0.9, 1.1))
	row[4] = Vector3(randf_range(-3.0, 3.0), randf_range(-2.0, 2.0), randf_range(3.0, 7.0))
	row[6] = float(def.depth)
	row[7] = float(def.gone)
	row.append(def.get("burst", []))  # [8]: what it bursts into where it is gone
	var at := Vector2(fly.position.x, fly.position.y)
	peak.audio.play("kick_thwack", at, -5.0, randf_range(0.8, 0.95))
	peak.audio.play("plank_creak", at, -3.0)
	# The board dips under the rock and springs back.
	var pivot: Node3D = board.pivot
	var dip := -0.16 if ((board.pts[0] as Vector2).x > (board.pts[1] as Vector2).x) else 0.16
	var tw := pivot.create_tween()
	tw.tween_property(pivot, "rotation:z", dip, 0.07)
	tw.tween_property(pivot, "rotation:z", 0.0, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


## A thrown faller's flight, every drawn frame: up and back, to its depth behind the
## climb, then down out of sight.
func _fly_thrown(delta: float) -> void:
	for sp in spawners:
		for row: Array in sp.live:
			if float(row[2]) < 0.0 or row[0] == null or not is_instance_valid(row[0]):
				continue
			var rb: Node3D = row[0]
			var v: Vector3 = row[3]
			v.y -= 9.8 * FALLER_G * delta
			var p := rb.position + v * delta
			var depth := float(row[6])
			if p.z <= depth:
				p.z = depth
				v.z = 0.0
			row[3] = v
			rb.position = p
			rb.rotation += (row[4] as Vector3) * delta
			# Smaller as it goes back (the camera is close: the depth alone hardly shows).
			var s := lerpf(1.0, 0.6, clampf(p.z / minf(depth, -0.01), 0.0, 1.0))
			rb.scale = Vector3(s, s, s)
			if p.y < float(row[7]) and v.y < 0.0:
				# (a slab bursts in the hollow it was thrown into: note 91)
				if row.size() > 8:
					for kind in (row[8] as Array):
						peak.zones.burst(Vector2(p.x, p.y), str(kind), 1.6, Vector2.UP, p.z + 0.3)
					if not (row[8] as Array).is_empty():
						peak.audio.play("snow_whump", Vector2(p.x, p.y), -4.0)
				rb.queue_free()
				row[0] = null


## WHAT FALLS IS SEEN COMING (playtest notes 86 and 93; Parker 11-13: "Make the falling
## icicles grow before they fall", "make the ice blocks come out of a hole in the wall").
## An icicle grows at its source over its last ICICLE_GROW seconds, shivers in the last
## SHIVER_S, then drops. A snow slab sits in a dark mouth in the ice at its source and
## creeps out of it during its warning, then tips out and goes. Each is a drawn piece only
## (nothing to touch) until the real faller takes its place.
const ICICLE_GROW := 2.6  # s
const COMING_SHIVER := 0.4  # s
const SLAB_CREEP := 1.6  # m: how far up the chute, set back in the mouth, a slab starts its creep


func _tick_coming(sp: Dictionary, def: Dictionary, at: Vector2, next: float, near: bool) -> void:
	var kind := str(def.kind)
	if kind != "icicle" and kind != "slab":
		return
	var r := float(def.get("r", 0.45))
	if not sp.has("pre"):
		var root: Node3D = sp.root
		var pre := Node3D.new()
		var look: Node3D
		if kind == "icicle":
			look = _falling_icicle(r)
			pre.position = Vector3(at.x, at.y + r * 1.5, 0)
		else:
			look = _slab_look(r)
			pre.position = Vector3(at.x, at.y, 0)
		if kind == "slab" and not LuchaKit.kit_model_exists("glaciar_slab_mouth"):
			# The mouth in the ice the slabs come out of: a dark hole a little bigger than a slab.
			# (Once a9_dress's glaciar_slab_mouth lands, that is the mouth: the dress places it.)
			var mouth := Node3D.new()
			var hole := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 1.0
			cm.bottom_radius = 1.0
			cm.height = 0.05
			cm.radial_segments = 20
			hole.mesh = cm
			hole.rotation.x = PI * 0.5
			hole.scale = Vector3(r * 3.8, 1.0, r * 2.2)
			hole.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			CelPass.paint(hole, Color("#1C2A44"))
			mouth.add_child(hole)
			mouth.position = Vector3(at.x, at.y + r * 0.3, -Peak.HALF - 0.6)
			root.add_child(mouth)
		pre.add_child(look)
		pre.visible = false
		root.add_child(pre)
		sp["pre"] = pre
		sp["pre_dir"] = Peak.v2(def.get("vel", [1, -1])).normalized()
	var pre: Node3D = sp.pre
	var lead := ICICLE_GROW if kind == "icicle" else float(def.get("warn", 1.2))
	if not near or next > lead:
		pre.visible = false
		return
	pre.visible = true
	var f := clampf(1.0 - next / maxf(lead, 0.01), 0.0, 1.0)
	var jig := Vector3.ZERO
	if next < COMING_SHIVER:
		jig = Vector3(randf_range(-0.03, 0.03), randf_range(-0.02, 0.02), 0)
	if kind == "icicle":
		var s := lerpf(0.08, 1.0, f)
		pre.scale = Vector3(lerpf(0.4, 1.0, f), s, lerpf(0.4, 1.0, f))
		pre.position = Vector3(at.x, at.y + r * 1.5, 0) + jig
	else:
		var back: Vector2 = -(sp.pre_dir as Vector2) * SLAB_CREEP * (1.0 - f)
		pre.position = Vector3(at.x + back.x, at.y + back.y, -(Peak.HALF + 0.6) * (1.0 - f)) + jig


## AN ICICLE THAT FALLS IS NOT ONE THAT HOLDS (playtest note 86; a9_dress item 6e): smooth, sharp, no
## rings and no collar, made to the faller's capsule (r * 0.4 by r * 3.0) with its tip drawn past it.
## Its zero is its top (where it hangs from its crack). Until `glaciar_icicle_falling` lands it is a
## plain cone of the same size: never the kit's 2.5 m ringed icicle_big, which is a holding icicle.
func _falling_icicle(r: float) -> Node3D:
	var look := LuchaKit.kit_model("glaciar_icicle_falling")
	if look != null:
		return look
	look = Node3D.new()
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = r * 0.4
	cm.bottom_radius = 0.02
	cm.height = r * 3.0 + 0.25
	cm.radial_segments = 12
	mi.mesh = cm
	mi.position.y = -cm.height * 0.5
	CelPass.paint(mi, Color("#9FDDF2"))
	look.add_child(mi)
	return look


## A snow slab's look (a9_dress item 8: `glaciar_snow_slab`, made to the game's slab), zero its middle.
func _slab_look(r: float) -> Node3D:
	var look := LuchaKit.kit_model("glaciar_snow_slab")
	if look != null:
		return look
	return LuchaKit.box(Vector3(r * 6.0, r * 1.6, Peak.HALF * 1.6), Color("#F4F7FA"))


## An icicle that lands breaks into harmless pieces (they touch the world, never you).
func _shatter_ice(rb: RigidBody3D, r: float) -> void:
	var root: Node3D = rb.get_parent()
	var at := rb.position
	rb.queue_free()
	for i in 7:
		var ch := RigidBody3D.new()
		ch.collision_layer = 0
		ch.collision_mask = Climber.LAYER_WORLD
		ch.mass = 1.0
		ch.gravity_scale = 0.75
		var size := Vector3(r * randf_range(0.25, 0.45), r * randf_range(0.35, 0.8), r * randf_range(0.25, 0.4))
		var cs := CollisionShape3D.new()
		var bx := BoxShape3D.new()
		bx.size = size
		cs.shape = bx
		ch.add_child(cs)
		ch.add_child(_chunk_look(size, Color("#BFE8F6").darkened(randf_range(0.0, 0.15)), "a9"))  # (icicles are the glacier's)
		ch.position = at + Vector3(randf_range(-r, r) * 0.6, randf_range(-r, r) * 0.6, randf_range(-0.2, 0.2))
		ch.linear_velocity = Vector3(randf_range(-2.2, 2.2), randf_range(0.6, 2.6), randf_range(-0.6, 0.6))
		ch.angular_velocity = Vector3(randf_range(-6, 6), randf_range(-6, 6), randf_range(-8, 8))
		root.add_child(ch)
		_debris.append([ch, peak.clock - DEBRIS_S * 0.45])  # (ice goes quicker than rock)
	var p := Vector2(at.x, at.y)
	peak.zones.burst(p, "glitter", 1.0)
	peak.zones.burst(p, "frost", 0.8)
	peak.audio.play("ice_shatter", p, 0.0)


## A faller that never reached its board breaks up where it lies (chunks that tumble,
## shrink and are gone, as a breaking hold's do).
func _break_faller(rb: RigidBody3D, r: float) -> void:
	var root: Node3D = rb.get_parent()
	var at := rb.position
	rb.queue_free()
	for i in 6:
		var ch := RigidBody3D.new()
		ch.collision_layer = 0
		ch.collision_mask = Climber.LAYER_WORLD
		ch.mass = 2.0
		ch.gravity_scale = 0.75
		var size := Vector3.ONE * r * randf_range(0.45, 0.7)
		var cs := CollisionShape3D.new()
		var bx := BoxShape3D.new()
		bx.size = size
		cs.shape = bx
		ch.add_child(cs)
		ch.add_child(LuchaKit.box(size, Color("#8C7B6C").darkened(randf_range(0.0, 0.2))))
		ch.position = at + Vector3(randf_range(-r, r) * 0.5, randf_range(-r, r) * 0.5, randf_range(-0.3, 0.3))
		ch.linear_velocity = Vector3(randf_range(-1.6, 1.6), randf_range(0.4, 2.2), randf_range(-0.6, 0.6))
		ch.angular_velocity = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-6, 6))
		root.add_child(ch)
		_debris.append([ch, peak.clock])
	peak.audio.play("rock_crumble", Vector2(at.x, at.y), 0.0)


func _spawn_faller(sp: Dictionary, def: Dictionary, at: Vector2) -> void:
	var kind := str(def.kind)
	var r := float(def.get("r", 0.45))
	var rb := RigidBody3D.new()
	rb.mass = float(def.get("mass", 30.0))
	rb.collision_layer = Climber.LAYER_PROP
	rb.collision_mask = Climber.LAYER_WORLD
	rb.axis_lock_linear_z = true
	rb.axis_lock_angular_x = true
	rb.axis_lock_angular_y = true
	rb.gravity_scale = FALLER_G
	rb.linear_damp = 0.02
	var cs := CollisionShape3D.new()
	var vis: Node3D = null
	var col := Color("#8C7B6C")
	match kind:
		"icicle":
			var cap := CapsuleShape3D.new()
			cap.radius = r * 0.4
			cap.height = r * 3.0
			cs.shape = cap
			col = Color("#9FDDF2")
			vis = _falling_icicle(r)
			vis.position.y = r * 1.5  # (its zero is its top)
		"slab":
			var bx := BoxShape3D.new()
			bx.size = Vector3(r * 6.0, r * 1.6, Peak.HALF * 1.6)
			cs.shape = bx
			col = Color("#F4F7FA")
			vis = _slab_look(r)
			rb.mass *= 4.0
		_:
			var sph := SphereShape3D.new()
			sph.radius = r
			cs.shape = sph
			vis = LuchaKit.kit_model("boulder")
			if vis == null:
				vis = LuchaKit.ball(r, col)
			else:
				vis.scale = Vector3.ONE * (r / 0.6)
	rb.add_child(cs)
	rb.add_child(vis)
	rb.position = Vector3(at.x, at.y, 0)
	if kind == "icicle":
		rb.contact_monitor = true  # (it shatters on the first solid thing it touches)
		rb.max_contacts_reported = 4
	var v := Peak.v2(def.get("vel", [0, 0]))
	rb.linear_velocity = Vector3(v.x, v.y, 0)
	(sp.root as Node3D).add_child(rb)
	sp.live.append([rb, peak.clock + float(def.get("life", 8.0)), -1.0, Vector3.ZERO, Vector3.ZERO, 0.0, 0.0, 0.0])
	peak.audio.play("icicle_drop" if kind == "icicle" else ("snow_whump" if kind == "slab" else "rock_crumble"), at, 1.0)
