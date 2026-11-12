"""THE PEAK OF DEGAYO: the shared score.

Twelve loops that are ONE piece (docs/peak/PEAK_DESIGN.md, section 8). This module holds
everything the twelve share, so they can play in step and only their volumes move:

  * the tempo and length:  98 bpm (44100*60/98 = 27000 samples a beat, sample-exact),
    32 bars of 4/4 = 128 beats = 3,456,000 samples = 78.3673 s. Every loop, exactly.
  * PLAN:   one 32-bar chord plan. Every area plays these roots, bar for bar.
  * modes:  each area colours the plan in one of four ways (ion, mix, lyd, plain), and
    allowed() is the law that keeps any two neighbours from clashing.
  * TUNE:   one 32-bar tune in D major pentatonic that every area voices or thins out.
  * MOTIF:  the DeGayo call, D F# A B. It hangs on the B and falls back, in every area
    but the summit, where it reaches the D above (tune(resolved=True)).
  * render_area(): renders a seamless loop (render_loop_exact: sf_kit's method, with the
    wrap always blended), sets its loudness to the shipped match music
    (audio/music/desert_snake.wav), encodes OGG, decodes it back and measures it.
  * analyse(): reads the notes back and checks them against the law.

Full write-up and the measured numbers: docs/peak/MUSIC.md.
"""
import os
import random
import shutil
import subprocess
import sys
import tempfile

import numpy as np
import soundfile as sf

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.normpath(os.path.join(HERE, "..")))
from sf_kit import Song, DRUMS, FLUID, SF2, _FX  # noqa: E402

REPO = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
OUT_MUSIC = os.path.join(REPO, "audio", "music", "peak")
OUT_SFX = os.path.join(REPO, "audio", "sfx", "peak")
REFERENCE = os.path.join(REPO, "audio", "music", "desert_snake.wav")

SR = 44100
TEMPO = 98
assert SR * 60 % TEMPO == 0
SPB = SR * 60 // TEMPO            # 27000 samples a beat
BARS = 32
BEATS = BARS * 4                  # 128
LOOP_SAMPLES = BEATS * SPB        # 3,456,000
FALLBACK_RMS_DB = -23.79          # desert_snake.wav, measured 2026-11-12
OGG_QUALITY = "5"

# ---------------------------------------------------------------- the chord plan
PLAN = [
    "D", "D", "G", "D", "Bm", "G", "Em", "A",      # 1-8    the call, and an answer that ends open
    "D", "D", "G", "D", "Bm", "Em", "A", "D",      # 9-16   the call again, a higher answer, home
    "Bm", "Bm", "G", "D", "Em", "G", "A", "A",     # 17-24  the dark middle, a long climb on A
    "D", "G", "D", "Bm", "G", "A", "D", "A",       # 25-32  the reach, the cadence, the turnaround
]
assert len(PLAN) == BARS
ROOT_PC = {"D": 2, "G": 7, "Bm": 11, "Em": 4, "A": 9}
BASS = {"D": 38, "G": 43, "Bm": 35, "Em": 40, "A": 33}        # the shared bass line (octave 2)
TRIAD = {"D": [2, 6, 9], "G": [7, 11, 2], "Bm": [11, 2, 6], "Em": [4, 7, 11], "A": [9, 1, 4]}
PENTA = {2, 4, 6, 9, 11}                                      # D E F# A B: the tune's notes

# The four colours of the plan. Every one keeps the same roots.
#   ion    D major                                   a0 a4 a8 a11
#   mix    D mixolydian: C natural, on D bars only   a1 a5 a7      (A bars have no third)
#   lyd    D lydian: G sharp, on D and Bm bars only  a3 a9
#   plain  no colour note, D bars have no third      a2 a6 a10     (D E A: hollow)
MODES = ("ion", "mix", "lyd", "plain")


