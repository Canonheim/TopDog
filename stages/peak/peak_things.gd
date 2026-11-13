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
const ROPE_MASS := {"rope": 0.3, "chain": 0.5, "vine": 0.3, "cable": 0.5, "banner": 0.25}
const PLANK_MASS := 7.2  # a bridge's planks are stood on, not swung on: as they were
const ROPE_DAMP := 0.03
const ROPE_SPIN_DAMP := 0.15
const ROPE_REACH := 0.17  # a free hand or foot this near a rope takes it
const ROPE_TONE := {"rope": "#C9A36A", "chain": "#B5532A", "vine": "#7FA04A", "cable": "#B9B2A6", "banner": "#C9A36A"}
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
	var mo: Dictionary = def.motion
	var m := {"id": str(def.id), "def": def, "area": str(a.id), "home": home, "nodes": nodes, "vis": vis, "mo": mo, "type": str(mo.type),
		"offset": Vector2.ZERO, "angle": 0.0, "lo": lo, "hi": hi, "run": false, "dist": 0.0, "v": 0.0, "arrived": -1.0,
		"board_t": 0.0, "tip_t": -1.0, "prog": 0.0, "prev": home, "speed": 0.0, "active": true}
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
	if def.has("hold"):
		add_hold(nodes[0], def.hold, vis, Color.WHITE, peak.tone(a, "slick"), a)
	movers[m.id] = m


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
		if planks:
			var bx := BoxShape3D.new()
			bx.size = Vector3(0.12, maxf(0.1, seg_len - 0.06), 1.0)
			cs.shape = bx
			var bm := BoxMesh.new()
			bm.size = Vector3(0.1, maxf(0.1, seg_len - 0.08), 0.9)
			mi.mesh = bm
			CelPass.paint(mi, Color("#B07A32"))
		else:
			var cap := CapsuleShape3D.new()
			cap.radius = SEG_R
			cap.height = seg_len + SEG_R * 2.0
			cs.shape = cap
			var bm := BoxMesh.new()
			var wide := 0.085 if kind != "chain" else (0.11 if i % 2 == 0 else 0.07)
			bm.size = Vector3(wide, seg_len + 0.02, wide)
			mi.mesh = bm
			CelPass.paint(mi, col)
		rb.add_child(cs)
		rb.add_child(mi)
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
		"planks": planks, "seg_len": seg_len, "top": top, "reach": length + 2.0})


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
	_tick_levers(delta)
	_tick_strain(delta)
	_tick_holds(delta)
	_tick_burns()
	_tick_strays()
	_tick_debris()
	_tick_spawners(delta)
	_tick_wettings()


