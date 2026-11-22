shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
varying vec4 puff;
void vertex(){
	puff=INSTANCE_CUSTOM;
	MODELVIEW_MATRIX=VIEW_MATRIX*mat4(vec4(INV_VIEW_MATRIX[0].xyz*length(MODEL_MATRIX[0].xyz),0.0),vec4(INV_VIEW_MATRIX[1].xyz*length(MODEL_MATRIX[1].xyz),0.0),vec4(INV_VIEW_MATRIX[2].xyz*length(MODEL_MATRIX[2].xyz),0.0),MODEL_MATRIX[3]);
}
void fragment(){
	vec2 p=(UV-.5)*2.0;
	float cloud=max(0.0,1.0-dot(p,p));
	ALBEDO=vec3(.75,.91,.98);
	ALPHA=cloud*cloud*puff.a*.075;
}
