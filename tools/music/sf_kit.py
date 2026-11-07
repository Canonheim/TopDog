"""
sf_kit — a composition toolkit that knows the WHOLE GeneralUser-GS soundfont.

It parses the .sf2 at import so PRESETS is always the real, complete list
(287 presets across banks 0-128), gives you named lookup, a GM drum key map,
scale/chord helpers, a tiny multi-track MIDI builder, and a render() that uses
Parker's tuned FluidSynth settings with correct Windows paths.

Quickstart:
    from sf_kit import Song, find, PRESETS, DRUMS, scale, chord
    s = Song(tempo=110)
    lead = s.track("Nylon Guitar")          # look up by name
    lead.notes([62,64,66,67], dur=0.5)
    dr = s.drums()                          # channel 10 kit
    dr.hit("Acoustic Snare", at=1.0)
    s.render("mytune.wav")
"""
import os, struct, subprocess
import mido
from mido import Message, MidiFile, MidiTrack, MetaMessage

# ---- environment (this machine) -------------------------------------------
# Repo-relative paths (this file lives in tools/music/; fluidsynth + the
# soundfont ship in tools/ — GOLEMHEIM.md law: everything renders after a pull)
_HERE = os.path.dirname(os.path.abspath(__file__))
FLUID = os.path.join(_HERE, "..", "bin", "fluidsynth", "fluidsynth.exe")
SF2   = os.path.join(_HERE, "..", "soundfonts", "GeneralUser-GS.sf2")
TPB   = 480  # ticks per beat

# tuned render settings (mirrors render.sh)
_FX = ["-o","synth.reverb.damp=0.3","-o","synth.reverb.level=0.4",
       "-o","synth.reverb.room-size=0.4","-o","synth.reverb.width=0.8",
       "-o","synth.chorus.depth=3.6","-o","synth.chorus.level=0.55",
       "-o","synth.chorus.nr=4","-o","synth.chorus.speed=0.36",
       "-o","synth.device-id=16"]

