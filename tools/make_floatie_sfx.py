"""Del Mar's floatie boing (Parker 11-11: "the bouncy floats should have ... a sound
effect when you hit them"). Synthesized, nothing sampled: a soft rubber thump, a
squeak of rubber, then the spring's boing, a tone that bends up and wobbles as it dies.

    python tools/make_floatie_sfx.py

writes audio/sfx/floatie_boing_01..03.wav (mono, 16-bit, 44.1 kHz, -1 dBFS), the
"floatie" sound in core/sound.gd. The game pitches each floatie's kind on top.
"""
import os
import wave

import numpy as np

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "audio", "sfx")


def boing(seed, f0, wobble_hz, length=0.75):
    rng = np.random.default_rng(seed)
    t = np.arange(int(SR * length)) / SR
    # The thump: the body landing on air-filled rubber, low and quick.
    thump_f = 70.0 + 50.0 * np.exp(-t * 30.0)
    thump = np.sin(2 * np.pi * np.cumsum(thump_f) / SR) * np.exp(-t * 26.0)
    # The flub: a short burst of low noise, smoothed (rubber slapping).
    noise = rng.standard_normal(t.size)
    k = 40
    noise = np.convolve(noise, np.ones(k) / k, mode="same")
    flub = noise * np.exp(-t * 45.0) * 3.0
    # The squeak: a quick high chirp, rubber dragged on rubber.
    sq_f = 900.0 + 700.0 * np.clip(t / 0.05, 0, 1)
    squeak = np.sin(2 * np.pi * np.cumsum(sq_f) / SR) * np.exp(-t * 60.0) * np.clip(t / 0.006, 0, 1) * 0.25
    # The boing: bends up from under its note, then wobbles (the spring) as it dies.
    bend = 0.62 + 0.38 * (1.0 - np.exp(-t * 28.0))
    wob = 1.0 + 0.16 * np.sin(2 * np.pi * wobble_hz * t) * np.exp(-t * 2.2)
    f = f0 * bend * wob
    ph = 2 * np.pi * np.cumsum(f) / SR
    tone = np.sin(ph) + 0.42 * np.sin(2 * ph + 0.3) + 0.16 * np.sin(3 * ph + 1.1)
    env = np.clip(t / 0.008, 0, 1) * np.exp(-t * 4.6)
    tone *= env * 0.8
    mix = thump * 0.9 + flub * 0.5 + squeak + tone
    mix = np.tanh(mix * 1.4)
    fade = np.clip((length - t) / 0.05, 0, 1)
    mix *= fade
    mix /= np.max(np.abs(mix)) / (10 ** (-1.0 / 20.0))
    return mix


def write(path, x):
    data = (np.clip(x, -1, 1) * 32767).astype("<i2").tobytes()
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data)


if __name__ == "__main__":
    for i, (f0, wob) in enumerate([(196.0, 11.0), (220.0, 12.5), (175.0, 10.0)]):
        p = os.path.abspath(os.path.join(OUT, "floatie_boing_%02d.wav" % (i + 1)))
        write(p, boing(11 + i, f0, wob))
        print(p)
