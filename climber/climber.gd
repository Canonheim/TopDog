class_name Climber
extends Node
## THE CLIMBER: one physical knight. 16 RigidBody3D pieces on 15 hinge joints,
## every piece locked to the play plane (z = 0): it moves in x/y and turns about z
## only, so it plays exactly flat and looks fully 3D.
##
## Physics: Jolt. Godot 2D's pins were tried first and failed the P1 spike (no
## working angle limits; joints stretched 0.3-1.4 m under swings). The record is
## docs/BOOK.md "The physics call" and docs/spike/.
##
## The rules it plays by (the reference game's, Parker 2026-11-07):
## - A hand or foot that is NOT held sticks to whatever it touches, by itself, and
##   stays stuck. Pressing its button picks it up (unsticks it); while held it aims
##   where the driver says (stick or mouse) and cannot stick. Letting go plants it:
##   if it's on something, it sticks right there.
## - A held limb only DRIVES while you're attached by something else: another hand
##   or foot stuck, or another climber holding you. Pick up your last stuck limb
##   in midair and you fall. On landing, loose limbs settle into a passive grip.
## - The torso is three pieces with springy left/right flex. With one grip the
##   active limb can swing the whole body about the planted end.
## - freeze() turns every piece static where it is: the body joins the tower.
##
## THE DRAG (the reference game's model, read off it by playing it, 2026-11-07):
## holding a limb PULLS ITS HAND OR FOOT toward the target (the mouse point, or the
## pad's steered point) with a strong elastic pull, capped at Feel drag_strength
## body-weights. Nothing aims the joints: the pulled hand drags the arm straight
## toward the target and the body after it. Every joint has FRICTION (a Jolt hinge
## motor holding still with a capped torque), so the body keeps whatever pose it's
## pushed into, and under a pull the knees and elbows buckle sideways, either way.
## The pulled limb's own joints are nearly free so it follows the pull. The torso's
## two spine joints and the neck are soft springs. Elbows and knees turn all the
## way round, through themselves, against THE SOFT FOLD.

const Layout := preload("res://climber/body_layout.gd")

const LAYER_WORLD := 1
const LAYER_LIVE := 2
const LAYER_FROZEN := 4
const LAYER_PROP := 8
const SOLID_MASK := LAYER_WORLD | LAYER_LIVE | LAYER_FROZEN
const DEPTH := 0.24  # how thick a box piece is through the plane, for contacts (m)
## THE SOFT FOLD (Parker 11-08): elbows and knees turn a full 360 degrees again,
## but folding through the joint meets resistance from FOLD_START degrees of bend,
## strongest at 180 (Feel fold_resistance). Past 180 it helps you through, so a
## limb rotated around comes easily and a straight pull back inward doesn't.
const ANKLE_LIMIT_DEG := 30.0  # feet turn at most this far either way from the shin (Parker 11-09)
const WRIST_LIMIT_DEG := 30.0  # hands the same from the forearm (Parker 11-09, with THE SLIP)
## THE SLIP (Parker 11-09): a stuck hand or foot turns on what it holds once its wrist
## or ankle comes this close to the stop, so the body still swings all the way round it.
const SLIP_EDGE_DEG := 3.0
const WRIST_CLOSE_RATE := 4.0  # a let-go hand's stop closes back to 30 degrees this fast (rad/s)
const SLAP_QUIET_S := 0.6  # no slaps for this long after spawning (the feet settle)
## THE ROPES (Parker 11-08: "the ropes on the side of the ring to bounce you if you
## run into them, with more force than you hit them with"): the side ropes stand at
## +-rope_x, between ROPE_LOW and ROPE_HIGH above the canvas. Set by Game from the
## stage; 0 = no ropes (tests, the dock).
static var rope_x := 0.0
const ROPE_LOW := 0.15
const ROPE_HIGH := 1.55
const ROPE_COOLDOWN := 0.25
var _rope_wait := 0.0
const FOLD_START_DEG := 150.0  # the old stop's angle: everything before it is free
const FOLD_REACH_DEG := 150.0  # the folded reach the steering keeps clear of the root
## The engine's hinge sign conventions, pinned by the --spike "signs" test.
const MOTOR_SIGN := -1.0  # Jolt: a positive motor velocity spins the child CW (pinned by --spike signs)
const LIMIT_FLIP := true  # Jolt: the hinge angle runs clockwise about +z (pinned by --spike signs)

enum State { LIVE, PUPPET, FROZEN }

signal froze(climber: Climber)
signal limb_selected(index: int, release_velocity: Vector3)
signal grab_lost(climber: Climber, limb: int)
signal rope_bounced(at: Vector3, speed: float)
signal grab_made(climber: Climber, limb: int, other: Object)
signal release_contact(position: Vector3)
signal exerted
signal knocked_out
signal knockout_changed(active: bool)

var state := State.LIVE
var climber_id := 0
var local_slot := -1  # the local Players slot driving this climber, or -1
var owner_peer := 1
var player_id := 0
var display_name := "Climber"
var tint := Color(1, 1, 1)
## Something with held(limb: int) -> bool, aim(climber, limb: int) -> Variant
## (null = keep the pose; {"dir": Vector2, "mag": float}; or {"point": Vector2}),
## lock_pressed() -> bool. See climber/drivers.gd.
var driver: Object = null

var body_scale := 0.9
var bodies := {}  # piece name -> RigidBody3D
## LIVE CLIMBERS GRAB EACH OTHER (Parker's call 10; taken out in 0.3.30, put back
## 11-08: "Dan took out grabbing people. Put it back in").
var grabbed_by := 0  # grabs other climbers hold on me (local joints)
var held_by: Array = []  # the climbers holding me (one entry per grab), for THE GROUNDED GROUP
var puppet_on_support := false
var remote_grabbed := 0  # grabs on me reported from other machines
## Online: forces other machines' climbers put on my pieces, piece -> Vector2 (N).
var remote_pulls := {}
var joints := {}  # joint name -> Dictionary
var limbs: Array = []  # per limb: Dictionary (see _build_limbs)
var total_mass := 0.0
var spawn_at := Vector2.ZERO
const KNOCKOUT_DURATION := 1.6
var knockout_left := 0.0
var knockout_stars: Node3D
const KnockoutStars := preload("res://climber/knockout_stars.gd")
var _impact_guard := 0.0
var _pull_load := 0.0
var _incoming_pull := 0.0
var remote_support := false
var live_time := 0.0
var removed := false
## THE PEAK (stages/peak). In water (`float_mode`) the limbs work with nothing gripped,
## and what a held limb pulls with is paid by the chest, so only the water's push on a
## moving hand carries the body: that's the swim. `scramble` is the Peak's softlock
## net: lying on slick with nothing to hold, a weak pull that drags along the ground.
var float_mode := false
var scramble := false
var support_extra: bool:
	get:
		return float_mode or scramble
var _shape_geo := {}  # piece -> [kind, data...] for height reads (local, m)
var _grunt_wait := 2.0
var _active_limb := -1
var _neutral_angles := {}
var _buttons_down := [false, false, false, false]
var _gravity_scale := -1.0
var _root: Node3D
var _glyphs: Array = []  # per limb: the Sprite3D / Label3D riding the hand or foot
var _hand_meshes := {}  # hand piece -> [mesh, its rest transform on the body]: THE DRAWN WRIST
var _wrists := {}  # hand piece -> [forearm body, hand body, the wrist in the forearm's frame]
## THE GROW-IN (Parker 11-10): "when a players spawns, make them grow from nothing at
## ground level and get bigger, pushing anything in their way out of the way... Grow
## over the time frame of .3 seconds". While it runs the pieces are held (no physics,
## no collisions) and drawn scaled about the feet, and an invisible block the climber's
## size grows with them, shoving climbers, the chair and the partner aside.
const GROW_S := 0.3
var _grow_t := -1.0  # seconds into the grow-in; < 0 = not growing
var _grow_full := {}  # piece -> its full-size Transform3D
var _grow_kids := {}  # Node3D child of a piece -> its full-size local transform
var _grow_block: StaticBody3D = null
var _grow_box: BoxShape3D = null
var _grow_size := Vector2.ONE  # the block at full size (w, h), from the feet up


# ---------------------------------------------------------------- frames

## WHOSE BODY IS THIS (the 11-10 input sweep): a piece's climber, or null for the
## arena, a prop, or a GHOST (a piece whose climber no longer exists). Every lookup
## goes through here: a typed read of a freed climber is a script error, and one of
## those inside the tick stopped that climber's grabs and steering dead for as long as
## it touched the ghost ("his controller randomly stopped working").
static func climber_of(o: Object) -> Climber:
	if o == null or not is_instance_valid(o) or not o.has_meta("climber"):
		return null
	var m = o.get_meta("climber")
	if m == null or not is_instance_valid(m):
		return null
	return m as Climber


## A piece that says it's a climber's but whose climber is gone: touches nothing,
## holds nobody up, can't be grabbed.
static func is_ghost(o: Object) -> bool:
	return o != null and is_instance_valid(o) and o.has_meta("climber") and climber_of(o) == null


static func angle_of(b: Node3D) -> float:
	var x := b.global_transform.basis.x
	return atan2(x.y, x.x)


static func pos2(b: Node3D) -> Vector2:
	var p := b.global_position
	return Vector2(p.x, p.y)


static func xf2(b: Node3D) -> Transform2D:
	return Transform2D(angle_of(b), pos2(b))


## THE LATE TRANSFORM LAW: push a moved body's transform to the physics server
## now, so a joint made next anchors where the body IS (Godot 2D anchored pins to
## stale transforms and tore them 2 m apart; 3D is pushed too, to be sure).
static func sync_server(b: CollisionObject3D) -> void:
	PhysicsServer3D.body_set_state(b.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, b.global_transform)


# ---------------------------------------------------------------- build

