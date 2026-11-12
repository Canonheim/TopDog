"""A5 EL TEMPLO DEL PRIMER PERRO: deep drums, clay flute, low brass on the motif.

D mixolydian (mix): the horns hold D A C on the D bars (a hollow old seventh), the A bars
have no third, and the clay flute (ocarina) leans on C natural. A taiko keeps a slow heavy
figure with a concert bass drum under every second bar and a rattle of maracas. Trombone and
horns state the call low at every slot, the tuba holds the plan's roots.

Channels: 1 Ocarina, 2 Trombone, 3 French Horns, 4 Tuba, 5 Taiko Drum, 6 Concert Bass Drum,
10 kit (maracas, floor tom).
"""
from peak_common import *

INDEX, NAME, MODE, RESOLVED = 5, "El Templo del Primer Perro", "mix", False
RENDER = dict(gain=0.45, fx_extra=["-o", "synth.reverb.level=0.5", "-o", "synth.reverb.room-size=0.7"])

HPAD = {"D": [50, 57, 60], "G": [50, 55, 59], "Bm": [54, 59, 62], "Em": [52, 55, 59], "A": [45, 52, 55]}
PAD_BARS = set(range(2, 8)) | set(range(10, 16)) | set(range(18, 24)) | set(range(26, 32))


def build():
    rng = random.Random(105)
    s = Song(tempo=TEMPO)
    oca = part(s, "Ocarina", vol=84, pan=72, rev=100)
    bone = part(s, "Trombone", vol=104, pan=44, rev=70)
    horn = part(s, "French Horns", vol=88, pan=84, rev=80)
    tuba = part(s, "Tuba", vol=106, pan=60, rev=60)
    taiko = part(s, "Taiko Drum", vol=106, pan=64, rev=70, pitched=False)
    cbd = part(s, "Concert Bass Drum", vol=112, pan=64, rev=80, pitched=False)
    dr = kit(s, 0, vol=110)

    for bar, ch in enumerate(PLAN):
        b0, ph = bar * 4.0, bar // 8
        tuba.at(b0).note(bass(ch), 3.6, 86)
        hits = [(0, 112), (2, 96), (3, 70), (3.5, 84)] if ph == 2 else [(0, 112), (1.5, 78), (2, 100), (3.5, 84)]
        if bar % 8 == 7:
            hits = [(0, 112), (1.5, 78), (2, 90), (2.5, 74), (3, 84), (3.25, 92), (3.5, 100), (3.75, 110)]
        for off, v in hits:
            taiko.at(b0 + off).note(50 if v >= 90 else 45, 0.2, v + rng.randint(-4, 4))
        if bar % 2 == 0:
            cbd.at(b0).note(48, 1.0, 100)
        for k in range(8):
            dr.hit("Maracas", at=b0 + k * 0.5, vel=50 if k % 2 else 70)
        if bar % 2 == 1:
            dr.hit("Low Floor Tom", at=b0 + 3, vel=60)
        if bar in PAD_BARS:
            horn.at(b0).chord(HPAD[ch], 3.8, 62)
            swell(horn, b0, b0 + 4, 86, 120)

    # The call, low, at every slot.
    for a, o, both in ((1, -12, False), (9, -12, True), (17, -12, False), (25, -24, True)):
        ev = tune_bars(a, a + 1)
        play(bone, ev, octave=o, vel=100, legato=0.95, rng=rng)
        horn.cc(11, 127, at=(a - 1) * 4.0)
        if both:
            play(horn, ev, octave=o + 12, vel=96, legato=0.95, rng=rng)
    # The clay flute.
    L = tune_bars(1, 3) + [(12, 69, 1), (13, 72, 1), (14, 69, 1.5)] + tune_bars(5, 8)
    L += tune_bars(13, 16)
    L += tune_bars(19, 19) + [(76, 72, 1), (77, 69, 1), (78, 66, 1.5)] + tune_bars(21, 24)
    L += tune_bars(25, 30) + [(120, 78, 1), (121, 74, 1), (122, 72, .5), (122.5, 69, 1.5)] + tune_bars(32, 32)
    play(oca, L, vel=88, legato=0.93, rng=rng)
    return s
