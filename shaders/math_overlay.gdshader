shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, fog_disabled;
uniform sampler2D glyph_atlas : source_color, filter_linear_mipmap, repeat_disable;
instance uniform float opacity = 1.0;
void fragment() {
 vec4 glyph = texture(glyph_atlas, UV);
 ALBEDO = glyph.rgb;
 ALPHA = glyph.a * opacity;
}
