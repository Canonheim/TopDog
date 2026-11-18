shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
uniform sampler2D atlas : source_color, filter_nearest, repeat_disable;
instance uniform float brightness = 1.0;
void fragment() {
    float across = abs(UV2.x);
    float falloff = pow(max(0.0, 1.0-across), 2.4);
    ALBEDO = texture(atlas, UV).rgb;
    ALPHA = falloff * brightness;
}
