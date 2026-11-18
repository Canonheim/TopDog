extends RefCounted
const GROUP = preload("res://ui3d/common_effects/group2/effect.gd")
static var meshes: Array = []
static func prepare_unit(index: int) -> void:
	if index == 0: CelPass.one()
	else: GROUP.prepare_variant("ice_cream_social",index-1)
	meshes = GROUP.effect_meshes("ice_cream_social")
static func burst(camera: Node3D) -> Node3D:
	var result: Node3D = GROUP.burst(camera,"ice_cream_social")
	meshes = GROUP.effect_meshes("ice_cream_social")
	return result
