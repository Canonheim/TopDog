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
def face(ps,c):m.face('Grass',ps,sw(c))
def blade(origin,length,width,bend,color,cut=False,lean=0):
 rings=[]
 for i in range(7):
  t=i/6;x=origin[0]+bend*t*t+lean*t;y=origin[1]+length*t;z=origin[2]+.035*math.sin(t*math.pi)
  w=width*(.65+.35*math.sin(t*math.pi))*(1-.97*t**3) if not cut else width*(.75+.25*math.sin(t*math.pi))
  rings.append([(x-w,y,z),(x,y,z+.003),(x+w,y,z),(x,y,z-.003)])
 face(rings[0][::-1],color)
 for a,b in zip(rings,rings[1:]):
  for j in range(4):face([a[j],a[(j+1)%4],b[(j+1)%4],b[j]],color if j%2 else tuple(min(255,int(v*1.15)) for v in color))
 face(rings[-1],color)
def kernel(x,y,z,r,h,c):
 pts=[(x-r,y,z),(x,y,z+r*.6),(x+r,y,z),(x,y,z-r*.6)]
 for j in range(4):
  face([pts[j],pts[(j+1)%4],(x,y+h,z)],c)
  face([pts[(j+1)%4],pts[j],(x,y-h*.6,z)],c)
colors=[(64,133,35),(98,165,38),(42,111,38),(123,171,43),(60,148,53),(145,183,58)]
manifest=[]
for index in range(12):
 m.parts.clear();c=colors[index%6]
 if index<6:blade((0,-.16,0),.24+index*.019,.009+index%3*.002,(-1 if index%2 else 1)*.035,c,cut=index%3==0)
 elif index<10:blade((0,-.25,0),.48+(index-6)*.04,.016,.10*(-1 if index%2 else 1),c)
 else:
  blade((0,-.33,0),.61,.004,.035,c)
  blade((.005,-.20,0),.30,.013,-.09,c)
  for i in range(9):
   y=.015+i*.029;x=.035*((y+.33)/.61)**2
   sign=-1 if (i+index)%2 else 1
   reach=sign*(.048-.0038*i)*(1+.12*math.sin(i*2.1))
   rise=.027+.013*(i%3)
   end=(x+reach,y+rise,math.sin(i*2.4)*.008)
   m.loft('Grass',[(x,y,0,.0017,.0017),(end[0]*.55+x*.45,y+rise*.55,end[2]*.5,.0012,.0012),(end[0],end[1],end[2],.0005,.0005)],sw(c),sides=4)
   for k in range(2):
    t=.63+k*.37
    kernel(x+reach*t,y+rise*t+.012,end[2]*t,.0045-.00012*i,.016+(i%2)*.003,(113,151,55))

 tri=sum(len(v)//3 for v in m.parts.values());m.export(ROOT/'kit/models'/f'grass_{index}.glb')
 manifest.append(dict(variant=index,family='clipping' if index<6 else 'blade' if index<10 else 'seed_head',triangles=tri))
(ROOT/'tools/grass/manifest.json').write_text(json.dumps(manifest,indent=2));print(manifest)
