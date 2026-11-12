extends Node
## How fast does the pinwheel swim go? Still water, one arm circling at several rates.
## The river's currents (tools/peak/areas/a2.py) are set against these numbers.
##   Godot_console.exe --headless --path . res://tests/peak_swim_probe.tscn
const ClimberScript := preload("res://climber/climber.gd")
const Drivers := preload("res://climber/drivers.gd")


func _ready() -> void:
	var world := Node3D.new()
	add_child(world)
	var pk := Peak.new()
	world.add_child(pk)
	pk.course_dir = "res://tests/peak_lab/"
	pk.setup(null)
	pk.begin()
	pk.dev_warp = true
	var hz := Engine.physics_ticks_per_second
	for rate in [0.8, 1.2, 1.6, 2.0, 2.6, 3.2]:
		var c: Climber = ClimberScript.new()
		c.climber_id = 800 + int(rate * 10)
		add_child(c)
		c.build(pk.world_of(Vector2(-42, 5.0)), world, null)
		c.driver = Drivers.ScriptDriver.new()
		pk.on_player(c, true)
		c.release_all()
		for l in c.limbs:
			l.regrip = 99.0
		var d: Drivers.ScriptDriver = c.driver
		for i in int(1.5 * hz):
			pk.tick(1.0 / hz)
			await get_tree().physics_frame
		var x0 := pk.local_of(c.centre_of_mass()).x
		var x_mid := x0
		for i in int(6.0 * hz):
			d.set_limb(1, true, Vector2.from_angle(-TAU * rate * float(i) / hz))
			pk.tick(1.0 / hz)
			await get_tree().physics_frame
			if i == int(3.0 * hz):
				x_mid = pk.local_of(c.centre_of_mass()).x
		var x1 := pk.local_of(c.centre_of_mass()).x
		print("SWIM %.1f turns a second: %.2f m/s once going (%.1f m in 6 s)" % [rate, (x1 - x_mid) / 3.0, x1 - x0])
		c.remove()
		for i in 3:
			pk.tick(1.0 / hz)
			await get_tree().physics_frame
	get_tree().quit()
