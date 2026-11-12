shader_type spatial;
render_mode blend_mix, unshaded, cull_front, depth_draw_never, depth_test_disabled, shadows_disabled, fog_disabled;

// Bounded 3D density projection. A fixed box supplies one back face per ray,
// including when the camera is inside. Nothing turns toward the camera.
uniform sampler2D scene_depth : hint_depth_texture, repeat_disable, filter_nearest;
uniform vec4 ember_color : source_color = vec4(0.96,0.19,0.035,1.0);
uniform vec4 flame_color : source_color = vec4(1.0,0.43,0.055,1.0);
uniform vec4 hot_color : source_color = vec4(1.0,0.78,0.16,1.0);
uniform vec4 core_color : source_color = vec4(1.0,0.96,0.63,1.0);
uniform float brightness : hint_range(0.5,2.0) = 1.1;
uniform float speed : hint_range(0.0,3.0) = 1.0;
uniform float seed = 0.0;
uniform float sway : hint_range(0.0,0.25) = 0.085;
uniform float merge_threshold : hint_range(0.08,0.4) = 0.20;
uniform float edge_softness : hint_range(0.5,2.0) = 0.8;
uniform float preview_time = -1.0;
varying flat vec4 b0;
varying flat vec4 b1;
varying flat vec4 b2;
varying flat vec4 b3;
varying flat vec4 b4;
varying flat vec4 b5;
varying flat vec4 b6;
varying flat vec4 b7;
varying flat vec3 tongue_stretch;
varying flat vec2 curl;
uniform float draw_distance = 200.0;
varying flat float camera_distance;
varying flat mat4 world_to_local;

vec4 rising(float t, float phase, vec2 lane) {
	float age = fract(t * 0.43 + phase);
	float size = max(sin(age * PI) * mix(0.26,0.09,age),0.001);
	vec2 drift = vec2(sin(t*2.1+phase*17.0+age*3.0),cos(t*1.7+phase*13.0+age*2.0));
	return vec4(lane.x+drift.x*sway*2.3*age,0.19+age*1.35,lane.y+drift.y*sway*1.8*age,size);
}

// Independent random height targets, joined with zero velocity and
// acceleration at each boundary. Evaluated only on the proxy vertices.
float random_height(float time, float salt) {
	float cell=floor(time);
	float u=fract(time);
	u=u*u*u*(u*(u*6.0-15.0)+10.0);
	float a=fract(sin(cell*12.9898+salt)*43758.5453);
	float b=fract(sin((cell+1.0)*12.9898+salt)*43758.5453);
	return mix(0.72,1.28,mix(a,b,u));
}


// ONE HUE, FOUR ROLES (2026-09-11, the Fire picker): `flame_color` is
// the picker's colour; ember, hot and core stay authored uniforms but
// ride the SAME hue / saturation / value shift the picker applied to the
// stock flame — so the stock orange renders exactly as authored, and a
// green picker gives a green flame with a dark green ember and a pale
// green core. Solved per fragment here — this shader already spends its
// 32 varying slots on the lobes (the quad shader solves it per vertex).
uniform vec4 stock_reference : source_color = vec4(1.0, 0.43, 0.055, 1.0);

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 recolor_role(vec3 role) {
	vec3 d = abs(flame_color.rgb - stock_reference.rgb);
	if (max(d.x, max(d.y, d.z)) < 0.002) {
		return role; // stock: the authored role, untouched
	}
	vec3 hs = rgb2hsv(stock_reference.rgb);
	vec3 hf = rgb2hsv(flame_color.rgb);
	vec3 hr = rgb2hsv(role);
	float h = fract(hr.x + (hf.x - hs.x));
	float s = clamp(hr.y * hf.y / max(hs.y, 1.0e-4), 0.0, 1.0);
	float v = clamp(hr.z * hf.z / max(hs.z, 1.0e-4), 0.0, 1.0);
	return hsv2rgb(vec3(h, s, v));
}

