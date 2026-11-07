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
##   and you fall, holding your pose, until an unheld limb catches.
## - The torso is three pieces with springy left/right flex. Nothing steers it; the
##   limbs push on it as they drive.
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
## two spine joints and the neck are soft springs. A climber's own pieces never
## collide with each other.

const Layout := preload("res://climber/body_layout.gd")

const LAYER_WORLD := 1
const LAYER_LIVE := 2
const LAYER_FROZEN := 4
const DEPTH := 0.24  # how thick a box piece is through the plane, for contacts (m)
## The engine's hinge sign conventions, pinned by the --spike "signs" test.
const MOTOR_SIGN := -1.0  # Jolt: a positive motor velocity spins the child CW (pinned by --spike signs)
const LIMIT_FLIP := true  # Jolt: the hinge angle runs clockwise about +z (pinned by --spike signs)

enum State { LIVE, PUPPET, FROZEN }

signal froze(climber: Climber)
signal grab_made(climber: Climber, limb: int, other: Object)
signal grab_lost(climber: Climber, limb: int)

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
var joints := {}  # joint name -> Dictionary
var limbs: Array = []  # per limb: Dictionary (see _build_limbs)
var grabbed_by := 0  # grabs other climbers hold on me (local joints)
var remote_grabbed := 0  # grabs on me reported from other machines
var total_mass := 0.0
var spawn_at := Vector2.ZERO
var live_time := 0.0
var removed := false
## Online: forces other machines' climbers put on my pieces, piece -> Vector2 (N).
var remote_pulls := {}

var _shape_geo := {}  # piece -> [kind, data...] for height reads (local, m)
var _root: Node3D
var _glyphs: Array = []  # per limb: the Sprite3D / Label3D riding the hand or foot


# ---------------------------------------------------------------- frames

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
				centre = shape[1] * s
				var sp := SphereShape3D.new()
				sp.radius = shape[2] * s
				col.shape = sp
				_shape_geo[pname] = ["circle", shape[2] * s]
			"capsule":
				var a: Vector2 = shape[1] * s
				var b: Vector2 = shape[2] * s
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
				centre = shape[1] * s
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
		body.gravity_scale = Feel.get_k("gravity_scale")
		body.linear_damp = Feel.get_k("linear_damp")
		body.angular_damp = Feel.get_k("angular_damp")
		body.can_sleep = false
		body.axis_lock_linear_z = true
		body.axis_lock_angular_x = true
		body.axis_lock_angular_y = true
		body.collision_layer = LAYER_LIVE
		body.collision_mask = LAYER_WORLD | LAYER_LIVE | LAYER_FROZEN
		if _is_end(pname):
			body.continuous_cd = true
			body.contact_monitor = true
			body.max_contacts_reported = 6
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
				mesh.get_parent().remove_child(mesh)
				body.add_child(mesh)
				mesh.global_transform = keep
	if visual != null:
		visual.queue_free()
	# No self-collision: a climber's own pieces pass through each other.
	var names := Layout.ORDER
	for i in names.size():
		for j in range(i + 1, names.size()):
			bodies[names[i]].add_collision_exception_with(bodies[names[j]])
	_build_joints(feet)
	_build_limbs()
	_arms_down()
	set_tint(tint)


## The file's T-pose is the build pose; a climber STANDS with its arms at its sides
## (0.46 m wide, not 1.8 m), so spawns next to each other or next to the barrel
## don't start tangled. Each arm swings 90 degrees about its shoulder, pieces and
## joints together, before the first physics tick.
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
		var at := feet + (jd.at as Vector2) * s
		var at3 := Vector3(at.x, at.y, 0.0)
		var lim: Array = jd.lim
		if jd.kind == "spine":
			var sl := Feel.get_k("spine_limit")
			lim = [-sl, sl]
		var rid := PhysicsServer3D.joint_create()
		# Hinge axis = local z of both frames; frames at the anchor, unrotated.
		PhysicsServer3D.joint_make_hinge(rid, a.get_rid(), Transform3D(Basis(), a.to_local(at3)), b.get_rid(), Transform3D(Basis(), b.to_local(at3)))
		PhysicsServer3D.joint_disable_collisions_between_bodies(rid, true)
		set_hinge_limits(rid, float(lim[0]), float(lim[1]))
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
		var root_at: Vector2 = Layout.JOINTS[ld.root].at * s
		var mid_at: Vector2 = Layout.JOINTS[ld.mid].at * s
		var end_pt: Vector2 = Layout.end_point(ld.end) * s
		var end_shape: Array = Layout.PIECES[ld.end].shape
		var end_r: float = (end_shape[2] if end_shape[0] == "circle" else (end_shape[2] as Vector2).x) * s
		limbs.append({
			"def": ld,
			"l1": root_at.distance_to(mid_at),
			"l2": mid_at.distance_to(end_pt),
			"end_r": end_r,
			"held": false,
			"grab": RID(),  # pin joint RID while stuck
			"grab_other": null,  # the body stuck to
			"grab_climber": null,  # its climber, if it is one
			"grab_piece": "",
			"regrip": 0.0,
			"hold": [0.0, 0.0],  # root/mid targets kept while the stick rests
			"cursor": Vector2.ZERO,  # where a held hand or foot is being steered (world m)
			"driving": false,
		})


