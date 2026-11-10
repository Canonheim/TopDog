# Making music for Top Dog with GeneralUser GS

How the house composes, renders and loops game music with one free SoundFont, one free synthesizer, and
Python scripts that *are* the score. It's the method from our other game, written for Top Dog and given to
an LLM to work from. Read all of it before writing code. You cannot hear the result, so the method leans
on determinism and measurement.

The short version: **a piece of music is a Python script.** Running it writes a MIDI file and renders it
through the GeneralUser GS SoundFont with FluidSynth into a seamless loop. The script is the only source
of truth; editing a melody means editing a table near the top of the script and re-running it.

Everything you need is already in this repo. Nothing to download except three Python packages.

---

## 1. What is in the repo

| Thing | Where | What |
|---|---|---|
| **FluidSynth** (Windows x64) | `tools/bin/fluidsynth/` | the synthesizer: MIDI + SoundFont in, WAV out. `fluidsynth.exe` and its DLLs must stay together |
| **GeneralUser GS** v2.0 | `tools/soundfonts/GeneralUser-GS.sf2` | the SoundFont: 287 presets in 19 banks (the 128 General MIDI instruments, GS variations, drum kits), by S. Christian Collins. Free for private and commercial use; its licence sits beside it |
| **sf_kit** | `tools/music/sf_kit.py` | the toolkit: compose in beats, write MIDI, render, render seamless loops (section 4) |
| **the example** | `tools/music/example_loop.py` | an 8-bar loop that proves the whole road works |
| **real pieces** | `tools/music/theme_luchador.py`, `tools/music/theme.py` | the Top Dog title theme (cartoon mariachi lucha romp, 168 bpm) and the older jazz theme. Read these to see the method on full pieces |
| **every sound** | `docs/music/PRESETS.md` | the full preset list, read from the soundfont |

Python 3 needs `mido`, `numpy` and `soundfile`:

```
pip install mido numpy soundfile
```

Prove it works (from the repo root):

```
python tools/music/example_loop.py
```

It writes `example_loop.wav` and prints a line ending in `-> OK`. If that plays, everything below works.

`sf_kit` finds FluidSynth and the soundfont relative to its own file, so it works from any checkout with
no setup. FluidSynth here is the Windows build; on macOS or Linux, install FluidSynth from your package
manager and change `FLUID` at the top of `sf_kit.py` to `"fluidsynth"`.

---

## 2. The soundfont, and how to pick a sound

A sound is a **(bank, program)** pair, selected in MIDI by `CC0 = bank`, `CC32 = 0`, then
`Program Change = program`. `sf_kit` does this for you: `song.track("Trumpet")` looks the name up.
Bank 0 is the General MIDI set:

| Programs | Family | Examples |
|---|---|---|
| 0 to 7 | pianos | 0 Grand Piano, 6 Harpsichord |
| 8 to 15 | chromatic percussion | 8 Celeste, 9 Glockenspiel, 10 Music Box, 11 Vibraphone, 12 Marimba, 13 Xylophone, 14 Tubular Bells |
| 16 to 23 | organs | 16 Tonewheel Organ, 19 Pipe Organ, 21 Accordion |
| 24 to 31 | guitars | 24 Nylon Guitar, 25 Steel Guitar, 27 Clean Guitar, 29 Overdrive, 30 Distortion |
| 32 to 39 | basses | 32 Acoustic Bass, 33 Finger Bass, 36 Slap Bass 1, 38 Synth Bass 1 |
| 40 to 47 | strings | 40 Violin, 42 Cello, 45 Pizzicato Strings, 46 Orchestral Harp, 47 Timpani |
| 48 to 55 | ensembles and choir | 48 Fast Strings, 49 Slow Strings, 52 Concert Choir, 55 Orchestra Hit |
| 56 to 63 | brass | 56 Trumpet, 57 Trombone, 58 Tuba, 59 Muted Trumpet, 60 French Horns, 61 Brass Section |
| 64 to 79 | reeds and pipes | 64 to 67 saxophones, 71 Clarinet, 73 Flute, 75 Pan Flute, 78 Whistle |
| 80 to 103 | synth leads, pads and effects | 80 Square Lead, 81 Saw Lead, 88 Fantasia, 89 Warm Pad, 94 Halo Pad |
| 104 to 111 | ethnic | 105 Banjo, 107 Koto, 109 Bagpipes, 110 Fiddle |
| 112 to 119 | percussive | 113 Agogo, 114 Steel Drums, 115 Wood Block, 116 Taiko Drum, 118 Synth Drum |
| 120 to 127 | sound effects | 122 Seashore, 126 Applause |

