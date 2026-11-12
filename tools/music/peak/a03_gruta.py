"""A3 LA GRUTA DE CRISTAL: celesta and glass, music-box motif, slow harp.

D lydian (lyd): G sharp glints on the D and Bm bars, in the celesta's turning figure and in
a glockenspiel sigh (G#6 to A6). A music box sings the call and the tune an octave up, the
celesta turns even eighths underneath (and stops to let the call ring alone), a harp climbs
four slow notes a bar from the plan's root, and bowed glass holds a fifth behind it all.

Channels: 1 Celeste, 2 Music Box, 3 Orchestral Harp, 4 Bowed Glass, 5 Glockenspiel.
"""
from peak_common import *

INDEX, NAME, MODE, RESOLVED = 3, "La Gruta de Cristal", "lyd", False
RENDER = dict(gain=0.5, fx_extra=["-o", "synth.reverb.level=0.6", "-o", "synth.reverb.room-size=0.75",
                                  "-o", "synth.reverb.damp=0.15"])

ARP = {"D": [62, 66, 68, 69, 76, 69, 68, 66], "G": [59, 62, 67, 62, 71, 67, 62, 67],
       "Bm": [59, 62, 66, 68, 71, 68, 66, 62], "Em": [59, 64, 67, 64, 71, 67, 64, 67],
       "A": [61, 64, 69, 64, 73, 69, 64, 69]}
GLASS = {"D": [62, 69], "G": [67, 74], "Bm": [71, 78], "Em": [64, 71], "A": [69, 76]}
CEL_BARS = set(range(2, 8)) | set(range(10, 16)) | set(range(20, 24)) | set(range(26, 32))
GLASS_BARS = set(range(4, 8)) | set(range(10, 16)) | set(range(18, 24)) | set(range(26, 32))


def build():
    rng = random.Random(103)
    s = Song(tempo=TEMPO)
    cel = part(s, "Celeste", vol=92, pan=40, rev=90)
    mb = part(s, "Music Box", vol=118, pan=84, rev=100)
    harp = part(s, "Orchestral Harp", vol=86, pan=64, rev=80)
    glass = part(s, "Bowed Glass", vol=100, pan=64, rev=110)
    spark = part(s, "Glockenspiel", vol=96, pan=100, rev=120)

    cyc = [62, 48, 54, 58, 48, 52, 56, 48]
    for bar, ch in enumerate(PLAN):
        b0 = bar * 4.0
        if bar in CEL_BARS:
            for k, n in enumerate(ARP[ch]):
                cel.at(b0 + k * 0.5).note(n, 0.45, cyc[k] + rng.randint(-3, 3))
        r = bass(ch, 1)
        up = voicing(ch, MODE, r + 12, 2)
        for k, n in enumerate([r, r + 7, up[0], up[1]]):
            harp.at(b0 + k).note(n, 3.9 - k, (78 if k == 0 else 62) + rng.randint(-4, 4))
        if bar in GLASS_BARS:
            glass.at(b0).chord(GLASS[ch], 4.0, 64)
        swell(glass, b0, b0 + 4, 80, 122)
        if bar in (3, 11, 19):
            spark.at(b0 + 2.5).note(92, 0.5, 72)
            spark.at(b0 + 3.0).note(93, 1.0, 64)
        if bar in (5, 13, 21):
            spark.at(b0 + 2.0).note(91, 1.0, 62)
        if bar == 29:
            spark.at(b0 + 2.0).note(88, 1.0, 62)

    for a, b, o in ((1, 8, 12), (9, 10, 12), (13, 16, 12), (17, 24, 12), (25, 32, 0)):
        play(mb, tune_bars(a, b), octave=o, vel=100, legato=1.0, rng=rng)
    return s
