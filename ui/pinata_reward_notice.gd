extends Control
## Three newest loot / XP notices; the displaced oldest fades away permanently.
const COLORS := [Color("ffffff"),Color("36dc70"),Color("398aff"),Color("ba54ff"),Color("ff3046")]
const RADII := [12,16,21,27,34]
const LIFE := 5.1
const EXIT_FADE := .25
var outgoing: Dictionary = {}
var active: Array[Dictionary] = []
var showing := false
var card: Control
var _xp_font: Font

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	process_mode=Node.PROCESS_MODE_ALWAYS
	_xp_font=load(LuchaKit.TITLE_FONT) if ResourceLoader.exists(LuchaKit.TITLE_FONT) else ThemeDB.fallback_font

func enqueue(reward_name: String, rarity: int, player_name := "") -> void:
	_push({"name":reward_name,"rarity":clampi(rarity,0,4),"player":player_name,"kind":"loot","age":0.0,"left":LIFE})

func enqueue_xp(title: String, amount: int, player_name := "") -> void:
	if amount<=0: return
	# Frequent airtime ticks update one notice, move it to the top and restart its lifetime.
	for entry in active:
		if title=="Upward airtime" and entry.kind=="xp" and entry.name==title and entry.player==player_name:
			entry.amount=int(entry.amount)+amount
			entry.left=LIFE
			if entry.has("card"): entry.card.get_node("RewardName").text=_xp_text(entry)
			active.erase(entry)
			active.push_front(entry)
			return
	_push({"name":title,"amount":amount,"player":player_name,"kind":"xp","age":0.0,"left":LIFE})

func _xp_text(entry: Dictionary) -> String:
	return "%s  +%s XP" % [entry.name,preload("res://core/player_progression.gd").number(int(entry.amount))]

func _capacity() -> int:
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
	outgoing.alpha=entry.card.modulate.a
	entry.card.position=Vector2(36,36+_capacity()*104*_scale_factor())

func _mount(entry: Dictionary) -> void:
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
	text.add_theme_color_override("font_color", Color("a8a8a8") if tier == 0 else Color.WHITE)
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
