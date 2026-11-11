// THE SEA'S SURFACE (Del Mar, Parker 11-10: "golemhiem has splashes and sounds for the
// water we can use"): Golemheim's living-water surface shader (SwordGame scripts/water.gd
// SURFACE_SHADER), brought over as a file. Depth-tinted colour, the foam-circle top, the
// shore foam rings, ripple rings stamped in, the clean waterline and the ink replayed.
// DelMarSea sets the uniforms.
shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded;

// THE OCEAN'S DAY COLOUR: fallback values only — the LAW is the script's
// DAY_WATER_SHALLOW / DAY_WATER_DEEP consts up top (one number, one
// place); _rebuild stamps them over these, and main.gd's night driver
// blends from the same consts. Old stops — shallow (0.3, 0.62, 0.7),
// deep (0.08, 0.28, 0.45).
uniform vec4 shallow_color : source_color = vec4(0.27, 0.72, 0.83, 0.45);
uniform vec4 deep_color : source_color = vec4(0.11, 0.44, 0.74, 0.85);
uniform vec4 sparkle_color : source_color = vec4(0.85, 0.95, 1.0, 1.0);
uniform vec4 foam_color : source_color = vec4(0.92, 0.98, 1.0, 0.95);
uniform sampler2D noise_tex : filter_linear_mipmap, repeat_enable;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap, repeat_disable;
uniform float wave_height = 0.05;
// THE GLINT SCALE (Parker 2026-08-31, THE cells he actually meant): a
// straight multiplier on the pattern size — 1 = the authored look, 2 =
// twice as wide, 0.5 = half. Since THE FOAM-CIRCLE TOP (2026-09-02) it
// sizes the foam-circle tiles (foam_tile_m metres each at 1) AND still
// divides the refraction wobbles noise UVs — coupled on purpose, they
// are one water.
uniform float glint_scale = 1.0;
uniform float foam_tile_m = 14.0;
uniform float foam_speed = 1.0;
uniform float foam_strength = 0.9;
uniform float foam_edge_m = 1.6;       // THE PROJECTED FOAM: vertical metres it covers (0 = off)
uniform float foam_edge_rings = 2.0;   // toon rings across that depth
uniform float shore_edge_break = 0.25; // m the waterline cut wobbles
uniform float foam_edge_speed = 0.8;   // rings per second marching outward
uniform float foam_edge_strength = 1.0;
uniform float foam_width = 0.4;
uniform float depth_fade = 1.6;
uniform float refraction = 0.035;
uniform float murk_min = 0.3;   // how much water color covers a THIN column
uniform float murk_max = 0.85;  // ...and a deep one (1 = solid water color —
								// the OCEAN runs ~0.97 so it reads BLUE, not
								// re-tinted seabed sand; Parker v13)
uniform vec2 half_size = vec2(10.0, 8.0);
uniform float edge_flat = 0.5;
// ROUND WATER (Parker 2026-07-23, the hub ocean): 0 = rectangular
// footprint (the classic box law); > 0 = a circular disc of that
// radius in local metres — the square surface grid keeps its verts,
// the fragment stage simply clips outside the circle and the swell
// damp runs radially instead of per-axis.
uniform float round_radius = 0.0;
// THE RIM MELT (Parker 2026-07-23, per-volume toggle): > 0 = the outer
// rim_fade metres of the surface fade to TRANSPARENT, so an ocean edge
// dissolves into whatever sky gradient sits behind it instead of
// ending on a line. 0 = off — ponds and moats keep their honest edge.
// v2 same day (Parker: the sky box is not one color): a COLOR melt
// came first and could never match the skys own gradient; scene-wide
// distance fog before that hazed the clouds out. Transparency is the
// one melt that always agrees with the sky.
uniform float rim_fade = 0.0;
uniform int ripple_count = 0;
uniform vec4 ripples[12];  // x, z (world), ring radius, progress 0..1
// THE INK LEDGER (2026-07-23): the outline compositors final blurred
// ink, handed over by cel_shading.bind_water_ink. Only sampled when
// ink_on_water is raised — the flag and the texture arrive together.
// hint_default_black is LOAD-BEARING (2026-07-26): cel_shading.bind_water_ink
// raises ink_on_water and hands over a Texture2DRD whose RID is still empty
// until the compositor's first _render_callback publishes it. An unhinted
// sampler defaults to Godot's WHITE texture, so oink reads 1.0 and the line
// below paints the whole surface solid ink for those first frames — a black
// flash across every water body on load. outline_compositor.gd promises an
// empty RID samples black; this hint is what makes that promise true.
// (NB this whole shader is a GDScript STRING constant — never type a
// double quote in here, it ends the string and the game stops loading.)
uniform sampler2D outline_ink : hint_default_black, filter_linear;
uniform vec4 outline_ink_color = vec4(0.0, 0.0, 0.0, 0.9);
uniform float ink_on_water = 0.0;
uniform float ink_depth_fade = 0.0;   // THE DROWNED INK: metres under the surface past which replayed ink fades (0 = off)

