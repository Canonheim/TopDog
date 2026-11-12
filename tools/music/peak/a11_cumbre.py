"""A11 LA CUMBRE: the whole mariachi on the motif, finally resolved.

D major (ion), and the only loop that plays tune(resolved=True): every call reaches the D
above (D F# A B, D), the second phrase ends on D, and the last phrase climbs the call again,
broad, across the cadence (G, A, D) and holds the D chord for a whole bar. Bar 32 is the
band's turnaround: no tune, a bass walk, a harp run and a trombone pickup back to bar 1.

Two trumpets in thirds, violins (taking the tune in the second phrase and singing the octave
above at the end), a trombone answering and doubling low, vihuela-style off-beat strums on a
nylon guitar, a steel guitar holding the chords, a guitarron bass in octaves with walk-ups,
a harp rolling and running, a glockenspiel on the last phrase, maracas, guiro and tambourine.

Channels: 1 Trumpet, 2 Trumpet 2, 3 Fast Strings (violins), 4 Trombone, 5 Nylon Guitar
(vihuela), 6 Steel Guitar, 7 Orchestral Harp, 8 Acoustic Bass, 9 Glockenspiel, 10 kit.
"""
from peak_common import *

INDEX, NAME, MODE, RESOLVED = 11, "La Cumbre", "ion", True
RENDER = dict(gain=0.35)


def R(a, b):
    return tune_bars(a, b, resolved=True)