## The house look (CelPass: cel shading on the shared colour atlas, inked by the
## screen-space outline), with each climber's knight washed toward its player
## colour. The artist's skins replace the wash; any skin on the 16 Defaultio
## names drops in piece by piece.
func set_tint(c: Color) -> void:
	tint = c
	var wash := Color(1, 1, 1).lerp(c, 0.45)
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
				var mine: ShaderMaterial = cel.duplicate()
				mine.set_shader_parameter("color", wash)
				mi.set_surface_override_material(si, mine)


## THE LIMB GLYPHS (the reference game's idea): the button for each limb sits ON
## the hand or foot, so you never wonder which button is which. Dim when loose,
## bright when held, green when stuck. items: [{"tex": Texture2D or null, "text"}].
func set_glyphs(items: Array) -> void:
	for g in _glyphs:
		if is_instance_valid(g):
			g.queue_free()
	_glyphs.clear()
	for i in mini(items.size(), limbs.size()):
		var end: RigidBody3D = bodies[limbs[i].def.end]
		var item: Dictionary = items[i]
		var node: Node3D
		if item.get("tex") != null:
			var sp := Sprite3D.new()
			sp.texture = item.tex
			sp.pixel_size = 0.0038
			sp.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			sp.no_depth_test = true
			sp.render_priority = 20
			sp.shaded = false
			node = sp
		else:
			var lb := Label3D.new()
			lb.text = str(item.get("text", "?"))
			lb.font_size = 48
			lb.pixel_size = 0.0055
			lb.outline_size = 12
			lb.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			lb.no_depth_test = true
			lb.render_priority = 20
			node = lb
		# Feet sit close together: their glyphs step outward so both read.
		var side := 0.0
		if not bool(limbs[i].def.arm):
			side = -0.16 if limbs[i].def.id == "leg_l" else 0.16
		node.position = Vector3(side, -0.04 if not bool(limbs[i].def.arm) else 0.0, 0.3)
		end.add_child(node)
		_glyphs.append(node)


func _process(_delta: float) -> void:
	if _glyphs.is_empty():
		return
	for i in _glyphs.size():
		var g = _glyphs[i]
		if not is_instance_valid(g):
			continue
		var l: Dictionary = limbs[i]
		var c := Color(1, 1, 1, 0.55)
		var sc := 1.0
		if l.grab.is_valid():
			c = Color(0.55, 1.0, 0.55, 1.0)
			sc = 1.1
		elif l.held:
			c = Color(1, 1, 1, 1)
			sc = 1.25
		if g is Sprite3D:
			(g as Sprite3D).modulate = c
		else:
			(g as Label3D).modulate = c
		g.scale = Vector3.ONE * sc


# ---------------------------------------------------------------- tick

func _physics_process(delta: float) -> void:
	if removed or state != State.LIVE:
		return
	live_time += delta
	var attached := is_attached()
	for i in limbs.size():
		_tick_limb(i, delta)
	_tick_joints(attached)
	for pn in remote_pulls:
		var f: Vector2 = remote_pulls[pn]
		if bodies.has(pn):
			(bodies[pn] as RigidBody3D).apply_central_force(Vector3(f.x, f.y, 0.0))


