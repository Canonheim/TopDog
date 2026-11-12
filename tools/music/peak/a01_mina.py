"""A1 LA MINA VIEJA: guitarron and muted pick-axe percussion, a lone harmonica.

D mixolydian (mix): the harmonica bends the tune through C natural on the D bars, and the
guitarron walks through it. A slow trudge, two picks a bar (side stick), a tink and a chip
now and then. The harmonica is alone, so its own echo answers it off the far wall (a second
harmonica, a beat and a half late and three beats late, quieter each time).

Channels: 1 Acoustic Bass (guitarron, in octaves), 2 Harmonica, 3 Harmonica (the echo),
10 kit (side stick, mute triangle, wood blocks).
"""
from peak_common import *

INDEX, NAME, MODE, RESOLVED = 1, "La Mina Vieja", "mix", False
RENDER = dict(gain=0.5, fx_extra=["-o", "synth.reverb.level=0.55", "-o", "synth.reverb.room-size=0.7",
                                  "-o", "synth.reverb.damp=0.2"])


def line():
    """The harmonica's line: the tune, with rests where a lone player breathes and blue notes."""
    L = []
    L += tune_bars(1, 3) + [(12, 69, 1.5), (13.5, 72, .5), (14, 69, 1.5)] + tune_bars(7, 8)
    L += tune_bars(11, 11) + [(44, 74, 1), (45, 72, 1), (46, 69, 1.5)] + tune_bars(13, 16)
    L += tune_bars(17, 18) + [(76, 72, .5), (76.5, 69, 1.5), (78, 66, 1.5)] + tune_bars(23, 24)
    L += [(t, n - 12, d) for t, n, d in tune_bars(25, 26)]
    L += [(104, 66, 1.5), (105.5, 64, .5), (106, 62, 1), (107, 60, .9), (108, 59, 2), (110, 62, 1), (111, 66, 1)]
    L += tune_bars(29, 32)
    return L


def build():
    rng = random.Random(101)
    s = Song(tempo=TEMPO)
    gron = part(s, "Acoustic Bass", vol=100, pan=64, rev=40)
    harm = part(s, "Harmonica", vol=110, pan=56, rev=90)
    echo = part(s, "Harmonica", vol=84, pan=92, rev=127)
    dr = kit(s, 0, vol=104)

    for bar, ch in enumerate(PLAN):
        b0 = bar * 4.0
        r = bass(ch)
        gron.at(b0).note(r, 1.6, 98)
        gron.at(b0).note(r + 12, 1.6, 70)
        gron.at(b0 + 2).note(fifth(ch), 1.2, 84)
        if bar in (1, 9):
            gron.at(b0 + 3).note(48, 0.9, 80)                 # D ... A . C | G : the mixolydian walk
        elif bar % 2 == 1:
            gron.at(b0 + 3.5).note(r + 12, 0.45, 70)
        dr.hit("Side Stick", at=b0 + 1, vel=76 + rng.randint(-4, 4))
        dr.hit("Side Stick", at=b0 + 3, vel=88 + rng.randint(-4, 4))
        if bar % 2 == 1:
            dr.hit("Mute Triangle", at=b0 + 1.5, vel=50)
        if bar % 4 == 1:
            dr.hit("Hi Wood Block", at=b0 + 2.5, vel=46)
            dr.hit("Hi Wood Block", at=b0 + 2.75, vel=38)
        if bar % 4 == 3:
            dr.hit("Low Wood Block", at=b0 + 3.5, vel=56)

    ringing = {}                                              # pitch -> beat its last echo ends
    for t, n, d in line():
        v = 86 + rng.randint(-5, 5)
        harm.at(t).note(n, d * 0.95, v)
        for late, ev in ((1.5, 44), (3.0, 28)):
            te = t + late
            if te < BEATS and n % 12 in allowed(int(te // 4), MODE):
                dd = min(d, 1.0)
                # the echo dies inside its bar, and never lands on its own ringing pitch
                if int((te + dd - 0.3) // 4) == int(te // 4) and ringing.get(n, -1) <= te:
                    echo.at(te).note(n, dd * 0.9, ev)
                    ringing[n] = te + dd * 0.9
    return s
