"""A8 EL TELEFERICO: accordion and a swaying bass, a little tipsy.

D major (ion). The tuba sways 3+3+2 (root, fifth, root) and stumbles up a leading tone into
each new phrase. A second accordion puffs chords in the gaps of the sway. The lead accordion
plays the whole tune, never quite on the beat (each note a hair late, by a seeded amount),
scoops up into its long notes from the step below, and breathes with the bellows every bar.
It is joined in thirds on the second and last phrases and drops an octave for the middle.
A clarinet hiccups at the ends of lines. Brushes and a tambourine.

Channels: 1 Accordion (lead), 2 Accordion (thirds), 3 Italian Accordion (chords), 4 Tuba,
5 Clarinet (the hiccup), 10 Brush kit.
"""
from peak_common import *

INDEX, NAME, MODE, RESOLVED = 8, "El Teleferico", "ion", False
RENDER = dict(gain=0.45)

HICS = [(3, 3.5, 86), (7, 3.25, 88), (7, 3.75, 88), (11, 3.5, 86), (15, 3.5, 90),
        (19, 3.5, 86), (23, 3.25, 88), (23, 3.75, 88), (27, 3.5, 90), (31, 3.5, 88)]
SLOT_BARS = {0, 1, 8, 9, 16, 17, 24, 25}


def build():
    rng = random.Random(108)
    s = Song(tempo=TEMPO)
    acc = part(s, "Accordion", vol=106, pan=56, rev=50)
    acc2 = part(s, "Accordion", vol=86, pan=76, rev=50)
    chd = part(s, "Italian Accordion", vol=96, pan=38, rev=40)
    tuba = part(s, "Tuba", vol=100, pan=64, rev=30)
    hic = part(s, "Clarinet", vol=72, pan=102, rev=60)
    dr = kit(s, 40, vol=112)

    for bar, ch in enumerate(PLAN):
        b0 = bar * 4.0
        r = bass(ch)
        tuba.at(b0).note(r, 1.3, 96)
        tuba.at(b0 + 1.5).note(r + 7, 1.3, 80)
        if bar % 8 == 7:
            nxt = bass(PLAN[(bar + 1) % BARS])
            app = next(n for n in (nxt - 1, nxt - 2, nxt + 2, nxt + 1) if n % 12 in allowed(bar, MODE))
            tuba.at(b0 + 3).note(r + 12, .45, 84)
            tuba.at(b0 + 3.5).note(app, .45, 88)
        else:
            tuba.at(b0 + 3).note(r + 12, .8, 84)
        v = voicing(ch, MODE, 60, 3)
        chd.at(b0 + 1).chord(v, .4, 66 + rng.randint(-4, 4))
        chd.at(b0 + 2.5).chord(v, .4, 62 + rng.randint(-4, 4))
        chd.at(b0 + 3.5).chord(v, .35, 58 + rng.randint(-4, 4))
        dr.hit("Kick", at=b0, vel=70)
        dr.hit("Acoustic Snare", at=b0 + 1, vel=64)
        dr.hit("Acoustic Snare", at=b0 + 2.5, vel=58)
        dr.hit("Tambourine", at=b0 + 3, vel=60)
        swell(acc, b0, b0 + 4, 94, 124, steps=6)
        swell(acc2, b0, b0 + 4, 94, 124, steps=6)

    lag = lambda t: rng.choice([0, 0, .03, .05, .08])
    for a, b, o, thirds in ((1, 8, 0, False), (9, 16, 0, True), (17, 24, -12, False), (25, 32, 0, True)):
        ev = tune_bars(a, b)
        play(acc, ev, octave=o, vel=94, legato=.9, rng=rng, second=acc2 if thirds else None, mode=MODE, lag=lag)
        # the scoop: a quick step up into the long notes
        for i, (t, n, d) in enumerate(ev):
            bar = int(t // 4)
            if d < 2 or i == 0 or bar in SLOT_BARS:
                continue
            g = next((x for x in (n - 2, n - 3) if x % 12 in (allowed(bar, MODE) & PENTA)), None)
            if g is not None and ev[i - 1][1] != g and int((t - .14) // 4) == bar:
                acc.at(t - .14).note(g + o, .1, 64)
    for bar, off, n in HICS:
        hic.at(bar * 4.0 + off).note(n, .12, 78)
    return s
