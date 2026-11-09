class_name Stage
extends RefCounted
## THE STAGE: the dock, the sea and the barrel. Builds the 2D collision (what you
## touch) and, when there's a 3D root, the dressing (what you see). The 2D outline
## of every solid is its 3D shape cut at the play plane (z = 0).

const BARREL_MODEL := preload("res://models/barrel.glb")

## Stage rows: deck half-width, barrel scale, spawn x, bounds.
const STAGES := {
	"dock": {"name": "The Dock", "deck_half": 9.0, "barrel_scale": 2.1, "spawn_x": 5.5, "kill_y": -4.0, "side_x": 16.0},
	# THE PLAZA RING (Parker's picture): the same flat 18 m deck and barrel, dressed as
	# a wrestling ring on a raised stage in a sunny plaza. Fall off the apron and you
	# drop to the plaza stones (out, respawn), like falling in the sea.
	"plaza": {"name": "The Plaza Ring", "deck_half": 9.0, "barrel_scale": 2.1, "spawn_x": 5.5, "kill_y": -4.0, "side_x": 16.0, "dress": "plaza"},
}
## The plaza's ground level (the ring's canvas is y = 0, its stage stands on this).
const PLAZA_GROUND := -0.9  # the kit ring's apron drops 0.9 m to the plaza
const CANVAS := Color("#ADA28E")  # the ring canvas: mid warm grey, so pale climbers read on it

## The barrel's profile at the plane: (half-width, height) pairs, bottom to top,
## at scale 1.0 (staves bulge 0.44 at the middle, 0.40 at the rims; 0.96 tall).
const BARREL_PROFILE := [
	Vector2(0.39, 0.0), Vector2(0.43, 0.24), Vector2(0.445, 0.48), Vector2(0.43, 0.72), Vector2(0.39, 0.96),
]

var row: Dictionary
var barrel_top := 0.0
var ring_kit: Node3D = null  # the kit ring, once dressed (its ropes animate)
## THE FIRST LINE: the line before anyone is in the tower sits this far above the
## barrel's top, out of a standing climber's reach (Parker 11-07: "I can reach
## straight up at spawn and touch it").
const FIRST_LINE_ABOVE := 0.45
var first_line := 0.0
var barrel_half := 0.0
var bodies: Array = []


func _init(id := "dock") -> void:
	row = STAGES.get(id, STAGES.dock)


func build(world: Node3D, dress := true) -> void:
	var half: float = row.deck_half
	# Deck: a long slab, top at y = 0.
	_static_poly(world, PackedVector2Array([Vector2(-half, 0), Vector2(half, 0), Vector2(half, -1.2), Vector2(-half, -1.2)]), 1.0, 2.0)
	# THE PLAZA FLOOR outside the ring (Parker 11-08: "if you hit the ground outside
	# the ring, it says RING OUT!"): the stones the apron drops to, solid, so a
	# climber lands there instead of falling through.
	if str(row.get("dress", "")) == "plaza":
		for sx in [-1.0, 1.0]:
			var x0: float = sx * half
			var x1: float = sx * float(row.side_x)
			var floor := _static_poly(world, PackedVector2Array([Vector2(minf(x0, x1), PLAZA_GROUND), Vector2(maxf(x0, x1), PLAZA_GROUND), Vector2(maxf(x0, x1), PLAZA_GROUND - 1.0), Vector2(minf(x0, x1), PLAZA_GROUND - 1.0)]), 1.0, 2.0)
			floor.set_meta("plaza_floor", true)
	# Barrel, standing on the deck at x = 0.
	var bs: float = row.barrel_scale
	var pts := PackedVector2Array()
	for p in BARREL_PROFILE:
		pts.append(Vector2(-p.x * bs, p.y * bs))
	for i in range(BARREL_PROFILE.size() - 1, -1, -1):
		var p: Vector2 = BARREL_PROFILE[i]
		pts.append(Vector2(p.x * bs, p.y * bs))
	_static_poly(world, pts, 0.9, 0.6)
	barrel_top = BARREL_PROFILE[-1].y * bs
	first_line = barrel_top + FIRST_LINE_ABOVE
	barrel_half = BARREL_PROFILE[2].x * bs
	if dress:
		if str(row.get("dress", "dock")) == "plaza":
			_dress_plaza(world, half, bs)
		else:
			_dress(world, half, bs)


func spawn_point(side: int) -> Vector2:
	return Vector2(float(row.spawn_x) * (1.0 if side > 0 else -1.0), 0.05)