// ---- THE FOAM-CIRCLE TOP (NekotoArts, CC0; shadertoy 3tKBDz) ----
// value noise + fBm warp the tile, then a layer of 75 authored circles
// tiles the water: two blues under it, foam over it. World-space xz
// drives the UV so the pattern never stretches with the mesh.
const float M_2PI = 6.283185307;
const float M_6PI = 18.84955592;

// THE SEAM CUT (Parker 2026-09-02, the straight hard cuts across the
// foam): the classic sin hash is fed the world-space lattice — hundreds
// of metres x fBm frequencies up to 96 = arguments in the tens of
// thousands, where a 32-bit sin() collapses into banding along lines of
// constant dot(uv, k): straight seams through the pattern. Wrapping the
// lattice to a 512-cell period keeps every argument small (the hash is
// then periodic every 512 cells — kilometres of water — and the four
// corners of a cell agree across the wrap, so it stays seamless).
float ww_random(vec2 uv) {
	uv = mod(uv, 512.0);
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float ww_noise(vec2 uv) {
	vec2 uv_index = floor(uv);
	vec2 uv_fract = fract(uv);
	float a = ww_random(uv_index);
	float b = ww_random(uv_index + vec2(1.0, 0.0));
	float c = ww_random(uv_index + vec2(0.0, 1.0));
	float d = ww_random(uv_index + vec2(1.0, 1.0));
	vec2 blur = smoothstep(0.0, 1.0, uv_fract);
	return mix(a, b, blur.x) + (c - a) * blur.y * (1.0 - blur.x)
			+ (d - b) * blur.x * blur.y;
}

float ww_fbm(vec2 uv) {
	float amplitude = 0.5;
	float frequency = 3.0;
	float value = 0.0;
	for (int i = 0; i < 6; i++) {
		value += amplitude * ww_noise(frequency * uv);
		amplitude *= 0.5;
		frequency *= 2.0;
	}
	return value;
}

float ww_circ(vec2 pos, vec2 c, float s) {
	c = abs(pos - c);
	c = min(c, 1.0 - c);
	return smoothstep(0.0, 0.002, sqrt(s) - sqrt(dot(c, c))) * -1.0;
}

// the foam pattern: a series of circles on a [0..1] tile
float ww_waterlayer(vec2 uv) {
	uv = mod(uv, 1.0);
	float ret = 1.0;
	ret += ww_circ(uv, vec2(0.37378, 0.277169), 0.0268181);
	ret += ww_circ(uv, vec2(0.0317477, 0.540372), 0.0193742);
	ret += ww_circ(uv, vec2(0.430044, 0.882218), 0.0232337);
	ret += ww_circ(uv, vec2(0.641033, 0.695106), 0.0117864);
	ret += ww_circ(uv, vec2(0.0146398, 0.0791346), 0.0299458);
	ret += ww_circ(uv, vec2(0.43871, 0.394445), 0.0289087);
	ret += ww_circ(uv, vec2(0.909446, 0.878141), 0.028466);
	ret += ww_circ(uv, vec2(0.310149, 0.686637), 0.0128496);
	ret += ww_circ(uv, vec2(0.928617, 0.195986), 0.0152041);
	ret += ww_circ(uv, vec2(0.0438506, 0.868153), 0.0268601);
	ret += ww_circ(uv, vec2(0.308619, 0.194937), 0.00806102);
	ret += ww_circ(uv, vec2(0.349922, 0.449714), 0.00928667);
	ret += ww_circ(uv, vec2(0.0449556, 0.953415), 0.023126);
	ret += ww_circ(uv, vec2(0.117761, 0.503309), 0.0151272);
	ret += ww_circ(uv, vec2(0.563517, 0.244991), 0.0292322);
	ret += ww_circ(uv, vec2(0.566936, 0.954457), 0.00981141);
	ret += ww_circ(uv, vec2(0.0489944, 0.200931), 0.0178746);
	ret += ww_circ(uv, vec2(0.569297, 0.624893), 0.0132408);
	ret += ww_circ(uv, vec2(0.298347, 0.710972), 0.0114426);
	ret += ww_circ(uv, vec2(0.878141, 0.771279), 0.00322719);
	ret += ww_circ(uv, vec2(0.150995, 0.376221), 0.00216157);
	ret += ww_circ(uv, vec2(0.119673, 0.541984), 0.0124621);
	ret += ww_circ(uv, vec2(0.629598, 0.295629), 0.0198736);
	ret += ww_circ(uv, vec2(0.334357, 0.266278), 0.0187145);
	ret += ww_circ(uv, vec2(0.918044, 0.968163), 0.0182928);
	ret += ww_circ(uv, vec2(0.965445, 0.505026), 0.006348);
	ret += ww_circ(uv, vec2(0.514847, 0.865444), 0.00623523);
	ret += ww_circ(uv, vec2(0.710575, 0.0415131), 0.00322689);
	ret += ww_circ(uv, vec2(0.71403, 0.576945), 0.0215641);
	ret += ww_circ(uv, vec2(0.748873, 0.413325), 0.0110795);
	ret += ww_circ(uv, vec2(0.0623365, 0.896713), 0.0236203);
	ret += ww_circ(uv, vec2(0.980482, 0.473849), 0.00573439);
	ret += ww_circ(uv, vec2(0.647463, 0.654349), 0.0188713);
	ret += ww_circ(uv, vec2(0.651406, 0.981297), 0.00710875);
	ret += ww_circ(uv, vec2(0.428928, 0.382426), 0.0298806);
	ret += ww_circ(uv, vec2(0.811545, 0.62568), 0.00265539);
	ret += ww_circ(uv, vec2(0.400787, 0.74162), 0.00486609);
	ret += ww_circ(uv, vec2(0.331283, 0.418536), 0.00598028);
	ret += ww_circ(uv, vec2(0.894762, 0.0657997), 0.00760375);
	ret += ww_circ(uv, vec2(0.525104, 0.572233), 0.0141796);
	ret += ww_circ(uv, vec2(0.431526, 0.911372), 0.0213234);
	ret += ww_circ(uv, vec2(0.658212, 0.910553), 0.000741023);
	ret += ww_circ(uv, vec2(0.514523, 0.243263), 0.0270685);
	ret += ww_circ(uv, vec2(0.0249494, 0.252872), 0.00876653);
	ret += ww_circ(uv, vec2(0.502214, 0.47269), 0.0234534);
	ret += ww_circ(uv, vec2(0.693271, 0.431469), 0.0246533);
	ret += ww_circ(uv, vec2(0.415, 0.884418), 0.0271696);
	ret += ww_circ(uv, vec2(0.149073, 0.41204), 0.00497198);
	ret += ww_circ(uv, vec2(0.533816, 0.897634), 0.00650833);
	ret += ww_circ(uv, vec2(0.0409132, 0.83406), 0.0191398);
	ret += ww_circ(uv, vec2(0.638585, 0.646019), 0.0206129);
	ret += ww_circ(uv, vec2(0.660342, 0.966541), 0.0053511);
	ret += ww_circ(uv, vec2(0.513783, 0.142233), 0.00471653);
	ret += ww_circ(uv, vec2(0.124305, 0.644263), 0.00116724);
	ret += ww_circ(uv, vec2(0.99871, 0.583864), 0.0107329);
	ret += ww_circ(uv, vec2(0.894879, 0.233289), 0.00667092);
	ret += ww_circ(uv, vec2(0.246286, 0.682766), 0.00411623);
	ret += ww_circ(uv, vec2(0.0761895, 0.16327), 0.0145935);
	ret += ww_circ(uv, vec2(0.949386, 0.802936), 0.0100873);
	ret += ww_circ(uv, vec2(0.480122, 0.196554), 0.0110185);
	ret += ww_circ(uv, vec2(0.896854, 0.803707), 0.013969);
	ret += ww_circ(uv, vec2(0.292865, 0.762973), 0.00566413);
	ret += ww_circ(uv, vec2(0.0995585, 0.117457), 0.00869407);
	ret += ww_circ(uv, vec2(0.377713, 0.00335442), 0.0063147);
	ret += ww_circ(uv, vec2(0.506365, 0.531118), 0.0144016);
	ret += ww_circ(uv, vec2(0.408806, 0.894771), 0.0243923);
	ret += ww_circ(uv, vec2(0.143579, 0.85138), 0.00418529);
	ret += ww_circ(uv, vec2(0.0902811, 0.181775), 0.0108896);
	ret += ww_circ(uv, vec2(0.780695, 0.394644), 0.00475475);
	ret += ww_circ(uv, vec2(0.298036, 0.625531), 0.00325285);
	ret += ww_circ(uv, vec2(0.218423, 0.714537), 0.00157212);
	ret += ww_circ(uv, vec2(0.658836, 0.159556), 0.00225897);
	ret += ww_circ(uv, vec2(0.987324, 0.146545), 0.0288391);
	ret += ww_circ(uv, vec2(0.222646, 0.251694), 0.00092276);
	ret += ww_circ(uv, vec2(0.159826, 0.528063), 0.00605293);
	return max(ret, 0.0);
}

// the top: two blues under the circles, foam over them. `deep_rgb` is
// OUR depth-tinted water colour (the night driver tints it), the second
// tone rides a shade under it, the foam is our sparkle colour.
vec3 ww_water(vec2 uv, vec3 deep_rgb, vec3 foam_rgb, float t) {
	uv *= vec2(0.25);
	uv += ww_fbm(uv) * 0.2;
	float d1 = mod(uv.x + uv.y, M_2PI);
	float d2 = mod((uv.x + uv.y + 0.25) * 1.3, M_6PI);
	d1 = t * 0.07 + d1;
	d2 = t * 0.5 + d2;
	vec2 dist = vec2(sin(d1) * 0.15 + sin(d2) * 0.05,
			cos(d1) * 0.15 + cos(d2) * 0.05);
	vec3 ret = mix(deep_rgb, deep_rgb * 0.88, ww_waterlayer(uv + dist.xy));
	ret = mix(ret, foam_rgb, ww_waterlayer(vec2(1.0) - uv - dist.yx) * foam_strength);
	return ret;
}

// THE PROJECTED FOAM helper: the world point behind a screen pixel.
vec3 world_behind(vec2 suv, mat4 inv_proj, mat4 inv_view) {
	float d = texture(depth_tex, suv).x;
	vec4 v = inv_proj * vec4(suv * 2.0 - 1.0, d, 1.0);
	v.xyz /= v.w;
	return (inv_view * vec4(v.xyz, 1.0)).xyz;
}

varying vec3 wpos;
varying vec2 lxz;  // local footprint coords — the round clip reads these
varying float wy_live;  // the LIVE surface height (rest + swell): the foam
						// and the rings measure depth from here (v14)

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	lxz = VERTEX.xz;
	// THE BLANKET STAYS TUCKED (Parker v8): the swell dies to flat over
	// edge_flat metres from the rim — a lifted crest at the shoreline
	// read like a blanket edge you could see under. Round water damps
	// radially — same tuck, circular rim.
	vec2 to_edge = half_size - abs(VERTEX.xz);
	float edge_m = round_radius > 0.0 ? round_radius - length(VERTEX.xz)
			: min(to_edge.x, to_edge.y);
	float damp = smoothstep(0.0, edge_flat, edge_m);
	float sw = (sin(wpos.x * 1.9 + TIME * 1.2)
			+ sin(wpos.z * 2.4 + TIME * 0.9)
			+ sin((wpos.x + wpos.z) * 1.1 - TIME * 1.5))
			* wave_height * 0.333 * damp;
	VERTEX.y += sw;
	wy_live = wpos.y + sw;
}

