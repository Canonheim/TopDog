## THE CEL PASS: turn an imported scene into the house look.
##
##   CelPass.celify(root)            every StandardMaterial3D surface under root -> its cel twin (cached, shared)
##   CelPass.add_outline_pass(root)  the screen-space ink on root's WorldEnvironment (one per world)
##   CelPass.paint(thing, color)     THE ONE MATERIAL on a thing built from code, in that colour
##   CelPass.cel_material(color)     a material of its own (see-through and metal looks only)
##
## Call celify and add_outline_pass once per loaded map or scene (after the scene is in the tree). Imported GLBs
## arrive with StandardMaterial3D; the twin keeps the colour, texture and tiling, swaps the shader for
## shaders/cel/cel-shader-base.gdshader, and -- for a PALETTE material (the colour atlas) -- binds the ONE shared
## atlas and its two masks so the glow and the shine come from the sheet.
##
## THE PLASTIC LAW: the vendored shader's defaults ship a grey glint and a grey rim on everything, which made every
## wall and body look like plastic. _metal_specular runs on EVERY material: a non-metal gets a black glint (adds
## zero light) and no rim; a metal gets a glint tinted by its own colour, its breadth from roughness. Atlas models
## get their shine from the surface mask instead (THE SHINE NUMBERS, atlas/ATLAS.md).
class_name CelPass
extends RefCounted

const SHADER := preload("res://shaders/cel/cel-shader-base.gdshader")
const PALETTE_MATERIAL := "PALETTE"
const ATLAS_PATH := "res://palette/house_atlas.png"
const ATLAS := preload("res://palette/house_atlas.png")
const ATLAS_EMIT := preload("res://palette/house_atlas_emit.png")
const ATLAS_SURFACE := preload("res://palette/house_atlas_surface.png")
const OUTLINE_HOST := preload("res://shaders/cel/outline_compositor.gd")

# source StandardMaterial3D -> its cel twin (object key on purpose: a scene's materials are loader-cached
# resources, so the twin survives scene changes and identical walls keep sharing one material)
static var _twins := {}
static var _outline_fx: CompositorEffect = null
## Top Dog (Parker 11-07): "We don't want to use emissive right now for anything."
## Nothing self-lights: the atlas glow mask and glTF emissive are both ignored.
const NO_EMISSION := true


## Walk a scene and cel every opaque StandardMaterial3D surface. ShaderMaterials (already cel, particles, water)
## and transparent looks pass through untouched.
static func celify(root: Node) -> void:
	if root is MeshInstance3D:
		_cel_mesh(root as MeshInstance3D)
	for child in root.get_children():
		celify(child)


static func _cel_mesh(mi: MeshInstance3D) -> void:
	if mi.mesh == null:
		return
	for s in mi.mesh.get_surface_count():
		var std := mi.get_active_material(s) as StandardMaterial3D
		if std != null and std.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED:
			mi.set_surface_override_material(s, material_for(std, mi.mesh, s))


## StandardMaterial3D -> the equivalent cel ShaderMaterial (cached). Pass the mesh and surface when you have them: a
## mesh carrying a COLOR attribute (Blender vertex paint) lights `use_vertex_color` even when the importer forgot
## vertex_color_use_as_albedo -- safe on the shared twin, because meshes without COLOR_0 sample white.
static func material_for(src: StandardMaterial3D, mesh: Mesh = null, surface := 0) -> ShaderMaterial:
	var cel: ShaderMaterial = _twins.get(src)
	if cel == null:
		# A plain atlas material (every kit model's PALETTE: white, untiled, matte, no
		# vertex paint) IS the one material: 130 files used to make 130 identical twins.
		var plain_atlas := is_palette(src) and src.albedo_color.is_equal_approx(Color.WHITE) and src.metallic <= 0.0 \
				and src.uv1_scale.is_equal_approx(Vector3.ONE) and src.uv1_offset.is_zero_approx() \
				and not src.vertex_color_use_as_albedo and not _has_vertex_color(mesh, surface) and (not src.emission_enabled or NO_EMISSION)
		cel = one() if plain_atlas else _build_cel(src)
		_twins[src] = cel
	if cel == _one:
		return cel
	if _has_vertex_color(mesh, surface):
		cel.set_shader_parameter("use_vertex_color", true)
	return cel


