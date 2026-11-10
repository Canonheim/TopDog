class_name AtlasPalette
extends RefCounted
## Flat colours sampled from existing matte cells; never paints over the atlas.
static var _cells: Array = []
static var _matches := {}

static func swatch(color: Color) -> Dictionary:
	var key := color.to_html(false)
	if _matches.has(key):
		return _matches[key]
	if _cells.is_empty():
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://palette/house_atlas_map.json"))
		var image := CelPass.ATLAS.get_image()
		for cell in data.cells.values():
			var x := int(cell.col) * 32 + 16
			var y := int(cell.row) * 32 + 16
			_cells.append({"color": image.get_pixel(x, y), "uv": Vector2((x + 0.5) / image.get_width(), (y + 0.5) / image.get_height())})
	var closest: Dictionary = _cells[0]
	var distance := INF
	for cell: Dictionary in _cells:
		var c: Color = cell.color
		var d := Vector3(c.r-color.r, c.g-color.g, c.b-color.b).length_squared()
		if d < distance:
			distance = d
			closest = cell
	_matches[key] = closest
	return closest

static func material(color: Color) -> ShaderMaterial:
	var m := CelPass.palette_material()
	m.set_shader_parameter("uv_scale", Vector2.ZERO)
	m.set_shader_parameter("uv_offset", swatch(color).uv)
	# Clothing and skin are matte, including colours also offered as metals.
	m.set_shader_parameter("surface_texture", null)
	return m

static func theme_tree(node: Node) -> void:
	if node is Label3D:
		node.modulate = swatch(node.modulate).color
	elif node is MeshInstance3D and node.mesh != null:
		for i in node.mesh.get_surface_count():
			var m := node.get_active_material(i) as ShaderMaterial
			if m != null and m.get_shader_parameter("base_texture") == null:
				var color: Variant = m.get_shader_parameter("color")
				node.set_surface_override_material(i, material(color if color is Color else Color.WHITE))
	for child in node.get_children():
		theme_tree(child)
