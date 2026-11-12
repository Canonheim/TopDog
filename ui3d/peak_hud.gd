class_name PeakHud
extends Node3D
## THE PEAK'S HUD: the solo climb's screens (docs/peak/PEAK_DESIGN.md §9, §10;
## docs/peak/PARTS.md "The Second Director"). Parker 11-11: "The goal of the solo mode
## is to scale this massive mountain ... It will be a rage game so if you fall at
## certain points you can lose a lot of progress."
##
## altimeter  bottom left: your height above the trailhead on four rolling drums, and a
##            cardboard cut-out of the Peak with your mask climbing its trail. The trail
##            turns gold up to your best height, where a pennant stands.
## area card  entering an area: its name slams in at the top on the title card, holds
##            3 s and flies out.
## milestone  every new best 100 m: a gold seal pops by the pennant with a puff of paper.
## the fall   after a fall of 15 m or more the altimeter shudders, stars circle your
##            mask, and it prints a small receipt: how far, and one dry line. The receipt
##            then falls off the screen too.
## pause      a slate on the right: TIME, FALLS, BEST.
## summit     the ending: TOP DOG, the plates, confetti, then PRESS ANY BUTTON; a press
##            sends `summit_closed`.
##
## Everything is unshaded (the mountain's caves are dark; the HUD never is) and hangs
## 1.25 m from the lens at the match HUD's on-screen size, in front of the mountain's
## near card layers. The root is in LuchaUI.UI_ROOT and anchors by lucha.virtual_half_w
## / _h, so narrow windows shrink it with the rest.
##
## Kit pieces taken by name when they land (Top Dog Kit): peak_altimeter,
## peak_summit_card. Painted-card stand-ins until then.

## The summit card was closed by a press.
signal summit_closed

const NEAR := 1.25  # metres from the lens
const TOP_M := 1000.0
const AREAS := 11
const FELL_MIN := 15.0

const KRAFT := Color("#B8895A")
const KRAFT_DARK := Color("#8A6238")
const NAVY := Color("#26124A")
const PAPER := Color("#F4E9CF")
const ROCK := Color("#5B78B8")
const ROCK_LIT := Color("#7C97D0")
const ROCK_DARK := Color("#3F5590")
const SNOW := Color("#FFF7E8")
const TRAIL_DIM := Color("#2B3A66")
const PAPEL := [Color("#E0287A"), Color("#1FB8AE"), Color("#FFC928"), Color("#7CC83A"), Color("#8A3FC0"), Color("#F28A1E")]

# ---- the altimeter's layout, in its own units (origin: its bottom-left corner) ----
const ALT_SCALE := 0.9
const ALT_MARGIN := Vector2(0.28, 0.2)
const MOUNTAIN := [Vector2(0.0, 0.0), Vector2(0.22, 0.40), Vector2(0.36, 0.58), Vector2(0.50, 0.98),
	Vector2(0.66, 1.36), Vector2(0.78, 1.74), Vector2(0.90, 2.15), Vector2(1.02, 1.86), Vector2(1.12, 1.52),
	Vector2(1.26, 1.36), Vector2(1.36, 1.05), Vector2(1.44, 0.86), Vector2(1.56, 1.50), Vector2(1.66, 1.02),
	Vector2(1.82, 0.50), Vector2(2.0, 0.0)]
const MOUNTAIN_LIT := [Vector2(0.90, 2.15), Vector2(1.02, 1.86), Vector2(1.12, 1.52), Vector2(1.26, 1.36),
	Vector2(1.36, 1.05), Vector2(1.44, 0.86), Vector2(1.25, 0.55), Vector2(1.02, 1.0), Vector2(0.96, 1.55)]
const MOUNTAIN_SNOW := [Vector2(0.70, 1.55), Vector2(0.78, 1.74), Vector2(0.90, 2.15), Vector2(1.02, 1.86),
	Vector2(1.10, 1.58), Vector2(1.01, 1.68), Vector2(0.92, 1.54), Vector2(0.82, 1.67)]
const MOUNTAIN_FANG := [Vector2(1.56, 1.50), Vector2(1.66, 1.02), Vector2(1.82, 0.50), Vector2(2.0, 0.0),
	Vector2(1.62, 0.0), Vector2(1.52, 0.70)]
const SUMMIT_AT := Vector2(0.90, 2.15)
## The trail: [share of 1,000 m, x, y]. It walks the real route: in at the foot, west
## through the caves, back east to the cliffs, up the cableway side to the bell.
const TRAIL := [[0.0, 1.72, 0.07], [0.10, 1.30, 0.24], [0.27, 0.68, 0.58], [0.48, 0.98, 1.03],
	[0.58, 1.18, 1.25], [0.78, 0.90, 1.68], [0.90, 0.87, 1.93], [1.0, 0.90, 2.10]]
const ODO_S := 1.25  # the kit's hud_odometer case (1.9 x 0.72) as the drum box
const CASE_AT := Vector3(2.92, 0.47, 0.0)
const CASE_TOP := 0.92
const DIGIT_STEP := TAU / 10.0
const TICKET_W := 2.25
const TICKET_H := 0.86
const TICKET_HOLD := 4.6

## The receipt's one dry line, by how far you fell. {b}: the fall in burros (1.5 m
## each, stacked); {l}: in luchadors (1.8 m).
const FELL_LINES := [
	[40.0, ["NOTED.", "A SMALL ONE.", "THE MOUNTAIN SAW THAT.", "{l} LUCHADORS TALL.", "IT HAPPENS."]],
	[120.0, ["THAT ONE COUNTED.", "THE SCENIC ROUTE.", "{b} BURROS, STACKED.", "YOU KNOW THIS PART.", "A FAIR DISTANCE."]],
	[350.0, ["THE RIVER SAYS HELLO.", "THE VIEW WAS NICE, THOUGH.", "{b} BURROS. WE COUNTED.", "THE MOUNTAIN KEEPS THE CHANGE.", "WELL. THERE IT GOES."]],
	[800.0, ["THE DONKEY HEARD.", "TAKE A MOMENT.", "{l} LUCHADORS, END TO END.", "WE'LL SAY NO MORE.", "A LOT OF MOUNTAIN, THAT."]],
	[INF, ["ALL OF IT, THEN.", "THE BELL WILL WAIT.", "THE WHOLE TOWN FELT THAT.", "FROM THE TOP, AS THEY SAY."]],
]

