"""Stationary atlas-mapped donkey. Metres, Y up, facing +X."""
import math
import struct
import json
from pathlib import Path

def add(a, b):
    return tuple(x + y for x, y in zip(a, b))


def sub(a, b):
    return tuple(x - y for x, y in zip(a, b))


def scale(v, k):
    return tuple(x * k for x in v)


def dot(a, b):
    return sum(x * y for x, y in zip(a, b))


def unit(v):
    return scale(v, 1 / math.sqrt(dot(v, v)))


def cross(a, b):
    x, y, z = a
    i, j, k = b
    return (y*k-z*j, z*i-x*k, x*j-y*i)



parts = {}


def cell(col, row):
    return (col*32+16, row*32+16)


COAT = cell(13,38)
LIGHT = cell(60,36)
CREAM = cell(54,34)
DARK = cell(0,33)
INNER = cell(39,35)


def face(name, points, color):
    # One flat polygon normal avoids artificial diagonal shading on quads.
    normal=[0.0,0.0,0.0]
    for a,b in zip(points,points[1:]+points[:1]):
        normal[0]+=(a[1]-b[1])*(a[2]+b[2])
        normal[1]+=(a[2]-b[2])*(a[0]+b[0])
        normal[2]+=(a[0]-b[0])*(a[1]+b[1])
    normal=unit(normal)
    for i in range(2,len(points)):
        parts.setdefault(name,[]).extend((p,normal,color) for p in [points[0],points[i-1],points[i]])


def loft(name, path, color=COAT, sides=16, belly=False):
    rings = []
    for i,(x,y,z,ru,rv) in enumerate(path):
        tangent = unit(sub(path[min(i+1,len(path)-1)][:3],path[max(i-1,0)][:3]))
        axis = (0,1,0) if abs(tangent[2]) > .9 else (0,0,1)
        u = unit(cross(axis,tangent))
        v = cross(tangent,u)
        rings.append([add((x,y,z),add(scale(u,ru*math.cos(math.tau*j/sides)),
                                   scale(v,rv*math.sin(math.tau*j/sides)))) for j in range(sides)])
    face(name,rings[0][::-1],color)
    for a,b in zip(rings,rings[1:]):
        for j in range(sides):
            k=(j+1)%sides
            tint = color
            if belly and sides*.34<=j<sides*.66:
                tint = LIGHT
            face(name,[a[j],a[k],b[k],b[j]],tint)
    face(name,rings[-1],color)


def oval(name, center, rx, ry, depth, color, sign=1):
    x,y,z = center
    outer=[(x+rx*math.cos(i*math.tau/12),y+ry*math.sin(i*math.tau/12),z)
           for i in range(12)]
    for i in range(12):
        tri=[outer[i],outer[(i+1)%12],(x,y,z+sign*depth)]
        face(name,tri if sign>0 else tri[::-1],color)


