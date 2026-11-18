extends RefCounted
## Lossless offline copies of expensive approved procedural meshes. Geometry is
## fingerprinted against the original builders by tests/bake_effect_meshes.gd.
static var meshes := {}
static func path_for(effect: String, index: int) -> String:
	return "res://kit/effects/prepared/%s_%02d.res" % [effect,index]
static func get_mesh(effect: String, index: int) -> ArrayMesh:
	var path := path_for(effect,index)
	if meshes.has(path): return meshes[path]
	if not ResourceLoader.exists(path): return null  # Authoring fallback, audit fails if missing.
	var mesh := load(path) as ArrayMesh
	if mesh == null: return null
	for surface in mesh.get_surface_count(): mesh.surface_set_material(surface,CelPass.one())
	meshes[path] = mesh
	return mesh
