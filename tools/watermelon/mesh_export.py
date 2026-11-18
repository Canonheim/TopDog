"""Atlas GLB export helper; metres, Y up."""
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


