extends RefCounted
const GROUP = preload("res://ui3d/common_effects/group4/effect.gd")
static var meshes: Array = []
static func prepare_unit(index: int) -> void:
	if index == 0: CelPass.one()
	else: GROUP.prepare_variant("seashell_shuffle",index-1)
	meshes = GROUP.effect_meshes("seashell_shuffle")
static func burst(camera: Node3D) -> Node3D:
	var result: Node3D = GROUP.burst(camera,"seashell_shuffle")
	meshes = GROUP.effect_meshes("seashell_shuffle")
	return result
