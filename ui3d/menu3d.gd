class_name Menu3D
extends Node3D
## A 3D MENU: championship-belt buttons in the world, hung in front of the camera.
## Pad (through PadNav's ui_* actions), keyboard (arrows, Enter/Space) and mouse
## (a ray against each belt) all drive it. The focused belt grows and wobbles and
## a luchador mask slides beside it; a menu opening drops its belts in with a bounce.
##
## Items: add_button(label, callback) / add_choice(label, options, index, on_change)
## / add_spacer(). A choice cycles with left/right (or a click on its sides).
## add_row(plate, cb): a kit row (friend / lobby row, a row of small belts) with
## focus stops left to right; left/right walks the stops, A calls cb(stop). The
## plate brings its own focus rings (meta focus_nodes) and stop centres (stop_x).

signal activated(index: int)

const UI_LAYER := 1 << 19
const STEP := 0.5
const MENU_COLUMN_X := -3.9
const MENU_TOP_Y := 2.25  # (the UI pass, 1b: the top belt's crest and arrows clear the banner)
const BELT_W := 2.3

var items: Array = []  # [{node, kind, label, cb, options, index, on_change, text_node, area}]
var focus := 0
var cam: Camera3D
var header: Node3D  # optional: logo / title above the belts
var cursor: Node3D
var item_spacing := STEP
var header_tilt := 0.0
var _header_home := Vector3.ZERO
var _header_tween: Tween = null
var column_x := MENU_COLUMN_X
var top_y := MENU_TOP_Y
var _open_t := 0.0
var _hover := -1
## THE TITLE'S PRESS ANY BUTTON (Parker 11-11): the logo big in the middle with the
## press line under it and no belts; on a press the logo shrinks to its corner and
## the belts fall in from the top of the screen. (lucha_ui owns the press.)
var attract := false
var attract_at := Vector3(0, 0.7, 0)  # the big logo's spot, menu space
var attract_scale := 1.45
## The big logo stands level (Parker 11-11: "not be rotated clockwise like it is in the
## main menu"): the header's turn that undoes its own built-in tilt.
var attract_tilt := 0.0
var attract_plate: Node3D = null  # "PRESS ANY BUTTON TO START", under the big logo
var _quiet_until := 0  # msec: the press that left the attract does nothing else


func _init(p_cam: Camera3D) -> void:
	cam = p_cam


func _ready() -> void:
	cursor = LuchaKit.mask_icon(LuchaKit.RED, LuchaKit.GOLD)
	cursor.scale = Vector3.ONE * 0.55
	add_child(cursor)
	close()


func set_header(n: Node3D, at: Vector3) -> void:
	if header != null:
		header.queue_free()
	header = n
	header.position = at
	_header_home = at
	add_child(header)


func add_button(label: String, cb: Callable) -> int:
	return _add({"kind": "button", "label": label, "cb": cb})


func add_choice(label: String, options: Array, index: int, on_change: Callable) -> int:
	return _add({"kind": "choice", "label": label, "options": options, "index": index, "on_change": on_change})


## A belt that flips through options with left / right and does something with the
## shown option on A / Enter / click (HOST  PUBLIC, CHAT  HELLO!).
func add_choice_button(label: String, options: Array, index: int, cb: Callable) -> int:
	return _add({"kind": "choice_button", "label": label, "options": options, "index": index, "on_change": Callable(), "cb": cb})


## Rebuilt lists (friends, lobbies, members): lay the belts out again and keep the
## menu open, with no drop-in, the focus kept in range.
func refresh() -> void:
	_layout()
	_set_pickable(visible)
	if not _live(focus):
		focus = _next_live(-1, 1)
	for it in items:
		if it.node != null:
			it.node.position = it.node.get_meta("home")
	no_shadows_here()


func no_shadows_here() -> void:
	LuchaUI.no_shadows(self)