func is_attached() -> bool:
	if grabbed_by > 0 or remote_grabbed > 0:
		return true
	for l in limbs:
		if l.grab.is_valid():
			return true
	return false


func stuck_count() -> int:
	var n := 0
	for l in limbs:
		if l.grab.is_valid():
			n += 1
	return n


func _tick_limb(i: int, delta: float) -> void:
	var l: Dictionary = limbs[i]
	var held: bool = driver != null and driver.held(i)
	if held and not l.held:
		# Press: pick the limb up. It won't stick while held.
		if l.grab.is_valid():
			release(i)
		l.regrip = 0.0
		l.hold = _current_rel(i)
		l.cursor = limb_end(i)  # steering starts from where the hand is
	elif not held and l.held:
		l.regrip = 0.0  # release: plant it right now if it's on something
	l.held = held
	l.regrip = maxf(0.0, l.regrip - delta)
	if not held and not l.grab.is_valid() and l.regrip <= 0.0:
		_try_grab(i)


func _try_grab(i: int) -> void:
	var l: Dictionary = limbs[i]
	var end: RigidBody3D = bodies[l.def.end]
	# The end pieces report their contacts (contact_monitor), so a stick check is
	# a list read, not a shape query: every unheld limb checks every tick.
	var hits := end.get_colliding_bodies()
	if hits.is_empty():
		return
	# Prefer solid ground (world and tower) over a live rival, then the nearest.
	var best: Object = null
	var best_score := INF
	for o in hits:
		if o == null or o == end:
			continue
		var score := 0.0
		if o is RigidBody3D and o.has_meta("climber"):
			var oc: Climber = o.get_meta("climber")
			if oc == self:
				continue
			if oc.state != State.FROZEN:
				score += 1000.0
		if o is Node3D:
			score += (o as Node3D).global_position.distance_to(end.global_position) * 0.001
		if score < best_score:
			best_score = score
			best = o
	if best != null:
		attach(i, best)


## Stick limb i's end to `other` (a PhysicsBody3D) right where it is.
func attach(i: int, other: Object) -> void:
	var l: Dictionary = limbs[i]
	if l.grab.is_valid():
		release(i)
	var end: RigidBody3D = bodies[l.def.end]
	var ob := other as CollisionObject3D
	var at := end.global_position
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
	end.add_collision_exception_with(ob)
	l.grab = rid
	l.grab_other = other
	l.grab_climber = null
	l.grab_piece = ""
	if other is RigidBody3D and other.has_meta("climber"):
		var oc: Climber = other.get_meta("climber")
		if oc != self:
			l.grab_climber = oc
			l.grab_piece = other.get_meta("piece")
			if oc.state != State.FROZEN:
				oc.grabbed_by += 1
	grab_made.emit(self, i, other)


func release(i: int) -> void:
	var l: Dictionary = limbs[i]
	if not l.grab.is_valid():
		return
	PhysicsServer3D.free_rid(l.grab)
	l.grab = RID()
	var end: RigidBody3D = bodies[l.def.end]
	if l.grab_other != null and is_instance_valid(l.grab_other) and l.grab_other is CollisionObject3D:
		end.remove_collision_exception_with(l.grab_other)
	var oc = l.grab_climber
	if oc != null and is_instance_valid(oc) and oc.state != State.FROZEN:
		oc.grabbed_by = maxi(0, oc.grabbed_by - 1)
	l.grab_other = null
	l.grab_climber = null
	l.grab_piece = ""
	l.regrip = Feel.get_k("regrip_delay")
	grab_lost.emit(self, i)


func release_all() -> void:
	for i in limbs.size():
		release(i)


