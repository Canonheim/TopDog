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
