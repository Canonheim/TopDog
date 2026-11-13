// THE PEAK'S WATER, ONE BODY SEEN FROM THE SIDE (playtest note 22, Parker 11-12: "water
// will need a full visual overhaul, it is in weird cubes and it doesn't pour off things or
// look like water"). One mesh for a whole connected stretch (PeakZones._body_vis builds
// it from the joined outline of every water rule that touches), so there is no seam, no
// overlap and no end wall. The top of the body still wears Del Mar's own surface
// (DelMarSea); this is its front:
//   - a waterline that MOVES: a travelling ripple cuts the top edge;
//   - a body with depth: the cave's two blues, shallow to deep;
//   - current you can read: long soft streaks that slide with the flow (each vertex
//     carries its own flow speed, so a river, its quick end and its eddies are one
//     surface), and slow turning marks in the still patches;
//   - foam where the water meets a wall, a pile, a lip or the foot of a fall.
// Vertex COLOR: r = flow along x (0.5 is still, +-4 m/s is 1 and 0), g = how still a
// patch it is (an eddy), b unused.
shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 shallow_color : source_color = vec4(0.27, 0.72, 0.83, 0.45);
uniform vec4 deep_color : source_color = vec4(0.11, 0.44, 0.74, 0.85);
uniform vec4 line_color : source_color = vec4(0.92, 0.98, 1.0, 0.95);
uniform float surface_y = 0.0;  // the surface, world metres
uniform float fade_m = 2.4;     // metres from the surface over which shallow turns deep
uniform float line_m = 0.05;    // the waterline's thickness
uniform float glow_m = 0.38;    // a paler band under it
uniform float wave_m = 0.03;    // how high the travelling ripple stands
uniform float mean_flow = 0.0;  // m/s: the ripple travels with it
uniform float streak = 0.7;     // how strongly the current is drawn
uniform int foam_count = 0;
uniform vec3 foams[12];         // x (world), reach m, strength

varying vec2 wp;
varying float flow;
varying float eddy;

float hash1(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

// Long soft dashes in thin rows: 1 inside a dash, 0 between. `longer` (0..1) lengthens
// them. (Never scale p.x by something that changes along the river: p.x is a world
// position in the hundreds, and the smallest change in the scale crushes the pattern.)
float dashes(vec2 p, float longer) {
	float rows = p.y / 0.17;
	float r = floor(rows);
	float fy = abs(fract(rows) - 0.5) * 2.0;
	float period = mix(2.2, 4.4, hash1(r + 7.0));
	float u = p.x / period + hash1(r) * 13.0;
	float cell = floor(u);
	float fx = fract(u);
	float on = step(0.5, hash1(cell * 1.7 + r * 3.1));
	float len = mix(0.3, 0.6, hash1(cell + r * 5.3)) + 0.3 * longer;
	float along = smoothstep(0.0, 0.14, fx) * (1.0 - smoothstep(len - 0.22, len, fx));
	float across = 1.0 - smoothstep(0.12, 0.42, fy);
	return on * along * across;
}

void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xy;
	flow = (COLOR.r - 0.5) * 8.0;
	eddy = COLOR.g;
}

void fragment() {
	// the waterline: a ripple that travels with the water
	float c = mean_flow * 0.7 + 0.45;
	float wave = sin((wp.x - c * TIME) * 1.9) * 0.6 + sin((wp.x - c * 1.7 * TIME) * 4.3 + 1.3) * 0.3 + sin((wp.x + 0.5 * TIME) * 9.1) * 0.1;
	float top = surface_y + wave * wave_m;
	// foam: where the water meets something it piles up, lumpy
	float pile = 0.0;
	for (int i = 0; i < foam_count; i++) {
		float d = abs(wp.x - foams[i].x);
		float k = clamp(1.0 - d / max(foams[i].y, 0.01), 0.0, 1.0);
		pile = max(pile, k * k * foams[i].z);
	}
	float lumps = (sin(wp.x * 31.0 + TIME * 2.3) * 0.5 + 0.5) * 0.6 + (sin(wp.x * 17.0 - TIME * 1.7) * 0.5 + 0.5) * 0.4;
	top += pile * 0.05 * lumps;
	float under = top - wp.y;
	if (under < 0.0) {
		discard;
	}
	float deep = clamp(under / fade_m, 0.0, 1.0);
	vec4 col = mix(shallow_color, deep_color, deep);
	float thick = line_m + pile * (0.07 + 0.09 * lumps);
	float line = 1.0 - smoothstep(thick, thick + 0.014, under);
	float glow = (1.0 - smoothstep(0.0, glow_m, under)) * 0.22;
	// the current: two copies of the dashes, each sliding with the flow for a while and
	// fading into the other, so a speed that changes along the river never smears them
	float speed = abs(flow);
	// (where a still patch begins the speed changes fast along x, which would crush the
	// dashes: they are faded out before that)
	float shear = abs(dFdx(flow)) / max(abs(dFdx(wp.x)), 0.00001);  // m/s per metre along the river
	float moving = clamp(speed / 1.1, 0.0, 1.0) * (1.0 - smoothstep(0.02, 0.22, eddy)) * (1.0 - smoothstep(0.25, 0.7, shear));
	float t0 = fract(TIME / 5.0);
	float t1 = fract(TIME / 5.0 + 0.5);
	float w0 = 1.0 - abs(2.0 * t0 - 1.0);
	float stretch = clamp((speed - 0.6) / 2.4, 0.0, 1.0);
	float d0 = dashes(vec2(wp.x - flow * (t0 - 0.5) * 5.0, under), stretch);
	float d1 = dashes(vec2(wp.x - flow * (t1 - 0.5) * 5.0 + 17.3, under + 0.6), stretch);
	float near = mix(1.0, 0.3, clamp(under / 1.6, 0.0, 1.0));
	float marks = (d0 * w0 + d1 * (1.0 - w0)) * moving * near * streak;
	// a still patch: slow arcs, turning
	if (eddy > 0.3) {
		float ci = floor(wp.x / 1.4);
		float size = mix(0.7, 1.15, hash1(ci + 5.0));
		vec2 ctr = vec2((ci + 0.3 + 0.4 * hash1(ci + 1.0)) * 1.4, surface_y - 0.38 - 0.4 * hash1(ci));
		vec2 q = (wp - ctr) / size;
		float r = length(q);
		float a = atan(q.y, q.x) - TIME * 0.55 * (hash1(ci + 3.0) > 0.5 ? 1.0 : -1.0);
		float ring = (1.0 - smoothstep(0.016, 0.04, abs(r - 0.27))) * smoothstep(0.0, 0.7, cos(a));
		ring += (1.0 - smoothstep(0.012, 0.03, abs(r - 0.13))) * smoothstep(0.0, 0.7, cos(a + 2.6));
		marks = max(marks, ring * smoothstep(0.3, 0.8, eddy) * 0.42);
	}
	float pale = max(max(line * line_color.a, glow), marks);
	ALBEDO = mix(col.rgb, line_color.rgb, pale);
	ALPHA = mix(col.a, 1.0, max(line * line_color.a, marks * 0.55));
}
