"""A10 LA CRESTA DE LA TORMENTA: timpani, tremolo strings, trumpet calls torn by wind.

Plain, and as tense as the plan allows: the D bars are bare (A D E), the A bars are full
sevenths, the Em bars carry their ninth, and a high tremolo A hangs over every bar of the
loop without ever letting go. Timpani strike the roots and roll into every second bar (a
whole bar of roll at each phrase end). Low strings chug 3+3+2 from the second phrase on.
The trumpet throws the call at every slot and the wind takes it: the first is cut off as
the B sounds, the second loses its B altogether (a far muted trumpet finds it a bar later),
the third and fourth get there and are shaken (expression flutter). Between slots it shouts
two-note calls that are torn the same way. A concert bass drum is the thunder.

Channels: 1 Timpani, 2 Tremolo Strings (chords), 3 Tremolo Strings (the high A),
4 Fast Strings (low chug), 5 French Horns, 6 Trumpet, 7 Muted Trumpet (far),
8 Concert Bass Drum, 10 kit (crashes).
"""
from peak_common import *

INDEX, NAME, MODE, RESOLVED = 10, "La Cresta de la Tormenta", "plain", False
RENDER = dict(gain=0.4, fx_extra=["-o", "synth.reverb.level=0.5", "-o", "synth.reverb.room-size=0.7"])

TIMP = {"D": 38, "G": 43, "Bm": 47, "Em": 40, "A": 45}


def tear(tr, t0, t1):
    """The wind takes the note: expression falls away over [t0, t1], and is given back after."""
    tr.ramp_cc(11, 127, 22, t0, t1, steps=8)
    tr.cc(11, 127, at=t1 + 0.3)


def flutter(tr, t0, beats):
    """The wind shakes the note: expression rolls up and down twice a beat."""
    import math
    for i in range(int(beats * 16)):
        tr.cc(11, int(round(90 + 34 * math.cos(2 * math.pi * i / 8.0))), at=t0 + i / 16.0)
    tr.cc(11, 127, at=t0 + beats)


def build():
    rng = random.Random(110)
    s = Song(tempo=TEMPO)
    timp = part(s, "Timpani", vol=112, pan=60, rev=70)
    trem = part(s, "Tremolo Strings", vol=98, pan=50, rev=70)
    ped = part(s, "Tremolo Strings", vol=96, pan=86, rev=90)
    celli = part(s, "Fast Strings", vol=92, pan=40, rev=50)
    horn = part(s, "French Horns", vol=70, pan=72, rev=80)
    tpt = part(s, "Trumpet", vol=110, pan=64, rev=90)
    far = part(s, "Muted Trumpet", vol=100, pan=106, rev=127)
    thunder = part(s, "Concert Bass Drum", vol=112, pan=64, rev=90, pitched=False)
    dr = kit(s, 0, vol=84)

    for bar, ch in enumerate(PLAN):
        b0, ph, k = bar * 4.0, bar // 8, bar % 8
        tn = TIMP[ch]
        if k == 7:
            for i in range(16):
                timp.at(b0 + i * .25).note(tn, .22, min(118, 46 + int(4.4 * i) + (40 if i == 0 else 0)))
        else:
            timp.at(b0).note(tn, .9, 104)
            if bar % 2 == 1:
                for i in range(8):
                    timp.at(b0 + 2 + i * .25).note(tn, .22, 52 + 6 * i)
            elif ph >= 2:
                timp.at(b0 + 1.5).note(tn, .4, 72)
                timp.at(b0 + 2).note(tn, .4, 86)
        # A7 whole; Em with its ninth a seventh above the third (B E G, F#), not crushed against it
        tv = [59, 64, 67, 78] if ch == "Em" else voicing(ch, MODE, 57, 4 if ch == "A" else 3, colour=ch == "A")
        trem.at(b0).chord(tv, 3.95, 82)
        if bar % 2 == 0:
            swell(trem, b0, b0 + 8, 66, 124, steps=12)
        if bar % 4 == 0:
            ped.at(b0).note(81, 15.9, 62)
            swell(ped, b0, b0 + 16, 70, 120, steps=16)
        r = bass(ch, 1)
        if ph == 0:
            celli.at(b0).note(r, 3.9, 64)
        else:
            for i, (n, v) in enumerate(zip([r, r, r + 7, r, r, r + 7, r, r + 7], [92, 60, 70, 88, 60, 70, 86, 72])):
                celli.at(b0 + i * .5).note(n, .3, v + rng.randint(-3, 3))
        if ph >= 2:
            horn.at(b0).chord([r + 12, r + 19], 3.9, 70 if ph == 2 else 84)

    for t, v in ((10.5, 104), (27, 112), (45.5, 100), (62, 116), (75, 106), (90.5, 112), (109, 118), (123, 108)):
        thunder.at(t).note(48, 1.5, v)
    dr.hit("Crash Cymbal 2", at=32, vel=76)
    dr.hit("Crash Cymbal 1", at=64, vel=84)
    dr.hit("Crash Cymbal 1", at=96, vel=100)

    # slot 1 (bars 1-2): cut off as the B sounds; a far echo gets three notes of it
    tpt.at(0).notes([(62, 1), (66, 1), (69, 1), (71, 1.2)], vel=104)
    tear(tpt, 3.1, 4.2)
    far.at(6).notes([(62, .5), (66, .5), (69, 1)], vel=64)
    # slot 2 (bars 9-10): the B is taken; the far trumpet finds it late
    tpt.at(32).notes([(62, 1), (66, 1), (69, 1.6)], vel=104)
    tear(tpt, 34.4, 35.6)
    far.at(37).notes([(71, 2), (69, 1)], vel=66)
    # bars 13-14: two calls
    for t0, a, b in ((48, 66, 71), (52, 71, 76)):
        tpt.at(t0).notes([(a, .5), (b, 2.4)], vel=100)
        tear(tpt, t0 + 1.4, t0 + 2.9)
    # slot 3 (bars 17-18): it gets there, shaken, and falls back
    tpt.at(64).notes([(62, 1), (66, 1), (69, 1), (71, 3)], vel=106)
    flutter(tpt, 68, 2)
    tpt.at(70).note(66, 1.6, 96)
    far.at(73).notes([(62, .5), (66, .5), (69, .5), (71, 1.4)], vel=60)
    # bars 21-24: four calls, each higher
    for t0, a, b in ((80, 64, 71), (84, 71, 74), (88, 69, 76), (92, 76, 81)):
        tpt.at(t0).notes([(a, .5), (b, 2.4)], vel=102)
        tear(tpt, t0 + 1.6, t0 + 2.9)
    # slot 4 (bars 25-26): the octave above
    tpt.at(96).notes([(74, 1), (78, 1), (81, 1), (83, 3)], vel=112)
    flutter(tpt, 100, 2)
    tpt.at(102).notes([(81, 1), (76, .9)], vel=100)
    far.at(104.5).notes([(74, .5), (78, .5), (81, 1.5)], vel=62)
    # bars 29-31: the tune's last line, and the wind has the end of it
    play(tpt, tune_bars(29, 31), vel=102, rng=rng)
    tear(tpt, 122.2, 123.9)
    return s
