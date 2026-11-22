extends Control
## Three newest loot / XP notices; the displaced oldest fades away permanently.
const COLORS := [Color("36dc70"),Color("36dc70"),Color("398aff"),Color("ba54ff"),Color("ff3046")]
const RADII := [12,16,21,27,34]
const LIFE := 5.1
const EXIT_FADE := .25
var outgoing: Dictionary = {}
var active: Array[Dictionary] = []
var showing := false
var card: Control
var _xp_font: Font
## THE KIT CARDS (Parker 11-19: "Have our UI guy redo the new UI things so they are in our
## UI style"; the UI creator's reward_card and xp_notice, Top Dog Kit\docs\PARTS.md X3-X4).
## With the 3D UI up (Main sets `lucha`) and the models delivered, each notice is a kit
## piece hung on the camera with the rest of the UI, top left, at 0.9 of the UI's scale:
## a loot card's gem and stars take the rarity's colour, the XP notice writes what was done
## and its XP on two faces. The kit is opaque, so a notice slides in from the left edge
## (a small overshoot) and leaves the same way. Without them (a unit test, a missing
## model) the 2D cards below stand in.
var lucha: Node = null
var _layer: Node3D = null
## The compact cut (the UI creator's X5b, 11-19): the stack stays left of the turn banner's
## tail (its right edge under about 340 px at 1080p) with the gem's rosette fully on screen.
const CARD_SCALE := .85
const CARD_STEP := 1.3  # menu units from one loot card's top to the next
const XP_STEP := .75  # and from an XP notice's
const SLIDE_IN := .32
const EDGE := .06  # from the screen's left edge, menu units (about 8 px at 1080p)
const EDGE_TOP := .14  # from its top
const BURST_STAR := "xp_burst_star"

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	process_mode=Node.PROCESS_MODE_ALWAYS
	_xp_font=load(LuchaKit.TITLE_FONT) if ResourceLoader.exists(LuchaKit.TITLE_FONT) else ThemeDB.fallback_font

func enqueue(reward_name: String, rarity: int, player_name := "") -> void:
	_push({"name":reward_name,"rarity":clampi(rarity,1,4),"player":player_name,"kind":"loot","age":0.0,"left":LIFE})

func enqueue_xp(title: String, amount: int, player_name := "") -> void:
	if amount<=0: return
	# Frequent airtime ticks update one notice, move it to the top and restart its lifetime.
	for entry in active:
		if title=="Upward airtime" and entry.kind=="xp" and entry.name==title and entry.player==player_name:
			entry.amount=int(entry.amount)+amount
			entry.left=LIFE
			if entry.has("card"):
				if entry.card is Node3D: _write_xp_3d(entry.card, entry)
				else: entry.card.get_node("RewardName").text=_xp_text(entry)
			active.erase(entry)
			active.push_front(entry)
			return
	_push({"name":title,"amount":amount,"player":player_name,"kind":"xp","age":0.0,"left":LIFE})

func _xp_text(entry: Dictionary) -> String:
	return "%s  +%s XP" % [entry.name,preload("res://core/player_progression.gd").number(int(entry.amount))]

func _three_d() -> bool:
	return lucha != null and is_instance_valid(lucha) and lucha.get("cam") != null \
		and LuchaKit.kit_model_exists("reward_card") and LuchaKit.kit_model_exists("xp_notice")


func _ensure_layer() -> void:
	if _layer != null and is_instance_valid(_layer):
		return
	_layer = Node3D.new()
	_layer.name = "RewardNotices3D"
	_layer.add_to_group(LuchaUI.UI_ROOT)
	_layer.position = Vector3(0, 0, -LuchaUI.MENU_DIST)
	_layer.scale = Vector3.ONE * LuchaUI.UI_SCALE
	(lucha.get("cam") as Node3D).add_child(_layer)


func _capacity() -> int:
	if _three_d():
		return 3
	return clampi(int((get_viewport_rect().size.y-72.0)/(104.0*_scale_factor())),1,3)

func _scale_factor() -> float:
	return clampf((get_viewport_rect().size.x-72.0)/584.0,.25,1.0)

func _push(entry: Dictionary) -> void:
	while active.size()>=_capacity(): _retire_oldest()
	active.push_front(entry)
	showing=true

