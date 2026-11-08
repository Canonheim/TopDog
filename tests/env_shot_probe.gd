extends Node
## THE TOWN FRAMES (the environment pass): the title, then Practice on the plaza
## seen from fixed cameras at the follow camera's places (fov 34), so two builds
## compare frame for frame. -- --out=DIR (writes env_<name>.png there)
const CAMS := [
	["play_g0_x55", Vector3(5.5, 1.32, 6.71), Vector3(5.5, 1.02, 0.0)],
	["play_g0_x0", Vector3(-1.09, 1.32, 6.71), Vector3(-1.09, 1.02, 0.0)],
	["play_5m", Vector3(0, 5.27, 6.71), Vector3(0, 4.97, 0.0)],
	["play_10m", Vector3(0, 10.27, 6.71), Vector3(0, 9.97, 0.0)],
	["play_15m", Vector3(0, 15.27, 6.71), Vector3(0, 14.97, 0.0)],
	["play_20m", Vector3(0, 20.27, 6.71), Vector3(0, 19.97, 0.0)],
	["wide", Vector3(0, 6.0, 40.0), Vector3(0, 6.0, 0.0)],
]


func _ready() -> void:
	var out := "user://env_frames"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.get_slice("=", 1)
	DirAccess.make_dir_recursive_absolute(out)
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(3.0).timeout
	await _shot(out + "/env_title.png")
	main._start_practice()
	await get_tree().create_timer(2.0).timeout
	var cam := Camera3D.new()
	cam.fov = 34.0
	get_tree().root.add_child(cam)
	for c in CAMS:
		cam.position = c[1]
		cam.look_at(c[2], Vector3.UP)
		cam.make_current()
		await get_tree().create_timer(0.4).timeout
		await _shot(out + "/env_" + str(c[0]) + ".png")
	get_tree().paused = false
	get_tree().quit()


func _shot(path: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	print("SHOT ", path)
