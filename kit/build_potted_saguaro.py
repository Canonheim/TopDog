"""Deterministic, atlas-mapped saguaro with a terracotta pot at 60 percent of its original size."""
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
    return (col * 32 + 16, row * 32 + 16)


CLAY = cell(31, 36)
CREAM = cell(54, 35)
GREEN = cell(21, 35)
LIGHT_GREEN = cell(58, 34)
DARK_GREEN = cell(35, 37)
SOIL = (152, 72)


def face(name, points, color):
    for end in range(2, len(points)):
        tri = [points[0], points[end-1], points[end]]
        normal = unit(cross(sub(tri[1], tri[0]), sub(tri[2], tri[0])))
        parts.setdefault(name, []).extend((p, normal, color) for p in tri)


def pot():
    # Closed ceramic wall, including its recessed interior and a chamfered rim.
    profile = [(.32,0),(.355,.025),(.355,.07),(.445,.515),
               (.480,.515),(.493,.54),(.493,.65),(.473,.675),
               (.422,.675),(.407,.65),(.407,.57),(.395,.55)]
    rings = [[(r*math.cos(math.tau*j/16),y,r*math.sin(math.tau*j/16))
              for j in range(16)] for r,y in profile]
    face("terracotta_pot",rings[0],CLAY)
    for i,(a,b) in enumerate(zip(rings,rings[1:])):
        for j in range(16):
            k=(j+1)%16
            face("terracotta_pot",[a[j],b[j],b[k],a[k]],CLAY)
    face("potting_soil",rings[-1][::-1],SOIL)
    # One cream band around the pot, with a repeating clay chevron cut into it.
    for j in range(16):
        angle=math.tau*j/16
        nxt=math.tau*(j+1)/16
        r=.494
        a=(r*math.cos(angle),.565,r*math.sin(angle))
        b=(r*math.cos(nxt),.565,r*math.sin(nxt))
        c=(r*math.cos(nxt),.615,r*math.sin(nxt))
        d=(r*math.cos(angle),.615,r*math.sin(angle))
        face("cream_rim_band",[a,d,c,b],CREAM)


def cactus(name, path):
    # Eight broad ribs, each a pair of facets. Tapered rings close the crown.
    rings = []
    for i,(x,y,z,r) in enumerate(path):
        p=(x,y,z)
        previous=path[max(0,i-1)][:3]
        following=path[min(len(path)-1,i+1)][:3]
        tangent=unit(sub(following,previous))
        u=unit(cross((0,0,1),tangent))
        v=cross(tangent,u)
        ring=[]
        for j in range(16):
            angle=math.tau*j/16
            radius=r*(1 if j%2==0 else .83)
            ring.append(add(p,add(scale(u,radius*math.cos(angle)),
                                  scale(v,radius*math.sin(angle)))))
        rings.append(ring)
    face(name,rings[0][::-1],DARK_GREEN)
    for a,b in zip(rings,rings[1:]):
        for j in range(16):
            k=(j+1)%16
            color=LIGHT_GREEN if j%2==0 else GREEN
            face(name,[a[j],a[k],b[k],b[j]],color)
    face(name,rings[-1],LIGHT_GREEN)


def spine(name, base, direction, length):
    # A few broad ivory spines keep the silhouette readable at gameplay distance.
    u=unit(cross(direction,(0,1,0)))
    v=cross(direction,u)
    ring=[add(base,add(scale(u,.009*math.cos(j*math.tau/4)),
                       scale(v,.009*math.sin(j*math.tau/4)))) for j in range(4)]
    tip=add(base,scale(direction,length))
    for j in range(4):
        face(name,[ring[j],ring[(j+1)%4],tip],CREAM)


def build():
    pot()
    cactus("ribbed_trunk",[(0,.535,0,.174),(0,.70,0,.186),(0,1.05,0,.181),
           (0,1.45,0,.169),(0,1.83,0,.152),(0,1.94,0,.125),
           (0,1.996,0,.070),(0,2.016,0,.012)])
    cactus("left_raised_arm",[(-.12,1.05,0,.112),(-.32,1.05,0,.119),
           (-.44,1.10,0,.119),(-.50,1.20,0,.114),(-.51,1.44,0,.108),
           (-.51,1.60,0,.092),(-.51,1.66,0,.055),(-.51,1.68,0,.009)])
    cactus("right_raised_arm",[(.13,1.31,0,.106),(.33,1.31,0,.112),
           (.43,1.36,0,.111),(.48,1.46,0,.108),(.48,1.66,0,.102),
           (.48,1.79,0,.080),(.48,1.84,0,.044),(.48,1.855,0,.009)])
    for y,r in [(.80,.184),(1.03,.180),(1.27,.174),(1.51,.165),(1.75,.155)]:
        for angle in [0,math.pi/2,math.pi,math.pi*1.5]:
            direction=(math.cos(angle),.16,math.sin(angle))
            spine("trunk_spines",(r*math.cos(angle),y,r*math.sin(angle)),unit(direction),.043)
    for x,ys,r in [(-.51,[1.31,1.51],.108),(.48,[1.52,1.71],.100)]:
        for y in ys:
            for angle in [0,math.pi/2,math.pi,math.pi*1.5]:
                direction=(math.cos(angle),.13,math.sin(angle))
                spine("arm_spines",(x+r*math.cos(angle),y,r*math.sin(angle)),unit(direction),.032)

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
    for name, vertices in parts.items():
        is_pot = name in ("terracotta_pot", "potting_soil", "cream_rim_band")
        parts[name] = [
            (scale(position, 0.6) if is_pot else add(position, (0, -0.22, 0)), normal, color)
            for position, normal, color in vertices
        ]
    export(Path(__file__).parent / "models" / "potted_saguaro.glb")
    print(sum(len(v)//3 for v in parts.values()), "triangles")
