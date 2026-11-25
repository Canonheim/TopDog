shader_type spatial;
// Effect-local alpha; atlas is sampled for RGB only.
instance uniform float crystal_opacity : hint_range(0.0,1.0) = 1.0;
instance uniform vec2 shade_uv=vec2(-1.0);
instance uniform float multicolor=0.0;
uniform vec2 spectrum[7];
instance uniform float tint_boost=1.0;
instance uniform float color_strength=1.0;
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
 if(multicolor>.5)swatch=mix(swatch,texture(atlas,spectrum[int(min(6.0,floor(variation*7.0)))]).rgb,.95);
 else if(shade_uv.x>=0.0)swatch=mix(swatch,texture(atlas,shade_uv).rgb,.95);
 // Stronger crystal hue; the body retains its separate subtle tint.
 swatch=mix(vec3(dot(swatch,vec3(.2126,.7152,.0722))),swatch,min(1.0,.95*sqrt(tint_boost)));
 swatch=clamp(mix(vec3(dot(swatch,vec3(.2126,.7152,.0722))),swatch,color_strength),vec3(0.0),vec3(1.0));
 float rim=pow(1.0-abs(dot(normalize(NORMAL),normalize(VIEW))),3.0);
 float edge=1.0-smoothstep(.0,.035,min(UV2.x,1.0-UV2.x));
 // Fine effect-local ink edges: the global outline pass precedes transparency.
 float taper=max(0.0,(UV2.y-.72)/.28)*.5;
 float boundary=min(UV2.x-taper,1.0-taper-UV2.x);
 float pixel=max(fwidth(boundary),.0001);
 float ink=1.0-smoothstep(pixel*.15,pixel*.85,boundary);
 ALBEDO=mix(swatch,vec3(1.0),(rim*.12+edge*.05)/color_strength);
 ALBEDO=mix(ALBEDO,vec3(.025,.022,.03),ink*.88);
 METALLIC=.12;
 ROUGHNESS=.18;
 SPECULAR=.45;
 EMISSION=swatch*(rim*.10+edge*.05)*(1.0-ink);
 ALPHA=mix(.55+rim*.25+edge*.12+variation*.06,.92,ink)*smoothstep(0.0,.08,growth)*crystal_opacity;
}
