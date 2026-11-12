// THE FLAME COMMONS (2026-07-30): the math all three flame shaders
// (flame_bands / flame_ember / flame_teardrop) used to carry as
// hand-matched copies — the phase hash and the two billboard builds.
// Pure functions only: no uniforms, no varyings, nothing renderer-side.
//
// THE CACHE TRAP (the cel body's lesson): Godot's import cache misses
// include-only changes — after editing THIS file, bump the rev line in
// each flame .gdshader stub header or the edit silently doesn't ship.
//
// fire.gd stacks the same wander() SHAPE onto the glow's energy in
// GDScript — that twin is cross-language and stays by design; if you
// retune wander() here, retune fire.gd's copy to match.

// THE FLAME HASH: any 2D key -> a stable phase in 0..TAU. Deterministic
// on purpose — a torch's flame looks identical every time you walk
// back into the room. A scalar seed is the same hash with key.y = 0
// (dot((s, 0), k) == s * k.x — bit-identical to the old scalar form).
float flame_phase_hash(vec2 key) {
	return fract(sin(dot(key, vec2(12.9898, 78.233))) * 43758.5453) * TAU;
}

// TWO UNSYNCED SINES = a hand-drawn wander in roughly [-1, 1]. The
// 1.73 is deliberately irrational-ish so the pair never repeats on a
// short loop. (fire.gd's glow stacks the same shape — see the header.)
float wander(float t) {
	return sin(t) * 0.62 + sin(t * 1.73 + 1.37) * 0.38;
}

// FULL CAMERA-FACING BILLBOARD, spelled out. StandardMaterial3D gives
// you billboard_mode for free; a ShaderMaterial has to build the
// matrix itself. Camera-facing with the per-particle scale KEPT (the
// process material's scale_min/max and scale_curve live in the model
// columns' lengths — drop the scale multiply and every particle snaps
// to the same size and the shrink curve stops working). Callers do
//   MODELVIEW_MATRIX = VIEW_MATRIX * flame_billboard(INV_VIEW_MATRIX, MODEL_MATRIX);
// (+ MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX) where normals matter).
mat4 flame_billboard(mat4 inv_view, mat4 model) {
	mat4 mat_world = mat4(
			normalize(inv_view[0]),
			normalize(inv_view[1]),
			normalize(inv_view[2]),
			model[3]);
	return mat_world * mat4(
			vec4(length(model[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(model[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(model[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
}

// Y-BILLBOARD, SCALE KEPT. The flame yaws to face the camera but never
// tips over: a torch flame points at the sky no matter where you
// stand, and a full camera-facing billboard would lie down when you
// look at it from a balcony.
mat4 flame_billboard_y(mat4 inv_view, mat4 model) {
	vec3 origin = model[3].xyz;
	vec3 up = vec3(0.0, 1.0, 0.0);
	vec3 right = cross(up, inv_view[2].xyz);
	float rl = length(right);
	// degenerate only when the camera looks straight down the world's up
	// axis; fall back to the camera's own right so it can't collapse.
	right = rl > 0.0001 ? right / rl : inv_view[0].xyz;
	vec3 fwd = cross(right, up);
	vec3 sc = vec3(length(model[0].xyz),
			length(model[1].xyz),
			length(model[2].xyz));
	return mat4(
			vec4(right * sc.x, 0.0),
			vec4(up * sc.y, 0.0),
			vec4(fwd * sc.z, 0.0),
			vec4(origin, 1.0));
}
