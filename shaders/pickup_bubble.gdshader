shader_type spatial;
render_mode unshaded, cull_back;

void fragment() {
	vec3 n = normalize(NORMAL);
	float rim = pow(1.0 - clamp(dot(n, normalize(VIEW)), 0.0, 1.0), 2.3);
	// A soft, elongated studio reflection and a smaller glint curve over the shell.
	vec2 reflection = (n.xy - vec2(-0.40, 0.57)) / vec2(0.23, 0.095);
	reflection.y += 0.65 * reflection.x;
	float shine = 1.0 - smoothstep(0.52, 1.0, length(reflection));
	float glint = 1.0 - smoothstep(0.025, 0.065, distance(n.xy, vec2(-0.15, 0.57)));
	float highlight = max(shine, glint);
	ALBEDO = mix(vec3(0.34, 0.73, 0.97), vec3(0.95, 0.99, 1.0), max(highlight, 0.45 * rim));
	ALPHA = clamp(0.075 + 0.54 * rim + 0.73 * highlight, 0.0, 1.0);
}