func frame(delta: float) -> void:
	_fly_thrown(delta)


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
		"limb": -1, "thrown": false, "turn": turn})


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
	for i in c.limbs.size():
		if c.limbs[i].grab_other == null:
			continue
		stuck += 1
		var v: float = (c.bodies[c.limbs[i].def.end] as RigidBody3D).linear_velocity.length()
		fastest_v = maxf(fastest_v, v)
		if v < slowest_v:
			slowest_v = v
			slowest = i
	if stuck < 2 or fastest_v < 0.4 or fastest_v - slowest_v < 0.3:
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
	var at := peak.local_of(c.limb_end(slowest))
	c.release(slowest)
	c.limbs[slowest].regrip = 0.5
	Sound.play_at("grip", Vector3(c.limb_end(slowest).x, c.limb_end(slowest).y, 0), -2.0)
	peak.audio.play("rope_creak", at, -6.0)


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
				var d := p.distance_to(sp + axis * along)
				if d < best_d:
					best_d = d
					best = seg
		if best != null:
			c.attach(i, best)
			peak.audio.play("rope_creak", peak.local_of(p), -4.0)


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
						# wall, and can't be touched until it is in the play plane.
						var em: Dictionary = mo.emerge
						var f := clampf(d / maxf(0.1, float(em.over)), 0.0, 1.0)
						m["zoff"] = float(em.depth) * (1.0 - _ease(f))
					var solid := not bool(m.get("shed", false)) and absf(float(m.get("zoff", 0.0))) < 0.45
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
					if m.run:
						var acc := float(mo.get("accel", 0.0))
						m.v = speed if acc <= 0.0 else minf(speed, float(m.v) + acc * delta)
						m.dist = float(m.dist) + float(m.v) * delta
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
				m.angle = lerp_angle(float(m.angle), want, 1.0 - exp(-delta * 6.0))
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
			if float(m.tip_t) < 0.0:
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
	for node: AnimatableBody3D in m.nodes:
		node.transform = Transform3D(Basis(Vector3.BACK, float(m.angle)), Vector3(pos.x, pos.y, float(m.get("zoff", 0.0))))
	if bool((m.def as Dictionary).get("ko", false)):
		_mover_ko(m)
	if str(m.type) in ["cycle", "path"]:
		_wall_wipe(m)
		if (m.def as Dictionary).has("socket") and str(m.type) == "cycle":
			_socket_tell(m)


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
					if h.has("cracks"):
						(h.cracks as Node3D).visible = false  # (it comes back cracked as it was, no worse)
						var mid2 := _hold_at(h)
						peak.zones.burst(mid2, "glitter" if str(h.kind) == "crazed" else "dust", 1.6)
						if str(h.kind) == "rusty":
							peak.zones.burst(mid2, "sparks", 0.8)
							peak.audio.play("hammer_clang", mid2, -4.0, 0.8)
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
					if near_me:
						# The drip lands on it (a splash of drops, a drip's sound); or the
						# last drops fall as it dries, and its colour comes back over a moment.
						peak.zones.burst(_hold_at(h), "drops", 1.0 if wet else 0.6)
						if wet:
							peak.audio.play("drip", _hold_at(h), -4.0)
						else:
							h["dry_at"] = t
				if near_me and wet and t >= float(h.get("drop_at", 0.0)):
					h["drop_at"] = t + 0.3
					peak.zones.burst(_hold_at(h) + Vector2(randf_range(-0.15, 0.15), -0.2), "drops", 0.35, Vector2.DOWN)
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
				rb.add_child(LuchaKit.box(chunk, col.darkened(randf_range(0.0, 0.14))))
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
				var board := _board_under(str(sp.area), fp, r)
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
				rb.queue_free()
				continue
			keep.append(row)
			if c != null and _ko_wait <= 0.0 and c.knockout_left <= 0.0 and rb.linear_velocity.length() > 2.2:
				for pname in ["head", "chest", "pelvis"]:
					var b: RigidBody3D = c.bodies.get(pname)
					if b != null and peak.local_of(Climber.pos2(b)).distance_to(fp) < float(def.get("hit", r + 0.32)):
						_ko_wait = 2.5
						c.knock_out()
						peak.audio.play("rock_hit", fp, 3.0)
						peak.audio.play("knock_out_bonk", fp, 2.0)
						break
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
			# (the kit's board is 2 m long, its zero the middle of its underside)
			piece.scale = Vector3(p0.distance_to(p1) / 2.0, 1.0, 1.0)
			piece.position = Vector3(mid.x - half.x, mid.y - half.y, 0) - pivot.position
		else:
			piece = LuchaKit.box(Vector3(p0.distance_to(p1), thick, 0.9), peak.kind_color(a, "wood").darkened(0.1 * i))
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
				rb.queue_free()
				row[0] = null


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
			vis = LuchaKit.kit_model("icicle_big")
			if vis == null:
				vis = LuchaKit.cyl(r * 0.4, r * 3.0, col)
			else:
				vis.position.y = r * 1.5
		"slab":
			var bx := BoxShape3D.new()
			bx.size = Vector3(r * 6.0, r * 1.6, Peak.HALF * 1.6)
			cs.shape = bx
			col = Color("#F4F7FA")
			vis = LuchaKit.box(Vector3(r * 6.0, r * 1.6, Peak.HALF * 1.6), col)
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
	var v := Peak.v2(def.get("vel", [0, 0]))
	rb.linear_velocity = Vector3(v.x, v.y, 0)
	(sp.root as Node3D).add_child(rb)
	sp.live.append([rb, peak.clock + float(def.get("life", 8.0)), -1.0, Vector3.ZERO, Vector3.ZERO, 0.0, 0.0, 0.0])
	peak.audio.play("icicle_drop" if kind == "icicle" else ("snow_whump" if kind == "slab" else "rock_crumble"), at, 1.0)
