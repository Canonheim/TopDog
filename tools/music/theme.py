"""TOP YOUR PALS: the main theme, take two. Parker: "Make it Fun and jazzy and smooth."

A swinging jazz loop in Bb: walking acoustic bass, a brush kit, tine electric piano
comping (rootless 3-7-9 voicings, Charleston rhythms), soft Freddie-Green jazz guitar
on all four, vibraphone carrying the tune with a muted trumpet taking the second
chorus and the bridge answered by flute. 126 bpm (44100*60/126 = 21000, sample-exact),
32 bars = 128 beats, AABA, continuous: the last bar's ii-V leads home to bar 1.

Swing: straight eighths are written as positions in eighths; the off-eighth lands at
2/3 of the beat (triplet swing).

Render: python theme.py  ->  audio/music/top_your_pals_theme.ogg
"""
import os
import random
import shutil
import subprocess

from sf_kit import Song

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "..", "audio", "music"))
TEMPO = 126
SWING = 2.0 / 3.0
random.seed(4)

# ---- harmony: one chord per bar (two per bar in the bridge's last bars) ---------
# name -> (bass root midi, rhodes voicing midi list, guitar 3-note voicing)
CH = {
    "Bbmaj7": (46, [62, 65, 69, 72], [58, 62, 69]),       # D F A C  (3 5 7 9)
    "Gm7":    (43, [58, 62, 65, 69], [55, 58, 65]),       # Bb D F A
    "Cm7":    (48, [63, 67, 70, 74], [60, 63, 70]),       # Eb G Bb D
    "F7":     (41, [57, 63, 64, 67], [53, 57, 63]),       # A Eb E(9?) -> use A Eb G: 3 7 9
    "Dm7":    (50, [60, 65, 69, 72], [57, 60, 65]),       # C F A C
    "G7":     (43, [59, 65, 69, 70], [55, 59, 65]),       # B F A Bb(#9 flavour)
    "Ebmaj7": (51, [55, 58, 62, 65], [51, 55, 62]),       # G Bb D F
    "Ab7":    (44, [60, 66, 70, 72], [56, 60, 66]),       # C Gb Bb C
}
CH["F7"] = (41, [57, 63, 67, 70], [53, 57, 63])           # A Eb G Bb: 3 7 9 11

A_PROG = ["Bbmaj7", "Gm7", "Cm7", "F7", "Dm7", "G7", "Cm7", "F7"]
B_PROG = ["Ebmaj7", "Ab7", "Bbmaj7", "G7", "Cm7", "F7", ("Dm7", "G7"), ("Cm7", "F7")]
PROG = A_PROG + A_PROG + B_PROG + A_PROG  # 32 bars

# ---- the tune: (midi or 0 for a rest, length in straight eighths); 64 per section
MEL_A = [
    (0, 1), (74, 1), (77, 1), (81, 2), (79, 1), (77, 2),
    (74, 3), (70, 1), (74, 2), (0, 2),
    (75, 1), (79, 1), (82, 2), (81, 1), (79, 1), (77, 2),
    (75, 2), (72, 2), (69, 2), (0, 2),
    (77, 1), (81, 1), (84, 2), (82, 1), (81, 1), (77, 2),
    (80, 1), (79, 1), (77, 2), (74, 2), (71, 2),
    (72, 2), (75, 1), (79, 1), (77, 2), (75, 2),
    (74, 2), (72, 4), (0, 2),
]
MEL_A2 = MEL_A[:-8] + [
    (79, 1), (82, 1), (84, 2), (82, 1), (79, 1), (77, 2),
    (75, 1), (74, 1), (72, 2), (69, 2), (0, 2),
]
MEL_B = [
    (79, 2), (82, 2), (86, 2), (84, 1), (82, 1),
    (80, 2), (78, 1), (75, 1), (72, 2), (0, 2),
    (77, 1), (81, 1), (86, 2), (84, 1), (82, 1), (81, 2),
    (77, 2), (74, 2), (71, 2), (74, 2),
    (75, 1), (79, 1), (82, 2), (84, 2), (82, 2),
    (81, 2), (75, 2), (72, 2), (69, 2),
    (74, 1), (77, 1), (81, 2), (80, 1), (79, 1), (77, 2),
    (75, 2), (74, 2), (72, 2), (69, 1), (70, 1),
]
for name, m in [("A", MEL_A), ("A2", MEL_A2), ("B", MEL_B)]:
    assert sum(d for _, d in m) == 64, (name, sum(d for _, d in m))


def swing_pos(eighths):
    """Straight eighth index -> beat position with triplet swing on the off-eighths."""
    beat, half = divmod(eighths, 2)
    return beat + (SWING if half else 0.0)


def swing_len(start_e, dur_e):
    return swing_pos(start_e + dur_e) - swing_pos(start_e)


def play_melody(track, mel, bar0, vel=92, octave=0, legato=0.88):
    e = bar0 * 8
    for n, d in mel:
        if n:
            t0 = swing_pos(e) + random.uniform(-0.015, 0.015)
            track.at(t0).note(n + octave, swing_len(e, d) * legato, vel + random.randint(-7, 6))
        e += d


def chords_in_bar(entry):
    return list(entry) if isinstance(entry, tuple) else [entry]


