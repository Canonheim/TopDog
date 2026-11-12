class_name PeakDress
extends RefCounted
## SURFACE DETAIL for the Peak's plain pieces (Parker 11-12: "making models for
## everything that is still just block outs"). A solid drawn from the course's data is a
## flat-coloured cardboard shape; this draws what it is made of on its face, as thin
## painted lines in the same mesh: grain on timber, rivets on iron, courses on brick and
## carved stone, a facet on crystal. Rock stays plain card: that is the mountain's look.
## Everything is clipped to the piece's own outline, so any shape can be dressed.

const LINE := 0.032
const MAX_LINES := 260


static func dress(mb: PeakMesh, pts: PackedVector2Array, z: float, kind: String, face: Color, rng: RandomNumberGenerator) -> void:
	if not kind in ["wood", "plank", "root", "iron", "metal", "paint", "brick", "stone", "crystal", "gold", "rotten", "brittle", "bone", "shell"]:
		return
	var lo := pts[0]
	var hi := pts[0]
	for p in pts:
		lo = lo.min(p)
		hi = hi.max(p)
	var size := hi - lo
	if maxf(size.x, size.y) < 0.55:
		return
	var dark := AtlasPalette.matte_uv(face.darkened(0.2))
	var light := AtlasPalette.matte_uv(face.lightened(0.22))
	# The piece's own long way: its longest edge.
	var axis := Vector2.RIGHT
	var longest := 0.0
	for i in pts.size():
		var e := pts[(i + 1) % pts.size()] - pts[i]
		if e.length() > longest:
			longest = e.length()
			axis = e.normalized()
	var across := axis.orthogonal()
	var a0 := INF
	var a1 := -INF
	var c0 := INF
	var c1 := -INF
	for p in pts:
		a0 = minf(a0, p.dot(axis))
		a1 = maxf(a1, p.dot(axis))
		c0 = minf(c0, p.dot(across))
		c1 = maxf(c1, p.dot(across))
	var length := a1 - a0
	var width := c1 - c0
	match kind:
		"wood", "plank", "root", "rotten", "bone":
			# Grain: broken lines along the piece.
			var n := clampi(int(width / 0.3), 1, 4)
			for k in n:
				var off := c0 + width * (float(k) + 0.5) / n + rng.randf_range(-0.03, 0.03)
				var t := a0 + rng.randf_range(0.05, 0.3)
				while t < a1 - 0.1:
					var run := rng.randf_range(0.5, 1.6)
					_line(mb, pts, axis * t + across * off, axis * minf(t + run, a1 - 0.05) + across * off, z, dark)
					t += run + rng.randf_range(0.15, 0.5)
			if kind == "rotten" and length > 0.8:
				# A crack across it: this one won't hold long.
				var at := a0 + length * rng.randf_range(0.35, 0.65)
				_line(mb, pts, axis * (at - 0.08) + across * c0, axis * (at + 0.1) + across * (c0 + width * 0.6), z, AtlasPalette.matte_uv(face.darkened(0.45)), LINE * 1.3)
		"iron", "metal", "paint", "gold":
			# Rivets at each end, and a highlight along the top.
			var rows := 2 if width > 0.3 else 1
			for end in [a0 + 0.12, a1 - 0.12]:
				for r in rows:
					var off := c0 + width * (float(r) + 0.5) / rows
					_dot(mb, pts, axis * end + across * off, 0.035, z, light if kind != "gold" else AtlasPalette.matte_uv(face.lightened(0.4)))
			if length > 1.2:
				var off2 := c1 - width * 0.22 if axis.x >= 0.0 else c0 + width * 0.22
				_line(mb, pts, axis * (a0 + 0.3) + across * off2, axis * (a1 - 0.3) + across * off2, z, light)
		"brick", "stone", "brittle", "shell":
			var course := 0.3 if kind == "brick" else (0.85 if kind == "stone" else 0.5)
			var joint := course * 2.2
			if size.x * size.y > 400.0:
				course *= 2.0
				joint *= 2.0
			var count := 0
			var y := lo.y + course * (0.6 if size.y > course * 1.5 else 2.0)
			var row := 0
			while y < hi.y - 0.05 and count < MAX_LINES:
				_line(mb, pts, Vector2(lo.x - 0.1, y), Vector2(hi.x + 0.1, y), z, dark)
				count += 1
				y += course
				row += 1
			# The upright joints, staggered course by course.
			y = lo.y - course * 0.4
			row = 0
			while y < hi.y and count < MAX_LINES:
				var x := lo.x + joint * (0.25 + 0.5 * float(row % 2))
				while x < hi.x and count < MAX_LINES:
					_line(mb, pts, Vector2(x, y), Vector2(x, y + course), z, dark)
					count += 1
					x += joint
				y += course
				row += 1
		"crystal":
			# One bright facet edge and one dark.
			if length > 0.8:
				_line(mb, pts, axis * (a0 + length * 0.15) + across * (c0 + width * 0.3), axis * (a1 - length * 0.2) + across * (c0 + width * 0.45), z, light, LINE * 1.4)
				_line(mb, pts, axis * (a0 + length * 0.3) + across * (c0 + width * 0.72), axis * (a1 - length * 0.3) + across * (c0 + width * 0.68), z, dark)


## A painted line from a to b, clipped to the piece.
static func _line(mb: PeakMesh, pts: PackedVector2Array, a: Vector2, b: Vector2, z: float, uv: Vector2, w := LINE) -> void:
	if a.distance_to(b) < 0.05:
		return
	for seg: PackedVector2Array in Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([a, b]), pts):
		if seg.size() < 2:
			continue
		var p := seg[0]
		var q := seg[seg.size() - 1]
		var d := q - p
		if d.length() < 0.08:
			continue
		var n := d.normalized().orthogonal() * w * 0.5
		var inset := d.normalized() * minf(0.03, d.length() * 0.2)
		p += inset
		q -= inset
		mb.quad(Vector3(p.x - n.x, p.y - n.y, z), Vector3(q.x - n.x, q.y - n.y, z), Vector3(q.x + n.x, q.y + n.y, z), Vector3(p.x + n.x, p.y + n.y, z), Vector3(0, 0, 1), uv)


static func _dot(mb: PeakMesh, pts: PackedVector2Array, at: Vector2, r: float, z: float, uv: Vector2) -> void:
	if not Geometry2D.is_point_in_polygon(at, pts):
		return
	mb.quad(Vector3(at.x - r, at.y - r, z), Vector3(at.x + r, at.y - r, z), Vector3(at.x + r, at.y + r, z), Vector3(at.x - r, at.y + r, z), Vector3(0, 0, 1), uv)
