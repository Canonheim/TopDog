"""The Peak's sound effects, all synthesised (nothing sampled, nothing downloaded).

    python tools/peak/make_peak_sfx.py            # every file, then docs/peak/SFX.md
    python tools/peak/make_peak_sfx.py drip amb_  # only names starting with these (no doc)

Writes audio/sfx/peak/*.wav: mono, 16-bit, 44.1 kHz (the house format of
tools/make_floatie_sfx.py). One-shots are normalised to -3 dBFS peak; loops and the
twelve ambience beds to -16 dBFS RMS, so the game sets the levels.

How the loops are made seamless: every loop is built PERIODIC over its own length.
Noise is shaped in the frequency domain (an inverse FFT of length N repeats every N
samples), slow movement comes from low-passed periodic noise or whole numbers of
cycles, events are added modulo N, and echo and reverb are circular convolutions. So
the last sample runs into the first with no crossfade. Each loop is then rotated to
start at a gentle zero crossing. The seam is still measured from the written file
(jump, slope, level either side) and printed in SFX.md.

The tools, all numpy: FFT noise shaping, biquad resonator banks (RBJ coefficients,
applied through their frequency response), heterodyned noise for moving band-passes
(wind), modal/additive banks (bells, glass, metal, drums), Karplus-Strong strings
(cable, ring rope), stick-slip impulse trains through resonators (creaks), FM (the
new-best chime), pitch envelopes (thumps, drips, boings).
"""
import os
import sys
import wave
import zlib

import numpy as np

SR = 44100
TAU = 2.0 * np.pi
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
OUT = os.path.join(ROOT, "audio", "sfx", "peak")
DOC = os.path.join(ROOT, "docs", "peak", "SFX.md")

SHOT_PEAK_DB = -3.0
LOOP_RMS_DB = -16.0
LOOP_CEIL_DB = -1.0

TRACE = None  # set to a list to collect a sound's layers (for checking a mix)


def st(label, x):
    if TRACE is not None:
        TRACE.append((label, np.array(x, dtype=float)))
    return x


# --------------------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------------------

def nsamp(sec):
    return int(round(sec * SR))


def tvec(n):
    return np.arange(n) / SR


def unit(x):
    r = np.sqrt(np.mean(x * x))
    return x / r if r > 0 else x


def pk(x):
    m = np.max(np.abs(x))
    return x / m if m > 0 else x


def _fftlen(n):
    return 1 << (int(n) - 1).bit_length()


def curve(f, lo=None, hi=None, order=2, tilt=0.0):
    """A magnitude curve: Butterworth-shaped high-pass at lo, low-pass at hi, and a
    tilt in dB per octave about 1 kHz (-3 pink, -6 brown)."""
    ff = np.maximum(f, 1e-9)
    g = np.ones_like(ff)
    if lo:
        g = g / np.sqrt(1.0 + (lo / ff) ** (2 * order))
    if hi:
        g = g / np.sqrt(1.0 + (ff / hi) ** (2 * order))
    if tilt:
        g = g * (np.maximum(ff, 20.0) / 1000.0) ** (tilt / 6.0206)
    return g


def noise(n, rng, lo=None, hi=None, order=2, tilt=0.0):
    """Shaped noise at unit RMS. Built in the frequency domain, so it is periodic over
    n samples: the base of every seamless loop."""
    spec = np.fft.rfft(rng.standard_normal(n))
    g = curve(np.fft.rfftfreq(n, 1.0 / SR), lo, hi, order, tilt)
    g[0] = 0.0
    return unit(np.fft.irfft(spec * g, n))


