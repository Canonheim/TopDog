extends Node3D
## Camera-hung title belt. Geometry uses the shared atlas/cel material, like the menus.
const Progression = preload("res://core/player_progression.gd")
@export_enum("Championship", "Fiesta", "Royal") var style := 0
var fill: MeshInstance3D
var level_text: Label3D
var amount_text: Label3D
var next_text: Label3D
const BAR_LEFT := -1.27
const BAR_WIDTH := 3.35

func _ready() -> void:
	name = "PlayerXP"
	build_display()

func set_style(value: int) -> void:
	style = clampi(value, 0, 2)
	for child in get_children():
		remove_child(child)
		child.queue_free()
	build_display()

func build_display() -> void:
	var face := [LuchaKit.CREAM, LuchaKit.RED, LuchaKit.BLUE][style] as Color
	var ink := LuchaKit.INK if style == 0 else LuchaKit.CREAM
	# Nested chamfered plates make the gold belt rim and recessed cream face.
	plate(5.15, 1.28, LuchaKit.INK, 0.0)
	plate(5.04, 1.17, LuchaKit.GOLD, 0.025)
	plate(4.80, .94, LuchaKit.GOLD_DARK, 0.05)
	plate(4.70, .84, face, 0.075)
	if style == 1:
		for x in [-2.05, -1.55, -1.05, -.55, -.05, .45, .95, 1.45, 1.95]:
			add_child(LuchaKit.cyl(.035,.025,LuchaKit.CREAM,Vector3(x,.52,.12),Vector3.BACK))
	if style == 2:
		add_child(LuchaKit.box(Vector3(4.40,.04,.025),LuchaKit.TURQUOISE,Vector3(0,.47,.12)))
		add_child(LuchaKit.box(Vector3(4.40,.04,.025),LuchaKit.TURQUOISE,Vector3(0,-.47,.12)))
	for x in [-2.38, 2.38]:
		var star := LuchaKit.star_mesh(.16, LuchaKit.TURQUOISE if style != 1 else LuchaKit.GOLD)
		star.position = Vector3(x, 0, .13)
		add_child(star)
	# Level medallion and small upper title.
	if style == 2:
		var crest := LuchaKit.star_mesh(.60,LuchaKit.GOLD)
		crest.position = Vector3(-1.83,0,.14)
		add_child(crest)
	var badge := LuchaKit.cyl(.44, .08, LuchaKit.GOLD, Vector3(-1.83,0,.15), Vector3.BACK)
	add_child(badge)
	add_child(LuchaKit.cyl(.35, .08, LuchaKit.RED if style == 0 else LuchaKit.TURQUOISE, Vector3(-1.83,0,.20), Vector3.BACK))
	label("LEVEL", .16, LuchaKit.CREAM, Vector3(-1.83,.15,.27))
	level_text = label("1", .32, LuchaKit.CREAM, Vector3(-1.83,-.09,.27))
	label("PLAYER XP", .21, LuchaKit.RED if style == 0 else LuchaKit.GOLD, Vector3(-.62,.25,.14))
	next_text = label("Next Level Up Reward:\nComing soon.", .135, ink, Vector3(1.12,.25,.14))
	add_child(LuchaKit.box(Vector3(BAR_WIDTH+.10,.29,.05), LuchaKit.INK, Vector3(BAR_LEFT+BAR_WIDTH*.5,-.07,.13)))
	add_child(LuchaKit.box(Vector3(BAR_WIDTH,.21,.04), LuchaKit.INK if style != 0 else LuchaKit.GOLD_DARK, Vector3(BAR_LEFT+BAR_WIDTH*.5,-.07,.17)))
	fill = LuchaKit.box(Vector3(1,.21,.04), LuchaKit.GOLD if style == 2 else LuchaKit.TURQUOISE)
	add_child(fill)
	if style == 2:
		for i in range(1,10):
			add_child(LuchaKit.box(Vector3(.025,.21,.02),LuchaKit.BLUE,Vector3(BAR_LEFT+BAR_WIDTH*i/10.0,-.07,.24)))
	amount_text = label("0 / 500 XP", .18, ink, Vector3(.40,-.30,.25))
	refresh()

func plate(w: float, h: float, color: Color, z: float) -> void:
	var cut := .18
	var points := PackedVector2Array([Vector2(-w/2+cut,-h/2),Vector2(w/2-cut,-h/2),Vector2(w/2,-h/2+cut),Vector2(w/2,h/2-cut),Vector2(w/2-cut,h/2),Vector2(-w/2+cut,h/2),Vector2(-w/2,h/2-cut),Vector2(-w/2,-h/2+cut)])
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in points.size():
		for v in [Vector2.ZERO, points[(i+1)%points.size()], points[i]]:
			st.set_normal(Vector3.BACK)
			st.set_uv(Vector2.ZERO)
			st.add_vertex(Vector3(v.x,v.y,z))
	var mesh := MeshInstance3D.new()
	mesh.mesh = st.commit()
	CelPass.paint(mesh, color)
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh)

func label(text: String, size: float, color: Color, at: Vector3) -> Label3D:
	var node := LuchaKit.text3d(text, size, color)
	node.position = at
	add_child(node)
	return node

func refresh() -> void:
	set_progress(Progression.load_snapshot())

func set_progress(state: Dictionary) -> void:
	var ratio := clampf(float(state.fraction),0,1)
	fill.visible = ratio > 0
	fill.scale.x = maxf(.0001, BAR_WIDTH * ratio)
	fill.position = Vector3(BAR_LEFT + BAR_WIDTH * ratio * .5, -.07, .20)
	level_text.text = str(state.level)
	amount_text.text = "MAX LEVEL" if state.level >= Progression.MAX_LEVEL else "%s / %s XP" % [Progression.number(int(state.xp)),Progression.number(int(state.needed))]
	next_text.text = "ALL LEVELS COMPLETE" if state.level >= Progression.MAX_LEVEL else "Next Level Up Reward:\nComing soon."
