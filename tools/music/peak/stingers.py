"""THE PEAK OF DEGAYO: the three stingers (same soundfont, same render settings).

  peak_fall_wah        about 2 s. A muted trumpet's sad "wah-waaah" after a long fall: the
                       call's top note, B, and then the B flat it sags to, drooping away.
                       A trombone an octave under it. Funny, not cruel.
  peak_summit_fanfare  about 9.5 s. The call in full mariachi: D F# A B, the D above, a
                       cadence (G, A) and a held D major chord, D on top, left to ring.
  peak_milestone       1 s. A small rising chime on the call's first three notes (D F# A).

Written to audio/sfx/peak/ as 44.1 kHz 16-bit stereo WAV.
Run: python tools/music/peak/stingers.py   (build_all.py runs it too)
"""
import os
import shutil
import tempfile

import mido
import numpy as np
import soundfile as sf
from mido import Message, MetaMessage, MidiFile, MidiTrack

from peak_common import OUT_SFX, SR, Song, below, kit, part, rms_db, voicing
from sf_kit import find, render_midi


def _finish(wav_in, name, seconds, peak, fade=0.25):
    """Trim to `seconds`, fade the end, set the peak, write 16-bit, return the facts."""
    d, sr = sf.read(wav_in)
    assert sr == SR
    n = int(round(seconds * SR))
    if len(d) < n:
        d = np.vstack([d, np.zeros((n - len(d), d.shape[1]))])
    d = d[:n].copy()
    k = int(fade * SR)
    d[-k:] *= np.linspace(1.0, 0.0, k)[:, None]
    d *= peak / np.abs(d).max()
    os.makedirs(OUT_SFX, exist_ok=True)
    out = os.path.join(OUT_SFX, name + ".wav")
    sf.write(out, d, SR, subtype="PCM_16")
    back, _ = sf.read(out)
    return {"file": "audio/sfx/peak/%s.wav" % name, "samples": int(len(back)), "seconds": round(len(back) / SR, 3),
            "rms_db": round(rms_db(back), 2), "peak": round(float(np.abs(back).max()), 3),
            "kb": round(os.path.getsize(out) / 1024.0, 1)}


def fall_wah(tmp):
    """Written straight to MIDI, because it needs pitch bend (sf_kit tracks have none)."""
    tpb = 480                       # at 120 bpm: 960 ticks a second
    sec = lambda x: int(round(x * 960))
    bend = lambda semis: max(-8192, min(8191, int(round(semis / 2.0 * 8191))))
    mid = MidiFile(ticks_per_beat=tpb)
    meta = MidiTrack()
    mid.tracks.append(meta)
    meta.append(MetaMessage("set_tempo", tempo=mido.bpm2tempo(120), time=0))
    for ch, (preset, octave, vol) in enumerate((("Muted Trumpet", 0, 118), ("Trombone", -12, 70))):
        bank, prog = find(preset)
        ev = [(0, Message("control_change", channel=ch, control=0, value=bank)),
              (0, Message("control_change", channel=ch, control=32, value=0)),
              (0, Message("program_change", channel=ch, program=prog)),
              (0, Message("control_change", channel=ch, control=7, value=vol)),
              (0, Message("control_change", channel=ch, control=91, value=50)),
              (0, Message("control_change", channel=ch, control=1, value=0))]

        def wah(t0, t1, note, droop):
            # the "w": a scoop up into the note and the hand coming off the bell
            for i in range(9):
                f = i / 8.0
                ev.append((sec(t0 + 0.11 * f), Message("pitchwheel", channel=ch, pitch=bend(-0.7 * (1 - f)))))
                ev.append((sec(t0 + 0.13 * f), Message("control_change", channel=ch, control=11, value=int(46 + 81 * f))))
            ev.append((sec(t0) + 1, Message("note_on", channel=ch, note=note + octave, velocity=104)))
            # the "ah": the hand closes again, and the last one sags and wobbles
            steps = 24
            for i in range(steps + 1):
                f = i / steps
                t = t0 + 0.16 + (t1 - t0 - 0.16) * f
                ev.append((sec(t), Message("control_change", channel=ch, control=11, value=int(127 - 80 * f ** 1.5))))
                if droop:
                    ev.append((sec(t), Message("pitchwheel", channel=ch, pitch=bend(-droop * max(0.0, (f - 0.2) / 0.8) ** 1.3))))
                    ev.append((sec(t), Message("control_change", channel=ch, control=1, value=int(100 * min(1.0, f * 1.6)))))
            ev.append((sec(t1), Message("note_off", channel=ch, note=note + octave, velocity=0)))
            ev.append((sec(t1) + 2, Message("pitchwheel", channel=ch, pitch=0)))
            ev.append((sec(t1) + 2, Message("control_change", channel=ch, control=1, value=0)))

        wah(0.02, 0.50, 71, 0.0)          # wah      (B)
        wah(0.62, 1.85, 70, 2.0)          # waaah    (B flat, sagging a whole tone)
        tr = MidiTrack()
        mid.tracks.append(tr)
        prev = 0
        for tick, msg in sorted(ev, key=lambda e: e[0]):
            tr.append(msg.copy(time=tick - prev))
            prev = tick
    p = os.path.join(tmp, "wah.mid")
    mid.save(p)
    w = os.path.join(tmp, "wah.wav")
    render_midi(p, w, gain=0.6)
    return _finish(w, "peak_fall_wah", 2.15, 0.80, fade=0.2)


