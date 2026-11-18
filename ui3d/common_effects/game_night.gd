extends RefCounted
const GROUP = preload("res://ui3d/common_effects/group3/effect.gd")
static var meshes: Array = []
static func prepare_unit(index: int) -> void:
	if index == 0: CelPass.one()
	else: GROUP.prepare_variant("game_night",index-1)
	meshes = GROUP.effect_meshes("game_night")
static func burst(camera: Node3D) -> Node3D:
	var result: Node3D = GROUP.burst(camera,"game_night")
	meshes = GROUP.effect_meshes("game_night")
	return result