## Build the body standing in the T-pose with its feet at `feet` (y-up metres).
## root: a Node3D in the world (physics and visuals share it). model: the knight
## glb, or null for a headless battery.
func build(feet: Vector2, root: Node3D, model: PackedScene = null) -> void:
	body_scale = Feel.get_k("body_scale")
	spawn_at = feet
	_root = root
	var s := body_scale
	var friction_ends := Feel.get_k("friction_ends")
	var friction_body := Feel.get_k("friction_body")
	var visual: Node3D = null
	if model != null:
		visual = model.instantiate()
		root.add_child(visual)
		# The knight faces -z in its file: turn it to face the camera, and scale it.
		visual.global_transform = Transform3D(Basis(Vector3.UP, PI).scaled(Vector3.ONE * s), Vector3(feet.x, feet.y, 0.0))
	for pname in Layout.ORDER:
		var p: Dictionary = Layout.PIECES[pname]
		var shape: Array = p.shape
		var centre: Vector2
		var col := CollisionShape3D.new()
		match shape[0]:
			"circle":
				centre = (shape[1] + Layout.shift(pname)) * s
				var sp := SphereShape3D.new()
				sp.radius = shape[2] * s
				col.shape = sp
				_shape_geo[pname] = ["circle", shape[2] * s]
			"capsule":
				var a: Vector2 = (shape[1] + Layout.shift(pname)) * s
				var b: Vector2 = (shape[2] + Layout.shift(pname)) * s
				centre = (a + b) * 0.5
				var r: float = shape[3] * s
				var cap := CapsuleShape3D.new()
				cap.radius = r
				cap.height = a.distance_to(b) + 2.0 * r
				col.shape = cap
				var d := b - a
				# CapsuleShape3D runs along local y; lay it onto a->b in the plane.
				col.rotation = Vector3(0, 0, d.angle() - PI * 0.5)
				_shape_geo[pname] = ["capsule", -d * 0.5, d * 0.5, r]
			"box":
				centre = (shape[1] + Layout.shift(pname)) * s
				var bx := BoxShape3D.new()
				var he: Vector2 = shape[2] * s
				bx.size = Vector3(he.x * 2.0, he.y * 2.0, DEPTH)
				col.shape = bx
				_shape_geo[pname] = ["box", he]
		var body := RigidBody3D.new()
		body.name = "%s_%d" % [pname, climber_id]
		body.mass = float(p.mass) * s * s * s
		total_mass += body.mass
		var mat := PhysicsMaterial.new()
		mat.friction = friction_ends if _is_end(pname) else friction_body
		mat.bounce = Feel.get_k("bounce")
		body.physics_material_override = mat
		body.gravity_scale = Feel.climber_gravity(false)
		body.linear_damp = Feel.get_k("linear_damp")
		body.angular_damp = Feel.get_k("angular_damp")
		body.can_sleep = false
		body.axis_lock_linear_z = true
		body.axis_lock_angular_x = true
		body.axis_lock_angular_y = true
		body.collision_layer = LAYER_LIVE
		body.collision_mask = SOLID_MASK | LAYER_PROP
		body.contact_monitor = true
		body.max_contacts_reported = 6
		if _is_end(pname):
			body.continuous_cd = true
		body.set_meta("climber", self)
		body.set_meta("piece", pname)
		body.add_child(col)
		body.position = root.to_local(Vector3(feet.x + centre.x, feet.y + centre.y, 0.0))
		root.add_child(body)
		sync_server(body)
		bodies[pname] = body
		if visual != null:
			var mesh: Node3D = visual.find_child(p.mesh, true, false)
			if mesh != null:
				var keep := mesh.global_transform
				var sh := Layout.shift(pname) * s  # the wide shoulders: the arm mesh rides out with its piece
				keep.origin += Vector3(sh.x, sh.y, 0.0)
				mesh.get_parent().remove_child(mesh)
				body.add_child(mesh)
				mesh.global_transform = keep
				if pname.begins_with("hand"):
					_hand_meshes[pname] = [mesh, mesh.transform]
	if visual != null:
		visual.queue_free()
	# No self-collision: a climber's own pieces pass through each other, limbs fold
	# through themselves (Parker 11-07, again 11-08: "go through each other
	# completely"). THE SOFT FOLD in the joints is the only resistance.
	var names := Layout.ORDER
	for i in names.size():
		for j in range(i + 1, names.size()):
			bodies[names[i]].add_collision_exception_with(bodies[names[j]])
	_build_joints(feet)
	for hand_name in _hand_meshes:
		var wrist: Dictionary = joints.get("wrist" + (hand_name as String).substr(4), {})
		if not wrist.is_empty():
			_wrists[hand_name] = [wrist.a, wrist.b, wrist.local_a]  # kept past the joints (puppets, the frozen)
	_build_limbs()
	_hands_on_hips()
	set_tint(tint)


## The file's T-pose is the build pose; a climber STANDS with its arms at its sides
## (0.46 m wide, not 1.8 m), so spawns next to each other or next to the barrel
## don't start tangled. Each arm swings 90 degrees about its shoulder, pieces and
## joints together, before the first physics tick.
## HANDS ON HIPS (Parker 11-08: "when climber spawns, their hands are on their
## hips"): each arm is solved as two bones before the first physics tick. The
## shoulder stays, the hand goes to the side of the pelvis, the elbow bends
## outward. Forearm and hand turn together (wrist straight).
func _hands_on_hips() -> void:
	var pelvis: RigidBody3D = bodies["pelvis"]
	var P := pos2(pelvis)
	var half_w := 0.22 * body_scale
	for ld in Layout.LIMBS:
		if not bool(ld.arm):
			continue
		var side := -1.0 if ld.id == "arm_l" else 1.0  # screen side
		var S0: Vector2 = joints[ld.root].at
		var E0: Vector2 = joints[ld.mid].at
		var hand: RigidBody3D = bodies[ld.end]
		var H0 := pos2(hand)
		var l1 := S0.distance_to(E0)
		var l2 := E0.distance_to(H0)
		var T := P + Vector2(side * (half_w + 0.06 * body_scale), 0.03 * body_scale)
		var d := clampf(S0.distance_to(T), absf(l1 - l2) + 0.001, l1 + l2 - 0.001)
		var to_t := (T - S0).normalized()
		var a := acos(clampf((l1 * l1 + d * d - l2 * l2) / (2.0 * l1 * d), -1.0, 1.0))
		# Two elbow solutions: take the one further out from the body.
		var e1 := S0 + to_t.rotated(a) * l1
		var e2 := S0 + to_t.rotated(-a) * l1
		var E := e1 if absf(e1.x - P.x) > absf(e2.x - P.x) else e2
		var th1 := (E - S0).angle() - (E0 - S0).angle()
		var th2 := (T - E).angle() - (H0 - E0).angle()
		_turn_piece(bodies[ld.up], S0, S0, th1)
		_turn_piece(bodies[ld.lo], E0, E, th2)
		_turn_piece(hand, E0, E, th2)


## Turn a piece by `th` about its old pivot, and carry it to the new pivot.
func _turn_piece(b: RigidBody3D, pivot_old: Vector2, pivot_new: Vector2, th: float) -> void:
	var p := pos2(b)
	var q := pivot_new + (p - pivot_old).rotated(th)
	b.global_transform = Transform3D(Basis(Vector3.BACK, angle_of(b) + th), Vector3(q.x, q.y, 0.0))
	sync_server(b)


func _arms_down() -> void:
	for ld in Layout.LIMBS:
		if not bool(ld.arm):
			continue
		var j: Dictionary = joints[ld.root]
		var S: Vector2 = j.at
		var turn := PI * 0.5 if ld.id == "arm_l" else -PI * 0.5  # left arm: 180 -> 270; right: 0 -> -90
		for pname in [ld.up, ld.lo, ld.end]:
			var b: RigidBody3D = bodies[pname]
			var p := pos2(b)
			var q := S + (p - S).rotated(turn)
			b.global_transform = Transform3D(Basis(Vector3.BACK, angle_of(b) + turn), Vector3(q.x, q.y, 0.0))
			sync_server(b)


static func _is_end(pname: String) -> bool:
	return pname.begins_with("hand") or pname.begins_with("foot")


func _build_joints(feet: Vector2) -> void:
	var s := body_scale
	var kids := {}
	for jn in Layout.JOINTS:
		var jd: Dictionary = Layout.JOINTS[jn]
		if not kids.has(jd.a):
			kids[jd.a] = []
		kids[jd.a].append(jd.b)
	for jn in Layout.JOINTS:
		var jd: Dictionary = Layout.JOINTS[jn]
		var a: RigidBody3D = bodies[jd.a]
		var b: RigidBody3D = bodies[jd.b]
		var at := feet + ((jd.at as Vector2) + Layout.shift(jn)) * s
		var at3 := Vector3(at.x, at.y, 0.0)
		var lim: Array = jd.lim
		if jd.kind == "spine":
			var sl := Feel.get_k("spine_limit")
			lim = [-sl, sl]
		var rid := PhysicsServer3D.joint_create()
		# Hinge axis = local z of both frames; frames at the anchor, unrotated.
		PhysicsServer3D.joint_make_hinge(rid, a.get_rid(), Transform3D(Basis(), a.to_local(at3)), b.get_rid(), Transform3D(Basis(), b.to_local(at3)))
		PhysicsServer3D.joint_disable_collisions_between_bodies(rid, true)
		# Every limb joint turns freely all the way round (Parker 11-07, again 11-08);
		# folding an elbow or knee through itself meets THE SOFT FOLD instead of a stop.
		if jd.kind in ["spine", "neck"]:
			set_hinge_limits(rid, float(lim[0]), float(lim[1]))
		elif jn.begins_with("ankle") or jn.begins_with("wrist"):
			# THE ANKLE AND WRIST STOPS (Parker 11-09: "the feet keep breaking at the
			# ankles ... so they don't turn more than 30 degrees in either direction",
			# then the hands too). A stuck end SLIPS on its hold at the stop (_tick_slip),
			# so the stop shapes the look without pinning the body to one angle. The
			# hand you are steering drops its stop while held (_tick_slip, THE DRAWN WRIST).
			var stop := ANKLE_LIMIT_DEG if jn.begins_with("ankle") else WRIST_LIMIT_DEG
			lim = [-stop, stop]
			set_hinge_limits(rid, float(lim[0]), float(lim[1]))
		else:
			lim = [-360.0, 360.0]
		PhysicsServer3D.hinge_joint_set_flag(rid, PhysicsServer3D.HINGE_JOINT_FLAG_ENABLE_MOTOR, true)
		PhysicsServer3D.hinge_joint_set_param(rid, PhysicsServer3D.HINGE_JOINT_MOTOR_TARGET_VELOCITY, 0.0)
		PhysicsServer3D.hinge_joint_set_param(rid, PhysicsServer3D.HINGE_JOINT_MOTOR_MAX_IMPULSE, 0.0)
		# Effective inertia of everything hanging off the child, about the anchor.
		var ieff := 0.0
		var stack: Array = [jd.b]
		while not stack.is_empty():
			var pn: String = stack.pop_back()
			var pb: RigidBody3D = bodies[pn]
			ieff += _piece_inertia(pn, pb.mass) + pb.mass * pos2(pb).distance_squared_to(at)
			if kids.has(pn):
				stack.append_array(kids[pn])
		# And the other side: everything NOT hanging off the child, about the anchor.
		# A stuck foot's ankle holds the BODY up, so its servo is sized by this.
		var child_set := {}
		var st: Array = [jd.b]
		while not st.is_empty():
			var pn: String = st.pop_back()
			child_set[pn] = true
			if kids.has(pn):
				st.append_array(kids[pn])
		var other := 0.0
		for pn in bodies:
			if not child_set.has(pn):
				var pb: RigidBody3D = bodies[pn]
				other += _piece_inertia(pn, pb.mass) + pb.mass * pos2(pb).distance_squared_to(at)
		joints[jn] = {
			"rid": rid, "a": a, "b": b, "kind": jd.kind, "at": at,
			"lo": deg_to_rad(float(lim[0])), "hi": deg_to_rad(float(lim[1])),
			"ieff": ieff, "ieff_other": other, "local_a": xf2(a).affine_inverse() * at,
			"win": deg_to_rad(float(lim[1])), "stop_on": true,  # a wrist's live stop window (rad)
		}


