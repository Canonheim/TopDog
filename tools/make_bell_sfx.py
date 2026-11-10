"""THE BELL BASE'S RING (Parker 11-10: "a deeper church bell like tone, with multiple
slight pitch variations"). Three strikes at slightly different pitches, additive: a
church bell's partials (hum, prime, tierce, quint, nominal, upper partials), each slightly
off-harmonic and decaying at its own rate (the hum longest), with a short metallic strike
at the front. Sound.play_at adds its own +-8% pitch on top.

Run: python tools/make_bell_sfx.py   (writes audio/sfx/church_bell_01..03.wav)
"""
import os
import numpy as np
import soundfile as sf

SR = 44100
LEN = 4.0
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "audio", "sfx")

# (ratio to the prime, amplitude, decay seconds): a minor-third church bell
PARTIALS = [
    (0.5, 0.55, 3.6),    # hum
    (1.0, 0.70, 2.6),    # prime
    (1.183, 0.50, 2.0),  # tierce (minor third), the bell's colour
    (1.506, 0.30, 1.6),  # quint
    (2.0, 0.65, 1.4),    # nominal (the strike note)
    (2.51, 0.22, 0.9),   # superquint
    (2.66, 0.18, 0.8),
    (3.01, 0.15, 0.6),
    (4.07, 0.10, 0.35),
]


def strike(prime_hz: float, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    t = np.arange(int(SR * LEN)) / SR
    y = np.zeros_like(t)
    for ratio, amp, decay in PARTIALS:
        f = prime_hz * ratio * (1.0 + rng.uniform(-0.004, 0.004))
        # each partial is a slightly beating pair, the way a real bell's are
        beat = 1.0 + 0.12 * np.cos(2 * np.pi * rng.uniform(0.6, 2.2) * t)
        y += amp * beat * np.sin(2 * np.pi * f * t + rng.uniform(0, 2 * np.pi)) * np.exp(-t / decay)
    # the strike: a bright, very short clang
    n = int(SR * 0.04)
    clang = rng.normal(0, 1, n) * np.exp(-np.arange(n) / (SR * 0.008))
    clang = np.convolve(clang, np.ones(6) / 6, mode="same")
    y[:n] += 0.35 * clang
    attack = np.minimum(1.0, t / 0.004)
    y *= attack
    fade = np.ones_like(t)
    tail = int(SR * 0.4)
    fade[-tail:] = np.linspace(1.0, 0.0, tail)
    y *= fade
    return (0.6 * y / np.max(np.abs(y))).astype(np.float32)


if __name__ == "__main__":
    for i, prime in enumerate([156.0, 165.0, 175.0], start=1):
        path = os.path.normpath(os.path.join(OUT, "church_bell_%02d.wav" % i))
        sf.write(path, strike(prime, 7 + i), SR, subtype="PCM_16")
        print("wrote", path)
