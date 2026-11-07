#[compute]
#version 450
// Short, depth-rejected history of INK ONLY. No scene-color feedback,
// no camera jitter and no global TAA. Set temporal weight to zero for
// purely spatial adaptive ink. Motion follows Godot's uv + velocity.
layout(local_size_x=8,local_size_y=8,local_size_z=1) in;
layout(rgba16f,set=0,binding=0) uniform restrict image2D color_image;
layout(set=1,binding=0) uniform sampler2D coverage_texture;
layout(r8,set=2,binding=0) uniform restrict writeonly image2D final_image;
layout(set=3,binding=0) uniform sampler2D depth_texture;
layout(set=4,binding=0) uniform sampler2D velocity_texture;
layout(set=5,binding=0) uniform sampler2D history_texture;
layout(rg32f,set=6,binding=0) uniform restrict writeonly image2D next_history;
layout(push_constant,std430) uniform Params {
    vec2 raster_size; float width; float strength; vec4 line_color;
    vec4 temporal; // history valid, maximum history weight, reserved, reserved
} params;
void main() {
    ivec2 q=ivec2(gl_GlobalInvocationID.xy),sz=ivec2(params.raster_size);
    if(any(greaterThanEqual(q,sz))) return;
    float current=texelFetch(coverage_texture,q,0).r;
    float lo=current,hi=current,mean=0,mean2=0;
    float carrier_depth=texelFetch(depth_texture,q,0).r;
    ivec2 carrier=q;
    for(int y=-1;y<=1;y++) for(int x=-1;x<=1;x++) {
        ivec2 p=clamp(q+ivec2(x,y),ivec2(0),sz-1);
        float ink=texelFetch(coverage_texture,p,0).r;
        lo=min(lo,ink); hi=max(hi,ink); mean+=ink; mean2+=ink*ink;
        float d=texelFetch(depth_texture,p,0).r;
        // An outside stroke belongs to the nearer object casting it.
        if(d>carrier_depth) {carrier_depth=d;carrier=p;}
    }
    float ink=current;
    if(params.temporal.x>0.5 && params.temporal.y>0 && hi>0.001) {
        vec2 velocity=texelFetch(velocity_texture,carrier,0).xy;
        vec2 previous=(vec2(q)+0.5)/params.raster_size+velocity;
        vec2 sample_pos=previous*params.raster_size-0.5;
        ivec2 base=ivec2(floor(sample_pos));
        vec2 fraction=fract(sample_pos);
        float history=0,weight=0;
        for(int y=0;y<=1;y++) for(int x=0;x<=1;x++) {
            ivec2 p=base+ivec2(x,y);
            if(any(lessThan(p,ivec2(0))) || any(greaterThanEqual(p,sz))) continue;
            vec2 h=texelFetch(history_texture,p,0).rg;
            // Reject revealed surfaces rather than dragging the old line.
            float rel=abs(h.g-carrier_depth)/max(max(h.g,carrier_depth),1e-7);
            float valid=1.0-smoothstep(0.015,0.04,rel);
            float w=(x==0?1-fraction.x:fraction.x)*(y==0?1-fraction.y:fraction.y)*valid;
            history+=h.r*w;weight+=w;
        }
        if(weight>0.01) {
            mean/=9.0;mean2/=9.0;
            float dev=sqrt(max(mean2-mean*mean,0.0));
            float h=clamp(history/weight,max(lo,mean-1.5*dev),min(hi,mean+1.5*dev));
            float speed=length(velocity*params.raster_size);
            float blend=params.temporal.y*min(weight,1.0)*(1.0-smoothstep(3.0,16.0,speed));
            ink=mix(current,h,blend);
        }
    }
    imageStore(next_history,q,vec4(ink,carrier_depth,0,0));
    imageStore(final_image,q,vec4(ink,0,0,0));
    vec4 color=imageLoad(color_image,q);
    float alpha=ink*params.line_color.a;
    imageStore(color_image,q,vec4(mix(color.rgb,params.line_color.rgb,alpha),max(color.a,alpha)));
}
