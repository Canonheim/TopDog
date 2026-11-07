extends RefCounted
## UI KIT: the house look for screen menus, and small builders so every screen
## is a few lines. Big type, warm parchment-and-wood panels, pad-navigable.

const FONT_SIZE := 30


static func make_theme() -> Theme:
	var th := Theme.new()
	th.default_font_size = FONT_SIZE
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.13, 0.09, 0.06, 0.92)
	panel.border_color = Color(0.78, 0.6, 0.32)
	panel.set_border_width_all(4)
	panel.set_corner_radius_all(14)
	panel.set_content_margin_all(28)
	th.set_stylebox("panel", "PanelContainer", panel)
	var btn := StyleBoxFlat.new()
	btn.bg_color = Color(0.45, 0.29, 0.16)
	btn.border_color = Color(0.85, 0.66, 0.36)
	btn.set_border_width_all(3)
	btn.set_corner_radius_all(10)
	btn.set_content_margin_all(12)
	var hov := btn.duplicate()
	hov.bg_color = Color(0.62, 0.41, 0.22)
	var foc := btn.duplicate()
	foc.bg_color = Color(0.7, 0.48, 0.24)
	foc.border_color = Color(1.0, 0.88, 0.45)
	foc.set_border_width_all(5)
	var dis := btn.duplicate()
	dis.bg_color = Color(0.25, 0.2, 0.16)
	for t in ["Button", "CheckButton"]:
		th.set_stylebox("normal", t, btn)
		th.set_stylebox("hover", t, hov)
		th.set_stylebox("pressed", t, foc)
		th.set_stylebox("focus", t, foc)
		th.set_stylebox("disabled", t, dis)
	th.set_color("font_color", "Label", Color(0.97, 0.92, 0.82))
	th.set_color("font_color", "Button", Color(1, 0.96, 0.88))
	return th


## A centred panel with a title, a blurb and a VBox (meta "box") to fill.
static func panel_screen(title: String, blurb: String) -> Control:
	var c := CenterContainer.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	var p := PanelContainer.new()
	c.add_child(p)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	p.add_child(box)
	var t := Label.new()
	t.text = title
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 64 if title == "TOP YOUR PALS" else 48)
	t.add_theme_color_override("font_color", Color(1.0, 0.82, 0.38))
	box.add_child(t)
	if blurb != "":
		var b := Label.new()
		b.text = blurb
		b.autowrap_mode = TextServer.AUTOWRAP_WORD
		b.custom_minimum_size = Vector2(900, 0)
		b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.add_theme_font_size_override("font_size", 24)
		box.add_child(b)
	c.set_meta("box", box)
	return c


static func button(parent: Control, text: String, cb: Callable, size := FONT_SIZE) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	b.pressed.connect(func(): Sound.play("ui_click", -6.0); cb.call())
	b.focus_entered.connect(func(): Sound.play("ui_hover", -16.0))
	parent.add_child(b)
	return b


static func slider(parent: Control, label: String, value: float, lo: float, hi: float, cb: Callable, size := 24) -> HSlider:
	var l := Label.new()
	l.text = label
	l.add_theme_font_size_override("font_size", size)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD
	parent.add_child(l)
	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = (hi - lo) / 200.0
	s.value = value
	s.custom_minimum_size = Vector2(440, 28)
	var v := Label.new()
	v.text = "%.2f" % value
	v.add_theme_font_size_override("font_size", size)
	s.value_changed.connect(func(x): v.text = "%.2f" % x; cb.call(x))
	var row := HBoxContainer.new()
	row.add_child(s)
	row.add_child(v)
	parent.add_child(row)
	return s


## Mode / timer / spawn pickers. on_change gets the whole settings dictionary.
static func settings_rows(parent: Control, settings: Dictionary, on_change: Callable) -> Dictionary:
	var s := settings.duplicate()
	var out := {}
	var mode_ids := ["tower", "scramble"]
	var m := OptionButton.new()
	for id in mode_ids:
		m.add_item(Modes.row(id).name)
	m.selected = maxi(0, mode_ids.find(str(s.get("mode", "tower"))))
	var blurb := Label.new()
	blurb.text = Modes.row(mode_ids[m.selected]).blurb
	blurb.add_theme_font_size_override("font_size", 22)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD
	blurb.custom_minimum_size = Vector2(500, 0)
	m.item_selected.connect(func(i):
		s.mode = mode_ids[i]
		blurb.text = Modes.row(mode_ids[i]).blurb
		on_change.call(s.duplicate()))
	parent.add_child(_row("Mode", m))
	parent.add_child(blurb)
	var tm := OptionButton.new()
	for n in Modes.TIMER_NAMES:
		tm.add_item(n)
	tm.selected = maxi(0, Modes.TIMERS.find(float(s.get("timer", 60.0))))
	tm.item_selected.connect(func(i):
		s.timer = Modes.TIMERS[i]
		on_change.call(s.duplicate()))
	parent.add_child(_row("Clock", tm))
	var sp := OptionButton.new()
	for n in Modes.SPAWN_NAMES:
		sp.add_item(n)
	sp.selected = maxi(0, Modes.SPAWNS.find(str(s.get("spawn", "alternate"))))
	sp.item_selected.connect(func(i):
		s.spawn = Modes.SPAWNS[i]
		on_change.call(s.duplicate()))
	parent.add_child(_row("Spawns", sp))
	out.mode = m
	out.timer = tm
	out.spawn = sp
	return out


static func _row(label: String, ctl: Control) -> HBoxContainer:
	var r := HBoxContainer.new()
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(160, 0)
	r.add_child(l)
	ctl.custom_minimum_size = Vector2(320, 0)
	r.add_child(ctl)
	return r


static func first_focus(n: Node) -> Control:
	for ch in n.get_children():
		if ch is BaseButton and (ch as Control).visible and not (ch as BaseButton).disabled:
			return ch
		var f := first_focus(ch)
		if f != null:
			return f
	return null
