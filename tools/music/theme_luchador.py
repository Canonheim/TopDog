"""TOP DOG: the main theme. Parker: "fun music that is cartoon luchador themed."

A cartoon lucha-libre romp: a mariachi brass section (two trumpets in thirds, a
trombone answering), vihuela-style strummed nylon guitar on the off-beats, a
guitarron-style bass bouncing root-fifth, marimba runs between phrases, and a full
Latin kit (timbales, congas, cowbell, claves, maracas, guiro) with timbale fills
and brass "hits" like a wrestler hitting the ring.

D minor verse into an F major chorus. 168 bpm (44100*60/168 = 15750, sample-
exact), 32 bars = 128 beats (~46 s), A A B C, continuous: the last bar's A7 turns
back to Dm.

Render: python theme_luchador.py  ->  audio/music/top_dog_theme.ogg
"""
import os
import random
import shutil
import subprocess

from sf_kit import Song

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "..", "audio", "music"))
TEMPO = 168
random.seed(11)

# chord name -> (bass root, guitar voicing, third-above helper for the 2nd trumpet)
CH = {
    "Dm": (38, [57, 62, 65, 69]),
    "Gm": (43, [55, 58, 62, 67]),
    "A7": (45, [57, 61, 64, 67]),
    "Bb": (46, [58, 62, 65, 70]),
    "F": (41, [57, 60, 65, 69]),
    "C7": (48, [55, 60, 64, 70]),
    "C": (48, [55, 60, 64, 67]),
}
VERSE = ["Dm", "Dm", "Gm", "Dm", "Dm", "A7", "A7", "Dm"]
VERSE2 = ["Dm", "Dm", "Gm", "Dm", "Bb", "A7", "Dm", "A7"]
BRIDGE = ["Gm", "Gm", "Dm", "Dm", "Bb", "Bb", "A7", "A7"]
CHORUS = ["F", "C7", "F", "Bb", "F", "C7", "Dm", "A7"]
PROG = VERSE + VERSE2 + BRIDGE + CHORUS

# Tunes in (midi, beats); each 32 beats. 0 = rest.
MEL_A = [
    (74, 1), (76, 0.5), (77, 0.5), (76, 1), (74, 1),  (69, 2), (0, 1), (69, 1),
    (70, 1), (74, 1), (79, 1.5), (77, 0.5),  (74, 3), (0, 1),
    (74, 1), (76, 0.5), (77, 0.5), (79, 1), (77, 1),  (76, 1), (73, 1), (69, 2),
    (76, 0.5), (77, 0.5), (79, 0.5), (76, 0.5), (73, 1), (76, 1),  (74, 3), (0, 1),
]
MEL_A2 = MEL_A[:14] + [
    (77, 1), (79, 0.5), (81, 0.5), (82, 1), (81, 1),  (79, 1), (76, 1), (73, 2),
    (74, 0.5), (76, 0.5), (77, 0.5), (79, 0.5), (81, 1), (73, 1),  (76, 2), (73, 2),
]
MEL_B = [
    (79, 2), (82, 1), (79, 1),  (77, 1), (74, 1), (70, 2),
    (77, 2), (81, 1), (77, 1),  (74, 1), (69, 1), (65, 2),
    (70, 1), (74, 1), (77, 1), (82, 1),  (81, 1), (79, 1), (77, 2),
    (76, 1), (77, 1), (79, 1), (81, 1),  (82, 1), (81, 1), (79, 1), (76, 1),
]
MEL_C = [
    (81, 1.5), (79, 0.5), (77, 1), (72, 1),  (76, 1), (79, 1), (82, 2),
    (81, 1.5), (79, 0.5), (77, 1), (81, 1),  (82, 1), (81, 1), (79, 2),
    (81, 1), (77, 1), (72, 1), (77, 1),  (79, 1), (76, 1), (72, 2),
    (74, 1), (77, 1), (81, 1), (77, 1),  (76, 1), (73, 1), (69, 1), (73, 1),
]
for nm, m in [("A", MEL_A), ("A2", MEL_A2), ("B", MEL_B), ("C", MEL_C)]:
    assert abs(sum(d for _, d in m) - 32) < 1e-9, (nm, sum(d for _, d in m))


def third_below(n, chord):
    """The 2nd trumpet: the nearest chord tone a third-ish below the melody note."""
    tones = sorted({t % 12 for t in CH[chord][1]})
    for drop in (3, 4, 5, 2):
        if (n - drop) % 12 in tones:
            return n - drop
    return n - 3


