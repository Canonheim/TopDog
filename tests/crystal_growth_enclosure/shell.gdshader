shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_back,diffuse_burley,specular_schlick_ggx;
uniform sampler2D atlas:source_color,filter_nearest,repeat_disable;
uniform vec2 pale;
instance uniform vec2 shade_uv=vec2(-1.0);
instance uniform float shell_growth=0.0;
varying float face;
void vertex(){
 VERTEX*=mix(.015,1.0,shell_growth);
 face=COLOR.r;
}
void fragment(){
 vec3 color=texture(atlas,pale).rgb;
 if(shade_uv.x>=0.0)color=mix(color,texture(atlas,shade_uv).rgb,.3);
 float edge_distance=min(min(UV2.x,UV2.y),1.0-UV2.x-UV2.y);
 float edge=1.0-smoothstep(.002,.002+fwidth(edge_distance)*1.4,edge_distance);
 float rim=pow(1.0-abs(dot(normalize(NORMAL),normalize(VIEW))),2.5);
 float flash=smoothstep(.73,.90,face);
 ALBEDO=color*mix(.68,1.0,face);
 ROUGHNESS=.14;METALLIC=.08;SPECULAR=.8;
 EMISSION=color*(edge*.18+flash*.14);
 ALPHA=clamp(.09+face*.10+flash*.23+edge*.35+rim*.15,0.,.72)*smoothstep(.05,.3,shell_growth);
}