## THE ROPE BOUNCE (Parker 11-08: "the ropes need to have a bouncing animation when
## they bounce you"): the side's ropes are knocked outward by the hit, then spring
## back with an elastic wobble. side: -1 left, +1 right; speed: the hit (m/s).
func bounce_rope(side: float, speed: float) -> void:
	if ring_kit == null or not is_instance_valid(ring_kit):
		return
	var rope := ring_kit.find_child("ring_ropes_right" if side > 0.0 else "ring_ropes_left", true, false) as MeshInstance3D
	if rope == null or rope.mesh == null:
		return
	# THE FLEX (Parker 11-08: "the middle needs to flex but the sides connected to
	# the posts should stay connected to the posts"): the rope's own mesh bends on a
	# sine along its length, zero at both posts, most in the middle. The rest mesh
	# is kept; the bent one is rebuilt each frame of the spring only.
	if not rope.has_meta("rest_mesh"):
		rope.set_meta("rest_mesh", rope.mesh)
		var mats: Array = []
		for si in rope.mesh.get_surface_count():
			mats.append(rope.get_surface_override_material(si))
		rope.set_meta("rest_mats", mats)
	var push := clampf(speed * 0.06, 0.08, 0.4)
	if rope.has_meta("tween"):
		var old: Tween = rope.get_meta("tween")
		if old != null and old.is_valid():
			old.kill()
	var flex := func(a: float) -> void: _flex_rope(rope, side * a)
	var tw := rope.create_tween()
	tw.tween_method(flex, 0.0, push, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_method(flex, push, 0.0, 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void: _rest_rope(rope))
	rope.set_meta("tween", tw)


## Bend a side rope's mesh out by `dx` at its middle (sine along local z, the
## rope's length, so its ends at the posts don't move).
func _flex_rope(rope: MeshInstance3D, dx: float) -> void:
	var rest: Mesh = rope.get_meta("rest_mesh")
	var bb := rest.get_aabb()
	var z0 := bb.position.z
	var span := maxf(bb.size.z, 0.001)
	var bent := ArrayMesh.new()
	for si in rest.get_surface_count():
		var arrays := rest.surface_get_arrays(si)
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var out := PackedVector3Array()
		out.resize(verts.size())
		for k in verts.size():
			var v := verts[k]
			v.x += dx * sin(PI * clampf((v.z - z0) / span, 0.0, 1.0))
			out[k] = v
		arrays[Mesh.ARRAY_VERTEX] = out
		bent.add_surface_from_arrays(rest.surface_get_primitive_type(si), arrays)
		bent.surface_set_material(si, rest.surface_get_material(si))
	rope.mesh = bent
	_rope_mats(rope)


func _rest_rope(rope: MeshInstance3D) -> void:
	if is_instance_valid(rope) and rope.has_meta("rest_mesh"):
		rope.mesh = rope.get_meta("rest_mesh")
		_rope_mats(rope)


func _rope_mats(rope: MeshInstance3D) -> void:
	var mats: Array = rope.get_meta("rest_mats", [])
	for si in mini(mats.size(), rope.mesh.get_surface_count()):
		if mats[si] != null:
			rope.set_surface_override_material(si, mats[si])


## The ring's half-width (the side ropes stand at +-this).
func ring_half() -> float:
	return float(row.deck_half)


## RING OUT: is this climber down on the plaza floor outside the ring? (Its lowest
## piece near the stones, beyond the apron.) Works on live bodies and puppets.
func ring_out(c) -> bool:
	if str(row.get("dress", "")) != "plaza":
		return false
	for b in c.bodies.values():
		var p: Vector3 = (b as Node3D).global_position
		if absf(p.x) > float(row.deck_half) and p.y < PLAZA_GROUND + 0.25:
			return true
	return false


func out_of_bounds(p: Vector2) -> bool:
	return p.y < float(row.kill_y) or absf(p.x) > float(row.side_x)


## A solid whose outline at the play plane is `pts` (y-up metres), extruded
## through the plane by +-depth so what you see at z = 0 is what you touch.
func _static_poly(world: Node3D, pts: PackedVector2Array, friction: float, depth: float) -> StaticBody3D:
	var sb := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var cv := ConvexPolygonShape3D.new()
	var p3 := PackedVector3Array()
	for p in pts:
		p3.append(Vector3(p.x, p.y, -depth))
		p3.append(Vector3(p.x, p.y, depth))
	cv.points = p3
	col.shape = cv
	sb.add_child(col)
	sb.collision_layer = 1
	sb.collision_mask = 0
	var mat := PhysicsMaterial.new()
	mat.friction = friction
	sb.physics_material_override = mat
	sb.set_meta("stage", true)
	world.add_child(sb)
	bodies.append(sb)
	return sb


# ---------------------------------------------------------------- dressing

func _dress(vis: Node3D, half: float, bs: float) -> void:
	var root := Node3D.new()
	root.name = "StageDressing"
	vis.add_child(root)
	# The barrel: the file stands it along -z; tip it upright (+90 deg about x).
	var barrel: Node3D = BARREL_MODEL.instantiate()
	root.add_child(barrel)
	barrel.transform = Transform3D(Basis(Vector3.RIGHT, PI * 0.5).scaled(Vector3.ONE * bs), Vector3.ZERO)
	CelPass.celify(barrel)
	# The deck: planks across the play plane, deep enough to read as 3D.
	var wood := _mat(Color(0.47, 0.32, 0.2), 0.85)
	var wood_dark := _mat(Color(0.36, 0.24, 0.15), 0.9)
	var n := int(ceil(half * 2.0 / 0.32))
	for i in n:
		var x := -half + 0.16 + i * 0.32
		var plank := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.3, 0.12, 4.0)
		plank.mesh = bm
		plank.material_override = wood if i % 3 != 1 else wood_dark
		plank.position = Vector3(x, -0.06 - (i % 2) * 0.006, -0.6)
		root.add_child(plank)
	# Beams and posts under the deck, into the sea.
	for side in [-1.0, 1.0]:
		var beam := MeshInstance3D.new()
		var bb := BoxMesh.new()
		bb.size = Vector3(half * 2.0, 0.26, 0.26)
		beam.mesh = bb
		beam.material_override = wood_dark
		beam.position = Vector3(0, -0.25, -0.6 + side * 1.6)
		root.add_child(beam)
	for i in range(-4, 5):
		for z in [1.0, -2.2]:
			var post := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 0.16
			cm.bottom_radius = 0.18
			cm.height = 3.2
			post.mesh = cm
			post.material_override = wood_dark
			post.position = Vector3(i * half / 4.0, -1.6, z)
			root.add_child(post)
	# A few crates and a coil of rope at the back, off the play plane.
	var crate_m := _mat(Color(0.55, 0.4, 0.24), 0.8)
	for c in [[-6.8, 0.5, -1.6, 1.0], [-5.9, 0.35, -1.9, 0.7], [7.2, 0.45, -1.7, 0.9], [-6.6, 1.35, -1.7, 0.7]]:
		var crate := MeshInstance3D.new()
		var cb := BoxMesh.new()
		cb.size = Vector3.ONE * c[3]
		crate.mesh = cb
		crate.material_override = crate_m
		crate.position = Vector3(c[0], c[1], c[2])
		crate.rotation.y = c[0] * 0.3
		root.add_child(crate)
	# The sea.
	var sea := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(400, 400)
	sea.mesh = pm
	sea.material_override = CelPass.cel_material(Color(0.2, 0.45, 0.6))
	sea.position = Vector3(0, -1.5, 0)
	root.add_child(sea)
	# Far islands for depth.
	var rock := _mat(Color(0.42, 0.45, 0.4), 1.0)
	var grass := _mat(Color(0.33, 0.52, 0.28), 1.0)
	for isl in [[-40.0, -90.0, 14.0], [25.0, -120.0, 22.0], [70.0, -160.0, 30.0], [-95.0, -150.0, 26.0]]:
		var m := MeshInstance3D.new()
		var sp := SphereMesh.new()
		sp.radius = isl[2]
		sp.height = isl[2] * 0.9
		m.mesh = sp
		m.material_override = grass
		m.position = Vector3(isl[0], -1.5, isl[1])
		root.add_child(m)
		var b := MeshInstance3D.new()
		var cy := CylinderMesh.new()
		cy.top_radius = isl[2] * 0.95
		cy.bottom_radius = isl[2] * 1.05
		cy.height = 3.0
		b.mesh = cy
		b.material_override = rock
		b.position = Vector3(isl[0], -2.0, isl[1])
		root.add_child(b)


