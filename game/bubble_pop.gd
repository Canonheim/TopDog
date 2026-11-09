extends CPUParticles3D
## One quick spray at the bubble's last position when the chair is collected.

func _ready() -> void:
	name = "BubblePop"
	emitting = false
	one_shot = true
	amount = 32
	lifetime = 0.28
	explosiveness = 1.0
	randomness = 0.35
	local_coords = false
	emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE_SURFACE
	emission_sphere_radius = 0.55
	direction = Vector3.UP
	spread = 180.0
	initial_velocity_min = 0.7
	initial_velocity_max = 1.8
	gravity = Vector3(0, -0.8, 0)
	scale_amount_min = 0.6
	scale_amount_max = 1.3
	var fade := Gradient.new()
	fade.set_color(0, Color(0.85, 0.97, 1.0, 0.95))
	fade.set_color(1, Color(0.85, 0.97, 1.0, 0.0))
	color_ramp = fade
	var shrink := Curve.new()
	shrink.add_point(Vector2(0, 1))
	shrink.add_point(Vector2(1, 0.15))
	scale_amount_curve = shrink
	var droplet := SphereMesh.new()
	droplet.radius = 0.018
	droplet.height = 0.036
	droplet.radial_segments = 8
	droplet.rings = 4
	mesh = droplet
	var surface := StandardMaterial3D.new()
	surface.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	surface.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	surface.vertex_color_use_as_albedo = true
	material_override = surface
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	finished.connect(queue_free)
	# The pickup supplies the world transform immediately after adding this node.
	call_deferred("restart")
