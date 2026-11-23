shader_type spatial;
// Blend coverage independently; never make the underlying character transparent.
instance uniform float quartz_facets=0.0;
instance uniform float film_coverage : hint_range(0.0,1.0) = 1.0;
instance uniform vec2 shade_uv=vec2(-1.0);
instance uniform float multicolor=0.0;
uniform vec2 spectrum[7];
instance uniform float tint_boost=1.0;
uniform vec2 cool_body;
uniform vec2 stone_dark;
uniform vec2 stone_base;
uniform vec2 stone_light;
uniform vec2 moss_dark;
uniform vec2 moss_green;
instance uniform float stone_progress=0.0;
instance uniform float stone_floor=0.0;
instance uniform float stone_height=2.0;
instance uniform float stone_seed=0.0;
instance uniform vec2 stone_pattern=vec2(0.0,7.0);
varying vec3 stone_position;
uint stone_bits(uint v){v=((v>>16u)^v)*0x45d9f3bu;v=((v>>16u)^v)*0x45d9f3bu;return (v>>16u)^v;}
vec2 stone_hash(vec2 p){uint h=uint(int(p.x))*73856093u ^ uint(int(p.y))*19349663u;return vec2(float(stone_bits(h)&0xffffffu),float(stone_bits(h^0x9e3779b9u)&0xffffffu))/16777216.0;}
float moss_noise(vec2 p){
 vec2 cell=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);
 return mix(mix(stone_hash(cell).y,stone_hash(cell+vec2(1,0)).y,f.x),mix(stone_hash(cell+vec2(0,1)).y,stone_hash(cell+vec2(1,1)).y,f.x),f.y);
}
vec2 stone_cell(vec2 p){
 vec2 base=floor(p);vec2 f=fract(p);float nearest=8.0;float second=8.0;
 for(int y=-1;y<=1;y++){for(int x=-1;x<=1;x++){
  vec2 offset=vec2(float(x),float(y));vec2 v=offset+stone_hash(base+offset)-f;float d=dot(v,v);
  if(d<nearest){second=nearest;nearest=d;}else{second=min(second,d);}
 }}
 return vec2(nearest,second-nearest);
}
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

// THE ONE MATERIAL (Top Dog, Parker 2026-11-10: the whole game on one material, that's
// the benefit of the colour atlas). Per-INSTANCE values, so thousands of pieces share
// one material and still differ:
//   swatch_uv  x >= 0: the whole piece is this one atlas texel (a thing built in code,
//              painted by CelPass.paint); x < 0 (the default): the mesh's own UVs.
//   tint       multiplies the colour (LuchaKit.tint_part: a card's band, a streamer).
instance uniform vec2 swatch_uv = vec2(-1.0, -1.0);
instance uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void vertex() {
 stone_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
	UV = UV * uv_scale.xy + uv_offset.xy;
	if (swatch_uv.x >= 0.0) {
		UV = swatch_uv;
	}
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
			vec3 lin = color.rgb * tint.rgb * texture(base_texture, base_uv).rgb;
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

ALBEDO = color.rgb * tint.rgb * texture(base_texture, base_uv).rgb;
	// COLOR is the mesh's vertex color (white when the mesh has no COLOR_0),
	// so this only bites when painted
	if (use_vertex_color) {
		ALBEDO *= COLOR.rgb;
	}
 vec3 p=stone_position+vec3(stone_seed,0.0,stone_seed*.37);
 vec2 coord=vec2(p.x+p.z*.41,p.y);
 // Offset triangular lattice: each face gets its own value, not crack outlines.
 coord+=vec2(sin(coord.y*3.1),sin(coord.x*2.7))*.035;
 vec2 lattice=vec2(coord.x+coord.y*.5,coord.y*.8660254)*10.0;
 vec2 cell=floor(lattice);vec2 f=fract(lattice);
 float upper=step(1.0,f.x+f.y);
 vec2 face=cell*2.0+vec2(upper,upper*.37);
 float facet=stone_hash(face).x;
 float gradient=upper>.5 ? 2.0-f.x-f.y : f.x+f.y;
 float film=smoothstep(.0,.65,stone_progress)*film_coverage;
 float rim=pow(1.0-abs(dot(normalize(NORMAL),normalize(VIEW))),3.0);
 vec3 crystal=texture(base_texture,stone_light).rgb;
 vec3 rolled=crystal;
 if(shade_uv.x>=0.0)rolled=texture(base_texture,shade_uv).rgb;
 if(multicolor>.5)rolled=texture(base_texture,spectrum[int(min(6.0,floor(facet*7.0)))]).rgb;
 // Strong atlas hue must remain legible under the actual arena lighting.
 rolled=mix(vec3(dot(rolled,vec3(.2126,.7152,.0722))),rolled,min(.68,.50*tint_boost));
 crystal=mix(crystal,rolled,.78);
 // Tint the underlying body before applying the crystalline faces.
 float body_value=dot(ALBEDO,vec3(.2126,.7152,.0722));
 vec3 filtered=mix(ALBEDO,vec3(body_value),.78)*mix(vec3(1.0),rolled,.75);
 ALBEDO=mix(ALBEDO,mix(filtered,rolled*mix(.66,.9,body_value),.72),film*.98);
 vec3 faceted=crystal*mix(.48,1.08,facet)+crystal*gradient*.035;
 ALBEDO=mix(ALBEDO,faceted,film*(.24+facet*.24));
 ALBEDO=mix(ALBEDO,crystal,film*rim*.08);
 // Quartz needs value separation even over the lightest player skin.
 if(quartz_facets>.5){
  vec3 cool=texture(base_texture,cool_body).rgb;
  vec3 pale=texture(base_texture,stone_light).rgb;
  vec3 quartz_face=mix(cool*.72,pale*.94,smoothstep(.08,.94,facet));
  ALBEDO=mix(ALBEDO,quartz_face,film*.78);
 }


 SPECULAR_COLOR=crystal*.45;SPECULAR_STRENGTH=film*.30;
 FRESNEL_COLOR=crystal;FRESNEL_STRENGTH=film*.12;
 EMISSION+=crystal*film*(facet*.018+rim*.07);

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