def build():
    g=globals()
    face, loft, oval, cell = (g[n] for n in ('face','loft','oval','cell'))
    import math
    coat=cell(60,36); pale=cell(54,34); dark=cell(0,33)
    warm=cell(39,35); highlight=cell(13,38)

    # Explicit vertical sections keep the saddle of the back level while the
    # belly swells; the shoulder rises into a compact, muscular chest.
    def section(name, rows, sides=16, color=coat, belly=False):
        rings=[]
        for x,top,bottom,width in rows:
            cy=(top+bottom)/2; ry=(top-bottom)/2
            rings.append([(x,cy+ry*math.cos(j*math.tau/sides),width*math.sin(j*math.tau/sides)) for j in range(sides)])
        face(name,rings[0][::-1],color)
        for ring_index,(a,b) in enumerate(zip(rings,rings[1:])):
            for j in range(sides):
                k=(j+1)%sides
                face(name,[a[j],a[k],b[k],b[j]],pale if belly and 1<ring_index<5 and 6<=j<=9 else color)
        face(name,rings[-1],color)

    section('body',[(-.93,1.16,.98,.10),(-.86,1.34,.83,.27),
        (-.67,1.40,.73,.36),(-.38,1.36,.68,.395),(-.06,1.34,.70,.38),
        (.20,1.39,.78,.32),(.38,1.43,.92,.24),(.46,1.30,1.04,.13)],belly=True)
    # Broad lower neck fits inside the shoulder; no thin cylindrical neck.
    loft('neck',[(.21,1.10,0,.20,.23),(.32,1.33,0,.25,.255),
        (.43,1.53,0,.23,.23),(.53,1.71,0,.17,.20),(.60,1.79,0,.11,.15)],coat,16)
    # Heavy cheek, convex forehead and short, wide soft nose distinguish a
    # donkey from a long narrow horse face.
    loft('head',[(.48,1.73,0,.08,.12),(.60,1.80,0,.155,.20),
        (.75,1.72,0,.23,.23),(.89,1.56,0,.19,.205),
        (1.02,1.42,0,.135,.185)],coat,16)
    loft('muzzle',[(.96,1.46,0,.14,.185),(1.075,1.37,0,.17,.215),
        (1.18,1.34,0,.135,.205),(1.235,1.36,0,.07,.14)],pale,16)
    # Four planted feet with visibly different front and rear anatomy.
    for s in (-1,1):
        tag='near' if s>0 else 'far'; z=s*.255; dx=-.08 if s<0 else .035
        loft(tag+'_foreleg',[(.25+dx,1.27,s*.12,.09,.09),(.28+dx,1.08,s*.16,.10,.095),(.29+dx,.88,z,.085,.08),
            (.32+dx,.59,z,.07,.067),(.32+dx,.53,z,.079,.076),
            (.30+dx,.24,z,.046,.052),(.34+dx,.13,z,.06,.063)],coat,10)
        loft(tag+'_hindleg',[(-.67+dx,1.28,s*.10,.10,.10),(-.64+dx,1.03,s*.19,.16,.12),
            (-.59+dx,.81,s*.23,.145,.095),(-.69+dx,.51,z,.075,.070),
            (-.72+dx,.43,z,.061,.060),(-.70+dx,.24,z,.053,.058),(-.69+dx,.14,z,.05,.057)],coat,10)
        for label,x in [('fore',.34+dx),('hind',-.69+dx)]:
            # Forward flare and slanted toe, with a single bevel.
            section(tag+'_'+label+'_hoof',[(x-.07,.095,.016,.055),
                (x-.025,.16,.006,.09),(x+.09,.075,.006,.10),
                (x+.105,.055,.018,.065)],8,dark)
            # Shift the locally authored hoof's depth to its leg.
            g['parts'][tag+'_'+label+'_hoof']=[((p[0],p[1],p[2]+z),n,c) for p,n,c in g['parts'][tag+'_'+label+'_hoof']]

        # Leaf-shaped ears, cupped toward the viewing side. Deliberately
        # asymmetric rake keeps both ears readable in profile.
        ex=.51 if s<0 else .72; ez=.135*s; tilt=-.19 if s<0 else .09
        rings=[(ex,1.80,ez,.045,.045),(ex+tilt*.2,1.90,ez,.077,.052),
            (ex+tilt*.65,2.075,ez,.088,.044),(ex+tilt*.94,2.22,ez,.046,.025),
            (ex+tilt,2.25,ez,.012,.012)]
        loft(tag+'_ear',rings,coat,10)
        leaf=[(ex-.040,1.88,ez+.048),(ex+tilt*.55-.064,2.04,ez+.047),
            (ex+tilt,2.217,ez+.028),(ex+tilt*.65+.054,2.08,ez+.046),
            (ex+.040,1.91,ez+.053)]
        face(tag+'_ear_inner',leaf[::-1],pale)
        leaf2=[(ex-.015,1.925,ez+.056),(ex+tilt*.6-.035,2.06,ez+.052),
            (ex+tilt,2.18,ez+.034),(ex+tilt*.65+.025,2.07,ez+.052)]
        face(tag+'_ear_inner',leaf2[::-1],warm)
        # Almond shaped eye set into the cheek, a dark lid, a single glint.
        oval(tag+'_eye_rim',(.77,1.688,s*.218),.071,.052,.012,pale,s)
        oval(tag+'_eye',(.779,1.69,s*.232),.045,.035,.014,dark,s)
        oval(tag+'_eye_glint',(.789,1.703,s*.247),.011,.010,.002,pale,s)
        lid=[(.704,1.712,s*.229),(.750,1.736,s*.224),(.811,1.725,s*.222),
            (.833,1.706,s*.229),(.774,1.717,s*.246)]
        face(tag+'_brow',lid if s<0 else lid[::-1],coat)
        oval(tag+'_nostril',(1.156,1.399,s*.191),.033,.043,.008,dark,s)
        lip=[(1.018,1.239,s*.158),(1.103,1.217,s*.161),(1.177,1.242,s*.149),
            (1.106,1.230,s*.169)]
        face(tag+'_mouth',lip if s<0 else lip[::-1],dark)
    # Short upright mane follows the full nape, ending in a small forelock.
    ridge=[(.055,1.40),(.075,1.48),(.115,1.54),(.135,1.61),
        (.18,1.67),(.21,1.73),(.26,1.78),(.30,1.82),(.35,1.85),(.41,1.86),(.48,1.85)]
    for i,((x,y),(a,b)) in enumerate(zip(ridge,ridge[1:])):
        width=.035 * min(1,(i+1)/2,(len(ridge)-i)/3)
        face('dark_mane',[(x,y,-width),(x,y,width),(a,b,width),(a,b,-width)],dark)
        for s in (-1,1):
            q=[(x,y,s*width),(x+.075,y-.07,s*width),(a+.075,b-.07,s*width),(a,b,s*width)]
            face('dark_mane',q if s>0 else q[::-1],dark)
    loft('tail',[(-.87,1.20,0,.038,.036),(-1.015,1.03,.025,.031,.03),
        (-1.06,.76,.06,.025,.025),(-1.095,.57,.09,.023,.025)],coat,8)
    loft('tail_tuft',[(-1.085,.64,.09,.025,.03),(-1.13,.52,.10,.068,.060),
        (-1.16,.36,.10,.04,.038),(-1.18,.30,.10,.007,.008)],dark,8)

    # Compress the upper silhouette into a sturdy, compact donkey bearing.
    for name,vertices in g['parts'].items():
        g['parts'][name]=[((p[0], 1.4+(p[1]-1.4)*.84 if p[1]>1.4 else p[1],p[2]), n,c) for p,n,c in vertices]
    # Transform the existing flat polygon normals by the inverse scale.
    for name,vertices in g['parts'].items():
        g['parts'][name]=[(p,unit((n[0],n[1]/.84,n[2])) if p[1]>1.4 else n,
            pale if ('foreleg' in name or 'hindleg' in name) and p[1]<=.241 else c) for p,n,c in vertices]
        # Keep the color constant across each face, including ankle boundaries.
        vs=g['parts'][name]
        for i in range(0,len(vs),3):
            color=pale if ('foreleg' in name or 'hindleg' in name) and max(v[0][1] for v in vs[i:i+3])<=.241 else vs[i][2]
            if 'foreleg' in name or 'hindleg' in name:
                color=pale if max(v[0][1] for v in vs[i:i+3])<=.241 else coat
            for k in range(i,i+3):
                p,n,_=vs[k];vs[k]=(p,n,color)

