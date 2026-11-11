extends Node
## DEL MAR SCENERY FRAMES (the TD Environment Maker): builds DelMarScenery beside the
## plaza and shoots it from the plan's cameras. For review only: it hides the plaza's
## land box and its mountain cut-outs (as the game will, per the plan) in this run.
## -- --out=DIR (writes dm_<name>.png)
const CAMS := [
	["start", Vector3(102.5, 2.8, 13.1), Vector3(102.5, 2.5, 0.0)],
	["wide", Vector3(114.0, 3.2, 25.8), Vector3(114.0, 2.9, 0.0)],
	["midpan", Vector3(51.0, 2.5, 11.8), Vector3(51.0, 2.2, 0.0)],
	["beach", Vector3(76.0, 2.0, 12.0), Vector3(82.0, 0.0, -10.0)],
	["aerial", Vector3(110.0, 70.0, 60.0), Vector3(120.0, 0.0, -90.0)],
	["title", Vector3(0.0, 2.13, 10.47), Vector3(0.0, 1.83, 0.0)],
	["lobby", Vector3(-5.5, 5.85, 31.0), Vector3(-5.5, 4.85, 0.0)],
]


func _ready() -> void:
	var out := "user://dm_frames"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.get_slice("=", 1)
	DirAccess.make_dir_recursive_absolute(out)
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(3.0).timeout
	var scenery := DelMarScenery.new()
	main.world.add_child(scenery)
	scenery.build()
	for mi in main.world.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.mesh is BoxMesh and (m.mesh as BoxMesh).size.x >= 3999.0:
			m.visible = false  # the plaza's land box: the plan's polygon left of the line instead
			main.world.add_child(scenery._flat(DelMarScenery.plaza_land_outline(), DelMarScenery.GROUND_Y, DelMarScenery.LAND, "PlazaLand"))
	for n in main.world.find_children("*", "Node3D", true, false):
		if str((n as Node).scene_file_path).contains("mountain_cutout"):
			(n as Node3D).visible = false  # option B: the flats are lowered for Del Mar
	var cam := Camera3D.new()
	cam.fov = 34.0
	get_tree().root.add_child(cam)
	for i in 30:
		scenery.tick(1.0 / 30.0)
	for c in CAMS:
		var show_dm: bool = not (str(c[0]) in ["title", "lobby"])
		cam.position = c[1]
		cam.look_at(c[2], Vector3.UP)
		cam.make_current()
		await get_tree().create_timer(0.4).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(out + "/dm_" + str(c[0]) + ".png")
		print("SHOT ", c[0], " ", show_dm)
	get_tree().paused = false
	get_tree().quit()