The other banks hold GS variations under the same program numbers (bank 8 program 25 is a 12-String Guitar,
bank 16 program 25 a Mandolin). **Look the real list up in `PRESETS.md`, or with `sf_kit.search("horn")`;
never guess a name.**

**Drums** live on MIDI channel 10 (channel 9 counting from zero). In this soundfont the kits are bank 120
(`CC0 = 120`; 128 can't be sent as a bank-select value). `song.drums()` sets that up; `song.drums(kit=16)`
picks the Power Kit (kits: 0 Standard, 8 Room, 16 Power, 24 Electronic, and more in `PRESETS.md`). Keys follow the GM drum map, and `sf_kit.DRUMS` names them all, the Latin set
included: 36 Kick, 38 Acoustic Snare, 39 Hand Clap, 42 Closed Hi-Hat, 46 Open Hi-Hat, 49 Crash,
41 to 50 toms, 54 Tambourine, 56 Cowbell, 60/61 bongos, 62 to 64 congas, 65/66 timbales, 69 Cabasa,
70 Maracas, 73/74 guiro, 75 Claves, 76/77 woodblocks.

Presets whose name ends in **"Nm"** play without random attack variation, so two renders come out the
same. Prefer them when that matters.

---

## 3. The render settings

Every render uses the same FluidSynth call, so two pieces never sound like two different rooms:

```
fluidsynth -ni -F out.wav -r 44100 -g 0.6
  -o synth.reverb.damp=0.3 -o synth.reverb.level=0.4 -o synth.reverb.room-size=0.4 -o synth.reverb.width=0.8
  -o synth.chorus.depth=3.6 -o synth.chorus.level=0.55 -o synth.chorus.nr=4 -o synth.chorus.speed=0.36
  -o synth.device-id=16
  GeneralUser-GS.sf2 in.mid
```

These settings are built into `sf_kit` (`_FX`). `-g` is the master gain: 0.6 normally, down to about
0.35 to 0.55 for dense mixes that clip. `-r 44100` is the sample rate. `synth.device-id=16` makes the GS
system-exclusive messages land. `render_loop(..., chorus=False)` drops the chorus, and
`fx_extra=["-o", "synth.reverb.level=0.25"]` overrides any one setting for one render.

---

## 4. The toolkit: compose in beats, emit MIDI, render

`tools/music/sf_kit.py` is the whole core. Everything is written in **beats** (a quarter note is 1.0).

```python
from sf_kit import Song, chord, scale, find, search, PRESETS, DRUMS

s = Song(tempo=105)                  # a sample-exact tempo (section 5)
lead = s.track("Accordion")          # one track = one MIDI channel = one instrument
bass = s.track("Acoustic Bass")
kit = s.drums()                      # channel 10, GS drum bank

lead.at(0).notes([(69, .75), (69, .25), (74, 1)], vel=90)   # (note, beats) or (note, beats, velocity)
lead.note(72, 1.0, 88)               # one note at the cursor, then the cursor moves on
lead.chord(chord(50, "min"), 1.0, 70, strum=0.02)           # a strummed chord
lead.rest(2)                         # a rest: move the cursor on 2 beats
lead.at(16)                          # jump the cursor to beat 16
lead.cc(7, 100, at=0)                # a controller: 7 volume, 10 pan, 11 expression
lead.ramp_cc(11, 40, 110, 0, 8)      # a swell over beats 0 to 8
kit.hit("Kick", 0)                   # a drum by name at a beat
kit.hit("Hand Clap", 1, vel=90)

s.save_midi("piece.mid")             # the MIDI only
s.render("piece.wav")                # a straight render
s.render_loop("piece_loop.wav", loop_beats=32)   # a SEAMLESS loop
```

Helpers: `chord(root, "maj" | "min" | "dim" | "aug" | "sus2" | "sus4" | "maj7" | "min7" | "dom7" | "add9" | "5" | "min9")`
gives MIDI notes; `scale(root, "major" | "minor" | "dorian" | "mixolydian" | "lydian" | "phrygian" |
"harmonic_minor" | "pentatonic" | "minor_pentatonic" | "blues" | "chromatic", octaves=1)`; `search("sax")`
lists matching presets; `find("Trumpet")` gives `(bank, program)`. MIDI note 60 is middle C.

### How `render_loop` makes a seamless loop

This is the heart of the method. A loop rendered once has a seam: the reverb and the note tails at the
end don't match the silence at the start. So `render_loop` renders the content **`reps` times back to
back** (8 by default), so every repetition after the first starts with the previous one's tails ringing
in, exactly as it will in the game. It then scores every interior repetition by how cleanly its last
sample meets its first, keeps the cleanest one, and, if even that one steps (a big reverb wash that
never settles), blends the last 10 ms into the audio that came just before it. Finally it normalises to
a 0.89 peak and prints the verdict:

```
example_loop.wav: 18.2857s  kept iter 4/8  seam=0.000086 vs delta=0.011327 -> OK
```

`seam` is the jump at the wrap; `delta` is a typical sample-to-sample step. `OK` means the seam is under
four steps and inaudible. **Ship nothing marked AUDIBLE.** For long pieces use fewer reps
(`reps=4`, as the title theme does) to keep the render quick; you need at least 3.

The loop's length is exactly `loop_beats * 60 / tempo` seconds, and in samples exactly
`loop_beats * 44100 * 60 / tempo`, which is why the tempo matters (section 5).

---

## 5. The rules that make loops work

These aren't taste; each exists because its absence broke something.

1. **A fixed bar form, continuous and loopable.** No intro, no outro. The last bar carries a turnaround
   that leads harmonically back to bar 1 (a V7 back to i, a ii-V home), so the loop seam is a musical
   event, not a cut. 16 to 48 bars of 4/4 is the usual size. Pass the form's length as `loop_beats`.
2. **A sample-exact tempo.** `44100 * 60 / BPM` must be a whole number, or the loop length is a fraction
   of a sample and the seam drifts. Usable tempos: **60, 63, 70, 72, 75, 80, 84, 90, 98, 100, 105, 108,
   112, 120, 125, 126, 135, 140, 144, 147, 150, 168, 175, 180, 189, 196, 200.**
3. **The melody is plain.** Eighths and quarters, no flurries or grace-note runs. Character comes from the
   layers (who plays it, what backs it), not from ornament. A turnaround never quotes the phrase it leads
   into.
4. **Chords from a small set whose roots make a bass line.** The bass plays root and fifth (no thirds), the
   shared skeleton every layer rides on.
5. **Sixteen channels, one layer each.** Lead, a second voice that joins on the repeat, rhythm (real
   accompaniment patterns: bass-strum-strum, boom-chuck, off-beat skanks), bass, warmth (a pad), sparkle
   (glockenspiel, marimba), and the drum kit on channel 10. Humanise velocities with a strong-weak-mid
   cycle (100, 80, 86, 94, 80, 88) or a small `random` jitter with a fixed `random.seed`, so every render
   is identical. Bring layers in on the second time through, or only in one section.
6. **Unison beats counterpoint for a second voice.** When a second instrument should be heard *with* the
   lead, put it on the same notes, or a third above in the same rhythm (the title theme's two trumpets).
   An octave below in the same rhythm fuses into one timbre and is heard as tone colour, not a second
   player.
7. **One note per channel at a time.** A new note on a channel while the same pitch still sounds garbles
   ("two notes mushed together"). `sf_kit` shortens every note by 8 ticks to prevent the exact-overlap
   case; for sustained voices, leave a gap before the next attack on the same pitch.
8. **Level is not timbre.** Turning a channel up changes loudness only. For a harder sound (a pianist
   slamming, a drummer hitting), raise the **velocity**: GS hardens the timbre with velocity.
9. **Slower pieces expose everything.** Simplify, never decorate, when the tempo drops.
10. **Fix it in the script.** Never edit a render by hand. Every change is a change to the script, then a
    re-run.

### Variations of one tune

Need a calmer menu version, a tense final-round version, a slowed pause version? **Derive, don't
recompose.** Take the same script and change only numbers: a tempo from the list, which channels play
(a channel missing is silent), a softer velocity, an instrument swapped on a channel (lead to vibraphone,
rhythm to a warm pad), more reverb (`fx_extra`). A darker version raises nothing new: flatten the sixth
and seventh of the same melody and end the turnaround on a harmonic-minor V to i. Recognisability is the
effect. Keep every variation on the same bar form, so they can crossfade on the beat in the game.

---

## 6. Measuring, because you can't listen

Every claim about a render is a number from the file, never a guess.

- **The loop seam.** `render_loop` prints OK or AUDIBLE. Ship nothing AUDIBLE.
- **The length.** Read the WAV back and check its sample count equals `loop_beats * 44100 * 60 / tempo`
  exactly.
- **Loudness.** Integrated LUFS (ITU-R BS.1770) and the peak. Pieces in one game should sit within a couple
  of LU of each other. `render_loop` normalises to a 0.89 peak; quieter pieces on purpose need a lower
  `normalize=`.
- **Harmony.** Read the MIDI back (`mido`) and assert every note-on has its note-off, every melody note is
  in the scale, every bar sums to its length.
- **Can a new part be heard?** Render with and without it (`normalize=None`, so the normaliser doesn't
  re-gain the quieter render) and diff the band energy in its register.
- **Zones.** A preset can jump several dB between sample zones (some harps drop about 4.5 dB across one
  octave boundary). If a soloed voice jumps, trim velocity by pitch where a zone boundary falls inside the
  melody.

A human listens last and decides. The numbers only make sure nothing is broken when they do.

---

## 7. Putting a loop in the game

Top Dog plays pre-rendered loops: one file per piece, looping forever on the `Music` bus.

1. Render into `audio/music/`: `render_loop("audio/music/<name>.wav", loop_beats=...)`.
2. **OGG or WAV.** OGG is about a tenth of the size. The title theme's script converts with ffmpeg:
   `ffmpeg -y -i <name>.wav -c:a libvorbis -q:a 6 <name>.ogg`. The game turns looping on for OGG in code.
   If you ship a **WAV** instead, its Godot import must loop: in the `.wav.import` file (or the Import dock)
   set `edit/loop_mode=2` (forward), `edit/loop_begin=0`, `edit/loop_end=-1`, as
   `audio/music/desert_snake.wav.import` does.
3. Register it in `core/sound.gd`'s `MUSIC` table: `"climb": "res://audio/music/desert_snake.wav"`.
4. The game picks the music in `game/main.gd`'s `show_screen` with `Sound.music(id)`: today the title and
   menus play `"title"`, and a match (and its pause) plays `"climb"`.
5. Open the project once in Godot (or run `--import`) so it imports the new file, and commit the audio file,
   its `.import`, and the script that made it.

---

## 8. The workflow for one new piece

1. **The brief.** A mood and a place in the game. Decide the form (bars, metre), a sample-exact tempo,
   the key and mode, the chord set, and the layer plan (which channel plays what).
2. **The script.** `tools/music/<name>.py`, copied from `example_loop.py` or `theme_luchador.py`. Its
   docstring says what it is, the tempo with its sample-exact check, the form, and the render command.
   Chords and melody as tables at the top; the arrangement as code below.
3. **Render and measure.** One run writes the loop. Check the seam line, the length and the loudness.
4. **Listen.** A human does this part. Change the tables, re-run, repeat.
5. **Ship** (section 7) and **record it**: the docstring holds the structure, chord chart, loop length in
   beats and samples, and the channel plan. The next piece starts from the last one.

Two worked pieces sit in `tools/music/`: `theme_luchador.py` (D minor verse into an F major chorus, two
trumpets in thirds, a trombone answering, vihuela-style off-beat nylon guitar, a guitarron-style bass,
marimba runs, a full Latin kit with timbale fills; 32 bars = 128 beats at 168 bpm) and `theme.py`
(a swinging AABA jazz loop at 126 bpm with a walking bass; swing is written by placing the off-eighth at
two thirds of the beat). The method doesn't change between them; only the tables do.
