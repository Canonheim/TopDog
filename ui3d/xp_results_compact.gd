extends "res://ui3d/xp_championship.gd"
## Sculpted marquee extension with a complete visible border and a shared gold spine.
## THE KIT LOOK (Parker 11-19: "Dan added a bunch of XP stuff and the UI is a little different
## than ours. Have our UI guy redo the new UI things so they are in our UI style. It already
## looks good, but it's a different style with outlines and stuff"). The UI creator's kit
## models (Top Dog Kit\docs\PARTS.md, X) carry the plates, the stars, the meter's fill and the
## faces; the code writes the numbers on them. Dan's built look stays as the stand-in.
var _firework_audio: Node

func reset_firework_audio() -> void:
	if is_instance_valid(_firework_audio): _firework_audio.reset()

func _firework_launched(offset: float) -> void:
	if not is_visible_in_tree(): return
	if not is_instance_valid(_firework_audio):
		_firework_audio = preload("res://ui3d/xp_firework_audio.gd").new()
		add_child(_firework_audio)
	_firework_audio.play_launch(offset)

func _firework_popped() -> void:
	if not is_visible_in_tree(): return
	if not is_instance_valid(_firework_audio):
		_firework_audio = preload("res://ui3d/xp_firework_audio.gd").new()
		add_child(_firework_audio)
	_firework_audio.play_burst()

const KIT_PANEL := "xp_match_panel"
## The cream window the category and its XP are written in (xp_match_summary._fit_text).
var window_top := 1.16
var window_bottom := .64
var window_width := 1.48
var feed_top := .55  # where the feed stars start


func build_display() -> void:
	kit = LuchaKit.kit_model(KIT_PANEL)
	if kit == null:
		_build_marquee()
		return
	add_child(kit)
	_kit_parts()
	meter_left = -.88
	meter_width = 1.76
	meter_y = -.88
	window_top = 1.19
	window_bottom = .54
	window_width = 1.70
	feed_top = .54
	level_cap = .22
	level_text = label("1", level_cap, LuchaKit.CREAM, Vector3(0, -.04, .17))
	amount_text = label("", .15, LuchaKit.INK, Vector3(0, -1.22, .118))
	next_text = label("", .12, LuchaKit.INK, Vector3.ZERO)
	next_text.visible = false
	refresh()
	LuchaUI.no_shadows(self)


func _build_marquee() -> void:
	var outline:=PackedVector2Array([
		Vector2(-.72,1.75),Vector2(.72,1.75),Vector2(.85,1.68),Vector2(.91,1.55),
		Vector2(1.06,1.48),Vector2(1.12,1.34),Vector2(1.12,-1.02),Vector2(1.06,-1.17),
		Vector2(.91,-1.24),Vector2(.85,-1.37),Vector2(.72,-1.45),Vector2(-.72,-1.45),
		Vector2(-.85,-1.37),Vector2(-.91,-1.24),Vector2(-1.06,-1.17),Vector2(-1.12,-1.02),
		Vector2(-1.12,1.34),Vector2(-1.06,1.48),Vector2(-.91,1.55),Vector2(-.85,1.68)])
	# A broad gold spine joins the two frames without hiding the XP panel's border.
	add_child(LuchaKit.box(Vector3(.28,2.32,.035),LuchaKit.GOLD,Vector3(-1.20,.06,-.05)))
	polygon(Array(outline),LuchaKit.INK,0)
	for layer in [[.04,LuchaKit.GOLD,.025],[.11,LuchaKit.INK,.045],[.135,LuchaKit.GOLD,.06],[.20,LuchaKit.CREAM,.08]]:
		polygon(Array(Geometry2D.offset_polygon(outline,-float(layer[0]))[0]),layer[1],float(layer[2]))
	# Derive the tag from the frame's contour, leaving a visible cream gutter.
	var header_inset := Geometry2D.offset_polygon(outline, -.26)[0]
	var header_clip := PackedVector2Array([Vector2(-2,1.24),Vector2(2,1.24),Vector2(2,2),Vector2(-2,2)])
	var header := Geometry2D.intersect_polygons(header_inset, header_clip)[0]
	polygon(Array(header), LuchaKit.RED, .12)
	var heading := label("MATCH XP",.19,LuchaKit.CREAM,Vector3(0,1.345,.20))
	LuchaKit.center_digits(heading)
	# Recessed score window echoes the leaderboard slats; no redundant tally footer.
	well(Vector2(0,.90),Vector2(1.78,.61),LuchaKit.CREAM)
	# Center both straps in the gap between the .35 medallion and .92 inner rim.
	for x in [-.635,.635]:
		well(Vector2(x,.12),Vector2(.44,.32),LuchaKit.RED)
	badge(0,.12,.35)
	for x in [-.635,.635]:
		var star:=LuchaKit.star_mesh(.115,LuchaKit.TURQUOISE)
		star.position=Vector3(x,.12,.21)
		add_child(star)
		side_stars.append(star)
	label("PLAYER XP",.16,LuchaKit.RED,Vector3(0,-.50,.20))
	meter(-.82,1.64,-.81,.18)
	amount_text=label("",.125,LuchaKit.INK,Vector3(0,-1.11,.25))
	next_text=label("",.12,LuchaKit.INK,Vector3.ZERO)
	next_text.visible=false
	refresh()
	LuchaUI.no_shadows(self)

func well(center: Vector2, size: Vector2, face: Color) -> void:
	var w:=size.x*.5
	var h:=size.y*.5
	var c:=minf(.065,h*.35)
	var shape:=PackedVector2Array([Vector2(-w+c,h),Vector2(w-c,h),Vector2(w,h-c),Vector2(w,-h+c),Vector2(w-c,-h),Vector2(-w+c,-h),Vector2(-w,-h+c),Vector2(-w,h-c)])
	for i in shape.size(): shape[i]+=center
	polygon(Array(shape),LuchaKit.GOLD,.10)
	polygon(Array(Geometry2D.offset_polygon(shape,-.025)[0]),LuchaKit.INK,.115)
	polygon(Array(Geometry2D.offset_polygon(shape,-.045)[0]),face,.13)

func celebrate(level: int) -> void:
	super.celebrate(level)
	# All three colors launch together from both rims, behind the panel's face.
	for upper in [true, false]:
		var effect := preload("res://ui3d/xp_fireworks.gd").new()
		effect.simultaneous = true
		effect.popped.connect(_firework_popped)
		effect.launched.connect(_firework_launched)
		add_child(effect)
		effect.scale = Vector3.ONE * .48
		effect.position = Vector3(0, 1.70 if upper else -1.40, -.18)
		effect.rotation.z = 0.0 if upper else PI

func set_progress(state: Dictionary) -> void:
	super.set_progress(state)
	# Six-digit requirements at high levels must stay inside the cream face.
	var font: Font = amount_text.font if amount_text.font != null else ThemeDB.fallback_font
	var width := font.get_string_size(amount_text.text, HORIZONTAL_ALIGNMENT_CENTER, -1, amount_text.font_size).x
	amount_text.pixel_size = minf((.15 if kit != null else .125) / amount_text.font_size, (1.6 if kit != null else 1.48) / maxf(width, 1))
