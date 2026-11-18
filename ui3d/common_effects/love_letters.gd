extends RefCounted
const GROUP = preload("res://ui3d/common_effects/group3/effect.gd")
static var meshes: Array = []
static func prepare_unit(index: int) -> void:
	if index == 0: CelPass.one()
	else: GROUP.prepare_variant("love_letters",index-1)
	meshes = GROUP.effect_meshes("love_letters")
static func burst(camera: Node3D) -> Node3D:
	var result: Node3D = GROUP.burst(camera,"love_letters")
	meshes = GROUP.effect_meshes("love_letters")
	return result
