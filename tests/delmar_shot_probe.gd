extends Node
## DEL MAR AND MOUNTAIN FRAMES (the TD Environment Maker): shoots the plaza's cameras
## (the mountains behind the town), then builds DelMarScenery, sinks the mountains as
## the game does for Del Mar, and shoots the Del Mar cameras.
## -- --out=DIR (writes dm_<name>.png)  --mountains=new (the modelled PlazaMountains in
## place of whatever the plaza built, to review them before they're wired in)
const PLAZA_CAMS := [
	["title", Vector3(0.0, 2.13, 10.47), Vector3(0.0, 1.83, 0.0)],
	["lobby", Vector3(-5.5, 5.85, 31.0), Vector3(-5.5, 4.85, 0.0)],
	["plaza_wide", Vector3(14.0, 3.0, 32.0), Vector3(14.0, 2.5, 0.0)],
	["plaza_high", Vector3(0.0, 15.0, 10.47), Vector3(0.0, 14.7, 0.0)],
]
const CAMS := [
	["start", Vector3(102.5, 2.8, 13.1), Vector3(102.5, 2.5, 0.0)],
	["wide", Vector3(114.0, 3.2, 25.8), Vector3(114.0, 2.9, 0.0)],
	["far", Vector3(126.0, 5.0, 31.0), Vector3(126.0, 4.5, 0.0)],
	["results", Vector3(98.5, 2.0, 9.0), Vector3(98.5, 1.5, 0.0)],
	["midpan", Vector3(51.0, 2.5, 11.8), Vector3(51.0, 2.2, 0.0)],
	["beach", Vector3(76.0, 2.0, 12.0), Vector3(82.0, 0.0, -10.0)],
	["aerial", Vector3(110.0, 70.0, 60.0), Vector3(120.0, 0.0, -90.0)],
]


func _ready() -> void:
	var out := "user://dm_frames"
	var new_mountains := false
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.get_slice("=", 1)
		elif a == "--mountains=new":
			new_mountains = true
	DirAccess.make_dir_recursive_absolute(out)
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(3.0).timeout
	var lucha = main.lucha
	if new_mountains:
		for m in lucha._mountains:
			if is_instance_valid(m[0]):
				(m[0] as Node3D).queue_free()
		lucha._mountains.clear()
		var plaza: Node3D = main.world.find_child("Plaza", true, false)
		for m in PlazaMountains.build(plaza, Stage.PLAZA_GROUND):
			lucha._mountains.append(m)
		lucha._mountains_t = 0.0
	var cam := Camera3D.new()
	cam.fov = 34.0
	get_tree().root.add_child(cam)
	for c in PLAZA_CAMS:
		await _shoot(cam, c, out)
	# Del Mar: the scenery, and the mountains sunk (the game's option B).
	var scenery := DelMarScenery.new()
	main.world.add_child(scenery)
	scenery.build()
	for i in 60:
		lucha.mountains_down(true, 1.0 / 30.0)
		scenery.tick(1.0 / 30.0)
	# main.gd drives mountains_down(Del Mar on?) every frame, and no Del Mar match is
	# running here, so it would raise them again: keep them down by leaving the list.
	for m in lucha._mountains:
		if is_instance_valid(m[0]):
			(m[0] as Node3D).visible = false
	lucha._mountains.clear()
	for c in CAMS:
		await _shoot(cam, c, out)
	get_tree().paused = false
	get_tree().quit()


func _shoot(cam: Camera3D, c: Array, out: String) -> void:
	cam.position = c[1]
	cam.look_at(c[2], Vector3.UP)
	cam.make_current()
	await get_tree().create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(out + "/dm_" + str(c[0]) + ".png")
	print("SHOT ", c[0])
