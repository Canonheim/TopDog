group_uniforms Emission;
uniform vec4 emission : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_energy = 1.0;
// THE GLOW SWITCH: the atlas's emission mask -- RGB the glow colour, alpha
// the strength / emission_strength_max (GLOW SOFT 0.5 = 32, NORMAL 1.0 = 64, HOT 3.0 = 191; alpha 0 everywhere that
// does not glow). The cel pass hands every PALETTE material the ONE shared mask; every other material keeps this
// default (transparent: no glow) and its flat `emission` (an unconverted model's emissive factor). Nearest, as the
// atlas: a face's UVs sit on one texel. The glow lights the surface alone; an OmniLight lights its surroundings.
uniform sampler2D emission_texture : source_color, hint_default_transparent, filter_nearest, repeat_disable;
uniform float emission_strength_max = 4.0;   // mask alpha 1.0 = this strength
group_uniforms;

vec3 emission_fragment(vec2 uv) {
	vec4 m = texture(emission_texture, uv);
	return (emission.rgb + m.rgb * m.a * emission_strength_max) * emission_energy;
}
