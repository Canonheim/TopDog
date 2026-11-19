extends Node
## SMOOTH MOTION (Parker 11-19: "when on the minecart and some other times when moving, the whole
## world is super weirdly shaky, it's hard to describe but the camera does not feel smooth at these
## parts. It's nauseating ... it might be all through the game").
##
## Physics runs 120 times a second (project physics_ticks_per_second). A screen at 144 or 165 Hz
## drew every moving body where its last tick left it, so the climber, the cart, the ropes and the
## chair moved five frames and stood still the sixth, a shudder about 24 times a second against
## everything else; the eye on the climber read it as the world shaking. Godot's physics
## interpolation draws a body between its last two ticks by how far into the next one the frame
## falls (Engine.get_physics_interpolation_fraction), up to one tick (8 ms) behind.
##
## Only the bodies physics moves (RigidBody3D, AnimatableBody3D, CharacterBody3D) and what hangs off
## them are drawn this way. Everything else (cameras, the 3D menus, effects and scenery moved every
## frame) keeps its mode OFF from the root and is drawn as it was: a node moved every frame must not
## be interpolated, or it stutters. The Peak's camera reads the climber the same way (main.gd
## _physics_process), so the two agree.
##
## Feel "smooth_motion" (the F1 panel) turns it off, to compare.


func _ready() -> void:
	get_tree().root.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	get_tree().node_added.connect(_on_node_added)
	_sweep(get_tree().root)
	_apply()


func _on_node_added(n: Node) -> void:
	if n is RigidBody3D or n is AnimatableBody3D or n is CharacterBody3D:
		n.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON


func _sweep(n: Node) -> void:
	_on_node_added(n)
	for ch in n.get_children():
		_sweep(ch)


func _process(_delta: float) -> void:
	_apply()


func _apply() -> void:
	var on := Feel.get_k("smooth_motion") >= 0.5
	if get_tree().physics_interpolation != on:
		get_tree().physics_interpolation = on
