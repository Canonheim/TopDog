#[compute]
#version 450
// Smooth integrated edge density before expansion. The preceding exact
// downsample includes every source pixel, so thin rows cannot alias out.
layout(local_size_x=8,local_size_y=8,local_size_z=1) in;
layout(r16f,set=0,binding=0) uniform restrict writeonly image2D density_image;
layout(set=1,binding=0) uniform sampler2D raw_density;
layout(push_constant,std430) uniform Params {
    vec2 raster_size; float width; float strength; vec4 line_color;
} params;
void main() {
    ivec2 q=ivec2(gl_GlobalInvocationID.xy),sz=imageSize(density_image);
    if(any(greaterThanEqual(q,sz))) return;
    int radius=max(1,int(round(params.raster_size.y/1080.0*2.0)));
    float total=0,weights=0;
    for(int y=-radius;y<=radius;y++) for(int x=-radius;x<=radius;x++) {
        ivec2 p=clamp(q+ivec2(x,y),ivec2(0),sz-1);
        float w=float((radius+1-abs(x))*(radius+1-abs(y)));
        float edge=texelFetch(raw_density,p,0).r;
        total+=edge*w; weights+=w;
    }
    imageStore(density_image,q,vec4(total/weights));
}