func add_row(plate: Node3D, cb: Callable, stop := 0) -> int:
	return _add({"kind": "row", "label": "", "cb": cb, "plate": plate, "stop": stop, "custom_text": true})


func add_spacer() -> void:
	items.append({"kind": "spacer", "node": null})


func clear_items() -> void:
	for it in items:
		if it.node != null:
			it.node.queue_free()
	items.clear()
	focus = 0


func _add(it: Dictionary) -> int:
	var root := Node3D.new()
	var belt: Node3D = it.get("plate", null)
	if belt == null:
		belt = LuchaKit.belt_button(BELT_W)
	root.add_child(belt)
	if it.kind == "choice" or it.kind == "choice_button":
		# The < > cues either side: left / right flips this one.
		var half: float = float(belt.get_meta("width", BELT_W)) * 0.5 + 0.22
		var arrows: Array = []
		for d in [-1, 1]:
			var a := LuchaKit.picker_arrow(d)
			a.position = Vector3(d * half, 0, 0.05)
			a.visible = true
			root.add_child(a)
			arrows.append(a)
		it.arrows = arrows
	it.belt = belt
	var txt := Node3D.new()
	root.add_child(txt)
	it.text_node = txt
	var area := Area3D.new()
	area.collision_layer = UI_LAYER
	area.collision_mask = 0
	area.monitoring = false
	var col := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(float(belt.get_meta("width", BELT_W)) + (0.95 if it.has("arrows") else 0.2), maxf(0.55, float(belt.get_meta("height", 0.55))), 0.3)
	col.shape = bs
	area.add_child(col)
	root.add_child(area)
	add_child(root)
	it.node = root
	it.area = area
	items.append(it)
	var idx := items.size() - 1
	area.set_meta("menu_index", idx)
	_relabel(idx)
	_layout()
	return idx


func _relabel(i: int) -> void:
	var it: Dictionary = items[i]
	for ch in it.text_node.get_children():
		ch.queue_free()
	if it.get("custom_text", false):
		return  # the plate carries its own words
	var s: String = it.label
	if it.kind == "choice" or it.kind == "choice_button":
		s = "%s  %s" % [it.label, str(it.options[it.index])]  # left / right flips it; the stars on the belt say so
		if it.get("value_only", false):
			s = str(it.options[it.index])  # (the climber beside it shows what it changes)
	# Fit the words to the belt's label face (the kit's face, or the placeholder plate).
	var belt: Node3D = it.belt
	var face_w: float = belt.get_meta("face_w", BELT_W * 0.92)
	var face_z: float = belt.get_meta("face_z", 0.06)
	var size := minf(0.2, face_w * 0.94 / maxf(1.0, s.length() * 0.62))
	var t := LuchaKit.poster_text(s, size, belt.get_meta("text_color", LuchaKit.LEATHER), belt.get_meta("text_back", LuchaKit.GOLD_DARK), 0.025)
	t.position = Vector3(0, 0, face_z + 0.01)
	it.text_node.add_child(t)


func set_label(i: int, s: String) -> void:
	items[i].label = s
	_relabel(i)


func _layout() -> void:
	var y := top_y
	for it in items:
		var step := item_spacing
		if it.node != null:
			it.node.position = it.get("layout_position", Vector3(column_x, y, 0))
			it.node.set_meta("home", it.node.position)
			# A kit belt says how tall its plate is: never let the points overlap.
			step = maxf(item_spacing, float((it.belt as Node3D).get_meta("height", 0.0)) + 0.06)
		if not it.has("layout_position"):
			y -= step


# ---------------------------------------------------------------- show / hide

