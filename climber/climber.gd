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
##   or foot stuck to the arena or frozen stack. Pick up your last stuck limb
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
## two spine joints and the neck are soft springs. A hand or foot can contact
## its own upper segment at a deep fold.

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
signal limb_selected(index: int, release_velocity: Vector3)
signal grab_made(climber: Climber, limb: int, other: Object)
signal release_contact(position: Vector3)
signal exerted

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
var total_mass := 0.0
var spawn_at := Vector2.ZERO
var live_time := 0.0
var removed := false
var _shape_geo := {}  # piece -> [kind, data...] for height reads (local, m)
var _grunt_wait := 2.0
var _active_limb := -1
var _neutral_angles := {}
var _buttons_down := [false, false, false, false]
var _gravity_scale := -1.0
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
		body.collision_mask = LAYER_WORLD | LAYER_LIVE | LAYER_FROZEN
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
	if visual != null:
		visual.queue_free()
	# Connected shapes overlap at their hinge. Let only the non-adjacent pair
	# within each limb collide. Other limbs and the torso can cross its path.
	var upper_by_end := {}
	for limb in Layout.LIMBS:
		upper_by_end[limb.end] = limb.up
	var names := Layout.ORDER
	for i in names.size():
		for j in range(i + 1, names.size()):
			if upper_by_end.get(names[i]) == names[j] or upper_by_end.get(names[j]) == names[i]:
				continue
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
		# The whole limb can revolve about the shoulder or hip. Stops between
		# adjacent pieces keep them from folding through their shared hinge.
		if jd.kind in ["spine", "neck", "mid"]:
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
		var fold_angle: float = joints[ld.mid].hi
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
			"regrip": 0.0,
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
		# Feet sit close together: their glyphs step outward so both read.
		var side := 0.0
		if not bool(limbs[i].def.arm):
			side = -0.16 if limbs[i].def.id == "leg_l" else 0.16
		node.position = Vector3(side, -0.04 if not bool(limbs[i].def.arm) else 0.0, 0.3)
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
static func _on_disc(tex: Texture2D, disc := true) -> Texture2D:
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
	if _glyphs.is_empty():
		return
	for i in _glyphs.size():
		var g = _glyphs[i]
		if not is_instance_valid(g):
			continue
		var l: Dictionary = limbs[i]
		var c := Color(1, 1, 1, 0.55)
		var sc := 1.0
		var stuck: bool = l.grab.is_valid()
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


# ---------------------------------------------------------------- tick

func _physics_process(delta: float) -> void:
	if removed or state != State.LIVE:
		return
	live_time += delta
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
func is_attached() -> bool:
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


# A fresh press takes over. Older held buttons must be pressed again to unplant.
# For edges sampled in the same tick, use the first limb in controller order.
func active_limb() -> int:
	return _active_limb


func _select_active_limb() -> void:
	var previous := _active_limb
	var pressed := -1
	for i in limbs.size():
		var down: bool = driver != null and driver.held(i)
		if down and not _buttons_down[i] and pressed == -1:
			pressed = i
		_buttons_down[i] = down
	if pressed != -1:
		_active_limb = pressed
	elif _active_limb != -1 and not _buttons_down[_active_limb]:
		_active_limb = -1
	if previous != _active_limb:
		var velocity := Vector3.ZERO
		if previous >= 0:
			var end: RigidBody3D = bodies[limbs[previous].def.end]
			velocity = end.linear_velocity
		limb_selected.emit(_active_limb, velocity)


func _tick_limb(i: int, delta: float) -> void:
	var l: Dictionary = limbs[i]
	var held := i == _active_limb
	var just_released: bool = l.held and not held
	if held and not l.held:
		# Press: pick the limb up. It won't stick while held.
		if l.grab.is_valid():
			release(i)
		l.regrip = 0.0
		_neutral_angles.clear()
		l.cursor = limb_end(i)  # steering starts from where the hand is
	elif just_released:
		l.regrip = 0.0  # release: plant it right now if it's on something
	l.held = held
	l.regrip = maxf(0.0, l.regrip - delta)
	if not held and not l.grab.is_valid() and l.regrip <= 0.0:
		_try_grab(i)
		if just_released and l.grab.is_valid():
			var end: RigidBody3D = bodies[l.def.end]
			release_contact.emit(end.global_position)


func _try_grab(i: int) -> void:
	var l: Dictionary = limbs[i]
	var end: RigidBody3D = bodies[l.def.end]
	# The end pieces report their contacts (contact_monitor), so a stick check is
	# a list read, not a shape query: every unheld limb checks every tick.
	var hits := end.get_colliding_bodies()
	if hits.is_empty():
		return
	# Only the arena and frozen stack are valid anchors.
	var best: Object = null
	var best_score := INF
	for o in hits:
		if o == null or o == end:
			continue
		var score := 0.0
		if o is RigidBody3D and o.has_meta("climber"):
			var oc: Climber = o.get_meta("climber")
			if oc == self or oc.state != State.FROZEN:
				continue
		if o is Node3D:
			score += (o as Node3D).global_position.distance_to(end.global_position) * 0.001
		if score < best_score:
			best_score = score
			best = o
	if best != null:
		attach(i, best)


## Stick limb i's end to `other` (a PhysicsBody3D) right where it is.
func attach(i: int, other: Object) -> void:
	if other.has_meta("climber"):
		var target: Climber = other.get_meta("climber")
		if target == self or target.state != State.FROZEN:
			return
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
	if other is RigidBody3D and other.has_meta("climber"):
		var oc: Climber = other.get_meta("climber")
		if oc != self:
			l.grab_climber = oc
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
	l.grab_other = null
	l.grab_climber = null
	l.regrip = Feel.get_k("regrip_delay")


func release_all() -> void:
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
		if not anchor.grab.is_valid():
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
			return l.grab.is_valid()
	return false


func _end_stuck(joint_name: String) -> bool:
	for l in limbs:
		if l.grab.is_valid() and (l.def.end as String) == Layout.JOINTS[joint_name].b:
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


func remove() -> void:
	removed = true
	release_all()
	_free_joints()
	for b in bodies.values():
		b.queue_free()
	bodies.clear()
	queue_free()
