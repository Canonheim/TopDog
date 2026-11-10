# docs/music: how Top Dog makes its music

Start here. This folder is everything an LLM (or a person) needs to write new music for Top Dog the way
the house does it: compose in Python, render through the GeneralUser GS SoundFont with FluidSynth, and
come out with a seamless loop the game plays forever.

| File | What |
|---|---|
| `MAKING_MUSIC.md` | **The method.** What's in the repo, picking sounds, the render settings, the `sf_kit` toolkit, how seamless loops are made, the rules that make loops work, measuring, and putting a loop in the game. Read all of it before writing music code |
| `PRESETS.md` | Every sound in the soundfont (287 presets), by bank and program, generated from the `.sf2` |

The tools themselves live in the repo, so nothing needs installing beyond `pip install mido numpy soundfile`:

| Path | What |
|---|---|
| `tools/music/sf_kit.py` | the toolkit (compose in beats, render, `render_loop`) |
| `tools/music/example_loop.py` | an 8-bar loop that proves everything works: `python tools/music/example_loop.py` |
| `tools/music/theme_luchador.py` | the Top Dog title theme, a full worked piece |
| `tools/music/theme.py` | an earlier jazz theme, another worked piece (swing) |
| `tools/bin/fluidsynth/` | the synthesizer (Windows x64) |
| `tools/soundfonts/GeneralUser-GS.sf2` | the soundfont and its licence |
| `audio/music/` | the shipped loops; `core/sound.gd`'s `MUSIC` table names them |

A brief for a new piece, to hand over with this folder:

> Read `docs/music/README.md` and `docs/music/MAKING_MUSIC.md`. Write `tools/music/<name>.py` with
> `sf_kit`: a seamless loop of N bars at a tempo from the sample-exact list, in the mood of <...>.
> Render it into `audio/music/`, report the seam line (it must say OK), the length in beats and seconds,
> and the channel plan.
