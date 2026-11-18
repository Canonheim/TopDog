from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageFilter
import math
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'kit/effects';OUT.mkdir(parents=True,exist_ok=True)
W,H=512,256
fontpath='C:/Windows/Fonts/cambria.ttc'
def font(n):return ImageFont.truetype(fontpath,n,index=1)
def text(d,xy,s,n=48,anchor='mm'):
 d.text(xy,s,font=font(n),fill='white',anchor=anchor)
def line(d,pts,width=4):d.line(pts,fill='white',width=width,joint='curve')
def arrow(d,a,b):
 line(d,[a,b],3);v=(a[0]-b[0],a[1]-b[1]);ang=math.atan2(v[1],v[0]);line(d,[(b[0]+11*math.cos(ang-.5),b[1]+11*math.sin(ang-.5)),b,(b[0]+11*math.cos(ang+.5),b[1]+11*math.sin(ang+.5))],3)
images=[]
for k in range(12):
 im=Image.new('RGBA',(W,H));d=ImageDraw.Draw(im)
 if k==0:
  text(d,(256,83),'ax² + bx + c = 0',49)
  text(d,(80,171),'x =',47)
  text(d,(310,143),'−b ± √(b² − 4ac)',38);line(d,[(148,172),(480,172)],3);text(d,(310,200),'2a',37)
 elif k==1:
  text(d,(256,104),'a² + b² = c²',64);text(d,(256,185),'sin² θ + cos² θ = 1',39)
 elif k==2:
  text(d,(256,102),'d/dx (xⁿ) = nxⁿ⁻¹',50);text(d,(256,182),'d/dx (sin x) = cos x',39)
 elif k==3:
  text(d,(256,103),'∫ 2x dx = x² + C',53);text(d,(256,184),'∫ cos x dx = sin x + C',37)
 elif k==4:
  text(d,(256,104),'exp(iπ) + 1 = 0',58);text(d,(256,183),'exp(iθ) = cos θ + i sin θ',35)
 elif k==5:
  text(d,(256,98),'lim  sin x / x = 1',52);text(d,(91,145),'x → 0',26);text(d,(270,205),'1 + 2 + ⋯ + n = n(n+1)/2',33)
 elif k==6:
  d.ellipse((26,25,226,225),outline='white',width=4);arrow(d,(126,125),(216,83));d.ellipse((122,121,130,129),fill='white');text(d,(174,80),'r',31)
  text(d,(373,95),'A = πr²',43);text(d,(373,164),'C = 2πr',43)
 elif k==7:
  line(d,[(40,200),(40,37),(260,200),(40,200)],4);line(d,[(40,180),(60,180),(60,200)],3)
  text(d,(25,123),'a',30);text(d,(148,223),'b',30);text(d,(165,101),'c',30);text(d,(382,93),'a² + b²',38);text(d,(382,145),'= c²',38)
 elif k==8:
  line(d,[(125,25),(30,195)],4);line(d,[(125,25),(220,195)],4);d.ellipse((30,171,220,219),outline='white',width=4);line(d,[(125,25),(125,195),(220,195)],3);text(d,(141,112),'h',28);text(d,(172,179),'r',28)
  text(d,(380,105),'V = ⅓πr²h',38);text(d,(370,169),'A = πr²',35)
 elif k==9:
  arrow(d,(25,210),(260,210));arrow(d,(143,225),(143,24))
  pts=[(143+x,210-.013*x*x) for x in range(-113,114,2)];line(d,pts,4);text(d,(280,211),'x',26);text(d,(125,27),'y',26);text(d,(383,93),'y = x²',45);text(d,(378,164),'y′ = 2x',39)
 elif k==10:
  arrow(d,(20,130),(290,130));arrow(d,(45,224),(45,23));line(d,[(45+x,130-65*math.sin(x/36)) for x in range(233)],4)
  text(d,(374,83),'y = sin x',39);text(d,(376,161),'T = 2π',40);text(d,(154,153),'π',24)
 else:
  arrow(d,(50,208),(260,208));arrow(d,(50,208),(50,25));arrow(d,(50,208),(222,63));line(d,[(222,63),(222,208)],2)
  text(d,(157,224),'a',28);text(d,(242,137),'b',28);text(d,(127,98),'v',31);text(d,(389,94),'v = (a, b)',35);text(d,(377,166),'|v| = √(a²+b²)',29)
 # Tiny dark outline keeps the light mathematics legible over colorful scenery.
 alpha=im.getchannel('A');halo=alpha.filter(ImageFilter.MaxFilter(7));back=Image.new('RGBA',(W,H),(12,24,35,0));back.putalpha(halo.point(lambda x:int(x*.82)));back.alpha_composite(im);images.append(back)
atlas=Image.new('RGBA',(W*4,H*3))
for i,im in enumerate(images):atlas.alpha_composite(im,((i%4)*W,(i//4)*H))
atlas.save(OUT/'math_atlas.png')
