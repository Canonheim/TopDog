"""Sendero del Sol: original Mexican tropical-adventure instrumental.
120 BPM, 4/4; 48 bars / 192 beats / 96 seconds / 4233600 frames at 44100 Hz.
D major with B minor contrast; A A' B C D C', final A7 resolves to D.
Channel plan: 1 Steel Guitar with playable chord strumming; 2 Trumpet accents; 3 Marimba; 4 Flute; 5 Nylon Guitar;
6 Acoustic Bass (guitarron-style root/fifth); 7 Fast Strings; 8 Violin;
10 Standard Kit with congas, bongos, guiro and timbales. Fixed seed 1113.
Uses sf_kit / GeneralUser GS and house rendering settings. No reference samples.
Run: python theme_sendero_del_sol.py --out <directory>
"""
from pathlib import Path
import argparse,random,json
import numpy as np,soundfile as sf,pyloudnorm as pyln
from sf_kit import Song
from theme_ring_rally import validate_midi
CH={'D':(38,[57,62,66]),'G':(31,[55,59,62]),'A7':(33,[55,57,61,64]),'Bm':(35,[54,59,62]),'Em':(40,[55,59,64])}
P1=['D','G','D','A7','Bm','G','Em','A7']
P2=['Bm','G','D','A7','Bm','Em','G','A7']
PC=['D','G','Bm','A7','D','G','Em','A7']
PROG=P1+P1+P2+PC+P2+PC
A=[[(66,1),(69,.5),(71,.5),(74,1),(0,1)],[(71,1.5),(69,.5),(67,1),(62,1)],[(66,.5),(69,.5),(74,2),(73,1)],[(69,1),(64,1),(61,1),(0,1)],[(66,1),(71,1),(74,1),(78,1)],[(74,1.5),(71,.5),(67,1),(0,1)],[(67,1),(71,1),(76,1),(74,1)],[(73,1),(69,1),(64,1),(0,1)]]
B=[[(71,2),(66,1),(62,1)],[(67,1.5),(71,.5),(74,1),(0,1)],[(69,1),(66,1),(62,2)],[(64,1),(69,2),(0,1)],[(66,1),(71,2),(74,1)],[(76,1.5),(74,.5),(71,1),(67,1)],[(74,1),(71,1),(67,1),(62,1)],[(64,1),(61,1),(69,1),(0,1)]]
C=[[(74,1.5),(78,.5),(76,1),(74,1)],[(79,1),(78,1),(74,1),(71,1)],[(78,2),(74,1),(71,1)],[(76,1.5),(73,.5),(69,1),(0,1)],[(78,1),(81,1),(78,1),(74,1)],[(79,1.5),(78,.5),(74,1),(71,1)],[(76,1),(74,1),(71,1),(67,1)],[(73,1),(76,1),(69,1),(0,1)]]