func _retire_oldest() -> void:
	# At most one outgoing card, even during a burst of simultaneous awards.
	if outgoing.has("card"): outgoing.card.queue_free()
	outgoing.clear()
	var entry: Dictionary=active.pop_back()
	if not entry.has("card"): return
	outgoing=entry
	outgoing.left=EXIT_FADE
	if entry.card is Node3D:
		outgoing.x0=(entry.card as Node3D).position.x  # it slides out from where it is
		return
	outgoing.alpha=entry.card.modulate.a
	entry.card.position=Vector2(36,36+_capacity()*104*_scale_factor())

func _mount(entry: Dictionary) -> void:
	if _three_d():
		_ensure_layer()
		entry.card=_make_card_3d(entry)
		_layer.add_child(entry.card)
		return
	card=make_card(entry.name,entry.rarity,entry.player) if entry.kind=="loot" else _make_xp_card(entry)
	entry.card=card
	add_child(card)
	card.position=Vector2(36,36)
	card.size=Vector2(584,92)
	card.modulate.a=0.0

func _make_xp_card(entry: Dictionary) -> Control:
	var panel:=Control.new()
	panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var text:=_label(_xp_text(entry),_xp_font,27)
	text.name="RewardName"
	text.position=Vector2(0,28)
	text.size=Vector2(584,64)
	text.add_theme_color_override("font_color",LuchaKit.CREAM)
	text.add_theme_constant_override("outline_size",7)
	text.add_theme_color_override("font_outline_color",LuchaKit.INK)
	panel.add_child(text)
	return panel

func _process(dt: float) -> void:
	if (_layer != null and is_instance_valid(_layer)) or _three_d():
		_process_3d(dt)
		return
	while active.size()>_capacity(): _retire_oldest()
	for i in range(active.size()-1,-1,-1):
		var entry: Dictionary=active[i]
		entry.age=float(entry.age)+dt
		entry.left=float(entry.left)-dt
		if float(entry.left)<=0:
			if entry.has("card"): entry.card.queue_free()
			active.remove_at(i)
	if outgoing.has("card"):
		outgoing.left=float(outgoing.left)-dt
		outgoing.card.modulate.a=float(outgoing.alpha)*maxf(0.0,float(outgoing.left)/EXIT_FADE)
		if float(outgoing.left)<=0.0:
			outgoing.card.queue_free()
			outgoing.clear()
	var factor:=_scale_factor()
	for i in active.size():
		var entry: Dictionary=active[i]
		if not entry.has("card"): _mount(entry)
		var node: Control=entry.card
		node.scale=Vector2.ONE*factor
		node.position=Vector2(36,36+i*104*factor)
		node.modulate.a=minf(clampf(float(entry.age)/.2,0,1),clampf(float(entry.left)/.4,0,1))
	showing=not active.is_empty() or not outgoing.is_empty()

