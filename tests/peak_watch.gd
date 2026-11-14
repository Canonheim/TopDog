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
	if _sun_shadow >= 0.0 and main != null:
		(main.get("_world_sun") as DirectionalLight3D).shadow_opacity = _sun_shadow
	if _free_cam and main != null:
		var cam: Camera3D = main.cam
		var dist := _cam_half / tan(deg_to_rad(cam.fov * 0.5))
		var sway := sin(Time.get_ticks_msec() / 1000.0 * 2.2) * _cam_sway
		cam.position = Vector3(_cam_at.x + Peak.ORIGIN.x + sway, _cam_at.y + Peak.ORIGIN.y, dist)
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


## Any spot, looked at: at:NAME:CHALLENGE:STANDX:STANDY:LOOKX:LOOKY:HALF[:WAIT] (stand
## "-" "-" keeps the challenge's own start; look "-" "-" "-" keeps the game's camera).
## Several spots in one run: --watch=at:a:5.3:-:-:-369:404:6,at:b:...
func _w_at(a: Array) -> void:
	pk.warp(str(a[1]))
	await secs(0.4)
	if str(a[2]) != "-":
		stand(Vector2(float(a[2]), float(a[3])))
	if str(a[4]) != "-":
		look(Vector2(float(a[4]), float(a[5])), float(a[6]))
	else:
		_free_cam = false
	await secs(float(a[7]) if a.size() > 7 else 3.0)
	print("WATCH at %s: climber at %s, limbs %s" % [a[0], where(), holds()])
	await shot(str(a[0]))


## Note 48: the temple's pistons. A hand on a piston going in is let go at the wall's face;
## a hand on the wall where a piston sleeps holds nothing.
func _w_piston(_a: Array) -> void:
	pk.warp("5.3")
	await secs(1.0)
	var c := me()
	var m: Dictionary = pk.things.movers["piston1"]  # west wall, face x -372
	look(Vector2(-369.3, 402.0), 3.6)
	# wait for it to be fully out
	var t0 := pk.clock
	while (m.offset as Vector2).x < 3.5 and pk.clock - t0 < 12.0:
		await get_tree().physics_frame
	c.release_all()
	for l in c.limbs:
		l.regrip = 99.0
	put_limb(1, mover_at("piston1") + Vector2(-0.9, 0.5))  # (on its top, 0.8 m out from the wall's face)
	c.attach(1, m.nodes[0])
	await secs(0.3)
	print("WATCH piston: a hand on the piston's top, %.2f m out from the wall's face: limbs %s" % [me().limb_end(1).x - Peak.ORIGIN.x + 372.0, holds()])
	await shot("48_piston_hand_on")
	var let_go_x := INF
	t0 = pk.clock
	while pk.clock - t0 < 9.0:
		await get_tree().physics_frame
		if c.limbs[1].grab_other == null and let_go_x == INF:
			let_go_x = c.limb_end(1).x - Peak.ORIGIN.x
			print("WATCH piston: the hand was let go at x %.2f (the wall's face is x -372.00), %.2f s after the piston started back" % [let_go_x, pk.clock - t0])
			await shot("48_piston_wiped")
			break
	if let_go_x == INF:
		print("WATCH piston: the hand was NEVER let go; it is at x %.2f" % (c.limb_end(1).x - Peak.ORIGIN.x))
	# Now the wall itself, at a sleeping socket and between sockets.
	t0 = pk.clock
	while (m.offset as Vector2).x > 0.01 and pk.clock - t0 < 12.0:
		await get_tree().physics_frame
	for spot: Vector2 in [Vector2(-371.95, 400.75), Vector2(-371.95, 401.9)]:
		c.release_all()
		for l in c.limbs:
			l.regrip = 99.0
		c.limbs[0].regrip = 0.0
		var got := false
		for i in 50:
			put_limb(0, spot)
			await get_tree().physics_frame
			if c.limbs[0].grab_other != null:
				got = true
				break
		print("WATCH piston: a hand pressed to the west wall at %s (piston in): holds %s" % [spot, "SOMETHING: " + holds() if got else "nothing"])
	for l in c.limbs:
		l.regrip = 0.0
	stand(Vector2(-365.0, 396.4))
	look(Vector2(-369.3, 404.6), 5.6)
	await secs(2.5)
	await shot("48_pistons_after")


## Note 52: the gallery's slots. A climber dropped into one goes through; a hand on its lip holds.
func _w_slot(_a: Array) -> void:
	pk.warp("5.7")
	await secs(0.6)
	var c := me()
	look(Vector2(-337.3, 451.6), 3.4)
	stand(Vector2(-339.3, 453.0))
	await secs(1.0)
	await shot("52_slot_after")
	# Dropped in feet first, limbs free to catch what they can.
	stand(Vector2(-337.3, 452.6))
	var t0 := pk.clock
	var caught := ""
	while pk.clock - t0 < 3.0:
		await get_tree().physics_frame
		if where().y > 449.8 and holds() != "- - - -" and caught == "":
			caught = holds() + " at " + str(where())
	print("WATCH slot: dropped into the west slot: %s; 3 s later the climber is at %s" % ["it CAUGHT the side (" + caught + ")" if caught != "" else "nothing inside it held", where()])
	await shot("52_slot_fell_through")
	# The lip: a hand laid on the floor's top right at the edge.
	stand(Vector2(-339.3, 453.0))
	c.release_all()
	for l in c.limbs:
		l.regrip = 99.0
	c.limbs[0].regrip = 0.0
	var got := false
	for i in 50:
		put_limb(0, Vector2(-338.12, 453.06))
		await get_tree().physics_frame
		if c.limbs[0].grab_other != null:
			got = true
			break
	print("WATCH slot: a hand on the floor's top at the lip (x -338.12): %s" % ("holds" if got else "does NOT hold"))
	for l in c.limbs:
		l.regrip = 0.0


## Note 55: the area banner's quiet time, on the game's own HUD (6 s here, 15 in play).
func _w_banner(_a: Array) -> void:
	var hud = main.get("_peak_hud")
	if hud == null:
		print("WATCH banner: no HUD")
		return
	await secs(5.0)  # (the first banner of the run has been and gone)
	hud.area_quiet_s = 6.0
	hud._area_said_t = -1.0e9
	hud._area_said = ""
	hud.show_area("La Mina Vieja", 1)
	await secs(0.6)
	print("WATCH banner: first one shows at once: %s" % hud.area_up)
	hud.show_area("Las Aguas Negras", 2)
	hud.show_area("La Mina Vieja", 1)
	hud.show_area("Las Aguas Negras", 2)
	await secs(4.5)
	print("WATCH banner: 5.1 s in, three more asked for across the line: one on screen? %s (want false)" % hud.area_up)
	await secs(2.0)
	print("WATCH banner: 7.1 s in, the quiet over: showing %s? %s (want true, Las Aguas Negras)" % [hud._area_said, hud.area_up])
	await shot("55_banner_after_quiet")
	await secs(4.5)
	hud._area_said_t = -1.0e9
	stand(where() + Vector2(0, 30.0))  # (a fall)
	hud.show_area("La Gruta de Cristal", 3)
	await secs(0.5)
	print("WATCH banner: asked for in mid fall (holding %s): on screen? %s (want false)" % [hud.holding, hud.area_up])
	pk.warp("1.3")
	await secs(1.5)
	print("WATCH banner: holding again (%s): on screen? %s (want true)" % [hud.holding, hud.area_up])
	hud.area_quiet_s = 15.0


## HOW MUCH A PART OF THE PICTURE CHANGES OVER TIME (a still can't show a flicker). The
## part is given in fractions of the window. Returns [the average over its points of how
## far each one's brightness strays (0..255), the biggest average jump between two frames].
func flicker(part: Rect2, seconds: float) -> Array:
	var frames: Array = []
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(seconds * 1000.0):
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		var sz := img.get_size()
		var crop := img.get_region(Rect2i(int(part.position.x * sz.x), int(part.position.y * sz.y), int(part.size.x * sz.x), int(part.size.y * sz.y)))
		crop.resize(48, 27, Image.INTERPOLATE_BILINEAR)
		var lum := PackedFloat32Array()
		lum.resize(48 * 27)
		for y in 27:
			for x in 48:
				lum[y * 48 + x] = crop.get_pixel(x, y).get_luminance() * 255.0
		frames.append(lum)
		await get_tree().process_frame
	var n := frames.size()
	if n < 3:
		return [0.0, 0.0]
	var stray := 0.0
	for i in 48 * 27:
		var mean := 0.0
		for f: PackedFloat32Array in frames:
			mean += f[i]
		mean /= n
		var dev := 0.0
		for f: PackedFloat32Array in frames:
			dev += (f[i] - mean) * (f[i] - mean)
		stray += sqrt(dev / n)
	stray /= 48.0 * 27.0
	var jump := 0.0
	for k in range(1, n):
		var d := 0.0
		for i in 48 * 27:
			d += absf((frames[k] as PackedFloat32Array)[i] - (frames[k - 1] as PackedFloat32Array)[i])
		jump = maxf(jump, d / (48.0 * 27.0))
	return [stray, jump]


var _sun_shadow := -1.0  # (>= 0: the probe holds the sun's shadow at this strength, over the game's own)
var _wobble := 0.0  # (> 0: the climber is rocked this many metres, as if crawling)
var _cam_sway := 0.0  # (> 0: the free camera slides this many metres side to side)
var _wob_t := 0.0


func _physics_process(delta: float) -> void:
	if _wobble > 0.0 and pk != null and pk.player != null:
		_wob_t += delta
		var c := me()
		var p := c.pose()
		var d := Vector2(cos(_wob_t * 15.0), sin(_wob_t * 11.0)) * _wobble * delta * 13.0
		for k in range(0, p.size(), 3):
			p[k] += d.x
			p[k + 1] += d.y
		c.apply_pose(p)


var _flick := {}  # lantern -> does it flicker by design


func lights_steady(on: bool) -> void:
	for row: Array in pk._lights:
		if not _flick.has(row[0]):
			_flick[row[0]] = row[2]
		row[2] = (not on) and bool(_flick[row[0]])


## Notes 17 and 27: which suspect makes the light pulse. light:race or light:crystal
func _w_light(a: Array) -> void:
	var which := str(a[0]) if a.size() > 0 else "race"
	var part := Rect2(0.2, 0.35, 0.6, 0.5)
	if which == "race":
		pk.warp("2.3")
		await secs(0.5)
		look(Vector2(-241.0, 98.2), 3.6)
	else:
		pk.warp("3.1")
		await secs(0.5)
		look(Vector2(-415.0, 176.6), 3.0)
		part = Rect2(0.15, 0.45, 0.7, 0.35)
	await secs(5.0)
	await shot("light_%s_as_played" % which)
	var runs := [
		# name, sun shadow (-1 = the game's own), lanterns steady, the climber's lamp off, climber rocked, camera sway
		["as the branch is now", -1.0, false, false, 0.0, 0.0],
		["as it was played: the sun's shadows on", 1.0, false, false, 0.0, 0.0],
		["shadows on, lanterns held steady", 1.0, true, false, 0.0, 0.0],
		["shadows off, lanterns held steady", 0.0, true, false, 0.0, 0.0],
		["as played, the climber crawling (rocked 6 cm)", 1.0, false, false, 0.06, 0.0],
		["...the same with the climber's own lamp off", 1.0, false, true, 0.06, 0.0],
		["...lamp off and lanterns steady", 1.0, true, true, 0.06, 0.0],
		["now, the climber crawling", -1.0, false, false, 0.06, 0.0],
		["a still climber, everything steady, the camera sliding (two surfaces in one place would show here)", 0.0, true, true, 0.0, 0.5],
	]
	for r: Array in runs:
		_sun_shadow = float(r[1])
		lights_steady(bool(r[2]))
		pk._lamp.visible = not bool(r[3])
		_wobble = float(r[4])
		_cam_sway = float(r[5])
		await secs(0.6)
		var f: Array = await flicker(part, 2.5)
		print("WATCH light %s: %-90s stray %5.2f, biggest jump %5.2f" % [which, str(r[0]) + ":", f[0], f[1]])
	_sun_shadow = -1.0
	_wobble = 0.0
	_cam_sway = 0.0
	lights_steady(false)
	pk._lamp.visible = true