def build():
    rng = random.Random(111)
    s = Song(tempo=TEMPO)
    tp1 = part(s, "Trumpet", vol=110, pan=52, rev=60)
    tp2 = part(s, "Trumpet 2", vol=98, pan=78, rev=60)
    vln = part(s, "Fast Strings", vol=102, pan=34, rev=70)
    bone = part(s, "Trombone", vol=94, pan=94, rev=60)
    vih = part(s, "Nylon Guitar", vol=98, pan=44, rev=40)
    gtr = part(s, "Steel Guitar", vol=92, pan=86, rev=40)
    harp = part(s, "Orchestral Harp", vol=86, pan=104, rev=60)
    bs = part(s, "Acoustic Bass", vol=100, pan=64, rev=30)
    glk = part(s, "Glockenspiel", vol=76, pan=22, rev=80)
    dr = kit(s, 0, vol=112)

    for bar, ch in enumerate(PLAN):
        b0, ph = bar * 4.0, bar // 8
        r = bass(ch)
        v4 = voicing(ch, MODE, 57, 4)
        v3 = voicing(ch, MODE, 62, 3)
        for k in range(8):
            dr.hit("Maracas", at=b0 + k * .5, vel=56 if k % 2 else 76)
        if bar % 2 == 0:
            dr.hit("Long Guiro", at=b0 + 1, vel=44)
            dr.hit("Short Guiro", at=b0 + 3, vel=40)
        if ph == 3:
            dr.hit("Tambourine", at=b0 + 1, vel=52)
            dr.hit("Tambourine", at=b0 + 3, vel=52)
        if bar == 30:
            # the held chord: everyone stays on D
            bs.at(b0).note(r, 3.8, 104)
            bs.at(b0).note(r + 12, 3.8, 88)
            for i in range(16):
                vih.at(b0 + i * .25).chord(v4 if i % 2 == 0 else v4[1:][::-1], .22, 58 + int(1.6 * i), strum=.006)
            gtr.at(b0).chord(v3, 3.8, 64, strum=.03)
            for i, n in enumerate(voicing(ch, MODE, 50, 8)):
                harp.at(b0 + i * .25).note(n, 1.5, 62 + 3 * i)
            dr.hit("Crash Cymbal 1", at=b0, vel=102)
            continue
        if bar == 31:
            # the turnaround: A, walking up to the D of bar 1
            bs.at(b0).note(45, .9, 84)
            for i, (n, v) in enumerate([(33, 100), (35, 88), (37, 92), (40, 96)]):
                bs.at(b0 + i).note(n, .9, v)
            for i, n in enumerate([57, 61, 64, 67]):
                harp.at(b0 + 2 + i * .5).note(n, min(1.0, 2 - i * .5), 66 + 5 * i)
            bone.at(b0 + 2).notes([(57, 1), (61, .9)], vel=88)
        else:
            bs.at(b0).note(r, .9, 102)
            bs.at(b0).note(r + 12, .9, 84)
            bs.at(b0 + 2).note(fifth(ch), .9, 92)
            if bar % 2 == 1:
                nxt = bass(PLAN[(bar + 1) % BARS])
                app = next(n for n in (nxt - 1, nxt - 2, nxt + 2, nxt + 1) if n % 12 in allowed(bar, MODE))
                bs.at(b0 + 3.5).note(app, .45, 80)
            if bar % 8 == 7 or bar == 15:
                for i, n in enumerate(voicing(ch, MODE, 57, 8)):
                    harp.at(b0 + 2 + i * .25).note(n, min(.6, 2 - i * .25), 60 + 4 * i)
            elif bar % 2 == 0:
                harp.at(b0).chord(voicing(ch, MODE, r + 12, 4), 2.0, 60, strum=.05)
        j = lambda: rng.randint(-4, 4)
        vih.at(b0 + 1).chord(v4, .3, 80 + j(), strum=.012)
        vih.at(b0 + 1.5).chord(v4[1:][::-1], .25, 58 + j(), strum=.008)
        vih.at(b0 + 3).chord(v4, .3, 78 + j(), strum=.012)
        vih.at(b0 + 3.5).chord(v4[1:][::-1], .25, 60 + j(), strum=.008)
        gtr.at(b0).chord(v3, 1.8, 56, strum=.02)
        gtr.at(b0 + 2).chord(v3, 1.8, 50, strum=.02)
    dr.hit("Crash Cymbal 1", at=0, vel=72)
    dr.hit("Crash Cymbal 1", at=96, vel=86)

    # Phrase 1: the trumpets in thirds, violins holding, the trombone answering the long notes.
    play(tp1, R(1, 8), vel=102, rng=rng, second=tp2, mode=MODE)
    for bar in range(2, 8):
        vln.at(bar * 4.0).chord(voicing(PLAN[bar], MODE, 69, 2), 1.9 if bar == 7 else 3.8, 60)
    vln.at(30).notes([(69, .5, 70), (73, .5, 76), (76, .5, 82), (81, .5, 88)])
    bone.at(14).notes([(57, .5), (62, .5), (66, 1)], vel=86)
    bone.at(30).notes([(57, .5), (61, .5), (64, 1)], vel=86)
    # Phrase 2: the violins sing; the trumpets double the call, punch, and bring it home.
    play(vln, R(9, 16), octave=12, vel=98, legato=.95, rng=rng)
    play(tp1, R(9, 10), vel=100, rng=rng, second=tp2, mode=MODE)
    for bar in (11, 13):
        d2 = voicing(PLAN[bar], MODE, 69, 2)
        for off in (2.5, 3):
            tp1.at(bar * 4.0 + off).note(d2[1], .3, 96)
            tp2.at(bar * 4.0 + off).note(d2[0], .3, 88)
    play(tp1, R(15, 16), vel=100, rng=rng, second=tp2, mode=MODE)
    # Phrase 3: trombone and violins, low; then the trumpets build over a long A.
    play(bone, R(17, 20), octave=-12, vel=96, rng=rng)
    play(vln, R(17, 20), vel=90, legato=.95, rng=rng)
    play(tp1, R(21, 24), vel=102, rng=rng, second=tp2, mode=MODE)
    play(bone, R(21, 24), octave=-12, vel=90, rng=rng)
    for bar in range(20, 24):
        vln.at(bar * 4.0).chord(voicing(PLAN[bar], MODE, 81, 2), 3.8, 62)
    # Phrase 4: everyone. The call reaches the D, then climbs again across the cadence.
    play(tp1, R(25, 26), octave=-12, vel=106, rng=rng, second=tp2, mode=MODE)
    play(vln, R(25, 28), vel=102, legato=.95, rng=rng)
    play(glk, R(25, 28), vel=70, legato=.5, rng=rng)
    play(tp1, R(27, 28), vel=106, rng=rng, second=tp2, mode=MODE)
    play(bone, R(27, 28), octave=-12, vel=92, rng=rng)
    play(vln, R(29, 31), vel=108, legato=.97, rng=rng)
    play(glk, R(29, 31), vel=76, legato=.5, rng=rng)
    play(tp1, R(29, 31), octave=-12, vel=110, legato=.97, rng=rng, second=tp2, mode=MODE)
    play(bone, R(29, 31), octave=-24, vel=98, legato=.97, rng=rng)
    return s
