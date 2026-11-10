"""Mar de Bronce: original Mexican seafaring instrumental, not a song transcription.
80 BPM, 3/4, 32 bars / 96 quarter beats / 72 seconds / 3175200 frames at 44100 Hz.
D harmonic/natural minor. A A' B C, final A7 resolving to Dm at the loop seam.
GeneralUser GS / sf_kit settings from docs/music/MAKING_MUSIC.md.
Channels: 1 Concert Choir Mono (wordless low lead), 2 Trumpet, 3 Trumpet 2,
4 Nylon Guitar (vihuela-style sparse strums), 5 Acoustic Bass (guitarron-style),
6 Violin, 7 Trombone, 8 Marimba, 10 Standard Kit (kick, low tom, conga, side stick).
Fixed seed 1112. Run: python theme_mar_de_bronce.py --out <directory>
"""
from pathlib import Path
import argparse,random,json
import numpy as np,soundfile as sf,pyloudnorm as pyln
from sf_kit import Song
from theme_ring_rally import validate_midi
BPM=80
CH={'Dm':(38,[57,62,65]),'Bb':(34,[58,62,65]),'Gm':(31,[55,58,62]),'A7':(33,[55,57,61,64]),'F':(29,[57,60,65]),'C':(36,[55,60,64])}
PROG=['Dm','Dm','Bb','A7','Gm','Dm','Bb','A7']*2+['F','C','Dm','Bb','Gm','Dm','Bb','A7']+['Dm','Bb','Gm','A7','Dm','Gm','A7','A7']
A=[[(57,1),(62,1.5),(60,.5)],[(57,2),(0,1)],[(58,1.5),(62,.5),(65,1)],[(64,2),(61,1)],[(62,1),(58,1),(55,1)],[(57,1.5),(65,.5),(62,1)],[(65,1),(62,1),(58,1)],[(61,2),(0,1)]]
B=[[(65,1.5),(69,.5),(67,1)],[(64,2),(60,1)],[(62,1),(65,1),(69,1)],[(70,2),(65,1)],[(67,1.5),(65,.5),(62,1)],[(65,1),(62,2)],[(58,1),(62,1),(65,1)],[(64,1),(61,1),(0,1)]]
C=[[(62,1),(65,1),(69,1)],[(70,1.5),(65,.5),(62,1)],[(67,2),(62,1)],[(64,1),(61,2)],[(65,1.5),(62,.5),(57,1)],[(58,1),(62,1),(67,1)],[(64,1.5),(61,.5),(57,1)],[(61,2),(0,1)]]
def build():
 rng=random.Random(1112);s=Song(tempo=BPM,numerator=3)
 choir=s.track('Concert Choir Mono');trumpet=s.track('Trumpet');second=s.track('Trumpet 2');guitar=s.track('Nylon Guitar');bass=s.track('Acoustic Bass');violin=s.track('Violin');bone=s.track('Trombone');mar=s.track('Marimba');dr=s.drums()
 for tr,vol,pan in [(choir,83,64),(trumpet,89,52),(second,65,78),(guitar,75,29),(bass,108,64),(violin,58,84),(bone,67,45),(mar,53,74),(dr,92,64)]:tr.cc(7,vol,at=0);tr.cc(10,pan,at=0)
 for bar,ch in enumerate(PROG):
  b=bar*3;root,voices=CH[ch];section=bar//8;big=section==3
  bass.at(b).note(root,1.7,100 if big else 90)
  bass.at(b+2).note(root+7,.75,88 if big else 79)
  # Deliberate three-beat Mexican accompaniment; no chattering offbeat guitar.
  guitar.at(b+1).chord(voices,.64,76 if big else 65,strum=.018)
  guitar.at(b+2).chord(voices,.62,68 if big else 58,strum=.018)
  dr.hit('Kick',b,vel=101 if big else 88,dur=.16)
  dr.hit('Low Floor Tom',b,vel=82 if big else 69,dur=.18)
  dr.hit('Low Conga',b+2,vel=74 if big else 59,dur=.15)
  if section in (1,3): dr.hit('Side Stick',b+1,vel=61)
  if bar%8==7:
   dr.hit('Low Tom',b+2,vel=74);dr.hit('Low Floor Tom',b+2.5,vel=82)
  if section in (1,3):violin.at(b).note(voices[-1]+12,2.65,61 if big else 51)
  if section==2:
   mar.at(b+1).note(voices[1]+12,.75,59)
   mar.at(b+2).note(voices[-1]+12,.75,53)
  melody=(A+A+B+C)[bar];assert sum(d for _,d in melody)==3
  pos=b
  for n,d in melody:
   if n:
    assert n%12 in {0,1,2,4,5,7,9,10}
    choir.at(pos).note(n-12,d*.91,83 if big else 72)
    if section==1:trumpet.at(pos).note(n+12,d*.82,79+rng.randint(-3,3))
    elif section==2:trumpet.at(pos).note(n,d*.88,72+rng.randint(-3,3))
    elif big:
     trumpet.at(pos).note(n+12,d*.85,90+rng.randint(-3,3))
     # In-phase harmony, chord tone a third or fourth below.
     harm=next((n+12-drop for drop in (3,4,5) if (n+12-drop)%12 in {v%12 for v in voices}),n+12)
     second.at(pos).note(harm,d*.83,80)
    if section in (0,3):bone.at(pos).note(n-12,d*.86,65 if section==0 else 78)
   pos+=d
 return s
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--out',required=True);a=parser.parse_args();out=Path(a.out);out.mkdir(parents=True,exist_ok=True)
 s=build();wav=out/'mar_de_bronce.wav';s.save_midi(str(wav.with_suffix('.mid')));notes=validate_midi(wav.with_suffix('.mid'))
 s.render_loop(str(wav),loop_beats=96,reps=4,gain=.40)
 x,r=sf.read(wav);assert len(x)==3175200
 measured=pyln.Meter(r).integrated_loudness(x);gain=min(10**((-16.3-measured)/20),.89/np.max(abs(x)))
 sf.write(wav,x*gain,r,subtype='PCM_16');x,r=sf.read(wav)
 seam=float(np.max(abs(x[0]-x[-1])));delta=float(np.mean(abs(np.diff(x[:,0]))));assert seam<4*delta
 report={'BPM':BPM,'meter':'3/4','bars':32,'seconds':len(x)/r,'LUFS':pyln.Meter(r).integrated_loudness(x),'peak_dBFS':float(20*np.log10(np.max(abs(x)))),'seam':'OK','validated_notes':notes}
 (out/'measurements.json').write_text(json.dumps(report,indent=2));print(json.dumps(report,indent=2))