def build():
    s = Song(tempo=TEMPO)
    bass = s.track("Acoustic Bass")
    rhodes = s.track("Tine Electric Piano")
    guitar = s.track("Jazz Guitar")
    vibes = s.track("Vibraphone")
    trumpet = s.track("Muted Trumpet")
    flute = s.track("Flute")
    drums = s.drums(40)  # Brush Kit

    # Bass: walking quarters. Root, then chord tones, then a chromatic approach to the next root.
    for bar, entry in enumerate(PROG):
        b0 = bar * 4.0
        chords = chords_in_bar(entry)
        nxt = chords_in_bar(PROG[(bar + 1) % len(PROG)])[0]
        next_root = CH[nxt][0]
        if len(chords) == 1:
            root, voicing, _ = CH[chords[0]]
            third = voicing[0] - 12 if voicing[0] - 12 > root else voicing[0] - 24
            fifth = root + 7
            approach = next_root + random.choice([-1, 1, -2])
            line = [root, third if random.random() < 0.6 else root + 12, fifth, approach]
        else:
            r1 = CH[chords[0]][0]
            r2 = CH[chords[1]][0]
            line = [r1, r1 + 7, r2, next_root + random.choice([-1, 1])]
        for k, n in enumerate(line):
            while n > 55:
                n -= 12
            while n < 38:
                n += 12
            bass.at(b0 + k).note(n, 0.92, 88 + random.randint(-6, 6))

    # Rhodes: Charleston comping, alternating figures, soft. Guitar: four-to-the-bar, softer.
    figures = [
        [(0, 1.5), (3, 0.5)],          # beat 1 long, "and of 2" short
        [(1, 0.5), (4, 1.5)],          # "and of 1", beat 3
        [(3, 0.5), (6, 1.0)],          # "and of 2", beat 4
        [(0, 1.0), (5, 0.5), (7, 0.5)],
    ]
    for bar, entry in enumerate(PROG):
        b0 = bar * 4.0
        chords = chords_in_bar(entry)
        fig = figures[(bar + bar // 8) % len(figures)]
        for i, (e, dur_beats) in enumerate(fig):
            ch = chords[0] if len(chords) == 1 or e < 4 else chords[1]
            voicing = CH[ch][1]
            t = b0 + swing_pos(e)
            rhodes.at(t).chord(voicing, dur_beats, 56 + random.randint(-6, 8), strum=0.018)
        for k in range(4):
            ch = chords[0] if len(chords) == 1 or k < 2 else chords[1]
            guitar.at(b0 + k).chord(CH[ch][2], 0.55, 44 if k % 2 == 0 else 38)

    # Brush kit: ride swing, hats on 2 and 4, feathered kick, a few snare brushes, crashes on the top of sections.
    for bar in range(32):
        b0 = bar * 4.0
        for k in range(4):
            drums.hit("Ride Cymbal 1", at=b0 + k, vel=78 if k % 2 == 0 else 70)
            if k % 2 == 1:
                drums.hit("Ride Cymbal 1", at=b0 + k + SWING, vel=58)
                drums.hit("Pedal Hi-Hat", at=b0 + k, vel=72)
            drums.hit("Kick", at=b0 + k, vel=34 if k % 2 == 0 else 26)
        if bar % 2 == 1:
            drums.hit("Acoustic Snare", at=b0 + 1 + SWING, vel=44)
        if bar % 4 == 3:
            drums.hit("Acoustic Snare", at=b0 + 3 + SWING, vel=52)
            drums.hit("Side Stick", at=b0 + 3, vel=46)
        if bar % 8 == 0:
            drums.hit("Crash Cymbal 1", at=b0, vel=64)
        if bar % 8 == 7:
            for k, nm in enumerate(["Low-Mid Tom", "Acoustic Snare", "Low Tom", "Acoustic Snare"]):
                drums.hit(nm, at=b0 + 2 + k * 0.5, vel=58 + k * 4)

    # The tune. A: vibes. A2: muted trumpet, vibes answering an octave up on the long notes.
    # B: flute lead with vibes underneath. A: vibes and trumpet together.
    play_melody(vibes, MEL_A, 0, vel=94)
    play_melody(trumpet, MEL_A2, 8, vel=84, legato=0.8)
    e = 64
    for n, d in MEL_A2:
        if n and d >= 3:
            vibes.at(swing_pos(e) + 0.05).note(n + 12, swing_len(e, d) * 0.7, 60)
        e += d
    play_melody(flute, MEL_B, 16, vel=86, legato=0.92)
    play_melody(vibes, MEL_B, 16, vel=62, octave=-12, legato=0.6)
    play_melody(vibes, MEL_A, 24, vel=96)
    play_melody(trumpet, MEL_A, 24, vel=74, octave=-12, legato=0.8)
    return s


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    wav = os.path.join(OUT, "top_your_pals_theme.wav")
    build().render_loop(wav, loop_beats=128, reps=4, gain=0.5)
    ff = shutil.which("ffmpeg") or r"C:\Users\Parke\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1.2-full_build\bin\ffmpeg.exe"
    ogg = wav[:-4] + ".ogg"
    subprocess.run([ff, "-y", "-loglevel", "error", "-i", wav, "-c:a", "libvorbis", "-q:a", "6", ogg], check=True)
    os.remove(wav)
    print("wrote", ogg)