var lucha: LuchaUI
## What the HUD shows now (tests read these).
var shown_m := 0.0
var best_m := 0.0
var area_up := false
var ticket_up := false
var ticket_text := ""
var summit_up := false
var paused := false
var longest_fall := 0.0

var _near: Node3D
var _mats := {}
var _atlas_mats := {}
# the altimeter
var _alt: Node3D
var _drums: Array = []
var _minus: Node3D
var _marker: Node3D
var _pennant: Node3D
var _dots: Array = []  # [MeshInstance3D, share]
var _dots_gold := -1
var _target_m := 0.0
var _have_alt := false
var _shake_t := 99.0
var _shake_amp := 0.0
var _stars: Node3D
var _stars_t := 0.0
# the receipt
var _ticket: Node3D
var _ticket_words: Node3D
var _ticket_rise := 0.0
var _ticket_tw: Tween
var _ticket_drop := Vector3.ZERO
var _line_i := {}
# the area card
var _area: Node3D
var _area_off := 4.0
var _area_tw: Tween
# the seal
var _seal: Node3D
var _seal_tw: Tween
# the pause slate
var _pause: Node3D
var _pause_in := 0.0
var _pause_tw: Tween
var _pause_rows := {}
var _pause_key := ""
# the summit
var _summit: Node3D
var _summit_press: AnyPress
var _summit_tw: Tween
var _summit_off := 0.0
var _t := 0.0


## Hung on the camera like the match HUD (in the UI_ROOT group).
static func make(p_lucha: LuchaUI) -> PeakHud:
	var h := PeakHud.new()
	h.lucha = p_lucha
	h.name = "PeakHud"
	h.add_to_group(LuchaUI.UI_ROOT)
	h.position = Vector3(0, 0, -LuchaUI.MENU_DIST)
	h.scale = Vector3.ONE * LuchaUI.UI_SCALE
	p_lucha.cam.add_child(h)
	return h


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_near = Node3D.new()
	_near.name = "Near"
	add_child(_near)
	_build_altimeter()
	_build_ticket()
	_area = Node3D.new()
	_area.name = "AreaCard"
	_area.visible = false
	_near.add_child(_area)
	_seal = Node3D.new()
	_seal.name = "Seal"
	_seal.visible = false
	_alt.add_child(_seal)
	_build_pause()
	_summit = Node3D.new()
	_summit.name = "Summit"
	_summit.visible = false
	_near.add_child(_summit)
	_place()


# ================================================================ the interface

## Every frame: your height above the trailhead, and your best ever.
func set_altitude(metres: float, best: float) -> void:
	_target_m = metres
	if not _have_alt:
		_have_alt = true
		shown_m = metres  # the first reading lands at once (no roll up from zero)
	if absf(best - best_m) > 0.01:
		best_m = best
		_move_pennant()