static func make_card(reward_name: String, rarity: int, player_name := "") -> Control:
	var tier := clampi(rarity, 0, 4)
	var panel := Control.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_meta("reward_rarity", tier)
	panel.set_meta("glow_radius", RADII[tier])
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Arial"])
	font.font_weight = 700
	# Render a padded glyph mask so the aura can extend beyond font-outline limits.
	var mask := SubViewport.new()
	mask.name = "GlowMask"
	mask.transparent_bg = true
	mask.disable_3d = true
	mask.size = Vector2i(664, 172)
	mask.render_target_update_mode = SubViewport.UPDATE_ONCE
	panel.add_child(mask)
	var mask_text := _label(reward_name, font, 30)
	mask_text.position = Vector2(40, 68)
	mask_text.size = Vector2(584, 64)
	mask_text.add_theme_color_override("font_color", Color.WHITE)
	mask.add_child(mask_text)
	var glow := TextureRect.new()
	glow.name = "RewardGlow"
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.texture = mask.get_texture()
	glow.position = Vector2(-40, -40)
	glow.size = Vector2(664, 172)
	var shader := Shader.new()
	shader.code = """shader_type canvas_item;
render_mode unshaded;
uniform vec4 glow_color : source_color = vec4(1.0);
uniform float radius = 12.0;
uniform float strength = 3.0;
uniform vec2 axis = vec2(0.0,1.0);
varying vec4 item_tint;
void vertex() { item_tint = COLOR; }
void fragment() {
 float haze = 0.0;
 float total = 0.0;
 for (int i=-16; i<=16; i++) {
  float p=float(i)/16.0;
  float weight=exp(-p*p*3.0);
  haze += texture(TEXTURE,UV+axis*TEXTURE_PIXEL_SIZE*radius*p).a*weight;
  total += weight;
 }
 COLOR=vec4(glow_color.rgb,clamp(haze/total*strength,0.0,0.95))*item_tint;
}
"""
	var horizontal := SubViewport.new()
	horizontal.name = "HorizontalGlow"
	horizontal.transparent_bg = true
	horizontal.disable_3d = true
	horizontal.size = mask.size
	horizontal.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	panel.add_child(horizontal)
	var pass_rect := TextureRect.new()
	pass_rect.texture = mask.get_texture()
	pass_rect.size = Vector2(mask.size)
	var pass_material := ShaderMaterial.new()
	pass_material.shader = shader
	pass_material.set_shader_parameter("axis", Vector2(1, 0))
	pass_material.set_shader_parameter("radius", float(RADII[tier]))
	pass_material.set_shader_parameter("strength", 1.0)
	pass_rect.material = pass_material
	horizontal.add_child(pass_rect)
	glow.texture = horizontal.get_texture()
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("glow_color", COLORS[tier])
	material.set_shader_parameter("radius", float(RADII[tier]))
	material.set_shader_parameter("strength", 3.0 + tier * 0.8)
	glow.material = material
	panel.add_child(glow)
	var text := _label(reward_name, font, 30)
	text.name = "RewardName"
	text.add_theme_constant_override("outline_size", 1)
	text.add_theme_color_override("font_outline_color", Color("31313c"))
	text.add_theme_color_override("font_color", COLORS[tier])
	panel.add_child(text)
	text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	text.offset_top = 28
	var heading := _label("UNLOCKED" if player_name.is_empty() else player_name + " â€” UNLOCKED", font, 16)
	heading.add_theme_color_override("font_color", Color("dddddd"))
	heading.add_theme_constant_override("outline_size", 3)
	heading.add_theme_color_override("font_outline_color", Color("242430"))
	panel.add_child(heading)
	heading.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	heading.offset_bottom = 28
	return panel

