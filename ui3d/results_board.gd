class_name ResultsBoard
extends Menu3D
## THE RESULTS BOARD (Parker 11-11: "make all of that, including the buttons built into
## one UI thing over on the left of the screen ... a leaderboard with all the heights that
## people in the lobby made it to, one that auto scrolls. But the Top Dog's name should
## always be displayed at the top"). The UI creator's marquee (Top Dog Kit PARTS.md J):
## TOP DOG and the winner's plate pinned at the top, a six-slot roll of everyone else's
## best heights that steps round like a flip board when it doesn't fit, the tower's line
## as the loop's divider, and REMATCH! / BACK built into its footer.
##
## It is the results Menu3D: the two buttons are its items (pad focus, mouse, confirm as
## every belt), carried in the board's own swinging space.

const HANG_Y := 4.8  # the straps' line: the board swings about it
const LEFT_IN := 0.30 + 2.10  # its left rim 0.30 in from the screen's edge, half its width
const SLOTS := [0.90, 0.40, -0.10, -0.60, -1.10, -1.60]
const ROW_Z := 0.07
const HIDE_ABOVE := 1.40
const HIDE_BELOW := -2.10
const HOLD_S := 3.0
const STEP_EVERY := 0.70
const STEP_S := 0.22
const NAVY := Color("#26124A")
const OWN_ROW := Color("#FFE08A")
const WAIT_FACE := Color("#5A5470")
const WINNER_BACK := Color("#5A0A12")
## THE NAME FLIP (Parker 11-11: "after 4 seconds on the screen, the names section on the
## winner screen should flip like they do in the options menu, 360 degrees, and when it
## lands facing forward, it will show the person's steam username, then after another 4
## seconds, it will flip back"): PARTS.md J8.
const FLIP_EVERY := 4.0
const FLIP_S := 0.45
const FLIP_RIPPLE := 0.05
const FLIP_BUSY := 0.70  # the whole ripple: the roll waits it out

var lucha: Node = null  # LuchaUI (half_w, the camera numbers)
var _hang: Node3D  # the pivot on the straps' line
var _space: Node3D  # the board's own space (its centre), under the pivot
var _board: Node3D
var _roll: Node3D
var _rows: Array = []  # Node3D, ranks 2..N then the tower slat
var _medal: Node3D
var _crest: Node3D
var _letters: Node3D
var _bulbs: Array = []
var _more: Array = []
var _winner_words: Node3D = null
var _rematch_plate: Node3D
var _back_plate: Node3D
var _wait_glass: Node3D
var _rematch_words: Node3D = null
var _waiting := false
var _t := 0.0  # since the screen opened
var _rows_in_at := 1.0  # when the last row has flipped in
var roll_off := 0.0  # the loop's offset, in rows (tweened one step at a time)
var _roll_target := 0
var _next_step := INF
var _step_tween: Tween = null
var _bulb_t := 0.0
var _bulb_swap := false
var _glass_t := 0.0
var _tiles: Array = []  # {tile, words, game, steam, row (or null), winner}
var _next_flip := INF
var _show_steam := false
var _flip_until := 0.0


func _init(p_cam: Camera3D) -> void:
	super(p_cam)


func _ready() -> void:
	_hang = Node3D.new()
	_hang.name = "Hang"
	add_child(_hang)
	_space = Node3D.new()
	_space.position = Vector3(0, -HANG_Y, 0)
	_hang.add_child(_space)
	_board = LuchaKit.kit_model("results_board")
	if _board == null:
		_board = LuchaKit._plate(4.2, 6.65, LuchaKit.STRAP_BLUE)
		_board.position.y = -0.225
	_space.add_child(_board)
	_medal = _board.find_child("results_medal_1", true, false) as Node3D
	_crest = _board.find_child("results_crest", true, false) as Node3D
	_letters = _board.find_child("results_title_letters", true, false) as Node3D
	for nm in ["results_bulbs_a", "results_bulbs_b"]:
		var b := _board.find_child(nm, true, false)
		if b != null:
			_bulbs.append(b)
	for nm in ["results_more_up", "results_more_down"]:
		var m := _board.find_child(nm, true, false) as Node3D
		if m != null:
			m.set_meta("home", m.position)
			_more.append(m)
	_roll = Node3D.new()
	_roll.name = "Roll"
	_space.add_child(_roll)
	# The two buttons: Menu3D items, laid out in the board's space.
	_rematch_plate = _button_plate("results_rematch", 2.94, 0.69, "REMATCH!")
	_wait_glass = _rematch_plate.find_child("results_rematch_wait", true, false) as Node3D
	if _wait_glass != null:
		_wait_glass.visible = false
	_back_plate = _button_plate("results_back", 1.84, 0.44, "BACK")
	_back_plate.add_child(_words("BACK", 0.97, 0.19, LuchaKit.CREAM, LuchaKit.INK, Vector3(0, 0, 0.07)))
	super._ready()