## A material born cel, for call sites that build a look from a plain colour. metallic / roughness map onto the
## toon specular band (_metal_specular), never onto PBR.
## SHARED (the 11-10 sweep): one material per colour and finish, handed to everyone who
## asks. The plaza alone made about 1,200 identical-looking materials, one per stair,
## lamp and flower. Nobody may change a material this returns: to tint one piece,
## duplicate it first (LuchaKit.tint_part does).
static var _plain := {}
static var _plain_colors := {}  # a plain non-metal material -> its colour (unify reads it)
static var _one: ShaderMaterial = null


## THE ONE MATERIAL (Parker 11-10: "the whole game should be using one material, that's
## the benefit of the color atlas ... except maybe clear things"): the shared atlas and
## its masks, white, matte. Every kit model wears it by its UVs; everything built in code
## wears it through a per-instance atlas texel (paint). Never change it.
static func one() -> ShaderMaterial:
	if _one == null:
		_one = palette_material()
		_one.resource_name = "ONE"
	return _one


## A thing built in code (a box, a ball, a wall of bricks, a flat of sand), in one colour,
## on THE ONE MATERIAL: its colour is the nearest texel of the atlas's matte block (188,000
## colours: never more than about 3% off), handed over per instance. A see-through colour
## keeps a material of its own.
static func paint(thing: GeometryInstance3D, color: Color) -> void:
	if thing == null:
		return
	if color.a < 0.999:
		thing.material_override = cel_material(color)
		return
	thing.material_override = one()
	thing.set_instance_shader_parameter(&"swatch_uv", AtlasPalette.matte_uv(color))


## The same, by an atlas UV already in hand (the wardrobe's skins and suits).
static func paint_uv(thing: GeometryInstance3D, uv: Vector2) -> void:
	if thing == null:
		return
	thing.material_override = one()
	thing.set_instance_shader_parameter(&"swatch_uv", uv)


