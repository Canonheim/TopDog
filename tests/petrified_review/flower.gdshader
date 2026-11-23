shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
uniform sampler2D atlas:source_color;
instance uniform float growth=1.0;
instance uniform vec2 stem_curve=vec2(1.,0.);
instance uniform float stem_bend=.8;
void vertex(){
 float h=clamp(VERTEX.y/.054,0.,1.);
 float opening=smoothstep(.55,1.,growth);
 vec2 radial=VERTEX.xz*mix(.3,1.,growth);
 if(VERTEX.y>.0539) radial*=mix(.32,1.,opening);
 vec2 dir=normalize(stem_curve);
 float bend=max(.1,stem_bend+(1.-growth)*.6);
 float angle=bend*h;
 float length=.054*growth;
 float extra=max(0.,VERTEX.y-.054)*growth;
 float along=dot(radial,dir);
 VERTEX.xz=radial-dir*along+dir*(along*cos(angle)+length*(1.-cos(angle))/bend+extra*sin(angle));
 VERTEX.y=length*sin(angle)/bend-along*sin(angle)+extra*cos(angle);
}
void fragment(){ALBEDO=texture(atlas,UV).rgb;ALPHA=1.0;}
