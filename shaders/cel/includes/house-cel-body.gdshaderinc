// THE ONE CEL BODY: the house cel shader. cel-shader-base.gdshader is a stub
// over this file (add a second stub for a depth-test-off twin if a game wants
// camera-glued 3D UI: one render_mode line is the whole difference).
//
// THE CACHE TRAP: Godot's import cache misses include-only changes. After
// editing THIS file, bump the rev line in the stub .gdshader or the edit
// silently does not ship.
//
// Built on eldskald/godot4-cel-shader (MIT, see ../LICENSE), with the house's
// changes: THE POOL LAW (base-cel-shader.gdshaderinc bands dot x attenuation
// together, so a lamp's reach ends in a hard toon ring), WW-FLAT (no PBR
// reflection sheen: toon surfaces get ALL their light from the ramp), THE GLOW
// SWITCH (emission on; the atlas's emission mask carries the strength in its
// alpha), THE SHINE (the atlas's surface mask picks satin or polished per
// texel), and `use_vertex_color` for vertex-painted meshes.

#define USE_ALPHA 0
#define USE_ALPHA_CUTOFF 0
// THE GLOW SWITCH: emission on -- the atlas's GLOW sections light their own surface
#define USE_EMISSION 1
#define USE_REFLECTIONS 0
#define USE_NORMAL_MAP 0
#define USE_OCCLUSION 0
#define USE_HEIGHT_MAP 0
#define USE_ANISOTROPY 0
#define USE_BACKLIGHT 0
#define USE_REFRACTION 0

#if USE_ALPHA
render_mode depth_draw_always;
#endif

#include "res://shaders/cel/includes/base-cel-shader.gdshaderinc"

#if USE_EMISSION
#include "res://shaders/cel/includes/emission.gdshaderinc"
#endif

#if USE_REFLECTIONS
#include "res://shaders/cel/includes/reflections.gdshaderinc"
#endif

#if USE_NORMAL_MAP
#include "res://shaders/cel/includes/normal-map.gdshaderinc"
#endif

#if USE_OCCLUSION
#include "res://shaders/cel/includes/occlusion.gdshaderinc"
#endif

#if USE_HEIGHT_MAP
#include "res://shaders/cel/includes/height-map.gdshaderinc"
#endif

#if USE_ANISOTROPY
#include "res://shaders/cel/includes/anisotropy.gdshaderinc"
#endif

#if USE_BACKLIGHT
#include "res://shaders/cel/includes/backlight.gdshaderinc"
#endif

#if USE_REFRACTION
#include "res://shaders/cel/includes/refraction.gdshaderinc"
#elif !USE_REFRACTION && USE_ALPHA
#include "res://shaders/cel/includes/transparency.gdshaderinc"
#endif

group_uniforms BaseProperties;
#if USE_ALPHA_CUTOFF
uniform float alpha_cutoff: hint_range(0.0, 1.0) = 0.5;
#endif
uniform vec4 color: source_color = vec4(0.7, 0.12, 0.86, 1.0);
uniform sampler2D base_texture: source_color;
uniform vec4 specular: source_color = vec4(0.3, 0.3, 0.3, 0.5);
uniform sampler2D specular_texture: hint_default_white;
uniform vec4 fresnel: source_color = vec4(0.2, 0.2, 0.2, 0.3);
uniform sampler2D fresnel_texture: hint_default_white;
// vertex-paint albedo (see the header note)
uniform bool use_vertex_color = false;
group_uniforms;

// THE SHINE: the atlas's surface mask -- R metallic, G gloss (SATIN 128, POLISHED 255), A 255 where defined. The
// cel pass hands every PALETTE material the ONE shared mask; every other material keeps this default (transparent:
// its own glint and rim, as the cel pass's _metal_specular wrote them). Where the mask is set it REPLACES the
// material's glint and rim with THE SHINE NUMBERS (measured on spheres in the game's look): satin a soft glint
// tinted by its colour and no rim; polished a broad white glint and a white rim -- the one surface that gets a rim.
// Low specular.a is a TIGHT glint in this shader (the vendored curve runs backwards from PBR), so these are
// breadths, not roughness. True reflections stay off.
group_uniforms Shine;
uniform sampler2D surface_texture : hint_default_transparent, filter_nearest, repeat_disable;
uniform float shine_satin_lighten = 0.5;     // satin's glint: its colour lightened by this toward white (sRGB)
uniform float shine_satin_breadth = 0.62;    // satin's specular.a
uniform float shine_polished_breadth = 0.78; // polished's specular.a (white)
uniform float shine_polished_rim = 0.65;     // polished's fresnel.a (white)
group_uniforms;

varying vec3 SPECULAR_COLOR;
varying float SPECULAR_STRENGTH;
varying vec3 FRESNEL_COLOR;
varying float FRESNEL_STRENGTH;

varying vec2 base_uv;

group_uniforms Tiling;
uniform vec2 uv_scale = vec2(1,1);
uniform vec2 uv_offset = vec2(0,0);
group_uniforms;

void vertex() {
	UV = UV * uv_scale.xy + uv_offset.xy;
	#if !USE_HEIGHT_MAP
		base_uv = UV;
	#endif
}