## A mesh of several one-colour surfaces (the paving's tones, the sand and the wet sand)
## onto THE ONE MATERIAL: each surface's vertices take its colour's atlas texel as their
## UV, and every surface wears the one material. Surfaces that aren't plain colours stay.
static func unify(mi: MeshInstance3D) -> void:
	var src := mi.mesh as ArrayMesh
	if src == null:
		return
	var out := ArrayMesh.new()
	var changed := false
	for si in src.get_surface_count():
		var m := src.surface_get_material(si)
		var arrays := src.surface_get_arrays(si)
		if m != null and _plain_colors.has(m):
			var n := (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
			var uvs := PackedVector2Array()
			uvs.resize(n)
			uvs.fill(AtlasPalette.matte_uv(_plain_colors[m]))
			arrays[Mesh.ARRAY_TEX_UV] = uvs
			changed = true
			out.add_surface_from_arrays(src.surface_get_primitive_type(si), arrays)
			out.surface_set_material(si, one())
		else:
			out.add_surface_from_arrays(src.surface_get_primitive_type(si), arrays)
			out.surface_set_material(si, m)
	if changed:
		mi.mesh = out


static func cel_material(color: Color, metallic := 0.0, roughness := 1.0) -> ShaderMaterial:
	var key := "%s|%.3f|%.3f" % [color.to_html(true), metallic, roughness]
	if _plain.has(key):
		return _plain[key]
	var cel := ShaderMaterial.new()
	cel.shader = SHADER
	cel.set_shader_parameter("color", color)
	_metal_specular(cel, color, metallic, roughness)
	_plain[key] = cel
	if metallic <= 0.0 and color.a >= 0.999:
		_plain_colors[cel] = color
	return cel


## A material born cel ON THE ATLAS: the one shared sheet and masks; colour it by UVs, not by `color`.
static func palette_material() -> ShaderMaterial:
	var cel := ShaderMaterial.new()
	cel.shader = SHADER
	cel.set_shader_parameter("color", Color.WHITE)
	cel.set_shader_parameter("base_texture", ATLAS)
	if not NO_EMISSION:
		cel.set_shader_parameter("emission_texture", ATLAS_EMIT)
	cel.set_shader_parameter("surface_texture", ATLAS_SURFACE)
	_metal_specular(cel, Color.WHITE, 0.0, 1.0)
	return cel


static func _has_vertex_color(mesh: Mesh, surface: int) -> bool:
	return mesh is ArrayMesh and ((mesh as ArrayMesh).surface_get_format(surface) & Mesh.ARRAY_FORMAT_COLOR) != 0


## The uncached build: the StandardMaterial3D properties the house uses, mapped onto the shader's uniforms.
static func _build_cel(src: StandardMaterial3D) -> ShaderMaterial:
	var cel := ShaderMaterial.new()
	cel.shader = SHADER
	cel.set_shader_parameter("color", src.albedo_color)
	if src.albedo_texture != null:
		cel.set_shader_parameter("base_texture", src.albedo_texture)
	cel.set_shader_parameter("uv_scale", Vector2(src.uv1_scale.x, src.uv1_scale.y))
	cel.set_shader_parameter("uv_offset", Vector2(src.uv1_offset.x, src.uv1_offset.y))
	if src.vertex_color_use_as_albedo:
		cel.set_shader_parameter("use_vertex_color", true)
	# a flat emissive factor (a per-colour file not yet on the atlas) self-lights its surface through `emission`;
	# the energy is glTF's emissive strength
	if src.emission_enabled and not NO_EMISSION:
		cel.set_shader_parameter("emission", src.emission)
		cel.set_shader_parameter("emission_energy", src.emission_energy_multiplier)
	# THE COLOUR ATLAS: a PALETTE material wears the ONE shared atlas, its glow and its shine (the masks)
	if is_palette(src):
		cel.set_shader_parameter("base_texture", ATLAS)
		if not NO_EMISSION:
			cel.set_shader_parameter("emission_texture", ATLAS_EMIT)
		cel.set_shader_parameter("surface_texture", ATLAS_SURFACE)
	# ALWAYS, never behind a metal gate: the shader defaults ship a grey glint and rim (THE PLASTIC LAW)
	_metal_specular(cel, src.albedo_color, src.metallic, src.roughness)
	return cel


## A material on the colour atlas: its base colour IS the project's atlas (an import that found it by uri), or it
## carries no base colour image and is named PALETTE (the law's one material).
static func is_palette(src: BaseMaterial3D) -> bool:
	if src == null:
		return false
	if src.albedo_texture != null:
		return src.albedo_texture.resource_path == ATLAS_PATH
	return src.resource_name == PALETTE_MATERIAL


## NO PBR METAL HERE (reflections stay off): metallic maps onto the toon SPECULAR band. Metal tints the glint with
## the albedo (gold glints gold, not white); roughness drives the band's breadth through `specular.a` (LOW = a tight
## pinpoint glint: the vendored gloss curve runs backwards from PBR). Non-metals get a black glint and no rim.
static func _metal_specular(cel: ShaderMaterial, albedo: Color, metallic: float, roughness: float) -> void:
	var glint := Color.BLACK.lerp(albedo, metallic)
	var breadth := lerpf(0.5, clampf(roughness, 0.05, 0.9), metallic)
	cel.set_shader_parameter("specular", Color(glint.r, glint.g, glint.b, breadth))
	cel.set_shader_parameter("fresnel", Color(0.0, 0.0, 0.0, 0.0))


## THE SCREEN-SPACE INK: one Compositor on the scene's WorldEnvironment running shaders/cel/outline_compositor.gd
## (the six-pass adaptive chain over the depth and normal buffers). It rides the VIEWPORT, so every camera that looks
## at the world inks the same edges; no per-material hulls. Appended, never replacing effects a scene already has.
## Headless-safe: the effect disables itself without a RenderingDevice (Forward+ only).
static func add_outline_pass(root: Node) -> void:
	for child in root.get_children():
		if child is WorldEnvironment:
			var we := child as WorldEnvironment
			if we.compositor == null:
				we.compositor = Compositor.new()
			_outline_fx = OUTLINE_HOST.new()
			var fx: Array = we.compositor.compositor_effects
			fx.append(_outline_fx)
			we.compositor.compositor_effects = fx
			return
	push_warning("CelPass.add_outline_pass: no WorldEnvironment under %s" % root.name)


## Ink in a SubViewport that runs its own World3D (a menu window): a compositor effect belongs to the world or camera
## that renders it, so such a camera gets its own instance. The line width scales to render height by itself.
static func add_viewport_outlines(cam: Camera3D) -> void:
	if cam == null or RenderingServer.get_rendering_device() == null:
		return
	var comp := Compositor.new()
	comp.compositor_effects = [OUTLINE_HOST.new()]
	cam.compositor = comp


## The live ink pass's final coverage ledger (an R8 texture), for a transparent surface such as water that must
## repaint the line on itself; null until a pass exists. Sample it at SCREEN_UV.
static func ink_texture() -> Texture2DRD:
	if _outline_fx == null or not _outline_fx.enabled:
		return null
	return _outline_fx.call("ink_texture")
