#[compute]
#version 450
// Pixel-wide edge evidence. Width and density never change detection.
// RG: right/down depth evidence (0..1); clear foreground silhouettes may carry
// 1 + exterior-width protection (0..1). BA: normal-crease evidence (0..1).
// Consumers clamp evidence before density/opacity; only width uses the tag.
layout(local_size_x=8, local_size_y=8, local_size_z=1) in;
layout(rgba16f,set=0,binding=0) uniform restrict writeonly image2D edges_image;
layout(set=1,binding=0) uniform sampler2D depth_texture;
layout(set=2,binding=0) uniform sampler2D normal_texture;
layout(push_constant,std430) uniform Params {
    vec2 raster_size; float width; float reserved;
    vec4 line_color; mat4 inv_projection;
} params;
struct Surface { vec3 p; vec3 n; bool sky; };
Surface surface_at(ivec2 q) {
    q=clamp(q,ivec2(0),ivec2(params.raster_size)-1);
    float d=texelFetch(depth_texture,q,0).r;
    vec2 uv=(vec2(q)+0.5)/params.raster_size;
    vec4 v=params.inv_projection*vec4(uv*2.0-1.0,max(d,1e-6),1);
    vec3 n=texelFetch(normal_texture,q,0).xyz*2.0-1.0;
    Surface s;
    s.p=v.xyz/v.w;
    s.n=n*inversesqrt(max(dot(n,n),1e-6));
    s.sky=d<1e-7;
    return s;
}
// Sky/water use the original empty-depth test. For an opaque backdrop,
// clearance means staying behind the foreground layer, not behind every
// little variation on the background wall. No color/object-ID heuristic.
bool behind_layer(ivec2 p,float layer_z) {
    float d=texelFetch(depth_texture,p,0).r;
    if(d<1e-7) return true;
    if(layer_z==0.0) return false;
    float z=-(params.inv_projection[2][2]*d+params.inv_projection[3][2])
        /(params.inv_projection[2][3]*d+params.inv_projection[3][3]);
    return z>layer_z;
}
// Broad outward clearance selects a local cutout contour. Close foreground
// geometry in the ray still blocks priority, even over an opaque backdrop.
float exterior_clearance(ivec2 background,ivec2 outward,float layer_z) {
    ivec2 tangent=ivec2(-outward.y,outward.x);
    float scale=max(params.raster_size.y/1080.0,1.0);
    // Do not jump over thin foreground posts between the wider probes.
    // The candidate must actually be outermost along its outward ray.
    int ray_length=int(ceil(8.0*scale));
    for(int i=1;i<=ray_length;i++) {
        ivec2 p=background+outward*i;
        if(any(lessThan(p,ivec2(0))) || any(greaterThanEqual(p,ivec2(params.raster_size)))) return 0.0;
        if(!behind_layer(p,layer_z)) return 0.0;
    }
    float clear=0.0;
    for(int forward=2;forward<=8;forward+=2) {
        for(int side=-4;side<=4;side+=2) {
            ivec2 offset=ivec2(round(vec2(outward*forward+tangent*side)*scale));
            ivec2 p=background+offset;
            if(any(lessThan(p,ivec2(0))) || any(greaterThanEqual(p,ivec2(params.raster_size)))) continue;
            clear+=behind_layer(p,layer_z) ? 1.0 : 0.0;
        }
    }
    return smoothstep(0.75,0.95,clear/20.0);
}
vec2 boundary(Surface a,Surface b,ivec2 q,ivec2 axis) {
    if(a.sky && b.sky) return vec2(0);
    if(a.sky != b.sky) {
        ivec2 outward=b.sky?axis:-axis;
        ivec2 background=b.sky?q+axis:q;
        return vec2(1.0+exterior_clearance(background,outward,0.0),0);
    }
    vec3 delta=b.p-a.p;
    // Both tangent planes must disagree: a grazing plane stays empty;
    // an actual joined corner is primarily a crease, not a false gap.
    float gap=min(abs(dot(a.n,delta)),abs(dot(b.n,delta)));
    // A thin ledge can miss every sample along part of a shallow seam.
    // Its front faces still have a depth step: measure that step against
    // a pixel footprint, rather than the old 15 cm rejection threshold.
    // Subtract the normal buffer's quantization uncertainty first, so a
    // distant/grazing continuous plane does not turn into false ink.
    float uncertainty=length(delta)*0.01;
    gap=max(gap-uncertainty,0.0);
    float pixel_world=2.0*min(-a.p.z,-b.p.z)*abs(params.inv_projection[1][1])/params.raster_size.y;
    // Shading normals can point away from the triangle's actual plane.
    // Require a genuine depth discontinuity at EVERY distance; otherwise
    // an interpolated cliff/helmet normal turns a face into a field of ink.
    float t0=max(0.0001,pixel_world*0.18);
    float silhouette=0.0;
    float step_evidence=0.0;
    Surface before=surface_at(q-axis);
    Surface after=surface_at(q+axis*2);
    if(!before.sky && !after.sky) {
        float za=-a.p.z,zb=-b.p.z;
        float jump=1.0/zb-1.0/za;
        float left=jump-(1.0/za-1.0/(-before.p.z));
        float right=(1.0/(-after.p.z)-1.0/zb)-jump;
        float z=min(za,zb);
        float step_error=left*right<0.0 ? min(abs(left),abs(right)) : 0.0;
        float validated_gap=min(gap,max(step_error*z*z-uncertainty,0.0));
        step_evidence=smoothstep(t0,t0*3.0,max(step_error*z*z-uncertainty,0.0));
        silhouette=smoothstep(t0,t0*3.0,validated_gap);
        // A subpixel bevel can resemble a depth step: the pixel jumps
        // across its steep connecting face. A coherent shading-normal
        // field across BOTH sides identifies that smooth bend. Do not
        // ink it as a tiny occlusion that appears/disappears on motion.
        // Parallel stepped plates have no normal curvature and keep ink.
        vec3 nl=a.n-before.n, nm=b.n-a.n, nr=after.n-b.n;
        float agree_l=dot(nl,nm)*inversesqrt(max(dot(nl,nl)*dot(nm,nm),1e-12));
        float agree_r=dot(nm,nr)*inversesqrt(max(dot(nm,nm)*dot(nr,nr),1e-12));
        float rotation=min(length(b.n-before.n),length(after.n-a.n));
        float smooth_field=smoothstep(0.012,0.035,rotation)
            *smoothstep(0.5,0.9,min(agree_l,agree_r));
        float shallow=1.0-smoothstep(1.0,2.5,gap/max(pixel_world,1e-6));
        // A subpixel rounded trim can align one shading tangent plane with
        // the depth jump, making the two-plane minimum vanish. Recover only
        // a measured depth step beside a flat face whose normals turn back
        // on the other side of the thin ridge. A smooth bend has no return.
        float stable_left=1.0-smoothstep(0.002,0.025,length(nl));
        float stable_right=1.0-smoothstep(0.002,0.025,length(nr));
        float return_left=smoothstep(0.5,0.9,-agree_l)
            *smoothstep(0.08,0.20,min(length(nl),length(nm)));
        float return_right=smoothstep(0.5,0.9,-agree_r)
            *smoothstep(0.08,0.20,min(length(nr),length(nm)));
        float ridge=max(stable_left*return_right,stable_right*return_left);
        float depth_step=max(step_error*z*z-uncertainty,0.0)/max(pixel_world,1e-6);
        silhouette=max(silhouette,ridge*smoothstep(0.65,1.15,depth_step));
        silhouette*=1.0-smooth_field*shallow;

    }
    // A separated foreground cutout must not depend on an interpolated
    // shading normal facing the depth jump. At a curved silhouette that
    // tangent plane can align with the view and intermittently erase ink.
    // Validate the depth discontinuity and broad outward clearance first;
    // shallow joins and continuous slopes retain the interior tests above.
    if(max(silhouette,step_evidence)>0.0) {
        float za=-a.p.z,zb=-b.p.z;
        float z=min(za,zb);
        float margin=max(0.12,max(4.0*pixel_world,0.025*z));
        float separation=smoothstep(margin,max(0.25,max(8.0*pixel_world,0.075*z)),abs(za-zb));
        if(separation>0.0) {
            ivec2 outward=zb>za?axis:-axis;
            ivec2 background=zb>za?q+axis:q;
            float clear=exterior_clearance(background,outward,min(za,zb)+margin);
            silhouette=max(silhouette,step_evidence*separation*clear);
            if(silhouette>=1.0) silhouette+=0.65*separation*clear;
        }
    }
    float crease=1.0-smoothstep(0.60,0.74,dot(a.n,b.n));
    // Independent evidence: transitioning from crease to depth must not
    // weaken a real line halfway through that transition.
    return vec2(silhouette,crease);
}
void main() {
    ivec2 q=ivec2(gl_GlobalInvocationID.xy),size=ivec2(params.raster_size);
    if(any(greaterThanEqual(q,size))) return;
    Surface c=surface_at(q);
    vec2 x=boundary(c,surface_at(q+ivec2(1,0)),q,ivec2(1,0));
    vec2 y=boundary(c,surface_at(q+ivec2(0,1)),q,ivec2(0,1));
    imageStore(edges_image,q,vec4(x.x,y.x,x.y,y.y));
}
