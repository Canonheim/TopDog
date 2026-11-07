#[compute]
#version 450
// Exact 4x4 integration; never stride over pixel-wide edges (that flickers).
layout(local_size_x=8,local_size_y=8,local_size_z=1) in;
layout(r16f,set=0,binding=0) uniform restrict writeonly image2D raw_density;
layout(set=1,binding=0) uniform sampler2D edges_texture;
layout(push_constant,std430) uniform Params {
    vec2 raster_size; float width; float strength; vec4 line_color;
} params;
void main() {
    ivec2 q=ivec2(gl_GlobalInvocationID.xy),sz=imageSize(raw_density);
    if(any(greaterThanEqual(q,sz))) return;
    float total=0,count=0;
    for(int y=0;y<4;y++) for(int x=0;x<4;x++) {
        ivec2 p=q*4+ivec2(x,y);
        if(any(greaterThanEqual(p,ivec2(params.raster_size)))) continue;
        // Values above one carry exterior-width metadata, not extra ink.
        vec4 e=min(texelFetch(edges_texture,p,0),vec4(1.0));
        total+=max(e.r,e.b)+max(e.g,e.a); count+=1;
    }
    imageStore(raw_density,q,vec4(total/max(count,1.0)));
}