def chord_pcs(ch, mode, colour=False):
    """The chord's pitch classes in this colour, root first."""
    t = list(TRIAD[ch])
    if mode == "mix" and ch == "A":
        t = [9, 4, 7, 11] if colour else [9, 4]           # A with no third (the 7th and 9th colour it)
    elif mode == "plain" and ch == "D":
        t = [2, 9, 4]                                      # D E A, no third
    if colour:
        extra = {
            "ion": {"D": [11], "G": [4], "Bm": [9], "Em": [2], "A": [7]},
            "mix": {"D": [0], "G": [9], "Bm": [9], "Em": [2], "A": []},
            "lyd": {"D": [4, 8], "G": [9], "Bm": [8], "Em": [2], "A": []},
            "plain": {"D": [], "G": [9], "Bm": [9], "Em": [6], "A": [7]},
        }[mode][ch]
        t += [p for p in extra if p not in t]
    return t


def allowed(bar, mode):
    """THE LAW. The pitch classes an area in this colour may sound in this bar (0-based).

    The tune's five notes everywhere, except D over an A bar (it rubs the C sharp).
    G natural only where G is a chord tone or A's seventh. C sharp only on A bars and never
    in a mix area. C natural only on D bars, only in mix. G sharp only on D and Bm bars, only
    in lyd. So C and C sharp, or G and G sharp, can never sound in the same bar in two
    neighbouring areas (a mix area is never next to a lyd area)."""
    ch = PLAN[bar % BARS]
    s = set(PENTA)
    if ch in ("G", "Em"):
        s.add(7)
    if ch == "A":
        s.discard(2)
        s.add(7)
        if mode != "mix":
            s.add(1)
    if ch == "D" and mode == "mix":
        s.add(0)
    if ch in ("D", "Bm") and mode == "lyd":
        s.add(8)
    return s


def voicing(ch, mode, lo, n=3, colour=False):
    """n chord notes going up from lo."""
    pcs = set(chord_pcs(ch, mode, colour))
    out, note = [], lo
    while len(out) < n:
        if note % 12 in pcs:
            out.append(note)
        note += 1
    return out


def below(note, bar, mode):
    """A second voice under a tune note: the nearest chord tone a third to a fifth below."""
    ch = PLAN[bar % BARS]
    tri = set(chord_pcs(ch, mode))
    ok = allowed(bar, mode)
    for want in (tri, ok):
        for drop in (3, 4, 5):
            if (note - drop) % 12 in want:
                return note - drop
    return note - 12


def bass(ch, octave=0):
    return BASS[ch] + 12 * octave


def fifth(ch, octave=0):
    return BASS[ch] + 7 + 12 * octave


# ---------------------------------------------------------------- the tune and the motif
MOTIF = [62, 66, 69, 71]          # D F# A B

# (midi, beats), 0 = rest. Four phrases of 32 beats. D major pentatonic only.
_P1 = [(62, 1), (66, 1), (69, 1), (71, 3), (69, 2),
       (71, 1.5), (69, .5), (71, 1), (74, 1),
       (69, 3), (0, 1),
       (66, 1), (71, 1), (74, 1.5), (71, .5),
       (74, 2), (71, 2),
       (71, 1), (76, 1), (74, 1), (71, 1),
       (69, 3), (0, 1)]
_P2 = [(62, 1), (66, 1), (69, 1), (71, 3), (69, 1), (66, 1),
       (71, 1.5), (69, .5), (71, 1), (74, 1),
       (78, 2), (74, 1.5), (69, .5),
       (71, 1), (74, 1), (78, 1.5), (74, .5),
       (76, 2), (71, 1), (76, 1),
       (76, 1), (71, 1), (69, 1.5), (66, .5),
       (66, 3), (0, 1)]
_P3 = [(62, 1), (66, 1), (69, 1), (71, 3), (66, 2),
       (74, 1.5), (71, .5), (74, 1), (76, 1),
       (69, 2), (66, 2),
       (64, 1), (71, 1), (76, 1.5), (74, .5),
       (71, 2), (74, 2),
       (76, 1), (78, 1), (76, 1), (71, 1),
       (76, 3), (0, 1)]
