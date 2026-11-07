"""TOP YOUR PALS: the main theme. A bouncy oompah loop: tuba and bassoon bass,
pizzicato strings and accordion on the off-beats, xylophone and tin whistle on the
tune, woodblock and tambourine. F major, 140 bpm (44100*60/140 = 18900, sample-
exact), 32 bars = 128 beats, continuous: the last bar leads back to bar 1.

Render: python theme.py  ->  audio/music/top_your_pals_theme.wav (+ .ogg via ffmpeg)
"""
import os, subprocess, shutil
from sf_kit import Song, chord

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "..", "audio", "music"))
TEMPO = 140

F, G, A, Bb, C, D, E = 53, 55, 57, 58, 60, 62, 64  # F3.. as roots

# Progression, one chord per bar: A A' B A''
A_PROG = [("F", "maj"), ("Bb", "maj"), ("C", "maj"), ("F", "maj"), ("D", "min"), ("Bb", "maj"), ("C", "dom7"), ("F", "maj")]
B_PROG = [("D", "min"), ("G", "min"), ("C", "maj"), ("F", "maj"), ("Bb", "maj"), ("C", "maj"), ("A", "dom7"), ("C", "dom7")]
ROOT = {"F": 41, "G": 43, "A": 45, "Bb": 46, "C": 48, "D": 50}  # bass octave (F2..)
PROG = A_PROG + A_PROG + B_PROG + A_PROG

# The tune: (note, beats). Section A (8 bars), A' answer, B (minor lift), A'' (ends leading home).
MEL_A = [(72, 1), (69, 0.5), (72, 0.5), (77, 1), (72, 1),   (74, 1), (70, 0.5), (74, 0.5), (77, 2),
         (76, 1), (74, 0.5), (72, 0.5), (70, 1), (67, 1),   (69, 1.5), (65, 0.5), (69, 2),
         (69, 1), (74, 0.5), (77, 0.5), (74, 1), (69, 1),   (70, 1), (74, 0.5), (77, 0.5), (82, 2),
         (79, 1), (77, 0.5), (76, 0.5), (74, 1), (70, 1),   (72, 3), (0, 1)]
MEL_A2 = [(77, 1), (76, 0.5), (77, 0.5), (79, 1), (77, 1),  (74, 1), (72, 0.5), (74, 0.5), (70, 2),
          (72, 0.5), (74, 0.5), (76, 0.5), (77, 0.5), (79, 1), (76, 1),  (77, 2), (72, 2),
          (74, 1), (77, 1), (81, 1), (77, 1),  (82, 1), (81, 0.5), (79, 0.5), (77, 2),
          (76, 1), (79, 1), (82, 1), (76, 1),  (77, 3), (0, 1)]
MEL_B = [(74, 1.5), (72, 0.5), (69, 1), (74, 1),  (70, 1.5), (69, 0.5), (67, 1), (70, 1),
         (72, 1), (76, 1), (79, 1), (76, 1),  (77, 2), (72, 2),
         (70, 1), (74, 1), (77, 1), (74, 1),  (72, 1), (76, 1), (79, 2),
         (81, 1), (79, 0.5), (77, 0.5), (76, 1), (73, 1),  (72, 1), (70, 1), (69, 1), (67, 1)]
MEL = MEL_A + MEL_A2 + MEL_B + MEL_A


def build():
    s = Song(tempo=TEMPO)
    tuba = s.track("Tuba")
    bassoon = s.track("Bassoon")
    pizz = s.track("Pizzicato Strings")
    acc = s.track("Accordion")
    xylo = s.track("Xylophone")
    whistle = s.track("Tin Whistle")
    glock = s.track("Glockenspiel")
    drums = s.drums()
    for bar, (name, q) in enumerate(PROG):
        b0 = bar * 4.0
        r = ROOT[name]
        fifth = r + 7 if q != "dim" else r + 6
        # Oompah: root on 1, fifth on 3 (tuba), bassoon walking up on the last bar of each phrase.
        tuba.at(b0).note(r, 0.9, 100).at(b0 + 2).note(fifth - 12 if fifth - 12 >= 33 else fifth, 0.9, 92)
        if bar % 4 == 3:
            bassoon.at(b0).notes([(r + 12, 1, 70), (r + 14, 1, 70), (r + 16, 1, 72), (r + 17, 1, 74)])
        # Off-beat chords: pizzicato and accordion on 2 and 4.
        ch = [n + 12 for n in chord(r + 12, q)]
        for off in (1.0, 3.0):
            pizz.at(b0 + off).chord(ch, 0.4, 72)
            acc.at(b0 + off).chord([n - 12 for n in ch], 0.5, 58)
        # Percussion: kick on 1/3, woodblock on the off-beats, tambourine shimmer, a fill every 8 bars.
        drums.hit("Kick", at=b0, vel=96)
        drums.hit("Kick", at=b0 + 2, vel=88)
        for off in (1.0, 3.0):
            drums.hit("Hi Wood Block", at=b0 + off, vel=78)
        for e in range(8):
            drums.hit("Tambourine", at=b0 + e * 0.5, vel=46 if e % 2 else 60)
        if bar % 8 == 7:
            for k, n in enumerate(["Low Wood Block", "Hi Wood Block", "Low Wood Block", "Hand Clap"]):
                drums.hit(n, at=b0 + 2 + k * 0.5, vel=90)
    # The tune: xylophone doubled by tin whistle an octave down on the B section.
    t = 0.0
    for i, (n, d) in enumerate(MEL):
        if n:
            xylo.at(t).note(n, d * 0.9, 96)
            if 64 <= t < 96:
                whistle.at(t).note(n - 12 if n - 12 >= 60 else n, d * 0.95, 70)
        t += d
    assert abs(t - 128.0) < 1e-6, t
    # Glockenspiel sparkle on the downbeat of each phrase.
    for bar in range(0, 32, 4):
        glock.at(bar * 4.0).note(84 if bar % 8 == 0 else 81, 1.5, 60)
    return s


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    wav = os.path.join(OUT, "top_your_pals_theme.wav")
    build().render_loop(wav, loop_beats=128, reps=4, gain=0.55)
    ff = shutil.which("ffmpeg") or r"C:\Users\Parke\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1.2-full_build\bin\ffmpeg.exe"
    ogg = wav[:-4] + ".ogg"
    subprocess.run([ff, "-y", "-loglevel", "error", "-i", wav, "-c:a", "libvorbis", "-q:a", "6", ogg], check=True)
    os.remove(wav)
    print("wrote", ogg)
