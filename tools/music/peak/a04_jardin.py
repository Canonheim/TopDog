"""A4 EL JARDIN DE HONGOS: kalimba, pizzicato, a bouncing bassoon, playful.

D major (ion). The bassoon bounces root, octave, fifth in staccato eighths and trips up a
little run every fourth bar. The kalimba plucks the tune an octave up and taps its long notes
again (boing, boing). Pizzicato strings sit on the backbeats, then take the tune themselves
through the middle while the kalimba answers off the beat. Wood blocks tick-tock on the
off-beats, a cabasa keeps time, bongos trip over the phrase ends, and a vibraslap laughs twice.

Channels: 1 Kalimba, 2 Pizzicato Strings, 3 Bassoon, 4 Xylophone (last phrase), 10 kit.
"""
from peak_common import *

INDEX, NAME, MODE, RESOLVED = 4, "El Jardin de Hongos", "ion", False
RENDER = dict(gain=0.5)


def build():
    rng = random.Random(104)
    s = Song(tempo=TEMPO)
    kal = part(s, "Kalimba", vol=112, pan=52, rev=50)
    pizz = part(s, "Pizzicato Strings", vol=96, pan=82, rev=50)
    bsn = part(s, "Bassoon", vol=96, pan=40, rev=40)
    xyl = part(s, "Xylophone", vol=84, pan=98, rev=60)
    dr = kit(s, 0, vol=110)

    for bar, ch in enumerate(PLAN):
        b0, ph = bar * 4.0, bar // 8
        r = bass(ch, 1)
        bounce = [(0, r, .35, 94), (.5, r + 12, .25, 70), (1.5, r + 7, .3, 80),
                  (2, r, .35, 88), (2.5, r + 12, .25, 70), (3.5, r + 7, .3, 78)]
        if bar % 4 == 3:
            up = [n for n in range(r, r + 14) if n % 12 in (allowed(bar, MODE) & PENTA)][:4]
            bounce = bounce[:3] + [(2 + k * .5, n, .3, 76 + 6 * k) for k, n in enumerate(up)]
        for off, n, d, v in bounce:
            bsn.at(b0 + off).note(n, d, v + rng.randint(-4, 4))
        v3 = voicing(ch, MODE, 62, 3)
        if ph != 2:
            pizz.at(b0 + 1).chord(v3, 0.3, 76 + rng.randint(-4, 4))
            pizz.at(b0 + 3).chord(v3, 0.3, 74 + rng.randint(-4, 4))
            if ph in (1, 3):
                pizz.at(b0 + 3.5).chord(v3[1:], 0.25, 56)
        else:
            hi = voicing(ch, MODE, 74, 3)
            kal.at(b0 + 1).chord(hi[1:], 0.3, 64)
            kal.at(b0 + 3).chord(hi[1:], 0.3, 62)
            if bar % 2 == 1:
                kal.at(b0 + 3.5).note(hi[2], 0.25, 54)
        for k in range(8):
            dr.hit("Cabasa", at=b0 + k * 0.5, vel=44 if k % 2 else 62)
        dr.hit("Hi Wood Block", at=b0 + 0.5, vel=64)
        dr.hit("Low Wood Block", at=b0 + 1.5, vel=58)
        dr.hit("Hi Wood Block", at=b0 + 2.5, vel=60)
        dr.hit("Low Wood Block", at=b0 + 3.5, vel=56)
        if bar % 2 == 1:
            dr.hit("Short Guiro", at=b0 + 2, vel=44)
        if bar % 4 == 3:
            dr.hit("Hi Bongo", at=b0 + 3, vel=66)
            dr.hit("Low Bongo", at=b0 + 3.5, vel=60)
            dr.hit("Hi Bongo", at=b0 + 3.75, vel=70)
        if bar % 8 == 0:
            dr.hit("Open Triangle", at=b0, vel=58)
        if bar in (15, 31):
            dr.hit("Vibraslap", at=b0 + 2, vel=54)

    def pluck(events, octave, vel):
        for t, n, d in events:
            v = vel + rng.randint(-4, 4)
            kal.at(t).note(n + octave, min(d, 1.4) * 0.9, v)
            if d >= 2:
                kal.at(t + 1.5).note(n + octave, 0.4, v - 26)
            if d >= 3:
                kal.at(t + 2.5).note(n + octave, 0.4, v - 34)

    pluck(tune_bars(1, 16), 12, 94)
    play(pizz, tune_bars(17, 24), vel=92, legato=0.45, rng=rng)
    pluck(tune_bars(25, 32), 0, 96)
    play(xyl, tune_bars(25, 32), octave=12, vel=64, legato=0.4, rng=rng)
    return s