## Notes 17 and 27 again, on clean patches. light2:race puts the OLD water box back over
## the mill race (a see-through box whose bottom lay in the bed's own top) and watches the
## bed while the camera drifts; light2:crystal watches the floor beside a crawling climber.
func _w_light2(a: Array) -> void:
	var which := str(a[0]) if a.size() > 0 else "race"
	if which == "race":
		pk.warp("2.3")
		await secs(0.5)
		look(Vector2(-241.0, 98.6), 5.0)  # (from a little above, as the pulled-back camera saw it)
		_cam_at.y = 100.4
		await secs(4.0)
		var bed := Rect2(0.05, 0.80, 0.9, 0.09)  # (the bed's top and the water just over it; the surface and its flecks are above this)
		var old := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(24.5, 1.4, Peak.HALF * 2.4)
		old.mesh = bm
		old.material_override = PeakZones._flat(Color("#2A4660"), 0.62)
		old.position = Vector3(-241.25, 97.5, 0)
		old.visible = false
		(pk._roots["a2"] as Node3D).add_child(old)
		for r: Array in [["the branch's water, camera still", false, 0.0], ["the branch's water, camera drifting 5 cm", false, 0.05],
				["the OLD box put back, camera still", true, 0.0], ["the OLD box put back, camera drifting 5 cm", true, 0.05],
				["the OLD box, drifting, lanterns held steady", true, 0.05]]:
			old.visible = bool(r[1])
			_cam_sway = float(r[2])
			lights_steady(str(r[0]).contains("steady"))
			await secs(0.5)
			var f: Array = await flicker(bed, 2.5)
			print("WATCH light2 race: %-48s stray %5.2f, biggest jump %5.2f" % [str(r[0]) + ":", f[0], f[1]])
			if bool(r[1]) and float(r[2]) > 0.0 and not str(r[0]).contains("steady"):
				await shot("17_old_water_box_on_the_bed")
		old.queue_free()
		_cam_sway = 0.0
		lights_steady(false)
		return
	if which == "swim":
		# The race again, with a climber floating in it: the bed beside and under a swimmer.
		pk.warp("2.3")
		await secs(0.5)
		stand(Vector2(-241.0, 97.6))
		look(Vector2(-241.0, 98.6), 3.6)
		await secs(4.0)
		print("WATCH light2 swim: the climber floats at %s (in water %s); the bed is at y 96.8" % [where(), me().float_mode])
		await shot("17_swimmer_over_the_bed")
		var bed2 := Rect2(0.12, 0.735, 0.3, 0.035)
		for r: Array in [["as played: lamp on, sun's shadows on", 1.0, false, false], ["lamp OFF, shadows on", 1.0, true, false],
				["lamp on, shadows OFF", 0.0, false, false], ["lamp on, shadows on, lanterns steady", 1.0, false, true],
				["lamp OFF, shadows OFF, lanterns steady", 0.0, true, true], ["as played (again)", 1.0, false, false]]:
			_sun_shadow = float(r[1])
			pk._lamp.visible = not bool(r[2])
			lights_steady(bool(r[3]))
			await secs(0.6)
			var f: Array = await flicker(bed2, 3.0)
			print("WATCH light2 swim: %-42s stray %5.2f, biggest jump %5.2f" % [str(r[0]) + ":", f[0], f[1]])
		_sun_shadow = -1.0
		pk._lamp.visible = true
		lights_steady(false)
		return
	pk.warp("3.1")
	await secs(0.5)
	look(Vector2(-415.0, 176.6), 3.0)
	await secs(5.0)
	await shot("27_floor_before")
	var floor_part := Rect2(0.08, 0.56, 0.3, 0.07)  # (the floor's top, 1.4 to 3.2 m west of the climber)
	for r: Array in [["a still climber", 0.0, false], ["crawling (rocked 6 cm), its lamp on", 0.06, false], ["crawling, its lamp OFF", 0.06, true],
			["crawling, its lamp on (again)", 0.06, false], ["crawling, its lamp OFF (again)", 0.06, true]]:
		_wobble = float(r[1])
		pk._lamp.visible = not bool(r[2])
		await secs(0.6)
		var f: Array = await flicker(floor_part, 2.5)
		print("WATCH light2 crystal: %-40s stray %5.2f, biggest jump %5.2f" % [str(r[0]) + ":", f[0], f[1]])
	_wobble = 0.0
	pk._lamp.visible = true


## Note 45: the dark place at Los Ojos. How dark it is as you walk up to it and into it
## (it must deepen over metres, never snap), and a picture inside it.
func _w_dark(_a: Array) -> void:
	pk.warp("4.8")
	await secs(4.0)
	var z: Dictionary = {}
	for row in pk.zones.darks:
		if str(row.area) == "a4":
			z = row.def
	print("WATCH dark: the box is x %.0f..%.0f, y %.0f..%.0f, strength %.2f (the mountain's floor on darkness is %.2f)" % [z.rect[0], z.rect[2], z.rect[1], z.rect[3], float(z.level), PeakZones.DARK_MAX])
	var line: Array = []
	for d: float in [12.0, 8.0, 6.0, 4.0, 2.0, 0.0, -3.0]:
		line.append("%.0f m out: %.2f" % [d, pk.zones.dark_at(Vector2(float(z.rect[2]) + d, 362.0))])
	print("WATCH dark: by the boxes, coming from the east: %s" % ", ".join(line))
	# Dropped straight into the middle of it: how fast does the picture's darkness follow?
	var mid := Vector2((float(z.rect[0]) + float(z.rect[2])) * 0.5, 362.0)
	pk.warp("4.9")
	var t0 := Time.get_ticks_msec()
	var steps: Array = []
	for i in 6:
		steps.append("%.1f s: %.2f" % [(Time.get_ticks_msec() - t0) / 1000.0, pk.zones.darkness(mid)])
		await secs(0.4)
	print("WATCH dark: warped to 4.9 from outside it, the darkness on screen went: %s" % ", ".join(steps))
	await secs(3.0)
	await shot("45_dark_after_game_camera")
	look(mid + Vector2(0, 1.0), 7.0)
	await secs(0.5)
	await shot("45_dark_after_whole")
	_free_cam = false


## Notes 23 and 56: a hot hold's tells. hot:2.9 or hot:6.2. A hand is put on the first hot
## hold and left there: pictures at rest, as the time runs out, as it lets go, and after.
func _w_hot(a: Array) -> void:
	var cid := str(a[0]) if a.size() > 0 else "2.9"
	pk.warp(cid)
	await secs(0.6)
	var c := me()
	var first := Vector2(-350.2, 121.2) if cid == "2.9" else Vector2(-276.2, 487.5)
	var view := Vector2(-351.3, 122.3) if cid == "2.9" else Vector2(-274.6, 491.6)
	var half := 3.0 if cid == "2.9" else 6.0
	var h: Dictionary = {}
	for hh: Dictionary in pk.things.holds:
		if str(hh.type) == "timed" and pk.things._hold_at(hh).distance_to(first) < 0.3:
			h = hh
	if h.is_empty():
		print("WATCH hot: no hot hold at ", first)
		return
	var tag := ("23" if cid == "2.9" else "56")
	look(view, half)
	await secs(3.0)
	await shot(tag + "_hot_at_rest")
	c.release_all()
	for l in c.limbs:
		l.regrip = 99.0
	c.limbs[0].regrip = 0.0
	for k in 60:  # (laid on it and left to stick by touch, as in play)
		put_limb(0, first + Vector2(0.0, 0.2))
		await get_tree().physics_frame
		if c.limbs[0].grab_other != null:
			break
	var limit := float((h.def as Dictionary).t)
	var t0 := pk.clock
	var shots := 0
	var let_go := -1.0
	while pk.clock - t0 < limit + 1.6:
		await get_tree().physics_frame
		var el := pk.clock - t0
		if let_go < 0.0 and c.limbs[0].grab_other == null:
			let_go = el
		var want := false
		if shots == 0 and el > limit * 0.45:
			want = true
		elif shots == 1 and el > limit - 0.2:
			want = true
		elif shots == 2 and let_go >= 0.0 and el > let_go + 0.12:
			want = true
		elif shots == 3 and let_go >= 0.0 and el > let_go + 0.5:
			want = true
		if want:
			print("WATCH hot %s: %.2f s on it: heat %.2f, tint %s, hand marks %d" % [cid, el, float(h.get("heat", 0.0)), h.get("tint", Color.WHITE), pk.things._burns.size()])
			await shot(tag + "_hot_" + ["half_way", "last_moments", "lets_go", "hand_after"][shots])
			shots += 1
	print("WATCH hot %s: the hand was let go after %.2f s (the hold's time is %.1f s); it can hold again %.1f s later" % [cid, let_go, limit, float((h.def as Dictionary).get("rearm", 0.6))])
	for l in c.limbs:
		l.regrip = 0.0


## Note 13: La Cortina's wet holds and the drips that wet them.
func _w_cortina(_a: Array) -> void:
	pk.warp("1.11")
	await secs(1.0)
	look(Vector2(-234.2, 80.5), 9.5)
	await secs(4.5)
	await shot("13_cortina_whole")
	# Every wet hold of the wall, watched for 15 s: how long wet, how long dry, how near a
	# drip is when it turns wet, and whether a row ever has both its holds wet.
	var wall: Array = []
	for h: Dictionary in pk.things.holds:
		if str(h.type) == "wet" and str(h.area) == "a1":
			wall.append(h)
	var lines: Array = []
	for row in pk.zones.drip_lines:
		if str(row.area) == "a1":
			lines.append(row)
	var was := {}
	var wet_s := {}
	var turns: Array = []
	var both := 0
	var samples := 0
	var t0 := pk.clock
	while pk.clock - t0 < 15.0:
		await get_tree().physics_frame
		samples += 1
		var by_row := {}
		for h: Dictionary in wall:
			var at: Vector2 = pk.things._hold_at(h)
			var id := "%0.2f,%0.2f" % [at.x, at.y]
			var wet := bool(h.wet)
			if wet:
				wet_s[id] = float(wet_s.get(id, 0.0)) + 1.0 / Engine.physics_ticks_per_second
				by_row[snappedf(at.y, 0.01)] = int(by_row.get(snappedf(at.y, 0.01), 0)) + 1
			if was.has(id) and wet and not bool(was[id]):
				var nearest := INF
				for row in lines:
					for n: Node3D in row.nodes:
						if n.visible:
							nearest = minf(nearest, Vector2(n.position.x, n.position.y).distance_to(at))
				turns.append(nearest)
			was[id] = wet
		for y in by_row:
			if int(by_row[y]) >= 2:
				both += 1
	var lo := INF
	var hi := 0.0
	for id in wet_s:
		lo = minf(lo, float(wet_s[id]))
		hi = maxf(hi, float(wet_s[id]))
	var far := 0.0
	for d: float in turns:
		far = maxf(far, d)
	print("WATCH cortina: %d wet holds, %d drip lines. Over 15 s each hold was wet %.1f to %.1f s (2 s in every 7 would be 4.0 to 6.0). %d times a hold turned wet; the nearest drip was then at most %.2f m from it. Moments a row had BOTH holds wet: %d of %d." % [
		wall.size(), lines.size(), lo, hi, turns.size(), far, both, samples])
	look(Vector2(-234.6, 76.0), 3.4)
	await secs(0.6)
	await shot("13_cortina_close_0")
	await secs(1.3)
	await shot("13_cortina_close_1")
	await secs(1.3)
	await shot("13_cortina_close_2")
	# The rope (note 14): where its tail and its top are against the holds and the lip.
	for r in pk.things.ropes:
		if str(r.id) == "cuerda_cortina":
			var top: RigidBody3D = r.segs[0]
			var tail: RigidBody3D = r.segs[r.segs.size() - 1]
			var tp := Vector2(tail.position.x, tail.position.y)
			var best := INF
			for h: Dictionary in pk.things.holds:
				if str(h.area) == "a1":
					best = minf(best, pk.things._hold_at(h).distance_to(tp))
			print("WATCH rope: top at (%.2f, %.2f), tail at (%.2f, %.2f); the nearest of the wall's holds is %.2f m from the tail; the lip (-232.0, 89.7) is %.2f m from the top" % [
				top.position.x, top.position.y, tp.x, tp.y, best, Vector2(top.position.x, top.position.y).distance_to(Vector2(-232.0, 89.7))])
			# A climber hung on it half way up: does it hold, and can it take the lip from the top?
			var c := me()
			c.release_all()
			for l in c.limbs:
				l.regrip = 99.0
			var mid: RigidBody3D = r.segs[r.segs.size() - 3]
			put_limb(0, Vector2(mid.position.x, mid.position.y))
			c.attach(0, mid)
			look(Vector2(-233.6, 85.0), 6.0)
			await secs(3.0)
			print("WATCH rope: a climber hung from its lower end for 3 s: still on it %s, joints open %.3f m, the rope's tail now at (%.2f, %.2f)" % [
				c.limbs[0].grab_other == mid, c.worst_joint_gap(), tail.position.x, tail.position.y])
			await shot("14_rope_hanging")
			for l in c.limbs:
				l.regrip = 0.0
	_free_cam = false


