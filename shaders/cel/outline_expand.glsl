#[compute]
#version 450
// Geometric coverage: interior detail narrows with density. Tagged local
// exterior boundaries retain full width independently for each axis.
layout(local_size_x=8,local_size_y=8,local_size_z=1) in;
layout(r16f,set=0,binding=0) uniform restrict writeonly image2D coverage_image;
layout(set=1,binding=0) uniform sampler2D edges_texture;
layout(set=2,binding=0) uniform sampler2D density_texture;
layout(push_constant,std430) uniform Params {
    vec2 raster_size; float width; float strength; vec4 line_color;
} params;
float density_at(vec2 p) {
    float density=textureLod(density_texture,(p+0.5)/params.raster_size,0).r
        *params.raster_size.y/1080.0;
    return smoothstep(0.12,0.42,density)*params.strength;
}
void main() {
    ivec2 q=ivec2(gl_GlobalInvocationID.xy),sz=ivec2(params.raster_size);
    if(any(greaterThanEqual(q,sz))) return;
    float radius=max(params.width*0.5,0.85);
    int reach=int(ceil(radius+0.5));
    float ink=0.0;
    // An edge samples density at its own location, so all pixels drawing
    // that edge agree on width. Border clamps prevent opposite-side wraps.
    for(int y=-reach;y<=reach;y++) for(int x=-reach;x<=reach;x++) {
        ivec2 p=q+ivec2(x,y);
        if(any(lessThan(p,ivec2(0))) || any(greaterThanEqual(p,sz))) continue;
        vec4 e=texelFetch(edges_texture,p,0);
        if(max(max(e.r,e.g),max(e.b,e.a))<0.001) continue;
        float crowd=density_at(vec2(p));
        float narrow=max(0.55,0.60*params.raster_size.y/1080.0);
        vec2 exterior=clamp(e.rg-1.0,vec2(0.0),vec2(1.0));
        e=min(e,vec4(1.0));
        vec2 r=mix(vec2(radius),vec2(min(radius,narrow)),crowd*(1.0-exterior));
        vec2 o=vec2(x,y);
        // Distance to the unit-length grid-boundary segment, not a
        // square dilation. A one-pixel coverage ramp supplies edge AA.
        float dx=length(vec2(o.x+0.5,max(abs(o.y)-0.5,0.0)));
        float dy=length(vec2(max(abs(o.x)-0.5,0.0),o.y+0.5));
        float cx=clamp(r.x+0.5-dx,0.0,1.0);
        float cy=clamp(r.y+0.5-dy,0.0,1.0);
        ink=max(ink,max(cx*max(e.r,e.b),cy*max(e.g,e.a)));
    }
    imageStore(coverage_image,q,vec4(ink,0,0,0));
}
