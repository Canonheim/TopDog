from pathlib import Path
import sys,math,json
from functools import lru_cache
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools/watermelon'))
import mesh_export as m
im=Image.open(ROOT/'palette/house_atlas.png').convert('RGB')
@lru_cache(None)
def sw(c):
 pts=[(x,y) for y in range(1072,1248,32) for x in range(16,2048,32)]
 return min(pts,key=lambda p:sum((a-b)**2 for a,b in zip(im.getpixel(p),c)))
def face(ps,c):m.face('Onion',ps,sw(c))
WHITE=(238,238,220);SHADE=(211,213,184);ROOT_COLOR=(159,119,65)
def bulb(v):
 n=16;rings=[]
 for y,rad in [(-.16,.040),(-.14,.12),(-.075,.19),(0,.205),(.08,.19),(.14,.13),(.172,.065),(.180,.030)]:
  rings.append([(math.cos(i*math.tau/n)*rad*(1+v*.03),y*(1+v*.045),math.sin(i*math.tau/n)*rad) for i in range(n)])
 face(rings[0],ROOT_COLOR)
 for a,b in zip(rings,rings[1:]):
  for i in range(n):k=(i+1)%n;face([a[i],b[i],b[k],a[k]],SHADE if i%4==0 else WHITE)
 face(rings[-1][::-1],SHADE)
 for i in range(7):
  a=i*math.tau/7;dx=math.cos(a);dz=math.sin(a)
  m.loft('Onion',[(dx*.018,-.16,dz*.018,.003,.003),(dx*.038,-.177,dz*.035,.002,.002),(dx*.050,-.19,dz*.045,.0006,.0006)],sw(ROOT_COLOR),sides=4)
def crescent(v):
 rings=[];steps=14;radius=.20+v*.016
 for i in range(steps+1):
  t=i/steps;a=(-1.35+t*2.7);w=.004+.024*math.sin(math.pi*t);x=radius*math.sin(a);y=radius*math.cos(a)-.11
  rings.append([(x+dx*math.sin(a),y+dx*math.cos(a),z) for dx,z in [(-w,-.013),(w,-.013),(w,.013),(-w,.013)]])
 face(rings[0][::-1],WHITE)
 # Integrated broad layer bands partition the cut faces; no floating overlays.
 def lerp(a,b,t):return tuple(x+(y-x)*t for x,y in zip(a,b))
 for a,b in zip(rings,rings[1:]):
  for j in range(4):
   k=(j+1)%4
   if j in (0,2):
    cuts=[0,.36,.64,1]
    for strip in range(3):
     lo,hi=cuts[strip:strip+2]
     face([lerp(a[j],a[k],lo),lerp(a[j],a[k],hi),lerp(b[j],b[k],hi),lerp(b[j],b[k],lo)],(224,226,208) if strip==1 else WHITE)
   else:face([a[j],a[k],b[k],b[j]],WHITE)
 face(rings[-1],WHITE)

def dice(v):
 x=.035+v*.005;y=.035+(v%2)*.015;z=.03
 pts=[(-x,-y,-z),(x,-y,-z),(x,y,-z),(-x,y,-z),(-x,-y,z),(x,-y,z),(x,y,z),(-x,y,z)]
 for indices in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(3,7,6,2),(0,4,7,3),(1,2,6,5)]:face([pts[i] for i in indices],WHITE)
manifest=[]
for index in range(12):
 m.parts.clear()
 if index<4:bulb(index)
 elif index<8:crescent(index-4)
 else:dice(index-8)
 tri=sum(len(v)//3 for v in m.parts.values());m.export(ROOT/'kit/models'/f'onion_{index}.glb');manifest.append(dict(variant=index,triangles=tri,family=['whole','slice','dice'][index//4]))
(ROOT/'tools/onions/manifest.json').write_text(json.dumps(manifest,indent=2));print(manifest)
