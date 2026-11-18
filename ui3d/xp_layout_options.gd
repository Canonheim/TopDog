extends "res://ui3d/xp_display.gd"
## Structural concepts; not selected as the live menu display yet.
var meter_left := -1.35
var meter_width := 3.6
var meter_y := 0.0
var side_stars: Array[MeshInstance3D] = []

func build_display() -> void:
	match style:
		0: slim()
		1: belt()
		2: stacked()
	refresh()
	LuchaUI.no_shadows(self)

func panel(w: float, h: float, x: float, y: float, face: Color = LuchaKit.CREAM) -> void:
	var first := get_child_count()
	plate(w,h,LuchaKit.INK,.0)
	plate(w-.08,h-.08,LuchaKit.GOLD,.025)
	plate(w-.23,h-.23,face,.06)
	for i in range(first,get_child_count()):
		get_child(i).position = Vector3(x,y,0)

func badge(x: float, y: float, radius: float, star := false) -> void:
	if star:
		var crest := LuchaKit.star_mesh(radius*1.35,LuchaKit.GOLD)
		crest.position = Vector3(x,y,.14)
		add_child(crest)
	# All rings share one plane and one center: no perspective shift between layers.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var radii := [radius,radius-.025,radius-.065,radius-.085,0.0]
	var colors := [LuchaKit.INK,LuchaKit.GOLD,LuchaKit.INK,LuchaKit.RED]
	for ring in 4:
		var uv := AtlasPalette.matte_uv(colors[ring])
		for i in 64:
			var a := TAU*i/64.0
			var b := TAU*(i+1)/64.0
			var outer_a: Vector2 = Vector2(cos(a),sin(a))*radii[ring]
			var outer_b: Vector2 = Vector2(cos(b),sin(b))*radii[ring]
			var inner_a: Vector2 = Vector2(cos(a),sin(a))*radii[ring+1]
			var inner_b: Vector2 = Vector2(cos(b),sin(b))*radii[ring+1]
			for v in [outer_a,inner_b,outer_b,outer_a,inner_a,inner_b]:
				st.set_uv(uv)
				st.set_normal(Vector3.BACK)
				st.add_vertex(Vector3(v.x+x,v.y+y,.12))
	var disc := MeshInstance3D.new()
	disc.name = "CenteredLevelBadge"
	disc.mesh = st.commit()
	disc.material_override = CelPass.one()
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(disc)
	var caption := label("LEVEL",.14,LuchaKit.CREAM,Vector3(x,y+.115,.121))
	center_visible_text(caption)
	level_text = label("1",.30,LuchaKit.CREAM,Vector3(x,y-.075,.121))
	center_visible_text(level_text)

func meter(left: float, width: float, y: float, height: float) -> void:
	meter_left=left
	meter_width=width
	meter_y=y
	add_child(LuchaKit.box(Vector3(width+.09,height+.08,.035),LuchaKit.INK,Vector3(left+width*.5,y,.12)))
	add_child(LuchaKit.box(Vector3(width,height,.035),LuchaKit.GOLD_DARK,Vector3(left+width*.5,y,.16)))
	fill=LuchaKit.box(Vector3(1,height,.035),LuchaKit.TURQUOISE)
	add_child(fill)

func slim() -> void:
	# A separate hanging crest beside a thin rail; reward is a free-standing line.
	panel(4.03,.53,.38,0)
	badge(-2.12,0,.43,true)
	label("PLAYER XP",.20,LuchaKit.RED,Vector3(-.98,.48,.14))
	amount_text=label("250 / 500 XP",.18,LuchaKit.INK,Vector3(1.48,.48,.14))
	meter(-1.45,3.65,0,.20)
	next_text=label("",.15,LuchaKit.INK,Vector3(.38,-.50,.14))