static func _label(value: String, font: Font, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("outline_size", 0)
	return label


# ---------------------------------------------------------------- the kit cards (3D)

## The stack, top left: newest at the top, each sliding in, out, and up as others go.
func _process_3d(dt: float) -> void:
	while active.size() > _capacity(): _retire_oldest()
	for i in range(active.size() - 1, -1, -1):
		var entry: Dictionary = active[i]
		entry.age = float(entry.age) + dt
		entry.left = float(entry.left) - dt
		if float(entry.left) <= 0:
			if entry.has("card"): entry.card.queue_free()
			active.remove_at(i)
	if outgoing.has("card"):
		outgoing.left = float(outgoing.left) - dt
		var gone: float = 1.0 - maxf(0.0, float(outgoing.left)) / EXIT_FADE
		var node: Node3D = outgoing.card
		node.position.x = float(outgoing.get("x0", node.position.x)) - gone * gone * _slide(node)
		_align_rarity_gem(node)
		_tick_puff(node, dt)
		if float(outgoing.left) <= 0.0:
			node.queue_free()
			outgoing.clear()
	var hw := 6.79
	var hh := 3.82
	if lucha != null and is_instance_valid(lucha):
		hw = float(lucha.get("virtual_half_w"))
		hh = float(lucha.get("virtual_half_h"))
	var top := hh - EDGE_TOP
	for entry in active:
		if not entry.has("card"): _mount(entry)
		var node: Node3D = entry.card
		var step: float = node.get_meta("step")
		var home_x := -hw + EDGE + float(node.get_meta("left"))
		var home_y := top - float(node.get_meta("top"))
		top -= step
		var t := clampf(float(entry.age) / SLIDE_IN, 0.0, 1.0)
		var c1 := 1.0  # a small overshoot
		var arrive := 1.0 + (c1 + 1.0) * pow(t - 1.0, 3) + c1 * pow(t - 1.0, 2)
		var leave := clampf(1.0 - float(entry.left) / EXIT_FADE, 0.0, 1.0)
		node.position.x = home_x - (1.0 - arrive) * _slide(node) - leave * leave * _slide(node)
		if not node.get_meta("placed", false):
			node.position.y = home_y
			node.set_meta("placed", true)
		else:
			node.position.y += (home_y - node.position.y) * minf(1.0, dt * 14.0)
		_align_rarity_gem(node)
		_tick_puff(node, dt)
	showing = not active.is_empty() or not outgoing.is_empty()


## How far a notice travels to be off the left edge.
func _slide(node: Node3D) -> float:
	return float(node.get_meta("width")) + EDGE + .4


func _make_card_3d(entry: Dictionary) -> Node3D:
	var loot: bool = entry.kind == "loot"
	var node := Node3D.new()
	node.name = "RewardCard" if loot else "XpNotice"
	var model := LuchaKit.kit_model("reward_card" if loot else "xp_notice")
	node.add_child(model)
	node.scale = Vector3.ONE * CARD_SCALE
	# Its left edge (the gem's rosette, the star's ring), top and width, at CARD_SCALE.
	node.set_meta("left", (1.424 if loot else 1.22) * CARD_SCALE)
	node.set_meta("top", (.448 if loot else .30) * CARD_SCALE)
	node.set_meta("width", (2.744 if loot else 2.72) * CARD_SCALE)
	node.set_meta("step", CARD_STEP if loot else XP_STEP)
	if loot:
		var tier: int = entry.rarity
		var colour: Color = COLORS[tier]
		var gem := model.find_child("reward_gem", true, false) as MeshInstance3D
		if gem != null:
			# A raised table, sloping crown facets and solid girdle, on the house atlas.
			gem.mesh = _rarity_gem(clampi(tier, 1, 4) + 2, colour)
			gem.position.x = -.98
			gem.position.y = 0
			gem.position.z = .175  # rear face .150, ahead of the setting at .122
			gem.material_override = CelPass.one()
			gem.set_instance_shader_parameter(&"swatch_uv", Vector2(-1, -1))

		var who: String = str(entry.player)
		var head := LuchaKit.text3d((who.to_upper() + ": UNLOCKED") if who != "" else "UNLOCKED", .12, LuchaKit.CREAM)
		head.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		head.position = Vector3(-.44, .165, .066)
		_fit(head, .12, 1.6)
		model.add_child(head)
		var title := LuchaKit.poster_text(str(entry.name), .17, colour)
		title.position = Vector3(.35, -.135, .078)
		for letter_layer in title.get_children():
			_fit(letter_layer as Label3D, .17, 1.6)
		LuchaKit.center_digits(title)
		model.add_child(title)
		if tier >= 3:
			_puff(node, colour)
	else:
		var what := LuchaKit.text3d("", .105, LuchaKit.CREAM)
		what.name = "XpWhat"
		what.position = Vector3(.07, 0, .06)
		model.add_child(what)
		var amount := LuchaKit.text3d("", .14, LuchaKit.RED)
		amount.name = "XpAmount"
		amount.position = Vector3(1.1, 0, .062)
		model.add_child(amount)
		_write_xp_3d(node, entry)
	LuchaUI.no_shadows(node)
	return node


## The XP notice's two faces: what was done, and its XP on the chip.
func _write_xp_3d(node: Node3D, entry: Dictionary) -> void:
	var what := node.find_child("XpWhat", true, false) as Label3D
	var amount := node.find_child("XpAmount", true, false) as Label3D
	if what == null or amount == null:
		return
	what.text = str(entry.name).to_upper()
	_fit(what, .095, 1.18)
	LuchaKit.center_digits(what)
	amount.text = "+%s XP" % preload("res://core/player_progression.gd").number(int(entry.amount))
	_fit(amount, .12, .56)
	LuchaKit.center_digits(amount)


## The label at its cap height, narrowed to fit `width` if its text runs longer.
static func _fit(lb: Label3D, cap: float, width: float) -> void:
	lb.pixel_size = cap / 96.0
	var font: Font = lb.font if lb.font != null else ThemeDB.fallback_font
	var w := font.get_string_size(lb.text, HORIZONTAL_ALIGNMENT_LEFT, -1, lb.font_size).x * lb.pixel_size
	if w > width:
		lb.pixel_size *= width / w


## For the two top rarities, a puff of kit stars in the rarity's colour as the card lands.
func _puff(node: Node3D, colour: Color) -> void:
	var stars: Array = []
	for i in 10:
		var star := LuchaKit.kit_model(BURST_STAR)
		if star == null:
			return
		LuchaKit.tint_part(star, BURST_STAR, colour)
		star.position = Vector3(-.98, 0, .2)  # from the gem
		node.add_child(star)
		var a := TAU * (i + randf() * .5) / 10.0
		stars.append({"node": star, "v": Vector3(cos(a), sin(a), 0) * randf_range(1.6, 2.6), "spin": randf_range(-8, 8), "age": -SLIDE_IN})
	node.set_meta("puff", stars)


func _tick_puff(node: Node3D, dt: float) -> void:
	if not node.has_meta("puff"):
		return
	var stars: Array = node.get_meta("puff")
	for st in stars:
		if not is_instance_valid(st.node):
			continue
		var star: Node3D = st.node
		st.age = float(st.age) + dt
		star.visible = float(st.age) >= 0.0
		if float(st.age) < 0.0:
			continue
		var life := float(st.age) / .7
		star.position += (st.v as Vector3) * dt
		st.v = (st.v as Vector3) * exp(-3.0 * dt) + Vector3(0, -2.0 * dt, 0)
		star.rotation.z += float(st.spin) * dt
		star.scale = Vector3.ONE * maxf(0.0, 1.0 - life)  # the re-cut star is twice the old
		if life >= 1.0:
			star.queue_free()
	if stars.all(func(st): return not is_instance_valid(st.node)):
		node.remove_meta("puff")


## Faceted star-cut gem: every triangle uses one matte atlas swatch.
static func _rarity_gem(points: int, colour: Color) -> ArrayMesh:
	var ring := PackedVector2Array()
	for i in points * 2:
		var angle := PI * .5 + i * TAU / (points * 2)
		var inner := .085 if points == 3 else .12
		var radius := .275 if i % 2 == 0 else inner
		ring.append(Vector2(cos(angle), sin(angle)) * radius)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var top_colour := colour.lightened(.22)
	var tris := Geometry2D.triangulate_polygon(ring)
	for k in range(0, tris.size(), 3):
		var a := ring[tris[k]] * .55
		var b := ring[tris[k + 1]] * .55
		var c := ring[tris[k + 2]] * .55
		_gem_triangle(st, Vector3(a.x,a.y,.09), Vector3(b.x,b.y,.09), Vector3(c.x,c.y,.09), top_colour)
		var ba := ring[tris[k]]
		var bb := ring[tris[k + 1]]
		var bc := ring[tris[k + 2]]
		_gem_triangle(st, Vector3(bc.x,bc.y,-.025), Vector3(bb.x,bb.y,-.025), Vector3(ba.x,ba.y,-.025), colour.darkened(.35))
	for i in ring.size():
		var a := ring[i]
		var b := ring[(i + 1) % ring.size()]
		var aa := a * .55
		var bb := b * .55
		var face_colour := colour.lightened(.38) if (a + b).y > .05 else colour.darkened(.22)
		if (a + b).x > .1:
			face_colour = colour.darkened(.1)
		var v0 := Vector3(a.x,a.y,0)
		var v1 := Vector3(b.x,b.y,0)
		var v2 := Vector3(bb.x,bb.y,.09)
		var v3 := Vector3(aa.x,aa.y,.09)
		_gem_triangle(st,v0,v1,v2,face_colour)
		_gem_triangle(st,v0,v2,v3,face_colour)
		_gem_triangle(st,Vector3(a.x,a.y,-.025),Vector3(b.x,b.y,-.025),v1,colour.darkened(.35))
		_gem_triangle(st,Vector3(a.x,a.y,-.025),v1,v0,colour.darkened(.35))
	st.set_material(CelPass.one())
	return st.commit()


static func _gem_triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, colour: Color) -> void:
	st.set_normal((b-a).cross(c-a).normalized())
	st.set_uv(AtlasPalette.matte_uv(colour))
	# Godot front faces use clockwise winding; normals remain outward.
	st.add_vertex(a)
	st.add_vertex(c)
	st.add_vertex(b)


## Project the star's tip circle concentrically onto the setting's front plane.
## Keep its depth: compensate perspective in XY rather than burying the gem.
func _align_rarity_gem(card: Node3D) -> void:
	var gem := card.find_child("reward_gem", true, false) as MeshInstance3D
	if gem == null or lucha == null:
		return
	var camera := lucha.get("cam") as Camera3D
	if camera == null:
		return
	var model := gem.get_parent() as Node3D
	var circle := camera.to_local(model.to_global(Vector3(-.98, 0, .122)))
	var tips := camera.to_local(model.to_global(Vector3(-.98, 0, .175)))
	var ratio := tips.z / circle.z if camera.projection == Camera3D.PROJECTION_PERSPECTIVE else 1.0
	var aligned := Vector3(circle.x * ratio, circle.y * ratio, tips.z)
	gem.position = model.to_local(camera.to_global(aligned))
	gem.scale = Vector3(ratio, ratio, 1)
