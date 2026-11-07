#[compute]
#version 450
// Remove compact, disconnected edge specks BEFORE density and expansion.
// Coverage/lighting pixels are never blurred or used as connectivity evidence.
layout(local_size_x=8,local_size_y=8,local_size_z=1) in;
layout(rgba16f,set=0,binding=0) uniform restrict writeonly image2D clean_image;
layout(set=1,binding=0) uniform sampler2D edges_texture;
layout(push_constant,std430) uniform Params {
    vec2 raster_size; float width; float minimum_span; vec4 line_color;
} params;
float peak(vec4 e) {return max(max(e.r,e.g),max(e.b,e.a));}
vec4 edge_at(ivec2 q) {
    if(any(lessThan(q,ivec2(0))) || any(greaterThanEqual(q,ivec2(params.raster_size)))) return vec4(0);
    return texelFetch(edges_texture,q,0);
}
// A one-pixel sideways jog, one or two pixels long, between two straight
// protected contour flanks is raster-scale chatter. Move only that jog to
// the flanks. Corners, sustained steps, creases and close parallel strokes
// fail this test. The source remains the detector, never scene color.
int jog_shift(ivec2 q,int axis) {
    if(edge_at(q)[axis]<=1.01) return 0;
    ivec2 n=axis==0?ivec2(1,0):ivec2(0,1),t=ivec2(n.y,n.x);
    bool before=edge_at(q-t)[axis]>1.01,after=edge_at(q+t)[axis]>1.01;
    if(before && after) return 0;
    ivec2 first=before?q-t:q;
    int count=(before || after)?2:1;
    if(edge_at(first-t)[axis]>0.002 || edge_at(first+t*count)[axis]>0.002) return 0;
    for(int shift=-1;shift<=1;shift+=2) {
        ivec2 target=first+n*shift;
        if(min(min(edge_at(target-t)[axis],edge_at(target-t*2)[axis]),
               min(edge_at(target+t*count)[axis],edge_at(target+t*(count+1))[axis]))<=1.01) continue;
        bool clear=true;
        for(int i=0;i<count;i++) {
            for(int j=-1;j<=2;j++) {
                if(j==0) continue;
                vec4 e=edge_at(first+t*i+n*(shift*j));
                clear=clear && max(e[axis],e[axis+2])<0.002;
            }
        }
        if(clear) return shift;
    }
    return 0;
}
bool jog_cap(ivec2 q,int axis) {
    int cross_axis=1-axis;
    ivec2 n=cross_axis==0?ivec2(1,0):ivec2(0,1),t=ivec2(n.y,n.x);
    for(int shift=-1;shift<=1;shift+=2) {
        ivec2 p=q-(shift>0?n:ivec2(0));
        int a=jog_shift(p,cross_axis),b=jog_shift(p+t,cross_axis);
        if((a==shift && b==0) || (b==shift && a==0)) return true;
    }
    return false;
}
// A shallow depth seam can stair-step between adjacent pixel columns.
// Its single perpendicular connector is expanded as a separate stroke,
// producing a sideways tick. Keep the two longitudinal runs and remove
// only that connector. Normal creases, branches and protected edges stay.
bool stair_connector(ivec2 q,int axis) {
    vec4 e=edge_at(q);
    if(e[axis]<0.25 || e[axis]>1.01 || e[axis+2]>0.002) return false;
    ivec2 n=axis==0?ivec2(1,0):ivec2(0,1),t=ivec2(n.y,n.x);
    vec4 left=edge_at(q-t),right=edge_at(q+t);
    if(max(max(left[axis],left[axis+2]),max(right[axis],right[axis+2]))>0.002) return false;
    int along=1-axis;
    for(int side=0;side<2;side++) {
        ivec2 before=q-t*side,after=q-t*(1-side)+n;
        float support=min(min(edge_at(before)[along],edge_at(before-n)[along]),
                          min(edge_at(after)[along],edge_at(after+n)[along]));
        if(support>=0.25) return true;
    }
    return false;
}
vec4 steady_contour(ivec2 q,vec4 original) {
    vec4 result=original;
    for(int axis=0;axis<2;axis++) {
        ivec2 n=axis==0?ivec2(1,0):ivec2(0,1);
        if(jog_shift(q,axis)!=0) {result[axis]=0;result[axis+2]=0;}
        else if(max(original[axis],original[axis+2])<0.002) {
            for(int shift=-1;shift<=1;shift+=2) {
                ivec2 source=q-n*shift;
                if(jog_shift(source,axis)!=shift) continue;
                vec4 e=edge_at(source);
                result[axis]=e[axis];result[axis+2]=e[axis+2];
            }
        }
        // Remove only the perpendicular end caps belonging to that jog.
        if(original[axis]<=1.01 && max(original[axis],original[axis+2])>0.002 && jog_cap(q,axis)) {
            result[axis]=0;result[axis+2]=0;
        }
        if(stair_connector(q,axis)) result[axis]=0;
    }
    return result;
}
void main() {
    ivec2 q=ivec2(gl_GlobalInvocationID.xy),sz=ivec2(params.raster_size);
    if(any(greaterThanEqual(q,sz))) return;
    vec4 edge=texelFetch(edges_texture,q,0);
    float strength=peak(edge);
    int min_span=clamp(int(params.minimum_span),0,4);
    if(min_span==0) {imageStore(clean_image,q,edge);return;}
    edge=steady_contour(q,edge);
    strength=peak(edge);
    if(strength<0.002) {imageStore(clean_image,q,vec4(0));return;}
    // A local 8-connected flood fill distinguishes a tiny enclosed speck
    // from a real stroke or a tip attached to one. A nearby disconnected
    // line cannot rescue the speck. Relative support preserves soft ink.
    float threshold=min(0.12,max(0.02,strength*0.5));
    uint occupied[9],seen[9],grown[9];
    for(int y=0;y<9;y++) {
        uint row=0u;
        for(int x=0;x<9;x++) {
            ivec2 p=q+ivec2(x-4,y-4);
            if(any(lessThan(p,ivec2(0))) || any(greaterThanEqual(p,sz))) continue;
            if(peak(texelFetch(edges_texture,p,0))>=threshold) row|=1u<<uint(x);
        }
        occupied[y]=row;seen[y]=0u;
    }
    seen[4]=16u;
    bool keep=false;
    for(int iteration=0;iteration<8;iteration++) {
        uint columns=0u;int first=9,last=-1;bool changed=false;
        for(int y=0;y<9;y++) {
            uint neighbors=seen[y];
            if(y>0) neighbors|=seen[y-1];
            if(y<8) neighbors|=seen[y+1];
            grown[y]=seen[y]|((neighbors|(neighbors<<1u)|(neighbors>>1u))&occupied[y]&511u);
            changed=changed || grown[y]!=seen[y];
            columns|=grown[y];
            if(grown[y]!=0u) {first=min(first,y);last=max(last,y);}
        }
        int span=max(findMSB(columns)-findLSB(columns),last-first);
        if(span>=min_span) {keep=true;break;}
        if(!changed) break;
        for(int y=0;y<9;y++) seen[y]=grown[y];
    }
    imageStore(clean_image,q,keep?edge:vec4(0));
}