_P4 = [(74, 1), (78, 1), (81, 1), (83, 3), (81, 1), (76, 1),
       (78, 1.5), (76, .5), (74, 1), (69, 1),
       (71, 2), (74, 1), (78, 1),
       (74, 1.5), (76, .5), (74, 1), (71, 1),
       (69, 1), (71, 1), (76, 2),
       (78, 1), (74, 1), (69, 2),
       (64, 3), (0, 1)]
# The summit's endings: the reach lands on the D above, and the cadences come home.
_P1_RES = [(62, 1), (66, 1), (69, 1), (71, 1), (74, 3), (0, 1)] + _P1[5:]
_P2_RES = [(62, 1), (66, 1), (69, 1), (71, 1), (74, 3), (0, 1)] + _P2[6:-2] + [(62, 3), (0, 1)]
_P3_RES = [(62, 1), (66, 1), (69, 1), (71, 1), (74, 3), (0, 1)] + _P3[5:]
_P4_RES = [(74, 1), (78, 1), (81, 1), (83, 1), (86, 2), (81, 1), (76, 1)] + _P4[6:13] + [
    (71, 2), (74, 1), (78, 1),          # 29  G: the reach starts again, broad
    (81, 2), (83, 2),                   # 30  A
    (86, 4),                            # 31  D: home, on top
    (0, 4)]                             # 32  A: the turnaround belongs to the band
for _nm, _p in (("P1", _P1), ("P2", _P2), ("P3", _P3), ("P4", _P4),
                ("P1r", _P1_RES), ("P2r", _P2_RES), ("P3r", _P3_RES), ("P4r", _P4_RES)):
    assert abs(sum(d for _, d in _p) - 32) < 1e-9, (_nm, sum(d for _, d in _p))


def tune(resolved=False):
    """The tune as [(beat, midi, beats)], beat 0 = bar 1."""
    out, t = [], 0.0
    for ph in ((_P1_RES, _P2_RES, _P3_RES, _P4_RES) if resolved else (_P1, _P2, _P3, _P4)):
        for n, d in ph:
            if n:
                out.append((t, n, d))
            t += d
    return out


def tune_bars(first, last, resolved=False, min_dur=0.0):
    """The tune's notes that START in bars first..last (1-based, inclusive)."""
    a, b = (first - 1) * 4.0, last * 4.0
    return [(t, n, d) for (t, n, d) in tune(resolved) if a <= t < b and d >= min_dur]


