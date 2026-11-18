extends RefCounted
const GROUP = preload("res://ui3d/common_effects/group3/effect.gd")
static var meshes: Array = []
static func prepare_unit(index: int) -> void:
	if index == 0: CelPass.one()
	else: GROUP.prepare_variant("music_notes",index-1)
	meshes = GROUP.effect_meshes("music_notes")
static func burst(camera: Node3D) -> Node3D:
	var result: Node3D = GROUP.burst(camera,"music_notes")
	meshes = GROUP.effect_meshes("music_notes")
	return result
