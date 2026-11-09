// THE BUBBLE'S INK (Parker 11-09): an inverse hull for the see-through chair bubble.
// A sphere a little bigger than the bubble, drawn back faces only, flat ink. Seen through
// the clear bubble its inside would blacken the chair, so every pixel whose sight line
// passes through the bubble itself is cut: only the rim ring is left.
shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled;

uniform vec4 ink : source_color = vec4(0.1, 0.07, 0.05, 1.0);
uniform float inner_radius = 0.67;  // the bubble's radius (model units)

void fragment() {
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 centre = NODE_POSITION_WORLD;
	float r = inner_radius * length(MODEL_MATRIX[0].xyz);
	bool ortho = PROJECTION_MATRIX[3][3] == 1.0;
	vec3 dir = ortho ? -INV_VIEW_MATRIX[2].xyz : normalize(world - CAMERA_POSITION_WORLD);
	vec3 to_c = centre - world;
	// distance from the bubble's centre to this pixel's sight line
	float miss = length(to_c - dir * dot(to_c, dir));
	if (miss < r) {
		discard;
	}
	ALBEDO = ink.rgb;
}
