class_name Stage
extends RefCounted
## THE STAGE: the dock, the sea and the barrel. Builds the 2D collision (what you
## touch) and, when there's a 3D root, the dressing (what you see). The 2D outline
## of every solid is its 3D shape cut at the play plane (z = 0).

const BARREL_MODEL := preload("res://models/barrel.glb")

## Stage rows: deck half-width, barrel scale, spawn x, bounds.
const STAGES := {
	"dock": {"name": "The Dock", "deck_half": 9.0, "barrel_scale": 1.7, "spawn_x": 5.5, "kill_y": -4.0, "side_x": 16.0},
}

## The barrel's profile at the plane: (half-width, height) pairs, bottom to top,
## at scale 1.0 (staves bulge 0.44 at the middle, 0.40 at the rims; 0.96 tall).
const BARREL_PROFILE := [
	Vector2(0.39, 0.0), Vector2(0.43, 0.24), Vector2(0.445, 0.48), Vector2(0.43, 0.72), Vector2(0.39, 0.96),
]

var row: Dictionary
var barrel_top := 0.0
var barrel_half := 0.0
var bodies: Array = []


func _init(id := "dock") -> void:
	row = STAGES.get(id, STAGES.dock)


func build(world: Node3D, dress := true) -> void:
	var half: float = row.deck_half
	# Deck: a long slab, top at y = 0.
	_static_poly(world, PackedVector2Array([Vector2(-half, 0), Vector2(half, 0), Vector2(half, -1.2), Vector2(-half, -1.2)]), 1.0, 2.0)
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
	barrel_half = BARREL_PROFILE[2].x * bs
	if dress:
		_dress(world, half, bs)


func spawn_point(side: int) -> Vector2:
	return Vector2(float(row.spawn_x) * (1.0 if side > 0 else -1.0), 0.05)


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
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color(0.13, 0.36, 0.48)
	sm.roughness = 0.15
	sm.metallic = 0.1
	sea.material_override = sm
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


func _mat(c: Color, rough: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	return m