## Note 15: the life ring at the foot of the wet slab. ring[:N] drops a climber N times
## off the balcony and N/2 times from each of the first three rows of La Cortina, and
## counts where each ends up.
func _w_ring(a: Array) -> void:
	var n := int(a[0]) if a.size() > 0 else 10
	pk.warp("1.11")
	await secs(1.0)
	var c := me()
	var starts := [["the balcony's edge", Vector2(-233.75, 72.25), n]]
	for r in 3:
		var y := 73.3 + 1.25 * r
		starts.append(["row %d of La Cortina" % (r + 1), Vector2(-235.6 + 0.11 * r + 0.65, y - 0.9), maxi(1, n / 2)])
	look(Vector2(-233.8, 68.0), 8.0)
	var shot_taken := 0
	for st: Array in starts:
		var tally := {}
		var times: Array = []
		for k in int(st[2]):
			stand((st[1] as Vector2) + Vector2(randf_range(-0.25, 0.25), 0.0))
			for l in c.limbs:
				l.regrip = 0.7  # (it has just come off: nothing catches for the first moment of the fall)
			var t0 := pk.clock
			var out := "still in the air after 12 s"
			var bounced := -1.0
			var held := 0.0
			var apex := -INF
			while pk.clock - t0 < 12.0:
				await get_tree().physics_frame
				var p := where()
				if bounced < 0.0 and pk.zones._bounce_wait > 0.0:
					bounced = pk.clock - t0
					if shot_taken == 0:
						shot_taken = 1
						await shot("15_ring_squashed")
				if bounced >= 0.0:
					apex = maxf(apex, p.y)
					if shot_taken == 1 and pk.clock - t0 - bounced > 1.6:
						shot_taken = 2
						await shot("15_ring_thrown")
				if p.y < 52.0:
					out = "LOST down the fall"
					break
				if c.touches_solid() and bounced >= 0.0:
					held += 1.0 / Engine.physics_ticks_per_second
					if held > 0.6:
						if p.y > 71.6 and p.y < 74.2 and p.x > -233.6 and p.x < -229.4:
							out = "on the balcony"
						elif p.y > 71.6 and p.x >= -229.4:
							out = "on the top drift, past the balcony"
						elif p.y > 72.6:
							out = "holding La Cortina"
						else:
							out = "holding something lower (%.1f, %.1f)" % [p.x, p.y]
						times.append(pk.clock - t0 - bounced)
						break
				else:
					held = 0.0
			if bounced < 0.0 and out.begins_with("still"):
				out = "never reached the ring: at (%.1f, %.1f) holding %s" % [where().x, where().y, holds()]
			elif out.begins_with("still"):
				out = "still loose after 12 s at (%.1f, %.1f)" % [where().x, where().y]
			tally[out] = int(tally.get(out, 0)) + 1
			if out.begins_with("on the") and shot_taken == 2:
				shot_taken = 3
				await shot("15_ring_landed")
			c.release_all()
		var avg := 0.0
		for tt: float in times:
			avg += tt / maxf(1.0, times.size())
		print("WATCH ring, dropped from %s x%d: %s (bounce to holding on: %.1f s on average)" % [st[0], st[2], tally, avg])
	_free_cam = false


## HOW FAST DOES A CLIMBER CROSS A FLOOR? (notes 24 and 53 hang on it.) A scripted crawl
## along the temple's gallery floor, 12 m of level stone: one limb at a time is picked up,
## aimed ahead and planted, as a player does it. gait[:low] keeps the body low (crouched).
## It reports metres a second for a few rhythms; the fastest is "moving briskly".
func _w_gait(a: Array) -> void:
	var low := a.size() > 0 and str(a[0]) == "low"
	const Drivers := preload("res://climber/drivers.gd")
	pk.warp("5.7")
	await secs(0.5)
	var c := me()
	var old_driver = c.driver
	var d := Drivers.ScriptDriver.new()
	var floor_y := 453.0 + Peak.ORIGIN.y
	var best := 0.0
	var best_name := ""
	for plan: Array in [["hands then feet, 0.20 s a limb", [1, 0, 3, 2], 0.20, 1.05, 0.25], ["hands then feet, 0.14 s a limb", [1, 0, 3, 2], 0.14, 1.05, 0.25],
			["hand, foot, hand, foot, 0.16 s a limb", [1, 3, 0, 2], 0.16, 1.0, 0.3], ["hands then feet, long reach, 0.18 s", [1, 0, 3, 2], 0.18, 1.3, 0.45],
			["hand, foot, hand, foot, long reach, 0.12 s", [1, 3, 0, 2], 0.12, 1.3, 0.45]]:
		stand(Vector2(-350.5, 453.0))
		c.driver = d
		d.clear()
		await secs(0.8)
		_free_cam = false
		var x0 := where().x
		var t0 := pk.clock
		var k := 0
		var seq: Array = plan[1]
		var fell := false
		while pk.clock - t0 < 8.0 and where().x < -340.5:
			var limb: int = seq[k % seq.size()]
			k += 1
			var com := c.centre_of_mass()
			var ahead := float(plan[3]) if limb < 2 else float(plan[4])
			var up := 0.06 if (limb >= 2 or low) else 0.06
			d.point_limb(limb, true, Vector2(com.x + ahead, floor_y + up))
			await secs(float(plan[2]))
			d.set_limb(limb, false)
			await secs(0.05)
			if where().y < 452.0:
				fell = true
				break
		var dist := where().x - x0
		var took := pk.clock - t0
		var chest: RigidBody3D = c.bodies["chest"]
		print("WATCH gait%s: %-44s %.1f m in %.1f s = %.2f m/s%s (chest %.2f m over the floor)" % [" (low)" if low else "", str(plan[0]) + ":", dist, took, dist / maxf(took, 0.01), "  FELL" if fell else "", chest.global_position.y - floor_y])
		if not fell and dist / maxf(took, 0.01) > best:
			best = dist / maxf(took, 0.01)
			best_name = str(plan[0])
	print("WATCH gait: the fastest that held: %.2f m/s (%s). At that pace 1.5 m takes %.1f s and 2 m takes %.1f s; a body is about 1.6 m long from leading hand to trailing foot, so to be wholly off a 1.5 m piece after first touching it takes %.1f s, and off a 2 m piece %.1f s." % [
		best, best_name, 1.5 / maxf(best, 0.01), 2.0 / maxf(best, 0.01), 3.1 / maxf(best, 0.01), 3.6 / maxf(best, 0.01)])
	d.clear()
	c.driver = old_driver


## A scripted crawl toward x = `to_x` (course metres) along a floor whose top is `floor_y`:
## one limb at a time picked up, aimed ahead and planted. Returns [got there, seconds,
## where it ended, was it knocked out]. `reach` and `beat` are the gait (see _w_gait).
func crawl(to_x: float, floor_y: float, reach := 1.3, beat := 0.12, limit := 30.0) -> Array:
	const Drivers := preload("res://climber/drivers.gd")
	var c := me()
	var old_driver = c.driver
	var d := Drivers.ScriptDriver.new()
	c.driver = d
	var dir := signf(to_x - where().x)
	var seq := [1, 3, 0, 2] if dir > 0.0 else [0, 2, 1, 3]
	var t0 := pk.clock
	var k := 0
	var ko := false
	while pk.clock - t0 < limit and (to_x - where().x) * dir > 0.0:
		var limb: int = seq[k % 4]
		k += 1
		var com := c.centre_of_mass()
		var ahead := reach if limb < 2 else reach * 0.35
		d.point_limb(limb, true, Vector2(com.x + ahead * dir, floor_y + Peak.ORIGIN.y + 0.06))
		await secs(beat)
		d.set_limb(limb, false)
		await secs(0.05)
		if c.knockout_left > 0.0:
			ko = true
		if where().y < floor_y - 1.2:
			break
	d.clear()
	c.driver = old_driver
	return [(to_x - where().x) * dir <= 0.0, pk.clock - t0, where(), ko]


## Group E: the breaking pieces. break:pipe | catwalk | shelves | beam
func _w_break(a: Array) -> void:
	var which := str(a[0]) if a.size() > 0 else "pipe"
	var c := me()
	if which == "pipe":
		pk.warp("2.1")
		await secs(0.6)
		look(Vector2(-240.8, 94.2), 3.4)
		await secs(4.0)
		await shot("16_pipe_at_rest")
		var h := hold_near(Vector2(-238.25, 94.5), "crumble")
		c.release_all()
		for l in c.limbs:
			l.regrip = 99.0
		c.limbs[0].regrip = 0.0
		for k in 60:
			put_limb(0, Vector2(-238.25, 94.7))
			await get_tree().physics_frame
			if c.limbs[0].grab_other != null:
				break
		var t0 := pk.clock
		print("WATCH break pipe: a hand on the first rusted section: limbs %s" % holds())
		await secs(0.55)
		await shot("16_pipe_touched")
		while c.limbs[0].grab_other != null and pk.clock - t0 < 4.0:
			await get_tree().physics_frame
		print("WATCH break pipe: it let go of the hand %.2f s after it was taken (its time is %.1f); the section is gone: %s" % [pk.clock - t0, float((h.def as Dictionary).t), (h.body as CollisionObject3D).collision_layer == 0])
		await secs(0.15)
		await shot("16_pipe_breaks")
		var tb := pk.clock
		while (h.body as CollisionObject3D).collision_layer == 0 and pk.clock - tb < 12.0:
			await get_tree().physics_frame
		print("WATCH break pipe: back %.1f s after it broke" % (pk.clock - tb))
		for l in c.limbs:
			l.regrip = 0.0
	elif which == "catwalk":
		pk.warp("2.11")
		await secs(0.6)
		look(Vector2(-408.5, 152.6), 9.0)
		stand(Vector2(-424.6, 153.0))
		await secs(4.0)
		await shot("24_catwalk_at_rest")
		look(Vector2(-420.0, 152.8), 3.2)
		await secs(0.4)
		await shot("24_catwalk_close")
		_free_cam = false
		# The crawl: from the west landing over two breaking pieces, the gap, two more, to the first rest plate.
		# (The scripted crawl can't lunge a 1.3 m gap, which was there before too: each leg
		# starts past one.)
		var legs := [[-424.6, -420.2, "from the west landing over the two pieces to the first gap"],
			[-418.1, -414.2, "the two pieces from the gap to the rest plate"],
			[-403.6, -392.9, "the long run: five pieces, 10.5 m, to the east landing"]]
		var fine := true
		for leg: Array in legs:
			stand(Vector2(float(leg[0]), 153.0))
			await secs(0.4)
			var r: Array = await crawl(float(leg[1]), 153.0)
			print("WATCH break catwalk: %s: %s in %.1f s (%.2f m/s), now at %s" % [leg[2], "made it" if bool(r[0]) else "DID NOT", float(r[1]), absf(float(leg[1]) - float(leg[0])) / maxf(float(r[1]), 0.1), r[2]])
			if not bool(r[0]):
				fine = false
			await secs(9.0)  # (everything it broke grows back)
		await shot("24_catwalk_crawled")
		var broken := 0
		for h: Dictionary in pk.things.holds:
			if str(h.area) == "a2" and str(h.get("kind", "")) == "rusty" and float(h.back_at) >= 0.0:
				broken += 1
		print("WATCH break catwalk: crossed at a crawl: %s; pieces broken behind it right now: %d" % [fine, broken])
		# And standing still on one: it must drop you.
		stand(Vector2(-410.4, 153.0))
		var ts := -1.0
		var t_in := pk.clock
		while where().y > 152.0 and pk.clock - t_in < 10.0:
			await get_tree().physics_frame
			if ts < 0.0 and holds() != "- - - -":
				ts = pk.clock
		print("WATCH break catwalk: stood still on a piece: dropped %.1f s after first holding it (the piece's time is 3.4)" % (pk.clock - ts))
	elif which == "shelves":
		pk.warp("3.6")
		await secs(0.6)
		look(Vector2(-380.4, 227.2), 6.2)
		await secs(4.0)
		await shot("31_shelves_at_rest")
		var order: Array = []
		for h: Dictionary in pk.things.holds:
			if str(h.area) == "a3" and str(h.get("kind", "")) == "crazed":
				order.append(h)
		order.sort_custom(func(x, y): return pk.things._hold_at(x).y < pk.things._hold_at(y).y)
		var tags: Array = []
		for h: Dictionary in order:
			tags.append(str((h.body as Node).get_meta("peak_tag", "?")))
		print("WATCH break shelves: %d shelves, bottom to top their notes are %s (each plays crystal_chime_NN of its own number)" % [order.size(), tags])
		var h0: Dictionary = order[0]
		c.release_all()
		for l in c.limbs:
			l.regrip = 99.0
		c.limbs[0].regrip = 0.0
		for k in 60:
			put_limb(0, pk.things._hold_at(h0) + Vector2(0.0, 0.2))
			await get_tree().physics_frame
			if c.limbs[0].grab_other != null:
				break
		var t0 := pk.clock
		look(pk.things._hold_at(h0) + Vector2(0.4, 0.3), 2.4)
		await secs(0.7)
		await shot("31_shelf_touched")
		while c.limbs[0].grab_other != null and pk.clock - t0 < 4.0:
			await get_tree().physics_frame
		print("WATCH break shelves: the first shelf let go %.2f s after it was taken (was 0.8, asked 1.3)" % (pk.clock - t0))
		await secs(0.1)
		await shot("31_shelf_breaks")
		for l in c.limbs:
			l.regrip = 0.0
	elif which == "beam":
		pk.warp("5.10")
		await secs(0.6)
		look(Vector2(-318.6, 471.6), 6.0)
		await secs(4.0)
		await shot("53_beam_at_rest")
		var m: Dictionary = pk.things.movers["altar_cross"]
		var a0 := float(m.angle)
		var tq := pk.clock
		await secs(2.0)
		print("WATCH break beam: the cross turned %.1f degrees in 2 s = %.2f rpm (asked 6.4); an arm passes every %.2f s" % [rad_to_deg(float(m.angle) - a0), (float(m.angle) - a0) / TAU * 30.0, 60.0 / (absf(float(m.angle) - a0) / TAU * 30.0) / 4.0])
		_free_cam = false
		stand(Vector2(-324.4, 468.9))
		await secs(0.6)
		for gait: Array in [["the brisk crawl (1.1 m/s, chest 0.75 m up)", 1.3, 0.12], ["the low crawl (0.9 m/s, chest 0.5 m up)", 1.3, 0.18], ["the lowest crawl (0.65 m/s, chest 0.3 m up)", 1.05, 0.2]]:
			stand(Vector2(-324.4, 468.9))
			# wait for every piece to be back
			var tw := pk.clock
			while pk.clock - tw < 10.0:
				var all_back := true
				for h: Dictionary in pk.things.holds:
					if str(h.area) == "a5" and str(h.get("kind", "")) == "brittle" and pk.things._hold_at(h).y < 469.0 and (float(h.back_at) >= 0.0 or float(h.break_at) >= 0.0):
						all_back = false
				if all_back:
					break
				await get_tree().physics_frame
			await secs(0.5)
			var r: Array = await crawl(-314.2, 468.9, float(gait[1]), float(gait[2]), 20.0)
			print("WATCH break beam: %s: %s in %.1f s, ended at %s%s" % [gait[0], "CROSSED" if bool(r[0]) else "did not cross", float(r[1]), r[2], ", KNOCKED OUT by the cross" if bool(r[3]) else ""])
			if str(gait[0]).begins_with("the low crawl"):
				await shot("53_beam_after_a_crawl")
	_free_cam = false


