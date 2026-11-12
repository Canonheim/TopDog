extends Node
## THE GREAT FALLS, followed with a real climber: dropped limp at the top of each of the
## mountain's long drops, hands and feet free to catch whatever grips, and tracked until
## it holds on or comes to rest. Prints where it went and how long it took.
##   Godot_console.exe --headless --path . res://tests/peak_drop.tscn [-- --only=pozo]
const ClimberScript := preload("res://climber/climber.gd")
const Drivers := preload("res://climber/drivers.gd")
const DROPS := [
	["pozo", "down the well from the third crossing", Vector2(-300.0, 478.0)],
	["pozo1", "down the well from the first crossing", Vector2(-300.0, 270.0)],
	["garganta", "off the cliffs past El Balcon's edge", Vector2(-200.0, 600.0)],
	["cable", "off the cableway, mid-span", Vector2(-215.0, 730.0)],
	["east", "flung east of the fang", Vector2(-140.0, 720.0)],
	["summit", "the last jump, missed", Vector2(-345.0, 992.0)],
	["river", "into the lower river, 20 m above the lip", Vector2(-262.0, 96.0)],
]
const MAX_S := 240.0


func _ready() -> void:
	var only := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--only="):
			only = a.get_slice("=", 1)
	var world := Node3D.new()
	add_child(world)
	var pk := Peak.new()
	world.add_child(pk)
	pk.setup(null)
	pk.begin()
	pk.dev_warp = true
	var hz := Engine.physics_ticks_per_second
	for i in 4:
		await get_tree().physics_frame
	var n := 0
	for row in DROPS:
		if only != "" and str(row[0]) != only:
			continue
		n += 1
		var c: Climber = ClimberScript.new()
		c.climber_id = 600 + n
		add_child(c)
		var at: Vector2 = row[2]
		c.build(pk.world_of(at), world, null)
		c.driver = Drivers.ScriptDriver.new()
		pk.on_player(c, true)
		c.release_all()
		var t := 0.0
		var low := at.y
		var held := 0.0
		var still := 0.0
		var water_s := 0.0
		var log: Array = []
		var next_log := 0.0
		var how := "still moving"
		while t < MAX_S:
			pk.tick(1.0 / hz)
			await get_tree().physics_frame
			t += 1.0 / hz
			var p := pk.local_of(c.centre_of_mass())
			low = minf(low, p.y)
			if c.float_mode:
				water_s += 1.0 / hz
			if t >= next_log:
				next_log += 6.0
				log.append("%ds (%d, %d)%s" % [int(t), int(p.x), int(p.y), " in water" if c.float_mode else ""])
			if c.touches_solid():
				held += 1.0 / hz
				if held > 1.5:
					how = "HOLDS ON"
					break
			else:
				held = 0.0
			if c.float_mode and c.linear_speed() < 0.25:
				still += 1.0 / hz
				if still > 4.0:
					how = "FLOATS in still water"
					break
			elif not c.float_mode and c.linear_speed() < 0.1:
				still += 1.0 / hz
				if still > 4.0:
					how = "AT REST, holding nothing (scramble %s)" % c.scramble
					break
			else:
				still = 0.0
			if pk.out_of_world(c.centre_of_mass()):
				how = "LEFT THE WORLD"
				break
		var end := pk.local_of(c.centre_of_mass())
		var near := ""
		var near_d := INF
		for ch in pk.challenges:
			var d := Peak.v2(ch.anchor).distance_to(end)
			if d < near_d:
				near_d = d
				near = "%s %s" % [ch.id, ch.name]
		print("DROP %s: %s, from (%d, %d): %s at (%d, %d) after %d s, %d m lower, %d s in water, nearest %s (%d m)" % [row[0], row[1], int(at.x), int(at.y), how, int(end.x), int(end.y), int(t), int(at.y - end.y), int(water_s), near, int(near_d)])
		print("DROP    path: ", " > ".join(log))
		c.remove()
		for i in 4:
			pk.tick(1.0 / hz)
			await get_tree().physics_frame
	get_tree().quit()
