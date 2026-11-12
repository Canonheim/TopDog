"""A6 LA CHIMENEA: anvils, snare rolls, rising brass, urgent.

Plain (the D bars are bare fourths and fifths: E A D). Four kicks to the bar, a snare that
gallops (one, and-a, two, and-a) and rolls into every second bar, anvils (agogo) ringing the
plan's root on the backbeats. Low strings chug eighths in 3+3+2, the tuba pounds the roots.
The brass section climbs through each eight-bar phrase (its voicing rises and its expression
opens) and stabs out of the last bar. A trumpet with horns under it throws the call at every
slot, shouts short rising calls between, and takes the tune out of the top of the chimney.

Channels: 1 Trumpet, 2 French Horns, 3 Brass Section, 4 Fast Strings (low chug), 5 Tuba,
6 Agogo (the anvils), 10 Power kit.
"""
from peak_common import *

INDEX, NAME, MODE, RESOLVED = 6, "La Chimenea", "plain", False
RENDER = dict(gain=0.4, fx_extra=["-o", "synth.reverb.level=0.35"])

RISE = [52, 52, 55, 55, 59, 59, 62, 62]
ANV = {"D": 74, "G": 79, "Bm": 83, "Em": 76, "A": 81}


def build():
    rng = random.Random(106)
    s = Song(tempo=TEMPO)
    tpt = part(s, "Trumpet", vol=108, pan=76, rev=70)
    horn = part(s, "French Horns", vol=98, pan=48, rev=70)
    brs = part(s, "Brass Section", vol=84, pan=64, rev=60)
    ost = part(s, "Fast Strings", vol=106, pan=40, rev=40)
    tuba = part(s, "Tuba", vol=106, pan=64, rev=40)
    anv = part(s, "Agogo", vol=116, pan=98, rev=60)
    dr = kit(s, 16, vol=90)

    for bar, ch in enumerate(PLAN):
        b0, ph, k = bar * 4.0, bar // 8, bar % 8
        for q in range(4):
            dr.hit("Kick", at=b0 + q, vel=[100, 84, 94, 84][q])
            if k == 7 and q >= 2:
                for i in range(4):
                    dr.hit("Acoustic Snare", at=b0 + q + i * .25, vel=min(120, 56 + 8 * ((q - 2) * 4 + i)))
            elif bar % 2 == 1 and q == 3:
                for i in range(4):
                    dr.hit("Acoustic Snare", at=b0 + q + i * .25, vel=64 + 11 * i)
            else:
                dr.hit("Acoustic Snare", at=b0 + q, vel=98 if q in (1, 3) else 68)
                dr.hit("Acoustic Snare", at=b0 + q + .5, vel=50 + rng.randint(-3, 3))
                dr.hit("Acoustic Snare", at=b0 + q + .75, vel=60 + rng.randint(-3, 3))
        if k == 0:
            dr.hit("Crash Cymbal 1", at=b0, vel=92)
        dr.hit("Ride Bell", at=b0 + .5, vel=48)
        dr.hit("Ride Bell", at=b0 + 2.5, vel=48)
        anv.at(b0 + 1).note(ANV[ch], .2, 98)
        anv.at(b0 + 3).note(ANV[ch], .2, 104)
        anv.at(b0 + 3.5).note(ANV[ch] - 12, .2, 74)
        if ph == 2:
            anv.at(b0 + 1.5).note(ANV[ch] - 12, .2, 70)
        r = bass(ch, 1)
        for i, (n, v) in enumerate(zip([r, r, r + 7, r, r, r + 7, r, r + 7], [98, 66, 72, 94, 66, 72, 92, 72])):
            ost.at(b0 + i * .5).note(n, .32, v + rng.randint(-3, 3))
        tuba.at(b0).note(bass(ch), .9, 100)
        tuba.at(b0 + 2).note(bass(ch), .9, 92)
        tuba.at(b0 + 3.5).note(fifth(ch), .4, 82)
        notes = voicing(ch, MODE, RISE[k] + (2 if ph == 3 else 0), 3)
        if k == 0:
            brs.ramp_cc(11, 72, 127, b0, b0 + 31, steps=16)
        if k == 7:
            brs.at(b0).chord(notes, 1.8, 98)
            for off in (2, 2.5, 3, 3.5):
                brs.at(b0 + off).chord(notes, .3, 104)
        else:
            brs.at(b0).chord(notes, 3.4, 82 + 3 * k)
        if bar in (4, 5, 6, 7, 20, 21, 22, 23):
            cv = voicing(ch, MODE, 66, 3)
            n = cv[min(2, bar % 4)]
            tpt.at(b0 + 2.5).notes([(n, .22, 92), (n, .22, 96), (n, .9, 106)])

    for a in (1, 9, 17, 25):
        play(tpt, tune_bars(a, a + 1), vel=108, rng=rng)
        play(horn, tune_bars(a, a + 1), octave=-12, vel=98, rng=rng)
    play(tpt, tune_bars(13, 16), vel=102, rng=rng)
    play(horn, tune_bars(19, 24), octave=-12, vel=98, rng=rng)
    play(tpt, tune_bars(27, 32), vel=108, rng=rng)
    play(horn, tune_bars(27, 31), octave=-12, vel=96, rng=rng)
    return s