## Limits in the layout are degrees of the child CCW relative to the parent.
static func set_hinge_limits(rid: RID, lo_deg: float, hi_deg: float) -> void:
	var lo := deg_to_rad(lo_deg)
	var hi := deg_to_rad(hi_deg)
	if LIMIT_FLIP:
		var t := lo
		lo = -hi
		hi = -t
	PhysicsServer3D.hinge_joint_set_flag(rid, PhysicsServer3D.HINGE_JOINT_FLAG_USE_LIMIT, true)
	PhysicsServer3D.hinge_joint_set_param(rid, PhysicsServer3D.HINGE_JOINT_LIMIT_LOWER, lo)
	PhysicsServer3D.hinge_joint_set_param(rid, PhysicsServer3D.HINGE_JOINT_LIMIT_UPPER, hi)


func _piece_inertia(pname: String, mass: float) -> float:
	var g: Array = _shape_geo[pname]
	match g[0]:
		"circle":
			return 0.4 * mass * g[1] * g[1]
		"capsule":
			var l: float = (g[2] - g[1]).length() + 2.0 * g[3]
			return mass * (l * l / 12.0 + g[3] * g[3] * 0.25)
		"box":
			var he: Vector2 = g[1]
			return mass * (4.0 * he.x * he.x + 4.0 * he.y * he.y) / 12.0
	return 0.0


func _build_limbs() -> void:
	var s := body_scale
	for ld in Layout.LIMBS:
		var root_at: Vector2 = (Layout.JOINTS[ld.root].at + Layout.shift(ld.root)) * s
		var mid_at: Vector2 = (Layout.JOINTS[ld.mid].at + Layout.shift(ld.mid)) * s
		var end_pt: Vector2 = Layout.end_point(ld.end) * s
		var upper_length := root_at.distance_to(mid_at)
		var lower_length := mid_at.distance_to(end_pt)
		var fold_angle := deg_to_rad(FOLD_REACH_DEG)
		var folded_reach := Vector2(upper_length, 0) + Vector2.from_angle(fold_angle) * lower_length
		var end_shape: Array = Layout.PIECES[ld.end].shape
		var end_r: float = (end_shape[2] if end_shape[0] == "circle" else (end_shape[2] as Vector2).x) * s
		limbs.append({
			"def": ld,
			"l1": upper_length,
			"l2": lower_length,
			"min_reach": folded_reach.length(),
			"end_r": end_r,
			"held": false,
			"grab": RID(),  # pin joint RID while stuck
			"grab_other": null,  # the body stuck to
			"grab_climber": null,  # its climber, if it is one
			"grab_piece": "",
			"end_offset": Vector3.ZERO, "contact_offset": Vector3.ZERO, "last_anchor": Vector3.ZERO,
			"contact_force": Vector3.ZERO, "strain_time": 0.0, "peeled_from": 0,
			"regrip": 0.0,
			"end_joint": ("wrist" if ld.arm else "ankle") + (ld.id as String).substr((ld.id as String).length() - 2),
			"grab_rel0": 0.0,  # the end's angle against its hold when it stuck (rad)
			"slipping": false,  # THE SLIP: the weld is turning as a friction pivot
			"cursor": Vector2.ZERO,  # where a held hand or foot is being steered (world m)
			"driving": false,
		})


## The house look (CelPass: cel shading on the shared colour atlas, inked by the
## screen-space outline), in the model's own colours: no wash toward the player
## colour (Parker 11-07). Players will pick skins later; any skin on the 16
## Defaultio names drops in piece by piece. `tint` still colours tags and cards.
func set_tint(c: Color) -> void:
	tint = c  # still the player's colour for name tags and cards; the body keeps its own colours
	for b in bodies.values():
		for ch in b.get_children():
			if not (ch is MeshInstance3D):
				continue
			var mi := ch as MeshInstance3D
			if mi.mesh == null:
				continue
			for si in mi.mesh.get_surface_count():
				var m := mi.get_active_material(si)
				var cel: ShaderMaterial = null
				if m is StandardMaterial3D:
					cel = CelPass.material_for(m, mi.mesh, si)
				elif m is ShaderMaterial:
					cel = m
				if cel == null:
					continue
				# No wash toward the player colour (Parker 11-07: "People can look the same
				# it's fine"; skins will tell players apart later): the shared cel material.
				mi.set_surface_override_material(si, cel)


## THE LIMB GLYPHS (the reference game's idea): the button for each limb sits ON
## the hand or foot, so you never wonder which button is which. Dim when loose,
## bright when held, on a white disc when stuck to something (Parker 11-07: half
## the old size, "a white background to indicate they are attached").
## items: [{"tex": Texture2D or null, "text"}].
## The glyphs draw over everything (no depth test): hidden under the pause menu.
func set_glyphs_visible(on: bool) -> void:
	for g in _glyphs:
		if is_instance_valid(g) and g.visible != on:
			g.visible = on


func set_glyphs(items: Array) -> void:
	for g in _glyphs:
		if is_instance_valid(g):
			g.hide()
			g.queue_free()
	_glyphs.clear()
	if state == State.FROZEN:
		return
	for i in mini(items.size(), limbs.size()):
		var end: RigidBody3D = bodies[limbs[i].def.end]
		var item: Dictionary = items[i]
		var node: Node3D
		if item.get("tex") != null:
			var sp := Sprite3D.new()
			sp.texture = item.tex
			sp.pixel_size = 0.0019
			sp.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			sp.no_depth_test = true
			sp.render_priority = 20
			sp.shaded = false
			node = sp
		else:
			var lb := Label3D.new()
			lb.text = str(item.get("text", "?"))
			lb.font_size = 48
			lb.pixel_size = 0.00275
			lb.outline_size = 12
			lb.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			lb.no_depth_test = true
			lb.render_priority = 20
			node = lb
		node.position = Vector3(0.0, 0.0, 0.3)
		end.add_child(node)
		# The stuck look: the glyph baked onto a white disc with a dark rim (one image,
		# so no sorting between two see-through sprites), swapped in while stuck.
		if node is Sprite3D:
			node.set_meta("tex_free", _on_disc(item.tex, false))
			node.set_meta("tex_stuck", _on_disc(item.tex, true))
			(node as Sprite3D).texture = node.get_meta("tex_free")
		else:
			var disc := Sprite3D.new()
			disc.name = "StuckDisc"
			disc.texture = _on_disc(null, true)
			disc.pixel_size = 0.13 / 128.0
			disc.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			disc.no_depth_test = true
			disc.render_priority = 19
			disc.shaded = false
			disc.visible = false
			node.add_child(disc)
		_glyphs.append(node)


## tex (any size, or null) with its cut-out letter inked dark, over a white disc
## with a dark rim filling the canvas when `disc`.
static var _disc_cache := {}
static func _on_disc(tex: Texture2D, disc := true) -> Texture2D:
	var cache_key := "%d:%s" % [tex.get_instance_id() if tex != null else 0, disc]
	if _disc_cache.has(cache_key):
		return _disc_cache[cache_key]
	var made := _make_disc(tex, disc)
	_disc_cache[cache_key] = made
	return made


static func _make_disc(tex: Texture2D, disc := true) -> Texture2D:
	var n := 128
	var top: Image = null
	if tex != null:
		top = tex.get_image().duplicate()
		if top.is_compressed():
			top.decompress()
		top.convert(Image.FORMAT_RGBA8)
		n = top.get_width()
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	var r := n * 0.5 if disc else 0.0
	var rim_w := maxf(2.0, n * 0.045)
	var rim := Color(0.08, 0.09, 0.2)
	for y in n:
		for x in n:
			var d := Vector2(x + 0.5 - n * 0.5, y + 0.5 - n * 0.5).length()
			var c := rim.lerp(Color.WHITE, clampf(r - rim_w - d, 0.0, 1.0))
			c.a = clampf(r - d, 0.0, 1.0)
			img.set_pixel(x, y, c)
	if top != null:
		img.blend_rect(top, Rect2i(0, 0, n, top.get_height()), Vector2i.ZERO)
		# The prompts cut their letter out of the cap (a see-through hole), which
		# vanishes on white: ink the holes. A hole is a clear pixel that a flood
		# from the image's edge can't reach.
		var h := top.get_height()
		var outside := PackedByteArray()
		outside.resize(n * h)
		var stack: Array[Vector2i] = []
		for x in n:
			stack.append(Vector2i(x, 0))
			stack.append(Vector2i(x, h - 1))
		for y in h:
			stack.append(Vector2i(0, y))
			stack.append(Vector2i(n - 1, y))
		while not stack.is_empty():
			var q: Vector2i = stack.pop_back()
			if q.x < 0 or q.y < 0 or q.x >= n or q.y >= h or outside[q.y * n + q.x] == 1:
				continue
			if top.get_pixel(q.x, q.y).a > 0.5:
				continue
			outside[q.y * n + q.x] = 1
			stack.append(q + Vector2i.RIGHT)
			stack.append(q + Vector2i.LEFT)
			stack.append(q + Vector2i.DOWN)
			stack.append(q + Vector2i.UP)
		for y in h:
			for x in n:
				var a := top.get_pixel(x, y).a
				if outside[y * n + x] == 0 and a < 1.0:
					var ink := Color(rim.r, rim.g, rim.b, 1.0)
					img.set_pixel(x, y, ink.lerp(img.get_pixel(x, y), a))
	return ImageTexture.create_from_image(img)


func _process(_delta: float) -> void:
	if growing():
		return
	_draw_wrists()
	if _glyphs.is_empty():
		return
	for i in _glyphs.size():
		var g = _glyphs[i]
		if not is_instance_valid(g):
			continue
		var l: Dictionary = limbs[i]
		var c := Color(1, 1, 1, 0.55)
		var sc := 1.0
		var stuck: bool = l.grab_other != null
		var disc := (g as Node).get_node_or_null("StuckDisc")
		if disc != null:
			disc.visible = stuck
		if (g as Node).has_meta("tex_stuck"):
			(g as Sprite3D).texture = g.get_meta("tex_stuck") if stuck else g.get_meta("tex_free")
		if stuck:
			c = Color(1, 1, 1, 1)
			sc = 1.1
		elif l.held:
			c = Color(1, 1, 1, 1)
			sc = 1.25
		if g is Sprite3D:
			(g as Sprite3D).modulate = c
		else:
			(g as Label3D).modulate = c
		g.scale = Vector3.ONE * sc


## THE DRAWN WRIST (Parker 11-09): a hand's mesh is drawn turned back within the
## wrist stop, about the wrist, whatever the physics hand is doing (the steered hand's
## wrist is free, and remote puppets show the owner's pose). Within the stop it rests.
func _draw_wrists() -> void:
	for pname in _hand_meshes:
		var entry: Array = _hand_meshes[pname]
		var mesh := entry[0] as Node3D
		if not is_instance_valid(mesh):
			continue
		var wj: Array = _wrists.get(pname, [])
		if wj.is_empty() or not is_instance_valid(wj[0]) or not is_instance_valid(wj[1]):
			continue
		var hand := wj[1] as RigidBody3D
		var rel := wrapf(angle_of(hand) - angle_of(wj[0]), -PI, PI)
		var stop := deg_to_rad(WRIST_LIMIT_DEG)
		var back := clampf(rel, -stop, stop) - rel
		if absf(back) < 0.001:
			mesh.transform = entry[1]
			continue
		var w2 := xf2(wj[0]) * (wj[2] as Vector2)
		var pivot := hand.to_local(Vector3(w2.x, w2.y, 0.0))
		var turn := Transform3D(Basis(Vector3.BACK, back), pivot - Basis(Vector3.BACK, back) * pivot)
		mesh.transform = turn * (entry[1] as Transform3D)