def export(path, model=parts):
    binary = bytearray()
    doc = dict(asset=dict(version="2.0",generator="Top Dog prop builder"),scene=0,
               scenes=[dict(nodes=list(range(len(model))))],nodes=[],meshes=[],
               accessors=[],bufferViews=[],images=[dict(uri="../../palette/house_atlas.png")],
               samplers=[dict(magFilter=9728,minFilter=9728)],textures=[dict(source=0,sampler=0)],
               materials=[dict(name="PALETTE",pbrMetallicRoughness=dict(baseColorTexture=dict(index=0),
               metallicFactor=0,roughnessFactor=1))])
    def attribute(values):
        n=len(values[0])
        start=len(binary)
        for value in values:
            binary.extend(struct.pack("<"+"f"*n,*value))
        doc["bufferViews"].append(dict(buffer=0,byteOffset=start,byteLength=len(binary)-start,target=34962))
        doc["accessors"].append(dict(bufferView=len(doc["bufferViews"])-1,componentType=5126,
            count=len(values),type="VEC"+str(n),min=list(map(min,zip(*values))),max=list(map(max,zip(*values)))))
        return len(doc["accessors"])-1
    for name, vertices in model.items():
        positions,normals,pixels=zip(*vertices)
        attrs=dict(POSITION=attribute(positions),NORMAL=attribute(normals),
                   TEXCOORD_0=attribute([tuple((k+.5)/2048 for k in uv) for uv in pixels]))
        doc["nodes"].append(dict(name=name,mesh=len(doc["meshes"])))
        doc["meshes"].append(dict(name=name,primitives=[dict(attributes=attrs,material=0)]))
    assert sum(len(v)//3 for v in model.values()) < 2500
    doc["buffers"]=[dict(byteLength=len(binary))]
    header=json.dumps(doc,separators=(",",":")).encode()
    header+=b" "*(-len(header)%4)
    path.write_bytes(struct.pack("<4sII",b"glTF",2,28+len(header)+len(binary))+
        struct.pack("<I4s",len(header),b"JSON")+header+struct.pack("<I4s",len(binary),b"BIN\0")+binary)


if __name__ == "__main__":
    build()
    export(Path(__file__).parent / "models" / "donkey_base.glb")
    print(sum(len(v)//3 for v in parts.values()), "triangles")