## Note 21: the pool's barrels. barrels:stretch measures how wide a gap of water a climber
## can stretch from one barrel to the next; barrels:watch watches them arrive and leave.
func _w_barrels(a: Array) -> void:
	var which := str(a[0]) if a.size() > 0 else "watch"
	const Drivers := preload("res://climber/drivers.gd")
	pk.warp("2.7")
	await secs(1.0)
	var c := me()
	var mine: Array = []
	for id in pk.things.movers:
		if str(id).begins_with("barril"):
			mine.append(pk.things.movers[id])
	if which == "stretch":
		# Two barrels are set a chosen gap apart (the rest sent away); the climber stands on
		# the east one and reaches a hand west for the other, as a player hopping west does.
		var d := Drivers.ScriptDriver.new()
		var old_driver = c.driver
		var speed := float((mine[0].mo as Dictionary).speed)
		var widest := 0.0
		for gap: float in [1.2, 1.5, 1.7, 1.9, 2.1, 2.3, 2.5]:
			var base := -(pk.clock) + 20.0 / speed  # (puts barrel A 20 m along its road right now)
			for i in mine.size():
				(mine[i].mo as Dictionary)["phase"] = base - (1.8 + gap) / speed if i == 1 else (base if i == 0 else base + 400.0 + 30.0 * i)
			await secs(0.3)
			var pa := mover_at("barril1")
			var pb := mover_at("barril2")
			stand(pa + Vector2(-0.7, 0.56))  # (at the first barrel's west end)
			c.driver = d
			d.clear()
			await secs(1.2)
			look(pa + Vector2(-1.5, 0.6), 3.0)
			var took := false
			var far := 0.0
			var t0 := pk.clock
			while pk.clock - t0 < 6.0 and not took:
				# The hand is held and aimed at the next barrel's near top corner for a
				# second (the body leans out after it on its feet), then let go to stick.
				var th := pk.clock
				while pk.clock - th < 1.0:
					pb = mover_at("barril2")
					d.point_limb(0, true, pb + Vector2(0.8, 0.52) + Vector2(Peak.ORIGIN.x, Peak.ORIGIN.y))
					await get_tree().physics_frame
					var foot_x := maxf(c.limb_end(2).x, c.limb_end(3).x)
					far = maxf(far, foot_x - c.limb_end(0).x)
				d.set_limb(0, false)
				await secs(0.25)
				took = c.limbs[0].grab_other == mine[1].nodes[0]
			print("WATCH barrels stretch: (the hand got %.2f m west of the rear foot at most)" % far)
			var feet_on: bool = c.limbs[2].grab_other == mine[0].nodes[0] or c.limbs[3].grab_other == mine[0].nodes[0]
			print("WATCH barrels stretch: %.1f m of water between them (middles %.1f m apart): the hand %s; a foot still on the first barrel: %s" % [gap, gap + 1.8, "TOOK the next barrel" if took else "could not reach it", feet_on])
			if took:
				widest = gap
				await shot("21_stretch_%.1f" % gap)
			d.clear()
			c.release_all()
		c.driver = old_driver
		print("WATCH barrels stretch: the widest gap of water a standing climber's hand crossed: %.1f m" % widest)
		_free_cam = false
		return
	# Watch: what is on the pool, five arrivals at the cove, five over the lip.
	look(Vector2(-300.0, 116.0), 9.0)
	await secs(4.0)
	var on_pool := 0
	var xs: Array = []
	for m: Dictionary in mine:
		if (m.vis as Node3D).visible:
			on_pool += 1
			xs.append(snappedf(mover_at(str(m.id)).x, 0.1))
	xs.sort()
	print("WATCH barrels: %d barrels in all, %d on the pool now, at x %s" % [mine.size(), on_pool, xs])
	await shot("21_pool_whole")
	look(Vector2(-311.6, 116.0), 3.4)
	var arrivals := 0
	var last_z := {}
	var t0 := pk.clock
	var shot_a := 0
	while arrivals < 5 and pk.clock - t0 < 75.0:
		await get_tree().physics_frame
		for m: Dictionary in mine:
			var z := float(m.get("zoff", 0.0))
			var id := str(m.id)
			if last_z.has(id) and float(last_z[id]) < -0.45 and z >= -0.45:
				arrivals += 1
				print("WATCH barrels: %s came out of the cove into the climb's plane at x %.1f, %.1f s into the watch" % [id, mover_at(id).x, pk.clock - t0])
			if shot_a < 2 and z < -1.0 - 1.2 * shot_a and z > -2.9 and (m.vis as Node3D).visible and last_z.has(id) and float(last_z[id]) != z:
				shot_a += 1
				await shot("21_cove_coming_out_%d" % shot_a)
			last_z[id] = z
	look(Vector2(-287.6, 108.0), 9.5)
	var overs := 0
	var seen := {}
	t0 = pk.clock
	var shot_o := 0
	while overs < 5 and pk.clock - t0 < 75.0:
		await get_tree().physics_frame
		for row: Array in pk.things._strays:
			var rb: RigidBody3D = row[0]
			if not is_instance_valid(rb):
				continue
			var id := rb.get_instance_id()
			if not seen.has(id):
				seen[id] = pk.clock
				if shot_o == 0:
					shot_o = 1
			if float(row[2]) >= 0.0 and float(seen[id]) > 0.0:
				overs += 1
				print("WATCH barrels: one went over the lip and hit the river %.1f s later at (%.1f, %.1f)" % [pk.clock - float(seen[id]), rb.position.x, rb.position.y])
				seen[id] = -1.0
			if shot_o == 1 and pk.clock - absf(float(seen[id])) > 1.2 and float(seen[id]) > 0.0:
				shot_o = 2
				await shot("21_over_the_lip")
	# One with a climber on it.
	_free_cam = false
	var ride: Dictionary = {}
	t0 = pk.clock
	while ride.is_empty() and pk.clock - t0 < 40.0:
		await get_tree().physics_frame
		for m: Dictionary in mine:
			var x := mover_at(str(m.id)).x
			if (m.vis as Node3D).visible and x > -292.5 and x < -291.5:
				ride = m
	if not ride.is_empty():
		stand(mover_at(str(ride.id)) + Vector2(0.0, 0.57))
		t0 = pk.clock
		while not holds().contains("RigidBody3D") and pk.clock - t0 < 20.0:
			await get_tree().physics_frame  # (until the barrel under it is the loose one)
		var after := holds()
		print("WATCH barrels: the barrel it stood on went loose %.1f s after it stepped on, at x %.1f" % [pk.clock - t0, where().x])
		await secs(1.3)
		await shot("21_riding_it_over")
		await secs(3.0)
		print("WATCH barrels: ridden over the lip: limbs just after it went loose: %s; 4.3 s later the climber is at %s, in water %s, limbs %s" % [after, where(), c.float_mode, holds()])
	_free_cam = false


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


## NOTE 20, THE ROPES: a climber on the mine's rope (1.4), pumped by the bench's own
## script (a leg thrown the way the body is going), pictured still, at the end of the
## second, fourth and fifth pushes, and half way through the flight after letting go.
func _w_rope(_a: Array) -> void:
	const Drivers := preload("res://climber/drivers.gd")
	pk.warp("1.4")
	await secs(0.5)
	var c := me()
	var rope: Dictionary = {}
	for r in pk.things.ropes:
		if str(r.id) == "cuerda_minero":
			rope = r
	var segs: Array = rope.segs
	var seg: RigidBody3D = segs[segs.size() - 2]
	var top: Vector2 = pk.world_of(rope.top)
	c.release_all()
	var d := Drivers.ScriptDriver.new()
	c.driver = d
	for l in c.limbs:
		l.regrip = 999.0
	var off := Vector2(seg.global_position.x, seg.global_position.y) - c.limb_end(0)
	var p := c.pose()
	for k in range(0, p.size(), 3):
		p[k] += off.x
		p[k + 1] += off.y
	c.apply_pose(p)
	c.attach(0, seg)
	look(pk.local_of(top) + Vector2(0, -3.2), 5.0)
	await secs(3.0)
	await shot("20_rope_hanging_still")
	var going := 0.0
	var pushes := 0
	var widest := 0.0
	var t0 := pk.clock
	while pk.clock - t0 < 26.0 and pushes < 5:
		var v := c.velocity()
		d.set_limb(3, true, Vector2(1 if v.x >= 0.0 else -1, 0))
		await ticks(1)
		var com := c.centre_of_mass()
		widest = maxf(widest, rad_to_deg(absf(atan2(com.x - top.x, top.y - com.y))))
		if absf(v.x) > 0.12:
			if going != 0.0 and signf(v.x) != going:
				pushes += 1
				print("WATCH rope: push %d took it %.0f degrees out, %.1f s in" % [pushes, widest, pk.clock - t0])
				if pushes in [2, 4, 5]:
					await shot("20_rope_push_%d" % pushes)
				widest = 0.0
			going = signf(v.x)
	# through the bottom going east, and let go
	var last_x := c.centre_of_mass().x - top.x
	while pk.clock - t0 < 40.0:
		var v := c.velocity()
		d.set_limb(3, true, Vector2(1 if v.x >= 0.0 else -1, 0))
		await ticks(1)
		var x := c.centre_of_mass().x - top.x
		if last_x < 0.0 and x >= 0.0:
			break
		last_x = x
	d.clear()
	c.release_all()
	var lv := c.velocity()
	print("WATCH rope: let go at the bottom at %.1f m/s (%.1f east, %.1f up)" % [lv.length(), lv.x, lv.y])
	await secs(0.7)
	await shot("20_rope_let_go")