# ---------------------------------------------------------------- tick

func _physics_process(delta: float) -> void:
	if _grow_t >= 0.0 and not removed:
		_tick_grow(delta)
		return
	if removed or state != State.LIVE:
		return
	live_time += delta
	if sinking:
		_tick_sink(delta)
		return
	_impact_guard = maxf(0, _impact_guard - delta)
	for load_info: Dictionary in remote_pulls.values():
		var piece: RigidBody3D = bodies.get(load_info.piece)
		if piece != null:
			var force: Vector3 = load_info.force
			piece.apply_force(force, piece.global_basis * (load_info.offset as Vector3))
			_incoming_pull = maxf(_incoming_pull, force.length() * (1.0 if load_info.get("directly_supported", false) else 0.2))
	_forget_dead_holds()
	_tick_slip(delta)
	if knockout_left > 0:
		knockout_left = maxf(0, knockout_left - delta)
		if is_instance_valid(knockout_stars):
			knockout_stars.set_remaining(knockout_left)
		if knockout_left == 0:
			set_knockout_visual(false)
			knockout_changed.emit(false)
		_incoming_pull = 0
		_tick_ropes(delta)  # out cold you still bounce off the ropes (Parker 11-10), not through them
		return
	_tick_ropes(delta)
	_grunt_wait -= delta / Engine.time_scale
	_select_active_limb()
	for i in limbs.size():
		_tick_limb(i, delta)
	var attached := is_attached()
	var gravity := Feel.climber_gravity(attached)
	if gravity != _gravity_scale:
		for body: RigidBody3D in bodies.values():
			body.gravity_scale = gravity
		_gravity_scale = gravity
	_tick_joints(attached, delta)
	# Opposed pulls have to persist through several physics ticks to peel a grip.
	var load_ratio := _incoming_pull / maxf(1, total_mass * 9.8 * 2.0)
	_pull_load = maxf(0, _pull_load + (load_ratio - 0.9) * delta)
	_incoming_pull = 0
	if _pull_load >= 0.15:
		_pull_load = 0
		for i in limbs.size():
			var grip: Dictionary = limbs[i]
			if grip.grab.is_valid() and (grip.grab_climber == null or grip.grab_climber.state == State.FROZEN):
				release(i)
				grip.regrip = 0.65


## IN THE DRINK (Parker 11-11): limp from the moment a piece goes in, every grip let go
## and every motor off; under the surface each piece is slowed to a sink, so the body
## goes all the way under, and down a little more, before the host calls it out.
const SINK_SPEED := 1.7  # m/s down, under the water
var sinking := false
var _sink_water_y := 0.0


func sink(water_y: float) -> void:
	if sinking or state != State.LIVE:
		return
	sinking = true
	_sink_water_y = water_y
	release_all()
	_active_limb = -1
	_press_stack.clear()
	_buttons_down.fill(false)
	_neutral_angles.clear()
	limb_selected.emit(-1, Vector3.ZERO)
	for l in limbs:
		l.held = false
		l.driving = false
	for joint in joints.values():
		PhysicsServer3D.hinge_joint_set_param(joint.rid, PhysicsServer3D.HINGE_JOINT_MOTOR_MAX_IMPULSE, 0)
	_gravity_scale = Feel.get_k("gravity_scale")  # full weight: nothing holds it up now
	for body: RigidBody3D in bodies.values():
		body.gravity_scale = _gravity_scale


func _tick_sink(delta: float) -> void:
	var k := 1.0 - exp(-4.5 * delta)
	for body: RigidBody3D in bodies.values():
		if body.global_position.y < _sink_water_y:
			var v := body.linear_velocity
			v.y += 9.8 * body.gravity_scale * delta * 0.8  # the water bears most of the weight
			body.linear_velocity = v.lerp(Vector3(v.x * 0.25, -SINK_SPEED, 0.0), k)
			body.angular_velocity *= 1.0 - k * 0.6


## True during the spawn's grow-in.
func growing() -> bool:
	return _grow_t >= 0.0


## Start the grow-in (call right after build, on every machine): from nothing at the
## feet to full size in GROW_S, the growing block pushing whatever stands there away.
func grow_in() -> void:
	if bodies.is_empty() or removed:
		return
	_grow_full.clear()
	_grow_kids.clear()
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for b in bodies.values():
		var rb: RigidBody3D = b
		_grow_full[rb] = rb.global_transform
		for ch in rb.get_children():
			if ch is Node3D and not ch is CollisionShape3D:
				_grow_kids[ch] = (ch as Node3D).transform
		var g: Array = _shape_geo.get(rb.get_meta("piece"), [])
		var r := 0.12
		if not g.is_empty():
			match str(g[0]):
				"circle":
					r = float(g[1])
				"capsule":
					r = float(g[3]) + (g[2] as Vector2).length()
				"box":
					r = (g[1] as Vector2).length()
		var p := pos2(rb)
		lo = lo.min(p - Vector2(r, r))
		hi = hi.max(p + Vector2(r, r))
		rb.collision_layer = 0
		rb.collision_mask = 0
		rb.linear_velocity = Vector3.ZERO
		rb.angular_velocity = Vector3.ZERO
		rb.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		rb.freeze = true
	# The block: the climber's standing width (both sides of the feet) and height.
	var half_w := maxf(spawn_at.x - lo.x, hi.x - spawn_at.x)
	_grow_size = Vector2(half_w * 2.0, maxf(hi.y - spawn_at.y, 0.2))
	_grow_block = StaticBody3D.new()
	_grow_block.name = "GrowBlock_%d" % climber_id
	_grow_block.collision_layer = LAYER_WORLD  # everything that stands on the world feels it
	_grow_block.collision_mask = 0
	_grow_block.set_meta("no_weld", true)  # never held, never a support
	_grow_box = BoxShape3D.new()
	var col := CollisionShape3D.new()
	col.shape = _grow_box
	_grow_block.add_child(col)
	_root.add_child(_grow_block)
	_grow_t = 0.0
	_apply_grow(0.0)


func _tick_grow(delta: float) -> void:
	_grow_t += delta
	if _grow_t >= GROW_S:
		_end_grow()
		return
	_apply_grow(_grow_t / GROW_S)
	_grow_push(delta)


## Shove whatever the block overlaps out sideways: a whole climber one way together
## (by its centre against the feet), a loose body (the chair) by its own centre, fast
## enough to be clear by the time the block reaches it.
func _grow_push(delta: float) -> void:
	if _grow_block == null or not _grow_block.is_inside_tree():
		return
	var space := _grow_block.get_world_3d().direct_space_state
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = _grow_box
	q.transform = _grow_block.global_transform
	q.collision_mask = SOLID_MASK | LAYER_PROP
	q.exclude = [_grow_block.get_rid()]
	var half := _grow_box.size.x * 0.5
	var done := {}
	for hit in space.intersect_shape(q, 32):
		var rb := hit.collider as RigidBody3D
		if rb == null or rb.freeze:
			continue
		var group: Array = [rb]
		var cx := rb.global_position.x
		var who: Climber = climber_of(rb)
		if who != null and who != self:
			if done.has(who):
				continue
			done[who] = true
			group = (who as Climber).bodies.values()
			cx = (who as Climber).centre_of_mass().x
		var dx := cx - spawn_at.x
		var side := signf(dx) if absf(dx) > 0.02 else (1.0 if climber_id % 2 == 0 else -1.0)
		var need := half + 0.25 - absf(dx)
		if need <= 0.0:
			continue
		var speed := minf(need / maxf(delta, 0.008), 4.0)  # a firm shove aside, never a launch
		if who != null:
			for li in who.limbs.size():
				var hold: Dictionary = who.limbs[li]
				if hold.grab_other != null and (hold.grab as RID).is_valid() and (hold.grab_climber == null or hold.grab_climber.state == State.FROZEN):
					who.release(li)  # its feet were welded to the spot: let go, to be moved
					hold.regrip = 0.35
		for b in group:
			var body := b as RigidBody3D
			if body != null and not body.freeze and side * body.linear_velocity.x < speed:
				body.linear_velocity.x = side * speed


## Draw everything at k of full size about the feet, and size the block to match.
func _apply_grow(f: float) -> void:
	var k := maxf(0.02, 1.0 - pow(1.0 - clampf(f, 0.0, 1.0), 2.0))  # eased out: quick, then settling
	var feet := Vector3(spawn_at.x, spawn_at.y, 0.0)
	for rb in _grow_full:
		var full: Transform3D = _grow_full[rb]
		(rb as RigidBody3D).global_transform = Transform3D(full.basis, feet + (full.origin - feet) * k)
	for ch in _grow_kids:
		if is_instance_valid(ch):
			var t: Transform3D = _grow_kids[ch]
			(ch as Node3D).transform = Transform3D(t.basis.scaled(Vector3.ONE * k), t.origin * k)
	if _grow_box != null:
		var w := maxf(_grow_size.x * k, 0.02)
		var h := maxf(_grow_size.y * k, 0.02)
		_grow_box.size = Vector3(w, h, 4.0)  # deep: the push comes out sideways or up, never along z (locked)
		_grow_block.global_position = feet + Vector3(0.0, h * 0.5, 0.0)


func _end_grow() -> void:
	_grow_t = -1.0
	for ch in _grow_kids:
		if is_instance_valid(ch):
			(ch as Node3D).transform = _grow_kids[ch]
	for rb in _grow_full:
		var body := rb as RigidBody3D
		if not is_instance_valid(body):
			continue
		body.global_transform = _grow_full[rb]
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		if state == State.FROZEN:
			body.collision_layer = LAYER_FROZEN
		else:
			body.collision_layer = LAYER_LIVE
		body.collision_mask = SOLID_MASK | LAYER_PROP
		if state == State.LIVE:
			body.freeze = false
		sync_server(body)
	_grow_full.clear()
	_grow_kids.clear()
	if is_instance_valid(_grow_block):
		_grow_block.queue_free()
	_grow_block = null
	_grow_box = null


func set_knockout_visual(active: bool) -> void:
	if active and (removed or state == State.FROZEN or not bodies.has("head")):
		return
	if active and not is_instance_valid(knockout_stars):
		knockout_stars = KnockoutStars.new()
		knockout_stars.name = "KnockoutStars"
		bodies["head"].add_child(knockout_stars)
		knockout_stars.setup(body_scale)
	if is_instance_valid(knockout_stars):
		knockout_stars.show_active(active, KNOCKOUT_DURATION)
		if active and state == State.LIVE:
			knockout_stars.set_remaining(knockout_left)


