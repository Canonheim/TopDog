shader_type spatial;
instance uniform vec2 shade_uv=vec2(-1.0);
instance uniform float multicolor=0.0;
uniform vec2 spectrum[7];
instance uniform float tint_boost=1.0;
render_mode blend_mix,depth_prepass_alpha,cull_back,diffuse_burley,specular_schlick_ggx;
uniform sampler2D atlas : source_color,filter_nearest,repeat_disable;
instance uniform float age=0.0;
varying float growth;
varying float variation;
void vertex(){
 float t=clamp((age-INSTANCE_CUSTOM.r)/INSTANCE_CUSTOM.g,0.0,1.0);
 growth=1.0-pow(1.0-t,3.0);
 variation=INSTANCE_CUSTOM.b;
 VERTEX*=growth;
}
void fragment(){
 vec3 swatch=texture(atlas,UV).rgb;
 if(multicolor>.5)swatch=mix(swatch,texture(atlas,spectrum[int(min(6.0,floor(variation*7.0)))]).rgb,.72);
 else if(shade_uv.x>=0.0)swatch=mix(swatch,texture(atlas,shade_uv).rgb,.72);
 // Stronger crystal hue; the body retains its separate subtle tint.
 swatch=mix(vec3(dot(swatch,vec3(.2126,.7152,.0722))),swatch,.65*sqrt(tint_boost));
 float rim=pow(1.0-abs(dot(normalize(NORMAL),normalize(VIEW))),3.0);
 float edge=1.0-smoothstep(.0,.035,min(UV2.x,1.0-UV2.x));
 ALBEDO=mix(swatch,vec3(1.0),rim*.55+edge*.22);
 METALLIC=.12;
 ROUGHNESS=.10;
 SPECULAR=.95;
 EMISSION=swatch*(rim*.20+edge*.12);
 ALPHA=(.24+rim*.45+edge*.18+variation*.08)*smoothstep(0.0,.08,growth);
}
