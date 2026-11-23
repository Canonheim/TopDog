shader_type spatial;
uniform sampler2D atlas:source_color;
uniform vec2 swatch;
void fragment(){ALBEDO=texture(atlas,swatch).rgb;ROUGHNESS=1.;}