void fragment() {
#if USE_HEIGHT_MAP
	base_uv = height_map_fragment(UV, VERTEX, TANGENT, BINORMAL, NORMAL);
#endif

#if USE_ALPHA
	float alpha = color.a * texture(base_texture, base_uv).a;
	ALBEDO *= alpha;
#elif USE_ALPHA_CUTOFF
	ALPHA = color.a * texture(base_texture, base_uv).a;
	ALPHA_SCISSOR_THRESHOLD = color.a * texture(base_texture, base_uv).a;
#endif

#if USE_REFRACTION && USE_ALPHA
	EMISSION += refraction_fragment(alpha, NORMAL, SCREEN_UV, FRAGCOORD.z);
#elif !USE_REFRACTION && USE_ALPHA
	EMISSION += transparency_fragment(alpha, SCREEN_UV);
#endif

	SPECULAR_COLOR = specular.rgb * texture(specular_texture, base_uv).rgb;
	SPECULAR_STRENGTH = specular.a * texture(specular_texture, base_uv).a;
	FRESNEL_COLOR = fresnel.rgb * texture(fresnel_texture, base_uv).rgb;
	FRESNEL_STRENGTH = fresnel.a * texture(fresnel_texture, base_uv).a;
	// THE SHINE: the surface mask, where set, replaces the glint and the rim
	vec4 shine = texture(surface_texture, base_uv);
	if (shine.a > 0.5) {
		if (shine.g > 0.75) {   // POLISHED
			SPECULAR_COLOR = vec3(1.0);
			SPECULAR_STRENGTH = shine_polished_breadth;
			FRESNEL_COLOR = vec3(1.0);
			FRESNEL_STRENGTH = shine_polished_rim;
		} else {                // SATIN
			vec3 lin = color.rgb * texture(base_texture, base_uv).rgb;
			vec3 srgb = mix(pow(lin, vec3(1.0 / 2.4)) * 1.055 - 0.055, lin * 12.92, lessThan(lin, vec3(0.0031308)));
			srgb = mix(srgb, vec3(1.0), shine_satin_lighten);
			SPECULAR_COLOR = mix(pow((srgb + 0.055) / 1.055, vec3(2.4)), srgb / 12.92, lessThan(srgb, vec3(0.04045)));
			SPECULAR_STRENGTH = shine_satin_breadth;
			FRESNEL_COLOR = vec3(0.0);
			FRESNEL_STRENGTH = 0.0;
		}
	}

#if USE_EMISSION
	EMISSION += emission_fragment(base_uv);
#endif

#if USE_REFLECTIONS
	Surface surf = reflections_fragment(UV);
	METALLIC = surf.metallic;
	ROUGHNESS = surf.roughness;
#else
	// WW-FLAT (divergence from upstream): an unwritten SPECULAR built-in defaults
	// to 0.5 and feeds Godot's sky/ambient REFLECTION pass on top of the
	// toon lighting — a view-dependent sheen, worst on floors at grazing
	// angles. The docs' own words: "0.0 disables reflections." Toon
	// surfaces get ALL their light from the ramp — nothing reflects.
	SPECULAR = 0.0;
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
#endif

#if USE_NORMAL_MAP
	NormalData normal = normal_map_fragment(base_uv, NORMAL, TANGENT, BINORMAL);
	NORMAL = normal.vector;
	NORMAL_MAP = normal.map;
	NORMAL_MAP_DEPTH = normal.depth;
#endif

#if USE_OCCLUSION
	OcclusionData occlusion = occlusion_fragment(base_uv);
	AO = occlusion.ao;
	AO_LIGHT_AFFECT = occlusion.ao_light_affect;
#endif

#if USE_ANISOTROPY
	AnisotropyData aniso = anisotropy_fragment(UV);
	ANISOTROPY_DIR = aniso.direction;
	ANISOTROPY_RATIO = aniso.ratio;
#endif

#if USE_BACKLIGHT
	BACKLIGHT = backlight_fragment(base_uv);
#endif

ALBEDO = color.rgb * texture(base_texture, base_uv).rgb;
	// COLOR is the mesh's vertex color (white when the mesh has no COLOR_0),
	// so this only bites when painted
	if (use_vertex_color) {
		ALBEDO *= COLOR.rgb;
	}
}

void light() {
	float sun_att = ATTENUATION;
#if USE_BACKLIGHT
	DIFFUSE_LIGHT += backlight_diffuse(
			ALBEDO,
			LIGHT_COLOR,
			LIGHT,
			NORMAL,
			sun_att,
			BACKLIGHT
	);
#else
	DIFFUSE_LIGHT += diffuse_light(
			ALBEDO,
			LIGHT_COLOR,
			LIGHT,
			NORMAL,
			sun_att
	);
#endif

#if USE_ANISOTROPY
	SPECULAR_LIGHT += anisotropy_specular(
			LIGHT_COLOR,
			SPECULAR_COLOR,
			SPECULAR_STRENGTH,
			NORMAL,
			VIEW,
			LIGHT,
			sun_att,
			UV,
			ANISOTROPY_DIR,
			ANISOTROPY_RATIO
	);
#else
	SPECULAR_LIGHT += specular_light(
			LIGHT_COLOR,
			SPECULAR_COLOR,
			SPECULAR_STRENGTH,
			NORMAL,
			VIEW,
			LIGHT,
			sun_att
	);
#endif

	SPECULAR_LIGHT += fresnel_light(
			LIGHT_COLOR,
			FRESNEL_COLOR,
			FRESNEL_STRENGTH,
			NORMAL,
			VIEW,
			LIGHT,
			sun_att
	);
}