func knock_out() -> void:
	if state != State.LIVE or knockout_left > 0 or _impact_guard > 0:
		return
	knockout_left = KNOCKOUT_DURATION
	set_knockout_visual(true)
	knockout_changed.emit(true)
	knocked_out.emit()
	_impact_guard = knockout_left + 0.8
	release_all()
	_active_limb = -1
	_press_stack.clear()
	_buttons_down.fill(false)
	_neutral_angles.clear()
	limb_selected.emit(-1, Vector3.ZERO)
	for l in limbs:
		l.held = false
		l.driving = false
	for joint in joints.values():
		PhysicsServer3D.hinge_joint_set_param(joint.rid, PhysicsServer3D.HINGE_JOINT_MOTOR_MAX_IMPULSE, 0)
	_gravity_scale = Feel.climber_gravity(false)
	for body: RigidBody3D in bodies.values():
		body.gravity_scale = _gravity_scale


## THE GROUNDED GROUP (Parker 11-08: "you cannot exert force unless at least one
## connected person is touching something solid like the ground or tower"): I can
## drive only if someone in my chain of grabs (me, whoever I hold, whoever holds me,
## and on through) is stuck to or touching the arena or the frozen tower. Two climbers
## holding each other in the air can't fly. A rival on another machine counts while
## their pull arrives (their machine sends it only while they're grounded).
## Contact from either side of the rope throws the whole climber back
## into the ring at Feel rope_bounce times the speed it hit (relative motion kept).
func _tick_ropes(delta: float) -> void:
	_rope_wait -= delta
	if rope_x <= 0.0:
		return
	# Well inside the ring (no piece is 2 m from the pelvis): no rope can be near.
	var pelvis: RigidBody3D = bodies.get("pelvis")
	if pelvis != null and absf(pelvis.global_position.x) < rope_x - 2.2:
		return
	var pieces := bodies.values()
	var com_v := Vector2.ZERO
	var velocity_ready := false
	for b in pieces:
		var p: Vector3 = (b as Node3D).global_position
		var body := b as RigidBody3D
		var side := signf(p.x)
		var outward := body.linear_velocity.x * side
		var outside := absf(p.x) > rope_x
		var reach := 0.3 + absf(body.linear_velocity.x) * delta
		if absf(p.x) < rope_x - 0.22 or absf(p.x) > rope_x + reach or p.y < ROPE_LOW or p.y > ROPE_HIGH:
			continue
		if not velocity_ready:
			for piece: RigidBody3D in pieces:
				var v := piece.linear_velocity
				com_v += Vector2(v.x, v.y) * piece.mass
			com_v /= maxf(total_mass, 0.001)
			velocity_ready = true
		# Resist individual limbs even during the audiovisual bounce cooldown.
		# A slow limb can otherwise pass through while the body's average speed is zero.
		if outward > 0.0:
			body.linear_velocity.x = -side * maxf(0.3, outward * 0.5)
		if absf(p.x) > rope_x + 0.12:
			body.global_position.x = side * (rope_x + 0.12)
			sync_server(body)
		if _rope_wait > 0.0:
			continue
		# Outside contact uses the same inward throw, even when already moving inward.
		# Keep the original directional gate for a wrestler inside leaving the rope.
		var out_speed: float = maxf(0.3, absf(com_v.x)) if outside else com_v.x * side
		if out_speed < 0.3:
			continue
		var new_v := rope_throw(Vector2(side * out_speed, com_v.y), side)
		for o in pieces:
			var rb := o as RigidBody3D
			rb.linear_velocity.x += new_v.x - com_v.x
			rb.linear_velocity.y += new_v.y - com_v.y
		_rope_wait = ROPE_COOLDOWN
		rope_bounced.emit(Vector3(side * rope_x, p.y, 0.0), com_v.length())


## THE ROPE THROW, for climbers and the chair alike (Parker 11-09: "bounce you in the
## opposite direction to where you are coming from, so if you are falling off the
## tower and hit it, it can potentially bounce you up and back on ... only ever add
## lift ... the chair should have the same rules as the people"). v: the velocity
## into the ropes on `side` (-1 left, +1 right). The sideways part turns round at
## rope_bounce; a fall turns into a throw UP at rope_bounce_up; rising, you keep
## rising as you were (it never sends you down).
static func rope_throw(v: Vector2, side: float) -> Vector2:
	var out_speed := maxf(0.0, v.x * side)
	var up := -v.y * Feel.get_k("rope_bounce_up") if v.y < 0.0 else v.y
	return Vector2(-side * out_speed * Feel.get_k("rope_bounce"), up)


func is_attached() -> bool:
	return remote_support or float_mode or scramble or grounded_locally()


## THE GROUNDED GROUP on this machine only (what the network pull is sent on, so
## two airborne rivals on two machines can't hold each other up either).
func grounded_locally() -> bool:
	var seen := {self: true}
	var queue: Array = [self]
	while not queue.is_empty():
		var c: Climber = queue.pop_back()
		if c.touches_solid():
			return true
		var next: Array = c.held_by.duplicate()
		for l in c.limbs:
			if l.grab_other != null and l.grab_climber != null:
				next.append(l.grab_climber)
		for o in next:
			if o != null and is_instance_valid(o) and not seen.has(o) and o.state != State.FROZEN:
				seen[o] = true
				queue.append(o)
	return false


## WELDED TO A SUPPORT (Parker 11-09: "If I am welded to the tower, I should be able to
## lock in if I am above the line"): a hand or foot stuck to the arena or the frozen
## tower. A strained weld can hang a few centimetres off the surface, so the host's
## pose test alone missed it; the lock-in request carries this too.
func welded_to_support() -> bool:
	for l in limbs:
		if (l.grab as RID).is_valid() and l.grab_other != null and (l.grab_climber == null or not is_instance_valid(l.grab_climber) or l.grab_climber.state == State.FROZEN):
			return true
	return false


## Stuck to the arena or the frozen tower, or an end piece touching either.
var _solid_frame := -1
var _solid_value := false
func touches_solid() -> bool:
	if state == State.PUPPET:
		return puppet_on_support
	# One answer per physics frame: the tick, the pose stream, the pulls and the HUD
	# all ask, and each ask read every end's contact list. attach / release reset it.
	var f := Engine.get_physics_frames()
	if f == _solid_frame:
		return _solid_value
	_solid_value = _touches_solid_now()
	_solid_frame = f
	return _solid_value


func _touches_solid_now() -> bool:
	for l in limbs:
		if l.grab_other != null and (l.grab_climber == null or not is_instance_valid(l.grab_climber) or l.grab_climber.state == State.FROZEN):
			return true
	for l in limbs:
		if l.held:
			continue  # a limb you're lifting off doesn't hold you up
		var end: RigidBody3D = bodies.get(l.def.end)
		if end == null or not end.contact_monitor:
			continue
		for o in end.get_colliding_bodies():
			if o == null or not is_instance_valid(o) or (o.collision_layer & SOLID_MASK) == 0:
				continue
			if o.has_meta("no_weld"):
				continue  # the buoy holds nobody up
			if not (o is RigidBody3D and o.has_meta("climber")):
				return true  # the arena (static world)
			var oc := climber_of(o)
			if oc != null and oc != self and oc.state == State.FROZEN:
				return true
	return false


func stuck_count() -> int:
	var n := 0
	for l in limbs:
		if l.grab_other != null:
			n += 1
	return n


# THE PRESS STACK (Parker 11-08): one limb is active at a time, the most recent
# press still held. Hold A, press X: X takes over. Let go of X with A still down:
# A takes over again, as if you never stopped holding it. Edges sampled in the
# same tick: the first limb in controller order ends on top.
func active_limb() -> int:
	return _active_limb


var _press_stack: Array[int] = []


func _select_active_limb() -> void:
	var previous := _active_limb
	var fresh: Array[int] = []
	for i in limbs.size():
		var down: bool = driver != null and driver.held(i)
		if down and not _buttons_down[i]:
			fresh.append(i)
		elif not down and _buttons_down[i]:
			_press_stack.erase(i)
		_buttons_down[i] = down
	for k in range(fresh.size() - 1, -1, -1):  # lowest index pushed last: on top
		_press_stack.erase(fresh[k])
		_press_stack.append(fresh[k])
	_active_limb = _press_stack.back() if not _press_stack.is_empty() else -1
	if previous != _active_limb:
		var velocity := Vector3.ZERO
		if previous >= 0:
			var end: RigidBody3D = bodies[limbs[previous].def.end]
			velocity = end.linear_velocity
		limb_selected.emit(_active_limb, velocity)


## A hold on something that was freed under us (a piece, the chair): forget it
## cleanly, before the slip, the limbs or a knockout read it. (A freed object compares
## equal to null, so release() alone left its joint and its fields dangling.)
func _forget_dead_holds() -> void:
	for i in limbs.size():
		var l: Dictionary = limbs[i]
		if not is_instance_valid(l.grab_other) and (typeof(l.grab_other) == TYPE_OBJECT or (l.grab as RID).is_valid()):
			if (l.grab as RID).is_valid():
				PhysicsServer3D.free_rid(l.grab)
			l.grab = RID()
			l.grab_other = null
			l.grab_climber = null
			l.grab_piece = ""
			_solid_frame = -1
			grab_lost.emit(self, i)
		elif typeof(l.grab_climber) == TYPE_OBJECT and not is_instance_valid(l.grab_climber):
			l.grab_climber = null


func _tick_limb(i: int, delta: float) -> void:
	var l: Dictionary = limbs[i]
	var held := i == _active_limb
	var just_released: bool = l.held and not held
	if held and not l.held:
		# Press: pick the limb up. It won't stick while held.
		if l.grab_other != null:
			release(i)
		l.regrip = 0.0
		_neutral_angles.clear()
		l.cursor = limb_end(i)  # steering starts from where the hand is
	elif just_released:
		l.regrip = 0.0  # release: plant it right now if it's on something
	if l.held != held:
		_solid_frame = -1
	l.held = held
	l.regrip = maxf(0.0, l.regrip - delta)
	var was_stuck: bool = l.grab_other != null
	if l.grab_climber != null and not l.grab.is_valid():
		_tick_live_contact(i, delta)
	if not held and l.grab_other == null and l.regrip <= 0.0:
		_try_grab(i)
	# THE SLAP on every catch (Parker 11-08: "anytime a hand connects, it should make
	# the noise", held or not: a flung limb landing, a held one grabbing someone),
	# except the feet settling onto the canvas at spawn.
	if l.grab_other != null and not was_stuck and live_time > SLAP_QUIET_S:
		var end: RigidBody3D = bodies[l.def.end]
		release_contact.emit(end.global_position)


