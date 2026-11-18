extends Node
const Effect = preload("res://ui3d/lightning_effect.gd")
const Layout = preload("res://climber/body_layout.gd")
func _ready() -> void:
	var folder := "res://kit/effects/lightning_vertices"
	DirAccess.make_dir_recursive_absolute(folder)
	var count := 0
	var total_bytes := 0
	for index in 32:
		var scene: PackedScene = Wardrobe.PUG if index<16 else Wardrobe.SPIRAL
		var name: String = Layout.PIECES[Layout.ORDER[index%16]].mesh
		var state := scene.get_state()
		var data := {}
		for node in state.get_node_count():
			var path := str(state.get_node_path(node))
			if not name in path.split("/"): continue
			for prop in state.get_node_property_count(node):
				if state.get_node_property_name(node,prop)!="mesh": continue
				var mesh = state.get_node_property_value(node,prop)
				if not mesh is Mesh: continue
				var points := PackedVector3Array()
				for surface in mesh.get_surface_count(): points.append_array(mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX])
				data[path]=points
				count += 1
				total_bytes += points.size()*12
		assert(not data.is_empty())
		var file := FileAccess.open(folder+"/part_%02d.bin" % index,FileAccess.WRITE)
		file.store_var(data)
		file.close()
	print("BAKED_LIGHTNING_VERTICES meshes=",count," bytes=",total_bytes)
	for index in 6:
		var mesh := Effect._bolt_mesh(index)
		assert(ResourceSaver.save(mesh,Effect.mesh_path(index))==OK)
	print("BAKED_LIGHTNING_MESHES 6")
	get_tree().quit()
