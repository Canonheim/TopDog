extends Node
## THE PEAK'S HUD, driven without the game (windowed): every PeakHud call in turn, over
## the plaza. -- --shots=DIR saves a frame of each state there (peak_*.png).
##   altimeter, area card (short and long names), milestone, the fall receipt (small,
##   long, a record, the whole mountain), pause, summit (first ascent, a new best, a
##   slower run), a narrow window, and the dark (the sun and ambient off).
var fails := 0
var shots := ""
var hud: PeakHud
var alt := 0.0
var best := 0.0
var closed := 0


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shots="):
			shots = a.get_slice("=", 1)
	_check("drums: 347.6 m reads 0 3 4 7.6", _near(PeakHud.drum_values(347.6), [0.0, 3.0, 4.0, 7.6]), PeakHud.drum_values(347.6))
	_check("drums: 999.5 m is half way to 1000 on every drum", _near(PeakHud.drum_values(999.5), [0.5, 9.5, 9.5, 9.5]), PeakHud.drum_values(999.5))
	_check("drums: 1000 m reads 1 0 0 0", _near(PeakHud.drum_values(1000.0), [1.0, 0.0, 0.0, 0.0]), PeakHud.drum_values(1000.0))
	_check("drums: -28 m (the sump) reads 0 0 2 8", _near(PeakHud.drum_values(-28.0), [0.0, 0.0, 2.0, 8.0]), PeakHud.drum_values(-28.0))
	_check("clock: 9667 s is 2:41:07", PeakHud.clock(9667.0) == "2:41:07", PeakHud.clock(9667.0))
	_check("clock: 754.56 s is 12:34.5", PeakHud.clock(754.56) == "12:34.5", PeakHud.clock(754.56))
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await _wait(1.2)
	main.lucha.title_attract = false
	main.lucha.show_screen("peak_probe")  # every menu closes; the plaza is the backdrop
	hud = PeakHud.make(main.lucha)
	hud.summit_closed.connect(func() -> void: closed += 1)
	_check("the HUD hangs on the camera in the UI_ROOT group", hud.get_parent() == main.cam and hud.is_in_group(LuchaUI.UI_ROOT))
	# ---- the altimeter
	alt = 0.0
	best = 0.0
	await _wait(0.4)
	await _shot("peak_01_trailhead")
	alt = 347.6
	best = 412.0
	await _wait(1.6)
	_check("the drums ease to the height", absf(hud.shown_m - 347.6) < 0.5, hud.shown_m)
	_check("the pennant stands at the best", hud._pennant.visible and absf(hud.best_m - 412.0) < 0.01)
	await _shot("peak_02_altimeter")
	alt = -28.0
	await _wait(1.6)
	_check("below the trailhead the minus shows", hud._minus.visible)
	await _shot("peak_03_sump")
	alt = 396.0
	await _wait(1.2)
	# ---- the area card
	hud.show_area("La Mina Vieja", 1)
	await _wait(0.9)
	_check("the area card is up", hud.area_up and hud._area.visible)
	await _shot("peak_04_area")
	await _wait(3.4)
	_check("...and has left after its 3 s", not hud.area_up)
	hud.show_area("El Templo del Primer Perro", 5)
	await _wait(0.9)
	await _shot("peak_05_area_long")
	hud.show_area("La Cumbre", 11)
	await _wait(0.9)
	await _shot("peak_06_area_summit")
	await _wait(3.4)
	# ---- a new best 100 m
	alt = 400.4
	best = 400.4
	hud.milestone(400)
	await _wait(0.7)
	_check("the milestone's seal is up", hud._seal.visible)
	await _shot("peak_07_milestone")
	await _wait(2.4)
	# ---- the falls
	alt = 612.0
	best = 612.0
	await _wait(1.0)
	_check("a 9 m slip prints nothing", _fell(9.0) == false)
	alt = 594.0
	hud.fell(18.4)
	await _wait(1.3)
	_check("an 18 m fall prints a receipt", hud.ticket_up and hud.ticket_text.begins_with("FELL 18 m"), hud.ticket_text)
	await _shot("peak_08_fell_small")
	alt = 282.0
	hud.fell(312.0)
	await _wait(0.25)
	await _shot("peak_09_fell_shudder")
	await _wait(1.1)
	_check("a 312 m fall prints over the last, stamped the longest yet", hud.ticket_up and hud.ticket_text.begins_with("FELL 312 m") and hud.longest_fall == 312.0, hud.ticket_text)
	await _shot("peak_10_fell_long")
	await _wait(5.6)
	_check("the receipt falls away by itself", not hud.ticket_up)
	alt = -28.0
	hud.fell(1028.0)
	await _wait(1.4)
	await _shot("peak_11_fell_everything")
	var seen := {}
	for i in 12:
		seen[hud.fell_line(200.0)] = true
	_check("the dry lines rotate (5 for a 200 m fall)", seen.size() == 5, seen.size())
	await _wait(1.0)
	# ---- pause
	alt = 282.0
	hud.set_paused(true, 5025.0, 37, 612.0)
	await _wait(0.6)
	_check("the pause slate is up", hud.paused and hud._pause.visible)
	await _shot("peak_12_pause")
	hud.set_paused(false, 5025.0, 37, 612.0)
	await _wait(0.5)
	_check("...and away", not hud._pause.visible)
	# ---- the dark (a cave: no sun, no ambient)
	var lights: Array = main.find_children("*", "DirectionalLight3D", true, false)
	var env: Environment = null
	for we in main.find_children("*", "WorldEnvironment", true, false):
		env = (we as WorldEnvironment).environment
	var amb := env.ambient_light_energy if env != null else 1.0
	for l in lights:
		(l as Node3D).visible = false
	if env != null:
		env.ambient_light_energy = 0.0
	hud.show_area("Las Aguas Negras", 2)
	hud.fell(64.0)
	await _wait(1.4)
	await _shot("peak_13_dark")
	for l in lights:
		(l as Node3D).visible = true
	if env != null:
		env.ambient_light_energy = amb
	await _wait(3.4)
	# ---- a narrow window
	var win := get_window()
	var was_mode := win.mode
	var was := win.size
	win.mode = Window.MODE_WINDOWED
	await _wait(0.3)
	win.size = Vector2i(1000, 900)
	await _wait(0.6)
	hud.show_area("El Jardín de Hongos", 4)
	hud.set_paused(true, 754.0, 3, 371.0)
	await _wait(1.0)
	await _shot("peak_14_narrow")
	var vs := get_viewport().get_visible_rect().size
	_check("the window is narrow for that frame", vs.x / vs.y < 1.3, vs)
	hud.set_paused(false, 754.0, 3, 371.0)
	win.size = was
	win.mode = was_mode
	await _wait(3.6)
	# ---- the summit
	alt = 1000.0
	best = 1000.0
	hud.summit(9667.0, 214, 0.0)
	await _wait(1.0)
	_check("the summit card is up and the altimeter away", hud.summit_up and hud._summit.visible and not hud._alt.visible)
	await _shot("peak_15_summit_landing")
	await _wait(3.2)
	await _shot("peak_16_summit_first")
	_key()
	await _wait(0.8)
	_check("a press closes it and says so", closed == 1 and not hud.summit_up, closed)
	_check("...and the altimeter is back", hud._alt.visible)
	hud.summit(7012.4, 0, 9667.0)
	await _wait(4.4)
	await _shot("peak_17_summit_new_best")
	_key()
	await _wait(0.8)
	hud.summit(2291.0, 1, 1840.5)
	await _wait(4.4)
	await _shot("peak_18_summit_slower")
	_key()
	await _wait(0.8)
	_check("each summit closed on its press", closed == 3, closed)
	print("PEAK HUD RESULT fails=", fails)
	get_tree().quit(fails)


func _process(_delta: float) -> void:
	if hud != null:
		hud.set_altitude(alt, best)


func _fell(m: float) -> bool:
	hud.fell(m)
	return hud.ticket_up


func _key() -> void:
	for down in [true, false]:
		var e := InputEventKey.new()
		e.keycode = KEY_F9
		e.physical_keycode = KEY_F9
		e.pressed = down
		Input.parse_input_event(e)


func _near(a: Array, b: Array, eps := 0.02) -> bool:
	for i in a.size():
		if absf(float(a[i]) - float(b[i])) > eps:
			return false
	return true


func _check(label: String, ok: bool, extra = "") -> void:
	print(("PASS  " if ok else "FAIL  ") + label + ("" if str(extra) == "" else "  [%s]" % str(extra)))
	if not ok:
		fails += 1


func _wait(s: float) -> void:
	await get_tree().create_timer(s).timeout


func _shot(n: String) -> void:
	if shots == "":
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(shots.path_join(n + ".png"))