def build():
 rng=random.Random(1113);s=Song(tempo=120)
 lead=s.track('Steel Guitar');harm=s.track('Trumpet');mar=s.track('Marimba');flute=s.track('Flute');gtr=s.track('Nylon Guitar');bass=s.track('Acoustic Bass');strings=s.track('Fast Strings');violin=s.track('Violin');dr=s.drums()
 for tr,vol,pan in [(lead,77,60),(harm,78,72),(mar,76,78),(flute,66,49),(gtr,0,30),(bass,96,64),(strings,47,70),(violin,45,38),(dr,91,64)]:tr.cc(7,vol,at=0);tr.cc(10,pan,at=0)
 for bar,ch in enumerate(PROG):
  sec=bar//8;chorus=sec in (3,5);quiet=sec==4;b=bar*4;root,voicing=CH[ch]
  for off,n,d,v in [(0,root,1.3,98),(2,root+7,1.2,89)]:bass.at(b+off).note(n,d,v-8*quiet)
  if not quiet and bar%2:bass.at(b+3.5).note(root,.35,78)
  for off in ([1,3] if quiet else [.5,1.5,2.5,3.5]):gtr.at(b+off).chord(voicing,.32,68+8*chorus+rng.randint(-3,3),strum=.012)
  if chorus:
   for off in (0,2):strings.at(b+off).chord([v+12 for v in voicing],1.8,63)
  elif sec==2:violin.at(b).note(voicing[-1]+12,3.7,54)
  if quiet:
   dr.hit('Low Conga',b,vel=58);dr.hit('Side Stick',b+3,vel=48)
  else:
   for off,v in [(0,99),(2,90)]:dr.hit('Kick',b+off,vel=v if chorus else v-9)
   for off in (1,3):dr.hit('Acoustic Snare' if chorus else 'Side Stick',b+off,vel=88 if chorus else 66)
   for k in range(8):dr.hit('Closed Hi-Hat',b+k*.5,vel=(52 if k%2 else 66)-5*(sec==2))
  for off,name,v in [(1.5,'Mute Hi Conga',61),(2.5,'Open Hi Conga',73),(3.5,'Low Conga',68)]:dr.hit(name,b+off,vel=v-16*quiet)
  if bar%2==0:
   dr.hit('Hi Bongo',b+.75,vel=55);dr.hit('Low Bongo',b+1.5,vel=59)
  if chorus:
   dr.hit('Tambourine',b+1,vel=54);dr.hit('Tambourine',b+3,vel=58)
  if bar%4==2 and not quiet:dr.hit('Short Guiro',b+3,vel=52)
  if bar%8==7:
   for k in range(4):dr.hit('High Timbale' if k%2 else 'Low Timbale',b+2+k*.5,vel=65+k*7)
  # Playable open/barre chord shapes, low-to-high string order.
  shapes={'D':[50,57,62,66],'G':[43,47,50,55,59,67],'A7':[45,52,55,61,64],'Bm':[47,54,59,62,66],'Em':[40,47,52,55,59,64]}
  shape=shapes[ch]
  # Distinct section grooves; the full eighth-note pickup remains at bar 24 (0:48).
  full=[(0,'d',88),(.5,'u',85),(1,'d',82),(1.5,'u',91),(2,'d',86),(2.5,'u',87),(3,'d',84),(3.5,'u',94)]
  if sec==0:
   strokes=[(0,'d',79),(1.5,'u',73),(2,'d',78),(3.5,'u',77)] if bar%2==0 else [(0,'d',76),(2.5,'u',78),(3,'d',73)]
  elif sec==1:
   strokes=[(0,'d',83),(1,'d',77),(1.5,'u',83),(2.5,'u',80),(3,'d',82),(3.5,'u',85)] if bar%2==0 else [(0,'d',84),(1.5,'u',83),(3,'d',78)]
  elif sec==2:
   strokes=[(0,'d',76),(2,'d',74),(3.5,'u',78)] if bar%2==0 else [(0,'d',74),(2.5,'u',77)]
  elif quiet:
   strokes=[(0,'d',68),(3,'u',70)] if bar%2==0 else [(0,'d',66)]
  else:
   strokes=full if bar%4 in (0,3) else [(0,'d',87),(1,'d',80),(1.5,'u',88),(2.5,'u',85),(3,'d',83),(3.5,'u',91)]
   if bar%4==2:strokes=[(0,'d',86),(1.5,'u',86),(2,'d',84),(3.5,'u',90)]
  # Keep each string ringing until that same string is struck again.
  attacks={pitch:[] for pitch in shape}
  for off,direction,vel in strokes:
   played=shape if direction=='d' else list(reversed(shape[-4:]))
   for k,pitch in enumerate(played):
    delay=k*(.018 if direction=='d' else .042)+rng.uniform(0,.003)
    attacks[pitch].append((off+delay,vel+rng.randint(-3,3)+(8 if direction=='u' and k==0 else 0)))
  for pitch,hits in attacks.items():
   hits.sort()
   for k,(off,vel) in enumerate(hits):
    stop=(hits[k+1][0]-.07) if k+1<len(hits) else 3.94
    if stop-off>.03:lead.at(b+off).note(pitch,stop-off,vel+4*chorus)
  melody=(A+A+B+C+B+C)[bar];assert sum(d for _,d in melody)==4
  pos=b
  for n,d in melody:
   if n:
    assert n%12 in {1,2,4,6,7,9,11}
    # Nylon guitar carries the complete melody in a warm guitar register.
    # Guitar supports the ensemble; marimba carries the melody between brass accents.
    if sec in (0,1,2,3,5):mar.at(pos).note(n,d*.75,70 if chorus else 65)
    # Brass answers alternate verse bars, then shares the chorus melody.
    trumpet_phrase=(sec==1 and bar%2==1) or (chorus and bar%4 in (0,2,3)) or (sec==2 and bar%4==3)
    if trumpet_phrase:harm.at(pos).note(n,d*.80,84 if chorus else 75)
    # Occasional tropical colour, kept below the guitar.
    if quiet and bar%4==0 and pos==b:flute.at(pos).note(n,d*.72,51)
   elif chorus or sec==1:
    # Brief trumpet punctuation only in rests in the melody.
    harm.at(pos).note(voicing[-1]+12,min(.5,d*.6),74)
   pos+=d
 return s
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--out',required=True);a=parser.parse_args();out=Path(a.out);out.mkdir(parents=True,exist_ok=True)
 s=build();wav=out/'sendero_del_sol_varied_brass.wav';s.save_midi(str(wav.with_suffix('.mid')));notes=validate_midi(wav.with_suffix('.mid'))
 s.render_loop(str(wav),loop_beats=192,reps=4,gain=.38)
 x,r=sf.read(wav);assert len(x)==4233600
 target=-16.3;gain=min(10**((target-pyln.Meter(r).integrated_loudness(x))/20),.89/np.max(abs(x)))
 sf.write(wav,x*gain,r,subtype='PCM_16');x,r=sf.read(wav)
 seam=float(np.max(abs(x[0]-x[-1])));delta=float(np.mean(abs(np.diff(x[:,0]))));assert seam<4*delta
 report={'BPM':120,'bars':48,'seconds':len(x)/r,'LUFS':pyln.Meter(r).integrated_loudness(x),'peak_dBFS':float(20*np.log10(np.max(abs(x)))),'seam':'OK','validated_notes':notes}
 (out/'measurements.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))
