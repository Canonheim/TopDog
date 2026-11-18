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
def mix(a,b,t):return tuple(round(x*(1-t)+y*t) for x,y in zip(a,b))
COLORS=[(247,109,19),(186,215,31),(26,148,62),(244,176,24),(199,34,48)]
GLASS=(163,210,184);WHITE=(241,251,224);SILVER=(188,207,209)
def face(ps,c):m.face('Soda',ps,sw(c))
def ring(y,r,n):return [(r*math.cos(i*math.tau/n),y,r*math.sin(i*math.tau/n)) for i in range(n)]
def lathe(profile,n,colors,closed=True):
 rings=[ring(y,r,n) for y,r in profile]
 for j,(a,b) in enumerate(zip(rings,rings[1:])):
  for i in range(n):
   k=(i+1)%n;face([a[i],b[i],b[k],a[k]],colors[j])
 if closed:
  face(rings[0],colors[0]);face(rings[-1][::-1],colors[-1])
 return rings
def bottle(c):
 profile=[(-.27,.048),(-.26,.065),(-.245,.071),(-.225,.069),(-.045,.069),(.005,.064),(.065,.045),(.115,.028),(.215,.026),(.231,.027),(.237,.034),(.253,.034),(.259,.028)]
 colors=[mix(c,(28,70,45),.5),mix(c,(44,94,48),.2),c,c,c,c,mix(c,GLASS,.35),GLASS,GLASS,mix(GLASS,WHITE,.45),GLASS,mix(GLASS,WHITE,.6)]
 rings=lathe(profile,12,colors,False);face(rings[0],mix(c,(20,60,33),.6))
 inner=ring(.259,.020,12);low=ring(.243,.020,12)
 for i in range(12):
  k=(i+1)%12;face([rings[-1][i],inner[i],inner[k],rings[-1][k]],WHITE);face([inner[i],low[i],low[k],inner[k]],mix(GLASS,(24,69,38),.55))
 face(low[::-1],mix(c,(15,41,23),.7))
 # Thin atlas-colored highlights suggest glass without transparent shells.
 for first,last,angle,width in [(3,6,1.13,.10),(7,10,1.13,.12),(2,3,1.05,.35),(4,5,2.1,.06)]:
  for j in range(first,last):
   y0,r0=profile[j];y1,r1=profile[j+1]
   ps=[((rr+.001)*math.cos(a),y,(rr+.001)*math.sin(a)) for y,rr,a in [(y0,r0,angle-width),(y1,r1,angle-width),(y1,r1,angle+width),(y0,r0,angle+width)]]
   face(ps,mix(WHITE,c,.13))
def cap(c):
 n=24;bottom=[((.047 if i%2==0 else .043)*math.cos(i*math.tau/n),-.016,(.047 if i%2==0 else .043)*math.sin(i*math.tau/n)) for i in range(n)]
 rim=ring(.003,.044,n);top=ring(.012,.037,n)
 for i in range(n):
  k=(i+1)%n;face([bottom[i],rim[i],rim[k],bottom[k]],SILVER if i%2==0 else (101,126,135));face([rim[i],top[i],top[k],rim[k]],WHITE)
 face(top[::-1],c);face(bottom,(201,213,207))
def drop(c):
 lathe([(-.057,.005),(-.041,.026),(-.01,.030),(.027,.018),(.066,.001)],8,[mix(c,(66,67,21),.2),c,c,mix(c,WHITE,.15)])
 # Single small shine facet, part of the same mesh/material.
 face([(-.011,-.013,.029),(-.007,.020,.021),(.003,.016,.024),(.003,-.010,.031)],mix(WHITE,c,.2))
manifest=[]
for family,fn in [('bottle',bottle),('cap',cap),('drop',drop)]:
 for index,c in enumerate(COLORS):
  m.parts.clear();fn(c);tri=sum(len(v)//3 for v in m.parts.values());name=f'{family}_{index}'
  m.export(ROOT/'kit/models'/f'soda_{name}.glb');manifest.append(dict(name=name,triangles=tri,meshes=1,materials=1))
(ROOT/'tools/sodas/manifest.json').write_text(json.dumps(manifest,indent=2));print(manifest)