## A footer plate as a Menu3D row: its focus ring is the mark (no cursor, no crest).
func _button_plate(stem: String, w: float, h: float, _word: String) -> Node3D:
	var root := Node3D.new()
	var k := LuchaKit.kit_model(stem)
	if k == null:
		k = LuchaKit._plate(w, h * 0.7, LuchaKit.RED if stem == "results_rematch" else LuchaKit.STRAP_BLUE)
	root.add_child(k)
	root.set_meta("width", w)
	root.set_meta("height", h)
	root.set_meta("stop_x", [0.0])
	root.set_meta("focus_nodes", LuchaKit._focus_rings(k, [stem + "_focus"]))
	return root


## Wire the buttons (lucha_ui gives the callbacks).
func set_buttons(rematch: Callable, back: Callable) -> void:
	var a := add_row(_rematch_plate, func(_s): _on_rematch(rematch))
	items[a].layout_position = Vector3(0, -2.37, 0.22)
	var b := add_row(_back_plate, func(_s): back.call())
	items[b].layout_position = Vector3(0, -3.11, 0.22)
	_layout()
	# Into the board's swinging space, so they hang with it.
	for i in [a, b]:
		var n: Node3D = items[i].node
		remove_child(n)
		_space.add_child(n)
	_layout()


func _on_rematch(cb: Callable) -> void:
	cb.call()
	if _waiting:
		# Only the host starts the next one: a shake says so (the game's own note follows).
		var n: Node3D = items[0].node
		var home: Vector3 = n.get_meta("home")
		var tw := create_tween()
		for k in 3:
			tw.tween_property(n, "position:x", home.x + 0.06, 0.042)
			tw.tween_property(n, "position:x", home.x - 0.06, 0.042)
		tw.tween_property(n, "position:x", home.x, 0.042)


# ---------------------------------------------------------------- words

## Words fitted to a face `w` wide by the font's own measure (never past max_size); a
## name that would go under `min_size` is cut with an ellipsis instead.
static func fitted(s: String, w: float, max_size: float, min_size := 0.0) -> Array:
	var probe := LuchaKit.text3d(s, 1.0, Color.WHITE)
	var f: Font = probe.font if probe.font != null else ThemeDB.fallback_font
	probe.free()
	var per := func(t: String) -> float: return f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 96).x / 96.0
	var size := minf(max_size, w / maxf(per.call(s), 0.001))
	if min_size > 0.0 and size < min_size:
		size = min_size
		while s.length() > 2 and per.call(s + "...") * size > w:
			s = s.left(-1).strip_edges()
		s += "..."
	return [s, size]


func _words(s: String, w: float, max_size: float, face: Color, back, at: Vector3, min_size := 0.0) -> Node3D:
	var fit := fitted(s, w, max_size, min_size)
	var n: Node3D
	if back == null:
		n = LuchaKit.text3d(str(fit[0]), float(fit[1]), face)
	else:
		n = LuchaKit.poster_text(str(fit[0]), float(fit[1]), face, back, 0.02)
	n.position = at
	return n


# ---------------------------------------------------------------- filling

