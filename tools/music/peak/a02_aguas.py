"""A2 LAS AGUAS NEGRAS: bowed bass, dripping marimba, low accordion swells.

Plain (the D bars have no third: D E A, hollow). No pulse but the bass re-bowing each bar.
A bowed double bass holds the plan's roots, a low accordion breathes in two-bar swells, a
bandoneon low in its range speaks the call and the tune's second halves, and a marimba drips
from the roof (seeded, so every build is the same water). The marimba also drips the call
itself in bars 17-18 and 25-26.

Channels: 1 Double Bass, 2 Accordion (pad), 3 Bandoneon (call and tune, low), 4 Marimba.
"""
from peak_common import *

INDEX, NAME, MODE, RESOLVED = 2, "Las Aguas Negras", "plain", False
RENDER = dict(gain=0.5, fx_extra=["-o", "synth.reverb.level=0.6", "-o", "synth.reverb.room-size=0.8"])

PAD = {"D": [50, 57, 64], "G": [55, 59, 62], "Bm": [54, 59, 62], "Em": [52, 55, 59], "A": [52, 57, 61]}


def build():
    rng = random.Random(102)
    s = Song(tempo=TEMPO)
    cb = part(s, "Double Bass", vol=108, pan=64, rev=60)
    pad = part(s, "Accordion", vol=92, pan=44, rev=80)
    lead = part(s, "Bandoneon", vol=104, pan=78, rev=90)
    mar = part(s, "Marimba", vol=96, pan=58, rev=115)

    for bar, ch in enumerate(PLAN):
        b0 = bar * 4.0
        cb.at(b0).note(bass(ch), 4.0, 80)
        swell(cb, b0, b0 + 4, 78, 118)
        if bar >= 4:
            pad.at(b0).chord(PAD[ch], 4.0, 70)
        if bar % 2 == 0:
            swell(pad, b0, b0 + 8, 44, 108, steps=12)
        if bar in (16, 17, 24, 25):
            continue                                           # the marimba drips the call here
        pool = [n for n in range(74, 96) if n % 12 in (set(TRIAD[ch]) & allowed(bar, MODE))]
        used = set()
        for pos in sorted(rng.sample(range(16), rng.choice([1, 2, 2, 3]))):
            t = b0 + pos * 0.25
            n = rng.choice([x for x in pool if x not in used and x - 12 not in used])   # no drip on a ringing pitch
            used.update((n, n - 12))
            v = rng.randint(58, 86)
            mar.at(t).note(n, 0.25, v)
            if pos <= 12 and rng.random() < 0.6:
                mar.at(t + 0.75).note(n, 0.25, int(v * 0.5))    # the drip's echo
            elif pos <= 14 and rng.random() < 0.5:
                mar.at(t + 0.25).note(n - 12, 0.25, int(v * 0.7))   # plip-plop

    play(mar, tune_bars(17, 18), octave=12, vel=88, legato=0.3, rng=rng)
    play(mar, tune_bars(25, 26), vel=88, legato=0.3, rng=rng)
    for a, b in ((1, 2), (9, 10), (13, 16), (27, 31)):
        play(lead, tune_bars(a, b), octave=-12, vel=78, legato=0.97, rng=rng)
    for b0 in range(0, BEATS, 8):
        swell(lead, b0, b0 + 8, 84, 124, steps=12)
    return s
