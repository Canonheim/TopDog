"""Top Dog: ring-rally title variation, derived from theme_luchador.py.
168 BPM; 15750 samples/beat at 44100 Hz. 32 bars / 128 beats / 2016000 frames.
A(8) A2(8) B(8) C(8); D minor to F major, final A7 resolves to Dm.
Original Top Dog melody retained; ska/Latin-rock instrumentation and articulation.
No reference audio or reference melody is sampled into this arrangement.
Channels: 1 trumpet lead; 2 trumpet harmony; 3 trombone; 4 clean offbeat guitar;
5 pick bass; 6 marimba; 7 overdrive accents; 8 organ; 9 nylon guitar;
10 Power Kit. All other channels unused. Fixed seed 1110.
Run: python tools/music/theme_ring_rally.py --out <preview directory>
Requires repository sf_kit, theme_luchador, numpy, mido, soundfile, pyloudnorm.
Source melody/chord tables: theme_luchador.CH / PROG / MEL_A / MEL_A2 / MEL_B / MEL_C.
"""
import argparse,random,json
from pathlib import Path
import numpy as np
import soundfile as sf
import mido
import pyloudnorm as pyln
from sf_kit import Song
from theme_luchador import CH,PROG,MEL_A,MEL_A2,MEL_B,MEL_C,third_below
TEMPO=168
BEATS=128

def build():
    rng=random.Random(1110)
    s=Song(tempo=TEMPO)
    lead=s.track('Trumpet'); harmony=s.track('Trumpet 2'); bone=s.track('Trombone')
    guitar=s.track('Clean Guitar'); bass=s.track('Pick Bass'); marimba=s.track('Marimba')
    drive=s.track('Overdrive Guitar'); organ=s.track('Tonewheel Organ'); nylon=s.track('Nylon Guitar')
    drums=s.drums(kit=16)
    for tr,vol,pan in [(lead,96,58),(harmony,76,76),(bone,79,48),(guitar,89,35),(bass,105,64),(marimba,82,82),(drive,60,92),(organ,48,50),(nylon,66,20),(drums,100,64)]:
        tr.cc(7,vol,at=0);tr.cc(10,pan,at=0)
    for bar,ch in enumerate(PROG):
        b=bar*4; root,voicing=CH[ch]; fifth=root+7 if root+7<=52 else root-5
        bridge=16<=bar<24; chorus=bar>=24
        # Root/fifth bass with syncopated pickups, no chromatic passing notes.
        for off,n,d,v in [(0,root,.65,108),(1,root,.35,87),(1.5,fifth,.35,96),(2,root,.65,101),(3,fifth,.35,91),(3.5,root,.35,98)]:
            bass.at(b+off).note(n,d,v+rng.randint(-3,3))
        for k,off in enumerate([.5,1.5,2.5,3.5]):
            guitar.at(b+off).chord(voicing,.20,94 if k%2 else 86,strum=.007)
            if not bridge: nylon.at(b+off).chord(voicing,.18,72,strum=.009)
            if chorus or bridge: organ.at(b+off).chord(voicing,.22,65)
        if not bridge:
            for off in [0,2]: drive.at(b+off).chord([root+12,root+19],.45,89 if chorus else 76)
        for off,v in [(0,107),(1.5,81),(2,100),(3.5,88)]: drums.hit('Kick',b+off,vel=v)
        for off in [1,3]:
            drums.hit('Acoustic Snare',b+off,vel=103 if not bridge else 90)
            if chorus: drums.hit('Hand Clap',b+off,vel=65)
        for k in range(8):
            drums.hit('Closed Hi-Hat',b+k*.5,vel=[72,55,65,59,74,54,68,60][k]+rng.randint(-3,3),dur=.12)
            drums.hit('Maracas',b+k*.5,vel=44 if k%2 else 53)
        for off,name,v in [(1.5,'Mute Hi Conga',67),(2.5,'Open Hi Conga',76),(3.5,'Low Conga',72)]: drums.hit(name,b+off,vel=v)
        if chorus or bridge:
            for off in [0,1.5,2.5]: drums.hit('Cowbell',b+off,vel=63)
        if bar%8==0: drums.hit('Crash Cymbal 1',b,vel=83)
        if bar%8==7:
            for k in range(4): drums.hit('High Timbale' if k%2==0 else 'Low Timbale',b+2+k*.5,vel=78+k*6)
        # Terse horn answers occupy gaps rather than competing with the lead.
        if bar in [3,7,11]:
            for off,n in [(3,root+24),(3.5,fifth+24)]: bone.at(b+off).note(n,.28,94)
    allowed={0,1,2,4,5,7,9,10} # D minor / harmonic minor plus F major harmony.
    for sec,mel in enumerate([MEL_A,MEL_A2,MEL_B,MEL_C]):
        assert sum(d for _,d in mel)==32
        t=sec*32
        for n,d in mel:
            if n:
                assert n%12 in allowed
                tr=marimba if sec==2 else lead
                tr.at(t).note(n,d*(.65 if sec==2 else .74),98+rng.randint(-4,4))
                if sec in [1,3]: harmony.at(t).note(third_below(n,PROG[int(t//4)]),d*.70,87)
                if sec==2: bone.at(t).note(n-12,d*.72,82)
            t+=d
    return s

def validate_midi(path):
    active={}; count=0
    for track in mido.MidiFile(path).tracks:
        for m in track:
            if m.type=='note_on' and m.velocity:
                key=(m.channel,m.note);assert active.get(key,0)==0,('overlap',key)
                active[key]=1;count+=1
            elif m.type=='note_off' or (m.type=='note_on' and m.velocity==0):
                key=(m.channel,m.note);assert active.get(key,0)==1,('unpaired',key);active[key]=0
    assert not any(active.values())
    return count

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--out',required=True);args=parser.parse_args()
    out=Path(args.out);out.mkdir(parents=True,exist_ok=True)
    song=build(); midi=out/'top_dog_ring_rally.mid';song.save_midi(str(midi));notes=validate_midi(midi)
    wav=out/'top_dog_ring_rally.wav'
    song.render_loop(str(wav),loop_beats=BEATS,reps=4,gain=.35)
    x,sr=sf.read(wav);assert sr==44100 and len(x)==2016000
    # Level matching is part of the reproducible rendering script.
    current=Path(__file__).resolve().parents[2]/'audio/music/top_dog_theme.ogg'
    ref,rr=sf.read(current)
    target=pyln.Meter(rr).integrated_loudness(ref); measured=pyln.Meter(sr).integrated_loudness(x)
    gain=min(10**((target-measured)/20),.89/np.max(abs(x)))
    sf.write(wav,x*gain,sr,subtype='PCM_16');x,sr=sf.read(wav)
    seam=float(np.max(abs(x[0]-x[-1])));delta=float(np.mean(abs(np.diff(x[:,0]))))
    assert seam<4*delta
    report={'tempo':TEMPO,'bars':32,'beats':BEATS,'frames':len(x),'seconds':len(x)/sr,'seam':seam,'mean_sample_step':delta,'seam_verdict':'OK','LUFS':pyln.Meter(sr).integrated_loudness(x),'current_title_LUFS':target,'peak_dBFS':20*np.log10(np.max(abs(x))),'validated_notes':notes}
    (out/'ring_rally_measurements.json').write_text(json.dumps(report,indent=2))
    print(json.dumps(report,indent=2))
