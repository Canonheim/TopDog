extends RefCounted
const GROUP = preload("res://ui3d/common_effects/group2/effect.gd")
static var meshes: Array = []
static func prepare_unit(index: int) -> void:
	if index == 0: CelPass.one()
	else: GROUP.prepare_variant("nuts_acorns",index-1)
	meshes = GROUP.effect_meshes("nuts_acorns")
static func burst(camera: Node3D) -> Node3D:
	var result: Node3D = GROUP.burst(camera,"nuts_acorns")
	meshes = GROUP.effect_meshes("nuts_acorns")
	return result