def play(track, mel, bar0, vel, harm=None, octave=0, legato=0.9):
    t = bar0 * 4.0
    for n, d in mel:
        if n:
            track.at(t).note(n + octave, d * legato, vel + random.randint(-6, 6))
            if harm is not None:
                chord = PROG[int(t // 4) % len(PROG)]
                harm.at(t).note(third_below(n, chord) + octave, d * legato, vel - 10)
        t += d


def build():
    s = Song(tempo=TEMPO)
    tpt1 = s.track("Trumpet")
    tpt2 = s.track("Trumpet 2")
    bone = s.track("Trombone")
    guitar = s.track("Nylon Guitar")
    bass = s.track("Acoustic Bass")
    marimba = s.track("Marimba")
    glock = s.track("Glockenspiel")
    drums = s.drums()

    for bar, ch in enumerate(PROG):
        b0 = bar * 4.0
        root, voicing = CH[ch]
        fifth = root + 7 if root + 7 <= 52 else root - 5
        # Guitarron bounce: root on 1, fifth on 3, a pickup on the and-of-4 every other bar.
        bass.at(b0).note(root, 0.8, 100)
        bass.at(b0 + 2).note(fifth, 0.8, 92)
        if bar % 2 == 1:
            bass.at(b0 + 3.5).note(root + 2 if root + 2 <= 50 else root - 1, 0.4, 84)
        # Vihuela strums: off-beat chops, a down-up on 4.
        for off in (1.0, 2.0, 3.0):
            guitar.at(b0 + off).chord(voicing, 0.35, 70 if off != 2.0 else 58, strum=0.012)
        guitar.at(b0 + 3.5).chord(voicing, 0.3, 54, strum=0.01)
        # Latin kit.
        drums.hit("Kick", at=b0, vel=92)
        drums.hit("Kick", at=b0 + 2, vel=84)
        drums.hit("Side Stick", at=b0 + 1, vel=72)
        drums.hit("Side Stick", at=b0 + 3, vel=76)
        for e in range(8):
            drums.hit("Maracas", at=b0 + e * 0.5, vel=58 if e % 2 else 70)
        for k, off in enumerate((0.0, 1.5, 3.0)):
            drums.hit("Claves", at=b0 + off + (0.0 if bar % 2 == 0 else 0.5 * (k == 1)), vel=74)
        drums.hit("Cowbell", at=b0, vel=80)
        drums.hit("Cowbell", at=b0 + 2.5, vel=66)
        drums.hit("Mute Hi Conga", at=b0 + 1.5, vel=70)
        drums.hit("Open Hi Conga", at=b0 + 2, vel=78)
        drums.hit("Low Conga", at=b0 + 3.5, vel=76)
        if bar % 4 == 2:
            drums.hit("Short Guiro", at=b0 + 1, vel=60)
            drums.hit("Long Guiro", at=b0 + 3, vel=64)
        if bar % 8 == 7:
            # Timbale fill into the next section, and a brass "hit" on the downbeat after.
            for k in range(8):
                drums.hit("High Timbale" if k % 2 == 0 else "Low Timbale", at=b0 + 2 + k * 0.25, vel=70 + k * 4)
        if bar % 8 == 0:
            drums.hit("Crash Cymbal 1", at=b0, vel=86)
            for tr in (tpt1, tpt2, bone):
                pass

    # Brass hits on each section's downbeat (the wrestler hits the ring).
    for sec in range(4):
        b0 = sec * 32.0
        ch = PROG[sec * 8]
        root, voicing = CH[ch]
        bone.at(b0).chord([root + 12, root + 19], 0.6, 104)
        tpt2.at(b0).note(voicing[1] + 12, 0.6, 100)

    # The tunes. A: trumpets in thirds. A2: trumpets, trombone answering the long notes.
    # B: marimba leads, trombone underneath. C (the chorus): everybody, glock sparkle.
    play(tpt1, MEL_A, 0, 98, harm=tpt2)
    play(tpt1, MEL_A2, 8, 100, harm=tpt2)
    t = 32.0
    for n, d in MEL_A2:
        if n and d >= 2:
            bone.at(t + d * 0.5).notes([(n - 12, d * 0.25, 82), (n - 15, d * 0.25, 78)])
        t += d
    play(marimba, MEL_B, 16, 96, octave=0, legato=0.6)
    play(bone, MEL_B, 16, 84, octave=-12, legato=0.85)
    play(tpt1, MEL_C, 24, 104, harm=tpt2)
    play(bone, MEL_C, 24, 86, octave=-12)
    play(glock, MEL_C, 24, 58, octave=12, legato=0.4)
    # Marimba runs in the gaps of the verses.
    for bar in (3, 7, 11, 15):
        b0 = bar * 4.0 + 2.0
        ch = PROG[bar]
        tones = CH[ch][1]
        run = [tones[0] + 12, tones[1] + 12, tones[2] + 12, tones[3] + 12, tones[2] + 12, tones[1] + 12, tones[0] + 12, tones[1] + 12]
        marimba.at(b0).notes([(n, 0.25, 84) for n in run])
    return s


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    wav = os.path.join(OUT, "top_dog_theme.wav")
    build().render_loop(wav, loop_beats=128, reps=4, gain=0.55)
    ff = shutil.which("ffmpeg") or r"C:\Users\Parke\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1.2-full_build\bin\ffmpeg.exe"
    ogg = wav[:-4] + ".ogg"
    subprocess.run([ff, "-y", "-loglevel", "error", "-i", wav, "-c:a", "libvorbis", "-q:a", "6", ogg], check=True)
    os.remove(wav)
    print("wrote", ogg)
