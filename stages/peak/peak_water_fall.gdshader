// THE PEAK'S WATER, FALLING (playtest note 22, Parker 11-12: "it doesn't pour off things
// or look like water"). A ribbon that follows the water's own path: over the lip in a
// bend, then down (PeakZones._fall_vis builds it; UV.x runs across it, UV.y is metres
// along it from the lip). Broken white where it breaks over the lip, a sheet with streaks
// that speed up as they fall, ragged edges, and white again where it lands.
shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 water_color : source_color = vec4(0.62, 0.84, 0.93, 0.62);
uniform vec4 head_color : source_color = vec4(0.27, 0.72, 0.83, 0.5);  // the pool's own colour, where it leaves it
uniform vec4 white_color : source_color = vec4(0.94, 0.98, 1.0, 0.92);
uniform float length_m = 10.0;  // the whole ribbon
uniform float width_m = 0.5;
uniform float v0 = 1.5;         // m/s as it leaves the lip
uniform float fall_g = 7.0;     // the pull the streaks speed up under
uniform float top_white = 1.0;  // 1 = it breaks over a lip; 0 = it comes out of the rock
uniform float foot_white = 1.0; // 1 = it lands here; 0 = it carries on (into the area below)
uniform float clip_y = -100000.0; // world y: nothing drawn under it (a fall into a lock ends at its moving surface)
varying vec3 world_pos;

float hash1(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	if (world_pos.y < clip_y) {
		discard;
	}
	float s = UV.y;
	float across = UV.x;
	// the time a drop took to get here: streaks drawn in it stretch as they fall
	float tf = (sqrt(v0 * v0 + 2.0 * fall_g * s) - v0) / fall_g;
	float q = tf - TIME;
	float cols = max(3.0, floor(width_m / 0.07));
	float ci = floor(across * cols);
	float fc = abs(fract(across * cols) - 0.5) * 2.0;
	float u = q / mix(0.22, 0.5, hash1(ci)) + hash1(ci + 9.0) * 7.0;
	float cell = floor(u);
	float fu = fract(u);
	float on = step(0.42, hash1(cell * 1.3 + ci * 2.7));
	float dash = on * smoothstep(0.0, 0.2, fu) * (1.0 - smoothstep(0.55, 0.95, fu)) * (1.0 - smoothstep(0.25, 0.8, fc));
	// ragged edges: the sheet's sides waver, and tear more the further it has fallen
	float tear = 0.1 + 0.1 * clamp(s / 6.0, 0.0, 1.0);
	float wob = sin(q * 9.0 + ci) * 0.5 + sin(q * 23.0) * 0.5;
	float edge = smoothstep(0.0, tear * (1.0 + 0.6 * wob), across) * smoothstep(0.0, tear * (1.0 - 0.6 * wob), 1.0 - across);
	// broken white over the lip, and where it lands
	float lumps = sin(across * 19.0 + q * 11.0) * 0.5 + 0.5;
	// it leaves the pool as the pool's own water and breaks white from its outer edge
	// inward over the first metre and a half
	float breaking = smoothstep(0.0, 0.5, s * 0.8 - across * 1.1 + lumps * 0.35) * (1.0 - smoothstep(1.2, 2.6, s));
	float head = breaking * top_white;
	float foot = smoothstep(length_m - 1.4, length_m - 0.1, s) * foot_white;
	float falling = smoothstep(0.1, 1.3, s);
	float white = max(max(head * (0.5 + 0.5 * lumps), foot * (0.5 + 0.5 * lumps)), dash * 0.75 * falling);
	// broken white where it meets a lock's surface (clip_y), over its last 0.4 m
	float entry = (1.0 - smoothstep(clip_y, clip_y + 0.4, world_pos.y)) * step(-99999.0, clip_y);
	white = max(white, entry * (0.6 + 0.4 * lumps));
	vec4 base = mix(head_color, water_color, falling);
	ALBEDO = mix(base.rgb, white_color.rgb, white);
	ALPHA = mix(base.a, white_color.a, white) * mix(1.0, edge, falling) * (1.0 - foot * 0.35 * (1.0 - lumps));
}
