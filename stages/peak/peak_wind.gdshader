// THE WIND, DRAWN LOUDLY (playtest note 89; Parker 11-13: "wind effects need to be way
// more obvious", then "i like the flag and wavy wind idea"). One quad over a wind's whole
// box: long wavy lines, white with an inked edge so they read on snow as well as on dark
// rock, travelling along the wind at its speed. They fade out at the box's edge, so you
// see where the wind stops (note 70). A see-through look, like the water's: not the atlas.
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix, shadows_disabled;

uniform vec2 size = vec2(10.0, 10.0);  // the box, metres
uniform vec2 dir = vec2(1.0, 0.0);     // which way it blows
uniform float speed = 6.0;             // m/s the lines travel
uniform float gust = 1.0;              // 0..1: how hard it blows now
uniform float warn = 0.0;              // 0..1: the warning before a gust
uniform float spacing = 0.85;          // m between lines, across the wind
uniform float seed = 0.0;
uniform float core = 0.045;            // m: half the white line's width
uniform float ink = 0.085;             // m: half the inked edge's width

varying vec2 local;

void vertex() {
	local = VERTEX.xy;
}

float hash(float n) {
	return fract(sin(n * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 d = normalize(dir);
	vec2 n = vec2(-d.y, d.x);
	float u = dot(local, d);
	float v = dot(local, n);
	float row = floor(v / spacing + 0.5);
	float h = hash(row);
	float h2 = hash(row + 17.0);
	float t = TIME;
	// The line waves as it goes: two slow waves, each row its own.
	float wave = sin(u * 1.25 + t * speed * 0.55 + h * 6.283) * 0.13 + sin(u * 0.5 - t * 1.6 + h2 * 3.1) * 0.08;
	float dv = v - (row * spacing + (h - 0.5) * spacing * 0.45) - wave;
	// Dashes running along the wind.
	float len = mix(2.4, 4.6, h);
	float period = len + mix(1.4, 3.6, h2);
	float s = mod(u - t * speed * mix(0.85, 1.15, h) + h * period * 3.0, period);
	// Round ends: the line's width falls away over its last 0.18 m, never to a point.
	float endw = smoothstep(0.0, 0.18, s) * smoothstep(len, len - 0.18, s) * step(s, len);
	float cw = core * endw;
	float iw = ink * endw;
	float a_core = 1.0 - smoothstep(cw * 0.6, cw, abs(dv));
	float a_ink = 1.0 - smoothstep(iw * 0.75, iw, abs(dv));
	vec2 e = size * 0.5 - abs(local);
	float edge = smoothstep(0.0, 0.7, min(e.x, e.y));
	float k = max(gust, warn * 0.35) * edge;
	ALBEDO = mix(vec3(0.08, 0.09, 0.2), vec3(1.0), a_core);
	ALPHA = clamp(max(a_ink, a_core), 0.0, 1.0) * k;
}
