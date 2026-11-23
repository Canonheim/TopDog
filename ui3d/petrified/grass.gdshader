shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
uniform sampler2D atlas:source_color,filter_nearest;
instance uniform float growth=0.0;
instance uniform vec2 grass_curve=vec2(.035,0.);
void vertex(){
 float h=clamp(VERTEX.y/.090,0.,1.);
 VERTEX.y*=growth;
 VERTEX.xz*=mix(.15,1.,growth);
 VERTEX.xz+=grass_curve*h*h*growth;
 VERTEX.x+=sin(h*3.14159)*.012*(1.-growth)*growth;
}
void fragment(){ALBEDO=texture(atlas,UV).rgb;ALPHA=1.0;}
