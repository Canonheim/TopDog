// THE WHIRLPOOL'S FUNNEL (MINE_PASS F-C11, 11-18): the flume's water turning down into the drain at its eye. The
// funnel mesh (peak_zones _whirl_mesh) dips from the surface at `radius` to `depth` at the middle; this paints it:
// the water's colour darkening toward the middle, three flat foam arms turning on a slow spiral, a foam ring near the
// rim, and the eye dark (the grating's hole seen through the water). Opaque and flat-lit, as the water's surface.
shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec4 shallow_color : source_color = vec4(0.27, 0.72, 0.83, 1.0);
uniform vec4 deep_color : source_color = vec4(0.11, 0.44, 0.74, 1.0);
uniform vec4 foam_color : source_color = vec4(0.86, 0.94, 0.97, 1.0);
uniform vec4 eye_color : source_color = vec4(0.03, 0.05, 0.07, 1.0);
uniform float radius = 1.13;  // m: where it meets the flat surface
uniform float eye = 0.44;     // m: the dark eye
uniform float spin = 0.25;    // turns a second

varying vec2 lp;

void vertex() {
	lp = VERTEX.xz;
}

void fragment() {
	float r = length(lp);
	float a = atan(lp.y, lp.x);
	float s = clamp(r / radius, 0.0, 1.0);
	vec3 col = mix(deep_color.rgb * 0.45, shallow_color.rgb, smoothstep(0.15, 1.0, s));
	// three arms on a log spiral, drawn in toward the eye as they turn
	float arm = sin(3.0 * a + 5.5 * log(max(r, 0.05)) + TIME * spin * 6.2831853);
	float foam = smoothstep(0.6, 0.95, arm) * smoothstep(eye * 1.05, eye * 1.7, r) * (1.0 - smoothstep(radius * 0.8, radius * 0.98, r));
	// the ring where the surface starts to go down
	foam = max(foam, (1.0 - smoothstep(0.0, 0.07, abs(r - radius * 0.88))) * 0.55);
	float eyed = 1.0 - smoothstep(eye * 0.8, eye * 1.08, r);
	col = mix(col, foam_color.rgb, foam * 0.8);
	col = mix(col, eye_color.rgb, eyed);
	ALBEDO = col;
}
