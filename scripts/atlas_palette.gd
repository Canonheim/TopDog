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

## THE MATTE BLOCK (the atlas's top 160 rows: 188,000 colours): the UV of the texel
## nearest a colour, for CelPass.paint. Any colour the code asks for is within about 3%
## of one. The block is read once into a 32 x 32 x 32 grid of buckets (every other
## texel: its neighbours differ by less than the eye can tell), and each colour is
## looked up once.
static var _grid := {}
static var _matte_uvs := {}
static var _atlas_w := 2048
static var _atlas_h := 2048
const MATTE_ROWS := 160


static func matte_uv(color: Color) -> Vector2:
	var key := color.to_rgba32()
	if _matte_uvs.has(key):
		return _matte_uvs[key]
	if _grid.is_empty():
		var image := CelPass.ATLAS.get_image()
		if image.is_compressed():
			image.decompress()
		image.convert(Image.FORMAT_RGB8)
		_atlas_w = image.get_width()
		_atlas_h = image.get_height()
		var data := image.get_data()
		for y in range(3, MATTE_ROWS - 3, 2):
			var row := y * _atlas_w * 3
			for x in range(1, _atlas_w, 2):
				var i := row + x * 3
				var bucket := ((data[i] >> 3) << 10) | ((data[i + 1] >> 3) << 5) | (data[i + 2] >> 3)
				var packed := (y << 12) | x
				if _grid.has(bucket):
					(_grid[bucket] as Array).append(packed)
					(_grid[bucket] as Array).append((data[i] << 16) | (data[i + 1] << 8) | data[i + 2])
				else:
					_grid[bucket] = [packed, (data[i] << 16) | (data[i + 1] << 8) | data[i + 2]]
	var r := int(round(clampf(color.r, 0.0, 1.0) * 255.0))
	var g := int(round(clampf(color.g, 0.0, 1.0) * 255.0))
	var b := int(round(clampf(color.b, 0.0, 1.0) * 255.0))
	var best := -1
	var best_d := 1 << 30
	var reach := 1
	while best < 0 or reach <= 2:  # the buckets around, then one ring more (the nearest can sit next door)
		for br in range(maxi(0, (r >> 3) - reach), mini(31, (r >> 3) + reach) + 1):
			for bg in range(maxi(0, (g >> 3) - reach), mini(31, (g >> 3) + reach) + 1):
				for bb in range(maxi(0, (b >> 3) - reach), mini(31, (b >> 3) + reach) + 1):
					var cells = _grid.get((br << 10) | (bg << 5) | bb)
					if cells == null:
						continue
					var list: Array = cells
					for k in range(0, list.size(), 2):
						var c: int = list[k + 1]
						var dr := ((c >> 16) & 255) - r
						var dg := ((c >> 8) & 255) - g
						var db := (c & 255) - b
						var d := dr * dr + dg * dg + db * db
						if d < best_d:
							best_d = d
							best = list[k]
		reach += 1
		if reach > 32:
			break
	var uv: Vector2 = Vector2(((best & 4095) + 0.5) / _atlas_w, ((best >> 12) + 0.5) / _atlas_h) if best >= 0 else (swatch(color).uv as Vector2)
	_matte_uvs[key] = uv
	return uv


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
				if node.mesh.get_surface_count() == 1:
					CelPass.paint_uv(node, swatch(color if color is Color else Color.WHITE).uv)  # THE ONE MATERIAL
				else:
					node.set_surface_override_material(i, material(color if color is Color else Color.WHITE))
	for child in node.get_children():
		theme_tree(child)
