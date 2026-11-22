shader_type spatial;
render_mode unshaded,cull_disabled;
uniform sampler2D base_texture:source_color;
void fragment(){ALBEDO=texture(base_texture,UV).rgb;EMISSION=ALBEDO*.35;}
