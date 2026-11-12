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


func commit() -> ArrayMesh:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	var m := ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return m