def summit_fanfare(tmp):
    s = Song(tempo=98)
    tp1 = part(s, "Trumpet", vol=114, pan=52, rev=60)
    tp2 = part(s, "Trumpet 2", vol=104, pan=78, rev=60)
    bone = part(s, "Trombone", vol=102, pan=94, rev=60)
    horn = part(s, "French Horns", vol=92, pan=40, rev=70)
    vln = part(s, "Fast Strings", vol=98, pan=30, rev=70)
    vih = part(s, "Nylon Guitar", vol=100, pan=44, rev=40)
    harp = part(s, "Orchestral Harp", vol=92, pan=104, rev=60)
    bs = part(s, "Acoustic Bass", vol=116, pan=64, rev=30)
    timp = part(s, "Timpani", vol=110, pan=64, rev=60)
    glk = part(s, "Glockenspiel", vol=70, pan=22, rev=80)
    dr = kit(s, 0, vol=92)
    D4 = [57, 62, 66, 69]
    G4 = [55, 59, 62, 67]
    A4 = [57, 61, 64, 69]
    # bar 1 (D): the call, trumpets in thirds, trombone an octave under
    for i, n in enumerate([62, 66, 69, 71]):
        tp1.at(i).note(n, .92, 110)
        tp2.at(i).note(below(n, 0, "ion"), .92, 100)
        bone.at(i).note(n - 12, .92, 98)
        vih.at(i).chord(D4, .4, 84, strum=.012)
        vih.at(i + .5).chord(D4[1:][::-1], .25, 62, strum=.008)
    bs.at(0).note(38, 1.8, 104)
    bs.at(0).note(50, 1.8, 88)
    bs.at(2).note(45, 1.8, 96)
    timp.at(0).note(38, .9, 104)
    for i in range(8):
        timp.at(2 + i * .25).note(45, .22, 56 + 7 * i)
    dr.hit("Crash Cymbal 1", at=0, vel=84)
    # bar 2 (G, then A on the last beat): it reaches the D above
    tp1.at(4).note(74, 2.9, 114)
    tp2.at(4).note(71, 2.9, 102)
    bone.at(4).note(62, 2.9, 98)
    vln.at(4).notes([(74, 1), (79, 1), (83, 1)], vel=96)
    horn.at(4).chord([55, 59, 62], 2.9, 88)
    horn.at(7).chord([57, 61, 64], .9, 94)
    for i in range(3):
        vih.at(4 + i).chord(G4, .4, 84, strum=.012)
        vih.at(4.5 + i).chord(G4[1:][::-1], .25, 62, strum=.008)
    vih.at(7).chord(A4, .4, 90, strum=.012)
    vih.at(7.5).chord(A4, .3, 94, strum=.012)
    bs.at(4).note(43, 2.8, 102)
    bs.at(7).note(45, .9, 104)
    timp.at(4).note(43, .9, 100)
    tp1.at(7).notes([(76, .5), (76, .45)], vel=112)
    tp2.at(7).notes([(73, .5), (73, .45)], vel=102)
    bone.at(7).notes([(64, .5), (64, .45)], vel=100)
    vln.at(7).notes([(81, .5), (85, .45)], vel=100)
    for i in range(4):
        timp.at(7 + i * .25).note(45, .22, 76 + 10 * i)
    # bars 3-4 (D): the held chord, D on top, swelling and left to ring
    HOLD = 5.4
    tp1.at(8).note(78, HOLD, 118)
    tp2.at(8).note(74, HOLD, 108)
    bone.at(8).note(69, HOLD, 102)
    horn.at(8).chord([57, 62, 66], HOLD, 96)
    vln.at(8).chord([81, 86], HOLD, 104)
    glk.at(8).notes([(86, .5), (90, .5), (93, .5), (98, 2)], vel=84)
    bs.at(8).note(38, HOLD, 108)
    bs.at(8).note(50, HOLD, 92)
    for i, n in enumerate(voicing("D", "ion", 50, 12)):
        harp.at(8 + i * .125).note(n, 2.0, 66 + 3 * i)
    for i in range(int(HOLD * 4)):
        vih.at(8 + i * .25).chord(D4 if i % 2 == 0 else D4[1:][::-1], .22, 66 + i, strum=.006)
        timp.at(8 + i * .25).note(38, .22, min(112, (112 if i == 0 else 62 + 2 * i)))
    dr.hit("Crash Cymbal 1", at=8, vel=110)
    for tr in (tp1, tp2, bone, horn, vln):
        tr.ramp_cc(11, 104, 127, 8.2, 8 + HOLD - 0.4, steps=10)
    w = os.path.join(tmp, "fanfare.wav")
    s.render(w, gain=0.35)
    return _finish(w, "peak_summit_fanfare", 9.6, 0.89, fade=0.5)


def milestone(tmp):
    s = Song(tempo=120)
    glk = part(s, "Glockenspiel", vol=110, pan=70, rev=70)
    cel = part(s, "Celeste", vol=100, pan=50, rev=70)
    for i, n in enumerate([86, 90, 93]):               # D6 F#6 A6, 0.09 s apart
        glk.at(i * .18).note(n, 1.2, 84 + 8 * i)
        cel.at(i * .18).note(n - 12, 1.2, 72 + 6 * i)
    w = os.path.join(tmp, "milestone.wav")
    s.render(w, gain=0.6)
    return _finish(w, "peak_milestone", 1.0, 0.60, fade=0.3)


def build():
    tmp = tempfile.mkdtemp(prefix="peak_sting_")
    try:
        return [fall_wah(tmp), summit_fanfare(tmp), milestone(tmp)]
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    for m in build():
        print(m)