void vertex() {
	float t = (preview_time >= 0.0 ? preview_time : TIME) * speed + seed;
	// Three rooted tongues at 120-degree intervals fill X and Z equally.
	// The smaller, taller base blends into these tongues instead of a disk.
	b0=vec4(0.015*sin(t*1.7),0.20,0.015*cos(t*1.9),0.40);
	b1=vec4(0.20+sway*0.35*sin(t*2.3),0.37,0.0,0.33);
	b2=vec4(-0.10,0.40,0.173+sway*0.35*sin(t*2.1+2.0),0.33);
	b3=vec4(-0.10+sway*0.35*cos(t*1.9),0.38,-0.173,0.33);
	// Vary each tongue independently while anchoring its lower support.
	vec3 heights=vec3(0.53,0.55,0.54)*vec3(
		random_height(t*0.65,17.3),
		random_height(t*0.73+3.7,53.1),
		random_height(t*0.59+8.2,91.7));
	tongue_stretch=heights/0.33;
	b1.y=heights.x-0.16;
	b2.y=heights.y-0.15;
	b3.y=heights.z-0.16;
	// Rotate the three rooted tongues around the fixed fire center,
	// preserving their spacing and sway. One revolution takes ~18s.
	float orbit=t*0.35;
	float c=cos(orbit);
	float s=sin(orbit);
	mat2 orbit_rotation=mat2(vec2(c,s),vec2(-s,c));
	b1.xz=orbit_rotation*b1.xz;
	b2.xz=orbit_rotation*b2.xz;
	b3.xz=orbit_rotation*b3.xz;
	// Rising lobes occupy all four quadrants rather than one diagonal plane.
	b4=rising(t,0.00,vec2(-0.16,0.16));
	b5=rising(t,0.26,vec2(0.16,-0.16));
	b6=rising(t,0.53,vec2(-0.16,-0.16));
	b7=rising(t,0.79,vec2(0.16,0.16));
	curl=vec2(sin(t*2.7),cos(t*1.8+0.7));
	world_to_local=inverse(MODEL_MATRIX);
	camera_distance=length((VIEW_MATRIX*MODEL_MATRIX[3]).xyz);
	VERTEX.y+=1.6;
}

float density(vec3 p, vec4 b, float stretch) {
	vec3 q=(p-b.xyz)/b.w;
	q.y/=stretch;
	float tip=max(q.y,0.0);
	q.xz*=1.0+2.0*tip*tip;
	float h=max(1.0-dot(q,q),0.0);
	return h*h*h;
}

vec2 field_at(vec3 local_p) {
	vec3 p=local_p/vec3(1.7,1.94,1.7)-vec3(0.0,0.12,0.0);
	float y2=p.y*p.y;
	p.xz=p.xz*(1.0+0.65*y2)+y2*vec2(curl.x*0.07+p.y*curl.y*0.035,curl.y*0.06);
	// Smooth low-frequency 3D warping gives the foot an uneven, flowing
	// perimeter. Polynomial terms avoid trigonometry in ray samples.
	float foot=1.0-smoothstep(0.22,0.65,p.y);
	vec2 xz=p.xz;
	p.xz+=foot*0.32*vec2(xz.y*xz.y-xz.x*xz.x,2.0*xz.x*xz.y);
	p.y+=foot*(0.08*curl.x*xz.x+0.07*curl.y*xz.y+0.13*(xz.x*xz.x-xz.y*xz.y));
	float base=density(p,b0,0.32/0.40);
	float field=base+density(p,b1,tongue_stretch.x)+density(p,b2,tongue_stretch.y)+density(p,b3,tongue_stretch.z)
		+density(p,b4,1.75)+density(p,b5,1.75)+density(p,b6,1.75)+density(p,b7,1.75);
	float heat=field*(1.0-smoothstep(0.28,1.25,p.y)*0.82)+0.45*base*smoothstep(0.60,1.50,field);
	return vec2(field,heat);
}

vec3 unproject(vec2 uv, float z, mat4 inv_projection) {
	vec4 v=inv_projection*vec4(uv*2.0-1.0,z,1.0);
	return v.xyz/v.w;
}

