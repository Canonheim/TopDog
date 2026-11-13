extends Node
## THE PEAK, WATCHED: the real game (main.tscn) in a small window, its climber stood where
## a thing happens, the thing made to happen, and the window saved as pictures. Written for
## the 11-12 playtest's fixes (docs/peak/playtest/WORK_LOG.md): each scene below is one
## note's check. It prints what it measured as "WATCH ..." lines.
##   Godot_console.exe --path . --audio-driver Dummy res://tests/peak_watch.tscn -- --no-steam --out=DIR --watch=cam,plank
## A scene may take arguments after a colon: --watch=cam:1.4:1.6:9.3
## Run it with APPDATA pointed at a scratch folder: main reads the player's own display
## setting and would go full screen with it.
const SIZE := Vector2i(1280, 720)

var main: Node
var pk: Peak
var out := "user://peak_watch"
var prefix := ""
var _free_cam := false
var _cam_at := Vector2.ZERO
var _cam_half := 5.0


func _ready() -> void:
	process_priority = 1000  # after main: a free camera is set over the game's own
	var scenes: Array = []
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.get_slice("=", 1)
		elif a.begins_with("--watch="):
			scenes = Array(a.get_slice("=", 1).split(","))
		elif a.begins_with("--prefix="):
			prefix = a.get_slice("=", 1)
	DirAccess.make_dir_recursive_absolute(out)
	main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(0.5).timeout
	_window()
	main._start_peak()
	for i in 600:
		await get_tree().process_frame
		pk = main.game.peak
		if pk != null and pk.player != null and pk.player.live_time > 0.4:
			break
	if pk == null or pk.player == null:
		print("WATCH no climber")
		get_tree().quit(1)
		return
	pk.dev_warp = true  # never the save
	_window()
	for s: String in scenes:
		var parts := s.split(":")
		var fn := "_w_" + parts[0]
		if not has_method(fn):
			print("WATCH no scene ", parts[0])
			continue
		_free_cam = false
		print("WATCH scene ", s)
		await call(fn, Array(parts.slice(1)))
	get_tree().quit(0)


func _window() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(SIZE)
	DisplayServer.window_set_position(Vector2i(4000, 3000))  # off every screen: it still draws


func _process(_delta: float) -> void:
	if main != null and main.get("_focus_notice") != null:
		(main.get("_focus_notice") as CanvasItem).visible = false  # (the window is off screen and unfocused on purpose)
	if _free_cam and main != null:
		var cam: Camera3D = main.cam
		var dist := _cam_half / tan(deg_to_rad(cam.fov * 0.5))
		cam.position = Vector3(_cam_at.x + Peak.ORIGIN.x, _cam_at.y + Peak.ORIGIN.y, dist)
		cam.look_at(Vector3(cam.position.x, cam.position.y, 0.0), Vector3.UP)


# ---------------------------------------------------------------- helpers

func secs(s: float) -> void:
	await get_tree().create_timer(s, false, true).timeout


