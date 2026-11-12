extends Node
## THE PEAK'S BACKDROP, FRAMED (the TD Environment Maker): builds PeakBackdrop standing
## alone behind a stand-in of the mountain's card, and shoots it from where the follow
## camera would be up the climb, each under its area's sky. -- --out=DIR (bd_<name>.png)
## The cave shots hide the mountain's card, since it covers the cavern layers in game.
const ORIGIN := Vector3(-110.0, -0.9, 0.0)  # Peak.ORIGIN
const WEST := [[-350, 1000], [-372, 950], [-430, 800], [-520, 550], [-620, 250], [-700, 0], [-714, -40]]
## [name, local x (null: 3 m off the east face), local y, frame half height, sky, sun, ambient, hide the card]
const SHOTS := [
	["cliffs_590", null, 590.0, 6.0, "#58A8F0", 1.3, "#D5DCE6", false],
	["cliffs_660", null, 660.0, 12.0, "#58A8F0", 1.3, "#D5DCE6", false],
	["cable_740", -200.0, 740.0, 14.0, "#F2B66A", 1.2, "#E6D2B8", false],
	["glacier_840", null, 840.0, 8.0, "#9CCBEF", 1.35, "#C8DCEC", false],
	["storm_915", null, 915.0, 8.0, "#3A414E", 0.55, "#7E8794", false],
	["storm_955", null, 955.0, 6.0, "#3A414E", 0.55, "#7E8794", false],
	["summit_985", null, 985.0, 8.0, "#FFCF7A", 1.4, "#F2E2C0", false],
	["summit_1004", -350.0, 1004.0, 14.0, "#FFCF7A", 1.4, "#F2E2C0", false],
	["slope_300", null, 300.0, 10.0, "#58A8F0", 1.3, "#D5DCE6", false],
	["slope_120", null, 120.0, 10.0, "#8FD0FF", 1.25, "#D9D7DA", false],
	["trailhead", 0.0, 3.0, 4.2, "#8FD0FF", 1.25, "#D9D7DA", false],
	["cave_mine", -220.0, 30.0, 12.0, "#120C08", 0.28, "#6E5236", true],
	["cave_river", -340.0, 130.0, 12.0, "#0A1216", 0.26, "#4C6E78", true],
	["cave_crystal", -380.0, 226.0, 14.0, "#0E0824", 0.34, "#7C68B8", true],
	["cave_fungus", -240.0, 320.0, 14.0, "#0A160B", 0.32, "#5E8A52", true],
	["cave_temple", -372.0, 424.0, 14.0, "#140C08", 0.3, "#8A5E36", true],
	["cave_chimney", -254.0, 530.0, 12.0, "#1C0A06", 0.36, "#9A4A2E", true],
]


func _ready() -> void:
	var out := "user://bd_frames"
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
	# the mountain's own card (the course's `st` body, z -9) and its snow, standing in
	var body := PackedVector2Array()
	for p in PeakBackdrop.EAST:
		body.append(Vector2(float(p[0]), float(p[1])))
	body.reverse()
	for p in WEST:
		if float(p[1]) < 1000.0:
			body.append(Vector2(float(p[0]), float(p[1])))
	var card := PeakBackdrop._cards([body], -9.0, Color("#8C8273"))
	card.position = ORIGIN
	world.add_child(card)
	var ledge := PeakBackdrop._box(Vector3(6.0, 1.0, 2.4), Color("#E6DCC6"), Vector3.ZERO)
	world.add_child(ledge)
	var backdrop := PeakBackdrop.build(world, ORIGIN)
	var cam := Camera3D.new()
	cam.fov = 34.0
	get_tree().root.add_child(cam)
	for s in SHOTS:
		var y: float = s[2]
		var x: float = PeakBackdrop._x_at(y) + 3.0 if s[1] == null else float(s[1])
		var dist: float = float(s[3]) / tan(deg_to_rad(17.0))
		cam.position = ORIGIN + Vector3(x, y + 1.0, dist)
		cam.look_at(ORIGIN + Vector3(x, y + 1.0, 0.0), Vector3.UP)
		cam.make_current()
		ledge.position = ORIGIN + Vector3(x - 1.0, y - 0.5, 0.0)  # a ledge on the plane, for scale
		card.visible = not bool(s[7])
		var sky := Color(str(s[4]))
		main._world_sky.sky_top_color = sky.darkened(0.25)
		main._world_sky.sky_horizon_color = sky.lightened(0.2)
		main._world_sky.ground_horizon_color = sky.lightened(0.2)
		main._world_sky.ground_bottom_color = sky.lightened(0.2)  # (no darker band under the horizon: see the note to Top Dog)
		main._world_env.ambient_light_color = Color(str(s[6]))
		main._world_sun.light_energy = float(s[5])
		for i in 20:
			backdrop.tick(1.0 / 60.0, cam)
		await get_tree().create_timer(0.4).timeout
		backdrop.tick(1.0 / 60.0, cam)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(out + "/bd_" + str(s[0]) + ".png")
		print("SHOT ", s[0])
	get_tree().quit()
