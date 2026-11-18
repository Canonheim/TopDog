extends RefCounted
const GROUP = preload("res://ui3d/common_effects/group1/effect.gd")
static var meshes: Array = []
static func prepare_unit(index: int) -> void:
	if index == 0: CelPass.one()
	else: GROUP.prepare_variant("pretzel_twist",index-1)
	meshes = GROUP.effect_meshes("pretzel_twist")
static func burst(camera: Node3D) -> Node3D:
	var result: Node3D = GROUP.burst(camera,"pretzel_twist")
	meshes = GROUP.effect_meshes("pretzel_twist")
	return result