## THE JOINTS: friction everywhere (a motor holding still with a capped torque, so a
## pose holds until something pushes harder), soft springs in the spine and neck.
## Then THE DRAG on every held hand or foot, while attached.
func _tick_joints(attached: bool) -> void:
	var g := 9.8 * Feel.get_k("gravity_scale")
	var dt := 1.0 / float(Engine.physics_ticks_per_second)
	var weight := total_mass * g
	var held_joints := {}
	for l in limbs:
		l.driving = l.held and attached
		if l.held:
			held_joints[l.def.root] = true
			held_joints[l.def.mid] = true
			held_joints["wrist_l" if l.def.end == "hand_l" else ("wrist_r" if l.def.end == "hand_r" else ("ankle_l" if l.def.end == "foot_l" else "ankle_r"))] = true
	var f_root := Feel.get_k("joint_friction") * weight * 0.5
	var f_mid := Feel.get_k("bend_friction") * weight * 0.5
	var f_held := Feel.get_k("held_friction") * weight * 0.5
	var f_end := Feel.get_k("wrist_friction") * weight * 0.5
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
			_:
				torque = f_held if held_joints.has(jn) else f_root
		PhysicsServer3D.hinge_joint_set_param(j.rid, PhysicsServer3D.HINGE_JOINT_MOTOR_TARGET_VELOCITY, want_w * MOTOR_SIGN)
		PhysicsServer3D.hinge_joint_set_param(j.rid, PhysicsServer3D.HINGE_JOINT_MOTOR_MAX_IMPULSE, torque * dt)
	if not attached:
		return
	var cap := Feel.get_k("drag_strength") * weight
	var k := Feel.get_k("drag_stiffness") * total_mass
	var c := Feel.get_k("drag_damping") * total_mass
	for i in limbs.size():
		var l: Dictionary = limbs[i]
		if not l.held:
			continue
		var target := drag_target(i)
		var end: RigidBody3D = bodies[l.def.end]
		var p := pos2(end)
		var v := Vector2(end.linear_velocity.x, end.linear_velocity.y)
		var f := ((target - p) * k - v * c).limit_length(cap)
		end.apply_central_force(Vector3(f.x, f.y, 0.0))


## Where limb i's held hand or foot is being pulled (world m). The mouse puts it
## on its point; a pad's stick moves it like a cursor (Feel hand_speed) and a
## resting stick leaves it. It starts where the hand was when the button went down.
func drag_target(i: int) -> Vector2:
	var l: Dictionary = limbs[i]
	var aim = driver.aim(self, i) if driver != null else null
	if aim is Dictionary:
		if aim.has("point"):
			l.cursor = aim.point
		elif aim.has("dir"):
			var dt := 1.0 / float(Engine.physics_ticks_per_second)
			l.cursor += (aim.dir as Vector2).normalized() * clampf(float(aim.mag), 0.0, 1.0) * Feel.get_k("hand_speed") * dt
			# A stick-steered target stays within a stretch of the limb's root, so it
			# can't wander off-screen while the hand is held back.
			var S := limb_root(i)
			var reach: float = (l.l1 + l.l2) * 1.25
			if l.cursor.distance_to(S) > reach:
				l.cursor = S + (l.cursor - S).normalized() * reach
	return l.cursor


## Is the limb whose elbow or knee this is stuck to something?
func _limb_of_mid_stuck(mid_joint: String) -> bool:
	for l in limbs:
		if (l.def.mid as String) == mid_joint:
			return l.grab.is_valid()
	return false


func _end_stuck(joint_name: String) -> bool:
	for l in limbs:
		if l.grab.is_valid() and (l.def.end as String) == Layout.JOINTS[joint_name].b:
			return true
	return false


func _current_rel(i: int) -> Array:
	var l: Dictionary = limbs[i]
	var r: Dictionary = joints.get(l.def.root, {})
	var m: Dictionary = joints.get(l.def.mid, {})
	if r.is_empty() or m.is_empty():
		return [0.0, 0.0]
	return [wrapf(angle_of(r.b) - angle_of(r.a), -PI, PI), wrapf(angle_of(m.b) - angle_of(m.a), -PI, PI)]


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
	remote_grabbed = 0
	remote_pulls.clear()
	for g in _glyphs:
		if is_instance_valid(g):
			g.visible = false
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
		var p := pos2(b)
		out[k] = p.x
		out[k + 1] = p.y
		out[k + 2] = angle_of(b)
		k += 3
	return out


func apply_pose(p: PackedFloat32Array) -> void:
	if p.size() < Layout.ORDER.size() * 3:
		return
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


## The top a pose would have, without moving the body.
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
		var at: Vector2 = spawn_at + (jd.at as Vector2) * body_scale
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
		return (shape[1] + shape[2]) * 0.5 * body_scale
	return shape[1] * body_scale


func remove() -> void:
	removed = true
	release_all()
	_free_joints()
	for b in bodies.values():
		b.queue_free()
	bodies.clear()
	queue_free()