## The board's words: the winner (or none: GAME OVER), everyone else in finishing order
## ({name, height, tint, own}), the tower's line, and whether this player only waits.
func fill(winner: Dictionary, others: Array, tower_l: String, tower_r: String, waiting: bool) -> void:
	for r in _rows:
		(r as Node3D).queue_free()
	_rows.clear()
	if _winner_words != null:
		_winner_words.queue_free()
	_winner_words = Node3D.new()
	_board.add_child(_winner_words)
	var has_winner := not winner.is_empty()
	var name_s: String = str(winner.get("name", "GAME OVER")) if has_winner else "GAME OVER"
	for d in _tiles:
		if d.winner and is_instance_valid(d.words):
			(d.words as Node3D).queue_free()  # (on the board's own tile: the rows go with their rows)
		if is_instance_valid(d.tile):
			(d.tile as Node3D).rotation.x = 0.0
	_tiles.clear()
	_show_steam = false
	var nm := _words(name_s, 2.53, 0.30, LuchaKit.GOLD, WINNER_BACK, Vector3(0.32, 1.97, 0.272), 0.16)
	nm.name = "WinnerName"
	_winner_words.add_child(nm)
	var wtile := _board.find_child("results_winner_face", true, false) as Node3D
	if wtile != null:
		_onto_tile(nm, wtile)
		_tiles.append({"tile": wtile, "words": nm, "game": name_s, "steam": str(winner.get("steam", "")) if has_winner else "", "row": null, "winner": true})
	if has_winner:
		_winner_words.add_child(_words(str(winner.get("height", "")), 1.27, 0.22, LuchaKit.CREAM, LuchaKit.INK, Vector3(0.32, 1.49, 0.265)))
		LuchaKit.tint_part(_board, "results_winner_tint", winner.get("tint", Color.WHITE))
	if _medal != null:
		_medal.visible = has_winner
	var wt := _board.find_child("results_winner_tint", true, false) as Node3D
	if wt != null:
		wt.visible = has_winner
	# The rows: ranks 2..N, then the tower slat.
	for i in others.size():
		_rows.append(_player_row(i + 2, others[i]))
	_rows.append(_tower_row(tower_l, tower_r))
	for r in _rows:
		_roll.add_child(r)
	for i in others.size():
		var row: Node3D = _rows[i]
		var tile := row.find_child("results_row_face", true, false) as Node3D
		var words: Node3D = row.get_meta("name_words")
		if tile != null:
			_onto_tile(words, tile)
			_tiles.append({"tile": tile, "words": words, "game": str(others[i].get("name", "")), "steam": str(others[i].get("steam", "")), "row": row, "winner": false})
	_next_flip = FLIP_EVERY if _tiles.any(func(d): return str(d.steam) != "") else INF
	_flip_until = 0.0
	roll_off = 0.0
	_roll_target = 0
	if _step_tween != null and _step_tween.is_valid():
		_step_tween.kill()
	# The entrance: the rows flip in from the top slot down, then the buttons pop.
	var shown := mini(_rows.size(), SLOTS.size())
	_rows_in_at = 0.80 + 0.07 * maxf(shown - 1, 0) + 0.20
	_next_step = _rows_in_at + HOLD_S if _scrolls() else INF
	for k in _rows.size():
		var r: Node3D = _rows[k]
		r.rotation.x = PI * 0.5
		if k < shown:
			var tw := create_tween()
			tw.tween_interval(0.80 + 0.07 * k)
			tw.tween_property(r, "rotation:x", 0.0, 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			r.rotation.x = 0.0
	_place_rows()
	for m in _more:
		(m as Node3D).visible = _scrolls()
	# REMATCH: a non-host online only waits for the host.
	_waiting = waiting
	if _rematch_words != null:
		_rematch_words.queue_free()
	var rk := _rematch_plate.get_child(0) as Node3D
	LuchaKit.tint_part(rk, "results_rematch_face", WAIT_FACE if waiting else LuchaKit.RED)
	_rematch_words = _words("WAITING FOR HOST" if waiting else "REMATCH!", 1.72, 0.24, LuchaKit.CREAM, LuchaKit.INK, Vector3(0, 0, 0.07))
	_rematch_plate.add_child(_rematch_words)
	if _wait_glass != null:
		_wait_glass.visible = waiting
		_wait_glass.rotation.z = 0.0
	_glass_t = 0.0
	# The buttons pop after the last row (input is live from the start).
	for i in items.size():
		var n: Node3D = items[i].node
		n.visible = false
		var tw := create_tween()
		tw.tween_interval(_rows_in_at + 0.10 + 0.08 * i)
		tw.tween_callback(func():
			n.visible = true
			n.scale = Vector3.ONE * 0.01)
		tw.tween_property(n, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# The medal pops and the name punches at 0.5 s.
	if _medal != null:
		_medal.scale = Vector3.ONE * 0.01
		var mt := create_tween()
		mt.tween_interval(0.5)
		mt.tween_property(_medal, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	nm.scale = Vector3.ONE * 1.35
	var nt := create_tween()
	nt.tween_interval(0.5)
	nt.tween_property(nm, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _player_row(rank: int, p: Dictionary) -> Node3D:
	var root := Node3D.new()
	var k := LuchaKit.kit_model("results_row")
	if k == null:
		k = LuchaKit._plate(3.4, 0.4, LuchaKit.GOLD)
	root.add_child(k)
	LuchaKit.tint_part(k, "results_row_tint", p.get("tint", Color.WHITE))
	if p.get("own", false):
		LuchaKit.tint_part(k, "results_row_face", OWN_ROW)  # online: find yourself in a long lobby
	for nm in ["results_row_medal_silver", "results_row_medal_bronze", "results_row_medal_plain"]:
		var m := k.find_child(nm, true, false) as Node3D
		if m != null:
			m.visible = nm == ["results_row_medal_silver", "results_row_medal_bronze", "results_row_medal_plain"][mini(rank - 2, 2)]
	if rank >= 4:
		var rk := LuchaKit.text3d(str(rank), 0.20 if rank < 10 else 0.16, LuchaKit.CREAM)
		rk.position = Vector3(-1.40, 0, 0.092)
		LuchaKit.center_digits(rk)
		root.add_child(rk)
	var nmw := _words(str(p.get("name", "")), 1.46, 0.20, NAVY, null, Vector3(-0.03, 0, 0.0765), 0.12)
	root.add_child(nmw)
	root.set_meta("name_words", nmw)
	var h := _words(str(p.get("height", "")), 0.71, 0.17, LuchaKit.CREAM, LuchaKit.INK, Vector3(1.255, 0, 0.065))
	LuchaKit.center_digits(h)
	root.add_child(h)
	return root


func _tower_row(l: String, r: String) -> Node3D:
	var root := Node3D.new()
	var k := LuchaKit.kit_model("results_tower_row")
	if k == null:
		k = LuchaKit._plate(3.4, 0.4, LuchaKit.STRAP_BLUE)
	root.add_child(k)
	root.add_child(_words(l, 1.26, 0.18, NAVY, null, Vector3(-0.885, 0, 0.065)))
	root.add_child(_words(r, 1.26, 0.18, NAVY, null, Vector3(0.885, 0, 0.065)))
	return root


static func _tint(n: Node, c: Color) -> void:
	if n is MeshInstance3D:
		(n as MeshInstance3D).set_instance_shader_parameter(&"tint", c)


## Words onto a flip tile, where they stand now: they turn with it.
func _onto_tile(words: Node3D, tile: Node3D) -> void:
	var at := words.global_transform
	words.get_parent().remove_child(words)
	tile.add_child(words)
	words.global_transform = at


## New words in a tile's place: the same spot, the same fit rule.
func _swap_words(d: Dictionary, steam: bool) -> void:
	var s: String = str(d.steam) if steam and str(d.steam) != "" else str(d.game)
	var old: Node3D = d.words
	if not is_instance_valid(old):
		return
	var nw: Node3D
	if d.winner:
		nw = _words(s, 2.53, 0.30, LuchaKit.GOLD, WINNER_BACK, Vector3.ZERO, 0.16)
	else:
		nw = _words(s, 1.46, 0.20, NAVY, null, Vector3.ZERO, 0.12)
	nw.transform = old.transform
	nw.scale = Vector3.ONE
	old.get_parent().add_child(nw)
	old.queue_free()
	d.words = nw


## The flip: the winner's tile, then the rows in sight top down, 0.05 s apart; a full
## turn in 0.45 s, the words swapped while the back faces the camera. Rows out of sight
## just swap. A tile with no Steam name stays put.
func _flip() -> void:
	_show_steam = not _show_steam
	var to_steam := _show_steam
	var in_sight: Array = []
	for d in _tiles:
		if str(d.steam) == "":
			continue
		var row = d.row
		if row != null and (not (row as Node3D).visible or (row as Node3D).position.y > SLOTS[0] + 0.01 or (row as Node3D).position.y < SLOTS[SLOTS.size() - 1] - 0.01):
			_swap_words(d, to_steam)
			continue
		in_sight.append(d)
	in_sight.sort_custom(func(a, b): return (a.winner and not b.winner) or (a.winner == b.winner and a.row != null and b.row != null and (a.row as Node3D).position.y > (b.row as Node3D).position.y))
	for k in in_sight.size():
		var d: Dictionary = in_sight[k]
		var tile: Node3D = d.tile
		var tw := create_tween()
		tw.tween_interval(FLIP_RIPPLE * k)
		tw.tween_property(tile, "rotation:x", TAU, FLIP_S).from(0.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_callback(func(): tile.rotation.x = 0.0)
		var sw := create_tween()
		sw.tween_interval(FLIP_RIPPLE * k + 0.2 * FLIP_S / 0.45)
		sw.tween_callback(func(): _swap_words(d, to_steam))
	_flip_until = _t + FLIP_BUSY
	_next_flip = _t + FLIP_EVERY


func _scrolls() -> bool:
	return _rows.size() > SLOTS.size()


## Each slat's place in the loop at the current offset; hidden under the covers.
func _place_rows() -> void:
	var n := _rows.size()
	for k in n:
		var r: Node3D = _rows[k]
		var s := float(k)
		if _scrolls():
			s = fposmod(float(k) - roll_off + 1.0, float(n)) - 1.0  # (-1 .. n-1): leaving at the top, then from the bottom
		var y := SLOTS[0] - 0.5 * s
		r.position = Vector3(0, y, ROW_Z)
		r.visible = y <= HIDE_ABOVE and y >= HIDE_BELOW


func _step() -> void:
	_roll_target += 1
	if _step_tween != null and _step_tween.is_valid():
		_step_tween.kill()
	_step_tween = create_tween()
	_step_tween.tween_property(self, "roll_off", float(_roll_target), STEP_S).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Sound.play("ui_hover", -22.0)
	# Rank 2 back on top: hold again.
	_next_step = _t + (HOLD_S if _roll_target % _rows.size() == 0 else STEP_EVERY)


# ---------------------------------------------------------------- show / hide

func open() -> void:
	super.open()
	_t = 0.0
	_hang.position = Vector3(0, HANG_Y + 8.0, 0)
	_hang.rotation.z = 0.0
	var tw := create_tween()
	tw.tween_property(_hang, "position:y", HANG_Y, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_fit_screen()


## Hung by its left rim at every window shape; narrow windows take it at 0.9.
func _fit_screen() -> void:
	if lucha == null or cam == null:
		return
	var vs: Vector2 = get_viewport().get_visible_rect().size if get_viewport() != null else Vector2(16, 9)
	var aspect := vs.x / maxf(1.0, vs.y)
	var half_h := tan(deg_to_rad(cam.fov * 0.5)) * LuchaUI.MENU_DIST / LuchaUI.UI_SCALE
	var half_w := half_h * aspect
	var s := 0.9 if aspect < 1.45 else 1.0
	_hang.scale = Vector3.ONE * s
	position.x = (-half_w + 0.30 + 2.10 * s) * LuchaUI.UI_SCALE


func _process(delta: float) -> void:
	super._process(delta)
	if not visible:
		return
	_t += delta
	var t := Time.get_ticks_msec() / 1000.0
	_fit_screen()
	# The swing about the straps: from 2.5 degrees, damped to a slow idle that never stops.
	if _t > 0.55:
		var u := _t - 0.55
		_hang.rotation.z = deg_to_rad(2.5) * exp(-u * 2.2) * cos(u * 4.0) + deg_to_rad(0.5) * sin(TAU * 0.25 * u)
	if _medal != null and _t > 1.0:
		_medal.rotation.y = deg_to_rad(10.0) * sin(TAU * 0.4 * t)
	if _crest != null:
		_crest.rotation.z = deg_to_rad(2.0) * sin(TAU * 0.5 * t)
	if _letters != null:
		_letters.scale = Vector3.ONE * (1.0 + 0.015 + 0.015 * sin(TAU * t))
	_bulb_t += delta
	if _bulb_t >= 0.45 and _bulbs.size() == 2:
		_bulb_t = 0.0
		_bulb_swap = not _bulb_swap
		_tint(_bulbs[0], LuchaKit.GOLD if _bulb_swap else LuchaKit.CREAM)
		_tint(_bulbs[1], LuchaKit.CREAM if _bulb_swap else LuchaKit.GOLD)
	for m in _more:
		if (m as Node3D).visible:
			(m as Node3D).position = (m.get_meta("home") as Vector3) + Vector3(0, 0.02 * sin(TAU * 1.5 * t), 0)
	var stepping := _step_tween != null and _step_tween.is_valid() and _step_tween.is_running()
	if _t >= _next_flip and not stepping:
		_flip()
	if _scrolls() and _t >= _next_step:
		if _t < _flip_until:
			_next_step = _flip_until  # the roll waits the flip out
		else:
			_step()
	if not _rows.is_empty():
		_place_rows()
	if _waiting and _wait_glass != null:
		_glass_t += delta
		if _glass_t >= 1.6:
			_glass_t = 0.0
			var gt := create_tween()
			gt.tween_property(_wait_glass, "rotation:z", _wait_glass.rotation.z + PI, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
