"""The star wipe's two swooshes (Parker 11-20), synthesised: nothing sampled, nothing downloaded.

    python tools/make_star_wipe_sfx.py

Writes audio/sfx/star_wipe_in.wav and star_wipe_out.wav: mono, 16-bit, 44.1 kHz, normalised to -3 dBFS
peak (the house format of tools/peak/make_peak_sfx.py).
- IN (the star closing to black, 0.55 s): a whoosh of noise through a band-pass sweeping down, a slide
  whistle falling with it, and a soft low "tunk" as the star shuts.
- OUT (the star opening on the climb, 0.6 s): the whoosh sweeping up, the whistle rising, and three quick
  bright pings as it opens.
"""
import os
import wave

import numpy as np

SR = 44100
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "audio", "sfx")


def bandpass_sweep(x, f0, f1, q=2.2):
    """x through a 2-pole resonator whose centre glides exponentially from f0 to f1 (RBJ band-pass, per sample)."""
    n = len(x)
    fc = f0 * (f1 / f0) ** (np.arange(n) / max(1, n - 1))
    y = np.zeros(n)
    x1 = x2 = y1 = y2 = 0.0
    for i in range(n):
        w = 2.0 * np.pi * fc[i] / SR
        al = np.sin(w) / (2.0 * q)
        b0, b2 = al, -al
        a0, a1, a2 = 1.0 + al, -2.0 * np.cos(w), 1.0 - al
        yi = (b0 * x[i] + b2 * x2 - a1 * y1 - a2 * y2) / a0
        x2, x1 = x1, x[i]
        y2, y1 = y1, yi
        y[i] = yi
    return y


def glide_tone(dur, f0, f1, vib=6.0, depth=0.012):
    t = np.arange(int(dur * SR)) / SR
    f = f0 * (f1 / f0) ** (t / dur) * (1.0 + depth * np.sin(2 * np.pi * vib * t))
    ph = 2 * np.pi * np.cumsum(f) / SR
    return np.sin(ph) + 0.25 * np.sin(2 * ph)


def env(n, attack, release, total):
    t = np.arange(n) / SR
    e = np.clip(t / attack, 0, 1) * np.clip((total - t) / release, 0, 1)
    return e


def ping(freq, dur=0.22):
    t = np.arange(int(dur * SR)) / SR
    return (np.sin(2 * np.pi * freq * t) + 0.4 * np.sin(2 * np.pi * freq * 2.76 * t)) * np.exp(-t * 18.0)


def place(buf, clip, at_s, gain):
    i = int(at_s * SR)
    j = min(len(buf), i + len(clip))
    buf[i:j] += clip[: j - i] * gain


def write(name, y):
    y = y / max(1e-9, np.max(np.abs(y))) * (10 ** (-3 / 20))
    pcm = (np.clip(y, -1, 1) * 32767).astype(np.int16)
    path = os.path.join(OUT, name + ".wav")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    print("wrote", os.path.normpath(path), "%.2f s" % (len(y) / SR))


def main():
    rng = np.random.default_rng(1120)
    # IN: the star closing
    dur = 0.55
    n = int(dur * SR)
    whoosh = bandpass_sweep(rng.standard_normal(n), 3200.0, 420.0) * env(n, 0.06, 0.10, dur)
    whistle = glide_tone(0.5, 1500.0, 330.0) * env(int(0.5 * SR), 0.03, 0.08, 0.5)
    y = whoosh * 1.0
    place(y, whistle, 0.0, 0.22)
    t = np.arange(int(0.12 * SR)) / SR
    tunk = np.sin(2 * np.pi * (140.0 - 60.0 * t / 0.12) * t) * np.exp(-t * 30.0)
    place(y, tunk, dur - 0.12, 0.55)
    write("star_wipe_in", y)
    # OUT: the star opening
    dur = 0.6
    n = int(dur * SR)
    whoosh = bandpass_sweep(rng.standard_normal(n), 420.0, 3400.0) * env(n, 0.05, 0.16, dur)
    whistle = glide_tone(0.5, 330.0, 1500.0) * env(int(0.5 * SR), 0.05, 0.10, 0.5)
    y = whoosh * 1.0
    place(y, whistle, 0.04, 0.22)
    for k, (f, at) in enumerate(((2637.0, 0.30), (3322.0, 0.36), (4186.0, 0.42))):
        place(y, ping(f), at, 0.18 - 0.03 * k)
    write("star_wipe_out", y)


if __name__ == "__main__":
    main()
