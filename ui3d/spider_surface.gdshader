shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
uniform sampler2D atlas:source_color;
uniform vec2 swatch_uv;
uniform float opacity:hint_range(0.0,1.0)=1.0;
void fragment(){ALBEDO=texture(atlas,swatch_uv).rgb;ALPHA=opacity;}
