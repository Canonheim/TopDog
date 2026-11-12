"""A0 LA ESTACION: the town's guitar and trumpet, half heard, walking away.

D major (ion). A nylon guitar keeps a slow bass-strum, a far trumpet starts each phrase and
wanders off (its expression falls away), and a second guitar finishes what the trumpet left.
The whole loop is rendered wet and then low-passed as a circle, so it sounds like a band
playing two streets behind you.

Channels: 1 Nylon Guitar (rhythm), 2 Nylon Guitar (tune), 3 Trumpet (far), 4 Acoustic Bass,
10 kit (maracas only, the footsteps).
"""
from peak_common import *

INDEX, NAME, MODE, RESOLVED = 0, "La Estacion", "ion", False
RENDER = dict(gain=0.5,
              fx_extra=["-o", "synth.reverb.level=0.6", "-o", "synth.reverb.room-size=0.65"],
              post=lambda d: circular_lowpass(d, 1500.0, 5000.0, 0.35))


def build():
    rng = random.Random(100)
    s = Song(tempo=TEMPO)
    gtr = part(s, "Nylon Guitar", vol=88, pan=50, rev=70)
    lead = part(s, "Nylon Guitar", vol=112, pan=76, rev=80)
    tpt = part(s, "Trumpet", vol=80, pan=86, rev=127)
    bs = part(s, "Acoustic Bass", vol=112, pan=60, rev=50)
    dr = kit(s, 0, vol=90)

    for bar, ch in enumerate(PLAN):
        b0, ph = bar * 4.0, bar // 8
        v = voicing(ch, MODE, 57, 3)
        r = bass(ch, 1)
        f = r + 7 if r + 7 <= 57 else r - 5
        if ph == 2:
            # the middle: fingerpicked eighths
            for k, n in enumerate([r, v[0], v[1], v[2], f, v[0], v[1], v[2]]):
                gtr.at(b0 + k * 0.5).note(n, 0.9 if k == 0 else 0.45, (74 if k in (0, 4) else 52) + rng.randint(-4, 4))
        else:
            gtr.at(b0).note(r, 0.9, 76 + rng.randint(-4, 4))
            gtr.at(b0 + 1).chord(v, 0.6, 56 + rng.randint(-4, 4), strum=0.02)
            gtr.at(b0 + 2).note(f, 0.9, 66 + rng.randint(-4, 4))
            gtr.at(b0 + 3).chord(v, 0.42 if bar % 2 == 1 else 0.6, 54 + rng.randint(-4, 4), strum=0.02)
            if bar % 2 == 1:
                gtr.at(b0 + 3.5).chord(v[1:], 0.3, 42, strum=0.01)
        if ph >= 1:
            bs.at(b0).note(bass(ch), 1.6, 62)
            bs.at(b0 + 2).note(fifth(ch), 1.2, 54)
        if ph in (1, 3):
            for k in range(4):
                dr.hit("Maracas", at=b0 + k, vel=90 if k % 2 else 68)

    # The trumpet starts a phrase and walks away from it.
    play(tpt, tune_bars(1, 4), vel=72, rng=rng)
    tpt.ramp_cc(11, 127, 36, 8, 15.5)
    tpt.cc(11, 112, at=31.5)
    play(tpt, tune_bars(9, 12), vel=60, rng=rng)
    tpt.ramp_cc(11, 112, 30, 40, 47.5)
    tpt.cc(11, 122, at=95.5)
    play(tpt, tune_bars(25, 28), octave=-12, vel=68, rng=rng)
    tpt.ramp_cc(11, 122, 30, 104, 111.5)
    # The guitar finishes the phrases, and carries the whole middle.
    play(lead, tune_bars(5, 8), vel=74, legato=0.95, rng=rng)
    play(lead, tune_bars(13, 16), vel=72, legato=0.95, rng=rng)
    play(lead, tune_bars(17, 24), vel=76, legato=0.95, rng=rng)
    play(lead, tune_bars(29, 32), vel=72, legato=0.95, rng=rng)
    return s
