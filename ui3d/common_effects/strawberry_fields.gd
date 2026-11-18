extends RefCounted
const GROUP = preload("res://ui3d/common_effects/group2/effect.gd")
static var meshes: Array = []
static func prepare_unit(index: int) -> void:
	if index == 0: CelPass.one()
	else: GROUP.prepare_variant("strawberry_fields",index-1)
	meshes = GROUP.effect_meshes("strawberry_fields")
static func burst(camera: Node3D) -> Node3D:
	var result: Node3D = GROUP.burst(camera,"strawberry_fields")
	meshes = GROUP.effect_meshes("strawberry_fields")
	return result