func _try_grab(i: int) -> void:
	var l: Dictionary = limbs[i]
	var end: RigidBody3D = bodies[l.def.end]
	# The end pieces report their contacts (contact_monitor), so a stick check is
	# a list read, not a shape query: every unheld limb checks every tick.
	var hits := end.get_colliding_bodies()
	if hits.is_empty():
		l.peeled_from = 0
		return
	# Prefer the arena and frozen stack when the same end touches both.
	var still_touching_peeled := false
	var best: Object = null
	var best_score := INF
	for o in hits:
		if o == null or not is_instance_valid(o) or o == end or (o.collision_layer & SOLID_MASK) == 0 or o.has_meta("no_weld"):
			continue
		var score := 0.0
		if o is RigidBody3D and o.has_meta("climber"):
			var oc := climber_of(o)
			if oc == null or oc == self or oc.removed:
				continue  # (null: a ghost piece, its climber gone)
			if oc.state != State.FROZEN:
				if oc.get_instance_id() == l.peeled_from:
					still_touching_peeled = true
					continue
				score += 1.0
		if o is Node3D:
			score += (o as Node3D).global_position.distance_to(end.global_position) * 0.001
		if score < best_score:
			best_score = score
			best = o
	if not still_touching_peeled:
		l.peeled_from = 0
	if best != null:
		attach(i, best)


## A live contact has no angular weld. A damped spring transfers opposite forces
## at the two original contact points. A short overload allowance lets a catch
## or toss transfer momentum before the contact peels.
func _tick_live_contact(i: int, dt: float) -> void:
	var l: Dictionary = limbs[i]
	var other: RigidBody3D = l.grab_other
	var rival: Climber = l.grab_climber
	if rival.state == State.FROZEN:
		release(i)
		attach(i, other)
		return
	var end: RigidBody3D = bodies[l.def.end]
	var point := other.to_global(l.contact_offset)
	var lever := point - other.global_position
	var speed := other.linear_velocity + other.angular_velocity.cross(lever)
	if rival.state == State.PUPPET:
		speed = (point - (l.last_anchor as Vector3)) / dt
	l.last_anchor = point
	var hand_lever := end.global_basis * (l.end_offset as Vector3)
	var hand_speed := end.linear_velocity + end.angular_velocity.cross(hand_lever)
	var gap := point - (end.global_position + hand_lever)
	var weight := total_mass * 9.8
	var stiffness := weight * 24.0
	var damping := 1.6 * sqrt(stiffness * end.mass)
	var force := (gap * stiffness + (speed - hand_speed) * damping) / (1.0 + damping * dt / end.mass)
	var ratio := force.length() / (weight * 2.0)
	l.strain_time = maxf(0, float(l.strain_time) + dt * (ratio - 1.45))
	if l.strain_time > 0.055 or gap.length() > 0.60:
		l.peeled_from = rival.get_instance_id()
		release(i)
		l.regrip = 0.22
		return
	force = force.limit_length(weight * 3.0)
	end.apply_force(force, hand_lever)
	l.contact_force = -force
	if rival.state == State.LIVE:
		other.apply_force(-force, lever)
		rival._incoming_pull = maxf(rival._incoming_pull, force.length() * (1.0 if touches_solid() else 0.2))

## Stick limb i's end to `other` (a PhysicsBody3D) right where it is.
func attach(i: int, other: Object) -> void:
	if other == null or not is_instance_valid(other) or is_ghost(other):
		return
	if other is CollisionObject3D and (other.collision_layer & SOLID_MASK) == 0:
		return
	if other is Node and (other as Node).has_meta("no_weld"):
		return  # Del Mar's buoy: solid, never held (Parker 11-10)
	if climber_of(other) == self:
		return
	var l: Dictionary = limbs[i]
	if l.grab_other != null:
		release(i)
	var end: RigidBody3D = bodies[l.def.end]
	var ob := other as CollisionObject3D
	var at := end.global_position
	var target := climber_of(other)
	if target != null and target.state != State.FROZEN:
		var physics := PhysicsServer3D.body_get_direct_state(end.get_rid())
		if physics != null:
			for j in physics.get_contact_count():
				if physics.get_contact_collider_object(j) == other:
					at = physics.get_contact_collider_position(j)
					at.z = 0
					break
		l.end_offset = end.to_local(at)
		l.contact_offset = ob.to_local(at)
		l.last_anchor = at
		l.contact_force = Vector3.ZERO
		l.strain_time = 0.0
	else:
		# A WELD, as the reference game's grabs are: a hinge on z locked at its current
		# angle, so a stuck hand or foot can't turn on what it holds (a free pin let the
		# standing body topple over its feet at the first lean).
		var rid := PhysicsServer3D.joint_create()
		var frame_end := Transform3D(Basis(), Vector3.ZERO)
		var frame_other := ob.global_transform.affine_inverse() * end.global_transform
		PhysicsServer3D.joint_make_hinge(rid, end.get_rid(), frame_end, ob.get_rid(), Transform3D(Basis(Vector3.BACK, 0.0) * frame_other.basis.orthonormalized(), frame_other.origin))
		PhysicsServer3D.hinge_joint_set_flag(rid, PhysicsServer3D.HINGE_JOINT_FLAG_USE_LIMIT, true)
		PhysicsServer3D.hinge_joint_set_param(rid, PhysicsServer3D.HINGE_JOINT_LIMIT_LOWER, 0.0)
		PhysicsServer3D.hinge_joint_set_param(rid, PhysicsServer3D.HINGE_JOINT_LIMIT_UPPER, 0.0)
		# The end and what it holds must not push apart while stuck. NOT the joint's own
		# disable-collisions flag: on Jolt that exception outlived the freed joint, so a
		# released foot never touched the deck again (0.1.3). An explicit exception,
		# removed on release, is reversible.
		PhysicsServer3D.joint_disable_collisions_between_bodies(rid, false)
		l.grab = rid
		l.grab_rel0 = angle_of(end) - angle_of(ob)
		l.slipping = false
	end.add_collision_exception_with(ob)
	_solid_frame = -1
	l.grab_other = other
	l.grab_climber = null
	l.grab_piece = ""
	if other is RigidBody3D and other.has_meta("climber"):
		var oc := climber_of(other)
		if oc != null and oc != self:
			l.grab_climber = oc
			l.grab_piece = other.get_meta("piece")
			if oc.state != State.FROZEN:
				oc.grabbed_by += 1
				oc.held_by.append(self)
	grab_made.emit(self, i, other)


## THE SLIP (Parker 11-09: "make it so the foot that is connected to the ground rotates
## on the ground as you move if you hit the rotational limit, so you have full freedom
## again ... Add this to the hands as well"). A weld is a hinge locked at one angle. When
## a stuck end's wrist or ankle comes SLIP_EDGE_DEG short of its stop, the weld unlocks
## into a FRICTION PIVOT as stiff as that joint (a foot's ankle holds like a hip, a
## hand's wrist stays loose), so the end turns on its hold with the limb and the body
## keeps its full swing, but stands exactly as firmly as a free ankle held it. Off the
## stop again, the weld locks where the end now sits. (A free turn with no friction let
## the standing body topple over its feet.)
func _tick_slip(dt: float) -> void:
	var weight := total_mass * 9.8 * Feel.climber_gravity(true)
	# THE DRAWN WRIST: the hand you steer turns freely (a stopped one handed its whole
	# swing to the body, which toppled on a plain reach); its mesh is drawn within the
	# stop instead (_draw_wrists). Let go, and the real stop closes back in from wherever
	# the hand is, WRIST_CLOSE_RATE at a time, rather than snapping it.
	for l: Dictionary in limbs:
		if not bool(l.def.arm):
			continue
		var wj: Dictionary = joints[l.end_joint]
		var stop: float = wj.hi
		if l.held:
			if wj.stop_on:
				wj.stop_on = false
				PhysicsServer3D.hinge_joint_set_flag(wj.rid, PhysicsServer3D.HINGE_JOINT_FLAG_USE_LIMIT, false)
			continue
		var bend := absf(wrapf(angle_of(wj.b) - angle_of(wj.a), -PI, PI))
		var win: float = wj.win
		if not wj.stop_on:
			win = maxf(stop, bend + 0.01)
		win = maxf(stop, minf(win, bend + 0.01) - WRIST_CLOSE_RATE * dt)
		if not wj.stop_on or not is_equal_approx(win, float(wj.win)):
			wj.win = win
			set_hinge_limits(wj.rid, -rad_to_deg(win), rad_to_deg(win))
			wj.stop_on = true
	for l: Dictionary in limbs:
		if not (l.grab as RID).is_valid():
			continue
		var jn: String = l.end_joint
		var jd: Dictionary = joints[jn]
		var edge: float = jd.hi - deg_to_rad(SLIP_EDGE_DEG)
		var rel := wrapf(angle_of(jd.b) - angle_of(jd.a), -PI, PI)
		var at_stop := absf(rel) >= edge
		if at_stop:
			var friction := Feel.get_k("joint_friction" if jn.begins_with("ankle") else "wrist_friction") * weight * 0.5
			if not l.slipping:
				l.slipping = true
				PhysicsServer3D.hinge_joint_set_flag(l.grab, PhysicsServer3D.HINGE_JOINT_FLAG_USE_LIMIT, false)
				PhysicsServer3D.hinge_joint_set_flag(l.grab, PhysicsServer3D.HINGE_JOINT_FLAG_ENABLE_MOTOR, true)
				PhysicsServer3D.hinge_joint_set_param(l.grab, PhysicsServer3D.HINGE_JOINT_MOTOR_TARGET_VELOCITY, 0.0)
			PhysicsServer3D.hinge_joint_set_param(l.grab, PhysicsServer3D.HINGE_JOINT_MOTOR_MAX_IMPULSE, friction * dt)
		elif l.slipping and absf(rel) < edge - deg_to_rad(1.0):
			# Lock again where the end sits now (the weld's angle is the end's CCW turn
			# against its hold since it stuck).
			l.slipping = false
			var hold := l.grab_other as Node3D
			var turn := wrapf(angle_of(bodies[l.def.end]) - angle_of(hold) - float(l.grab_rel0), -PI, PI)
			PhysicsServer3D.hinge_joint_set_flag(l.grab, PhysicsServer3D.HINGE_JOINT_FLAG_ENABLE_MOTOR, false)
			PhysicsServer3D.hinge_joint_set_param(l.grab, PhysicsServer3D.HINGE_JOINT_LIMIT_LOWER, turn)
			PhysicsServer3D.hinge_joint_set_param(l.grab, PhysicsServer3D.HINGE_JOINT_LIMIT_UPPER, turn)
			PhysicsServer3D.hinge_joint_set_flag(l.grab, PhysicsServer3D.HINGE_JOINT_FLAG_USE_LIMIT, true)


func release(i: int) -> void:
	var l: Dictionary = limbs[i]
	if l.grab_other == null:
		return
	if l.grab.is_valid():
		PhysicsServer3D.free_rid(l.grab)
		l.grab = RID()
	var end: RigidBody3D = bodies[l.def.end]
	if l.grab_other != null and is_instance_valid(l.grab_other) and l.grab_other is CollisionObject3D:
		end.remove_collision_exception_with(l.grab_other)
	var oc = l.grab_climber
	if oc != null and is_instance_valid(oc) and oc.state != State.FROZEN:
		oc.grabbed_by = maxi(0, oc.grabbed_by - 1)
		oc.held_by.erase(self)
	_solid_frame = -1
	l.grab_other = null
	l.grab_climber = null
	l.grab_piece = ""
	l.regrip = Feel.get_k("regrip_delay")
	grab_lost.emit(self, i)


func release_all() -> void:
	_forget_dead_holds()
	for i in limbs.size():
		release(i)