func belt() -> void:
	# Symmetric short straps, even inset trim, and a single centered information column.
	for side in [-1.0,1.0]:
		var strap := [Vector2(1.72,-.36),Vector2(2.45,-.30),Vector2(2.55,-.18),Vector2(2.55,.20),Vector2(2.45,.32),Vector2(1.72,.38)]
		var points: Array[Vector2] = []
		for v in strap: points.append(Vector2(v.x*side,v.y))
		polygon(points,LuchaKit.INK,0)
		var inset := Geometry2D.offset_polygon(PackedVector2Array(points),-.045)
		polygon(Array(inset[0]),LuchaKit.GOLD,.02)
		inset = Geometry2D.offset_polygon(PackedVector2Array(points),-.10)
		polygon(Array(inset[0]),LuchaKit.RED,.04)
		var star := LuchaKit.star_mesh(.17,LuchaKit.TURQUOISE)
		side_stars.append(star)
		star.position = Vector3(side*2.29,.01,.13)
		add_child(star)
	var shield := PackedVector2Array([Vector2(-2.02,.40),Vector2(-1.66,.64),Vector2(1.66,.64),Vector2(2.02,.40),Vector2(1.92,-.60),Vector2(1.50,-.76),Vector2(0,-.97),Vector2(-1.50,-.76),Vector2(-1.92,-.60)])
	polygon(Array(shield),LuchaKit.INK,.05)
	polygon(Array(Geometry2D.offset_polygon(shield,-.055)[0]),LuchaKit.GOLD,.075)
	polygon(Array(Geometry2D.offset_polygon(shield,-.17)[0]),LuchaKit.INK,.095)
	polygon(Array(Geometry2D.offset_polygon(shield,-.20)[0]),LuchaKit.CREAM,.115)
	badge(0,.67,.39)
	label("PLAYER XP",.18,LuchaKit.RED,Vector3(0,.17,.27))
	meter(-1.58,3.16,-.11,.23)
	amount_text=label("",.17,LuchaKit.INK,Vector3(0,-.35,.27))
	next_text=label("",.125,LuchaKit.INK,Vector3(0,-.53,.27))

func stacked() -> void:
	# Compact scoreboard body, header tab, and physically separate reward ticket.
	panel(4.23,.98,0,.05)
	panel(2.22,.43,.51,.70,LuchaKit.RED)
	label("PLAYER XP",.20,LuchaKit.CREAM,Vector3(.51,.70,.15))
	badge(-1.67,.56,.41)
	meter(-1.83,3.66,.12,.24)
	amount_text=label("",.18,LuchaKit.INK,Vector3(0,-.20,.24))
	for x in [-1.4,1.4]:
		add_child(LuchaKit.box(Vector3(.07,.35,.04),LuchaKit.GOLD,Vector3(x,-.52,0)))
	panel(3.55,.58,0,-.72)
	next_text=label("",.145,LuchaKit.INK,Vector3(0,-.72,.17))

func polygon(points: Array, color: Color, z: float) -> void:
	var verts := PackedVector2Array(points)
	var indices := Geometry2D.triangulate_polygon(verts)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(0,indices.size(),3):
		for j in [2,1,0]:
			var v := verts[indices[i+j]]
			st.set_normal(Vector3.BACK)
			st.set_uv(Vector2.ZERO)
			st.add_vertex(Vector3(v.x,v.y,z))
	var mesh := MeshInstance3D.new()
	mesh.mesh=st.commit()
	CelPass.paint(mesh,color)
	add_child(mesh)

func set_progress(state: Dictionary) -> void:
	var ratio := clampf(float(state.fraction),0,1)
	fill.visible=ratio>0
	fill.scale.x=maxf(.0001,meter_width*ratio)
	fill.position=Vector3(meter_left+meter_width*ratio*.5,meter_y,.21)
	if level_text.text != str(state.level):
		level_text.text=str(state.level)
		level_text.pixel_size = (.24 if state.level >= 100 else .30) / 96.0
		center_visible_text(level_text)
	amount_text.text="MAX LEVEL" if state.level>=100 else "%s / %s" % [Progression.number(int(state.xp)),Progression.number(int(state.needed))]
	center_visible_text(amount_text)
	next_text.text="ALL LEVELS COMPLETE" if state.level>=100 else "Next Level Up Reward:\nComing soon."

func center_visible_text(node: Label3D) -> void:
	# Center the ink bounds, not the font advance box (especially asymmetric digit 1).
	var font: Font = node.font
	var size := node.font_size
	var ts := TextServerManager.get_primary_interface()
	var rid := font.get_rids()[0]
	var cursor := -font.get_string_size(node.text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x*.5
	var bounds := Rect2()
	var first := true
	for i in node.text.length():
		var glyph := ts.font_get_glyph_index(rid,size,node.text.unicode_at(i),0)
		var at := ts.font_get_glyph_offset(rid,Vector2i(size,0),glyph)
		var extent := ts.font_get_glyph_size(rid,Vector2i(size,0),glyph)
		var rect := Rect2(Vector2(cursor+at.x,at.y),extent)
		bounds = rect if first else bounds.merge(rect)
		first = false
		cursor += ts.font_get_glyph_advance(rid,size,glyph).x
	var baseline := (font.get_descent(size)-font.get_ascent(size))*.5
	node.offset = Vector2(-bounds.get_center().x, -baseline+bounds.get_center().y)
