extends "res://ui3d/xp_layout_options.gd"
## Selected title XP design. Presentation only: never grants or writes XP.
signal gain_finished
signal level_celebrated(level: int)
var _shown_total := -1
var _target_total := 0
var _gain: Tween
var _lit_star: ShaderMaterial
var dev_xp_enabled := false
var _dev_hint: Label3D
const DEV_XP_STEP := 2000
## THE KIT LOOK (Parker 11-19: "Dan added a bunch of XP stuff and the UI is a little different
## than ours. Have our UI guy redo the new UI things so they are in our UI style. It already
## looks good, but it's a different style with outlines and stuff"). The UI creator's kit
## models (Top Dog Kit\docs\PARTS.md, X) carry the plates, the stars, the meter's fill and the
## faces; the code writes the numbers on them. Dan's built look stays as the stand-in.
const KIT_BELT := "xp_title_belt"
var kit: Node3D = null  # the kit model, when delivered
var level_cap := .26


func build_display() -> void:
	kit = LuchaKit.kit_model(KIT_BELT)
	if kit == null:
		super.build_display()
		return
	add_child(kit)
	_kit_parts()
	meter_width = 3.16  # xp_fill: 1 long, origin at its left end on the track's start
	level_text = label("1", level_cap, LuchaKit.CREAM, Vector3(0, 1.00, .12))
	amount_text = label("", .16, LuchaKit.INK, Vector3(0, -.38, .089))
	next_text = label("", .12, LuchaKit.INK, Vector3(0, -.95, -.002))
	refresh()
	LuchaUI.no_shadows(self)


## The kit's side stars and fill (the same names on the belt and the match panel).
func _kit_parts() -> void:
	side_stars.clear()
	for part in ["xp_star_l", "xp_star_r"]:
		var star := kit.find_child(part, true, false) as MeshInstance3D
		if star != null:
			side_stars.append(star)
	fill = kit.find_child("xp_fill", true, false) as MeshInstance3D


func set_progress(state: Dictionary) -> void:
	if kit == null:
		super.set_progress(state)
		return
	# The kit's fill only stretches: its origin is already the track's start.
	var ratio := clampf(float(state.fraction), 0, 1)
	fill.visible = ratio > 0
	fill.scale.x = maxf(.0001, meter_width * ratio)
	if level_text.text != str(state.level):
		level_text.text = str(state.level)
		level_text.pixel_size = level_cap * (.8 if state.level >= 100 else 1.0) / 96.0
		center_visible_text(level_text)
	amount_text.text = "MAX LEVEL" if state.level >= Progression.MAX_LEVEL else "%s / %s" % [Progression.number(int(state.xp)), Progression.number(int(state.needed))]
	center_visible_text(amount_text)
	next_text.text = "ALL LEVELS COMPLETE" if state.level >= Progression.MAX_LEVEL else "Next Level Up Reward:\nComing soon."

func _init() -> void:
	style = 1

func total_for(state: Dictionary) -> int:
	var total := int(state.xp)
	for level in range(1,int(state.level)):
		total += Progression.required_xp(level)
	return total

func refresh() -> void:
	if dev_xp_enabled:
		return
	var state := Progression.load_snapshot()
	var total := total_for(state)
	if _shown_total < 0:
		_shown_total = total
		_target_total = total
		set_progress(state)
	elif total != _target_total:
		settle_total(total)

func settle_total(total: int) -> void:
	if _gain != null: _gain.kill()
	_target_total=clampi(total,0,Progression.MAX_TOTAL)
	_shown_total=_target_total
	set_progress(Progression.snapshot(_shown_total))
	stars(false)

func animate_to_total(total: int) -> void:
	total = clampi(total,0,Progression.MAX_TOTAL)
	if _gain != null:
		_gain.kill()
	_target_total = total
	if _shown_total < 0 or total <= _shown_total or not is_visible_in_tree():
		_shown_total = total
		set_progress(Progression.snapshot(total))
		stars(false)
		return
	var before := Progression.snapshot(_shown_total)
	var after := Progression.snapshot(total)
	_gain = create_tween()
	var level := int(before.level)
	var xp := int(before.xp)
	while level < int(after.level):
		var needed := Progression.required_xp(level)
		_gain.tween_callback(stars.bind(true))
		_gain.tween_method(draw_gain.bind(level),float(xp),float(needed),.65)
		_gain.tween_callback(celebrate.bind(level+1))
		_gain.tween_interval(.28)
		level += 1
		xp = 0
	if level < Progression.MAX_LEVEL and int(after.xp) > xp:
		_gain.tween_callback(stars.bind(true))
		_gain.tween_method(draw_gain.bind(level),float(xp),float(after.xp),.8)
	_gain.tween_callback(finish_gain)

func draw_gain(value: float, level: int) -> void:
	var needed := Progression.required_xp(level)
	var state := {"level":level,"xp":roundi(value),"needed":needed,"fraction":value/needed}
	set_progress(state)
	_shown_total = total_for(state)

func stars(lit: bool) -> void:
	if kit != null:
		# Lit without glow (the kit is matte): a size up and the title's gold.
		for star in side_stars:
			if is_instance_valid(star):
				star.set_instance_shader_parameter(&"swatch_uv", AtlasPalette.matte_uv(LuchaKit.GOLD) if lit else Vector2(-1, -1))
				star.scale = Vector3.ONE * (1.3 if lit else 1.0)
		return
	for star in side_stars:
		if is_instance_valid(star):
			CelPass.paint(star,LuchaKit.TURQUOISE)
			if lit:
				if _lit_star == null:
					_lit_star = CelPass.one().duplicate()
					_lit_star.set_shader_parameter("emission",Color(.1,.8,1.0))
					_lit_star.set_shader_parameter("emission_energy",1.5)
				star.material_override = _lit_star
			star.scale = Vector3.ONE * (1.16 if lit else 1.0)

func celebrate(level: int) -> void:
	var total := 0
	for previous in range(1,level):
		total += Progression.required_xp(previous)
	_shown_total = total
	set_progress(Progression.snapshot(total))
	level_celebrated.emit(level)

func finish_gain() -> void:
	_shown_total = _target_total
	set_progress(Progression.snapshot(_target_total))
	stars(false)
	gain_finished.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree() and _gain != null:
		_gain.kill()
		finish_gain()
		for child in get_children():
			if child.has_meta("xp_sparks"):
				child.queue_free()

func handle_dev_key(event: InputEvent) -> bool:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return false
	var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	if key == KEY_F4:
		dev_xp_enabled = not dev_xp_enabled
		if _dev_hint == null:
			_dev_hint = label("XP TEST: NUMPAD +/- 2,000 XP | F4 TO EXIT", .13, LuchaKit.CREAM, Vector3(0,1.25,.2))
			_dev_hint.outline_size = 8
			_dev_hint.outline_modulate = LuchaKit.INK
		_dev_hint.visible = dev_xp_enabled
		if not dev_xp_enabled:
			if _gain != null:
				_gain.kill()
			_target_total = total_for(Progression.load_snapshot())
			finish_gain()
			for child in get_children():
				if child.has_meta("xp_sparks"):
					child.queue_free()
		return true
	if dev_xp_enabled and key in [KEY_KP_ADD,KEY_KP_SUBTRACT]:
		animate_to_total(_target_total + (DEV_XP_STEP if key == KEY_KP_ADD else -DEV_XP_STEP))
		return true
	return false
