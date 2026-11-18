extends RefCounted
## Keep common camera bursts centered at the original Pickles launch height.
## Translate the entire trajectory, preserving authored velocities and spread.
const CENTER_Y := 0.4
static func align(root: Node3D, authored_center_y: float) -> void:
	root.position.y = CENTER_Y - authored_center_y