## Dressing built in code is born cel (the house look); the ink outlines it.
## The plaza ring: a raised stage with a star-painted apron skirt, a canvas floor,
## padded corner posts with turnbuckles, red / white / blue ropes along the back and
## the sides (none across the front, the camera's side), the barrel in the middle,
## and plaza stones all round. The kit's `ring` replaces the ring when delivered.
func _dress_plaza(vis: Node3D, half: float, bs: float) -> void:
	var root := Node3D.new()
	root.name = "PlazaRing"
	vis.add_child(root)
	var barrel: Node3D = BARREL_MODEL.instantiate()
	root.add_child(barrel)
	barrel.transform = Transform3D(Basis(Vector3.RIGHT, PI * 0.5).scaled(Vector3.ONE * bs), Vector3.ZERO)
	CelPass.celify(barrel)
	var kit := LuchaKit.kit_model("ring")
	var depth := 3.4  # shallow: the front apron must stay out of the camera's lower frame
	var gy := PLAZA_GROUND
	if kit != null:
		# Built at the stage's size (18 x 3.42 m, canvas top at y 0, origin its
		# centre, apron dropping 0.9 m): it goes in at scale 1.
		root.add_child(kit)
		ring_kit = kit
		# The canvas in a mid warm grey: the kit's near-white read pure white in
		# the sun and swallowed the climber's pale legs (environment pass 11-08).
		var canvas := kit.find_child("ring_canvas", true, false) as MeshInstance3D
		if canvas != null:
			canvas.material_override = CelPass.cel_material(CANVAS)
	else:
		var w := half * 2.0
		# The stage block and its skirt panels, then the canvas and its rim.
		# The stage block stops under the canvas (its top showed as a dark strip).
		root.add_child(_boxm(Vector3(w + 0.3, -gy - 0.12, depth + 0.3), LuchaKit.INK, Vector3(0, (gy - 0.12) * 0.5, 0)))
		var skirt := [LuchaKit.BLUE, LuchaKit.RED, LuchaKit.BLUE, LuchaKit.RED, LuchaKit.BLUE, LuchaKit.RED]
		for k in skirt.size():
			var pw := w / skirt.size()
			var panel := _boxm(Vector3(pw - 0.04, -gy - 0.12, 0.06), skirt[k], Vector3(-half + pw * (k + 0.5), gy * 0.5, depth * 0.5 + 0.17))
			root.add_child(panel)
			var star := LuchaKit.star_mesh(0.28, LuchaKit.GOLD)
			star.position = Vector3(-half + pw * (k + 0.5), gy * 0.5, depth * 0.5 + 0.3)
			root.add_child(star)
		root.add_child(_boxm(Vector3(w, 0.08, depth), Color(0.74, 0.77, 0.82), Vector3(0, -0.04, 0)))  # canvas, toned down (it glared white)
		root.add_child(_boxm(Vector3(w + 0.36, 0.14, 0.18), LuchaKit.CREAM, Vector3(0, -0.02, depth * 0.5 + 0.06)))
		root.add_child(_boxm(Vector3(w + 0.36, 0.14, 0.18), LuchaKit.CREAM, Vector3(0, -0.02, -depth * 0.5 - 0.06)))
		# Corner posts, turnbuckle pads and the ropes.
		var pz := depth * 0.5 - 0.1
		var post_h := 1.75
		var corners := [Vector2(-half, -pz), Vector2(half, -pz), Vector2(-half, pz), Vector2(half, pz)]
		for c in corners:
			var post := LuchaKit.cyl(0.11, post_h, LuchaKit.SILVER, Vector3(c.x, post_h * 0.5, c.y))
			root.add_child(post)
			for k in 3:
				var pad := LuchaKit.box(Vector3(0.3, 0.22, 0.3), [LuchaKit.RED, LuchaKit.CREAM, LuchaKit.BLUE][k], Vector3(c.x, 0.5 + k * 0.45, c.y))
				root.add_child(pad)
		# Ring ropes in blue and white, thin: never red, which is the height line's colour.
		var ropes := [LuchaKit.BLUE, LuchaKit.CREAM, LuchaKit.BLUE]
		for k in 3:
			var y := 0.5 + k * 0.45
			root.add_child(LuchaKit.cyl(0.022, half * 2.0, ropes[k], Vector3(0, y, -pz), Vector3.RIGHT))
			for sx in [-1.0, 1.0]:
				root.add_child(LuchaKit.cyl(0.022, pz * 2.0, ropes[k], Vector3(sx * half, y, 0), Vector3.BACK))
		# Ring steps at one corner.
		for k in 3:
			root.add_child(_boxm(Vector3(1.2, 0.36, 0.6), Color(0.3, 0.3, 0.34), Vector3(half + 0.8, gy + 0.18 + k * 0.36, pz - 0.3 - k * 0.6)))
	# The plaza stones, out to the houses and forward under the camera.
	root.add_child(_boxm(Vector3(90.0, 0.3, 40.0), Color(0.82, 0.72, 0.56), Vector3(0, gy - 0.15, -4.0)))
	# (The paving over the stones is LuchaUI._pave: the street, the kerb and the square.)


func _boxm(size: Vector3, c: Color, at: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = CelPass.cel_material(c)
	mi.position = at
	return mi


func _mat(c: Color, _rough: float) -> ShaderMaterial:
	return CelPass.cel_material(c)