## THE JOINTS: friction everywhere (a motor holding still with a capped torque, so a
## pose holds until something pushes harder), soft springs in the spine and neck.
## Then THE DRAG on every held hand or foot, while attached.
## The summed drag force this tick (N), for the batteries: never over one budget.
var _drag_total := 0.0


func _touching_solid() -> bool:
	for body: RigidBody3D in bodies.values():
		for other in body.get_colliding_bodies():
			if other.collision_layer & (LAYER_WORLD | LAYER_FROZEN):
				return true
	return false


func _tick_joints(attached: bool, dt: float) -> void:
	var g := 9.8 * (Feel.climber_gravity(true) if attached else Feel.get_k("gravity_scale"))
	var weight := total_mass * g
	var settling := not attached and _touching_solid()
	var aim = driver.aim(self, _active_limb) if attached and _active_limb >= 0 and driver != null else null
	var held_joints := {}
	for l in limbs:
		if l.held and attached:
			held_joints[l.def.root] = true
			held_joints[l.def.mid] = true
			held_joints["wrist_l" if l.def.end == "hand_l" else ("wrist_r" if l.def.end == "hand_r" else ("ankle_l" if l.def.end == "foot_l" else "ankle_r"))] = true
	# A centered stick holds joint angles relative to the body. Pulling toward
	# the old world-space cursor here makes a bent wrist or ankle chase it.
	if aim != null or held_joints.is_empty():
		_neutral_angles.clear()
	elif _neutral_angles.is_empty():
		for jn in held_joints:
			var j: Dictionary = joints[jn]
			_neutral_angles[jn] = angle_of(j.b) - angle_of(j.a)
	var f_root := Feel.get_k("joint_friction") * weight * 0.5
	var f_mid := Feel.get_k("bend_friction") * weight * 0.5
	var f_held := Feel.get_k("held_friction") * weight * 0.5
	var f_end := Feel.get_k("wrist_friction") * weight * 0.5
	var f_fold := Feel.get_k("fold_resistance") * weight * 0.5
	var f_fold_held := Feel.get_k("fold_resistance_held") * weight * 0.5
	var spine_w := Feel.get_k("spine_spring") * 20.0
	var neck_w := Feel.get_k("neck_spring") * 20.0
	for jn in joints:
		var j: Dictionary = joints[jn]
		var rel := wrapf(angle_of(j.b) - angle_of(j.a), -PI, PI)
		var ie: float = j.ieff
		var want_w := 0.0  # rel spin the motor asks for (rad/s, CCW); 0 = friction
		var torque := 0.0  # its torque cap (N m)
		match j.kind:
			"spine":
				want_w = -spine_w * rel
				torque = ie * spine_w * spine_w * absf(rel) + ie * spine_w
			"neck":
				want_w = -neck_w * rel
				torque = ie * neck_w * neck_w * absf(rel) + ie * neck_w
			"end":
				# A planted FOOT's ankle is as stiff as a hip: it holds the body up over
				# the welded foot. A stuck hand's wrist stays loose, so you swing from it.
				if held_joints.has(jn):
					torque = f_held
				elif jn.begins_with("ankle") and _end_stuck(jn):
					torque = f_root
				else:
					torque = f_end
			"mid":
				torque = f_held if held_joints.has(jn) else f_mid
				# THE SOFT FOLD: deep in a fold the joint pushes back toward straight
				# (and past 180, on through), capped so a strong swing still carries.
				var bend := rad_to_deg(absf(rel))
				if bend > FOLD_START_DEG:
					var depth := smoothstep(FOLD_START_DEG, 180.0, bend)
					want_w = -signf(rel) * 6.0
					# The limb you're moving meets a lighter hump you can swing through;
					# every other knee and elbow holds a load like the old stop did (it
					# keeps the body up), and still turns through under enough of one.
					torque = maxf(torque, (f_fold_held if held_joints.has(jn) else f_fold) * depth)
			_:
				torque = f_held if held_joints.has(jn) else f_root
		if _neutral_angles.has(jn):
			want_w = 30.0 * angle_difference(rel, _neutral_angles[jn])
			torque = f_root
		# On a loose landing, let gravity lower the limbs into a passive grip.
		if settling and jn != "neck" and not jn.begins_with("spine"):
			torque = 0.0
		PhysicsServer3D.hinge_joint_set_param(j.rid, PhysicsServer3D.HINGE_JOINT_MOTOR_TARGET_VELOCITY, want_w * MOTOR_SIGN)
		PhysicsServer3D.hinge_joint_set_param(j.rid, PhysicsServer3D.HINGE_JOINT_MOTOR_MAX_IMPULSE, torque * dt)
	_drag_total = 0.0
	for l in limbs:
		l.driving = l.held and attached
	if not attached or aim == null:
		return
	# The cap is in body-weights at FULL gravity, so turning gravity down (Feel
	# gravity_scale) never weakens the hands (Parker 11-07: more force, less gravity).
	var cap := Feel.get_k("drag_strength") * total_mass * 9.8
	var vmax := Feel.get_k("drag_max_speed")
	var k := Feel.get_k("drag_stiffness") * total_mass
	var c := Feel.get_k("drag_damping") * total_mass
	for i in limbs.size():
		var l: Dictionary = limbs[i]
		if not l.held:
			continue
		var target := _aim_target(i, aim)
		_try_exertion(i, aim)
		var end: RigidBody3D = bodies[l.def.end]
		var p := pos2(end)
		var v := Vector2(end.linear_velocity.x, end.linear_velocity.y)
		var swing_force := _drive_swing(aim, target - p, l.l1 + l.l2, cap)
		# A light end needs timestep-safe braking throughout a reachable stick
		# command. Beyond reach, retain the tuned swing until the limb straightens.
		var reach: float = l.l1 + l.l2
		var root := limb_root(i)
		var outward := (target - root) / reach
		var alignment := (p - root).dot(outward.normalized()) / reach
		var extended := smoothstep(0.92, 0.99, alignment) * smoothstep(0.94, 1.0, outward.length())
		var reachable := 1.0 - smoothstep(1.0, 1.04, outward.length()) if aim.has("dir") else 0.0
		var folded := 1.0 - smoothstep(l.min_reach, float(l.min_reach) + 0.05 * reach, target.distance_to(root))
		var damping := lerpf(c, minf(c, end.mass / dt), maxf(folded, maxf(reachable, extended)))
		var f := ((target - p) * k - v * damping).limit_length(maxf(0, cap - swing_force.length()))
		# Limit the full velocity change, including sideways steering at speed.
		# A limb already moving faster from the swing can coast or brake.
		var next_v := v + f * dt / end.mass
		next_v = next_v.limit_length(maxf(vmax, v.length()))
		f = (next_v - v) * end.mass / dt
		if (float_mode or scramble) and not touches_solid():
			if float_mode:
				(bodies["chest"] as RigidBody3D).apply_central_force(Vector3(-f.x, -f.y, 0.0))  # (the swim: no pull on nothing)
			else:
				f = f.limit_length(total_mass * 9.8 * 0.5)  # (the scramble: it drags, it never lifts)
		_drag_total += f.length() + swing_force.length()
		end.apply_central_force(Vector3(f.x, f.y, 0.0))


## Use part of the active limb's budget to turn the whole body about its sole grip.
## Apply the opposite force at the planted end so a moving anchor feels the reaction.
func _drive_swing(aim: Variant, target_error: Vector2, reach: float, cap: float) -> Vector2:
	if not (aim is Dictionary) or stuck_count() != 1:
		return Vector2.ZERO
	var steer := (target_error / reach).limit_length(1.0)
	if aim.has("dir"):
		steer = (aim.dir as Vector2).normalized() * clampf(aim.mag, 0, 1)
	for anchor in limbs:
		if anchor.grab_other == null:
			continue
		var planted: RigidBody3D = bodies[anchor.def.end]
		var tangent := (centre_of_mass() - pos2(planted)).normalized().orthogonal()
		var swing := tangent * steer.dot(tangent) * cap * Feel.get_k("swing_share")
		var force := Vector3(swing.x, swing.y, 0)
		for piece: RigidBody3D in bodies.values():
			piece.apply_central_force(force * piece.mass / total_mass)
		planted.apply_central_force(-force)
		return swing
	return Vector2.ZERO

## Where limb i's held hand or foot is being pulled (world m). The mouse puts it
## on its point. A pad's stick POINTS the limb, at once (Parker 11-07: the stick is
## instant, as in the reference game): the target sits out from the limb's root
## (shoulder or hip) in the stick's direction, at the stick's push times a little
## over the limb's full reach. A resting stick suspends the pull and holds the pose. The cursor
## starts where the hand was when the button went down.
func drag_target(i: int) -> Vector2:
	return _aim_target(i, driver.aim(self, i) if driver != null else null)


func _try_exertion(i: int, aim: Variant) -> void:
	# Only the live driver's actively steered limb calls this. Measure ascent at the torso.
	if _grunt_wait >= 0.0 or not (aim is Dictionary) or stuck_count() == 0:
		return
	var chest: RigidBody3D = bodies["chest"]
	if chest.linear_velocity.y <= 500.0 / Feel.PPM:
		return
	var up := 0.0
	if aim.has("dir"):
		up = (aim.dir as Vector2).normalized().y * clampf(aim.mag, 0.0, 1.0)
	elif aim.has("point"):
		var reach: float = (limbs[i].l1 + limbs[i].l2) * Feel.get_k("stick_reach")
		up = (((aim.point as Vector2) - limb_root(i)) / reach).limit_length(1.0).y
	if up > 0.5:
		_grunt_wait = randf_range(1.5, 3.5)
		exerted.emit()


func _aim_target(i: int, aim: Variant) -> Vector2:
	var l: Dictionary = limbs[i]
	if aim is Dictionary:
		if aim.has("point"):
			var root := limb_root(i)
			var offset: Vector2 = aim.point - root
			if offset.length() < l.min_reach:
				# At the pivot itself, keep the direction the limb already faces.
				var direction := offset.normalized() if not offset.is_zero_approx() else (limb_end(i) - root).normalized()
				l.cursor = root + direction * float(l.min_reach)
			else:
				l.cursor = aim.point
		elif aim.has("dir"):
			var reach: float = (l.l1 + l.l2) * Feel.get_k("stick_reach")
			var radius := maxf(l.min_reach, clampf(float(aim.mag), 0.0, 1.0) * reach)
			l.cursor = limb_root(i) + (aim.dir as Vector2).normalized() * radius
	return l.cursor


## Is the limb whose elbow or knee this is stuck to something?
func _limb_of_mid_stuck(mid_joint: String) -> bool:
	for l in limbs:
		if (l.def.mid as String) == mid_joint:
			return l.grab_other != null
	return false


func _end_stuck(joint_name: String) -> bool:
	for l in limbs:
		if l.grab_other != null and (l.def.end as String) == Layout.JOINTS[joint_name].b:
			return true
	return false


## World position (y-up m) of limb i's root joint and end.
func limb_root(i: int) -> Vector2:
	var j: Dictionary = joints[limbs[i].def.root]
	return xf2(j.a) * (j.local_a as Vector2)