func open() -> void:
	visible = true
	_set_pickable(true)
	_open_t = 0.0
	focus = _next_live(-1, 1)
	var k := 0
	for it in items:
		if it.node == null:
			continue
		var home: Vector3 = it.node.get_meta("home")
		it.node.position = home + Vector3(0, 3.5, 0)
		var tw := create_tween()
		tw.tween_interval(0.05 * k)
		tw.tween_property(it.node, "position", home, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		k += 1
	if header != null:
		# From its true home: read mid-drop (pause, resume, pause) it settled higher each time.
		var hp := _header_home
		if _header_tween != null and _header_tween.is_valid():
			_header_tween.kill()
		header.position = hp + Vector3(0, 4.0, 0)
		header.rotation.z = header_tilt + 0.25
		var tw2 := create_tween().set_parallel()
		_header_tween = tw2
		tw2.tween_property(header, "position", hp, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw2.tween_property(header, "rotation:z", header_tilt, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if cursor != null and _live(focus):
		cursor.position = (items[focus].node.get_meta("home") as Vector3) + Vector3(-BELT_W * 0.5 - 0.55, 0, 0.1)


## The title waiting on a press: the logo big, the press line, no belts.
func open_attract() -> void:
	visible = true
	attract = true
	_set_pickable(false)
	_open_t = 0.0
	cursor.visible = false
	for it in items:
		if it.node != null:
			(it.node as Node3D).visible = false
	if attract_plate != null:
		attract_plate.visible = true
		attract_plate.scale = Vector3.ONE
	if header != null:
		if _header_tween != null and _header_tween.is_valid():
			_header_tween.kill()
		header.position = attract_at + Vector3(0, 4.0, 0)
		header.rotation.z = attract_tilt + 0.25
		header.scale = Vector3.ONE * attract_scale
		var tw := create_tween().set_parallel()
		_header_tween = tw
		tw.tween_property(header, "position", attract_at, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw.tween_property(header, "rotation:z", attract_tilt, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


## The press: the logo shrinks a little and moves to its spot, the belts fall in
## quickly from above the top of the screen, one after another.
func leave_attract() -> void:
	if not attract:
		return
	attract = false
	_quiet_until = Time.get_ticks_msec() + 350
	_open_t = 0.0
	_set_pickable(true)
	focus = _next_live(-1, 1)
	if attract_plate != null:
		var tp := create_tween()
		tp.tween_property(attract_plate, "scale", Vector3.ONE * 0.01, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tp.tween_callback(func(): attract_plate.visible = false)
	if header != null:
		if _header_tween != null and _header_tween.is_valid():
			_header_tween.kill()
		var tw := create_tween().set_parallel()
		_header_tween = tw
		tw.tween_property(header, "position", _header_home, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(header, "scale", Vector3.ONE, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(header, "rotation:z", header_tilt, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Above the screen's top edge, wherever the window's shape puts it.
	var top := 6.0
	if cam != null:
		top = tan(deg_to_rad(cam.fov * 0.5)) * absf(position.z) / maxf(0.001, scale.y) + 1.0
	var k := 0
	for it in items:
		if it.node == null:
			continue
		var n := it.node as Node3D
		var home: Vector3 = n.get_meta("home")
		n.visible = true
		n.position = Vector3(home.x, maxf(top, home.y + 3.5), home.z)
		var tw2 := create_tween()
		tw2.tween_interval(0.12 + 0.045 * k)
		tw2.tween_property(n, "position", home, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		k += 1
	if cursor != null and _live(focus):
		cursor.position = (items[focus].node.get_meta("home") as Vector3) + Vector3(-BELT_W * 0.5 - 0.55, 0, 0.1)


func close() -> void:
	visible = false
	_set_pickable(false)
	if attract:
		# Left while waiting on the press (an invite opened the lobby): next time it's a plain menu.
		attract = false
		if attract_plate != null:
			attract_plate.visible = false
		for it in items:
			if it.node != null:
				(it.node as Node3D).visible = true
		if header != null:
			header.scale = Vector3.ONE


## Hidden menus must not catch the mouse: their belts leave the UI layer.
func _set_pickable(on: bool) -> void:
	for it in items:
		if it.node != null:
			(it.area as Area3D).collision_layer = UI_LAYER if on else 0


# ---------------------------------------------------------------- input

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not is_visible_in_tree():
		return
	if attract or Time.get_ticks_msec() < _quiet_until:
		if not event is InputEventMouseMotion:
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_down"):
		_move(1)
	elif event.is_action_pressed("ui_up"):
		_move(-1)
	elif event.is_action_pressed("ui_left"):
		_cycle(-1)
	elif event.is_action_pressed("ui_right"):
		_cycle(1)
	elif event.is_action_pressed("ui_accept"):
		_activate(focus)
	elif event is InputEventMouseMotion:
		var h := _pick((event as InputEventMouseMotion).position)
		if h != -1 and h != focus:
			focus = h
			Sound.play("ui_hover", -14.0)
		if h != -1 and items[h].kind == "row":
			items[h].stop = _stop_at(h, (event as InputEventMouseMotion).position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var h := _pick((event as InputEventMouseButton).position)
		if h != -1:
			focus = h
			var it: Dictionary = items[h]
			if it.kind == "row":
				it.stop = _stop_at(h, (event as InputEventMouseButton).position)
				_activate(h)
			elif it.has("arrows"):
				var local := _ray_local(h, (event as InputEventMouseButton).position)
				var half: float = float(it.belt.get_meta("width", BELT_W)) * 0.5
				if absf(local.x) > half:
					_cycle(-1 if local.x < 0.0 else 1)
				else:
					_activate(h)
			else:
				_activate(h)
	else:
		return
	get_viewport().set_input_as_handled()


func _live(i: int) -> bool:
	return i >= 0 and i < items.size() and items[i].node != null


func _next_live(from: int, dir: int) -> int:
	var i := from
	for k in items.size():
		i = wrapi(i + dir, 0, items.size())
		if _live(i):
			return i
	return 0


func _move(dir: int) -> void:
	focus = _next_live(focus, dir)
	Sound.play("ui_hover", -12.0)


func _stop_at(i: int, screen_pos: Vector2) -> int:
	var xs: Array = (items[i].belt as Node3D).get_meta("stop_x", [0.0])
	var x := _ray_local(i, screen_pos).x
	var best := 0
	for k in xs.size():
		if absf(float(xs[k]) - x) < absf(float(xs[best]) - x):
			best = k
	return best


func _cycle(dir: int) -> void:
	if not _live(focus):
		return
	var it: Dictionary = items[focus]
	if it.kind == "row":
		var n: int = ((it.belt as Node3D).get_meta("stop_x", [0.0]) as Array).size()
		var to := clampi(int(it.stop) + dir, 0, n - 1)
		if to != it.stop:
			it.stop = to
			Sound.play("ui_hover", -12.0)
		return
	if it.kind != "choice" and it.kind != "choice_button":
		return
	it.index = wrapi(it.index + dir, 0, it.options.size())
	_relabel(focus)
	Sound.play("ui_click", -8.0)
	_punch(focus)
	if it.on_change.is_valid():
		it.on_change.call(it.index)


func _activate(i: int) -> void:
	if not _live(i):
		return
	var it: Dictionary = items[i]
	if it.kind == "choice":
		_cycle(1)
		return
	Sound.play("clap", -6.0)
	_punch(i)
	activated.emit(i)
	if it.kind == "row":
		if it.cb.is_valid():
			it.cb.call(int(it.stop))
		return
	if it.kind == "choice_button":
		if it.cb.is_valid():
			it.cb.call(it.index)
		return
	if it.cb.is_valid():
		it.cb.call()


func _punch(i: int) -> void:
	var n: Node3D = items[i].node
	n.scale = Vector3.ONE * 1.3
	var tw := create_tween()
	tw.tween_property(n, "scale", Vector3.ONE * 1.12, 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _pick(screen_pos: Vector2) -> int:
	if cam == null:
		return -1
	var from := cam.project_ray_origin(screen_pos)
	var to := from + cam.project_ray_normal(screen_pos) * 60.0
	var q := PhysicsRayQueryParameters3D.create(from, to, UI_LAYER)
	q.collide_with_areas = true
	q.collide_with_bodies = false
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty() or not hit.collider.has_meta("menu_index"):
		return -1
	var idx := int(hit.collider.get_meta("menu_index"))
	return idx if _live(idx) and items[idx].area == hit.collider else -1


func _ray_local(i: int, screen_pos: Vector2) -> Vector3:
	var n: Node3D = items[i].node
	var from := cam.project_ray_origin(screen_pos)
	var dir := cam.project_ray_normal(screen_pos)
	var plane := Plane(n.global_transform.basis.z.normalized(), n.global_position)
	var p = plane.intersects_ray(from, dir)
	return n.global_transform.affine_inverse() * (p if p != null else n.global_position)


# ---------------------------------------------------------------- life

func _process(delta: float) -> void:
	if not visible:
		return
	_open_t += delta
	var t := Time.get_ticks_msec() / 1000.0
	if attract:
		if header != null and _open_t > 0.7:
			header.rotation.z = attract_tilt + sin(t * 1.4) * 0.025
			header.scale = Vector3.ONE * attract_scale * (1.0 + sin(t * 2.6) * 0.012)
		if attract_plate != null:
			attract_plate.scale = Vector3.ONE * (1.0 + sin(t * 3.4) * 0.05)
		return
	for i in items.size():
		var it: Dictionary = items[i]
		if it.node == null:
			continue
		var n: Node3D = it.node
		var want := (1.04 if it.kind == "row" else 1.12) if i == focus else 1.0
		var rings = (it.belt as Node3D).get_meta("focus_nodes") if (it.belt as Node3D).has_meta("focus_nodes") else null
		if rings != null:
			for k in (rings as Array).size():
				if is_instance_valid(rings[k]):
					(rings[k] as Node3D).visible = i == focus and k == int(it.get("stop", 0))
		if it.has("arrows"):
			for a in it.arrows:
				(a as Node3D).visible = true
				(a as Node3D).scale = Vector3.ONE * (1.0 + 0.12 * sin(t * 8.0))
		if _open_t > 0.6:
			n.scale = n.scale.lerp(Vector3.ONE * want, 1.0 - exp(-delta * 12.0))
		n.rotation.z = (sin(t * 5.0 + i) * 0.035) if i == focus else lerpf(n.rotation.z, sin(t * 1.3 + i * 0.7) * 0.01, 0.1)
		# The kit belt's pug crest shows on the selected belt only (they stack tight).
		var crest = (it.belt as Node3D).get_meta("crest") if (it.belt as Node3D).has_meta("crest") else null
		if crest != null and is_instance_valid(crest):
			(crest as Node3D).visible = i == focus
	# The kit belt carries its own selection mark (the pug crest): no mask cursor then.
	if cursor != null and _live(focus):
		var fb := items[focus].belt as Node3D
		cursor.visible = not fb.has_meta("crest") and not fb.has_meta("focus_nodes")
	if cursor != null and cursor.visible and _live(focus) and _open_t > 0.3:
		var home: Vector3 = items[focus].node.get_meta("home")
		var bw: float = (items[focus].belt as Node3D).get_meta("width", BELT_W)
		var target := home + Vector3(-bw * 0.5 - 0.45, 0, 0.12)
		cursor.position = cursor.position.lerp(target, 1.0 - exp(-delta * 14.0))
		cursor.rotation.z = sin(t * 6.0) * 0.18
		cursor.rotation.y = sin(t * 2.0) * 0.4
	if header != null and _open_t > 0.7:
		header.rotation.z = header_tilt + sin(t * 1.4) * 0.025
		header.scale = Vector3.ONE * (1.0 + sin(t * 2.6) * 0.012)
