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
def face(ps,c):m.face('Lipstick',ps,sw(c))
def mix(a,b,t):return tuple(round(x*(1-t)+y*t) for x,y in zip(a,b))
BLACK=(29,28,34);EDGE=(59,54,61);GOLD=(207,156,44);LIGHT=(245,216,133)
SILVER=(170,180,190);SILVER_LIGHT=(224,230,235)
COLORS=[(201,29,43),(156,30,43),(231,55,68),(180,58,47),(225,70,120),(242,118,145),(187,65,104),(215,104,127),(176,112,88),(206,151,117),(162,98,76),(185,122,115)]
def ring(y,r,n,slope=0,square=0):
 result=[]
 for i in range(n):
  a=i*math.tau/n;ca=math.cos(a);sa=math.sin(a);factor=(1-square)+square/max(abs(ca),abs(sa));x=r*ca*factor;z=r*sa*factor;result.append((x,y+slope*x,z))
 return result
def loft(profile,n,colors,square=0):
 rings=[ring(y,r,n,slope,square) for y,r,slope in profile]
 face(rings[0],colors[0])
 for j,(a,b) in enumerate(zip(rings,rings[1:])):
  for i in range(n):k=(i+1)%n;face([a[i],b[i],b[k],a[k]],colors[j])
 face(rings[-1][::-1],colors[-1]);return rings
def lipstick(index,c):
 form=index%4;n=12;square=.3 if form==3 else 0;radius=.046+(.003 if form==1 else 0);height=.19+form*.009
 base=[BLACK,GOLD,SILVER][index%3];edge=[EDGE,LIGHT,SILVER_LIGHT][index%3]
 profile=[(-height,radius*.86,0),(-height+.01,radius,0),(-.065,radius,0),(-.055,radius*1.02,0),(-.042,radius*1.02,0),(-.034,radius*.88,0),(.055,radius*.78,0),(.065,radius*.80,0)]
 metals=[((12,12,14),(36,35,40),(107,105,109)),((79,43,13),(188,125,29),(255,235,171)),((37,37,37),(126,126,126),(242,242,242))]
 # Lower casing and gold collar share band directions but have distinct metals.
 rings=[ring(y,r,n,slope,square) for y,r,slope in profile]
 face(rings[0],edge)
 for j,(a,b) in enumerate(zip(rings,rings[1:])):
  dark,mid,bright=metals[index%3 if j<3 else 1]
  for i,t in enumerate([.42,.16,.60,1.0,.72,.29,.12,.40,.83,.96,.55,.25]):
   k=(i+1)%n;color=mix(dark,mid,t*2) if t<.5 else mix(mid,bright,(t-.5)*2)
   if j in (0,3,4,6):color=mix(color,bright,.32)
   face([a[i],b[i],b[k],a[k]],color)
 face(rings[-1][::-1],LIGHT)
 lipradius=radius*.66;slope=.7+form*.07;top=.17+form*.012
 loft([(.05,lipradius,0),(.085,lipradius,0),(top-.009,lipradius,slope),(top,lipradius*.88,slope)],n,[c,c,mix(c,LIGHT,.13)])
 # Sparse baked highlight panels: same opaque atlas material, no reflections.
 for y0,y1,r,color in [(-height+.025,-.077,radius,[(135,135,135),(255,245,201),(250,250,250)][index%3]),(-.024,.047,radius*.78,LIGHT)]:
  a=1.08;w=.095
  face([((r+.001)*math.cos(t),y,(r+.001)*math.sin(t)) for y,t in [(y0,a-w),(y1,a-w),(y1,a+w),(y0,a+w)]],color)
manifest=[]
for index,c in enumerate(COLORS):
 m.parts.clear();lipstick(index,c);tri=sum(len(v)//3 for v in m.parts.values());assert tri<400
 m.export(ROOT/'kit/models'/f'lipstick_{index}.glb');manifest.append(dict(variant=index,triangles=tri,family=['red','pink','nude'][index//4],base=['black','gold','silver'][index%3]))
(ROOT/'tools/lipsticks/manifest.json').write_text(json.dumps(manifest,indent=2));print(manifest)
