class_name PeakMesh
extends RefCounted
## Builds one drawn mesh out of many flat-coloured cardboard pieces. Each vertex carries
## its colour's atlas texel as its UV, so the whole thing wears THE ONE MATERIAL
## (CelPass.one()), or a single painted colour when the UVs are left at zero.

var verts := PackedVector3Array()
var normals := PackedVector3Array()
var uvs := PackedVector2Array()


func empty() -> bool:
	return verts.is_empty()


## One triangle facing `want` (Godot draws the clockwise side).
func tri(a: Vector3, b: Vector3, c: Vector3, want: Vector3, uv: Vector2) -> void:
	if (b - a).cross(c - a).dot(want) > 0.0:
		var t := b
		b = c
		c = t
	verts.append(a)
	verts.append(b)
	verts.append(c)
	for i in 3:
		normals.append(want)
		uvs.append(uv)


func quad(a: Vector3, b: Vector3, c: Vector3, d: Vector3, want: Vector3, uv: Vector2) -> void:
	tri(a, b, c, want, uv)
	tri(a, c, d, want, uv)


## A polygon extruded from z0 (back) to z1 (front): its face, its back, its edge.
func prism(pts: PackedVector2Array, z0: float, z1: float, face_uv: Vector2, edge_uv: Vector2) -> void:
	var idx := Geometry2D.triangulate_polygon(pts)
	for k in range(0, idx.size(), 3):
		var a := pts[idx[k]]
		var b := pts[idx[k + 1]]
		var c := pts[idx[k + 2]]
		tri(Vector3(a.x, a.y, z1), Vector3(b.x, b.y, z1), Vector3(c.x, c.y, z1), Vector3(0, 0, 1), face_uv)
		tri(Vector3(a.x, a.y, z0), Vector3(b.x, b.y, z0), Vector3(c.x, c.y, z0), Vector3(0, 0, -1), edge_uv)
	var n := pts.size()
	var area := 0.0
	for i in n:
		area += pts[i].cross(pts[(i + 1) % n])
	var ccw := area > 0.0  # (y up)
	for i in n:
		var a := pts[i]
		var b := pts[(i + 1) % n]
		var out := Vector2(b.y - a.y, a.x - b.x).normalized()
		if not ccw:
			out = -out
		quad(Vector3(a.x, a.y, z1), Vector3(b.x, b.y, z1), Vector3(b.x, b.y, z0), Vector3(a.x, a.y, z0), Vector3(out.x, out.y, 0), edge_uv)


## A thin band just inside a polygon's edge, on its face: the wet shine of slick rock.
func rim(pts: PackedVector2Array, z: float, width: float, uv: Vector2) -> void:
	var n := pts.size()
	var area := 0.0
	for i in n:
		area += pts[i].cross(pts[(i + 1) % n])
	var side := 1.0 if area > 0.0 else -1.0
	for i in n:
		var a := pts[i]
		var b := pts[(i + 1) % n]
		if a.distance_to(b) < 1.2:
			continue
		var inward := Vector2(-(b.y - a.y), b.x - a.x).normalized() * side * width
		var along := (b - a).normalized() * width
		quad(Vector3(a.x + along.x, a.y + along.y, z), Vector3(b.x - along.x, b.y - along.y, z), Vector3(b.x - along.x + inward.x, b.y - along.y + inward.y, z), Vector3(a.x + along.x + inward.x, a.y + along.y + inward.y, z), Vector3(0, 0, 1), uv)


## A ROCK FACE on a polygon's front (Parker 11-12: "the walls should look like walls"):
## the flat card becomes facets, standing out from `z_low` at the outline to `z_high` in
## places, each a flat plane with its own tilt, so the light breaks on it like cut rock.
## The high and low points sit on ONE lattice for the whole mountain (LATTICE), each with
## its own fixed height, so two pieces that overlap carry the same face where they do
## and never poke through each other in patches.
## `tones`: three atlas texels, [lit, plain, shaded]. `into`: for one-colour meshes (the
## slick rock), three meshes to take the lit, plain and shaded facets instead (each drawn
## in its own shade of the colour, facing the camera: on a tilted normal the slick's
## sheen went white in sunlight). `lift` brings the whole face that much forward (grip
## rock stands a hair in front of slick where they share a face).
const LATTICE := 1.7


static func _lattice(i: int, j: int, k: int) -> float:
	var h := (i * 73856093) ^ (j * 19349663) ^ (k * 83492791)
	h = (h ^ (h >> 13)) * 1274126177
	return float((h ^ (h >> 16)) & 0xFFFF) / 65535.0


func facets(pts: PackedVector2Array, z_low: float, z_high: float, tones: Array, into: Array = [], lift := 0.0) -> void:
	var n := pts.size()
	var lo := pts[0]
	var hi := pts[0]
	for i in n:
		lo = lo.min(pts[i])
		hi = hi.max(pts[i])
	var g := LATTICE
	var points := PackedVector2Array()
	var depth := PackedFloat32Array()
	# The outline: its corners, and its long edges cut up.
	for i in n:
		var a := pts[i]
		var b := pts[(i + 1) % n]
		var steps := maxi(1, ceili(a.distance_to(b) / (g * 1.3)))
		for k in steps:
			points.append(a.lerp(b, float(k) / steps))
			depth.append(z_low + lift)
	var rim_count := points.size()
	# Inside: the lattice's points that lie in it, clear of its edge.
	var row_h := g * 0.87
	for j in range(floori(lo.y / row_h), ceili(hi.y / row_h) + 1):
		for i in range(floori(lo.x / g) - 1, ceili(hi.x / g) + 1):
			var p := Vector2((i + (0.5 if j % 2 != 0 else 0.0) + (_lattice(i, j, 1) - 0.5) * 0.64) * g, (j + (_lattice(i, j, 2) - 0.5) * 0.64) * row_h)
			if p.x < lo.x or p.x > hi.x or p.y < lo.y or p.y > hi.y or not Geometry2D.is_point_in_polygon(p, pts):
				continue
			var clear := true
			for e in n:
				if Geometry2D.get_closest_point_to_segment(p, pts[e], pts[(e + 1) % n]).distance_to(p) < 0.5:
					clear = false
					break
			if clear:
				points.append(p)
				depth.append(lerpf(z_low, z_high, pow(_lattice(i, j, 3), 0.7)) + lift)
	if points.size() - rim_count < 1:
		return
	var idx := Geometry2D.triangulate_delaunay(points)
	for k in range(0, idx.size(), 3):
		var a2 := points[idx[k]]
		var b2 := points[idx[k + 1]]
		var c2 := points[idx[k + 2]]
		if not Geometry2D.is_point_in_polygon((a2 + b2 + c2) / 3.0, pts):
			continue
		var a3 := Vector3(a2.x, a2.y, depth[idx[k]])
		var b3 := Vector3(b2.x, b2.y, depth[idx[k + 1]])
		var c3 := Vector3(c2.x, c2.y, depth[idx[k + 2]])
		var want := (b3 - a3).cross(c3 - a3).normalized()
		if want.z < 0.0:
			want = -want
		var which := 1
		if want.y > 0.1:
			which = 0
		elif want.y < -0.1:
			which = 2
		if into.is_empty():
			tri(a3, b3, c3, want, tones[which])
		else:
			(into[which] as PeakMesh).tri(a3, b3, c3, Vector3(0, 0, 1), Vector2.ZERO)


func commit() -> ArrayMesh:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	var m := ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return m