## Entering an area: its name slams in, holds 3 s, leaves. `number` 0 is the trailhead.
func show_area(area_name: String, number: int) -> void:
	for ch in _area.get_children():
		ch.queue_free()
	var card := _kit("hud_banner")
	var s := 2.0
	if card != null:
		card.scale = Vector3.ONE * s
		_area.add_child(card)
		var words := LuchaKit.fit_words(area_name.to_upper(), 2.95 * s, 0.19 * s, LuchaKit.RED, LuchaKit.INK)
		LuchaKit.center_digits(words)
		words.position = Vector3(0, 0, 0.07 * s + 0.02)
		_area.add_child(words)
	else:
		_area.add_child(_card_rect(7.4, 0.9, LuchaKit.RED))
		var words := LuchaKit.fit_words(area_name.to_upper(), 6.8, 0.42, LuchaKit.CREAM, LuchaKit.INK)
		LuchaKit.center_digits(words)
		words.position = Vector3(0, 0, 0.06)
		_area.add_child(words)
	# The chip under it: which area of the eleven.
	var chip_s := "THE TRAILHEAD" if number <= 0 else ("THE SUMMIT" if number >= AREAS else "AREA %d OF %d" % [number, AREAS])
	var chip := Node3D.new()
	chip.position = Vector3(0, -0.98, 0.04)
	chip.add_child(_card_rect(2.3, 0.36, NAVY))
	var cw := LuchaKit.fit_words(chip_s, 2.0, 0.19, LuchaKit.CREAM, LuchaKit.INK)
	LuchaKit.center_digits(cw)
	cw.position = Vector3(0, 0, 0.05)
	chip.add_child(cw)
	_area.add_child(chip)
	LuchaUI.no_shadows(_area)
	_area.visible = true
	_area.rotation.z = randf_range(-0.05, 0.05)
	area_up = true
	_area_off = 3.2
	if _area_tw != null and _area_tw.is_valid():
		_area_tw.kill()
	_area_tw = _tw()
	_area_tw.tween_property(self, "_area_off", 0.0, 0.34).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_area_tw.tween_property(_area, "scale", Vector3(1.06, 0.92, 1.0), 0.06)
	_area_tw.tween_property(_area, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_area_tw.tween_interval(3.0)
	_area_tw.tween_property(self, "_area_off", 3.4, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_area_tw.tween_callback(func() -> void:
		_area.visible = false
		area_up = false)


## Every new best 100 m: a gold seal by the pennant and a puff of paper.
func milestone(metres: int) -> void:
	if summit_up:
		return
	for ch in _seal.get_children():
		ch.queue_free()
	var star := PackedVector2Array()
	for i in 32:
		var a := TAU * i / 32.0
		star.append(Vector2(cos(a), sin(a)) * (0.5 if i % 2 == 0 else 0.42))
	_seal.add_child(_prism(star, 0.04, LuchaKit.GOLD_DARK, Vector3(0.02, -0.03, -0.02)))
	_seal.add_child(_prism(star, 0.04, LuchaKit.GOLD))
	_seal.add_child(_disc(0.36, PAPER, Vector3(0, 0, 0.03)))
	var tag := LuchaKit.fit_words("NEW BEST", 0.5, 0.1, LuchaKit.INK, PAPER)
	tag.position = Vector3(0, 0.17, 0.06)
	_seal.add_child(tag)
	var num := LuchaKit.fit_words("%d m" % metres, 0.6, 0.24, LuchaKit.RED, LuchaKit.INK)
	LuchaKit.center_digits(num)
	num.position = Vector3(0, -0.06, 0.06)
	_seal.add_child(num)
	LuchaUI.no_shadows(_seal)
	var at := _trail_at(clampf(float(metres) / TOP_M, 0.0, 1.0))
	_seal.position = Vector3(clampf(at.x + 0.85, 0.7, 3.2), clampf(at.y + 0.6, 1.0, 2.4), 0.5)
	_seal.visible = true
	_seal.scale = Vector3.ONE * 0.01
	_seal.rotation.z = -0.5
	if _seal_tw != null and _seal_tw.is_valid():
		_seal_tw.kill()
	_seal_tw = _tw()
	_seal_tw.set_parallel(true)
	_seal_tw.tween_property(_seal, "scale", Vector3.ONE * 1.25, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_seal_tw.tween_property(_seal, "rotation:z", 0.12, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_seal_tw.chain().tween_interval(2.0)
	_seal_tw.chain().tween_property(_seal, "scale", Vector3.ONE * 0.01, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_seal_tw.chain().tween_callback(func() -> void: _seal.visible = false)
	_puff(_seal.position)
	if _pennant != null:
		_pennant.scale = Vector3.ONE * 1.9
		_tw().tween_property(_pennant, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


## After a fall of 15 m or more: the number, briefly, and it hurts.
func fell(metres: float) -> void:
	if metres < FELL_MIN or summit_up:
		return
	var record := metres > longest_fall and metres >= 60.0 and longest_fall > 0.0
	longest_fall = maxf(longest_fall, metres)
	_shake_t = 0.0
	_shake_amp = clampf(0.5 + metres / 250.0, 0.6, 2.4)
	_stars_t = clampf(1.2 + metres / 150.0, 1.4, 5.0)
	_print_ticket(metres, record)


## The ending: TOP DOG, the plates, confetti, then it waits for a press.
## `best_s` is the best summit time so far (0 or less: this is the first).
func summit(time_s: float, falls: int, best_s: float) -> void:
	_drop_ticket()
	_seal.visible = false
	_area.visible = false
	area_up = false
	for ch in _summit.get_children():
		ch.queue_free()
	_summit_press = null
	summit_up = true
	_alt.visible = false
	var new_best := best_s <= 0.0 or time_s <= best_s + 0.05
	var best_shown := time_s if new_best else best_s
	var card := _build_summit_card(time_s, falls, best_shown, new_best, best_s <= 0.0)
	_summit.add_child(card)
	LuchaUI.no_shadows(_summit)
	_summit.visible = true
	_summit_off = 9.0
	_summit.rotation.z = 0.06
	if _summit_tw != null and _summit_tw.is_valid():
		_summit_tw.kill()
	_summit_tw = _tw()
	_summit_tw.tween_property(self, "_summit_off", 0.0, 0.55).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_summit_tw.parallel().tween_property(_summit, "rotation:z", 0.0, 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_summit_tw.tween_callback(_confetti)
	# The plates turn up one at a time, then the stamp, then the prompt.
	var k := 0
	for row in card.get_meta("rows"):
		var r := row as Node3D
		r.scale = Vector3(1.0, 0.01, 1.0)
		r.visible = false
		_summit_tw.tween_callback(func() -> void: r.visible = true)
		_summit_tw.tween_property(r, "scale", Vector3.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_summit_tw.tween_interval(0.16)
		k += 1
	var stamp: Node3D = card.get_meta("stamp") if card.has_meta("stamp") else null
	if stamp != null:
		stamp.visible = false
		_summit_tw.tween_callback(func() -> void:
			stamp.visible = true
			stamp.scale = Vector3.ONE * 2.6)
		_summit_tw.tween_property(stamp, "scale", Vector3.ONE, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_summit_tw.tween_callback(_confetti)
	_summit_tw.tween_interval(0.7)
	var prompt: Node3D = card.get_meta("prompt")
	prompt.visible = false
	_summit_tw.tween_callback(func() -> void:
		prompt.visible = true
		_confetti()
		_summit_press = AnyPress.new()
		_summit_press.delay = 0.3
		_summit_press.pressed.connect(close_summit)
		add_child(_summit_press))


## Close the summit card (the press does this; the game may too).
func close_summit() -> void:
	if not summit_up:
		return
	summit_up = false
	if _summit_press != null:
		_summit_press.queue_free()
		_summit_press = null
	if _summit_tw != null and _summit_tw.is_valid():
		_summit_tw.kill()
	_summit_tw = _tw()
	_summit_tw.tween_property(self, "_summit_off", 9.5, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_summit_tw.tween_callback(func() -> void:
		_summit.visible = false
		_alt.visible = true)
	summit_closed.emit()


## The pause slate: the clock, the falls, the best height. Call with on = false to put
## it away. Safe to call every frame while paused.
func set_paused(on: bool, time_s: float, falls: int, p_best_m: float) -> void:
	if on:
		var key := "%d|%d|%d" % [int(time_s), falls, int(round(p_best_m))]
		if key != _pause_key:
			_pause_key = key
			_set_row(_pause_rows.time, clock(time_s, false))
			_set_row(_pause_rows.falls, str(falls))
			_set_row(_pause_rows.best, "%d m" % int(round(p_best_m)))
	if on == paused:
		return
	paused = on
	if _pause_tw != null and _pause_tw.is_valid():
		_pause_tw.kill()
	_pause_tw = _tw()
	if on:
		_pause.visible = true
		_pause_tw.tween_property(self, "_pause_in", 1.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		_pause_tw.tween_property(self, "_pause_in", 0.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		_pause_tw.tween_callback(func() -> void: _pause.visible = false)


## A clock: 1:02:07 past the hour; under it 12:34, or 12:34.5 with `tenths`.
static func clock(seconds: float, tenths := true) -> String:
	var s := maxf(seconds, 0.0)
	var h := int(s / 3600.0)
	var m := int(fmod(s, 3600.0) / 60.0)
	var sec := fmod(s, 60.0)
	if h > 0:
		return "%d:%02d:%02d" % [h, m, int(sec)]
	if tenths:
		return "%d:%04.1f" % [m, floorf(sec * 10.0) / 10.0]
	return "%d:%02d" % [m, int(sec)]


## The four drums' turns (0..10 each, left to right) for a height: the right drum turns
## with the metres; each drum to its left steps on as the one beside it passes 9.
static func drum_values(metres: float) -> Array:
	var x := clampf(absf(metres), 0.0, 9999.0)
	var out: Array = [0.0, 0.0, 0.0, 0.0]
	out[3] = fmod(x, 10.0)
	var lower: float = out[3]
	for i in [2, 1, 0]:
		var place := pow(10.0, 3 - i)
		var v := fmod(floorf(x / place), 10.0) + clampf(lower - 9.0, 0.0, 1.0)
		out[i] = v
		lower = v
	return out


## The receipt's dry line for a fall (the lines rotate, so none repeats back to back).
func fell_line(metres: float) -> String:
	for tier in FELL_LINES.size():
		if metres < float(FELL_LINES[tier][0]):
			var pool: Array = FELL_LINES[tier][1]
			var i: int = _line_i.get(tier, 0)
			_line_i[tier] = i + 1
			var line: String = pool[i % pool.size()]
			return line.replace("{b}", str(int(round(metres / 1.5)))).replace("{l}", str(int(round(metres / 1.8))))
	return ""


# ================================================================ the frame

func _process(delta: float) -> void:
	_t += delta
	_place()
	# The drums ease to the height (in a long fall they spin down).
	shown_m = lerpf(shown_m, _target_m, 1.0 - exp(-delta * 10.0))
	if absf(shown_m - _target_m) < 0.02:
		shown_m = _target_m
	var vals := drum_values(shown_m)
	for i in _drums.size():
		(_drums[i] as Node3D).rotation.x = -float(vals[i]) * DIGIT_STEP
	if _minus != null:
		_minus.visible = shown_m < -0.5
	var at := _trail_at(clampf(shown_m / TOP_M, -0.04, 1.0))
	_marker.position = Vector3(at.x, at.y, 0.16)
	_marker.rotation.z = sin(_t * 2.2) * 0.08
	# The shudder after a fall, and the stars round your mask.
	_shake_t += delta
	var sh := _shake_amp * exp(-_shake_t * 6.0)
	if sh > 0.005:
		_alt.position += Vector3(sin(_shake_t * 47.0), cos(_shake_t * 38.0), 0) * sh * 0.07
		_alt.rotation.z = sin(_shake_t * 40.0) * sh * 0.03
	else:
		_alt.rotation.z = 0.0
	_stars_t = maxf(0.0, _stars_t - delta)
	_stars.visible = _stars_t > 0.0
	if _stars.visible:
		_stars.position = _marker.position + Vector3(0, 0.22, 0.06)
		var k := 0
		for st in _stars.get_children():
			var a := _t * 5.0 + k * TAU / 3.0
			(st as Node3D).position = Vector3(cos(a) * 0.24, sin(a) * 0.07, sin(a) * 0.02)
			(st as Node3D).rotation.z = _t * 3.0 + k
			(st as Node3D).scale = Vector3.ONE * clampf(_stars_t * 2.0, 0.0, 1.0)
			k += 1
	if _pennant != null:
		_pennant.rotation.z = sin(_t * 3.1) * 0.06


## Where everything sits this frame: 1.25 m from the lens at the HUD's on-screen size,
## anchored to the screen's edges (the virtual ones in a narrow window).
func _place() -> void:
	var s := maxf(scale.x, 0.0001)
	_near.position = Vector3(0, 0, (LuchaUI.MENU_DIST - NEAR) / s)
	_near.scale = Vector3.ONE * (NEAR / LuchaUI.MENU_DIST)
	var hw := 6.79
	var hh := 3.82
	if lucha != null:
		hw = lucha.virtual_half_w
		hh = lucha.virtual_half_h
	_alt.position = Vector3(-hw + ALT_MARGIN.x, -hh + ALT_MARGIN.y, 0)
	_ticket.position = Vector3(CASE_AT.x, CASE_TOP - TICKET_H * 0.5 + TICKET_H * _ticket_rise, -0.2) + _ticket_drop
	_area.position = Vector3(0, hh - 0.95 + _area_off, 0.2)
	_pause.position = Vector3(hw - 0.4 - 1.9 + (1.0 - _pause_in) * 5.0, 0.35, 0.1)
	_summit.position = Vector3(0, 0.25 + _summit_off, 0.3)


# ================================================================ the altimeter

func _build_altimeter() -> void:
	_alt = Node3D.new()
	_alt.name = "Altimeter"
	_alt.scale = Vector3.ONE * ALT_SCALE
	_near.add_child(_alt)
	# The Peak, a painted card with a kraft edge.
	var peak := Node3D.new()
	peak.name = "Peak"
	peak.position = Vector3(0, 0, -0.12)
	_alt.add_child(peak)
	var outline := PackedVector2Array(MOUNTAIN)
	var grown := Geometry2D.offset_polygon(outline, 0.05)
	if not grown.is_empty():
		peak.add_child(_prism(grown[0], 0.05, KRAFT, Vector3(0, 0, -0.03)))
	peak.add_child(_prism(outline, 0.05, ROCK))
	peak.add_child(_prism(PackedVector2Array(MOUNTAIN_LIT), 0.02, ROCK_LIT, Vector3(0, 0, 0.03)))
	peak.add_child(_prism(PackedVector2Array(MOUNTAIN_SNOW), 0.02, SNOW, Vector3(0, 0, 0.045)))
	# The fang's far side in shadow, and the cable across to it.
	peak.add_child(_prism(PackedVector2Array(MOUNTAIN_FANG), 0.02, ROCK_DARK, Vector3(0, 0, 0.03)))
	var cable := _box(Vector3(0.34, 0.018, 0.01), KRAFT_DARK, Vector3(1.41, 1.43, 0.06))
	cable.rotation.z = 0.44
	peak.add_child(cable)
	# The trail's dots, gold up to your best.
	var steps := 22
	for i in steps + 1:
		var share := float(i) / steps
		var at := _trail_at(share)
		var d := _disc(0.032, TRAIL_DIM, Vector3(at.x, at.y, 0.075))
		peak.add_child(d)
		_dots.append([d, share])
	# The bell at the top.
	peak.add_child(_box(Vector3(0.02, 0.1, 0.01), KRAFT_DARK, Vector3(SUMMIT_AT.x, SUMMIT_AT.y + 0.05, 0.07)))
	peak.add_child(_disc(0.06, LuchaKit.GOLD, Vector3(SUMMIT_AT.x, SUMMIT_AT.y + 0.12, 0.075)))
	# Your best: a pennant on a pin.
	_pennant = Node3D.new()
	_pennant.add_child(_box(Vector3(0.024, 0.32, 0.012), KRAFT_DARK, Vector3(0, 0.16, 0)))
	_pennant.add_child(_prism(PackedVector2Array([Vector2(0.0, 0.32), Vector2(0.27, 0.245), Vector2(0.0, 0.17)]), 0.012, LuchaKit.RED, Vector3(0.012, 0, 0)))
	_pennant.visible = false
	_alt.add_child(_pennant)
	# You: a luchador's mask.
	_marker = Node3D.new()
	var mask := _kit("mask_icon", {"mask_hood": LuchaKit.RED})
	if mask != null:
		mask.scale = Vector3.ONE * 0.44
		_marker.add_child(mask)
	else:
		_marker.add_child(_disc(0.11, LuchaKit.GOLD, Vector3.ZERO))
		_marker.add_child(_disc(0.085, LuchaKit.RED, Vector3(0, 0, 0.012)))
	_alt.add_child(_marker)
	_stars = Node3D.new()
	_stars.visible = false
	for i in 3:
		var star := PackedVector2Array()
		for j in 10:
			var a := TAU * j / 10.0 + PI * 0.5
			star.append(Vector2(cos(a), sin(a)) * (0.062 if j % 2 == 0 else 0.027))
		_stars.add_child(_prism(star, 0.01, LuchaKit.GOLD))
	_alt.add_child(_stars)
	# The drums: the kit's odometer case, four of 0-9, reading whole metres.
	var box := _kit("hud_odometer")
	var wheels: Array = []
	if box != null:
		for n in box.find_children("odo_*", "Node3D", true, false):
			var nm := String(n.name)
			if n is VehicleWheel3D or nm.begins_with("odo_drum_") or nm.begins_with("odo_wheel_"):
				wheels.append(n)
		wheels.sort_custom(func(a, b): return (a as Node3D).position.x < (b as Node3D).position.x)
		var point := box.find_child("odo_point", true, false) as Node3D
		if point != null:
			point.visible = false
	if box == null or wheels.size() < 4:
		box = _stand_in_drums()
		wheels = box.get_meta("wheels")
	box.scale = Vector3.ONE * ODO_S
	box.position = CASE_AT
	_alt.add_child(box)
	for w in wheels.slice(0, 4):
		_drums.append(_dress_drum(w as Node3D))
	# Below the trailhead (the mine's sump): a minus on the case's left rim.
	_minus = LuchaKit.text3d("−", 0.3 * ODO_S, LuchaKit.CREAM, 0.0, 2)
	_minus.position = CASE_AT + Vector3(-0.865 * ODO_S, 0.02, 0.33 * ODO_S)
	_minus.visible = false
	_alt.add_child(_minus)
	LuchaUI.no_shadows(_alt)


## A drum's digits: 0-9 round its rim, the next one waiting below. Returns the turning node.
func _dress_drum(wheel: Node3D) -> Node3D:
	var r: float = wheel.get_meta("radius", 0.24)
	var width: float = wheel.get_meta("width", 0.26)
	var spin := Node3D.new()
	spin.name = "digits"
	wheel.add_child(spin)
	# The drum's own mesh turns with its digits.
	for ch in wheel.get_children():
		if ch is MeshInstance3D:
			ch.reparent(spin, false)
	for k in 10:
		var a := -k * DIGIT_STEP
		var d := LuchaKit.text3d(str(k), minf(width * 0.8, r * 0.76), LuchaKit.CREAM, 0.0, 2)
		LuchaKit.center_digits(d)
		d.position = Vector3(0, r * sin(a), r * cos(a)) * 1.02
		d.rotation.x = -a
		spin.add_child(d)
	return spin


func _stand_in_drums() -> Node3D:
	var root := Node3D.new()
	root.add_child(_box(Vector3(1.9, 0.72, 0.5), Color("#5A2E14"), Vector3(0, 0, -0.05)))
	root.add_child(_box(Vector3(1.98, 0.8, 0.44), LuchaKit.GOLD, Vector3(0, 0, -0.1)))
	var wheels: Array = []
	for i in 4:
		var w := Node3D.new()
		w.position = Vector3(-0.65 + i * 0.34, 0, 0)
		var cm := CylinderMesh.new()
		cm.top_radius = 0.24
		cm.bottom_radius = 0.24
		cm.height = 0.26
		var mi := MeshInstance3D.new()
		mi.mesh = cm
		mi.rotation.z = PI * 0.5
		mi.material_override = _mat(Color("#3A1C0C"))
		w.add_child(mi)
		root.add_child(w)
		wheels.append(w)
	root.set_meta("wheels", wheels)
	return root


## A point on the trail, by share of the 1,000 m (under 0 it runs on below the foot).
func _trail_at(share: float) -> Vector2:
	for i in range(1, TRAIL.size()):
		if share <= float(TRAIL[i][0]) or i == TRAIL.size() - 1:
			var a: Array = TRAIL[i - 1]
			var b: Array = TRAIL[i]
			var k := (share - float(a[0])) / maxf(float(b[0]) - float(a[0]), 0.0001)
			return Vector2(lerpf(a[1], b[1], k), lerpf(a[2], b[2], k))
	return Vector2(TRAIL[0][1], TRAIL[0][2])


func _move_pennant() -> void:
	if _pennant == null:
		return
	_pennant.visible = best_m >= 1.0
	var at := _trail_at(clampf(best_m / TOP_M, 0.0, 1.0))
	_pennant.position = Vector3(at.x, at.y, 0.1)
	var gold := 0
	for d in _dots:
		if float(d[1]) * TOP_M <= best_m + 0.01:
			gold += 1
	if gold != _dots_gold:
		_dots_gold = gold
		for i in _dots.size():
			(_dots[i][0] as MeshInstance3D).material_override = _mat(LuchaKit.GOLD if i < gold else TRAIL_DIM)


# ================================================================ the receipt

func _build_ticket() -> void:
	_ticket = Node3D.new()
	_ticket.name = "Receipt"
	_ticket.visible = false
	_alt.add_child(_ticket)
	# Paper with torn (zigzag) ends.
	var pts := PackedVector2Array()
	var hw := TICKET_W * 0.5
	var hh := TICKET_H * 0.5
	var teeth := 14
	for i in teeth + 1:
		pts.append(Vector2(-hw + TICKET_W * i / teeth, hh - (0.0 if i % 2 == 0 else 0.035)))
	for i in teeth + 1:
		pts.append(Vector2(hw - TICKET_W * i / teeth, -hh + (0.0 if i % 2 == 0 else 0.035)))
	_ticket.add_child(_prism(pts, 0.012, KRAFT_DARK, Vector3(0.025, -0.03, -0.012)))
	_ticket.add_child(_prism(pts, 0.012, PAPER))
	_ticket_words = Node3D.new()
	_ticket_words.position = Vector3(0, 0, 0.012)
	_ticket.add_child(_ticket_words)


func _print_ticket(metres: float, record: bool) -> void:
	if _ticket_tw != null and _ticket_tw.is_valid():
		_ticket_tw.kill()
	for ch in _ticket_words.get_children():
		ch.queue_free()
	var number := "%d m" % int(round(metres))
	var line := fell_line(metres)
	ticket_text = "FELL %s %s" % [number, line]
	var head := LuchaKit.text3d("FELL", 0.115, LuchaKit.INK, 0.0, 2)
	head.position = Vector3(0, 0.305, 0)
	_ticket_words.add_child(head)
	var num := LuchaKit.fit_words(number, TICKET_W * 0.8, 0.33, LuchaKit.RED, LuchaKit.INK)
	LuchaKit.center_digits(num)
	num.position = Vector3(0, 0.075, 0)
	_ticket_words.add_child(num)
	# A dotted rule, then the dry line.
	for i in 23:
		_ticket_words.add_child(_box(Vector3(0.045, 0.012, 0.004), KRAFT_DARK, Vector3(-0.99 + i * 0.09, -0.15, 0)))
	var words := LuchaKit.fit_words(line, TICKET_W * 0.9, 0.135, LuchaKit.INK, PAPER)
	LuchaKit.center_digits(words)
	words.position = Vector3(0, -0.29, 0)
	_ticket_words.add_child(words)
	if record:
		# The rubber stamp: your longest yet.
		var stamp := Node3D.new()
		stamp.position = Vector3(0.72, 0.27, 0.01)
		stamp.rotation.z = -0.2
		stamp.add_child(_box(Vector3(0.86, 0.19, 0.004), PAPER, Vector3(0, 0, -0.004)))
		var sw := LuchaKit.text3d("LONGEST YET", 0.1, LuchaKit.MAGENTA, 0.0, 3)
		LuchaKit.center_digits(sw)
		stamp.add_child(sw)
		stamp.add_child(_frame(0.86, 0.19, 0.016, LuchaKit.MAGENTA))
		_ticket_words.add_child(stamp)
	LuchaUI.no_shadows(_ticket)
	_ticket.visible = true
	_ticket.rotation.z = 0.0
	_ticket_drop = Vector3.ZERO
	_ticket_rise = 0.0
	ticket_up = true
	# It prints in steps, like a till roll; holds; then tears off and falls too.
	_ticket_tw = _tw()
	_ticket_tw.tween_interval(0.35)
	var steps := 7
	for i in steps:
		_ticket_tw.tween_property(self, "_ticket_rise", float(i + 1) / steps, 0.05)
		_ticket_tw.tween_interval(0.04)
	_ticket_tw.tween_interval(TICKET_HOLD)
	_ticket_tw.tween_callback(_drop_ticket)


## The receipt tears off and falls out of the frame.
func _drop_ticket() -> void:
	if not ticket_up:
		return
	ticket_up = false
	if _ticket_tw != null and _ticket_tw.is_valid():
		_ticket_tw.kill()
	_ticket_tw = _tw()
	_ticket_drop = Vector3(0, 0, 0.8)  # in front of the case as it goes
	_ticket_tw.tween_property(self, "_ticket_drop", Vector3(0.05, 0.07, 0.8), 0.06)
	_ticket_tw.tween_property(self, "_ticket_drop", Vector3(0.7, -4.2, 0.8), 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_ticket_tw.parallel().tween_property(_ticket, "rotation:z", -0.9, 0.75)
	_ticket_tw.tween_callback(func() -> void: _ticket.visible = false)


# ================================================================ the plates (pause, summit)

## A plate: a navy label tile and a paper face for the value, on a kraft card.
func _row(label: String, w: float, h := 0.5) -> Node3D:
	var r := Node3D.new()
	var lw := w * 0.36
	r.add_child(_box(Vector3(w + 0.1, h + 0.1, 0.03), KRAFT, Vector3(0, 0, -0.01)))
	r.add_child(_box(Vector3(lw, h, 0.03), NAVY, Vector3(-w * 0.5 + lw * 0.5, 0, 0.01)))
	r.add_child(_box(Vector3(w - lw - 0.04, h, 0.03), PAPER, Vector3(lw * 0.5 + 0.02, 0, 0.01)))
	var lt := LuchaKit.fit_words(label, lw * 0.84, h * 0.46, LuchaKit.GOLD, LuchaKit.INK)
	LuchaKit.center_digits(lt)
	lt.position = Vector3(-w * 0.5 + lw * 0.5, 0, 0.035)
	r.add_child(lt)
	var val := Node3D.new()
	val.name = "value"
	val.position = Vector3(lw * 0.5 + 0.02, 0, 0.035)
	r.add_child(val)
	r.set_meta("value_w", (w - lw - 0.04) * 0.88)
	r.set_meta("value_h", h * 0.62)
	return r


func _set_row(r: Node3D, value: String, note := "") -> void:
	var val := r.get_node("value") as Node3D
	for ch in val.get_children():
		ch.queue_free()
	var vw: float = r.get_meta("value_w")
	var vh: float = r.get_meta("value_h")
	if note == "":
		var t := LuchaKit.fit_words(value, vw * 0.8, vh, LuchaKit.RED, LuchaKit.INK)
		LuchaKit.center_digits(t)
		val.add_child(t)
	else:
		# The value, and a small dry note beside it.
		var t := LuchaKit.fit_words(value, vw * 0.42, vh, LuchaKit.RED, LuchaKit.INK)
		LuchaKit.center_digits(t)
		t.position = Vector3(-vw * 0.27, 0, 0)
		val.add_child(t)
		if note.strip_edges() != "":
			var n := LuchaKit.fit_words(note, vw * 0.5, vh * 0.4, LuchaKit.INK, PAPER)
			LuchaKit.center_digits(n)
			n.position = Vector3(vw * 0.24, 0, 0)
			val.add_child(n)
	LuchaUI.no_shadows(val)


func _build_pause() -> void:
	_pause = Node3D.new()
	_pause.name = "PauseSlate"
	_pause.visible = false
	_near.add_child(_pause)
	var w := 3.5
	_pause.add_child(_card_rect(w + 0.3, 2.75, KRAFT_DARK, Vector3(0, -0.1, -0.06), false))
	var head := LuchaKit.fit_words("THE PEAK OF DEGAYO", w * 0.92, 0.2, LuchaKit.CREAM, LuchaKit.INK)
	LuchaKit.center_digits(head)
	head.position = Vector3(0, 0.98, 0)
	_pause.add_child(head)
	var y := 0.42
	for id in ["time", "falls", "best"]:
		var r := _row({"time": "TIME", "falls": "FALLS", "best": "BEST"}[id], w)
		r.position = Vector3(0, y, 0)
		_pause.add_child(r)
		_pause_rows[id] = r
		y -= 0.68
	LuchaUI.no_shadows(_pause)


## The summit card. The kit's peak_summit_card when it lands; a lucha poster until then.
func _build_summit_card(time_s: float, falls: int, best_shown: float, new_best: bool, first: bool) -> Node3D:
	var card := Node3D.new()
	var w := 5.6
	var h := 5.5
	# The poster: kraft card, cream paper, a red sunburst behind the name.
	card.add_child(_card_rect(w, h, PAPER))
	var sun := Vector2(0, 1.55)
	var rect := PackedVector2Array([Vector2(-w * 0.5 + 0.12, -h * 0.5 + 0.12), Vector2(w * 0.5 - 0.12, -h * 0.5 + 0.12), Vector2(w * 0.5 - 0.12, h * 0.5 - 0.12), Vector2(-w * 0.5 + 0.12, h * 0.5 - 0.12)])
	var rays := 20
	for i in rays:
		if i % 2 == 1:
			continue
		var a0 := TAU * i / rays
		var a1 := TAU * (i + 1) / rays
		var wedge := PackedVector2Array([sun, sun + Vector2(cos(a0), sin(a0)) * 9.0, sun + Vector2(cos(a1), sin(a1)) * 9.0])
		for piece in Geometry2D.intersect_polygons(wedge, rect):
			card.add_child(_prism(piece, 0.004, Color("#F6D78C"), Vector3(0, 0, 0.022)))
	card.add_child(_frame(w - 0.24, h - 0.24, 0.05, LuchaKit.RED, Vector3(0, 0, 0.024)))
	# TOP DOG.
	var logo := _kit("title_logo")
	if logo != null:
		logo.scale = Vector3.ONE * 1.42
		logo.position = Vector3(0, 0.9, 0.05)
		card.add_child(logo)
	else:
		var td := LuchaKit.fit_words("TOP DOG", w * 0.8, 1.0, LuchaKit.RED, LuchaKit.INK)
		td.position = Vector3(0, 1.6, 0.05)
		card.add_child(td)
	var sub := LuchaKit.fit_words("THE PEAK OF DEGAYO", w * 0.62, 0.2, LuchaKit.INK, PAPER)
	LuchaKit.center_digits(sub)
	sub.position = Vector3(0, 0.55, 0.05)
	card.add_child(sub)
	# The plates.
	var rows: Array = []
	var y := -0.12
	var data := [["TIME", clock(time_s), ""], ["FALLS", str(falls), falls_note(falls)], ["BEST", clock(best_shown), "FIRST ASCENT" if first else (" " if new_best else "")]]
	for d in data:
		var r := _row(d[0], w - 0.9, 0.56)
		r.position = Vector3(0, y, 0.05)
		_set_row(r, d[1], d[2])
		card.add_child(r)
		rows.append(r)
		y -= 0.76
	card.set_meta("rows", rows)
	# The stamp.
	var stamp: Node3D = null
	if new_best and not first:
		stamp = Node3D.new()
		stamp.position = Vector3(1.5, -1.66, 0.12)  # the BEST plate's note space
		stamp.rotation.z = -0.14
		stamp.add_child(_box(Vector3(1.3, 0.38, 0.01), PAPER, Vector3(0, 0, -0.01)))
		stamp.add_child(_frame(1.3, 0.38, 0.032, LuchaKit.MAGENTA))
		var sw := LuchaKit.text3d("NEW BEST!", 0.2, LuchaKit.MAGENTA, 0.0, 3)
		LuchaKit.center_digits(sw)
		sw.position = Vector3(0, 0, 0.01)
		stamp.add_child(sw)
		card.add_child(stamp)
	if stamp != null:
		card.set_meta("stamp", stamp)
	# The prompt.
	var prompt := Node3D.new()
	prompt.position = Vector3(0, -h * 0.5 - 0.42, 0.05)
	var ribbon := _kit("status_ribbon")
	if ribbon != null:
		ribbon.scale = Vector3.ONE * 1.5
		prompt.add_child(ribbon)
	else:
		prompt.add_child(_card_rect(4.4, 0.5, NAVY))
	var pw := LuchaKit.fit_words("PRESS ANY BUTTON", 3.5, 0.2, LuchaKit.INK, PAPER)
	LuchaKit.center_digits(pw)
	pw.position = Vector3(0, 0, 0.09)
	prompt.add_child(pw)
	card.add_child(prompt)
	card.set_meta("prompt", prompt)
	return card


## The falls plate's small note.
static func falls_note(falls: int) -> String:
	if falls <= 0:
		return "NOT ONE. SUSPICIOUS."
	if falls == 1:
		return "JUST THE ONE."
	if falls < 25:
		return "BARELY A SCRATCH."
	if falls < 100:
		return "A FEW."
	if falls < 300:
		return "IT ADDS UP."
	return "THE MOUNTAIN KEPT COUNT."


func _confetti() -> void:
	if lucha != null and lucha.has_method("confetti"):
		lucha.confetti(true)


# ================================================================ small makers

func _tw() -> Tween:
	var t := create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return t


## A flat colour that no light or fog touches (the caves are dark; the HUD is not).
func _mat(c: Color) -> StandardMaterial3D:
	var key := c.to_html(true)
	if not _mats.has(key):
		var m := StandardMaterial3D.new()
		m.albedo_color = c
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.disable_fog = true
		_mats[key] = m
	return _mats[key]


## A kit model in its atlas colours, unshaded (`tints`: part name -> colour for the
## near-white parts). Null until the model is in kit/models.
func _kit(model: String, tints := {}) -> Node3D:
	var n := LuchaKit.kit_model(model)
	if n == null:
		return null
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		var c: Color = tints.get(String(mi.name), Color.WHITE)
		var key := c.to_html(true)
		if not _atlas_mats.has(key):
			var m := StandardMaterial3D.new()
			m.albedo_texture = CelPass.ATLAS
			m.albedo_color = c
			m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			m.disable_fog = true
			_atlas_mats[key] = m
		(mi as MeshInstance3D).material_override = _atlas_mats[key]
	LuchaUI.no_shadows(n)
	return n


func _box(size: Vector3, c: Color, at := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = _mat(c)
	mi.position = at
	return mi


func _prism(pts: PackedVector2Array, depth: float, c: Color, at := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = LuchaKit._prism(pts, depth)
	mi.material_override = _mat(c)
	mi.position = at
	return mi


func _disc(r: float, c: Color, at := Vector3.ZERO) -> MeshInstance3D:
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	return _prism(pts, 0.01, c, at)


## A painted card: the colour on a kraft card that shows as its edge.
func _card_rect(w: float, h: float, c: Color, at := Vector3.ZERO, edge := true) -> Node3D:
	var n := Node3D.new()
	n.position = at
	if edge:
		n.add_child(_box(Vector3(w + 0.12, h + 0.12, 0.03), KRAFT, Vector3(0, 0, -0.012)))
	n.add_child(_box(Vector3(w, h, 0.03), c))
	return n


## A rectangle's outline, `t` thick.
func _frame(w: float, h: float, t: float, c: Color, at := Vector3.ZERO) -> Node3D:
	var n := Node3D.new()
	n.position = at
	for sy in [-1.0, 1.0]:
		n.add_child(_box(Vector3(w, t, 0.006), c, Vector3(0, sy * (h - t) * 0.5, 0)))
	for sx in [-1.0, 1.0]:
		n.add_child(_box(Vector3(t, h, 0.006), c, Vector3(sx * (w - t) * 0.5, 0, 0)))
	return n


## A puff of paper at a spot in the altimeter's space.
func _puff(at: Vector3) -> void:
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = 22
	p.lifetime = 1.3
	var qm := QuadMesh.new()
	qm.size = Vector2(0.07, 0.045)
	p.mesh = qm
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	p.material_override = m
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.17, 0.34, 0.5, 0.67, 0.84])
	grad.colors = PackedColorArray(PAPEL)
	grad.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	p.color_initial_ramp = grad
	p.direction = Vector3.UP
	p.spread = 70.0
	p.initial_velocity_min = 1.2
	p.initial_velocity_max = 2.6
	p.gravity = Vector3(0, -3.2, 0)
	p.angular_velocity_min = -400.0
	p.angular_velocity_max = 400.0
	p.angle_max = 360.0
	p.local_coords = true
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	_alt.add_child(p)
	p.position = at
	p.emitting = true
	p.finished.connect(p.queue_free)
