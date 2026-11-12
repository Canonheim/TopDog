"""A7 LOS RISCOS DEL VIENTO: whistled motif, western guitar, castanets, wide open.

D mixolydian (mix): the steel guitar turns the second D bar into D7, the bass walks through
C natural, the whistle leans on it. The guitar plays boom, chk-a-chk; castanets answer on two
and four and roll out of each phrase. A whistle carries the tune an octave up with a lot of
air round it, a second guitar twangs the call alone (bars 9-10) and takes the dark middle an
octave down, and a high fifth of strings (A and E) opens the sky over the second half.

Channels: 1 Whistle, 2 Steel Guitar (rhythm), 3 Steel Guitar (lead), 4 Acoustic Bass,
5 Castanets, 6 Slow Strings (the sky).
"""
from peak_common import *

INDEX, NAME, MODE, RESOLVED = 7, "Los Riscos del Viento", "mix", False
RENDER = dict(gain=0.5, fx_extra=["-o", "synth.reverb.level=0.6", "-o", "synth.reverb.room-size=0.8",
                                  "-o", "synth.reverb.width=1.0"])


def build():
    rng = random.Random(107)
    s = Song(tempo=TEMPO)
    whi = part(s, "Whistle", vol=64, pan=60, rev=110)
    gtr = part(s, "Steel Guitar", vol=108, pan=44, rev=60)
    lead = part(s, "Steel Guitar", vol=106, pan=84, rev=80)
    bs = part(s, "Acoustic Bass", vol=106, pan=64, rev=40)
    cas = part(s, "Castanets", vol=127, pan=96, rev=60, pitched=False)
    air = part(s, "Slow Strings", vol=76, pan=64, rev=120)

    for bar, ch in enumerate(PLAN):
        b0, ph = bar * 4.0, bar // 8
        v = voicing(ch, MODE, 57, 3)
        v7 = voicing(ch, MODE, 57, 4, colour=True) if bar in (1, 9) else v
        r = bass(ch, 1)
        f = r + 7 if r + 7 <= 57 else r - 5
        soft = -10 if ph == 2 else 0
        j = lambda: rng.randint(-4, 4)
        gtr.at(b0).note(r, .9, 84 + soft + j())
        gtr.at(b0 + .5).chord(v[1:], .2, 50 + soft)
        gtr.at(b0 + .75).chord(v[1:], .2, 46 + soft)
        gtr.at(b0 + 1).chord(v, .5, 70 + soft + j(), strum=.015)
        gtr.at(b0 + 2).note(f, .45, 76 + soft + j())
        gtr.at(b0 + 2.5).chord(v7[1:], .2, 50 + soft)
        gtr.at(b0 + 2.75).chord(v7[1:], .2, 46 + soft)
        gtr.at(b0 + 3).chord(v7, .5, 70 + soft + j(), strum=.015)
        bs.at(b0).note(bass(ch), 1.5, 92)
        bs.at(b0 + 2).note(fifth(ch), 0.95 if bar in (1, 9) else 1.2, 80)
        if bar in (1, 9):
            bs.at(b0 + 3).note(48, .9, 78)
        if bar >= 2:
            cas.at(b0 + 1).note(60, .1, 84)
            cas.at(b0 + 1.5).note(60, .1, 56)
            cas.at(b0 + 1.75).note(60, .1, 64)
            if bar % 8 == 7:
                for i in range(8):
                    cas.at(b0 + 2 + i * .25).note(60, .1, 50 + 6 * i)
            else:
                cas.at(b0 + 3).note(60, .1, 88)
                cas.at(b0 + 3.5).note(60, .1, 56)
                cas.at(b0 + 3.75).note(60, .1, 66)
        if bar >= 16 and bar % 2 == 0:
            air.at(b0).chord([81, 88], 8.0, 46)
    swell(air, 64, 128, 70, 118, steps=24)

    L1 = tune_bars(1, 3) + [(12, 69, 2), (14, 72, .5), (14.5, 69, 1.2)] + tune_bars(5, 8)
    L4 = tune_bars(25, 30) + [(120, 78, 1), (121, 74, 1), (122, 72, .5), (122.5, 69, 1.5)] + tune_bars(32, 32)
    play(whi, L1, octave=12, vel=80, legato=.96, rng=rng)
    play(whi, tune_bars(11, 16), octave=12, vel=80, legato=.96, rng=rng)
    play(whi, L4, vel=84, legato=.96, rng=rng)
    play(lead, tune_bars(9, 10), vel=100, legato=.95, rng=rng)
    play(lead, tune_bars(17, 24), octave=-12, vel=100, legato=.95, rng=rng)
    return s
