"""Deterministic atlas watermelon kit, low-poly game props."""
import math,json
from pathlib import Path
from functools import lru_cache
from PIL import Image
import mesh_export as m
ROOT=Path(__file__).resolve().parents[2]
im=Image.open(ROOT/'palette/house_atlas.png').convert('RGB')
@lru_cache(None)
def sw(rgb):
 pts=[(x,y) for y in range(1072,1248,32) for x in range(16,2048,32)]
 return min(pts,key=lambda p:sum((a-b)**2 for a,b in zip(im.getpixel(p),rgb)))
GREEN=sw((28,101,40));LIGHT=sw((111,164,66));PALE=sw((219,230,150));RED=sw((235,57,68));PINK=sw((247,91,104));BLACK=sw((25,23,24));SH=sw((53,44,39));SCAR=sw((141,116,66))
def face(ps,c):m.face('watermelon',ps,c)
def whole(oval=False):
 # Keep the 32 x 12 budget. Move stripe boundaries instead of changing face
 # colors between latitude rings: continuous pole-to-pole bands with no stairs.
 rings=[];n=32;bands=12
 for j in range(bands+1):
  latitude=-math.pi/2+j*math.pi/bands;r=max(.002,math.cos(latitude))
  ring=[]
  for i in range(n):
   stripe=i//4;fraction=[0,.23,.46,.73][i%4]
   angle=(stripe+fraction)*math.tau/8
   # Smooth, periodic angular deformation: seam joins exactly and each band
   # retains its identity at every latitude, including the converging poles.
   phase=.4 if oval else 0
   bend=.065*math.sin(3*latitude+angle*2+phase)+.027*math.sin(6*latitude-angle*3)
   angle+=bend
   ring.append((.20*r*math.cos(angle),(.25 if oval else .20)*math.sin(latitude),.20*r*math.sin(angle)))
  rings.append(ring)
 for a,b in zip(rings,rings[1:]):
  for i in range(n):
   k=(i+1)%n
   face([a[i],b[i],b[k],a[k]],GREEN if i%4<2 else LIGHT)
 y=.252 if oval else .202
 face([(.013*math.cos(i*math.tau/8),y,.013*math.sin(i*math.tau/8)) for i in reversed(range(8))],SCAR)

if __name__ == "__main__":
 for kind,oval in [("whole_round",False),("whole_oval",True)]:
  m.parts.clear();whole(oval)
  triangles=sum(len(v)//3 for v in m.parts.values())
  assert triangles == 774
  m.export(ROOT/'kit/models'/f'watermelon_{kind}.glb')
  print(kind,triangles,"triangles, one mesh, one atlas material")
