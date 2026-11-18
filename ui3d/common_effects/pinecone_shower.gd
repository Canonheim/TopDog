extends RefCounted
const GROUP = preload("res://ui3d/common_effects/group4/effect.gd")
static var meshes: Array = []
static func prepare_unit(index: int) -> void:
	if index == 0: CelPass.one()
	else: GROUP.prepare_variant("pinecone_shower",index-1)
	meshes = GROUP.effect_meshes("pinecone_shower")
static func burst(camera: Node3D) -> Node3D:
	var result: Node3D = GROUP.burst(camera,"pinecone_shower")
	meshes = GROUP.effect_meshes("pinecone_shower")
	return result
