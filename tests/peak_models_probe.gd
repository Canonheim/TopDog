extends Node
## THE PEAK'S LIVING THINGS, IN THE GAME'S LIGHT (the TD Environment Maker): stands the kit
## models of PARTS.md's "TD Environment Maker" table in rows before a plain card, under
## the game's own cel shading and ink, and shoots each row. A missing model shows as a
## red box of its table size. -- --out=DIR (pm_<row>.png)
## [name, width, height, hangs from the top or stands at its centre (else on its base)]
const ROWS := {
	"fungus": [["mushroom_cap_s", 2.0, 1.5, ""], ["mushroom_cap_m", 4.0, 2.5, ""], ["mushroom_cap_l", 7.0, 4.0, ""], ["puffball", 1.2, 1.2, "centre"],
		["spore_pod", 0.36, 0.5, ""], ["glow_moss", 1.0, 0.18, ""], ["giant_snail", 2.4, 1.8, ""], ["vine_leaf", 0.6, 1.6, "top"]],
	"crystal": [["crystal_cluster_c", 1.0, 1.5, ""], ["crystal_cluster_a", 2.0, 3.0, ""], ["crystal_cluster_b", 4.0, 5.0, ""], ["crystal_spire", 2.0, 10.0, ""],
		["chandelier_crystal", 2.0, 2.5, "top"], ["stalactite_a", 0.8, 3.0, "top"], ["stalactite_b", 1.5, 6.0, "top"]],
	"giant": [["mushroom_giant", 16.0, 22.0, ""], ["giant_snail", 2.4, 1.8, ""], ["mushroom_cap_l", 7.0, 4.0, ""]],
	"cliffs": [["vulture", 2.6, 1.5, ""], ["nest", 1.8, 0.6, ""], ["burro", 1.8, 1.5, ""], ["shrub", 1.0, 0.8, ""], ["boulder", 1.2, 1.2, "centre"], ["dead_tree", 6.0, 8.0, ""]],
	"ice": [["icicle_big", 0.6, 2.5, "top"], ["ice_block", 2.0, 2.0, ""], ["snow_cornice", 6.0, 2.0, ""]],
}


func _ready() -> void:
	var out := "user://pm_frames"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out = a.get_slice("=", 1)
	DirAccess.make_dir_recursive_absolute(out)
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(3.0).timeout
	main.ui.visible = false
	main.lucha.visible = false
	var world: Node3D = main.world
	var cam := Camera3D.new()
	cam.fov = 34.0
	get_tree().root.add_child(cam)
	var base := Vector3(0.0, 400.0, 0.0)  # well clear of the plaza
	for row_name in ROWS:
		var row: Array = ROWS[row_name]
		var holder := Node3D.new()
		world.add_child(holder)
		var total := 0.0
		var tall := 0.0
		for r in row:
			total += float(r[1]) + 1.0
			tall = maxf(tall, float(r[2]))
		var wall := PeakBackdrop._cards([PackedVector2Array([Vector2(-total, -1.0), Vector2(total, -1.0), Vector2(total, tall * 1.6 + 2.0), Vector2(-total, tall * 1.6 + 2.0)])], -4.0, Color("#5A5566"))
		holder.add_child(wall)
		var ground := PeakBackdrop._box(Vector3(total * 2.0, 0.4, 8.0), Color("#8C8273"), Vector3(0.0, -0.2, 0.0))
		holder.add_child(ground)
		holder.position = base
		var x := -total * 0.5
		for r in row:
			var w: float = r[1]
			var h: float = r[2]
			var n: Node3D = LuchaKit.kit_model(str(r[0]))
			if n == null:
				n = PeakBackdrop._box(Vector3(w, h, w), Color("#D8262E"), Vector3(0.0, h * 0.5, 0.0))
				var wrap := Node3D.new()
				wrap.add_child(n)
				n = wrap
				print("MISSING ", r[0])
			var y := 0.0
			if str(r[3]) == "top":
				y = tall * 0.9 if h < tall * 0.9 else h
			elif str(r[3]) == "centre":
				y = h * 0.5
			n.position = Vector3(x + w * 0.5 + 0.5, y, 0.0)
			holder.add_child(n)
			x += w + 1.0
		var half_w := total * 0.5 + 0.5
		var half_h := maxf(tall * 0.5 + 0.6, half_w / (1920.0 / 1010.0))
		var dist := half_h / tan(deg_to_rad(17.0))
		for view in [["", Vector3(0.0, half_h - 0.3, dist)], ["_q", Vector3(dist * 0.42, half_h * 1.35, dist * 0.92)]]:
			cam.position = base + (view[1] as Vector3)
			cam.look_at(base + Vector3(0.0, half_h - 0.3, 0.0), Vector3.UP)
			cam.make_current()
			await get_tree().create_timer(0.5).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(out + "/pm_" + str(row_name) + str(view[0]) + ".png")
		print("SHOT ", row_name)
		holder.queue_free()
		await get_tree().process_frame
	get_tree().quit()
