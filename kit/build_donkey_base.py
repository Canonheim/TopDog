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
    for i in range(2,len(points)):
        tri = [points[0],points[i-1],points[i]]
        normal = unit(cross(sub(tri[1],tri[0]),sub(tri[2],tri[0])))
        parts.setdefault(name,[]).extend((p,normal,color) for p in tri)


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
    # A heavy hindquarter, dipped back and raised withers form one continuous mass.
    loft("barrel_body",[(-.89,1.08,0,.10,.12),(-.82,1.09,0,.23,.25),
         (-.64,1.085,0,.31,.34),(-.39,1.035,0,.31,.355),
         (-.08,1.015,0,.32,.34),(.21,1.07,0,.33,.30),
         (.40,1.13,0,.27,.255),(.50,1.17,0,.12,.17)],belly=True)
    loft("sloping_neck",[(.23,1.05,0,.21,.235),(.35,1.25,0,.245,.235),
         (.49,1.48,0,.215,.205),(.59,1.66,0,.16,.175),
         (.63,1.72,0,.10,.135)])
    # Fuller poll and jowl taper into the characteristic long, downward donkey muzzle.
    loft("long_face",[(.57,1.70,0,.09,.12),(.65,1.73,0,.145,.18),
         (.77,1.66,0,.19,.20),(.87,1.51,0,.17,.174),
         (1.00,1.34,0,.125,.15)],sides=16)
    loft("pale_muzzle",[(.94,1.39,0,.135,.157),(1.045,1.285,0,.145,.175),
         (1.12,1.255,0,.11,.158),(1.16,1.26,0,.055,.10)],CREAM,16)
    for sign in [-1,1]:
        side="near" if sign>0 else "far"
        z=.235*sign
        shift=-.12 if sign<0 else 0
        loft(side+"_front_leg",[(.31+shift,1.04,z,.125,.12),(.35+shift,.79,z,.09,.085),
             (.39+shift,.55,z,.065,.069),(.39+shift,.48,z,.075,.071),
             (.37+shift,.24,z,.043,.048),(.405+shift,.13,z,.052,.055)],COAT,10)
        loft(side+"_rear_leg",[(-.65+shift,1.07,z,.18,.15),(-.58+shift,.82,z,.15,.13),
             (-.65+shift,.61,z,.09,.08),(-.77+shift,.43,z,.066,.065),
             (-.72+shift,.30,z,.045,.050),(-.68+shift,.13,z,.051,.055)],COAT,10)
        for label,x in [("front",.405+shift),("rear",-.68+shift)]:
            loft(side+"_"+label+"_sock",[(x-.012,.12,z,.052,.056),
                 (x-.016,.205,z,.048,.051),(x-.023,.245,z,.043,.048)],LIGHT,10)
            loft(side+"_"+label+"_hoof",[(x+.035,.008,z,.098,.086),
                 (x+.031,.045,z,.103,.09),(x+.008,.125,z,.066,.066)],DARK,10)
            # A muted bevel on the hoof picks up light without a painted stripe.
            oval(side+"_"+label+"_hoof_edge",(x+.038,.045,z+sign*.086),.056,.014,.001,LIGHT,sign)
        earx=.54 if sign<0 else .72
        earz=.12*sign
        tilt=-.16 if sign<0 else .075
        loft(side+"_long_ear",[(earx,1.71,earz,.045,.043),
             (earx+tilt*.18,1.79,earz,.065,.049),
             (earx+tilt*.50,1.93,earz,.079,.042),
             (earx+tilt*.82,2.07,earz,.050,.028),
             (earx+tilt,2.13,earz,.008,.010)],COAT,10)
        # Layered cream rim and warm recess are broad enough to read in the ring.
        leaf=[(earx-.031,1.79,earz+.049),(earx-.050+tilt*.50,1.93,earz+.043),
              (earx+tilt,2.105,earz+.019),(earx+.050+tilt*.50,1.93,earz+.043),
              (earx+.031,1.79,earz+.049)]
        face(side+"_ear_inner",leaf[::-1],CREAM)
        inset=[(earx-.012,1.82,earz+.051),(earx-.028+tilt*.50,1.94,earz+.045),
               (earx+tilt,2.075,earz+.026),(earx+.025+tilt*.50,1.94,earz+.045),
               (earx+.012,1.82,earz+.051)]
        face(side+"_ear_inner",inset[::-1],INNER)
        # Dark almond eyes under a substantial lid, with a tiny ivory reflection.
        eye=(.795,1.622,sign*.188)
        oval(side+"_eye_rim",eye,.061,.044,.008,LIGHT,sign)
        oval(side+"_eye",(.802,1.620,sign*.201),.042,.028,.011,DARK,sign)
        oval(side+"_eye_glint",(.794,1.631,sign*.214),.009,.009,.001,CREAM,sign)
        lid=[(.746,1.643,sign*.197),(.787,1.669,sign*.191),
             (.836,1.644,sign*.196),(.816,1.638,sign*.208),(.778,1.649,sign*.207)]
        face(side+"_brow",lid if sign<0 else lid[::-1],COAT)
        oval(side+"_nostril",(1.080,1.301,sign*.164),.026,.038,.005,DARK,sign)
        # A restrained mouth crease follows the side of the pale muzzle.
        lip=[(.991,1.205,sign*.123),(1.075,1.203,sign*.128),
             (1.124,1.224,sign*.117),(1.076,1.216,sign*.136)]
        face(side+"_mouth",lip if sign<0 else lip[::-1],DARK)
    # A connected short bristly mane stands above the neck's rear edge.
    edge=[(.12,1.35),(.17,1.45),(.21,1.43),(.24,1.54),(.27,1.52),
          (.31,1.63),(.35,1.60),(.39,1.72),(.43,1.69),(.48,1.80),(.58,1.78)]
    for i in range(len(edge)-1):
        x,y=edge[i];a,b=edge[i+1]
        face("dark_mane",[(x,y,-.048),(x,y,.048),(a,b,.048),(a,b,-.048)],DARK)
        face("dark_mane",[(x,y,.048),(x+.085,y-.10,.048),(a+.085,b-.10,.048),(a,b,.048)],DARK)
        face("dark_mane",[(a,b,-.048),(a+.085,b-.10,-.048),(x+.085,y-.10,-.048),(x,y,-.048)],DARK)
    loft("tail",[(-.86,1.15,0,.037,.037),(-.97,1.00,.015,.031,.031),
         (-1.00,.79,.03,.025,.025),(-1.045,.56,.04,.024,.024)],COAT,8)
    loft("tail_tuft",[(-1.04,.63,.04,.030,.031),(-1.08,.51,.04,.067,.052),
         (-1.10,.37,.04,.035,.030),(-1.12,.32,.04,.006,.007)],DARK,8)

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
