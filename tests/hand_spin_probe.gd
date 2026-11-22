extends Node
## HAND SPIN PROBE (Parker 11-22: "I was spinning my hand in game in a circle and for some reason my
## hand was like glitching off my body a bunch for a few frames while I was spinning"). Windowed: the
## drawn hand (its mesh, as the screen shows it, interpolated) is measured against the forearm's
## wrist point every frame while the steered hand is swung round in circles. It must never be drawn
## more than HAND_REACH from the wrist.
const Drivers := preload("res://climber/drivers.gd")
const HAND_REACH := 0.32  # m: a hand mesh's farthest point from its wrist, with room
var fails := 0


func _ready() -> void:
	get_tree().create_timer(30).timeout.connect(func(): print("TIMEOUT"); get_tree().quit(1))
	var world := Node3D.new()
	add_child(world)
	var cam := Camera3D.new()
	cam.position = Vector3(0, 1.2, 5)
	world.add_child(cam)
	var floor_body := StaticBody3D.new()
	floor_body.collision_layer = Climber.LAYER_WORLD
	floor_body.position.y = -0.1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(20, 0.2, 2)
	shape.shape = box
	floor_body.add_child(shape)
	world.add_child(floor_body)
	var c := Climber.new()
	add_child(c)
	c.build(Vector2.ZERO, world, preload("res://game/game.gd").KNIGHT)
	var d := Drivers.ScriptDriver.new()
	c.driver = d
	for i in 60:
		await get_tree().physics_frame
	var limb := -1
	for i in c.limbs.size():
		if c.limbs[i].def.end == "hand_r":
			limb = i
	var mesh: Node3D = c._hand_meshes["hand_r"][0]
	var wj: Array = c._wrists["hand_r"]
	var worst := 0.0
	var over := 0
	var frames := 0
	var flips := 0
	var worst_body := 0.0
	var worst_drawn_vs_body := 0.0
	var worst_follow := 0.0
	var last_rel := INF
	var hand_body: Node3D = wj[1]
	var t := 0.0
	var rate := 1.6
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--rate="):
			rate = float(arg.get_slice("=", 1))
	while t < 6.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var a := t * TAU * rate  # swung round `rate` times a second
		d.set_limb(limb, true, Vector2(cos(a), sin(a)), 1.0)
		var w2: Vector2 = Climber.xf2(wj[0]) * (wj[2] as Vector2)
		# The hand mesh keeps the model's origin (at the feet): measure its box's middle.
		var drawn: Vector3 = mesh.get_global_transform_interpolated() * (mesh as MeshInstance3D).get_aabb().get_center()
		var arm_at := Vector3(w2.x, w2.y, 0.0)
		var gap := Vector2(drawn.x - arm_at.x, drawn.y - arm_at.y).length()
		worst = maxf(worst, gap)
		if gap > HAND_REACH:
			over += 1
		frames += 1
		# The drawn hand must ride its body as the screen blends it (no stutter against the arm).
		var rides: Vector3 = (hand_body.get_global_transform_interpolated() * mesh.transform) * (mesh as MeshInstance3D).get_aabb().get_center()
		worst_follow = maxf(worst_follow, rides.distance_to(drawn))
		var body_mid: Vector3 = hand_body.global_transform * (hand_body.global_transform.affine_inverse() * mesh.global_transform * (mesh as MeshInstance3D).get_aabb().get_center())
		worst_body = maxf(worst_body, Vector2(body_mid.x - arm_at.x, body_mid.y - arm_at.y).length())
		worst_drawn_vs_body = maxf(worst_drawn_vs_body, Vector2(drawn.x - body_mid.x, drawn.y - body_mid.y).length())
		# The drawn hand's turn against the forearm: a jump between frames is a visible snap.
		var mx := mesh.get_global_transform_interpolated().basis
		var fx := (wj[0] as Node3D).get_global_transform_interpolated().basis
		var rel := wrapf(atan2(mx.x.y, mx.x.x) - atan2(fx.x.y, fx.x.x), -PI, PI)
		if last_rel != INF and absf(wrapf(rel - last_rel, -PI, PI)) > deg_to_rad(35.0):
			flips += 1
		last_rel = rel
	print("frames %d, the drawn hand at most %.3f m from its wrist, %d frames past %.2f m, %d snaps of its turn" % [frames, worst, over, HAND_REACH, flips])
	print("the physics hand at most %.3f m from its wrist; the drawing at most %.3f m from the physics hand" % [worst_body, worst_drawn_vs_body])
	print("the drawn hand off its blended body at most %.4f m" % worst_follow)
	if worst_follow > 0.01:
		fails += 1
		print("FAIL the drawn hand does not ride its blended body")
	if worst > HAND_REACH:
		fails += 1
		print("FAIL the drawn hand left the wrist")
	print("RESULT fails=", fails)
	get_tree().quit(fails)