void fragment() {
	// Reconstruct both perspective and orthographic rays in fixed local space.
	mat4 view_to_local=world_to_local*INV_VIEW_MATRIX;
	vec3 near_v=unproject(SCREEN_UV,1.0,INV_PROJECTION_MATRIX);
	vec3 far_v=unproject(SCREEN_UV,0.001,INV_PROJECTION_MATRIX);
	vec3 ro=(view_to_local*vec4(near_v,1.0)).xyz;
	vec3 rd=normalize((view_to_local*vec4(far_v-near_v,0.0)).xyz);
	vec3 safe_rd=mix(vec3(0.00001),rd,greaterThan(abs(rd),vec3(0.00001)));
	vec3 ta=(vec3(-1.4,0.0,-1.4)-ro)/safe_rd;
	vec3 tb=(vec3(1.4,3.2,1.4)-ro)/safe_rd;
	vec3 lo=min(ta,tb);
	vec3 hi=max(ta,tb);
	float start=max(max(lo.x,max(lo.y,lo.z)),0.0);
	float end=min(hi.x,min(hi.y,hi.z));
	float z=textureLod(scene_depth,SCREEN_UV,0.0).r;
	vec3 opaque=(view_to_local*vec4(unproject(SCREEN_UV,max(z,0.000001),INV_PROJECTION_MATRIX),1.0)).xyz;
	end=min(end,dot(opaque-ro,rd));
	if(end<=start) { discard; }
	// A fixed deterministic sample grid avoids animated noise. Fewer samples
	// at distance; total work stays bounded even with the camera in the volume.
	int count=int(mix(32.0,20.0,smoothstep(10.0,36.0,camera_distance)));
	float step_size=(end-start)/float(count);
	vec2 peak=vec2(0.0);
	vec2 peak_t=vec2(start);
	for(int i=0;i<32;i++) {
		if(i>=count) { break; }
		float t=start+(float(i)+0.5)*step_size;
		vec2 sample_value=field_at(ro+rd*t);
		peak_t=mix(peak_t,vec2(t),greaterThan(sample_value,peak));
		peak=max(peak,sample_value);
	}
	// Refine the two strongest samples to prevent visible depth-slice bands
	// on the silhouette and color boundaries, particularly from overhead.
	float radius=step_size*0.5;
	for(int j=0;j<3;j++) {
		float tl=max(start,peak_t.x-radius);
		float tr=min(end,peak_t.x+radius);
		float l=field_at(ro+rd*tl).x;
		float r=field_at(ro+rd*tr).x;
		if(l>peak.x) { peak.x=l; peak_t.x=tl; }
		if(r>peak.x) { peak.x=r; peak_t.x=tr; }
		tl=max(start,peak_t.y-radius);
		tr=min(end,peak_t.y+radius);
		l=field_at(ro+rd*tl).y;
		r=field_at(ro+rd*tr).y;
		if(l>peak.y) { peak.y=l; peak_t.y=tl; }
		if(r>peak.y) { peak.y=r; peak_t.y=tr; }
		radius*=0.5;
	}
	float aa=max(fwidth(peak.x)*edge_softness,0.008);
	float alpha=smoothstep(merge_threshold-aa,merge_threshold+aa,peak.x);
	float band_aa=max(fwidth(peak.y)*edge_softness,0.008);
	vec3 role_ember=recolor_role(ember_color.rgb);
	vec3 role_hot=recolor_role(hot_color.rgb);
	vec3 role_core=recolor_role(core_color.rgb);
	vec3 color=mix(role_ember,flame_color.rgb,smoothstep(0.36-band_aa,0.36+band_aa,peak.y));
	color=mix(color,role_hot,smoothstep(0.85-band_aa,0.85+band_aa,peak.y));
	color=mix(color,role_core,smoothstep(1.65-band_aa,1.65+band_aa,peak.y));
	// Preserve a thin ember-orange shell even where the hot basal core
	// raises heat: silhouette density, not heat, owns this outermost rim.
	float rim_aa=max(fwidth(peak.x)*edge_softness,0.004);
	float rim=smoothstep(merge_threshold+0.035-rim_aa,merge_threshold+0.10+rim_aa,peak.x);
	color=mix(role_ember,color,rim);
	ALBEDO=color*brightness;
	ALPHA=alpha*(1.0-smoothstep(draw_distance*0.8,draw_distance,camera_distance));
}
