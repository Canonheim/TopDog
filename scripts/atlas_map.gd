## THE COLOUR ATLAS'S MAP for any script (atlas/ATLAS.md): a named colour's UV, a section's
## spot, what a UV is. Reads palette/house_atlas_map.json once. UVs here are Godot's (and glTF's): u = (x +
## 0.5) / size across, v = (y + 0.5) / size DOWN the image -- the map's own "uv" field is the bottom-up convention the
## Maya tool shows, so it is not used.
##   const AtlasMap := preload("res://scripts/atlas_map.gd")
##   AtlasMap.uv("brass")                 -> the named cell's centre
##   AtlasMap.section_uv("GLOW HOT", x, y) -> the matte block's pixel (x, y) moved into a section
##   AtlasMap.named("black_iron")         -> the cell's row ({col, row, srgb, rgb_linear, family, theme, ...})
extends RefCounted

const MAP_PATH := "res://palette/house_atlas_map.json"

static var _map: Dictionary = {}


static func data() -> Dictionary:
	if _map.is_empty():
		var txt := FileAccess.get_file_as_string(MAP_PATH)
		var parsed = JSON.parse_string(txt)
		if parsed is Dictionary:
			_map = parsed
	return _map


static func size() -> int:
	return int(data().get("size", 2048))


static func named(colour: String) -> Dictionary:
	return (data().get("cells", {}) as Dictionary).get(colour, {})


## The centre of a named cell, as a mesh's UV (Vector2.ZERO and an error for a name the map does not hold).
static func uv(colour: String) -> Vector2:
	var c := named(colour)
	if c.is_empty():
		push_error("THE COLOUR ATLAS: no named colour '%s'" % colour)
		return Vector2.ZERO
	var cell := int(data().get("cell", 32))
	return pixel_uv(int(c.col) * cell + cell / 2, int(c.row) * cell + cell / 2)


## A pixel's centre as a UV.
static func pixel_uv(x: int, y: int) -> Vector2:
	var s := float(size())
	return Vector2((x + 0.5) / s, (y + 0.5) / s)


## The same spot as the MATTE section's pixel (x, y) in another section (every section repeats the block).
static func section_uv(section: String, x: int, y: int) -> Vector2:
	var y0 := -1
	var m0 := 0
	for s in data().get("sections", []):
		if str(s.name) == "MATTE":
			m0 = int(s.y[0])
		if str(s.name) == section:
			y0 = int(s.y[0])
	if y0 < 0:
		push_error("THE COLOUR ATLAS: no section '%s'" % section)
		return Vector2.ZERO
	return pixel_uv(x, y0 + (y - m0))


## The section a UV falls in ("" off every section: a named cell or a separator).
static func section_of(at: Vector2) -> String:
	var y := int(at.y * size())
	for s in data().get("sections", []):
		if y >= int(s.y[0]) and y < int(s.y[1]):
			return str(s.name)
	return ""
