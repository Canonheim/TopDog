"""A9 EL GLACIAR: high strings, glass harmonica, almost no rhythm.

D lydian (lyd): a G sharp hangs in the top of the strings on four of the D bars and a celesta
touches it. Nothing keeps time. High strings hold the plan a bar or two at a time, a low
string holds its roots, and bowed glass speaks the call four times as slow as anyone else
(one note a bar, bars 1-4, 9-12 and 17-20; two beats a note in bars 25-26), then only the
tune's long notes. Rendered with the biggest room on the mountain.

Channels: 1 Slow Strings (high), 2 Slow Strings (low root), 3 Bowed Glass, 4 Celeste.
"""
from peak_common import *

INDEX, NAME, MODE, RESOLVED = 9, "El Glaciar", "lyd", False
RENDER = dict(gain=0.5, fx_extra=["-o", "synth.reverb.level=0.75", "-o", "synth.reverb.room-size=0.9",
                                  "-o", "synth.reverb.damp=0.1"])

HI = {"D": [81, 86, 88], "G": [79, 83, 86], "Bm": [78, 83, 86], "Em": [79, 83, 88], "A": [81, 85, 88]}


def build():
    rng = random.Random(109)
    s = Song(tempo=TEMPO)
    hi = part(s, "Slow Strings", vol=84, pan=64, rev=120)
    lo = part(s, "Slow Strings", vol=110, pan=52, rev=100)
    glass = part(s, "Bowed Glass", vol=100, pan=78, rev=127)
    cel = part(s, "Celeste", vol=76, pan=102, rev=127)

    bar = 0
    while bar < BARS:
        ch, n = PLAN[bar], 1
        if bar + 1 < BARS and PLAN[bar + 1] == ch:
            n = 2
        hi.at(bar * 4.0).chord(HI[ch], 4.0 * n, 46)
        lo.at(bar * 4.0).chord([bass(ch), bass(ch, 1)], 4.0 * n, 74)
        bar += n
    for bar in (3, 11, 19, 26):
        hi.at(bar * 4.0 + 1).note(92, 3.0, 38)
    for ph in range(4):
        swell(hi, ph * 32, ph * 32 + 32, 80, 120, steps=16)
        swell(lo, ph * 32, ph * 32 + 32, 80, 120, steps=16)

    # The call, one note a bar.
    for a in (0, 8, 16):
        for k, n in enumerate(MOTIF):
            glass.at((a + k) * 4.0).note(n + 12, 3.9, 72)
    glass.at(96).notes([(74, 2), (78, 2), (81, 2), (83, 2), (81, 3.5)], vel=74)
    for a, b in ((6, 8), (14, 16), (22, 24), (30, 31)):
        play(glass, tune_bars(a, b, min_dur=2), vel=60, legato=.97, jitter=2, rng=rng)

    for bar in (3, 11, 19):
        cel.at(bar * 4.0 + 2).note(92, 1.0, 46)
        cel.at(bar * 4.0 + 3).note(93, 1.0, 40)
    for bar, n in ((6, 88), (13, 88), (21, 91), (29, 88)):
        cel.at(bar * 4.0 + 1).note(n, 1.0, 40)
    return s