# ---- parse the soundfont so we KNOW every preset --------------------------
def _load_presets(path=SF2):
    data = open(path, "rb").read()
    assert data[:4] == b"RIFF" and data[8:12] == b"sfbk"
    i, pdta_off, pdta_sz = 12, None, None
    while i < len(data) - 8:
        cid = data[i:i+4]; sz = struct.unpack_from("<I", data, i+4)[0]
        if cid == b"LIST" and data[i+8:i+12] == b"pdta":
            pdta_off, pdta_sz = i+12, sz-4; break
        i += 8 + sz + (sz & 1)
    j = pdta_off
    while j < pdta_off + pdta_sz - 8:
        cid = data[j:j+4]; sz = struct.unpack_from("<I", data, j+4)[0]
        if cid == b"phdr":
            ph_off, ph_sz = j+8, sz; break
        j += 8 + sz + (sz & 1)
    out = {}
    for k in range(ph_sz // 38):
        rec = data[ph_off + k*38: ph_off + k*38 + 38]
        name = rec[:20].split(b"\x00")[0].decode("latin-1").strip()
        preset, bank = struct.unpack_from("<HH", rec, 20)
        if name != "EOP":
            out[(bank, preset)] = name
    return out

PRESETS = _load_presets()                      # {(bank, program): name}
_BY_NAME = {}                                  # lowercased name -> (bank, program)
for (b, p), nm in PRESETS.items():
    _BY_NAME.setdefault(nm.lower(), (b, p))

def find(name):
    """Look up a preset by name (case-insensitive, exact or substring)."""
    key = name.lower()
    if key in _BY_NAME:
        return _BY_NAME[key]
    hits = [(b, p, nm) for (b, p), nm in PRESETS.items() if key in nm.lower()]
    if not hits:
        raise KeyError(f"no preset matching {name!r}")
    hits.sort()
    return hits[0][0], hits[0][1]

def search(substr):
    """Return every (bank, program, name) whose name contains substr."""
    s = substr.lower()
    return sorted((b, p, nm) for (b, p), nm in PRESETS.items() if s in nm.lower())

# ---- GM percussion key map (drum channel, bank 128) -----------------------
DRUMS = {
    "Kick": 36, "Acoustic Bass Drum": 35, "Bass Drum 1": 36,
    "Side Stick": 37, "Acoustic Snare": 38, "Hand Clap": 39, "Electric Snare": 40,
    "Low Floor Tom": 41, "Closed Hi-Hat": 42, "High Floor Tom": 43,
    "Pedal Hi-Hat": 44, "Low Tom": 45, "Open Hi-Hat": 46, "Low-Mid Tom": 47,
    "Hi-Mid Tom": 48, "Crash Cymbal 1": 49, "High Tom": 50, "Ride Cymbal 1": 51,
    "Chinese Cymbal": 52, "Ride Bell": 53, "Tambourine": 54, "Splash Cymbal": 55,
    "Cowbell": 56, "Crash Cymbal 2": 57, "Vibraslap": 58, "Ride Cymbal 2": 59,
    "Hi Bongo": 60, "Low Bongo": 61, "Mute Hi Conga": 62, "Open Hi Conga": 63,
    "Low Conga": 64, "High Timbale": 65, "Low Timbale": 66, "High Agogo": 67,
    "Low Agogo": 68, "Cabasa": 69, "Maracas": 70, "Short Whistle": 71,
    "Long Whistle": 72, "Short Guiro": 73, "Long Guiro": 74, "Claves": 75,
    "Hi Wood Block": 76, "Low Wood Block": 77, "Mute Cuica": 78, "Open Cuica": 79,
    "Mute Triangle": 80, "Open Triangle": 81,
}

# ---- music theory helpers -------------------------------------------------
_STEPS = {"major":[0,2,4,5,7,9,11], "minor":[0,2,3,5,7,8,10],
          "dorian":[0,2,3,5,7,9,10], "mixolydian":[0,2,4,5,7,9,10],
          "lydian":[0,2,4,6,7,9,11], "phrygian":[0,1,3,5,7,8,10],
          "harmonic_minor":[0,2,3,5,7,8,11], "pentatonic":[0,2,4,7,9],
          "minor_pentatonic":[0,3,5,7,10], "blues":[0,3,5,6,7,10],
          "chromatic":list(range(12))}

def scale(root, mode="major", octaves=1):
    steps = _STEPS[mode]
    return [root + 12*o + s for o in range(octaves) for s in steps] + [root + 12*octaves]

def chord(root, quality="maj"):
    q = {"maj":[0,4,7], "min":[0,3,7], "dim":[0,3,6], "aug":[0,4,8],
         "sus2":[0,2,7], "sus4":[0,5,7], "maj7":[0,4,7,11], "min7":[0,3,7,10],
         "dom7":[0,4,7,10], "add9":[0,4,7,14], "5":[0,7], "min9":[0,3,7,10,14]}[quality]
    return [root + i for i in q]

# ---- MIDI building --------------------------------------------------------
class Track:
    def __init__(self, song, channel, bank, program, name):
        self.song, self.ch, self.name = song, channel, name
        self.events = []   # (abs_tick, 'on'/'off', note, vel)
        self.cursor = 0    # in beats
        self._bank, self._prog = bank, program

    def _add(self, note, start_beat, dur_beats, vel):
        if not (0 <= note <= 127):
            raise ValueError(f"[{self.name}] note {note} out of MIDI range 0..127")
        vel = max(1, min(127, int(vel)))
        t0 = int(round(start_beat * TPB)); t1 = int(round((start_beat+dur_beats)*TPB)) - 8
        self.events.append((t0, 'on', note, vel))
        self.events.append((max(t0+1, t1), 'off', note, 0))

    def note(self, n, dur=1.0, vel=90, advance=True):
        self._add(n, self.cursor, dur, vel)
        if advance: self.cursor += dur
        return self

    def notes(self, seq, dur=1.0, vel=90):
        """seq: list of ints, or list of (note, dur) / (note, dur, vel) tuples."""
        for item in seq:
            if isinstance(item, (tuple, list)):
                n = item[0]; d = item[1] if len(item) > 1 else dur
                v = item[2] if len(item) > 2 else vel
                self.note(n, d, v)
            else:
                self.note(item, dur, vel)
        return self

    def chord(self, notes, dur=1.0, vel=85, strum=0.0, advance=True):
        for i, n in enumerate(notes):
            self._add(n, self.cursor + i*strum, dur - i*strum, vel)
        if advance: self.cursor += dur
        return self

    def rest(self, dur=1.0):
        self.cursor += dur; return self

    def cc(self, control, value, at=None):
        """Queue a MIDI CC (7=volume, 11=expression, ...) at a beat position."""
        t = self.cursor if at is None else at
        self.events.append((int(round(t*TPB)), 'cc', int(control), int(value)))
        return self

    def ramp_cc(self, control, v0, v1, t0, t1, steps=12):
        """Linear CC ramp from v0 to v1 across beats [t0, t1] — a volume fade."""
        for i in range(steps + 1):
            f = i / steps
            self.cc(control, int(round(v0 + (v1 - v0) * f)), at=t0 + (t1 - t0) * f)
        return self

    def at(self, beat):
        self.cursor = beat; return self

class Song:
    def __init__(self, tempo=120, numerator=4, denominator=4):
        self.tempo, self.num, self.den = tempo, numerator, denominator
        self.tracks = []

    def track(self, preset, channel=None):
        bank, prog = find(preset) if isinstance(preset, str) else preset
        ch = channel if channel is not None else self._next_channel()
        t = Track(self, ch, bank, prog, preset if isinstance(preset, str) else PRESETS.get((bank,prog), str(preset)))
        self.tracks.append(t); return t

    def drums(self, kit=0):
        # GS drum bank is CC0=120 (128 can't be sent as a MIDI bank-select value).
        t = Track(self, 9, 120, kit, "Drum Kit")   # channel 10, GS drum bank
        self.tracks.append(t)
        t.hit = lambda name, at=None, vel=100, dur=0.1: (
            t.at(at) if at is not None else t, t.note(DRUMS[name], dur, vel, advance=False))[-1]
        return t

    def _next_channel(self):
        used = {t.ch for t in self.tracks}
        for c in list(range(0,9)) + list(range(10,16)):
            if c not in used: return c
        return 0

    def to_midi(self):
        mid = MidiFile(ticks_per_beat=TPB)
        meta = MidiTrack(); mid.tracks.append(meta)
        meta.append(MetaMessage('set_tempo', tempo=mido.bpm2tempo(self.tempo), time=0))
        meta.append(MetaMessage('time_signature', numerator=self.num, denominator=self.den, time=0))
        for t in self.tracks:
            tr = MidiTrack(); mid.tracks.append(tr)
            tr.append(Message('control_change', channel=t.ch, control=0,  value=t._bank, time=0))
            tr.append(Message('control_change', channel=t.ch, control=32, value=0, time=0))
            tr.append(Message('program_change', channel=t.ch, program=t._prog, time=0))
            evs = sorted(t.events, key=lambda e: (e[0], e[1]=='on'))
            prev = 0
            for tick, kind, a, b in evs:
                dt = tick - prev
                if kind == 'cc':
                    tr.append(Message('control_change', channel=t.ch, control=a, value=b, time=dt))
                else:
                    tr.append(Message('note_on' if kind=='on' else 'note_off',
                                      channel=t.ch, note=a, velocity=b, time=dt))
                prev = tick
        return mid

    def save_midi(self, path):
        self.to_midi().save(path); return path

    def render(self, wav_path, gain=0.6, normalize=None):
        mid_path = os.path.splitext(wav_path)[0] + ".mid"
        self.save_midi(mid_path)
        subprocess.run([FLUID, "-ni", "-F", wav_path, "-r", "44100", "-g", str(gain),
                        *_FX, SF2, mid_path], check=True,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if normalize:
            import soundfile as sf, numpy as np
            d, sr = sf.read(wav_path); pk = np.abs(d).max()
            if pk > 0: sf.write(wav_path, d*(normalize/pk), sr, subtype="PCM_16")
        return wav_path

    def _tripled_midi(self, loop_ticks, reps):
        mid = MidiFile(ticks_per_beat=TPB)
        meta = MidiTrack(); mid.tracks.append(meta)
        meta.append(MetaMessage('set_tempo', tempo=mido.bpm2tempo(self.tempo), time=0))
        meta.append(MetaMessage('time_signature', numerator=self.num, denominator=self.den, time=0))
        for t in self.tracks:
            tr = MidiTrack(); mid.tracks.append(tr)
            tr.append(Message('control_change', channel=t.ch, control=0,  value=t._bank, time=0))
            tr.append(Message('control_change', channel=t.ch, control=32, value=0, time=0))
            tr.append(Message('program_change', channel=t.ch, program=t._prog, time=0))
            allev = [(tick + r*loop_ticks, kind, a, b)
                     for r in range(reps) for (tick, kind, a, b) in t.events]
            allev.sort(key=lambda e: (e[0], e[1] == 'on'))
            prev = 0
            for tick, kind, a, b in allev:
                dt = tick - prev
                if kind == 'cc':
                    tr.append(Message('control_change', channel=t.ch, control=a, value=b, time=dt))
                else:
                    tr.append(Message('note_on' if kind == 'on' else 'note_off',
                                      channel=t.ch, note=a, velocity=b, time=dt))
                prev = tick
        return mid

    def render_loop(self, wav_path, loop_beats, reps=8, gain=0.6, normalize=0.89, chorus=True, fx_extra=None):
        """Render the one-iteration content x`reps` and AUTO-KEEP the interior
        iteration whose wrap point splices most cleanly -> seamless loop.

        Lush arrangements (organ/bell/choir/strings) have voice tails longer than one
        loop, so the render never settles to a single steady state and the loop-point
        seam is bimodal across iterations -- most splice cleanly, a few land on a tail
        peak. Rather than gamble on a fixed iteration, we score every interior iteration
        and keep the lowest-seam one. Compose a CONTINUOUS core (no intro/outro) whose
        last bar leads back to bar 1, and use a tempo where 44100*60/tempo is integer
        (e.g. 84, 80, 75, 72, 70) for a sample-exact loop."""
        import soundfile as sf, numpy as np
        loop_ticks = int(round(loop_beats * TPB))
        tmp_mid = os.path.splitext(wav_path)[0] + f"_x{reps}.mid"
        tmp_wav = os.path.splitext(wav_path)[0] + f"_x{reps}.wav"
        self._tripled_midi(loop_ticks, reps).save(tmp_mid)
        if chorus:
            fx = _FX
        else:  # drop each "-o synth.chorus.*" PAIR, then force chorus off
            fx = []
            i = 0
            while i < len(_FX):
                if _FX[i] == "-o" and "chorus" in _FX[i+1]:
                    i += 2; continue
                fx.append(_FX[i]); i += 1
            fx += ["-o", "synth.chorus.active=0"]
        if fx_extra:
            fx = fx + list(fx_extra)          # later -o wins: per-render overrides
        subprocess.run([FLUID, "-ni", "-F", tmp_wav, "-r", "44100", "-g", str(gain),
                        *fx, SF2, tmp_mid], check=True,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        d, sr = sf.read(tmp_wav)
        L = int(round(loop_beats * sr * 60 / self.tempo))
        # score every interior iteration by its wrap-point seam; keep the cleanest
        cands = []
        for k in range(1, reps - 1):
            s = d[k*L:(k+1)*L]
            cands.append((float(np.abs(s[0] - s[-1]).max()), k))
        cands.sort()
        best_seam, keep = cands[0]
        seg = d[keep*L:(keep+1)*L].copy()
        typ = float(np.abs(np.diff(seg[:, 0])).mean())
        # Wash-heavy mixes (big reverb + stacked sustains) never settle to a
        # loop-periodic state, so every candidate wraps with a step. Fix: blend
        # the last 10ms into the audio that PRECEDED seg[0] in the x-render —
        # the wrap becomes continuous by construction, inaudible in 10ms.
        if float(np.abs(seg[0] - seg[-1]).max()) >= typ*4 and keep >= 1:
            n = int(0.010 * sr)
            pre = d[keep*L - n:keep*L]
            w = np.linspace(0.0, 1.0, n)[:, None]
            seg[-n:] = seg[-n:] * (1.0 - w) + pre * w
        if normalize:
            pk = np.abs(seg).max()
            if pk > 0: seg = seg * (normalize/pk)
        seam = float(np.abs(seg[0] - seg[-1]).max())
        typ  = float(np.abs(np.diff(seg[:, 0])).mean())
        verdict = 'OK' if seam < typ*4 else 'AUDIBLE'
        print(f"{os.path.basename(wav_path)}: {len(seg)/sr:.4f}s  kept iter {keep}/{reps}  "
              f"seam={seam:.6f} vs delta={typ:.6f} -> {verdict}")
        sf.write(wav_path, seg, sr, subtype="PCM_16")
        os.remove(tmp_mid); os.remove(tmp_wav)
        return wav_path

def render_midi(mid_path, wav_path, gain=0.6):
    """Render an existing .mid through the tuned settings."""
    subprocess.run([FLUID, "-ni", "-F", wav_path, "-r", "44100", "-g", str(gain),
                    *_FX, SF2, mid_path], check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return wav_path

if __name__ == "__main__":
    print(f"soundfont knows {len(PRESETS)} presets across "
          f"{len(set(b for b,_ in PRESETS))} banks")
    print("drum keys:", len(DRUMS))