func limb_end(i: int) -> Vector2:
	return pos2(bodies[limbs[i].def.end])


# ---------------------------------------------------------------- freeze, pose, height

## Turn to stone where we are: every piece static, our grabs and joints gone.
## Grabs OTHER climbers hold on us stay: they now hold a static piece.
func freeze() -> void:
	if growing():
		_end_grow()  # frozen mid grow-in: stand at full size first
	set_knockout_visual(false)
	if state == State.FROZEN:
		return
	release_all()
	_free_joints()
	for b in bodies.values():
		var rb: RigidBody3D = b
		rb.linear_velocity = Vector3.ZERO
		rb.angular_velocity = Vector3.ZERO
		rb.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		rb.freeze = true
		rb.collision_layer = LAYER_FROZEN
	state = State.FROZEN
	grabbed_by = 0
	held_by.clear()
	remote_grabbed = 0
	remote_pulls.clear()
	remote_support = false
	set_glyphs([])
	_draw_wrists()  # the hands as they stand, for good
	set_process(false)
	set_physics_process(false)
	for b in bodies.values():
		(b as RigidBody3D).contact_monitor = false  # nothing reads a frozen piece's own contacts
	froze.emit(self)


## Remote climbers: every piece kinematic, moved by apply_pose from the stream.
func make_puppet() -> void:
	state = State.PUPPET
	release_all()
	_free_joints()
	for b in bodies.values():
		var rb: RigidBody3D = b
		rb.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		rb.freeze = true


func _free_joints() -> void:
	for jn in joints:
		PhysicsServer3D.free_rid(joints[jn].rid)
	joints.clear()


## The pose as x, y (m) and angle (rad) per piece, in Layout.ORDER.
func pose() -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(Layout.ORDER.size() * 3)
	var k := 0
	for pname in Layout.ORDER:
		var b: RigidBody3D = bodies[pname]
		# Mid grow-in the pieces are drawn small at the feet: the pose is where they
		# will stand (a freeze, the spawn search and the stream must not get the heap).
		var xf: Transform3D = _grow_full[b] if _grow_t >= 0.0 and _grow_full.has(b) else b.global_transform
		out[k] = xf.origin.x
		out[k + 1] = xf.origin.y
		out[k + 2] = atan2(xf.basis.x.y, xf.basis.x.x)
		k += 3
	return out


func apply_pose(p: PackedFloat32Array) -> void:
	if p.size() < Layout.ORDER.size() * 3:
		return
	if growing():
		_end_grow()  # a pose from outside ends the grow-in: it must not be overwritten
	var k := 0
	for pname in Layout.ORDER:
		var b: RigidBody3D = bodies[pname]
		b.global_transform = Transform3D(Basis(Vector3.BACK, p[k + 2]), Vector3(p[k], p[k + 1], 0.0))
		if state != State.PUPPET:
			sync_server(b)
		k += 3


## The highest point of any piece, metres above y = 0.
func top_height() -> float:
	var best := -INF
	for pname in bodies:
		best = maxf(best, piece_top(pname))
	return best


func piece_top(pname: String) -> float:
	return top_of(pname, xf2(bodies[pname]))


## Top of a piece at a given 2D transform (also used on poses from the network).
func top_of(pname: String, xf: Transform2D) -> float:
	var g: Array = _shape_geo[pname]
	match g[0]:
		"circle":
			return xf.origin.y + g[1]
		"capsule":
			return maxf((xf * (g[1] as Vector2)).y, (xf * (g[2] as Vector2)).y) + g[3]
		"box":
			var he: Vector2 = g[1]
			var top := -INF
			for c in [Vector2(-he.x, -he.y), Vector2(he.x, -he.y), Vector2(he.x, he.y), Vector2(-he.x, he.y)]:
				top = maxf(top, (xf * c).y)
			return top
	return xf.origin.y


## REACH ALONG A DIRECTION (Del Mar, Parker 11-10): how far a piece reaches along
## `d` (not normalised: the line's maths are in its units), its furthest point's
## dot with d. d = (0, 1) is the piece's top; Del Mar's diagonal line uses (1, 1).
func reach_of(pname: String, xf: Transform2D, d: Vector2) -> float:
	var g: Array = _shape_geo[pname]
	match g[0]:
		"circle":
			return xf.origin.dot(d) + float(g[1]) * d.length()
		"capsule":
			return maxf((xf * (g[1] as Vector2)).dot(d), (xf * (g[2] as Vector2)).dot(d)) + float(g[3]) * d.length()
		"box":
			var he: Vector2 = g[1]
			var best := -INF
			for c in [Vector2(-he.x, -he.y), Vector2(he.x, -he.y), Vector2(he.x, he.y), Vector2(-he.x, he.y)]:
				best = maxf(best, (xf * c).dot(d))
			return best
	return xf.origin.dot(d)


## The point where a piece reaches furthest along d (reach_of's own point).
func reach_point_of(pname: String, xf: Transform2D, d: Vector2) -> Vector2:
	var g: Array = _shape_geo[pname]
	var n := d.normalized()
	match g[0]:
		"circle":
			return xf.origin + n * float(g[1])
		"capsule":
			var p1: Vector2 = xf * (g[1] as Vector2)
			var p2: Vector2 = xf * (g[2] as Vector2)
			return (p1 if p1.dot(d) >= p2.dot(d) else p2) + n * float(g[3])
		"box":
			var he: Vector2 = g[1]
			var best := xf.origin
			var best_r := -INF
			for c in [Vector2(-he.x, -he.y), Vector2(he.x, -he.y), Vector2(he.x, he.y), Vector2(-he.x, he.y)]:
				var p: Vector2 = xf * c
				if p.dot(d) > best_r:
					best_r = p.dot(d)
					best = p
			return best
	return xf.origin


## Each piece's furthest point along d: live, and a pose's (the lock-in judges these
## against the line as the camera shows it).
func reach_points(d: Vector2) -> Array:
	var out: Array = []
	for pname in bodies:
		out.append(reach_point_of(pname, xf2(bodies[pname]), d))
	return out


func pose_reach_points(p: PackedFloat32Array, d: Vector2) -> Array:
	var out: Array = []
	var k := 0
	for pname in Layout.ORDER:
		out.append(reach_point_of(pname, Transform2D(p[k + 2], Vector2(p[k], p[k + 1])), d))
		k += 3
	return out


## The climber's reach along d (live bodies), and a pose's (from the network).
func reach(d: Vector2) -> float:
	var best := -INF
	for pname in bodies:
		best = maxf(best, reach_of(pname, xf2(bodies[pname]), d))
	return best


func pose_reach(p: PackedFloat32Array, d: Vector2) -> float:
	var best := -INF
	var k := 0
	for pname in Layout.ORDER:
		best = maxf(best, reach_of(pname, Transform2D(p[k + 2], Vector2(p[k], p[k + 1])), d))
		k += 3
	return best


## Axis-aligned bounds of all collision pieces in a submitted pose.
func pose_bounds(p: PackedFloat32Array) -> Rect2:
	var bounds := Rect2(Vector2(p[0], p[1]), Vector2.ZERO)
	for i in Layout.ORDER.size():
		var k := i * 3
		var xf := Transform2D(p[k + 2], Vector2(p[k], p[k + 1]))
		var piece: String = Layout.ORDER[i]
		var low := Vector2(-top_of(piece, xf.rotated(-PI * 0.5)), -top_of(piece, xf.rotated(PI)))
		var high := Vector2(top_of(piece, xf.rotated(PI * 0.5)), top_of(piece, xf))
		bounds = bounds.expand(low).expand(high)
	return bounds


func pose_top(p: PackedFloat32Array) -> float:
	var best := -INF
	var k := 0
	for pname in Layout.ORDER:
		best = maxf(best, top_of(pname, Transform2D(p[k + 2], Vector2(p[k], p[k + 1]))))
		k += 3
	return best


func centre_of_mass() -> Vector2:
	var acc := Vector2.ZERO
	for b in bodies.values():
		acc += pos2(b) * b.mass
	return acc / maxf(total_mass, 0.001)


func linear_speed() -> float:
	var acc := Vector3.ZERO
	for b in bodies.values():
		acc += b.linear_velocity * b.mass
	return (acc / maxf(total_mass, 0.001)).length()


## Largest gap between a joint's two anchors (m): the "did it tear" number.
var last_worst_gap_joint := ""


func worst_joint_gap() -> float:
	var worst := 0.0
	for jn in Layout.JOINTS:
		var jd: Dictionary = Layout.JOINTS[jn]
		var at: Vector2 = spawn_at + ((jd.at as Vector2) + Layout.shift(jn)) * body_scale
		var la := _rest_local(jd.a, at)
		var lb := _rest_local(jd.b, at)
		var gp := (xf2(bodies[jd.a]) * la).distance_to(xf2(bodies[jd.b]) * lb)
		if gp > worst:
			worst = gp
			last_worst_gap_joint = jn
	return worst


## Largest overshoot past any joint limit (deg): the "do the limits hold" number.
func worst_limit_excess() -> float:
	var worst := 0.0
	for jn in joints:
		var j: Dictionary = joints[jn]
		var rel := wrapf(angle_of(j.b) - angle_of(j.a), -PI, PI)
		if jn.begins_with("wrist"):
			# THE DRAWN WRIST: a steered hand's stop is open on purpose, and a let-go
			# one's closes in from where it was; judge a wrist by its live window.
			if not j.stop_on:
				continue
			worst = maxf(worst, absf(rel) - float(j.win))
			continue
		worst = maxf(worst, maxf(rel - j.hi, j.lo - rel))
	return rad_to_deg(worst)


var _rest_xf := {}


func _rest_local(pname: String, at: Vector2) -> Vector2:
	if not _rest_xf.has(pname):
		_rest_xf[pname] = Transform2D(0.0, spawn_at + _piece_rest_centre(pname)).affine_inverse()
	return _rest_xf[pname] * at


func _piece_rest_centre(pname: String) -> Vector2:
	var shape: Array = Layout.PIECES[pname].shape
	if shape[0] == "capsule":
		return ((shape[1] + shape[2]) * 0.5 + Layout.shift(pname)) * body_scale
	return (shape[1] + Layout.shift(pname)) * body_scale


# Scene teardown can destroy a live climber without calling remove().
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for limb in limbs:
			if limb.grab.is_valid():
				PhysicsServer3D.free_rid(limb.grab)
		_free_joints()
		# NO GHOSTS: the pieces live in the world, not under this node. A climber freed
		# any way but remove() (its game freed under it) takes its pieces with it, so
		# nothing is left standing in the world with a dead climber's name on it.
		for piece in bodies.values():
			if is_instance_valid(piece) and not (piece as Node).is_queued_for_deletion():
				(piece as Node).queue_free()
		if is_instance_valid(_grow_block):
			_grow_block.queue_free()


func remove() -> void:
	if is_instance_valid(_grow_block):
		_grow_block.queue_free()
	_grow_block = null
	set_knockout_visual(false)
	removed = true
	release_all()
	_free_joints()
	for b in bodies.values():
		b.queue_free()
	bodies.clear()
	queue_free()
