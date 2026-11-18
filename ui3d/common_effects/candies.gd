extends RefCounted
const GROUP = preload("res://ui3d/common_effects/group1/effect.gd")
static var meshes: Array = []
static func prepare_unit(index: int) -> void:
	if index == 0: CelPass.one()
	else: GROUP.prepare_variant("candies",index-1)
	meshes = GROUP.effect_meshes("candies")
static func burst(camera: Node3D) -> Node3D:
	var result: Node3D = GROUP.burst(camera,"candies")
	meshes = GROUP.effect_meshes("candies")
	return result
