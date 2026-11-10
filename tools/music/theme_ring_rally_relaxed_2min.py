"""Approved two-minute Ring Rally main menu loop, before added maraca buildups.
150 BPM, 75 bars, 300 beats, 5292000 stereo frames at 44100 Hz (120 seconds).
Two complete 32-bar cycles, eight verse bars, then existing F / C7 / A7 bars.
Guitars removed; acoustic root/fifth bass replaces pick bass; softer Standard Kit
and brass. Uses theme_ring_rally and theme_luchador score tables with sf_kit.
Run: python tools/music/theme_ring_rally_relaxed_2min.py
Dependencies: mido, numpy, soundfile, pyloudnorm, scipy; bundled FluidSynth and SF2.
Renders to audio/music relative to this script's repository, regardless of cwd.
"""
from pathlib import Path
import json
import numpy as np,soundfile as sf,pyloudnorm as pyln
from theme_ring_rally import build,validate_midi
OUT=Path(__file__).resolve().parents[2]/'audio/music';OUT.mkdir(parents=True,exist_ok=True)

def render(song,name,beats,target=None):
    wav=OUT/(name+'.wav');song.save_midi(str(wav.with_suffix('.mid')))
    validate_midi(wav.with_suffix('.mid'))
    song.render_loop(str(wav),loop_beats=beats,reps=4,gain=.35)
    x,r=sf.read(wav)
    if target is not None:
        gain=min(10**((target-pyln.Meter(r).integrated_loudness(x))/20),.89/np.max(abs(x)))
        sf.write(wav,x*gain,r,subtype='PCM_16');x,r=sf.read(wav)
    seam=float(np.max(abs(x[0]-x[-1])));delta=float(np.mean(abs(np.diff(x[:,0]))))
    assert seam<delta*4 and len(x)==round(beats*r*60/song.tempo)
    return {'file':str(wav),'seconds':len(x)/r,'LUFS':pyln.Meter(r).integrated_loudness(x),'seam':'OK','peak_dBFS':float(20*np.log10(np.max(abs(x))))}

s=build();s.tempo=150;s.tracks=[t for t in s.tracks if t.ch not in [3,6,8]]
for t in s.tracks:
    if t.ch==4:
        t._bank=0;t._prog=32;t.name='Acoustic Bass';t.events=[]
        from theme_luchador import PROG,CH
        for bar,ch in enumerate(PROG):
            root=CH[ch][0];fifth=root+7 if root+7<=52 else root-5
            t.at(bar*4).note(root,1.5,87);t.at(bar*4+2).note(fifth,1.5,80)
        t.cc(7,98,at=0);t.cc(10,64,at=0)
    elif t.ch==9:
        t._prog=0
        t.events=[e for e in t.events if e[1]=='cc' or e[2] not in [39,49,56]]
        t.events=[(tick,kind,n,max(1,round(v*.80)) if kind=='on' else v) for tick,kind,n,v in t.events]
    else:
        factor=.88 if t.ch in [0,1,2] else .94
        t.events=[(tick,kind,n,max(1,round(v*factor)) if kind=='on' else v) for tick,kind,n,v in t.events]

# 75 bars at 150 BPM = exactly 120 seconds. Two full approved cycles,
# then its eight-bar verse and existing F, C7, A7 bars as a closing turnaround.
# No new notes, instruments or altered performance velocities.
bar_order=list(range(32))*2+list(range(8))+[28,29,31]
assert len(bar_order)==75
for track in s.tracks:
    original=list(track.events)
    events=[e for e in original if e[1]=='cc']
    for dest,source in enumerate(bar_order):
        for tick,kind,n,v in original:
            if kind!='cc' and source*1920<=tick<(source+1)*1920:
                events.append((tick+(dest-source)*1920,kind,n,v))
    track.events=events
report=render(s,'top_dog_ring_rally_relaxed_2min',300,-16.3)
assert report['seconds']==120
(OUT/'relaxed_2min_measurements.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
