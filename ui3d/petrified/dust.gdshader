shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
uniform sampler2D atlas:source_color;
uniform vec2 swatch;
varying float opacity;
void vertex(){opacity=INSTANCE_CUSTOM.a;}
void fragment(){
 float soft=1.-smoothstep(.25,1.,length(UV*2.-1.));
 ALBEDO=texture(atlas,swatch).rgb;
 ALPHA=soft*soft*opacity*.22;
}