func ticks(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	if img.get_size() != SIZE:
		img.resize(SIZE.x, SIZE.y, Image.INTERPOLATE_LANCZOS)
	var path := out.path_join(prefix + name + ".jpg")
	img.save_jpg(path, 0.82)
	print("WATCH shot ", path)


## The game's camera, pointed by hand: `at` in the course's metres, `half` its half height.
func look(at: Vector2, half: float) -> void:
	_free_cam = true
	_cam_at = at
	_cam_half = half


func me() -> Climber:
	return pk.player


## Stand the climber with its feet on a point (the course's metres), holding nothing.
func stand(at: Vector2) -> void:
	var c := me()
	c.release_all()
	var p := c.pose()
	var com := c.centre_of_mass()
	var low := INF
	for b: RigidBody3D in c.bodies.values():
		low = minf(low, b.global_position.y)
	var feet := pk.world_of(at)
	var shift := Vector2(feet.x - com.x, feet.y - low + 0.17)
	for k in range(0, p.size(), 3):
		p[k] += shift.x
		p[k + 1] += shift.y
	c.apply_pose(p)
	still()


func still() -> void:
	for b: RigidBody3D in me().bodies.values():
		b.linear_velocity = Vector3.ZERO
		b.angular_velocity = Vector3.ZERO


## Move the whole climber so limb i's end is on a point (the course's metres).
func put_limb(i: int, at: Vector2) -> void:
	var c := me()
	var d := pk.world_of(at) - c.limb_end(i)
	var p := c.pose()
	for k in range(0, p.size(), 3):
		p[k] += d.x
		p[k + 1] += d.y
	c.apply_pose(p)
	still()


func where() -> Vector2:
	return pk.player_at()


func holds() -> String:
	var c := me()
	var s: Array = []
	for i in c.limbs.size():
		var o = c.limbs[i].grab_other
		s.append("-" if o == null else str((o as Node).name))
	return " ".join(s)


# ---------------------------------------------------------------- the scenes

## The camera at challenges' starts: cam:1.4:1.6 ...
func _w_cam(ids: Array) -> void:
	var first := true
	for id: String in ids:
		pk.warp(id)
		await secs(6.5 if first else 3.5)  # (the area's banner clears)
		first = false
		var cam: Camera3D = main.cam
		var half: float = cam.position.z * tan(deg_to_rad(cam.fov * 0.5))
		var p := where()
		print("WATCH cam %s: view %.1f m tall, climber %.2f m %s the middle" % [id, half * 2.0, absf(p.y + Peak.ORIGIN.y - cam.position.y), "above" if p.y + Peak.ORIGIN.y > cam.position.y else "below"])
		await shot("cam_" + id.replace(".", "_"))


# ---------------------------------------------------------------- more helpers

## The hold with a behaviour whose outline's middle is nearest a point.
func hold_near(at: Vector2, type: String) -> Dictionary:
	var best := {}
	var best_d := INF
	for h: Dictionary in pk.things.holds:
		if str(h.type) != type or not (h.body as Node).has_meta("peak_pts"):
			continue
		var d: float = pk.things._hold_middle(h.body).distance_to(at)
		if d < best_d:
			best_d = d
			best = h
	return best


## Where a node's drawn meshes are, in the course's metres: [middle, size].
func drawn_box(n: Node3D) -> Array:
	var box := AABB()
	var first := true
	var list: Array = n.find_children("*", "MeshInstance3D", true, false)
	if n is MeshInstance3D:
		list.append(n)
	for mi: MeshInstance3D in list:
		if mi.mesh == null:
			continue
		var b := mi.global_transform * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	var mid := box.get_center()
	return [Vector2(mid.x - Peak.ORIGIN.x, mid.y - Peak.ORIGIN.y), Vector2(box.size.x, box.size.y)]


## A mover's collision, outlined in a loud colour in front of everything (proof in a
## picture that the drawn thing and the solid thing agree).
func outline(m: Dictionary, col := Color(0.2, 1.0, 1.0)) -> Node3D:
	var im := ImmediateMesh.new()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = col
	mat.no_depth_test = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	im.surface_begin(Mesh.PRIMITIVE_TRIANGLES, mat)
	for sh in (m.def as Dictionary).shapes:
		var pts: PackedVector2Array = pk._pts(sh.pts)
		for i in pts.size():
			var a := pts[i]
			var b := pts[(i + 1) % pts.size()]
			var n := (b - a).normalized().orthogonal() * 0.012
			for p: Vector2 in [a - n, b - n, b + n, a - n, b + n, a + n]:
				im.surface_add_vertex(Vector3(p.x, p.y, 0.0))  # (in the play plane: no parallax against the model)
	im.surface_end()
	var mi := MeshInstance3D.new()
	mi.mesh = im
	(m.nodes[0] as Node3D).add_child(mi)
	return mi


func mover_at(id: String) -> Vector2:
	var m: Dictionary = pk.things.movers[id]
	return (m.home as Vector2) + (m.offset as Vector2)


## "drawn a..b across, c..d up" of a mover's model against the mover's own zero.
func drawn_span(id: String) -> String:
	var m: Dictionary = pk.things.movers[id]
	var box := drawn_box(m.vis)
	var mid: Vector2 = (box[0] as Vector2) - mover_at(id)
	var half: Vector2 = (box[1] as Vector2) * 0.5
	return "%.2f..%.2f across, %.2f..%.2f up" % [mid.x - half.x, mid.x + half.x, mid.y - half.y, mid.y + half.y]


# ---------------------------------------------------------------- the playtest's scenes

## Note 1: a rotten plank of 1.3 breaks and comes back. It must grow where it stands.
func _w_plank(_a: Array) -> void:
	stand(Vector2(-175.0, 6.0))
	await secs(1.0)
	var h := hold_near(Vector2(-178.9, 5.84), "crumble")
	var mid: Vector2 = pk.things._hold_middle(h.body)
	look(Vector2(-178.9, 5.6), 2.4)
	await secs(0.5)
	await shot("01_plank_whole")
	h.break_at = pk.clock + 0.4  # (as if a hand had been on it)
	await secs(0.3)
	await shot("01_plank_shudder")
	while float(h.back_at) < 0.0:
		await get_tree().physics_frame
	await secs(0.35)
	await shot("01_plank_broken")
	h.back_at = pk.clock + 0.8  # (not the whole 8 s)
	var v: Node3D = h.vis
	while not v.visible:
		await get_tree().process_frame
	var worst := 0.0
	var t0 := Time.get_ticks_msec()
	var n := 0
	while Time.get_ticks_msec() - t0 < 600:
		var box := drawn_box(v)
		worst = maxf(worst, (box[0] as Vector2).distance_to(mid))
		var el := Time.get_ticks_msec() - t0
		if (n == 0 and el >= 40) or (n == 1 and el >= 110) or (n == 2 and el >= 200):
			print("WATCH plank mid-return %d ms: scale %.2f, drawn middle %s (its place %s), drawn size %s" % [el, v.scale.x, box[0], mid, box[1]])
			await shot("01_plank_return_%d" % n)
			n += 1
		else:
			await get_tree().process_frame
	print("WATCH plank: while it grew back its drawn middle was never more than %.3f m from its place" % worst)
	await shot("01_plank_back")


## Note 3: the ore bucket. Is the drawn bucket where the solid one is; do hands and feet
## stick to it; does it carry a climber.
func _w_bucket(_a: Array) -> void:
	stand(Vector2(-198.0, 26.2))
	await secs(1.0)
	var m: Dictionary = pk.things.movers["cubo"]
	var w: Dictionary = pk.things.movers["cubo_peso"]
	var o1 := outline(m)
	var o2 := outline(w, Color(1.0, 0.3, 1.0))
	print("WATCH bucket: drawn %s; solid -0.60..0.60 across, 0.00..1.04 up" % drawn_span("cubo"))
	print("WATCH counterweight: drawn %s; solid -0.80..0.80 across, 0.00..1.20 up" % drawn_span("cubo_peso"))
	look(mover_at("cubo") + Vector2(-1.2, 0.4), 2.2)
	await secs(0.3)
	await shot("03_bucket_solid_outline")
	o1.queue_free()
	o2.queue_free()
	# A hand laid on the outside of its wall, low down (the half that had no collision):
	# the right hand on the west wall, so the body hangs outside the bucket.
	var c := me()
	c.release_all()
	for l in c.limbs:
		l.regrip = 99.0
	c.limbs[1].regrip = 0.0
	for i in 40:
		put_limb(1, mover_at("cubo") + Vector2(-0.63, 0.3))
		await get_tree().physics_frame
		if c.limbs[1].grab_other != null:
			break
	print("WATCH bucket: a hand on the lower half of its wall holds: %s (limbs: %s)" % [c.limbs[1].grab_other == m.nodes[0], holds()])
	for l in c.limbs:
		l.regrip = 0.0
	var y0 := where().y
	var b0 := mover_at("cubo").y
	look(mover_at("cubo") + Vector2(-0.8, -0.6), 3.0)
	await secs(1.2)
	await shot("03_bucket_hand_holds")
	var t := 0.0
	while t < 9.0 and absf(mover_at("cubo").y - b0) < 4.0:
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
		look(mover_at("cubo") + Vector2(-0.8, -0.6), 3.0)
	print("WATCH bucket: hanging from it for %.1f s the bucket went %.2f m and the climber %.2f m; limbs: %s" % [t, mover_at("cubo").y - b0, where().y - y0, holds()])
	await shot("03_bucket_hanging_ride")
	# Standing in it.
	c.release_all()
	stand(mover_at("cubo") + Vector2(0.0, 0.14))
	await secs(0.6)
	y0 = where().y
	b0 = mover_at("cubo").y
	print("WATCH bucket: stood in it: %s" % holds())
	look(mover_at("cubo") + Vector2(0.0, 0.8), 2.6)
	await secs(0.2)
	await shot("03_bucket_standing_in")
	t = 0.0
	while t < 9.0 and absf(mover_at("cubo").y - b0) < 4.0:
		await get_tree().physics_frame
		t += 1.0 / Engine.physics_ticks_per_second
		look(mover_at("cubo") + Vector2(0.0, 0.8), 2.6)
	print("WATCH bucket: standing in it for %.1f s the bucket went %.2f m and the climber %.2f m; limbs: %s; joints open %.3f m" % [t, mover_at("cubo").y - b0, where().y - y0, holds(), c.worst_joint_gap()])
	await shot("03_bucket_riding_in")
	_free_cam = false
	await secs(1.5)
	await shot("03_bucket_riding_game_camera")


## Note 5: an up-or-down wind's streaks stay in its own box. wind:a1 or wind:a4
func _w_wind(a: Array) -> void:
	var area := str(a[0]) if a.size() > 0 else "a1"
	var row: Dictionary = {}
	for wrow: Dictionary in pk.zones.winds:
		var acc := Peak.v2(wrow.def.accel)
		if str(wrow.area) == area and absf(acc.y) > absf(acc.x) and row.is_empty():
			row = wrow
	if row.is_empty():
		print("WATCH wind: none in ", area)
		return
	var r: Array = row.def.rect
	if area == "a1":
		pk.warp("1.9")
		await secs(5.0)
		look(Vector2(-236.0, 54.0), 11.0)
	else:
		pk.warp("4.3")
		await secs(5.0)
		look(Vector2((float(r[0]) + float(r[2])) * 0.5 + 2.0, (float(r[1]) + float(r[3])) * 0.5), 7.0)
	var fx: CPUParticles3D = row.fx
	print("WATCH wind %s: zone x %.1f..%.1f, y %.1f..%.1f, accel %s; its streaks are born in a box %.1f x %.1f m at (%.1f, %.1f), turned %.0f deg, flying %s" % [area,
		float(r[0]), float(r[2]), float(r[1]), float(r[3]), row.def.accel, fx.emission_box_extents.x * 2.0, fx.emission_box_extents.y * 2.0,
		fx.position.x, fx.position.y, rad_to_deg(fx.rotation.z), fx.direction])
	await secs(2.5)
	await shot("05_wind_" + area)
	if area == "a1":
		# Where Parker met the stray band: 36 m up on the banded wall, under the cart ledge.
		pk.warp("1.7")
		look(Vector2(-204.0, 34.5), 7.0)
		await secs(2.5)
		await shot("05_wind_a1_where_the_stray_band_was")


## Note 8: the staging under the winding wheel is one run of planks.
func _w_staging(_a: Array) -> void:
	pk.warp("1.9")
	await secs(6.0)
	await shot("08_staging_game_camera")
	look(Vector2(-234.7, 52.6), 2.6)
	await secs(0.4)
	await shot("08_staging_close")
	# Its west end: held like the rest?
	stand(Vector2(-236.6, 52.45))
	await secs(1.2)
	print("WATCH staging: stood on its west end (x -236.6): limbs %s, at %s" % [holds(), where()])
	await shot("08_staging_west_end")


## Note 6, the track end: the boards past the trestle are solid to their drawn end.
func _w_trackend(_a: Array) -> void:
	pk.warp("1.7")
	await secs(6.0)
	stand(Vector2(-212.7, 40.0))
	await secs(1.5)
	print("WATCH track end: stood at x -212.7 on the boards (they were air west of -211.6): limbs %s, at %s" % [holds(), where()])
	look(Vector2(-211.5, 40.4), 2.6)
	await secs(0.3)
	await shot("06_track_end_close")
	_free_cam = false
	await secs(2.0)
	await shot("06_track_end_game_camera")


## Notes 9, 10, 11: the cave-in's rocks. One whole loop of the written rhythm, watched:
## when each rock fell and from which source, where the board threw it, where it went out
## of sight. rocks:SECONDS (default 46).
func _w_rocks(a: Array) -> void:
	var watch_s := float(a[0]) if a.size() > 0 else 46.0
	pk.warp("1.10")
	await secs(1.0)
	stand(Vector2(-228.6, 57.4))  # west along the gallery, out of the rocks' road
	look(Vector2(-223.6, 60.2), 4.6)
	await secs(2.0)
	await shot("09_board_idle")
	var mine: Array = []
	for sp in pk.things.spawners:
		if str(sp.area) == "a1":
			mine.append(sp)
	var seen := {}  # instance id -> {src, born, thrown, at, last}
	var order: Array = []
	var t0 := pk.clock
	var shots_left := 3
	var shot_rock := 0
	var shot_at := 0.0
	var worst_low := INF
	while pk.clock - t0 < watch_s:
		await get_tree().physics_frame
		for si in mine.size():
			for row: Array in mine[si].live:
				if row[0] == null or not is_instance_valid(row[0]):
					continue
				var rb: Node3D = row[0]
				var id := rb.get_instance_id()
				if float(row[2]) >= 0.0 and not seen.has(id):
					for old in seen:  # (thrown, a rock's look goes on as a new node: the same rock)
						if seen[old].get("row") == row:
							seen[id] = seen[old]
							order[order.find(old)] = id
							seen.erase(old)
							break
				if not seen.has(id):
					seen[id] = {"src": "AB"[si], "born": pk.clock, "thrown": -1.0, "at": Vector2.ZERO, "last": Vector3.ZERO, "rest": 0.0, "row": row}
					order.append(id)
				var e: Dictionary = seen[id]
				e.last = rb.position
				if float(row[2]) >= 0.0 and float(e.thrown) < 0.0:
					e.thrown = float(row[2])
					e.at = Vector2(rb.position.x, rb.position.y)
					if shot_rock == 0 and order.size() >= 2:
						shot_rock = id
						shot_at = pk.clock
				if float(row[2]) < 0.0 and rb.position.y < 58.6 and rb.position.x < -223.0:
					worst_low = minf(worst_low, rb.position.x)  # a rock loose on the gallery floor
		if shot_rock != 0 and shots_left > 0 and pk.clock - shot_at > [1.25, 0.7, 0.2][shots_left - 1]:
			shots_left -= 1
			await shot("09_rock_thrown_%d" % (2 - shots_left))
	var prev := -1.0
	var left_by_board := 0
	var first := -1.0
	var line: Array = []
	for id in order:
		var e: Dictionary = seen[id]
		if first < 0.0:
			first = float(e.born)
		var gap := (float(e.born) - prev) if prev >= 0.0 else 0.0
		prev = float(e.born)
		var fate := "NOT thrown: last seen at (%.1f, %.1f)" % [e.last.x, e.last.y]
		if float(e.thrown) >= 0.0:
			var gone: bool = (e.last as Vector3).y < 57.4 and (e.last as Vector3).z < -2.0
			fate = "board at (%.1f, %.1f) %.1f s after it fell; last seen (%.1f, %.1f) %.1f m behind the climb%s" % [e.at.x, e.at.y, float(e.thrown) - float(e.born), e.last.x, e.last.y, -e.last.z, "" if gone else " (still in sight when the watch ended)"]
			if gone:
				left_by_board += 1
		line.append("%.1f" % gap)
		print("WATCH rock %s at %5.1f s (gap %.1f): %s" % [e.src, float(e.born) - first, gap, fate])
	print("WATCH rocks: %d fell in %.0f s; gaps %s; %d left by the board and dropped out of sight; furthest west any rolled loose on the gallery floor: %s" % [
		order.size(), watch_s, " ".join(line), left_by_board, ("x %.1f" % worst_low) if worst_low < INF else "none past the beam's foot"])
	await shot("09_board_after")
	# The board itself: solid, and it holds.
	stand(Vector2(-224.1, 57.9))
	await secs(1.0)
	print("WATCH board: stood on it: limbs %s, at %s" % [holds(), where()])
	await shot("09_board_stood_on")


## Note 6: the cart of 1.7 runs off the trestle and is a loose thing from there.
## Three times: empty (the climber steps off as it starts), ridden all the way down (feet
## on it, hands kept to itself), and ridden with the hands free (one finds a chain).
func _w_cart(_a: Array) -> void:
	var m: Dictionary = pk.things.movers["cart1"]
	for tag: String in ["empty", "ridden", "chain"]:
		var ride := tag != "empty"
		pk.warp("1.7")
		await secs(1.0)
		var w0 := pk.clock
		while m.get("loose") != null and pk.clock - w0 < 45.0:
			await get_tree().physics_frame  # (the last run's cart is still on its way home)
		await secs(0.3)
		stand(mover_at("cart1") + Vector2(0.0, 0.12))
		if tag == "ridden":
			me().limbs[0].regrip = 99.0
			me().limbs[1].regrip = 99.0
		look(Vector2(-210.5, 40.6), 4.2)
		var t0 := pk.clock
		while not bool(m.run) and pk.clock - t0 < 4.0:
			await get_tree().physics_frame
		var t_go := pk.clock
		print("WATCH cart (%s): it rolled %.2f s after the climber stood in it; limbs %s" % [tag, t_go - t0, holds()])
		if not ride:
			stand(Vector2(-203.0, 40.0))  # (off it, back on the pillar's top)
		var t_loose := -1.0
		var t_wet := -1.0
		var t_floor := -1.0
		var v_loose := Vector3.ZERO
		var at_loose := Vector2.ZERO
		var shots := 0
		var fastest := 0.0
		var gap_worst := 0.0
		var held_after := ""
		while pk.clock - t_go < 16.0:
			await get_tree().physics_frame
			var rb: RigidBody3D = m.get("loose")
			var here := mover_at("cart1")
			if tag == "chain" and rb == null and here.x < -213.6 and not holds().contains("RigidBody3D"):
				# The player's reach for the first chain, done for them: a hand on its tail.
				for r in pk.things.ropes:
					if str(r.id) == "cadena_a":
						var seg: RigidBody3D = r.segs[r.segs.size() - 2]
						me().release(0)
						me().attach(0, seg)
						print("WATCH cart (chain): a hand took the chain with the cart at x %.1f: limbs %s" % [here.x, holds()])
			if rb != null:
				here = Vector2(rb.position.x, rb.position.y)
				if t_loose < 0.0:
					t_loose = pk.clock
					v_loose = rb.linear_velocity
					at_loose = here
					held_after = holds()
				fastest = maxf(fastest, rb.linear_velocity.length())
				if ride:
					gap_worst = maxf(gap_worst, me().worst_joint_gap())
				if t_wet < 0.0 and bool(m.loose_wet):
					t_wet = pk.clock
				if t_wet >= 0.0 and t_floor < 0.0 and rb.linear_velocity.length() < 0.6 and pk.clock - t_wet > 0.5:
					t_floor = pk.clock
					print("WATCH cart (%s): came to rest at (%.1f, %.1f), turned %.0f deg" % [tag, here.x, here.y, rad_to_deg(rb.rotation.z)])
			elif t_loose >= 0.0:
				break  # (home again)
			if ride:
				_free_cam = false
			else:
				look(here + Vector2(1.0, 0.3), 5.0 if t_loose < 0.0 else 7.0)
			var el := pk.clock - t_go
			var want := false
			if shots == 0 and el > 1.2:
				want = true
			elif shots == 1 and t_loose >= 0.0 and pk.clock - t_loose > 0.35:
				want = true
			elif shots == 2 and t_loose >= 0.0 and pk.clock - t_loose > 1.6:
				want = true
			elif shots == 3 and t_wet >= 0.0 and pk.clock - t_wet > 0.25:
				want = true
			elif shots == 4 and t_floor >= 0.0 and pk.clock - t_floor > 0.3:
				want = true
			if want:
				await shot("06_cart_%s_%d" % [tag, shots])
				shots += 1
			if t_floor >= 0.0 and shots >= 5 and ride:
				break
			if tag == "chain" and t_loose >= 0.0 and pk.clock - t_loose > 7.5:
				break
		print("WATCH cart (%s): let loose %.2f s after it rolled, at (%.1f, %.1f) going %s; hit the water %.2f s later; fastest %.1f m/s; at rest %.2f s after the water" % [
			tag, t_loose - t_go, at_loose.x, at_loose.y, v_loose, t_wet - t_loose, fastest, t_floor - t_wet])
		if ride:
			print("WATCH cart (%s): limbs just after it was let loose: %s; limbs at the end: %s; joints opened %.3f m at most; climber at %s, in water %s" % [tag, held_after, holds(), gap_worst, where(), me().float_mode])
			for l in me().limbs:
				l.regrip = 0.0
		else:
			# The empty one: is it back on the rails after its wait?
			var t1 := pk.clock
			while m.get("loose") != null and pk.clock - t1 < 30.0:
				await get_tree().physics_frame
			await secs(0.3)
			look(Vector2(-207.5, 40.6), 4.2)
			await secs(0.3)
			print("WATCH cart (empty): home again %.1f s after it was let loose: at %s, drawn %s, solid layer %d" % [pk.clock - t_loose, mover_at("cart1"), drawn_span("cart1"), (m.nodes[0] as CollisionObject3D).collision_layer])
			await shot("06_cart_empty_home_again")
	_free_cam = false


## Note 2: the water. Pictures of the Sump, a race, the river with its eddies, a small
## pool and the lake; then a climber dropped into the Sump (the splash going in), and
## climbing out.
func _w_water(_a: Array) -> void:
	var spots := [
		["sump", "1.3", Vector2(-188.7, -27.7), Vector2(-197.0, -27.5), 6.0],
		["race", "2.3", Vector2(-247.6, 101.4), Vector2(-241.0, 99.0), 5.0],
		["river", "2.8", Vector2(-323.0, 118.0), Vector2(-331.0, 116.5), 5.0],
		["pool", "2.10", Vector2(-381.5, 138.0), Vector2(-386.0, 136.5), 4.5],
		["lake", "2.11", Vector2(-447.5, 167.5), Vector2(-454.0, 165.5), 4.5],
	]
	for row: Array in spots:
		pk.warp(str(row[1]))
		await secs(0.4)
		stand(row[2])
		look(row[3], float(row[4]))
		await secs(5.0 if str(row[0]) in ["sump", "race"] else 2.5)
		print("WATCH water %s: climber at %s, limbs %s" % [row[0], where(), holds()])
		await shot("02_water_" + str(row[0]))
	# Into the Sump from 6 m up, by the old staging piles.
	pk.warp("1.3")
	await secs(0.4)
	stand(Vector2(-215.0, -21.0))
	me().release_all()
	for l in me().limbs:
		l.regrip = 99.0
	look(Vector2(-215.0, -27.2), 4.2)
	var t0 := pk.clock
	while not me().float_mode and pk.clock - t0 < 6.0:
		await get_tree().physics_frame
	print("WATCH water: the climber hit the Sump %.2f s after the drop, at %s" % [pk.clock - t0, where()])
	await secs(0.12)
	await shot("02_splash_in_0")
	await secs(0.2)
	await shot("02_splash_in_1")
	await secs(0.35)
	await shot("02_splash_in_2")
	await secs(1.2)
	await shot("02_floating")
	# Out again: lifted clear of the water by hand (the probe's doing), to see what leaving looks like.
	for l in me().limbs:
		l.regrip = 0.0
	var p := me().pose()
	for k in range(0, p.size(), 3):
		p[k + 1] += 2.2
	me().apply_pose(p)
	for b: RigidBody3D in me().bodies.values():
		b.linear_velocity = Vector3(0, 3.0, 0)
	await secs(0.15)
	await shot("02_splash_out_0")
	await secs(0.25)
	await shot("02_splash_out_1")
	# Something else that falls in: a chunk like a broken plank's, dropped from 1.5 m.
	stand(Vector2(-203.0, 6.0))
	look(Vector2(-215.0, -27.2), 4.2)
	await secs(1.0)
	var before := 0
	for ch in get_tree().get_nodes_in_group("splash_fx"):
		before += 1
	for i in 3:
		var rb := RigidBody3D.new()
		rb.collision_layer = 0
		rb.collision_mask = Climber.LAYER_WORLD
		rb.gravity_scale = 0.75
		var cs := CollisionShape3D.new()
		var bx := BoxShape3D.new()
		bx.size = Vector3(0.35, 0.2, 0.4)
		cs.shape = bx
		rb.add_child(cs)
		rb.add_child(LuchaKit.box(bx.size, Color("#B07A32")))
		rb.position = Vector3(-216.5 + 1.5 * i, -26.5 + 0.4 * i, 0)
		(pk._roots["a1"] as Node3D).add_child(rb)
		pk.things._debris.append([rb, pk.clock])
	await secs(0.75)
	var after := 0
	for ch in get_tree().get_nodes_in_group("splash_fx"):
		after += 1
	print("WATCH water: three chunks dropped into the Sump threw %d splash(es) (thinned on purpose: small ones 0.22 s apart a pool)" % (after - before))
	await shot("02_splash_chunks")
	_free_cam = false


## The frame rate with all of Las Aguas Negras's water on: fps[:SECONDS]
func _w_fps(a: Array) -> void:
	var span := float(a[0]) if a.size() > 0 else 5.0
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	for id: String in ["1.3", "2.3", "2.8", "2.10"]:
		pk.warp(id)
		await secs(4.0)
		var n := 0
		var t0 := Time.get_ticks_usec()
		var worst := 0.0
		var last := t0
		while Time.get_ticks_usec() - t0 < int(span * 1000000.0):
			await get_tree().process_frame
			var now := Time.get_ticks_usec()
			worst = maxf(worst, float(now - last) / 1000.0)
			last = now
			n += 1
		var secs_taken := float(Time.get_ticks_usec() - t0) / 1000000.0
		print("WATCH fps at %s: %.0f frames a second over %.1f s (average frame %.2f ms, worst %.1f ms), window %s" % [id, n / secs_taken, secs_taken, 1000.0 * secs_taken / n, worst, get_viewport().get_visible_rect().size])


## Note 4: what stands where the lift's two cables were.
func _w_lift(_a: Array) -> void:
	pk.warp("1.5")
	await secs(6.0)
	await shot("04_lift_game_camera_1_5")
	look(Vector2(-191.5, 22.5), 12.0)
	await secs(0.4)
	await shot("04_lift_whole")
	_free_cam = false
	stand(Vector2(-186.0, 6.0))
	await secs(3.0)
	await shot("04_lift_from_catwalk")