def play(track, events, octave=0, vel=90, legato=0.92, jitter=4, rng=None, second=None,
         mode="ion", second_vel=-12, lag=None):
    """Put tune events on a track. second = a track that sings under it (below())."""
    rng = rng or random
    for t, n, d in events:
        late = lag(t) if lag else 0.0
        v = vel + rng.randint(-jitter, jitter)
        track.at(t + late).note(n + octave, d * legato - late, v)
        if second is not None:
            second.at(t + late).note(below(n, int(t // 4), mode) + octave, d * legato - late, v + second_vel)


# ---------------------------------------------------------------- building tracks
def part(song, preset, vol=100, pan=64, rev=None, cho=None, pitched=True):
    """A track with its volume, pan and sends set at beat 0 (so every loop pass resets them)."""
    t = song.track(preset)
    t.pitched = pitched
    t.cc(7, vol, at=0).cc(10, pan, at=0).cc(11, 127, at=0)
    if rev is not None:
        t.cc(91, rev, at=0)
    if cho is not None:
        t.cc(93, cho, at=0)
    return t


def kit(song, number=0, vol=100):
    t = song.drums(kit=number)
    t.pitched = False
    t.cc(7, vol, at=0)
    return t


def swell(track, t0, t1, lo, hi, steps=8):
    """Expression up to the middle of [t0, t1] and back down. Ends where it began."""
    mid = (t0 + t1) / 2.0
    track.ramp_cc(11, lo, hi, t0, mid, steps)
    track.ramp_cc(11, hi, lo, mid, t1 - 0.02, steps)


# ---------------------------------------------------------------- reading the notes back
def notes_of(track):
    """[(start_beat, end_beat, midi)] from a track's events."""
    open_, out = {}, []
    for tick, kind, a, _b in sorted(track.events, key=lambda e: (e[0], e[1] == "on")):
        if kind == "on":
            open_.setdefault(a, []).append(tick)
        elif kind == "off":
            assert open_.get(a), f"[{track.name}] note-off with no note-on: {a} at tick {tick}"
            out.append((open_[a].pop(0) / 480.0, tick / 480.0, a))
    assert not any(open_.values()), f"[{track.name}] a note-on has no note-off"
    return sorted(out)


def has_motif(song, resolved):
    """True if some pitched track plays D F# A B as four notes in a row, rising. With
    resolved=True the next note must be the D above; with False it must not be."""
    found = False
    for tr in song.tracks:
        if not getattr(tr, "pitched", True):
            continue
        ns = notes_of(tr)
        for i in range(len(ns) - 3):
            four = [ns[i + k][2] for k in range(4)]
            if [n % 12 for n in four] == [2, 6, 9, 11] and four == sorted(four) and four[3] - four[0] == 9:
                nxt = ns[i + 4][2] if i + 4 < len(ns) else None
                lands = nxt is not None and nxt - four[3] == 3 and ns[i + 4][0] - ns[i + 3][0] <= 4.0
                if lands == resolved:
                    found = True
                elif lands and not resolved:
                    return False
    return found


def analyse(song, mode, resolved=False):
    """Check one loop's notes against the law. Returns a dict of facts; raises on a breach."""
    worst, count, low_roots = [], 0, 0
    for tr in song.tracks:
        ns = notes_of(tr)                      # asserts on/off balance for every track
        ends = {}
        for a, b, n in ns:                     # one note per pitch per channel at a time
            assert ends.get(n, -1) <= a + 1e-6, \
                f"[{tr.name}] {n} starts at beat {a:.2f} while the same pitch still sounds (until {ends[n]:.2f})"
            ends[n] = b
        if not getattr(tr, "pitched", True):
            continue
        for a, b, n in ns:
            count += 1
            assert 0 <= a < BEATS + 1e-6, f"[{tr.name}] a note starts outside the loop at beat {a}"
            assert b <= BEATS + 2.0, f"[{tr.name}] a note runs {b - BEATS:.2f} beats past the loop end"
            bar = int(a // 4) % BARS
            if n % 12 not in allowed(bar, mode):
                worst.append((tr.name, bar + 1, round(a - bar * 4, 2), n))
            # a note held over a barline must still be lawful in the bar it rings into
            bar2 = int((b - 0.26) // 4) % BARS
            if bar2 != bar and b - (bar + 1) * 4 > 0.26 and n % 12 not in allowed(bar2, mode):
                worst.append((tr.name, bar + 1, "held into %d" % (bar2 + 1), n))
    assert not worst, f"notes outside the law ({mode}): {worst[:12]}"
    # the shared bass: in every bar, the lowest note sounding on beat 1 (under middle C) is the root
    grid = sounding(song, steps=4)
    for bar in range(BARS):
        low = [n for n in grid[bar * 16] if n < 60]
        if low:
            assert min(low) % 12 == ROOT_PC[PLAN[bar]], f"bar {bar + 1}: lowest note {min(low)} is not the root"
            low_roots += 1
    assert has_motif(song, resolved), "the motif is missing (or resolves where it must not)"
    onsets = sum(1 for tr in song.tracks for e in tr.events if e[1] == "on")
    return {"notes": count, "onsets": onsets, "bars_with_bass_root": low_roots}


def sounding(song, steps=12):
    """For every 1/steps of a beat: the set of midi notes sounding on pitched tracks."""
    grid = [set() for _ in range(BEATS * steps)]
    for tr in song.tracks:
        if not getattr(tr, "pitched", True):
            continue
        for a, b, n in notes_of(tr):
            i0 = int(round(a * steps))
            i1 = max(i0 + 1, int(round(b * steps)))
            for i in range(i0, i1):
                grid[i % len(grid)].add(n)
    return grid


CHROMATIC = {frozenset((0, 1)), frozenset((7, 8))}       # C with C#, G with G#: never lawful together


def cross_clash(song_a, song_b, steps=12):
    """Two loops played together, read from their notes. In beats (of 128):
      chromatic  a C against a C sharp, or a G against a G sharp, across the two (must be 0)
      new        a semitone (by pitch class) between a note of A and a note of B that
                 neither loop sounds on its own at that moment
      together   any semitone at all sounding in the two together (their own colours included)
    Returns (chromatic, new, together, worst_bar)."""
    ga, gb = sounding(song_a, steps), sounding(song_b, steps)
    chrom = new = both = 0
    per_bar = [0] * BARS
    for i in range(len(ga)):
        pa, pb = {n % 12 for n in ga[i]}, {n % 12 for n in gb[i]}
        hit_c = hit_n = False
        for p in pa:
            for q in ((p + 1) % 12, (p - 1) % 12):
                if q in pb:
                    if frozenset((p, q)) in CHROMATIC:
                        hit_c = True
                    elif q not in pa and p not in pb:
                        hit_n = True
        un = pa | pb
        hit_u = any((p + 1) % 12 in un for p in un)
        chrom += hit_c
        new += hit_n
        both += hit_u
        per_bar[i // (steps * 4)] += hit_u
    worst = max(range(BARS), key=lambda k: per_bar[k]) + 1
    return chrom / steps, new / steps, both / steps, worst


def self_clash(song, steps=12):
    """Beats in which one loop sounds two pitch classes a semitone apart (its own colour)."""
    g = sounding(song, steps)
    n = 0
    for s in g:
        pcs = {x % 12 for x in s}
        n += any((p + 1) % 12 in pcs for p in pcs)
    return n / steps


# ---------------------------------------------------------------- rendering and measuring
def ffmpeg():
    ff = shutil.which("ffmpeg")
    assert ff, "ffmpeg is not on PATH"
    return ff


def target_rms_db():
    if os.path.exists(REFERENCE):
        d, _ = sf.read(REFERENCE)
        return float(20 * np.log10(np.sqrt((d ** 2).mean())))
    return FALLBACK_RMS_DB


def rms_db(d):
    return float(20 * np.log10(max(1e-12, np.sqrt((d ** 2).mean()))))


def circular_lowpass(d, f0, f1, floor):
    """A soft low-pass done on the whole loop at once, as a circle, so the seam survives:
    full level under f0, falling to `floor` at f1 and above."""
    n = len(d)
    f = np.fft.rfftfreq(n, 1.0 / SR)
    x = np.clip((f - f0) / (f1 - f0), 0.0, 1.0)
    g = 1.0 - (1.0 - floor) * (0.5 - 0.5 * np.cos(np.pi * x))
    out = np.empty_like(d)
    for c in range(d.shape[1]):
        out[:, c] = np.fft.irfft(np.fft.rfft(d[:, c]) * g, n)
    return out


def seam_of(d):
    """(seam, delta, local, click): the jump at the wrap; a typical sample step over the whole
    file (sf_kit's yardstick: OK is seam < 4 x delta); a typical step in the 256 samples each
    side of the wrap (the stricter yardstick); and the wrap's second difference against the
    loudest 0.1% of second differences in the file (a click would stand far above 1)."""
    seam = float(np.abs(d[0] - d[-1]).max())
    delta = float(np.abs(np.diff(d[:, 0])).mean())
    local = float(max(np.abs(np.diff(d[-256:], axis=0)).mean(), np.abs(np.diff(d[:256], axis=0)).mean(), 2.0 / 32768))
    m = d.mean(axis=1)
    wrap = np.concatenate([m[-4:], m[:4]])
    click = float(np.abs(np.diff(wrap, 2)).max())
    ref = float(np.quantile(np.abs(np.diff(m, 2)), 0.999)) if len(m) > 100 else 1.0
    return seam, delta, local, click / max(ref, 1e-9)


def lufs(path):
    """Integrated loudness (ITU-R BS.1770, by ffmpeg's ebur128 filter), in LUFS."""
    import re
    r = subprocess.run([ffmpeg(), "-hide_banner", "-nostats", "-i", path, "-af", "ebur128", "-f", "null", "-"],
                       capture_output=True, text=True)
    hits = re.findall(r"I:\s+(-?[\d.]+) LUFS", r.stderr)
    return float(hits[-1]) if hits else float("nan")


def decode(path):
    """Decode any audio file with ffmpeg to float32 stereo frames."""
    raw = subprocess.run([ffmpeg(), "-v", "error", "-i", path, "-f", "f32le", "-acodec", "pcm_f32le",
                          "-ac", "2", "-ar", str(SR), "-"], check=True, stdout=subprocess.PIPE).stdout
    return np.frombuffer(raw, dtype=np.float32).reshape(-1, 2).astype(np.float64)


def render_loop_exact(song, tmp, gain, fx_extra=None, reps=3, blend=2048):
    """One seamless pass of the loop as float frames, exactly LOOP_SAMPLES long.

    This is sf_kit.render_loop's method (render the loop `reps` times back to back so every
    pass after the first starts with the last one's tails ringing in, and keep an interior
    pass), with the two changes this job needs. Nothing is normalised here (the level is set
    later, by RMS). And the end of the kept pass is ALWAYS cross-faded, over `blend` samples
    (46 ms), into the audio that came just before the pass began, so the wrap is continuous
    by construction: the last sample is the very sample that preceded the first one in the
    long render. sf_kit only blends when the step is over four typical steps, and a sustained
    bass can sit just under that with a step that is large for where it falls.
    Returns (frames, raw_step): raw_step is the wrap's jump before the blend."""
    mid = os.path.join(tmp, "x.mid")
    wav = os.path.join(tmp, "x.wav")
    song._tripled_midi(BEATS * 480, reps).save(mid)
    fx = list(_FX) + list(fx_extra or [])
    subprocess.run([FLUID, "-ni", "-F", wav, "-r", str(SR), "-g", str(gain), *fx, SF2, mid], check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    d, sr = sf.read(wav)
    assert sr == SR
    L = LOOP_SAMPLES
    assert len(d) >= (reps - 1) * L, "the render is shorter than the passes it should hold"
    cands = sorted((float(np.abs(d[k * L] - d[(k + 1) * L - 1]).max()), k) for k in range(1, reps - 1))
    raw_step, keep = cands[0]
    seg = d[keep * L:(keep + 1) * L].copy()
    w = np.linspace(0.0, 1.0, blend)[:, None]
    seg[-blend:] = seg[-blend:] * (1.0 - w) + d[keep * L - blend:keep * L] * w
    os.remove(wav)
    os.remove(mid)
    return seg, raw_step


def render_area(song, index, gain=0.4, reps=3, fx_extra=None, post=None, target_db=None, keep_wav=None):
    """Render one area's loop to audio/music/peak/peak_a<index>.ogg and measure it."""
    os.makedirs(OUT_MUSIC, exist_ok=True)
    target_db = target_rms_db() if target_db is None else target_db
    tmp = tempfile.mkdtemp(prefix="peak_a%d_" % index)
    name = "peak_a%d" % index
    try:
        wav = os.path.join(tmp, name + ".wav")
        d, raw_step = render_loop_exact(song, tmp, gain, fx_extra, reps)
        assert np.abs(d).max() < 0.999, f"{name}: the raw render clips; lower gain (now {gain})"
        assert len(d) == LOOP_SAMPLES                            # one common length, to the sample
        if post is not None:
            d = post(d)
        d = d - d.mean(axis=0)                                   # no DC
        d = d * (10 ** ((target_db - rms_db(d)) / 20.0))
        peak = float(np.abs(d).max())
        assert peak < 0.98, f"{name}: peak {peak:.3f} at the target loudness; tame the loudest hits"
        sf.write(wav, d, SR, subtype="PCM_16")
        w, _ = sf.read(wav)
        assert len(w) == LOOP_SAMPLES
        w_seam, w_delta, w_local, w_click = seam_of(w)
        ogg = os.path.join(OUT_MUSIC, name + ".ogg")
        subprocess.run([ffmpeg(), "-y", "-v", "error", "-i", wav, "-c:a", "libvorbis", "-q:a", OGG_QUALITY,
                        "-map_metadata", "-1", "-fflags", "+bitexact", "-flags:a", "+bitexact", ogg], check=True)
        o = decode(ogg)
        o_seam, o_delta, o_local, o_click = seam_of(o)
        n = min(len(o), len(w))
        err = o[:n] - w[:n]
        edge = np.concatenate([err[:512], err[-512:]])
        m = {
            "file": "audio/music/peak/%s.ogg" % name,
            "samples": int(len(o)),
            "seconds": round(len(o) / SR, 4),
            "wav_samples": int(len(w)),
            "rms_db": round(rms_db(o), 2),
            "lufs": lufs(ogg),
            "peak": round(float(np.abs(o).max()), 3),
            "raw_step": round(raw_step, 6),
            "wav_seam": round(w_seam, 6), "wav_delta": round(w_delta, 6), "wav_local": round(w_local, 6),
            "wav_click": round(w_click, 2),
            "ogg_seam": round(o_seam, 6), "ogg_delta": round(o_delta, 6), "ogg_local": round(o_local, 6),
            "ogg_click": round(o_click, 2),
            "wav_seam_ok": bool(w_seam < 4 * w_delta and w_seam < 4 * w_local),
            "ogg_seam_ok": bool(o_seam < 4 * o_delta and o_click < 1.0),
            "ogg_edge_err_db": round(rms_db(edge), 1),
            "ogg_mid_err_db": round(rms_db(err[n // 2 - 4096:n // 2 + 4096]), 1),
            "ogg_kb": round(os.path.getsize(ogg) / 1024.0, 1),
        }
        if keep_wav:
            shutil.copy(wav, keep_wav)
        return m
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def a_weighted_active_db(d):
    """How loud a part is to an ear, roughly: A-weighted, and only over the 0.4 s blocks in
    which it is actually playing (within 30 dB of its loudest block)."""
    m = d.mean(axis=1)
    f = np.fft.rfftfreq(len(m), 1.0 / SR)
    f2 = f ** 2
    ra = (12194.0 ** 2 * f2 ** 2) / ((f2 + 20.6 ** 2) * np.sqrt((f2 + 107.7 ** 2) * (f2 + 737.9 ** 2)) * (f2 + 12194.0 ** 2) + 1e-30)
    w = np.fft.irfft(np.fft.rfft(m) * ra * 1.2589, len(m))
    blk = int(0.4 * SR)
    n = len(w) // blk
    if n == 0:
        return -120.0
    p = (w[:n * blk].reshape(n, blk) ** 2).mean(axis=1)
    live = p[p > p.max() * 1e-3]
    return float(10 * np.log10(max(1e-12, live.mean()))) if len(live) else -120.0


def stem_levels(song, bars=32):
    """Dev tool: render each track alone (straight, the first `bars` bars) and return its
    level three ways (plain RMS, A-weighted while playing, peak), so a part's place in the
    mix is a number and not a guess."""
    tmp = tempfile.mkdtemp(prefix="peak_stems_")
    out = []
    try:
        for i, tr in enumerate(song.tracks):
            solo = Song(tempo=song.tempo)
            solo.tracks = [tr]
            wav = os.path.join(tmp, "stem%d.wav" % i)
            keep = tr.events
            tr.events = [e for e in keep if e[0] < bars * 4 * 480]
            try:
                solo.render(wav, gain=0.4)
            finally:
                tr.events = keep
            d, _ = sf.read(wav)
            d = d[:bars * 4 * SPB]
            out.append((tr.name, rms_db(d), a_weighted_active_db(d), float(np.abs(d).max())))
        full = os.path.join(tmp, "full.wav")
        song.render(full, gain=0.4)
        d, _ = sf.read(full)
        d = d[:bars * 4 * SPB]
        out.append(("ALL", rms_db(d), a_weighted_active_db(d), float(np.abs(d).max())))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    return out