## NOTES 28 AND 43, THE CAMERA'S OWN CONTROLS: a test pad's right stick looks around and
## its left trigger zooms out, in the real camera. look:CHALLENGE (default 1.4).
func _w_look(a: Array) -> void:
	var id := str(a[0]) if a.size() > 0 else "1.4"
	pk.warp(id)
	_free_cam = false
	await secs(2.5)
	var pad := {"stick": Vector2.ZERO, "buttons": {}, "look": Vector2.ZERO}
	Players.fake[1000] = pad
	var cam := get_viewport().get_camera_3d()
	var fr: Array = pk.cam_frame()
	var home := cam.position
	print("WATCH look at %s: the spot's own frame is %.1f m half-height, bias %s, drawn by its author: %s. The close camera stands %.1f m back (half-height %.2f m)" % [
		id, float(fr[0]), fr[1], fr[2], home.z, home.z * tan(deg_to_rad(cam.fov * 0.5))])
	await shot("28_43_normal")
	# the zoom: held
	pad.buttons["zoom"] = true
	var t0 := Time.get_ticks_msec()
	await secs(0.33)
	print("WATCH look: zoom held 0.33 s: half-height %.2f m" % (cam.position.z * tan(deg_to_rad(cam.fov * 0.5))))
	await secs(0.5)
	print("WATCH look: zoom held 0.83 s: half-height %.2f m, the camera moved %s from the close view" % [cam.position.z * tan(deg_to_rad(cam.fov * 0.5)), Vector2(cam.position.x - home.x, cam.position.y - home.y)])
	await shot("43_zoomed_out")
	# the look, while zoomed
	pad.look = Vector2(1, 0)
	await secs(0.6)
	await shot("28_43_zoomed_looking_east")
	pad.look = Vector2.ZERO
	pad.buttons["zoom"] = false
	await secs(0.33)
	print("WATCH look: zoom let go 0.33 s: half-height %.2f m" % (cam.position.z * tan(deg_to_rad(cam.fov * 0.5))))
	await secs(0.6)
	home = cam.position
	# the look: each way
	for row: Array in [["east", Vector2(1, 0)], ["west", Vector2(-1, 0)], ["down", Vector2(0, -1)], ["up", Vector2(0, 1)], ["half east", Vector2(0.6, 0)], ["a drifting stick", Vector2(0.15, 0.1)]]:
		pad.look = row[1]
		await secs(0.25)
		var quarter := Vector2(cam.position.x - home.x, cam.position.y - home.y)
		await secs(0.55)
		var full := Vector2(cam.position.x - home.x, cam.position.y - home.y)
		if str(row[0]) in ["east", "down"]:
			await shot("28_looking_" + str(row[0]))
		pad.look = Vector2.ZERO
		await secs(0.25)
		var back := Vector2(cam.position.x - home.x, cam.position.y - home.y)
		await secs(0.5)
		print("WATCH look %s: the view slid %.2f, %.2f m after 0.25 s and %.2f, %.2f m after 0.8 s; 0.25 s after letting go it was %.2f m from home; the climber is %s on screen at full look" % [
			row[0], quarter.x, quarter.y, full.x, full.y, back.length(), "still"])
	Players.fake.erase(1000)
	await secs(0.3)
	await shot("28_43_back_to_normal")


## NOTE 72, THE STATION'S LEVER: at rest; standing in the cart (it must not start); a hand
## on the handle; drawn over, and the cart going; and pulled from the deck with nobody in
## the cart. lever (no arguments).
func _w_lever(_a: Array) -> void:
	const Drivers := preload("res://climber/drivers.gd")
	pk.warp("0.1")
	await secs(0.4)
	var c := me()
	var lv: Dictionary = pk.things.levers[0]
	var cart: Dictionary = pk.things.movers["cart0"]
	var rest: Vector2 = pk.things.lever_handle(lv)
	var old_driver = c.driver
	var d := Drivers.ScriptDriver.new()
	stand(Vector2(-9.0, 2.76))
	look(Vector2(-8.2, 3.6), 2.6)
	await secs(3.0)
	print("WATCH lever: at rest its handle is at %s. After 3 s standing in the cart: rolling %s, %.2f m along" % [rest, cart.run, float(cart.dist)])
	await shot("72_lever_at_rest")
	c.driver = d
	var t0 := pk.clock
	while pk.clock - t0 < 2.5 and int(lv.limb) != 1:
		d.point_limb(1, true, pk.world_of(rest))
		await ticks(1)
	print("WATCH lever: the right hand, its button held, took the handle after %.2f s (limb %d)" % [pk.clock - t0, int(lv.limb)])
	await shot("72_lever_hand_on_it")
	t0 = pk.clock
	var mid_shot := false
	while pk.clock - t0 < 3.0 and not bool(lv.thrown):
		d.point_limb(1, true, pk.world_of(rest + Vector2(1.0, 0.0)))
		await ticks(1)
		if not mid_shot and pk.things.lever_handle(lv).x - rest.x > 0.35:
			mid_shot = true
			await shot("72_lever_half_way")
	print("WATCH lever: drawn over in %.2f s: thrown %s, the handle now at %s (%.2f m east); the cart rolling %s" % [pk.clock - t0, lv.thrown, pk.things.lever_handle(lv), pk.things.lever_handle(lv).x - rest.x, cart.run])
	d.set_limb(1, false)
	await secs(0.25)
	await shot("72_lever_pulled")
	await secs(0.9)
	look(Vector2(-10.5, 3.6), 3.4)
	await secs(0.05)
	await shot("72_cart_going")
	# from the deck, with nobody in the cart: put the cart home first (the game's own rule
	# brings it back after 25 s with the climber away; the probe just waits it out far off)
	c.driver = old_driver
	stand(Vector2(40.0, 0.2))
	var t1 := pk.clock
	while pk.clock - t1 < 80.0 and (bool(cart.run) or float(cart.arrived) >= 0.0):
		await secs(0.5)
	await secs(0.3)
	print("WATCH lever: the cart was home again %.1f s after the pull; the lever thrown %s, its handle %.2f m from rest" % [pk.clock - t0, lv.thrown, pk.things.lever_handle(lv).distance_to(rest)])
	stand(Vector2(-7.0, 2.3))
	look(Vector2(-8.2, 3.6), 2.6)
	c.driver = d
	d.clear()
	await secs(1.0)
	t0 = pk.clock
	while pk.clock - t0 < 4.0 and not bool(lv.thrown):
		var aim: Vector2 = rest if int(lv.limb) < 0 else rest + Vector2(1.0, 0.0)
		d.point_limb(0, true, pk.world_of(aim))
		await ticks(1)
	d.set_limb(0, false)
	await secs(0.6)
	print("WATCH lever: from the deck, the left hand: thrown %s after %.2f s; the cart rolling %s with the climber at %s (not in it)" % [lv.thrown, pk.clock - t0, cart.run, where()])
	await shot("72_pulled_from_the_deck")
	c.driver = old_driver


## THE FAR LAYERS (the far-facade rule, Parker 11-13): at each challenge's start, the game's
## own camera, then the same spot pulled back to a view 48 m tall. far:TAG:7.1:7.5 ...
## Pictures are <challenge>_close_<TAG> and <challenge>_pulled_back_<TAG>.
func _w_far(a: Array) -> void:
	var tag := str(a[0])
	var first := true
	for id: String in a.slice(1):
		_free_cam = false
		pk.warp(id)
		await secs(6.5 if first else 3.5)  # (the area's banner clears)
		first = false
		var cam: Camera3D = main.cam
		var at := Vector2(cam.position.x - Peak.ORIGIN.x, cam.position.y - Peak.ORIGIN.y)
		var nm := id.replace(".", "_")
		print("WATCH far %s: the camera at %s, %.1f m back" % [id, at, cam.position.z])
		await shot(nm + "_close_" + tag)
		look(at, 24.0)
		await secs(0.5)
		await shot(nm + "_pulled_back_" + tag)
	_free_cam = false


# ================================================================ the fix run of 11-13, group 1
## (These scenes touch only what the old code has too, so the same scene shoots the
## "before" with the old files swapped in.)