void fragment() {
	// round water: the grid is square, the disc is not — clip the corners
	if (round_radius > 0.0 && length(lxz) > round_radius) {
		discard;
	}
	// the water COLUMN: how far behind this surface the opaque world sits
	float d = texture(depth_tex, SCREEN_UV).x;
	vec4 view = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, d, 1.0);
	view.xyz /= view.w;
	float column = -view.z + VERTEX.z;
	float depth_mix = clamp(column / depth_fade, 0.0, 1.0);
	// two scrolling noise reads: the refraction wobble window (the old
	// glint bands read these too — THE FOAM-CIRCLE TOP replaced them)
	float na = texture(noise_tex,
			wpos.xz * (0.055 / glint_scale) + vec2(TIME * 0.024, TIME * 0.011)).r;
	float nb = texture(noise_tex,
			wpos.xz * (0.11 / glint_scale) - vec2(TIME * 0.017, TIME * 0.029)).r;
	// REFRACTION (v7): peek at the world below through a wobbling
	// window. The offset sample is depth-GUARDED — if it lands on
	// something in FRONT of the surface (a wader's dry torso), fall
	// back to the straight view instead of smearing dry into wet.
	vec2 off = (vec2(na, nb) - vec2(0.5)) * refraction
			* clamp(column, 0.0, 1.0);
	vec2 ruv = SCREEN_UV + off;
	float dr = texture(depth_tex, ruv).x;
	vec4 vr = INV_PROJECTION_MATRIX * vec4(ruv * 2.0 - 1.0, dr, 1.0);
	vr.xyz /= vr.w;
	if (-vr.z < -VERTEX.z) {
		ruv = SCREEN_UV;
	}
	vec3 under = texture(screen_tex, ruv).rgb;
	// murk: the refracted floor drowns into the water color with depth —
	// and the water colour IS THE FOAM-CIRCLE TOP: the depth-tinted blue
	// under the drifting foam circles (world xz / the foam tile, so the
	// pattern is metres, never mesh UVs)
	vec3 tint_rgb = mix(shallow_color.rgb, deep_color.rgb, depth_mix);
	vec3 water_rgb = ww_water(wpos.xz * (4.0 / (foam_tile_m * glint_scale)),
			tint_rgb, sparkle_color.rgb, TIME * foam_speed * 2.0);
	vec3 rgb = mix(under, water_rgb, mix(murk_min, murk_max, depth_mix));
	// shoreline foam: a hard bright band wherever the column runs thin.
	// STRICTLY POSITIVE columns only (v10, the white-fringe fix): a zero
	// or negative column means something sits in FRONT of the surface —
	// an outline hull, a dry crate edge — and that is NOT a shore.
	// (depth_tex is also filter_nearest now: LINEAR-blending depth at
	// silhouettes invented tiny columns along every edge = foam fringe.)
	// THE FOAM WIDTH FOLLOWS THE GROUND (v12, Parker: the white outline
	// came back — a wader's submerged chest ran a thin column along
	// his whole dry silhouette and the full-width foam traced it like
	// ink): reconstruct the opaque point + its face normal from depth.
	// Smooth UP-FACING floors (banks, beds, a crate's top) keep the
	// full shoreline band; everything else — bodies, box walls,
	// silhouette edges — foams only a TIGHT band (30%), so the wader
	// hug survives right at the pierce line and nowhere above it.
	// v13 (Parker 2026-09-02, the cut-up lines along the beach): the
	// face-normal gate above read screen-space DERIVATIVES of a depth
	// reconstruction — on a gentle beach seen from above the 24-bit
	// depth steps made flat_up flicker in stripes, and the band's width
	// jumped 0.3x/1x along them: straight cuts through the shoreline.
	// The band reads the VERTICAL depth of the opaque point instead
	// (surface height minus the floors height): smooth everywhere, and
	// a DRY silhouette is a negative depth — the v12 fringe stays dead
	// with no derivative in sight.
	// v14 (Parker: the foam is not following the wave): the depth is
	// measured from the LIVE swelled surface, so the waterline foam
	// climbs and falls the beach with every wave (the rest height froze
	// it in place)
	vec3 floor_w = (INV_VIEW_MATRIX * vec4(view.xyz, 1.0)).xyz;
	float vdepth = wy_live - floor_w.y;
	// THE CLEAN WATERLINE (v15, borrowed): where the ground behind this
	// pixel rises ABOVE the live surface the water pixel is discarded —
	// no halo where things pierce, no overshoot up a bank. The cut height
	// is jittered with foam-scale noise so the waterline is never a
	// mathematically clean curve.
	float shore_jitter = (ww_noise(wpos.xz * 1.8 + TIME * foam_edge_speed * 0.2) - 0.5)
			* shore_edge_break;
	if (floor_w.y > wy_live + 0.05 + shore_jitter) {
		discard;
	}
	// THE EDGE FOAM (2026-09-02): cartoon shore rings on OUR column —
	// hard toon bands (a stepped sine over the column depth) marching
	// outward, solid at the waterline and breaking up with distance,
	// chewed by the circle layer so no ring is ever a clean contour.
	// (v1 gated them to up-facing floors — v2 below reads vertical depth.)
	// v2 (Parker, the blockout's cliffs: not seeing much): the rings read
	// the VERTICAL depth of the opaque point under this pixel, not the
	// view column, and take any floor — a cliff wall just under the
	// waterline rings like a beach, a wader rings like the game he came
	// from; a DRY silhouette above the surface reads a negative depth
	// and never foams (the v12 problem never returns).
	// THE PROJECTED FOAM (v15, borrowed from EmacEArt's recipe, re-derived;
	// v16 painter): the vertical depth at four diagonal taps 8 px out (the
	// shallowest wins — that is what reaches round a pillars flank, where
	// the floor UNDER the pixel is deep; an above-water tap is a huge
	// sentinel, never a ring) builds one distance field, 0 at the
	// waterline and 1 a full foam_edge_m of depth away. v16: that field
	// is painted with v14s toon rings marching outward + smooth chew (the
	// look Parker liked) instead of v15s solid band + torn tongues.
	if (foam_edge_m > 0.0 && column > 0.0) {
		vec2 ts = 8.0 / VIEWPORT_SIZE;
		vec3 fw0 = world_behind(SCREEN_UV + ts * vec2(1.0, 1.0), INV_PROJECTION_MATRIX, INV_VIEW_MATRIX);
		vec3 fw1 = world_behind(SCREEN_UV + ts * vec2(-1.0, 1.0), INV_PROJECTION_MATRIX, INV_VIEW_MATRIX);
		vec3 fw2 = world_behind(SCREEN_UV + ts * vec2(1.0, -1.0), INV_PROJECTION_MATRIX, INV_VIEW_MATRIX);
		vec3 fw3 = world_behind(SCREEN_UV + ts * vec2(-1.0, -1.0), INV_PROJECTION_MATRIX, INV_VIEW_MATRIX);
		float big_d = 1000000.0;
		float fd0 = (fw0.y > wy_live) ? big_d : (wy_live - fw0.y);
		float fd1 = (fw1.y > wy_live) ? big_d : (wy_live - fw1.y);
		float fd2 = (fw2.y > wy_live) ? big_d : (wy_live - fw2.y);
		float fd3 = (fw3.y > wy_live) ? big_d : (wy_live - fw3.y);
		float proj_diff = min(min(min(fd0, fd1), min(fd2, fd3)), max(vdepth, 0.0));
		float edge_t = clamp(proj_diff / max(0.001, foam_edge_m), 0.0, 1.0);
		float rings = 0.5 + 0.5 * sin(edge_t * foam_edge_rings * M_2PI
				- TIME * foam_edge_speed * M_2PI);
		float chew = ww_noise(wpos.xz * 0.9 + vec2(TIME * 0.05, -TIME * 0.035));
		float band = rings * (1.0 - edge_t * 0.85) + (chew - 0.5) * 0.35;
		float edge_foam = smoothstep(0.5, 0.6, band)
				* (1.0 - smoothstep(0.6, 1.0, edge_t));
		rgb = mix(rgb, foam_color.rgb, edge_foam * foam_color.a * foam_edge_strength);
	}
	// RIPPLE RINGS (v8, chunked v9): stamped INTO the surface — they
	// ride the swell by construction, wear the foam's paint, and can
	// never poke outside the water. The (old) glint noise was too COARSE to
	// break them (~4m features read constant across a 1m ring — still
	// a compass circle), so rings get their own fine reads: `wob`
	// warps the radius with ~25cm features, `bites` eats drifting gaps
	// out of the circumference. Hoisted out of the loop — same water,
	// same chew, for every ring.
	float wob = texture(noise_tex,
			wpos.xz * 0.8 + vec2(TIME * 0.06, -TIME * 0.04)).r;
	float bites = smoothstep(0.3, 0.46, texture(noise_tex,
			wpos.xz * 0.45 + vec2(TIME * 0.021, TIME * 0.033)).r);
	float ring = 0.0;
	for (int i = 0; i < ripple_count; i++) {
		vec4 rp = ripples[i];
		float band_w = 0.09 + rp.w * 0.18;
		float b = 1.0 - smoothstep(0.0, band_w,
				abs(length(wpos.xz - rp.xy) - rp.z) + (wob - 0.5) * 0.3);
		ring = max(ring, step(0.42, b) * bites
				* (1.0 - smoothstep(0.45, 1.0, rp.w)));
	}
	rgb = mix(rgb, foam_color.rgb, ring * 0.8);
	// THE RIM MELT (v2, transparency): the last rim_fade metres thin to
	// nothing — the sky gradient behind shows through, and glints, foam
	// and rings sink away with the water.
	float rim_a = 1.0;
	if (rim_fade > 0.0) {
		float rim_m = round_radius > 0.0 ? round_radius - length(lxz)
				: min(half_size.x - abs(lxz.x), half_size.y - abs(lxz.y));
		rim_a = smoothstep(0.0, rim_fade, rim_m);
	}
	// THE INK COMES BACK (2026-07-23): the outline stamps PRE-transparent
	// (the health-bar law) and this very surface repaints over it — the
	// murk swallowed every silhouette band crossing open water. Replay
	// the compositors final ink on ourselves (written the same frame,
	// before the water draws).
	if (ink_on_water > 0.5) {
		float oink = texture(outline_ink, SCREEN_UV).r;
		// THE DROWNED INK (Run 3): a crease wholly under the sea fades; the highest point behind this
		// pixel and its four neighbours decides, so a dry silhouette beside open water keeps its band
		if (ink_depth_fade > 0.0 && oink > 0.0) {
			vec2 ts2 = 5.0 / VIEWPORT_SIZE;
			float hy = floor_w.y;
			hy = max(hy, world_behind(SCREEN_UV + vec2(ts2.x, 0.0), INV_PROJECTION_MATRIX, INV_VIEW_MATRIX).y);
			hy = max(hy, world_behind(SCREEN_UV - vec2(ts2.x, 0.0), INV_PROJECTION_MATRIX, INV_VIEW_MATRIX).y);
			hy = max(hy, world_behind(SCREEN_UV + vec2(0.0, ts2.y), INV_PROJECTION_MATRIX, INV_VIEW_MATRIX).y);
			hy = max(hy, world_behind(SCREEN_UV - vec2(0.0, ts2.y), INV_PROJECTION_MATRIX, INV_VIEW_MATRIX).y);
			oink *= 1.0 - smoothstep(ink_depth_fade * 0.3, ink_depth_fade, wy_live - hy);
		}
		rgb = mix(rgb, outline_ink_color.rgb, oink * outline_ink_color.a);
	}
	ALBEDO = rgb;
	ALPHA = rim_a;  // 1 everywhere but the rim melt: the refracted copy
					// repaints the pixel whole until the edge thins away
}
