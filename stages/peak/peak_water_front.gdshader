// THE PEAK'S WATER, SEEN FROM THE SIDE (Parker 11-12: "the water should use the water
// shader and splash effects we use in del mar"). Del Mar's surface is made for a sea you
// look down on; the Peak's pools are tanks you look into. So the TOP of every pool wears
// Del Mar's own surface (stages/delmar/sea_surface_fast.gdshader, dressed by DelMarSea),
// and this is the FRONT: a clean tint that deepens downward, and the waterline along its
// top edge. PeakZones sets the uniforms (the two colours come from PeakZones.water_colors).
shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 shallow_color : source_color = vec4(0.27, 0.72, 0.83, 0.45);
uniform vec4 deep_color : source_color = vec4(0.11, 0.44, 0.74, 0.85);
uniform vec4 line_color : source_color = vec4(0.92, 0.98, 1.0, 0.95);
uniform float depth_m = 2.0;   // how deep this pool is (the quad's height)
uniform float fade_m = 2.4;    // metres from the surface over which shallow turns deep
uniform float line_m = 0.055;  // the waterline's thickness
uniform float glow_m = 0.38;   // a paler band under it
uniform float flow = 0.0;      // m/s the water runs along x: the waterline's ripples ride it

varying vec2 wp;

void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xy;
}

void fragment() {
	float under = UV.y * depth_m;  // metres below the surface (a quad's UV runs down from its top)
	float deep = clamp(under / fade_m, 0.0, 1.0);
	vec4 col = mix(shallow_color, deep_color, deep);
	// the waterline: never a ruled line. Two slow waves along x move its lower edge.
	float x = wp.x - flow * TIME;
	float wob = sin(x * 2.3 + TIME * 1.3) * 0.014 + sin(x * 5.9 - TIME * 2.1) * 0.008;
	float line = 1.0 - smoothstep(line_m + wob, line_m + wob + 0.012, under);
	float glow = (1.0 - smoothstep(0.0, glow_m, under)) * 0.22;
	vec3 rgb = mix(col.rgb, line_color.rgb, max(line * line_color.a, glow));
	ALBEDO = rgb;
	ALPHA = mix(col.a, 1.0, line * line_color.a);
}
