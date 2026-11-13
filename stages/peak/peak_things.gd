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
const ROPE_MASS := {"rope": 3.6, "chain": 6.6, "vine": 3.0, "cable": 6.0, "banner": 2.7}
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
var statues: Array = []
var _anchors := {}  # area id -> StaticBody3D the joints tie to
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
	for m in a.get("movers", []):
		_build_mover(a, m, root)
	for b in a.get("bodies", []):
		_build_body(a, b, root)
	for r in a.get("ropes", []):
		_build_rope(a, r, root)
	for s in a.get("spawners", []):
		spawners.append({"def": s, "area": str(a.id), "root": root, "n": -1, "live": [], "warned": -1})
	for s in a.get("statues", []):
		_build_statue(a, s, root)


func add_hold(body: CollisionObject3D, def: Dictionary, vis: Node3D, col: Color, slick: Color, a: Dictionary) -> void:
	var h := {"body": body, "def": def, "vis": vis, "col": col, "slick": slick, "area": str(a.id),
		"type": str(def.type), "break_at": -1.0, "back_at": -1.0, "wet": false, "layer": body.collision_layer}
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
		rb.mass = float(ROPE_MASS.get(kind, 1.2)) * (2.0 if planks else 1.0)
		rb.collision_layer = Climber.LAYER_WORLD
		rb.collision_mask = 0
		rb.axis_lock_linear_z = true
		rb.axis_lock_angular_x = true
		rb.axis_lock_angular_y = true
		rb.linear_damp = 0.25
		rb.angular_damp = 1.2
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
		bob.linear_damp = 0.15
		bob.angular_damp = 1.0
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


func sleep_all() -> void:
	for sp in spawners:
		for row in sp.live:
			if is_instance_valid(row[0]):
				(row[0] as Node).queue_free()
		sp.live.clear()


# ================================================================ tick

func tick(delta: float) -> void:
	_ko_wait = maxf(0.0, _ko_wait - delta)
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
	_tick_strain(delta)
	_tick_holds(delta)
	_tick_debris()
	_tick_spawners(delta)


func frame(_delta: float) -> void:
	pass


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
		node.transform = Transform3D(Basis(Vector3.BACK, float(m.angle)), Vector3(pos.x, pos.y, 0))
	if bool((m.def as Dictionary).get("ko", false)):
		_mover_ko(m)


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
					if not bool(_grip_warned[i]) and float(_grip_t[i]) > limit - 0.5:
						_grip_warned[i] = true
						peak.audio.play("sizzle" if hot else "ice_tick", at)
					if float(_grip_t[i]) >= limit:
						c.release(i)
						l.regrip = float(def.get("rearm", 0.6))
						_grip_on.erase(i)
						peak.audio.play("steam_hiss" if hot else "ice_crack", at, -3.0)
				"crumble":
					if float(h.break_at) < 0.0 and float(h.back_at) < 0.0:
						h.break_at = t + float(def.t)
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
				if float(h.break_at) >= 0.0 and t >= float(h.break_at):
					h.break_at = -1.0
					h.back_at = t + float((h.def as Dictionary).get("respawn", 8.0))
					_release_from([body])
					body.collision_layer = 0
					(h.vis as Node3D).visible = false
					(h.vis as Node3D).position = Vector3.ZERO
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
					v.scale = Vector3(0.05, 0.05, 1.0)
					v.create_tween().tween_property(v, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			"wet":
				var def: Dictionary = h.def
				var on := float(def.get("on", 2.0))
				var wet := fposmod(t + float(def.get("phase", 0.0)), on + float(def.get("off", 3.0))) < on
				if wet != bool(h.wet):
					h.wet = wet
					if wet:
						body.set_meta("no_weld", true)
						_release_from([body])
					else:
						body.remove_meta("no_weld")
					if (h.vis as Node).has_meta("fitted"):
						PeakFit.set_wet(h.vis, str(body.get_meta("slick_class", "mud")) if wet else "")
					elif h.vis is GeometryInstance3D:
						if wet:
							(h.vis as GeometryInstance3D).material_override = Peak.slick_material(str(body.get_meta("slick_class", "mud")))
						else:
							CelPass.paint(h.vis, h.col as Color)


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

func _tick_spawners(delta: float) -> void:
	var t := peak.clock
	var c := peak.player
	for sp in spawners:
		if not bool(peak._area_active.get(sp.area, true)):
			continue
		var def: Dictionary = sp.def
		var period := maxf(0.5, float(def.period))
		var at := Peak.v2(def.at)
		var ph := t + float(def.get("phase", 0.0))
		var n := int(floor(ph / period))
		var warn := float(def.get("warn", 1.2))
		var near := c != null and peak.player_at().distance_to(at) < 45.0
		if near and int(sp.warned) != n and fposmod(ph, period) > period - warn:
			sp.warned = n
			peak.audio.play("dust_trickle" if str(def.kind) in ["rock", "boulder"] else "ice_tick", at, 2.0)
		if n != int(sp.n):
			sp.n = n
			if near:
				_spawn_faller(sp, def, at)
		var keep: Array = []
		for row in sp.live:
			var rb: RigidBody3D = row[0]
			if not is_instance_valid(rb):
				continue
			if t > float(row[1]):
				rb.queue_free()
				continue
			keep.append(row)
			if c != null and _ko_wait <= 0.0 and c.knockout_left <= 0.0 and rb.linear_velocity.length() > 2.2:
				var fp := peak.local_of(Vector2(rb.global_position.x, rb.global_position.y))
				for pname in ["head", "chest", "pelvis"]:
					var b: RigidBody3D = c.bodies.get(pname)
					if b != null and peak.local_of(Climber.pos2(b)).distance_to(fp) < float(def.get("r", 0.45)) + 0.32:
						_ko_wait = 2.5
						c.knock_out()
						peak.audio.play("rock_hit", fp, 3.0)
						peak.audio.play("knock_out_bonk", fp, 2.0)
						break
		sp.live = keep


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
	rb.gravity_scale = 0.55
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
	sp.live.append([rb, peak.clock + float(def.get("life", 8.0))])
	peak.audio.play("icicle_drop" if kind == "icicle" else ("snow_whump" if kind == "slab" else "rock_crumble"), at, 1.0)