## The spawner of an area nearest a point.
func _spawner_near(at: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_d := INF
	for sp in pk.things.spawners:
		var d := Peak.v2(sp.def.at).distance_to(at)
		if d < best_d:
			best_d = d
			best = sp
	return best


## Seconds until a spawner's next drop.
func _until_drop(sp: Dictionary) -> float:
	return float(PeakThings._drops(sp.def, pk.clock + float(sp.def.get("phase", 0.0)))[1])


## NOTE 86: the icicles of 9.2. g1ice:TAG
func _w_g1ice(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("9.2")
	await secs(6.5)  # (the area's banner clears)
	stand(Vector2(-316.5, 786.6))
	look(Vector2(-323.5, 799.0), 4.2)
	var sp := _spawner_near(Vector2(-324.8, 802.1))
	while _until_drop(sp) > 1.6 or _until_drop(sp) < 1.2:
		await ticks(1)
	await shot("86_icicle_coming_" + tag)
	while _until_drop(sp) > 0.15:
		await ticks(1)
	await shot("86_icicle_about_to_drop_" + tag)
	await secs(1.3)
	await shot("86_icicle_landed_" + tag)
	# what lies on the floor: over 14 s, the most icicles lying still at once
	var most := 0
	var t0 := pk.clock
	while pk.clock - t0 < 14.0:
		var lying := 0
		for s2 in pk.things.spawners:
			if str(s2.area) != "a9":
				continue
			for row: Array in s2.live:
				if row[0] is RigidBody3D and is_instance_valid(row[0]) and (row[0] as RigidBody3D).linear_velocity.length() < 0.3:
					lying += 1
		most = maxi(most, lying)
		await secs(0.1)
	print("WATCH g1ice %s: the most icicles lying on the floor at once over 14 s: %d" % [tag, most])
	await shot("86_floor_after_14s_" + tag)
	# a knocked-out climber on the floor under the four sources: when can it get up?
	var c := me()
	var kos := 0
	var up_windows: Array = []
	var up_since := -1.0
	t0 = pk.clock
	stand(Vector2(-323.4, 786.6))
	c.knock_out()
	while pk.clock - t0 < 20.0:
		if c.knockout_left > 0.0:
			if up_since >= 0.0:
				up_windows.append(snappedf(pk.clock - up_since, 0.1))
				up_since = -1.0
				kos += 1
		elif up_since < 0.0:
			up_since = pk.clock
		await ticks(1)
	if up_since >= 0.0:
		up_windows.append(snappedf(pk.clock - up_since, 0.1))
	print("WATCH g1ice %s: lying on the floor under the sources for 20 s: knocked out again %d times; the spells awake between: %s s" % [tag, kos, up_windows])


## NOTE 88: the serac of 9.5. g1serac:TAG
func _w_g1serac(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("9.5")
	await secs(0.4)
	var m: Dictionary = pk.things.movers["serac"]
	look(Vector2(-320.0, 832.5), 8.0)
	stand(Vector2(-326.4, 832.1))
	await secs(1.0)
	await shot("88_serac_standing_" + tag)
	var c := me()
	c.attach(0, m.nodes[0])
	var t0 := pk.clock
	var marks := [[2.5, "88_serac_tipping_"], [5.3, "88_serac_near_level_"], [5.9, "88_serac_past_level_"], [6.4, "88_serac_shattered_"], [9.6, "88_serac_growing_"], [13.0, "88_serac_back_"]]
	var k := 0
	var log := []
	while pk.clock - t0 < 13.2:
		if k < marks.size() and pk.clock - t0 >= float(marks[k][0]):
			await shot(str(marks[k][1]) + tag)
			log.append("%.1f s: %.0f deg, %s" % [pk.clock - t0, rad_to_deg(float(m.angle)), m.get("tip_state", "-")])
			k += 1
		await ticks(1)
	print("WATCH g1serac %s: %s; the climber at %s" % [tag, log, where()])


## NOTES 91 and 93: the slabs of 9.8. g1slab:TAG
func _w_g1slab(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("9.8")
	await secs(0.4)
	stand(Vector2(-284.0, 846.2))
	look(Vector2(-292.5, 870.0), 8.5)
	var sp := _spawner_near(Vector2(-301.2, 880.4))
	while _until_drop(sp) > 1.0 or _until_drop(sp) < 0.6:
		await ticks(1)
	await shot("93_slab_in_the_mouth_" + tag)
	while _until_drop(sp) > 0.1:
		await ticks(1)
	await shot("93_slab_coming_out_" + tag)
	await secs(1.6)
	await shot("91_slab_on_the_chute_" + tag)
	await secs(1.0)
	await shot("91_slab_at_the_rope_" + tag)
	# 22 s: how many slabs got past the rope's foot (below y 858) still on the chute
	var past := {}
	var thrown := {}
	var t0 := pk.clock
	while pk.clock - t0 < 22.0:
		for row: Array in sp.live:
			if row[0] == null or not is_instance_valid(row[0]):
				continue
			var id := (row[0] as Object).get_instance_id()
			if float(row[2]) >= 0.0:
				thrown[id] = true
			elif (row[0] as Node3D).position.y < 857.0:
				past[id] = true
		await ticks(2)
	print("WATCH g1slab %s: over 22 s, %d slabs went past the rope's foot down the chute, %d were thrown into the cave" % [tag, past.size(), thrown.size()])
	look(Vector2(-288.0, 862.0), 5.0)
	await secs(0.3)
	await shot("91_the_kicker_" + tag)


## NOTES 89 and 70: wind. g1wind:TAG
func _w_g1wind(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	for spot in [["7.1", Vector2(-214.0, 584.0), 7.0, "89_wind_cliffs_"], ["9.7", Vector2(-280.0, 840.0), 7.0, "89_wind_glacier_"], ["10.1", Vector2(-300.0, 896.0), 9.0, "89_wind_storm_ridge_"]]:
		pk.warp(str(spot[0]))
		await secs(0.6)
		look(spot[1], float(spot[2]))
		# wait for a gust that blows over the spot
		var t0 := pk.clock
		while pk.clock - t0 < 8.0:
			var k := 0.0
			for row in pk.zones.winds:
				if Peak.rect_has(row.def.rect, spot[1], 2.0):
					k = maxf(k, pk.zones._gust(row.def))
			if k > 0.8:
				break
			await ticks(1)
		await secs(0.3)
		await shot(str(spot[3]) + tag)


## NOTE 95: the lightning of 10.3. g1bolt:TAG
func _w_g1bolt(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("10.3")
	await secs(6.5)
	look(Vector2(-311.0, 926.0), 9.0)
	var row: Dictionary = pk.zones.strikes[0]
	var period := float(row.def.period)
	while fposmod(pk.clock + float(row.def.get("phase", 0.0)), period) < period - 0.9 or fposmod(pk.clock + float(row.def.get("phase", 0.0)), period) > period - 0.6:
		await ticks(1)
	await shot("95_hum_" + tag)
	while fposmod(pk.clock + float(row.def.get("phase", 0.0)), period) > 0.5:
		await ticks(1)
	await ticks(4)
	await shot("95_strike_" + tag)


## NOTES 98, 76, 77: what can be touched is drawn. g1drawn:TAG
func _w_g1drawn(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("11.3")
	await secs(0.6)
	look(Vector2(-325.0, 990.0), 7.5)
	await secs(0.3)
	await shot("98_ring_ropes_" + tag)
	pk.warp("7.10")
	await secs(0.6)
	look(Vector2(-219.0, 675.5), 6.0)
	await secs(0.3)
	await shot("76_bull_wheel_" + tag)
	pk.warp("8.2")
	await secs(0.6)
	var g: Dictionary = pk.things.movers["g2a"]
	var at: Vector2 = (g.home as Vector2) + (g.offset as Vector2) + Vector2(0.5, -3.2)
	look(at, 4.5)
	await secs(0.1)
	await shot("77_gondola_rails_" + tag)


## NOTE 84: the cold hand. g1cold:TAG
func _w_g1cold(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("9.1")
	await secs(0.6)
	var c := me()
	# the nearest timed ice hold to the start
	var best: Dictionary = {}
	var bd := INF
	for h in pk.things.holds:
		if str(h.type) == "timed" and float((h.def as Dictionary).t) >= 1.8:
			var d: float = pk.things._hold_at(h).distance_to(where())
			if d < bd:
				bd = d
				best = h
	if best.is_empty():
		print("WATCH g1cold: no ice hold")
		return
	var hat: Vector2 = pk.things._hold_at(best)
	put_limb(1, hat)
	still()
	c.attach(1, best.body)
	look(hat + Vector2(0.4, -0.6), 2.2)
	var glyphs: Array = c.get("_glyphs")
	var offs := []
	var t0 := pk.clock
	var shots := [[0.3, "84_cold_hand_just_taken_"], [1.75, "84_cold_hand_nearly_gone_"]]
	var k := 0
	while pk.clock - t0 < 2.3:
		if glyphs != null and glyphs.size() > 1 and is_instance_valid(glyphs[1]):
			offs.append(Vector2((glyphs[1] as Node3D).position.x, (glyphs[1] as Node3D).position.y).length())
		if k < shots.size() and pk.clock - t0 >= float(shots[k][0]):
			await shot(str(shots[k][1]) + tag)
			k += 1
		await ticks(1)
	var early := 0.0
	var late := 0.0
	for i in offs.size():
		if i < offs.size() / 4:
			early = maxf(early, float(offs[i]))
		elif i > offs.size() * 3 / 4 - 10 and i < offs.size() * 3 / 4:
			late = maxf(late, float(offs[i]))
	print("WATCH g1cold %s: the hand's mark moved up to %.3f m in its first half second, up to %.3f m near the end; the hand let go %s" % [tag, early, late, c.limbs[1].grab_other == null])



## A slab's life on the chute of 9.8, followed: every live slab every half second. slabtrack
func _w_slabtrack(_a: Array) -> void:
	pk.warp("9.8")
	await secs(0.4)
	stand(Vector2(-284.0, 846.2))
	look(Vector2(-296.0, 873.0), 10.0)
	var sp := _spawner_near(Vector2(-301.2, 880.4))
	var log := []
	for i in 24:
		var rows := []
		for row: Array in sp.live:
			var n = row[0]
			if n == null or not is_instance_valid(n):
				rows.append("dead")
			else:
				rows.append("(%.1f,%.1f)%s" % [(n as Node3D).position.x, (n as Node3D).position.y, " thrown" if float(row[2]) >= 0.0 else ""])
		log.append("%.1f: %s" % [_until_drop(sp), rows])
		if i == 6:
			await shot("slabtrack_3s")
		await secs(0.5)
	print("WATCH slabtrack: near %s, at %s, def %s" % [pk.player_at().distance_to(Peak.v2(sp.def.at)), sp.def.at, sp.def.kind])
	for l in log:
		print("WATCH slab ", l)


## NOTE 7: the tool tip at the long jumps. NOTE 28: the Controls board's pages. g2hud:TAG
func _w_g2hud(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	var n: int = pk.long_jump_count() if pk.has_method("long_jump_count") else -1
	print("WATCH g2hud %s: long jumps found: %d" % [tag, n])
	for spot in [["11.4", Vector2(-335.7, 996.3)], ["7.8", Vector2(-184.7, 659.6)]]:
		var id: String = spot[0]
		pk.warp(id)
		await secs(6.5)
		stand(spot[1] + Vector2(0, -1.0))
		_free_cam = false
		await secs(0.8)
		await shot("7_tool_tip_at_%s_%s" % [id.replace(".", "_"), tag])
	pk.warp("11.1")
	await secs(1.5)
	await shot("7_no_tool_tip_at_11_1_" + tag)
	main.show_screen("controls")
	await secs(1.0)
	await shot("28_controls_page_1_" + tag)
	var st = main.lucha.settings
	if st.has_method("_show_page"):
		for k in st._stops.size():
			if str(st._stops[k].kind) == "page":
				st._activate(k)
				break
		await secs(0.6)
		await shot("28_controls_page_2_" + tag)
	main.show_screen("hud")


## NOTE 73: the cart's hop over the broken rail. g3hop:TAG
func _w_g3hop(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("0.3")
	await secs(1.0)
	var cart: Dictionary = pk.things.movers["cart0"]
	var c := me()
	stand(Vector2(-9.0, 2.76))
	await secs(1.5)
	# the right hand on the cart's end, held: a rider who holds on
	c.attach(1, cart.nodes[0])
	cart["pulled"] = true
	var air_shot := false
	var land_shot := false
	var top_clear := 0.0
	var flew := false
	var landed_x := 0.0
	var worst := 0.0
	var t0 := pk.clock
	while pk.clock - t0 < 16.0 and (bool(cart.run) or float(cart.dist) == 0.0):
		var at: Vector2 = (cart.home as Vector2) + (cart.offset as Vector2)
		look(at + Vector2(0, 0.8), 3.6)
		worst = maxf(worst, where().distance_to(at))
		if cart.has("fly"):
			flew = true
			var road: float = pk.things._road_y(cart, at.x)
			top_clear = maxf(top_clear, at.y - road)
			if not air_shot and at.x < -92.5:
				air_shot = true
				await shot("73_cart_in_the_air_" + tag)
		elif flew and landed_x == 0.0:
			landed_x = at.x
			await ticks(3)
			await shot("73_cart_landing_dust_" + tag)
			land_shot = true
		await ticks(1)
	if not air_shot:
		look(Vector2(-93.0, -2.5), 3.6)
		await shot("73_cart_in_the_air_" + tag)
	print("WATCH g3hop %s: flew %s, the floor's most clearance over the road %.2f m, down at x %.1f; the rider never more than %.2f m from the cart; still holding %s" % [tag, flew, top_clear, landed_x, worst, c.limbs[1].grab_other != null])


## NOTE 25: the dam's one lift, its winch on board. g3lift:TAG
func _w_g3lift(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	const Drivers := preload("res://climber/drivers.gd")
	pk.warp("2.11")
	await secs(6.5)
	look(Vector2(-436.0, 159.0), 8.5)
	await secs(0.3)
	await shot("25_the_dam_" + tag)
	if not pk.things.movers.has("jaula"):
		print("WATCH g3lift %s: no lift (the old dam)" % tag)
		return
	var m: Dictionary = pk.things.movers["jaula"]
	var c := me()
	stand(Vector2(-438.9, 152.25))
	await secs(1.0)
	var old_driver = c.driver
	var d := Drivers.ScriptDriver.new()
	c.driver = d
	var t0 := pk.clock
	var took := -1.0
	var ang := 0.0
	var log := []
	var shots := [[6.0, "25_winding_"], [16.0, "25_winding_higher_"]]
	var k := 0
	while pk.clock - t0 < 22.0:
		var hub: Vector2 = pk.things.winch_hub(m)
		if int(m.w_limb) < 0:
			d.point_limb(1, true, pk.world_of(pk.things.winch_handle(m)))
		else:
			if took < 0.0:
				took = pk.clock - t0
			ang += TAU / 1.4 / Engine.physics_ticks_per_second  # a turn every 1.4 s
			d.point_limb(1, true, pk.world_of(hub + Vector2(cos(ang), sin(ang)) * 0.35))
		var deck: float = (m.home as Vector2).y + (m.offset as Vector2).y
		look(Vector2(-436.5, deck + 1.5), 4.5)
		if k < shots.size() and pk.clock - t0 >= float(shots[k][0]):
			await shot(str(shots[k][1]) + tag)
			log.append("%.0f s: deck %.1f" % [pk.clock - t0, deck])
			k += 1
		await ticks(1)
	var top: float = (m.home as Vector2).y + (m.offset as Vector2).y
	d.set_limb(1, false)
	await secs(3.0)
	var after: float = (m.home as Vector2).y + (m.offset as Vector2).y
	c.driver = old_driver
	print("WATCH g3lift %s: the hand took the winch after %.2f s; %s; after 22 s the deck at %.2f (from 152.2, the crest 167.0); 3 s after letting go %.2f; the climber at %s" % [tag, took, log, top, after, where()])


## NOTE 54: Pay Your Respects (press F at the altar). g3fart
func _w_g3fart(_a: Array) -> void:
	pk.warp("5.10")
	await secs(6.5)
	stand(Vector2(-327.0, 469.0))
	look(Vector2(-326.0, 470.0), 3.5)
	await secs(1.0)
	var had: bool = pk.get("achievements") != null and (pk.achievements as Dictionary).has("pay_your_respects")
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_F
	ev.keycode = KEY_F
	ev.pressed = true
	Input.parse_input_event(ev)
	await secs(0.5)
	await shot("54_pay_your_respects")
	var up := ev.duplicate()
	up.pressed = false
	Input.parse_input_event(up)
	await secs(0.3)
	print("WATCH g3fart: earned before %s, after %s; slot %d" % [had, (pk.achievements as Dictionary).has("pay_your_respects"), me().local_slot])


## NOTE 58: the dynamite rung. NOTE 62: the vents' grates. g3boom
func _w_g3boom(_a: Array) -> void:
	pk.warp("6.4")
	await secs(6.5)
	var h: Dictionary = {}
	for x in pk.things.holds:
		if str(x.type) == "dynamite":
			h = x
	if h.is_empty():
		print("WATCH g3boom: no dynamite")
		return
	var c := me()
	var mid: Vector2 = pk.things._hold_at(h)
	put_limb(1, mid)
	await ticks(2)  # (THE LATE TRANSFORM LAW: the server has the moved hand before it is welded)
	put_limb(1, mid)
	await ticks(1)
	c.attach(1, h.body)
	look(mid + Vector2(0, -0.6), 3.0)
	await secs(0.15)
	await shot("58_dynamite_lit")
	var before_blast := "hand %.2f m from the stick, guard %.2f, state %s" % [pk.local_of(c.limb_end(1)).distance_to(mid), float(c.get("_impact_guard")), c.state]
	var ko := false
	var t0 := pk.clock
	var shot_done := false
	while pk.clock - t0 < 1.2:
		ko = ko or c.knockout_left > 0.0
		if not shot_done and pk.things.blasts > 0:
			shot_done = true
			await ticks(2)
			await shot("58_dynamite_blows")
		await ticks(1)
	print("WATCH g3boom: before the blast: ", before_blast)
	await secs(1.2)
	look(Vector2(-284.0, 521.0), 4.0)
	await shot("58_after_the_blast")
	var gone := (h.body as CollisionObject3D).collision_layer == 0
	await secs(9.5)
	var back := (h.body as CollisionObject3D).collision_layer != 0
	print("WATCH g3boom: blasts %d, knocked out %s, the climber at %s, the stick gone %s, back 10 s later %s" % [pk.things.blasts, ko, where(), gone, back])
	pk.warp("6.8")
	await secs(1.0)
	look(Vector2(-246.0, 560.0), 7.0)
	await secs(2.0)
	await shot("62_the_grates_lit")


## NOTE 58 again: the blast's own rule, with the chest put 0.5 m from the stick and the fuse lit by hand. g3boom2
func _w_g3boom2(_a: Array) -> void:
	pk.warp("6.4")
	await secs(6.5)
	var h: Dictionary = {}
	for x in pk.things.holds:
		if str(x.type) == "dynamite":
			h = x
	var c := me()
	var mid: Vector2 = pk.things._hold_at(h)
	var p := c.pose()
	var ch := pk.local_of(Climber.pos2(c.bodies["chest"]))
	var shift := mid + Vector2(0.5, 0.0) - ch
	for k in range(0, p.size(), 3):
		p[k] += shift.x
		p[k + 1] += shift.y
	c.apply_pose(p)
	still()
	h["lit_at"] = pk.clock - 0.95  # (0.05 s of fuse left: the climber has no time to fall away)
	look(mid + Vector2(0.3, -0.5), 3.0)
	var ko := false
	var t0 := pk.clock
	var start_v := 0.0
	while pk.clock - t0 < 1.4:
		ko = ko or c.knockout_left > 0.0
		await ticks(1)
		if pk.things.blasts > 0 and start_v == 0.0:
			start_v = Vector2((c.bodies["chest"] as RigidBody3D).linear_velocity.x, (c.bodies["chest"] as RigidBody3D).linear_velocity.y).length()
	print("WATCH g3boom2: blasts %d, knocked out %s, the chest thrown at %.1f m/s" % [pk.things.blasts, ko, start_v])


## NOTE 70: 7.8's tail wind, during a gust, looking at the horn and the fang. g3wind78:TAG
func _w_g3wind78(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("7.8")
	await secs(6.5)
	look(Vector2(-182.0, 660.0), 8.0)
	var t0 := pk.clock
	while pk.clock - t0 < 9.0:
		var k := 0.0
		for row in pk.zones.winds:
			if Peak.rect_has(row.def.rect, Vector2(-185.0, 660.0), 0.5):
				k = maxf(k, pk.zones._gust(row.def))
		if k > 0.9:
			break
		await ticks(1)
	await secs(0.3)
	await shot("70_wind_to_the_fang_" + tag)


## NOTE 82: the zip line ridden to its end. g3zip:TAG
func _w_g3zip(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("8.7")
	await secs(6.5)
	var m: Dictionary = pk.things.movers["zip"]
	var c := me()
	var handle: Vector2 = (m.home as Vector2) + Vector2(0.0, -0.9)
	put_limb(1, handle)
	await ticks(2)
	put_limb(1, handle)
	await ticks(1)
	c.attach(1, m.nodes[0])
	var t0 := pk.clock
	var shot_mid := false
	while pk.clock - t0 < 6.0 and (bool(m.run) or float(m.dist) == 0.0):
		var at: Vector2 = (m.home as Vector2) + (m.offset as Vector2)
		look(at + Vector2(-2.0, -2.0), 5.0)
		if not shot_mid and pk.clock - t0 > 1.4:
			shot_mid = true
			await shot("82_zip_riding_" + tag)
		await ticks(1)
	var end_at: Vector2 = (m.home as Vector2) + (m.offset as Vector2)
	await secs(0.6)
	await shot("82_zip_at_the_end_" + tag)
	c.release_all()
	await secs(2.0)
	print("WATCH g3zip %s: the ride took %.1f s; the trolley ended at %s; let go, the climber is at %s (the deck: x -196..-190, top 720)" % [tag, pk.clock - t0 - 2.6, end_at, where()])
	await shot("82_zip_let_go_" + tag)


## NOTE 92: the storm ridge's foot, where the six cloud cards stood. g3clouds:TAG
func _w_g3clouds(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("10.1")
	await secs(6.5)
	look(Vector2(-299.0, 891.0), 9.0)
	await secs(0.5)
	await shot("92_storm_ridge_foot_" + tag)
	pk.warp("10.4")
	await secs(3.0)
	look(Vector2(-303.0, 928.0), 11.0)
	await secs(0.5)
	await shot("92_storm_ridge_towers_" + tag)


## NOTE 96: the weather balloon's rope(s), and how far the ridge's wind carries a rope's foot. g3globo:TAG
func _w_g3globo(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("10.8")
	await secs(6.5)
	look(Vector2(-322.5, 954.5), 6.5)
	var most := 0.0
	var t0 := pk.clock
	while pk.clock - t0 < 10.0:
		for r in pk.things.ropes:
			if str(r.id).begins_with("globo"):
				var end: RigidBody3D = r.bob if r.bob != null else (r.segs as Array).back()
				var top: Vector2 = pk.local_of(Climber.pos2((r.segs as Array)[0]))
				most = maxf(most, absf(pk.local_of(Climber.pos2(end)).x - top.x))
		await ticks(1)
	await shot("96_globo_rope_" + tag)
	var ids := []
	for r in pk.things.ropes:
		if str(r.id).begins_with("globo"):
			ids.append(r.id)
	print("WATCH g3globo %s: ropes %s; over 10 s the foot strayed at most %.2f m sideways from the top" % [tag, ids, most])


## NOTE 99: El Ultimo Salto, the post and the ring. g3ring:TAG
func _w_g3ring(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("11.4")
	await secs(6.5)
	look(Vector2(-333.5, 997.0), 4.5)
	await secs(0.3)
	await shot("99_post_and_ring_" + tag)


## NOTE 100: hang on the bell rope, pump it, and watch the bell. g3bell:TAG
func _w_g3bell(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("11.5")
	await secs(6.5)
	var r: Dictionary = {}
	for x in pk.things.ropes:
		if str(x.id) == "bell_rope":
			r = x
	var c := me()
	look(Vector2(-355.7, 1001.5), 5.5)
	await shot("100_bell_still_" + tag)
	var seg: RigidBody3D = (r.segs as Array)[6]
	var at := pk.local_of(Climber.pos2(seg))
	put_limb(1, at)
	await ticks(2)
	put_limb(1, at)
	await ticks(1)
	c.release_all()  # (the warp's pose already has a hand on the rope: let go, let the bell settle, then catch)
	await secs(2.5)
	at = pk.local_of(Climber.pos2(seg))
	put_limb(1, at)
	await ticks(2)
	put_limb(1, at)
	await ticks(1)
	var tolls0 := int(pk.things.get("bell_tolls")) if pk.things.get("bell_tolls") != null else 0
	var holds := []
	for l in c.limbs:
		holds.append(l.grab_other != null and l.grab_other.has_meta("peak_rope"))
	print("WATCH g3bell %s: before the catch: on the rope already %s (limbs on rope pieces %s), tolls so far %d" % [tag, r.get("was_on"), holds, tolls0])
	c.attach(1, seg)
	await ticks(1)
	print("WATCH g3bell %s: hand on the rope %s (limb 1 holds %s), the bell found %s, seg layer %d" % [tag, c.limbs[1].grab_other == seg, c.limbs[1].grab_other, r.get("bell_node") != null, seg.collision_layer])
	var caught_tolls := 0
	await secs(0.4)
	caught_tolls = (int(pk.things.get("bell_tolls")) if pk.things.get("bell_tolls") != null else 0) - tolls0
	var most := 0.0
	var most_c := 0.0
	var shot_done := false
	var t0 := pk.clock
	# pump: a shove of 2 m/s east, then each time the swing turns a shove the way it now goes (4 at most), over 12 s
	var shoves := 0
	var was_dir := 0.0
	while pk.clock - t0 < 12.0:
		var vx := (c.bodies["chest"] as RigidBody3D).linear_velocity.x
		var dir := signf(vx) if absf(vx) > 0.15 else was_dir
		if shoves < 4 and (shoves == 0 or (dir != was_dir and dir != 0.0)):
			shoves += 1
			var push := 2.0 if shoves == 1 else 2.0 * dir
			for b: RigidBody3D in c.bodies.values():
				b.linear_velocity += Vector3(push, 0, 0)
			dir = signf(push)
		was_dir = dir
		if r.has("b_ang"):
			most = maxf(most, absf(float(r.b_ang)))
			most_c = maxf(most_c, absf(float(r.c_ang)))
			if not shot_done and absf(float(r.b_ang)) > 0.18:
				shot_done = true
				await shot("100_bell_swinging_" + tag)
		await ticks(1)
	var tolls := (int(pk.things.get("bell_tolls")) if pk.things.get("bell_tolls") != null else 0) - tolls0
	c.release_all()
	var t1 := pk.clock
	var settle := -1.0
	while pk.clock - t1 < 10.0:
		if r.has("b_ang") and absf(float(r.b_ang)) < 0.02 and absf(float(r.b_w)) < 0.05 and settle < 0.0:
			settle = pk.clock - t1
		await ticks(1)
	await shot("100_bell_after_" + tag)
	print("WATCH g3bell %s: tolls on the catch %d, in 12 s of pumping %d; the bell tipped at most %.0f deg, the clapper %.0f deg; let go, it rocked to rest in %.1f s (-1: not in 10 s)" % [tag, caught_tolls, tolls, rad_to_deg(most), rad_to_deg(most_c), settle])


## NOTE 103: the cart room. Ride the cart down the new road and off the lip; with "catch",
## at the chain take it with the right hand (the nearest piece, if any is within 1.2 m). g103:TAG[:catch]
func _w_g103(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	var catch := a.size() > 1 and str(a[1]) == "catch"
	pk.warp("1.7")
	await secs(1.0)
	look(Vector2(-217.5, 38.0), 12.5)
	await secs(0.5)
	if not catch:
		await shot("103_cart_room_" + tag)
	var cart: Dictionary = pk.things.movers["cart1"]
	var c := me()
	stand(Vector2(-206.5, 40.56))
	await secs(0.3)
	c.attach(1, cart.nodes[0])
	var chain: Dictionary = {}
	for r in pk.things.ropes:
		if str(r.id) == "cadena":
			chain = r
	var v_crest := 0.0
	var v_dip := 0.0
	var v_lip := 0.0
	var worst := 0.0
	var t0 := pk.clock
	var dip_shot := false
	while pk.clock - t0 < 12.0 and cart.get("loose") == null:
		var at: Vector2 = (cart.home as Vector2) + (cart.offset as Vector2)
		if float(cart.dist) > 0.0:
			worst = maxf(worst, where().distance_to(at))
		if at.x > -213.6 and at.x < -213.2:
			v_crest = float(cart.v)
		if at.y < 28.6:
			v_dip = maxf(v_dip, float(cart.v))
		v_lip = float(cart.v)
		if not dip_shot and at.y < 29.0 and not catch:
			dip_shot = true
			await shot("103_cart_in_the_dip_" + tag)
		await ticks(1)
	var rb: RigidBody3D = cart.get("loose")
	var cross_y := -1.0
	var top_y := -INF
	var tail_y := -1.0
	var near_hand := INF
	var near_chest := INF
	var caught := false
	var flight_shot := false
	var lip_at := Vector2.ZERO
	var lip_v := Vector2.ZERO
	if rb != null:
		lip_at = pk.local_of(Climber.pos2(rb))
		lip_v = Vector2(rb.linear_velocity.x, rb.linear_velocity.y)
		var t1 := pk.clock
		var px := lip_at.x
		while pk.clock - t1 < 3.0 and is_instance_valid(rb):
			var p := pk.local_of(Climber.pos2(rb))
			top_y = maxf(top_y, p.y)
			var segs: Array = chain.segs
			for seg: RigidBody3D in segs:
				var sp := pk.local_of(Climber.pos2(seg))
				near_chest = minf(near_chest, sp.distance_to(pk.local_of(Climber.pos2(c.bodies["chest"]))))
				near_hand = minf(near_hand, minf(sp.distance_to(pk.local_of(c.limb_end(0))), sp.distance_to(pk.local_of(c.limb_end(1)))))
			if px > -230.6 and p.x <= -230.6:
				cross_y = p.y
				var last: RigidBody3D = segs.back()
				tail_y = pk.local_of(Climber.pos2(last)).y - 0.25
			if catch and not caught and p.x < -228.0:
				var hand := pk.local_of(c.limb_end(1))
				var best: RigidBody3D = null
				var bd := 0.35
				for seg: RigidBody3D in segs:
					var d := pk.local_of(Climber.pos2(seg)).distance_to(hand)
					if d < bd:
						bd = d
						best = seg
				if best != null:
					for i in c.limbs.size():
						c.release(i)
					c.attach(1, best)
					caught = true
					var held := []
					for k in [12, 48, 120]:
						await ticks(k - (0 if held.is_empty() else [12, 48, 120][held.size() - 1]))
						held.append(c.limbs[1].grab_other != null and segs.has(c.limbs[1].grab_other))
					print("WATCH g103 %s: the hand was %.2f m from the chain when it took it; holding after 0.1 / 0.4 / 1.0 s: %s; last strain %s" % [tag, bd, held, pk.things.get("last_strain")])
			if not flight_shot and p.x < -229.0:
				flight_shot = true
				look(Vector2(-226.0, 37.0), 9.0)
				await shot("103_cart_at_the_chain_" + tag + ("_catch" if catch else ""))
			px = p.x
			await ticks(1)
	var west := INF
	var t2 := pk.clock
	while pk.clock - t2 < (8.0 if catch else 2.0):
		west = minf(west, where().x)
		await ticks(1)
	print("WATCH g103 %s: over %.0f s after the flight the climber came west to x %.2f (the fall's wind starts at x -238)" % [tag, 8.0 if catch else 2.0, west])
	var on_chain := false
	for l in c.limbs:
		if l.grab_other != null and chain.segs.has(l.grab_other):
			on_chain = true
	if catch:
		look(where() + Vector2(0, 2.0), 7.0)
		await shot("103_on_the_chain_" + tag)
	print("WATCH g103 %s%s: v over the crest %.1f, in the dip %.1f, at the lip %.1f m/s; the rider at most %.2f m from the cart; let loose at %s going %s (%.1f m/s); crossed the chain's line (x -230.6) at y %.2f, top of the arc %.2f; the chain's tail at %.2f; nearest hand to the chain %.2f m, chest %.2f m; on the chain 2 s later %s, the climber at %s" % [tag, " catch" if catch else "", v_crest, v_dip, v_lip, worst, lip_at, lip_v, lip_v.length(), cross_y, top_y, tail_y, near_hand, near_chest, on_chain, where()])


## The nearest a mover's shapes (or one of them) come to a point, now.
func _mover_near(m: Dictionary, p: Vector2, only := -1) -> float:
	var best := INF
	var at: Vector2 = (m.home as Vector2) + (m.offset as Vector2)
	var rot := Transform2D(float(m.get("angle", 0.0)), at)
	var shapes: Array = m.def.shapes
	for k in shapes.size():
		if only >= 0 and k != only:
			continue
		var pts: Array = shapes[k].pts
		var poly := PackedVector2Array()
		for q in pts:
			poly.append(rot * Vector2(float(q[0]), float(q[1])))
		if Geometry2D.is_point_in_polygon(p, poly):
			return 0.0
		for i in poly.size():
			var c := Geometry2D.get_closest_point_to_segment(p, poly[i], poly[(i + 1) % poly.size()])
			best = minf(best, c.distance_to(p))
	return best


## NOTE 77: the two stations' real roofs: how near the cars come to them. g77:TAG
func _w_g77(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("8.1")
	await secs(2.0)
	look(Vector2(-242.0, 692.0), 6.5)
	var corner_lo := Vector2(-237.6, 692.5)
	var corner_hi := Vector2(-237.6, 692.8)
	var near_any := INF
	var near_step := INF
	var shot_done := false
	var t0 := pk.clock
	while pk.clock - t0 < 12.5:
		for id in ["g1a", "g1b"]:
			var m: Dictionary = pk.things.movers[id]
			near_any = minf(near_any, minf(_mover_near(m, corner_lo), _mover_near(m, corner_hi)))
			var s := minf(_mover_near(m, corner_lo, 5), _mover_near(m, corner_hi, 5))
			near_step = minf(near_step, s)
			if not shot_done and s < 1.3:
				shot_done = true
				await shot("77_low_roof_car_passing_" + tag)
		await ticks(1)
	print("WATCH g77 %s: low station: over a lap the cars came within %.2f m of the roof's east end (their steps %.2f m); the gangway's rail post top to the roof's underside %.2f m" % [tag, near_any, near_step, Vector2(-239.85, 689.9).distance_to(Vector2(-239.85, 692.5))])
	pk.warp("8.11")
	await secs(2.0)
	look(Vector2(-272.0, 789.0), 5.5)
	var eave := Vector2(-268.0, 790.5)
	var near_roof := INF
	var near_car := INF
	var who := ""
	t0 = pk.clock
	var shot2 := false
	while pk.clock - t0 < 16.0:
		for k in 4:
			var m: Dictionary = pk.things.movers["ex%d" % (k + 1)]
			var r := _mover_near(m, eave, 1)
			if r < near_roof:
				near_roof = r
				who = "ex%d" % (k + 1)
			near_car = minf(near_car, _mover_near(m, eave))
			if not shot2 and r < 2.3:
				shot2 = true
				await shot("77_high_roof_car_below_" + tag)
		await ticks(1)
	if not shot2:
		await shot("77_high_roof_" + tag)
	print("WATCH g77 %s: high station: the nearest a car's roof came to the eave's corner %.2f m (%s); any part of a car %.2f m; the deck's top to the roof's underside %.2f m" % [tag, near_roof, who, near_car, 790.5 - 786.0])


## NOTE 102: the frogs' hot spring. "drop": slide off the summit's west flank; "slide": go
## down the spring's slide; "out": break the frost wall from the doorstep. g102:TAG:WHICH
func _w_g102(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	var which := str(a[1]) if a.size() > 1 else "drop"
	pk.warp("11.6")
	await secs(1.5)
	var c := me()
	var lowest := INF
	var fastest := 0.0
	var t0 := pk.clock
	match which:
		"drop":
			stand(Vector2(-361.9, 999.2))
			look(Vector2(-369.0, 985.0), 9.0)
			var shot1 := false
			while pk.clock - t0 < 14.0:
				var p := where()
				if not shot1 and p.y < 983.5:
					shot1 = true
					await shot("102_off_the_eave_" + tag)
				await ticks(1)
			look(Vector2(-371.0, 972.5), 5.5)
			await shot("102_in_the_spring_" + tag)
		"slide":
			stand(Vector2(-378.5, 971.5))
			for b: RigidBody3D in c.bodies.values():
				b.linear_velocity = Vector3(0, -2.0, 0)  # (dropped in feet first)
			look(Vector2(-372.0, 972.0), 6.0)
			var shot2 := false
			var p_prev := where()
			while pk.clock - t0 < 30.0:
				var p := where()
				lowest = minf(lowest, p.y)
				fastest = maxf(fastest, (p - p_prev).length() * 120.0)
				p_prev = p
				if p.y < 900.0 and not shot2:
					look(Vector2(-330.0, 888.0), 9.0)
				if not shot2 and p.x > -318.0 and p.y < 892.0:
					shot2 = true
					await shot("102_out_of_the_slide_" + tag)
				await ticks(1)
			if not shot2:
				look(where(), 8.0)
				await shot("102_slide_end_" + tag)
		"out":
			stand(Vector2(-367.6, 978.35))
			look(Vector2(-360.0, 974.0), 9.0)
			await secs(0.5)
			var wall: Dictionary = {}
			for h in pk.things.holds:
				var at: Vector2 = pk.things._hold_at(h)
				if absf(at.x + 366.05) < 0.4 and absf(at.y - 980.2) < 1.2:
					wall = h
			if not wall.is_empty():
				var mid: Vector2 = pk.things._hold_at(wall)
				put_limb(1, mid + Vector2(-0.3, -0.6))
				await ticks(2)
				put_limb(1, mid + Vector2(-0.3, -0.6))
				await ticks(1)
				c.attach(1, wall.body)
				await shot("102_on_the_frost_wall_" + tag)
			print("WATCH g102 %s out: the frost wall found %s, the hand on it %s" % [tag, not wall.is_empty(), c.limbs[1].grab_other != null])
			await secs(3.6)
			var broke := not wall.is_empty() and (wall.body as CollisionObject3D).collision_layer == 0
			var held := []
			for l in c.limbs:
				held.append(l.grab_other != null)
			var space := (c.bodies["chest"] as RigidBody3D).get_world_3d().direct_space_state
			var hits := []
			for q in [Vector2(-366.0, 978.8), Vector2(-366.0, 979.6), Vector2(-365.2, 978.3), Vector2(-364.5, 977.8)]:
				var pp := PhysicsPointQueryParameters3D.new()
				var w := pk.world_of(q)
				pp.position = Vector3(w.x, w.y, 0.0)
				pp.collision_mask = 1
				hits.append(space.intersect_point(pp, 4).size())
			print("WATCH g102 %s out: 3.6 s later the wall is broken: %s; limbs held %s; solids at points %s; the wall's layer %d" % [tag, broke, held, hits, (wall.body as CollisionObject3D).collision_layer])
			c.release_all()  # (the feet were planted on the doorstep)
			for l in c.limbs:
				l.regrip = 1.5
			for b: RigidBody3D in c.bodies.values():
				b.linear_velocity += Vector3(3.0, -0.5, 0)  # (a step east, into the tunnel)
			var shot3 := false
			while pk.clock - t0 < 14.0:
				var p := where()
				if not shot3 and p.x > -352.0:
					shot3 = true
					look(Vector2(-347.0, 966.0), 6.0)
					await shot("102_out_by_the_tunnel_" + tag)
				await ticks(1)
	var in_water := false
	for z in pk.zones.waters if pk.zones.get("waters") != null else []:
		pass
	print("WATCH g102 %s %s: after %.0f s the climber is at %s (lowest %.1f, fastest %.1f m/s)" % [tag, which, pk.clock - t0, where(), lowest, fastest])


## The decos that move with movers (a1 item 9, a2 item 8) and the gates' pistons (a2 6g). gfollow:TAG
func _w_gfollow(a: Array) -> void:
	var tag := str(a[0]) if a.size() > 0 else ""
	pk.warp("2.5")
	await secs(3.0)
	look(Vector2(-252.5, 113.0), 6.0)
	var out := []
	for k in 2:
		for f in pk.things.followers:
			var n: Node3D = f[0]
			if not is_instance_valid(n):
				continue
			var m: Dictionary = pk.things.movers.get(str(f[1].mover), {})
			if m.is_empty():
				continue
			out.append("%s %s: deco moved %s / turned %.2f; the mover's offset %s, angle %.2f" % [f[1].mover, f[1].how,
				Vector2(n.position.x - (f[2] as Vector3).x, n.position.y - (f[2] as Vector3).y), n.rotation.z - float(f[3]),
				m.get("offset", Vector2.ZERO), float(m.get("angle", 0.0))])
		await shot("followers_gates_%d_%s" % [k, tag])
		await secs(2.1)
	for line in out:
		print("WATCH gfollow %s: %s" % [tag, line])
