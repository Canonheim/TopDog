shader_type spatial;
instance uniform vec2 shade_uv=vec2(-1.0);
instance uniform float multicolor=0.0;
uniform vec2 spectrum[7];
render_mode unshaded,cull_disabled,depth_draw_never;
uniform sampler2D atlas:source_color,filter_nearest,repeat_disable;
uniform vec2 swatch;
instance uniform float aura_age=0.0;
varying float alpha;
varying float spark;
varying vec2 sparkle_tint;
float hash(float n){return fract(sin(n*12.9898)*43758.5453);}
void vertex(){
 float life=INSTANCE_CUSTOM.a;
 float t=max(0.0,aura_age-.3)+INSTANCE_CUSTOM.r*life;
 float cycle=floor(t/life);
 float phase=fract(t/life);
 float seed=INSTANCE_CUSTOM.g*981.7+cycle*7.13;
 spark=step(.5,INSTANCE_CUSTOM.b);
 sparkle_tint=spectrum[int(min(6.0,floor(INSTANCE_CUSTOM.g*7.0)))];
 float fade=sin(phase*3.14159265);
 float twinkle=.3+.7*pow(.5+.5*sin(t*10.0+seed),3.0);
 alpha=fade*smoothstep(.25,1.1,aura_age)*mix(.085,twinkle,spark);
 if(INSTANCE_CUSTOM.b>1.5)alpha*=smoothstep(1.5,1.65,aura_age);
 // Each emitter's local Z stores the sampled skin normal.
 vec3 outward=normalize(MODEL_MATRIX[2].xyz);
 vec3 side=normalize(MODEL_MATRIX[0].xyz);
 vec3 across=normalize(MODEL_MATRIX[1].xyz);
 vec3 drift=outward*(.06+hash(seed+3.0)*.13)*phase;
 drift+=side*sin(phase*5.0+seed)*.025*phase;
 drift+=across*sin(phase*3.0+seed*1.7)*.018*phase;
 vec3 center=MODEL_MATRIX[3].xyz+drift;
 float size=length(MODEL_MATRIX[0].xyz)*mix(.7+phase*.8,.8+.2*twinkle,spark);
 MODELVIEW_MATRIX=VIEW_MATRIX*mat4(vec4(INV_VIEW_MATRIX[0].xyz*size,0.0),vec4(INV_VIEW_MATRIX[1].xyz*size,0.0),vec4(INV_VIEW_MATRIX[2].xyz*size,0.0),vec4(center,1.0));
}
void fragment(){
 vec2 p=(UV-.5)*2.0;
 float soft=pow(max(0.0,1.0-dot(p,p)),3.0);
 float diamond=pow(max(0.0,1.0-abs(p.x)-abs(p.y)),1.5);
 float glint=max(0.0,1.0-abs(p.x)*11.0)*pow(max(0.0,1.0-abs(p.y)),3.0)+max(0.0,1.0-abs(p.y)*11.0)*pow(max(0.0,1.0-abs(p.x)),3.0);
 ALBEDO=texture(atlas,swatch).rgb;
 if(multicolor>.5)ALBEDO=mix(ALBEDO,texture(atlas,sparkle_tint).rgb,.58);
 else if(shade_uv.x>=0.0)ALBEDO=mix(ALBEDO,texture(atlas,shade_uv).rgb,.58);
 ALPHA=mix(soft,min(1.,diamond+glint*.5),spark)*alpha;
}