def filt(x, lo=None, hi=None, order=2, tilt=0.0, wrap=False):
    """Zero-phase FFT filter. wrap=True is circular (for loops)."""
    n = x.size
    m = n if wrap else _fftlen(n + SR // 2)
    g = curve(np.fft.rfftfreq(m, 1.0 / SR), lo, hi, order, tilt)
    if lo:
        g[0] = 0.0
    return np.fft.irfft(np.fft.rfft(x, m) * g, m)[:n]


def biquad_h(f, kind, f0, q):
    """The frequency response of an RBJ biquad (bp has unit gain at f0)."""
    w0 = TAU * f0 / SR
    a = np.sin(w0) / (2.0 * q)
    c = np.cos(w0)
    if kind == "bp":
        b0, b1, b2 = a, 0.0, -a
    elif kind == "lp":
        b0, b1, b2 = (1 - c) / 2, 1 - c, (1 - c) / 2
    else:
        b0, b1, b2 = (1 + c) / 2, -(1 + c), (1 + c) / 2
    z = np.exp(-1j * TAU * f / SR)
    return (b0 + b1 * z + b2 * z * z) / ((1 + a) - 2 * c * z + (1 - a) * z * z)


def resonate(x, modes, dry=0.0, wrap=False):
    """A bank of band-pass biquads in parallel: modes = [(hz, q, gain), ...]. Causal,
    so an impulse in rings after it, never before."""
    n = x.size
    m = n if wrap else _fftlen(n + SR // 4)
    f = np.fft.rfftfreq(m, 1.0 / SR)
    h = np.full(f.size, dry, dtype=complex)
    for f0, q, g in modes:
        h = h + g * biquad_h(f, "bp", f0, q)
    return np.fft.irfft(np.fft.rfft(x, m) * h, m)[:n]


def conv(x, ir, wrap=False):
    n = x.size
    if wrap:
        h = np.zeros(n)
        np.add.at(h, np.arange(ir.size) % n, ir)
        return np.fft.irfft(np.fft.rfft(x) * np.fft.rfft(h), n)
    m = _fftlen(n + ir.size)
    return np.fft.irfft(np.fft.rfft(x, m) * np.fft.rfft(ir, m), m)[:n]


def phase(f, n=None, wrap=False):
    """Phase of an oscillator at frequency f (array or number), starting at 0.
    wrap=True nudges the frequency so a whole number of cycles fits (loops)."""
    f = np.asarray(f, dtype=float)
    if f.ndim == 0:
        f = np.full(n, float(f))
    if wrap:
        cyc = f.sum() / SR
        f = f + (np.round(cyc) - cyc) * SR / f.size
    return TAU * (np.cumsum(f) - f) / SR


def sweep_noise(n, rng, fc, bw, order=1, wrap=True):
    """Band-passed noise whose centre moves: low-passed complex noise heterodyned up
    to fc(t). order 1 gives the skirts of a two-pole resonator (wind); 2 is a whistle."""
    i = noise(n, rng, hi=bw / 2.0, order=order)
    q = noise(n, rng, hi=bw / 2.0, order=order)
    ph = phase(fc, n, wrap)
    return (i * np.cos(ph) - q * np.sin(ph)) * 0.7071


def slow(n, rng, rate, lo=0.0, hi=1.0):
    """A smooth random curve in lo..hi that moves at about rate Hz, periodic over n."""
    x = noise(n, rng, hi=rate, order=3)
    x = (x - x.min()) / (x.max() - x.min() + 1e-12)
    return lo + (hi - lo) * x


def modal(n, parts):
    """Additive bank: parts = [(hz, amp, t60 seconds[, phase]), ...]."""
    t = tvec(n)
    y = np.zeros(n)
    for p in parts:
        ph0 = p[3] if len(p) > 3 else 0.0
        y += p[1] * np.sin(TAU * p[0] * t + ph0) * np.exp(-6.908 * t / p[2])
    return y


def tone(ph, harm):
    y = np.zeros(ph.size)
    for k, a in enumerate(harm):
        if a:
            y += a * np.sin((k + 1) * ph)
    return y


def ks(n, f0, t60, rng, bright=4000.0, pick=0.23):
    """Karplus-Strong plucked string, one period per numpy step."""
    per = max(4, int(round(SR / f0 - 0.5)))
    exc = noise(per, rng, hi=bright, order=1)
    exc = exc - np.roll(exc, int(per * pick))  # the comb of where it was plucked
    blocks = n // per + 2
    buf = np.zeros(blocks * per + 1)
    buf[1:per + 1] = exc
    g = 10.0 ** (-3.0 * per / (SR * t60))
    for k in range(1, blocks):
        s = 1 + k * per
        buf[s:s + per] = g * 0.5 * (buf[s - per:s] + buf[s - per - 1:s - 1])
    return buf[1:n + 1]


def warp(x, rate):
    """Play x back at a time-varying rate (1 = as is): pitch bends and vibrato."""
    pos = np.cumsum(rate) - rate[0]
    return np.interp(pos, np.arange(x.size), x, right=0.0)


def dull(y, split, tau):
    """Let everything above `split` Hz die away with time constant tau: a string or a
    rope loses its top first."""
    lo = filt(y, hi=split, order=2)
    return lo + (y - lo) * np.exp(-tvec(y.size) / tau)


def thump(n, f0, f1, tau_f, tau_a, attack=0.0008):
    """A sine that drops from f0 to f1 and dies: the low end of every impact."""
    t = tvec(n)
    f = f1 + (f0 - f1) * np.exp(-t / tau_f)
    return np.sin(phase(f)) * np.exp(-t / tau_a) * np.clip(t / attack, 0, 1)


def burst(n, rng, lo, hi, tau, attack=0.0004, order=2, tilt=0.0):
    """A band of noise with a fast attack and an exponential decay, peak near 1."""
    m = min(n, max(64, nsamp(tau * 14)))
    t = tvec(m)
    y = np.zeros(n)
    y[:m] = noise(m, rng, lo, hi, order, tilt) * np.exp(-t / tau) * np.clip(t / attack, 0, 1) / 2.5
    return y


def plink(f0, dur=0.25, rise=0.9, tau=0.03):
    """A water drop: a sine whose pitch jumps up as the bubble closes."""
    n = nsamp(dur)
    t = tvec(n)
    ph = phase(f0 * (1.0 + rise * (1.0 - np.exp(-t / 0.012))))
    return (np.sin(ph) + 0.07 * np.sin(2 * ph)) * np.exp(-t / tau) * np.clip(t / 0.0006, 0, 1)


def bubble(f0, dur, rise=0.6):
    n = nsamp(dur)
    t = tvec(n)
    u = t / dur
    ph = phase(f0 * (1.0 + rise * u ** 1.5))
    return np.sin(ph) * np.exp(-u * 5.0) * np.clip(t / 0.002, 0, 1) * np.clip((1 - u) / 0.1, 0, 1)


def chirp(f0, f1, dur, h2=0.15):
    n = nsamp(dur)
    u = np.arange(n) / n
    ph = phase(f0 * (f1 / f0) ** u)
    return (np.sin(ph) + h2 * np.sin(2 * ph)) * np.sin(np.pi * u) ** 1.5


def place(buf, x, at, gain=1.0, wrap=False):
    """Add x into buf at `at` seconds. wrap=True adds modulo the loop's length."""
    i = int(round(at * SR))
    n = buf.size
    if wrap:
        np.add.at(buf, (i + np.arange(x.size)) % n, gain * x)
    elif 0 <= i < n:
        m = min(x.size, n - i)
        buf[i:i + m] += gain * x[:m]


def scatter(rng, count, scale, tmax):
    """Event times that thin out (exponential), the first at 0, all before tmax."""
    out = [0.0]
    while len(out) < count:
        t = rng.exponential(scale)
        if 0.004 < t < tmax:
            out.append(t)
    return out


def reverb(x, rng, t60, mix, lo=150.0, hi=5000.0, pre=0.012, wrap=False):
    """A room: convolution with decaying noise (circular for loops)."""
    m = nsamp(min(t60 * 1.3, 6.0))
    t = tvec(m)
    ir = noise(m, rng, lo=lo, hi=hi, order=1, tilt=-3.0) * np.exp(-6.908 * t / t60)
    ir *= np.clip(t / 0.003, 0, 1)
    ir /= np.sqrt(np.sum(ir * ir))
    ir = np.concatenate([np.zeros(nsamp(pre)), ir])
    return x + mix * conv(x, ir, wrap)


def echo(x, delay, gains, hi=3000.0, wrap=False):
    """Discrete echoes, each duller than the last."""
    y = x.copy()
    d = nsamp(delay)
    e = x
    for k, g in enumerate(gains):
        e = filt(e, hi=hi, order=1, wrap=wrap)
        if wrap:
            y += g * np.roll(e, d * (k + 1))
        else:
            s = d * (k + 1)
            if s < x.size:
                y[s:] += g * e[:x.size - s]
    return y


def impulses(n, rng, rate, heavy=2.0):
    """Poisson clicks at `rate` per second (number or array), random size and sign."""
    mask = rng.random(n) < (np.asarray(rate, dtype=float) / SR)
    return mask * rng.random(n) ** heavy * rng.choice([-1.0, 1.0], n)


def creak(dur, rng, r0, r1, modes, jitter=0.08, gap=0.04, bend=1.0, wobble=0.12, drive=2.5):
    """Stick-slip: an uneven train of slips (rate r0 to r1 per second) ringing a body.
    Slow, it ticks; fast, the ticks run together into a pitched groan. A longer stick
    lets go harder, as real friction does."""
    n = nsamp(dur)
    imp = np.zeros(n)
    tcur = 0.0
    wf = rng.uniform(2.0, 5.0)
    wp = rng.uniform(0, TAU)
    while tcur < dur:
        u = tcur / dur
        r = r0 * (r1 / r0) ** (u ** bend) * (1.0 + wobble * np.sin(TAU * wf * tcur + wp))
        per = (1.0 / r) * max(0.3, 1.0 + jitter * rng.standard_normal())
        if rng.random() < gap:
            per *= rng.uniform(1.5, 2.2)
        i = int(tcur * SR)
        if i < n:
            imp[i] += (per * r) ** 0.5 * rng.uniform(0.7, 1.0)
        tcur += per
    y = np.tanh(drive * pk(resonate(imp, modes)))
    t = tvec(n)
    return pk(y * np.clip(t / 0.002, 0, 1) * np.clip((dur - t) / (dur * 0.25), 0, 1) ** 1.5)


def squeal(n, f, rng, rough=0.2, harm=(1.0, 0.45, 0.2, 0.08), jitter=0.004):
    """A friction squeak: a tone with a little pitch jitter and a rough edge."""
    f = np.asarray(f, dtype=float) * (1.0 + jitter * noise(n, rng, hi=40.0))
    y = tone(phase(f, n), harm)
    return y * (1.0 + rough * noise(n, rng, lo=20.0, hi=140.0))


def impact(n, rng, f_low=90.0, drop=1.7, t_low=0.06, low=1.0,
           nlo=300.0, nhi=2500.0, t_noise=0.02, nz=0.6, ring=()):
    y = low * thump(n, f_low * drop, f_low, 0.015, t_low)
    y += nz * burst(n, rng, nlo, nhi, t_noise)
    if ring:
        y += modal(n, ring)
    return y


def fire(n, rng, crackles=12.0, crack=1.0):
    """A flame: low flutter, a little roar, and sparse crackles. Periodic over n."""
    flut = noise(n, rng, lo=60, hi=800, order=1, tilt=-3.0) * (0.35 + 0.65 * slow(n, rng, 9.0)) ** 2
    roar = noise(n, rng, lo=300, hi=3000, order=1, tilt=-5.0) * (0.5 + 0.5 * slow(n, rng, 5.0))
    ker = burst(nsamp(0.03), rng, 900, 5500, 0.0025)
    cr = conv(impulses(n, rng, crackles, heavy=3.0), ker, wrap=True)
    return st("flutter", unit(flut)) + st("roar", 0.45 * unit(roar)) + st("crackle", cr * 7.0 * crack)


def flag(n, rng, rate=8.5, strength=None):
    """Cloth in wind: soft flaps at an uneven rate, plus a ripple. Periodic over n."""
    out = np.zeros(n)
    src = noise(max(n, SR), rng, lo=140, hi=2200, order=1, tilt=-3.5)
    dur = n / SR
    t = rng.uniform(0, 0.05)
    while t < dur:
        s = 1.0 if strength is None else float(strength[int(t * SR) % n])
        d = rng.uniform(0.02, 0.05)
        m = nsamp(d * 6)
        off = int(rng.integers(0, src.size - m))
        tt = tvec(m)
        e = np.clip(tt / 0.004, 0, 1) * np.exp(-tt / d)
        flap = src[off:off + m] * e * 0.6 + 0.5 * thump(m, rng.uniform(150, 220), 95, 0.02, d * 0.8, 0.003)
        place(out, flap, t, s * rng.uniform(0.45, 1.0), wrap=True)
        t += (1.0 / rate) * rng.uniform(0.6, 1.5)
    r = np.sqrt(np.mean(out * out))
    out = 2.2 * np.tanh(out / (2.2 * r))  # hold the biggest flaps down; now at unit RMS or so
    rip = noise(n, rng, lo=300, hi=3000, order=1, tilt=-4.0) * (0.3 + 0.7 * slow(n, rng, 14.0)) ** 2
    if strength is not None:
        rip = rip * strength
    return st("flaps", out) + st("ripple", 0.5 * unit(rip))


def wind(n, rng, c_lo, c_hi, bw, rate, body=0.5, air=0.3, gust=0.7, order=1):
    """Wind: a resonant band of noise whose centre and level ride one slow gust curve,
    over a low body and a little air. Returns (signal, gust curve 0..1)."""
    m = slow(n, rng, rate)
    m2 = slow(n, rng, rate * 1.7)
    fc = c_lo * (c_hi / c_lo) ** m
    w = unit(sweep_noise(n, rng, fc, bw, order)) * (1 - gust + gust * (0.25 + 0.75 * m ** 1.5))
    b = noise(n, rng, lo=70, hi=500, tilt=-3.0) * (1 - gust + gust * (0.3 + 0.7 * m2))
    a = noise(n, rng, lo=900, hi=4500, order=1, tilt=-4.5) * (1 - gust + gust * m ** 2)
    return w + body * b + air * a, m


def thunder_roll(dur, rng, crack=0.0, bumps=6, lp=220.0):
    n = nsamp(dur)
    t = tvec(n)
    env = np.zeros(n)
    tb = 0.0
    for k in range(bumps):
        a = rng.uniform(0.5, 1.0) * (1.0 if k == 0 else 0.85 ** k)
        at = rng.uniform(0.01, 0.07) if k == 0 else rng.uniform(0.04, 0.12)
        de = rng.uniform(0.3, 0.9)
        tt = t - tb
        env += a * np.where(tt >= 0, np.clip(tt / at, 0, 1) * np.exp(-np.maximum(tt, 0) / de), 0.0)
        tb += rng.uniform(0.25, 0.75) * dur / (bumps * 0.62)
        if tb > dur * 0.8:
            break
    env *= np.exp(-t / (dur * 0.45))
    y = noise(n, rng, lo=40, hi=lp, order=1, tilt=-3.0) * env
    y += 0.6 * noise(n, rng, lo=120, hi=900, tilt=-4.0) * env ** 1.6
    if crack > 0:
        c = burst(n, rng, 180, 3200, 0.07, tilt=-3.0)
        for k in range(4):
            place(c, burst(nsamp(0.4), rng, 250, 2600, rng.uniform(0.02, 0.05), tilt=-3.0),
                  rng.uniform(0.03, 0.32), rng.uniform(0.3, 0.7))
        y += crack * c * 2.2
    return y


# --------------------------------------------------------------------------------------
# finishing and measuring
# --------------------------------------------------------------------------------------

def finish_shot(x, tail=0.03, fade_in=0.0005):
    x = filt(x, lo=25.0, order=2)
    # drop dead air once the sound has gone 70 dB under its peak
    live = np.nonzero(np.abs(x) > np.max(np.abs(x)) * 10 ** (-70 / 20.0))[0]
    end = min(x.size, live[-1] + nsamp(0.02))
    if x.size - end > nsamp(0.02):
        x = x[:end]
    n = x.size
    k = max(2, nsamp(fade_in))
    x[:k] *= np.linspace(0.0, 1.0, k)
    k = min(n, max(2, nsamp(tail)))
    x[-k:] *= 0.5 * (1.0 + np.cos(np.linspace(0.0, np.pi, k)))
    return x * (10 ** (SHOT_PEAK_DB / 20.0) / np.max(np.abs(x)))


def best_start(x, window=0.25):
    """A loop that is periodic can start anywhere. Of the places in the first quarter
    second where the level is steadiest (50 ms before against 50 ms after), start at the
    one where the wave crosses zero most gently, so the file begins and ends at rest
    and a player that starts it cold makes no click."""
    n = x.size
    k = min(n // 4, nsamp(window))
    w = nsamp(0.05)
    xx = np.concatenate([x[-w - 2:], x[:k + w + 2]])  # the stretch round the old seam, unwrapped
    i = np.arange(w + 2, w + 2 + k)
    c = np.concatenate([[0.0], np.cumsum(xx * xx)])
    step = np.abs(np.log((c[i + w] - c[i] + 1e-12) / (c[i] - c[i - w] + 1e-12)))
    score = (np.abs(xx[i]) + np.abs(xx[i - 1]) + np.abs(xx[i + 1] - 2 * xx[i] + xx[i - 1])
             + np.abs(xx[i] - 2 * xx[i - 1] + xx[i - 2]))
    score = np.where(step <= np.percentile(step, 25), score, np.inf)
    return np.roll(x, -int(np.argmin(score)))


def finish_loop(x):
    x = filt(x, lo=22.0, order=2, wrap=True)
    target = 10 ** (LOOP_RMS_DB / 20.0)
    ceil = 10 ** (LOOP_CEIL_DB / 20.0)
    for _ in range(8):
        x = x * (target / np.sqrt(np.mean(x * x)))
        if np.max(np.abs(x)) <= ceil:
            break
        x = ceil * np.tanh(x / ceil)  # a static soft ceiling keeps the loop periodic
    return x


def write_wav(path, x):
    data = np.round(np.clip(x, -1, 1) * 32767).astype("<i2").tobytes()
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data)


def read_wav(path):
    with wave.open(path, "rb") as w:
        assert w.getnchannels() == 1 and w.getsampwidth() == 2 and w.getframerate() == SR
        return np.frombuffer(w.readframes(w.getnframes()), dtype="<i2").astype(float) / 32767.0


def dbfs(v):
    return 20.0 * np.log10(max(float(v), 1e-9))


def a_rms_db(x):
    """A-weighted RMS in dB re full scale: a rough guide to how loud a file will seem
    next to the others (peak and plain RMS say little about that)."""
    spec = np.fft.rfft(x)
    f2 = np.fft.rfftfreq(x.size, 1.0 / SR) ** 2
    ra = (12194.0 ** 2 * f2 * f2) / ((f2 + 20.6 ** 2) * np.sqrt((f2 + 107.7 ** 2) * (f2 + 737.9 ** 2)) * (f2 + 12194.0 ** 2) + 1e-30)
    p = 2.0 * np.sum(np.abs(spec * ra * 1.2589) ** 2) / (x.size ** 2)
    return 10.0 * np.log10(max(p, 1e-18))


def measure(x):
    peak = np.max(np.abs(x))
    rms = np.sqrt(np.mean(x * x))
    above = np.nonzero(np.abs(x) >= peak * 0.01)[0]
    onset_ms = 1000.0 * above[0] / SR
    tail_db = dbfs(np.max(np.abs(x[-10:])))
    return dict(len=x.size / SR, peak=dbfs(peak), rms=dbfs(rms), onset=onset_ms, tail=tail_db, a=a_rms_db(x))


def seam(x):
    """The loop point, from the written samples. jump = last sample to first; slope =
    the second difference across the seam. Each is ranked against every other place in
    the file (a seam that sits inside the file's own range is not a seam). level = the
    RMS of the 50 ms after the seam against the 50 ms before it, ranked against the
    same measure taken every 50 ms through the file."""
    d = np.abs(np.diff(x))
    d2 = np.abs(np.diff(x, 2))
    jump = abs(x[0] - x[-1])
    s2 = max(abs((x[0] - x[-1]) - (x[-1] - x[-2])), abs((x[1] - x[0]) - (x[0] - x[-1])))
    k = nsamp(0.05)
    c = np.concatenate([[0.0], np.cumsum(x * x)])
    at = np.arange(k, x.size - k, 64)  # every place inside the file, 1.5 ms apart
    steps = np.abs(10 * np.log10((c[at + k] - c[at] + 1e-12) / (c[at] - c[at - k] + 1e-12)))
    lvl = dbfs(np.sqrt(np.mean(x[:k] ** 2))) - dbfs(np.sqrt(np.mean(x[-k:] ** 2)))
    return dict(jump=jump, jump_pct=100.0 * np.mean(d <= jump), jump_max=d.max(),
                slope=s2, slope_pct=100.0 * np.mean(d2 <= s2), slope_max=d2.max(),
                level=lvl, level_pct=100.0 * np.mean(steps <= abs(lvl)), level_max=steps.max(),
                ok=bool(jump <= d.max() and s2 <= d2.max() and abs(lvl) <= max(steps.max(), 1.0)))


# --------------------------------------------------------------------------------------
# resonant bodies
# --------------------------------------------------------------------------------------

WOOD = [(230, 14, 1.0), (470, 16, 0.9), (880, 14, 0.6), (1550, 10, 0.3), (2500, 7, 0.1)]
ROPE = [(560, 9, 1.0), (1020, 10, 0.8), (1700, 8, 0.45), (2600, 6, 0.15)]
VINE = [(280, 12, 1.0), (560, 12, 0.8), (1080, 9, 0.4), (1900, 6, 0.12)]
IRON = [(900, 30, 1.0), (1420, 40, 0.7), (2150, 35, 0.5), (3100, 30, 0.3)]
CABLE = [(310, 30, 1.0), (620, 35, 0.8), (1240, 30, 0.5), (1900, 25, 0.2)]
ICE = [(110, 12, 0.8), (175, 14, 1.0), (290, 12, 0.9), (460, 10, 0.6), (700, 8, 0.25)]
STONE = [(140, 3, 1.0), (380, 4, 0.8), (900, 3, 0.5), (1700, 3, 0.25)]

D5, E5, FS5, A5, B5 = 587.33, 659.26, 739.99, 880.0, 987.77
D6, E6, FS6, A6, B6, D7 = 1174.66, 1318.51, 1479.98, 1760.0, 1975.53, 2349.32


def glass(f, dur, rng, tail=1.2):
    """A glassy bell: a free bar's partials (1, 2.76, 5.40), a faint octave, and a
    twin of the fundamental a hair sharp so the tail shimmers."""
    n = nsamp(dur)
    parts = [(f, 1.0, tail * 1.15), (f * 1.0016, 0.45, tail * 1.1, 1.0)]
    for r, a, d in [(2.0, 0.16, 0.6), (2.76, 0.30, 0.5), (5.40, 0.10, 0.22), (8.93, 0.03, 0.1)]:
        if f * r < 8500:
            parts.append((f * r, a * min(1.0, 1500.0 / f), tail * d, rng.uniform(0, TAU)))
    y = modal(n, parts)
    y += 0.06 * burst(n, rng, 2500, 7000, 0.003)
    return y * np.clip(tvec(n) / 0.0012, 0, 1)


# --------------------------------------------------------------------------------------
# the twelve ambience beds (12 s, periodic)
# --------------------------------------------------------------------------------------

BED = 12.0


def murmur(n, rng, voices=7):
    """A far crowd: voices as a pulse train of wandering pitch through two formants,
    each speaking in syllables and phrases."""
    out = np.zeros(n)
    for _ in range(voices):
        f0 = rng.uniform(105, 230) * (1.0 + 0.18 * (slow(n, rng, 1.2) - 0.5))
        ph = phase(f0, n, wrap=True)
        v = tone(ph, [1.0 / (k + 1) for k in range(16)]) + 0.5 * noise(n, rng, lo=300, hi=3000, tilt=-3.0)
        f1 = rng.uniform(380, 700)
        f2 = rng.uniform(950, 1500)
        v = resonate(v, [(f1, 4, 1.0), (f2, 5, 0.6), (2400, 6, 0.2)], wrap=True)
        out += unit(v) * slow(n, rng, rng.uniform(2.5, 4.5)) ** 2.5 * slow(n, rng, 0.4)
    return unit(out)


def amb_a0(rng):
    n = nsamp(BED)
    w, m = wind(n, rng, 350, 800, 500, 0.25, body=0.35, air=0.35, gust=0.6)
    y = st("breeze", unit(w))
    y = y + st("leaves", 0.22 * noise(n, rng, lo=2200, hi=6000, tilt=-3.0) * slow(n, rng, 0.5) ** 2 * 3.0)
    crowd = filt(murmur(n, rng), lo=250, hi=1400, order=2, wrap=True)
    crowd = unit(reverb(crowd, rng, 1.6, 1.2, hi=2500, wrap=True)) * slow(n, rng, 0.15, 0.45, 1.0)
    y = y + st("crowd", 0.8 * crowd)
    bird = np.zeros(n)
    for at, f0, f1, d in [(3.80, 2700, 3500, 0.07), (3.93, 3300, 2600, 0.08), (4.07, 2800, 3700, 0.06),
                          (9.30, 3000, 3600, 0.06), (9.42, 3400, 2700, 0.09)]:
        place(bird, chirp(f0, f1, d), at, 1.0, wrap=True)
    return y + st("bird", 0.55 * reverb(bird, rng, 0.8, 0.5, lo=1500, hi=5000, wrap=True))


def amb_a1(rng):
    n = nsamp(BED)
    y = np.zeros(n)
    for fc, bw, g in [(58, 9, 0.35), (92, 12, 0.8), (138, 14, 1.0), (207, 18, 0.8), (311, 30, 0.4)]:
        y += g * unit(sweep_noise(n, rng, fc, bw)) * slow(n, rng, 0.3, 0.4, 1.0)
    y += 0.2 * noise(n, rng, lo=45, hi=260, tilt=-4.0)
    y = st("drone", unit(y))
    y = y + st("air", 0.2 * noise(n, rng, lo=300, hi=1600, tilt=-4.0))
    ev = np.zeros(n)
    for at, f0, g in [(0.9, 900, 1.0), (3.45, 760, 0.7), (5.1, 1060, 0.85), (8.05, 820, 1.0), (10.3, 980, 0.6)]:
        place(ev, plink(f0, 0.3), at, g * 0.6, wrap=True)
    ev = echo(ev, 0.31, [0.45, 0.2, 0.09], wrap=True)
    place(ev, creak(1.0, rng, 20, 90, WOOD, bend=1.3), 2.2, 0.5, wrap=True)
    place(ev, creak(0.7, rng, 80, 22, WOOD), 7.1, 0.4, wrap=True)
    return y + st("drips+creaks", reverb(ev, rng, 2.6, 0.9, hi=3500, wrap=True))


def amb_a2(rng):
    n = nsamp(BED)
    y = noise(n, rng, lo=90, hi=5000, order=1, tilt=-3.5) * (0.85 + 0.15 * slow(n, rng, 0.6))
    y += 0.4 * noise(n, rng, lo=45, hi=200, tilt=-5.0)
    y += 0.35 * unit(sweep_noise(n, rng, 500 * 2.2 ** slow(n, rng, 0.7), 600)) * slow(n, rng, 0.9, 0.4, 1.0)
    y = st("roar", unit(y))
    ev = np.zeros(n)
    for _ in range(80):
        place(ev, bubble(rng.uniform(250, 900), rng.uniform(0.04, 0.11), rng.uniform(0.3, 1.0)),
              rng.uniform(0, BED), rng.uniform(0.25, 0.9), wrap=True)
    st("gurgles", ev.copy())
    for at, f0 in [(1.7, 870), (4.6, 1020), (7.9, 780), (10.6, 940)]:
        place(ev, plink(f0, 0.3), at, 0.55, wrap=True)
    return reverb(y + 1.5 * ev, rng, 1.8, 0.3, wrap=True)


def amb_a3(rng):
    n = nsamp(BED)
    t = tvec(n)
    y = st("room", 0.3 * noise(n, rng, lo=80, hi=450, tilt=-4.0))
    sh = np.zeros(n)
    for _ in range(26):
        f = np.round(rng.uniform(1800, 4800) * BED) / BED
        k = rng.integers(1, 6)
        a = (0.5 + 0.5 * np.sin(TAU * k * t / BED + rng.uniform(0, TAU))) ** 3
        sh += (1800.0 / f) * a * np.sin(TAU * f * t + rng.uniform(0, TAU))
    y = y + st("shimmer", 0.085 * unit(sh))
    y = y + st("air", 0.10 * noise(n, rng, lo=2500, hi=6500, tilt=-6.0) * slow(n, rng, 0.3, 0.3, 1.0))
    dr = np.zeros(n)
    for f, g in [(D5, 1.0), (A5, 0.6), (D5 * 1.5 * 1.002, 0.3), (D6, 0.35), (D5 / 2, 0.8)]:
        f = np.round(f * BED) / BED
        k = rng.integers(1, 4)
        dr += g * np.sin(TAU * f * t) * (0.55 + 0.45 * np.sin(TAU * k * t / BED + rng.uniform(0, TAU)))
    y = y + st("glass drone", 0.22 * unit(dr))
    ev = np.zeros(n)
    for at, f, g in [(1.1, A6, 0.8), (3.9, D7, 0.55), (6.2, FS6, 1.0), (8.4, B6, 0.6), (10.5, E6, 0.8)]:
        place(ev, glass(f, 1.6, rng, 1.4), at, g * 0.45, wrap=True)
    return y + st("pings", reverb(ev, rng, 3.2, 1.0, lo=500, hi=6000, wrap=True))


def amb_a4(rng):
    n = nsamp(BED)
    y = noise(n, rng, lo=85, hi=450, tilt=-4.0) + 0.5 * noise(n, rng, lo=300, hi=2500, tilt=-6.0)
    y = st("room", unit(y))
    fz = resonate(impulses(n, rng, 500 + 900 * slow(n, rng, 0.35)),
                  [(2600, 6, 1.0), (3600, 7, 0.8), (4800, 8, 0.45)], wrap=True)
    fz = unit(fz) + 0.6 * noise(n, rng, lo=2500, hi=6500, tilt=-4.0) * slow(n, rng, 0.4, 0.4, 1.0)
    y = y + st("fizz", 0.2 * unit(fz))
    ev = np.zeros(n)
    for at in [0.7, 2.9, 4.4, 6.9, 8.3, 10.9]:
        f0 = rng.uniform(300, 620)
        m = nsamp(0.14)
        tt = tvec(m)
        p = np.sin(phase(f0 * (1 + 0.9 * (tt / 0.14) ** 1.3))) * np.exp(-tt / 0.03) * np.clip(tt / 0.002, 0, 1)
        p += 0.2 * burst(m, rng, 1500, 4000, 0.012)
        place(ev, p, at + rng.uniform(-0.2, 0.2), rng.uniform(0.9, 1.5), wrap=True)
    for at, fc, rate, d in [(1.8, 3700, 52, 0.55), (5.6, 4100, 64, 0.38), (9.4, 3500, 47, 0.7)]:
        m = nsamp(d)
        tt = tvec(m)
        c = (np.sin(TAU * fc * tt) + 0.6 * np.sin(TAU * fc * 1.012 * tt))
        c *= (0.5 - 0.5 * np.cos(TAU * rate * tt)) ** 2 * np.sin(np.pi * tt / d)
        place(ev, c, at, 0.18, wrap=True)
    return y + st("plops+chirrs", reverb(ev, rng, 0.9, 0.4, hi=5000, wrap=True))


def amb_a5(rng):
    n = nsamp(BED)
    y = noise(n, rng, lo=50, hi=280, tilt=-3.0)
    y += 0.4 * unit(sweep_noise(n, rng, 62, 8)) * slow(n, rng, 0.25, 0.4, 1.0)
    y += 0.6 * unit(sweep_noise(n, rng, 98, 10)) * slow(n, rng, 0.3, 0.3, 1.0)
    y += 0.4 * unit(sweep_noise(n, rng, 163, 14)) * slow(n, rng, 0.3, 0.3, 1.0)
    y = st("room", unit(y))
    y = y + st("air", 0.12 * noise(n, rng, lo=200, hi=1500, tilt=-5.0))
    y = y + 0.42 * unit(reverb(fire(n, rng, 10.0, crack=0.6), rng, 1.2, 0.35, wrap=True))
    ev = np.zeros(n)
    for at, g in [(1.2, 1.0), (7.2, 0.85)]:
        m = nsamp(1.6)
        d = thump(m, 96, 64, 0.05, 0.3, attack=0.025) + 0.6 * thump(m, 150, 101, 0.04, 0.2, attack=0.025)
        place(ev, d, at, g * 0.4, wrap=True)
    ev = filt(ev, hi=320, wrap=True)
    return y + st("far drum", reverb(ev, rng, 3.0, 1.2, lo=50, hi=500, wrap=True))


def amb_a6(rng):
    n = nsamp(BED)
    y = st("hiss", 0.45 * noise(n, rng, lo=1400, hi=6000, order=1, tilt=-3.0) * slow(n, rng, 0.4, 0.6, 1.0))
    y = y + st("jet", 0.08 * unit(sweep_noise(n, rng, 1300 * 1.25 ** slow(n, rng, 0.3), 500)))
    y = y + st("rumble", 0.6 * noise(n, rng, lo=40, hi=160, tilt=-4.0) * slow(n, rng, 0.8, 0.7, 1.0))
    y = y + st("sputter", 0.4 * noise(n, rng, lo=120, hi=700, tilt=-3.0) * slow(n, rng, 12.0) ** 2 * 2.5)
    ev = np.zeros(n)
    at = 0.3
    while at < BED - 0.1:
        s = rng.uniform(0.8, 1.25)
        m = nsamp(0.25)
        tk = modal(m, [(1700 * s, 1.0, rng.uniform(0.03, 0.08)), (2700 * s, 0.6, 0.04), (3900 * s, 0.3, 0.025)])
        tk += 0.5 * burst(m, rng, 1800, 5500, 0.0015)
        g = rng.uniform(0.4, 1.0)
        place(ev, tk, at, g, wrap=True)
        if rng.random() < 0.3:
            place(ev, tk, at + rng.uniform(0.07, 0.14), g * 0.5, wrap=True)
        at += rng.uniform(0.35, 1.5)
    return y + st("ticks", 1.7 * reverb(ev, rng, 0.6, 0.4, lo=800, wrap=True))


def bird_of_prey(rng, dur=0.9, f_hi=2250.0, f_lo=1600.0):
    n = nsamp(dur)
    t = tvec(n)
    u = t / dur
    f = f_lo + (f_hi - f_lo) * (1 - u) ** 1.4 * (1.0 + 0.06 * np.exp(-t / 0.05))
    y = tone(phase(f), [1.0, 0.5, 0.25, 0.1])
    y *= 1.0 + 0.3 * np.sin(TAU * 34 * t)
    return y * np.clip(t / 0.05, 0, 1) * np.clip((1 - u) / 0.5, 0, 1) ** 1.3


def amb_a7(rng):
    n = nsamp(BED)
    w, m = wind(n, rng, 250, 700, 400, 0.22, body=0.6, air=0.35, gust=0.8)
    y = st("wind", unit(w))
    y = y + st("whistle", 0.4 * unit(sweep_noise(n, rng, 700 * 1.8 ** m, 250)) * m ** 2)
    ev = np.zeros(n)
    place(ev, bird_of_prey(rng), 6.5, 1.0, wrap=True)
    ev = filt(ev, lo=900, hi=3200, wrap=True)
    ev = echo(ev, 0.37, [0.3, 0.1], hi=2500, wrap=True)
    return y + st("bird", 0.26 * reverb(ev, rng, 1.5, 0.6, lo=800, hi=3500, wrap=True))


def amb_a8(rng):
    n = nsamp(BED)
    t = tvec(n)
    w, m = wind(n, rng, 300, 650, 350, 0.25, body=0.5, air=0.25, gust=0.6)
    y = st("wind", 0.75 * unit(w))
    hum = np.zeros(n)
    # 55 Hz and its harmonics: mains-like, and an A, the fifth of the climb's D
    for k, a in [(1, 0.4), (2, 1.0), (3, 0.5), (4, 0.7), (5, 0.25), (6, 0.4), (8, 0.2), (10, 0.1), (12, 0.05)]:
        hum += a * np.sin(TAU * 55.0 * k * t + rng.uniform(0, TAU))
    y = y + st("hum", 0.8 * unit(hum) * slow(n, rng, 0.3, 0.8, 1.0))
    y = y + st("cable sing", 0.3 * unit(sweep_noise(n, rng, 480 * (1 + 0.03 * m), 15, order=2)) * m ** 2)
    ev = np.zeros(n)
    place(ev, creak(1.1, rng, 30, 105, CABLE), 2.8, 1.0, wrap=True)
    place(ev, creak(0.7, rng, 90, 40, CABLE), 8.6, 0.75, wrap=True)
    return y + st("creaks", reverb(ev, rng, 0.8, 0.3, wrap=True))


def ice_groan(rng, dur, r0, r1, f0, f1):
    n = nsamp(dur)
    u = np.arange(n) / n
    g = creak(dur, rng, r0, r1, ICE, jitter=0.15, gap=0.08)
    s = np.sin(phase(f0 * (f1 / f0) ** u)) * np.sin(np.pi * u) ** 1.5
    return g + 0.5 * s


def amb_a9(rng):
    n = nsamp(BED)
    w, m = wind(n, rng, 800, 1700, 350, 0.3, body=0.15, air=0.5, gust=0.75)
    y = st("wind", unit(w))
    y = y + st("spindrift", 0.25 * noise(n, rng, lo=2500, hi=7000, tilt=-3.0) * m ** 2 * 2.0)
    y = y + st("cold floor", 0.5 * noise(n, rng, lo=40, hi=200, tilt=-4.0) * slow(n, rng, 0.3, 0.5, 1.0))
    ev = np.zeros(n)
    place(ev, ice_groan(rng, 1.8, 10, 34, 82, 64), 1.5, 0.6, wrap=True)
    place(ev, ice_groan(rng, 1.3, 30, 12, 70, 88), 8.2, 0.5, wrap=True)
    for at, g in [(0.6, 0.8), (4.7, 1.0), (6.4, 0.6), (10.8, 0.9)]:
        m2 = nsamp(0.2)
        tt = tvec(m2)
        c = burst(m2, rng, 1500, 5500, 0.008)
        c += 0.25 * np.sin(phase(700 + 1500 * np.exp(-tt / 0.012))) * np.exp(-tt / 0.02)
        place(ev, c, at, g * 0.8, wrap=True)
    ev = echo(ev, 0.18, [0.3, 0.1], wrap=True)
    return y + st("groans+cracks", reverb(ev, rng, 2.4, 0.7, lo=40, hi=4000, wrap=True))


def amb_a10(rng):
    n = nsamp(BED)
    w, m = wind(n, rng, 220, 1100, 500, 0.45, body=0.8, air=0.6, gust=1.0)
    y = st("wind", unit(w))
    y = y + st("howl", 0.7 * unit(sweep_noise(n, rng, 400 * 2.25 ** m, 60, order=2)) * m ** 3)
    mr = slow(n, rng, 0.5)
    rain = noise(n, rng, lo=1600, hi=7500, order=1, tilt=-2.5) * (0.6 + 0.4 * mr)
    drops = unit(filt(impulses(n, rng, 700.0), lo=1500, hi=5500, wrap=True)) * (0.5 + 0.5 * mr)
    y = y + st("rain", 0.3 * rain + 0.22 * drops)
    ev = np.zeros(n)
    roll = thunder_roll(5.5, rng, crack=0.0, bumps=7, lp=200.0)
    roll *= np.clip(tvec(roll.size) / 0.7, 0, 1) ** 1.5
    place(ev, roll, 4.6, 1.0, wrap=True)
    return y + st("thunder", 0.45 * unit(ev))


def amb_a11(rng):
    n = nsamp(BED)
    w, m = wind(n, rng, 600, 1300, 300, 0.2, body=0.2, air=0.4, gust=0.5)
    y = st("wind", unit(w))
    return y + st("cloth", 0.4 * unit(flag(n, rng, 8.0, strength=0.25 + 0.75 * m ** 1.5)))


# --------------------------------------------------------------------------------------
# the other loops (2 to 4 s, periodic)
# --------------------------------------------------------------------------------------

def cart_roll_loop(rng):
    n = nsamp(3.0)
    t = tvec(n)
    wheel = 0.5 + 0.35 * np.sin(TAU * 5 * t) + 0.15 * np.sin(TAU * 10 * t + 1.0)
    y = st("rumble", noise(n, rng, lo=50, hi=400, tilt=-3.0) * (0.75 + 0.25 * wheel))
    y = y + st("iron", 0.3 * unit(resonate(noise(n, rng, lo=300, hi=5000), IRON, wrap=True)) * slow(n, rng, 2.0, 0.6, 1.0))
    y = y + st("grit", 0.5 * noise(n, rng, lo=600, hi=4000, tilt=-3.0) * slow(n, rng, 20.0) ** 2)
    ev = np.zeros(n)
    for k in range(15):  # a flat on the wheel, five to the second
        m = nsamp(0.08)
        tk = 0.8 * thump(m, 190, 130, 0.01, 0.018) + 0.5 * burst(m, rng, 900, 3500, 0.004)
        place(ev, tk, k / 5.0 + 0.03, rng.uniform(0.7, 1.0), wrap=True)
    return y + st("flat", 1.6 * ev)


def waterfall_loop(rng):
    n = nsamp(4.0)
    y = st("fall", noise(n, rng, lo=60, hi=6500, order=1, tilt=-3.0))
    y = y + st("sub", 0.5 * noise(n, rng, lo=35, hi=160, tilt=-5.0))
    y = y + st("churn", 0.4 * noise(n, rng, lo=300, hi=2500) * slow(n, rng, 6.0, 0.6, 1.0))
    return y + st("spray", 0.15 * noise(n, rng, lo=2500, hi=7500, tilt=-3.0) * slow(n, rng, 2.0, 0.7, 1.0))


def river_loop(rng):
    n = nsamp(4.0)
    y = noise(n, rng, lo=250, hi=5500, order=1, tilt=-4.0) * slow(n, rng, 3.0, 0.7, 1.0)
    y += 0.4 * unit(sweep_noise(n, rng, 700 * 2.3 ** slow(n, rng, 2.5), 500)) * slow(n, rng, 2.0, 0.4, 1.0)
    y = st("water", unit(y))
    ev = np.zeros(n)
    for _ in range(110):
        place(ev, bubble(rng.uniform(300, 1400), rng.uniform(0.025, 0.07), rng.uniform(0.3, 1.0)),
              rng.uniform(0, 4.0), rng.uniform(0.2, 0.8), wrap=True)
    return y + st("bubbles", 1.6 * ev)


def wheel_creak_loop(rng):
    n = nsamp(4.0)
    t = tvec(n)
    big = [(190, 14, 1.0), (370, 16, 0.9), (720, 14, 0.6), (1300, 10, 0.3), (2100, 7, 0.1)]
    y = st("axle", 0.3 * noise(n, rng, lo=70, hi=350, tilt=-3.0) * (0.8 + 0.2 * np.sin(TAU * 0.5 * t)))
    ev = np.zeros(n)
    place(ev, creak(1.5, rng, 24, 110, big, bend=0.7), 0.15, 0.8, wrap=True)
    place(ev, creak(1.0, rng, 100, 28, big), 2.3, 0.65, wrap=True)
    st("creaks", ev.copy())
    for k in range(4):
        m = nsamp(0.3)
        kn = modal(m, [(240, 1.0, 0.09), (610, 0.5, 0.06), (1180, 0.2, 0.04)]) + 0.3 * burst(m, rng, 400, 2000, 0.006)
        place(ev, kn, k + 0.02 + rng.uniform(0, 0.03), rng.uniform(0.7, 1.1), wrap=True)
    return y + reverb(ev, rng, 0.5, 0.2, wrap=True)


def gondola_hum_loop(rng):
    n = nsamp(3.0)
    t = tvec(n)
    f0 = 220.0 / 3.0  # D2 less two cents: 220 whole cycles in the loop
    y = np.zeros(n)
    for k, a in [(1, 0.8), (2, 0.9), (3, 0.45), (4, 0.6), (5, 0.2), (6, 0.3), (7, 0.1), (8, 0.18), (12, 0.06)]:
        y += a * np.sin(TAU * f0 * k * t + rng.uniform(0, TAU))
    y = st("motor", unit(y) * (0.9 + 0.1 * np.sin(TAU * 2 * t)))
    sheave = 0.5 - 0.5 * np.cos(TAU * 7 * t)
    y = y + st("cable", 0.35 * noise(n, rng, lo=300, hi=1500, tilt=-3.0) * (0.55 + 0.45 * sheave ** 2))
    ev = np.zeros(n)
    for k in range(21):
        m = nsamp(0.05)
        place(ev, burst(m, rng, 700, 2600, 0.004) + 0.5 * thump(m, 260, 200, 0.01, 0.012), k / 7.0, 0.8, wrap=True)
    return y + st("ticks", ev) + 0.12 * noise(n, rng, lo=45, hi=150, tilt=-5.0)


def fall_wind_loop(rng):
    n = nsamp(3.0)
    y = noise(n, rng, lo=180, hi=2600, order=1, tilt=-3.0) * slow(n, rng, 5.0, 0.85, 1.0)
    y += 0.5 * unit(sweep_noise(n, rng, 600 * (1 + 0.16 * (slow(n, rng, 1.5) - 0.5)), 500))
    y += 0.3 * noise(n, rng, lo=50, hi=200, tilt=-3.0) * slow(n, rng, 9.0, 0.3, 1.0)
    return y


def steam_loop(rng):
    n = nsamp(3.0)
    y = st("hiss", noise(n, rng, lo=1200, hi=6000, order=1, tilt=-3.0) * slow(n, rng, 4.0, 0.75, 1.0))
    y = y + st("sputter", 1.0 * noise(n, rng, lo=150, hi=900, tilt=-3.0) * slow(n, rng, 14.0) ** 3 * 2.0)
    return y + st("sub", 0.3 * noise(n, rng, lo=45, hi=160, tilt=-5.0))


def torch_loop(rng):
    return fire(nsamp(3.0), rng, 14.0)


def stone_grind_loop(rng):
    n = nsamp(3.0)
    rough = slow(n, rng, 10.0) ** 2
    g = unit(resonate(impulses(n, rng, 1500.0, heavy=1.0) * (0.3 + rough), STONE, wrap=True))
    y = st("grind", 2.0 * np.tanh(g / 2.0))
    y = y + st("rumble", 0.6 * noise(n, rng, lo=40, hi=200, tilt=-5.0) * slow(n, rng, 3.0, 0.6, 1.0))
    return y + st("grit", 0.9 * noise(n, rng, lo=800, hi=3500, tilt=-5.0) * slow(n, rng, 25.0) ** 2)


def flag_flutter_loop(rng):
    n = nsamp(2.5)
    return flag(n, rng, 9.5, strength=slow(n, rng, 1.2, 0.6, 1.0))


def boulder_roll_loop(rng):
    n = nsamp(3.0)
    hits = [0.05, 0.47, 0.95, 1.33, 1.82, 2.2, 2.66]
    env = np.zeros(n)
    ev = np.zeros(n)
    for at in hits:
        m = nsamp(0.5)
        tt = tvec(m)
        g = rng.uniform(0.6, 1.0)
        th = thump(m, rng.uniform(130, 170), rng.uniform(62, 80), 0.02, 0.09)
        th += 0.9 * burst(m, rng, 250, 1800, 0.03) + 0.3 * burst(m, rng, 1200, 4000, 0.008)
        place(ev, th, at, g, wrap=True)
        place(env, np.exp(-tt / 0.15), at, g, wrap=True)
    y = st("rumble", unit(noise(n, rng, lo=45, hi=260, tilt=-3.0) * (0.6 + 0.4 * env)))
    crunch = unit(filt(impulses(n, rng, 900.0, heavy=1.0), lo=500, hi=3000, wrap=True)) * (0.25 + env)
    return y + st("thumps", 2.0 * ev) + st("crunch", 0.25 * crunch)


def avalanche_loop(rng):
    n = nsamp(4.0)
    y = st("rumble", noise(n, rng, lo=30, hi=280, order=1, tilt=-4.0) * slow(n, rng, 1.2, 0.75, 1.0))
    y = y + st("snow", 0.7 * noise(n, rng, lo=400, hi=4500, order=1, tilt=-4.5) * slow(n, rng, 0.9, 0.6, 1.0))
    y = y + st("churn", 0.45 * unit(sweep_noise(n, rng, 150 * 2.6 ** slow(n, rng, 1.0), 200)) * slow(n, rng, 1.5, 0.4, 1.0))
    ev = np.zeros(n)
    for _ in range(9):
        m = nsamp(0.6)
        place(ev, thump(m, rng.uniform(100, 130), rng.uniform(50, 70), 0.03, 0.14, attack=0.004),
              rng.uniform(0, 4.0), rng.uniform(0.8, 1.6), wrap=True)
    return y + st("thumps", ev)


# --------------------------------------------------------------------------------------
# one-shots
# --------------------------------------------------------------------------------------

def cart_start(rng):
    n = nsamp(1.5)
    t = tvec(n)
    y = impact(n, rng, f_low=95, t_low=0.06, low=0.8, nlo=250, nhi=2200, t_noise=0.02, nz=0.8,
               ring=[(640, 0.35, 0.12), (1010, 0.25, 0.09), (1730, 0.15, 0.06)])
    place(y, creak(0.45, rng, 28, 90, WOOD), 0.03, 0.3)
    up = np.clip(t / 1.1, 0, 1) ** 1.6
    roll = noise(n, rng, lo=50, hi=420, tilt=-3.0) + 0.3 * unit(resonate(noise(n, rng, lo=300, hi=5000), IRON))
    y += 0.42 * roll * up * (1.0 + 0.3 * np.sin(phase(1.0 + 6.0 * up)))
    at = 0.25
    gapk = 0.3
    while at < 1.45:  # the wheel's flat, coming quicker
        m = nsamp(0.08)
        place(y, 0.8 * thump(m, 190, 130, 0.01, 0.018) + 0.5 * burst(m, rng, 900, 3500, 0.004), at, 0.3)
        at += gapk
        gapk = max(0.11, gapk * 0.82)
    return y * np.clip((1.5 - t) / 0.3, 0, 1)


def cart_clack(rng, v):
    n = nsamp([0.32, 0.36, 0.3][v])
    s = [1.0, 0.86, 1.17][v]
    gap = [0.055, 0.075, 0.042][v]
    y = np.zeros(n)
    for at, g in [(0.0, 1.0), (gap, 0.75)]:
        m = nsamp(0.25)
        c = impact(m, rng, f_low=130 * s, t_low=0.02, low=0.6, nlo=700, nhi=4000, t_noise=0.006, nz=0.9,
                   ring=[(1100 * s, 0.7, 0.09), (1900 * s, 0.5, 0.07), (2750 * s, 0.28, 0.05)])
        place(y, c, at, g)
    return y


def cart_brake(rng):
    n = nsamp(1.4)
    t = tvec(n)
    u = t / 1.4
    f = 1450.0 * (680.0 / 1450.0) ** (u ** 0.8) * (1.0 + 0.02 * np.sin(TAU * 11 * t))
    y = squeal(n, f, rng, rough=0.3, harm=(1.0, 0.4, 0.15, 0.05))
    y = 0.7 * filt(y, lo=400, hi=4200)
    y += 0.5 * noise(n, rng, lo=300, hi=3000, tilt=-3.0) * (1 - u) ** 0.5
    y += 0.5 * noise(n, rng, lo=50, hi=300, tilt=-3.0) * (1 - u)
    place(y, impact(nsamp(0.2), rng, f_low=110, nz=0.5), 0.0, 1.2)
    return y * np.clip(t / 0.004, 0, 1) * (0.25 + 0.75 * (1 - u) ** 0.7) * np.clip((1 - u) / 0.12, 0, 1)


def cart_crash(rng):
    n = nsamp(1.7)
    y = impact(n, rng, f_low=82, drop=2.0, t_low=0.1, low=0.9, nlo=150, nhi=3500, t_noise=0.05, nz=1.1,
               ring=[(410, 0.4, 0.5), (730, 0.35, 0.4), (1190, 0.25, 0.3), (1870, 0.18, 0.22), (2600, 0.1, 0.15)])
    for _ in range(9):  # timber letting go
        at = rng.uniform(0.01, 0.35)
        place(y, burst(nsamp(0.15), rng, 500, 5000, rng.uniform(0.004, 0.012)), at, rng.uniform(0.3, 0.8))
        place(y, modal(nsamp(0.15), [(rng.uniform(300, 900), 1.0, 0.07)]), at, 0.25)
    for at in scatter(rng, 14, 0.3, 1.3):  # what was in the cart
        at += 0.15
        s = rng.uniform(0.7, 1.4)
        c = impact(nsamp(0.2), rng, f_low=150 * s, t_low=0.02, nlo=600, nhi=3500, t_noise=0.008,
                   ring=[(900 * s, 0.4, 0.08), (1700 * s, 0.25, 0.06)])
        place(y, c, at, rng.uniform(0.15, 0.5) * np.exp(-at * 1.5))
    return reverb(y, rng, 0.9, 0.25)


def lever_clunk(rng):
    n = nsamp(0.38)
    y = 0.5 * burst(n, rng, 1800, 6000, 0.0025)
    y += impact(n, rng, f_low=140, t_low=0.03, low=0.8, nlo=300, nhi=1800, t_noise=0.012, nz=0.7,
                ring=[(780, 0.4, 0.08), (1260, 0.25, 0.05)])
    m = nsamp(0.2)
    place(y, impact(m, rng, f_low=175, t_low=0.02, nlo=800, nhi=3500, t_noise=0.005, nz=0.6,
                    ring=[(1480, 0.3, 0.06), (2300, 0.15, 0.04)]), 0.085, 0.6)
    return y


def plank_creak(rng, v):
    dur = [0.6, 0.85, 0.7][v]
    r0, r1 = [(35, 210), (26, 150), (44, 260)][v]
    s = [1.0, 0.85, 1.2][v]
    return creak(dur, rng, r0, r1, [(f * s, q, g) for f, q, g in WOOD], bend=1.2)


def plank_snap(rng, v):
    n = nsamp([0.55, 0.6, 0.5][v])
    s = [1.0, 0.82, 1.22][v]
    y = 1.2 * burst(n, rng, 500, 6000, 0.006)
    y += 0.5 * thump(n, 260 * s, 95 * s, 0.012, 0.04)
    y += modal(n, [(230 * s, 0.5, 0.12), (470 * s, 0.5, 0.09), (910 * s, 0.4, 0.06), (1650 * s, 0.2, 0.04)])
    for _ in range([6, 8, 5][v]):  # the splinters
        at = rng.uniform(0.012, 0.2)
        place(y, burst(nsamp(0.1), rng, 900, 6000, rng.uniform(0.002, 0.006)), at, rng.uniform(0.2, 0.55) * np.exp(-at * 6))
    place(y, modal(nsamp(0.2), [(620 * s, 1.0, 0.07), (1340 * s, 0.5, 0.05)]), [0.19, 0.24, 0.16][v], 0.2)
    return y


def rock_hit(rng, v):
    n = nsamp([0.35, 0.3, 0.42][v])
    f = [95, 120, 80][v]
    s = [1.0, 1.25, 0.8][v]
    return impact(n, rng, f_low=f, t_low=[0.045, 0.035, 0.06][v], low=0.8, nlo=500, nhi=3000, t_noise=0.014, nz=1.0,
                  ring=[(820 * s, 0.5, 0.05), (1340 * s, 0.35, 0.04), (2050 * s, 0.2, 0.03)])


def rock_crumble(rng, v):
    dur = [0.95, 1.25, 1.55][v]
    n = nsamp(dur)
    t = tvec(n)
    y = np.zeros(n)
    place(y, impact(nsamp(0.3), rng, f_low=[100, 88, 78][v], nlo=400, nhi=2800, nz=0.9), 0.0, 1.0)
    for at in scatter(rng, [45, 70, 100][v], dur * 0.3, dur - 0.15):
        fc = rng.uniform(380, 2400) * [1.0, 0.9, 0.8][v]
        m = nsamp(0.12)
        g = burst(m, rng, fc * 0.6, fc * 1.6, rng.uniform(0.004, 0.015))
        if rng.random() < 0.3:
            g += 0.8 * thump(m, fc * 0.3, fc * 0.15, 0.01, 0.03)
        place(y, g, at, rng.uniform(0.15, 0.7) * np.exp(-at / (dur * 0.5)))
    y += 0.3 * noise(n, rng, lo=50, hi=300, tilt=-4.0) * np.exp(-t / (dur * 0.3))
    return y


def dust_trickle(rng, v):
    dur = [1.3, 1.7][v]
    n = nsamp(dur)
    t = tvec(n)
    u = t / dur
    env = (0.35 + 0.65 * np.sin(np.pi * np.clip(u / 0.7, 0, 1)) ** 2) * np.clip((1 - u) / 0.45, 0, 1)
    y = unit(filt(impulses(n, rng, [3200.0, 2200.0][v]), lo=[1500, 1200][v], hi=5000, tilt=-3.0)) * env
    y += 0.5 * noise(n, rng, lo=900, hi=4500, tilt=-4.0) * env * slow(n, rng, 6.0, 0.4, 1.0)
    for _ in range([6, 10][v]):
        fc = rng.uniform(900, 2600)
        place(y, burst(nsamp(0.08), rng, fc * 0.6, fc * 1.6, rng.uniform(0.003, 0.008)),
              rng.uniform(0.0, dur * 0.8), rng.uniform(1.0, 2.5))
    return y


def rope_creak(rng, v):
    dur = [0.7, 0.9, 0.55][v]
    r0, r1 = [(34, 110), (27, 85), (45, 140)][v]
    s = [1.0, 0.88, 1.15][v]
    y = creak(dur, rng, r0, r1, [(f * s, q, g) for f, q, g in ROPE], jitter=0.12, bend=0.9)
    return y + 0.08 * noise(y.size, rng, lo=1200, hi=4000, tilt=-3.0) * np.abs(y) * 3.0


def chain_rattle(rng, v):
    dur = [0.7, 0.95, 0.6][v]
    n = nsamp(dur)
    y = np.zeros(n)
    s = [1.0, 0.85, 1.1][v]
    for at in scatter(rng, [10, 16, 8][v], dur * 0.25, dur - 0.2):
        f = rng.uniform(1100, 2400) * s
        d = rng.uniform(0.05, 0.12)
        m = nsamp(0.3)
        c = modal(m, [(f, 1.0, d), (f * 1.47, 0.6, d * 0.8), (f * 2.09, 0.3, d * 0.6), (f * 2.83, 0.1, d * 0.4)])
        c += 0.4 * burst(m, rng, 1500, 6000, 0.002) + 0.2 * thump(m, 330, 240, 0.01, 0.01)
        place(y, c, at, rng.uniform(0.35, 1.0) * np.exp(-at / (dur * 0.6)))
    return filt(y, hi=7000)


def gate_slam(rng, v):
    n = nsamp([1.1, 1.25][v])
    f = [62, 54][v]
    y = 0.8 * thump(n, f * 2.2, f, 0.02, [0.12, 0.15][v])
    y += 1.3 * burst(n, rng, 150, 1400, 0.04) + 0.8 * burst(n, rng, 800, 4000, 0.008)
    y += modal(n, [(196 * [1, 0.9][v], 0.5, 0.3), (333 * [1, 0.9][v], 0.45, 0.22), (540, 0.3, 0.15), (870, 0.15, 0.1)])
    for _ in range(4):
        fr = rng.uniform(900, 1800)
        place(y, modal(nsamp(0.2), [(fr, 1.0, 0.08), (fr * 1.5, 0.5, 0.05)]), rng.uniform(0.03, 0.22), rng.uniform(0.08, 0.2))
    return reverb(np.tanh(1.3 * y), rng, 0.9, 0.3, hi=3500)


def water_paddle(rng, v):
    dur = [0.55, 0.7, 0.5][v]
    n = nsamp(dur)
    t = tvec(n)
    u = t / dur
    hump = np.sin(np.pi * np.clip(u / 0.75, 0, 1)) ** 1.5
    c0, c1 = [(500, 1400), (420, 1150), (600, 1700)][v]
    sw = unit(sweep_noise(n, rng, c0 * (c1 / c0) ** hump, 900, wrap=False)) * (0.15 + 0.85 * hump)
    sw += 0.4 * noise(n, rng, lo=150, hi=700, tilt=-3.0) * hump
    y = sw * 0.45
    place(y, bubble([520, 430, 640][v], 0.07, 0.8), 0.0, 0.9)
    place(y, burst(nsamp(0.08), rng, 1000, 4000, 0.01), 0.0, 0.4)
    for _ in range([14, 20, 11][v]):
        place(y, bubble(rng.uniform(300, 1100), rng.uniform(0.03, 0.08), rng.uniform(0.4, 1.0)),
              rng.uniform(0.04, dur * 0.75), rng.uniform(0.2, 0.6))
    return filt(y, hi=6000) * np.clip((1 - u) / 0.3, 0, 1)


def drip(rng, v):
    n = nsamp([0.32, 0.38, 0.28][v])
    f0 = [900, 720, 1100][v]
    y = np.zeros(n)
    place(y, plink(f0, 0.2, rise=[0.9, 0.7, 1.1][v], tau=[0.03, 0.04, 0.024][v]), 0.0, 1.0)
    y += 0.12 * burst(n, rng, 1500, 5000, 0.004)
    return echo(y, [0.09, 0.11, 0.08][v], [0.2, 0.07], hi=2500)


def crystal_chime(rng, v):
    f = [D5, E5, FS5, A5, B5, D6, E6, FS6][v]
    return glass(f, 1.35, rng, 1.2)


def crystal_shatter(rng, v):
    dur = [0.9, 1.1, 0.8][v]
    n = nsamp(dur)
    s = [1.0, 0.85, 1.2][v]
    y = 0.8 * burst(n, rng, 1500, 7000, 0.03) + 0.7 * burst(n, rng, 300, 2500, 0.04)
    for at in scatter(rng, [30, 40, 24][v], 0.2, dur - 0.3):
        f = rng.uniform(1200, 4200) * s
        m = nsamp(0.4)
        p = modal(m, [(f, 1.0, rng.uniform(0.08, 0.32)), (f * 2.76, 0.2, 0.06)]) * np.clip(tvec(m) / 0.001, 0, 1)
        place(y, p, at, rng.uniform(0.12, 0.5) * np.exp(-at * 1.5))
    return filt(y, hi=7500)


def mushroom_boing(rng, v):
    f0 = [98.0, 146.83, 220.0][v]
    dur = [0.6, 0.52, 0.45][v]
    wob = [9.0, 11.0, 13.5][v]
    n = nsamp(dur)
    t = tvec(n)
    f = f0 * (1 + 0.6 * np.exp(-t / 0.02)) * (1 + 0.13 * np.sin(TAU * wob * t) * np.exp(-t * 4.5))
    f *= 1 + 0.22 * (t / dur) ** 2
    ph = phase(f)
    y = (np.sin(ph) + 0.6 * np.sin(2 * ph + 0.3) + 0.3 * np.sin(3 * ph + 1.1) + 0.12 * np.sin(4 * ph + 0.5))
    y *= np.clip(t / 0.004, 0, 1) * np.exp(-t * [5.0, 6.0, 7.0][v])
    y += 0.7 * thump(n, 120, 70, 0.02, 0.035) + 0.35 * burst(n, rng, 150, 900, 0.02)
    return np.tanh(1.3 * y)


def spore_puff(rng, v):
    dur = [0.5, 0.68][v]
    n = nsamp(dur)
    t = tvec(n)
    fc = [500, 380][v] + [1900, 1500][v] * np.exp(-t / [0.07, 0.1][v])
    y = unit(sweep_noise(n, rng, fc, 1400, wrap=False)) * np.clip(t / 0.004, 0, 1) * np.exp(-t / [0.09, 0.13][v])
    y += 0.9 * thump(n, 130, 72, 0.02, 0.04, attack=0.002)
    y += 0.2 * unit(filt(impulses(n, rng, 900.0), lo=2500, hi=6000)) * np.exp(-t / 0.2)
    return y


def puffball_pop(rng, v):
    n = nsamp([0.26, 0.3][v])
    t = tvec(n)
    f0, f1 = [(650, 180), (840, 240)][v]
    y = thump(n, f0, f1, 0.02, 0.035, attack=0.0005)
    y += 0.4 * burst(n, rng, 600, 3500, 0.012)
    y += 0.3 * noise(n, rng, lo=500, hi=2500, tilt=-3.0) * np.sin(np.pi * np.clip((t - 0.02) / 0.16, 0, 1)) ** 2 * 0.5
    return y


def vine_creak(rng, v):
    dur = [0.8, 0.6][v]
    r0, r1 = [(22, 80), (30, 100)][v]
    y = creak(dur, rng, r0, r1, [(f * [1.0, 1.2][v], q, g) for f, q, g in VINE], jitter=0.1)
    n = y.size
    u = np.arange(n) / n
    sq = squeal(n, [480, 600][v] * (1 + 0.3 * u), rng, rough=0.3, harm=(1.0, 0.3, 0.1))
    return y + 0.1 * sq * np.sin(np.pi * u) ** 2


def stone_slam(rng, v):
    n = nsamp([1.3, 1.5][v])
    t = tvec(n)
    f = [55, 47][v]
    y = 0.7 * thump(n, f * 2.4, f, 0.025, [0.13, 0.17][v])
    y += 1.4 * burst(n, rng, 300, 3000, 0.014) + 1.4 * burst(n, rng, 120, 900, 0.05)
    grit = resonate(impulses(n, rng, 500.0 * np.exp(-t / 0.2)), [(f0 * [1, 0.85][v], q, g) for f0, q, g in STONE])
    y += 0.6 * pk(grit)
    return reverb(np.tanh(1.3 * y), rng, 1.6, 0.35, hi=3500)


def stone_drum(rng, v):
    n = nsamp([1.6, 1.8][v])
    t = tvec(n)
    f0 = [73.42, 55.0][v]  # D2 and A1
    bend = 1 + 0.12 * np.exp(-t / 0.03)
    ph = phase(f0 * bend)
    y = np.zeros(n)
    for r, a, d in [(1.0, 1.0, 0.8), (1.59, 0.8, 0.5), (2.14, 0.6, 0.38), (2.30, 0.5, 0.33), (2.65, 0.38, 0.28), (2.92, 0.3, 0.24), (3.6, 0.24, 0.18), (4.1, 0.18, 0.15)]:
        y += a * np.sin(r * ph + rng.uniform(0, 0.5)) * np.exp(-6.908 * t / (d * [1.0, 1.2][v]))
    y *= np.clip(t / 0.002, 0, 1)
    y = np.tanh(2.0 * y)  # a little skin: harmonics a small speaker can find
    y += 1.3 * burst(n, rng, 120, 1200, 0.022) + 0.35 * burst(n, rng, 800, 3000, 0.004)
    return reverb(y, rng, 1.4, 0.25, lo=200, hi=2500)


def steam_hiss(rng, v):
    dur = [0.8, 1.3][v]
    n = nsamp(dur)
    t = tvec(n)
    env = np.clip(t / 0.004, 0, 1) * np.exp(-t / [0.22, 0.42][v])
    y = noise(n, rng, lo=1200, hi=6000, order=1, tilt=-3.0) * env
    y += 0.25 * unit(sweep_noise(n, rng, 1300 + 700 * np.exp(-t / 0.3), 300, wrap=False)) * env
    y += 0.5 * burst(n, rng, 150, 700, 0.05)
    return y


def geyser_warn(rng):
    n = nsamp(1.0)
    t = tvec(n)
    y = np.zeros(n)
    at = 0.0
    while at < 0.97:
        u = at
        f0 = 140 + 520 * u ** 1.3
        place(y, bubble(f0 * rng.uniform(0.85, 1.15), 0.075 - 0.04 * u, 0.9), at, 0.55 + 0.45 * u)
        at += (0.11 - 0.085 * u) * rng.uniform(0.7, 1.3)
    y += 0.16 * noise(n, rng, lo=50, hi=260, tilt=-4.0) * (0.15 + 0.85 * t ** 1.5)
    y += 0.12 * noise(n, rng, lo=1200, hi=4500, tilt=-3.0) * t ** 3
    return y


def geyser_burst(rng, v):
    dur = [1.6, 2.0][v]
    n = nsamp(dur)
    t = tvec(n)
    fc = 300 + [1300, 1000][v] * np.clip(t / 0.15, 0, 1) * np.exp(-np.maximum(t - 0.15, 0) / 0.8)
    env = np.clip(t / 0.02, 0, 1) * np.exp(-t / [0.5, 0.7][v])
    y = unit(sweep_noise(n, rng, fc, 900, wrap=False)) * env
    y += 1.2 * thump(n, 110, [50, 43][v], 0.04, 0.2)
    spray = np.clip(t / 0.2, 0, 1) * np.exp(-np.maximum(t - 0.2, 0) / [0.45, 0.6][v])
    y += 0.4 * noise(n, rng, lo=1800, hi=6500, tilt=-3.0) * spray
    y += 0.25 * unit(filt(impulses(n, rng, 500.0), lo=800, hi=3000)) * np.clip((t - 0.4) / 0.3, 0, 1) * np.exp(-np.maximum(t - 0.7, 0) / 0.4)
    return y


def sizzle(rng, v):
    dur = [0.7, 1.0][v]
    n = nsamp(dur)
    t = tvec(n)
    ker = np.exp(-tvec(nsamp(0.02)) / 0.002)
    ce = conv(np.abs(impulses(n, rng, [320.0, 220.0][v])), ker)
    ce = ce / (np.mean(ce) + 1e-9)
    y = noise(n, rng, lo=1800, hi=6500, tilt=-3.0) * (0.3 + 0.4 * np.minimum(ce, 6.0))
    y += 0.35 * noise(n, rng, lo=700, hi=2500, tilt=-3.0)
    return y * np.clip(t / 0.003, 0, 1) * np.exp(-t / [0.22, 0.34][v])


def hammer_clang(rng, v):
    n = nsamp([1.0, 1.15][v])
    f = [540.0, 452.0][v]
    parts = []
    for r, a, d in [(1.0, 1.0, 0.9), (2.21, 0.7, 0.7), (3.19, 0.5, 0.5), (4.63, 0.32, 0.35), (5.9, 0.18, 0.25), (7.4, 0.08, 0.15)]:
        parts.append((f * r, a, d * [1.0, 1.15][v], rng.uniform(0, TAU)))
        parts.append((f * r * 1.004, a * 0.4, d * [1.0, 1.15][v], rng.uniform(0, TAU)))
    y = modal(n, parts) * np.clip(tvec(n) / 0.0008, 0, 1)
    y += 0.5 * burst(n, rng, 1500, 6000, 0.003) + 0.5 * thump(n, 200, 120, 0.01, 0.04)
    return filt(y, hi=6500, order=1)


def bellows_whoosh(rng, v):
    dur = [0.9, 1.15][v]
    n = nsamp(dur)
    t = tvec(n)
    u = t / dur
    hump = np.exp(-0.5 * ((u - 0.35) / 0.2) ** 2)
    env = (0.12 + 0.88 * hump) * np.clip((1 - u) / 0.3, 0, 1)
    c0 = [350, 280][v]
    y = unit(sweep_noise(n, rng, c0 * 3.0 ** hump, 700, wrap=False)) * env
    y += 0.5 * noise(n, rng, lo=80, hi=400, tilt=-3.0) * env
    place(y, creak(0.25, rng, 30, 45, [(160, 6, 1.0), (330, 7, 0.7), (700, 6, 0.3)]), 0.0, 0.12)
    return y


def wind_gust(rng, v):
    n = nsamp(2.0)
    t = tvec(n)
    u = t / 2.0
    shape = np.exp(-0.5 * ((u - [0.45, 0.35, 0.55][v]) / [0.2, 0.16, 0.22][v]) ** 2)
    env = 0.07 + 0.93 * shape
    c0, c1 = [(300, 750), (380, 1000), (240, 600)][v]
    y = unit(sweep_noise(n, rng, c0 * (c1 / c0) ** shape, 350, wrap=False)) * env
    y += 0.6 * noise(n, rng, lo=70, hi=450, tilt=-3.0) * env
    y += 0.35 * noise(n, rng, lo=900, hi=4500, order=1, tilt=-4.5) * env ** 2
    y *= 0.8 + 0.4 * slow(n, rng, 7.0)
    return y * np.clip((1 - u) / 0.15, 0, 1)


def wind_warn(rng):
    n = nsamp(0.8)
    t = tvec(n)
    u = t / 0.8
    fc = 480.0 * (1350.0 / 480.0) ** u
    env = (0.15 + 0.85 * u ** 1.5) * np.clip((1 - u) / 0.08, 0, 1)
    y = unit(sweep_noise(n, rng, fc, 60, order=2, wrap=False))
    y += 0.55 * np.sin(phase(fc * (1 + 0.012 * np.sin(TAU * 6.5 * t))))  # a steady core under the breath
    y += 0.12 * unit(sweep_noise(n, rng, fc * 2, 90, order=2, wrap=False)) * u
    y += 0.3 * noise(n, rng, lo=500, hi=3000, tilt=-3.0)
    return y * env


def vulture_cry(rng, v):
    dur = [0.7, 0.95][v]
    n = nsamp(dur)
    t = tvec(n)
    u = t / dur
    if v == 0:
        f = 520 + 110 * np.exp(-((u - 0.12) / 0.12) ** 2) - 130 * u
        env = np.clip(t / 0.012, 0.15, 1) * np.clip((1 - u) / 0.35, 0, 1)
    else:  # kra-kaaah
        f = 470 + 90 * np.exp(-((u - 0.4) / 0.1) ** 2) - 110 * np.clip((u - 0.4) / 0.6, 0, 1)
        env = np.clip(t / 0.012, 0.15, 1) * (np.clip((0.22 - u) / 0.05, 0, 1) + np.clip((u - 0.27) / 0.04, 0, 1)) * np.clip((1 - u) / 0.3, 0, 1)
    f = f * (1 + 0.02 * noise(n, rng, hi=30.0))
    src = tone(phase(f), [1.0 / (k + 1) for k in range(12)])
    rasp = np.sin(phase(68 * (1 + 0.15 * noise(n, rng, hi=15.0))))
    rasp = 0.72 + 0.28 * np.tanh(3.0 * rasp)
    y = resonate(src * rasp, [(1100, 5, 1.0), (2300, 6, 0.6), (3200, 6, 0.2)], dry=0.15)
    y = unit(y) + 0.25 * noise(n, rng, lo=1200, hi=4000, tilt=-3.0)
    return y * env


def kick_thwack(rng):
    n = nsamp(0.3)
    t = tvec(n)
    y = 0.8 * thump(n, 190, 78, 0.018, 0.04)
    y += 1.0 * burst(n, rng, 900, 4500, 0.008) + 0.9 * burst(n, rng, 200, 1100, 0.022)
    y += 0.3 * np.sin(phase(250 + 650 * np.exp(-t / 0.018))) * np.exp(-t / 0.03)
    return np.tanh(1.2 * y)


def branch_snap(rng, v):
    n = nsamp([0.4, 0.34][v])
    s = [1.0, 1.3][v]
    y = 1.1 * burst(n, rng, 900, 7000, 0.004)
    y += modal(n, [(680 * s, 0.6, 0.07), (1250 * s, 0.45, 0.05), (2100 * s, 0.25, 0.03)])
    y += 0.4 * thump(n, 300 * s, 170 * s, 0.008, 0.02)
    place(y, burst(nsamp(0.1), rng, 1200, 6500, 0.003), [0.035, 0.022][v], 0.45)
    for _ in range(4):
        place(y, burst(nsamp(0.05), rng, 1500, 6000, 0.002), rng.uniform(0.05, 0.16), rng.uniform(0.08, 0.2))
    return y


def cable_twang(rng, v):
    dur = [1.5, 1.8][v]
    n = nsamp(dur)
    t = tvec(n)
    f0 = [73.42, 55.0][v]
    s = ks(n + nsamp(0.1), f0, [2.2, 2.8][v], rng, bright=5000.0)
    y = warp(s, 1 + 0.05 * np.exp(-t / 0.05) + 0.006 * np.sin(TAU * 6 * t) * np.exp(-t / 0.4))
    y = pk(dull(filt(y, hi=4500, order=1), 900.0, 0.3))
    # a struck wire is dispersive: the highs arrive first, so it says "pew"
    y += 0.3 * np.sin(phase(350 + [2300, 1900][v] * np.exp(-t / 0.035))) * np.exp(-t / 0.06)
    y += modal(n, [(1870 * [1, 0.8][v], 0.1, 0.4), (2930 * [1, 0.8][v], 0.05, 0.25)])
    y += 0.3 * burst(n, rng, 800, 4000, 0.004)
    return y * np.clip((dur - t) / 0.4, 0, 1)


def pulley_squeak(rng, v):
    n = nsamp([0.48, 0.6][v])
    t = tvec(n)
    if v == 0:
        a = np.clip(t / 0.16, 0, 1)
        b = np.clip((t - 0.22) / 0.22, 0, 1)
        f = np.where(t < 0.2, 950 + 400 * a, 1050 + 450 * b)
        env = np.where(t < 0.2, np.sin(np.pi * np.clip(t / 0.19, 0, 1)) ** 0.6,
                       np.sin(np.pi * np.clip((t - 0.22) / 0.25, 0, 1)) ** 0.6)
    else:
        u = t / 0.6
        f = 800 + 450 * np.sin(np.pi * u) ** 1.5 + 200 * u
        env = np.sin(np.pi * np.clip(u, 0, 1)) ** 0.5
    y = squeal(n, f, rng, rough=0.35, harm=(1.0, 0.4, 0.15, 0.04))
    y = y * (0.12 + 0.88 * np.maximum(env, 0.0)) * np.clip(t / 0.003, 0, 1) * np.clip((n / SR - t) / 0.03, 0, 1)
    return filt(y, lo=500, hi=4000, order=1)


def gondola_clunk(rng, v):
    n = nsamp([0.6, 0.7][v])
    s = [1.0, 0.85][v]
    y = impact(n, rng, f_low=[84, 72][v], t_low=0.06, low=0.9, nlo=250, nhi=2500, t_noise=0.015, nz=0.8,
               ring=[(175 * s, 0.6, 0.25), (292 * s, 0.5, 0.2), (431 * s, 0.35, 0.15), (687 * s, 0.22, 0.1)])
    m = nsamp(0.2)
    place(y, 0.6 * burst(m, rng, 1500, 5000, 0.004) + modal(m, [(1250 * s, 0.4, 0.06), (1980 * s, 0.2, 0.04)]),
          [0.07, 0.1][v], 0.45)
    return y


def zip_whirr(rng):
    n = nsamp(2.0)
    t = tvec(n)
    u = t / 2.0
    fc = 400 + 900 * np.clip(t / 0.5, 0, 1) ** 0.7 - 500 * np.clip((t - 0.5) / 1.5, 0, 1) ** 1.3
    y = unit(sweep_noise(n, rng, fc, 120, wrap=False))
    ph = phase(fc / 4.0)
    y += 0.45 * unit(tone(ph, [1.0, 0.6, 0.4, 0.3, 0.2, 0.12])) * (1.0 + 0.3 * np.sin(phase(fc / 40.0)))
    y += 0.18 * unit(sweep_noise(n, rng, fc * 2.2, 200, wrap=False))
    y += 0.2 * noise(n, rng, lo=300, hi=2500, tilt=-3.0)
    return y * np.clip(t / 0.03, 0.12, 1) * np.clip((1 - u) / 0.3, 0, 1) ** 1.2


def ice_tick(rng, v):
    n = nsamp([0.12, 0.14, 0.16][v])
    f = [2500.0, 2950.0, 2150.0][v]
    y = 0.6 * burst(n, rng, 2200, 7000, 0.0015) + modal(n, [(f, 1.0, 0.03), (f * 1.63, 0.4, 0.02)])
    if v == 2:
        m = nsamp(0.08)
        place(y, 0.6 * burst(m, rng, 2200, 7000, 0.0015) + modal(m, [(f * 1.12, 1.0, 0.03)]), 0.045, 0.6)
    return filt(y, hi=7000, order=1)


def ice_crack(rng, v):
    n = nsamp([0.6, 0.72, 0.5][v])
    t = tvec(n)
    s = [1.0, 0.8, 1.25][v]
    y = 1.1 * burst(n, rng, 600, 6500, 0.005)
    for _ in range([5, 7, 4][v]):  # the crack running on
        at = rng.uniform(0.015, 0.14)
        place(y, burst(nsamp(0.06), rng, 1200, 6500, 0.0025), at, rng.uniform(0.2, 0.5))
    y = echo(y, 0.13, [0.14, 0.05], hi=3000)
    y += 0.28 * np.sin(phase(600 * s + 2200 * s * np.exp(-t / 0.02))) * np.exp(-t / 0.03)  # a little zing
    y += 0.45 * thump(n, 210 * s, 75 * s, 0.02, 0.05)
    return filt(y, hi=7500, order=1)


def ice_shatter(rng, v):
    dur = [1.0, 1.2][v]
    n = nsamp(dur)
    s = [1.0, 0.85][v]
    y = 0.9 * burst(n, rng, 400, 5000, 0.04) + 0.5 * thump(n, 180, 85, 0.02, 0.05)
    for at in scatter(rng, [26, 36][v], 0.24, dur - 0.25):
        f = rng.uniform(1800, 4800) * s
        m = nsamp(0.2)
        p = modal(m, [(f, 1.0, rng.uniform(0.03, 0.11)), (f * 1.7, 0.3, 0.03)]) + 0.5 * burst(m, rng, f * 0.7, f * 1.4, 0.003)
        place(y, p, at, rng.uniform(0.12, 0.45) * np.exp(-at * 1.8))
    return filt(y, hi=7500)


def snow_whump(rng, v):
    n = nsamp([0.7, 0.85][v])
    t = tvec(n)
    f = [50, 43][v]
    y = 1.1 * thump(n, f * 2.2, f, 0.03, [0.1, 0.13][v], attack=0.003)
    y += 0.9 * noise(n, rng, lo=100, hi=900, order=1, tilt=-4.0) * np.clip(t / 0.005, 0, 1) * np.exp(-t / [0.11, 0.15][v])
    y += 0.12 * noise(n, rng, lo=1000, hi=4000, tilt=-6.0) * np.sin(np.pi * np.clip(t / 0.4, 0, 1)) ** 2
    return y


def icicle_drop(rng, v):
    dur = [0.5, 0.62][v]
    n = nsamp(dur)
    s = [1.0, 0.82][v]
    y = modal(n, [(2400 * s, 1.0, 0.06), (3900 * s, 0.5, 0.04)]) + 0.8 * burst(n, rng, 1500, 7000, 0.006)
    y += 0.5 * thump(n, 420 * s, 300 * s, 0.01, 0.02)
    for _ in range([7, 10][v]):
        at = rng.uniform(0.03, dur * 0.6)
        f = rng.uniform(2000, 4600) * s
        place(y, modal(nsamp(0.15), [(f, 1.0, rng.uniform(0.04, 0.1))]) + 0.4 * burst(nsamp(0.15), rng, 2000, 6000, 0.002),
              at, rng.uniform(0.12, 0.4) * np.exp(-at * 3))
    return filt(y, hi=7500, order=1)


def thunder(rng, v):
    dur = [3.3, 4.2, 5.0][v]
    y = thunder_roll(dur, rng, crack=[1.0, 0.25, 0.0][v], bumps=[5, 7, 8][v], lp=[280.0, 240.0, 200.0][v])
    t = tvec(y.size)
    return y * np.clip((dur - t) / 0.8, 0, 1)


def lightning_hum(rng):
    n = nsamp(1.5)
    t = tvec(n)
    u = t / 1.5
    ph = phase(70.0 * 3.0 ** u)
    y = np.zeros(n)
    for k in range(1, 17):
        y += np.sin(k * ph + 0.7 * k) * k ** -0.7 * np.exp(-k / (3.0 + 9.0 * u))
    y = pk(y)
    cr = pk(filt(impulses(n, rng, 40 + 400 * u ** 2, heavy=1.0), lo=1500, hi=5000)) * u ** 1.5
    return (y + 0.3 * cr) * (0.12 + 0.88 * u ** 1.8) * np.clip((1 - u) / 0.012, 0, 1)


def lightning_zap(rng, v):
    n = nsamp([0.5, 0.62][v])
    t = tvec(n)
    f = [100.0, 84.0][v]
    saw = filt(tone(phase(f, n), [1.0 / (k + 1) ** 0.5 for k in range(30)]), lo=350, hi=5000, order=1)
    ker = np.exp(-tvec(nsamp(0.03)) / 0.004)
    gate = conv(np.abs(impulses(n, rng, 90.0, heavy=1.0)), ker)
    gate = gate / (gate.max() + 1e-9)
    y = 1.0 * burst(n, rng, 700, 6500, 0.025)
    y += 0.9 * pk(saw) * (0.35 + 0.65 * gate) * np.exp(-t / [0.11, 0.15][v])  # bzzt, stuttering
    y += 0.12 * np.sin(phase(400 + [2000, 1600][v] * np.exp(-t / 0.04))) * np.exp(-t / 0.05)
    y += 0.4 * pk(filt(impulses(n, rng, 500.0 * np.exp(-t / 0.12)), lo=1500, hi=6000)) * np.exp(-t / 0.15)
    return filt(np.tanh(1.5 * y), hi=6500, order=1)


def kite_whip(rng, v):
    n = nsamp([0.35, 0.42][v])
    t = tvec(n)
    ts = [0.11, 0.16][v]
    r = np.clip(t / ts, 0, 1)
    fc = [500, 400][v] * (5.0 ** r)
    env = (0.15 + 0.85 * r ** 2) * np.where(t < ts, 1.0, np.exp(-(t - ts) / 0.03))
    y = unit(sweep_noise(n, rng, fc, 500, wrap=False)) * env * 0.7
    m = nsamp(0.2)
    snap = 1.2 * burst(m, rng, 1200, 6000, 0.006) + 0.8 * thump(m, 220, 90, 0.012, 0.035)
    place(y, snap, ts, 1.0)
    for k in range(3):
        place(y, burst(nsamp(0.1), rng, 200, 2000, 0.02) + thump(nsamp(0.1), 150, 80, 0.015, 0.03),
              ts + 0.06 + k * rng.uniform(0.045, 0.07), 0.3 * 0.6 ** k)
    return y


def summit_bell(rng, v):
    n = nsamp(5.6)
    t = tvec(n)
    prime = 146.83  # D3; the tierce is a major third (F#), so the bell sits in D major
    bright = [1.0, 1.5, 0.7][v]
    parts = []
    table = [(0.5, 0.4, 8.0), (1.0, 1.0, 6.0), (1.26, 0.6, 4.6), (1.5, 0.3, 3.6), (2.0, 1.0, 3.6),
             (2.52, 0.35, 2.6), (3.0, 0.5, 2.1), (4.0, 0.45, 1.6), (5.33, 0.25, 1.1), (6.7, 0.16, 0.7), (8.2, 0.1, 0.45)]
    for r, a, d in table:
        hi = bright if r > 2.0 else (1.0 + (bright - 1.0) * 0.3 if r > 1.0 else 1.0)
        f = prime * r
        det = rng.uniform(0.0008, 0.0022)
        parts.append((f, a * hi, d, rng.uniform(0, TAU)))
        parts.append((f * (1 + det), a * hi * rng.uniform(0.4, 0.7), d * 0.95, rng.uniform(0, TAU)))
    y = modal(n, parts) * np.clip(t / 0.0015, 0, 1)
    y += [0.5, 0.8, 0.3][v] * burst(n, rng, 400, [3500, 4500, 2500][v], 0.012)
    y += 0.5 * thump(n, 180, 110, 0.01, 0.03)
    return y * np.clip((5.6 - t) / 0.9, 0, 1)


def bounce_rope(rng, v):
    dur = [0.8, 0.9][v]
    n = nsamp(dur)
    t = tvec(n)
    f0 = [82.41, 110.0][v]  # E2 and A2
    s = ks(n + nsamp(0.3), f0, [1.0, 1.2][v], rng, bright=2500.0)
    rate = 1 + 0.28 * np.exp(-t / 0.04) + 0.035 * np.sin(TAU * [7.0, 8.5][v] * t) * np.exp(-t / 0.3)
    y = pk(dull(filt(warp(s, rate), hi=2200, order=1), 500.0, 0.09))
    y += 0.6 * burst(n, rng, 200, 1500, 0.015) + 0.5 * thump(n, 140, 70, 0.02, 0.05)
    return y * np.clip((dur - t) / 0.25, 0, 1)


def knock_out_bonk(rng, v):
    n = nsamp([0.4, 0.46][v])
    t = tvec(n)
    f0 = [430.0, 345.0][v]
    f = f0 * (1 + 0.28 * np.exp(-t / 0.008)) * (1 - 0.1 * np.clip(t / 0.2, 0, 1))
    ph = phase(f)
    tau = [0.055, 0.07][v]
    y = np.sin(ph) * np.exp(-t / tau) + 0.25 * np.sin(2.71 * ph) * np.exp(-t / (tau * 0.4))
    y *= np.clip(t / 0.0006, 0, 1)
    click = np.zeros(n)
    click[:nsamp(0.03)] = burst(nsamp(0.03), rng, 300, 4000, 0.002)
    y += 0.5 * pk(resonate(click, [(f0, 8, 1.0), (f0 * 2.4, 6, 0.5)]))
    y += 0.45 * thump(n, 190, 120, 0.015, 0.05)
    return y


def land_thud_big(rng, v):
    n = nsamp([0.7, 0.82][v])
    t = tvec(n)
    f = [58, 50][v]
    y = 0.9 * thump(n, f * 2.5, f, 0.03, [0.11, 0.14][v])
    y += 1.4 * burst(n, rng, 150, 1000, 0.03) + 0.5 * burst(n, rng, 800, 3000, 0.006)
    dust = np.clip(t / 0.08, 0, 1) * np.exp(-np.maximum(t - 0.08, 0) / 0.2)
    y += 0.08 * unit(filt(impulses(n, rng, 1500.0), lo=1200, hi=4500)) * dust
    return np.tanh(1.2 * y)


def new_best_chime(rng):
    n = nsamp(0.6)
    y = np.zeros(n)
    for at, f, g in [(0.0, A5, 0.85), (0.15, D6, 1.0)]:
        m = n - nsamp(at)
        t = tvec(m)
        idx = 1.2 * np.exp(-t / 0.04) + 0.08  # FM: the index falls, so each note starts bright
        note = np.sin(TAU * f * t + idx * np.sin(TAU * f * 3.0 * t))
        note += 0.25 * np.sin(TAU * f * 2.0 * t) * np.exp(-t / 0.08)
        place(y, note * np.exp(-t / 0.16) * np.clip(t / 0.001, 0, 1), at, g)
    return y


# --------------------------------------------------------------------------------------
# the list
# --------------------------------------------------------------------------------------

ITEMS = []  # (name, kind, how, fn, args)


def add(name, kind, how, fn, *args):
    ITEMS.append((name, kind, how, fn, args))


def add_n(stem, count, how, fn):
    for v in range(count):
        add("%s_%02d" % (stem, v + 1), "shot", how, fn, v)


add("amb_a0", "bed", "wind band over a low body; a far crowd (pulse-train voices through formants, low-passed, in a room); one bird, two short phrases", amb_a0)
add("amb_a1", "bed", "narrow noise bands at 58 to 311 Hz for the hollow drone; five drips with a 0.31 s echo; two stick-slip timber creaks; long room", amb_a1)
add("amb_a2", "bed", "pink roar 90 Hz to 5 kHz, a wandering mid band, 80 bubbles, four drips, cave room", amb_a2)
add("amb_a3", "bed", "26 faint high sines twinkling on whole-cycle envelopes, a soft D/A glass drone, five glass pings (A6 D7 F#6 B6 E6) in a long room", amb_a3)
add("amb_a4", "bed", "Poisson clicks through 2.6 to 4.8 kHz resonators (fizz), six rising-sine plops, three pulsed insect chirrs, low room tone", amb_a4)
add("amb_a5", "bed", "low noise with bands at 62, 98 and 163 Hz, a torch (flutter and crackle), a soft far thump every 6 s in a 3 s room", amb_a5)
add("amb_a6", "bed", "hiss 1.4 to 6 kHz, rumble, a boiling sputter, about 14 metal ticks (short modal pings) at uneven gaps", amb_a6)
add("amb_a7", "bed", "gusting wind band 250 to 700 Hz with a higher whistle on the gusts; one falling bird-of-prey cry with an echo", amb_a7)
add("amb_a8", "bed", "wind, a 55 Hz hum with harmonics (an A under the climb's D), a faint cable whistle, two metal stick-slip creaks", amb_a8)
add("amb_a9", "bed", "thin wind band 800 to 1700 Hz with spindrift hiss, two slow stick-slip ice groans over a low sine, four small cracks with echo", amb_a9)
add("amb_a10", "bed", "hard gusting wind with a howl, rain (hiss plus Poisson drops), one far thunder roll that swells in", amb_a10)
add("amb_a11", "bed", "gentle high wind band 600 to 1300 Hz, cloth flaps that follow the gusts", amb_a11)

add("cart_roll_loop", "loop", "low rumble, noise through iron resonators, grit, a wheel flat ticking five to the second", cart_roll_loop)
add("waterfall_loop", "loop", "pink noise 60 Hz to 6.5 kHz with a sub layer, a churning mid band and spray", waterfall_loop)
add("river_loop", "loop", "band noise with a wandering resonance and 110 bubbles", river_loop)
add("wheel_creak_loop", "loop", "axle rumble, two long stick-slip creaks through wood resonators, four wooden knocks, one a second", wheel_creak_loop)
add("gondola_hum_loop", "loop", "harmonics of 73.3 Hz (a D), sheave noise pulsing at 7 Hz with a tick on each", gondola_hum_loop)
add("fall_wind_loop", "loop", "plain band noise 180 Hz to 2.6 kHz with a light buffet: no events, made to be pitched", fall_wind_loop)
add("steam_loop", "loop", "hiss 1.2 to 6 kHz, a low sputter, a little sub", steam_loop)
add("torch_loop", "loop", "low flutter, a soft roar, sparse crackles", torch_loop)
add("stone_grind_loop", "loop", "dense Poisson clicks through low stone resonators, with rumble and grit", stone_grind_loop)
add("flag_flutter_loop", "loop", "soft flaps (noise and a short low thump) at about 9 a second, with a ripple", flag_flutter_loop)
add("boulder_roll_loop", "loop", "rumble, seven uneven thumps, gravel crunch after each", boulder_roll_loop)
add("avalanche_loop", "loop", "deep rumble, a snow wash, a moving low band, nine low thumps", avalanche_loop)

add("cart_start", "shot", "a clunk, a short wood creak, then rumble and wheel ticks picking up", cart_start)
add_n("cart_clack", 3, "two iron impacts a few hundredths apart: thump, click, three ringing modes", cart_clack)
add("cart_brake", "shot", "a falling squeal (1450 to 680 Hz, rough-edged) over scrape noise", cart_brake)
add("cart_crash", "shot", "a big impact with iron modes, nine timber cracks, fourteen falling bits, short room", cart_crash)
add("lever_clunk", "shot", "a click, a low iron thunk, and the latch 85 ms later", lever_clunk)
add_n("plank_creak", 3, "stick-slip ticks that speed up into a rising groan (the strain) through wood resonators", plank_creak)
add_n("plank_snap", 3, "a crack, a low thump, wood modes, then splinters and a clatter", plank_snap)
add_n("rock_crumble", 3, "a first hit, then 45 to 100 small rock grains thinning out, over a rumble", rock_crumble)
add_n("rock_hit", 3, "a low thump, a band of noise, three short modes: a tock", rock_hit)
add_n("dust_trickle", 2, "dense Poisson clicks from 1.5 to 5 kHz (sand) with a few pebble ticks", dust_trickle)
add_n("rope_creak", 3, "stick-slip train through fibre resonators (560 Hz to 2.6 kHz)", rope_creak)
add_n("chain_rattle", 3, "8 to 16 clinks, each four inharmonic modes and a click, thinning out", chain_rattle)
add_n("gate_slam", 2, "a deep thump, wood and iron noise, a few rattles, tunnel room", gate_slam)
add_n("water_paddle", 3, "a swoosh of moving band noise, an entry plip, 11 to 20 bubbles", water_paddle)
add_n("drip", 3, "a sine that jumps up in pitch, with two small echoes", drip)
add_n("crystal_chime", 8, "glass-bar partials (1, 2.76, 5.40), a faint octave and a detuned twin: D5 E5 F#5 A5 B5 D6 E6 F#6", crystal_chime)
add_n("crystal_shatter", 3, "a bright burst and a crunch, then 24 to 40 glass pings thinning out", crystal_shatter)
add_n("mushroom_boing", 3, "a three-harmonic tone that drops onto its note, wobbles and rises (G2, D3, A3), over a soft thump", mushroom_boing)
add_n("spore_puff", 2, "band noise falling from 2.4 kHz to 500 Hz, a soft low pf, a little fizz", spore_puff)
add_n("puffball_pop", 2, "a fast falling sine (the pop) and a breath of noise after", puffball_pop)
add_n("vine_creak", 2, "slow stick-slip through low green resonators with a faint wet squeak", vine_creak)
add_n("stone_slam", 2, "a 55 Hz thump, a crack, grit through stone resonators, temple room", stone_slam)
add_n("stone_drum", 2, "seven drum-head modes with a pitch drop at the strike (D2, A1), a beater thud, a room", stone_drum)
add_n("steam_hiss", 2, "hiss 1.2 to 6 kHz with a fast attack and a falling whistle band", steam_hiss)
add("geyser_warn", "shot", "bubbles coming faster and higher (140 to 660 Hz) over a growing rumble", geyser_warn)
add_n("geyser_burst", 2, "a low thump, a roar of band noise that opens then falls, spray, patter", geyser_burst)
add_n("sizzle", 2, "high noise under a crackle envelope, dying", sizzle)
add_n("hammer_clang", 2, "six inharmonic anvil modes in beating pairs, a click and a thump", hammer_clang)
add_n("bellows_whoosh", 2, "a breath of band noise that opens and closes, with a little leather creak", bellows_whoosh)
add_n("wind_gust", 3, "wind band whose centre and level swell and fall over 2 s", wind_gust)
add("wind_warn", "shot", "a narrow band of noise over a sine core, rising 480 to 1350 Hz and growing", wind_warn)
add_n("vulture_cry", 2, "a falling sawtooth voice through formants with a 68 Hz rasp", vulture_cry)
add("kick_thwack", "shot", "a low thump, a slap of noise, a quick falling chirp", kick_thwack)
add_n("branch_snap", 2, "a dry crack with three short wood modes and a second small crack", branch_snap)
add_n("cable_twang", 2, "Karplus-Strong string (D2, A1) losing its top, with a falling chirp at the front, as a struck wire has", cable_twang)
add_n("pulley_squeak", 2, "a rough squeal tone: two rising chirps, or one that wobbles", pulley_squeak)
add_n("gondola_clunk", 2, "a low thump, four hollow box modes, a latch click", gondola_clunk)
add("zip_whirr", "shot", "a narrow noise band and a buzz that climb for half a second then fall away", zip_whirr)
add_n("ice_tick", 3, "a tiny click and a 2 to 3 kHz ping, 30 ms long (the third is a double)", ice_tick)
add_n("ice_crack", 3, "a crack that runs on with a short echo, a low thump, a little falling zing", ice_crack)
add_n("ice_shatter", 2, "a crunch, then 26 to 36 short dull pings", ice_shatter)
add_n("snow_whump", 2, "a soft low thump and a muffled puff of low noise", snow_whump)
add_n("icicle_drop", 2, "a glass tick, a small crunch, 7 to 10 shards", icicle_drop)
add_n("thunder", 3, "low noise under a run of bumps: 01 near with a crack, 02 rolling, 03 far", thunder)
add("lightning_hum", "shot", "a buzz of 16 harmonics rising 70 to 210 Hz and brightening, with growing crackle", lightning_hum)
add_n("lightning_zap", 2, "a bright burst, a stuttering 100 Hz buzz, dying crackle", lightning_zap)
add_n("kite_whip", 2, "a rising whoosh into a snap, then three small flaps", kite_whip)
add_n("summit_bell", 3, "eleven bronze-bell partials in beating pairs on D3 with a major-third tierce; 02 struck harder, 03 softer", summit_bell)
add_n("bounce_rope", 2, "Karplus-Strong string (E2, A2), dulled, bent down onto its note with a wobble, over a thwap", bounce_rope)
add_n("knock_out_bonk", 2, "a short sine that drops onto its note, a hollow two-mode click, a low thump", knock_out_bonk)
add_n("land_thud_big", 2, "a 58 Hz thump, a slap of low noise, a breath of dust", land_thud_big)
add("new_best_chime", "shot", "two FM bell notes, A5 then D6, the index falling so each starts bright", new_best_chime)

TAILS = {"wind_warn": 0.012, "geyser_warn": 0.02, "lightning_hum": 0.012}
FOREIGN = ("peak_fall_wah.wav", "peak_summit_fanfare.wav", "peak_milestone.wav")

# What a human should replace first. Written after measuring; nobody has listened.
WEAK = [
    "**`vulture_cry_01/02` and the bird in `amb_a7`.** A voice is the hardest thing to fake. The vulture is a sawtooth through three formants with a rasp, and will likely read as a kazoo or a goose; the far bird of prey is one falling tone. A recorded or performed cry would beat both.",
    "**The far fiesta in `amb_a0`.** Seven pulse-train voices through formants, low-passed and put in a room. It measures as a murmur (about 5 dB under the breeze) but may come across as a muffled buzz, not people. The bird in the same bed is plain sine chirps.",
    "**Every creak: `plank_creak`, `rope_creak`, `vine_creak`, `wheel_creak_loop`, and the creaks inside `amb_a1` and `amb_a8`.** They are stick-slip click trains through resonators. The spectrograms show the ticks running together into a groan, as intended, but this method can read as a ratchet or a purr. `plank_creak` matters most: it is the warning before a plank snaps.",
    "**`thunder_01/02/03` and the roll in `amb_a10`.** Filtered noise under a run of bumps. Fine far away; the near one (01) has no real crack or depth. `thunder_03` is nearly all under 200 Hz and will vanish on small speakers.",
    "**The water: `waterfall_loop`, `river_loop`, `water_paddle`, `amb_a2`.** Shaped noise with sine bubbles on top. Noise water tends to read as hiss without the fine detail of the real thing. `waterfall_loop` has to carry a 113 m fall and is the one to replace first.",
    "**`cart_brake` and `pulley_squeak_01/02`.** Nearly pure squeal tones around 1 to 1.5 kHz. They are cartoonish on purpose, but they are also the loudest files by the A column (the pulley is about 10 dB hotter than most one-shots at the same gain): turn them down, and replace them if they grate.",
    "**The deep hits: `stone_drum_01/02`, `stone_slam`, `gate_slam`, `land_thud_big`, `summit_bell`.** At -3 dBFS peak they are mostly below 200 Hz, so there is no headroom left to make them heard on small speakers. I added skin, slap and upper partials to each, but check them on laptop speakers. `stone_drum` is the worst case (A about -33 dB).",
    "**`stone_grind_loop`, `boulder_roll_loop`, `avalanche_loop`.** Noise through low resonators with thumps. They measure as steady rumble with little of the grit and weight of the real thing.",
    "**`lightning_zap`, `lightning_hum`, `zip_whirr`.** Harmonic buzzes and a moving noise band. They will sound synthesised. That may suit the cartoon; it will not sound like a recording.",
    "**`crystal_shatter` and `ice_shatter`.** A burst and a scatter of pings. May read as wind chimes falling over, not as something breaking.",
    "**`flag_flutter_loop`, `kite_whip`, the cloth in `amb_a11`.** Flaps made of short noise bursts. Plausible on the spectrogram; cloth is easy to get wrong.",
    "**The beds repeat every 12 s.** Each has a few one-off events (drips, pings, a cry, a roll, two groans). They are kept low, but an hour in one place will show the pattern. `amb_a5`'s far thump every 6 s is not in time with the music (96 bpm): if it fights the drums of the A5 loop, cut it from the bed.",
]

STRONG = [
    "The pitched and struck sounds, where synthesis is at home: `crystal_chime_01..08` (the rising scale), `new_best_chime`, `summit_bell`, `mushroom_boing`, `drip`, `knock_out_bonk`, `hammer_clang`, `cable_twang`, `bounce_rope`, `chain_rattle`, `cart_clack`, `lever_clunk`.",
    "The wind family: `wind_gust`, `wind_warn`, `fall_wind_loop` and the wind in beds A7 to A11. Resonant noise with a moving centre is how wind is usually made.",
    "The hisses and fires: `steam_loop`, `steam_hiss`, `sizzle`, `torch_loop`, `dust_trickle`, `spore_puff`, `geyser_warn`.",
]

TUNING = [
    "The climb's music is in D. Pitched effects were tuned to sit in it: `crystal_chime` is the asked-for scale (D5 E5 F#5 A5 B5 D6 E6 F#6); `new_best_chime` is A5 to D6; `summit_bell` is on D3 with a major-third tierce (F#, where a church bell has a minor third) so it agrees with the summit's D major; `stone_drum` is D2 and A1; `cable_twang` D2 and A1; `bounce_rope` E2 and A2; `mushroom_boing` G2, D3, A3; the pings in `amb_a3` are A6 D7 F#6 B6 E6 over a faint D/A drone.",
    "`amb_a8`'s electrical hum is 55 Hz and its harmonics (an A), not 50 or 60 Hz, so it does not beat against the music. `gondola_hum_loop` is on 73.3 Hz (a D, two cents flat, so a whole number of cycles fits the loop).",
    "`fall_wind_loop` has no pitch and no events, so the game can pitch it with fall speed.",
]


def render(item):
    """Returns (samples, built): built is the seam check at the point where the
    generator's own period wraps, taken before the loop is rotated to its start."""
    name, kind, how, fn, args = item
    rng = np.random.default_rng(zlib.crc32(name.encode()))
    x = fn(rng, *args)
    if kind == "shot":
        stem = name[:-3] if name[-3] == "_" and name[-2:].isdigit() else name
        return finish_shot(x, tail=TAILS.get(stem, 0.03)), None
    x = finish_loop(x)
    built = seam(np.round(x * 32767) / 32767.0)
    return best_start(x), built


def main(argv):
    only = [a for a in argv if not a.startswith("-")]
    os.makedirs(OUT, exist_ok=True)
    rows = []
    bad = []
    for item in ITEMS:
        name, kind = item[0], item[1]
        if only and not any(name.startswith(o) for o in only):
            continue
        path = os.path.join(OUT, name + ".wav")
        y, built = render(item)
        write_wav(path, y)
        x = read_wav(path)
        m = measure(x)
        s = seam(x) if kind != "shot" else None
        if s:
            s["built"] = built
            if not (built["jump"] <= built["jump_max"] and built["slope"] <= built["slope_max"]):
                bad.append("%s: the generator's wrap point: jump %.5f (max inside %.5f), slope %.5f (max inside %.5f)" % (
                    name, built["jump"], built["jump_max"], built["slope"], built["slope_max"]))
        rows.append((item, m, s))
        if kind == "shot":
            if m["onset"] > 5.0:
                bad.append("%s: starts at %.1f ms" % (name, m["onset"]))
            if m["tail"] > -60.0:
                bad.append("%s: tail ends at %.1f dBFS" % (name, m["tail"]))
            if abs(m["peak"] - SHOT_PEAK_DB) > 0.1:
                bad.append("%s: peak %.2f dBFS" % (name, m["peak"]))
            print("%-22s %5.2f s  peak %6.1f  rms %6.1f  A %6.1f  onset %4.1f ms  tail %6.1f" % (
                name, m["len"], m["peak"], m["rms"], m["a"], m["onset"], m["tail"]))
        else:
            if not s["ok"]:
                bad.append("%s: seam jump %.5f (max inside %.5f), slope %.5f (max inside %.5f), level %+.1f dB (max inside %.1f)" % (
                    name, s["jump"], s["jump_max"], s["slope"], s["slope_max"], s["level"], s["level_max"]))
            if abs(m["rms"] - LOOP_RMS_DB) > 0.3:
                bad.append("%s: rms %.2f dBFS" % (name, m["rms"]))
            if m["peak"] > LOOP_CEIL_DB + 0.05:
                bad.append("%s: peak %.2f dBFS" % (name, m["peak"]))
            print("%-22s %5.2f s  peak %6.1f  rms %6.1f  A %6.1f  seam jump %.5f (%.0f%%) slope %.5f (%.0f%%) level %+.1f dB (%.0f%%)  wrap %.0f%%/%.0f%%" % (
                name, m["len"], m["peak"], m["rms"], m["a"], s["jump"], s["jump_pct"], s["slope"], s["slope_pct"], s["level"], s["level_pct"],
                built["jump_pct"], built["slope_pct"]))
    print("%d files written to %s" % (len(rows), OUT))
    for b in bad:
        print("CHECK FAILED  " + b)
    if not only:
        write_doc(rows, bad)
        print(DOC)
    return 1 if bad else 0


def write_doc(rows, bad):
    L = []
    L.append("# The Peak's sound effects")
    L.append("")
    L.append("Written by `tools/peak/make_peak_sfx.py` (run it to rebuild every file and this page;")
    L.append("edit the script, not this page). %d files in `audio/sfx/peak/`, mono, 16-bit, 44.1 kHz," % len(rows))
    L.append("all synthesised in numpy: nothing sampled, nothing downloaded. **Nobody has listened to")
    L.append("these yet.** They were built and checked by measurement and by reading spectrograms, so")
    L.append("treat the weak list below as where to start listening, not as the whole truth.")
    L.append("")
    L.append("Levels: one-shots peak at %.0f dBFS; loops and beds sit at %.0f dBFS RMS (peaks held" % (SHOT_PEAK_DB, LOOP_RMS_DB))
    L.append("under %.0f dBFS by a soft ceiling). The game sets the mix. The **A dB** column is the" % LOOP_CEIL_DB)
    L.append("A-weighted RMS: a rough guide to how loud each file will seem beside the others at the")
    L.append("same gain (a thump and a squeak with the same peak are far apart). Use it for a first")
    L.append("pass at the gains.")
    L.append("")
    L.append("Three more files in the folder are another worker's and are not listed here:")
    L.append(", ".join("`%s`" % f for f in FOREIGN) + ".")
    L.append("")
    L.append("## Checks")
    L.append("")
    if bad:
        L.append("**Failed on the last run:**")
        L.append("")
        for b in bad:
            L.append("- " + b)
    else:
        L.append("All passed on the last run: every one-shot reaches 1% of its peak within 5 ms (the")
        L.append("swells start at a low floor, not from silence) and its last samples are below -60 dBFS;")
        L.append("every loop's seam sits inside the file's own range. One-shots are trimmed where they")
        L.append("fall 70 dB under their peak, so some are shorter than the sound they describe.")
    L.append("")
    L.append("**How the loops loop.** Each is built periodic over its own length (FFT-shaped noise,")
    L.append("whole numbers of cycles, events added modulo the length, circular echo and reverb), so")
    L.append("the last sample runs into the first with no crossfade, and each is rotated to start at")
    L.append("a gentle zero crossing. Import them with loop mode Forward over the whole file. The seam")
    L.append("columns are measured from the written file, in full-scale units (1.0 = 0 dBFS):")
    L.append("")
    L.append("- **jump**: |first sample - last sample|, and the share of all sample-to-sample steps in")
    L.append("  the file that are no bigger. Under 100% means the seam's step is an ordinary one.")
    L.append("- **slope**: the change of slope across the seam (second difference), ranked the same way.")
    L.append("- **level**: RMS of the first 50 ms against the last 50 ms, ranked against the same")
    L.append("  measure taken all through the file.")
    L.append("- **wrap**: the same jump and slope ranks at the place where the generator's own period")
    L.append("  wraps. That place is inside the file now (the rotation moved it), so this is the test")
    L.append("  of the claim that the loops were built periodic. Ranks spread anywhere from 0 to 100%")
    L.append("  are what a point with nothing special about it gives; a hard 100% on both would be a click.")
    L.append("")
    L.append("**The beds repeat every 12 s.** Their one-off events (the bird, the far cry, the thunder")
    L.append("roll, the groans) are kept quiet for that reason. If a bed's repeat is noticed, lower")
    L.append("the bed and let the game fire the matching one-shots at random instead.")
    L.append("")
    L.append("## What is probably weak (replace these first)")
    L.append("")
    L.append("In the order I would replace them. This is judgement from how each was made and how it")
    L.append("measures, not from hearing it.")
    L.append("")
    for k, w in enumerate(WEAK):
        L.append("%d. %s" % (k + 1, w))
    L.append("")
    L.append("## What should be sound")
    L.append("")
    for w in STRONG:
        L.append("- " + w)
    L.append("")
    L.append("## Tuning")
    L.append("")
    for w in TUNING:
        L.append("- " + w)
    L.append("")
    for kind, title in [("bed", "Ambience beds"), ("loop", "Loops"), ("shot", "One-shots")]:
        L.append("## " + title)
        L.append("")
        if kind == "shot":
            L.append("| File | Length s | Peak dBFS | RMS dBFS | A dB | Starts ms | How it was made |")
            L.append("|---|---|---|---|---|---|---|")
        else:
            L.append("| File | Length s | Peak dBFS | RMS dBFS | A dB | Seam jump | Seam slope | Seam level dB | Wrap jump, slope | How it was made |")
            L.append("|---|---|---|---|---|---|---|---|---|---|")
        for (name, k, how, fn, args), m, s in rows:
            if k != kind:
                continue
            if kind == "shot":
                L.append("| `%s.wav` | %.2f | %.1f | %.1f | %.1f | %.1f | %s |" % (
                    name, m["len"], m["peak"], m["rms"], m["a"], m["onset"], how))
            else:
                L.append("| `%s.wav` | %.2f | %.1f | %.1f | %.1f | %.5f (%.0f%%) | %.5f (%.0f%%) | %+.1f (%.0f%%) | %.0f%%, %.0f%% | %s |" % (
                    name, m["len"], m["peak"], m["rms"], m["a"], s["jump"], s["jump_pct"], s["slope"], s["slope_pct"],
                    s["level"], s["level_pct"], s["built"]["jump_pct"], s["built"]["slope_pct"], how))
        L.append("")
    with open(DOC, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(L))


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
